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

#2
##  All calendar functions use the Gregorian calendar.

#############################################################################
##
#F  DaysInYear( <year> )  . . . . . . . . .  days in a year, knows leap-years
##
##  returns the number of days in a year.
DeclareGlobalFunction("DaysInYear");


#############################################################################
##
#F  DaysInMonth( <month>, <year> )  . . . . days in a month, knows leap-years
##
##  returns the number of days in month number <month> of <year>.
DeclareGlobalFunction("DaysInMonth");

#############################################################################
##
#F  DMYDay( <day> ) . . .  convert days since 01-Jan-1970 into day-month-year
##
##  converts a number of days, starting 1-Jan-1970 to a list
##  `[<day>,<month>,<year>]'
DeclareGlobalFunction("DMYDay");


#############################################################################
##
#F  DayDMY( <dmy> ) . . .  convert day-month-year into days since 01-Jan-1970
##
##  returns the number of days from 01-Jan-1970 to the day given by <dmy>.
##  <dmy> must be a list of the form `[<day>,<month>,<year>]'.
DeclareGlobalFunction("DayDMY");


#############################################################################
##
#v  NamesWeekDay  . . . . . . . . . . . . . . . . . list of names of weekdays
##
##  is a list of abbreviated weekday names.
NameWeekDay := Immutable( ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"] );


#############################################################################
##
#F  WeekDay( <date> ) . . . . . . . . . . . . . . . . . . . weekday of a date
##
##  returns the weekday of a day given by <date>. <date> can be a number of
##  days since 1-Jan-1970 or a list `[<day>,<month>,<year>]'.
DeclareGlobalFunction("WeekDay");

#############################################################################
##
#v  NameMonth . . . . . . . . . . . . . . . . . . . . list of names of months
##
NameMonth := Immutable( [ "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ] );


#############################################################################
##
#F  StringDate( <date> )  . . . . . . . . convert date into a readable string
##
##  converts <date> to a readable string.  <date> can be a number of days
##  since 1-Jan-1970 or a list `[<day>,<month>,<year>]'.
DeclareGlobalFunction("StringDate");

#############################################################################
##
#F  HMSMSec( <msec> )  . . . . . . . .  convert seconds into hour-min-sec-mill
##
##  converts a number <msec> of milliseconds in a list
##  `[<hour>,<min>,<sec>,<milli>]'.
DeclareGlobalFunction("HMSMSec");


#############################################################################
##
#F  SecHMSM( <hmsm> ) . . . . . . . . convert hour-min-sec-milli into seconds
##
##  is the reverse of `HMSMSec'.
DeclareGlobalFunction("SecHMSM");


#############################################################################
##
#F  StringTime( <time> )  . convert hour-min-sec-milli into a readable string
##
##  converts <time> (given as a sumber of milliseconds or a list
##  `[<hour>,<min>,<sec>,<milli>]') to a readable string.
DeclareGlobalFunction("StringTime");


#############################################################################
##
#F  StringPP( <int> ) . . . . . . . . . . . . . . . . . . . . P1^E1 ... Pn^En
##
##  returns a string representing the prime factor decomposition of <int>.
DeclareGlobalFunction("StringPP");

############################################################################
##
#F  WordAlp( <alpha>, <nr> ) . . . . . .  <nr>-th word over alphabet <alpha>
##
##  returns  a string  that  is the <nr>-th  word  over the alphabet <alpha>,
##  w.r.  to word  length   and  lexicographical order.   The  empty  word is
##  `WordAlp( <alpha>, 0 )'.
##
DeclareGlobalFunction("WordAlp");

#############################################################################
##
#F  LowercaseString( <string> ) . . . string consisting of lower case letters
##
##  returns a lower case version of the string <string>.
DeclareGlobalFunction("LowercaseString");

#############################################################################
##
#E  string.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here


