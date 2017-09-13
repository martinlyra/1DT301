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
;	Function: 	Run a binary counter for every button
;				transition, both positive and negative alike.
;
;	Input ports: PORTA
;
;	Output ports: PORTB
;
;	Subroutines: 
;	-	check_button
;		-	button_press
;		-	button_depress
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
.def B_STATE = r18
.def B_CHECK = r19

; Initialize stack pointer
ldi r16, low(RAMEND)
out SPL, r16
ldi r16, high(RAMEND)
out SPH, r16

ldi r16,0x00				; Setup PORTA as input
out DDRA, r16

ldi r16, 0xFF				; Setup PORTB as output
out DDRB, r16

main:
	rcall check_button
	
	mov OUTPUT, STATE		; Copy STATE to OUTPUT
	com OUTPUT				; The LEDs are turned on by default, invert to accommodate this.

	out PORTB, OUTPUT

	rjmp main

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; check_button
; Parameters: n/a
; Purpose: 	Checks input for SW0 at PORTA
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
check_button:
	in B_STATE, PINA
	com B_STATE					; By default, the switches are active high (1 when resting, 0 when pressed) - invert input bits
	andi B_STATE, $1			; We just want the input from SW0
	cpi B_STATE, $1
	brne not_pressed
	ldi B_STATE, -1				; A shortcut hack for this lab, see comparsion in button_press/depress

	cpi B_CHECK, -0				; Should we check the button? (As in: Are we holding the button?)
	breq skip_check
		rcall button_press
		ldi B_CHECK, -0			; Don't check for positive edge presses (holds) until it has been left off.
		ret
	not_pressed:				; We have not pressed the button (we has released the button)
		rcall button_depress
		ldi B_CHECK, -1			; Next time we'll check for a button press
		ret
	skip_check:
		ldi B_STATE, -0			; There should be no consequences from holding the button
		ret

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; button_press
; Parameters: n/a
; Purpose: 	Increments a counter for every press (0-1)
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
button_press:
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; button_depress
; Parameters: n/a
; Purpose: 	Increments a counter for every depress (1-0)
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
button_depress:
	cp B_CHECK, B_STATE
	breq increment_count
	ret
	increment_count:
	inc STATE
	ret
