# coding: utf-8
"""
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
"""

import inspect
import sys
import os

import __builtin__  # Import built-in namespace (Python 2.x style)

from os import pardir
from os.path import join, abspath, dirname, normpath

# Make Database and Log globally available in the built-in namespace
__builtin__.Database = Database
__builtin__.Log = Log

# Ensure __file__ is defined, even if running in an environment where it isn't
if '__file__' not in locals():
    __file__ = normpath(abspath(inspect.currentframe().f_code.co_filename))

# Add the 'py_packages' directory (four levels up) to sys.path for module imports
sys.path.append(normpath(join(__file__, pardir, pardir, pardir, pardir, 'py_packages')))

# List of available high temperature threshold values (in Celsius)
TPMH_THRESHOLD_VALUES = ["105", "120"]

def create_ui(component):
    """
    Creates the user interface symbols for the Low and High Temperature Monitor Protection.
    """
    # --- Low Temperature Monitor Protection (TPML) ---
    tpml_menu = component.createMenuSymbol("tpml_menu", None)
    tpml_menu.setLabel("Low Temperature Monitor Protection")
    tpml_menu.setDescription("Configure the Low Temperature Monitor Protection")

    tpml_backup_enable = component.createBooleanSymbol("tpml_backup_enable", tpml_menu)
    tpml_backup_enable.setLabel("Enable in Backup operating mode")
    tpml_backup_enable.setDefaultValue(False)

    tpml_backup_enable_wakeup = component.createBooleanSymbol("tpml_backup_enable_wakeup", tpml_backup_enable)
    tpml_backup_enable_wakeup.setLabel("Enable wake-up")
    tpml_backup_enable_wakeup.setDefaultValue(False)
    tpml_backup_enable_wakeup.setReadOnly(True)
    # Make 'Enable wake-up' editable only if 'Enable in Backup operating mode' is checked
    tpml_backup_enable_wakeup.setDependencies(
        lambda symbol, event: symbol.setReadOnly(not event["value"]), ["tpml_backup_enable"]
    )

    tpml_normal_enable = component.createBooleanSymbol("tpml_normal_enable", tpml_menu)
    tpml_normal_enable.setLabel("Enable in Normal operating mode")
    tpml_normal_enable.setDefaultValue(False)

    tpml_normal_enable_interrupt = component.createBooleanSymbol("tpml_normal_enable_interrupt", tpml_normal_enable)
    tpml_normal_enable_interrupt.setLabel("Enable interrupt")
    tpml_normal_enable_interrupt.setDefaultValue(False)
    tpml_normal_enable_interrupt.setReadOnly(True)
    # Make 'Enable interrupt' editable only if 'Enable in Normal operating mode' is checked
    tpml_normal_enable_interrupt.setDependencies(
        lambda symbol, event: symbol.setReadOnly(not event["value"]), ["tpml_normal_enable"]
    )

    # --- High Temperature Monitor Protection (TPMH) ---
    tpmh_menu = component.createMenuSymbol("tpmh_menu", None)
    tpmh_menu.setLabel("High Temperature Monitor Protection")
    tpmh_menu.setDescription("Configure the High Temperature Monitor Protection")

    tpmh_threshold_value = component.createComboSymbol("tpmh_threshold_value", tpmh_menu, TPMH_THRESHOLD_VALUES)
    tpmh_threshold_value.setLabel("High temperature threshold (in Celsius degree)")
    tpmh_threshold_value.setDefaultValue(TPMH_THRESHOLD_VALUES[0])

    tpmh_backup_enable = component.createBooleanSymbol("tpmh_backup_enable", tpmh_menu)
    tpmh_backup_enable.setLabel("Enable in Backup operating mode")
    tpmh_backup_enable.setDefaultValue(False)

    tpmh_backup_enable_wakeup = component.createBooleanSymbol("tpmh_backup_enable_wakeup", tpmh_backup_enable)
    tpmh_backup_enable_wakeup.setLabel("Enable wake-up")
    tpmh_backup_enable_wakeup.setDefaultValue(False)
    tpmh_backup_enable_wakeup.setReadOnly(True)
    # Make 'Enable wake-up' editable only if 'Enable in Backup operating mode' is checked
    tpmh_backup_enable_wakeup.setDependencies(
        lambda symbol, event: symbol.setReadOnly(not event["value"]), ["tpmh_backup_enable"]
    )

    tpmh_normal_enable = component.createBooleanSymbol("tpmh_normal_enable", tpmh_menu)
    tpmh_normal_enable.setLabel("Enable in Normal operating mode")
    tpmh_normal_enable.setDefaultValue(False)

    tpmh_normal_enable_interrupt = component.createBooleanSymbol("tpmh_normal_enable_interrupt", tpmh_normal_enable)
    tpmh_normal_enable_interrupt.setLabel("Enable interrupt")
    tpmh_normal_enable_interrupt.setDefaultValue(False)
    tpmh_normal_enable_interrupt.setReadOnly(True)
    # Make 'Enable interrupt' editable only if 'Enable in Normal operating mode' is checked
    tpmh_normal_enable_interrupt.setDependencies(
        lambda symbol, event: symbol.setReadOnly(not event["value"]), ["tpmh_normal_enable"]
    )

    # Option to enable UNIT TESTS
    secumod_unittest = component.createBooleanSymbol("secumod_unittest", None)
    secumod_unittest.setLabel("Add secumod Unit Tests")
    secumod_unittest.setDefaultValue(False)
    secumod_unittest.setDescription("Add all functions needed for unit tests.")

