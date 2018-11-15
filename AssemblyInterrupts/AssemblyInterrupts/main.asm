;Setting up a interupt vector to handle timer overflow (Pg. 147 - 157)
;James Deromedi
;Registers:
;     TCCR0A (Pg. 147)
;     TCCR0B (Pg. 150)
;     TIMSK0 (Pg. 152)
;     TCNT0  (Pg. 154)
;     TIFR0  (Pg. 157)
;f[timer] at prescalar 1024 = 15625Hz
;	f[squarewave] = 30.5Hz
;f[timer] at prescalar 1024 = 62500Hz
;	f[squarewave] = 122.07Hz	


.def			io_setup	= r16						
.def			workhorse	= r17						
.cseg								
					
.org			0x0000									
				rjmp		setup	
.org			0x001C										;Jump to overflow interrupt vector for compare A
				rjmp		ISR_TIMER0_OVF				
.org			0x0100									

;-----------------------------------------------------------------------------------------------------------------
setup:			
				ser			io_setup							
				out			DDRD, io_setup					;Sets all bits in DDRD	

				ldi			workhorse, 0b00000010			;Set Compare output mode to clear on compare match		
				out			TCCR0A, workhorse				;Set TCCR0A for normal operations
				ldi			workhorse, 0b00000100		
				out			TCCR0B, workhorse				;Set TCCR0B for prescalar (1024 for part 1 / 256 for part 2)

				ldi			io_setup, (1<<OCIE0A)
				out			TIMSK0, io_setup				;Set the output compare match A interrupt flag

				ldi			io_setup, 0b10000000
				out			OCR0A, io_setup					;Set value to be compared to by TNCT0 (Change for different frequencies)
				sei											;Set the global interrupt flag

;-----------------------------------------------------------------------------------------------------------------																											
loop:						
				rjmp		loop							;Do things here that you want to complete
															;While waiting for the overflow to happen

;-----------------------------------------------------------------------------------------------------------------
ISR_TIMER0_OVF:	
				sbi			PIND, 1							; Toggle the led
				ldi			workhorse, 0b00000010	
				out			TIFR0, workhorse				; Reset the interrupt flag
				reti
