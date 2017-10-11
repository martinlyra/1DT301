#include <avr/io.h>
#include <stdio.h>
#include <stdlib.h>

#define BAUD_RATE		25 // 2400 bps

#define DISPLAY_CHAR	'L'

// Forward declaration
void initialize(void);
void urat_init(void);
void urat_send(char character);
void boardcast_message(char* string);

// Entry point
int main(void) {
	initialize();		
	
	// Set display's memory to display 'L'
	boardcast_message(DISPLAY_CHAR);

	// Send the update screen command
	char* tmp = "\rZD0013C\n";
	char dat;
	while ((dat = *tmp++))
		urat_send(dat);

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
	UCSR1B = ((1 << RXEN1) | (1 << TXEN1));
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
// boardcast_message
// Compiles the string into an appropriate packet then transmits out on the Serial port
//
void boardcast_message(char* string)
{
	int length = sizeof(string)/sizeof(char);
	int buffer_size = 7 + length + 3;
	
	char* buffer = malloc(buffer_size*sizeof(char)); // prepare some empty space for the string

	// Assemble the frame (payload)
	sprintf(buffer, "\rAO0001%s", string);

	// calculate the checksum
	unsigned int checksum = 0;
	for (int i = 0; (buffer[i] != 0); i++)
		checksum += buffer[i];
		
	checksum %= 256;

	// Final assembly of the string
	sprintf(buffer, "%s%02X\n", buffer, checksum);

	// Send all chars in string
	for (int i = 0; buffer[i]; i++)
		urat_send(buffer[i]);

	free(buffer); // we are done
}
