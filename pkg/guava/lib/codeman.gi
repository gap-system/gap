############################################################################
##
#A  codeman.gi              GUAVA library                       Reinald Baart
#A                                                        &Jasper Cramwinckel
#A                                                           &Erik Roijackers
##
##  This file contains functions for manipulating codes
##
#H  @(#)$Id: codeman.gi,v 1.7 2004/12/20 21:26:06 gap Exp $
##
## ConstantWeightSubcode revised 10-23-2004
##
Revision.("guava/lib/codeman_gi") :=
    "@(#)$Id: codeman.gi,v 1.7 2004/12/20 21:26:06 gap Exp $";

#############################################################################
##
#F  DualCode( <C> ) . . . . . . . . . . . . . . . . . . . .  dual code of <C>
##

InstallMethod(DualCode, "generic method for codes", true, [IsCode], 0, 
function(C) 
	local Cnew; 
	if IsCyclicCode(C) or IsLinearCode(C) then  
		return DualCode(C); 
	else 
		Cnew := CheckMatCode(BaseMat(VectorCodeword(AsSSortedList(C))), 
							"dual code", LeftActingDomain(C));
		Cnew!.history := History(C); 
		return(Cnew);
	fi;
end);

InstallMethod(DualCode, "method for linear codes", true, [IsLinearCode], 0, 
function(C) 
	local C1, Pr, n, newwd, wd, oldrow, newrow, i, j, q;
	if IsCyclicCode(C) then  
		return DualCode(C); 
	elif HasGeneratorMat(C) then 
		C1 := CheckMatCode(GeneratorMat(C), "dual code", LeftActingDomain(C)); 
	elif HasCheckMat(C) then 
		C1 := GeneratorMatCode(CheckMat(C), "dual code", LeftActingDomain(C)); 
	else
		Error("No GeneratorMat or CheckMat for C");  
	fi;
	if HasWeightDistribution(C) then 
		n := WordLength(C);  
		wd := WeightDistribution(C);  
		q := Size(LeftActingDomain(C)) - 1;
		newwd := [Sum(wd)];  
		oldrow := List([1..n+1],i->1);  
		newrow := []; 
		for i in [2..n+1] do 
            newrow[1] := Binomial(n, i-1) * q^(i-1);
            for j in [2..n+1] do
                newrow[j] := newrow[j-1] - q * oldrow[j] - oldrow[j-1];
            od;
            newwd[i] := newrow * wd;
            oldrow := ShallowCopy(newrow);
        od;
        SetWeightDistribution(C1, newwd / ((q+1) ^ Dimension(C)) );
        Pr := PositionProperty(WeightDistribution(C1){[2..n+1]}, i-> i <> 0);
        if Pr = false then
            Pr := n;
        fi;
        C1!.lowerBoundMinimumDistance := Pr;
        C1!.upperBoundMinimumDistance := Pr;
    fi;
    C1!.history := History(C);
    return C1;
end);

InstallMethod(DualCode, "method for self dual codes", true,[IsSelfDualCode], 0, 
function(C) 
	return ShallowCopy(C); 
end); 

InstallMethod(DualCode, "method for cyclic codes", true, [IsCyclicCode], 0, 
function(C) 
	local C1, r, n, Pr, wd, q, newwd, oldrow, newrow, i, j;  
    if HasGeneratorPol(C) then
		r := ReciprocalPolynomial(GeneratorPol(C),Redundancy(C));
		r := r/LeadingCoefficient(r);
		C1 := CheckPolCode(r, WordLength(C), "dual code", LeftActingDomain(C));
	elif HasCheckPol(C) then
		r := ReciprocalPolynomial(CheckPol(C),Dimension(C));
		r := r/LeadingCoefficient(r);
		C1 := GeneratorPolCode(r, WordLength(C), "dual code", 
								LeftActingDomain(C));
	else 
		Error("No GeneratorPol or CheckPol for C"); 
	fi;
	if HasWeightDistribution(C) then
		n := WordLength(C);
		wd := WeightDistribution(C);
		q := Size(LeftActingDomain(C)) - 1;
		newwd := [Sum(wd)];
		oldrow := List([1..n+1], i->1);
		newrow := [];
		for i in [2..n+1] do
			newrow[1] := Binomial(n, i-1) * q^(i-1);
			for j in [2..n+1] do
				newrow[j] := newrow[j-1] - q * oldrow[j] - oldrow[j-1];
			od;
            newwd[i] := newrow * wd;
			oldrow := ShallowCopy(newrow);
		od;
		SetWeightDistribution(C1, newwd / ((q+1) ^ Dimension(C)));
	    Pr := PositionProperty(WeightDistribution(C1){[2..n+1]}, i-> i <> 0);
	    if Pr = false then
	         Pr := n;
	    fi;
	    C1!.lowerBoundMinimumDistance := Pr;
	    C1!.upperBoundMinimumDistance := Pr;
	fi;
	C1!.history := History(C);
	return C1;
end); 


#############################################################################
##
#F  AugmentedCode( <C> [, <L>] )  . . .  add words to generator matrix of <C>
##

InstallMethod(AugmentedCode, "unrestricted code and codeword list/object", 
	true, [IsCode, IsObject], 0, 
function (C, L) 
	if IsLinearCode(C) then 
		return AugmentedCode(C, L); 
	else 
		Error("argument must be a linear code"); 
	fi; 
end); 

InstallOtherMethod(AugmentedCode, "unrestricted code", true, [IsCode], 0, 
function(C) 
	return AugmentedCode(C, NullMat(1, WordLength(C), LeftActingDomain(C)) 
								+ One(LeftActingDomain(C))); 
end); 

InstallMethod(AugmentedCode, "linear code and codeword object/list", 
	true, [IsCode, IsObject], 0, 
function (C, L) 
    local Cnew;  
	L := VectorCodeword(Codeword(L, C) );
	if not IsList(L[1]) then
		L := [L];
	else
		L := Set(L);
	fi;
    Cnew := GeneratorMatCode(BaseMat(Concatenation(GeneratorMat(C),L)),
                 Concatenation("code, augmented with ", String(Length(L)),
                         " word(s)"), LeftActingDomain(C));
    if Length(GeneratorMat(Cnew)) > Dimension(C) then
        Cnew!.upperBoundMinimumDistance := Minimum(
                 UpperBoundMinimumDistance(C),
                 Minimum(List(L, l-> Weight(Codeword(l)))));
        Cnew!.history := History(C);
        return Cnew;
    else
        return ShallowCopy(C);
    fi;
end);


#############################################################################
##
#F  EvenWeightSubcode( <C> )  . . .  code of all even-weight codewords of <C>
##

InstallMethod(EvenWeightSubcode, "method for unrestricted codes", true, 
	[IsCode], 0, 
function(Cold) 
	local C, n, Els, E, d, i, s, q, wd;  

	if IsCyclicCode(Cold) or IsLinearCode(Cold) then    
		return EvenWeightSubcode(Cold); 
	fi;  

    q := Size(LeftActingDomain(Cold));
    n := WordLength(Cold);
    Els := AsSSortedList(Cold); 
    E := []; 
	s := 0;
    for i in [1..Size(Cold)] do
        if IsEvenInt(Weight(Els[i])) then
            Append(E, [Els[i]]);
            s := s + 1;
        fi;
    od;
    if s <> Size(Cold) then
        C := ElementsCode( E, "even weight subcode", GF(q) );
        d := [LowerBoundMinimumDistance(Cold),
              UpperBoundMinimumDistance(Cold)];
        for i in [1..2] do 
            if q=2 and IsOddInt(d[i] mod 2) then
                d[i] := Minimum(d[i]+1,n);
            fi;
        od;
        C!.lowerBoundMinimumDistance := d[1];
        C!.upperBoundMinimumDistance := d[2];
        if HasWeightDistribution(Cold) then
            wd := ShallowCopy(WeightDistribution(Cold));
            for i in [1..QuoInt(n+1,2)] do 
                wd[2*i] := 0;
            od;
        	SetWeightDistribution(C, wd);
		fi;
        C!.history := History(Cold);
        return C;
    else
        return ShallowCopy(Cold);
    fi;
end);

