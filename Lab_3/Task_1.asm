.include "m2560def.inc"

.org 0x00
jmp reset
.org 0x02
jmp ext_interrupt_0

.org 0x72
reset:

; Initialize stack pointer
ldi r16, low(RAMEND)
out SPL, r16
ldi r16, high(RAMEND)
out SPH, r16

ldi r16, 0x00
out DDRD, r16 ;D is input
ldi r16, 0xFF
out DDRB, r16 ;B is output

ldi r16, (1<<INT0)
out EIMSK, r16

ldi r16, 0b0000_0010
sts EICRA, r16

sei

main:
    nop
rjmp main

ext_interrupt_0:
	com r17
	out PORTB,r17
reti
