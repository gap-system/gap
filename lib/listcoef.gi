#############################################################################
##
#W  listcoef.gi                 GAP Library                      Frank Celler
##
##  The  '<Something>RowVector' functions operate  on row vectors, that is to
##  say (where it  makes sense) that the vectors  must have the  same length,
##  for example 'AddRowVector'  requires that  the  two involved row  vectors
##  have the same length.
##
##  The '<DoSomething>Coeffs' functions  operate  on row vectors  which might
##  have different lengths.  They will return the new length without counting
##  trailing zeros, however they will *not*  necessarily remove this trailing
##  zeros.  The  only  exception to this  rule  is 'RemoveOuterCoeffs'  which
##  returns the number of elements removed at the beginning.
##
##  The '<Something>Coeffs' functions operate on row vectors which might have
##  different lengths, the returned result will have trailing zeros removed.
##
Revision.listcoef_gi :=
    "@(#)$Id$";


#############################################################################
##

#M  AddRowVector( <list1>, <list2>, <mult>, <from>, <to> )
##
InstallMethod( AddRowVector,
    true,
    [ IsDenseList and IsMutable,
      IsDenseList,
      IsMultiplicativeElement,
      IsInt and IsPosRat,
      IsInt and IsPosRat ],
    0,

function( l1, l2, m, f, t )
    local   i;

    for i  in [ f .. t ]  do
        l1[i] := l1[i] + m * l2[i];
    od;
end );


#############################################################################
##
#M  AddRowVector( <list1>, <list2>, <mult> )
##
InstallOtherMethod( AddRowVector,
    true,
    [ IsDenseList and IsMutable,
      IsDenseList,
      IsMultiplicativeElement ],
    0,

function( l1, l2, m )
    local   i;

    for i  in [ 1 .. Length(l1) ]  do
        l1[i] := l1[i] + m * l2[i];
    od;
end );



#############################################################################
##
#M  AddRowVector( <list1>, <list2> )
##
InstallOtherMethod( AddRowVector,
    true,
    [ IsDenseList and IsMutable,
      IsDenseList ],
    0,

function( l1, l2 )
    local   i;

    for i  in [ 1 .. Length(l1) ]  do
        l1[i] := l1[i] + l2[i];
    od;
end );


#############################################################################
##
#M  LeftShiftRowVector( <list>, <shift> )
##
InstallMethod( LeftShiftRowVector,
    true,
    [ IsDenseList and IsMutable,
      IsInt and IsPosRat ],
    0,

function( l, s )
    local   i;

    for i  in [ 1 .. Length(l)-s ]  do
        l[i] := l[i+s];
    od;
    for i  in [ Length(l)-s+1 .. Length(l) ]  do
        Unbind(l[i]);
    od;
end );


#############################################################################
##
#M  LeftShiftRowVector( <list>, <no-shift> )
##
InstallOtherMethod( LeftShiftRowVector,
    true,
    [ IsDenseList,
      IsInt and IsZeroCyc ],
    SUM_FLAGS,

function( l, s )
    return;
end );


#############################################################################
##
#M  MultRowVector( <list1>, <poss1>, <list2>, <poss2>, <mult> )
##
InstallMethod( MultRowVector,
    true,
    [ IsDenseList and IsMutable,
      IsDenseList,
      IsDenseList,
      IsDenseList,
      IsMultiplicativeElement ],
    0,

function( l1, p1, l2, p2, m )
    l1{p1} := m * l2{p2};
end );


#############################################################################
##
#M  MultRowVector( <list>, <mul> )
##
InstallOtherMethod( MultRowVector,
    true,
    [ IsDenseList and IsMutable,
      IsMultiplicativeElement ],
    0,

function( l, m )
    local   i;

    for i  in [ 1 .. Length(l) ]  do
        l[i] := m * l[i];
    od;
end );


#############################################################################
##
#M  RightShiftRowVector( <list>, <shift>, <fill> )
##
InstallMethod( RightShiftRowVector,
    true,
    [ IsList and IsMutable,
      IsInt and IsPosRat,
      IsObject ],
    0,

function( l, s, f )
    local   i;

    l{s+[1..Length(l)]} := l{[1..Length(l)]};
    for i  in [ 1 .. s ]  do
        l[i] := f;
    od;
end );


#############################################################################
##
#M  RightShiftRowVector( <list>, <no-shift>, <fill> )
##
InstallOtherMethod( RightShiftRowVector,
    true,
    [ IsList,
      IsInt and IsZeroCyc,
      IsObject ],
    SUM_FLAGS,

function( l, s, f )
    return;
end );


