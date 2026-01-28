#############################################################################
##
##  conformal.gd
##
##  Provide 'ConformalSymplecticGroup' and related functions.
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
