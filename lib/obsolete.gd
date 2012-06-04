#############################################################################
##
#W  obsolete.gd                  GAP library                     Steve Linton
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains a number of functions, or extensions of
##  functions to certain numbers or combinations of arguments, which
##  are now considered "deprecated" or "obsolescent", but which are presently
##  included in the system to maintain backwards compatibility.
##
##  Procedures for dealing with this functionality are not yet completely
##  agreed, but it will probably be removed from the system over
##  several releases.
##
##  These functions should *NOT* be used in the GAP library.
##
##  For each variable name that appears in this file, information should be
##  provided up to which version the name was documented, in which version
##  it was added to this file and hence is regarded as ``obsolescent'',
##  and in which version it is expected to be removed.
##
##  Concerning the distribution of code to `lib/obsolete.gd' and
##  `lib/obsolete.gi', the following rule holds.
##  Function declarations must be added to `lib/obsolete.gd', since the
##  declaration part of packages may reference them.
##  Also function bodies that rely only on variables declared in the
##  declaration part of the GAP library can be added to `lib/obsolete.gd'.
##  Only those method installations and function bodies must be added to
##  `lib/obsolete.gd' that rely on variables declared in the implementation
##  part of the GAP library.
##
##  <#GAPDoc Label="obsolete_intro">
##  <Index>obsolete</Index>
##  <Index>deprecated</Index>
##  <Index>legacy</Index>
##  
##  In general we try to keep &GAP;&nbsp;4 compatible with former releases
##  as much as possible.
##  Nevertheless,
##  from time to time it seems appropriate to remove some commands
##  or to change the names of some commands or variables.
##  There are various reasons for that:
##  Some functionality was improved and got another (hopefully better)
##  interface,
##  names turned out to be too special or too general for the underlying
##  functionality,
##  or names are found to be unintuitive or inconsistent with other names.
##  <P/>
##  In this chapter we collect such old names while pointing to the sections
##  which explain how to substitute them.
##  Usually, old names will be available for several releases;
##  they may be removed when they don't seem to be used any more.
##  <P/>
##  The obsolete &GAP; code is collected in two library files,
##  <F>lib/obsolete.gd</F> and <F>lib/obsolete.gi</F>.
##  By default, these files are read when &GAP; is started.
##  It may be useful to omit reading these files,
##  for example in order to make sure that one's own &GAP; code does not rely
##  on the obsolete variables.
##  For that, one can set the component <C>ReadObsolete</C> in the file
##  <F>gap.ini</F> to <K>false</K> (see <Ref Sect="sect:gap.ini"/>).
##  <P/>
##  (Note that the condition whether the library files with the obsolete
##  &GAP; code shall be read has changed.
##  In &GAP;&nbsp;4.3 and 4.4, the global variables <C>GAP_OBSOLESCENT</C>
##  and <C>GAPInfo.ReadObsolete</C>
##  &ndash;to be set in the user's <F>.gaprc</F> file&ndash;
##  were used to control this behaviour.)
##  <#/GAPDoc>
##


#############################################################################
##
#F  SmithNormalFormSQ( mat )
##
##  returns D = diagonalised form, D = P * M * Q, I = Q^-1
##
DeclareGlobalFunction( "SmithNormalFormSQ" );


#############################################################################
##
#F  DiagonalizeIntMatNormDriven(<mat>)  . . . . diagonalize an integer matrix
##
##  'DiagonalizeIntMatNormDriven'  diagonalizes  the  integer  matrix  <mat>.
##
##  It tries to keep the entries small  through careful  selection of pivots.
##
##  First it selects a nonzero entry for which the  product of row and column
##  norm is minimal (this need not be the entry with minimal absolute value).
##  Then it brings this pivot to the upper left corner and makes it positive.
##
##  Next it subtracts multiples of the first row from the other rows, so that
##  the new entries in the first column have absolute value at most  pivot/2.
##  Likewise it subtracts multiples of the 1st column from the other columns.
##
##  If afterwards not  all new entries in the  first column and row are zero,
##  then it selects a  new pivot from those  entries (again driven by product
##  of norms) and reduces the first column and row again.
##
##  If finally all offdiagonal entries in the first column  and row are zero,
##  then it  starts all over again with the submatrix  '<mat>{[2..]}{[2..]}'.
##
##  It is  based  upon  ideas by  George Havas  and code by  Bohdan Majewski.
##  G. Havas and B. Majewski, Integer Matrix Diagonalization, JSC, to appear
##
DeclareGlobalFunction( "DiagonalizeIntMatNormDriven" );


