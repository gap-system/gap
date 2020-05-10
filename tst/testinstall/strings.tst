#############################################################################
##
##  This file tests output methods (mainly for strings)
##
#@local x, str, len
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
gap> "\0x4a";
"J"
gap> x:="\0x4A";
"J"
gap> x:="\0x42\0x23\0x10\0x10\0x10";
"B#\020\020\020"
gap> PrintString(x);
"B#\020\020\020"
gap> ViewString(x);
"\"B#\\020\\020\\020\""
gap> x:="A string with Hex stuff \0x42 in it";
"A string with Hex stuff B in it"
gap> PrintString(x);
"A string with Hex stuff B in it"
gap> ViewString(x);
"\"A string with Hex stuff B in it\""
gap> x := "\n\t\c\\\"'";
"\n\t\c\\\"'"
gap> PrintString(x);
"\n\t\c\\\"'"
gap> ViewString(x);
"\"\\n\\t\\c\\\\\\\"'\""
gap> "\0yab";
Syntax error: Expecting hexadecimal escape, or two more octal digits in stream\
:1
"\0yab";
^^^
gap> "\090";
Syntax error: Expecting hexadecimal escape, or two more octal digits in stream\
:1
"\090";
^^^
gap> "\009";
Syntax error: Expecting octal digit in stream:1
"\009";
^^^^
gap> "\0x1g";
Syntax error: Expecting hexadecimal digit in stream:1
"\0x1g";
^^^^^
gap> '\0x1bc';
Syntax error: Missing single quote in character constant in stream:1
'\0x1bc';
^^^^^^
gap> "\0x1bc";
"\033c"
gap> '
Syntax error: Character literal must not include <newline> in stream:1
'
^
gap> "
Syntax error: String must not include <newline> in stream:1
"
^
gap> "abc" + "def";
Error, concatenating strings via + is not supported, use Concatenation(<a>,<b>\
) instead

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

# Dense list
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
"\>\>[ \>\>1\<,\< \>\>2\<,\< \>\>3 \<\<\<\<]"
gap> PrintString(x);
"[ 1, 2, 3 ]"
gap> String(x);
"[ 1, 2, 3 ]"

# Non-dense list
gap> x:= [ 1,, 3 ];
[ 1,, 3 ]
gap> Display( x );
[ 1,, 3 ]
gap> ViewObj( x ); Print( "\n" );
[ 1,, 3 ]
gap> PrintObj( x ); Print( "\n" );
[ 1,, 3 ]
gap> DisplayString( x );
"<object>\n"
gap> ViewString( x );
"\>\>[ \>\>1\<,\<\>\>\<,\< \>\>3 \<\<\<\<]"
gap> PrintString( x );
"[ 1, , 3 ]"
gap> String( x );
"[ 1, , 3 ]"

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
gap> '\0x42';
'B'
gap> '\102';
'B'
gap> '\0xFF';
'\377'
gap> '\0xff';
'\377'
gap> '\0xFf';
'\377'
gap> '\0xfF';
'\377'
gap> '\0xab';
'\253'

# Huge strings
gap> for len in [10,100,1000,10000,100000] do
> str := List([1..len], x -> 'a');
> Assert(0, Concatenation("\"",str,"\"") = ViewString(str));
> Assert(0, Concatenation(str,"\n") = DisplayString(str));
> od;;

#
gap> STOP_TEST( "strings.tst", 1);
