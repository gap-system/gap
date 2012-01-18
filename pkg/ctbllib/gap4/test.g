#############################################################################
##
#W  test.g               GAP 4 package CTblLib                  Thomas Breuer
##
#Y  Copyright (C)  2011,   Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  This file contains functions to test the data available in the
##  GAP Character Table Library.
##


#############################################################################
##
##  <#GAPDoc Label="tests">
##  The fact that the &GAP; Character Table Library is designed as an
##  open database
##  (see Chapter&nbsp;<Ref Chap="ch:introduction"/>)
##  makes it especially desirable to have consistency checks available
##  which can be run automatically whenever new data are added.
##  <P/>
##  The file <F>tst/testall.g</F> of the package
##  contains <Ref Func="ReadTest" BookName="ref"/> statements
##  for executing a collection of such sanity checks;
##  one can run them by calling
##  <C>ReadPackage( "CTblLib", "tst/testall.g" )</C>.
##  If no problem occurs then &GAP; prints only lines starting with one of
##  the following.
##  <P/>
##  <Log><![CDATA[
##  + Input file:
##  + GAP4stones:
##  ]]></Log>
##  <P/>
##  The examples in the package manual form a part of the tests,
##  they are collected in the file <F>tst/docxpl.tst</F> of the package.
##  <P/>
##  The following tests concern only <E>ordinary</E> character tables.
##  In all cases,
##  let <A>tbl</A> be the ordinary character table of a group <M>G</M>, say.
##  The return value is <K>false</K> if an error occurred,
##  and <K>true</K> otherwise.
##  <P/>
##  <List>
##  <#Include Label="test:CTblLib.Test.InfoText">
##  <#Include Label="test:CTblLib.Test.RelativeNames">
##  <#Include Label="test:CTblLib.Test.FindRelativeNames">
##  <#Include Label="test:CTblLib.Test.PowerMaps">
##  <#Include Label="test:CTblLib.Test.TableAutomorphisms">
##  <#Include Label="test:CTblLib.Test.CompatibleFactorFusions">
##  <#Include Label="test:CTblLib.Test.FactorsModPCore">
##  <#Include Label="test:CTblLib.Test.Fusions">
##  <#Include Label="test:CTblLib.Test.Maxes">
##  <#Include Label="test:CTblLib.Test.ClassParameters">
##  <#Include Label="test:CTblLib.Test.Constructions">
##  <#Include Label="test:CTblLib.Test.GroupForGroupInfo">
##  </List>
##  <P/>
##  The following tests concern only <E>modular</E> character tables.
##  In all cases,
##  let <A>modtbl</A> be a Brauer character table of a group <M>G</M>, say.
##  <P/>
##  <List>
##  <#Include Label="test:CTblLib.Test.BlocksInfo">
##  <#Include Label="test:CTblLib.Test.TensorDecomposition">
##  <#Include Label="test:CTblLib.Test.Indicators">
##  <#Include Label="test:CTblLib.Test.FactorBlocks">
##  </List>
##  <#/GAPDoc>
##


#############################################################################
##
##  1. General tools for checking character tables
##

CTblLib.BlanklessString:= function( obj, ncols )
    local result, stream;

    result:= "";
    stream:= OutputTextString( result, true );
    SetPrintFormattingStatus( stream, true );
    BlanklessPrintTo( stream, obj, ncols, 0, false );
    CloseStream( stream );
    return result;
end;

CTblLib.Test.BracketsString:= function( string )
    local pos, open, i, partner;

    pos:= 1;
    open:= [];
    for i in [ 1 .. Length( string ) ] do
      if string[i] in "({[" then
        Add( open, string[i] );
      elif string[i] in ")}]" then
        if Length( open ) = 0 then
          return false;
        fi;
        partner:= open[ Length( open ) ];
        if ( string[i] = ')' and partner = '(' ) or
           ( string[i] = '}' and partner = '{' ) or
           ( string[i] = ']' and partner = '[' ) then
          Unbind( open[ Length( open ) ] );
        else
          return false;
        fi;
      fi;
    od;
    return IsEmpty( open );
end;


#############################################################################
##
#F  CTblLib.PrintTestLog( <type>, <functionname>, <tblname>, <texts1>,
#F                       <texts2>, ... )
#F  CTblLib.PrintTestLog( <type>, <functionname>, <tblname>, <textlist> )
##
##  This function is used in the test functions in this file.
##  <type> should be one of the strings "E", "I";
##
CTblLib.PrintTestLog:= function( arg )
    local type, functionname, info, pos, tblname, texts, libinfo, text, entry;

    type:= arg[1];         # either "E" or "I"
    functionname:= arg[2];
    info:= arg[3];
    pos:= PositionSublist( info, " -> " );
    if pos = fail then
      tblname:= info;
    else
      tblname:= info{ [ 1 .. pos-1 ] };
    fi;
    texts:= arg{ [ 4 .. Length( arg  ) ] };
    if Length( texts ) = 1 and IsList( texts[1] )
                           and not IsString( texts[1] ) then
      texts:= texts[1];
    fi;
    libinfo:= LibInfoCharacterTable( tblname );
    if libinfo = fail then
      libinfo:= "no library file";
    else
      libinfo:= libinfo.fileName;
    fi;
    Print( "#", type, "  ", functionname, ":\n",
           "#", type, "  for " );
    if tblname = info then
      Print( "table ", tblname, " (in ", libinfo, ")\n" );
    else
      Print( info, " (in ", libinfo, ")\n" );
    fi;
    for text in texts do
      Print( "#", type, "  " );
      if IsString( text ) or not IsList( text ) then
        Print( text );
      else
        for entry in text do
          Print( entry );
        od;
      fi;
      Print( "\n" );
    od;
end;


#############################################################################
##
#F  CTblLib.AdmissibleNames( <tblname> )
##
CTblLib.AdmissibleNames:= function( tblname )
    local pos;

    pos:= Position( LIBLIST.allnames, LowercaseString( tblname ) );
    if pos = fail then
      # The table does not belong to the library.
      return [ tblname ];
#T not clean but needed in the functions below,
#T in order to deal with new tables before adding them?
    else
      pos:= LIBLIST.position[ pos ];
      return LIBLIST.allnames{ Filtered( [ 1 .. Length( LIBLIST.position ) ],
                                         i -> LIBLIST.position[i] = pos ) };
    fi;
end;


#############################################################################
##
#F  CTblLib.Test.RelativeNames( <tbl>[, <tblname>] )
##
##  <#GAPDoc Label="test:CTblLib.Test.RelativeNames">
##  <Mark><C>CTblLib.Test.RelativeNames( <A>tbl</A>[, <A>tblname</A>] )</C></Mark>
##  <Item>
##    checks some properties of those admissible names for <A>tbl</A>
##    that refer to a related group <M>H</M>, say.
##    Let <A>name</A> be an admissible name for the character table of
##    <M>H</M>.  (In particular, <A>name</A> is not an empty string.)
##    Then the following relative names are considered.
##    <P/>
##    <List>
##    <Mark><A>name</A><C>M</C><M>n</M></Mark>
##    <Item>
##      <M>G</M> is isomorphic with the groups in the <M>n</M>-th class of
##      maximal subgroups of <M>H</M>.
##      An example is <C>"M12M1"</C> for the Mathieu group <M>M_{11}</M>.
##      We consider only cases where <A>name</A> does <E>not</E> contain
##      the letter <C>x</C>.
##      For example, <C>2xM12</C> denotes the direct product of a cyclic group
##      of order two and the Mathieu group <M>M_{12}</M>
##      but <E>not</E> a maximal subgroup of <Q><C>2x</C></Q>.
##      Similarly, <C>3x2.M22M5</C> denotes the direct product of a cyclic
##      group of order three and a group in the fifth class of maximal
##      subgroups of <M>2.M_{22}</M>
##      but <E>not</E> a maximal subgroup of <Q><C>3x2.M22</C></Q>.
##    </Item>
##    <Mark><A>name</A><C>N</C><M>p</M></Mark>
##    <Item>
##      <M>G</M> is isomorphic with the normalizers of the
##      Sylow <M>p</M>-subgroups of <M>H</M>.
##      An example is <C>"M24N2"</C> for the (self-normalizing)
##      Sylow <M>2</M>-subgroup in the Mathieu group <M>M_{24}</M>.
##    </Item>
##    <Mark><A>name</A><C>N</C><A>cnam</A></Mark>
##    <Item>
##      <M>G</M> is isomorphic with the normalizers of the
##      cyclic subgroups generated by the elements in the class with the name
##      <A>cnam</A> of <M>H</M>.
##      An example is <C>"O7(3)N3A"</C> for the normalizer of an element
##      in the class <C>3A</C> of the simple group <M>O_7(3)</M>.
##    </Item>
##    <Mark><A>name</A><C>C</C><A>cnam</A></Mark>
##    <Item>
##      <M>G</M> is isomorphic with the groups in the centralizers of the
##      elements in the class with the name <A>cnam</A> of <M>H</M>.
##      An example is <C>"M24C2A"</C> for the centralizer of an element in the
##      class <C>2A</C> in the Mathieu group <M>M_{24}</M>.
##    </Item>
##    </List>
##    <P/>
##    In these cases, <C>CTblLib.Test.RelativeNames</C> checks whether a
##    library table with the admissible name <A>name</A> exists and a class
##    fusion to <A>tbl</A> is stored on this table.
##    <P/>
##    In the case of Sylow <M>p</M>-normalizers,
##    it is also checked whether <M>G</M> contains a normal
##    Sylow <M>p</M>-subgroup of the same order as the
##    Sylow <M>p</M>-subgroups in <M>H</M>.
##    If the normal Sylow <M>p</M>-subgroup of <M>G</M> is cyclic then it is
##    also checked whether <M>G</M> is the full Sylow <M>p</M>-normalizer in
##    <M>H</M>.
##    (In general this information cannot be read off
##    from the character table of <M>H</M>).
##    <P/>
##    In the case of normalizers (centralizers) of cyclic subgroups,
##    it is also checked whether <M>H</M> really normalizes (centralizes) a
##    subgroup of the given order,
##    and whether the class fusion from <A>tbl</A> to the table of <M>H</M>
##    is compatible with the relative name.
##    <P/>
##    If the optional argument <A>tblname</A> is given then only this name
##    is tested.
##    If there is only one argument then all admissible names for <A>tbl</A>
##    are tested.
##  </Item>
##  <#/GAPDoc>
##
CTblLib.Test.RelativeNames:= function( arg )
    local result, tbl, name, tocheck, tblname, parse, filt, p, size, classes,
          supertbl, orders, centralizers, cand, cen, fus, classname, cname,
          orbits, supname;

    result:= true;
    tbl:= arg[1];
    if Length( arg ) = 1 then
      for name in CTblLib.AdmissibleNames( Identifier( tbl ) ) do
        result:= CTblLib.Test.RelativeNames( tbl, name ) and result;
      od;
    else
      tocheck:= [];
      tblname:= Identifier( tbl );
      name:= LowercaseString( arg[2] );

      # The names of ordinary tables must not involve the substring `mod'.
      if PositionSublist( tblname, "mod" ) <> fail then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.RelativeNames", tblname,
            [ [ "`", name, "' contains substring `mod'" ] ] );
        result:= false;
      fi;

      # Brackets in the name must occur in pairs.
      if not CTblLib.Test.BracketsString( name ) then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.RelativeNames", tblname,
            [ [ "inconsistent brackets in `", name, "'" ] ] );
        result:= false;
      fi;

      # Check names of the form <grpname>M<n>.
      # (We are not interested in names such as "3xM12" or "3x2.M22M5".)
      parse:= PParseBackwards( name, [ IsChar, "m", IsDigitChar ] );
      if parse <> fail and parse[3] <> 0 and not 'x' in parse[1] then
        Add( tocheck, parse[1] );
      fi;

      # Check names of the form <grpname>N<p>.
      parse:= PParseBackwards( name, [ IsChar, "n", IsDigitChar ] );
      if parse <> fail and parse[3] <> 0 then
        p:= parse[3];
        if not IsPrimeInt( p ) then
          CTblLib.PrintTestLog( "E", "CTblLib.Test.RelativeNames", tblname,
              [ [ "`", p, "' is not a prime" ] ] );
          result:= false;
        else
          Add( tocheck, parse[1] );
          # Check whether the Sylow `p' subgroup is normal.
          size:= p ^ Number( Factors( Size( tbl ) ), x -> x = p );
          classes:= SizesConjugacyClasses( tbl );
          if ForAll( ClassPositionsOfNormalSubgroups( tbl ),
                     l -> Sum( classes{ l } ) <> size ) then
            CTblLib.PrintTestLog( "E", "CTblLib.Test.RelativeNames", tblname,
                [ [ "Sylow ", p, " subgroup is not normal" ] ] );
            result:= false;
          fi;
          # Check whether the two Sylow `p' subgroups have the same order.
          supertbl:= CharacterTable( parse[1] );
          if supertbl <> fail then
            if size
               <> p ^ Number( Factors( Size( supertbl ) ), x -> x = p ) then
              CTblLib.PrintTestLog( "E", "CTblLib.Test.RelativeNames", tblname,
                  [ [ "the Sylow ", p, " subgroup of `", parse[1],
                      "' has different order" ] ] );
              result:= false;
            fi;

            # If the Sylow `p' subgroup is cyclic then check the order of the
            # normalizer.
            orders:= OrdersClassRepresentatives( supertbl );
            if size in orders and
               Size( tbl )
               <> SizesCentralizers( supertbl )[ Position( orders, size ) ]
                  * Phi( size ) / Number( orders, x -> x = size ) then
              CTblLib.PrintTestLog( "E", "CTblLib.Test.RelativeNames", tblname,
                  [ [ "order is not that of the Sylow ", p,
                      " normalizer of `", parse[1], "'" ] ] );
              result:= false;
            fi;
          fi;
        fi;
      fi;

      # Check names of the form <grpname>C<nam>.
      parse:= PParseBackwards( name,
                  [ IsChar, "c", IsDigitChar, IsAlphaChar ] );
      if parse <> fail and parse[3] <> 0 and not IsEmpty( parse[4] ) then
        Add( tocheck, parse[1] );
        supertbl:= CharacterTable( parse[1] );
        if supertbl <> fail then
          # Check whether a class in the big group has a centralizer order
          # equal to the order of `tbl',
          # such that the class fusion is compatible with that.
          centralizers:= SizesCentralizers( supertbl );
          orders:= OrdersClassRepresentatives( supertbl );
          cand:= Filtered( [ 1 .. Length( centralizers ) ],
                           i -> centralizers[i] = Size( tbl ) and
                                orders[i] = parse[3] );
          if IsEmpty( cand ) then
            CTblLib.PrintTestLog( "E", "CTblLib.Test.RelativeNames", tblname,
                [ [ "not the centralizer of an el. of order ", parse[3],
                    " in `", parse[1], "'" ] ] );
            result:= false;
          else
            orders:= OrdersClassRepresentatives( tbl );
            cen:= Filtered( ClassPositionsOfCentre( tbl ),
                            i -> orders[i] = parse[3] );
            fus:= GetFusionMap( tbl, supertbl );
            if fus <> fail then
              cen:= Filtered( cen, i -> fus[i] in cand );
            fi;
            if IsEmpty( cen ) then
              CTblLib.PrintTestLog( "E", "CTblLib.Test.RelativeNames", tblname,
                  [ [ "not the centralizer of an el. of order ", parse[3],
                      " in `", parse[1], "'" ] ] );
              result:= false;
            elif fus <> fail then
              classname:= LowercaseString( Concatenation(
                  String( parse[3] ), parse[4] ) );
              cname:= List( ClassNames( supertbl ){ fus{ cen } },
                            LowercaseString );
              if not classname in cname then
                CTblLib.PrintTestLog( "E", "CTblLib.Test.RelativeNames", tblname,
                    [ "centralizer in `", parse[1], "' of a class in `" ],
                    [ String( cname ), "' not of `", classname, "'" ] );
                result:= false;
              fi;
            fi;
          fi;
        fi;
      fi;

      # Check names of the form <grpname>N<nam>.
      parse:= PParseBackwards( name,
                  [ IsChar, "n", IsDigitChar, IsAlphaChar ] );
      if parse <> fail and parse[3] <> 0 and not IsEmpty( parse[4] ) then
        Add( tocheck, parse[1] );
        supertbl:= CharacterTable( parse[1] );
        if supertbl <> fail then
          # Check whether a class in the big group has a normalizer order
          # equal to the order of `tbl',
          # such that the class fusion is compatible with that.
          centralizers:= SizesCentralizers( supertbl );
          orders:= OrdersClassRepresentatives( supertbl );
          orbits:= List( [ 1 .. NrConjugacyClasses( supertbl ) ],
                         i -> Length( ClassOrbit( supertbl, i ) ) );
          cand:= Filtered( [ 1 .. Length( centralizers ) ],
                           i -> centralizers[i] * Phi( orders[i] )
                                / orbits[i] = Size( tbl ) and
                                orders[i] = parse[3] );
          if IsEmpty( cand ) then
            CTblLib.PrintTestLog( "E", "CTblLib.Test.RelativeNames", tblname,
                [ [ "not the centralizer of an el. of order ", parse[3],
                    " in `", parse[1], "'" ] ] );
            result:= false;
          else
            orders:= OrdersClassRepresentatives( tbl );
            classes:= SizesConjugacyClasses( tbl );
            cen:= Filtered( [ 1 .. Length( orders ) ],
                    i -> orders[i] = parse[3] and
                         orders[i] = Sum(
              classes{ ClassPositionsOfNormalClosure( tbl, [ i ] ) } ) );
            fus:= GetFusionMap( tbl, supertbl );
            if fus <> fail then
              cen:= Filtered( cen, i -> fus[i] in cand );
            fi;
            if IsEmpty( cen ) then
              CTblLib.PrintTestLog( "E", "CTblLib.Test.RelativeNames", tblname,
                  [ [ "not the normalizer of an el. of order ", parse[3],
                      " in `", parse[1], "'" ] ] );
              result:= false;
            elif fus <> fail then
              classname:= LowercaseString( Concatenation(
                  String( parse[3] ), parse[4] ) );
              cname:= List( ClassNames( supertbl ){ fus{ cen } },
                            LowercaseString );
              if not classname in cname then
                CTblLib.PrintTestLog( "E", "CTblLib.Test.RelativeNames", tblname,
                    [ "normalizer in `", parse[1], "' of a class in `" ],
                    [ String( cname ), "' not of `", classname, "'" ] );
                result:= false;
              fi;
            fi;
          fi;
        fi;
      fi;

      for supname in tocheck do
        supertbl:= CharacterTable( supname );
        if supertbl = fail then
          CTblLib.PrintTestLog( "E", "CTblLib.Test.RelativeNames", tblname,
              [ [ "no character table with name `", supname, "'" ] ] );
          result:= false;
        elif GetFusionMap( tbl, supertbl ) = fail then
          # Check that a class fusion is stored.
          CTblLib.PrintTestLog( "I", "CTblLib.Test.RelativeNames", tblname,
              [ [ "no fusion to `", Identifier( supertbl ), "' stored" ] ] );
          fus:= CTblLib.Test.SubgroupFusion( tbl, supertbl );
          if IsRecord( fus ) then
            CTblLib.PrintTestLog( "I", "CTblLib.Test.RelativeNames", tblname,
                "store the following fusion" );
            Print( LibraryFusion( tbl, fus ) );
          fi;
          result:= false;
        fi;
      od;
    fi;

    return result;
    end;


