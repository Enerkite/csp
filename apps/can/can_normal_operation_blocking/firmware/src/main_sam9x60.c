/*******************************************************************************
  Main Source File

  Company:
    Microchip Technology Inc.

  File Name:
    main.c

  Summary:
    This file contains the "main" function for a project.

  Description:
    This file contains the "main" function for a project.  The
    "main" function calls the "SYS_Initialize" function to initialize the state
    machines of all modules in the system
 *******************************************************************************/

/*******************************************************************************
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
*******************************************************************************/

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include <stddef.h>                     // Defines NULL
#include <stdbool.h>                    // Defines true
#include <stdlib.h>                     // Defines EXIT_FAILURE
#include "definitions.h"                // SYS function prototypes

/* LED Toggle */
#define LED_Toggle() LED_GREEN_Toggle()

void print_menu(void)
{
    printf(" ------------------------------ \r\n");   
    printf(" Press '1' to Transmit message \r\n");
    printf(" Press '2' to Receive message \r\n");
}

// *****************************************************************************
// *****************************************************************************
// Section: Main Entry Point
// *****************************************************************************
// *****************************************************************************

int main ( void )
{
    uint8_t user_input = 0;
    uint32_t messageID = 0;
    uint8_t message[8];
    uint8_t messageLength = 0;
    uint32_t status = 0;
    
    uint8_t rx_message[8];
    uint32_t rx_messageID = 0;
    uint8_t rx_messageLength = 0;
    
    /* Initialize all modules */
    SYS_Initialize ( NULL );

    LED_RED_Clear();
    LED_GREEN_Clear();
    LED_BLUE_Clear();

    printf(" ------------------------------ \r\n");
    printf("            CAN Demo            \r\n");
    printf(" ------------------------------ \r\n");
    
    print_menu();
    
    /* Prepare the message to send*/
    messageID = 0x469;
    messageLength = 8;
    for (uint8_t count = 8; count >=1; count--){
        message[count - 1] = count;
    }
    
    while ( true )
    {
        /* Maintain state machines of all polled Harmony modules. */
        scanf("%c", (char *) &user_input);
        
        switch (user_input)
        {
            case '1': 
                printf(" Transmitting Message:");
                if (CAN1_MessageTransmit(messageID, messageLength, message, CAN_MAILBOX_DATA_FRAME_TX) == true)
                {    
                    printf("Success \r\n");
                    LED_Toggle();
                }
                else
                {
                    printf("Failed \r\n");
                }             
                break;
            case '2':
                printf(" Waiting for message: \r\n");
                while (true)
                {
                    if (CAN1_InterruptGet(CAN_INTERRUPT_MB1_MASK))
                    {
                        /* Check CAN Status */
                        status = CAN1_ErrorGet();

                        if ((status & (CAN_ERROR_BOFF | CAN_ERROR_CERR |
                                        CAN_ERROR_SERR | CAN_ERROR_AERR |
                                        CAN_ERROR_FERR | CAN_ERROR_BERR)) == CAN_ERROR_NONE)
                        {
                            memset(rx_message, 0x00, sizeof(rx_message));
                            
                            /* Receive New Message */
                            if (CAN1_MessageReceive(&rx_messageID, &rx_messageLength, rx_message, 0, CAN_MAILBOX_DATA_FRAME_RX_OVERWRITE) == true)  
                            {
                                printf(" New Message Received    \r\n");
                                status = CAN1_ErrorGet();
                                if ((status & (CAN_ERROR_BOFF | CAN_ERROR_CERR |
                                               CAN_ERROR_SERR | CAN_ERROR_AERR |
                                               CAN_ERROR_FERR | CAN_ERROR_BERR)) == CAN_ERROR_NONE)
                                {
                                    /* Print message to Console */
                                    uint8_t length = rx_messageLength;
                                    printf(" Message - ID : 0x%x Length : 0x%x ", (unsigned int) rx_messageID,(unsigned int) rx_messageLength);
                                    printf("Message : ");
                                    while(length)
                                    {
                                        printf("0x%x ", rx_message[rx_messageLength - length--]);
                                    }
                                    printf("\r\n");
                                    LED_Toggle();
                                    break;
                                }
                                else
                                {
                                    printf("Error in received message");
                                }
                            }
                            else
                            {
                                printf("Message Reception Failed \r");
                            }
                        }
                        else
                        {
                            printf("Error in last received message");
                        }
                    }
                }
                break;
            default:
                printf(" Invalid Input \r\n");
                break;
        }
        
        print_menu();
        
    }

    /* Execution should not come here during normal operation */

    return ( EXIT_FAILURE );
}


/*******************************************************************************
 End of File
*/
