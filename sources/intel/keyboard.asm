;================================================
;=================== KEYBOARD  ==================

include keyboard_buffer.asm						
include keyboard_init.asm

;----------------[ Video Memory ]---------------;
		VM_BASE 		equ		0B800h			; Video Memory base segment.
		VM_POS			equ		3Eh				; 40:3Eh, позиция "курсора"
		VM_SIZE			equ		80*25*2			; Размер задействованной видеопамяти
;-----------------------------------------------; (макс. количество символов на экране, размер экрана * 2, т.к. 1 символ = 2 байта)

;------------------[ KB PRINT ]-----------------; receives 1 argument
KB_PRINT proc near								; al <--- scancode
		push	es								;
		push	ds								;
		push	bx								;
												;
		mov		bx, VM_BASE						; 
		mov		ds, bx							;
		mov		bx,	40h							; BIOS data segment
		mov		es, bx							;
												;
		mov		bx, es:[VM_POS]					;
		cmp		bx, VM_SIZE 					; 
		jl		kb_pr1							; if VM_POS > VM_SIZE
		xor		bx, bx							; then VM_POS := 0
kb_pr1:	mov		word ptr es:[VM_POS], bx			;
		mov		byte ptr ds:[bx], al			;
		add		word ptr es:[VM_POS], 2			; 
												;
		pop		bx								;
		pop		ds								;
		pop		es								;
		ret										;
KB_PRINT endp									;
;-----------------------------------------------;

;---------------[ KB_get_char  ]----------------;
KB_get_char proc near							;
		push	ax								;
kb_gc_1:										;
		cli										;
		call	KB_SC_DEQ						; 	Вытаскиваем код из буфера (code -> AL)				;
		sti										;
		;mov		al, 50						;
		cmp		al,	0FFh						;	if code == 0xFF	
		je		kb_gc_1							;		then try again (buffer is empty)
		call	KB_PRINT						;   else print symbol (sym <- AL)
												;
		pop		ax								;
		ret										;
KB_get_char endp								;
;-----------------------------------------------;