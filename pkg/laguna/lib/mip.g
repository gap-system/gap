#############################################################################
##  
#W  laguna.g                 The LAGUNA package                  Viktor Bovdi
#W                                                        Alexander Konovalov
#W                                                         Richard Rossmanith
#W                                                            Csaba Schneider
##
#H  $Id: mip.g,v 1.1 2005/05/28 13:13:03 alexk Exp $
##
#############################################################################


#############################################################################
##
#A  RoggenkampParameterForNormalSubset( <G>, <S> )
##  
##  Let T = { g_1, ..., g_t} be the full system of representatives of 
##  conjugacy classes of the group G. Then the number
##  R(G) = \sum_{i=1,...,t} log_p ( | C_G( g_i ) / \Phi( C_G( g_i ) ) |) 
##  is determined by the group algebra KG. This parameter was introduced
##  by K.Roggenkamp and was described in [M.Wursthorn, Die modularen
##  Gruppenringe der gruppen der Ordnung 2^6, Diplomarbeit, Universitat 
##  Stuttgart, 1990; M.Wursthorn, Isomorphisms of modular group algebras: an
##  algorithm and its application to groups of order 2^6, J.Symbolic Comput.
##  15 (1993), no.2, 211-227]. The calculation of R(G) is implemented in
##  laguna.gi file, but sometimes it is also interesting to compute
##  R_{G}(S) = \sum_{i=1,...,s} log_p ( | C_G( h_i ) / \Phi( C_G( h_i ) ) |)
##  where h_i, ..., h_s is a set of representatives of the conjugacy classes
##  of G contained in the normal subset S of G. This can be done by the
##  function RoggenkampParameterForSubset
RoggenkampParameterForNormalSubset := function( G, S )
local s, cc, cl, t, reps, sum, g, c, pn;
if IsGroup(G) then
  if IsSubset(G,S) then
    if ForAll(G, g -> ForAll(S, s -> s^g in S) ) then
      cc:=ConjugacyClasses( G );
      reps:=[];
      for cl in cc do
        t:=Intersection(S,cl);
        if Size(t)>0 then
          Add( reps, Random(t) );
        fi;  
      od;
      sum := 0;
      for g in reps do
        c := Centralizer( G, g );
        pn := Size( c / FrattiniSubgroup(c) );
        sum := sum + LogInt( pn, PrimePGroup(G) );
      od;
      return sum;
    else
      Error("RoggenkampParameterForNormalSubset: S is not normal subset of G !"); 
    fi;
  else
    Error("RoggenkampParameterForNormalSubset: S is not a subset of G !"); 
  fi;   
else
  Error("RoggenkampParameterForNormalSubset: G is not a group !"); 
fi;  
end;


#############################################################################
##
##  MIPInvariantsRecord(G) 
##
MIPInvariantsRecord:=function(G) 
local r, d;
r:=rec( );
r.CenterSize                  := Size(Center(G));
r.CenterAbelianInvariants     := AbelianInvariants(Center(G));
r.DerivedFactorGroupSize      := Size(G/DerivedSubgroup(G));         
r.DerivedFactorGroupAbelianInvariants := AbelianInvariants(G);
d := LogInt( Size( DerivedSubgroup( G ) /
       FrattiniSubgroup( DerivedSubgroup( G ) ) ), PrimePGroup( G ) );
r.NrGeneratorsDerivedSubgroup := d;
if d=1 then
  r.NilpotencyClass           := Length(LowerCentralSeries(G))-1;
fi;  
r.FrattiniFactorGroupSize     := Size(G/FrattiniSubgroup(G));
r.FrattiniFactorGroupId       := IdGroup(G/FrattiniSubgroup(G));
r.Exponent                    := Exponent(G);
r.SandlingFactorGroupSize     := Size(SandlingFactorGroup(G));
r.SandlingFactorGroupId       := IdGroup(SandlingFactorGroup(G));
r.NrOfConjugacyClasses        := Length(ConjugacyClasses(G));            
r.NrOfConjugacyClassesPPowers := NumberOfConjugacyClassesPPowers(G);
r.ClassSumPowers              := ClassSumNumbers(G);
r.JenningsSeriesLength        := Length(JenningsSeries(G));       
r.JenningsFactors             := JenningsFactors(G);  
r.QuillenSeries               := QuillenSeries(G);
r.RoggenkampParameter         := RoggenkampParameter(G);   
return r;
end;


