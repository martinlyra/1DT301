.include "m2560def.inc"
ldi r31, 0b11111110 ; The output

ldi r16, 0b11111111
out DDRB, r16			; Make Port B for output


my_loop:


out PORTB, r31	
rcall delay			; Call the delay subroutine
rcall shift 		; Call the shift subroutine (which shifts the led which is on to the left)


rjmp my_loop

shift: 		; Shift subroutine which which shifts the led which is on to the left

ldi r16, 0
lsl r31
adc r31, r16

ret

delay:	; A delay subroutine which consists of three loops

ldi r16, 0		; Counter for the Outer loop

outer_loop:

		ldi r17, 0		; Counter for the middle loop

		middle_loop:

				ldi r18, 0		; Counter for the inner loop
				
				inner_loop:

								inc r18
								cpi r18, 55
								brlo inner_loop


				inc r17
				cpi r17, 55
				brlo middle_loop


		inc r16
		cpi r16, 55
		brlo outer_loop

ret
