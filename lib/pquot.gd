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
#F  PQuotient(<fpgrp>,<p>) . .  . .  p-quotient of a finitely presented group
##
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
##  If  <quotsys>  is  a  quotient  system as  obtained  from  the  PQuotient
##  algorithm, this operation returns  an epimorphism $<F>\to<P>$ where $<F>$
##  is the finitely  presented group of which <quotsys>  is a quotient system
##  and $<P>$ is a `PcGroup' isomorphic  to the quotient of <F> determined by
##  <quotsys>.
##
##  Different calls to this operation will create nifferent groups <P>, each
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
#E  Emacs . . . . . . . . . . . . . . . . . . . . . . . . . . emacs variables
##  
##  Local Variables:
##  mode:               outline
##  tab-width:          4
##  outline-regexp:     "#[ACEFHMOPRWY]"
##  fill-column:        77
##  fill-prefix:        "##  "
##  End:

