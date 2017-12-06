/* Includes ------------------------------------------------------------------*/
#include "cube_hal.h"

#include "osal.h"
#include "sample_service.h"
#include "debug.h"
#include "stm32_bluenrg_ble.h"
#include "bluenrg_utils.h"
#include <string.h>
#include <stdio.h>

/** @addtogroup X-CUBE-BLE1_Applications
 *  @{
 */

/** @defgroup SensorDemo
 *  @{
 */

/** @defgroup MAIN 
 * @{
 */

/** @defgroup MAIN_Private_Defines 
 * @{
 */
/* Private defines -----------------------------------------------------------*/
#define BDADDR_SIZE 6
int counter = 0;
/**
 * @}
 */

/* Private macros ------------------------------------------------------------*/

/** @defgroup MAIN_Private_Variables
 * @{
 */
/* Private variables ---------------------------------------------------------*/
extern volatile uint8_t set_connectable;
extern volatile int connected;
uint8_t bnrg_expansion_board = IDB04A1; /* at startup, suppose the X-NUCLEO-IDB04A1 is used */
/**
 * @}
 */

/** @defgroup MAIN_Private_Function_Prototypes
 * @{
 */
/* Private function prototypes -----------------------------------------------*/
/**
 * @}
 */

void sendDataToIos()
{
  //This is assuming we have all the data that we want to send
  int data[10] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
  //sendAudioData(data);
}

void initializeEverything()
{
  const char *name = "Cloud7";
  uint8_t SERVER_BDADDR[] = {0x12, 0x34, 0x00, 0xE1, 0x80, 0x03};
  uint8_t bdaddr[BDADDR_SIZE];
  uint16_t service_handle, dev_name_char_handle, appearance_char_handle;

  uint8_t hwVersion;
  uint16_t fwVersion;

  int ret;

  /* STM32Cube HAL library initialization:
    *  - Configure the Flash prefetch, Flash preread and Buffer caches
    *  - Systick timer is configured by default as source of time base, but user 
    *    can eventually implement his proper time base source (a general purpose 
    *    timer for example or other time source), keeping in mind that Time base 
    *    duration should be kept 1ms since PPP_TIMEOUT_VALUEs are defined and 
    *    handled in milliseconds basis.
    *  - Low Level Initialization
    */
  HAL_Init();

  #if NEW_SERVICES
  /* Configure LED2 */
  BSP_LED_Init(LED2);
  #endif

  /* Configure the User Button in GPIO Mode */
  BSP_PB_Init(BUTTON_KEY, BUTTON_MODE_GPIO);

  /* Configure the system clock */
  /* SYSTEM CLOCK = 32 MHz */
  SystemClock_Config();

  /* Initialize the BlueNRG SPI driver */
  BNRG_SPI_Init();

  /* Initialize the BlueNRG HCI */
  HCI_Init();

  /* Reset BlueNRG hardware */
  BlueNRG_RST();

  /* get the BlueNRG HW and FW versions */
  getBlueNRGVersion(&hwVersion, &fwVersion);

  /* 
    * Reset BlueNRG again otherwise we won't
    * be able to change its MAC address.
    * aci_hal_write_config_data() must be the first
    * command after reset otherwise it will fail.
    */
  BlueNRG_RST();

  /* The Nucleo board must be configured as SERVER */
  Osal_MemCpy(bdaddr, SERVER_BDADDR, sizeof(SERVER_BDADDR));

  ret = aci_hal_write_config_data(CONFIG_DATA_PUBADDR_OFFSET, CONFIG_DATA_PUBADDR_LEN, bdaddr);
  if (ret)
  {
    PRINTF("Setting BD_ADDR failed.\n");
  }

  ret = aci_gatt_init();
  if (ret)
  {
    PRINTF("GATT_Init failed.\n");
  }

  if (bnrg_expansion_board == IDB05A1)
  {
    ret = aci_gap_init_IDB05A1(GAP_PERIPHERAL_ROLE_IDB05A1, 0, 0x03, &service_handle, &dev_name_char_handle, &appearance_char_handle);
  }
  else
  {
    ret = aci_gap_init_IDB04A1(GAP_PERIPHERAL_ROLE_IDB04A1, &service_handle, &dev_name_char_handle, &appearance_char_handle);
  }

  if (ret != BLE_STATUS_SUCCESS)
  {
    PRINTF("GAP_Init failed.\n");
  }

  ret = aci_gatt_update_char_value(service_handle, dev_name_char_handle, 0,
                                    strlen(name), (uint8_t *)name);

  if (ret)
  {
    PRINTF("aci_gatt_update_char_value failed.\n");
    while (1)
      ;
  }

  ret = aci_gap_set_auth_requirement(MITM_PROTECTION_REQUIRED,
                                      OOB_AUTH_DATA_ABSENT,
                                      NULL,
                                      7,
                                      16,
                                      USE_FIXED_PIN_FOR_PAIRING,
                                      123456,
                                      BONDING);
  if (ret == BLE_STATUS_SUCCESS)
  {
    PRINTF("BLE Stack Initialized.\n");
  }

  PRINTF("SERVER: BLE Stack Initialized\n");

  ret = Add_Sample_Service();

  if (ret == BLE_STATUS_SUCCESS)
    PRINTF("Audio service added successfully.\n");
  else
    PRINTF("Error while adding Acc service.\n");

  /* Set output power level */
  ret = aci_hal_set_tx_power_level(1, 4);
}

void audioService(void){
	HAL_Delay(2000);
	static uint8_t value = 0;
	
	if(value > 20){
		value = 0;
	} else {
		value++;
	}
	if (set_connectable){
		setConnectable();
		set_connectable = FALSE;
	}
	
	if(connected){
		Sample_Characteristic_Update(value);
	}
	
}

int main(void)
{
  initializeEverything();
  while (1)
  {
	audioService();
    HCI_Process();
  }
}

/**
 * @brief  Process user input (i.e. pressing the USER button on Nucleo board)
 *         and send the updated acceleration data to the remote client.
 *
 * @param  AxesRaw_t* p_axes
 * @retval None
 */
//void User_Process(AxesRaw_t *p_axes)
//{
//  if (set_connectable)
//  {
//    setConnectable();
//    set_connectable = FALSE;
//  }

//  /* Check if the user has pushed the button */
//  if (BSP_PB_GetState(BUTTON_KEY) == RESET)
//  {
//    while (BSP_PB_GetState(BUTTON_KEY) == RESET)
//      ;

//    //BSP_LED_Toggle(LED2); //used for debugging (BSP_LED_Init() above must be also enabled)

//    if (connected)
//    {
//      /* Update acceleration data */
//      p_axes->AXIS_X += 1;
//      p_axes->AXIS_Y -= 1;
//      p_axes->AXIS_Z += 2;
//      PRINTF("ACC: X=%6d Y=%6d Z=%6d\r\n", p_axes->AXIS_X, p_axes->AXIS_Y, p_axes->AXIS_Z);
//      Acc_Update(p_axes);
//    }
//  }
//}

/**
 * @}
 */

/**
 * @}
 */

/**
 * @}
 */

/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/
