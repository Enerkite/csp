
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

Log.writeInfoMessage("Loading Clock Manager for " + Variables.get("__PROCESSOR"))

from os.path import join
from xml.etree import ElementTree
from collections import defaultdict
global topsort
clkMenu = coreComponent.createMenuSymbol("PIC32CM_PL10_CLK_MENU", None)
clkMenu.setLabel("Clock")
clkMenu.setDescription("Configuration for Clock System Service")

# Clock Source Configuration
clkSourceMenu = coreComponent.createMenuSymbol("CLOCK_SOURCE", clkMenu)
clkSourceMenu.setLabel("Clock Source Configuration")

osc32k_Menu = coreComponent.createMenuSymbol("OSC32K_MENU", clkSourceMenu)
osc32k_Menu.setLabel("32Khz Internal Oscillator Configuration")

xosc32k_Menu = coreComponent.createMenuSymbol("XOSC32K_MENU", clkSourceMenu)
xosc32k_Menu.setLabel("32Khz External Oscillator Configuration")

oschf_Menu = coreComponent.createMenuSymbol("OSCHF_MENU", clkSourceMenu)
oschf_Menu.setLabel("OSCHF oscillator Configuration")

# Clock Generator Configuration
clkGen_Menu = coreComponent.createMenuSymbol("GCLK_MENU", clkMenu)
clkGen_Menu.setLabel("Generic Clock Configuration")

gclkGen_Menu = coreComponent.createMenuSymbol("GCLK_GEN_MENU", clkGen_Menu)
gclkGen_Menu.setLabel("Generator Configuration")

gclkPeriChannel_menu = coreComponent.createMenuSymbol("GCLK_PERI_MENU",clkGen_Menu)
gclkPeriChannel_menu.setLabel("Peripheral Channel Configuration")

# Main Clock Configuration
mclkSym_Menu = coreComponent.createMenuSymbol("MCLK_MENU", clkMenu)
mclkSym_Menu.setLabel("Main Clock Configuration")

# Peripheral Clock Configuration
peripheralClockMenu = coreComponent.createMenuSymbol("PERIPHERAL_CLOCK_MENU", clkMenu)
peripheralClockMenu.setLabel("Peripheral Clock Configuration")

# Calculated Frequency Menu
calculatedFreq_Menu = coreComponent.createMenuSymbol("FREQ_MENU", clkMenu)
calculatedFreq_Menu.setLabel("Calculated Clock Frequencies")

#################################################################################################
################################################################################
##########              Callback Functions            ##########################
################################################################################

def setOSCHFFreq(symbol, event):
    symbol.setValue(int(event["source"].getSymbolByID("OSCHF_OSCHFCTRL_FRQSEL").getSelectedKey()[:-1]) * 1000000)

def writeEnable(symbol, event):
    if (event["value"] == True):
       symbol.setReadOnly(True)
    elif (event["value"] == False):
       symbol.setReadOnly(False)

def interruptControl(symbol, event):
    if event["id"] == "XOSC32K_CFDEN":
        moduleInterruptName = "OSC32KCTRL"
    elif event["id"] == "MCLK_INTENSET_CKRDY":
        moduleInterruptName = "MCLK"

    InterruptVector = moduleInterruptName + "_INTERRUPT_ENABLE"
    InterruptHandler = moduleInterruptName + "_INTERRUPT_HANDLER"
    InterruptHandlerLock = moduleInterruptName + "_INTERRUPT_HANDLER_LOCK"

    if (event["value"] == True):
        Database.setSymbolValue("core", InterruptVector, True)
        Database.setSymbolValue("core", InterruptHandler, moduleInterruptName + "_InterruptHandler")
        Database.setSymbolValue("core", InterruptHandlerLock, True)
    else :
        Database.setSymbolValue("core", InterruptVector, False)
        Database.setSymbolValue("core", InterruptHandler, moduleInterruptName + "_Handler")
        Database.setSymbolValue("core", InterruptHandlerLock, False)

################################################################################
#######          OSCCTRL Database Components      ##############################
################################################################################

############################   OSCHF Components    ##############################
#OSCHF Oscillator Frequency
oscctrlSym_OSCHFCTRL_FRQSEL = coreComponent.createKeyValueSetSymbol("OSCHF_OSCHFCTRL_FRQSEL", oschf_Menu)
oscctrlSym_OSCHFCTRL_FRQSEL.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:OSCHFCTRL")
oscctrlSym_OSCHFCTRL_FRQSEL.setLabel("Select OSCHF Frequency")
oscctrlSym_OSCHFCTRL_FRQSEL.setDescription("Select OSCHF Frequency")
oscctrlSym_OSCHFCTRLNode = ATDF.getNode("/avr-tools-device-file/modules/module@[name=\"OSCCTRL\"]/value-group@[name=\"OSCCTRL_OSCHFCTRL__FRQSEL\"]")
if oscctrlSym_OSCHFCTRLNode != None:
    oscctrlSym_OSCHFCTRLValues = []
    oscctrlSym_OSCHFCTRLValues = oscctrlSym_OSCHFCTRLNode.getChildren()
    for index in range(0, len(oscctrlSym_OSCHFCTRLValues)):
        oschf_freqsel_KeyName = oscctrlSym_OSCHFCTRLValues[index].getAttribute("name")
        oschf_freqsel_KeyDescription = oscctrlSym_OSCHFCTRLValues[index].getAttribute("caption")
        oschf_freqsel_KeyValue = oscctrlSym_OSCHFCTRLValues[index].getAttribute("value")
        oscctrlSym_OSCHFCTRL_FRQSEL.addKey(oschf_freqsel_KeyName, oschf_freqsel_KeyValue , oschf_freqsel_KeyDescription)
oscctrlSym_OSCHFCTRL_FRQSEL.setDefaultValue(3)
oscctrlSym_OSCHFCTRL_FRQSEL.setOutputMode("Value")
oscctrlSym_OSCHFCTRL_FRQSEL.setDisplayMode("Description")
# OSCHF set to 24 MHz frequency
oscctrlSym_OSCHFCTRL_FRQSEL.setValue(8)

#OSCHF Oscillator ONDEMAND Mode
oscctrlSym_OSCHFCTRL_ONDEMAND = coreComponent.createKeyValueSetSymbol("OSCHF_OSCHFCTRL_ONDEMAND", oschf_Menu)
oscctrlSym_OSCHFCTRL_ONDEMAND.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:OSCHFCTRL")
oscctrlSym_OSCHFCTRL_ONDEMAND.setLabel("OSCHF On-Demand Control")
oscctrlSym_OSCHFCTRL_ONDEMAND.setDescription("Configures the OSCHF on Demand Behavior")
oscctrlSym_OSCHFCTRL_ONDEMAND.setOutputMode("Key")
oscctrlSym_OSCHFCTRL_ONDEMAND.setDisplayMode("Description")
oscctrlSym_OSCHFCTRL_ONDEMAND.addKey("DISABLE",str(0),"Always Enable")
oscctrlSym_OSCHFCTRL_ONDEMAND.addKey("ENABLE",str(1),"Only on Peripheral Request")
oscctrlSym_OSCHFCTRL_ONDEMAND.setDefaultValue(0)

#OSCHF Oscillator AUTOTUNE
oscctrlSym_OSCHFCTRL_AUTOTUNE = coreComponent.createBooleanSymbol("OSCHF_OSCHFCTRL_AUTOTUNE", oschf_Menu)
oscctrlSym_OSCHFCTRL_AUTOTUNE.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:OSCHFCTRL")
oscctrlSym_OSCHFCTRL_AUTOTUNE.setLabel("Enable automatic oscillator tune")
oscctrlSym_OSCHFCTRL_AUTOTUNE.setDefaultValue(False)

