#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Lübeck, Max Neunhöffer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file declares variables for random sources.
##


#############################################################################
##
#C  IsRandomSource( <rs> )
##
##  <#GAPDoc Label="IsRandomSource">
##  <ManSection>
##  <Filt Name="IsRandomSource" Arg='obj' Type='Category'/>
##
##  <Description>
##  This is the category of random source objects.
##  The <E>user interface</E> for these objects consists of the following
##  functions.
##  <P/>
##  <Ref Oper="RandomSource"/> creates a new random source <A>rs</A>, say.
##  <P/>
##  <C>Random( <A>rs</A>, <A>list</A> )</C> yields a random element of the
##  list <A>list</A>, and
##  <C>Random( <A>rs</A>, <A>low</A>, <A>high</A> )</C> yields a random
##  integer between <A>low</A> and <A>high</A> (inclusive),
##  see <Ref Oper="Random" Label="for random source and list"/>.
##  <P/>
##  If <A>rs</A> supports resetting (see <Ref Oper="State"/>) then
##  <C>State( <A>rs</A> )</C> yields a copy <A>state</A>, say,
##  of the current state of <A>rs</A> such that
##  <C>Reset( <A>rs</A>, <A>state</A> )</C> resets <A>rs</A> to the given
##  state.
##  <P/>
##  One idea behind providing several independent (pseudo) random sources is
##  to make algorithms which use some sort of random choices deterministic.
##  They can use their own new random source created with a fixed seed and
##  so do exactly the same in different calls.
##  <P/>
##  Random source objects lie in the family <C>RandomSourcesFamily</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "RandomSourcesFamily", NewFamily( "RandomSourcesFamily" ) );
DeclareCategory( "IsRandomSource", IsComponentObjectRep );


#############################################################################
##
#O  Random( <rs>, <list> ) . . . for random source and a dense, nonempty list
#O  Random( <rs>, <low>, <high> )  . . . . for random source and two integers
##
##  <#GAPDoc Label="Random">
##  <ManSection>
##  <Oper Name="Random" Arg='rs, list' Label="for random source and list"/>
##  <Oper Name="Random" Arg='rs, coll'
##   Label="for random source and collection"/>
##  <Oper Name="Random" Arg='rs, low, high'
##                      Label="for random source and two integers"/>
##
##  <Description>
##  This operation returns a random element from the dense, nonempty list
##  <A>list</A> or the nonempty collection <A>coll</A>,
##  or an integer in the range from the given (possibly large) integers
##  <A>low</A> to <A>high</A>, respectively.
##  <P/>
##  The choice should only depend on the random source <A>rs</A> and have no
##  effect on other random sources.
##  <P/>
##  It is not defined what happens if <A>list</A> or <A>coll</A> is empty,
##  <A>list</A> is not dense, or <A>low</A> is larger than <A>high</A>.
##  <Example>
##  gap> mysource := RandomSource(IsMersenneTwister, 42);;
##  gap> Random(mysource, 1, 10^60);
##  999331861769949319194941485000557997842686717712198687315183
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
# We keep the declaration for non-dense lists
# in order not to break existing code.
DeclareOperation( "Random", [IsRandomSource, IsListOrCollection] );
DeclareOperation( "Random", [IsRandomSource, IsInt, IsInt] );


