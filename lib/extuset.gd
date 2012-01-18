#############################################################################
##
#W  extuset.gd                  GAP library                     Thomas Breuer
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file declares the operations for external upper sets.
##


#############################################################################
##
#C  IsExtUSet
##
DeclareCategory( "IsExtUSet", IsDomain );


#############################################################################
##
#C  IsAssociativeUOpDProd
##
DeclareCategory( "IsAssociativeUOpDProd", IsExtUSet );


#############################################################################
##
#C  IsAssociativeUOpEProd
##
DeclareCategory( "IsAssociativeUOpEProd", IsExtUSet );


#############################################################################
##
#C  IsDistributiveUOpDProd
##
DeclareCategory( "IsDistributiveUOpDProd", IsExtUSet );


#############################################################################
##
#C  IsDistributiveUOpDSum
##
DeclareCategory( "IsDistributiveUOpDSum", IsExtUSet );


#############################################################################
##
#C  IsDistributiveUOpEProd
##
DeclareCategory( "IsDistributiveUOpEProd", IsExtUSet );


#############################################################################
##
#C  IsDistributiveUOpESum
##
DeclareCategory( "IsDistributiveUOpESum", IsExtUSet );


#############################################################################
##
#C  IsTrivialUOpEOne
##
DeclareCategory( "IsTrivialUOpEOne", IsExtUSet );


#############################################################################
##
#C  IsTrivialUOpEZero
##
DeclareCategory( "IsTrivialUOpEZero", IsExtUSet );


#############################################################################
##
#C  IsUpperActedOnByGroup
##
DeclareCategory( "IsUpperActedOnByGroup", IsExtUSet );


#############################################################################
##
#C  IsUpperActedOnBySuperset
##
DeclareCategory( "IsUpperActedOnBySuperset", IsExtUSet );


#############################################################################
##
#A  GeneratorsOfExtUSet
##
DeclareAttribute( "GeneratorsOfExtUSet", IsExtUSet );


#############################################################################
##
#A  UpperActingDomain( <D> )
##
DeclareAttribute( "UpperActingDomain", IsExtRSet );


#############################################################################
##
#E  extuset.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