oscctrlSym_OSCHF_FREQ = coreComponent.createIntegerSymbol("OSCHF_FREQ", calculatedFreq_Menu)
oscctrlSym_OSCHF_FREQ.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:%NOREGISTER%")
oscctrlSym_OSCHF_FREQ.setLabel("OSCHF Frequency")
oscctrlSym_OSCHF_FREQ.setDefaultValue(int(oscctrlSym_OSCHFCTRL_FRQSEL.getSelectedKey()[:-1]) * 1000000)
oscctrlSym_OSCHF_FREQ.setReadOnly(True)
oscctrlSym_OSCHF_FREQ.setDependencies(setOSCHFFreq, ["OSCHF_OSCHFCTRL_FRQSEL"])

################################################################################
##########              Callback Functions            ##########################
################################################################################

####    XOSC32K Configuration Callback Functions    ############################

def setXOSC32KFreq(symbol, event):
    xosc = Database.getSymbolValue("core", "CONF_CLOCK_XOSC32K_ENABLE")
    xoscmode = Database.getSymbolValue("core","XOSC32K_OSCILLATOR_MODE")
    xosc_in_freq = Database.getSymbolValue("core","XOSC32K_FREQ_IN")

    if (xosc == True) and (xoscmode == 1):
        symbol.setValue(32768)
    elif (xosc == True) and (xoscmode == 0):
        symbol.setValue(xosc_in_freq)
    elif (xosc == False):
        symbol.setValue(0)

################################################################################
#######          OSC32KCTRL Database Components      ###########################
################################################################################

####################    XOSC32K Components    ##################################
#XOSC32K External Oscillator Enable
osc32kctrlSym_XOSC32K_CONFIG_ENABLE = coreComponent.createBooleanSymbol("CONF_CLOCK_XOSC32K_ENABLE", xosc32k_Menu)
osc32kctrlSym_XOSC32K_CONFIG_ENABLE.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:XOSC32K")
osc32kctrlSym_XOSC32K_CONFIG_ENABLE.setLabel("32KHz External Crystal Oscillator(XOSC32K) Enable")
osc32kctrlSym_XOSC32K_CONFIG_ENABLE.setDefaultValue(False)

#XOSC32K External Oscillator Mode
osc32kctrlSym_XOSC32K_OSCILLATOR_MODE = coreComponent.createKeyValueSetSymbol("XOSC32K_OSCILLATOR_MODE", xosc32k_Menu)
osc32kctrlSym_XOSC32K_OSCILLATOR_MODE.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:XOSC32K")
osc32kctrlSym_XOSC32K_OSCILLATOR_MODE.setLabel("32KHz External Oscillator Mode ")
osc32kctrlSym_XOSC32K_OSCILLATOR_MODE.addKey("EXTERNAL_CLOCK","0","xosc32K external clock enable")
osc32kctrlSym_XOSC32K_OSCILLATOR_MODE.addKey("CRYSTAL","1","crystal oscillator enable")
osc32kctrlSym_XOSC32K_OSCILLATOR_MODE.setOutputMode("Value")
osc32kctrlSym_XOSC32K_OSCILLATOR_MODE.setDefaultValue(1)

clkSym_XOSC32K_Input_Freq = coreComponent.createIntegerSymbol("XOSC32K_FREQ_IN", xosc32k_Menu)
clkSym_XOSC32K_Input_Freq.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:XOSC32K")
clkSym_XOSC32K_Input_Freq.setLabel("Frequency")
clkSym_XOSC32K_Input_Freq.setDefaultValue(32768)

#XOSC32K External Oscillator Run in Low Power Mode
osc32kctrlSym_XOSC32K_LPMODE = coreComponent.createBooleanSymbol("XOSC32K_LPMODE", xosc32k_Menu)
osc32kctrlSym_XOSC32K_LPMODE.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:XOSC32K")
osc32kctrlSym_XOSC32K_LPMODE.setLabel("Run Oscillator in Low Power Mode")

#XOSC32K External Oscillator ONDEMAND Mode
osc32kctrlSym_XOSC32K_ONDEMAND= coreComponent.createKeyValueSetSymbol("XOSC32K_ONDEMAND", xosc32k_Menu)
osc32kctrlSym_XOSC32K_ONDEMAND.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:XOSC32K")
osc32kctrlSym_XOSC32K_ONDEMAND.setLabel("XOSC32K On-Demand Control")
osc32kctrlSym_XOSC32K_ONDEMAND.setDescription("Configures the XOSC32K on Demand Behavior")
osc32kctrlSym_XOSC32K_ONDEMAND.setOutputMode("Key")
osc32kctrlSym_XOSC32K_ONDEMAND.setDisplayMode("Description")
osc32kctrlSym_XOSC32K_ONDEMAND.addKey("DISABLE",str(0),"Always Enable")
osc32kctrlSym_XOSC32K_ONDEMAND.addKey("ENABLE",str(1),"Only on Peripheral Request")
osc32kctrlSym_XOSC32K_ONDEMAND.setDefaultValue(1)

#RTC Clock Selection
global rtcClockSourceSelection
rtcClockSourceSelection = coreComponent.createKeyValueSetSymbol("CONFIG_CLOCK_RTC_SRC",xosc32k_Menu) # FIXME base component by Kathir
rtcClockSourceSelection.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:RTCCTRL")
rtcClockSourceSelection.setLabel("RTC Clock Selection")
rtcClockSourceSelection.setDescription("Clock Source selection for RTC")
osc32kctrlSym_RTCSELNode = ATDF.getNode("/avr-tools-device-file/modules/module@[name=\"OSC32KCTRL\"]/value-group@[name=\"OSC32KCTRL_RTCCTRL__RTCSEL\"]")
osc32kctrlSym_RTCSELValues = []
osc32kctrlSym_RTCSELValues = osc32kctrlSym_RTCSELNode.getChildren()
for index in range(0, len(osc32kctrlSym_RTCSELValues)):
    osc32kctrlSym_RTCSEL_KeyName = osc32kctrlSym_RTCSELValues[index].getAttribute("name")
    osc32kctrlSym_RTCSEL_KeyDescription = osc32kctrlSym_RTCSELValues[index].getAttribute("caption")
    osc32kctrlSym_RTCSEL_KeyValue = osc32kctrlSym_RTCSELValues[index].getAttribute("value")
    rtcClockSourceSelection.addKey(osc32kctrlSym_RTCSEL_KeyName, osc32kctrlSym_RTCSEL_KeyValue, osc32kctrlSym_RTCSEL_KeyDescription)
rtcClockSourceSelection.setDefaultValue(0)
rtcClockSourceSelection.setOutputMode("Value")
rtcClockSourceSelection.setDisplayMode("Key")

#XOSC32K External Oscillator StartUp Time
osc32kctrlSym_XOSC32K_STARTUP = coreComponent.createKeyValueSetSymbol("XOSC32K_STARTUP", xosc32k_Menu)
osc32kctrlSym_XOSC32K_STARTUP.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:XOSC32K")
osc32kctrlSym_XOSC32K_STARTUP.setLabel("Oscillator Startup Time ")
osc32kctrlSym_XOSC32K_STARTUP.setDescription("XOSC start up time ")
osc32kctrlSym_XOSC32K_STARTUP.addKey("1K", "0x0" , "1K XOSC32K Cycles")
osc32kctrlSym_XOSC32K_STARTUP.addKey("16K", "0x1" , "16K XOSC32K Cycles")
osc32kctrlSym_XOSC32K_STARTUP.addKey("32K", "0x2" , "32K XOSC32K Cycles")
osc32kctrlSym_XOSC32K_STARTUP.addKey("64K", "0x3" , "64K XOSC32K Cycles")
osc32kctrlSym_XOSC32K_STARTUP.setDefaultValue(0)
osc32kctrlSym_XOSC32K_STARTUP.setOutputMode("Value")
osc32kctrlSym_XOSC32K_STARTUP.setDisplayMode("Description")

#XOSC32K External Oscillator Clock Failure Detection(CFD) Enable
osc32kctrlSym_XOSC32K_CFDCTRL_CFDEN = coreComponent.createBooleanSymbol("XOSC32K_CFDEN", xosc32k_Menu)
osc32kctrlSym_XOSC32K_CFDCTRL_CFDEN.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:CFDCTRL")
osc32kctrlSym_XOSC32K_CFDCTRL_CFDEN.setLabel("Enable Clock Failure Detection")
osc32kctrlSym_XOSC32K_CFDCTRL_CFDEN.setDependencies(interruptControl, ["XOSC32K_CFDEN"])

