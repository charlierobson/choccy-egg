@echo off

setlocal
cd data
python cv_map2off.py cheg1.raw cheg1.off
python cv_map2off.py cheg2.raw cheg2.off
python cv_map2off.py cheg3.raw cheg3.off
python cv_map2off.py chegt.raw chegt.off
cd ..
set dest=C:\Users\robsonc\EightyOne\ZXpand_SD_Card\

brass .\a_main.asm chuck.p -s -l chuck.html

copy /y chuck.p %dest%menu.p