#############################################################################
##
##  PrintMIPInvariants(G)
##
##  Printing of the set of invariants for a given group G
PrintMIPInvariants:=function(G)
local d;
Print("Z(G) order             : ", Size(Center(G)), "\n");
Print("Z(G) abel.invariants   : ", AbelianInvariants(Center(G)), "\n");
Print("G/G' order             : ", Size(G/DerivedSubgroup(G)), "\n");
Print("G/G' abel.invariants   : ", AbelianInvariants(G), "\n");
d := LogInt( Size( DerivedSubgroup(G) /
       FrattiniSubgroup( DerivedSubgroup( G ) ) ), PrimePGroup( G ) );
Print("d(G')                  : ", d, "\n");
if d=1 then
  Print("cl(G)                  : ", NilpotencyClassOfGroup(G), "\n");
fi;
Print("G/F(G) order           : ", Size(G/FrattiniSubgroup(G)), "\n");
Print("G/F(G) ID              : ", IdGroup(G/FrattiniSubgroup(G)), "\n");
Print("Exponent(G)            : ", Exponent(G), "\n");
Print("Sandling(G) order      : ", Size(SandlingFactorGroup(G)), "\n");
Print("Sandling(G) ID         : ", IdGroup(SandlingFactorGroup(G)), "\n");
Print("NrConjugacyClasses(G)  : ", Length(ConjugacyClasses(G)), "\n");
Print("Con.classes of g^(p^n) : ", NumberOfConjugacyClassesPPowers(G), "\n");
Print("ClassSumNumbers(G)     : ", ClassSumNumbers(G), "\n");
Print("Jennings length        : ", Length(JenningsSeries(G)), "\n");
Print("Jennings factors       : ", "\n", 
      "   M_i/M_i+1           : ", JenningsFactors(G)[1] , "\n", 
      "   M_i/M_i+2           : ", JenningsFactors(G)[2] , "\n", 
      "   M_i/M_2i+1          : ", JenningsFactors(G)[3] , "\n");
Print("Quillen series         : ", QuillenSeries(G), "\n");
Print("Roggenkamp parameter   : ", RoggenkampParameter(G), "\n");
return;
end;


#############################################################################
##
##  PrintMIPInvariantsTable(l, filename)
##
## Service function for printing the table of invariants for all groups from 
## a given list l to the text file with a given name, which than can be 
## easily converted to the speadsheet format.
PrintMIPInvariantsTable:=function(l, filename)
local G, d, output;
output := OutputTextFile( filename, false );
SizeScreen( [ 256, ] );
PrintTo( output, 
  "ID:|Z(G)|:Z(G):|G/G'|:G/G':d(G'):cl(G):|G/F(G)|:G/F(G) ID:Exp(G):|Sand(G)|:Sand(G) ID:Con.cl:Con.cl p^n:ClassSums:Jennings:Quillen:Roggenkamp \n");
for G in l do
AppendTo(output, IdGroup(G));  
AppendTo(output, " : ", Size(Center(G)));
AppendTo(output, " : ", AbelianInvariants(Center(G)));
AppendTo(output, " : ", Size(G/DerivedSubgroup(G)));
AppendTo(output, " : ", AbelianInvariants(G));
d := LogInt( Size(DerivedSubgroup(G) /
       FrattiniSubgroup( DerivedSubgroup( G ) ) ), PrimePGroup( G ) );
AppendTo(output, " : ", d );
if d=1 then
  AppendTo(output, " : ", NilpotencyClassOfGroup(G));
else
  AppendTo(output, " : ");
