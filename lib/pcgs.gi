#############################################################################
##
#W  pcgs.gi                     GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the methods for polycylic generating systems.
##
Revision.pcgs_gi :=
    "@(#)$Id$";

#############################################################################
##
#M  Pcgs( <A> ) . . . . . . . .  from independent generators of abelian group
##
InstallGlobalFunction( PcgsByIndependentGeneratorsOfAbelianGroup, function( A )
    local   pcgs,  pcs,  rel,  gen,  f;
    
    pcs := [  ];
    rel := [  ];
    for gen  in IndependentGeneratorsOfAbelianGroup( A )  do
        for f  in FactorsInt( Order( gen ) )  do
            Add( pcs, gen );
            Add( rel, f );
            gen := gen ^ f;
        od;
    od;
    pcgs := PcgsByPcSequenceNC( FamilyObj( One( A ) ), pcs );
    SetOneOfPcgs( pcgs, One( A ) );
    SetRelativeOrders( pcgs, rel );
    SetIsPrimeOrdersPcgs( pcgs, true );
    return pcgs;
end );

InstallMethod( Pcgs, "from independent generators of abelian group", true,
    [ IsGroup and IsAbelian and HasIndependentGeneratorsOfAbelianGroup ], 0,
function(A)
  if HasHomePcgs(A) then
    TryNextMethod();
  else
    return PcgsByIndependentGeneratorsOfAbelianGroup(A);
  fi;
end);

#############################################################################
##
#M  SetPcgs( <G>, fail )  . . . . . . . . . . . . . . . . .  never set `fail'
##
##  `HasPcgs' implies  `CanEasilyComputePcgs',  which implies `IsSolvable',
##  so a  pcgs cannot be set for insoluble permutation groups.
##  As Pcgs may return 'fail' for insolvable permutation groups, this method
##  is necessary.
##
InstallMethod( SetPcgs, true, [ IsGroup, IsBool ], SUM_FLAGS,
    function( G, fail )
    SetIsSolvableGroup( G, false );
end );


#############################################################################
##

#M  IsBound[ <pos> ]
##
InstallMethod( IsBound\[\],
    "pcgs",
    true,
    [ IsPcgs,
      IsPosInt ],
    0,

function( pcgs, pos )
    return pos <= Length(pcgs);
end );


#############################################################################
##
#M  Length( <pcgs> )
##
InstallMethod( Length,
    "pcgs",
    true,
    [ IsPcgs and IsPcgsDefaultRep ],
    0,
    pcgs -> Length(pcgs!.pcSequence) );


#############################################################################
##
#M  Position( <pcgs>, <elm>, <from> )
##
InstallMethod( Position,
    "pcgs, object, int",
    true,
    [ IsPcgs and IsPcgsDefaultRep,
      IsObject,
      IsInt ],
    0,

function( pcgs, obj, from )
    return Position( pcgs!.pcSequence, obj, from );
end );


#############################################################################
##
#M  PrintObj( <pcgs> )
##
InstallMethod( PrintObj,
    "pcgs",
    true,
    [ IsPcgs and IsPcgsDefaultRep ],
    0,

function(pcgs)
    Print( "Pcgs(", pcgs!.pcSequence, ")" );
end );


#############################################################################
##
#M  <pcgs> [ <pos> ]
##
InstallMethod( \[\],
    "pcgs, pos int",
    true,
    [ IsPcgs and IsPcgsDefaultRep,
      IsPosInt ],
    0,

function( pcgs, pos )
    return pcgs!.pcSequence[pos];
end );


