#############################################################################
##
#W cong.g                  The Congruence package                   Ann Dooms
#W                                                               Eric Jespers
#W                                                        Alexander Konovalov
##
#H $Id: cong.g,v 1.3 2008/05/28 23:58:03 alexk Exp $
##
#############################################################################

#############################################################################
#
# CanEasilyCompareCongruenceSubgroups( G, H )
#
InstallGlobalFunction( "CanEasilyCompareCongruenceSubgroups",
function ( G, H )
local i;
if ForAll( [ G, H ], IsPrincipalCongruenceSubgroup ) or
   ForAll( [ G, H ], IsCongruenceSubgroupGamma0 ) or
   ForAll( [ G, H ], IsCongruenceSubgroupGammaUpper0 ) or
   ForAll( [ G, H ], IsCongruenceSubgroupGamma1 ) or
   ForAll( [ G, H ], IsCongruenceSubgroupGammaUpper1 ) then
  return LevelOfCongruenceSubgroup(G)=LevelOfCongruenceSubgroup(H);
elif ForAll( [ G, H ], IsIntersectionOfCongruenceSubgroups ) then
  # we use the canonical ordering of subgroups 
  # in the intersection of congruence subgroups
  if Length(DefiningCongruenceSubgroups(G)) <> 
     Length(DefiningCongruenceSubgroups(H)) then
    return false;
  else
    return ForAll( [ 1 .. Length(DefiningCongruenceSubgroups(G)) ], i ->
                   CanEasilyCompareCongruenceSubgroups( 
                     DefiningCongruenceSubgroups(G)[i],
                     DefiningCongruenceSubgroups(H)[i]) );
  fi;  
else
  return false;
fi;
end);


#############################################################################
#
# CanReduceIntersectionOfCongruenceSubgroups( G, H )
#
# This function mimics the structure of the method for Intersection for
# congruence subgroups. It returns true, if their intersection can be reduced
# to one of the canonical congruence subgroups, and false otherwise, i.e. the
# intersection can be expressed only as IntersectionOfCongruenceSubgroups.
# This is used in IntersectionOfCongruenceSubgroups to reduce the list of
# canonical subgroups forming the intersection.
# 
InstallGlobalFunction( "CanReduceIntersectionOfCongruenceSubgroups",
function( G, H )
#
# Case 1 - at least one subgroup is an intersection of congruence subgroups
#
if IsIntersectionOfCongruenceSubgroups(G) or
   IsIntersectionOfCongruenceSubgroups(H) then
  return false;
#
# Case 2 - the diagonal (both subgroups has the same type)
# 
elif IsPrincipalCongruenceSubgroup(G) and IsPrincipalCongruenceSubgroup(H) then
  return true;
elif IsCongruenceSubgroupGamma1(G) and IsCongruenceSubgroupGamma1(H) then
  return true;
elif IsCongruenceSubgroupGammaUpper1(G) and IsCongruenceSubgroupGammaUpper1(H) then
  return true;
elif IsCongruenceSubgroupGamma0(G) and IsCongruenceSubgroupGamma0(H) then
  return true;
elif IsCongruenceSubgroupGammaUpper0(G) and IsCongruenceSubgroupGammaUpper0(H) then
  return true;
#
# Case 3 - Subgroups has different level
#
elif LevelOfCongruenceSubgroup(G) <> LevelOfCongruenceSubgroup(H) then
  return false;
  #
  # Now subgroups have the same level
  #
elif IsCongruenceSubgroupGamma1(G) and IsCongruenceSubgroupGamma0(H) then
  return true;
elif IsCongruenceSubgroupGamma0(G) and IsCongruenceSubgroupGamma1(H) then
  return true; 
elif IsCongruenceSubgroupGammaUpper1(G) and IsCongruenceSubgroupGammaUpper0(H) then
  return true;
elif IsCongruenceSubgroupGammaUpper0(G) and IsCongruenceSubgroupGammaUpper1(H) then
  return true;
elif IsCongruenceSubgroupGamma0(G) and IsCongruenceSubgroupGammaUpper0(H) or IsCongruenceSubgroupGammaUpper0(G) and IsCongruenceSubgroupGamma0(H) then
  return false;
else
  return true;
fi;                                             
end);
    
    
#############################################################################
#
# NumeratorOfGFSElement( gfs, i )
#
# Returns the numerator of the i-th term of the generalised Farey sequence 
# gfs: for the 1st infinite entry returns -1, for the last one returns 1,
# for all other entries returns usual numerator.
#  
InstallGlobalFunction( "NumeratorOfGFSElement",
function(gfs,i)
if i in [ 2 .. Length(gfs)-1 ] then
  return NumeratorRat( gfs[i] ); 
elif i=1 then
  return -1; # infinity on the left
elif i=Length(gfs) then
  return 1;  # infinity on the right
else
  Error("There is no entry number ", i, " in <gfs> !!! \n");  
fi;
end);