fi;
AppendTo(output, " : ", Size(G/FrattiniSubgroup(G)));
AppendTo(output, " : ", IdGroup(G/FrattiniSubgroup(G)));
AppendTo(output, " : ", Exponent(G));
AppendTo(output, " : ", Size(SandlingFactorGroup(G)));
AppendTo(output, " : ", IdGroup(SandlingFactorGroup(G)));
AppendTo(output, " : ", Length(ConjugacyClasses(G)));
AppendTo(output, " : ", NumberOfConjugacyClassesPPowers(G));
AppendTo(output, " : ", ClassSumNumbers(G));
AppendTo(output, " : ", Length(JenningsSeries(G)));
AppendTo(output, " : ", QuillenSeries(G));
AppendTo(output, " : ", RoggenkampParameter(G));
AppendTo(output, "\n");
od;
CloseStream(output);
SizeScreen( [ 78, ] );
end;


#############################################################################
##
##  MIPInvariantsLibrary(n) 
##
MIPInvariantsLibrary:=function(n) 
local k, output, i, G;  
k:=NrSmallGroups(n);
Print("Starting library generation for ", k, " groups of order ", n, "\n"); 
output := OutputTextFile( Concatenation("lib",String(n),".g"), false );
PrintTo( output, "lib", String(n), " := [ ", "\n");
for i in [ 1 .. k ] do   
  G:=SmallGroup(n,i);   
  if not IsAbelian(G) then
    Print("Group ", i, " of ", k, "\n");
    AppendTo(output, "[ ", [n,i], ", \n",
                     MIPInvariantsRecord(G), " ],", "\n");            
  fi;  
od; 
AppendTo(output, "];");
return;
end;


#############################################################################
##
##  MIPInvariantsLibraryClassification( invlib, mode )
##
##  classification of groups from the invariants library
##  mode = 1 : returns a list of all classes, including 
##             the trivial (one-element) ones 
##  mode = 2 : returns only non-splitted groups, i.e.
##             a list of classes with more than one element
##  mode = 3 : returns the same as 2, and, if there are non-splitted
##             groups, saves result to a text file with the name of 
##             the form "splitN.g", where N is the group order for 
##             the further investigation with MIP splitting tools 
MIPInvariantsLibraryClassification := function( invlib, mode )
local labels, class, classes, i, j, l, ns, output, n;
if not mode in [1,2,3] then
  Print("ATTENTION : The second argument should be 1, 2, or 3: \n");
  Print("  1 - return all groups (long list) \n");
  Print("  2 - return only non-splitted groups (shorter list) \n");
  Print("  3 - do (2) and save results to the file splitN.g \n");
  return;
fi;
Print("Starting classification ... \n");
labels := List( [ 1 .. Length(invlib) ], x -> 0);
classes := [];
for i in [ 1 .. Length(invlib)] do
  class:=[];
  if labels[i] = 0 then
    class:=[ invlib[i][1] ];
    Print(class[1], " \c");
    labels[i]:=1;
    for j in [ i+1 .. Length(invlib)] do
      if invlib[i][2] = invlib[j][2] then
        Add( class, invlib[j][1] );
        labels[j] := 1;
      fi;
    od;
    Add( classes, class );
    if Length(class) = 1 then
      Print(" - splitted! \n");
    else
      Print(" - ", Length(class)-1, " more groups ... \n");
    fi;  
  fi;
od;
if mode = 1 then
  return classes;
else
  ns:=Filtered(classes, l -> Length(l)>1 );
  if Length(ns) > 0 then
    Print("Returning ", Length(ns), " non-splitted families of groups \n");
    if mode=3 then
    n:=ns[1][1][1]; # this is the order of groups
      Print("Generating the file split", String(n), ".g ... \c");
      output := OutputTextFile( 
                Concatenation("split",String(n),".g"), false );
      PrintTo( output, "split", String(n), " := [ ", "\n");
      for i in [ 1 .. Length(ns) ] do   
        AppendTo( output, "\n", "\043", " ", i, "\n");
        AppendTo( output, "[ "); 
        AppendTo( output, ns[i], ", \n", "[ ");

        for j in Combinations( ns[i], 2) do
        AppendTo( output, "[ ", j, ", \n",
         rec( splitted          := false,
              splittedByKerSize := false,
              kerSizeResult     := fail,
              kerSizeLimit      := 0 ), " ] , " , "\n");
        od;                   
        AppendTo( output, "], "); # closing the list of pairs
        AppendTo( output, "], \n"); # closing the current family
      od;
      AppendTo( output, "];"); # closing the whole list
      Print("OK \n");
    fi;
  else
    Print("All groups are splitted! Empty list returned ");  
    if mode=3 then
      Print("without file generation \n");
        else
      Print("\n");  
    fi;
  fi;
  return ns;
