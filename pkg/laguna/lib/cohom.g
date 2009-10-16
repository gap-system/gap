#############################################################################
##  
#W  cohom.g                  The LAGUNA package                  Viktor Bovdi
#W                                                        Alexander Konovalov
#W                                                         Richard Rossmanith
#W                                                            Csaba Schneider
##
#H  $Id: cohom.g,v 1.1 2005/05/28 19:38:37 alexk Exp $
##
#############################################################################


#############################################################################
##
##  CohomologyDimensions( H )
##
##  Let H be a p-group. Then dimensions of the 1st and 2nd cohomology 
##  groups of H are determined by the group algebra FH. 
##  This function computes these dimensions using the Cohomolo package
##  by Derek Holt.
##  Note that since the dimension of the 1st cohomology group is the 
##  minimal number of generators of H, this dimension will not give any
##  new information in case when the isomorphism type of the factorgroup 
##  H/FrattiniSubgroup(H) is already known (the latter is determined by 
##  [Dieckmann]). So actually we could compute only the second dimension,
##  and we use the first one only for double-checking.
CohomologyDimensions:=function( H )
local G, p, r, F, mats, r1;
if not IsPGroup( H ) then
  Error("H should be a p-group");
fi;
G := Image( IsomorphismPermGroup( H ) );
p := PrimePGroup( G );
r := CHR( G, p ); # this function is from the from Cohomolo package
CalcPres( r ); # this uses external routine provided by Cohomolo
F := r.fpgp;   # also from Cohomolo
#F:=Image(IsomorphismFpGroup( G )); # this is another option, 
                                    # mentioned in Cohomolo 
mats:=List( GeneratorsOfGroup( G ), g -> IdentityMat( 1, GF(p) ) );
r1 := CHR( G, p, F, mats ); # also from Cohomolo
return [ FirstCohomologyDimension(  r1 ), 
         SecondCohomologyDimension( r1 ) ];
end;


#############################################################################
##
##  CohomologyDimensionsTest( KG, KH )
##
##  The dimensions of the 1st and 2nd cohomology groups of G are determined 
##  by the group algebra FG. 
##  This function compares these dimension using the Cohomolo package
##  by Derek Holt.
##  Note that since the dimension of the 1st cohomology group is the 
##  minimal number of generators of G, this dimension will not give any
##  new information in case when the isomorphism type of the factorgroup 
##  G/FrattiniSubgroup(G) is already known (the latter is determined by 
##  [Dieckmann]). So actually we could compute only the second dimension,
##  and we use the first one only for double-checking.
CohomologyDimensionsTest := function( KG, KH )
return CohomologyDimensions( UnderlyingGroup( KG ) ) = 
       CohomologyDimensions( UnderlyingGroup( KH ) );
end;


#############################################################################
##
##  MIPSplittingByCohomDimensions( l, startno, forcedTest )
##
MIPSplittingByCohomDimensions := function( l, startno, forcedTest )
local fg,        # list of groups for the tested family l[i]
      i,         # the number of current family from the list l
      j,         # loop parameter
      output,    # output text file saved in the current directory
      size,      # the order of p-groups being tested
      curfamily, # the current family
      curpair,   # current pair from the current family
      n1, n2,    # numbers of the 1st and 2nd groups from 
                 # the current pair in the current family
      cd1, cd2;  # dimensions for 1st and 2nd groups;           
# determine the order of groups 
size:=l[1][1][1][1];
output:=OutputTextFile( 
        Concatenation( "split", String(size), ".txt" ),
        false);
PrintTo(output, "split", size, ":=[ \n");
for i in [ startno .. Length(l) ] do
  Print("***********************************************\n");
  Print("Testing ", i, "-th family ", l[i][1], " of ", Length(l), "\n");
  # now we will define the current family from the list l;
  # curfamily is a list of two elements, the first is a list of
  # identificators of groups from the current family, and the second
  # contains identificators of pairs with meta-information for each pair
  curfamily:=l[i]; 
  # now we make a list of groups from the current family
  fg := List( curfamily[1], j -> SmallGroup(j) );
  # the next cycle is over the pairs in the current family
  for curpair in curfamily[2] do
    Print("Comparing ", curpair[1][1], " and ",  curpair[1][2], " : \c");
    if (not curpair[2].splitted) or forcedTest then
      if not IsBound(curpair[2].splittedByCohom) then
        # we determine numbers of groups, corresponding to our
        # pair of groups in the list of groups fg for our family
        n1:=Position(curfamily[1], curpair[1][1]);
        n2:=Position(curfamily[1], curpair[1][2]);
        # now we actually check whether cohomology dimensions coincide
        # and save the result of the test
        cd1:= CohomologyDimensions( fg[n1] );
        cd2:= CohomologyDimensions( fg[n2] );
        curpair[2].splittedByCohom := cd1 <> cd2;
        if curpair[2].splittedByCohom then
           curpair[2].cohomDims:=[cd1,cd2];
        fi;
        # we check whether the pair was not already splitted by other
        # tools, and if so, we also switch the general result  
        if not curpair[2].splitted then
          curpair[2].splitted:=curpair[2].splittedByCohom;
        fi;
        Print(curpair[2].splittedByCohom," : ", cd1, ", ", cd2, "\n");
      else
        # skip the pair if it was already checked 
        Print(curpair[2].splittedByCohom," \n");
      fi;
    else 
      # skip the pair if it is splitted and the test is not forced
      Print(curpair[2].splitted," \n");
    fi;
  od; # end of the cycle over pairs
  AppendTo( output, "\n", "\043", " ", i, "\n");
  AppendTo( output, "[ "); 
  AppendTo( output, curfamily[1], ", \n", "[ ");
  for j in curfamily[2] do
    AppendTo( output, "[ ", j[1], ", \n", j[2], " ] , " , "\n");
  od;                   
  AppendTo( output, "], "); # closing the list of pairs
  AppendTo( output, "], \n"); # closing the current family
od;
AppendTo( output, "];"); # closing the whole list
# end of the cycle over families
CloseStream(output);
return l;
end;