#############################################################################
##
#W  schur.gd                 GAP library                        Werner Nickel 
#W                                                           Alexander Hulpke
##
#Y  (C) 2000 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.schur_gd :=
    "@(#)$Id$";

##############################################################################
##
#V  InfoSchur()
##
DeclareInfoClass( "InfoSchur" );

##############################################################################
##
#O  SchurCover(<G>)
##
##  returns one (of possibly several) Schur covers of <G>.
##
##  At the moment this cover is represented as a finitely presented group
##  and `IsomorphismPermGroup' would be needed to convert it to a
##  permutation group.
##
##  If also the relation to <G> is needed, `EpimorphismSchurCover' should be
##  used.
##
DeclareOperation( "SchurCover", [IsGroup] );

##############################################################################
##
#O  EpimorphismSchurCover(<G>[,<pl>])
##
##  returns an epimorphism <epi> from a group <D> onto <G>. The group <D> is
##  one (of possibly several) Schur covers of <G>.
##  The group <D> can be obtained as the `Source' of <epi>. the kernel of
##  <epi> is the schur multiplier of <G>.
##  If <pl> is given as a list of primes, only the multiplier part for these
##  primes is realized.
##  At the moment, <D> is represented as a finitely presented group.
DeclareOperation( "EpimorphismSchurCover", [IsGroup] );

##############################################################################
##
#O  AbelianInvariantsMultiplier(<G>)
##
##  \index{Multiplier}\atindex{Schur multiplier}{@Schur multiplier}
##  returns a list of the abelian invariants of the Schur multiplier of <G>.
DeclareOperation( "AbelianInvariantsMultiplier", [IsGroup] );

##############################################################################
##
#F  SchuMu(<G>,<p>)
##
## returns epimorphism from p-part of multiplier.p-Sylow (note: This
## extension is *not* necessarily isomorphic to a sylow subgroup of a
## Darstellungsgruppe!) onto p-Sylow, the
## kernel is the p-part of the multiplier.
## The implemented algorithm is based on section 7 in Derek Holt's paper.
## However we use some of the general homomorphism setup to avoid having to
## remember certain relations.
DeclareGlobalFunction("SchuMu");

##############################################################################
##
#F  CorestEval(<FG>,<s>)
##
## evaluate corestriction mapping.
## <FH> is an homomorphism from a finitely presented group onto a finite
## group <G>. <s> an epimorphism onto a p-Sylow subgroup of <G> as obtained
## from `SchuMu'.
## This function evaluates the relators of the source of <FH> in the
## extension M_p.<G>. It returns a list whose entries are of the form
## [<rel>,<val>], where <rel> is a relator of <G> and <val> its evaluation as
## an element of M_p.
DeclareGlobalFunction("CorestEval");

##############################################################################
##
#F  RelatorFixedMultiplier(<hom>,<p>)
##
##  Let <hom> an epimorphism from an fp group onto a finite group <G>. This
##  function returns an epimorphism onto the <p>-Sylow subgroup of <G>,
##  whose kernel is the largest quotient of the multiplier, that can lift
##  <hom> to a larger quotient. (The source of this map thus is $M_R(B)$
##  of~\cite{HulpkeQuot}.)
DeclareGlobalFunction("RelatorFixedMultiplier");

