#############################################################################
##
#W  general.g              GAP4 Package `ResClasses'              Stefan Kohl
##
#H  @(#)$Id: general.g,v 1.62 2012/01/07 22:05:12 stefan Exp $
##
##  This file contains a couple of functions and methods which are not
##  directly related to computations with residue classes, and which might
##  perhaps later be moved into the GAP Library.
##
Revision.general_g :=
  "@(#)$Id: general.g,v 1.62 2012/01/07 22:05:12 stefan Exp $";

#############################################################################
##
#S  SendEmail and EmailLogFile. /////////////////////////////////////////////
##
#############################################################################

#############################################################################
##
#F  SendEmail( <sendto>, <copyto>, <subject>, <text> ) . . . . send an e-mail
##
##  Sends an e-mail with subject <subject> and body <text> to the addresses
##  in the list <sendto>, and copies it to those in the list <copyto>.
##  The first two arguments must be lists of strings, and the latter two must
##  be strings.
##
BindGlobal( "SendEmail",

  function ( sendto, copyto, subject, text )

    local  sendmail, inp;

    sendto   := JoinStringsWithSeparator( sendto, "," );
    copyto   := JoinStringsWithSeparator( copyto, "," );
    sendmail := Filename( DirectoriesSystemPrograms(  ), "mail" );
    inp      := InputTextString( text );
    return Process( DirectoryCurrent(  ), sendmail, inp, OutputTextNone(  ),
                    [ "-s", subject, "-c", copyto, sendto ] );
  end );

#############################################################################
##
#F  EmailLogFile( <addresses> ) . . .  send log file by e-mail to <addresses>
##
##  Sends the current logfile by e-mail to <addresses>, if GAP is in logging
##  mode and one is working under UNIX, and does nothing otherwise.
##  The argument <addresses> must be either a list of email addresses or
##  a single e-mail address. Long log files are abbreviated, i.e. if the log
##  file is larger than 64KB, then any output is truncated at 1KB, and if the
##  log file is still longer than 64KB afterwards, it is truncated at 64KB.
##
BindGlobal( "EmailLogFile", 

  function ( addresses )

    local  filename, logfile, selection, pos1, pos2;

    if ARCH_IS_UNIX() and IN_LOGGING_MODE <> false then
      if IsString(addresses) then addresses := [addresses]; fi;
      filename := USER_HOME_EXPAND(IN_LOGGING_MODE);
      logfile  := ReadAll(InputTextFile(filename));
      if Length(logfile) > 2^16 then # Abbreviate output in long logfiles.
        selection := ""; pos1 := 1;
        repeat
          pos2 := PositionSublist(logfile,"gap> ",pos1);
          if pos2 = fail then pos2 := Length(logfile) + 1; fi;
          Append(selection,logfile{[pos1..Minimum(pos1+1024,pos2-1)]});
          if pos1 + 1024 < pos2 - 1 then
            Append(selection,
                   logfile{[pos1+1025..Position(logfile,'\n',pos1+1024)]});
            Append(selection,"                                    ");
            Append(selection,"[ ... ]\n");
          fi;
          pos1 := pos2;
        until pos2 >= Length(logfile);
        logfile := selection;
        if Length(logfile) > 2^16 then logfile := logfile{[1..2^16]}; fi;
      fi;
      return SendEmail(addresses,[],Concatenation("GAP logfile ",filename),
                       logfile);
    fi;
  end );

#############################################################################
##
#S  A simple caching facility. //////////////////////////////////////////////
##
#############################################################################

#############################################################################
##
#F  SetupCache( <name>, <size> )
##
##  Creates an empty cache named <name> for at most <size> values.
##
BindGlobal( "SetupCache",
  function ( name, size )
    BindGlobal(name,[[size,-1,fail]]);
  end );

#############################################################################
##
#F  PutIntoCache( <name>, <key>, <value> )
##
##  Puts the entry <value> with key <key> into the cache named <name>.
##
BindGlobal( "PutIntoCache",

  function ( name, key, value )

    local  cache, pos, i;

    cache := ValueGlobal(name);
    MakeReadWriteGlobal(name);
    pos := Position(List(cache,t->t[1]),key,1);
    if pos = fail then Add(cache,[key,0,value]);
                  else cache[pos][2] := 0; fi;
    for i in [2..Length(cache)] do
      cache[i][2] := cache[i][2] + 1;
    od;
    Sort(cache,function(t1,t2) return t1[2]<t2[2]; end);
    if   Length(cache) > cache[1][1]+1
    then cache := cache{[1..cache[1][1]+1]}; fi;
    MakeReadOnlyGlobal(name);
  end );

#############################################################################
##
#F  FetchFromCache( <name>, <key> )
##
##  Picks the entry with key <key> from the cache named <name>.
##  Returns fail if no such entry is present.
##
BindGlobal( "FetchFromCache",

  function ( name, key )

    local  cache, pos, i;

    cache := ValueGlobal(name);
    pos   := Position(List(cache,t->t[1]),key,1);
    if IsInt(pos) then
      MakeReadWriteGlobal(name);
      cache[pos][2] := 0;
      for i in [2..Length(cache)] do
        cache[i][2] := cache[i][2] + 1;
      od;
      MakeReadOnlyGlobal(name);
      return cache[pos][3];
    fi;
    return fail;
  end );

#############################################################################
##
#S  Some trivial methods which are missing in the GAP Library. //////////////
##
#############################################################################

