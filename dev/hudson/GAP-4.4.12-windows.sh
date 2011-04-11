call rm -rf *
call curl -s -k -o gap4r4p12.tar.bz2 ftp://ftp.gap-system.org/pub/gap/gap4/tar.bz2/gap4r4p12.tar.bz2
call curl -s -k -o xtom1r1p4.tar.bz2 ftp://ftp.gap-system.org/pub/gap/gap4/tar.bz2/xtom1r1p4.tar.bz2
call curl -s -k -o tools4r4p12.tar.bz2 ftp://ftp.gap-system.org/pub/gap/gap4/tar.bz2/tools4r4p12.tar.bz2
call tar jxf gap4r4p12.tar.bz2
call tar jxf xtom1r1p4.tar.bz2
call tar jxf tools4r4p12.tar.bz2
call rm *.tar.bz2
call cd gap4r4/
call cd pkg
call curl -s -k -o packages.tar.bz2 ftp://ftp.gap-system.org/pub/gap/gap4/tar.bz2/packages-2010_08_27-09_40_UTC.tar.bz2
call tar jxf packages.tar.bz2
call rm *.tar.bz2
call cd ..
call bin\gapw95.exe -A -N -x 80 -r -m 100m -l %WORKSPACE%\gap4r4 %WORKSPACE%\gap4r4\tst\testall.g
call bin\gapw95.exe    -N -x 80 -r -m 100m -l %WORKSPACE%\gap4r4 %WORKSPACE%\gap4r4\tst\testall.g
