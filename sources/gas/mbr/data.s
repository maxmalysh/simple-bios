	
###############     Text Data     ############### 
_MBR_logo: 										#
.ascii "\r\n\n"									#	
.ascii "~~~~~~~~~~~~~~~~~~ Master Boot Record code is being executed ~~~~~~~~~~~~~~~~~~~\r\n"
.asciz "Step 1. Relocating the MBR from the 0x7C00 to 0x0600... "

_MBR_copy:
.asciz "Done.\r\nStep 2. Copying the bootloader from the ROM to RAM to the 0x7C00... "

_MBR_hit:
.asciz "Done.\r\n\r\nHit enter to start our fancy 32-bit protected bootloader..."
