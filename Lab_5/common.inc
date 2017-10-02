.include "m2560def.inc"

.equ DIS_REG_INSTRUCTION = 0b0000_0000
.equ DIS_REG_DATA = 0b0010_0000

.equ DIS_CLEAR		= 0b00_0001
.equ DIS_BITMODE4 	= 0b00_0010
.equ DIS_EBC		= 0b00_1111	; enable on, blink on, cursor on

.equ OUT_PIN_D4	= 0b0000_0100
.equ OUT_PIN_D5	= 0b0000_1000
.equ OUT_PIN_D6	= 0b0000_0001
.equ OUT_PIN_D7 = 0b0000_0010
.equ OUT_PIN_RW	= 0b0010_0000
.equ OUT_PIN_RS = 0b1000_0000

.equ NEW_LINE = 0b0000_1101

.def TMP = r16
.def DAT = r17
.def SEL = r18 ; selection register for display

init_display:
	ser tmp
	out DDRE, tmp
	clr tmp
	out PORTE, tmp

	ldi r24, low(20)
	ldi r25, high(20)
	call wait_milliseconds	; power up wait

	ldi dat, DIS_BITMODE4
	call display_write_nibble

	call short_wait

	ldi dat, DIS_EBC
	call display_write_cmd

	call short_wait

	call display_clear
	ret

display_clear:
	ldi dat, DIS_CLEAR
	call display_write_cmd

	ldi r24, low(20)
	ldi r25, high(20)
	call wait_milliseconds

	ret

display_write_char:
	ldi sel, DIS_REG_DATA
	jmp display_write

display_write_cmd:
	ldi sel, DIS_REG_INSTRUCTION

display_write:
	push tmp

	mov tmp, dat
	andi dat, 0b1111_0000
	swap dat
	or dat, sel
	call display_write_nibble
	mov dat, tmp
	andi dat, 0b0000_1111
	or dat, sel
	call display_write_nibble

	pop tmp
	ret

display_write_nibble:
	call display_switch
	nop
	sbi PORTE, 5
	nop
	nop
	cbi PORTE, 5
	nop
	nop
	ret

display_switch:
	push tmp
	clr tmp

	sbrc dat, 0			; skip the instruction below if 1st bit is clear (0)
	ori tmp, OUT_PIN_D4	; D4	pin 2
	
	sbrc dat, 1	
	ori tmp, OUT_PIN_D5	; D5	pin 3

	sbrc dat, 2
	ori tmp, OUT_PIN_D6	; D6	pin 0

	sbrc dat, 3
	ori tmp, OUT_PIN_D7	; D7	pin 1

	sbrc dat, 4
	ori tmp, OUT_PIN_RW	; E		pin 5

	sbrc dat, 5
	ori tmp, OUT_PIN_RS	; RS	pin 7

	out PORTE, tmp
	pop tmp

	ret

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; wait_milliseconds
; Parameters: integer (r25:r24)
; Purpose: Wait N milliseconds
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
wait_milliseconds:
	push r16			; Store data in r16 and r17 to the stack first
	push r17

	; These instructions take approx 1 ms to complete on ATMEGA2560
	_L0:
	ldi r16, low(500)
	ldi r17, high(500)

	_L1:
	dec r16
	nop
	brne _L1				
	dec r17
	nop
	brne _L1

	; To gain N delay, repeat above instructions N times with this
	sbiw r25:r24, 1			; 16-bit decrementation by subtraction
	brne _L0				; Continue until the 16-bit value is 0x00

	pop r17				; Return stored data to r16 and r17 from stack
	pop r16
ret

short_wait:
	clr zh
	ldi zl, 30
	jmp wait_loop

wait_loop:
	sbiw z, 1
	brne wait_loop
	ret

