.include "m2560def.inc"

.equ TIME = 240

.equ PWN_DUTY_CAP = 100
.equ PWN_DUTY_STEP = 5
.equ PWN_DUTY_DEFAULT = 50

.def TEMP = r16
.def PWN_DUTY = r17
.def PWN_COUNTER = r18

.cseg
.org 0x00
jmp reset

.org 0x04
jmp interrupt1
.org 0x06
jmp interrupt2

.org 0x2e
jmp timer0_tick

.org 0x72
reset:
ldi temp, LOW(RAMEND)
out SPL, temp
ldi temp, HIGH(RAMEND)
out SPH, temp

ldi temp, 0x01
out DDRB, temp

; Ext interrupts
ldi temp, (1<<INT1 | 1<<INT2)
out EIMSK, temp

ldi temp, 0b0010_1000
sts EICRA, temp

; Timer
ldi temp, 0x05
out TCCR0B, temp

ldi temp, (1<<TOIE0)
sts TIMSK0, temp

ldi temp, TIME
out TCNT0, temp

sei

ldi PWN_DUTY, PWN_DUTY_DEFAULT

main:
	rjmp main

timer0_tick:
	push temp
	in temp, SREG
	push temp

	inc PWN_COUNTER
	ldi temp, 0xFF

	cp PWN_COUNTER, PWN_DUTY
	breq no_low
	brlo no_low
		ldi temp, 0x00
	no_low:

	com temp
	out PORTB, temp

	cpi PWN_COUNTER, PWN_DUTY_CAP
	brlo no_reset
		clr PWN_COUNTER
	no_reset:

	ldi temp, TIME
	out TCNT0, temp

	pop temp
	out SREG, temp
	pop temp
reti

; Increment with 5, unless PWN_DUTY is equal to or greater than 100
interrupt1:
	cpi PWN_DUTY, PWN_DUTY_CAP
	brge max_capped
		push temp

		ldi temp, PWN_DUTY_STEP
		add PWN_DUTY, temp

		pop temp
	max_capped:
	nop
reti

; Decrement with 5, unless PWN_DUTY is equal to 0
interrupt2:
	cpi PWN_DUTY, 0
	breq min_capped
		push temp
		
		ldi temp, PWN_DUTY_STEP
		sub PWN_DUTY, temp

		pop temp

	min_capped:
	nop
reti
