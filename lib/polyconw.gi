#############################################################################
##
#W  polyconw.gi                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the implementation part of functions and data around
##  Conway polynomials.
##
Revision.polyconw_gi :=
    "@(#)$Id$";


###############################################################################
##
#F  PowerModEvalPol( <f>, <g>, <xpownmodf> )
##
InstallGlobalFunction( PowerModEvalPol, function( f, g, xpownmodf )

    local l,    # length of coefficients of `g'
          res,  # result
          i;    # loop over coefficients of `g'

    l:= Length( g );
    res:= [ g[l] ];
    for i in [ 1 .. l-1 ] do
      res:= ProductCoeffs( res, xpownmodf );   # `res:= res * x^n;'
      ReduceCoeffs( res, f );                  # `res:= res mod f;'
      res[1]:= res[1] + g[l-i];                # `res:= res + g_{l-i+1};'
      ShrinkCoeffs( res );
    od;
    return res;
end );


############################################################################
##
#V  CONWAYPOLYNOMIALS
##
##  All Conway polynomials listed here, unless stated otherwise for
##  specific polynomials, are taken from a list computed by Richard Parker,
##  and have been checked using the {\GAP} library function `ConwayPol'.
##
InstallValue( CONWAYPOLYNOMIALS, [] );

CONWAYPOLYNOMIALS[2] := [
    [1],
    [1,1],
    [1,1],
    [1,1],
    [1,0,1],
    [1,1,0,1,1],
    [1,1],
    [1,0,1,1,1],
    [1,0,0,0,1],
    [1,1,1,1,0,1,1],
    [1,0,1],
    [1,1,0,1,0,1,1,1],
    [1,1,0,1,1],
    [1,0,0,1,0,1,0,1],
    [1,0,1,0,1,1],
    [1,0,1,1,0,1],
    [1,0,0,1],
    [1,1,0,0,0,0,0,0,0,0,1,0,1],
    [1,1,1,0,0,1],
    [1,1,0,0,1,1,1,1,0,1,1],
    [1,0,1,0,0,1,1],
    [1,0,0,0,0,1,1,0,1,1,1,1,1],
    [1,0,0,0,0,1],
    [1,0,0,1,0,1,0,1,0,1,1,0,0,1,1,1,1],
    [1,0,1,0,0,0,1,0,1],
    [1,1,0,0,1,0,1,1,1,0,1,0,0,0,1],
    [1,0,1,1,0,1,0,1,0,1,1,0,1],
    [1,0,1,0,0,1,1,1,0,0,0,0,0,1],
    [1,0,1],
    [1,1,1,1,0,1,0,1,0,0,0,1,0,1,0,0,1,1],
    [1,0,0,1],
    [1,0,0,1,1,0,0,1,0,1,0,0,0,0,0,1],
    [1,0,0,1,0,0,1,0,1,0,1,1,1,1],
    [1,1,1,0,1,1,1,1,1,0,0,1,1,0,0,1,1],
    [1,0,1,0,0,1,0,1,0,0,1,1],
    [1,1,0,0,0,1,1,0,1,0,0,0,0,1,1,0,0,1,0,1,1,0,1,1],
    [1,1,1,1,1,1],
    [1,1,1,0,0,1,0,0,1,1,1,0,0,0,1],
    [1,0,1,0,0,1,1,1,0,1,1,1,1,0,0,1],
    [1,1,0,1,0,1,0,0,1,0,0,0,1,1,0,1,1,0,1,0,0,1,0,1],
    [1,0,0,1],
    [1,1,1,0,0,1,1,0,0,1,0,1,1,0,0,0,0,0,1,0,1,0,0,0,1,1,1,0,0,0,1], # not yet verified with GAP
    [1,0,0,1,1,0,1],
    [1,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,0,1,0,0,0,0,1],
    [1,0,0,0,0,0,1,0,0,0,0,1,1,0,1,1,0,1,0,0,1],
    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,1,1,0,1],
    [1,0,0,0,0,1],
    [1,0,0,1,0,0,0,1,1,0,1,1,1,0,0,0,0,1,0,0,0,0,0,1,0,1],
    [1,1,1,1,1,0,1,0,1,0,1],
    [1,0,1,0,1,0,1,0,1,1,1,0,1,1,1,0,1,1,0,1,0,0,0,0,0,0,0,1,1,1], # not yet verified with GAP
    [1,0,0,0,0,0,1,0,0,1,0,0,1,0,0,1,1],
    ,
    [1,1,1,0,0,0,1],
    [1,1,1,0,1,0,0,1,0,0,0,0,0,1,0,1,1,1,1,0,0,1,0,0,0,1,0,1,0,1,1,1,1,0,1], # not yet verified with GAP
    [1,0,0,0,1,0,0,1,0,1,1,1],
    ,
    [1,1,1,1,1,1,1,0,1,0,1,1,0,1,0,0,1,0,0,1,0,1],
    ,
    [1,1,0,1,1,1,1],
    [1,0,1,1,1,1,0,0,1,0,0,0,1,0,0,0,0,1,0,1,0,0,1,0,0,1,1,0,0,0,1,0,1,1,1,0,1,0,0,1,0,1,1,0,1,1], # not yet verified with GAP
    [1,1,1,0,0,1],
    ,
    ,
    ,
    [1,1,0,0,0,1,0,1,0,1,1,0,1,1,1,1],
    ,
    [1,1,1,0,0,1],
    ,
    ,
    ,
    [1,1,0,1,0,1],
    ,
    [1,0,1,1,1],
    ,
    ,
    ,
    ,
    ,
    [1,0,1,1,1],
    ,
    ,
    ,
    [1,0,1,0,1,0,0,1],
    ,
    ,
    ,
    ,
    ,
    [1,0,0,1,0,1,1],
    ,
    ,
    ,
    ,
    ,
    ,
    ,
    [1,0,0,0,0,0,1],
    ];

