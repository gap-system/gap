#############################################################################
##
#W  rwspcftl.gd                 GAP Library                     Werner Nickel
#W                                                               Bettina Eick
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St  Andrews, Scotland
##
##
Revision.rwspcftl_gd :=
    "@(#)$Id: rwspcftl.gd,v 1.1 1999/02/26 11:51:10 werner Exp $";

#############################################################################
##
##  First we need a new representation for a power-conjugate collector, which
##  will  implement the  generic collector  for  groups given by a polycyclic
##  presentation.
##
#R  IsFromTheLeftCollectorRep( <obj> )  . . . . . . . . . . . . . . . . . . .
##
DeclareRepresentation( "IsFromTheLeftCollectorRep",
                        IsPowerConjugateCollector, [] );

BindGlobal( "FromTheLeftCollectorFamily",
    NewFamily( "FromTheLeftCollector", IsFromTheLeftCollectorRep ) );
          
#############################################################################
##  
#P  The following property is used to dispatch between a GAP level collector
#P  and the kernel collector.           . . . . . . . . . . . . . . . . . . .
##
DeclareProperty( "UseKernelCollector", IsFromTheLeftCollectorRep  );

#############################################################################
##
##  Next the  operation for creating a from the left collector is defined.
##
#O  FromTheLeftCollector. . . . . . . . . . . . . . . . . . . . . . . . . . .
##
DeclareOperation( "FromTheLeftCollector", [IsObject] );

#############################################################################
##
## the elements of pcp groups
##
DeclareCategory( "IsPcpElement", 
                  IsMultiplicativeElementWithInverse );
DeclareCategoryFamily( "IsPcpElement" );
DeclareCategoryCollections( "IsPcpElement" );
DeclareRepresentation( "IsPcpElementRep", 
              IsComponentObjectRep,
              ["collector", "exponents", "name" ] );

#############################################################################
##
## attributes of the elements
##
#DeclareAttribute( "Collector", IsPcpElement );
#DeclareAttribute( "Name", IsPcpElement );
#DeclareAttribute( "Exponents", IsPcpElement );
#
#DeclareAttribute( "Depth", IsPcpElement );
#DeclareAttribute( "LeadingExponent", IsPcpElement );
#DeclareAttribute( "RelativeOrder", IsPcpElement );
               
#############################################################################
##
## the pcp groups
##
#DeclareProperty( "IsPcpGroup", IsGroup );
DeclareSynonym( "IsPcpGroup", IsGroup and IsPcpElementCollection );
DeclareAttribute( "Pcp", IsPcpGroup );

