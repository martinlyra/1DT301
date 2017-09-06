.include "m2560def.inc"

ldi r16,0x00
out DDRA, r16

ldi r16, 0xFF
out DDRB, r16


loop:
in r16,PINA
out PORTB,r16

rjmp loop
