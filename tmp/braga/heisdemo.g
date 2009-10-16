##################################################################
##
##  Heisenberg example.
##	The Heisenberg group is an infinite nilpotent group.
##
##################################################################

##################################################################
##
##  Part 1.  
##  Create the Heisenberg group.
##	Testing equality of words does not work: Coset enumeration fails.
##  

# creating the free semigroup and giving names to generators
f := FreeGroup( "gamma", "beta", "alpha");
alpha := GeneratorsOfGroup( f )[ 3 ];
beta := GeneratorsOfGroup( f )[ 2 ];
gamma := GeneratorsOfGroup( f )[ 1 ];

# the relators of the Heisenberg group
relators := [ alpha^-1 * beta^-1 * alpha * beta * gamma^-1,
alpha^-1 * gamma^-1 * alpha * gamma, beta^-1 * gamma^-1 * beta * gamma ];

# and finally factor the free group by the relators
g := f/relators;

###########################################################
##
##	Part 2.	
##	Build an ismorphism to a finitely presented semigroup.	
##	Create a rewriting system with respect to the basic
##	Wreath product ordering.
##	Test equality of words.
##

# the isomorphism and the heisenberg semigroup
phi := IsomorphismFpSemigroup( g );
s := Range( phi );

# give names to the generators of the semigroup
sgens := GeneratorsOfSemigroup( s );
gamma_inv := sgens[ 2 ]; gamma := sgens[ 3 ];
beta_inv := sgens[ 4 ]; beta := sgens[ 5 ];
alpha_inv := sgens[ 6 ]; alpha := sgens[ 7 ]; 

# build the rewriting system
# ordeding to be used has to be basic wreath product ordering
# to be possible to find a coinfluent rewriting system 
kbrws := KnuthBendixRewritingSystem( s, IsBasicWreathLessThanOrEqual );

# test equality of words
gamma_inv * alpha = alpha * gamma_inv;


