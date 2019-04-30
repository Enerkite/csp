/*******************************************************************************
  SYS PORTS Static Functions for PORTS System Service

  Company:
    Microchip Technology Inc.

  File Name:
    plib_pio.c

  Summary:
    PIO function implementations for the PIO PLIB.

  Description:
    The PIO PLIB provides a simple interface to manage peripheral
    input-output controller.

*******************************************************************************/

//DOM-IGNORE-BEGIN
/*******************************************************************************
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
*******************************************************************************/
//DOM-IGNORE-END

#include "plib_pio.h"



		
/* port B current number of callbacks */
uint8_t portBCurNumCb = 0;

/* port B maximum number of callbacks */
uint8_t portBMaxNumCb = 2;

/* port B callback objects */
PIO_PIN_CALLBACK_OBJ portBPinCbObj[2];


/******************************************************************************
  Function:
    PIO_Initialize ( void )

  Summary:
    Initialize the PIO library.

  Remarks:
    See plib_pio.h for more details.
*/
void PIO_Initialize ( void )
{
 /* Port B Peripheral function A configuration */
	PIOB_REGS->PIO_MSKR = 0x0L;
	PIOB_REGS->PIO_CFGR = 0x1;
	
 /* Port B Peripheral function B configuration */
	PIOB_REGS->PIO_MSKR = 0x0L;
	PIOB_REGS->PIO_CFGR = 0x2;
	
 /* Port B Peripheral function C configuration */
	PIOB_REGS->PIO_MSKR = 0x0L;
	PIOB_REGS->PIO_CFGR = 0x3;
	
 /* Port B Peripheral function D configuration */
	PIOB_REGS->PIO_MSKR = 0x0L;
	PIOB_REGS->PIO_CFGR = 0x4;
	
 /* Port B Peripheral function E configuration */
	PIOB_REGS->PIO_MSKR = 0x0L;
	PIOB_REGS->PIO_CFGR = 0x5;
	
 /* Port B Peripheral function F configuration */
	PIOB_REGS->PIO_MSKR = 0x0L;
	PIOB_REGS->PIO_CFGR = 0x6;
	
 /* Port B Peripheral function G configuration */
	PIOB_REGS->PIO_MSKR = 0x0L;
	PIOB_REGS->PIO_CFGR = 0x7;
	
 /* Port B Pin 0 configuration */
	PIOB_REGS->PIO_MSKR = 0x1;
	PIOB_REGS->PIO_CFGR |= 0x500;
	
 /* Port B Pin 9 configuration */
	PIOB_REGS->PIO_MSKR = 0x200;
	PIOB_REGS->PIO_CFGR |= 0x200;
	
 /* Port B Latch configuration */
	PIOB_REGS->PIO_SODR = 0x1;
	
 /* Port C Peripheral function A configuration */
	PIOC_REGS->PIO_MSKR = 0x0L;
	PIOC_REGS->PIO_CFGR = 0x1;
	
 /* Port C Peripheral function B configuration */
	PIOC_REGS->PIO_MSKR = 0x0L;
	PIOC_REGS->PIO_CFGR = 0x2;
	
 /* Port C Peripheral function C configuration */
	PIOC_REGS->PIO_MSKR = 0x0L;
	PIOC_REGS->PIO_CFGR = 0x3;
	
 /* Port C Peripheral function D configuration */
	PIOC_REGS->PIO_MSKR = 0x0L;
	PIOC_REGS->PIO_CFGR = 0x4;
	
 /* Port C Peripheral function E configuration */
	PIOC_REGS->PIO_MSKR = 0x0L;
	PIOC_REGS->PIO_CFGR = 0x5;
	
 /* Port C Peripheral function F configuration */
	PIOC_REGS->PIO_MSKR = 0x0L;
	PIOC_REGS->PIO_CFGR = 0x6;
	
 /* Port C Peripheral function G configuration */
	PIOC_REGS->PIO_MSKR = 0x0L;
	PIOC_REGS->PIO_CFGR = 0x7;
	
 /* Port D Peripheral function A configuration */
	PIOD_REGS->PIO_MSKR = 0x3c008L;
	PIOD_REGS->PIO_CFGR = 0x1;
	
 /* Port D Peripheral function B configuration */
	PIOD_REGS->PIO_MSKR = 0x0L;
	PIOD_REGS->PIO_CFGR = 0x2;
	
 /* Port D Peripheral function C configuration */
	PIOD_REGS->PIO_MSKR = 0x0L;
	PIOD_REGS->PIO_CFGR = 0x3;
	
 /* Port D Peripheral function D configuration */
	PIOD_REGS->PIO_MSKR = 0x0L;
	PIOD_REGS->PIO_CFGR = 0x4;
	
 /* Port D Peripheral function E configuration */
	PIOD_REGS->PIO_MSKR = 0x0L;
	PIOD_REGS->PIO_CFGR = 0x5;
	
 /* Port D Peripheral function F configuration */
	PIOD_REGS->PIO_MSKR = 0x0L;
	PIOD_REGS->PIO_CFGR = 0x6;
	
 /* Port D Peripheral function G configuration */
	PIOD_REGS->PIO_MSKR = 0x0L;
	PIOD_REGS->PIO_CFGR = 0x7;
	
 /* Port D Pin 3 configuration */
	PIOD_REGS->PIO_MSKR = 0x8;
	PIOD_REGS->PIO_CFGR |= 0x400;
	
}

