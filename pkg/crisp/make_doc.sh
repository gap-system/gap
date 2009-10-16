#! /bin/sh
cd doc
tex manual
makeindex manual
tex manual
tex manual
pdftex manual
pdftex manual
cd ..

 

