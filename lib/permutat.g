#############################################################################
##
#W  permutat.g                   GAP library                    Thomas Breuer
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file deals with permutations.
##
Revision.permutat_g :=
    "@(#)$Id$";


#############################################################################
##

#C  IsPerm  . . . . . . . . . . . . . . . . . . . .  category of permutations
##
IsPerm := NewCategoryKernel( "IsPerm",
    IsMultiplicativeElementWithInverse and IsAssociativeElement and
        IsFiniteOrderElement,
    IS_PERM );


#############################################################################
##
#C  IsPermCollection  . . . . . . . . . . . . . .  collection of permutations
##
IsPermCollection := CategoryCollections( IsPerm );


#############################################################################
##

#A  SmallestMovedPointPerm( <perm> )  . . . . . . . . . . . .  smallest point
##
SmallestMovedPointPerm := NewAttribute( "SmallestMovedPointPerm", IsPerm );


#############################################################################
##
#A  LargestMovedPointPerm( <perm> ) . . . . . . . . . . . . . . largest point
##
LargestMovedPointPerm := NewAttribute( "LargestMovedPointPerm", IsPerm );


#############################################################################
##
#A  NrMovedPointsPerm( <perm> ) . . . . . . . . . . .  number of moved points
##
NrMovedPointsPerm := NewAttribute( "NrMovedPointsPerm", IsPerm );


#############################################################################
##
#A  CycleStructurePerm( <perm> )  . . . . . . . . . . . . . . cycle structure
##
CycleStructurePerm := NewAttribute( "CycleStructurePerm", IsPerm );


#############################################################################
##

#R  IsPerm2Rep  . . . . . . . . . . . . . .  permutation with 2 bytes entries
##
IsPerm2Rep := NewRepresentation( "IsPerm2Rep", IsInternalRep, [] );


#############################################################################
##
#R  IsPerm4Rep  . . . . . . . . . . . . . .  permutation with 4 bytes entries
##
IsPerm4Rep := NewRepresentation( "IsPerm4Rep", IsInternalRep, [] );


#############################################################################
##

#V  PermutationsFamily  . . . . . . . . . . . . .  family of all permutations
##
PermutationsFamily := NewFamily( "PermutationsFamily", IsPerm );


#############################################################################
##
#V  TYPE_PERM2  . . . . . . . . . .  type of permutation with 2 bytes entries
##
TYPE_PERM2 := NewType( PermutationsFamily, IsPerm and IsPerm2Rep );


#############################################################################
##
#V  TYPE_PERM4  . . . . . . . . . .  type of permutation with 4 bytes entries
##
TYPE_PERM4 := NewType( PermutationsFamily, IsPerm and IsPerm4Rep );


#############################################################################
##
#V  One . . . . . . . . . . . . . . . . . . . . . . . . .  one of permutation
##
SetOne( PermutationsFamily, () );


#############################################################################
##

#F  ListPerm( <perm> )  . . . . . . . . . . . . . . . . . . .  list of images
##
ListPerm := function( perm )
    local lst, i;
    lst:= [];
    for i in [ 1 .. LargestMovedPointPerm( perm ) ] do
      lst[i]:= i ^ perm;
    od;
    return lst;
end;


#############################################################################
##
#F  RestrictedPerm(<g>,<D>)  restriction of a permutation to an invariant set
##
RestrictedPerm := function( g, D )
    local   res, d, e, max;

    # check the arguments
    if not IsPerm( g )  then
        Error("<g> must be a permutation");
    elif not IsList( D )  then
        Error("<D> must be a list");
    fi;

    # special case for the identity
    if g = ()  then return ();  fi;

    # compute the largest point that we must consider
    max := 1;
    for d  in D  do
        e := d ^ g;
        if d <> e  and max < d  then
            max := d;
        fi;
    od;

    # compute the restricted permutation <res>
    res := [ 1 .. max ];
    for d  in D  do
        e := d ^ g;
        if d <= max  then
            res[d] := e;
        fi;
    od;

    # return the restricted permutation <res>
    return PermList( res );
