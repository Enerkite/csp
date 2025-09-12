/*******************************************************************************
  Inter-Integrated Circuit (I3C) Host/Controller Library
  Instance Header File

  Company
    Microchip Technology Inc.

  File Name
    plib_i3cc_host_common.h

  Summary
    I3CC peripheral library host/controller mode common interface.

  Description
    This file defines the interface to the I3CC host/controller peripheral library. 
    This library provides access to and control of the associated peripheral
    instance.

  Remarks:

*******************************************************************************/

// DOM-IGNORE-BEGIN
/*******************************************************************************
* Copyright (C) 2024-2025 Microchip Technology Inc. and its subsidiaries.
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
// DOM-IGNORE-END

#ifndef PLIB_I3CC_HOST_COMMON_H
#define PLIB_I3CC_HOST_COMMON_H

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include "device.h"

// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility

    extern "C" {

#endif
// DOM-IGNORE-END

#define MAX_XFER_QUEUE_SIZE         16
#define MAX_IBI_PAYLOAD             256
#define MAX_SCRATCH_BUFFER_SIZE     16
#define I3C_XFER_ID_INVALID         -1
        
typedef enum
{
    I3C_EVENT_DEVICE_DISCOVERY,
    I3C_EVENT_XFER_DONE_BROADCAST_CCC,
    I3C_EVENT_XFER_DONE_DIRECTED_CCC_READ,
    I3C_EVENT_XFER_DONE_DIRECTED_CCC_WRITE,
    I3C_EVENT_XFER_DONE_PRIVATE_READ,
    I3C_EVENT_XFER_DONE_PRIVATE_WRITE,    
    I3C_EVENT_IBI,
    I3C_EVENT_HOT_JOIN,
    I3C_EVENT_NONE,
            
}I3C_EVENT;
        

typedef void (*I3C_CALLBACK)(I3C_EVENT event, void* pEventData);
typedef uint16_t I3C_XFER_ID;


typedef enum
{
    IBI_STATUS_ACK,
    IBI_STATUS_NAK_AUTO_DISABLED,
            
}IBI_STATUS;

typedef enum
{
    I3C_CMD_DESC_TYPE_ADDR_ASSIGN = 0x02,
    I3C_CMD_DESC_TYPE_IMMEDIATE_XFER = 0x01,
    I3C_CMD_DESC_TYPE_RGLR_DATA_XFER = 0x00,
    I3C_CMD_DESC_TYPE_COMBO_XFER = 0x03,
    I3C_CMD_DESC_TYPE_INTERNAL_CTRL = 0x7
        
}I3C_CMD_DESC_TYPE;

typedef enum
{
   I3C_CCC_ENEC_B       = 0x00,   /**< Enable Events Command */
   I3C_CCC_DISEC_B      = 0x01,   /**< Disable Events Command */
   I3C_CCC_ENTAS0_B     = 0x02,   /**< Enter Activity State 0 */
   I3C_CCC_ENTAS1_B     = 0x03,   /**< Enter Activity State 1 */
   I3C_CCC_ENTAS2_B     = 0x04,   /**< Enter Activity State 2 */
   I3C_CCC_ENTAS3_B     = 0x05,   /**< Enter Activity State 3 */
   I3C_CCC_RSTDAA_B     = 0x06,   /**< Reset Dynamic Address Assignment */
   I3C_CCC_ENTDAA_B     = 0x07,   /**< Enter Dynamic Address Assignment */
   I3C_CCC_DEFTGTS_B    = 0x08,   /**< Define List of Targets */
   I3C_CCC_SETMWL_B     = 0x09,   /**< Set Max Write Length */
   I3C_CCC_SETMRL_B     = 0x0A,   /**< Set Max Read Length */
   I3C_CCC_ENTTM_B      = 0x0B,   /**< Enter Test Mode */
   I3C_CCC_SETBUSCON_B  = 0x0C,   /**< Set Bus Context */
   I3C_CCC_ENDXFER_B    = 0x12,   /**< Data Transfer Ending Procedure Control */
   I3C_CCC_ENTHDR0_B    = 0x20,   /**< Enter HDR Mode 0 */
   I3C_CCC_ENTHDR1_B    = 0x21,   /**< Enter HDR Mode 1 */
   I3C_CCC_ENTHDR2_B    = 0x22,   /**< Enter HDR Mode 2 */
   I3C_CCC_ENTHDR3_B    = 0x23,   /**< Enter HDR Mode 3 */
   I3C_CCC_ENTHDR4_B    = 0x24,   /**< Enter HDR Mode 4 */
   I3C_CCC_ENTHDR5_B    = 0x25,   /**< Enter HDR Mode 5 */
   I3C_CCC_ENTHDR6_B    = 0x26,   /**< Enter HDR Mode 6 */
   I3C_CCC_ENTHDR7_B    = 0x27,   /**< Enter HDR Mode 7 */
   I3C_CCC_SETXTIME_B   = 0x28,   /**< Exchange Timing Information */
   I3C_CCC_SETAASA_B    = 0x29,   /**< Set All Addresses to Static Addresses */
   I3C_CCC_RSTACT_B     = 0x2A,   /**< Target Reset Action */
   I3C_CCC_DEFGRPA_B    = 0x2B,   /**< Define List of Group Address */
   I3C_CCC_RSTGRPA_B    = 0x2C,   /**< Reset Group Address  */
   I3C_CCC_MLANE_B      = 0x2D,   /**< Multi-Lane Data Transfer Control */
   I3C_CCC_DBGACTION_B  = 0x58,   /**< Debug Action (Debug Specific command)*/
   I3C_CCC_SETHID_B     = 0x61,   /**< Hub updates 3-bit HID field (JEDEC Specific command)*/
   I3C_CCC_DEVCTRL_B    = 0x62,   /**< Configure hub and all devices behind hub (JEDEC Specific command)*/
	
   I3C_CCC_ENEC_D       = 0x80,   /**< Enable Events Command */
   I3C_CCC_DISEC_D      = 0x81,   /**< Disable Events Command  */
   I3C_CCC_ENTAS0_D     = 0x82,   /**< Enter Activity State 0 */
   I3C_CCC_ENTAS1_D     = 0x83,   /**< Enter Activity State 1 */
   I3C_CCC_ENTAS2_D     = 0x84,   /**< Enter Activity State 2 */
   I3C_CCC_ENTAS3_D     = 0x85,   /**< Enter Activity State 3 */
   I3C_CCC_RSTDAA_D     = 0x86,   /**< Reset Dynamic Address Assignment */
   I3C_CCC_SETDASA_D    = 0x87,   /**< Set Dynamic Address from Static Address */
   I3C_CCC_SETNEWDA_D   = 0x88,   /**< Set New Dynamic Address */
   I3C_CCC_SETMWL_D     = 0x89,   /**< Set Max Write Length */
   I3C_CCC_SETMRL_D     = 0x8A,   /**< Set Max Read Length */
   I3C_CCC_GETMWL_D     = 0x8B,   /**< Get Max Write Length */
   I3C_CCC_GETMRL_D     = 0x8C,   /**< Get Max Read Length */
   I3C_CCC_GETPID_D     = 0x8D,   /**< Get Provisioned ID */
   I3C_CCC_GETBCR_D     = 0x8E,   /**< Get Bus Characteristics Register  */
   I3C_CCC_GETDCR_D     = 0x8F,   /**< Get Device Characteristics Register */
   I3C_CCC_GETSTATUS_D  = 0x90,   /**< Get Device Status */
   I3C_CCC_GETACCCR_D   = 0x91,   /**< Get Accept Controller Role */
   I3C_CCC_ENDXFER_D    = 0x92,   /**< Data Transfer Ending Procedure Control */
   I3C_CCC_SETBRGTGT_D  = 0x93,   /**< Set Bridge Targets */
   I3C_CCC_GETMXDS_D    = 0x94,   /**< Get Max Data Speed */
   I3C_CCC_GETCAPS_D    = 0x95,   /**< Get Optional Feature Capabilities */
   I3C_CCC_SETROUTE_D   = 0x96,   /**< Set Route */
   I3C_CCC_D2DXFER_D    = 0x97,   /**< Device to Device(s) Tunneling Control */
   I3C_CCC_SETXTIME_D   = 0x98,   /**< Set Exchange Timing Information */
   I3C_CCC_GETXTIME_D   = 0x99,   /**< Get Exchange Timing Information */
   I3C_CCC_RSTACT_D     = 0x9A,   /**< Target Reset Action */
   I3C_CCC_SETGRPA_D    = 0x9B,   /**< Set Group Address */
   I3C_CCC_RSTGRPA_D    = 0x9C,   /**< Reset Group Address */
   I3C_CCC_MLANE_D      = 0x9D,   /**< Multi-Lane Data Transfer Control */
   I3C_CCC_DBGOPCODE_D  = 0xD7,   /**< Debug Network Adaptor Operation (Debug Specific command)*/
   I3C_CCC_DBGACTION_D  = 0xD8,   /**< Debug Action (Debug Specific command)*/ 
   I3C_CCC_DEVCAPS_D    = 0xE0,    /**< Get device capabilities (JEDEC Specific command) */ 
   I3C_CCC_NONE = -1,
}I3C_CCC;

