#############################################################################
##
#W  extuset.gd                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file declares the operations for external upper sets.
##
Revision.extuset_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsExtUSet
##
IsExtUSet := NewCategory( "ExtUSet", IsDomain );


#############################################################################
##
#C  IsAssociativeUOpDProd
##
IsAssociativeUOpDProd := NewCategory( "IsAssociativeUOpDProd", IsExtUSet );


#############################################################################
##
#C  IsAssociativeUOpEProd
##
IsAssociativeUOpEProd := NewCategory( "IsAssociativeUOpEProd", IsExtUSet );


#############################################################################
##
#C  IsDistributiveUOpDProd
##
IsDistributiveUOpDProd := NewCategory( "IsDistributiveUOpDProd", IsExtUSet );


#############################################################################
##
#C  IsDistributiveUOpDSum
##
IsDistributiveUOpDSum := NewCategory( "IsDistributiveUOpDSum", IsExtUSet );


#############################################################################
##
#C  IsDistributiveUOpEProd
##
IsDistributiveUOpEProd := NewCategory( "IsDistributiveUOpEProd", IsExtUSet );


#############################################################################
##
#C  IsDistributiveUOpESum
##
IsDistributiveUOpESum := NewCategory( "IsDistributiveUOpESum", IsExtUSet );


#############################################################################
##
#C  IsTrivialUOpEOne
##
IsTrivialUOpEOne := NewCategory( "IsTrivialUOpEOne", IsExtUSet );


#############################################################################
##
#C  IsTrivialUOpEZero
##
IsTrivialUOpEZero := NewCategory( "IsTrivialUOpEZero", IsExtUSet );


#############################################################################
##
#C  IsUpperActedOnByGroup
##
IsUpperActedOnByGroup := NewCategory( "IsUpperActedOnByGroup", IsExtUSet );


#############################################################################
##
#C  IsUpperActedOnBySuperset
##
IsUpperActedOnBySuperset := NewCategory( "IsUpperActedOnBySuperset",
    IsExtUSet );


#############################################################################
##
#A  GeneratorsOfExtUSet
##
GeneratorsOfExtUSet := NewAttribute( "GeneratorsOfExtUSet", IsExtUSet );
SetGeneratorsOfExtUSet := Setter( GeneratorsOfExtUSet );
HasGeneratorsOfExtUSet := Tester( GeneratorsOfExtUSet );


#############################################################################
##
#A  UpperActingDomain( <D> )
##
UpperActingDomain := NewAttribute( "UpperActingDomain", IsExtRSet );
SetUpperActingDomain := Setter( UpperActingDomain );
HasUpperActingDomain := Tester( UpperActingDomain );


#############################################################################
##
#E  extuset.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



