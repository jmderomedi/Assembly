; CSC-330 Lab 10 B
; ADC Basics
; This program will show the basic functionality of the Analog-to-Digital Converter (ADC)
;
; Resolution of ADC [10-bit]
; ADC first conversition [25 ADC cycles] from (28.5)
; Normal ADC conversition [13 ADC cycles]	from (28.5)
; ADC Values 
;	Vin = 0.5V: ADC Value = 102; 0001100110
;	Vin = 2.2V: ADC Value = 405; 0110010101
;	Vin = 4.7V: ADC Value = 962; 1111000010

.cseg											
.def			io_set				= r16
.def			workhorse			= r17
.def			workhorse_upper		= r18
.def			adc_value_low		= r19
.def			adc_value_high		= r20
.def			counter				= r21	
.def			compare_value_low	= r22	
.def			compare_value_high	= r23	
.def			divider_high		= r24
.def			divider_low			= r25	

.org			0x0000									
				rjmp		io_setup						
.org			0x0100									

;-------------------------------------------------------------
io_setup:			
				ldi			io_set, 0xFF					; Load all 1s into io_set
				out			DDRB, io_set					; Set port D to outputs
				out			DDRD, io_set					; Set port B to all outputs
												
				ldi			workhorse, 0b01000010			; Use external Vref and use ADC02
				sts			ADMUX, workhorse
				
;-------------------------------------------------------------
controller:
				rjmp		adc_setup		
			
;-------------------------------------------------------------
adc_setup:				
				ldi			workhorse, 0b11001111			; Set prescalar for 128, and enable and start ADC and enable the interupt
				sts			ADCSRA, workhorse

;-------------------------------------------------------------
wait_adc:		
				lds			workhorse, ADCSRA				; Store the value of ADCSRA for comparision
				andi		workhorse, 0b00010000			; Bitmask 'ADCSRA' to keep only interupt flag
				breq		wait_adc						; Loop back to wait_adc if the zero flag is set 
															;	andi result = 0
				rjmp		setup							; COMMENT for Part 1

;-------------------------------------------------------------
setup:
				ldi			workhorse, 0b00000001
				ldi			workhorse_upper, 0b00000001
				ldi			counter, 0b00000000

				ldi			divider_high, 0b00000000
				ldi			divider_low, 0b01110000
				lds			adc_value_low, ADCL
				lds			adc_value_high, ADCH

;-------------------------------------------------------------
new_method:
				sub			adc_value_low, divider_low
				sbc			adc_value_high, divider_high
				brmi		output_new
				inc			counter
				
				rjmp		new_method

;-------------------------------------------------------------
output_new:
				ldi			compare_value_low, 0b00001000
				cp			counter, compare_value_low
				brlo		lower_leds
				cp			counter, compare_value_low
				breq		output_B_new
				lsl			workhorse_upper
				rjmp		output_B_new	
						
;-------------------------------------------------------------
lower_leds:
				cpi			counter, 0b00000000
				breq		output_D_new
				lsl			workhorse
				dec			counter
				brne		lower_leds
				rjmp		output_D_new

;-------------------------------------------------------------
output_B_new:
				ldi			io_set, 0b00000000
				out			PORTD, io_set
				out			PORTB, workhorse_upper
				rjmp		controller

;-------------------------------------------------------------
output_D_new:
				ldi			io_set, 0b00000000
				out			PORTB, io_set
				out			PORTD, workhorse
				rjmp		controller