#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

############################################################################
##
#R  IsFromFpGroupGeneralMapping(<map>)
#R  IsFromFpGroupHomomorphism(<map>)
##
##  <ManSection>
##  <Filt Name="IsFromFpGroupGeneralMapping" Arg='map' Type='Representation'/>
##  <Filt Name="IsFromFpGroupHomomorphism" Arg='map' Type='Representation'/>
##
##  <Description>
##  is the representation of mappings from an fp group.
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsFromFpGroupGeneralMapping", IsGroupGeneralMapping
  # we want all methods for homs from fp groups to be better. This (slight
  # hack) increases the rank of the category of such mappings.
  and NewFilter("Extrarankfilter",10));
DeclareSynonym("IsFromFpGroupHomomorphism",
  IsFromFpGroupGeneralMapping and IsMapping);

############################################################################
##
#R  IsFromFpGroupGeneralMappingByImages(<map>)
#R  IsFromFpGroupHomomorphismByImages(<map>)
##
##  <#GAPDoc Label="IsFromFpGroupGeneralMappingByImages">
##  <ManSection>
##  <Filt Name="IsFromFpGroupGeneralMappingByImages" Arg='map'
##   Type='Representation'/>
##  <Filt Name="IsFromFpGroupHomomorphismByImages" Arg='map'
##   Type='Representation'/>
##
##  <Description>
##  is the representation of mappings from an fp group.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation( "IsFromFpGroupGeneralMappingByImages",
      IsFromFpGroupGeneralMapping and IsGroupGeneralMappingByImages,
      [ "generators", "genimages" ] );
DeclareSynonym("IsFromFpGroupHomomorphismByImages",
  IsFromFpGroupGeneralMappingByImages and IsMapping);

############################################################################
##
#R  IsFromFpGroupStdGensGeneralMappingByImages(<map>)
#R  IsFromFpGroupStdGensHomomorphismByImages(<map>)
##
##  <#GAPDoc Label="IsFromFpGroupStdGensGeneralMappingByImages">
##  <ManSection>
##  <Filt Name="IsFromFpGroupStdGensGeneralMappingByImages" Arg='map'
##   Type='Representation'/>
##  <Filt Name="IsFromFpGroupStdGensHomomorphismByImages" Arg='map'
##   Type='Representation'/>
##
##  <Description>
##  is the representation of total mappings from an fp group that give images of
##  the standard generators.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation( "IsFromFpGroupStdGensGeneralMappingByImages",
      IsFromFpGroupGeneralMappingByImages, [ "generators", "genimages" ] );
DeclareSynonym("IsFromFpGroupStdGensHomomorphismByImages",
  IsFromFpGroupStdGensGeneralMappingByImages and IsMapping);


############################################################################
##
#R  IsToFpGroupGeneralMappingByImages(<map>)
#R  IsToFpGroupHomomorphismByImages(<map>)
##
##  <ManSection>
##  <Filt Name="IsToFpGroupGeneralMappingByImages" Arg='map' Type='Representation'/>
##  <Filt Name="IsToFpGroupHomomorphismByImages" Arg='map' Type='Representation'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareRepresentation( "IsToFpGroupGeneralMappingByImages",
      IsGroupGeneralMappingByImages,
      [ "generators", "genimages" ] );
DeclareSynonym("IsToFpGroupHomomorphismByImages",
  IsToFpGroupGeneralMappingByImages and IsMapping);

############################################################################
##
#P  IsWordDecompHomomorphism(<map>)
##
##  <ManSection>
##  <Prop Name="IsWordDecompHomomorphism" Arg='map'/>
##
##  <Description>
##  these homomorphism contain a component <C>!.decompinfo</C> that provides
##  functionality to decompose a word into generators. They are primarily
##  used for <C>IsomorphismFpGroupBy...Series</C>.
##  </Description>
##  </ManSection>
##
DeclareProperty( "IsWordDecompHomomorphism",IsGroupGeneralMappingByImages);

#############################################################################
##
#A  CosetTableFpHom(<hom>)
##
##  <ManSection>
##  <Attr Name="CosetTableFpHom" Arg='hom'/>
##
##  <Description>
##  returns an augmented coset table for an homomorphism from an fp group,
##  corresponding to the !.generators component. The component
##  <C>.secondaryImages</C> of this table will give the images of all (primary
##  and secondary) subgroup generators under <A>hom</A>.
##  <P/>
##  As we might want to add further entries to the table, it is a mutable
##  attribute.
##  </Description>
##  </ManSection>
##
DeclareAttribute("CosetTableFpHom",IsGeneralMapping,"mutable");

#############################################################################
##
#F  SecondaryImagesAugmentedCosetTable(<aug>,<gens>,<genimages>)
##
##  <ManSection>
##  <Func Name="SecondaryImagesAugmentedCosetTable" Arg='aug,gens,genimages'/>
##
##  <Description>
##  returns a list of images of the secondary generators, based on the
##  components <C>homgens</C> and <C>homgenims</C> in the augmented coset table <A>aug</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("SecondaryImagesAugmentedCosetTable");

