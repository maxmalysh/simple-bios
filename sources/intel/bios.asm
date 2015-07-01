.586

include macros.asm								; Macros go here 
												
_TEXT segment byte public 'DATA' use16		
assume cs:_TEXT, ds:nothing, es:nothing

org		100h

;-----------------[ Main part ]-----------------;
start:											;
		cli										;
		lss		SP, dword ptr STKPTR			;
		sti										;

		call	scanbios						; scanbios.asm
		call	init_pic						; pic.asm
		call	init_timer						; timer.asm
		call	init_keyboard					; keyboard_init.asm
		call	stop							; stop.asm

		STKPTR  dw	0FFFEh,09000h				;
												;
		include scanbios.asm					;
		include pic.asm							;
		include timer.asm						;
		include keyboard.asm					;
		include stop.asm						;
		include ivt.asm							;
												;
; real startup entry begins at F000:FFF0		;
org		0FFF0h									;
		db		0EAh							; far jump
		dw		offset start					; offset
		dw		0F000h							; segment
												;
org		0FFFEh									;
		dw		99FCh							; PC ID
												;
_TEXT   ends									;
end		start									;
;-----------------------------------------------;
