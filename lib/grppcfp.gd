#############################################################################
##
#W  grppcfp.gd                  GAP library                      Bettina Eick
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.grppcfp_gd :=
    "@(#)$Id$"; 

#############################################################################
##
#I  InfoSQ
##
DeclareInfoClass( "InfoSQ" );

#############################################################################
##
#F  PcGroupFpGroup( <G> )
##
##  creates a PcGroup <P> from an FpGroup (see Chapter "Finitely Presented
##  Groups") <G> whose presentation is polycyclic. The resulting group <P>
##  has generators corresponding to the generators of <G>. They are printed
##  in the same way as generators of <G>, but they lie in a different
##  family. If the pc presentation of <G> is not confluent, an error message
##  occurs.
#T  should this become a method?
DeclareGlobalFunction( "PcGroupFpGroup" );
DeclareGlobalFunction( "PcGroupFpGroupNC" );

#############################################################################
##
#F  SmithNormalFormSQ( mat ) 
##
##  Obsolete function. Use NormalFormIntMat instead.
DeclareGlobalFunction( "SmithNormalFormSQ" );

#############################################################################
##
#F  InitEpimorphismSQ( F )
#F  InitEpimorphismSQ(<hom>)
##
##  If <F> is a finitiely presented group, this operation returns the SQ
##  epimorphism system corresponding to the largest abelian quotient of <F>.
##  If <hom> is a epimorphism from a finitely presented group to a pc
##  group, it returns the system coresponding to this epimorphism.
##  No argument checking is performed.
##  
DeclareGlobalFunction( "InitEpimorphismSQ" );

#############################################################################
##
#F  LiftEpimorphismSQ( epi, M, c )
##
##  if c is an integer, split extensions are searched. if c=0 only one is
##  returned, otherwise the subdirect product of all such extensions is
##  found.
DeclareGlobalFunction( "LiftEpimorphismSQ" );

#############################################################################
##
#F  BlowUpCocycleSQ( v, K, F )
##
DeclareGlobalFunction( "BlowUpCocycleSQ" );

#############################################################################
##
#F  TryModuleSQ( epi, M )
##
DeclareGlobalFunction( "TryModuleSQ" );

#############################################################################
##
#F  TryLayerSQ( epi, layer )
##
DeclareGlobalFunction( "TryLayerSQ" );

#############################################################################
##
#F  SQ( <F>, <...> ) / SolvableQuotient( <F>, <...> )
##  should this become a method?
##
DeclareGlobalFunction( "SolvableQuotient" );
DeclareSynonym( "SQ", SolvableQuotient);

#############################################################################
##
#F  AllModulesSQ( epi, M )
##
##  returns a list of all permissible extensions of <epi> with the module
##  <M>.
DeclareGlobalFunction("AllModulesSQ");

#############################################################################
##
#F  EAPrimeLayerSQ( epi, prime )
##
##  returns the largest elementary abelian <prime> layer extending <epi>.
DeclareGlobalFunction("EAPrimeLayerSQ");
