
;-----------[ int_08: System timer ]------------;
int08_handler proc near							;
		push	ax								;
		push	es								;
												;
		mov		ax, 40h							;
		mov		es, ax							;
		inc		dword ptr es:[TCOUNT]			;
		
		EndOfInterrupt()						;
		pop		es								;
		pop		ax								;
		iret									;
int08_handler endp								;
;-----------------------------------------------;

TCOUNT	equ		6Ch; 							; 40:6C - 40:6E (2 bytes)
NOTE	equ		7Ch;					 		; 40:7C - 40:7F (4 bytes) 

;--------------[ obsolete int_08 ]--------------; 
old_int08_handler proc near						;
		pushf									;
		push	eax								;
		push	ecx								;
		push	dx								;
		push	es								;
												;
		mov		ax, 40h							;
		mov		es, ax							;
												;
		xor		ecx, ecx						;
		mov		cx, word ptr es:[NOTE]			; get note
		cmp		cx, word ptr cs:[NOTES]			;
		jnz		oldnote							;
		xor		cx, cx							;
		mov		es:[NOTE], cx					;
oldnote:										;
		mov		eax, dword ptr es:[TCOUNT]		; get timer-tick count 
		shl		al,	4							; if eax mod 2^{8-4} != 0
		jnz		skip							; then skip (don't change the current note)
												;
		mov		dx, [ecx*2+NOTES+2]				; }
		call	sound_off						; } Loading a new note to the PIT
		call	sound_on						; }
												;
		inc		word ptr es:[NOTE]				; 
skip:											;
		inc		dword ptr es:[TCOUNT]			; increment timer counter
												;
		EndOfInterrupt()						;
												;
		pop		es								;
		pop		dx								;
		pop		ecx								;
		pop		eax								;
		popf									;
		iret									;
old_int08_handler endp							;
;-----------------------------------------------;


;----------------[ freq. table ]----------------; for the obsolete int_08 handler
NOTES	dw		16								; 
		dw		0FDFh,	0BE4h,	0A98h,	0A00h	; D  G  A  A#
		dw		0FDFh,	0EFBh,	0A00h,	0000h	; D  D# A# A#
		dw		11D1h,	0D59h,	0BE4h,	0A98h	; C  F  G  A
		dw		11D1h,	0FDFh,	0FDFh,	0000h	; C  D  D  -
;-----------------------------------------------;


;-------------[ int_09: Keyboard  ]-------------;
int09_handler proc near							;
		push	ax								;
												;
		mov		al, 0ADh						; Запрет сканирования
		out		64h, al							;
												;
		in		al, 60h							; Считывание скан-кода
												;
		call	KB_SC_ENQ						; Кладём его в буфер
												;
		EndOfInterrupt()						;
												;
		mov		al, 0AEh						; Разрешить сканирование
		out		64h, al							;
												;
		pop		ax								;
		iret									;
int09_handler endp								;
;-----------------------------------------------;


;-------------[ int_16: Keyboard  ]-------------;	Выводит все сканкоды, содержащиеся в буфере, 
int16_handler proc near							;	на экран (до тех пор, пока буфер не будет пуст)
		sti
		push	ax	
i_16_1:	;cli 									;	while (1) {	
		call	KB_SC_DEQ						;		chr = getchar();   (code -> AL)			
		;sti 									; 
		cmp		al,	0FFh						; 		if chr == 0xFF
		je		i_16_1							;			goto i_16_done
												; 		else
		call	KB_PRINT						;			print_char()
	;	jmp		i_16_1							;	}
i_16_done:
		pop		ax								;
		iret										;
int16_handler endp								;
;-----------------------------------------------;
