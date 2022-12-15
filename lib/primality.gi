#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Jack Schmidt.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains declarations for the primality test in the integers.
##

##  This file is meant to improve the primality testing in GAP in two
##  significant ways. (1) IsProbablyPrimeInt has been sped up, and perhaps
##  been better documented. (2) IsPrimeInt can now use N+-1 primality proving
##  algorithms to prove primality (proofs can be produced for all primes
##  less than 10^18, and for most primes up to 10^50 or more). A proof
##  verifier is included to demonstrate the simplicity of the proofs.
##
##  This file is split into five parts.
##
##  (1) Prerequisites, including efficient IsSquareInt
##  routine. Some short tables are also included.
##
##  (2) The optimized Baillie-Pomerance-Selfridge-Wagstaff
##  pseudoprimality test with subtests properly labelled and explained,
##  and bounds given at a more precise level.
##
##  (3) The primality proof production code, which finds a machine
##  verifiable proof for the primality of a (probable) prime. It is
##  based on the paper Brillhart, Lehmer, Selfridge's "New Primality
##  Criteria and Factorizations of 2^m +-1", 1975, hereafter referred
##  to as BLS1975. This paper is available on JSTOR and is very clearly
##  written.
##
##  (4) The primality proof verifier, which detects if the proposed
##  proof in fact satisfies the conditions of one of the results in BLS1975.
##
##  (5) A pretty interface to GAP, with result caching and warnings in
##  the rare event IsPrimeInt is unable to prove primality.
##
#T  Further work: The following would be good future tasks for the
#T  interested developer:
#T
#T  (1) Recursive verification: It is standard for primality proofs
#T  to require "lemmas" where other numbers are proved prime as well.
#T  Currently I make no use of this (and it is not needed for N < 10^18)
#T  so it is not implemented.
#T
#T  (2) Theoretical extensions of BLS1975: one should be able to more
#T  carefully handle the case of multiple composite factors of N+-1
#T  in the earlier portions of the paper, to bring results like Theorem 21
#T  into wider use.
#T
#T  (3) Other tests: One can easily verify ECPP machine proofs, and they
#T  can coexist in the current format. Unfortunately finding ECPP proofs
#T  is a difficult task. Another test, the APRCL, might also be suitable.
#T  However, verification of its certificates is extremely complex and
#T  some experts warn "the probability of an implementation error in the
#T  verification routine is much higher than the probability that a
#T  composite BPSW is found". GAP does have rudimentary support for the
#T  needed algebraic structures, but initial testing shows the overhead
#T  of arithmetic in these rings is an insurmountable obstacle for N in
#T  in the appropriate range.
#T
#T  (4) Direct interface to PARI-lib. For a number of reasons, it might
#T  be advantageous to allow use of PARI from within GAP.
##
##  Testing: All primes < 10^7 tested. All 236021 "Brent factors" tested,
##  but two such primes could not be proven prime (1.8*10^104 and 3.2*10^86).
##
##############################################################################

##############################################################################
##
##  Section 1: Prerequisites
##
##  (a) record our tables of small primes and pseudoprimes
##  (b) Define IsSquareInt
##
##############################################################################


##############################################################################
##
##  Tables - We define a table
##  CompositeSPP2 which contains a list of
##  the composite numbers < 10^7 that are strong pseudoprimes for
##  base 2, and that have no prime factors < 1000.
##
##############################################################################

BindGlobal("CompositeSPP2",
  [ 1194649, 1678541, 2284453, 2304167, 3090091, 3125281,
  3375041, 3400013, 3898129, 4181921, 4360621, 4469471,
  4513841, 4863127, 5044033, 5173169, 5489641, 5919187,
  6226193, 6233977, 6368689, 6787327, 6952037, 7306261,
  7306561, 7820201, 8036033, 8095447, 8725753, 9006401,
  9056501, 9371251, 9729301, 9863461 ]);

MakeImmutable(CompositeSPP2);

##############################################################################
##
##  Caches - install flushable values into the cache if they are not already
##  installed.
##
##############################################################################
InstallFlushableValue(PrimesProofs,[]);
if IsHPCGAP then
    ShareSpecialObj(PrimesProofs);
fi;

##############################################################################
##
#F  IsSquareInt - Check if an integer is a square
##
##  Simple implementation based on the ideas in Cohen's CCANT, Algorithm 1.7.3.
##  Briefly, check if N is a quadratic residue modulo some small prime powers,
##  then test if it is equal to the square of its integer square root.
##
##  Please note: This is unimaginably faster than the simpler RootInt(n)^2=n
##  because of the initial residue tests.
##
##############################################################################
BindGlobal("CCANT_1_7_3_q11",List([1..11],i->0));
BindGlobal("CCANT_1_7_3_q63",List([1..63],i->0));
BindGlobal("CCANT_1_7_3_q64",List([1..64],i->0));
BindGlobal("CCANT_1_7_3_q65",List([1..65],i->0));

Perform([0..32], function(t)
    CCANT_1_7_3_q11[(t^2 mod 11)+1]:=1;
    CCANT_1_7_3_q63[(t^2 mod 63)+1]:=1;
    CCANT_1_7_3_q64[(t^2 mod 64)+1]:=1;
    CCANT_1_7_3_q65[(t^2 mod 65)+1]:=1;
end);
MakeImmutable(CCANT_1_7_3_q11);
MakeImmutable(CCANT_1_7_3_q63);
MakeImmutable(CCANT_1_7_3_q64);
MakeImmutable(CCANT_1_7_3_q65);