// *****************************************************************************
// *****************************************************************************
// Section: PIO APIs which operates on multiple pins of a port
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* Function:
    uint32_t PIO_PortRead ( PIO_PORT port )

  Summary:
    Read all the I/O lines of the selected port.

  Description:
    This function reads the live data values on all the I/O lines of the
    selected port.  Bit values returned in each position indicate corresponding
    pin levels.
    1 = Pin is high.
    0 = Pin is low.

    This function reads the value regardless of pin configuration, whether it is
    set as as an input, driven by the PIO Controller, or driven by a peripheral.

  Remarks:
    If the port has less than 32-bits, unimplemented pins will read as
    low (0).
    Implemented pins are Right aligned in the 32-bit return value.
*/
uint32_t PIO_PortRead(PIO_PORT port)
{
    return ((pio_registers_t*)port)->PIO_PDSR;
}

// *****************************************************************************
/* Function:
    void PIO_PortWrite (PIO_PORT port, uint32_t mask, uint32_t value);

  Summary:
    Write the value on the masked I/O lines of the selected port.

  Remarks:
    See plib_pio.h for more details.
*/
void PIO_PortWrite(PIO_PORT port, uint32_t mask, uint32_t value)
{
    ((pio_registers_t*)port)->PIO_MSKR = mask;
    ((pio_registers_t*)port)->PIO_ODSR = value;
}

// *****************************************************************************
/* Function:
    uint32_t PIO_PortLatchRead ( PIO_PORT port )

  Summary:
    Read the latched value on all the I/O lines of the selected port.

  Remarks:
    See plib_pio.h for more details.
*/
uint32_t PIO_PortLatchRead(PIO_PORT port)
{
    return ((pio_registers_t*)port)->PIO_ODSR;
}

// *****************************************************************************
/* Function:
    void PIO_PortSet ( PIO_PORT port, uint32_t mask )

  Summary:
    Set the selected IO pins of a port.

  Remarks:
    See plib_pio.h for more details.
*/
void PIO_PortSet(PIO_PORT port, uint32_t mask)
{
    ((pio_registers_t*)port)->PIO_SODR = mask;
}

// *****************************************************************************
/* Function:
    void PIO_PortClear ( PIO_PORT port, uint32_t mask )

  Summary:
    Clear the selected IO pins of a port.

  Remarks:
    See plib_pio.h for more details.
*/
void PIO_PortClear(PIO_PORT port, uint32_t mask)
{
    ((pio_registers_t*)port)->PIO_CODR = mask;
}

// *****************************************************************************
/* Function:
    void PIO_PortToggle ( PIO_PORT port, uint32_t mask )

  Summary:
    Toggles the selected IO pins of a port.

  Remarks:
    See plib_pio.h for more details.
*/
void PIO_PortToggle(PIO_PORT port, uint32_t mask)
{
    /* Write into Clr and Set registers */
    ((pio_registers_t*)port)->PIO_MSKR = mask;
    ((pio_registers_t*)port)->PIO_ODSR ^= mask;
}

