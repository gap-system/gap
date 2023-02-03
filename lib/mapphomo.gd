#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, and Heiko Theißen.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the definitions of properties of mappings preserving
##  algebraic structure.
##
##  1. properties and attributes of gen. mappings that respect multiplication
##  2. properties and attributes of gen. mappings that respect addition
##  3. properties and attributes of gen. mappings that respect scalar mult.
##  4. properties and attributes of gen. mappings that respect multiplicative
##     and additive structure
##  5. properties and attributes of gen. mappings that transform
##     multiplication into addition
##  6. properties and attributes of gen. mappings that transform addition
##     into multiplication
##


#############################################################################
##
##  1. properties and attributes of gen. mappings that respect multiplication
##

#############################################################################
##
#P  RespectsMultiplication( <mapp> )
##
##  <#GAPDoc Label="RespectsMultiplication">
##  <ManSection>
##  <Prop Name="RespectsMultiplication" Arg='mapp'/>
##
##  <Description>
##  Let <A>mapp</A> be a general mapping with underlying relation
##  <M>F \subseteq S \times R</M>,
##  where <M>S</M> and <M>R</M> are the source and the range of <A>mapp</A>,
##  respectively.
##  Then <Ref Prop="RespectsMultiplication"/> returns <K>true</K> if
##  <M>S</M> and <M>R</M> are magmas such that
##  <M>(s_1,r_1), (s_2,r_2) \in F</M> implies
##  <M>(s_1 * s_2,r_1 * r_2) \in F</M>,
##  and <K>false</K> otherwise.
##  <P/>
##  If <A>mapp</A> is single-valued then
##  <Ref Prop="RespectsMultiplication"/> returns <K>true</K>
##  if and only if the equation
##  <C><A>s1</A>^<A>mapp</A> * <A>s2</A>^<A>mapp</A> =
##  (<A>s1</A> * <A>s2</A>)^<A>mapp</A></C>
##  holds for all <A>s1</A>, <A>s2</A> in <M>S</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "RespectsMultiplication", IsGeneralMapping );


#############################################################################
##
#P  RespectsOne( <mapp> )
##
##  <#GAPDoc Label="RespectsOne">
##  <ManSection>
##  <Prop Name="RespectsOne" Arg='mapp'/>
##
##  <Description>
##  Let <A>mapp</A> be a general mapping with underlying relation
##  <M>F \subseteq <A>S</A> \times <A>R</A></M>,
##  where <A>S</A> and <A>R</A> are the source and the range of <A>mapp</A>,
##  respectively.
##  Then <Ref Prop="RespectsOne"/> returns <K>true</K> if
##  <A>S</A> and <A>R</A> are magmas-with-one such that
##  <M>( </M><C>One(<A>S</A>)</C><M>, </M><C>One(<A>R</A>)</C><M> ) \in F</M>,
##  and <K>false</K> otherwise.
##  <P/>
##  If <A>mapp</A> is single-valued then <Ref Prop="RespectsOne"/> returns
##  <K>true</K> if and only if the equation
##  <C>One( <A>S</A> )^<A>mapp</A> = One( <A>R</A> )</C>
##  holds.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "RespectsOne", IsGeneralMapping );


#############################################################################
##
#P  RespectsInverses( <mapp> )
##
##  <#GAPDoc Label="RespectsInverses">
##  <ManSection>
##  <Prop Name="RespectsInverses" Arg='mapp'/>
##
##  <Description>
##  Let <A>mapp</A> be a general mapping with underlying relation
##  <M>F \subseteq <A>S</A> \times <A>R</A></M>,
##  where <A>S</A> and <A>R</A> are the source and the range of <A>mapp</A>,
##  respectively.
##  Then <Ref Prop="RespectsInverses"/> returns <K>true</K> if
##  <A>S</A> and <A>R</A> are magmas-with-inverses such that,
##  for <M>s \in <A>S</A></M> and <M>r \in <A>R</A></M>,
##  <M>(s,r) \in F</M> implies <M>(s^{{-1}},r^{{-1}}) \in F</M>,
##  and <K>false</K> otherwise.
##  <P/>
##  If <A>mapp</A> is single-valued then <Ref Prop="RespectsInverses"/>
##  returns <K>true</K> if and only if the equation
##  <C>Inverse( <A>s</A> )^<A>mapp</A> = Inverse( <A>s</A>^<A>mapp</A> )</C>
##  holds for all <A>s</A> in <M>S</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "RespectsInverses", IsGeneralMapping );


