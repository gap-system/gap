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
##  For that, one can use the <C>-O</C> command line option 
##  (see <Ref Label="Command Line Options"/>) or set the component 
##  <C>ReadObsolete</C> in the file <F>gap.ini</F> to <K>false</K> 
##  (see <Ref Sect="sect:gap.ini"/>). Note that <C>-O</C> command 
##  line option overrides <C>ReadObsolete</C>.
##  <P/>
##  (Note that the condition whether the library files with the obsolete
##  &GAP; code shall be read has changed.
##  In &GAP;&nbsp;4.3 and 4.4, the global variables <C>GAP_OBSOLESCENT</C>
##  and <C>GAPInfo.ReadObsolete</C>
##  &ndash;to be set in the user's <F>.gaprc</F> file&ndash;
##  were used to control this behaviour.)
##  <#/GAPDoc>
##

BIND_GLOBAL( "DeclareObsoleteSynonym", function( name_obsolete, name_current, desc )
    local value, orig_value;
    if not ForAll( [ name_obsolete, name_current, desc ], IsString ) then
        Error("Each argument of DeclareObsoleteSynonym must be a string\n");
    fi;
    value := EvalString( name_current );
    if IsFunction( value ) then
        orig_value := value;
        value := function (arg)
            local res;
            Info( InfoObsolete, 1, "'", name_obsolete, "' is obsolete.",
                "\n#I  It may be removed in the future release of GAP ", desc,
                "\n#I  Use ", name_current, " instead.");
            # TODO: This will error out if orig_value is a function which returns nothing.
            #return CallFuncList(orig_value, arg);
            res := CALL_WITH_CATCH(orig_value, arg);
            if Length(res) = 2 then
                return res[2];
            fi; 
        end;
    fi;
    BIND_GLOBAL( name_obsolete, value );
end );

BIND_GLOBAL( "DeclareObsoleteSynonymAttr", function( name_obsolete, name_current, desc )
    Assert(0, IsFunction( ValueGlobal( name_current ) ) );
    DeclareObsoleteSynonym( name_obsolete, name_current, desc );
    DeclareObsoleteSynonym( Concatenation("Set", name_obsolete), Concatenation("Set", name_current), desc );
    DeclareObsoleteSynonym( Concatenation("Has", name_obsolete), Concatenation("Has", name_current), desc );
end );


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
##  Moved to obsoletes in May 2003.
##
##  not used in any redistributed package (01/2016)
DeclareGlobalFunction( "DiagonalizeIntMatNormDriven" );


#############################################################################
##
#F  DeclarePackage( <name>, <version>, <tester> )
#F  DeclareAutoPackage( <name>, <version>, <tester> )
#F  DeclarePackageDocumentation( <name>, <doc>[, <short>[, <long> ] ] )
#F  DeclarePackageAutoDocumentation( <name>, <doc>[, <short>[, <long> ] ] )
#F  ReadPkg( ... )
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
# 01/2016: still used in fplsa, itc, qaos
BindGlobal( "DeclareAutoPackage", Ignore );
# 01/2016: still used in automgrp, liealgdb
BindGlobal( "DeclarePackageAutoDocumentation", Ignore );
# 01/2016: still used in fplsa, itc
BindGlobal( "DeclarePackageDocumentation", Ignore );
# 01/2016: still used in qaos
BindGlobal( "ReadPkg", ReadPackage );
# 01/2016: still used in automgrp, ctbllib, fplsa, fwtree, grpconst, guava,
# Hap (HapCocyclic), itc, modisom, pargap, qaos, xgap
BindGlobal( "RequirePackage", LoadPackage );
# 01/2016: still used (sometimes in examples or documentation) in ace,
# autpgrp, edim, fwtree, hecke, itc, liepring, polycyclic, qaos, repsn,
# sglppow, singular, tomlib, toric, unipot, xgap


