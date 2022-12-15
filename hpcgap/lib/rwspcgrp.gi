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
##  This file   contains  the methods  for  groups  defined  by  a polycyclic
##  collector.
##


#############################################################################
##
#M  IsConfluent( <pc-group> )
##
InstallOtherMethod( IsConfluent,
    "for pc group",
    true,
    [ IsPcGroup ],
    0,

function( g )
    local   gens,  fam,  exps,  R,  R1,  k,  gk,  j,  gj,  i,  gi,  r;

    gens := GeneratorsOfGroup(g);
    fam  := ElementsFamily(FamilyObj(g));
    exps := fam!.rewritingSystem![SCP_RELATIVE_ORDERS];

    # be verbose for debugging
    Info( InfoTiming + InfoConfluence, 2,
          "'IsConfluent' starting part 1" );
    R := Runtime();  R1 := R;

    # Consistency relations: gk * ( gj * gi ) = ( gk * gj ) * gi
    for k  in [ 1 .. Length(gens) ]  do
        gk := gens[k];
        for j  in [ 1 .. k-1 ]  do
            gj := gens[j];
            for i  in [ 1 .. j-1 ]  do
                gi := gens[i];
                r  := [ gk * ( gj * gi ), ( gk * gj ) * gi ];
                if r[1] <> r[2]  then
                    return false;
                fi;
            od;
        od;
    od;

    # be verbose for debugging
    Info( InfoTiming + InfoConfluence, 2,
          "'IsConfluent' part 1 took ", Runtime()-R, " ms, ",
          "starting part 2" );
    R := Runtime();

    # Consistency relations: gj^ej-1 * ( gj * gi ) = ( gj^ej-1 * gj ) * gi
    for j  in [ 1 .. Length(gens) ]  do
        gj := gens[j];
        for i  in [ 1 .. j-1 ]  do
            gi := gens[i];
            r  := [ gj^(exps[j]-1)*(gj*gi), (gj^(exps[j]-1)*gj)*gi ];
            if r[1] <> r[2]  then
                return false;
            fi;
        od;
    od;

    # be verbose for debugging
    Info( InfoTiming + InfoConfluence, 2,
          "'IsConfluent' part 2 took ", Runtime()-R, " ms, ",
          "'IsConfluent' starting part 3" );
    R := Runtime();

    # Consistency relations: gj * ( gi^ei-1 * gi ) = ( gj * gi^ei-1 ) * gi
    for j  in [ 1 .. Length( gens ) ]  do
        gj := gens[j];
        for i  in [ 1 .. j-1 ]  do
            gi := gens[i];
            r := [ gj*(gi^(exps[i]-1)*gi), (gj*gi^(exps[i]-1))*gi ];
            if r[1] <> r[2]  then
                return false;
            fi;
        od;
    od;

    # be verbose for debugging
    Info( InfoTiming + InfoConfluence, 2,
          "'IsConfluent' part 3 took ", Runtime()-R, " ms, ",
          "'IsConfluent' starting part 4" );
    R := Runtime();

    # Consistency relations: gi * ( gi^ei-1 * gi ) = ( gi * gi^ei-1 ) * gi
    for i  in [ 1 .. Length(gens) ]  do
        gi := gens[ i ];
        r := [ gi*(gi^(exps[i]-1)*gi), (gi*gi^(exps[i]-1))*gi ];
        if r[1] <> r[2]  then
            return false;
        fi;
    od;
    Info( InfoTiming + InfoConfluence, 2,
          "'IsConfluent' part 4 took, ", Runtime()-R, " ms" );
    Info( InfoTiming + InfoConfluence, 1,
          "'IsConfluent' took ", Runtime()-R1, " ms" );

    # Report if one check failed and <all> was set.
    return true;

end );


#############################################################################
##
#M  MultiplicativeElementsWithInversesFamilyByRws( <rws> )
##
InstallMethod( MultiplicativeElementsWithInversesFamilyByRws,
    "generic method",
    true,
    [ IsPolycyclicCollector ],
    0,

function( rws )
    local   fam,  pcs, implied;

    implied:=IsObject;

# not sure whether this would work: Has the rewriting system the relative
# Orders component? (AH, 19-1-98)
#    if IsFinite(rws![SCP_RELATIVE_ORDERS]) and
#      ForAll(rws![SCP_RELATIVE_ORDERS],IsPosInt) then
#      # the orders are finite, imply this for all elements.
#      implied:=implied and IsElementFinitePolycyclicGroup;
#    fi;

    # create a new family in the category <IsElementsFamilyByRws>
    fam := NewFamily(
      "MultiplicativeElementsWithInversesFamilyByPolycyclicCollector(...)",
      IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsAssociativeElement,
      CanEasilySortElements and implied,
      CanEasilySortElements and IsElementsFamilyByRws );

    # create the default type for the elements
    fam!.defaultType := NewType( fam, IsPackedElementDefaultRep );

    # store the identity
    SetOne( fam, ElementByRws( fam, ReducedOne(rws) ) );

    # store the rewriting system
    UpdatePolycyclicCollector(rws);
    fam!.rewritingSystem := Immutable(rws);

    # this family has a defining pcgs
    pcs := List( GeneratorsOfRws(rws), x -> ElementByRws(fam,x) );
    SetDefiningPcgs( fam, PcgsByPcSequenceNC( fam, pcs ) );

    # that's it
    return fam;

end );


