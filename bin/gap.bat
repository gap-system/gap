set TERMINFO=/cygdrive/c/gap4dev/terminfo
set CYGWIN=nodosfilewarning
set LANG=en_US.UTF-8
set HOME=%HOMEDRIVE%%HOMEPATH%
cd %HOME%
start "GAP" C:\gap4dev\bin\mintty.exe -s 120,40 /cygdrive/c/gap4dev/bin/gapw95.exe -l /cygdrive/c/gap4dev %*
exit
