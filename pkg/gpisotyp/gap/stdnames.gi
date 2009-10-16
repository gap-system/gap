############################################################################
##
#W  stdnames.gi          GAP 4 package `gpisotyp'               Thomas Breuer
##
#H  @(#)$Id: stdnames.gi,v 1.6 2002/07/10 16:32:46 gap Exp $
##
#Y  Copyright (C)  2002,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declarations for name translation objects and
##  for the special case of standard names of groups.
##
##  0. Global variables for the package
##  1. Translated Names, Admissible Names, and Standard Names
##  2. Name Translator Objects
##  3. Name Standardizer Objects
##  4. Admissible Names and Standard Names of Groups
##  5. A utility for names of finite simple groups
##  6. Markup Names of Groups
##  7. Internal Structure of Name Translator Objects
##
Revision.( "gpisotyp/gap/stdnames_gi" ) :=
    "@(#)$Id: stdnames.gi,v 1.6 2002/07/10 16:32:46 gap Exp $";


#############################################################################
##
##  0. Global variables for the package
##


#############################################################################
##
#F  ReadGpIsoTyp( <name> )  . . . . . . . . . . . . data files of the package
##
InstallGlobalFunction( "ReadGpIsoTyp",
    name -> DoRereadPkg( Concatenation( "gpisotyp/data/", name ),
                         "isomorphism types of groups" ) );


#############################################################################
##
IsMultipleOf4:= n -> n mod 4 = 0;
IsNotMultipleOf4:= n -> n mod 4 <> 0;


#############################################################################
##
#V  GpIsoTypGlobals
##
InstallValue( GpIsoTypGlobals, rec(
    SortNames                := true,
    TestNotificationsOfNames := true,
    ContradictoryConditions  := [ [ IsOddInt, IsEvenInt ],
#T better use `IsOddIntString', `IsEvenIntString',
#T and admit strings here, for understanding what is really meant
                                  [ IsMultipleOf4, IsNotMultipleOf4 ],
                                ] ) );


#############################################################################
##
##  1. Translated Names, Admissible Names, and Standard Names
##


#############################################################################
##
##  2. Name Translator Objects
##


#############################################################################
##
#F  EmptyNameTranslatorObject( <arec> )
##
InstallGlobalFunction( EmptyNameTranslatorObject, function( arec )
    local result, name;

    result:= rec(
        IndividualAdmissibleNames := [],
        IndividualTranslatedNames := [],
        ParametrizedNamesInfo     := [],

        ParseFunction             := ParseForwardsWithSuffix,
        NormalizedName            := IdFunc,

        SortNames                 := true,
        TestNotificationsOfNames  := true );

    for name in [ "SortNames", "TestNotificationsOfNames" ] do
      if IsBound( arec.( name ) ) and IsBool( arec.( name ) ) then
        result.( name ):= arec.( name );
      fi;
    od;
    for name in [ "ParseFunction", "NormalizedName" ] do
      if IsBound( arec.( name ) ) and IsFunction( arec.( name ) ) then
        result.( name ):= arec.( name );
      fi;
    od;

    return result;
    end );


#############################################################################
##
#F  FinishInitializationOfNameTranslatorObject( <nametransobj> )
##
##  This is used in the files `data/<...>.dat'.
##
BindGlobal( "FinishInitializationOfNameTranslatorObject",
    function( nametransobj )
    SortParallel( nametransobj.IndividualAdmissibleNames,
                  nametransobj.IndividualTranslatedNames );
    nametransobj.SortNames := true;
    nametransobj.TestNotificationsOfNames := true;
    end );


