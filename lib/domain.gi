#############################################################################
##
#W  domain.gi                   GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This contains the generic methods for domains.
##
Revision.domain_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  SetParent( <D>, <P> ) . . . . . . . method to run the subset implications
##
InstallMethod( SetParent,
    "method that calls 'RunSubsetImplications'",
    IsIdentical,
    [ IsDomain, IsDomain ], SUM_FLAGS,
    function( D, P )
    RunSubsetImplications( P, D );
    TryNextMethod();
    end );


#############################################################################
##
#M  DomainByGenerators(<F>,<generators>)
##
InstallMethod( DomainByGenerators, true,
    [ IsFamily, IsList and IsEmpty ], 0,
    function ( F, generators )
    local   D;
    D := Objectify( NewKind( CollectionsFamily( F ),
                             IsDomain and IsAttributeStoringRep ),
                    rec() );
    SetGeneratorsOfDomain( D, AsList( generators ) );
    return D;
    end );

InstallMethod( DomainByGenerators, true,
    [ IsFamily, IsCollection ], 0,
    function ( F, generators )
    local   D;
    if IsNotIdentical( CollectionsFamily(F), FamilyObj(generators) ) then
        Error( "<generators> must lie in <F>" );
    fi;
    D := Objectify( NewKind( FamilyObj( generators ),
                             IsDomain and IsAttributeStoringRep ),
                    rec() );
    SetGeneratorsOfDomain( D, AsList( generators ) );
    return D;
    end );

InstallOtherMethod( DomainByGenerators, true,
    [ IsCollection ], 0,
    function ( generators )
    local   D;
    D := Objectify( NewKind( FamilyObj( generators ),
                             IsDomain and IsAttributeStoringRep ),
                    rec() );
    SetGeneratorsOfDomain( D, AsList( generators ) );
    return D;
    end );


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
InstallMethod( \in, IsElmsColls, [ IsObject, IsDomain ], 0,
    function( elm, D )
    return elm in Enumerator( D );
    end );


#############################################################################
##
#F  RepresentativeFromGenerators( <GeneratorsStruct> )
##
##  We can get ia representative of a domain by taking an element of a
##  suitable generators list, so the problem is to specify the generators.
##
RepresentativeFromGenerators := function( StructGenerators )
    return function( D )
           D:= StructGenerators( D );
           if IsEmpty( D ) then
             TryNextMethod();
           fi;
           return Representative( D );
           end;
end;


#############################################################################
##
#M  Representative( <D> ) . . . . . . . . . . . . . representative of a domain
##
InstallMethod( Representative, true, [ IsDomain ], 0,
    RepresentativeFromGenerators( GeneratorsOfDomain ) );


#############################################################################
##
#M  PrintObj( <enum> )  . . . . . . . . . . . . . . print a domain enumerator
##
InstallMethod( PrintObj, true,
    [ IsDomainEnumerator and HasUnderlyingCollection ], 0,
    function( enum ) Print( "<enumerator of ",
    UnderlyingCollection( enum ), ">" ); end );

InstallMethod( PrintObj, true, [ IsDomainEnumerator ], 0,
    function( enum ) Print( "<enumerator of a domain>" ); end );


#############################################################################
##
#M  Length( <enum> )  . . . . . . . . . . . . . length of a domain enumerator
##
InstallMethod( Length, true,
    [ IsDomainEnumerator and HasUnderlyingCollection ], 0,
    enum -> Size( UnderlyingCollection( enum ) ) );


#############################################################################
##
#M  IsSubset( <D>, <E> )  . . . . . . . . . . . . . . . . for <E> with parent
##
InstallMethod( IsSubset,
    IsIdentical, [ IsDomain, IsDomain and HasParent ], SUM_FLAGS,
    function ( D, E )
    if not IsIdentical( D, Parent( E ) ) then
        TryNextMethod();
    fi;
    return true;
    end );


#############################################################################
##
#E  domain.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