CONWAYPOLYNOMIALS[3] := [
    [1],
    [2,2],
    [1,2],
    [2,0,0,2],
    [1,2],
    [2,2,1,0,2],
    [1,0,2],
    [2,2,2,0,1,2],
    [1,1,2,2],
    [2,1,0,0,2,2,2],
    [1,0,2],
    [2,0,1,0,1,1,1],
    [1,2],
    [2,0,1,2,0,1,2,1,1,2],
    [1,1,2,0,0,1,0,0,2],
    [2,1,2,2,2,0,2,2],
    [1,2],
    [2,0,2,0,2,1,2,0,2,0,1],
    [1,0,2],
    [2,1,0,2,2,2,0,0,1,1,1,1,0,2],
    [1,2,0,2,0,1,2,0,2,0,2], # GAP value, Richard said [1,1,1,2,0,2,0,1,0,1,1]
    [2,2,0,1,0,1,1,1,2,2,1,2],
    [1,1,0,1],
    [2,2,0,2,2,0,2,0,2,0,0,2,0,0,1],
    [1,2,1,1,0,2,2],
    [2,1,2,1,0,0,2,2,2,2,2,2,2,1],
    [1,0,0,0,0,0,0,2],
    [2,0,0,1,2,0,2,0,1,1,1,2,1,1,2],
    [1,0,0,0,2],
    [2,2,2,1,2,2,1,2,0,2,2,2,0,2,1,0,2,2,2,0,2], # not yet verified with GAP
    [1,1,0,1],
    [2,1,0,1,2,1,2,0,0,0,0,2,2], # not yet verified with GAP
    [1,0,2,1,2,2,1,0,0,1,0,1,2],
    ,
    [1,1,2,0,2,0,0,1,1,1],
    ,
    [1,2,2,1],
    ,
    [1,0,2,0,1,0,1,2,0,1,2,2,1],
    ,
    [1,2],
    ,
    [1,1,0,1],
    ,
    ,
    ,
    [1,2,2,0,2],
    ,
    [1,1,0,0,1,1,0,1,1],
    ,
    ,
    ,
    [1,0,2,2,2],
    ,
    ,
    ,
    ,
    ,
    [1,2,2,1],
    ,
    [1,2,2,1],
    ,
    ,
    ,
    ,
    ,
    [1,0,2],
    ,
    ,
    ,
    [1,2,2,0,1],
    ,
    [1,2],
    ,
    ,
    ,
    ,
    ,
    [1,2,1,0,2],
    ,
    ,
    ,
    [1,2,2,0,0,1],
    ,
    ,
    ,
    ,
    ,
    [1,0,1,2],
    ,
    ,
    ,
    ,
    ,
    ,
    ,
    [1,2,2,2],
    ];