#############################################################################
##
#F  DeclarePackage( <name>, <version>, <tester> )
#F  DeclareAutoPackage( <name>, <version>, <tester> )
#F  DeclarePackageDocumentation( <name>, <doc>[, <short>[, <long> ] ] )
#F  DeclarePackageAutoDocumentation( <name>, <doc>[, <short>[, <long> ] ] )
#F  ReadPkg( ... )
#F  RereadPkg( ... )
#F  DoReadPkg( ... )
#F  DoRereadPkg( ... )
#F  RequirePackage( ... )
##
##  Up to GAP 4.3, these functions were needed inside the `init.g' files
##  of GAP packages, whereas from GAP 4.4 on, the `PackageInfo.g' files
##  are used instead.
##  So they are needed only for those packages which have a `PackageInfo.g'
##  file as well as an `init.g' file that works also with GAP 4.3
##  (or older).
##  They can be removed as soon as none of the available packages calls them.
##
BindGlobal( "DeclarePackage", Ignore );
BindGlobal( "DeclareAutoPackage", Ignore );
BindGlobal( "DeclarePackageAutoDocumentation", Ignore );
BindGlobal( "DeclarePackageDocumentation", Ignore );
BindGlobal( "ReadPkg", ReadPackage );
BindGlobal( "RereadPkg", RereadPackage );
BindGlobal( "DoReadPkg", function( arg )
    ReadPackage( arg[1] );
    return true;
    end );
BindGlobal( "DoRereadPkg", function( arg )
    RereadPackage( arg[1] );
    return true;
    end );
BindGlobal( "RequirePackage", LoadPackage );


#############################################################################
##
#V  KERNEL_VERSION
#V  VERSION
#V  GAP_ARCHITECTURE
#V  GAP_ROOT_PATHS
#V  USER_HOME
#V  GAP_RC_FILE
#V  DO_AUTOLOAD_PACKAGES
#V  DEBUG_LOADING
#V  CHECK_FOR_COMP_FILES
#V  BANNER
#V  QUIET
#V  AUTOLOAD_PACKAGES
#V  LOADED_PACKAGES
#V  PACKAGES_VERSIONS
##
##  Up to GAP 4.3,
##  these global variables were used instead of the record `GAPInfo'.
##
BindGlobal( "KERNEL_VERSION", GAPInfo.KernelVersion );
BindGlobal( "VERSION", GAPInfo.Version );
BindGlobal( "GAP_ARCHITECTURE", GAPInfo.Architecture );
BindGlobal( "GAP_ROOT_PATHS", GAPInfo.RootPaths );
BindGlobal( "USER_HOME", GAPInfo.UserHome );
# BindGlobal( "GAP_RC_FILE", GAPInfo.gaprc ); # not nec. bound
BindGlobal( "DO_AUTOLOAD_PACKAGES", not GAPInfo.CommandLineOptions.A );
BindGlobal( "DEBUG_LOADING", GAPInfo.CommandLineOptions.D );
BindGlobal( "CHECK_FOR_COMP_FILES", not GAPInfo.CommandLineOptions.N );
BindGlobal( "BANNER", not GAPInfo.CommandLineOptions.b );
BindGlobal( "QUIET", GAPInfo.CommandLineOptions.q );
BindGlobal( "LOADED_PACKAGES", GAPInfo.PackagesLoaded );
BindGlobal( "PACKAGES_VERSIONS", rec() );


#############################################################################
##
##
##  
##


#############################################################################
##
#F  ListSorted( <coll> )
#F  AsListSorted(<coll>)
##
##  These operations are obsolete and will vanish in future versions. They
##  are included solely for temporary compatibility with beta releases but
##  should *never* be used. Use `SSortedList' and `AsSSortedList' instead!
##
ListSorted := function(coll)
  Info(InfoWarning,1,"The command `ListSorted' will *not* be supported in",
        "further versions!");
  return SSortedList(coll);
end;

AsListSorted := function(coll)
  Info(InfoWarning,1,"The command `AsListSorted' will *not* be supported in",
        "further versions!");
  return AsSSortedList(coll);
end;


#############################################################################
##
#A  NormedVectors( <V> )
##
DeclareSynonymAttr( "NormedVectors", NormedRowVectors );