#XOSC32K External Oscillator Clock Failure Detection(CFD) Pre-Scalar
osc32kctrlSym_XOSC32K_CFDCTRL_CFDPRESC = coreComponent.createBooleanSymbol("XOSC32K_CFDPRESC", osc32kctrlSym_XOSC32K_CFDCTRL_CFDEN)
osc32kctrlSym_XOSC32K_CFDCTRL_CFDPRESC.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:CFDCTRL")
osc32kctrlSym_XOSC32K_CFDCTRL_CFDPRESC.setLabel("Clock Failure Backup Clock Frequency Divide-by-2")
osc32kctrlSym_XOSC32K_CFDCTRL_CFDPRESC.setDefaultValue(False)
osc32kctrlSym_XOSC32K_CFDCTRL_CFDPRESC.setVisible(False)

clkSym_XOSC32K_Freq = coreComponent.createIntegerSymbol("XOSC32K_FREQ", calculatedFreq_Menu)
clkSym_XOSC32K_Freq.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:XOSC32K")
clkSym_XOSC32K_Freq.setLabel("XOSC32K Clock Frequency")
clkSym_XOSC32K_Freq.setDefaultValue(0)
clkSym_XOSC32K_Freq.setReadOnly(True)
clkSym_XOSC32K_Freq.setDependencies(setXOSC32KFreq, ["CONF_CLOCK_XOSC32K_ENABLE", "XOSC32K_OSCILLATOR_MODE", "XOSC32K_FREQ_IN"])

#######################   OSC32K Components    #################################
#OSC32K Oscillator ONDEMAND Mode
osc32kctrlSym_OSC32K_ONDEMAND= coreComponent.createKeyValueSetSymbol("OSC32K_ONDEMAND", osc32k_Menu)
osc32kctrlSym_OSC32K_ONDEMAND.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:OSC32K")
osc32kctrlSym_OSC32K_ONDEMAND.setLabel("OSC32K On-Demand Control")
osc32kctrlSym_OSC32K_ONDEMAND.setDescription("Configures the OSC32K on Demand Behavior")
osc32kctrlSym_OSC32K_ONDEMAND.setOutputMode("Key")
osc32kctrlSym_OSC32K_ONDEMAND.setDisplayMode("Description")
osc32kctrlSym_OSC32K_ONDEMAND.addKey("DISABLE",str(0),"Always Enable")
osc32kctrlSym_OSC32K_ONDEMAND.addKey("ENABLE",str(1),"Only on Peripheral Request")
osc32kctrlSym_OSC32K_ONDEMAND.setDefaultValue(1)

clkSym_OSC32K_Freq = coreComponent.createIntegerSymbol("OSC32K_FREQ", calculatedFreq_Menu)
clkSym_OSC32K_Freq.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:OSC32K")
clkSym_OSC32K_Freq.setLabel("OSC32K Clock Frequency")
clkSym_OSC32K_Freq.setDefaultValue(32768)
clkSym_OSC32K_Freq.setReadOnly(True)

################################################################################
##########             GCLK Callback Functions            ######################
################################################################################
#GCLK Peripheral Channel Write Lock visible Property
def setPCHCTRLFREQVisibleProperty(symbol, event):
    index = symbol.getID().split("_FREQ")[0]
    if "_FREQ" not in event["id"]:
        perifreq = Database.getSymbolValue("core",index + "_GENSEL")
        channel = Database.getSymbolValue("core", index + "_CHEN")
        if channel:
            if perifreq == 0:
                srcFreq = Database.getSymbolValue("core","GCLK_0_FREQ")
                symbol.setValue(srcFreq,1)

            elif perifreq == 1:
                srcFreq = Database.getSymbolValue("core","GCLK_1_FREQ")
                symbol.setValue(srcFreq,1)
            elif perifreq == 2:
                srcFreq = Database.getSymbolValue("core","GCLK_2_FREQ")
                symbol.setValue(srcFreq,1)
            elif perifreq == 3:
                srcFreq = Database.getSymbolValue("core","GCLK_3_FREQ")
                symbol.setValue(srcFreq,1)
            else:
                symbol.setValue(0, 1)

        else:
            symbol.setValue(0, 1)

    else:
        if Database.getSymbolValue("core", index + "_CHEN"):
            perifreq = Database.getSymbolValue("core",index + "_GENSEL")
            generator = event["id"].split("_")[1]
            if int(perifreq) == int(generator):
                symbol.setValue(event["value"],1)

def setGClockFreq(symbol, event):
    global gclkSym_GENCTRL_SRC
    index = symbol.getID().split("_")[1]

    enable = Database.getSymbolValue("core", "GCLK_INST_NUM" + index)

    if enable:
        src = gclkSym_GENCTRL_SRC[int(index)].getSelectedKey()

        #OSCHF
        if src == "OSCHF":
            srcFreq = int(Database.getSymbolValue("core","OSCHF_FREQ"))

        # GCLKIN
        elif 'GCLK_IN' in str(src):
            gclk_in_symbol = "GCLK_IO_"+str(index)+"_FREQ"
            srcFreq = int(Database.getSymbolValue("core",gclk_in_symbol))

        # GCLKGEN1
        elif src == "GCLK1":
            if index != 1:
                srcFreq = int(Database.getSymbolValue("core","GCLK_1_FREQ"))

        #OSC32K
        elif src == "OSC32K":
            srcFreq = int(Database.getSymbolValue("core", "OSC32K_FREQ"))

        #XOSC32K
        elif src == "XOSC32K":
            srcFreq = int(Database.getSymbolValue("core", "XOSC32K_FREQ"))

        divSel = int(Database.getSymbolValue("core","GCLK_" + index + "_DIVSEL"))
        div = int(Database.getSymbolValue("core","GCLK_" + index + "_DIV"))

        if divSel == 0:

            if div != 0:
                gclk_freq = int(srcFreq / float(div))
            else:
                gclk_freq = srcFreq

        elif divSel == 1:
            gclk_freq = int(srcFreq / float(2**(div + 1)))

        symbol.setValue(gclk_freq)

    else:
        symbol.setValue(0)

def topsort(graph):
    from collections import deque

    #Initialize the degree of vetexes to zero and increment dependents by 1
    degreeList = {}
    for vertex in graph:
        degreeList[vertex] = 0

    for vertex in graph:
        for dependent in graph[vertex]:
            degreeList[dependent] = degreeList[dependent] + 1

    #initialize a dequeue pipe
    pipe = deque()

    #move vertexes with zero degree to the starting of pipe
    for vertex in degreeList:
        if degreeList[vertex] == 0:
            pipe.appendleft(vertex)

    outputList = []

    #move vertexes with degree 0 to output list
    #visit the dependent and reduce the degree by one for every visited dependent
    while pipe:
        vertex = pipe.pop()
        outputList.append(vertex)
        for dependent in graph[vertex]:
            degreeList[dependent] -= 1
            if degreeList[dependent] == 0:
                pipe.appendleft(dependent)

    #If there are no cycles that is the max degree of all vertices is 1
    #then the length of list should be equal to total number of vertices in graph else a cycle has been formed
    if len(outputList) == len(graph):
        return outputList
    else:
        return []

def codeGen(symbol, event):
    global topsort
    global gclkSym_GENCTRL_SRC
    global cycleFormed
    from collections import defaultdict
    sourceDestmap = defaultdict(list)
    sourceDestmap = {
                    "GCLK0" : [],
                    "GCLK1" : [],
                    "GCLK2" : [],
                    "GCLK3" : []
                    }
    symbol.clearValues()
    codeList = []

    for i in range(0, 4):
        if Database.getSymbolValue("core", "GCLK_INST_NUM" + str(i)):
           if gclkSym_GENCTRL_SRC[i].getSelectedKey() in ["GCLK1"]:
                sourceDestmap[gclkSym_GENCTRL_SRC[i].getSelectedKey()].append("GCLK"+str(i))

    codeList = topsort(sourceDestmap)
    if len(codeList) != 0:
        cycleFormed.setValue(False)

        for i in range(0, 4):
            if Database.getSymbolValue("core", "GCLK_INST_NUM" + str(i)) == False:
                codeList.remove("GCLK"+str(i))
        for i in range(0,len(codeList)):
            symbol.addValue("    " + codeList[i] + "_Initialize();")

    else:
        cycleFormed.setValue(True)

