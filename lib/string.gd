#############################################################################
##
#W  string.gd                   GAP library                      Frank Celler
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the declarations for functions for strings.
##


#############################################################################
##
#F  IsDigitChar( <c> )
##
##  <#GAPDoc Label="IsDigitChar">
##  <ManSection>
##  <Func Name="IsDigitChar" Arg='c'/>
##
##  <Description>
##  checks whether the character <A>c</A> is a digit,
##  i.e., occurs in the string <C>"0123456789"</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IsDigitChar" );


#############################################################################
##
#F  IsUpperAlphaChar( <c> )
##
##  <#GAPDoc Label="IsUpperAlphaChar">
##  <ManSection>
##  <Func Name="IsUpperAlphaChar" Arg='c'/>
##
##  <Description>
##  checks whether the character <A>c</A> is an uppercase alphabet letter,
##  i.e., occurs in the string <C>"ABCDEFGHIJKLMNOPQRSTUVWXYZ"</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IsUpperAlphaChar" );


#############################################################################
##
#F  IsLowerAlphaChar( <c> )
##
##  <#GAPDoc Label="IsLowerAlphaChar">
##  <ManSection>
##  <Func Name="IsLowerAlphaChar" Arg='c'/>
##
##  <Description>
##  checks whether the character <A>c</A> is a lowercase alphabet letter,
##  i.e., occurs in the string <C>"abcdefghijklmnopqrstuvwxyz"</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IsLowerAlphaChar" );


#############################################################################
##
#F  IsAlphaChar( <c> )
##
##  <#GAPDoc Label="IsAlphaChar">
##  <ManSection>
##  <Func Name="IsAlphaChar" Arg='c'/>
##
##  <Description>
##  checks whether the character <A>c</A> is either a lowercase or an
##  uppercase alphabet letter.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IsAlphaChar" );


##  <#GAPDoc Label="[2]{string}">
##  All calendar functions use the Gregorian calendar.
##  <#/GAPDoc>


#############################################################################
##
#F  DaysInYear( <year> )  . . . . . . . . .  days in a year, knows leap-years
##
##  <#GAPDoc Label="DaysInYear">
##  <ManSection>
##  <Func Name="DaysInYear" Arg='year'/>
##
##  <Description>
##  returns the number of days in the year <A>year</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DaysInYear" );


#############################################################################
##
#F  DaysInMonth( <month>, <year> )  . . . . days in a month, knows leap-years
##
##  <#GAPDoc Label="DaysInMonth">
##  <ManSection>
##  <Func Name="DaysInMonth" Arg='month, year'/>
##
##  <Description>
##  returns the number of days in month number <A>month</A> of <A>year</A>,
##  and <K>fail</K> if <C>month</C> is not in the valid range.
##  <Example><![CDATA[
##  gap> DaysInYear(1998);
##  365
##  gap> DaysInMonth(3,1998);
##  31
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DaysInMonth" );


#############################################################################
##
#F  DMYDay( <day> ) . . .  convert days since 01-Jan-1970 into day-month-year
##
##  <#GAPDoc Label="DMYDay">
##  <ManSection>
##  <Func Name="DMYDay" Arg='day'/>
##
##  <Description>
##  converts a number of days, starting 1-Jan-1970, to a list
##  <C>[ day, month, year ]</C> in Gregorian calendar counting.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DMYDay" );


#############################################################################
##
#F  DayDMY( <dmy> ) . . .  convert day-month-year into days since 01-Jan-1970
##
##  <#GAPDoc Label="DayDMY">
##  <ManSection>
##  <Func Name="DayDMY" Arg='dmy'/>
##
##  <Description>
##  returns the number of days from 01-Jan-1970 to the day given by
##  <A>dmy</A>, which must be a list of the form
##  <C>[ day, month, year ]</C> in Gregorian calendar counting.
##  The result is <K>fail</K> on input outside valid ranges.
##  <P/>
##  Note that this makes not much sense for early dates like: before 1582
##  (no Gregorian calendar at all), or before 1753 in many English speaking
##  countries or before 1917 in Russia.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DayDMY" );


#############################################################################
##
#F  SecondsDMYhms( <DMYhms> ) . . . . . convert day-month-year-hms into seconds
##
##  <#GAPDoc Label="SecondsDMYhms">
##  <ManSection>
##  <Func Name="SecondsDMYhms" Arg='DMYhms'/>
##
##  <Description>
##  returns the number of seconds from 01-Jan-1970, 00:00:00,
##  to the time given by <A>DMYhms</A>, which must be a list of the form
##  <C>[ day, month, year, hour, minute, second ]</C>.
##  The remarks on the Gregorian calendar in the section on
##  <Ref Func="DayDMY"/> apply here as well.
##  The last three arguments must lie in the appropriate ranges. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SecondsDMYhms" );