#############################################################################
##
#F  SameBlock( <tbl>, <p>, <omega1>, <omega2>, <relevant>, <exponents> )
##
##  Let <tbl> be an ordinary character table, <p> a prime integer, <omega1>
##  and <omega2> two central characters (or their values lists) of <tbl>.
##  The remaining arguments <relevant> and <exponents> are lists as stored in
##  the components `relevant' and `exponents' of a record returned by
##  `PrimeBlocks' (see~"PrimeBlocks").
##
##  `SameBlock' returns `true' if <omega1> and <omega2> are equal modulo any
##  maximal ideal in the ring of complex algebraic integers containing the
##  ideal spanned by <p>, and `false' otherwise.
##
##  The above syntax was supported and documented in GAP 4.3.
##  In GAP 4.4, the first and the last argument were omitted because they
##  turned out to be unnecessary.  (The record returned by `PrimeBlocks' does
##  no longer have a component `exponents'.)
##  From GAP 4.5 on, only the four argument version will be supported.
##


#############################################################################
##
#F  TryConwayPolynomialForFrobeniusCharacterValue( <p>, <n> )
##
##  This name is needed just for backwards compatibility with GAP 4.4.
##  It should be still available and regarded as obsolescent in GAP 4.5,
##  and should be removed in GAP 4.6.
##  Now one should better use `IsCheapConwayPolynomial' directly.
##
DeclareSynonym( "TryConwayPolynomialForFrobeniusCharacterValue",
    IsCheapConwayPolynomial );


#############################################################################
##
#O  FormattedString( <obj>, <nr> )  . . formatted string repres. of an object
##
##  This variable name was never documented and is obsolete.
##  (It had been introduced at a time when only unary methods were allowed
##  for attributes.)
##
BIND_GLOBAL( "FormattedString", String );


#############################################################################
##
#F  SubspacesAll
#F  SubspacesDim
##
##  for compatibility with GAP 4.1 only ...
##
DeclareSynonymAttr( "SubspacesAll", Subspaces);
DeclareSynonym( "SubspacesDim", Subspaces);


#############################################################################
##
##  In 2009, `IsTuple' was renamed to `IsDirectProductElement'.
##  The following names should be still available and regarded as obsolescent
##  in GAP 4.5, and should be removed in GAP 4.6.
##
#F  ComponentsOfTuplesFamily( ... )
#F  IsTuple( ... )
#F  IsTupleFamily( ... )
#F  IsTupleCollection( ... )
#F  Tuple( ... )
#F  TupleNC( ... )
#F  TuplesFamily( ... )
#I  InfoTuples
#R  IsDefaultTupleRep( ... )
#V  EmptyTuplesFamily( ... )
#V  TUPLES_FAMILIES
##
DeclareSynonym( "ComponentsOfTuplesFamily",
    ComponentsOfDirectProductElementsFamily );
DeclareSynonym( "IsTuple", IsDirectProductElement );
DeclareSynonym( "IsTupleFamily", IsDirectProductElementFamily );
DeclareSynonym( "IsTupleCollection", IsDirectProductElementCollection );
DeclareSynonym( "Tuple", DirectProductElement );
DeclareSynonym( "TupleNC", DirectProductElementNC );
DeclareSynonym( "TuplesFamily", DirectProductElementsFamily );
DeclareSynonym( "InfoTuples", InfoDirectProductElements );
DeclareSynonym( "IsDefaultTupleRep", IsDefaultDirectProductElementRep );
DeclareSynonym( "EmptyTuplesFamily", EmptyDirectProductElementsFamily );
DeclareSynonym( "TUPLES_FAMILIES", DIRECT_PRODUCT_ELEMENT_FAMILIES );

##  from GAPs "classical" random number generator:

# Outdated, but kept since they were documented for a long time.
#############################################################################
##
#F  StateRandom()
#F  RestoreStateRandom(<obj>)
##
##  <ManSection>
##  <Func Name="StateRandom" Arg=''/>
##  <Func Name="RestoreStateRandom" Arg='obj'/>
##
##  <Description>
##  [This interface to the global random generator is kept for compatibility 
##  with older versions of &GAP;. Use now <C>State(GlobalRandomSource)</C>
##  and <C>Reset(GlobalRandomSource, <A>obj</A>)</C> instead.]
##  <P/>
##  For debugging purposes, it can be desirable to reset the random number
##  generator to a state it had before. <Ref Func="StateRandom"/> returns a
##  &GAP; object that represents the current state of the random number
##  generator used by <Ref Func="RandomList"/>.
##  <P/>
##  By calling <Ref Func="RestoreStateRandom"/> with this object as argument,
##  the random number is reset to this same state.
##  <P/>
##  (The same result can be obtained by accessing the two global variables
##  <C>R_N</C> and <C>R_X</C>.)
##  <P/>
##  (The format of the object used to represent the random generator seed
##  is not guaranteed to be stable between different machines or versions
##  of &GAP;.)
##  <P/>
##  <Example><![CDATA[
##  gap> seed:=StateRandom();;
##  gap> List([1..10],i->Random(Integers));
##  [ -3, 2, 5, 1, 0, -2, 4, 3, 5, 3 ]
##  gap> List([1..10],i->Random(Integers));
##  [ 1, -2, 1, -1, -2, 4, -1, -3, -1, 1 ]
##  gap> RestoreStateRandom(seed);
##  gap> List([1..10],i->Random(Integers));
##  [ -3, 2, 5, 1, 0, -2, 4, 3, 5, 3 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##
############################################################################
##  Compatibility functions, these are documented for a long time.
##  (We also keep the global variables R_N and R_X within the 
##  'GlobalRandomSource' because they were documented.)
##  
BindGlobal( "StateRandom", function()
  return State(GlobalRandomSource);
end);

