#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file deals with permutations.
##

#############################################################################
##
##  <#GAPDoc Label="[1]{permutat}">
##  Internally, &GAP; stores a permutation as a list of the <M>d</M> images
##  of the integers <M>1, \ldots, d</M>, where the <Q>internal degree</Q>
##  <M>d</M> is the largest integer moved by the permutation or bigger.
##  When a permutation is read in cycle notation, <M>d</M> is always set
##  to the largest moved integer, but a bigger <M>d</M> can result from a
##  multiplication of two permutations, because the product is not shortened
##  if it fixes&nbsp;<M>d</M>.
##  The images are stored all as <M>16</M>-bit integers or all as
##  <M>32</M>-bit integers, depending on whether <M>d \leq 65536</M> or not.
##  For example, if <M>m\geq 65536</M>, the permutation
##  <M>(1, 2, \ldots, m)</M> has internal degree <M>d=m</M> and takes
##  <M>4m</M> bytes of memory for storage. But --- since the internal degree
##  is not reduced  --- this
##  means that the identity permutation <C>()</C> calculated as
##  <M>(1, 2, \ldots, m) * (1, 2, \ldots, m)^{{-1}}</M> also
##  takes <M>4m</M> bytes of storage.
##  It can take even more because the internal list has sometimes room for
##  more than <M>d</M> images.
##  <P/> On 32-bit systems, the limit on the degree of permutations is, for
##  technical reasons, <M>2^{28}-1</M>.
##  On 64-bit systems, it is <M>2^{32}-1</M> because only a 32-bit integer
##  is used to represent each image internally. Error messages should be given
##  if any command would require creating a permutation exceeding this limit.
##  <P/>
##  The operation <Ref Oper="RestrictedPerm"/> reduces the storage degree of
##  its result and therefore can be used to save memory if intermediate
##  calculations in large degree result in a small degree result.
##  <P/>
##  Permutations do not belong to a specific group.
##  That means that one can work with permutations without defining
##  a permutation group that contains them.
##  <P/>
##  <Example><![CDATA[
##  gap> (1,2,3);
##  (1,2,3)
##  gap> (1,2,3) * (2,3,4);
##  (1,3)(2,4)
##  gap> 17^(2,5,17,9,8);
##  9
##  gap> OnPoints(17,(2,5,17,9,8));
##  9
##  ]]></Example>
##  <P/>
##  The operation <Ref Oper="Permuted"/> can be used to permute the entries
##  of a list according to a permutation.
##  <#/GAPDoc>
##


#############################################################################
##
#C  IsPerm( <obj> )
##
##  <#GAPDoc Label="IsPerm">
##  <ManSection>
##  <Filt Name="IsPerm" Arg='obj' Type='Category'/>
##
##  <Description>
##  Each <E>permutation</E> in &GAP; lies in the category
##  <Ref Filt="IsPerm"/>.
##  Basic operations for permutations are
##  <Ref Attr="LargestMovedPoint" Label="for a permutation"/>,
##  multiplication of two permutations via <C>*</C>,
##  and exponentiation <C>^</C> with first argument a positive integer
##  <M>i</M> and second argument a permutation <M>\pi</M>,
##  the result being the image <M>i^{\pi}</M> of the point <M>i</M>
##  under <M>\pi</M>.
##  <!-- other arith. ops.?-->
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IsPermCollection">
##  <ManSection>
##  <Filt Name="IsPermCollection" Arg='obj' Type='Category'/>
##  <Filt Name="IsPermCollColl" Arg='obj' Type='Category'/>
##
##  <Description>
##  are the categories for collections of permutations and collections of
##  collections of permutations, respectively.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategoryCollections( "IsPerm" );
DeclareCategoryCollections( "IsPermCollection" );


