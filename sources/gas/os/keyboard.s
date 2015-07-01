#################################################
#                   KEYBOARD                    #
#################################################

.include "sources/gas/os/keyboard_scancodes.s"

#-----------------[ KB BUFFER ]-----------------#--------------------#------------------#
		.equ	KB_CAP,	 		16				# #define KB_CAP 8	 | 			  		|				
		.equ	KB_COUNT,		0x17			# char KB_COUNT 	 | 40:17h	 		|				
		.equ	KB_HEAD,		0x1A			# char* HEAD		 | 40:1Ah	 		|	
		.equ	KB_TAIL,		0x1C			# char* TAIL		 | 40:1Ch	   		|
		.equ	KB_DATA,		0x1E			# char KB_DATA[8]	 | 40:1E-40:2Eh		|
#-----------------------------------------------#--------------------#------------------#

################################################# Receives <-- Nothing
#                KBD buffer init                # Returns ---> Nothing
################################################# Destroys nothing
KB_SC_INIT:										#
		push	%edx							#
												#
		mov		$0x400,	%edx					#
												#
		movb	$0, KB_COUNT(%edx)				#
		movb	$0, KB_HEAD(%edx)				#
		movb	$0, KB_TAIL(%edx)				#
												#
		pop		%edx							#
		ret										#
#-----------------------------------------------#

################################################# Receives <-- AL
#              KBD buffer enqueue               # Returns ---> Nothing
################################################# Destroys nothing
KB_SC_ENQ:			 							#
		push	%edx							#
		push	%ebx							#
		
		cli										#
		mov		$0x400, %edx					#
		cmpb	$KB_CAP, KB_COUNT(%edx)		 	# if count = cap 
		je		KB_OVERFLOW						# then error
												#
		xor		%ebx, %ebx						#
		mov		KB_TAIL(%edx), %bl				#
		mov		%al, KB_DATA(%edx, %ebx) 		# data[tail] <- x
		inc		%bx								# tail++
												#
		cmpb	$KB_CAP, %bl					# if tail = cap 
		jne		enq_1							#
		xor		%bx, %bx
enq_1:	movb	%bl, KB_TAIL(%edx)		 		# then tail <- 0
		incb	KB_COUNT(%edx)					# count++
		jmp		enq_ok							#
												#
KB_OVERFLOW:									#
	#	call	beep							#										
enq_ok:											#
		sti										#
		
		pop		%edx							#
		pop		%ebx							#
		ret										#
#-----------------------------------------------#


################################################# Receives <-- Nothing
#              KBD buffer dequeue               # Returns ---> Al
################################################# Destroys nothing
KB_SC_DEQ:										#
		push	%ebx							#
		push	%edx							#
												#
		mov		$0x400, %edx 					#
		cli  									# <--------- No interrupts, memory access!
		cmpb	$0, KB_COUNT(%edx)				# if count == 0 
		je		KB_EMPTY						# then error (return 0xFF)
												#
		xor		%ebx, %ebx						#
		mov		KB_HEAD(%edx), %bl 				#
		mov		KB_DATA(%edx, %ebx), %al 		# x <- data[head]
												#
		inc		%bx								# head++
		movb	%bl, KB_HEAD(%edx)				#
												#
		cmp		$KB_CAP, %bl 					# if head = cap 
		jne		deq_1							#
		movb	$0, KB_HEAD(%edx)				# then tail <- 0
deq_1:	decb	KB_COUNT(%edx)					# count++
		
		jmp		deq_ok							#
KB_EMPTY:										#
		mov		$0xFF, %al						#
deq_ok:											#
		sti										# <-------- We can access memory now.
		pop		%edx							#
		pop		%ebx							#
		ret										#
#-----------------------------------------------#