#############################################################################
##
#M  RespectsOne( <mapp> )
##
InstallTrueMethod( RespectsOne,
    RespectsMultiplication and RespectsInverses );


#############################################################################
##
#P  IsGroupGeneralMapping( <mapp> )
#P  IsGroupHomomorphism( <mapp> )
##
##  <#GAPDoc Label="IsGroupGeneralMapping">
##  <ManSection>
##  <Filt Name="IsGroupGeneralMapping" Arg='mapp'/>
##  <Filt Name="IsGroupHomomorphism" Arg='mapp'/>
##
##  <Description>
##  A <E>group general mapping</E> is a mapping which respects multiplication
##  and inverses.
##  If it is total and single valued it is called a
##  <E>group homomorphism</E>.
##  <P/>
##  Chapter&nbsp;<Ref Chap="Group Homomorphisms"/> explains
##  group homomorphisms in more detail.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "IsGroupGeneralMapping",
    IsGeneralMapping and RespectsMultiplication and RespectsInverses );

DeclareSynonymAttr( "IsGroupHomomorphism",
    IsGroupGeneralMapping and IsMapping );


#############################################################################
##
#A  KernelOfMultiplicativeGeneralMapping( <mapp> )
##
##  <#GAPDoc Label="KernelOfMultiplicativeGeneralMapping">
##  <ManSection>
##  <Attr Name="KernelOfMultiplicativeGeneralMapping" Arg='mapp'/>
##
##  <Description>
##  Let <A>mapp</A> be a general mapping.
##  Then <Ref Attr="KernelOfMultiplicativeGeneralMapping"/> returns
##  the set of all elements in the source of <A>mapp</A> that have
##  the identity of the range in their set of images.
##  <P/>
##  (This is a monoid if <A>mapp</A> respects multiplication and one,
##  and if the source of <A>mapp</A> is associative.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "KernelOfMultiplicativeGeneralMapping",
    IsGeneralMapping );


#############################################################################
##
#A  CoKernelOfMultiplicativeGeneralMapping( <mapp> )
##
##  <#GAPDoc Label="CoKernelOfMultiplicativeGeneralMapping">
##  <ManSection>
##  <Attr Name="CoKernelOfMultiplicativeGeneralMapping" Arg='mapp'/>
##
##  <Description>
##  Let <A>mapp</A> be a general mapping.
##  Then <Ref Attr="CoKernelOfMultiplicativeGeneralMapping"/> returns
##  the set of all elements in the range of <A>mapp</A> that have
##  the identity of the source in their set of preimages.
##  <P/>
##  (This is a monoid if <A>mapp</A> respects multiplication and one,
##  and if the range of <A>mapp</A> is associative.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "CoKernelOfMultiplicativeGeneralMapping",
    IsGeneralMapping );


#############################################################################
##
##  2. properties and attributes of gen. mappings that respect addition
##

#############################################################################
##
#P  RespectsAddition( <mapp> )
##
##  <#GAPDoc Label="RespectsAddition">
##  <ManSection>
##  <Prop Name="RespectsAddition" Arg='mapp'/>
##
##  <Description>
##  Let <A>mapp</A> be a general mapping with underlying relation
##  <M>F \subseteq S \times R</M>,
##  where <M>S</M> and <M>R</M> are the source and the range of <A>mapp</A>,
##  respectively.
##  Then <Ref Prop="RespectsAddition"/> returns <K>true</K> if
##  <M>S</M> and <M>R</M> are additive magmas such that
##  <M>(s_1,r_1), (s_2,r_2) \in F</M> implies
##  <M>(s_1 + s_2,r_1 + r_2) \in F</M>,
##  and <K>false</K> otherwise.
##  <P/>
##  If <A>mapp</A> is single-valued then <Ref Prop="RespectsAddition"/>
##  returns <K>true</K> if and only if the equation
##  <C><A>s1</A>^<A>mapp</A> + <A>s2</A>^<A>mapp</A> =
##  (<A>s1</A>+<A>s2</A>)^<A>mapp</A></C>
##  holds for all <A>s1</A>, <A>s2</A> in <M>S</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "RespectsAddition", IsGeneralMapping );