def clkSetup(symbol, event):
    global indexSymbolMap
    global peripheralInstanceList
    symbolKey = ""
    status = False

    if event["id"] == "CPU_CLOCK_FREQUENCY":
        freq = Database.getSymbolValue("core", "CPU_CLOCK_FREQUENCY")
        for name in peripheralInstanceList:
            if Database.getSymbolValue("core", name + "_CLOCK_ENABLE"):
                Database.setSymbolValue("core", name + "_CLOCK_FREQUENCY", freq)
            else:
                Database.setSymbolValue("core", name + "_CLOCK_FREQUENCY", 0)

    if event["id"].split("_CLOCK_ENABLE")[0] in peripheralInstanceList:
        if event["value"]:
            freq = Database.getSymbolValue("core", "CPU_CLOCK_FREQUENCY")
            Database.setSymbolValue("core", event["id"].split("_CLOCK_ENABLE")[0] + "_CLOCK_FREQUENCY", freq)
        else:
            Database.setSymbolValue("core", event["id"].split("_CLOCK_ENABLE")[0] + "_CLOCK_FREQUENCY", 0)
    elif "_CLOCK_ENABLE" in event["id"]:
        for key,value in indexSymbolMap.iteritems():
            for i in range(0,len(value)):
                if value[i] == event["id"].split("_CLOCK_ENABLE")[0]:
                    symbolKey = key
                    break
        symbolValues = indexSymbolMap.get(symbolKey)
        for i in symbolValues:
            status = status | Database.getSymbolValue("core", i + "_CLOCK_ENABLE")
        Database.setSymbolValue("core", symbolKey + "_CHEN", status, 2)
        if event["value"]:
            freq = Database.getSymbolValue("core", symbolKey + "_FREQ")
            Database.setSymbolValue("core", event["id"].split("_CLOCK_ENABLE")[0] + "_CLOCK_FREQUENCY", freq)
        else :
            Database.setSymbolValue("core", event["id"].split("_CLOCK_ENABLE")[0] + "_CLOCK_FREQUENCY", 0)

    if "_FREQ" in event["id"]:
        symbolKey = event["id"].split("_FREQ")[0]
        symbolValues = indexSymbolMap.get(symbolKey)
        for i in symbolValues:
            if Database.getSymbolValue("core", i + "_CLOCK_ENABLE"):
                freq = Database.getSymbolValue("core", symbolKey + "_FREQ")
                Database.setSymbolValue("core", i + "_CLOCK_FREQUENCY", freq)

def calcGclkDivider(symbol, event):
    index = symbol.getID().split("_")[1]
    divSel = int(Database.getSymbolValue("core","GCLK_" + index + "_DIVSEL"))
    div = int(Database.getSymbolValue("core","GCLK_" + index + "_DIV"))

    if divSel == 0:
        if div != 0:
            divider = div
        else:
            divider = 1

    elif divSel == 1:
        divider = 2**(div + 1)

    symbol.setValue(divider,2)

def setGCLKIOFreq(symbol, event):
    index = int(symbol.getID().split("GCLK_IO_")[1].split("_FREQ")[0])
    enable = Database.getSymbolValue("core", "GCLK_" + str(index) + "_OUTPUTENABLE" )
    if enable:
        symbol.setValue(int (Database.getSymbolValue("core", "GCLK_" + str(index) + "_FREQ" )), 2)
    else:
        symbol.setValue(0, 2)

def gclkMaxset(symbol, event):
    global gclkSym_GENCTRL_DIV
    generator = int(symbol.getID().split("GCLK_")[1].split("_DIV")[0])
    if event["value"] == 1:
        if (generator == 1):
            symbol.setMax(16)
        else:
            symbol.setMax(8)
    else:
        if (generator == 1):
            symbol.setMax(0xffff)
        else:
            symbol.setMax(0xff)


################################################################################
#######          GCLK Database Components            ###########################
################################################################################

gclkDependencyList = []

global gclkSym_num,gclkSym_GENCTRL_DIVSEL,gclkSym_GENCTRL_DIV
gclkSym_num = []
gclkSym_GENCTRL_RUNSTDBY = []
gclkSym_GENCTRL_OE = []
gclkSym_GENCTRL_OOV = []
global gclkSym_GENCTRL_IDC
gclkSym_GENCTRL_IDC = []
gclkSym_GCLK_IO_FREQ = []
gclkSym_GENCTRL_GENEN = []
gclkSym_GENCTRL_DIVSEL = []
gclkSym_GENCTRL_DIV = []
gclkSym_GENCTRL_DIVIDER_VALUE = []
global gclkSym_GENCTRL_SRC
gclkSym_GENCTRL_SRC = []
gclkSym_index = []
gclkSym_Freq = []
codeGenerationDep = []
triggerdepList = []
global indexSymbolMap
indexSymbolMap = defaultdict(list)


#------------------------- ATDF Read -------------------------------------
packageName = str(Database.getSymbolValue("core", "COMPONENT_PACKAGE"))
channel = []
availablePins = []        # array to save available pins
gclk_io_signals = [False, False, False, False] #array to save available signals
pinout = ""
numPads = 0
global cycleFormed
val = ATDF.getNode("/avr-tools-device-file/variants")
children = val.getChildren()
for index in range(0, len(children)):
    if packageName in children[index].getAttribute("package"):
        pinout = children[index].getAttribute("pinout")

children = []
val = ATDF.getNode("/avr-tools-device-file/pinouts/pinout@[name=\""+str(pinout)+"\"]")
children = val.getChildren()
for pad in range(0, len(children)):
    availablePins.append(children[pad].getAttribute("pad"))


gclk = ATDF.getNode("/avr-tools-device-file/devices/device/peripherals/module@[name=\"GCLK\"]/instance@[name=\"GCLK\"]/signals")
wakeup_signals = gclk.getChildren()
for pad in range (0 , len(wakeup_signals)):
    if "index" in wakeup_signals[pad].getAttributeList():
        padSignal = wakeup_signals[pad].getAttribute("pad")
        if padSignal in availablePins :
            gclk_io_signals[int(wakeup_signals[pad].getAttribute("index"))] = True

