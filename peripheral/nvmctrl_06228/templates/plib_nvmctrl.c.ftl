/*******************************************************************************
  Non-Volatile Memory Controller(${NVMCTRL_INSTANCE_NAME}) PLIB.

  Company:
    Microchip Technology Inc.

  File Name:
    plib_${NVMCTRL_INSTANCE_NAME?lower_case}.c

  Summary:
    Interface definition of ${NVMCTRL_INSTANCE_NAME} Plib.

  Description:
    This file defines the interface for the ${NVMCTRL_INSTANCE_NAME} Plib.
    It allows user to Program, Erase and lock the on-chip Non Volatile Flash
    Memory.
*******************************************************************************/

// DOM-IGNORE-BEGIN
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
// DOM-IGNORE-END

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include <string.h>
#include "plib_${NVMCTRL_INSTANCE_NAME?lower_case}.h"
<#if core.CoreSysIntFile == true>
#include "interrupts.h"
</#if>

<#if INTERRUPT_ENABLE == true>

typedef struct
{
    NVMCTRL_CALLBACK CallbackFunc;
    uintptr_t Context;
}nvmCallbackObjType;

static volatile nvmCallbackObjType ${NVMCTRL_INSTANCE_NAME?lower_case}CallbackObj;
</#if>
// *****************************************************************************
// *****************************************************************************
// Section: ${NVMCTRL_INSTANCE_NAME} Implementation
// *****************************************************************************
// *****************************************************************************

<#if INTERRUPT_ENABLE == true>


    <#lt>void ${NVMCTRL_INSTANCE_NAME}_CallbackRegister( NVMCTRL_CALLBACK callback, uintptr_t context )
    <#lt>{
    <#lt>    /* Register callback function */
    <#lt>    ${NVMCTRL_INSTANCE_NAME?lower_case}CallbackObj.CallbackFunc = callback;
    <#lt>    ${NVMCTRL_INSTANCE_NAME?lower_case}CallbackObj.Context = context;
    <#lt>}

    <#lt>void __attribute__((used)) ${NVMCTRL_INSTANCE_NAME}_InterruptHandler(void)
    <#lt>{
    <#lt>    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_INTENCLR = NVMCTRL_INTENCLR_READY_Msk;

    <#lt>    if(${NVMCTRL_INSTANCE_NAME?lower_case}CallbackObj.CallbackFunc != NULL)
    <#lt>    {
    <#lt>        uintptr_t context = ${NVMCTRL_INSTANCE_NAME?lower_case}CallbackObj.Context;
    <#lt>        ${NVMCTRL_INSTANCE_NAME?lower_case}CallbackObj.CallbackFunc(context);
    <#lt>    }
    <#lt>}
</#if>

/*
void ${NVMCTRL_INSTANCE_NAME}_Initialize(void)
{

}
*/

bool ${NVMCTRL_INSTANCE_NAME}_Read( uint32_t *data, uint32_t length, const uint32_t address )
{
    uint32_t *paddress_read = (uint32_t *)address;
    (void) memcpy(data, paddress_read, length);
    return true;
}

bool ${NVMCTRL_INSTANCE_NAME}_WordWrite( uint32_t *data, const uint32_t address, uint32_t word_count )
{
    uint32_t i;
    uint32_t * paddress = (uint32_t *)address;

	/* Erase page before write 
	if ( ${NVMCTRL_INSTANCE_NAME}_PageErase( address ) == false){
		return false;
	}
	*/
	
    /* Set address and command */
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_ADDR = address >> 1U;

    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_CTRLB = NVMCTRL_CTRLB_CMD_FLWR_Val | NVMCTRL_CTRLB_CMDEX_KEY;

	/* writing 32-bit data into the given address */
    for (i = 0U; i < word_count; i++)
    {
        *paddress = data[i];
         paddress++;
    }

<#if INTERRUPT_ENABLE == true>
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_INTENSET = NVMCTRL_INTENSET_READY_Msk;
</#if>
    return true;
}

bool ${WRITE_API_NAME}( uint32_t *data, const uint32_t address )
{
    uint32_t i;
    uint32_t * paddress = (uint32_t *)address;

	/* Erase page before write */
	if ( ${NVMCTRL_INSTANCE_NAME}_PageErase( address ) == false){
		return false;
	}
	
    /* Set address and command */
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_ADDR = address >> 1U;

    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_CTRLB = NVMCTRL_CTRLB_CMD_FLWR_Val | NVMCTRL_CTRLB_CMDEX_KEY;

	/* writing 32-bit data into the given address */
    for (i = 0U; i < (${NVMCTRL_INSTANCE_NAME}_FLASH_PAGESIZE/4U); i++)
    {
        *paddress = data[i];
         paddress++;
    }

<#if INTERRUPT_ENABLE == true>
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_INTENSET = NVMCTRL_INTENSET_READY_Msk;
</#if>
    return true;
}