#############################################################################
##
#F  SmallestGeneratorPerm( <perm> )
##
##  <#GAPDoc Label="SmallestGeneratorPerm">
##  <ManSection>
##  <Attr Name="SmallestGeneratorPerm" Arg='perm'/>
##
##  <Description>
##  is the smallest permutation that generates the same cyclic group
##  as the permutation <A>perm</A>.
##  This is very efficient, even when <A>perm</A> has large order.
##  <Example><![CDATA[
##  gap> SmallestGeneratorPerm( (1,4,3,2) );
##  (1,2,3,4)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "SmallestGeneratorPerm",IsPerm);

InstallMethod( SmallestGeneratorPerm,"for internally represented permutation",
    [ IsPerm and IsInternalRep ],
    SMALLEST_GENERATOR_PERM );


#############################################################################
##
#A  SmallestMovedPoint( <perm> )
#A  SmallestMovedPoint( <C> )
##
##  <#GAPDoc Label="SmallestMovedPoint">
##  <ManSection>
##  <Attr Name="SmallestMovedPoint" Arg='perm' Label="for a permutation"/>
##  <Attr Name="SmallestMovedPoint" Arg='C'
##   Label="for a list or collection of permutations"/>
##
##  <Description>
##  is the smallest positive integer that is moved by <A>perm</A>
##  if such an integer exists, and <Ref Var="infinity"/> if
##  <A>perm</A> is the identity.
##  For <A>C</A> a collection or list of permutations,
##  the smallest value of
##  <Ref Attr="SmallestMovedPoint" Label="for a permutation"/> for the
##  elements of <A>C</A> is returned
##  (and <Ref Var="infinity"/> if <A>C</A> is empty).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="LargestMovedPoint">
##  <ManSection>
##  <Attr Name="LargestMovedPoint" Arg='perm' Label="for a permutation"/>
##  <Attr Name="LargestMovedPoint" Arg='C'
##   Label="for a list or collection of permutations"/>
##
##  <Description>
##  For a permutation <A>perm</A>, this attribute contains
##  the largest positive integer which is moved by <A>perm</A>
##  if such an integer exists, and <C>0</C> if <A>perm</A> is the identity.
##  For <A>C</A> a collection or list of permutations,
##  the largest value of
##  <Ref Attr="LargestMovedPoint" Label="for a permutation"/> for the
##  elements of <A>C</A> is returned (and <C>0</C> if <A>C</A> is empty).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="NrMovedPoints">
##  <ManSection>
##  <Attr Name="NrMovedPoints" Arg='perm' Label="for a permutation"/>
##  <Attr Name="NrMovedPoints" Arg='C'
##   Label="for a list or collection of permutations"/>
##
##  <Description>
##  is the number of positive integers that are moved by <A>perm</A>,
##  respectively by at least one element in the collection <A>C</A>.
##  (The actual moved points are returned by
##  <Ref Attr="MovedPoints" Label="for a permutation"/>.)
##  <Example><![CDATA[
##  gap> SmallestMovedPointPerm((4,5,6)(7,2,8));
##  2
##  gap> LargestMovedPointPerm((4,5,6)(7,2,8));
##  8
##  gap> NrMovedPointsPerm((4,5,6)(7,2,8));
##  6
##  gap> MovedPoints([(2,3,4),(7,6,3),(5,47)]);
##  [ 2, 3, 4, 5, 6, 7, 47 ]
##  gap> NrMovedPoints([(2,3,4),(7,6,3),(5,47)]);
##  7
##  gap> SmallestMovedPoint([(2,3,4),(7,6,3),(5,47)]);
##  2
##  gap> LargestMovedPoint([(2,3,4),(7,6,3),(5,47)]);
##  47
##  gap> LargestMovedPoint([()]);
##  0
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="MovedPoints">
##  <ManSection>
##  <Attr Name="MovedPoints" Arg='perm' Label="for a permutation"/>
##  <Attr Name="MovedPoints" Arg='C'
##   Label="for a list or collection of permutations"/>
##
##  <Description>
##  is the proper set of the positive integers moved by at least one
##  permutation in the collection <A>C</A>, respectively by the permutation
##  <A>perm</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "MovedPoints", IsPerm);
DeclareAttribute( "MovedPoints", IsPermCollection );
DeclareAttribute( "MovedPoints", IsList and IsEmpty );


