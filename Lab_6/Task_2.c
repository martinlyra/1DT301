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
void urat_send(char);
void boardcast_message(char*);
void boardcast(char, char*, char*);

int main(void) {
	initialize();		
	
	boardcast('A', "O0001", "****Brodje met kaas!**********Second line!******");
	boardcast('B', "O0001", "******Third line!*******");
	boardcast('Z', "D001", 0);

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
	boardcast('A', "O0001", string);
}

void boardcast(char memory, char* command, char* string)
{
	int cmd_length = sizeof(command)/sizeof(char);
	int msg_length = sizeof(string)/sizeof(char);

	int buffer_size = 1 + cmd_length + msg_length + 3;
	char* buffer = malloc(buffer_size*sizeof(char));

	sprintf(buffer, "\r%c%s%s", memory, command, string);

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
