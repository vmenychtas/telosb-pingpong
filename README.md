# TelosB-PingPongApp

This is an implementation of a ping pong application written in nesC for the TelosB mote, running on TinyOS.


The application runs and stops by pressing the user button located on the mote.
Using two motes, the application starts by broadcasting a packet from the mote
which got it's button pressed first. Upon receiving the packet, the second mote
turns on it's LED, waits for 2 seconds and then turns it off again before it
broadcasts it's packet. The application stops when either of the two motes has
it's user button pressed.
