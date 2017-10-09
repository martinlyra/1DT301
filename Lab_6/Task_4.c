#include <avr/io.h>
#include <stdio.h>
#include <stdlib.h>

#define BAUD_RATE 25

#define LINE_LIMIT			2
#define LINE_CHAR_LIMIT		24

#define PAYLOAD_MAX_SIZE 	48
#define COMMAND_SIZE		5
#define FRAME_SIZE 			(2 + COMMAND_SIZE + PAYLOAD_MAX_SIZE)
#define BUFFER_SIZE 		(FRAME_SIZE + 3 + 1)

#define VAILD_DIGITS		"12"
//#define VAILD_DIGITS		"0123456789"

int current_line = 0;
char line_selection = 0;
char lines[8][24] = { "", "", "", "", "", "", "", "" };

void initialize(void);
void urat_init(void);
void urat_send(char);
char urat_read(void);
char strcon_char(char*, char);
void boardcast(char, char*, char*);
void refresh_display(void);
void change_line(int);

int main(void) 
{
	initialize();
	
	refresh_display();	
	
	while (1)
	{
		char in = urat_read();

		if (line_selection)
		{
			if (in < '1') continue;

			if (strcon_char(VAILD_DIGITS, in))
			{
				change_line((in - '1'));
				line_selection = 0;
			}
		}
		else {
			if (in == '>')
				line_selection = 1;
			else if (in == '/' || in == 13 || in == '\n')	
				change_line(-1);
			else
			{
				char* line = lines[current_line];
				sprintf(line, "%s%c", line, in);
			}
		}

		refresh_display();
	}	

	return 0;
}

void initialize(void) 
{
	urat_init();

	//						 ************************ - 24 char limit
	//boardcast('A', "O0001", " ");
	boardcast('B', "O0001", " ");
	boardcast('Z', "D001", 0);
}

void urat_init(void)
{
	UBRR1L = BAUD_RATE;
	UCSR1B = (1 << RXEN1) | (1 << TXEN1);
}

void urat_send(char character)
{
	while ( !(UCSR1A & (1<<UDRE1)) ) ; // while the data register is NOT empty, do nothing

	UDR1 = character;
}

char urat_read(void)
{
	while ( !(UCSR1A & (1<<RXC1)) ) ;

	return UDR1;
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

char strcon_char(char* string, char c)
{
	char t;
	while ((t = *string++)) 
		if (t == c) return 1;
	return 0;
}

void refresh_display()
{
	char memory_space_A[48] = "";
	char line_display = line_selection ? '_' : (current_line + '1');

	//						 ************************ - 24 char limit
	sprintf(memory_space_A, "Enter input: (Line %c)  %s", line_display, lines[0]);

	char memory_space_B[48] = "";
	for (int i = 0; i < 48; i++)
		memory_space_B[i] = lines[1][i];

	boardcast('A', "O0001", memory_space_A);
	boardcast('B', "O0001", memory_space_B);
	boardcast('Z', "D001", 0);
}

void change_line(int target)
{
	if (target == -1) // increment
	{
		current_line++;
		if (current_line >= LINE_LIMIT)
			current_line = 0;
	}
	else // change to selection
		current_line = target;
}
