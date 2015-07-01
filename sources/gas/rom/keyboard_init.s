#----------------[ Keyboard ports ]-----------------#
		.equ		KB_DATA_BUF,	0x60			# 8031 commands &
		.equ		KB_OUT_BUF,	 	0x60			# 8042 data
		.equ		STATUS_PORT, 	0x64			# 8042 status &
		.equ		KB_CMD_BUF,		0x64			# 8042 commands
#-------------[ Keyboard status (8042) ]------------#
		.equ		OUT_BUF_FULL,	0x1				#
		.equ		INP_BUF_FULL, 	0x2				#
#-----------[ Keyboard responses (8031) ]-----------#
		.equ		KB_TEST_OK, 	0xAA			#
		.equ		KB_ACK,			0xFA			#
#---------------------------------------------------#

#-------------------[ Таблица команд и ответов ]--------------------#
KB_TBL:		 # [ CMD ]  [  Порт  ]  [ # отв]  [ Ответ(ы) ]          #
		.byte	0xAA,	KB_CMD_BUF,		1,		0x55				#	#1
		.byte	0xAB,	KB_CMD_BUF,		1,		0x00				#	#2
		.byte	0xAE,	KB_CMD_BUF,		0							#	#3
		.byte	0xA8,	KB_CMD_BUF,		0							#	#4
		.byte	0xFF,	KB_DATA_BUF,	2,		KB_ACK, KB_TEST_OK	#	#5
		.byte	0xF5,	KB_DATA_BUF,	1,		KB_ACK				#	#6
		.byte	0x60,	KB_CMD_BUF,		0							#	#7
		.byte	0x61,	KB_DATA_BUF,	0							#	#8
		.byte	0xF4,	KB_DATA_BUF,	1,		KB_ACK				#	#9
		.byte	0x0													#   End of table
#-------------------------------------------------------------------#
	
	
#--------[ Keyboard tests & initialization ]--------# 
init_keyboard:										# 
		pusha										#
		push	%es									#
													
		call	KB_SC_INIT							# Инициализация кольцевого буфера
													
#...................................................# <<< setting up 09 & 16 vectors
		xor		%ax, %ax							#
		mov		%ax, %es							#
		cli	 										#
		movw	$int09_handler, %es:0x9*4			#
		movw	%cs, %es:0x9*4+2					# 
		movw	$int16_handler, %es:0x16*4			# 
		movw	%cs, %es:0x16*4+2					# 
		sti											#
#...................................................#

		xor		%ax, %ax							# AL - Команды, AH - # ответов
		xor		%bx, %bx							# BX - текущий элемент таблицы
		xor		%dx, %dx							# DL - ответы 
													
#...................................................# <<< Ожидание пустого буфера
w_loop:												#
		mov 	$0xFFF0, %cx						# # попыток
w0:		in 		$STATUS_PORT, %al					#
		test 	$INP_BUF_FULL, %al 					#
		jz 		w1 									# OK
		loop 	w0									#
		jmp 	KB_Fail 							# Тайм-аут
#...................................................#

#...................................................# <<< Отправка кода команды
w1: 	mov 	%cs:KB_TBL(%bx), %al				# AL <- Command
		inc		%bx									#
		mov		%cs:KB_TBL(%bx), %dl				# DX <- Port 
		out 	%al, %dx							#
		inc		%bx									#
#...................................................#

#...................................................# <<< Решаем, нужно ли ждать ответ(ы)
		mov		%cs:KB_TBL(%bx), %ah				# AH <- Кол-во ответов
		inc		%bx									#
													#
		cmp		$0x0, %ah							# if response_num == 0
		je		w_next								# 	goto next command (не ждем)
#...................................................# 
									
#...................................................# else 
		mov 	$0x2000, %cx 						# 	ждём ответ...
w2: 	in		$STATUS_PORT, %al					#
		test 	$OUT_BUF_FULL, %al 					#
		jz 		w3 									# 
#...................................................# 

#...................................................# <<< Анализ кода ответа
		in 		$KB_OUT_BUF, %al					# AL <- полученный ответ
		mov		%cs:KB_TBL(%bx), %dl				# DL <- правильный ответ
		inc		%bx									# 
		cmp		%dl, %al							# Если получен неверный ответ
		jne		KB_Fail								# ...
													#
		dec		%ah									# Уменьшаем количество оставшихся ответов
		jz		w_next								# Если осталось получить 0 ответов goto w_next 
		mov 	$0x2000, %cx						# Иначе
w3: 	loop 	w2									# 	Ждём следующий ответ
		jmp 	KB_Fail 							# Тайм-аут
#...................................................#

#...................................................# <<< Проверяем, есть ли еще команды
w_next:	cmpb	$0x0, %cs:KB_TBL(%bx)				# 
		jne		w_loop								#
		jmp		K_done								#
#---------------------------------------------------#

#--------------------[ KBD fail ]-------------------# 
KB_Fail:
		PutString "Keyboard reported an error during its initialization!\r\n" , color_fail
KB_Fail_loop:
		hlt											#
		jmp		KB_Fail_loop						#
#---------------------------------------------------#

#--------------------[ Success ]--------------------#
K_done: PIC_mask $0b11111100, $0b11111111			# Unmasking keyboard
		#call	beep								#
		PutString "Keyboard have been successfully initialized.\r\n", color_good
		pop		%es									#
		popa										#
		ret
#---------------------------------------------------#	

		
