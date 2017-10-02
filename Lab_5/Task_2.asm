.include "m2560def.inc"

.equ COUNTER_MAX = 75

.cseg
.org 0x00
jmp reset

.org 0x04
jmp ext_interrupt1_handler

.org 0x72
.include "./common.inc"	; common code used for tasks 1-4

.def COUNTER = r19 ; registers 16 to 18 are already in use in common.inc

reset:

ldi tmp, low(RAMEND)
out SPL, tmp
ldi tmp, high(RAMEND)
out SPH, tmp

clr tmp
out DDRD, tmp

;ser tmp
;out DDRC, tmp
;out PORTC, tmp

ldi tmp, (1<<INT1)
out EIMSK, tmp

ldi tmp, 0b0000_1100
sts EICRA, tmp

sei

call init_display

main: 
	rcall tick
	nop
	nop
	nop
	rjmp main

tick:
	inc counter

	cpi counter, COUNTER_MAX
	brlo skip0
		clr counter
	skip0:
ret

ext_interrupt1_handler:
	rcall display_counter
reti

display_counter:
	push tmp
	mov tmp, counter
	push counter
	clr counter

	;out PORTC, tmp

	L0:
	cpi tmp, 10		; while tmp >= 10
	brlo E0
		subi tmp, 10
		inc counter
		rjmp L0
	E0:

	call display_clear

	ldi dat, 0b0011_0000
	or dat, counter
	call display_write_char

	ldi dat, 0b0011_0000
	or dat, tmp
	call display_write_char

	pop counter
	pop tmp
ret
