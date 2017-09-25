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
ldi temp, LOW(RAMEND)
out SPL, temp
ldi temp, HIGH(RAMEND)
out SPH, temp

ldi temp, 0xFF
out DDRB, temp
out PORTB, temp

ldi temp, UBRR_DEFAULT
sts UBRR0L, temp

ldi temp, (1<<RXEN0 | 1<<TXEN0 | 1<<RXCIE0)
sts UCSR0B, temp

sei

main:
rjmp main

urxc0_handler:
	push temp
	in temp, SREG
	push temp

	lds input, UDR0
	mov temp, input
	com temp
	out PORTB, temp

	lds temp, UCSR0B
	ori temp, 1<<UDRIE0
	sts UCSR0B, temp

	pop temp
	out SREG, temp
	pop temp
reti

udre0_handler:
	push temp
	in temp, SREG
	push temp

	sts UDR0, input
	clr input

	lds temp, UCSR0B
	cbr temp, 1<<UDRIE0
	sts UCSR0B, temp

	pop temp
	out SREG, temp
	pop temp
reti
