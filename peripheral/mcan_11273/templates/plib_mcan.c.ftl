/*******************************************************************************
  Controller Area Network (MCAN) Peripheral Library Source File

  Company:
    Microchip Technology Inc.

  File Name:
    plib_${MCAN_INSTANCE_NAME?lower_case}.c

  Summary:
    MCAN peripheral library interface.

  Description:
    This file defines the interface to the MCAN peripheral library. This
    library provides access to and control of the associated peripheral
    instance.

  Remarks:
    None.
*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2018 Microchip Technology Inc. and its subsidiaries.
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
//DOM-IGNORE-END
// *****************************************************************************
// *****************************************************************************
// Header Includes
// *****************************************************************************
// *****************************************************************************

#include "device.h"
<#if core.CoreSysIntFile == true>
#include "interrupts.h"
</#if>
#include "plib_${MCAN_INSTANCE_NAME?lower_case}.h"

// *****************************************************************************
// *****************************************************************************
// Global Data
// *****************************************************************************
// *****************************************************************************
<#assign MCAN_NBTP_NTSEG1  = NBTP_NTSEG1 - 1>
<#assign MCAN_NBTP_NTSEG2  = NBTP_NTSEG2 - 1>
<#assign MCAN_NBTP_NSJW    = NBTP_NSJW - 1>
<#assign MCAN_DBTP_DTSEG1  = DBTP_DTSEG1 - 1>
<#assign MCAN_DBTP_DTSEG2  = DBTP_DTSEG2 - 1>
<#assign MCAN_DBTP_DSJW    = DBTP_DSJW - 1>
<#assign TX_EVENT_FIFO_ELEMENTS = TX_FIFO_ELEMENTS>
<#if TXBUF_USE>
<#assign TX_EVENT_FIFO_ELEMENTS = TX_BUFFER_ELEMENTS + TX_FIFO_ELEMENTS>
</#if>
#define MCAN_STD_ID_Msk        0x7FFU

static MCAN_OBJ ${MCAN_INSTANCE_NAME?lower_case}Obj;
<#if FILTERS_STD?number gt 0>
<#assign numInstance=FILTERS_STD?number>

static const mcan_sidfe_registers_t ${MCAN_INSTANCE_NAME?lower_case}StdFilter[] =
{
    <#list 1..(numInstance) as idx>
    {
        .MCAN_SIDFE_0 = MCAN_SIDFE_0_SFT(${.vars["${MCAN_INSTANCE_NAME}_STD_FILTER${idx}_TYPE"]}UL) |
                  MCAN_SIDFE_0_SFID1(0x${.vars["${MCAN_INSTANCE_NAME}_STD_FILTER${idx}_SFID1"]}UL) |
                  MCAN_SIDFE_0_SFID2(0x${.vars["${MCAN_INSTANCE_NAME}_STD_FILTER${idx}_SFID2"]}UL) |
                  MCAN_SIDFE_0_SFEC(${.vars["${MCAN_INSTANCE_NAME}_STD_FILTER${idx}_CONFIG"]}UL)
    },
     </#list>
};
</#if>
<#if FILTERS_EXT?number gt 0>
<#assign numInstance=FILTERS_EXT?number>

static const mcan_xidfe_registers_t ${MCAN_INSTANCE_NAME?lower_case}ExtFilter[] =
{
    <#list 1..(numInstance) as idx>
    {
        .MCAN_XIDFE_0 = MCAN_XIDFE_0_EFID1(0x${.vars["${MCAN_INSTANCE_NAME}_EXT_FILTER${idx}_EFID1"]}UL) | MCAN_XIDFE_0_EFEC(${.vars["${MCAN_INSTANCE_NAME}_EXT_FILTER${idx}_CONFIG"]}UL),
        .MCAN_XIDFE_1 = MCAN_XIDFE_1_EFID2(0x${.vars["${MCAN_INSTANCE_NAME}_EXT_FILTER${idx}_EFID2"]}UL) | MCAN_XIDFE_1_EFT(${.vars["${MCAN_INSTANCE_NAME}_EXT_FILTER${idx}_TYPE"]}UL),
    },
     </#list>
};
</#if>

// *****************************************************************************
// *****************************************************************************
// ${MCAN_INSTANCE_NAME} PLib Interface Routines
// *****************************************************************************
// *****************************************************************************
// *****************************************************************************
/* Function:
    void ${MCAN_INSTANCE_NAME}_Initialize(void)

   Summary:
    Initializes given instance of the MCAN peripheral.

   Precondition:
    None.

   Parameters:
    None.

   Returns:
    None
*/
void ${MCAN_INSTANCE_NAME}_Initialize(void)
{
    /* Start MCAN initialization */
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_CCCR = MCAN_CCCR_INIT_Msk;
    while ((${MCAN_INSTANCE_NAME}_REGS->MCAN_CCCR & MCAN_CCCR_INIT_Msk) != MCAN_CCCR_INIT_Msk)
    {
        /* Wait for initialization complete */
    }

    /* Set CCE to unlock the configuration registers */
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_CCCR |= MCAN_CCCR_CCE_Msk;

<#if MCAN_OPMODE != "NORMAL">
<#if MCAN_REVISION_A_ENABLE == true>
    /* Set Fast Bit Timing and Prescaler Register */
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_FBTP = MCAN_FBTP_FTSEG2(${MCAN_DBTP_DTSEG2}) | MCAN_FBTP_FTSEG1(${MCAN_DBTP_DTSEG1}) | MCAN_FBTP_FBRP(${DBTP_DBRP}) | MCAN_FBTP_FSJW(${MCAN_DBTP_DSJW});

<#else>
    /* Set Data Bit Timing and Prescaler Register */
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_DBTP = MCAN_DBTP_DTSEG2(${MCAN_DBTP_DTSEG2}) | MCAN_DBTP_DTSEG1(${MCAN_DBTP_DTSEG1}) | MCAN_DBTP_DBRP(${DBTP_DBRP}) | MCAN_DBTP_DSJW(${MCAN_DBTP_DSJW});

</#if>
</#if>
<#if MCAN_REVISION_A_ENABLE == true>
    /* Set Bit timing and Prescaler Register */
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_BTP  = MCAN_BTP_TSEG2(${MCAN_NBTP_NTSEG2}) | MCAN_BTP_TSEG1(${MCAN_NBTP_NTSEG1}) | MCAN_BTP_BRP(${NBTP_NBRP}) | MCAN_BTP_SJW(${MCAN_NBTP_NSJW});
<#else>
    /* Set Nominal Bit timing and Prescaler Register */
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_NBTP  = MCAN_NBTP_NTSEG2(${MCAN_NBTP_NTSEG2}) | MCAN_NBTP_NTSEG1(${MCAN_NBTP_NTSEG1}) | MCAN_NBTP_NBRP(${NBTP_NBRP}) | MCAN_NBTP_NSJW(${MCAN_NBTP_NSJW});
</#if>

<#if RXF0_USE || RXF1_USE || RXBUF_USE>
  <#if MCAN_OPMODE != "NORMAL">
    /* Receive Buffer / FIFO Element Size Configuration Register */
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_RXESC = 0UL <#if RXF0_USE> | MCAN_RXESC_F0DS(${RXF0_BYTES_CFG!0}UL)</#if><#if RXF1_USE> | MCAN_RXESC_F1DS(${RXF1_BYTES_CFG!0}UL)</#if><#if RXBUF_USE> | MCAN_RXESC_RBDS(${RX_BUFFER_BYTES_CFG!0}UL)</#if>;
  </#if>
</#if>
<#if RXBUF_USE>
    /*lint -e{9048} PC lint incorrectly reports a missing 'U' Suffix */
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_NDAT1 = MCAN_NDAT1_Msk;
    /*lint -e{9048} PC lint incorrectly reports a missing 'U' Suffix */
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_NDAT2 = MCAN_NDAT2_Msk;

</#if>
<#if TX_USE || TXBUF_USE>
  <#if MCAN_OPMODE != "NORMAL">
    /* Transmit Buffer/FIFO Element Size Configuration Register */
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_TXESC = MCAN_TXESC_TBDS(${TX_FIFO_BYTES_CFG}UL);
  </#if>
</#if>

    /* Global Filter Configuration Register */
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_GFC = ${FILTERS_STD_NOMATCH} | ${FILTERS_EXT_NOMATCH}<#if FILTERS_STD_REJECT> | MCAN_GFC_RRFS_Msk</#if><#if FILTERS_EXT_REJECT> | MCAN_GFC_RRFE_Msk</#if>;
<#if FILTERS_EXT?number gt 0>

    /* Extended ID AND Mask Register */
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_XIDAM = MCAN_XIDAM_Msk;
</#if>
<#if TIMESTAMP_ENABLE || MCAN_TIMEOUT>

    /* Timestamp Counter Configuration Register */
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_TSCC = MCAN_TSCC_TCP(${TIMESTAMP_PRESCALER})<#if TIMESTAMP_ENABLE == true> | ${TIMESTAMP_MODE}</#if>;
</#if>
<#if MCAN_TIMEOUT>

    /* Timeout Counter Configuration Register */
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_TOCC = ${TIMEOUT_SELECT} | MCAN_TOCC_ETOC_TOS_CONTROLLED | MCAN_TOCC_TOP(${TIMEOUT_COUNT});
</#if>

    /* Set the operation mode */
<#if MCAN_REVISION_A_ENABLE == true>
    <#if MCAN_OPMODE != "NORMAL">
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_CCCR |= MCAN_CCCR_CME_FD | MCAN_CCCR_CMR_FD_BITRATE_SWITCH<#rt>
                                           <#lt><#if MCAN_OPMODE == "Restricted Operation Mode"> | MCAN_CCCR_ASM_Msk</#if><#rt>
                                           <#lt><#if MCAN_OPMODE == "Bus Monitoring Mode"> | MCAN_CCCR_MON_Msk</#if><#rt>
                                           <#lt><#if MCAN_OPMODE == "External Loop Back Mode"> | MCAN_CCCR_TEST_Msk</#if><#rt>
                                           <#lt><#if MCAN_OPMODE == "Internal Loop Back Mode"> | MCAN_CCCR_TEST_Msk | MCAN_CCCR_MON_Msk</#if>;
    </#if>
<#else>
    <#if MCAN_OPMODE != "NORMAL">
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_CCCR |= MCAN_CCCR_FDOE_ENABLED | MCAN_CCCR_BRSE_ENABLED<#rt>
                                           <#lt><#if MCAN_OPMODE == "Restricted Operation Mode"> | MCAN_CCCR_ASM_Msk</#if><#rt>
                                           <#lt><#if MCAN_OPMODE == "Bus Monitoring Mode"> | MCAN_CCCR_MON_Msk</#if><#rt>
                                           <#lt><#if MCAN_OPMODE == "External Loop Back Mode"> | MCAN_CCCR_TEST_Msk</#if><#rt>
                                           <#lt><#if MCAN_OPMODE == "Internal Loop Back Mode"> | MCAN_CCCR_TEST_Msk | MCAN_CCCR_MON_Msk</#if>;
    </#if>
</#if>
    <#if TX_PAUSE == true>
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_CCCR |= MCAN_CCCR_TXP_Msk;
    </#if>

    <#if MCAN_OPMODE == "External Loop Back Mode" || MCAN_OPMODE == "Internal Loop Back Mode">
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_TEST |= MCAN_TEST_LBCK_Msk;
    </#if>

    ${MCAN_INSTANCE_NAME}_REGS->MCAN_CCCR &= ~MCAN_CCCR_INIT_Msk;
    while ((${MCAN_INSTANCE_NAME}_REGS->MCAN_CCCR & MCAN_CCCR_INIT_Msk) == MCAN_CCCR_INIT_Msk)
    {
        /* Wait for initialization complete */
    }

    memset(&${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig, 0x00, sizeof(MCAN_MSG_RAM_CONFIG));
}

<#if TXBUF_USE>
// *****************************************************************************
/* Function:
    bool ${MCAN_INSTANCE_NAME}_MessageTransmit(uint8_t bufferNumber, MCAN_TX_BUFFER *txBuffer)

   Summary:
    Transmits a message into MCAN bus from the specific Tx buffer.

   Precondition:
    ${MCAN_INSTANCE_NAME}_Initialize must have been called for the associated MCAN instance.

   Parameters:
    bufferNumber - Tx buffer number.
    txBuffer     - Pointer to Tx buffer

   Returns:
    Request status.
    true  - Request was successful.
    false - Request has failed.
*/
bool ${MCAN_INSTANCE_NAME}_MessageTransmit(uint8_t bufferNumber, MCAN_TX_BUFFER *txBuffer)
{
    uint8_t *txBuf = NULL;

    if ((bufferNumber >= ${TX_BUFFER_ELEMENTS}U) || (txBuffer == NULL))
    {
        return false;
    }

    txBuf = (uint8_t *)((uint8_t*)${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.txBuffersAddress + ((uint32_t)bufferNumber * ${MCAN_INSTANCE_NAME}_TX_FIFO_BUFFER_ELEMENT_SIZE));

    memcpy(txBuf, (uint8_t *)txBuffer, ${MCAN_INSTANCE_NAME}_TX_FIFO_BUFFER_ELEMENT_SIZE);
	
	SCB_CleanDCache_by_Addr((uint32_t *) txFifo, ${MCAN_INSTANCE_NAME}_TX_FIFO_BUFFER_ELEMENT_SIZE);

	/* memory barrier to make sure processor updates values*/
	__DMB();

    /* Set Transmission request */
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_TXBAR = 1UL << bufferNumber;

    return true;
}
</#if>

<#if TX_USE>
// *****************************************************************************
/* Function:
    bool ${MCAN_INSTANCE_NAME}_MessageTransmitFifo(uint8_t numberOfMessage, MCAN_TX_BUFFER *txBuffer)

   Summary:
    Transmit multiple messages into MCAN bus from Tx FIFO.

   Precondition:
    ${MCAN_INSTANCE_NAME}_Initialize must have been called for the associated MCAN instance.

   Parameters:
    numberOfMessage - Total number of message.
    txBuffer        - Pointer to Tx buffer

   Returns:
    Request status.
    true  - Request was successful.
    false - Request has failed.
*/
bool ${MCAN_INSTANCE_NAME}_MessageTransmitFifo(uint8_t numberOfMessage, MCAN_TX_BUFFER *txBuffer)
{
    uint8_t  *txFifo = NULL;
    uint8_t  *txBuf = (uint8_t *)txBuffer;
    uint32_t bufferNumber = 0U;
    uint8_t  tfqpi = 0U;
    uint8_t  count = 0U;

    if (((numberOfMessage < 1U) || (numberOfMessage > ${TX_FIFO_ELEMENTS}U)) || (txBuffer == NULL))
    {
        return false;
    }

    tfqpi = (uint8_t)((${MCAN_INSTANCE_NAME}_REGS->MCAN_TXFQS & MCAN_TXFQS_TFQPI_Msk) >> MCAN_TXFQS_TFQPI_Pos);

    for (count = 0; count < numberOfMessage; count++)
    {
        txFifo = (uint8_t *)((uint8_t*)${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.txBuffersAddress + ((uint32_t)tfqpi * ${MCAN_INSTANCE_NAME}_TX_FIFO_BUFFER_ELEMENT_SIZE));

        memcpy(txFifo, txBuf, ${MCAN_INSTANCE_NAME}_TX_FIFO_BUFFER_ELEMENT_SIZE);
		
		SCB_CleanDCache_by_Addr((uint32_t *) txFifo, ${MCAN_INSTANCE_NAME}_TX_FIFO_BUFFER_ELEMENT_SIZE);

        /* memory barrier to make sure processor updates values*/
        __DMB();

        txBuf += ${MCAN_INSTANCE_NAME}_TX_FIFO_BUFFER_ELEMENT_SIZE;
        bufferNumber |= (1UL << tfqpi);
        tfqpi++;
        <#if TXBUF_USE>
        if (tfqpi == (${TX_BUFFER_ELEMENTS}U + ${TX_FIFO_ELEMENTS}U))
        {
            tfqpi = ${TX_BUFFER_ELEMENTS}U;
        }
        <#else>
        if (tfqpi == ${TX_FIFO_ELEMENTS}U)
        {
            tfqpi = 0U;
        }
        </#if>
    }

    /* Set Transmission request */
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_TXBAR = bufferNumber;

    return true;
}

// *****************************************************************************
/* Function:
    uint8_t ${MCAN_INSTANCE_NAME}_TxFifoFreeLevelGet(void)

   Summary:
    Returns Tx FIFO Free Level.

   Precondition:
    ${MCAN_INSTANCE_NAME}_Initialize must have been called for the associated MCAN instance.

   Parameters:
    None.

   Returns:
    Tx FIFO Free Level.
*/
uint8_t ${MCAN_INSTANCE_NAME}_TxFifoFreeLevelGet(void)
{
    return (uint8_t)(${MCAN_INSTANCE_NAME}_REGS->MCAN_TXFQS & MCAN_TXFQS_TFFL_Msk);
}
</#if>

<#if TX_USE || TXBUF_USE>
// *****************************************************************************
/* Function:
    bool ${MCAN_INSTANCE_NAME}_TxBufferIsBusy(uint8_t bufferNumber)

   Summary:
    Check if Transmission request is pending for the specific Tx buffer.

   Precondition:
    ${MCAN_INSTANCE_NAME}_Initialize must have been called for the associated MCAN instance.

   Parameters:
    None.

   Returns:
    true  - Transmission request is pending.
    false - Transmission request is not pending.
*/
bool ${MCAN_INSTANCE_NAME}_TxBufferIsBusy(uint8_t bufferNumber)
{
    return ((${MCAN_INSTANCE_NAME}_REGS->MCAN_TXBRP & (1UL << bufferNumber)) != 0U);
}

// *****************************************************************************
/* Function:
    bool ${MCAN_INSTANCE_NAME}_TxEventFifoRead(uint8_t numberOfTxEvent, MCAN_TX_EVENT_FIFO *txEventFifo)

   Summary:
    Read Tx Event FIFO for the transmitted messages.

   Precondition:
    ${MCAN_INSTANCE_NAME}_Initialize must have been called for the associated MCAN instance.

   Parameters:
    numberOfTxEvent - Total number of Tx Event
    txEventFifo     - Pointer to Tx Event FIFO

   Returns:
    Request status.
    true  - Request was successful.
    false - Request has failed.
*/
bool ${MCAN_INSTANCE_NAME}_TxEventFifoRead(uint8_t numberOfTxEvent, MCAN_TX_EVENT_FIFO *txEventFifo)
{
    uint8_t txefgi     = 0U;
    uint8_t count      = 0U;
    uint8_t *txEvent   = NULL;
    uint8_t *txEvtFifo = (uint8_t *)txEventFifo;

    if (txEventFifo == NULL)
    {
        return false;
    }

    /* Read data from the Rx FIFO0 */
    txefgi = (uint8_t)((${MCAN_INSTANCE_NAME}_REGS->MCAN_TXEFS & MCAN_TXEFS_EFGI_Msk) >> MCAN_TXEFS_EFGI_Pos);
    for (count = 0; count < numberOfTxEvent; count++)
    {
        txEvent = (uint8_t *) ((uint8_t *)${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.txEventFIFOAddress + ((uint32_t)txefgi * sizeof(MCAN_TX_EVENT_FIFO)));

        /* make sure CPU reads new values from memory by invalidating data cache */
        SCB_InvalidateDCache_by_Addr((uint32_t *) txEvent, sizeof(MCAN_TX_EVENT_FIFO));
		
		memcpy(txEvtFifo, txEvent, sizeof(MCAN_TX_EVENT_FIFO));
		
		/* memory barrier to make sure processor updates values*/
        __DMB();

        if ((count + 1) == numberOfTxEvent)
        {
            break;
        }
        txEvtFifo += sizeof(MCAN_TX_EVENT_FIFO);
        txefgi++;
        if (txefgi == ${TX_EVENT_FIFO_ELEMENTS}U)
        {
            txefgi = 0U;
        }
    }

    /* Ack the Tx Event FIFO position */
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_TXEFA = MCAN_TXEFA_EFAI((uint32_t)txefgi);

    return true;
}

// *****************************************************************************
/* Function:
    uint8_t ${MCAN_INSTANCE_NAME}_TxEventFifoFillLevelGet(void)

   Summary:
    Returns Tx Event FIFO Fill Level.

   Precondition:
    ${MCAN_INSTANCE_NAME}_Initialize must have been called for the associated MCAN instance.

   Parameters:
    None.

   Returns:
    Tx Event FIFO Fill Level.
*/
uint8_t ${MCAN_INSTANCE_NAME}_TxEventFifoFillLevelGet(void)
{
    return (uint8_t)(${MCAN_INSTANCE_NAME}_REGS->MCAN_TXEFS & MCAN_TXEFS_EFFL_Msk);
}
</#if>

<#if RXBUF_USE>
// *****************************************************************************
/* Function:
    bool ${MCAN_INSTANCE_NAME}_MessageReceive(uint8_t bufferNumber, MCAN_RX_BUFFER *rxBuffer)

   Summary:
    Read a message from the specific Rx Buffer.

   Precondition:
    ${MCAN_INSTANCE_NAME}_Initialize must have been called for the associated MCAN instance.

   Parameters:
    bufferNumber - Rx buffer number
    rxBuffer     - Pointer to Rx buffer

   Returns:
    Request status.
    true  - Request was successful.
    false - Request has failed.
*/
bool ${MCAN_INSTANCE_NAME}_MessageReceive(uint8_t bufferNumber, MCAN_RX_BUFFER *rxBuffer)
{
    uint8_t *rxBuf = NULL;

    if ((bufferNumber >= ${RX_BUFFER_ELEMENTS}U) || (rxBuffer == NULL))
    {
        return false;
    }

    rxBuf = (uint8_t *) ((uint8_t *)${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.rxBuffersAddress + ((uint32_t)bufferNumber * ${MCAN_INSTANCE_NAME}_RX_BUFFER_ELEMENT_SIZE));
	
	/* make sure CPU reads new values from memory by invalidating data cache */
    SCB_InvalidateDCache_by_Addr((uint32_t *) rxBuf, ${MCAN_INSTANCE_NAME}_RX_BUFFER_ELEMENT_SIZE);

    memcpy((uint8_t *)rxBuffer, rxBuf, ${MCAN_INSTANCE_NAME}_RX_BUFFER_ELEMENT_SIZE);
	
	/* memory barrier to make sure processor updates values*/
    __DMB();

    /* Clear new data flag */
    if (bufferNumber < 32U)
    {
        ${MCAN_INSTANCE_NAME}_REGS->MCAN_NDAT1 = (1UL << bufferNumber);
    }
    else
    {
        ${MCAN_INSTANCE_NAME}_REGS->MCAN_NDAT2 = (1UL << (bufferNumber - 32U));
    }

    return true;
}

// *****************************************************************************
/* Function:
    bool ${MCAN_INSTANCE_NAME}_RxBufferNumberGet(uint8_t* bufferNumber)

   Summary:
    Get Rx Buffer Number.

   Precondition:
    ${MCAN_INSTANCE_NAME}_Initialize must have been called for the associated MCAN instance.

   Parameters:
    None.

   Returns:
    Request status.
    true  - Request was successful.
    false - Request has failed.
*/
bool ${MCAN_INSTANCE_NAME}_RxBufferNumberGet(uint8_t* bufferNumber)
{
    bool     status = false;
    uint8_t  bufferNum = 0;
    uint32_t newData1 = ${MCAN_INSTANCE_NAME}_REGS->MCAN_NDAT1;
    <#if RX_BUFFER_ELEMENTS gt 32>
    uint32_t newData2 = ${MCAN_INSTANCE_NAME}_REGS->MCAN_NDAT2;
    </#if>

    if (newData1 != 0U)
    {
        <#assign BUF_NUM = 32>
        <#if RX_BUFFER_ELEMENTS lt 32>
        <#assign BUF_NUM = RX_BUFFER_ELEMENTS>
        </#if>
        for (bufferNum = 0U; bufferNum < ${BUF_NUM}U; bufferNum++)
        {
            if ((newData1 & (1UL << bufferNum)) == (1UL << bufferNum))
            {
                *bufferNumber = bufferNum;
                status = true;
                break;
            }
        }
    }
    <#if RX_BUFFER_ELEMENTS gt 32>
    if ((newData2 != 0U) && (status == false))
    {
        for (bufferNum = 0U; bufferNum < (${RX_BUFFER_ELEMENTS}U - 32U); bufferNum++)
        {
            if ((newData2 & (1UL << bufferNum)) == (1UL << bufferNum))
            {
                *bufferNumber = (bufferNum + 32U);
                status = true;
                break;
            }
        }
    }
    </#if>

    return status;
}
</#if>

<#if RXF0_USE || RXF1_USE>
// *****************************************************************************
/* Function:
    bool ${MCAN_INSTANCE_NAME}_MessageReceiveFifo(MCAN_RX_FIFO_NUM rxFifoNum, uint8_t numberOfMessage, MCAN_RX_BUFFER *rxBuffer)

   Summary:
    Read messages from Rx FIFO0/FIFO1.

   Precondition:
    ${MCAN_INSTANCE_NAME}_Initialize must have been called for the associated MCAN instance.

   Parameters:
    rxFifoNum       - Rx FIFO number
    numberOfMessage - Total number of message
    rxBuffer        - Pointer to Rx buffer

   Returns:
    Request status.
    true  - Request was successful.
    false - Request has failed.
*/
bool ${MCAN_INSTANCE_NAME}_MessageReceiveFifo(MCAN_RX_FIFO_NUM rxFifoNum, uint8_t numberOfMessage, MCAN_RX_BUFFER *rxBuffer)
{
    uint8_t rxgi = 0U;
    uint8_t count = 0U;
    uint8_t *rxFifo = NULL;
    uint8_t *rxBuf = (uint8_t *)rxBuffer;
    bool status = false;

    if (rxBuffer == NULL)
    {
        return status;
    }

    switch (rxFifoNum)
    {
<#if RXF0_USE>
        case MCAN_RX_FIFO_0:
            /* Read data from the Rx FIFO0 */
            rxgi = (uint8_t)((${MCAN_INSTANCE_NAME}_REGS->MCAN_RXF0S & MCAN_RXF0S_F0GI_Msk) >> MCAN_RXF0S_F0GI_Pos);
            for (count = 0; count < numberOfMessage; count++)
            {
                rxFifo = (uint8_t *) ((uint8_t *)${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.rxFIFO0Address + ((uint32_t)rxgi * ${MCAN_INSTANCE_NAME}_RX_FIFO0_ELEMENT_SIZE));
				
				/* make sure CPU reads new values from memory by invalidating data cache */
				SCB_InvalidateDCache_by_Addr((uint32_t *) rxFifo, ${MCAN_INSTANCE_NAME}_RX_FIFO0_ELEMENT_SIZE);

                memcpy(rxBuf, rxFifo, ${MCAN_INSTANCE_NAME}_RX_FIFO0_ELEMENT_SIZE);
				
				/* memory barrier to make sure processor updates values*/
				__DMB();

                if ((count + 1) == numberOfMessage)
                {
                    break;
                }
                rxBuf += ${MCAN_INSTANCE_NAME}_RX_FIFO0_ELEMENT_SIZE;
                rxgi++;
                if (rxgi == ${RXF0_ELEMENTS}U)
                {
                    rxgi = 0U;
                }
            }

            /* Ack the fifo position */
            ${MCAN_INSTANCE_NAME}_REGS->MCAN_RXF0A = MCAN_RXF0A_F0AI((uint32_t)rxgi);

            status = true;
            break;
</#if>
<#if RXF1_USE>
        case MCAN_RX_FIFO_1:
            /* Read data from the Rx FIFO1 */
            rxgi = (uint8_t)((${MCAN_INSTANCE_NAME}_REGS->MCAN_RXF1S & MCAN_RXF1S_F1GI_Msk) >> MCAN_RXF1S_F1GI_Pos);
            for (count = 0; count < numberOfMessage; count++)
            {
                rxFifo = (uint8_t *) ((uint8_t *)${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.rxFIFO1Address + ((uint32_t)rxgi * ${MCAN_INSTANCE_NAME}_RX_FIFO1_ELEMENT_SIZE));
				
				/* make sure CPU reads new values from memory by invalidating data cache */
				SCB_InvalidateDCache_by_Addr((uint32_t *) rxFifo, ${MCAN_INSTANCE_NAME}_RX_FIFO1_ELEMENT_SIZE);

                memcpy(rxBuf, rxFifo, ${MCAN_INSTANCE_NAME}_RX_FIFO1_ELEMENT_SIZE);
				
				/* memory barrier to make sure processor updates values*/
				__DMB();

                if ((count + 1) == numberOfMessage)
                {
                    break;
                }
                rxBuf += ${MCAN_INSTANCE_NAME}_RX_FIFO1_ELEMENT_SIZE;
                rxgi++;
                if (rxgi == ${RXF1_ELEMENTS}U)
                {
                    rxgi = 0U;
                }
            }
            /* Ack the fifo position */
            ${MCAN_INSTANCE_NAME}_REGS->MCAN_RXF1A = MCAN_RXF1A_F1AI((uint32_t)rxgi);

            status = true;
            break;
</#if>
        default:
            /* Do nothing */
            break;
    }
    return status;
}

// *****************************************************************************
/* Function:
    uint8_t ${MCAN_INSTANCE_NAME}_RxFifoFillLevelGet(MCAN_RX_FIFO_NUM rxFifoNum)

   Summary:
    Returns Rx FIFO0/FIFO1 Fill Level.

   Precondition:
    ${MCAN_INSTANCE_NAME}_Initialize must have been called for the associated MCAN instance.

   Parameters:
    None.

   Returns:
    Rx FIFO0/FIFO1 Fill Level.
*/
uint8_t ${MCAN_INSTANCE_NAME}_RxFifoFillLevelGet(MCAN_RX_FIFO_NUM rxFifoNum)
{
    if (rxFifoNum == MCAN_RX_FIFO_0)
    {
        return (uint8_t)(${MCAN_INSTANCE_NAME}_REGS->MCAN_RXF0S & MCAN_RXF0S_F0FL_Msk);
    }
    else
    {
        return (uint8_t)(${MCAN_INSTANCE_NAME}_REGS->MCAN_RXF1S & MCAN_RXF1S_F1FL_Msk);
    }
}
</#if>

// *****************************************************************************
/* Function:
    MCAN_ERROR ${MCAN_INSTANCE_NAME}_ErrorGet(void)

   Summary:
    Returns the error during transfer.

   Precondition:
    ${MCAN_INSTANCE_NAME}_Initialize must have been called for the associated MCAN instance.

   Parameters:
    None.

   Returns:
    Error during transfer.
*/
MCAN_ERROR ${MCAN_INSTANCE_NAME}_ErrorGet(void)
{
    MCAN_ERROR error;
    uint32_t   errorStatus = ${MCAN_INSTANCE_NAME}_REGS->MCAN_PSR;

    error = (MCAN_ERROR) ((errorStatus & MCAN_PSR_LEC_Msk) | (errorStatus & MCAN_PSR_EP_Msk) | (errorStatus & MCAN_PSR_EW_Msk)
            | (errorStatus & MCAN_PSR_BO_Msk) | (errorStatus & MCAN_PSR_DLEC_Msk) | (errorStatus & MCAN_PSR_PXE_Msk));

    if ((${MCAN_INSTANCE_NAME}_REGS->MCAN_CCCR & MCAN_CCCR_INIT_Msk) == MCAN_CCCR_INIT_Msk)
    {
        ${MCAN_INSTANCE_NAME}_REGS->MCAN_CCCR &= ~MCAN_CCCR_INIT_Msk;
        while ((${MCAN_INSTANCE_NAME}_REGS->MCAN_CCCR & MCAN_CCCR_INIT_Msk) == MCAN_CCCR_INIT_Msk)
        {
            /* Wait for initialization complete */
        }
    }

    return error;
}

// *****************************************************************************
/* Function:
    void ${MCAN_INSTANCE_NAME}_ErrorCountGet(uint8_t *txErrorCount, uint8_t *rxErrorCount)

   Summary:
    Returns the transmit and receive error count during transfer.

   Precondition:
    ${MCAN_INSTANCE_NAME}_Initialize must have been called for the associated MCAN instance.

   Parameters:
    txErrorCount - Transmit Error Count to be received
    rxErrorCount - Receive Error Count to be received

   Returns:
    None.
*/
void ${MCAN_INSTANCE_NAME}_ErrorCountGet(uint8_t *txErrorCount, uint8_t *rxErrorCount)
{
    *txErrorCount = (uint8_t)(${MCAN_INSTANCE_NAME}_REGS->MCAN_ECR & MCAN_ECR_TEC_Msk);
    *rxErrorCount = (uint8_t)((${MCAN_INSTANCE_NAME}_REGS->MCAN_ECR & MCAN_ECR_REC_Msk) >> MCAN_ECR_REC_Pos);
}

// *****************************************************************************
/* Function:
    bool ${MCAN_INSTANCE_NAME}_InterruptGet(MCAN_INTERRUPT_MASK interruptMask)

   Summary:
    Returns the Interrupt status.

   Precondition:
    ${MCAN_INSTANCE_NAME}_Initialize must have been called for the associated MCAN instance.

   Parameters:
    interruptMask - Interrupt source number

   Returns:
    true - Requested interrupt is occurred.
    false - Requested interrupt is not occurred.
*/
bool ${MCAN_INSTANCE_NAME}_InterruptGet(MCAN_INTERRUPT_MASK interruptMask)
{
    return ((${MCAN_INSTANCE_NAME}_REGS->MCAN_IR & (uint32_t)interruptMask) != 0x0U);
}

// *****************************************************************************
/* Function:
    void ${MCAN_INSTANCE_NAME}_InterruptClear(MCAN_INTERRUPT_MASK interruptMask)

   Summary:
    Clears Interrupt status.

   Precondition:
    ${MCAN_INSTANCE_NAME}_Initialize must have been called for the associated MCAN instance.

   Parameters:
    interruptMask - Interrupt to be cleared

   Returns:
    None
*/
void ${MCAN_INSTANCE_NAME}_InterruptClear(MCAN_INTERRUPT_MASK interruptMask)
{
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_IR = (uint32_t)interruptMask;
}

// *****************************************************************************
/* Function:
    void ${MCAN_INSTANCE_NAME}_MessageRAMConfigSet(uint8_t *msgRAMConfigBaseAddress)

   Summary:
    Set the Message RAM Configuration.

   Precondition:
    ${MCAN_INSTANCE_NAME}_Initialize must have been called for the associated MCAN instance.

   Parameters:
    msgRAMConfigBaseAddress - Pointer to application allocated buffer base address.
                              Application must allocate buffer from non-cached
                              contiguous memory and buffer size must be
                              ${MCAN_INSTANCE_NAME}_MESSAGE_RAM_CONFIG_SIZE

   Returns:
    None
*/
void ${MCAN_INSTANCE_NAME}_MessageRAMConfigSet(uint8_t *msgRAMConfigBaseAddress)
{
    uint32_t offset = 0U;

    memset((void*)msgRAMConfigBaseAddress, 0x00, ${MCAN_INSTANCE_NAME}_MESSAGE_RAM_CONFIG_SIZE);

    /* Set MCAN CCCR Init for Message RAM Configuration */
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_CCCR |= MCAN_CCCR_INIT_ENABLED;
    while ((${MCAN_INSTANCE_NAME}_REGS->MCAN_CCCR & MCAN_CCCR_INIT_Msk) != MCAN_CCCR_INIT_Msk)
    {
        /* Wait for configuration complete */
    }

    /* Set CCE to unlock the configuration registers */
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_CCCR |= MCAN_CCCR_CCE_Msk;

<#if RXF0_USE>
    ${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.rxFIFO0Address = (mcan_rxf0e_registers_t *)msgRAMConfigBaseAddress;
    offset = ${MCAN_INSTANCE_NAME}_RX_FIFO0_SIZE;
    /* Receive FIFO 0 Configuration Register */
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_RXF0C = MCAN_RXF0C_F0S(${RXF0_ELEMENTS}UL) | MCAN_RXF0C_F0WM(${RXF0_WATERMARK}UL)<#if RXF0_OVERWRITE> | MCAN_RXF0C_F0OM_Msk</#if> |
            MCAN_RXF0C_F0SA(((uint32_t)${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.rxFIFO0Address >> 2));

</#if>
<#if RXF1_USE>
    ${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.rxFIFO1Address = (mcan_rxf1e_registers_t *)(msgRAMConfigBaseAddress + offset);
    offset += ${MCAN_INSTANCE_NAME}_RX_FIFO1_SIZE;
    /* Receive FIFO 1 Configuration Register */
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_RXF1C = MCAN_RXF1C_F1S(${RXF1_ELEMENTS}UL) | MCAN_RXF1C_F1WM(${RXF1_WATERMARK}UL)<#if RXF1_OVERWRITE> | MCAN_RXF1C_F1OM_Msk</#if> |
            MCAN_RXF1C_F1SA(((uint32_t)${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.rxFIFO1Address >> 2));

</#if>
<#if RXBUF_USE>
    ${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.rxBuffersAddress = (mcan_rxbe_registers_t *)(msgRAMConfigBaseAddress + offset);
    offset += ${MCAN_INSTANCE_NAME}_RX_BUFFER_SIZE;
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_RXBC = MCAN_RXBC_RBSA(((uint32_t)${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.rxBuffersAddress >> 2));

</#if>
<#if TX_USE || TXBUF_USE>
    ${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.txBuffersAddress = (mcan_txbe_registers_t *)(msgRAMConfigBaseAddress + offset);
    offset += ${MCAN_INSTANCE_NAME}_TX_FIFO_BUFFER_SIZE;
    /* Transmit Buffer/FIFO Configuration Register */
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_TXBC = MCAN_TXBC_TFQS(${TX_FIFO_ELEMENTS}UL)<#if TXBUF_USE> | MCAN_TXBC_NDTB(${TX_BUFFER_ELEMENTS}UL)</#if> |
            MCAN_TXBC_TBSA(((uint32_t)${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.txBuffersAddress >> 2));

    ${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.txEventFIFOAddress =  (mcan_txefe_registers_t *)(msgRAMConfigBaseAddress + offset);
    offset += ${MCAN_INSTANCE_NAME}_TX_EVENT_FIFO_SIZE;
    /* Transmit Event FIFO Configuration Register */
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_TXEFC = MCAN_TXEFC_EFWM(${TX_FIFO_WATERMARK}UL) | MCAN_TXEFC_EFS(${TX_FIFO_ELEMENTS}UL) |
            MCAN_TXEFC_EFSA(((uint32_t)${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.txEventFIFOAddress >> 2));

</#if>
<#if FILTERS_STD?number gt 0>
    ${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.stdMsgIDFilterAddress = (mcan_sidfe_registers_t *)(msgRAMConfigBaseAddress + offset);
    memcpy((void *)${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.stdMsgIDFilterAddress,
           (const void *)${MCAN_INSTANCE_NAME?lower_case}StdFilter,
           ${MCAN_INSTANCE_NAME}_STD_MSG_ID_FILTER_SIZE);
    offset += ${MCAN_INSTANCE_NAME}_STD_MSG_ID_FILTER_SIZE;
    /* Standard ID Filter Configuration Register */
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_SIDFC = MCAN_SIDFC_LSS(${FILTERS_STD}UL) |
            MCAN_SIDFC_FLSSA(((uint32_t)${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.stdMsgIDFilterAddress >> 2));

</#if>
<#if FILTERS_EXT?number gt 0>
    ${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.extMsgIDFilterAddress = (mcan_xidfe_registers_t *)(msgRAMConfigBaseAddress + offset);
    memcpy((void *)${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.extMsgIDFilterAddress,
           (const void *)${MCAN_INSTANCE_NAME?lower_case}ExtFilter,
           ${MCAN_INSTANCE_NAME}_EXT_MSG_ID_FILTER_SIZE);
    /* Extended ID Filter Configuration Register */
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_XIDFC = MCAN_XIDFC_LSE(${FILTERS_EXT}UL) |
            MCAN_XIDFC_FLESA(((uint32_t)${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.extMsgIDFilterAddress >> 2));

</#if>
    /* Set 16-bit MSB of ${MCAN_INSTANCE_NAME?lower_case} base address */
<#if MCAN_SFR_CAN_ENABLE_VALUE == 1>
  <#if MCAN_INSTANCE_NAME?lower_case == "mcan0">
    SFR_REGS->SFR_CAN = (SFR_REGS->SFR_CAN & ~SFR_CAN_EXT_MEM_CAN0_ADDR_Msk)
                       | SFR_CAN_EXT_MEM_CAN0_ADDR(((uint32_t)msgRAMConfigBaseAddress >> 16));
  <#else>
    SFR_REGS->SFR_CAN = (SFR_REGS->SFR_CAN & ~SFR_CAN_EXT_MEM_CAN1_ADDR_Msk)
                       | SFR_CAN_EXT_MEM_CAN1_ADDR(((uint32_t)msgRAMConfigBaseAddress >> 16));
  </#if>
<#elseif MCAN_SFR_CAN_ENABLE_VALUE == 3>
    SFR_REGS->SFR_CAN${MCAN_INSTANCE_NAME?lower_case?remove_beginning("mcan")} =
        (SFR_REGS->SFR_CAN${MCAN_INSTANCE_NAME?lower_case?remove_beginning("mcan")} & ~SFR_CAN${MCAN_INSTANCE_NAME?lower_case?remove_beginning("mcan")}_EXT_MEM_ADDR_Msk) |
         SFR_CAN${MCAN_INSTANCE_NAME?lower_case?remove_beginning("mcan")}_EXT_MEM_ADDR(((uint32_t)msgRAMConfigBaseAddress >> 16));
<#elseif MCAN_MATRIX_CAN_ENABLE == true>
  <#if MCAN_INSTANCE_NAME?lower_case == "mcan0">
    MATRIX_REGS->CCFG_CAN0 = (MATRIX_REGS->CCFG_CAN0 & ~CCFG_CAN0_Msk)
                            | CCFG_CAN0_CAN0DMABA(((uint32_t)msgRAMConfigBaseAddress >> 16));
  <#else>
    MATRIX_REGS->CCFG_SYSIO = (MATRIX_REGS->CCFG_SYSIO & ~CCFG_SYSIO_CAN1DMABA_Msk)
                            | CCFG_SYSIO_CAN1DMABA(((uint32_t)msgRAMConfigBaseAddress >> 16));
  </#if>
</#if>

    /* Reference offset variable once to remove warning about the variable not being used after increment */
    (void)offset;

    /* Complete Message RAM Configuration by clearing MCAN CCCR Init */
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_CCCR &= ~MCAN_CCCR_INIT_Msk;
    while ((${MCAN_INSTANCE_NAME}_REGS->MCAN_CCCR & MCAN_CCCR_INIT_Msk) == MCAN_CCCR_INIT_Msk)
    {
        /* Wait for configuration complete */
    }
}

<#if FILTERS_STD?number gt 0>
// *****************************************************************************
/* Function:
    bool ${MCAN_INSTANCE_NAME}_StandardFilterElementSet(uint8_t filterNumber, mcan_sidfe_registers_t *stdMsgIDFilterElement)

   Summary:
    Set a standard filter element configuration.

   Precondition:
    ${MCAN_INSTANCE_NAME}_Initialize and ${MCAN_INSTANCE_NAME}_MessageRAMConfigSet must have been called
    for the associated MCAN instance.

   Parameters:
    filterNumber          - Standard Filter number to be configured.
    stdMsgIDFilterElement - Pointer to Standard Filter Element configuration to be set on specific filterNumber.

   Returns:
    Request status.
    true  - Request was successful.
    false - Request has failed.
*/
bool ${MCAN_INSTANCE_NAME}_StandardFilterElementSet(uint8_t filterNumber, mcan_sidfe_registers_t *stdMsgIDFilterElement)
{
    if ((filterNumber > ${FILTERS_STD}U) || (stdMsgIDFilterElement == NULL))
    {
        return false;
    }
    ${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.stdMsgIDFilterAddress[filterNumber - 1U].MCAN_SIDFE_0 = stdMsgIDFilterElement->MCAN_SIDFE_0;

    return true;
}

// *****************************************************************************
/* Function:
    bool ${MCAN_INSTANCE_NAME}_StandardFilterElementGet(uint8_t filterNumber, mcan_sidfe_registers_t *stdMsgIDFilterElement)

   Summary:
    Get a standard filter element configuration.

   Precondition:
    ${MCAN_INSTANCE_NAME}_Initialize and ${MCAN_INSTANCE_NAME}_MessageRAMConfigSet must have been called
    for the associated MCAN instance.

   Parameters:
    filterNumber          - Standard Filter number to get filter configuration.
    stdMsgIDFilterElement - Pointer to Standard Filter Element configuration for storing filter configuration.

   Returns:
    Request status.
    true  - Request was successful.
    false - Request has failed.
*/
bool ${MCAN_INSTANCE_NAME}_StandardFilterElementGet(uint8_t filterNumber, mcan_sidfe_registers_t *stdMsgIDFilterElement)
{
    if ((filterNumber > ${FILTERS_STD}U) || (stdMsgIDFilterElement == NULL))
    {
        return false;
    }
    stdMsgIDFilterElement->MCAN_SIDFE_0 = ${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.stdMsgIDFilterAddress[filterNumber - 1U].MCAN_SIDFE_0;

    return true;
}
</#if>

<#if FILTERS_EXT?number gt 0>
// *****************************************************************************
/* Function:
    bool ${MCAN_INSTANCE_NAME}_ExtendedFilterElementSet(uint8_t filterNumber, mcan_xidfe_registers_t *extMsgIDFilterElement)

   Summary:
    Set a Extended filter element configuration.

   Precondition:
    ${MCAN_INSTANCE_NAME}_Initialize and ${MCAN_INSTANCE_NAME}_MessageRAMConfigSet must have been called
    for the associated MCAN instance.

   Parameters:
    filterNumber          - Extended Filter number to be configured.
    extMsgIDFilterElement - Pointer to Extended Filter Element configuration to be set on specific filterNumber.

   Returns:
    Request status.
    true  - Request was successful.
    false - Request has failed.
*/
bool ${MCAN_INSTANCE_NAME}_ExtendedFilterElementSet(uint8_t filterNumber, mcan_xidfe_registers_t *extMsgIDFilterElement)
{
    if ((filterNumber > ${FILTERS_EXT}U) || (extMsgIDFilterElement == NULL))
    {
        return false;
    }
    ${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.extMsgIDFilterAddress[filterNumber - 1U].MCAN_XIDFE_0 = extMsgIDFilterElement->MCAN_XIDFE_0;
    ${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.extMsgIDFilterAddress[filterNumber - 1U].MCAN_XIDFE_1 = extMsgIDFilterElement->MCAN_XIDFE_1;

    return true;
}

// *****************************************************************************
/* Function:
    bool ${MCAN_INSTANCE_NAME}_ExtendedFilterElementGet(uint8_t filterNumber, mcan_xidfe_registers_t *extMsgIDFilterElement)

   Summary:
    Get a Extended filter element configuration.

   Precondition:
    ${MCAN_INSTANCE_NAME}_Initialize and ${MCAN_INSTANCE_NAME}_MessageRAMConfigSet must have been called
    for the associated MCAN instance.

   Parameters:
    filterNumber          - Extended Filter number to get filter configuration.
    extMsgIDFilterElement - Pointer to Extended Filter Element configuration for storing filter configuration.

   Returns:
    Request status.
    true  - Request was successful.
    false - Request has failed.
*/
bool ${MCAN_INSTANCE_NAME}_ExtendedFilterElementGet(uint8_t filterNumber, mcan_xidfe_registers_t *extMsgIDFilterElement)
{
    if ((filterNumber > ${FILTERS_EXT}U) || (extMsgIDFilterElement == NULL))
    {
        return false;
    }
    extMsgIDFilterElement->MCAN_XIDFE_0 = ${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.extMsgIDFilterAddress[filterNumber - 1U].MCAN_XIDFE_0;
    extMsgIDFilterElement->MCAN_XIDFE_1 = ${MCAN_INSTANCE_NAME?lower_case}Obj.msgRAMConfig.extMsgIDFilterAddress[filterNumber - 1U].MCAN_XIDFE_1;

    return true;
}
</#if>

void ${MCAN_INSTANCE_NAME}_SleepModeEnter(void)
{
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_CCCR |=  MCAN_CCCR_CSR_Msk;
    while ((${MCAN_INSTANCE_NAME}_REGS->MCAN_CCCR & MCAN_CCCR_CSA_Msk) != MCAN_CCCR_CSA_Msk)
    {
        /* Wait for clock stop request to complete */
    }
}

void ${MCAN_INSTANCE_NAME}_SleepModeExit(void)
{
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_CCCR &=  ~MCAN_CCCR_CSR_Msk;
    while ((${MCAN_INSTANCE_NAME}_REGS->MCAN_CCCR & MCAN_CCCR_CSA_Msk) == MCAN_CCCR_CSA_Msk)
    {
        /* Wait for no clock stop */
    }
    ${MCAN_INSTANCE_NAME}_REGS->MCAN_CCCR &= ~MCAN_CCCR_INIT_Msk;
    while ((${MCAN_INSTANCE_NAME}_REGS->MCAN_CCCR & MCAN_CCCR_INIT_Msk) == MCAN_CCCR_INIT_Msk)
    {
        /* Wait for initialization complete */
    }
}

/*******************************************************************************
 End of File
*/
