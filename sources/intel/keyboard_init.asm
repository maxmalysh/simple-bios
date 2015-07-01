;----------------[ Keyboard ports ]-----------------;
		KB_DATA_BUF 		equ		060h			; 8031 commands &
		KB_OUT_BUF	 		equ		060h			; 8042 data
		STATUS_PORT 		equ		064h			; 8042 status &
		KB_CMD_BUF 			equ		064h			; 8042 commands
;-------------[ Keyboard status (8042) ]------------;
		OUT_BUF_FULL		equ		01h				;
		INP_BUF_FULL 		equ		02h				;
;-----------[ Keyboard responses (8031) ]-----------;
		KB_TEST_OK 			equ		0AAh			;
		KB_ACK				equ		0FAh			;
;---------------------------------------------------;

;-------------------[ Таблица команд и ответов ]--------------------;
;			   [ CMD ]  [  Порт  ]  [ # отв]  [ Ответ(ы) ]          ;
KB_TBL	db		0AAh,	KB_CMD_BUF,		1,		055h,				;	#1
				0ABh,	KB_CMD_BUF,		1,		000h,				;	#2
				0AEh,	KB_CMD_BUF,		0,							;	#3
				0A8h,	KB_CMD_BUF,		0,							;	#4
				0FFh,	KB_DATA_BUF,	2,		KB_ACK, KB_TEST_OK,	;	#5
				0F5h,	KB_DATA_BUF,	1,		KB_ACK,				;	#6
				060h,	KB_CMD_BUF,		0,							;	#7
				061h,	KB_DATA_BUF,	0,							;	#8
				0F4h,	KB_DATA_BUF,	1,		KB_ACK				;	#9
		db		0h													;   End of table
;-------------------------------------------------------------------;
	
;--------[ Keyboard tests & initialization ]--------; 
init_keyboard proc near								; 
		push	ax									;
		push	bx									;
		push	cx									;
		push	dx									;
		push	es									;
													
		call	KB_SC_INIT							; Инициализация кольцевого буфера
													
;...................................................; <<< setting up 09 & 16 vectors
		xor		ax, ax								;
		mov		es, ax								;
		cli	 										;
		mov		es:[09h*4],		offset int09_handler;
		mov		es:[09h*4+2], 	cs					; 
		mov		es:[16h*4], 	offset int16_handler; 
		mov		es:[16h*4+2], 	cs					; 
		sti											;
;...................................................;

		xor		ax,	ax								; AL - Команды, AH - # ответов
		xor		bx,	bx								; BX - текущий элемент таблицы
		xor		dx, dx								; DL - ответы 

;...................................................; <<< Ожидание пустого буфера
w_loop:												;
		mov 	cx, 0FFF0h 							; # попыток
w0:		in 		al, STATUS_PORT						;
		test 	al, INP_BUF_FULL					;
		jz 		w1 									; OK
		loop 	w0									;
		jmp 	KB_Fail 							; Тайм-аут
;...................................................;

;...................................................; <<< Отправка кода команды
w1: 	mov 	al, [bx+KB_TBL]						; AL <- Command
		inc		bx									;
		mov		dl, [bx+KB_TBL]						; DX <- Port 
		out 	dx, al								;
		inc		bx									;
;...................................................;

;...................................................; <<< Решаем, нужно ли ждать ответ(ы)
		mov		ah, [bx+KB_TBL]						; AH <- Кол-во ответов
		inc		bx									;
													;
		cmp		ah, 0								; if response_num == 0
		je		w_next								; 	goto next command (не ждем)
;...................................................; 
									
;...................................................; else 
		mov 	cx, 2000h 							; 	ждём ответ...
w2: 	in		al, STATUS_PORT						;
		test 	al, OUT_BUF_FULL					;
		jz 		w3 									; 
;...................................................; 

;...................................................; <<< Анализ кода ответа
		in 		al, KB_OUT_BUF						; 
		mov		dl, [bx+KB_TBL]						; DL <- правильный ответ
		inc		bx									;
		cmp		al, dl								; Если получен неверный ответ
		jne		KB_Fail								; ...
													;
		dec		ah									; Уменьшаем количество оставшихся ответов
		jz		w_next								; Если осталось получить 0 ответов goto ... 
		mov 	cx, 2000h 							; Иначе
w3: 	loop 	w2									; 	Ждём следующий ответ
		jmp 	KB_Fail 							; Тайм-аут
;...................................................;

;...................................................; <<< Проверяем, есть ли еще команды
w_next:	cmp		[bx+KB_TBL], 0						;
		jne		w_loop								;
		jmp		K_done								;
;---------------------------------------------------;

;--------------------[ KBD fail ]-------------------; Endless beeping 
KB_Fail:call	beep								; 
		hlt											;
		jmp		KB_Fail								;
;---------------------------------------------------;

;--------------------[ Success ]--------------------;
K_done: PIC_mask 	11111100b, 11111111b			; Unmasking keyboard
		;call	beep								;
		pop		es									;
		pop		dx									;
		pop		cx									;
		pop		bx									;
		pop		ax									;	
		ret											;
init_keyboard endp									;
;---------------------------------------------------;	