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
			in		input, PORTD

			rjmp	addition

;------------------------------------------------------------
split:
					num_a, input
			mov		num_b, input
			(num_a>>4)

			lsl		num_b
			lsl		num_b
			lsl		num_b
			lsl		num_b

addition:
			add		

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