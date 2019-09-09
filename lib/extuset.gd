#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
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
