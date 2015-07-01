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

if exist sources/intel/%1.asm (
	
	echo Initializing Visual Studio environment variables...
	set flag=0
	for /D %%d in ("c:\program files*") do (
		for /D %%f in ("%%d\microsoft visual studio*") do (
			if exist "%%f\Common7\Tools\vsvars32.bat" (
				set flag=1
				echo OK & echo.
				call "%%f\Common7\Tools\vsvars32.bat"
			)
		)
	)
	if flag==0 ( 
		echo Error! Failed to find Visual Studio. 
		goto :error
	)
	
	echo Compiling...
	ml /Zm /omf /c /nologo sources/intel/%1.asm  

	if exist %1.obj (
		echo OK & echo.
		
		echo Linking %1.obj, %1.tmp, nul.map, nul.def
		.\chk\link /tiny /nologo %1.obj, %1.tmp, nul.map, , nul.def
	
		if exist %1.tmp (
			echo OK & echo.
			
			echo Converting to binary...
			if %1==bios copy /b .\chk\zero.bin+%1.tmp %1.bin >nul
			echo OK & echo.
		) else (
			echo Error! Failed to link.
			goto :error
		)
	) else (
		echo Error! MASM have failed to compile %1.asm.
		goto :error
	)
) else (
	echo Error! %1.asm was not found.
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
if exist %1.obj del %1.obj
if exist %1.tmp del %1.tmp
echo Done.
goto :EOF
rem Все вопросы на maxmalysh@gmail.com.