for gclknumber in range(0, 4):
    gclkSym_num.append(gclknumber)
    gclkSym_num[gclknumber] = coreComponent.createBooleanSymbol("GCLK_INST_NUM" + str(gclknumber),gclkGen_Menu)
    gclkSym_num[gclknumber].setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:GENCTRL1")
    gclkSym_num[gclknumber].setLabel("Enable Generic Clock Generator " + str(gclknumber))
    if( gclknumber == 0):
        gclkSym_num[gclknumber].setDefaultValue(True)
        gclkSym_num[gclknumber].setReadOnly(True)

    #GCLK Generator Run StandBy
    gclkSym_GENCTRL_RUNSTDBY.append(gclknumber)
    gclkSym_GENCTRL_RUNSTDBY[gclknumber] = coreComponent.createBooleanSymbol("GCLK_" + str(gclknumber) + "_RUNSTDBY", gclkSym_num[gclknumber])
    gclkSym_GENCTRL_RUNSTDBY[gclknumber].setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:GENCTRL")
    gclkSym_GENCTRL_RUNSTDBY[gclknumber].setLabel("GCLK should keep running in Standby mode")

    #GCLK Generator Source Selection
    gclkSym_GENCTRL_SRC.append(gclknumber)
    gclkSym_GENCTRL_SRC[gclknumber] = coreComponent.createKeyValueSetSymbol("GCLK_" + str(gclknumber) + "_SRC", gclkSym_num[gclknumber])
    gclkSym_GENCTRL_SRC[gclknumber].setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:GENCTRL")
    gclkSym_GENCTRL_SRC[gclknumber].setLabel("Source Selection")
    gclkSym_GENCTRL_SRC[gclknumber].addKey("OSCHF", "0", "OSCHF oscillator output")
    gclkSym_GENCTRL_SRC[gclknumber].addKey("OSC32K", "3", "32 KHz High Accuracy Internal Oscillator")
    gclkSym_GENCTRL_SRC[gclknumber].addKey("XOSC32K", "4", "32.768 KHz External Crystal Oscillator")

    gclk_in="GCLK_IN["+str(gclknumber)+"]"
    gclk_in_desc= "Generator Input Pad ("+"GCLK_IN["+str(gclknumber)+"])"

    if(gclk_io_signals[gclknumber]==True):
        gclkSym_GENCTRL_SRC[gclknumber].addKey(gclk_in, "1", gclk_in_desc)

    if gclknumber !=1:
        gclkSym_GENCTRL_SRC[gclknumber].addKey("GCLK1", "2", "GCLK Generator 1")

    gclkSym_GENCTRL_SRC[gclknumber].setDefaultValue(0)
    gclkSym_GENCTRL_SRC[gclknumber].setOutputMode("Value")
    gclkSym_GENCTRL_SRC[gclknumber].setDisplayMode("Key")

    #GCLK Generator Output Enable
    if(gclk_io_signals[gclknumber]==True):
        gclkSym_GENCTRL_OE.append(gclknumber)
        gclkSym_GENCTRL_OE[gclknumber] = coreComponent.createBooleanSymbol("GCLK_" + str(gclknumber) + "_OUTPUTENABLE", gclkSym_num[gclknumber])
        gclkSym_GENCTRL_OE[gclknumber].setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:GENCTRL")
        gclkSym_GENCTRL_OE[gclknumber].setLabel("Output GCLK clock signal on IO pin?")

    #GCLK External Clock Output frequency
    if(gclk_io_signals[gclknumber]==True):
        numPads = numPads + 1
        gclkSym_GCLK_IO_FREQ.append(gclknumber)
        gclkSym_GCLK_IO_FREQ[gclknumber] = coreComponent.createIntegerSymbol("GCLK_IO_" + str(gclknumber) +"_FREQ", gclkSym_GENCTRL_OE[gclknumber])
        gclkSym_GCLK_IO_FREQ[gclknumber].setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:GENCTRL1")
        gclkSym_GCLK_IO_FREQ[gclknumber].setLabel("External Output (GCLK_IO[" + str(gclknumber) + "]) Frequency")
        gclkSym_GCLK_IO_FREQ[gclknumber].setDefaultValue(0)
        gclkSym_GCLK_IO_FREQ[gclknumber].setReadOnly(True)
        gclkSym_GCLK_IO_FREQ[gclknumber].setDependencies(setGCLKIOFreq, ["GCLK_" + str(gclknumber) + "_FREQ", "GCLK_" + str(gclknumber) + "_OUTPUTENABLE" ])

    #GCLK Generator Output Off Value
    if(gclk_io_signals[gclknumber]==True):
        gclkSym_GENCTRL_OOV.append(gclknumber)
        gclkSym_GENCTRL_OOV[gclknumber] = coreComponent.createKeyValueSetSymbol("GCLK_" + str(gclknumber) + "_OUTPUTOFFVALUE", gclkSym_GENCTRL_OE[gclknumber])
        gclkSym_GENCTRL_OOV[gclknumber].setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:GENCTRL")
        gclkSym_GENCTRL_OOV[gclknumber].setLabel("Output Off Value")
        gclkSym_GENCTRL_OOV[gclknumber].addKey("LOW","0","Logic Level 0")
        gclkSym_GENCTRL_OOV[gclknumber].addKey("HIGH","1","Logic Level 1")
        gclkSym_GENCTRL_OOV[gclknumber].setDefaultValue(0)
        gclkSym_GENCTRL_OOV[gclknumber].setOutputMode("Key")
        gclkSym_GENCTRL_OOV[gclknumber].setDisplayMode("Description")

    gclkInFreq = coreComponent.createIntegerSymbol("GCLK_IN_" + str(gclknumber) + "_FREQ", gclkSym_num[gclknumber])
    gclkInFreq.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:GENCTRL1")
    gclkInFreq.setLabel("Gclk Input Frequency")
    gclkInFreq.setDefaultValue(0)
    gclkInFreq.setDependencies(writeEnable, ["GCLK_" + str(gclknumber) + "_OUTPUTENABLE"])

    #GCLK Generator Division Selection
    gclkSym_GENCTRL_DIVSEL.append(gclknumber)
    gclkSym_GENCTRL_DIVSEL[gclknumber] = coreComponent.createKeyValueSetSymbol("GCLK_" + str(gclknumber) + "_DIVSEL", gclkSym_num[gclknumber])
    gclkSym_GENCTRL_DIVSEL[gclknumber].setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:GENCTRL")
    gclkSym_GENCTRL_DIVSEL[gclknumber].setLabel("Divide Selection")
    gclkSymGenDivSelNode = ATDF.getNode("/avr-tools-device-file/modules/module@[name=\"GCLK\"]/value-group@[name=\"GCLK_GENCTRL__DIVSEL\"]")
    gclkSymGenDivSelNodeValues = []
    gclkSymGenDivSelNodeValues = gclkSymGenDivSelNode.getChildren()
    gclkSymGenDivSelDefaultValue = 0
    for index in range(0, len(gclkSymGenDivSelNodeValues)):
        gclkSymGenDivSelKeyName = gclkSymGenDivSelNodeValues[index].getAttribute("name")

        if (gclkSymGenDivSelKeyName == "DIV1"):
            gclkSymGenDivSelDefaultValue = index

        gclkSymGenDivSelKeyDescription = gclkSymGenDivSelNodeValues[index].getAttribute("caption")
        gclkSymGenDivSelKeyValue = gclkSymGenDivSelNodeValues[index].getAttribute("value")
        gclkSym_GENCTRL_DIVSEL[gclknumber].addKey(gclkSymGenDivSelKeyName, gclkSymGenDivSelKeyValue , gclkSymGenDivSelKeyDescription)


    gclkSym_GENCTRL_DIVSEL[gclknumber].setOutputMode("Key")
    gclkSym_GENCTRL_DIVSEL[gclknumber].setDisplayMode("Description")

    #GCLK Generator Division Factor
    gclkSym_GENCTRL_DIV.append(gclknumber)
    gclkSym_GENCTRL_DIV[gclknumber] = coreComponent.createIntegerSymbol("GCLK_" + str(gclknumber) + "_DIV", gclkSym_num[gclknumber])
    gclkSym_GENCTRL_DIV[gclknumber].setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:GENCTRL")
    gclkSym_GENCTRL_DIV[gclknumber].setLabel("Division Factor")
    gclkSym_GENCTRL_DIV[gclknumber].setMin(0)
    if (gclknumber == 1):
        gclkSym_GENCTRL_DIV[gclknumber].setMax(0xffff)
    else:
        gclkSym_GENCTRL_DIV[gclknumber].setMax(0xff)
    gclkSym_GENCTRL_DIV[gclknumber].setDefaultValue(1)
    gclkSym_GENCTRL_DIV[gclknumber].setDependencies(gclkMaxset, ["GCLK_" + str(gclknumber) + "_DIVSEL"])
    gclkSym_GENCTRL_DIVSEL[gclknumber].setDefaultValue(gclkSymGenDivSelDefaultValue)

  #GCLK Generator Division Factor to show in the UI
    gclkSym_GENCTRL_DIVIDER_VALUE.append(gclknumber)
    gclkSym_GENCTRL_DIVIDER_VALUE[gclknumber] = coreComponent.createIntegerSymbol("GCLK_" + str(gclknumber) + "_DIVIDER_VALUE", gclkSym_num[gclknumber])
    gclkSym_GENCTRL_DIVIDER_VALUE[gclknumber].setVisible(False)
    gclkSym_GENCTRL_DIVIDER_VALUE[gclknumber].setDefaultValue(1)
    gclkSym_GENCTRL_DIVIDER_VALUE[gclknumber].setDependencies(calcGclkDivider,["GCLK_" + str(gclknumber) + "_DIV", "GCLK_" + str(gclknumber) + "_DIVSEL"])

    #GCLK Generator Improve Duty Cycle
    gclkSym_GENCTRL_IDC.append(gclknumber)
    gclkSym_GENCTRL_IDC[gclknumber] = coreComponent.createBooleanSymbol("GCLK_" + str(gclknumber) + "_IMPROVE_DUTYCYCLE", gclkSym_num[gclknumber])
    gclkSym_GENCTRL_IDC[gclknumber].setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:GENCTRL")
    gclkSym_GENCTRL_IDC[gclknumber].setLabel("Enable 50/50 Duty Cycle")

    gclkSym_Freq.append(gclknumber)
    gclkSym_Freq[gclknumber]=coreComponent.createIntegerSymbol("GCLK_" + str(gclknumber) + "_FREQ", gclkSym_num[gclknumber])
    gclkSym_Freq[gclknumber].setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:GENCTRL1")
    gclkSym_Freq[gclknumber].setLabel("GCLK" + str(gclknumber) + " Clock Frequency")
    gclkSym_Freq[gclknumber].setReadOnly(True)
    if(gclknumber == 0):
        gclkSym_Freq[gclknumber].setDefaultValue(oscctrlSym_OSCHFCTRL_FRQSEL.getValue())
    else:
        gclkSym_Freq[gclknumber].setDefaultValue(0)

    depList = [ "GCLK_" + str(gclknumber) + "_DIVSEL",
                "GCLK_" + str(gclknumber) + "_DIV",
                "GCLK_" + str(gclknumber) + "_SRC",
                "GCLK_INST_NUM" + str(gclknumber),
                "OSCHF_FREQ",
                "XOSC32K_FREQ",
                "OSC32K_FREQ",
                "GCLK_IN_0_FREQ","GCLK_IN_1_FREQ","GCLK_IN_2_FREQ","GCLK_IN_3_FREQ"
                ]
    if gclknumber != 1:
        depList.append("GCLK_1_FREQ")
    gclkSym_Freq[gclknumber].setDependencies(setGClockFreq, depList)

    codeGenerationDep.append("GCLK_" + str(gclknumber) + "_SRC")
    codeGenerationDep.append("GCLK_INST_NUM" + str(gclknumber))