#############################################################################
##
#F  CTblLib.Test.FindRelativeNames( <tbl> )
##
##  <#GAPDoc Label="test:CTblLib.Test.FindRelativeNames">
##  <Mark><C>CTblLib.Test.FindRelativeNames( <A>tbl</A> )</C></Mark>
##  <Item>
##    runs over the class fusions stored on <A>tbl</A>.
##    If <A>tbl</A> is the full centralizer/normalizer of a cyclic subgroup
##    in the table to which the class fusion points
##    then the function proposes to make the corresponding relative name
##    an admissible name for <A>tbl</A>.
##  </Item>
##  <#/GAPDoc>
##
CTblLib.Test.FindRelativeNames:= function( tbl )
    local orders, classes, cen, nor, result, tocheck, record, fus, supertbl,
          centralizers, superclasses, i, orbits, j, name, info;

    orders:= OrdersClassRepresentatives( tbl );
    classes:= SizesConjugacyClasses( tbl );
    cen:= ClassPositionsOfCentre( tbl );
    nor:= Filtered( [ 1 .. NrConjugacyClasses( tbl ) ],
              i -> orders[i] = Sum( classes{
                   ClassPositionsOfNormalClosure( tbl, [ i ] ) } ) );

    result:= true;

    tocheck:= [];
    for record in ComputedClassFusions( tbl ) do
      fus:= record.map;
      if Length( ClassPositionsOfKernel( fus ) ) = 1 then
        supertbl:= CharacterTable( record.name );
        if supertbl <> fail then
          centralizers:= SizesCentralizers( supertbl );
          superclasses:= SizesConjugacyClasses( supertbl );
          orders:= OrdersClassRepresentatives( supertbl );
          # Is `tbl' is an element centralizer in a bigger table?
          if 1 < Length( cen ) then
            for i in [ 2 .. Length( cen ) ] do
              if centralizers[ fus[ cen[i] ] ] = Size( tbl ) and
                 not orders[ fus[ cen[i] ] ]
                     = Sum( superclasses{ ClassPositionsOfNormalClosure(
                              supertbl, [ fus[ cen[i] ] ] ) } ) and
                 not orders[ fus[ cen[i] ] ] = 2 then
                Add( tocheck, Concatenation( Identifier( supertbl ), "C",
                                ClassNames( supertbl )[ fus[ cen[i] ] ] ) );
              fi;
            od;
          fi;

          # Is `tbl' is an element normalizer in a bigger table?
          if 1 < Length( nor ) then
            orbits:= List( [ 1 .. NrConjugacyClasses( supertbl ) ],
                           i -> Length( ClassOrbit( supertbl, i ) ) );
            for i in [ 2 .. Length( nor ) ] do
              j:= fus[ nor[i] ];
              if centralizers[j] * Phi( orders[j] ) / orbits[j]
                 = Size( tbl ) and
                 not orders[ fus[ nor[i] ] ]
                 = Sum( superclasses{ ClassPositionsOfNormalClosure(
                            supertbl, [ fus[ nor[i] ] ] ) } ) then
                if IsPrimePowerInt( orders[j] ) and
                   Gcd( orders[j], Size( supertbl ) / orders[j] ) = 1 then
                  # Prefer the Sylow normalizer name.
                  Add( tocheck, Concatenation( Identifier( supertbl ), "N",
                                    String( Factors( orders[j] )[1] ) ) );
                else
                  # Choose the name of the normalizer of a cyclic subgroup.
                  Add( tocheck, Concatenation( Identifier( supertbl ), "N",
                    ClassNames( supertbl )[ fus[ nor[i] ] ] ) );
                fi;
              fi;
            od;
          fi;
        fi;
      fi;
    od;

    for name in Set( tocheck ) do
      info:= LibInfoCharacterTable( name );
      if info = fail then
        CTblLib.PrintTestLog( "I", "CTblLib.Test.FindRelativeNames",
            Identifier( tbl ),
            [ [ "add the new name `", name, "'" ] ] );
      elif info.firstName <> Identifier( tbl ) then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.FindRelativeNames",
            Identifier( tbl ),
            [ [ "`", name, "' should be a name for `",
                Identifier( tbl ), "' not `", info.firstName, "'" ] ] );
        result:= false;
      fi;
    od;

    return result;
    end;


#############################################################################
##
#F  CTblLib.Test.Decompositions( <sub>, <fuslist>, <tbl> )
##
##  Let <sub> and <tbl> be ordinary character tables, and <fuslist> a list of
##  possible class fusions from <sub> to <tbl>.
##
##  `CTblLibTestDecompositions' returns the set of all those entries in
##  <fuslist> such that for all available $p$-modular Brauer tables of <sub>
##  and <tbl>, the $p$-modular Brauer characters of <tbl> decompose into
##  $p$-modular Brauer characters of <sub>.
##
CTblLib.Test.Decompositions:= function( sub, fuslist, tbl )
    local bad, p, modtbl, modsub, modfuslist, modfus;

    if IsEmpty( fuslist ) then
      return [];
    fi;

    bad:= [];

    for p in Set( Factors( Size( tbl ) ) ) do
      modtbl:= tbl mod p;
      if modtbl <> fail then
        modsub:= sub mod p;
        if modsub <> fail then
          modfuslist:= List( fuslist, fus ->
              CompositionMaps( InverseMap( GetFusionMap( modtbl, tbl ) ),
                               CompositionMaps( fus,
                                   GetFusionMap( modsub, sub ) ) ) );
          for modfus in Set( modfuslist ) do
            if fail in Decomposition( Irr( modsub ),
                           List( Irr( modtbl ), chi -> chi{ modfus } ),
                           "nonnegative" ) then
              UniteSet( bad,
                  fuslist{ Filtered( [ 1 .. Length( fuslist ) ],
                                     i -> modfuslist[i] = modfus ) } );
            fi;
          od;
        fi;
      fi;
    od;

    return Difference( fuslist, bad );
    end;
#T Jon Thackray says: LinearIndependentColumns runs forever in
#T some computation with Ly ...


#############################################################################
##
#V  CTblLib.IgnoreFactorFusionsCompatibility
#F  CTblLib.PermutationInducedOnFactor( <factfus>, <perm> )
#F  CTblLib.Test.CompatibleFactorFusions( <tbl> )
##
##  <#GAPDoc Label="test:CTblLib.Test.CompatibleFactorFusions">
##  <Mark><C>CTblLib.Test.CompatibleFactorFusions( <A>tbl</A> )</C></Mark>
##  <Item>
##    checks whether triangles and quadrangles of factor fusions from
##    <A>tbl</A> to other library tables commute
##    (where the entries in the list
##    <C>CTblLib.IgnoreFactorFusionsCompatibility</C> are excluded from the
##    tests),
##    and whether the factor fusions commute with the actions of
##    corresponding outer automorphisms.
##  </Item>
##  <#/GAPDoc>
##
CTblLib.IgnoreFactorFusionsCompatibility:= [
    [ "2x2^3:L3(2)x2", "2x2^3:L3(2)", "C2" ],
    [ "2.A5xA5", "2.A5", "A5" ],
    [ "2.A5xA5", "A5xA5", "A5" ],
    [ "2.A5xA5", Set( [ "A5xA5", "2.A5" ] ), "A5" ],
  ];

CTblLib.PermutationInducedOnFactor:= function( factfus, perm )
    local ind, i, pre, img;

    ind:= [];
    for i in [ 1 .. Length( factfus ) ] do
      pre:= factfus[i];
      img:= factfus[ i^perm ];
      if IsBound( ind[ pre ] ) then
        if ind[ pre ] <> img then
          return fail;
        fi;
      else
        ind[ pre ]:= img;
      fi;
    od;
    return PermList( ind );
    end;

CTblLib.Test.CompatibleFactorFusions:= function( tbl )
    local result, tbls, ids, incid, t, factfus, facttbl, comp, triple1,
          triple2, i, j, auts, fact, ker, triple, factauts, ind, kerimg,
          supfact, facttriple;

    result:= true;

    # Collect factor fusions from `tbl' to other tables,
    # and from these tables to other tables.
    tbls:= [ tbl ];
    ids:= [ Identifier( tbl ) ];
    incid:= [];
    for t in tbls do
      for factfus in Filtered( ComputedClassFusions( t ),
              r -> 1 < Length( ClassPositionsOfKernel( r.map ) ) ) do
        if not factfus.name in ids then
          facttbl:= CharacterTable( factfus.name );
          if facttbl <> fail then
            Add( ids, factfus.name );
            Add( tbls, facttbl );
          fi;
        fi;
        Add( incid, [ Identifier( t ), factfus.name, factfus.map ] );
      od;
    od;

    # Check triangles and quadrangles in the directed graph.
    comp:= [];
    for triple1 in incid do
      for triple2 in incid do
        if triple1[2] = triple2[1] then
          # for t1 -> t2 and t2 -> t3, store [ t1, t3, map, t2 ]
          Add( comp, [ triple1[1], triple2[2],
               CompositionMaps( triple2[3], triple1[3] ), triple1[2] ] );
        fi;
      od;
    od;
    for i in [ 1 .. Length( comp ) ] do
      triple1:= comp[i];
      # triangles
      for triple2 in incid do
        if triple1[1] = triple2[1] and triple1[2] = triple2[2] and
           triple1[3] <> triple2[3] and
           not [ triple1[1], triple1[4], triple1[2] ] in
             CTblLib.IgnoreFactorFusionsCompatibility then
          CTblLib.PrintTestLog( "E", "CTblLib.Test.CompatibleFactorFusions",
              Identifier( tbl ),
              [ [ "inconsistent triangle: ", triple1[1], " ->> ", triple1[4],
                  " ->> ", triple1[2] ] ] );
          result:= false;
        fi;
      od;
      # quadrangles
      for j in [ 1 .. i-1 ] do
        triple2:= comp[j];
        if triple1[1] = triple2[1] and triple1[2] = triple2[2] and
           triple1[3] <> triple2[3] and
           not [ triple1[1], Set( [ triple1[4], triple2[4] ] ), triple1[2] ] in
             CTblLib.IgnoreFactorFusionsCompatibility then
          CTblLib.PrintTestLog( "E", "CTblLib.Test.CompatibleFactorFusions",
              Identifier( tbl ),
              [ [ "inconsistent quadrangle: ",
                  triple1[1], " ->> (", triple1[4], " or ",
                  triple2[4], ") ->> ", triple1[2] ] ] );
          result:= false;
        fi;
      od;
    od;

    # Check compatibility of factor fusions with outer automorphims.
    auts:= CTblLib.PermutationsInducedByOuterAutomorphisms( tbl );
    for factfus in Filtered( ComputedClassFusions( t ),
            r -> 1 < Length( ClassPositionsOfKernel( r.map ) ) ) do
      fact:= CharacterTable( factfus.name );
      if fact <> fail then
        ker:= ClassPositionsOfKernel( factfus.map );
        for triple in auts do
          if Set( ker ) = Set( OnTuples( ker, triple[1] ) ) then
            # The outer automorphism acts on the factor group.
            factauts:= CTblLib.PermutationsInducedByOuterAutomorphisms( fact );
            ind:= CTblLib.PermutationInducedOnFactor( factfus.map, triple[1] );
            if ind <> fail then
              kerimg:= Set( triple[3]{ ker } );
              supfact:= First( ComputedClassFusions( triple[2] ),
                            r -> ClassPositionsOfKernel( r.map ) = kerimg );
              if supfact <> fail then
                facttriple:= First( factauts,
                                 x -> Identifier( x[2] ) = supfact.name );
                if facttriple <> fail then
                  if ind <> facttriple[1] then
                    # The permutations do not fit together.
                    result:= false;
                    CTblLib.PrintTestLog( "E",
                        "CTblLib.Test.CompatibleFactorFusions",
                        Identifier( tbl ),
                        [ [ "autom. induced by ", Identifier( triple[2] ),
                            " incompatible with factor ", factfus.name ] ] );
                  fi;
                fi;
              fi;
            fi;
          fi;
        od;
      fi;
    od;

    return result;
    end;


#############################################################################
##
#V  CTblLib.HardFusions
##
##  `CTblLib.HardFusions' is a list of pairs `[ <subname>, <tblname> ]'
##  where <subname> and <tblname> are `Identifier' values of character
##  tables such that `CTblLib.Test.SubgroupFusion' shall omit the compatibility
##  check for the class fusion between these tables.
##
CTblLib.HardFusions:= [];

Add( CTblLib.HardFusions, [ "Co1N3", "Co1" ] );
Add( CTblLib.HardFusions, [ "Co1N2", "Co1" ] );
Add( CTblLib.HardFusions, [ "Co2N2", "Co2" ] );
Add( CTblLib.HardFusions, [ "Fi22N3", "Fi22" ] );
     # computed via factorization through 3^(1+6):2^(3+4):3^2:2
Add( CTblLib.HardFusions, [ "M24N2", "M24" ] );
     # computed from the groups, time 227180 msec, incl. tables comput.
     # (25-11-2002)
Add( CTblLib.HardFusions, [ "M24N2", "He" ] );
     # computed from the groups, time 12451360 msec, incl. tables comput.
     # (26-11-2002)
Add( CTblLib.HardFusions, [ "O8+(3)M14", "O8+(3)" ] );
     # 1 orbit, 648 sol., time 154539590 msec on regulus (22-11-2002)
Add( CTblLib.HardFusions, [ "L3(3)", "B" ] );
     # 1 orbit, 36 sol., harmless if one forbids decomposition
Add( CTblLib.HardFusions, [ "2^2xF4(2)", "2.2E6(2).2" ] );
Add( CTblLib.HardFusions, [ "(3^2:D8xU4(3).2^2).2", "B" ] );
Add( CTblLib.HardFusions, [ "[2^35].(S5xL3(2))", "B" ] );
     # unique, takes 34621084 msec (2009-04-20)
Add( CTblLib.HardFusions, [ "2^2x3xS3xU4(2)", "(2^2x3).U6(2)" ] );
     # takes a long time ... (February 2010)
Add( CTblLib.HardFusions, [ "2xM11", "2.B" ] );
     # takes a long time, needs a lot of space ... (February 2010)
Add( CTblLib.HardFusions, [ "(2^2x3).2E6(2)", "(2^2x3).2E6(2).2" ] );
     # not ready after 48 h ... (February 2010)

Add( CTblLib.HardFusions, [ "3.2E6(2)M8", "3.2E6(2)" ] );
Add( CTblLib.HardFusions, [ "3.2E6(2)M9", "3.2E6(2)" ] );
     # the test says ``text should not mention that fusion is relative''
     # in these two cases; but the fusions ARE relative,
     # just the reference table of 3.2E6(2).3 is missing
     # (so the pairs can be removed from `CTblLib.HardFusions' as soon as
     # this table will be available)