#############################################################################
##
#F  MappedMatchingName( <nametransobj>, <name>, <record> )
##
##  check whether the normalized name of <name>, w.r.t. the name translator
##  object <nametransobj>, matches the format in <record>,
##  and if yes then return the corresponding translated name.
##
BindGlobal( "MappedMatchingName", function( nametransobj, name, record )
    local match, cond, i, trn, map;

    # Check whether `name' matches `record.adm'.
    match:= nametransobj.ParseFunction( name, record.adm );
    if match = fail then
      return fail;
    fi;

    # Check whether `name' satisfies the conditions.
    cond:= record.cond;
    for i in [ 1, 3 .. Length( cond ) - 1 ] do
      if not CallFuncList( cond[ i+1 ], match{ cond[i] } ) then
        return fail;
      fi;
    od;

    # Map to the standard name.
    trn:= ShallowCopy( record.trn );
    map:= record.map;
    for i in [ 1, 4 .. Length( map ) - 2 ] do
      trn[ map[ i+2 ] ]:= String( map[ i+1 ]( match[ map[i] ] ) );
    od;

    # Now all entries in `trn' are supposed to be strings.
#T check this in the notif. of the format!
    return Concatenation( trn );
end );


#############################################################################
##
#F  TranslatedName( <nametransobj>, <name> )
##
InstallGlobalFunction( TranslatedName, function( nametransobj, name )
    local pos, record, trn;

    # Normalize the name.
    name:= nametransobj.NormalizedName( name );

    # Check the individual names.
    pos:= Position( nametransobj.IndividualAdmissibleNames, name );
    if pos <> fail then
      return nametransobj.IndividualTranslatedNames[ pos ];
    fi;

    # Check the parametrized names.
    for record in nametransobj.ParametrizedNamesInfo do
      trn:= MappedMatchingName( nametransobj, name, record );
      if trn <> fail then
        return trn;
      fi;
    od;

    # Check rules for composed names.
#T missing!

    # `name' is not admissible.
    return fail;
end );


#############################################################################
##
#F  AddToParallelLists( <list1>, <list2>, <entry1>, <entry2>, <sort> )
##
BindGlobal( "AddToParallelLists",
    function( list1, list2, entry1, entry2, sort )
    local len, pos, i;

    if sort = true then

      # <list2> must be strictly sorted afterwards.
      len:= Length( list2 );
      pos:= PositionSorted( list2, entry2 );
      for i in [ len, len-1 .. pos ] do
        list1[ i+1 ]:= list1[i];
        list2[ i+1 ]:= list2[i];
      od;
      list1[ pos ]:= entry1;
      list2[ pos ]:= entry2;
      SetIsSSortedList( list2, true );

    else

      # We just add the names.
      Add( list1, entry1 );
      Add( list2, entry2 );

    fi;
end );


#############################################################################
##
#F  NotifyIndividualTranslatedName( <nametransobj>, <name>, <translation> )
##
InstallGlobalFunction( NotifyIndividualTranslatedName,
    function( nametransobj, name, translation )
    local trans;

    if nametransobj.TestNotificationsOfNames then

      # If `name' is already admissible then it cannot be notified.
      trans:= TranslatedName( nametransobj, name );
      if trans = translation then
        Info( InfoGpIsoTyp, 1,
              "the translated name `", trans, "' was already notified" );
        return;
      elif trans <> fail then
        Error( "the translation of `", name, "' is `", trans,
               "' not `", translation, "'" );
      fi;

    fi;

    # Make `translation' admissible.
    AddToParallelLists( nametransobj.IndividualTranslatedNames,
                        nametransobj.IndividualAdmissibleNames,
                        Immutable( translation ),
                        Immutable( nametransobj.NormalizedName( name ) ),
                        nametransobj.SortNames );
end );


