@echo off
for /D %%d in ("c:\program files*") do (
	for /D %%f in ("%%d\Bochs-*") do (
		"%%f\bochs.exe" -q %*
		rem exit
   )
)
