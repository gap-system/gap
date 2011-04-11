#############################################################################
##
#W  classic.gd                  GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the operations for the construction of the classical
##  group types.
##
Revision.classic_gd :=
    "@(#)$Id$";


#############################################################################
##
##  <#GAPDoc Label="[1]{classic}">
##  The following functions return classical groups.
##  For the linear, symplectic, and unitary groups (the latter in dimension
##  at least <M>3</M>),
##  the generators are taken from&nbsp;<Cite Key="Tay87"/>;
##  for the unitary groups in dimension <M>2</M>, the isomorphism of
##  SU<M>(2,q)</M> and SL<M>(2,q)</M> is used,
##  see for example&nbsp;<Cite Key="Hup67"/>.
##  The generators of the orthogonal groups are taken
##  from&nbsp;<Cite Key="IshibashiEarnest94"/>
##  and&nbsp;<Cite Key="KleidmanLiebeck90"/>,
##  except that the generators of the orthogonal groups in odd dimension in
##  even characteristic are constructed via the isomorphism to a symplectic
##  group, see for example&nbsp;<Cite Key="Car72a"/>.
##  <P/>
##  For symplectic and orthogonal matrix groups returned by the functions
##  described below, the invariant bilinear form is stored as the value of
##  the attribute <Ref Attr="InvariantBilinearForm"/>.
##  Analogously, the invariant sesquilinear form defining the unitary groups
##  is stored as the value of the attribute
##  <Ref Attr="InvariantSesquilinearForm"/>).
##  The defining quadratic form of orthogonal groups is stored as the value
##  of the attribute <Ref Attr="InvariantQuadraticForm"/>.
##  <#/GAPDoc>
##


#############################################################################
##
#O  GeneralLinearGroupCons( <filter>, <d>, <R> )
##
##  <ManSection>
##  <Oper Name="GeneralLinearGroupCons" Arg='filter, d, R'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareConstructor( "GeneralLinearGroupCons", [ IsGroup, IsInt, IsRing ] );


#############################################################################
##
#F  GeneralLinearGroup( [<filt>, ]<d>, <R> )  . . . . .  general linear group
#F  GL( [<filt>, ]<d>, <R> )
#F  GeneralLinearGroup( [<filt>, ]<d>, <q> )
#F  GL( [<filt>, ]<d>, <q> )
##
##  <#GAPDoc Label="GeneralLinearGroup">
##  <ManSection>
##  <Heading>GeneralLinearGroup</Heading>
##  <Func Name="GeneralLinearGroup" Arg='[filt, ]d, R'
##   Label="for dimension and a ring"/>
##  <Func Name="GL" Arg='[filt, ]d, R'
##   Label="for dimension and a ring"/>
##  <Func Name="GeneralLinearGroup" Arg='[filt, ]d, q'
##   Label="for dimension and field size"/>
##  <Func Name="GL" Arg='[filt, ]d, q'
##   Label="for dimension and field size"/>
##
##  <Description>
##  The first two forms construct a group isomorphic to the general linear
##  group GL( <A>d</A>, <A>R</A> ) of all <M><A>d</A> \times <A>d</A></M>
##  matrices that are invertible over the ring <A>R</A>,
##  in the category given by the filter <A>filt</A>.
##  <P/>
##  The third and the fourth form construct the general linear group over the
##  finite field with <A>q</A> elements.
##  <P/>
##  If <A>filt</A> is not given it defaults to <Ref Func="IsMatrixGroup"/>,
##  and the returned group is the general linear group as a matrix group in
##  its natural action (see also&nbsp;<Ref Func="IsNaturalGL"/>,
##  <Ref Func="IsNaturalGLnZ"/>).
##  <P/>
##  Currently supported rings <A>R</A> are finite fields,
##  the ring <Ref Var="Integers"/>,
##  and residue class rings <C>Integers mod <A>m</A></C>,
##  see <Ref Sect="Residue Class Rings"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> GL(4,3);
##  GL(4,3)
##  gap> GL(2,Integers);
##  GL(2,Integers)
##  gap> GL(3,Integers mod 12);
##  GL(3,Z/12Z)
##  ]]></Example>
##  <P/>
##  <Index Key="OnLines" Subkey="example"><C>OnLines</C></Index>
##  Using the <Ref Func="OnLines"/> operation it is possible to obtain the
##  corresponding projective groups in a permutation action:
##  <P/>
##  <Example><![CDATA[
##  gap> g:=GL(4,3);;Size(g);
##  24261120
##  gap> pgl:=Action(g,Orbit(g,Z(3)^0*[1,0,0,0],OnLines),OnLines);;
##  gap> Size(pgl);
##  12130560
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "GeneralLinearGroup", function ( arg )
  if Length( arg ) = 2 then
    if IsRing( arg[2] ) then
      return GeneralLinearGroupCons( IsMatrixGroup, arg[1], arg[2] );
    elif IsPrimePowerInt( arg[2] ) then
      return GeneralLinearGroupCons( IsMatrixGroup, arg[1], GF( arg[2] ) );
    fi;
  elif Length( arg ) = 3 and IsOperation( arg[1] ) then
    if IsRing( arg[2] ) then
      return GeneralLinearGroupCons( arg[1], arg[2], arg[3] );
    elif IsPrimePowerInt( arg[3] ) then
      return GeneralLinearGroupCons( arg[1], arg[2], GF( arg[3] ) );
    fi;
  fi;
  Error( "usage: GeneralLinearGroup( [<filter>, ]<d>, <R> )" );