#############################################################################
##
#F  CTblLib.InitFusionsStatistics( <statfile> )
#F  CTblLib.AmendFusionsStatistics( <entry> )
#F  CTblLib.FinalizeFusionsStatistics()
##
##  Create a file with information about all subgroup fusions stored in the
##  GAP Character Table Library.
##  For the fusion from the table with identifier <subtbl> into that with
##  identifier <tbl>, a list entry of the following form is printed.
##
##  `[<subtbl>,<tbl>,<nrfus>,<nrorbs>,<nrcomp>,<nrcorbs>,<normtime>],'
##
##  Here <nrfus> is the number of fusions,
##  <nrorbs> is the number of orbits on the maps under table automorphisms,
##  <nrcomp> is the number of those fusions that are compatible with the
##  Brauer tables available for <subtbl> and <tbl>,
##  <nrcorbs> is the number of orbits on the compatible maps under table
##  automorphisms, and
##  <normtime> is the time needed to compute the fusions,
##  divided by ... (so this value is expected to be more or less independent
##  of the machine used).
##
##  Thus the fusion is unique if <nrfus> is $1$,
##  it is unique up to table automorphisms if <nrorbs> is $1$;
##  otherwise the fusion is ambiguous.
##  If <nrcomp> is smaller than <nrfus> then the Brauer tables impose
##  extra conditions on the fusions, and if <nrcorbs> is smaller than
##  <nrorbs> then the Brauer tables reduce the ambiguity.
##
CTblLib.InitFusionsStatistics:= function( statfile )
    local time, l, i, j;

    # Measure the time for some typical computations.
    time:= Runtime();
    l:= [];
    for i in [ 1 .. 1000 ] do
      for j in [ 1 .. 1000 ] do
        l[j]:= j;
      od;
    od;
    time:= ( Runtime() - time );

    # Create the file.
    PrintTo( statfile, "[\n" );

    LIBTABLE.FusionsStatistics:= rec( statfile:= statfile, time:= time );
    end;

CTblLib.AmendFusionsStatistics:= function( entry )
    if IsBound( LIBTABLE.FusionsStatistics ) then
      AppendTo( LIBTABLE.FusionsStatistics.statfile, Concatenation( "[\"",
        Identifier( entry[1] ),
        "\",\"",
        Identifier( entry[2] ),
        "\",",
        String( Length( entry[3] ) ),
        ",",
        String( Length( entry[4] ) ),
        ",",
        String( Length( entry[5] ) ),
        ",",
        String( Length( entry[6] ) ),
        ",",
        String( Int( entry[7] / LIBTABLE.FusionsStatistics.time ) ),
        "],\n" ) );
    fi;
    end;

CTblLib.FinalizeFusionsStatistics:= function()
    AppendTo( LIBTABLE.FusionsStatistics.statfile, "\n];\n" );
    end;


#############################################################################
##
#V  CTblLib.ExcludedFromFusionCompatibility
##
##  a list of those quadruples [ <sub>, <tbl>, <subfact>, <tblfact> ]
##  or [ <sub>, <tbl>, <subext>, <tblext> ]
##  for which no commutative diagram of stored fusions is guaranteed
##
CTblLib.ExcludedFromFusionCompatibility:= [
  # quadruples involving two subgroup fusions and two factor fusions
  [ "2.O7(3)M5", "2.O7(3)", "G2(3)", "O7(3)" ],
  [ "3.O7(3)M8", "3.O7(3)", "S6(2)", "O7(3)" ],
  [ "3.O7(3)M11", "3.O7(3)", "A9.2", "O7(3)" ],
  [ "2.S6(2)", "2.O8+(2)", "S6(2)", "O8+(2)" ],
  [ "2^(1+6)_+.A8", "2.O8+(2)", "2^6:A8", "O8+(2)" ],
  [ "2.A9", "2.O8+(2)", "A9", "O8+(2)" ],

  [ "2.U4(3).2_2", "2.U6(2)", "U4(3).2_2", "U6(2)" ],
    # since 2.U4(3).2_2 = 2.U6(2)M5, U4(3).2_2 = U6(2)M4

  [ "6_1.U4(3).2_2", "6.U6(2)", "U4(3).2_2", "U6(2)" ],
    # since 6_1.U4(3).2_2 = 6.U6(2)M5, U4(3).2_2 = U6(2)M4

  [ "6_1.U4(3).2_2", "6.U6(2)", "3_1.U4(3).2_2", "3.U6(2)" ],
    # since 6_1.U4(3).2_2 = 6.U6(2)M5, 3_1.U4(3).2_2 = U6(2)M4

  [ "2.M22", "2.U6(2)", "M22", "U6(2)" ],
    # since 2.M22 = 2.U6(2)M12, M22 = U6(2)M11

  [ "6.M22", "6.U6(2)", "M22", "U6(2)" ],
    # since 6.M22 = 6.U6(2)M12, M22 = U6(2)M11

  [ "6.M22", "6.U6(2)", "3.M22", "3.U6(2)" ],
    # since 6.M22 = 6.U6(2)M12, 3.M22 = 3.U6(2)M11

  [ "2.Fi22", "2.2E6(2)", "Fi22", "2E6(2)" ],
    # since 2.Fi22 = 2.2E6(2)M8, Fi22 = 2E6(2)M7

  [ "6.Fi22", "6.2E6(2)", "Fi22", "2E6(2)" ],
    # since 6.Fi22 = 6.2E6(2)M8, Fi22 = 2E6(2)M7

  [ "6.Fi22", "6.2E6(2)", "3.Fi22", "3.2E6(2)" ],
    # since 6.Fi22 = 6.2E6(2)M8, 3.Fi22 = 3.2E6(2)M7

  [ "2.F4(2)", "2.2E6(2)", "F4(2)", "2E6(2)" ],
    # since 2.F4(2) = 2.2E6(2)M4, "F4(2) = 2E6(2)M3

  [ "6.M22", "6.U6(2)", "2.M22", "2.U6(2)" ],
# why?

  [ "2xM22", "2.U6(2)", "M22", "U6(2)" ],
#T why?

# [ "2^2.U6(2)M12","2^2.U6(2)", "2.M22", "2.U6(2)" ],
#T no! excluding 6.M22 -> 3.M22 and 2.M22 -> M22 should suffice!

  # quadruples involving four subgroup fusions
  [ "L2(11)", "M12", "L2(11).2", "M12.2" ],
    # since L2(11).2 occurs as both the novelty M12.2M2 (cont. 2B elements)
    # and as the extension M12.2M3 (cont. 2A elements) in M12.2;
    # in AtlasRep and MFER, the novelty occurs first
  ];


#############################################################################
##
#F  CTblLib.AddIncompatibleFusionsOfFactors( <sub>, <tbl>, <fus>, <incompat> )
##
CTblLib.AddIncompatibleFusionsOfFactors:= function( sub, tbl, fus, incompat )
    local tblfactfus, record, ker, kersize, pair, subfact, tblfact,
          storedfus, ffus;

    # Compute a list of pairs [ <kernelsize>, <factfusrec> ] for `tbl'.
    tblfactfus:= Filtered( List( ComputedClassFusions( tbl ),
          r -> [ Sum( SizesConjugacyClasses( tbl ){ ClassPositionsOfKernel(
                                                      r.map ) } ), r ] ),
        pair -> pair[1] <> 1 );

    # Collect commutative diagrams of factor fusions and subgroup fusions.
    # We consider only those diagrams where a subgroup fusion between the
    # factor tables is already stored.
    for record in ComputedClassFusions( sub ) do
      ker:= ClassPositionsOfKernel( record.map );
      if ker <> [ 1 ] then
        kersize:= Sum( SizesConjugacyClasses( sub ){ ker } );
        for pair in Filtered( tblfactfus, x -> x[1] = kersize ) do
          subfact:= CharacterTable( record.name );
          tblfact:= CharacterTable( pair[2].name );
          if subfact <> fail and tblfact <> fail then
            if List( [ sub, tbl, subfact, tblfact ], Identifier )
                 in CTblLib.ExcludedFromFusionCompatibility then
              incompat.someexcluded:= true;
            else
              storedfus:= GetFusionMap( subfact, tblfact );
              if storedfus <> fail and
                 Set( fus{ ker } ) = ClassPositionsOfKernel( pair[2].map ) then
                # Compute the induced fusion between the factors and compare.
                ffus:= CompositionMaps( pair[2].map,
                         CompositionMaps( fus, InverseMap( record.map ) ) );
                if ffus <> storedfus then
                  Add( incompat.badfusions, [ sub, tbl, subfact, tblfact ] );
                fi;
                CTblLib.AddIncompatibleFusionsOfFactors( subfact, tblfact,
                    storedfus, incompat );
              fi;
            fi;
          fi;
        od;
      fi;
    od;
    end;


#############################################################################
##
#F  CTblLib.Test.SubgroupFusionOfMaximalSubgroup( <sub>, <tbl> )
##
##  returns
##  `false' if was not applicable,
##  `true' if no further treatment of the fusion is needed,
##  because it is interpreted relative to another fusion
##  (also if inconsistent!).
##
CTblLib.MaxesNames:= function( tbl )
    local result, tblname, pos, name, index;

    if HasMaxes( tbl ) then
      return Maxes( tbl );
    fi;

    result:= [];
    tblname:= Concatenation( LowercaseString( Identifier( tbl ) ), "m" );
    pos:= PositionSorted( LIBLIST.allnames, tblname );
    while pos <= Length( LIBLIST.allnames ) do
      name:= LIBLIST.allnames[ pos ];
      if Length( name ) <= Length( tblname ) then
        break;
      fi;
      index:= name{ [ Length( tblname ) + 1 .. Length( name ) ] };
      if ForAll( index, IsDigitChar ) then
        Add( result,
             [ Int( index ), LibInfoCharacterTable( name ).firstName ] );
      fi;
      pos:= pos + 1;
    od;
    Sort( result );
    return List( result, x -> x[2] );
end;


#T this function strikes for example for 2^2.L3(4).2_1 -> 2^2.L3(4).2^2
#T (w.r.t. Brauer tables for p = 5 or 7)
#T but why??
CTblLib.PermutationsInducedByOuterAutomorphisms:= function( tbl )
    local result, r, suptbl, fus, order, img, inv, lists, stab, cand, p,
          modtbl, modfus, range;

    result:= [];
    for r in ComputedClassFusions( tbl ) do
      suptbl:= CharacterTable( r.name );
      if suptbl <> fail then
        fus:= r.map;
        order:= Size( suptbl ) / Size( tbl );
        img:= Set( fus );
        if img in ClassPositionsOfNormalSubgroups( suptbl ) and
           Sum( SizesConjugacyClasses( suptbl ){ img } ) = Size( tbl ) and
           IsCyclic( suptbl / img ) then
          # `tbl' is a normal subgroup of index `order' in `suptbl'.
          inv:= InverseMap( fus );
          lists:= Filtered( inv, IsList );
          if not IsEmpty( lists ) then
            stab:= Stabilizer( AutomorphismsOfTable( tbl ),
                               Filtered( inv, IsInt ), OnTuples );
            stab:= Stabilizer( stab, lists, OnTuplesSets );
            cand:= Filtered( stab,
                       x -> Order( x ) = order and
                            ForAll( lists, l -> l <> OnTuples( l, x ) ) );
            cand:= Set( List( cand, SmallestGeneratorPerm ) );

            # Check whether the restriction to p-regular classes defines
            # a table automorphism.
            for p in Set( Factors( Size( tbl ) ) ) do
              modtbl:= tbl mod p;
              if modtbl <> fail then
                modfus:= GetFusionMap( modtbl, tbl );
                range:= [ 1 .. NrConjugacyClasses( tbl ) ];
                cand:= Filtered( cand, pi -> PermList( CompositionMaps(
                                               InverseMap( modfus ),
                   CompositionMaps( OnTuples( range, pi ), modfus ) ) ) in
                       AutomorphismsOfTable( modtbl ) );
              fi;
            od;

            if Length( cand ) = 0 then
              CTblLib.PrintTestLog( "E",
                  "CTblLib.PermutationsInducedByOuterAutomorphisms",
                  Identifier( tbl ),
                  [ [ "no table autom. induced by fusion to ",
                      Identifier( suptbl ), "?" ] ] );
            elif Length( cand ) = 1 then
              Add( result, [ cand[1], suptbl, fus ] );
            elif Length( cand ) = 2 and Identifier( tbl ) = "U3(8)"
                 and Identifier( suptbl ) = "U3(8).3_3" then
              # There are two groups U3(8).3_3 and U3(8).3_3',
              # to which the two candidates belong.
              # Note that the automorphisms 3_3 and 3_3' arise as 3_1 * 3_2
              # and 3_1 / 3_2, respectively; we choose the smaller of the two
              # possibilities as 3_3.
              Add( result, [ (6,7,8)(11,12,13)(14,15,16)(17,19,21)(18,20,22)*
                             (23,25,27)(24,26,28), suptbl, fus ] );
            else
              CTblLib.PrintTestLog( "I",
                  "CTblLib.PermutationsInducedByOuterAutomorphisms",
                  Identifier( tbl ),
                  [ [ "cannot identify table autom. induced by action of ",
                      Identifier( suptbl ) ] ] );
#T maybe we need just the orbits not the action itself
#T (if the classes in question are not hit, for example ...)
            fi;
          fi;
        fi;
      fi;
    od;

    return result;
    end;

CTblLib.Test.SubgroupFusionOfMaximalSubgroup:= function( sub, tbl )
    local maxesnames, pos, fusid, mx, tr, choice, fusions, auts, triple,
          cand, suptbl,
          fus, invariant, extcand, extname, ext, extfus, orb, orbreps,
          i, map, pos2, done, rep, fusrec, relative, source, text, incompat,
          incompatnames;

    maxesnames:= CTblLib.MaxesNames( tbl );
    pos:= PositionsProperty( maxesnames, x -> Identifier( sub ) = x );
    if IsEmpty( pos ) then
      # The subgroup is not known to be maximal,
      # so this function is not useful for this fusion.
      return false;
    fi;
    fusid:= Concatenation( Identifier( sub ), " -> ", Identifier( tbl ) );

    # Collect maxes with tables equivalent to that of `sub'.
    mx:= List( maxesnames, CharacterTable );
    tr:= List( [ 1 .. Length( mx ) ],
           i -> TransformingPermutationsCharacterTables( sub, mx[i] ) );
    choice:= PositionsProperty( tr, x -> x <> fail );
    fusions:= List( choice, i -> GetFusionMap( mx[i], tbl ) );
    tr:= tr{ choice };
    if fail in fusions then
      CTblLib.PrintTestLog( "E", "CTblLib.Test.SubgroupFusionOfMaximalSubgroup",
          fusid,
          [ [ "missing fusion from some maxes of ", Identifier( tbl ) ] ] );
      return false;
    fi;

    # Compute the action of outer automorphisms of `tbl'.
    auts:= [];
    for triple in CTblLib.PermutationsInducedByOuterAutomorphisms( tbl ) do
      cand:= triple[1];
      suptbl:= triple[2];
fus:= GetFusionMap( sub, tbl );
      Add( auts, cand );
      invariant:= RepresentativeAction( AutomorphismsOfTable( sub ),
                      fus, OnTuples( fus, cand ), Permuted ) <> fail;
      extcand:= Intersection( CTblLib.MaxesNames( suptbl ),
                    List( ComputedClassFusions( sub ), x -> x.name ) );
      RemoveSet( extcand, Identifier( tbl ) );
      for extname in extcand do
        ext:= CharacterTable( extname );
        if ext <> fail and
           Size( ext ) / Size( sub ) = Size( suptbl ) / Size( tbl ) then
          extfus:= GetFusionMap( ext, suptbl );
          if extfus <> fail then
            if CompositionMaps( extfus, GetFusionMap( sub, ext ) ) =
               CompositionMaps( triple[3], fus ) then
              if not invariant then
                # The subgroup behaves as if it would extend to the
                # autom. extension but it cannot extend.
                CTblLib.PrintTestLog( "E",
                    "CTblLib.Test.SubgroupFusionOfMaximalSubgroup", fusid,
                    "strange/invalid commutative diagram",
                  [ Identifier( sub ), " -> ", Identifier( suptbl ) ],
                  [ "via ", Identifier( ext ), " and ", Identifier( tbl ) ] );
              fi;
            elif invariant
                 and not List( [ sub, tbl, ext, suptbl ], Identifier )
                         in CTblLib.ExcludedFromFusionCompatibility then
              # The diagram shold commute.
              CTblLib.PrintTestLog( "E",
                  "CTblLib.Test.SubgroupFusionOfMaximalSubgroup", fusid,
                  "diagram should commute:",
                  [ Identifier( sub ), " -> ", Identifier( suptbl ) ],
                  [ "via ", Identifier( ext ), " and ", Identifier( tbl ) ] );
            fi;
          fi;
        fi;
      od;
    od;

    if IsEmpty( auts ) then
      # We cannot derive conditions from outer automorphisms.
      # so this function is not useful for this fusion.
      return false;
    fi;

    # Compute the orbit of the given fusion under `auts',
    # and representatives under table automorphisms of `sub'.
    fusions:= List( [ 1 .. Length( tr ) ],
                    i -> Permuted( fusions[i], tr[i].columns ) );
    fus:= fusions[ Position( choice, pos[1] ) ];
    orb:= Orbit( Group( auts ), fus, OnTuples );
    orbreps:= [ fus ];
    for i in [ 2 .. Length( orb ) ] do
      map:= orb[i];
      pos2:= PositionProperty( orbreps, rep -> RepresentativeAction(
               AutomorphismsOfTable( sub ), map, rep, Permuted ) <> fail );
      if pos2 = fail then
        Add( orbreps, map );
      fi;
    od;

    # Each of the essentially different fusions must occur
    # among the maxes fusions (with the same multiplicity).
    done:= [];
    for rep in orbreps do
      pos2:= PositionsProperty( fusions,
                 map -> RepresentativeAction( AutomorphismsOfTable( sub ),
                          map, rep, Permuted ) <> fail );
      UniteSet( done, choice{ pos2 } );
      if Length( pos2 ) = 0 then
