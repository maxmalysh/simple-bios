#================================================
#=================== KEYBOARD  ==================

.include "sources/gas/rom/keyboard_buffer.s"					
.include "sources/gas/rom/keyboard_init.s"
.include "sources/gas/rom/keyboard_scancodes.s"

#----------------[ Video Memory ]---------------#
		.equ	VM_BASE,	0xB800				# Video Memory base segment.
		.equ	VM_POS,		0x3E				# 40:3Eh, позиция "курсора"
		.equ	VM_SIZE,	80*25*2				# Размер задействованной видеопамяти
#-----------------------------------------------#(макс. количество символов на экране, размер экрана * 2, т.к. 1 символ = 2 байта)

/*
#------------------[ KB PRINT ]-----------------# receives 1 argument
KB_PRINT:										# al <--- scancode
		push	%es								#
		push	%ds								#
		push	%bx								#
												#
		mov		$VM_BASE, %bx 					# 
		mov		%bx, %ds						#
		mov		$0x40, %bx 						# BIOS data segment
		mov		%bx, %es						#
												#
		mov		%es:VM_POS, %bx					#
		cmp		$VM_SIZE, %bx 					# 
		jl		kb_pr1							# if VM_POS > VM_SIZE
		xor		%bx, %bx						# then VM_POS := 0
kb_pr1:	movw	%bx, %es:VM_POS					#
		movb	%al, %ds:(%bx) 					#
		addw	$2, %es:VM_POS 					# 
												#
		pop		%bx								#
		pop		%ds								#
		pop		%es								#
		ret										#
#-----------------------------------------------#

#---------------[ KB_get_char  ]----------------# not used!
KB_get_char:									#
		push	%ax								#
		push	%bx								#
kb_gc_1:										#
		xor		%ah, %ah						#
		int		$0x16							# int 0x16, 0 func. - GetChar 				
		cmp		$0xFF, %al						# AL <-- result
		je		kb_gc_1							#		
												#
		mov		$0xE, %ah 						#
		mov		$0, %bh							#
		int		$0x10							#
												#
		pop		%bx								#
		pop		%ax								#
		ret										#
#-----------------------------------------------#
*/