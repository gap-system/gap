#!/bin/bash
rm *

# timing in testinstall 32-bit mode

if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall1_time.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall1_time.txt 32bit-nogmp-testinstall-nopackages
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall2_time.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall2_time.txt 32bit-nogmp-testinstall-allpackages
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall1_time.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall1_time.txt 32bit-gmp-testinstall-nopackages
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall2_time.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall2_time.txt 32bit-gmp-testinstall-allpackages
fi

# timing in testinstall 64-bit mode

if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall1_time.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall1_time.txt 64bit-nogmp-testinstall-nopackages
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall2_time.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall2_time.txt 64bit-nogmp-testinstall-allpackages
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall1_time.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall1_time.txt 64bit-gmp-testinstall-nopackages
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall2_time.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall2_time.txt 64bit-gmp-testinstall-allpackages
fi

# timing in teststandard 32-bit mode

if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard1_time.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard1_time.txt 32bit-nogmp-teststandard-nopackages
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard2_time.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard2_time.txt 32bit-nogmp-teststandard-allpackages
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard1_time.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard1_time.txt 32bit-gmp-teststandard-nopackages
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard2_time.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard2_time.txt 32bit-gmp-teststandard-allpackages
fi

# timing in teststandard 64-bit mode

if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard1_time.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard1_time.txt 64bit-nogmp-teststandard-nopackages
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard2_time.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard2_time.txt 64bit-nogmp-teststandard-allpackages
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard1_time.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard1_time.txt 64bit-gmp-teststandard-nopackages
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard2_time.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard2_time.txt 64bit-gmp-teststandard-allpackages
fi

# number of lines in testinstall 32-bit mode

if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall1_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall1_count.txt 32bit-nogmp-testinstall-nopackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall2_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall2_count.txt 32bit-nogmp-testinstall-allpackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall1_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall1_count.txt 32bit-gmp-testinstall-nopackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall2_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall2_count.txt 32bit-gmp-testinstall-allpackages-count
fi

# number of lines in testinstall 64-bit mode

if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall1_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall1_count.txt 64bit-nogmp-testinstall-nopackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall2_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall2_count.txt 64bit-nogmp-testinstall-allpackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall1_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall1_count.txt 64bit-gmp-testinstall-nopackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall2_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/install/label/64bit/GAP-dev-snapshot/dev/log/plotinstall2_count.txt 64bit-gmp-testinstall-allpackages-count
fi

# number of lines in teststandard 32-bit mode

if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard1_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard1_count.txt 32bit-nogmp-teststandard-nopackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard2_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard2_count.txt 32bit-nogmp-teststandard-allpackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard1_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard1_count.txt 32bit-gmp-teststandard-nopackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard2_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard2_count.txt 32bit-gmp-teststandard-allpackages-count
fi

# number of lines in teststandard 64-bit mode

if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard1_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard1_count.txt 64bit-nogmp-teststandard-nopackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard2_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard2_count.txt 64bit-nogmp-teststandard-allpackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard1_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard1_count.txt 64bit-gmp-teststandard-nopackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard2_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/standard/label/64bit/GAP-dev-snapshot/dev/log/plotstandard2_count.txt 64bit-gmp-teststandard-allpackages-count
fi

# number of lines in testmanuals 32-bit mode

if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/manuals/label/64bit/GAP-dev-snapshot/dev/log/plotmanuals1_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/manuals/label/64bit/GAP-dev-snapshot/dev/log/plotmanuals1_count.txt 32bit-nogmp-testmanuals-nopackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/manuals/label/64bit/GAP-dev-snapshot/dev/log/plotmanualsA_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/manuals/label/64bit/GAP-dev-snapshot/dev/log/plotmanualsA_count.txt 32bit-nogmp-testmanuals-autopackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/manuals/label/64bit/GAP-dev-snapshot/dev/log/plotmanuals2_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/manuals/label/64bit/GAP-dev-snapshot/dev/log/plotmanuals2_count.txt 32bit-nogmp-testmanuals-allpackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/manuals/label/64bit/GAP-dev-snapshot/dev/log/plotmanuals1_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/manuals/label/64bit/GAP-dev-snapshot/dev/log/plotmanuals1_count.txt 32bit-gmp-testmanuals-nopackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/manuals/label/64bit/GAP-dev-snapshot/dev/log/plotmanualsA_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/manuals/label/64bit/GAP-dev-snapshot/dev/log/plotmanualsA_count.txt 32bit-gmp-testmanuals-autopackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/manuals/label/64bit/GAP-dev-snapshot/dev/log/plotmanuals2_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/manuals/label/64bit/GAP-dev-snapshot/dev/log/plotmanuals2_count.txt 32bit-gmp-testmanuals-allpackages-count
fi

# number of lines in testmanuals 64-bit mode

