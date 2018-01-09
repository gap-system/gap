#############################################################################
##
#W  basic.gd                    GAP Library                      Frank Celler
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the operations for the construction of the basic group
##  types.
##


#############################################################################
##
##  <#GAPDoc Label="[1]{basic}">
##  There are several infinite families of groups which are parametrized by
##  numbers.
##  &GAP; provides various functions to construct these groups.
##  The functions always permit (but do not require) one to indicate
##  a filter (see&nbsp;<Ref Sect="Filters"/>),
##  for example <Ref Prop="IsPermGroup"/>, <Ref Prop="IsMatrixGroup"/> or
##  <Ref Prop="IsPcGroup"/>, in which the group shall be constructed.
##  There always is a default filter corresponding to a <Q>natural</Q> way
##  to describe the group in question.
##  Note that not every group can be constructed in every filter,
##  there may be theoretical restrictions (<Ref Prop="IsPcGroup"/> only works
##  for solvable groups) or methods may be available only for a few filters.
##  <P/>
##  Certain filters may admit additional hints.
##  For example, groups constructed in <Ref Prop="IsMatrixGroup"/> may be
##  constructed over a specified field, which can be given as second argument
##  of the function that constructs the group;
##  The default field is <Ref Var="Rationals"/>.
##  <#/GAPDoc>


#############################################################################
##
#O  TrivialGroupCons( <filter> )
##
##  <ManSection>
##  <Oper Name="TrivialGroupCons" Arg='filter'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareConstructor( "TrivialGroupCons", [ IsGroup ] );


#############################################################################
##
#F  TrivialGroup( [<filter>] )  . . . . . . . . . . . . . . . . trivial group
##
##  <#GAPDoc Label="TrivialGroup">
##  <ManSection>
##  <Func Name="TrivialGroup" Arg='[filter]'/>
##
##  <Description>
##  constructs a trivial group in the category given by the filter
##  <A>filter</A>.
##  If <A>filter</A> is not given it defaults to <Ref Func="IsPcGroup"/>.
##  For more information on possible values of <A>filt</A> see section
##  (<Ref Sect="Basic Groups"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> TrivialGroup();
##  <pc group of size 1 with 0 generators>
##  gap> TrivialGroup( IsPermGroup );
##  Group(())
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "TrivialGroup", function( arg )

  if Length( arg ) = 0 then
    return TrivialGroupCons( IsPcGroup );
  elif IsFilter( arg[1] ) and Length( arg ) = 1 then
    return TrivialGroupCons( arg[1] );
  fi;
  Error( "usage: TrivialGroup( [<filter>] )" );

end );


#############################################################################
##
#O  AbelianGroupCons( <filter>, <ints> )
##
##  <ManSection>
##  <Oper Name="AbelianGroupCons" Arg='filter, ints'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareConstructor( "AbelianGroupCons", [ IsGroup, IsList ] );


#############################################################################
##
#F  AbelianGroup( [<filt>, ]<ints> )  . . . . . . . . . . . . . abelian group
##
##  <#GAPDoc Label="AbelianGroup">
##  <ManSection>
##  <Func Name="AbelianGroup" Arg='[filt, ]ints'/>
##
##  <Description>
##  constructs an abelian group in the category given by the filter
##  <A>filt</A> which is of isomorphism type
##  <M>C_{{<A>ints</A>[1]}} \times C_{{<A>ints</A>[2]}} \times \ldots
##  \times C_{{<A>ints</A>[n]}}</M>,
##  where <A>ints</A> must be a list of non-negative integers or
##  <Ref Var="infinity"/>; for the latter value or 0, <M>C_{{<A>ints</A>[i]}}</M>
##  is taken as an infinite cyclic group, otherwise as a cyclic group of
##  order <A>ints</A>[i].
##
##  If <A>filt</A> is not given it defaults to <Ref Func="IsPcGroup"/>,
##  unless any 0 or <C>infinity</C> is contained in  <A>ints</A>, in which
##  the default filter is switched to  <Ref Func="IsFpGroup"/>.
##  The generators of the group returned are the elements corresponding to
##  the factors <M>C_{{<A>ints</A>[i]}}</M> and hence the integers in <A>ints</A>.
##  For more information on possible values of <A>filt</A> see section
##  (<Ref Sect="Basic Groups"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> AbelianGroup([1,2,3]);
##  <pc group of size 6 with 3 generators>
##  gap> G:=AbelianGroup([0,3]);
##  <fp group on the generators [ f1, f2 ]>
##  gap> AbelianInvariants(G);
##  [ 0, 3 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "AbelianGroup", function ( arg )

  if Length(arg) = 1  then
    if ForAny(arg[1],x->x=0 or x=infinity) then
      return AbelianGroupCons( IsFpGroup, arg[1] );
    fi;
    return AbelianGroupCons( IsPcGroup, arg[1] );
  elif IsOperation(arg[1]) then
    if Length(arg) = 2  then
      return AbelianGroupCons( arg[1], arg[2] );
    fi;
  fi;
  Error( "usage: AbelianGroup( [<filter>, ]<ints> )" );

