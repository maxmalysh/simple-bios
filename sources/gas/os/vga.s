################################################# DH - x
#                    Cursor                     # DL - y
################################################# Returns nothing	
VGA_SET_CURPOS:
		push	%eax
		push	%ebx
		push	%ecx
		push	%edx
		
		xchg	%dl, %dh
		mov		%dx, %bx
		#AX will contain 'position'
		mov		%bx, %ax
		and		$0xFF, %ax 					#set AX to 'row'
		mov		$80, %cl    
		mul		%cl							#row*80
 
		mov		%bx, %cx			   
		shr		$8, %cx						#set CX to 'col'
		add		%cx, %ax 					#+ col
		mov		%ax, %cx					#store 'position' in CX
 
		#cursor LOW port to vga INDEX register
		mov		$0xF, %al 			 
		mov		$0x3d4, %dx 				#VGA port 3D4h
		out		%al, %dx 			 
 
		mov		%cx, %ax 					#restore 'postion' back to AX  
		mov		$0x3d5, %dx 				#VGA port 3D5h
		out		%al, %dx 					#send to VGA hardware
	
		#cursor HIGH port to vga INDEX register
		mov		$0xE, %al
		mov		$0x3d4, %dx 				#VGA port 3D4h
		out		%al, %dx
 
		mov		%cx, %ax					#restore 'position' back to AX
		shr		$8, %ax 					#get high byte in 'position'
		mov		$0x3d5, %dx 				#VGA port 3D5h
		out		%al, %dx					#send to VGA hardware
		
		pop		%edx
		pop		%ecx
		pop		%ebx
		pop		%eax
		ret
		
################################################# DH - x
#                     Stuff                     # DL - y
################################################# Returns BP - position
VGA_CALC_POS:
		push	%eax
		push	%ebx
		push	%ecx
		
		xchg	%dl, %dh					# Нет времени исправлять
		mov		%dx, %bx
		#AX will contain 'position'
		mov		%bx, %ax
		and		$0xFF, %ax 					#set AX to 'row'
		mov		$80, %cl    
		mul		%cl							#row*80
 
		mov		%bx, %cx			   
		shr		$8, %cx						#set CX to 'col'
		add		%cx, %ax 					#+ col
		mov		%ax, %bp					# За такое должно быть стыдно
		
		pop		%ecx
		pop		%ebx
		pop		%eax
		ret

