## Serial communication for task 3, 4, & 5
In order to communicate with the board through serial. We used an application named PuTTY that came pre-installed on our computers.

1. Start up PuTTY
2. Select Session, then select "Serial" radio button
3. Select the appropriate serial line, our case was COM1
4. Select the correct [Baud] speed, since our UBRR was set to 12; 4800, we used 4800.
	* 25 => 2400
	* 12 => 4800
	* 6 => 9600
5. Press Open, a terminal should open

PS: Don't worry if there are no feedback on the terminal, you won't get any unless your board is supposed to transmit. Although this might depends on your choice of terminal (and if it matters, the version too).

Note: Make sure you are using the correct flags in the code (RXEN to enable the board the ability to receive serial signals, TXEN for transmitting serial signals), we learned this mistake by the slow way.