end );


#############################################################################
##
#O  AlternatingGroupCons( <filter>, <deg> )
##
##  <ManSection>
##  <Oper Name="AlternatingGroupCons" Arg='filter, deg'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareConstructor( "AlternatingGroupCons", [ IsGroup, IsInt ] );


#############################################################################
##
#F  AlternatingGroup( [<filt>, ]<deg> ) . . . . . . . . . . alternating group
#F  AlternatingGroup( [<filt>, ]<dom> ) . . . . . . . . . . alternating group
##
##  <#GAPDoc Label="AlternatingGroup">
##  <ManSection>
##  <Heading>AlternatingGroup</Heading>
##  <Func Name="AlternatingGroup" Arg='[filt, ]deg' Label="for a degree"/>
##  <Func Name="AlternatingGroup" Arg='[filt, ]dom' Label="for a domain"/>
##
##  <Description>
##  constructs the alternating group of degree <A>deg</A> in the category given
##  by the filter <A>filt</A>.
##  If <A>filt</A> is not given it defaults to <Ref Prop="IsPermGroup"/>.
##  For more information on possible values of <A>filt</A> see section
##  (<Ref Sect="Basic Groups"/>).
##  In the second version, the function constructs the alternating group on
##  the points given in the set <A>dom</A> which must be a set of positive
##  integers.
##  <Example><![CDATA[
##  gap> AlternatingGroup(5);
##  Alt( [ 1 .. 5 ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "AlternatingGroup", function ( arg )

  if Length(arg) = 1  then
    return  AlternatingGroupCons( IsPermGroup, arg[1] );
  elif IsOperation(arg[1]) then

    if Length(arg) = 2  then
      return  AlternatingGroupCons( arg[1], arg[2] );
    fi;
  fi;
  Error( "usage: AlternatingGroup( [<filter>, ]<deg> )" );

end );


#############################################################################
##
#O  CyclicGroupCons( <filter>, <n> )
##
##  <ManSection>
##  <Oper Name="CyclicGroupCons" Arg='filter, n'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareConstructor( "CyclicGroupCons", [ IsGroup, IsInt ] );


#############################################################################
##
#F  CyclicGroup( [<filt>, ]<n> )  . . . . . . . . . . . . . . .  cyclic group
##
##  <#GAPDoc Label="CyclicGroup">
##  <ManSection>
##  <Func Name="CyclicGroup" Arg='[filt, ]n'/>
##
##  <Description>
##  constructs the cyclic group of size <A>n</A> in the category given by the
##  filter <A>filt</A>.
##  If <A>filt</A> is not given it defaults to <Ref Func="IsPcGroup"/>,
##  unless <A>n</A> equals <Ref Var="infinity"/>, in which case the
##  default filter is switched to  <Ref Func="IsFpGroup"/>.
##  For more information on possible values of <A>filt</A> see section
##  (<Ref Sect="Basic Groups"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> CyclicGroup(12);
##  <pc group of size 12 with 3 generators>
##  gap> CyclicGroup(infinity);
##  <free group on the generators [ a ]>
##  gap> CyclicGroup(IsPermGroup,12);
##  Group([ (1,2,3,4,5,6,7,8,9,10,11,12) ])
##  gap> matgrp1:= CyclicGroup( IsMatrixGroup, 12 );
##  <matrix group of size 12 with 1 generators>
##  gap> FieldOfMatrixGroup( matgrp1 );
##  Rationals
##  gap> matgrp2:= CyclicGroup( IsMatrixGroup, GF(2), 12 );
##  <matrix group of size 12 with 1 generators>
##  gap> FieldOfMatrixGroup( matgrp2 );
##  GF(2)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "CyclicGroup", function ( arg )

  if Length(arg) = 1  then
    if arg[1]=infinity then
      return CyclicGroupCons(IsFpGroup, arg[1]);
    fi;
    return CyclicGroupCons( IsPcGroup, arg[1] );
  elif IsOperation(arg[1]) then
    if Length(arg) = 2  then
      return CyclicGroupCons( arg[1], arg[2] );
    elif Length(arg) = 3  then
      # some filters require extra arguments, e.g. IsMatrixGroup + field
      return CyclicGroupCons( arg[1], arg[2], arg[3] );
    fi;
  fi;
  Error( "usage: CyclicGroup( [<filter>, ]<size> )" );

