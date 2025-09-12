import re

plib_ip_folder = "i3cc_05819"
global i3c_instance_name
i3c_instance_name = ""

def i3c_gclk_freq_get():
    global i3c_instance_name
    #Check if I3CC GCLK is enabled. If yes, read its value.
    i3cc_gclk_freq = 0

    i3cc_gclk_en = Database.getSymbolValue("core", "CLK_" + i3c_instance_name + "_GCLKEN")

    if i3cc_gclk_en == True:
        i3cc_gclk_freq = int(Database.getSymbolValue("core", i3c_instance_name + "_GCLK_FREQUENCY"))

    return i3cc_gclk_freq

def i3c_scl_lcnt_hcnt_get(freq):
    global i3c_instance_name
    lcnt = 0
    hcnt = 0
    time_period = 0

    i3c_gclk_freq = i3c_gclk_freq_get()
    scl_freq = freq

    if i3c_gclk_freq != 0 and scl_freq != None and scl_freq != 0:
        time_period = i3c_gclk_freq / scl_freq
        if time_period > 255:
            time_period = 255

        lcnt = hcnt = time_period/2

    calc_freq = (i3c_gclk_freq/time_period) if time_period > 0 else 0

    return (lcnt, hcnt, calc_freq)

def i3c_gclk_en_warning_callback(symbol, event):
    symbol.setVisible(i3c_gclk_freq_get() == 0)

def i3c_scl_freq_update(symbol_id):
    global i3c_instance_name

    ftype = ""
    scl_freq = 0

    if "OD" in symbol_id:
        ftype = "OD"
        scl_freq = Database.getSymbolValue(i3c_instance_name.lower(), "SCL_OD_FREQ")
        scl_freq = scl_freq * 1000
    elif "PP" in symbol_id:
        ftype = "PP"
        scl_freq = 12500000
    elif "FMP" in symbol_id:
        ftype = "FMP"
        scl_freq = 1000000
    elif "FM" in symbol_id:
        ftype = "FM"
        scl_freq = 400000

    scl_lcnt, scl_hcnt, calc_scl_freq = i3c_scl_lcnt_hcnt_get(scl_freq)

    return (scl_lcnt, scl_hcnt, calc_scl_freq, ftype)

def i3c_scl_freq_update_callback(symbol, event):
    global i3c_instance_name

    scl_lcnt, scl_hcnt, calc_scl_freq, ftype = i3c_scl_freq_update(symbol.getID())

    Database.setSymbolValue(i3c_instance_name.lower(), "SCL_" + ftype + "_LCNT", scl_lcnt)
    Database.setSymbolValue(i3c_instance_name.lower(), "SCL_" + ftype + "_HCNT", scl_hcnt)

    localComponent = symbol.getComponent()
    localComponent.getSymbolByID("I3C_CALC_SCL_" + ftype + "_FREQ").setLabel("Calculated SCL " + ftype + " Frequency is " + str(calc_scl_freq) + " Hz")

def i3c_calc_scl_freq(symbol_id):
    scl_lcnt, scl_hcnt, calc_scl_freq, ftype = i3c_scl_freq_update(symbol_id)
    return "Calculated SCL " + ftype + " Frequency is " + str(calc_scl_freq) + " Hz"

def i3c_peripheral_clk_config(component, enable):
    global i3c_instance_name
    Database.setSymbolValue("core", i3c_instance_name + "_CLOCK_ENABLE", enable, 2)

def i3c_interrupt_config(component, intEnable):
    int_name = component.getID().upper()

    Database.setSymbolValue( "core", int_name + "_INTERRUPT_ENABLE", intEnable, 2)
    Database.setSymbolValue( "core", int_name + "_INTERRUPT_HANDLER_LOCK", intEnable, 2)

    if intEnable == False:
        Database.setSymbolValue("core", int_name + "_INTERRUPT_HANDLER", int_name + "_Handler", 2)
    else:
        Database.setSymbolValue("core", int_name + "_INTERRUPT_HANDLER", int_name + "_InterruptHandler", 2)

def i3c_interrupt_controller_get():
    coreArch = Database.getSymbolValue("core", "CoreArchitecture")
    if "CORTEX-A" in coreArch:
        return "GIC"
    elif "CORTEX-M" in coreArch:
        return "NVIC"
    else:
        return None

