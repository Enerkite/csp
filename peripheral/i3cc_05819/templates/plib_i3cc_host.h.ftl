/*******************************************************************************
  Improved Inter-Integrated Circuit (I3C) Host/Controller Library PLIB

  Company
    Microchip Technology Inc.

  File Name
    plib_${I3CC_INSTANCE_NAME?lower_case}_host.h

  Summary
    I3C host/controller peripheral library interface.

  Description
    This file defines the interface to the I3C host/controller peripheral library. This
    library provides access to and control of the associated peripheral
    instance.

  Remarks:
    None.
*******************************************************************************/

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

#ifndef PLIB_${I3CC_INSTANCE_NAME}_HOST_H
#define PLIB_${I3CC_INSTANCE_NAME}_HOST_H

#include "device.h"
#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include "plib_i3cc_host_common.h"

#ifdef __cplusplus  // Provide C++ Compatibility

    extern "C" {

#endif

bool ${I3CC_INSTANCE_NAME}_Host_IsBusy(void);
void ${I3CC_INSTANCE_NAME}_Host_Abort(void);
void ${I3CC_INSTANCE_NAME}_Host_Resume(void);
void ${I3CC_INSTANCE_NAME}_Host_StatusEnable(uint32_t pioIntrStatusMsk);
void ${I3CC_INSTANCE_NAME}_Host_StatusDisable(uint32_t pioIntrStatusMsk);
void ${I3CC_INSTANCE_NAME}_Host_SignalEnable(uint32_t pioIntrSignalMsk);
void ${I3CC_INSTANCE_NAME}_Host_SignalDisable(uint32_t pioIntrSignalMsk);
uint32_t ${I3CC_INSTANCE_NAME}_Host_StatusGet(uint32_t pioIntrStatusMsk);
uint8_t ${I3CC_INSTANCE_NAME}_Host_QueueLevelGet(I3CC_QUEUE_LVL qLvl);
void ${I3CC_INSTANCE_NAME}_Host_QueueThresholdSet(I3CC_QUEUE_THLD qThresholdType, uint8_t threshold);
uint8_t ${I3CC_INSTANCE_NAME}_Host_QueueThresholdGet(I3CC_QUEUE_THLD qThresholdType);
void ${I3CC_INSTANCE_NAME}_Host_QueueReset(I3CC_QUEUE_RESET qType);
void ${I3CC_INSTANCE_NAME}_Host_SoftReset(void);
void ${I3CC_INSTANCE_NAME}_Host_DATTableRead(void* pBuffer, uint8_t numDATEntries);
void ${I3CC_INSTANCE_NAME}_Host_DATTableInitialize(I3CC_DAT_TABLE_ENTRY_TYPE type);
void ${I3CC_INSTANCE_NAME}_Host_Initialize(void);
uint8_t ${I3CC_INSTANCE_NAME}_Host_DATTableIndexGet(uint8_t addr);
uint8_t ${I3CC_INSTANCE_NAME}_Host_DATFreeIndexGet(void);
bool ${I3CC_INSTANCE_NAME}_Host_DATEntrySet(uint8_t datIndex, I3CC_DAT_TABLE_SETUP* datTableSetup);
bool ${I3CC_INSTANCE_NAME}_Host_DATEntryGet(uint8_t datIndex, I3CC_DAT_TABLE_ENTRY* datTableEntry);
bool ${I3CC_INSTANCE_NAME}_Host_IBIConfigSet(uint8_t dynamic_addr, I3CC_IBI_SETUP* ibiSetup);
bool ${I3CC_INSTANCE_NAME}_Host_IBIConfigGet(uint8_t dynamic_addr, I3CC_IBI_SETUP* ibiSetup);
uint8_t ${I3CC_INSTANCE_NAME}_Host_DeviceAddrGet(uint8_t datIndex);
uint8_t ${I3CC_INSTANCE_NAME}_Host_NumTargetsGet(void);
bool ${I3CC_INSTANCE_NAME}_Host_IsIBICapable(uint8_t dynamic_addr);
bool ${I3CC_INSTANCE_NAME}_Host_IBIHasPayload(uint8_t dynamic_addr);
bool ${I3CC_INSTANCE_NAME}_Host_TargetHasMaxDataSpeedLimit(uint8_t dynamic_addr);
bool ${I3CC_INSTANCE_NAME}_Host_DCTInfoGet(uint8_t dynamic_addr, I3CC_DCT_TABLE_ENTRY* dctInfo);
uint8_t ${I3CC_INSTANCE_NAME}_Host_DCTInfoGetAll(I3CC_DCT_TABLE_ENTRY* dctInfo, uint8_t maxEntries);
void ${I3CC_INSTANCE_NAME}_Host_GlobalXferFlagsSet(I3CC_XFER_FLAGS* xferFlags);
I3CC_XFER_ID ${I3CC_INSTANCE_NAME}_Host_DeviceDiscovery(uint8_t nExpectedTargets);

I3CC_XFER_ID ${I3CC_INSTANCE_NAME}_Host_AddressAssignmentCmd(
    I3CC_CCC  addrAssignCmd,
    uint8_t devIndex,
    uint8_t devCount
);
I3CC_XFER_ID ${I3CC_INSTANCE_NAME}_Host_ImmediateDataXferCmd(
    uint8_t targetAddr,
    bool cp,
    I3CC_CCC cmd,
    void* pDataBuffer,
    uint8_t numTxBytes,
    I3CC_XFER_FLAGS* xferFlags
);
I3CC_XFER_ID ${I3CC_INSTANCE_NAME}_Host_RegularDataXferCmd(
    uint8_t targetAddr,
    bool cp,
    I3CC_CCC cmd,
    I3CC_XFER_DIR dir,
    void* pDataBuffer,
    uint16_t numRxTxBytes,
    I3CC_XFER_FLAGS* xferFlags
);
I3CC_XFER_ID ${I3CC_INSTANCE_NAME}_Host_ComboDataXferCmd(
    uint8_t targetAddr,
    I3CC_XFER_OFFSET_LEN offsetLen,
    uint16_t offsetVal,
    I3CC_XFER_DIR dir,
    void* pDataBuffer,
    uint16_t numRxTxBytes,
    I3CC_XFER_FLAGS* xferFlags
);
I3CC_XFER_ID ${I3CC_INSTANCE_NAME}_Host_BroadcastCCCXfer(
    I3CC_CCC cmd,
    I3CC_XFER_DIR dir,
    void* pDataBuffer,
    uint16_t numRxTxBytes,
    I3CC_XFER_FLAGS* xferFlags
);
I3CC_XFER_ID ${I3CC_INSTANCE_NAME}_Host_DirectCCCXfer(
    uint8_t targetAddr,
    I3CC_CCC cmd,
    I3CC_XFER_DIR dir,
    void* pDataBuffer,
    uint16_t numRxTxBytes,
    I3CC_XFER_FLAGS* xferFlags
);
I3CC_XFER_ID ${I3CC_INSTANCE_NAME}_Host_PrivateDataXfer(
    uint8_t targetAddr,
    I3CC_XFER_DIR dir,
    void* pDataBuffer,
    uint16_t numRxTxBytes,
    I3CC_XFER_FLAGS* xferFlags
);
I3CC_XFER_ID ${I3CC_INSTANCE_NAME}_Host_Write(
    uint8_t targetAddr,
    void* pWrDataBuffer,
    uint16_t numTxBytes,
    I3CC_CCC cmd,
    I3CC_XFER_FLAGS* xferFlags
);
I3CC_XFER_ID ${I3CC_INSTANCE_NAME}_Host_Read(
    uint8_t targetAddr,
    void* pRdDataBuffer,
    uint16_t numRxBytes,
    I3CC_CCC cmd,
    I3CC_XFER_FLAGS* xferFlags
);
I3CC_XFER_ID ${I3CC_INSTANCE_NAME}_Host_WriteRead(
    uint8_t targetAddr,
    I3CC_XFER_OFFSET_LEN offsetLen,
    uint16_t offsetVal,
    void* pRdDataBuffer,
    uint16_t numRxBytes,
    I3CC_XFER_FLAGS* xferFlags
);

void ${I3CC_INSTANCE_NAME}_Host_CallbackRegister(I3CC_CALLBACK callback_fn);

void ${I3CC_INSTANCE_NAME}_Host_PresentStateGet(I3CC_PRESENT_STATE* currState);

#ifdef __cplusplus
}
#endif

#endif //PLIB_${I3CC_INSTANCE_NAME}_HOST_H