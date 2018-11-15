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


.include		"TWI_polling_lib.asm"

.def			io_setup	= r16						
.def			workhorse	= r17						
.cseg													
.org			0x0000									
				rjmp		setup					
.org			0x0100									

;------------------------------------------------------
setup:
			rcall		twi_setup
			
loop:
			rcall		twi_start	