InstallMethod(EvenWeightSubcode, "method for linear codes", true, 
	[IsLinearCode], 0, 
function(Cold) 
    local C, P, edited, n, G, Els, E, i, s,q, Gold, wd, lbmd;
    if IsCyclicCode(Cold) then    
		return EvenWeightSubcode(Cold); 
	fi; 
	q := Size(LeftActingDomain(Cold));
    n := WordLength(Cold);
    edited := false;
    if q = 2 then
        # Why is the next line needed?
        P := NullVector(n, GF(2));
        G := [];
        Gold := GeneratorMat(Cold);
        for i in [1..Dimension(Cold)] do
            if Weight(Codeword(Gold[i])) mod 2 <> 0 then
                if not edited then
                    P := Gold[i];
                    edited := true;
                else
                    Append(G, [Gold[i]+P]);
                fi;
            else
                Append(G, [Gold[i]]);
            fi;
        od;
        if edited then
            C := GeneratorMatCode(BaseMat(G),"even weight subcode",GF(q));
        fi;
    else
        Els := AsSSortedList(Cold);   
        E := []; s := 0;
        for i in [1..Size(Cold)] do
            if IsEvenInt(Weight(Els[i])) then
                Append(E, [Els[i]]);
                s := s + 1;
            fi;
        od;
        edited := (s <> Size(Cold));
        if edited then
            C := ElementsCode(E, "even weight subcode", GF(q) );
        fi;
    fi;

    if edited then
        lbmd := Minimum(n, LowerBoundMinimumDistance(Cold));
        if q = 2 and IsOddInt(lbmd) then
            lbmd := lbmd + 1;
        fi;
        C!.lowerBoundMinimumDistance := lbmd; 
		if HasWeightDistribution(Cold) then
            wd := ShallowCopy(WeightDistribution(Cold));
            for i in [1..QuoInt(n+1,2)] do 
                wd[2*i] := 0;
            od;
			SetWeightDistribution(C, wd);  
		fi; 
		C!.history := History(Cold);
        return C;
    else
        return ShallowCopy(Cold);
    fi;
end);

##LR See co'd roots stuff, nd reinstate sometime. 
InstallMethod(EvenWeightSubcode, "method for cyclic codes", true, 
	[IsCyclicCode], 0, 
function(Cold) 
    local C, P, edited, n, Els, E, i, q, lbmd, wd;
    q := Size(LeftActingDomain(Cold));
    n := WordLength(Cold);
    edited := false;
    if (q =2) then
        P := Indeterminate(GF(2))-One(GF(2));  
        if Gcd(P, GeneratorPol(Cold)) <> P then
            C := GeneratorPolCode( GeneratorPol(Cold)*P, n,
                         "even weight subcode", LeftActingDomain(Cold));
            #if IsBound(C.roots) then
            #    AddSet(C.roots, Z(2)^0);
            #fi;
            edited := true;
        fi;
    else
        Els := AsSSortedList(Cold);
        E := [];
        for i in [1..Size(Cold)] do
            if IsEvenInt(Weight(Els[i])) then
                Append(E, [Els[i]]);
            else
                edited := true;
            fi;
        od;
        if edited then
            C := ElementsCode(E, "even weight subcode", LeftActingDomain(Cold));
        fi;
    fi;

    if edited then
        lbmd := Minimum(n, LowerBoundMinimumDistance(Cold)); 
        if q = 2 and IsOddInt(lbmd) then
            lbmd := lbmd + 1;
        fi;
        C!.lowerBoundMinimumDistance := lbmd;  
		if HasWeightDistribution(Cold) then
            wd := ShallowCopy(WeightDistribution(Cold));
            for i in [1..QuoInt(n+1,2)] do 
                wd[2*i] := 0;
            od;
        	SetWeightDistribution(C, wd);  
		fi;
        C!.history := History(Cold);
        return C;
    else
        return ShallowCopy(Cold);
    fi;
end);


#############################################################################
##
#F  ConstantWeightSubcode( <C> [, <w>] )  .  all words of <C> with weight <w>
##

InstallMethod(ConstantWeightSubcode, "method for unrestricted code, weight", 
	true, [IsCode, IsInt], 0, 
function(C, wt) 
  local D, Els,path;  
  if IsLinearCode(C) then 
	return ConstantWeightSubcode(C, wt); 
  fi; 
  Els := Filtered(AsSSortedList(C), c -> Weight(c) = wt); 
  if Els <> [] then 
    D := ElementsCode(Els, Concatenation( "code with codewords of weight ", String(wt)), LeftActingDomain(C) ); 
    D!.lowerBoundMinimumDistance := LowerBoundMinimumDistance(C); 
    D!.history := History(C); 
    return D; 
   else 
    Error("no words of weight", wt); 
  fi; 
end); 

InstallOtherMethod(ConstantWeightSubcode, "method for unrestricted code", 
	true, [IsCode], 0, 
function(C) 
  local wt; 
  if IsLinearCode(C) then 
	return ConstantWeightSubcode(C, MinimumDistance(C)); 
  fi; 
  wt := PositionProperty(WeightDistribution(C){[2..WordLength(C)+1]}, i-> i > 0); 
  if wt = false then 
	wt := WordLength(C); 
  fi; 
 return ConstantWeightSubcode(C, wt); 
end); 

InstallMethod(ConstantWeightSubcode, "method for linear code, weight", true, 
	[IsLinearCode, IsInt], 0, 
function(C, wt) 
    local S, c, a, CWS, path, F, tmpdir, incode, infile, inV, Els, i, D;
    a:=wt;
    if wt = 0 then
        return NullCode(WordLength(C), LeftActingDomain(C));
    fi;
    if Dimension(C) = 0 then
        Error("no constant weight subcode of a null code is defined");
    fi;

      path := DirectoriesPackagePrograms( "guava" );

      if ForAny( ["desauto", "leonconv", "wtdist"], 
                 f -> Filename( path, f ) = fail ) then
##  begin if-then
	  Print("the C code programs are not compiled, so using GAP code...\n");
	  F:=LeftActingDomain(C);
	  S:=[];
	  for c in Elements(C) do
	   if WeightCodeword(c)=a then
	     S:=Concatenation([c],S); 
	   fi;
	  od;
	  CWS:=ElementsCode(S,"constant weight subcode",F);
	  CWS!.lowerBoundMinimumDistance:=a;
	  CWS!.upperBoundMinimumDistance:=a;
	  return CWS;
## end if-then
else 
	 Print("the C code programs are compiled, so using Leon's binary....\n");

 tmpdir := DirectoryTemporary();;
 incode := TmpName();
 PrintTo( incode, "\n" );
# inV := TmpName(); 
# PrintTo( inV, "\n" );
 infile := TmpName();
 PrintTo( infile, "\n" );
 GuavaToLeon(C, incode);
 Exec(Filename(DirectoriesPackagePrograms("guava"), "wtdist"), 
            Concatenation("-q ",incode,"::code ",
            String(wt), " ", Filename( tmpdir, "cwsc.txt" ),"::code"));  
 if IsReadableFile( Filename( tmpdir, "cwsc.txt" )) then
      inV := Filename( tmpdir, "cwsc.txt" );  
      Exec(Filename(DirectoriesPackagePrograms("guava"), "leonconv"), 
            Concatenation("-c ",inV," ",infile));  
  else  
      Error("\n Sorry, no codes words of weight ",wt,"\n");
 fi;
 Read(infile);
 RemoveFiles(incode,inV,infile);
 Els := [];
 for i in AsSSortedList(LeftActingDomain(C)){[2..Size(LeftActingDomain(C))]} do
        Append(Els, i * GUAVA_TEMP_VAR);
 od;
 if Els <> [] then
        D := ElementsCode(Els, Concatenation( "code with codewords of weight ",
                String(wt)), LeftActingDomain(C) );
        D!.lowerBoundMinimumDistance := LowerBoundMinimumDistance(C);
        D!.history := History(C);
        return D;
    else
        Error("no words of weight ",wt);
        Print("\n no words of weight ",wt);
 fi;
fi; ## end if-then-else
end);

InstallOtherMethod(ConstantWeightSubcode, "method for linear code", true, 
	[IsLinearCode], 0, 
function(C) 
	return ConstantWeightSubcode(C, MinimumDistance(C)); 
end); 


#############################################################################
##
#F  ExtendedCode( <C> [, <i>] ) . . . . . code with added parity check symbol
## 