#############################################################################
##
#O  State( <rs> )  . . . . . . . . . . . . . . . . . . state of random source
#O  Reset( <rs>[, <seed>] )  . . . . . . . . . . . . .  reset a random source
##
##  <#GAPDoc Label="State">
##  <ManSection Label="State and Reset for Random Sources">
##  <Heading>State and Reset for Random Sources</Heading>
##  <Oper Name="State" Arg='rs'/>
##  <Oper Name="Reset" Arg='rs[, seed]'/>
##
##  <Description>
##  These are the basic operations for random sources (see
##  <Ref Filt="IsRandomSource"/>).
##  <P/>
##  <Ref Oper="State"/> returns a data structure which admits recovering
##  the state of the random source such that a sequence of random calls
##  using this random source can be reproduced.
##  If a random source cannot be reset (say, it uses truly random physical
##  data) then <Ref Oper="State"/> returns <K>fail</K>.
##  <P/>
##  <C>Reset( <A>rs</A>, <A>seed</A> )</C> resets the random source <A>rs</A>
##  to a state described by <A>seed</A>, if the random source can be reset;
##  otherwise it does nothing.
##  Here <A>seed</A> can be an output of <Ref Oper="State"/> and then
##  <A>rs</A> gets reset to that state.
##  For historical reasons, random sources accept integer values as
##  <A>seed</A>.
##  We recommend that new code should not rely on this; always use the output
##  of a prior call to <Ref Oper="State"/> as <A>seed</A>, or omit it.
##  Without the <A>seed</A> argument a fixed default seed is used.
##  <Ref Oper="Reset"/> returns the state of <A>rs</A> before the call.
##  <P/>
##  Most methods for <Ref Oper="Random" Label="for a list or collection"/>
##  in the &GAP; library that do not take a random source as argument use the
##  <Ref Var="GlobalMersenneTwister"/> as random source. It can be reset
##  into a known state as in the following example.
##  <Example><![CDATA[
##  gap> seed := Reset(GlobalMersenneTwister);;
##  gap> seed = State(GlobalMersenneTwister);
##  true
##  gap> List([1..10],i->Random(Integers));
##  [ -3, 2, -1, -2, -1, -1, 1, -4, 1, 0 ]
##  gap> List([1..10],i->Random(Integers));
##  [ -1, -1, -1, 1, -1, 1, -2, -1, -2, 0 ]
##  gap> Reset(GlobalMersenneTwister, seed);;
##  gap> List([1..10],i->Random(Integers));
##  [ -3, 2, -1, -2, -1, -1, 1, -4, 1, 0 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "State", [IsRandomSource] );
DeclareOperation( "Reset", [IsRandomSource] );
DeclareOperation( "Reset", [IsRandomSource, IsObject] );
DeclareOperation( "Init", [IsRandomSource, IsObject] );

#############################################################################
##
#C  IsMersenneTwister( <rs> )
#C  IsGlobalRandomSource( <rs> )
#C  IsGAPRandomSource( <rs> )
#V  GlobalRandomSource
#V  GlobalMersenneTwister
##
##  <#GAPDoc Label="IsGlobalRandomSource">
##  <ManSection Label="Kinds of Random Sources">
##  <Heading>Kinds of Random Sources</Heading>
##  <Filt Name="IsMersenneTwister" Arg='rs' Type='Category'/>
##  <Filt Name="IsGAPRandomSource" Arg='rs' Type='Category'/>
##  <Filt Name="IsGlobalRandomSource" Arg='rs' Type='Category'/>
##  <Var Name="GlobalMersenneTwister"/>
##  <Var Name="GlobalRandomSource"/>
##
##  <Description>
##  Currently, the &GAP; library provides three types of random sources,
##  distinguished by the three listed categories.
##  <P/>
##  <Ref  Filt="IsMersenneTwister"/>  are random  sources  which  use a  fast
##  random generator  of 32  bit numbers, called  the Mersenne  twister. The
##  pseudo  random  sequence has  a  period  of <M>2^{19937}-1</M>  and  the
##  numbers have a <M>623</M>-dimensional equidistribution. For more details
##  and the origin of the code used in the &GAP; kernel, see:
##  <URL>http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/emt.html</URL>.
##  <P/>
##  Use the Mersenne twister if possible, in particular for generating many
##  large random integers.
##  <P/>
##  There is also a predefined global random source
##  <Ref Var="GlobalMersenneTwister"/> which is used as the default
##  random source by those library
##  methods for <Ref Oper="Random" Label="for a list or collection"/>
##  that do not take a random source as an argument.
##  <P/>
##  <Ref Filt="IsGAPRandomSource"/> uses the same number generator as
##  <Ref Filt="IsGlobalRandomSource"/>, but you can create several of these
##  random sources which generate their random numbers independently of
##  all other random sources.
##  <P/>
##  <Ref Filt="IsGlobalRandomSource"/> gives access to the <E>classical</E>
##  global random generator which was used by &GAP; in former releases.
##  You do not need to construct new random sources of this kind which would
##  all use the same global data structure. Just use the existing random
##  source <Ref Var="GlobalRandomSource"/>. This uses the additive random number
##  generator described in  <Cite Key="TACP2"/> (Algorithm A in&nbsp;3.2.2
##  with lag <M>30</M>).
##  <P/>
##  Other kinds of random sources are implemented by &GAP; packages.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory("IsGlobalRandomSource", IsRandomSource);
DeclareCategory("IsGAPRandomSource", IsRandomSource);
DeclareCategory("IsMersenneTwister", IsRandomSource);

