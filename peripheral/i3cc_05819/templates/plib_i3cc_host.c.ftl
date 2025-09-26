/*******************************************************************************
  Improved Inter-Integrated Circuit (I3C) Host/Controller Library
  Source File

  Company:
    Microchip Technology Inc.

  File Name:
    plib_${I3CC_INSTANCE_NAME?lower_case}_host.c

  Summary:
    I3CC PLIB Host/Controller Mode Implementation file

  Description:
    This file defines the interface to the I3CC host/controller peripheral library.
    This library provides access to and control of the associated peripheral
    instance.

*******************************************************************************/
// DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2024-2025 Microchip Technology Inc. and its subsidiaries.
*
* Subject to your compliance with these terms, you may use Microchip software
* and any derivatives exclusively with Microchip products. It is your
* responsibility to comply with third party license terms applicable to your
* use of third party software (including open source software) that may
* accompany Microchip software.
*
* THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER
* EXPRESS, IMPLIED OR STATUTORY, APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED
* WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND FITNESS FOR A
* PARTICULAR PURPOSE.
*
* IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE,
* INCIDENTAL OR CONSEQUENTIAL LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND
* WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF MICROCHIP HAS
* BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE
* FULLEST EXTENT ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN
* ANY WAY RELATED TO THIS SOFTWARE WILL NOT EXCEED THE AMOUNT OF FEES, IF ANY,
* THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
*******************************************************************************/
// DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

<#assign ibi_ctrl = "">

<#if NOTIFY_REJ_IBI>
    <#assign ibi_ctrl = ibi_ctrl + "I3CC_IBI_NOTIFY_CTRL_NOTIFY_IBI_REJECTED_Msk">
</#if>

<#if NOTIFY_REJ_CONTROLLER_REQ>
    <#if ibi_ctrl != "">
        <#assign ibi_ctrl = ibi_ctrl + " | ">
    </#if>
    <#assign ibi_ctrl = ibi_ctrl + "I3CC_IBI_NOTIFY_CTRL_NOTIFY_CRR_REJECTED_Msk">
</#if>

<#if NOTIFY_REJ_HJ_REQ>
    <#if ibi_ctrl != "">
        <#assign ibi_ctrl = ibi_ctrl + " | ">
    </#if>
    <#assign ibi_ctrl = ibi_ctrl + "I3CC_IBI_NOTIFY_CTRL_NOTIFY_HJ_REJECTED_Msk">
</#if>

#include "plib_i3cc_host.h"
#include "interrupts.h"
#include <string.h>
#include "peripheral/${INT_CONTROLLER?lower_case}/plib_${INT_CONTROLLER?lower_case}.h"

#define I3CC_DEV_INFO_INDEX_INVALID             ((uint8_t)0xFF)

static I3CC_HOST ${I3CC_INSTANCE_NAME?lower_case}_host;
static I3CC_XFER_QUEUE xfer_queue[I3CC_XFER_QUEUE_SIZE];

#define BITMASK(bitfield)               (bitfield##_Msk)
#define BITPOS(bitfield)                (bitfield##_Pos)
#define SET_BITS(reg, bitfield, val)    ((reg) = (((reg) & ~BITMASK(bitfield)) | (((uint32_t)val) << BITPOS(bitfield))))
#define CLR_BITS(reg, bitfield)         ((reg) = ((reg) & ~BITMASK(bitfield)))
#define GET_BITS(reg, bitfield)         (((reg) & BITMASK(bitfield)) >> BITPOS(bitfield))
#define WORD_TO_BYTE(val)               ((uint32_t)(val) << 2U)
#define BYTE_TO_WORD(val)               ((val) >> 2U)

#define I3CC_ENTER_CRITICAL(int_src)                     ${INT_CONTROLLER}_INT_SourceDisable(int_src)
#define I3CC_EXIT_CRITICAL(int_src, status)              ${INT_CONTROLLER}_INT_SourceRestore(int_src, status)

bool ${I3CC_INSTANCE_NAME}_Host_IsBusy(void)
{
    return ${I3CC_INSTANCE_NAME?lower_case}_host.isBusy;
}

static void ${I3CC_INSTANCE_NAME}_Host_CmdZeroInit(I3CC_CMD_DESC* cmdDesc)
{
    cmdDesc->cmd_words.cmd_word0 = 0U;
    cmdDesc->cmd_words.cmd_word1 = 0U;
}

static I3CC_XFER_ID ${I3CC_INSTANCE_NAME}_Host_XferIdGet(void)
{
    ${I3CC_INSTANCE_NAME?lower_case}_host.xfer_cntr += 1U;
    if (${I3CC_INSTANCE_NAME?lower_case}_host.xfer_cntr == I3CC_XFER_ID_INVALID)
    {
        ${I3CC_INSTANCE_NAME?lower_case}_host.xfer_cntr = 0U;
    }
    return ${I3CC_INSTANCE_NAME?lower_case}_host.xfer_cntr;
}

static uint8_t ${I3CC_INSTANCE_NAME}_Host_XferTIDGet(I3CC_XFER_ID xfer_id)
{
    return (uint8_t)(xfer_id & 0x0FU);
}

static I3CC_XFER_QUEUE* ${I3CC_INSTANCE_NAME}_Host_GetFreeQElement(I3CC_XFER_QUEUE* qPool, uint32_t qPoolSize)
{
    for (uint32_t i = 0; i < qPoolSize; i++)
    {
        if (qPool[i].inUse == false)
        {
            qPool[i].inUse = true;
            qPool[i].next = NULL;
            return &qPool[i];
        }
    }
    return NULL;
}

static bool ${I3CC_INSTANCE_NAME}_Host_AddBackQ(I3CC_XFER_QUEUE** qHead, I3CC_XFER_QUEUE* qElement)
{
    if (*qHead == NULL)
    {
        qElement->next = NULL;
        *qHead = qElement;
    }
    else
    {
        I3CC_XFER_QUEUE* pQueue = *qHead;
        while (pQueue->next != NULL)
        {
            pQueue = pQueue->next;
        }
        pQueue->next = qElement;
    }

    return true;
}

static I3CC_XFER_QUEUE* ${I3CC_INSTANCE_NAME}_Host_RemoveFrontQ(I3CC_XFER_QUEUE** qHead)
{
    I3CC_XFER_QUEUE* qTop = *qHead;

    *qHead = (*qHead)->next;
    qTop->inUse = false;
    qTop->next = NULL;

    return qTop;
}

static void ${I3CC_INSTANCE_NAME}_Host_InitQ(void)
{
    for (uint32_t i = 0; i < ${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_pool_size; i++)
    {
        ${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_pool[i].inUse = false;
        ${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_pool[i].next = NULL;
    }

    ${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_head = NULL;
}

void ${I3CC_INSTANCE_NAME}_Host_Abort(void)
{
    bool i3cInterruptStatus = I3CC_ENTER_CRITICAL(I3CC_IRQn);

    ${I3CC_INSTANCE_NAME}_REGS->I3CC_HC_CONTROL |= I3CC_HC_CONTROL_ABORT_Msk;

    ${I3CC_INSTANCE_NAME?lower_case}_host.abortRequested = true;

    /* Return if there is no space to save the request */
    I3CC_EXIT_CRITICAL(I3CC_IRQn, i3cInterruptStatus);
}

void ${I3CC_INSTANCE_NAME}_Host_Resume(void)
{
    /* Depending on the error, the host controller may enter a halted state. Check for the present state and resume it if it is in halted state. */
    if (GET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_PRESENT_STATE_DEBUG, I3CC_PRESENT_STATE_DEBUG_CM_TFR_ST_STATUS) == I3CC_PRESENT_STATE_DEBUG_CM_TFR_ST_STATUS_HALT_Val)
    {
        ${I3CC_INSTANCE_NAME}_REGS->I3CC_HC_CONTROL |= I3CC_HC_CONTROL_RESUME_Msk;
    }
}

static bool ${I3CC_INSTANCE_NAME}_Host_IsQEmpty(I3CC_XFER_QUEUE* qHead)
{
    return qHead == NULL ? true : false;
}

/* The input threshold must be in double words */
static uint8_t ${I3CC_INSTANCE_NAME}_Host_GetThreshold_Floor(uint32_t thldDW)
{
    uint8_t low = 0;        //Corresponding to index for 1
    uint8_t high = 7;       //Corresponding to index for 256
    uint8_t mid;
    uint32_t curr_val;
    uint8_t ans = 0;
    uint32_t possible_values[] = {1, 4, 8, 16, 32, 64, 128, 256};

    while (low <= high)
    {
        mid = (low+high)/2U;
        curr_val = possible_values[mid];
        if (curr_val <= thldDW)
        {
            /* Return the index. For example, if 16, then return 3 and so on.. */
            ans = mid;
            low = mid + 1U;
        }
        else
        {
            high = mid - 1U;
        }
    }
    return ans;
}

void ${I3CC_INSTANCE_NAME}_Host_StatusEnable(uint32_t pioIntrStatusMsk)
{
    ${I3CC_INSTANCE_NAME}_REGS->I3CC_PIO_INTR_STATUS_ENABLE |= pioIntrStatusMsk;
}

void ${I3CC_INSTANCE_NAME}_Host_StatusDisable(uint32_t pioIntrStatusMsk)
{
    ${I3CC_INSTANCE_NAME}_REGS->I3CC_PIO_INTR_STATUS_ENABLE &= ~(pioIntrStatusMsk);
}

void ${I3CC_INSTANCE_NAME}_Host_SignalEnable(uint32_t pioIntrSignalMsk)
{
    ${I3CC_INSTANCE_NAME}_REGS->I3CC_PIO_INTR_SIGNAL_ENABLE |= pioIntrSignalMsk;
}

void ${I3CC_INSTANCE_NAME}_Host_SignalDisable(uint32_t pioIntrSignalMsk)
{
    ${I3CC_INSTANCE_NAME}_REGS->I3CC_PIO_INTR_SIGNAL_ENABLE &= ~(pioIntrSignalMsk);
}

uint32_t ${I3CC_INSTANCE_NAME}_Host_StatusGet(uint32_t pioIntrStatusMsk)
{
    return (${I3CC_INSTANCE_NAME}_REGS->I3CC_PIO_INTR_STATUS & pioIntrStatusMsk);
}

uint8_t ${I3CC_INSTANCE_NAME}_Host_QueueLevelGet(I3CC_QUEUE_LVL qLvl)
{
    uint8_t level = 0;

    switch(qLvl)
    {
        case I3CC_QUEUE_LVL_COMMAND_FREE_CNT:
            level = (uint8_t)GET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_QUEUE_STATUS_LEVEL, I3CC_QUEUE_STATUS_LEVEL_CMD_QUEUE_FREE_LVL);
            break;
        case I3CC_QUEUE_LVL_RESPONSE_CNT:
            level = (uint8_t)GET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_QUEUE_STATUS_LEVEL, I3CC_QUEUE_STATUS_LEVEL_RESPONSE_BUFFER_LVL);
            break;
        case I3CC_QUEUE_LVL_IBI_BUF_CNT:
            level = (uint8_t)GET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_QUEUE_STATUS_LEVEL, I3CC_QUEUE_STATUS_LEVEL_IBI_BUFFER_LVL);
            break;
        case I3CC_QUEUE_LVL_IBI_STATUS_CNT:
            level = (uint8_t)GET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_QUEUE_STATUS_LEVEL, I3CC_QUEUE_STATUS_LEVEL_IBI_STATUS_CNT);
            break;
        case I3CC_QUEUE_LVL_TX_BUF_FREE_CNT:
            level = (uint8_t)GET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_DATA_BUFFER_STATUS_LEVEL, I3CC_DATA_BUFFER_STATUS_LEVEL_TX_BUF_FREE_LVL);
            break;
        case I3CC_QUEUE_LVL_RX_BUF_CNT:
            level = (uint8_t)GET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_DATA_BUFFER_STATUS_LEVEL, I3CC_DATA_BUFFER_STATUS_LEVEL_RX_BUF_LVL);
            break;
        default:
            /* default case, return */
            break;
    }

    return level;
}

void ${I3CC_INSTANCE_NAME}_Host_QueueThresholdSet(I3CC_QUEUE_THLD qThresholdType, uint8_t threshold)
{
    switch(qThresholdType)
    {
        case I3CC_QUEUE_THLD_CMD_EMPTY:
            SET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_QUEUE_THLD_CTRL, I3CC_QUEUE_THLD_CTRL_CMD_EMPTY_BUF_THLD, threshold);
            break;
        case I3CC_QUEUE_THLD_RESPONSE_READY:
            SET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_QUEUE_THLD_CTRL, I3CC_QUEUE_THLD_CTRL_RESP_BUF_THLD, threshold);
            break;
        case I3CC_QUEUE_THLD_IBI_STATUS:
            SET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_QUEUE_THLD_CTRL, I3CC_QUEUE_THLD_CTRL_IBI_STATUS_THLD, threshold);
            break;
        case I3CC_QUEUE_THLD_TX_BUFFER_FREE:
            SET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_DATA_BUFFER_THLD_CTRL, I3CC_DATA_BUFFER_THLD_CTRL_TX_BUF_THLD, threshold);
            break;
        case I3CC_QUEUE_THLD_RX_BUFFER_AVAILABLE:
            SET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_DATA_BUFFER_THLD_CTRL, I3CC_DATA_BUFFER_THLD_CTRL_RX_BUF_THLD, threshold);
            break;
        case I3CC_QUEUE_THLD_TX_START:
            SET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_DATA_BUFFER_THLD_CTRL, I3CC_DATA_BUFFER_THLD_CTRL_TX_START_THLD, threshold);
            break;
        case I3CC_QUEUE_THLD_RX_START:
            SET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_DATA_BUFFER_THLD_CTRL, I3CC_DATA_BUFFER_THLD_CTRL_RX_START_THLD, threshold);
            break;
        case I3CC_QUEUE_THLD_IBI_DATA_SIZE:
            SET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_QUEUE_THLD_CTRL, I3CC_QUEUE_THLD_CTRL_IBI_DATA_SEGMENT_SIZE, threshold);
            break;
        default:
            /* default case, return */
            break;
    }
}

