#############################################################################
##
#W  rwsgrp.gi                   GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file  contains the generic methods for  groups  defined by rewriting
##  systems.
##
Revision.rwsgrp_gi :=
    "@(#)$Id$";


#############################################################################
##

#R  IsElementByRwsDefaultRep
##
IsElementByRwsDefaultRep := NewRepresentation(
    "IsElementByRwsDefaultRep",
    IsPositionalObjectRep, [1] );


#############################################################################
##
#M  ElementByRws( <fam>, <elm> )
##
InstallMethod( ElementByRws,
    true,
    [ IsElementsFamilyByRws, IsObject ],
    0,

function( fam, elm )
    elm := [ Immutable(elm) ];
    return Objectify( fam!.defaultKind, elm );
end );


#############################################################################
##
#M  PrintObj( <elm-by-rws> )
##
InstallMethod( PrintObj,
    true,
    [ IsElementByRwsDefaultRep ],
    0,

function( obj )
    Print( obj![1] );
end );


#############################################################################
##
#M  UnderlyingElement( <elm-by-rws> )
##
InstallMethod( UnderlyingElement,
    true,
    [ IsMultiplicativeElementWithInverseByRws and IsElementByRwsDefaultRep ],
    0,

function( obj )
    return obj![1];
end );


#############################################################################
##
#M  ExtRepOfObj( <elm-by-rws> )
##
InstallMethod( ExtRepOfObj,
    true,
    [ IsMultiplicativeElementWithInverseByRws and IsElementByRwsDefaultRep ],
    0,

function( obj )
    return ExtRepOfObj( UnderlyingElement( obj ) );
end );


#############################################################################
##

#M  Inverse( <elm-by-rws> )
##
InstallMethod( Inverse,
    true,
    [ IsMultiplicativeElementWithInverseByRws ],
    0,

function( obj )
    local   fam;

    fam := FamilyObj(obj);
    return ElementByRws( fam, ReducedInverse( fam!.rewritingSystem,
        UnderlyingElement(obj) ) );
end );


#############################################################################
##
#M  One( <elm-by-rws> )
##
InstallMethod( One,
    true,
    [ IsMultiplicativeElementWithInverseByRws ],
    0,

function( obj )
    local   fam;

    fam := FamilyObj(obj);
    return ElementByRws( fam, ReducedOne(fam!.rewritingSystem) );
end );


#############################################################################
##
#M  <elm-by-rws> * <elm-by-rws>
##
InstallMethod( \*,
    IsIdentical,
    [ IsMultiplicativeElementWithInverseByRws,
      IsMultiplicativeElementWithInverseByRws ],
    0,

function( left, right )
    local   fam;

    fam := FamilyObj(left);
    return ElementByRws( fam, ReducedProduct( fam!.rewritingSystem,
        UnderlyingElement(left), UnderlyingElement(right) ) );
end );


#############################################################################
##
#M  <elm-by-rws> = <elm-by-rws>
##
InstallMethod( \=,
    IsIdentical,
    [ IsMultiplicativeElementWithInverseByRws,
      IsMultiplicativeElementWithInverseByRws ],
    0,

function( left, right )
    return UnderlyingElement(left) = UnderlyingElement(right);
end );


#############################################################################
##
#M  <elm-by-rws> < <elm-by-rws>
##
InstallMethod( \<,
    IsIdentical,
    [ IsMultiplicativeElementWithInverseByRws,
      IsMultiplicativeElementWithInverseByRws ],
    0,

function( left, right )
    return UnderlyingElement(left) < UnderlyingElement(right);
end );


#############################################################################
##

#M  MultiplicativeElementsWithInversesFamilyByRws( <rws> )
##
InstallMethod( MultiplicativeElementsWithInversesFamilyByRws,
    true,
    [ IsRewritingSystem and IsBuiltFromGroup ],
    0,

function( rws )
    local   fam;

    # create a new family in the category <IsElementsFamilyByRws>
    fam := NewFamily(
        "MultiplicativeElementsWithInversesFamilyByRws(...)",
        IsMultiplicativeElementWithInverseByRws 
          and IsAssociativeElement,
        IsElementsFamilyByRws );

    # store the rewriting system
    fam!.rewritingSystem := Immutable(rws);

    # create the default kind for the elements
    fam!.defaultKind := NewKind( fam, IsElementByRwsDefaultRep );

    # that's it
    return fam;

end );



#############################################################################
##

#M  GroupByRws( <rws> )
##
InstallMethod( GroupByRws,
    true,
    [ IsRewritingSystem and IsBuiltFromGroup ],
    0,

function( rws )

    # it must be confluent
    if not IsConfluent(rws)  then
        Error( "the rewriting system must be confluent" );
    fi;

    # use the no-check to do the work
    return GroupByRwsNC(rws);
end );


#############################################################################
##
#M  GroupByRwsNC( <rws> )
##
InstallMethod( GroupByRwsNC,
    true,
    [ IsRewritingSystem and IsBuiltFromGroup ],
    100,

function( rws )
    local   fam,  gens,  g,  id,  grp;

    # give the rewriting system a chance to optimise itself
    ReduceRules(rws);

    # construct a new family containing the group elements
    fam := MultiplicativeElementsWithInversesFamilyByRws(rws);

    # construct the generators
    gens := [];
    for g  in GeneratorsOfRws(rws)  do
        Add( gens, ElementByRws( fam, ReducedForm( rws, g ) ) );
    od;
    id := ElementByRws( fam, ReducedOne(rws) );

    # and a group
    grp := Group( gens, id );

    # it is the whole family
    SetIsWholeFamily( grp, true );

    # check the true methods
    RunGroupByRwsMethods( rws, grp );
    
    # that's it
    return grp;

end );


#############################################################################
##

#E  rwsgrp.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