InstallMethod(ExtendedCode, "method to extend unrestricted code i times", true, 
	[IsCode, IsInt], 0, 
function(Cold, nrcolumns) 
	local n, q, zeros, elements, word, vec, lbmd, ubmd, i, indist, wd, C;  
	if nrcolumns < 1 then 
		return ShallowCopy(Cold);
	elif IsLinearCode(Cold) then    
		return ExtendedCode(Cold,nrcolumns);
	fi;

    n := WordLength(Cold)+1;
    q := Size(LeftActingDomain(Cold));
    zeros:= List( [ 2 .. nrcolumns ], i-> Zero(LeftActingDomain(Cold)) );
    elements := [];
    for word in AsSSortedList(Cold) do
        vec := VectorCodeword(word); 
        Add(elements, Codeword(Concatenation(vec, [-Sum(vec)], zeros)));
        
    od;
    C := ElementsCode( elements, "extended code", q );
    lbmd := LowerBoundMinimumDistance(Cold);
    ubmd := UpperBoundMinimumDistance(Cold);
    if q = 2 then
        if lbmd mod 2 = 1 then
            lbmd := lbmd + 1;
        fi;
        if ubmd mod 2 = 1 then
            ubmd := ubmd + 1;
        fi;
        C!.lowerBoundMinimumDistance := lbmd;  
		C!.upperBoundMinimumDistance := ubmd; 
		if HasInnerDistribution(Cold) then
            indist := NullVector(n+1);
            indist[1] := InnerDistribution(Cold)[1];
            for i in [1 .. QuoInt( WordLength(Cold), 2 ) ] do
                indist[i*2+1]:= InnerDistribution(Cold)[i*2+1]+
                                    InnerDistribution(Cold)[i*2];
            od;
            if IsOddInt(WordLength(Cold)) then
                indist[WordLength(Cold) + 2] := 
                  InnerDistribution(Cold)[WordLength(Cold) + 1];
            fi;
        	SetInnerDistribution(C, indist); 
		fi;
        if HasWeightDistribution(Cold) then
            wd := NullVector( n + 1);
            wd[1] := WeightDistribution(Cold)[1];
            for i in [1 .. QuoInt( WordLength(Cold), 2 ) ] do
                wd[i*2+1]:= WeightDistribution(Cold)[i*2+1]+
                                WeightDistribution(Cold)[i*2];
            od;
            if IsOddInt(WordLength(Cold)) then
                wd[WordLength(Cold) + 2] := 
                  WeightDistribution(Cold)[WordLength(Cold) + 1];
            fi;
        	SetWeightDistribution(C, wd); 
		fi;
        if IsBound(Cold!.boundsCoveringRadius)
           and Length( Cold!.boundsCoveringRadius ) = 1 then
            C!.boundsCoveringRadius :=  
              [ Cold!.boundsCoveringRadius[ 1 ] + nrcolumns ];
        fi;
    else
        C!.upperBoundMinimumDistance := UpperBoundMinimumDistance(Cold) + 1;
    fi;
    C!.history := History(Cold);
    return C;
end);

InstallOtherMethod(ExtendedCode, "method for unrestricted code", 
	true, [IsCode], 0, 
function(C) 
	return ExtendedCode(C, 1); 
end); 

InstallMethod(ExtendedCode, "method to extend linear code i times", true, 
	[IsLinearCode, IsInt], 0, 
function(Cold, nrcolumns) 
    local C, G, word, zeros, i, n, q, lbmd, ubmd, wd;
	if nrcolumns < 1 then 
		return ShallowCopy(C); 
	fi; 
	
    n := WordLength(Cold) + nrcolumns;
    zeros := List( [2 .. nrcolumns], i-> Zero(LeftActingDomain(Cold)) );
    q := Size(LeftActingDomain(Cold));
    G := List(GeneratorMat(Cold), i-> ShallowCopy(i));
    for word in G do
        Add(word, -Sum(word));
        Append(word, zeros);
    od;
    C := GeneratorMatCode(G, "extended code", q);
    lbmd := LowerBoundMinimumDistance(Cold);
    ubmd := UpperBoundMinimumDistance(Cold);
    if q = 2 then
        if IsOddInt( lbmd ) then
            lbmd := lbmd + 1;
        fi;
        if IsOddInt( ubmd ) then
            ubmd := ubmd + 1;
        fi;
        C!.lowerBoundMinimumDistance := lbmd; 
		C!.upperBoundMinimumDistance := ubmd; 
		if HasWeightDistribution(Cold) then
            wd := NullVector(n + 1);
            wd[1] := 1;
            for i in [ 1 .. QuoInt( WordLength(Cold), 2 ) ] do
                wd[i*2+1]:=WeightDistribution(Cold)[i*2+1]+
                                 WeightDistribution(Cold)[i*2];
            od;
            if IsOddInt(WordLength(Cold)) then
                wd[WordLength(Cold) + 2] := 
                  WeightDistribution(Cold)[WordLength(Cold) + 1];
            fi;
        	SetWeightDistribution(C, wd); 
		fi;
        if IsBound(Cold!.boundsCoveringRadius)
           and Length( Cold!.boundsCoveringRadius ) = 1 then
            C!.boundsCoveringRadius :=  
              [ Cold!.boundsCoveringRadius[ 1 ] + nrcolumns ];
        fi;
    else
        C!.upperBoundMinimumDistance := UpperBoundMinimumDistance(Cold) + 1;
    fi;
    C!.history := History(Cold);
    return C;
end);


#############################################################################
##
#F  ShortenedCode( <C> [, <L>] )  . . . . . . . . . . . . . .  shortened code
##
## 

InstallMethod(ShortenedCode, "Method for unrestricted code, position list", 
	true, [IsCode, IsList], 0, 
function(C, L) 
    local Cnew, i, e, zero, q, baseels, element, max, number, 
          temp, els, n;
	if IsLinearCode(C) then 
		return ShortenedCode(C,L);  
	fi; 
	L := Reversed(Set(L));
    zero := Zero(LeftActingDomain(C));
    baseels := AsSSortedList(LeftActingDomain(C));  
    q := Size(LeftActingDomain(C));
    els := VectorCodeword(AsSSortedList(C));
    for i in L do
        temp := List(els, x -> x[i]);
        max := 0;
        for e in baseels do
            number := Length(Filtered(temp, x -> x=e));
            if number > max then
                max := number;
                element := e;
            fi;
        od;
        temp := [];
        n := Length(els[1]);
        for e in els do
            if e[i] = element then
                Add(temp,Concatenation(e{[1..i-1]},e{[i+1..n]}));
            fi;
            els := temp;
        od;
    od;
    Cnew := ElementsCode(temp, "shortened code", LeftActingDomain(C));
    Cnew!.history := History(C);
    Cnew!.lowerBoundMinimumDistance := Minimum(LowerBoundMinimumDistance(C),
                                              WordLength(Cnew));
    return Cnew;
end);

InstallOtherMethod(ShortenedCode, "method for unrestricted code, int position", 
	true, [IsCode, IsInt], 0, 
function(C, i) 
	return ShortenedCode(C, [i]); 
end); 

InstallOtherMethod(ShortenedCode, "method for unrestricted code", true, 
	[IsCode], 0, 
function(C) 
	return ShortenedCode(C, [1]); 
end); 

InstallMethod(ShortenedCode, "method for linear code and position list", 
	true, [IsLinearCode, IsList], 0, 
function(C, L) 
	local Cnew, G, i, e, zero, q, baseels, temp, n;  
	L := Reversed(Set(L));
    zero := Zero(LeftActingDomain(C)); 
    baseels := AsSSortedList(LeftActingDomain(C));
    q := Size(LeftActingDomain(C));
    G := ShallowCopy(GeneratorMat(C));
    for i in L do
        e := 0;
        repeat
            e := e + 1;
        until (e > Length(G)) or (G[e][i] <> zero);
        if G <> [] then 
            n := Length(G[1]);
        else
            n := WordLength(C);
        fi;
        if e <= Length(G) then
            temp := G[e];
            G := Concatenation(G{[1..e-1]},G{[e+1..Length(G)]});
            G := List(G, x-> x - temp * (x[i] / temp[i]));
        fi;
        G := List(G, x->Concatenation(x{[1..i-1]},x{[i+1..n]}));
        if G = [] then 
            return NullCode(WordLength(C)-Length(L), LeftActingDomain(C));
        fi;
    od;
    Cnew := GeneratorMatCode(BaseMat(G), "shortened code", LeftActingDomain(C));
    Cnew!.history := History(C);
    Cnew!.lowerBoundMinimumDistance := Minimum(LowerBoundMinimumDistance(C),
                                              WordLength(Cnew));
	if IsCyclicCode(C) then 
		Cnew!.upperBoundMinimumDistance := Minimum(WordLength(Cnew),  
											UpperBoundMinimumDistance(C)); 

	fi; 
	return Cnew;
end);