#############################################################################
##
#A  SignPerm( <perm> )
##
##  <#GAPDoc Label="SignPerm">
##  <ManSection>
##  <Attr Name="SignPerm" Arg='perm'/>
##
##  <Description>
##  The <E>sign</E> of a permutation <A>perm</A> is defined as <M>(-1)^k</M>
##  where <M>k</M> is the number of cycles of <A>perm</A> of even length.
##  <P/>
##  The sign is a homomorphism from the symmetric group onto the
##  multiplicative  group <M>\{ +1, -1 \}</M>,
##  the kernel of which is the alternating group.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "SignPerm", IsPerm );

InstallMethod( SignPerm,
    "for internally represented permutation",
    [ IsPerm and IsInternalRep ],
    SIGN_PERM );


#############################################################################
##
#A  CycleStructurePerm( <perm> )  . . . . . . . . . . . . . . cycle structure
##
##  <#GAPDoc Label="CycleStructurePerm">
##  <ManSection>
##  <Attr Name="CycleStructurePerm" Arg='perm'/>
##
##  <Description>
##  is the cycle structure (i.e. the numbers of cycles of different lengths)
##  of the permutation <A>perm</A>.
##  This is encoded in a list <M>l</M> in the following form:
##  The <M>i</M>-th entry of <M>l</M> contains the number of cycles of
##  <A>perm</A> of length <M>i+1</M>.
##  If <A>perm</A> contains no cycles of length <M>i+1</M> it is not
##  bound.
##  Cycles of length 1 are ignored.
##  <Example><![CDATA[
##  gap> SignPerm((1,2,3)(4,5));
##  -1
##  gap> CycleStructurePerm((1,2,3)(4,5,9,7,8));
##  [ , 1,, 1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "CycleStructurePerm", IsPerm );


#############################################################################
##
#R  IsPerm2Rep  . . . . . . . . . . . . . .  permutation with 2 bytes entries
##
##  <ManSection>
##  <Filt Name="IsPerm2Rep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareRepresentation( "IsPerm2Rep", IsInternalRep );


#############################################################################
##
#R  IsPerm4Rep  . . . . . . . . . . . . . .  permutation with 4 bytes entries
##
##  <ManSection>
##  <Filt Name="IsPerm4Rep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareRepresentation( "IsPerm4Rep", IsInternalRep );


#############################################################################
##
#V  PermutationsFamily  . . . . . . . . . . . . .  family of all permutations
##
##  <#GAPDoc Label="PermutationsFamily">
##  <ManSection>
##  <Fam Name="PermutationsFamily"/>
##
##  <Description>
##  is the family of all permutations.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "PermutationsFamily",
    NewFamily( "PermutationsFamily",
    IsPerm,CanEasilySortElements,CanEasilySortElements ) );
#    IsMultiplicativeElementWithOne,CanEasilySortElements,CanEasilySortElements ) );


#############################################################################
##
#V  TYPE_PERM2  . . . . . . . . . .  type of permutation with 2 bytes entries
##
##  <ManSection>
##  <Var Name="TYPE_PERM2"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_PERM2",
    NewType( PermutationsFamily, IsPerm and IsPerm2Rep ) );


#############################################################################
##
#V  TYPE_PERM4  . . . . . . . . . .  type of permutation with 4 bytes entries
##
##  <ManSection>
##  <Var Name="TYPE_PERM4"/>
##
##  <Description>
##  </Description>
##  </ManSection>
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
##  <#GAPDoc Label="PermList">
##  <ManSection>
##  <Func Name="PermList" Arg='list'/>
##
##  <Description>
##  is the permutation <M>\pi</M> that moves points as described by the
##  list <A>list</A>.
##  That means that <M>i^{\pi} =</M> <A>list</A><C>[</C><M>i</M><C>]</C> if
##  <M>i</M> lies between <M>1</M> and the length of <A>list</A>,
##  and <M>i^{\pi} = i</M> if <M>i</M> is
##  larger than the length of the list <A>list</A>.
##  <Ref Func="PermList"/> will return <K>fail</K>
##  if <A>list</A> does not define a permutation,
##  i.e., if <A>list</A> is not dense,
##  or if <A>list</A> contains a positive integer twice,
##  or if <A>list</A> contains an
##  integer not in the range <C>[ 1 .. Length( <A>list</A> ) ]</C>,
##  or if <A>list</A> contains non-integer entries, etc.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##


