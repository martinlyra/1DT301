;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;	1DT301, Computer Technology I
;	Date: 2016 - 09 - 25
;	Author:
;		Martin Lyrå
;		Yinlong Yao
;
;	Lab number: 4
;	Title: Timer and URAT
;
;	Hardware: STK600, CPU ATmega2560
;
;	Function: 	Creates a square sine-wave using timer and
;				a pulse width modulation, controllable by
;				external input with interrupts.
;
;	Input ports: PORTD
;
;	Output ports: PORTB
;
;	Subroutines: 
;
;	Included files: m2560def.inc
;
;	Other information:
;
;	Changes in program:
;		2017-09-25: File created
;		2017-09-26: Documentation
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

.include "m2560def.inc"

.equ TIME = 240

.equ PWM_DUTY_CAP = 100
.equ PWM_DUTY_STEP = 5
.equ PWM_DUTY_DEFAULT = 50

.def TEMP = r16
.def PWM_DUTY = r17
.def PWM_COUNTER = r18

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
; Initialize stack pointer
ldi temp, LOW(RAMEND)
out SPL, temp
ldi temp, HIGH(RAMEND)
out SPH, temp

ldi temp, 0x01			; Only the first bit of PORTB is output
out DDRB, temp

; Ext interrupts
ldi temp, (1<<INT1 | 1<<INT2)	; Enable interrupt 1 (SW1) and interrupt 2 (SW2)
out EIMSK, temp

ldi temp, 0b0010_1000			; Enable falling edge trigger for both
sts EICRA, temp

; Timer
ldi temp, 0x05			; Set 1024 Hz frequency for Timer0
out TCCR0B, temp

ldi temp, (1<<TOIE0)	; Enable overflow interrupt for Timer0 (required)
sts TIMSK0, temp

ldi temp, TIME			; Set duration in ms for between each "tick" for Timer0
out TCNT0, temp

sei						; Enable global interrupts

ldi PWM_DUTY, PWM_DUTY_DEFAULT	; Initialize the pwn duty cycle

main:
	rjmp main

; Interrupt handle for timer0 overflow
timer0_tick:
	push temp
	in temp, SREG
	push temp

	inc PWM_COUNTER
	ldi temp, 0xFF				; Start off as high

	cp PWM_COUNTER, PWM_DUTY	; Check if the counter is within the "high" part of the duty cycle
	breq no_low
	brlo no_low
		ldi temp, 0x00			; If the counter outside the cycle, we are at low.
	no_low:

	com temp					; Obligatory inversion due to STK600's active low LEDs
	out PORTB, temp	

	cpi PWM_COUNTER, PWM_DUTY_CAP	; Should we reset the counter? (Is COUNTER lower than DUTY_CAP?)
	brlo no_reset
		clr PWN_COUNTER				; If false, reset the counter
	no_reset:

	ldi temp, TIME				; As usual, restart the timer
	out TCNT0, temp

	pop temp
	out SREG, temp
	pop temp
reti

; Interrupt handler for INT1
; Increment with 5, unless PWM_DUTY is equal to or greater than 100
interrupt1:
	cpi PWM_DUTY, PWM_DUTY_CAP		; Is the duty at max?
	brge max_capped
		push temp

		ldi temp, PWM_DUTY_STEP		; If false, increment it
		add PWM_DUTY, temp

		pop temp
	max_capped:
	nop
reti

; Interrupt handler for INT2
; Decrement with 5, unless PWM_DUTY is equal to 0
interrupt2:
	cpi PWM_DUTY, 0					; Is the duty at minimum?
	breq min_capped
		push temp
		
		ldi temp, PWM_DUTY_STEP		; If alse, decrement it
		sub PWM_DUTY, temp

		pop temp

	min_capped:
	nop
reti
