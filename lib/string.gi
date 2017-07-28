#############################################################################
##
#W  string.gi                   GAP library                      Frank Celler
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains functions for strings.
##


#############################################################################
##
#F  IsDigitChar(<c>)
##

InstallGlobalFunction(IsDigitChar,x->x in CHARS_DIGITS);


#############################################################################
##
#F  IsUpperAlphaChar(<c>)
##

InstallGlobalFunction(IsUpperAlphaChar,x->x in CHARS_UALPHA);


#############################################################################
##
#F  IsLowerAlphaChar(<c>)
##

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
        String(date[1],2), "-",
        NameMonth[date[2]], "-",
        String(date[3],4) );
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
InstallGlobalFunction(StringPP, function( n )
    local str, facs, i;

    # hand special cases (in particular 0, 1, -1)
    if n in [-3..3] then
        return String( n );
    fi;

    if n < 0  then
        n := -n;
        str := "-";
    else
        str := "";
    fi;

    facs := Collected( FactorsInt( n ) );
    for i in [ 1 .. Length( facs ) ] do
        if i > 1 then Append( str, "*" ); fi;
        Append( str, String( facs[ i ][ 1 ] ) );
        if facs[ i ][ 2 ] > 1 then
            Append( str, "^" );
            Append( str, String( facs[ i ][ 2 ] ) );
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

BindGlobal("LOWERCASETRANSTABLE", (function()
    local l;
    l := List([0..255], CHAR_INT);
    l{1+[65..90]} := l{1+[97..122]};
    l{1+[192..214]} := l{33+[192..214]};
    l{1+[216..221]} := l{33+[216..221]};
    return Immutable(l);
end)());

BindGlobal("UPPERCASETRANSTABLE", (function()
    local l;
    l := List([0..255], CHAR_INT);
    l{1+[97..122]} := l{1+[65..90]};
    l{33+[192..214]} := l{1+[192..214]};
    l{33+[216..221]} := l{1+[216..221]};
    return Immutable(l);
end)());

#############################################################################
##
#F  LowercaseString( <string> ) . . . string consisting of lower case letters
##

InstallGlobalFunction(LowercaseString , function( str )
  local res;
  # delegate to kernels TranslateString
  res := ShallowCopy(str);
  TranslateString(res, LOWERCASETRANSTABLE);
  return res;
end);

InstallGlobalFunction(LowercaseChar , function( c )
  return LOWERCASETRANSTABLE[IntChar(c)+1];
end);

#############################################################################
##
#F  UppercaseString( <string> ) . . . string consisting of upper case letters
##

InstallGlobalFunction(UppercaseString , function( str )
  local res;
  # delegate to kernels TranslateString
  res := ShallowCopy(str);
  TranslateString(res, UPPERCASETRANSTABLE);
  return res;
end);

InstallGlobalFunction(UppercaseChar , function( c )
  return UPPERCASETRANSTABLE[IntChar(c)+1];
end);

#############################################################################
##
#M  Int( <str> )  . . . . . . . . . . . . . . . .  integer described by <str>
##
InstallMethod( Int,
    "for strings",
    true,
    [ IsString ],
    0,
    INT_STRING );


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
            if Length(string) = 1 then
                return fail;
            fi;
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
            if s <> fail  then
                z := 10 * z + (s-1);
            else
                return fail;
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

# we overwrite this in GAPDoc such that Unicode can be used depending on string
# and terminal encoding
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
#M  ViewString(<char>)
## 
InstallMethod(ViewString, "IsChar", true, [IsChar], 0,
function(s)
  local r;
  r:=[ ''', s, ''' ];
  ConvertToStringRep(r);
  return r;
end);


#############################################################################
##
#M  DisplayString(<char>)
##
InstallMethod(DisplayString, "IsChar", true, [IsChar], 0,
function(s)
  local r;
  r:=[ ''', s, ''', '\n' ];
  ConvertToStringRep(r);
  return r;
end);


#############################################################################
##
#M  DisplayString(<list>)
##
InstallMethod(DisplayString, "IsList", true, [IsList and IsFinite], 0,
function( list )
  if Length(list) = 0 then
    if IsEmptyString( list ) then
      return "\n";
    else
      return "[  ]\n";
    fi;
  elif IsString( list ) then
    return Concatenation( list, "\n");
  else
    TryNextMethod();
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
##  function( string, seps, wspace )
##      local   substrings,  a,  z;
##  
##      ##  make sets from char lists
##      seps := Set(seps);
##      wspace := Set(wspace);
##  
##      ##  store the substrings in a list.
##      substrings := [];
##  
##      ##  a is the position after the last separator/white space.
##      a := 1;
##      z := 0;
##  
##      for z in [1..Length( string )] do
##          ##  Whenever we encounter a separator or a white space, the substring
##          ##  starting after the last separator/white space is cut out.  The
##          ##  only difference between white spaces and separators is that white
##          ##  spaces don't separate empty strings.  
##          if string[z] in wspace then
##              if a < z then
##                  Add( substrings, string{[a..z-1]} );
##              fi;
##              a := z+1;
##          elif string[z] in seps then
##              Add( substrings, string{[a..z-1]} );
##              a := z+1;
##          fi;
##      od;
##  
##      ##  Pick up a substring at the end of the string.  Note that a trailing
##      ##  separator does not produce an empty string.
##      if a <= z  then
##          Add( substrings, string{[a..z]} );
##      fi;
##      return substrings;
##  end 
# moved to kernel
SplitStringInternal
);

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
#F  RemoveCharacters( <string>, <todelete> )
##
# moved into kernels string.c
##  InstallGlobalFunction( "RemoveCharacters", function( string, todelete )
##      local len, posto, posfrom, i;
##  
##      len:= Length( string );
##      posto:= 0;
##      posfrom:= 1;
##      while posfrom <= len do
##        if not string[ posfrom ] in todelete then
##          posto:= posto + 1;
##          string[ posto ]:= string[ posfrom ];
##        fi;
##        posfrom:= posfrom + 1;
##      od;
##      for i in [ len, len-1 .. posto + 1 ] do
##        Unbind( string[i] );
##      od;
##  end );

InstallGlobalFunction("RemoveCharacters", REMOVE_CHARACTERS);


#############################################################################
##
#F  EvalString( <expr> ) . . . . . . . . . . . . evaluate a string expression
##
_EVALSTRINGTMP := 0;
InstallGlobalFunction("EvalString", function( s )
  local a, f, res;
  a := "_EVALSTRINGTMP:=";
  Append(a, s);
  Add(a, ';');
  Unbind(_EVALSTRINGTMP);
  f := InputTextString(a);
  Read(f);
  if not IsBound(_EVALSTRINGTMP) then
    Error("Could not evaluate string.\n");
  fi;
  res := _EVALSTRINGTMP;
  Unbind(_EVALSTRINGTMP);
  return res;
end);
Unbind(_EVALSTRINGTMP);

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

InstallGlobalFunction(StartsWith, function(string, prefix)
  return Length(prefix) <= Length(string) and
    string{[1..Length(prefix)]} = prefix;
end);

InstallGlobalFunction(EndsWith, function(string, suffix)
  return Length(suffix) <= Length(string) and
    string{[Length(string)-Length(suffix)+1..Length(string)]} = suffix;
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
  if str = fail then
    CloseStream(f);
      Error("in StringFile: ", LastSystemError().message,
            " (", LastSystemError().number, ")\n");
    return fail;
  fi;
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
  if not (IsString(name) and IsString(str) and IsBool(append)) then
      Error("Usage: FileString(<name>, <str> [, <append> ])");
  fi;
  out := OutputTextFile(name, append);
  if out=fail then
    return fail;
  fi;
  IS_STRING_CONV(str);
  if WRITE_STRING_FILE_NC(out![1], str) = fail then
    CloseStream(out);
      Error("in FileString: ", LastSystemError().message,
            " (", LastSystemError().number, ")\n");
    return fail;
  fi;
  CloseStream(out);
  return Length(str);
end);


BindGlobal("RCSVSplitString",function(s,sep)
local l, i, start,nodob,str;
  l:=[];
  i:=1;
  while i<=Length(s) do
    if s[i]=sep then
      Add(l,"");
      i:=i+1;
    elif s[i]='"' then
      # find next ", treating "" special
      str:="";
      start:=i+1;
      repeat
	while (i+1<=Length(s) and s[i+1]<>'"') or
	      (i+2=Length(s) and s[i+2]<>sep) do
	  i:=i+1;
	od;
	if Length(s)>=i+2 and s[i+2]='"' then
	  str:=Concatenation(str,s{[start..i+1]});
	  i:=i+2;
	  start:=i+1;
	  nodob:=false;
	else
	  nodob:=true;
	fi;
      until nodob;
      if Length(str)>0 then
	Add(l,Concatenation(str,s{[start..i]}));
      else
	Add(l,s{[start..i]});
      fi;
      i:=i+3; # skip ",
    else
      start:=i;
      while i<Length(s) and s[i+1]<>sep do
	i:=i+1;
      od;
      Add(l,s{[start..i]});
      i:=i+2; # skip comma
    fi;
  od;
  return l;
end);

BindGlobal("RCSVReadLine",function(f)
local l, b;
  l:="";
  while not IsEndOfStream(f) do
    b:=ReadByte(f);
    if b<>fail then
      if b<0 then 
	b:=b+256;
      fi;
      if b=10 or b=13 then
	return l;
      fi;
      Add(l,CHAR_INT(b));
    fi;
  od;
  return l;
end);

InstallGlobalFunction(ReadCSV,function(arg)
local nohead,file,sep,f, line, fields, l, r, i,s,t,add,dir;
  file:=arg[1];

  if not IsReadableFile(file) then
    i:=file;
    file:=Concatenation(i,".csv");
    if not IsReadableFile(file) then
      file:=Concatenation(i,".xls");
      if not IsReadableFile(file) then
        Error("file ",i," does not exist or is not readable");
      fi;
    fi;
  fi;

  if LowercaseString(file{[Length(file)-3..Length(file)]})=".xls" or
     LowercaseString(file{[Length(file)-4..Length(file)]})=".xlsx" then
    dir:=DirectoryTemporary();
    i:=file;
    file:=Filename(dir,"temp.csv");
    Exec(Concatenation("xls2csv -x \"",i,"\" -c \"",file,"\""));
  else
    dir:=fail;
  fi;
  nohead:=false;
  if Length(arg)>1 then
    if IsBool(arg[2]) then
      nohead:=arg[2];
    fi;
    sep:=arg[Length(arg)];
    if IsString(sep) then
      sep:=sep[1];
    elif not IsChar(sep) then
      sep:=',';
    fi;
  else
    sep:=',';
  fi;
  f:=InputTextFile(file);
  if f=fail then return f;fi; # wrong file
  if nohead<>true then
    line:=RCSVReadLine(f);
    line:=Chomp(line);
    if '"' in line and sep=',' then
      fields:=RCSVSplitString(line,sep);
    else
      fields:=SplitString(line,sep);
    fi;
    # field names with blank or empty are awkward
    for i in [1..Length(fields)] do
      if ' ' in fields[i] then
	fields[i]:=ReplacedString(fields[i]," ","_");
      elif Length(fields[i])=0 then
	fields[i]:=Concatenation("field",String(i));
      fi;
    od;
  else
    fields:=List([1..10000],i->Concatenation("field",String(i)));
  fi;
  l:=[];
  while not IsEndOfStream(f) do
    line:=RCSVReadLine(f);
    if line<>fail then
      line:=Chomp(line);
      if '"' in line and sep=',' then
	line:=RCSVSplitString(line,sep);
      else
	line:=SplitString(line,sep);
      fi;
      r:=rec();
      add:=false;
      for i in [1..Length(fields)] do
	if IsBound(line[i]) and Length(line[i])>0 then
	  s:=line[i];
	  # openoffice and Excel translate booleans differently. 
	  if s="TRUE" then s:="1";
	  elif s="FALSE" then s:="0";
	  else
	    t:=Rat(s);
	    if not IsBool(t) and not '.' in s then 
	      s:=t;
	    fi;
	  fi;

	  r.(fields[i]):=s;
	  add:=true;
	fi;
      od;
      if add then
	Add(l,r);
      fi;
    fi;
  od;
  CloseStream(f);
  if dir<>fail then
    RemoveFile(file);
  fi;
  return l;
end);

InstallGlobalFunction(PrintCSV,function(arg)
  local file,l,printEntry, rf, r, i, j,sz;

  file:=arg[1];
  l:=arg[2];
  printEntry:=function(s)
  local p,q;
    q:=false;
    if not IsString(s) then
      s:=String(s);
    elif IsString(s) and ForAll(s,x->x in CHARS_DIGITS or x in "+-") and Int(s)<>fail and AbsInt(Int(s))>10^9 then
      q:=true;
    fi;

    p:=Position(s,'\n');
    while p<>fail do
      s:=Concatenation(s{[1..p-1]},s{[p+1..Length(s)]});
      p:=Position(s,'\n');
    od;
    p:=PositionSublist(s,"  ");
    while p<>fail do
      s:=Concatenation(s{[1..p-1]},s{[p+1..Length(s)]});
      p:=PositionSublist(s,"  ");
    od;

    if '"' in s then
      p:=1;
      while p<=Length(s) do
	if s[p]='"' then
	  s:=Concatenation(s{[1..p]},s{[p..Length(s)]});
	  p:=p+1;
	fi;
	p:=p+1;
      od;
    fi;

    if ',' in s or '"' in s then
      s:=Concatenation("\"",s,"\"");
    elif q=true then
      # integers as string
      s:=Concatenation("\"_",s,"\"");
    fi;
    AppendTo(file,s,"\c");
  end;

  sz:=SizeScreen();
  SizeScreen([4096,sz[2]]);
  if Length(arg)>2 then
    rf:=arg[3];
  else
    rf:=[];
    for i in l do
      r:=RecNames(i);
      for j in r do
	if not j in rf then
	  Add(rf,j);
	fi;
      od;
    od;
    # sort record fields
    Sort(rf,function(a,b)
      local ap;
      # check trailing numbers
      ap:=Length(a);
      while ap>0 and a[ap] in CHARS_DIGITS do
	ap:=ap-1;
      od;
      if Length(b)>=ap and ForAll([ap+1..Length(b)],j->b[j] in CHARS_DIGITS) then
	return Int(a{[ap+1..Length(a)]})<Int(b{[ap+1..Length(b)]});
      fi;
      return a<b;
    end);
  fi;

  PrintTo(file);

  if ValueOption("noheader")<>true then
    printEntry(rf[1]);
    for j in [2..Length(rf)] do
      AppendTo(file,",");
      printEntry(ReplacedString(rf[j],"_"," "));
    od;
    AppendTo(file,"\n");
  fi;

  for  i in l do
    for j in [1..Length(rf)] do
      if j>1 then
	AppendTo(file,",");
      fi;
      if IsBound(i.(rf[j])) then
        printEntry(i.(rf[j]));
      fi;
    od;
    AppendTo(file,"\n");
  od;
  SizeScreen(sz);
end);


# Format commands
# RLC: alignment
# M: Math mode
# MN: Math mode but names, characters are put into mbox
# F: Number displayed in factored form
# P: Minipage environment (25mm per default)
# B: Background color
# option `rows' colors alternating rows
InstallGlobalFunction(LaTeXTable,function(file,l)
local f,i,j,format,cold,a,e,z,str,new,box,lc,mini,color,alt,renum;

  alt:=ValueOption("rows")<>fail;
  color:=fail;
  # row 1 indicates which columns are relevant and their formatting
  cold:=ShallowCopy(l[1]);
  f:=RecNames(cold);
  renum:=[];
  for i in ShallowCopy(f) do

    a:=Filtered(cold.(i),x->x in CHARS_DIGITS);
    if LENGTH(a)>0 then
      cold.(i):=Filtered(cold.(i),x->not x in CHARS_DIGITS);
      Add(renum,Int(a));
    fi;

    if cold.(i)="B" then 
      # color indicator
      color:=i;
      Unbind(cold.(i));
      f:=Difference(f,[i]);
    else
      cold.(i):=UppercaseString(cold.(i));
    fi;
  od;

  # resort columns if numbers are given
  if Length(renum)=Length(f) then
    a:=ShallowCopy(renum);
    a:=Sortex(a);
    f:=Permuted(f,a);
  fi;


  PrintTo(file);
  # header
  format:="";
  for i in [1..Length(f)] do
    if i>1 then Append(format,"|");fi;
    if 'R' in cold.(f[i]) then
      Add(format,'r');
    elif 'C' in cold.(f[i]) then
      Add(format,'c');
    else
      Add(format,'l');
    fi;
  od;

  # header
  AppendTo(file,"\\begin{tabular}{",format,"}\n");
  for i in [1..Length(f)] do
    if i>1 then AppendTo(file,"&");fi;
    AppendTo(file,l[2].(f[i]),"\n");
  od;
  AppendTo(file,"\\\\\n");
  AppendTo(file,"\\hline\n");

  #entries
  for j in [3..Length(l)] do
    if color<>fail and IsBound(l[j].(color)) then
      AppendTo(file,"\\rowcolor{",l[j].(color),"}%\n");
    elif alt and IsEvenInt(j) then
      # light grey color
      AppendTo(file,"\\rowcolor{lgrey}%\n");
    fi;
    for i in [1..Length(f)] do
      if i>1 then AppendTo(file,"&");fi;
      if IsBound(l[j].(f[i])) then
	str:=l[j].(f[i]);
	# fix _integer to keep long integers from Excel
	if IsList(str) and Length(str)>0 and str[1]='_' and
	  Int(str{[2..Length(str)]})<>fail then
	  str:=str{[2..Length(str)]};
	fi;

	if 'P' in cold.(f[i]) then
	  mini:=true;
	  AppendTo(file,"\\begin{minipage}{25mm}%\n");
	else
	  mini:=false;
	fi;
	if 'F' in cold.(f[i]) then
          if IsInt(str) then
            a:=str;
          else
            # transform str in normal format
            str:=Filtered(str,x->x<>',');
            z:=0;
            a:=Position(str,'E');
            if a<>fail then
              z:=Int(Filtered(str{[a+1..Length(str)]},x->x<>'+'));
              str:=str{[1..a-1]};
            fi;
            a:=Position(str,'.');
            if a<>fail then
              z:=z-(Length(str)-a);
              str:=Filtered(str,x->x<>'.');
            fi;

            a:=Int(str)*10^z;
          fi;

	  a:=Collected(Factors(a));
	  AppendTo(file,"$");
	  for z in [1..Length(a)] do
	    if z>1 and e=false then
	      AppendTo(file,"\n{\\cdot}");
	    fi;
	    AppendTo(file,a[z][1]);
	    if a[z][2]>1 then
	      AppendTo(file,"^{",a[z][2],"}");
	      e:=true;
	    else
	      e:=false;
	    fi;
	  od;
	  AppendTo(file,"$\n");
	elif 'M' in cold.(f[i]) and 'N' in cold.(f[i]) then
	  # make strings ``names'' in mbox
	  new:="";
	  box:=false;
	  lc:=false;
	  for a in str do
	    z:=a in CHARS_UALPHA or a in CHARS_LALPHA;
	    if z and box=false then
	      if lc='\\' then # actual command
		box:=fail;
	      else
		Append(new,"\\mbox{");
		box:=true;
	      fi;
	    elif box=true and not z then
	      Append(new,"}");
	      box:=false;
	    elif box=fail and not z then
	      box:=false; # command over
	    fi;
	    Add(new,a);
	    lc:=a; # last character
	  od;
	  if box=true then
	    Append(new,"}");
	  fi;
	  AppendTo(file,"$",new,"$\n");

	elif 'M' in cold.(f[i]) then
	  AppendTo(file,"$",str,"$\n");
	else
	  AppendTo(file,str,"\n");
	fi;
	if mini then
	  AppendTo(file,"\\end{minipage}%\n");
	fi;
      fi;
    od;
    AppendTo(file,"\\\\\n");
  od;

  AppendTo(file,"\\end{tabular}\n");
end);


#############################################################################
##
#F  Convenience method to inform users how to concatenate strings.
##
##  Note that we could also have this method do the following
##     return Concatenation(a,b);
##  instead of raising an error. But this leads to inefficient code when
##  concatenating many strings. So in order to not encourage such bad code,
##  we instead tell the user the proper way to do this.
##
InstallOtherMethod(\+, [IsString,IsString],
function(a,b)
    Error("concatenating strings via + is not supported, use Concatenation(<a>,<b>) instead");
end);


#############################################################################
##
#E
