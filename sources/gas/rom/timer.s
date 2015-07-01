#================================================
#===================  TIMER  ====================
#-----------------[ Init timer ]----------------#
init_timer:
		push	%ax
		push	%es
	
		movb	$0b00110110, %al
		outb	%al, $0x43
		
		mov		$64496, %ax						# Bochs freq.
		outb	%al, $0x40
		
		movb	%ah, %al
		outb	%al, $0x40
		
		xor		%ax, %ax						#---------------- timer handler setup
		mov		%ax, %es			
		cli	
		movw	$int08_handler, %es:0x08*4		# offset int08_handler
		movw	%cs, %es:0x08*4+2 				# seg int08_handler 
		sti
		
		mov		$0x40, %ax 
		mov		%ax, %es
		
		movb	$0, %es:TCOUNT
		movb	$0, %es:NOTE
		
		PIC_mask $0b11111110, $0b11111111

		pop		%es
		pop		%ax
		PutString   "PIT (timer) have been successfully initialized.\r\n", color_good
		ret		     
	
#-----------------------------------------------#
/*
#-------------[ Beeping routines ]--------------#
beep:
		push	dx
		push	cx
		
		mov		dx, 0FDFh#
		call	sound_on
		mov		dx, 02h#
beep_l: loop    beep_l
        dec     dx
        jnz     beep_l
		call	sound_off
		
		pop		cx
		pop		dx
		ret
#-----------------------------------------------#

#-----------------------------------------------#
sound_on:								# receives frequency in DX
		push	ax
        mov     al, 10110110b			# 2-ой канал таймера, прямоуг. импульсы
        out     43h, al				
       
		mov     ax, dx					# загружаем частоту звука
        out     42h, al				
        mov     al, ah					# ^...
        out     42h, al				
        in      al, 61h					#			
        or      al, 00000011b			# первые два бита - вкл. динамик
		out     61h, al					# 
		pop		ax
		ret
#-----------------------------------------------#

#-----------------------------------------------#
sound_off proc near
		push	ax
		in		al, 61h
		and		al, 11111100b
		out		61h, al
		pop		ax
		ret
#-----------------------------------------------#
*/
#================================================
		