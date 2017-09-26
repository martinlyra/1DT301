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
;				Using interrupts.
;
;	Input ports: URAT0
;
;	Output ports: PORTB, URAT0
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

.equ UBRR_DEFAULT = 12

.def temp = r16
.def input = r17

.cseg
.org 0x00
jmp reset

.org 0x32	; URXC0addr - receive complete for USART0
jmp urxc0_handler
.org 0x34	; UDRE0addr - data buffer empty for USART0
jmp udre0_handler

.org 0x72
reset:
; Initialize stack pointer
ldi temp, LOW(RAMEND)
out SPL, temp
ldi temp, HIGH(RAMEND)
out SPH, temp

ldi temp, 0xFF			; Initialize PORTB as output and all LEDs extinguished
out DDRB, temp
out PORTB, temp

ldi temp, UBRR_DEFAULT	; Set Baud rate
sts UBRR0L, temp

ldi temp, (1<<RXEN0 | 1<<TXEN0 | 1<<RXCIE0)	; Enable receive, transmit, and receive interrupt for URAT0
sts UCSR0B, temp

sei						; Enable global interrupts

main:
rjmp main

urxc0_handler:
	push temp
	in temp, SREG
	push temp

	lds input, UDR0		; Get input from data register
	mov temp, input		
	com temp
	out PORTB, temp		; Display the output on PORTB

	lds temp, UCSR0B
	ori temp, 1<<UDRIE0	; Enable data register empty interrupt for URAT0
	sts UCSR0B, temp

	pop temp
	out SREG, temp
	pop temp
reti

udre0_handler:
	push temp
	in temp, SREG
	push temp

	sts UDR0, input		; Transmit the input on the serial connection
	clr input			; We are done - clear the input

	lds temp, UCSR0B
	cbr temp, 1<<UDRIE0	; Disable data register empty interrupt for URAT0
	sts UCSR0B, temp

	pop temp
	out SREG, temp
	pop temp
reti
