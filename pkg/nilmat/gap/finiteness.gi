#############################################################################
##
#W  finiteness.gi                   NilMat                       Alla Detinko
#W                                                               Bettina Eick
#W                                                              Dane Flannery
##

##
## This file contains methods for check whether a given f.g. nilpotent
## matrix group over Q is finite. Further, it contains methods to determine
## the order of a f.g. nilpotent matrix group over GF(q) or Q.
##

#############################################################################
##
#F IsFiniteNilpotentMatGroup( G )   . . . . . . . . . . . . decide finiteness
##
## This function takes a f.g. nilpotent matrix group G over Q and tests 
## whether it is finite. The test uses results of the nilpotency test 
## IsNilpotentMatGroup and hence it is particularly fast, if this test
## has been used for checking the nilpotence of G.
##
## Note that this function does not check whether G is nilpotent and it
## may return wrong results if it is not.
##
InstallGlobalFunction( IsFiniteNilpotentMatGroup, function(G)
    local n, g, d, a, p, t, pcgs, kern, F;

    # the trivial case
    F := FieldOfMatrixGroup(G);
    if IsFinite(F) then return true; fi;

    # set up
    g := GeneratorsOfGroup(G);
    d := List(g, JordanDecomposition);
    n := DimensionOfMatrixGroup(G);
    a := NullMat(n,n,Rationals);
   
    # check whether G contains unipotent part
    if ForAny(d, x -> not x[2] = a) then return false; fi;

    # compute kernel of congruence hom
    p := DetermineAdmissiblePrime(g);
    t := InducedByField(g, GF(p));
    pcgs := CPCS_finite_word( t, n+2 );
    kern := POL_NormalSubgroupGeneratorsOfK_p( pcgs, g );
 
    # check whether kernel is trivial
    kern := Filtered(kern, x -> not x = One(G));
    return (Length(kern) = 0);
end );

InstallMethod( IsFinite, true, [IsMatrixGroup and IsNilpotentGroup], 0,
function(G)
    local F;
    F := FieldOfMatrixGroup(G);
    if IsFinite(F) then return true; fi;
    if F = Rationals then return IsFiniteNilpotentMatGroup(G); fi;
    TryNextMethod();
end );

#############################################################################
##
#F SizeOfNilpotentMatGroupFF( G ) . . . . . . . . . . . . determine the order
##
## This function takes a nilpotent matrix group G over GF(q) and determines
## its order. The function uses results of the nilpotency test 
## IsNilpotentMatGroupFF and hence it is particularly fast, if this test
## has been used for checking the nilpotence of G.
##
## Note that this function does not check whether G is nilpotent and it
## may return wrong results if it is not.
##
## The calls to 'Size' below may need some further refinement and improve-
## ments.
##
SizeOfNilpotentMatGroupFF := function(G)
    local J, S, U, P, B, C, syl;
 
    # catch a trivial case
    if Length(GeneratorsOfGroup(G)) = 1 then
        return Order(GeneratorsOfGroup(G)[1]);
    fi;

    # get available info from nilpotency testing
    J := JordanSplitting(G);
    S := J[1];
    U := J[2];
    P := PiPrimarySplitting(S);
    B := P[1];
    C := P[2];
  
    # now G = B x C x U
    if IsAbelian(B) then
        return Size(U) * Size(C) * Size(B);
    else
        # in this case a Sylow system for B is known from nilpotency testing
        syl := SylowSystem(B);
        return Size(U) * Size(C) * Product(List(syl, Size));
    fi;
end;

#############################################################################
##
#F SizeOfNilpotentMatGroupRN( G ) . . . . . . . . . . . . determine the order
##
## This function takes a nilpotent matrix group G over Q and determines its 
## order. 
##
## Note that this function does not check whether G is nilpotent and it may 
## return wrong results if it is not.
##
SizeOfNilpotentMatGroupRN := function(G)
   local g, p, t, H;
   g := GeneratorsOfGroup(G);
   p := DetermineAdmissiblePrime(g);
   t := InducedByField(g, GF(p));
   H := MakeMatGroup(GF(p), t);
   return SizeOfNilpotentMatGroupFF(H);
end;

#############################################################################
##
#F SizeOfNilpotentMatGroup( G ) . . . . . . . . . . . . . determine the order
##
InstallGlobalFunction( SizeOfNilpotentMatGroup, function(G)
   local F;
   F := FieldOfMatrixGroup(G);
   if IsFinite(F) then return SizeOfNilpotentMatGroupFF(G);fi;
   if F = Rationals then return SizeOfNilpotentMatGroupRN(G);fi;
   return fail;
end );

##
## we cannot install a similar method to finite field groups, as the 
## algorithm for those groups uses a call to 'Size' for some smaller
## subgroups.
##

InstallMethod( Size, true, [IsMatrixGroup and IsNilpotentGroup], 0,
function(G)
   if FieldOfMatrixGroup(G) = Rationals then 
       return SizeOfNilpotentMatGroupRN(G); 
   fi;
   TryNextMethod();
end);
