#include <avr/io.h>
#include <stdio.h>
#include <stdlib.h>

#define BAUD_RATE 25 // 2400 bps

#define LINE_LIMIT 2 // change this to 8 for Task 5
#define LINE_CHAR_LIMIT	24

#define CHAR_SEL '>' // Char for line selection
#define CHAR_EOL '/' // Char for new line (end of line)

#define VAILD_DIGITS "12"
//#define VAILD_DIGITS "12345678" // Uncomment this line for Task 5
//#define VAILD_DIGITS "0123456789"

// "Global" variables
int current_line = 0;
char line_selection = 0;
char lines[8][LINE_CHAR_LIMIT] = { "", "", "", "", "", "", "", "" };

// Forward declaration
void initialize(void);
void urat_init(void);
void urat_send(char);
char urat_read(void);
void boardcast(char, char*, char*);
char string_contains(char*, char);
void refresh_display(void);
void change_line(int);

// Entry point
int main(void) 
{
	initialize();
	
	while (1) {
		char in = urat_read(); // Get input

		// Pharse the input - if selecting line, anticipate a [vaild] digit
		if (line_selection) {
			if (in < '1') continue; // if smaller than 0, ignore

			// Does 'in' exist in VAILD_DIGITS? (Is 'in' a vaild digit?)
			if (string_contains(VAILD_DIGITS, in)) {
				change_line((in - '1')); // turn the input into a sterile integer before passing to function
				line_selection = 0;
			}
		}
		else {
			// Select line
			if (in == CHAR_SEL)
				line_selection = 1;
			// End of line
			else if (in == CHAR_EOL || in == 13 || in == '\n')// increment
				change_line(-1); // increment
			// Normal appending
			else {
				// Else add character to end of selected line
				char* line = lines[current_line]; 
				sprintf(line, "%s%c", line, in);
			}
		}

		refresh_display(); // Update the screen
	}	

	return 0;
}

//
// initialize
// Handles all initialization
//
void initialize(void) 
{
	urat_init();
	
	refresh_display(); // Initialize the default state for the screen too
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
// urat_read
// Waits for input, then returns input char
//
char urat_read(void)
{
	while ( !(UCSR1A & (1<<RXC1)) ) ; // wait until receive has been completed
	return UDR1;
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

// 
// string_contains
// Checks string for target char 'c', returns 1 (true) if found, otherwise 0 (false)
// 
char string_contains(char* string, char c)
{
	char t;
	while ((t = *string++)) 
		if (t == c) return 1;
	return 0;
}

//
// refresh_display
// Updates the display 
//
void refresh_display()
{
	// Set up lines to show
	int display_line = current_line;
	if (display_line < 1)
		display_line++;
	
	// Set up variables necessary for the first & second display line
	char memory_space_A[48] = "";
	char line_selected = line_selection ? '_' : (current_line + '1');

	// Assemble the header line then copy line 1 to end
	//						 ************************ - 24 char limit
	sprintf(memory_space_A, "Enter input: (Line %c)  %s", line_selected, lines[display_line-1]);

	// Set up the third display line, then copy chars from memory to it
	char memory_space_B[48] = " ";
	if (lines[display_line][0]) // Is selected string just a '\0'? If true; do nothing
		for (int i = 0; i < 48; i++) 
			memory_space_B[i] = lines[display_line][i];

	// Boardcast all changes and then update the screen
	boardcast('A', "O0001", memory_space_A);
	boardcast('B', "O0001", memory_space_B);
	boardcast('Z', "D001", 0);
}

//
// change_line
// Increments (when target is -1) or sets current_line to 'target' line
//
void change_line(int target)
{
	// increment
	if (target == -1) {
		current_line++;
		if (current_line >= LINE_LIMIT)
			current_line = 0;
	}
	else // change to selection
		current_line = target;
}
