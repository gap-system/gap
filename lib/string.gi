#############################################################################
##
#W  string.gi                   GAP library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains functions for strings.
##
Revision.string_gi :=
    "@(#)$Id$";


#############################################################################
##
#F  IsDigitChar(<c>)
##
BIND_GLOBAL("CHARS_DIGITS",Immutable(SSortedList("0123456789")));

InstallGlobalFunction(IsDigitChar,x->x in CHARS_DIGITS);


#############################################################################
##
#F  IsUpperAlphaChar(<c>)
##
BIND_GLOBAL("CHARS_UALPHA",
  Immutable(SSortedList("ABCDEFGHIJKLMNOPQRSTUVWXYZ")));

InstallGlobalFunction(IsUpperAlphaChar,x->x in CHARS_UALPHA);


#############################################################################
##
#F  IsLowerAlphaChar(<c>)
##
BIND_GLOBAL("CHARS_LALPHA",
  Immutable(SSortedList("abcdefghijklmnopqrstuvwxyz")));

InstallGlobalFunction(IsLowerAlphaChar,x->x in CHARS_LALPHA);


#############################################################################
##
#F  IsAlphaChar(<c>)
##
InstallGlobalFunction(IsAlphaChar,
  x->x in CHARS_LALPHA or x in CHARS_UALPHA);


#############################################################################
##
#F  DaysInYear( <year> )  . . . . . . . . .  days in a year, knows leap-years
##
InstallGlobalFunction(DaysInYear , function ( year )
    if year mod 4 in [1,2,3]  or year mod 400 in [100,200,300]  then
        return 365;
    else
        return 366;
    fi;
end);


#############################################################################
##
#F  DaysInMonth( <month>, <year> )  . . . . days in a month, knows leap-years
##
InstallGlobalFunction(DaysInMonth , function ( month, year )
    if month in [ 1, 3, 5, 7, 8, 10, 12 ]  then
        return 31;
    elif month in [ 4, 6, 9, 11 ]  then
        return 30;
    elif month = 2 and 
            (year mod 4 in [1,2,3]  or year mod 400 in [100,200,300])  then
        return 28;
    elif month = 2 then
        return 29;
    else
        return  fail;
    fi;
end);


#############################################################################
##
#F  DMYDay( <day> ) . . .  convert days since 01-Jan-1970 into day-month-year
##
InstallGlobalFunction(DMYDay , function ( day )
    local  year, month;
    year := 1970;
    while DaysInYear(year) <= day  do
        day   := day - DaysInYear(year);
        year  := year + 1;
    od;
    while day < 0 do
      year := year - 1;
      day := day + DaysInYear(year);
    od;
    month := 1;
    while DaysInMonth(month,year) <= day  do
        day   := day - DaysInMonth(month,year);
        month := month + 1;
    od;
    return [ day+1, month, year ];
end);


#############################################################################
##
#F  DayDMY( <dmy> ) . . .  convert day-month-year into days since 01-Jan-1970
##
InstallGlobalFunction(DayDMY , function ( dmy )
    local  year, month, day;
    day   := dmy[1]-1;
    month := dmy[2];
    year  := dmy[3];
    if DaysInMonth(month, year) = fail or day < 0 or 
            day > DaysInMonth(month, year) - 1 then
        return fail;
    fi;
    while 1 < month  do
        month := month - 1;
        day   := day + DaysInMonth( month, year );
    od;
    while 1970 < year  do
        year  := year - 1;
        day   := day + DaysInYear( year );
    od;
    while year < 1970 do
        day := day - DaysInYear( year );
        year := year + 1;
    od;
    return day;
end);


#############################################################################
##
#F  WeekDay( <date> ) . . . . . . . . . . . . . . . . . . . weekday of a date
##
InstallGlobalFunction(WeekDay , function ( date )
    if IsList( date )  then date := DayDMY( date );  fi;
    return NameWeekDay[ (date + 3) mod 7 + 1 ];
end);