#############################################################################
##
#V  KERNEL_VERSION   - not used in any redistributed package (01/2016)
#V  VERSION          - not used in any redistributed package (01/2016)
#V  GAP_ARCHITECTURE - still used by gbnp, singular (01/2016)
#V  GAP_ROOT_PATHS   - still used by finings, forms, xgap (01/2016)
#V  DEBUG_LOADING    - still used by the GAP kernel itself (01/2016)
#V  BANNER           - still used by cubefree, loops, quagroup (01/2016)
#V  QUIET            - still used by cubefree, loops, quagroup (01/2016)
#V  LOADED_PACKAGES  - still used by GUAVA (01/2016)
##
##  Up to GAP 4.3,
##  these global variables were used instead of the record `GAPInfo'.
##
BindGlobal( "KERNEL_VERSION", GAPInfo.KernelVersion );
BindGlobal( "VERSION", GAPInfo.Version );
BindGlobal( "GAP_ARCHITECTURE", GAPInfo.Architecture );
BindGlobal( "GAP_ROOT_PATHS", GAPInfo.RootPaths );
BindGlobal( "DEBUG_LOADING", GAPInfo.CommandLineOptions.D );
BindGlobal( "BANNER", not GAPInfo.CommandLineOptions.b );
BindGlobal( "QUIET", GAPInfo.CommandLineOptions.q );
BindGlobal( "LOADED_PACKAGES", GAPInfo.PackagesLoaded );
BindGlobal( "PACKAGES_VERSIONS", rec() );


#############################################################################
##
#A  NormedVectors( <V> )
##
##  Moved to obsoletes in May 2003. 
##  Still used in autpgrp, ctbllib, matgrp, sophus. (01/2016)
##
DeclareObsoleteSynonymAttr( "NormedVectors", "NormedRowVectors", "4.8" );

#############################################################################
##
#F  SameBlock( <tbl>, <p>, <omega1>, <omega2>, <relevant>, <exponents> )
##
##  (the next three paragraphs were added in July 2003)
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
#O  FormattedString( <obj>, <nr> )  . . formatted string repres. of an object
##
##  This variable name was never documented and is obsolete.
##  (It had been introduced at a time when only unary methods were allowed
##  for attributes.)
## 
##  Moved to obsolete in Dec 2007, but as on Dec 2012 still used in ctbllib, 
##  gbnp, GradedModules, nilmat, rcwa and resclasses packages.
##
DeclareObsoleteSynonym( "FormattedString", "String", "4.8" );


#############################################################################
##
##  In June 2009, `IsTuple' was renamed to `IsDirectProductElement'.
##  The following names should be still available and regarded as obsolescent
##  in GAP 4.5, and should be removed in GAP 4.6.
##
#F  IsTuple( ... ) - not used in any redistributed package (01/2016)
#F  Tuple( ... ) - still used by cubefree, gpd, grpconst, openmath,
##                 sonata (01/2016)
##
DeclareObsoleteSynonym( "IsTuple", "IsDirectProductElement", "4.8" );
DeclareObsoleteSynonym( "Tuple", "DirectProductElement", "4.8" );

##  from GAPs "classical" random number generator:

# Outdated, but kept since they were documented for a long time.
# Moved to obsoletes in May 2010.
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
DeclareObsoleteSynonym( "StatusRandom", "StateRandom", "4.8" );

# synonym formerly declared in factgrp.gd
# Moved to obsoletes in October 2011, still used by xgap (01/2016)
DeclareObsoleteSynonym( "FactorCosetOperation", "FactorCosetAction", "4.8" );

# synonym retained for backwards compatibility with GAP 4.4.
# Moved to obsoletes in April 2012. Still used by grpconst, hap (01/2016)
DeclareObsoleteSynonym( "Complementclasses", "ComplementClassesRepresentatives", "4.8" );


#############################################################################
##
#O  ShrinkCoeffs( <list> )
##
##  Moved to obsoletes in June 2010
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
##  not used in any redistributed package (01/2016)
DeclareOperation( "ShrinkCoeffs", [ IsMutable and IsList ] );


#############################################################################
##
#F  ExcludeFromAutoload( ... )
##
##  was supported until GAP 4.4, obsolescent in GAP 4.5.
##
##  not used in any redistributed package (01/2016)
BindGlobal( "ExcludeFromAutoload", function( arg )
    Info( InfoWarning, 1,
          "the function `ExcludeFromAutoload' is not supported anymore,\n",
          "#I  use the component `ExcludeFromAutoload' in `gap.ini'\n",
          "#I  instead" );
    end );


#############################################################################
##
#V  POST_RESTORE_FUNCS - still used by grape (01/2016)
##
##  were supported until GAP 4.4, obsolescent in GAP 4.5.
##
POST_RESTORE_FUNCS:= GAPInfo.PostRestoreFuncs;


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
##  not used in any redistributed package (01/2016)
DeclareGlobalFunction( "ConnectGroupAndCharacterTable" );