#############################################################################
##
#M  PcgsByPcSequenceCons( <req-filter>, <imp-filter>, <fam>, <pcs> )
##
InstallMethod( PcgsByPcSequenceCons,
    "generic constructor",
    true,
    [ IsPcgsDefaultRep,
      IsObject,
      IsFamily,
      IsList ],
    0,

function( filter, imp, efam, pcs )
    local   pcgs,  fam;

    # if the <efam> has a family pcgs check if the are equal
    if HasDefiningPcgs(efam) and DefiningPcgs(efam) = pcs  then
        imp := imp and IsFamilyPcgs;
    fi;
    if 0 = Length(pcs)  then
        imp := imp and IsEmpty;
    fi;

    # construct a pcgs object
    pcgs := rec();
    pcgs.pcSequence := Immutable(pcs);

    # get the pcgs family
    fam := CollectionsFamily(efam);

    # convert record into component object
    Objectify( NewType( fam, filter and imp ), pcgs );

    # set a one
    if HasOne(efam)  then
        SetOneOfPcgs( pcgs, One(efam) );
    elif 0 < Length(pcs)  then
        SetOneOfPcgs( pcgs, One(pcs[1]) );
    fi;

    # and return
    return pcgs;

end );


#############################################################################
##

#M  IsPrimeOrdersPcgs( <pcgs> )
##
InstallMethod( IsPrimeOrdersPcgs,
    true,
    [ IsPcgs ],
    0,

function( pcgs )
    return ForAll( RelativeOrders(pcgs), x -> IsPrimeInt(x) );
end );



#############################################################################
##
#M  IsFiniteOrdersPcgs( <pcgs> )
##
InstallMethod( IsFiniteOrdersPcgs,
    true,
    [ IsPcgs ],
    0,

function( pcgs )
    return ForAll( RelativeOrders(pcgs), x -> x <> 0 and x <> infinity );
end );


#############################################################################
##
#M  DepthOfPcElement( <pcgs>, <elm> )
##
InstallMethod( DepthOfPcElement,
    "generic methods, ExponentsOfPcElement",
    IsCollsElms,
    [ IsPcgs,
      IsObject ],
    0,

function( pcgs, elm )
    return PositionNot( ExponentsOfPcElement( pcgs, elm ), 0 );
end );


#############################################################################
##
#M  DepthOfPcElement( <pcgs>, <elm>, <min> )
##
InstallOtherMethod( DepthOfPcElement,
    "pcgs modulo pcgs, ignoring <min>",
    function(a,b,c) return IsCollsElms(a,b); end,
    [ IsPcgs,
      IsObject,
      IsInt ],
    0,

function( pcgs, elm, min )
    local   dep;

    dep := DepthOfPcElement( pcgs, elm );
    if dep < min  then
        Error( "minimal depth <min> is incorrect" );
    fi;
    return dep;
end );


#############################################################################
##
#M  DifferenceOfPcElement( <pcgs>, <left>, <right> )
##
InstallMethod( DifferenceOfPcElement,
    "generic methods, PcElementByExponents/ExponentsOfPcElement",
    IsCollsElmsElms,
    [ IsPcgs,
      IsObject,
      IsObject ],
    0,

function( pcgs, left, right )
    return PcElementByExponents( pcgs,
        ExponentsOfPcElement(pcgs,left)-ExponentsOfPcElement(pcgs,right) );
end );


#############################################################################
##
#M  ExponentOfPcElement( <pcgs>, <elm>, <pos> )
##
InstallMethod( ExponentOfPcElement,
    "generic method, ExponentsOfPcElement",
    function(F1,F2,F3) return IsCollsElms(F1,F2); end,
    [ IsPcgs,
      IsObject,
      IsPosInt ],
    0,

function( pcgs, elm, pos )
    return ExponentsOfPcElement(pcgs,elm)[pos];
end );


#############################################################################
##
#M  ExponentsOfPcElement( <pcgs>, <elm>, <poss> )
##
InstallOtherMethod( ExponentsOfPcElement,
    "with positions, falling back to ExponentsOfPcElement",
    function(F1,F2,F3) return IsCollsElms(F1,F2); end,
    [ IsPcgs,
      IsObject,
      IsList ],
    0,

function( pcgs, elm, pos )
    return ExponentsOfPcElement(pcgs,elm){pos};
end );


