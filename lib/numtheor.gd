#############################################################################
##
#W  numtheor.gd                 GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file declares operations for integer primes.
##
Revision.numtheor_gd:=
    "@(#)$Id$";


##########################################################################
##
#V  InfoNumtheor
##
InfoNumtheor := NewInfoClass( "InfoNumtheor" );


#############################################################################
##
#F  PrimeResidues( <m> )  . . . . . . . integers relative prime to an integer
##
##  'PrimeResidues' returns the set of integers from the range  $0..Abs(m)-1$
##  that are relative prime to the integer <m>.
##
##  $Abs(m)$ must be less than $2^{28}$, otherwise the set would probably  be
##  too large anyhow.
##
PrimeResidues := NewOperationArgs( "PrimeResidues" );


#############################################################################
##
#F  Phi( <m> )  . . . . . . . . . . . . . . . . . . . Eulers totient function
##
##  'Phi' returns  the number of positive integers  less  than  the  positive
##  integer <m> that are relativ prime to <m>.
##
##  Suppose that $m = p_1^{e_1} p_2^{e_2} .. p_k^{e_k}$.  Then  $\phi(m)$  is
##  $p_1^{e_1-1} (p_1-1) p_2^{e_2-1} (p_2-1) ..  p_k^{e_k-1} (p_k-1)$.
##
Phi := NewOperationArgs( "Phi" );


#############################################################################
##
#F  Lambda( <m> ) . . . . . . . . . . . . . . . . . . .  Carmichaels function
##
##  'Lambda' returns the exponent of the group  of  relative  prime  residues
##  modulo the integer <m>.
##
##  Carmichaels theorem states that 'Lambda'  can  be  computed  as  follows:
##  $Lambda(2) = 1$, $Lambda(4) = 2$ and $Lambda(2^e) = 2^{e-2}$ if $3 <= e$,
##  $Lambda(p^e) = (p-1) p^{e-1}$ (i.e. $Phi(m)$) if $p$ is an odd prime  and
##  $Lambda(n*m) = Lcm( Lambda(n), Lambda(m) )$ if $n, m$ are relative prime.
##
Lambda := NewOperationArgs( "Lambda" );


#############################################################################
##
#F  OrderMod( <n>, <m> )  . . . . . . . .  multiplicative order of an integer
##
##  'OrderMod' returns the multiplicative order of the integer <n> modulo the
##  positive integer <m>.  If <n> and <m> are not relativ prime the order  if
##  <n> is not defined and 'OrderInt' will return 0.
##
OrderMod := NewOperationArgs( "OrderMod" );


#############################################################################
##
#F  IsPrimitiveRootMod( <r>, <m> )  . . . . . . . . test for a primitive root
##
##  'IsPrimitiveRootMod' returns  'true' if the  integer <r>  is a  primitive
##  root modulo the positive integer <m> and 'false' otherwise.
##
IsPrimitiveRootMod := NewOperationArgs( "IsPrimitiveRootMod" );


#############################################################################
##
#F  PrimitiveRootMod( <m> ) . . . . . . . .  primitive root modulo an integer
##
##  'PrimitiveRootMod' returns the smallest primitive root modulo the integer
##  <m> and 'false' if no such primitive root exists.  If the optional second
##  integer argument <start> is given 'PrimitiveRootMod' returns the smallest
##  primitive root that is strictly larger than <start>.
##
PrimitiveRootMod := NewOperationArgs( "PrimitiveRootMod" );


#############################################################################
##
#F  Jacobi( <n>, <m> ) . . . . . . . . . . . . . . . . . . . .  Jacobi symbol
##
##  'Jacobi'  returns  the  value of the  Jacobian symbol of the  integer <n>
##  modulo the nonnegative integer <m>.
##
##  A description of the Jacobi symbol and related topics can  be  found  in:
##  A. Baker, The theory of numbers, Cambridge University Press, 1984,  27-33
##
Jacobi := NewOperationArgs( "Jacobi" );


#############################################################################
##
#F  Legendre( <n>, <m> )  . . . . . . . . . . . . . . . . . . Legendre symbol
##
##  'Legendre' returns  the value of the Legendre  symbol of the  integer <n>
##  modulo the positive integer <m>.
##
##  A description of the Legendre symbol and related topics can be found  in:
##  A. Baker, The theory of numbers, Cambridge University Press, 1984,  27-33
##
Legendre := NewOperationArgs( "Legendre" );