#############################################################################
##
#F  InstallLinearOrder( <domains> )
##
DeclareGlobalFunction( "InstallLinearOrder" );
InstallGlobalFunction( InstallLinearOrder,

  function ( domains )

    local  pairs, pair, names, desc, descrev;

    pairs := Combinations([1..Length(domains)],2);
    for pair in pairs do
      names := List([1..2],i->NameFunction(domains[pair[i]]));
      desc    := Concatenation("for ",names[1]," and ",names[2]);
      descrev := Concatenation("for ",names[2]," and ",names[1]);
      InstallMethod( IsSubset, desc, ReturnTrue,
                     [domains[pair[2]],domains[pair[1]]], 0, ReturnTrue );
      InstallMethod( IsSubset, descrev, ReturnTrue,
                     [domains[pair[1]],domains[pair[2]]], 0, ReturnFalse );
      InstallMethod( \=, desc, ReturnTrue,
                     [domains[pair[2]],domains[pair[1]]], 0, ReturnFalse );
      InstallMethod( \=, descrev, ReturnTrue,
                     [domains[pair[1]],domains[pair[2]]], 0, ReturnFalse );
    od;
  end );

#############################################################################
##
##  Some orderings.
##
InstallLinearOrder( [ IsPositiveIntegers, IsNonnegativeIntegers, IsIntegers,
                      IsRationals, IsGaussianRationals ] );
InstallLinearOrder( [ IsPositiveIntegers, IsNonnegativeIntegers, IsIntegers,
                      IsGaussianIntegers, IsGaussianRationals ] );

#############################################################################
##
#M  ViewString( <rat> ) . . . . . . . . . . . . . . . . . . .  for a rational
#M  ViewString( <z> ) . . . . . . . . . . . . . .  for a finite field element
#M  ViewString( <s> ) . . . . . . . . . . . . . . . . . . . . .  for a string
##
InstallMethod( ViewString, "for a rational (ResClasses)", true, [ IsRat ], 0,
               function ( rat )
                 if IsInt(rat) or (IsBoundGlobal("Z_PI_RCWAMAPPING_FAMILIES")
                   and Length(ValueGlobal("Z_PI_RCWAMAPPING_FAMILIES")) >= 1)
                 then return String(rat);
                 else TryNextMethod(); fi;
               end );
InstallMethod( ViewString, "for a finite field element (ResClasses)", true,
               [ IsFFE and IsInternalRep ], 0, String );
InstallMethod( ViewString, "for a string (ResClasses)", true,
               [ IsString ], 0, String );

#############################################################################
##
#M  ViewString( <P> ) . . . . for a univariate polynomial over a finite field
##
InstallMethod( ViewString,
               "for univariate polynomial over finite field (ResClasses)",
               true, [ IsUnivariatePolynomial ], 0,

  function ( P )

    local  str, R, F, F_el, F_elints, lngs1, lngs2, i;

    str := String(P);
    if   ValueGlobal("GF_Q_X_RESIDUE_CLASS_UNIONS_FAMILIES") = []
    then TryNextMethod(); fi;

    R := DefaultRing(P);
    F := LeftActingDomain(R);
    if not IsFinite(F) then TryNextMethod(); fi;
    if not IsPrimeField(F) then return str; fi;

    F_el     := List(AsList(F),String);
    F_elints := List(List(AsList(F),Int),String);
    lngs1    := -List(F_el,Length);
    lngs2    := ShallowCopy(lngs1);
    SortParallel(lngs1,F_el);
    SortParallel(lngs2,F_elints);

    for i in [1..Length(F_el)] do
      str := ReplacedString(str,F_el[i],F_elints[i]);
    od;

    return str;
  end );

#############################################################################
##
#M  Comm( [ <elm1>, <elm2> ] ) . . .  for arguments enclosed in list brackets
##
InstallOtherMethod( Comm,
                    "for arguments enclosed in list brackets (ResClasses)",
                    true, [ IsList ], 0, LeftNormedComm );

#############################################################################
##
#S  Declarations of operations etc. /////////////////////////////////////////
##
#############################################################################

#############################################################################
##
#O  IsCommuting( <a>, <b> ) .  checks whether two group elements etc. commute
##
DeclareOperation( "IsCommuting", [ IsMultiplicativeElement,
                                   IsMultiplicativeElement ] );

#############################################################################
##
#M  IsCommuting( <a>, <b> ) . . . . . . . . . . . . . . . . . fallback method
##
InstallMethod( IsCommuting,
               "fallback method (ResClasses)", IsIdenticalObj,
               [ IsMultiplicativeElement, IsMultiplicativeElement ], 0,
               function ( a, b ) return a*b = b*a; end );

#############################################################################
##
#S  Miscellanea. ////////////////////////////////////////////////////////////
##
#############################################################################

#############################################################################
##
#F  BlankFreeString( <obj> ) . . . . . . . . . . . . .  string without blanks
##
BindGlobal( "BlankFreeString",

  function ( obj )

    local  str;

    str := String(obj);
    RemoveCharacters(str," ");
    return str;
  end );

#############################################################################
##
#F  IntOrInfinityToLaTeX( n )
##
BindGlobal( "IntOrInfinityToLaTeX",
  function( n )
    if   IsInt(n)      then return String(n);
    elif IsInfinity(n) then return "\\infty";
    else return fail; fi;
  end );

#############################################################################
##
#V  One-character global variables ...
##
##  ... should not be overwritten when reading test files, e.g., although
##  one-letter variable names are used in test files frequently.
##  This is just the list of their names.
##
##  The actual caching is done by `ResClassesDoThingsToBeDoneBeforeTest' and
##  `ResClassesDoThingsToBeDoneAfterTest'.
##
BindGlobal( "ONE_LETTER_GLOBALS",
  List( "ABCDFGHIJKLMNOPQRSTUVWYabcdefghijklmnopqrstuvwxyz", ch -> [ch] ) );

#############################################################################
##
#E  general.g . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here