#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file  contains the generic methods for  groups  defined by rewriting
##  systems.
##


#############################################################################
##
#M  ElementByRws( <fam>, <elm> )
##
InstallMethod( ElementByRws,
    true,
    [ IsElementsFamilyByRws, IsObject ],
    0,

function( fam, elm )
    return Objectify( fam!.defaultType, [ elm ] );
end );

##
##  Some collectors,  for example a Deep Thought  collector, store the
##  rhs of conjugate and power relations as generators exponent lists.
##  If ElementByRws() is called for those rhs, we need to convert them
##  first to words in the appropriate free group.
##
InstallMethod( ElementByRws,
    true,
    [ IsElementsFamilyByRws, IsList ],
    0,

function( fam, list )
    local  elm, freefam;

    freefam := UnderlyingFamily( fam!.rewritingSystem );
    elm := ObjByExtRep( freefam, list );
    return Objectify( fam!.defaultType, [ elm ] );
end );


#############################################################################
##
#M  PrintObj( <elm-by-rws> )
##
InstallMethod( PrintObj,
    true,
    [ IsMultiplicativeElementWithInverseByRws and IsPackedElementDefaultRep ],
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
    [ IsMultiplicativeElementWithInverseByRws and IsPackedElementDefaultRep ],
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
    [ IsMultiplicativeElementWithInverseByRws ],
    0,

function( obj )
    return ExtRepOfObj( UnderlyingElement( obj ) );
end );


#############################################################################
##
#M  Comm( <elm-by-rws>, <elm-by-rws> )
##
InstallMethod( Comm,
    "rws-element, rws-element",
    IsIdenticalObj,
    [ IsMultiplicativeElementWithInverseByRws,
      IsMultiplicativeElementWithInverseByRws ],
    0,

function( left, right )
    local   fam;

    fam := FamilyObj(left);
    return ElementByRws( fam, ReducedComm( fam!.rewritingSystem,
        UnderlyingElement(left), UnderlyingElement(right) ) );
end );


#############################################################################
##
#M  InverseOp( <elm-by-rws> )
##
InstallMethod( InverseOp,
    "rws-element",
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
#M  LeftQuotient( <elm-by-rws>, <elm-by-rws> )
##
InstallMethod( LeftQuotient,
    "rws-element, rws-element",
    IsIdenticalObj,
    [ IsMultiplicativeElementWithInverseByRws,
      IsMultiplicativeElementWithInverseByRws ],
    0,

function( left, right )
    local   fam;

    fam := FamilyObj(left);
    return ElementByRws( fam, ReducedLeftQuotient( fam!.rewritingSystem,
        UnderlyingElement(left), UnderlyingElement(right) ) );
end );


#############################################################################
##
#M  OneOp( <elm-by-rws> )
##
InstallMethod( OneOp,
    "rws-element",
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
#M  Quotient( <elm-by-rws>, <elm-by-rws> )
##
InstallMethod( \/,
    "rws-element, rws-element",
    IsIdenticalObj,
    [ IsMultiplicativeElementWithInverseByRws,
      IsMultiplicativeElementWithInverseByRws ],
    0,

function( left, right )
    local   fam;

    fam := FamilyObj(left);
    return ElementByRws( fam, ReducedQuotient( fam!.rewritingSystem,
        UnderlyingElement(left), UnderlyingElement(right) ) );
end );


#############################################################################
##
#M  <elm-by-rws> * <elm-by-rws>
##
InstallMethod( \*,
    "rws-element * rws-element",
    IsIdenticalObj,
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
#M  <elm-by-rws> ^ <elm-by-rws>
##
InstallMethod( \^,
    "rws-element ^ rws-element",
    IsIdenticalObj,
    [ IsMultiplicativeElementWithInverseByRws,
      IsMultiplicativeElementWithInverseByRws ],
    0,

function( left, right )
    local   fam;

    fam := FamilyObj(left);
    return ElementByRws( fam, ReducedConjugate( fam!.rewritingSystem,
        UnderlyingElement(left), UnderlyingElement(right) ) );
end );


#############################################################################
##
#M  <elm-by-rws> ^ <int>
##
InstallMethod( \^,
    "rws-element ^ int",
    [ IsMultiplicativeElementWithInverseByRws,
      IsInt ],
function( left, right )
    local   fam;

    fam := FamilyObj(left);
    return ElementByRws( fam, ReducedPower( fam!.rewritingSystem,
        UnderlyingElement(left), right ) );
end );


#############################################################################
##
#M  <elm-by-rws> = <elm-by-rws>
##
InstallMethod( \=,
    IsIdenticalObj,
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
    IsIdenticalObj,
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

    # create the default type for the elements
    fam!.defaultType := NewType( fam, IsPackedElementDefaultRep );

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
InstallMethod( GroupByRwsNC,"rewriting system", true,
    [ IsRewritingSystem and IsBuiltFromGroup ], 100,

function( rws )
    local   pows,conjs,fam,  gens,  g,  id,  grp,defpcgs,i;

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
    grp := GroupByGenerators( gens, id );

    # it is the whole family
    SetIsWholeFamily( grp, true );

    # check the true methods
    if HasIsFinite( rws ) then
      SetIsFinite( grp, IsFinite( rws ) );
    fi;
    if IsPolycyclicCollector( rws ) then
      defpcgs:=DefiningPcgs( ElementsFamily(FamilyObj(grp)) );
      SetFamilyPcgs( grp, defpcgs);
      SetHomePcgs( grp, defpcgs);
      SetGroupOfPcgs(defpcgs,grp);
      if HasIsFiniteOrdersPcgs(defpcgs) and IsFiniteOrdersPcgs(defpcgs) then
        SetSize(grp,Product(RelativeOrders(defpcgs)));
        if HasRelativeOrders(rws)
           and not ForAll(RelativeOrders(rws),IsPrimeInt) then
           Info(InfoWarning,1,
            "You are creating a Pc group with non-prime relative orders.");
           Info(InfoWarning,1,
            "Many algorithms require prime relative orders.");
           Info(InfoWarning,1,"Use `RefinedPcGroup' to convert.");
        fi;
      fi;

      if IsSingleCollectorRep(rws) then
        pows:=rws![SCP_POWERS];
        conjs:=rws![SCP_CONJUGATES];
        for i in [1..Length(pows)] do
          if IsBound(pows[i]) then
            # this certainly could be done better, if one knew more about rws
            # than I do. AH
            defpcgs!.powers[i]:=ExponentsOfPcElement(defpcgs,
                                  ElementByRws(fam,pows[i]));
          else
            defpcgs!.powers[i]:=defpcgs!.zeroVector;
          fi;
        od;
        for pows in [1..Length(conjs)] do
          for i in [1..Length(conjs[pows])] do
            if IsBound(conjs[pows][i]) then
            # this certainly could be done better, if one knew more about rws
            # than I do. AH
              defpcgs!.conjugates[pows][i]:=ExponentsOfPcElement(defpcgs,
                                              ElementByRws(fam,conjs[pows][i]));
            else
              defpcgs!.conjugates[pows][i]:=ExponentsOfPcElement(defpcgs,
                                              defpcgs[pows]);
            fi;
          od;
        od;
      fi;

    fi;

    # that's it
    return grp;

end );