#############################################################################
##
#M  HeadPcElementByNumber( <pcgs>, <elm>, <num> )
##
InstallMethod( HeadPcElementByNumber,
    "using 'ExponentsOfPcElement', 'PcElementByExponents'",
    true,
    [ IsPcgs,
      IsObject,
      IsInt ],
    0,

function( pcgs, elm, pos )
    local   exp,  i;

    exp := ShallowCopy(ExponentsOfPcElement( pcgs, elm ));
    if pos < 1  then pos := 1;  fi;
    for i  in [ pos .. Length(exp) ]  do
        exp[i] := 0;
    od;
    return PcElementByExponents( pcgs, exp );
end );

#############################################################################
##
#M  ParentPcgs( <pcgs> )
##
InstallOtherMethod( ParentPcgs, true, [ IsPcgs ], 0, IdFunc );

#############################################################################
##
#M  LeadingExponentOfPcElement( <pcgs>, <elm> )
##
InstallMethod( LeadingExponentOfPcElement,
    "generic methods, ExponentsOfPcElement",
    IsCollsElms,
    [ IsPcgs,
      IsObject ],
    0,

function( pcgs, elm )
    local   exp,  dep;

    exp := ExponentsOfPcElement( pcgs, elm );
    dep := PositionNot( exp, 0 );
    if Length(exp) < dep  then
        return fail;
    else
        return exp[dep];
    fi;
end );



#############################################################################
##
#M  PcElementByExponents( <pcgs>, <empty-list> )
##
InstallMethod( PcElementByExponents,
    "generic method for empty lists",
    true,
    [ IsPcgs,
      IsList and IsEmpty ],
    0,

function( pcgs, list )
    if Length(list) <> Length(pcgs)  then
        Error( "<list> and <pcgs> have different lengths" );
    fi;
    return OneOfPcgs(pcgs);
end );


#############################################################################
##
#M  PcElementByExponents( <pcgs>, <list> )
##
InstallMethod( PcElementByExponents,
    "generic method",
    true,
    [ IsPcgs,
      IsRowVector and IsCyclotomicCollection ],
    0,

function( pcgs, list )
    local   elm,  i;

    elm := OneOfPcgs(pcgs);
    if Length(list) <> Length(pcgs)  then
        Error( "<list> and <pcgs> have different lengths" );
    fi;

    for i  in [ 1 .. Length(list) ]  do
        if list[i] <> 0  then
            elm := elm * pcgs[i] ^ list[i];
        fi;
    od;

    return elm;

end );


#############################################################################
##
#M  PcElementByExponents( <pcgs>, <ffe-list> )
##
InstallMethod( PcElementByExponents,
    "generic method",
    true,
    [ IsPcgs,
      IsRowVector and IsFFECollection ],
    0,

function( pcgs, list )
    local   elm,  i;

    elm := OneOfPcgs(pcgs);
    if Length(list) <> Length(pcgs)  then
        Error( "<list> and <pcgs> have different lengths" );
    fi;

    for i  in [ 1 .. Length(list) ]  do
        if list[i] <> 0  then
            elm := elm * pcgs[i] ^ IntFFE(list[i]);
        fi;
    od;

    return elm;

end );


#############################################################################
##
#M  PcElementByExponents( <pcgs>, <basis>, <empty-list> )
##
InstallOtherMethod( PcElementByExponents,
    "generic method for empty lists",
    true,
    [ IsPcgs,
      IsList and IsEmpty,
      IsList and IsEmpty ],
    0,

function( pcgs, basis, list )
    return OneOfPcgs(pcgs);
end );


#############################################################################
##
#M  PcElementByExponents( <pcgs>, <basis>, <list> )
##
InstallOtherMethod( PcElementByExponents,
    "generic method",
    true,
    [ IsPcgs,
      IsList,
      IsRowVector and IsCyclotomicCollection ],
    0,

function( pcgs, basis, list )
    local   elm,  i;

    elm := OneOfPcgs(pcgs);
    if Length(list) <> Length(basis)  then
        Error( "<list> and <basis> have different lengths" );
    fi;

    for i  in [ 1 .. Length(list) ]  do
        if list[i] <> 0  then
            elm := elm * basis[i] ^ list[i];
        fi;
    od;

    return elm;

end );


