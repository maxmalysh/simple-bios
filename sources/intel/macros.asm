;-------------[ End of Interrupt ]--------------;
EndOfInterrupt 	macro							;
												;
				mov		al, 20h					; EOI
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