#############################################################################
##
#R  IsNBitsPcWordRep
##
DeclareRepresentation(
    "IsNBitsPcWordRep",
    IsDataObjectRep, [] );


#############################################################################
##
#M  PrintObj( <IsNBitsPcWordRep> )
##
InstallMethod( PrintObj,"pcword", true,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsNBitsPcWordRep ],
    0,

function( obj )
    local   names,  word,  len,  i;

    names := TypeObj(obj)![PCWP_NAMES];
    word  := ExtRepOfObj(obj);
    len   := Length(word) - 1;
    if len < 0 then
        Print( "<identity> of ..." );
    else
        i := 1;
        while i < len do
            Print( names[ word[i] ] );
            if word[i+1] <> 1 then
                Print( "^", word[i+1] );
            fi;
            Print( "*" );
            i := i+2;
        od;
        Print( names[word[i]] );
        if word[i+1] <> 1 then
            Print( "^", word[ i+1 ] );
        fi;
    fi;
end );

#############################################################################
##
#M  String( <IsNBitsPcWordRep> )
##
InstallMethod( String,"pcword",true,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsNBitsPcWordRep ], 0,
function( obj )
local   names,  word,  len,  i,s;

    names := TypeObj(obj)![PCWP_NAMES];
    word  := ExtRepOfObj(obj);
    len   := Length(word) - 1;
    if len < 0 then
        return "<identity> of ...";
    else
        s:="";
        i := 1;
        while i < len do
            Append(s,names[ word[i] ]);
            if word[i+1] <> 1 then
                Add(s,'^');
                Append(s, String(word[i+1]) );
            fi;
            Add(s,'*');
            i := i+2;
        od;
        Append(s,names[word[i]] );
        if word[i+1] <> 1 then
            Add(s,'^');
            Append(s,String(word[ i+1 ]));
        fi;
    fi;
    return s;
end );


#############################################################################
##
#M  InverseOp( <IsNBitsPcWordRep> )
##
InstallMethod( InverseOp,
    "generic method for n bits pc word rep",
    true,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsNBitsPcWordRep ],
    0,

function( obj )
    return FinPowConjCol_ReducedPowerSmallInt(
        TypeObj(obj)![PCWP_COLLECTOR], obj, -1 );
end );


#############################################################################
##
#M  Comm( <IsNBitsPcWordRep>, <IsNBitsPcWordRep> )
##
InstallMethod( Comm,
    "generic method for n bits pc word rep",
    IsIdenticalObj,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsNBitsPcWordRep,
      IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsNBitsPcWordRep ],
    0,
function( left, right )
    return FinPowConjCol_ReducedComm( TypeObj(left)![PCWP_COLLECTOR], left, right );
end );


#############################################################################
##
#M  LeftQuotient( <IsNBitsPcWordRep>, <IsNBitsPcWordRep> )
##
InstallMethod( LeftQuotient,
    "generic method for n bits pc word rep",
    IsIdenticalObj,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsNBitsPcWordRep,
      IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsNBitsPcWordRep ],
    0,
function( left, right )
    return FinPowConjCol_ReducedLeftQuotient( TypeObj(left)![PCWP_COLLECTOR], left, right );
end );


#############################################################################
##
#M  <IsNBitsPcWordRep> / <IsNBitsPcWordRep>
##
InstallMethod( \/,
    "generic method for n bits pc word rep",
    IsIdenticalObj,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsNBitsPcWordRep,
      IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsNBitsPcWordRep ],
    0,
function( left, right )
    return FinPowConjCol_ReducedQuotient( TypeObj(left)![PCWP_COLLECTOR], left, right );
end );


#############################################################################
##
#M  <IsNBitsPcWordRep> * <IsNBitsPcWordRep>
##
InstallMethod( \*,
    "generic method for n bits pc word rep",
    IsIdenticalObj,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsNBitsPcWordRep,
      IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsNBitsPcWordRep ],
    0,
function( left, right )
    return FinPowConjCol_ReducedProduct( TypeObj(left)![PCWP_COLLECTOR], left, right );
end );


#############################################################################
##
#M  <IsNBitsPcWordRep> ^ <IsNBitsPcWordRep>
##
InstallMethod( \^,
    "generic method for n bits pc word rep",
    IsIdenticalObj,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsNBitsPcWordRep,
      IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsNBitsPcWordRep ],
    0,