#############################################################################
##
#F  ListPerm( <perm>[, <n>] )  . . . . . . . . . . . . .  list of images
##
##  <#GAPDoc Label="ListPerm">
##  <ManSection>
##  <Func Name="ListPerm" Arg='perm[, n]'/>
##
##  <Description>
##  is a list <M>l</M> that contains the images of the positive integers
##  from 1 to <A>n</A> under the permutation <A>perm</A>.
##  That means that
##  <M>l</M><C>[</C><M>i</M><C>]</C> <M>= i</M><C>^</C><A>perm</A>,
##  where <M>i</M> lies between 1 and <A>n</A>.
##  <P/>
##  If the optional second argument <A>n</A> is omitted then the largest
##  point moved by <A>perm</A> is used
##  (see&nbsp;<Ref Attr="LargestMovedPoint" Label="for a permutation"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##


#############################################################################
##
#F  CycleFromList( <list> )  . . . . . . . . . . . cycle defined from a list
##
##  <#GAPDoc Label="CycleFromList">
##  <ManSection>
##  <Func Name="CycleFromList" Arg='list'/>
##
##  <Description>
##  For the given dense, duplicate-free list of positive integers
##  <M>[a_1, a_2, ..., a_n]</M>
##  return the <M>n</M>-cycle <M>(a_1,a_2,...,a_n)</M>. For the empty list
##  the trivial permutation <M>()</M> is returned.
##  <P/>
##  If the given <A>list</A> contains duplicates or holes, return <K>fail</K>.
##  <P/>
##  <Example><![CDATA[
##  gap> CycleFromList( [1,2,3,4] );
##  (1,2,3,4)
##  gap> CycleFromList( [3,2,6,4,5] );
##  (2,6,4,5,3)
##  gap> CycleFromList( [2,3,2] );
##  fail
##  gap> CycleFromList( [1,,3] );
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "CycleFromList", function( list )
    local max, images, set, i;

    # Trivial case
    if Length(list) = 0 then
        return ();
    fi;

    if ForAny( list, i -> not IsPosInt(i) ) then
        Error("CycleFromList: List must only contain positive integers.");
    fi;

    set := Set(list);
    if Length(set) <> Length(list) then
        # we found duplicates (or list was not dense)
        return fail;
    fi;
    max := Maximum( set );
    images := [1..max];
    for i in [1..Length(list)-1] do
        images[ list[i] ] := list[i+1];
    od;
    images[ list[Length(list)] ] := list[1];

    return PermList(images);
end );


#############################################################################
##
#O  RestrictedPerm(<perm>,<list>)  restriction of a perm. to an invariant set
#O  RestrictedPermNC(<perm>,<list>)  restriction of a perm. to an invariant set
##
##  <#GAPDoc Label="RestrictedPerm">
##  <ManSection>
##  <Oper Name="RestrictedPerm" Arg='perm, list'/>
##  <Oper Name="RestrictedPermNC" Arg='perm, list'/>
##
##  <Description>
##  <Ref Oper="RestrictedPerm"/> returns the new permutation
##  that acts on the points in the list <A>list</A> in the same way as
##  the permutation <A>perm</A>,
##  and that fixes those points that are not in <A>list</A>. The resulting
##  permutation is stored internally of degree given by the maximal entry of
##  <A>list</A>.
##  <A>list</A> must be a list of positive integers such that for each
##  <M>i</M> in <A>list</A> the image <M>i</M><C>^</C><A>perm</A> is also in
##  <A>list</A>,
##  i.e., <A>list</A> must be the union of cycles of <A>perm</A>.
##  <P/>
##  <Ref Oper="RestrictedPermNC"/> does not check whether <A>list</A>
##  is a union of cycles.
##  <P/>
##  <Example><![CDATA[
##  gap> ListPerm((3,4,5));
##  [ 1, 2, 4, 5, 3 ]
##  gap> PermList([1,2,4,5,3]);
##  (3,4,5)
##  gap> MappingPermListList([2,5,1,6],[7,12,8,2]);
##  (1,8,5,12,6,2,7)
##  gap> RestrictedPerm((1,2)(3,4),[3..5]);
##  (3,4)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "RestrictedPerm", [ IsPerm, IsList ] );
DeclareOperation( "RestrictedPermNC", [ IsPerm, IsList ] );

