#################################################
#        Глобальная таблица дескрипторов        #
#################################################	
GDT:
		.descriptor																# нулевой дескриптор
CS_dsc:	.descriptor	limit = 0xFFFFFFFF, base = 0x00000,	r=1, p=1, dpl=0, x=1	# код		
DS_dsc:	.descriptor	limit = 0xFFFFFFFF, base = 0x00000,	w=1, p=1, dpl=0			# данные	
GS_dsc:	.descriptor	limit = 0x00008000, base = 0xB8000,	w=1, p=1, dpl=0			# видео		
SS_dsc:	.descriptor	limit = 0x00000800, base = 0x06C00,	w=1, p=1, dpl=0, ed=1	# стек

# Сегмент видео (GS) охватывает только видеопамять
# 	с 0xB8000 по 0xC0000, т.е. 32 килобайта (0x8000 = 32 768)
# Сегмент стека - 2 килобайта (0x1000 - 0x800 = 0x800 = 2048)
#
# .descriptor, limit=0,base=0,g=0,x=0,l=0,p=0,dpl=0,c=0,r,a=0,w,ed=0,type

#################################################
#                     GDTR                      #
#################################################	
gdtr:	
	.word	. - GDT - 1						# Table Limit
	.long	0								# Linear Base Address

	