end );


#############################################################################
##
#O  DihedralGroupCons( <filter>, <n> )
##
##  <ManSection>
##  <Oper Name="DihedralGroupCons" Arg='filter, n'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareConstructor( "DihedralGroupCons", [ IsGroup, IsInt ] );


#############################################################################
##
#F  DihedralGroup( [<filt>, ]<n> )  . . . . . . . dihedral group of order <n>
##
##  <#GAPDoc Label="DihedralGroup">
##  <ManSection>
##  <Func Name="DihedralGroup" Arg='[filt, ]n'/>
##
##  <Description>
##  constructs the dihedral group of size <A>n</A> in the category given by the
##  filter <A>filt</A>.
##  If <A>filt</A> is not given it defaults to <Ref Func="IsPcGroup"/>,
##  unless <A>n</A> equals <Ref Var="infinity"/>, in which case the
##  default filter is switched to  <Ref Func="IsFpGroup"/>.
##  For more information on possible values of <A>filt</A> see section
##  (<Ref Sect="Basic Groups"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> DihedralGroup(8);
##  <pc group of size 8 with 3 generators>
##  gap> DihedralGroup( IsPermGroup, 8 );
##  Group([ (1,2,3,4), (2,4) ])
##  gap> DihedralGroup(infinity);
##  <fp group of size infinity on the generators [ r, s ]>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "DihedralGroup", function ( arg )

  if Length(arg) = 1  then
    if arg[1]=infinity then
      return DihedralGroupCons( IsFpGroup, arg[1] );
    fi;
    return DihedralGroupCons( IsPcGroup, arg[1] );
  elif IsOperation(arg[1]) then
    if Length(arg) = 2  then
      return DihedralGroupCons( arg[1], arg[2] );
    fi;
  fi;
  Error( "usage: DihedralGroup( [<filter>, ]<size> )" );

end );

#############################################################################
##
#O  QuaternionGroupCons( <filter>, <n> )
##
##  <ManSection>
##  <Oper Name="QuaternionGroupCons" Arg='filter, n'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareConstructor( "QuaternionGroupCons", [ IsGroup, IsInt ] );


#############################################################################
##
#F  QuaternionGroup( [<filt>, ]<n> )  . . . . . . . quaternion group of order <n>
##
##  <#GAPDoc Label="QuaternionGroup">
##  <ManSection>
##  <Func Name="QuaternionGroup" Arg='[filt, ]n'/>
##  <Func Name="DicyclicGroup" Arg='[filt, ]n'/>
##
##  <Description>
##  constructs the generalized quaternion group (or dicyclic group) of size
##  <A>n</A> in the category given by the filter <A>filt</A>.  Here, <A>n</A>
##  is a multiple of 4.
##  If <A>filt</A> is not given it defaults to <Ref Func="IsPcGroup"/>.
##  For more information on possible values of <A>filt</A> see section
##  (<Ref Sect="Basic Groups"/>).
##  Methods are also available for permutation and matrix groups (of minimal
##  degree and minimal dimension in coprime characteristic).
##  <P/>
##  <Example><![CDATA[
##  gap> QuaternionGroup(32);
##  <pc group of size 32 with 5 generators>
##  gap> g:=QuaternionGroup(IsMatrixGroup,CF(16),32);
##  Group([ [ [ 0, 1 ], [ -1, 0 ] ], [ [ E(16), 0 ], [ 0, -E(16)^7 ] ] ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "QuaternionGroup", function ( arg )

  if Length(arg) = 1  then
    return QuaternionGroupCons( IsPcGroup, arg[1] );
  elif IsOperation(arg[1]) then
    if Length(arg) = 2  then
      return QuaternionGroupCons( arg[1], arg[2] );
    elif Length(arg) = 3  then
      # some filters require extra arguments, e.g. IsMatrixGroup + field
      return QuaternionGroupCons( arg[1], arg[2], arg[3] );
    fi;
  fi;
  Error( "usage: QuaternionGroup( [<filter>, ]<size> )" );

end );

DeclareSynonym( "DicyclicGroup", QuaternionGroup );


#############################################################################
##
#O  ElementaryAbelianGroupCons( <filter>, <n> )
##
##  <ManSection>
##  <Oper Name="ElementaryAbelianGroupCons" Arg='filter, n'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareConstructor( "ElementaryAbelianGroupCons", [ IsGroup, IsInt ] );