#############################################################################
##
#F  RootMod( <n>, <k>, <m> )  . . . . . . . . . . . .  root modulo an integer
##
##  In the  second form  'RootMod' computes a  <k>th root  of the integer <n>
##  modulo the positive integer <m>, i.e., a <r> such that $r^k = n$ mod <m>.
##  If no such root exists 'RootMod' returns 'false'.
##
##  In the current implementation <k> must be a prime.
##
RootMod := NewOperationArgs( "RootMod" );


#############################################################################
##
#F  RootsMod( <n>, <k>, <m> ) . . . . . . . . . . . . roots modulo an integer
##
##  In the second form 'RootsMod' computes the <k>th roots of the integer <n>
##  modulo the positive integer <m>, ie. the <r> such that $r^k = n$ mod <m>.
##  If no such roots exist 'RootsMod' returns '[]'.
##
##  In the current implementation <k> must be a prime.
##
RootsMod := NewOperationArgs( "RootsMod" );


#############################################################################
##
#F  RootsUnityMod(<k>,<m>)  . . . . . . . .  roots of unity modulo an integer
##
##  'RootsUnityMod' returns a list of <k>-th roots of unity modulo a positive
##  integer <m>, i.e., the list of all solutions <r> of <r>^<k> = 1 mod <m>.
##
##  In the current implementation <k> must be a prime.
##
RootsUnityMod := NewOperationArgs( "RootsUnityMod" );


#############################################################################
##
#F  LogMod( <n>, <r>, <m> ) . . . . . .  discrete logarithm modulo an integer
##
LogMod := NewOperationArgs( "LogMod" );


#############################################################################
##
#F  TwoSquares(<n>) . .  representation of an integer as a sum of two squares
##
##  'TwoSquares' returns a list of two integers $x\<=y$ such that  the sum of
##  the squares of $x$ and $y$ is equal to the nonnegative integer <n>, i.e.,
##  $n = x^2+y^2$.  If no such representation exists 'TwoSquares' will return
##  'false'.  'TwoSquares' will return a representation for which the  gcd of
##  $x$  and   $y$ is  as  small  as  possible.    It is not  specified which
##  representation 'TwoSquares' returns, if there are more than one.
##
##  Let $a$ be the product of all maximal powers of primes of the form $4k+3$
##  dividing $n$.  A representation of $n$ as a sum of two squares  exists if
##  and only if $a$ is a perfect square.  Let $b$ be the maximal power of $2$
##  dividing $n$ or its half, whichever is a perfect square.  Then the minmal
##  possible gcd of $x$ and $y$ is the square root $c$ of $a b$.  The  number
##  of different minimal representation with $x\<=y$ is $2^{l-1}$, where  $l$
##  is the number of different prime factors of the form $4k+1$ of $n$.
##
##  The algorithm first finds a square root $r$ of $-1$  modulo  $n / (a b)$,
##  which must exist, and applies the Euclidean algorithm  to  $r$  and  $n$.
##  The first residues in the sequence that are smaller than $\root{n/(a b)}$
##  times $c$ are a possible pair $x$ and $y$.
##
##  Better descriptions of the algorithm and related topics can be found  in:
##  S. Wagon,  The Euclidean Algorithm Strikes Again, AMMon 97, 1990, 125-129
##  D. Zagier, A One-Sentence Proof that Every Pri.., AMMon 97, 1990, 144-144
##
TwoSquares := NewOperationArgs( "TwoSquares" );