#############################################################################
#
# DenominatorOfGFSElement( gfs, i )
#
# Returns the denominator of the i-th term of the generalised Farey sequence 
# gfs: for both infinite entries returns 0, for the other ones returns usual 
# denominator.
#  
InstallGlobalFunction( "DenominatorOfGFSElement",
function(gfs,i)
if i in [ 2 .. Length(gfs)-1 ] then
  return DenominatorRat( gfs[i] ); 
elif i=1 or i=Length(gfs) then
  return 0;
else
  Error("There is no entry number ", i, " in <gfs> !!! \n");   
fi;
end);


#############################################################################
#
# IsValidFareySymbol( fs )
#
# This function is used in FareySymbolByData to validate its output
# 
InstallGlobalFunction( "IsValidFareySymbol" ,
function( fs )
local gfs, labels, n, i, t;
gfs := GeneralizedFareySequence(fs);
labels := LabelsOfFareySymbol(fs);
n := Length(gfs);
if ForAny( [ 1 .. Length(labels) ], t -> not IsBound(labels[t] ) ) then
  Error("<labels> must not contain holes !!! \n");
fi;
if Length(labels)<>n-1 then
  Error("Lengths of <gfs> and <labels> do not match !!! \n");
fi;
if gfs[1]<>infinity or gfs[n]<>infinity then
  Error("First and last elements of <gfs> must be infinity !!! \n");
fi;
if not 0 in gfs then
  Error("<gfs> must contain at least one zero element !!! \n");
fi;
for i in [ 1 .. n-1 ] do
  if NumeratorOfGFSElement(gfs,i+1) * DenominatorOfGFSElement(gfs,i) -
     NumeratorOfGFSElement(gfs,i) * DenominatorOfGFSElement(gfs,i+1) <> 1 then
    Error("a", i+1, "*b", i, " - a", i, "*b", i+1, " <> 1 !!! \n");
  fi;     
od;
if ForAny( Collected(labels), t -> IsInt(t[1]) and t[2]<>2 ) then
  Error("<labels> are not properly paired !!! \n");
fi;
return true;
end);


#############################################################################
#
# MatrixByEvenInterval( gfs, i )
#
InstallGlobalFunction( "MatrixByEvenInterval",
function(gfs,i)
local ai, bi, ai1, bi1;
ai  := NumeratorOfGFSElement(gfs,i);
bi  := DenominatorOfGFSElement(gfs,i);
ai1 := NumeratorOfGFSElement(gfs,i+1);
bi1 := DenominatorOfGFSElement(gfs,i+1);
return [ [ ai1*bi1 + ai*bi, -ai^2 - ai1^2 ], 
         [    bi^2 + bi1^2, -ai1*bi1 - ai*bi ] ];
end);


#############################################################################
#
# MatrixByOddInterval( gfs, i ) 
#
InstallGlobalFunction( "MatrixByOddInterval",
function(gfs,j)
local aj, bj, aj1, bj1;
aj  := NumeratorOfGFSElement(gfs,j);
bj  := DenominatorOfGFSElement(gfs,j);
aj1 := NumeratorOfGFSElement(gfs,j+1);
bj1 := DenominatorOfGFSElement(gfs,j+1);
return [ [ aj1*bj1 + aj*bj1 + aj*bj, -aj^2 - aj*aj1 - aj1^2 ], 
         [    bj^2 + bj*bj1 + bj1^2, -aj1*bj1 - aj1*bj - aj*bj ] ];
end);


#############################################################################
#
# MatrixByFreePairOfIntervals( gfs, k, kp )
#
InstallGlobalFunction( "MatrixByFreePairOfIntervals",
function(gfs,k,kp)
local ak, bk, ak1, bk1, akp, bkp, akp1, bkp1;
ak   := NumeratorOfGFSElement(gfs,k);
bk   := DenominatorOfGFSElement(gfs,k);
ak1  := NumeratorOfGFSElement(gfs,k+1);
bk1  := DenominatorOfGFSElement(gfs,k+1);
akp  := NumeratorOfGFSElement(gfs,kp);
bkp  := DenominatorOfGFSElement(gfs,kp);
akp1 := NumeratorOfGFSElement(gfs,kp+1);
bkp1 := DenominatorOfGFSElement(gfs,kp+1);
return [ [ akp1*bk1 + akp*bk, -akp*ak - akp1*ak1 ], 
         [ bkp*bk + bkp1*bk1, -ak1*bkp1 - ak*bkp ] ];
end);


#############################################################################
##
#E
##
