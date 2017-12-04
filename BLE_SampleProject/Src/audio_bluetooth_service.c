#include <stdio.h>
#include "cube_hal.h"
#include "sensor_service.h"
#include "debug.h"
#include "stm32_bluenrg_ble.h"
#include "bluenrg_utils.h"

void addAudioService(){
	
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
