#############################################################################
##
#W random.gi               The Congruence package                   Ann Dooms
#W                                                               Eric Jespers
#W                                                        Alexander Konovalov
##
#H $Id: random.gi,v 1.2 2008/05/28 23:58:03 alexk Exp $
##
#############################################################################
##
## This file contains implementations of methods to construct random elements
## of congruence subgroups CongruenceSubgroupGamma, CongruenceSubgroupGamma0, CongruenceSubgroupGammaUpper0, CongruenceSubgroupGamma1, CongruenceSubgroupGammaUpper1.
## The idea is to select two random entries a and b in the same row or column
## of the matrix, such that a and b will satisfy the requirements arising 
## from the congruence subgroup. For example, for the principal congruence 
## subgroup we will select a and b as follows:
## a := 1 + n * Random( [ -10 .. 10 ] );  
## b :=     n * Random( [ -10 .. 10 ] );
## After this we can find such x and y for the other row (or column) of the
## matrix that its determinant will be equal to one. If the resulting matrix
## will be not in the congruence subgroup because of not suitable x and y,
## we will repeat this process for another a and b until we will find 
## suitable x and y.  
## For each type of congruence subgroups, we provide one- and two-argument 
## versions of Random. The one-argument version uses Random( [ -10 .. 10 ] ) 
## to generate a and b, ## and in the two-argument version Random([ -m..m ]) 
## will be used, where m is given by the second argument.


#############################################################################
##
## The principal congruence subgroup of level N consists of all matrices
## of the form   [ 1+N    N ]
##               [   N  1+N ]
##
InstallMethod( Random,
	"for a principal congruence subgroup",
	[ IsPrincipalCongruenceSubgroup ],
	0,
	function( G )
	local n, a, b, gcd;
	n := LevelOfCongruenceSubgroup( G );
    repeat
      a := 1 + n * Random( [ -10 .. 10 ] );  
      b :=     n * Random( [ -10 .. 10 ] );
      gcd := Gcdex( a, b );
    until gcd.gcd = 1 and 
          IsInt( -gcd.coeff2/n ) and 
          IsInt( (gcd.coeff1-1)/n );
    return [ [          a,           b ], 
             [ -gcd.coeff2, gcd.coeff1 ] ];
end);

InstallOtherMethod( Random,
	"for a principal congruence subgroup",
	[ IsPrincipalCongruenceSubgroup, IsPosInt ],
	0,
	function( G, m )
	local n, a, b, gcd;
	n := LevelOfCongruenceSubgroup( G );
    repeat
      a := 1 + n * Random( [ -m .. m ] );  
      b :=     n * Random( [ -m .. m ] );
      gcd := Gcdex( a, b );
    until gcd.gcd = 1 and 
          IsInt( -gcd.coeff2/n ) and 
          IsInt( (gcd.coeff1-1)/n );
    return [ [          a,           b ], 
             [ -gcd.coeff2, gcd.coeff1 ] ];
end);


#############################################################################
##
## The congruence subgroup CongruenceSubgroupGamma0(N) consists of all matrices
## of the form   [   *    * ]
##               [   N    * ]
##
InstallMethod( Random,
	"for a congruence subgroup CongruenceSubgroupGamma0",
	[ IsCongruenceSubgroupGamma0 ],
	0,
	function( G )
	local n, a, b, gcd;
	n := LevelOfCongruenceSubgroup( G );
    repeat
      a := Random( [ -n*10 .. n*10 ] );  
      b := n * Random( [ -10 .. 10 ] );
      gcd := Gcdex( a, b );
    until gcd.gcd = 1;
    return [ [ a, -gcd.coeff2 ], 
             [ b,  gcd.coeff1 ] ];
end);

InstallOtherMethod( Random,
	"for a congruence subgroup CongruenceSubgroupGamma0",
	[ IsCongruenceSubgroupGamma0, IsPosInt ],
	0,
	function( G, m )
	local n, a, b, gcd;
	n := LevelOfCongruenceSubgroup( G );
	repeat
      a := Random( [ -n*m .. n*m ] );  
      b := n * Random( [ -m .. m ] );
      gcd := Gcdex( a, b );
    until gcd.gcd = 1;
    return [ [ a,  -gcd.coeff2 ], 
             [ b,   gcd.coeff1 ] ];
end);