bool ${NVMCTRL_INSTANCE_NAME}_PagesErase(uint32_t start_address, FLASH_ERASE num_pages)
{
    uint8_t cmd;

    switch (num_pages)
    {
		case FLASH_ERASE_2_PAGE:
            cmd = NVMCTRL_CTRLB_CMD_FLMPER2_Val;
			break;
        case FLASH_ERASE_4_PAGE:
            cmd = NVMCTRL_CTRLB_CMD_FLMPER4_Val;
            break;
        case FLASH_ERASE_8_PAGE:
            cmd = NVMCTRL_CTRLB_CMD_FLMPER8_Val;
            break;
        case FLASH_ERASE_16_PAGE:
            cmd = NVMCTRL_CTRLB_CMD_FLMPER16_Val;
            break;
        case FLASH_ERASE_32_PAGE:
            cmd = NVMCTRL_CTRLB_CMD_FLMPER32_Val;
            break;
        default:
            return false;  
    }

	/* Set address and command */
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_ADDR = start_address >> 1U;
	
    /* Issue erase command */
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_CTRLB = cmd | NVMCTRL_CTRLB_CMDEX_KEY;
	
	${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_INTENSET = NVMCTRL_INTENSET_READY_Msk;

    return true;
}

bool ${ERASE_API_NAME}( uint32_t address )
{
    /* Set address and command */
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_ADDR = address >> 1U;

    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_CTRLB = NVMCTRL_CTRLB_CMD_FLPER_Val | NVMCTRL_CTRLB_CMDEX_KEY;

<#if INTERRUPT_ENABLE == true>
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_INTENSET = NVMCTRL_INTENSET_READY_Msk;
</#if>
    return true;
}

bool ${NVMCTRL_INSTANCE_NAME}_BOOTCFG_WordWrite( uint32_t *data, const uint32_t address, uint32_t word_count )
{
    uint32_t i;
    uint32_t * paddress = (uint32_t *)address;

	/* Set address and command */
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_ADDR = address >> 1U;

    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_CTRLB = NVMCTRL_CTRLB_CMD_WBOOTCFG_Val | NVMCTRL_CTRLB_CMDEX_KEY;

	/* writing 32-bit data into the given address */
    for (i = 0U; i < word_count; i++)
    {
        *paddress = data[i];
         paddress++;
    }
    
<#if INTERRUPT_ENABLE == true>
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_INTENSET = NVMCTRL_INTENSET_READY_Msk;
</#if>
    return true;
}

bool ${NVMCTRL_INSTANCE_NAME}_BOOTCFG_PageWrite( uint32_t *data, const uint32_t address )
{
    uint32_t i;
    uint32_t * paddress = (uint32_t *)address;

    /* Set address and command */
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_ADDR = address >> 1U;

    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_CTRLB = NVMCTRL_CTRLB_CMD_WBOOTCFG_Val | NVMCTRL_CTRLB_CMDEX_KEY;

    /* writing 32-bit data into the given address */
    for (i = 0U; i < (NVMCTRL_FLASH_PAGESIZE/4U); i++)
    {
        *paddress = data[i];
         paddress++;
    }

<#if INTERRUPT_ENABLE == true>
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_INTENSET = NVMCTRL_INTENSET_READY_Msk;
</#if>
    return true;
}

bool ${NVMCTRL_INSTANCE_NAME}_BOOTCFG_PageErase( uint32_t address )
{
    /* Set address and command */
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_ADDR = address >> 1U;

    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_CTRLB = NVMCTRL_CTRLB_CMD_EBOOTCFG_Val | NVMCTRL_CTRLB_CMDEX_KEY;

<#if INTERRUPT_ENABLE == true>
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_INTENSET = NVMCTRL_INTENSET_READY_Msk;
</#if>
    return true;
}


NVMCTRL_ERROR ${NVMCTRL_INSTANCE_NAME}_ErrorGet( void )
{
    volatile uint16_t nvm_error;

    /* Get the error bits set */
    nvm_error = (${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_STATUS & ((uint8_t) NVMCTRL_STATUS_LOCKE_Msk | NVMCTRL_STATUS_PROGE_Msk));

    /* Clear the error bits in both STATUS and INTFLAG register */
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_STATUS |= nvm_error;

    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_INTFLAG = NVMCTRL_INTFLAG_ERROR_Msk;

    return (nvm_error);
}

bool ${NVMCTRL_INSTANCE_NAME}_IsBusy(void)
{
    return ((${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_INTFLAG & NVMCTRL_INTFLAG_READY_Msk) == 0U);
}

void ${NVMCTRL_INSTANCE_NAME}_RegionLock(uint32_t address)
{
    /* Set address and command */
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_ADDR = address >> 1U;

    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_CTRLB = NVMCTRL_CTRLB_CMD_LR_Val | NVMCTRL_CTRLB_CMDEX_KEY;
}

void ${NVMCTRL_INSTANCE_NAME}_RegionUnlock(uint32_t address)
{
    /* Set address and command */
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_ADDR = address >> 1U;

    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_CTRLB = NVMCTRL_CTRLB_CMD_UR_Val | NVMCTRL_CTRLB_CMDEX_KEY;
}

void ${NVMCTRL_INSTANCE_NAME}_CMD_Clear(void)
{
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_CTRLB = NVMCTRL_CTRLB_CMD_NOCMD | NVMCTRL_CTRLB_CMDEX_KEY;
}

void ${NVMCTRL_INSTANCE_NAME}_WriteProtect_enable( void )
{
	${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_WPCTRL = NVMCTRL_WPCTRL_WPKEY(NVMCTRL_WPCTRL_KEY)| NVMCTRL_WPCTRL_WPEN_Msk;
}

void NVMCTRL_WriteProtect_disable( void )
{
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_WPCTRL = NVMCTRL_WPCTRL_WPKEY(NVMCTRL_WPCTRL_KEY) & (~NVMCTRL_WPCTRL_WPEN_Msk);
}

uint32_t ${NVMCTRL_INSTANCE_NAME}_InterruptFlagGet(void)
{
    uint32_t intFlag =  ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_INTFLAG & NVMCTRL_INTFLAG_Msk;
    /* Clear interrupt falg */
    ${NVMCTRL_INSTANCE_NAME}_REGS->NVMCTRL_INTFLAG = intFlag;
    return intFlag;
}

