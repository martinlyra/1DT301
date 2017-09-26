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
;	Function: 	Creates a 50% duty sqaure sine-wave using a timer
;
;	Input ports:
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

.equ TIME = 100
.equ TICK_CAP = 5

.def TEMP = r16
.def COUNTER = r17

.cseg
.org 0x00
jmp reset

.org 0x2e				; address for Timer0 overflow interrupt
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

ldi temp, 0x05			; Set 1024 Hz frequency for Timer0
out TCCR0B, temp

ldi temp, (1<<TOIE0)	; Enable overflow interrupt for Timer0 (required)
sts TIMSK0, temp

ldi temp, TIME			; Set duration in ms for between each "tick" for Timer0
out TCNT0, temp

sei						; Enable global interrutps

main:
	rjmp main

timer0_tick:
	push temp
	in temp, SREG
	push temp

	cpi COUNTER, TICK_CAP ; Check if we have reached a "tick" (when COUNTER equal to 5)
	brlo no_tick

	clr COUNTER			; Reset COUNTER

	in temp, PORTB		; Get PORTB's bits
	andi temp, 0x01		; Apply mask
	com temp			; Flip bits
	out PORTB, temp		; Push new state to PORTB

	no_tick:

	inc COUNTER			; Increment counter

	ldi temp, TIME		; Restart the timer by inserting the same value at initialization.
	out TCNT0, temp

	pop temp
	out SREG, temp
	pop temp
reti