gclkIOpads = coreComponent.createIntegerSymbol("GCLK_NUM_PADS", None)
gclkIOpads.setVisible(False)
gclkIOpads.setDefaultValue(numPads)

maxGCLKId = 0

cycleFormed = coreComponent.createBooleanSymbol("GCLK_CYCLE_FORMED", clkMenu)
cycleFormed.setDefaultValue(False)
cycleFormed.setVisible(False)

atdfFilePath = join(Variables.get("__DFP_PACK_DIR") , "atdf" , Variables.get("__PROCESSOR") + ".atdf")

try:
    atdfFile = open(atdfFilePath, "r")
except:
    Log.writeInfoMessage("clk.py peripheral clock: Error!!! while opening atdf file")

atdfContent = ElementTree.fromstring(atdfFile.read())

# parse atdf xml file to get instance name
# for the peripheral which has gclk id
for peripheral in atdfContent.iter("module"):
    for instance in peripheral.iter("instance"):
        for param in instance.iter("param"):
            if "GCLK_ID" in param.attrib["name"]:

                indexID = param.attrib["value"]
                symbolValue = instance.attrib["name"] + param.attrib["name"].split("GCLK_ID")[1]
                symbolId = "GCLK_ID_" + str(indexID)
                indexSymbolMap[symbolId].append(symbolValue)

                if maxGCLKId < int(indexID):
                    maxGCLKId = int(indexID)


channelMap = {}
#########################################################################
#KeyValueSet symbol for UI to identify gclk IO configuration */
gclk_io_clk_ui_list_sym = coreComponent.createKeyValueSetSymbol("GCLK_IO_CLOCK_CONFIG_UI", clkMenu)
gclk_io_clk_ui_list_sym.setOutputMode("Key")
gclk_io_clk_ui_list_sym.setDisplayMode("Key")
gclk_io_clk_ui_list_sym.setVisible(False)
#####################################################################
for key in indexSymbolMap.keys():
    index=key.split("GCLK_ID_")[1]
    channelMap[int(index)]=key

for index in sorted(channelMap.iterkeys()):
    key=channelMap[index]
    name = indexSymbolMap.get(key)
    name = " ".join(name)

    gclk_io_clk_ui_list_sym.addKey(key, name , str(index))

    #GCLK Peripheral Channel Enable
    clkSymPeripheral = coreComponent.createBooleanSymbol(key + "_CHEN", gclkPeriChannel_menu)
    clkSymPeripheral.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:PCHCTRL0")
    clkSymPeripheral.setLabel("Peripheral Channel " + str(index) + " Clock Enable")
    clkSymPeripheral.setDefaultValue(False)

    #GCLK Peripheral Channel Name
    gclkSym_PERCHANNEL_NAME = coreComponent.createStringSymbol(key + "_NAME", clkSymPeripheral)
    gclkSym_PERCHANNEL_NAME.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:PCHCTRL0")
    gclkSym_PERCHANNEL_NAME.setLabel("Peripheral")
    gclkSym_PERCHANNEL_NAME.setReadOnly(True)
    gclkSym_PERCHANNEL_NAME.setDefaultValue(name)

    #GCLK Peripheral Channel Index
    gclkSym_PERCHANNEL_INDEX = coreComponent.createIntegerSymbol(key + "_INDEX", clkSymPeripheral)
    gclkSym_PERCHANNEL_INDEX.setVisible(False)
    gclkSym_PERCHANNEL_INDEX.setDefaultValue(int(index))

    #Peripheral Channel Generator Selection
    gclkSym_PCHCTRL_GEN = coreComponent.createKeyValueSetSymbol(key + "_GENSEL", clkSymPeripheral)
    gclkSym_PCHCTRL_GEN.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:PCHCTRL")
    gclkSym_PCHCTRL_GEN.setLabel("Generator Selection")

    gclkSymPCHCTRLGenNode = ATDF.getNode("/avr-tools-device-file/modules/module@[name=\"GCLK\"]/value-group@[name=\"GCLK_PCHCTRL__GEN\"]")
    gclkSymPCHCTRLGenNodeValues = []
    gclkSymPCHCTRLGenNodeValues = gclkSymPCHCTRLGenNode.getChildren()

    gclkSymPCHCTRLGenDefaultValue = 0

    for i in range(0, len(gclkSymPCHCTRLGenNodeValues)):
        gclkSymPCHCTRLGenKeyName = gclkSymPCHCTRLGenNodeValues[i].getAttribute("name")

        if (gclkSymPCHCTRLGenKeyName == "GCLK0"):
            gclkSymPCHCTRLGenDefaultValue = i

        gclkSymPCHCTRLGenKeyDescription = gclkSymPCHCTRLGenNodeValues[i].getAttribute("caption")
        ggclkSymPCHCTRLGenKeyValue = gclkSymPCHCTRLGenNodeValues[i].getAttribute("value")
        gclkSym_PCHCTRL_GEN.addKey(gclkSymPCHCTRLGenKeyName, ggclkSymPCHCTRLGenKeyValue , gclkSymPCHCTRLGenKeyDescription)

    gclkSym_PCHCTRL_GEN.setDefaultValue(gclkSymPCHCTRLGenDefaultValue)
    gclkSym_PCHCTRL_GEN.setOutputMode("Value")
    gclkSym_PCHCTRL_GEN.setDisplayMode("Key")

    gclkSym_PCHCTRL_FREQ = coreComponent.createIntegerSymbol(key + "_FREQ", clkSymPeripheral)
    gclkSym_PCHCTRL_FREQ.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:PCHCTRL0")
    gclkSym_PCHCTRL_FREQ.setLabel("Peripheral Channel " + str(index) + " Frequency ")
    gclkSym_PCHCTRL_FREQ.setReadOnly(True)
    gclkSym_PCHCTRL_FREQ.setDependencies(setPCHCTRLFREQVisibleProperty, [key + "_CHEN",key + "_GENSEL", "GCLK_0_FREQ", "GCLK_1_FREQ", "GCLK_2_FREQ", "GCLK_3_FREQ"])
    triggerdepList.append(key + "_FREQ")
    #GCLK Peripheral Channel Lock
    gclkSym_PCHCTRL_WRTLOCK = coreComponent.createBooleanSymbol(key + "_WRITELOCK", clkSymPeripheral)
    gclkSym_PCHCTRL_WRTLOCK.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:PCHCTRL")
    gclkSym_PCHCTRL_WRTLOCK.setLabel("Write Lock")

