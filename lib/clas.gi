#############################################################################
##
#W  clas.gi                     GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
Revision.clas_gi :=
    "@(#)$Id$";

#############################################################################
##
#M  Enumerator( <xorb> )  . . . . . . . . . . . . . .  enumerator constructor
##
InstallMethod( Enumerator, true, [ IsExternalOrbitByStabilizerRep ], 0,
    function( xorb )
    local   enum;
    
    enum := Objectify( NewKind( FamilyObj( xorb ),
                    IsExternalOrbitByStabilizerEnumerator ),
        rec( rightTransversal := RightTransversal( ActingDomain( xorb ),
                    StabilizerOfExternalSet( xorb ) ) ) );
    SetUnderlyingCollection( enum, xorb );
    return enum;
end );

#############################################################################
##
#M  <enum>[ <pos> ] . . . . . . . . . . . . . . . . . .  for such enumerators
##
InstallMethod( \[\], true, [ IsExternalOrbitByStabilizerEnumerator,
        IsPosRat and IsInt ], 0,
    function( enum, pos )
    local   xorb;
    
    xorb := UnderlyingCollection( enum );
    return FunctionOperation( xorb )
           ( Representative( xorb ), enum!.rightTransversal[ pos ] );
end );

#############################################################################
##
#M  Position( <enum>, <elm>, <zero> ) . . . . . . . . .  for such enumerators
##
InstallMethod( Position, true, [ IsExternalOrbitByStabilizerEnumerator,
        IsObject, IsZeroCyc ], 0,
    function( enum, elm, zero )
    local   xorb,  rep;
    
    xorb := UnderlyingCollection( enum );
    rep := RepresentativeOperation( xorb, Representative( xorb ), elm );
    if rep = fail  then  return fail;
                   else  return Position( enum!.rightTransversal, rep );  fi;
end );

#############################################################################
##

#M  ConjugacyClass( <G>, <g> )  . . . . . . . . . . . . . . . . . constructor
##
InstallMethod( ConjugacyClass, IsCollsElms, [ IsGroup, IsObject ], 0,
    function( G, g )
    local   cl;
    
    cl := Objectify( NewKind( FamilyObj( G ) ), rec( start := [ g ] ) );
    if IsPermGroup( G )  then
        SetFilterObj( cl, IsConjugacyClassPermGroupRep );
    else
        SetFilterObj( cl, IsConjugacyClassGroupRep );
    fi;
    SetActingDomain( cl, G );
    SetRepresentative( cl, g );
    SetFunctionOperation( cl, OnPoints );
    return cl;
end );

#############################################################################
##
#M  HomeEnumerator( <cl> )  . . . . . . . . . . . . . . . . enumerator of <G>
##
InstallMethod( HomeEnumerator, true, [ IsConjugacyClassGroupRep ], 0,
    cl -> Enumerator( ActingDomain( cl ) ) );

#############################################################################
##
#M  PrintObj( <cl> )  . . . . . . . . . . . . . . . . . . . .  print function
##
InstallMethod( PrintObj, true, [ IsConjugacyClassGroupRep ], 0,
    function( cl )
    Print( "ConjugacyClass( ", ActingDomain( cl ), ", ",
           Representative( cl ), " )" );
end );

#############################################################################
##
#M  Size( <G>, <g> )  . . . . . . . . . . . . . . . . . . . . . size function
##
InstallMethod( Size, true, [ IsConjugacyClassGroupRep ], 0,
    cl -> Index( ActingDomain( cl ), StabilizerOfExternalSet( cl ) ) );

InstallOtherMethod( Centralizer, true, [ IsConjugacyClassGroupRep ], 0,
    StabilizerOfExternalSet );

#############################################################################
##
#M  AsList( <cl> )  . . . . . . . . . . . . . . . . . . .  by orbit algorithm
##
InstallMethod( AsList, true, [ IsExternalOrbitByStabilizerRep ], 0,
    cl -> Orbit( ActingDomain( cl ), Representative( cl ) ) );

#############################################################################
##
#M  ConjugacyClasses( <G> ) . . . . . . . . . . . . . . . . . . .  of a group
##
InstallMethod( ConjugacyClasses, true, [ IsGroup ], 0,
    function ( G )
    local   classes,    # conjugacy classes of <G>, result
            class,      # one class of <G>
            elms;       # elements of <G>

    # initialize the conjugacy class list
    classes := [ ConjugacyClass( G, One( G ) ) ];

    # if the group is small, or if its elements are known 
    # or if the group is abelian, do it the hard way
    if Size( G ) <= 1000 or HasAsListSorted( G )  or IsAbelian( G ) then

        # get the elements
        elms := Difference( AsListSorted( G ), [ One( G ) ] );

        # while we have not found all conjugacy classes
        while 0 < Length(elms)  do

            # add the class of the first element
            class := ConjugacyClass( G, elms[1] );
            Add( classes, class );

            # remove the elements of this class
            SubtractSet( elms, AsListSorted( class ) );

        od;

    # otherwise use probabilistic algorithm
    else

        # while we have not found all conjugacy classes
        while Sum( List( classes, Size ) ) <> Size( G )  do

            # try random elements
            ConjugacyClassesTry( G, classes, Random(G), 0, 1 );

        od;

    fi;

    # return the conjugacy classes
    return classes;

end );

