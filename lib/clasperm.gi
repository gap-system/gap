#############################################################################
##
#W  clasperm.gi                 GAP library                    Heiko Theißen
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This   file contains the functions   that calculate ordinary and rational
##  classes for permutation groups.
##


#############################################################################
##
#M  Enumerator( <xorb> )  . . . . . . . . . for conj. classes in perm. groups
##
##  The only difference to the enumerator for external orbits is a better
##  `Position' (and `PositionCanonical') method.
##
BindGlobal( "NumberElement_ConjugacyClassPermGroup", function( enum, elm )
    local xorb, G, rep;

    xorb := UnderlyingCollection( enum );
    G := ActingDomain( xorb );
    rep := RepOpElmTuplesPermGroup( true, G, [ elm ],
                   [ Representative( xorb ) ],
                   TrivialSubgroup( G ), StabilizerOfExternalSet( xorb ) );
    if rep = fail  then
        return fail;
    else
        return PositionCanonical( enum!.rightTransversal, rep ^ -1 );
    fi;
end );

InstallMethod( Enumerator,
    [ IsConjugacyClassPermGroupRep ],
    xorb -> EnumeratorByFunctions( xorb, rec(
               NumberElement     := NumberElement_ConjugacyClassPermGroup,
               ElementNumber     := ElementNumber_ExternalOrbitByStabilizer,

               rightTransversal  := RightTransversal( ActingDomain( xorb ),
                   StabilizerOfExternalSet( xorb ) ) ) ) );


#############################################################################
##
#M  <cl1> = <cl2> . . . . . . . . . . . . . . . . . . . for conjugacy classes
##
InstallMethod( \=,"classes for perm group", IsIdenticalObj,
    [ IsConjugacyClassPermGroupRep, IsConjugacyClassPermGroupRep ],
    function( cl1, cl2 )
    if not IsIdenticalObj( ActingDomain( cl1 ), ActingDomain( cl2 ) )  then
        TryNextMethod();
    fi;
    return RepOpElmTuplesPermGroup( true, ActingDomain( cl1 ),
                   [ Representative( cl1 ) ],
                   [ Representative( cl2 ) ],
                   StabilizerOfExternalSet( cl1 ),
                   StabilizerOfExternalSet( cl2 ) ) <> fail;
end );

#############################################################################
##
#M  <g> in <cl> . . . . . . . . . . . . . . . . . . . . for conjugacy classes
##
InstallMethod( \in,"perm class rep", IsElmsColls,
  [ IsPerm, IsConjugacyClassPermGroupRep ],
function( g, cl )
local   G;

    if HasAsList(cl) or HasAsSSortedList(cl) then
      TryNextMethod();
    fi;
    G := ActingDomain( cl );
    return RepOpElmTuplesPermGroup( true, ActingDomain( cl ),
                   [ g ], [ Representative( cl ) ],
                   TrivialSubgroup( G ),
                   StabilizerOfExternalSet( cl ) ) <> fail;
end );


#############################################################################
##
#M  Enumerator( <rcl> ) . . . . . . . . .  of rational class in a perm. group
##
##  The only difference to the enumerator for rational classes is a better
##  `Position' (and `PositionCanonical') method.
##
BindGlobal( "NumberElement_RationalClassPermGroup", function( enum, elm )
    local   rcl,  G,  rep,  gal,  T,  pow,  t;

    rcl := UnderlyingCollection( enum );
    G   := ActingDomain( rcl );
    rep := Representative( rcl );
    gal := RightTransversalInParent( GaloisGroup( rcl ) );
    T := enum!.rightTransversal;
    for pow  in [ 1 .. Length( gal ) ]  do
	# if gal[pow]=0 then the rep is the identity , no need to worry.
        t := RepOpElmTuplesPermGroup( true, G,
                     [ elm ], [ rep ^ Int( gal[ pow ] ) ],
                     TrivialSubgroup( G ),
                     StabilizerOfExternalSet( rcl ) );
        if t <> fail  then
            break;
        fi;
    od;
    if t = fail  then
        return fail;
    else
        return ( pow - 1 ) * Length( T ) + PositionCanonical( T, t ^ -1 );
    fi;
end );

