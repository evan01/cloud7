#include <stdio.h>
#include "cube_hal.h"
#include "sensor_service.h"
#include "debug.h"
#include "stm32_bluenrg_ble.h"
#include "bluenrg_utils.h"

#define COPY_AUDIO_SERVICE_UUID(uuid_struct) COPY_UUID_128(uuid_struct, 0x01, 0x36, 0x6e, 0x80, 0xcf, 0x3a, 0x11, 0xe1, 0x9a, 0xb4, 0x00, 0x02, 0xa5, 0xd5, 0xc5, 0x1b)
#define COPY_AUDIO_UUID(uuid_struct) COPY_UUID_128(uuid_struct, 0x02, 0x36, 0x6e, 0x80, 0xcf, 0x3a, 0x11, 0xe1, 0x9a, 0xb4, 0x00, 0x02, 0xa5, 0xd5, 0xc5, 0x1b)
#define COPY_AUDIO_UUID(uuid_struct) COPY_UUID_128(uuid_struct, 0x03, 0x36, 0x6e, 0x80, 0xcf, 0x3a, 0x11, 0xe1, 0x9a, 0xb4, 0x00, 0x02, 0xa5, 0xd5, 0xc5, 0x1b)
uint16_t accServHandle, freeFallCharHandle, accCharHandle;


/** @defgroup SENSOR_SERVICE_Private_Macros
 * @{
 */
/* Private macros ------------------------------------------------------------*/
#define COPY_UUID_128(uuid_struct, uuid_15, uuid_14, uuid_13, uuid_12, uuid_11, uuid_10, uuid_9, uuid_8, uuid_7, uuid_6, uuid_5, uuid_4, uuid_3, uuid_2, uuid_1, uuid_0) \
  \
do                                                                                                                                                                     \
  {                                                                                                                                                                      \
    uuid_struct[0] = uuid_0;                                                                                                                                             \
    uuid_struct[1] = uuid_1;                                                                                                                                             \
    uuid_struct[2] = uuid_2;                                                                                                                                             \
    uuid_struct[3] = uuid_3;                                                                                                                                             \
    uuid_struct[4] = uuid_4;                                                                                                                                             \
    uuid_struct[5] = uuid_5;                                                                                                                                             \
    uuid_struct[6] = uuid_6;                                                                                                                                             \
    uuid_struct[7] = uuid_7;                                                                                                                                             \
    uuid_struct[8] = uuid_8;                                                                                                                                             \
    uuid_struct[9] = uuid_9;                                                                                                                                             \
    uuid_struct[10] = uuid_10;                                                                                                                                           \
    uuid_struct[11] = uuid_11;                                                                                                                                           \
    uuid_struct[12] = uuid_12;                                                                                                                                           \
    uuid_struct[13] = uuid_13;                                                                                                                                           \
    uuid_struct[14] = uuid_14;                                                                                                                                           \
    uuid_struct[15] = uuid_15;                                                                                                                                           \
  \
}                                                                                                                                                                     \
  while (0)

void sendAudioData(int *data){
	if(set_connectable){
		setConnectable();
		set_connectable = FALSE;
	}
	
	//Let the user know we are sending stuff!
	BSP_LED_Toggle(LED2);
	
	//Then if we're actually connected, lets send the data
	if(connected){
		
	}
}
