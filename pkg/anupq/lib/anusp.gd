#############################################################################
####
##
#A  anusp.gd                    ANUPQ package                  Eamonn O'Brien
#A                                                             Alice Niemeyer 
##
#A  @(#)$Id: anusp.gd,v 1.1 2002/02/15 08:53:47 gap Exp $
##
#Y  Copyright 1993-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1993-2001,  School of Mathematical Sciences, ANU,     Australia
##
#A  @(#)$Id: anusp.gd,v 1.1 2002/02/15 08:53:47 gap Exp $
##
Revision.anusp_gd :=
    "@(#)$Id: anusp.gd,v 1.1 2002/02/15 08:53:47 gap Exp $";

#############################################################################
##
#F  ANUPQSPerror( <param> )  . . . . . . . . . . . . report illegal parameter
##
DeclareGlobalFunction( "ANUPQSPerror" );

#############################################################################
##
#F  ANUPQSPextractArgs( <args> )  . . . . . . . . . . . . parse argument list
##
DeclareGlobalFunction( "ANUPQSPextractArgs" );

#############################################################################
##
#V  ANUSPGlobalVariables
##
DeclareGlobalVariable( "ANUSPGlobalVariables",
  "A list of names of ANUPQ standard presentation variables"
  );

#############################################################################
##
#F  PqFpGroupPcGroup( <G> ) . . . . . .  corresponding fp group of a pc group
#O  FpGroupPcGroup( <G> )
##
DeclareGlobalFunction( "PqFpGroupPcGroup" );
DeclareOperation( "FpGroupPcGroup", [ IsPcGroup ] );

#############################################################################
##
#F  PQ_EPIMORPHISM_STANDARD_PRESENTATION( <args> ) . (epi. onto) SP for group
#F  EpimorphismPqStandardPresentation( <arg> ) . . . epi. onto SP for p-group
#M  EpimorphismStandardPresentation( <F> ) . . . . . epi. onto SP for p-group
#M  EpimorphismStandardPresentation( [<i>] )
##
DeclareGlobalFunction( "PQ_EPIMORPHISM_STANDARD_PRESENTATION" );
DeclareGlobalFunction( "EpimorphismPqStandardPresentation" );
DeclareOperation( "EpimorphismStandardPresentation", [IsObject] );

#############################################################################
##
#F  PqStandardPresentation( <arg> : <options> ) . . . . . . .  SP for p-group
#M  StandardPresentation( <F> ) . . . . . . . . . . . . . . .  SP for p-group
#M  StandardPresentation( [<i>] )
##
DeclareGlobalFunction( "PqStandardPresentation" );
DeclareOperation( "StandardPresentation", [IsObject] );

#############################################################################
##
#F  IsPqIsomorphicPGroup( <G>, <H> )  . . . . . . . . . . .  isomorphism test
#O  IsIsomorphicPGroup( <G>, <H> )
##
DeclareGlobalFunction( "IsPqIsomorphicPGroup" );
DeclareOperation( "IsIsomorphicPGroup", [IsPcGroup, IsPcGroup] );

#E  anusp.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
