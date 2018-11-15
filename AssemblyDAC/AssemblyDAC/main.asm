; CSC-330 Lab 10 B
; DAC Basics
; This code completes simple Digital to Analog conversion by inputing a analog signal
; convert it to digital then back to analog

.cseg											
.def			io_set				= r16
.def			workhorse			= r17


.org			0x0000									
				rjmp		io_setup						
.org			0x0100									

;------------------------------------------------------------------------------------------------------
io_setup:			
				ldi			io_set, 0xFF					; Load all 1s into io_set
				out			DDRB, io_set					; Set port D to outputs
												
				ldi			workhorse, 0b01000010			; Use external Vref and use ADC02
				sts			ADMUX, workhorse
				
;------------------------------------------------------------------------------------------------------
controller:
				rjmp		adc_setup		
			
;------------------------------------------------------------------------------------------------------
adc_setup:				
				ldi			workhorse, 0b11001111			; Set prescalar for 128, and enable and start ADC and enable the interupt
				sts			ADCSRA, workhorse

;------------------------------------------------------------------------------------------------------
wait_adc:		
				lds			workhorse, ADCSRA				; Store the value of ADCSRA for comparision
				andi		workhorse, 0b00010000			; Bitmask 'ADCSRA' to keep only interupt flag
				breq		wait_adc						; Loop back to wait_adc if the zero flag is set 
															;	andi result = 0
				rjmp		adc_conversion					

;------------------------------------------------------------------------------------------------------
adc_conversion:
				lds			workhorse, ADCL					;Save the lower part of the conversion
				out			PORTD, workhorse				;Send that signal to R2R ladder for conversion