#############################################################################
##
#M  ShrinkRowVector( <list> )
##
InstallMethod( ShrinkRowVector,
    true,
    [ IsList and IsMutable ],
    0,

function( l1 )
    local   z;

    if 0 = Length(l1)  then
        return;
    else
        z := l1[1] * 0;
        while 0 < Length(l1) and l1[Length(l1)] = z  do
            Unbind( l1[Length(l1)] );
        od;
    fi;
end );


#############################################################################
##

#M  AddCoeffs( <list1>, <poss1>, <list2>, <poss2>, <mul> )
##
InstallMethod( AddCoeffs,
    "generic methods",
    true,
    [ IsDenseList and IsMutable,
      IsDenseList,
      IsDenseList,
      IsDenseList,
      IsMultiplicativeElement ],
    0,

function( l1, p1, l2, p2, m )
    local   i,  zero,  n1;

    if Length(p1) <> Length(p2)  then
        Error( "positions lists have different lengths" );
    fi;
    for i  in [ 1 .. Length(p1) ]  do
        if not IsBound(l1[p1[i]])  then
            l1[p1[i]] := m*l2[p2[i]];
        else
            l1[p1[i]] := l1[p1[i]] + m*l2[p2[i]];
        fi;
    od;
    if 0 < Length(l1)  then
        zero := Zero(l1[1]);
        n1   := Length(l1);
        while 0 < n1 and l1[n1] = zero  do
            n1 := n1 - 1;
        od;
    else
        n1 := 0;
    fi;
    return n1;
end );


#############################################################################
##
#M  AddCoeffs( <list1>, <list2>, <mul> )
##
InstallOtherMethod( AddCoeffs,
    "generic methods",
    true,
    [ IsDenseList and IsMutable,
      IsDenseList,
      IsMultiplicativeElement ],
    0,

function( l1, l2, m )
    local   pos;

    pos := [ 1 .. Length(l2) ];
    return AddCoeffs( l1, pos, l2, pos, m );
end );


#############################################################################
##
#M  AddCoeffs( <list1>, <list2> )
##
InstallOtherMethod( AddCoeffs,
    "generic methods",
    true,
    [ IsDenseList and IsMutable,
      IsDenseList ],
    0,

function( l1, l2 )
    local   len,  zero,  pos;

    if 0 = Length(l2)  then
        if 0 = Length(l1)  then
            return 0;
        else
            len  := Length(l1);
            zero := Zero(l1[1]);
            while 0 < len and l1[len] = zero  do
                len := len - 1;
            od;
            return len;
        fi;
    else
        pos := [ 1 .. Length(l2) ];
        AddCoeffs( l1, pos, l2, pos, One(l2[1]) );
    fi;
end );


#############################################################################
##
#M  MultCoeffs( <list1>, <list2>, <len2>, <list3>, <len3> )
##
InstallMethod( MultCoeffs,
    true,
    [ IsList and IsMutable,
      IsDenseList,
      IsInt,
      IsDenseList,
      IsInt ],
    0,

function( l1, l2, n2, l3, n3 )
    local   zero,  i,  z,  j,  n1;

    # catch the trivial cases
    if n2 = 0  then
        return 0;
    elif n3 = 0  then
        return 0;
    fi;
    zero := Zero(l2[1]);
    if IsIdentical( l1, l2 )  then
        l2 := ShallowCopy(l2);
    elif IsIdentical( l1, l3 )  then
        l3 := ShallowCopy(l3);
    fi;

    # fold the product
    for i  in [ 1 .. n2+n3-1 ]  do
        z := zero;
        for j  in [ Maximum(i+1-n3,1) .. Minimum(n2,i) ]  do
            z := z + l2[j]*l3[i+1-j];
        od;
        l1[i] := z;
    od;

    # return the length of <l1>
    n1 := n2+n3-1;
    while 0 < n1 and l1[n1] = zero  do
        n1 := n1 - 1;
    od;
    return n1;

end );


#############################################################################
##
#M  ReduceCoeffs( <list1>, <len1>, <list2>, <len2> )
##
InstallMethod( ReduceCoeffs,
    true,
    [ IsDenseList and IsMutable,
      IsInt,
      IsDenseList,
      IsInt ],
    0,

function( l1, n1, l2, n2 )
    local   zero,  k,  l,  q,  ll,  i;

    # catch trivial cases
    if 0 = n2  then
        Error( "<l2> must be non-zero" );
    elif 0 = n1  then
        return l1;
    fi;
    zero := Zero(l1[1]);
    while 0 < n2 and l2[n2] = zero  do
        n2 := n2 - 1;
    od;
    if 0 = n2  then
        Error( "<l2> must be non-zero" );
    fi;
    while 0 < n2 and l1[n1] = zero  do
        n1 := n1 - 1;
    od;
        
    # reduce coeffs
    while n1 >= n2  do
        q := -l1[n1]/l2[n2];
        l := n1-n2;
        for i  in [ n1-n2+1 .. n1 ]  do 
            l1[i] := l1[i]+q*l2[i-n1+n2];
            if l1[i] <> zero  then
                l := i;
            fi;
        od;
        n1 := l;
    od;
    return n1;
end );


