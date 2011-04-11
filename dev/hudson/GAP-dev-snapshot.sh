mkdir -p extern/include

mv pkg/CVS ./pkg_CVS
mv pkg/gapdoc .
mv pkg/tomlib .
rm -rf pkg/*
cd pkg

wget -nv ftp://ftp.gap-system.org/pub/gap/gap4/tar.bz2/`echo 'cls -1 packages-*' | lftp ftp://ftp.gap-system.org/pub/gap/gap4/tar.bz2/|tail -1`
tar jxf `ls packages-*|tail -1`
rm packages-*
rm -rf GAPDoc*
mv ../pkg_CVS CVS
mv ../gapdoc .
mv ../tomlib .
cd gapdoc
cvs update -d
cd ..
cd tomlib
cvs update -d
cd ../../..
tar -cjf GAP-dev-snapshot.tar.bz2 GAP-dev-snapshot/
mv GAP-dev-snapshot.tar.bz2 GAP-dev-snapshot/
cd GAP-dev-snapshot/