#############################################################################
##
#F  NotifyParametrizedTranslatedName( <nametransobj>, <nameformat>,
#F      <translatedformat>, <conditions>, <map> )
##
InstallGlobalFunction( NotifyParametrizedTranslatedName,
    function( nametransobj, nameformat, translatedformat, conditions, map )
    local i, admname, match, record;

    nameformat:= ShallowCopy( nameformat );
    for i in [ 1 .. Length( nameformat ) ] do
      if IsString( nameformat[i] ) then
        if IsEmpty( nameformat[i] ) then
          Error( "<nameformat> must not contain empty strings" );
        fi;
        nameformat[i]:= nametransobj.NormalizedName( nameformat[i] );
      fi;
    od;

    # Replace positions by lists of positions if necessary,
    # replace strings by functions if necessary.
    conditions:= ShallowCopy( conditions );
    for i in [ 1, 3 .. Length( conditions )-1 ] do
      if IsInt( conditions[i] ) then
        conditions[i]:= [ conditions[i] ];
      fi;
    od;
    for i in [ 2, 4 .. Length( conditions ) ] do
      if IsString( conditions[i] ) then
        conditions[i]:= EvalString( conditions[i] );
      fi;
    od;

    # Replace strings by functions if necessary.
    for i in [ 2, 5 .. Length( map )-1 ] do
      if IsString( map[i] ) then
        map[i]:= EvalString( map[i] );
      fi;
    od;

    if nametransobj.TestNotificationsOfNames then

      # Check that the first character of each string that occurs after
      # a function does not satisfy this function.
      for i in [ 1 .. Length( nameformat )-1 ] do
        if IsFunction( nameformat[i] ) and IsString( nameformat[ i+1 ] ) then
          if nameformat[i]( nameformat[ i+1 ][1] ) then
            Error( "the string at position ", i+1,
                   " must not match the function at position ", i );
          fi;
        fi;
      od;

      # Check that all conditions refer to positions of non-strings.
      for i in [ 1, 3 .. Length( conditions )-1 ] do
        if ForAny( conditions[i], j -> not IsBound( nameformat[j] ) ) then
          Error( "condition stated for unbound positions ",
                 Filtered( conditions[i],
                           j -> not IsBound( nameformat[j] ) ) );
        fi;
      od;

      # Check whether the position of each non-string in `translatedformat'
      # occurs exactly once as an image in `map'.
      for i in [ 1 .. Length( translatedformat ) ] do
        if IsFunction( translatedformat[i] ) then
          if Number( [ 3, 6 .. Length( map ) ], j -> map[j] = i ) <> 1 then
            Error( "position ", i,
                   " in <translatedformat> is not a unique image" );
          fi;
        fi;
      od;

      # Check whether one of the individual names matches.
      for admname in nametransobj.IndividualAdmissibleNames do
        match:= nametransobj.ParseFunction( admname, nameformat );
        if match <> fail then
          # Check whether `admname' satisfies the conditions.
          if ForAll( [ 1, 3 .. Length( conditions ) - 1 ],
                     i -> CallFuncList( conditions[ i+1 ],
                                        match{ conditions[i] } ) ) then
            Error( "<nameformat> and <conditions> match `", admname, "'" );
          fi;
        fi;
      od;

      # Check whether one of the parametrized names matches.
      for record in nametransobj.ParametrizedNamesInfo do
        if CompareFormatsOfParametrizedNames( record.adm, record.cond,
               nameformat, conditions ) = true then
          Error( "concurrent parametrized names <record> and <nameformat>" );
        fi;
      od;

    fi;

    # Add the new name.
    Add( nametransobj.ParametrizedNamesInfo,
         rec( adm  := nameformat,
              trn  := translatedformat,
              cond := conditions,
              map  := map ) );
end );


#############################################################################
##
##  3. Name Standardizer Objects
##


#############################################################################
##
#F  EmptyNameStandardizerObject( <arec> )
##
InstallGlobalFunction( EmptyNameStandardizerObject, function( arec )
    local result;

    result:= EmptyNameTranslatorObject( arec );
    result.IsNameStandardizer:= true;

    return result;
    end );


#############################################################################
##
#F  NotifyIndividualStandardName( <stdobj>, <name> )
##
InstallGlobalFunction( NotifyIndividualStandardName,
    function( stdobj, name )
#T only for standardizer objects!
    NotifyIndividualTranslatedName( stdobj, name, name );
end );


