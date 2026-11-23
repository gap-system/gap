#############################################################################
##
##  conformal.gd
##
##  Provide 'ConformalSymplecticGroup', 'ConformalOrthogonalGroup',
##  'ConformalUnitaryGroup', and related functions.
##


#############################################################################
##
#A  InvariantBilinearFormUpToScalars( <matgrp> )
##
##  <#GAPDoc Label="InvariantBilinearFormUpToScalars">
##  <ManSection>
##  <Attr Name="InvariantBilinearFormUpToScalars" Arg='matgrp'/>
##
##  <Description>
##  This attribute describes a bilinear form that is invariant up to scalars
##  under the matrix group <A>matgrp</A>.
##  The form is given by a record with the component <C>matrix</C>
##  which is a matrix <M>J</M> such that for every generator <M>g</M> of
##  <A>matgrp</A> the equation <M>g \cdot J \cdot g^{tr} = \lambda(g) J</M>
##  holds, for <M>\lambda(g)</M> in the
##  <Ref Attr="FieldOfMatrixGroup"/> value of <A>matgrp</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "InvariantBilinearFormUpToScalars", IsMatrixGroup );


#############################################################################
##
#P  IsFullSubgroupGLRespectingBilinearFormUpToScalars( <matgrp> )
##
##  <#GAPDoc Label="IsFullSubgroupGLRespectingBilinearFormUpToScalars">
##  <ManSection>
##  <Prop Name="IsFullSubgroupGLRespectingBilinearFormUpToScalars"
##  Arg='matgrp'/>
##
##  <Description>
##  This property tests whether the matrix group <A>matgrp</A> is the full
##  subgroup of GL respecting, up to scalars, the form stored as the value of
##  <Ref Attr="InvariantBilinearFormUpToScalars"/> for <A>matgrp</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsFullSubgroupGLRespectingBilinearFormUpToScalars",
    IsMatrixGroup );

InstallTrueMethod( IsGroup,
    IsFullSubgroupGLRespectingBilinearFormUpToScalars );


#############################################################################
##
#A  InvariantQuadraticFormUpToScalars( <matgrp> )
##
##  <#GAPDoc Label="InvariantQuadraticFormUpToScalars">
##  <ManSection>
##  <Attr Name="InvariantQuadraticFormUpToScalars" Arg='matgrp'/>
##
##  <Description>
##  This attribute describes a quadratic form that is invariant up to scalars
##  under the matrix group <A>matgrp</A>.
##  The form is given by a record with the components <C>matrix</C>
##  and <C>baseDomain</C>,
##  where <C>matrix</C> is a matrix <M>Q</M> such that for every generator
##  <M>g</M> of <A>matgrp</A> the equation
##  <M>q(v g) = \lambda(g) q(v)</M> holds for all vectors <M>v</M>,
##  with <M>q(v) = v Q v^{tr}</M> and <M>\lambda(g)</M> in the field
##  <C>baseDomain</C>.
##  (See <Ref Attr="InvariantQuadraticForm"/> for the relation between
##  quadratic forms and matrices.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "InvariantQuadraticFormUpToScalars", IsMatrixGroup );


#############################################################################
##
#P  IsFullSubgroupGLRespectingQuadraticFormUpToScalars( <matgrp> )
##
##  <#GAPDoc Label="IsFullSubgroupGLRespectingQuadraticFormUpToScalars">
##  <ManSection>
##  <Prop Name="IsFullSubgroupGLRespectingQuadraticFormUpToScalars"
##  Arg='matgrp'/>
##
##  <Description>
##  This property tests whether the matrix group <A>matgrp</A> is the full
##  subgroup of GL respecting, up to scalars, the form stored as the value of
##  <Ref Attr="InvariantQuadraticFormUpToScalars"/> for <A>matgrp</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsFullSubgroupGLRespectingQuadraticFormUpToScalars",
    IsMatrixGroup );

InstallTrueMethod( IsGroup,
    IsFullSubgroupGLRespectingQuadraticFormUpToScalars );