#############################################################################
##  
#F  SecondsDMYhms( <DMYhms> ) . . . . . . . . . seconds since 1/1/1970/0/0/0
##  
InstallGlobalFunction(SecondsDMYhms, function(DMYhms)
  local d, res, s;
  d := DayDMY(DMYhms{[1..3]});
  if d = fail then
    return fail;
  fi;
  res := d * 24 * 60^2;
  s := DMYhms{[4..6]};
  if not (s[1] in [0..23] and s[2] in [0..59] and s[3] in [0..59]) then
    return fail;
  fi;
  Add(s, 0);
  return res + SecHMSM(s) / 1000;
end);

#############################################################################
##  
#F  DMYhmsSeconds( <DMYhms> ) . . . . . . . . . inverse of SecondsDMYhms
##  
InstallGlobalFunction(DMYhmsSeconds, function(sec)
  local d, DMY;
  d := sec mod (24 * 60^2);
  DMY := DMYDay((sec - d) / (24 * 60^2));
  return Concatenation(DMY, HMSMSec(d * 1000){[1..3]});
end);
  
#############################################################################
##
#F  StringDate( <date> )  . . . . . . . . convert date into a readable string
##
InstallGlobalFunction(StringDate , function ( date )
    if IsInt( date )  then date := DMYDay( date );  fi;
    return Concatenation(
        FormattedString(date[1],2), "-",
        NameMonth[date[2]], "-",
        FormattedString(date[3],4) );
end);


#############################################################################
##

#F  HMSMSec( <sec> )  . . . . . . convert milliseconds into hour-min-sec-mill
##
InstallGlobalFunction(HMSMSec , function ( sec )
    local  hour, minute, second, milli;
    hour   := QuoInt( sec, 3600000 );
    minute := QuoInt( sec,   60000 ) mod 60;
    second := QuoInt( sec,    1000 ) mod 60;
    milli  :=         sec            mod 1000;
    return [ hour, minute, second, milli ];
end);


#############################################################################
##
#F  SecHMSM( <hmsm> ) . . . . . . convert hour-min-sec-milli into milliseconds
##
InstallGlobalFunction(SecHMSM , function ( hmsm )
    return [3600000, 60000, 1000, 1] * hmsm;
end);


#############################################################################
##
#F  StringTime( <time> )  . convert hour-min-sec-milli into a readable string
##
InstallGlobalFunction(StringTime , function ( time )
    local   string;
    if IsInt( time )  then time := HMSMSec( time );  fi;
    string := "";
    if time[1] <  10  then Append( string, " " );  fi;
    Append( string, String(time[1]) );
    Append( string, ":" );
    if time[2] <  10  then Append( string, "0" );  fi;
    Append( string, String(time[2]) );
    Append( string, ":" );
    if time[3] <  10  then Append( string, "0" );  fi;
    Append( string, String(time[3]) );
    Append( string, "." );
    if time[4] < 100  then Append( string, "0" );  fi;
    if time[4] <  10  then Append( string, "0" );  fi;
    Append( string, String(time[4]) );
    return string;
end);


#############################################################################
##
#F  StringPP( <int> ) . . . . . . . . . . . . . . . . . . . . P1^E1 ... Pn^En
##
InstallGlobalFunction(StringPP , function( n )
    local   l, p, e, i, prime, str;

    if n = 1  then
        return "1";
    elif n = -1  then
        return "-1";
    elif n = 0  then
        return "0";
    elif n < 0  then
        l := FactorsInt( -n );
	str := "-";
    else
        l := FactorsInt( n );
	str := "";
    fi;
    p := [];
    e := [];
    for prime  in Set( l )  do
        Add( p, prime );
        Add( e, Length( Filtered( l, x -> prime = x ) ) );
    od;

    if e[ 1 ] = 1   then
        str := Concatenation( str, String( p[ 1 ] ) );
    else
        str := Concatenation( str, String( p[ 1 ] ),
	                                 "^", String( e[ 1 ] ) );
    fi;

    for i  in [ 2 .. Length( p ) ]  do
        if e[ i ] = 1  then
	    str := Concatenation( str, "*", String( p[ i ] ) );
        else
	    str := Concatenation( str, "*", String( p[ i ] ),
	                                     "^", String( e[ i ] ) );
        fi;
    od;

    return str;
end);


