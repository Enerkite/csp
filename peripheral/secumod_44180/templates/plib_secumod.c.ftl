/*******************************************************************************
  SECUMOD PLIB

  Company:
    Microchip Technology Inc.

  File Name:
    plib_secumod.c

  Summary:
    This source file implements a driver for a hardware security module found in secure microcontrollers.
    The driver is responsible for configuring and managing the module?s security features, which include
    monitoring for abnormal temperature, voltage fluctuations, and physical intrusion attempts.
    At startup, the driver sets up the security module to detect critical conditions, such as high
    temperature, and ensures that the system is ready to respond to these events.
    It provides mechanisms to read the current status of the security system, including whether backup
    protection, scrambling, or automatic backup features are active. The driver also allows the application
    to enable or disable these features as needed, adapting the security posture to the system?s operational requirements.

  Remarks:
    None.
*******************************************************************************/

/*
Copyright (C) 2025, Microchip Technology Inc., and its subsidiaries. All rights reserved.

The software and documentation is provided by Microchip and its contributors "as is" and any express,
implied or statutory warranties, including, but not limited to, the implied warranties of merchantability,
fitness for a particular purpose and non-infringement of third party intellectual property rights are
disclaimed to the fullest extent permitted by law. In no event shall Microchip or its contributors be
liable for any direct, indirect, incidental, special,exemplary, or consequential damages (including,
but not limited to, procurement of substitute goods or services; loss of use, data, or profits;
or business interruption) however caused and on any theory of liability, whether in contract, strict liability,
or tort (including negligence or otherwise) arising in any way out of the use of the software and documentation,
even if advised of the possibility of such damage.

Except as expressly permitted hereunder and subject to the applicable license terms for any third-party software
incorporated in the software and any applicable open source software license terms, no license or other rights,
whether express or implied, are granted under any patent or other intellectual property rights of Microchip or any third party.
*/

#include <string.h>
#include "plib_secumod.h"

// Define bit masks for temperature monitoring
#define SECUMOD_TPM_LOW_MASK    (SECUMOD_SCR_TPML_Msk >> SECUMOD_SCR_TPML_Pos)
#define SECUMOD_TPM_HIGH_MASK   (SECUMOD_SCR_TPMH_Msk >> SECUMOD_SCR_TPMH_Pos)

// Callback object for SECUMOD
static volatile SECUMOD_CALLBACK_OBJECT SECUMOD_CallbackObj;

/**
 * @brief Initialize SECUMOD module.
 *        Enables high temperature alarm and its interrupt, and sets the threshold.
 */
void SECUMOD_Initialize(void)
{
<#if tpml_backup_enable == true || tpmh_backup_enable == true>
    // Enable alarms for backup mode
    uint32_t backup_alarm_ctrl = 0;
    <#if tpml_backup_enable == true>
    backup_alarm_ctrl |= SECUMOD_ALARM_TEMPERATURE_LOW;
    </#if>
    <#if tpmh_backup_enable == true>
    backup_alarm_ctrl |= SECUMOD_ALARM_TEMPERATURE_HIGH;
    </#if>
    SECUMOD_EnableBackupAlarm( backup_alarm_ctrl );

</#if>
<#if tpml_backup_enable_wakeup == true || tpmh_backup_enable_wakeup == true>
    // Handle wake-up sources for backup mode
    uint32_t backup_alarm_irq = 0;
    <#if tpml_backup_enable_wakeup == true>
    backup_alarm_irq |= SECUMOD_ALARM_TEMPERATURE_LOW;
    </#if>
    <#if tpmh_backup_enable_wakeup == true>
    backup_alarm_irq |= SECUMOD_ALARM_TEMPERATURE_HIGH;
    </#if>
    SECUMOD_EnableBackupWakeup( backup_alarm_irq, true );

</#if>
<#if tpml_normal_enable == true || tpmh_normal_enable == true>
    // Enable high temperature alarm in normal mode
    uint32_t normal_alarm_ctrl = 0;
    <#if tpml_normal_enable == true>
    normal_alarm_ctrl |= SECUMOD_ALARM_TEMPERATURE_LOW;
    </#if>
    <#if tpmh_normal_enable == true>
    normal_alarm_ctrl |= SECUMOD_ALARM_TEMPERATURE_HIGH;
    </#if>
    SECUMOD_EnableNormalAlarm( normal_alarm_ctrl );

</#if>
<#if tpml_normal_enable_interrupt == true || tpmh_normal_enable_interrupt == true>
    // Enable interrupt for high temperature alarm in normal mode
    uint32_t normal_alarm_irq = 0;
    <#if tpml_normal_enable_interrupt == true>
    normal_alarm_irq |= SECUMOD_ALARM_TEMPERATURE_LOW;
    </#if>
    <#if tpmh_normal_enable_interrupt == true>
    normal_alarm_irq |= SECUMOD_ALARM_TEMPERATURE_HIGH;
    </#if>
    SECUMOD_EnableNormalInterrupt( normal_alarm_irq, true );

</#if>
<#if tpmh_backup_enable == true || tpmh_normal_enable == true >
    // Set high temperature threshold to 120
    <#if tpmh_threshold_value == "105" >
    SECUMOD_SetHighTemperatureThreshold( SECUMOD_TPMH_105 );
    <#else>
    SECUMOD_SetHighTemperatureThreshold( SECUMOD_TPMH_120 );
    </#if>
</#if>
}


