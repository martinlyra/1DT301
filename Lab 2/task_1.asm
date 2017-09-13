;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;	1DT301, Computer Technology I
;	Date: 2016 - 09 - 13
;	Author:
;		Martin Lyrå
;		Yinlong Yao
;
;	Lab number: 2
;	Title: Subroutines
;
;	Hardware: STK600, CPU ATmega2560
;
;	Function: Runs a Ring counter by default, can be switched 
;			  to Johnson and back via single presses on SW0
;
;	Input ports: PORTA
;
;	Output ports: PORTB
;
;	Subroutines: 
;	-	ring_shift
; 	-	johnson_shift
;		-	shift_pos
;		-	shift_neg
;	-	delay
;		-	check_button
;			-	change_state
;		
;
;	Included files: m2560def.inc
;
;	Other information:
;
;	Changes in program:
;		2017-09-11: File created
;		2017-09-13: Documentation
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

.include "m2560def.inc"

.DEF STATE = r16
.DEF OUTPUT = r17
.DEF B_STATE = r18				; Button state
.DEF B_CHECK = r23				; Button check

.EQU STATE_RING	= -0			; STATE_RING is 0b0000_0000
.EQU STATE_JOHNSON = -1			; STATE_JOHNSON is 0b1111_1111

; Initialize stack pointer
ldi r16, low(RAMEND)
out SPL, r16
ldi r16, high(RAMEND)
out SPH, r16

ldi r16,0x00					; Setup PORTA as input
out DDRA, r16

ldi r16, 0xFF					; Setup PORTB as output
out DDRB, r16

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
	lsl OUTPUT					; There is one high bit, shift the entire byte one bit to left
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
		rcall check_button
		cpi B_STATE, -0			; Immediately abort delay if button has been pressed
		brne abort

		dec r19
		brne DL1

		dec r20
		brne DL1

		dec r21
		brne DL1
		nop

	abort:
	ret

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; check_button
; Parameters: n/a
; Purpose: Checks input for SW0 at PORTA
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
check_button:
	in B_STATE, PINA
	com B_STATE					; By default, the switches are active high (1 when resting, 0 when pressed) - invert input bits
	andi B_STATE, $1			; We just want the input from SW0
	cpi B_STATE, $1
	brne not_pressed

	cpi B_CHECK, -0				; Should we check the button? (As in: Are we holding the button?)
	breq skip_check
		rcall change_state		; Change to either Ring or Johnson
		ldi B_CHECK, -0			; We don't want pressing and holding the button to do anything - don't check until the button has been let off.
		ldi OUTPUT, -0			; Reset current progress by Ring or Johnson
		ret
	not_pressed:				; We have not pressed the button (we has released the button)
		ldi B_CHECK, -1			; Next time we'll check for a button press
		ret
	skip_check:
		ldi B_STATE, -0			; There should be no consequences from holding the button
		ret

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; change_state
; Parameters: n/a
; Purpose: Switches between Ring or Johnson
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
change_state:
	cpi STATE, STATE_RING
	brne to_ring
	ldi STATE, STATE_JOHNSON
	ldi r22, -0
	ret
	to_ring:
	ldi STATE, STATE_RING
	ret