function( left, right )
    left := FinPowConjCol_ReducedProduct(
                TypeObj(left)![PCWP_COLLECTOR], left, right );
    return FinPowConjCol_ReducedLeftQuotient(
                TypeObj(left)![PCWP_COLLECTOR], right, left );
end );


#############################################################################
##
#M  <IsNBitsPcWordRep> ^ <small-int>
##
InstallMethod( \^,
    "generic method for n bits pc word rep and small int",
    true,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsNBitsPcWordRep,
      IsInt and IsSmallIntRep ],
    0,
function( left, right )
    return FinPowConjCol_ReducedPowerSmallInt(
                TypeObj(left)![PCWP_COLLECTOR], left, right );
end );


#############################################################################
##
#R  Is8BitsPcWordRep
##
DeclareRepresentation(
    "Is8BitsPcWordRep",
    IsNBitsPcWordRep and IsKernelPcWord, [] );


#############################################################################
##
#M  MultiplicativeElementsWithInversesFamilyByRws( <8bits-sc> )
##
InstallMethod( MultiplicativeElementsWithInversesFamilyByRws,
    "8 bits family",
    true,
    [ IsPolycyclicCollector and IsFinite and Is8BitsSingleCollectorRep
          and IsDefaultRhsTypeSingleCollector
          and IsUpToDatePolycyclicCollector ],
    0,

function( sc )
    local   fam,  i,  pcs, implied;

    implied:=IsObject;

    if IsFinite(sc![SCP_RELATIVE_ORDERS]) and
      ForAll(sc![SCP_RELATIVE_ORDERS],IsPosInt) then
      # the orders are finite, imply this for all elements.
      implied:=implied and IsElementFinitePolycyclicGroup;
    fi;

    # create a new family in the category <IsElementsFamilyByRws>
    fam := NewFamily(
      "MultiplicativeElementsWithInversesFamilyBy8BitsSingleCollector(...)",
      IsMultiplicativeElementWithInverseByPolycyclicCollector
        and IsAssociativeElement,
      CanEasilySortElements and implied,
      CanEasilySortElements and IsElementsFamilyBy8BitsSingleCollector);

    # store the rewriting system
    fam!.rewritingSystem := MakeReadOnlyObj(sc);

    # create the default type for the elements
    fam!.defaultType := NewType( fam, IsPackedElementDefaultRep );

    # create the special 8 bits type
    fam!.8BitsType := NewType( fam, Is8BitsPcWordRep );

    # copy the assoc word type
    for i in [ AWP_FIRST_ENTRY+1 .. AWP_LAST_ENTRY ] do
      StrictBindOnce( fam!.8BitsType, i, sc![SCP_DEFAULT_TYPE]![i] );
    od;

    # default type to use
    StrictBindOnce( fam!.8BitsType, AWP_PURE_TYPE, fam!.8BitsType );

    # store the names
    StrictBindOnce( fam!.8BitsType, PCWP_NAMES, FamilyObj(ReducedOne(sc))!.names );

    # force the single collector to return elements of that type
    sc := ShallowCopy(sc);
    sc![SCP_DEFAULT_TYPE] := fam!.8BitsType;
    MakeReadOnlyObj(sc);
    StrictBindOnce( fam!.8BitsType, PCWP_COLLECTOR, sc );

    # store the identity
    SetOne( fam, ElementByRws( fam, ReducedOne(fam!.rewritingSystem) ) );

    # this family has a defining pcgs
    pcs := List( GeneratorsOfRws(sc), x -> ElementByRws(fam,x) );
    SetDefiningPcgs( fam, PcgsByPcSequenceNC( fam, pcs ) );

    # that's it
    return fam;

end );


#############################################################################
##
#M  ElementByRws( <fam>, <elm> )
##
InstallMethod( ElementByRws,
    "using 8Bits_AssocWord",
    true,
    [ IsElementsFamilyBy8BitsSingleCollector,
      Is8BitsAssocWord ],
    0,

function( fam, elm )
    return 8Bits_AssocWord( fam!.8BitsType, ExtRepOfObj(elm) );
end );


#############################################################################
##
#M  UnderlyingElement( <Is8BitsPcWordRep> )
##
InstallMethod( UnderlyingElement,
    "using 8Bits_ExtRepOfObj",
    true,
    [ Is8BitsPcWordRep ],
    0,

function( obj )
    local   fam;

    fam := UnderlyingFamily( FamilyObj(obj)!.rewritingSystem );
    return ObjByExtRep( fam, 8Bits_ExtRepOfObj(obj) );
end );