CONWAYPOLYNOMIALS[5] := [
    [3],
    [2,4],
    [3,3],
    [2,4,4],
    [3,4],
    [2,0,1,4,1],
    [3,3],
    [2,4,3,0,1],
    [3,1,0,2],
    [2,1,4,2,3,3],
    [3,3],
    [2,2,3,4,4,0,1,1],
    [3,3,4],
    [2,1,0,3,2,4,4,0,1],
    [3,4,3,3,0,2],
    [2,1,4,4,2,4,4,4,1],
    [3,2,3],
    [2,0,2,2,0,1,2,0,2,1,1,1,1],
    [3,2,0,1],
    [2,1,0,4,0,0,3,0,2,3,4,0,3],
    [3,2,2,1,2,2,2,4],
    [2,3,3,4,0,2,2,0,3,4,0,3,1], # computed with GAP, Mar 99
    [3,0,2],
    [2,1,3,3,2,0,4,2,4,0,3,1,2,4,0,4,2], # not yet verified with GAP
    [3,4,2,4,0,1,3],
    ,
    [3,3,0,4,3,2,0,3,0,0,4],
    ,
    [3,1,3,1],
    ,
    [3,3],
    ,
    ,
    ,
    ,
    ,
    [3,3,4],
    ,
    ,
    ,
    [3,0,0,4],
    ,
    [3,3],
    ,
    ,
    ,
    [3,0,4,1,4],
    ,
    ,
    ,
    ,
    ,
    [3,1,2,2],
    ,
    ,
    ,
    ,
    ,
    [3,1,2,1],
    ,
    [3,4,4],
    ,
    ,
    ,
    ,
    ,
    [3,1,0,3,4],
    ,
    ,
    ,
    [3,3,3,3,4],
    ,
    [3,2,4,3],
    ,
    ,
    ,
    ,
    ,
    [3,2,0,1],
    ,
    ,
    ,
    [3,1,3,1],
    ,
    ,
    ,
    ,
    ,
    [3,0,1,1],
    ,
    ,
    ,
    ,
    ,
    ,
    ,
    [3,2,4,2],
    ];

CONWAYPOLYNOMIALS[7] := [
    [4],
    [3,6],
    [4,0,6],
    [3,4,5],
    [4,1],
    [3,6,4,5,1],
    [4,6],
    [3,2,6,4],
    [4,6,0,1,6],
    [3,3,2,1,4,1,1],
    [4,1],
    [3,0,5,0,4,2,3,5,2],
    [4,0,6],
    [3,6,3,0,2,6,0,5],
    [4,2,1,4,6,6,5],
    [3,4,2,6,1,4,3,5,4],
    [4,1],
    [3,2,6,0,0,3,1,5,6,1,6,2,1], # not yet verified with GAP
    [4,0,5],
    ,
    [4,4,0,6,0,0,0,3],
    ,
    [4,4,4],
    ,
    [4,2,1,0,5,0,5],
    ,
    ,
    ,
    [4,6],
    ,
    [4,0,5],
    ,
    ,
    ,
    ,
    ,
    [4,6],
    ,
    ,
    ,
    [4,1,4,1],
    ,
    [4,2,5],
    ,
    ,
    ,
    [4,3,4],
    ,
    ,
    ,
    ,
    ,
    [4,6],
    ,
    ,
    ,
    ,
    ,
    [4,3,6,1],
    ,
    [4,5,6],
    ,
    ,
    ,
    ,
    ,
    [4,4,6],
    ,
    ,
    ,
    [4,1,6],
    ,
    [4,2,6,3],
    ,
    ,
    ,
    ,
    ,
    [4,2,5,1],
    ,
    ,
    ,
    [4,6,6,1],
    ,
    ,
    ,
    ,
    ,
    [4,1],
    ,
    ,
    ,
    ,
    ,
    ,
    ,
    [4,5,6,1],
    ];

