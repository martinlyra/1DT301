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

.def STATE = r16
.def OUTPUT = r17
.def B_STATE = r18
.def B_CHECK = r19

main:
	rcall check_button
	mov OUTPUT, STATE
	com OUTPUT
	skip:
	out PORTB, OUTPUT

	rjmp main

check_button:
	in B_STATE, PINA
	com B_STATE
	andi B_STATE, $1
	cpi B_STATE, $1
	brne not_pressed
	ldi B_STATE, -1

	cpi B_CHECK, -0
	breq skip_check
		rcall button_press
		ldi B_CHECK, -0
		ret
	not_pressed:
		rcall button_depress
		ldi B_CHECK, -1
		ret
	skip_check:
		ldi B_STATE, -0
		ret

button_press:
button_depress:
	cp B_CHECK, B_STATE
	breq increment_count
	ret
	increment_count:
	inc STATE
	ret
