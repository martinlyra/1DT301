;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;	1DT301, Computer Technology I
;	Date: 2016 - 09 - 25
;	Author:
;		Martin Lyrå
;		Yinlong Yao
;
;	Lab number: 4
;	Title: Timer and URAT
;
;	Hardware: STK600, CPU ATmega2560
;
;	Function: 	Displays a ASCII character on LEDs and on 
;				host computer's terminal from input via serial.
;				Using polling.
;
;	Input ports:
;
;	Output ports: PORTB
;
;	Subroutines: 
;
;	Included files: m2560def.inc
;
;	Other information:
;
;	Changes in program:
;		2017-09-25: File created
;		2017-09-26: Documentation
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
.include "m2560def.inc"

; 25 = 2400 bps
; 12 = 4800 bps
; 6 = 9600 bps

.equ UBRR_DEFAULT = 12	; 4800 bps

.def temp = r16
.def input = r17

.cseg
.org 0x00
jmp reset

.org 0x72
reset:
ldi temp, 0xFF			; Initialize PORTB as output and all LEDs extinguished
out DDRB, temp
out PORTB, temp

ldi temp, UBRR_DEFAULT	; Set Baud rate
sts UBRR0L, temp

ldi temp, (1<<RXEN0 | 1<<TXEN0)	; Enable receive and transmission for URAT0
sts UCSR0B, temp

main:

get_char:

	lds temp, UCSR0A
	sbrs temp, RXC0		; Kkip the instruction below if the receive has been completed
	rjmp get_char

	lds input, UDR0		; Get the input

output:

	com input
	out PORTB, input	; Show the input on PORTB
	com input

send_echo:

	lds temp, UCSR0A
	sbrs temp, UDRE0	; Wait until the previous transmission has been completed (until when Data Register is empty)
	rjmp send_echo

	sts UDR0, input		; Echo to the other host computer - printing the input character on the terminal

rjmp main

