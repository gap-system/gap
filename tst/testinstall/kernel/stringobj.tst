#
# Tests for functions defined in src/strinobj.c
#
gap> START_TEST("kernel/strinobj.tst");

#
gap> s := EmptyString(2);
""
gap> EmptyString(-1);
Error, <len> must be an non-negative integer (not a integer)

#
gap> ShrinkAllocationString(s);
gap> ShrinkAllocationString(1);
Error, <str> must be a string, not a integer)

#
gap> CHAR_INT(fail);
Error, <val> must be an integer (not a boolean or fail)
gap> CHAR_INT(-1);
Error, <val> must be an integer between 0 and 255
gap> CHAR_INT(65);
'A'

#
gap> INT_CHAR(1);
Error, <val> must be a character (not a integer)
gap> INT_CHAR('A');
65

#
gap> CHAR_SINT(fail);
Error, <val> must be an integer (not a boolean or fail)
gap> CHAR_SINT(255);
Error, <val> must be an integer between -128 and 127
gap> CHAR_SINT(65);
'A'

#
gap> SINT_CHAR(1);
Error, <val> must be a character (not a integer)
gap> SINT_CHAR('A');
65

#
gap> INTLIST_STRING("ABC", 1);
[ 65, 66, 67 ]
gap> INTLIST_STRING("ABC", -1);
[ 65, 66, 67 ]
gap> INTLIST_STRING(1, -1);
Error, <val> must be a string, not a integer)

#
gap> SINTLIST_STRING("ABC");
[ 65, 66, 67 ]
gap> SINTLIST_STRING(1);
Error, <val> must be a string, not a integer)

#
gap> STRING_SINTLIST([ 65, 66, 67 ]);
"ABC"
gap> STRING_SINTLIST([ 65 .. 67 ]);
"ABC"
gap> STRING_SINTLIST(1);
Error, <val> must be a plain list of small integers or a range, not a integer
gap> STRING_SINTLIST([ 'B' ]);
Error, <val> must be a plain list of small integers or a range, not a list (pl\
ain,hom)

#
gap> REVNEG_STRING(1);
Error, <val> must be a string, not a integer)

#
gap> CONV_STRING(1);
Error, ConvString: <string> must be a string (not a integer)

#
gap> COPY_TO_STRING_REP(1);
Error, CopyToStringRep: <string> must be a string (not a integer)

#
gap> POSITION_SUBSTRING("abc","x",0);
fail
gap> POSITION_SUBSTRING("abc","b",0);
2
gap> POSITION_SUBSTRING("abc","b",3);
fail
gap> POSITION_SUBSTRING(1,2,3);
Error, POSITION_SUBSTRING: <string> must be a string (not a integer)
gap> POSITION_SUBSTRING("abc",2,3);
Error, POSITION_SUBSTRING: <substr> must be a string (not a integer)
gap> POSITION_SUBSTRING("abc","b",-1);
Error, POSITION_SUBSTRING: <off> must be a non-negative integer (not a integer\
)

#
gap> s:="  abc\n  xyz\n";; NormalizeWhitespace(s); s;
"abc xyz"
gap> NormalizeWhitespace(1);
Error, NormalizeWhitespace: <string> must be a string (not a integer)

#
gap> s:="abcdabcd";; REMOVE_CHARACTERS(s, "db"); s;
"acac"
gap> REMOVE_CHARACTERS(1,1);
Error, RemoveCharacters: first argument <string> must be a string (not a integ\
er)
gap> REMOVE_CHARACTERS(s,1);
Error, RemoveCharacters: second argument <rem> must be a string (not a integer\
)

#
gap> s:="abc";; TranslateString(s,UPPERCASETRANSTABLE); s;
"ABC"
gap> TranslateString(1,1);
Error, TranslateString: first argument <string> must be a string (not a intege\
r)
gap> TranslateString("abc",1);
Error, TranslateString: second argument <trans> must be a string (not a intege\
r)
gap> TranslateString("abc","def");
Error, TranslateString: second argument <trans> must have length >= 256

#
gap> STOP_TEST("kernel/strinobj.tst", 1);
