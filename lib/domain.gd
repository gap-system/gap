#############################################################################
##
#W  domain.gd                   GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This declares the operations for domains.
##
Revision.domain_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsDomain(<D>) . . . . . . . . . . . . . . . . . . . . . . test for domain
##
##  'IsDomain' returns 'true' if <D> is a domain and 'false' otherwise.
##
IsDomain :=
    NewCategory( "IsDomain",
        IsCollection );


#############################################################################
##
#A  GeneratorsOfDomain(<D>)
##
GeneratorsOfDomain := AsListSorted;
SetGeneratorsOfDomain := SetAsListSorted;
HasGeneratorsOfDomain := HasAsListSorted;


#############################################################################
##
#O  DomainByGenerators(<F>,<generators>)
##
DomainByGenerators := NewOperation( "DomainByGenerators",
    [ IsFamily, IsCollection ] );
#T 1997/01/16 fceller was old 'NewConstructor'


#############################################################################
##
#O  Domain(<F>,<generators>)
##
Domain := DomainByGenerators;
#T Do we need a dispatcher function around 'DomainByGenerators'?


#############################################################################
##
#A  Parent(<D>)
#F  SetParent(<D>,<P>)
#F  HasParent(<D>)
##
##  'Parent' returns the parent domain of the domain <D>.   If the parent has
##  not been set with 'SetParent' then 'Parent( <D> )' is identical to <D>.
##
##  One can set  a super-collection <P>  of a domain <D>  to be the parent of
##  <D> using   'SetParent( <D>, <P>  )'.   After this,  <P>  is the value of
##  'Parent( <D> )', and 'HasParent( <D> )' is 'true'.
##
ParentAttr := NewAttribute( "Parent", IsDomain );
SetParent  := Setter( ParentAttr );
HasParent  := Tester( ParentAttr );

Parent := function( S )
    if HasParent( S ) then
        return ParentAttr( S );
    else
        return S;
    fi;
end;


#############################################################################
##
#C  IsDomainEnumerator( <obj> )
##
##  Enumerators of domains that are not represented as plain lists may be in
##  this category.
##
IsDomainEnumerator := NewCategory( "IsDomainEnumerator",
    IsEnumerator and IsDuplicateFreeList );


#############################################################################
##
#A  UnderlyingCollection( <enum> )
##
##  An enumerator of a domain can delegate the task to compute its length to
##  'Size' for the underlying domain.
##
UnderlyingCollection := NewAttribute( "UnderlyingCollection",
    IsDomainEnumerator );
SetUnderlyingCollection := Setter( UnderlyingCollection );
HasUnderlyingCollection := Tester( UnderlyingCollection );

InstallInParentMethod := function( attr, filter, op )
    InstallMethod( attr, true, [ filter ], 0,
        dom -> op( Parent( dom ), dom ) );
end;

#############################################################################
##
#E  domain.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