#############################################################################
##
#M  PcElementByExponents( <pcgs>, <basis>, <list> )
##
InstallOtherMethod( PcElementByExponents,
    "generic method",
    true,
    [ IsPcgs,
      IsList,
      IsRowVector and IsFFECollection ],
    0,

function( pcgs, basis, list )
    local   elm,  i,  z;

    elm := OneOfPcgs(pcgs);
    if Length(list) <> Length(basis)  then
        Error( "<list> and <basis> have different lengths" );
    fi;

    for i  in [ 1 .. Length(list) ]  do
        z := IntFFE(list[i]);
        if z <> 0  then
            elm := elm * basis[i] ^ z;
        fi;
    od;

    return elm;

end );


#############################################################################
##
#M  ReducedPcElement( <pcgs>, <left>, <right> )
##
InstallMethod( ReducedPcElement,
    "generic method",
    IsCollsElmsElms,
    [ IsPcgs and IsPrimeOrdersPcgs,
      IsObject,
      IsObject ],
    0,

function( pcgs, left, right )
    local   d,  ll,  lr,  ord;

    d := DepthOfPcElement( pcgs, left );
    if d <> DepthOfPcElement( pcgs, right )  then
        Error( "pc elms <left> and <right> have different depth" );
    fi;
    ll  := LeadingExponentOfPcElement( pcgs, left );
    lr  := LeadingExponentOfPcElement( pcgs, right );
    ord := RelativeOrderOfPcElement( pcgs, left );
    return LeftQuotient( right^(ll/lr mod ord), left );
end );


#############################################################################
##
#M  RelativeOrderOfPcElement( <pcgs>, <elm> )
##
InstallMethod( RelativeOrderOfPcElement,
    "generic method using RelativeOrders",
    IsCollsElms,
    [ IsPcgs and IsPrimeOrdersPcgs,
      IsObject ],
    0,

function( pcgs, elm )
    local   d;

    d := DepthOfPcElement(pcgs,elm);
    if d > Length(pcgs)  then
        return 1;
    else
        return RelativeOrders(pcgs)[d];
    fi;
end );


#############################################################################
##
#M  SetRelativeOrders( <prime-orders-pcgs>, <orders> )
##
SET_RELATIVE_ORDERS := SETTER_FUNCTION(
    "RelativeOrders", HasRelativeOrders );


InstallMethod( SetRelativeOrders,
    "setting orders for prime orders pcgs",
    true,
    [ IsPcgs and IsComponentObjectRep and IsAttributeStoringRep and
        HasIsPrimeOrdersPcgs and HasIsFiniteOrdersPcgs,
      IsList ],
    SUM_FLAGS+2,
    SET_RELATIVE_ORDERS );


#############################################################################
##
#M  SetRelativeOrders( <pcgs>, <orders> )
##
InstallMethod( SetRelativeOrders,
    "setting orders and checking for prime orders",
    true,
    [ IsPcgs and IsComponentObjectRep and IsAttributeStoringRep,
      IsList ],
    SUM_FLAGS+1,

function( pcgs, orders )
    if not HasIsFiniteOrdersPcgs(pcgs)  then
        SetIsFiniteOrdersPcgs( pcgs,
            ForAll( orders, x -> x <> 0 and x <> infinity ) );
    fi;
    if IsFiniteOrdersPcgs(pcgs) and not HasIsPrimeOrdersPcgs(pcgs)  then
        SetIsPrimeOrdersPcgs( pcgs, ForAll( orders, x -> IsPrimeInt(x) ) );
    fi;
    SET_RELATIVE_ORDERS( pcgs, orders );
end );


