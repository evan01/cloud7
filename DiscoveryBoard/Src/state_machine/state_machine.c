#include <stdio.h>
#include <string.h>
#include "state_machine.h"
#include "../Threads.h"

state_e state = SLEEP;
state_e next_state;



/*
0 -> roll
1 -> pitch
*/

int printState(state_e state){
	switch(state){
		case START_STATE:
			printf("START_STATE\n");
			break;
		case SLEEP_STATE:
			printf("SLEEP_STATE\n");
			break;
		case ENTER_ROLL_STATE:
			printf("ENTER_ROLL_STATE\n");
			break;
		case ENTER_PITCH_STATE:
			printf("ENTER_PITCH_STATE\n");
			break;
		case PITCH_MONITOR_STATE:
			printf("PITCH_MONITOR_STATE\n");
			break;
		case ROLL_MONITOR_STATE:
			printf("ROLL_MONITOR_STATE\n");
			break;
		case TARGET_PITCH_STATE:
			printf("TARGET_PITCH_STATE\n");
			break;
		case TARGET_ROLL_STATE:
			printf("TARGET_ROLL_STATE\n");
			break;
	}
	return 0;
}




int update_state(){
	printf("Initial State: ");
	printState(state);

	if(state == START_STATE){
		memset(roll_buf, 0, 10);
		memset(pitch_buf, 0, 10);
		roll_pointer = 0;
		pitch_pointer = 0;
		state = ENTER_ROLL_STATE;
//		sscanf(roll_buf, "%f", &placeholder_value);
	}
	if(press_type == LONG_PRESS){
		if(event == STAR){
			printf("going to SLEEP_STATE\n");
			next_state = SLEEP_STATE;
		}else if(event == HASHTAG && state == SLEEP_STATE){
			printf("going to START_STATE\n");
			next_state = START_STATE;
		}else{
			next_state = state;
		}
	}else if(press_type == MID_PRESS){
		printf("Going back to START_STATE  %d \n", event);
		if(event == STAR && state != SLEEP_STATE){
			next_state = START_STATE;
			memset(roll_buf, 0, 10);
			memset(pitch_buf, 0, 10);
			roll_pointer = 0;
			pitch_pointer = 0;
		}else{
			next_state = state;
		}
	}else{
		switch(state){
			case START_STATE:
				next_state = ENTER_ROLL_STATE;
			case SLEEP_STATE:
				next_state = SLEEP_STATE;
				
				break;
			case ENTER_ROLL_STATE:
				if(event == HASHTAG){
					next_state = ENTER_PITCH_STATE;
					// sprintf(roll_buf + roll_pointer, "\0");
					sscanf(roll_buf, "%d", &target_roll);
					printf("Final roll = %d\n", target_roll);
				}else if(event == STAR){
					//clear last digit
					printf("Clearing digit from roll\n");
					next_state = ENTER_ROLL_STATE;
					clearingLastDigit(0);
				}else{
					//add number to roll variable
					int digit;
					if(event == NUMBER_0){
						digit = 0;
					}else{
						digit = event-1;
					}
					printf("Adding digit %d\n", digit);
					next_state = ENTER_ROLL_STATE;
					updateAngle(digit, 0);
				}
				break;
			case ENTER_PITCH_STATE:
				if(event == HASHTAG){
					next_state = PITCH_MONITOR_STATE;
					// sprintf(pitch_buf + pitch_pointer, "\0");
					sscanf(pitch_buf, "%d", &target_pitch);
					printf("Final pitch = %d\n", target_pitch);
				}else if(event == STAR){
					//clear last digit
					printf("Clearing digit from pitch\n");
					next_state = ENTER_PITCH_STATE;
					clearingLastDigit(1);
				}else{
					//add number to pitch variable
					int digit;
					if(event == NUMBER_0){
						digit = 0;
					}else{
						digit = event-1;
					}
					printf("Adding digit %d\n", digit);
					next_state = ENTER_PITCH_STATE;
					updateAngle(digit, 1);
				}
				break;
			case PITCH_MONITOR_STATE:
//				if(event == NUMBER_1){
//					next_state = PITCH_MONITOR_STATE;
//				}else if(event == NUMBER_2){
//					next_state = ROLL_MONITOR_STATE;
//				}else if(event == HASHTAG){
//					next_state = TARGET_PITCH_STATE;
//				}else{
//					next_state = PITCH_MONITOR_STATE;
//				}
			
				if(event == HASHTAG){
					next_state = TARGET_PITCH_STATE;
				}	else{
					next_state = PITCH_MONITOR_STATE;
				}
				break;
			case ROLL_MONITOR_STATE:
//				if(event == NUMBER_1){
//					next_state = PITCH_MONITOR_STATE;
//				}else if(event == NUMBER_2){
//					next_state = ROLL_MONITOR_STATE;
//				}else if(event == HASHTAG){
//					next_state = TARGET_ROLL_STATE;
//				}else{
//					next_state = ROLL_MONITOR_STATE;
//				}
				if(event == HASHTAG){
					next_state = TARGET_ROLL_STATE;
				}	else{
					next_state = ROLL_MONITOR_STATE;
				}
				break;
			case TARGET_PITCH_STATE:
//				if(event == NUMBER_1){
//					next_state = TARGET_PITCH_STATE;
//				}else if(event == NUMBER_2){
//					next_state = ROLL_MONITOR_STATE;
//				}else if(event == HASHTAG){
//					next_state = PITCH_MONITOR_STATE;
//				}else{
//					next_state = TARGET_PITCH_STATE;
//				}
			
				if(event == HASHTAG){
					next_state = ROLL_MONITOR_STATE;
				}	else{
					next_state = TARGET_PITCH_STATE;
				}
				break;
			case TARGET_ROLL_STATE:
//				if(event == NUMBER_1){
//					next_state = PITCH_MONITOR_STATE;
//				}else if(event == NUMBER_2){
//					next_state = TARGET_ROLL_STATE;
//				}else if(event == HASHTAG){
//					next_state = ROLL_MONITOR_STATE;
//				}else{
//					next_state = TARGET_ROLL_STATE;
//				}
			
				if(event == HASHTAG){
					next_state = PITCH_MONITOR_STATE;
				}	else{
					next_state = TARGET_ROLL_STATE;
				}
				break;
		}
	}
	osSemaphoreWait(state_sem, osWaitForever);
	state = next_state;
	osSemaphoreRelease(state_sem);
	
	printf("End State: ");
	printState(state);
	return 0;
}

