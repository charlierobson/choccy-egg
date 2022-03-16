setlocal
cd data
python cv_map2off.py cheg1.raw cheg1.off
python cv_map2off.py cheg3.raw cheg3.off
cd ..
set dest=C:\Users\robsonc\EightyOne\ZXpand_SD_Card\
brass .\a_main.asm %dest%menu.p -s -l chuck.html
copy /y %dest%menu.p.sym %dest%..

