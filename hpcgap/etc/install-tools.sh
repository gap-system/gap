#!/bin/sh
#############################################################################
##
##  
## This script unpacks the tools.tar.gz archive which contains some utilities 
## mainly for package authors (preparing documentation and archives, ...). 
##
## The content of the archive will go to the 'doc' and 'dev' subdirectories
## of the GAP root directory. To ensure that they will go to the correct 
## destination, run this script *ONLY* from the 'etc' directory where it is
## located (same directory with the tools.tar.gz archive).

if [ -f tools.tar.gz ] 
then
echo '============================================================================'
echo 'Unpacking tools.tar.gz archive ...'
tar -xvzf tools.tar.gz -C ../
echo 'Done!'
echo '============================================================================'
else
echo '============================================================================'
echo 'Error in install-tools.sh: can not find tools.tar.gz archive!'
echo 'Please run install-tools.sh from the dev directory of your GAP installation!'
echo '============================================================================'
fi