############################################################################
##
#F  WordAlp( <alpha>, <nr> )  . . . . . .  <nr>-th word over alphabet <alpha>
##
##  returns  a string  that  is the <nr>-th  word  over the alphabet <alpha>,
##  w.r.  to word  length   and  lexicographical order.   The  empty  word is
##  'WordAlp( <alpha>, 0 )'.
##
InstallGlobalFunction(WordAlp , function( alpha, nr )

    local lalpha,   # length of the alphabet
          word,     # the result
          nrmod;    # position of letter

    lalpha:= Length( alpha );
    word:= "";
    while nr <> 0 do
      nrmod:= nr mod lalpha;
      if nrmod = 0 then nrmod:= lalpha; fi;
      Add( word, alpha[ nrmod ] );
      nr:= ( nr - nrmod ) / lalpha;
    od;
    return Reversed( word );
end);

#############################################################################
##
#F  LowercaseString( <string> ) . . . string consisting of lower case letters
##
InstallGlobalFunction(LowercaseString , function( str )
local result, i, pos;

    result:= "";
    for i in str do
      pos:= Position( CHARS_UALPHA, i );
      if pos = fail then
        Add( result, i );
      else
        Add( result, CHARS_LALPHA[ pos ] );
      fi;
    od;
    ConvertToStringRep( result );
    return result;
end);


#############################################################################
##
#M  Int( <str> )  . . . . . . . . . . . . . . . .  integer described by <str>
##
InstallOtherMethod( Int,
    "for strings",
    true,
    [ IsString ],
    0,

function( str )
    local   m,  z,  d,  i,  s;

    m := 1;
    z := 0;
    d := 1;
    for i  in [ 1 .. Length(str) ]  do
        if i = d and str[i] = '-'  then
            m := m * -1;
            d := i+1;
        else
            s := Position( CHARS_DIGITS, str[i] );
            if s <> fail  then
                z := 10 * z + (s-1);
            else
                return fail;
            fi;
        fi;
    od;
    return z * m;
end );


#############################################################################
##
#M  Rat( <str> )  . . . . . . . . . . . . . . . . rational described by <str>
##
InstallOtherMethod( Rat,
    "for strings",
    true,
    [ IsString ],
    0,

function( string )
    local   z,  m,  i,  s,  n,  p,  d;

    z := 0;
    m := 1;
    p := 1;
    d := false;
    for i  in [ 1 .. Length(string) ]  do
        if i = p and string[i] = '-'  then
            m := -1;
        elif string[i] = '/' and IsBound(n)  then
            return fail;
        elif string[i] = '/' and not IsBound(n)  then
            if IsRat(d)  then
                z := d * z;
            fi;
            d := false;
            n := m * z;
            m := 1;
            p := i+1;
            z := 0;
        elif string[i] = '.' and IsRat(d)  then
            return fail;
        elif string[i] = '.' and not IsRat(d)  then
            d := 1;
        else
            s := Position( CHARS_DIGITS, string[i] );
            if s <> false  then
                z := 10 * z + (s-1);
            else
                return false;
            fi;
            if IsRat(d)  then
                d := d / 10;
            fi;
        fi;
    od;
    if IsRat(d)  then
        z := d * z;
    fi;
    if IsBound(n)  then
        return m * n / z;
    else
        return m * z;
    fi;
end );


