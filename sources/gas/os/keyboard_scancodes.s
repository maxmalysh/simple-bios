
.equ	SC_TABLE_FIRST, 0x01
.equ	SC_TABLE_LAST,  0x58
		
SC_TABLE:
		#	  Esc															 	BS  Tab
		#      1    2    3    4    5    6    7    8    9    A    B    C    D    E    F   #
		.byte ' ', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=','\b','\t'  # 0x01  - 0x0F. 0xE = Backspace, 0xF=Tab
		.byte 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']'
		.byte  0xBC # Enter - костыль
		.byte ' ' # Left Ctrl
		.byte 'a'
		.byte 's'
		.byte 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';','\'', '`'							 # 0x20
		.byte ' ' # Left Shift
		.byte '\\'
		.byte 'z'
		.byte 'x'
		.byte 'c'
		.byte 'v'
		.byte 'b'
		.byte 'n'
		.byte 'm'
		.byte ','
		.byte '.'
		.byte '/'
		.byte ' ' # Right shift
		.byte '*' # Keypad * (PrtSc)
		.byte ' ' # Left Alt
		.byte ' '
		.byte ' ' # Caps Lock
		.byte ' ' # F1
		.byte ' ' # F2
		.byte ' ' # F3
		.byte ' ' # F4
		.byte ' ' # F5
		.byte ' ' # F6
		.byte ' ' # F7
		.byte ' ' # F8
		.byte ' ' # F9
		.byte ' ' # F10
		.byte ' ' # Num Lock
		.byte ' ' # Scroll Lock
		.byte '7' # Keypad 7 (Home)
		.byte '8' # Keypad 8 (Up)
		.byte '9' # Keypad 9 (PgUp)
		.byte '-' # Keypad -
		.byte '4' # Keypad 4 (Left)
		.byte '5' # Keypad 5
		.byte '6' # Keypad 6 (Right)
		.byte '+' # Keypad +
		.byte '1' # Keypad 1 (End)
		.byte '2' # Keypad 2 (Down)
		.byte '3' # Keypad 3 (PgDn)
		.byte '0' # Keypad 0 (Ins)
		.byte '.' # Keypad . (Del)
		.byte ' ' # Sys Req
		.byte ' ' # None, 0x55
		.byte ' ' # None, 0x56
		.byte ' ' # F11
		.byte ' ' # F12
	
		