#############################################################################
##
#F  NotifyIndividualAdmissibleName( <stdobj>, <stdname>, <admname> )
##
InstallGlobalFunction( NotifyIndividualAdmissibleName,
    function( stdobj, stdname, admname )
#T only for standardizer objects!
    local std;

    if stdobj.TestNotificationsOfNames then

      # Test whether `stdname' is really a standard name.
      std:= StandardName( stdobj, stdname );
      if stdname = fail then
        Error( "`", stdname, "' is not an admissible name" );
      elif stdname <> std then
        Info( InfoGpIsoTyp, 1,
              "the name `", stdname, "' is not a standard name" );
        stdname:= std;
      fi;

    fi;

    # Make `admname' admissible as an individual name.
    NotifyIndividualTranslatedName( stdobj, admname, stdname );
end );


#############################################################################
##
#F  NotifyParametrizedStandardName( <stdobj>, <nameformat>, <conditions> )
##
InstallGlobalFunction( NotifyParametrizedStandardName,
    function( stdobj, nameformat, conditions )
#T only for standardizer objects!
    local map, i;

    # Construct a trivial mapping of entries.
    map:= [];
    for i in [ 1 .. Length( nameformat ) ] do
      if IsFunction( nameformat[i] ) then
        Append( map, [ i, IdFunc, i ] );
      fi;
    od;

    NotifyParametrizedTranslatedName( stdobj, nameformat, nameformat,
                                      conditions, map );
end );


#############################################################################
##
#F  NotifyParametrizedAdmissibleName( <stdobj>, <stdformat>, <admformat>,
#F      <conditions>, <map> )
##
InstallGlobalFunction( NotifyParametrizedAdmissibleName,
    function( stdobj, stdformat, admformat, conditions, map )
#T only for standardizer objects!
    local i;

    if stdobj.TestNotificationsOfNames then

      # Check whether `stdformat' is a parametrized standard name.
      if ForAll( stdobj.ParametrizedNamesInfo,
                 record -> CompareFormatsOfParametrizedNames( stdformat, [],
#T we have no conditions that refer to std ...
                               record.trn, record.cond ) = false ) then
        Error( "<stdformat> does not describe a parametrized standard name" );
      fi;

    fi;

    # Make `admformat' admissible as a parametrized name.
    NotifyParametrizedTranslatedName( stdobj, admformat, stdformat,
        conditions, map );
end );


#############################################################################
##
##  4. Admissible Names and Standard Names of Groups
##

#############################################################################
##
#F  StandardNameOfGroup( <name> )
##
InstallGlobalFunction( "StandardNameOfGroup",
    name -> TranslatedName( StandardizerForNamesOfGroups, name ) );


#############################################################################
##
##  5. A utility for names of finite simple groups
##