#############################################################################
##
#A  InvariantSesquilinearFormUpToScalars( <matgrp> )
##
##  <#GAPDoc Label="InvariantSesquilinearFormUpToScalars">
##  <ManSection>
##  <Attr Name="InvariantSesquilinearFormUpToScalars" Arg='matgrp'/>
##
##  <Description>
##  This attribute describes a sesquilinear form that is invariant up to
##  scalars under the matrix group <A>matgrp</A>.
##  The form is given by a record with the components <C>matrix</C>
##  and <C>baseDomain</C>,
##  where <C>matrix</C> is a matrix <M>J</M> such that for every generator
##  <M>g</M> of <A>matgrp</A> the equation
##  <M>g \cdot J \cdot (g^{tr})^f = \lambda(g) J</M> holds,
##  for <M>\lambda(g)</M> in the field <C>baseDomain</C>
##  and its automorphism <M>f</M> as described for
##  <Ref Attr="InvariantSesquilinearForm"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "InvariantSesquilinearFormUpToScalars", IsMatrixGroup );


#############################################################################
##
#P  IsFullSubgroupGLRespectingSesquilinearFormUpToScalars( <matgrp> )
##
##  <#GAPDoc Label="IsFullSubgroupGLRespectingSesquilinearFormUpToScalars">
##  <ManSection>
##  <Prop Name="IsFullSubgroupGLRespectingSesquilinearFormUpToScalars"
##  Arg='matgrp'/>
##
##  <Description>
##  This property tests whether the matrix group <A>matgrp</A> is the full
##  subgroup of GL respecting, up to scalars, the form stored as the value of
##  <Ref Attr="InvariantSesquilinearFormUpToScalars"/> for <A>matgrp</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsFullSubgroupGLRespectingSesquilinearFormUpToScalars",
    IsMatrixGroup );

InstallTrueMethod( IsGroup,
    IsFullSubgroupGLRespectingSesquilinearFormUpToScalars );


#############################################################################
##
#O  ConformalSymplecticGroupCons( <filter>, <d>, <R> )
#O  ConformalSymplecticGroupCons( <filter>, <d>, <q> )
##
DeclareConstructor( "ConformalSymplecticGroupCons", [ IsGroup, IsPosInt, IsRing ] );
DeclareConstructor( "ConformalSymplecticGroupCons", [ IsGroup, IsPosInt, IsPosInt ] );