#############################################################################
## 
## The congruence subgroup CongruenceSubgroupGammaUpper0(N) consists of all matrices
## of the form   [   *    N ]
##               [   *    * ]
##
InstallMethod( Random,
	"for a congruence subgroup CongruenceSubgroupGammaUpper0",
	[ IsCongruenceSubgroupGammaUpper0 ],
	0,
	function( G )
	local n, a, b, gcd;
	n := LevelOfCongruenceSubgroup( G );
    repeat
      a := Random( [ -n*10 .. n*10 ] );  
      b := n * Random( [ -10 .. 10 ] );
      gcd := Gcdex( a, b );
    until gcd.gcd = 1;
    return [ [           a,           b ], 
             [ -gcd.coeff2,  gcd.coeff1 ] ];
end);

InstallOtherMethod( Random,
	"for a congruence subgroup CongruenceSubgroupGammaUpper0",
	[ IsCongruenceSubgroupGammaUpper0, IsPosInt ],
	0,
	function( G, m )
	local n, a, b, gcd;
	n := LevelOfCongruenceSubgroup( G );
	repeat
      a := Random( [ -n*m .. n*m ] );  
      b := n * Random( [ -m .. m ] );
      gcd := Gcdex( a, b );
    until gcd.gcd = 1;
    return [ [           a,           b ], 
             [ -gcd.coeff2,  gcd.coeff1 ] ];
end);


#############################################################################
## 
## The congruence subgroup CongruenceSubgroupGamma1(N) consists of all matrices
## of the form   [ 1+N    * ]
##               [   N  1+N ]
##
InstallMethod( Random,
	"for a congruence subgroup CongruenceSubgroupGamma1",
	[ IsCongruenceSubgroupGamma1 ],
	0,
	function( G )
	local n, a, b, gcd;
	n := LevelOfCongruenceSubgroup( G );
    repeat
      a := 1 + n * Random( [ -10 .. 10 ] );  
      b :=     n * Random( [ -10 .. 10 ] );
      gcd := Gcdex( a, b );
    until gcd.gcd = 1 and IsInt( (gcd.coeff1-1)/n );
    return [ [ a, -gcd.coeff2 ], 
             [ b,  gcd.coeff1 ] ];
end);

InstallOtherMethod( Random,
	"for a congruence subgroup CongruenceSubgroupGamma1",
	[ IsCongruenceSubgroupGamma1, IsPosInt ],
	0,
	function( G, m )
	local n, a, b, gcd;
	n := LevelOfCongruenceSubgroup( G );
    repeat
      a := 1 + n * Random( [ -m .. m ] );  
      b :=     n * Random( [ -m .. m ] );
      gcd := Gcdex( a, b );
    until gcd.gcd = 1 and IsInt( (gcd.coeff1-1)/n );
    return [ [ a, -gcd.coeff2 ], 
             [ b,  gcd.coeff1 ] ];
end);


#############################################################################
## 
## The congruence subgroup CongruenceSubgroupGammaUpper1(N) consists of all matrices
## of the form   [ 1+N    N ]
##               [   *  1+N ]
##
InstallMethod( Random,
	"for a congruence subgroup CongruenceSubgroupGammaUpper1",
	[ IsCongruenceSubgroupGammaUpper1 ],
	0,
	function( G )
	local n, a, b, gcd;
	n := LevelOfCongruenceSubgroup( G );
    repeat
      a := 1 + n * Random( [ -10 .. 10 ] );  
      b :=     n * Random( [ -10 .. 10 ] );
      gcd := Gcdex( a, b );
    until gcd.gcd = 1 and IsInt( (gcd.coeff1-1)/n );
    return [ [          a,           b ], 
             [ -gcd.coeff2, gcd.coeff1 ] ];
end);

InstallOtherMethod( Random,
	"for a congruence subgroup CongruenceSubgroupGammaUpper1",
	[ IsCongruenceSubgroupGammaUpper1, IsPosInt ],
	0,
	function( G, m )
	local n, a, b, gcd;
	n := LevelOfCongruenceSubgroup( G );
    repeat
      a := 1 + n * Random( [ -m .. m ] );  
      b :=     n * Random( [ -m .. m ] );
      gcd := Gcdex( a, b );
    until gcd.gcd = 1 and IsInt( (gcd.coeff1-1)/n );
    return [ [          a,           b ], 
             [ -gcd.coeff2, gcd.coeff1 ] ];
end);


#############################################################################
##
#E
##