#############################################################################
##
#P  RespectsZero( <mapp> )
##
##  <#GAPDoc Label="RespectsZero">
##  <ManSection>
##  <Prop Name="RespectsZero" Arg='mapp'/>
##
##  <Description>
##  Let <A>mapp</A> be a general mapping with underlying relation
##  <M>F \subseteq <A>S</A> \times <A>R</A></M>,
##  where <A>S</A> and <A>R</A> are the source and the range of <A>mapp</A>,
##  respectively.
##  Then <Ref Prop="RespectsZero"/> returns <K>true</K> if
##  <A>S</A> and <A>R</A> are additive-magmas-with-zero such that
##  <M>( </M><C>Zero(<A>S</A>)</C><M>,
##  </M><C>Zero(<A>R</A>)</C><M> ) \in F</M>,
##  and <K>false</K> otherwise.
##  <P/>
##  If <A>mapp</A> is single-valued then <Ref Prop="RespectsZero"/> returns
##  <K>true</K> if and only if the equation
##  <C>Zero( <A>S</A> )^<A>mapp</A> = Zero( <A>R</A> )</C>
##  holds.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "RespectsZero", IsGeneralMapping );


#############################################################################
##
#P  RespectsAdditiveInverses( <mapp> )
##
##  <#GAPDoc Label="RespectsAdditiveInverses">
##  <ManSection>
##  <Prop Name="RespectsAdditiveInverses" Arg='mapp'/>
##
##  <Description>
##  Let <A>mapp</A> be a general mapping with underlying relation
##  <M>F \subseteq S \times R</M>,
##  where <M>S</M> and <M>R</M> are the source and the range of <A>mapp</A>,
##  respectively.
##  Then <Ref Prop="RespectsAdditiveInverses"/> returns <K>true</K> if
##  <M>S</M> and <M>R</M> are additive-magmas-with-inverses such that
##  <M>(s,r) \in F</M> implies <M>(-s,-r) \in F</M>,
##  and <K>false</K> otherwise.
##  <P/>
##  If <A>mapp</A> is single-valued then
##  <Ref Prop="RespectsAdditiveInverses"/> returns <K>true</K>
##  if and only if the equation
##  <C>AdditiveInverse( <A>s</A> )^<A>mapp</A> =
##  AdditiveInverse( <A>s</A>^<A>mapp</A> )</C>
##  holds for all <A>s</A> in <M>S</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "RespectsAdditiveInverses", IsGeneralMapping );


#############################################################################
##
#M  RespectsZero( <mapp> )
##
InstallTrueMethod( RespectsZero,
    RespectsAddition and RespectsAdditiveInverses );


#############################################################################
##
#P  IsAdditiveGroupGeneralMapping( <mapp> )
#P  IsAdditiveGroupHomomorphism( <mapp> )
##
##  <#GAPDoc Label="IsAdditiveGroupGeneralMapping">
##  <ManSection>
##  <Filt Name="IsAdditiveGroupGeneralMapping" Arg='mapp'/>
##  <Filt Name="IsAdditiveGroupHomomorphism" Arg='mapp'/>
##
##  <Description>
##  <Ref Filt="IsAdditiveGroupGeneralMapping"/>
##  specifies whether a general mapping <A>mapp</A> respects
##  addition (see <Ref Prop="RespectsAddition"/>) and respects
##  additive inverses (see <Ref Prop="RespectsAdditiveInverses"/>).
##  <P/>
##  <Ref Filt="IsAdditiveGroupHomomorphism"/> is a synonym for the meet of
##  <Ref Filt="IsAdditiveGroupGeneralMapping"/> and <Ref Filt="IsMapping"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "IsAdditiveGroupGeneralMapping",
    IsGeneralMapping and RespectsAddition and RespectsAdditiveInverses );

DeclareSynonymAttr( "IsAdditiveGroupHomomorphism",
    IsAdditiveGroupGeneralMapping and IsMapping );


#############################################################################
##
#A  KernelOfAdditiveGeneralMapping( <mapp> )
##
##  <#GAPDoc Label="KernelOfAdditiveGeneralMapping">
##  <ManSection>
##  <Attr Name="KernelOfAdditiveGeneralMapping" Arg='mapp'/>
##
##  <Description>
##  Let <A>mapp</A> be a general mapping.
##  Then <Ref Attr="KernelOfAdditiveGeneralMapping"/> returns
##  the set of all elements in the source of <A>mapp</A> that have
##  the zero of the range in their set of images.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "KernelOfAdditiveGeneralMapping", IsGeneralMapping );


