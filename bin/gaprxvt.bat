set TERMINFO=/cygdrive/c/gap4dev/terminfo
set CYGWIN=nodosfilewarning
set LANG=en_US.ISO-8859-1
set HOME=%HOMEDRIVE%%HOMEPATH%
cd %HOME%
start "GAP" C:\gap4dev\bin\rxvt.exe -fn fixedsys -sl 1000 -e /cygdrive/c/gap4dev/bin/gapw95.exe -l /cygdrive/c/gap4dev %*
exit
