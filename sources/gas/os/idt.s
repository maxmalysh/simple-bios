#################################################
#        Таблица дескрипторов прерываний        #
#################################################	
IDT:
#----------        0x00 - 0x1F        ----------# 0-31 - исключения
		.rept 32
			.long 0, 0
		.endr
#----------        0x20 - 0x28        ----------# 32-39. IRQ0-7; Master PIC's IRQ go here 
		.gate32 offset= i20_handler, p=1, dpl=0 # 	IRQ0 - Таймер
		.gate32 offset= i21_handler, p=1, dpl=0 # 	IRQ1 - Клавиатура
		.long 0, 0								# 	IRQ2 - Каскад
		.long 0, 0								# 	IRQ3 --- COM1-4
		.long 0, 0								# 	IRQ4 _/
		.long 0, 0								# 	IRQ5 
		.long 0, 0								# 	IRQ6
		.long 0, 0								# 	IRQ7
#----------        0x28 - 0x2F        ----------# 40-47. IRQ8-15; Slave PIC's IRQ go here
		.rept 8
			.long 0, 0
		.endr
#----------        0x30 - 0x3F        ----------# 48-63.  +16 dummies
		.gate32 offset= i30_handler, p=1, dpl=0 # 	Клавиатура (программное)
		.trap32 offset= i31_handler, p=1, dpl=0 # 	Хренотень
		.rept 14								#
			.long 0, 0							#
		.endr									#
################################################# итого 64


#################################################
#                     IDTR                      #
#################################################	
idtr:	.word	. - IDT - 1						# Table Limit
		.long	0								# Linear Base Address
		
		
#################################################
#             Обработчики прерываний            #
#################################################	
								
#-----------------------------------------------#
#         Int 0x20 (таймер, аппаратное)         #
#-----------------------------------------------#
		.equ	T_COUNT,	0x46C 				# 46C - 46E (2 bytes)
i20_handler:									#
		push	%eax							#
		push	%ebx							#
		push	%ecx							#
				
		#int		$0x31

		mov		$0x7, %bh	  					# белый текст на чёрном фоне
		mov		$'0', %bl
		movb	%ds:T_COUNT, %cl
		shr		$4, %cl							# cl = cl /4
		cmp		$9, %cl							# 
		jle		i20_skip
		mov		$'A', %bl
		sub		$10, %cl
i20_skip:
		add		%cl, %bl		 				# 

		mov		$(79 * 1 * 2), %eax				# правый верхний угол
		movw	%bx, %gs:(%eax)
		
		incb	%ds:T_COUNT
#		incl	%ds:T_COUNT						# так правильно было бы
		movb	$0x20, %al 						# End of interrupt
		outb	%al, $0x20 						#
		
		pop		%ecx							#
		pop		%ebx							#
		pop		%eax							#
		iretl									# 
#-----------------------------------------------#


#-----------------------------------------------#
#       Int 0x21 (Клавиатура, аппаратное)       #
#-----------------------------------------------#
i21_handler:									#
		push	%eax							#
												#
		mov		$0xAD, %al						# Запрет сканирования
		out		%al, $0x64 						#
												#
		inb		$0x60, %al 						# Считывание скан-кода
												#
		call	KB_SC_ENQ						# Кладём его в буфер
												#
		movb	$0x20, %al 						# End of interrupt
		outb	%al, $0x20 						#
												#
		movb	$0xAE, %al 						# Разрешить сканирование
		outb	%al, $0x64						#
												#
		pop		%eax							#
		iretl									# 
#-----------------------------------------------#

					
#-----------------------------------------------#
#      Int 0x30 (Клавиатура, программное)       #
#-----------------------------------------------#
#	AH = 0x0 - get a keypress (wait if needed)
#		Receives	<---	Nothing
#		Returns		--->	AL = ASCII
#							AH = Scancode
#-----------------------------------------------#
#	AH =  
#		Receives	<---	
#		Returns		--->	AL = 
#							AH = 
#-----------------------------------------------#
#	AH =  0x13 - очистка буфера клавы (костыль)
#		Receives	<---	
#		Returns		--->	AL = 
#							AH = 
#-----------------------------------------------#
i30_handler:									#
		sti										# 
		push	%ebx							# 
#-------#		 Looking for a function...		#
		cmp		$0, %ah							# 
		je		i30_gc1							# AH = 0 -> getchar
		cmp		$0x13, %ah						#
		je		i30_gc13						#					
		jmp		i30_exit						# not a valid function
												#
#-----------------------------------------------# AH=0x13:	Flush buffer	
i30_gc13:										#	
		call	KB_SC_INIT						#
		jmp		i30_exit						#
