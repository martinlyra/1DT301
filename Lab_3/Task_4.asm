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
jmp ext_interrupt_0	; right blinker
.org INT1addr
jmp ext_interrupt_1	; left blinker
.org INT2addr
jmp ext_interrupt_2	; brakes

.org 0x72
reset:

; Initialize stack pointer
ldi r16, low(RAMEND)
out SPL, r16
ldi r16, high(RAMEND)
out SPH, r16

ldi r16, 0x00
out DDRD, r16 ;D is input
ldi r16, 0xFF
out DDRB, r16 ;B is output

ldi r16, 0b0000_0111
out EIMSK, r16

ldi r16, 0b0001_0101
sts EICRA, r16

sei

ldi DEFAULT, STATE_BRAKES_L
main:
	mov OUTPUT, DEFAULT
	cpi STATE, STATE_TURN_R
	brne case_2
		rcall ring_right
		andi OUTPUT, 0b1111_0000
		add OUTPUT, r19
		rjmp end_if
	case_2:
	cpi STATE, STATE_TURN_L
	brne end_if
		rcall ring_left
		andi OUTPUT, 0b0000_1111
		add OUTPUT, r19
	end_if:

	com OUTPUT
	out PORTB, OUTPUT
	rcall delay
rjmp main

ring_right:
	cpi r19, 0b0001_0000
	brge C1
	cpi r19, 0b0000_0010
	brlo C1
		lsr r19
		ret
	C1:
		ldi r19, 0b0000_1000
ret

ring_left:
	cpi r19, 0b0001_0000
	brlo C2
	cpi r19, 0b1000_0000
	breq C2
		lsl r19
		ret
	C2:
		ldi r19, 0b0001_0000
ret

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; delay
; Parameters: n/a
; Purpose: Delay with less than 500 ms, check for button
; 		   presses meantime
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
delay:
	push r19
	push r20
	
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

	pop r20
	pop r19
	ret

ext_interrupt_0:
	push r16

	ldi r16, STATE_TURN_R

	and r17, r16

	cpi r17, 0
	brne turning_right
		ldi r17, STATE_TURN_R
		ldi r19, 0b0000_1000
		pop r16
		reti

	turning_right:
		ldi r17, 0
		pop r16
reti

ext_interrupt_1:
	push r16

	ldi r16, STATE_TURN_L

	and r17, r16

	cpi r17, 0
	brne turning_left
		ldi r17, STATE_TURN_L
		ldi r19, 0b0001_0000
		pop r16
		reti

	turning_left:
		ldi r17, 0
		pop r16
reti

ext_interrupt_2:
	cpi DEFAULT, STATE_BRAKES_H
	breq C3
		ldi DEFAULT, STATE_BRAKES_H
		reti
	C3:
		ldi DEFAULT, STATE_BRAKES_L
reti