BindGlobal("CCANT_1_7_3",
function(n)
local t,r,q;
  if n < 0 then return false; fi;
  t:= n mod 64;
  if(CCANT_1_7_3_q64[t+1]=0) then return false; fi;
  r:= n mod 45045;
    if(CCANT_1_7_3_q63[(r mod 63)+1]=0) then return false;
  elif(CCANT_1_7_3_q65[(r mod 65)+1]=0) then return false;
  elif(CCANT_1_7_3_q11[(r mod 11)+1]=0) then return false;
  else q:=RootInt(n);
    return n=q^2;
  fi;
end);

InstallGlobalFunction(IsSquareInt,CCANT_1_7_3);


##############################################################################
##
#F  LucasMod(P,Q,N,k) - return the reduction modulo N of the k'th terms of
##  the Lucas Sequences U,V associated to x^2+Px+Q.
##
##  Iterative version allows larger k (better=constant in N) memory use and
##  is about twice as fast as the recursive version for k around 1000. This
##  should be callable for k around 2^100000 or so (runtime is log(k)), but
##  the size of N is the biggest concern.
##
InstallMethod(LucasMod,
"iterative method",
[IsInt,IsInt,IsInt,IsInt],
1,
function(P,Q,N,K)
    local Um,Vm,Qm,U2m,V2m,Q2m,U2mp1,V2mp1,Q2mp1,k,s,d,i,P2m4Q,T;
    P2m4Q := P*P-4*Q;
    s := SignInt(K);
    k := AbsInt(K);
    d := LogInt(k+1,2);
    T := 2^d;
    Um := 0;
    Vm := 2 mod N;
    Qm := 1 mod N;
    for i in [d,d-1..0] do
        # T = 2^i
        # k is the 0 through i'th least significant bits of |K|
        # "T <= k" means the i'th bit of |K| is set.
        # If we have found [Um,Vm,Qm]=Lucas(P,Q,m) for m = QuoInt(|K|,2*T),
        # then we can find [Un,Vn,Qn]=Lucas(P,Q,n) for n = QuoInt(|K|,T)
        # using n = 2*m + (i'th bit of |K| is set)
        U2m := Um*Vm mod N;
        V2m := (Vm*Vm - 2*Qm) mod N;
        Q2m := Qm*Qm mod N;
        if T <= k then # replace m with n = 2m+1
            U2mp1 := (P*U2m + V2m)/2 mod N;
            V2mp1 := (P2m4Q*U2m + P*V2m)/2 mod N;
            Q2mp1 := Q2m*Q mod N;
            Um := U2mp1;
            Vm := V2mp1;
            Qm := Q2mp1;
            k := k - T;
        else # replace m with n = 2m
            Um := U2m;
            Vm := V2m;
            Qm := Q2m;
        fi;
        T := T/2;
    od;
    if s < 0 then
        Um := -Um/Qm mod N;
        Vm := Vm/Qm mod N;
        Qm := 1/Qm mod N;
    fi;
    return [Um,Vm,Qm];
end);


##############################################################################
##
##  Section 2: Baillie-Pomerance-Selfridge-Wagstaff pseudoprimality test
##
##  (1) IsStrongPseudoPrimeBaseA
##  (2) IsLucasPseudoPrime (the BPSW version with hardcoded discriminant)
##  (3) IsBPSWPsuedoPrime - main interface to optimized test
##
##############################################################################


##############################################################################
##
#F  IsStrongPseudoPrimeBaseA(N,A) - If A does not have odd multiplicative
##  order mod N, then check -1 in <A>.
##
##############################################################################
InstallGlobalFunction(IsStrongPseudoPrimeBaseA,
function(n,A)
  local e,o,i,x;
  # find $e$ and $o$ odd such that $n-1 = 2^e * o$
  e := 0; o := n-1;   while o mod 2 = 0 do e := e+1; o := o/2; od;
  # look at the seq $A^o, A^{2 o}, A^{4 o}, .., A^{2^e o}=A^{n-1}$
  x := PowerModInt( A, o, n );
  i := 0;
  while i < e and x <> 1 and x <> n-1 do
    x := x * x mod n;
    i := i + 1;
  od;
  # if it is not of the form $.., -1, 1, 1, ..$ then $n$ is composite
  return (x = n-1 or (i = 0 and x = 1));
end);

#
BindGlobal("TraceModQF", function ( p, k, n )
  local kb, trc, i;
  kb := [];
  while k <> 1 do
    if k mod 2 = 0 then
      k := k/2;
      Add(kb, 0);
    else
      k := (k+1)/2;
      Add(kb, 1);
    fi;
  od;
  trc := [p, 2];
  i := Length(kb);
  while i >= 1 do
    if kb[i] = 0 then
      trc := [ (trc[1]^2 - 2) mod n, (trc[1]*trc[2] - p) mod n ];
    else
      trc := [ (trc[1]*trc[2] - p) mod n, (trc[2]^2 - 2) mod n ];
    fi;
    i := i-1;
  od;
  return trc;
end);

