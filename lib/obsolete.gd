#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
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
##  Information about obsolete names is printed by <Ref Func="Info"/> using the
##  <Ref InfoClass="InfoObsolete"/> Info class.
##  By default <Ref InfoClass="InfoObsolete"/> is set to 1. Newly
##  obsoleted identifiers should at first be outputted at info level 2. Once they
##  have been removed from all packages, they should then be moved to info level
##  1, so they are visible to normal users, for at least one major release before
##  being removed.
##  <P/>
##  The functions <C>DeclareObsoleteSynonym</C> and
##  <C>DeclareObsoleteSynonymAttr</C> take
##  an optional final parameter, specifying the info level at which the given
##  obsolete symbol should be reported. It defaults to 2 and 1, respectively.
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
##  Not used in any redistributed package (01/2016)
#DeclareGlobalFunction( "DiagonalizeIntMatNormDriven" );


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

#BindGlobal( "DeclarePackage", Ignore );
# 09/2018: Not used in any redistributed package

#BindGlobal( "DeclareAutoPackage", Ignore );
# 06/2018: Not used in any redistributed package

#BindGlobal( "DeclarePackageAutoDocumentation", Ignore );
# 09/2018: Not used in any redistributed package

#BindGlobal( "DeclarePackageDocumentation", Ignore );
# 03/2018: Not used in any redistributed package

DeclareObsoleteSynonym( "ReadPkg", "ReadPackage" );
# 11/2018: still used in Hap (HapCocyclic)
# safely used in GAP3 compatibility code: ctbllib, quagroup (09/2018)

#DeclareObsoleteSynonym( "RequirePackage", "LoadPackage" );
# 09/2018: not used in "general" code in any redistributed package
# used in documentation or for generating it: edim, repsn (11/2018)
# safely used in GAP3 compatibility code: ctbllib (09/2018)


#############################################################################
##
#V  KERNEL_VERSION   - Not used in any redistributed package (11/2017)
#V  VERSION          - Not used in any redistributed package (11/2018)
#V  GAP_ARCHITECTURE - Not used in any redistributed package (10/2023)
#V  GAP_ROOT_PATHS   - Not used in any redistributed package (03/2018)
#V  DEBUG_LOADING    - Not used in any redistributed package (04/2019)
#V  BANNER           - Not used in any redistributed package (04/2019)
#V  QUIET            - Not used in any redistributed package (04/2019)
#V  LOADED_PACKAGES  - Not used in any redistributed package (11/2017)
##
##  Up to GAP 4.3,
##  these global variables were used instead of the record `GAPInfo'.
##
#BindGlobal( "KERNEL_VERSION", GAPInfo.KernelVersion );
#BindGlobal( "VERSION", GAPInfo.Version );
#BindGlobal( "GAP_ARCHITECTURE", GAPInfo.Architecture );
#BindGlobal( "GAP_ROOT_PATHS", GAPInfo.RootPaths );
#BindGlobal( "DEBUG_LOADING", GAPInfo.CommandLineOptions.D );
#BindGlobal( "BANNER", not GAPInfo.CommandLineOptions.b );
#BindGlobal( "QUIET", GAPInfo.CommandLineOptions.q );
#BindGlobal( "LOADED_PACKAGES", GAPInfo.PackagesLoaded );

#############################################################################
##
#V  PACKAGES_VERSIONS - Not used in any redistributed package (11/2017)
#V  Revision          - Not used in any redistributed package (10/2023)
#BindGlobal( "PACKAGES_VERSIONS", rec() );
#BindGlobal( "Revision", rec() );

#############################################################################
##
#V  TRANSDEGREES
##
##  This variable was used by the GAP Transitive Groups Library before it
##  became a separate TransGrp package. It denoted the maximal degree of
##  transitive permutation groups provided by that library.
##
##  In the TransGrp package, this information is provided by the boolean
##  list TRANSAVAILABLE, which indicates availability for each possible
##  degree (this is necessary because the data for some degrees may have
##  to be downloaded separately).
##
##  At the time of writing this comment, the TransGrp package contained
##  representatives for all transitive permutation groups of degree at
##  most 47, with degree 32 needing to be downloaded separately.
##
##  Not used in any redistributed package (07/2022)
#BindGlobal( "TRANSDEGREES", 30 );