end );

DeclareSynonym( "GL", GeneralLinearGroup );


#############################################################################
##
#O  GeneralOrthogonalGroupCons( <filter>, <e>, <d>, <q> )
##
##  <ManSection>
##  <Oper Name="GeneralOrthogonalGroupCons" Arg='filter, e, d, q'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareConstructor( "GeneralOrthogonalGroupCons",
    [ IsGroup, IsInt, IsPosInt, IsPosInt ] );


#############################################################################
##
#F  GeneralOrthogonalGroup( [<filt>, ][<e>, ]<d>, <q> ) .  gen. orthog. group
#F  GO( [<filt>, ][<e>, ]<d>, <q> )
##
##  <#GAPDoc Label="GeneralOrthogonalGroup">
##  <ManSection>
##  <Func Name="GeneralOrthogonalGroup" Arg='[filt, ][e, ]d, q'/>
##  <Func Name="GO" Arg='[filt, ][e, ]d, q'/>
##
##  <Description>
##  constructs a group isomorphic to the
##  general orthogonal group GO( <A>e</A>, <A>d</A>, <A>q</A> ) of those
##  <M><A>d</A> \times <A>d</A></M> matrices over the field with <A>q</A>
##  elements that respect a non-singular quadratic form
##  (see&nbsp;<Ref Func="InvariantQuadraticForm"/>) specified by <A>e</A>,
##  in the category given by the filter <A>filt</A>.
##  <P/>
##  The value of <A>e</A> must be <M>0</M> for odd <A>d</A> (and can
##  optionally be  omitted in this case), respectively one of <M>1</M> or
##  <M>-1</M> for even <A>d</A>.
##  If <A>filt</A> is not given it defaults to <Ref Func="IsMatrixGroup"/>,
##  and the returned group is the general orthogonal group itself.
##  <P/>
##  Note that in&nbsp;<Cite Key="KleidmanLiebeck90"/>,
##  GO is defined as the stabilizer
##  <M>\Delta(V, F, \kappa)</M> of the quadratic form, up to scalars,
##  whereas our GO is called <M>I(V, F, \kappa)</M> there.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "GeneralOrthogonalGroup", function ( arg )

  if   Length( arg ) = 2 then
    return GeneralOrthogonalGroupCons( IsMatrixGroup, 0, arg[1], arg[2] );
  elif Length( arg ) = 3 and ForAll( arg, IsInt ) then
    return GeneralOrthogonalGroupCons( IsMatrixGroup,arg[1],arg[2],arg[3] );
  elif IsOperation( arg[1] ) then
    if   Length( arg ) = 3 then
      return GeneralOrthogonalGroupCons( arg[1], 0, arg[2], arg[3] );
    elif Length( arg ) = 4 then
      return GeneralOrthogonalGroupCons( arg[1], arg[2], arg[3], arg[4] );
    fi;
  fi;
  Error( "usage: GeneralOrthogonalGroup( [<filter>, ][<e>, ]<d>, <q> )" );

