#!bin/bash
rm -f html/CHAP???.html
rm -f html/biblio.html
rm -f html/theindex.html
rm -f html/chapters.html
perl ../../etc/convert.pl -n IRREDSOL -c -i doc html
chmod -R a+r html
