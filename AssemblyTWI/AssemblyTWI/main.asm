; Author: James Deromedi
; using TWI to communicate with a alphanumeric display (Pg. 297-
; Start Condition for Master Reciever (Pg.314)
; Start Condition for Slave Transmitter (Pg. 317)
; Regisiters:
;     TWBR (Pg. 328)
;     TWSR (Pg. 329)
;     TWAR (Pg. 330)
;     TWDR (Pg. 331)
;     TWCR (Pg. 332)
;     TWAMR(Pg. 334)
;
; Problem 1: SDA-PC4, SCL-PC5 (Pg. 14)
; Problem 7: Set TWBR to 12 for 400kHz




.def			io_setup	= r16						
.def			workhorse	= r17						
.cseg													
								
.org				0x0000
					rjmp				setup
.include		"TWI_polling_lib.asm"

;------------------------------------------------------
setup:
			;0b00100001 for system clock setup
			;0b10100000 for ROW mode and INT output is active low
			;0b10000111 to setup display register and set blink to 0.5Hz
			;0b11101111 to set duty for 16/16 or max brightness
			;from 00 - 0F
			ldi			r19, 0b00000001
			rcall		twi_setup				;Sets up communication with the slave with TWI

			;Start the internal system clock
			rcall		twi_start				;Start the process
			ldi			workhorse, 0b11100000		
			rcall		twi_send_addr			;The location of TWDR0
			ldi			workhorse, 0b00100001
			rcall		twi_send_byte			;Start the system clock
			rcall		twi_stop				;Stop the communication to slave

			;Setup the Row/Int output pin
			rcall		twi_start				
			ldi			workhorse, 0b11100000
			rcall		twi_send_addr			
			ldi			workhorse, 0b10100000
			rcall		twi_send_byte			
			rcall		twi_stop				

			;Setup for dimming
			rcall		twi_start				;Start the process
			ldi			workhorse, 0b11100000		
			rcall		twi_send_addr			
			ldi			workhorse, 0b11101111
			rcall		twi_send_byte			
			rcall		twi_stop				

			;Setup for blinking set display on/off
			rcall		twi_start				;Start the process
			ldi			workhorse, 0b11100000	
			rcall		twi_send_addr			
			ldi			workhorse, 0b10000001
			rcall		twi_send_byte			
			rcall		twi_stop				

loop:
			;Updating the display
			rcall		twi_start
			ldi			workhorse, 0b11100000
			rcall		twi_send_addr
			ldi			workhorse, 0b00000000
			rcall		twi_send_byte

			
			ldi			workhorse, 0b00000000
			rcall		twi_send_byte	
			rcall		twi_stop

			lsl			r19

			rjmp		loop
