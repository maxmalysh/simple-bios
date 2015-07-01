#################################################
#     Переход в 32-битный защищённый режим      #
#################################################
init_pmode:										# 
		call	disable_interrupts				# Запрещаем прерывания
		call	reroute_interrupts				# Перенастраиваем PIC
		call	open_A20						# Открываем A20
		call	initialize_gdt					# Инициализируем GDT
		call	initialize_idt					# Инициализируем IDT
		call	set_PE							# Устанавливаем флаг PE

		ljmp	$(CS_dsc - GDT), $LoadCS		# Загружаем селектор кода
LoadCS: 
.code32 
		mov 	$(DS_dsc - GDT), %ax			# Загружаем селектор данных
		mov 	%ax, %ds						#
		mov		%ax, %es						#
		mov		%ax, %fs						#
		
		mov 	$(GS_dsc - GDT), %ax			# Загружаем селектор видеопамяти			
		mov 	%ax, %gs						#
		
		xor		%ebx, %ebx						# Так как call поместил в стек 16-битный адрес возврата,
		pop		%bx								# нам нужно преобразовать его в 32-битный

		mov 	$(SS_dsc - GDT), %ax			# Загружаем селектор стека
		mov 	%ax, %ss						# В стеке ничего полезного нет, поэтому ради одного
		mov		$0x1000, %esp					# ret не будем устанавливать esp в старое место
		
		call	enable_interrupts				# меняет только %eax
		
		jmp		*%ebx							# в ebx - 32-битный адрес возврата
#################################################


#################################################
#           Вспомогательные процедуры           #
#################################################	
.code16											#
open_A20:										# Открываем линию A20
		in		$0x92, %al						#
		or		$2,	%al							#
		out		%al, $0x92						#
		ret										#
		
initialize_gdt:									# Вычисляем линейный адрес 
		call	cs_to_eax						#	начала массива дескрипторов
		add		$GDT, %eax						#	
		movl	%eax, gdtr+2					# GDTR Linear Base Address
		lgdt	gdtr							# Загружаем GDTR
		ret										#
		
initialize_idt:									# Вычисляем линейный адрес 
		call	cs_to_eax						#	начала массива дескрипторов
		add		$IDT, %eax						# IDTR Linear Base Address
		movl	%eax,  idtr+2 					# Загружаем IDTR
		lidt	idtr							# 
		ret										#

set_PE:											# Перейти в защищенный режим.
		mov		%cr0, %eax						#
		or		$1, %al							#
		mov		%eax, %cr0						#
		ret										#
		
cs_to_eax:										# Преобразует линейный адрес
		xor		%eax, %eax 						# CS : 0x0000 в 32-битный
		mov		%cs, %ax 						#
		shl		$4, %eax						#
		ret										#
	
disable_interrupts:								#
		cli										# запретить прерывания
		in		$0x70, %al						# индексный порт CMOS
		or		$0b10000000, %al				# 	установка бита 7 в нем 
		out		%al, $0x70						#	запрещает NMI
		ret										#
	
enable_interrupts:								#
        in		$0x70, %al  					# индексный порт CMOS
        and		$0b01111111, %al				# сброс бита 7 отменяет 
        out		%al, $0x70						#	блокирование NMI
        sti             						# разрешить прерывания
        ret										#
		
reroute_interrupts:
        push    %eax

        mov		$0b00010001, %al				# ICW1
        out		%al, $0x020						#
        out		%al, $0x0A0 					#
												
        mov		$0x20, %al						# ICW2 -> master
        out		%al, $0x021 					#     IRQ0 -> int 0x20
												
        mov		$0x28, %al						# ICW2 -> slave
        out		%al, $0x0A1 					#     IRQ8 -> int 0x28
												
        mov		$0b00000100, %al				# ICW3 -> master
        out		%al, $0x021 					#
												
        mov		$2, %al							# ICW3 -> slave
        out		%al, $0x0A1 					#
												
        mov		$0b00000001, %al 				# ICW4
        out		%al, $0x021						#
        out		%al, $0x0A1 					#
												
		mov		$0b11111100, %al				# Masking everything 	except	
		outb	%al, $0x21						#     IRQ0 (timer) and
												#     IRQ1 (keyboard)
		mov		$0b11111111, %al				# We don't use slave PIC at all,
		outb	%al, $0xA1						#     so we mask IRQ2 too
												#
        pop		%eax							#
		ret										#
		
CS_to_dsc:										# Прописываем адрес начала cs 
		call	cs_to_eax						# в качестве базового адреса сегмента
		movw	%ax, CS_dsc+2					# cs_dsc.base_low
		shr		$16, %eax						#
		movb	%al, CS_dsc+4					# cs_dsc.base_high0
		ret										#
#################################################
