#############################################################################
##
#W  permutat.g                   GAP library                    Thomas Breuer
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file deals with permutations.
##
Revision.permutat_g :=
    "@(#)$Id$";


#############################################################################
##
#C  IsPerm(<obj>)
##
DeclareCategoryKernel( "IsPerm",
    IsMultiplicativeElementWithInverse and IsAssociativeElement and
        IsFiniteOrderElement,
    IS_PERM );


#############################################################################
##
#C  IsPermCollection(<obj>)
##
##  is the category for collections of permutations.
##
DeclareCategoryCollections( "IsPerm" );



#############################################################################
##
#F  SmallestGeneratorPerm( <perm> )
##
##  returns  the smallest  permutation that generates the  same cyclic group
##  as the permutation   <p>. This is very efficient, even when <p> has
##  large order.

# DeclareGlobalFunction( "SmallestGeneratorPerm");


#############################################################################
##
#A  SmallestMovedPointPerm( <perm> )  . . . . . . . . . . . .  smallest point
##
##  returns the smallest integer that is moved by <perm>.
##
DeclareAttribute( "SmallestMovedPointPerm", IsPerm );


#############################################################################
##
#A  LargestMovedPointPerm( <perm> ) . . . . . . . . . . . . . . largest point
##
##  returns the largest integer that is moved by <perm>.
##
DeclareAttribute( "LargestMovedPointPerm", IsPerm );


#############################################################################
##
#A  NrMovedPointsPerm( <perm> ) . . . . . . . . . . .  number of moved points
##
##  returns the number of points that are moved by <perm>.
##
DeclareAttribute( "NrMovedPointsPerm", IsPerm );


#############################################################################
##
#A  SignPerm( <perm> )
##
##  The *sign* of a permutation is defined as $-1^k$ where $k$ is the number
##  of cycles of $k$ of even length.

# DeclareAttribute("SignPerm",IsPerm );


#############################################################################
##
#A  CycleStructurePerm( <perm> )  . . . . . . . . . . . . . . cycle structure
##
##  returns the cycle structure (i.e. the numbers of cycles of different
##  lengths) of <perm>. This is encoded in a list <l> in the following form:
##  The <i>-th entry of <l> contains the number of cycles of <perm> of
##  length <i+1>. If <perm> contains no cycles of length <i+1> it is not
##  bound.
##  Cycles of length 1 are ignored.
##
DeclareAttribute( "CycleStructurePerm", IsPerm );


#############################################################################
##
#R  IsPerm2Rep  . . . . . . . . . . . . . .  permutation with 2 bytes entries
##
DeclareRepresentation( "IsPerm2Rep", IsInternalRep, [] );


#############################################################################
##
#R  IsPerm4Rep  . . . . . . . . . . . . . .  permutation with 4 bytes entries
##
DeclareRepresentation( "IsPerm4Rep", IsInternalRep, [] );


#############################################################################
##
#V  PermutationsFamily  . . . . . . . . . . . . .  family of all permutations
##
##  is the family of all permutations.
##
PermutationsFamily := NewFamily( "PermutationsFamily", IsPerm );


#############################################################################
##
#V  TYPE_PERM2  . . . . . . . . . .  type of permutation with 2 bytes entries
##
BIND_GLOBAL( "TYPE_PERM2",
    NewType( PermutationsFamily, IsPerm and IsPerm2Rep ) );


#############################################################################
##
#V  TYPE_PERM4  . . . . . . . . . .  type of permutation with 4 bytes entries
##
BIND_GLOBAL( "TYPE_PERM4",
    NewType( PermutationsFamily, IsPerm and IsPerm4Rep ) );


#############################################################################
##
#V  One . . . . . . . . . . . . . . . . . . . . . . . . .  one of permutation
##
SetOne( PermutationsFamily, () );


#############################################################################
##
#F  PermList( <list> )
##
##  returns the permutation <perm>  that moves points as described by the
##  list <list>.  That means that  `<i>^<perm>  = <list>[<i>]' if  <i> lies
##  between 1 and the length of <list>, and `<i>^<perm> = <i>' if <i> is
##  larger than  the length of  the list <list>. It will  signal an  error
##  if <list> does  not define a permutation,  i.e., if <list> is  not a
##  list of integers  without holes, or  if <list> contains  an  integer
##  twice, or if <list> contains an integer not in the range
##  `[1..Length(<list>)]'.

# DeclareGlobalFunction("PermList");

#############################################################################
##
#F  ListPerm( <perm> )  . . . . . . . . . . . . . . . . . . .  list of images
##
##  returns a list <list> that contains the images of the positive integers
##  under the permutation   <perm>. That means that  `<list>[<i>] =
##  <i>^<perm>',  where <i>  lies between 1   and the largest  point moved
##  by <perm> (see "LargestMovedPointPerm").
##
# DeclareGlobalFunction("ListPerm");

BIND_GLOBAL( "ListPerm", function( perm )
    local lst, i;
    lst:= [];
    for i in [ 1 .. LargestMovedPointPerm( perm ) ] do
      lst[i]:= i ^ perm;
    od;
    return lst;
end );


#############################################################################
##
#F  RestrictedPerm(<g>,<D>)  restriction of a permutation to an invariant set
##
##  `RestrictedPerm' returns  the new permutation <new>  that operates on the
##  points in the list <list> in the same  way as the permutation <perm>, and
##  that fixes those points that are not in <list>.  <list> must be a list of
##  positive integers  such that for each <i>  in <list> the image $i^{perm}$
##  is also in <list>, i.e., it must be the union of cycles of <perm>.
##
BIND_GLOBAL( "RestrictedPerm", function( g, D )
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
end );


#############################################################################
##
#F  MappingPermListList(<src>,<dst>)  permutation mapping one list to another
##
##  returns   a   permutation    <perm>  such   that
##  `<list1>[<i>]  ^ <perm> = <list2>[<i>]'.  <perm> fixes  all points larger
##  then the maximum  of the  entries in <list1>   and <list2>. If  there are
##  several     such    permutations,  it      is   not     specified   which
##  `MappingPermListList' returns.   <list1> and  <list2>  must  be  lists of
##  positive integers of the same length, and neither  may contain an element
##  twice.
BIND_GLOBAL( "MappingPermListList", function( src, dst )

    if not IsList(src) or not IsList(dst) or Length(src) <> Length(dst)  then
       Error("usage: MappingPermListList( <lst1>, <lst2> )");
    fi;

    if IsEmpty( src )  then
        return ();
    fi;

    src := Concatenation( src, Difference( [1..Maximum(src)], src ) );
    dst := Concatenation( dst, Difference( [1..Maximum(dst)], dst ) );

    return LeftQuotient( PermList( src ), PermList( dst ) );
end );


#############################################################################
##
#M  SmallestMovedPointPerm( <perm> )  . . . . . . . . . . .  for permutations
##
InstallMethod( SmallestMovedPointPerm,
    "for a permutation",
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
    "for an internal permutation",
    true,
    [ IsPerm and IsInternalRep ], 0,
    LARGEST_MOVED_POINT_PERM );


#############################################################################
##
#M  NrMovedPointsPerm( <perm> ) . . . . . . . . . . . . . . . for permutation
##
InstallMethod( NrMovedPointsPerm,
    "for a permutation",
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
    "for a permutation",
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