CONWAYPOLYNOMIALS[11] := [
    [9],
    [2,7],
    [9,2],
    [2,10,8],
    [9,0,10],
    [2,7,6,4,3],
    [9,4],
    [2,7,1,7,7],
    [9,8,9],
    [2,6,6,10,8,7],
    [9,10],
    [2,5,6,5,5,2,4,1,1],
    [9,7],
    [2,10,6,8,4,6,9,2],
    [9,0,0,5,0,7,10],
    ,
    [9,4],
    ,
    [9,2,8],
    ,
    ,
    ,
    [9,1,8],
    ,
    ,
    ,
    ,
    ,
    [9,2],
    ,
    [9,6,7],
    ,
    ,
    ,
    ,
    ,
    [9,4,10],
    ,
    ,
    ,
    [9,6,0,1],
    ,
    [9,9],
    ,
    ,
    ,
    [9,7,8],
    ,
    ,
    ,
    ,
    ,
    [9,1,10],
    ,
    ,
    ,
    ,
    ,
    [9,3,1],
    ,
    [9,7,7],
    ,
    ,
    ,
    ,
    ,
    [9,10,4],
    ,
    ,
    ,
    [9,10,9],
    ,
    [9,7,9],
    ,
    ,
    ,
    ,
    ,
    [9,9,10],
    ,
    ,
    ,
    [9,1,8],
    ,
    ,
    ,
    ,
    ,
    [9,1,6],
    ,
    ,
    ,
    ,
    ,
    ,
    ,
    [9,3,0,1],
    ];

CONWAYPOLYNOMIALS[13] := [
    [11],
    [2,12],
    [11,2],
    [2,12,3],
    [11,4],
    [2,11,11,10],
    [11,3],
    [2,3,2,12,8],
    [11,12,12,8,12],
    [2,1,1,8,5,7],
    [11,3],
    [2,4,1,1,3,11,8,5,1],
    [11,12],
    [2,10,10,7,11,6,0,4], # computed with GAP, Sep. 1998
    [11,8,11,10,11,2,12,2],
    [2,6,12,9,12,2,8,12,3], # computed with GAP, Oct. 1998
    [11,6,10],
    ,
    [11,9],
    ,
    ,
    ,
    [11,3],
    ,
    ,
    ,
    ,
    ,
    [11,4,11],
    ,
    [11,2,11],
    ,
    ,
    ,
    ,
    ,
    [11,12],
    ,
    ,
    ,
    [11,5,1],
    ,
    [11,8,12],
    ,
    ,
    ,
    [11,6,5],
    ,
    ,
    ,
    ,
    ,
    [11,4],
    ];

CONWAYPOLYNOMIALS[17] := [
    [14],
    [3,16],
    [14,1],
    [3,10,7],
    [14,1],
    [3,3,10,0,2],
    [14,12],
    [3,6,0,12,11],
    [14,8,7],
    [3,12,9,5,6,13],
    [14,5],
    [3,9,14,6,13,14,14,4,1], # not yet verified with GAP
    [14,15],
    ,
    [14,14,14,6,16,4,4],
    ,
    [14,16],
    ,
    [14,11],
    ,
    ,
    ,
    [14,16,15],
    ,
    ,
    ,
    ,
    ,
    [14,11,16],
    ,
    [14,4],
    ,
    ,
    ,
    ,
    ,
    [14,16],
    ,
    ,
    ,
    [14,1,15],
    ,
    [14,11,13],
    ,
    ,
    ,
    [14,8,16],
    ];

CONWAYPOLYNOMIALS[19] := [
    [17],
    [2,18],
    [17,4],
    [2,11,2],
    [17,5],
    [2,6,17,17],
    [17,6],
    [2,3,10,12,1],
    [17,16,14,11],
    [2,4,3,17,13,18],
    [17,8],
    [2,7,16,9,2,18,2,3], # not yet verified with GAP
    [17,11],
    ,
    [17,0,14,15,13,11,10,1], # computed with GAP, June 1999
    ,
    [17,2],
    ,
    [17,18],
    ,
    ,
    ,
    [17,13,18],
    ,
    ,
    ,
    ,
    ,
    [17,8],
    ,
    [17,5,17],
    ,
    ,
    ,
    ,
    ,
    [17,1,18],
    ,
    ,
    ,
    [17,1,18],
    ,
    [17,7],
    ];