typedef enum
{
    TARGET_DEVICE_TYPE_I3C = 0,
    TARGET_DEVICE_TYPE_I2C,
}TARGET_DEVICE_TYPE;

typedef enum
{
    DAT_TABLE_DEV_TYPE_I3C = 0,
    DAT_TABLE_DEV_TYPE_I2C,
}DAT_TABLE_DEV_TYPE;

typedef enum
{
    DAT_TABLE_ENTRY_TYPE_I3C,
    DAT_TABLE_ENTRY_TYPE_I2C,
    DAT_TABLE_ENTRY_TYPE_ALL
}DAT_TABLE_ENTRY_TYPE;

typedef enum
{
    I3C_XFER_MODE_I3C_SDR0 = 0,     //12.5 MHz
    I3C_XFER_MODE_I3C_SDR1 = 1,     //8 MHz
    I3C_XFER_MODE_I3C_SDR2 = 2,     //6 MHz
    I3C_XFER_MODE_I3C_SDR3 = 3,     //4 MHz
    I3C_XFER_MODE_I3C_SDR4 = 4,     //2 MHz
    I3C_XFER_MODE_I3C_HDR_TSX = 5,    
    I3C_XFER_MODE_I3C_HDR_DDR = 6,    
    I3C_XFER_MODE_I3C_RESERVED = 7,    
    
    I3C_XFER_MODE_I2C_FM = 0,
    I3C_XFER_MODE_I2C_FMP = 1,
    I3C_XFER_MODE_I2C_UDR1 = 2,
    I3C_XFER_MODE_I2C_UDR2 = 3,
    I3C_XFER_MODE_I2C_UDR3 = 4,
    
}I3C_XFER_MODE;

