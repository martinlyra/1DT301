;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;	1DT301, Computer Technology I
;	Date: 2016 - 10 - 02
;	Author:
;		Martin Lyrå
;		Yinlong Yao
;
;	Lab number: 5
;	Title: Display JHD202
;
;	Hardware: STK600, CPU ATmega2560, Display JHD202
;
;	Function: Display serial (URAT1) input on display
;
;	Input ports: URAT1
;
;	Output ports: PORTE
;
;	Subroutines:
;	-	urxc1_handler
;
;	Included files: m2560def.inc, common.inc
;
;	Other information: common.inc contains code used by all
;	tasks for this lab.
;
;	Changes in program:
;		2017-10-02: File created
;		2017-10-03: Documentation
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
.include "m2560def.inc"

; 25 = 2400 bps
; 12 = 4800 bps
; 6 = 9600 bps
.equ UBRR_DEFAULT = 12

.cseg
.org 0x00
jmp reset

.org URXC1addr	; URXC1addr - receive complete for USART1
jmp urxc1_handler

.org 0x72
.include "./common.inc"	; common code used for tasks 1-4
reset:
; Initialize stack pointer
ldi tmp, low(RAMEND)
out SPL, tmp
ldi tmp, high(RAMEND)
out SPH, tmp

; Set Baud rate, 4800 bps for URAT1
ldi tmp, UBRR_DEFAULT
sts UBRR1L, tmp

; Enable receive flag and receive interrupt for URAT1
ldi tmp, (1<<RXEN1 | 1<<RXCIE1)
sts UCSR1B, tmp

sei ; Enable interrupts

call init_display ; Initialize display

main: 
	nop
rjmp main

;
; urxc1_handler
; Purpose: Display serial input on display
;
urxc1_handler:
	lds dat, UDR1 ; Load data with input from data register
	call display_write_char ; Display input
reti
