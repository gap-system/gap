#!/bin/bash

for GTEST in install standard 
do
for GBITS in 32 64 
do
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}1_time.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}1_time.txt ${GBITS}bit-nogmp-test${GTEST}-nopackages
fi
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}2_time.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}2_time.txt ${GBITS}bit-nogmp-test${GTEST}-allpackages
fi
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}1_time.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}1_time.txt ${GBITS}bit-gmp-test${GTEST}-nopackages
fi
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}2_time.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}2_time.txt ${GBITS}bit-gmp-test${GTEST}-allpackages
fi
#
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}1_count.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}1_count.txt ${GBITS}bit-nogmp-test${GTEST}-nopackages-count
fi
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}2_count.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}2_count.txt ${GBITS}bit-nogmp-test${GTEST}-allpackages-count
fi
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}1_count.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}1_count.txt ${GBITS}bit-gmp-test${GTEST}-nopackages-count
fi
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}2_count.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}2_count.txt ${GBITS}bit-gmp-test${GTEST}-allpackages-count
fi
done
done

export GTEST="standard"
for ONETEST in arithlst hash2 primsan xgap grppcnrm grpmat grpperm matrix grplatt bugfix grpprmcs grpconst 
do
for GBITS in 32 64 
do
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${ONETEST}1.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${ONETEST}1.txt ${GBITS}bit-nogmp-${ONETEST}-nopackages
fi
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${ONETEST}2.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${ONETEST}2.txt ${GBITS}bit-nogmp-${ONETEST}-allpackages
fi
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${ONETEST}1.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${ONETEST}1.txt ${GBITS}bit-gmp-${ONETEST}-nopackages
fi
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${ONETEST}2.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${ONETEST}2.txt ${GBITS}bit-gmp-${ONETEST}-allpackages
fi
done
done

export GTEST="manuals"
for GBITS in 32 64 
do
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}1_count.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}1_count.txt ${GBITS}bit-nogmp-test${GTEST}-nopackages-count
fi
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}A_count.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}A_count.txt ${GBITS}bit-nogmp-test${GTEST}-autopackages-count
fi
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}2_count.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}2_count.txt ${GBITS}bit-nogmp-test${GTEST}-allpackages-count
fi
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}1_count.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}1_count.txt ${GBITS}bit-gmp-test${GTEST}-nopackages-count
fi
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}A_count.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}A_count.txt ${GBITS}bit-gmp-test${GTEST}-autopackages-count
fi
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}2_count.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}2_count.txt ${GBITS}bit-gmp-test${GTEST}-allpackages-count
fi
done


export GTEST="packages"
for GBITS in 32 64 
do
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}1_count.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}1_count.txt ${GBITS}bit-nogmp-test${GTEST}-nopackages-count
fi
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}2_count.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}2_count.txt ${GBITS}bit-nogmp-test${GTEST}-allpackages-count
fi
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}1_count.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}1_count.txt ${GBITS}bit-gmp-test${GTEST}-nopackages-count
fi
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}2_count.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}2_count.txt ${GBITS}bit-gmp-test${GTEST}-allpackages-count
fi
done


export GTEST="packagesload"
for GBITS in 32 64 
do
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}1_count.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}1_count.txt ${GBITS}bit-nogmp-test${GTEST}-nopackages-count
fi
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}A_count.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}A_count.txt ${GBITS}bit-nogmp-test${GTEST}-autopackages-count
fi
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}1_count.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}1_count.txt ${GBITS}bit-gmp-test${GTEST}-nopackages-count
fi
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}A_count.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}A_count.txt ${GBITS}bit-gmp-test${GTEST}-autopackages-count
fi
done

export GTEST="packagesload"
for GBITS in 32 64 
do
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}fail.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/nogmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}fail.txt ${GBITS}bit-nogmp-test${GTEST}fail
fi
if [ -f ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}fail.txt ] 
then
cp ${JPATH}/${JJOB}/GAPCOPTS/${GBITS}build/GAPGMP/gmp/GAPTARGET/${GTEST}/label/${JLABEL}/${JLOGS}/plot${GTEST}fail.txt ${GBITS}bit-gmp-test${GTEST}fail
fi
done