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
##  This file contains the implementations for functions pertaining to
##  adjoining an identity element to a semigroup.
##

###########################################################################
##
#M  AdjoinedIdentityFamily( <fam> )
##

InstallMethod(AdjoinedIdentityFamily, [IsFamily],
        function(fam)
    local   afam;
    afam := NewFamily(Concatenation("AdjoinedIdentityFamily(",fam!.NAME,")"),
                    IsMonoidByAdjoiningIdentityElt);
    SetUnderlyingSemigroupFamily(afam, fam);
    return afam;
end);

###########################################################################
##
#M  AdjoinedIdentityDefaultType( <fam> )
##

InstallMethod(AdjoinedIdentityDefaultType, [IsFamily],
        function(fam)
    return NewType(fam, IsMonoidByAdjoiningIdentityEltRep and
                   IsMonoidByAdjoiningIdentityElt);
end);

###########################################################################
##
#A  MonoidByAdjoiningIdentityElt( <elt> )
##
##  the result of this function is the corresponding element in the category
##  MonoidByAdjoiningIdentityElt with IsOne set to false.
##

InstallMethod( MonoidByAdjoiningIdentityElt, [IsMultiplicativeElement and IsAssociativeElement],
        function(se)
    local   fam,  l;
    fam := FamilyObj(se);
    l := [ se ];
    Objectify(AdjoinedIdentityDefaultType(AdjoinedIdentityFamily(fam)),l);
    SetIsOne(l,false);
    return l;
end);

###########################################################################
##
#M  <elt1> \* <elt2>
##
##  returns <elt2> if <elt1> represents the identity, <elt1> if <elt2>
##  represents the identity, and otherwise returns the value of
##  MonoidByAdjoiningIdentityElt for product of the underlying
##  elements.
##

InstallMethod(\*,         IsIdenticalObj,
        [IsMonoidByAdjoiningIdentityElt, IsMonoidByAdjoiningIdentityElt],
        function(me1,me2)
    if me1![1] = fail then
        return me2;
    elif me2![1] = fail then
        return me1;
    else
        return MonoidByAdjoiningIdentityElt(me1![1] * me2![1]);
    fi;
end);

###########################################################################
##
#M  <elt1> \< <elt2>
##
##  compares underlying elements if they exist, and considers the representative
##  of the identity to be the least element otherwise.
##

InstallMethod(\<,         IsIdenticalObj,
        [IsMonoidByAdjoiningIdentityElt, IsMonoidByAdjoiningIdentityElt],
        function(me1,me2)
    if me1![1] = fail then
        return me2![1] <> fail;
    elif me2![1] = fail then
        return false;
    else
        return me1![1] < me2![1];
    fi;
end);

###########################################################################
##
#M  <elt1> \= <elt2>
##
##  returns true if both elements represent the identity, false if one does
##  and the other doesn't, otherwise compares underlying elements.
##

InstallMethod(\=,         IsIdenticalObj,
        [IsMonoidByAdjoiningIdentityElt, IsMonoidByAdjoiningIdentityElt],
        function(me1,me2)
    if me1![1] = fail then
        return me2![1] = fail;
    elif me2![1] = fail then
        return false;
    else
        return me1![1] = me2![1];
    fi;
end);

###########################################################################
##
#M  One( <elt> )
##
##  returns the One of the element <elt>.
##

InstallMethod(One, [IsMonoidByAdjoiningIdentityElt],
        function(me)
    local   l;
    l := [ fail];
    Objectify(AdjoinedIdentityDefaultType(FamilyObj(me)),l);
    SetIsOne(l, true);
    return l;
end);

###########################################################################
##
#M  MonoidByAdjoiningIdentity( <semigroup> )
##
##  returns the monoid obtained from <semigroup> by adjoining an identity.
##

InstallMethod(MonoidByAdjoiningIdentity, [IsSemigroup and HasGeneratorsOfSemigroup],
        function( s )
        local m;
        m:=Monoid(List(GeneratorsOfSemigroup(s), MonoidByAdjoiningIdentityElt));
        SetUnderlyingSemigroupOfMonoidByAdjoiningIdentity(m, s);
        return m;
end);

###########################################################################
##
#M  UnderlyingSemigroupElementOfMonoidByAdjoiningIdentityElt( <elt> )
##
##  returns the underlying element of the MonoidByAdjoiningIdentityElt <elt>.
##

InstallMethod(UnderlyingSemigroupElementOfMonoidByAdjoiningIdentityElt,
        [IsMonoidByAdjoiningIdentityElt],
        x->x![1]);

InstallMethod(PrintObj, [IsMonoidByAdjoiningIdentityElt],
        function(me)
    if me![1] = fail then
        Print("<adjoined identity>");
        return;
    fi;
    Print("MonoidByAdjoiningIdentityElt(");
    Print(me![1]);
    Print(")");
end);

InstallMethod(ViewObj, [IsMonoidByAdjoiningIdentityElt],
        function(me)
    if me![1] = fail then
        Print("ONE");
        return;
    fi;
    ViewObj(me![1]);
end);
