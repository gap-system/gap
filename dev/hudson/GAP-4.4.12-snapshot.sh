curl -s -k -o gap4r4p12.tar.bz2 ftp://ftp.gap-system.org/pub/gap/gap4/tar.bz2/gap4r4p12.tar.bz2
curl -s -k -o xtom1r1p4.tar.bz2 ftp://ftp.gap-system.org/pub/gap/gap4/tar.bz2/xtom1r1p4.tar.bz2
curl -s -k -o tools4r4p12.tar.bz2 ftp://ftp.gap-system.org/pub/gap/gap4/tar.bz2/tools4r4p12.tar.bz2
tar jxf gap4r4p12.tar.bz2
tar jxf xtom1r1p4.tar.bz2
tar jxf tools4r4p12.tar.bz2
rm *.tar.bz2

cd gap4r4/doc/test/
curl -s -k -o mktest.sh http://www.cs.st-andrews.ac.uk/~alexk/gap/hudson/mktest.sh
curl -s -k -o mkxdiff.sh http://www.cs.st-andrews.ac.uk/~alexk/gap/hudson/mkxdiff.sh
curl -s -k -o mkdiff.sh http://www.cs.st-andrews.ac.uk/~alexk/gap/hudson/mkdiff.sh
curl -s -k -o mktestx.sh http://www.cs.st-andrews.ac.uk/~alexk/gap/hudson/mktestx.sh
curl -s -k -o mkxtest.sh http://www.cs.st-andrews.ac.uk/~alexk/gap/hudson/mkxtest.sh
chmod u+x mk*.sh
cd ../../tst
rm testutil.g
curl -s -k -o testutil.g http://www.cs.st-andrews.ac.uk/~alexk/gap/hudson/testutil.g
cd ..
rm Makefile.in
curl -s -k -o Makefile.in http://www.cs.st-andrews.ac.uk/~alexk/gap/hudson/Makefile.in  

cd pkg
curl -s -k -o packages.tar.bz2 ftp://ftp.gap-system.org/pub/gap/gap4/tar.bz2/`echo 'cls -1 packages-*' | lftp ftp://ftp.gap-system.org/pub/gap/gap4/tar.bz2/|tail -1`
tar jxf packages.tar.bz2
rm *.tar.bz2

cd ../..
tar -cjf gap4r4-snapshot.tar.bz2 gap4r4/
