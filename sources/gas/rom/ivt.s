#-----------[ int_08: System timer ]------------#
int08_handler:									#
		push	%ax								#
		push	%es								#
												#
		mov		$0x40, %ax						#
		mov		%ax, %es						#
		incl	%es:TCOUNT						#
												#
		EndOfInterrupt	 						#
												#
		pop		%es								#
		pop		%ax								#
		iret									#
#-----------------------------------------------#

		.equ	TCOUNT,	0x6C 							# 40:6C - 40:6E (2 bytes)
		.equ	NOTE,	0x7C					 		# 40:7C - 40:7F (4 bytes) 
		
#-------------[ int_09: Keyboard  ]-------------#
int09_handler:									#
		push	%ax								#
												#
		mov		$0xAD, %al						# Запрет сканирования
		out		%al, $0x64 						#
												#
		inb		$0x60, %al 						# Считывание скан-кода
												#
		call	KB_SC_ENQ						# Кладём его в буфер
												#
		EndOfInterrupt 							#
												#
		mov		$0xAE, %al 						# Разрешить сканирование
		out		%al, $0x64						#
												#
		pop		%ax								#
		iret									#
#-----------------------------------------------#


#-------------[ int_16: Keyboard  ]-------------#	
int16_handler:									#	
		sti										# 
		push	%bx								# no need to save AX
		cmp		$0, %ah							# 
		je		i16_gc1							# AH = 0 -> getchar
		cmp		$0x13, %ah						#
		jne		i16_exit						# no valid functions
		
		#	AH=0x13:	Flush buffer	 		#		
i16_gc13:
		xor		%ah, %ah						#
		call	KB_SC_DEQ						#
		cmp		$0xFF, %al						# 
		jne		i16_gc13						#
		jmp		i16_exit
		
		#	AH=0x0:	Waiting for scan code  		#								
i16_gc1:xor		%ah, %ah						#
		call	KB_SC_DEQ						#
		cmp		$0xFF, %al						# AL <-- result
		je		i16_gc1							#
		mov		%al, %ah						# 
		
		#		 scancode -> ASCII				#
		cmpb	$SC_TABLE_FIRST, %al			# check if it's valid scancode
		jl		i16_inv
		cmpb	$SC_TABLE_LAST, %al
		jg		i16_inv
												# check if it's command
		cmp		$0x1C, %al						# if enter
		jne		i16_ascii
		PutString "\r\n", 0
		mov		$0x0D, %al
		jmp		i16_exit
i16_ascii:										# else convert to ASCII
		xor		%bx, %bx
		mov		%al, %bl						# bl <--- scancode
		add		$SC_TABLE, %bx					# scancode + SC_TABLE
		sub		$SC_TABLE_FIRST, %bx			# scancode - SC_TABLE_FIRST
		movb	%cs:(%bx), %al					# al <--- ascii
		jmp		i16_exit
		####	end of scancode -> ASCII	 ####
i16_inv:jmp		i16_gc1								# в AL должен быть ASCII, в AH сканкод
		#mov		' ', %al						# Но трансляцию мы не сделали, поэтому 
i16_exit:										# AL <---- 0
		pop		%bx								# 
		iret									#
#-----------------------------------------------#

#------------[ int_19: Boot loader  ]-----------#	
int19_handler:
	sti
	/*	Тут мы должны были бы скопировать загрузочный сектор и загрузчик
		с жесткого диска или флоппи, но, так как для этого понадобится
		много-много человекочасов, сделаем так:
	
		1)	Загрузочный сектор и загрузчик разместим в ROM
		2)	Код ниже копирует загрузчик в память и передает управление ему
			(имитируем копирование с жесткого диска)
		3)	Затем MBR скопирует код загрузчика из ROM в RAM и
			аналогичным образом передает ему управление 	
	*/
			
	PutString	"In fact, we will load our MBR and bootloader from the ROM. In order to boot from", 0x0007
	PutString	"HDD or floppy we have to extend our BIOS, e.g. by adding an int # 0x13 to it.\r\n", 0x0007
	NewLine
	PutString	"--> Looking for a device to boot... ", 0x0008
	# looking for devices here
	PutString	"Disk found.\r\n--> Looking for a valid boot sector... ", 0x0008
	# checking if the signature (0x55AA) at 510 is present
	PutString	"Vaild MBR found.\r\n--> Copying it to the RAM (to the 0x7C00)... ", 0x0007
	
	movw	$_MBR, %si			# 
	movw	%cs, %ax			# ds:si - адрес нашего загрузчика 
	movw	%ax, %ds			# в данном случае это cs : offset _btldr
	
	xor		%di, %di			# 
	movw	%di, %es			# es:di - сюда в RAM скопируем 
	movw	$0x7C00, %di		# (0x0000 : 0x7C00 )


	movw	$512, %cx			# размер загрузочного сектора - 512 байт
	cld							# 
	rep		movsb				# 
								
	PutString	"Done. \r\n\nBIOS is passing control to the copied bootloader right now! \r\n", 0x0007
	ljmp	$0x0000, $0x7C00
#-----------------------------------------------#
	
#--------------[ obsolete int_08 ]--------------# 
#old_int08_handler proc near					#
#		pushf									#
#		push	eax								#
#		push	ecx								#
#		push	dx								#
#		push	es								#
#												#
#		mov		ax, 40h							#
#		mov		es, ax							#
#												#
#		xor		ecx, ecx						#
#		mov		cx, word ptr es:[NOTE]			# get note
#		cmp		cx, word ptr cs:[NOTES]			#
#		jnz		oldnote							#
#		xor		cx, cx							#
#		mov		es:[NOTE], cx					#
#oldnote:										#
#		mov		eax, dword ptr es:[TCOUNT]		# get timer-tick count 
#		shl		al,	4							# if eax mod 2^{8-4} != 0
#		jnz		skip							# then skip (don't change the current note)
#												#
#		mov		dx, [ecx*2+NOTES+2]				# }
#		call	sound_off						# } Loading a new note to the PIT
#		call	sound_on						# }
#												#
#		inc		word ptr es:[NOTE]				# 
#skip:											#
#		inc		dword ptr es:[TCOUNT]			# increment timer counter
#												#
#		EndOfInterrupt()						#
#												#
#		pop		es								#
#		pop		dx								#
#		pop		ecx								#
#		pop		eax								#
#		popf									#
#		iret									#
#old_int08_handler endp							#
#-----------------------------------------------#


#----------------[ freq. table ]----------------# for the obsolete int_08 handler
#NOTES	dw		16								# 
#		dw		0FDFh,	0BE4h,	0A98h,	0A00h	# D  G  A  A#
#		dw		0FDFh,	0EFBh,	0A00h,	0000h	# D  D# A# A#
#		dw		11D1h,	0D59h,	0BE4h,	0A98h	# C  F  G  A
#		dw		11D1h,	0FDFh,	0FDFh,	0000h	# C  D  D  -
#-----------------------------------------------#



