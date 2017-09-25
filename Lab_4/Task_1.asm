.include "m2560def.inc"

.equ TIME = 100
.equ TICK_CAP = 5

.def TEMP = r16
.def COUNTER = r17

.cseg
.org 0x00
jmp reset

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

ldi temp, 0x05
out TCCR0B, temp

ldi temp, (1<<TOIE0)
sts TIMSK0, temp

ldi temp, TIME
out TCNT0, temp

sei

main:
	rjmp main

timer0_tick:
	push temp
	in temp, SREG
	push temp

	cpi COUNTER, TICK_CAP
	brlo no_tick

	clr COUNTER

	in temp, PORTB
	andi temp, 0x01
	com temp
	out PORTB, temp

	no_tick:

	inc COUNTER

	ldi temp, TIME
	out TCNT0, temp

	pop temp
	out SREG, temp
	pop temp
reti