##############################################################################
##
#F  IsBPSWLucasPseudoPrime(N) - Check if N is a Lucas pseudoprime for
##  x^2+P*x+1 where P is the smallest positive integer such that P^2 - 4 is
##  not a square mod N. N should be odd. N should be prime or greater
##  than 100.
##
##############################################################################
InstallGlobalFunction(IsBPSWLucasPseudoPrime,
function(N)
  local P;
  if N = 2 then return true; fi;
  if IsSquareInt(N) or IsEvenInt(N) then return false; fi;
  P:=2;
  while Jacobi( P^2-4, N ) <> -1 do P:=(P+1) mod N; if P = 2 then return fail; fi; od;
  return TraceModQF(P,N+1,N) = [2,P];
end);

##  There are several variations on how to choose the parameters for the Lucas
##  test. The first two are based on PSW1980, p1024, and are also found in
##  BW1980, p1401. The next two parameter choices are from BW1980 p1409.
##  The next is reported to be a suggestion of Wei Dei. The final is the version
##  used by GAP, which was the fastest in the tests I ran. GAP was 5% faster
##  than the fastest of the other variants, and with TraceModQF function, was
##  twice as fast. Therefore the following code is simply commented out, and
##  the hard-wired version left. JS

#BPSWLucasParameters_PSW1980_A := function(N)
#  local D,o;
#  D:=5; o:=1;
#  while Jacobi(D,N) <> -1 do D:=(-D-2*o) mod N; o:=-o; od;
#  return [D,1,(1-D)/4 mod N];
#end;
#BPSWLucasParameters_PSW1980_B := function(N)
#  local D,P;
#  D:=5;
#  while Jacobi(D,N) <> -1 do D:=D+4; od;
#  P:=RootInt(D);
#  P:=P + ((P+1) mod 2);
#  while P^2 < D do P:=P+2; od;
#  return [D mod N,P mod N,(P^2-D)/4 mod N];
#end;
#BPSWLucasParameters_BW1980_Astar := function(N)
#  local D,o;
#  D:=5; o:=1;
#  while Jacobi(D,N) <> -1 do D:=(-D-2*o) mod N; o:=-o; od;
#  if (1-D)/4 mod N in [1,N-1] then return [5,5,5]; fi;
#  return [D,1,(1-D)/4 mod N];
#end;
#BPSWLucasParameters_BW1980_Bstar := function(N)
#  local D,P;
#  D:=5;
#  while Jacobi(D,N) <> -1 do D:=D+4; od;
#  P:=RootInt(D);
#  P:=P + ((P+1) mod 2);
#  while P^2 < D do P:=P+2; od;
#  if (P^2-D)/4 mod N in [1,N-1] then return [D,(P+2) mod N,(P+(P^2-D)/4 + 1) mod N]; fi;
#  return [D mod N,P mod N,(P^2-D)/4 mod N];
#end;
#BPSWLucasParameters_WeiDei := function(N)
#  local D,k;
#  k:=1;
#  while Jacobi((2*k+1)^2 - 4,N) = 1 do k:=k+1; od;
#  D:=(2*k+1)^2 - 4;
#  return [D,1,(1-D)/4];
#end;
#BPSWLucasParameters_GAP := function(N)
#  local P;
#  P:=2;
#  while Jacobi( P^2-4, N ) <> -1 do P:=(P+1) mod N; if P = 2 then return fail; fi; od;
#  return [ (P^2-4) mod N, P, 1 ];
#end;
#InstallGlobalFunction(IsBPSWLucasPseudoPrime,
#function(N)
#  local params, func, lucas;
#  if N = 2 then return true; fi;
#  if IsSquareInt(N) or IsEvenInt(N) then return false; fi;
#  if ValueOption("BPSWLucasParameters") = fail
#  then func:=BPSWLucasParameters_GAP;
#  else func:=ValueOption("BPSWLucasParameters");
#  fi;
#  if ValueOption("BPSWLucasTest") = fail then
#    if func = BPSWLucasParameters_GAP
#    then lucas:=function(N,D,P) return TraceModQF(P,N+1,N) = [2,P]; end;
#    else lucas:=IsLucasPseudoPrimeDP;
#    fi;
#  else lucas:=ValueOption("BPSWLucasTest");
#  fi;
#  params := CALL_FUNC_LIST(func,[N]);
#  if Jacobi(params[1],N) = 0 and params[1] < N and 0 < params[1] then return false; fi;
#  return CALL_FUNC_LIST(lucas,[N, params[1], params[2]]);
#end);

##############################################################################
##
#F  IsLucasPseudoPrimeDP(N,D,P) - Check if N is a Lucas pseudoprime for
##  x^2+P*x+(P^2-D)/4. D must be a nonsquare mod N, and N must be odd or prime.
##
##############################################################################
InstallGlobalFunction(IsLucasPseudoPrimeDP,
function(N,D,P)
  local Q;
  if N = 2 then return true; fi;
  Q := (P^2-D)/4 mod N;
  if not ( IsOddInt(N) and 0 <> Q mod N and Jacobi(D,N) = -1 ) then Error(); fi;
  return IsOddInt(N) and 0 <> Q mod N and Jacobi(D,N) = -1 and 0 = LucasMod(P,Q,N,N+1)[1];
end);

