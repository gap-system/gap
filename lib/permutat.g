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

#1
##  Internally, {\GAP}  stores a permutation as a  list of the  <d> images of
##  the  integers  $1,\ldots, d$,  where the ``internal  degree'' <d>  is the
##  largest integer moved by the permutation or bigger. When a permutation is
##  read  in  in  cycle  notation, <d> is  always  set  to  the largest moved
##  integer,   but a bigger   <d> can  result  from  a multiplication of  two
##  permutations, because the product is  not shortened if it fixes~<d>.  The
##  images are either all stored as 16-bit integers or all as 32-bit integers
##  (actually as {\GAP} immediate integers less  than $2^{28}$), depending on
##  whether  $d\le 65536$  or not. This  means that  the identity permutation
##  `()' takes $4<m>$ bytes if it was  calculated as  `(1, \dots, <m>) \* (1,
##  \dots, <m>)^-1'. It  can take even more  because the internal list  has
##  sometimes room for more than <d> images.  For example, the maximal degree
##  of   any permutation in  {\GAP}  is  $m  = 2^{22}-1024 =  4{,}193{,}280$,
##  because  bigger permutations  would have  an  internal list with room for
##  more than $2^{22}$ images, requiring  more than $2^{24}$~bytes. $2^{24}$,
##  however, is  the  largest possible size   of  an object that  the  {\GAP}
##  storage manager can deal with.
##
##  Permutations  do  not belong to  a specific group.   That means
##  that one can work  with permutations without defining a permutation group
##  that contains them.


#############################################################################
##
#C  IsPerm( <obj> )
##
DeclareCategoryKernel( "IsPerm",
    IsMultiplicativeElementWithInverse and IsAssociativeElement and
        IsFiniteOrderElement,
    IS_PERM );


#############################################################################
##
#C  IsPermCollection( <obj> )
#C  IsPermCollColl( <obj> )
##
##  are the categories for collections of permutations and collections of
##  collections of permutations, respectively.
##
DeclareCategoryCollections( "IsPerm" );
DeclareCategoryCollections( "IsPermCollection" );


#############################################################################
##
#F  SmallestGeneratorPerm( <perm> )
##
##  is the smallest permutation that generates the same cyclic group
##  as the permutation <perm>.
##  This is very efficient, even when <perm> has large order.

# DeclareGlobalFunction( "SmallestGeneratorPerm");


#############################################################################
##
#A  SmallestMovedPoint( <perm> )
#A  SmallestMovedPoint( <C> )
##
##  is the smallest positive integer that is moved by <perm>
##  if such an integer exists, and `infinity' if `<perm> = ()'.
##  For <C> a collection or list of permutations, the smallest value of
##  `SmallestMovedPoint' for the elements of <C> is returned (and `infinity'
##  if <C> is empty).
##
DeclareAttribute( "SmallestMovedPoint", IsPerm );
DeclareAttribute( "SmallestMovedPoint", IsPermCollection );
DeclareAttribute( "SmallestMovedPoint", IsList and IsEmpty );

DeclareSynonymAttr( "SmallestMovedPointPerm", SmallestMovedPoint );


#############################################################################
##
#A  LargestMovedPoint( <perm> ) . . . . . . . . . . . . . . largest point
#A  LargestMovedPoint( <C> )
##
##  For a permutation <perm>, this attribute contains
##  the largest positive integer which is moved by <perm>
##  if such an integer exists, and 0 if `<perm> = ()'.
##  For <C> a collection or list of permutations, the largest value of
##  `LargestMovedPoint' for the elements of <C> is returned (and 0 if <C> is
##  empty).
##
DeclareAttribute( "LargestMovedPoint", IsPerm );
DeclareAttribute( "LargestMovedPoint", IsPermCollection );
DeclareAttribute( "LargestMovedPoint", IsList and IsEmpty );

DeclareSynonymAttr( "LargestMovedPointPerm", LargestMovedPoint );


#############################################################################
##
#A  NrMovedPoints( <perm> )
#A  NrMovedPoints( <C> )
##
##  is the number of positive integers that are moved by <perm>,
##  respectively by at least one element in the collection <C>.
##  (The actual moved points are returned by `MovedPoints',
##  see~"MovedPoints")
##
DeclareAttribute( "NrMovedPoints", IsPerm );
DeclareAttribute( "NrMovedPoints", IsPermCollection );
DeclareAttribute( "NrMovedPoints", IsList and IsEmpty );

DeclareSynonymAttr( "NrMovedPointsPerm", NrMovedPoints );
DeclareSynonymAttr( "DegreeAction", NrMovedPoints );
DeclareSynonymAttr( "DegreeOperation", NrMovedPoints );


#############################################################################
##
#A  MovedPoints( <perm> )
#A  MovedPoints( <C> )
##
##  is the proper set of the positive integers moved by at least one
##  permutation in the collection <C>, respectively by the permutation
##  <perm>.
##
DeclareAttribute( "MovedPoints", IsPerm);
DeclareAttribute( "MovedPoints", IsPermCollection );
DeclareAttribute( "MovedPoints", IsList and IsEmpty );


#############################################################################
##
#A  SignPerm( <perm> )
##
##  The *sign* of a permutation <perm> is defined as $(-1)^k$
##  where $k$ is the number of cycles of <perm> of even length.
##
##  The sign is a homomorphism from the symmetric group onto the
##  multiplicative  group $\{ +1, -1 \}$,
##  the kernel of which is the alternating group.

