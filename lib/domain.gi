#############################################################################
##
#W  domain.gi                   GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the generic methods for domains.
##
Revision.domain_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  \=( <C>, <D> )  . . . . . . . . . . . . . . . . . . . for list and domain
##
##  A domain is equal to the strictly sorted list of its elements.
##
InstallMethod( \=,
    "for a list and a domain",
    IsIdenticalObj,
    [ IsCollection and IsList, IsDomain ], 0,
    function( C, D )
    return IsSSortedList( C ) and AsSSortedList( D ) = C;
    end );


#############################################################################
##
#M  \=( <D>, <C> )  . . . . . . . . . . . . . . . . . . . for domain and list
##
##  A domain is equal to the strictly sorted list of its elements.
##
InstallMethod( \=,
    "for a domain and a list",
    IsIdenticalObj,
    [ IsDomain, IsCollection and IsList ], 0,
    function( D, C )
    return IsSSortedList( C ) and AsSSortedList( D ) = C;
    end );


#############################################################################
##
#M  \=( <D1>, <D2> ) . . . . . . . . . . . . . . . . . . . .  for two domains
##
##  Two domains are equal if their elements lists are equal.
##
InstallMethod( \=,
    "for two domains",
    IsIdenticalObj,
    [ IsDomain, IsDomain ], 0,
    function( D1, D2 )
    return AsSSortedList( D1 ) = AsSSortedList( D2 );
    end );


#############################################################################
##
#M  \<( <C>, <D> )  . . . . . . . . . . . . . . . . . . . for list and domain
##
InstallMethod( \<,
    "for a list and a domain",
    IsIdenticalObj,
    [ IsCollection and IsList, IsDomain ], 0,
    function( C, D )
    return C < AsSSortedList( D );
    end );


#############################################################################
##
#M  \<( <D>, <C> )  . . . . . . . . . . . . . . . . . . . for domain and list
##
InstallMethod( \<,
    "for a domain and a list",
    IsIdenticalObj,
    [ IsDomain, IsCollection and IsList ], 0,
    function( D, C )
    return AsSSortedList( D ) < C;
    end );


#############################################################################
##
#M  SetParent( <D>, <P> ) . . . . . . . method to run the subset implications
##
InstallMethod( SetParent,
    "method that calls 'UseSubsetRelation'",
    IsIdenticalObj,
    [ IsDomain, IsDomain ], 0,
    function( D, P )
    UseSubsetRelation( P, D );
    TryNextMethod();
    end );


#############################################################################
##
#F  Domain( [<Fam>, ]<generators> )
##
InstallGlobalFunction( Domain, function( arg )
    if   Length( arg ) = 1 and IsHomogeneousList( arg[1] )
                           and not IsEmpty( arg[1] ) then
      return DomainByGenerators( FamilyObj( arg[1][1] ), arg[1] );
    elif     Length( arg ) = 2 and IsFamily( arg[1] )
         and IsHomogeneousList( arg[2] )
         and ( IsEmpty( arg[2] ) or
               FamilyObj(arg[2]) = CollectionsFamily( arg[1] ) ) then

      return DomainByGenerators( arg[1], arg[2] );
    else
      Error( "usage: Domain( [<Fam>, ]<generators> )" );
    fi;
    end );


#############################################################################
##
#M  DomainByGenerators( <F>, <empty> )  . . . . . . for family and empty list
##
InstallMethod( DomainByGenerators,
    "for family and empty list",
    true,
    [ IsFamily, IsList and IsEmpty ], 0,
    function ( F, generators )
    local   D;
    D := Objectify( NewType( CollectionsFamily( F ),
                             IsDomain and IsAttributeStoringRep ),
                    rec() );
    SetGeneratorsOfDomain( D, AsList( generators ) );
    return D;
    end );