#############################################################################
##
#M  ViewObj(<string>)
#M  ViewObj(<char>)
##  
##  The difference  to PrintObj is  that printable non-ASCII  characters are
##  output directly. Use PrintObj to get a result which can be safely reread
##  by GAP or used for cut and paste.
##  
InstallMethod(ViewObj, "IsChar", true, [IsChar], 0,
function(x)
  local pos;
  Print("'");
  pos := Position(SPECIAL_CHARS_VIEW_STRING[1], x);
  if pos <> fail  then
    Print( SPECIAL_CHARS_VIEW_STRING[2][pos] );
  else
    Print( [ x ] );
  fi;
  Print("\'");
end);

InstallMethod(ViewObj, "IsString", true, [IsString and IsFinite],0,
function(s)
    local  x, pos;
    Print("\"");
    for x  in s  do
        pos := Position(SPECIAL_CHARS_VIEW_STRING[1], x);
        if pos <> fail  then
            Print( SPECIAL_CHARS_VIEW_STRING[2][pos] );
        else
            Print( [ x ] );
        fi;
    od;
    Print("\"");
end);

InstallMethod(ViewObj,"empty strings",true,[IsString and IsEmpty],0,
function(e)
  if TNUM_OBJ_INT(e) in TNUM_EMPTY_STRING then
    Print("\"\"");
  else
    Print("[  ]");
  fi;
end);


#############################################################################
##
#M  SplitString( <string>, <seps>, <wspace> ) . . . . . . . .  split a string
##
InstallMethod( SplitString,
        "for three strings",
        true,
        [ IsString, IsString, IsString ], 0,
function( string, seps, wspace )
    local   substrings,  a,  z;

    ##  make sets from char lists
    seps := Set(seps);
    wspace := Set(wspace);

    ##  store the substrings in a list.
    substrings := [];

    ##  a is the position after the last separator/white space.
    a := 1;
    z := 0;

    for z in [1..Length( string )] do
        ##  Whenever we encounter a separator or a white space, the substring
        ##  starting after the last separator/white space is cut out.  The
        ##  only difference between white spaces and separators is that white
        ##  spaces don't separate empty strings.  
        if string[z] in wspace then
            if a < z then
                Add( substrings, string{[a..z-1]} );
            fi;
            a := z+1;
        elif string[z] in seps then
            Add( substrings, string{[a..z-1]} );
            a := z+1;
        fi;
    od;

    ##  Pick up a substring at the end of the string.  Note that a trailing
    ##  separator does not produce an empty string.
    if a <= z  then
        Add( substrings, string{[a..z]} );
    fi;
    return substrings;
end );

InstallMethod( SplitString,
        "for a string and two characters",
        true,
        [ IsString, IsChar, IsChar ], 0,
function( string, d1, d2 )
    return SplitString( string, [d1], [d2] );
end );

InstallMethod( SplitString,
        "for two strings and a character",
        true,
        [ IsString, IsString, IsChar ], 0,
function( string, seps, d )
    return SplitString( string, seps, [d] );
end );

InstallMethod( SplitString,
        "for a string, a character and a string",
        true,
        [ IsString, IsChar, IsString ], 0,
function( string, d, wspace )
    return SplitString( string, [d], wspace );
end );

InstallOtherMethod( SplitString,
        "for two strings",
        true,
        [ IsString, IsString ], 0,
function( string, seps )
        return SplitString( string, seps, "" );
end );

InstallOtherMethod( SplitString,
        "for a string and a character",
        true,
        [ IsString, IsChar ], 0,
function( string, d )
        return SplitString( string, [d], "" );
end );


InstallOtherMethod(PositionSublist, "for two args in IsStringRep", true,
             [IS_STRING_REP, IS_STRING_REP], 0,
function( string, sub )
  return POSITION_SUBSTRING(string, sub, 0);
end );