typedef enum
{
    I3C_XFER_OFFSET_LEN_8BIT = 0,
    I3C_XFER_OFFSET_LEN_16BIT = 1,
            
}I3C_XFER_OFFSET_LEN;


#define DAT_TABLE_DEV_TYPE_I2C  1
#define DAT_TABLE_DEV_TYPE_I3C  0

#define MAX_TARGET_DEV_SUPPORTED    5       //This number should be less than or equal to the number of DAT Table entries available.

typedef enum
{
    I3C_XFER_DIR_WR = 0,
    I3C_XFER_DIR_RD = 1,
}I3C_XFER_DIR;

typedef enum
{
    I3C_QUEUE_TYPE_COMMAND,
    I3C_QUEUE_TYPE_RESPONSE,
    I3C_QUEUE_TYPE_DATA,
    I3C_QUEUE_TYPE_IBI,
}I3C_QUEUE_TYPE;

typedef enum
{
    I3C_QUEUE_RESET_COMMAND = I3CC_RESET_CONTROL_CMD_QUEUE_RST_Msk,
    I3C_QUEUE_RESET_RESPONSE = I3CC_RESET_CONTROL_RESP_QUEUE_RST_Msk,
    I3C_QUEUE_RESET_TX = I3CC_RESET_CONTROL_TX_FIFO_RST_Msk,
    I3C_QUEUE_RESET_RX = I3CC_RESET_CONTROL_RX_FIFO_RST_Msk,
    I3C_QUEUE_RESET_IBI = I3CC_RESET_CONTROL_IBI_QUEUE_RST_Msk,
    I3C_QUEUE_RESET_ALL_QUEUES = (I3CC_RESET_CONTROL_Msk & ~I3CC_RESET_CONTROL_SOFT_RST_Msk),
}I3C_QUEUE_RESET;

typedef enum
{
    I3C_QUEUE_LVL_COMMAND_FREE_CNT,
    I3C_QUEUE_LVL_RESPONSE_CNT,
    I3C_QUEUE_LVL_IBI_BUF_CNT,
    I3C_QUEUE_LVL_IBI_STATUS_CNT,
    I3C_QUEUE_LVL_TX_BUF_FREE_CNT,
    I3C_QUEUE_LVL_RX_BUF_CNT,
}I3C_QUEUE_LVL;

typedef enum
{
    I3C_QUEUE_THLD_CMD_EMPTY, //Interrupt is issued when command queue contains at least N empty entries.
    I3C_QUEUE_THLD_RESPONSE_READY, //Interrupt is triggered when response queue contains at least N+1 entries (32-bit word).
    I3C_QUEUE_THLD_TX_BUFFER_FREE,    //min number of available transmit FIFO entries that triggers the TX_THLD_STAT interrupt.
    I3C_QUEUE_THLD_RX_BUFFER_AVAILABLE,    //min number of receive FIFO entries that triggers the RX_THLD_STAT interrupt.
    I3C_QUEUE_THLD_TX_START,
    I3C_QUEUE_THLD_RX_START,
    I3C_QUEUE_THLD_IBI_STATUS,
    I3C_QUEUE_THLD_IBI_DATA_SIZE,
}I3C_QUEUE_THLD;

typedef enum
{
    I3C_QUEUE_THLD_TX_BUFFER_FREE_1_DWORD,
    I3C_QUEUE_THLD_TX_BUFFER_FREE_4_DWORD,
    I3C_QUEUE_THLD_TX_BUFFER_FREE_8_DWORD,
    I3C_QUEUE_THLD_TX_BUFFER_FREE_16_DWORD,
    I3C_QUEUE_THLD_TX_BUFFER_FREE_32_DWORD,
    I3C_QUEUE_THLD_TX_BUFFER_FREE_64_DWORD,
}I3C_QUEUE_THLD_TX_BUFFER;

typedef enum
{
    I3C_QUEUE_THLD_RX_BUFFER_AVAIL_1_DWORD,
    I3C_QUEUE_THLD_RX_BUFFER_AVAIL_4_DWORD,
    I3C_QUEUE_THLD_RX_BUFFER_AVAIL_8_DWORD,
    I3C_QUEUE_THLD_RX_BUFFER_AVAIL_16_DWORD,
    I3C_QUEUE_THLD_RX_BUFFER_AVAIL_32_DWORD,
    I3C_QUEUE_THLD_RX_BUFFER_AVAIL_64_DWORD,
}I3C_QUEUE_THLD_RX_BUFFER;

