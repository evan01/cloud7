#ifndef STATE_MACHINE_H
#define STATE_MACHINE_H

typedef enum {
	SLEEP,
	RECORD,
	SEND,
	RECEIVE
}state_e;

extern state_e state = SLEEP;
extern state_e next_state;

#endif
