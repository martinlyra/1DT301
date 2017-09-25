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

.org 0x72
reset:
ldi temp, 0xFF
out DDRB, temp
out PORTB, temp

ldi temp, UBRR_DEFAULT
sts UBRR0L, temp

ldi temp, (1<<RXEN0 | 1<<TXEN0)
sts UCSR0B, temp

main:

get_char:

	lds temp, UCSR0A
	sbrs temp, RXC0		; skip if the receive has not been completed
	rjmp get_char

	lds input, UDR0

output:

	com input
	out PORTB, input
	com input

send_echo:

	lds temp, UCSR0A
	sbrs temp, UDRE0
	rjmp send_echo

	sts UDR0, input

rjmp main