#############################################################################
##
#A  NormedVectors( <V> )
##
##  Moved to obsoletes in May 2003.
##
##  Not used in any redistributed package (07/2022)
#DeclareObsoleteSynonymAttr( "NormedVectors", "NormedRowVectors" );

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
#F  CharValueWreathSymmetric( <tbl>, <n>, <beta>, <pi> )  . .
#F                                        . . . .  character value in G wr Sn
##
##  This function was never documented but had been available for decades.
##  Its functionality became documented under the more suitable name
##  'CharacterValueWreathSymmetric' in GAP 4.10.
##
##  Not used in any redistributed package (11/2018)
#DeclareObsoleteSynonym( "CharValueWreathSymmetric",
#    "CharacterValueWreathSymmetric" );


#############################################################################
##
#O  FormattedString( <obj>, <nr> )  . . formatted string repres. of an object
##
##  This variable name was never documented and is obsolete.
##  (It had been introduced at a time when only unary methods were allowed
##  for attributes.)
##
##  Moved to obsolete in Dec 2007.
##  Not used in any redistributed package (07/2022)
#DeclareObsoleteSynonym( "FormattedString", "String" );


#############################################################################
##
##  In June 2009, `IsTuple' was renamed to `IsDirectProductElement'.
##  The following names should be still available and regarded as obsolescent
##  in GAP 4.5, and should be removed in GAP 4.6.
##
#F  IsTuple( ... ) - Not used in any redistributed package (11/2017)
#F  Tuple( ... ) - still used in numericalsgps (11/2018)
##
#DeclareObsoleteSynonym( "IsTuple", "IsDirectProductElement" );
DeclareObsoleteSynonym( "Tuple", "DirectProductElement" );


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
# BindGlobal( "StateRandom", function()
#   return State(GlobalRandomSource);
# end);
#
# BindGlobal( "RestoreStateRandom", function(seed)
#   Reset(GlobalRandomSource, seed);
# end);

# older documentation referred to `StatusRandom'.
#DeclareObsoleteSynonym( "StatusRandom", "StateRandom" );

# synonym formerly declared in factgrp.gd.
# Moved to obsoletes in October 2011
# Not used in any redistributed package (11/2017)
#DeclareObsoleteSynonym( "FactorCosetOperation", "FactorCosetAction" );

# synonym retained for backwards compatibility with GAP 4.4.
# Moved to obsoletes in April 2012.
##  Not used in any redistributed package (07/2022)
#DeclareObsoleteSynonym( "Complementclasses", "ComplementClassesRepresentatives" );


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
##  Not used in any redistributed package (11/2017)
#DeclareOperation( "ShrinkCoeffs", [ IsMutable and IsList ] );


#############################################################################
##
#F  ExcludeFromAutoload( ... )
##
##  was supported until GAP 4.4, obsolescent in GAP 4.5.
##
##  Not used in any redistributed package (01/2016)
# BindGlobal( "ExcludeFromAutoload", function( arg )
#     Info( InfoWarning, 1,
#           "the function `ExcludeFromAutoload' is not supported anymore,\n",
#           "#I  use the component `ExcludeFromAutoload' in `gap.ini'\n",
#           "#I  instead" );
#     end );


#############################################################################
##
#V  POST_RESTORE_FUNCS
##
##  were supported until GAP 4.4, obsolescent in GAP 4.5.
##
##  Not used in any redistributed package (11/2018)
#POST_RESTORE_FUNCS:= GAPInfo.PostRestoreFuncs;


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
##  Not used in any redistributed package (11/2018)
#DeclareOperation( "TeXObj", [ IS_OBJECT ] );


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
##  Not used in any redistributed package (11/2018)
#DeclareOperation( "LaTeXObj", [ IS_OBJECT ] );


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
##  Not used in any redistributed package (01/2016)
#DeclareGlobalFunction( "ConnectGroupAndCharacterTable" );


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
##  Not used in any redistributed package (11/2018)
#DeclareObsoleteSynonym( "MutableIdentityMat", "IdentityMat" );


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
##  Not used in any redistributed package (11/2018)
#DeclareObsoleteSynonym( "MutableNullMat", "NullMat" );


#############################################################################
##
#F  IsSemilatticeAsSemigroup( <S> ) is the semigroup <S> a semilattice
##
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
##
##  Not used in any redistributed packages (11/2017)
#DeclareSynonymAttr( "IsSemilatticeAsSemigroup", IsSemilattice );

#############################################################################
##
#F  CreateCompletionFiles( [<path>] ) . . . . . . create "lib/readX.co" files
##
##  NO LONGER SUPPORTED IN GAP >= 4.5
##
# BindGlobal( "CreateCompletionFiles", function()
#   Print("CreateCompletionFiles: Completion files are no longer supported by GAP.\n");
# end);


