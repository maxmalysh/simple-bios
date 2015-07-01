;--------------[ Keyboard ports ]---------------;
		KBD_DATA_BUF 	equ		060h			; 8031 commands &
		KBD_OUT_BUF 	equ		060h			; 8042 data
		STATUS_PORT 	equ		064h			; 8042 status &
		KBD_CMD_BUF 	equ		064h			; 8042 commands
;-----------[ Keyboard status (8042) ]----------;
		OUT_BUF_FULL	equ		01h				;
		INPT_BUF_FULL 	equ		02h				;
;---------[ Keyboard responses (8031) ]---------;
		KB_TEST_OK 		equ		0AAh			;
		KB_ACK			equ		0FAh			;
;-----------------------------------------------;


;------[ Keyboard tests & initialization ]------;
init_keyboard proc near							;
		push	ax								;
		push	cx								;
		push	es								;
		call	KB_SC_INIT						;
												; setting up 09 & 16 vectors
		xor		ax, ax							;
		mov		es, ax							;
		cli	 									; 
		mov		es:[09h*4],	offset int09_handler; offset of int09_handler
		mov		es:[09h*4+2], cs				; segment of int09_handler 
		mov		es:[16h*4], offset int16_handler; the same 
		mov		es:[16h*4+2], cs				; 
		sti										;
	
;------------------[ wait... ]------------------;
		xor		cx, cx							;
w0: 	in		al, STATUS_PORT					;	Wait for input buffer being empty
		test	al, INPT_BUF_FULL				;
		loopnz	w0								;
;-----------------------------------------------;

;------------------[ Step #1 ]------------------;
		mov		al, 0AAh						;	Send self test command
		out		KBD_CMD_BUF, al					;
												;
		xor		cx, cx							;	Waiting...
w1: 	in		al, STATUS_PORT					;
		test	al, OUT_BUF_FULL				;
		loopnz	w1								;
												;	Complete.
		in		al, KBD_OUT_BUF					;	Check the result
		cmp		al, 055h						;	
		jne		KB_Fail							;
;-----------------------------------------------;

;------------------[ Step #2 ]------------------;
		mov		al, 0ABh						; test #2.
		out		KBD_CMD_BUF, al					;
												;
		xor		cx, cx							; Waiting...
w2:		in		al, STATUS_PORT					;
		test	al, OUT_BUF_FULL				;
		loopnz	w2								;
												; Complete.
		in		al, KBD_OUT_BUF					; Check the result
		cmp		al, 0							; Should be 0
		jne		KB_Fail							;
;-----------------------------------------------;

;------------------[ Step #3 ]------------------;
		mov		al, 0AEh						; Enable scanning (#3). 
		out		KBD_CMD_BUF, al					;
												;
		xor		cx, cx							; Waiting...
w3:		in		al, STATUS_PORT					;
		test	al, OUT_BUF_FULL				;
		loopnz	w3								;
;-----------------------------------------------; Complete.

;------------------[ Step #4 ]------------------;
		mov		al, 0A8h						; ? #4. 
		out		KBD_CMD_BUF, al					;
												;
		xor		cx, cx							; Waiting...
w4:		in		al, STATUS_PORT					;
		test	al, OUT_BUF_FULL				;
		loopnz	w4								;
;-----------------------------------------------; Complete.

;------------------[ Step #5 ]------------------;
		mov		al, 0FFh						; test #5. Reset.
		out		KBD_DATA_BUF, al				;
												;
		xor		cx, cx							; Waiting...
w5:		in		al, STATUS_PORT					; 
		test	al, OUT_BUF_FULL				;
		loopz	w5								;
												; Complete.
		in		al, KBD_OUT_BUF					; Check the answer
		cmp		al, KB_ACK						;
		jne		KB_Fail							;
												;
		xor		cx, cx							; Waiting...
w5_2:	in		al, STATUS_PORT					; 
		test	al, OUT_BUF_FULL				;
		loopz	w5_2							; Complete.
												;
		in		al, KBD_OUT_BUF					; Check the result
		cmp		al, KB_TEST_OK					;
		jne		KB_Fail							;					
;-----------------------------------------------;

;------------------[ Step #6 ]------------------;
		mov		al, 0F5h						; step #6. Disable keyboard
		out		KBD_DATA_BUF, al				;
												;
		xor		cx, cx							; Waiting...
w6:		in		al, STATUS_PORT					;	
		test	al, OUT_BUF_FULL				;
		loopz	w6								;
												; Complete.
		in		al, KBD_OUT_BUF					; Check the answer
		cmp		al, KB_ACK						;
		jne		KB_Fail							;
;-----------------------------------------------;

;------------------[ Step #7 ]------------------;
		mov		al, 060H 						; test # 7. Writing to the controller
		out		KBD_CMD_BUF, al					;	
												;
		xor		cx, cx							; Waiting....
w7:		in		al, STATUS_PORT 				;
		test	al, INPT_BUF_FULL 				;
		loopnz	w7								;
;-----------------------------------------------; Complete.

;------------------[ Step #8 ]------------------;
		mov		al, 061h						; ? #8
		out		KBD_DATA_BUF, al				;
												;
		xor		cx, cx							; Waiting...
w8:		in		al, STATUS_PORT					;	
		test	al, OUT_BUF_FULL				;
		loopz	w8								;
;-----------------------------------------------; Complete.
		
;------------------[ Step #9 ]------------------;
		mov		al, 0F4h						; Step #9 (final). Enable keyboard
		out		KBD_DATA_BUF, al				;
												;
		xor		cx, cx							; Waiting...
w9:		in		al, STATUS_PORT					;	
		test	al, OUT_BUF_FULL				;
		loopz	w9								;
												; Complete.
		in		al, KBD_OUT_BUF					; Check the answer.
		cmp		al, KB_ACK						;	
		je		K_done							;
;-----------------------------------------------;

;-----------------[ KBD fail ]------------------; Endless beeping 
KB_Fail:call beep								; 
		hlt										;
		jmp KB_Fail								;
;-----------------------------------------------;

;------------------[ Success ]------------------;
K_done: PIC_mask 11111100b, 11111111b			; Unmasking keyboard
		;call	beep							;
		pop		es								;
		pop		cx								;
		pop		ax								;	
		ret										;
init_keyboard endp								;
;-----------------------------------------------;	