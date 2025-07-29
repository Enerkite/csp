# coding: utf-8
"""*****************************************************************************
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
*****************************************************************************"""

###################################################################################################
########################################## Callbacks  #############################################
###################################################################################################
global PMfilesArray
PMfilesArray = []

def updatePMClockWarringStatus(symbol, event):

    symbol.setVisible(not event["value"])
    
def WriteProtect_InputsVisibility(symbol, event):
    if (event["value"] == True):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

###################################################################################################
########################################## Component  #############################################
###################################################################################################

def instantiateComponent(pmComponent):

    pmInstanceName = pmComponent.createStringSymbol("PM_INSTANCE_NAME", None)
    pmInstanceName.setVisible(False)
    pmInstanceName.setDefaultValue(pmComponent.getID().upper())

    #Clock enable
    Database.setSymbolValue("core", pmInstanceName.getValue() + "_CLOCK_ENABLE", True, 2)

    #Parse parameters to show device specific functions (but uses the same IP)
    parameters = [];
    parametersNode = ATDF.getNode("/avr-tools-device-file/devices/device/peripherals/module@[name=\"PM\"]/instance@[name=\""+pmInstanceName.getValue()+"\"]/parameters")

    #Get different modes for Idle Sleep
    pmIdleSleepOptions = ATDF.getNode("/avr-tools-device-file/modules/module@[name=\"PM\"]/value-group@[name=\"PM_SLEEPCFG__SLEEPMODE\"]")

    pmIdleSleepOptionValues = []
    pmIdleSleepOptionValues = pmIdleSleepOptions.getChildren()

    IdleModeCount = 0
    for id in range(0,len(pmIdleSleepOptionValues)):
        if "IDLE" in pmIdleSleepOptionValues[id].getAttribute("name"):
            IdleModeCount += 1

    if IdleModeCount > 1:
        #Idle configuration
        pmSym_PM_IDLE = pmComponent.createKeyValueSetSymbol("PM_IDLE_OPTION", None)
        pmSym_PM_IDLE.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:pm_pwr_pm_arm_v1;register:SLEEPCFG")
        pmSym_PM_IDLE.setLabel("Idle Mode Configuration")
        pmSym_PM_IDLE.setOutputMode("Value")
        pmSym_PM_IDLE.setDisplayMode("Description")

        for id in range(0,len(pmIdleSleepOptionValues)):
            pmSym_PM_IDLE_Key_Key = pmIdleSleepOptionValues[id].getAttribute("name")
            if "IDLE" in pmSym_PM_IDLE_Key_Key:
                pmSym_PM_IDLE_Key_Value = pmIdleSleepOptionValues[id].getAttribute("value")
                pmSym_PM_IDLE_Key_Description = pmIdleSleepOptionValues[id].getAttribute("caption")
                pmSym_PM_IDLE.addKey(pmSym_PM_IDLE_Key_Key, pmSym_PM_IDLE_Key_Value, pmSym_PM_IDLE_Key_Description)
        pmSym_PM_IDLE.setDefaultValue(0)

    # Clock Warning status
    pmSym_ClkEnComment = pmComponent.createCommentSymbol("PM_CLOCK_ENABLE_COMMENT", None)
    pmSym_ClkEnComment.setLabel("Warning!!! PM Peripheral Clock is Disabled in Clock Manager")
    pmSym_ClkEnComment.setVisible(False)
    pmSym_ClkEnComment.setDependencies(updatePMClockWarringStatus, ["core." + pmInstanceName.getValue() + "_CLOCK_ENABLE"])
    
    # Create WriteProtect Menu Branch
    wpctrl_Menu = pmComponent.createMenuSymbol("PM_WPCTRL_MENU", None)
    wpctrl_Menu.setLabel("Write Protect Configuration")
    
    # WriteProtect Enable
    wpctrl_Enabel = pmComponent.createBooleanSymbol("PM_WPCTRL__WPEN", wpctrl_Menu)
    wpctrl_Enabel.setLabel("Enable WriteProtect")
    wpctrl_Enabel.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:pm_pwr_pm_arm_v1;register:WPCTRL")
    wpctrl_Enabel.setDescription("Write protection blocks non-debugger access to PM registers")
    wpctrl_Enabel.setDefaultValue(False)
    wpctrl_Enabel.setVisible(True)

    # WriteProtect Lock
    wpctrl_Lock = pmComponent.createBooleanSymbol("PM_WPCTRL__WPLCK", wpctrl_Menu)
    wpctrl_Lock.setLabel("Enable WriteProtect LOCK")
    wpctrl_Lock.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:pm_pwr_pm_arm_v1;register:WPCTRL")
    wpctrl_Lock.setDescription("WPCTRL register is write-protected and can only be cleared by a system reset")
    wpctrl_Lock.setDefaultValue(False)
    wpctrl_Lock.setVisible(False)
    
    # Set dependency so visibility updates when wpctrl_Enabel changes
    wpctrl_Lock.setDependencies(WriteProtect_InputsVisibility, ["PM_WPCTRL__WPEN"])

    ###################################################################################################
    ####################################### Code Generation  ##########################################
    ###################################################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    pmModuleNode = ATDF.getNode("/avr-tools-device-file/modules/module@[name=\"PM\"]")
    pmModuleID = pmModuleNode.getAttribute("id")

    pmSym_HeaderFile = pmComponent.createFileSymbol("PM_HEADER", None)
    pmSym_HeaderFile.setSourcePath("../peripheral/pm_pwr_pm_arm_v1/templates/plib_pm.h.ftl")
    pmSym_HeaderFile.setOutputName("plib_" + pmInstanceName.getValue().lower() + ".h")
    pmSym_HeaderFile.setDestPath("/peripheral/pm/")
    pmSym_HeaderFile.setProjectPath("config/" + configName + "/peripheral/pm/")
    pmSym_HeaderFile.setType("HEADER")
    pmSym_HeaderFile.setMarkup(True)

    pmSym_SourceFile = pmComponent.createFileSymbol("PM_SOURCE", None)
    pmSym_SourceFile.setSourcePath("../peripheral/pm_pwr_pm_arm_v1/templates/plib_pm.c.ftl")
    pmSym_SourceFile.setOutputName("plib_" + pmInstanceName.getValue().lower() + ".c")
    pmSym_SourceFile.setDestPath("/peripheral/pm/")
    pmSym_SourceFile.setProjectPath("config/" + configName + "/peripheral/pm/")
    pmSym_SourceFile.setType("SOURCE")
    pmSym_SourceFile.setMarkup(True)

    pmSym_SystemInitFile = pmComponent.createFileSymbol("PM_SYS_INIT", None)
    pmSym_SystemInitFile.setType("STRING")
    pmSym_SystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_START")
    pmSym_SystemInitFile.setSourcePath("../peripheral/pm_pwr_pm_arm_v1/templates/system/initialization.c.ftl")
    pmSym_SystemInitFile.setMarkup(True)

    pmSymSystemDefFile = pmComponent.createFileSymbol("PM_SYS_DEF", None)
    pmSymSystemDefFile.setType("STRING")
    pmSymSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    pmSymSystemDefFile.setSourcePath("../peripheral/pm_pwr_pm_arm_v1/templates/system/definitions.h.ftl")
    pmSymSystemDefFile.setMarkup(True)

