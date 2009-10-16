#############################################################################
##
#A  bounds.gi               GUAVA library                       Reinald Baart
#A                                                        &Jasper Cramwinckel
#A                                                           &Erik Roijackers
##
##  This file contains functions for calculating with bounds
##
#H  @(#)$Id: bounds.gi,v 1.5 2004/12/20 21:26:06 gap Exp $
##
Revision.("guava/lib/bounds_gi") :=
    "@(#)$Id: bounds.gi,v 1.5 2004/12/20 21:26:06 gap Exp $";

#############################################################################
##
#F  LowerBoundGilbertVarshamov( <n>, <r>, <q> )  . . . Gilbert-Varshamov 
##                                                 lower bound for linear codes
##
## added 9-2004 by wdj
InstallMethod(LowerBoundGilbertVarshamov, "n, d, q", true, [IsInt, IsInt, IsInt], 0, 
function(n, d, q) 
    return Int((q^(n-1))/(SphereContent(n-1,d-2,GF(q))));
end);

#############################################################################
##
#F  LowerBoundSpherePacking( <n>, <r>, <q> )  . . . sphere packing lower bound
##                                                 for unrestricted codes
##
## added 11-2004 by wdj
InstallMethod(LowerBoundSpherePacking, "n, d, q", true, [IsInt, IsInt, IsInt], 0, 
function(n, d, q) 
    return Int((q^(n))/(SphereContent(n,d-1,GF(q))));
end);

#############################################################################
##
#F  UpperBoundHamming( <n>, <d>, <q> )  . . . . . . . . . . . . Hamming bound
##
InstallMethod(UpperBoundHamming, "n, d, q", true, [IsInt, IsInt, IsInt], 0, 
function(n, d, q) 
    return Int((q^n)/(SphereContent(n,QuoInt(d-1,2),q)));
end);

#############################################################################
##
#F  UpperBoundSingleton( <n>, <d>, <q> )  . . . . . . . . . . Singleton bound
##
InstallMethod(UpperBoundSingleton, "n, d, q", true, [IsInt, IsInt, IsInt], 0, 
function (n,d,q)
    return q^(n - d + 1);
end);

#############################################################################
##
#F  UpperBoundPlotkin( <n>, <d>, <q> )  . . . . . . . . . . . . Plotkin bound
##
InstallMethod(UpperBoundPlotkin, "n, d, q", true, [IsInt, IsInt, IsInt], 0, 
function (n,d,q)
    local t, fact;
    t := 1 - 1/q;
    if (q=2) and (n = 2*d) and (d mod 2 = 0) then
        return 4*d;
    elif (q=2) and (n = 2*d + 1) and (d mod 2 = 1) then
        return 4*d + 4;
    elif d >= t*n + 1 then
        return Int(d/( d - t*n));
    elif d < t*n + 1 then
        fact := (d-1) / t;
        if not IsInt(fact) then
            fact := Int(fact) + 1;
        fi;
        return Int(d/( d - t * fact)) * q^(n - fact);
    fi;
end);

#############################################################################
##
#F  UpperBoundGriesmer( <n>, <d>, <q> ) . . . . . . . . . . .  Griesmer bound
##
InstallMethod(UpperBoundGriesmer, "n, d, q", true, [IsInt, IsInt, IsInt], 0, 
function (n,d,q)
    local s, den, k, add;
    den := 1;
    s := 0;
    k := 0;
    add := 0;
    while s <= n do
        if add <> 1 then
            add := QuoInt(d, den) + SignInt(d mod den);
        fi;
        s := s + add;
        den := den * q;
        k := k + 1;
    od;
    return q^(k-1);
end);