#T better check that always the same nonzero length ...
        CTblLib.PrintTestLog( "E",
            "CTblLib.Test.SubgroupFusionOfMaximalSubgroup", fusid,
            "multiplicity of same fusion among maxes does not fit" );
      fi;
    od;

    # The fusion of `sub' can be interpreted relative to another fusion.
    fusrec:= First( ComputedClassFusions( sub ),
                    r -> r.name = Identifier( tbl ) );
    relative:= false;
    if IsBound( fusrec.text ) then
      source:= fail;
      text:= ReplacedString( fusrec.text, "\n", " " );
      pos2:= PositionSublist( text, ", mapped under" );
      if pos2 <> fail then
        relative:= true;
        text:= text{ [ 1 .. pos2 - 1 ] };
        pos2:= PositionSublist( text, " from " );
        if pos2 <> fail then
          source:= CharacterTable( text{ [ pos2 + 6 .. Length( text ) ] } );
        fi;
      fi;
      if source <> fail then
        if Identifier( source ) <> maxesnames[ Minimum( done ) ] and
           not ( relative and pos[1] = Minimum( done ) ) then
          CTblLib.PrintTestLog( "E",
            "CTblLib.Test.SubgroupFusionOfMaximalSubgroup", fusid,
            [ [ "text should mention that fusion is relative to ",
                Concatenation( maxesnames[ Minimum( done ) ],
                  " not ", Identifier( source ) ) ] ] );
        fi;

        # Check that the fusions lie in the same orbit.
        if TransformingPermutationsCharacterTables( source, sub ) = fail then
          CTblLib.PrintTestLog( "E",
            "CTblLib.Test.SubgroupFusionOfMaximalSubgroup", fusid,
            "wrong source stored for relative fusion" );
        fi;
      elif relative then
        CTblLib.PrintTestLog( "E",
          "CTblLib.Test.SubgroupFusionOfMaximalSubgroup", fusid,
          "missing source information in relative fusion" );
      fi;
    fi;

    if pos[1] = Minimum( done ) then
      # `sub' is the first table among the maxes in its orbit,
      # it should not be a relative fusion.
      if relative then
        CTblLib.PrintTestLog( "E",
            "CTblLib.Test.SubgroupFusionOfMaximalSubgroup", fusid,
            "text should not mention that fusion is relative" );
      fi;

      # Return `false' in order to check the fusion.
      return false;
    fi;

    # `sub' is not the first table among the maxes in its orbit,
    # so the fusion should be a relative fusion.
    if not relative then
      CTblLib.PrintTestLog( "E",
          "CTblLib.Test.SubgroupFusionOfMaximalSubgroup", fusid,
          [ [ "text should mention that fusion is relative to ",
              maxesnames[ Minimum( done ) ] ] ] );
    fi;

    # Check that the stored fusion is compatible with factors.
    incompat:= rec( badfusions:= [], someexcluded:= false );
    CTblLib.AddIncompatibleFusionsOfFactors( sub, tbl, fus, incompat );
    if not IsEmpty( incompat.badfusions ) then
      incompatnames:= List( incompat.badfusions,
          entry -> Concatenation( [ "  ", Identifier( entry[3] ),
                                    " -> ", Identifier( entry[4] ),
                                    " (w.r.t. ", Identifier( entry[1] ),
                                    " -> ", Identifier( entry[2] ), ")" ] ) );
      CTblLib.PrintTestLog( "E",
          "CTblLib.Test.SubgroupFusionOfMaximalSubgroup", fusid,
          Concatenation(
            [ "no fusion (compatible with Brauer tables if applicable and)",
              " consistent with" ], incompatnames ) );
    fi;

    return true;
end;


#############################################################################
##
#F  CTblLib.Test.SubgroupFusion( <sub>, <tbl> )
##
##  If no class fusion from <sub> to <tbl> is possible or if the possible
##  class fusions contradict the stored fusion then `false' is returned.
##  If a fusion is stored and is compatible with the possible fusions,
##  and the fusion is not unique up to table automorphisms and if the stored
##  fusion has no `text' component then `fail' is returned.
##  Otherwise the fusion record is returned.
##
##  If the pair of identifiers of <sub> and <tbl> occurs in the global list
##  `CTblLib.HardFusions' amd if a fusion is stored then the fusion record is
##  returned without tests, and a message is printed.
##
CTblLib.Test.SubgroupFusion:= function( sub, tbl )
    local fusrec, fusid, spec, tom, pos, perms, pi, storedfus, time, fus,
          filt, fusreps, filtreps, fus_c, reducedby, someexcluded, map,
          incompat, entry, pair, pairstring, fusreps_c, filt_c, filtreps_c,
          comp, libinfo, changedtext, reducedbyBrauer, reducedbyfactors,
          result;
Print( "#I test subgroup fusion ", Identifier( sub ), " -> ", Identifier( tbl ), "\n" );

    fusrec:= First( ComputedClassFusions( sub ),
                    r -> r.name = Identifier( tbl ) );
    fusid:= Concatenation( Identifier( sub ), " -> ", Identifier( tbl ) );

    # Verify a specification of the kind 'tom:<n>'.
    if fusrec <> fail and IsBound( fusrec.specification ) then
      spec:= fusrec.specification;
      if IsString( spec ) and 4 < Length( spec )
                          and spec{ [ 1 .. 4 ] } = "tom:" then
        tom:= TableOfMarks( tbl );
        pos:= Int( spec{ [ 5 .. Length( spec ) ] } );
        if tom = fail then
          CTblLib.PrintTestLog( "E", "CTblLib.Test.SubgroupFusion", fusid,
              [ [ "specification ", spec, " but no table of marks?" ] ] );
        elif not IsInt( pos ) then
          CTblLib.PrintTestLog( "E", "CTblLib.Test.SubgroupFusion", fusid,
              [ [ "strange specification ", spec ] ] );
        elif not HasFusionToTom( tbl ) then
          CTblLib.PrintTestLog( "E", "CTblLib.Test.SubgroupFusion", fusid,
              "no fusion to tom" );
        else
          perms:= PermCharsTom( tbl, tom );
          if Length( perms ) < pos then
            CTblLib.PrintTestLog( "E", "CTblLib.Test.SubgroupFusion", fusid,
                [ [ "specification ", spec, ": too few trans. perm. char." ] ] );
          else
            pi:= InducedClassFunctionsByFusionMap( sub, tbl,
                     [ TrivialCharacter( sub ) ], fusrec.map )[1];
            if not pi in perms then
              CTblLib.PrintTestLog( "E", "CTblLib.Test.SubgroupFusion", fusid,
                  "stored fusion does not fit to any trans. perm. char." );
            elif pi <> perms[ pos ] then
              CTblLib.PrintTestLog( "E", "CTblLib.Test.SubgroupFusion", fusid,
                [ [ "specification ", spec, " is wrong, store `tom:",
                    Position( perms, pi ), "' instead" ] ] );
            fi;
          fi;
        fi;
      fi;
    fi;

    # Shall the test be omitted?
    if [ Identifier( sub ), Identifier( tbl ) ] in CTblLib.HardFusions then
      if fusrec = fail then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.SubgroupFusion", fusid,
            "omitting fusion check (no map stored)" );
      else
        # At least test the existing map for consistency.
        fus:= PossibleClassFusions( sub, tbl,
                  rec( fusionmap:= fusrec.map ) );
        if IsEmpty( fus ) then
          CTblLib.PrintTestLog( "E", "CTblLib.Test.SubgroupFusion", fusid,
              "stored fusion is wrong" );
        else
          CTblLib.PrintTestLog( "E", "CTblLib.Test.SubgroupFusion", fusid,
              "omitting fusion check" );
        fi;
      fi;
      return fusrec;
    fi;

    # If the fusion must be interpreted relative to another one
    # then do not test anything else.
    if CTblLib.Test.SubgroupFusionOfMaximalSubgroup( sub, tbl ) then
      return fusrec;
    fi;

    if fusrec = fail then
      fusrec:= rec();
      storedfus:= fail;
    else
      storedfus:= fusrec.map;
    fi;

    # Recompute the possible class fusions.
    time:= Runtime();
    fus:= PossibleClassFusions( sub, tbl );
    time:= Runtime() - time;
    fusreps:= RepresentativesFusions( sub, fus, tbl );
    filt:= CTblLib.Test.Decompositions( sub, fus, tbl );
    filtreps:= RepresentativesFusions( sub, filt, tbl );

    # Amend the statistics if wanted.
    CTblLib.AmendFusionsStatistics(
        [ sub, tbl, fus, fusreps, filt, filtreps, time ] );

    # We may have no fusion at all.
    if   IsEmpty( fus ) then
      CTblLib.PrintTestLog( "E", "CTblLib.Test.SubgroupFusion", fusid,
          "no fusion possible" );
      return false;
    elif IsEmpty( filt ) then
      CTblLib.PrintTestLog( "E", "CTblLib.Test.SubgroupFusion", fusid,
          "no fusion compatible with Brauer tables" );
      return false;
    fi;

    # Consider factor fusions.
    # We use the information about factors for preferably choosing a map
    # from the set of compatible fusions,
    # and for printing warnings in case of inconsistencies,
    # but stored incompatible fusions are not automatically replaced.
    fus_c:= [];
    reducedby:= [ [], [] ];
    someexcluded:= false;
    for map in fus do
      incompat:= rec( badfusions:= [], someexcluded:= false );
      CTblLib.AddIncompatibleFusionsOfFactors( sub, tbl, map, incompat );
      someexcluded:= someexcluded or incompat.someexcluded;
      if IsEmpty( incompat.badfusions ) then
        Add( fus_c, map );
      else
        for entry in incompat.badfusions do
          pairstring:= Concatenation( [ "  ", Identifier( entry[3] ),
                                      " -> ", Identifier( entry[4] ),
                                      " (w.r.t. ", Identifier( entry[1] ),
                                      " -> ", Identifier( entry[2] ), ")" ] );
          if not pairstring in reducedby[1] then
            Add( reducedby[1], pairstring );
            Add( reducedby[2], entry{ [ 3, 4 ] } );
          fi;
        od;
        SortParallel( reducedby[1], reducedby[2] );
      fi;
    od;
    fusreps_c:= RepresentativesFusions( sub, fus_c, tbl );
    filt_c:= Filtered( fus_c, x -> x in filt );
    filtreps_c:= RepresentativesFusions( sub, filt_c, tbl );

    # We may have no consistent fusion.
    if IsEmpty( fus_c ) then
      CTblLib.PrintTestLog( "E", "CTblLib.Test.SubgroupFusion", fusid,
          Concatenation( [ "no fusion consistent with" ], reducedby[1] ) );
      # Propose changing the fusion between factors.
      for pair in reducedby[2] do
        if GetFusionMap( sub, pair[1] ) <> fail and
           GetFusionMap( tbl, pair[2] ) <> fail then
          comp:= Set( List( filt, map -> CompositionMaps(
                               GetFusionMap( tbl, pair[2] ),
                               CompositionMaps( map, InverseMap( GetFusionMap(
                                   sub, pair[1] ) ) ) ) ) );
          # Consider only those fusions that map the kernel compatibly.
          comp:= Filtered( comp, x -> ForAll( x, IsInt ) );
          libinfo:= LibInfoCharacterTable( pair[1] );
          if libinfo = fail then
            libinfo:= "no library file";
          else
            libinfo:= libinfo.fileName;
          fi;
          if Length( comp ) = 1 then
            CTblLib.PrintTestLog( "I", "CTblLib.Test.SubgroupFusion", fusid,
              "replace fusion of factors by the following unique fusion",
              Concatenation( "(in ", libinfo, ")" ) );
            Print( LibraryFusion( pair[1], rec( name:= pair[2], map:= comp[1],
                     text:= Concatenation(
                       "unique map that is compatible with ",
                       Identifier( sub ), " -> ", Identifier( tbl ) ) ) ) );
          elif Length( RepresentativesFusions( pair[1], comp, pair[2] ) )
               = 1 then
            CTblLib.PrintTestLog( "I", "CTblLib.Test.SubgroupFusion", fusid,
              "perhaps replace fusion of factors by the following (u.t.a.)",
              Concatenation( "(in ", libinfo, ")" ) );
            Print( LibraryFusion( pair[1], rec( name:= pair[2], map:= comp[1],
                     text:= Concatenation(
                       "compatible with ",
                       Identifier( sub ), " -> ", Identifier( tbl ) ) ) ) );
          else
            CTblLib.PrintTestLog( "I", "CTblLib.Test.SubgroupFusion", fusid,
              "perhaps replace fusion of factors by the following (ambig.)",
              Concatenation( "(in ", libinfo, ")" ) );
            Print( LibraryFusion( pair[1], rec( name:= pair[2], map:= comp[1]
                       ) ) );
          fi;
        fi;
      od;
      return false;
    elif IsEmpty( filt_c ) then
      CTblLib.PrintTestLog( "E", "CTblLib.Test.SubgroupFusion", fusid,
          Concatenation( [ "no fusion compatible with Brauer tables ",
                           "and consistent with" ], reducedby[1] ) );
      return false;
    fi;

    # Now we have consistent candidates.
    # Check whether the stored text mentions (only) the reductions used.
    # (The words ``factorization'' and ``factors through'' are allowed.)
    changedtext:= false;
    reducedbyBrauer:= IsBound( fusrec.text ) and
        PositionSublist( fusrec.text, "Brauer" ) <> fail;
    reducedbyfactors:= IsBound( fusrec.text ) and
        PositionSublist( ReplacedString( ReplacedString( fusrec.text,
            "factori", "" ), "factors through", "" ), "factor" ) <> fail;

    if Length( filt ) < Length( fus ) then
      # We have to choose a fusion that is compatible with Brauer tables,
      # perhaps the Brauer tables resolve ambiguities.
      if not reducedbyBrauer then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.SubgroupFusion", fusid,
            "text should mention reduction by Brauer tables" );
        changedtext:= true;
      fi;
    elif reducedbyBrauer then
      CTblLib.PrintTestLog( "E", "CTblLib.Test.SubgroupFusion", fusid,
          "text needs not mention reduction by Brauer tables" );
      changedtext:= true;
    fi;
    if Length( filt_c ) < Length( filt ) then
      # In addition to the compatibility with Brauer tables,
      # we have to choose a fusion that is compatible with factor tables,
      # perhaps the factor tables resolve ambiguities.
      if not reducedbyfactors then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.SubgroupFusion", fusid,
            "text should mention reduction by fusions of factors" );
        changedtext:= true;
      fi;
    elif reducedbyfactors then
      CTblLib.PrintTestLog( "E", "CTblLib.Test.SubgroupFusion", fusid,
          "text needs not mention reduction by fusions of factors" );
      changedtext:= true;
    fi;

    # Check whether the stored fusion is one of the candidates.
    if storedfus <> fail then
      if not storedfus in filt then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.SubgroupFusion", fusid,
            "stored fusion is wrong" );
      elif not storedfus in filt_c then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.SubgroupFusion", fusid,
            Concatenation( [
                "stored fusion not compatible with factor embeddings" ],
                reducedby[1] ) );
      fi;
    fi;

    # Check the uniqueness status, which should be mentioned in the text.
    if Length( fus ) = 1 then
      # The fusion is unique.
      if IsBound( fusrec.text )
         and fusrec.text <> "fusion map is unique"
         and ( Length( fusrec.text ) < 21 or
               fusrec.text{ [ 1 .. 21 ] } <> "fusion map is unique," )
         and ( Length( fusrec.text ) < 22 or
               fusrec.text{ [ 1 .. 22 ] } <> "fusion map is unique (" ) then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.SubgroupFusion", fusid,
            "text for stored fusion is wrong (map is unique!)" );
        changedtext:= true;
      fi;
      result:= rec( name := Identifier( tbl ),
                    map  := fus[1],
                    text := "fusion map is unique" );
    elif 1 < Length( filtreps_c ) and 1 < Length( fusreps ) then
      # The fusion is ambiguous.
      if storedfus = fail then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.SubgroupFusion", fusid,
            "ambiguous fusion, no map stored" );
        result:= fail;
      elif not IsBound( fusrec.text ) then
        # The ambiguity of the fusion is not mentioned in the stored fusion.
        CTblLib.PrintTestLog( "E", "CTblLib.Test.SubgroupFusion", fusid,
            "ambiguous fusion, no text stored" );
        result:= fail;
      elif     PositionSublist( fusrec.text, "together" ) = fail
           and PositionSublist( fusrec.text, "determined" ) = fail then
        # The ambiguity of the fusion is not mentioned in the stored fusion.
        CTblLib.PrintTestLog( "E", "CTblLib.Test.SubgroupFusion", fusid,
            "ambiguous fusion, no \"together\" or \"determined\" in text" );
        result:= fail;
      else
        # Keep the map; the text explains why it was chosen.
        result:= fusrec;
      fi;
###########################
      if result = fail then
        # Print the information we have about the ambiguous fusion.
        CTblLib.PrintTestLog( "E", "CTblLib.Test.SubgroupFusion", fusid,
            "data for the ambiguous fusion (fus, filt, filt_c, ...):",
            JoinStringsWithSeparator(
                List( [ fus, filt, filt_c, fusreps, filtreps, filtreps_c ],
                      x -> String( Length( x ) ) ), "/" ) );
        Print( filtreps_c, "\n" );
      fi;
