#================================================
#===================   PIC    ===================
init_pic:
		push	%ax
		
		EndOfInterrupt
		
		outb 	%al, $0xA0 

		movb	$0x11, %al						# ICW1
		outb	%al, $0x20		
		
		movb	$0x11, %al 
		outb	%al, $0xA0	
		
		movb	$0x8, %al						# ICW2
		outb	%al, $0x21 		
		
		movb	$0x70, %al
		outb	%al, $0xA1 	
		
		movb	$0x4, %al 						# ICW3
		outb	%al, $0x21 		

		movb	$0x2, %al
		outb	%al, $0xA1	
		
		movb	$0x5, %al 						# ICW4
		outb	%al, $0x21 		
		
		movb	$0x1, %al
		outb	%al, $0xA1	
		
		PIC_mask $0b11111111, $0b11111111

		pop		%ax
		PutString   "PIC have been successfully initialized.\r\n", color_good
		ret


#================================================
