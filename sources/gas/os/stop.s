stop:  
		xor		%ah, %ah		# Wait for keystroke and read 
		int		$0x30
		
		mov		$0xE, %ah		# Print char
		mov		$0x3, %bx
		int		$0x31
		
		jmp		stop