###########################
    elif 1 < Length( filtreps ) then
      # The compatibility conditions determine the fusion up to table autom..
      # Keep the stored fusion if it exists and is admissible.
      result:= rec( name := Identifier( tbl ) );
      if Length( filt_c ) < Length( filt ) then
        result.text:= Concatenation(
            "fusion map determined up to table aut. by compatibility\n",
            "with factors" );
        if Length( filt ) < Length( fus ) then
          Append( result.text, " and Brauer tables" );
        fi;
      elif Length( filt ) < Length( fus ) then
        result.text:= Concatenation(
            "fusion map determined up to table aut. by compatibility\n",
            "with Brauer tables" );
      else
        result.text:= "fusion map is unique up to table autom.";
      fi;

      if storedfus in filt_c then
        result.map:= storedfus;
      else
        result.map:= filt_c[1];
      fi;
      if someexcluded then
        result.text:= ReplacedString( result.text, "factors",
                                      "relevant factors" );
      fi;
    elif Length( filt ) = Length( fus ) then
      # The fusion is unique up to table automorphisms,
      # and no Brauer table imposes a condition.
      if IsBound( fusrec.text ) and
         PositionSublist( fusrec.text, "unique up to table " ) = fail then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.SubgroupFusion", fusid,
            [ [ "text for stored fusion is wrong ",
                "(map is unique up to table automorphisms!)" ] ] );
      fi;
      result:= rec( name := Identifier( tbl ) );
      if changedtext or not IsBound( fusrec.text ) then
        result.text:= "fusion map is unique up to table autom.";
      else
        result.text:= fusrec.text;
      fi;

      # Keep the stored fusion if it exists and is admissible.
      if storedfus in filt_c then
        result.map:= storedfus;
      else
        result.map:= filt_c[1];
      fi;
      if Length( filt_c ) < Length( filt ) then
        # Mention compatibility with fusions between factors.
        Append( result.text, ",\nrepresentative compatible with factors" );
        if someexcluded then
          result.text:= ReplacedString( result.text, "factors",
                                        "relevant factors" );
        fi;
      fi;

    else
      # We have 1 < Length( fus ), Length( filtreps ) = 1,
      # Length( filtreps_c ) = 1, Length( filt ) < Length( fus ).
      # So the Brauer tables impose additional conditions;
      # together with this and perhaps with factor consistencies,
      # the fusion is unique at least up to table automorphisms.
      # Keep the stored fusion if it exists and is admissible.
      result:= rec( name := Identifier( tbl ),
                    map  := fus );
      if storedfus in filt_c then
        result.map:= storedfus;
      else
        result.map:= filt_c[1];
      fi;
      if Length( fusreps ) = 1 then
        if Length( filt ) = 1 then
          # The fusion is unique.
          result.text:= Concatenation(
                    "fusion map is unique up to table autom.,\n",
                    "unique map that is compatible with Brauer tables" );
        elif Length( filt_c ) < Length( filt ) then
          # The fusion is unique up to table automorphisms
          # and compatible with factors.
          result.text:= Concatenation(
                    "fusion map is unique up to table autom.,\n",
                    "compatible with Brauer tables and factors" );
          if someexcluded then
            result.text:= ReplacedString( result.text, "factors",
                                          "relevant factors" );
          fi;
        else
          # The fusion is unique up to table automorphisms.
          result.text:= Concatenation(
                    "fusion map is unique up to table autom.,\n",
                    "compatible with Brauer tables" );
        fi;
      elif Length( filt ) = 1 then
        result.text:= "fusion map uniquely determined by Brauer tables";
      elif Length( filt_c ) < Length( filt ) then
        # The fusion is unique up to table automorphisms
        # and compatible with factors.
        result.text:= Concatenation(
                  "fusion map determined up to table autom.\n",
                  "by Brauer tables and factors" );
        if someexcluded then
          result.text:= ReplacedString( result.text, "factors",
                                        "relevant factors" );
        fi;
      else
        result.text:=
            "fusion map determined up to table autom. by Brauer tables";
      fi;
    fi;

    if changedtext and IsRecord( result ) then
      result.replace:= true;
    fi;
    if IsBound( fusrec.specification ) then
      result.specification:= fusrec.specification;
    fi;

    # Return the result.
    return result;
    end;


#############################################################################
##
#F  CTblLib.Test.FactorFusion( <tbl>, <fact> )
##
#T changed function!!
##  If no class fusion from <tbl> onto <fact> is possible or if the possible
##  factor fusions contradict the stored fusion then `false' is returned.
##  If a fusion is stored and is compatible with the possible fusions,
##  and the fusion is not unique up to table automorphisms and if the stored
##  fusion has no `text' component then `fail' is returned.
##  Otherwise the fusion record is returned.
##
CTblLib.Test.FactorFusion:= function( tbl, fact )
    local result, storedfus, fusid, ker, f, tr, map1, map2, quot,
          classes, kernels, factors, trans, pos, auts, triple, factauts, ind,
          kerimg, supfact, facttriple;

    result:= true;
    storedfus:= GetFusionMap( tbl, fact );
    fusid:= Concatenation( Identifier( tbl ), " -> ", Identifier( fact ) );

    if storedfus <> fail then
      if Maximum( storedfus ) > Length( Irr( fact ) ) or
         not IsSubset( Irr( tbl ),
                       List( Irr( fact ), x -> x{ storedfus } ) ) then
        result:= false;
      else
        # If the stored fusion fits then keep it.
        ker:= ClassPositionsOfKernel( storedfus );
        f:= CharacterTableFactorGroup( tbl, ker );
        tr:= TransformingPermutationsCharacterTables( fact, f );
        if tr = fail then
          result:= false;
        else
          map1:= OnTuples( storedfus, tr.columns );
          map2:= GetFusionMap( tbl, f );
          if ElementProperty( tr.group, pi -> map1 = OnTuples( map2, pi ) )
             = fail then
            result:= false;
          fi;
        fi;
      fi;
    else
      result:= false;
    fi;

    if result = false then
      # The stored fusion does not fit, or no fusion is stored.
      quot:= Size( tbl ) / Size( fact );
      classes:= SizesConjugacyClasses( tbl );
      kernels:= Filtered( ClassPositionsOfNormalSubgroups( tbl ),
                          list -> Sum( classes{ list } ) = quot );
      factors:= List( kernels, n -> tbl / n );
      trans:= List( factors,
                    f -> TransformingPermutationsCharacterTables( f,
                             fact ) );
      if ForAll( trans, x -> x = fail ) then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.FactorFusion", fusid,
            "no factor fusion is possible" );
        storedfus:= fail;
      elif storedfus = fail then
        # Choose a fusion.
        CTblLib.PrintTestLog( "I", "CTblLib.Test.FactorFusion", fusid,
            "add missing fusion" );
        pos:= PositionProperty( trans, IsRecord );
        storedfus:= OnTuples( GetFusionMap( tbl, factors[ pos ] ),
                              trans[ pos ].columns );
        Print( LibraryFusion( tbl, rec( name:= fact,
                                        map:= storedfus) ) );
      else
        # Replace the stored fusion.
        CTblLib.PrintTestLog( "E", "CTblLib.Test.FactorFusion", fusid,
            "replace wrong fusion" );
        pos:= Position( kernels, ClassPositionsOfKernel( storedfus ) );
        if trans[ pos ] = fail then
          pos:= PositionProperty( trans, IsRecord );
        fi;
        storedfus:= OnTuples( GetFusionMap( tbl, factors[ pos ] ),
                              trans[ pos ].columns );
        Print( LibraryFusion( tbl, rec( name:= fact,
                                        map:= storedfus ) ) );
      fi;
    fi;

    if storedfus <> fail then
      # Check whether the fusion is compatible with outer automorphisms.
#T Give an example where this helps.
      auts:= CTblLib.PermutationsInducedByOuterAutomorphisms( tbl );
      factauts:= CTblLib.PermutationsInducedByOuterAutomorphisms( fact );
      ker:= ClassPositionsOfKernel( storedfus );
      for triple in auts do
        if Set( ker ) = Set( OnTuples( ker, triple[1] ) ) then
          # The outer automorphism acts on the factor group.
          ind:= CTblLib.PermutationInducedOnFactor( storedfus, triple[1] );
          if ind <> fail then
            kerimg:= Set( triple[3]{ ker } );
            supfact:= First( ComputedClassFusions( triple[2] ),
                             r -> ClassPositionsOfKernel( r.map ) = kerimg );
            if supfact <> fail then
              facttriple:= First( factauts,
                                  x -> Identifier( x[2] ) = supfact.name );
              if facttriple <> fail then
                if ind <> facttriple[1] then
                  # The permutations do not fit together.
                  result:= false;
                  CTblLib.PrintTestLog( "I", "CTblLib.Test.FactorFusion",
                      fusid,
                      [ [ "incompatible autom. induced by ",
                          Identifier( triple[2] ) ] ] );
#T So it is reasonable to define extensions from subgroups;
#T Expl:  The first M22 < U6(2) extends to M22.2, the others do not;
#T        the same happens in preimages in (2^2x3).U6(2),
#T        provided that the automorphism of order three acts at all.
                fi;
              fi;
            fi;
          fi;
        fi;
      od;
    fi;

    return result;
    end;


#############################################################################
##
#F  CTblLib.Test.FusionToTom( <tbl> )
##
CTblLib.Test.FusionToTom:= function( tbl )
    local tom, result, tommaxes, tblmaxes, orders, primperm, t, nam, pos,
          fusrec, storedfus, fus, compat1, compat2, map, tomprimperm,
          tblfustom;

    tom:= TableOfMarks( tbl );
    if tom = fail then
      if HasFusionToTom( tbl ) then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.FusionToTom",
            Identifier( tbl ), "no table of marks but HasFusionToTom?" );
        return false;
      fi;
      return true;
    fi;

    result:= true;

    # Compare the compatibility of the maximal subgroup info.
    tommaxes:= MaximalSubgroupsTom( tom )[1];
    if HasMaxes( tbl ) then
      tblmaxes:= List( Maxes( tbl ), CharacterTable );
      orders:= OrdersTom( tom ){ tommaxes };
      if Length( orders ) <> Length( tblmaxes ) then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.FusionToTom",
            Identifier( tbl ),
            [ [ "different number of maxes in char. table (",
                Length( tblmaxes ), ") and table of marks (",
                Length( tommaxes ), ")" ] ] );
        result:= false;
      elif orders <> List( tblmaxes, Size ) then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.FusionToTom",
            Identifier( tbl ),
            [ "table of marks for `", Identifier( tom ),
              "' has maxes of orders" ],
            String( orders ),
            [ "but the character table has ", List( tblmaxes, Size ) ] );
        result:= false;
      fi;
    elif IsSubset( List( NotifiedFusionsToLibTom( Identifier( tom ) ),
                         x -> x[2] ), tommaxes ) then
      # The maxes of the character table should be added.
      tommaxes:= List( tommaxes,
                       x -> First( NotifiedFusionsToLibTom( Identifier( tom ) ),
                                   y -> y[2] = x )[1] );
      tblmaxes:= [];
      for nam in tommaxes do
        pos:= Position( LIBLIST.TOM_TBL_INFO[1],
                LowercaseString( Identifier( TableOfMarks( nam ) ) ) );
        if pos = fail then
          Add( tblmaxes, fail );
        else
          Add( tblmaxes, LibInfoCharacterTable( LIBLIST.TOM_TBL_INFO[2][ pos ]
                             ).firstName );
        fi;
      od;
      CTblLib.PrintTestLog( "I", "CTblLib.Test.FusionToTom",
          Identifier( tbl ),
          "add `maxes' for the character table,",
          "for the table of marks these are",
          String( tommaxes ),
          "the character table names are",
          String( tblmaxes ) );
    fi;

    # Check existence & compatibility of a stored fusion.
    if HasFusionToTom( tbl ) then
      fusrec:= FusionToTom( tbl );
      if fusrec.name <> Identifier( tom ) then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.FusionToTom",
            Identifier( tbl ),
            [ [ "`name' of `FusionToTom' should equal `Identifier' of `",
                Identifier( tom ) ] ] );
        result:= false;
      fi;
      storedfus:= fusrec.map;
    else
      fusrec:= rec();
      storedfus:= fail;
    fi;
    fus:= PossibleFusionsCharTableTom( tbl, tom );
    if   IsEmpty( fus ) then
      CTblLib.PrintTestLog( "E", "CTblLib.Test.FusionToTom",
          Identifier( tbl ),
          [ [ "no fusion to tom `", Identifier( tom ), "' possible" ] ] );
      return false;
    elif storedfus <> fail and not storedfus in fus then
      CTblLib.PrintTestLog( "E", "CTblLib.Test.FusionToTom",
          Identifier( tbl ),
          [ [ "stored fusion to tom `", Identifier( tom ), "' is wrong" ] ] );
      result:= false;
    fi;

    # If the `Maxes' value of `tbl' is known then choose a fusion
    # that is compatible with the primitive perm. characters (if possible).
    compat1:= fus;
    compat2:= fus;
    if HasMaxes( tbl ) then
      primperm:= [];
      for t in tblmaxes do
        if GetFusionMap( t, tbl ) <> fail then
          Add( primperm, TrivialCharacter( t )^tbl );
        else
          Add( primperm, fail );
        fi;
      od;
      if fail in primperm then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.FusionToTom",
            Identifier( tbl ),
            "missing maxes fusions from character tables in ",
            String( Maxes( tbl ){ Filtered( [ 1 .. Length( tblmaxes ) ],
                                  i -> primperm[i] = fail ) } ) );
        result:= false;
      else
        compat1:= [];
        compat2:= [];
        for map in fus do
          tomprimperm:= PermCharsTom( map, tom ){ tommaxes };
          if tomprimperm = primperm then
            Add( compat1, map );
            Add( compat2, map );
          elif SortedList( tomprimperm ) = SortedList( primperm ) then
            Add( compat1, map );
          fi;
        od;
        if IsEmpty( compat1 ) then
          CTblLib.PrintTestLog( "E", "CTblLib.Test.FusionToTom",
              Identifier( tbl ),
              [ [ "no fusion to tom `", Identifier( tom ),
                  "' compatible with `Maxes'" ] ] );
          return false;
        fi;
      fi;
    fi;

    if IsBound( fusrec.text ) then
      # Check that the text does not lie.
      if Length( fus ) = 1
         and fusrec.text <> "fusion map is unique"
         and ( Length( fusrec.text ) < 21 or
               fusrec.text{ [ 1 .. 21 ] } <> "fusion map is unique," ) then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.FusionToTom", Identifier( tbl ),
            [ [ "text for stored fusion tbl to tom `", Identifier( tom ),
                "' is wrong (map is unique!)" ] ] );
        result:= false;
      elif 1 < Length( fus )
         and ( fusrec.text = "fusion map is unique"
               or ( Length( fusrec.text ) >= 21 and
                    fusrec.text{ [ 1 .. 21 ] } = "fusion map is unique," ) ) then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.FusionToTom", Identifier( tbl ),
            [ [ "text for stored fusion tbl to tom `", Identifier( tom ),
                "' is wrong (map is not unique!)" ] ] );
        result:= false;
      fi;
    fi;

    # Check that the permutation does what it shall do.
    if IsBound( fusrec.perm ) and
       Permuted( PermCharsTom( fusrec.map, tom ){ tommaxes }, fusrec.perm )
         <> primperm then
      CTblLib.PrintTestLog( "E", "CTblLib.Test.FusionToTom",
          Identifier( tbl ),
          "stored permutation of maxes in fusion to tom is wrong" );
      result:= false;
    fi;

    # (We do *not* use automorphisms of `tom' because
    # the ambiguities can be resolved using the group stored in `tom'.)
    if 1 < Length( RepresentativesFusions( AutomorphismsOfTable( tbl ), fus,
                       Group( () ) ) ) then
      if storedfus = fail then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.FusionToTom",
            Identifier( tbl ),
            [ [ "ambiguous fusion to tom `", Identifier( tom ),
                "', no map stored" ] ] );
        result:= false;
      elif not IsBound( fusrec.text ) then
        # The ambiguity of the fusion is not mentioned in the stored fusion.
        CTblLib.PrintTestLog( "E", "CTblLib.Test.FusionToTom",
            Identifier( tbl ),
            [ [ "ambiguous fusion to tom `", Identifier( tom ),
                "', no text stored" ] ] );
        result:= false;
      elif     PositionSublist( fusrec.text, "together" ) = fail
           and PositionSublist( fusrec.text, "determined" ) = fail then
        # The ambiguity of the fusion is not mentioned in the stored fusion.
        CTblLib.PrintTestLog( "E", "CTblLib.Test.FusionToTom",
            Identifier( tbl ),
            [ "ambiguous fusion to tom `", Identifier( tom ), "'," ],
            "without \"together\" or \"determined\" in text" );
        result:= false;
      elif not storedfus in compat1 then
        # The stored fusion does not fit but the text supports it.
        CTblLib.PrintTestLog( "E", "CTblLib.Test.FusionToTom",
            Identifier( tbl ),
            [ "ambiguous fusion to tom `", Identifier( tom ), "'," ],
            "with text but map is incompatible" );
        result:= false;
      elif ( not storedfus in compat2 ) and not IsBound( fusrec.perm ) then
        # The maxes don't fit but the text supports the stored map.
        CTblLib.PrintTestLog( "E", "CTblLib.Test.FusionToTom",
            Identifier( tbl ),
            [ "ambiguous fusion to tom `", Identifier( tom ), "'," ],
            "with text, but map requires permutation of maxes" );
        result:= false;
      else
        # The text explains how the ambiguity was solved, and the maxes fit.
      fi;
      return result;
    fi;

    # Now we know that the fusion is unique up to table automorphisms.
    # Check that the text does not lie.
    if IsBound( fusrec.text ) and
       1 < Length( fus ) and
       PositionSublist( fusrec.text, "unique up to table " ) = fail then
      CTblLib.PrintTestLog( "E", "CTblLib.Test.FusionToTom",
          Identifier( tbl ),
          [ "text for stored fusion tom `", Identifier( tom ), "'" ],
          "is wrong (map is unique up to table automorphisms!)" );
    fi;

    # Propose adding/replacing a compatible fusion if necessary.
    tblfustom:= rec( name:= Identifier( tom ) );
    if Length( fus ) = 1 then
      tblfustom.text:= "fusion map is unique";
    elif Length( compat1 ) = Length( fus ) then
      tblfustom.text:= "fusion map is unique up to table autom.";
    else
      tblfustom.text:=
          "fusion map is unique up to table autom., compatible with `Maxes'";
    fi;

    if storedfus = fail or not storedfus in compat1 then
      if IsEmpty( compat2 ) then
        # A permutation of maxes is necessary.
        tblfustom.map:= compat1[1];
        tblfustom.perm:= SortingPerm( primperm ) /
            SortingPerm( PermCharsTom( compat1[1], tom ){ tommaxes } );
      else
        tblfustom.map:= compat2[1];
      fi;
      if storedfus = fail then
        CTblLib.PrintTestLog( "I", "CTblLib.Test.FusionToTom",
            Identifier( tbl ),
            "add the following fusion to tom" );
      else
        CTblLib.PrintTestLog( "E", "CTblLib.Test.FusionToTom",
            Identifier( tbl ),
            "the stored fusion to tom is not compatible with maxes",
            "replace it by the following one" );
      fi;
      Print( LibraryFusionTblToTom( tbl, tblfustom ) );
    elif not storedfus in compat2 then
      if not IsBound( fusrec.perm ) then
        # We must mention the necessary permutation.
        if IsEmpty( compat2 ) then
          # Propose a permutation.
          tblfustom.map:= storedfus;
          tblfustom.perm:= SortingPerm( PermCharsTom( storedfus, tom ){
                               tommaxes } ) / SortingPerm( primperm );
          CTblLib.PrintTestLog( "E", "CTblLib.Test.FusionToTom",
              Identifier( tbl ),
              "the stored fusion to tom needs the following perm. of maxes" );
          Print( LibraryFusionTblToTom( tbl, tblfustom ) );
        else
          CTblLib.PrintTestLog( "E", "CTblLib.Test.FusionToTom",
              Identifier( tbl ),
              "the stored fusion to tom would need a permutation of maxes" );
        fi;
      fi;
      if not IsEmpty( compat2 ) then
        # We could replace the fusion by one without permutation.
        CTblLib.PrintTestLog( "I", "CTblLib.Test.FusionToTom",
            Identifier( tbl ),
            "the stored fusion to tom could be replaced by one without perm." );
        tblfustom.map:= compat2[1];
        Print( LibraryFusionTblToTom( tbl, tblfustom ) );
      fi;
    else
      # The stored fusion can be kept.
    fi;