#############################################################################
##
#F  StandardNameOfFiniteSimpleGroupFromSeriesInfo( <info> )
##
InstallGlobalFunction( "StandardNameOfFiniteSimpleGroupFromSeriesInfo",
    function( info )
    local name, entry;

    name:= fail;
    if IsList( info ) then
      return List( info, StandardNameOfFiniteSimpleGroupFromSeriesInfo );
    elif IsRecord( info ) and IsBound( info.series )
                          and IsBound( info.parameter ) then
      if   info.series in [ "A", "Z" ] then
        name:= Concatenation( info.series, String( info.parameter ) );
      elif info.series in [ "L", "E" ] then
        name:= Concatenation( info.series, String( info.parameter[1] ),
                              "(", String( info.parameter[2] ), ")" );
      elif info.series = "B" then
        name:= Concatenation( "O", String( 2*info.parameter[1]+1 ),
                              "(", String( info.parameter[2] ), ")" );
      elif info.series = "C" then
        name:= Concatenation( "S", String( 2*info.parameter[1] ),
                              "(", String( info.parameter[2] ), ")" );
      elif info.series = "D" then
        name:= Concatenation( "O", String( 2*info.parameter[1] ),
                              "+(", String( info.parameter[2] ), ")" );
      elif info.series = "F" then
        name:= Concatenation( "F4(", String( info.parameter ), ")" );
      elif info.series = "G" then
        name:= Concatenation( "G2(", String( info.parameter ), ")" );
      elif info.series = "2A" then
        name:= Concatenation( "U", String( info.parameter[1]+1 ),
                              "(", String( info.parameter[2] ), ")" );
      elif info.series = "2B" then
        name:= Concatenation( "Sz(", String( info.parameter ), ")" );
      elif info.series = "2D" then
        name:= Concatenation( "O", String( 2*info.parameter[1] ),
                              "-(", String( info.parameter[2] ), ")" );
      elif info.series = "3D" then
        name:= Concatenation( "3D4(", String( info.parameter ), ")" );
      elif info.series = "2E" then
        name:= Concatenation( "2E6(", String( info.parameter ), ")" );
      elif info.series = "2F" and info.parameter = 2 then
        name:= "2F4(2)'";
      elif info.series = "2F" then
        name:= Concatenation( "2F4(", String( info.parameter ), ")" );
      elif info.series = "2G" then
        name:= Concatenation( "2G2(", String( info.parameter ), ")" );
      fi;
    elif IsRecord( info ) and IsBound( info.series ) and info.series = "Spor"
                          and IsBound( info.name ) then
      entry:= First( StandardizerForNamesOfGroups.SporadicSimpleGroupInfo,
                     x -> info.name = x[2] );
      if entry <> fail then
        name:= entry[1];
      fi;
    fi;

    if name <> fail then
      name:= StandardNameOfGroup( name );
    fi;

    return name;
end );


#############################################################################
##
##  6. Markup Names of Groups
##
##  to LaTeX: replace <sub>...</sub> by _{...}
##            replace <sup>...</sup> by ^{...} (if initial: prepend {}!)
##


#T hier!


#############################################################################
##
##  7. Internal Structure of Name Translator Objects
##


#############################################################################
##
#F  ParseBackwards( <string>, <format> )
##
InstallGlobalFunction( "ParseBackwards", function( string, format )
    local result, pos, j, pos2;

    # Scan the string backwards.
    result:= [];
    pos:= Length( string );
    for j in Reversed( format ) do
      if IsString( j ) then
        pos2:= pos - Length( j );
        if pos2 < 0 or string{ [ pos2+1 .. pos ] } <> j then
          return fail;
        fi;
      else
        pos2:= pos;
        while 0 < pos2 and j( string[ pos2 ] ) do
          pos2:= pos2-1;
        od;
      fi;
      if j = IsDigitChar then
        Add( result, Int( string{ [ pos2+1 .. pos ] } ) );
      else
        Add( result, string{ [ pos2+1 .. pos ] } );
      fi;
      pos:= pos2;
    od;
    if 0 < pos then
      return fail;
    fi;

    return Reversed( result );
    end );


#############################################################################
##
#F  ParseBackwardsWithPrefix( <string>, <format> )
##
InstallGlobalFunction( "ParseBackwardsWithPrefix", function( string, format )
    local prefixes, len, flen, fstr, fstrlen, result;

    # Remove string prefixes.
    prefixes:= [];
    len:= Length( string );
    flen:= Length( format );
    while 0 < flen and IsString( format[1] ) do
      fstr:= format[1];
      fstrlen:= Length( fstr );
      if len < fstrlen or string{ [ 1 .. fstrlen ] } <> fstr then
        return fail;
      fi;
      Add( prefixes, fstr );
      string:= string{ [ fstrlen + 1 .. len ] };
      format:= format{ [ 2 .. flen ] };
      len:= len - fstrlen;
      flen:= flen-1;
    od;

    # Parse the remaining string backwards.
    result:= ParseBackwards( string, format );
    if result = fail then
      return fail;
    fi;

    Append( prefixes, result );
    return prefixes;
end );