typedef enum
{
    I3C_QUEUE_THLD_LVL_RX_START_1_DWORD,
    I3C_QUEUE_THLD_LVL_RX_START_4_DWORD,
    I3C_QUEUE_THLD_LVL_RX_START_8_DWORD,
    I3C_QUEUE_THLD_LVL_RX_START_16_DWORD,
    I3C_QUEUE_THLD_LVL_RX_START_32_DWORD,
    I3C_QUEUE_THLD_LVL_RX_START_64_DWORD,
}I3C_QUEUE_THLD_LVL_RX_START;

typedef enum
{
    I3C_QUEUE_THLD_LVL_TX_START_1_DWORD,
    I3C_QUEUE_THLD_LVL_TX_START_4_DWORD,
    I3C_QUEUE_THLD_LVL_TX_START_8_DWORD,
    I3C_QUEUE_THLD_LVL_TX_START_16_DWORD,
    I3C_QUEUE_THLD_LVL_TX_START_32_DWORD,
    I3C_QUEUE_THLD_LVL_TX_START_64_DWORD,
}I3C_QUEUE_THLD_LVL_TX_START;


typedef enum
{
    I3C_PIO_INTR_STATUS_TX_THLD = I3CC_PIO_INTR_STATUS_TX_THLD_STAT_Msk,
    I3C_PIO_INTR_STATUS_RX_THLD = I3CC_PIO_INTR_STATUS_RX_THLD_STAT_Msk,
    I3C_PIO_INTR_STATUS_IBI_THLD = I3CC_PIO_INTR_STATUS_IBI_STATUS_THLD_STAT_Msk,
    I3C_PIO_INTR_STATUS_CMD_THLD = I3CC_PIO_INTR_STATUS_CMD_QUEUE_READY_STAT_Msk,
    I3C_PIO_INTR_STATUS_RESP_THLD = I3CC_PIO_INTR_STATUS_RESP_READY_STAT_Msk,
    I3C_PIO_INTR_STATUS_TFR_ABORT_THLD = I3CC_PIO_INTR_STATUS_TRANSFER_ABORT_STAT_Msk,
    I3C_PIO_INTR_STATUS_TFR_ERR_THLD = I3CC_PIO_INTR_STATUS_TRANSFER_ERR_STAT_Msk,
    I3C_PIO_INTR_STATUS_ALL = I3CC_PIO_INTR_STATUS_ENABLE_Msk,
}I3C_PIO_INTR_STATUS;

typedef enum
{
    I3C_PIO_INTR_SIGNAL_TX_THLD = I3CC_PIO_INTR_SIGNAL_ENABLE_TX_THLD_SIGNAL_EN_Msk,
    I3C_PIO_INTR_SIGNAL_RX_THLD = I3CC_PIO_INTR_SIGNAL_ENABLE_RX_THLD_SIGNAL_EN_Msk,
    I3C_PIO_INTR_SIGNAL_IBI_THLD = I3CC_PIO_INTR_SIGNAL_ENABLE_IBI_STATUS_THLD_SIGNAL_EN_Msk,
    I3C_PIO_INTR_SIGNAL_CMD_THLD = I3CC_PIO_INTR_SIGNAL_ENABLE_CMD_QUEUE_READY_SIGNAL_EN_Msk,
    I3C_PIO_INTR_SIGNAL_RESP_THLD = I3CC_PIO_INTR_SIGNAL_ENABLE_RESP_READY_SIGNAL_EN_Msk,
    I3C_PIO_INTR_SIGNAL_TFR_ABORT_THLD = I3CC_PIO_INTR_SIGNAL_ENABLE_TRANSFER_ABORT_SIGNAL_EN_Msk,
    I3C_PIO_INTR_SIGNAL_TFR_ERR_THLD = I3CC_PIO_INTR_SIGNAL_ENABLE_TRANSFER_ERR_SIGNAL_EN_Msk,
    
}I3C_PIO_INTR_SIGNAL;

/*-----------------------------------------*/
typedef enum
{
    ERR_STATUS_SUCCESS = 0,
    ERR_STATUS_CRC = 1,
    ERR_STATUS_PARITY = 2,
    ERR_STATUS_FRAME = 3,
    ERR_STATUS_ADDR_HEADER = 4,
    ERR_STATUS_NACK = 5,
    ERR_STATUS_OVL = 6,
    ERR_STATUS_I3C_SHORT_READ_ERR = 7,
    ERR_STATUS_HC_ABORTED = 8,
    ERR_STATUS_I2C_WR_DATA_NACK = 9,
    ERR_STATUS_I3C_BUS_ABORTED = 9,
    ERR_STATUS_NOT_SUPPORTED = 10,
}ERR_STATUS;

