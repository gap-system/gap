rm -rf GAP-dev-snapshot
curl -s -k -o GAP-dev-snapshot.tar.bz2 https://gap:SL25=2A5@keith.cs.st-andrews.ac.uk:8443/job/GAP-dev-snapshot/lastBuild/artifact/GAP-dev-snapshot.tar.bz2
tar jxf GAP-dev-snapshot.tar.bz2
cd GAP-dev-snapshot

if [ $GAPCOPTS = '64build' ]
then
export CC=gcc
export COPTS=-m64
fi

if [ $GAPGMP = 'nogmp' ]
then
./configure --with-gmp=no
else
if [ $GAPGMP = 'system' ]
then
./configure --with-gmp=system
else
cd extern
sed -e 's,tar zxvf,tar --numeric-owner -zxvf,g' Makefile.in > Makefile.new
mv Makefile.new Makefile.in
cd ..
./configure
fi
fi

make
cd pkg
wget -nv http://www.gap-system.org/Download/InstPackages.sh
sed -e 's,/usr/bin/tcsh,'`which tcsh`',g' InstPackages.sh > InstPackages2.sh
sed -e 's,tar xzpf,tar --numeric-owner -xzpf,g' InstPackages2.sh > InstPackages3.sh
chmod u+x InstPackages3.sh
./InstPackages3.sh
rm -rf anupq
rm -rf automata
rm -rf fr
rm -rf scscp
rm -rf Hap1.9
wget -nv http://www.cs.st-andrews.ac.uk/~alexk/gap/hudson/testshort.tst
mv testshort.tst simpcomp/tst/testshort.gap
wget -nv http://www.cs.st-andrews.ac.uk/~alexk/gap/hudson/nq.gi
mv nq.gi nq-2.2/gap/nq.gi
cd ..
rm -rf dev/log

if [ $GAPTARGET = 'manuals' ]
then
cd pkg/gapdoc/
../../bin/gap.sh -b makedocrel.g
cd ../../
make manuals
fi

make test$GAPTARGET

