; CSC-330 Lab 10 B
; ADC Basics
; This program will show the basic functionality of the Analog-to-Digital Converter (ADC)
;
; Resolution of ADC [10-bit]
; ADC first conversition [25 ADC cycles]
; Normal ADC conversition [13 ADC cycles]
; ADC Values:
;	Vin = 0.5V: ADC Value = 102; 0001100110
;	Vin = 2.2V: ADC Value = 405; 0110010101
;	Vin = 4.7V: ADC Value = 962; 1111000010

.cseg													
.def			io_set			= r16
.def			workhorse		= r17
.def			adc_value_low	= r18
.def			adc_value_high	= r19
.def			counter			= r20					

.org			0x0000									
				rjmp		io_setup						
.org			0x0100									

;-------------------------------------------------------------
io_setup:			
				ldi			io_set, 0xFF				; Load all 1s into io_set
				out			DDRB, io_set				; Set port D to outputs
				out			DDRD, io_set				; Set port B to all outputs
												
				ldi			workhorse, 0b01000010		; Use external Vref and use ADC02
				sts			ADMUX, workhorse

;-------------------------------------------------------------
controller:
				rjmp		adc_setup		
			
;-------------------------------------------------------------
adc_setup:				
				ldi			workhorse, 0b11001111		; Set prescalar for 128, and enable and start ADC and enable the interupt
				sts			ADCSRA, workhorse

;-------------------------------------------------------------
wait_adc:		
				lds			workhorse, ADCSRA			; Store the value of ADCSRA for comparision
				andi		workhorse, 0b00010000		; Bitmask 'ADCSRA' to keep only interupt flag
				breq		wait_adc					; Loop back to wait_adc if the zero flag is set 
														;	andi result = 0
				rjmp		position_display			; COMMENT for Part 1

;-------------------------------------------------------------
show:									
				lds			adc_value_low, ADCL			; Save values of low ADC conversition
				lds			adc_value_high, ADCH		; Save values of high ADC conversition
				out			PORTD, adc_value_low		; Output the low values
				out			PORTB, adc_value_high		; Output the high values
														
				rjmp		controller

;-------------------------------------------------------------
position_display:
				lds			adc_value_low, ADCL			; Save lower value of ADC conversion
				lds			counter, ADCH				; Save upper values of ADC conversion
				rol			adc_value_low				; Rotate lower values left and MSB moved to carry
				rol			counter						; Rotate upper values left and carry moved to LSB
				ldi			workhorse, 0b00000001		; Save value of workhorse to counter

;-------------------------------------------------------------		
display_loop:		
				lsl			workhorse					; Shift the bit to the left				
				dec			counter						; Decrement 1
				brne		display_loop				; Loop back if counter doesnt equal zero

				out			PORTD, workhorse
				rjmp		controller					; Loop back to start of program