#############################################################################
##
#M  DomainByGenerators( <F>, <generators> ) . . . . for family and collection
##
InstallMethod( DomainByGenerators,
    "for family and list & collection",
    true,
    [ IsFamily, IsCollection and IsList ], 0,
    function ( F, generators )
    local   D;
    if IsNotIdenticalObj( CollectionsFamily(F), FamilyObj(generators) ) then
        Error( "each element in <generators> must lie in <F>" );
    fi;
    D := Objectify( NewType( FamilyObj( generators ),
                             IsDomain and IsAttributeStoringRep ),
                    rec() );
    SetGeneratorsOfDomain( D, AsList( generators ) );
    return D;
    end );


#############################################################################
##
#M  DomainByGenerators( <generators> )  . . . . . . . . . . .  for collection
##
InstallOtherMethod( DomainByGenerators,
    "for a collection",
    true,
    [ IsCollection ], 0,
    function ( generators )
    local   D;
    D := Objectify( NewType( FamilyObj( generators ),
                             IsDomain and IsAttributeStoringRep ),
                    rec() );
    SetGeneratorsOfDomain( D, AsList( generators ) );
    return D;
    end );


#############################################################################
##
#M  GeneratorsOfDomain( <D> )
##
##  `GeneratorsOfDomain' delegates to `AsList'.
##
InstallImmediateMethod( GeneratorsOfDomain,
    IsDomain and HasAsList and IsAttributeStoringRep, 0,
    AsList );

InstallMethod( GeneratorsOfDomain,
    "for a domain (delegate to `AsList')",
    true,
    [ IsDomain ], 0,
    AsList );


#############################################################################
##
#M  AsList( <D> ) . . . . . . . . . . . . . . .  list of elements of a domain
#M  Enumerator( <D> ) . . . . . . . . . . . . .  list of elements of a domain
##
##  A domain contains no duplicates, so the sorted list can be taken for both
##  `AsList' and `Enumerator' if it is already known.
##  Note, however, that `AsSSortedList' resp. `EnumeratorSorted' cannot be the
##  default method of `AsList' resp. `Enumerator' for domains,
##  since `EnumeratorSorted' is allowed to call `Enumerator'.
##
##  If domain generators of <D> are stored then `AsList' and `Enumerator'
##  may return a duplicate-free list of domain generators.
##
InstallImmediateMethod( AsList,
    IsDomain and HasAsSSortedList and IsAttributeStoringRep,
    0,
    AsSSortedList );

InstallImmediateMethod( Enumerator,
    IsDomain and HasEnumeratorSorted and IsAttributeStoringRep,
    0,
    EnumeratorSorted );

InstallMethod( AsList,
    "for a domain with stored domain generators",
    true,
    [ IsDomain and HasGeneratorsOfDomain ], 0,
    D -> DuplicateFreeList( GeneratorsOfDomain( D ) ) );

InstallMethod( Enumerator,
    "for a domain with stored domain generators",
    true,
    [ IsDomain and HasGeneratorsOfDomain ], 0,
    D -> DuplicateFreeList( GeneratorsOfDomain( D ) ) );


#############################################################################
##
#M  EnumeratorSorted( <D> ) . . . . . . . . . . . set of elements of a domain
##
InstallMethod( EnumeratorSorted,
    "for a domain",
    true,
    [ IsDomain ], 0,
    D -> EnumeratorSorted( Enumerator( D )  ));


#############################################################################
##
#M  \in( <elm>, <D> ) . . . . . . . . . . . . . . membership test for domains
##
##  The default method for domain membership tests computes the set of
##  elements of the domain with the function 'Enumerator' and tests whether
##  <elm> lies in this set.
##
InstallMethod( \in,
    "for a domain, and an element",
    IsElmsColls,
    [ IsObject, IsDomain ], 0,
    function( elm, D )
    return elm in Enumerator( D );
    end );