#-----------------------------------------------# AH=0x0:	Waiting for a scan code  	 
i30_gc1:xor		%ah, %ah						#	
		call	KB_SC_DEQ						#
		cmp		$0xFF, %al						# AL <-- result
		je		i30_gc1							#
		mov		%al, %ah						# 
		
#-------#		 scancode -> ASCII				#
		cmpb	$SC_TABLE_FIRST, %al			# check if the scancode is supported 
		jl		i30_invalid
		cmpb	$SC_TABLE_LAST, %al
		jg		i30_invalid
i30_ascii:										# else convert to ASCII
		xor		%bx, %bx
		mov		%al, %bl						# bl <--- scancode
		add		$(SC_TABLE-SC_TABLE_FIRST), %bx	# scancode + # of symbol
		movb	%cs:(%bx), %al					# al <--- ascii
		jmp		i30_exit						#
#-------#		end of scancode -> ASCII	 	№
i30_invalid:
		jmp		i30_gc1							# в AL должен быть ASCII,
i30_exit:										# в AH сканкод
		pop		%ebx							#
		iretl									# 
												#	
#-----------------------------------------------#	


#-----------------------------------------------#
#        Int 0x31 (работа с видеопамятью)       #
#-----------------------------------------------#
#	AH = 0x2 - Set cursor position
#		Receives	<---	DH = row
#							DL = column
#		Returns		--->	Nothing
#-----------------------------------------------#
#	AH = 0x3 - Read cursor position
#		Receives	<---	Nothing
#		Returns		--->	DH = row
#							DL = column
#-----------------------------------------------#
#	AH = 0x6 - Scroll active page up
#		Receives	<---	
#		Returns		--->	AL = 
#							AH = 
#-----------------------------------------------#
#	AH = 0x7 - Scroll active page down
#		Receives	<---	Nothing
#		Returns		--->	Nothing
#-----------------------------------------------#
#	AH = 0x9 -  Write character and attribute at cursor
#		Receives	<---	AL = ASCII character to write
#							BL = character attribute
#		Returns		--->	Nothing
#-----------------------------------------------#
#	AH =  0xE - Write text in teletype mode
#		Receives	<---	AL = ASCII character to write
#							BL = character attribute
#		Returns		--->	Nothing 
#-----------------------------------------------#
#	AH =  0x13 - Write string 
#		Receives	<---	BL = attribute 
#							SI = pointer to string
#		Returns		--->	Nothing
#-----------------------------------------------#
#	AH =  0xAA - Madness
#		Receives	<---	Nothing
#		Returns		--->	Nothing
#-----------------------------------------------#

i31_handler:									
		cmp		$0x2, %ah
		je		i31_set_cursor
		cmp		$0x3, %ah
		je		i31_read_cursor
		cmp		$0x6, %ah
		je		i31_scroll_up
		cmp		$0x7, %ah
		je		i31_scroll_down
		cmp		$0x9, %ah
		je		i31_write_char
		cmp		$0xE, %ah
		je		i31_teletype
		cmp		$0x13, %ah
		je		i31_write_string
		cmp		$0xAA, %ah
		je		i31_madness
		
		jmp		i31_finish
		
i31_set_cursor:
		push	%ebx

		mov		$0x450, %ebx				# BIOS Data Area
		movb	%dl, (%ebx)					# 40:50 - Cursor position for page #0
		movb	%dh, 1(%ebx)
		call	VGA_SET_CURPOS

		pop		%ebx
		jmp		i31_finish

i31_read_cursor:
		push	%ebx
		mov		$0x450, %ebx
		movw	(%ebx), %dx
		pop		%ebx
		jmp		i31_finish
		
i31_scroll_up: 
i31_scroll_down: 
		push	%eax
		push	%ecx
		push	%edi
		push	%esi
		
		/* Копируем с 0xB8000 + 80*2
				   на 0xB8000
					80*24 байт
		*/
		
		mov		$(0xB8000+80*2), %esi    	# From
		mov		$(0xB8000), %edi         	# To
		mov		$(80*6*2), %ecx 	       	# Copy 80*6*2 dwords (80*24*2 bytes)
		cld										
		rep 	movsl		
		
		# empty the last string
		mov		$' ', %al					# Filling
		mov		$0x8, %ah					# Black color
		mov		$(0xB8000+80*24*2), %edi   	# From ax to the last string
		mov		$(80), %ecx 	        	# Copy 80*6 dwords (80*24 bytes)
		cld		
		rep 	stosw	
		
		pop		%esi
		pop		%edi
		pop		%ecx
		pop		%eax
		jmp		i31_finish
		