case $GAPTARGET in
install)
echo '=========OUTPUT START: testinstall without packages========='
cat `ls dev/log/testinstall1_*|tail -1`
echo '=========OUTPUT END: testinstall without packages========='
echo '=========OUTPUT START: testinstall with packages========='
cat `ls dev/log/testinstall2_*|tail -1`
echo '=========OUTPUT END: testinstall with packages========='
echo -n "YVALUE=" > dev/log/plotinstall1_count.txt
wc -l `ls dev/log/testinstall1_*|tail -1` | cut -f 1 -d ' ' >> dev/log/plotinstall1_count.txt
echo -n "URL=" >> dev/log/plotinstall1_count.txt
echo -n $HUDSON_URL >> dev/log/plotinstall1_count.txt
echo -n "job/" >> dev/log/plotinstall1_count.txt
echo -n $JOB_NAME >> dev/log/plotinstall1_count.txt
echo -n "/" >> dev/log/plotinstall1_count.txt
echo $BUILD_NUMBER >> dev/log/plotinstall1_count.txt
echo -n "YVALUE=" > dev/log/plotinstall2_count.txt
wc -l `ls dev/log/testinstall2_*|tail -1` | cut -f 1 -d ' ' >> dev/log/plotinstall2_count.txt
echo -n "URL=" >> dev/log/plotinstall2_count.txt
echo -n $HUDSON_URL >> dev/log/plotinstall2_count.txt
echo -n "job/" >> dev/log/plotinstall2_count.txt
echo -n $JOB_NAME >> dev/log/plotinstall2_count.txt
echo -n "/" >> dev/log/plotinstall2_count.txt
echo $BUILD_NUMBER >> dev/log/plotinstall2_count.txt
cat `ls dev/log/testinstall1_*|tail -1` | tail -2 | head -1 | sed -e 's/  */ /g' | cut -f 1 -d ' ' > dev/log/plotinstall1_total.txt
export GAPTOTAL=`cat dev/log/plotinstall1_total.txt `
if [ $GAPTOTAL = 'total' ]
then
echo -n "YVALUE=" > dev/log/plotinstall1_time.txt
cat `ls dev/log/testinstall1_*|tail -1` | tail -2 | head -1 | sed -e 's/  */ /g' | cut -f 3 -d ' ' >> dev/log/plotinstall1_time.txt
echo -n "URL=" >> dev/log/plotinstall1_time.txt
echo -n $HUDSON_URL >> dev/log/plotinstall1_time.txt
echo -n "job/" >> dev/log/plotinstall1_time.txt
echo -n $JOB_NAME >> dev/log/plotinstall1_time.txt
echo -n "/" >> dev/log/plotinstall1_time.txt
echo $BUILD_NUMBER >> dev/log/plotinstall1_time.txt
else
echo "test was not completed"
exit 1
fi
cat `ls dev/log/testinstall2_*|tail -1` | tail -2 | head -1 | sed -e 's/  */ /g' | cut -f 1 -d ' ' > dev/log/plotinstall2_total.txt
export GAPTOTAL=`cat dev/log/plotinstall2_total.txt`
if [ $GAPTOTAL = 'total' ]
then
echo -n "YVALUE=" > dev/log/plotinstall2_time.txt
cat `ls dev/log/testinstall2_*|tail -1` | tail -2 | head -1 | sed -e 's/  */ /g' | cut -f 3 -d ' ' >> dev/log/plotinstall2_time.txt
echo -n "URL=" >> dev/log/plotinstall2_time.txt
echo -n $HUDSON_URL >> dev/log/plotinstall2_time.txt
echo -n "job/" >> dev/log/plotinstall2_time.txt
echo -n $JOB_NAME >> dev/log/plotinstall2_time.txt
echo -n "/" >> dev/log/plotinstall2_time.txt
echo $BUILD_NUMBER >> dev/log/plotinstall2_time.txt
else
echo "test was not completed"
exit 1
fi
;;
standard)
echo '=========OUTPUT START: teststandard without packages========='
cat `ls dev/log/teststandard1_*|tail -1`
echo '=========OUTPUT END: teststandard without packages========='
echo '=========OUTPUT START: teststandard with packages========='
cat `ls dev/log/teststandard2_*|tail -1`
echo '=========OUTPUT END: teststandard with packages========='
echo -n "YVALUE=" > dev/log/plotstandard1_count.txt
wc -l `ls dev/log/teststandard1_*|tail -1` | cut -f 1 -d ' ' >> dev/log/plotstandard1_count.txt
echo -n "URL=" >> dev/log/plotstandard1_count.txt
echo -n $HUDSON_URL >> dev/log/plotstandard1_count.txt
echo -n "job/" >> dev/log/plotstandard1_count.txt
echo -n $JOB_NAME >> dev/log/plotstandard1_count.txt
echo -n "/" >> dev/log/plotstandard1_count.txt
echo $BUILD_NUMBER >> dev/log/plotstandard1_count.txt
echo -n "YVALUE=" > dev/log/plotstandard2_count.txt
wc -l `ls dev/log/teststandard2_*|tail -1` | cut -f 1 -d ' ' >> dev/log/plotstandard2_count.txt
echo -n "URL=" >> dev/log/plotstandard2_count.txt
echo -n $HUDSON_URL >> dev/log/plotstandard2_count.txt
echo -n "job/" >> dev/log/plotstandard2_count.txt
echo -n $JOB_NAME >> dev/log/plotstandard2_count.txt
echo -n "/" >> dev/log/plotstandard2_count.txt
echo $BUILD_NUMBER >> dev/log/plotstandard2_count.txt
cat `ls dev/log/teststandard1_*|tail -1` | tail -2 | head -1 | sed -e 's/  */ /g' | cut -f 1 -d ' ' > dev/log/plotstandard1_total.txt
export GAPTOTAL=`cat dev/log/plotstandard1_total.txt`
if [ $GAPTOTAL = 'total' ]
then
echo -n "YVALUE=" > dev/log/plotstandard1_time.txt
cat `ls dev/log/teststandard1_*|tail -1` | tail -2 | head -1 | sed -e 's/  */ /g' | cut -f 3 -d ' ' >> dev/log/plotstandard1_time.txt
echo -n "URL=" >> dev/log/plotstandard1_time.txt
echo -n $HUDSON_URL >> dev/log/plotstandard1_time.txt
echo -n "job/" >> dev/log/plotstandard1_time.txt
echo -n $JOB_NAME >> dev/log/plotstandard1_time.txt
echo -n "/" >> dev/log/plotstandard1_time.txt
echo $BUILD_NUMBER >> dev/log/plotstandard1_time.txt
else
echo "test was not completed"
exit 1
fi
cat `ls dev/log/teststandard2_*|tail -1` | tail -2 | head -1 | sed -e 's/  */ /g' | cut -f 1 -d ' ' > dev/log/plotstandard2_total.txt
export GAPTOTAL=`cat dev/log/plotstandard2_total.txt`
if [ $GAPTOTAL = 'total' ]
then
echo -n "YVALUE=" > dev/log/plotstandard2_time.txt
cat `ls dev/log/teststandard2_*|tail -1` | tail -2 | head -1 | sed -e 's/  */ /g' | cut -f 3 -d ' ' >> dev/log/plotstandard2_time.txt
echo -n "URL=" >> dev/log/plotstandard2_time.txt
echo -n $HUDSON_URL >> dev/log/plotstandard2_time.txt
echo -n "job/" >> dev/log/plotstandard2_time.txt
echo -n $JOB_NAME >> dev/log/plotstandard2_time.txt
echo -n "/" >> dev/log/plotstandard2_time.txt
echo $BUILD_NUMBER >> dev/log/plotstandard2_time.txt
else
echo "test was not completed"
exit 1
fi
;;
manuals)
echo '=========OUTPUT START: making tutorial========='
cat doc/tut/make_manuals.out
echo '=========OUTPUT END: making tutorial========='
echo '=========OUTPUT START: making reference manual========='
cat doc/ref/make_manuals.out
echo '=========OUTPUT END: making reference manual========='
echo '=========OUTPUT START: testmanuals without packages========='
cat `ls dev/log/testmanuals1_*|tail -1`
echo '=========OUTPUT END: testmanuals without packages========='
echo '=========OUTPUT START: testmanuals with autoloaded packages========='
cat `ls dev/log/testmanualsA_*|tail -1`
echo '=========OUTPUT END: testmanuals with autoloaded packages========='
echo '=========OUTPUT START: testmanuals with all packages========='
cat `ls dev/log/testmanuals2_*|tail -1`
echo '=========OUTPUT END: testmanuals with all packages========='
echo -n "YVALUE=" > dev/log/plotmanuals1_count.txt
wc -l `ls dev/log/testmanuals1_*|tail -1` | cut -f 1 -d ' ' >> dev/log/plotmanuals1_count.txt
echo -n "URL=" >> dev/log/plotmanuals1_count.txt
echo -n $HUDSON_URL >> dev/log/plotmanuals1_count.txt
echo -n "job/" >> dev/log/plotmanuals1_count.txt
echo -n $JOB_NAME >> dev/log/plotmanuals1_count.txt
echo -n "/" >> dev/log/plotmanuals1_count.txt
echo $BUILD_NUMBER >> dev/log/plotmanuals1_count.txt
echo -n "YVALUE=" > dev/log/plotmanualsA_count.txt
wc -l `ls dev/log/testmanualsA_*|tail -1` | cut -f 1 -d ' ' >> dev/log/plotmanualsA_count.txt
echo -n "URL=" >> dev/log/plotmanualsA_count.txt
echo -n $HUDSON_URL >> dev/log/plotmanualsA_count.txt
echo -n "job/" >> dev/log/plotmanualsA_count.txt
echo -n $JOB_NAME >> dev/log/plotmanualsA_count.txt
echo -n "/" >> dev/log/plotmanualsA_count.txt
echo $BUILD_NUMBER >> dev/log/plotmanualsA_count.txt
echo -n "YVALUE=" > dev/log/plotmanuals2_count.txt
wc -l `ls dev/log/testmanuals2_*|tail -1` | cut -f 1 -d ' ' >> dev/log/plotmanuals2_count.txt
echo -n "URL=" >> dev/log/plotmanuals2_count.txt
echo -n $HUDSON_URL >> dev/log/plotmanuals2_count.txt
echo -n "job/" >> dev/log/plotmanuals2_count.txt
echo -n $JOB_NAME >> dev/log/plotmanuals2_count.txt
echo -n "/" >> dev/log/plotmanuals2_count.txt
echo $BUILD_NUMBER >> dev/log/plotmanuals2_count.txt
;;
packages)
echo '=========OUTPUT START: testpackages without packages========='
cat `ls dev/log/testpackages1_*`
echo '=========OUTPUT END: testpackages without packages========='
echo '=========OUTPUT START: testpackages with all packages========='
cat `ls dev/log/testpackages2_*`
echo '=========OUTPUT END: testpackages with all packages========='
echo -n "YVALUE=" > dev/log/plotpackages1_count.txt
wc -l dev/log/testpackages1_*| tail -1 | cut -f 1 -d 't' >> dev/log/plotpackages1_count.txt
echo -n "URL=" >> dev/log/plotpackages1_count.txt
echo -n $HUDSON_URL >> dev/log/plotpackages1_count.txt
echo -n "job/" >> dev/log/plotpackages1_count.txt
echo -n $JOB_NAME >> dev/log/plotpackages1_count.txt
echo -n "/" >> dev/log/plotpackages1_count.txt
echo $BUILD_NUMBER >> dev/log/plotpackages1_count.txt
echo -n "YVALUE=" > dev/log/plotpackages2_count.txt
wc -l dev/log/testpackages2_*|tail -1 | cut -f 1 -d 't' >> dev/log/plotpackages2_count.txt
echo -n "URL=" >> dev/log/plotpackages2_count.txt
echo -n $HUDSON_URL >> dev/log/plotpackages2_count.txt
echo -n "job/" >> dev/log/plotpackages2_count.txt
echo -n $JOB_NAME >> dev/log/plotpackages2_count.txt
echo -n "/" >> dev/log/plotpackages2_count.txt
echo $BUILD_NUMBER >> dev/log/plotpackages2_count.txt
;;
packagesload)
echo '=========OUTPUT START: testpackages without packages========='
cat `ls dev/log/testpackagesload1_*`
echo '=========OUTPUT END: testpackages without packages========='
echo '=========OUTPUT START: testpackages with autoloaded packages========='
cat `ls dev/log/testpackagesloadA_*`
echo '=========OUTPUT END: testpackages with autoloaded packages========='
echo -n "YVALUE=" > dev/log/plotpackagesload1_count.txt
wc -l `ls dev/log/testpackagesload1_*|tail -1` | cut -f 1 -d ' ' >> dev/log/plotpackagesload1_count.txt
echo -n "URL=" >> dev/log/plotpackagesload1_count.txt
echo -n $HUDSON_URL >> dev/log/plotpackagesload1_count.txt
echo -n "job/" >> dev/log/plotpackagesload1_count.txt
echo -n $JOB_NAME >> dev/log/plotpackagesload1_count.txt
echo -n "/" >> dev/log/plotpackagesload1_count.txt
echo $BUILD_NUMBER >> dev/log/plotpackagesload1_count.txt
echo -n "YVALUE=" > dev/log/plotpackagesloadA_count.txt
wc -l `ls dev/log/testpackagesloadA_*|tail -1` | cut -f 1 -d ' ' >> dev/log/plotpackagesloadA_count.txt
echo -n "URL=" >> dev/log/plotpackagesloadA_count.txt
echo -n $HUDSON_URL >> dev/log/plotpackagesloadA_count.txt
echo -n "job/" >> dev/log/plotpackagesloadA_count.txt
echo -n $JOB_NAME >> dev/log/plotpackagesloadA_count.txt
echo -n "/" >> dev/log/plotpackagesloadA_count.txt
echo $BUILD_NUMBER >> dev/log/plotpackagesloadA_count.txt
;;
esac
echo '=========OUTPUT FINISHED========='