.include "m2560def.inc"

; Initialize stack pointer
ldi r16, low(RAMEND)
out SPL, r16
ldi r16, high(RAMEND)
out SPH, r16

ldi r16,0x00
out DDRA, r16

ldi r16, 0xFF
out DDRB, r16

.DEF STATE = r16
.DEF OUTPUT = r17
.DEF B_STATE = r18
.DEF B_CHECK = r23

.EQU STATE_RING	= -0
.EQU STATE_JOHNSON = -1

ldi STATE, STATE_RING

main:
	cpi STATE, STATE_RING
	brne johnson
	ring:
		rcall ring_shift
		rjmp end_if
	johnson:
		rcall johnson_shift
	end_if:

	com OUTPUT
	out PORTB, OUTPUT
	com OUTPUT

	rcall delay

	rjmp main


johnson_shift:
	cpi r22, -0
	breq increment		; If equal to 0 (all bits are zeros), go to increment label
	decrement:
		rcall shift_neg	; Call shift_neg subroutine
		cpi OUTPUT, -0		; Are all leds turned on (all bits are '0's)?
		brne endif		; Break the "if statement" if not
		ldi r22, -0		; If all leds are turned on, switch to increment mode
		jmp endif
	increment:
		rcall shift_pos	; Call shift_pos subroutine
		cpi OUTPUT, -1		; Are all leds turned off (all bits are '1's)?
		brne endif		; Break the "if statement" if not
		ldi r22, -1		; If all leds are turned off, switch to decrement mode
	endif:				; End if
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
	cpi OUTPUT,-0
	breq L0
	lsl OUTPUT
	ret
	
	L0:
	inc OUTPUT
	ret


delay:
	ldi r19, 2
	ldi r20, 2
	ldi r21, 2

	DL1:
		rcall check_button
		cpi B_STATE, -0
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

check_button:
	in B_STATE, PINA
	com B_STATE
	andi B_STATE, $1
	cpi B_STATE, $1
	brne not_pressed

	cpi B_CHECK, -0
	breq skip_check
		rcall change_state
		ldi B_CHECK, -0
		ldi OUTPUT, -0
		ret
	not_pressed:
		ldi B_CHECK, -1
		ret
	skip_check:
		ldi B_STATE, -0
		ret

change_state:
	cpi STATE, STATE_RING
	brne to_ring
	ldi STATE, STATE_JOHNSON
	ldi r22, -0
	ret
	to_ring:
	ldi STATE, STATE_RING
	ret