InstallOtherMethod(PositionSublist, "for two args in IsStringRep and offset", 
             true, [IS_STRING_REP, IS_STRING_REP, IsInt], 0,
function( string, sub, off )
  if off<0 then 
    off := 0;
  fi;
  return POSITION_SUBSTRING(string, sub, off);
end );

#############################################################################
##
#F  NormalizedWhitespace( <str> ) . . . . . . . copy of string with normalized
#F  white space
##  
##  doesn't work in place like the kernel function `NormalizeWhitespace'
##   
InstallGlobalFunction("NormalizedWhitespace", function ( str )
    local  res;
    res := ShallowCopy( str );
    NormalizeWhitespace( res );
    return res;
end);

#############################################################################
##
#F  EvalString( <expr> ) . . . . . . . . . . . . evaluate a string expression
##
InstallGlobalFunction("EvalString", function( expr )
  local tmp;
  tmp := Concatenation( "return ", expr, ";" );
  return ReadAsFunction( InputTextString( tmp ) )();
end );

#############################################################################
##
#F  JoinStringsWithSeparator( <list>[, <sep>] )
##
InstallGlobalFunction("JoinStringsWithSeparator", function( arg )
  local str, sep, res, i;
  str := List(arg[1], String);
  if Length(str) = 0 then return ""; fi;
  if Length(arg) > 1 then sep := arg[2]; else sep := ","; fi;
  res := ShallowCopy(str[1]);
  for i in [2 .. Length(str)] do
    Append(res, sep);
    Append(res, str[i]);
  od;
  return res;
end );

#############################################################################
##
#F  Chomp( <str> ) . .  remove trailing '\n' or "\r\n" from string if present
##
InstallGlobalFunction(Chomp, function(str)

  if IsString(str) and str <> "" and str[Length(str)] = '\n' then
    if 1 < Length(str) and str[Length(str) - 1] = '\r' then
      return str{[1 .. Length(str) - 2]};
    fi;
    return str{[1 .. Length(str) - 1]};
  else
    return str;
  fi;
end);


#############################################################################
##
#F  StringFile( <name> ) . . . . . . return content of file <name> as string
#F  FileString( <name>, <string>[, <append> ] ) . . write <string> to <name> 
##
##  <#GAPDoc Label="StringFile">
##  <ManSection >
##  <Func Arg="filename" Name="StringFile" />
##  <Func Arg="filename, str[, append]" Name="FileString" />
##  <Description>
##  The  function <Ref  Func="StringFile" />  returns the  content of
##  file  <A>filename</A> as  a string.  This works  efficiently with
##  arbitrary (binary or text) files. If something went wrong,   this 
##  function returns <K>fail</K>.
##  <P/>
##  
##  Conversely  the function  <Ref  Func="FileString"  /> writes  the
##  content of a string <A>str</A>  into the file <A>filename</A>. If
##  the  optional third  argument <A>append</A>  is given  and equals
##  <K>true</K> then  the content  of <A>str</A>  is appended  to the
##  file. Otherwise  previous  content  of  the file is deleted. This 
##  function returns the number of  bytes  written  or <K>fail</K> if 
##  something went wrong.<P/>
##  
##  Both functions are quite efficient, even with large files. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(StringFile, function(name)
  local   f,  str;
  f := InputTextFile(name);
  if f=fail then
    return fail;
  fi;
  str := READ_STRING_FILE(f![1]);
  CloseStream(f);
  return str;
end);

# arg: filename, string[, append]   (default for append is false) 
InstallGlobalFunction(FileString, function(arg)
  local   name,  str,  append,  out;
  name := arg[1];
  str := arg[2];
  if Length(arg)>2 then
    append := arg[3];
  else
    append := false;
  fi;
  out := OutputTextFile(name, append);
  if out=fail then
    return fail;
  fi;
  IS_STRING_CONV(str);
  WRITE_STRING_FILE_NC(out![1], str);
  CloseStream(out);
  return Length(str);
end);

#############################################################################
##
#E