#############################################################################
##
#F  TrySecondaryImages(<aug>)
##
##  <ManSection>
##  <Func Name="TrySecondaryImages" Arg='aug'/>
##
##  <Description>
##  sets a component <C>secondaryImages</C> in the augmented coset table (seeded
##  to a ShallowCopy of the primary images) if having all these images
##  cannot become too memory extensive. (Call this function for augmented
##  coset tables for homomorphisms once -- the other functions make use of
##  the <C>secondaryImages</C> component if existing.)
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("TrySecondaryImages");

#############################################################################
##
#F  KuKGenerators( <G>, <beta>, <alpha> )
##
##  <#GAPDoc Label="KuKGenerators">
##  <ManSection>
##  <Func Name="KuKGenerators" Arg='G, beta, alpha'/>
##
##  <Description>
##  <Index>Krasner-Kaloujnine theorem</Index>
##  <Index>Wreath product embedding</Index>
##  If <A>beta</A> is a homomorphism from <A>G</A> into a transitive
##  permutation group, <M>U</M> the full preimage of the point stabilizer and
##  <A>alpha</A> a homomorphism defined on (a superset) of <M>U</M>,
##  this function returns images of the generators of <A>G</A> when mapping
##  to the wreath product <M>(U <A>alpha</A>) \wr (<A>G</A> <A>beta</A>)</M>.
##  (This is the Krasner-Kaloujnine embedding theorem.)
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3,4),(1,2));;
##  gap> hom:=GroupHomomorphismByImages(g,Group((1,2)),
##  > GeneratorsOfGroup(g),[(1,2),(1,2)]);;
##  gap> u:=PreImage(hom,Stabilizer(Image(hom),1));
##  Group([ (2,3,4), (1,2,4) ])
##  gap> hom2:=GroupHomomorphismByImages(u,Group((1,2,3)),
##  > GeneratorsOfGroup(u),[ (1,2,3), (1,2,3) ]);;
##  gap> KuKGenerators(g,hom,hom2);
##  [ (1,4)(2,5)(3,6), (1,6)(2,4)(3,5) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("KuKGenerators");

#############################################################################
##
#A  IsomorphismSimplifiedFpGroup( <G> )
##
##  <#GAPDoc Label="IsomorphismSimplifiedFpGroup">
##  <ManSection>
##  <Attr Name="IsomorphismSimplifiedFpGroup" Arg='G'/>
##
##  <Description>
##  applies Tietze transformations to a copy of the presentation of the
##  given finitely presented group <A>G</A> in order to reduce it
##  with respect to the number of generators, the number of relators,
##  and the relator lengths.
##  <P/>
##  The operation returns an isomorphism with source <A>G</A>, range a group
##  <A>H</A> isomorphic to <A>G</A>, so that the presentation of <A>H</A> has
##  been simplified using Tietze transformations.
##  <Example><![CDATA[
##  gap> f:=FreeGroup(3);;
##  gap> g:=f/[f.1^2,f.2^3,(f.1*f.2)^5,f.1/f.3];
##  <fp group on the generators [ f1, f2, f3 ]>
##  gap> hom:=IsomorphismSimplifiedFpGroup(g);
##  [ f1, f2, f3 ] -> [ f1, f2, f1 ]
##  gap> Range(hom);
##  <fp group on the generators [ f1, f2 ]>
##  gap> RelatorsOfFpGroup(Range(hom));
##  [ f1^2, f2^3, (f1*f2)^5 ]
##  gap> RelatorsOfFpGroup(g);
##  [ f1^2, f2^3, (f1*f2)^5, f1*f3^-1 ]
##  ]]></Example>
##  <P/>
##  <Ref Attr="IsomorphismSimplifiedFpGroup"/> uses Tietze transformations
##  to simplify the presentation, see <Ref Sect="SimplifiedFpGroup"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("IsomorphismSimplifiedFpGroup",IsSubgroupFpGroup);

