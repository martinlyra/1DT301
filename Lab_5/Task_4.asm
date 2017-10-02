.include "m2560def.inc"

; 25 = 2400 bps
; 12 = 4800 bps
; 6 = 9600 bps

.equ UBRR_DEFAULT = 12

; Scroll delay
.equ SCROLL_DELAY = 2500 ; ms

; String memory
.equ MEMORY_START = 0x200
; Pointer memory
.equ TABLE_START = 0x300

;.equ LINE_BYTES = 20
.equ LINE_LIMIT = 4

;.equ MODE_READ = -0
;.equ MODE_WRITE = -1

.def MODE = r19	; Read/Write reg
.def CNTR = r20	; Counter

.cseg
.org 0x00
jmp reset

.org 0x04 ; address for external interrupt 1
jmp int1_handler

.org URXC1addr	; URXC1addr - receive complete for USART1
jmp urxc1_handler

.org 0x72
; Most of the common code are called using 'call', if you see one,
; try looking it up inside 'common.inc' in the same folder
.include "./common.inc"	; common code used for tasks 1-4
reset:

; Initialize stack pointer
ldi tmp, low(RAMEND)
out SPL, tmp
ldi tmp, high(RAMEND)
out SPH, tmp

; Initialize X pointer
ldi XL, low(MEMORY_START)
ldi XH, high(MEMORY_START)
; Initialize Y pointer
mov YL, XL
mov YH, XH
; Initialize Z pointer
ldi zl, low(TABLE_START)
ldi zh, high(TABLE_START)

ser tmp
out DDRC, tmp
out PORTC, tmp

; Enable INT1, set as rising edge
ldi tmp, (1<<INT1)
out EIMSK, tmp
ldi tmp, 0b0000_1100
sts EICRA, tmp

; Set Baud rate
ldi tmp, UBRR_DEFAULT
sts UBRR1L, tmp

; Enable receive flag and receive interrupt for URAT0
ldi tmp, (1<<RXEN1 | 1<<RXCIE1)
sts UCSR1B, tmp

sei

call init_display

ldi tmp, 0
ldi cntr, 0

main: 
	sbrs MODE, 0 ; Do not display or scroll when we are in WRITE mode
	rjmp main	

	push cntr
	clr cntr

	L3:
	; Print first line
	call display_clear
	rcall restore_x	; reset or move X pointer to last saved Y pointer
	call print_line

	; Print new line
	ldi dat, 0xA8
	call display_write_cmd
	call short_wait
	
	; Increment or reset counter
	inc cntr
	cpi cntr, LINE_LIMIT
	brlo C1
		clr cntr
	C1:

	; Print second line
	rcall restore_x
	call print_line

	; Delay
	ldi r24, low(SCROLL_DELAY)
	ldi r25, high(SCROLL_DELAY)
	call wait_milliseconds
		
	; Exit the loop if we've switched to "WRITE"
	sbrs MODE, 0
	rjmp L3

	pop cntr
rjmp main

int1_handler:
	com mode
reti
	

urxc1_handler:
	sbrc mode, 0
	reti

	push tmp

	lds tmp, UDR1		; Get input from data register
	st y+, tmp			; Store input in memory
	
	; Store location of Y in table (pointer memory)
	rcall restore_table_ptr ; Get the correct location first
	st z+, yl
	st z+, yh

	cpi tmp, NEW_LINE	; Check if input is \n (Character no.13 in ASCII)
	brne not_nl
		; If \n, increment the counter, next location for Z pointer will be calculated
		; the next call of 'restore_table_ptr' - new X will be copied from last saved location of Y
		inc cntr
	not_nl:

	call display_clear
	rcall restore_x		; Reset x pointer to start or last saved location of Y pointer
	rcall print_line

	pop tmp
reti

restore_table_ptr:
	ldi zl, low(TABLE_START)
	ldi zh, high(TABLE_START)

	push tmp
	cpi cntr, 0
	breq E1
		mov tmp, cntr
		L1:
		adiw z, 2
		dec tmp
		brne L1
	E1:
	pop tmp
ret

; Reset the X pointer to start of memory - or to the last saved location of Y pointer
restore_x:
	rcall restore_table_ptr
	cpi cntr, 0
	breq default
		; We are not at the first line, start off
		; from the last saved Y pointer
		ld xh, -z
		ld xl, -z
		adiw z, 2
	
		ret
	default:
	ldi xl, low(MEMORY_START)
	ldi xh, high(MEMORY_START)
ret

print_line:
	cp xh, yh
	brne do_print
	cp xl, yl
	brge E0

	do_print:

	ld dat, x+
	cpi dat, NEW_LINE
	breq E0

	call display_write_char
	rjmp print_line		; Continue until X == Y

	E0:
ret