#############################################################################
##
#F  ConformalSymplecticGroup( [<filt>, ]<d>, <R>[, <form>] ) conf. sympl. gp.
#F  ConformalSymplecticGroup( [<filt>, ]<d>, <q>[, <form>] ) conf. sympl. gp.
#F  ConformalSymplecticGroup( [<filt>, ]<form> )   conformal symplectic group
#F  CSp( [<filt>, ]<d>, <R>[, <form>] ) . . . . .  conformal symplectic group
#F  CSp( [<filt>, ]<d>, <q>[, <form>] ) . . . . .  conformal symplectic group
#F  CSp( [<filt>, ]<form> ) . . . . . . . . . . .  conformal symplectic group
##
##  <#GAPDoc Label="ConformalSymplecticGroup">
##  <ManSection>
##  <Heading>ConformalSymplecticGroup</Heading>
##  <Func Name="ConformalSymplecticGroup" Arg='[filt, ]d, R[, form]'
##   Label="for dimension and a ring"/>
##  <Func Name="ConformalSymplecticGroup" Arg='[filt, ]d, q[, form]'
##   Label="for dimension and field size"/>
##  <Func Name="ConformalSymplecticGroup" Arg='[filt, ]form'
##   Label="for form"/>
##  <Func Name="CSp" Arg='[filt, ]d, R[, form]'
##   Label="for dimension and a ring"/>
##  <Func Name="CSp" Arg='[filt, ]d, q[, form]'
##   Label="for dimension and field size"/>
##  <Func Name="CSp" Arg='[filt, ]form'
##   Label="for form"/>
##
##  <Description>
##  constructs a group isomorphic to the conformal symplectic group
##  CSp( <A>d</A>, <A>R</A> ) of those <M><A>d</A> \times <A>d</A></M>
##  matrices over the ring <A>R</A> or the field with <A>q</A> elements,
##  respectively,
##  that respect a fixed nondegenerate symplectic form up to scalars,
##  in the category given by the filter <A>filt</A>.
##  <P/>
##  Currently only finite fields <A>R</A> are supported.
##  <P/>
##  If <A>filt</A> is not given it defaults to <Ref Filt="IsMatrixGroup"/>,
##  and the returned group is the conformal symplectic group itself.
##  Another supported value for <A>filt</A> is
##  <Ref Filt="IsPermGroup"/>;
##  in this case, the argument <A>form</A> is not supported.
##  <P/>
##  If version at least 1.2.15 of the <Package>Forms</Package> package is
##  loaded and the arguments describe a matrix group over a finite field then
##  the desired bilinear form can be specified via <A>form</A>,
##  which can be either a matrix
##  or a form object in <Ref Filt="IsBilinearForm" BookName="Forms"/>
##  or a group with stored <Ref Attr="InvariantBilinearForm"/> or
##  <Ref Attr="InvariantBilinearFormUpToScalars"/> value
##  (and then this form is taken).
##  <P/>
##  A given <A>form</A> determines <A>d</A>, and also <A>R</A>
##  except if <A>form</A> is a matrix that does not store its
##  <Ref Attr="BaseDomain" Label="for a matrix object"/> value.
##  These parameters can be entered, and an error is signalled if they do
##  not fit to the given <A>form</A>.
##  <P/>
##  If <A>form</A> is not given then a default is chosen as described in the
##  introduction to Section <Ref Sect="Classical Groups"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> g:= ConformalSymplecticGroup( 4, 2 );
##  CSp(4,2)
##  gap> Size( g );
##  720
##  gap> StructureDescription( g );
##  "S6"
##  gap> ConformalSymplecticGroup( IsPermGroup, 4, 2 );
##  Perm_CSp(4,2)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConformalSymplecticGroup" );

DeclareSynonym( "CSp", ConformalSymplecticGroup );


#############################################################################
##
#O  ConformalOrthogonalGroupCons( <filter>, <e>, <d>, <q> )
#O  ConformalOrthogonalGroupCons( <filter>, <e>, <d>, <R> )
##
DeclareConstructor( "ConformalOrthogonalGroupCons",
    [ IsGroup, IsInt, IsPosInt, IsPosInt ] );
DeclareConstructor( "ConformalOrthogonalGroupCons",
    [ IsGroup, IsInt, IsPosInt, IsRing ] );


