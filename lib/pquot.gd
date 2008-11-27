#############################################################################
##  
#W  pquot.gd                    GAP Library                     Werner Nickel
##
#H  $Id$
##
#Y  Copyright (C) 1998, . . . . . . . . .  University of St Andrews, Scotland
##
Revision.pquot_gd :=
    "$Id$";

#############################################################################
##  
#F  AbelianPQuotient  . . . . . . . . . . .  initialize an abelian p-quotient
##
DeclareGlobalFunction( "AbelianPQuotient" );

#############################################################################
##
#F  PQuotient(<F>,<p> [,<c>] [,<logord>] [,<ctype>]) . . .  pq of an fp group
##
##  computes a factor <p>-group of a finitely presented group <F> in form 
##  of a quotient system.  The quotient system can be converted into an
##  epimorphism from <F> onto the <p>-group computed by the function
##  "EpimorphismQuotientSystem". 
##
##  For a group $G$ define the exponent-$p$ central series of $G$ inductively
##  by ${\cal P}_1(G) = G$ and ${\cal P}_{i+1}(G) = [{\cal P}_{i}(G),G]{\cal
##  P}_{i+1}(G)^p.$  The factor groups modulo the terms of the lower
##  exponent-$p$ central series are $p$-groups.  The group $G$ has $p$-class
##  $c$ if ${\cal P}_c(G)\not={\cal P}_{c+1}(G)=1.$ 
##  
##  The algorithm computes successive quotients modulo the terms of the
##  exponent-$p$ central series of <F>.  If the parameter <c> is present,
##  then the factor group modulo the $(c+1)$-th term of the exponent-$p$
##  central series of <F> is returned.  If <c> is not present, then the
##  algorithm attempts to compute the largest factor <p>-group of <F>.  In
##  case <F> does not have a largest factor <p>-group, the algorithm will not
##  terminate.
##
##  By default the algorithm computes only with factor groups of order at
##  most $p^{256}.$ If the parameter <logord> is present, it will compute
##  with factor groups of order atmost $p^<logord>.$ If this parameter is
##  specified, then the parameter <c> must also be given.  The present
##  implementation produces an error message if the order of a $p$-quotient
##  exceeds $p^{256}$ or $p^<logord>,$ respectively.  Note that the order of
##  intermediate $p$-groups may be larger than the final order of a
##  $p$-quotient.
##
##  The parameter <ctype> determines the type of collector that is used for
##  computations within the factor <p>-group.  <ctype> must either be
##  `single' in which case a simple collector from the left is used or
##  `combinatorial' in which case a combinatorial collector from the left is
##  used. 
DeclareGlobalFunction( "PQuotient" );

#############################################################################
##
#O  EpimorphismPGroup( <fpgrp>, <p> ) .  factor p-group of a fin. pres. group
#O  EpimorphismPGroup( <fpgrp>, <p>, <cl> )                    factor p-group
##
##  computes an epimorphism from the finitely presented group <fpgrp> to the
##  largest $p$-group of $p$-class <cl> which is a quotient of <fpgrp>. If <cl>
##  is omitted, the largest finite $p$-group quotient (of $p$-class up to
##  1000) is determined.
DeclareOperation( "EpimorphismPGroup", [IsGroup, IsPosInt ] );
DeclareOperation( "EpimorphismPGroup", [IsGroup, IsPosInt, IsPosInt] );

#############################################################################
##
#O  EpimorphismQuotientSystem(<quotsys>)
##
##  For a quotient system <quotsys> obtained from the function "PQuotient",
##  this operation returns an epimorphism $<F>\to<P>$ where $<F>$ is the
##  finitely presented group of which <quotsys> is a quotient system and
##  $<P>$ is a `PcGroup' isomorphic to the quotient of <F> determined by
##  <quotsys>.
##
##  Different calls to this operation will create different groups <P>, each
##  with its own family.
##  
DeclareOperation( "EpimorphismQuotientSystem", [IsQuotientSystem] );

#############################################################################
##
#F  EpimorphismNilpotentQuotient(<fpgrp>[,<n>])
##
##  returns an epimorphism on the class <n> finite nilpotent quotient of the
##  finitely presented group <fpgrp>. If <n> is omitted, the largest
##  finite nilpotent quotient (of $p$-class up to 1000) is taken.
##
DeclareOperation("EpimorphismNilpotentQuotientOp",[IsGroup,IsObject]);
DeclareGlobalFunction("EpimorphismNilpotentQuotient");

#############################################################################
##
#F  Nucleus . . . . . . . . . . . . . . . . . . . .  the nucleus of a p-cover
##
DeclareOperation("Nucleus",[IsPQuotientSystem,IsGroup]);

#############################################################################
##
#E  Emacs . . . . . . . . . . . . . . . . . . . . . . . . . . emacs variables
##  
##  Local Variables:
##  mode:               outline
##  tab-width:          4
##  outline-regexp:     "#[ACEFHMOPRWY]"
##  fill-column:        77
##  fill-prefix:        "##  "
##  End:

