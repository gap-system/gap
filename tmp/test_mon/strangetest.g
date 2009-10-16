
# This example causes an infinite recursion
# should be fixed when the infinite list stuff
# is cleaned up.

#### RFM July 3, 2000   Needs a length method for
####     the required enumerator.  See below.

# The category of the domain
DeclareCategory("IsTest", IsDomain);

# Representation of the enumerator
DeclareRepresentation("IsTestEnumRep", IsDomainEnumerator and 
        IsDenseList and IsAttributeStoringRep, rec());

# Enumerator creation
InstallMethod(Enumerator, "", true, [IsTest], 0,
function(d)
    local e;
    e:= Objectify(NewType(NewFamily("Fam2"), IsDomainEnumerator and
                IsTestEnumRep), rec());
    SetUnderlyingCollection(e, d);
    return e;
end);

# Just en[1] = 1, .. , en[5] = 5 and en[n] is unbound for n > 5

InstallMethod(\[\], "", true, [IsTestEnumRep, IsPosInt], 0,
function(e, i)
    return UnderlyingCollection(e)!.elms[i];
end);

InstallMethod(IsBound\[\], "", true, [IsTestEnumRep, IsPosInt], 0,
function(e, i)
    return IsBound(UnderlyingCollection(e)!.elms[i]);
end);


## RFM Enumerator needs a length method related to it.
##     Here is one -- else Size(d) will cause a recursion trap.
##
InstallMethod(Length,"", true, [IsTestEnumRep],0,
function(s)
    local n;
    n:=1;

    while IsBound(s[n]) do
        n:=n+1;
    od;

    return n-1;
end);

d:= Objectify(NewType(NewFamily("Fam1"), IsTest and
IsAttributeStoringRep),
            rec(elms:= [1,2,3,4,5]));

Size(d);