# DeclareAttribute( "SignPerm", IsPerm );


#############################################################################
##
#A  CycleStructurePerm( <perm> )  . . . . . . . . . . . . . . cycle structure
##
##  is the cycle structure (i.e. the numbers of cycles of different
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
BIND_GLOBAL( "PermutationsFamily",
    NewFamily( "PermutationsFamily",
    IsPerm,CanEasilySortElements,CanEasilySortElements ) );


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
#v  One . . . . . . . . . . . . . . . . . . . . . . . . .  one of permutation
##
SetOne( PermutationsFamily, () );


#############################################################################
##
#F  PermList( <list> )
##
##  is the permutation <perm>  that moves points as described by the
##  list <list>.  That means that  `<i>^<perm>  = <list>[<i>]' if  <i> lies
##  between 1 and the length of <list>, and `<i>^<perm> = <i>' if <i> is
##  larger than  the length of  the list <list>. It will  signal an  error
##  if <list> does  not define a permutation,  i.e., if <list> is  not a
##  list of integers  without holes, or  if <list> contains  an  integer
##  twice, or if <list> contains an integer not in the range
##  `[1..Length(<list>)]'.

# DeclareGlobalFunction( "PermList" );


#############################################################################
##
#F  ListPerm( <perm> )  . . . . . . . . . . . . . . . . . . .  list of images
##
##  is a list <list> that contains the images of the positive integers
##  under the permutation <perm>.
##  That means that `<list>[<i>] = <i>^<perm>', where <i> lies between 1
##  and the largest point moved by <perm> (see~"LargestMovedPoint").
##
BIND_GLOBAL( "ListPerm", function( perm )
    if IsOne( perm ) then
      return [];
    else
      return OnTuples( [ 1 .. LargestMovedPoint( perm ) ], perm );
    fi;
end );


#############################################################################
##
#F  RestrictedPerm(<perm>,<list>)  restriction of a perm. to an invariant set
##
##  `RestrictedPerm' returns  the new permutation <new>  that acts on the
##  points in the list <list> in the same  way as the permutation <perm>,
##  and that fixes those points that are not in <list>.
##  <list> must be a list of positive integers such that for each <i> in
##  <list> the image `<i>^<perm>' is also in <list>,
##  i.e., <list> must be the union of cycles of <perm>.
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
#F  MappingPermListList( <src>, <dst> ) . . perm. mapping one list to another
##
##  Let <src> and <dst> be lists of positive integers of the same length,
##  such that neither may contain an element twice.
##  `MappingPermListList' returns a permutation <perm> such that
##  `<src>[<i>]^<perm> = <dst>[<i>]'.
##  <perm> fixes all points larger than the maximum of the entries in <src>
##  and <dst>.
##  If there are several such permutations, it is not specified which of them
##  `MappingPermListList' returns.
##
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
#m  SmallestMovedPoint( <perm> )  . . . . . . . . . . .  for permutations
##
InstallMethod( SmallestMovedPoint,
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
#m  LargestMovedPoint( <perm> ) . . . . . . . .  for internal permutation
##
InstallMethod( LargestMovedPoint,
    "for an internal permutation",
    true,
    [ IsPerm and IsInternalRep ], 0,
    LARGEST_MOVED_POINT_PERM );


#############################################################################
##
#m  NrMovedPoints( <perm> ) . . . . . . . . . . . . . . . for permutation
##
InstallMethod( NrMovedPoints,
    "for a permutation",
    true,
    [ IsPerm ], 0,
    function( perm )
    local mov, pnt;
    mov:= 0;
    if perm <> () then
      for pnt in [ SmallestMovedPoint( perm )
                   .. LargestMovedPoint( perm ) ] do
        if pnt ^ perm <> pnt then
          mov:= mov + 1;
        fi;
      od;
    fi;
    return mov;
    end );


#############################################################################
##
#m  CycleStructurePerm( <perm> )  . . . . . . . . .  length of cycles of perm
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
        degree := LargestMovedPoint(perm);
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
#m  String( <perm> )  . . . . . . . . . . . . . . . . . . . for a permutation
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
        for i  in [ 1 .. LargestMovedPoint( perm ) ]  do
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
#M  Order( <perm> ) . . . . . . . . . . . . . . . . .  order of a permutation
##
InstallMethod( Order,
    "for a permutation",
    true,
    [ IsPerm ], 0,
    OrderPerm );

#############################################################################
##
#m  ViewObj( <perm> )  . . . . . . . . . . . . . . . . . . . for a permutation
##
InstallMethod( ViewObj, "for a permutation", true, [ IsPerm ], 0,
function( perm )
local dom,l,i,n,p,c;
  dom:=[];
  l:=LargestMovedPoint(perm);
  i:=SmallestMovedPoint(perm);
  n:=0;
  while n<200 and i<l do
    p:=i;
    if p^perm<>p and not p in dom then
      c:=false;
      while not p in dom do
	AddSet(dom,p);
	n:=n+1;
	# deliberately *no ugly blanks* printed!
	if c then
	  Print(",",p);
	else
	  Print(Concatenation("(",String(p)));
	fi;
	p:=p^perm;
	c:=true;
      od;
      Print(")");
    fi;
    i:=i+1;
  od;
  if i<l and ForAny([i..l],j->j^perm<>j and not j in dom) then
    Print("( [...] )");
  elif i>l+1 then
    Print("()");
  fi;
end );


#############################################################################
##
#E