#############################################################################
##
#M  Representative( <D> ) . . . . . . . . . . . .  representative of a domain
##
InstallMethod( Representative,
    "for a domain with known elements list",
    true,
    [ IsDomain and HasAsList ], 0,
    RepresentativeFromGenerators( AsList ) );

InstallMethod( Representative,
    "for a domain with known domain generators",
    true,
    [ IsDomain and HasGeneratorsOfDomain ], 0,
    RepresentativeFromGenerators( GeneratorsOfDomain ) );


#############################################################################
##
#M  Size( <D> ) . . . . . . . . . . . . . . . . . . . .  for a trivial domain
##
InstallMethod( Size,
    "for a trivial domain",
    true,
    [ IsDomain and IsTrivial ], 0,
    D -> 1 );


#############################################################################
##
#M  ViewObj( <enum> ) . . . . . . . . . . . . . . .  view a domain enumerator
##
InstallMethod( ViewObj,
    "for a domain enumerator with underlying collection",
    true,
    [ IsDomainEnumerator and HasUnderlyingCollection ], 20,
    # override, e.g., the method for finite lists
    # in the case of an enumerator of GF(q)^n
    function( enum )
    Print( "<enumerator of " );
    View( UnderlyingCollection( enum ) );
    Print( ">" );
    end );

InstallMethod( ViewObj,
    "for a domain enumerator",
    true,
    [ IsDomainEnumerator ], 0,
    function( enum )
    Print( "<enumerator of a domain>" );
    end );


#############################################################################
##
#M  PrintObj( <enum> )  . . . . . . . . . . . . . . print a domain enumerator
##
InstallMethod( PrintObj,
    "for a domain enumerator with underlying collection",
    true,
    [ IsDomainEnumerator and HasUnderlyingCollection ], 0,
    function( enum )
    Print( "<enumerator of ", UnderlyingCollection( enum ), ">" );
    end );

InstallMethod( PrintObj,
    "for a domain enumerator",
    true,
    [ IsDomainEnumerator ], 0,
    function( enum ) Print( "<enumerator of a domain>" );
    end );
#T this is not nice!


#############################################################################
##
#M  Length( <enum> )  . . . . . . . . . . . . . length of a domain enumerator
##
InstallMethod( Length,
    "for a domain enumerator with underlying collection",
    true,
    [ IsDomainEnumerator and HasUnderlyingCollection ], 0,
    enum -> Size( UnderlyingCollection( enum ) ) );


#############################################################################
##
#M  IsSubset( <D>, <E> )  . . . . . . . . . . . . . . . . for <E> with parent
##
InstallMethod( IsSubset,
    "test whether domain is parent of the other",
    IsIdenticalObj,
    [ IsDomain, IsDomain and HasParent ],
    SUM_FLAGS, # should be done before everything else
    function ( D, E )
    if not IsIdenticalObj( D, Parent( E ) ) then
        TryNextMethod();
    fi;
    return true;
    end );

InstallMethod( CanComputeIsSubset,
    "default for domains: no unless identical",
    true,
    [ IsDomain, IsDomain ], 0,
    function( a, b )
    return IsIdenticalObj( a, b )
           or ( HasParent( b ) and CanComputeIsSubset( a, Parent( b ) ) );
    end );


#############################################################################
##
#M  Intersection2( <D1>, <D2> )
##
##  We cannot install this for arbitrary collections since the intersection
##  must be duplicate free (and sorted in the case of a list).
##
InstallMethod( Intersection2,
    "whole family and domain",
    IsIdenticalObj,
    [ IsCollection and IsWholeFamily, IsDomain ],
    SUM_FLAGS, # this is better than everything else
    function( D1, D2 )
    return D2;
    end );

InstallMethod( Intersection2,
    "domain and whole family",
    IsIdenticalObj,
    [ IsDomain, IsCollection and IsWholeFamily ],
    SUM_FLAGS, # this is better than everything else
    function( D1, D2 )
    return D1;
    end );


#############################################################################
##
#E