#############################################################################
##
#M  ExtRepOfObj( <Is8BitsPcWordRep> )
##
InstallMethod( ExtRepOfObj,
    "using 8Bits_ExtRepOfObj",
    true,
    [ Is8BitsPcWordRep ],
    0,
    8Bits_ExtRepOfObj );


#############################################################################
##
#M  ObjByExtRep( <fam>, <elm> )
##
InstallMethod( ObjByExtRep,
    "using 8Bits_AssocWord",
    true,
    [ IsElementsFamilyBy8BitsSingleCollector,
      IsList ],
    0,

function( fam, elm )
    return 8Bits_AssocWord( fam!.8BitsType, elm );
end );


#############################################################################
##
#M  <Is8BitsPcWordRep> = <Is8BitsPcWordRep>
##
InstallMethod( \=,
    "for 8 bits pc word rep",
    IsIdenticalObj,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and Is8BitsPcWordRep,
      IsMultiplicativeElementWithInverseByPolycyclicCollector
        and Is8BitsPcWordRep ],
    0,
    8Bits_Equal );


#############################################################################
##
#M  <Is8BitsPcWordRep> < <Is8BitsPcWordRep>
##
InstallMethod( \<,
    "method for 8 bits pc word rep",
    IsIdenticalObj,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and Is8BitsPcWordRep,
      IsMultiplicativeElementWithInverseByPolycyclicCollector
        and Is8BitsPcWordRep ],
    0,
    8Bits_Less );


#############################################################################
##
#R  Is16BitsPcWordRep
##
DeclareRepresentation(
    "Is16BitsPcWordRep",
    IsNBitsPcWordRep and IsKernelPcWord, [] );


#############################################################################
##
#M  MultiplicativeElementsWithInversesFamilyByRws( <16bits-sc> )
##
InstallMethod( MultiplicativeElementsWithInversesFamilyByRws,
    "16 bits family",
    true,
    [ IsPolycyclicCollector and IsFinite and Is16BitsSingleCollectorRep
          and IsDefaultRhsTypeSingleCollector
          and IsUpToDatePolycyclicCollector ],
    0,

function( sc )
    local   fam,  i,  pcs, implied;

    implied:=IsObject;

    if IsFinite(sc![SCP_RELATIVE_ORDERS]) and
      ForAll(sc![SCP_RELATIVE_ORDERS],IsPosInt) then
      # the orders are finite, imply this for all elements.
      implied:=implied and IsElementFinitePolycyclicGroup;
    fi;

    # create a new family in the category <IsElementsFamilyByRws>
    fam := NewFamily(
      "MultiplicativeElementsWithInversesFamilyBy16BitsSingleCollector(...)",
      IsMultiplicativeElementWithInverseByPolycyclicCollector
      and IsAssociativeElement,
      CanEasilySortElements and implied,
      CanEasilySortElements and IsElementsFamilyBy16BitsSingleCollector);

    # store the rewriting system
    fam!.rewritingSystem := MakeReadOnlyObj(sc);

    # create the default type for the elements
    fam!.defaultType := NewType( fam, IsPackedElementDefaultRep );

    # create the special 16 bits type
    fam!.16BitsType := NewType( fam, Is16BitsPcWordRep );

    # copy the assoc word type
    for i in [ AWP_FIRST_ENTRY+1 .. AWP_LAST_ENTRY ] do
          StrictBindOnce( fam!.16BitsType, i, sc![SCP_DEFAULT_TYPE]![i] );
    od;

    # default type to use
    StrictBindOnce( fam!.16BitsType, AWP_PURE_TYPE, fam!.16BitsType );

    # store the names
    StrictBindOnce( fam!.16BitsType, PCWP_NAMES, FamilyObj(ReducedOne(sc))!.names );

    # force the single collector to return elements of that type
    sc := ShallowCopy(sc);
    sc![SCP_DEFAULT_TYPE] := fam!.16BitsType;
    MakeReadOnlyObj(sc);
    StrictBindOnce( fam!.16BitsType, PCWP_COLLECTOR, sc );

    # store the identity
    SetOne( fam, ElementByRws( fam, ReducedOne(fam!.rewritingSystem) ) );

    # this family has a defining pcgs
    pcs := List( GeneratorsOfRws(sc), x -> ElementByRws(fam,x) );
    SetDefiningPcgs( fam, PcgsByPcSequenceNC( fam, pcs ) );

    # that's it
    return fam;

end );


#############################################################################
##
#M  ElementByRws( <fam>, <elm> )
##
InstallMethod( ElementByRws,
    "using 16Bits_AssocWord",
    true,
    [ IsElementsFamilyBy16BitsSingleCollector,
      Is16BitsAssocWord ],
    0,

function( fam, elm )
    return 16Bits_AssocWord( fam!.16BitsType, ExtRepOfObj(elm) );
end );


