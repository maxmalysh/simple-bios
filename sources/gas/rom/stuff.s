#############################################
real_mode_done:
	NewLine

	PutString	"Well, we're done here. That was our small POST.\r\n",  0x0007
	PutString	"Press any key to start the chainload. ", 0x0007
	
	mov		$0x13, %ah						# 
	int		$0x16							# Int 16, 13 function: flush KB buffer
	
	xor		%ah, %ah						# No need to save registers here. 
	int		$0x16							# Int 16, 0 function: getchar
											# <---- ASCII symbol is AL now
	mov		$0x0E, %ah 						# int 10, 0xE function: 
	mov		$0, %bh							# print char (teletype)
	int		$0x10							#
	
	PutString	"\r\nAllright, loading.\r\n\r\n", 0x0008
	ret
#############################################

#############################################
invoke_bootloader:	
	#	PutString	"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~                             Some_name Bootloader                               ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", 0x000E # 

	cli	 									#   setting up 0x19 int (Bootstrap Loader)  
	movw	$int19_handler, %es:0x19*4		#
	movw	%cs, %es:0x19*4+2				# 
	sti										#
	
	int		$0x19							# int 0x19 passes control to the bootloader
############################################# 
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
/*              00H black     08H gray
                01H blue      09H bright blue
                02H green     0aH bright green
                03H cyan      0bH bright cyan
                04H red       0cH bright red
                05H magenta   0dH bright magenta
                06H brown     0eH yellow
                07H white     0fH bright white
                                                      
888888b.   888b     d888  .d8888b.  88888888888 888     888              
888  "88b  8888b   d8888 d88P  Y88b     888     888     888              
888  .88P  88888b.d88888 Y88b.          888     888     888              
8888888K.  888Y88888P888  "Y888b.       888     888     888              
888  "Y88b 888 Y888P 888     "Y88b.     888     888     888              
888    888 888  Y8P  888       "888     888     888     888              
888   d88P 888   "   888 Y88b  d88P     888     Y88b. .d88P              
8888888P"  888       888  "Y8888P"      888      "Y88888P"                                                                    
*/
	