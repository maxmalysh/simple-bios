.arch core2
.code16				
.section .eMBR	
			
.global _MBR
################################################# Это ещё не загрузчик, а всего-лишь
#                 MBR Bootstrap                 # 	загрузочный сектор (MBR), который
################################################# 	далее передаст управление загрузчику 
_MBR:	
		####	Setting up the Stack Pointer to _MBR_STKPTR
		cli                 					
		lss		%cs:(0x7C00 + _MBR_STKPTR - _MBR), %sp		
		sti                  					

		####	Print bootsector info
		mov		$(0x7C00 + _MBR_logo - _MBR), %ax 
		call	PrintString						
		
		####	Copying the MBR code to new location
		xor		%ax, %ax						#
		mov		%ax, %ds						# From ds:si
		mov		$0x7C00, %si           			#	( 0x0000 : 0x7C00)
		mov		%ax, %es						# To   es:di
		mov		$0x0600, %di         			#	( 0x0000 : 0x0600)
		mov		$128, %cx 	        			# Copy 128 dwords (512 bytes)
		cld										#
		rep 	movsl							#
					
		####	Jump to the copy of code.					
		ljmp	$0x0000, $(0x0600 + jmp600 - _MBR) 
		
		####	The following code will be executed at 0x0000 : (offset jmp600)  
jmp600:	mov		$(0x0600 + _MBR_copy - _MBR), %ax 	 
		call	PrintString					
		
		####	Copy bootloader to the RAM     
		mov		$0xF000, %si					# ds:si - адрес нашего загрузчика 
		mov		%si, %ds						# В данном случае это cs : offset _BTLDR
		mov		$_BTLDR, %si					# 
		
		xor		%di, %di						# es:di - сюда в RAM мы его скопируем
		mov		%di, %es						# (0x0000 : 0x7C00 )
		mov		$0x7C00, %di					# 

		mov		$_BTLDR_size, %cx				# Размер загрузочного сектора - _BTLDR_size байт
		cld										#
		rep		movsb							# 								
		
		####	Print message and wait for a keystroke 
		mov		$(0x0600 + _MBR_hit - _MBR), %ax 
		call	PrintString
		call	WaitKey
		
		#### Pass the control to the bootloader
		ljmp	$0x0000, $0x7C00				
		
		
_MBR_STKPTR:									# MBR stack pointer
		.word	0x7C00, 0x0000					#
												
		.include "sources/gas/mbr/functions.s"	# All functions called are here
		.include "sources/gas/mbr/data.s"		# Text messages are here
												
.org _MBR + 510, 0								#
		.word	0xAA55      					# MBR signature
												#
_MBR_size = . - _MBR							# 512 bytes
#################################################

