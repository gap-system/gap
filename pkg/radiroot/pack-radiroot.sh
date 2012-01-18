#!/bin/bash
if [ $# -lt 1 ] 
then 
echo "Die Versionsnummer fehlt!"
exit 1
fi

### copy to temporary directory
cp -r ../radiroot /tmp  
DIR=/tmp/radiroot
cd $DIR

### remove old emacs files and CVS directories

# remove # files
find . -iname *\#* | xargs -r -n 20 rm -f

# remove tilde files
find . -iname \*~ | xargs -r -n 20 rm -f

# remove CVS stuff
find . -iname CVS | xargs -r -n 20 rm -rf
find . -iname .cvsignore | xargs -r -n 20 rm -rf

# remove unnecessary doc files
cd $DIR/doc
rm manual.dvi manual.example*.tst
# files to delete from Alex K. email dated 30/09/2011
rm manual.aux manual.bbl manual.blg manual.idx manual.ilg manual.log manual.ps 
# remove old (?) tthmacros.tex file
rm tthmacros.tex tthout

# remove yourself
cd $DIR
rm pack-radiroot.sh 

# create tar archive and compress it
cd /tmp
tar cf radiroot-$1.tar radiroot
gzip -9 radiroot-$1.tar
tar cf radiroot-$1.tar radiroot

# assemble all necessary files
mkdir Radiroot
mv radiroot-$1.tar Radiroot
mv radiroot-$1.tar.gz Radiroot
cp radiroot/README Radiroot
cp radiroot/PackageInfo.g Radiroot
mv radiroot Radiroot

# copy the files to webserver
rsync --delete --verbose --progress --stats --compress --rsh=/usr/bin/ssh  --recursive --times --perms --links  /tmp/Radiroot/* anddistl@www.icm.tu-bs.de:/var/www/html/ag_algebra/software/radiroot/

#cp -r /tmp/Radiroot/* ~/Destination
 
# remove the unnecessary diretory
rm -r /tmp/Radiroot
#rm radiroot-$1.*
