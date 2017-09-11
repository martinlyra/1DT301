;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;	1DT301, Computer Technology I
;	Date: 2016 - 09 - 11
;	Author:
;		Martin Lyrå
;		Yinlong Yao
;
;	Lab number: 2
;	Title: Subroutines
;
;	Hardware: STK600, CPU ATmega2560
;
;	Function: Runs a ring counter on all LEDs (LED0 to LED7)
;
;	Input ports: None
;
;	Output ports: PORTB
;
;	Subroutines: wait_milliseconds
;
;	Included files: m2560def.inc
;
;	Other information:
;
;	Changes in program:
;		2017-09-11: File created
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

.include "m2560def.inc"

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; Initialization
;
; Initialize stack pointer
ldi r16, low(RAMEND)
out SPL, r16
ldi r16, high(RAMEND)
out SPH, r16

ldi r31, 0b11111110 			; Initialize register 31 (r31) for ring counter function

ldi r16, 0xFF				; Set up PORTB as output
out DDRB, r16	

.DEF OUTPUT = r16

ldi OUTPUT, $1

rjmp main
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; wait_milliseconds
; Parameters: integer (r25:r24)
; Purpose: Wait N milliseconds
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
wait_milliseconds:
	L0:
	sbiw r25:r24, 1			; 16-bit decrementation by subtraction
	brne L0				; Continue until the 16-bit value is 0x00
	nop
ret

main:
	out PORTB, OUTPUT		; OUTPUT was initialized, put it out right away

	ldi r24, low(500)		; Load an integer to register pair r25:r24
	ldi r25, high(500)
	rcall wait_milliseconds		; Call the delay subroutine

	lsl OUTPUT			; Do the actual function

rjmp main				; Loop back to main
