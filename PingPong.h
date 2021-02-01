/**
 * In this header we define the PingPongMsg struct which
 * contains the data of the packets transmitted from one
 * mote to the other.
 * The mote_id variable stores the sender mote ID, while
 * the check variable informs the receiver on the game's
 * state.
 *
 * The check variable's values are pre-defined as STOPPED
 * and RUNNING in the enum below.
 */

#ifndef PING_PONG_H
#define PING_PONG_H

typedef nx_struct PingPongMsg{
	nx_uint16_t mote_id;
	nx_uint8_t check;
} PingPongMsg_t;

enum {
	STOPPED = 0,
	RUNNING = 1
};

#endif