#############################################################################
##
#A  EpimorphismFromFreeGroup( <G> )
##
##  <#GAPDoc Label="EpimorphismFromFreeGroup">
##  <ManSection>
##  <Attr Name="EpimorphismFromFreeGroup" Arg='G'/>
##
##  <Description>
##  For a group <A>G</A> with a known generating set, this attribute returns
##  a homomorphism from a free group that maps the free generators to the
##  generators of <A>G</A>.
##  <P/>
##  The option <C>names</C> can be used to prescribe a (print) name
##  for the free generators.
##  <P/>
##  The following example shows how to decompose elements of <M>S_4</M> in the
##  generators <C>(1,2,3,4)</C> and <C>(1,2)</C>:
##  <P/>
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3,4),(1,2));
##  Group([ (1,2,3,4), (1,2) ])
##  gap> hom:=EpimorphismFromFreeGroup(g:names:=["x","y"]);
##  [ x, y ] -> [ (1,2,3,4), (1,2) ]
##  gap> PreImagesRepresentative(hom,(1,4));
##  y^-1*x^-1*(x^-1*y^-1)^2*x
##  ]]></Example>
##  <P/>
##  The following example stems from a real request to the &GAP; Forum.
##  In September 2000 a &GAP; user working with puzzles wanted to express the
##  permutation <C>(1,2)</C> as a word as short as possible in particular
##  generators of the symmetric group <M>S_{16}</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> perms := [ (1,2,3,7,11,10,9,5), (2,3,4,8,12,11,10,6),
##  >   (5,6,7,11,15,14,13,9), (6,7,8,12,16,15,14,10) ];;
##  gap> puzzle := Group( perms );;Size( puzzle );
##  20922789888000
##  gap> hom:=EpimorphismFromFreeGroup(puzzle:names:=["a", "b", "c", "d"]);;
##  gap> word := PreImagesRepresentative( hom, (1,2) );
##  a^-1*c*b*c^-1*a*b^-1*a^-2*c^-1*a*b^-1*c*b
##  gap> Length( word );
##  13
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("EpimorphismFromFreeGroup",IsGroup);

#############################################################################
##
#F  LargerQuotientBySubgroupAbelianization( <hom>,<U> )
##
##  <#GAPDoc Label="LargerQuotientBySubgroupAbelianization">
##  <ManSection>
##  <Func Name="LargerQuotientBySubgroupAbelianization" Arg='hom, U'/>
##
##  <Description>
##  Let <A>hom</A> a homomorphism from a finitely presented group <M>G</M>
##  to a finite group <M>H</M> and <M><A>U</A> \leq H</M>.
##  This function will &ndash;if it exists&ndash; return a subgroup
##  <M>S \leq <A>G</A></M>, such that the core of <M>S</M> is properly
##  contained in the kernel of <A>hom</A> as well as in the derived subgroup
##  of <M>V</M>,
##  where <M>V</M> is the pre-image of <A>U</A> under <A>hom</A>.
##  Thus <M>S</M> exposes a larger quotient of <M>G</M>.
##  If no such subgroup exists, <K>fail</K> is returned.
##  <Example><![CDATA[
##  gap> f:=FreeGroup("x","y","z");;
##  gap> g:=f/ParseRelators(f,"x^3=y^3=z^5=(xyx^2y^2)^2=(xz)^2=(yz^3)^2=1");
##  <fp group on the generators [ x, y, z ]>
##  gap> l:=LowIndexSubgroupsFpGroup(g,6);;
##  gap> List(l,IndexInWholeGroup);
##  [ 1, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6 ]
##  gap> q:=DefiningQuotientHomomorphism(l[6]);;p:=Image(q);Size(p);
##  Group([ (4,5,6), (1,2,3)(4,6,5), (2,4,6,3,5) ])
##  360
##  gap> s:=LargerQuotientBySubgroupAbelianization(q,SylowSubgroup(p,3));
##  Group(<fp, no generators known>)
##  gap> Size(Image(DefiningQuotientHomomorphism(s)));
##  193273528320
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("LargerQuotientBySubgroupAbelianization");

#############################################################################
##
#F  ProcessEpimorphismToNewFpGroup( <hom> )
##
##  <#GAPDoc Label="ProcessHomomorphismToNewFpGroup">
##  <ManSection>
##  <Func Name="LargerQuotientBySubgroupAbelianization" Arg='hom'/>
##
##  <Description>
##  Let <A>hom</A> a homomorphism from a group <A>G</A> to a newly created
##  finitely presented group <A>F</A> (in which no calculation yet has taken
##  place) such that the inverse of <A>hom</A> can be applied to elements of
##  $F$. This function endows <A>F</A> (or, more
##  correctly, its elements family) with information (in the form of an
##  <C>FPFaithHom</C>) about <A>G</A> that can be
##  used to obtain a faithful representation for <A>F</A>. This can be in the
##  form of <A>G</A> itself being a permutation/matrix or fp group. It also can
##  be if <A>G</A> is finitely presented but (its family) has an
##  <C>FPFaithHom</A>. (However it will not apply if <A>G</A> is a subgroup
##  of an fp group.) The result of this is make higher level calculations in
##  <A>F</A> more efficient.
##  This is an internal function that does not test its arguments and the
##  result is undefined if calling the function on any other object.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("ProcessEpimorphismToNewFpGroup");

#############################################################################
##
#M  InducedRepFpGroup(<hom>,<u> )
##
##  induce <hom> def. on <u> up to the full group
DeclareGlobalFunction("InducedRepFpGroup");
