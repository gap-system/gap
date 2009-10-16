#!/bin/csh
set tarfile = irredsol/irredsol-$1.tar
if ($tarfile == irredsol/irredsol-.tar) then
   echo "Version number expected";
   exit;
endif

# this suppresses resouce forks in tarballs
setenv COPY_EXTENDED_ATTRIBUTES_DISABLE 1

cd ../
rm -f $tarfile
rm -f $tarfile.bz2
chmod -R a+rX irredsol

set libfiles = (access.gd access.gi iterators.gd iterators.gi loadfp.gd loadfp.gi \
   loading.gd loading.gi matmeths.gd matmeths.gi primitive.gd primitive.gi \
   recognize.gd recognize.gi util.gd util.gi obsolete.gd obsolete.gi)

set docfiles = (manual.tex overview.tex access.tex matgroups.tex \
    primitive.tex recognition.tex)
    
set manfiles = (.bbl .ind .idx .six .pdf .mst .toc)

set testfiles = (test.tst)

tar -c -f $tarfile irredsol/PackageInfo.g 
tar -r -f $tarfile irredsol/init.g 
tar -r -f $tarfile irredsol/read.g 

foreach file ($libfiles)
   tar -r -f $tarfile irredsol/lib/$file 
end

foreach file ($docfiles)
   tar -r -f $tarfile irredsol/doc/$file 
end

foreach file ($manfiles)
   tar -r -f $tarfile irredsol/doc/manual$file 
end

foreach file ($testfiles)
   tar -r -f $tarfile irredsol/tst/$file 
end

foreach file (irredsol/htm/*.htm)
	tar -r -f $tarfile $file 
end

foreach file (irredsol/data/*.grp)
	tar -r -f $tarfile $file 
end

foreach file (irredsol/fp/*.idx)
	tar -r -f $tarfile $file 
end

foreach file (irredsol/fp/*.fp)
	tar -r -f $tarfile $file 
end

tar -r -f $tarfile irredsol/README 


bzip2  $tarfile 