// *****************************************************************************
/* Function:
    void PIO_PortInputEnable ( PIO_PORT port, uint32_t mask )

  Summary:
    Enables selected IO pins of a port as input.

  Remarks:
    See plib_pio.h for more details.
*/
void PIO_PortInputEnable(PIO_PORT port, uint32_t mask)
{
    ((pio_registers_t*)port)->PIO_MSKR = mask;
    ((pio_registers_t*)port)->PIO_CFGR &= ~(1 << PIO_CFGR_DIR_Pos);	
}

// *****************************************************************************
/* Function:
    void PIO_PortOutputEnable ( PIO_PORT port, uint32_t mask )

  Summary:
    Enables selected IO pins of a port as output(s).

  Remarks:
    See plib_pio.h for more details.
*/
void PIO_PortOutputEnable(PIO_PORT port, uint32_t mask)
{
    ((pio_registers_t*)port)->PIO_MSKR = mask;
    ((pio_registers_t*)port)->PIO_CFGR |= (1 << PIO_CFGR_DIR_Pos);
}

// *****************************************************************************
/* Function:
    void PIO_PortInterruptEnable(PIO_PORT port, uint32_t mask)

  Summary:
    Enables IO interrupt on selected IO pins of a port.

  Remarks:
    See plib_pio.h for more details.
*/
void PIO_PortInterruptEnable(PIO_PORT port, uint32_t mask)
{
    ((pio_registers_t*)port)->PIO_IER = mask;
}

// *****************************************************************************
/* Function:
    void PIO_PortInterruptDisable(PIO_PORT port, uint32_t mask)

  Summary:
    Disables IO interrupt on selected IO pins of a port.

  Remarks:
    See plib_pio.h for more details.
*/
void PIO_PortInterruptDisable(PIO_PORT port, uint32_t mask)
{
    ((pio_registers_t*)port)->PIO_IDR = mask;
}

// *****************************************************************************
// *****************************************************************************
// Section: PIO APIs which operates on one pin at a time
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* Function:
    void PIO_PinInterruptCallbackRegister(
        PIO_PIN pin,
        const PIO_PIN_CALLBACK callback,
        uintptr_t context
    );

  Summary:
    Allows application to register callback for every pin.

  Remarks:
    See plib_pio.h for more details.
*/
void PIO_PinInterruptCallbackRegister(
    PIO_PIN pin,
    const PIO_PIN_CALLBACK callback,
    uintptr_t context
)
{
    uint8_t portIndex;
    portIndex = pin >> 5;

    switch( portIndex )
    {
        case 1:
        {
            if( portBCurNumCb < portBMaxNumCb )
            {
                portBPinCbObj[ portBCurNumCb ].pin   = pin;
                portBPinCbObj[ portBCurNumCb ].callback = callback;
                portBPinCbObj[ portBCurNumCb ].context  = context;
                portBCurNumCb++;
            }
            break;
        }
        default:
        {
            break;
        }
    }
}

// *****************************************************************************
// *****************************************************************************
// Section: Interrupt Service Routine (ISR) Implementation(s)
// *****************************************************************************
// *****************************************************************************

// *****************************************************************************
/* Function:
    void PIOB_InterruptHandler (void)

  Summary:
    Interrupt handler for PORTB.

  Description:
    This function defines the Interrupt service routine for PORTB.
    This is the function which by default gets into Interrupt Vector Table.

  Remarks:
    User should not call this function.
*/
void PIOB_InterruptHandler(void)
{
    uint32_t status;
    uint8_t i;

    status  = PIOB_REGS->PIO_ISR;
    status &= PIOB_REGS->PIO_IMR;
	
	for( i = 0; i < portBCurNumCb; i++ )
	{
		if( ( status & ( 1 << (portBPinCbObj[i].pin & 0x1F) ) ) &&
			portBPinCbObj[i].callback != NULL )
		{
			portBPinCbObj[i].callback ( portBPinCbObj[i].pin, portBPinCbObj[i].context );
		}
	}
}



/*******************************************************************************
 End of File
*/
