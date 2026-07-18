#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Bettina Eick.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

#############################################################################
##
#R  IsGroupGeneralMappingByPcgs(<map>)
##
##  <#GAPDoc Label="IsGroupGeneralMappingByPcgs">
##  <ManSection>
##  <Filt Name="IsGroupGeneralMappingByPcgs" Arg='map' Type='Representation'/>
##
##  <Description>
##  is the representations for mappings that map a pcgs to images and thus
##  may use exponents to decompose generators.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation( "IsGroupGeneralMappingByPcgs",
      IsGroupGeneralMappingByImages,
      [ "generators", "genimages", "sourcePcgs", "sourcePcgsImages" ] );

#############################################################################
##
#R  IsPcGroupGeneralMappingByImages(<map>)
#R  IsPcGroupHomomorphismByImages(<map>)
##
##  <#GAPDoc Label="IsPcGroupGeneralMappingByImages">
##  <ManSection>
##  <Filt Name="IsPcGroupGeneralMappingByImages" Arg='map' Type='Representation'/>
##  <Filt Name="IsPcGroupHomomorphismByImages" Arg='map' Type='Representation'/>
##
##  <Description>
##  is the representation for mappings from a pc group
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation( "IsPcGroupGeneralMappingByImages",
      IsGroupGeneralMappingByPcgs,
      [ "generators", "genimages", "sourcePcgs", "sourcePcgsImages" ] );
DeclareSynonym("IsPcGroupHomomorphismByImages",
  IsPcGroupGeneralMappingByImages and IsMapping);

#############################################################################
##
#R  IsToPcGroupGeneralMappingByImages( <map>)
#R  IsToPcGroupHomomorphismByImages( <map>)
##
##  <#GAPDoc Label="IsToPcGroupGeneralMappingByImages">
##  <ManSection>
##  <Filt Name="IsToPcGroupGeneralMappingByImages" Arg='map' Type='Representation'/>
##  <Filt Name="IsToPcGroupHomomorphismByImages" Arg='map' Type='Representation'/>
##
##  <Description>
##  is the representation for mappings to a pc group
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation( "IsToPcGroupGeneralMappingByImages",
      IsGroupGeneralMappingByImages,
      [ "generators", "genimages", "rangePcgs", "rangePcgsPreimages" ] );
DeclareSynonym("IsToPcGroupHomomorphismByImages",
  IsToPcGroupGeneralMappingByImages and IsMapping);

#############################################################################
##
#O  NaturalIsomorphismByPcgs( <grp>, <pcgs> ) . . presentation through <pcgs>
##
##  <ManSection>
##  <Oper Name="NaturalIsomorphismByPcgs" Arg='grp, pcgs'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation( "NaturalIsomorphismByPcgs", [ IsGroup, IsPcgs ] );


#############################################################################
##
#R  IsNaturalHomomorphismPcGroupRep . . . . . . . . natural hom in a pc group
##
##  <ManSection>
##  <Filt Name="IsNaturalHomomorphismPcGroupRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareRepresentation( "IsNaturalHomomorphismPcGroupRep",
      IsGroupHomomorphism and IsSurjective and IsSPGeneralMapping and
      IsAttributeStoringRep,
      [ "sourcePcgs", "rangePcgs" ] );

#############################################################################
##
#R  IsPcgsToPcgsGeneralMappingByImages(<obj>)
##
##  <ManSection>
##  <Filt Name="IsPcgsToPcgsGeneralMappingByImages" Arg='obj' Type='Representation'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareRepresentation( "IsPcgsToPcgsGeneralMappingByImages",
      IsPcGroupGeneralMappingByImages and IsToPcGroupGeneralMappingByImages,
      [ "generators", "genimages", "sourcePcgs", "sourcePcgsImages",
        "rangePcgs", "rangePcgsPreimages" ] );
DeclareSynonym( "IsPcgsToPcgsHomomorphism",
  IsPcgsToPcgsGeneralMappingByImages and IsMapping);