#T Test also whether for all fusions to the table of marks,
#T there is a corresponding fusion to the character table?
#T Note that here we have a conceptual problem:
#T `CharacterTable' returns ``the'' character table of `tom',
#T but from the viewpoint of the fusions, there may be several tables
#T in the library!

    # Return the result.
    return result;
    end;


#############################################################################
##
#F  CTblLib.Test.Fusions( <tbl> )
##
##  <#GAPDoc Label="test:CTblLib.Test.Fusions">
##  <Mark><C>CTblLib.Test.Fusions( <A>tbl</A> )</C></Mark>
##  <Item>
##    checks the class fusions that are stored on the table <A>tbl</A>:
##    No duplicates shall occur, each subgroup fusion or factor fusion is
##    tested using <C>CTblLib.Test.SubgroupFusion</C> or
##    <C>CTblLib.Test.FactorFusion</C>, respectively,
##    and a fusion to the table of marks for <A>tbl</A> is tested using
##    <C>CTblLib.Test.FusionToTom</C>.
##  </Item>
##  <#/GAPDoc>
##
CTblLib.Test.Fusions:= function( sub )
    local result, destnames, dupl, tbl, record, fus, name;

    # Initialize the result.
    result:= true;

    # Check that there are no duplicate fusions.
    # (Duplicates distinguished by specifications are allowed,
    # they arise for example in direct product constructions.)
    destnames:= SortedList( List( ComputedClassFusions( sub ),
                                  r -> r.name ) );
    dupl:= destnames{ Filtered( [ 1 .. Length( destnames ) ],
               i -> PositionSorted( destnames, destnames[i] ) <> i ) };
    dupl:= Filtered( ComputedClassFusions( sub ),
               r -> r.name in dupl and not IsBound( r.specification ) );
    if not IsEmpty( dupl ) then
      dupl:= List( dupl, r -> Concatenation( "ALF(\"", Identifier( sub ),
                                  "\",\"", r.name, "\"..."  ) );
      CTblLib.PrintTestLog( "E", "CTblLib.Test.Fusions", Identifier( sub ),
          Concatenation( [ "remove duplicate fusions" ], dupl ) );
      result:= false;
    fi;

    for record in ShallowCopy( ComputedClassFusions( sub ) ) do
      tbl:= CharacterTable( record.name );
      # Do not report a problem if `fail' is returned,
      # since direct products involving `sub' may have been
      # constructed before this test started.
      if tbl <> fail then
        if Size( sub ) <= Size( tbl ) then
          fus:= CTblLib.Test.SubgroupFusion( sub, tbl );
          if not IsRecord( fus ) then
            result:= false;
          elif record.map <> fus.map then
            CTblLib.PrintTestLog( "E", "CTblLib.Test.Fusions", Identifier( sub ),
                Concatenation( Identifier( sub ), " -> ", Identifier( tbl ) ),
                "replace the stored fusion by the following one" );
            Print( LibraryFusion( sub, fus ) );
          elif IsBound( fus.replace ) and fus.replace = true then
            if IsBound( record.text ) and IsBound( fus.text ) and
               record.text = fus.text then
              CTblLib.PrintTestLog( "E", "CTblLib.Test.Fusions", Identifier( sub ),
                  Concatenation( Identifier( sub ), " -> ", Identifier( tbl ) ),
                  "strange fusion, perhaps ambiguous in spite of text?" );
#T check that the texts of ambiguous fusions do not lie!
            else
              CTblLib.PrintTestLog( "E", "CTblLib.Test.Fusions", Identifier( sub ),
                  Concatenation( Identifier( sub ), " -> ", Identifier( tbl ) ),
                  "replace the text of the stored fusion by the following one" );
            fi;
            Print( LibraryFusion( sub, fus ) );
          fi;
        else
          result:= CTblLib.Test.FactorFusion( sub, tbl ) and result;
        fi;
      fi;
    od;

    result:= CTblLib.Test.FusionToTom( sub ) and result;

    # Return the result.
    return result;
    end;


#############################################################################
##
#V  CTblLib.HardPowerMaps
##
##  `CTblLib.HardPowerMaps' is a list of pairs `[ <tblname>, <p> ]'
##  where <tblname> is a `Identifier' value of a character
##  table such that `CTblLib.Test.PowerMaps' shall omit the compatibility
##  check for the <p>-th power map.
##
CTblLib.HardPowerMaps:= [];

Add( CTblLib.HardPowerMaps, [ "2^12:Sz(8)", 2 ] );
# 5040 possibilities!


#############################################################################
##
#F  CTblLib.Test.PowerMaps( <tbl> )
##
##  <#GAPDoc Label="test:CTblLib.Test.PowerMaps">
##  <Mark><C>CTblLib.Test.PowerMaps( <A>tbl</A> )</C></Mark>
##  <Item>
##    checks whether all <M>p</M>-th power maps are stored on <A>tbl</A>,
##    for prime divisors <M>p</M> of the order of <M>G</M>,
##    and whether they are correct.
##    (This includes the information about uniqueness of the power maps.)
##  </Item>
##  <#/GAPDoc>
##
CTblLib.Test.PowerMaps:= function( tbl )
    local result, powermaps, info, p, pow, reps, storedmap, name;

    # Initialize the result.
    result:= true;

    name:= Identifier( tbl );
    powermaps:= ComputedPowerMaps( tbl );
    if HasInfoText( tbl ) then
      info:= InfoText( tbl );
    else
      info:= "";
    fi;
    for p in Set( Factors( Size( tbl ) ) ) do

      # Shall the test be omitted?
      if [ name, p ] in CTblLib.HardPowerMaps then
        if not IsBound( powermaps[p] ) then
          CTblLib.PrintTestLog( "E", "CTblLib.Test.PowerMaps", name,
              [ "omitting check of ", Ordinal( p ),
                " power map (no map stored)" ] );
          result:= false;
        else
          # At least test the existing map for consistency.
          pow:= PossiblePowerMaps( tbl, rec( powermap:= powermaps[p] ) );
          if IsEmpty( pow ) then
            CTblLib.PrintTestLog( "E", "CTblLib.Test.PowerMaps", name,
                [ "stored ", Ordinal( p ), " power map is wrong" ] );
            result:= false;
          else
            CTblLib.PrintTestLog( "E", "CTblLib.Test.PowerMaps", name,
                [ "omitting check of ", Ordinal( p ), " power map" ] );
          fi;
        fi;
        return result;
      fi;

      pow:= PossiblePowerMaps( tbl, p );
      reps:= RepresentativesPowerMaps( pow,
                 MatrixAutomorphisms( Irr( tbl ) ) );
      if not IsBound( powermaps[p] ) then
        CTblLib.PrintTestLog( "I", "CTblLib.Test.PowerMaps", name,
            [ [ "no ", Ordinal( p ), " power map stored" ] ] );
        storedmap:= fail;
      else
        storedmap:= powermaps[p];
      fi;

      if   IsEmpty( pow ) then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.PowerMaps", name,
            [ [ "no ", Ordinal( p ), " power map possible" ] ] );
        result:= false;
      elif storedmap <> fail and not storedmap in pow then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.PowerMaps", name,
            [ [ "stored ", Ordinal( p ), " power map is wrong" ] ] );
        result:= false;
      elif Length( reps ) <> 1 then
        if PositionSublist( info, Concatenation( Ordinal( p ),
               " power map determined" ) ) = fail then
          CTblLib.PrintTestLog( "E", "CTblLib.Test.PowerMaps", name,
              [ [ "ambiguous ", Ordinal( p ), " power map" ] ] );
          result:= false;
        fi;
      elif Length( pow ) <> 1 then
        if PositionSublist( info, Concatenation( Ordinal( p ),
               " power map determined only up to matrix automorphism" ) )
               <> fail then
          CTblLib.PrintTestLog( "E", "CTblLib.Test.PowerMaps", name,
              [ [ Ordinal( p ), " power map is det. only up to mat. aut." ] ] );
          result:= false;
        fi;
      elif PositionSublist( info, Concatenation( Ordinal( p ),
               " power map determined" ) ) <> fail then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.PowerMaps", name,
            [ [ "unnecessary statement about ", Ordinal( p ), " power map" ] ] );
        result:= false;
      fi;

      if storedmap = fail then
        if   Length( pow ) = 1 then
          CTblLib.PrintTestLog( "I", "CTblLib.Test.PowerMaps", name,
              [ [ "store the following unique ", Ordinal( p ), " power map" ] ] );
          Print( pow[1], "\n" );
        elif Length( reps ) = 1 then
          CTblLib.PrintTestLog( "I", "CTblLib.Test.PowerMaps", name,
              [ [ "store the following ", Ordinal( p ),
                  " power map (unique up to matrix automorphisms)" ] ] );
          Print( reps[1], "\n" );
        fi;
      fi;

    od;

    # Return the result.
    return result;
    end;


#############################################################################
##
#F  CTblLib.Test.BlocksInfo( <modtbl> )
##
##  <#GAPDoc Label="test:CTblLib.Test.BlocksInfo">
##  <Mark><C>CTblLib.Test.BlocksInfo( <A>modtbl</A> )</C></Mark>
##  <Item>
##    checks whether the decomposition matrices of all blocks of the Brauer
##    table <A>modtbl</A> are integral, as well as the inverses of their
##    restrictions to basic sets.
##  </Item>
##  <#/GAPDoc>
##
CTblLib.Test.BlocksInfo:= function( modtbl )
    local info, name, i;

    info:= BlocksInfo( modtbl );
    name:= Identifier( modtbl );
    for i in [ 1 .. Length( info ) ] do
      if     IsBound( info[i].decinv )
         and not ForAll( Concatenation( info[i].decinv ), IsInt ) then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.BlocksInfo", name,
            [ [ "nonintegral entry in ", Ordinal( i ), " `decinv'" ] ] );
      fi;
      if not ForAll( Concatenation( DecompositionMatrix( modtbl, i ) ),
                     IsInt ) then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.BlocksInfo", name,
            [ [ "nonintegral entry in ", Ordinal( i ), " dec. mat." ] ] );
      fi;
    od;

    return true;
    end;


#############################################################################
##
#F  CTblLib.Test.TensorDecomposition( <modtbl> )
##
##  <#GAPDoc Label="test:CTblLib.Test.TensorDecomposition">
##  <Mark><C>CTblLib.Test.TensorDecomposition( <A>modtbl</A> )</C></Mark>
##  <Item>
##    checks whether the tensor products of irreducible Brauer characters of
##    the Brauer table <A>modtbl</A> decompose into Brauer characters.
##  </Item>
##  <#/GAPDoc>
##
CTblLib.Test.TensorDecomposition:= function( modtbl )
    local ibr, name, i, tens;

    ibr:= IBr( modtbl );
    name:= Identifier( modtbl );
    for i in [ 1 .. Length( ibr ) ] do
      tens:= Set( Tensored( [ ibr[i] ], ibr{ [ 1 .. i ] } ) );
      if not ForAll( Decomposition( ibr, tens, "nonnegative" ), IsList ) then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.TensorDecomposition", name,
            [ [ "failed for products with X[", i, "]" ] ] );
        return false;
      fi;
    od;
    if HasInfoText( modtbl ) and
       PositionSublist( InfoText( modtbl ), "TENS" ) = fail then
      CTblLib.PrintTestLog( "I", "CTblLib.Test.TensorDecomposition", name,
          "add \"TENS\" to `InfoText'" );
    fi;

    return true;
    end;


#############################################################################
##
#F  CTblLib.Test.Indicators( <modtbl> )
##
##  <#GAPDoc Label="test:CTblLib.Test.Indicators">
##  <Mark><C>CTblLib.Test.Indicators( <A>modtbl</A> )</C></Mark>
##  <Item>
##    checks the <M>2</M>-nd indicators of the Brauer table <A>modtbl</A>:
##    The indicator of a Brauer character is zero iff it has at least one
##    nonreal value.
##    In odd characteristic, the indicator of an irreducible Brauer character
##    is equal to the indicator of any ordinary irreducible character that
##    contains it as a constituent, with odd multiplicity.
##    In characteristic two, we test that all nontrivial real irreducible
##    Brauer characters have even degree,
##    and that irreducible Brauer characters with indicator <M>-1</M> lie in
##    the principal block.
##  </Item>
##  <#/GAPDoc>
##
CTblLib.Test.Indicators:= function( modtbl )
    local name, ind, modind, unknown, irr, result, i, info, decmat, j, chi,
          odd;

    name:= Identifier( modtbl );
    if not IsBrauerTable( modtbl ) then
      Error( "<modtbl> must be a Brauer table" );
    elif     UnderlyingCharacteristic( modtbl ) = 2
         and not IsBound( ComputedIndicators( modtbl )[2] ) then
      CTblLib.PrintTestLog( "I", "CTblLib.Test.Indicators", name,
          "2nd indicator is not stored" );
      return true;
    fi;

    ind:= Indicator( OrdinaryCharacterTable( modtbl ), 2 );
    modind:= Indicator( modtbl, 2 );
    unknown:= Filtered( [ 1 .. Length( modind ) ],
                        i -> IsUnknown( modind[i] ) );
    if not IsEmpty( unknown ) then
      CTblLib.PrintTestLog( "I", "CTblLib.Test.Indicators", name,
          [ [ Length( unknown ), " unknown indicators" ] ] );
    fi;

    irr:= Irr( modtbl );

    result:= true;

    for i in [ 1 .. Length( BlocksInfo( modtbl ) ) ] do

      info:= BlocksInfo( modtbl )[i];
      decmat:= DecompositionMatrix( modtbl, i );

      for j in [ 1 .. Length( info.modchars ) ] do

        chi:= irr[ info.modchars[j] ];

        if   ForAny( chi, x -> GaloisCyc( x, -1 ) <> x ) then

          # The indicator of a Brauer character is zero iff it has
          # at least one nonreal value.
          if modind[ info.modchars[j] ] <> 0 then
            CTblLib.PrintTestLog( "E", "CTblLib.Test.Indicators", name,
                [ [ "indicator of X[", info.modchars[j], "] (degree ", chi[1],
                    ") must be 0, not ", modind[ info.modchars[j] ] ] ] );
            result:= false;
          fi;

        elif UnderlyingCharacteristic( modtbl ) = 2 then

          # In characteristic two, irreducible Brauer characters with
          # indicator <M>-1</M> lie in the principal block.
          if modind[ info.modchars[j] ] = -1 and i <> 1 then
            CTblLib.PrintTestLog( "E", "CTblLib.Test.Indicators", name,
                [ [ "X[", info.modchars[j], "] (degree ", chi[1],
                    ") has indicator -1 but is in block ", i ] ] );
            result:= false;
          fi;

          # All nontrivial irreducible real Brauer characters
          # in characteristic two have even degree.
          if not ForAll( chi, x -> x = 1 ) and chi[1] mod 2 <> 0 then
            CTblLib.PrintTestLog( "E", "CTblLib.Test.Indicators", name,
                [ [ "degree X[", info.modchars[j], "][1] = ", chi[1],
                    " but should be even" ] ] );
            result:= false;
          fi;

        else

          # In odd characteristic, the indicator is equal to the indicator
          # of an ordinary character that contains it as a constituent,
          # with odd multiplicity.
          odd:= Filtered( [ 1 .. Length( decmat ) ],
                          x -> decmat[x][j] mod 2 <> 0 );
          if IsEmpty( odd ) then
            CTblLib.PrintTestLog( "E", "CTblLib.Test.Indicators", name,
                [ [ "no odd constituent for X[", info.modchars[j],
                    "] (degree ", chi[1], ")" ] ] );
            result:= false;
          else
            odd:= List( odd, x -> ind[ info.ordchars[x] ] );
            if ForAny( odd,
                   x -> x <> 0 and x <> modind[ info.modchars[j] ] ) then
              if 1 < Length( Set( odd ) ) then
                CTblLib.PrintTestLog( "E", "CTblLib.Test.Indicators", name,
                    [ [ "ind. of odd const. not unique for X[",
                        info.modchars[j], "] (degree ", chi[1], ")" ] ] );
              else
                CTblLib.PrintTestLog( "E", "CTblLib.Test.Indicators", name,
                    [ [ "indicator of X[", i.modchars[j], "] (degree ",
                      chi[1], ") must be ", odd[1], ", not ",
                      modind[ info.modchars[j] ] ] ] );
              fi;
              result:= false;
            fi;
          fi;

        fi;
      od;
    od;

    # Return the result.
    return result;
    end;


