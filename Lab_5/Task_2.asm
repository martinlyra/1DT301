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
;	Function: Randomizes a number between 1-75, display on button press (SW1)
;
;	Input ports: PORTD
;
;	Output ports: PORTE, (PORTC)
;
;	Subroutines:
;	-	tick
;	-	interrupt1_handler
;	-	display_counter
;
;	Included files: m2560def.inc, common.inc
;
;	Other information: common.inc contains code used by all
;	tasks for this lab. PORTC is used as output for debugging
;
;	Changes in program:
;		2017-10-02: File created
;		2017-10-03: Documentation
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

.include "m2560def.inc"

.equ COUNTER_MAX = 75

.cseg
.org 0x00
jmp reset

.org 0x04
jmp interrupt1_handler

.org 0x72
.include "./common.inc"	; common code used for tasks 1-4
.def COUNTER = r19 ; registers 16 to 18 are already in use in common.inc

reset:
; Initialize stack pointer
ldi tmp, low(RAMEND)
out SPL, tmp
ldi tmp, high(RAMEND)
out SPH, tmp

; Setup PORTD as input
clr tmp
out DDRD, tmp

; Setup PORTC as output, for debugging purposes
;ser tmp
;out DDRC, tmp
;out PORTC, tmp

; Enable external interrupt 1 as rising edge
ldi tmp, (1<<INT1)
out EIMSK, tmp
ldi tmp, 0b0000_1100
sts EICRA, tmp

sei ; Enable interrupts

call init_display

main: 
	rcall tick
	nop
	nop
	nop
rjmp main

;
; tick
; Purpose: Pseudo-random number generator in the works
;
tick:
	inc counter

	; Clear the counter when it has reached COUNTER_MAX, 75
	cpi counter, COUNTER_MAX
	brlo skip0
		clr counter
	skip0:
ret

;
; interrupt1_handler
; Purpose: Calls display_counter
;
interrupt1_handler:
	rcall display_counter
reti

;
; display_counter
; Purpose: Displays the value of 'counter' on the display.
;
display_counter:
	; Prepare registers
	push tmp
	mov tmp, counter
	push counter
	clr counter

	;out PORTC, tmp	; for debugging purposes

	; Seperate tens to counter, ones to tmp. Via substraction by 10
	L0:
	cpi tmp, 10		; while tmp >= 10
	brlo E0
		subi tmp, 10
		inc counter	; increment for N tens removed from tmp
		rjmp L0
	E0:

	; Clear the display
	call display_clear

	; Display tens
	ldi dat, 0b0011_0000
	or dat, counter
	call display_write_char

	; Display ones
	ldi dat, 0b0011_0000
	or dat, tmp
	call display_write_char

	; Restore registers
	pop counter
	pop tmp
ret
