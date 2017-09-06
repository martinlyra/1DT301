.include "m2560def.inc"

ldi r16,0x00
out DDRA, r16

ldi r16, 0xFF
out DDRB, r16

loop:
in r16, PINA
cpi r16, 0b1101_1111
breq pressed

ldi r16, 0xFF
rjmp endif

pressed:
ldi r16, 0xFE

endif:
out PORTB, r16
rjmp loop