#############################################################################
##
#F  CTblLib.Test.FactorBlocks( <modtbl> )
##
##  <#GAPDoc Label="test:CTblLib.Test.FactorBlocks">
##  <Mark><C>CTblLib.Test.FactorBlocks( <A>modtbl</A> )</C></Mark>
##  <Item>
##    If the Brauer table <A>modtbl</A> is encoded using references to tables
##    of factor groups then we must make sure that the irreducible characters
##    of the underlying ordinary table and the factors in question are sorted
##    compatibly.
##    (Note that we simply take over the block information about the factors,
##    without applying an explicit mapping.)
##  </Item>
##  <#/GAPDoc>
##
CTblLib.Test.FactorBlocks:= function( modtbl )
    local name, test;

    if IsBound( modtbl!.factorblocks ) then
      name:= Identifier( modtbl );
      test:= CTblLib.ConsiderFactorBlocks( modtbl );
      if test = rec() then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.FactorBlocks", name,
            "no factor table found" );
        return false;
      elif IsBound( test.error ) then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.FactorBlocks", name,
            test.error );
        return false;
      elif test.info <> modtbl!.factorblocks then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.FactorBlocks", name,
            "inconsistent results" );
        return false;
      fi;
    fi;

    return true;
    end;


#############################################################################
##
#F  CTblLib.Test.InfoText( <tbl> )
##
##  <#GAPDoc Label="test:CTblLib.Test.InfoText">
##  <Mark><C>CTblLib.Test.InfoText( <A>tbl</A> )</C></Mark>
##  <Item>
##    checks some properties of the <Ref Attr="InfoText" BookName="ref"/>
##    value of <A>tbl</A>, if available.
##    Currently it is not recommended to use this value programmatically.
##    However, one can rely on the following structure of this value
##    for tables in the &GAP; Character Table Library.
##    <P/>
##    <List>
##    <Item>
##      The value is a string that consists of <C>\n</C> separated lines.
##    </Item>
##    <Item>
##      If a line of the form <Q>maximal subgroup of <A>grpname</A></Q>
##      occurs, where <A>grpname</A> is the name of a character table,
##      then a class fusion from the table in question to that with name
##      <A>grpname</A> is stored.
##    </Item>
##    <Item>
##      If a line of the form
##      <Q><M>n</M>th maximal subgroup of <A>grpname</A></Q> occurs
##      then additionally the name <A>nam</A><C>M</C><M>n</M> is admissible
##      for <A>tbl</A>.
##      Furthermore, if the table with name <A>grpname</A> has a
##      <Ref Func="Maxes"/> value then <A>tbl</A> is referenced in position
##      <M>n</M> of this list.
##    </Item>
##    </List>
##  </Item>
##  <#/GAPDoc>
#T  check also the cases <n>st, <n>nd, <n>rd!
#T  check also lines containing ``<n>th and <m>th''!
#T  check also lines ``<n>th maximal subgroup of ... group <grpname>...''!
##
CTblLib.Test.InfoText:= function( tbl )
    local name, result, info, pos, indices, pos3, groupname, info2, index,
          relname, reltbl, suptbl, maxes;

    name:= Identifier( tbl );
    result:= true;

    if not HasInfoText( tbl ) then
      # Nothing is to do.
      return true;
    elif not IsString( InfoText( tbl ) ) then
      CTblLib.PrintTestLog( "E", "CTblLib.Test.InfoText", name,
          "`InfoText' value is not a string" );
      return false;
    fi;

    for info in SplitString( InfoText( tbl ), "\n" ) do

      # Filter out phrases of the form `maximal subgroup of <grpname>'.
      pos:= PositionSublist( info, "maximal subgroup of " );
      if pos <> fail then

        # Get the indices if they are given.
        indices:= SplitString( info{ [ 1 .. pos-1 ] }, " ", " " );
        indices:= Filtered( List( indices, x -> Filtered( x, IsDigitChar ) ),
                            x -> x <> "" );
        indices:= SortedList( List( indices, Int ) );

        # Get the name of the overgroup.
        pos3:= PositionSublist( info, ",", pos + 20 );
        if pos3 = fail then
          pos3:= Length( info ) + 1;
        fi;
        groupname:= info{ [ pos + 20 .. pos3 - 1 ] };

        # Check that the line is what we expect it to be.
        info2:= Concatenation(
                    JoinStringsWithSeparator( List( indices, Ordinal ),
                        " and " ), " maximal subgroup of ", groupname );
        if info <> info2 and info <> Concatenation( info2, "," ) then
          result:= false;
          CTblLib.PrintTestLog( "E", "CTblLib.Test.InfoText", name,
              "confusing line", info );
        fi;

        # Check the admissibility of the relative names.
        for index in indices do
          relname:= Concatenation( groupname, "M", String( index ) );
          reltbl:= CharacterTable( relname );
          if reltbl = fail then
            result:= false;
            CTblLib.PrintTestLog( "E", "CTblLib.Test.InfoText", name,
                [ [ "no table `", relname, "'" ] ] );
          elif Identifier( reltbl ) <> name then
            result:= false;
            CTblLib.PrintTestLog( "E", "CTblLib.Test.InfoText", name,
                [ [ "tables `", name, "' and `", relname, "' differ" ] ] );
          fi;
        od;

        # Get the character table of the overgroup.
        suptbl:= CharacterTable( groupname );
        if   suptbl = fail then
          CTblLib.PrintTestLog( "E", "CTblLib.Test.InfoText", name,
              [ [ "substring `", info{ [ pos .. pos3 - 1 ] }, "'",
                  "but no table of `", groupname, "'" ] ] );
          result:= false;
        elif GetFusionMap( tbl, suptbl ) = fail then
          CTblLib.PrintTestLog( "E", "CTblLib.Test.InfoText", name,
              [ [ "missing fusion ", name, " -> ",
                  Identifier( suptbl ), " in spite of `InfoText'\n" ] ] );
          result:= false;
          # (We do not recompute the fusion here,
          # this is done in ...)
        fi;

        if suptbl <> fail and HasMaxes( suptbl ) and indices <> [] then
          # Compare the two values.
          maxes:= Maxes( suptbl );
          if Length( maxes ) < Maximum( indices ) then
            CTblLib.PrintTestLog( "E", "CTblLib.Test.InfoText", name,
                   [ [ "name `", groupname, "M", Maximum( indices ),
                       "' but Maxes value of length ", Length( maxes ) ] ] );
            result:= false;
          elif name <> maxes[ indices[1] ] or
               ForAny( indices, i -> maxes[i] <> name and
                maxes[i] <> Concatenation( groupname, "M", String( i ) ) ) then
            CTblLib.PrintTestLog( "E", "CTblLib.Test.InfoText", name,
                   [ [ "`", JoinStringsWithSeparator( Maxes{ indices }, ", " ),
                       "'?" ] ] );
            result:= false;
          fi;
        fi;
      fi;
    od;

    return result;
    end;


#############################################################################
##
#V  CTblLib.HardTableAutomorphisms
##
##  `CTblLib.HardTableAutomorphisms' is a list of `Identifier' values of
##  (ordinary or Brauer) character tables such that
##  `CTblLib.Test.TableAutomorphisms' shall omit the check for these tables.
##
CTblLib.HardTableAutomorphisms:= [];

Add( CTblLib.HardTableAutomorphisms, "O8+(3)M14" );
Add( CTblLib.HardTableAutomorphisms, "3.U6(2).3" );
Add( CTblLib.HardTableAutomorphisms, "3.U6(2).3mod5" );
Add( CTblLib.HardTableAutomorphisms, "3.U6(2).3mod7" );
Add( CTblLib.HardTableAutomorphisms, "3.U6(2).3mod11" );
Add( CTblLib.HardTableAutomorphisms, "2^2.(2^(1+8)_+:(S3xS3xS3))" );
Add( CTblLib.HardTableAutomorphisms, "3x2^2.2^(4+8):(S3xA5)" );
Add( CTblLib.HardTableAutomorphisms, "2^2x3xS3xU4(2)" );
Add( CTblLib.HardTableAutomorphisms, "(2^2x3).(3^(1+4).(2^7.3))" );
Add( CTblLib.HardTableAutomorphisms, "6x2.F4(2)" );
Add( CTblLib.HardTableAutomorphisms, "(2^2x3).2E6(2)" );


#############################################################################
##
#F  CTblLib.Test.TableAutomorphisms( <tbl> )
##
##  <#GAPDoc Label="test:CTblLib.Test.TableAutomorphisms">
##  <Mark><C>CTblLib.Test.TableAutomorphisms( <A>tbl</A> )</C></Mark>
##  <Item>
##    checks whether the table automorphisms are stored on <A>tbl</A>,
##    and whether they are correct.
##    Also all available Brauer tables of <A>tbl</A> are checked.
##  </Item>
##  <#/GAPDoc>
##
CTblLib.Test.TableAutomorphisms:= function( tbl )
    local result, libinfo, p, ordtbl, info, name, aut, irr, irrset, powermap,
          nccl, stored, modtbl;

    # Initialize the result.
    result:= true;

Print( "#I  CTblLib.Test.TableAutomorphisms: testing ", tbl, "\n" );
    libinfo:= LibInfoCharacterTable( Identifier( tbl ) );

    # Exclude tables which do not need stored table automorphisms.
    if   libinfo = fail then
      # The table may be a Brauer table that can be constructed from the
      # construction info of its ordinary table.
      return true;
    elif HasOrdinaryCharacterTable( tbl ) then
      p:= UnderlyingCharacteristic( tbl );
      ordtbl:= OrdinaryCharacterTable( tbl );
      if 1 < Length( ClassPositionsOfPCore( ordtbl, p ) ) then
        # The Brauer table belongs to a proper factor group.
        # It will be tested when the ordinary table of this factor is tested.
        return true;
      elif IsPSolvableCharacterTable( ordtbl, p ) then
        # No modular library table is needed.
        # (However, if table automorphisms are stored then test them.)
        if not HasAutomorphismsOfTable( tbl ) then
          return true;
        fi;
      elif HasConstructionInfoCharacterTable( ordtbl ) then
        info:= ConstructionInfoCharacterTable( ordtbl );
        if IsList( info ) and info[1] in [ "ConstructDirectProduct",
               "ConstructIndexTwoSubdirectProduct", "ConstructIsoclinic",
               "ConstructMGA", "ConstructPermuted", "ConstructV4G" ] then
          # The ordinary table was constructed from other ordinary tables,
          # see the corresponding methods for `BrauerTableOp'
          # (one in the GAP library and one in CTblLib).
          # No modular library table is needed.
          # (However, if table automorphisms are stored then test them.)
          if not HasAutomorphismsOfTable( tbl ) then
            return true;
          fi;
        fi;
      fi;
    fi;

    name:= Identifier( tbl );
    if name in CTblLib.HardTableAutomorphisms then
      # The test shall be omitted?
      CTblLib.PrintTestLog( "I", "CTblLib.Test.TableAutomorphisms", name,
          "omitting table automorphisms check" );
      result:= true;
    elif not HasAutomorphismsOfTable( tbl ) then
      if not ( HasConstructionInfoCharacterTable( tbl ) and
         ConstructionInfoCharacterTable( tbl )[1] = "ConstructPermuted" and
         Length( ConstructionInfoCharacterTable( tbl )[2] ) = 1 ) then
        if IsOrdinaryTable( tbl ) then
          aut:= TableAutomorphisms( tbl, Irr( tbl ), "closed" );
        else
          aut:= TableAutomorphisms( tbl, Irr( tbl ) );
        fi;
        CTblLib.PrintTestLog( "I", "CTblLib.Test.TableAutomorphisms", name,
            "table automorphisms missing, add" );
        Print( CTblLib.BlanklessString( GeneratorsOfGroup( aut ), 78 ), "\n" );
        result:= false;
      fi;
    else
      # Check that the stored automorphisms are automorphisms,
      # and that there are not more automorphisms than the stored ones.
      irr:= Irr( tbl );
      irrset:= Set( irr );
      powermap:= ComputedPowerMaps( tbl );
      nccl:= NrConjugacyClasses( tbl );
      stored:= AutomorphismsOfTable( tbl );
      aut:= Filtered( GeneratorsOfGroup( stored ),
                gen -> ForAll( irr, chi -> Permuted( chi, gen ) in irrset )
                       and ForAll( powermap,
                               x -> ForAll( [ 1 .. nccl ],
                                      y -> x[ y^gen ] = x[y]^gen ) ) );
      aut:= SubgroupNC( stored, aut );
      if aut <> stored then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.TableAutomorphisms", name,
            "wrong automorphisms stored" );
      fi;
      aut:= TableAutomorphisms( tbl, Irr( tbl ), aut );
      if aut <> stored then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.TableAutomorphisms", name,
            "replace wrong automorphisms by" );
        Print( CTblLib.BlanklessString( GeneratorsOfGroup( aut ), 78 ), "\n" );
        result:= false;
      fi;
    fi;

    # Check also the available Brauer tables.
    if IsOrdinaryTable( tbl ) then
      for p in Set( Factors( Size( tbl ) ) ) do
        modtbl:= tbl mod p;
        if IsCharacterTable( modtbl ) then
          result:= CTblLib.Test.TableAutomorphisms( modtbl ) and result;
        fi;
      od;
    fi;

    # Return the result.
    return result;
    end;


#############################################################################
##
##  2. Check ``construction tables''
##


#############################################################################
##
#F  CTblLib.Test.PermutedConstruction( <tbl> )
##
##  Check that the tables are really equivalent, that is, no defining
##  components differ.
##  Note that `ConstructPermuted' must not change the isomorphism type of
##  the table; if one wants to achieve this then one should use
##  `ConstructAdjusted'.
##
CTblLib.Test.PermutedConstruction:= function( tbl )
    local info, orig, filt;

    info:= ConstructionInfoCharacterTable( tbl );
    orig:= CallFuncList( CharacterTableFromLibrary, info[2] );
    if orig = fail then
      CTblLib.PrintTestLog( "E", "CTblLib.Test.PermutedConstruction",
            Identifier( tbl ),
            "table of `", info[2] , "' is not available" );
      return false;
    fi;
    if IsBound( info[3] ) then
      orig:= CharacterTableWithSortedClasses( orig, info[3] );
    fi;
    if IsBound( info[4] ) then
      orig:= CharacterTableWithSortedCharacters( orig, info[4] );
    fi;
    if Irr( orig ) <> Irr( tbl ) then
      CTblLib.PrintTestLog( "E", "CTblLib.Test.PermutedConstruction",
            Identifier( tbl ),
            "irreducibles do not fit" );
      return false;
    elif OrdersClassRepresentatives( orig ) <>
         OrdersClassRepresentatives( tbl ) then
      CTblLib.PrintTestLog( "E", "CTblLib.Test.PermutedConstruction",
            Identifier( tbl ),
            "element orders do not fit" );
      return false;
    else
      filt:= Filtered( [ 1 .. Length( ComputedPowerMaps( tbl ) ) ],
                         i -> IsBound( ComputedPowerMaps( tbl )[i] ) and
                              IsBound( ComputedPowerMaps( orig )[i] ) );
      if ForAny( filt, i -> ComputedPowerMaps( tbl )[i] <>
                            ComputedPowerMaps( orig )[i] ) then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.PermutedConstruction",
              Identifier( tbl ),
              "power maps do not fit" );
        return false;
      fi;
    fi;
    return true;
    end;


#############################################################################
##
#F  CTblLib.Test.DirectProductConstruction( <tbl> )
##
##  Check that there are at least two factors.
##
CTblLib.Test.DirectProductConstruction:= function( tbl )
    local info;

    info:= ConstructionInfoCharacterTable( tbl );
    if Length( info[2] ) < 2 then
      CTblLib.PrintTestLog( "I", "CTblLib.Test.DirectProductConstruction",
            Identifier( tbl ),
            "use `ConstructPermuted' not `ConstructDirectProduct'" );
      return false;
    fi;
    return true;
    end;