#############################################################################
##
#O  MultRowVector( <list1>, <poss1>, <list2>, <poss2>, <mul> )
##
##  <#GAPDoc Label="MultRowVector_Obsolete">
##  <ManSection>
##  <Oper Name="MultRowVector" Arg='list1, [poss1, list2, poss2, ]mul'/>
##  <Returns>nothing</Returns>
##
##  <Description>
##  The two argument version of this operation is an obsolete synonym for
##  <C>MultVectorLeft</C>, which calculates <A>mul</A>*<A>list1</A> in-place.
##  New code should use <C>MultVectorLeft</C> or its synonym
##  <C>MultVector</C> instead.
##  <P/>
##  <E>The five argument version of this operation is kept for compatibility
##  with older versions of &GAP; and will be removed eventually.</E>
##  It replaces
##  <A>list1</A><C>[</C><A>poss1</A><C>[</C><M>i</M><C>]]</C> by
##  <C><A>mul</A>*<A>list2</A>[<A>poss2</A>[</C><M>i</M><C>]]</C> for <M>i</M>
##  between <M>1</M> and <C>Length( <A>poss1</A> )</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  Still used in fining, orb, recog (08/2022)
DeclareObsoleteSynonym( "MultRowVector", "MultVector" );

#############################################################################
##
#O  ReadTest
##
##  `ReadTest' is superseded by more robust and flexible `Test'. Since the
##  former is still used in some packages, for backwards compatibility we
##  replace it by the call of `Test' with comparison up to whitespaces.
##
##  Not used in any redistributed package (07/2022)
##  Safely used in compatibility code: gapdoc (09/2018)
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
##  Not used in any redistributed package (07/2022)
##  Safely used in compatibility code: digraphs, profiling, semigroups (09/2018)
DeclareObsoleteSynonym( "USER_HOME_EXPAND", "UserHomeExpand" );

#############################################################################
##
#F  RecFields
##
##  This name stems from GAP 3 days.
##
##  Not used in any redistributed package (07/2022)
##  Safely used in GAP3 compatibility code: ctbllib (11/2018)
#DeclareObsoleteSynonym( "RecFields", "RecNames" );

#############################################################################
##
#F  SHALLOW_SIZE
##
##  'SHALLOW_SIZE' is an alias for the kernel function 'SIZE_OBJ'. Note that
##  in the past, SIZE_OBJ was buggy for immediate inputs (i.e. small integers
##  or finite field elements), hence packages using either of these
##  UNDOCUMENTED kernel functions may wish to keep using SHALLOW_SIZE until
##  they can adjust their minimal GAP version requirements.
##
##  Not used in any redistributed package (11/2018)
#DeclareObsoleteSynonym( "SHALLOW_SIZE", "SIZE_OBJ" );


#############################################################################
##
#V  InfoRead?
##
##  InfoRead used to be used to print when a file is read using `Read()`
##
##  Not used in any redistributed package (07/2022)
#if GAPInfo.CommandLineOptions.D then InfoRead1 := Print; fi;
#if not IsBound(InfoRead1) then InfoRead1 := Ignore; fi;
#if not IsBound(InfoRead2) then InfoRead2 := Ignore; fi;

#############################################################################
##
#F  TemporaryGlobalVarName( [<prefix>] )   name of an unbound global variable
##
##  <ManSection>
##  <Func Name="TemporaryGlobalVarName" Arg='[prefix]'/>
##
##  <Description>
##  TemporaryGlobalVarName ( [<A>prefix</A>] ) returns a string that can be used
##  as the name of a global variable that is not bound at the time when
##  TemporaryGlobalVarName() is called.  The optional argument prefix can
##  specify a string with which the name of the global variable starts.
##  </Description>
##  </ManSection>
##
##  Still used in SCSCP (07/2022)
DeclareGlobalFunction("TemporaryGlobalVarName");


#############################################################################
##
#F  HideGlobalVariables(<str1>[,<str2>,...]))
##
##  <ManSection>
##  <Func Name="HideGlobalVariables" Arg='str1[,str2,...]'/>
##
##  <Description>
##  temporarily makes global variables <Q>undefined</Q>. The arguments to
##  <C>HideGlobalVariables</C> are strings. If there is a global variable defined
##  whose identifier is equal to one of the strings it will be <Q>hidden</Q>.
##  This means that identifier and value will be safely stored on a stack
##  and the variable will be undefined afterwards. A call to
##  <C>UnhideGlobalVariables</C> will restore the old values.
##  The main purpose of hiding variables will be for the temporary creation
##  of global variables for reading in data created by other programs.
##  </Description>
##  </ManSection>
##
##  This function was never documented.
##
##  Still used in anupq (07/2022)
DeclareGlobalFunction("HideGlobalVariables");


