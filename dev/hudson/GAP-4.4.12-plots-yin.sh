#!/bin/bash
rm *
if [ -f /mnt/raid/hudson-slave/workspace/GAP-4.4.12/GAPCOPTS/32build/GAPTARGET/install/label/64bit/gap4r4/dev/log/plotinstall1_time.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-4.4.12/GAPCOPTS/32build/GAPTARGET/install/label/64bit/gap4r4/dev/log/plotinstall1_time.txt 32bit-testinstall-nopackages
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-4.4.12/GAPCOPTS/32build/GAPTARGET/install/label/64bit/gap4r4/dev/log/plotinstall2_time.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-4.4.12/GAPCOPTS/32build/GAPTARGET/install/label/64bit/gap4r4/dev/log/plotinstall2_time.txt 32bit-testinstall-allpackages
fi

if [ -f /mnt/raid/hudson-slave/workspace/GAP-4.4.12/GAPCOPTS/64build/GAPTARGET/install/label/64bit/gap4r4/dev/log/plotinstall1_time.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-4.4.12/GAPCOPTS/64build/GAPTARGET/install/label/64bit/gap4r4/dev/log/plotinstall1_time.txt 64bit-testinstall-nopackages
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-4.4.12/GAPCOPTS/64build/GAPTARGET/install/label/64bit/gap4r4/dev/log/plotinstall2_time.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-4.4.12/GAPCOPTS/64build/GAPTARGET/install/label/64bit/gap4r4/dev/log/plotinstall2_time.txt 64bit-testinstall-allpackages
fi

if [ -f /mnt/raid/hudson-slave/workspace/GAP-4.4.12/GAPCOPTS/32build/GAPTARGET/standard/label/64bit/gap4r4/dev/log/plotstandard1_time.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-4.4.12/GAPCOPTS/32build/GAPTARGET/standard/label/64bit/gap4r4/dev/log/plotstandard1_time.txt 32bit-teststandard-nopackages
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-4.4.12/GAPCOPTS/32build/GAPTARGET/standard/label/64bit/gap4r4/dev/log/plotstandard2_time.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-4.4.12/GAPCOPTS/32build/GAPTARGET/standard/label/64bit/gap4r4/dev/log/plotstandard2_time.txt 32bit-teststandard-allpackages
fi

if [ -f /mnt/raid/hudson-slave/workspace/GAP-4.4.12/GAPCOPTS/64build/GAPTARGET/standard/label/64bit/gap4r4/dev/log/plotstandard1_time.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-4.4.12/GAPCOPTS/64build/GAPTARGET/standard/label/64bit/gap4r4/dev/log/plotstandard1_time.txt 64bit-teststandard-nopackages
fi
if [ -f /mnt/raid/hudson-slave/workspace/GAP-4.4.12/GAPCOPTS/64build/GAPTARGET/standard/label/64bit/gap4r4/dev/log/plotstandard2_time.txt ] 
then
cp /mnt/raid/hudson-slave/workspace/GAP-4.4.12/GAPCOPTS/64build/GAPTARGET/standard/label/64bit/gap4r4/dev/log/plotstandard2_time.txt 64bit-teststandard-allpackages
fi