#############################################################################
##
#F  ElementaryAbelianGroup( [<filt>, ]<n> ) . . . .  elementary abelian group
##
##  <#GAPDoc Label="ElementaryAbelianGroup">
##  <ManSection>
##  <Func Name="ElementaryAbelianGroup" Arg='[filt, ]n'/>
##
##  <Description>
##  constructs the elementary abelian group of size <A>n</A> in the category
##  given by the filter <A>filt</A>.
##  If <A>filt</A> is not given it defaults to <Ref Func="IsPcGroup"/>.
##  For more information on possible values of <A>filt</A> see section
##  (<Ref Sect="Basic Groups"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> ElementaryAbelianGroup(8192);
##  <pc group of size 8192 with 13 generators>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "ElementaryAbelianGroup", function ( arg )

  if Length(arg) = 1  then
    return ElementaryAbelianGroupCons( IsPcGroup, arg[1] );
  elif IsOperation(arg[1]) then
    if Length(arg) = 2  then
      return ElementaryAbelianGroupCons( arg[1], arg[2] );
    fi;
  fi;
  Error( "usage: ElementaryAbelianGroup( [<filter>, ]<size> )" );

end );


#############################################################################
##
#O  FreeAbelianGroupCons( <filter>, <rank> )
##
##  <ManSection>
##  <Oper Name="FreeAbelianGroupCons" Arg='filter, rank'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareConstructor( "FreeAbelianGroupCons", [ IsGroup, IsInt ] );


#############################################################################
##
#F  FreeAbelianGroup( [<filt>, ]<rank> ) . . . . . . . . . .  free abelian group
##
##  <#GAPDoc Label="FreeAbelianGroup">
##  <ManSection>
##  <Func Name="FreeAbelianGroup" Arg='[filt, ]rank'/>
##
##  <Description>
##  constructs the free abelian group of rank <A>n</A> in the category
##  given by the filter <A>filt</A>.
##  If <A>filt</A> is not given it defaults to <Ref Func="IsFpGroup"/>.
##  For more information on possible values of <A>filt</A> see section
##  (<Ref Sect="Basic Groups"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> FreeAbelianGroup(4);
##  <fp group on the generators [ f1, f2, f3, f4 ]>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "FreeAbelianGroup", function ( arg )

  if Length(arg) = 1  then
    return FreeAbelianGroupCons( IsFpGroup, arg[1] );
  elif IsOperation(arg[1]) then
    if Length(arg) = 2  then
      return FreeAbelianGroupCons( arg[1], arg[2] );
    fi;
  fi;
  Error( "usage: FreeAbelianGroup( [<filter>, ]<rank> )" );

end );


#############################################################################
##
#O  ExtraspecialGroupCons( <filter>, <order>, <exponent> )
##
##  <ManSection>
##  <Oper Name="ExtraspecialGroupCons" Arg='filter, order, exponent'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareConstructor( "ExtraspecialGroupCons", [ IsGroup, IsInt, IsObject ] );


#############################################################################
##
#F  ExtraspecialGroup( [<filt>, ]<order>, <exp> ) . . . .  extraspecial group
##
##  <#GAPDoc Label="ExtraspecialGroup">
##  <ManSection>
##  <Func Name="ExtraspecialGroup" Arg='[filt, ]order, exp'/>
##
##  <Description>
##  Let <A>order</A> be of the form <M>p^{{2n+1}}</M>, for a prime integer
##  <M>p</M> and a positive integer <M>n</M>.
##  <Ref Func="ExtraspecialGroup"/> returns the extraspecial group of order
##  <A>order</A> that is determined by <A>exp</A>,
##  in the category given by the filter <A>filt</A>.
##  <P/>
##  If <M>p</M> is odd then admissible values of <A>exp</A> are the exponent
##  of the group (either <M>p</M> or <M>p^2</M>) or one of <C>'+'</C>,
##  <C>"+"</C>, <C>'-'</C>, <C>"-"</C>.
##  For <M>p = 2</M>, only the above plus or minus signs are admissible.
##  <P/>
##  If <A>filt</A> is not given it defaults to <Ref Func="IsPcGroup"/>.
##  For more information on possible values of <A>filt</A> see section
##  (<Ref Sect="Basic Groups"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> ExtraspecialGroup( 27, 3 );
##  <pc group of size 27 with 3 generators>
##  gap> ExtraspecialGroup( 27, '+' );
##  <pc group of size 27 with 3 generators>
##  gap> ExtraspecialGroup( 8, "-" );
##  <pc group of size 8 with 3 generators>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "ExtraspecialGroup", function ( arg )

  if Length(arg) = 2  then
    return ExtraspecialGroupCons( IsPcGroup, arg[1], arg[2] );
  elif IsOperation(arg[1]) then
    if Length(arg) = 3  then
      return ExtraspecialGroupCons( arg[1], arg[2], arg[3] );
    fi;
  fi;
  Error( "usage: ExtraspecialGroup( [<filter>, ]<order>, <exponent> )" );