fi;  
end;


#############################################################################
##
## MIPSplittingReport( l )
##
MIPSplittingReport:=function(l)
local size,       # the order of groups analyzed in the report
      notsplitted,# number of not splitted groups (after groups invariants)
      nfams,      # number of their families (after group invariants) 
      npairs,     # number of their pairs to check (after group invariants)
      remgroups,  # number of groups not splitted after splitting tests
      nfamssplit, # number of completely splitted families
      npairssplit,# number of splitted pairs of groups
      failed,     # a list of failed pairs from the current family
      failednums, # a list of numbers of groups from failed pairs
      limits,     # a set of limits appeared in failed pairs
      x, y, z;    # internal loop parameters
size := l[1][1][1][1];
Print("============================================== \n");
Print("MIP splitting report for groups of order ", size, "\n");
Print("---------------------------------------------- \n");
Print("Number of groups of order ", size, " : ", NrSmallGroups(size), "\n");
notsplitted := Sum( List( l, x -> Length (x[1] ) ) );
Print("Splitted by group invariants : ", NrSmallGroups(size)-notsplitted, "\n");
Print("Remaining groups             : ", notsplitted, "\n");
Print("---------------------------------------------- \n");
nfams:=Length(l);
Print("Number of families           : ", nfams, "\n" );
Print("Size/number of families      : ", 
       Collected(List(l, x -> Length(x[1]))), "\n");
npairs:=Sum(List(l, x -> NrCombinations([1..Length(x[1])],2)));
Print("Number of pairs to check     : ", npairs, "\n" );
Print("---------------------------------------------- \n");
# computing the list of numbers of remaining groups
remgroups:=[];
for x in l do
  # get those pairs where were not splitted
  failed:= Filtered(x[2], y -> not y[2].splitted);
  # get the set numbers of non-splitted groups in a given family
  failednums:= Set(Flat(List(failed, y -> List(y[1], z -> z[2]))));
  UniteSet(remgroups, failednums);
od;
remgroups:=Length(remgroups);
Print("Number of splitted groups    : ", notsplitted-remgroups, "\n");
nfamssplit := Length( Filtered( l, x -> 
              ForAll( x[2], y -> y[2].splitted ) ) );
Print("Number of splitted families  : ", nfamssplit, "\n");
npairssplit := Sum( List( l, x -> 
               Length( Filtered( x[2], y -> y[2].splitted ) ) ) );
Print("Number of splitted pairs     : ", npairssplit, "\n");
Print("---------------------------------------------- \n");
Print("Remaining groups to check    : ", remgroups, "\n");
Print("Remaining families to check  : ", nfams-nfamssplit, "\n");
Print("Remaining pairs to check     : ", npairs-npairssplit, "\n");
Print("---------------------------------------------- \n");
limits:=[];
for x in l do
  failed:=Filtered(x[2], y -> y[2].kerSizeResult = fail );
  UniteSet(limits, Set(List(failed, y -> y[2].kerSizeLimit)));
od;
if Length(limits)>0 then
  Print("Minimal upper limit          : ", Minimum(limits), "\n" );
  Print("Maximal upper limit          : ", Maximum(limits), "\n" );
fi;
Print("============================================== \n");
end;