InstallMethod(RestrictedPermNC,"kernel method",true,
  [IsPerm and IsInternalRep, IsList],0,
function(g,D)
local p;
  p:=RESTRICTED_PERM(g,D,false);
  if p=fail then
    Error("<g> must be a permutation and <D> a plain list or range,\n",
          "   consisting of a union of cycles of <g>");
  fi;
  return p;
end);

InstallMethod( RestrictedPerm,"use kernel method, test",true,
  [IsPerm and IsInternalRep, IsList],0,
function(g,D)
  local p;
  p:=RESTRICTED_PERM(g,D,true);
  if p=fail then
    Error("<g> must be a permutation and <D> a plain list or range,\n",
          "   consisting of a union of cycles of <g>");
  fi;
  return p;
end);

#############################################################################
##
#F  MappingPermListList( <src>, <dst> ) . . perm. mapping one list to another
##
##  <#GAPDoc Label="MappingPermListList">
##  <ManSection>
##  <Func Name="MappingPermListList" Arg='src, dst'/>
##
##  <Description>
##  Let <A>src</A> and <A>dst</A> be lists of positive integers of the same
##  length, such that there is a permutation <M>\pi</M> such that
##  <C>OnTuples(<A>src</A>,</C> <M>\pi</M><C>) = <A>dst</A></C>.
##  <Ref Func="MappingPermListList"/> returns the permutation <C>p</C> from the
##  previous sentence, i.e.  <A>src</A><C>[</C><M>i</M><C>]^</C><M>p =</M>
##  <A>dst</A><C>[</C><M>i</M><C>]</C>.
##  The permutation <M>\pi</M> fixes any point which is not in <A>src</A> or
##  <A>dst</A>.
##  If there are several such permutations, it is not specified which of them
##  <Ref Func="MappingPermListList"/> returns. If there is no such
##  permutation, then <Ref Func="MappingPermListList"/> returns <K>fail</K>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

