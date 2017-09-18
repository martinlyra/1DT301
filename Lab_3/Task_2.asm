.include "m2560def.inc"

.org 0x00
jmp reset

.org 0x02
jmp ext_interrupt_0


.DEF STATE = r16
.DEF OUTPUT = r17
.DEF ABORT = r18

.EQU STATE_RING	= -0			; STATE_RING is 0b0000_0000
.EQU STATE_JOHNSON = -1			; STATE_JOHNSON is 0b1111_1111

.org 0x72
reset:
; Initialize stack pointer
ldi r16, low(RAMEND)
out SPL, r16
ldi r16, high(RAMEND)
out SPH, r16

ldi r16,0x00					; Setup PORTA as input
out DDRD, r16

ldi r16, 0xFF					; Setup PORTB as output
out DDRB, r16

ldi r16, 0b0000_0001
out EIMSK, r16

ldi r16, 0b0000_0010
sts EICRA, r16

sei

ldi STATE, STATE_RING			; Load ring as the default state

main:
	cpi STATE, STATE_RING		; Are we doing ring counter?
	brne johnson
	ring:						; Do ring counter
		rcall ring_shift
		rjmp end_if
	johnson:					; Else do Johnson
		rcall johnson_shift
	end_if:

	com OUTPUT					; Invert bits before outputting to PORTB
	out PORTB, OUTPUT
	com OUTPUT					; RETURN back to normal

	rcall delay					; Delay (+ check button) before looping back

	rjmp main

; Code copied from task 6 for lab 1
johnson_shift:
	cpi r22, -0
	breq increment				; If equal to 0 (all bits are zeros), go to increment label
	decrement:
		rcall shift_neg			; Call shift_neg subroutine
		cpi OUTPUT, -0			; Are all leds turned on (all bits are '0's)?
		brne endif				; Break the "if statement" if not
		ldi r22, -0				; If all leds are turned on, switch to increment mode
		jmp endif
	increment:
		rcall shift_pos			; Call shift_pos subroutine
		cpi OUTPUT, -1			; Are all leds turned off (all bits are '1's)?
		brne endif				; Break the "if statement" if not
		ldi r22, -1				; If all leds are turned off, switch to decrement mode
	endif:						; End if
	ret

; Shifts all bits in r20 to left with one step, then adds one at right end by incrementing
; the register.
shift_pos:
	lsl OUTPUT
	inc OUTPUT
	ret

; Makes the LSB (the right-most bit) a zero, then shifts all bits 
; in r20 to right with one step. Reverse function of shift_pos
shift_neg:
	dec OUTPUT
	lsr OUTPUT
	ret

	
ring_shift:
	cpi OUTPUT,-0				; Happens once, check if OUTPUT is all zeros
	breq L0
	ldi r19, 0
	lsl OUTPUT					;
	adc OUTPUT, r19				
	ret
	
	L0:
	inc OUTPUT					; There are no high bits, insert one at LSB.
	ret

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; delay
; Parameters: n/a
; Purpose: Delay with less than 500 ms, check for button
; 		   presses meantime
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
delay:
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
	ret

ext_interrupt_0:
	com STATE
	ldi ABORT, -1
	ldi OUTPUT, -0
reti
