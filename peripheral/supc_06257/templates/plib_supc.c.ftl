/*******************************************************************************
  Supply Controller(${SUPC_INSTANCE_NAME}) PLIB

  Company
    Microchip Technology Inc.

  File Name
    plib_${SUPC_INSTANCE_NAME?lower_case}.c

  Summary
    ${SUPC_INSTANCE_NAME} PLIB Implementation File.

  Description
    This file defines the interface to the SUPC peripheral library. This
    library provides access to and control of the associated peripheral
    instance.

  Remarks:
    None.

*******************************************************************************/

// DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2025 Microchip Technology Inc. and its subsidiaries.
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

<#if core.CoreSysIntFile == true>
#include "interrupts.h"
</#if>
#include "device.h"
#include "plib_${SUPC_INSTANCE_NAME?lower_case}.h"

<#assign SUPC_VREG_VAL = "">
<#assign SUPC_MVIO_VAL = "">
<#assign SUPC_EVCTRL_VAL = "">
<#assign SUPC_INT_VAL = "">
<#assign SUPC_BOD_VLMLVL_VAL = "">
<#assign SUPC_BOD_VLMLVL = "SUPC_BODVDD_VLMLVL">
<#assign SUPC_BOD_VLMCFG_VAL = "">
<#assign SUPC_BOD_VLMCFG = "SUPC_BODVDD_VLMCFG">
<#assign SUPC_BOD_VAL = "">
<#assign SUPC_BOD_FACTORY_DATA_MASK = "SUPC_BODVDD_ENABLE_Msk | SUPC_BODVDD_LEVEL_Msk | SUPC_BODVDD_SAMPFREQ_Msk">
<#assign SUPC_BOD_RUNSTDBY = "SUPC_BODVDD_RUNSTDBY">
<#assign SUPC_BOD_STDBYCFG = "SUPC_BODVDD_STDBYCFG">
<#assign SUPC_BOD_ACTCFG = "SUPC_BODVDD_ACTCFG">
<#assign SUPC_BOD_WRTLOCK = "SUPC_BODVDD_WRTLOCK">
<#if SUPC_BOD_VLMLVL??>
    <#assign SUPC_BOD_VLMLVL_VAL = "${SUPC_BOD_VLMLVL}(${.vars[SUPC_BOD_VLMLVL]}UL)">
    <#assign SUPC_BOD_VAL = SUPC_BOD_VLMLVL_VAL>
</#if>
<#if SUPC_BOD_VLMCFG??>
    <#assign SUPC_BOD_VLMCFG_VAL = "${SUPC_BOD_VLMCFG}(${.vars[SUPC_BOD_VLMCFG]}UL)">
    <#if SUPC_BOD_VAL != "">
        <#assign SUPC_BOD_VAL = SUPC_BOD_VAL + " | " + SUPC_BOD_VLMCFG_VAL>
    <#else>
        <#assign SUPC_BOD_VAL = SUPC_BOD_VLMCFG_VAL>
    </#if>
</#if>
<#if .vars[SUPC_BOD_RUNSTDBY]?has_content>
    <#if .vars[SUPC_BOD_RUNSTDBY] == true>
        <#if SUPC_BOD_VAL != "">
        <#assign SUPC_BOD_VAL = SUPC_BOD_VAL + " | SUPC_BODVDD_RUNSTDBY_Msk">
        <#else>
        <#assign SUPC_BOD_VAL = "SUPC_BODVDD_RUNSTDBY_Msk">
        </#if>
    </#if>
</#if>
<#if .vars[SUPC_BOD_STDBYCFG]?has_content>
    <#if .vars[SUPC_BOD_STDBYCFG] == "0x1">
        <#if SUPC_BOD_VAL != "">
        <#assign SUPC_BOD_VAL = SUPC_BOD_VAL + " | SUPC_BODVDD_STDBYCFG_Msk">
        <#else>
        <#assign SUPC_BOD_VAL = "SUPC_BODVDD_STDBYCFG_Msk">
        </#if>
    </#if>
</#if>
<#if .vars[SUPC_BOD_ACTCFG]?has_content>
    <#if .vars[SUPC_BOD_ACTCFG] == "0x1">
        <#if SUPC_BOD_VAL != "">
        <#assign SUPC_BOD_VAL = SUPC_BOD_VAL + " | SUPC_BODVDD_ACTCFG_Msk">
        <#else>
        <#assign SUPC_BOD_VAL = "SUPC_BODVDD_ACTCFG_Msk">
        </#if>
    </#if>
