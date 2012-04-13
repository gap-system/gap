set TERMINFO=/cygdrive/c/GAP4R5/terminfo
set CYGWIN=nodosfilewarning
set LANG=en_US.UTF-8
set HOME=%HOMEDRIVE%%HOMEPATH%
cd %HOME%
start "GAP" C:\GAP4R5\bin\mintty.exe -s 120,40 /cygdrive/c/gap4r5/bin/gapw95.exe -l /cygdrive/c/GAP4R5 %*
exit
