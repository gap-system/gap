set TERMINFO=/cygdrive/c/GAP4R5/terminfo
set CYGWIN=nodosfilewarning
set LANG=en_US.ISO-8859-1
set HOME=%HOMEDRIVE%%HOMEPATH%
cd %HOME%
start "GAP" C:\GAP4R5\bin\rxvt.exe -fn fixedsys -sl 1000 -e /cygdrive/c/gap4r5/bin/gapw95.exe -l /cygdrive/c/GAP4R5 %*
exit
