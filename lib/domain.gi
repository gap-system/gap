#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Martin Schönert.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the generic methods for domains.
##


#############################################################################
##
#M  \=( <C>, <D> )  . . . . . . . . . . . . . . . . . . . for list and domain
##
##  A domain is equal to the strictly sorted list of its elements.
##
InstallMethod( \=,
    "for a list and a domain",
    IsIdenticalObj,
    [ IsCollection and IsList, IsDomain ],
    function( C, D )
    if IsFinite(C) <> IsFinite(D) then
      return false;
    fi;
    if not IsFinite(D) then
        Error("no method found for comparing an infinite domain and an infinite list");
    fi;
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
    [ IsDomain, IsCollection and IsList ],
    function( D, C )
    if IsFinite(C) <> IsFinite(D) then
      return false;
    fi;
    if not IsFinite(C) then
        Error("no method found for comparing an infinite domain and an infinite list");
    fi;
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
    [ IsDomain, IsDomain ],
    function( D1, D2 )
    if IsFinite(D1) <> IsFinite(D2) then
      return false;
    fi;
    if not IsFinite(D1) then
        Error("no method found for comparing two infinite domains");
    fi;
    return AsSSortedList( D1 ) = AsSSortedList( D2 );
    end );


#############################################################################
##
#M  \<( <C>, <D> )  . . . . . . . . . . . . . . . . . . . for list and domain
##
InstallMethod( \<,
    "for a list and a domain",
    IsIdenticalObj,
    [ IsCollection and IsList, IsDomain ],
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
    [ IsDomain, IsCollection and IsList ],
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
    [ IsDomain, IsDomain ],
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
    [ IsFamily, IsList and IsEmpty ],
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
    [ IsFamily, IsCollection and IsList ],
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
    [ IsCollection ],
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
    [ IsDomain ],
    AsList );


#############################################################################
##
##  PrintObj
##
InstallMethod( PrintObj,
    "for a domain with GeneratorsOfDomain",
    [ HasGeneratorsOfDomain and IsDomain ],
    function( dom )
    Print( "Domain(", GeneratorsOfDomain( dom ), ")" );
    end );


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
    [ IsDomain and HasGeneratorsOfDomain ],
    function( D )
        if HasIsDuplicateFreeList( GeneratorsOfDomain( D ) )
                and IsDuplicateFreeList( GeneratorsOfDomain( D ) ) then
            return GeneratorsOfDomain( D );
        else
            return DuplicateFreeList( GeneratorsOfDomain( D ) );
        fi;
    end );

InstallMethod( Enumerator,
    "for a domain with stored domain generators",
    [ IsDomain and HasGeneratorsOfDomain ],
    AsList );


#############################################################################
##
#M  EnumeratorSorted( <D> ) . . . . . . . . . . . set of elements of a domain
##
InstallMethod( EnumeratorSorted,
    "for a domain",
    [ IsDomain ],
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
    [ IsObject, IsDomain ],
    function( elm, D )
    return elm in Enumerator( D );
    end );


#############################################################################
##
#M  Representative( <D> ) . . . . . . . . . . . .  representative of a domain
##
InstallMethod( Representative,
    "for a domain with known elements list",
    [ IsDomain and HasAsList ],
    RepresentativeFromGenerators( AsList ) );

InstallMethod( Representative,
    "for a domain with known domain generators",
    [ IsDomain and HasGeneratorsOfDomain ],
    RepresentativeFromGenerators( GeneratorsOfDomain ) );


#############################################################################
##
#M  Size( <D> ) . . . . . . . . . . . . . . . . . . . .  for a trivial domain
##
InstallMethod( Size,
    "for a trivial domain",
    [ IsDomain and IsTrivial ],
    D -> 1 );


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
    [ IsDomain, IsDomain ],
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
    ReturnFirst);

#############################################################################
##
#F  InstallAccessToGenerators( <required>, <infotext>, <generators> )
##
InstallGlobalFunction( InstallAccessToGenerators,
    function( required, infotext, generators )

    InstallMethod( \.,
        Concatenation( "generators of a ", infotext ),
        true,
        [ required and Tester( generators ), IsPosInt ], 0,
        function( D, n )

        local gens, nr, names;

        # Get the appropriate generators and the component name string.
        gens:= generators( D );
        n:= NameRNam( n );

        # If the component name stands for an integer,
        # return the generator at this position.
        nr:= Int( n );
        if IsPosInt( nr ) then
          if nr <= Length( gens ) then
            return gens[ nr ];
          else
            Error("Generator number ", nr, " does not exist\n");
          fi;
        fi;

        # I the component name is the name itself,
        # return the corresponding generator.
        names:= ElementsFamily( FamilyObj( D ) );
        if IsBound( names!.names ) then
          names:= names!.names;
          nr:= Position( names, n );
          if nr <> fail then
            return gens[ nr ];
          fi;
        fi;

        # Give up.
        TryNextMethod();
        end );

    end );