#############################################################################
##
#F  UpperBoundElias( <n>, <d>, <q> )  . . . . . . . . . . . . . . Elias bound
##
## bug found + corrected 2-2004
## code added 8-2004
##
InstallMethod(UpperBoundElias, "n, d, q", true, [IsInt, IsInt, IsInt], 0, 
function (n,d,q)
    local r, i, I, w, bnd, ff, get_list;
    ff:=function(n,d,w,q)
          local r;
	  r:=1-1/q;
	  return r*n*d*q^n/((w^2-2*r*n*w+r*n*d)*SphereContent(n,w,q));
    end; 
    get_list:=function(n,d,q)
     local r,i,I;
      I:=[];
       r:=1-1/q;
        for i in [1..Int(r*n)] do
	  if IsPosRat(i^2-2*r*n*i+r*n*d) then Append(I,[i]); fi;
	   od;
	    return I;
    end;
    I:=get_list(n,d,q);
    bnd:= Minimum(List(I, w -> ff(n,d,w,q)));
    return Int(bnd);
end);

#############################################################################
##
#F  UpperBoundJohnson( <n>, <d> ) . . . . . . . . . . Johnson bound for <q>=2
##
InstallMethod(UpperBoundJohnson, "n, d", true, [IsInt, IsInt], 0, 
function (n,d)
    local UBConsWgt, e, num, den;
    UBConsWgt := function (n1,d1)
        local fact, e, res, t;
        e := Int((d1-1) / 2);
        res := 1;
        for t in [0..e] do
            res := Int(res * (n1 - (e-t)) / ( d1 - (e-t)));
        od;
        return res;
    end;
    e := Int((d-1) / 2);
    num := Binomial(n,e+1) - Binomial(d,e)*UBConsWgt(n,d);
    den := Int(num / Int(n / (e+1)));
    return Int(2^n / (den + SphereContent(n,e,2)));
end);

#############################################################################
##
#F  UpperBound( <n>, <d> [, <F>] )  . . . .  upper bound for minimum distance
##
##  calculates upperbound for a code C of word length n, minimum distance at
##  least d over an alphabet Q of size q, using the minimum of the Hamming,
##  Plotkin and Singleton bound.
##
InstallMethod(UpperBound, "n, d, fieldsize", true, [IsInt, IsInt, IsInt], 0, 
function(n, d, q) 
    local MinBound, l;

    MinBound := function (n1,d1,q1)
        local mn1;
        mn1 := Minimum (UpperBoundPlotkin(n1,d1,q1),
                       UpperBoundSingleton(n1,d1,q1),
                       UpperBoundElias(n1,d1,q1));
        if q1 = 2 then
            return Minimum(mn1, UpperBoundJohnson(n1,d1));
        else
            return Minimum(mn1, UpperBoundHamming(n1,d1,q1));
        fi;
    end;

    if n < d then
        return 0;
    elif n = d then
        return q;
    elif d = 1 then
        return q^n;
    fi;
    if (q=2) then
        if d mod 2 = 0 then
            return Minimum(MinBound(n,d,q), MinBound(n-1,d-1,q));
        else
            return Minimum(MinBound(n,d,q), MinBound(n+1,d+1,q));
        fi;
    else
        return MinBound(n,d,q);
    fi;
end);

InstallOtherMethod(UpperBound, "n, d, field", true, [IsInt, IsInt, IsField], 0, 
function(n, d, F) 
	return UpperBound(n, d, Size(F)); 
end); 

InstallOtherMethod(UpperBound, "n, d", true, [IsInt, IsInt], 0, 
function(n, d) 
	return UpperBound(n, d, 2); 
end); 