#############################################################################
##
#M  SumOfPcElement( <pcgs>, <left>, <right> )
##
InstallMethod( SumOfPcElement,
    "generic methods, PcElementByExponents/ExponentsOfPcElement",
    IsCollsElmsElms,
    [ IsPcgs,
      IsObject,
      IsObject ],
    0,

function( pcgs, left, right )
    return PcElementByExponents( pcgs,
        ExponentsOfPcElement(pcgs,left)+ExponentsOfPcElement(pcgs,right) );
end );


#############################################################################
##
#M  ExtendedPcgs( <N>, <no-gens> )
##
InstallMethod( ExtendedPcgs, "pcgs, empty list", true,
        [ IsPcgs, IsList and IsEmpty ], 0,
    function( N, gens )
    return N;
end );


#############################################################################
##

#M  ExtendedIntersectionSumPcgs( <parent-pcgs>, <n>, <u>, <modpcgs> )
##
InstallMethod( ExtendedIntersectionSumPcgs,
    "generic method for modulo pcgs",
    true,
    #function(a,b,c) return IsIdenticalObj(a,b) and IsIdenticalObj(a,c); end,
    [ IsPcgs and IsPrimeOrdersPcgs,
      IsList,
      IsList,
      IsObject ],
    0,

function( pcgs, n, u, pcgsM )
    local   id,  G,  ls,  rs,  is,  g,  z,  I,  ros,  al,  ar,  tmp,  
            sum,  int;

    # set up
    id := OneOfPcgs( pcgs );
    G  := GroupOfPcgs( pcgs );

    # What  follows  is a Zassenhausalgorithm: <ls> and <rs> are the left and
    # rights  sides. They are initialized with [ n, n ] and [ u, 1 ]. <is> is
    # the  intersection.  <I>  contains  the  words  [ u, 1 ]  which  must be
    # Sifted through [ <ls>, <rs> ].

    ls := List( pcgs, x -> id );
    rs := List( pcgs, x -> id );
    is := List( pcgs, x -> id );

    for g in u do
        z := DepthOfPcElement( pcgs, g );
        ls[z] := g;
        rs[z] := g;
    od;

    I := [];
    for g in n do
        z := DepthOfPcElement( pcgs, g );
        if ls[z] = id  then
            ls[z] := g;
        else
            Add( I, g );
        fi;
    od;

    # enter the pairs [ u, 1 ] of <I> into [ <ls>, <rs> ]
    ros := RelativeOrders(pcgs);
    for al  in I  do
        ar := id;
        if not IsBool( pcgsM ) then 
            al := SiftedPcElement( pcgsM, al );
        fi;
        z  := DepthOfPcElement( pcgs, al );

        # shift through and reduced from the left
        while al <> id and ls[z] <> id  do
            tmp := LeadingExponentOfPcElement( pcgs, al )
                   / LeadingExponentOfPcElement( pcgs, ls[z] )
                   mod ros[z];
            al := LeftQuotient( ls[z]^tmp, al );
            if not IsBool( pcgsM ) then
                al := SiftedPcElement( pcgsM, al );
            fi;
            ar := LeftQuotient( rs[z]^tmp, ar );
            z  := DepthOfPcElement( pcgs, al );
        od;

        # have we a new sum or intersection generator
        if al <> id  then
            ls[z] := al;
            rs[z] := ar;
        else
            z := DepthOfPcElement( pcgs, ar );
            while ar <> id and is[z] <> id  do
                ar := ReducedPcElement( pcgs, ar, is[z] );
                if not IsBool( pcgsM ) then
                    ar := SiftedPcElement( pcgsM, ar );
                fi;
                z  := DepthOfPcElement( pcgs, ar );
            od;
            if ar <> id  then
                is[z] := ar;
            fi;
        fi;
    od;

    # Construct  the sum and intersection aggroups. Return left and right
    # sides, so one can decompose words of <N> * <U>.

    sum := InducedPcgsByPcSequence( pcgs, Filtered( ls, x -> x <> id ) );
    int := InducedPcgsByPcSequence( pcgs,
                        Filtered( is, x -> x <> id ) );
   
    return rec(
        leftSide     := ls,
        rightSide    := rs,
        sum          := sum,
        intersection := int );
end );