end );

DeclareSynonym( "GO", GeneralOrthogonalGroup );


#############################################################################
##
#O  GeneralUnitaryGroupCons( <filter>, <d>, <q> )
##
##  <ManSection>
##  <Oper Name="GeneralUnitaryGroupCons" Arg='filter, d, q'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareConstructor( "GeneralUnitaryGroupCons",
    [ IsGroup, IsPosInt, IsPosInt ] );


#############################################################################
##
#F  GeneralUnitaryGroup( [<filt>, ]<d>, <q> ) . . . . . general unitary group
#F  GU( [<filt>, ]<d>, <q> )
##
##  <#GAPDoc Label="GeneralUnitaryGroup">
##  <ManSection>
##  <Func Name="GeneralUnitaryGroup" Arg='[filt, ]d, q'/>
##  <Func Name="GU" Arg='[filt, ]d, q'/>
##
##  <Description>
##  constructs a group isomorphic to the general unitary group
##  GU( <A>d</A>, <A>q</A> ) of those <M><A>d</A> \times <A>d</A></M>
##  matrices over the field with <M><A>q</A>^2</M> elements
##  that respect a fixed nondegenerate sesquilinear form,
##  in the category given by the filter <A>filt</A>.
##  <P/>
##  If <A>filt</A> is not given it defaults to <Ref Func="IsMatrixGroup"/>,
##  and the returned group is the general unitary group itself.
##  <P/>
##  <Example><![CDATA[
##  gap> GeneralUnitaryGroup( 3, 5 );
##  GU(3,5)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "GeneralUnitaryGroup", function ( arg )

  if Length( arg ) = 2 then
    return GeneralUnitaryGroupCons( IsMatrixGroup, arg[1], arg[2] );
  elif IsOperation( arg[1] ) then

    if Length( arg ) = 3 then
      return GeneralUnitaryGroupCons( arg[1], arg[2], arg[3] );
    fi;
  fi;
  Error( "usage: GeneralUnitaryGroup( [<filter>, ]<d>, <q> )" );

end );

DeclareSynonym( "GU", GeneralUnitaryGroup );


#############################################################################
##
#O  SpecialLinearGroupCons( <filter>, <d>, <R> )
##
##  <ManSection>
##  <Oper Name="SpecialLinearGroupCons" Arg='filter, d, R'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareConstructor( "SpecialLinearGroupCons", [ IsGroup, IsInt, IsRing ] );


#############################################################################
##
#F  SpecialLinearGroup( [<filt>, ]<d>, <R> )  . . . . .  special linear group
#F  SL( [<filt>, ]<d>, <R> )
#F  SpecialLinearGroup( [<filt>, ]<d>, <q> )
#F  SL( [<filt>, ]<d>, <q> )
##
##  <#GAPDoc Label="SpecialLinearGroup">
##  <ManSection>
##  <Heading>SpecialLinearGroup</Heading>
##  <Func Name="SpecialLinearGroup" Arg='[filt, ]d, R'
##   Label="for dimension and a ring"/>
##  <Func Name="SL" Arg='[filt, ]d, R'
##   Label="for dimension and a ring"/>
##  <Func Name="SpecialLinearGroup" Arg='[filt, ]d, q'
##   Label="for dimension and a field size"/>
##  <Func Name="SL" Arg='[filt, ]d, q'
##   Label="for dimension and a field size"/>
##
##  <Description>
##  The first two forms construct a group isomorphic to the special linear
##  group SL( <A>d</A>, <A>R</A> ) of all those
##  <M><A>d</A> \times <A>d</A></M> matrices over the ring <A>R</A> whose
##  determinant is the identity of <A>R</A>,
##  in the category given by the filter <A>filt</A>.
##  <P/>
##  The third and the fourth form construct the special linear group over the
##  finite field with <A>q</A> elements.
##  <P/>
##  If <A>filt</A> is not given it defaults to <Ref Func="IsMatrixGroup"/>,
##  and the returned group is the special linear group as a matrix group in
##  its natural action (see also&nbsp;<Ref Func="IsNaturalSL"/>,
##  <Ref Func="IsNaturalSLnZ"/>).
##  <P/>
##  Currently supported rings <A>R</A> are finite fields,
##  the ring <Ref Var="Integers"/>,
##  and residue class rings <C>Integers mod <A>m</A></C>,
##  see <Ref Sect="Residue Class Rings"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> SpecialLinearGroup(2,2);
##  SL(2,2)
##  gap> SL(3,Integers);
##  SL(3,Integers)
##  gap> SL(4,Integers mod 4);
##  SL(4,Z/4Z)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "SpecialLinearGroup", function ( arg )
  if Length( arg ) = 2  then
    if IsRing( arg[2] ) then
      return SpecialLinearGroupCons( IsMatrixGroup, arg[1], arg[2] );
    elif IsPrimePowerInt( arg[2] ) then
      return SpecialLinearGroupCons( IsMatrixGroup, arg[1], GF( arg[2] ) );
    fi;
  elif Length( arg ) = 3 and IsOperation( arg[1] ) then
    if IsRing( arg[2] ) then
      return SpecialLinearGroupCons( arg[1], arg[2], arg[3] );
    elif IsPrimePowerInt( arg[3] ) then
      return SpecialLinearGroupCons( arg[1], arg[2], GF( arg[3] ) );
    fi;
  fi;
  Error( "usage: SpecialLinearGroup( [<filter>, ]<d>, <R> )" );