#############################################################################
##
#F  ConformalOrthogonalGroup( [<filt>, ][<e>, ]<d>, <q>[, <form>] )
#F  ConformalOrthogonalGroup( [<filt>, ]<form> )
#F  CO( [<filt>, ][<e>, ]<d>, <q>[, <form>] )
#F  CO( [<filt>, ]<form> )
##
##  <#GAPDoc Label="ConformalOrthogonalGroup">
##  <ManSection>
##  <Func Name="ConformalOrthogonalGroup" Arg='[filt, ][e, ]d, q[, form]'/>
##  <Func Name="ConformalOrthogonalGroup" Arg='[filt, ]form'
##   Label="for a form"/>
##  <Func Name="CO" Arg='[filt, ][e, ]d, q[, form]'/>
##  <Func Name="CO" Arg='[filt, ]form' Label="for a form"/>
##
##  <Description>
##  constructs a group isomorphic to the conformal orthogonal group
##  CO( <A>e</A>, <A>d</A>, <A>q</A> ) of those
##  <M><A>d</A> \times <A>d</A></M> matrices over the field with <A>q</A>
##  elements that respect a non-singular quadratic form specified by
##  <A>e</A> up to scalars, in the category given by the filter <A>filt</A>.
##  <P/>
##  The arguments <A>filt</A>, <A>e</A>, <A>d</A>, <A>q</A>, and
##  <A>form</A> have the same meaning as for
##  <Ref Func="GeneralOrthogonalGroup"/>,
##  except that a group given as <A>form</A> may also store an
##  <Ref Attr="InvariantQuadraticFormUpToScalars"/> value,
##  and that version at least 1.3.1 of the <Package>Forms</Package> package
##  is needed for <A>form</A>.
##  Without <A>form</A>, the matrix group
##  CO( <A>e</A>, <A>d</A>, <A>q</A> ) contains
##  GO( <A>e</A>, <A>d</A>, <A>q</A> ).
##  <P/>
##  In&nbsp;<Cite Key="KleidmanLiebeck90"/>, this group is called
##  <M>\Delta(V, F, \kappa)</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> g:= ConformalOrthogonalGroup( 1, 4, 3 );
##  CO(+1,4,3)
##  gap> Size( g ) / Size( GO( 1, 4, 3 ) );
##  2
##  gap> ConformalOrthogonalGroup( 5, 3 );
##  CO(0,5,3)
##  gap> ConformalOrthogonalGroup( IsPermGroup, -1, 4, 3 );
##  Perm_CO(-1,4,3)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConformalOrthogonalGroup" );

DeclareSynonym( "CO", ConformalOrthogonalGroup );


#############################################################################
##
#O  ConformalUnitaryGroupCons( <filter>, <d>, <q> )
##
DeclareConstructor( "ConformalUnitaryGroupCons",
    [ IsGroup, IsPosInt, IsPosInt ] );


#############################################################################
##
#F  ConformalUnitaryGroup( [<filt>, ]<d>, <q>[, <form>] )
#F  ConformalUnitaryGroup( [<filt>, ]<form> )
#F  CU( [<filt>, ]<d>, <q>[, <form>] )
#F  CU( [<filt>, ]<form> )
##
##  <#GAPDoc Label="ConformalUnitaryGroup">
##  <ManSection>
##  <Func Name="ConformalUnitaryGroup" Arg='[filt, ]d, q[, form]'/>
##  <Func Name="ConformalUnitaryGroup" Arg='[filt, ]form'
##   Label="for a form"/>
##  <Func Name="CU" Arg='[filt, ]d, q[, form]'/>
##  <Func Name="CU" Arg='[filt, ]form' Label="for a form"/>
##
##  <Description>
##  constructs a group isomorphic to the conformal unitary group
##  CU( <A>d</A>, <A>q</A> ) of those <M><A>d</A> \times <A>d</A></M>
##  matrices over the field with <M><A>q</A>^2</M> elements
##  that respect a fixed nondegenerate sesquilinear form up to scalars,
##  in the category given by the filter <A>filt</A>.
##  <P/>
##  The arguments <A>filt</A>, <A>d</A>, <A>q</A>, and <A>form</A> have
##  the same meaning as for <Ref Func="GeneralUnitaryGroup"/>,
##  except that a group given as <A>form</A> may also store an
##  <Ref Attr="InvariantSesquilinearFormUpToScalars"/> value,
##  and that version at least 1.3.1 of the <Package>Forms</Package> package
##  is needed for <A>form</A>.
##  Without <A>form</A>, the matrix group
##  CU( <A>d</A>, <A>q</A> ) contains GU( <A>d</A>, <A>q</A> ).
##  <P/>
##  <Example><![CDATA[
##  gap> g:= ConformalUnitaryGroup( 3, 3 );
##  CU(3,3)
##  gap> Size( g ) / Size( GU( 3, 3 ) );
##  2
##  gap> ConformalUnitaryGroup( IsPermGroup, 3, 3 );
##  Perm_CU(3,3)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConformalUnitaryGroup" );

DeclareSynonym( "CU", ConformalUnitaryGroup );
