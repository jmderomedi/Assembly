; --------------------------------------------------------------------------------------------------------------------------------------
; TWI polling library
; Small library for setting up TWI protocol (without interrupts) in AVR assembly
; Author: Kristof Aldenderfer
; Date: 2018.04.14
;
; Register usage:
;		- r16: is the register doing all the heavy lifting.
;		- r17: is the data register from which data will be sent or into which data will be loaded.	
; --------------------------------------------------------------------------------------------------------------------------------------
.equ					TWI_init_chk =	0x08
.equ					TWI_ack_addr =	0x18
.equ					TWI_ack_data =	0x28
; --------------------------------------------------------------------------------------------------------------------------------------
; Sets up TWI protocol
; --------------------------------------------------------------------------------------------------------------------------------------
twi_setup:
						in				r16, DDRC								; set up SDA/SCL as inputs
						andi			r16, 0b11001111
						out				DDRC, r16
						ldi				r16, 0b00110000							; enable pullups on SDA/SCL
						out				PORTC, r16
						lds				r16, TWSR0								; set prescalar to 1 by clearing TWPS1 and TWPS0
						andi			r16, 0b11111100
						sts				TWSR0, r16
						ldi				r16, 12									; set freq to 400kHz
						sts				TWBR0, r16								; TWBR = ((F_CPU / TWI_FREQ) - 16) / 2
						ldi				r16, (1<<TWEN | 1<<TWIE)				; turn on TWI
						sts				TWCR0, r16
						ret
; --------------------------------------------------------------------------------------------------------------------------------------
; Generates a TWI START
; --------------------------------------------------------------------------------------------------------------------------------------
twi_start:				ldi				r16, (1<<TWINT | 1<<TWSTA | 1<<TWEN)
						sts				TWCR0, r16								; generate START condition
	twi_start_wait:		lds				r16, TWCR0								
						sbrs			r16, TWINT
						rjmp			twi_start_wait
						lds				r16, TWSR0								; check to make sure bus works
						andi			r16, 0b11111000
						cpi				r16, TWI_init_chk						; check if an ACK was recieved
						;brne			twi_error
						ret
; --------------------------------------------------------------------------------------------------------------------------------------
; Generates a TWI STOP
; --------------------------------------------------------------------------------------------------------------------------------------
twi_stop:				ldi				r16, (1<<TWINT | 1<<TWSTO | 1<<TWEN)
						sts				TWCR0, r16								; generate STOP condition
						ret
; --------------------------------------------------------------------------------------------------------------------------------------
; Sends TWI address, slave device to speak to
; --------------------------------------------------------------------------------------------------------------------------------------
twi_send_addr:			sts				TWDR0, r17								; write byte
						ldi				r16, (1<<TWINT | 1<<TWEN)
						sts				TWCR0, r16								; start sending
	twi_send_addr_wait:	lds				r16, TWCR0
						sbrs			r16, TWINT
						rjmp			twi_send_addr_wait
						lds				r16, TWSR0								; check for an ACK
						andi			r16, 0b11111000
						cpi				r16, TWI_ack_addr
						;brne			twi_error
						ret
; --------------------------------------------------------------------------------------------------------------------------------------
; Sends one byte over TWI
; --------------------------------------------------------------------------------------------------------------------------------------
twi_send_byte:			sts				TWDR0, r17								; write byte
						ldi				r16, (1<<TWINT | 1<<TWEN)
						sts				TWCR0, r16								; start sending
	twi_send_byte_wait:	lds				r16, TWCR0
						sbrs			r16, TWINT
						rjmp			twi_send_byte_wait
						lds				r16, TWSR0								; check for an ACK
						andi			r16, 0b11111000
						cpi				r16, TWI_ack_data
						;brne			twi_error
						ret
; --------------------------------------------------------------------------------------------------------------------------------------
; When TWI generates an error, end up here
; --------------------------------------------------------------------------------------------------------------------------------------
twi_error:				ldi				r16, 0b00000001
						out				PORTD, r16
	twi_error_loop:		rjmp			twi_error_loop

.exit