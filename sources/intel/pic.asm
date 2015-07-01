;================================================
;===================   PIC    ===================
init_pic proc near 
		push	ax
		
		EndOfInterrupt()								; начальный сброс PIC (безличный EOI)
		
		out 	0A0h, al

		mov		al,	11h									; ICW1
		out		20h, al		
		
		mov		al, 11h
		out		0A0h, al	
		
		mov		al,	8h									; ICW2
		out		21h, al		
		
		mov		al, 70h
		out		0A1h, al	
		
		mov		al, 4h									; ICW3
		out		21h, al		

		mov		al, 2h	
		out		0A1h, al	
		
		mov		al, 5h									; ICW4
		out		21h, al		
		
		mov		al, 1h
		out		0A1h, al	
		
		PIC_mask 11111111b,	11111111b
		
		pop		ax
		ret
init_pic endp
;================================================
