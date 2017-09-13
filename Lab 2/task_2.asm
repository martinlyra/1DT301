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
;	Function: 	Runs a ticker when button is not pressed,
;				displays a die pattern when SW0 has been 
;				pressed.
;
;	Input ports: PORTA
;
;	Output ports: PORTB
;
;	Subroutines:
;	-	check_button
;	-	translate_number
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

.def STATE = r16
.def OUTPUT = r17
.def B_STATE = r18				; Button state
.def B_CHECK = r19				; Button check
.def COUNTER = r20

; Initialize stack pointer
ldi r16, low(RAMEND)
out SPL, r16
ldi r16, high(RAMEND)
out SPH, r16

ldi r16,0x00					; Set up PORTA as input
out DDRA, r16

ldi r16, 0xFF					; Set up PORTB as output
out DDRB, r16

main:
	rcall check_button
	cpi B_STATE, -0				; Has the button been pressed?
	breq skip
	rcall translate_number		; We have pressed the button - begin throwing the die.
	com OUTPUT
	skip:						
	out PORTB, OUTPUT

	rjmp main

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

	cpi B_CHECK, -0
	breq skip_check				
		ldi B_CHECK, -0			; Button is pressed
		ret
	not_pressed:
		rcall button_rest		; Feedback subroutine for when not being pressed and held
		ldi B_CHECK, -1
		ret
	skip_check:					; Button is being held
		ldi B_STATE, -0
		ret

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; button_rest
; Parameters: n/a
; Purpose: 	Button resting feedback: Increments a register
;			between 0-5
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
button_rest:
	inc COUNTER
	cpi COUNTER, $6				; Is COUNTER over 5?
	brge overflow
	ret
	overflow:
	ldi COUNTER, 0				; If so, reset to 0
	ret

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; translate_number
; Parameters: n/a
; Purpose: 	Sets OUTPUT with an appropriate die pattern from
;			COUNTER's value
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
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