#############################################################################
##
#F  PuncturedCode( <C> [, <list>] ) . . . . . . . . . . . . .  punctured code
##
##  PuncturedCode(C [, remlist]) punctures a code by leaving out the
##  coordinates given in list remlist. If remlist is omitted, then
##  the last coordinate will be removed.
##

InstallMethod(PuncturedCode, 
	"method for unrestricted codes, position list provided", 
	true, [IsCode, IsList], 0, 
function(Cold, remlist) 
	local keeplist, n, C;  
	if IsLinearCode(Cold) then 
		return PuncturedCode(Cold, remlist); 
	fi;
	n := WordLength(Cold);
	remlist := Set(remlist);
	keeplist := [1..n];
	SubtractSet(keeplist, remlist);
    C := ElementsCode(
                 VectorCodeword(Codeword( 
				 	AsSSortedList(Cold))){[1 .. Size(Cold)]}{keeplist},
                 "punctured code", LeftActingDomain(Cold));
    C!.history := History(Cold);
    C!.lowerBoundMinimumDistance := Maximum(LowerBoundMinimumDistance(Cold) -
                                           Length(remlist), 1);
    C!.upperBoundMinimumDistance := Minimum( Maximum( 1,
                                           UpperBoundMinimumDistance(Cold) ), 
                                           n-Length(remlist));
    return C;
end);

InstallOtherMethod(PuncturedCode, 
	"method for unrestricted codes, int position provided", 
	true, [IsCode, IsInt], 0, 
function(C, n) 
	return PuncturedCode(C, [n]); 
end); 

InstallOtherMethod(PuncturedCode, "method for unrestricted codes", true, 
	[IsCode], 0, 
function(C) 
	return PuncturedCode(C, [WordLength(C)]);  
end); 

InstallMethod(PuncturedCode, "method for linear codes, position list provided", 
	true, [IsLinearCode, IsList], 0, 
function(Cold, remlist)  
	local C, keeplist, n;  
	n := WordLength(Cold);
	remlist := Set(remlist);
	keeplist := [1..n];
	SubtractSet(keeplist, remlist);
    C := GeneratorMatCode(
                 GeneratorMat(Cold){[1..Dimension(Cold)]}{keeplist},
                 "punctured code", LeftActingDomain(Cold) );
    C!.history := History(Cold);
    C!.lowerBoundMinimumDistance := Maximum(LowerBoundMinimumDistance(Cold) -
                                           Length(remlist), 1);
	
# Cyclic codes always have at least one codeword with minimal weight in the
# i-th column (for every i), so if you remove a column, that word has a
# weight of one less -> the minimumdistance is reduced by one
	if IsCyclicCode(Cold) then 
		C!.upperBoundMinimumDistance := Minimum( Maximum( 1,
									   UpperBoundMinimumDistance(Cold)-1),
									   n - Length(remlist) );
	else 
		C!.upperBoundMinimumDistance := Minimum( Maximum( 1, 
                                           UpperBoundMinimumDistance(Cold) ), 
                                           n - Length(remlist));
    fi; 
	return C;
end);


#############################################################################
##
#F  ExpurgatedCode( <C>, <L> )  . . . . .  removes codewords in <L> from code
##
##  The usual way of expurgating a code is removing all words of odd weight.
##

InstallMethod(ExpurgatedCode, "method for unrestricted codes, codeword list", 
	true, [IsCode, IsList], 0, 
function(C, L) 
	if IsLinearCode(C) then 
		return ExpurgatedCode(C, L);  
	else 
		Error("can't expurgate a non-linear code; ",
			  "consider using RemovedElementsCode"); 
	fi; 
end); 

InstallOtherMethod(ExpurgatedCode, "method for unrestricted code, codeword", 
	true, [IsCode, IsCodeword], 0, 
function(C, w) 
	return ExpurgatedCode(C, [w]); 
end); 

InstallOtherMethod(ExpurgatedCode, "method for unrestricted code", true, 
	[IsCode], 0, 
function(C) 
	if IsLinearCode(C) then 
		return ExpurgatedCode(C); 
	else 
		Error("can't expurgate a non-linear code; "); 
	fi; 
end); 

InstallMethod(ExpurgatedCode, "method for linear code, codeword list", 
	true, [IsLinearCode, IsList], 0, 
function(Cold, L) 
    local C, num, H, F;
	L := VectorCodeword( L );
	L := Set(L);
    F := LeftActingDomain(Cold);
    L := Filtered(L, l-> Codeword(l) in Cold);
    H := List(L, function(l)
        local V,p;
        V := NullVector(WordLength(Cold), F);
        p := PositionProperty(l, i-> not (i = Zero(F)));
        if not (p = false) then
            V[p] := One(F);
        fi;
        return V;
    end);
	H := BaseMat(Concatenation(CheckMat(Cold), H));
    num := Length(H) - Redundancy(Cold);
    if num > 0 then
        C := CheckMatCode( H, Concatenation("code, expurgated with ",
                     String(num), " word(s)"), F);
        C!.lowerBoundMinimumDistance := LowerBoundMinimumDistance(Cold);
        C!.history := History(Cold);
        return C;
    else
        return ShallowCopy(Cold);
    fi;
end);

InstallOtherMethod(ExpurgatedCode, "method for linear code", true, 
	[IsLinearCode], 0, 
function(C) 
	local C2; 
	C2 := EvenWeightSubcode(C); 
	##LR - prob if C2 not lin.  Try on DualCode(RepetitionCode(5, GF(3))) 
	if Dimension(C2) = Dimension(C) then 
		## No words of odd weight, so expurgate by removing first row of 
		## generator matrix. 
		return ExpurgatedCode(C, Codeword(GeneratorMat(C)[1])); 
	else 
		return C2; 
	fi; 
end); 


#############################################################################
##
#F  AddedElementsCode( <C>, <L> ) . . . . . . . . . .  adds words in list <L>
##

InstallMethod(AddedElementsCode, "method for unrestricted code, codeword list", 
	true, [IsCode, IsList], 0, 
function(C, L) 
    local Cnew, e, w, E, CalcWD, wd, num;
    L := VectorCodeword( L );
	L := Set(L);
    E := ShallowCopy(VectorCodeword(AsSSortedList(C)));
    if HasWeightDistribution(C) then
        wd := ShallowCopy(WeightDistribution(C));
        CalcWD := true;
    else
        CalcWD := false;
    fi;
    num := 0;
    for e in L do
        if not (e in C) then
            Add(E, e);
            num := num + 1;
            if CalcWD then
                w := Weight(Codeword(e)) + 1;
                wd[w] := wd[w] + 1;
            fi;
        fi;
    od;
    if num > 0 then
        Cnew := ElementsCode(E, Concatenation( "code with ", String(num),
                " word(s) added"), LeftActingDomain(C));
        if CalcWD then
            SetWeightDistribution(Cnew, wd); 
        fi;
        Cnew!.history := History(C);
        return Cnew;
    else
        return ShallowCopy(C);
    fi;
end);

InstallOtherMethod(AddedElementsCode, "method for unrestricted code, codeword", 
	true, [IsCode, IsCodeword], 0, 
function(C, w) 
	return AddedElementsCode(C, [w]); 
end); 


#############################################################################
##
#F  RemovedElementsCode( <C>, <L> ) . . . . . . . . removes words in list <L>
##

InstallMethod(RemovedElementsCode, 
	"method for unrestricted code, codeword list", 
	true, [IsCode, IsList], 0, 
function(C, L) 
    local E, E2, e, num, s, CalcWD, wd, w, Cnew;
    L := VectorCodeword( L );
    E := Set(VectorCodeword(AsSSortedList(C)));
    E2 := [];
    if HasWeightDistribution(C) then
        wd := ShallowCopy(WeightDistribution(C));
        CalcWD := true;
    else
        CalcWD := false;
    fi;
    for e in E do
        if not (e in L) then
            Add(E2, e);
        elif CalcWD then
            w := Weight(Codeword(e)) + 1;
            wd[w] := wd[w] - 1;
        fi;
    od;
    num := Size(E) - Size(E2);
    if num > 0 then
        Cnew := ElementsCode(E2, Concatenation( "code with ", String(num),
                " word(s) removed"), LeftActingDomain(C) );
        if CalcWD then
            SetWeightDistribution(Cnew, wd);
        fi;
        Cnew!.history := History(C);
        Cnew!.lowerBoundMinimumDistance := LowerBoundMinimumDistance(C);
        return Cnew;
    else
        return ShallowCopy(C);
    fi;
end);

