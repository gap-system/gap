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
#E