/**
 * @brief Get the current system status from SECUMOD.
 * @return secumod_sys_status_t Structure containing system status flags.
 */
void SECUMOD_GetSystemStatus(secumod_sys_status_t* status)
{
    // Read system status register
    uint32_t sysr = SECUMOD_REGS->SECUMOD_SYSR;

    // Extract and assign each status flag
    status->erase_status = ( sysr & SECUMOD_SYSR_ERASE_DONE_Msk & SECUMOD_SYSR_ERASE_ON_Msk ) >> SECUMOD_SYSR_ERASE_DONE_Pos;
    status->backup_is_active = ( sysr & SECUMOD_SYSR_BACKUP_Msk ) == SECUMOD_SYSR_BACKUP_1;
    status->SWKUP_is_sent = ( sysr & SECUMOD_SYSR_SWKUP_Msk ) == SECUMOD_SYSR_SWKUP_1;
    status->non_imprinting_enabled = ( sysr & SECUMOD_SYSR_NIMP_EN_Msk ) == SECUMOD_SYSR_NIMP_EN_1;
    status->auto_backup_enabled = ( sysr & SECUMOD_SYSR_AUTOBKP_Msk ) == SECUMOD_SYSR_AUTOBKP_1;
    status->scrambling_enabled = ( sysr & SECUMOD_SYSR_SCRAMB_Msk ) == SECUMOD_SYSR_SCRAMB_1;
    status->idle_in_non_imprinting = ( sysr & SECUMOD_SYSR_NIMP_IDLE_Msk ) == SECUMOD_SYSR_NIMP_IDLE_1;
}


/**
 * @brief Set system control options for SECUMOD.
 * @param control Structure containing control flags.
 */
void SECUMOD_SetSystemControl( const secumod_sys_ctrl_t control )
{
    uint32_t sys_ctrl = 0;

    // Set control bits according to structure fields
    sys_ctrl |= SECUMOD_CR_BACKUP( control.activate_backup ? 1:0 );
    sys_ctrl |= SECUMOD_CR_NORMAL( control.activate_normal ? 1:0 );
    sys_ctrl |= SECUMOD_CR_SWPROT( control.activate_sw_protection ? 1:0 );
    sys_ctrl |= SECUMOD_CR_NIMP_EN( control.control_non_imprinting );
    sys_ctrl |= SECUMOD_CR_AUTOBKP( control.control_automatic_backup );
    sys_ctrl |= SECUMOD_CR_SCRAMB( control.activate_scrambling ? 1:0 );

    // Write to system control register
    SECUMOD_REGS->SECUMOD_CR = sys_ctrl;
}