#############################################################################
##
#F  IsPerfectCode( <C> )  . . . . . .  determines whether C is a perfect code
##
InstallMethod(IsPerfectCode, "method for unrestricted codes", true, 
	[IsCode], 0, 
function(C) 
    local n, q, dist, d, t, isperfect, IsTrivialPerfect, ArePerfectParameters;

    IsTrivialPerfect := function(C)
        # Checks if C has only one or zero codewords, or is the whole
        # space, or is a repetition code of odd length over GF(2).
        # These are 'trivial' perfect codes.
        return ((Size(C) <= 1) or 
                (Size(C) = Size(LeftActingDomain(C))^WordLength(C)) or
                ((LeftActingDomain(C) = GF(2)) and (Size(C) = 2) and
                 ((WordLength(C) mod 2) <> 0) and (IsCyclicCode(C))));
    end;

    ArePerfectParameters := function(q, n, M, dvec) 
        local k, r;
        # Can the parameters be of a perfect code? If they don't belong
        # to a trivial perfect code, they should be the same as a Golay
        # or Hamming code.
        k := LogInt(M, q);
        if M <> q^k then 
            return false; #nothing wrong here
        elif (q = 2) and (n = 23) then
            return (k = 12) and (7 in [dvec[1]..dvec[2]]);
        elif (q = 3) and (n = 11) then
            return (k = 6) and (5 in [dvec[1]..dvec[2]]);
        else
            r := n-k;
            return (n = ((q^r-1)/(q-1))) and 
                   (3 in [dvec[1]..dvec[2]]);
        fi;
    end;

    n := WordLength(C);
    q := Size(LeftActingDomain(C));
    dist := [LowerBoundMinimumDistance(C), UpperBoundMinimumDistance(C)];
    if IsTrivialPerfect(C) then
        if (Size(C) > 1) then
            SetCoveringRadius(C, Int(MinimumDistance(C)/2));
        else
            SetCoveringRadius(C, n);
        fi; 
		return true; 
    elif not ArePerfectParameters(q, n, Size(C), dist) then
        return false;
    else
        t := List(dist, d->QuoInt(d-1, 2));
        if t[1] = t[2] then 
            d := t[1]*2 +1;
        else
            d := MinimumDistance(C);
        fi;
        isperfect := (d mod 2 = 1) and 
                     ArePerfectParameters(q, n, Size(C), [d,d]);
        if isperfect then
            C!.lowerBoundMinimumDistance := d;
            C!.upperBoundMinimumDistance := d;
            SetCoveringRadius(C, Int(d/2));
        fi;
    	return isperfect; 
	fi;
end);

#############################################################################
##
#F  IsMDSCode( <C> )  . . .  checks if C is a Maximum Distance Separable Code
##
InstallMethod(IsMDSCode, "method for unrestricted code", true, [IsCode], 0, 
function(C)
    local wd, w, n, d, q;
    q:= Size(LeftActingDomain(C));
    n:= WordLength(C);
    d:= MinimumDistance(C);
    if d = n - LogInt(Size(C),q) + 1 then
        if not HasWeightDistribution(C) then
            wd := List([0..n], i -> 0);
            wd[1] := 1;
            for w in [d..n] do
                # The weight distribution of MDS codes is exactly known
                wd[w+1] := Binomial(n,w)*Sum(List([0..w-d],j -> 
                                   (-1)^j * Binomial(w,j) *(q^(w-d+1-j)-1)));
            od;
            SetWeightDistribution(C, wd);
        fi;
        return true;
    else
        return false; #this is great!
    fi;
end);

#############################################################################
##
#F  OptimalityCode( <C> ) . . . . . . . . . .  estimate for optimality of <C>
##
##  OptimalityCode(C) returns the difference between the smallest known upper-
##  bound and the actual size of the code. Note that the value of the
##  function UpperBound is not allways equal to the actual upperbound A(n,d)
##  thus the result may not be equal to 0 for all optimal codes!
##
InstallMethod(OptimalityCode, "method for unrestricted code", true, 
	[IsCode], 0, 
function(C)
    return UpperBound(WordLength(C), MinimumDistance(C), 
						Size(LeftActingDomain(C))) - 
			Size(C);
end);

#############################################################################
##
#F  OptimalityLinearCode( <C> ) .  estimate for optimality of linear code <C>
##
##  OptimalityLinearCode(C) returns the difference between the smallest known
##  upperbound on the size of a linear code and the actual size.
##

