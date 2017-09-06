;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;	1DT301, Computer Technology I
;	Date: 2016 - 09 - 04
;	Author:
;		Martin Lyrå
;		Yinlong Yao
;
;	Lab number: 1
;	Title: How to use the PORTs. Digital input/output. Subroutine call.
;
;	Hardware: STK600, CPU ATmega2560
;
;	Function: Gives switch SW5 a function to lit LED0 whenever pressed (and held), and alone
;
;	Input ports: PORTA
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

ldi r16,0x00			; Set up PORTA as input
out DDRA, r16

ldi r16, 0xFF			; Set up PORTB as output
out DDRB, r16

loop:			
in r16, PINA			; Set bits in r16 from PORTA's pins
cpi r16, 0b1101_1111	; Switches are active high - check if switch SW5 (and alone) is pressed
breq pressed			; Branch to 'pressed' if comparsion is equal - SW5 is being pressed

						; If not equal
ldi r16, 0xFF			; Turn all LEDS off (0b1111_1111), see line 51
rjmp endif				; Go to 'endif'

pressed:
ldi r16, 0xFE			; Turn all LEDS off, except LED0 (0b1111_1110), see line 51

endif:
out PORTB, r16			; Sets bits stored in r16 to PORTB
rjmp loop