##############################################################################
##
#F  IsStrongLucasPseudoPrimeDP(N,D,P) - Check if N is a strong Lucas
##  pseudoprime for x^2+P*x+(P^2-D)/4. N must be odd or prime.
##
##############################################################################
InstallGlobalFunction(IsStrongLucasPseudoPrimeDP,
function(N,D,P)
  local Q,d,s,J,L,r,Qi;
  if N = 2 then return true; fi;
  if N in [-1,0,1] then return false; fi;
  if not ( IsOddInt(N) and GcdInt(N,D)=1 ) then return false; fi;
  Q := (P^2-D)/4 mod N;
  J := Jacobi(D,N);
  d := N - J; s:=0; while IsEvenInt(d) do s:=s+1; d:=d/2; od; # Now N-(D/N) = 2^s * d, d odd
  L := LucasMod(P,Q,N,d);
  # Does n divide U_d ?
  if L[1] = 0 then return true; fi;
  # Does n divide V_{2^r d} for some r=0,1,...,s-1 ?
  Qi := PowerModInt(Q,d,N);
  for r in [0..s-1] do
    if L[2] = 0 then return true; fi;
    # L is [Ui,Vi], make it [U2i,V2i] = [ Ui*Vi, Vi^2 - 2Q^i], where i=2^s d
    L[1] := L[1]*L[2] mod N;
    L[2] := (L[2]^2 - 2*Qi) mod N;
    Qi   := Qi*Qi mod N;
  od;
  return false;
end);

##############################################################################
##
#F  IsBSPWPseudoPrime(N) - Check if N is a Baillie-Pomerance-Selfridge-Wagstaff
##  pseudoprime (that is, N is a possibly composite number with no proper
##  divisors less than 1000, N is a strong pseudoprime base 2, and N is a
##  Lucas pseudoprime as above.
##
##############################################################################
InstallGlobalFunction(IsBPSWPseudoPrime,
function(n)
  # Step 1 handle n with prime factors < 103
  # 1a: if n < 103, then n is prime exactly when it is listed
  # 1b: if n is even and >=103, then it is not prime
  # 1c-g: if n has a prime factor < 103, then it is not coprime
  # to 3*5*..*101 split up into factors < 2^28.
  # 1h: A composite number with no factors < 103 must itself be >= 103^2
  n := AbsInt(n);
  if n < 1000 then return n in Primes;
  elif 0 = n mod 2 then return false;
  elif 1<>GcdInt(n,257041785) then return false; # 3*5*7*11*13*17*19*53
  elif 1<>GcdInt(n, 11559991) then return false; # 83*79*43*41
  elif 1<>GcdInt(n,259860509) then return false; # 89*73*47*37*23
  elif 1<>GcdInt(n, 12596323) then return false; # 97*71*59*31
  elif 1<>GcdInt(n, 11970823) then return false; # 101*67*61*29
  elif n < 10609 then return true;
  fi;

  # Step 2 handle n with prime factors < 1000
  # Note that if n < 1000 we have already finished.
  # 2a: Check Gcd(n,Product(Primes{[27..168]}) = 1
  # 2b: If n < 1009^2 is composite, then it has a prime factor < 1009
  if 1<>GcdInt(n,
841284107844892882230924743483896036230303226400884429367479745\
182396425076313801080105888842525657179186823477095844441732607\
309415612117497325122570590402649274666448191740488756513678929\
402959775310209214502833707784648441319210161128261125112776114\
119620471154579797706399078932717575475133487349361392344929340\
84356041841547537781640044258066541550710400764797315999285813)
  then return false;
  elif n < 1018081 then return true;
  fi;

  # Step 3 check if strong pseudo-prime base 2
  # 3a: check for strong pseudo-prime base
  # 3b: the composite pseudo-primes base 2 less than 10^7 with no
  # factors < 1000 are listed in CompositeSPP2
  if not IsStrongPseudoPrimeBaseA(n,2) then return false;
  elif n < 10^7 then return not n in CompositeSPP2;
  fi;

  # Step 4 Check for Lucas pseudo prime
  if not IsBPSWLucasPseudoPrime(n) then return false;
  fi;

  # Step 5 Give up and call it a pseudoprime.
  return true;
end);

#############################################################################
##
##  Note by http://www.trnicely.net/misc/bpsw.html we have that if
##  N < 2^64 is a BPSW-pp, then N is in fact prime.
##
#############################################################################
BindGlobal("BPSW_ProvedBound", 2^64);

#############################################################################
##
##  Section 3: Primality proof production, based on BLS 1975
##
##  (1) Find witnesses for each divisor (either Fermat or Lucas)
##  (2) Suitable Factor N+-1 to decide which witness are needed
##  (3) Main routine
##  (4) Simpler main routine which appears to be very adequate
##
#############################################################################

##  Applicability: A number of results are used from BLS1975, but perhaps
##  Theorem 21 has the widest theoretical use. In short, if one factors
##  the odd parts of N+-1 into E,F (possibly composite) factors each of
##  which has no prime divisors less than B and into various smaller prime
##  factors, and if N < B^(E+F+Max(E,F)), then Fermat and Lucas witnesses
##  for those factors suffice to prove primality. In particular, if N < B^3,
##  then we will succeed in our proof production. Currently GAP's FactorsInt
##  gives us a value of B=10^6, and applicability for N < 10^18.

##############################################################################
##
#F  PrimalityProof_FindFermat(N,P) - find a base A such that
##  N is a strong Fermat pseudoprime base A and such that
##  GcdInt(A^((N-1)/P)-1,N)=1.
##
##  Return [true,A] if such a base is found, or [false,B] if N
##  has been proven composite (where B may help to verify this).
##
##############################################################################
InstallGlobalFunction(PrimalityProof_FindFermat,
function(N,p)
  local Np,a,b,c,g;
  Np:=(N-1)/p;
  a:=2;
  while true do
    b:=PowerModInt(a,Np,N);
    if(1<>b) then break; fi;
    a:=a+1;
    if(a=N) then return [fail]; fi;
  od;
  c:=PowerModInt(b,p,N);
  if(1 <> c) then return [false,a]; fi;
  g:=GcdInt(b-1,N);
  if 1 < g and g < N then return [false,g]; fi;
  return [true,a];
end);