InstallMethod(OptimalityLinearCode, "method for unrestricted code", 
	true, [IsCode], 0, 
function(C) 
	local q, ub; 
	if not IsLinearCode(C) then 
		Print("Warning: OptimalityLinearCode called with non-linear ", 
		      "code as argument\n"); 
		##LR do we want to raise an error here? 
	fi; 
    q := Size(LeftActingDomain(C));
    ub := Minimum(UpperBound(WordLength(C), MinimumDistance(C), q),
                  UpperBoundGriesmer(WordLength(C), MinimumDistance(C), q));
    return q^LogInt(ub,q) - Size(C);
end);


#############################################################################
##
#F  BoundsMinimumDistance( <n>, <k>, <F> )  . .  gets data from bounds tables
##
##  LowerBoundMinimumDistance uses (n, k, q, true)
##  UpperBoundMinimumDistance uses (n, k, q, false)

InstallGlobalFunction(BoundsMinimumDistance, 
function(arg)
    local n, k, q, RecurseBound, res, InfoLine, GLOBAL_ALERT,
          DoTheTrick, kind, obj;

    InfoLine := function(n, k, d, S, spaces, prefix)
        local K, res;
        if kind = 1 then
            K := "L";
        else
            K := "U";
        fi;
        return String(Flat([ K, "b(", String(n), ","
                       , String(k), ")=", String(d), ", ", S ]));
    end;

    DoTheTrick := function( obj, man, str)
        if IsBound(obj.lastman) and obj.lastman = man then
            obj.expl[Length(obj.expl)] := str;
        else
            Add(obj.expl, str);
        fi;
        obj.lastman := man;
        return obj;
    end;
#F              RecurseBound
    RecurseBound := function(n, k, spaces, prefix)
        local i, obj, obj2;
        if k = 0 then  # Nullcode
            return rec(d := n, expl := [InfoLine(n, k, n,
                           "null code", spaces, prefix) ], cons :=
                       [NullCode, [n, q]]);
        elif k = 1 then  # RepetitionCode
            return rec(d := n, expl := [InfoLine(n, k, n,
                           "repetition code", spaces, prefix) ],
                       cons := [RepetitionCode, [n, q]]);
        elif k = 2 and q = 2 then  # Cordaro-Wagner code
            obj := rec( d :=2*Int((n+1)/3) - Int(n mod 3 / 2) );
            obj.expl :=  [InfoLine(n, k, obj.d, "Cordaro-Wagner code", spaces,
                                 prefix)];
            obj.cons := [CordaroWagnerCode,[n]];
            return obj;
        elif k = n-1 then  # Dual of the repetition code
            return rec( d :=2, 
                        expl := [InfoLine(n, k, 2,
                           "dual of the repetition code", spaces, prefix) ],
                        cons := [DualCode,[[RepetitionCode, [n, q]]]]);
        elif k = n then  # Whole space code
            return rec( d :=1,
                        expl := [InfoLine(n, k, 1, Concatenation(
                           "entire space GF(", String(q), ")^",
                                   String(n)), spaces, prefix) ],
                        cons := [WholeSpaceCode, [n, q]]);
        elif not IsBound(GUAVA_BOUNDS_TABLE[kind][q][n][k]) then
            if kind = 1 then  # trivial for lower bounds
                obj := rec(d :=2, 
                           expl := [InfoLine(n, k, 2,
                                   "expurgated dual of repetition code",
                                   spaces, prefix) ],
                           cons := [DualCode,[[RepetitionCode, [n, q]]]]);
                for i in [ k .. n - 2 ] do
                    obj.cons := [ExpurgatedCode,[obj.cons]];
                od;
                return obj;
            else  # Griesmer for upper bounds
                obj := rec( d := 2);
                while Sum([0..k-1], i -> 
                        QuoInt(obj.d, q^i) + SignInt(obj.d mod q^i)) <= n do
                    obj.d := obj.d + 1;
                od;
                obj.d := obj.d - 1;
                obj.expl := [InfoLine(n, k, obj.d, "Griesmer bound", spaces,
                                    prefix)];
                return obj;
            fi;
                       #Look up construction in table
        elif IsInt(GUAVA_BOUNDS_TABLE[kind][q][n][k]) then
            i := GUAVA_BOUNDS_TABLE[kind][q][n][k];
            if i = 1 then  # Shortening
                obj := RecurseBound(n+1, k+1, spaces, "");
                if IsBound(obj.lastman) and obj.lastman = 1 then
                    Add(obj.cons[2][2], Length(obj.cons[2][2])+1);
                else
                    obj.cons := [ShortenedCode, [ obj.cons, [1] ]];
                fi;
                return DoTheTrick( obj, 1, InfoLine(n, k, obj.d,
                               "by shortening of:", spaces, prefix) );
            elif i = 2 then  # Puncturing
                obj := RecurseBound(n+1, k, spaces, "");
                obj.d := obj.d - 1;
                if IsBound(obj.lastman) and obj.lastman = 2 then
                    Add(obj.cons[2][2], Length(obj.cons[2][2])+1);
                else
                    obj.cons := [ PuncturedCode, [ obj.cons, [1] ]];
                fi;
                return DoTheTrick( obj, 2, InfoLine(n, k, obj.d,
                               "by puncturing of:", spaces, prefix) );
            elif i = 3 then  # Extending
                obj := RecurseBound(n-1, k, spaces, "");
                if q = 2 and IsOddInt(obj.d) then
                    obj.d := obj.d + 1;
                fi;
                if IsBound(obj.lastman) and obj.lastman = 3 then
                    obj.cons[2][2] := obj.cons[2][2] + 1;
                else
                    obj.cons := [ ExtendedCode, [ obj.cons, 1 ]];
                fi;
                return DoTheTrick( obj, 3, InfoLine(n, k, obj.d,
                               "by extending:", spaces, prefix) );
            # Methods for upper bounds:
            elif i = 11 then  # Shortening
                obj := RecurseBound(n-1, k-1, spaces, "");
                return DoTheTrick( obj, 11, InfoLine(n, k, obj.d,
                               "otherwise shortening would contradict:",
                               spaces, prefix) );
            elif i = 12 then  # Puncturing
                obj := RecurseBound(n-1, k, spaces, "");
                obj.d := obj.d + 1;
                return DoTheTrick( obj, 12, InfoLine(n, k, obj.d,
                               "otherwise puncturing would contradict:",
                               spaces, prefix) );
            elif i = 13 then  #Extending
                obj := RecurseBound(n+1, k, spaces, "");
                if q=2 and IsOddInt(obj.d) then
                    obj.d := obj.d - 1;
                fi;
                return DoTheTrick( obj, 13, InfoLine(n, k, obj.d,
                               "otherwise extending would contradict:",
                               spaces, prefix) );
            else
                Error("invalid table entry; table is corrupted");
            fi;
        else
            i := GUAVA_BOUNDS_TABLE[kind][q][n][k];
            if i[1] = 0 then  # Code from library
                if IsBound( GUAVA_REF_LIST.(i[3]) ) then
                    res.references.(i[3]) := GUAVA_REF_LIST.(i[3]);
                else
                    res.references.(i[3]) := GUAVA_REF_LIST.ask;
                fi;
                obj := rec( d := i[2], expl := [InfoLine(n, k, i[2],
                               Concatenation("reference: ", i[3]),
                               spaces, prefix)], cons := false );
                if kind = 1 and not GLOBAL_ALERT then
                    GUAVA_TEMP_VAR := [n, k];
                    ReadPkg( "guava",  
                            Concatenation( "tbl/codes", String(q), ".g" ) );
                    if GUAVA_TEMP_VAR = false then
                        GLOBAL_ALERT := true;
                    fi;
                    obj.cons := GUAVA_TEMP_VAR;
                fi;
                return obj;
            elif i[1] = 4 then  # Construction B
                obj := RecurseBound(n+i[2],k+i[2]-1, spaces, "");
                obj.cons := [ConstructionBCode, [obj.cons]];
                Add(obj.expl, InfoLine(n, k, obj.d, Concatenation(
                                    "by contruction B (deleting ",String(i[2]),
                                    " coordinates of a word in the dual)"),
                                    spaces, prefix) );
                Unbind(obj.lastman);
                return obj;
            elif i[1] = 5 then  # u | u+v construction
                obj := RecurseBound(n/2,   i[2], spaces + 4, "C1: ");
                obj2 :=RecurseBound(n/2, k-i[2], spaces + 4, "C2: ");
                obj.d := Minimum( 2 * obj.d, obj2.d );
                obj.cons := [UUVCode,[obj.cons, obj2.cons]];
                obj.expl := Concatenation(obj2.expl, obj.expl);
                Add(obj.expl, InfoLine(n, k, obj.d, 
                        "u|u+v construction of C1 and C2:", spaces, prefix));
                Unbind(obj.lastman);
                return obj;
            elif i[1] = 6 then  # Concatenation
                obj  := RecurseBound(n-i[2], k, spaces + 4, "C1: ");
                obj2 := RecurseBound(i[2],   k, spaces + 4, "C2: ");
                obj.cons := [ConcatenationCode,[obj.cons, obj2.cons]];
                obj.d := obj.d + obj2.d;
                obj.expl := Concatenation(obj2.expl, obj.expl);
                Add(obj.expl, InfoLine(n, k, obj.d, 
                        "concatenation of C1 and C2:", spaces, prefix));
                Unbind(obj.lastman);
                return obj;
            elif i[1] = 7 then  # ResidueCode
                obj := RecurseBound(i[2], k+1, spaces, "");
                obj.d := QuoInt(obj.d, q) + SignInt(obj.d mod q);
                Add(obj.expl, InfoLine(n, k, obj.d, "residue code of:", spaces,
                                    prefix) );
                obj.cons := [ResidueCode, [obj.cons]];
                Unbind(obj.lastman);
                return obj;
            elif i[1] = 14 then  # Construction B
                obj := RecurseBound(n-i[2], k-i[2]+1, spaces, "");
                Add(obj.expl, InfoLine(n, k, obj.d,
                        "otherwise construction B would contradict:", spaces,
                        prefix) );
                Unbind(obj.lastman);
                return obj;
            else
                Error("invalid table entry; table is corrupted");
            fi;
        fi;
    end;
#F              Function body
    
	
	if Length(arg) < 2 or Length(arg) > 4 then
        Error("usage: OptimalLinearCode( <n>, <k> [, <F>] )");
    fi;
    n := arg[1];
    k := arg[2];
    q := 2;
    if Length(arg) > 2 then
        if IsInt(arg[3]) then
            q := arg[3];
        else
            q := Size(arg[3]);
        fi;
    fi;
    if k > n then
        Error("k must be less than or equal to n");
    fi;
    # Check that right tables are present
    if not IsBound(GUAVA_REF_LIST) or Length(RecNames(GUAVA_REF_LIST))=0 then
        ReadPkg( "guava", "tbl/refs.g" );
    fi;
    res := rec(n := n,
               k := k,
               q := q,
               references := rec(),
               construction := false); 
    if not ( IsBound(GUAVA_BOUNDS_TABLE[1][q]) and
             IsBound(GUAVA_BOUNDS_TABLE[2][q]) ) and
       q > 4 then
        # Left the following lines out and replaced them with the previous,
        # and the else-part of this if, because using READ in
        # this way does not work in GAP 3.5.
        # (the behaviour of LOADED_PACKAGES has changed)
#       not READ(Concatenation(LOADED_PACKAGES.guava, "tbl/bdtable",
#               String(q),".g")) then       
        res.lowerBound := 1;
        res.upperBound := n - k + 1;
        return res;
#        Error("boundstable for q = ", q, " is not implemented.");
    else
        ReadPkg( "guava", Concatenation( "tbl/bdtable", String(q), ".g" ) );
    fi;
    if n > Length(GUAVA_BOUNDS_TABLE[1][q]) then
        # no error should be returned here, otherwise Upper and
        # LowerBoundMinimumDistance would not work. The upper bound
        # could easely be sharpened by the Griesmer bound and
        # if n - k > Sz then
        #     upperbound >= n - k + 1;
        # else
        #     upperbound <= Ub[ Sz ][ k - n + Sz ]
        # fi;
        # lowerbound >= Lb[ Sz ][Minimum(Sz, k)]

        res.lowerBound := 1;
        res.upperBound := n - k + 1;
        return res;
#        Error("no data for n > ", Length(GUAVA_BOUNDS_TABLE[1][q]));
    fi;
    if Length(arg) < 4 or arg[4] then
        kind := 1;
        GLOBAL_ALERT := (Length(arg) = 4);
        obj := RecurseBound( n, k, 0, "");
        if not GLOBAL_ALERT then
            res.construction := obj.cons;
        fi;
        res.lowerBound := obj.d;
        res.lowerBoundExplanation := Reversed( obj.expl );
    fi;
    if Length(arg) < 4 or not arg[4] then
        kind := 2;
        obj := RecurseBound( n, k, 0, "");
        res.upperBound := obj.d;
        res.upperBoundExplanation := Reversed( obj.expl );
    fi;
    return res;
end);
 
 
#############################################################################
##
#F  StringFromBoundsInfo . . . . . . .  functions for bounds record
##  PrintBoundsInfo  . . . . . . . . .  
##  DisplayBoundsInfo  . . . . . . . .  
## 

