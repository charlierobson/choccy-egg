@echo off

setlocal
cd data
call :convert cheg1
call :convert cheg2
call :convert cheg3
call :convert chegt
cd ..
set dest=C:\Users\robsonc\EightyOne\ZXpand_SD_Card\

brass .\a_main.asm chuck.p -s -l chuck.html

copy /y chuck.p %dest%menu.p

exit /b

:convert
python cv_map2off.py %1.raw %1.off
lz48 -i %1.off -o %1.lz
exit /b