</#if>
<#if .vars[SUPC_BOD_WRTLOCK]?has_content>
    <#if .vars[SUPC_BOD_WRTLOCK] == true>
        <#if SUPC_BOD_VAL != "">
        <#assign SUPC_BOD_VAL = SUPC_BOD_VAL + " | SUPC_BODVDD_WRTLOCK_Msk">
        <#else>
        <#assign SUPC_BOD_VAL = "SUPC_BODVDD_WRTLOCK_Msk">
        </#if>
    </#if>
</#if>
<#if SUPC_VREG_RUNSTDBY?has_content>
    <#if SUPC_VREG_RUNSTDBY == "1">
        <#assign SUPC_VREG_VAL = "SUPC_VREG_RUNSTDBY_Msk">
    </#if>
</#if>
<#if SUPC_MVIO_VDDIO2CFG?has_content>
    <#if SUPC_MVIO_VDDIO2CFG != "0x0">
        <#assign SUPC_MVIO_VDDIO2CFG_VAL = "SUPC_MVIO_VDDIO2CFG">
        <#assign SUPC_MVIO_VDDIO2CFG_VALUE = "${SUPC_MVIO_VDDIO2CFG_VAL}(${.vars[SUPC_MVIO_VDDIO2CFG_VAL]}UL)">
        <#assign SUPC_MVIO_VAL = SUPC_MVIO_VDDIO2CFG_VALUE>
    </#if>
</#if>
<#if SUPC_EVCTRL_VLMEO == true>
    <#if SUPC_EVCTRL_VAL != "">
    <#assign SUPC_EVCTRL_VAL = SUPC_EVCTRL_VAL + " | SUPC_EVCTRL_VLMEO_Msk">
    <#else>
    <#assign SUPC_EVCTRL_VAL = "SUPC_EVCTRL_VLMEO_Msk">
    </#if>
</#if>
<#if SUPC_EVCTRL_MVIOEO == true>
    <#if SUPC_EVCTRL_VAL != "">
    <#assign SUPC_EVCTRL_VAL = SUPC_EVCTRL_VAL + " | SUPC_EVCTRL_MVIOEO_Msk">
    <#else>
    <#assign SUPC_EVCTRL_VAL = "SUPC_EVCTRL_MVIOEO_Msk">
    </#if>
</#if>
<#if SUPC_INTENSET_VDDIO2LPMPOR == true>
    <#if SUPC_INT_VAL != "">
    <#assign SUPC_INT_VAL = SUPC_INT_VAL + " | SUPC_INTENSET_VDDIO2LPMPOR_Msk">
    <#else>
    <#assign SUPC_INT_VAL = "SUPC_INTENSET_VDDIO2LPMPOR_Msk">
    </#if>
</#if>
<#if SUPC_INTENSET_VDDIO2OK == true>
    <#if SUPC_INT_VAL != "">
    <#assign SUPC_INT_VAL = SUPC_INT_VAL + " | SUPC_INTENSET_VDDIO2OK_Msk">
    <#else>
    <#assign SUPC_INT_VAL = "SUPC_INTENSET_VDDIO2OK_Msk">
    </#if>
</#if>
<#if SUPC_INTENSET_VLM == true>
    <#if SUPC_INT_VAL != "">
    <#assign SUPC_INT_VAL = SUPC_INT_VAL + " | SUPC_INTENSET_VLM_Msk">
    <#else>
    <#assign SUPC_INT_VAL = "SUPC_INTENSET_VLM_Msk">
    </#if>
</#if>
<#if SUPC_INTENSET_BODVDDRDY == true>
    <#if SUPC_INT_VAL != "">
    <#assign SUPC_INT_VAL = SUPC_INT_VAL + " | SUPC_INTENSET_BODVDDRDY_Msk">
    <#else>
    <#assign SUPC_INT_VAL = "SUPC_INTENSET_BODVDDRDY_Msk">
    </#if>
</#if>

<#if SUPC_INT_VAL?has_content>
typedef struct
{
    SUPC_CALLBACK callback;
    uintptr_t context;
} SUPC_CALLBACK_OBJ;

