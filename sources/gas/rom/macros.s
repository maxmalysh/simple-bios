#########################################
#			Some PIC routines  			#
#########################################

#------------[ Macking PIC ]------------#
.macro	PIC_mask	mask_1,	mask_2		#
		mov		\mask_1, %al			#			
		outb	%al, $0x21				#	
										#
		mov		\mask_2, %al			#
		outb	%al, $0xA1				#
.endm 									#
#---------------------------------------#

#---------[ End of Interrupt ]----------#
.macro	EndOfInterrupt					#
		movb	$0x20, %al 				# 
		outb	%al, $0x20 				#
.endm 									#
#---------------------------------------#


#########################################
#			Screen  output				#
#########################################

#---------[ Color attributes ]----------#
.equ	color_fail,		0x004F			# F - белый фон, 4 - красный шрифт 
.equ	color_good,		0x002F			#
.equ	color_default,	0x0008
/*.equ	color_
.equ	color_*/
#---------------------------------------#
										
#---------------------------------------#
.macro	PutString	string = "\r\n",  color = 0x0007	#		
		pusha							# God knows what was making it crash
		push	%es						# 
										#
		jmp		3f						#
1:										#
	.ascii	"\string" 					#
	sizeof_string = (. - 1b)			#
										#
3:										#
		mov 	$0x300, %ax				# get cursor position
		xor 	%bx, %bx				#
		int 	$0x10					#
		
		mov		$0x1301, %ax			# 13-ая функция, 
		mov		$\color,  %bx			#
		mov		$sizeof_string, %cx		# длина строки
		push	%cs						#
		pop		%es						# 
		mov		$1b, %bp				# es:bp <- указатель на строку
		int 	$0x10					#
										#
		pop		%es						#
		popa							#
.endm 									#
#---------------------------------------#

#---------------------------------------#
.macro	NewLine	  						#	
		PutString	"                                                                                ",color_default
.endm 									#
#########################################

/*
;-------------[ End of Interrupt ]--------------;
EndOfInterrupt 	macro							;
												;
				mov		al, 20h					# EOI
				out		20h, al					;
												;
				endm							;
;-----------------------------------------------;

;-------------[ Маскирование PIC ]--------------; 
PIC_mask		macro	mask_1,	mask_2			;
												;
				mov		al, mask_1				;			
				out		21h, al					;		
												;
				mov		al, mask_2				;
				out		0A1h, al				;
												;
				endm							;
;-----------------------------------------------;

;---------[ Отправить команду в порт ]----------;
SendToPort		macro	SND_PORT, SND_PORT_CMD	; 									
				mov		al, SND_PORT_CMD		;	
				out		SND_PORT, al			;
												;
				endm							;
;-----------------------------------------------;	
		
;----------[ Ожидание пустого буфера ]----------;
KB_Wait_Emp		macro	KB_PORT_CMD, KB_PORT	;
				local	waiting					;
												;
				xor		cx, cx					;
	waiting: 	in		al, KB_PORT				;	
				test	al, KB_PORT_CMD			;
				loopnz	waiting					;
				endm							;
;-----------------------------------------------;

;----------[ Ожидание полного буфера ]----------;
KB_Wait_Ful		macro	KB_PORT_CMD, KB_PORT	;
				local	waiting					;
												;
				xor		cx, cx					; Waiting...
waiting:		in		al, KB_PORT				; 
				test	al, KB_PORT_CMD			;
				loopz	waiting					;
				endm							;
;-----------------------------------------------;

;----------[ Ожидание полного буфера ]----------;
KB_Chk_Answ		macro	KB_OUT_ANS, KB_ANS_RIGHT;
				in		al, KB_OUT_ANS			;	Check the result
				cmp		al, KB_ANS_RIGHT		;
				jne		KB_Fail					;	
				endm							;
;-----------------------------------------------;
*/
