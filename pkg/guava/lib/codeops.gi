#############################################################################
##
#A  codeops.gi               GUAVA                              Reinald Baart
#A                                                        &Jasper Cramwinckel
#A                                                           &Erik Roijackers
##
##  All the code operations 
##
#H  @(#)$Id: codeops.gi,v 1.13 2004/12/20 21:26:06 gap Exp $
##
## changes 2003-2004 to MinimumDistance by David Joyner, Aron Foster
## bug in MinimumDistance corrected 9-29-2004 by wdj
## moved Decode and PermutationDecode to decoders.gi on 10-2004
## added HasGeneratorMat to GeneratorMat function 11-2-220
## another bug in MinimumDistance (discovered by Jason McGowan) 
##                             corrected 11-9-2004 by wdj
##
Revision.("guava/lib/codeops_gi") :=
    "@(#)$Id: codeops.gi,v 1.13 2004/12/20 21:26:06 gap Exp $";


#############################################################################
##
#F  WordLength( <C> ) . . . . . . . . . . . .  length of the codewords of <C>
##

InstallOtherMethod(WordLength, "generic code", true, [IsCode], 0,
function(C)
    return  WordLength(AsSSortedList(C)[1]) ;
end);

# This comment from GAP3 version. 
#In a linear code, the wordlength must always be included
#because the wordlength cannot always be calculated (NullCode)
#
#InstallOtherMethod(WordLength, "method for linear codes", true, 
#	[IsLinearCode], 0, 
#function(C)
#    if HasGeneratorMat(C) then
#        return Length( GeneratorMat(C)[1] );
#    else
#        return Length( CheckMat(C)[1] );
#    fi;
#end);


#############################################################################
##
#F  IsLinearCode( <C> ) . . . . . . . . . . . . . . . checks if <C> is linear
##
## If so, the record fields will be adjusted to the linear type
##

InstallMethod(IsLinearCode, "method for unrestricted codes", true, [IsCode], 0, 
function(C) 
    local gen, k, F, q;
    F := LeftActingDomain(C);
    q := Size(F);
    k := LogInt(Size(C),q);
    # first the trivial cases:
    if ( HasWeightDistribution(C) and 
         HasInnerDistribution(C)
         and (WeightDistribution(C) <> InnerDistribution(C)) )
       or ( q^k <> Size(C) )
       or (not NullWord(WordLength(C), F) in C) then
        return false; #is cool
    else
        gen:=BaseMat(VectorCodeword(AsSSortedList(C)));
        if Length(gen) <> k then
            return false; # is cool as ice
        else    
           	SetFilterObj(C, IsLinearCodeRep);  
			SetGeneratorMat(C, gen);
            if Length(gen) = 0 then  # special case for Nullcode 
				SetGeneratorsOfLeftModule(C, [AsSSortedList(C)[1]]); 
			else 
				SetGeneratorsOfLeftModule(C, AsList(Codeword(gen,F)));  
			fi; 
			if HasInnerDistribution(C) then
                SetWeightDistribution(C, InnerDistribution(C));
            fi;
            return true;
        fi;        
    fi;
end);

InstallOtherMethod(IsLinearCode, "method for generic object", true, 
	[IsObject], 0, 
function(obj) 
	return IsCode(obj) and IsLinearCode(obj); 
end); 


#############################################################################
##
#F  IsFinite( <C> ) . . . . . . . . . . . . . . . . . . . . . . . . . . . .  
##
##

InstallTrueMethod(IsFinite, IsCode); 


#############################################################################
##
#F  Dimension( <C> )  . . . . . . . . . . . . . . . . . . . . . . . . . . .  
##
##

InstallOtherMethod(Dimension, "method for unrestricted codes", true, 
	[IsCode], 0, 
function(C)
    if IsLinearCode(C) then
        return Dimension(C);
    else
        Error("dimension is only defined for linear codes");
    fi;
end);

InstallOtherMethod(Dimension, "method for cyclic codes", true, 
	[IsCyclicCode], 0, 
function(C) 
    if HasGeneratorPol(C) then
        return WordLength(C) - DegreeOfLaurentPolynomial(
														GeneratorPol(C));
    else
        return DegreeOfLaurentPolynomial(CheckPol(C));
    fi;
end);


#############################################################################
##
#F  Size( <C> ) . . . . . . . . . . .  returns the number of codewords of <C>
##
##

InstallMethod(Size, "method for unrestricted codes", true, [IsCode], 0, 
function(C)
    return Length(AsSSortedList(C));
end);


#############################################################################
##
#F  AsSSortedList( <C> ) . . . . . . . .  returns the list of codewords of <C>
##  AsList( <C> ) 
##
##  Codes created with ElementsCode must have AsSSortedList set.  
##  Linear codes use the vector space / FLM method to calculate.  
##  AsList defaults to AsSSortedList. 

InstallMethod(AsList, "method for unrestricted codes", true, [IsCode], 0, 
function(C) 
	return AsSSortedList(C); 
end);  


#############################################################################
##
#F  Redundancy( <C> ) . . . . . . . . . . . . . . . . . . . . . . . . . . .  
##
##

InstallMethod(Redundancy, "method for unrestricted codes", true, [IsCode], 0, 
function(C) 
    if IsLinearCode(C) then
        return Redundancy(C);
    else
        Error("redundancy is only defined for linear codes");
    fi;
end);

InstallMethod(Redundancy, "method for linear codes", true, [IsLinearCode], 0, 
function(C) 
    return WordLength(C) - Dimension(C);
end);


#############################################################################
##
#F  GeneratorMat(C) . . . . .  finds the generator matrix belonging to code C
##
##  Pre: C should contain a generator or check matrix
##

InstallMethod(GeneratorMat, "method for unrestricted code", true, [IsCode], 0, 
function(C) 
	if IsLinearCode(C) then 
		return GeneratorMat(C); 
	else 
        Error("non-linear codes don't have a generator matrix");
    fi;
end);

InstallMethod(GeneratorMat, "method for linear code", true, [IsLinearCode], 0, 
function(C) 
    local G;

    if HasGeneratorMat(C) then return C!.GeneratorMat; fi;
    if not HasCheckMat( C ) then
        return List( BasisVectors( Basis( C ) ), x -> VectorCodeword( x ) );
    fi;
    
    if CheckMat(C) = [] then  
        G := IdentityMat(Dimension(C), LeftActingDomain(C)); 
    elif IsInStandardForm(CheckMat(C), false) then      
        G := TransposedMat(Concatenation(IdentityMat(
                     Dimension(C), LeftActingDomain(C) ),
                     List(-CheckMat(C), x->x{[1..Dimension(C) ]})));
    else 
        G := NullspaceMat(TransposedMat(CheckMat(C)));
    fi;
    return ShallowCopy(G);
end);

InstallMethod(GeneratorMat, "method for cyclic code", true, [IsCyclicCode], 0, 
function(C) 
    local F, G, p, n, i, R, zero, coeffs;

    if HasGeneratorMat(C) then return C!.GeneratorMat; fi;
    #To be inspected:
    #if HasCheckMat(C) and IsInStandardForm(CheckMat(C), false) then
    #    G := TransposedMat(Concatenation(IdentityMat(Dimension(C), 
	#													LeftActingDomain(C)),
    #                 List(-CheckMat(C), x->x{[1..Dimension(C)]})));
    #else
        F := LeftActingDomain(C);
        p := GeneratorPol(C);
        n := WordLength(C);
		G := [];
        zero := Zero(F);  
		coeffs := CoefficientsOfLaurentPolynomial(p); 
		coeffs := ShiftedCoeffs(coeffs[1], coeffs[2]);  
        for i in [1..Dimension(C)] do
            R := NullVector(i-1, F);
            Append(R, coeffs);
            Append(R, NullVector(n-Length(R), F));
            G[i] := R;
        od;
    #fi;
    return ShallowCopy(G);
end);

#############################################################################
##
#F  CheckMat( <C> ) . . . . . . .  finds the check matrix belonging to code C
##
##  Pre: <C> should be a linear code
##

InstallMethod(CheckMat, "method for unrestricted codes", true, [IsCode], 0, 
function(C) 
    if IsLinearCode(C) then
        return CheckMat(C);
    else
        Error("non-linear codes don't have a check matrix");
    fi;
end);

InstallMethod(CheckMat, "method for linear code", true, [IsLinearCode], 0, 
function(C) 
    local H;
    if GeneratorMat(C) = [] then
        H := IdentityMat(WordLength(C), LeftActingDomain(C));
    elif IsInStandardForm(GeneratorMat(C), true) then
        H := TransposedMat(Concatenation(List(-GeneratorMat(C),
                     x-> x{[Dimension(C)+1 .. WordLength(C) ]}),
                     IdentityMat(Redundancy(C), LeftActingDomain(C) )));
    else
        H := NullspaceMat(TransposedMat(GeneratorMat(C)));
    fi;
    return ShallowCopy(H);
end);

InstallMethod(CheckMat, "method for cyclic code", true, [IsCyclicCode], 0, 
function(C) 
    local F, H, p, n, i, R, zero, coeffs;
    #if HasGeneratorMat(C) and IsInStandardForm(GeneratorMat(C), true) then
    #    H := TransposedMat(Concatenation(List(-GeneratorMat(C), x-> 
    #                 x{[Dimension(C)+1..WordLength(C)]}),
    #                 IdentityMat(Redundancy(C), LeftActingDomain(C))));
    #else
        F := LeftActingDomain(C);
        H := [];
        p := CheckPol(C);
        p := Indeterminate(F)^Dimension(C)*Value(p,Indeterminate(F)^-1);
        n := WordLength(C);
        zero := Zero(F); 
		coeffs := CoefficientsOfLaurentPolynomial(p); 
		coeffs := ShiftedCoeffs(coeffs[1], coeffs[2]); 
        for i in [1..Redundancy(C)] do
            R := NullVector(i-1, F);
            Append(R, coeffs);
            Append(R, NullVector(n-Length(R), F));
            H[i] := R;
        od;
    #fi;
    return ShallowCopy(H);
end);

#############################################################################
##
#F  IsCyclicCode( <C> ) . . . . . . . . . . . . . . . . . . . . . . . . . .  
##

InstallOtherMethod(IsCyclicCode, "method for unrestricted codes", 
	true, [IsCode], 0, 
function(C) 
    if IsLinearCode(C) then
        return IsCyclicCode(C);
    else
        return false;
    fi;
end);

InstallMethod(IsCyclicCode, "method for linear codes", true, [IsLinearCode], 0, 
function(C) 
    local C1, F, L, Gp;
    F := LeftActingDomain(C);
    L := List(GeneratorMat(C), 
	        g->LaurentPolynomialByCoefficients(
		    ElementsFamily(FamilyObj(F)),One(F)*g, 0 ));
    Add(L, Indeterminate(F)^WordLength(C) - One(F));
    Gp := Gcd(L);
    if Redundancy(C) = DegreeOfLaurentPolynomial(Gp) then
        SetGeneratorPol(C, Gp);
        return true;
    else
        return false; #so the code is not cyclic
    fi;
end);