ConjugacyClassesTry := function ( G, classes, elm, length, fixes )
    local   C,          # new class
            D,          # another new class
            new,        # new classes
            i;          # loop variable

    # if the element is not in one of the known classes add a new class
    if ForAll( classes, D -> length mod Size(D) <> 0 or not elm in D )  then
        C := ConjugacyClass( G, elm );
        Add( classes, C );
        new := [ C ];

        # try powers that keep the order, compare only with new classes
        for i  in [2..Order(elm)-1]  do
            if GcdInt( i, Order(elm) * fixes ) = 1  then
                if not elm^i in C  then
                    if ForAll( new, D -> not elm^i in D )  then
                        D := ConjugacyClass( G, elm^i );
                        Add( classes, D );
                        Add( new, D );
                    fi;
                elif IsPrimeInt(i)  then
                    fixes := fixes * i;
                fi;
            fi;
        od;

        # try also the powers of this element that reduce the order
        for i  in Set( FactorsInt( Order( elm ) ) )  do
            ConjugacyClassesTry(G,classes,elm^i,Size(C),fixes);
        od;

    fi;

end;

InstallMethod( ConjugacyClasses, true, [ IsSolvableGroup ], 0,
    G -> ClassesSolvableGroup( G, G, true, 0 ) );

#############################################################################
##

#M  RationalClass( <G>, <g> ) . . . . . . . . . . . . . . . . . . constructor
##
InstallMethod( RationalClass, IsCollsElms, [ IsGroup, IsObject ], 0,
    function( G, g )
    local   cl;
    
    cl := Objectify( NewKind( FamilyObj( G ) ), rec(  ) );
    if IsPermGroup( G )  then
        SetFilterObj( cl, IsRationalClassPermGroupRep );
    else
        SetFilterObj( cl, IsRationalClassGroupRep );
    fi;
    SetActingDomain( cl, G );
    SetRepresentative( cl, g );
    SetFunctionOperation( cl, OnPoints );
    return cl;
end );

#############################################################################
##
#M  <cl1> = <cl2> . . . . . . . . . . . . . . . . . . .  for rational classes
##
InstallMethod( \=, IsIdentical, [ IsRationalClassGroupRep,
        IsRationalClassGroupRep ], 0,
    function( cl1, cl2 )
    if ActingDomain( cl1 ) <> ActingDomain( cl2 )  then
        TryNextMethod();
    fi;
    return ForAny( RightTransversalInParent( GaloisGroup( cl1 ) ), e ->
                   RepresentativeOperation( ActingDomain( cl1 ),
                           Representative( cl1 ),
                           Representative( cl2 ) ^ ( 1 ^ e ) ) <> fail );
end );

#############################################################################
##
#M  <g> in <cl> . . . . . . . . . . . . . . . . . . . .  for rational classes
##
InstallMethod( \in, IsElmsColls, [ IsObject, IsRationalClassGroupRep ], 0,
    function( g, cl )
    return ForAny( RightTransversalInParent( GaloisGroup( cl ) ), e ->
                   RepresentativeOperation( ActingDomain( cl ),
                           Representative( cl ),
                           g ^ ( 1 ^ e ) ) <> fail );
end );
    
#############################################################################
##
#M  HomeEnumerator( <cl> )  . . . . . . . . . . . . . . . . enumerator of <G>
##
InstallMethod( HomeEnumerator, true, [ IsConjugacyClassGroupRep ], 0,
    cl -> Enumerator( ActingDomain( cl ) ) );

#############################################################################
##
#M  PrintObj( <cl> )  . . . . . . . . . . . . . . . . . . . .  print function
##
InstallMethod( PrintObj, true, [ IsRationalClassGroupRep ], 0,
    function( cl )
    Print( "RationalClass( ", ActingDomain( cl ), ", ",
           Representative( cl ), " )" );
end );

#############################################################################
##
#M  Size( <cl> )  . . . . . . . . . . . . . . . . . . . . . . . size function
##
InstallMethod( Size, true, [ IsRationalClassGroupRep ], 0,
    cl -> IndexInParent( GaloisGroup( cl ) ) *
          Index( ActingDomain( cl ), StabilizerOfExternalSet( cl ) ) );