CONWAYPOLYNOMIALS[23] := [
    [18],
    [5,21],
    [18,2],
    [5,19,3],
    [18,3],
    [5,1,9,9,1],
    [18,21],
    [5,3,5,20,3],
    [18,9,8,3],
    [5,1,6,15,5,17],
    [18,7,22],
    [5,12,18,12,14,15,21,21], # not yet verified with GAP
    [18,9],
    ,
    ,
    ,
    [18,20],
    ,
    [18,5],
    ,
    ,
    ,
    [18,22],
    ,
    ,
    ,
    ,
    ,
    [18,5,21],
    ,
    [18,13],
    ,
    ,
    ,
    ,
    ,
    [18,3,22],
    ,
    ,
    ,
    [18,7,22],
    ,
    [18,6,22],
    ];

CONWAYPOLYNOMIALS[29] := [
    [27],
    [2,24],
    [27,2],
    [2,15,2],
    [27,3],
    [2,13,17,25,1],
    [27,2],
    [2,23,26,24,3],
    [27,22,22,4],
    [2,22,2,17,8,25,1], # not yet verified with GAP
    [27,8,28],
    [2,1,1,25,16,9,28,19,3], # not yet verified with GAP
    [27,7],
    ,
    ,
    ,
    [27,2],
    ,
    [27,4],
    ,
    ,
    ,
    [27,10],
    ,
    ,
    ,
    ,
    ,
    [27,28],
    ,
    [27,13],
    ,
    ,
    ,
    ,
    ,
    [27,21,27],
    ,
    ,
    ,
    [27,5,23],
    ];

CONWAYPOLYNOMIALS[31] := [
    [28],
    [3,29],
    [28,1],
    [3,16,3],
    [28,7],
    [3,8,16,19],
    [28,1],
    [3,24,12,25],
    [28,29,20,4],
    [3,13,13,13,26,30],
    [28,20],
    [3,12,25,9,2,28,14,4], # not yet verified with GAP
    [28,6],
    ,
    ,
    ,
    [28,10],
    ,
    [28,7],
    ,
    ,
    ,
    [28,26],
    ,
    ,
    ,
    ,
    ,
    [28,11],
    ,
    [28,30],
    ,
    ,
    ,
    ,
    ,
    [28,5],
    ];

CONWAYPOLYNOMIALS[37] := [
    [35],
    [2,33],
    [35,6],
    [2,24,6],
    [35,10],
    [2,30,4,35],
    [35,7],
    [2,1,27,20,7],
    [35,32,20,6],
    [2,4,11,18,29,8],
    [35,2],
    [2,33,18,23,23,10,31,4], # not yet verified with GAP
    [35,6],
    ,
    ,
    ,
    [35,3],
    ,
    [35,23,36],
    ,
    ,
    ,
    [35,22,36],
    ,
    ,
    ,
    ,
    ,
    [35,13,36],
    ,
    [35,33,35],
    ,
    ,
    ,
    ,
    ,
    [35,36],
    ];

CONWAYPOLYNOMIALS[41] := [
    [35],
    [6,38],
    [35,1],
    [6,23],
    [35,14,40],
    [6,6,39,33,4],
    [35,6],
    [6,6,20,32,5],
    [35,5,31,4],
    ,
    [35,20],
    ,
    [35,13],
    ,
    ,
    ,
    [35,4],
    ,
    [35,10],
    ,
    ,
    ,
    [35,10],
    ,
    ,
    ,
    ,
    ,
    [35,13],
    ,
    [35,6],
    ,
    ,
    ,
    ,
    ,
    [35,30],
    ];

CONWAYPOLYNOMIALS[43] := [
    [40],
    [3,42],
    [40,1],
    [3,42,5],
    [40,8],
    [3,21,28,19],
    [40,7,42],
    [3,24,20,39,1],
    [40,1,39,12],
    ,
    [40,7],
    ,
    [40,4],
    ,
    ,
    ,
    [40,36],
    ,
    [40,30],
    ,
    ,
    ,
    [40,27],
    ,
    ,
    ,
    ,
    ,
    [40,8,42],
    ,
    [40,4],
    ];

