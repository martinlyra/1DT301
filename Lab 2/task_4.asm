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
;		2017-09-14: Redid delay and pattern code
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

.include "m2560def.inc"

.EQU DELAY	= 500	;ms 

.DEF OUTPUT = r16

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

ldi OUTPUT, 0x01

rjmp main
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; wait_milliseconds
; Parameters: integer (r25:r24)
; Purpose: Wait N milliseconds
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
wait_milliseconds:
	push r16			; Store data in r16 and r17 to the stack first
	push r17

	; These instructions take approx 1 ms to complete on ATMEGA2560
	L0:
	ldi r16, low(500)
	ldi r17, high(500)

	L1:
	dec r16
	nop
	brne L1				
	dec r17
	nop
	brne L1

	; To gain N delay, repeat above instructions N times with this
	sbiw r25:r24, 1			; 16-bit decrementation by subtraction
	brne L0				; Continue until the 16-bit value is 0x00

	pop r17				; Return stored data to r16 and r17 from stack
	pop r16
ret

main:
	com OUTPUT
	out PORTB, OUTPUT		; OUTPUT was initialized, put it out right away
	com OUTPUT

	ldi r24, low(DELAY)		; Load an integer to register pair r25:r24
	ldi r25, high(DELAY)
	rcall wait_milliseconds		; Call the delay subroutine

	ldi r17, 0
	lsl OUTPUT			; Do the actual function
	adc OUTPUT, r17	

rjmp main				; Loop back to main
