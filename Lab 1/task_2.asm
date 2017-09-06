;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;	1DT301, Computer Technology I
;	Date: 2016 - 09 - 05
;	Author:
;		Martin Lyrå
;		Yinlong Yao
;
;	Lab number: 1
;	Title: How to use the PORTs. Digital input/output. Subroutine call.
;
;	Hardware: STK600, CPU ATmega2560
;
;	Function: Gives switches SW0 to SW7 a function that lits
;	corresponding LED light LEDn when pressed (and held)
;
;	Input ports: PORTA (Switches)
;
;	Output ports: PORTB (LEDs)
;
;	Subroutines: None
;
;	Included files: m2560def.inc
;
;	Other information:
;
;	Changes in program:
;		2017-09-04: File created
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

.include "m2560def.inc"

ldi r16,0x00	; 0x00 = Input, to register 15 (r15)
out DDRA, r16	; Set Data Direction as Input for A

ldi r16, 0xFF	; 0xFF = Output, to register 16 (r16)
out DDRB, r16	; Set Data Direction as Output for B


loop:			; Destination label for rjmp
in r16,PINA		; Assign value to r16 from PORTA's pins (PINA)
out PORTB,r16	; Assign value to PORTB from r16 (PINA)

rjmp loop		; Jump to label 'loop'
