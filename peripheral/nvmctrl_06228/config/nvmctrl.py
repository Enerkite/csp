# coding: utf-8
"""*****************************************************************************
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
*****************************************************************************"""

global InterruptVector
global InterruptHandler
global InterruptHandlerLock
global nvmctrlInstanceName
global nvmctrlSym_Interrupt

###################################################################################################
########################################## Callbacks  #############################################
###################################################################################################


def updateNVMCTRLInterruptStatus(symbol, event):

    Database.setSymbolValue("core", InterruptVector, event["value"])
    Database.setSymbolValue("core", InterruptHandlerLock, event["value"])

    if event["value"] == True:
        Database.setSymbolValue("core", InterruptHandler, nvmctrlInstanceName.getValue() + "_InterruptHandler")
    else:
        Database.clearSymbolValue("core", InterruptHandler)


def updateNVMCTRLInterruptWarringStatus(symbol, event):

    if event["source"].getSymbolValue("INTERRUPT_ENABLE") == True:
        symbol.setVisible(event["value"])


def nvmctlrSetMemoryDependency(symbol, event):
    symbol.setVisible(event["value"])


def updateVisibility (symbol, event):
    symbol.setVisible(event["value"])

###################################################################################################
########################################## Component  #############################################
###################################################################################################


def instantiateComponent(nvmctrlComponent):

    global InterruptVector
    global InterruptHandler
    global InterruptHandlerLock
    global nvmctrlInstanceName
    global nvmctrlSym_Interrupt

    nvmctrlInstanceName = nvmctrlComponent.createStringSymbol("NVMCTRL_INSTANCE_NAME", None)
    nvmctrlInstanceName.setVisible(False)
    nvmctrlInstanceName.setDefaultValue(nvmctrlComponent.getID().upper())
    Log.writeInfoMessage("Running " + nvmctrlInstanceName.getValue())

    # Flash Address
    nvmctrlFlashNode = ATDF.getNode("/avr-tools-device-file/devices/device/address-spaces/address-space/memory-segment@[name=\"FLASH\"]")
    if nvmctrlFlashNode != None:
        nvmctrlSym_FLASH_ADDRESS = nvmctrlComponent.createStringSymbol("FLASH_START_ADDRESS", None)
        nvmctrlSym_FLASH_ADDRESS.setVisible(False)
        nvmctrlSym_FLASH_ADDRESS.setDefaultValue(nvmctrlFlashNode.getAttribute("start"))

        # Flash size
        nvmctrlSym_FLASH_SIZE = nvmctrlComponent.createStringSymbol("FLASH_SIZE", None)
        nvmctrlSym_FLASH_SIZE.setVisible(False)
        nvmctrlSym_FLASH_SIZE.setDefaultValue(nvmctrlFlashNode.getAttribute("size"))

        # Flash Page size
        nvmctrlSym_FLASH_PROGRAM_SIZE = nvmctrlComponent.createStringSymbol("FLASH_PROGRAM_SIZE", None)
        nvmctrlSym_FLASH_PROGRAM_SIZE.setVisible(False)
        nvmctrlSym_FLASH_PROGRAM_SIZE.setDefaultValue(nvmctrlFlashNode.getAttribute("pagesize"))

        # Flash Row size
        nvmctrlSym_ERASE_SIZE = nvmctrlComponent.createStringSymbol("FLASH_ERASE_SIZE", None)
        nvmctrlSym_ERASE_SIZE.setVisible(False)
        nvmctrlSym_ERASE_SIZE.setDefaultValue(str(int(nvmctrlSym_FLASH_PROGRAM_SIZE.getValue(), 0) * 4))

    # Data Flash Address
    nvmctrlDATAFLASHNode = ATDF.getNode("/avr-tools-device-file/devices/device/address-spaces/address-space/memory-segment@[name=\"DATAFLASH\"]")
    if nvmctrlDATAFLASHNode != None:
        nvmctrlSym_DATAFLASH_START_ADDRESS = nvmctrlComponent.createStringSymbol("FLASH_DATAFLASH_START_ADDRESS", None)
        nvmctrlSym_DATAFLASH_START_ADDRESS.setVisible(False)
        nvmctrlSym_DATAFLASH_START_ADDRESS.setDefaultValue(nvmctrlDATAFLASHNode.getAttribute("start"))

        # DATAFLASH size
        nvmctrlSym_DATAFLASH_SIZE = nvmctrlComponent.createStringSymbol("FLASH_DATAFLASH_SIZE", None)
        nvmctrlSym_DATAFLASH_SIZE.setVisible(False)
        nvmctrlSym_DATAFLASH_SIZE.setDefaultValue(nvmctrlDATAFLASHNode.getAttribute("size"))

        # DATAFLASH Page size
        nvmctrlSym_DATAFLASH_PROGRAM_SIZE = nvmctrlComponent.createStringSymbol("FLASH_DATAFLASH_PROGRAM_SIZE", None)
        nvmctrlSym_DATAFLASH_PROGRAM_SIZE.setVisible(False)
        nvmctrlSym_DATAFLASH_PROGRAM_SIZE.setDefaultValue(nvmctrlDATAFLASHNode.getAttribute("pagesize"))

        # DATAFLASH Row size
        nvmctrlSym_DATAFLASH_ERASE_SIZE = nvmctrlComponent.createStringSymbol("FLASH_DATAFLASH_ERASE_SIZE", None)
        nvmctrlSym_DATAFLASH_ERASE_SIZE.setVisible(False)
        nvmctrlSym_DATAFLASH_ERASE_SIZE.setDefaultValue(str(int(nvmctrlSym_DATAFLASH_PROGRAM_SIZE.getValue(), 0) * 4))

    # NVM USER row Address
    nvmctrlUSERPAGENode = ATDF.getNode("/avr-tools-device-file/devices/device/address-spaces/address-space/memory-segment@[name=\"USER_PAGE\"]")
    if nvmctrlUSERPAGENode != None:
        nvmctrlSym_USERROW_START_ADDRESS = nvmctrlComponent.createStringSymbol("FLASH_USERROW_START_ADDRESS", None)
        nvmctrlSym_USERROW_START_ADDRESS.setVisible(False)
        nvmctrlSym_USERROW_START_ADDRESS.setDefaultValue(nvmctrlUSERPAGENode.getAttribute("start"))

        # NVM user row size
        nvmctrlSym_USERROW_SIZE = nvmctrlComponent.createStringSymbol("FLASH_USERROW_SIZE", None)
        nvmctrlSym_USERROW_SIZE.setVisible(False)
        nvmctrlSym_USERROW_SIZE.setDefaultValue(nvmctrlUSERPAGENode.getAttribute("size"))

        # NVM user row Page size
        nvmctrlSym_USERROW_PROGRAM_SIZE = nvmctrlComponent.createStringSymbol("FLASH_USERROW_PROGRAM_SIZE", None)
        nvmctrlSym_USERROW_PROGRAM_SIZE.setVisible(False)
        nvmctrlSym_USERROW_PROGRAM_SIZE.setDefaultValue(nvmctrlUSERPAGENode.getAttribute("pagesize"))

    ##### Do not modify below symbol names as they are used by Memory Driver #####

    # Configures the library for interrupt mode operations
    nvmctrlSym_Interrupt = nvmctrlComponent.createBooleanSymbol("INTERRUPT_ENABLE", None)
    nvmctrlSym_Interrupt.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:nvmctrl_06228;register:INTENSET")
    nvmctrlSym_Interrupt.setLabel("Enable Interrupt?")
    nvmctrlSym_Interrupt.setDefaultValue(False)

    # Configuration when interfaced with memory driver
    nvmctrlSym_MemoryDriver = nvmctrlComponent.createBooleanSymbol("DRV_MEMORY_CONNECTED", None)
    nvmctrlSym_MemoryDriver.setLabel("Memory Driver Connected")
    nvmctrlSym_MemoryDriver.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:nvmctrl_06228;register:%NOREGISTER%")
    nvmctrlSym_MemoryDriver.setVisible(False)
    nvmctrlSym_MemoryDriver.setDefaultValue(False)

    offsetStart = (int(nvmctrlSym_FLASH_SIZE.getValue(), 16) / 2)

    nvmOffset = str(hex(int(nvmctrlSym_FLASH_ADDRESS.getValue(), 16) + offsetStart))

    nvmctrlSym_MemoryStartAddr = nvmctrlComponent.createStringSymbol("START_ADDRESS", None)
    nvmctrlSym_MemoryStartAddr.setLabel("NVM Media Start Address")
    nvmctrlSym_MemoryStartAddr.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:nvmctrl_06228;register:ADDR")
    nvmctrlSym_MemoryStartAddr.setVisible(False)
    nvmctrlSym_MemoryStartAddr.setDefaultValue(nvmOffset[2:])
    nvmctrlSym_MemoryStartAddr.setDependencies(nvmctlrSetMemoryDependency, ["DRV_MEMORY_CONNECTED"])

    memMediaSizeKB = (offsetStart / 1024)

    nvmctrlSym_MemoryMediaSize = nvmctrlComponent.createIntegerSymbol("MEMORY_MEDIA_SIZE", None)
    nvmctrlSym_MemoryMediaSize.setLabel("NVM Media Size (KB)")
    nvmctrlSym_MemoryMediaSize.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:nvmctrl_06228;register:%NOREGISTER%")
    nvmctrlSym_MemoryMediaSize.setVisible(False)
    nvmctrlSym_MemoryMediaSize.setDefaultValue(memMediaSizeKB)
    nvmctrlSym_MemoryMediaSize.setDependencies(nvmctlrSetMemoryDependency, ["DRV_MEMORY_CONNECTED"])

    nvmctrlSym_MemoryEraseEnable = nvmctrlComponent.createBooleanSymbol("ERASE_ENABLE", None)
    nvmctrlSym_MemoryEraseEnable.setLabel("NVM Erase Enable")
    nvmctrlSym_MemoryEraseEnable.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:nvmctrl_06228;register:CTRLB")
    nvmctrlSym_MemoryEraseEnable.setVisible(False)
    nvmctrlSym_MemoryEraseEnable.setDefaultValue(True)
    nvmctrlSym_MemoryEraseEnable.setReadOnly(True)

    nvmctrlSym_MemoryEraseBufferSize = nvmctrlComponent.createIntegerSymbol("ERASE_BUFFER_SIZE", None)
    nvmctrlSym_MemoryEraseBufferSize.setLabel("NVM Erase Buffer Size")
    nvmctrlSym_MemoryEraseBufferSize.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:nvmctrl_06228;register:%NOREGISTER%")
    nvmctrlSym_MemoryEraseBufferSize.setVisible(False)
    nvmctrlSym_MemoryEraseBufferSize.setDefaultValue(int(nvmctrlSym_ERASE_SIZE.getValue()))
    nvmctrlSym_MemoryEraseBufferSize.setDependencies(nvmctlrSetMemoryDependency, ["DRV_MEMORY_CONNECTED", "ERASE_ENABLE"])

    nvmctrlSym_MemoryEraseComment = nvmctrlComponent.createCommentSymbol("ERASE_COMMENT", None)
    nvmctrlSym_MemoryEraseComment.setVisible(False)
    nvmctrlSym_MemoryEraseComment.setLabel("*** Should be equal to Row Erase Size ***")
    nvmctrlSym_MemoryEraseComment.setDependencies(nvmctlrSetMemoryDependency, ["DRV_MEMORY_CONNECTED", "ERASE_ENABLE"])

    writeApiName = nvmctrlComponent.getID().upper() + "_FlashWrite"
    eraseApiName = nvmctrlComponent.getID().upper() + "_PageErase"
    userRowEraseApiName = nvmctrlComponent.getID().upper() + "_BOOTCFG_PageErase"
    userRowWriteApiName = nvmctrlComponent.getID().upper() + "_BOOTCFG_PageWrite"
    unlockApiName = nvmctrlComponent.getID().upper() + "_RegionUnlock"

    nvmctrlWriteApiName = nvmctrlComponent.createStringSymbol("WRITE_API_NAME", None)
    nvmctrlWriteApiName.setVisible(False)
    nvmctrlWriteApiName.setReadOnly(True)
    nvmctrlWriteApiName.setDefaultValue(writeApiName)

    nvmctrlEraseApiName = nvmctrlComponent.createStringSymbol("ERASE_API_NAME", None)
    nvmctrlEraseApiName.setVisible(False)
    nvmctrlEraseApiName.setReadOnly(True)
    nvmctrlEraseApiName.setDefaultValue(eraseApiName)
    
    nvmctrlUnlockApiName = nvmctrlComponent.createStringSymbol("UNLOCK_API_NAME", None)
    nvmctrlUnlockApiName.setVisible(False)
    nvmctrlUnlockApiName.setReadOnly(True)
    nvmctrlUnlockApiName.setDefaultValue(unlockApiName)

    nvmctrlUserRowEraseApiName = nvmctrlComponent.createStringSymbol("USER_PAGE_ERASE_API_NAME", None)
    nvmctrlUserRowEraseApiName.setVisible(False)
    nvmctrlUserRowEraseApiName.setReadOnly(True)
    nvmctrlUserRowEraseApiName.setDefaultValue(userRowEraseApiName)

    nvmctrlUserRowWriteApiName = nvmctrlComponent.createStringSymbol("USER_PAGE_WRITE_API_NAME", None)
    nvmctrlUserRowWriteApiName.setVisible(False)
    nvmctrlUserRowWriteApiName.setReadOnly(True)
    nvmctrlUserRowWriteApiName.setDefaultValue(userRowWriteApiName)

    ############################################################################
    #### Dependency ####
    ############################################################################

    InterruptVector = nvmctrlInstanceName.getValue()+"_INTERRUPT_ENABLE"
    InterruptHandler = nvmctrlInstanceName.getValue()+"_INTERRUPT_HANDLER"
    InterruptHandlerLock = nvmctrlInstanceName.getValue()+"_INTERRUPT_HANDLER_LOCK"
    InterruptVectorUpdate = nvmctrlInstanceName.getValue()+"_INTERRUPT_ENABLE_UPDATE"

    # Interrupt Dynamic settings
    nvmctrlSym_UpdateInterruptStatus = nvmctrlComponent.createBooleanSymbol("NVMCTRL_INTERRUPT_STATUS", None)
    nvmctrlSym_UpdateInterruptStatus.setDependencies(updateNVMCTRLInterruptStatus, ["INTERRUPT_ENABLE"])
    nvmctrlSym_UpdateInterruptStatus.setVisible(False)

    # Interrupt Warning status
    nvmctrlSym_IntEnComment = nvmctrlComponent.createCommentSymbol("NVMCTRL_INTERRUPT_ENABLE_COMMENT", None)
    nvmctrlSym_IntEnComment.setVisible(False)
    nvmctrlSym_IntEnComment.setLabel("Warning!!! NVMCTRL Interrupt is Disabled in Interrupt Manager")
    nvmctrlSym_IntEnComment.setDependencies(updateNVMCTRLInterruptWarringStatus, ["core." + InterruptVectorUpdate])

    isEccPresent = False
    eccPresentParam = ATDF.getNode("/avr-tools-device-file/devices/device/peripherals/module@[name=\"NVMCTRL\"]/instance@[name=\"NVMCTRL\"]/parameters/param@[name=\"ECC_PRESENT\"]")
    if eccPresentParam != None:
        isEccPresent = True if eccPresentParam.getAttribute("value") == "1" else False

    if isEccPresent == True:
        nvmctrlSym_ECCTestingEnable = nvmctrlComponent.createBooleanSymbol("NVMCTRL_ECC_TESTING_ENABLE", None)
        nvmctrlSym_ECCTestingEnable.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp: ;register:ECCCTRL")
        nvmctrlSym_ECCTestingEnable.setLabel("ECC Testing Enable")
        nvmctrlSym_ECCTestingEnable.setDefaultValue(False)

        nvmctrlSym_MainArrECCDisable = nvmctrlComponent.createBooleanSymbol("NVMCTRL_ECC_MAIN_ARR_DIS", nvmctrlSym_ECCTestingEnable)
        nvmctrlSym_MainArrECCDisable.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp: ;register:ECCCTRL")
        nvmctrlSym_MainArrECCDisable.setLabel("Main Array ECC Disable")
        nvmctrlSym_MainArrECCDisable.setDefaultValue(False)
        nvmctrlSym_MainArrECCDisable.setVisible(False)
        nvmctrlSym_MainArrECCDisable.setDependencies(updateVisibility, ["NVMCTRL_ECC_TESTING_ENABLE"])

        nvmctrlSym_DataFlashECCDisable = nvmctrlComponent.createBooleanSymbol("NVMCTRL_ECC_DATA_FLASH_DIS", nvmctrlSym_ECCTestingEnable)
        nvmctrlSym_DataFlashECCDisable.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp: ;register:ECCCTRL")
        nvmctrlSym_DataFlashECCDisable.setLabel("Data Flash ECC Disable")
        nvmctrlSym_DataFlashECCDisable.setDefaultValue(False)
        nvmctrlSym_DataFlashECCDisable.setVisible(False)
        nvmctrlSym_DataFlashECCDisable.setDependencies(updateVisibility, ["NVMCTRL_ECC_TESTING_ENABLE"])

        nvmctrlSym_InitECCCnt = nvmctrlComponent.createIntegerSymbol("NVMCTRL_ECC_ERR_INIT_COUNT", nvmctrlSym_ECCTestingEnable)
        nvmctrlSym_InitECCCnt.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp: ;register:ECCCTRL")
        nvmctrlSym_InitECCCnt.setLabel("ECC Error Counter Initial Value")
        nvmctrlSym_InitECCCnt.setMin(0)
        nvmctrlSym_InitECCCnt.setMax(255)
        nvmctrlSym_InitECCCnt.setDefaultValue(0)
        nvmctrlSym_InitECCCnt.setVisible(False)
        nvmctrlSym_InitECCCnt.setDependencies(updateVisibility, ["NVMCTRL_ECC_TESTING_ENABLE"])