end );

DeclareSynonym( "SL", SpecialLinearGroup );


#############################################################################
##
#O  SpecialOrthogonalGroupCons( <filter>, <e>, <d>, <q> )
##
##  <ManSection>
##  <Oper Name="SpecialOrthogonalGroupCons" Arg='filter, e, d, q'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareConstructor( "SpecialOrthogonalGroupCons",
    [ IsGroup, IsInt, IsPosInt, IsPosInt ] );


#############################################################################
##
#F  SpecialOrthogonalGroup( [<filt>, ][<e>, ]<d>, <q> ) . spec. orthog. group
#F  SO( [<filt>, ][<e>, ]<d>, <q> )
##
##  <#GAPDoc Label="SpecialOrthogonalGroup">
##  <ManSection>
##  <Func Name="SpecialOrthogonalGroup" Arg='[filt, ][e, ]d, q'/>
##  <Func Name="SO" Arg='[filt, ][e, ]d, q'/>
##
##  <Description>
##  <Ref Func="SpecialOrthogonalGroup"/> returns a group isomorphic to the 
##  special orthogonal group SO( <A>e</A>, <A>d</A>, <A>q</A> ),
##  which is the subgroup of all those matrices in the general orthogonal
##  group (see&nbsp;<Ref Func="GeneralOrthogonalGroup"/>) that have
##  determinant one, in the category given by the filter <A>filt</A>.
##  (The index of SO( <A>e</A>, <A>d</A>, <A>q</A> ) in
##  GO( <A>e</A>, <A>d</A>, <A>q</A> ) is <M>2</M> if <A>q</A> is
##  odd, and <M>1</M> if <A>q</A> is even.)
##  <!-- Also interesting is the group Omega( <A>e</A>, <A>d</A>, <A>q</A> ), which is always of-->
##  <!-- index <M>2</M> in SO( <A>e</A>, <A>d</A>, <A>q</A> );-->
##  <!-- this is the subgroup of all matrices with square spinor norm in odd-->
##  <!-- characteristic or Dickson invariant <M>0</M> in even characteristic.-->
##  <P/>
##  If <A>filt</A> is not given it defaults to <Ref Func="IsMatrixGroup"/>,
##  and the returned group is the special orthogonal group itself.
##  <P/>
##  <Example><![CDATA[
##  gap> GeneralOrthogonalGroup( 3, 7 );
##  GO(0,3,7)
##  gap> GeneralOrthogonalGroup( -1, 4, 3 );
##  GO(-1,4,3)
##  gap> SpecialOrthogonalGroup( 1, 4, 4 );
##  GO(+1,4,4)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "SpecialOrthogonalGroup", function ( arg )

  if   Length( arg ) = 2 then
    return SpecialOrthogonalGroupCons( IsMatrixGroup, 0, arg[1], arg[2] );
  elif Length( arg ) = 3 and ForAll( arg, IsInt ) then
    return SpecialOrthogonalGroupCons( IsMatrixGroup,arg[1],arg[2],arg[3] );
  elif IsOperation( arg[1] ) then
    if   Length( arg ) = 3 then
      return SpecialOrthogonalGroupCons( arg[1], 0, arg[2], arg[3] );
    elif Length( arg ) = 4 then
      return SpecialOrthogonalGroupCons( arg[1], arg[2], arg[3], arg[4] );
    fi;
  fi;
  Error( "usage: SpecialOrthogonalGroup( [<filter>, ][<e>, ]<d>, <q> )" );

