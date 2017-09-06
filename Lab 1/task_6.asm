.include "m2560def.inc"

; Initialize stack pointer
ldi r16, low(RAMEND)
out SPL, r16
ldi r16, high(RAMEND)
out SPH, r16

ldi r16, 0xFF
out DDRB, r16

;r21 = Direction: 0 = increment, 1 = decrement
main:
	cpi r21, -0
	breq increment
	decrement:
		call shift_neg
		cpi r20, -0
		brne endif
		ldi r21, -0
		jmp endif
	increment:
		call shift_pos
		cpi r20, -1
		brne endif
		ldi r21, -1
	endif:
	out PORTB, r20
	call delay
rjmp main

shift_pos:
	lsl r20
	inc r20
ret

shift_neg:
	dec r20
	lsr r20
ret


delay:

	ldi r17, 2
	ldi r18, 2
	ldi r19, 2

	L1: 
	dec r19
	brne L1
	dec r18
	brne L1
	dec r17
	brne L1
	nop

ret
