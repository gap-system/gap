#############################################################################
##
#W  strings.tst                GAP tests                  Alexander Konovalov
##
##  This file tests output methods (mainly for strings)
##
##  To be listed in testinstall.g
##
gap> START_TEST("strings.tst");

# FFE
gap> x:=Z(2);
Z(2)^0
gap> Display(x);
Z(2)^0
gap> ViewObj(x);Print("\n");
Z(2)^0
gap> PrintObj(x);Print("\n");
Z(2)^0
gap> DisplayString(x);
"Z(2)^0\n"
gap> ViewString(x);
"Z(2)^0"
gap> PrintString(x);
"Z(2)^0"
gap> String(x);
"Z(2)^0"

# String
gap> x:="abc";
"abc"
gap> Display(x);
abc
gap> ViewObj(x);Print("\n");
"abc"
gap> PrintObj(x);Print("\n");
"abc"
gap> DisplayString(x);
"abc\n"
gap> ViewString(x);
"\"abc\""
gap> PrintString(x);
"abc"
gap> String(x);
"abc"

# Empty string
gap> x:="";
""
gap> Display(x);

gap> ViewObj(x);Print("\n");
""
gap> PrintObj(x);Print("\n");
""
gap> DisplayString(x);
"\n"
gap> ViewString(x);
"\"\""
gap> PrintString(x);
""
gap> String(x);
""

# Empty list
gap> x:=[];
[  ]
gap> Display(x);
[  ]
gap> ViewObj(x);Print("\n");
[  ]
gap> PrintObj(x);Print("\n");
[  ]
gap> DisplayString(x);
"[  ]\n"
gap> ViewString(x);
"[  ]"
gap> PrintString(x);
"[ ]"
gap> String(x);
"[ ]"

# List
gap> x:=[1,2,3];
[ 1, 2, 3 ]
gap> Display(x);
[ 1, 2, 3 ]
gap> ViewObj(x);Print("\n");
[ 1, 2, 3 ]
gap> PrintObj(x);Print("\n");
[ 1, 2, 3 ]
gap> DisplayString(x);
"<object>\n"
gap> ViewString(x);
"[ 1,\<\> 2,\<\> 3 ]"
gap> PrintString(x);
"[ 1, 2, 3 ]"
gap> String(x);
"[ 1, 2, 3 ]"

# Character
gap> x:='a';
'a'
gap> Display(x);
'a'
gap> ViewObj(x);Print("\n");
'a'
gap> PrintObj(x);Print("\n");
'a'
gap> DisplayString(x);
"'a'\n"
gap> ViewString(x);
"'a'"
gap> PrintString(x);
"'a'"
gap> String(x);
"'a'"
gap> STOP_TEST( "strings.tst", 100000 );