end );

DeclareSynonym( "SO", SpecialOrthogonalGroup );


#############################################################################
##
#O  SpecialUnitaryGroupCons( <filter>, <d>, <q> )
##
##  <ManSection>
##  <Oper Name="SpecialUnitaryGroupCons" Arg='filter, d, q'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareConstructor( "SpecialUnitaryGroupCons",
    [ IsGroup, IsPosInt, IsPosInt ] );


#############################################################################
##
#F  SpecialUnitaryGroup( [<filt>, ]<d>, <q> ) . . . . . general unitary group
#F  SU( [<filt>, ]<d>, <q> )
##
##  <#GAPDoc Label="SpecialUnitaryGroup">
##  <ManSection>
##  <Func Name="SpecialUnitaryGroup" Arg='[filt, ]d, q'/>
##  <Func Name="SU" Arg='[filt, ]d, q'/>
##
##  <Description>
##  constructs a group isomorphic to the special unitary group
##  GU(<A>d</A>, <A>q</A>) of those <M><A>d</A> \times <A>d</A></M> matrices
##  over the field with <M><A>q</A>^2</M> elements
##  whose determinant is the identity of the field and that respect a fixed
##  nondegenerate sesquilinear form,
##  in the category given by the filter <A>filt</A>.
##  <P/>
##  If <A>filt</A> is not given it defaults to <Ref Func="IsMatrixGroup"/>,
##  and the returned group is the special unitary group itself.
##  <P/>
##  <Example><![CDATA[
##  gap> SpecialUnitaryGroup( 3, 5 );
##  SU(3,5)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "SpecialUnitaryGroup", function ( arg )

  if Length( arg ) = 2 then
    return SpecialUnitaryGroupCons( IsMatrixGroup, arg[1], arg[2] );
  elif IsOperation( arg[1] ) then

    if Length( arg ) = 3 then
      return SpecialUnitaryGroupCons( arg[1], arg[2], arg[3] );
    fi;
  fi;
  Error( "usage: SpecialUnitaryGroup( [<filter>, ]<d>, <q> )" );

end );

DeclareSynonym( "SU", SpecialUnitaryGroup );


#############################################################################
##
#O  SymplecticGroupCons( <filter>, <d>, <q> )
##
##  <ManSection>
##  <Oper Name="SymplecticGroupCons" Arg='filter, d, q'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareConstructor( "SymplecticGroupCons", [ IsGroup, IsPosInt, IsPosInt ] );


#############################################################################
##
#F  SymplecticGroup( [<filt>, ]<d>, <q> ) . . . . . . . . .  symplectic group
#F  Sp( [<filt>, ]<d>, <q> )
#F  SP( [<filt>, ]<d>, <q> )
##
##  <#GAPDoc Label="SymplecticGroup">
##  <ManSection>
##  <Func Name="SymplecticGroup" Arg='[filt, ]d, q'/>
##  <Func Name="Sp" Arg='[filt, ]d, q'/>
##  <Func Name="SP" Arg='[filt, ]d, q'/>
##
##  <Description>
##  constructs a group isomorphic to the symplectic group
##  Sp( <A>d</A>, <A>q</A> ) of those <M><A>d</A> \times <A>d</A></M>
##  matrices over the field with <A>q</A> elements
##  that respect a fixed nondegenerate symplectic form,
##  in the category given by the filter <A>filt</A>.
##  <P/>
##  If <A>filt</A> is not given it defaults to <Ref Func="IsMatrixGroup"/>,
##  and the returned group is the symplectic group itself.
##  <P/>
##  <Example><![CDATA[
##  gap> SymplecticGroup( 4, 2 );
##  Sp(4,2)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "SymplecticGroup", function ( arg )

  if Length( arg ) = 2 then
    return SymplecticGroupCons( IsMatrixGroup, arg[1], arg[2] );
  elif IsOperation( arg[1] ) then

    if Length( arg ) = 3 then
      return SymplecticGroupCons( arg[1], arg[2], arg[3] );
    fi;
  fi;
  Error( "usage: SymplecticGroup( [<filter>, ]<d>, <q> )" );

