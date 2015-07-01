@echo off
echo.
setlocal

if .%1.==.. ( 
	call :do_build bios 
) else  (
	call :do_build %1
)

endlocal
echo ================================================================================
exit /B


:do_build
echo ==========================	Building %1.bin...   	========================

if exist %1.bin del %1.bin

if exist sources/gas/%1.s (
	
	echo Setting up MinGW environment variables...
	if exist "C:\MinGW\bin\gcc.exe" (
		set "PATH=C:\MinGW\bin;%PATH%"
	rem	set "PATH=C:\Code\bin;%PATH%"
		echo OK & echo.
	) else ( 
		echo Error! Failed to find gcc MinGW.
		goto :error
	)

	echo Compiling...
	rem mingw32-as sources/gas/%1.s sources/gas/os.s -o %1.o -c --32 -a > .\listings\gas_listing.lst
	mingw32-as sources/gas/%1.s  -o %1.o  -c --32 -a > .\listings\%1.lst
	mingw32-as sources/gas/mbr.s -o mbr.o -c --32 -a > .\listings\mbr.lst
	mingw32-as sources/gas/os.s  -o os.o  -c --32 -a > .\listings\os.lst
	if exist mbr.o ( 
		rem
	) else (
		echo Error! Failed to compile mbr.s
		goto :error
	)
	if exist os.o ( 
		rem	
	) else (
		echo Error! Failed to compile os.s
		goto :error
	)
	if exist %1.o (
		echo OK & echo.	
		
		echo Linking...
		mingw32-ld -o %1.tmp %1.o  os.o mbr.o --default-script=".\chk\ld-script"
		rem mingw32-ld -o %1.tmp %1.o  --default-script=".\chk\ld-script"
		if exist %1.tmp (
			echo OK & echo.
			
			echo Converting to binary...
			mingw32-objcopy -O binary -j .text bios.tmp bios.bin
			if exist %1.bin (
				echo OK & echo.
			) else (
				echo Error! Failed to convert %1.tmp to %1.bin
				goto :error
			)
		) else (
			echo Error! Failed to link.
			goto :error
		)
	) else (
		echo Error! Failed to compile %1.s
		goto :error
	)
) else (
	echo Error! %1.s was not found.
	goto :error
)

echo Success! %1.bin was translated and linked
goto :delete_temp

:error
echo.
echo Error! Failed to build image.

:delete_temp
echo.
echo Deleting temporary files...
if exist %1.o  del %1.o 
if exist os.o  del os.o 
if exist mbr.o  del mbr.o 
if exist %1.tmp del %1.tmp
echo Done.
goto :EOF
rem Все вопросы на maxmalysh@gmail.com.