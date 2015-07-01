# http://wiki.osdev.org/Setting_Up_Paging
# http://wiki.osdev.org/Paging

#################################################
#        ...............................        #
#################################################
		
		.equ 	PAGE_DIR, 0x200000				# Директория будет располагаться на 2-ом мбайте
		.equ	PAGE_CAT, (PAGE_DIR + 4096)		# Каталог первых 4 мбайт следом за ней
		.equ	PAGE_VGA, (PAGE_CAT + 4096)		# На 4-8 мбайты отобразим память VGA
		
		.equ	PAGE_VGA_NUM, 8					# Для отображения памяти VGA(32 кбайта) хватит 8 страниц по 4 кибайта.
		
Paging_msg1:
		.asciz "--> Press enter in order to set up paging. We will map the first 4 megabytes 1:1 and the first 32kb of the 4th mb to the video memory. \r\n\r\n"
Paging_msg2:
		.asciz "Paging is enabled now.\r\nLoot at the \"A\" and \"B\" on the top; the first was printed via the physical address 0xB8002 and the second via the virtual address 0x400004. \r\n"

#################################################
#      Инициализация страничной адресации       #
#################################################	
init_pages:										#
######  Всякая фигня: печатаем сообщение и ждём нажатия на клавишу
		# Put string
		mov		$0x13, %ah
		mov		$0x7, %bl
		mov		$Paging_msg1, %si
		int		$0x31
		# Wait for a keypress
		call	WaitKeyPM
		
######	Создаём директорию (пустую)
		xor		%ecx, %ecx
		mov		$PAGE_DIR, %ebx					# 2-ой мегабайт

.FillPageDir:	
		movl	$2, (%ebx, %ecx, 4)				# supervisor level, read/write, not present.
		
		inc		%ecx
		cmp		$1024, %ecx
		jne		.FillPageDir
			
######	Создаём каталог для первых 4 мегабайт
		mov		$PAGE_CAT, %ebx					# 
		xor		%ecx, %ecx						# счетчик
		xor		%eax, %eax						# адреса
1:	
		mov		%eax, %edx
		or		$3,	  %edx						# attributes: supervisor level, read/write, present.
		movl	%edx, (%ebx, %ecx,4)			# 
		add		$4096, %eax
		inc		%ecx
		cmp		$1024, %ecx
		jne		1b
		
######	Создаём каталог для видеопамяти - 32 768 кбайта, 8 страниц (32кб/4кб=8)
		mov		$PAGE_VGA, %ebx					# 
		mov		$0xB8000, %eax					# адреса
		xor		%ecx, %ecx						# счетчик
1:	
		mov		%eax, %edx
		or		$3,	  %edx						# attributes: supervisor level, read/write, present.
		movl	%edx, (%ebx, %ecx,4)			# 
		add		$4096, %eax
		inc		%ecx
		cmp		$PAGE_VGA_NUM, %ecx
		jne		1b
		
######	Кладем созданные каталоги в директорию
		movl	$PAGE_CAT, %ds:PAGE_DIR
		orl		$3, %ds:PAGE_DIR
		
		movl	$PAGE_VGA, %ds:(PAGE_DIR+4)
		orl		$3, %ds:(PAGE_DIR+4)
		
######	Загружаем адрес директории в CR3
		mov 	$PAGE_DIR, %eax
		mov 	%eax, %cr3

######	Включаем страницы (ставим соотв. бит в CR0)
		mov		%cr0, %eax
		or		$0x80000000, %eax 
		mov		%eax, %cr0

######	Проверяем:
		# Мы отобразили видеопамять (0xB8000) на начало 4-ого мегабайта
		# Это 0x400000
		# Но если говорить по-английски, получается, 
		# we have mapped the first 32kb of the 4th mbyte to the video memory 
		# (мысли вслух)
		movb	$'A', %ds:0xB8000				# Ascii
		movb	$0x8E, %ds:0xB8001				# Color
		movb	$'B', %ds:0x400004				# Ascii
		movb	$0x8E, %ds:0x400005				# Color

####### Печатем инфу о том, что всё хорошо
		mov		$0x13, %ah						# Put string
		mov		$0x2, %bl						#
		mov		$Paging_msg2, %si				#
		int		$0x31							#
												#
		ret										#
#################################################

	
#################################################
#            Вспомогательные функци             #
#################################################	
WaitKeyPM:										# В защищенном режиме мы переназачаем прерывания,
		mov		$0x13, %ah						# 	поэтому пришлосьс делать этот костыль
		int		$0x30							# Int 30, 13 function: flush KB buffer
.WaitAgainPM:									#
		xor		%ah, %ah						# No need to save registers here. 
		int		$0x30							# Int 30, 0 function: getchar
		cmp		$0x1C, %ah						# <---- Scancode is     AH now; $0x1C = enter
		jne		.PrintCharPM					# <---- ASCII symbol is AL now
		ret										#
.PrintCharPM:									#
		mov		$0x0E, %ah 						# int 31, 0xE function: 
		mov		$0x7, %bl						# print char (teletype)
		int		$0x31							#
		jmp		.WaitAgainPM					#
		ret										#