InstallOtherMethod(RemovedElementsCode, 
	"method for unrestricted code, codeword", 
	true, [IsCode, IsCodeword], 0, 
function(C, w) 
	return RemovedElementsCode(C, [w]); 
end); 


#############################################################################
##
#F  LengthenedCode( <C> [, <i>] ) . . . . . . . . . . . . . .  lengthens code
##

InstallMethod(LengthenedCode, "method for unrestricted code, number of columns",
	true, [IsCode, IsInt], 0, 
function(C, nrcolumns) 
    local Cnew;
    Cnew := ExtendedCode(AugmentedCode(C), nrcolumns);
    Cnew!.history := History(C);
    Cnew!.name := Concatenation("code, lengthened with ",String(nrcolumns),
            " column(s)");
    return Cnew;
end);

InstallOtherMethod(LengthenedCode, "unrestricted code", true, [IsCode], 0,  
function(C) 
	return LengthenedCode(C, 1); 
end); 


#############################################################################
##
#F  ResidueCode( <C> [, <w>] )  . .  takes residue of <C> with respect to <w>
##
##  If w is omitted, a word from C of minimal weight is used
##

InstallMethod(ResidueCode, "method for unrestricted code, codeword", true, 
	[IsCode, IsCodeword], 0, 
function(C, w) 
	if not IsLinearCode(C) then 
		Error("argument must be a linear code"); 
	else 
		return ResidueCode(C, w); 
	fi; 
end); 

InstallOtherMethod(ResidueCode, "method for unrestricted code", true, 
	[IsCode], 0, 
function(C) 
	if not IsLinearCode(C) then 
		Error("argument must be a linear code"); 
	else 
		return ResidueCode(C); 
	fi; 
end); 

InstallOtherMethod(ResidueCode, "method for linear code", true, 
	[IsLinearCode], 0, 
function(C) 
    local w, i, d;
	d := MinimumDistance(C);
	i := 2;
	while Weight(CodewordNr(C, i)) > d do
		i := i + 1;
	od;
	w := CodewordNr(C, i);
    return ResidueCode(C, w);
end);

InstallMethod(ResidueCode, "method for linear code, codeword", true, 
	[IsLinearCode, IsCodeword], 0, 
function(C, w) 
    local Cnew, q, d;
    if Weight(w) = 0 then 
		Error("word of weight 0 is not allowed"); 
	elif Weight(w) = WordLength(C) then 
		Error("all-one word is not allowed"); 
	fi; 
	Cnew := PuncturedCode(ExpurgatedCode(C, w), Support(w));
    q := Size(LeftActingDomain(C));
    d := MinimumDistance(C) - Weight(w) * ( (q-1) / q );
    if not IsInt(d) then
        d := Int(d) + 1;
    fi;
    Cnew!.lowerBoundMinimumDistance := d;
    Cnew!.history := History(C);
    Cnew!.name := "residue code";
    return Cnew;
end);


#############################################################################
##
#F  ConstructionBCode( <C> )  . . . . . . . . . . .  code from construction B
##
##  Construction B (See M&S, Ch. 18, P. 9) assumes that the check matrix has
##  a first row of weight d' (the dual distance of C). The new code has a
##  check matrix equal to this matrix, but with columns removed where the
##  first row is 1.
##

InstallMethod(ConstructionBCode, "method for unrestricted codes", true, 
	[IsCode], 0, 
function(C)  
	if LeftActingDomain(C) <> GF(2) then 
		Error("only valid for binary codes"); 
	elif IsLinearCode(C) then   
		return ConstructionBCode(C);  
	else 
		Error("only valid for linear codes");  
	fi; 
end); 

InstallMethod(ConstructionBCode, "method for linear codes", true, 
	[IsLinearCode], 0, 
function(C) 
    local i, H, dd, M, mww, Cnew, DC, keeplist;
	if LeftActingDomain(C) <> GF(2) then
		Error("only valid for binary codes");
	fi;
	DC := DualCode(C);
    H := ShallowCopy(GeneratorMat(DC));        # is check matrix of C
    M := Size(DC);
    dd := MinimumDistance(DC);          # dual distance of C
    i := 2;
    repeat
        mww := CodewordNr(DC, i);
        i := i + 1;
    until Weight(mww) = dd;
    i := i - 2;
    keeplist := Set([1..WordLength(C)]);
    SubtractSet(keeplist, Support(mww));
    mww := VectorCodeword(mww);
    # make sure no row dependencies arise;
    H[Redundancy(C)-LogInt(i, Size(LeftActingDomain(C)))] := mww;
    H := List(H, h -> h{keeplist});
    Cnew := CheckMatCode(H, Concatenation("Construction B (",String(dd),
            " coordinates)"), LeftActingDomain(C));
    Cnew!.lowerBoundMinimumDistance := LowerBoundMinimumDistance(C);
    Cnew!.history := History(DC);
    return Cnew;
end);


#############################################################################
##
#F  PermutedCode( <C>, <P> )  . . . . . . . permutes coordinates of codewords
##

InstallMethod(PermutedCode, "method for unrestricted codes", true, 
	[IsCode, IsPerm], 0, 
function(Cold, P) 
	local C, field, fields;  
	if IsCyclicCode(Cold) or IsLinearCode(Cold) then 
		return PermutedCode(Cold, P); 
	fi; 

    C := ElementsCode(
				PermutedCols(VectorCodeword(Codeword(AsSSortedList(Cold))), P),
                "permuted code", LeftActingDomain(Cold));
    # Copy the fields that stay the same:
    fields := [WeightDistribution, InnerDistribution, IsPerfectCode, 
				IsSelfDualCode, MinimumDistance, CoveringRadius]; 
	for field in fields do 
		if Tester(field)(Cold) then 
			Setter(field)(C, field(Cold)); 
		fi; 
	od; 
	fields := ["lowerBoundMinimumDistance", "upperBoundMinimumDistance", 
				"boundsCoveringRadius"]; 
	for field in fields do 
		if IsBound(Cold!.(field)) then 
			C!.(field) := Cold!.(field); 
		fi; 
	od; 
	C!.history := History(Cold);
    return C;
end);

InstallMethod(PermutedCode, "method for linear codes", true, 
	[IsLinearCode, IsPerm], 0,  
function(Cold, P) 
	local C, field, fields;  
	if IsCyclicCode(Cold) then 
		return PermutedCode(Cold, P); 
	fi; 
    C := GeneratorMatCode(
                 PermutedCols(GeneratorMat(Cold), P),
                 "permuted code", LeftActingDomain(Cold));
    # Copy the fields that stay the same:
    fields := [WeightDistribution, IsPerfectCode, IsSelfDualCode, 
				MinimumWeightOfGenerators, MinimumDistance, CoveringRadius]; 
	for field in fields do
        if Tester(field)(Cold) then
			Setter(field)(C, field(Cold));
		fi;
	od;
	fields := ["lowerBoundMinimumDistance", "upperBoundMinimumDistance", 
				"boundsCoveringRadius"]; 
	for field in fields do
        if IsBound(Cold!.(field)) then
			C!.(field) := Cold!.(field);
		fi;
	od;
	C!.history := History(Cold);
    return C;
end);

InstallMethod(PermutedCode, "method for cyclic codes", true, 
	[IsCyclicCode, IsPerm], 0, 
function(Cold, P) 
    local C, field, fields;
    C := GeneratorMatCode(
                 PermutedCols(GeneratorMat(Cold), P),
                 "permuted code", LeftActingDomain(Cold) );
    # Copy the fields that stay the same:
	fields := [WeightDistribution, IsPerfectCode, IsSelfDualCode,
                MinimumWeightOfGenerators, MinimumDistance, CoveringRadius, 
				UpperBoundOptimalMinimumDistance];
	for field in fields do
		if Tester(field)(Cold) then
	        Setter(field)(C, field(Cold));
	    fi;
	od;
	fields := ["lowerBoundMinimumDistance", "upperBoundMinimumDistance",
	            "boundsCoveringRadius"];
	for field in fields do
	    if IsBound(Cold!.(field)) then
	        C!.(field) := Cold!.(field);
	    fi;
	od;

    C!.history := History(Cold);
    return C;
end);