#############################################################################
##
#M  IntersectionSumPcgs( <parent-pcgs>, <n>, <u> )
##
InstallMethod( IntersectionSumPcgs,
    "using 'ExtendedIntersectionSumPcgs'",
    function(a,b,c) return IsIdenticalObj(a,b) and IsIdenticalObj(a,c); end,
    [ IsPcgs and IsPrimeOrdersPcgs,
      IsList,
      IsList ],
    0,
    function( pcgs, n, u ) 
        return ExtendedIntersectionSumPcgs(pcgs, n, u, true);
    end );


#############################################################################
##
#M  NormalIntersectionPcgs( <parent-pcgs>, <n>, <u> )
##
InstallMethod( NormalIntersectionPcgs,
    "using 'ExtendedIntersectionSumPcgs'",
    function(a,b,c) return IsIdenticalObj(a,b) and IsIdenticalObj(a,c); end,
    [ IsPcgs and IsPrimeOrdersPcgs,
      IsList,
      IsList ],
    0,

function( p, n, u )
   return ExtendedIntersectionSumPcgs(p,n,u,true).intersection;
end );


#############################################################################
##
#M  SumPcgs( <parent-pcgs>, <n>, <u> )
##
InstallMethod( SumPcgs,
    "generic method",
    function(a,b,c) return IsIdenticalObj(a,b) and IsIdenticalObj(a,c); end,
    [ IsPcgs and IsPrimeOrdersPcgs,
      IsList,
      IsList ],
    0,

function( pcgs, n, u )
    local   id,  G,  ls,  g,  z,  I,  ros,  al,  tmp;

    # set up
    id := OneOfPcgs( pcgs );
    G  := GroupOfPcgs( pcgs );

    # what follows is a Zassenhausalgorithm
    ls := List( pcgs, x -> id );

    for g in u do
        z := DepthOfPcElement( pcgs, g );
        ls[z] := g;
    od;

    I := [];
    for g in n do
        z := DepthOfPcElement( pcgs, g );
        if ls[z] = id  then
            ls[z] := g;
        else
            Add( I, g );
        fi;
    od;

    # enter the elements of <I> into <ls>
    ros := RelativeOrders(pcgs);
    for al  in I  do
        z  := DepthOfPcElement( pcgs, al );

        # shift through and reduced from the left
        while al <> id and ls[z] <> id  do
            tmp := LeadingExponentOfPcElement( pcgs, al )
                   / LeadingExponentOfPcElement( pcgs, ls[z] )
                   mod ros[z];
            al := LeftQuotient( ls[z]^tmp, al );
            z  := DepthOfPcElement( pcgs, al );
        od;

        # have we a new sum or intersection generator
        if al <> id  then
            ls[z] := al;
        fi;
    od;

    return InducedPcgsByPcSequence( pcgs, Filtered( ls, x -> x <> id ) );

end );


#############################################################################
##
#M  SumFactorizationFunctionPcgs( <parent-pcgs>, <u>, <n>, <modpcgs> )
##
InstallMethod( SumFactorizationFunctionPcgs,
    "generic method",
    #function(a,b,c) return IsIdenticalObj(a,b) and IsIdenticalObj(a,c); end,
    true,
    [ IsPcgs and IsPrimeOrdersPcgs,
      IsList,
      IsList,
      IsObject ],
    0,

function( pcgs, u, n, pcgsM )
    local   id,  S,  f;

    id := OneOfPcgs( pcgs );
    S  := ExtendedIntersectionSumPcgs( pcgs, n, u, pcgsM );

    # decomposition function
    f := function( un )
        local a, u, w, z;

        # Catch trivial case.
        if un = id  then
            return rec( u := id, n := id );
        fi;

        # Shift  through  'leftSide'  and  do  the  inverse  operations  with
        # 'rightSide'. This will give the <N> part.
        u := id;
        a := un;
        w := DepthOfPcElement( pcgs, a );
        while a <> id and S.leftSide[ w ] <> id  do
            z := LeadingExponentOfPcElement( pcgs, a )
                   / LeadingExponentOfPcElement( pcgs, S.leftSide[ w ] )
                 mod RelativeOrderOfPcElement( pcgs, a );
            a := LeftQuotient( S.leftSide[ w ] ^ z, a );
            u := u * S.rightSide[ w ] ^ z;
            w := DepthOfPcElement( pcgs, a );
        od;
        return rec( u := u, n := u^-1 * un );
    end;

    # Return the sum, intersection and the function.
    return rec( sum           := S.sum,
                intersection  := S.intersection,
                factorization := f );

end );


