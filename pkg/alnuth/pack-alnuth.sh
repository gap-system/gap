#!/bin/bash
if [ $# -lt 1 ] 
then 
echo "Die Versionsnummer fehlt!"
exit 1
fi

### copy to temporary directory
cp -r ../alnuth /tmp  
DIR=/tmp/alnuth
cd $DIR

### remove files

# remove .# files
find . -iname *\.#* | xargs -r -n 20 rm -f

# remove tilde files
find . -iname \*~ | xargs -r -n 20 rm -f

# remove CVS stuff
find . -iname CVS | xargs -r -n 20 rm -rf

# remove TODO files
find . -iname TODO | xargs -r -n 20 rm -f

# remove unnecessary doc files
cd $DIR/doc
rm manual.dvi manual.example*.tst
# files to delete from Alex K. email dated 30/09/2011
rm manual.aux manual.bbl manual.blg manual.idx manual.ilg manual.log  
# remove old (?) tthmacros.tex file
rm tthmacros.tex

# remove old kant files in lib
cd $DIR
rm -rf lib

# remove old compatibility file
cd $DIR/gap
rm compat.g

# remove yourself
cd $DIR
rm pack-alnuth.sh 

### create archives
cd /tmp

# rename including version number
mv alnuth Alnuth-$1

# create gzipped tar-archive 
tar cf alnuth.tar Alnuth-$1
gzip -9 alnuth.tar

# create tar-archive
tar cf alnuth.tar Alnuth-$1

# create win.zip-archive
find Alnuth-$1 | zip -9 -l alnuth-win.zip -@
# make sure binary files are not ruined by line break style change
zip -d alnuth-win.zip Alnuth-$1/doc/manual.pdf Alnuth-$1/doc/manual.ps Alnuth-$1/doc/manual.dvi
zip -9 alnuth-win.zip Alnuth-$1/doc/manual.pdf Alnuth-$1/doc/manual.ps Alnuth-$1/doc/manual.dvi

# change back to original name
mv Alnuth-$1 alnuth

### assemble all necessary files
mkdir Alnuth
mv alnuth.tar Alnuth
mv alnuth.tar.gz Alnuth
mv alnuth-win.zip Alnuth
cp alnuth/GPL Alnuth
cp alnuth/README Alnuth
cp alnuth/PackageInfo.g Alnuth
cp alnuth/doc/manual.ps Alnuth
cp alnuth/doc/manual.pdf Alnuth
mv alnuth Alnuth

### copy the files to webserver
rsync --delete --verbose --progress --stats --compress --rsh=/usr/bin/ssh  --recursive --times --perms --links  /tmp/Alnuth/* anddistl@www.icm.tu-bs.de:/var/www/html/ag_algebra/software/Alnuth/

### create numbered archives
cd Alnuth
mv alnuth.tar Alnuth-$1.tar
mv alnuth.tar.gz Alnuth-$1.tar.gz
mv alnuth-win.zip Alnuth-$1-win.zip

### copy numbered archives to webserver
rsync --delete --verbose --progress --stats --compress --rsh=/usr/bin/ssh  --recursive --times --perms --links  /tmp/Alnuth/Alnuth-$1* anddistl@www.icm.tu-bs.de:/var/www/html/ag_algebra/software/Alnuth/Archives/

### remove the unnecessary diretory
cd /tmp
rm -r /tmp/Alnuth

#### OLD ####
# copy the files to cayley
#scp -r /tmp/Alnuth/* assmann@cayley.math.nat.tu-bs.de:/usr/local/httpd/htdocs/software/assmann/Alnuth
 
# copy the files to new place
#scp -r /tmp/Alnuth/* y0018612@brauer.math.nat.tu-bs.de:/afs/tu-bs.de/www/inst/icm/html/ag_algebra/software/assmann/Alnuth

   #rm Alnuth-$VERS.*
