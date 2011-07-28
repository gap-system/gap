#!bin/bash
rm -f html/CHAP???.html
rm -f html/biblio.html
rm -f html/theindex.html
rm -f html/chapters.html
perl ../../etc/convert.pl -n IRREDSOL -c -i doc html
(cd html; for file in *.htm; do mv $file $file"l"; done)
chmod -R a+r html
