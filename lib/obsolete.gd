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
##  (see <Ref Label="Command Line Options"/>) or set the user preference
##  <C>ReadObsolete</C> in the file <F>gap.ini</F> to <K>false</K>
##  (see <Ref Sect="sect:gap.ini"/>). Note that the <C>-O</C> command
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
##  In June 2009, `IsTuple' was renamed to `IsDirectProductElement'.
##  The following names should be still available and regarded as obsolescent
##  in GAP 4.5, and should be removed in GAP 4.6.
##
#F  IsTuple( ... ) - Not used in any redistributed package (11/2017)
#F  Tuple( ... ) - still used in smallantimagmas (06/2025)
##
#DeclareObsoleteSynonym( "IsTuple", "IsDirectProductElement" );
DeclareObsoleteSynonym( "Tuple", "DirectProductElement" );

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
##  Still used in recog (06/2025)
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
##  Not used in any redistributed package
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
##  Still used in anupq (06/2025)
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
##  Still used in anupq (06/2025)
DeclareGlobalFunction("UnhideGlobalVariables");


#############################################################################
##
##
##  Used in many packages, documented CamelCase versions introduced (04/2020)
DeclareObsoleteSynonym("GAP_EXIT_CODE", "GapExitCode", 2);
DeclareObsoleteSynonym("QUIT_GAP", "QuitGap", 2);
DeclareObsoleteSynonym("FORCE_QUIT_GAP", "ForceQuitGap", 2);


#############################################################################
##
##  We can't use DeclareObsoleteSynonym for FirstOp, because this would break
##  code installing methods for it, and the `fr` package does just that.
##
##  Still used in fr (06/2025)
DeclareSynonym( "FirstOp", First );


#############################################################################
##
#A  RadicalGroup( <G> )
##
##  'RadicalGroup' was renamed in GAP 4.12.
##
##  Still used in autpgrp, sophus (06/2025)
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
#F  SCRSiftOld( <S>, <g> )
##
##  Moved to obsoletes in August 2025.
##
##  The function was never documented.
##  It was a library code version of 'SCRSift', which is a kernel function
##  (see https://github.com/gap-system/gap/pull/525).
##  The functions 'SCRSiftOld' and 'SiftedPermutation' do essentially the
##  same, in particular they return the same results, thus 'SCRSiftOld' is
##  obsolete.
##
DeclareObsoleteSynonym( "SCRSiftOld", "SiftedPermutation" );


#############################################################################
##
#V  OVERRIDENICE
##
##  Moved to obsoletes in August 2025.
##
##  Use 'OverrideNice()' instead, in order to take the current value of
##  'RankFilter( IsHandledByNiceMonomorphism )' into account,
##  not the initial value of the filter.
##
BindGlobal( "OVERRIDENICE", Maximum( NICE_FLAGS,
               RankFilter( IsMatrixGroup and IsFinite ) ) );


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
