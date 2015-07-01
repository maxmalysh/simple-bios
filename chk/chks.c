#define _CRT_SECURE_NO_DEPRECATE
#include <stdio.h>
#include <stdint.h>

#define countof(a)	(sizeof(a)/sizeof((a)[0]))

int main( int ac, char **av )
{
	int		i, n, j, sj;
	FILE		*fp;
	char		chks;
	char		buf[ 4096 ];
	uint32_t	pos;
	uint32_t	off;
	static char	signature[] = "\xAA\xFF\xFF\x55";
	

	for ( i=1; i<ac; i++ ) {
		fp = fopen( av[i], "r+b" );
		if ( !fp ) {
			fprintf( stderr, "Can't open '%s'\n", av[i] );
		} else {
			chks = '\0';
			pos = 0xFFFFFFFFUL;
			sj = 0;
			off = 0UL;
			while ( !feof( fp ) ) {
				n = fread( buf, 1, countof(buf), fp );
				for ( j=0; j<n; j++ ) {
					chks += buf[j];
					if ( 0xFFFFFFFFUL == pos ) {
						if ( buf[j] == signature[sj] ) {
							sj++;
							if ( signature[sj] == '\0' ) pos = off + j - 2;
						} else {
							sj = 0;
							if ( buf[j] == signature[sj] ) sj++;
						}
					}
				}
				off += (uint32_t)n;
			}

			if ( 0xFFFFFFFFUL != pos ) {
				chks = (char)( 0x1FFU - (unsigned)(unsigned char)chks );
				fseek( fp, pos, SEEK_SET );
				if ( fwrite( &chks, 1, 1, fp ) != 1 ) fprintf( stderr, "error: can't write\n" );
			} else {
				fprintf( stderr, "Can't find signature 0x55FFFFAA\n" );
			}
			fclose( fp );
		}
	}
	return 0;
}