InstallMethod( Enumerator,
    [ IsRationalClassPermGroupRep ],
    rcl -> EnumeratorByFunctions( rcl, rec(
               NumberElement     := NumberElement_RationalClassPermGroup,
               ElementNumber     := ElementNumber_RationalClassGroup,

               rightTransversal  := RightTransversal( ActingDomain( rcl ),
                   StabilizerOfExternalSet( rcl ) ) ) ) );


InstallOtherMethod( CentralizerOp, [ IsRationalClassGroupRep ],
    StabilizerOfExternalSet );

#############################################################################
##
#M  <cl1> = <cl2> . . . . . . . . . . . . . . . . . . .  for rational classes
##
InstallMethod( \=, IsIdenticalObj, [ IsRationalClassPermGroupRep,
        IsRationalClassPermGroupRep ],
    function( cl1, cl2 )
    if ActingDomain( cl1 ) <> ActingDomain( cl2 )  then
        TryNextMethod();
    fi;
    # the Galois group of the identity is <0>, therefore we have to do this
    # extra test.
    return Order(Representative(cl1))=Order(Representative(cl2)) and
      ForAny( RightTransversalInParent( GaloisGroup( cl1 ) ), e ->
                   RepOpElmTuplesPermGroup( true, ActingDomain( cl1 ),
                           [ Representative( cl1 ) ],
                           [ Representative( cl2 ) ^ Int( e ) ],
                           StabilizerOfExternalSet( cl1 ),
                           StabilizerOfExternalSet( cl2 ) ) <> fail );
end );

#############################################################################
##
#M  <g> in <cl> . . . . . . . . . . . . . . . . . . . .  for rational classes
##
InstallMethod( \in, true, [ IsPerm, IsRationalClassPermGroupRep ], 0,
    function( g, cl )
    local   G;

    G := ActingDomain( cl );
    # the Galois group of the identity is <0>, therefore we have to do this
    # extra test.
    return Order(Representative(cl))=Order(g) and
     ForAny( RightTransversalInParent( GaloisGroup( cl ) ), e ->
                   RepOpElmTuplesPermGroup( true, G,
                           [ g ^ Int( e ) ],
                           [ Representative( cl ) ],
                           TrivialSubgroup( G ),
                           StabilizerOfExternalSet( cl ) ) <> fail );
end );

#############################################################################
##