#############################################################################
##

#M  GroupByPcgs( <pcgs> )
##
GROUP_BY_PCGS_FINITE_ORDERS := function( pcgs )
    local   f,  e,  m,  i,  type,  s,  id,  tmp,  j;

    # construct a new free group
    f := FreeGroup( Length(pcgs) );
    e := ElementsFamily( FamilyObj(f) );

    # and a default type
    if 0 = Length(pcgs)  then
        m := 1;
    else
        m := Maximum(RelativeOrders(pcgs));
    fi;
    i := 1;
    while i < 4 and e!.expBitsInfo[i] <= m  do
        i := i + 1;
    od;
    type := e!.types[i];

    # and use a single collector
    s := SingleCollector( f, RelativeOrders(pcgs) );

    # compute the power relations
    id := OneOfPcgs(pcgs);
    for i  in [ 1 .. Length(pcgs) ]  do
        tmp := pcgs[i]^RelativeOrderOfPcElement(pcgs,pcgs[i]);
        if tmp <> id  then
            tmp := ExponentsOfPcElement( pcgs, tmp );
            tmp := ObjByVector( type, tmp );
            SetPowerNC( s, i, tmp );
        fi;
    od;

    # compute the conjugates
    for i  in [ 1 .. Length(pcgs) ]  do
        for j  in [ i+1 .. Length(pcgs) ]  do
            tmp := pcgs[j] ^ pcgs[i];
            if tmp <> id  then
                tmp := ExponentsOfPcElement( pcgs, tmp );
                tmp := ObjByVector( type, tmp );
                SetConjugateNC( s, j, i, tmp );
            fi;
        od;
    od;

    # and return the new group
    return GroupByRwsNC(s);

end;


InstallMethod( GroupByPcgs,
    true,
    [ IsPcgs ],
    0,

function( pcgs )

    # the following only works for finite orders
    if not IsFiniteOrdersPcgs(pcgs)  then
        TryNextMethod();
    fi;
    return GROUP_BY_PCGS_FINITE_ORDERS(pcgs);

end );


#############################################################################
##
#M  GroupOfPcgs( <pcgs> )
##
InstallMethod( GroupOfPcgs,
    true,
    [ IsPcgs ],
    0,

function( pcgs )
    local   tmp;

    tmp := Group( List( pcgs, x -> x ), OneOfPcgs(pcgs) );
    SetIsFinite( tmp, IsFiniteOrdersPcgs(pcgs) );
    SetPcgs(     tmp, pcgs                     );
    return tmp;
end );


#############################################################################
##

#R  IsEnumeratorByPcgsRep
##
DeclareRepresentation( "IsEnumeratorByPcgsRep",
    IsEnumerator and IsAttributeStoringRep,
    [ "pcgs", "sublist" ] );


#############################################################################
##
#M  EnumeratorByPcgs( <pcgs> )
##
InstallMethod( EnumeratorByPcgs,
    true,
    [ IsPcgs ],
    0,

function( pcgs )
    return Objectify(
        NewType( FamilyObj(pcgs), IsEnumerator and IsEnumeratorByPcgsRep ),
        rec( pcgs := pcgs, sublist := [ 1 .. Length(pcgs) ],
             relativeOrders := RelativeOrders(pcgs),
             complementList := [] ) );
end );


