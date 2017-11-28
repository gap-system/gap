#############################################################################
##
#W   random.gd                     GAP library                    Frank Lübeck
#W                                                              Max Neunhöffer
##
##
#Y  Copyright (C) 2006 The GAP Group
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
##  This is the category of random source objects which are defined to have,
##  for  an  object  <A>rs</A>  in  this  category,  methods  available  for
##  the  following operations  which  are explained  in  more detail  below:
##  <C>Random( <A>rs</A>,  <A>list</A> )</C>  giving a  random element  of a
##  list,  <C>Random(  <A>rs</A>,  <A>low</A>, <A>high</A>  )</C>  giving  a
##  random  integer between  <A>low</A>  and  <A>high</A> (inclusive),  <Ref
##  Oper="Init"/>, <Ref Oper="State"/> and <Ref Oper="Reset"/>.
##  <P/>
##  Use <Ref Func="RandomSource"/> to construct new random sources.
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
BindGlobal( "RandomSourcesFamily", NewFamily( "RandomSourcesFamily" ) );    
DeclareCategory( "IsRandomSource", IsComponentObjectRep );

#############################################################################
##  
#O  Random( <rs>, <list> ) . . . . . . . . . . for random source and a list
#O  Random( <rs>, <low>, <high> )  . . . for random source and two integers
##
##  <#GAPDoc Label="Random">
##  <ManSection>
##  <Oper Name="Random" Arg='rs, list' Label="for random source and list"/>
##  <Oper Name="Random" Arg='rs, low, high' 
##                      Label="for random source and two integers"/>
##
##  <Description>
##  This operation returns a random element from list <A>list</A>, or an integer 
##  in the range from the given (possibly large) integers <A>low</A> to <A>high</A>,
##  respectively. 
##  <P/>
##  The choice should only depend on the random source <A>rs</A> and have no 
##  effect on other random sources.
##  <Example>
##  gap> mysource := RandomSource(IsMersenneTwister, 42);;
##  gap> Random(mysource, 1, 10^60);
##  999331861769949319194941485000557997842686717712198687315183
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Random", [IsRandomSource, IsListOrCollection] );
DeclareOperation( "Random", [IsRandomSource, IsInt, IsInt] );

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
##  <Ref Oper="Random" Label="for a list or collection"/> and
##  <Ref Oper="PseudoRandom"/> to GAP which can
##  be called both with, and without, a random source.
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
(function()
    local func;
    func := function(installType)
        return function(args...)
            local str, filterpos, filtercopy, argscopy, i, func, info;

            # Check we understand arguments
            # Second value must be an info string
            if not IsString(args[2]) then
                ErrorNoReturn("Second argument must be an info string");
            fi;

            # Info strings always tend to begin 'for ', and here we want
            # to be able to edit it, so we check.
            if args[2]{[1..23]} <> "for a random source and" then
                ErrorNoReturn("Info string must begin 'for a random source and'");
            fi;

            # Filters must start with 'IsRandomSource'
            for i in [1..Length(args)] do
                if IsList(args[i]) and args[i][1] = IsRandomSource then
                    filterpos := i;
                fi;
            od;

            if not IsBound(filterpos) then
                ErrorNoReturn("Must use a list of filters beginning 'IsRandomSource'");
            fi;

            # Last argument must be the actual method
            if not IsFunction(args[Length(args)]) then
                ErrorNoReturn("Argument list must end with the method");
            fi;

            # Install 
            CallFuncList(installType, args);

            # Install random, wrapping random source argument
            argscopy := List(args);

            # Remove 'IsRandomSource' from the filter list
            argscopy[filterpos] := argscopy[filterpos]{[2..Length(argscopy[filterpos])]};

            # Correct info string by removing 'a random source and'
            info := "for";
            APPEND_LIST(info, argscopy[2]{[24..Length(argscopy[2])]});
            argscopy[2] := info;

            func := argscopy[Length(argscopy)];
            if Length(argscopy[filterpos]) = 1 then
                argscopy[Length(argscopy)] := x -> func(GlobalMersenneTwister,x);
            elif Length(argscopy[filterpos]) = 2 then
                argscopy[Length(argscopy)] :=
                    function(x,y)
                        return func(GlobalMersenneTwister,x,y);
                    end;
            else
                Error("Only 2 or 3 argument methods supported");
            fi;

            CallFuncList(installType, argscopy);
        end;
    end;
    BIND_GLOBAL("InstallMethodWithRandomSource", func(InstallMethod));
    BIND_GLOBAL("InstallOtherMethodWithRandomSource", func(InstallOtherMethod));
end)();