##  These functions are not automatically called.  The user must 
##  specifically call them if desired.  They are intended for use 
##  with the Bounds Info record returned by the BoundsMinimumDistance 
##  function only.  They replace the BoundsOps functions of the GAP3 
##  version of GUAVA and provide a way to neatly print and display 
##  the information returned by BoundsMinimumDistance.  
##  Ex: PrintBoundsInfo(BoundsMinimumDistance(13,5,3)); 
## 

StringFromBoundsInfo := function(R)
    local line;
    line := Concatenation("an optimal linear [", String(R.n), ",",
                    String(R.k), ",d] code over GF(", String(R.q), ") has d");
    if R.upperBound <> R.lowerBound then
        Append(line,Concatenation(" in [", String(R.lowerBound),"..",
                String(R.upperBound),"]"));
    else
        Append(line,Concatenation("=",String(R.lowerBound)));
    fi;
    return line;
end;

PrintBoundsInfo := function(R)
    Print(StringFromBoundsInfo(R), "\n");
end;

DisplayBoundsInfo := function(R)
    local i, ref;
    PrintBoundsInfo(R);
    if IsBound(R.lowerBoundExplanation) then
        for i in [1..SizeScreen()[1]-2] do Print( "-" ); od; Print( "\n" );
        for i in R.lowerBoundExplanation do
            Print(i, "\n");
        od;
    fi;
    if IsBound(R.upperBoundExplanation) then
        for i in [1..SizeScreen()[1]-2] do Print( "-" ); od; Print( "\n" );
        for i in R.upperBoundExplanation do
            Print(i, "\n");
        od;
    fi;
    if IsBound(R.references) and Length(RecNames(R.references)) > 0 then
        for i in [1..SizeScreen()[1]-2] do  Print( "-" ); od; Print( "\n" );
        for i in RecNames(R.references) do
            Print("Reference ", i, ":\n");
            for ref in R.references.(i) do
                Print(ref, "\n");
            od;
        od;
    fi;
end;