#############################################################################
##
#F  StandardFormCode( <C> ) . . . . . . . . . . . . standard form of code <C>
##

##LR - all of these methods used to use a ShallowCopy, but that doesn't 
##	   allow for unbinding/unsetting of attributes.  So now a whole new 
##	   code is created.  However, should figure out what can be saved and 
##	   use that.  

InstallMethod(StandardFormCode, "method for unrestricted code", true, 
	[IsCode], 0, 
function(C) 
	local Cnew;   
	if IsLinearCode(C) then 
		return StandardFormCode(C);  
	fi; 
	Cnew := ElementsCode(AsSSortedList(C), "standard form", 
						 LeftActingDomain(C)); 
	Cnew!.history := History(C); 
	return Cnew; 
end); 

InstallMethod(StandardFormCode, "method for linear codes", true, 
	[IsLinearCode], 0, 
function(C) 
	local G, P, Cnew;  
	G := ShallowCopy(GeneratorMat(C)); 
	P := PutStandardForm(G, true, LeftActingDomain(C)); 
	if P = () then 
		Cnew := ShallowCopy(C); 	
		# this messes up code names
		#Cnew!.name := "standard form"; 	
	else 
		Cnew := GeneratorMatCode(G, 
			Concatenation("standard form, permuted with ", 
			               String(P)),  
				      LeftActingDomain(C)); 
	fi;
	Cnew!.history := History(C); 
	return Cnew; 
end); 


#############################################################################
##
#F  ConversionFieldCode( <C> )  . . . . . converts code from GF(q^m) to GF(q)
##

InstallMethod(ConversionFieldCode, "method for unrestricted code", true, 
	[IsCode], 0, 
function (C) 
	local F, x, q, m, i, ConvertElms, Cnew;  
	if IsLinearCode(C) then 
		return ConversionFieldCode(C); 
	fi; 

    ConvertElms := function (M)
        local res,n,k,vec,coord, ConvTable, Nul, g, zero;
        res := [];
        n := Length(M[1]);
        k := Length(M);
        g := MinimalPolynomial(GF(q), Z(q^m));
        zero := Zero(F);  
        Nul := List([1..m], i -> zero);
        ConvTable := [];
        x := Indeterminate(GF(q));
        for i in [1..Size(F) - 1] do
            ConvTable[i] := VectorCodeword(Codeword(x^(i-1) mod g, m));
        od;
        for vec in [1..k] do
            res[vec] := [];
            for coord in [1..n] do
                if M[vec][coord] <> zero then
                    Append(res[vec], 
							ConvTable[LogFFE(M[vec][coord], Z(q^m)) + 1]);
                else
                    Append(res[vec], Nul);
                fi;
            od;
        od;
        return res;
    end;

    F := LeftActingDomain(C);
    q := Characteristic(F);  
    m := Dimension(F); 
    Cnew := ElementsCode(
                    ConvertElms(VectorCodeword(AsSSortedList(C))),
                    Concatenation("code, converted to basefield GF(",
                            String(q),")"),
                    F );
    Cnew!.lowerBoundMinimumDistance := LowerBoundMinimumDistance(C);
    Cnew!.upperBoundMinimumDistance := Minimum(WordLength(C), 
                                              m*UpperBoundMinimumDistance(C));
    Cnew!.history := History(C);
    return Cnew;
end);

InstallOtherMethod(ConversionFieldCode, "method for linear code", true, 
	[IsLinearCode], 0, 
function(C) 
    local F, Cnew;
    F := LeftActingDomain(C); 
    Cnew := GeneratorMatCode(
                    HorizontalConversionFieldMat( GeneratorMat(C), F),
                    Concatenation("code, converted to basefield GF(",
                            String(Characteristic(F)), ")"),
                    GF(Characteristic(F)));
    Cnew!.lowerBoundMinimumDistance := LowerBoundMinimumDistance(C);
    Cnew!.upperBoundMinimumDistance := Minimum(WordLength(C), 
                                 Dimension(F) * UpperBoundMinimumDistance(C));
    Cnew!.history := History(C);
    return Cnew;
end);


#############################################################################
##
#F  CosetCode( <C>, <f> ) . . . . . . . . . . . . . . . . . . .  coset of <C>
##

InstallMethod(CosetCode, "method for unrestricted codes", true, 
	[IsCode, IsCodeword], 0, 
function(C, f) 
	local i, els, Cnew; 	
	if IsLinearCode(C) then 
		return CosetCode(C, f); 
	fi;
    f := Codeword(f, LeftActingDomain(C));
    els := [];
    for i in [1..Size(C)] do
        Add(els, AsSSortedList(C)[i] + f);
    od;
    Cnew := ElementsCode(els, "coset code", LeftActingDomain(C) );
    Cnew!.lowerBoundMinimumDistance := LowerBoundMinimumDistance(C);
    Cnew!.upperBoundMinimumDistance := UpperBoundMinimumDistance(C);
    Cnew!.history := History(C);
    return Cnew;
end);

InstallMethod(CosetCode, "method for linear codes", true, 
	[IsLinearCode, IsCodeword], 0, 
function(C, f) 
    local Cnew, i, els, Cels;
    f := Codeword(f, LeftActingDomain(C));
    if f in C then
        return ShallowCopy(C);
    fi;
    els := [];
    Cels := AsSSortedList(C);
    for i in [1..Size(C)] do
        Add(els, Cels[i] + f);
    od;
    Cnew := ElementsCode(els, "coset code", LeftActingDomain(C) );
	if HasWeightDistribution(C) then
        SetInnerDistribution(Cnew, ShallowCopy(WeightDistribution(C)));
    fi;
    Cnew!.lowerBoundMinimumDistance := LowerBoundMinimumDistance(C);
    Cnew!.upperBoundMinimumDistance := UpperBoundMinimumDistance(C);
    Cnew!.history := History(C);
    return Cnew;
end);


#############################################################################
##
#F  DirectSumCode( <C1>, <C2> ) . . . . . . . . . . . . . . . . .  direct sum
##
##  DirectSumCode(C1, C2) creates a (n1 + n2 , M1 M2 , min{d1 , d2} ) code
##  by adding each codeword of the second code to all the codewords of the
##  first code.
##
    
InstallMethod(DirectSumCode, "method for unrestricted codes", true, 
	[IsCode, IsCode], 0, 
function(C1, C2) 
	local i, j, C, els, n, sumcr, wd, id;   
	if IsLinearCode(C1) and IsLinearCode(C2) then
        return DirectSumCode(C1, C2);
	fi;
	if LeftActingDomain(C1) <> LeftActingDomain(C2) then
        Error("Codes are not in the same basefield");
	fi;

    els := [];
    for i in VectorCodeword(AsSSortedList(C1)) do
        Append(els,List(VectorCodeword(AsSSortedList(C2)),
                x-> Concatenation(i, x ) ) );
    od;
    C := ElementsCode( els, "direct sum code", LeftActingDomain(C1) );
    n := WordLength(C1) + WordLength(C2);
    if Size(C) <= 1 then
        C!.lowerBoundMinimumDistance := n;
        C!.upperBoundMinimumDistance := n;
    else
        C!.lowerBoundMinimumDistance := Minimum(LowerBoundMinimumDistance(C1),
                                               LowerBoundMinimumDistance(C2));
        C!.upperBoundMinimumDistance := Minimum(UpperBoundMinimumDistance(C1),
                                               UpperBoundMinimumDistance(C2));
    fi;
    if HasWeightDistribution(C1) and HasWeightDistribution(C2) then
        wd := NullVector(WordLength(C)+1);
        for i in [1..WordLength(C1)+1] do
            for j in [1..WordLength(C2)+1] do
                wd[i+j-1] := wd[i+j-1]+
                             WeightDistribution(C1)[i] *
                             WeightDistribution(C2)[j];
            od;
        od;
    	SetWeightDistribution(C, wd); 
	fi;
    if HasInnerDistribution(C1) and HasInnerDistribution(C2) then
        id := NullVector(WordLength(C) + 1);
        for i in [1..WordLength(C1) + 1 ] do
            for j in [1..WordLength(C2) + 1 ] do
                id[i+j-1] := id[i+j-1]+
                             InnerDistribution(C1)[i] *
                             InnerDistribution(C2)[j];

            od;
        od;
		SetInnerDistribution(C, id); 
	fi;
    if IsBound(C1!.boundsCoveringRadius) 
       and IsBound(C2!.boundsCoveringRadius) then
        sumcr := List( C1!.boundsCoveringRadius,
          x -> x + C2!.boundsCoveringRadius);
        sumcr := Set( Flat( sumcr ) );
        IsRange( sumcr );
        C!.boundsCoveringRadius := sumcr;
    fi;
    C!.history := MergeHistories(History(C1), History(C2));
    return C;
end);