/**
 * @brief Get the current alarm status from SECUMOD.
 * @return secumod_alarm_status_t Structure containing alarm status flags.
 */
void SECUMOD_GetAlarmStatus(secumod_alarm_status_t* status)
{
    uint32_t secumod_status = SECUMOD_REGS->SECUMOD_SR;

    // Extract and assign each alarm status flag
    status->DWDT_SW = ( secumod_status & SECUMOD_SR_DWDT_SW_Msk ) ? true : false;
    status->DOUBLE_FREQUENCY = ( secumod_status & SECUMOD_SR_DBLFM_Msk ) ? true : false;
    status->TEST_PIN = ( secumod_status & SECUMOD_SR_TST_Msk ) ? true : false;
    status->JTAG_PIN = ( secumod_status & SECUMOD_SR_JTAG_Msk ) ? true : false;
    status->VDDANA_REGULATOR = ( secumod_status & SECUMOD_SR_REGANA_Msk ) ? true : false;
    status->TEMPERATURE_LOW = ( secumod_status & SECUMOD_SR_TPML_Msk ) ? true : false;
    status->TEMPERATURE_HIGH = ( secumod_status & SECUMOD_SR_TPMH_Msk ) ? true : false;
    status->VBAT_LOW = ( secumod_status & SECUMOD_SR_VBATL_Msk ) ? true : false;
    status->VBAT_HIGH = ( secumod_status & SECUMOD_SR_VBATH_Msk ) ? true : false;
    status->VDDCORE_LOW = ( secumod_status & SECUMOD_SR_VDDCOREL_Msk ) ? true : false;
    status->VDDCPU_LOW = ( secumod_status & SECUMOD_SR_VDDCPUL_Msk ) ? true : false;
    status->VDDCORE_HIGH = ( secumod_status & SECUMOD_SR_VDDCOREH_Msk ) ? true : false;
    status->VDDCPU_HIGH = ( secumod_status & SECUMOD_SR_VDDCPUH_Msk ) ? true : false;
    status->INTRUSION_DETECT_0 = ( secumod_status & SECUMOD_SR_DET0_Msk ) ? true : false;
    status->INTRUSION_DETECT_1 = ( secumod_status & SECUMOD_SR_DET1_Msk ) ? true : false;
    status->INTRUSION_DETECT_2 = ( secumod_status & SECUMOD_SR_DET2_Msk ) ? true : false;
    status->INTRUSION_DETECT_3 = ( secumod_status & SECUMOD_SR_DET3_Msk ) ? true : false;
}


/**
 * @brief Enable backup alarms as specified in the list.
 * @param backup_alarm_list Bitmask of alarms to enable.
 */
void SECUMOD_EnableBackupAlarm( const SECUMOD_BACKUP_ALARM_LIST backup_alarm_list )
{
    if ( backup_alarm_list & SECUMOD_BACKUP_STATUS_MASK )
    {
        // Show backup and normal protection registers
        SECUMOD_REGS->SECUMOD_CR = SECUMOD_CR_KEY_SHOW;

        // Enable each alarm in the list
        SECUMOD_REGS->SECUMOD_BMPR |= backup_alarm_list;

        // Hide backup and normal protection registers
        SECUMOD_REGS->SECUMOD_CR = SECUMOD_CR_KEY_HIDE;
    }
}


/**
 * @brief Disable backup alarms as specified in the list.
 * @param backup_alarm_list Bitmask of alarms to disable.
 */
void SECUMOD_DisableBackupAlarm( const SECUMOD_BACKUP_ALARM_LIST backup_alarm_list )
{
    if ( backup_alarm_list & SECUMOD_BACKUP_STATUS_MASK )
    {
        // Show backup and normal protection registers
        SECUMOD_REGS->SECUMOD_CR = SECUMOD_CR_KEY_SHOW;

        // Disable each alarm in the list
        SECUMOD_REGS->SECUMOD_BMPR &= ~backup_alarm_list;

        // Hide backup and normal protection registers
        SECUMOD_REGS->SECUMOD_CR = SECUMOD_CR_KEY_HIDE;
    }
}


