#-----------------[ KB BUFFER ]-----------------#--------------------#------------------#
		.equ	KB_CAP,	 		16				# #define KB_CAP 8	 | 			  		|				
		.equ	KB_COUNT,		0x17			# char KB_COUNT 	 | 40:17h	 		|				
		.equ	KB_HEAD,		0x1A			# char* HEAD		 | 40:1Ah	 		|	
		.equ	KB_TAIL,		0x1C			# char* TAIL		 | 40:1Ch	   		|
		.equ	KB_DATA,		0x1E			# char KB_DATA[8]	 | 40:1E-40:2Eh		|
#-----------------------------------------------#--------------------#------------------#


#---------[ KBD buffer initialization ]---------# void KB_SC_INIT()
KB_SC_INIT:										#
		push	%dx								#
		push	%ds								#
												#
		mov		$0x40,	%dx						#
		mov		%dx,	%ds						#
												#
		movb	$0, %ds:KB_COUNT				#
		movb	$0, %ds:KB_HEAD					#
		movb	$0, %ds:KB_TAIL					#
												#
		pop		%ds								#
		pop		%dx								#
		ret										#
#-----------------------------------------------#


#-------------[ KBD buffer enqueue ]------------#
KB_SC_ENQ:			 							# void KB_SC_ENQ (char AL)
		cli
		push	%bx								#
		push	%ds								#
												#
		mov		$0x40, %bx						#
		mov		%bx, %ds						#
		cmpb	$KB_CAP, %ds:KB_COUNT		 	# if count = cap 
		je		KB_OVERFLOW						# then error
												#
		xor		%bx, %bx						#
		mov		%ds:KB_TAIL, %bl				#
		mov		%al, %ds:KB_DATA(%bx) 			# data[tail] <- x
		inc		%bx								# tail++
												#
		cmpb	$KB_CAP, %bl					# if tail = cap 
		jne		enq_1							#
		xor		%bx, %bx
enq_1:	movb	%bl, %ds:KB_TAIL		 		# then tail <- 0
		incb	%ds:KB_COUNT					# count++
		jmp		enq_ok							#
												#
KB_OVERFLOW:									#
	#	call	beep							#										
enq_ok:											#
		sti
		pop		%ds								#
		pop		%bx								#
		ret										#
#-----------------------------------------------#


#-------------[ KBD buffer dequeue ]------------# (AL) char KB_SC_DEQ()
KB_SC_DEQ:										#
		push	%bx								#
		push	%ds								#
												#
		mov		$0x40, %bx 						#
		mov		%bx, %ds						#
		
		cli  									# <--------- No interrupts, memory access!
		cmpb	$0, %ds:KB_COUNT				# if count == 0 
		je		KB_EMPTY						# then error (return 0xFF)
												#
		xor		%bx, %bx						#
		
		mov		%ds:KB_HEAD, %bl 				#
		mov		%ds:KB_DATA(%bx), %al 			# x <- data[head]
												#
		inc		%bx								# head++
		movb	%bl, %ds:KB_HEAD				#
												#
		cmp		$KB_CAP, %bl 					# if head = cap 
		jne		deq_1							#
		movb	$0, %ds:KB_HEAD					# then tail <- 0
deq_1:	decb	%ds:KB_COUNT					# count++
		
		jmp		deq_ok							#
KB_EMPTY:										#
		mov		$0xFF, %al						#
deq_ok:											#
		sti										# <-------- We can access memory now.
		pop		%ds								#
		pop		%bx								#
		ret										#
#-----------------------------------------------#

#----------------[ Pseudo code ]----------------#
#KB_SC_ENQ proc near # scancode -> al. 
#		if count = cap then error
#		data[tail] <- x
#		tail++
#		if tail = cap then tail <- 0
#		count++
#		ret
#KB_SC_ENQ endp

#KB_SC_DEQ proc near # al <- scancode
#		if count = 0 then error
#		x <- data[head]
#		head++
#		if head = cap then head <-0
#		count --
#		ret
#KB_SC_DEQ endp
#-----------------------------------------------#
