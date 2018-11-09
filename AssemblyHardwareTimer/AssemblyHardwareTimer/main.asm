;Setting up the hardware timer for different frequencies
;James Deromedi
;Setting the amount of steps raises the 'floor' to count to 256
;f[timer] at prescalar 1024 = 15625Hz
;	f[squarewave] = 30.5Hz
;f[timer] at prescalar 1024 = 62500Hz
;	f[squarewave] = 122.07Hz	

.def			io_setup	= r16						
.def			workhorse	= r17						
.cseg													
.org			0x0000									
				rjmp		setup						
.org			0x0100									

;------------------------------------------------------
setup:			
				ser			io_setup							
				out			DDRD, io_setup					;Sets all bits in DDRD	

				ldi			workhorse, 0b00000000			
				out			TCCR0A, workhorse				;Set TCCR0A for normal operations
				sts			TCCR1A, workhorse	
				sts			TCCR2A, workhorse
				ldi			workhorse, 0b00000100		
				out			TCCR0B, workhorse				;Set TCCR0B for prescalar (1024 for part 1 / 256 for part 2)
				out			TCCR0B, workhorse
				out			TCCR0B, workhorse

;------------------------------------------------------																												
loop:						
														
				ldi			workhorse, 0b10111001			; For generating a frequency of 440Hz
				out			TCNT0, workhorse				; Change for different frequencies

				ldi			workhorse, 0b01110111			; For generating a frequency of 440Hz
				sts			TCNT1L, workhorse				; Change for different frequencies

				ldi			workhorse, 0b01011111			; For generating a frequency of 440Hz
				sts			TCNT2, workhorse				; Change for different frequencies

				rcall		wait_t0_overflow
				rjmp		loop

;------------------------------------------------------
wait_t0_overflow:										
				in			workhorse, TIFR0				; Save the value of the interupt register
				
				

				andi		workhorse, 0x01					; Check if the interupt flag is set
				breq		output1				; Break if it is not set
				rcall		output1
t1:
				lds			r22, TIFR1
				andi		r22, 0x01					; Check if the interupt flag is set
				breq		t1				; Break if it is not set
				rcall		output2
t2:
				lds			r23, TIFR2
				andi		r23, 0x01					; Check if the interupt flag is set
				breq		t2				; Break if it is not set
				rcall		output3

				cbr			workhorse, 0b11111110			
				out			TIFR0, workhorse				; Set the LSB to high and the rest low
				out			TIFR1, workhorse
				out			TIFR2, workhorse

				ret

output1:
				sbi			PIND, 1	
				ret
output2:
				sbi			PIND, 2
				ret
output3:
				sbi			PIND, 3	
				ret