#############################################################################
##
#A  CoKernelOfAdditiveGeneralMapping( <mapp> )
##
##  <#GAPDoc Label="CoKernelOfAdditiveGeneralMapping">
##  <ManSection>
##  <Attr Name="CoKernelOfAdditiveGeneralMapping" Arg='mapp'/>
##
##  <Description>
##  Let <A>mapp</A> be a general mapping.
##  Then <Ref Attr="CoKernelOfAdditiveGeneralMapping"/> returns
##  the set of all elements in the range of <A>mapp</A> that have
##  the zero of the source in their set of preimages.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "CoKernelOfAdditiveGeneralMapping", IsGeneralMapping );


#############################################################################
##
##  3. properties and attributes of gen. mappings that respect scalar mult.
##

#############################################################################
##
#P  RespectsScalarMultiplication( <mapp> )
##
##  <#GAPDoc Label="RespectsScalarMultiplication">
##  <ManSection>
##  <Prop Name="RespectsScalarMultiplication" Arg='mapp'/>
##
##  <Description>
##  Let <A>mapp</A> be a general mapping, with underlying relation
##  <M>F \subseteq S \times R</M>,
##  where <M>S</M> and <M>R</M> are the source and the range of <A>mapp</A>,
##  respectively.
##  Then <Ref Prop="RespectsScalarMultiplication"/> returns <K>true</K> if
##  <M>S</M> and <M>R</M> are left modules with the left acting domain
##  <M>D</M> of <M>S</M> contained in the left acting domain of <M>R</M>
##  and such that
##  <M>(s,r) \in F</M> implies <M>(c * s,c * r) \in F</M> for all
##  <M>c \in D</M>, and <K>false</K> otherwise.
##  <P/>
##  If <A>mapp</A> is single-valued then
##  <Ref Prop="RespectsScalarMultiplication"/> returns
##  <K>true</K> if and only if the equation
##  <C><A>c</A> * <A>s</A>^<A>mapp</A> =
##  (<A>c</A> * <A>s</A>)^<A>mapp</A></C>
##  holds for all <A>c</A> in <M>D</M> and <A>s</A> in <M>S</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "RespectsScalarMultiplication", IsGeneralMapping );

InstallTrueMethod( RespectsAdditiveInverses, RespectsScalarMultiplication );


#############################################################################
##
#P  IsLeftModuleGeneralMapping( <mapp> )
#P  IsLeftModuleHomomorphism( <mapp> )
##
##  <#GAPDoc Label="IsLeftModuleGeneralMapping">
##  <ManSection>
##  <Filt Name="IsLeftModuleGeneralMapping" Arg='mapp'/>
##  <Filt Name="IsLeftModuleHomomorphism" Arg='mapp'/>
##
##  <Description>
##  <Ref Filt="IsLeftModuleGeneralMapping"/>
##  specifies whether a general mapping <A>mapp</A> satisfies the property
##  <Ref Filt="IsAdditiveGroupGeneralMapping"/> and respects scalar
##  multiplication (see <Ref Prop="RespectsScalarMultiplication"/>).
##  <P/>
##  <Ref Filt="IsLeftModuleHomomorphism"/> is a synonym for the meet of
##  <Ref Filt="IsLeftModuleGeneralMapping"/> and <Ref Filt="IsMapping"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "IsLeftModuleGeneralMapping",
    IsAdditiveGroupGeneralMapping and RespectsScalarMultiplication );

DeclareSynonymAttr( "IsLeftModuleHomomorphism",
    IsLeftModuleGeneralMapping and IsMapping );


#############################################################################
##
#O  IsLinearMapping( <F>, <mapp> )
##
##  <#GAPDoc Label="IsLinearMapping">
##  <ManSection>
##  <Oper Name="IsLinearMapping" Arg='F, mapp'/>
##
##  <Description>
##  For a field <A>F</A> and a general mapping <A>mapp</A>,
##  <Ref Oper="IsLinearMapping"/> returns <K>true</K> if <A>mapp</A> is an
##  <A>F</A>-linear mapping, and <K>false</K> otherwise.
##  <P/>
##  A mapping <M>f</M> is a linear mapping (or vector space homomorphism)
##  if the source and range are vector spaces over the same division ring
##  <M>D</M>, and if
##  <M>f( a + b ) = f(a) + f(b)</M> and <M>f( s * a ) = s * f(a)</M> hold
##  for all elements <M>a</M>, <M>b</M> in the source of <M>f</M>
##  and <M>s \in D</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IsLinearMapping", [ IsDomain, IsGeneralMapping ] );


#############################################################################
##
##  4. properties and attributes of gen. mappings that respect multiplicative
##     and additive structure
##

