#include <avr/io.h>
#include <stdio.h>
#include <stdlib.h>

#define F_CPU 1843200UL
#include <util/delay.h>

#define BAUD_RATE 25 // 2400 bps
#define DELAY 1000 // in ms

// Supposed constant
char* NAMES[] = {
	"Martin Lyraa",
	"Yinlong Yao"
};

// Forward declaration
void initialize(void);
void urat_init(void);
void urat_send(char);
void boardcast(char, char*, char*);

// Entry point
int main(void) {
	initialize();		
	
	//						 ************************ - 24 char limit per line
	boardcast('A', "O0001", "Computer Technology     Assignment #6");
	boardcast('B', "O0001", "");
	boardcast('Z', "D001", 0);

	// Changes name after a delay of 1 second (1000 ms), loops forever
	while (1) {
		for (int i = 0; i < 2; i++)
		{
			boardcast('B', "O0001", NAMES[i]);
			boardcast('Z', "D001", 0); // The update command must be sent for the change to show
			_delay_ms(DELAY);
		}
	}

	return 0;
}

//
// initialize
// Handles all initialization
//
void initialize(void) {
	urat_init();
}

//
// urat_init
// Prepares the URAT1 port for use
//
void urat_init(void)
{
	UBRR1L = BAUD_RATE;
	UCSR1B = ((1 << RXEN1) | (1 << TXEN1)); // Enable receive and transmission
}

//
// urat_send
// Transmits character to Serial on URAT1
//
void urat_send(char character)
{
	while ( !(UCSR1A & (1<<UDRE1)) ) ; // wait until the data register is empty
	UDR1 = character;
}

//
// boardcast
// Assemble the input data into a packet then transmit it on URAT
//
void boardcast(char memory, char* command, char* string)
{
	// Get lengths
	int cmd_length = sizeof(command)/sizeof(char);
	int msg_length = sizeof(string)/sizeof(char);

	// Calculate and allocate memory for buffer string
	int buffer_size = 1 + cmd_length + msg_length + 3;
	char* buffer = malloc(buffer_size*sizeof(char));

	// Assemble the frame (payload)
	sprintf(buffer, "\r%c%s%s", memory, command, string);

	// Calculate the checksum
	unsigned int checksum = 0;
	for (int i = 0; (buffer[i] != 0); i++)
		checksum += buffer[i];
		
	checksum %= 256;

	// Final assembly of string
	sprintf(buffer, "%s%02X\n", buffer, checksum);

	// Send all chars in string
	for (int i = 0; buffer[i]; i++)
		urat_send(buffer[i]);

	free(buffer); // we are done with the buffer
}