uint8_t ${I3CC_INSTANCE_NAME}_Host_QueueThresholdGet(I3CC_QUEUE_THLD qThresholdType)
{
    uint8_t threshold = 0;

    switch(qThresholdType)
    {
        case I3CC_QUEUE_THLD_CMD_EMPTY:
            threshold = (uint8_t)GET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_QUEUE_THLD_CTRL, I3CC_QUEUE_THLD_CTRL_CMD_EMPTY_BUF_THLD);
            break;
        case I3CC_QUEUE_THLD_RESPONSE_READY:
            threshold = (uint8_t)GET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_QUEUE_THLD_CTRL, I3CC_QUEUE_THLD_CTRL_RESP_BUF_THLD);
            break;
        case I3CC_QUEUE_THLD_IBI_STATUS:
            threshold = (uint8_t)GET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_QUEUE_THLD_CTRL, I3CC_QUEUE_THLD_CTRL_IBI_STATUS_THLD);
            break;
        case I3CC_QUEUE_THLD_TX_BUFFER_FREE:
            threshold = (uint8_t)GET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_DATA_BUFFER_THLD_CTRL, I3CC_DATA_BUFFER_THLD_CTRL_TX_BUF_THLD);
            break;
        case I3CC_QUEUE_THLD_RX_BUFFER_AVAILABLE:
            threshold = (uint8_t)GET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_DATA_BUFFER_THLD_CTRL, I3CC_DATA_BUFFER_THLD_CTRL_RX_BUF_THLD);
            break;
        case I3CC_QUEUE_THLD_TX_START:
            threshold = (uint8_t)GET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_DATA_BUFFER_THLD_CTRL, I3CC_DATA_BUFFER_THLD_CTRL_TX_START_THLD);
            break;
        case I3CC_QUEUE_THLD_RX_START:
            threshold = (uint8_t)GET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_DATA_BUFFER_THLD_CTRL, I3CC_DATA_BUFFER_THLD_CTRL_RX_START_THLD);
            break;
        case I3CC_QUEUE_THLD_IBI_DATA_SIZE:
            threshold = (uint8_t)GET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_QUEUE_THLD_CTRL, I3CC_QUEUE_THLD_CTRL_IBI_DATA_SEGMENT_SIZE);
            break;
        default:
            /* default case, return */
            break;
    }

    return threshold;
}

void ${I3CC_INSTANCE_NAME}_Host_QueueReset(I3CC_QUEUE_RESET qType)
{
    ${I3CC_INSTANCE_NAME}_REGS->I3CC_RESET_CONTROL = (uint32_t)qType;

    while ((${I3CC_INSTANCE_NAME}_REGS->I3CC_RESET_CONTROL & (uint32_t)qType) != 0U)
    {
        /* Wait for the queue reset to complete */
    }
}

void ${I3CC_INSTANCE_NAME}_Host_SoftReset(void)
{
    ${I3CC_INSTANCE_NAME}_REGS->I3CC_RESET_CONTROL = I3CC_RESET_CONTROL_SOFT_RST_Msk;

    while ((${I3CC_INSTANCE_NAME}_REGS->I3CC_RESET_CONTROL & I3CC_RESET_CONTROL_SOFT_RST_Msk) != 0U)
    {
        /* Wait for the queue reset to complete */
    }
}