#############################################################################
##
#P  IsRingGeneralMapping( <mapp> )
#P  IsRingHomomorphism( <mapp> )
##
##  <#GAPDoc Label="IsRingGeneralMapping">
##  <ManSection>
##  <Filt Name="IsRingGeneralMapping" Arg='mapp'/>
##  <Filt Name="IsRingHomomorphism" Arg='mapp'/>
##
##  <Description>
##  <Ref Filt="IsRingGeneralMapping"/> specifies whether a general mapping
##  <A>mapp</A> satisfies the property
##  <Ref Filt="IsAdditiveGroupGeneralMapping"/> and respects multiplication
##  (see <Ref Prop="RespectsMultiplication"/>).
##  <P/>
##  <Ref Filt="IsRingHomomorphism"/> is a synonym for the meet of
##  <Ref Filt="IsRingGeneralMapping"/> and <Ref Filt="IsMapping"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "IsRingGeneralMapping",
    IsGeneralMapping and RespectsMultiplication
    and IsAdditiveGroupGeneralMapping );

DeclareSynonymAttr( "IsRingHomomorphism",
    IsRingGeneralMapping and IsMapping );


#############################################################################
##
#P  IsRingWithOneGeneralMapping( <mapp> )
#P  IsRingWithOneHomomorphism( <mapp> )
##
##  <#GAPDoc Label="IsRingWithOneGeneralMapping">
##  <ManSection>
##  <Filt Name="IsRingWithOneGeneralMapping" Arg='mapp'/>
##  <Filt Name="IsRingWithOneHomomorphism" Arg='mapp'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "IsRingWithOneGeneralMapping",
    IsRingGeneralMapping and RespectsOne );

DeclareSynonymAttr( "IsRingWithOneHomomorphism",
    IsRingWithOneGeneralMapping and IsMapping );


#############################################################################
##
#P  IsAlgebraGeneralMapping( <mapp> )
#P  IsAlgebraHomomorphism( <mapp> )
##
##  <#GAPDoc Label="IsAlgebraGeneralMapping">
##  <ManSection>
##  <Filt Name="IsAlgebraGeneralMapping" Arg='mapp'/>
##  <Filt Name="IsAlgebraHomomorphism" Arg='mapp'/>
##
##  <Description>
##  <Ref Filt="IsAlgebraGeneralMapping"/> specifies whether a general
##  mapping <A>mapp</A> satisfies both properties
##  <Ref Filt="IsRingGeneralMapping"/> and
##  (see <Ref Filt="IsLeftModuleGeneralMapping"/>).
##  <P/>
##  <Ref Filt="IsAlgebraHomomorphism"/> is a synonym for the meet of
##  <Ref Filt="IsAlgebraGeneralMapping"/> and <Ref Filt="IsMapping"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "IsAlgebraGeneralMapping",
    IsRingGeneralMapping and IsLeftModuleGeneralMapping );

DeclareSynonymAttr( "IsAlgebraHomomorphism",
    IsAlgebraGeneralMapping and IsMapping );


#############################################################################
##
#P  IsAlgebraWithOneGeneralMapping( <mapp> )
#P  IsAlgebraWithOneHomomorphism( <mapp> )
##
##  <#GAPDoc Label="IsAlgebraWithOneGeneralMapping">
##  <ManSection>
##  <Filt Name="IsAlgebraWithOneGeneralMapping" Arg='mapp'/>
##  <Filt Name="IsAlgebraWithOneHomomorphism" Arg='mapp'/>
##
##  <Description>
##  <Ref Filt="IsAlgebraWithOneGeneralMapping"/>
##  specifies whether a general mapping <A>mapp</A> satisfies both
##  properties <Ref Filt="IsAlgebraGeneralMapping"/> and
##  <Ref Prop="RespectsOne"/>.
##  <P/>
##  <Ref Filt="IsAlgebraWithOneHomomorphism"/> is a synonym for the meet of
##  <Ref Filt="IsAlgebraWithOneGeneralMapping"/> and <Ref Filt="IsMapping"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "IsAlgebraWithOneGeneralMapping",
    IsAlgebraGeneralMapping and RespectsOne );

DeclareSynonymAttr( "IsAlgebraWithOneHomomorphism",
    IsAlgebraWithOneGeneralMapping and IsMapping );


#############################################################################
##
#P  IsFieldHomomorphism( <mapp> )
##
##  <#GAPDoc Label="IsFieldHomomorphism">
##  <ManSection>
##  <Prop Name="IsFieldHomomorphism" Arg='mapp'/>
##
##  <Description>
##  A general mapping is a field homomorphism if and only if it is
##  a ring homomorphism with source a field.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsFieldHomomorphism", IsGeneralMapping );