#F  CompleteGaloisGroupPElement( <cl>, <gal>, <power>, <p> )  add the p'-part
##
##  This  function assumes  that  the <p>-part  of the Galois  group  of  the
##  rational class <cl>  is already  bound  to  '<cl>.galoisGroup'.  It  then
##  computes  the  <p>'-part  and finds an  element  of the  normalizer which
##  induces an inner automorphism representing the generating residue of  the
##  Galois group.  <power> must the <p>-th power of <cl> .  If <p> = 2, there
##  is nothing to be done, since the Galois group is a 2-group then.
##
InstallGlobalFunction( CompleteGaloisGroupPElement, function( class, gal, power, p )
    local  G,  rep,  order,  F,
           phi,             # size of the prime residue class group
           primitiveRoot,   # generator of the cyclic prime residue class group
           sizeKnownPart,   # size of the known part of the Galois group
           sizeUnknownPart, # size of the unknown part of the Galois group
           generatorUnknownPart,
                            # generator of the unknown part of the prime
                            # residue class group, whose powers are tested
                            # one by one
           exp,             # some power of 'generatorP_Part'
           div,             # divisors of $p-1$
           q,               # variable used in division test
           fusingElement,   # element that  does the generating automorphism
           i;               # loop variable

    # If $p=2$, there is nothing to do.
    if p > 2  then
        G := ActingDomain( class );
        rep := Representative( class );
        order := Order( rep );
        F := FamilyObj( One( ZmodnZ( order ) ) );

        # <power> = 1 means that the power is the identity class.
        if power = 1  then
            power := RationalClass( G, One( G ) );
            SetStabilizerOfExternalSet( power, G );
            SetGaloisGroup( power, GroupByPrimeResidues( [  ], 1 ) );
            power!.fusingElement := One( G );
        fi;

        # Get the size of the prime residue class group and of the known part
        # of  the Galois  group (already known   from the calculation in  the
        # Sylow subgroup).
        phi                  := order / p * ( p - 1 );
        sizeKnownPart        := Size( gal );
        sizeUnknownPart      := GcdInt( p - 1, phi / sizeKnownPart );
        primitiveRoot        := ZmodnZObj( F, PrimitiveRootMod( order ) );
        generatorUnknownPart := primitiveRoot ^ ( phi / sizeUnknownPart );
        q := Size( G ) / Size( StabilizerOfExternalSet( class ) ) /
             sizeKnownPart;

        # Now run through all  the divisors <d> of  'sizeUnknownPart' testing
        # if there is an automorphism of order 'sizeKnownPart * <d>'.
        div           := DivisorsInt( sizeUnknownPart );
        i             := Length( div ) + 1;
        fusingElement := fail;
        repeat
            i := i - 1;

            # If such an automorphism exists, its order times the centralizer
            # order must divide the group order.
            if q mod div[ i ] = 0  then
                exp := generatorUnknownPart ^ ( sizeUnknownPart/div[i] );

                # If $C_G(g) = C_G(g^p)$, then Gal(<g>) must be generated
                # by a power of the generator of Gal(<g>^<p>).
                if Size( StabilizerOfExternalSet( class ) ) =
                   Size( StabilizerOfExternalSet( power ) )  then
                    if sizeKnownPart*div[i]>Size(GaloisGroup(power))  then
                        fusingElement := fail;
                    else
                        fusingElement := power!.fusingElement ^
                                         (Size(GaloisGroup(power)) /
                                          (sizeKnownPart*div[i]));
                        if rep ^ fusingElement <> rep ^ Int( exp )  then
                            fusingElement := fail;
                        fi;
                    fi;

                elif    order = p
                     or LogMod( Int( exp ), PrimitiveRootMod( order / p ),
                                order / p ) mod
                        IndexInParent( GaloisGroup( power ) ) = 0  then
                    if IsPerm( rep )  then
                        fusingElement := RepOpElmTuplesPermGroup( true, G,
                            [ rep ], [ rep ^ Int( exp ) ],
                            StabilizerOfExternalSet( class ),
                            StabilizerOfExternalSet( class ) );
                    else
                        fusingElement := RepresentativeAction( G,
                                         rep, rep ^ Int( exp ) );
                    fi;
                fi;
            fi;

        until fusingElement <> fail;

        # Construct the Galois  group as  subgroup of  a prime residue  class
        # group   and enter  the  conjugating   element   which induces   the
        # generating automorphism into the class record.
        gal := GroupByPrimeResidues(
                   [ primitiveRoot ^ ( phi / sizeKnownPart / div[ i ] ) ],
                   order );
        class!.fusingElement := fusingElement;

    fi;
    return gal;
end );

#############################################################################
##
#F  RatClasPElmArrangeClasses( <T>, <list>, <roots>, <power> )
##
InstallGlobalFunction( RatClasPElmArrangeClasses, function( T, list, roots, power )
    local  i,  j,  allRoots;

    allRoots := [ power ];
    for i  in [ 2 .. Length( T ) ]  do
        if T[ i ].power = power  then
            j := Length( list ) + 1;
            list[ j ] := i;
            roots[ j ] := [  ];
            Append( roots[ j ],RatClasPElmArrangeClasses(T,list,roots,i));
            Append( allRoots, roots[ j ] );
        fi;
    od;
    return allRoots;
end );

#############################################################################
##
#F  SortRationalClasses( <rationalClasses>, <p> ) . .  sort a list of classes
##
##  Sort the classes according to increasing  order, then decreasing <p>-part
##  of centralizer order, then decreasing <p>-part of Galois group order.
##
InstallGlobalFunction( SortRationalClasses, function( rationalClasses, p )
    Sort( rationalClasses, function( cl1, cl2 )
        local  ppart;
        if   Order( cl1.representative ) <
             Order( cl2.representative )  then
            return true;
        elif Order( cl1.representative ) >
             Order( cl2.representative )  then
            return false;
        else
            ppart := p ^ LogInt( Size( cl1.centralizer ), p );
            if Size( cl2.centralizer ) mod ppart <> 0  then
                return true;
            elif Size( cl2.centralizer ) mod ( ppart * p ) = 0  then
                return false;
            else
                ppart := p ^ LogInt( Size( cl1!.galoisGroup ), p );
                return Size( cl2!.galoisGroup ) mod ppart <> 0;
            fi;
        fi;
      end );
end );

