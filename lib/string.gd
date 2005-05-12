#############################################################################
##
#W  string.gd                   GAP library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the declarations for functions for strings.
##
Revision.string_gd :=
    "@(#)$Id$";


#############################################################################
##
#F  IsDigitChar( <c> )
##
##  checks whether the character <c> is a digit, i.e., occurs in the string
##  `\"0123456789\"'.
##
DeclareGlobalFunction( "IsDigitChar" );


#############################################################################
##
#F  IsUpperAlphaChar( <c> )
##
##  checks whether the character <c> is an uppercase alphabet letter, i.e.,
##  occurs in the string `\"ABCDEFGHIJKLMNOPQRSTUVWXYZ\"'.
##
DeclareGlobalFunction( "IsUpperAlphaChar" );


#############################################################################
##
#F  IsLowerAlphaChar( <c> )
##
##  checks whether the character <c> is a lowercase alphabet letter, i.e.,
##  occurs in the string `\"abcdefghijklmnopqrstuvwxyz\"'.
##
DeclareGlobalFunction( "IsLowerAlphaChar" );


#############################################################################
##
#F  IsAlphaChar( <c> )
##
##  checks whether the character <c> is either a lowercase or an uppercase
##  alphabet letter.
##
DeclareGlobalFunction( "IsAlphaChar" );


#2
##  All calendar functions use the Gregorian calendar.


#############################################################################
##
#F  DaysInYear( <year> )  . . . . . . . . .  days in a year, knows leap-years
##
##  returns the number of days in a year.
##
DeclareGlobalFunction( "DaysInYear" );


#############################################################################
##
#F  DaysInMonth( <month>, <year> )  . . . . days in a month, knows leap-years
##
##  returns the number of days in month number <month> of <year> (and `fail'
##  if `month' is integer not in valid range.
##
DeclareGlobalFunction( "DaysInMonth" );


#############################################################################
##
#F  DMYDay( <day> ) . . .  convert days since 01-Jan-1970 into day-month-year
##
##  converts a number of days, starting 1-Jan-1970 to a list
##  `[<day>,<month>,<year>]' in Gregorian calendar counting.
##
DeclareGlobalFunction( "DMYDay" );


#############################################################################
##
#F  DayDMY( <dmy> ) . . .  convert day-month-year into days since 01-Jan-1970
##
##  returns the number of days from 01-Jan-1970 to the day given by <dmy>.
##  <dmy> must be a list of the form `[<day>,<month>,<year>]' in Gregorian
##  calendar counting. The result is `fail' on input outside valid ranges.
##  
##  Note that this makes not much sense for early dates like: before 1582
##  (no Gregorian calendar at all), or before 1753 in many English countries
##  or before 1917 in Russia.
##  
DeclareGlobalFunction( "DayDMY" );

#############################################################################
##
#F  SecondsDMYhms( <DMYhms> ) . . . . . convert day-month-year-hms into seconds
##
##  returns the number of seconds from 01-Jan-1970, 00:00:00,  to the time 
##  given by <DMYhms>.
##  <DMYhms> must be a list of the form
##  `[<day>,<month>,<year>,<hour>,<minute>,<second>]'. The remarks on the
##  Gregorian calendar in the section on "DayDMY" apply here as well. The
##  last three arguments must lie in the appropriate ranges. 
## 
DeclareGlobalFunction( "SecondsDMYhms" );

#############################################################################
##
#F  DMYhmsSeconds( <secs> ) . . . . . . . . . . . . . inverse of SecondsDMYhms
##
##  This is the inverse function to "SecondsDMYhms".
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
##  returns the weekday of a day given by <date>. <date> can be a number of
##  days since 1-Jan-1970 or a list `[<day>,<month>,<year>]'.
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
##  converts <date> to a readable string.  <date> can be a number of days
##  since 1-Jan-1970 or a list `[<day>,<month>,<year>]'.
##
DeclareGlobalFunction( "StringDate" );


#############################################################################
##
#F  HMSMSec( <msec> )  . . . . . . . .  convert seconds into hour-min-sec-mill
##
##  converts a number <msec> of milliseconds into a list
##  `[<hour>,<min>,<sec>,<milli>]'.
##
DeclareGlobalFunction( "HMSMSec" );


#############################################################################
##
#F  SecHMSM( <hmsm> ) . . . . . . . . convert hour-min-sec-milli into seconds
##
##  is the reverse of `HMSMSec'.
##
DeclareGlobalFunction( "SecHMSM" );


#############################################################################
##
#F  StringTime( <time> )  . convert hour-min-sec-milli into a readable string
##
##  converts <time> (given as a number of milliseconds or a list
##  `[<hour>, <min>, <sec>, <milli>]') to a readable string.
##
DeclareGlobalFunction( "StringTime" );


#############################################################################
##
#F  StringPP( <int> ) . . . . . . . . . . . . . . . . . . . . P1^E1 ... Pn^En
##
##  returns a string representing the prime factor decomposition
##  of the integer <int>.
##
DeclareGlobalFunction( "StringPP" );


############################################################################
##
#F  WordAlp( <alpha>, <nr> ) . . . . . .  <nr>-th word over alphabet <alpha>
##
##  returns a string that is the <nr>-th word over the alphabet list
##  <alpha>, w.r.t. word length and lexicographical order.
##  The empty word is `WordAlp( <alpha>, 0 )'.
##
DeclareGlobalFunction( "WordAlp" );


#############################################################################
##
#F  LowercaseString( <string> ) . . . string consisting of lower case letters
##
##  returns a lowercase version of the string <string>,
##  that is, a string in which each uppercase alphabet character is replaced
##  by the corresponding lowercase character.
##
DeclareGlobalFunction( "LowercaseString" );