InstallMethod(DirectSumCode, "method for linear codes", true, 
	[IsLinearCode, IsLinearCode], 0, 
function(C1, C2) 
	local i, j, C, zeros1, zeros2, G, n, sumcr, wd;  
	if LeftActingDomain(C1) <> LeftActingDomain(C2) then
        Error("Codes are not in the same basefield");
	fi;
    
	zeros1 := NullVector(WordLength(C1), LeftActingDomain(C1));
    zeros2 := NullVector(WordLength(C2), LeftActingDomain(C1));
    G := List(GeneratorMat(C1),x -> Concatenation(x,zeros2));
    Append(G,List(GeneratorMat(C2),x -> Concatenation(zeros1,x)));
    C := GeneratorMatCode( G, "direct sum code", LeftActingDomain(C1) );
    n := WordLength(C1) + WordLength(C2);
    if Size(C) <= 1 then
        C!.lowerBoundMinimumDistance := n;
        C!.upperBoundMinimumDistance := n;
    else
        C!.lowerBoundMinimumDistance := Minimum(LowerBoundMinimumDistance(C1),
                                               LowerBoundMinimumDistance(C2));
        C!.upperBoundMinimumDistance := Minimum(UpperBoundMinimumDistance(C1),
                                               UpperBoundMinimumDistance(C2));
    fi;
    if HasWeightDistribution(C1) and HasWeightDistribution(C2) then
        wd := NullVector(WordLength(C)+1);
        for i in [1..WordLength(C1)+1] do
            for j in [1..WordLength(C2)+1] do
                wd[i+j-1] := wd[i+j-1]+
                             WeightDistribution(C1)[i] *
                             WeightDistribution(C2)[j];
            od;
        od;
    	SetWeightDistribution(C, wd);  
	fi;  
    if IsBound(C1!.boundsCoveringRadius) 
       and IsBound(C2!.boundsCoveringRadius) then
        sumcr := List( C1!.boundsCoveringRadius,
          x -> x + C2!.boundsCoveringRadius);
        sumcr := Set( Flat( sumcr ) );
        IsRange( sumcr );
        C!.boundsCoveringRadius := sumcr;
    fi;
    if HasIsNormalCode(C1) and HasIsNormalCode(C2) and
       IsNormalCode( C1 ) and IsNormalCode( C2 ) then
        SetIsNormalCode(C, true);
    fi;
    if HasIsSelfOrthogonalCode(C1) and HasIsSelfOrthogonalCode(C2) 
       and IsSelfOrthogonalCode(C1) and IsSelfOrthogonalCode(C2) then
        SetIsSelfOrthogonalCode(C, true);
    fi;
    C!.history := MergeHistories(History(C1), History(C2));
    return C;
end);


#############################################################################
##
#F  ConcatenationCode( <C1>, <C2> ) . . . . .  concatenation of <C1> and <C2>
##

InstallMethod(ConcatenationCode, "method for unrestricted codes", true, 
	[IsCode, IsCode], 0, 
function(C1, C2) 
	local E,e,C;  
	if IsLinearCode(C1) and IsLinearCode(C2) then 
		return ConcatenationCode(C1, C2);
	elif Size(C1) <> Size(C2) then
		Error("both codes must have equal size");
	elif LeftActingDomain(C1) <> LeftActingDomain(C2) then
		Error("both codes must be over the same field");
	fi;
						
	E := [];
	for e in [1..Size(C1)] do
		Add(E,Concatenation(VectorCodeword(AsSSortedList(C1)[e]),
				VectorCodeword(AsSSortedList(C2)[e])));
	od;
	C := ElementsCode( E, "concatenation code", LeftActingDomain(C1) );
	C!.lowerBoundMinimumDistance := LowerBoundMinimumDistance(C1) +
								   LowerBoundMinimumDistance(C2);
	C!.upperBoundMinimumDistance := UpperBoundMinimumDistance(C1) +
								   UpperBoundMinimumDistance(C2);
	# CoveringRadius?
	C!.history := MergeHistories(History(C1), History(C2));
	return C;
end);
    

InstallMethod(ConcatenationCode, "method for linear codes", true, 
	[IsLinearCode, IsLinearCode], 0, 
function(C1, C2) 
	local e, C, G, G1, G2;   
	if Size(C1) <> Size(C2) then
        Error("both codes must have equal size");
	elif LeftActingDomain(C1) <> LeftActingDomain(C2) then
		Error("both codes must be over the same field");
	fi;
						
	G := [];
	G1 := GeneratorMat(C1);
	G2 := GeneratorMat(C2);
	for e in [1..Dimension(C1)] do
		Add(G, Concatenation(G1[e], G2[e]));
	od;
	C := GeneratorMatCode(G, "concatenation code", LeftActingDomain(C1));
	C!.lowerBoundMinimumDistance := LowerBoundMinimumDistance(C1) +
								   LowerBoundMinimumDistance(C2);
	C!.upperBoundMinimumDistance := UpperBoundMinimumDistance(C1) +
								   UpperBoundMinimumDistance(C2);
	# CoveringRadius?
	C!.history := MergeHistories(History(C1), History(C2));
	return C;
end);
    

#############################################################################
##
#F  DirectProductCode( <C1>, <C2> ) . . . . . . . . . . . . .  direct product
##
##  DirectProductCode constructs a new code from the direct product of two
##  codes by taking the Kronecker product of the two generator matrices
##

InstallMethod(DirectProductCode, "method for unrestricted codes", true, 
	[IsCode, IsCode], 0, 
function(C1, C2) 
	if IsLinearCode(C1) and IsLinearCode(C2) then 
		return DirectProductCode(C1,C2); 
	else
		Error("both codes must be linear"); 
	fi; 
end); 

InstallMethod(DirectProductCode, "method for linear codes", true, 
	[IsLinearCode, IsLinearCode], 0, 
function(C1, C2) 
	local C;
	if LeftActingDomain(C1) <> LeftActingDomain(C2) then
		Error("both codes must have the same basefield");
	fi;
	C := GeneratorMatCode(
				 KroneckerProduct(GeneratorMat(C1), GeneratorMat(C2)),
				 "direct product code",
				 LeftActingDomain(C1));
	if Dimension(C) = 0 then
		C!.lowerBoundMinimumDistance := WordLength(C);
		C!.upperBoundMinimumDistance := WordLength(C);
	else
		C!.lowerBoundMinimumDistance := LowerBoundMinimumDistance(C1) *
									   LowerBoundMinimumDistance(C2);
		C!.upperBoundMinimumDistance := UpperBoundMinimumDistance(C1) *
									   UpperBoundMinimumDistance(C2);
	fi;
	C!.history := MergeHistories(History(C1), History(C2));
	if IsBound( C1!.boundsCoveringRadius ) and
	   IsBound( C2!.boundsCoveringRadius ) then
		C!.boundsCoveringRadius := [
		Maximum( WordLength( C1 ) * C2!.boundsCoveringRadius[ 1 ],
				   WordLength( C2 ) * C1!.boundsCoveringRadius[ 1 ] )
		  .. GeneralUpperBoundCoveringRadius( C ) ];
	fi;
	return C;
end);


#############################################################################
##
#F  UUVCode( <C1>, <C2> ) . . . . . . . . . . . . . . .  u | u+v construction
##
##  Uuvcode(C1, C2) # creates a ( 2n , M1 M2 , d = min{2 d1 , d2} ) code
##  with codewords  (u | u + v) for all u in C1 and v in C2
##