#############################################################################
##
#F  FusionRationalClassesPSubgroup( <N>, <S>, <rationalClasses> )  pre-fusion
##
InstallGlobalFunction( FusionRationalClassesPSubgroup, function( N, S, rationalClasses )
    local  representatives,  classreps,  classimages,  fusedClasses,
           gens,  gensS,  gensNmodS,  genimages,  gen,
           prm,  i,  orbs,  orb,  cl,  pos,  porb;

    if Size( N ) > Size( S )  then

        # Construct the fusing operation of the group <N>.
        representatives := List( rationalClasses, cl -> cl.representative );
        classreps := [  ];
#        gens := TryPcgsPermGroup( [ N, S, TrivialSubgroup( N ) ],
#                        false, false, false );
#        if not IsPcgs( gens )  then
            gens := GeneratorsOfGroup( N );
#        fi;
        gensS := [  ];  gensNmodS := [  ];
        for gen  in gens  do
            if gen in S  then
                Add( gensS, gen );
            else
                Add( gensNmodS, gen );
                Append( classreps, OnTuples( representatives, gen ) );
            fi;
        od;
        classimages := List( RationalClassesSolvableGroup( S, 1,
	  rec(candidates:= classreps) ),
	  cl -> cl.representative );
        genimages := [  ];
        for i  in [ 1 .. Length( gensNmodS ) ]  do
            prm := List( [ 1 + ( i - 1 ) * Length( rationalClasses )
                           ..        i   * Length( rationalClasses ) ],
                   x -> Position( representatives, classimages[ x ] ) );
            Add( genimages, PermList( prm ) );
        od;
        orbs := ExternalOrbitsStabilizers( N,
                        [ 1 .. Length( rationalClasses ) ],
                        Concatenation( gensNmodS, gensS ),
                        Concatenation( genimages, List( gensS, g -> () ) ) );
                        # `genimages' arose from `PermList'
        fusedClasses := [  ];
        for orb  in orbs  do
            cl := rationalClasses[ Representative( orb ) ];
#
#T We may *NOT* set a known (larger) centralizer here as the centralizers
# themselves are used later to arrange the classes correctly (Lemma 3.3 in
# Heiko's diploma thesis, page 59/60).               AH
#
#            cl.centralizer := Centralizer
#                    ( StabilizerOfExternalSet( orb ), cl.representative,
#                      cl.centralizer );
            Add( fusedClasses, cl );
        od;

        # Update the `.power' entries.
        porb := [  ];
        for i  in [ 1 .. Length( fusedClasses ) ]  do
            pos := Position( representatives,
                             fusedClasses[ i ].power.representative );
            porb[ i ] := PositionProperty( orbs, o -> pos in AsList( o ) );
        od;
        for i  in [ 1 .. Length( fusedClasses ) ]  do
            fusedClasses[ i ].power := fusedClasses[ porb[ i ] ];
        od;

        return fusedClasses;
    else
        return rationalClasses;
    fi;
end );

