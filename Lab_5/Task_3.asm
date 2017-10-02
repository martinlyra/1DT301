.include "m2560def.inc"

; 25 = 2400 bps
; 12 = 4800 bps
; 6 = 9600 bps

.equ UBRR_DEFAULT = 12

.cseg
.org 0x00
jmp reset

.org URXC1addr	; URXC1addr - receive complete for USART1
jmp urxc1_handler

.org 0x72
.include "./common.inc"	; common code used for tasks 1-4
reset:

ldi tmp, low(RAMEND)
out SPL, tmp
ldi tmp, high(RAMEND)
out SPH, tmp

ser tmp
out DDRC, tmp
out PORTC, tmp

ldi tmp, UBRR_DEFAULT	; Set Baud rate
sts UBRR1L, tmp

ldi tmp, (1<<RXEN1 | 1<<RXCIE1)	; Enable receive flag and receive interrupt for URAT0
sts UCSR1B, tmp

sei

call init_display

call display_clear

main: 
	nop
	rjmp main

urxc1_handler:
	push tmp

	lds tmp, UDR1		; Get input from data register
	mov	dat, tmp
	call display_write_char

	pop tmp
reti
