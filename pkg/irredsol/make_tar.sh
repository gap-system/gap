#!/bin/bash
tarfile=irredsol/irredsol-$1.tar
if [ "$tarfile" = "irredsol/irredsol-.tar" ]; then
   echo "Version number expected"
   exit
fi

   

# this suppresses extended attributes in tarballs
export COPY_EXTENDED_ATTRIBUTES_DISABLE=1
export COPYFILE_DISABLE=1

cd ../
rm -f $tarfile
rm -f $tarfile.bz2
chmod -R a+rX irredsol

libfiles="access.gd access.gi iterators.gd iterators.gi loadfp.gd loadfp.gi \
   loading.gd loading.gi matmeths.gd matmeths.gi primitive.gd primitive.gi \
   recognize.gd recognize.gi recognizeprim.gd recognizeprim.gi \
   util.g util.gd util.gi obsolete.gd obsolete.gi"

docfiles="manual.tex overview.tex access.tex matgroups.tex \
    primitive.tex recognition.tex"
    
manexts=".bbl .ind .idx .six .pdf .mst .toc"

testfiles="test.tst"

tar -c -f $tarfile irredsol/PackageInfo.g 
tar -r -f $tarfile irredsol/init.g 
tar -r -f $tarfile irredsol/read.g 

for file  in $libfiles
   do tar -r -f $tarfile irredsol/lib/$file 
done

for file in $docfiles
   do tar -r -f $tarfile irredsol/doc/$file 
done

for ext in $manexts
   do tar -r -f $tarfile irredsol/doc/manual$ext 
done

for file in $testfiles
   do tar -r -f $tarfile irredsol/tst/$file 
done

for file in irredsol/html/*.htm
	do tar -r -f $tarfile $file 
done

for file in irredsol/data/*.grp
	do tar -r -f $tarfile $file 
done

for file in irredsol/fp/*.idx
	do tar -r -f $tarfile $file 
done

for file in irredsol/fp/*.fp
	do tar -r -f $tarfile $file 
done

tar -r -f $tarfile irredsol/README 

bzip2 $tarfile 