#############################################################################
##
#F  ParseForwards( <string>, <format> )
##
InstallGlobalFunction( "ParseForwards", function( string, format )
    local result, pos, j, pos2, len;

    result:= [];
    pos:= 0;
    for j in format do
      len:= Length( string );
      if IsString( j ) then
        pos2:= pos + Length( j );
        if len < pos2 or string{ [ pos+1 .. pos2 ] } <> j then
          return fail;
        fi;
      else
        pos2:= pos + 1;
        while pos2 <= len and j( string[ pos2 ] ) do
          pos2:= pos2 + 1;
        od;
        pos2:= pos2 - 1;
      fi;
      if j = IsDigitChar then
        Add( result, Int( string{ [ pos+1 .. pos2 ] } ) );
      else
        Add( result, string{ [ pos+1 .. pos2 ] } );
      fi;
      pos:= pos2;
    od;
    if pos <> len then
      return fail;
    fi;

    return result;
end );


#############################################################################
##
#F  ParseForwardsWithSuffix( <string>, <format> )
##
InstallGlobalFunction( "ParseForwardsWithSuffix", function( string, format )
    local suffixes, len, flen, fstr, fstrlen, result;

    # Remove string suffixes.
    suffixes:= [];
    len:= Length( string );
    flen:= Length( format );
    while 0 < flen and IsString( format[ flen ] ) do
      fstr:= format[ flen ];
      fstrlen:= Length( fstr );
      if len < fstrlen or string{ [ len-fstrlen+1 .. len ] } <> fstr then
        return fail;
      fi;
      suffixes:= Concatenation( [ fstr ], suffixes );
      len:= len - fstrlen;
      flen:= flen-1;
      string:= string{ [ 1 .. len ] };
      format:= format{ [ 1 .. flen ] };
    od;

    # Parse the remaining string forwards.
    result:= ParseForwards( string, format );
    if result = fail then
      return fail;
    fi;

    Append( result, suffixes );
    return result;
end );