#############################################################################
##
##  KernelSizeTest( FG, FH )
##
##  Compares the sizes of the kernel of the following mappings, depending on
##  three parameters [n,m,k]: Phi_nmk from I^n/I^n+m to I^(np^k)/I^(np^k+m),
##  which is induced by turning an element x from I^n to ist p^k-th power
##  and maps  x + I^n+m  to  x^(p^k) + I^(np^k+m). The kernel size of such
##  mapping is an invariant of KG [see M.Wursthorn, Die modularen 
##  Gruppenringe der gruppen der Ordnung 2^6, Diplomarbeit, Universitat 
##  Stuttgart, 1990; M.Wursthorn, Isomorphisms of modular group algebras: an
##  algorithm and its application to groups of order 2^6, J.Symbolic Comput.
##  15 (1993), no.2, 211-227]. 
KernelSizeTest:=function(FG,FH)
local s, p, m, n, k, r1, r2, t, tmp, i;
s:=AugmentationIdealNilpotencyIndex(FG);
p:=Characteristic(UnderlyingField(FG));
if s <> AugmentationIdealNilpotencyIndex(FH) then
  Error("Different values of AugmentationIdealNilpotencyIndex");
fi;
for n in [1..s-1] do
  for m in [1..s-n] do
    for k in [1..LogInt(s,p)] do
      if Position(ComputedKernelSizes(FG),[n,m,k])=fail then
        # if it is calculated for the first time
        r1:=KernelSize(FG,[n,m,k]);
      elif KernelSize(FG,[n,m,k])=fail then
        # if previous attempt of calculation failed
        t:=Position(ComputedKernelSizes(FG),[n,m,k]);
        Unbind(ComputedKernelSizes(FG)[t]);
        Unbind(ComputedKernelSizes(FG)[t+1]);
        tmp:=Compacted(ShallowCopy(ComputedKernelSizes(FG)));
        for i in [1..Length(tmp)] do
          ComputedKernelSizes(FG)[i]:=tmp[i];
        od;
        Unbind(ComputedKernelSizes(FG)[Length(tmp)+1]);
        Unbind(ComputedKernelSizes(FG)[Length(tmp)+2]);
        r1:=KernelSize(FG,[n,m,k]);
      else # if it was already successfully calculated  
        r1:=KernelSize(FG,[n,m,k]);
      fi;
      if Position(ComputedKernelSizes(FH),[n,m,k])=fail then
        # if it is calculated for the first time
        r2:=KernelSize(FH,[n,m,k]);
      elif KernelSize(FH,[n,m,k])=fail then
        # if previous attempt of calculation failed
        t:=Position(ComputedKernelSizes(FH),[n,m,k]);
        Unbind(ComputedKernelSizes(FH)[t]);
        Unbind(ComputedKernelSizes(FH)[t+1]);
        tmp:=Compacted(ShallowCopy(ComputedKernelSizes(FH)));
        for i in [1..Length(tmp)] do
          ComputedKernelSizes(FH)[i]:=tmp[i];
        od;
        Unbind(ComputedKernelSizes(FH)[Length(tmp)+1]);
        Unbind(ComputedKernelSizes(FH)[Length(tmp)+2]);
        r2:=KernelSize(FH,[n,m,k]);
      else # if it was already successfully calculated  
        r2:=KernelSize(FH,[n,m,k]);
      fi;
      Info(LAGInfo, 2, "KernelSizes[", n,",", m,",",k,"]={",r1,",",r2,"}");
      if r1<>r2 then
        return [[n,m,k],[r1,r2]];
      fi;
    od;
  od;
od;
return fail;
end;


#############################################################################
##
##  MIPSplittingByKernelSize( l, startno, forcedTest )
##
MIPSplittingByKernelSize := function( l, startno, forcedTest )
local fg,        # list of group algebras for the tested family l[i]
      i,         # the number of current family from the list l
      j,         # loop parameter
      output,    # output text file saved in the current directory
      primep,    # the prime p for corresponding p-groups
      size,      # the order of these groups
      curfamily, # the current family
      curpair,   # current pair from the current family
      n1, n2;    # numbers of the 1st and 2nd groups from 
                 # the current pair in the current family
