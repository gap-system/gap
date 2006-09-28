#############################################################################
##
#W   random.gd                     GAP library                    Frank Lübeck
#W                                                              Max Neunhöffer
##
#H  @(#)$Id$
##
#Y  Copyright (C) 2006 The GAP Group
##
##  This file declares variables for random sources.
##
Revision.random_gd :=
    "@(#)$Id$";


#############################################################################
##  
#C  IsRandomSource( <rs> ) 
##  
##  This is the category of random source objects <rs> which are defined to
##  have methods available for the following operations which are explained 
##  in more detail below: `Random( <rs>, <list> )' giving a random element 
##  of a list, `Random( <rs>, <low>, <high> )' giving a random integer between
##  <low> and <high> (inclusive), `Init', `State' and `Reset'.
##  
##  Use `RandomSource' (see "RandomSource") to construct new random sources.
##  
##  One idea behind providing several independent (pseudo) random sources is
##  to make algorithms which use some sort of random choices deterministic.
##  They can use their own new random source created with a fixed seed and 
##  so do exactly the same in different calls.
##  
##  Random source objects lie in the family `RandomSourcesFamily'.
##  
BindGlobal( "RandomSourcesFamily", NewFamily( "RandomSourcesFamily" ) );    
DeclareCategory( "IsRandomSource", IsComponentObjectRep );

#############################################################################
##  
#O  Random( <rs>, <list> ) . . . . . . . . . . for random source and a list
#O  Random( <rs>, <low>, <high> )  . . . for random source and two integers
##  
##  This operation returns a random element from list <list>, or an integer 
##  in the range from the given (possibly large) integers <low> to <high>,
##  respectively. 
##  The choice should only depend on the random source <rs> and have no 
##  effect on other random sources.
##  
DeclareOperation( "Random", [IsRandomSource, IsList] );
DeclareOperation( "Random", [IsRandomSource, IsInt, IsInt] );

#############################################################################
##  
#O  State( <rs> ) . . . . . . . . . . . . . . . state of random source
#O  Reset( <rs> )
#O  Reset( <rs>, <seed> ) . . . . . . . . . . . reset a random source
#O  Init( <rs> )
#O  Init( <prers>, <seed> )  . . . . . . . initialize a random source
##  
##  These are the basic operations for which random sources (see
##  "IsRandomSource") must have methods. 
##  
##  `State' should return a data structure which allows to recover the state
##  of the random source such that a sequence of random calls using this 
##  random source can be reproduced. If a random source cannot be reset 
##  (say, it uses truely random physical data) then `State' should return 
##  `fail'.
##  
##  `Reset( <rs>, <seed> )' resets the random source <rs> to a state described
##  by <seed>, if the random source can be reset (otherwise it should do
##  nothing). Here <seed> can be an output of `State' and then should reset
##  to that state. Also, the methods should always allow integers as <seed>.
##  Without the <seed> argument the default $<seed> = 1$ is used.
##  
##  `Init' is the constructor of a random source, it gets an empty component 
##  object which has already the correct type and should fill in the actual 
##  data which are needed. Optionally, it should allow one to specify a 
##  <seed> for the initial state, as explained for `Reset'.
##  
DeclareOperation( "State", [IsRandomSource] );
DeclareOperation( "Reset", [IsRandomSource] );
DeclareOperation( "Reset", [IsRandomSource, IsObject] );
DeclareOperation( "Init", [IsRandomSource] );
DeclareOperation( "Init", [IsRandomSource, IsObject] );

#############################################################################
##  
#C  IsGlobalRandomSource( <rs> )
#C  IsGAPRandomSource( <rs> )
#C  IsMersenneTwister( <rs> )
#V  GlobalRandomSource
#V  GlobalMersenneTwister
##  
##  Currently, the {\GAP} library provides three types of random sources,
##  distinguished by the three listed categories.
##  
##  `IsGlobalRandomSource' gives access to the *classical* global 
##  random generator which was used by {\GAP} in previous releases. 
##  You do not need to construct new random sources of this kind which would
##  all use the same global data structure. Just use the existing random
##  source `GlobalRandomSource'. This uses the additive random number 
##  generator described in  \cite{TACP2} (Algorithm A in~3.2.2 with lag $30$).
##  
##  `IsGAPRandomSource' uses the same number generator as 
##  `IsGlobalRandomSource', but you can create several of these random sources 
##  which generate their random numbers independently of all other random
##  sources. 
##  
##  `IsMersenneTwister' are random sources which use a fast random generator of
##  32 bit numbers, called the Mersenne twister. The pseudo random sequence has 
##  a period of $2^{19937}-1$ and the numbers have a $623$-dimensional 
##  equidistribution. For more details and the origin of the code used in the
##  {\GAP} kernel, see:
##  
##  `http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/emt.html'
##  
##  Use the Mersenne twister if possible, in particular for generating many 
##  large random integers. 
##  
##  There is also a predefined global random source `GlobalMersenneTwister'.
##  
DeclareCategory("IsGlobalRandomSource", IsRandomSource);
DeclareCategory("IsGAPRandomSource", IsRandomSource);
DeclareCategory("IsMersenneTwister", IsRandomSource);

DeclareGlobalVariable( "GlobalRandomSource" );
DeclareGlobalVariable( "GlobalMersenneTwister" );

#############################################################################
##  
#O  RandomSource( <cat> )
#O  RandomSource( <cat>, <seed> )
##  
##  This operation is used to create new random sources. The first argument is 
##  the category describing the type of the random generator, an optional
##  <seed> which can be an integer or a type specific data structure can be
##  given to specify the initial state.
##  
##  \beginexample
##  gap> rs1 := RandomSource(IsMersenneTwister);
##  <RandomSource in IsMersenneTwister>
##  gap> state1 := State(rs1);;
##  gap> l1 := List([1..10000], i-> Random(rs1, [1..6]));;  
##  gap> rs2 := RandomSource(IsMersenneTwister);;
##  gap> l2 := List([1..10000], i-> Random(rs2, [1..6]));;
##  gap> l1 = l2;
##  true
##  gap> l1 = List([1..10000], i-> Random(rs1, [1..6])); 
##  false
##  gap> n := Random(rs1, 1, 2^220);
##  1598617776705343302477918831699169150767442847525442557699717518961
##  \endexample
##  
DeclareOperation( "RandomSource", [IsOperation] );
DeclareOperation( "RandomSource", [IsOperation, IsObject] );


# Outdated, but kept since they were documented for a long time.
#############################################################################
##
#F  StateRandom()
#F  RestoreStateRandom(<obj>)
##
##  [This interface to the global random generator is kept for compatibility 
##  with older versions of {\GAP}. Use now `State(GlobalRandomSource)'
##  and `Reset(GlobalRandomSource, <obj>)' instead.]
##  
##  For debugging purposes, it can be desirable to reset the random number
##  generator to a state it had before. `StateRandom' returns a {\GAP}
##  object that represents the current state of the random number generator
##  used by `RandomList'.
##
##  By calling `RestoreStateRandom' with this object as argument, the
##  random number is reset to this same state.
##
##  (The same result can be obtained by accessing the two global variables
##  `R_N' and `R_X'.)
##
##  (The format of the object used to represent the random generator seed
##  is not guaranteed to be stable between different machines or versions
##  of {\GAP}.
##
DeclareGlobalFunction( "StateRandom" );
DeclareGlobalFunction( "RestoreStateRandom" );

# older documentation referred to `StatusRandom'. 
DeclareSynonym("StatusRandom",StateRandom);

#############################################################################
##  