#############################################################################
##
#M  UnderlyingElement( <Is16BitsPcWordRep> )
##
InstallMethod( UnderlyingElement,
    "using 16Bits_ExtRepOfObj",
    true,
    [ Is16BitsPcWordRep ],
    0,

function( obj )
    local   fam;

    fam := UnderlyingFamily( FamilyObj(obj)!.rewritingSystem );
    return ObjByExtRep( fam, 16Bits_ExtRepOfObj(obj) );
end );

#############################################################################
##
#M  ExtRepOfObj( <Is16BitsPcWordRep> )
##
InstallMethod( ExtRepOfObj,
    "using 16Bits_ExtRepOfObj",
    true,
    [ Is16BitsPcWordRep ],
    0,
    16Bits_ExtRepOfObj );


#############################################################################
##
#M  ObjByExtRep( <fam>, <elm> )
##
InstallMethod( ObjByExtRep,
    "using 16Bits_AssocWord",
    true,
    [ IsElementsFamilyBy16BitsSingleCollector,
      IsList ],
    0,

function( fam, elm )
    return 16Bits_AssocWord( fam!.16BitsType, elm );
end );


#############################################################################
##
#M  <Is16BitsPcWordRep> = <Is16BitsPcWordRep>
##
InstallMethod( \=,
    "for 16 bits pc word rep",
    IsIdenticalObj,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and Is16BitsPcWordRep,
      IsMultiplicativeElementWithInverseByPolycyclicCollector
        and Is16BitsPcWordRep ],
    0,
    16Bits_Equal );


#############################################################################
##
#M  <Is16BitsPcWordRep> < <Is16BitsPcWordRep>
##
InstallMethod( \<,
    "for 16 bits pc word rep",
    IsIdenticalObj,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and Is16BitsPcWordRep,
      IsMultiplicativeElementWithInverseByPolycyclicCollector
        and Is16BitsPcWordRep ],
    0,
    16Bits_Less );


#############################################################################
##
#R  Is32BitsPcWordRep
##
DeclareRepresentation(
    "Is32BitsPcWordRep",
    IsNBitsPcWordRep and IsKernelPcWord, [] );


#############################################################################
##
#M  MultiplicativeElementsWithInversesFamilyByRws( <32bits-sc> )
##
InstallMethod( MultiplicativeElementsWithInversesFamilyByRws,
    "32 bits family",
    true,
    [ IsPolycyclicCollector and IsFinite and Is32BitsSingleCollectorRep
          and IsDefaultRhsTypeSingleCollector
          and IsUpToDatePolycyclicCollector ],
    0,

function( sc )
    local   fam,  i,  pcs, implied;

    implied:=IsObject;

    if IsFinite(sc![SCP_RELATIVE_ORDERS]) and
      ForAll(sc![SCP_RELATIVE_ORDERS],IsPosInt) then
      # the orders are finite, imply this for all elements.
      implied:=implied and IsElementFinitePolycyclicGroup;
    fi;

    # create a new family in the category <IsElementsFamilyByRws>
    fam := NewFamily(
      "MultiplicativeElementsWithInversesFamilyBy32BitsSingleCollector(...)",
      IsMultiplicativeElementWithInverseByPolycyclicCollector
      and IsAssociativeElement,
      CanEasilySortElements and implied,
      CanEasilySortElements and IsElementsFamilyBy32BitsSingleCollector);

    # store the rewriting system
    fam!.rewritingSystem := MakeReadOnlyObj(sc);

    # create the default type for the elements
    fam!.defaultType := NewType( fam, IsPackedElementDefaultRep );

    # create the special 32 bits type
    fam!.32BitsType := NewType( fam, Is32BitsPcWordRep );

    # copy the assoc word type
    for i in [ AWP_FIRST_ENTRY+1 .. AWP_LAST_ENTRY ] do
      StrictBindOnce( fam!.32BitsType, i, sc![SCP_DEFAULT_TYPE]![i] );
    od;

    # default type to use
    StrictBindOnce( fam!.32BitsType, AWP_PURE_TYPE, fam!.32BitsType );

    # store the names
    StrictBindOnce( fam!.32BitsType, PCWP_NAMES, FamilyObj(ReducedOne(sc))!.names );

    # force the single collector to return elements of that type
    sc := ShallowCopy(sc);
    sc![SCP_DEFAULT_TYPE] := fam!.32BitsType;
    MakeReadOnlyObj(sc);
    StrictBindOnce( fam!.32BitsType, PCWP_COLLECTOR, sc );

    # store the identity
    SetOne( fam, ElementByRws( fam, ReducedOne(fam!.rewritingSystem) ) );

    # this family has a defining pcgs
    pcs := List( GeneratorsOfRws(sc), x -> ElementByRws(fam,x) );
    SetDefiningPcgs( fam, PcgsByPcSequenceNC( fam, pcs ) );

    # that's it
    return fam;

end );