#############################################################################
##
#F  DecomposedRationalClass( <cl> ) . . . . . decompose into ordinary classes
##
DecomposedRationalClass := function( cl )
    local   G,  C,  rep,  gal,  T,  cls,  e,  c;
    
    G := ActingDomain( cl );
    C := StabilizerOfExternalSet( cl );
    rep := Representative( cl );
    gal := GaloisGroup( cl );
    T := RightTransversal( Parent( gal ), gal );
    cls := [  ];
    for e  in T  do
        c := ConjugacyClass( G, rep ^ ( 1 ^ e ) );
        SetStabilizerOfExternalSet( c, C );
        Add( cls, c );
    od;
    return cls;
end;

#############################################################################
##
#R  IsRationalClassGroupEnumerator  . . . . . . enumerator for rational class
##
IsRationalClassGroupEnumerator := NewRepresentation
    ( "IsRationalClassGroupEnumerator",
      IsDomainEnumerator and IsComponentObjectRep and IsAttributeStoringRep,
      [ "rightTransversal" ] );

#############################################################################
##
#M  Enumerator( <rcl> ) . . . . . . . . . . . . . . . . . . of rational class
##
InstallMethod( Enumerator, true, [ IsRationalClassGroupRep ], 0,
    function( rcl )
    local   enum;
    
    enum := Objectify( NewKind( FamilyObj( rcl ),
                IsRationalClassGroupEnumerator ),
                rec( rightTransversal := RightTransversal
                ( ActingDomain( rcl ), StabilizerOfExternalSet( rcl ) ) ) );
    SetUnderlyingCollection( enum, rcl );
    return enum;
end );

InstallMethod( \[\], true, [ IsRationalClassGroupEnumerator,
        IsPosRat and IsInt ], 0,
    function( enum, pos )
    local   rcl,  rep,  gal,  T,  pow;
    
    rcl := UnderlyingCollection( enum );
    rep := Representative( rcl );
    gal := RightTransversalInParent( GaloisGroup( rcl ) );
    T := enum!.rightTransversal;
    pos := pos - 1;
    pow := QuoInt( pos, Length( T ) ) + 1;
    pos := pos mod Length( T ) + 1;
    return ( rep ^ T[ pos ] ) ^ ( 1 ^ gal[ pow ] );
end );

InstallMethod( Position, true, [ IsRationalClassGroupEnumerator, IsObject,
        IsZeroCyc ], 0,
    function( enum, elm, zero )
    local   rcl,  G,  rep,  gal,  T,  pow,  t;
    
    rcl := UnderlyingCollection( enum );
    G   := ActingDomain( rcl );
    rep := Representative( rcl );
    gal := RightTransversalInParent( GaloisGroup( rcl ) );
    T := enum!.rightTransversal;
    for pow  in [ 1 .. Length( gal ) ]  do
        t := RepresentativeOperation( G, rep ^ ( 1 ^ gal[ pow ] ), elm );
        if t <> fail  then
            break;
        fi;
    od;
    if t = fail  then  return fail;
                 else  return ( pow - 1 ) * Length( T ) + Position( T, t );
    fi;
end );

InstallOtherMethod( Centralizer, true, [ IsRationalClassGroupRep ], 0,
    StabilizerOfExternalSet );

#############################################################################
##
#M  AsList( <rcl> ) . . . . . . . . . . . . . . . . . . .  by orbit algorithm
##
InstallMethod( AsList, true, [ IsRationalClassGroupRep ], 0,
    function( rcl )
    local   aslist,  orb,  e;
    
    aslist := [  ];
    orb := Orbit( ActingDomain( rcl ), Representative( rcl ) );
    for e  in RightTransversalInParent( GaloisGroup( rcl ) )  do
        Append( aslist, List( orb, g -> g ^ ( 1 ^ e ) ) );
    od;
    return aslist;
end );

#############################################################################
##
#F  PermResidueClass( <r>, <n> )  . .  residue class as permutation on [1..n]
##
PermResidueClass := function( r, n )
    return PermList( List( [ 1 .. n - 1 ] * r, i -> i mod n ) );
end;

#############################################################################
##
#F  PrimeResidueClassGroup(<m>) . . . . . . .  full prime residue class group
##
PrimeResidueClassGroups := [ Group( () ) ];

