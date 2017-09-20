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
;				featuring blinkers, sans braking lights -
;				see Task_4.asm for this feature.
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
.DEF ABORT = r18

.EQU STATE_TURN_R = 0x01
.EQU STATE_TURN_L = 0x02

.org 0x00
jmp reset
.org 0x02
jmp ext_interrupt_0				; Interrupt handler for INT0
.org 0x04
jmp ext_interrupt_1				; Interrupt handler for INT1

.org 0x72
reset:

; Initialize stack pointer
ldi r16, low(RAMEND)
out SPL, r16
ldi r16, high(RAMEND)
out SPH, r16

ldi r16, 0x00
out DDRD, r16 					; D is input
ldi r16, 0xFF
out DDRB, r16 					; B is output

ldi r16, (1<<INT0 | 1 << INT1)	; Enable INT0 and INT1
out EIMSK, r16

ldi r16, 0b0000_0101			; Enable trigger for both raising and falling edges for both INT0 & INT1
sts EICRA, r16

sei								; Enable global interrupts (important)

main:
	clr OUTPUT					; Wipe the output clean

	cpi STATE, STATE_TURN_R		; Are we turning right?
	brne case_2					
		ldi OUTPUT, 0b1100_0000
		rcall ring_right		; Assemble a ring counter to r19
		add OUTPUT, r19			; Add the effect to the output
		rjmp end_if
	case_2:						; We aren't - are we turning left?
	cpi STATE, STATE_TURN_L
	brne default
		ldi OUTPUT, 0b0000_0011	
		rcall ring_left			; Assemble a ring counter to r19
		add OUTPUT, r19			; Add the effect to the output.
		rjmp end_if
	default:					; Nope, we ain't turning.
		ldi OUTPUT, 0b1100_0011
	end_if:

	com OUTPUT					; Invert all bits, the LEDs are active low (high by default)
	out PORTB, OUTPUT			
	rcall delay					; Wait ~500ms before proceeding
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
;			an interrupt has been triggered.
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
delay:
	push r19
	
	ldi r19, 2					; Innner counter
	ldi r20, 2					; Center counter
	ldi r21, 2					; Outer counter

	DL1:
		cpi ABORT, -1			; Immediately abort delay if button has been pressed
		breq _abort

		dec r19
		brne DL1

		dec r20
		brne DL1

		dec r21
		brne DL1
		nop

	_abort:
	ldi ABORT, -0

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