end );


#############################################################################
##
#O  MathieuGroupCons( <filter>, <degree> )
##
##  <ManSection>
##  <Oper Name="MathieuGroupCons" Arg='filter, degree'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareConstructor( "MathieuGroupCons", [ IsGroup, IsInt ] );


#############################################################################
##
#F  MathieuGroup( [<filt>, ]<degree> )  . . . . . . . . . . . . Mathieu group
##
##  <#GAPDoc Label="MathieuGroup">
##  <ManSection>
##  <Func Name="MathieuGroup" Arg='[filt, ]degree'/>
##
##  <Description>
##  constructs the Mathieu group of degree <A>degree</A> in the category
##  given by the filter <A>filt</A>, where <A>degree</A> must be in the set
##  <M>\{ 9, 10, 11, 12, 21, 22, 23, 24 \}</M>.
##  If <A>filt</A> is not given it defaults to <Ref Prop="IsPermGroup"/>.
##  For more information on possible values of <A>filt</A> see section
##  (<Ref Sect="Basic Groups"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> MathieuGroup( 11 );
##  Group([ (1,2,3,4,5,6,7,8,9,10,11), (3,7,11,8)(4,10,5,6) ])
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "MathieuGroup", function( arg )

  if Length( arg ) = 1 then
    return MathieuGroupCons( IsPermGroup, arg[1] );
  elif IsOperation( arg[1] ) then
    if Length( arg ) = 2 then
      return MathieuGroupCons( arg[1], arg[2] );
    fi;
  fi;
  Error( "usage: MathieuGroup( [<filter>, ]<degree> )" );

end );


#############################################################################
##
#O  SymmetricGroupCons( <filter>, <deg> )
##
##  <ManSection>
##  <Oper Name="SymmetricGroupCons" Arg='filter, deg'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareConstructor( "SymmetricGroupCons", [ IsGroup, IsInt ] );


#############################################################################
##
#F  SymmetricGroup( [<filt>, ]<deg> )
#F  SymmetricGroup( [<filt>, ]<dom> )
##
##  <#GAPDoc Label="SymmetricGroup">
##  <ManSection>
##  <Heading>SymmetricGroup</Heading>
##  <Func Name="SymmetricGroup" Arg='[filt, ]deg' Label="for a degree"/>
##  <Func Name="SymmetricGroup" Arg='[filt, ]dom' Label="for a domain"/>
##
##  <Description>
##  constructs the symmetric group of degree <A>deg</A> in the category
##  given by the filter <A>filt</A>.
##  If <A>filt</A> is not given it defaults to <Ref Prop="IsPermGroup"/>.
##  For more information on possible values of <A>filt</A> see section
##  (<Ref Sect="Basic Groups"/>).
##  In the second version, the function constructs the symmetric group on
##  the points given in the set <A>dom</A> which must be a set of positive
##  integers.
##  <P/>
##  <Example><![CDATA[
##  gap> SymmetricGroup(10);
##  Sym( [ 1 .. 10 ] )
##  ]]></Example>
##  <P/>
##  Note that permutation groups provide special treatment of symmetric and
##  alternating groups,
##  see&nbsp;<Ref Sect="Symmetric and Alternating Groups"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "SymmetricGroup", function ( arg )

  if Length(arg) = 1  then
    return  SymmetricGroupCons( IsPermGroup, arg[1] );
  elif IsOperation(arg[1]) then

    if Length(arg) = 2  then
      return  SymmetricGroupCons( arg[1], arg[2] );
    fi;
  fi;
  Error( "usage: SymmetricGroup( [<filter>, ]<deg> )" );

end );

BIND_GLOBAL("PermConstructor",function(oper,filter,use)
local val, i;
  val:=0;
  # force value 0 (unless offset).
  for i in filter do
    val:=val-RankFilter(i);
  od;

  InstallOtherMethod( oper,
    "convert to permgroup",
    filter,
    val,
  function(arg)
  local argc,g,h;
    argc:=ShallowCopy(arg);
    argc[1]:=use;
    g:=CallFuncList(oper,argc);
    h:=Image(IsomorphismPermGroup(g),g);
    if HasName(g) then
      SetName(h,Concatenation("Perm_",Name(g)));
    fi;
    if HasSize(g) then
      SetSize(h,Size(g));
    fi;
    return h;
  end);

end);


#############################################################################
##
#E