end;


#############################################################################
##
#F  MappingPermListList(<src>,<dst>)  permutation mapping one list to another
##
MappingPermListList := function( src, dst )

    if not IsList(src) or not IsList(dst) or Length(src) <> Length(dst)  then
       Error("usage: MappingPermListList( <lst1>, <lst2> )");
    fi;

    if IsEmpty( src )  then
        return ();
    fi;

    src := Concatenation( src, Difference( [1..Maximum(src)], src ) );
    dst := Concatenation( dst, Difference( [1..Maximum(dst)], dst ) );

    return LeftQuotient( PermList( src ), PermList( dst ) );
end;


#############################################################################
##

#M  SmallestMovedPointPerm( <perm> )  . . . . . . . . . . .  for permutations
##
InstallMethod( SmallestMovedPointPerm,
    "method for a permutation",
    true,
    [ IsPerm ], 0,
    function( p )
    local   i;
    
    if IsOne(p)  then
        return infinity;
    fi;
    i := 1;
    while i ^ p = i  do
        i := i + 1;
    od;
    return i;
end );


#############################################################################
##
#M  LargestMovedPointPerm( <perm> ) . . . . . . . .  for internal permutation
##
InstallMethod( LargestMovedPointPerm,
    "method for an internal permutation",
    true,
    [ IsPerm and IsInternalRep ], 0,
    LARGEST_MOVED_POINT_PERM );


#############################################################################
##
#M  NrMovedPointsPerm( <perm> ) . . . . . . . . . . . . . . . for permutation
##
InstallMethod( NrMovedPointsPerm,
    "method for a permutation",
    true,
    [ IsPerm ], 0,
    function( perm )
    local mov, pnt;
    mov:= 0;
    if perm <> () then
      for pnt in [ SmallestMovedPointPerm( perm )
                   .. LargestMovedPointPerm( perm ) ] do
        if pnt ^ perm <> pnt then
          mov:= mov + 1;
        fi;
      od;
    fi;
    return mov;
    end );


#############################################################################
##
#M  CycleStructurePerm( <perm> )  . . . . . . . . .  length of cycles of perm
##
InstallMethod( CycleStructurePerm,
    "default method",
    true,
    [ IsPerm ],
    0,

function ( perm )
    local   cys,    # collected cycle lengths, result
            degree, # degree of perm
            mark,   # boolean list to mark elements already processed
            i,j,    # loop variables 
            len,    # length of a cycle 
            cyc;    # a cycle of perm

    if IsOne(perm) then
        cys := [];
    else
        degree := LargestMovedPointPerm(perm);
        mark := BlistList([1..degree], []);
        cys := [];
        for i in [1..degree] do
            if not mark[i] then 
               cyc := CyclePermInt( perm, i );
               len := Length(cyc) - 1;
               if 0 < len  then
                  if IsBound(cys[len])  then
                     cys[len] := cys[len]+1;
                  else
                     cys[len] := 1;
                  fi;
               fi;
               for j in cyc do
                  mark[j] := true;
               od;
            fi;
        od;
    fi;
    return cys;
end );


#############################################################################
##
#M  String( <perm> )  . . . . . . . . . . . . . . . . . . . for a permutation
##
InstallMethod( String,
    "method for a permutation",
    true,
    [ IsPerm ], 0,
    function( perm )
    local   str,  i,  j;

    if IsOne( perm ) then
        str := "()";
    else
        str := "";
        for i  in [ 1 .. LargestMovedPointPerm( perm ) ]  do
            j := i ^ perm;
            while j > i  do j := j ^ perm;  od;
            if j = i and i ^ perm <> i  then
                Append( str, "(" );
                Append( str, String( i ) );
                j := i ^ perm;
                while j > i do
                    Append( str, "," );
                    Append( str, String( j ) );
                    j := j ^ perm;
                od;
                Append( str, ")" );
            fi;
        od;
        ConvertToStringRep( str );
    fi;
    return str;
    end );


#############################################################################
##

#E  permutat.g	. . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