#############################################################################
##
#M  ReduceCoeffs( <list1>, <list2> )
##
InstallOtherMethod( ReduceCoeffs,
    true,
    [ IsDenseList and IsMutable,
      IsDenseList ],
    0,

function( l1, l2 )
    return ReduceCoeffs( l1, Length(l1), l2, Length(l2) );
end );


#############################################################################
##
#M  ReduceCoeffsMod( <list1>, <len1>, <list2>, <len2>, <mod> )
##
InstallMethod( ReduceCoeffsMod,
    true,
    [ IsDenseList and IsMutable,
      IsInt,
      IsDenseList,
      IsInt,
      IsInt ],
    0,

function( l1, n1, l2, n2, p )
    local   zero,  k,  l,  q,  ll,  i;

    # catch trivial cases
    if 0 = n2  then
        Error( "<l2> must be non-zero" );
    elif 0 = n1  then
        return l1;
    fi;
    zero := Zero(l1[1]);
    while 0 < n2 and l2[n2] = zero  do
        n2 := n2 - 1;
    od;
    if 0 = n2  then
        Error( "<l2> must be non-zero" );
    fi;
    while 0 < n2 and l1[n1] = zero  do
        n1 := n1 - 1;
    od;
        
    # reduce coeffs
    while n1 >= n2  do
        q := -l1[n1]/l2[n2] mod p;
        l := n1-n2;
        for i  in [ n1-n2+1 .. n1 ]  do 
            l1[i] := (l1[i]+q*l2[i-n1+n2] mod p) mod p;
            if l1[i] <> zero  then
                l := i;
            fi;
        od;
        n1 := l;
    od;
    return n1;
end );


#############################################################################
##
#M  ReduceCoeffsMod( <list1>, <list2>, <mod> )
##
InstallOtherMethod( ReduceCoeffsMod,
    true,
    [ IsDenseList and IsMutable,
      IsDenseList,
      IsInt ],
    0,

function( l1, l2, p )
    return ReduceCoeffsMod( l1, Length(l1), l2, Length(l2), p );
end );


#############################################################################
##
#M  ReduceCoeffsMod( <list>, <len>, <mod> )
##
InstallOtherMethod( ReduceCoeffsMod,
    true,
    [ IsDenseList and IsMutable,
      IsInt,
      IsInt ],
    0,

function( l1, n1, p )
    local   zero,  n2,  i;

    # catch trivial cases
    if 0 = n1  then
        return l1;
    fi;
    zero := Zero(l1[1]);
        
    # reduce coeffs
    n2 := 0;
    for i  in [ 1 .. n1 ]  do
        l1[i] := l1[i] mod p;
        if l1[i] <> zero  then
            n2 := i;
        fi;
    od;
    return n2;

end );


#############################################################################
##
#M  ReduceCoeffsMod( <list>, <mod> )
##
InstallOtherMethod( ReduceCoeffsMod,
    true,
    [ IsDenseList and IsMutable,
      IsInt ],
    0,

function( l1, p )
    return ReduceCoeffsMod( l1, Length(l1), p );
end );


#############################################################################
##
#M  RemoveOuterCoeffs( <list>, <coef> )
##
InstallMethod( RemoveOuterCoeffs,
    true,
    [ IsDenseList and IsMutable,
      IsObject ],
    0,

function( l, c )
    local   n,  m,  i;

    if 0 = Length(l)  then
        return 0;
    fi;
    n := Length(l);
    while 0 < n and l[n] = c  do
        Unbind(l[n]);
        n := n-1;
    od;
    if n = 0  then
        return 0;
    fi;
    m := 0;
    while m < n and l[m+1] = c  do
        m := m+1;
    od;
    if 0 = m  then
        return 0;
    fi;
    for i  in [ m+1 .. n ]  do
        l[i-m] := l[i];
    od;
    for i  in [ 1 .. m ]  do
        Unbind(l[n-i+1]);
    od;
    return m;
end );


#############################################################################
##
#M  ShrinkCoeffs( <list> )
##
InstallMethod( ShrinkCoeffs,
    true,
    [ IsList and IsMutable ],
    0,

function( l1 )
    ShrinkRowVector(l1);
    return Length(l1);
end );


