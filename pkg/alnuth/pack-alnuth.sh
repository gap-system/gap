#!/bin/bash
if [ $# -lt 1 ] 
then 
echo "Die Versionsnummer fehlt!"
exit 1
fi

cp -r ../alnuth /tmp  
DIR=/tmp/alnuth
cd $DIR

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
rm   manual.ind  manual.ps  manual.blg  fields.dvi manual.dvi manual.log fields.log   manual.aux   manual.idx   manual.bbl   manual.ilg  

# remove old kant files in lib
cd $DIR
rm -rf lib

# remove yourself
cd $DIR
rm pack-alnuth.sh 

# create tar archive and compress it
cd /tmp
tar cf alnuth.tar alnuth
gzip -9 alnuth.tar
tar cf alnuth.tar alnuth

# assemble all necessary files
mkdir Alnuth
mv alnuth.tar Alnuth
mv alnuth.tar.gz Alnuth
cp alnuth/README Alnuth
cp alnuth/PackageInfo.g Alnuth
mv alnuth Alnuth

# copy the files to webserver
rsync --delete --verbose --progress --stats --compress --rsh=/usr/bin/ssh  --recursive --times --perms --links  /tmp/Alnuth/* anddistl@www.icm.tu-bs.de:/var/www/html/ag_algebra/software/Alnuth/

# create numbered archives
cd Alnuth
mv alnuth.tar Alnuth-$1.tar
mv alnuth.tar.gz Alnuth-$1.tar.gz

# copy numbered archives to webserver
rsync --delete --verbose --progress --stats --compress --rsh=/usr/bin/ssh  --recursive --times --perms --links  /tmp/Alnuth/Alnuth-$1.tar* anddistl@www.icm.tu-bs.de:/var/www/html/ag_algebra/software/Alnuth/archives/

# remove the unnecessary diretory
rm -r /tmp/Alnuth

#### OLD ####
# copy the files to cayley
#scp -r /tmp/Alnuth/* assmann@cayley.math.nat.tu-bs.de:/usr/local/httpd/htdocs/software/assmann/Alnuth
 
# copy the files to new place
#scp -r /tmp/Alnuth/* y0018612@brauer.math.nat.tu-bs.de:/afs/tu-bs.de/www/inst/icm/html/ag_algebra/software/assmann/Alnuth

   #rm Alnuth-$VERS.*