peripheralList = []
for value in indexSymbolMap.values():
    for i in range (0,len(value)):
        peripheralList.append(value[i])

# The following peripherals have APB clock but it doesn't have GCLK
peripheralApbClkList = ["AC", "ADC", "DMAC", "PTC"]
global peripheralInstanceList
peripheralInstanceList = []
for module in peripheralApbClkList:
    instances = ATDF.getNode("/avr-tools-device-file/devices/device/peripherals/module@[name=\"" + module + "\"]").getChildren()
    for instance in range (0, len(instances)):
        if instances[instance].getAttribute("name") not in peripheralList:
            peripheralList.append(instances[instance].getAttribute("name"))
            peripheralInstanceList.append(instances[instance].getAttribute("name"))

# Symbol created for UI
peripheralInstanceApbClkList = coreComponent.createComboSymbol("PERIPHERAL_APB_CLOCK_LIST", None, peripheralInstanceList)
peripheralInstanceApbClkList.setVisible(False)

peripheralList.sort()

for name in peripheralList:
    #GCLK Peripheral Channel Enable
    clkSymExtPeripheral = coreComponent.createBooleanSymbol(name + "_CLOCK_ENABLE", peripheralClockMenu)
    clkSymExtPeripheral.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:PCHCTRL0")
    clkSymExtPeripheral.setLabel(name + " Clock Enable")
    clkSymExtPeripheral.setDefaultValue(False)
    triggerdepList.append(name + "_CLOCK_ENABLE")

    clkSymExtPeripheral = coreComponent.createIntegerSymbol(name + "_CLOCK_FREQUENCY", clkSymExtPeripheral)
    clkSymExtPeripheral.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:PCHCTRL0")
    clkSymExtPeripheral.setLabel(name + " Clock Frequency")
    clkSymExtPeripheral.setReadOnly(True)
    gclkDependencyList.append(name + "_CLOCK_ENABLE")

triggerdepList.append("CPU_CLOCK_FREQUENCY")

clockTrigger = coreComponent.createBooleanSymbol("TRIGGER_LOGIC", None)
clockTrigger.setVisible(False)
clockTrigger.setDependencies(clkSetup, triggerdepList)

gclkSym_PeriIdMax = coreComponent.createIntegerSymbol("GCLK_MAX_ID", clkSymPeripheral)
gclkSym_PeriIdMax.setVisible(False)
gclkSym_PeriIdMax.setDefaultValue(int(maxGCLKId))

clkInitList = coreComponent.createListSymbol("CLK_INIT_LIST", None)

codeGenerationList = coreComponent.createListEntrySymbol("GCLK_CODE", None)
codeGenerationList.setVisible(False)
codeGenerationDep.append("GCLK_ID_0_GENSEL")
codeGenerationList.setDependencies(codeGen, codeGenerationDep)
codeGenerationList.addValue("    GCLK0_Initialize();")
codeGenerationList.setTarget("core.CLK_INIT_LIST")

################################################################################
##########              MCLK Callback Functions            #####################
################################################################################
def apbValue(symbol,event):
    global apbInit
    global mclkDic
    enable = event["value"]
    perInstance = event["id"].split("_CLOCK_ENABLE")[0]
    if "_CORE" in perInstance:
        perInstance = perInstance.split("_CORE")[0]

    if "_SLOW" in perInstance:
        return

    if "EVSYS" in perInstance:
        perInstance = perInstance.split("_")[0]
        for i in range (0,4):
            if Database.getSymbolValue("core", "EVSYS_" + str(i) + "_CLOCK_ENABLE") == True:
                enable = enable | True
                break

    for key in mclkDic.keys():
        if mclkDic.get(key) == perInstance:
            if key.startswith("APB"):
                bridge = key.split("_")[0]
                bitmask = int(key.split("_")[1])
                apbVal = int(Database.getSymbolValue("core", "MCLK_" + bridge + "_INITIAL_VALUE"),16)
                if enable == True:
                    apbVal =  apbVal | bitmask
                    Database.setSymbolValue("core", "MCLK_" + bridge + "_INITIAL_VALUE", hex(apbVal),2)
                    break
                else:
                    apbVal =  (apbVal & ~(bitmask)) | int(apbInit[bridge], 16)
                    Database.setSymbolValue("core", "MCLK_" + bridge + "_INITIAL_VALUE", hex(apbVal),2)
                    break


################################################################################
#######          MCLK Database Components            ###########################
################################################################################

global ahbInit
numAPB = 0
ahbInit = 0x0
global mclkDic
mclkDic = {}
global apbInit

ahbNode = ATDF.getNode("/avr-tools-device-file/modules/module@[name=\"MCLK\"]/register-group")
for index in range(0, len(ahbNode.getChildren())):
    if ahbNode.getChildren()[index].getAttribute("name") == "AHBMASK":
        ahbInit = hex(int(ahbNode.getChildren()[index].getAttribute("initval"),16))

#AHB Bridge Clock Initial/reset Settings
mclk_AHB_reset_Value = coreComponent.createStringSymbol("MCLK_AHB_RESET_VALUE",mclkSym_Menu)
mclk_AHB_reset_Value.setDefaultValue(str(ahbInit))
mclk_AHB_reset_Value.setVisible(False)

#AHB Bridge Clock settings which will get updated as and when components are used/removed.
# Ignore the word "INITIAL" in the symbol name
mclk_AHB_Clock_Value = coreComponent.createStringSymbol("MCLK_AHB_INITIAL_VALUE",mclkSym_Menu)
mclk_AHB_Clock_Value.setDefaultValue(str(ahbInit))
mclk_AHB_Clock_Value.setReadOnly(True)
ahbMaskNode = ATDF.getNode('/avr-tools-device-file/modules/module@[name="MCLK"]/register-group@[name="MCLK"]/register@[name="AHBMASK"]')
ahbMaskValues = ahbMaskNode.getChildren()
for index in range(0, len(ahbMaskValues)):
    mclkDic["AHB_" + str(int(ahbMaskValues[index].getAttribute("mask"),16))] = ahbMaskValues[index].getAttribute("name").split("_")[0]
    if (ahbMaskValues[index].getAttribute("name").startswith("APB")):
        numAPB = numAPB + 1

bridges = ["APBA", "APBB", "APBC"]
apbInit = {"APBA" : "",
           "APBB" : "",
           "APBC" : ""
           }
for index in range(0, numAPB):
    bridgeName = bridges[index]
    path = "/avr-tools-device-file/modules/module@[name=\"MCLK\"]/register-group@[name=\"MCLK\"]/register@[name=\"" + bridgeName + "MASK\"]"
    apbNode = ATDF.getNode(path)
    apbValues = apbNode.getChildren()
    for bitpos in range(0, len(apbValues)):
        mclkDic[bridgeName + "_" + str(int(apbValues[bitpos].getAttribute("mask"),16))] = apbValues[bitpos].getAttribute("name").split("_")[0]

    apbInitNode = ATDF.getNode("/avr-tools-device-file/modules/module@[name=\"MCLK\"]/register-group")
    for index in range(0, len(apbInitNode.getChildren())):
        if apbInitNode.getChildren()[index].getAttribute("name") == (bridgeName + "MASK"):
            apbInit[bridgeName] = hex(int(apbInitNode.getChildren()[index].getAttribute("initval"),16))

    #APB Bridge Clock Initial/reset Settings
    mclk_Clock_reset_Value = coreComponent.createStringSymbol("MCLK_" + bridgeName +"_RESET_VALUE",mclkSym_Menu)
    mclk_Clock_reset_Value.setDefaultValue(str(apbInit[bridgeName]))
    mclk_Clock_reset_Value.setVisible(False)

    #APB Bridge Clock settings which will get updated as and when components are used/removed.
    # Ignore the word "INITIAL" in the symbol name
    mclk_Clock_Value = coreComponent.createStringSymbol("MCLK_" + bridgeName +"_INITIAL_VALUE",mclkSym_Menu)
    mclk_Clock_Value.setDefaultValue(str(apbInit[bridgeName]))
    mclk_Clock_Value.setReadOnly(True)

