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
; 0b00100001 for system clock setup
; 0b10100000 for ROW mode and INT output is active low
; 0b10000111 to setup display register and set blink to 0.5Hz
; 0b11101111 to set duty for 16/16 or max brightness
; Problem 1: SDA-PC4, SCL-PC5 (Pg. 14)
; Problem 7: Set TWBR to 12 for 400kHz




.def			io_setup		= r16						
.def			workhorse		= r17			
.def			z_low			= r19				;Low value for pointer
.def			z_high			= r23				;High value for pointer
.def			led_address		= r24				;Counter
.def			list_count		= r25				;Counter to know which list to go into

;-------------------------------------------------------------------------------
.macro			set_pointer
				ldi			@0, low(@2)
				ldi			@1, high(@2)
.endmacro
;-------------------------------------------------------------------------------
;Takes in a value of a location of RAM that the data is being sent too
;@0 The RAM location address for the slave			
.macro			send_RAM_location
				mov			workhorse, @0
				rcall		twi_send_byte
.endmacro
;-------------------------------------------------------------------------------
;Sends data to the slave to address called before it
;@0 Regisiter! The data being sent to a command module
.macro			send_byte_data
				mov			workhorse, @0
				rcall		twi_send_byte
				inc			led_address
.endmacro
;-------------------------------------------------------------------------------
;Sends data to the slave to address called before it
;@0 Constant value! The data being sent to a command module
.macro			send_byte_data_imm
				ldi			workhorse, @0
				rcall		twi_send_byte
				inc			led_address
.endmacro
;-------------------------------------------------------------------------------
;Calls the start command, sets the location for command
;@0 The location address for the command modules
.macro			send_byte_address
				rcall		twi_start
				ldi			workhorse, @0
				rcall		twi_send_addr
.endmacro

.cseg						
.org				0x0000
					rjmp				setup

.include			"TWI_polling_lib.asm"

;-------------------------------------------------------------------------------
setup:
			ldi			led_address, 0b00000000		;Intialize the counter to 0
			ldi			list_count, 0b00000000
			rcall		twi_setup					;Setup the TWI for communication

			;Start the internal system clock block
send_byte_address		0b11100000
send_byte_data_imm		0b00100001

			;Setup the Row/Int output block
send_byte_address		0b11100000
send_byte_data_imm		0b10100000		

			;Setup for dimming block
send_byte_address		0b11100000
send_byte_data_imm		0b11101111

			;Setup for blinking display on/off block
send_byte_address		0b11100000
send_byte_data_imm		0b10000001
				
set_pointer				ZL, ZH, (rtfm_list*2)		;Set the pointer intially

;-------------------------------------------------------------------------------
loop:
			lpm			z_low, Z+					;Load in the lower part of pointer
			lpm			z_high, Z+					;Load in the higher part of pointer

send_byte_address		0b11100000					;Send address to write to RAM

send_RAM_location		led_address					;Send RAM location of the led
			
send_byte_data			z_low						;Send lower byte of the word to screen

send_byte_data			z_high						;Send upper byte of the word to screen

			rcall		twi_stop					;Stop command of the communication

			
			cpi			led_address, 0b00001000		;Checks if the counter has reached 8
			brne		loop						;If it has not, loop again
			inc			list_count
			rcall		list_assignment
			rcall		reset						;If it has call reset

			
			rcall		delay_1s
						
			rjmp		loop

;-------------------------------------------------------------------------------
list_assignment:			
			cpi			list_count, 0b00000001
			breq		list_0

			cpi			list_count, 0b00000010
			breq		list_1

			cpi			list_count, 0b00000011
			breq		list_2

			cpi			list_count, 0b00000100
			breq		list_3

			cpi			list_count, 0b00000101
			breq		list_4
				
			cpi			list_count, 0b00000110
			breq		list_5

			cpi			list_count, 0b00000111
			breq		list_6

list_assign_ret:
			ret

reset:
			ldi			led_address, 0b00000000		;Sets the counter to zero		
			ret										;Returns

;-------------------------------------------------------------------------------
list_0:
set_pointer				ZL, ZH, (rtfm_list*2)		;Resets the pointer to start at top of array
			rjmp		list_assign_ret
;-------------------------------------------------------------------------------
list_1:
set_pointer				ZL, ZH, (read_list*2)		;Resets the pointer to start at top of array
			rjmp		list_assign_ret
;-------------------------------------------------------------------------------
list_2:
set_pointer				ZL, ZH, (the_list*2)		;Resets the pointer to start at top of array
			rjmp		list_assign_ret
;-------------------------------------------------------------------------------
list_3:
set_pointer				ZL, ZH, (F_ing_list*2)		;Resets the pointer to start at top of array
			rjmp		list_assign_ret
;-------------------------------------------------------------------------------
list_4:
set_pointer				ZL, ZH, (man_list*2)		;Resets the pointer to start at top of array
			rjmp		list_assign_ret
;-------------------------------------------------------------------------------
list_5:
set_pointer				ZL, ZH, (ual_list*2)		;Resets the pointer to start at top of array
			rjmp		list_assign_ret
;-------------------------------------------------------------------------------
list_6:
set_pointer				ZL, ZH, (on_list*2)		;Resets the pointer to start at top of array
			ldi			list_count, 0b00000000
			rjmp		list_assign_ret

;-------------------------------------------------------------------------------
;Varlist to print out RTFM
rtfm_list:	.DW			0b0010000011110011,\
						0b0001001000000001,\
						0b0000000001110001,\
						0b0000010100110110

;-------------------------------------------------------------------------------
;Varlist to print out all leds ON						
on_list:	.DW			0b0111111111111111,\
						0b0111111111111111,\
						0b0111111111111111,\
						0b0111111111111111

;-------------------------------------------------------------------------------
;Varlist to print out READ
read_list:	.DW			0b0010000011110011,\
						0b0000000011111001,\
						0b0000000011110111,\
						0b0001001000001111

;-------------------------------------------------------------------------------
;Varlist to print out THE
the_list:	.DW			0b0000000000000000,\
						0b0001001000000001,\
						0b0000000011110110,\
						0b0000000011111001

;-------------------------------------------------------------------------------
;Varlist to print out F.ING
F_ing_list:	.DW			0b0100000001110001,\
						0b0001001000000000,\
						0b0010000100110110,\
						0b0000000010111101

;-------------------------------------------------------------------------------
;Varlist to print out MAN
man_list:	.DW			0b0000000000000000,\
						0b0000010100110110,\
						0b0000000011110111,\
						0b0010000100110110

;-------------------------------------------------------------------------------
;Varlist to print out UAL
ual_list:	.DW			0b0000000000111110,\
						0b0000000011110111,\
						0b0000000000111000,\
						0b0000000000000000

;-------------------------------------------------------------------------------

delay_1s:	ldi			R20, 0x53
delay_1s_1:	ldi			R21, 0xFB
delay_1s_2:	ldi			R22, 0xFF
delay_1s_3:	dec			R22
			brne		delay_1s_3
			dec			R21
			brne		delay_1s_2
			dec			R20
			brne		delay_1s_1
			ldi			R20, 0x02
delay_1s_4:	dec			R20
			brne		delay_1s_4
			nop	
			ret	