CONWAYPOLYNOMIALS[47] := [
    [42],
    [5,45],
    [42,3],
    [5,40,8],
    [42,1],
    [5,41,9,35,2],
    [42,12],
    [5,3,19,29,1],
    [42,1,19,1],
    ,
    [42,6],
    ,
    [42,5],
    ,
    ,
    ,
    [42,16],
    ,
    [42,35],
    ,
    ,
    ,
    [42,14,46],
    ,
    ,
    ,
    ,
    ,
    [42,15],
    ,
    [42,10,46],
    ];

CONWAYPOLYNOMIALS[53] := [
    [51],
    [2,49],
    [51,3],
    [2,38,9],
    [51,3],
    [2,45,4,7,1],
    [51,9],
    [2,1,18,29,8],
    [51,5,13],
    ,
    [51,15],
    ,
    [51,28,52],
    ,
    ,
    ,
    [51,12],
    ,
    [51,11],
    ,
    ,
    ,
    [51,27],
    ,
    ,
    ,
    ,
    ,
    [51,20],
    ,
    [51,33],
    ];

CONWAYPOLYNOMIALS[59] := [
    [57],
    [2,58],
    [57,5],
    [2,40,2],
    [57,8],
    [2,0,38,18,2],
    [57,10],
    [2,50,2,32,16],
    [57,47,32,1],
    ,
    [57,6],
    ,
    [57,3],
    ,
    ,
    ,
    [57,9],
    ,
    [57,11],
    ,
    ,
    ,
    [57,35],
    ,
    ,
    ,
    ,
    ,
    [57,9,58],
    ,
    [57,9],
    ];

CONWAYPOLYNOMIALS[61] := [
    [59],
    [2,60],
    [59,7],
    [2,40,3],
    [59,12],
    [2,29,3,49],
    [59,2],
    [2,56,1,57],
    [59,18,50,9],
    ,
    [59,18],
    ,
    [59,3],
    ,
    ,
    ,
    [59,10],
    ,
    [59,2],
    ,
    ,
    ,
    [59,13],
    ,
    ,
    ,
    ,
    ,
    [59,4],
    ,
    [59,11],
    ];

CONWAYPOLYNOMIALS[67] := [
    [65],
    [2,63],
    [65,6],
    [2,54,8],
    [65,2],
    [2,55,49,63],
    [65,7],
    [2,64,17,46,3],
    [65,55,49,25],
    ,
    [65,9,66],
    ,
    [65,22],
    ,
    ,
    ,
    [65,5],
    ,
    [65,18],
    ,
    ,
    ,
    [65,11],
    ,
    ,
    ,
    ,
    ,
    [65,2],
    ,
    [65,24],
    ];

CONWAYPOLYNOMIALS[71] := [
    [64],
    [7,69],
    [64,4],
    [7,41,4],
    [64,18],
    [7,29,13,10,1],
    [64,2],
    [7,19,22,53],
    [64,62,43,4],
    ,
    [64,48],
    ,
    [64,27],
    ,
    ,
    ,
    [64,3],
    ,
    [64,4],
    ,
    ,
    ,
    [64,4],
    ,
    ,
    ,
    ,
    ,
    [64,19],
    ,
    [64,21],
    ];

CONWAYPOLYNOMIALS[73] := [
    [68],
    [5,70],
    [68,2],
    [5,56,16],
    [68,9],
    [5,48,23,45],
    [68,10],
    [5,18,39,53,3],
    [68,15,72],
    ,
    [68,5],
    ,
    [68,7],
    ,
    ,
    ,
    [68,8],
    ,
    [68,25],
    ,
    ,
    ,
    [68,13],
    ,
    ,
    ,
    ,
    ,
    [68,3],
    ,
    [68,10],
    ];

CONWAYPOLYNOMIALS[79] := [
    [76],
    [3,78],
    [76,9],
    [3,66,2],
    [76,5],
    [3,68,28,19],
    [76,4],
    [3,48,59,60],
    [76,19,57],
    ,
    [76,3],
    ,
    [76,4,78],
    ,
    ,
    ,
    [76,25],
    ,
    [76,25],
    ,
    ,
    ,
    [76,9],
    ,
    ,
    ,
    ,
    ,
    [76,11],
    ,
    [76,52,78],
    ];

