/*******************************************************************************
  Power Manager(${PM_INSTANCE_NAME}) PLIB

  Company
    Microchip Technology Inc.

  File Name
    plib_${PM_INSTANCE_NAME?lower_case}.c

  Summary
    ${PM_INSTANCE_NAME} PLIB Implementation File.

  Description
    This file defines the interface to the PM peripheral library. This
    library provides access to and control of the associated peripheral
    instance.

  Remarks:
    None.

*******************************************************************************/

// DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2019 Microchip Technology Inc. and its subsidiaries.
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
/* This section lists the other files that are included in this file.
*/

#include "device.h"
#include "plib_${PM_INSTANCE_NAME?lower_case}.h"

<#if PM_WPCTRL__WPEN || PM_WPCTRL__WPLCK>
#define PM_WPKEY_VALUE 0x505752U
</#if>

void PM_Initialize( void )
{
	<#if PM_WPCTRL__WPEN>
    // Enable Write Protect
    ${PM_INSTANCE_NAME}_REGS->PM_WPCTRL = PM_WPCTRL_WPKEY(PM_WPKEY_VALUE) | PM_WPCTRL_WPEN_Msk;
    </#if>
	<#if PM_WPCTRL__WPLCK && PM_WPCTRL__WPEN>
    // Enable Write Protect Lock
    ${PM_INSTANCE_NAME}_REGS->PM_WPCTRL = PM_WPCTRL_WPKEY(PM_WPKEY_VALUE) | PM_WPCTRL_WPEN_Msk | PM_WPCTRL_WPLCK_Msk;
    </#if>

}

void ${PM_INSTANCE_NAME}_IdleModeEnter( void )
{
    <#if PM_IDLE_OPTION ? has_content>
    ${PM_INSTANCE_NAME}_REGS->PM_SLEEPCFG = (uint8_t)PM_SLEEPCFG_SLEEPMODE(${PM_IDLE_OPTION}UL);

    
    while ((${PM_INSTANCE_NAME}_REGS->PM_SLEEPCFG & PM_SLEEPCFG_SLEEPMODE_Msk) != PM_SLEEPCFG_SLEEPMODE(${PM_IDLE_OPTION}UL))
    {
        /* Ensure that SLEEPMODE bits are configured with the given value */
    }
    <#else>
    /* Configure Idle Sleep mode */
    ${PM_INSTANCE_NAME}_REGS->PM_SLEEPCFG = (uint8_t)PM_SLEEPCFG_SLEEPMODE_IDLE_Val;

    while ((${PM_INSTANCE_NAME}_REGS->PM_SLEEPCFG & PM_SLEEPCFG_SLEEPMODE_IDLE_Val) == 0U)
    {
        /* Ensure that SLEEPMODE bits are configured with the given value */
    }
    </#if>
    /* Wait for interrupt instruction execution */
    __WFI();
}

void ${PM_INSTANCE_NAME}_StandbyModeEnter( void )
{
    /* Configure Standby Sleep */
    ${PM_INSTANCE_NAME}_REGS->PM_SLEEPCFG = (uint8_t)PM_SLEEPCFG_SLEEPMODE_STANDBY_Val;
  
    while ((${PM_INSTANCE_NAME}_REGS->PM_SLEEPCFG & PM_SLEEPCFG_SLEEPMODE_STANDBY_Val) == 0U)
    {
        /* Ensure that SLEEPMODE bits are configured with the given value */
    }

    /* Wait for interrupt instruction execution */
    __WFI();
}

<#if HAS_BACKUP_SLEEP??>
void ${PM_INSTANCE_NAME}_BackupModeEnter( void )
{
    /* Configure Backup Sleep */
    ${PM_INSTANCE_NAME}_REGS->PM_SLEEPCFG = (uint8_t)PM_SLEEPCFG_SLEEPMODE_BACKUP_Val;
    
    while ((${PM_INSTANCE_NAME}_REGS->PM_SLEEPCFG & PM_SLEEPCFG_SLEEPMODE_BACKUP_Val) == 0U)
    {
        /* Ensure that SLEEPMODE bits are configured with the given value */
    }

    /* Wait for interrupt instruction execution */
    __WFI();
}
</#if>

<#if HAS_OFF_SLEEP??>
void ${PM_INSTANCE_NAME}_OffModeEnter( void )
{
    /* Configure Off Sleep */
    ${PM_INSTANCE_NAME}_REGS->PM_SLEEPCFG = (uint8_t)PM_SLEEPCFG_SLEEPMODE_OFF_Val;

    while ((${PM_INSTANCE_NAME}_REGS->PM_SLEEPCFG & PM_SLEEPCFG_SLEEPMODE_OFF_Val) == 0U)
    {
        /* Ensure that SLEEPMODE bits are configured with the given value */
    }

    /* Wait for interrupt instruction execution */
    __WFI();
}
</#if>
<#if HAS_IORET_BIT??>

/* ********Important Note********
 * When IORET is enabled, SWD access to the device will not be
 * available after waking up from Backup sleep until
 * the bit is cleared by the application.
 */
void ${PM_INSTANCE_NAME}_IO_RetentionSet( void )
{
    ${PM_INSTANCE_NAME}_REGS->PM_CTRLA |= (uint8_t)PM_CTRLA_IORET_Msk;
}

void ${PM_INSTANCE_NAME}_IO_RetentionClear( void )
{
    ${PM_INSTANCE_NAME}_REGS->PM_CTRLA &= (uint8_t)(~PM_CTRLA_IORET_Msk);
}
</#if>

<#if HAS_PLCFG??>
bool ${PM_INSTANCE_NAME}_ConfigurePerformanceLevel(PLCFG_PLSEL plsel)
{
    bool status = false;

    /* Write the value only if Performance Level Disable is not set */
    if ((${PM_INSTANCE_NAME}_REGS->PM_PLCFG & PM_PLCFG_PLDIS_Msk) == 0U)
    {
        if((${PM_INSTANCE_NAME}_REGS->PM_PLCFG & PM_PLCFG_PLSEL_Msk) != (uint8_t)plsel)
        {
            /* Clear INTFLAG.PLRDY */
            ${PM_INSTANCE_NAME}_REGS->PM_INTFLAG |= (uint8_t)PM_INTENCLR_PLRDY_Msk;

            /* Write PLSEL bits */
            ${PM_INSTANCE_NAME}_REGS->PM_PLCFG  = (uint8_t)plsel;

            while((${PM_INSTANCE_NAME}_REGS->PM_INTFLAG & PM_INTFLAG_PLRDY_Msk) == 0U)
            {
                /* Wait for performance level transition to complete */
            }

            status = true;
        }
    }

    return status;
}

</#if>