###################################################################################################
####################################### Code Generation  ##########################################
###################################################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    nvmctrlModuleNode = ATDF.getNode("/avr-tools-device-file/modules/module@[name=\"NVMCTRL\"]")
    nvmctrlModuleID = nvmctrlModuleNode.getAttribute("id")

    nvmctrlSym_HeaderFile = nvmctrlComponent.createFileSymbol("NVMCTRL_HEADER", None)
    nvmctrlSym_HeaderFile.setSourcePath("../peripheral/nvmctrl_06228/templates/plib_nvmctrl.h.ftl")
    nvmctrlSym_HeaderFile.setOutputName("plib_"+nvmctrlInstanceName.getValue().lower()+".h")
    nvmctrlSym_HeaderFile.setDestPath("/peripheral/nvmctrl/")
    nvmctrlSym_HeaderFile.setProjectPath("config/" + configName + "/peripheral/nvmctrl/")
    nvmctrlSym_HeaderFile.setType("HEADER")
    nvmctrlSym_HeaderFile.setMarkup(True)

    nvmctrlSym_SourceFile = nvmctrlComponent.createFileSymbol("NVMCTRL_SOURCE", None)
    nvmctrlSym_SourceFile.setSourcePath("../peripheral/nvmctrl_06228/templates/plib_nvmctrl.c.ftl")
    nvmctrlSym_SourceFile.setOutputName("plib_"+nvmctrlInstanceName.getValue().lower()+".c")
    nvmctrlSym_SourceFile.setDestPath("/peripheral/nvmctrl/")
    nvmctrlSym_SourceFile.setProjectPath("config/" + configName + "/peripheral/nvmctrl/")
    nvmctrlSym_SourceFile.setType("SOURCE")
    nvmctrlSym_SourceFile.setMarkup(True)

  #  nvmctrlSym_SystemInitFile = nvmctrlComponent.createFileSymbol("NVMCTRL_SYS_INIT", None)
  #  nvmctrlSym_SystemInitFile.setSourcePath("../peripheral/nvmctrl_06228/templates/system/initialization.c.ftl")
  #  nvmctrlSym_SystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_PERIPHERALS")
  #  nvmctrlSym_SystemInitFile.setType("STRING")
  #  nvmctrlSym_SystemInitFile.setMarkup(True)

    nvmctrlSystemDefFile = nvmctrlComponent.createFileSymbol("NVMCTRL_SYS_DEF", None)
    nvmctrlSystemDefFile.setSourcePath("../peripheral/nvmctrl_06228/templates/system/definitions.h.ftl")
    nvmctrlSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    nvmctrlSystemDefFile.setType("STRING")
    nvmctrlSystemDefFile.setMarkup(True)
