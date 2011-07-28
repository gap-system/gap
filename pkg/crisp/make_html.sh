rm html/CHAP???.htm
rm html/biblio.htm
rm html/theindex.htm
rm html/chapters.htm
perl ../../etc/convert.pl -n CRISP -c -i doc html
chmod -R a+r html