#############################################################################
##
#F  DMYhmsSeconds( <secs> ) . . . . . . . . . . . . . inverse of SecondsDMYhms
##
##  <#GAPDoc Label="DMYhmsSeconds">
##  <ManSection>
##  <Func Name="DMYhmsSeconds" Arg='secs'/>
##
##  <Description>
##  This is the inverse function to <Ref Func="SecondsDMYhms"/>.
##  <Example><![CDATA[
##  gap> SecondsDMYhms([ 9, 9, 2001, 1, 46, 40 ]);
##  1000000000
##  gap> DMYhmsSeconds(-1000000000);
##  [ 24, 4, 1938, 22, 13, 20 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DMYhmsSeconds" );

#############################################################################
##
#v  NamesWeekDay  . . . . . . . . . . . . . . . . . list of names of weekdays
##
##  is a list of abbreviated weekday names.
##
BindGlobal( "NameWeekDay",
    Immutable( ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"] ) );


#############################################################################
##
#F  WeekDay( <date> ) . . . . . . . . . . . . . . . . . . . weekday of a date
##
##  <#GAPDoc Label="WeekDay">
##  <ManSection>
##  <Func Name="WeekDay" Arg='date'/>
##
##  <Description>
##  returns the weekday of a day given by <A>date</A>, which can be a number
##  of days since 1-Jan-1970 or a list <C>[ day, month, year ]</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "WeekDay" );


#############################################################################
##
#v  NameMonth . . . . . . . . . . . . . . . . . . . . list of names of months
##
BindGlobal( "NameMonth",
    Immutable( [ "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                 "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ] ) );


#############################################################################
##
#F  StringDate( <date> )  . . . . . . . . convert date into a readable string
##
##  <#GAPDoc Label="StringDate">
##  <ManSection>
##  <Func Name="StringDate" Arg='date'/>
##
##  <Description>
##  converts <A>date</A> to a readable string.
##  <A>date</A> can be a number of days since 1-Jan-1970 or a list
##  <C>[ day, month, year ]</C>.
##  <Example><![CDATA[
##  gap> DayDMY([1,1,1970]);DayDMY([2,1,1970]);
##  0
##  1
##  gap> DMYDay(12345);
##  [ 20, 10, 2003 ]
##  gap> WeekDay([11,3,1998]);
##  "Wed"
##  gap> StringDate([11,3,1998]);
##  "11-Mar-1998"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "StringDate" );


#############################################################################
##
#F  HMSMSec( <msec> )  . . . . . . . .  convert seconds into hour-min-sec-mill
##
##  <#GAPDoc Label="HMSMSec">
##  <ManSection>
##  <Func Name="HMSMSec" Arg='msec'/>
##
##  <Description>
##  converts a number <A>msec</A> of milliseconds into a list
##  <C>[ hour, min, sec, milli ]</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "HMSMSec" );


#############################################################################
##
#F  SecHMSM( <hmsm> ) . . . . . . . . convert hour-min-sec-milli into seconds
##
##  <#GAPDoc Label="SecHMSM">
##  <ManSection>
##  <Func Name="SecHMSM" Arg='hmsm'/>
##
##  <Description>
##  is the reverse of <Ref Func="HMSMSec"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SecHMSM" );


#############################################################################
##
#F  StringTime( <time> )  . convert hour-min-sec-milli into a readable string
##
##  <#GAPDoc Label="StringTime">
##  <ManSection>
##  <Func Name="StringTime" Arg='time'/>
##
##  <Description>
##  converts <A>time</A> (given as a number of milliseconds or a list
##  <C>[ hour, min, sec, milli ]</C>) to a readable string.
##  <Example><![CDATA[
##  gap> HMSMSec(Factorial(10));
##  [ 1, 0, 28, 800 ]
##  gap> SecHMSM([1,10,5,13]);
##  4205013
##  gap> StringTime([1,10,5,13]);
##  " 1:10:05.013"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "StringTime" );


#############################################################################
##
#F  StringPP( <int> ) . . . . . . . . . . . . . . . . . . . . P1^E1 ... Pn^En
##
##  <#GAPDoc Label="StringPP">
##  <ManSection>
##  <Func Name="StringPP" Arg='int'/>
##
##  <Description>
##  returns a string representing the prime factor decomposition
##  of the integer <A>int</A>.
##  <Example><![CDATA[
##  gap> StringPP(40320);
##  "2^7*3^2*5*7"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "StringPP" );


############################################################################
##
#F  WordAlp( <alpha>, <nr> ) . . . . . .  <nr>-th word over alphabet <alpha>
##
##  <#GAPDoc Label="WordAlp">
##  <ManSection>
##  <Func Name="WordAlp" Arg='alpha, nr'/>
##
##  <Description>
##  returns a string that is the <A>nr</A>-th word over the alphabet list
##  <A>alpha</A>, w.r.t. word length and lexicographical order.
##  The empty word is <C>WordAlp( <A>alpha</A>, 0 )</C>.
##  <Example><![CDATA[
##  gap> List([0..5],i->WordAlp("abc",i));
##  [ "", "a", "b", "c", "aa", "ab" ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "WordAlp" );


#############################################################################
##
#F  LowercaseString( <string> ) . . . string consisting of lower case letters
##
##  <#GAPDoc Label="LowercaseString">
##  <ManSection>
##  <Func Name="LowercaseString" Arg='string'/>
##
##  <Description>
##  returns a lowercase version of the string <A>string</A>,
##  that is, a string in which each uppercase alphabet character is replaced
##  by the corresponding lowercase character.
##  <Example><![CDATA[
##  gap> LowercaseString("This Is UpperCase");
##  "this is uppercase"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "LowercaseString" );

#########################################################################
##
#F  UppercaseString( <string> ) . . . string consisting of upper case letters
##
##  returns a uppercase version of the string <string>,
##  that is, a string in which each lowercase alphabet character is replaced
##  by the corresponding uppercase character.
##
DeclareGlobalFunction( "UppercaseString" );

#############################################################################
##
#O  SplitString( <string>, <seps>[, <wspace>] )
##
##  <#GAPDoc Label="SplitString">
##  <ManSection>
##  <Oper Name="SplitString" Arg='string, seps[, wspace]'/>
##
##  <Description>
##  This function accepts a string <A>string</A> and lists <A>seps</A> and,
##  optionally, <A>wspace</A> of characters.
##  Now <A>string</A> is split into substrings at each occurrence of a
##  character in <A>seps</A> or <A>wspace</A>.
##  The characters in <A>wspace</A> are interpreted as white space
##  characters.
##  Substrings of characters in <A>wspace</A> are treated as one white space
##  character and they are ignored at the beginning and end of a string.
##  <P/>
##  Both arguments <A>seps</A> and <A>wspace</A> can be single characters.
##  <P/>
##  Each string in the resulting list of substring does not contain any
##  characters in <A>seps</A> or <A>wspace</A>.
##  <P/>
##  A character that occurs both in <A>seps</A> and <A>wspace</A> is treated
##  as a white space character.
##  <P/>
##  A separator at the end of a string is interpreted as a terminator; in
##  this case, the separator does not produce a trailing empty string.
##  Also see&nbsp;<Ref Func="Chomp"/>.
##  <Example><![CDATA[
##  gap> SplitString( "substr1:substr2::substr4", ":" );
##  [ "substr1", "substr2", "", "substr4" ]
##  gap> SplitString( "a;b;c;d;", ";" );
##  [ "a", "b", "c", "d" ]
##  gap> SplitString( "/home//user//dir/", "", "/" );
##  [ "home", "user", "dir" ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "SplitString", [IsString, IsObject, IsObject] );


#############################################################################
##
#F  RemoveCharacters( <string>, <todelete> )
##
##  For a mutable string <string> and a list <todelete> of characters,
##  `RemoveCharacters' removes the characters in <todelete> from <string>.
##
DeclareGlobalFunction( "RemoveCharacters" );


#############################################################################
##
#F  NormalizedWhitespace( <str> ) .  copy of string with normalized whitespace
##
##  <#GAPDoc Label="NormalizedWhitespace">
##  <ManSection>
##  <Func Name="NormalizedWhitespace" Arg='str'/>
##
##  <Description>
##  This function returns a copy of string <A>str</A> to which
##  <Ref Func="NormalizeWhitespace"/> was applied.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "NormalizedWhitespace" );


#############################################################################
##
#F  ReplacedString( <string>, <old>, <new> )
##
##  <#GAPDoc Label="ReplacedString">
##  <ManSection>
##  <Func Name="ReplacedString" Arg='string, old, new'/>
##
##  <Description>
##  replaces occurrences of the string <A>old</A> in <A>string</A> by
##  <A>new</A>, starting from the left and always replacing the first
##  occurrence.
##  To avoid infinite recursion, characters which have been replaced already,
##  are not subject to renewed replacement.
##  <Example><![CDATA[
##  gap> ReplacedString("abacab","a","zl");
##  "zlbzlczlb"
##  gap> ReplacedString("ababa", "aba","c");
##  "cba"
##  gap> ReplacedString("abacab","a","ba");
##  "babbacbab"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
MakeReadOnlyGlobal("ReplacedString"); # function defined in `init.g'.


#############################################################################
##
#F  EvalString( <expr> ) . . . . . . . . . . . . evaluate a string expression
##
##  <#GAPDoc Label="EvalString">
##  <ManSection>
##  <Func Name="EvalString" Arg='expr'/>
##
##  <Description>
##  passes the string <A>expr</A> through an input text stream so that &GAP;
##  interprets it, and returns the result.
##  <P/>
##  <Example><![CDATA[
##  gap> a:=10;
##  10
##  gap> EvalString("a^2");
##  100
##  ]]></Example>
##  <P/>
##  <Ref Func="EvalString"/> is intended for <E>single</E> expressions.
##  A sequence of commands may be interpreted by using the functions
##  <Ref Func="InputTextString"/> and
##  <Ref Func="ReadAsFunction" Label="for streams"/> together;
##  see <Ref Sect="Operations for Input Streams"/> for an example.
##  <P/>
##  If <Ref Func="EvalString"/> is used inside a function, then it doesn't
##  know about the local variables and the arguments of the function. 
##  A possible workaround is to define global variables in advance, and
##  then to assign the values of the local variables to the global ones,
##  like in the example below.
##  <P/>
##  <Example><![CDATA[
##  gap> global_a := 0;;
##  gap> global_b := 0;;
##  gap> example := function ( local_a )
##  >     local  local_b;
##  >     local_b := 5;
##  >     global_a := local_a;
##  >     global_b := local_b;
##  >     return EvalString( "global_a * global_b" );
##  > end;;
##  gap> example( 2 );
##  10
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##


#############################################################################
##
#F  JoinStringsWithSeparator( <list>[, <sep>] )
##
##  <#GAPDoc Label="JoinStringsWithSeparator">
##  <ManSection>
##  <Func Name="JoinStringsWithSeparator" Arg='list[, sep]'/>
##
##  <Description>
##  joins <A>list</A> (a list of strings) after interpolating <A>sep</A>
##  (or <C>","</C> if the second argument is omitted) between each adjacent
##  pair of strings; <A>sep</A> should be a string.
##  <P/>
##  <Example><![CDATA[
##  gap> list := List([1..10], String);
##  [ "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" ]
##  gap> JoinStringsWithSeparator(list);
##  "1,2,3,4,5,6,7,8,9,10"
##  gap> JoinStringsWithSeparator(["The", "quick", "brown", "fox"], " ");
##  "The quick brown fox"
##  gap> new:= JoinStringsWithSeparator(["a", "b", "c", "d"], ",\n    ");
##  "a,\n    b,\n    c,\n    d"
##  gap> Print("    ", new, "\n");
##      a,
##      b,
##      c,
##      d
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "JoinStringsWithSeparator" );


#############################################################################
##
#F  Chomp( <str> ) . .  remove trailing '\n' or "\r\n" from string if present
##
##  <#GAPDoc Label="Chomp">
##  <ManSection>
##  <Func Name="Chomp" Arg='str'/>
##  <Description>
##  Like the similarly named Perl function, <Ref Func="Chomp"/> removes a
##  trailing newline character (or carriage-return line-feed couplet) from a
##  string argument <A>str</A> if present and returns the result.
##  If <A>str</A> is not a string or does not have such trailing character(s)
##  it is returned unchanged.
##  This latter property means that <Ref Func="Chomp"/> is safe to use in
##  cases where one is manipulating the result of another function which
##  might sometimes return <K>fail</K>.
##  <P/>
##  <Example><![CDATA[
##  gap> Chomp("The quick brown fox jumps over the lazy dog.\n");
##  "The quick brown fox jumps over the lazy dog."
##  gap> Chomp("The quick brown fox jumps over the lazy dog.\r\n");
##  "The quick brown fox jumps over the lazy dog."
##  gap> Chomp("The quick brown fox jumps over the lazy dog.");
##  "The quick brown fox jumps over the lazy dog."
##  gap> Chomp(fail);
##  fail
##  gap> Chomp(32);
##  32
##  ]]></Example>
##  <P/>
##  <E>Note:</E>
##  <Ref Func="Chomp"/> only removes a trailing newline character from
##  <A>str</A>.
##  If your string contains several newline characters and you really want to
##  split <A>str</A> into lines at the newline characters (and remove those
##  newline characters) then you should use <Ref Func="SplitString"/>, e.g.
##  <P/>
##  <Example><![CDATA[
##  gap> str := "The quick brown fox\njumps over the lazy dog.\n";
##  "The quick brown fox\njumps over the lazy dog.\n"
##  gap> SplitString(str, "", "\n");
##  [ "The quick brown fox", "jumps over the lazy dog." ]
##  gap> Chomp(str);
##  "The quick brown fox\njumps over the lazy dog."
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Chomp" );

#############################################################################
##
#F  StartsWith( <string>, <prefix> ) . . . does <string> start with <prefix>?
#F  EndsWith( <string>, <suffix> ) . . . . . does <string> end with <suffix>?
##
##  <#GAPDoc Label="StartsWith">
##  <ManSection>
##  <Func Name="StartsWith" Arg='string, prefix'/>
##  <Func Name="EndsWith" Arg='string, suffix'/>
##
##  <Description>
##  <Index>Prefix</Index>
##  <Index>Suffix</Index>
##  Determines whether a string starts or ends with another string.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "StartsWith" );
DeclareGlobalFunction( "EndsWith" );


#############################################################################
##
## IntChar(<char>) . . . . . . .  integer in [0..255] corresponding to <char>
## CharInt(<int>)  . . . . . . character corresponding to <int> from [0..255] 
## SIntChar(<char>) . . signed integer in [-128..127] corresponding to <char>
## CharSInt(<int>) . . .  character corresponding to <int> from [-128 .. 127] 
## The signed and unsigned integer functions behave the same for values 
## in the range [0..127].

DeclareSynonym( "IntChar",  INT_CHAR);
DeclareSynonym( "CharInt",  CHAR_INT);
DeclareSynonym( "SIntChar", SINT_CHAR);
DeclareSynonym( "CharSInt", CHAR_SINT);


#############################################################################
##
#F  StringFile( <name> ) . . . . . . return content of file <name> as string
#F  FileString( <name>, <string>[, <append> ] ) . . write <string> to <name> 
##
##  <ManSection>
##  <Func Name="StringFile" Arg='name'/>
##  <Func Name="FileString" Arg='name, string[, append ]'/>
##
##  <Description>
##  fast copy of file into string and vice versa
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("StringFile");
DeclareGlobalFunction("FileString");


#############################################################################
##
#F  ReadCSV(<filename>[,<nohead>][,<separator>])
##
##  <#GAPDoc Label="ReadCSV">
##  <ManSection>
##  <Func Name="ReadCSV" Arg='filename[, nohead][, separator]'/>
##
##  <Description>
##  This function reads in a spreadsheet, saved in CSV format
##  (<E>c</E>omma <E>s</E>eparated <E>v</E>alues) and returns its entries as
##  a list of records.
##  The entries of the first line of the spreadsheet are used to denote
##  the names of the record components. Blanks will be translated into
##  underscore characters.
##  If the parameter <A>nohead</A> is given as <K>true</K>,
##  instead the record components will be called <C>fieldn</C>.
##  Each subsequent line will create one record.
##  If given, <A>separator</A> is the character used to separate fields.
##  Otherwise it defaults to a comma.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("ReadCSV");


#############################################################################
##
#F  PrintCSV(<filename>, <list> [,<fields>])
##
##  <#GAPDoc Label="PrintCSV">
##  <ManSection>
##  <Func Name="PrintCSV" Arg='filename, list[, fields]'/>
##
##  <Description>
##  This function prints a list of records as a spreadsheet in CSV format
##  (which can be read in for example into Excel). The names of the record
##  components will be printed as entries in the first line.
##  If the argument <A>fields</A> is given only the record fields listed in
##  this list will be printed
##  and they will be printed in the same arrangement as given in this list.
##  If the option noheader is set to true the line with the record field
##  names will not be printed.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("PrintCSV");

#############################################################################
##
#F  LaTeXTable(<filename>, <list> )
##
##  <#GAPDoc Label="LaTeXTable">
##  <ManSection>
##  <Func Name="LaTeXTable" Arg='filename, list'/>
##
##  <Description>
##  This function prints a list of records with entries named fieldNR as a
##  LaTeX table. The first row specifies the print format for the column as
##  a combination of letters from:
##  RLC: alignment
##  M: Math mode
##  MN: Math mode but names, characters are put into mbox
##  F: Number displayed in factored form
##  P: Minipage environment (25mm per default)
##  B: This column is used to indicate background color of a row.
##  If the option rows is given, alternating rows are colored grey.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("LaTeXTable");

BindGlobal("BHINT", "\>\<");

#############################################################################
##
#E