#############################################################################
##
#M  ElementByRws( <fam>, <elm> )
##
InstallMethod( ElementByRws,
    "using 32Bits_AssocWord",
    true,
    [ IsElementsFamilyBy32BitsSingleCollector,
      Is32BitsAssocWord ],
    0,

function( fam, elm )
    return 32Bits_AssocWord( fam!.32BitsType, ExtRepOfObj(elm) );
end );


#############################################################################
##
#M  UnderlyingElement( <Is32BitsPcWordRep> )
##
InstallMethod( UnderlyingElement,
    "using 16Bits_ExtRepOfObj",
    true,
    [ Is32BitsPcWordRep ],
    0,

function( obj )
    local   fam;

    fam := UnderlyingFamily( FamilyObj(obj)!.rewritingSystem );
    return ObjByExtRep( fam, 32Bits_ExtRepOfObj(obj) );
end );

#############################################################################
##
#M  ExtRepOfObj( <Is32BitsPcWordRep> )
##
InstallMethod( ExtRepOfObj,
    "using 32Bits_ExtRepOfObj",
    true,
    [ Is32BitsPcWordRep ],
    0,
    32Bits_ExtRepOfObj );


#############################################################################
##
#M  ObjByExtRep( <fam>, <elm> )
##
InstallMethod( ObjByExtRep,
    "using 32Bits_AssocWord",
    true,
    [ IsElementsFamilyBy32BitsSingleCollector,
      IsList ],
    0,

function( fam, elm )
    return 32Bits_AssocWord( fam!.32BitsType, elm );
end );


#############################################################################
##
#M  <Is32BitsPcWordRep> = <Is32BitsPcWordRep>
##
InstallMethod( \=,
    "for 32 bits pc word rep",
    IsIdenticalObj,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and Is32BitsPcWordRep,
      IsMultiplicativeElementWithInverseByPolycyclicCollector
        and Is32BitsPcWordRep ],
    0,
    32Bits_Equal );


#############################################################################
##
#M  <Is32BitsPcWordRep> < <Is32BitsPcWordRep>
##
InstallMethod( \<,
    "for 32 bits pc word rep",
    IsIdenticalObj,
    [ IsMultiplicativeElementWithInverseByPolycyclicCollector
        and Is32BitsPcWordRep,
      IsMultiplicativeElementWithInverseByPolycyclicCollector
        and Is32BitsPcWordRep ],
    0,
    32Bits_Less );


#############################################################################
##
#F  SingleCollector_GroupRelators( ... )
##
SingleCollector_GroupRelators := function(
    efam, gens, rods, powersp, powersn,
    commpp, commpn, commnp, commnn, conjpp,
    conjpn, conjnp, conjnn, conflicts )

    local   col,  i,  j,  rhs;

    # be verbose
    # Print( "#I  SingleCollector_GroupRelators: ", Length(Flat(powersp)),
    #        "/", Length(Flat(powersn)), " ", Length(Flat(commpp)), "/",
    #        Length(Flat(commpn)), "/", Length(Flat(commnp)), "/",
    #        Length(Flat(commnn)), " ", Length(Flat(conjpp)), "/",
    #        Length(Flat(conjpn)), "/", Length(Flat(conjnp)), "/",
    #        Length(Flat(conjnn)), " ", Length(conflicts), "\n" );

    # start with an empty single collector
    col := SingleCollectorByGenerators( efam, gens, rods );

    # we want to use positive powers first
    for i  in [ 1 .. Length(rods) ]  do
        if IsBound(powersp[i])  then
            SetPower( col, i, powersp[i]^-1 * gens[i]^rods[i] );
        fi;
    od;

    # we want to use positive conjugates/commutators first
    for i  in [ 1 .. Length(gens) ]  do
        for j  in [ 1 .. i-1 ]  do
            if IsBound(conjpp[i][j])  then
                rhs := ( (gens[i]^-1)^gens[j] * conjpp[i][j] ) ^ -1;
                SetConjugate( col, i, j, rhs );
                Unbind(conjpp[i][j]);
            elif IsBound(commpp[i][j])  then
                rhs := gens[i]*(Comm(gens[j],gens[i])*commpp[i][j])^-1;
                SetConjugate( col, i, j, rhs );
                Unbind(commpp[i][j]);
            elif IsBound(conjnp[i][j])  then
                rhs := gens[j]^-1*gens[i]*gens[j]*conjnp[i][j];
                SetConjugate( col, i, j, rhs );
                Unbind(conjnp[i][j]);
            elif IsBound(commnp[i][j])  then
                rhs := gens[i]^gens[j] * commnp[i][j]^gens[i];
                SetConjugate( col, i, j, rhs );
                Unbind(commnp[i][j]);
            fi;
        od;
    od;

    # everything must a consequence
    Append( conflicts, Flat(commpp)  );
    Append( conflicts, Flat(conjpp)  );
    Append( conflicts, Flat(powersn) );
    Append( conflicts, Flat(conjpn)  );
    Append( conflicts, Flat(conjnp)  );
    Append( conflicts, Flat(conjnn)  );
    Append( conflicts, Flat(commpn)  );
    Append( conflicts, Flat(commnp)  );
    Append( conflicts, Flat(commnn)  );

    # return the rewriting system
    return col;