#############################################################################
##
#F  CompareFormatsOfParametrizedNames( <fmt1>, <cond1>, <fmt2>, <cond2> )
##
##  Currently this is *very* experimental!
##
InstallGlobalFunction( "CompareFormatsOfParametrizedNames",
    function( fmt1, cond1, fmt2, cond2 )
    local i, fun, str, pos, totest, cond1curr, cond2curr, entry,
          fmt11, fmt21, cond11, cond21;

    fmt1:= ShallowCopy( fmt1 );
    fmt2:= ShallowCopy( fmt2 );
    cond1:= ShallowCopy( cond1 );
    cond2:= ShallowCopy( cond2 );

#T Print( "enter CFOPN with ", fmt1, ", ", cond1, ", ", fmt2, ", ", cond2, "\n" );
    while not IsEmpty( fmt1 ) and not IsEmpty( fmt2 ) do

      if IsString( fmt1[1] ) and IsString( fmt2[1] ) then
#T this depends on the parsing function!!
#T Print( "two strings: ", fmt1[1], " and ", fmt2[1], "\n" );

        # The formats are different if the strings do not match
        if Length( fmt1[1] ) < Length( fmt2[1] ) then
          if fmt1[1] = fmt2[1]{ [ 1 .. Length( fmt1[1] ) ] } then
            fmt2[1]:= fmt2[1]{ [ Length( fmt1[1] ) + 1 .. Length( fmt2[1] ) ] };
            fmt1:= fmt1{ [ 2 .. Length( fmt1 ) ] };
            for i in [ 1, 3 .. Length( cond1 )-1 ] do
              cond1[i]:= cond1[i] - 1;
            od;
          else
            return false;
          fi;
        elif Length( fmt2[1] ) < Length( fmt1[1] ) then
          if fmt2[1] = fmt1[1]{ [ 1 .. Length( fmt2[1] ) ] } then
            fmt1[1]:= fmt1[1]{ [ Length( fmt2[1] ) + 1 .. Length( fmt1[1] ) ] };
            fmt2:= fmt2{ [ 2 .. Length( fmt2 ) ] };
            for i in [ 1, 3 .. Length( cond2 )-1 ] do
              cond2[i]:= cond2[i] - 1;
            od;
          else
            return false;
          fi;
        else
          if fmt1[1] = fmt2[1] then
            fmt1:= fmt1{ [ 2 .. Length( fmt1 ) ] };
            fmt2:= fmt2{ [ 2 .. Length( fmt2 ) ] };
            for i in [ 1, 3 .. Length( cond1 )-1 ] do
              cond1[i]:= cond1[i] - 1;
            od;
            for i in [ 1, 3 .. Length( cond2 )-1 ] do
              cond2[i]:= cond2[i] - 1;
            od;
          else
            return false;
          fi;
        fi;

      elif IsString( fmt1[1] ) and IsFunction( fmt2[1] ) then
#T Print( "string and function: ", fmt1[1], " and ", fmt2[1], "\n" );

        # Remove the part of the string that matches and satisfies the
        # unary conditions;
#T note that for non-unary conditions, we are in trouble;
#T if they just exclude a finite number of exceptions then
#T nothing bad happens ...
#T Should the setup be changed:
#T admit only unary conditions, and introduce an additional component
#T that describes a finite number of exceptions!
        # if the string does not match completely then omit the function,
        # otherwise omit the string.
        fun:= fmt2[1];
        str:= fmt1[1];
        pos:= 1;
        while pos <= Length( str ) and fun( str[ pos ] ) do
          pos:= pos + 1;
        od;
        for i in [ 1, 3 .. Length( cond2 )-1 ] do
          if cond2[i] = [ 1 ] then
            if fun = IsDigitChar then
              totest:= Int( str{ [ 1 .. pos-1 ] } );
            else
              totest:= str{ [ 1 .. pos-1 ] };
            fi;
            if not cond2[ i+1 ]( totest ) then
              return false;
            fi;
          fi;
        od;
        if pos <= Length( str ) then
          fmt1[1]:= fmt1[1]{ [ pos .. Length( str ) ] };
          fmt2:= fmt2{ [ 2 .. Length( fmt2 ) ] };
          for i in [ 1, 3 .. Length( cond2 )-1 ] do
            cond2[i]:= cond2[i] - 1;
          od;
        else
          fmt1:= fmt1{ [ 2 .. Length( fmt1 ) ] };
          for i in [ 1, 3 .. Length( cond1 )-1 ] do
            cond1[i]:= cond1[i] - 1;
          od;
        fi;

      elif IsFunction( fmt1[1] ) and IsString( fmt2[1] ) then
#T Print( "function and string: ", fmt1[1], " and ", fmt2[1], "\n" );

        # Remove the part of the string that matches;
        # if the string does not match completely then omit the function,
        # otherwise omit the string.
        fun:= fmt1[1];
        str:= fmt2[1];
        pos:= 1;
        while pos <= Length( str ) and fun( str[ pos ] ) do
          pos:= pos + 1;
        od;
        for i in [ 1, 3 .. Length( cond1 )-1 ] do
          if cond1[i] = [ 1 ] then
            if fun = IsDigitChar then
              totest:= Int( str{ [ 1 .. pos-1 ] } );
            else
              totest:= str{ [ 1 .. pos-1 ] };
            fi;
            if not cond1[ i+1 ]( totest ) then
              return false;
            fi;
          fi;
        od;
        if pos <= Length( str ) then
          fmt2[1]:= fmt2[1]{ [ pos .. Length( str ) ] };
          fmt1:= fmt1{ [ 2 .. Length( fmt1 ) ] };
          for i in [ 1, 3 .. Length( cond1 )-1 ] do
            cond1[i]:= cond1[i] - 1;
          od;
        else
          fmt2:= fmt2{ [ 2 .. Length( fmt2 ) ] };
          for i in [ 1, 3 .. Length( cond2 )-1 ] do
            cond2[i]:= cond2[i] - 1;
          od;
        fi;

      else
#T Print( "two functions: ", fmt1[1], " and ", fmt2[1], "\n" );

        # Two functions;
        # if the conditions are known to be contradictory then return `false'.
#T only if the functions are equal?
        cond1curr:= [];
        for i in [ 1, 3 .. Length( cond1 )-1 ] do
          if cond1[i] = [ 1 ] then
            Add( cond1curr, cond1[ i+1 ] );
          fi;
        od;
        cond2curr:= [];
        for i in [ 1, 3 .. Length( cond2 )-1 ] do
          if cond2[i] = [ 1 ] then
            Add( cond2curr, cond2[ i+1 ] );
          fi;
        od;
# Error( "!" );
        for entry in GpIsoTypGlobals.ContradictoryConditions do
          if ( entry[1] in cond1curr and entry[2] in cond2curr ) or
             ( entry[1] in cond2curr and entry[2] in cond1curr ) then
#T Print( "contradictory!\n" );
            return false;
          fi;
        od;
#T Print( "not contradictory:", cond1curr, cond2curr, "\n" );

        # We branch by omitting either both or one of them,
        # provided that the additional conditions do not exclude this.
        # (If a condition implies that the substring in question is nonempty,
        # for example `IsOddInt' or `IsPosInt' or `IsPrimePowerInt',
        # then the omission of exactly this function cannot occur.
        fmt11:= fmt1{ [ 2 .. Length( fmt1 ) ] };
        fmt21:= fmt2{ [ 2 .. Length( fmt2 ) ] };
        cond11:= ShallowCopy( cond1 );
        for i in [ 1, 3 .. Length( cond11 )-1 ] do
          cond11[i]:= cond11[i] - 1;
        od;
        cond21:= ShallowCopy( cond2 );
        for i in [ 1, 3 .. Length( cond21 )-1 ] do
          cond21[i]:= cond21[i] - 1;
        od;
#T Print( "case1: ", CompareFormatsOfParametrizedNames( fmt11, cond11, fmt2, cond2  ), "\n" );
        if   CompareFormatsOfParametrizedNames( fmt11, cond11, fmt2, cond2  ) <> false then
          return true;
#T return `fail' if the result is `fail'!
        fi;
#T Print( "case2: ", CompareFormatsOfParametrizedNames( fmt1, cond1, fmt21, cond21  ), "\n" );
        if CompareFormatsOfParametrizedNames( fmt1 , cond1,  fmt21, cond21 ) <> false then
          return true;
        fi;
#T Print( "case3: ", CompareFormatsOfParametrizedNames( fmt11, cond11, fmt21, cond21  ), "\n" );
        if CompareFormatsOfParametrizedNames( fmt11, cond11, fmt21, cond21 ) <> false then
          return true;
        fi;
        return false;

      fi;
    od;

    while not IsEmpty( fmt1 ) and IsFunction( fmt1[1] ) do
      fmt1:= fmt1{ [ 2 .. Length( fmt1 ) ] };
      for i in [ 1, 3 .. Length( cond1 )-1 ] do
        cond1[i]:= cond1[i] - 1;
      od;
    od;
    while not IsEmpty( fmt2 ) and IsFunction( fmt2[1] ) do
      fmt2:= fmt2{ [ 2 .. Length( fmt2 ) ] };
      for i in [ 1, 3 .. Length( cond2 )-1 ] do
        cond2[i]:= cond2[i] - 1;
      od;
    od;

    if IsEmpty( fmt1 ) and IsEmpty( fmt2 ) then
      return true;
    else
      return false;
    fi;
end );


#############################################################################
##
#E

