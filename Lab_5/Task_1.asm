;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;	1DT301, Computer Technology I
;	Date: 2016 - 10 - 02
;	Author:
;		Martin Lyrå
;		Yinlong Yao
;
;	Lab number: 5
;	Title: Display JHD202
;
;	Hardware: STK600, CPU ATmega2560, Display JHD202
;
;	Function: Displays the character '%' on the display
;
;	Input ports:
;
;	Output ports: PORTE
;
;	Subroutines: 
;
;	Included files: m2560def.inc, common.inc
;
;	Other information: common.inc contains code used by all
;	tasks for this lab
;
;	Changes in program:
;		2017-10-02: File created
;		2017-10-03: Documentation
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

.include "m2560def.inc"
.equ PERCENT_CHAR = 0b0010_0101

.cseg
.org 0x00
jmp reset

.org 0x72
.include "./common.inc"	; common code used for tasks 1-4
reset:

; Initialize stack pointer (important)
ldi tmp, low(RAMEND)
out SPL, tmp
ldi tmp, high(RAMEND)
out SPH, tmp

call init_display	; Look inside common.inc for code

ldi dat, PERCENT_CHAR	; Load character to data register
call display_write_char	; Display it

main: 
	nop
	rjmp main
