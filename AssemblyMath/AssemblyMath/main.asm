; CSC-330 Lab -Answer
; Date: 10/18/2018
; Author: James Deromedi
; Description: Completed to provide anwser for the students

;---------------------Pre-setup section----------------------
.cseg	

.def				io_setup	= r16
.def				input		= r17
.def				output		= r18
.def				num_a		= r19
.def				num_b		= r20
.def				counter		= r21

.org				0x0000
rjmp				setup
.org				0x0100

;-----------------------Setup section------------------------
setup:
			ldi		io_setup, 0b00000000
			out		DDRD, io_setup						;Set up PORTD to take inputs from switch
			ldi		io_setup, 0b11111111				
			out		DDRB, io_setup						;Set up PORTB to output to leds
			out		PORTD, io_setup						;Turn on all PORTD pullup resisitors on chip

;------------------------Loop section------------------------
loop:		
			in		input, PIND						;Take input from switch
			rcall	split								;Calling split and returning

			rcall	addition							;Change to what math you want to do

			out		PORTB, output						;Sends answer to LEDs
			rcall	delay_100ms
			clr		output								;Clear the output to zeros
			clr		counter								;Clear the counter to zeros

			rjmp	loop

;------------------------------------------------------------
split:
			mov		num_a, input						;Saving the input bytes
			mov		num_b, input						;Saving the input bytes
			
			andi		num_a, 0b00001111					;Bitmask to remove the top significant bits (Only the 4 least sig left)
			swap	num_b								;Swap the nibbles
			andi		num_b, 0b00001111					;Bitmask to remove the new top significant bits (Only the 4 most sig left)
			nop
			ret

;------------------------------------------------------------		
addition:
			add		num_a, num_b						;Add A and B and save it in A
			mov		output, num_a						;Move the value to output register
			nop
			ret	

;------------------------------------------------------------
subtraction:
			sub		num_a, num_b						;Subtract A and B and save it in A
			mov		output, num_a						;Move the value to output register
			nop
			ret

;------------------------------------------------------------
subtraction_two:
			com		num_b								;Taking 'Ones Complement' aka flip the bits
			neg		num_b								;Taking the 'twos complement'
			add		num_a, num_b						;Add the two registers together to get a subtraction
			mov		output, num_a						;Move the value to output register
			nop
			ret


;------------------------------------------------------------
multiplication:
			mul		num_a, num_b						;Multiply A and B and save it in A
			mov		output, num_a						;Move the value to output register
			nop
			ret

;------------------------------------------------------------
multiplication_no_mul:

			lsr		num_b								;Shift multiplier over with carry
			brcc	multiplication_add					;If the shifted out bit is a 1, branch else continue

			add		output, 0b00000000					;Add all zeros (AKA does nothing)
			lsl		num_a								;Shift multicand over to the left

			inc		counter								;Counts how many times this loop activates
			cpi		counter, 0b00000100					;Compares to 4, the size of each number
			brne	multiplication_no_mul				;Breaks if not equal to 4

			nop
			ret											;Return to the main loop

;------------------------------------------------------------
multiplication_add:
			add		output, num_a						;Add multicand to output
			lsl		num_a								;Shift multicand over to the left
			nop
			rjmp	multiplication_no_mul

divide:
			

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