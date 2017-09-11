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
.def COUNTER = r20

main:
	rcall check_button
	cpi B_STATE, -0
	breq skip
	rcall translate_number
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

	cpi B_CHECK, -0
	breq skip_check
		ldi B_CHECK, -0
		ret
	not_pressed:
		rcall button_feedback
		ldi B_CHECK, -1
		ret
	skip_check:
		ldi B_STATE, -0
		ret

button_feedback:
	inc COUNTER
	cpi COUNTER, $6
	brge overflow
	ret
	overflow:
	ldi COUNTER, 0
	ret

translate_number:
	cpi COUNTER,0
	breq case_0

	cpi COUNTER,1
	breq case_1

	cpi COUNTER,2
	breq case_2

	cpi COUNTER,3
	breq case_3

	cpi COUNTER,4
	breq case_4

	rjmp case_5
	
	case_0:
		ldi OUTPUT, 0b0001_0000
		ret
	case_1:
		ldi OUTPUT, 0b0010_1000
		ret
	case_2:
		ldi OUTPUT, 0b0101_0100
		ret
	case_3:
		ldi OUTPUT, 0b1100_0110
		ret
	case_4:
		ldi OUTPUT, 0b1101_0110
		ret
	case_5:
		ldi OUTPUT, 0b1110_1110
		ret
		

	