InstallOtherMethod(IsCyclicCode, "method for generic objects", true, 
	[IsObject], 0, 
function(obj) 
	return IsCode(obj) and IsLinearCode(obj) and IsCyclicCode(obj); 
end); 


#############################################################################
##
#F  GeneratorPol( <C> ) . . . . . . . . returns the generator polynomial of C
##
##  Pre: C must have a generator or check polynomial
##

InstallMethod(GeneratorPol, "method for unrestricted codes", true, [IsCode], 0, 
function(C) 
    if IsCyclicCode(C) then
        return GeneratorPol(C);
    else
        Error("generator polynomial is only defined for cyclic codes");
    fi;
end);

InstallMethod(GeneratorPol, "method for cyclic codes", true, [IsCyclicCode], 0, 
function(C) 
    local F, n;
    F := LeftActingDomain(C);
    n := WordLength(C); 
	return EuclideanQuotient(One(F)*(Indeterminate(F)^n-1),CheckPol(C));
end);


#############################################################################
##
#F  CheckPol( <C> ) . . . . . . . .  returns the parity check polynomial of C
##
##  Pre: C must have a generator or check polynomial 
##

InstallMethod(CheckPol, "method for unrestricted codes", true, [IsCode], 0, 
function(C) 
    if IsCyclicCode(C) then
        return CheckPol(C);
    else
        Error("generator polynomial is only defined for cyclic codes");
    fi;
end);

InstallMethod(CheckPol, "method for cyclic codes", true, [IsCyclicCode], 0, 
function(C) 
    local F, n;
    F := LeftActingDomain(C);
    n := WordLength(C);
    return EuclideanQuotient((Indeterminate(F)^n-One(F)),GeneratorPol(C));
end);


#############################################################################
##
#F  MinimumDistance( <C> [, <w>] )  . . . .  determines the minimum distance 
##
##  MinimumDistance( <C> ) determines the minimum distance of <C>
##  MinimumDistance( <C>, <w> ) determines the minimum distance to a word <w>
##

InstallMethod(MinimumDistance, "attribute method for unrestricted codes", true, 
	[IsCode], 0, 
function(C) 
	local W, El, F, n, zero, d, DD, w;  
	if IsBound(C!.upperBoundMinimumDistance) and 
	   IsBound(C!.lowerBoundMinimumDistance) and 
	   C!.upperBoundMinimumDistance = C!.lowerBoundMinimumDistance then 
		return C!.lowerBoundMinimumDistance;   
	elif IsCyclicCode(C) or IsLinearCode(C) then 
		return MinimumDistance(C); 
	fi;
	W := VectorCodeword(AsSSortedList(C));
	El := W;  # so not a copy!
    F := LeftActingDomain(C);
    n := WordLength(C);
    zero := Zero(F);  
    d := n;
    DD := NullVector(n+1);
    for w in W do
        DD := DD + DistancesDistributionVecFFEsVecFFE(El, w);
    od;
    d := PositionProperty([2..n+1], i->DD[i] <> 0);
    C!.lowerBoundMinimumDistance := d; 
	C!.upperBoundMinimumDistance := d; 
	return d;
end);

InstallMethod(MinimumDistance, "attribute method for linear codes", true, 
	[IsLinearCode], 0, 
function(C) 

	local HasZeroRow,Gp, Gpt, Gt, L, k, i, j, dimMat, Grstr, J, d1, arrayd1, Combo,
	rows, row, rowSum, G, F, zero, AClosestVec, s, p, num, n;
	if IsBound(C!.upperBoundMinimumDistance) and 
	   IsBound(C!.lowerBoundMinimumDistance) and 
	   C!.upperBoundMinimumDistance = C!.lowerBoundMinimumDistance then 
		return C!.lowerBoundMinimumDistance;   
        fi;
	G := GeneratorMat(C);

	if (IsInStandardForm(G)=false) then
		G := ShallowCopy(G);
		PutStandardForm(G);		
	fi;
	F:=LeftActingDomain(C);
	dimMat := DimensionsMat(G);
	k:=dimMat[1]; 
	n := dimMat[2];
if n=k then 
    C!.lowerBoundMinimumDistance := 1; 
    C!.upperBoundMinimumDistance := 1; 
    return 1; 
fi; #  added 11-2004
	Gp := ShallowCopy(G);

##Use gaussian elimination on the new matrix
#	TriangulizeMat(Gp); ## redundant - already in standard form

##generate the restricted code of Z from Gp=(I|Z)
	Gpt := TransposedMat(Gp);
	Grstr := NullMat(n-k,k);
	for i in [k+1..n] do
		Grstr[i-k] := Gpt[i];
	od;
	Grstr := TransposedMat(Grstr);

HasZeroRow:=function(M,F)
 local z,i;
 z:=Zero(F)*M[1];
 for i in [1..Length(M)] do
  if M[i]=z then return true; fi;
 od;
 return false;
end;

if n>k and HasZeroRow(Grstr,F)  then 
    C!.lowerBoundMinimumDistance := 1; 
    C!.upperBoundMinimumDistance := 1; 
    return 1; 
fi; #  added 11-2004
	zero := Zero(F)*Grstr[1];
	if Grstr=Zero(F)*Grstr then 
          C!.lowerBoundMinimumDistance := 1; 
          C!.upperBoundMinimumDistance := 1; 
          return 1; 
        fi; # bugfix added 9-2004

	J := []; #col number of codewords to compute the length of
	
	for i in [1..k] do
	AClosestVec:=AClosestVectorCombinationsMatFFEVecFFE(Grstr, F, zero, i, 1);
	if WeightVecFFE(AClosestVec)>=0 then
		Add(J, [AClosestVec,i]);
	fi;
	od;

	d1:=dimMat[2];
	for rows in J do
	    d1:=Minimum(WeightVecFFE(rows[1])+rows[2],d1);
	od;
    C!.lowerBoundMinimumDistance := d1; 
    C!.upperBoundMinimumDistance := d1; 
return(d1);
end);
    
InstallMethod(MinimumDistance, "attribute method for cyclic code", true, 
	[IsCyclicCode], 0, 
function(C) 
	local md; 
	if IsBound(C!.lowerBoundMinimumDistance) and 
	   IsBound(C!.upperBoundMinimumDistance) and 
	   C!.lowerBoundMinimumDistance = C!.upperBoundMinimumDistance then 
		return C!.lowerBoundMinimumDistance; 
	else 
		md := MinimumDistance( PuncturedCode( C ) ) + 1;
		C!.lowerBoundMinimumDistance := md; 
		C!.upperBoundMinimumDistance := md; 
		return md; 
	fi; 
end);

## Should be a better way to set up the Other methods, given 
## how much overlap there is with attribute methods.  For now, though, 
## this works.  
InstallOtherMethod(MinimumDistance, "unrestricted code, word", true, 
	[IsCode, IsCodeword], 0, 
function(C, word) 
    local W, El, F, n, zero, d, w, DD;
    if IsLinearCode(C) then
        return MinimumDistance(C, word); 
    fi; 
	if word in C then
		return 0;
	fi;
	W := [VectorCodeword(Codeword(word, C))];
	El := VectorCodeword(AsSSortedList(C));
    F := LeftActingDomain(C);  
    n := WordLength(C);
    zero := Zero(F); 
    d := n;
    DD := NullVector(n+1);
    for w in W do
        DD := DD + DistancesDistributionVecFFEsVecFFE(El, w);
    od;
    d := PositionProperty([2..n+1], i->DD[i] <> 0);
    return d;
end);

InstallOtherMethod(MinimumDistance, "linear code, word", true, 
	[IsLinearCode, IsCodeword], 0, 
function(C, word)  
    local Mat, n, k, zero, UP, G, W, multiple, weight,
          ThisGIsDone,  #is true as the latest matrix is converted
          Icount,       #number of corrected generatormatrices
          i,            #first rownumber which could be added to I
          l,            #columnnumber which could be used
          IdentityColumns,
          j, CurW, UMD, w, q, tmp, F;
    
    k := Dimension(C);
    n := WordLength(C);
    zero := Zero(LeftActingDomain(C)); 
    q := Size(LeftActingDomain(C)); 
	F := LeftActingDomain(C); 
	w := VectorCodeword(word);
	if w in C then
		return 0;
	elif k = 0 then
		return Weight(Codeword(w));
	elif HasSyndromeTable(C) then
		j := 1;
		w := VectorCodeword( Syndrome(C, w) );
		for i in [ 0 .. k - 1 ] do
			if w[ k - i ] <> zero then
				j := j + q^i * ( LogFFE( w[ k - i ] ) + 1 );
			fi;
		od;
		return Weight(SyndromeTable(C)[j][1]);
	fi;
	UMD := Weight(Codeword(w));
			   #this must be so, because the kernel function
			   #can not find this distance
	CurW := 0; 
    Mat := ShallowCopy(GeneratorMat(C));
    i := 1;
##  The next lines could go etwas faster for cyclic codes by weighting the
##  generator polynomial, but a copy of this function must be made in the
##  CycCodeOps, which makes it harder to make changes. 
    if q = 2 then
		multiple := 2;
        repeat
            weight := 0;
            for j in Mat[i] do
                if not j = zero then
                    weight := weight + 1;
                fi;
            od;
            multiple := Gcd( multiple, weight );
            i := i + 1;
        until multiple = 1 or i > k;
    else
        multiple := 1;
    fi;
# we now know that the weight of all the elements are a multiple of multiple
    UP := List([1..n], i->false);   #which columns are already used
    G := [];
    W := [];
    Icount := 0;
    
    repeat
        ThisGIsDone := false;
        i := 1;                   # i is the row of the identitymatrix it
        l := 1;                   # is trying to make
        IdentityColumns := [];
        while not ThisGIsDone and (l <= n) do
            if not UP[l] then     # try this column if it is not already used
                j := i;      
                while (j <= k) and (Mat[j][l] = zero) do 
                    j := j + 1;   # go down in the matrix until a nonzero
                od;               # entry is found
                if j <= k then
                    if j > i then
                        tmp := Mat[i];
                        Mat[i] := Mat[j];
                        Mat[j] := tmp;
                    fi;
                    Mat[i] := Mat[i]/Mat[i][l];
                    for j in Concatenation([1..i-1], [i+1..k]) do
                        if Mat[j][l] <> zero then
                            Mat[j] := Mat[j] - Mat[j][l]*Mat[i];
                        fi;
                    od;
                    UP[l] := true;
                    Add(IdentityColumns, l);
                    i := i + 1;
                    ThisGIsDone := ( i > k );
                fi;
            fi; 
            l := l + 1;
        od;
        if ThisGIsDone then
            Icount := Icount + 1;
            Add( G, Mat{[1..k]}{Difference([1..n],IdentityColumns)} );
            w := w-w{IdentityColumns}*Mat;
            Add(W,w{Difference([1..n], IdentityColumns)} );
			UMD := Minimum( UMD, WeightCodeword( Codeword( w ) ) );
## G_i is generator matrix i
## W_i has zeros in IdentityColumns,
## but has same distance to code because
## only a codeword is added
        fi;
    until not ThisGIsDone or ( Icount = Int( n / k ) );

    while CurW <= ( UMD - multiple ) / Icount do
        i := 0;
        repeat
            i := i + 1;
            UMD := Minimum( UMD, DistanceVecFFE( W[i],
                                   AClosestVectorCombinationsMatFFEVecFFE(
                                     G[i], F, W[i], CurW, CurW*(Icount-1) )
                                   ) + CurW );
        until (i = Length(G)) or (UMD = CurW*Icount);
        CurW := CurW + 1;
    od;
    return UMD;
end);
           