BindGlobal( "RestoreStateRandom", function(seed)
  Reset(GlobalRandomSource, seed);
end);

# older documentation referred to `StatusRandom'. 
DeclareSynonym("StatusRandom",StateRandom);

# synonym formerly declared in factgrp.gd
DeclareSynonym( "FactorCosetOperation",FactorCosetAction);

# synonyms formerly declared in grppc.gd
DeclareSynonym( "AffineOperation", AffineAction );
DeclareSynonym( "AffineOperationLayer",AffineActionLayer );

# synonyms for ComplementClasses retained for backwards compatibility with GAP 4.4
DeclareSynonym( "Complementclasses", ComplementClassesRepresentatives );
DeclareSynonym( "ComplementclassesEA", ComplementClassesRepresentativesEA );


#############################################################################
##
#O  ShrinkCoeffs( <list> )
##
##  <ManSection>
##  <Oper Name="ShrinkCoeffs" Arg='list'/>
##
##  <Description>
##  removes trailing zeroes from <A>list</A>.
##  It returns the position of the last non-zero entry,
##  that is the length of <A>list</A> after the operation.
##  <Example><![CDATA[
##  gap> l:=[1,0,0];;ShrinkCoeffs(l);l;
##  1
##  [ 1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##
DeclareOperation( "ShrinkCoeffs", [ IsMutable and IsList ] );


#############################################################################
##
#F  ExcludeFromAutoload( ... )
##
##  was supported until GAP 4.4, obsolescent in GAP 4.5.
##
BindGlobal( "ExcludeFromAutoload", function( arg )
    Info( InfoWarning, 1,
          "the function `ExcludeFromAutoload' is not supported anymore,\n",
          "#I  use the component `ExcludeFromAutoload' in `gap.ini'\n",
          "#I  instead" );
    end );


#############################################################################
##
#V  EDITOR
#V  HELP_VIEWER
#V  PAGER
#V  PAGER_OPTIONS
#V  XDVI_OPTIONS
#V  XPDF_OPTIONS
##
##  were supported until GAP 4.4, obsolescent in GAP 4.5.
##
EDITOR:= UserPreference("Editor");
HELP_VIEWER:= UserPreference("HelpViewers");
PAGER:= UserPreference("Pager");
PAGER_OPTIONS:= UserPreference("PagerOptions");
XDVI_OPTIONS:= UserPreference("XdviOptions");
XPDF_OPTIONS:= UserPreference("XpdfOptions");
POST_RESTORE_FUNCS:= GAPInfo.PostRestoreFuncs;


#############################################################################
##
#F  ProductPol( <coeffs_f>, <coeffs_g> )  . . . .  product of two polynomials
##
##  <ManSection>
##  <Func Name="ProductPol" Arg='coeffs_f, coeffs_g'/>
##
##  <Description>
##  Was supported until GAP 4.4, obsolescent in GAP 4.5.
##  <P/> 
##  Let <A>coeffs_f</A> and <A>coeffs_g</A> be coefficients lists of two univariate
##  polynomials <M>f</M> and <M>g</M>, respectively.
##  <C>ProductPol</C> returns the coefficients list of the product <M>f g</M>.
##  <P/>
##  The coefficient of <M>x^i</M> is assumed to be stored at position <M>i+1</M> in
##  the coefficients lists.
##  </Description>
##  <Example><![CDATA[
##  gap> ProductPol([1,2,3],[4,5,6]); -->
##  [ 4, 13, 28, 27, 18 ] -->
##  ]]></Example>
##  </ManSection>
##
DeclareGlobalFunction( "ProductPol" );


#############################################################################
##
#O  TeXObj( <obj> ) . . . . . . . . . . . . . . . . . . . . . . TeX an object
##
##  <ManSection>
##  <Oper Name="TeXObj" Arg='obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation( "TeXObj", [ IS_OBJECT ] );


