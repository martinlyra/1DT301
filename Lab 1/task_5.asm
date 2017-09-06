;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;	1DT301, Computer Technology I
;	Date: 2016 - 09 - 06
;	Author:
;		Martin Lyrå
;		Yinlong Yao
;
;	Lab number: 1
;	Title: How to use the PORTs. Digital input/output. Subroutine call.
;
;	Hardware: STK600, CPU ATmega2560
;
;	Function: Runs a Ring Counter algothrim using all LEDs (LED0 to LED7) via PORTB
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

ldi r31, 0b11111110 	; Initialize register 31 (r31) for ring counter function

ldi r16, 0xFF			; Set up PORTB as output
out DDRB, r16			


my_loop:				; Start of loop

out PORTB, r31			; Set PORTB's bits using r31
rcall delay				; Call the delay subroutine
rcall shift 			; Call the shift subroutine (which shifts the led which is on to the left)

rjmp my_loop			; End of loop

shift: 					; Shift subroutine which which shifts the led which is on to the left

;ldi r16, 0				; Commented out, redunant. If nothing is working, try uncommenting this line and the second line below.
lsl r31					; Shift r31's bits to left by one step
;adc r31, r16	

ret						; Return to 

delay:					; A delay subroutine which consists of three loops
ldi r16, 0				; Counter for the Outer loop

outer_loop:
	ldi r17, 0			; Counter for the middle loop

	middle_loop:
		ldi r18, 0		; Counter for the inner loop
				
			inner_loop:
				inc r18			; Increment r18 by one
				cpi r18, 55		
				brlo inner_loop ; Continue while r18 < 55


		inc r17				; Increment r17 by one
		cpi r17, 55
		brlo middle_loop	; Continue while r17 < 55


	inc r16				; Increment r16 by one
	cpi r16, 55
	brlo outer_loop		; Continue while r16 < 55

ret