#############################################################################
##
#F  RationalClassesPElements( <G>, <p> )  . .  rational classes of p-elements
##
InstallGlobalFunction( RationalClassesPElements, function( arg )
    local  G,               # the group
           p,               # the prime
           minprime,        # is <p> the minimal prime dividing $|G|$?
           sumSizes,        # sum of all class lengths known so far, optional
           rationalClasses, # rational classes of <p>-elements, result
           S,               # Sylow <p> subgroup of <G>
           gen,             # generator of <S> in the cyclic case
           N,               # solvable subgroup of N_G(S)
           rationalSClasses,# rational <S>-classes under conjugation by <N>
           list,            # list of class indices for order of treatment
           roots,           # list of indices of roots of a class
           found,           # classes already found
           movedTo,         # list of new positions of fused classes
           power,  gal,     # power and Galois group of current class
           i, j, cl, Scl;   # loop variables

    Error("`RationalClassesPElements' is not guaranteed to work");
    # Get the arguments.
    G := arg[ 1 ];
    p := arg[ 2 ];
    minprime :=  p = 2  or  p = Set( FactorsInt( Size( G ) ) )[ 1 ];
    if Length( arg ) > 2  then  sumSizes := arg[ 3 ];
                          else  sumSizes := -1;        fi;

    Info( InfoClasses, 1, "Calculating Sylow ", p, "-subgroup of |G| = ",
        Size( G ) );
    S := SylowSubgroup( G, p );

    # Treat the cyclic case.
    if IsCyclic( S )  then

        # Find a generator that generates the whole cyclic group.
        if IsTrivial( S )  then
            gen := One( S );
        else
            gen := First( GeneratorsOfGroup( S ),
                          gen -> Order( gen ) = Size( S ) );
        fi;

        rationalClasses := [  ];
        j := LogInt( Size( S ), p );
        for i  in [ 1 .. j ]  do
            cl := RationalClass( G, gen ^ ( p ^ ( j - i ) ) );
            SetStabilizerOfExternalSet( cl, Centralizer( G,
                    Representative( cl ), S ) );
            gal := GroupByPrimeResidues( [  ], p ^ i );
            if i = 1  then  power := 1;
                      else  power := rationalClasses[ i - 1 ];  fi;
            SetGaloisGroup( cl, CompleteGaloisGroupPElement
                    ( cl, gal, power, p ) );
            Add( rationalClasses, cl );
        od;
        return rationalClasses;
    fi;

    N := Normalizer( G, S );

    # Special treatment for elementary abelian Sylow subgroups.
    if IsElementaryAbelian( S )  then
        rationalClasses := RationalClassesInEANS( N, S );
        rationalSClasses := [  ];
        for cl  in rationalClasses  do
            Scl := rec( representative := Representative( cl ),
                           centralizer := StabilizerOfExternalSet( cl ),
                           galoisGroup := GroupByPrimeResidues( [  ],
                                          Order( Representative( cl ) ) ),
                                 power := rec( representative := One( S ) ) );
            Add( rationalSClasses, Scl );
        od;

    else
        Info( InfoClasses, 1,
              "Calculating rational classes in Sylow subgroup" );
        rationalSClasses := RationalClassesSolvableGroup( S, 3 );

        # Fuse the classes with the Sylow normalizer.
        rationalSClasses := FusionRationalClassesPSubgroup
                            ( N, S, rationalSClasses );

    fi;

    # Sort the classes. Change the `.power'  entries so that they contain the
    # index of the power class.
    SortRationalClasses( rationalSClasses, p );
    for cl  in rationalSClasses  do
        cl.power := PositionProperty( rationalSClasses,
                            c -> c.representative = cl.power.representative );
    od;
    Info( InfoClasses, 1, Length( rationalSClasses ), " classes to fuse" );

    # Determine the order in which to process the <S>-classes.
    list  := [ 1 ];
    roots := [ [  ] ];
    RatClasPElmArrangeClasses( rationalSClasses, list, roots, 1 );
    found   := [ 1 ];
    movedTo := [ 0 ];

    # Make <G>-classes out of the <N>-classes, putting them in a new list.
    rationalClasses := [  ];
    j := 1;
    while     j < Length( list )
          and sumSizes < Size( G )  do
        j := j + 1;
        if not list[ j ] in found  then
            Scl := rationalSClasses[ list[ j ] ];

            # If the class is  central, since we  have already considered the
            # Sylow  normalizer, it will not fuse to any other central class,
            # so it can be added to the list.
            if IsBound( Scl.isCentral )  then
                i := fail;
            else
                i := PositionProperty( rationalClasses, c -> ForAny
                  ( RightTransversalInParent( Scl.galoisGroup ), e ->
                     RepOpElmTuplesPermGroup( true, G,
                             [ Scl.representative ],
                             [ Representative( c ) ^ Int( e ) ],
                             Scl.centralizer,
                             StabilizerOfExternalSet( c ) ) <> fail ) );
            fi;
            if i = fail  then
                i := Length( rationalClasses ) + 1;
            fi;

            movedTo[ list[ j ] ] := i;
            if i > Length( rationalClasses )  then
                cl := RationalClass( G, Scl.representative );
                SetStabilizerOfExternalSet( cl, Centralizer( G,
                    Representative( cl ), Scl.centralizer ) );
                if movedTo[ Scl.power ] = 0  then
                    power := 1;
                else
                    power := rationalClasses[ movedTo[ Scl.power ] ];
                fi;
                if minprime  or  IsBound( Scl.isCentral )  then
                    SetGaloisGroup( cl, Scl.galoisGroup );
                else
                    SetGaloisGroup( cl, CompleteGaloisGroupPElement
                            ( cl, Scl.galoisGroup, power, p ) );
                fi;
                Add( rationalClasses, cl );
                if sumSizes >= 0  then
                    sumSizes := sumSizes + Size( cl );
                    Info( InfoClasses, 2, "Still missing ",
                          Size( G ) - sumSizes, " elements" );
                fi;
            else
                UniteSet( found, roots[ j ] );
            fi;
        fi;
    od;

    return rationalClasses;
end );

