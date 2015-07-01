#########################################
#       ฬเ๊๐๎๑ ไ๋ÿ ๏ๅ๗เ๒่ ๑๒๐๎๊่        #
#########################################							
.macro	PutString	string = "\r\n",  color = 0x0007			
		jmp		3f						#
1:										#
		.ascii	"\string" 				#
		sizeof_string = (. - 1b)		#
3:										#
		mov 	$0x300, %ax				# get cursor position
		xor 	%bx, %bx				#
		int 	$0x10					#
		
		mov		$0x1301, %ax			# 13-เÿ ๔๓ํ๊๖่ÿ, 
		mov		$\color,  %bx			#
		mov		$sizeof_string, %cx		# ไ๋่ํเ ๑๒๐๎๊่
		push	%cs						#
		pop		%es						# 
		mov		$1b, %bp				# es:bp <- ๓๊เ็เ๒ๅ๋ü ํเ ๑๒๐๎๊๓
		int 	$0x10					#
.endm 									#
#########################################


######################################### อ๓ เ ๊เ๊ ๆๅ แๅ็ ๋๎ใ๎? :)
#              ฯๅ๗เ๒ü ๋๎ใ๎              #
#########################################	
PrintOsLogo:
		mov	$0x0003, %ax
		int	$0x10
		
		PutString	"ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป", 0x000A # green
		PutString	"บ     8888888 888     888         .d8888b.         .d88888b.   .d8888b.        บ", 0x000A # green 
		PutString	"บ       888   888     888        d88P  Y88b       d88P` `Y88b d88P  Y88b       บ", 0x000E # yellow 
		PutString	"บ       888   888     888        888    888       888     888 Y88b.            บ", 0x0006 # brown 
		PutString	"บ       888   888     888        Y88b. d888       888     888  `Y888b.         บ", 0x0004 # red
		PutString	"บ       888   888     888         `Y888P888       888     888     `Y88b.       บ", 0x000C # bright red
		PutString	"บ       888   888     888 888888        888       888     888       `888       บ", 0x000D # bright magenta
		PutString	"บ       888   Y88b. .d88P        Y88b  d88P       Y88b. .d88P Y88b  d88P       บ", 0x0005 # magenta  
		PutString	"บ     8888888  `Y88888P`          `Y8888P`         `Y88888P`   `Y8888P  ver 0.1บ", 0x0009 # bright blue
		PutString	"ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ\r\n", 0x000A #   
		PutString	"Well, this is not an operating system at all... \r\n   ...but I like how this logo looks like! \r\n\n", 0x0007 #  
		PutString	"--> Hit enter to switch to the protected mode.\r\n", 0x0007

		ret
#########################################


#########################################
#       ฮๆ่ไเํ่ๅ ํเๆเ๒่ÿ ๊๋เโ่๘่        #
#########################################
WaitKey:								#
		mov		$0x13, %ah				# 
		int		$0x16					# Int 16, 13 function: flush KB buffer
.WaitAgain:								#
		xor		%ah, %ah				# No need to save registers here. 
		int		$0x16					# Int 16, 0 function: getchar
		cmp		$0x1C, %ah				# <---- Scancode is     AH now; $0x1C = enter
		jne		.PrintChar				# <---- ASCII symbol is AL now
		ret								#
.PrintChar:								#
		mov		$0x0E, %ah 				# int 10, 0xE function: 
		mov		$0, %bh					# print char (teletype)
		int		$0x10					#
		jmp		.WaitAgain				#
		ret								#
		

#########################################
