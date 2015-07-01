;-----------------[ KB BUFFER ]-----------------;--------------------|------------------|
		KB_CAP	 		equ		16				; #define KB_CAP 8	 | 			  		|				
		KB_COUNT		equ		17h				; char KB_COUNT 	 | 40:17h	 		|				
		KB_HEAD			equ		1Ah				; char* HEAD		 | 40:1Ah	 		|	
		KB_TAIL			equ		1Ch				; char* TAIL		 | 40:1Ch	   		|
		KB_DATA			equ		1Eh				; char KB_DATA[8]	 | 40:1E-40:2Eh		|
;-----------------------------------------------;--------------------|------------------|


;---------[ KBD buffer initialization ]---------; void KB_SC_INIT()
KB_SC_INIT proc near							;
		push	dx								;
		push	ds								;
												;
		mov		dx, 40h							;
		mov		ds, dx							;
												;
		mov		byte ptr ds:[KB_COUNT], 0		;
		mov		byte ptr ds:[KB_HEAD], 0		;
		mov		byte ptr ds:[KB_TAIL], 0		;
												;
		pop		ds								;
		pop		dx								;
		ret										;
KB_SC_INIT endp									;
;-----------------------------------------------;


;-------------[ KBD buffer enqueue ]------------;
KB_SC_ENQ proc near 							; void KB_SC_ENQ (char AL)
		push	bx								;
		push	ds								;
												;
		mov		bx, 40h							;
		mov		ds, bx							;
		cmp		byte ptr ds:[KB_COUNT], KB_CAP	; if count = cap 
		je		short	KB_OVERFLOW				; then error
												;
		xor		bx, bx							;
		mov		bl,	ds:KB_TAIL					;
		mov		ds:[KB_DATA + bx], al			; data[tail] <- x
		inc		bx								; tail++
												;
		cmp		bl, KB_CAP						; if tail = cap 
		jne		short	enq_1					;
		xor		bx, bx
enq_1:	mov		byte ptr ds:[KB_TAIL], bl		; then tail <- 0
		inc		byte ptr ds:[KB_COUNT]			; count++
		jmp		short	enq_ok					;
												;
KB_OVERFLOW:									;
	;	call	beep							;										
enq_ok:											;
		pop		ds								;
		pop		bx								;
		ret										;
KB_SC_ENQ endp									;
;-----------------------------------------------;


;-------------[ KBD buffer dequeue ]------------; (AL) char KB_SC_DEQ()
KB_SC_DEQ proc near								;
		push	bx								;
		push	ds								;
												;
		mov		bx, 40h							;
		mov		ds, bx							;
		
		cmp		byte ptr ds:[KB_COUNT], 0		; if count == 0 
		je		short	KB_EMPTY				; then error (return 0xFF)
												;
		xor		bx, bx							;
		cli  ;<---------
		mov		bl, ds:[KB_HEAD]				;
		mov		al, ds:[KB_DATA + bx]			; x <- data[head]
												;
		inc		bx								; head++
		mov		byte ptr ds:[KB_HEAD], bl		;
												;
		cmp		bl, KB_CAP						; if head = cap 
		jne		deq_1							;
		mov		byte ptr ds:[KB_HEAD], 0		; then tail <- 0
deq_1:	dec		byte ptr ds:[KB_COUNT]			; count++
		sti	; <--------
		jmp		short	deq_ok					;
KB_EMPTY:										;
		mov		al, 0FFh						;
deq_ok:											;
		
		pop		ds								;
		pop		bx								;
		ret										;
KB_SC_DEQ endp									;
;-----------------------------------------------;


;----------------[ Pseudo code ]----------------;
;KB_SC_ENQ proc near ; scancode -> al. 
;		if count = cap then error
;		data[tail] <- x
;		tail++
;		if tail = cap then tail <- 0
;		count++
;		ret
;KB_SC_ENQ endp

;KB_SC_DEQ proc near ; al <- scancode
;		if count = 0 then error
;		x <- data[head]
;		head++
;		if head = cap then head <-0
;		count --
;		ret
;KB_SC_DEQ endp
;-----------------------------------------------;