# determine the order of groups and a prime p 
size:=l[1][1][1][1];
primep:=Factors(size)[1];
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
  # now we will make a list of group algebras of groups from the 
  # current family (we will remember kernel sizes for each group 
  # from the family in attributes to avoid repeating their computations)
  fg := List( curfamily[1], j -> GroupRing( GF(primep), SmallGroup(j) ) );
  # the next cycle is over the pairs in the current family
  for curpair in curfamily[2] do
    Print("Comparing ", curpair[1][1], " and ",  curpair[1][2], " : \c");
    if (not curpair[2].splitted) or forcedTest then
      if not curpair[2].splittedByKerSize then
        if curpair[2].kerSizeLimit < 
           LAGUNA_UPPER_KERNEL_SIZE_LIMIT then  
          # we determine numbers of group algebras, corresponding to our
          # pair of groups in the list of group algebras fg for our family
          n1:=Position(curfamily[1], curpair[1][1]);
          n2:=Position(curfamily[1], curpair[1][2]);
          # now we actually check kernel sizes, 
          # save the result of the test
          curpair[2].kerSizeResult:=KernelSizeTest( fg[n1], fg[n2] );
          # and also remember the upper limit
          curpair[2].kerSizeLimit:=LAGUNA_UPPER_KERNEL_SIZE_LIMIT;
          # if the result is not fail - this means that we split the pair!
          curpair[2].splittedByKerSize:= 
            not (curpair[2].kerSizeResult=fail);
          # we check whether the pair was not already splitted by other
          # tools, and if so, we also switch the general result  
          if not curpair[2].splitted then
            curpair[2].splitted:=curpair[2].splittedByKerSize;
          fi;
          Print(curpair[2].kerSizeResult," (with new limit) \n");
        else
          # skip the pair if it was already checked with this limit
          Print(curpair[2].kerSizeResult," (with same limit) \n");
        fi;
      fi;
    else 
      # skip the pair if it is splitted and the test is not forced
      Print(curpair[2].splitted," (already splitted) \n");
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


#############################################################################
##
##  JenningsLieAlgebraTest( KG, KH )
##
##  The JenningsLieAlgebra(G) is determined by the group algebra FG. 
##  This function constructs such restricted Lie algebras for 
##  underlying groups G and H, and then check their isomorphism using 
##  the Sophus package by Csaba Schneider. The function returns true 
##  if the restricted Lie algebras are isomorphic and false otherwise.
JenningsLieAlgebraTest:=function(KG,KH)
local G, H, LG, LH;
G  := UnderlyingGroup(KG);
H  := UnderlyingGroup(KH);
LG := JenningsLieAlgebra(G);
LH := JenningsLieAlgebra(H);
return AreIsomorphicNilpotentLieAlgebras( LG, LH );
end;


#############################################################################
##
##  MIPSplittingByJenningsLieAlgebra( l, startno, forcedTest )
##
MIPSplittingByJenningsLieAlgebra := function( l, startno, forcedTest )
local fg,        # list of Lie algebras for the tested family l[i]
      i,         # the number of current family from the list l
      j,         # loop parameter
      output,    # output text file saved in the current directory
      size,      # the order of p-groups being tested
      curfamily, # the current family
      curpair,   # current pair from the current family
      n1, n2;    # numbers of the 1st and 2nd groups from 
                 # the current pair in the current family
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
  # now we make a list of Lie algebras for groups from the current family
  fg := List( curfamily[1], j -> JenningsLieAlgebra( SmallGroup(j) ) );
  # the next cycle is over the pairs in the current family
  for curpair in curfamily[2] do
    Print("Comparing ", curpair[1][1], " and ",  curpair[1][2], " : \c");
    if (not curpair[2].splitted) or forcedTest then
      if not IsBound(curpair[2].splittedByLieAlg) then
        # we determine numbers of Lie algebras, corresponding to our
        # pair of groups in the list of group algebras fg for our family
        n1:=Position(curfamily[1], curpair[1][1]);
        n2:=Position(curfamily[1], curpair[1][2]);
        # now we actually check the isomorphism of Lie algebras
        # and save the result of the test
        curpair[2].splittedByLieAlg := 
                not AreIsomorphicNilpotentLieAlgebras( fg[n1], fg[n2] );
        # we check whether the pair was not already splitted by other
        # tools, and if so, we also switch the general result  
        if not curpair[2].splitted then
          curpair[2].splitted:=curpair[2].splittedByLieAlg;
        fi;
        Print(curpair[2].splittedByLieAlg," \n");
      else
        # skip the pair if it was already checked 
        Print(curpair[2].splittedByLieAlg," \n");
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


#############################################################################
##
#E
##