#############################################################################
##
#F  CTblLib.Test.GS3Construction( <tbl> )
##
##  Assume that <tbl> is an ordinary character table such that the first
##  entry of `ConstructionInfoCharacterTable( <tbl> )' is `"ConstructGS3"'.
##  `CTblLib.Test.GS3Construction' checks
##  whether the action on the classes of the index two subgroup is correct,
##  that the construction with `CharacterTableOfTypeGS3' yields the same
##  irreducibles as those of <tbl>,
##  that the available Brauer tables coincide with the automatically
##  constructed ones,
##  and that all Brauer tables are available that can be constructed this
##  way.
##
CTblLib.Test.GS3Construction:= function( tbl )
    local result, name, info, t2, t3, tnames, t, t3fustbl, aut, poss, ts3,
          p, tmodp, t2modp, t3modp, tblmodp, ts3modp, nsg;

    result:= true;
    name:= Identifier( tbl );
    info:= ConstructionInfoCharacterTable( tbl );
    t2:= CharacterTable( info[2] );
    t3:= CharacterTable( info[3] );

    tnames:= Intersection( NamesOfFusionSources( t2 ),
                           NamesOfFusionSources( t3 ) );
    t:= Filtered( List( tnames, CharacterTable ),
                  ttbl -> 6 * Size( ttbl ) = Size( tbl ) );
    if Length( t ) <> 1 then
      CTblLib.PrintTestLog( "E", "CTblLib.Test.GS3Construction", name,
          "table of the kernel of S3 not identified" );
      return false;
    fi;
    t:= t[1];

    # Get the action of `tbl' on the classes of `t3'.
    t3fustbl:= GetFusionMap( t3, tbl );
    aut:= Product( List( Filtered( InverseMap( t3fustbl ), IsList ),
                         x -> ( x[1], x[2] ) ), () );
    poss:= PossibleActionsForTypeGS3( t, t2, t3 );
    if not aut in poss then
      CTblLib.PrintTestLog( "E", "CTblLib.Test.GS3Construction", name,
          "the action of G.S3 on G.3 is not possible" );
      result:= false;
    elif Length( poss ) <> 1 then
      CTblLib.PrintTestLog( "E", "CTblLib.Test.GS3Construction", name,
             "the action of G.S3 on G.3 is not unique" );
      result:= false;
    fi;

    # Check that the two constructions (from the tables of subgroups
    # and from the info stored on `tbl') yield the same result.
    ts3:= CharacterTableOfTypeGS3( t, t2, t3, aut, "test" );
    if SortedList( Irr( ts3.table ) ) <> SortedList( Irr( tbl ) ) then
      CTblLib.PrintTestLog( "E", "CTblLib.Test.GS3Construction", name,
          "characters in constructed and library table differ" );
      result:= false;
    elif Irr( ts3.table ) <> Irr( tbl ) then
      CTblLib.PrintTestLog( "I", "CTblLib.Test.GS3Construction", name,
          "characters in constructed and library table sorted incompatibly" );
    fi;

    # Check that also the Brauer tables are available.
    for p in Set( Factors( Size( tbl ) ) ) do
      tmodp:= t mod p;
      t2modp:= t2 mod p;
      t3modp:= t3 mod p;
      if tmodp <> fail and t2modp <> fail and t3modp <> fail then
        tblmodp:= tbl mod p;
        ts3modp:= CharacterTableOfTypeGS3( tmodp, t2modp, t3modp, tbl,
            Concatenation( Identifier( tbl ), "mod", String( p ) ) );
        if tblmodp = fail then
          # Add the table to the library if it has trivial $O_p(G)$.
          nsg:= List( ClassPositionsOfNormalSubgroups( tbl ),
                      x -> Sum( SizesConjugacyClasses( tbl ){ x } ) );
          if not ForAny( nsg, n -> IsPrimePowerInt( n ) and n mod p = 0 ) then
            AutomorphismsOfTable( ts3modp.table );

            # Perform all checks for new Brauer tables.
            if CTblLib.Test.OneBrauerCharacterTable( ts3modp.table ) then
              CTblLib.PrintTestLog( "I", "CTblLib.Test.GS3Construction", name,
                  [ [ "add the following ", p, "-modular table" ] ] );
              Print( CTblLib.StringBrauer( ts3modp.table) );
            else
              CTblLib.PrintTestLog( "E", "CTblLib.Test.GS3Construction", name,
                  [ [ "proposed new ", p, "-modular table corrupted" ] ] );
            fi;
          fi;
        elif SortedList( Irr( ts3modp.table ) )
             <> SortedList( Irr( tblmodp ) ) then
          CTblLib.PrintTestLog( "E", "CTblLib.Test.GS3Construction", name,
              [ [ "characters in constructed and library table mod ", p,
                  " differ" ] ] );
          result:= false;
        elif Irr( ts3modp.table ) <> Irr( tblmodp ) then
          CTblLib.PrintTestLog( "I", "CTblLib.Test.GS3Construction", name,
              [ [ "characters in constructed and library table mod ", p,
                  " sorted incompatibly" ] ] );
        fi;
      fi;
    od;

    return result;
    end;


#############################################################################
##
#V  CTblLib.Test.ConstructionsFunctions
##
CTblLib.Test.ConstructionsFunctions:= [
    "ConstructGS3", CTblLib.Test.GS3Construction,
    "ConstructDirectProduct", CTblLib.Test.DirectProductConstruction,
    "ConstructPermuted", CTblLib.Test.PermutedConstruction,
    ];


#############################################################################
##
#F  CTblLib.Test.Constructions( <tbl> )
##
##  <#GAPDoc Label="test:CTblLib.Test.Constructions">
##  <Mark><C>CTblLib.Test.Constructions( <A>tbl</A> )</C></Mark>
##  <Item>
##    checks the <Ref Func="ConstructionInfoCharacterTable"/> status for
##    the table <A>tbl</A>:
##    If this attribute value is set then tests depending on this value are
##    executed;
##    if this attribute is not set then it is checked whether a description
##    of <A>tbl</A> via a construction would be appopriate.
##  </Item>
##  <#/GAPDoc>
##
CTblLib.Test.Constructions:= function( tbl )
    local result, name, constr, pos;

    if HasConstructionInfoCharacterTable( tbl ) then
      constr:= ConstructionInfoCharacterTable( tbl );
      if IsFunction( constr ) then
        CTblLib.PrintTestLog( "I", "CTblLib.Test.Constructions",
            Identifier( tbl ),
            "construction via function (allowed but not recommended)" );
      else
        # Apply tests depending on the construction type of the table.
        pos:= Position( CTblLib.Test.ConstructionsFunctions, constr[1] );
        if pos <> fail then
          return CTblLib.Test.ConstructionsFunctions[ pos + 1 ]( tbl );
        fi;
      fi;
    else
      # Check that tables of direct products are stored as such.
      if not IsEmpty( ClassPositionsOfDirectProductDecompositions( tbl ) ) then
        CTblLib.PrintTestLog( "I", "CTblLib.Test.Constructions",
            Identifier( tbl ),
            "direct product but not stored as such" );
        return false;
      fi;
    fi;

    return true;
    end;


#############################################################################
##
#F  CTblLib.Test.FactorsModPCore( <tbl> )
##
##  <#GAPDoc Label="test:CTblLib.Test.FactorsModPCore">
##  <Mark><C>CTblLib.Test.FactorsModPCore( <A>tbl</A> )</C></Mark>
##  <Item>
##    checks, for all prime divisors <M>p</M> of the order of <M>G</M>,
##    whether the factor fusion to the character table of <M>G/O_p(G)</M>
##    is stored on <A>tbl</A>.
##    <P/>
##    Note that if <M>G</M> is not <M>p</M>-solvable
##    and <M>O_p(G)</M> is nontrivial
##    then we can compute the <M>p</M>-modular Brauer table of <M>G</M>
##    if that of the factor group <M>G/O_p(G)</M> is available.
##    The availability of this table is indicated via the availability
##    of the factor fusion from <A>tbl</A>.
##  </Item>
##  <#/GAPDoc>
##
CTblLib.Test.FactorsModPCore:= function( tbl )
    local name, classes, p, op, fact, trans, cand;

    name:= Identifier( tbl );
    classes:= SizesConjugacyClasses( tbl );
    for p in Filtered( Set( Factors( Size( tbl ) ) ),
                       p -> BrauerTable( tbl, p ) = fail ) do
      op:= ClassPositionsOfPCore( tbl, p );
      if op <> [ 1 ] and
         ForAll( ComputedClassFusions( tbl ),
             fus -> ClassPositionsOfKernel( fus.map ) <> op ) then
        CTblLib.PrintTestLog( "I", "CTblLib.Test.FactorsModPCore", name,
            [ [ "no stored factor fusion to factor mod O_", p ] ] );
        # Try to find the table of the factor group in the library.
        # Note that `trans' is a gloal variable.
        fact:= CharacterTableFactorGroup( tbl, op );
        trans:= fail;
        cand:= OneCharacterTableName( FingerprintOfCharacterTable,
#T better use the identification function
          FingerprintOfCharacterTable( fact ),
          function( ftbl )
            if HasConstructionInfoCharacterTable( ftbl ) and
               ConstructionInfoCharacterTable( ftbl )[1]
                 = "ConstructPermuted" then
              return false;
            fi;
            trans:= TransformingPermutationsCharacterTables( fact, ftbl );
            return trans <> fail;
          end, true );

        if cand <> fail then
          CTblLib.PrintTestLog( "I", "CTblLib.Test.FactorsModPCore", name,
              "store the following fusion" );
          Print( LibraryFusion( Identifier( tbl ), rec( name := cand,
                     map := OnTuples( GetFusionMap( tbl, fact ),
                                      trans.columns ) ) ) );
        else
          CTblLib.PrintTestLog( "I", "CTblLib.Test.FactorsModPCore", name,
              "(the factor table is currently missing)" );
        fi;
      fi;
    od;
    return true;
    end;


#############################################################################
##
#F  CTblLib.Test.Maxes( <tbl> )
##
##  <#GAPDoc Label="test:CTblLib.Test.Maxes">
##  <Mark><C>CTblLib.Test.Maxes( <A>tbl</A> )</C></Mark>
##  <Item>
##    checks for those character tables <A>tbl</A> that have the
##    <Ref Func="Maxes"/> set whether the character tables
##    with the given names are really available,
##    that they are ordered w.r.t. non-increasing group order,
##    and that the fusions into <A>tbl</A> are stored.
##  </Item>
##  <#/GAPDoc>
##
CTblLib.Test.Maxes:= function( tbl )
    local result, name, maxestbls, maxorders, i;

    result:= true;
    if HasMaxes( tbl ) then
      name:= Identifier( tbl );
      maxestbls:= List( Maxes( tbl ), CharacterTable );
      maxorders:= [];
      for i in [ 1 .. Length( maxestbls ) ] do
        if maxestbls[i] = fail then
          CTblLib.PrintTestLog( "E", "CTblLib.Test.Maxes", name,
              [ [ "no table of ", Ordinal( i ), " max. subgroup" ] ] );
          result:= false;
        else
          Add( maxorders, Size( maxestbls[i] ) );
          if GetFusionMap( maxestbls[i], tbl ) = fail then
            CTblLib.PrintTestLog( "E", "CTblLib.Test.Maxes", name,
              [ [ "no fusion from ", Ordinal( i ), " max. subgroup" ] ] );
            result:= false;
          fi;
        fi;
      od;
      if not IsSortedList( - maxorders ) then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.Maxes", name,
            "orders of max. subgroups are not non-increasing" );
        result:= false;
      fi;
    fi;

    return result;
    end;


#############################################################################
##
#F  CTblLib.Test.ClassParameters( <tbl> )
##
##  <#GAPDoc Label="test:CTblLib.Test.ClassParameters">
##  <Mark><C>CTblLib.Test.ClassParameters( <A>tbl</A> )</C></Mark>
##  <Item>
##    checks the compatibility of class parameters of alternating and
##    symmetric groups (partitions describing cycle structures),
##    using the underlying group stored in the corresponding table of marks.
##  </Item>
##  <#/GAPDoc>
##
CTblLib.Test.ClassParameters:= function( tbl )
    local result, name, pos, paras, fus, tom, i, g, cyc, part, j;

    result:= true;

    if HasClassParameters( tbl ) and HasFusionToTom( tbl ) then
      name:= Identifier( tbl );
      pos:= Position( name, '.' );
      if pos = fail then
        pos:= Length( name ) + 1;
      fi;
      if name[1] = 'A' and ForAll( name{ [ 2 .. pos-1 ] }, IsDigitChar ) then
        paras:= ClassParameters( tbl );
        fus:= FusionToTom( tbl );
        tom:= TableOfMarks( tbl );
        for i in [ 1 .. Length( fus.map ) ] do
          g:= RepresentativeTom( tom, fus.map[i] );
          if not IsCyclic( g ) then
            CTblLib.PrintTestLog( "E", "CTblLib.Test.ClassParameters", name,
                [ [ Ordinal( i ), " subgroup is not cyclic" ] ] );
            result:= false;
          else
            cyc:= [];
            part:= paras[i][2];
            if IsList( part[1] ) then
              part:= part[1];
            fi;
            for j in part do
              if j <> 1 then
                if IsBound( cyc[ j-1 ] ) then
                  cyc[ j-1 ]:= cyc[ j-1 ] + 1;
                else
                  cyc[ j-1 ]:= 1;
                fi;
              fi;
            od;
            if cyc <> CycleStructurePerm( MinimalGeneratingSet( g )[1] ) then
              CTblLib.PrintTestLog( "E", "CTblLib.Test.ClassParameters", name,
                  [ [ Ordinal( i ), " class parameter is wrong" ] ] );
              result:= false;
            fi;
          fi;
        od;
      fi;
    fi;

    return result;
    end;


#############################################################################
##
##  <#GAPDoc Label="test:CTblLib.Test.GroupForGroupInfo">
##  <Mark><C>CTblLib.Test.GroupForGroupInfo( <A>tbl</A> )</C></Mark>
##  <Item>
##    checks that the entries in the list returned by
##    <Ref Func="GroupInfoForCharacterTable"/> fit to the character table
##    <A>tbl</A>.
##  </Item>
##  <#/GAPDoc>
##
CTblLib.Test.GroupForGroupInfo:= function( tbl )
    local result, size, name, info, G;

    result:= true;
    size:= Size( tbl );
    name:= Identifier( tbl );

    for info in GroupInfoForCharacterTable( tbl ) do
      G:= GroupForGroupInfo( info );
      if G = fail or not IsGroup( G ) then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.GroupForGroupInfo", name,
            [ [ "not admissible info ", String( info ) ] ] );
        result:= false;
      elif Size( G ) <> size then
        CTblLib.PrintTestLog( "E", "CTblLib.Test.GroupForGroupInfo", name,
            [ [ "wrong order for ", String( info ) ] ] );
        result:= false;
      fi;
    od;

    return result;
    end;


#############################################################################
##
#V  CTblLib.TestsForOrdinaryTables
##
CTblLib.TestsForOrdinaryTables:= [
      "InfoText",
      "RelativeNames",
      "FindRelativeNames",
      "PowerMaps",
      "TableAutomorphisms",
      "CompatibleFactorFusions",
      "FactorsModPCore",
      "Fusions",
      "Maxes",
      "ClassParameters",
      "Constructions",
      "GroupForGroupInfo",
    ];


#############################################################################
##
#V  CTblLib.TestsForBrauerTables
##
CTblLib.TestsForBrauerTables:= [
      "BlocksInfo",
      "TensorDecomposition",
      "Indicators",
      "FactorBlocks",
    ];
#T what about decomposition matrix?
#T (there were cases where the constructed table was o.k.
#T but did not fit to the ordinary table!)


#############################################################################
##
#F  CTblLib.TestOneOrdinaryCharacterTable( <tbl> )
##
CTblLib.TestOneOrdinaryCharacterTable:= function( tbl )
    local result, entry;

    result:= true;

    for entry in CTblLib.TestsForOrdinaryTables do
      if not CallFuncList( CTblLib.Test.( entry ), [ tbl ] ) then
        Print( "#E  problems with `CTblLib.Test.", entry, "' for `",
               Identifier( tbl ), "'\n" );
        result:= false;
      fi;
    od;

    return result;
    end;


#############################################################################
##
#F  CTblLib.TestOneBrauerCharacterTable( <modtbl> )
##
CTblLib.TestOneBrauerCharacterTable:= function( modtbl )
    local result, entry;

    result:= true;

    for entry in CTblLib.TestsForBrauerTables do
      if not CallFuncList( CTblLib.Test.( entry ), [ modtbl ] ) then
        Print( "#E  problems with `CTblLib.Test.", entry, "' for `",
               Identifier( modtbl ), "'\n" );
        result:= false;
      fi;
    od;

    return result;
    end;


#############################################################################
##
#F  CTblLib.TestOneCharacterTable( <tbl> )
##
##  Apply the tests introduced above to the ordinary table <tbl>.
##  Apply the tests introduced above to all available Brauer tables
##  of this table (including those Brauer tables that can be constructed by
##  GAP).
##
CTblLib.TestOneCharacterTable:= function( tbl )
    local result, p, modtbl;

    if not IsOrdinaryTable( tbl ) then
      Print( "#E  `", tbl, "' is not an ordinary character table\n" );
      return false;
    fi;

    result:= CTblLib.TestOneOrdinaryCharacterTable( tbl );

    for p in Set( Factors( Size( tbl ) ) ) do
      modtbl:= tbl mod p;
      if modtbl <> fail then
        result:= CTblLib.TestOneBrauerCharacterTable( modtbl ) and result;
      fi;
    od;

    return result;
    end;


#############################################################################
##
#E

