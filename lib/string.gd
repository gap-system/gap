#############################################################################
##
#W  string.gd                   GAP library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
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
##  returns the number of days in month number <month> of <year>.
##
DeclareGlobalFunction( "DaysInMonth" );


#############################################################################
##
#F  DMYDay( <day> ) . . .  convert days since 01-Jan-1970 into day-month-year
##
##  converts a number of days, starting 1-Jan-1970 to a list
##  `[<day>,<month>,<year>]'
##
DeclareGlobalFunction( "DMYDay" );


#############################################################################
##
#F  DayDMY( <dmy> ) . . .  convert day-month-year into days since 01-Jan-1970
##
##  returns the number of days from 01-Jan-1970 to the day given by <dmy>.
##  <dmy> must be a list of the form `[<day>,<month>,<year>]'.
##
DeclareGlobalFunction( "DayDMY" );


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
##  converts <time> (given as a sumber of milliseconds or a list
##  `[<hour>,<min>,<sec>,<milli>]') to a readable string.
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
##
DeclareOperation( "SplitString", [IsString, IsObject, IsObject] );

#############################################################################
##
#F  ReplacedString( <string>, <old>, <new> )
##
##  replaces occurrences of the string <old> in <string> by <new>, starting
##  from the left and always replacing the first occurrence.
##  To avoid inifinite recursion, characters which have been replaced
##  already, are not subject to renewed replacement.
MakeReadOnlyGlobal("ReplacedString"); # function defined in `init.g'.

#############################################################################
##
#E