typedef enum
{
    I3CC_CURRENT_XFER_STATE_IDLE = 0x00,        /* Host Controller is in the Idle */
    I3CC_CURRENT_XFER_STATE_START = 0x01,       /* START Generation State*/
    I3CC_CURRENT_XFER_STATE_RESTART = 0x02,     /* RESTART Generation State*/
    I3CC_CURRENT_XFER_STATE_STOP = 0x03,        /* STOP Generation State */
    I3CC_CURRENT_XFER_STATE_START_HOLD = 0x04,  /* START Hold Generation for the Target-initiated START state */
    I3CC_CURRENT_XFER_STATE_BCAST_WRITE = 0x05, /* Broadcast Write Address Header(7'h7E,W) Generation State */
    I3CC_CURRENT_XFER_STATE_BCAST_READ = 0x06,  /* Broadcast Read Address Header(7'h7E,R) Generation State */
    I3CC_CURRENT_XFER_STATE_DAA = 0x07,         /* Dynamic Address Assignment State */
    I3CC_CURRENT_XFER_STATE_ADDR = 0x08,        /* Target Address Generation State */
    I3CC_CURRENT_XFER_STATE_CCC = 0x0B,         /* CCC Byte Generation State */
    I3CC_CURRENT_XFER_STATE_HDR = 0x0C,         /* HDR Command Generation State */
    I3CC_CURRENT_XFER_STATE_WR = 0x0D,          /* Write Data Transfer State */
    I3CC_CURRENT_XFER_STATE_RD = 0x0E,          /* Read Data Transfer State */
    I3CC_CURRENT_XFER_STATE_IBI_ADDR_RD = 0x0F, /* In-Band Interrupt Address Read Data State */
    I3CC_CURRENT_XFER_STATE_IBI_DIS = 0x10,     /* In-Band Interrupt Auto-Disable State */
    I3CC_CURRENT_XFER_STATE_HDR_DDR_CRC = 0x11, /* HDR-DDR CRC Data Generation/Receive State */
    I3CC_CURRENT_XFER_STATE_CLOCK_EXT = 0x12,   /* Clock Extension State */
    I3CC_CURRENT_XFER_STATE_HALT = 0x13,        /* Halt State */
    I3CC_CURRENT_XFER_STATE_IBI_READ = 0x14,    /* In-Band Interrupt (IBI) Read Data State */
    
}I3CC_CURRENT_XFER_STATE;

typedef enum
{
    I3CC_CURRENT_XFER_TYPE_IDLE = 0x00,             /* Idle */
    I3CC_CURRENT_XFER_TYPE_BCAST_WRITE = 0x01,      /* Broadcast CCC Write Transfer*/
    I3CC_CURRENT_XFER_TYPE_TARGET_WRITE = 0x02,     /* Directed CCC Write Transfer */
    I3CC_CURRENT_XFER_TYPE_TARGET_READ = 0x03,      /* Directed CCC Read Transfer */
    I3CC_CURRENT_XFER_TYPE_ENTDAA = 0x04,           /* ENTDAA Address Assignment Transfer */
    I3CC_CURRENT_XFER_TYPE_SETDASA = 0x05,          /* SETDASA Address Assignment Transfer */
    I3CC_CURRENT_XFER_TYPE_I3C_SDR_WRITE = 0x06,    /* Private I3C SDR Write Transfer */      
    I3CC_CURRENT_XFER_TYPE_I3C_SDR_READ = 0x07,     /* Private I3C SDR Read Transfer */      
    I3CC_CURRENT_XFER_TYPE_I2C_SDR_WRITE = 0x08,    /* Private I2C SDR Write Transfer */      
    I3CC_CURRENT_XFER_TYPE_I2C_SDR_READ = 0x09,     /* Private I2C SDR Read Transfer */      
    I3CC_CURRENT_XFER_TYPE_HDR_TS_WRITE = 0x0A,     /* Private HDR Ternary Symbol (TS) Write Transfer */       
    I3CC_CURRENT_XFER_TYPE_HDR_TS_READ = 0x0B,      /* Private HDR Ternary Symbol (TS) Read Transfer */    
    I3CC_CURRENT_XFER_TYPE_HDR_DDR_WRITE = 0x0C,    /* Private HDR Double-Data Rate (DDR) Write Transfer */    
    I3CC_CURRENT_XFER_TYPE_HDR_DDR_READ = 0x0D,     /* Private HDR Double-Data Rate (DDR) Read Transfer */
    I3CC_CURRENT_XFER_TYPE_IBI = 0x0E,              /* In-Band Interrupt Transfer */
    I3CC_CURRENT_XFER_TYPE_HALTED = 0x0F,           /* Host Controller is in the Halt State, waiting for the application to resume */
}I3CC_CURRENT_XFER_TYPE;

typedef struct
{
    uint32_t cmd_attr       : 3;
    uint32_t tid            : 4;
    uint32_t cmd            : 8;
    uint32_t                : 1;
    uint32_t dev_index      : 5;
    uint32_t                : 5;
    uint32_t dev_count      : 4;
    uint32_t roc            : 1;
    uint32_t toc            : 1;
}ADDR_ASSIGN_CMD0_BITS;

typedef struct
{
    uint32_t                     word;
}ADDR_ASSIGN_CMD1;

typedef union
{
    ADDR_ASSIGN_CMD0_BITS        bits;
    uint32_t                     word;
}ADDR_ASSIGN_CMD0;

