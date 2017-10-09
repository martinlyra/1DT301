#include <avr/io.h>
#include <stdio.h>
#include <stdlib.h>

#define BAUD_RATE 25

#define BOARDCAST_START 0x0D
#define BOARDCAST_END 0x0A

#define PAYLOAD_MAX_SIZE 	48
#define COMMAND_SIZE		5
#define FRAME_SIZE 			(2 + COMMAND_SIZE + PAYLOAD_MAX_SIZE)
#define BUFFER_SIZE 		(FRAME_SIZE + 3 + 1)

void initialize(void);
void urat_init(void);
void urat_send(char character);
void boardcast_message(char* string);
//void boardcast_command(const char* string);

int main(void) {
	initialize();		
	
	boardcast_message(DISPLAY_CHAR);

	char* tmp = "\rZD0013C\n";
	char dat;
	while ((dat = *tmp++))
		urat_send(dat);

	return 0;
}

void initialize(void) {
	urat_init();
}

void urat_init(void)
{
	UBRR1L = BAUD_RATE;
	UCSR1B = ((1 << RXEN1) | (1 << TXEN1));
}

void urat_send(char character)
{
	while ( !(UCSR1A & (1<<UDRE1)) ) ; // while the data register is NOT empty, do nothing

	UDR1 = character;
}

void boardcast_message(char* string)
{
	int length = sizeof(string)/sizeof(char);

	int buffer_size = 7 + length + 3;
	char* buffer = malloc(buffer_size*sizeof(char));

	sprintf(buffer, "\rAO0001%s", string);

	// calculate the checksum
	unsigned int checksum = 0;
	for (int i = 0; (buffer[i] != 0); i++)
		checksum += buffer[i];
		
	checksum %= 256;

	sprintf(buffer, "%s%02X\n", buffer, checksum);

	for (int i = 0; buffer[i]; i++)
		urat_send(buffer[i]);

	free(buffer);
}