#############################################################################
##
#m  SmallestMovedPoint( <perm> )  . . . . . . . . . . .  for permutations
##
InstallMethod( SmallestMovedPoint,
    "for a permutation",
    [ IsPerm ],
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


InstallMethod( SmallestMovedPoint,
    "for an internal permutation",
    [ IsPerm and IsInternalRep ],
    SMALLEST_MOVED_POINT_PERM );


#############################################################################
##
#m  LargestMovedPoint( <perm> ) . . . . . . . .  for internal permutation
##
InstallMethod( LargestMovedPoint,
    "for an internal permutation",
    [ IsPerm and IsInternalRep ],
    LARGEST_MOVED_POINT_PERM );


#############################################################################
##
#m  NrMovedPoints( <perm> ) . . . . . . . . . . . . . . . for permutation
##
InstallMethod( NrMovedPoints,
    "for a permutation",
    [ IsPerm ],
    function( perm )
    local mov, pnt;
    mov:= 0;
    if not IsOne( perm ) then
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
InstallMethod( CycleStructurePerm, "internal", [ IsPerm and IsInternalRep],0,
  CYCLE_STRUCT_PERM);

InstallMethod( CycleStructurePerm, "generic method", [ IsPerm ],0,
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
               cyc := CYCLE_PERM_INT( perm, i );
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
BIND_GLOBAL("DoStringPerm",function( perm,hint )
local   str,  i,  j, maxpnt, blist;

  if IsOne( perm ) then
      str := "()";
  else
      str := "";
      maxpnt := LargestMovedPoint( perm );
      blist := BlistList([1..maxpnt], []);
      for i  in [ 1 .. LargestMovedPoint( perm ) ]  do
      if not blist[i] and i ^ perm <> i  then
          blist[i] := true;
          Append( str, "(" );
          Append( str, String( i ) );
          j := i ^ perm;
          while j > i do
          blist[j] := true;
          Append( str, "," );
          if hint then Append(str,"\<\>"); fi;
          Append( str, String( j ) );
          j := j ^ perm;
          od;
          Append( str, ")" );
          if hint then Append(str,"\<\<\>\>"); fi;
      fi;
      od;
      if Length(str)>4 and str{[Length(str)-3..Length(str)]}="\<\<\>\>" then
          str:=str{[1..Length(str)-4]}; # remove tailing line breaker
      fi;
      ConvertToStringRep( str );
  fi;
  return str;
end );

InstallMethod( String, "for a permutation", [ IsPerm ],function(perm)
  return DoStringPerm(perm,false);
end);

InstallMethod( ViewString, "for a permutation", [ IsPerm ],function(perm)
  return DoStringPerm(perm,true);
end);




#############################################################################
##
#M  Order( <perm> ) . . . . . . . . . . . . . . . . .  order of a permutation
##
InstallMethod( Order,
    "for a permutation",
    [ IsPerm ],
    ORDER_PERM );


#############################################################################
##
#O  DistancePerms( <perm1>, <perm2> ) . returns NrMovedPoints( <perm1>/<perm2> )
##        but possibly faster
##
##  <#GAPDoc Label="DistancePerms">
##  <ManSection>
##  <Oper Name="DistancePerms" Arg="perm1, perm2"/>
##
##  <Description>
##  returns the number of points for which <A>perm1</A> and <A>perm2</A>
##  have different images. This should always produce the same result as
##  <C>NrMovedPoints(<A>perm1</A>/<A>perm2</A>)</C> but some methods may be
##  much faster than this form, since no new permutation needs to be created.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>

DeclareOperation( "DistancePerms", [IsPerm, IsPerm] );


#############################################################################
##
#M  DistancePerms( <perm1>, <perm2> ) . returns NrMovedPoints( <perm1>/<perm2> )
##    for kernel permutations
##
InstallMethod( DistancePerms, "for kernel permutations",
        [ IsPerm and IsInternalRep, IsPerm and IsInternalRep ],
        DISTANCE_PERMS);

#############################################################################
##
#M  DistancePerms( <perm1>, <perm2> ) . returns NrMovedPoints( <perm1>/<perm2> )
##    generic
##

InstallMethod( DistancePerms, "for general permutations",
        [ IsPerm, IsPerm ],
        function(x,y)
    return NrMovedPoints(x/y); end);

#############################################################################
##
#V  PERM_INVERSE_THRESHOLD . . . . cut off for when inverses are computed
##                                 eagerly
##
##  <#GAPDoc Label="PERM_INVERSE_THRESHOLD">
##  <ManSection>
##  <Var Name="PERM_INVERSE_THRESHOLD"/>
##
##  <Description>
##  For permutations of degree up to <C>PERM_INVERSE_THRESHOLD</C> whenever
##  the inverse image of a point under a permutations is needed, the entire
##  inverse is computed and stored. Otherwise, if the inverse is not stored,
##  the point is traced around the cycle it is part of to find the inverse
##  image. This takes time when it happens, and uses memory, but saves time
##  on a variety of subsequent computations. This threshold can be adjusted
##  by simply assigning to the variable. The default is 10000.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>

PERM_INVERSE_THRESHOLD := 10000;



#############################################################################
##
#m  ViewObj( <perm> )  . . . . . . . . . . . . . . . . . . . for a permutation
##
InstallMethod( ViewObj, "for a permutation", [ IsPerm ],
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