typedef struct
{
    ADDR_ASSIGN_CMD0        cmd_word0;
    ADDR_ASSIGN_CMD1        cmd_word1;    
}ADDR_ASSIGN_CMD;

/*-----------------------------------------*/
typedef struct
{
    uint32_t cmd_attr       : 3;
    uint32_t tid            : 4;
    uint32_t cmd            : 8;
    uint32_t cp             : 1;
    uint32_t dev_index      : 5;
    uint32_t                : 2;
    uint32_t byte_count     : 3;
    uint32_t mode           : 3;
    uint32_t rnw            : 1;
    uint32_t roc            : 1;
    uint32_t toc            : 1;
}IMMD_XFER_CMD0_BITS;

typedef struct
{
    uint8_t data_byte1      : 8;
    uint8_t data_byte2      : 8;
    uint8_t data_byte3      : 8;
    uint8_t data_byte4      : 8;    
}IMMD_XFER_CMD1_BITS;

typedef union
{
    IMMD_XFER_CMD0_BITS          bits;
    uint32_t                     word;
}IMMD_XFER_CMD0;

typedef union
{
    IMMD_XFER_CMD1_BITS          bits;
    uint32_t                     word;
}IMMD_XFER_CMD1;

typedef struct
{
    IMMD_XFER_CMD0        cmd_word0;
    IMMD_XFER_CMD1        cmd_word1;    
}IMMD_XFER_CMD;

/*-----------------------------------------*/
typedef struct
{
    uint32_t cmd_attr       : 3;
    uint32_t tid            : 4;
    uint32_t cmd            : 8;
    uint32_t cp             : 1;
    uint32_t dev_index      : 5;
    uint32_t                : 5;
    uint32_t mode           : 3;
    uint32_t rnw            : 1;
    uint32_t roc            : 1;
    uint32_t toc            : 1;
}RGLR_DATA_XFER_CMD0_BITS;

typedef struct
{
    uint32_t def_byte       : 8;
    uint32_t                : 8;
    uint32_t data_length    : 16;    
}RGLR_DATA_XFER_CMD1_BITS;

typedef union
{
    RGLR_DATA_XFER_CMD1_BITS     bits;
    uint32_t                     word;
}RGLR_DATA_XFER_CMD1;

typedef union
{
    RGLR_DATA_XFER_CMD0_BITS      bits;
    uint32_t                      word;
}RGLR_DATA_XFER_CMD0;

typedef struct
{
    RGLR_DATA_XFER_CMD0        cmd_word0;
    RGLR_DATA_XFER_CMD1        cmd_word1;    
}RGLR_DATA_XFER_CMD;

/*-----------------------------------------*/
typedef struct
{
    uint32_t cmd_attr           : 3;
    uint32_t tid                : 4;
    uint32_t cmd                : 8;
    uint32_t cp                 : 1;
    uint32_t dev_index          : 5;
    uint32_t                    : 1;
    uint32_t data_length_pos    : 2;
    uint32_t first_phase_mode   : 1;
    uint32_t suboffset_8_16_bit : 1;       
    uint32_t mode               : 3;        
    uint32_t rnw                : 1;
    uint32_t roc                : 1;
    uint32_t toc                : 1;
}COMBO_DATA_XFER_CMD0_BITS;

typedef struct
{
    uint32_t offset_suboffset   : 16;
    uint32_t data_length        : 16;
}COMBO_DATA_XFER_CMD1_BITS;

typedef union
{
    COMBO_DATA_XFER_CMD0_BITS   bits;
    uint32_t                    word;
}COMBO_DATA_XFER_CMD0;

typedef union
{
    COMBO_DATA_XFER_CMD1_BITS   bits;
    uint32_t                    word;
}COMBO_DATA_XFER_CMD1;

typedef struct
{
    COMBO_DATA_XFER_CMD0        cmd_word0;
    COMBO_DATA_XFER_CMD1        cmd_word1;
    
}COMBO_DATA_XFER_CMD;

/*-----------------------------------------*/
typedef struct
{
    uint32_t            cmd_word0;
    uint32_t            cmd_word1;
}CMD_DESC_WORDS;

typedef union
{
    ADDR_ASSIGN_CMD         addr_assign_cmd;
    IMMD_XFER_CMD           immd_xfer_cmd;
    RGLR_DATA_XFER_CMD      rglr_data_xfer_cmd;
    COMBO_DATA_XFER_CMD     combo_data_xfer_cmd;
    
    CMD_DESC_WORDS          cmd_words;
    
}CMD_DESC;

/*-----------------------------------------*/
typedef struct
{
    uint32_t data_length        : 8;
    uint32_t ibi_id             : 8;
    uint32_t chunks             : 8;
    uint32_t last_status        : 1;    
    uint32_t ts                 : 1;
    uint32_t hw_context         : 3;
    uint32_t status_type        : 1;
    uint32_t error              : 1;
    uint32_t ibi_ack_status     : 1;
}IBI_STATUS_DESC_BITS;

typedef union
{
    IBI_STATUS_DESC_BITS         bits;
    uint32_t                     word;
}IBI_STATUS_DESC;