InstallMethod(MinimumDistanceLeon, "attribute method for linear codes", true, 
	[IsLinearCode], 0, 
function(C) 
	local majority,G0, Gp, Gpt, Gt, L, k, i, j, dimMat, Grstr, J, d1, arrayd1, Combo, rows, row, rowSum, G, F, zero, AClosestVec, s, p, num;
	G0 := GeneratorMat(C);
	if (IsInStandardForm(G0)=false) then
		G := List(G0,ShallowCopy);
		PutStandardForm(G);		
	fi;
	F:=LeftActingDomain(C);
	if F<>GF(2) then Print("Code must be binary. Quitting. \n"); return(0); fi;
	p:=5; #these seem to be optimal values
	num:=8; #these seem to be optimal values
	dimMat := DimensionsMat(G);
	s := dimMat[2]-dimMat[1];
	arrayd1:=[];

for k in [1..num] do
##Permute the columns randomly
	Gt := TransposedMat(G);
	Gp := NullMat(dimMat[2],dimMat[1]);
	L := SymmetricGroup(dimMat[2]);
	L := Random(L);
	L:=List([1..dimMat[2]],i->OnPoints(i,L));
	for i in [1..dimMat[2]] do 
		Gp[i] := Gt[L[i]];
	od;
	Gp := TransposedMat(Gp);
	Gp := ShallowCopy(Gp);

##Use gaussian elimination on the new matrix
	TriangulizeMat(Gp);

##generate the restricted code (I|Z) from Gp=(I|Z|B)
	Gpt := TransposedMat(Gp);
	Grstr := NullMat(s,dimMat[1]);
	for i in [dimMat[1]+1..dimMat[1]+s] do
		Grstr[i-dimMat[1]] := Gpt[i];
	od;
	Grstr := TransposedMat(Grstr);
	zero := Zero(F)*Grstr[1];

##search for all rows of weight p

	J := []; #col number of codewords to compute the length of
	
	for i in [1..p] do
	AClosestVec:=AClosestVectorCombinationsMatFFEVecFFE(Grstr, F, zero, i, 1);
	if WeightVecFFE(AClosestVec) > 0 then
		Add(J, [AClosestVec,i]);
	fi;
	od;

	d1:=dimMat[2];
	for rows in J do
	  d1:=Minimum(WeightVecFFE(rows[1])+rows[2],d1);
	od;
	arrayd1[k]:=d1;
od;
if AbsoluteValue(Sum(arrayd1)/Length(arrayd1)-Int(Sum(arrayd1)/Length(arrayd1)))<1/2 then 
  majority:=Int(Sum(arrayd1)/Length(arrayd1)); 
 else
  majority:=Int(Sum(arrayd1)/Length(arrayd1))+1;
fi;
return(majority);
end);



#############################################################################
##
#F  LowerBoundMinimumDistance( arg )  . . . . . . . . . . . . . . . . . . .  
##

##LR - Is there a better way to handle HasMD case, without reset? 
InstallMethod(LowerBoundMinimumDistance, "method for unrestricted codes", 
	true, [IsCode], 0, 
function(C) 
	if HasMinimumDistance(C) then 
		C!.lowerBoundMinimumDistance := MinimumDistance(C); 
	elif not IsBound(C!.lowerBoundMinimumDistance) then 
		if Size(C) = 1 then 
			C!.lowerBoundMinimumDistance := WordLength(C); 
		else 
			C!.lowerBoundMinimumDistance := 1;
		fi;
	fi; 
	return C!.lowerBoundMinimumDistance; 
end); 

InstallMethod(LowerBoundMinimumDistance, "method for linear code", true, 
	[IsLinearCode], 0, 
function(C) 
	if HasMinimumDistance(C) then 
		C!.lowerBoundMinimumDistance := MinimumDistance(C); 
	elif not IsBound(C!.lowerBoundMinimumDistance) then 
		if Dimension(C) = 0 then  
			C!.lowerBoundMinimumDistance := WordLength(C);  
		elif Dimension(C) = 1 then 
			C!.lowerBoundMinimumDistance:= Weight(Codeword(GeneratorMat(C)[1]));
		else  
			C!.lowerBoundMinimumDistance := 1;
		fi;
	fi; 
	return C!.lowerBoundMinimumDistance; 
end); 

InstallMethod(LowerBoundMinimumDistance, "method for cyclic codes", true, 
	[IsCyclicCode], 0, 
function(C) 
	if HasMinimumDistance(C) then 
		C!.lowerBoundMinimumDistance := MinimumDistance(C); 
	elif not IsBound(C!.lowerBoundMinimumDistance) then 
		if Dimension(C) = 0 then  
			C!.lowerBoundMinimumDistance := WordLength(C);  
		elif Dimension(C) = 1 then 
			C!.lowerBoundMinimumDistance := Weight(Codeword(GeneratorPol(C))); 
		else 
			C!.lowerBoundMinimumDistance := 1;
		fi;
	fi; 
	return C!.lowerBoundMinimumDistance; 
end); 

InstallOtherMethod(LowerBoundMinimumDistance, "n, k, q", true, 
	[IsInt, IsInt, IsInt], 0, 
function(n, k, q) 
	local r; 
	r := BoundsMinimumDistance(n, k, q, true); 
	return r.lowerBound; 
end); 

InstallOtherMethod(LowerBoundMinimumDistance, "n, k", true, 
	[IsInt, IsInt], 0, 
function(n, k) 
	local r; 
	r := BoundsMinimumDistance(n, k, 2, true); 
	return r.lowerBound; 
end); 

InstallOtherMethod(LowerBoundMinimumDistance, "n, k, F", true, 
	[IsInt, IsInt, IsField], 0, 
function(n, k, F) 
	local r; 
	r := BoundsMinimumDistance(n, k, Size(F), true); 
	return r.lowerBound; 
end); 


#############################################################################
##
#F  UpperBoundMinimumDistance( arg )  . . . . . . . . . . . . . . . . . . .  
## 

##LR - is there a better way to handle HasMD case, without reset? 
InstallMethod(UpperBoundMinimumDistance, "method for unrestricted codes", 
	true, [IsCode], 0, 
function(C) 
	if HasMinimumDistance(C) then 
		C!.upperBoundMinimumDistance := MinimumDistance(C); 
	elif not IsBound(C!.upperBoundMinimumDistance) then 
		C!.upperBoundMinimumDistance := WordLength(C); 
	fi; 
	return C!.upperBoundMinimumDistance; 
end); 

InstallMethod(UpperBoundMinimumDistance, "method for linear codes", true, 
	[IsLinearCode], 0, 
function(C) 
    local ubmd;
	if HasMinimumDistance(C) then 
		C!.upperBoundMinimumDistance := MinimumDistance(C); 
	else 
		if not IsBound(C!.upperBoundMinimumDistance) then 
			ubmd := WordLength(C);
		else 
			ubmd := C!.upperBoundMinimumDistance; 
		fi; 
		if MinimumWeightOfGenerators(C) < ubmd then
			ubmd := MinimumWeightOfGenerators(C);
		fi;
		if UpperBoundOptimalMinimumDistance(C) < ubmd then
		    ubmd := UpperBoundOptimalMinimumDistance(C);
		fi;
		C!.upperBoundMinimumDistance := ubmd; 
	fi; 
	return C!.upperBoundMinimumDistance; 
end);

InstallOtherMethod(UpperBoundMinimumDistance, "n, k, q", true,
    [IsInt, IsInt, IsInt], 0,
function(n, k, q)
	local r;
	r := BoundsMinimumDistance(n, k, q, false);
	return r.upperBound;
end);

InstallOtherMethod(UpperBoundMinimumDistance, "n,k", true,
	[IsInt, IsInt], 0,
function(n, k)
	local r;
	r := BoundsMinimumDistance(n, k, 2, false);
	return r.upperBound;
end);

InstallOtherMethod(UpperBoundMinimumDistance, "n,k,F", true,
	[IsInt, IsInt, IsField], 0,
function(n, k, F)
	local r;
	r := BoundsMinimumDistance(n, k, Size(F), false);
	return r.upperBound;
end);


#############################################################################
##
#F  UpperBoundOptimalMinimumDistance( arg )  . . . . . . . . . . . . . . . .
##
##  UpperBoundMinimumDistance of optimal code with given parameters 
## 

InstallMethod(UpperBoundOptimalMinimumDistance, "method for unrestricted code", 
	true, [IsCode], 0, 
function(C) 
	local r; 
	r := BoundsMinimumDistance(WordLength(C), Dimension(C), 
								Size(LeftActingDomain(C)), false); 
	return r.upperBound; 
end); 


#############################################################################
##
#F  MinimumWeightOfGenerators( arg )  . . . . . . . . . . . . . . . . . . . .
##
##

InstallMethod(MinimumWeightOfGenerators, "linear codes", true, 
	[IsLinearCode], 0, 
function(C) 
	local zero, mwg, sum, element, row;  
    zero := Zero(LeftActingDomain(C));  
	mwg := WordLength(C);
	if Dimension(C) > 0 then
	    # minimumWeightOfGenerators for null codes is n
	    for row in GeneratorMat(C) do
	        sum := 0;
	        for element in row do
	            if element <> zero then
	                 sum := sum + 1;
	            fi;
	        od;
			if sum < mwg then
				 mwg := sum;
			fi;
	    od;
	fi;
	return mwg;
end); 

InstallMethod(MinimumWeightOfGenerators, "method for cyclic codes", true, 
	[IsCyclicCode], 0, 
function(C) 
	if Dimension(C) > 0 then
	     # minimumWeightOfGenerators of null codes is n
	     return Weight(Codeword(GeneratorPol(C)));  
	else
	     return WordLength(C);
	fi;
end); 


#############################################################################
##
#F  MinimumWeightWords( <C> ) . . .  returns the code words of minimum weight
##

InstallMethod(MinimumWeightWords, "method for unrestricted code", true, 
	[IsCode], 0, 
function(C)
    local curmin, res, e, w, zerovec;
    if IsLinearCode(C) then
        return MinimumWeightWords(C);
    fi;
    curmin := WordLength(C);
    if not HasWeightDistribution(C) then
        res := [];
        for e in AsSSortedList(C) do
            w := Weight(e);
            if w < curmin and w <> 0 then
                # New minimum weight found
                curmin := w;
                res := [ e ];
            elif w = curmin then
                Add(res, e);
            fi;
        od;
        return res;
    else
        # Find the minimum weight
        w := PositionProperty(WeightDistribution(C){[2..WordLength(C)]},
                     e -> e <> 0);
        if w = false then
            return NullVector(WordLength(C), LeftActingDomain(C));
        else
            return Filtered(AsSSortedList(C), e -> Weight(e) = w);
        fi;
    fi;
end);