end );

DeclareSynonym( "Sp", SymplecticGroup );
DeclareSynonym( "SP", SymplecticGroup );


#############################################################################
##
#O  GeneralSemilinearGroupCons( <filter>, <d>, <q> )
##
##  <ManSection>
##  <Oper Name="GeneralSemilinearGroupCons" Arg='filter, d, q'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareConstructor( "GeneralSemilinearGroupCons",
    [ IsGroup, IsPosInt, IsPosInt ] );


#############################################################################
##
#F  GeneralSemilinearGroup( [<filt>, ]<d>, <q> )  .  general semilinear group
#F  GammaL( [<filt>, ]<d>, <q> )
##
##  <#GAPDoc Label="GeneralSemilinearGroup">
##  <ManSection>
##  <Func Name="GeneralSemilinearGroup" Arg='[filt, ]d, q'/>
##  <Func Name="GammaL" Arg='[filt, ]d, q'/>
##
##  <Description>
##  <Ref Func="GeneralSemilinearGroup"/> returns a group isomorphic to the
##  general semilinear group <M>\Gamma</M>L( <A>d</A>, <A>q</A> ) of
##  semilinear mappings of the vector space
##  <C>GF( </C><A>q</A><C> )^</C><A>d</A>.
##  <P/>
##  If <A>filt</A> is not given it defaults to <Ref Func="IsMatrixGroup"/>,
##  and the returned group consists of matrices of dimension
##  <A>d</A> <M>f</M> over the field with <M>p</M> elements,
##  where <A>q</A> <M>= p^f</M>, for a prime integer <M>p</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "GeneralSemilinearGroup", function( arg )
  if Length( arg ) = 2 then
    return GeneralSemilinearGroupCons( IsMatrixGroup, arg[1], arg[2] );
  elif Length( arg ) = 3 and IsOperation( arg[1] ) then
    return GeneralSemilinearGroupCons( arg[1], arg[2], arg[3] );
  fi;
  Error( "usage: GeneralSemilinearGroup( [<filter>, ]<d>, <q> )" );
end );

DeclareSynonym( "GammaL", GeneralSemilinearGroup );


#############################################################################
##
#O  SpecialSemilinearGroupCons( <filter>, <d>, <q> )
##
##  <ManSection>
##  <Oper Name="SpecialSemilinearGroupCons" Arg='filter, d, q'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareConstructor( "SpecialSemilinearGroupCons",
    [ IsGroup, IsPosInt, IsPosInt ] );


#############################################################################
##
#F  SpecialSemilinearGroup( [<filt>, ]<d>, <q> )  .  special semilinear group
#F  SigmaL( [<filt>, ]<d>, <q> )
##
##  <#GAPDoc Label="SpecialSemilinearGroup">
##  <ManSection>
##  <Func Name="SpecialSemilinearGroup" Arg='[filt, ]d, q'/>
##  <Func Name="SigmaL" Arg='[filt, ]d, q'/>
##
##  <Description>
##  <Ref Func="SpecialSemilinearGroup"/> returns a group isomorphic to the
##  special semilinear group <M>\Sigma</M>L( <A>d</A>, <A>q</A> ) of those
##  semilinear mappings of the vector space
##  <C>GF( </C><A>q</A><C> )^</C><A>d</A> 
##  (see <Ref Func="GeneralSemilinearGroup"/>)
##  whose linear part has determinant one.
##  <P/>
##  If <A>filt</A> is not given it defaults to <Ref Func="IsMatrixGroup"/>,
##  and the returned group consists of matrices of dimension
##  <A>d</A> <M>f</M> over the field with <M>p</M> elements,
##  where <A>q</A> <M>= p^f</M>, for a prime integer <M>p</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "SpecialSemilinearGroup", function( arg )
  if Length( arg ) = 2 then
    return SpecialSemilinearGroupCons( IsMatrixGroup, arg[1], arg[2] );
  elif Length( arg ) = 3 and IsOperation( arg[1] ) then
    return SpecialSemilinearGroupCons( arg[1], arg[2], arg[3] );
  fi;
  Error( "usage: SpecialSemilinearGroup( [<filter>, ]<d>, <q> )" );