CONWAYPOLYNOMIALS[83] := [
    [81],
    [2,82],
    [81,3],
    [2,42,4],
    [81,9],
    [2,17,32,76,1],
    [81,3],
    [2,42,23,65,1],
    [81,18,24,1],
    ,
    [81,17],
    ,
    [81,15],
    ,
    ,
    ,
    [81,7],
    ,
    [81,47],
    ,
    ,
    ,
    [81,4],
    ,
    ,
    ,
    ,
    ,
    [81,9],
    ,
    [81,38],
    ];

CONWAYPOLYNOMIALS[89] := [
    [86],
    [3,82],
    [86,3],
    [3,72,4],
    [86,1],
    [3,15,80,82,1],
    [86,7],
    [3,79,40,65],
    [86,6,12,5],
    ,
    [86,26,88],
    ,
    [86,17],
    ,
    ,
    ,
    [86,20],
    ,
    [86,34],
    ,
    ,
    ,
    [86,9],
    ,
    ,
    ,
    ,
    ,
    [86,1],
    ];

CONWAYPOLYNOMIALS[97] := [
    [92],
    [5,96],
    [92,9],
    [5,80,6],
    [92,3],
    [5,88,58,92],
    [92,5],
    [5,32,1,65],
    [92,7,59,12],
    ,
    [92,5],
    ,
    [92,3],
    ,
    ,
    ,
    [92,5],
    ,
    [92,15],
    ,
    ,
    ,
    [92,35],
    ,
    ,
    ,
    ,
    ,
    [92,22],
    ];