InstallMethod(MinimumWeightWords, "method for linear code", true, 
	[IsLinearCode], 0, 
function(C)
    local d, G, res, vector, count, i, t, k, q, M, zerovec;
    d := MinimumDistance(C);  # Equal to minimum weight
    G := GeneratorMat(C);
    k := Dimension(C);
    q := Size(LeftActingDomain(C));
    M := Size(C);
    res := [];
    vector := NullVector(WordLength(C), LeftActingDomain(C));
    zerovec := ShallowCopy(vector);
    count := 1;
    while count < M do
        # Calculate next word in the code
        i := k;
        t := count;
        while t mod q = 0 do
            t := t / q;
            i := i - 1;
        od;
        vector := vector + G[i];
        if DistanceVecFFE(vector, zerovec) = d then
            # This word has minimum weight
            Add(res, Codeword(vector));
        fi;
        count := count + 1;
    od;
    return res;
end);


#############################################################################
##
#F  WeightDistribution( <C> ) . . . returns the weight distribution of a code
##
InstallMethod(WeightDistribution, "method for unrestricted code", true, 
	[IsCode], 0, 
function (C)
    local El, nl, newwd;
    if IsLinearCode(C) then
        return WeightDistribution(C);
    fi;
    El := VectorCodeword(AsSSortedList(C));
    nl := VectorCodeword(NullWord(C));
    newwd := DistancesDistributionVecFFEsVecFFE(El, nl);
    return newwd;
end);

InstallMethod(WeightDistribution, "method for linear code", true, 
	[IsLinearCode], 0, 
function(C)
    local G, nl, k, n, q, F, wd, newwd, oldrow, newrow, i, j;
    n := WordLength(C);
    k := Dimension(C);
    q := Size(LeftActingDomain(C)); 
	F := LeftActingDomain(C); 
    nl := VectorCodeword(NullWord(C));
    if k = 0 then
        G := NullVector(n+1);
        G[1] := 1;
        newwd := G;
    elif k = n then
        newwd := List([0..n], i->Binomial(n, i));
    elif k <= Int(n/2) then
		G := ShallowCopy(GeneratorMat(C));
        newwd := DistancesDistributionMatFFEVecFFE(G, F, nl);
    else
        G := ShallowCopy(CheckMat(C));
        wd := DistancesDistributionMatFFEVecFFE(G, F, nl);
        newwd := [Sum(wd)];
        oldrow := List([1..n+1], i->1);
        newrow := [];
        for i in [2..n+1] do
            newrow[1] := Binomial(n, i-1) * (q-1)^(i-1);
            for j in [2..n+1] do
                newrow[j] := newrow[j-1] - (q-1) * oldrow[j] - oldrow[j-1];
            od;
            newwd[i] := newrow * wd;
            oldrow := ShallowCopy(newrow);
        od;
        newwd:= newwd / (q ^ Redundancy(C));
    fi;
    return newwd;
end);


#############################################################################
##
#F  InnerDistribution( <C> )  . . . . . .  the inner distribution of the code
##
##  The average distance distribution of distances between all codewords
##

InstallMethod(InnerDistribution, "method for unrestricted code", true, 
	[IsCode], 0, 
function (C)
    local ID, c, El;
    El := VectorCodeword(AsSSortedList(C));
    ID := List([1..WordLength(C)+1], i->0);
    for c in El do
        ID := ID + DistancesDistributionVecFFEsVecFFE(El, c);
    od;
    return ID/Size(C);
end);

InstallMethod(InnerDistribution, "method for linear codes", true, 
	[IsLinearCode], 0, 
function (C)
    return WeightDistribution(C);
end);


#############################################################################
##
#F  OuterDistribution( <C> )  . . . . . . . . . . . . . . . . . . . . . . .  
##
##  the number of codewords on a distance i from all elements of GF(q)^n
##
									
InstallOtherMethod(OuterDistribution, "method for unrestricted code", true, 
	[IsCode], 0, 
function (C)
	local gen, q, n, F, zero, Els, res, vector, t, large, count, dd; 

    if IsLinearCode(C) then
        return OuterDistribution(C);
    fi;
    q := Size(LeftActingDomain(C));
    n := WordLength(C);
	F := LeftActingDomain(C); 
	zero := Zero(F); 

	Els := VectorCodeword(AsSSortedList(C)); 
	res := [[NullWord(C),WeightDistribution(C)]]; 
	vector := NullVector(n, F); 
	t := n; 
	gen := Z(q); 
	large := One(F); 

	for count in [2..q^n] do 
		t := n; 
		while vector[t] = large do 
			vector[t] := zero; 
			t := t-1; 
		od; 
		if vector[t] = zero then 
			vector[t] := gen; 
		else 
			vector[t] := vector[t] * gen; 
		fi; 

		dd := DistancesDistributionVecFFEsVecFFE(Els, vector); 
		Add(res, [Codeword(vector), dd]); 
	od; 

	return res; 

end); 

InstallMethod(OuterDistribution, "method for linear codes", true,
    [IsLinearCode], 0,
function(C)
	local STentry, dtw, E, res, i;
	E := AsSSortedList(C);
	res := [];
	for STentry in List(SyndromeTable(C), i -> i[1]) do
		dtw := DistancesDistribution(C, STentry);
		for i in E do
			Add(res, [VectorCodeword(STentry) + i, dtw]);
		od;
	od;
	return res;
end);


  
#############################################################################
##
#F  InformationWord( Code, c )  . . . "decodes" a codeword c in C to the 
##                                information "message" word m, so m*C=c

InstallMethod(InformationWord, "code, codeword", true, [IsCode, IsCodeword], 1, 
function(C, c)
	local m;
	if not(c in C) then return "ERROR: codeword must belong to code"; fi; 
	if not(IsLinearCode(C)) then return "ERROR: code must be linear"; fi; 
	m := Decode(C,c);  
	return m;
end);



#############################################################################
##
#F  IsSelfDualCode( <C> ) . . . . . . . . . determines whether C is self dual
##
##  i.o.w. each codeword is orthogonal to all codewords (including itself)
##

InstallMethod(IsSelfDualCode, "method for unrestricted code", true, 
	[IsCode], 0, 
function(C)
    if IsCyclicCode(C) or IsLinearCode(C) then 
		return IsSelfDualCode(C); 
	else 
		return false;
	fi; 
end);

InstallMethod(IsSelfDualCode, "method for linear code", true, 
	[IsLinearCode], 0, 
function(C)
    if IsCyclicCode(C) then 
		return IsSelfDualCode(C); 
	elif Redundancy(C) <> Dimension(C) then
        return false; #so the code is not self dual
    else
        return (GeneratorMat(C)*TransposedMat(GeneratorMat(C)) = 
                NullMat(Dimension(C),Dimension(C),LeftActingDomain(C))); 
    fi;
end);

InstallMethod(IsSelfDualCode, "method for cyclic codes", true, 
	[IsCyclicCode], 0, 
function(C)
    local r;
    if Redundancy(C) <> Dimension(C) then
        return false; #so the code is not self dual
    else
        r := ReciprocalPolynomial(GeneratorPol(C),Redundancy(C));
        r := r/LeadingCoefficient(r);
        return CheckPol(C) = r;
    fi;
end);


#############################################################################
##
#F  CodewordVector( <l>, <C> )
##
##  only valid if C is linear! 
##

InstallOtherMethod(CodewordVector,"vector and unrestricted code", true, 
	[IsList, IsCode], 0, 
function(l, C) 
    if IsLinearCode(C) then
        return CodewordVector(l,C);
    else
    	Error("<r> is a non-linear code");# encoding not possible
    fi;
end);

InstallOtherMethod(CodewordVector,"vector and linear code", true, 
	[IsList, IsLinearCode], 0, 
function(l, C) 
    local s, i, k;
    if IsCyclicCode(C) then
        return CodewordVector(l,C);
    else
        l := VectorCodeword(Codeword(l, Dimension(C), LeftActingDomain(C)));
		if GeneratorMat(C) = [] then
            return NullMat(Length(l), WordLength(C), LeftActingDomain(C));
        else
            return Codeword(l*GeneratorMat(C), C);
        fi;
    fi;
end);

InstallOtherMethod(CodewordVector, "<list of codewords|vector>,cyclic code", 
	true, [IsList, IsCyclicCode], 0, 
function(l, C) 
    local F, p;
    F := LeftActingDomain(C);
	l := Codeword(l, Dimension(C), F);
	if IsList(l) and not IsCodeword(l) then
	    return List(l, i->CodewordVector(i,C));
	else
	    return Codeword(PolyCodeword(l) * GeneratorPol(C), C);
	fi;
end);  

InstallOtherMethod(CodewordVector, "method for poly and cyclic code", true, 
	[IsUnivariatePolynomial, IsCyclicCode], 0, 
function(p, C) 
	local F, w; 
	F := LeftActingDomain(C); 
	w := Codeword(p, Dimension(C), F); 
	return Codeword(PolyCodeword(w) * GeneratorPol(C), C); 
end); 

InstallOtherMethod(\*, "list with code", true, [IsList, IsCode], 0, 
  CodewordVector);

InstallOtherMethod(\*, "poly with code", true, 
  [IsUnivariatePolynomial, IsCode], 0, CodewordVector);

InstallOtherMethod(\*, "method for two codes", true, [IsCode, IsCode], 0, 
function(C1, C2) 
	return DirectProductCode(C1, C2); 
end); 


#############################################################################
##
#F  \+( <l>, <C> )  . . . . . . . . . . . . . . . . . . . . . . . . . . . .  
##
##

InstallOtherMethod(\+, "method for codeword+code", true, 
	[IsCodeword, IsCode], 0, 
function(w, C) 
	return CosetCode(C, w); 
end); 

InstallOtherMethod(\+, "method for code+codeword", true, 
	[IsCode, IsCodeword], 0, 
function(C, w) 
	return CosetCode(C, w); 
end); 

InstallOtherMethod(\+, "method for two codes", true, [IsCode, IsCode], 0, 
function(C1, C2) 
	return DirectSumCode(C1, C2); 
end); 


#############################################################################
##
#F  \in( <l>, <C> ) . . . . . .  true if the vector is an element of the code
##
##

InstallMethod(\in, "method for codeword in unrestricted code", true, 
	[IsCodeword, IsCode], 0, 
function(w, C) 
	if WordLength(w) <> WordLength(C) then 
		return false; 
	else 
		return w in AsSSortedList(C); 
	fi; 
end); 

InstallMethod(\in, "method for list of codewords in unrestricted code", true, 
	[IsList, IsCode], 0, 
function(l, C) 
	return ForAll(l, w->w in C); 
end); 

InstallMethod(\in, "method for unrestricted code in unrestricted code", true, 
	[IsCode, IsCode], 0, 
function(C1, C2)
	local l;
	l := ShallowCopy(AsSSortedList(C1)); 
	return ForAll(l, w->w in C2);    
end); 

InstallMethod(\in, "method for codeword in linear code", true, 
	[IsCodeword, IsLinearCode], 0, 
function(w, C) 
	if WordLength(w) <> WordLength(C) then 
		return false; 
	elif GeneratorMat(C) = [] then 
		return w = 0*w; 
	elif CheckMat(C) = [] then  #Code is WholeSpace, just check field.  
		return ForAll(VectorCodeword(w), x->x in LeftActingDomain(C)); 
	else 
		return CheckMat(C)*w = 0*w;
	fi; 
end); 

