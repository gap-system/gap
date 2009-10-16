#!/bin/bash
cp -r ../alnuth /tmp  
DIR=/tmp/alnuth
cd $DIR

# remove tilde files
find . -iname \*~ | xargs -r -n 20 rm -f

# remove CVS stuff
find . -iname CVS | xargs -r -n 20 rm -rf

# remove TODO files
find . -iname TODO | xargs -r -n 20 rm -f

# remove unnecessary doc files
cd $DIR/doc
rm   manual.ind  manual.ps  manual.blg  fields.dvi manual.dvi manual.log fields.log   manual.aux   manual.idx   manual.bbl   manual.ilg  

# remove yourself
cd $DIR
rm pack-alnuth.sh 

# create tar archive and compress it
cd /tmp
VERS=2.2.5
tar cf Alnuth-$VERS.tar alnuth
gzip -9 Alnuth-$VERS.tar
tar cf Alnuth-$VERS.tar alnuth

# assemble all necessary files
mkdir Alnuth
mv Alnuth-$VERS.tar Alnuth
mv Alnuth-$VERS.tar.gz Alnuth
cp alnuth/README Alnuth
cp alnuth/PackageInfo.g Alnuth
mv alnuth Alnuth

# copy the files to cayley
#scp -r /tmp/Alnuth/* assmann@cayley.math.nat.tu-bs.de:/usr/local/httpd/htdocs/software/assmann/Alnuth
 
# copy the files to new place
#scp -r /tmp/Alnuth/* y0018612@brauer.math.nat.tu-bs.de:/afs/tu-bs.de/www/inst/icm/html/ag_algebra/software/assmann/Alnuth

rsync --delete --verbose --progress --stats --compress --rsh=/usr/bin/ssh  --recursive --times --perms --links  /tmp/Alnuth/* bjoern@home-rsch.cs.st-andrews.ac.uk:~/public_html/software/Alnuth/

# remove the unnecessary diretory
rm -r /tmp/Alnuth
   #rm Alnuth-$VERS.*
