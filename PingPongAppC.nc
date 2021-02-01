/**
 * In this file we the define the components
 * used for the application's implementation
 * along with their wiring.
 */

configuration PingPongAppC{
}

implementation{
	// The main module of our application
	// which we name App.
	components PingPongC as App;

	// These are the required components for Boot
	// the LEDs, the UserButton as well as the Timer.
	components MainC, LedsC;
	components new TimerMilliC() as Timer;
	components UserButtonC;
	// The modules' wiring.
	App.Boot -> MainC;
	App.Leds -> LedsC;
	App.Timer0 -> Timer;
	App.Notify -> UserButtonC;

	// The components required for composing,
	// transmitting and receiving the packets.
	components ActiveMessageC;
	components new AMSenderC(14);
	components new AMReceiverC(14);
	// Wiring of the modules.
	App.Packet -> AMSenderC;
	App.AMSend -> AMSenderC;
	App.Receive -> AMReceiverC;
	App.SplitControl -> ActiveMessageC;
}
