;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;	1DT301, Computer Technology I
;	Date: 2016 - 09 - 18
;	Author:
;		Martin Lyrå
;		Yinlong Yao
;
;	Lab number: 3
;	Title: Interrupts
;
;	Hardware: STK600, CPU ATmega2560
;
;	Function: Enables button SW0 as interrupt, toggles all LED on/off when pressed.
;
;	Input ports: PORTD
;
;	Output ports: PORTB
;
;	Subroutines: ext_interrupt_0
;
;	Included files: m2560def.inc
;
;	Other information:
;
;	Changes in program:
;		2017-09-18: File created
;		2017-09-20: Documentation
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

.include "m2560def.inc"

.org 0x00				; Vector address for RESET interrupt
jmp reset
.org 0x02				; Vector address for INT0
jmp ext_interrupt_0

.org 0x72				; Outside the vector table for Atmega2560
reset:

; Initialize stack pointer
ldi r16, low(RAMEND)
out SPL, r16
ldi r16, high(RAMEND)
out SPH, r16

ldi r16, 0x00
out DDRD, r16 			; D is input
ldi r16, 0xFF
out DDRB, r16 			; B is output

ldi r16, (1<<INT0)		; Enable external interrupt 0 (INT0)
out EIMSK, r16

ldi r16, 0b0000_0010	; Set falling edge for INT0 
sts EICRA, r16

sei						; Enable global interrupts (IMPORTANT!)

main:
    nop					; Main should do nothing
rjmp main

ext_interrupt_0:
	com r17				; Invert all bits in r17
	out PORTB,r17		; Push the new state to PORTB
reti