end;

#############################################################################
##
#M  PolycyclicFactorGroupByRelators( <efam>, <gens>, <rels> )
##
InstallGlobalFunction( "SingleCollectorByRelators",
function( efam, gens, rels, conflicts )
    local   i,  r,  rel,  powersp,  powersn,  powlst,  commpp,
            commpn,  commnp,  commnn,  conjpp,  conjpn,  conjnp,
            conjnn,  n,  g1,  e1,  g2,  e2,  g3,  e3,  g4,
            e4,  rods,  col;

    # check the generators
    for i  in [ 1 .. Length(gens) ]  do
        if 1 <> NumberSyllables(gens[i])  then
            Error( gens[i], " must be a word of length 1" );
        elif 1 <> ExponentSyllable( gens[i], 1 )  then
            Error( gens[i], " must be a word of length 1" );
        elif i <> GeneratorSyllable( gens[i], 1 )  then
            Error( gens[i], " must be generator number ", i );
        fi;
    od;

    # first convert relations into relators
    r := [];
    for rel  in rels  do
        if IsList(rel)  then
            if 2 <> Length(rel)  then
                Error( rel, " is not a relation" );
            fi;
            AddSet( r, rel[1] / rel[2] );
        else
            AddSet( r, rel );
        fi;
    od;
    rels := r;

    # power relation
    powersp := [];
    powersn := [];
    powlst  := [];

    # commutator pos, pos
    commpp := List( gens, x -> [] );

    # commutator pos, neg
    commpn := List( gens, x -> [] );

    # commutator neg, pos
    commnp := List( gens, x -> [] );

    # commutator neg, neg
    commnn := List( gens, x -> [] );

    # conjugate pos, pos
    conjpp := List( gens, x -> [] );

    # conjugate pos, neg
    conjpn := List( gens, x -> [] );

    # conjugate neg, pos
    conjnp := List( gens, x -> [] );

    # conjugate neg, neg
    conjnn := List( gens, x -> [] );

    # conflicts is passed already as argument and is changed!
    # conflicts are collected in this list and tested later
    #conflicts := [];

    # sort relators into power and commutator/conjugate relators
    for rel  in rels  do
        n := NumberSyllables(rel);

        # a word with only one or two syllabel is a power
        if n = 1 or n = 2  then
            Add( powlst, rel );

        # ignore the trivial word
        elif 2 < n  then

            # extract the first four entries
            g1 := GeneratorSyllable( rel, 1 );
            e1 := ExponentSyllable(  rel, 1 );
            g2 := GeneratorSyllable( rel, 2 );
            e2 := ExponentSyllable(  rel, 2 );
            g3 := GeneratorSyllable( rel, 3 );
            e3 := ExponentSyllable(  rel, 3 );
            if 3 < n  then
                g4 := GeneratorSyllable( rel, 4 );
                e4 := ExponentSyllable( rel, 4 );
            fi;

            # a word starting with gi^-1gj^+-1gi is a conjugate or commutator
            if e1 = -1 and e3 = 1 and g1 = g3  then

                # gi^-1 gj^-1 gi gj is a commutator
                if 3<n and e2 = -1 and e4 = 1 and g2 = g4 and g2 < g1  then
                    if IsBound(commpp[g1][g2])  then
                        Add( conflicts, rel );
                    else
                        commpp[g1][g2] := rel;
                    fi;

                # gi^-1 gj^-1 gi is a conjugate
                elif e2 = -1 and g1 < g2  then
                    if IsBound(conjnp[g2][g1])  then
                        Add( conflicts, rel );
                    else
                        conjnp[g2][g1] := rel;
                    fi;

                # gi^-1 gj gi gj^-1 is a commutator
                elif 3<n and e2 = 1 and e4 = -1 and g2 = g4 and g2 < g1  then
                    if IsBound(commpn[g1][g2])  then
                        Add( conflicts, rel );
                    else
                        commpn[g1][g2] := rel;
                    fi;

                # gi^-1 gj gi is a conjugate
                elif e2 = 1 and g1 < g2  then
                    if IsBound(conjpp[g2][g1])  then
                        Add( conflicts, rel );
                    else
                        conjpp[g2][g1] := rel;
                    fi;

                # impossible
                else
                    Error( "illegal relator ", rel );
                fi;

            # a word starting with gigjgi^-1 is a conjugate or commutator
            elif e1 = 1 and e3 = -1 and g1 = g3  then

                # gi gj gi^-1 gj^-1 is a commutator
                if 3 < n and e2 = 1 and e4 = -1 and g2 = g4 and g2 < g1  then
                    if IsBound(commnn[g1][g2])  then
                        Add( conflicts, rel );
                    else
                        commnn[g1][g2] := rel;
                    fi;

                # gi gj gi^-1 is a conjugate
                elif e2 = 1 and g1 < g2  then
                    if IsBound(conjpn[g2][g1])  then
                        Add( conflicts, rel );
                    else
                        conjpn[g2][g1] := rel;
                    fi;

                # gi gj^-1 gi^-1 gj is a commutator
                elif 3<n and e2 = -1 and e4 = 1 and g2 = g4 and g2 < g1  then
                    if IsBound(commnp[g1][g2])  then
                        Add( conflicts, rel );
                    else
                        commnp[g1][g2] := rel;
                    fi;

                # gi gj^-1 gi^-1 gj is a conjugate
                elif e2 = -1 and g1 < g2  then
                    if IsBound(conjnp[g2][g1])  then
                        Add( conflicts, rel );
                    else
                        conjnp[g2][g1] := rel;
                    fi;

                # impossible
                else
                    Error( "illegal relator ", rel );
                fi;

            # it must be a power
            else
                Add( powlst, rel );
            fi;
        fi;
    od;

    # now check the powers
    rods := List( gens, x -> 0 );
    for rel  in powlst  do
        g1 := GeneratorSyllable( rel, 1 );
        e1 := ExponentSyllable(  rel, 1 );
        if rods[g1] <> 0  then
            if IsBound(powersp[g1])  then
                Add( conflicts, rel );
            else
                Add( conflicts, rel );
            fi;
        else
            rods[g1] := AbsInt(e1);
            if e1 < 0  then
                powersn[g1] := rel;
            else
                powersp[g1] := rel;
            fi;
        fi;
    od;

    # now decide which collector to use
    if ForAny( rods, x -> x = 0 )  then
        Error( "not ready yet, only finite polycyclic groups are allowed" );
    else
        col := SingleCollector_GroupRelators( efam, gens,
                   rods, powersp, powersn,
                   commpp, commpn, commnp, commnn, conjpp, conjpn,
                   conjnp, conjnn, conflicts );
    fi;

    return col;
end );