InstallMethod(\in, "method for linear code in linear code", true, 
	[IsLinearCode, IsLinearCode], 0, 
function(C1, C2) 
	local l; 
	l := ShallowCopy(GeneratorMat(C1)); 
	return ForAll(l, w-> Codeword(w) in C2); 
end); 

InstallMethod(\in, "method for codeword in cyclic code", true, 
	[IsCodeword, IsCyclicCode], 0, 
function(w, C) 
	return PolyCodeword(w) mod GeneratorPol(C) = 
					0 * Indeterminate(LeftActingDomain(C)); 
end); 

InstallMethod(\in, "method for cyclic code in cyclic code", true, 
	[IsCyclicCode, IsCyclicCode], 0, 
function(C1, C2) 
	return GeneratorPol(C1) mod GeneratorPol(C2) = 
					0 * Indeterminate(LeftActingDomain(C2));
end); 

#############################################################################
##
#F  \=( <C1>, <C2> )  . . . . .  tests if Set(AsList(C1))=Set(AsList(C2))
##
##  Post: returns a boolean
##

InstallMethod(\=, "method for unrestricted code = unrestricted code", true, 
	[IsCode, IsCode], 0, 
function(C1, C2) 
	local field, fields; 
	if (IsLinearCode(C1) and IsLinearCode(C2)) or 
	   (IsCyclicCode(C1) and IsCyclicCode(C2)) then 
		return C1 = C2; 
	elif IsLinearCode(C1) or IsLinearCode(C2) then 
		return false;  ##one is linear, the other is not, so not equal
	fi; 
	if Set(AsSSortedList(C1)) = Set(AsSSortedList(C2)) then
		fields := [WeightDistribution, InnerDistribution,
				   IsLinearCode, IsPerfectCode,
				   IsSelfDualCode, OuterDistribution, IsCyclicCode,
				   AutomorphismGroup, MinimumDistance, CoveringRadius];
		for field in fields do 
			if not Tester(field)(C1) then 
				if Tester(field)(C2) then 
					Setter(field)(C1, field(C2)); 
				fi;
			else
				if not Tester(field)(C2) then
					Setter(field)(C2, field(C1));  
				fi;
			fi;
		od; 
		if not IsBound(C1!.boundsCoveringRadius) then 
			if IsBound(C2!.boundsCoveringRadius) then 
				C1!.boundsCoveringRadius := C2!.boundsCoveringRadius; 
			fi; 
		else 
			if not IsBound(C2!.boundsCoveringRadius) then 
				C2!.boundsCoveringRadius := C1!.boundsCoveringRadius; 
			fi; 
		fi; 
		C1!.lowerBoundMinimumDistance := Maximum(LowerBoundMinimumDistance(C1),
												LowerBoundMinimumDistance(C2));
		C2!.lowerBoundMinimumDistance := C1!.lowerBoundMinimumDistance;
		C1!.upperBoundMinimumDistance := Minimum(UpperBoundMinimumDistance(C1), 
												UpperBoundMinimumDistance(C2));
		C2!.upperBoundMinimumDistance := C1!.upperBoundMinimumDistance;
		return true;
	else
		return false; #so C1 is not equal to C2 
	fi;
end);

InstallMethod(\=, "method for linear code = linear code", true, 
	[IsLinearCode, IsLinearCode], 0, 
function(C1, C2) 
    local field, fields;
    if IsCyclicCode(C1) and IsCyclicCode(C2) then 
		return C1 = C2; 
	elif IsCyclicCode(C1) or IsCyclicCode(C2) then 
		return false;  ##one is cyclic, the other is not, so not equal. 
	fi; 
	if BaseMat(GeneratorMat(C1))=BaseMat(GeneratorMat(C2)) then
		fields := [WeightDistribution, InnerDistribution,
				   IsLinearCode, IsPerfectCode,
				   IsSelfDualCode, OuterDistribution, IsCyclicCode,
				   AutomorphismGroup, MinimumDistance, CoveringRadius];
		for field in fields do 
			if not Tester(field)(C1) then
				if Tester(field)(C2) then 
					Setter(field)(C1, field(C2)); 
				fi;
			else
				if not Tester(field)(C2) then 
					Setter(field)(C2, field(C1)); 
				fi;
			fi;
		od;  
		if not IsBound(C1!.boundsCoveringRadius) then 
			if IsBound(C2!.boundsCoveringRadius) then 
				C1!.boundsCoveringRadius := C2!.boundsCoveringRadius; 
			fi; 
		else 
			if not IsBound(C2!.boundsCoveringRadius) then 
				C2!.boundsCoveringRadius := C1!.boundsCoveringRadius; 
			fi; 
		fi; 
		C1!.lowerBoundMinimumDistance := Maximum(LowerBoundMinimumDistance(C1),
												LowerBoundMinimumDistance(C2));
		C2!.lowerBoundMinimumDistance := C1!.lowerBoundMinimumDistance;
		C1!.upperBoundMinimumDistance := Minimum(UpperBoundMinimumDistance(C1),
												UpperBoundMinimumDistance(C2));
		C2!.upperBoundMinimumDistance := C1!.upperBoundMinimumDistance;
		return true;
	else
		return false; #so l is not equal to r
	fi;
end);

InstallMethod(\=, "method for cyclic code = cyclic code", true, 
	[IsCyclicCode, IsCyclicCode], 0, 
function(C1, C2) 
    local field, fields, bmdl, bmdr;
    if GeneratorPol(C1) = GeneratorPol(C2) then
        fields := [WeightDistribution, InnerDistribution,
                   IsLinearCode, IsPerfectCode,
                   IsSelfDualCode, OuterDistribution, IsCyclicCode,
                   AutomorphismGroup, MinimumDistance, CoveringRadius, 
				   RootsOfCode]; 
        for field in fields do 
            if not Tester(field)(C1) then 
                if Tester(field)(C2) then 
                    Setter(field)(C1, field(C2)); 
                fi;
            else
                if not Tester(field)(C2) then
                    Setter(field)(C2, field(C1)); 
                fi;
            fi;
        od; 
		if not IsBound(C1!.boundsCoveringRadius) then 
			if IsBound(C2!.boundsCoveringRadius) then 
				C1!.boundsCoveringRadius := C2!.boundsCoveringRadius; 
			fi; 
		else 
			if not IsBound(C2!.boundsCoveringRadius) then 
				C2!.boundsCoveringRadius := C1!.boundsCoveringRadius; 
			fi; 
		fi; 
        C1!.lowerBoundMinimumDistance := Maximum(LowerBoundMinimumDistance(C1),
                                               LowerBoundMinimumDistance(C2));
        C2!.lowerBoundMinimumDistance := C1!.lowerBoundMinimumDistance;
        C1!.upperBoundMinimumDistance := Minimum(UpperBoundMinimumDistance(C1),
                                               UpperBoundMinimumDistance(C2));
        C2!.upperBoundMinimumDistance := C1!.upperBoundMinimumDistance;
        return true;
    else
        return false; #so l is not equal to r
    fi;
end);


#############################################################################
##
#F  SyndromeTable ( <C> ) . . . . . . . . . . . . . . . a Syndrome table of C
##

InstallMethod(SyndromeTable, "method for unrestricted code", true, 
	[IsCode], 0, 
function(C)
    if IsLinearCode(C) then
        return SyndromeTable(C);
    else
        Error("the syndrome table is not defined for non-linear codes");
    fi;
end);

InstallMethod(SyndromeTable, "method for linear code", true, 
	[IsLinearCode], 0, 
function(C)
    local H, L, F;
    H := CheckMat(C);
    if H = [] then
        return [];
    fi;
    F := LeftActingDomain(C);
    L := CosetLeadersMatFFE(H, F);
    H := TransposedMat(H);
    return Codeword(List(L, l-> [l, l*H]), F);
end);


#############################################################################
##
#F  StandardArray( <C> )  . . . . . . . . . . . . a standard array for code C
##
##  Post: returns a 3D-matrix. The first row contains all the codewords of C.
##  The other rows contain the cosets, preceded by their coset leaders.
##

InstallMethod(StandardArray, "method for unrestricted code", true, 
	[IsCode], 0, 
function(C)
    if IsLinearCode(C) then
        return StandardArray(C);
    else
        Error("a standard array is not defined for non-linear codes");
    fi;
end);

InstallMethod(StandardArray, "method for linear code", true, [IsLinearCode], 0, 
function(C)
    local Els;
    Els := AsSSortedList(C);
    if CheckMat(C) = [] then
        return [Els];
    fi;
    return List(Set(CosetLeadersMatFFE(CheckMat(C), LeftActingDomain(C))),
                row -> List(Els, column -> row + column));
end);
    

#############################################################################
##
#F  AutomorphismGroup( <C> )  . . . . . . . .  the automorphism group of code
##
##  The automorphism group is the largest permutation group of degree n such
##  that for each permutation in the group C' = C
##

InstallOtherMethod(AutomorphismGroup, "method for unrestricted codes", true, 
	[IsCode], 0, 
function(C) 
 local path;
      path := DirectoriesPackagePrograms( "guava" );

      if ForAny( ["desauto", "leonconv", "wtdist"], 
                 f -> Filename( path, f ) = fail ) then
Print("desauto not loaded ... switching to PermutationGroup ...\n");
return PermutationGroup(C);
      fi;
    if Size(LeftActingDomain(C)) > 2 then
	Print("This command calculates automorphism groups for binary codes only\n");
        Print("... automatically switching to PermutationGroup ...\n");
        return PermutationGroup(C);
    elif IsLinearCode(C) then
        return AutomorphismGroup(C);
    else
        return MatrixAutomorphisms(VectorCodeword(AsSSortedList(C)), 
                       [], Group( () ));
    fi;
end);

InstallOtherMethod(AutomorphismGroup, "method for linear codes", true, 
	[IsLinearCode], 0, 
function(C) 
    local incode, inV, outgroup, infile,Ccalc,path;
      path := DirectoriesPackagePrograms( "guava" );

      if ForAny( ["desauto", "leonconv", "wtdist"], 
                 f -> Filename( path, f ) = fail ) then
Print("desauto not loaded ... switching to PermutationGroup ...\n");
return PermutationGroup(C);
      fi;
    if Size(LeftActingDomain(C)) > 2 then 
	Print("This command calculates automorphism groups for binary codes only\n");
        Print("... automatically switching to PermutationGroup ...\n");
        return PermutationGroup(C);
	fi; 
    incode :=  TmpName(); PrintTo( incode, "\n" );
    inV := TmpName(); PrintTo( inV, "\n" );
    outgroup := TmpName(); PrintTo( outgroup, "\n" );
    infile := TmpName(); PrintTo( infile, "\n" );
    # Calculate with dual code if it is smaller:
    if Dimension(C) > QuoInt(WordLength(C), 2) then
        Ccalc := DualCode(C);
    else
        Ccalc := ShallowCopy(C);
    fi;
    GuavaToLeon(Ccalc, incode);
    Exec(Filename(DirectoriesPackagePrograms("guava"), "wtdist"), 
            Concatenation("-q ",incode,"::code ",
            String(MinimumDistance(Ccalc))," ",inV,"::code"));
    Exec(Filename(DirectoriesPackagePrograms("guava"), "desauto"), 
            Concatenation("-code -q ",
            incode,"::code ",inV,"::code ",outgroup));
    Exec(Filename(DirectoriesPackagePrograms("guava"), "leonconv"), 
            Concatenation("-a ",outgroup," ", infile));
    Read(infile);
    RemoveFiles(incode,inV,outgroup,infile);
    return GUAVA_TEMP_VAR;
end);

