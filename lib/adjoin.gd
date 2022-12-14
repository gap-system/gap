#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declarations for functions pertaining to
##  adjoining an identity element to a semigroup.
##


DeclareCategory("IsMonoidByAdjoiningIdentityElt", IsMultiplicativeElementWithOne and IsAssociativeElement);
DeclareCategory("IsMonoidByAdjoiningIdentity", IsMonoid);

DeclareAttribute("AdjoinedIdentityFamily", IsFamily);
DeclareAttribute("UnderlyingSemigroupFamily", IsFamily);
DeclareAttribute("AdjoinedIdentityDefaultType", IsFamily);

DeclareRepresentation("IsMonoidByAdjoiningIdentityEltRep", IsPositionalObjectRep, 1);

###########################################################################
##
#A  MonoidByAdjoiningIdentity( <semigroup> )
##
##  this attribute stores the monoid obtained from <semigroup> by adjoining
##  an identity. Even if <semigroup> happens to be a monoid, the resultant
##  monoid has a new identity adjoined.
##

DeclareAttribute("MonoidByAdjoiningIdentity", IsSemigroup);

###########################################################################
##
#A  UnderlyingSemigroupOfMonoidByAdjoiningIdentity( <monoid> )
##
##  this attribute stores the original semigroup that <monoid> was made from.
##

DeclareAttribute("UnderlyingSemigroupOfMonoidByAdjoiningIdentity", IsMonoidByAdjoiningIdentity );

###########################################################################
##
#A  MonoidByAdjoiningIdentityElt( <elt> )
##
##  the result of this function is the corresponding element in the category
##  MonoidByAdjoiningIdentityElt with IsOne set to false.
##

DeclareAttribute("MonoidByAdjoiningIdentityElt", IsMultiplicativeElement and IsAssociativeElement);

###########################################################################
##
#A  UnderlyingSemigroupOfMonoidByAdjoiningIdentity( <monoidelt> )
##
##  this attribute stores the original semigroup element that <monoidelt>
##  was made from.
##

DeclareAttribute("UnderlyingSemigroupElementOfMonoidByAdjoiningIdentityElt", IsMonoidByAdjoiningIdentityElt);