/**
 * @brief Enable backup wakeup sources and clear pending alarms if specified.
 * @param backup_alarm_list Bitmask of alarms to enable as wakeup sources.
 * @param clear_pending_flag_mask Bitmask of alarms to clear.
 */
void SECUMOD_EnableBackupWakeup( const SECUMOD_BACKUP_ALARM_LIST backup_alarm_list,
                                 SECUMOD_ALARM_MASK clear_pending_flag_mask )
{
    if ( backup_alarm_list & SECUMOD_BACKUP_STATUS_MASK )
    {
        // Clear any pending alarm on temperature
        SECUMOD_ClearAlarmEvent( clear_pending_flag_mask );

        // Enable wakeup on specified events
        SECUMOD_REGS->SECUMOD_WKPR |= backup_alarm_list;
    }
}


/**
 * @brief Disable backup wakeup sources as specified.
 * @param backup_alarm_list Bitmask of alarms to disable as wakeup sources.
 */
void SECUMOD_DisableBackupWakeup( const SECUMOD_BACKUP_ALARM_LIST backup_alarm_list )
{
    if ( backup_alarm_list & SECUMOD_BACKUP_STATUS_MASK )
    {
        SECUMOD_REGS->SECUMOD_WKPR &= ~backup_alarm_list;
    }
}


/**
 * @brief Enable normal alarms as specified in the list.
 * @param normal_alarm_list Bitmask of alarms to enable.
 */
void SECUMOD_EnableNormalAlarm( const SECUMOD_NORMAL_ALARM_LIST normal_alarm_list )
{
    if ( normal_alarm_list & SECUMOD_NORMAL_STATUS_MASK )
    {
        // Show backup and normal protection registers
        SECUMOD_REGS->SECUMOD_CR = SECUMOD_CR_KEY_SHOW;

        // Enable each alarm in the list
        SECUMOD_REGS->SECUMOD_NMPR |= normal_alarm_list;

        // Hide backup and normal protection registers
        SECUMOD_REGS->SECUMOD_CR = SECUMOD_CR_KEY_HIDE;
    }
}


/**
 * @brief Disable normal alarms as specified in the list.
 * @param normal_alarm_list Bitmask of alarms to disable.
 */
void SECUMOD_DisableNormalAlarm( const SECUMOD_NORMAL_ALARM_LIST normal_alarm_list )
{
    if ( normal_alarm_list & SECUMOD_NORMAL_STATUS_MASK )
    {
        // Show backup and normal protection registers
        SECUMOD_REGS->SECUMOD_CR = SECUMOD_CR_KEY_SHOW;

        // Disable each alarm in the list
        SECUMOD_REGS->SECUMOD_NMPR &= ~normal_alarm_list;

        // Hide backup and normal protection registers
        SECUMOD_REGS->SECUMOD_CR = SECUMOD_CR_KEY_HIDE;
    }
}


/**
 * @brief Enable normal interrupts for specified alarms and clear pending flags if specified.
 * @param normal_alarm_list Bitmask of alarms to enable interrupts for.
 * @param clear_pending_flag_mask Bitmask of alarms to clear.
 */
void SECUMOD_EnableNormalInterrupt( const uint32_t normal_alarm_list, SECUMOD_ALARM_MASK clear_pending_flag_mask )
{
    if ( normal_alarm_list & SECUMOD_NORMAL_STATUS_MASK )
    {
        // Clear any pending alarm event
        SECUMOD_ClearAlarmEvent( clear_pending_flag_mask );

        // Enable interrupt for specified alarms
        SECUMOD_REGS->SECUMOD_NIEPR = normal_alarm_list & SECUMOD_NIEPR_Msk;
    }
}


/**
 * @brief Disable normal interrupts for specified alarms.
 * @param normal_element_list Bitmask of alarms to disable interrupts for.
 */