i31_write_char:
		push	%ebp
		push	%edx
	
		mov		$0x3, %ah			# Read cursor position
		int		$0x31	
		
		call	VGA_CALC_POS		# 
		shl		$1, %ebp			# 
		
		movb	%al, %gs:(%ebp)
		movb	%bl, %gs:1(%ebp)
	
		pop		%edx
		pop		%ebp
		jmp		i31_finish
		
#-----------------------------------------------#
i31_teletype:
		# Проверяем, что за символ.
		# ... Если это backspace
		cmp 	$'\b', %al
		je		i31_tt_backspace
		# ... Если это delete
		cmp 	$0x7F, %al
		je		i31_tt_backspace		
		# ... Если это \r (возврат каретки)
		cmp 	$'\r', %al
		je		i31_tt_CR
		# ... Если это \n (новая строка)
		cmp		$'\n', %al
		je		i31_tt_NL
		# ... Если это костыль для Enter, который мы кодируем как 0xBC
		cmp		$0xBC, %al
		je		i31_tt_kostyl
		# ... Если это Tab
		cmp		$'\t', %al
		je		i31_tt_Tab
		# ... Если это `
		cmp		$'`', %al
		je		i31_tt_lol
		# ...Иначе это простой символ
		mov		$0x9, %ah					# Рисуем символ
		int		$0x31 

		mov		$0x3, %ah
		int		$0x31						# читаем позицию курсора
	
		inc		%dl							# инкрементируем y
		cmp		$80, %dl
		jl		i31_tt_skip_newline
		xor		%dl, %dl
i31_tt_inc_x:
		inc		%dh							# инкрементируем x
		cmp		$25, %dh
		jl		i31_tt_skip_newline
		dec		%dh
		mov		$0x7, %ah
		int		$0x31						# sroll screen
					
i31_tt_skip_newline:	
		mov		$0x2, %ah					# устанавливаем новую позицию курсора
		int		$0x31
		
		jmp		i31_finish
		
i31_tt_backspace:
		mov		$0x3, %ah
		int		$0x31						# читаем позицию курсора
		dec		%dl							# декрементируем y
		cmp		$0xFF, %dl
		jne		i31_tt_bp_skip_backline
		mov		$79, %dl
		dec		%dh
		cmp		$0xFF, %dh
		jne		i31_tt_bp_skip_backline
		xor		%dh, %dh
		# scroll up?

i31_tt_bp_skip_backline:
		mov		$0x2, %ah					# устанавливаем новую позицию курсора
		int		$0x31
		
		mov		$' ', %al
		mov		$0x9, %ah					# Рисуем пустоту
		int		$0x31 
		
		jmp		i31_finish
	
i31_tt_CR:
		mov		$0x3, %ah
		int		$0x31						# читаем позицию курсора
		xor		%dl, %dl					# обнуляем y
		
		mov		$0x2, %ah					# устанавливаем новую позицию курсора
		int		$0x31
		
		jmp		i31_finish 
i31_tt_NL:
		mov		$0x3, %ah
		int		$0x31						# читаем позицию курсора
		jmp		i31_tt_inc_x
		
		jmp		i31_finish
i31_tt_kostyl:
		xchg	%bx, %bx
		mov		$'\r', %al
		mov		$0xE, %ah
		int		$0x31
		
		mov		$'\n', %al
		mov		$0xE, %ah
		int		$0x31
		jmp		i31_finish
i31_tt_Tab:
		mov		$0x3, %ah
		int		$0x31						# читаем позицию курсор
	
		add		$4, %dl						# инкрементируем y 4 раза
		
		mov		$0x2, %ah					# устанавливаем новую позицию курсора
		int		$0x31
		jmp		i31_finish
i31_tt_lol:
		mov		$0xAA, %ah					# Shift colors
		int		$0x31				
		jmp		i31_finish
#-----------------------------------------------#
i31_write_string:								#
		push	%eax
		cld
.i31_NextChar:									#
		lodsb									# Load char from string (ds:si)
		cmp		$0x00, %al 						# Check for null terminator
		jz		.i31_EndChar					#
		mov		$0x0E, %ah 						# Function: Write text in teletype mode
		int		$0x31							# 
		jmp		.i31_NextChar					#
.i31_EndChar:									#
		pop		%eax
		jmp	i31_finish		
		
#-----------------------------------------------#
i31_madness:
		push	%eax							#
		push	%ecx							#
		
		xor		%eax, %eax						# Текущий символ
		mov		$2000, %ecx						# Колическтво сиволов на экране

screen_loop:									#
		inc		%eax
		incb	%gs:(%eax)						# Меняем атрибут
		andb	$0b10001111, %gs:(%eax)			# Убираем фон
		inc		%eax
		loop	screen_loop

		pop		%ecx							#
		pop		%eax							#
		jmp		i31_finish		
i31_finish:

		iretl									# 
#-----------------------------------------------#

#################################################
