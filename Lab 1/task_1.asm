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
;	Function: Lits LED2 on board.
;
;	Input ports: None
;
;	Output ports: PORTB
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

ldi r16, 0xFF			; 0xFF = Output, to register 16 (r16)
out DDRB, r16			; Set data direction (DDR) as Output

ldi r16, 0b00000100 	; Only LED2 will be lit
out PORTB, r16 			; Assign value to PORTB from r16