InstallTrueMethod( IsAlgebraHomomorphism, IsFieldHomomorphism );


#############################################################################
##
#F  InstallEqMethodForMappingsFromGenerators( <IsStruct>,
#F                           <GeneratorsOfStruct>, <respects>, <infostring> )
##
##  <ManSection>
##  <Func Name="InstallEqMethodForMappingsFromGenerators"
##   Arg='IsStruct, GeneratorsOfStruct, respects, infostring'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BindGlobal( "InstallEqMethodForMappingsFromGenerators", function( IsStruct,
    GeneratorsOfStruct, respects, infostring )

    InstallMethod( \=,
        Concatenation( "method for two s.v. gen. mappings", infostring ),
        IsIdenticalObj,
        [ IsGeneralMapping and IsSingleValued and respects,
          IsGeneralMapping and IsSingleValued and respects ],
        0,
        function( map1, map2 )
        local preim, gen;
        if   not IsStruct( Source( map1 ) ) then
          TryNextMethod();
        elif     HasIsInjective( map1 ) and HasIsInjective( map2 )
             and IsInjective( map1 ) <> IsInjective( map2 ) then
          return false;
        elif     HasIsSurjective( map1 ) and HasIsSurjective( map2 )
             and IsSurjective( map1 ) <> IsSurjective( map2 ) then
          return false;
        elif     HasIsTotal( map1 ) and HasIsTotal( map2 )
             and IsTotal( map1 ) <> IsTotal( map2 ) then
          return false;
        elif    Source( map1 ) <> Source( map2 )
             or Range ( map1 ) <> Range ( map2 ) then
          return false;
        fi;

        preim:= PreImagesRange( map1 );
        if not IsStruct( preim ) then
          TryNextMethod();
        fi;
        for gen in GeneratorsOfStruct( preim ) do
          if    ImagesRepresentative( map1, gen )
             <> ImagesRepresentative( map2, gen ) then
            return false;
          fi;
        od;
        return true;
        end );


    InstallMethod(IsOne,
        Concatenation( "method for s.v. gen. mapping", infostring ),
        true,
        [ IsGeneralMapping and IsSingleValued and respects ],
        0,
        function( map )
        local gen;
        if   not IsStruct( Source( map ) ) then
          TryNextMethod();
        elif     HasIsInjective( map ) and not IsInjective( map ) then
          return false;
        elif     HasIsSurjective( map ) and not IsSurjective( map ) then
          return false;
        elif     HasIsTotal( map ) and not IsTotal( map ) then
          return false;
        elif    Source( map ) <> Range( map ) then
          return false;
        fi;

        for gen in GeneratorsOfStruct( Source(map) ) do
          if    gen<>ImagesRepresentative( map, gen )  then
            return false;
          fi;
        od;
        return true;
        end );

end );


#############################################################################
##
##  5. properties and attributes of gen. mappings that transform
##     multiplication into addition
##

#############################################################################
##
#P  TransformsMultiplicationIntoAddition( <mapp> )
##
##  <ManSection>
##  <Prop Name="TransformsMultiplicationIntoAddition" Arg='mapp'/>
##
##  <Description>
##  Let <A>mapp</A> be a general mapping with underlying relation
##  <M>F \subseteq S \times R</M>,
##  where <M>S</M> and <M>R</M> are the source and the range of <A>mapp</A>,
##  respectively.
##  Then <Ref Func="TransformsMultiplicationIntoAddition"/> returns
##  <K>true</K> if <M>S</M> is a magma and <M>R</M> an additive magma
##  such that <M>(s_1,r_1), (s_2,r_2) \in F</M> implies
##  <M>(s_1 * s_2,r_1 + r_2) \in F</M>,
##  and <K>false</K> otherwise.
##  <P/>
##  If <A>mapp</A> is single-valued then
##  <Ref Func="TransformsMultiplicationIntoAddition"/>
##  returns <K>true</K> if and only if the equation
##  <C><A>s1</A>^<A>mapp</A> + <A>s2</A>^<A>mapp</A> =
##  (<A>s1</A> * <A>s2</A>)^<A>mapp</A></C> holds for all
##  <A>s1</A>, <A>s2</A> in <M>S</M>.
##  </Description>
##  </ManSection>
##
DeclareProperty( "TransformsMultiplicationIntoAddition", IsGeneralMapping );