#############################################################################
##
#A  SpeedupDataPcHom( <hom> )
##
##  <#GAPDoc Label="SpeedupDataPcHom">
##  <ManSection>
##  <Attr Name="SpeedupDataPcHom" Arg='hom'/>
##
##  <Description>
##  This attribute can be used to speed up the evaluation of automorphisms
##  defined on pc groups
##  For a bijective <C>GroupGeneralMappingByPcgs</C> <A>hom</A> whose source
##  and range coincide, this attribute computes auxiliary data that
##  is used to evaluate <A>hom</A> (via <Ref Oper="ImagesRepresentative"/>)
##  more efficiently on elements given as PC words.
##  <P/>
##  The underlying idea is to chop the source pcgs into consecutive chunks
##  of generators, and -- for each chunk -- cache the linear combination of
##  the images of the chunk's pcgs generators corresponding to a given
##  exponent vector, indexed via an enumeration of all exponent vectors for
##  that chunk. If the bottom layer of the pcgs corresponds to an
##  elementary abelian characteristic section of the group, that layer is
##  instead handled by a single matrix (over the corresponding prime
##  field) describing the induced linear action, which avoids caching an
##  exponential number of images.
##  <P/>
##  The data returned is a record with components <C>groupData</C> (itself
##  a record, cached on the source group, describing the pcgs, the chunk
##  boundaries <C>depths</C>, the enumeration functions <C>pats</C> for
##  each chunk, and the bottom-layer <C>field</C>, if any), <C>mat</C> (the
##  bottom-layer action matrix, or <K>fail</K> if there is none), and
##  <C>vals</C> (the (initially empty) per-chunk caches of already computed
##  linear combinations).
##  <P/>
##  <Example><![CDATA[
##  gap> c:=
##  > 795907704596091686712646038905184706593454298469413373797143285153657747\
##  > 351239586262811710749847738976801000754254026040413579046667526466817130\
##  > 802914392952057538792583640445109649600520674698702973723709697810007373\
##  > 995233352187116591143677686258788327453115978744358269535782002029058318\
##  > 257810771066005080889842841087624746370436252682688197604003291620050028\
##  > 846401909466242477914863426492367981611326065610744459532482363544128183\
##  > 604374827708984459564333504764988635016199760594017468033192923946773034\
##  > 271770646937977241649366365016081229348787914203827648812957496851490453\
##  > 241282156106350395799951977534893207577655765871551105496570960614315334\
##  > 053994514353225444855671606481854013179019965035204709283566628789385554\
##  > 419928011419194010887928919720468833278109533276505173824168955123284931\
##  > 001265659454767607182439296171623310796817449741182968155870079586170364\
##  > 119024273084749477859421889660225177004903125725448515527934855500266332\
##  > 704103204371694822574479313082827045452619695412612791277277701430890177\
##  > 221327579098337215352541159848448340430707754477742647984659147310320792\
##  > 862576023639631550894467198294544031652869769649601433223221326429951;;
##  gap>
##  gap> g:=PcGroupCode(c,67108864);
##  <pc group of size 67108864 with 26 generators>
##  gap> pcgs:=Pcgs(g);
##  Pcgs([ f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13, f14, f15,
##    f16, f17, f18, f19, f20, f21, f22, f23, f24, f25, f26 ])
##  gap>
##  gap> mat:=
##  > [[0,1,1,0,0,1,1,0,1,1,1,1,1,1,1,0,1,1,1,0,1,0,0,1,1,1],
##  > [0,0,1,1,0,1,1,1,0,1,0,0,1,0,0,0,0,0,1,1,1,0,0,1,1,1],
##  > [0,1,0,0,0,0,0,1,0,1,0,1,0,1,1,1,0,0,1,1,0,1,1,1,0,0],
##  > [1,0,0,0,0,0,0,1,1,0,1,1,0,1,1,0,1,0,1,1,0,0,0,1,0,0],
##  > [1,1,0,0,0,0,0,1,1,0,0,0,0,1,1,0,0,1,0,0,0,0,1,0,1,0],
##  > [1,1,1,0,0,0,1,0,1,1,1,1,1,1,1,0,0,0,1,0,0,0,1,0,0,1],
##  > [1,0,1,0,1,0,1,0,1,1,0,1,0,0,0,1,0,0,1,1,1,1,1,1,1,1],
##  > [1,0,1,0,1,0,0,1,1,1,0,1,0,0,0,1,1,1,1,0,1,1,1,1,1,0],
##  > [0,0,1,0,1,1,1,1,1,1,1,1,1,0,0,0,1,1,0,0,1,0,0,1,0,1],
##  > [1,1,0,0,1,0,0,1,1,1,0,0,0,1,1,0,1,0,1,1,1,0,1,1,1,1],
##  > [0,0,1,0,1,1,1,1,0,1,0,1,1,0,0,0,1,1,0,0,1,1,1,1,1,0],
##  > [0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,1,1,0],
##  > [1,0,1,0,1,0,0,0,1,1,0,1,1,0,0,1,1,1,0,1,1,1,0,0,1,1],
##  > [0,1,1,1,0,1,1,1,0,1,0,0,1,1,0,0,1,1,0,0,0,0,0,1,1,1],
##  > [1,0,1,0,1,0,0,0,1,1,0,1,0,0,1,1,1,0,0,1,1,0,1,1,0,1],
##  > [1,0,1,0,1,0,0,0,1,1,0,1,0,0,0,0,1,0,1,1,1,1,0,1,1,0],
##  > [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,1,1,0,1,0],
##  > [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,1,1,0,1,0],
##  > [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,1,1,0,1,0,0,0],
##  > [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,1,0],
##  > [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,1,0],
##  > [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0],
##  > [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0],
##  > [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0],
##  > [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,1,0,0,0,0],
##  > [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,1,0,0,1,1]];;
##  gap> a:=GroupHomomorphismByImages(g,g,pcgs,List(mat,x->
##  >   PcElementByExponents(pcgs,x)));;
##  gap> IsBijective(a);
##  true
##  gap> r:=List([1..50000],x->Random(g));;
##  gap> List(r,x->ImagesRepresentative(a,x));;
##  gap> t1:=Runtime();;
##  gap> List(r,x->ImagesRepresentative(a,x));;
##  gap> t1:=Runtime()-t1;;
##  gap> SpeedupDataPcHom(a);; # force caching
##  gap> t2:=Runtime();;
##  gap> List(r,x->ImagesRepresentative(a,x));;
##  gap> t2:=Runtime()-t2;;
##  gap> t1/t2>5/2; # speedup better than factor 2.5
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("SpeedupDataPcHom",IsGroupGeneralMappingByPcgs,"mutable");