##############################################################################
##
#F  PrimalityProof_FindLucas(N,D,K) - Find a polynomial
##  x^2+P*x+Q with discriminant D=P^2-4Q such that the
##  associated LucasSequence U satisfies U(N+1) = 0 mod N
##  and Gcd(U((N+1)/K),N)=1.
##
##  Return [true,P] if such a polynomial is found, and
##  [false,B] if N is shown to be composite (where B
##  may help to verify this).
##
##############################################################################
InstallGlobalFunction(PrimalityProof_FindLucas,
function(N,D,K)
  local P,Q,g;
  P:=2;
  Q:=((P^2-D)/4) mod N;
  while true do
    if 0 <> LucasMod(P,Q,N,N+1)[1] then return [false,P,Q]; fi;
    g:=GcdInt(N, LucasMod(P,Q,N,(N+1)/K)[1]);
    if 1<g and g<N then return [false,g];
    elif 1=g then return [true,P];
    fi;
    Q:=(Q+P+1) mod N;
    P:=(P+2) mod N;
    if(P=0) then return [fail]; fi;
  od;
end);


##############################################################################
##
#F  PrimalityProof_FindStructure(N) - Find divisors of N+-1 which can be
##  used to prove primality of N based on the ideas in BLS1975.
##
##  The return value is a list of pairs [T,div] where T is the name of a test
##  (either "F" or "L") and div is a divisor of N+-1.
##
##  This routine requires a partial factorization routine.
##
##############################################################################
InstallGlobalFunction(PrimalityProof_FindStructure,
function(N)
  local cheap, FactIntPartial, factorsp, factorsm, sqrtN,
    F1s, F1, R1, F2s, F2, R2, B, to_check, p, s, r;

  cheap:=ValueOption("cheap");
  FactIntPartial:=ValueOption("FactIntPartial");
  if(cheap=fail) then cheap:=true; fi;
  if(FactIntPartial=fail) then FactIntPartial:=true; fi;

  # try straightforward method first
  if cheap=true and FactIntPartial=true then
    to_check:=Concatenation(
      List(Set(PartialFactorization(N-1,7 : cheap)),p->["F",p]),
      List(Set(PartialFactorization(N+1,7 : cheap)),p->["L",p]));
    if [] <> PrimalityProof_VerifyStructure(N,to_check)
    then return to_check;
    else Info(InfoPrimeInt,1,"Straightforward Fermat-Lucas primality proof failed on ",N);
    fi;
  fi;

  sqrtN:=RootInt(N);
  B:=10^6;

  factorsm:=Factors(N-1 : cheap:=cheap, FactIntPartial:=FactIntPartial);

  if not IsList(factorsm[1]) then
    factorsm:=[factorsm,[1]];
  fi;
  F1s:=Set(factorsm[1]);
  F1:=Product(factorsm[1]);
  R1:=Product(factorsm[2]);

  # BLS1975 Cor1
  if F1 > sqrtN then
    F1:=1;
    to_check:=[];
    for p in Reversed(F1s) do
      AddSet(to_check,p);
      F1:=F1*p^Number(factorsm[1],q->p=q);
      if(F1 > sqrtN) then break; fi;
    od;
    return List(to_check,p->["F",p]);
  # BLS1975 Cor3
  elif B*F1 > sqrtN then
    to_check:=F1s;
    AddSet(to_check,R1);
    return List(to_check,p->["F",p]);
  fi;
  s:=QuoInt(R1,2*F1);
  r:=2*F1*s-R1;
  # BLS1975 Th7
  if N < (B*F1+1)*(2*F1^2+(r-B)*F1+1) and (s=0 or not IsSquareInt(r^2-8*s)) then
    to_check:=F1s;
    AddSet(to_check,R1);
    return List(to_check,p->["F",p]);
  fi;

  factorsp:=Factors(N+1 : cheap:=cheap, FactIntPartial:=FactIntPartial);
  if not IsList(factorsp[1]) then
    factorsp:=[factorsp,[1]];
  fi;
  F2s:=Set(factorsp[1]);
  F2:=Product(factorsp[1]);
  R2:=Product(factorsp[2]);

  # BLS1975 Cor8
  if F2 > sqrtN + 1 then
    F2:=1;
    to_check:=[];
    for p in Reversed(F2s) do
      AddSet(to_check,p);
      F2:=F2*p^Number(factorsp[1],q->p=q);
      if F2 > sqrtN + 1 then break; fi;
    od;
    return List(to_check,p->["L",p]);
  # BLS1975 Cor3
  elif B*F2 > sqrtN then
    to_check:=F2s;
    AddSet(to_check,R2);
    return List(to_check,p->["L",p]);
  fi;
  s:=BestQuoInt(R2,2*F2);
  r:=R2-2*F2*s;
  # BLS1975 Th19
  if N < (B*F2-1)*(2*F2^2 + (B-AbsInt(r))*F2 + 1) and (s=0 or not IsSquareInt(r^2+8*s)) then
    to_check:=F2s;
    AddSet(to_check,R2);
    return List(to_check,p->["L",p]);
  fi;

  # BLS1975 Cor11
  if B^3*F1^2*F2 > 2*N or B^3*F1*F2^2 > 2*N then
    return Union(List(F1s,p->["F",p]),List(F2s,p->["L",p]),[ ["F",R1], ["L",R2]]);
  fi;

  if cheap = true then return PrimalityProof_FindStructure(N:cheap:=false); fi;

  return fail;
end);