void ${I3CC_INSTANCE_NAME}_Host_DATTableRead(void* pBuffer, uint8_t numDATEntries)
{
    uint32_t* pDATBuffer = (uint32_t*)pBuffer;
    uint8_t numEntriesToRead = numDATEntries > ${I3CC_INSTANCE_NAME?lower_case}_host.DATTableSize? ${I3CC_INSTANCE_NAME?lower_case}_host.DATTableSize: numDATEntries;

    for (uint8_t i = 0; (i < numEntriesToRead) ; i++)
    {
        *pDATBuffer++ = ${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr[i].word0.word;
        *pDATBuffer++ = ${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr[i].word1.word;
    }
}

void ${I3CC_INSTANCE_NAME}_Host_DATTableInitialize(I3CC_DAT_TABLE_ENTRY_TYPE type)
{
    I3CC_DAT_TABLE_ENTRY DATTableEntry;
    bool init = false;
    for (uint8_t i = 0; i < ${I3CC_INSTANCE_NAME?lower_case}_host.DATTableSize; i++)
    {
        DATTableEntry.word0.word = ${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr[i].word0.word;
        if ((type == I3CC_DAT_TABLE_ENTRY_TYPE_I3C) && (DATTableEntry.word0.bits.dev_type == (uint8_t)I3CC_DAT_TABLE_DEV_TYPE_I3C))
        {
            init = true;
        }
        else if ((type == I3CC_DAT_TABLE_ENTRY_TYPE_I2C) && (DATTableEntry.word0.bits.dev_type == (uint8_t)I3CC_DAT_TABLE_DEV_TYPE_I2C))
        {
            init = true;
        }
        else if (type == I3CC_DAT_TABLE_ENTRY_TYPE_ALL)
        {
            init = true;
        }
        else
        {
            init = false;
        }

        if (init)
        {
            DATTableEntry.word0.bits.static_addr = 0;
            DATTableEntry.word0.bits.dynamic_addr = 0;
            ${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr[i].word0.word = DATTableEntry.word0.word;
        }
    }
}


void ${I3CC_INSTANCE_NAME}_Host_Initialize(void)
{
    uint32_t DAT_TableOffset;
    uint8_t DAT_TableSize;
    uint32_t DCT_TableOffset;
    uint8_t DCT_TableSize;
    uint32_t PIO_Offset;

    ${I3CC_INSTANCE_NAME}_Host_SoftReset();

    ${I3CC_INSTANCE_NAME}_REGS->I3CC_SCL_I3C_OD_TIMING = I3CC_SCL_I3C_OD_TIMING_I3C_OD_LCNT(${SCL_OD_LCNT}) | I3CC_SCL_I3C_OD_TIMING_I3C_OD_HCNT(${SCL_OD_HCNT});

    ${I3CC_INSTANCE_NAME}_REGS->I3CC_SCL_I3C_PP_TIMING = I3CC_SCL_I3C_PP_TIMING_I3C_PP_LCNT(${SCL_PP_LCNT}) | I3CC_SCL_I3C_PP_TIMING_I3C_PP_HCNT(${SCL_PP_HCNT});

    ${I3CC_INSTANCE_NAME}_REGS->I3CC_SCL_I2C_FMP_TIMING = I3CC_SCL_I2C_FMP_TIMING_I2C_FMP_LCNT(${SCL_FMP_LCNT}) | I3CC_SCL_I2C_FMP_TIMING_I2C_FMP_HCNT(${SCL_FMP_HCNT});

    ${I3CC_INSTANCE_NAME}_REGS->I3CC_SCL_I2C_FM_TIMING = I3CC_SCL_I2C_FM_TIMING_I2C_FM_LCNT(${SCL_FM_LCNT}) | I3CC_SCL_I2C_FM_TIMING_I2C_FM_HCNT(${SCL_FM_HCNT});

    DAT_TableOffset = ${I3CC_INSTANCE_NAME}_REGS->I3CC_DAT_SECTION_OFFSET & I3CC_DAT_SECTION_OFFSET_TABLE_OFFSET_Msk;
    DAT_TableSize = (uint8_t)((${I3CC_INSTANCE_NAME}_REGS->I3CC_DAT_SECTION_OFFSET & I3CC_DAT_SECTION_OFFSET_TABLE_SIZE_Msk) >> I3CC_DAT_SECTION_OFFSET_TABLE_SIZE_Pos);

    if (DAT_TableOffset == 0U)
    {
        //printf("DAT Table not supported in hardware\r\n");
    }

    DCT_TableOffset = ${I3CC_INSTANCE_NAME}_REGS->I3CC_DCT_SECTION_OFFSET & I3CC_DCT_SECTION_OFFSET_TABLE_OFFSET_Msk;
    DCT_TableSize = (uint8_t)((${I3CC_INSTANCE_NAME}_REGS->I3CC_DCT_SECTION_OFFSET & I3CC_DCT_SECTION_OFFSET_TABLE_SIZE_Msk) >> I3CC_DCT_SECTION_OFFSET_TABLE_SIZE_Pos);

    if (DCT_TableOffset == 0U)
    {
        //printf("DCT Table not supported in hardware\r\n");
    }

    PIO_Offset = (${I3CC_INSTANCE_NAME}_REGS->I3CC_PIO_SECTION_OFFSET & I3CC_PIO_SECTION_OFFSET_SECTION_OFFSET_Msk);

    if (PIO_Offset == 0U)
    {
        //printf("PIO not supported\r\n");
    }

    ${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr = (I3CC_DAT_TABLE_ENTRY*)((uint32_t)${I3CC_INSTANCE_NAME}_REGS + DAT_TableOffset);
    ${I3CC_INSTANCE_NAME?lower_case}_host.DCTTablePtr = (I3CC_DCT_TABLE_ENTRY*)((uint32_t)${I3CC_INSTANCE_NAME}_REGS + DCT_TableOffset);

    ${I3CC_INSTANCE_NAME?lower_case}_host.DATTableSize = DAT_TableSize >> 1U; //Each DAT entry is 2 32-bit words. The DAT Table size is specified as number of 32-bit words.
    ${I3CC_INSTANCE_NAME?lower_case}_host.DCTTableSize = DCT_TableSize >> 2U; //Each DCT entry is 4 32-bit words. The DCT Table size is specified as number of 32-bit words.

    ${I3CC_INSTANCE_NAME?lower_case}_host.RXQ_SizeDW = GET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_QUEUE_SIZE, I3CC_QUEUE_SIZE_RX_DATA_BUFFER_SIZE);
    ${I3CC_INSTANCE_NAME?lower_case}_host.RXQ_SizeDW = ((uint32_t)1UL << (${I3CC_INSTANCE_NAME?lower_case}_host.RXQ_SizeDW + 1U));

    ${I3CC_INSTANCE_NAME?lower_case}_host.TXQ_SizeDW = GET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_QUEUE_SIZE, I3CC_QUEUE_SIZE_TX_DATA_BUFFER_SIZE);
    ${I3CC_INSTANCE_NAME?lower_case}_host.TXQ_SizeDW = ((uint32_t)1UL << (${I3CC_INSTANCE_NAME?lower_case}_host.TXQ_SizeDW + 1U));

    ${I3CC_INSTANCE_NAME?lower_case}_host.CRQ_SizeDW = GET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_QUEUE_SIZE, I3CC_QUEUE_SIZE_CR_QUEUE_SIZE);

    ${I3CC_INSTANCE_NAME?lower_case}_host.IBIStatusQ_Size = GET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_QUEUE_SIZE, I3CC_QUEUE_SIZE_IBI_STATUS_SIZE);

    /* Software initialization */
    ${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_pool = xfer_queue;
    ${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_head = NULL;
    ${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_pool_size = I3CC_XFER_QUEUE_SIZE;
    ${I3CC_INSTANCE_NAME?lower_case}_host.xfer_cntr = 0;

    //${I3CC_INSTANCE_NAME}_Host_QueueReset(I3C_QUEUE_RESET_ALL);

    /* Enable all PIO status. There should not be any need to disable it. */
    ${I3CC_INSTANCE_NAME}_Host_StatusEnable(I3CC_PIO_INTR_STATUS_ALL);

    /* Always keep the Response Ready signal enabled. Set threshold to trigger interrupt when response queue contains 1 entry (32-bit word) */
    ${I3CC_INSTANCE_NAME}_Host_QueueThresholdSet(I3CC_QUEUE_THLD_RESPONSE_READY, 0);
    ${I3CC_INSTANCE_NAME}_Host_SignalEnable(I3CC_PIO_INTR_SIGNAL_RESP_THLD | I3CC_PIO_INTR_SIGNAL_TFR_ERR_THLD | I3CC_PIO_INTR_SIGNAL_RX_THLD | I3CC_PIO_INTR_SIGNAL_IBI_THLD);

    /*
    If the number of data DWORDs that have been written into the Tx Data Queue is sufficient to satisfy
    the number of bytes indicated by the next enqueued Command Descriptor, then the Transmit Start
    Threshold is met, so the transfer command shall be allowed to proceed.
    */
    ${I3CC_INSTANCE_NAME}_Host_QueueThresholdSet(I3CC_QUEUE_THLD_TX_START, ${I3CC_INSTANCE_NAME}_Host_GetThreshold_Floor(${I3CC_INSTANCE_NAME?lower_case}_host.TXQ_SizeDW));

    /* Set threshold to 1/2 TX queue size */
    ${I3CC_INSTANCE_NAME}_Host_QueueThresholdSet(I3CC_QUEUE_THLD_TX_BUFFER_FREE, ${I3CC_INSTANCE_NAME}_Host_GetThreshold_Floor(${I3CC_INSTANCE_NAME?lower_case}_host.TXQ_SizeDW >> 1U));

    /*
    I3CC waits for one of the following to be true to initiate the read command:
    1. Entire receive buffer to be empty, if the data length is more than the receive buffer size
    2. The data length number of locations to be empty in the receive buffer, if data length is smaller
    than the receive buffer size
    */
    ${I3CC_INSTANCE_NAME}_Host_QueueThresholdSet(I3CC_QUEUE_THLD_RX_START, ${I3CC_INSTANCE_NAME}_Host_GetThreshold_Floor(${I3CC_INSTANCE_NAME?lower_case}_host.RXQ_SizeDW));

    /* Fix the threshold to 1/2 RX queue size, irrespective of the transfer length. If the transfer length is less than threshold then
       the response event will occur. In the response event read out the available data from the RX buffer.
    */
    ${I3CC_INSTANCE_NAME}_Host_QueueThresholdSet(I3CC_QUEUE_THLD_RX_BUFFER_AVAILABLE, ${I3CC_INSTANCE_NAME}_Host_GetThreshold_Floor(${I3CC_INSTANCE_NAME?lower_case}_host.RXQ_SizeDW >> 1U));

    ${I3CC_INSTANCE_NAME}_Host_QueueThresholdSet(I3CC_QUEUE_THLD_IBI_STATUS, 0);

    ${I3CC_INSTANCE_NAME}_Host_QueueThresholdSet(I3CC_QUEUE_THLD_IBI_DATA_SIZE, (uint8_t)(${I3CC_INSTANCE_NAME?lower_case}_host.IBIStatusQ_Size - 1U));

    ${I3CC_INSTANCE_NAME}_Host_DATTableInitialize(I3CC_DAT_TABLE_ENTRY_TYPE_ALL);

    <#if ibi_ctrl != "">
        ${I3CC_INSTANCE_NAME}_REGS->I3CC_IBI_NOTIFY_CTRL  = ${ibi_ctrl};
    </#if>

    ${I3CC_INSTANCE_NAME}_Host_InitQ();

    ${I3CC_INSTANCE_NAME?lower_case}_host.xferFlagsGlobal.i3cXferMode.mode = I3CC_XFER_MODE_I3C_SDR0;
    ${I3CC_INSTANCE_NAME?lower_case}_host.xferFlagsGlobal.i2cXferMode.mode = I3CC_XFER_MODE_I2C_FM;

    ${I3CC_INSTANCE_NAME?lower_case}_host.xferFlagsGlobal.i3cXferMode.toc = true;
    ${I3CC_INSTANCE_NAME?lower_case}_host.xferFlagsGlobal.i2cXferMode.toc = true;

    ${I3CC_INSTANCE_NAME?lower_case}_host.callback = NULL;
    ${I3CC_INSTANCE_NAME?lower_case}_host.isBusy = false;

    <@compress single_line=true> ${I3CC_INSTANCE_NAME}_REGS->I3CC_HC_CONTROL = (I3CC_HC_CONTROL_BUS_ENABLE_Msk
    <#if I3C_NAK_HOT_JOIN_REQ> | I3CC_HC_CONTROL_HOT_JOIN_CTRL_Msk  </#if>
    <#if IBA_INCLUDE> | I3CC_HC_CONTROL_IBA_INCLUDE_Msk  </#if>
    <#if I2C_DEV_PRESENT> | I3CC_HC_CONTROL_I2C_DEV_PRESENT_Msk  </#if>);</@compress>
}

static uint8_t ${I3CC_INSTANCE_NAME}_Host_AddressWithParity(uint8_t dynamic_addr)
{
    uint8_t addr = dynamic_addr;
    uint8_t parity = 1;

    while (addr != 0U)
    {
        parity ^= 1U;
        addr = addr & (addr-1U);
    }

    return parity;
}

uint8_t ${I3CC_INSTANCE_NAME}_Host_DATTableIndexGet(uint8_t addr)
{
    I3CC_DAT_TABLE_ENTRY datTableEntry;

    for (uint8_t i = 0; i < ${I3CC_INSTANCE_NAME?lower_case}_host.DATTableSize; i++)
    {
        datTableEntry.word0.word = ${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr[i].word0.word;

        if (datTableEntry.word0.bits.dynamic_addr == addr)
        {
            return i;
        }
    }

    /* If dynamic address is not found, look for a static address */
    for (uint8_t i = 0; i < ${I3CC_INSTANCE_NAME?lower_case}_host.DATTableSize; i++)
    {
        datTableEntry.word0.word = ${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr[i].word0.word;

        if ((datTableEntry.word0.bits.dev_type == (uint8_t)I3CC_DAT_TABLE_DEV_TYPE_I2C) && (datTableEntry.word0.bits.static_addr == addr))
        {
            return i;
        }
    }

    return I3CC_DAT_INDEX_INVALID;
}

uint8_t ${I3CC_INSTANCE_NAME}_Host_DATFreeIndexGet(void)
{
    I3CC_DAT_TABLE_ENTRY datTableEntry;

    for (uint8_t i = 0; i < ${I3CC_INSTANCE_NAME?lower_case}_host.DATTableSize; i++)
    {
        datTableEntry.word0.word = ${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr[i].word0.word;

        /* If both dynamic and static address are 0, consider it to be free */
        if ((datTableEntry.word0.bits.dynamic_addr == 0U) && (datTableEntry.word0.bits.static_addr == 0U))
        {
            return i;
        }
    }

    return I3CC_DAT_INDEX_INVALID;
}

/* Application must call this routine to setup the DAT table - basic fields - prior to sending
 * the ENTDAA/SETDASA command */
bool ${I3CC_INSTANCE_NAME}_Host_DATEntrySet(uint8_t datIndex, I3CC_DAT_TABLE_SETUP* datTableSetup)
{
    I3CC_DAT_TABLE_ENTRY datTableEntry = {0};

    if (datIndex >= ${I3CC_INSTANCE_NAME?lower_case}_host.DATTableSize)
    {
        return false;
    }

    datTableEntry.word0.word = ${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr[datIndex].word0.word;

    datTableEntry.word0.bits.static_addr = datTableSetup->static_addr;
    datTableEntry.word0.bits.dynamic_addr = datTableSetup->dynamic_addr;
    datTableEntry.word0.bits.parity = ${I3CC_INSTANCE_NAME}_Host_AddressWithParity(datTableSetup->dynamic_addr);
    datTableEntry.word0.bits.crr_reject = (uint8_t)datTableSetup->crr_reject;
    datTableEntry.word0.bits.dev_type = (uint8_t)datTableSetup->devType;
    datTableEntry.word0.bits.dev_nack_retry_cnt = datTableSetup->nak_retry_count;

    ${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr[datIndex].word0.word = datTableEntry.word0.word;

    return true;
}

bool ${I3CC_INSTANCE_NAME}_Host_DATEntryGet(uint8_t datIndex, I3CC_DAT_TABLE_ENTRY* datTableEntry)
{
    if ((datIndex >= ${I3CC_INSTANCE_NAME?lower_case}_host.DATTableSize) || (datTableEntry == NULL))
    {
        return false;
    }

    datTableEntry->word0.word = ${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr[datIndex].word0.word;
    datTableEntry->word1.word = ${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr[datIndex].word1.word;

    return true;
}

bool ${I3CC_INSTANCE_NAME}_Host_IBIConfigSet(uint8_t dynamic_addr, I3CC_IBI_SETUP* ibiSetup)
{
    if (ibiSetup != NULL)
    {
        uint8_t datIndex = ${I3CC_INSTANCE_NAME}_Host_DATTableIndexGet(dynamic_addr);

        if (datIndex != I3CC_DAT_INDEX_INVALID)
        {
            I3CC_DAT_TABLE_ENTRY datTableEntry = ${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr[datIndex];

            datTableEntry.word0.bits.ibi_reject = (uint8_t)ibiSetup->ibi_reject;
            datTableEntry.word1.bits.autocmd_mask = ibiSetup->autocmd_mask;
            datTableEntry.word1.bits.autocmd_value = ibiSetup->autocmd_value;
            datTableEntry.word1.bits.autocmd_mode = (uint8_t)ibiSetup->autocmd_mode;

            ${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr[datIndex].word0 = datTableEntry.word0;
            ${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr[datIndex].word1 = datTableEntry.word1;

            return true;
        }
    }

    return false;
}

bool ${I3CC_INSTANCE_NAME}_Host_IBIConfigGet(uint8_t dynamic_addr, I3CC_IBI_SETUP* ibiSetup)
{
    if (ibiSetup != NULL)
    {
        uint8_t datIndex = ${I3CC_INSTANCE_NAME}_Host_DATTableIndexGet(dynamic_addr);

        if (datIndex != I3CC_DAT_INDEX_INVALID)
        {
            I3CC_DAT_TABLE_ENTRY datTableEntry = ${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr[datIndex];

            ibiSetup->ibi_reject = (bool)datTableEntry.word0.bits.ibi_reject;
            ibiSetup->autocmd_mask = datTableEntry.word1.bits.autocmd_mask;
            ibiSetup->autocmd_value = datTableEntry.word1.bits.autocmd_value;
            ibiSetup->autocmd_mode = (I3CC_XFER_MODE)datTableEntry.word1.bits.autocmd_mode;
            return true;
        }
    }

    return false;
}

uint8_t ${I3CC_INSTANCE_NAME}_Host_DeviceAddrGet(uint8_t datIndex)
{
    I3CC_DAT_TABLE_ENTRY datTableEntry;

    datTableEntry.word0.word = ${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr[datIndex].word0.word;

    if (datTableEntry.word0.bits.dev_type == (uint8_t)I3CC_DAT_TABLE_DEV_TYPE_I2C)
    {
        return datTableEntry.word0.bits.static_addr;
    }
    else
    {
        return datTableEntry.word0.bits.dynamic_addr;
    }
}

static void ${I3CC_INSTANCE_NAME}_Host_DATTableUpdate(volatile I3CC_DAT_TABLE_ENTRY* pDATEntry, I3CC_DCT_TABLE_ENTRY* pDCTInfo)
{
    I3CC_DAT_TABLE_ENTRY tableEntry = {0};
    uint8_t ibi_request_capable = (pDCTInfo->DCTFields.bcr & I3CC_BCR_IBI_REQUEST_CAPABLE) != 0U? 1U : 0U;
    uint8_t ibi_payload = (pDCTInfo->DCTFields.bcr & I3CC_BCR_IBI_PAYLOAD) != 0U? 1U : 0U;

    tableEntry.word0.word = pDATEntry->word0.word;
    tableEntry.word0.bits.ibi_reject = ibi_request_capable == 1U? 0U : 1U;
    tableEntry.word0.bits.ibi_payload = ibi_payload;

    /* Disable auto-command (i.e. generation of repeated start + read after IBI is read). */
    tableEntry.word1.word = pDATEntry->word1.word;
    tableEntry.word1.bits.autocmd_mask = 0x00U;
    tableEntry.word1.bits.autocmd_value = 0xffU;

    pDATEntry->word0.word = tableEntry.word0.word;
    pDATEntry->word1.word = tableEntry.word1.word;
}

static bool ${I3CC_INSTANCE_NAME}_Host_CMDPortWrite(I3CC_CMD_DESC* cmdDesc)
{
    if (${I3CC_INSTANCE_NAME}_Host_QueueLevelGet(I3CC_QUEUE_LVL_COMMAND_FREE_CNT) < 2U)
    {
        return false;
    }
    else
    {
        ${I3CC_INSTANCE_NAME}_REGS->I3CC_COMMAND_QUEUE_PORT = cmdDesc->cmd_words.cmd_word0;
        ${I3CC_INSTANCE_NAME}_REGS->I3CC_COMMAND_QUEUE_PORT = cmdDesc->cmd_words.cmd_word1;
        return true;
    }
}
/* Routine to fill up the XFER DATA PORT */
static uint32_t ${I3CC_INSTANCE_NAME}_Host_DataPortWrite(void* pTxData, uint32_t data_length)
{
    uint32_t dword = 0;
    uint32_t numBytesQueued = 0;
    uint32_t txQFreeEntries = WORD_TO_BYTE(${I3CC_INSTANCE_NAME}_Host_QueueLevelGet(I3CC_QUEUE_LVL_TX_BUF_FREE_CNT));
    uint32_t nBytesToWrite = (txQFreeEntries < data_length) ? txQFreeEntries : data_length;

    if ((pTxData == NULL) || (data_length == 0U))
    {
        return 0;
    }

    while ((numBytesQueued + 4U) <= nBytesToWrite)
    {
        ${I3CC_INSTANCE_NAME}_REGS->I3CC_XFER_DATA_PORT = ((uint32_t*)pTxData)[numBytesQueued/4U];
        numBytesQueued += 4U;
    }

    if ((nBytesToWrite % 4U) != 0U)
    {
        for (uint32_t j = 0; j < (nBytesToWrite - numBytesQueued); j++)
        {
            ((uint8_t*)&dword)[j] |= (((uint8_t*)pTxData)[numBytesQueued + j]);
        }

        ${I3CC_INSTANCE_NAME}_REGS->I3CC_XFER_DATA_PORT = dword;
        numBytesQueued += (nBytesToWrite - numBytesQueued);
    }

    return numBytesQueued;
}

/* Routine to read from the I3C XFER DATA PORT */
static uint32_t ${I3CC_INSTANCE_NAME}_Host_DataPortRead(void* pRxData, uint32_t data_length, I3CC_QUEUE_TYPE qType)
{
    uint32_t dword;
    uint32_t numBytesRead = 0;
    uint32_t rxQAvailableEntries = 0;

    if ((qType != I3CC_QUEUE_TYPE_DATA) && (qType != I3CC_QUEUE_TYPE_IBI))
    {
        return 0;
    }
    if (pRxData == NULL)
    {
        return 0;
    }

    /* Read-out the received data from the RX Data or IBI Queue */
    if (qType == I3CC_QUEUE_TYPE_DATA)
    {
        rxQAvailableEntries = WORD_TO_BYTE(${I3CC_INSTANCE_NAME}_Host_QueueLevelGet(I3CC_QUEUE_LVL_RX_BUF_CNT));
    }
    else
    {
        rxQAvailableEntries = WORD_TO_BYTE(${I3CC_INSTANCE_NAME}_Host_QueueLevelGet(I3CC_QUEUE_LVL_IBI_BUF_CNT));
    }

    uint32_t nBytesToRead = (rxQAvailableEntries > data_length) ? data_length : rxQAvailableEntries;

    while ((numBytesRead + 4U) <= nBytesToRead)
    {
        uint32_t data = ${I3CC_INSTANCE_NAME}_REGS->I3CC_XFER_DATA_PORT;
        ((uint32_t*)pRxData)[numBytesRead/4U] = data;
        numBytesRead += 4U;
    }

    if ((nBytesToRead % 4U) != 0U)
    {
        dword = ${I3CC_INSTANCE_NAME}_REGS->I3CC_XFER_DATA_PORT;

        for (uint32_t j = 0; j < (nBytesToRead - numBytesRead); j++)
        {
            ((uint8_t*)pRxData)[numBytesRead + j] = ((uint8_t*)&dword)[j];
        }
        numBytesRead += (nBytesToRead - numBytesRead);
    }

    return numBytesRead;
}

static I3CC_RESPONSE_DESC ${I3CC_INSTANCE_NAME}_Host_ResponsePortRead(void)
{
    I3CC_RESPONSE_DESC responseDesc = (I3CC_RESPONSE_DESC)(${I3CC_INSTANCE_NAME}_REGS->I3CC_RESPONSE_QUEUE_PORT);
    return responseDesc;
}

static void ${I3CC_INSTANCE_NAME}_Host_DCT_IndexReset(void)
{
    CLR_BITS( ${I3CC_INSTANCE_NAME}_REGS->I3CC_DCT_SECTION_OFFSET, I3CC_DCT_SECTION_OFFSET_TABLE_INDEX);
}

static uint8_t ${I3CC_INSTANCE_NAME}_Host_DCT_IndexGet(void)
{
    return (uint8_t)GET_BITS( ${I3CC_INSTANCE_NAME}_REGS->I3CC_DCT_SECTION_OFFSET, I3CC_DCT_SECTION_OFFSET_TABLE_INDEX);
}

static uint8_t ${I3CC_INSTANCE_NAME}_Host_DCT_NumEntriesGet(uint8_t initialIndex)
{
    uint8_t currentIndex = ${I3CC_INSTANCE_NAME}_Host_DCT_IndexGet();

    if (currentIndex > initialIndex)
    {
        return (currentIndex - initialIndex);
    }
    else
    {
        return 0;
    }
}

uint8_t ${I3CC_INSTANCE_NAME}_Host_NumTargetsGet(void)
{
    return ${I3CC_INSTANCE_NAME?lower_case}_host.deviceInfo.numValidEntries;
}

static uint8_t ${I3CC_INSTANCE_NAME}_Host_DeviceInfoNumFreeSlotsGet(void)
{
    uint8_t freeSlotsCntr = 0;

    for (uint32_t i = 0; i < I3CC_NUM_TARGET_DEV_SUPPORTED ; i++)
    {
        if (${I3CC_INSTANCE_NAME?lower_case}_host.deviceInfo.devInfo[i].inUse == false)
        {
            freeSlotsCntr += 1U;
        }
    }

    return freeSlotsCntr;
}

static uint8_t ${I3CC_INSTANCE_NAME}_Host_DeviceInfoAcquireSlotAny(void)
{
    for (uint8_t i = 0; i < I3CC_NUM_TARGET_DEV_SUPPORTED; i++)
    {
        if (${I3CC_INSTANCE_NAME?lower_case}_host.deviceInfo.devInfo[i].inUse == false)
        {
            ${I3CC_INSTANCE_NAME?lower_case}_host.deviceInfo.devInfo[i].inUse = true;
            return i;
        }
    }

    return I3CC_DEV_INFO_INDEX_INVALID;
}

static uint8_t ${I3CC_INSTANCE_NAME}_Host_DeviceInfoSlotGet(uint8_t dynamic_addr)
{
    for (uint8_t i = 0; i < I3CC_NUM_TARGET_DEV_SUPPORTED; i++)
    {
        if ((${I3CC_INSTANCE_NAME?lower_case}_host.deviceInfo.devInfo[i].DCTInfo.DCTFields.dynamic_addr == dynamic_addr) && (${I3CC_INSTANCE_NAME?lower_case}_host.deviceInfo.devInfo[i].inUse == true))
        {
            return i;
        }
    }

    return I3CC_DEV_INFO_INDEX_INVALID;
}

static uint8_t ${I3CC_INSTANCE_NAME}_Host_DeviceInfoReleaseSlot(uint8_t dynamic_addr)
{
    for (uint8_t i = 0; i < I3CC_NUM_TARGET_DEV_SUPPORTED; i++)
    {
        if (${I3CC_INSTANCE_NAME?lower_case}_host.deviceInfo.devInfo[i].DCTInfo.DCTFields.dynamic_addr == dynamic_addr)
        {
            ${I3CC_INSTANCE_NAME?lower_case}_host.deviceInfo.devInfo[i].inUse = false;
            ${I3CC_INSTANCE_NAME?lower_case}_host.deviceInfo.numValidEntries -= 1U;

            return i;
        }
    }

    return I3CC_DEV_INFO_INDEX_INVALID;
}

static bool ${I3CC_INSTANCE_NAME}_Host_DeviceInfoFreeSlotsAll(void)
{
    for (uint8_t i = 0; i < I3CC_NUM_TARGET_DEV_SUPPORTED; i++)
    {
        ${I3CC_INSTANCE_NAME?lower_case}_host.deviceInfo.devInfo[i].inUse = false;
    }

    ${I3CC_INSTANCE_NAME?lower_case}_host.deviceInfo.numValidEntries = 0U;

    return true;
}

static bool ${I3CC_INSTANCE_NAME}_Host_DCT_Read(I3CC_DCT_TABLE_ENTRY* pSwDCT, volatile I3CC_DCT_TABLE_ENTRY* pHwDCT)
{
    if (pHwDCT == NULL || pSwDCT == NULL)
    {
        return false;
    }

    /* Copy 128 bits (4, 32-bit words) of DCT information from HW DCT register to SW DCT array */
    for (uint8_t i = 0; i < 4U; i++)
    {
        pSwDCT->words[i] = pHwDCT->words[i];
    }

    return true;
}

bool ${I3CC_INSTANCE_NAME}_Host_IsIBICapable(uint8_t dynamic_addr)
{
    uint8_t devInfoIndex = ${I3CC_INSTANCE_NAME}_Host_DeviceInfoSlotGet(dynamic_addr);

    if (devInfoIndex != I3CC_DEV_INFO_INDEX_INVALID)
    {
        uint8_t bcr = ${I3CC_INSTANCE_NAME?lower_case}_host.deviceInfo.devInfo[devInfoIndex].DCTInfo.DCTFields.bcr;
        return (bcr & I3CC_BCR_IBI_REQUEST_CAPABLE) != 0U ? true : false;
    }

    return false;
}

bool ${I3CC_INSTANCE_NAME}_Host_IBIHasPayload(uint8_t dynamic_addr)
{
    uint8_t devInfoIndex = ${I3CC_INSTANCE_NAME}_Host_DeviceInfoSlotGet(dynamic_addr);

    if (devInfoIndex != I3CC_DEV_INFO_INDEX_INVALID)
    {
        uint8_t bcr = ${I3CC_INSTANCE_NAME?lower_case}_host.deviceInfo.devInfo[devInfoIndex].DCTInfo.DCTFields.bcr;
        return (bcr & I3CC_BCR_IBI_PAYLOAD) != 0U ? true : false;
    }

    return false;
}

bool ${I3CC_INSTANCE_NAME}_Host_TargetHasMaxDataSpeedLimit(uint8_t dynamic_addr)
{
    uint8_t devInfoIndex = ${I3CC_INSTANCE_NAME}_Host_DeviceInfoSlotGet(dynamic_addr);

    if (devInfoIndex != I3CC_DEV_INFO_INDEX_INVALID)
    {
        uint8_t bcr = ${I3CC_INSTANCE_NAME?lower_case}_host.deviceInfo.devInfo[devInfoIndex].DCTInfo.DCTFields.bcr;
        return (bcr & I3CC_BCR_MAX_DATA_SPEED_LIMITATION) != 0U ? true : false;
    }

    return false;
}

/* Application can call this API to readout the DCT information for each device found under the ENTDAA command */
bool ${I3CC_INSTANCE_NAME}_Host_DCTInfoGet(uint8_t dynamic_addr, I3CC_DCT_TABLE_ENTRY* dctInfo)
{
    I3CC_DEVICE_INFO* devInfo = ${I3CC_INSTANCE_NAME?lower_case}_host.deviceInfo.devInfo;
    if (dctInfo == NULL)
    {
        return false;
    }

    for (uint8_t i = 0; i < I3CC_NUM_TARGET_DEV_SUPPORTED; i++)
    {
        if (devInfo[i].inUse == true && devInfo[i].DCTInfo.DCTFields.dynamic_addr == dynamic_addr)
        {
            *dctInfo = devInfo[i].DCTInfo;
            return true;
        }
    }
    return false;
}

uint8_t ${I3CC_INSTANCE_NAME}_Host_DCTInfoGetAll(I3CC_DCT_TABLE_ENTRY* dctInfo, uint8_t maxEntries)
{
    I3CC_DEVICE_INFO* devInfo = ${I3CC_INSTANCE_NAME?lower_case}_host.deviceInfo.devInfo;
    uint8_t j = 0;

    if (dctInfo == NULL)
    {
        return 0;
    }

    for (uint8_t i = 0; i < I3CC_NUM_TARGET_DEV_SUPPORTED; i++)
    {
        if (devInfo[i].inUse == true)
        {
            dctInfo[j++] = devInfo[i].DCTInfo;

            if (j >= maxEntries)
            {
                break;
            }
        }
    }

    return j;
}

static bool ${I3CC_INSTANCE_NAME}_Host_DCTEntriesSave(void)
{
    /* During the device discovery process (ENTDAA command), multiple targets may be found and assigned
     * a dynamic address. Each device will respond with 128 bits of DCT containing (PID (48), DCR(8), BCR(8)).
     * In this routine, read out the received DCT one by one and then update the DAT table with necessary information
     * found in BCR register. Do this for all the DCT entries corresponding to each device found on the bus are
     * read out. */
    I3CC_DEV_INFO* device_info = &${I3CC_INSTANCE_NAME?lower_case}_host.deviceInfo;
    uint32_t devInfoAvailFreeEntries = ${I3CC_INSTANCE_NAME}_Host_DeviceInfoNumFreeSlotsGet();
    uint8_t numDCTEntriesAvailable = ${I3CC_INSTANCE_NAME}_Host_DCT_NumEntriesGet(0);
    uint8_t numDCTEntriesToRead = (uint8_t)((uint32_t)numDCTEntriesAvailable > devInfoAvailFreeEntries ? devInfoAvailFreeEntries : numDCTEntriesAvailable);

    for (uint32_t i = 0; i < numDCTEntriesToRead; i++)
    {
        /* Get a free slot in the device Info array */
        uint8_t devInfoSlot = ${I3CC_INSTANCE_NAME}_Host_DeviceInfoAcquireSlotAny();
        if (devInfoSlot == I3CC_DEV_INFO_INDEX_INVALID)
        {
            break;
        }

        /* Read the next DCT and update the DAT table */
        /* Copy DCT information from HW registers to SW array */

        (void)${I3CC_INSTANCE_NAME}_Host_DCT_Read(&device_info->devInfo[devInfoSlot].DCTInfo, &${I3CC_INSTANCE_NAME?lower_case}_host.DCTTablePtr[i]);

        /* Next pass the DCT information stored in SW array to update the corresponding device's DAT entry in DAT table*/
        /* First get the DAT index corresponding to the dynamic address in the DCT information */

        uint8_t datIndex = ${I3CC_INSTANCE_NAME}_Host_DATTableIndexGet(device_info->devInfo[devInfoSlot].DCTInfo.DCTFields.dynamic_addr);

        if (datIndex == I3CC_DAT_INDEX_INVALID)
        {
            /* DAT table does not have matching device entry. Free the Device Info slot. */
            device_info->devInfo[devInfoSlot].inUse = false;
        }
        else
        {
            ${I3CC_INSTANCE_NAME}_Host_DATTableUpdate(&${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr[datIndex], &device_info->devInfo[devInfoSlot].DCTInfo);
            /* Update the DAT Index corresponding to this device for quick access */
            device_info->devInfo[devInfoSlot].DATIndex = datIndex;
            device_info->numValidEntries += 1U;
        }
    }

    return true;
}

void ${I3CC_INSTANCE_NAME}_Host_GlobalXferFlagsSet(I3CC_XFER_FLAGS* xferFlags)
{
    if (xferFlags == NULL)
    {
        return;
    }

    ${I3CC_INSTANCE_NAME?lower_case}_host.xferFlagsGlobal.i3cXferMode.mode = xferFlags->i3cXferMode.mode;
    ${I3CC_INSTANCE_NAME?lower_case}_host.xferFlagsGlobal.i3cXferMode.toc = xferFlags->i3cXferMode.toc;
    ${I3CC_INSTANCE_NAME?lower_case}_host.xferFlagsGlobal.i2cXferMode.mode = xferFlags->i2cXferMode.mode;
    ${I3CC_INSTANCE_NAME?lower_case}_host.xferFlagsGlobal.i2cXferMode.toc = xferFlags->i2cXferMode.toc;
}

static I3CC_XFER_MODE ${I3CC_INSTANCE_NAME}_Host_GlobalXferFlagsGet(I3CC_DAT_TABLE_DEV_TYPE devType, I3CC_XFER_FLAGS* xferFlags)
{
    if (xferFlags != NULL)
    {
        return (devType == I3CC_DAT_TABLE_DEV_TYPE_I3C)? xferFlags->i3cXferMode.mode : xferFlags->i2cXferMode.mode;
    }
    else
    {
        /* If xferFlags is NULL, use the global transfer configuration */
        return (devType == I3CC_DAT_TABLE_DEV_TYPE_I3C)? ${I3CC_INSTANCE_NAME?lower_case}_host.xferFlagsGlobal.i3cXferMode.mode : ${I3CC_INSTANCE_NAME?lower_case}_host.xferFlagsGlobal.i2cXferMode.mode;
    }
}

/* Set dynamic address */
I3CC_XFER_ID ${I3CC_INSTANCE_NAME}_Host_AddressAssignmentCmd(
    I3CC_CCC  addrAssignCmd,
    uint8_t devIndex,
    uint8_t devCount
)
{
    if (((uint32_t)devIndex + devCount) > ${I3CC_INSTANCE_NAME?lower_case}_host.DATTableSize)
    {
        return I3CC_XFER_ID_INVALID;
    }

    bool i3cInterruptStatus = I3CC_ENTER_CRITICAL(I3CC_IRQn);

    if ((addrAssignCmd != I3CC_CCC_ENTDAA_B) && (addrAssignCmd != I3CC_CCC_SETDASA_D))
    {
        /* Return if there is no space to save the request */
        I3CC_EXIT_CRITICAL(I3CC_IRQn, i3cInterruptStatus);
        return I3CC_XFER_ID_INVALID;
    }

    I3CC_XFER_QUEUE* qElement = ${I3CC_INSTANCE_NAME}_Host_GetFreeQElement(${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_pool, ${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_pool_size);

    if (qElement == NULL)
    {
        /* Return if there is no space to save the request */
        I3CC_EXIT_CRITICAL(I3CC_IRQn, i3cInterruptStatus);
        return I3CC_XFER_ID_INVALID;
    }

    ${I3CC_INSTANCE_NAME}_Host_CmdZeroInit(&qElement->xfer_info.cmd);

    ${I3CC_INSTANCE_NAME?lower_case}_host.isBusy = true;

    /* Always start from 0th index in DCT */
    ${I3CC_INSTANCE_NAME}_Host_DCT_IndexReset();

    I3CC_ADDR_ASSIGN_CMD0_BITS* addr_assign_cmd0_bits = &qElement->xfer_info.cmd.addr_assign_cmd.cmd_word0.bits;

    addr_assign_cmd0_bits->cmd_attr = (uint8_t)I3CC_CMD_DESC_TYPE_ADDR_ASSIGN;
    addr_assign_cmd0_bits->cmd = (uint8_t)addrAssignCmd;

    addr_assign_cmd0_bits->dev_index = devIndex;
    addr_assign_cmd0_bits->dev_count = devCount;
    addr_assign_cmd0_bits->roc = (uint8_t)true;
    addr_assign_cmd0_bits->toc = (uint8_t)true;

    /* Save the command information with the driver */
    I3CC_XFER_INFO* xfer_info = &qElement->xfer_info;

    xfer_info->cmd_desc_type = I3CC_CMD_DESC_TYPE_ADDR_ASSIGN;
    xfer_info->xfer_dir = I3CC_XFER_DIR_WR;
    xfer_info->nBytesRequested = 0;
    xfer_info->nBytesProcessed = 0;    /* Since payload is part of the command itself. Consider all bytes to have been processed */
    xfer_info->pDataBuffer = NULL;
    xfer_info->xfer_id = ${I3CC_INSTANCE_NAME}_Host_XferIdGet();
    addr_assign_cmd0_bits->tid = ${I3CC_INSTANCE_NAME}_Host_XferTIDGet(xfer_info->xfer_id);

    bool isQEmpty = ${I3CC_INSTANCE_NAME}_Host_IsQEmpty(${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_head);

    (void)${I3CC_INSTANCE_NAME}_Host_AddBackQ(&${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_head, qElement);

    if (isQEmpty == true)
    {
        /* This is the first command */
        /* The command must be queued in at the very last, after everything is setup correctly */
        (void)${I3CC_INSTANCE_NAME}_Host_CMDPortWrite(&qElement->xfer_info.cmd);
    }

    I3CC_EXIT_CRITICAL(I3CC_IRQn, i3cInterruptStatus);
    return xfer_info->xfer_id;
}

I3CC_XFER_ID ${I3CC_INSTANCE_NAME}_Host_ImmediateDataXferCmd(
    uint8_t targetAddr,
    bool cp,
    I3CC_CCC cmd,
    void* pDataBuffer,
    uint8_t numTxBytes,
    I3CC_XFER_FLAGS* xferFlags
)
{
    if (numTxBytes > 4U)
    {
        return I3CC_XFER_ID_INVALID;
    }

    bool i3cInterruptStatus = I3CC_ENTER_CRITICAL(I3CC_IRQn);
    uint8_t datIndex = 0;
    I3CC_DAT_TABLE_DEV_TYPE devType = I3CC_DAT_TABLE_DEV_TYPE_I3C;

    bool directed_ccc = (cp == true) && ((uint8_t)cmd > 0x7FU);
    bool private_xfer = (cp == false);

    if (directed_ccc || private_xfer)
    {
        datIndex = ${I3CC_INSTANCE_NAME}_Host_DATTableIndexGet(targetAddr);
        if (datIndex == I3CC_DAT_INDEX_INVALID)
        {
            I3CC_EXIT_CRITICAL(I3CC_IRQn, i3cInterruptStatus);
            return I3CC_XFER_ID_INVALID;
        }
        else
        {
            devType = (I3CC_DAT_TABLE_DEV_TYPE)${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr[datIndex].word0.bits.dev_type;
        }
    }

    I3CC_XFER_QUEUE* qElement = ${I3CC_INSTANCE_NAME}_Host_GetFreeQElement(${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_pool, ${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_pool_size);

    if (qElement == NULL)
    {
        I3CC_EXIT_CRITICAL(I3CC_IRQn, i3cInterruptStatus);
        /* Return if there is no space to save the request */
        return I3CC_XFER_ID_INVALID;
    }

    ${I3CC_INSTANCE_NAME}_Host_CmdZeroInit(&qElement->xfer_info.cmd);

    ${I3CC_INSTANCE_NAME?lower_case}_host.isBusy = true;

    I3CC_IMMD_XFER_CMD0_BITS* immd_xfer_bits = &qElement->xfer_info.cmd.immd_xfer_cmd.cmd_word0.bits;

    immd_xfer_bits->cmd_attr = (uint8_t)I3CC_CMD_DESC_TYPE_IMMEDIATE_XFER;
    immd_xfer_bits->cmd = (uint8_t)cmd;
    immd_xfer_bits->cp = cp ? 1U : 0U;
    immd_xfer_bits->dev_index = datIndex;
    immd_xfer_bits->byte_count = numTxBytes;
    immd_xfer_bits->rnw = (uint8_t)I3CC_XFER_DIR_WR;
    immd_xfer_bits->roc = (uint8_t)true;
    immd_xfer_bits->toc = (uint8_t)true;

    if (cp == true)
    {
        immd_xfer_bits->mode = (uint8_t)I3CC_XFER_MODE_I3C_SDR0;
    }
    else
    {
        immd_xfer_bits->mode = (uint8_t)${I3CC_INSTANCE_NAME}_Host_GlobalXferFlagsGet(devType, xferFlags);
    }

    uint8_t* pDataByte = (uint8_t*)&qElement->xfer_info.cmd.immd_xfer_cmd.cmd_word1.word;

    for (uint8_t i = 0U; i < numTxBytes; i++)
    {
        pDataByte[i] = ((uint8_t*)pDataBuffer)[i];
    }

    /* Save the command information with the driver */
    I3CC_XFER_INFO* xfer_info = &qElement->xfer_info;

    xfer_info->cmd_desc_type = I3CC_CMD_DESC_TYPE_IMMEDIATE_XFER;
    xfer_info->xfer_dir = I3CC_XFER_DIR_WR;
    xfer_info->nBytesRequested = numTxBytes;
    xfer_info->nBytesProcessed = numTxBytes;    /* Since payload is part of the command itself. Consider all bytes to have been processed */
    xfer_info->pDataBuffer = NULL;
    xfer_info->xfer_id = ${I3CC_INSTANCE_NAME}_Host_XferIdGet();
    immd_xfer_bits->tid = ${I3CC_INSTANCE_NAME}_Host_XferTIDGet(xfer_info->xfer_id);

    bool isQEmpty = ${I3CC_INSTANCE_NAME}_Host_IsQEmpty(${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_head);

    (void)${I3CC_INSTANCE_NAME}_Host_AddBackQ(&${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_head, qElement);

    if (isQEmpty == true)
    {
        /* This is the first command */
        /* The command must be queued in at the very last, after everything is setup correctly */
        (void)${I3CC_INSTANCE_NAME}_Host_CMDPortWrite(&qElement->xfer_info.cmd);
    }

    I3CC_EXIT_CRITICAL(I3CC_IRQn, i3cInterruptStatus);

    return xfer_info->xfer_id;
}

I3CC_XFER_ID ${I3CC_INSTANCE_NAME}_Host_RegularDataXferCmd(
    uint8_t targetAddr,
    bool cp,
    I3CC_CCC cmd,
    I3CC_XFER_DIR dir,
    void* pDataBuffer,
    uint16_t numRxTxBytes,
    I3CC_XFER_FLAGS* xferFlags
)
{
    bool i3cInterruptStatus = I3CC_ENTER_CRITICAL(I3CC_IRQn);

    uint8_t datIndex = 0;
    bool directed_ccc = (cp == true) && ((uint8_t)cmd > 0x7FU);
    bool private_xfer = (cp == false);
    I3CC_DAT_TABLE_DEV_TYPE devType = I3CC_DAT_TABLE_DEV_TYPE_I3C;

    if (directed_ccc || private_xfer)
    {
        datIndex = ${I3CC_INSTANCE_NAME}_Host_DATTableIndexGet(targetAddr);
        if (datIndex == I3CC_DAT_INDEX_INVALID)
        {
            I3CC_EXIT_CRITICAL(I3CC_IRQn, i3cInterruptStatus);
            return I3CC_XFER_ID_INVALID;
        }
        else
        {
            devType = (I3CC_DAT_TABLE_DEV_TYPE)${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr[datIndex].word0.bits.dev_type;
        }
    }

    if ((private_xfer == true) && ((pDataBuffer == NULL) || (numRxTxBytes == 0U)))
    {
        I3CC_EXIT_CRITICAL(I3CC_IRQn, i3cInterruptStatus);
        return I3CC_XFER_ID_INVALID;
    }

    I3CC_XFER_QUEUE* qElement = ${I3CC_INSTANCE_NAME}_Host_GetFreeQElement(${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_pool, ${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_pool_size);

    if (qElement == NULL)
    {
        /* Return if there is no space to save the request */
        I3CC_EXIT_CRITICAL(I3CC_IRQn, i3cInterruptStatus);
        return I3CC_XFER_ID_INVALID;
    }

    ${I3CC_INSTANCE_NAME}_Host_CmdZeroInit(&qElement->xfer_info.cmd);

    ${I3CC_INSTANCE_NAME?lower_case}_host.isBusy = true;

    I3CC_RGLR_DATA_XFER_CMD0_BITS* rglr_xfer_word0_bits = &qElement->xfer_info.cmd.rglr_data_xfer_cmd.cmd_word0.bits;
    I3CC_RGLR_DATA_XFER_CMD1_BITS* rglr_xfer_word1_bits = &qElement->xfer_info.cmd.rglr_data_xfer_cmd.cmd_word1.bits;

    rglr_xfer_word0_bits->cmd_attr = (uint8_t)I3CC_CMD_DESC_TYPE_RGLR_DATA_XFER;
    rglr_xfer_word0_bits->cmd = (uint8_t)cmd;
    rglr_xfer_word0_bits->cp = cp ? 1U : 0U;
    rglr_xfer_word0_bits->dev_index = datIndex;
    rglr_xfer_word0_bits->rnw = (uint8_t)dir;
    rglr_xfer_word0_bits->roc = (uint8_t)true;
    rglr_xfer_word0_bits->toc = (uint8_t)true;

    rglr_xfer_word1_bits->data_length = numRxTxBytes;

    if (cp == true)
    {
        rglr_xfer_word0_bits->mode = (uint8_t)I3CC_XFER_MODE_I3C_SDR0;
    }
    else
    {
        rglr_xfer_word0_bits->mode = (uint8_t)${I3CC_INSTANCE_NAME}_Host_GlobalXferFlagsGet(devType, xferFlags);
    }

    I3CC_XFER_INFO* xfer_info = &qElement->xfer_info;

    xfer_info->cmd_desc_type = I3CC_CMD_DESC_TYPE_RGLR_DATA_XFER;
    xfer_info->xfer_dir = dir;
    xfer_info->nBytesRequested = numRxTxBytes;
    xfer_info->nBytesProcessed = 0;
    xfer_info->pDataBuffer = pDataBuffer;
    xfer_info->xfer_id = ${I3CC_INSTANCE_NAME}_Host_XferIdGet();
    rglr_xfer_word0_bits->tid = ${I3CC_INSTANCE_NAME}_Host_XferTIDGet(xfer_info->xfer_id);

    bool isQEmpty = ${I3CC_INSTANCE_NAME}_Host_IsQEmpty(${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_head);

    (void)${I3CC_INSTANCE_NAME}_Host_AddBackQ(&${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_head, qElement);

    if (isQEmpty)
    {
        if (dir == I3CC_XFER_DIR_WR)
        {
            /* Fill the TX buffer as much as we can */
            xfer_info->nBytesProcessed = ${I3CC_INSTANCE_NAME}_Host_DataPortWrite(pDataBuffer, numRxTxBytes);

            ${I3CC_INSTANCE_NAME}_Host_SignalEnable(I3CC_PIO_INTR_SIGNAL_TX_THLD);
        }
        /* Start the transfer by queuing in the command */
        (void)${I3CC_INSTANCE_NAME}_Host_CMDPortWrite(&qElement->xfer_info.cmd);
    }

    I3CC_EXIT_CRITICAL(I3CC_IRQn, i3cInterruptStatus);

    return xfer_info->xfer_id;
}

I3CC_XFER_ID ${I3CC_INSTANCE_NAME}_Host_ComboDataXferCmd(
    uint8_t targetAddr,
    I3CC_XFER_OFFSET_LEN offsetLen,
    uint16_t offsetVal,
    I3CC_XFER_DIR dir,
    void* pDataBuffer,
    uint16_t numRxTxBytes,
    I3CC_XFER_FLAGS* xferFlags
)
{
    bool i3cInterruptStatus = I3CC_ENTER_CRITICAL(I3CC_IRQn);

    uint8_t datIndex = 0;
    I3CC_DAT_TABLE_DEV_TYPE devType = I3CC_DAT_TABLE_DEV_TYPE_I3C;

    datIndex = ${I3CC_INSTANCE_NAME}_Host_DATTableIndexGet(targetAddr);
    if (datIndex == I3CC_DAT_INDEX_INVALID)
    {
        I3CC_EXIT_CRITICAL(I3CC_IRQn, i3cInterruptStatus);
        return I3CC_XFER_ID_INVALID;
    }
    else
    {
        devType = (I3CC_DAT_TABLE_DEV_TYPE)${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr[datIndex].word0.bits.dev_type;
    }

    I3CC_XFER_QUEUE* qElement = ${I3CC_INSTANCE_NAME}_Host_GetFreeQElement(${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_pool, ${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_pool_size);

    if (qElement == NULL)
    {
        /* Return if there is no space to save the request */
        I3CC_EXIT_CRITICAL(I3CC_IRQn, i3cInterruptStatus);
        return I3CC_XFER_ID_INVALID;
    }

    ${I3CC_INSTANCE_NAME}_Host_CmdZeroInit(&qElement->xfer_info.cmd);

    I3CC_COMBO_DATA_XFER_CMD0_BITS* combo_xfer_word0_bits = &qElement->xfer_info.cmd.combo_data_xfer_cmd.cmd_word0.bits;
    I3CC_COMBO_DATA_XFER_CMD1_BITS* combo_xfer_word1_bits = &qElement->xfer_info.cmd.combo_data_xfer_cmd.cmd_word1.bits;

    combo_xfer_word0_bits->cmd_attr = (uint8_t)I3CC_CMD_DESC_TYPE_COMBO_XFER;
    combo_xfer_word0_bits->dev_index = (uint8_t)datIndex;
    combo_xfer_word0_bits->data_length_pos = 0;
    combo_xfer_word0_bits->first_phase_mode = 1;
    combo_xfer_word0_bits->suboffset_8_16_bit = (uint8_t)offsetLen;

    combo_xfer_word0_bits->rnw = (uint8_t)dir;
    combo_xfer_word0_bits->roc = (uint8_t)true;
    combo_xfer_word0_bits->toc = (uint8_t)true;

    combo_xfer_word0_bits->mode = (uint8_t)${I3CC_INSTANCE_NAME}_Host_GlobalXferFlagsGet(devType, xferFlags);

    combo_xfer_word1_bits->offset_suboffset = offsetVal;
    combo_xfer_word1_bits->data_length = numRxTxBytes;

    I3CC_XFER_INFO* xfer_info = &qElement->xfer_info;

    xfer_info->cmd_desc_type = I3CC_CMD_DESC_TYPE_COMBO_XFER;
    xfer_info->xfer_dir = dir;
    xfer_info->nBytesRequested = numRxTxBytes;
    xfer_info->nBytesProcessed = 0;
    xfer_info->pDataBuffer = pDataBuffer;
    xfer_info->xfer_id = ${I3CC_INSTANCE_NAME}_Host_XferIdGet();
    combo_xfer_word0_bits->tid = ${I3CC_INSTANCE_NAME}_Host_XferTIDGet(xfer_info->xfer_id);

    /* Before adding the request to the queue, check if it is empty or not */
    bool isQEmpty = ${I3CC_INSTANCE_NAME}_Host_IsQEmpty(${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_head);

    (void)${I3CC_INSTANCE_NAME}_Host_AddBackQ(&${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_head, qElement);

    if (isQEmpty)
    {
        if (dir == I3CC_XFER_DIR_WR)
        {
            /* Fill the TX buffer as much as we can */
            xfer_info->nBytesProcessed = ${I3CC_INSTANCE_NAME}_Host_DataPortWrite(pDataBuffer, numRxTxBytes);

            ${I3CC_INSTANCE_NAME}_Host_SignalEnable(I3CC_PIO_INTR_SIGNAL_TX_THLD);
        }
        /* Start the transfer by queuing in the command */
        (void)${I3CC_INSTANCE_NAME}_Host_CMDPortWrite(&qElement->xfer_info.cmd);
    }

    I3CC_EXIT_CRITICAL(I3CC_IRQn, i3cInterruptStatus);

    return xfer_info->xfer_id;
}

I3CC_XFER_ID ${I3CC_INSTANCE_NAME}_Host_BroadcastCCCXfer(
    I3CC_CCC cmd,
    I3CC_XFER_DIR dir,
    void* pDataBuffer,
    uint16_t numRxTxBytes,
    I3CC_XFER_FLAGS* xferFlags
)
{
    if (dir == I3CC_XFER_DIR_WR && numRxTxBytes <= 4U)
    {
        return ${I3CC_INSTANCE_NAME}_Host_ImmediateDataXferCmd(0U, true, cmd, pDataBuffer, (uint8_t)numRxTxBytes, xferFlags);
    }
    else
    {
        return ${I3CC_INSTANCE_NAME}_Host_RegularDataXferCmd(0U, true, cmd, dir, pDataBuffer, numRxTxBytes, xferFlags);
    }
}

I3CC_XFER_ID ${I3CC_INSTANCE_NAME}_Host_DirectCCCXfer(
    uint8_t targetAddr,
    I3CC_CCC cmd,
    I3CC_XFER_DIR dir,
    void* pDataBuffer,
    uint16_t numRxTxBytes,
    I3CC_XFER_FLAGS* xferFlags
)
{
    if ((dir == I3CC_XFER_DIR_WR) && (numRxTxBytes <= 4U))
    {
        return ${I3CC_INSTANCE_NAME}_Host_ImmediateDataXferCmd(targetAddr, true, cmd, pDataBuffer, (uint8_t)numRxTxBytes, xferFlags);
    }
    else
    {
        return ${I3CC_INSTANCE_NAME}_Host_RegularDataXferCmd(targetAddr, true, cmd, dir, pDataBuffer, numRxTxBytes, xferFlags);
    }
}

I3CC_XFER_ID ${I3CC_INSTANCE_NAME}_Host_PrivateDataXfer(
    uint8_t targetAddr,
    I3CC_XFER_DIR dir,
    void* pDataBuffer,
    uint16_t numRxTxBytes,
    I3CC_XFER_FLAGS* xferFlags
)
{
    if (dir == I3CC_XFER_DIR_WR && numRxTxBytes <= 4U)
    {
        return ${I3CC_INSTANCE_NAME}_Host_ImmediateDataXferCmd(targetAddr, false, (I3CC_CCC)0U, pDataBuffer, (uint8_t)numRxTxBytes, xferFlags);
    }
    else
    {
        return ${I3CC_INSTANCE_NAME}_Host_RegularDataXferCmd(targetAddr, false, (I3CC_CCC)0U, dir, pDataBuffer, numRxTxBytes, xferFlags);
    }
}

I3CC_XFER_ID ${I3CC_INSTANCE_NAME}_Host_Write(
    uint8_t targetAddr,
    void* pWrDataBuffer,
    uint16_t numTxBytes,
    I3CC_CCC cmd,
    I3CC_XFER_FLAGS* xferFlags
)
{
    if (numTxBytes <= 4U)
    {
        return ${I3CC_INSTANCE_NAME}_Host_ImmediateDataXferCmd(targetAddr, (cmd != I3CC_CCC_NONE)? true : false, cmd, pWrDataBuffer, (uint8_t)numTxBytes, xferFlags);
    }
    else
    {
        return ${I3CC_INSTANCE_NAME}_Host_RegularDataXferCmd(targetAddr, (cmd != I3CC_CCC_NONE)? true : false, cmd, I3CC_XFER_DIR_WR, pWrDataBuffer, numTxBytes, xferFlags);
    }
}

I3CC_XFER_ID ${I3CC_INSTANCE_NAME}_Host_Read(
    uint8_t targetAddr,
    void* pRdDataBuffer,
    uint16_t numRxBytes,
    I3CC_CCC cmd,
    I3CC_XFER_FLAGS* xferFlags
)
{
    return ${I3CC_INSTANCE_NAME}_Host_RegularDataXferCmd(targetAddr, (cmd != I3CC_CCC_NONE), cmd, I3CC_XFER_DIR_RD, pRdDataBuffer, numRxBytes, xferFlags);
}

I3CC_XFER_ID ${I3CC_INSTANCE_NAME}_Host_WriteRead(
    uint8_t targetAddr,
    I3CC_XFER_OFFSET_LEN offsetLen,
    uint16_t offsetVal,
    void* pRdDataBuffer,
    uint16_t numRxBytes,
    I3CC_XFER_FLAGS* xferFlags
)
{
    return ${I3CC_INSTANCE_NAME}_Host_ComboDataXferCmd(targetAddr, offsetLen, offsetVal, I3CC_XFER_DIR_RD, pRdDataBuffer, numRxBytes, xferFlags);
}

I3CC_XFER_ID ${I3CC_INSTANCE_NAME}_Host_DeviceDiscovery(uint8_t nExpectedTargets)
{
    I3CC_DAT_TABLE_SETUP DATSetup;

    uint8_t nDATEntries = nExpectedTargets > ${I3CC_INSTANCE_NAME?lower_case}_host.DATTableSize ? ${I3CC_INSTANCE_NAME?lower_case}_host.DATTableSize : nExpectedTargets;

    if (nDATEntries == 0U)
    {
        return I3CC_XFER_ID_INVALID;
    }

    DATSetup.static_addr = 0;
    DATSetup.dynamic_addr = 0x08;
    DATSetup.devType = I3CC_DAT_TABLE_DEV_TYPE_I3C;
    DATSetup.crr_reject = true;
    DATSetup.nak_retry_count = 0;


    for (uint8_t i = 0; i < nDATEntries; i++)
    {
        (void)${I3CC_INSTANCE_NAME}_Host_DATEntrySet(i, &DATSetup);
        DATSetup.dynamic_addr += 1U;
    }

    I3CC_XFER_ID xferID = ${I3CC_INSTANCE_NAME}_Host_AddressAssignmentCmd(I3CC_CCC_ENTDAA_B, 0U, nDATEntries);

    return xferID;
}

void ${I3CC_INSTANCE_NAME}_Host_CallbackRegister(I3CC_CALLBACK callback_fn)
{
    ${I3CC_INSTANCE_NAME?lower_case}_host.callback = callback_fn;
}

void ${I3CC_INSTANCE_NAME}_Host_PresentStateGet(I3CC_PRESENT_STATE* currState)
{
    uint32_t presentState = ${I3CC_INSTANCE_NAME}_REGS->I3CC_PRESENT_STATE_DEBUG;

    if (currState == NULL)
    {
        return;
    }

    currState->currXferState = (I3CC_CUR_XFER_STATE)((uint32_t)GET_BITS(presentState, I3CC_PRESENT_STATE_DEBUG_CM_TFR_ST_STATUS));
    currState->currXferType = (I3CC_CUR_XFER_TYPE)((uint32_t)GET_BITS(presentState, I3CC_PRESENT_STATE_DEBUG_CM_TFR_STATUS));
    currState->currentTID = (uint8_t)GET_BITS(presentState, I3CC_PRESENT_STATE_DEBUG_CMD_TID);
    currState->SDASignalLevel = (uint8_t)GET_BITS(presentState, I3CC_PRESENT_STATE_DEBUG_SCL_LINE_SIGNAL_LEVEL);
}

static void ${I3CC_INSTANCE_NAME}_Host_WriteHandler(void)
{
    /* Get the command at the top of the queue */
    I3CC_XFER_QUEUE* qTop = ${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_head;

    if ((qTop != NULL) && (qTop->xfer_info.xfer_dir == I3CC_XFER_DIR_WR))
    {
        I3CC_XFER_INFO* xfer_info = &qTop->xfer_info;

        uint32_t nBytesPending = (xfer_info->nBytesRequested - xfer_info->nBytesProcessed);

        /* Fill the TX buffer as much as we can */
        xfer_info->nBytesProcessed += ${I3CC_INSTANCE_NAME}_Host_DataPortWrite(&((uint8_t*)(xfer_info->pDataBuffer))[xfer_info->nBytesProcessed], nBytesPending);

        if (xfer_info->nBytesProcessed == xfer_info->nBytesRequested)
        {
            /* We are done for this command. Stop TX threshold interrupt generation as it is a level-triggered interrupt. */
            ${I3CC_INSTANCE_NAME}_Host_SignalDisable(I3CC_PIO_INTR_SIGNAL_TX_THLD);
        }
    }
    else
    {
        /* No command is queued, nothing to transmit. Disable the interrupt generation as it is a level-triggered interrupt. */
        ${I3CC_INSTANCE_NAME}_Host_SignalDisable(I3CC_PIO_INTR_SIGNAL_TX_THLD);
    }
}

static void ${I3CC_INSTANCE_NAME}_Host_ReadHandler(void)
{
    /* Get the command at the top of the queue */
    I3CC_XFER_QUEUE* qTop = ${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_head;

    if ((qTop != NULL) && (qTop->xfer_info.xfer_dir == I3CC_XFER_DIR_RD))
    {
        I3CC_XFER_INFO* xfer_info = &qTop->xfer_info;

        /* Read-out the received data from the RX Data Queue */
        uint32_t nBytesPending = (xfer_info->nBytesRequested - xfer_info->nBytesProcessed);

        xfer_info->nBytesProcessed += ${I3CC_INSTANCE_NAME}_Host_DataPortRead(&((uint8_t*)xfer_info->pDataBuffer)[xfer_info->nBytesProcessed], nBytesPending, I3CC_QUEUE_TYPE_DATA);
    }
}

static void ${I3CC_INSTANCE_NAME}_Host_IBIHandler(void)
{
    I3CC_IBI_STATUS_DESC* ibiStatus;
    I3CC_EVENT_DATA eventData = {0};
    void* evData;
    I3CC_EVENT event = I3CC_EVENT_NONE;

    uint32_t numIBIStatusEntries = ${I3CC_INSTANCE_NAME}_Host_QueueLevelGet(I3CC_QUEUE_LVL_IBI_STATUS_CNT);
    uint32_t nBytesRead;
    uint32_t ibi_data;
    uint8_t* ibiPayload;

    for (uint32_t i = 0; i < numIBIStatusEntries; i++)
    {
        ${I3CC_INSTANCE_NAME?lower_case}_host.ibiInfo.ibiStatusDescriptor.word = ${I3CC_INSTANCE_NAME}_REGS->I3CC_IBI_PORT;
        ibiStatus = &${I3CC_INSTANCE_NAME?lower_case}_host.ibiInfo.ibiStatusDescriptor;

        nBytesRead = 0;

        while ((nBytesRead + 4U) <= ibiStatus->bits.data_length)
        {
            ibi_data = ${I3CC_INSTANCE_NAME}_REGS->I3CC_IBI_PORT;
            ibiPayload = &${I3CC_INSTANCE_NAME?lower_case}_host.ibiInfo.ibiPayload[nBytesRead];

            ibiPayload[nBytesRead++] = (uint8_t)(ibi_data & 0xFFU);
            ibiPayload[nBytesRead++] = (uint8_t)(ibi_data >> 8U)  & 0xFFU;
            ibiPayload[nBytesRead++] = (uint8_t)(ibi_data >> 16U) & 0xFFU;
            ibiPayload[nBytesRead++] = (uint8_t)(ibi_data >> 24U) & 0xFFU;
        }

        if (nBytesRead < ibiStatus->bits.data_length)
        {
            ibi_data = ${I3CC_INSTANCE_NAME}_REGS->I3CC_IBI_PORT;
            for (uint32_t j = 0; j < ibiStatus->bits.data_length - nBytesRead; j++)
            {
                ${I3CC_INSTANCE_NAME?lower_case}_host.ibiInfo.ibiPayload[nBytesRead + j] = ((uint8_t*)&ibi_data)[j];
            }
        }
    }
    if ((${I3CC_INSTANCE_NAME?lower_case}_host.ibiInfo.ibiStatusDescriptor.bits.ibi_id >> 1U) == 0x02U)
    {
        I3CC_EVENT_DATA_HOTJOIN* hotjoinEvent = &eventData.hotjoinEvent;
        hotjoinEvent->status_desc.word = ${I3CC_INSTANCE_NAME?lower_case}_host.ibiInfo.ibiStatusDescriptor.word;

        event = I3CC_EVENT_HOT_JOIN;
        evData = (void*)hotjoinEvent;
    }
    else
    {
        I3CC_EVENT_DATA_IBI* ibiEventData = &eventData.ibiDataEvent;

        ibiEventData->devId = ${I3CC_INSTANCE_NAME?lower_case}_host.ibiInfo.ibiStatusDescriptor.bits.ibi_id >> 1U;
        ibiEventData->nPayloadBytes = ${I3CC_INSTANCE_NAME?lower_case}_host.ibiInfo.ibiStatusDescriptor.bits.data_length;
        ibiEventData->status_desc.word = ${I3CC_INSTANCE_NAME?lower_case}_host.ibiInfo.ibiStatusDescriptor.word;
        ibiEventData->payloadDataBuffer = ${I3CC_INSTANCE_NAME?lower_case}_host.ibiInfo.ibiPayload;

        event = I3CC_EVENT_IBI;
        evData = (void*)ibiEventData;
    }

    if (${I3CC_INSTANCE_NAME?lower_case}_host.callback != NULL)
    {
        ${I3CC_INSTANCE_NAME?lower_case}_host.callback(event, evData);
    }
}

static void ${I3CC_INSTANCE_NAME}_Host_ResponseHandler(void)
{
    /* Get the command at the top of the queue */
    I3CC_XFER_QUEUE* qTop = ${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_head;

    if (qTop == NULL)
    {
        return;
    }

    I3CC_XFER_INFO* xfer_info = &qTop->xfer_info;
    I3CC_RESPONSE_DESC responseDesc = ${I3CC_INSTANCE_NAME}_Host_ResponsePortRead();
    uint8_t tid = ${I3CC_INSTANCE_NAME}_Host_XferTIDGet(xfer_info->xfer_id);
    I3CC_EVENT event = I3CC_EVENT_NONE;
    I3CC_EVENT_DATA eventData;
    void* evData;

    /* Make sure we are processing the response corresponding to the correct command */
    if (responseDesc.bits.tid == tid)
    {
        xfer_info->responseDesc = responseDesc;
        I3CC_ERR_STATUS errStatus = xfer_info->responseDesc.bits.err_status;

        if (xfer_info->cmd_desc_type == I3CC_CMD_DESC_TYPE_ADDR_ASSIGN)
        {
            I3CC_CCC ccc = xfer_info->cmd.addr_assign_cmd.cmd_word0.bits.cmd;
            I3CC_EVENT_DATA_DEVICE_DISCOVERY* devDiscoveryInfo = &eventData.devDiscoveryInfo;
            devDiscoveryInfo->errStatus = errStatus;
            devDiscoveryInfo->nDevicesCnt = (uint8_t)(xfer_info->cmd.addr_assign_cmd.cmd_word0.bits.dev_count -  xfer_info->responseDesc.bits.data_length);
            devDiscoveryInfo->ccc = ccc;
            devDiscoveryInfo->xferId = xfer_info->xfer_id;

            event = I3CC_EVENT_DEVICE_DISCOVERY;
            evData = (void*)devDiscoveryInfo;

            /* Special case for ENTDAA command. This command can result in err_status set as 0x04 when the number of DAT entries participating in the
             * ENTDAA procedure is more than the number of devices on the bus. Basically, all the devices on the bus have been assigned a dynamic address
             * and now there are no devices available for dynamic address assignment and hence the broadcast address 0x7E is NAK'd which results in address
             * header error (0x04). In this case, the driver still needs to update the DCT entries for the devices that were found on the bus. */
            if (xfer_info->cmd.addr_assign_cmd.cmd_word0.bits.cmd == (uint8_t)I3CC_CCC_ENTDAA_B)
            {
                (void)${I3CC_INSTANCE_NAME}_Host_DCTEntriesSave();
            }

            /* If the transfer is successful, perform additional operations based on the command type */
            if (xfer_info->responseDesc.bits.err_status == 0U)
            {
                if (xfer_info->cmd.addr_assign_cmd.cmd_word0.bits.cmd == (uint8_t)I3CC_CCC_SETDASA_D)
                {
                    /* For SETDASA (assign DA using SA), the PID, BCR and DCR must be read using individual commands.
                     * The driver internally schedules these reads once the SETDASA command completes.
                     */
                    uint8_t datIndex = xfer_info->cmd.addr_assign_cmd.cmd_word0.bits.dev_index;
                    for (uint8_t i = 0; i < devDiscoveryInfo->nDevicesCnt; i++)
                    {
                        (void)${I3CC_INSTANCE_NAME}_Host_Read(${I3CC_INSTANCE_NAME}_Host_DeviceAddrGet(datIndex), (void*)${I3CC_INSTANCE_NAME?lower_case}_host.scratchBuffer, 6, I3CC_CCC_GETPID_D, NULL);
                        (void)${I3CC_INSTANCE_NAME}_Host_Read(${I3CC_INSTANCE_NAME}_Host_DeviceAddrGet(datIndex), (void*)${I3CC_INSTANCE_NAME?lower_case}_host.scratchBuffer, 1, I3CC_CCC_GETBCR_D, NULL);
                        (void)${I3CC_INSTANCE_NAME}_Host_Read(${I3CC_INSTANCE_NAME}_Host_DeviceAddrGet(datIndex), (void*)${I3CC_INSTANCE_NAME?lower_case}_host.scratchBuffer, 1, I3CC_CCC_GETDCR_D, NULL);
                    }
                }
            }
        }
        else
        {
            if (xfer_info->xfer_dir == I3CC_XFER_DIR_RD)
            {
                /* We may have few residual bytes pending to be read. This is the time to read out these bytes from the RX data queue */
                uint32_t nBytesPending = (xfer_info->responseDesc.bits.data_length - xfer_info->nBytesProcessed);
                xfer_info->nBytesProcessed += ${I3CC_INSTANCE_NAME}_Host_DataPortRead(&((uint8_t*)xfer_info->pDataBuffer)[xfer_info->nBytesProcessed], nBytesPending, I3CC_QUEUE_TYPE_DATA);
            }

            /* CP and cmd bitfields are common between Immediate, Regular and Combo transfer descriptors.
             * Hence taking Regular Descriptor to extract cp and cmd values */
            I3CC_RGLR_DATA_XFER_CMD0* cmd_word0 = &xfer_info->cmd.rglr_data_xfer_cmd.cmd_word0;

            bool cp = (bool)cmd_word0->bits.cp;
            uint8_t cmd = cmd_word0->bits.cmd;
            uint8_t devId = ${I3CC_INSTANCE_NAME}_Host_DeviceAddrGet(cmd_word0->bits.dev_index);

            if (cp == false)
            {
                //Private read/write transfer
                if (xfer_info->xfer_dir == I3CC_XFER_DIR_RD)
                {
                    I3CC_EVENT_DATA_PRIVATE_READ* privRdEventData = &eventData.privRdEventData;

                    privRdEventData->errStatus = errStatus;
                    privRdEventData->cmdDescType = xfer_info->cmd_desc_type;
                    privRdEventData->devId = devId;
                    privRdEventData->nBytesRead = xfer_info->responseDesc.bits.data_length;
                    privRdEventData->readBuffer = xfer_info->pDataBuffer;
                    privRdEventData->xferId = xfer_info->xfer_id;

                    event = I3CC_EVENT_XFER_DONE_PRIVATE_READ;
                    evData = (void*)privRdEventData;
                }
                else
                {
                    I3CC_EVENT_DATA_PRIVATE_WRITE* privWrEventData = &eventData.privWrEventData;

                    privWrEventData->errStatus = errStatus;
                    privWrEventData->cmdDescType = xfer_info->cmd_desc_type;
                    privWrEventData->devId = devId;
                    privWrEventData->nBytesWritten = (xfer_info->nBytesRequested - xfer_info->responseDesc.bits.data_length);
                    privWrEventData->nBytesPending = xfer_info->responseDesc.bits.data_length;
                    privWrEventData->writeBuffer = xfer_info->pDataBuffer;
                    privWrEventData->xferId = xfer_info->xfer_id;

                    event = I3CC_EVENT_XFER_DONE_PRIVATE_WRITE;
                    evData = (void*)privWrEventData;
                }
            }
            else
            {
                I3CC_CCC ccc = xfer_info->cmd.rglr_data_xfer_cmd.cmd_word0.bits.cmd;
                // CCC broadcast/directed read/write transfers
                if ((cmd & 0x80U) != 0U)
                {
                    // CCC directed read/write transfers
                    if (xfer_info->xfer_dir == I3CC_XFER_DIR_RD)
                    {
                        /// CCC directed read transfer
                        I3CC_EVENT_DATA_DIRECT_CCC_READ* directCCCRdEventData = &eventData.directCCCRdEventData;

                        directCCCRdEventData->errStatus = errStatus;
                        directCCCRdEventData->cmdDescType = xfer_info->cmd_desc_type;
                        directCCCRdEventData->ccc = ccc;
                        directCCCRdEventData->devId = devId;
                        directCCCRdEventData->nBytesRead = xfer_info->responseDesc.bits.data_length;
                        directCCCRdEventData->readBuffer = xfer_info->pDataBuffer;
                        directCCCRdEventData->xferId = xfer_info->xfer_id;

                        event = I3CC_EVENT_XFER_DONE_DIR_CCC_READ;
                        evData = (void*)directCCCRdEventData;
                    }
                    else
                    {
                        /// CCC directed write transfer
                        I3CC_EVENT_DATA_DIRECT_CCC_WRITE* directCCCWrEventData = &eventData.directCCCWrEventData;

                        directCCCWrEventData->errStatus = errStatus;
                        directCCCWrEventData->cmdDescType = xfer_info->cmd_desc_type;
                        directCCCWrEventData->ccc = ccc;
                        directCCCWrEventData->devId = devId;
                        directCCCWrEventData->nBytesWritten = (xfer_info->nBytesRequested - xfer_info->responseDesc.bits.data_length);
                        directCCCWrEventData->nBytesPending = xfer_info->responseDesc.bits.data_length;
                        directCCCWrEventData->writeBuffer = xfer_info->pDataBuffer;
                        directCCCWrEventData->xferId = xfer_info->xfer_id;

                        event = I3CC_EVENT_XFER_DONE_DIR_CCC_WRITE;
                        evData = (void*)directCCCWrEventData;
                    }
                }
                else
                {
                    // CCC broadcast write transfers
                    I3CC_EVENT_DATA_BROADCAST_CCC_WRITE* broadcastCCCWrEventData = &eventData.broadcastCCCWrEventData;
                    broadcastCCCWrEventData->errStatus = errStatus;
                    broadcastCCCWrEventData->cmdDescType = xfer_info->cmd_desc_type;
                    broadcastCCCWrEventData->ccc = ccc;
                    broadcastCCCWrEventData->nBytesWritten = (xfer_info->nBytesRequested - xfer_info->responseDesc.bits.data_length);
                    broadcastCCCWrEventData->nBytesPending = xfer_info->responseDesc.bits.data_length;
                    broadcastCCCWrEventData->writeBuffer = xfer_info->pDataBuffer;
                    broadcastCCCWrEventData->xferId = xfer_info->xfer_id;

                    event = I3CC_EVENT_XFER_DONE_BROADCAST_CCC;
                    evData = (void*)broadcastCCCWrEventData;
                }

                /* Based on the command and if the response status is success, perform additional operations */
                if (xfer_info->responseDesc.bits.err_status == 0U)
                {
                    /* Special check for the RSTDAA command.
                     * After RSTDAA, free the device info slots as application must perform a fresh device discovery on the bus
                     */
                    if (ccc == I3CC_CCC_RSTDAA_B)
                    {
                        (void) ${I3CC_INSTANCE_NAME}_Host_DeviceInfoFreeSlotsAll();
                        ${I3CC_INSTANCE_NAME}_Host_DATTableInitialize(I3CC_DAT_TABLE_ENTRY_TYPE_I3C);
                    }
                    else if (ccc == I3CC_CCC_RSTDAA_D)
                    {
                        (void) ${I3CC_INSTANCE_NAME}_Host_DeviceInfoReleaseSlot(devId);
                        ${I3CC_INSTANCE_NAME}_Host_DATTableInitialize(I3CC_DAT_TABLE_ENTRY_TYPE_I3C);
                    }
                    else if (ccc == I3CC_CCC_SETNEWDA_D)
                    {
                        /* Update the DAT table to reflect the new Dynamic Address */
                        uint8_t datIndex = xfer_info->cmd.immd_xfer_cmd.cmd_word0.bits.dev_index;
                        if (datIndex < ${I3CC_INSTANCE_NAME?lower_case}_host.DATTableSize)
                        {
                            uint8_t dynamic_addr = (xfer_info->cmd.immd_xfer_cmd.cmd_word1.bits.data_byte1 >> 1);
                            uint8_t devInfoIndex = ${I3CC_INSTANCE_NAME}_Host_DeviceInfoSlotGet(devId);
                            I3CC_DAT_TABLE_ENTRY datTableEntry;
                            datTableEntry.word0.word = ${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr[datIndex].word0.word;

                            if (devInfoIndex != I3CC_DEV_INFO_INDEX_INVALID)
                            {
                                ${I3CC_INSTANCE_NAME?lower_case}_host.deviceInfo.devInfo[devInfoIndex].DCTInfo.DCTFields.dynamic_addr = dynamic_addr;
                            }
                            datTableEntry.word0.bits.dynamic_addr = dynamic_addr;
                            datTableEntry.word0.bits.parity = ${I3CC_INSTANCE_NAME}_Host_AddressWithParity(dynamic_addr);
                            ${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr[datIndex].word0.word = datTableEntry.word0.word;
                        }
                    }
                    else if (ccc == I3CC_CCC_GETPID_D || ccc == I3CC_CCC_GETBCR_D || ccc == I3CC_CCC_GETDCR_D)
                    {
                        if (xfer_info->pDataBuffer != NULL)
                        {
                            uint8_t devInfoIndex = ${I3CC_INSTANCE_NAME}_Host_DeviceInfoSlotGet(devId);
                            if (devInfoIndex == I3CC_DEV_INFO_INDEX_INVALID)
                            {
                                devInfoIndex = ${I3CC_INSTANCE_NAME}_Host_DeviceInfoAcquireSlotAny();
                            }
                            if (devInfoIndex != I3CC_DEV_INFO_INDEX_INVALID)
                            {
                                if (ccc == I3CC_CCC_GETBCR_D)
                                {
                                    ${I3CC_INSTANCE_NAME?lower_case}_host.deviceInfo.devInfo[devInfoIndex].DCTInfo.DCTFields.bcr = ((uint8_t*)xfer_info->pDataBuffer)[0];

                                    uint8_t datIndex = xfer_info->cmd.rglr_data_xfer_cmd.cmd_word0.bits.dev_index;

                                    I3CC_DAT_TABLE_ENTRY DATTableEntry;
                                    uint8_t bcr = ${I3CC_INSTANCE_NAME?lower_case}_host.deviceInfo.devInfo[devInfoIndex].DCTInfo.DCTFields.bcr;

                                    DATTableEntry.word0.word = ${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr[datIndex].word0.word;
                                    DATTableEntry.word1.word = ${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr[datIndex].word1.word;

                                    DATTableEntry.word0.bits.ibi_reject = (bcr & I3CC_BCR_IBI_REQUEST_CAPABLE) != 0U ? 0U: 1U;
                                    DATTableEntry.word0.bits.ibi_payload = (bcr & I3CC_BCR_IBI_PAYLOAD) != 0U ? 1U: 0U;

                                    /* Disable auto-command (i.e. generation of repeated start + read after IBI is read). */
                                    DATTableEntry.word1.bits.autocmd_mask = 0x00;
                                    DATTableEntry.word1.bits.autocmd_value = 0xff;

                                    ${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr[datIndex].word0.word = DATTableEntry.word0.word;
                                    ${I3CC_INSTANCE_NAME?lower_case}_host.DATTablePtr[datIndex].word1.word = DATTableEntry.word1.word;
                                }
                                else if (ccc == I3CC_CCC_GETDCR_D)
                                {
                                    ${I3CC_INSTANCE_NAME?lower_case}_host.deviceInfo.devInfo[devInfoIndex].DCTInfo.DCTFields.dcr = ((uint8_t*)xfer_info->pDataBuffer)[0];
                                }
                                else
                                {
                                    ${I3CC_INSTANCE_NAME?lower_case}_host.deviceInfo.devInfo[devInfoIndex].DCTInfo.DCTFields.pid_low = ((uint16_t*)xfer_info->pDataBuffer)[0];

                                    uint8_t* pid_high  = (uint8_t*)&${I3CC_INSTANCE_NAME?lower_case}_host.deviceInfo.devInfo[devInfoIndex].DCTInfo.DCTFields.pid_high;

                                    uint8_t* pid_val = &((uint8_t*)xfer_info->pDataBuffer)[2];

                                    for (uint8_t i = 0; i < 4U; i++)
                                    {
                                        *pid_high++ = *pid_val++;
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        /* Do nothing */
                    }
                }
            }
        }

        /* Flush the TX queue. This is important in case a write command fails. In such a scenario, the TX queue will contain stale data for the write command that was
         * NAK'd by the slave. The hardware does not automatically flush the TX queue in case a write fails. The end result is that this data ends up getting transmitted
         * for the subsequent write command which is obviously incorrect. Hence, always flush out the TX queue before giving a callback to the application. */

        if ((xfer_info->responseDesc.bits.err_status != 0U) && ((xfer_info->cmd_desc_type == I3CC_CMD_DESC_TYPE_COMBO_XFER) || (xfer_info->xfer_dir == I3CC_XFER_DIR_WR)))
        {
            ${I3CC_INSTANCE_NAME}_Host_QueueReset(I3CC_QUEUE_RESET_TX);
        }

        if (${I3CC_INSTANCE_NAME?lower_case}_host.callback != NULL && event != I3CC_EVENT_NONE)
        {
            ${I3CC_INSTANCE_NAME?lower_case}_host.callback(event, evData);
        }

        /* If abort is requested by the application, reset all the queues */
        if (${I3CC_INSTANCE_NAME?lower_case}_host.abortRequested == true)
        {
            ${I3CC_INSTANCE_NAME}_Host_InitQ();
            ${I3CC_INSTANCE_NAME}_Host_QueueReset(I3CC_QUEUE_RESET_ALL_QUEUES);
            ${I3CC_INSTANCE_NAME?lower_case}_host.abortRequested = false;
            ${I3CC_INSTANCE_NAME?lower_case}_host.isBusy = false;
        }
        else
        {
            /* Done with the current request, remove it from the queue */
            (void) ${I3CC_INSTANCE_NAME}_Host_RemoveFrontQ(&${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_head);

            /* Get the next command at the top of the queue */
            qTop = ${I3CC_INSTANCE_NAME?lower_case}_host.xfer_queue_head;

            if (qTop != NULL)
            {
                xfer_info = &qTop->xfer_info;

                if (xfer_info->xfer_dir == I3CC_XFER_DIR_WR)
                {
                    /* Nothing to do for immediate transfers, as the data payload is part of the command itself. */
                    if (xfer_info->cmd_desc_type != I3CC_CMD_DESC_TYPE_IMMEDIATE_XFER)
                    {
                        uint32_t nBytesPending = (xfer_info->nBytesRequested - xfer_info->nBytesProcessed);

                        /* Fill the TX buffer as much as we can */
                        xfer_info->nBytesProcessed += ${I3CC_INSTANCE_NAME}_Host_DataPortWrite(&((uint8_t*)xfer_info->pDataBuffer)[xfer_info->nBytesProcessed], nBytesPending);
                    }
                    ${I3CC_INSTANCE_NAME}_Host_SignalEnable(I3CC_PIO_INTR_SIGNAL_TX_THLD);
                }
                /* Start the transfer by queuing in the command */
                (void)${I3CC_INSTANCE_NAME}_Host_CMDPortWrite(&xfer_info->cmd);
            }
            else
            {
                ${I3CC_INSTANCE_NAME?lower_case}_host.isBusy = false;
            }
        }
    }
}

void ${I3CC_INSTANCE_NAME}_InterruptHandler(void)
{
    uint32_t intr_status = ${I3CC_INSTANCE_NAME}_REGS->I3CC_PIO_INTR_STATUS;

    if ((intr_status & I3CC_PIO_INTR_STATUS_IBI_STATUS_THLD_STAT_Msk) != 0U)
    {
        ${I3CC_INSTANCE_NAME}_Host_IBIHandler();
    }
    if ((intr_status & I3CC_PIO_INTR_STATUS_RX_THLD_STAT_Msk) != 0U)
    {
        /* Handle Read */
        ${I3CC_INSTANCE_NAME}_Host_ReadHandler();
    }
    if ((intr_status & I3CC_PIO_INTR_STATUS_TX_THLD_STAT_Msk) != 0U)
    {
        /* Handle Write */
        ${I3CC_INSTANCE_NAME}_Host_WriteHandler();
    }
    if ((intr_status & I3CC_PIO_INTR_STATUS_RESP_READY_STAT_Msk) != 0U)
    {
        ${I3CC_INSTANCE_NAME}_Host_ResponseHandler();
    }
    if ((intr_status & I3CC_PIO_INTR_STATUS_TRANSFER_ERR_STAT_Msk) != 0U)
    {
        /* Clear the Error bit (W1C) to allow for normal operation on the I3C bus */
        ${I3CC_INSTANCE_NAME}_REGS->I3CC_PIO_INTR_STATUS |= I3CC_PIO_INTR_STATUS_TRANSFER_ERR_STAT_Msk;

        /* Depending on the error, the host controller may enter a halted state. Check for the present state and resume it if it is in halted state. */
        if (GET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_PRESENT_STATE_DEBUG, I3CC_PRESENT_STATE_DEBUG_CM_TFR_ST_STATUS) == I3CC_PRESENT_STATE_DEBUG_CM_TFR_ST_STATUS_HALT_Val)
        {
            ${I3CC_INSTANCE_NAME}_REGS->I3CC_HC_CONTROL |= I3CC_HC_CONTROL_RESUME_Msk;
        }
    }

    if ((intr_status & I3CC_PIO_INTR_STATUS_TRANSFER_ABORT_STAT_Msk) != 0U)
    {
        ${I3CC_INSTANCE_NAME}_REGS->I3CC_PIO_INTR_STATUS |= I3CC_PIO_INTR_STATUS_TRANSFER_ABORT_STAT_Msk;

        if (GET_BITS(${I3CC_INSTANCE_NAME}_REGS->I3CC_PRESENT_STATE_DEBUG, I3CC_PRESENT_STATE_DEBUG_CM_TFR_ST_STATUS) == I3CC_PRESENT_STATE_DEBUG_CM_TFR_ST_STATUS_HALT_Val)
        {
            ${I3CC_INSTANCE_NAME}_REGS->I3CC_HC_CONTROL |= I3CC_HC_CONTROL_RESUME_Msk;
        }
    }
}