#############################################################################
##

#M  CoeffsMod( <list>, <len>, <mod> )
##
InstallMethod( CoeffsMod,
    true,
    [ IsDenseList,
      IsInt,
      IsInt ],
    0,

function( l1, n1, p )
    l1 := ShallowCopy(l1);
    ReduceCoeffsMod( l1, n1, p );
    ShrinkRowVector(l1);
    return l1;
end );


#############################################################################
##
#M  CoeffsMod( <list>, <mod> )
##
InstallOtherMethod( CoeffsMod,
    true,
    [ IsDenseList,
      IsInt ],
    0,

function( l1, p )
    return CoeffsMod( l1, Length(l1), p );
end );


#############################################################################
##
#M  PowerModCoeffs( <list1>, <len1>, <exp>, <list2>, <len2> )
##
InstallMethod( PowerModCoeffs,
    true,
    [ IsDenseList,
      IsInt,
      IsInt,
      IsDenseList,
      IsInt ],
    0,

function( l1, n1, exp, l2, n2 )
    local   c,  n3;

    if exp <= 0  then
        Error( "power <exp> must be positive" );
    fi;
    l1 := ShallowCopy(l1);
    n1 := ReduceCoeffs( l1, n1, l2, n2 );
    if n1 = 0  then
        return [];
    fi;
    c  := [ One(l1[1]) ];
    n3 := 1;
    while exp <> 0 do
        if exp mod 2 = 1  then
            n3 := MultCoeffs( c, c, n3, l1, n1 );
            n3 := ReduceCoeffs( c, n3, l2, n2 );
        fi;
        exp := QuoInt( exp, 2 );
        if exp <> 0  then
            l1 := ProductCoeffs( l1, n1, l1, n1 );
            n1 := ReduceCoeffs( l1, Length(l1), l2, n2 );
        fi;
    od;
    return c;
end );


#############################################################################
##
#M  PowerModCoeffs( <list1>, <exp>, <list2> )
##
InstallOtherMethod( PowerModCoeffs,
    true,
    [ IsDenseList,
      IsInt,
      IsDenseList ],
    0,

function( l1, exp, l2 )
    return PowerModCoeffs( l1, Length(l1), exp, l2, Length(l2) );
end );


#############################################################################
##
#M  ProductCoeffs( <list1>, <len1>, <list2>, <len2> )
##
InstallMethod( ProductCoeffs,
    true,
    [ IsDenseList,
      IsInt,
      IsDenseList,
      IsInt ],
    0,

function( l1, n1, l2, n2 )
    local   p;

    p := [];
    MultCoeffs( p, l1, n1, l2, n2 );
    ShrinkRowVector(p);
    return p;
end );


#############################################################################
##
#M  ProductCoeffs( <list1>, <list2> )
##
InstallOtherMethod( ProductCoeffs,
    true,
    [ IsDenseList,
      IsDenseList ],
    0,

function( l1, l2 )
    return ProductCoeffs( l1, Length(l1), l2, Length(l2) );
end );


#############################################################################
##
#M  ShiftedCoeffs( <list>, <shift> )
##
InstallMethod( ShiftedCoeffs,
    true,
    [ IsDenseList,
      IsInt ],
    0,

function( l, shift )
    if 0 = Length(l)  then
        return [];
    fi;
    l := ShallowCopy(l);
    if shift < 0  then
        LeftShiftRowVector( l, -shift );
        ShrinkRowVector(l);
        return l;
    elif shift = 0  then
        ShrinkRowVector(l);
        return l;
    else
        RightShiftRowVector( l, shift, Zero(l[1]) );
        ShrinkRowVector(l);
        return l;
    fi;
end );


#############################################################################
##
#F  QuotRemPolList( <f>, <g>) 
##
##  Quotient and  Remainder  of polynomials   given as  list,  is  needed for
##  algebraic extensions and fits best here.
##
QuotRemPolList := function(f,g)
local q,m,n,i,c,k,z;
  q:=[];
  f:=ShallowCopy(f);
  g:=ShallowCopy(g);
  z:=0*g[1];
  n:=Length(g);
  while n>0 and g[n]=z do
    Unbind(g[n]);
    n:=n-1;
  od;
  n:=Length(g);
  m:=Length(f);
  for i  in [0..(m-n)]  do
    c:=f[m-i]/g[n];
    q[m-n-i+1]:=c;
    for k in [1..n] do
      f[m-i-n+k]:=f[m-i-n+k]-c*g[k];
    od;
  od;
  return [q,f];
end;


#############################################################################
##

#E  listcoef.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