def i3cSymbolsSetup(component):
    i3cSymList = [
        {
            "type": "boolean",
            "name": "I3C_NAK_HOT_JOIN_REQ",
            "label": "NAK Hot Join Request",
            "default": False,
        },
        {
            "type": "boolean",
            "name": "I2C_DEV_PRESENT",
            "label": "I2C Device Present",
            "default": True,
        },
        {
            "type": "boolean",
            "name": "IBA_INCLUDE",
            "label": "IBA Include",
            "default": False,
        },
        {
            "type": "menu",
            "name": "IBI_NOTIFY_CONTROL",
            "label": "IBI Notify Control",
        },
        {
            "type": "boolean",
            "name": "NOTIFY_REJ_IBI",
            "parent": "IBI_NOTIFY_CONTROL",
            "label": "Notify rejected IBI",
            "default": True,
        },
        {
            "type": "boolean",
            "name": "NOTIFY_REJ_CONTROLLER_REQ",
            "parent": "IBI_NOTIFY_CONTROL",
            "label": "Notify rejected Controller role request",
            "default": True,
        },
        {
            "type": "boolean",
            "name": "NOTIFY_REJ_HJ_REQ",
            "parent": "IBI_NOTIFY_CONTROL",
            "label": "Notify rejected Hot-Join request",
            "default": True,
        },
        {
            "type": "int",
            "name": "SCL_OD_FREQ",
            "label": "SCL Open Drain Frequency (kHz)",
            "min": 400,
            "max": 1000,
            "default": 400,
        },
        {
            "type": "int",
            "name": "SCL_OD_LCNT",
            "default": lambda: i3c_scl_lcnt_hcnt_get(400000)[0],
            "visible": False,
        },
        {
            "type": "int",
            "name": "SCL_OD_HCNT",
            "default": lambda: i3c_scl_lcnt_hcnt_get(400000)[1],
            "visible": False,
        },
        {
            "type": "int",
            "name": "SCL_PP_LCNT",
            "default": lambda: i3c_scl_lcnt_hcnt_get(12500000)[0],
            "visible": False,
        },
        {
            "type": "int",
            "name": "SCL_PP_HCNT",
            "default": lambda: i3c_scl_lcnt_hcnt_get(12500000)[1],
            "visible": False,
        },
        {
            "type": "int",
            "name": "SCL_FM_LCNT",
            "default": lambda: i3c_scl_lcnt_hcnt_get(400000)[0],
            "visible": False,
        },
        {
            "type": "int",
            "name": "SCL_FM_HCNT",
            "default": lambda: i3c_scl_lcnt_hcnt_get(400000)[1],
            "visible": False,
        },
        {
            "type": "int",
            "name": "SCL_FMP_LCNT",
            "default": lambda: i3c_scl_lcnt_hcnt_get(1000000)[0],
            "visible": False,
        },
        {
            "type": "int",
            "name": "SCL_FMP_HCNT",
            "default": lambda: i3c_scl_lcnt_hcnt_get(1000000)[1],
            "visible": False,
        },
        {
            "type": "string",
            "name": "INT_CONTROLLER",
            "default": lambda: i3c_interrupt_controller_get(),
            "visible": False,
        },
        {
            "type": "file",
            "filename": "plib_i3cc_host.h.ftl",
        },
        {
            "type": "file",
            "filename": "plib_i3cc_host.c.ftl",
        },
        {
            "type": "file",
            "filename": "plib_i3cc_host_common.h",
        },
        {
            "type": "system_file",
            "filename": "initialization.c.ftl",
            "outputlist": "core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_PERIPHERALS",
        },
        {
            "type": "system_file",
            "filename": "definitions.h.ftl",
            "outputlist": "core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES",
        },
        {
            "type": "comment",
            "name": "I3C_GCLK_EN_WARNING",
            "label": "!! I3CC GCLK is disabled. Enable it using the Clock configurator !!",
            "visible": i3c_gclk_freq_get() == 0,
            "dependencies": ["core." + component.getID().upper() + "_GCLK_FREQUENCY"],
            "dependencyCallback": i3c_gclk_en_warning_callback,
        },
        {
            "type": "comment",
            "name": "I3C_CALC_SCL_OD_FREQ",
            "label": lambda : i3c_calc_scl_freq("I3C_CALC_SCL_OD_FREQ"),
            "dependencies": ["SCL_OD_FREQ", "core." + component.getID().upper() + "_GCLK_FREQUENCY"],
            "dependencyCallback": i3c_scl_freq_update_callback,
        },
        {
            "type": "comment",
            "name": "I3C_CALC_SCL_PP_FREQ",
            "label": lambda : i3c_calc_scl_freq("I3C_CALC_SCL_PP_FREQ"),
            "dependencies": ["core." + component.getID().upper() + "_GCLK_FREQUENCY"],
            "dependencyCallback": i3c_scl_freq_update_callback,
        },
        {
            "type": "comment",
            "name": "I3C_CALC_SCL_FM_FREQ",
            "label": lambda : i3c_calc_scl_freq("I3C_CALC_SCL_FM_FREQ"),
            "dependencies": ["core." + component.getID().upper() + "_GCLK_FREQUENCY"],
            "dependencyCallback": i3c_scl_freq_update_callback,
        },
        {
            "type": "comment",
            "name": "I3C_CALC_SCL_FMP_FREQ",
            "label": lambda : i3c_calc_scl_freq("I3C_CALC_SCL_FMP_FREQ"),
            "dependencies": ["core." + component.getID().upper() + "_GCLK_FREQUENCY"],
            "dependencyCallback": i3c_scl_freq_update_callback,
        },

    ]

    return i3cSymList

