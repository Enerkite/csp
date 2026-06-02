/*******************************************************************************
  SECUMOD PLIB

  Company:
    Microchip Technology Inc.

  File Name:
    plib_secumod.h

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

#ifndef _SECUMOD_44180_H    /* Guard against multiple inclusion */
#define _SECUMOD_44180_H

/* ************************************************************************** */
/* Section: Included Files                                                    */
/* ************************************************************************** */

#include <stddef.h>
#include <stdlib.h>
#include <stdbool.h>

#include "definitions.h"
#include "device.h"

/* Provide C++ Compatibility */
#ifdef __cplusplus
extern "C" {
#endif

/* ************************************************************************** */
/* Section: Constants                                                         */
/* ************************************************************************** */

/* 
 * Control register keys for showing/hiding secure module features.
 * These are typically used to unlock or lock access to protected registers.
 */
#define SECUMOD_CR_KEY_SHOW     (0x89CA0000UL)
#define SECUMOD_CR_KEY_HIDE     (0x76350000UL)

#define SECUMOD_BACKUP_STATUS_MASK      ( SECUMOD_SR_DBLFM_Msk |   \
                                          SECUMOD_SR_TST_Msk |     \
                                          SECUMOD_SR_TPML_Msk |    \
                                          SECUMOD_SR_TPMH_Msk |    \
                                          SECUMOD_SR_VBATL_Msk |   \
                                          SECUMOD_SR_VBATH_Msk |   \
                                          SECUMOD_SR_DET0_Msk |    \
                                          SECUMOD_SR_DET1_Msk |    \
                                          SECUMOD_SR_DET2_Msk |    \
                                          SECUMOD_SR_DET3_Msk )

#define SECUMOD_NORMAL_STATUS_MASK      ( SECUMOD_BACKUP_STATUS_MASK |  \
                                          SECUMOD_SR_DWDT_SW_Msk |      \
                                          SECUMOD_SR_JTAG_Msk |         \
                                          SECUMOD_SR_REGANA_Msk |       \
                                          SECUMOD_SR_VDDCOREL_Msk |     \
                                          SECUMOD_SR_VDDCPUL_Msk |      \
                                          SECUMOD_SR_VDDCOREH_Msk |     \
                                          SECUMOD_SR_VDDCPUH_Msk )

#define SECUMOD_ALARM_STATUS_NONE       (0UL)
#define SECUMOD_ALARM_STATUS_ALL        SECUMOD_NORMAL_STATUS_MASK

/* ************************************************************************** */
/* Section: Data Types                                                        */
/* ************************************************************************** */

typedef uint32_t SECUMOD_SYS_STATUS;
typedef uint32_t SECUMOD_ALARM_STATUS;
typedef uint32_t SECUMOD_ALARM_MASK;

typedef uint32_t SECUMOD_BACKUP_ALARM_LIST;     // list of secumod_alarm_list_t separated by "|"
typedef uint32_t SECUMOD_NORMAL_ALARM_LIST;     // list of secumod_alarm_list_t separated by "|"

typedef void (*SECUMOD_CALLBACK) ( SECUMOD_SYS_STATUS system_status, SECUMOD_ALARM_STATUS status, uintptr_t context );

typedef struct 
{
    SECUMOD_CALLBACK callback_fn;
    uintptr_t context;
    SECUMOD_ALARM_STATUS auto_clear_status_mask;
} SECUMOD_CALLBACK_OBJECT;

typedef enum 
{
    SECUMOD_ALARM_DWDT_SW            = SECUMOD_SR_DWDT_SW_Msk,
    SECUMOD_ALARM_DOUBLE_FREQUENCY   = SECUMOD_SR_DBLFM_Msk,
    SECUMOD_ALARM_TEST_PIN           = SECUMOD_SR_TST_Msk,
    SECUMOD_ALARM_JTAG_PIN           = SECUMOD_SR_JTAG_Msk,
    SECUMOD_ALARM_VDDANA_REGULATOR   = SECUMOD_SR_REGANA_Msk,
    SECUMOD_ALARM_TEMPERATURE_LOW    = SECUMOD_SR_TPML_Msk,
    SECUMOD_ALARM_TEMPERATURE_HIGH   = SECUMOD_SR_TPMH_Msk,
    SECUMOD_ALARM_VBAT_LOW           = SECUMOD_SR_VBATL_Msk,
    SECUMOD_ALARM_VBAT_HIGH          = SECUMOD_SR_VBATH_Msk,
    SECUMOD_ALARM_VDDCORE_LOW        = SECUMOD_SR_VDDCOREL_Msk,
    SECUMOD_ALARM_VDDCPU_LOW         = SECUMOD_SR_VDDCPUL_Msk,
    SECUMOD_ALARM_VDDCORE_HIGH       = SECUMOD_SR_VDDCOREH_Msk,
    SECUMOD_ALARM_VDDCPU_HIGH        = SECUMOD_SR_VDDCPUH_Msk,
    SECUMOD_ALARM_INTRUSION_DETECT_0 = SECUMOD_SR_DET0_Msk,
    SECUMOD_ALARM_INTRUSION_DETECT_1 = SECUMOD_SR_DET1_Msk,
    SECUMOD_ALARM_INTRUSION_DETECT_2 = SECUMOD_SR_DET2_Msk,
    SECUMOD_ALARM_INTRUSION_DETECT_3 = SECUMOD_SR_DET3_Msk
} secumod_alarm_list_t;