##  If the new partition backtrack algorithms are implemented, the previous
##  function can be replaced by the next:
#InstallOtherMethod(AutomorphismGroup, "method for linear code", true, 
#	[IsLinearCode], 0, 
#function(C)
#    local Ccalc, InvSet;
#    if Dimension(C) > QuoInt(WordLength(C), 2) then
#        Ccalc := DualCode(C);
#    else
#        Ccalc := ShallowCopy(C);
#    fi;
#    InvSet := VectorCodeword(MinimumWeightWords(Ccalc));
#    return AutomorphismGroupBinaryLinearCode(Ccalc, InvSet);
#end);

#############################################################################
##
## PermutationGroup( <C> ) . . . . . .  PermutationGroup of non-binary code
##
## confusing name?

InstallMethod(PermutationGroup, "attribute method for linear codes", true, 
	[IsLinearCode], 0, 
function(C)
local G0, Gell, G1, G2, Gt, L, k, i, j, G, F, A, aut, n, Sn, ell;

Print("\n To be deprecated. Please use PermutationAutomorphismGroup.\n");
	F:=LeftActingDomain(C);
	G1 := GeneratorMat(C);
	G := List(G1,ShallowCopy);
	k:=DimensionsMat(G)[1];
	n:=DimensionsMat(G)[2];
	TriangulizeMat(G);
	Gt := TransposedMat(G);
	Sn := SymmetricGroup(n);
	A:=[];
	for ell in Sn do
 	  G2:= NullMat(n,k);
 	  for j in [1..n] do
  	    G2[j]:=Gt[OnPoints(j,ell)];
 	  od; # j
	  Gell := TransposedMat(G2);
 	  G0 := List(Gell,ShallowCopy);
 	  TriangulizeMat(G0);
 	  if G = G0 then Add(A, ell); fi;
	od; # ell
	if Length(A)>0 then 
	  aut := Group(A); 
	else aut:=Group(()); 
	fi;
	return(aut);
end);


#############################################################################
##
## PermutationAutomorphismGroup( <C> ) . .  Permutation automorphism
##                                  group of linear (possibly non-binary) code
##
##

InstallMethod(PermutationAutomorphismGroup, "attribute method for linear codes", true, 
	[IsLinearCode], 0, 
function(C)
local G0, Gell, G1, G2, Gt, L, k, i, j, G, F, A, aut, n, Sn, ell;

	F:=LeftActingDomain(C);
	G1 := GeneratorMat(C);
	G := List(G1,ShallowCopy);
	k:=DimensionsMat(G)[1];
	n:=DimensionsMat(G)[2];
	TriangulizeMat(G);
	Gt := TransposedMat(G);
	Sn := SymmetricGroup(n);
	A:=[];
	for ell in Sn do
 	  G2:= NullMat(n,k);
 	  for j in [1..n] do
  	    G2[j]:=Gt[OnPoints(j,ell)];
 	  od; # j
	  Gell := TransposedMat(G2);
 	  G0 := List(Gell,ShallowCopy);
 	  TriangulizeMat(G0);
 	  if G = G0 then Add(A, ell); fi;
	od; # ell
	if Length(A)>0 then 
	  aut := Group(A); 
	else aut:=Group(()); 
	fi;
	return(aut);
end);

#############################################################################
##
#F  IsSelfOrthogonalCode( <C> ) . . . . . . . . . . . . . . . . . . . . . .  
##

InstallTrueMethod(IsSelfOrthogonalCode, IsSelfDualCode);  

InstallMethod(IsSelfOrthogonalCode, "method for unrestricted code", true, 
	[IsCode], 0, 
function(C)
    local El, M, zero, i, j, IsSO;
    if IsLinearCode(C) then
        return IsSelfOrthogonalCode(C);
    fi;
    El := AsSSortedList(C);
    M := Size(C);
    zero := Zero(LeftActingDomain(C));
    i := 1; IsSO := true;
    while (i <= M-1) and IsSO do
        j := i+1;
        while (j <= M) and (El[i]*El[j] = zero) do 
            j := j + 1; 
        od;
        if j <= M then 
            IsSO := false;
        fi;
        i := i + 1;
    od;
    return IsSO;
end);

InstallMethod(IsSelfOrthogonalCode, "method for linear code", true, 
	[IsLinearCode], 0, 
function(C)
    local G, k;
    G := GeneratorMat(C);
    k := Dimension(C);
    return G*TransposedMat(G) = NullMat(k,k,LeftActingDomain(C));
end);


#############################################################################
##
#F  CodeIsomorphism( <C1>, <C2> ) . . the permutation that translates C1 into
#F                         C2 if C1 and C2 are equivalent, or false otherwise
##

InstallMethod(CodeIsomorphism, "method for two unrestricted codes", true, 
	[IsCode, IsCode], 0, 
function(C1, C2) 
    local tp, field; 
	if WordLength(C1) <> WordLength(C2) or Size(C1) <> Size(C2)
       or MinimumDistance(C1) <> MinimumDistance(C2)
       or LeftActingDomain(C1) <> LeftActingDomain(C2) then
        return false; #I think this is what we want (see IsEquivalentCode)
    elif C1=C2 then
        return ();
    elif IsLinearCode(C1) and IsLinearCode(C2) then 
        return CodeIsomorphism(C1, C2 );
    fi;
     
    tp :=  TransformingPermutations(VectorCodeword(AsSSortedList(C1)), 
                   VectorCodeword(AsSSortedList(C2)));
    if tp <> false then
        for field in [WeightDistribution, InnerDistribution,
                IsPerfectCode, IsSelfDualCode] do 
            if not Tester(field)(C1) then 
				if Tester(field)(C2) then 
					Setter(field)(C1, field(C2)); 
				fi; 
			else 
				if not Tester(field)(C2) then 
					Setter(field)(C2, field(C1)); 
				fi; 
			fi; 
		od; 

		if not IsBound(C1!.boundsCoveringRadius) then
			if IsBound(C2!.boundsCoveringRadius) then
				C1!.boundsCoveringRadius := C2!.boundsCoveringRadius;
			fi;
		else
			if not IsBound(C2!.boundsCoveringRadius) then
				C2!.boundsCoveringRadius := C1!.boundsCoveringRadius;
			fi;
		fi;
	    	
        C1!.lowerBoundMinimumDistance := Maximum(LowerBoundMinimumDistance(C1),
                                                LowerBoundMinimumDistance(C2));
        C2!.lowerBoundMinimumDistance := LowerBoundMinimumDistance(C1);
        C1!.upperBoundMinimumDistance := Minimum(UpperBoundMinimumDistance(C1),
                                                UpperBoundMinimumDistance(C2));
        C2!.upperBoundMinimumDistance := UpperBoundMinimumDistance(C1);
        return tp.columns;
    else
        return false; #yes, this is right
    fi;
end);

InstallMethod(CodeIsomorphism, "method for two linear codes", true, 
	[IsLinearCode, IsLinearCode], 0, 
function(C1, C2) 
    local code1,code2,cwcode1,cwcode2,output,infile, field;

	if WordLength(C1) <> WordLength(C2) or Size(C1) <> Size(C2)
       or MinimumDistance(C1) <> MinimumDistance(C2)
	   or LeftActingDomain(C1) <> LeftActingDomain(C2) then
		return false; #I think this is what we want (see IsEquivalentCode)
	elif C1=C2 then
		return ();
	elif LeftActingDomain(C1) <> GF(2) then
        Error("GUAVA can only calculate equivalence over GF(2)");
    fi;
    
	code1 := TmpName(); PrintTo( code1, "\n" );
    code2 := TmpName(); PrintTo( code2, "\n" );
    cwcode1 := TmpName(); PrintTo( cwcode1, "\n" );
    cwcode2 := TmpName(); PrintTo( cwcode2, "\n" );
    output := TmpName(); PrintTo( output, "\n" );
    infile := TmpName(); PrintTo( infile, "\n" );
    GuavaToLeon(C1, code1);
    GuavaToLeon(C2, code2);
    Exec(Filename(DirectoriesPackagePrograms("guava"), "wtdist"), 
            Concatenation("-q ",code1,"::code ",
            String(MinimumDistance(C1))," ",cwcode1,"::code"));
    Exec(Filename(DirectoriesPackagePrograms("guava"), "wtdist"), 
            Concatenation("-q ",code2,"::code ",
            String(MinimumDistance(C2))," ",cwcode2,"::code"));
    Exec(Filename(DirectoriesPackagePrograms("guava"), "desauto"), 
            Concatenation("-iso -code -q ",
            code1,"::code ",code2,"::code ",cwcode1,"::code ",
            cwcode2,"::code ",output));
    Exec(Filename(DirectoriesPackagePrograms("guava"), "leonconv"), 
            Concatenation("-e ",output," ", 
            infile));
    Read(infile);
    RemoveFiles(code1,code2,cwcode1,cwcode2,output,infile);
    if not IsPerm(GUAVA_TEMP_VAR) then
        return false; #it is good that false is returned
    else
        for field in [WeightDistribution,
                IsPerfectCode,
                IsSelfDualCode]  do 
			if not Tester(field)(C1) then 
				if Tester(field)(C2) then 
					Setter(field)(C1, field(C2)); 
				fi; 
			else 
				if not Tester(field)(C2) then 
					Setter(field)(C2, field(C1)); 
				fi; 
			fi; 
		od; 

		if not IsBound(C1!.boundsCoveringRadius) then
			if IsBound(C2!.boundsCoveringRadius) then
				C1!.boundsCoveringRadius := C2!.boundsCoveringRadius;
			fi;
		else
			if not IsBound(C2!.boundsCoveringRadius) then
				C2!.boundsCoveringRadius := C1!.boundsCoveringRadius;
			fi;
		fi;
        C1!.lowerBoundMinimumDistance := Maximum(LowerBoundMinimumDistance(C1),
                                                LowerBoundMinimumDistance(C2));
        C2!.lowerBoundMinimumDistance := LowerBoundMinimumDistance(C1);
        C1!.upperBoundMinimumDistance := Minimum(UpperBoundMinimumDistance(C1),
                                                UpperBoundMinimumDistance(C2));
        C2!.upperBoundMinimumDistance := UpperBoundMinimumDistance(C1);
        return GUAVA_TEMP_VAR;
    fi;
end);