#############################################################################
##
#O  SplitString( <string>, <seps>[, <wspace>] )
##
##  This function accepts a string <string> and lists <seps> and, optionally,
##  <wspace> of characters.  Now string is split into substrings at each
##  occurrence of a character in <seps> or <wspace>.  The characters in
##  <wspace> are interpreted as white space characters.  Substrings of
##  characters in <wspace> are treated as one white space character and they
##  are ignored at the beginning and end of a string.
##
##  Both arguments <seps> and <wspace> can be single characters.
##
##  Each string in the resulting list of substring does not contain any
##  characters in <seps> or <wspace>.
##
##  A character that occurs both in <seps> and <wspace> is treated as a
##  white space character.
##
##  A separator at the end of a string is interpreted as a terminator; in
##  this case, the separator does not produce a trailing empty string.
##  Also see~"Chomp".
##
DeclareOperation( "SplitString", [IsString, IsObject, IsObject] );


#############################################################################
##
# F  RemoveCharacters( <string>, <todelete> )
##
##  For a mutable string <string> and a list <todelete> of characters,
##  `RemoveCharacters' removes the characters in <todelete> from <string>.
##
DeclareGlobalFunction( "RemoveCharacters" );


#############################################################################
##
#F  NormalizedWhitespace( <str> ) .  copy of string with normalized whitespace
##  
##  This function returns a copy of string <str> to which
##  "NormalizeWhitespace" was applied.
##  
DeclareGlobalFunction( "NormalizedWhitespace" );

#############################################################################
##
#F  ReplacedString( <string>, <old>, <new> )
##
##  replaces occurrences of the string <old> in <string> by  <new>,  starting
##  from the left  and  always  replacing  the  first  occurrence.  To  avoid
##  infinite recursion, characters which have been replaced already, are  not
##  subject to renewed replacement.
##
MakeReadOnlyGlobal("ReplacedString"); # function defined in `init.g'.

#############################################################################
##
#F  EvalString( <expr> ) . . . . . . . . . . . . evaluate a string expression
##
##  passes <expr> (a string) through  an  input text stream  so  that  {\GAP}
##  interprets it, and returns the  result.  The  following  trivial  example
##  demonstrates its use.
##
##  \beginexample
##  gap> a:=10;
##  10
##  gap> EvalString("a^2");
##  100
##  \endexample
##
##  `EvalString' is intended for *single* expressions. A sequence of commands
##  may   be   interpreted   by   using   the   functions   `InputTextString'
##  (see~"InputTextString")  and  `ReadAsFunction'   (see~"ReadAsFunction!for
##  streams") together; see "Operations for Input Streams" for an example.
##
DeclareGlobalFunction( "EvalString" );

#############################################################################
##
#F  JoinStringsWithSeparator( <list>[, <sep>] )
##
##  joins <list> (a list of strings) after interpolating <sep> (or  `","'  if
##  the second argument is omitted) between each adjacent  pair  of  strings;
##  <sep> should be a string.
##
##  *Examples*
##
##  \beginexample
##  gap> list := List([1..10], String);                                  
##  [ "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" ]
##  gap> JoinStringsWithSeparator(list);
##  "1,2,3,4,5,6,7,8,9,10"
##  gap> JoinStringsWithSeparator(["The", "quick", "brown", "fox"], " ");
##  "The quick brown fox"
##  gap> JoinStringsWithSeparator(["a", "b", "c", "d"], ",\n    ");    
##  "a,\n    b,\n    c,\n    d"
##  gap> Print("    ", last, "\n");
##      a,
##      b,
##      c,
##      d
##  \endexample
##
##  Recall, `last' is the last expression output by {\GAP}.
##
DeclareGlobalFunction( "JoinStringsWithSeparator" );

#############################################################################
##
#F  Chomp( <str> ) . .  remove trailing '\n' or "\r\n" from string if present
##
##  Like the similarly  named  Perl  function,  `Chomp'  removes  a  trailing
##  newline character (or carriage-return line-feed couplet)  from  a  string
##  argument <str> if present and returns the  result.  If  <str>  is  not  a
##  string or does  not  have  such  trailing  character(s)  it  is  returned
##  unchanged. This latter property means that `Chomp'  is  safe  to  use  in
##  cases where one is manipulating the  result  of  another  function  which
##  might sometimes return `fail', for example.
##
##  \beginexample
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
##  \endexample
##
##  *Note:*
##  `Chomp' only removes a trailing newline character  from  <str>.  If  your
##  string contains several newline characters and you really want  to  split
##  <str> into lines at the newline  characters  (and  remove  those  newline
##  characters) then you should use `SplitString' (see~"SplitString"), e.g.
##
##  \beginexample
##  gap> str := "The quick brown fox\njumps over the lazy dog.\n";
##  "The quick brown fox\njumps over the lazy dog.\n"
##  gap> SplitString(str, "", "\n");
##  [ "The quick brown fox", "jumps over the lazy dog." ]
##  gap> Chomp(str);
##  "The quick brown fox\njumps over the lazy dog."
##  \endexample
##
DeclareGlobalFunction( "Chomp" );


#############################################################################
##
#F  StringFile( <name> ) . . . . . . return content of file <name> as string
#F  FileString( <name>, <string>[, <append> ] ) . . write <string> to <name> 
##  
##  fast copy of file into string and vice versa
##  
DeclareGlobalFunction("StringFile");
DeclareGlobalFunction("FileString");

#############################################################################
##
#E