if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/manuals/label/64bit/GAP-dev-snapshot/dev/log/plotmanuals1_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/manuals/label/64bit/GAP-dev-snapshot/dev/log/plotmanuals1_count.txt 64bit-nogmp-testmanuals-nopackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/manuals/label/64bit/GAP-dev-snapshot/dev/log/plotmanualsA_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/manuals/label/64bit/GAP-dev-snapshot/dev/log/plotmanualsA_count.txt 64bit-nogmp-testmanuals-autopackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/manuals/label/64bit/GAP-dev-snapshot/dev/log/plotmanuals2_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/manuals/label/64bit/GAP-dev-snapshot/dev/log/plotmanuals2_count.txt 64bit-nogmp-testmanuals-allpackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/manuals/label/64bit/GAP-dev-snapshot/dev/log/plotmanuals1_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/manuals/label/64bit/GAP-dev-snapshot/dev/log/plotmanuals1_count.txt 64bit-gmp-testmanuals-nopackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/manuals/label/64bit/GAP-dev-snapshot/dev/log/plotmanualsA_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/manuals/label/64bit/GAP-dev-snapshot/dev/log/plotmanualsA_count.txt 64bit-gmp-testmanuals-autopackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/manuals/label/64bit/GAP-dev-snapshot/dev/log/plotmanuals2_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/manuals/label/64bit/GAP-dev-snapshot/dev/log/plotmanuals2_count.txt 64bit-gmp-testmanuals-allpackages-count
fi

# number of lines in testpackages 32-bit mode

if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/packages/label/64bit/GAP-dev-snapshot/dev/log/plotpackages1_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/packages/label/64bit/GAP-dev-snapshot/dev/log/plotpackages1_count.txt 32bit-nogmp-testpackages-nopackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/packages/label/64bit/GAP-dev-snapshot/dev/log/plotpackages2_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/packages/label/64bit/GAP-dev-snapshot/dev/log/plotpackages2_count.txt 32bit-nogmp-testpackages-allpackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/packages/label/64bit/GAP-dev-snapshot/dev/log/plotpackages1_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/packages/label/64bit/GAP-dev-snapshot/dev/log/plotpackages1_count.txt 32bit-gmp-testpackages-nopackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/packages/label/64bit/GAP-dev-snapshot/dev/log/plotpackages2_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/packages/label/64bit/GAP-dev-snapshot/dev/log/plotpackages2_count.txt 32bit-gmp-testpackages-allpackages-count
fi

# number of lines in testpackages 64-bit mode

if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/packages/label/64bit/GAP-dev-snapshot/dev/log/plotpackages1_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/packages/label/64bit/GAP-dev-snapshot/dev/log/plotpackages1_count.txt 64bit-nogmp-testpackages-nopackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/packages/label/64bit/GAP-dev-snapshot/dev/log/plotpackages2_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/packages/label/64bit/GAP-dev-snapshot/dev/log/plotpackages2_count.txt 64bit-nogmp-testpackages-allpackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/packages/label/64bit/GAP-dev-snapshot/dev/log/plotpackages1_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/packages/label/64bit/GAP-dev-snapshot/dev/log/plotpackages1_count.txt 64bit-gmp-testpackages-nopackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/packages/label/64bit/GAP-dev-snapshot/dev/log/plotpackages2_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/packages/label/64bit/GAP-dev-snapshot/dev/log/plotpackages2_count.txt 64bit-gmp-testpackages-allpackages-count
fi

# number of lines in testpackagesload 32-bit mode

if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/packagesload/label/64bit/GAP-dev-snapshot/dev/log/plotpackagesload1_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/packagesload/label/64bit/GAP-dev-snapshot/dev/log/plotpackagesload1_count.txt 32bit-nogmp-testpackagesload-nopackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/packagesload/label/64bit/GAP-dev-snapshot/dev/log/plotpackagesloadA_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/nogmp/GAPTARGET/packagesload/label/64bit/GAP-dev-snapshot/dev/log/plotpackagesloadA_count.txt 32bit-nogmp-testpackagesload-autopackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/packagesload/label/64bit/GAP-dev-snapshot/dev/log/plotpackages1_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/packagesload/label/64bit/GAP-dev-snapshot/dev/log/plotpackages1_count.txt 32bit-gmp-testpackagesload-nopackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/packagesload/label/64bit/GAP-dev-snapshot/dev/log/plotpackagesloadA_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/32build/GAPGMP/gmp/GAPTARGET/packagesload/label/64bit/GAP-dev-snapshot/dev/log/plotpackagesloadA_count.txt 32bit-gmp-testpackagesload-autopackages-count
fi

# number of lines in testpackagesload 64-bit mode

if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/packagesload/label/64bit/GAP-dev-snapshot/dev/log/plotpackagesload1_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/packagesload/label/64bit/GAP-dev-snapshot/dev/log/plotpackagesload1_count.txt 64bit-nogmp-testpackagesload-nopackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/packagesload/label/64bit/GAP-dev-snapshot/dev/log/plotpackagesloadA_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/nogmp/GAPTARGET/packagesload/label/64bit/GAP-dev-snapshot/dev/log/plotpackagesloadA_count.txt 64bit-nogmp-testpackagesload-autopackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/packagesload/label/64bit/GAP-dev-snapshot/dev/log/plotpackagesload1_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/packagesload/label/64bit/GAP-dev-snapshot/dev/log/plotpackagesload1_count.txt 64bit-gmp-testpackagesload-nopackages-count
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/packagesload/label/64bit/GAP-dev-snapshot/dev/log/plotpackagesloadA_count.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-dev/GAPCOPTS/64build/GAPGMP/gmp/GAPTARGET/packagesload/label/64bit/GAP-dev-snapshot/dev/log/plotpackagesloadA_count.txt 64bit-gmp-testpackagesload-autopackages-count
fi