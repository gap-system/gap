#############################################################################
##
#W  domain.gi                   GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This contains the generic methods for domains.
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
    return IsSSortedList( C ) and AsListSorted( D ) = C;
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
    return IsSSortedList( C ) and AsListSorted( D ) = C;
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
    return AsListSorted( D1 ) = AsListSorted( D2 );
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
    return C < AsListSorted( D );
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
    return AsListSorted( D ) < C;
    end );


#############################################################################
##
#M  SetParent( <D>, <P> ) . . . . . . . method to run the subset implications
##
InstallMethod( SetParent,
    "method that calls 'UseSubsetRelation'",
    IsIdenticalObj,
    [ IsDomain, IsDomain ], SUM_FLAGS,
    function( D, P )
    UseSubsetRelation( P, D );
    TryNextMethod();
    end );


#############################################################################
##
#M  DomainByGenerators(<F>,<empty>) . . . . . . . . for family and empty list
##
InstallOtherMethod( DomainByGenerators,
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
#M  DomainByGenerators(<F>,<generators>)  . . . . . for family and collection
##
InstallMethod( DomainByGenerators,
    "for family and collection",
    true,
    [ IsFamily, IsCollection ], 0,
    function ( F, generators )
    local   D;
    if IsNotIdenticalObj( CollectionsFamily(F), FamilyObj(generators) ) then
        Error( "<generators> must lie in <F>" );
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
#M  FinalizeDomain( <D> ) . . . . . . . . . . . . . . . . . .  default method
##
InstallMethod( FinalizeDomain,
    "default method 'Ignore'",
    true,
    [ IsDomain ], 0,
    Ignore );


#############################################################################
##
#M  AsList( <D> ) . . . . . . . . . . . . . . . . set of elements of a domain
#M  Enumerator( <D> ) . . . . . . . . . . . . . . set of elements of a domain
##
##  A domain contains no duplicates, so the sorted list can be taken
##  if it is already known.
##  Note, however, that 'AsListSorted' resp. 'EnumeratorSorted' cannot be the
##  default method of 'AsList' resp. 'Enumerator' for domains,
##  since 'EnumeratorSorted' is allowed to call 'Enumerator'.
##
InstallImmediateMethod( AsList,
    IsDomain and HasAsListSorted,
    0,
    AsListSorted );

InstallImmediateMethod( Enumerator,
    IsDomain and HasEnumeratorSorted,
    0,
    EnumeratorSorted );


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
    RepresentativeFromGenerators( GeneratorsOfDomain ) );


#############################################################################
##
#M  ViewObj( <enum> ) . . . . . . . . . . . . . . .  view a domain enumerator
##
InstallMethod( ViewObj,
    "for a domain enumerator with underlying collection",
    true,
    [ IsDomainEnumerator and HasUnderlyingCollection ], 0,
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
    "for domain and domain with parent",
    IsIdenticalObj,
    [ IsDomain, IsDomain and HasParent ], SUM_FLAGS,
    function ( D, E )
    if not IsIdenticalObj( D, Parent( E ) ) then
        TryNextMethod();
    fi;
    return true;
    end );


#############################################################################
##
#E  domain.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