InstallMethod(UUVCode, "method for linear codes", true, 
	[IsLinearCode, IsLinearCode], 0, 
function(C1, C2) 
	local C, F, diff, zeros, zeros2, G, n; 
	if LeftActingDomain(C1)<>LeftActingDomain(C2) then
        Error("Codes are not in the same basefield");
	fi; 
	F := LeftActingDomain(C1); 
	n := WordLength(C1)+Maximum(WordLength(C1),WordLength(C2));
	diff := WordLength(C1)-WordLength(C2);
	zeros := NullVector(WordLength(C1), F);
	zeros2 := NullVector(AbsInt(diff), F);
	if diff < 0 then
		G := List(GeneratorMat(C1),u -> Concatenation(u,u,zeros2));
		Append(G,List(GeneratorMat(C2),v -> Concatenation(zeros,v)));
	else
		G:=List(GeneratorMat(C1),u -> Concatenation(u,u));
		Append(G,List(GeneratorMat(C2),v->Concatenation(zeros,v,zeros2)));
	fi;
	C := GeneratorMatCode( G, "U|U+V construction code", F );
	if Dimension(C1) = 0 then
		if Dimension(C2) = 0 then
			C!.lowerBoundMinimumDistance := n;
			C!.upperBoundMinimumDistance := n;
		else
			C!.lowerBoundMinimumDistance := LowerBoundMinimumDistance(C2);
			C!.upperBoundMinimumDistance := UpperBoundMinimumDistance(C2);
		fi;
	elif Dimension(C2) = 0 then
		C!.lowerBoundMinimumDistance := 2*LowerBoundMinimumDistance(C1);
		C!.upperBoundMinimumDistance := 2*UpperBoundMinimumDistance(C1);
	else
		C!.lowerBoundMinimumDistance := Minimum(
			2*LowerBoundMinimumDistance(C1),LowerBoundMinimumDistance(C2));
		C!.upperBoundMinimumDistance := Minimum(
			2*UpperBoundMinimumDistance(C1),UpperBoundMinimumDistance(C2));
	fi;
	
	C!.history := MergeHistories(History(C1), History(C2));
	return C;
end);

InstallMethod(UUVCode, "method for unrestricted codes", true, 
	[IsCode, IsCode], 0, 
function(C1, C2) 
	local C, F, i, M1, diff, zeros, extended, Els1, Els2, els, n; 
    if LeftActingDomain(C1)<>LeftActingDomain(C2) then
		Error("Codes are not in the same basefield");
	elif IsLinearCode(C1) and IsLinearCode(C2) then
		return UUVCode(C1, C2);
	fi;
	F := LeftActingDomain(C1); 
	n := WordLength(C1)+Maximum(WordLength(C1),WordLength(C2));
	diff := WordLength(C1)-WordLength(C2);
	M1 := Size(C1);
	zeros := NullVector(AbsInt(diff), F);
	els := [];
	Els1 := AsSSortedList(C1);
	Els2 := AsSSortedList(C2);
	if diff>0 then 
		extended := List(Els2,x->Concatenation(VectorCodeword(x),zeros)); 
		for i in [1..M1] do 
			Append(els, List(extended,x-> Concatenation(VectorCodeword(Els1[i]),
					VectorCodeword(Els1[i]) + x ) ) );
		od; 
	elif diff<0 then 
		for i in [1..M1] do 
			extended := Concatenation(VectorCodeword(Els1[i]),zeros);
			Append(els,List(Els2,x-> Concatenation(VectorCodeword(Els1[i]), 
					extended + VectorCodeword(x) ) ) ); 
		od; 
	else 
		for i in [1..M1] do
			Append(els,List(Els2,x-> Concatenation(VectorCodeword(Els1[i]), 
					VectorCodeword(Els1[i]) + VectorCodeword(x) ) ) );
		od; 
	fi;
	C := ElementsCode(els, "U|U+V construction code", F);
	C!.lowerBoundMinimumDistance := Minimum(2*LowerBoundMinimumDistance(C1),
										   LowerBoundMinimumDistance(C2));
	C!.upperBoundMinimumDistance := Minimum(2*UpperBoundMinimumDistance(C1),
										   UpperBoundMinimumDistance(C2));

	C!.history := MergeHistories(History(C1), History(C2));
	return C;
end);


#############################################################################
##
#F  UnionCode( <C1>, <C2> ) . . . . . . . . . . . . .  union of <C1> and <C2>
##

InstallMethod(UnionCode, "method for two linear codes", true, 
	[IsLinearCode, IsLinearCode], 0, 
function(C1, C2) 
	local C, Els, e;
	if LeftActingDomain(C1) <> LeftActingDomain(C2) then
		Error("codes are not in the same basefield");
	elif WordLength(C1) <> WordLength(C2) then
		Error("wordlength must be the same");
	fi;
	C := AugmentedCode(C1, GeneratorMat(C2));
	C!.upperBoundMinimumDistance := Minimum(UpperBoundMinimumDistance(C1),
										   UpperBoundMinimumDistance(C2));
	C!.history := MergeHistories(History(C1), History(C2));
	C!.name := "union code";
	return C;
end);

# should there be a special function for cyclic codes? Or in other words:
# If C1 and C2 are cyclic, does that mean that UnionCode(C1, C2) is cyclic?

InstallMethod(UnionCode, "method for one or both unrestricted codes", true, 
	[IsCode, IsCode], 0, 
function(C1, C2) 
	if IsLinearCode(C1) and IsLinearCode(C2) then 
		return UnionCode(C1,C2); 
	else 
		Error("use AddedElementsCode for non-linear codes"); 
	fi; 
end); 


#############################################################################
##
#F  IntersectionCode( <C1>, <C2> )  . . . . . . intersection of <C1> and <C2>
##

InstallMethod(IntersectionCode, "method for unrestricted codes", true, 
	[IsCode, IsCode], 0, 
function(C1, C2) 
	local C, Els, e; 
	if (IsCyclicCode(C1) and IsCyclicCode(C2)) or 
	   (IsLinearCode(C1) and IsLinearCode(C2)) then 
		return IntersectionCode(C1, C2); 
	fi; 
	if LeftActingDomain(C1) <> LeftActingDomain(C2) then
		Error("codes are not in the same basefield");
	elif WordLength(C1) <> WordLength(C2) then
		Error("wordlength must be the same");
	fi;
	Els := [];
	for e in AsSSortedList(C1) do
		if e in C2 then Add(Els, e); fi;
	od;
	if Els = [] then
		return false; # or an Error?   
	else
		C := ElementsCode(Els, "intersection code", LeftActingDomain(C1));
	fi;
	C!.lowerBoundMinimumDistance := Maximum(LowerBoundMinimumDistance(C1),
										   LowerBoundMinimumDistance(C2));  
	C!.history := MergeHistories(History(C1), History(C2));
	return C;
end);
  
InstallMethod(IntersectionCode, "method for linear codes", true, 
	[IsLinearCode, IsLinearCode], 0, 
function(C1, C2) 
	local C;
	if IsCyclicCode(C1) and IsCyclicCode(C2) then 
		return IntersectionCode(C1, C2); 
	fi; 
	if LeftActingDomain(C1) <> LeftActingDomain(C2) then
		Error("codes are not in the same basefield");
	elif WordLength(C1) <> WordLength(C2) then
		Error("wordlength must be the same");
	fi;
	C := DualCode(AugmentedCode(DualCode(C1), CheckMat(C2)));
	C!.lowerBoundMinimumDistance := Maximum(LowerBoundMinimumDistance(C1),
										   LowerBoundMinimumDistance(C2));
	C!.history := MergeHistories(History(C1), History(C2));
	C!.name := "intersection code";
	return C;
end);
  
InstallMethod(IntersectionCode, "method for cyclic codes", true, 
	[IsCyclicCode, IsCyclicCode], 0, 
function(C1, C2) 
	local C; 
	if LeftActingDomain(C1) <> LeftActingDomain(C2) then
        Error("codes are not in the same basefield");
	elif WordLength(C1) <> WordLength(C2) then
		Error("wordlength must be the same");
	fi;
	C := GeneratorPolCode(
				 Lcm(GeneratorPol(C1), GeneratorPol(C2)), WordLength(C1),
				 "intersection code", LeftActingDomain(C1) );
	if HasRootsOfCode(C1) and HasRootsOfCode(C2) then 
		SetRootsOfCode(C, UnionSet(RootsOfCode(C1), RootsOfCode(C2))); 
	fi;
	C!.lowerBoundMinimumDistance := Maximum(LowerBoundMinimumDistance(C1),
										   LowerBoundMinimumDistance(C2));  
	C!.history := MergeHistories(History(C1), History(C2));
	return C;
end);
    
