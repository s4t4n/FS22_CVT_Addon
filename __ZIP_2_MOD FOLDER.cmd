@echo off & setlocal
REM @echo off
REM @ECHO >> _ZiP_log.txt
REM by sÀtÁñ
REM echo dir_2_zip
REM alle *.bak Dateien werden vor dem Packen entfernt !
REM if not EXIST "%1" goto zipit
REM if EXIST "%1" goto startit
set modname=FS22_RandomFuelsPrices

set path_self=%~dp0
for %%i in ("%path_self:~0,-1%") do set name_parent=%%~nxi
REM echo %name_parent%
REM echo 
goto zipit
REM goto cleanzip


:startit
echo ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ >> _ZiP_log.txt
REM DATE /T >> _ZiP_log.txt
REM TIME /T >> _ZiP_log.txt
REM echo %~n1 to %~n1.zip >> _ZiP_log.txt
REM echo. >> _ZiP_log.txt
REM IF EXIST %1.zip goto zipped
REM IF not EXIST %1.zip goto cleanzip
goto end

:zipped
REM call rundll32.exe cmdext.dll,MessageBeepStub
REM ECHO file %1.zip already exists
REM ECHO file %~n1.zip already exists >> _ZiP_log.txt
echo ###########_______________________DATEI BEREITS VORHANDEN !!!!_____############ %~z1 Bytes
REM echo ###########_______________________DATEI BEREITS VORHANDEN !!!!_____############ %~z1 Bytes >> _ZiP_log.txt
echo.
echo __________________Datei überschreiben? %~z1  (j/n)
REM echo __________________Datei überschreiben? %~z1  (j/n) >> _ZiP_log.txt
SET /P fragen=
if '%fragen%'=='n' goto end
if '%fragen%'=='j' goto repl
timeout /T 0
goto end

:cleanzip
REM echo _______________ cleaning from .bak files of np++
echo _______________ Aktualisiere...
REM echo _______________ cleaning from .bak files of np++ >> _ZiP_log.txt
REM del %1\*.bak
REM del %1\*.bak /s
REM del %1\*.bak /s >> _ZiP_log.txt
REM setlocal enabledelayedexpansion
REM setlocal DisableDelayedExpansion

REM set zeileNrAustausch=19
REM set zeileNeu=local scrversion = "0.3.2.5+";

REM if exist CVT_Addon.tmp del CVT_Addon.tmp

REM set zeileNr=0

REM for /f "delims=" %%A in (CVT_Addon.lua) do (
REM ( set /a zeileNr+=1 >NUL)
  REM (if !zeileNr!==%zeileNrAustausch% (echo %zeileNeu%>>CVT_Addon.tmp) else (echo %%A>>CVT_Addon.tmp))
REM )

REM if exist CVT_Addon.akt del CVT_Addon.akt
REM ren CVT_Addon.lua CVT_Addon.akt
REM ren CVT_Addon.tmp CVT_Addon.lua
REM pause

REM timeout /T 3
goto zipit

:zipit
echo.
echo.
echo.
echo ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ >> _ZiP_log.txt
C:\Programme\7-Zip\7z.exe a "%~dp0"%name_parent% -w "%~dp0"* -xr!*.cmd -xr!*.bak -xr!*.7z -xr!*.zip -xr!*.png -xr!*.jpg -xr!Old -xr!VCA_modified -xr!log -xr!*.psd -xr!screenshots -xr!_ZiP_log.txt -xr!offline -tzip >> _ZiP_log.txt
echo ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ >> _ZiP_log.txt
echo.
echo.
echo.
REM echo Dir-Size = %~z1 Bytes >> _ZiP_log.txt 
if exist "%~dp0"%name_parent%.zip goto moveit
REM echo folder exists, delete again
REM echo folder exists, delete again >> _ZiP_log.txt
goto end

:repl
del %1.zip
echo lösche %1.zip
REM echo lösche %~n1.zip >> _ZiP_log.txt
REM timeout /T 0 /nobreak
rem C:\Programme\7-Zip\7z.exe a %1 -w %1\*  -tzip

echo ______________############# überschrieben! ##############
echo _______________############# Überschrieben! ##############
echo ________________############# Überschrieben! ##############
echo _________________############# Überschrieben! ##############
echo __________________############# Überschrieben! ##############
echo ___________________############# Überschrieben! ##############
REM echo __________________############# Überschrieben! ############## >> _ZiP_log.txt
goto cleanzip

:deldir
echo delete directory %1
REM echo delete directory %~n1 >> _ZiP_log.txt
rmdir /s /q %1
timeout /T 0
if exist %1 echo folder exists, delete again
timeout /T 0
goto end

:moveit
echo MOOOOOOOOOVE
copy /Y "%~dp0"%name_parent%.zip "D:\__LS-MODS\Mod-Sets\G-Portal LUpool" >> _ZiP_log.txt
move /Y "%~dp0"%name_parent%.zip "C:\Users\SbSh\Documents\My Games\FarmingSimulator2022\mods" >> _ZiP_log.txt
echo                                   nach "C:\Users\SbSh\Documents\My Games\FarmingSimulator2022\mods\%name_parent%.zip" >> _ZiP_log.txt
timeout /T 1
REM pause
goto end

:end
echo ..............ByE bYe...........................
REM call rundll32.exe cmdext.dll,MessageBeepStub
REM %sizecheck% = "%~z1.zip"
REM echo Zipfile has %sizecheck%
REM echo Zipfile has %sizecheck% >> _ZiP_log.txt
REM echo ..............ByE bYe........................... >> _ZiP_log.txt
echo ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ >> _ZiP_log.txt
REM echo. >> _ZiP_log.txt
REM echo. >> _ZiP_log.txt
REM echo. >> _ZiP_log.txt
REM echo. >> _ZiP_log.txt
REM timeout /T 5
goto EOF


:ddende

echo Bitte Verzeichnis per drag and drop auf diesen command ziehen.
timeout /T 20