#############################################################################
##
#F  RationalClassesPermGroup(<G>[,<primes>]) rational classes for perm groups
##
InstallGlobalFunction( RationalClassesPermGroup, function( G, primes )
    local  rationalClasses,  # rational classes of <G>, result
           p,                # next (largest) prime to be processed
           pRationalClasses, # rational classes of <p>-elements in <G>
           pClass,           # one class from <pRationalClasses>
           z, r,             # <z> is the repr. of <pClass> of order <p>^<r>
           C,                # the centralizer of <z> in <G>
           Hom,              # block homomorphism determined by the cycles
                             # of <z>
           C_,               # image of <C> under <Hom>
           rationalClasses_, # rational classes in <C_>
           found,            # classes whose preimages are already found
           pos,              # position of class among constructed classes
           class_,           # one class from <rationalClasses_>
           y_, t,            # <y_> is the repr. of <class_> of order <t>
           moduli,           # moduli for Chinese remainder theorem
           y,  oy,           # preimage of <y_> that is a root of <z>, order
           s, rs, a, b, gcd, # auxiliary variables in the calculation of <y>
           class,            # class to be constructed from <y>
           ji,               # generator of the cyclic Galois group of <z>
           gi,               # element inducing the conjugation corr. to <ji>
           conj,             # result of conjugacy test $Hom(y^g)$ to $y_^m$
           m,                # auxiliary variable in calculation of $Gal(y)$
           gens,  gen,       # generators of the Galois group of <y>.
           i, k, cl;   # loop variables

    # Treat the trivial case.
    rationalClasses := [  ];
    if IsTrivial( G )  then
        return rationalClasses;
    fi;

    for k  in [ 1 .. Length( primes ) ]  do
        p := primes[ k ];
        if Size( G ) mod p = 0  then
            if     k = Length( primes )
               and IsSubset( primes, FactorsInt( Size( G ) ) )  then
                pRationalClasses := RationalClassesPElements( G, p,
                                        Sum( rationalClasses, Size ) );
            else
                pRationalClasses := RationalClassesPElements( G, p );
            fi;
            Append( rationalClasses, pRationalClasses );
            if k < Length( primes )  then
                if p = 2  then
                    Error( "case p = 2 not implemented" );
                fi;
                for pClass  in pRationalClasses  do
                    z := Representative( pClass );
                    C := StabilizerOfExternalSet( pClass );
                    r := LogInt( Order( z ), p );

                    # Set  up the  blocks homomorphism  C  -> C_ and find the
                    # rational classes in C_.
                    Hom := ActionHomomorphism( C, List( Cycles( z,
                                   MovedPoints( G ) ), Set ), OnSets );
                    C_ := ImagesSource( Hom );
                    rationalClasses_ := RationalClassesPermGroup
                        ( C_, primes{ [ k + 1 .. Length( primes ) ] } );

                    # Pull  back the rational classes and  the  Galois groups
                    # from C_ to C.
                    Info( InfoClasses, 1, "Lifting back from |C_| = ",
                        Size( C_ ), " to |G| = ", Size( G ) );
                    found := [  ];
                    for i  in [ 1 .. Length( rationalClasses_ ) ]  do
                      if not i in found  then
                        class_ := rationalClasses_[ i ];
                        y_ := Representative( class_ );
                        t := Order( y_ );
                        moduli := [ p ^ r, t ];

                        # Find  a preimage of <y_>  that really is  a root of
                        # <z>.
                        y   := PreImagesRepresentative( Hom, y_ );
                        s   := LogInt( Order( y ), p );
                        rs  := Maximum( r, s );
                        gcd := Gcdex( t, p ^ rs );
                        a   := gcd.coeff1;
                        b   := gcd.coeff2;
                        y   := y ^ ( b * p ^ rs ) * z ^ a;
                        oy  := Order( y );

                        # Let <g> be an element  conjugating <z> to $z^j$ and
                        # generating  $Gal(z)$. Find the smallest power $g^i$
                        # such that $Hom(y^{g^i})$ is rationally conjugate to
                        # $Hom(y)$. Then    $j^i$ times  a   cofactor is  the
                        # generator of  one  direct  factor of $Gal(y)$.  All
                        # preimages of elements $Hom(y^{g^l})$ with $l<i$ are
                        # rationally conjugate to <y>.
                        gi := One( G );
                        ji := One( GaloisGroup( pClass ) );
                        if not IsTrivial( GaloisGroup( pClass ) )  then
                          repeat
                            gi :=gi*pClass!.fusingElement;
                            ji :=ji*GeneratorsOfGroup(GaloisGroup(pClass))[1];
                            cl :=( y ^ gi ) ^ Hom;
                            pos := i - 1;
                            repeat
                              pos := pos + 1;
                              for m  in RightTransversalInParent
                                (GaloisGroup(rationalClasses_[pos]))  do
                                conj := RepOpElmTuplesPermGroup( true, C_,
                                  [ cl ], [ Representative
                                            (rationalClasses_[pos])^Int(m) ],
                                  TrivialSubgroup( C_ ),
                                  StabilizerOfExternalSet
                                                (rationalClasses_[ pos ]) );
                                if conj <> fail  then  break;  fi;
                              od;
                            until conj <> fail;
                            AddSet( found, pos );
                          until pos = i;
                        else
                          cl   := Representative( class_ );
                          m    := One( GaloisGroup( class_ ) );
                          conj := One( G );
                        fi;

                        # Now   $Hom(y^{g^i})  ~  Hom(y^m)$.  $Gal(y)$ is the
                        # direct product   of $Gal(Hom(y))$ and  the subgroup
                        # generated by $mj^i$.
                        gens := [ ChineseRem( moduli, [ Int(ji), Int(m) ] ) ];
                        for gen  in GeneratorsOfGroup( GaloisGroup( class_ ) )
                          do
                            Add( gens, ChineseRem( moduli, [ 1, Int(gen)] ) );
                        od;
                        class := RationalClass( G, y );
                        SetStabilizerOfExternalSet( class, Centralizer
                          ( PreImages( Hom, StabilizerOfExternalSet(class_) ),
                            y ) );
                        SetGaloisGroup( class, GroupByPrimeResidues
                                ( gens, oy ) );
                        Add( rationalClasses, class );
                      fi;
                    od;
                od;
            fi;
        fi;
    od;
    return rationalClasses;
end );

# #############################################################################
# ##
# #M  RationalClasses( <G> )  . . . . . . . . . . . . . . . . . . of perm group
# ##
# InstallMethod( RationalClasses, "perm group", [ IsPermGroup ],
#     function( G )
#     local   cl;
# 
#     if IsPrimePowerInt( Size( G ) ) and not HasIsNilpotentGroup(G) then
#         SetIsNilpotentGroup( G, true );
#         return RationalClasses(G);
#     else
#         cl := RationalClass( G, One( G ) );
#         SetStabilizerOfExternalSet( cl, G );
#         SetGaloisGroup( cl, GroupByPrimeResidues( [  ], 1 ) );
#         return Concatenation( [ cl ], RationalClassesPermGroup
#                        ( G, Reversed( Set( FactorsInt( Size( G ) ) ) ) ) );
#     fi;
# end );

# #############################################################################
# ##
# #M  ConjugacyClasses( <G> )
# ##
# InstallMethod( ConjugacyClasses, "perm group",
#     [ IsPermGroup and HasRationalClasses ],
#     G -> Concatenation( List( RationalClasses( G ),
# 		        DecomposedRationalClass ) ) );


#############################################################################
##
#E

