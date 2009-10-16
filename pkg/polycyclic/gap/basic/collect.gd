#############################################################################
##
#W  collect.gd                 Polycyclic                       Werner Nickel
##

#############################################################################
##
##  First we need a new representation for a power-conjugate collector, which
##  will  implement the  generic collector  for  groups given by a polycyclic
##  presentation.
##
#R  IsFromTheLeftCollectorRep( <obj> )
##
DeclareRepresentation( "IsFromTheLeftCollectorRep",
                        IsPowerConjugateCollector, [] );

BindGlobal( "FromTheLeftCollectorFamily",
    NewFamily( "FromTheLeftCollector", IsFromTheLeftCollectorRep ) );
          
#############################################################################
##  
#P  The following property is set if a collector presents a nilpotent group
##  and has a weight array and a second commute array.  . . . . . . . . . . .
##
DeclareProperty( "IsWeightedCollector", IsPolycyclicCollector );

#############################################################################
##  
#P  The following property is set if a collector presents a nilpotent group
##  and has Hall polynomials (computed by Deep Thought)
##
DeclareProperty( "IsPolynomialCollector", IsFromTheLeftCollectorRep );

#############################################################################
##  
#P  The following property is used to dispatch between a GAP level collector
##  and the kernel collector.  By default the property is false.  Its main
##  use is for debugging purposes.
##
DeclareProperty( "UseLibraryCollector", IsFromTheLeftCollectorRep  );

#############################################################################
##  
#V  The following variables are global flags mainly intended for debugging
##  purposes.
##
BindGlobal( "USE_LIBRARY_COLLECTOR", false );
BindGlobal( "DEBUG_COMBINATORIAL_COLLECTOR", false );
BindGlobal( "USE_COMBINATORIAL_COLLECTOR", false );

#############################################################################
##
##  Next the operation for creating a from-the-left collector is defined.
##
#O  FromTheLeftCollector. . . . . . . . . . . . . . . . . . . . . . . . . . .
##
DeclareOperation( "FromTheLeftCollector", [IsObject] );

#############################################################################
##
##  This is the inverse operation for ObjByExponents.
##
#O  ExponentsByObj
##
DeclareOperation( "ExponentsByObj", [IsPolycyclicCollector, IsObject] );

#############################################################################
##
##  These operations should be defined in the GAP library.
##
#O  GetPower
#O  GetConjugate
##
DeclareOperation( "GetPower", [IsPolycyclicCollector, IsObject] );
DeclareOperation( "GetConjugate", 
        [IsPolycyclicCollector, IsObject, IsObject] );

#############################################################################
##
#I  InfoFromTheLeftCollector 
#I  InfoCombinatorialFromTheLeftCollector 
##
DeclareInfoClass( "InfoFromTheLeftCollector" );
DeclareInfoClass( "InfoCombinatorialFromTheLeftCollector" );

############################################################################
##
#F  NumberOfGenerators
#F  FromTheLeftCollector_SetCommute
#F  FromTheLeftCollector_CompletePowers
#F  FromTheLeftCollector_CompleteConjugate
##
DeclareGlobalFunction( "NumberOfGenerators" );
DeclareGlobalFunction( "FromTheLeftCollector_SetCommute" );
DeclareGlobalFunction( "FromTheLeftCollector_CompletePowers" );
DeclareGlobalFunction( "FromTheLeftCollector_CompleteConjugate" );

############################################################################
##
#F  IsPcpNormalFormObj( <ftl>, <w> )
##
DeclareGlobalFunction( "IsPcpNormalFormObj" );

############################################################################
##
#P  IsPolycyclicPresentation
##
## checks whether the input-presentation is a polycyclic presentation, i.e.
## whether the right-hand-sides of the relations are normal.
##
DeclareProperty( "IsPolycyclicPresentation", IsFromTheLeftCollectorRep );

#############################################################################
##
#H The following indices point into a from the left collector.  They are used
##  in additoin to the ones  defined in the GAP source file src/objcftl.h/.c.
##  Eventually,  there  will be  one  place for  defining  the  indices of  a
##  from-the-left collector.
##
BindGlobal( "PC_PCP_ELEMENTS_FAMILY", 22 );
BindGlobal( "PC_PCP_ELEMENTS_TYPE",   23 );

BindGlobal( "PC_COMMUTATORS",               24 );
BindGlobal( "PC_INVERSECOMMUTATORS",        25 );
BindGlobal( "PC_COMMUTATORSINVERSE",        26 );
BindGlobal( "PC_INVERSECOMMUTATORSINVERSE", 27 );

BindGlobal( "PC_NILPOTENT_COMMUTE", 28 );
BindGlobal( "PC_WEIGHTS",           29 );
BindGlobal( "PC_ABELIAN_START",     30 );