##  If the new partition backtrack algorithms are implemented, the previous
##  function can be replaced by the next:
#InstallMethod(CodeIsomorphism, "method for linear codes", true, 
#	[IsLinearCode, IsLinearCode], 0, 
#function (C1, C2)
#   local field, InvSet1, InvSet2, P;
#   if WordLength(C1) <> WordLength(C2) or Size(C1) <> Size(C2)
#      or MinimumDistance(C1) <> MinimumDistance(C2)
#	   or LeftActingDomain(C1) <> LeftActingDomain(C2) then
#		return false; #I think this is what we want (see IsEquivalentCode)
#	elif C1=C2 then
#	 	return ();
#	elif LeftActingDomain(C1) <> GF(2) then
#		Error("GUAVA can only calculate equivalence over GF(2)");
#	fi;
#    InvSet1 := VectorCodeword(MinimumWeightWords(C1));
#    InvSet2 := VectorCodeword(MinimumWeightWords(C2));
#    P := AutomorphismGroupBinaryLinearCode(C1, InvSet1, C2, InvSet2);
#    if not IsPerm(P) then
#        return false; #it is good that false is returned
#    else
#        for field in [WeightDistribution,
#                      IsPerfectCode,
#                      IsSelfDualCode]  do 
#        	if not Tester(field)(C1) then 
#				if Tester(field)(C2) then 
#					Setter(field)(C1, field(C2)); 
#				fi; 
#			else 
#				if not Tester(field)(C2) then 
#					Setter(field)(C2, field(C1)); 
#				fi; 
#			fi; 
#		 od; 
#
#		 if not IsBound(C1!.boundsCoveringRadius) then
#            if IsBound(C2!.boundsCoveringRadius) then
#                C1!.boundsCoveringRadius := C2!.boundsCoveringRadius; 
#            fi;
#        else
#            if not IsBound(C2!.boundsCoveringRadius) then
#                C2!.boundsCoveringRadius := C1!.boundsCoveringRadius;
#            fi;
#        fi;
#        C1!.lowerBoundMinimumDistance := Maximum(LowerBoundMinimumDistance(C1),
#                                               LowerBoundMinimumDistance(C2));
#        C2!.lowerBoundMinimumDistance := LowerBoundMinimumDistance(C1);
#        C1!.upperBoundMinimumDistance := Minimum(UpperBoundMinimumDistance(C1),
#                                               UpperBoundMinimumDistance(C2));
#        C2!.upperBoundMinimumDistance := UpperBoundMinimumDistance(C1);
#        return P;
#    fi;
#end);


#############################################################################
##
#F  IsEquivalent( <C1>, <C2> )  . . . . . .  true if C1 and C2 are equivalent
##
##  that is if there exists a permutation that transforms C1 into C2.
##  If returnperm is true, this permutation (if it exists) is returned;
##  else the function only returns true or false. Has a global dispatcher.
##
InstallMethod(IsEquivalent, "method for unrestricted codes", true, 
	[IsCode, IsCode], 0, 
function (C1, C2 )
    return not IsBool( CodeIsomorphism( C1, C2 ) );
end);


#############################################################################
##
#F  RootsOfCode( <C> )  . . . .  the roots of the generator polynomial of <C>
##
##  It finds the roots by trying all elements of the extension field
##

InstallMethod(RootsOfCode, "method for unrestricted code", true, 
	[IsCode], 0, 
function(C)
    if IsCyclicCode(C) then
        return RootsOfCode(C);
    else
        Error("the roots of a code are only defined for cyclic codes");
    fi;
end);

InstallMethod(RootsOfCode, "method for cyclic code", true, [IsCyclicCode], 0, 
function(C)
    local a, roots, zero, i, t, G;
    G := GeneratorPol(C);
    a := PrimitiveUnityRoot(Size(LeftActingDomain(C)), WordLength(C));
    roots := [];
    zero := 0*a;
    t := a^0;
    for i in [0..WordLength(C)-1] do
        if Value(G, t) = zero then
            Add(roots, t);
        fi;
        t := t * a;
    od;
    return(Set(roots));
end);


#############################################################################
##
#F  DistancesDistribution( <C>, <w> ) . . .  distribution of distances from a
#F                                               word w to all codewords of C
##

InstallMethod(DistancesDistribution, 
	"method for unrestricted code and codeword", 
	true, [IsCode, IsCodeword], 0, 
function(C, w)
    local El;
    if IsLinearCode(C) then
        return DistancesDistribution(C,w);
    fi;
    El := VectorCodeword(AsSSortedList(C));  
    w := VectorCodeword(w);
    return DistancesDistributionVecFFEsVecFFE(El,w);
end);

InstallMethod(DistancesDistribution, "method for linear code and codeword", 
	true, [IsLinearCode, IsCodeword], 0, 
function(C, w)
	local G;
	G := ShallowCopy(GeneratorMat(C));
	w := VectorCodeword(w);
	return DistancesDistributionMatFFEVecFFE(G, LeftActingDomain(C), w);
end);

          
#############################################################################
##
#F  Syndrome( <C>, <c> )  . . . . . . .  the syndrome of word <c> in code <C>
##

InstallMethod(Syndrome, "method for unrestricted code and codeword", true, 
	[IsCode, IsCodeword], 0, 
function(C, c) 
    if not IsLinearCode(C) then
        Error("argument must be a linear code");
    else
        return Syndrome(C,c);
    fi;
end);

InstallMethod(Syndrome, "method for linear code and codeword", true, 
	[IsLinearCode, IsCodeword], 0, 
function(C, c) 
    if CheckMat(C) = [] then
        return [Zero(LeftActingDomain(C))];  
    else
        return CheckMat(C) * Codeword(c,C);
    fi;
end);


#############################################################################
##
#F  CodewordNr( <C>, <i> )  . . . . . . . . . . . . . . . . .  elements(C)[i]
##

InstallMethod(CodewordNr, "method for unrestricted code and position list", 
	true, [IsCode, IsList], 0, 
function(C, l) 
	local returnlist;  
	if IsLinearCode(C) then 
		return CodewordNr(C,l); 
	fi;

	l := Set(l);
	returnlist := (Length(l) > 1);
    if (l[1] < 1) or (l[Length(l)] > Size(C)) then
        Error("range: 1..", String(Size(C)));
    fi;
    if returnlist then
        return AsSSortedList(C){l};
    else
        return Flat(AsSSortedList(C){l})[1];
    fi;
end);

DoCodewordNr:=function(C, l) 
local index, source, i, result, q, returnlist, F, kmin;
    if IsList(l) then
      l := Set(l);
      returnlist:=true;
    else
      l:=[l];
      returnlist:=false;
    fi;
    if (l[1] < 1) or (l[Length(l)] > Size(C)) then
        Error("range: 1..", String(Size(C)));
    fi;
    if HasAsSSortedList(C) then 
        if returnlist then
            return AsSSortedList(C){l};
        else
            return AsSSortedList(C)[l[1]];
        fi;
    else
        result := [];
        q := Size(LeftActingDomain(C));  
        F := LeftActingDomain(C);
        kmin := Dimension(C) - 1;
        for index in l do
            source := [];
            i := index-1;
            while i >= 1 do
                Add(source, i mod q);
                i := Int(i / q);
            od;
            for i in [Length(source)..kmin] do
                Add(source, 0);
            od;
            Add(result, CodewordVector(Reversed(source),C));
        od;
        if returnlist then
            return result;
        else
            return result[1];
        fi;
    fi;
end;

InstallOtherMethod(CodewordNr, "method for unrestricted code and int position", 
	true, [IsCode, IsInt], 0,DoCodewordNr);

InstallMethod(CodewordNr, "method for linear code and position list", true, 
	[IsLinearCode, IsList], 0, DoCodewordNr);


#############################################################################
##
#F  String( <C> ) . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  
##
##  

InstallMethod(String, "method for code", true, [IsCode], 0, 
function(C) 
	return CodeDescription(C); 
end); 


#############################################################################
##
#F  CodeDescription( <C> ) . . . . . . . . . . . . . . . . . . . . . . . . .
##
##

InstallMethod(CodeDescription, "method for an unrestricted code", 
	true, [IsCode], 0, 
function(C) 
    local n, x, lbmd, ubmd, line;
    line := "a";
    if Int(WordLength(C)/(10^LogInt(WordLength(C),10))) = 8 
       or WordLength( C ) = 11 or WordLength( C ) = 18 then
    	Append(line, "n");
    fi;
    Append(line,Concatenation(" (",String(WordLength(C)),",",
            String(Size(C)),","));
    lbmd := String( LowerBoundMinimumDistance(C));
    ubmd := String( UpperBoundMinimumDistance(C));
    if lbmd = ubmd then
		Append(line, lbmd );
	else
		Append( line, Concatenation( lbmd, "..", ubmd ) );
    fi; 
    Append( line, ")" );
	# Call to BoundsCoveringRadius checks HasCoveringRadius first.  
	# No need to repeat here.  Similar for LBMD, UBMD, above.  
	if Length( BoundsCoveringRadius( C ) ) = 1 then
        SetCoveringRadius(C, BoundsCoveringRadius(C)[1]); 
		Append( line, String( BoundsCoveringRadius(C)[ 1 ] ) );
    else
        Append( line, Concatenation( 
                String( BoundsCoveringRadius(C)[ 1 ] ),
                "..",
                String( BoundsCoveringRadius(C)[ 
                        Length( BoundsCoveringRadius(C) ) ] ) ) );
    fi;
    Append( line, " " );
    if not IsBound( C!.name ) then
        C!.name := "unknown unrestricted code";
    fi;
    Append( line, C!.name );
    if not IsBound( C!.history ) then
        Append(line,Concatenation(" over GF(", String(Size(LeftActingDomain(C))),")"));
    fi;
    IsString( line );
    return line;
end);
          
InstallMethod(CodeDescription, "method for linear code", 
	true, [IsLinearCode], 0, 
function(C) 
    local lbmd, ubmd, line;
    line := "a linear [";
    line := Concatenation( line, String(WordLength(C)), ",",
                    String(Dimension(C)), "," );
    lbmd := String( LowerBoundMinimumDistance(C) );
    ubmd := String( UpperBoundMinimumDistance(C) );
    if lbmd = ubmd then
        Append(line, lbmd );
    else
        Append(line,Concatenation( lbmd, "..", ubmd ) );
    fi;
    Append( line, "]" );
	if Length( BoundsCoveringRadius( C ) ) = 1 then
        Append( line, String( BoundsCoveringRadius(C)[ 1 ] ) );
    else
        Append( line, Concatenation( 
                String( BoundsCoveringRadius(C)[ 1 ] ),
                "..",
                String( Maximum( BoundsCoveringRadius(C) ) ) ) );
    fi;
    Append( line, " " );
    if not IsBound( C!.name ) then
        C!.name := "unknown linear code";
    fi;
    Append( line, C!.name );
    if not IsBound( C!.history ) then
        Append(line,Concatenation(" over GF(", String(Size(LeftActingDomain(C))),")"));
    fi;
    IsString( line );
    return line;
end);

