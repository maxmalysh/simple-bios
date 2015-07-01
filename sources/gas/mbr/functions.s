##############     Print string    ############## 
PrintString:									#
		mov		%ax, %si 						#
		push	$0								#
		pop		%ds								#
		cld
.NextChar:										#
		lodsb									# Load char from string
		cmp		$0x00, %al 						# Check for null terminator
		jz		.EndChar						#
		mov		$0x0E, %ah 						# Function: Write text in teletype mode
		mov		$0x0007, %bx 					# Page 0, Attributes Black & White
		int		$0x10							# Call Video BIOS Services
		jmp		.NextChar						#
.EndChar:										#
		ret										#
		
###########    Wait for a keystroke   ###########
WaitKey:										#
		mov		$0x13, %ah						# 
		int		$0x16							# Int 16, 13 function: flush KB buffer
.WaitAgain:										#
		xor		%ah, %ah						# No need to save registers here. 
		int		$0x16							# Int 16, 0 function: getchar
		cmp		$0x1C, %ah						# <---- Scancode is     AH now; $0x1C = enter
		jne		.PrintChar						# <---- ASCII symbol is AL now
		ret										#
.PrintChar:										#
		mov		$0x0E, %ah 						# int 10, 0xE function: 
		mov		$0, %bh							# print char (teletype)
		int		$0x10							#
		jmp		.WaitAgain						#
		

		