end );

DeclareSynonym( "SigmaL", SpecialSemilinearGroup );


#############################################################################
##
#F  DECLARE_PROJECTIVE_GROUPS_OPERATION( ... )
##
BindGlobal("DECLARE_PROJECTIVE_GROUPS_OPERATION",
  # (<name>,<abbreviation>,<fieldextdeg>,<sizefunc-or-fail>)
  function(nam,abbr,extdeg,szf)
local pnam,cons,opr;
  opr:=VALUE_GLOBAL(nam);
  pnam:=Concatenation("Projective",nam);
  cons:=NewConstructor(Concatenation(pnam,"Cons"),[IsGroup,IsInt,IsInt]);
  BindGlobal(Concatenation(pnam,"Cons"),cons);
  BindGlobal(pnam,function(arg)
    if Length(arg) = 2  then
      return cons( IsPermGroup, arg[1], arg[2] );
    elif IsOperation(arg[1]) then
      if Length(arg) = 3  then
	return cons( arg[1], arg[2], arg[3] );
      fi;
    fi;
    Error( "usage: ",pnam,"( [<filter>, ]<d>, <q> )" );
  end );
  DeclareSynonym(Concatenation("P",abbr),VALUE_GLOBAL(pnam));

  # install a method to get the permutation action on lines
  InstallMethod( cons,"action on lines",
      [ IsPermGroup, IsPosInt,IsPosInt ],
  function(fil,n,q)
  local g,f,p;
    g:=opr(IsMatrixGroup,n,q);
    f:=GF(q^extdeg);
    p:=ProjectiveActionOnFullSpace(g,f,n);
    if szf<>fail then
      SetSize(p,szf(n,q,g));
    fi;
    return p;
  end);

end);


#############################################################################
##
#F  ProjectiveGeneralLinearGroup( [<filt>, ]<d>, <q> )
#F  PGL( [<filt>, ]<d>, <q> )
##
##  <#GAPDoc Label="ProjectiveGeneralLinearGroup">
##  <ManSection>
##  <Func Name="ProjectiveGeneralLinearGroup" Arg='[filt, ]d, q'/>
##  <Func Name="PGL" Arg='[filt, ]d, q'/>
##
##  <Description>
##  constructs a group isomorphic to the projective general linear group
##  PGL( <A>d</A>, <A>q</A> ) of those <M><A>d</A> \times <A>d</A></M>
##  matrices over the field with <A>q</A> elements, modulo the
##  centre, in the category given by the filter <A>filt</A>.
##  <P/>
##  If <A>filt</A> is not given it defaults to <Ref Func="IsPermGroup"/>,
##  and the returned group is the action on lines of the underlying vector
##  space.
##  <P/>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DECLARE_PROJECTIVE_GROUPS_OPERATION("GeneralLinearGroup","GL",1,
  # size function
  function(n,q,g)
    return Size(g)/(q-1);
  end);


#############################################################################
##
#F  ProjectiveSpecialLinearGroup( [<filt>, ]<d>, <q> )
#F  PSL( [<filt>, ]<d>, <q> )
##
##  <#GAPDoc Label="ProjectiveSpecialLinearGroup">
##  <ManSection>
##  <Func Name="ProjectiveSpecialLinearGroup" Arg='[filt, ]d, q'/>
##  <Func Name="PSL" Arg='[filt, ]d, q'/>
##
##  <Description>
##  constructs a group isomorphic to the projective special linear group
##  PSL( <A>d</A>, <A>q</A> ) of those <M><A>d</A> \times <A>d</A></M>
##  matrices over the field with <A>q</A> elements whose determinant is the
##  identity of the field, modulo the centre,
##  in the category given by the filter <A>filt</A>.
##  <P/>
##  If <A>filt</A> is not given it defaults to <Ref Func="IsPermGroup"/>,
##  and the returned group is the action on lines of the underlying vector
##  space.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DECLARE_PROJECTIVE_GROUPS_OPERATION("SpecialLinearGroup","SL",1,
  # size function
  function(n,q,g)
    return Size(g)/Gcd(n,q-1);
  end);