#############################################################################
##
#F  MutableIdentityMat( <m> [, <F>] ) mutable identity matrix of a given size
##
##  <#GAPDoc Label="MutableIdentityMat">
##  <ManSection>
##  <Func Name="MutableIdentityMat" Arg='m [, F]'/>
##
##  <Description>
##  returns a (mutable) <A>m</A><M>\times</M><A>m</A> identity matrix over the field given
##  by <A>F</A>.
##  This is identical to <Ref Func="IdentityMat"/> and is present in &GAP;&nbsp;4.1
##  only for the sake of compatibility with beta-releases.
##  It should <E>not</E> be used in new code.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
## still used by autpgrp, float, modisom (01/2016)
DeclareObsoleteSynonym( "MutableIdentityMat", "IdentityMat", "4.8" );


#############################################################################
##
#F  MutableNullMat( <m>, <n>  [, <F>] ) mutable null matrix of a given size
##
##  <#GAPDoc Label="MutableNullMat">
##  <ManSection>
##  <Func Name="MutableNullMat" Arg='m, n [, F]'/>
##
##  <Description>
##  returns a (mutable) <A>m</A><M>\times</M><A>n</A> null matrix over the field given
##  by <A>F</A>.
##  This is identical to <Ref Func="NullMat"/> and is present in &GAP;&nbsp;4.1
##  only for the sake of compatibility with beta-releases.
##  It should <E>not</E> be used in new code.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
## still used by grpconst, guava, liepring, modisom, qpa, singular (01/2016)
DeclareObsoleteSynonym( "MutableNullMat", "NullMat", "4.8" );

#############################################################################
##
#F  IsSemilatticeAsSemigroup( <S> ) is the semigroup <S> a semilattice
##
##  <#GAPDoc Label="IsSemilatticeAsSemigroup">
##  <ManSection>
##  <Prop Name="IsSemilatticeAsSemigroup" Arg='S'/>
##
##  <Description>
##    <C>IsSemilatticeAsSemigroup</C> returns <K>true</K> if the semigroup
##    <A>S</A> is a semilattice and <K>false</K> if it is not. <P/>
##
##    A semigroup is a <E>semilattice</E> if it is commutative and every
##    element is an idempotent. The idempotents of an inverse semigroup form a
##    semilattice.
##
##    This is identical to <Ref Prop="IsSemilattice" BookName = "Semigroups"/> #
##    and is present in &GAP;&nbsp;4.8 #  only for the sake of compatibility with
##    beta-releases.  #  It should <E>not</E> be used in new code.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "IsSemilatticeAsSemigroup", IsSemilattice );

#############################################################################
##
#F  CreateCompletionFiles( [<path>] ) . . . . . . create "lib/readX.co" files
##
##  NO LONGER SUPPORTED IN GAP >= 4.5 
##
BindGlobal( "CreateCompletionFiles", function()
  Print("CreateCompletionFiles: Completion files are no longer supported by GAP.\n");
end);


#############################################################################
##
#O  PositionFirstComponent( <list>, <obj> )
##
## Removed due to being incompletely documented and its available methods
## behaving inconsistently. Use PositionSorted or Position instead.
##
## Deprecated in GAP >= 4.8
##
## still used by GAPDoc (01/2016)
DeclareOperation("PositionFirstComponent",[IsList,IsObject]);

#############################################################################
##
#O  ReadTest 
##
##  `ReadTest' is superseded by more robust and flexible `Test'. Since the
##  former is still used in some packages, for backwards compatibility we
##  replace it by the call of `Test' with comparison up to whitespaces.
##
BindGlobal( "ReadTest", function( fn )
  Print("#I  ReadTest is no longer supported. Please use more robust and flexible\n",
        "#I  Test. For backwards compatibility, ReadTest(<filename>) is replaced\n",
        "#I  by Test( <filename>, rec( compareFunction := \"uptowhitespace\" ))\n");
  Test( fn, rec( compareFunction := "uptowhitespace" ));
end);

#############################################################################
##
#F  USER_HOME_EXPAND
##
##  This got a nicer name before is became documented.
##
## still used by Browse, ctbllib, profiling, resclasses (01/2016)
DeclareGlobalFunction( "USER_HOME_EXPAND" );

#############################################################################
##
#F  RecFields
##
##  This name stems from GAP 3 days.
##
## still used by Browse, ctbllib, gapdoc, genss, io, orb (05/2017)
DeclareObsoleteSynonym( "RecFields", "RecNames", "4.0" );

#############################################################################
##
#E

