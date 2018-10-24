; CSC-330 Lab -Answer
; Date: 10/18/2018
; Author: James Deromedi
; Description: Completed to provide anwser for the students

;---------------------Pre-setup section----------------------
.cseg	

.def				io_setup	= r16
.def				leds_d		= r17
.def				leds_b		= r18

.org				0x0000
rjmp				setup
.org				0x0100

;-----------------------Setup section------------------------
setup:
					ldi		io_setup, 0xFF					;Set io_setup to all 1s
					out		DDRD, io_setup					;Make all D pins to outputs
					out		DDRB, io_setup					;Make all B pins to outputs
					ldi		leds_d, 0b00000001				;Change to 0b00000000 for part 1
					ldi		leds_b, 0b00000001				




;------------------------Loop section------------------------
loop:	
					rjmp	Left

;----------------------------------------------------------------
;Part 3 of the lab
Left_Next:			
					ldi		leds_d, 0b00000000				;Sets all d leds to zero
					out		PORTD, leds_d					;Turns off all the d leds

					

					ldi		io_setup, 0b00000010			;Set comparative for first two bits
					out		PORTB, leds_b					;Output the new value
					;rcall	delay_100ms						;delay 100ms
					nop
					cp		leds_b, io_setup				;Compare to io_setup
					breq	Right_Next						;Break if they are a match
					lsl		leds_b							;Increment from all off
					
					rjmp	Left_Next	

;----------------------------------------------------------------
;Part 3 of the lab
Right_Next:
					ldi		io_setup, 0b00000001			;Set comparative for first two bits
					lsr		leds_b							;Increment to the right
					out		PORTB, leds_b					;Output the new value
					;rcall	delay_100ms
					nop
					cp		leds_b, io_setup
					breq	Right

					rjmp	Right_Next

;----------------------------------------------------------------
;Part 2 of the lab
;Set rjmp in loop to this tag
;Change breq to Right
Left:
					ldi		io_setup, 0b10000000			;Set the value to turn around at
					lsl		leds_d							;Move the bit over by one
					out		PORTD, leds_d					;Output the leds_d
					;rcall	delay_100ms						;Delay by 100ms
					nop
					cp		leds_d, io_setup				;Check if the value equals where we want to turn around
					breq	Left_Next						;Break to move the other direction

					rjmp	Left

;----------------------------------------------------------------
;Part 2 of the lab
Right:
					ldi		leds_b, 0b00000000				;Set leds b to all zeros
					out		PORTB, leds_b					;Turn off all the leds

					ldi		io_setup, 0b00000001			;Set the value to turn around at

					ldi		leds_d, 0b10000000				;Set start value COMMENT OUT FOR PART 2
					out		PORTD, leds_d					;Output the leds_d COMMENT OUT FOR PART 2

					lsr		leds_d							;Move the bit over by one

					;out		PORTD, leds_d					;Output the leds_d COMMENT OUT FOR PART 3
					;rcall	delay_100ms						;Delay by 100ms
					nop

					cp		leds_d, io_setup				;Check if the value equals where we want to turn around
					breq	Left							;Break to move the other direction

					rjmp	Right

;----------------------------------------------------------------
;Part 1 of the lab
;Set rjmp of loop to this tag
B_Leds:
					out		PORTD, leds_d					;Output value of leds_d
					out		PORTB, leds_b					;Ouput value of leds_b
					;rcall	delay_100ms						;Delay by 100ms
					nop
					inc		leds_d							;Increment leds_d by one
					cp		leds_d, io_setup				;Check if leds_d is equal to zero then set zero flag
					breq	D_Leds							;If zero flag is set then break

					rjmp	loop

;----------------------------------------------------------------
;Part 1 of the lab
D_Leds:
					inc		leds_b							;Increment the leds_b
					nop

					rjmp	loop

;--------------------------1s delay--------------------------
delay_1s:			ldi		R20, 0x53
delay_1s_1:			ldi		R21, 0xFB
delay_1s_2:			ldi		R22, 0xFF
delay_1s_3:			dec		R22
					brne	delay_1s_3
					dec		R21
					brne	delay_1s_2
					dec		R20
					brne	delay_1s_1
					ldi		R20, 0x02
delay_1s_4:			dec		R20
					brne	delay_1s_4
					nop
					ret

;------------------------100ms delay-------------------------
delay_100ms:		ldi		r20, 9
					ldi		r21, 30
					ldi		r22, 229
delay_100ms_1:		dec		r22
					brne	delay_100ms_1
					dec		r21
					brne	delay_100ms_1
					dec		r20
					brne	delay_100ms_1
					ret
;------------------------10ms delay--------------------------
delay_10ms:			ldi		r20, 208
					ldi		r21, 202
delay_10ms_1:		dec		r21
					brne	delay_10ms_1
					dec		r20
					brne	delay_10ms_1
					ret