i3cSymCreateFuncs = {
    "int": "createIntegerSymbol",
    "hex": "createHexSymbol",
    "long": "createLongSymbol",
    "boolean": "createBooleanSymbol",
    "string": "createStringSymbol",
    "comment": "createCommentSymbol",
    "combo": "createComboSymbol",
    "menu": "createMenuSymbol",
    "file": "createFileSymbol",
}

def i3cSymObjGet(symList, symName):
    symObj = None

    for sym in symList:
        if sym["name"] == symName:
            symObj = sym["obj"] if "obj" in sym else None
            break

    return symObj

def i3cCreateSymbols(component, symList):
    global i3c_instance_name
    configName = Variables.get("__CONFIGURATION_NAME")
    plib_instance = component.getID()
    plib_name = re.sub(r'\d+$', '', plib_instance) #i3cc

    for sym in symList:
        if sym["type"] == "combo":
            symObj = getattr(component, i3cSymCreateFuncs[sym["type"]])(sym["name"], i3cSymObjGet(symList, sym["parent"]) if "parent" in sym else None, sym["comboValues"])
        elif sym["type"] == "file":
            filename = sym["filename"]
            plib_mode_folder = None
            plib_mode = None
            if filename.count("_") >= 2:
                plib_mode_folder = filename.split("_", 2)[2].split(".")[0].split("_")[0]
                plib_mode = filename.split("_", 2)[2].split(".")[0]       #host, host_common
            file_extn = ".c" if ".c" in filename else ".h"                          #.c or .h

            symObj = component.createFileSymbol(filename.replace(".", "_").upper(), None)
            symObj.setSourcePath("../peripheral/" + plib_ip_folder + "/templates/" + filename)

            if plib_mode != None:
                symObj.setOutputName("plib_" + plib_instance + "_" + plib_mode + file_extn)
            else:
                symObj.setOutputName("plib_" + plib_instance + file_extn)

            if plib_mode_folder != None:
                symObj.setDestPath("peripheral/" + plib_name + "/" + plib_mode_folder + "/")
                symObj.setProjectPath("config/" + configName + "/peripheral/" + plib_name + "/" + plib_mode_folder + "/")
            else:
                symObj.setDestPath("peripheral/" + plib_name + "/")
                symObj.setProjectPath("config/" + configName + "/peripheral/" + plib_name + "/")

            symObj.setType("SOURCE" if ".c" in filename else "HEADER")
            symObj.setMarkup(True if ".ftl" in filename else False)
        elif sym["type"] == "system_file":
            filename = sym["filename"]
            symObj = component.createFileSymbol(plib_name + "_" + filename.split(".")[0].upper(), None)
            symObj.setType("STRING")
            symObj.setOutputName(sym["outputlist"])
            symObj.setSourcePath("../peripheral/" + plib_ip_folder + "/templates/system/" + filename)
            symObj.setMarkup(True if ".ftl" in filename else False)
        else:
            symObj = getattr(component, i3cSymCreateFuncs[sym["type"]])(sym["name"], i3cSymObjGet(symList, sym["parent"]) if "parent" in sym else None)

        if sym["type"] == "menu":
            menuObj = symObj
        if "default" in sym:
            value = sym["default"]
            if callable(value):
                value = value()
            symObj.setDefaultValue(value)
        if "label" in sym:
            label_val = sym["label"]
            if callable(label_val):
                label_val = label_val()
            symObj.setLabel(label_val)
        if "min" in sym:
            symObj.setMin(sym["min"])
        if "max" in sym:
            symObj.setMax(sym["max"])
        if "isReadOnly" in sym:
            symObj.setReadOnly(sym["isReadOnly"])
        if "keyValueGroups" in sym:
            for keyvalgrp in sym["keyValueGroups"]:
                symObj.addKey(keyvalgrp["key"], keyvalgrp["value"], keyvalgrp["desc"])
        if "dependencies" in sym and "dependencyCallback" in sym:
            symObj.setDependencies(sym["dependencyCallback"], sym["dependencies"])
        if "visible" in sym:
            symObj.setVisible(sym["visible"])

        sym["obj"] = symObj

def instantiateComponent(i3cComponent):
    global i3c_instance_name

    configName = Variables.get("__CONFIGURATION_NAME")

    symObj = i3cComponent.createStringSymbol((i3cComponent.getID() + "_INSTANCE_NAME").upper(), None)
    symObj.setVisible(False)
    symObj.setDefaultValue(i3cComponent.getID().upper())
    i3c_instance_name = i3cComponent.getID().upper()

    i3cSymList = i3cSymbolsSetup(i3cComponent)

    i3cCreateSymbols(i3cComponent, i3cSymList)

    #I3CC peripheral clock enable
    i3c_peripheral_clk_config(i3cComponent, True)

    #Interrupt enable
    i3c_interrupt_config(i3cComponent, True)