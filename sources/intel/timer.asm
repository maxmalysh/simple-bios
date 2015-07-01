;================================================
;===================  TIMER  ====================
init_timer proc near 
		push	ax
		push	es
		
		mov     al, 00110110b					; 00 - канал 0, 11 -r/w l/h; 011; 0(hex)
		out     43h, al		 	
	
		mov     ax, 64496						; для bochs 
		out     40h, al
		
		mov     al,  ah
		out     40h, al		
		
		xor		ax, ax							;---------------- timer handler setup
		mov		es, ax			
		cli	
		mov		es:[8h*4], offset int08_handler	; offset int08_handler
		mov		es:[8h*4+2], cs					; seg int08_handler 
		sti
		
		mov		ax, 40h
		mov		es, ax
		
		mov		byte ptr es:TCOUNT,0
		mov		byte ptr es:NOTE, 0
		
		PIC_mask 11111110b, 11111111b
		
		pop		es
		pop		ax
		ret		     
init_timer endp

;-------------[ Beeping routines ]--------------;
beep proc near
		push	dx
		push	cx
		
		mov		dx, 0FDFh;
		call	sound_on
		mov		dx, 02h;
beep_l: loop    beep_l
        dec     dx
        jnz     beep_l
		call	sound_off
		
		pop		cx
		pop		dx
		ret
beep endp

sound_on proc near						; receives frequency in DX
		push	ax
        mov     al, 10110110b			; 2-ой канал таймера, прямоуг. импульсы
        out     43h, al				
       
		mov     ax, dx					; загружаем частоту звука
        out     42h, al				
        mov     al, ah					; ^...
        out     42h, al				
        in      al, 61h					;			
        or      al, 00000011b			; первые два бита - вкл. динамик
		out     61h, al					; 
		pop		ax
		ret
sound_on endp

sound_off proc near
		push	ax
		in		al, 61h
		and		al, 11111100b
		out		61h, al
		pop		ax
		ret
sound_off endp
;-----------------------------------------------;
;================================================
		