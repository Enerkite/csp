# coding: utf-8
"""*****************************************************************************
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
*****************************************************************************"""

###################################################################################################
########################################## Callbacks  #############################################
###################################################################################################
global supcSym_BODVDD_STDBYCFG
global supcSym_BODVDD_ACTCFG
global supcInstanceName
global evsys_generatorsNamesList
evsys_generatorsNamesList = []

def supcEvsysGeneratorNamesPopulate():
    global evsys_generatorsNamesList

    generatorNode = ATDF.getNode("/avr-tools-device-file/devices/device/events/generators")
    generatorValues = generatorNode.getChildren()
    for id in range(0, len(generatorNode.getChildren())):
        if ("MVIO" in generatorValues[id].getAttribute("module-instance")) or ("VLM" in generatorValues[id].getAttribute("module-instance")):
            evsys_generatorsNamesList.append(generatorValues[id].getAttribute("name"))

def supcEvesysConfigure(symbol, event):
    global evsys_generatorsNamesList

    if ("SUPC_EVCTRL_VLMEO" in event["id"]):
        for genName in evsys_generatorsNamesList:
            if "VLM" in genName:
                evsysGenName = genName
        Database.setSymbolValue("evsys", "GENERATOR_" + evsysGenName + "_ACTIVE", event["value"])

    if ("SUPC_EVCTRL_MVIOEO" in event["id"]):
        for genName in evsys_generatorsNamesList:
            if "MVIO" in genName:
                evsysGenName = genName
        Database.setSymbolValue("evsys", "GENERATOR_" + evsysGenName + "_ACTIVE", event["value"])

def updateBODVisibleProperty(symbol, event):
    symbol.setVisible(event["value"])

def interruptControl(symbol, event):
    global supcInstanceName
    InterruptVector = supcInstanceName.getValue()+"_INTERRUPT_ENABLE"
    InterruptHandler = supcInstanceName.getValue()+"_INTERRUPT_HANDLER"
    InterruptHandlerLock = supcInstanceName.getValue()+"_INTERRUPT_HANDLER_LOCK"

    if ((Database.getSymbolValue(supcInstanceName.getValue().lower(), "SUPC_INTENSET_VDDIO2LPMPOR") == True) or
        (Database.getSymbolValue(supcInstanceName.getValue().lower(), "SUPC_INTENSET_VDDIO2OK") == True) or
        (Database.getSymbolValue(supcInstanceName.getValue().lower(), "SUPC_INTENSET_VLM") == True) or
        (Database.getSymbolValue(supcInstanceName.getValue().lower(), "SUPC_INTENSET_BODVDDRDY") == True)):
        Database.setSymbolValue("core", InterruptVector, True)
        Database.setSymbolValue("core", InterruptHandler, supcInstanceName.getValue() + "_InterruptHandler")
        Database.setSymbolValue("core", InterruptHandlerLock, True)
    else :
        Database.setSymbolValue("core", InterruptVector, False)
        Database.setSymbolValue("core", InterruptHandler, supcInstanceName.getValue() + "_Handler")
        Database.setSymbolValue("core", InterruptHandlerLock, False)

    intEnableState=Database.getSymbolValue("core", supcInstanceName.getValue() + "_INTERRUPT_ENABLE_UPDATE")

    if (((Database.getSymbolValue(supcInstanceName.getValue().lower(), "SUPC_INTENSET_VDDIO2LPMPOR") == True) or
        (Database.getSymbolValue(supcInstanceName.getValue().lower(), "SUPC_INTENSET_VDDIO2OK") == True) or
        (Database.getSymbolValue(supcInstanceName.getValue().lower(), "SUPC_INTENSET_VLM") == True) or
        (Database.getSymbolValue(supcInstanceName.getValue().lower(), "SUPC_INTENSET_BODVDDRDY") == True)) and
        (intEnableState == True)):
        symbol.setVisible(True)
    else:
        symbol.setVisible(False)

###################################################################################################
########################################## Component  #############################################
###################################################################################################