#############################################################################
##
#P  TranformsOneIntoZero( <mapp> )
##
##  <ManSection>
##  <Prop Name="TranformsOneIntoZero" Arg='mapp'/>
##
##  <Description>
##  Let <A>mapp</A> be a general mapping with underlying relation
##  <M>F \subseteq S \times R</M>,
##  where <M>S</M> and <M>R</M> are the source and the range of <A>mapp</A>,
##  respectively.
##  Then <Ref Func="TranformsOneIntoZero"/> returns <K>true</K> if
##  <M>S</M> is a magma-with-one and <M>R</M> an additive-magma-with-zero
##  such that
##  <M>( </M><C>One(</C><M>S</M><C>), Zero(</C><M>R</M><C>) )</C><M> \in F</M>,
##  and <K>false</K> otherwise.
##  <P/>
##  If <A>mapp</A> is single-valued then
##  <Ref Func="TranformsOneIntoZero"/> returns <K>true</K>
##  if and only if the equation
##  <C>One( S )^<A>mapp</A> = Zero( R )</C>
##  holds.
##  </Description>
##  </ManSection>
##
DeclareProperty( "TranformsOneIntoZero", IsGeneralMapping );


#############################################################################
##
#P  TransformsInversesIntoAdditiveInverses( <mapp> )
##
##  <ManSection>
##  <Prop Name="TransformsInversesIntoAdditiveInverses" Arg='mapp'/>
##
##  <Description>
##  Let <A>mapp</A> be a general mapping with underlying relation
##  <M>F \subseteq S \times R</M>,
##  where <M>S</M> and <M>R</M> are the source and the range of <A>mapp</A>,
##  respectively.
##  Then <Ref Func="RespectsInverses"/> returns <K>true</K> if
##  <M>S</M> and <M>R</M> are magmas-with-inverses such that
##  <M>S</M> is a magma-with-inverses
##  and <M>R</M> an additive-magma-with-inverses
##  such that <M>(s,r) \in F</M> implies <M>(s^{-1},-r) \in F</M>,
##  and <K>false</K> otherwise.
##  <P/>
##  If <A>mapp</A> is single-valued then
##  <Ref Func="TransformsInversesIntoAdditiveInverses"/>
##  returns <K>true</K> if and only if the equation
##  <C>Inverse( <A>s</A> )^<A>mapp</A> =
##  AdditiveInverse( <A>s</A>^<A>mapp</A> )</C>
##  holds for all <A>s</A> in <M>S</M>.
##  </Description>
##  </ManSection>
##
DeclareProperty( "TransformsInversesIntoAdditiveInverses", IsGeneralMapping );


#############################################################################
##
#M  RespectsOne( <mapp> )
##
InstallTrueMethod( TranformsOneIntoZero,
    TransformsMultiplicationIntoAddition and
    TransformsInversesIntoAdditiveInverses );


#############################################################################
##
#P  IsGroupToAdditiveGroupGeneralMapping( <mapp> )
#P  IsGroupToAdditiveGroupHomomorphism( <mapp> )
##
##  <ManSection>
##  <Prop Name="IsGroupToAdditiveGroupGeneralMapping" Arg='mapp'/>
##  <Prop Name="IsGroupToAdditiveGroupHomomorphism" Arg='mapp'/>
##
##  <Description>
##  A <C>GroupToAdditiveGroupGeneralMapping</C> is a mapping which transforms
##  multiplication into addition and transforms
##  inverses into additive inverses. If it is total and single valued it is
##  called a group-to-additive-group
##  homomorphism.
##  </Description>
##  </ManSection>
##
DeclareSynonymAttr( "IsGroupToAdditiveGroupGeneralMapping",
    IsGeneralMapping and TransformsMultiplicationIntoAddition and
    TransformsInversesIntoAdditiveInverses );

DeclareSynonymAttr( "IsGroupToAdditiveGroupHomomorphism",
    IsGroupToAdditiveGroupGeneralMapping and IsMapping );


#############################################################################
##
##  6. properties and attributes of gen. mappings that transform addition
##     into multiplication
##