mclk_Clock_Value.setDependencies(apbValue, gclkDependencyList)

#MCLK CPU Division
mclkSym_CPUDIV_CPUDIV = coreComponent.createKeyValueSetSymbol("CONF_CPU_CLOCK_DIVIDER",mclkSym_Menu)
mclkSym_CPUDIV_CPUDIV.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:CPUDIV")
mclkSym_CPUDIV_CPUDIV.setLabel("CPU Clock Division Factor")
mclkcpudivNode = ATDF.getNode("/avr-tools-device-file/modules/module@[name=\"MCLK\"]/value-group@[name=\"MCLK_CPUDIV__CPUDIV\"]")
mclkcpudivNodeValues = []
mclkcpudivNodeValues = mclkcpudivNode.getChildren()
mclkcpudivDefaultValue = 0

for index in range(0, len(mclkcpudivNodeValues)):
    mclkcpudivKeyName= mclkcpudivNodeValues[index].getAttribute("name")

    if (mclkcpudivKeyName == "DIV1"):
        mclkcpudivDefaultValue = index

    mclkcpudivKeyDescription = mclkcpudivNodeValues[index].getAttribute("caption")
    mclkcpudivKeyValue = mclkcpudivNodeValues[index].getAttribute("value")
    mclkSym_CPUDIV_CPUDIV.addKey(mclkcpudivKeyName, mclkcpudivKeyValue , mclkcpudivKeyDescription)

mclkSym_CPUDIV_CPUDIV.setDefaultValue(mclkcpudivDefaultValue)
mclkSym_CPUDIV_CPUDIV.setOutputMode("Value")
mclkSym_CPUDIV_CPUDIV.setDisplayMode("Key")

#MCLK Enable Clock Ready Interrupt
mclkSym_MCLK_INTENSET_CKRDY = coreComponent.createBooleanSymbol("MCLK_INTENSET_CKRDY", mclkSym_Menu)
mclkSym_MCLK_INTENSET_CKRDY.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:INTENSET")
mclkSym_MCLK_INTENSET_CKRDY.setLabel("Enable Clock Ready Interrupt")
mclkSym_MCLK_INTENSET_CKRDY.setDependencies(interruptControl, ["MCLK_INTENSET_CKRDY"])

################################################################################
#######          Calculated Clock Frequencies        ###########################
################################################################################

def setMainClockFreq(symbol, event):
    divider = int(Database.getSymbolValue("core","CONF_CPU_CLOCK_DIVIDER"))
    gclk0_freq = int(Database.getSymbolValue("core","GCLK_0_FREQ"))

    symbol.setValue(gclk0_freq / (1 << divider), 1)

def setFreq(symbol, event):
    global rtcClockSourceSelection
    src = rtcClockSourceSelection.getSelectedKey()

    freq = 0
    if src == "OSC1K":
        freq = 1024
    elif src == "OSC32K":
        freq = int(Database.getSymbolValue("core","OSC32K_FREQ"))
    elif src == "XOSC1K":
        freq = 1024
    else:
        freq = int(Database.getSymbolValue("core","XOSC32K_FREQ"))

    symbol.setValue(freq)

clkSym_MAIN_CLK_FREQ = coreComponent.createIntegerSymbol("CPU_CLOCK_FREQUENCY", calculatedFreq_Menu)
clkSym_MAIN_CLK_FREQ.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:CPUDIV")
clkSym_MAIN_CLK_FREQ.setLabel("Main Clock Frequency")
clkSym_MAIN_CLK_FREQ.setReadOnly(True)
clkSym_MAIN_CLK_FREQ.setDependencies(setMainClockFreq, ["GCLK_0_FREQ", "CONF_CPU_CLOCK_DIVIDER"])

divider = mclkSym_CPUDIV_CPUDIV.getValue()
gclk0_freq = int(gclkSym_Freq[0].getValue())
clkSym_MAIN_CLK_FREQ.setValue(gclk0_freq / (divider + 1), 1)

clkSym_WDT_CLK_FREQ = coreComponent.createIntegerSymbol("WDT_CLOCK_FREQUENCY", calculatedFreq_Menu)
clkSym_WDT_CLK_FREQ.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:%NOREGISTER%")
clkSym_WDT_CLK_FREQ.setLabel("WDT Clock Frequency")
clkSym_WDT_CLK_FREQ.setReadOnly(True)
clkSym_WDT_CLK_FREQ.setDefaultValue(1024)

clkSym_RTC_CLK_FREQ = coreComponent.createIntegerSymbol("RTC_CLOCK_FREQUENCY", calculatedFreq_Menu)
clkSym_RTC_CLK_FREQ.setHelp("atmel;device:" + Variables.get("__PROCESSOR") + ";comp:clk_pic32cm_pl10;register:%NOREGISTER%")
clkSym_RTC_CLK_FREQ.setLabel("RTC Clock Frequency")
clkSym_RTC_CLK_FREQ.setReadOnly(True)
clkSym_RTC_CLK_FREQ.setDefaultValue(1024)
clkSym_RTC_CLK_FREQ.setDependencies(setFreq, ["CONFIG_CLOCK_RTC_SRC", "OSC32K_FREQ", "XOSC32K_FREQ"])

################################################################################
###########             CODE GENERATION                     ####################
################################################################################

configName = Variables.get("__CONFIGURATION_NAME")

clockSym_OSCCTRL_HeaderFile = coreComponent.createFileSymbol("CLOCK_HEADER_FILE", None)
clockSym_OSCCTRL_HeaderFile.setSourcePath("../peripheral/clk_pic32cm_pl10/templates/plib_clock.h.ftl")
clockSym_OSCCTRL_HeaderFile.setOutputName("plib_clock.h")
clockSym_OSCCTRL_HeaderFile.setDestPath("peripheral/clock/")
clockSym_OSCCTRL_HeaderFile.setProjectPath("config/" + configName + "/peripheral/clock/")
clockSym_OSCCTRL_HeaderFile.setType("HEADER")
clockSym_OSCCTRL_HeaderFile.setMarkup(True)

clockSym_OSCCTRL_SourceFile = coreComponent.createFileSymbol("CLOCK_SOURCE_FILE", None)
clockSym_OSCCTRL_SourceFile.setSourcePath("../peripheral/clk_pic32cm_pl10/templates/plib_clock.c.ftl")
clockSym_OSCCTRL_SourceFile.setOutputName("plib_clock.c")
clockSym_OSCCTRL_SourceFile.setDestPath("peripheral/clock/")
clockSym_OSCCTRL_SourceFile.setProjectPath("config/" + configName + "/peripheral/clock/")
clockSym_OSCCTRL_SourceFile.setType("SOURCE")
clockSym_OSCCTRL_SourceFile.setMarkup(True)

clockSystemInitFile = coreComponent.createFileSymbol("CLOCK_INIT", None)
clockSystemInitFile.setType("STRING")
clockSystemInitFile.setOutputName("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_CORE")
clockSystemInitFile.setSourcePath("../peripheral/clk_pic32cm_pl10/templates/system/initialization.c.ftl")
clockSystemInitFile.setMarkup(True)

clockSystemDefFile = coreComponent.createFileSymbol("CLOCK_SYS_DEF", None)
clockSystemDefFile.setType("STRING")
clockSystemDefFile.setOutputName("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
clockSystemDefFile.setSourcePath("../peripheral/clk_pic32cm_pl10/templates/system/definitions.h.ftl")
clockSystemDefFile.setMarkup(True)