/*-----------------------------------------*/
typedef struct
{
    uint32_t data_length        : 16;
    uint32_t                    : 8;
    uint32_t tid                : 4;
    uint32_t err_status         : 4;    
}RESPONSE_DESC_BITS;

typedef union
{
    RESPONSE_DESC_BITS           bits;
    uint32_t                     word;
}RESPONSE_DESC;

/*-----------------------------------------*/
typedef struct
{
    uint32_t static_addr       : 7;
    uint32_t                   : 5;
    uint32_t ibi_payload       : 1;
    uint32_t ibi_reject        : 1;
    uint32_t crr_reject        : 1;
    uint32_t ts                : 1;
    uint32_t dynamic_addr      : 7;
    uint32_t parity            : 1;
    uint32_t                   : 2;
    uint32_t ring_id           : 3;
    uint32_t dev_nack_retry_cnt : 2;
    uint32_t dev_type          : 1;
}DAT_TABLE_WORD0_bits;

typedef struct
{
    uint32_t autocmd_mask      : 8;
    uint32_t autocmd_value     : 8;
    uint32_t autocmd_mode      : 3;
    uint32_t autocmd_hdr_code  : 8;
    uint32_t                   : 5;
}DAT_TABLE_WORD1_bits;

typedef union
{
    DAT_TABLE_WORD0_bits        bits;
    uint32_t                    word;
}DAT_TABLE_WORD0;

typedef union
{
    DAT_TABLE_WORD1_bits        bits;
    uint32_t                    word;
}DAT_TABLE_WORD1;

typedef struct
{
    DAT_TABLE_WORD0             word0;
    DAT_TABLE_WORD1             word1;
}DAT_TABLE_ENTRY;

/*-----------------------------------------*/
typedef struct
{
    uint8_t max_data_spped_limitation   : 1;
    uint8_t ibi_request_capable         : 1;
    uint8_t ibi_payload                 : 1;
    uint8_t offline_capable             : 1;
    uint8_t bridge_identifier           : 1;
    uint8_t sdr_hdr_capable             : 1;
    uint8_t device_role                 : 2;
}I3C_BCR_BITS;

typedef union
{
    I3C_BCR_BITS        bits;
    uint8_t             byte;
}I3C_BCR;

typedef struct
{
    uint8_t             pid[6];
    uint8_t             dcr;
    I3C_BCR             bcr;    
}I3C_PID_BCR_DCR;

/*-----------------------------------------*/
typedef struct
{
    uint32_t            pid_high;
    uint16_t            pid_low;
    uint16_t            reserved1;
    
    uint8_t             dcr;
    I3C_BCR             bcr;    
    uint16_t            reserved2;
    
    uint8_t             dynamic_addr;
    uint8_t             reserved3[3];    
}DCT_TABLE_ENTRY;



/*-----------------------------------------*/
typedef struct
{
    DCT_TABLE_ENTRY         DCTInfo;
    uint8_t                 DATIndex;
    bool                    inUse;
}I3C_DEVICE_INFO;

typedef struct
{
    I3C_DEVICE_INFO         devInfo[MAX_TARGET_DEV_SUPPORTED];
    uint8_t                 numValidEntries;
}I3C_DEV_INFO;      
/*-----------------------------------------*/

typedef struct
{
    I3C_CMD_DESC_TYPE       cmd_desc_type;
    I3C_XFER_DIR            xfer_dir;
    uint32_t                nBytesRequested;
    uint32_t                nBytesProcessed;
    void*                   pDataBuffer;
    CMD_DESC                cmd;
    RESPONSE_DESC           responseDesc;
    I3C_XFER_ID             xfer_id;
}XFER_INFO;

typedef struct XFER_QUEUE
{
    XFER_INFO               xfer_info;
    bool                    inUse;
    struct XFER_QUEUE*      next;
}XFER_QUEUE;

typedef struct
{
    IBI_STATUS_DESC         ibiStatusDescriptor;
    uint8_t                 ibiPayload[MAX_IBI_PAYLOAD];
}IBI_INFO;

typedef struct
{
    I3C_XFER_MODE       mode;
    bool                toc;
}I3C_XFER_FLAGS_I3C;

typedef struct
{
    I3C_XFER_MODE       mode;
    bool                toc;
}I3C_XFER_FLAGS_I2C;

typedef struct
{
    I3C_XFER_FLAGS_I3C       i3cXferMode;
    I3C_XFER_FLAGS_I2C       i2cXferMode;
}I3C_XFER_FLAGS;

typedef struct
{
    volatile DAT_TABLE_ENTRY* DATTablePtr;
    volatile DCT_TABLE_ENTRY* DCTTablePtr;
    uint32_t                DATTableSize;
    uint32_t                DCTTableSize;
    uint32_t                RXQ_SizeDW;
    uint32_t                TXQ_SizeDW;
    uint32_t                CRQ_SizeDW;
    uint32_t                IBIStatusQ_Size;
    I3C_XFER_ID             xfer_cntr;
    uint8_t                 tid;
    
    I3C_DEV_INFO            deviceInfo;
    I3C_XFER_FLAGS          xferFlagsGlobal;
    // Transient, shared by all devices on the bus. 
    //Must read by application upon reception of IBI_EVENT or it will be overwritten by another IBI request
    IBI_INFO                ibiInfo;   
    
    XFER_QUEUE*             xfer_queue_pool;
    XFER_QUEUE*             xfer_queue_head;
    uint32_t                xfer_queue_pool_size;
    uint8_t                 scratchBuffer[MAX_SCRATCH_BUFFER_SIZE];
    volatile bool           abortRequested;
    I3C_CALLBACK            callback;
    volatile bool           isBusy;
}I3C_HOST;