#############################################################################
##
#P  TransformsAdditionIntoMultiplication( <mapp> )
##
##  <ManSection>
##  <Prop Name="TransformsAdditionIntoMultiplication" Arg='mapp'/>
##
##  <Description>
##  Let <A>mapp</A> be a general mapping with underlying relation
##  <M>F \subseteq S \times R</M>,
##  where <M>S</M> and <M>R</M> are the source and the range of <A>mapp</A>,
##  respectively.
##  Then <Ref Func="TransformsAdditionIntoMultiplication"/> returns
##  <K>true</K> if
##  <M>S</M> is an additive magma and <M>R</M> a magma such that
##  <M>(s_1,r_1), (s_2,r_2) \in F</M> implies <M>(s_1 + s_2,r_1 * r_2) \in F</M>,
##  and <K>false</K> otherwise.
##  <P/>
##  If <A>mapp</A> is single-valued then
##  <Ref Func="TransformsAdditionIntoMultiplication"/>
##  returns <K>true</K> if and only if the equation
##  <C><A>s1</A>^<A>mapp</A> * <A>s2</A>^<A>mapp</A> =
##  (<A>s1</A>+<A>s2</A>)^<A>mapp</A></C>
##  holds for all <A>s1</A>, <A>s2</A> in <M>S</M>.
##  </Description>
##  </ManSection>
##
DeclareProperty( "TransformsAdditionIntoMultiplication", IsGeneralMapping );


#############################################################################
##
#P  TransformsZeroIntoOne( <mapp> )
##
##  <ManSection>
##  <Prop Name="TransformsZeroIntoOne" Arg='mapp'/>
##
##  <Description>
##  Let <A>mapp</A> be a general mapping with underlying relation
##  <M>F \subseteq S \times R</M>,
##  where <M>S</M> and <M>R</M> are the source and the range of <A>mapp</A>,
##  respectively.
##  Then <Ref Func="TransformsZeroIntoOne"/> returns <K>true</K> if
##  <M>S</M> is an additive-magma-with-zero and <M>R</M> a magma-with-one
##  such that
##  <M>( </M><C>Zero(</C><M>S</M><C>), One(</C><M>R</M><C>) )</C><M> \in F</M>,
##  and <K>false</K> otherwise.
##  <P/>
##  If <A>mapp</A> is single-valued then
##  <Ref Func="TransformsZeroIntoOne"/> returns <K>true</K>
##  if and only if the equation
##  <C>Zero( S )^<A>mapp</A> = One( R )</C>
##  holds.
##  </Description>
##  </ManSection>
##
DeclareProperty( "TransformsZeroIntoOne", IsGeneralMapping );


#############################################################################
##
#P  TransformsAdditiveInversesIntoInverses( <mapp> )
##
##  <ManSection>
##  <Prop Name="TransformsAdditiveInversesIntoInverses" Arg='mapp'/>
##
##  <Description>
##  Let <A>mapp</A> be a general mapping with underlying relation
##  <M>F \subseteq S \times R</M>,
##  where <M>S</M> and <M>R</M> are the source and the range of <A>mapp</A>,
##  respectively.
##  Then <Ref Func="TransformsAdditiveInversesIntoInverses"/> returns
##  <K>true</K> if <M>S</M> is an additive-magma-with-inverses and
##  <M>R</M> a magma-with-inverses such that
##  <M>(s,r) \in F</M> implies <M>(-s,r^{-1}) \in F</M>,
##  and <K>false</K> otherwise.
##  <P/>
##  If <A>mapp</A> is single-valued then
##  <Ref Func="TransformsAdditiveInversesIntoInverses"/>
##  returns <K>true</K> if and only if the equation
##  <C>AdditiveInverse( <A>s</A> )^<A>mapp</A> =
##  Inverse( <A>s</A>^<A>mapp</A> )</C> holds for all <A>s</A> in <M>S</M>.
##  </Description>
##  </ManSection>
##
DeclareProperty( "TransformsAdditiveInversesIntoInverses", IsGeneralMapping );


#############################################################################
##
#M  TransformsAdditiveInversesIntoInverses( <mapp> )
##
InstallTrueMethod( TransformsAdditiveInversesIntoInverses,
    TransformsAdditionIntoMultiplication and
    TransformsAdditiveInversesIntoInverses );


#############################################################################
##
#P  IsAdditiveGroupToGroupGeneralMapping( <mapp> )
#P  IsAdditiveGroupToGroupHomomorphism( <mapp> )
##
##  <ManSection>
##  <Prop Name="IsAdditiveGroupToGroupGeneralMapping" Arg='mapp'/>
##  <Prop Name="IsAdditiveGroupToGroupHomomorphism" Arg='mapp'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareSynonymAttr( "IsAdditiveGroupToGroupGeneralMapping",
    IsGeneralMapping and TransformsAdditionIntoMultiplication and
    TransformsAdditiveInversesIntoInverses );

DeclareSynonymAttr( "IsAdditiveGroupToGroupHomomorphism",
    IsAdditiveGroupToGroupGeneralMapping and IsMapping );