#############################################################################
##
#F  ProjectiveGeneralUnitaryGroup( [<filt>, ]<d>, <q> )
#F  PGU( [<filt>, ]<d>, <q> )
##
##  <#GAPDoc Label="ProjectiveGeneralUnitaryGroup">
##  <ManSection>
##  <Func Name="ProjectiveGeneralUnitaryGroup" Arg='[filt, ]d, q'/>
##  <Func Name="PGU" Arg='[filt, ]d, q'/>
##
##  <Description>
##  constructs a group isomorphic to the projective general unitary group
##  PGU( <A>d</A>, <A>q</A> ) of those <M><A>d</A> \times <A>d</A></M>
##  matrices over the field with <M><A>q</A>^2</M> elements that respect
##  a fixed nondegenerate sesquilinear form,
##  modulo the centre, in the category given by the filter <A>filt</A>.
##  <P/>
##  If <A>filt</A> is not given it defaults to <Ref Func="IsPermGroup"/>,
##  and the returned group is the action on lines of the underlying vector
##  space.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DECLARE_PROJECTIVE_GROUPS_OPERATION("GeneralUnitaryGroup","GU",2,
  # size function
  function(n,q,g)
    return Size(g)/(q+1);
  end);


#############################################################################
##
#F  ProjectiveSpecialUnitaryGroup( [<filt>, ]<d>, <q> )
#F  PSU( [<filt>, ]<d>, <q> )
##
##  <#GAPDoc Label="ProjectiveSpecialUnitaryGroup">
##  <ManSection>
##  <Func Name="ProjectiveSpecialUnitaryGroup" Arg='[filt, ]d, q'/>
##  <Func Name="PSU" Arg='[filt, ]d, q'/>
##
##  <Description>
##  constructs a group isomorphic to the projective special unitary group
##  PSU( <A>d</A>, <A>q</A> ) of those <M><A>d</A> \times <A>d</A></M>
##  matrices over the field with <M><A>q</A>^2</M> elements that respect
##  a fixed nondegenerate sesquilinear form and have determinant 1,
##  modulo the centre, in the category given by the filter <A>filt</A>.
##  <P/>
##  If <A>filt</A> is not given it defaults to <Ref Func="IsPermGroup"/>,
##  and the returned group is the action on lines of the underlying vector
##  space.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DECLARE_PROJECTIVE_GROUPS_OPERATION("SpecialUnitaryGroup","SU",2,
  # size function
  function(n,q,g)
    return Size(g)/Gcd(n,q+1);
  end);


#############################################################################
##
#F  ProjectiveSymplecticGroup( [<filt>, ]<d>, <q> )
#F  PSP( [<filt>, ]<d>, <q> )
#F  PSp( [<filt>, ]<d>, <q> )
##
##  <#GAPDoc Label="ProjectiveSymplecticGroup">
##  <ManSection>
##  <Func Name="ProjectiveSymplecticGroup" Arg='[filt, ]d, q'/>
##  <Func Name="PSP" Arg='[filt, ]d, q'/>
##  <Func Name="PSp" Arg='[filt, ]d, q'/>
##
##  <Description>
##  constructs a group isomorphic to the projective symplectic group
##  PSp(<A>d</A>,<A>q</A>) of those <M><A>d</A> \times <A>d</A></M> matrices
##  over the field with <A>q</A> elements that respect a fixed nondegenerate
##  symplectic form, modulo the centre,
##  in the category given by the filter <A>filt</A>.
##  <P/>
##  If <A>filt</A> is not given it defaults to <Ref Func="IsPermGroup"/>,
##  and the returned group is the action on lines of the underlying vector
##  space.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DECLARE_PROJECTIVE_GROUPS_OPERATION("SymplecticGroup","SP",1,
  # size function
  function(n,q,g)
    return Size(g)/Gcd(2,q-1);
  end);
DeclareSynonym( "PSp", PSP );


#############################################################################
##
#E

