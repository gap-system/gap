rm -f htm/CHAP???.htm
rm -f htm/biblio.htm
rm -f htm/theindex.htm
rm -f htm/chapters.htm
perl ../../etc/convert.pl -n IRREDSOL -c -i doc htm
chmod -R a+r htm
