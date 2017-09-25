;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;	1DT301, Computer Technology I
;	Date: 2016 - 09 - 18
;	Author:
;		Martin Lyrå
;		Yinlong Yao
;
;	Lab number: 3
;	Title: Interrupts
;
;	Hardware: STK600, CPU ATmega2560
;
;	Function: 	Simulates the taillights of a Ford Mustang,
;				featuring blinkers and braking lights.
;
;	Input ports: PORTD
;
;	Output ports: PORTB
;
;	Subroutines: 
;	- 	ring_right
;	-	ring_left
;	-	ext_interrupt_0
;	-	ext_interrupt_1
;	-	ext_interrupt_2
;
;	Included files: m2560def.inc
;
;	Other information:
;
;	Changes in program:
;		2017-09-18: File created
;		2017-09-20: Documentation
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

.include "m2560def.inc"

.DEF OUTPUT = r16
.DEF STATE = r17
.DEF DEFAULT = r18
.DEF ABORT = r22

.EQU STATE_TURN_R = 0x01
.EQU STATE_TURN_L = 0x02

.EQU STATE_BRAKES_H = 0b1111_1111
.EQU STATE_BRAKES_L = 0b1100_0011

.org 0x00
jmp reset
.org INT0addr
jmp ext_interrupt_0		; Interrupt handler for INT0 - right blinker
.org INT1addr
jmp ext_interrupt_1		; Interrupt handler for INT1 - left blinker
.org INT2addr
jmp ext_interrupt_2		; Interrupt handler for INT2 - brakes

.org 0x72
reset:

; Initialize stack pointer
ldi r16, low(RAMEND)
out SPL, r16
ldi r16, high(RAMEND)
out SPH, r16

ldi r16, 0x00
out DDRD, r16 			;D is input
ldi r16, 0xFF
out DDRB, r16 			;B is output

ldi r16, 0b0000_0111	; Enable INT0, INT1, and INT2
out EIMSK, r16

ldi r16, 0b0001_0101	; Set trigger for all edges (pos + neg) for INT0, 1, and 2.
sts EICRA, r16

sei						; Enable global interrupts

ldi DEFAULT, STATE_BRAKES_L
main:
	mov OUTPUT, DEFAULT				; Wipe the output clean by copying from the DEFAULT
	cpi STATE, STATE_TURN_R			; Are we turning right?
	brne case_2
		rcall ring_right			; Assemble right-facing ring effect to r19
		andi OUTPUT, 0b1111_0000	; Apply bitmask
		add OUTPUT, r19				; Add effect to output
		rjmp end_if
	case_2:
	cpi STATE, STATE_TURN_L			; If not, are we turning left?
	brne end_if
		rcall ring_left				; Assemble left-facing ring effect to r19
		andi OUTPUT, 0b0000_1111	; Apply bitmask
		add OUTPUT, r19				; Add effect to output
	end_if:

	com OUTPUT						; Invert all bits, the LEDs are active low (high by default)
	out PORTB, OUTPUT			
	rcall delay						; Wait ~500ms before proceeding
rjmp main

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ring_right
; Parameters: n/a
; Purpose:	Assembles a 4-bit ring counter moving to right,
;			the result is saved to register 19 (r19)
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
ring_right:
	cpi r19, 0b0001_0000		; Check if we are using results from the left-facing ring counter
	brge C1
	cpi r19, 0b0000_0010		; If above is false, check if our bit is at LSB or lower
	brlo C1
		lsr r19					; If none of above are true, shift the bit one step to right
		ret
	C1:
		ldi r19, 0b0000_1000	; Otherwise, reset the state back to default
ret

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ring_left
; Parameters: n/a
; Purpose:	Assembles a 4-bit ring counter moving to left,
;			the result is saved to register 19 (r19)
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
ring_left:
	cpi r19, 0b0001_0000		; Check if we are using results from the right-facing counter
	brlo C2
	cpi r19, 0b1000_0000		; If above is false, check if our bit is at MSB or greater
	breq C2
		lsl r19					; If none of above are true, shift the bit one step to left
		ret
	C2:
		ldi r19, 0b0001_0000	; Otherwise, reset the state back to default.
ret

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; delay
; Parameters: n/a
; Purpose: 	Delay with less than 500 ms, aborts when 
;		an interrupt has been triggered (not in use here).
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
delay:
	push r19
	push r20
	
	ldi r19, 2					; Innner counter
	ldi r20, 2					; Center counter
	ldi r21, 2					; Outer counter

	DL1:
		;cpi ABORT, -1			; Immediately abort delay if button has been pressed
		;breq _abort

		dec r19
		brne DL1

		dec r20
		brne DL1

		dec r21
		brne DL1
		nop

	;_abort:
	;ldi ABORT, -0

	pop r20
	pop r19
	ret

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ext_interrupt_0
; Parameters: n/a
; Purpose: 	When triggered, turns the right blinker on/off
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
ext_interrupt_0:
	push r16

	ldi r16, STATE_TURN_R		; Retrieve a bitmask

	and r17, r16				; Apply bitmask

	cpi r17, 0					; Check if we are turning right
	brne turning_right
		ldi r17, STATE_TURN_R	; If false, turn the right blinker on
		ldi r19, 0b0000_1000
		pop r16
		reti

	turning_right:				; If true, turn the right blinker off
		ldi r17, 0
		pop r16
reti

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ext_interrupt_1
; Parameters: n/a
; Purpose: 	When triggered, turns the left blinker on/off
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
ext_interrupt_1:
	push r16

	ldi r16, STATE_TURN_L		; Retrieve a bitmask

	and r17, r16				; Apply bitmask

	cpi r17, 0					; Check if we are turning left
	brne turning_left
		ldi r17, STATE_TURN_L	; If false, turn the left blinker on
		ldi r19, 0b0001_0000
		pop r16
		reti

	turning_left:
		ldi r17, 0				; If true, turn the left blinker off
		pop r16
reti

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ext_interrupt_1
; Parameters: n/a
; Purpose: 	When triggered, toggles the braking lights on/off
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
ext_interrupt_2:
	cpi DEFAULT, STATE_BRAKES_H	; Are we already braking?
	breq C3
		ldi DEFAULT, STATE_BRAKES_H	; No - Use the breaking lights
		reti
	C3:
		ldi DEFAULT, STATE_BRAKES_L	; Yes - Use the normal taillights
reti