static volatile SUPC_CALLBACK_OBJ ${SUPC_INSTANCE_NAME?lower_case}CallbackObject;
</#if>

void ${SUPC_INSTANCE_NAME}_Initialize( void )
{
<#if SUPC_BOD_VAL?has_content>
    uint32_t bodEnable = ${SUPC_INSTANCE_NAME}_REGS->SUPC_BODVDD & SUPC_BODVDD_ENABLE_Msk;

    /* Configure BODVDD. Mask the values loaded from NVM during reset. */
    ${SUPC_INSTANCE_NAME}_REGS->SUPC_BODVDD &= ~SUPC_BODVDD_ENABLE_Msk;
    ${SUPC_INSTANCE_NAME}_REGS->SUPC_BODVDD = (${SUPC_INSTANCE_NAME}_REGS->SUPC_BODVDD & (${SUPC_BOD_FACTORY_DATA_MASK})) | ${SUPC_BOD_VAL};
    if (bodEnable != 0U)
    {
        ${SUPC_INSTANCE_NAME}_REGS->SUPC_BODVDD |= SUPC_BODVDD_ENABLE_Msk;

        <#if SUPC_INTENSET_BODVDDRDY == false>
        /* If BODVDD in continuous mode then wait for BODVDD Ready */
        if((${SUPC_INSTANCE_NAME}_REGS->SUPC_BODVDD & SUPC_BODVDD_ACTCFG_Msk) == 0U)
        {
            while((${SUPC_INSTANCE_NAME}_REGS->SUPC_STATUS & SUPC_STATUS_BODVDDRDY_Msk) == 0U)
            {
            }
        }
        </#if>
    }

</#if>
<#if SUPC_VREG_VAL?has_content>
    /* Configure VREG */
    ${SUPC_INSTANCE_NAME}_REGS->SUPC_VREG = ${SUPC_VREG_VAL};

</#if>
<#if SUPC_MVIO_VAL?has_content>
    /* Configure MVIO */
    ${SUPC_INSTANCE_NAME}_REGS->SUPC_MVIO = ${SUPC_MVIO_VAL};

</#if>
<#if SUPC_EVCTRL_VAL?has_content>
    /* Configure Event output */
    ${SUPC_INSTANCE_NAME}_REGS->SUPC_EVCTRL = ${SUPC_EVCTRL_VAL};

</#if>
<#if SUPC_INT_VAL?has_content>
    /* Configure interrupt */
    ${SUPC_INSTANCE_NAME}_REGS->SUPC_INTENSET = ${SUPC_INT_VAL};
</#if>
}

void ${SUPC_INSTANCE_NAME}_MVIOVDDIO2ConfigSet(MVIO_VDDIO2CFG_CONFIG mvioVddio2Config)
{
    if ((${SUPC_INSTANCE_NAME}_REGS->SUPC_MVIO & SUPC_MVIO_MODE_Msk) == SUPC_MVIO_MODE_DUAL)
    {
        ${SUPC_INSTANCE_NAME}_REGS->SUPC_MVIO = (uint32_t)mvioVddio2Config;
    }
}

uint32_t ${SUPC_INSTANCE_NAME}_StatusGet(void)
{
    return (uint32_t)${SUPC_INSTANCE_NAME}_REGS->SUPC_STATUS;
}

<#if SUPC_INT_VAL?has_content>
void ${SUPC_INSTANCE_NAME}_CallbackRegister(SUPC_CALLBACK callback, uintptr_t context)
{
    ${SUPC_INSTANCE_NAME?lower_case}CallbackObject.callback = callback;
    ${SUPC_INSTANCE_NAME?lower_case}CallbackObject.context = context;
}

void __attribute__((used)) ${SUPC_INSTANCE_NAME}_InterruptHandler( void )
{
    uintptr_t context = ${SUPC_INSTANCE_NAME?lower_case}CallbackObject.context;
    uint32_t supc_status = ${SUPC_INSTANCE_NAME}_REGS->SUPC_INTFLAG;

    ${SUPC_INSTANCE_NAME}_REGS->SUPC_INTFLAG = SUPC_INTFLAG_Msk;

    if (${SUPC_INSTANCE_NAME?lower_case}CallbackObject.callback != NULL)
    {
        ${SUPC_INSTANCE_NAME?lower_case}CallbackObject.callback(supc_status, context);
    }
}
</#if>