if IsHPCGAP then
    MakeThreadLocal( "GlobalRandomSource" );
    MakeThreadLocal( "GlobalMersenneTwister" );
else
    DeclareGlobalName( "GlobalRandomSource" );
    DeclareGlobalName( "GlobalMersenneTwister" );
fi;

#############################################################################
##
#O  RandomSource( <cat>[, <seed>] )
##
##  <#GAPDoc Label="RandomSource">
##  <ManSection>
##  <Oper Name="RandomSource" Arg='cat[, seed]'/>
##
##  <Description>
##  This operation is used to create new random sources. The first argument
##  <A>cat</A> is the category describing the type of the random generator,
##  for example one of the categories listed in
##  Section <Ref Subsect="Kinds of Random Sources"/>.
##  <P/>
##  An optional <A>seed</A> can be given to specify the initial state.
##  For details,
##  see Section <Ref Subsect="State and Reset for Random Sources"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> rs1 := RandomSource(IsMersenneTwister);
##  <RandomSource in IsMersenneTwister>
##  gap> l1 := List([1..10000], i-> Random(rs1, [1..6]));;
##  gap> state1 := State(rs1);;
##  gap> rs2 := RandomSource(IsMersenneTwister);;
##  gap> l2 := List([1..10000], i-> Random(rs2, [1..6]));;
##  gap> l1 = l2;
##  true
##  gap> l3 := List([1..10000], i-> Random(rs1, [1..6]));;
##  gap> l1 = l3;
##  false
##  gap> rs3 := RandomSource(IsMersenneTwister, state1);;
##  gap> l4 := List([1..10000], i-> Random(rs3, [1..6]));;
##  gap> l3 = l4;
##  true
##  gap> n := Random(rs1, 1, 2^220);
##  1077726777923092117987668044202944212469136000816111066409337432400
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "RandomSource", [IsOperation] );
DeclareOperation( "RandomSource", [IsOperation, IsObject] );