def instantiateComponent(supcComponent):
    global supcSym_BODVDD_STDBYCFG
    global supcSym_BODVDD_ACTCFG
    global supcInstanceName
    global supcSym_INTENSET

    supcInstanceName = supcComponent.createStringSymbol("SUPC_INSTANCE_NAME", None)
    supcInstanceName.setVisible(False)
    supcInstanceName.setDefaultValue(supcComponent.getID().upper())

    supcEvsysGeneratorNamesPopulate()

    #BOD Menu
    supcSym_BODVDD_Menu= supcComponent.createMenuSymbol("BOD_MENU", None)
    supcSym_BODVDD_Menu.setLabel("VDD Brown-Out Detector (BOD) Configuration")

    #BODVDD ACTCFG mode
    supcSym_BODVDD_ACTCFG = supcComponent.createKeyValueSetSymbol("SUPC_BODVDD_ACTCFG", supcSym_BODVDD_Menu)
    supcSym_BODVDD_ACTCFG.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:supc_06257;register:BODVDD")
    supcSym_BODVDD_ACTCFG.setLabel("Select Active mode operation")
    supcSym_BODVDD_ACTCFG.setDescription("Configures whether BODVDD should operate in continuous or sampling mode in Active mode")
    supcBODVDDActcfgNode = ATDF.getNode("/avr-tools-device-file/modules/module@[name=\"SUPC\"]/value-group@[name=\"SUPC_BODVDD__ACTCFG\"]")
    supcBODVDDActcfgValues = []
    supcBODVDDActcfgValues = supcBODVDDActcfgNode.getChildren()
    for index in range (0, len(supcBODVDDActcfgValues)):
        supcBODVDDActcfgKeyName = supcBODVDDActcfgValues[index].getAttribute("name")
        supcBODVDDActcfgKeyDescription = supcBODVDDActcfgValues[index].getAttribute("caption")
        supcBODVDDActcfgKeyValue =  supcBODVDDActcfgValues[index].getAttribute("value")
        supcSym_BODVDD_ACTCFG.addKey(supcBODVDDActcfgKeyName, supcBODVDDActcfgKeyValue, supcBODVDDActcfgKeyDescription)
    supcSym_BODVDD_ACTCFG.setDefaultValue(0)
    supcSym_BODVDD_ACTCFG.setOutputMode("Value")
    supcSym_BODVDD_ACTCFG.setDisplayMode("Description")

    #BODVDD RUNSTDBY enable
    supcSym_BODVDD_RUNSTDBY = supcComponent.createBooleanSymbol("SUPC_BODVDD_RUNSTDBY", supcSym_BODVDD_Menu)
    supcSym_BODVDD_RUNSTDBY.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:supc_06257;register:BODVDD")
    supcSym_BODVDD_RUNSTDBY.setLabel("Run in Standby mode")
    supcSym_BODVDD_RUNSTDBY.setDescription("Configures BODVDD operation in Standby Sleep Mode")

    #BODVDD STDBYCFG mode
    supcSym_BODVDD_STDBYCFG = supcComponent.createKeyValueSetSymbol("SUPC_BODVDD_STDBYCFG", supcSym_BODVDD_Menu)
    supcSym_BODVDD_STDBYCFG.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:supc_06257;register:BODVDD")
    supcSym_BODVDD_STDBYCFG.setLabel("Select Standby mode operation")
    supcSym_BODVDD_STDBYCFG.setDescription("Configures whether BODVDD should operate in continuous or sampling mode in Standby Sleep mode")
    supcBODVDDStdbycfgNode = ATDF.getNode("/avr-tools-device-file/modules/module@[name=\"SUPC\"]/value-group@[name=\"SUPC_BODVDD__STDBYCFG\"]")
    supcBODVDDStdbycfgValues = []
    supcBODVDDStdbycfgValues = supcBODVDDStdbycfgNode.getChildren()
    for index in range (0, len(supcBODVDDStdbycfgValues)):
        supcBODVDDStdbycfgKeyName = supcBODVDDStdbycfgValues[index].getAttribute("name")
        supcBODVDDStdbycfgKeyDescription = supcBODVDDStdbycfgValues[index].getAttribute("caption")
        supcBODVDDStdbycfgKeyValue =  supcBODVDDStdbycfgValues[index].getAttribute("value")
        supcSym_BODVDD_STDBYCFG.addKey(supcBODVDDStdbycfgKeyName, supcBODVDDStdbycfgKeyValue, supcBODVDDStdbycfgKeyDescription)
    supcSym_BODVDD_STDBYCFG.setDefaultValue(0)
    supcSym_BODVDD_STDBYCFG.setOutputMode("Value")
    supcSym_BODVDD_STDBYCFG.setDisplayMode("Description")
    supcSym_BODVDD_STDBYCFG.setVisible(False)
    supcSym_BODVDD_STDBYCFG.setDependencies(updateBODVisibleProperty, ["SUPC_BODVDD_RUNSTDBY"])

    #BODVDD VLMLVL
    supcSym_BODVDD_VLMLVL = supcComponent.createKeyValueSetSymbol("SUPC_BODVDD_VLMLVL", supcSym_BODVDD_Menu)
    supcSym_BODVDD_VLMLVL.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:supc_06257;register:BODVDD")
    supcSym_BODVDD_VLMLVL.setLabel("Select Voltage Level Monitor Level")
    supcSym_BODVDD_VLMLVL.setDescription("Select Voltage Level Monitor Level")
    supcSym_BODVDD_VLMLVL.setVisible(True)
    supcBODVDDVlmlvlNode = ATDF.getNode("/avr-tools-device-file/modules/module@[name=\"SUPC\"]/value-group@[name=\"SUPC_BODVDD__VLMLVL\"]")
    supcBODVDDVlmlvlValues = []
    supcBODVDDVlmlvlValues = supcBODVDDVlmlvlNode.getChildren()
    for index in range (0, len(supcBODVDDVlmlvlValues)):
        supcBODVDDVlmlvlKeyName = supcBODVDDVlmlvlValues[index].getAttribute("name")
        supcBODVDDVlmlvlKeyDescription = supcBODVDDVlmlvlValues[index].getAttribute("caption")
        supcBODVDDVlmlvlKeyValue =  supcBODVDDVlmlvlValues[index].getAttribute("value")
        supcSym_BODVDD_VLMLVL.addKey(supcBODVDDVlmlvlKeyName, supcBODVDDVlmlvlKeyValue, supcBODVDDVlmlvlKeyDescription)
    supcSym_BODVDD_VLMLVL.setDefaultValue(0)
    supcSym_BODVDD_VLMLVL.setOutputMode("Value")
    supcSym_BODVDD_VLMLVL.setDisplayMode("Description")

    #BODVDD VLMCFG
    supcSym_BODVDD_VLMCFG = supcComponent.createKeyValueSetSymbol("SUPC_BODVDD_VLMCFG", supcSym_BODVDD_Menu)
    supcSym_BODVDD_VLMCFG.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:supc_06257;register:BODVDD")
    supcSym_BODVDD_VLMCFG.setLabel("Select Voltage Level Monitor Interrupt")
    supcSym_BODVDD_VLMCFG.setDescription("Selects which incident will trigger a VLM interrupt")
    supcSym_BODVDD_VLMCFG.setVisible(True)
    supcBODVDDVlmcfgNode = ATDF.getNode("/avr-tools-device-file/modules/module@[name=\"SUPC\"]/value-group@[name=\"SUPC_BODVDD__VLMCFG\"]")
    supcBODVDDVlmcfgValues = []
    supcBODVDDVlmcfgValues = supcBODVDDVlmcfgNode.getChildren()
    for index in range (0, len(supcBODVDDVlmcfgValues)):
        supcBODVDDVlmcfgKeyName = supcBODVDDVlmcfgValues[index].getAttribute("name")
        supcBODVDDVlmcfgKeyDescription = supcBODVDDVlmcfgValues[index].getAttribute("caption")
        supcBODVDDVlmcfgKeyValue =  supcBODVDDVlmcfgValues[index].getAttribute("value")
        supcSym_BODVDD_VLMCFG.addKey(supcBODVDDVlmcfgKeyName, supcBODVDDVlmcfgKeyValue, supcBODVDDVlmcfgKeyDescription)
    supcSym_BODVDD_VLMCFG.setDefaultValue(0)
    supcSym_BODVDD_VLMCFG.setOutputMode("Value")
    supcSym_BODVDD_VLMCFG.setDisplayMode("Description")

    #BODVDD Write Lock
    supcSym_BODVDD_WRTLOCK = supcComponent.createBooleanSymbol("SUPC_BODVDD_WRTLOCK", supcSym_BODVDD_Menu)
    supcSym_BODVDD_WRTLOCK.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:supc_06257;register:BODVDD")
    supcSym_BODVDD_WRTLOCK.setLabel("Lock BODVDD configuration")
    supcSym_BODVDD_WRTLOCK.setDescription("Lock BODVDD configuration")

    #VREG Menu
    supcSym_VREG_Menu= supcComponent.createMenuSymbol("VREG_MENU", None)
    supcSym_VREG_Menu.setLabel("Voltage Regulator (VREG) Configuration")

    #VREG RUNSTDBY mode
    supcSym_VREG_RUNSTDBY = supcComponent.createKeyValueSetSymbol("SUPC_VREG_RUNSTDBY", supcSym_VREG_Menu)
    supcSym_VREG_RUNSTDBY.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:supc_06257;register:VREG")
    supcSym_VREG_RUNSTDBY.setLabel("Select Standby mode operation")
    supcSym_VREG_RUNSTDBY.setDescription("Configures VREG operation in Standby Sleep Mode")
    supcSym_VREG_RUNSTDBY.addKey("LP_OP", "0", "Automatically switch from LDO to ULP regulator in sleep and when running on 32.768 kHz oscillator")
    supcSym_VREG_RUNSTDBY.addKey("NORMAL_OP", "1", "The main LDO voltage regulator is on and powers the device in Standby sleep mode")
    supcSym_VREG_RUNSTDBY.setDefaultValue(0)
    supcSym_VREG_RUNSTDBY.setOutputMode("Value")
    supcSym_VREG_RUNSTDBY.setDisplayMode("Description")

    #MVIO Menu
    supcSym_MVIO_Menu= supcComponent.createMenuSymbol("MVIO_MENU", None)
    supcSym_MVIO_Menu.setLabel("MVIO Configuration")

    #MVIO VDDIO2CFG
    supcSym_MVIO_VDDIO2CFG = supcComponent.createKeyValueSetSymbol("SUPC_MVIO_VDDIO2CFG", supcSym_MVIO_Menu)
    supcSym_MVIO_VDDIO2CFG.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:supc_06257;register:SUPC_MVIO")
    supcSym_MVIO_VDDIO2CFG.setLabel("VDDIO2 Configuration")
    supcSym_MVIO_VDDIO2CFG.setDescription("Selects VDDIO2 Configuration")
    supcSym_MVIO_VDDIO2CFG.setVisible(True)
    supcMVIOVddio2cfgNode = ATDF.getNode("/avr-tools-device-file/modules/module@[name=\"SUPC\"]/value-group@[name=\"SUPC_MVIO__VDDIO2CFG\"]")
    supcMVIOVddio2cfgValues = []
    supcMVIOVddio2cfgValues = supcMVIOVddio2cfgNode.getChildren()
    for index in range (0, len(supcMVIOVddio2cfgValues)):
        supcMVIOVddio2cfgKeyName = supcMVIOVddio2cfgValues[index].getAttribute("name")
        supcMVIOVddio2cfgKeyDescription = supcMVIOVddio2cfgValues[index].getAttribute("caption")
        supcMVIOVddio2cfgKeyValue =  supcMVIOVddio2cfgValues[index].getAttribute("value")
        supcSym_MVIO_VDDIO2CFG.addKey(supcMVIOVddio2cfgKeyName, supcMVIOVddio2cfgKeyValue, supcMVIOVddio2cfgKeyDescription)
    supcSym_MVIO_VDDIO2CFG.setDefaultValue(0)
    supcSym_MVIO_VDDIO2CFG.setOutputMode("Value")
    supcSym_MVIO_VDDIO2CFG.setDisplayMode("Description")

    #SUPC Event Menu
    supcSym_Event_Menu= supcComponent.createMenuSymbol("SUPC_EVENT_MENU", None)
    supcSym_Event_Menu.setLabel("Event Configuration")

    #VLM Event Output
    supcSym_EVCTRL_VLMEO = supcComponent.createBooleanSymbol("SUPC_EVCTRL_VLMEO", supcSym_Event_Menu)
    supcSym_EVCTRL_VLMEO.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:supc_06257;register:EVCTRL")
    supcSym_EVCTRL_VLMEO.setLabel("Enable VLM Event Output")
    supcSym_EVCTRL_VLMEO.setDescription("Enable VLM Event Output")
    supcSym_EVCTRL_VLMEO.setDependencies(supcEvesysConfigure, ["SUPC_EVCTRL_VLMEO"])

    #MVIO Event Output
    supcSym_EVCTRL_MVIOEO = supcComponent.createBooleanSymbol("SUPC_EVCTRL_MVIOEO", supcSym_Event_Menu)
    supcSym_EVCTRL_MVIOEO.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:supc_06257;register:EVCTRL")
    supcSym_EVCTRL_MVIOEO.setLabel("Enable MVIO Event Output")
    supcSym_EVCTRL_MVIOEO.setDescription("Enable MVIO Event Output")
    supcSym_EVCTRL_MVIOEO.setDependencies(supcEvesysConfigure, ["SUPC_EVCTRL_MVIOEO"])

    #SUPC Interrupt Menu
    supcSym_Interrupt_Menu= supcComponent.createMenuSymbol("SUPC_INTERRUPT_MENU", None)
    supcSym_Interrupt_Menu.setLabel("Interrupt Configuration")

    #VDDIO2LPMPOR Interrupt
    supcSym_INTENSET_VDDIO2LPMPOR = supcComponent.createBooleanSymbol("SUPC_INTENSET_VDDIO2LPMPOR", supcSym_Interrupt_Menu)
    supcSym_INTENSET_VDDIO2LPMPOR.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:supc_06257;register:INTENSET")
    supcSym_INTENSET_VDDIO2LPMPOR.setLabel("Enable VDDIO2 Low Power Mode POR Interrupt")
    supcSym_INTENSET_VDDIO2LPMPOR.setDefaultValue(False)

    #VDDIO2OK Interrupt
    supcSym_INTENSET_VDDIO2OK = supcComponent.createBooleanSymbol("SUPC_INTENSET_VDDIO2OK", supcSym_Interrupt_Menu)
    supcSym_INTENSET_VDDIO2OK.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:supc_06257;register:INTENSET")
    supcSym_INTENSET_VDDIO2OK.setLabel("Enable VDDIO2 OK Interrupt")
    supcSym_INTENSET_VDDIO2OK.setDefaultValue(False)

    #VLM Interrupt
    supcSym_INTENSET_VLM = supcComponent.createBooleanSymbol("SUPC_INTENSET_VLM", supcSym_Interrupt_Menu)
    supcSym_INTENSET_VLM.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:supc_06257;register:INTENSET")
    supcSym_INTENSET_VLM.setLabel("Enable Voltage Level Monitor Interrupt")
    supcSym_INTENSET_VLM.setDefaultValue(False)

    #BODVDDRDY Interrupt
    supcSym_INTENSET_BODVDDRDY = supcComponent.createBooleanSymbol("SUPC_INTENSET_BODVDDRDY", supcSym_Interrupt_Menu)
    supcSym_INTENSET_BODVDDRDY.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:supc_06257;register:INTENSET")
    supcSym_INTENSET_BODVDDRDY.setLabel("Enable BODVDD Ready Interrupt")
    supcSym_INTENSET_BODVDDRDY.setDefaultValue(False)

    # Interrupt Warning status
    supcSym_IntEnComment = supcComponent.createCommentSymbol("SUPC_INTERRUPT_ENABLE_COMMENT", supcSym_Interrupt_Menu)
    supcSym_IntEnComment.setVisible(False)
    supcSym_IntEnComment.setLabel("Warning!!! SUPC Interrupt is Disabled in Interrupt Manager")
    supcSym_IntEnComment.setDependencies(interruptControl, [supcInstanceName.getValue() + "_INTERRUPT_ENABLE_UPDATE", "SUPC_INTENSET_VDDIO2LPMPOR", "SUPC_INTENSET_VDDIO2OK", "SUPC_INTENSET_VLM", "SUPC_INTENSET_BODVDDRDY"])

    ###################################################################################################
    ####################################### Code Generation  ##########################################
    ###################################################################################################

    configName = Variables.get("__CONFIGURATION_NAME")

    supcSym_HeaderFile = supcComponent.createFileSymbol("SUPC_HEADER", None)
    supcSym_HeaderFile.setSourcePath("../peripheral/supc_06257/templates/plib_supc.h.ftl")
    supcSym_HeaderFile.setOutputName("plib_"+supcInstanceName.getValue().lower()+".h")
    supcSym_HeaderFile.setDestPath("/peripheral/supc/")
    supcSym_HeaderFile.setProjectPath("config/" + configName + "/peripheral/supc/")
    supcSym_HeaderFile.setType("HEADER")
    supcSym_HeaderFile.setMarkup(True)

    supcSym_SourceFile = supcComponent.createFileSymbol("SUPC_SOURCE", None)
    supcSym_SourceFile.setSourcePath("../peripheral/supc_06257/templates/plib_supc.c.ftl")
    supcSym_SourceFile.setOutputName("plib_"+supcInstanceName.getValue().lower()+".c")
    supcSym_SourceFile.setDestPath("/peripheral/supc/")
    supcSym_SourceFile.setProjectPath("config/" + configName + "/peripheral/supc/")
    supcSym_SourceFile.setType("SOURCE")
    supcSym_SourceFile.setMarkup(True)

    supcSym_SystemInitFile = supcComponent.createFileSymbol("SUPC_SYS_INT", None)
    supcSym_SystemInitFile.setType("STRING")
    supcSym_SystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_PERIPHERALS")
    supcSym_SystemInitFile.setSourcePath("../peripheral/supc_06257/templates/system/initialization.c.ftl")
    supcSym_SystemInitFile.setMarkup(True)

    supcSym_SystemDefFile = supcComponent.createFileSymbol("SUPC_SYS_DEF", None)
    supcSym_SystemDefFile.setType("STRING")
    supcSym_SystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    supcSym_SystemDefFile.setSourcePath("../peripheral/supc_06257/templates/system/definitions.h.ftl")
    supcSym_SystemDefFile.setMarkup(True)