void SECUMOD_DisableNormalInterrupt( const uint32_t normal_element_list )
{
    SECUMOD_REGS->SECUMOD_NIDPR = normal_element_list & SECUMOD_NIDPR_Msk;
}


/**
 * @brief Set the high temperature threshold for SECUMOD.
 * @param threshold Threshold value to set.
 */
void SECUMOD_SetHighTemperatureThreshold( const secumod_tpmh_thesh_t threshold )
{
    // Clear threshold bits
    SECUMOD_REGS->SECUMOD_GPSBR &= ~SECUMOD_GPSBR_TSRANGE_Msk;
    // Set threshold bits according to input
    SECUMOD_REGS->SECUMOD_GPSBR |= threshold ? SECUMOD_GPSBR_TSRANGE_0 : SECUMOD_GPSBR_TSRANGE_1;
}


/**
 * @brief Clear alarm event flags as specified by the mask.
 * @param clear_status_mask Bitmask of alarms to clear.
 */
void SECUMOD_ClearAlarmEvent( SECUMOD_ALARM_STATUS clear_status_mask )
{
    SECUMOD_ALARM_STATUS alarm_status = SECUMOD_REGS->SECUMOD_SR;
    SECUMOD_REGS->SECUMOD_SCR = alarm_status & clear_status_mask;
}


/**
 * @brief Register a callback for SECUMOD events.
 * @param callback Function pointer to callback.
 * @param context User context to pass to callback.
 * @param auto_clear_status_mask Bitmask of alarms to auto-clear.
 */
void SECUMOD_CallbackRegister( SECUMOD_CALLBACK callback, uintptr_t context, SECUMOD_ALARM_STATUS auto_clear_status_mask )
{
    SECUMOD_CallbackObj.callback_fn = callback;
    SECUMOD_CallbackObj.context = context;
    SECUMOD_CallbackObj.auto_clear_status_mask = auto_clear_status_mask;
}


/**
 * @brief SECUMOD interrupt handler.
 *        Calls registered callback and clears alarm flags if needed.
 */
void __attribute__((used)) SECUMOD_Handler(void)
{
    SECUMOD_ALARM_STATUS secumod_status = SECUMOD_REGS->SECUMOD_SR;
    SECUMOD_SYS_STATUS secumod_system_status = SECUMOD_REGS->SECUMOD_SYSR;

    // Temporary variable to prevent MISRA violations (Rule 13.x)
    uintptr_t context = SECUMOD_CallbackObj.context;

    // Call registered callback function if set and if any alarm or system status is active
    if ( ( SECUMOD_CallbackObj.callback_fn != NULL ) && (
        ( SECUMOD_ALARM_STATUS_NONE != secumod_status ) || ( SECUMOD_ALARM_STATUS_NONE != secumod_system_status ) ) )
    {
        // Clear alarm flags if requested
        SECUMOD_ClearAlarmEvent( SECUMOD_CallbackObj.auto_clear_status_mask );
        // Execute callback
        SECUMOD_CallbackObj.callback_fn( secumod_system_status, secumod_status, context );
    }
}
<#if secumod_unittest == true>

/**
 * @brief Unit test for temperature monitoring protection.
 *        Sets threshold, enables alarms and interrupts for temperature.
 * @return EXIT_SUCCESS on success.
 */
uint32_t SECUMOD_UNITTEST_temperature_monitoring_protection(void)
{
    bool auto_clear_alarm_flag = true;

    SECUMOD_SetHighTemperatureThreshold( SECUMOD_TPMH_105 );

    SECUMOD_EnableBackupAlarm( SECUMOD_ALARM_TEMPERATURE_HIGH );
    SECUMOD_EnableBackupWakeup( SECUMOD_ALARM_TEMPERATURE_HIGH, auto_clear_alarm_flag );

    SECUMOD_EnableNormalAlarm( SECUMOD_ALARM_TEMPERATURE_HIGH );
    SECUMOD_EnableNormalInterrupt( SECUMOD_ALARM_TEMPERATURE_HIGH, auto_clear_alarm_flag );

    return EXIT_SUCCESS;
}
</#if>