#############################################################################
##
#O  LaTeXObj( <obj> ) . . . . . . . . . . . . . . . . . . . . LaTeX an object
##
##  <ManSection>
##  <Oper Name="LaTeXObj" Arg='obj'/>
##  
##  <Description>
##  The function <Ref Func="LaTeX"/> actually calls the operation
##  <Ref Func="LaTeXObj"/> for each argument.
##  By installing special methods for this operation, it is possible
##  to achieve special &LaTeX;'ing behavior for certain objects
##  (see Chapter&nbsp;<Ref Chap="Method Selection"/>).
##  </Description>
##  </ManSection>
##
DeclareOperation( "LaTeXObj", [ IS_OBJECT ] );


#############################################################################
##
#F  DisplayRevision() . . . . . . . . . . . . . . .  display revision entries
##
##  <ManSection>
##  <Func Name="DisplayRevision" Arg=''/>
##
##  <Description>
##  Displays the revision numbers of all loaded files from the library.
##  </Description>
##  </ManSection>
##
BIND_GLOBAL("DisplayRevision",function()
    local   names,  source,  library,  unknown,  name,  p,  s,  type,
            i,  j;

    names   := RecNames( Revision );
    source  := [];
    library := [];
    unknown := [];

    for name  in names  do
        p := Position( name, '_' );
        if p = fail  then
            Add( unknown, name );
        else
            s := name{[p+1..Length(name)]};
            if s = "c" or s = "h"  then
                Add( source, name );
            elif s = "g" or s = "gi" or s = "gd"  then
                Add( library, name );
            else
                Add( unknown, name );
            fi;
        fi;
    od;
    Sort( source );
    Sort( library );
    Sort( unknown );

    for type  in [ source, library, unknown ]  do
        if 0 < Length(type)  then
            if IsIdenticalObj(type,source)  then
                Print( "Source Files\n" );
            elif IsIdenticalObj(type,library)  then
                Print( "Library Files\n" );
            else
                Print( "Unknown Files\n" );
            fi;
            j := 1;
            for name  in type  do
                s := Revision.(name);
                p := Position( s, ',' )+3;
                i := p;
                while s[i] <> ' '  do i := i + 1;  od;
                s := Concatenation( String( Concatenation(
                         name, ":" ), -15 ), String( s{[p..i]},
                         -5 ) );
                if j = 3  then
                    Print( s, "\n" );
                    j := 1;
                else
                    Print( s, "    " );
                    j := j + 1;
                fi;
            od;
            if j <> 1  then Print( "\n" );  fi;
            Print( "\n" );
        fi;
    od;
end);


#############################################################################
##
#F  ARCH_IS_MAC()
##
##  <#GAPDoc Label="ARCH_IS_MAC">
##  <ManSection>
##  <Func Name="ARCH_IS_MAC" Arg=''/>
##
##  <Description>
##  tests whether &GAP; is running on a Macintosh under Mac OS 8, 9 or
##  under Mac OS X in the Classic Environment.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("MACINTOSH_68K_ARCHITECTURE",
  IMMUTABLE_COPY_OBJ("MC68020-motorola-macos-mwerksc"));

BIND_GLOBAL("MACINTOSH_PPC_ARCHITECTURE",
  IMMUTABLE_COPY_OBJ("PPC-motorola-macos-mwerksc"));

BIND_GLOBAL("ARCH_IS_MAC",function()
  return GAPInfo.Architecture = MACINTOSH_68K_ARCHITECTURE
      or GAPInfo.Architecture = MACINTOSH_PPC_ARCHITECTURE;
end);


#############################################################################
##
#F  ConnectGroupAndCharacterTable( <G>, <tbl>[, <info>] )
##
##  This function was supported up to GAP 4.4.12.
##  It is deprecated because it changes its arguments, which is a bad idea.
##  Note that after a successful call of `ConnectGroupAndCharacterTable',
##  one cannot use <tbl> in another call with another group <G>.
##
##  Moreover, if <tbl> is a character table from GAP's table library (which
##  is probably the most usual application) then the following may happen.
##  One fetches the table <tbl> with `CharacterTable',
##  then stores the group information with `ConnectGroupAndCharacterTable',
##  then performs some computations with this table and perhaps with other
##  tables,
##  and finally one fetches <tbl> again with `CharacterTable'; depending on
##  the intermediate computations, this table can be the old instance, with
##  the (unwanted) stored group information.
##
##  In GAP 4.5, one can use the function `CharacterTableWithStoredGroup'
##  instead of `ConnectGroupAndCharacterTable'.
##
DeclareGlobalFunction( "ConnectGroupAndCharacterTable" );


#############################################################################
##
#E