def create_files(component):
    """
    Creates the necessary header and source files, and adds them to the project.
    """
    dst_path = join("peripheral", "secumod")
    prj_path = join("config", Variables.get("__CONFIGURATION_NAME"), dst_path)

    # Create header file symbol for the peripheral
    header_file = component.createFileSymbol("LIB_SECUMOD_HEADER", None)
    header_file.setMarkup(True)
    header_file.setSourcePath("../peripheral/secumod_44180/templates/plib_secumod.h.ftl")
    header_file.setOutputName("plib_secumod.h")
    header_file.setDestPath(dst_path)
    header_file.setProjectPath(prj_path)
    header_file.setType("HEADER")
    header_file.setOverwrite(True)

    # Create source file symbol for the peripheral
    source_file = component.createFileSymbol("LIB_SECUMOD_SOURCE", None)
    source_file.setMarkup(True)
    source_file.setSourcePath("../peripheral/secumod_44180/templates/plib_secumod.c.ftl")
    source_file.setOutputName("plib_secumod.c")
    source_file.setDestPath(dst_path)
    source_file.setProjectPath(prj_path)
    source_file.setType("SOURCE")
    source_file.setOverwrite(True)

    # Add header include to system definitions
    inc_def_file = component.createListEntrySymbol("LIB_SECUMOD_SYS_DEF_INC", None)
    inc_def_file.setTarget("core.LIST_SYSTEM_DEFINITIONS_H_INCLUDES")
    inc_def_file.addValue('#include "peripheral/secumod/plib_secumod.h"')
    inc_def_file.setVisible(False)

    # Add initialization call to system init
    inc_init_file = component.createListEntrySymbol("SECUMOD_SYS_INT", None)
    inc_init_file.setTarget("core.LIST_SYSTEM_INIT_C_SYS_INITIALIZE_PERIPHERALS")
    inc_init_file.addValue('    SECUMOD_Initialize();')
    inc_init_file.setVisible(False)

def before_destroy():
    """
    Performs cleanup before the component is destroyed, such as disabling interrupts.
    """
    comp = Database.getComponentByID("core")
    if comp is not None:
        sym = comp.getSymbolByID("SECUMOD_INTERRUPT_ENABLE")
        if sym is not None:
            sym.setValue(False)

def instantiateComponent(component):
    """
    Called by the framework to instantiate the component.
    """
    create_ui(component)
    create_files(component)

def finalizeComponent(component):
    """
    Called by the framework to finalize the component (if needed).
    """
    pass  # Add any finalization logic if needed

def destroyComponent(component):
    """
    Called by the framework to destroy the component and perform cleanup.
    """
    before_destroy()