InstallMethod( PolycyclicFactorGroupByRelatorsNC,
    "generic method for family, generators, relators",
    true,
    [ IsFamily, IsList, IsList ], 0,
function( efam, gens, rels )
    local col;

    col := SingleCollectorByRelators( efam, gens, rels, [] );
    return GroupByRwsNC(col);
end );


InstallMethod( PolycyclicFactorGroupByRelators,
    "generic method for family, generators, relators",
    true,
    [ IsFamily, IsList, IsList ], 0,
function( efam, gens, rels )
    local  col,  conflicts,  e1,  rel;

    conflicts := [];
    col := SingleCollectorByRelators( efam, gens, rels, conflicts );

    # check that there are no conflicts between the relations
    e1 := ReducedOne(col);
    for rel  in conflicts  do
        if ReducedForm( col, rel ) <> e1  then
            Error( "relator ", rel, " is not trivial" );
        fi;
    od;

    # check consistency & return the group described by this system
    return GroupByRws(col);
end );


#############################################################################
##
#M  PolycyclicFactorGroup( <fgrp>, <rels> )
##


#############################################################################
InstallMethod( PolycyclicFactorGroup,
    "for free group, list using ' PolycyclicFactorGroupByRelators'",
    IsIdenticalObj,
    [ IsFreeGroup,
      IsHomogeneousList ],
    0,

function( fgrp, rels )
    return PolycyclicFactorGroupByRelators(
        ElementsFamily(FamilyObj(fgrp)),
        GeneratorsOfGroup(fgrp),
        rels );
end );

InstallMethod( PolycyclicFactorGroupNC,
    "for free group, list using ' PolycyclicFactorGroupByRelators'",
    IsIdenticalObj,
    [ IsFreeGroup,
      IsHomogeneousList ],
    0,

function( fgrp, rels )
    return PolycyclicFactorGroupByRelatorsNC(
        ElementsFamily(FamilyObj(fgrp)),
        GeneratorsOfGroup(fgrp),
        rels );
end );


#############################################################################
InstallMethod( PolycyclicFactorGroup,
    "for free group, empty list using ' PolycyclicFactorGroupByRelators'",
    true,
    [ IsFreeGroup,
      IsList and IsEmpty ],
    0,

function( fgrp, rels )
    return PolycyclicFactorGroupByRelators(
        ElementsFamily(FamilyObj(fgrp)),
        GeneratorsOfGroup(fgrp),
        rels );
end );