#############################################################################
##  
#O  State( <rs> ) . . . . . . . . . . . . . . . state of random source
#O  Reset( <rs> )
#O  Reset( <rs>, <seed> ) . . . . . . . . . . . reset a random source
#O  Init( <rs> )
#O  Init( <prers>, <seed> )  . . . . . . . initialize a random source
##
##  <#GAPDoc Label="State">
##  <ManSection>
##  <Oper Name="State" Arg='rs'/>
##  <Oper Name="Reset" Arg='rs[, seed]'/>
##  <Oper Name="Init" Arg='prers[, seed]'/>
##
##  <Description>
##  These are the basic operations for which random sources (see
##  <Ref Func="IsRandomSource"/>) must have methods. 
##  <P/>
##  <Ref Oper="State"/> should return a data structure which allows to recover the state
##  of the random source such that a sequence of random calls using this 
##  random source can be reproduced. If a random source cannot be reset 
##  (say, it uses truly random physical data) then <Ref Oper="State"/>
##  should return  <K>fail</K>.
##  <P/>
##  <C>Reset( <A>rs</A>, <A>seed</A> )</C> resets the random source <A>rs</A> to a state described
##  by <A>seed</A>, if the random source can be reset (otherwise it should do
##  nothing). Here <A>seed</A> can be an output of <Ref Oper="State"/> and then should reset
##  to that state. Also, the methods should always allow integers as <A>seed</A>.
##  Without the <A>seed</A> argument the default <M><A>seed</A> = 1</M> is used.
##  <P/>
##  <Ref Oper="Init"/> is the constructor of a random source, it gets an empty component 
##  object <A>prers</A> which has already the correct type and should fill in the actual 
##  data which are needed. Optionally, it should allow one to specify a 
##  <A>seed</A> for the initial state, as explained for <Ref Oper="Reset"/>.
##  <P/>
##  Most methods for <Ref Oper="Random" Label="for a list or collection"/> 
##  in the &GAP; library use the 
##  <Ref Var="GlobalMersenneTwister"/> as random source. It can be reset 
##  into a known state as in the following example.
##  <Example><![CDATA[
##  gap> seed := State(GlobalMersenneTwister);;
##  gap> List([1..10],i->Random(Integers));
##  [ 2, -1, -2, -1, -1, 1, -4, 1, 0, -1 ]
##  gap> List([1..10],i->Random(Integers));
##  [ -1, -1, 1, -1, 1, -2, -1, -2, 0, -1 ]
##  gap> Reset(GlobalMersenneTwister, seed);;
##  gap> List([1..10],i->Random(Integers));
##  [ 2, -1, -2, -1, -1, 1, -4, 1, 0, -1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "State", [IsRandomSource] );
DeclareOperation( "Reset", [IsRandomSource] );
DeclareOperation( "Reset", [IsRandomSource, IsObject] );
DeclareOperation( "Init", [IsRandomSource] );
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
##  <ManSection>
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
##  <Ref  Var="IsMersenneTwister"/>  are random  sources  which  use a  fast
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
##  <Ref Var="GlobalMersenneTwister"/> which is used by most of the library
##  methods for <Ref Oper="Random" Label="for a list or collection"/>.
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
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory("IsGlobalRandomSource", IsRandomSource);
DeclareCategory("IsGAPRandomSource", IsRandomSource);
DeclareCategory("IsMersenneTwister", IsRandomSource);

if IsHPCGAP then
    MakeThreadLocal( "GlobalRandomSource" );
    # this declaration is in coll.gi because it is needed for RandomList
    # MakeThreadLocal( "GlobalMersenneTwister" );
else
    DeclareGlobalVariable( "GlobalRandomSource" );
    # this declaration is in coll.gi because it is needed for RandomList
    # DeclareGlobalVariable( "GlobalMersenneTwister" );
fi;

#############################################################################
##  
#O  RandomSource( <cat> )
#O  RandomSource( <cat>, <seed> )
##
##  <#GAPDoc Label="RandomSource">
##  <ManSection>
##  <Oper Name="RandomSource" Arg='cat[, seed]'/>
##
##  <Description>
##  This operation is used to create new random sources. The first argument 
##  <A>cat</A> is the category describing the type of the random generator, 
##  an optional <A>seed</A> which can be an integer or a type specific data 
##  structure can be given to specify the initial state.
##  <P/>
##  <Example><![CDATA[
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
##  1077726777923092117987668044202944212469136000816111066409337432400
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "RandomSource", [IsOperation] );
DeclareOperation( "RandomSource", [IsOperation, IsObject] );

#############################################################################
##
#E
