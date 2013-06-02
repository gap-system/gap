rm -rf *
curl -s -k -o gap4r4-snapshot.tar.bz2 https://gap:SL25=2A5@keith.cs.st-andrews.ac.uk:8443/job/GAP-4.4.12-snapshot/lastBuild/artifact/gap4r4-snapshot.tar.bz2
tar jxf gap4r4-snapshot.tar.bz2
cd gap4r4/

if [ $GAPCOPTS = '64build' ]
then
export CC=gcc
export COPTS=-m64
fi

./configure
make
cd pkg
curl -s -k -o InstPackages.sh http://www.gap-system.org/Download/InstPackages.sh
sed -e 's,/usr/bin/tcsh,'`which tcsh`',g' InstPackages.sh > InstPackages2.sh
sed -e 's,tar xzpf,tar --numeric-owner -xzpf,g' InstPackages2.sh > InstPackages3.sh
chmod u+x InstPackages3.sh
./InstPackages3.sh
rm -rf anupq
cd ..

make test$GAPTARGET

case $GAPTARGET in
install)
echo '=========OUTPUT START: testinstall without packages========='
cat `ls dev/log/testinstall1_*|tail -1`
echo '=========OUTPUT END: testinstall without packages========='
echo '=========OUTPUT START: testinstall with packages========='
cat `ls dev/log/testinstall2_*|tail -1`
echo '=========OUTPUT END: testinstall with packages========='
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
echo '=========OUTPUT START: testmanuals without packages========='
cat `ls dev/log/testmanuals1_*|tail -1`
echo '=========OUTPUT END: testmanuals without packages========='
echo '=========OUTPUT START: testmanuals with autoloaded packages========='
cat `ls dev/log/testmanualsA_*|tail -1`
echo '=========OUTPUT END: testmanuals with autoloaded packages========='
echo '=========OUTPUT START: testmanuals with all packages========='
cat `ls dev/log/testmanuals2_*|tail -1`
echo '=========OUTPUT END: testmanuals with all packages========='
;;
packages)
echo '=========OUTPUT START: testpackages without packages========='
cat `ls dev/log/testpackages1_*`
echo '=========OUTPUT END: testpackages without packages========='
echo '=========OUTPUT START: testpackages with all packages========='
cat `ls dev/log/testpackages2_*`
echo '=========OUTPUT END: testpackages with all packages========='
;;
packagesload)
echo '=========OUTPUT START: testpackages without packages========='
cat `ls dev/log/testpackagesload1_*`
echo '=========OUTPUT END: testpackages without packages========='
echo '=========OUTPUT START: testpackages with autoloaded packages========='
cat `ls dev/log/testpackagesloadA_*`
echo '=========OUTPUT END: testpackages with autoloaded packages========='
;;
esac
echo '=========OUTPUT FINISHED========='