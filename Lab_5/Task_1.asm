.include "m2560def.inc"
.equ PERCENT_CHAR = 0b0010_0101

.cseg
.org 0x00
jmp reset

.org 0x72
.include "./common.inc"	; common code used for tasks 1-4
reset:

ldi tmp, low(RAMEND)
out SPL, tmp
ldi tmp, high(RAMEND)
out SPH, tmp

call init_display

ldi dat, PERCENT_CHAR
call display_write_char

main: 
	nop
	rjmp main