#############################################################################
##
#F  UnhideGlobalVariables(<str1>[,<str2>,...])
#F  UnhideGlobalVariables()
##
##  <ManSection>
##  <Func Name="UnhideGlobalVariables" Arg='str1[,str2,...]'/>
##  <Func Name="UnhideGlobalVariables" Arg=''/>
##
##  <Description>
##  The second version unhides all variables that are still hidden.
##  </Description>
##  </ManSection>
##
##  This function was never documented.
##
##  Still used in anupq (07/2022)
DeclareGlobalFunction("UnhideGlobalVariables");


#############################################################################
##
##
##  Not used in any redistributed package (07/2022)
# BindGlobal("STRING_LIST_DIR", function(dirname)
#     local list;
#
#     list:= LIST_DIR( dirname );
#     if list = fail then
#       return fail;
#     else
#       return JoinStringsWithSeparator( list, "\000" );
#     fi;
# end);


#############################################################################
##
##
##  Used in many packages, documented CamelCase versions introduced (04/2020)
DeclareObsoleteSynonym("GAP_EXIT_CODE", "GapExitCode", 2);
DeclareObsoleteSynonym("QUIT_GAP", "QuitGap", 2);
DeclareObsoleteSynonym("FORCE_QUIT_GAP", "ForceQuitGap", 2);


#############################################################################
##
#F  IsLexicographicallyLess( <list1>, <list2> )
##
##  <#GAPDoc Label="IsLexicographicallyLess">
##  <ManSection>
##  <Func Name="IsLexicographicallyLess" Arg='list1, list2'/>
##
##  <Description>
##  Let <A>list1</A> and <A>list2</A> be two dense, but not necessarily
##  homogeneous lists
##  (see&nbsp;<Ref Filt="IsDenseList"/>, <Ref Filt="IsHomogeneousList"/>),
##  such that for each <M>i</M>, the entries in both lists at position
##  <M>i</M> can be compared via <C>&lt;</C>.
##  <Ref Func="IsLexicographicallyLess"/> returns <K>true</K> if <A>list1</A>
##  is smaller than <A>list2</A> w.r.t.&nbsp;lexicographical ordering,
##  and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  Not used in any redistributed package (05/2021)
#DeclareObsoleteSynonym( "IsLexicographicallyLess", "<" );


#############################################################################
##
##  We can't use DeclareObsoleteSynonym for FirstOp, because this would break
##  code installing methods for it, and the `fr` package does just that.
##
##  Still used in fr (06/2021)
DeclareSynonym( "FirstOp", First );


#############################################################################
##
#A  RadicalGroup( <G> )
##
##  'RadicalGroup' was renamed in GAP 4.12.
##
##  Still used in autpgrp, crisp, sophus (07/2022)
DeclareObsoleteSynonym( "RadicalGroup", "SolvableRadical" );


#############################################################################
##
#O  MutableCopyMat( <mat> )
##
##  Moved to obsoletes in February 2023.
##
##  Still used in corelg, crisp, cryst, cubefree, cvec, fining, forms, genss,
##  guava, hap, hapcryst, lpres, matricesforhomalg, modisom, polycyclic,
##  recog, semigroups, smallsemi, sophus (02/2023)
##
##  (We cannot use 'DeclareObsoleteSynonym' because the cvec package wants to
##  install a method for 'MutableCopyMat', thus 'MutableCopyMat' must be an
##  operation.)
##
DeclareSynonym( "MutableCopyMat", MutableCopyMatrix );


#############################################################################
##
##  Not used in any redistributed package
DeclareObsoleteSynonym( "ZeroSM", "ZeroSameMutability" );
DeclareObsoleteSynonym( "AdditiveInverseSM", "AdditiveInverseSameMutability" );
DeclareObsoleteSynonym( "OneSM", "OneSameMutability" );
DeclareObsoleteSynonym( "InverseSM", "InverseSameMutability" );

DeclareObsoleteSynonymAttr( "ZeroAttr", "ZeroImmutable" );
DeclareObsoleteSynonymAttr( "AdditiveInverseAttr", "AdditiveInverseImmutable" );
DeclareObsoleteSynonymAttr( "OneAttr", "OneImmutable" );
DeclareObsoleteSynonymAttr( "InverseAttr", "InverseImmutable" );

DeclareObsoleteSynonymAttr( "TransposedMatAttr", "TransposedMatImmutable" );