#T ##########################################################################
#T ##
#T #F  IsResidueClass(<obj>) . . . . . . .  test if an object is a residue class
#T ##
#T IsResidueClass := function ( obj )
#T     return IsRec( obj )
#T            and IsBound( obj.isResidueClass )
#T            and obj.isResidueClass;
#T end;
#T
#T
#T ##########################################################################
#T ##
#T #F  ResidueClass(<representative>,<modulus>)  . . . .  create a residue class
#T ##
#T ResidueClass := function ( representative, modulus )
#T     local res;
#T     res := rec();
#T     res.isGroupElement  := true;
#T     res.isDomain        := true;
#T     res.isResidueClass  := true;
#T     res.representative  := representative mod modulus;
#T     res.modulus         := modulus;
#T     res.isFinite        := false;
#T     res.size            := "infinity";
#T     res.domain          := ResidueClasses;
#T     res.operations      := ResidueClassOps;
#T     return res;
#T end;
#T
#T ResidueClassOps := MergedRecord( GroupElementOps, DomainOps );
#T
#T ResidueClassOps.\= := function ( l, r )
#T     local   isEql;
#T     if IsResidueClass( l )  then
#T         if IsResidueClass( r )  then
#T             isEql :=    l.representative = r.representative
#T                     and l.modulus        = r.modulus;
#T         else
#T             isEql := false;
#T         fi;
#T     else
#T         if IsResidueClass( r )  then
#T             isEql := false;
#T         else
#T             Error("panic, neither <l> nor <r> is a residue class");
#T         fi;
#T     fi;
#T     return isEql;
#T end;
#T
#T ResidueClassOps.\< := function ( l, r )
#T     local   isLess;
#T     if IsResidueClass( l )  then
#T         if IsResidueClass( r )  then
#T             isLess :=   l.representative < r.representative
#T                     or (l.representative = r.representative
#T                         and l.modulus    < r.modulus);
#T         else
#T             isLess := not IsInt( r ) and not IsRat( r )
#T                   and not IsCyc( r ) and not IsPerm( r )
#T                   and not IsWord( r ) and not IsAgWord( r );
#T         fi;
#T     else
#T         if IsResidueClass( r )  then
#T             isLess :=  IsInt( l ) or IsRat( l )
#T                     or IsCyc( l ) or IsPerm( l )
#T                     or IsWord( l ) or IsAgWord( l );
#T         else
#T             Error("panic, neither <l> nor <r> is a residue class");
#T         fi;
#T     fi;
#T     return isLess;
#T end;
#T
#T ResidueClassOps.\* := function ( l, r )
#T     local   prd;        # product of <l> and <r>, result
#T     if IsResidueClass( l )  then
#T         if IsResidueClass( r )  then
#T             if l.modulus <> r.modulus  then
#T                 Error( "<l> and <r> must have the same modulus" );
#T             fi;
#T             prd := ResidueClass(
#T                         l.representative * r.representative,
#T                         l.modulus );
#T         elif IsList( r )  then
#T             prd := List( r, x -> l * x );
#T         else
#T             Error("product of <l> and <r> must be defined");
#T         fi;
#T     elif IsList( l )  then
#T         if IsResidueClass( r )  then
#T             prd := List( l, x -> x * r );
#T         else
#T             Error("panic: neither <l> nor <r> is a residue class");
#T         fi;
#T     else
#T         if IsResidueClass( r )  then
#T             if IsRec( l )  and IsBound( l.operations )
#T                 and IsBound( l.operations.\* )
#T                 and l.operations.\* <> ResidueClassOps.\*
#T             then
#T                 prd := l.operations.\*( l, r );
#T             else
#T                 Error("product of <l> and <r> must be defined");
#T             fi;
#T         else
#T             Error("panic, neither <l> nor <r> is a residue class");
#T         fi;
#T     fi;
#T     return prd;
#T end;
#T
#T ResidueClassOps.\^ := function ( l, r )
#T     local    pow;
#T     if IsResidueClass( l )  then
#T         if IsResidueClass( r )  then
#T             if l.modulus <> r.modulus  then
#T                 Error("<l> and <r> must have the same modulus");
#T             fi;
#T             if GcdInt( r.representative, r.modulus ) <> 1  then
#T                 Error("<r> must be invertable");
#T             fi;
#T             pow := l;
#T         elif IsInt( r )  then
#T             pow := ResidueClass(
#T                         PowerMod( l.representative, r, l.modulus ),
#T                         l.modulus );
#T         else
#T             Error("power of <l> and <r> must be defined");
#T         fi;
#T     else
#T         if IsResidueClass( r )  then
#T             Error("power of <l> and <r> must be defined");
#T         else
#T             Error("panic, neither <l> nor <r> is a residue class");
#T         fi;
#T     fi;
#T     return pow;
#T end;
#T
#T ResidueClassOps.\in := function ( element, class )
#T     if IsInt( element )  then
#T         return (element mod class.modulus = class.representative);
#T     else
#T         return false;
#T     fi;
#T end;
#T
#T ResidueClassOps.Intersection := function ( R, S )
#T     local   I,          # intersection of <R> and <S>, result
#T             gcd;        # gcd of the moduli
#T     if IsResidueClass( R )  then
#T         if IsResidueClass( S )  then
#T             gcd := GcdInt( R.modulus, S.modulus );
#T             if     R.representative mod gcd
#T                 <> S.representative mod gcd
#T             then
#T                 I := [];
#T             else
#T                 I := ResidueClass(
#T                         ChineseRem(
#T                                [ R.representative, S.representative ],
#T                                [ R.modulus,        S.modulus ] ),
#T                         LcmInt(  R.modulus,        S.modulus ) );
#T             fi;
#T         else
#T             I := DomainOps.Intersection( R, S );
#T         fi;
#T     else
#T         I := DomainOps.Intersection( R, S );
#T     fi;
#T     return I;
#T end;
#T
#T ResidueClassOps.Print := function ( r )
#T     Print("ResidueClass( ",r.representative,", ",r.modulus," )");
#T end;
#T
#T ResidueClassOps.Group := function ( R )
#T     return ResidueClassesOps.Group( ResidueClasses, [R], R^0 );
#T end;
#T
#T
#T ##########################################################################
#T ##
#T #V  ResidueClasses  . . . . . . . . . . . . . . domain of all residue classes
#T ##
#T ResidueClasses            := Copy( GroupElements );
#T ResidueClasses.name       := "ResidueClasses";
#T ResidueClassesOps         := OperationsRecord( "ResidueClassesOps",
#T                                                GroupElementsOps );
#T ResidueClasses.operations := ResidueClassesOps;
#T
#T ResidueClassesOps.Group := function ( ResidueClasses, gens, id )
#T     local   G,          # group <G>, result
#T             gen;        # one generator from <gens>
#T     for gen  in gens  do
#T         if gen.modulus <> id.modulus  then
#T             Error("the generators must all have the same modulus");
#T         fi;
#T         if GcdInt( gen.representative, gen.modulus ) <> 1  then
#T           Error("the generators must all be prime residue classes");
#T         fi;
#T     od;
#T     G := GroupElementsOps.Group( ResidueClasses, gens, id );
#T     G.modulus    := id.modulus;
#T     G.operations := ResidueClassGroupOps;
#T     return G;
#T end;
#T
#T
#T ##########################################################################
#T ##
#T #V  ResidueClassGroupOps  . . . . operations record of residue classes groups
#T ##
#T ResidueClassGroupOps := OperationsRecord( "ResidueClassGroupOps", GroupOps );
#T
#T ResidueClassGroupOps.Subgroup := function ( G, gens )
#T     local   S,          # subgroup of <G>, result
#T             gen;        # one generator from <gens>
#T     for gen  in gens  do
#T         if gen.modulus <> G.modulus  then
#T             Error("the generators must all have the same modulus");
#T         fi;
#T         if GcdInt( gen.representative, gen.modulus ) <> 1  then
#T           Error("the generators must all be prime residue classes");
#T         fi;
#T     od;
#T     S := GroupOps.Subgroup( G, gens );
#T     S.modulus    := G.modulus;
#T     S.operations := ResidueClassGroupOps;
#T     return S;
#T end;
#T
#T ResidueClassGroupOps.TrivialSubgroup := function ( G )
#T     local   T;
#T     T := GroupOps.TrivialSubgroup( G );
#T     Unbind( T.elements );
#T     return T;
#T end;
#T
#T ResidueClassGroupOps.SylowSubgroup := function ( G, p )
#T     local   S,          # Sylow subgroup of <G>, result
#T             gen,        # one generator of <G>
#T             ord,        # order of <gen>
#T             gens;       # generators of <S>
#T     gens := [];
#T     for gen  in G.generators  do
#T         ord := OrderMod( gen.representative, G.modulus );
#T         while ord mod p = 0  do ord := ord / p;  od;
#T         Add( gens, gen ^ ord );
#T     od;
#T     S := Subgroup( Parent( G ), gens );
#T     return S;
#T end;
#T
#T ResidueClassGroupOps.MakeFactors := function ( G )
#T     local   p, q,       # prime factor of modulus and largest power
#T             r, s,       # two rows of the standard generating system
#T             g,          # extended gcd of leading entries in <r>, <s>
#T             x, y,       # two entries in <r> and <s>
#T             i, k, l;    # loop variables
#T
#T     # find the factors of the direct product
#T     G.facts := [];
#T     G.roots := [];
#T     G.sizes := [];
#T     for p  in Set( Factors( G.modulus ) )  do
#T         q := p;
#T         while G.modulus mod (p*q) = 0  do q := p*q;  od;
#T         if q mod 4 = 0  then
#T             Add( G.facts, 4 );
#T             Add( G.roots, 3 );
#T             Add( G.sizes, 2 );
#T         fi;
#T         if q mod 8 = 0  then
#T             Add( G.facts, q );
#T             Add( G.roots, 5 );
#T             Add( G.sizes, q/4 );
#T         fi;
#T         if p <> 2  then
#T             Add( G.facts, q );
#T             Add( G.roots, PrimitiveRootMod( q ) );
#T             Add( G.sizes, (p-1)*q/p );
#T         fi;
#T     od;
#T
#T     # represent each generator in this factorization
#T     G.sgs := [];
#T     for k  in [ 1 .. Length( G.generators ) ]  do
#T         G.sgs[k] := [];
#T         for i  in [ 1 .. Length( G.facts ) ]  do
#T             if G.facts[i] mod 8 = 0  then
#T                 if G.generators[k].representative mod 4 = 1  then
#T                     G.sgs[k][i] := LogMod(
#T                         G.generators[k].representative,
#T                         G.roots[i], G.facts[i] );
#T                 else
#T                     G.sgs[k][i] := LogMod(
#T                         -G.generators[k].representative,
#T                         G.roots[i], G.facts[i] );
#T                 fi;
#T             else
#T                 G.sgs[k][i] := LogMod(
#T                         G.generators[k].representative,
#T                         G.roots[i], G.facts[i] );
#T             fi;
#T         od;
#T     od;
#T     for i  in [ Length( G.sgs ) + 1 .. Length( G.facts ) ]  do
#T         G.sgs[i] := 0 * G.facts;
#T     od;
#T
#T     # bring this matrix to diagonal form
#T     for i  in [ 1 .. Length( G.facts ) ]  do
#T         r := G.sgs[i];
#T         for k  in [ i+1 .. Length( G.sgs ) ]  do
#T             s := G.sgs[k];
#T             g := Gcdex( r[i], s[i] );
#T             for l  in [ i .. Length( r ) ]  do
#T                 x := r[l];  y := s[l];
#T                 r[l] := (g.coeff1 * x + g.coeff2 * y) mod G.sizes[l];
#T                 s[l] := (g.coeff3 * x + g.coeff4 * y) mod G.sizes[l];
#T             od;
#T         od;
#T         s := [];
#T         x := G.sizes[i] / GcdInt( G.sizes[i], r[i] );
#T         for l  in [ 1 .. Length( r ) ]  do
#T             s[l] := (x * r[l]) mod G.sizes[l];
#T         od;
#T         Add( G.sgs, s );
#T     od;
#T
#T end;
#T
#T ResidueClassGroupOps.Size := function ( G )
#T     local   s,          # size of <G>, result
#T             i;          # loop variable
#T     if not IsBound( G.facts )  then
#T         G.operations.MakeFactors( G );
#T     fi;
#T     s := 1;
#T     for i  in [ 1 .. Length( G.facts ) ]  do
#T         s := s * G.sizes[i] / GcdInt( G.sizes[i], G.sgs[i][i] );
#T     od;
#T     return s;
#T end;
#T
#T ResidueClassGroupOps.\in := function ( res, G )
#T     local   s,          # exponent vector of <res>
#T             g,          # extended gcd
#T             x, y,       # two entries in <s> and '<G>.sgs[i]'
#T             i, l;       # loop variables
#T     if not IsResidueClass( res )
#T         or res.modulus <> G.modulus
#T         or GcdInt( res.representative, res.modulus ) <> 1
#T     then
#T         return false;
#T     fi;
#T     if not IsBound( G.facts )  then
#T         G.operations.MakeFactors( G );
#T     fi;
#T     s := [];
#T     for i  in [ 1 .. Length( G.facts ) ]  do
#T         if G.facts[i] mod 8 = 0  then
#T             if res.representative mod 4 = 1  then
#T                 s[i] := LogMod( res.representative,
#T                                 G.roots[i], G.facts[i] );
#T             else
#T                 s[i] := LogMod( -res.representative,
#T                                 G.roots[i], G.facts[i] );
#T             fi;
#T         else
#T             s[i] := LogMod( res.representative,
#T                             G.roots[i], G.facts[i] );
#T         fi;
#T     od;
#T     for i  in [ 1 .. Length( G.facts ) ]  do
#T         if s[i] mod GcdInt( G.sizes[i], G.sgs[i][i] ) <> 0  then
#T             return false;
#T         fi;
#T         g := Gcdex( G.sgs[i][i], s[i] );
#T         for l  in [ i .. Length( G.facts ) ]  do
#T             x := G.sgs[i][l];  y := s[l];
#T             s[l] := (g.coeff3 * x + g.coeff4 * y) mod G.sizes[l];
#T         od;
#T     od;
#T     return true;
#T end;
#T
#T ResidueClassGroupOps.Random := function ( G )
#T     local   s,          # exponent vector of random element
#T             r,          # vector of remainders in each factor
#T             i, k, l;    # loop variables
#T     if not IsBound( G.facts )  then
#T         G.operations.MakeFactors( G );
#T     fi;
#T     s := 0 * G.facts;
#T     for i  in [ 1 .. Length( G.facts ) ]  do
#T         l := G.sizes[i] / GcdInt( G.sizes[i], G.sgs[i][i] );
#T         k := Random( [ 0 .. l-1 ] );
#T         for l  in [ i .. Length( s ) ]  do
#T             s[l] := (s[l] + k * G.sgs[i][l]) mod G.sizes[l];
#T         od;
#T     od;
#T     r := [];
#T     for l  in [ 1 .. Length( s ) ]  do
#T         r[l] := PowerModInt( G.roots[l], s[l], G.facts[l] );
#T         if G.facts[l] mod 8 = 0  and r[1] = 3  then
#T             r[l] := G.facts[l] - r[l];
#T         fi;
#T     od;
#T     return ResidueClass( ChineseRem( G.facts, r ), G.modulus );
#T end;
#T
#T
#T ##########################################################################
#T ##
#T #F  PrimeResidueClassGroup(<m>) . . . . . . .  full prime residue class group
#T ##
#T PrimeResidueClassGroup := function ( m )
#T     local   G,          # group $Z/mZ$, result
#T             gens,       # generators of <G>
#T             p, q,       # prime and prime power dividing <m>
#T             r,          # primitive root modulo <q>
#T             g;          # is = <r> mod <q> and = 1 mod <m> / <q>
#T
#T     # add generators for each prime power factor <q> of <m>
#T     gens := [];
#T     for p  in Set( Factors( m ) )  do
#T         q := p;
#T         while m mod (q * p) = 0  do q := q * p;  od;
#T
#T         # $ Z / 4Z = < 3 > $
#T         if   q = 4  then
#T             r := 3;
#T             g := r + q * (((1/q mod (m/q)) * (1 - r)) mod (m/q));
#T             Add( gens, ResidueClass( g, m ) );
#T
#T         # $ Z / 8nZ = < 5, -1 > $ is *not* cyclic
#T         elif q mod 8 = 0  then
#T             r := q-1;
#T             g := r + q * (((1/q mod (m/q)) * (1 - r)) mod (m/q));
#T             Add( gens, ResidueClass( g, m ) );
#T             r := 5;
#T             g := r + q * (((1/q mod (m/q)) * (1 - r)) mod (m/q));
#T             Add( gens, ResidueClass( g, m ) );
#T
#T         # for odd <q> $ Z / qZ $ is cyclic
#T         elif q <> 2  then
#T             r :=  PrimitiveRootMod( q );
#T             g := r + q * (((1/q mod (m/q)) * (1 - r)) mod (m/q));
#T             Add( gens, ResidueClass( g, m ) );
#T         fi;
#T
#T     od;
#T
#T     # return the group generated by <gens>
#T     G := Group( gens, ResidueClass( 1, m ) );
#T     G.size := Phi( m );
#T     return G;
#T end;


#############################################################################
##
#E  numtheor.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