##############################################################################
##
#F  PrimalityProof(N) - Construct a machine verifiable proof of the primality
##  of (the probable prime) N, following the ideas of the paper Brillhart,
##  Lehmer, Selfridge's "New Primality Criteria and Factorizations of 2^m +-1",
##  1975.
##
##############################################################################
InstallGlobalFunction(PrimalityProof,
function(N)
  local factors,certs,D,J,p,ret;

  if(N<=2) then return fail;
  elif 0 = N mod 2 then return false;
  fi;

  factors:=PrimalityProof_FindStructure(N);
  if(factors=fail) then return fail; fi;

  if(ForAny(factors,p->p[1]="L")) then
    D:=1;
    repeat
      D:=(D+1) mod N;
      if(D=0) then Error(); return fail; fi;
      J:=Jacobi(D,N);
      if(J=0) then Error(); return false; fi;
    until J=-1;
  fi;
  certs:=[];
  for p in factors do
    if p[1]="F" then
      ret:=PrimalityProof_FindFermat(N,p[2]);
      if(ret[1]=fail) then
        Print("\n\n");
        Print("# !!! Please email support@gap-system.org the following:\n");
        Print("# !!! PrimalityProof(",HexStringInt(N),") failed at F",p[2],"\n\n\n");
        Error("# !!! You have probably found a bug. Theoretically <n> is composite.");
        return fail;
      elif(ret[1]=false) then
        if 0 = N mod ret[2] and 1<ret[2] and ret[2]<N
        then Error("# PrimalityProof: ",N," is composite (divisible by ",ret[2],").");
        elif 0 <> ret[2] mod N and 1 <> PowerModInt(ret[2],N-1,N)
        then Error("# PrimalityProof: ",N," is composite (",ret[2],"^",N-1," mod N is not 1).");
        else Error("# PrimalityProof: unknown error. N is supposedly composite.");
        fi;
        return false;
      elif(ret[1]=true) then
        Add(certs,["F",p[2],ret[2]]);
      fi;
    elif p[1]="L" then
      ret:=PrimalityProof_FindLucas(N,D,p[2]);
      if(ret[1]=fail) then
        Print("\n\n");
        Print("# !!! Please email support@gap-system.org the following:\n");
        Print("# !!! PrimalityProof(",HexStringInt(N),") failed at L",p[2],"\n\n\n");
        Error("# !!! You have probably found a bug. Theoretically <n> is composite.");
        return fail;
      elif(ret[1]=false) then
        if 0 = N mod ret[2] and 1<ret[2] and ret[2]<N
        then Error("# PrimalityProof: ",N," is composite (divisible by ",ret[2],").");
        elif 0 <> LucasMod(ret[2],ret[3],N,N-1)[1] mod N
        then Error("# PrimalityProof: ",N," is composite (Lucas(",ret[2],",",ret[3],",N-1) mod N is not 0).");
        else Error("# PrimalityProof: unknown error. N is supposedly composite.");
        fi;
        return false;
      elif(ret[1]=true) then
        Add(certs,["L",p[2],D,ret[2]]);
      fi;
    else
      Error("Unknown certification requested.");
      return fail;
    fi;
  od;
  return certs;
end);


##############################################################################
##
##  Section 4: Primality proof verification
##
##  (1) Verify witnesses
##  (2) Verify the collection of witnesses would provide a primality proof
##  (3) Main interface
##
##############################################################################

##############################################################################
##
#F  PrimalityProof_VerifyWitness(N,witness) - ensure that the proposed
##  witness is valid. In other words check condition II or IV from BLS1975.
##
##############################################################################
InstallGlobalFunction(PrimalityProof_VerifyWitness,
function(N,witness)
  local type, divisor, base, D, P, Q;

  type:=witness[1];
  if( type = "F" ) then
    divisor := witness[2];
    base := witness[3];
    return IsStrongPseudoPrimeBaseA(N,base) and
      GcdInt( PowerModInt(base,(N-1)/divisor,N)-1, N) = 1;
  elif( type = "L" ) then
    divisor := witness[2];
    D := witness[3];
    P := witness[4];
    Q := (P^2-D)/4 mod N;
    return Jacobi(D,N)=-1 and 0 = LucasMod(P,Q,N,N+1)[1]
      and 1 = GcdInt(N, LucasMod(P,Q,N,(N+1)/divisor)[1]);
  fi;
  return fail;
end);


