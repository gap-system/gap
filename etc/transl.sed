# This is a simple-minded converter that can ease translation from a GAP3
# manual file to a GAP4 manual file. Further Hand-Editing is almost
# certainly needed!
# usage: sed -f transl.sed <oldfile >newfile
/^%H[ -z]*/d
1,$s/ $//g
1,$s/\\\\$/\
/g
1,$s/ $//g
1,$s/%$//g
1,$s/'\\\\$/'/g
1,$s/^|    /\\beginexample\
/g
1,$s/^|   /\\beginexample\
/g
1,$s/^|  /\\beginexample\
/g
1,$s/^| /\\beginexample\
/g
1,$s/^|/\\beginexample\
/g
1,$s/|$/\
\\endexample/g
1,$s/^    //g
1,$s/ '/ `/g
1,$s/^'/`/g
1,$s/^`\([ -z]*\)'$/\\>\1/g
1,$s/\\\*/*/g
1,$s/\\ / /g
