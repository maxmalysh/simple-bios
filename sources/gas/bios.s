.arch core2
.code16											
.section .ROM

.global start					
				
#################################################
#                      Rom                      #
#################################################
.org 0											# Bios starts at 0xF000:0x0000
start:											# We jump here after the CPU start-up
		cli										#
		lss		%cs:STKPTR, %sp					# We set stack at STKPTR(0xFFFE:0x9000)
		sti
		
		/* We are doing some POST routines here */
		call	scanbios						# scanbios.s
		call	init_pic						# pic.s
		call	init_timer						# timer.s
		call	init_keyboard					# keyboard_init.s
		call	real_mode_done					# stuff.s
		call	invoke_bootloader				# stuff.s 

		STKPTR:	.word	0xFFFE, 0x9000

		/* Our ROM BIOS image */
		.include "sources/gas/rom/macros.s"		# All macros go here
		.include "sources/gas/rom/scanbios.s"	# BIOS modules are initialized here
		.include "sources/gas/rom/pic.s"		# PIC initialization
		.include "sources/gas/rom/timer.s"		# PIT initialization
		.include "sources/gas/rom/keyboard.s"	# Keyboard  initialization, buffer routines, translation et.c.
		.include "sources/gas/rom/ivt.s"		# All int handlers are here
		.include "sources/gas/rom/stuff.s"		# Bootloader 
#################################################


#################################################
#              CPU starts up here               #
#################################################
.code16											#
.section .ejump 								# F000:FFF0
		ljmp	$0xF000, $start					# processor starts here
												#
.org 0x0E										#
	.word	0x99FC								# System ID
												#
#################################################