InstallMethod(CodeDescription, "method for cyclic codes", 
	true, [IsCyclicCode], 0, 
function(C) 
    local n, x, lbmd, ubmd, line;
    line:="a cyclic [";
    Append( line, Concatenation( String(WordLength(C)), ",",
            String(Dimension(C)), "," ));
	lbmd := String( LowerBoundMinimumDistance(C) );
	ubmd := String( UpperBoundMinimumDistance(C) );
	if lbmd = ubmd then
		Append(line, lbmd );
	else
		Append(line,Concatenation( lbmd, "..", ubmd ) );
	fi; 
    Append( line, "]" );
	if Length( BoundsCoveringRadius( C ) ) = 1 then
		Append( line, String( BoundsCoveringRadius(C)[ 1 ] ) );
    else
        Append( line, Concatenation( 
                String( BoundsCoveringRadius(C)[ 1 ] ),
                "..",
                String( BoundsCoveringRadius(C)[ 
                        Length( BoundsCoveringRadius(C) ) ] ) ) );
    fi;
    Append( line, " " );
    if not IsBound( C!.name ) then
        C!.name := "unknown cyclic code";
    fi;
    Append( line, C!.name );
    if not IsBound( C!.history ) then
        Append(line,Concatenation(" over GF(", String(Size(LeftActingDomain(C))),")"));
    fi;
    IsString( line );
    return line;
end);


#############################################################################
##
#F  Print( <C> )  . . . . . . . . . . . . .  prints short information about C
##
##
InstallMethod(PrintObj, "method for codes", true, [IsCode], 0, 
function(C) 
  if HasCoveringRadius(C) and HasMinimumDistance(C) then 
    Print(String(C));  # sets for future use  
  else 
  Print(CodeDescription(C)); # allows to change as bmd, bcr updated 
  fi; 
end);

InstallMethod(PrintObj, "method for linear code", true, 
	[IsFreeLeftModule and IsLinearCodeRep], 0, 
function(C) 
  if HasCoveringRadius(C) and HasMinimumDistance(C) then 
    Print(String(C));  #sets for future use 
  else 
    Print(CodeDescription(C)); # allows to change as bcr, bmd updated 
  fi; 
end); 

InstallMethod(ViewObj, "method for codes", true, [IsCode], 0, 
function(C) 
  if HasCoveringRadius(C) and HasMinimumDistance(C) then 
    Print(String(C));  # sets for future use  
  else 
    Print(CodeDescription(C)); # allows to change as bcr, bmd updated 
  fi; 
end);

InstallMethod(ViewObj, "method for linear code", true, 
	[IsFreeLeftModule and IsLinearCodeRep], 0, 
function(C) 
  local line;
  if HasCoveringRadius(C) and HasMinimumDistance(C) then 
     Print(String(C));  #sets for future use 
   elif (IsBound(C!.name) and C!.name="random linear code") then 
     line := Concatenation( "a  [", String(WordLength(C)), ",",String(Dimension(C)), "," );
     Append(line,Concatenation( "?] randomly generated code over GF(",String(Size(LeftActingDomain(C))),")") ); 
     Print(line);
   elif (IsBound(C!.name) and C!.name="code defined by generator matrix, NC") then 
     line := Concatenation( "a  [", String(WordLength(C)), ",",String(Dimension(C)), "," );
     Append(line,Concatenation( "?] randomly generated code over GF(",String(Size(LeftActingDomain(C))),")") ); 
     Print(line);
   else
     Print(CodeDescription(C)); # allows to change as bcr, bmd updated  
   fi;
end); 


#############################################################################
##
#F  Display( <C> )  . . . . . . . . . . . .  prints the history of the code C
##
##

InstallMethod(Display, "method for codes", true, [IsCode], 0,  
function(C) 
    local d;
    for d in History(C) do
        Print(d,"\n");
    od;
end);


#############################################################################
##
#F  Save( <filename>, <C>, <var-name> ) . . . . . writes the code C to a file
##
##  with variable name var-name. It can be read back by calling
##  Read (filename); the code then has the name var-name.
##  All fields of the code record are stored except for the operations field
##  and, in case of a linear or cyclic code, the elements.
##  Pre: filename is accessible for writing
##

InstallMethod(Save, "method for unrestricted code", true, 
	[IsString, IsCode, IsString], 0, 
function(filename, C, codename) 
	local fld, attr_list, attr;
    PrintTo(filename, "\n# GUAVA code #\n");
    ##LR - need proper code creation statement here! 
	AppendTo(filename, codename, " := rec(\n");
	attr_list := [CheckMat, CheckPol, CodeDensity, CodeNorm, 
		CoordinateNorm, CoveringRadius, DesignedDistance,
	        Dimension, GeneratorMat, GeneratorPol, 
		GeneratorsOfLeftModule, 
		InnerDistribution, IsAffineCode, IsAlmostAffineCode, 
		IsCyclicCode, IsGriesmerCode, IsLinearCode, 
	        IsMDSCode, IsNormalCode, IsPerfectCode,
		IsSelfComplementaryCode, IsSelfDualCode, 
	        IsSelfOrthogonalCode,
	        LeftActingDomain, MinimumDistance, 
	        MinimumWeightOfGenerators, MinimumWeightWords, 
	        OuterDistribution, Redundancy,
		RootsOfCode, SpecialCoveringRadius, SpecialDecoder, 
		StandardArray, SyndromeTable, 
		UpperBoundOptimalMinimumDistance, 
		WeightDistribution, WordLength ];
	for attr in attr_list do  
		if Tester(attr)(C) then 
			AppendTo(filename, "Set", NameFunction(attr), "(", codename, ", ", 
			attr(C), ");\n"); 
    	fi; 
	od;
    for fld in ["boundsCoveringRadius", "lowerBoundMinimumDistance", 
				"upperBoundMinimumDistance"] do 
		if IsBound(C!.(fld)) then 
			AppendTo(filename, codename, "!.", fld, ":=", C!.(fld), ";\n" ); 
		fi; 
	od; 
	if (not HasIsLinearCode(C)) or (not IsLinearCode(C)) then 
		AppendTo(filename,
			"SetAsSSortedList(", codename, ", ", "Codeword(", 
			VectorCodeword(AsSSortedList(C)),");\n");
    fi; 
	AppendTo(filename, "C!.name := \"", C!.name,"\";\n");
end);


#############################################################################
##
#F  History( <C> )  . . . . . . . . . . . . . . . shows the history of a code
##
InstallMethod(History, "method for codes", true, [IsCode], 0, 
function(C) 
	local s; 
	if not IsBound(C!.history) then 
		return [CodeDescription(C)]; 
	else 
		s := String(Concatenation(CodeDescription(C), " of")); 
		return Concatenation( [s], C!.history); 
	fi;
end); 


######################################################################################
##
#F           MinimumDistanceRandom( <C>, <num>, <s> )
##
## This is a simpler version than Leon's method, which does not put G in st form.
## (this works welland is in some cases faster than the st form one)
## Input: C is a linear code 
##        num is an integer >0 which represents the number of iterations
##        s is an integer between 1 and n which represents the columns considered
##           in the algorithm.
## Output: an integer >= min dist(C), and hopefully equal to it!
##         a codework of that weight
##
## Algorithm: randomly permute the columns of the gen mat G of C
##              by a permutation rho - call new mat Gp
##            break Gp into (A,B), where A is kxs and B is kx(n-s)
##            compute code C_A generated by rows of A
##            find min weight codeword c_A of C_A and w_A=wt(c_A)
##              using AClosestVectorCombinationsMatFFEVecFFECoords
##            extend c_A to a corresponding codeword c_p in C_Gp
##            return c=rho^(-1)(c_p) and wt=wt(c_p)=wt(c)
##
InstallMethod(MinimumDistanceRandom, "attribute method for linear codes", true, 
	[IsLinearCode,IsInt,IsInt], 0, 
function(C,num,s) 
	local A,HasZeroRow,majority,G0, Gp, Gpt, Gt, L, k, n, i, j, m, dimMat, J, d1,M,
	arrayd1, Combo, rows, row, rowSum, G, F, zero, AClosestVec, B, ZZ,  p, numrow0,
        bigwtrow,bigwtvec, x, d, v, ds, vecs,rho,perms,g,newv,pos,rowcombos,v1,v2;
# returns the estimated distance, and corresponding vector of that weight
Print("\n This is a probabilistic algorithm which may return the wrong answer.\n");
	G0 := GeneratorMat(C);
	p:=5; #this seems to be an optimal value
              # it's the max number of rows used in Z to find a small
              # codewd in C_Z
        G := List(G0,ShallowCopy);

	F:=LeftActingDomain(C);
	dimMat := DimensionsMat(G);
	n:=dimMat[2];
	k:=dimMat[1];
        if n=k then 
           C!.lowerBoundMinimumDistance := 1; 
           C!.upperBoundMinimumDistance := 1; 
           return 1; 
        fi; #  added 11-2004
	if s > n-1 then 
            Print("Resetting s to ",n-2," ... \n"); 
            s:=n-k; 
        fi;
	arrayd1:=[n];

        numrow0:=0; # initialize
        perms:=[]; # initialize

   for m in [1..num] do
   ##Permute the columns of C randomly
	Gt := TransposedMat(G);
	Gp := NullMat(n,k);
	L := SymmetricGroup(n);
	rho := Random(L);
	L:=List([1..n],i->OnPoints(i,rho));
	for i in [1..n] do 
		Gp[i] := Gt[L[i]];
	od;
	Gp := TransposedMat(Gp);
        Gp := List(Gp,ShallowCopy);

##generate the matrix A from Gp=(A|B)
	Gpt := TransposedMat(Gp);
	A := NullMat(s,k);
	for i in [1..s] do
		A[i] := Gpt[i];
	od;
	A := TransposedMat(A);

##generate the matrix B from Gp=(A|B)
	Gpt := TransposedMat(Gp);
	B := NullMat(n-s,k);
	for i in [s+1..n] do
		B[i-s] := Gpt[i];
	od;
	B := TransposedMat(B);

	zero := Zero(F)*A[1];
	if (s<n-k and A=Zero(F)*A) then 
           Error("This method fails for these parameters. Try increasing s.\n");
        fi; 
        if (s=n and A=Zero(F)*A) then 
           return 1; 
        fi;                 

## search for all rows of weight p
## J is the list of all triples representing the codeword in C which
## corresponds to AClosestVec[1].

	J := []; #col number of codewords to compute the length of
	for i in [1..p] do
        	AClosestVec:=AClosestVectorCombinationsMatFFEVecFFECoords(A, F, zero, i, 1);
### AClosestVec[1]=ZZ*AClosestVec[2]...
                v1:=AClosestVec[2]*Gp;
                v2:=Permuted(v1,(rho)^(-1));
        	Add(J,[WeightVecFFE(v2),Codeword(v2,n,F),AClosestVec[2]]);
	od;
        ds:=List(J,x->x[1]);
        vecs:=List(J,x->x[2]);
        rowcombos:=List(J,x->x[3]);
        d:=Minimum(ds);
        i:=Position(ds,d);
        arrayd1[m]:=[d,vecs[i],rowcombos[i]];
        perms[m]:=rho;
   od; ## m

   ds:=List(arrayd1,x->x[1]);
   vecs:=List(arrayd1,x->x[2]);
   rowcombos:=List(arrayd1,x->x[3]);
   d:=MostCommonInList(ds);
   pos:=Position(ds,d);
   v:=vecs[pos];
   L:=List([1..n],i->OnPoints(i,perms[pos]^(-1)));
   newv:=Codeword(List(L,i->v[L[i]]));
   return([d,newv]);
end);

