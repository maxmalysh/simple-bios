test_pmode:
		# Put string
		mov		$0x13, %ah
		mov		$0x2, %bl
		mov		$Pmode_msg, %si
		int		$0x31
		
#		mov		$0xAA, %ah		# Shift colors
#		int		$0x31			# Можно запихнуть эти две строки в код в обработчика прерывания таймера и радоваться
		
		ret

Pmode_msg:
	.asciz "Woo-hoo, we have succesfully switched to the protected mode!\r\n\r\n"
		