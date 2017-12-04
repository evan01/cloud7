#include <stdio.h>
#include "cube_hal.h"
#include "sensor_service.h"
#include "debug.h"
#include "stm32_bluenrg_ble.h"
#include "bluenrg_utils.h"

#define COPY_AUDIO_SERVICE_UUID(uuid_struct) COPY_UUID_128(uuid_struct, 0x01, 0x36, 0x6e, 0x80, 0xcf, 0x3a, 0x11, 0xe1, 0x9a, 0xb4, 0x00, 0x02, 0xa5, 0xd5, 0xc5, 0x1b)
#define COPY_AUDIO_UUID(uuid_struct) COPY_UUID_128(uuid_struct, 0x02, 0x36, 0x6e, 0x80, 0xcf, 0x3a, 0x11, 0xe1, 0x9a, 0xb4, 0x00, 0x02, 0xa5, 0xd5, 0xc5, 0x1b)
#define COPY_AUDIO_UUID(uuid_struct) COPY_UUID_128(uuid_struct, 0x03, 0x36, 0x6e, 0x80, 0xcf, 0x3a, 0x11, 0xe1, 0x9a, 0xb4, 0x00, 0x02, 0xa5, 0xd5, 0xc5, 0x1b)

void initializeAudioService(){
	/**
	 * You need 3 things to start a bluetooth service
	 * 	1. The Service UUID
	 * 	2. The Service 
	 */
  tBleStatus ret;

  uint8_t uuid[16];

  COPY_AUDIO_SERVICE_UUID(uuid); // todo change
  ret = aci_gatt_add_serv(UUID_TYPE_128, uuid, PRIMARY_SERVICE, 7,
                          &accServHandle); // todo change
  if (ret != BLE_STATUS_SUCCESS)
    goto fail;

  COPY_AUDIO_UUID(uuid);
  ret = aci_gatt_add_char(accServHandle, UUID_TYPE_128, uuid, 1,
                          CHAR_PROP_NOTIFY, ATTR_PERMISSION_NONE, 0,
                          16, 0, &freeFallCharHandle);
  if (ret != BLE_STATUS_SUCCESS)
    goto fail;

  COPY_AUDIO_UUID(uuid);
  ret = aci_gatt_add_char(accServHandle, UUID_TYPE_128, uuid, 6,
                          CHAR_PROP_NOTIFY | CHAR_PROP_READ,
                          ATTR_PERMISSION_NONE,
                          GATT_NOTIFY_READ_REQ_AND_WAIT_FOR_APPL_RESP,
                          16, 0, &accCharHandle);
  if (ret != BLE_STATUS_SUCCESS)
    goto fail;

  PRINTF("Service ACC added. Handle 0x%04X, Free fall Charac handle: 0x%04X, Acc Charac handle: 0x%04X\n", accServHandle, freeFallCharHandle, accCharHandle);
  return BLE_STATUS_SUCCESS;

fail:
  PRINTF("Error while adding AUDIO service.\n");
  return BLE_STATUS_ERROR;
}
}

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