##############################################################################
##
##  <#GAPDoc Label="RandomSource_develop">
##  <Subsection Label="Implementing new kinds of random sources">
##  <Heading>Implementing new kinds of random sources</Heading>
##
##  If one wants to implement a new kind of random sources then
##  the first step is the declaration of a new category <C>C</C>, say,
##  that implies <Ref Filt="IsRandomSource"/>, analogous to the categories
##  listed in Section <Ref Subsect="Kinds of Random Sources"/>,
##  as follows.
##  <P/>
##  <C>DeclareCategory( "C", IsRandomSource );</C>.
##  <P/>
##  Then the following method installations are needed.
##  <P/>
##  <Index Key="Init"><C>Init</C> (initialize a random source object)</Index>
##  <C>InstallMethod( Init, [ C, IsObject ], function( prers, seed )
##  ... end );</C>
##  <P/>
##  Here <C>prers</C> is an empty component object (which has already the
##  filter <C>C</C>), and <C>seed</C> is an integer or a state value
##  as returned by <Ref Oper="State"/> that describes the initial state of
##  the random source.
##  The function should fill in the actual data and then return the
##  (now initialized) object <C>prers</C>.
##  The default used for <C>seed</C> is the integer <C>1</C>.
##  A given state value need not be copied by the function.
##  <P/>
##  <C>InstallMethod( Random, [ C, IsInt, IsInt ], function( rs, low, high )
##  ... end );</C>
##  <P/>
##  Here <C>rs</C> is an already initialized random source object in the
##  category <C>C</C>, and the function returns an integer between <C>low</C>
##  and <C>high</C> (inclusive).
##  It is not defined what happens when <C>low</C> is larger than <C>high</C>.
##  <P/>
##  <C>InstallMethod( State, [ C ], function( rs ) ... end );</C>
##  <P/>
##  If <C>rs</C> supports resetting then the function must return an object
##  that describes the current state of <C>rs</C>.
##  This object must be an independent copy, that is,
##  calling <Ref Oper="Random" Label="for random source and list"/>
##  for <C>rs</C> must not change the object that was returned by
##  <Ref Oper="State"/>;
##  otherwise <Ref Func="ReturnFail"/> should be installed.
##  <P/>
##  <C>InstallMethod( Reset, [ C, IsObject ], function( rs, seed )
##  ... end );</C>
##  <P/>
##  If <C>rs</C> supports resetting then the function must reinitialize
##  <C>rs</C> to the integer or <Ref Oper="State"/> value <C>seed</C>
##  and must return the <Ref Oper="State"/> value of <C>rs</C> before these
##  changes; if resetting is not supported then <Ref Func="ReturnNothing"/>
##  should be installed.
##  Reset need not copy a given state.
##  Note that the generic unary <Ref Oper="Reset"/> method uses the default
##  seed <C>1</C>.
##  <P/>
##  Examples of implementations as described here are given by the
##  random sources with defining filter <Ref Filt="IsMersenneTwister"/>
##  or <C>IsRealRandomSource</C>.
##  (For the latter, see <Ref Meth="RandomSource" BookName="io"/>
##  in the &GAP; package <Package>IO</Package>.)
##  </Subsection>
##  <#/GAPDoc>

##############################################################################
##
##  <#GAPDoc Label="InstallMethodWithRandomSource">
##  <ManSection>
##  <Func Name="InstallMethodWithRandomSource"
##   Arg="opr,info[,famp],args-filts[,val],method"/>
##  <Func Name="InstallOtherMethodWithRandomSource"
##   Arg="opr,info[,famp],args-filts[,val],method"/>
##
##  <Description>
##  These functions are designed to simplify adding new methods for
##  <Ref Oper="Random" Label="for a list or collection"/>,
##  <Ref Oper="PseudoRandom"/>,
##  and <Ref Oper="Randomize" Label="for a vector object"/> to &GAP;
##  which can be called both with, and without, a random source.
##  <P/>
##  They accept the same arguments as <Ref Func="InstallMethod"/> and
##  <Ref Func="InstallOtherMethod"/>, with
##  the extra requirement that the first member of <A>args-filts</A> must
##  be <Ref Filt="IsRandomSource"/>, and the <A>info</A> argument
##  is compulsory and must begin 'for a random source and'.
##  <P/>
##  This function then installs two methods: first it calls
##  <Ref Func="InstallMethod"/> (or <Ref Func="InstallOtherMethod"/>)
##  with unchanged arguments.
##  Then it calls <Ref Func="InstallMethod"/>
##  (or <Ref Func="InstallOtherMethod"/>) a second time to install
##  another method which lacks the initial random source argument; this
##  additional method simply invokes the original method, with
##  <Ref Var="GlobalMersenneTwister"/> added as first argument.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("InstallMethodWithRandomSource");
DeclareGlobalFunction("InstallOtherMethodWithRandomSource");
