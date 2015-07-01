.arch core2
.code16		
.section .eBTLDR 
								
.global	_BTLDR
.global	_BTLDR_size 

################################################# Конечно, это вовсе не ОС и не ядро даже,
#            Our small kernel, ha-ha            # 	а лишь что-то вроде загрузчика ОС 
#################################################	(наподобие NTLDR или GRUB). Наверное...
_BTLDR:											#
		cli                 					# Set Stack Pointer to _MBR_STKPTR
		lss		%cs:_BTLDR_STKPTR, %sp		
		sti      
		
		call	PrintOsLogo						# stuff.s; Выводим лого
		call	WaitKey							# stuff.s; Ждём нажатия клавиши 

		call	init_pmode						# protected.s
.code32	call	test_pmode						# pmode_test.s; Тут процессор работает уже в 32-битном режиме
		call	init_pages						# pages.s
		call	stop							# stop.s
		
		
		.include "sources/gas/os/macros.s"		# Все макросы тут
.code32	.include "sources/gas/os/idt.s"			# IDT и обработчики
		.include "sources/gas/os/gdt.s"			# GDT
.code16	.include "sources/gas/os/pmode_init.s"	# Перевод процессора в PM
.code32	.include "sources/gas/os/pmode_test.s"	# Демонстрация работы в PM
		.include "sources/gas/os/pages.s"		# Страницы
		.include "sources/gas/os/keyboard.s"	# Буфер клавиатуры и таблица певеода SC -> ASCII
		.include "sources/gas/os/vga.s"			# Работа с видео 
		.include "sources/gas/os/stop.s"		# hang 
.code16	.include "sources/gas/os/stuff.s"		# PrintOsLogo & WaitKey
		
_BTLDR_STKPTR:									# MBR stack pointer
		.word	0x7C00, 0x0000					#
												#
_BTLDR_size = . - _BTLDR						#
#################################################
