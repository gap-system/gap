#!/bin/bash
cp -r ../radiroot /tmp  
DIR=/tmp/radiroot
cd $DIR

#remove old emacs files and CVS directories
rm *.*~
rm -r CVS
cd $DIR/lib
rm *.*~
rm -r CVS
cd $DIR/doc
rm *.*~
rm -r CVS
cd $DIR/tst
rm *.*~
rm -r CVS

# remove unnecessary doc files
cd $DIR/doc
rm   manual.ind  manual.blg  manual.dvi manual.log  manual.aux   manual.idx   manual.bbl   manual.ilg  
# manual.ps

# remove yourself
cd $DIR
rm pack-radiroot.sh 

# create tar archive and compress it
cd /tmp
VERS=2.3
tar cf radiroot-$VERS.tar radiroot
gzip -9 radiroot-$VERS.tar
tar cf radiroot-$VERS.tar radiroot

# assemble all necessary files
mkdir Radiroot
mv radiroot-$VERS.tar Radiroot
mv radiroot-$VERS.tar.gz Radiroot
cp radiroot/README Radiroot
cp radiroot/PackageInfo.g Radiroot
mv radiroot Radiroot

# copy the files to cayley
#scp -r /tmp/Alnuth/* assmann@cayley.math.nat.tu-bs.de:/usr/local/httpd/htdocs/software/assmann/Alnuth
 
# copy the files to new place
scp -r /tmp/Radiroot/* y0018612@brauer.math.nat.tu-bs.de:/afs/tu-bs.de/www/inst/icm/html/ag_algebra/software/distler/radiroot
#cp -r /tmp/Radiroot/* /afs/tu-bs.de/www/inst/icm/html/ag_algebra/software/distler/radiroot

#cp -r /tmp/Radiroot/* ~/Destination
 
# remove the unnecessary diretory
rm -r /tmp/Radiroot
#rm radiroot-$VERS.*
