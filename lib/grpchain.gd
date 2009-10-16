#############################################################################
##
#W  grpchain.gd			GAP Library		       Gene Cooperman
#W							     and Scott Murray
##
#H  @(#)$Id: grpchain.gd,v 4.7 2002/04/15 10:04:44 sal Exp $
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  Requires: transversal
##
Revision.grpchain_gd :=
    "@(#)$Id: grpchain.gd,v 4.7 2002/04/15 10:04:44 sal Exp $";

#1
##  Data structures for storing general group chains. Note that this does 
##  *not* replace `StabChain'.
##  The group attribute `ChainSubgroup(<G>)' stores the next group down 
##  in the chain (i.e.~the structure is recursive).  `ChainSubgroup(<G>)' 
##  should have an attribute `Transversal' which describes a transversal 
##  of `ChainSubgroup(<G>)' in <G>, as in `gptransv.[gd,gi]'.
##  
##  The command `ChainSubgroup' will use the default method for computing
##  chains -- currently this is random Schreier-Sims, unless the group is
##  nilpotent.
##  *Warning:* This algorithm is Monte-Carlo.
##  `ChainSubgroup' is mutable, since it may start as the trivial subgroup,
##  and then grow as elements are sifted in, and some stick.
##  This allows us to do, if we want, things like:
##  
##  \){\kernttindent}SetChainSubgroup(<G>, ClosureGroup(ChainSubgroup(<G>), %
##  <siftee>) );
##  
##  Whether this code is used instead of previous methods is determined by 
##  4 variables which control the behaviour of the filter `IsChainTypeGroup'.
##  See the file `gap.../lib/grpchain.gd' for details.
##  

DeclareInfoClass( "InfoChain" );

#############################################################################
#############################################################################
##
##  Control variables
##
#############################################################################
#############################################################################

##  Use chain subgroups for matrix groups
UseMatrixChainSubgroups := false;

##  Use chain subgroups for permutation groups
UsePermChainSubgroups := false;

##  Use our code rather than StabChain
UseStabChainViaChainSubgroup := false;

##  Cutoff for using our code rather than nice homomorphisms for mx grps
SmallSpaceCutoff := 50000;

#############################################################################
##
#A  ChainSubgroup( <G> )
##
##  Computes the chain, if necessary, and returns the next subgroup in the 
##  chain.  The current default is to use the random Schreier-Sims algorithm,
##  unless the group is known to be nilpotent, in which case `MakeHomChain'
##  is used.
##
DeclareAttribute( "ChainSubgroup", IsGroup, "mutable" );

#############################################################################
##
#A  Transversal( <G> )
##
##  The transversal of the group <G> in the previous subgroup of the chain.
##
DeclareAttribute( "Transversal", IsGroup );  


#############################################################################
##
#O  IsInChain( <G> )
##
##  A group <G> is in a chain if it has either a `ChainSubgroup' or 
##  a `Transversal'.
##
DeclareFilter( "IsInChain" );     
InstallTrueMethod( IsInChain, HasChainSubgroup );
InstallTrueMethod( IsInChain, HasTransversal );  

#############################################################################
##
#P  IsFFEMatrixGroupOverLargeSpace( <G> )
##
##  Is the underlying vector space of size less than SmallSpaceCutoff?
##
DeclareProperty( "IsFFEMatrixGroupOverLargeSpace", IsGroup );
InstallImmediateMethod( IsFFEMatrixGroupOverLargeSpace,
    IsFFEMatrixGroup and HasDimensionOfMatrixGroup and HasFieldOfMatrixGroup, 0,
    G -> Size( FieldOfMatrixGroup(G) ) ^ DimensionOfMatrixGroup( G )
         >= SmallSpaceCutoff );

#############################################################################
##
#P  IsChainTypeGroup( <G> )
##
##  returns `true' if the group <G> is ``chain type'', i.e. it is the kind
##  of group where computations are best done with chains.
##
DeclareProperty( "IsChainTypeGroup", IsGroup );
InstallImmediateMethod( IsChainTypeGroup, IsPermGroup, 0,
                        G -> UsePermChainSubgroups ) ;