PrimeResidueClassGroup := function ( m )
    local   G,          # group $Z/mZ$, result
            gens,       # generators of <G>
            p, q,       # prime and prime power dividing <m>
            r,          # primitive root modulo <q>
            g;          # is = <r> mod <q> and = 1 mod <m> / <q>

  if not IsBound( PrimeResidueClassGroups[ m ] )  then
        
    # add generators for each prime power factor <q> of <m>
    gens := [];
    for p  in Set( FactorsInt( m ) )  do
        q := p;
        while m mod (q * p) = 0  do q := q * p;  od;

        # $ Z / 4Z = < 3 > $
        if   q = 4  then
            r := 3;
            g := r + q * (((1/q mod (m/q)) * (1 - r)) mod (m/q));
            Add( gens, PermResidueClass( g, m ) );

        # $ Z / 8nZ = < 5, -1 > $ is *not* cyclic
        elif q mod 8 = 0  then
            r := q-1;
            g := r + q * (((1/q mod (m/q)) * (1 - r)) mod (m/q));
            Add( gens, PermResidueClass( g, m ) );
            r := 5;
            g := r + q * (((1/q mod (m/q)) * (1 - r)) mod (m/q));
            Add( gens, PermResidueClass( g, m ) );

        # for odd <q> $ Z / qZ $ is cyclic
        elif q <> 2  then
            r :=  PrimitiveRootMod( q );
            g := r + q * (((1/q mod (m/q)) * (1 - r)) mod (m/q));
            Add( gens, PermResidueClass( g, m ) );
        fi;

    od;

    # return the group generated by <gens>
    G := Group( gens, PermResidueClass( 1, m ) );
    SetSize( G, Phi( m ) );
    PrimeResidueClassGroups[ m ] := G;

  fi;
  return PrimeResidueClassGroups[ m ];
end;

#############################################################################
##
#M  GaloisGroup( <cl> ) . . . . . . . . . . . . . . . . . of a rational class
##
InstallOtherMethod( GaloisGroup, true, [ IsRationalClassGroupRep ], 0,
    function( cl )
    local   rep,  ord,  gals,  i;
    
    rep := Representative( cl );
    ord := Order( rep );
    gals := [  ];
    for i  in [ 1 .. ord - 1 ]  do
        if     GcdInt( i, ord ) = 1
           and RepresentativeOperation( ActingDomain( cl ),
                       rep, rep ^ i ) <> fail  then
            Add( gals, PermResidueClass( i, ord ) );
        fi;
    od;
    return SubgroupNC( PrimeResidueClassGroup( ord ), gals );
end );
    
#############################################################################
##
#M  RationalClasses( <G> )  . . . . . . . . . . . . . . . . . . .  of a group
##
InstallMethod( RationalClasses, true, [ IsGroup ], 0,
    function( G )
    local   rcl;

    rcl := [];
    while Sum( rcl, Size ) < Size( G )  do
        RationalClassesTry( G, rcl, Random(G) );
    od;
    return rcl;
end );

RationalClassesTry := function(  G, classes, elm  )
    local   C,          # new class
            D,          # another new class
            i;          # loop variable

    # if the element is not in one of the known classes add a new class
    if ForAll( classes, D -> not elm in D )  then
        C := RationalClass( G, elm );
        Add( classes, C );

        # try the powers of this element that reduce the order
        for i  in Set(FactorsInt(Order(elm)))  do
            RationalClassesTry( G, classes, elm ^ i );
        od;

    fi;

end;

InstallMethod( RationalClasses, true, [ IsSolvableGroup ], 0,
    function( G )
    if not IsPrimePowerInt( Size( G ) )  then
        TryNextMethod();
    fi;
    return ClassesSolvableGroup( G, G, true, 1 );
end );

#############################################################################

#F  RationalClassesInEANS( <G>, <E> ) . . . . . . . . by projective operation
##
RationalClassesInEANS := function( G, E )
    local  pcgs,  ff,  one,  pro,  opr,  gens,  orbs,  xorb,  rcl,  rcls,
           rep,  N;

    rcls := [ RationalClass( G, One( G ) ) ];
    if IsTrivial( E )  then
        return rcls;
    fi;
    
    pcgs := Pcgs( E );
    ff := GF( RelativeOrders( pcgs )[ 1 ] );
    one := One( ff );
    pro := ProjectiveSpace( ff ^ Length( pcgs ) );
    opr := function( v, g )
        return one * ExponentsOfPcElement( pcgs,
                       PcElementByExponents( pcgs, v ) ^ g );
    end;
    gens := Pcgs( G );
    if gens = fail  then
        gens := GeneratorsOfGroup( G );
    fi;
    orbs := ExternalOrbits( G, pro, gens, gens, opr );

    # Construct the rational classes  from the  orbit representatives and the
    # centralizers from the stabilizers.
    for xorb  in orbs  do
        rep := PcElementByExponents( pcgs, Representative( xorb ) );
        rcl := RationalClass( G, rep );
        if HasStabilizerOfExternalSet( xorb )  then
            N := StabilizerOfExternalSet( xorb );
        else
            N := G;
        fi;
        SetStabilizerOfExternalSet( rcl, Centralizer( N, rep, E ) );
        Add( rcls, rcl );
    od;
    return rcls;
end;

#############################################################################
##

#E  Emacs variables . . . . . . . . . . . . . . local variables for this file
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:
#############################################################################