##############################################################################
##
#F  PrimalityProof_VerifyStructure(N,witnesses) - Verify that the collection
##  of witness actually satisfies the hypotheses of one of the results in
##  BLS1975. Failure is indicated by an empty list. Success is a list:
##  [true, NameOfTheorem, AssumedPrimes, DivisorBound, SortOfPrimes ]
##
##  In this case, the routine recognized the proof but may require
##  some lemmas. Every number in AssumedPrimes must be proven prime.
##  Every number in SortOfPrimes must either be (prime and less than
##  DivisorBound) or relatively prime to Factorial(DivisorBound).
##  DivisorBound is always small enough to make this check feasible
##  (currently capped at 10^6).
##
##############################################################################
InstallGlobalFunction(PrimalityProof_VerifyStructure,
function(N,witnesses)
  local Fs,Ls,BF,BL, MaxB, B1, B2, F1s, F2s, R1s, R2s, F1, F2, R1, R2, r, s,
    QuadraticEstimate, GotOne, rets;
  MaxB:=10^6;

  QuadraticEstimate:=function(a,b,c)
    if b^2 - 4*a*c < 0 then return 10^100; fi;
    return Int((-b + RootInt(b^2-4*a*c))/(2*a));
  end;

  GotOne:=function(ret) Add(rets,ret); end;
  rets:=[];

  Fs:=List(Filtered(witnesses,wit->wit[1]="F"),wit->wit[2]);
  Ls:=List(Filtered(witnesses,wit->wit[1]="L"),wit->wit[2]);

  # Every number in F1s and F2s is known to be prime
  F1s:=Filtered(Fs,p->p<BPSW_ProvedBound and IsBPSWPseudoPrime(p));
  R1s:=Filtered(Fs,p->p>BPSW_ProvedBound or not IsBPSWPseudoPrime(p));
  F2s:=Filtered(Ls,p->p<BPSW_ProvedBound and IsBPSWPseudoPrime(p));
  R2s:=Filtered(Ls,p->p>BPSW_ProvedBound or not IsBPSWPseudoPrime(p));

  F1:=Product(F1s, p->p^Valuation(N-1,p));
  R1:=Product(R1s, p->p^Valuation(N-1,p));
  F2:=Product(F2s, p->p^Valuation(N+1,p));
  R2:=Product(R2s, p->p^Valuation(N+1,p));

  # Check Co1
  if F1^2 > N then GotOne([ true, "BLS1975-Co1", [] , 1 , [] ]); fi;

  # Check Cor3 and Th7
  if Size(R1s)=1 and R1s[1]=R1 and F1*R1=N-1 then

    # Check Cor3, solving for B1
    B1 := RootInt( Int(N/F1^2) );
    while B1 < MaxB and N >= (B1*F1)^2 do B1:=B1+1; od;

    if B1 < MaxB and N < (B1*F1)^2
    then GotOne([ true, "BLS1975-Co3", [], B1, R1s]);
    fi;

    # Check Th7, solving for B1
    s:=QuoInt(R1,2*F1);
    r:=R1-2*F1*s;
    # Want B1 large so that N>= (B1*F1+1)*(2*F1^2+(r-B1)*F1+1)
    B1 := QuadraticEstimate( -F1^2, 2*F1^3 + r*F1^2, 2*F1^2+r*F1+1-N);
    #B1 := Int(N/(F1+1)/(2*F1^2+r*F1+1));
    while B1 < MaxB and 2*F1^2+(r-B1)*F1+1 > 0 and
      N >= (B1*F1+1)*(2*F1^2+(r-B1)*F1+1)
    do B1:=B1+1; od;

    if B1 < MaxB and N < (B1*F1+1)*(2*F1^2+(r-B1)*F1+1)
    then GotOne([ 0=s or not IsSquareInt(r^2-8*s), "BLS1975-Th7", [], B1, R1s ]);
    fi;
  fi;

  # Check Cor8
  if (F2-1)^2 > N then GotOne([ true, "BLS1975-Co8", [], 1 , [] ]); fi;

  # Check Cor10 and Th19
  if Size(R2s)=1 and R2s[1]=R2 and F2*R2=N+1 then

    # Check Cor10
    # Want large B2 such that (B2*F2-1)^2 <= N
    B2 := RootInt(Int(N/F2^2));
    while B2 < MaxB and (B2*F2-1)^2 <= N do B2:=B2+1; od;

    if B2 < MaxB and N < (B2*F2-1)^2
    then GotOne([ true, "BLS1975-Co10", [], B2, R2s ]);
    fi;

    # Check Th19
    s:=BestQuoInt(R2,2*F2);
    r:=R2-2*F2;
    # Want large B2 such that (B2*F2-1)*(2*F2^2 + (B2-|r|)*F2 +1) <= N
    B2:=QuadraticEstimate(F2^2,
      2*F2^3-F2^2*AbsInt(r),
      F2*AbsInt(r) - 2*F2^2 - 1 - N);
    while B2 < MaxB and (B2*F2-1)*(2*F2^2 + (B2-AbsInt(r))*F2 +1) <= N
    do B2:=B2+1; od;

    if B2 < MaxB and N < (B2*F2-1)*(2*F2^2 + (B2-AbsInt(r))*F2 +1)
    then GotOne([ s=0 or not IsSquareInt(r^2+8*s), "BLS1975-Th19", [], B2, R2s ]);
    fi;
  fi;

  # Check Cor11
  if ( R1=1 or (Size(R1s)=1 and R1s[1]=R1))
    and ( R2=1 or (Size(R2s)=1 and R2s[1]=R2))
  then
    B2 := RootInt( Int(N/F1/F2/Maximum(F1,F2)), 3);
    while B2 < MaxB and B2^3 <= N/F1/F2/Maximum(F1,F2) do B2:=B2+1; od;

    if B2 < MaxB and B2^3 > 2*N/F1/F2/Maximum(F1,F2)
    then GotOne([true, "BLS1975-Co11", [], B2, Set(Concatenation(R1s,R2s))]);
    fi;
  fi;

  # First check Theorem 21, which requires no primality assumptions
  # on the divisors (only a bound the proper prime factors of those
  # divisors).
  if F1*R1 = N-1 and F2*R2 = N+1 then

    BF := Sum(Fs,p->Valuation(N-1,p));
    BL := Sum(Ls,p->Valuation(N+1,p));
    B1 := RootInt(N,BF+BL+Maximum(BF,BL));
    while B1 < MaxB and N >= Maximum(B1^BF+1, B1^BL-1)*(B1^BF*B1^BL/2+1)
    do B1:=B1+1; od;

    if B1 < MaxB and N < Maximum(B1^BF+1,B1^BL-1)*(B1^BF*B1^BL/2 + 1)
      and ForAll(Combinations(Fs,2),x->GcdInt(x[1],x[2])=1)
      and ForAll(Combinations(Ls,2),x->GcdInt(x[1],x[2])=1)
    then GotOne( [true, "BLS1975-Th21", [], B1,
      Set(Concatenation( R1s,R2s))]);
    fi;
  fi;

  return rets;
end);