#############################################################################
##
#M  EnumeratorByPcgs( <pcgs>, <sublist> )
##
InstallOtherMethod( EnumeratorByPcgs,
    true,
    [ IsPcgs,
      IsList ],
    0,

function( pcgs, sublist )
    return Objectify(
        NewType( FamilyObj(pcgs), IsEnumerator and IsEnumeratorByPcgsRep ),
        rec( pcgs := pcgs, sublist := sublist,
             relativeOrders := RelativeOrders(pcgs),
             complementList := Difference([1..Length(pcgs)],sublist) ) );
end );


#############################################################################
##
#M  Length( <enum-by-pcgs> )
##
InstallMethod( Length,
    true,
    [ IsEnumerator and IsEnumeratorByPcgsRep ],
    0,
    enum -> Product(enum!.relativeOrders{enum!.sublist}) );


#############################################################################
##
#M  <enum-by-pcgs> [ <pos> ]
##
InstallMethod( \[\],
    true,
    [ IsEnumerator and IsEnumeratorByPcgsRep,
      IsPosInt ],
    0,

function( enum, pos )
    local   pcgs,  elm,  i,  p;
    
    pcgs := enum!.pcgs;
    elm  := OneOfPcgs( pcgs );
    pos  := pos - 1;
    for i  in Reversed( enum!.sublist )  do
        p   := enum!.relativeOrders[i];
        elm := pcgs[ i ] ^ ( pos mod p ) * elm;
        pos := QuoInt( pos, p );
    od;
    return elm;
end );


#############################################################################
##
#M  Position( <enum-by-pcgs>, <elm>, <zero> )
##
InstallMethod( Position,
    function(a,b,c) return IsCollsElms(a,b); end,
    [ IsEnumerator and IsEnumeratorByPcgsRep,
      IsMultiplicativeElementWithInverse,
      IsZeroCyc ],
    0,

function( enum, elm, zero )
    local   pcgs,  exp,  pos,  i;

    pcgs := enum!.pcgs;
    exp  := ExponentsOfPcElement( pcgs, elm );
    pos  := 0;
    if ForAny( enum!.complementList, x -> 0 <> exp[x] )  then
        return fail;
    fi;
    for i  in enum!.sublist  do
        pos := pos * enum!.relativeOrders[i] + exp[i];
    od;
    return pos + 1;
end );


#############################################################################
##
#M  PositionCanonical( <enum-by-pcgs>, <elm> )
##
InstallMethod( PositionCanonical,
    IsCollsElms,
    [ IsEnumerator and IsEnumeratorByPcgsRep,
      IsMultiplicativeElementWithInverse ],
    0,

function( enum, elm )
    local   pcgs,  exp,  pos,  i;

    pcgs := enum!.pcgs;
    exp  := ExponentsOfPcElement( pcgs, elm );
    pos  := 0;
    for i  in enum!.sublist  do
        pos := pos * enum!.relativeOrders[i] + exp[i];
    od;
    return pos + 1;
end );


#############################################################################
##
#M  NormalSeriesByPcgs( <pcgs> )
##
InstallMethod(NormalSeriesByPcgs,"via SubgroupByPcgs",true,
  [IsPcgs],0,
function(pcgs)
local p,l,g,h,i;
  l:=IndicesNormalSteps(pcgs);
  p:=Group(pcgs);
  g:=[p];
  for i in [2..Length(l)-1] do
    h:=SubgroupByPcgs(p,
      InducedPcgsByPcSequenceNC(pcgs,pcgs{[l[i]..Length(pcgs)]}));
    if not HasHomePcgs(h) then
      SetHomePcgs(h,pcgs);
    fi;
    Add(g,h);
  od;
  Add(g,TrivialSubgroup(p));
  return g;
end);


#############################################################################
##
#E  pcgs.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