############################################################################
##
#F  ConwayPol( <p>, <n> ) . . . . . <n>-th Conway polynomial in charact. <p>
##
InstallGlobalFunction( ConwayPol, function( p, n )

    local F,          # `GF(p)'
          one,        # `One( F )'
          zero,       # `Zero( F )'
          eps,        # $(-1)^n$ in `F'
          x,          # indeterminate over `F', as coefficients list
          cpol,       # actual candidate for the Conway polynomial
          nfacs,      # all `n/d' for prime divisors `d' of `n'
          cpols,      # Conway polynomials for `d' in `nfacs'
          pp,         # $p^n-1$
          quots,      # list of $(p^n-1)/(p^d-1)$, for $d$ in `nfacs'
          lencpols,   # `Length( cpols )'
          ppmin,      # list of $(p^n-1)/d$, for prime factors $d$ of $p^n-1$
          found,      # is the actual candidate compatible?
          onelist,    # `[ one ]'
          pow,        # powers of several polynomials
          i,          # loop over `ppmin'
          xpownmodf,  # power of `x', modulo `cpol'
          c,          # loop over `cpol'
          e;          # 1 or -1, used to compute the next candidate

    # Check the arguments.
    if not ( IsPrimeInt( p ) and IsInt( n ) and n > 0 ) then
      Error( "<p> must be a prime, <n> a positive integer" );
    fi;

    if not IsBound( CONWAYPOLYNOMIALS[p] ) then
      CONWAYPOLYNOMIALS[p]:= [];
    fi;
    if not IsBound( CONWAYPOLYNOMIALS[p][n] ) then

      Info( InfoWarning, 1,
            "computing Conway polynomial for p = ", p, " and n = ", n );

      F:= GF(p);
      one:= One( F );
      zero:= Zero( F );

      if n mod 2 = 1 then
        eps:= AdditiveInverse( one );
      else
        eps:= one;
      fi;

      # polynomial `x' (as coefficients list)
      x:= [ zero, one ];

      # Initialize the smallest polynomial of degree `n' that is a candidate
      # for being the Conway polynomial.
      # This is `x^n + (-1)^n \*\ z' for the smallest primitive root `z'.
      # If the field can be realized in {\GAP} then `z' is just `Z(p)'.

      # Note that we enumerate monic polynomials with constant term
      # $(-1)^n \alpha$ where $\alpha$ is the smallest primitive element in
      # $GF(p)$ by the compatibility condition (and by existence of such a
      # polynomial).

      cpol:= ListWithIdenticalEntries( n, zero );
      cpol[ n+1 ]:= one;
      cpol[1]:= eps * PrimitiveRootMod( p );

      if n > 1 then

        # Compute the list of all `n / p' for `p' a prime divisor of `n'
        nfacs:= List( Set( FactorsInt( n ) ), d -> n / d );

        if nfacs = [ 1 ] then

          # `n' is a prime, we have to check compatibility only with
          # the degree 1 Conway polynomial.
          # But this condition is satisfied by choice of the constant term
          # of the candidates.
          cpols:= [];

        else

          # Compute the Conway polynomials for all values $<n> / d$
          # where $d$ is a prime divisor of <n>.
          # They are used for checking compatibility.
          cpols:= List( nfacs, d -> ConwayPol( p, d ) * one );

        fi;

        pp:= p^n-1;

        quots:= List( nfacs, x -> pp / ( p^x -1 ) );
        lencpols:= Length( cpols );
        ppmin:= List( Set( FactorsInt( pp ) ), d -> pp/d );

        found:= false;
        onelist:= [ one ];

        while not found do

          # Test whether `cpol' is primitive.
          #  $f$ is primitive if and only if
          #  1. $f$ divides $X^{q^n-1} -1$, and
          #  2. $f$ does not divide $X^{(q^n-1)/p} - 1$ for every
          #     prime divisor $p$ of $q^n - 1$.

          pow:= PowerModCoeffs( x, pp, cpol );
          ShrinkCoeffs( pow );
          found:= ( pow = onelist );

          i:= 1;
          while found and ( i <= Length( ppmin ) ) do
            pow:= PowerModCoeffs( x, ppmin[i], cpol );
            ShrinkCoeffs( pow );
            found:= pow <> onelist;
            i:= i+1;
          od;

          # Test compatibility with polynomials in `cpols'.
          i:= 1;
          while found and i <= lencpols do

            # Compute $`cpols[i]'( x^{\frac{p^n-1}{p^m-1}} ) mod `cpol'$.
            xpownmodf:= PowerModCoeffs( x, quots[i], cpol );
            pow:= PowerModEvalPol( cpol, cpols[i], xpownmodf );
            # Note that we need *not* call `ShrinkCoeffs'
            # since the list `cpols[i]' has always length at least 2,
            # and a final `ShrinkCoeffs' call is done by `PowerModEvalPol'.
            # ShrinkCoeffs( pow );
            found:= IsEmpty( pow );
            i:= i+1;

          od;

          if not found then

            # Compute the next candidate according to the chosen ordering.

            # We have $f$ smaller than $g$ for two polynomials $f$, $g$ of
            # degree $n$ with
            # $f = \sum_{i=0}^n (-1)^{n-i} f_i x^i$ and
            # $g = \sum_{i=0}^n (-1)^{n-i} g_i x^i$ if and only if exists
            # $m\leq n$ such that $f_m \< g_m$,
            # and $f_i = g_i$ for all $i > m$.
            # (Note that the thesis of W. Nickel gives a wrong definition.)

            c:= 0;
            e:= eps;
            repeat
              c:= c+1;
              e:= -1*e;
              cpol[c+1]:= cpol[c+1] + e;
            until cpol[c+1] <> zero;

          fi;

        od;

      fi;

      cpol:= List( cpol, IntFFE );

      # Subtract `x^n', strip leading zeroes,
      # and store this polynomial in the global list.
      found:= ShallowCopy( cpol );
      Unbind( found[ n+1 ] );
      ShrinkCoeffs( found );
      CONWAYPOLYNOMIALS[p][n]:= found;

    else

      # Decode the polynomial stored in the list.
      # (Append necessary zeroes.)
      cpol:= ShallowCopy( CONWAYPOLYNOMIALS[p][n] );
      while Length( cpol ) < n do
        Add( cpol, 0 );
      od;
      Add( cpol, 1 );

    fi;

    # Return the coefficients list.
    return cpol;
end );


############################################################################
##
#F  ConwayPolynomial( <p>, <n> ) .  <n>-th Conway polynomial in charact. <p>
##
InstallGlobalFunction( ConwayPolynomial, function( p, n )
    local F;
    if IsPrimeInt( p ) and IsPosInt( n ) then
      F:= GF(p);
      return UnivariatePolynomial( F, One( F ) * ConwayPol( p, n ) );
    else
      Error( "<p> must be a prime, <n> a positive integer" );
    fi;
end );


#############################################################################
##
#E

