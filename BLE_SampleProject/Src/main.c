/* Includes ------------------------------------------------------------------*/
#include "cube_hal.h"

#include "osal.h"
#include "sample_service.h"
#include "debug.h"
#include "stm32_bluenrg_ble.h"
#include "bluenrg_utils.h"
#include <string.h>
#include <stdio.h>
#include "stm32f4xx_hal.h"

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
#define B1_Pin GPIO_PIN_13
#define B1_GPIO_Port GPIOC
#define USART_TX_Pin GPIO_PIN_2
#define USART_TX_GPIO_Port GPIOA
#define USART_RX_Pin GPIO_PIN_3
#define USART_RX_GPIO_Port GPIOA
#define LD2_Pin GPIO_PIN_5
#define LD2_GPIO_Port GPIOA
#define TMS_Pin GPIO_PIN_13
#define TMS_GPIO_Port GPIOA
#define TCK_Pin GPIO_PIN_14
#define TCK_GPIO_Port GPIOA
#define SWO_Pin GPIO_PIN_3
#define SWO_GPIO_Port GPIOB

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
//  int data[10] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
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
	printf("Here\n");

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
//  HAL_Init();

  #if NEW_SERVICES
  /* Configure LED2 */
  BSP_LED_Init(LED2);
  #endif

  /* Configure the User Button in GPIO Mode */
  BSP_PB_Init(BUTTON_KEY, BUTTON_MODE_GPIO);

  /* Configure the system clock */
  /* SYSTEM CLOCK = 32 MHz */
//  SystemClock_Config();

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

uint8_t rx_buffer[40000];
int audio_counter = 1;
int done_sending = 1;
void audioService(void){
	HAL_Delay(10);
	static uint8_t value = 0;
		uint8_t buf[20];
	for(int i = 0; i< 20; i++){
		buf[i]=rx_buffer[i+audio_counter];
//		printf("%d\n", audio_counter+i);
	}
	audio_counter += 20;
	


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
	
				Sample_Characteristic_Update(buf);
	}
	
}

UART_HandleTypeDef huart6;
void SystemClock_Config(void);
static void MX_GPIO_Init(void);
static void MX_USART6_UART_Init(void);
uint8_t valBuffer[40000];
char* bufftr = "Hello!\n\r";
uint8_t buffrc[8];
int main(void)
{
	
	HAL_Init();
	SystemClock_Config();
	MX_GPIO_Init();
  MX_USART6_UART_Init();
	__HAL_UART_ENABLE_IT (&huart6, UART_IT_RXNE);
//	__HAL_UART_ENABLE_IT (&huart6, UART_IT_TC);
	int valuesRecorded = 1;

  while (valuesRecorded)
  {
			printf("Hello\n");
//		HAL_UART_Transmit_IT(&huart6, (uint8_t *)bufftr, 8);
//		HAL_UART_Receive_IT(&huart6, (uint8_t *)buffrc, 8);
	HAL_UART_Receive_IT(&huart6, rx_buffer, 40000);
  /* USER CODE BEGIN 3 */
	HAL_Delay(5000);
	if(rx_buffer[0] != 0 && rx_buffer[30000] != 0){
			printf("DONE!\n");
			printf("%d\n", rx_buffer[39999]);
					valuesRecorded = 0;

	}
//		HAL_GPIO_TogglePin(GPIOC, GPIO_PIN_6);
//		printf("Buff: %s\n", buffrc);
	if (rx_buffer[1] != valBuffer[1]){
			memcpy((uint8_t*)valBuffer,(uint8_t*)rx_buffer, 40000);
//		printf("Val 1: %d \n", valBuffer[1]); 
	}
	

 

  }
 initializeEverything();

	while(done_sending){
			audioService();
			HCI_Process();
	}
}

/** System Clock Configuration
*/
void SystemClock_Config(void)
{

  RCC_OscInitTypeDef RCC_OscInitStruct;
  RCC_ClkInitTypeDef RCC_ClkInitStruct;

    /**Configure the main internal regulator output voltage 
    */
  __HAL_RCC_PWR_CLK_ENABLE();

  __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE2);

    /**Initializes the CPU, AHB and APB busses clocks 
    */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.HSICalibrationValue = 16;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSI;
  RCC_OscInitStruct.PLL.PLLM = 16;
  RCC_OscInitStruct.PLL.PLLN = 336;
  RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV4;
  RCC_OscInitStruct.PLL.PLLQ = 7;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    _Error_Handler(__FILE__, __LINE__);
  }

    /**Initializes the CPU, AHB and APB busses clocks 
    */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_2) != HAL_OK)
  {
    _Error_Handler(__FILE__, __LINE__);
  }

    /**Configure the Systick interrupt time 
    */
  HAL_SYSTICK_Config(HAL_RCC_GetHCLKFreq()/1000);

    /**Configure the Systick 
    */
  HAL_SYSTICK_CLKSourceConfig(SYSTICK_CLKSOURCE_HCLK);

  /* SysTick_IRQn interrupt configuration */
  HAL_NVIC_SetPriority(SysTick_IRQn, 0, 0);
}

/* USART6 init function */
static void MX_USART6_UART_Init(void)
{

  huart6.Instance = USART6;
  huart6.Init.BaudRate = 115200;
  huart6.Init.WordLength = UART_WORDLENGTH_8B;
  huart6.Init.StopBits = UART_STOPBITS_1;
  huart6.Init.Parity = UART_PARITY_NONE;
  huart6.Init.Mode = UART_MODE_TX_RX;
  huart6.Init.HwFlowCtl = UART_HWCONTROL_NONE;
  huart6.Init.OverSampling = UART_OVERSAMPLING_16;
  if (HAL_UART_Init(&huart6) != HAL_OK)
  {
    _Error_Handler(__FILE__, __LINE__);
  }

}

/** Configure pins as 
        * Analog 
        * Input 
        * Output
        * EVENT_OUT
        * EXTI
     PA2   ------> USART2_TX
     PA3   ------> USART2_RX
*/
static void MX_GPIO_Init(void)
{

  GPIO_InitTypeDef GPIO_InitStruct;

  /* GPIO Ports Clock Enable */
  __HAL_RCC_GPIOC_CLK_ENABLE();
  __HAL_RCC_GPIOH_CLK_ENABLE();
  __HAL_RCC_GPIOA_CLK_ENABLE();
  __HAL_RCC_GPIOB_CLK_ENABLE();

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(LD2_GPIO_Port, LD2_Pin, GPIO_PIN_RESET);

  /*Configure GPIO pin : B1_Pin */
  GPIO_InitStruct.Pin = B1_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_IT_FALLING;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(B1_GPIO_Port, &GPIO_InitStruct);

  /*Configure GPIO pins : USART_TX_Pin USART_RX_Pin */
  GPIO_InitStruct.Pin = USART_TX_Pin|USART_RX_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  GPIO_InitStruct.Alternate = GPIO_AF7_USART2;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

  /*Configure GPIO pin : LD2_Pin */
  GPIO_InitStruct.Pin = LD2_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(LD2_GPIO_Port, &GPIO_InitStruct);

}

void _Error_Handler(char * file, int line)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  while(1) 
  {
  }
  /* USER CODE END Error_Handler_Debug */ 
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