typedef enum 
{
    SECUMOD_TPMH_105,
    SECUMOD_TPMH_120
} secumod_tpmh_thesh_t;

typedef enum 
{
    SECUMOD_ERASE_NONE             = 0,
    SECUMOD_ERASE_DONE             = 1,
    SECUMOD_ERASE_RUNNING          = 2,
    SECUMOD_ERASE_DONE_AND_RUNNING = 3
} secumod_erase_status_t;

typedef enum 
{
    SECUMOD_NIMP_ENABLE          = 1,
    SECUMOD_NIMP_DISABLE         = 2,
    SECUMOD_NIMP_ENABLE_ON_IDLE  = 3
} secumod_nimp_ctrl_t;

typedef enum 
{
    SECUMOD_AUTOBKP_AUTO_SWITCH = 1,
    SECUMOD_AUTOBKP_SW_SWITCH   = 2
} secumod_autobkp_ctrl_t;

typedef struct 
{
    secumod_erase_status_t erase_status;
    bool backup_is_active;      // normal otherwise
    bool SWKUP_is_sent;
    bool non_imprinting_enabled;
    bool auto_backup_enabled;
    bool scrambling_enabled;
    bool idle_in_non_imprinting;
} secumod_sys_status_t;

typedef struct 
{
    bool activate_backup;
    bool activate_normal;
    bool activate_sw_protection;
    secumod_nimp_ctrl_t control_non_imprinting;
    secumod_autobkp_ctrl_t control_automatic_backup;
    bool activate_scrambling;
} secumod_sys_ctrl_t;

typedef struct 
{
    bool DWDT_SW;
    bool DOUBLE_FREQUENCY;
    bool TEST_PIN;
    bool JTAG_PIN;
    bool VDDANA_REGULATOR;
    bool TEMPERATURE_LOW;
    bool TEMPERATURE_HIGH;
    bool VBAT_LOW;
    bool VBAT_HIGH;
    bool VDDCORE_LOW;
    bool VDDCPU_LOW;
    bool VDDCORE_HIGH;
    bool VDDCPU_HIGH;
    bool INTRUSION_DETECT_0;
    bool INTRUSION_DETECT_1;
    bool INTRUSION_DETECT_2;
    bool INTRUSION_DETECT_3;
} secumod_alarm_status_t;

/* ************************************************************************** */
/* Section: Interface Functions                                               */
/* ************************************************************************** */

void SECUMOD_Initialize(void);

void SECUMOD_CallbackRegister(SECUMOD_CALLBACK callback, uintptr_t context, SECUMOD_ALARM_STATUS auto_clear_status_mask);

void SECUMOD_GetSystemStatus(secumod_sys_status_t* status);
void SECUMOD_SetSystemControl(const secumod_sys_ctrl_t control);

void SECUMOD_GetAlarmStatus(secumod_alarm_status_t* status);

void SECUMOD_ClearAlarmEvent(SECUMOD_ALARM_MASK clear_alarm_mask);

void SECUMOD_EnableBackupAlarm(const SECUMOD_BACKUP_ALARM_LIST backup_alarm_list);
void SECUMOD_DisableBackupAlarm(const SECUMOD_BACKUP_ALARM_LIST backup_alarm_list);

void SECUMOD_EnableBackupWakeup(const SECUMOD_BACKUP_ALARM_LIST backup_element_list,
                                SECUMOD_ALARM_MASK clear_pending_flag_mask);
void SECUMOD_DisableBackupWakeup(const SECUMOD_BACKUP_ALARM_LIST backup_element_list);

void SECUMOD_EnableNormalAlarm(const SECUMOD_NORMAL_ALARM_LIST normal_alarm_list);
void SECUMOD_DisableNormalAlarm(const SECUMOD_NORMAL_ALARM_LIST normal_alarm_list);

void SECUMOD_EnableNormalInterrupt(const SECUMOD_NORMAL_ALARM_LIST normal_alarm_list, SECUMOD_ALARM_MASK clear_pending_flag_mask);
void SECUMOD_DisableNormalInterrupt(const SECUMOD_NORMAL_ALARM_LIST normal_alarm_list);

void SECUMOD_SetHighTemperatureThreshold(const secumod_tpmh_thesh_t value);
<#if secumod_unittest == true>

uint32_t SECUMOD_UNITTEST_temperature_monitoring_protection(void);
</#if>

/* Provide C++ Compatibility */
#ifdef __cplusplus
}
#endif

#endif /* _SECUMOD_44180_H */

