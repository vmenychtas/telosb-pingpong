/**
 * This file contains the code of our application. Here we define the
 * interfaces required and the functions served by the events available.
 */

// We include the UserButton.h so we can make use of the button_state_t
// which is necessary for using the "Notify" interface. We also include
// our own PingPong.h which defines the type of the transmitted messages.
#include <UserButton.h>
#include "PingPong.h"

module PingPongC{
	uses{
		interface Boot;
		interface Leds;
		// We track the LED's time of operation using the Timer<TMilli>
		// interface. The "startOneShot" command activates the timer for
		// 2 seconds while the "fired" event signifies the timer's halt
		// and runs the necessary code.
		interface Timer<TMilli> as Timer0;

		// The "Notify" interface provides the "notify" event
		// which we make use of when the user button changes state.
		interface Notify<button_state_t>;

		// The "Packet" interface provides the "getPayload" which is used for
		// creating the packet, the "AMSend" interface provides "send" for
		// sending the packet, while the "Receive" interface provides "receive"
		// for receiving it. We use the "SplitControl" interface to enable and
		// disable our application's components.
		interface Packet;
		interface AMSend;
		interface Receive;
		interface SplitControl;
	}
}

implementation{
	uint8_t gameStatus = STOPPED;	// the game's status flag
	bool commBusy = FALSE;	// packet's transmission state flag
	message_t packet;			// this variable is the packet that's sent
	PingPongMsg_t* message;	// pointer to the where the data is written before it's
									// transmitted (packet length is defined by this)

	// Upon booting the mote, we activate the "Notify" and "SplitControl" interfaces.
	event void Boot.booted(){
		call Notify.enable();
		call SplitControl.start();
	}

	// The "fired" event is triggered upon the timer's termination. It serves to
	// disable the LED and inform the other mote of it's turn.
	event void Timer0.fired(){
		call Leds.led2Off();	// LED disabled
		// Checking the game's and the packet transmission's state.
		if ((gameStatus == RUNNING)&&(commBusy == FALSE)){
			// using Packet.getPayload we set the pointer to the to-be-sent packet
			message = call Packet.getPayload(&packet, sizeof(PingPongMsg_t));
			// we then specify the values for the packet's variables
			message->mote_id = TOS_NODE_ID;	// the sender mote's ID
			message->check = gameStatus;		// current game state

			// Using AMSend.send we send the packet and set CommBusy.
			// AMSend.sendDone verifies the packet's transmission state and resets CommBusy.
			if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(PingPongMsg_t)) == SUCCESS){
				commBusy = TRUE;
			}
		}
	}

	// The "notify" function is triggered by the user button's change of state.
	// It's purpose is to start and finish the game and to notify the other mote.
	event void Notify.notify(button_state_t val){
		// The game starts and finishes by having the user button pressed.
		// We check that no other packet is being transmitted
		if ((val == BUTTON_PRESSED)&&(commBusy == FALSE)){
			// and then create the packet using getPayload
			message = call Packet.getPayload(&packet, sizeof(PingPongMsg_t));
			message->mote_id = TOS_NODE_ID;
			// We toggle the game's state
			if (gameStatus == STOPPED){
				gameStatus = RUNNING;
			} else {
				gameStatus = STOPPED;
				// We turn off the mote's LED in case it's on
				call Leds.led2Off();
			}
			message->check = gameStatus;

			// We transmit the packet
			if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(PingPongMsg_t)) == SUCCESS){
				commBusy = TRUE;
			}
		}
	}

	// sendDone is executed upon the transmission's completion
	event void AMSend.sendDone(message_t *msg, error_t error){
		if(msg == &packet){
			commBusy = FALSE;	// commBusy gets reset
		}
	}
	// startDone verifies that the components booted properly
	event void SplitControl.startDone(error_t error){
		// in case of a problem we restart
		if(error == FALSE){
			call SplitControl.start();
		}
	}
	// stopDone verifies that the components deactivated without errors
	// In our implementation we chose not to turn off the components so
	// that we can restart the game without having to reset the mote.
	// Still, we include the function as it's required.
	event void SplitControl.stopDone(error_t error){
	}

	// "receive" handles the incoming packets
	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len){
		// We check that the packet is of the expected size
		if (len == sizeof(PingPongMsg_t)){
			// we make a pointer to the payload of the incoming packet
			PingPongMsg_t* incomingPacket = (PingPongMsg_t*) payload;
			// we verify that the packet comes from another mote
			if (incomingPacket->mote_id != TOS_NODE_ID){
				// we check and update the game's state
				gameStatus = incomingPacket->check;
				if (gameStatus == RUNNING){
					// If the game's still running, we set a timer for 2 seconds
					// and activate the LED. When the timer ends Timer0.fired
					// gets triggered.
					call Timer0.startOneShot(2000);
					call Leds.led2On();
				} else {
					// If the game stopped, we turn of the mote's LED.
					call Leds.led2Off();
				}
			}
		}
		return msg;
	}
}