InstallImmediateMethod( IsChainTypeGroup, IsFFEMatrixGroupOverLargeSpace, 0,
                        G -> UseMatrixChainSubgroups );

InstallMethod( IsChainTypeGroup, "default:  false if no immediate method ran",
               true, [ IsGroup ], 0, ReturnFalse );

#############################################################################
##
#P  IsStabChainViaChainSubgroup( <G> )
##
##  returns `true' if stabiliser chains for <G> are to be computed with our 
##  code rather than with `StabChain'.
##
DeclareProperty( "IsStabChainViaChainSubgroup", IsPermGroup );                       
InstallImmediateMethod( IsStabChainViaChainSubgroup, IsPermGroup, 0,
                        G -> UseStabChainViaChainSubgroup ) ;

#############################################################################
##
#P  GeneratingSetIsComplete( <G> )
##
##  returns `true' if the generating set of the group <G> is complete.  For 
##  example, for a stabiliser subgroup this is true if our strong generators
##  have been verified.
##
DeclareProperty( "GeneratingSetIsComplete", IsGroup );


#############################################################################
#############################################################################
##
##  General chain utilities
##
#############################################################################
#############################################################################

#############################################################################
##
#O  SiftOneLevel( <G>, <g> )
##
##  Sift <g> though one level of the chain.
##
DeclareOperation( "SiftOneLevel", 
    [ IsGroup and HasChainSubgroup, IsAssociativeElement ] );

#############################################################################
##
#O  Sift( <G>, <g> )
##
##  Sift <g> through the entire chain.
##
DeclareOperation( "Sift", 
    [ IsGroup, IsAssociativeElement ] );

#############################################################################
##
#F  SizeOfChainOfGroup( <G> )
##
##  Uses the chain to compute the size of a group.  Unlike `Size(<G>)',
##  this does not set the `Size' attribute, which is useful if the chain is
##  not known to be complete.
##  
DeclareGlobalFunction( "SizeOfChainOfGroup", [IsGroup] );

#############################################################################
##
#F  TransversalOfChainSubgroup( <G> )
##
##  Returns the transversal of the next group in the chain, inside <G>.
##
DeclareGlobalFunction( "TransversalOfChainSubgroup", [IsGroup] );

#############################################################################
##
#F  ChainStatistics( <G> )
##
##  Returns a record containing useful statistics about the chain of <G>.
##
DeclareGlobalFunction( "ChainStatistics", [IsGroup and HasChainSubgroup ] );

#############################################################################
##
#F  HasChainHomomorphicImage( <G> )
##
##  Does <G> have a chain subgroup derived from a homomorphic image?
##  This will be `false' for stabiliser, trivial, and sift function chain 
##  subgroups.  It will be true for homomorphism and direct product chain
##  subgroups.
##
DeclareGlobalFunction( "HasChainHomomorphicImage" );

#############################################################################
##
#F  ChainHomomorphicImage( <G> )
##
##  Returns the chain homomorphic image, or `fail' if no such image exists.
##
DeclareGlobalFunction( "ChainHomomorphicImage" );



#############################################################################
#############################################################################
##
##  Stabiliser chain utilities
##
#############################################################################
#############################################################################

#############################################################################
##
#A  BaseOfGroup( <G> )
##
##  If the group <G> has a chain consisting entirely of stabiliser subgroups,
##  then this command returns the base as a list.  This command does not 
##  compute a base, however.
##
DeclareAttribute( "BaseOfGroup", IsGroup and IsInChain );


#############################################################################
##
#O  ExtendedGroup( <G>, <g> )
##
##  Add a new Schreier generator for <G>.
##
DeclareOperation( "ExtendedGroup", 
    [ IsGroup and IsInChain, IsAssociativeElement ] );


#############################################################################
##
#F  StrongGens( <G> )
##
##  Returns a list of generating sets for each level of the chain.
##
DeclareGlobalFunction( "StrongGens", [ IsGroup ] );