typedef struct
{
    IBI_STATUS_DESC     status_desc;
    uint8_t             devId;
    uint8_t             nPayloadBytes;
    uint8_t*            payloadDataBuffer;        
}I3C_EVENT_DATA_IBI;

typedef struct
{
    IBI_STATUS_DESC     status_desc;         
}I3C_EVENT_DATA_HOTJOIN;

typedef struct
{
    ERR_STATUS          errStatus;
    I3C_CMD_DESC_TYPE   cmdDescType;
    uint8_t             devId;
    I3C_XFER_ID         xferId;
    uint32_t            nBytesRead;
    uint8_t*            readBuffer;    
}I3C_EVENT_DATA_PRIVATE_READ;

typedef struct
{
    ERR_STATUS          errStatus;
    I3C_CMD_DESC_TYPE   cmdDescType;
    uint8_t             devId;
    I3C_XFER_ID         xferId;
    uint32_t            nBytesWritten;
    uint32_t            nBytesPending;
    uint8_t*            writeBuffer;    
}I3C_EVENT_DATA_PRIVATE_WRITE;

typedef struct
{
    ERR_STATUS          errStatus;
    I3C_CMD_DESC_TYPE   cmdDescType;
    uint8_t             devId;
    I3C_CCC             ccc;
    I3C_XFER_ID         xferId;
    uint32_t            nBytesRead;
    uint8_t*            readBuffer;      
}I3C_EVENT_DATA_DIRECT_CCC_READ;

typedef struct
{
    ERR_STATUS          errStatus;
    I3C_CMD_DESC_TYPE   cmdDescType;
    uint8_t             devId;
    I3C_CCC             ccc;
    I3C_XFER_ID         xferId;
    uint32_t            nBytesWritten;
    uint32_t            nBytesPending;
    uint8_t*            writeBuffer;      
}I3C_EVENT_DATA_DIRECT_CCC_WRITE;

typedef struct
{
    ERR_STATUS          errStatus;
    I3C_CMD_DESC_TYPE   cmdDescType;
    I3C_CCC             ccc;
    I3C_XFER_ID         xferId;
    uint32_t            nBytesWritten;
    uint32_t            nBytesPending;
    uint8_t*            writeBuffer;    
}I3C_EVENT_DATA_BROADCAST_CCC_WRITE;

typedef struct
{
    ERR_STATUS          errStatus;
    uint8_t             nDevicesCnt;     
    I3C_CCC             ccc;
    I3C_XFER_ID         xferId;
}I3C_EVENT_DATA_DEVICE_DISCOVERY;

typedef union
{
    I3C_EVENT_DATA_BROADCAST_CCC_WRITE      broadcastCCCWrEventData;
    I3C_EVENT_DATA_DIRECT_CCC_WRITE         directCCCWrEventData;
    I3C_EVENT_DATA_DIRECT_CCC_READ          directCCCRdEventData;
    I3C_EVENT_DATA_PRIVATE_WRITE            privWrEventData;
    I3C_EVENT_DATA_PRIVATE_READ             privRdEventData;
    I3C_EVENT_DATA_DEVICE_DISCOVERY         devDiscoveryInfo;
    I3C_EVENT_DATA_IBI                      ibiDataEvent;
    I3C_EVENT_DATA_HOTJOIN                  hotjoinEvent;
}I3C_EVENT_DATA;


typedef struct
{
    uint8_t             datIndex;
    uint8_t             staticAddr;
    uint8_t             dynamicAddr;
    uint32_t            pid_high;
    uint16_t            pid_low;    
    uint8_t             dcr;
    I3C_BCR             bcr;        
}I3C_TARGET_INFO;

typedef struct
{
    bool ibi_reject;
    uint8_t autocmd_mask;
    uint8_t autocmd_value;
    I3C_XFER_MODE autocmd_mode;
}IBI_SETUP;

typedef struct
{
    DAT_TABLE_DEV_TYPE devType;
    uint8_t static_addr;
    uint8_t dynamic_addr;     
    uint8_t nak_retry_count;
    bool crr_reject;
}DAT_TABLE_SETUP;

typedef struct
{
    I3CC_CURRENT_XFER_STATE     currXferState;
    I3CC_CURRENT_XFER_TYPE      currXferType;
    uint8_t                     currentTID;
    uint8_t                     SDASignalLevel;
}I3C_PRESENT_STATE;

// DOM-IGNORE-BEGIN
#ifdef __cplusplus  // Provide C++ Compatibility
    }
#endif
// DOM-IGNORE-END

#endif /* PLIB_I3CC_HOST_COMMON_H */














