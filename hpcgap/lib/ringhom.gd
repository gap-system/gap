#############################################################################
##
#W  ringhom.gd                   GAP library                  Alexander Hulpke
##
##
#Y  Copyright (C) 2008 The GAP Group
##
##  This file contains declarations of operations for ring general mappings
##  and homomorphisms. It is based on alghom.gd
##
##


DeclareInfoClass("InfoRingHom");

#############################################################################
##
#O  RingGeneralMappingByImages( <R>, <S>, <gens>, <imgs> )
##
##  <#GAPDoc Label="RingGeneralMappingByImages">
##  <ManSection>
##  <Oper Name="RingGeneralMappingByImages" Arg='R, S, gens, imgs'/>
##
##  <Description>
##  is a general mapping from the ring <A>A</A> to the ring <A>S</A>.
##  This general mapping is defined by mapping the entries in the list
##  <A>gens</A> (elements of <A>R</A>) to the entries in the list <A>imgs</A>
##  (elements of <A>S</A>),
##  and taking the additive and multiplicative closure.
##  <P/>
##  <A>gens</A> need not generate <A>R</A> as a ring,
##  and if the specification does not define an additive and multiplicative
##  mapping then the result will be multivalued.
##  Hence, in general it is not a mapping.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "RingGeneralMappingByImages",
    [ IsRing, IsRing, IsHomogeneousList, IsHomogeneousList ] );


#############################################################################
##
#F  RingHomomorphismByImages( <R>, <S>, <gens>, <imgs> )
##
##  <#GAPDoc Label="RingHomomorphismByImages">
##  <ManSection>
##  <Func Name="RingHomomorphismByImages" Arg='R, S, gens, imgs'/>
##
##  <Description>
##  <Ref Func="RingHomomorphismByImages"/> returns the ring homomorphism with
##  source <A>R</A> and range <A>S</A> that is defined by mapping the list
##  <A>gens</A> of generators of <A>R</A> to the list <A>imgs</A> of images
##  in <A>S</A>.
##  <P/>
##  If <A>gens</A> does not generate <A>R</A> or if the homomorphism does not
##  exist (i.e., if mapping the generators describes only a multi-valued
##  mapping) then <K>fail</K> is returned.
##  <P/>
##  One can avoid the checks by calling
##  <Ref Oper="RingHomomorphismByImagesNC"/>,
##  and one can construct multi-valued mappings with
##  <Ref Func="RingGeneralMappingByImages"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RingHomomorphismByImages" );


#############################################################################
##
#O  RingHomomorphismByImagesNC( <R>, <S>, <gens>, <imgs> )
##
##  <#GAPDoc Label="RingHomomorphismByImagesNC">
##  <ManSection>
##  <Oper Name="RingHomomorphismByImagesNC" Arg='R, S, gens, imgs'/>
##
##  <Description>
##  <Ref Oper="RingHomomorphismByImagesNC"/> is the operation that is called
##  by the function <Ref Func="RingHomomorphismByImages"/>.
##  Its methods may assume that <A>gens</A> generates <A>R</A> as a ring
##  and that the mapping of <A>gens</A> to <A>imgs</A> defines a ring
##  homomorphism.
##  Results are unpredictable if these conditions do not hold.
##  <P/>
##  For creating a possibly multi-valued mapping from <A>R</A> to <A>S</A>
##  that respects addition and multiplication,
##  <Ref Func="RingGeneralMappingByImages"/> can be used.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "RingHomomorphismByImagesNC",
    [ IsRing, IsRing, IsHomogeneousList, IsHomogeneousList ] );


#############################################################################
##
#O  NaturalHomomorphismByIdeal( <R>, <I> ) . . . . . . . map onto factor ring
##
##  <#GAPDoc Label="NaturalHomomorphismByIdeal">
##  <ManSection>
##  <Oper Name="NaturalHomomorphismByIdeal" Arg='R, I'/>
##
##  <Description>
##  is the homomorphism of rings provided by the natural
##  projection map of <A>R</A> onto the quotient ring <A>R</A>/<A>I</A>.
##  This map can be used to take pre-images in the original ring from
##  elements in the quotient.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "NaturalHomomorphismByIdeal",
    [ IsRing, IsRing ] );


#############################################################################
##
#E