#############################################################################
##
#F  ChainSubgroupByStabiliser( <G>, <basePoint>, <Action> )
##
##  Form a chain subgroup by stabilising <basePoint> under the given action.
##  The subgroup will start with no generators, and will have a transversal
##  by Schreier tree.
##
DeclareGlobalFunction( "ChainSubgroupByStabiliser", 
    [ IsGroup, IsObject, IsFunction ] );

#############################################################################
##
#A  OrbitGeneratorsOfGroup( <G> )
##
##  Generators used to compute the orbit of <G>.  Used by `baseim.[gd,gi]'.
##
DeclareAttribute( "OrbitGeneratorsOfGroup", IsGroup );


#############################################################################
#############################################################################
##
##  Hom coset chain utilities
##
#############################################################################
#############################################################################

#############################################################################
##
#F  ChainSubgroupByHomomorphism( <hom> )
##
##  Form a chain subgroup by the kernel of <hom>.
##  The subgroup will start with no generators, and will have a <hom>
##  transversal.
##
DeclareGlobalFunction( "ChainSubgroupByHomomorphism", [ IsGroupHomomorphism ] );

#############################################################################
##
#F  ChainSubgroupByProjectionFunction( <G>, <kernelSubgp>, <imgSubgp>, %
#F  <projFnc> )
##
##  When the homomorphism of a quotient group is a projection, then
##  there is an internal semidirect product, for which `TransversalElt()'
##  has a direct implementation as the projection.
##  <hom> will be the projection, and `<elt> -> ImageElm(<hom>, <elt>)' is 
##  the map.
##
DeclareGlobalFunction( "ChainSubgroupByProjectionFunction",
    [ IsGroup, IsGroup, IsFunction ]); # Ideally, IsProjection, if it existed.

#############################################################################
##
#F  QuotientGroupByChainHomomorphicImage( <quo>[, <quo2>] )
##
##  This function deals with quotient groups of quotient groups in a chain.
##
DeclareGlobalFunction( "QuotientGroupByChainHomomorphicImage" );

#############################################################################
##
#A  ChainSubgroupQuotient( <G> )
##
##  The quotient by the chain subgroup.
##
DeclareAttribute( "ChainSubgroupQuotient", IsGroup );




#############################################################################
#############################################################################
##
##  Direct sum chain utilities
##
#############################################################################
#############################################################################

#############################################################################
##
#F  ChainSubgroupByDirectProduct( <proj>, <inj > )
##
##  Form a chain subgroup by internal direct product.
##
DeclareGlobalFunction( "ChainSubgroupByDirectProduct", 
    [ IsGroupHomomorphism, IsGroupHomomorphism ] );

#############################################################################
##
#F  ChainSubgroupByPSubgroupOfAbelian( <G>, <p> )
##
##  <G> is an abelian group, <p> a prime involved in <G>.
##  Form a direct sum chain where the subgroup is the <p>-prime part of <G>.
##
DeclareGlobalFunction( "ChainSubgroupByPSubgroupOfAbelian", 
    [ IsGroup and IsAbelian, IsInt ] );



#############################################################################
#############################################################################
##
##  Trivial subgroup chain utilities
##
#############################################################################
#############################################################################

#############################################################################
##
#F  ChainSubgroupByTrivialSubgroup( <G> )
##
##  Form a chain subgroup by enumerating the group.
##
DeclareGlobalFunction( "ChainSubgroupByTrivialSubgroup", 
    [ IsGroup ] );

#############################################################################
#############################################################################
##
##  Sift function chain utilities
##
#############################################################################
#############################################################################

#############################################################################
##
#F  ChainSubgroupBySiftFunction( <G>, <subgroup>, <siftFnc> )
##
##  Form a chain subgroup using a sift function.
##
DeclareGlobalFunction( "ChainSubgroupBySiftFunction", 
    [ IsGroup, IsGroup, IsFunction ] );


#############################################################################
##
#E  grpchain.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