##############################################################################
##
#F  PrimalityProof_Verify(N,proof) - Verbosely verify a proposed primality
##  proof.
##
##############################################################################
InstallGlobalFunction(PrimalityProof_Verify,
function(N,proof)
  local theorems,theorem,x;
  theorems:=PrimalityProof_VerifyStructure(N,proof);
  if theorems = [] then return fail; fi;
  if not ForAll(proof, wit -> PrimalityProof_VerifyWitness(N,wit))
  then return false; fi;

  for theorem in theorems do
    Print("\nNumber proven prime by ",theorem[2],"\n");
    if( theorem[3] <> [] ) then Print("assuming each of ",theorem[3],
      "is prime\n"); fi;
    if theorem[5] <> [] then Print("assuming each of ", theorem[5],
      " have no nontrivial divisors less than ", theorem[4]);
      x := Product(Filtered(Primes,p->p<theorem[4]));
      if theorem[4] < Maximum(Primes) and ForAll(theorem[5], p->
        p in Primes or GcdInt(p,x)=1)
      then Print("(which is true)\n");
      else Print("\n");
      fi;
    fi;
  od;
  return true;
end);


##############################################################################
##
##  Section 5: Pretty interface
##
##  (1) Bind ProbablePrimes2
##  (2) IsPrimeIntReplacement - handle caching and warning
##  (3) IsProbablyPrimeIntReplacement - handle caching
##  (4) Optional code to replace the main gap functions
##
##############################################################################

##############################################################################
##
#F  IsPrimeInt(N) - Perform as IsPrimeInt, but use PrimalityProof
##  to avoid using any unproven primes. Store proofs in PrimesProofs.
##
##############################################################################
InstallGlobalFunction(IsPrimeInt,
function(N)
  local ret;
  N := AbsInt(N);
  if(N in Primes2) then return true; fi;
  ret:= IsBPSWPseudoPrime(N);
  if ret = false  then return false;
  elif ret = true and N < BPSW_ProvedBound then
    AddSet(Primes2,N);
    return true;
  elif ret = true then
    ret := PrimalityProof(N);
    if PrimalityProof_VerifyStructure(N,ret) <> [] then
      AddSet(Primes2,N);
      AddSet(PrimesProofs,MakeImmutable([N,ret]));
    else
      Info(InfoPrimeInt, 1,
           "IsPrimeInt: probably prime, but not proven: ", N);
      AddSet( ProbablePrimes2, N );
    fi;
    return true;
  fi;
  Error("Bad return from IsBPSWPseudoPrime");
end);

##############################################################################
##
#F  IsProbablyPrimeInt(N) - Perform as isProbablyPrimeInt
##  calling the optimized BPSW test instead of the current GAP default.
##
##  The option "RabinMillerTrials" may be passed to force additional
##  probabilistic tests to be run for larger N. The cost can be quite
##  significant for large N.
##
##############################################################################
InstallGlobalFunction(IsProbablyPrimeInt,
function(N)
  local ret, RabinMillerTrials;
  if(N in Primes2 or N in ProbablePrimes2) then return true; fi;
  ret := IsBPSWPseudoPrime(N);

  if ret = false then return false;
  # Otherwise is BPSW number, and all such < BPSW_ProvedBound are prime
  elif ret = true and N < BPSW_ProvedBound then
    AddSet(Primes2,N);
    return true;
  # Otherwise give a dose of Rabin-Miller
  else
    RabinMillerTrials := ValueOption("RabinMillerTrials");
    if RabinMillerTrials = fail then
      RabinMillerTrials:=0;
      # RabinMillerTrials:= RootInt(Maximum(0,LogInt(N,10)-13));
    elif IsFunction(RabinMillerTrials) then
      RabinMillerTrials:=RabinMillerTrials(N);
    fi;
    if ForAll([1..RabinMillerTrials],i->
      IsStrongPseudoPrimeBaseA(N,Random(3,N-1)))
    then
      AddSet(ProbablePrimes2,N);
      return true;
    # Otherwise an error or composite BPSW number has been found.
    else
      Print("\n\n");
      Print("# !!! Please email support@gap-system.org the following:\n");
      Print("# !!! BPSW failed on ",HexStringInt(N),"\n\n\n");
      Error("# !!! You have probably found a bug. Theoretically <n> is composite.");
      return false;
    fi;
  fi;
end);
