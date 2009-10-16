if not IsBound( SnLa_Name )  then
    DeclareAttribute( "SnLa_Name", IsLieAlgebra );
fi;


SNLA_NAMES:=[];

LieAlgebrasOfMPGong_sList := function(campo)
    local  e, s, char, z, lambda, tables, t, i, j, l;

    char := Characteristic( campo );
    z := Zero( campo );

    if char = 2  then
        lambda := 1;
    else
        lambda := - 1 / 2;
    fi;
    lambda := lambda * One( campo );

    e := dim -> EmptySCTable( dim, z, "antisymmetric" );
    s := SetEntrySCTable;

    SNLA_NAMES := [  ];
    tables := [  ];



## The data below on the small nilpotent Lie algebras is taken from M. P.  
## Gong, and was converted in a Gap readable format with help by Aldo 
## Cristilli.

## Gong, Ming-Peng. Classification of Nilpotent Lie Algebras of
## Dimension 7 (Over Algebraically Closed Fields and R).
## Ph.D. thesis, University of Waterloo, Ontario, Canada, 1998.
## http://etd.uwaterloo.ca/etd/mpgong1998.pdf


## Paragraph 3.2.1
## Algebras of Dimensions <= 5

## Dimension 1
Add( SNLA_NAMES,"N1,1" );
t:= e(1);
Add(tables, t);

## Dimension 2
## None.

## Dimension 3

Add( SNLA_NAMES,"N3,2" );
t:= e(3);
s( t, 1, 2, [ 1, 3 ] );
Add(tables, t);

## Dimension 4

Add( SNLA_NAMES,"N4,2" );
t:= e(4);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
Add(tables, t);

## Dimension 5

Add( SNLA_NAMES,"N5,1" );
t:= e(5);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 2, 3, [ 1, 5 ] );
Add(tables, t);

Add( SNLA_NAMES,"N5,2,1" );
t:= e(5);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+1 ] );
od;
Add(tables, t);

Add( SNLA_NAMES,"N5,2,2" );
t:= e(5);
s( t, 1, 2, [ 1, 4 ] );
s( t, 1, 4, [ 1, 5 ] );
s( t, 2, 3, [ 1, 5 ] );
Add(tables, t);

Add( SNLA_NAMES,"N5,2,3" );
t:= e(5);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 2, 3, [ 1, 5 ] );
Add(tables, t);

Add( SNLA_NAMES,"N5,3,1" );
t:= e(5);
s( t, 1, 2, [ 1, 5 ] );
s( t, 3, 4, [ 1, 5 ] );
Add(tables, t);

Add( SNLA_NAMES,"N5,3,2" );
t:= e(5);
s( t, 1, 2, [ 1, 4 ] );
s( t, 1, 3, [ 1, 5 ] );
Add(tables, t);

## Paragraph 3.2.2
## Algebras of Dimension 6 over Algebraically Closed Fields of char <> 2

Add( SNLA_NAMES,"N6,1,1" );
t:= e(6);
for i in [2 .. 5] do
  s( t, 1, i, [ 1, i+1 ] );
od;
for i in [3, 4] do
  s( t, 2, i, [ 1, i+2 ] );
od;
Add(tables, t);

Add( SNLA_NAMES,"N6,1,2" );
t:= e(6);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 5, [ 1, 6 ] );
s( t, 3, 4, [ -1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"N6,1,3" );
t:= e(6);
for i in [2 .. 5] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 2, 3, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"N6,1,4" );
t:= e(6);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 4 ] );
s( t, 1, 4, [ 1, 6 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 5, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"N6,2,1" );
t:= e(6);
for i in [2 .. 5] do
  s( t, 1, i, [ 1, i+1 ] );
od;
Add(tables, t);

Add( SNLA_NAMES,"N6,2,2" );
t:= e(6);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 2, 5, [ 1, 6 ] );
s( t, 3, 4, [ -1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"N6,2,3" );
t:= e(6);
s( t, 1, 2, [ 1, 4 ] );
for i in [4, 5] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 2, 3, [ 1, 5 ] );
s( t, 3, 4, [ -1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"N6,2,4" );
t:= e(6);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 4 ] );
s( t, 1, 4, [ 1, 6 ] );
s( t, 2, 5, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"N6,2,5" );
t:= e(6);
for i in [2, 3, 5] do
  s( t, 1, i, [ 1, i+1 ] );
od;
for j in [3, 4] do
  s( t, 2, j, [ 1, j+2 ] );
od;
Add(tables, t);

Add( SNLA_NAMES,"N6,2,6" );
t:= e(6);
s( t, 1, 2, [ 1, 4 ] );
s( t, 1, 3, [ 1, 5 ] );
s( t, 1, 4, [ 1, 6 ] );
s( t, 3, 5, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"N6,2,7" );
t:= e(6);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 2, 3, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"N6,2,8" );
t:= e(6);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 5 ] );
s( t, 1, 4, [ 1, 6 ] );
s( t, 2, 4, [ 1, 5 ] );
Add(tables, t);

Add( SNLA_NAMES,"N6,2,9" );
t:= e(6);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 5 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 4, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"N6,2,10" );
t:= e(6);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 5 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 4, [ 1, 5 ] );
Add(tables, t);

Add( SNLA_NAMES,"N6,3,1" );
t:= e(6);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 2, 5, [ 1, 6 ] );
s( t, 3, 4, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"N6,3,2" );
t:= e(6);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 6 ] );
s( t, 4, 5, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"N6,3,3" );
t:= e(6);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 4, [ 1, 6 ] );
s( t, 2, 3, [ 1, 5 ] );
Add(tables, t);

Add( SNLA_NAMES,"N6,3,4" );
t:= e(6);
s( t, 1, 2, [ 1, 3 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 4, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"N6,3,5" );
t:= e(6);
s( t, 1, 2, [ 1, 5 ] );
s( t, 1, 4, [ 1, 6 ] );
s( t, 2, 3, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"N6,3,6" );
t:= e(6);
s( t, 1, 2, [ 1, 4 ] );
s( t, 1, 3, [ 1, 5 ] );
s( t, 2, 3, [ 1, 6 ] );
Add(tables, t);

## Paragraph 3.2.3
## Algebras of Dimension 6 over Algebraically Closed Fields of char = 2

## In addition to the algebras over algebraically closed fields of
## char <> 2, ## we have the following 5 extra indecomposable algebras 
## for char = 2:

if char = 2 then 

Add( SNLA_NAMES,"A" );
t:= e(6);
for i in [2 .. 5] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 2, 3, [ 1, 5, 1, 6 ] );
s( t, 2, 4, [ 1, 6 ] );
Add(tables, t);
## Remark: When char <> 2, this algebra is isomorphic to N6;1;1.

Add( SNLA_NAMES,"B" );
t:= e(6);
s( t, 1, 2, [ 1, 4 ] );
s( t, 1, 4, [ 1, 5 ] );
s( t, 1, 5, [ 1, 6 ] );
s( t, 2, 3, [ 1, 5, 1, 6 ] );
s( t, 3, 4, [ -1, 6 ] );
Add(tables, t);
## Remark: When char <> 2, this algebra is isomorphic to N6;2;3.

Add( SNLA_NAMES,"C" );
t:= e(6);
for i in [2, 3, 5] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 4, [ 1, 6 ] );
s( t, 2, 5, [ 1, 6 ] );
Add(tables, t);
## Remark: When char <> 2, this algebra is isomorphic to N6;2;5.

Add( SNLA_NAMES,"D" );
t:= e(6);
s( t, 1, 2, [ 1, 4 ] );
s( t, 1, 3, [ 1, 5 ] );
s( t, 2, 5, [ 1, 6 ] );
s( t, 3, 4, [ 1, 6 ] );
s( t, 3, 5, [ 1, 6 ] );
Add(tables, t);
## Remark: When char <> 2, this algebra is isomorphic to N6;3;1.

Add( SNLA_NAMES,"E" );
t:= e(6);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 5 ] );
s( t, 1, 4, [ 1, 6 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 4, [ 1, 5 ] );
Add(tables, t);
## Remark: When char <> 2, this algebra is isomorphic to N6;2;10.

fi;


## Paragraph 7.4
## Four More Real Algebras and Their Extensions

## In the real field R, apart from all the algebras already listed over C,
## we have 4 more algebras, which we will list in the following, ... . The
## notation La means that, as a Lie algebras over R, La and L are
## nonisomorphic algebras, but are isomorphic over the complex field C.

Add( SNLA_NAMES,"N6,2,5a" );
t:= e(6);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 4, [ -1, 6 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 5, [ -1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"N6,2,9a" );
t:= e(6);
s( t, 1, 2, [ 1, 3 ] );
for i in [3, 4] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 2, 3, [ -1, 6 ] );
s( t, 2, 4, [ 1, 5 ] );
Add(tables, t);

Add( SNLA_NAMES,"N6,3,1a" );
t:= e(6);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 2, 4, [ 1, 6 ] );
s( t, 3, 5, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"N6,4,4a" );
t:= e(6);
s( t, 1, 3, [ 1, 5 ] );
s( t, 2, 4, [ 1, 5 ] );
s( t, 1, 4, [ -1, 6 ] );
s( t, 2, 3, [ 1, 6 ] );
Add(tables, t);


## Paragraph 4.1:
## List of 7-Dimensional Indecomposable Nilpotent Lie Algebras
## over Algebraically Closed Fields (char <> 2)

## Upper Central Series Dimensions (37)

Add( SNLA_NAMES,"37A" );
t:= e(7);
s( t, 1, 2, [ 1, 5 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 4, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"37B" );
t:= e(7);
s( t, 1, 2, [ 1, 5 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 3, 4, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"37C" );
t:= e(7);
s( t, 1, 2, [ 1, 5 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 4, [ 1, 7 ] );
s( t, 3, 4, [ 1, 5 ] );
Add(tables, t);

Add( SNLA_NAMES,"37D" );
t:= e(7);
s( t, 1, 2, [ 1, 5 ] );
s( t, 1, 3, [ 1, 6 ] );
s( t, 2, 4, [ 1, 7 ] );
s( t, 3, 4, [ 1, 5 ] );
Add(tables, t);

## Upper Central Series Dimensions (357)

Add( SNLA_NAMES,"357A" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 5 ] );
s( t, 1, 4, [ 1, 7 ] );
s( t, 2, 4, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"357B" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 5 ] );
s( t, 1, 4, [ 1, 7 ] );
s( t, 2, 3, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"357C" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 5 ] );
s( t, 1, 4, [ 1, 7 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 4, [ 1, 5 ] );
Add(tables, t);

## Upper Central Series Dimensions (27)

Add( SNLA_NAMES,"27A" );
t:= e(7);
s( t, 1, 2, [ 1, 6 ] );
s( t, 1, 4, [ 1, 7 ] );
s( t, 3, 5, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"27B" );
t:= e(7);
s( t, 1, 2, [ 1, 6 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 3, [ 1, 7 ] );
s( t, 3, 4, [ 1, 6 ] );
Add(tables, t);

## Upper Central Series Dimensions (257)

Add( SNLA_NAMES,"257A" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 6 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 4, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"257B" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 6 ] );
s( t, 1, 4, [ 1, 7 ] );
s( t, 2, 5, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"257C" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 6 ] );
s( t, 2, 4, [ 1, 6 ] );
s( t, 2, 5, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"257D" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 6 ] );
s( t, 1, 4, [ 1, 7 ] );
s( t, 2, 4, [ 1, 6 ] );
s( t, 2, 5, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"257E" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 6 ] );
s( t, 2, 4, [ 1, 7 ] );
s( t, 4, 5, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"257F" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 4, [ 1, 7 ] );
s( t, 4, 5, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"257G" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 6 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 4, [ 1, 7 ] );
s( t, 4, 5, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"257H" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 6 ] );
s( t, 2, 4, [ 1, 6 ] );
s( t, 4, 5, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"257I" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 6 ] );
s( t, 1, 4, [ 1, 6 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 3, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"257J" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 6 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 3, [ 1, 7 ] );
s( t, 2, 4, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"257K" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 6 ] );
s( t, 2, 3, [ 1, 7 ] );
s( t, 4, 5, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"257L" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 6 ] );
s( t, 2, 3, [ 1, 7 ] );
s( t, 2, 4, [ 1, 6 ] );
s( t, 4, 5, [ 1, 7 ] );
Add(tables, t);

## Upper Central Series Dimensions (247)

Add( SNLA_NAMES,"247A" );
t:= e(7);
for i in [2, 3, 4, 5] do
  s( t, 1, i, [ 1, i+2 ] );
od;
Add(tables, t);

Add( SNLA_NAMES,"247B" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 3, 5, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"247C" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 1, 5, [ 1, 7 ] );
s( t, 3, 5, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"247D" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 1, 4, [ 1, 6 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 3, 4, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"247E" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 1, 5, [ 1, 6 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 3, 4, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"247F" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 2, 4, [ 1, 6 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 3, 4, [ 1, 7 ] );
s( t, 3, 5, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"247G" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 1, 5, [ 1, 6 ] );
s( t, 2, 4, [ 1, 6 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 3, 4, [ 1, 7 ] );
s( t, 3, 5, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"247H" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 2, 4, [ 1, 6 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 3, 4, [ 1, 7 ] );
s( t, 3, 5, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"247I" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 2, 5, [ 1, 6 ] );
s( t, 3, 4, [ 1, 6 ] );
s( t, 3, 5, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"247J" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 1, 5, [ 1, 6 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 3, 4, [ 1, 7 ] );
s( t, 3, 5, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"247K" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 2, 5, [ 1, 7 ] );
s( t, 3, 4, [ 1, 7 ] );
s( t, 3, 5, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"247L" );
t:= e(7);
for i in [2, 3, 4, 5] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 2, 3, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"247M" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 2, 3, [ 1, 6 ] );
s( t, 3, 5, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"247N" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 1, 5, [ 1, 6 ] );
s( t, 2, 3, [ 1, 7 ] );
s( t, 2, 4, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"247O" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 3, [ 1, 7 ] );
s( t, 3, 5, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"247P" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 3, 4, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"247Q" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 3, 4, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"247R" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 1, 5, [ 1, 6 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 3, 4, [ 1, 7 ] );
Add(tables, t);

## Upper Central Series Dimensions (2457)

Add( SNLA_NAMES,"2457A" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
for i in [4, 5] do
  s( t, 1, i, [ 1, i+2 ] );
od;
Add(tables, t);

Add( SNLA_NAMES,"2457B" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 4, [ 1, 7 ] );
s( t, 2, 5, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"2457C" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
for i in [4, 5] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 2, 5, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"2457D" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
for i in [4, 5] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 5, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"2457E" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 4, [ 1, 7 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 5, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"2457F" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
for i in [4, 5] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 2, 3, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"2457G" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 4, [ 1, 7 ] );
s( t, 1, 5, [ 1, 6 ] );
s( t, 2, 3, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"2457H" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 4, [ 1, 7 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 5, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"2457I" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 4, [ 1, 6 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 5, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"2457J" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 4, [ 1, 6 ] );
s( t, 2, 3, [ 1, 6, 1, 7 ] );
s( t, 2, 5, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"2457K" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 4, [ 1, 7 ] );
s( t, 1, 5, [ 1, 6 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 5, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"2457L" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 4, [ 1, 6 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 4, [ 1, 7 ] );
s( t, 2, 5, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"2457M" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 4, [ 1, 7 ] );
s( t, 1, 5, [ 1, 6 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 4, [ 1, 6 ] );
Add(tables, t);

## Upper Central Series Dimensions (2357)

Add( SNLA_NAMES,"2357A" );
t:= e(7);
s( t, 1, 2, [ 1, 4 ] );
s( t, 1, 4, [ 1, 5 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 3, [ 1, 5, 1, 6 ] );
s( t, 3, 4, [ -1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"2357B" );
t:= e(7);
s( t, 1, 2, [ 1, 4 ] );
s( t, 1, 3, [ 1, 6 ] );
s( t, 1, 4, [ 1, 5 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 3, 4, [ -1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"2357C" );
t:= e(7);
s( t, 1, 2, [ 1, 4 ] );
s( t, 1, 4, [ 1, 5 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 4, [ 1, 6 ] );
s( t, 3, 4, [ -1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"2357D" );
t:= e(7);
s( t, 1, 2, [ 1, 4 ] );
s( t, 1, 3, [ 1, 6 ] );
s( t, 1, 4, [ 1, 5 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 4, [ 1, 6 ] );
s( t, 3, 4, [ -1, 7 ] );
Add(tables, t);

## Upper Central Series Dimensions (23457)

Add( SNLA_NAMES,"23457A" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 5, [ 1, 6 ] );
s( t, 2, 3, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"23457B" );
## Here another basis is used, with x_6 and x_7 swapped respect to the 
## basis used by Gong
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 3, 4, [ -1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"23457C" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 5, [ 1, 6 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 3, 4, [ -1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"23457D" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 5, [ 1, 6 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 3, 4, [ -1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"23457E" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 5, [ 1, 6 ] );
s( t, 2, 3, [ 1, 5, 1, 7 ] );
s( t, 2, 4, [ 1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"23457F" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 2, 3, [ 1, 5, 1, 7 ] );
s( t, 2, 5, [ 1, 6 ] );
s( t, 3, 4, [ -1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"23457G" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 5, [ 1, 6 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 4, [ 1, 6 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 3, 4, [ -1, 7 ] );
Add(tables, t);

## Upper Central Series Dimensions (17)

Add( SNLA_NAMES,"17" );
t:= e(7);
s( t, 1, 2, [ 1, 7 ] );
s( t, 3, 4, [ 1, 7 ] );
s( t, 5, 6, [ 1, 7 ] );
Add(tables, t);

## Upper Central Series Dimensions (157)

Add( SNLA_NAMES,"157" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 7 ] );
s( t, 2, 4, [ 1, 7 ] );
s( t, 5, 6, [ 1, 7 ] );
Add(tables, t);

## Upper Central Series Dimensions (147)

Add( SNLA_NAMES,"147A" );
t:= e(7);
s( t, 1, 2, [ 1, 4 ] );
s( t, 1, 3, [ 1, 5 ] );
s( t, 1, 6, [ 1, 7 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 3, 4, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"147B" );
t:= e(7);
s( t, 1, 2, [ 1, 4 ] );
s( t, 1, 3, [ 1, 5 ] );
s( t, 1, 4, [ 1, 7 ] );
s( t, 2, 6, [ 1, 7 ] );
s( t, 3, 5, [ 1, 7 ] );
Add(tables, t);

if char<>2 then
Add( SNLA_NAMES,"147C" );
## It is a member of the one parameter family "147E", with
## lambda = -1, 1/2, 2, and was not included by Gong, but this algebra has
## different invariants
t:= e(7);
s( t, 1, 2, [ 1, 4 ] );
s( t, 1, 3, [ -1, 6 ] );
s( t, 1, 5, [ -1, 7 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 6, [ 1/2, 7 ] );
s( t, 3, 4, [ 1/2, 7 ] );
Add(tables, t);
fi;

Add( SNLA_NAMES,"147D" );
t:= e(7);
s( t, 1, 2, [ 1, 4 ] );
s( t, 1, 3, [ -1, 6 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 1, 6, [ 1, 7 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 6, [ 1, 7 ] );
s( t, 3, 4, [ -2, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"147E" );
## One parameter family, with invariant
## I(lambda) = (1 - lambda + lambda^2)^3 / ( lambda^2 (lambda - 1)^2 ) ,
## lambda <> 0, 1.
t:= e(7);
s( t, 1, 2, [ 1, 4 ] );
s( t, 1, 3, [ -1, 6 ] );
s( t, 1, 5, [ -1, 7 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 6, [ lambda, 7 ] );
s( t, 3, 4, [ (1 - lambda), 7 ] );
Add(tables, t);
## When lambda = 0 or 1, it is isomorphic to (247P).

if char=3 then
Add( SNLA_NAMES,"147F" );
## (for char = 3 only)
t:= e(7);
s( t, 1, 2, [ 1, 4 ] );
s( t, 1, 3, [ -1, 6 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 1, 6, [ 1, 7 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 4, [ 1, 7 ] );
s( t, 2, 6, [ 1, 7 ] );
s( t, 3, 4, [ 1, 7 ] );
Add(tables, t);
fi;

## Remark: (147C) in Seeley's list is a special case of (147E) by taking
## lambda = 1.
## This is an error: it should be "lambda = -1, 1/2, 2".

## Upper Central Series Dimensions (1457)

Add( SNLA_NAMES,"1457A" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 4, [ 1, 7 ] );
s( t, 5, 6, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"1457B" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 4, [ 1, 7 ] );
s( t, 2, 3, [ 1, 7 ] );
s( t, 5, 6, [ 1, 7 ] );
Add(tables, t);

## Upper Central Series Dimensions (137)

Add( SNLA_NAMES,"137A" );
t:= e(7);
s( t, 1, 2, [ 1, 5 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 3, 4, [ 1, 6 ] );
s( t, 3, 6, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"137B" );
t:= e(7);
s( t, 1, 2, [ 1, 5 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 4, [ 1, 7 ] );
s( t, 3, 4, [ 1, 6 ] );
s( t, 3, 6, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"137C" );
t:= e(7);
s( t, 1, 2, [ 1, 5 ] );
s( t, 1, 4, [ 1, 6 ] );
s( t, 1, 6, [ 1, 7 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 3, 5, [ -1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"137D" );
t:= e(7);
s( t, 1, 2, [ 1, 5 ] );
s( t, 1, 4, [ 1, 6 ] );
s( t, 1, 6, [ 1, 7 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 4, [ 1, 7 ] );
s( t, 3, 5, [ -1, 7 ] );
Add(tables, t);

## Upper Central Series Dimensions (1357)

Add( SNLA_NAMES,"1357A" );
t:= e(7);
s( t, 1, 2, [ 1, 4 ] );
s( t, 1, 4, [ 1, 5 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 6, [ 1, 7 ] );
s( t, 3, 4, [ -1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"1357B" );
t:= e(7);
s( t, 1, 2, [ 1, 4 ] );
s( t, 1, 4, [ 1, 5 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 3, 4, [ -1, 7 ] );
s( t, 3, 6, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"1357C" );
t:= e(7);
s( t, 1, 2, [ 1, 4 ] );
s( t, 1, 4, [ 1, 5 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 4, [ 1, 7 ] );
s( t, 3, 4, [ -1, 7 ] );
s( t, 3, 6, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"1357D" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 6, [ 1, 7 ] );
for i in [3, 4] do
  s( t, 2, i, [ 1, i+2 ] );
od;
s( t, 2, 5, [ 1, 7 ] );
s( t, 3, 4, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"1357E" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
for i in [3, 4] do
  s( t, 2, i, [ 1, i+2 ] );
od;
s( t, 2, 5, [ 1, 7 ] );
s( t, 4, 6, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"1357F" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 7 ] );
for i in [3, 4] do
  s( t, 2, i, [ 1, i+2 ] );
od;
s( t, 2, 5, [ 1, 7 ] );
s( t, 4, 6, [ -1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"1357G" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 4, [ 1, 6 ] );
s( t, 1, 6, [ 1, 7 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 5, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"1357H" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 4, [ 1, 6 ] );
s( t, 1, 6, [ 1, 7 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 2, 6, [ 1, 7 ] );
s( t, 3, 4, [ -1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"1357I" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 4, [ 1, 6 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 4, 6, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"1357J" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 7 ] );
s( t, 1, 4, [ 1, 6 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 4, 6, [ 1, 7 ] );
Add(tables, t);

if char<>2 then
Add( SNLA_NAMES,"1357K" );
## It is a member of the one parameter family "1357M", with
## lambda = 1/2, and was not included by Gong, but this algebra has
## different invariants
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
for i in [3, 4, 5] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 2, 4, [ 1, 5 ] );
s( t, 2, 6, [ 1/2, 7 ] );
s( t, 3, 4, [ 1/2, 7 ] );
Add(tables, t);
fi;

if char<>2 then
Add( SNLA_NAMES,"1357L" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
for i in [3, 4, 5] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 2, 3, [ 1, 7 ] );
s( t, 2, 4, [ 1, 5 ] );
s( t, 2, 6, [ 1/2, 7 ] );
s( t, 3, 4, [ 1/2, 7 ] );
Add(tables, t);
fi;

Add( SNLA_NAMES,"1357M" );
## One parameter family, with lambda <> 0
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
for i in [3, 4, 5] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 2, 4, [ 1, 5 ] );
s( t, 2, 6, [ lambda, 7 ] );
s( t, 3, 4, [ (1 - lambda), 7 ] );
Add(tables, t);
## When lambda = 0, it is isomorphic to (2357B).

Add( SNLA_NAMES,"1357N" );
## One parameter family.
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
for i in [3, 4, 5] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 2, 3, [ lambda, 7 ] );
s( t, 2, 4, [ 1, 5 ] );
s( t, 3, 4, [ 1, 7 ] );
s( t, 4, 6, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"1357O" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 5 ] );
s( t, 1, 6, [ 1, 7 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 4, [ 1, 5 ] );
s( t, 2, 5, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"1357P" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
for i in [3, 5] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 4, [ 1, 5 ] );
s( t, 2, 6, [ 1, 7 ] );
s( t, 3, 4, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"1357Q" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 5 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 4, [ 1, 6 ] );
s( t, 2, 6, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"1357R" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 5 ] );
s( t, 1, 6, [ 1, 7 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 4, [ 1, 6 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 3, 4, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"1357S" );
## One parameter family, with lambda <> 1
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 5 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 1, 6, [ 1, 7 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 4, [ 1, 6 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 2, 6, [ lambda, 7 ] );
s( t, 3, 4, [ 1, 7 ] );
Add(tables, t);
## When lambda = 1, it is isomorphic to (2357D).

## Remark: (1357K) in Seeley's list is a special case of
## (1357M) by taking lambda = 1/2:

## Upper Central Series Dimensions (13457)

Add( SNLA_NAMES,"13457A" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 6, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"13457B" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 3, [ 1, 7 ] );
s( t, 2, 6, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"13457C" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 6, [ 1, 7 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 3, 4, [ -1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"13457D" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 4, [ 1, 7 ] );
s( t, 2, 6, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"13457E" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 6, [ 1, 7 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 3, 4, [ -1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"13457F" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 6, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"13457G" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 6, [ 1, 7 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 4, [ 1, 7 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 3, 4, [ -1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"13457I" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 2, 6, [ 1, 7 ] );
s( t, 3, 4, [ -1, 7 ] );
Add(tables, t);

## Remark: (13457H) in Seeley's list is not a Lie algebra, should be
## deleted.

## Upper Central Series Dimensions (12457)

Add( SNLA_NAMES,"12457A" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 4, [ 1, 6 ] );
s( t, 1, 6, [ 1, 7 ] );
s( t, 2, 5, [ 1, 6 ] );
s( t, 3, 5, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"12457B" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 4, [ 1, 6 ] );
s( t, 1, 6, [ 1, 7 ] );
s( t, 2, 5, [ 1, 6, 1, 7 ] );
s( t, 3, 5, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"12457C" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 4, [ 1, 6 ] );
s( t, 2, 5, [ 1, 6 ] );
s( t, 2, 6, [ 1, 7 ] );
s( t, 3, 4, [ -1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"12457D" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
for i in [4, 5] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 2, 5, [ 1, 6 ] );
s( t, 2, 6, [ 1, 7 ] );
s( t, 3, 4, [ -1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"12457E" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 4, [ 1, 6 ] );
s( t, 1, 6, [ 1, 7 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 4, [ 1, 7 ] );
s( t, 2, 5, [ 1, 6 ] );
s( t, 3, 5, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"12457F" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 4, [ 1, 6 ] );
s( t, 2, 3, [ 1, 6 ] );
for i in [5, 6] do
  s( t, 2, i, [ 1, i+1 ] );
od;
s( t, 3, 4, [ -1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"12457G" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 4, [ 1, 6 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 3, [ 1, 6 ] );
for i in [5, 6] do
  s( t, 2, i, [ 1, i+1 ] );
od;
s( t, 3, 4, [ -1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"12457H" );
t:= e(7);
for i in [2, 3, 5, 6] do
  s( t, 1, i, [ 1, i+1 ] );
od;
for j in [3, 4] do
  s( t, 2, j, [ 1, j+2 ] );
od;
s( t, 3, 4, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"12457I" );
t:= e(7);
for i in [2, 3, 5, 6] do
  s( t, 1, i, [ 1, i+1 ] );
od;
for j in [3, 4] do
  s( t, 2, j, [ 1, j+2 ] );
od;
s( t, 2, 5, [ 1, 7 ] );
s( t, 3, 4, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"12457J" );
t:= e(7);
for i in [2, 3, 5, 6] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 4, [ 1, 7 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 4, [ 1, 6 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 3, 4, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"12457K" );
t:= e(7);
for i in [2, 3, 5, 6] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 4, [ 1, 7 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 4, [ 1, 6 ] );
s( t, 3, 4, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"12457L" );
t:= e(7);
for i in [2, 3, 5, 6] do
  s( t, 1, i, [ 1, i+1 ] );
od;
for j in [3, 4] do
  s( t, 2, j, [ 1, j+2 ] );
od;
s( t, 2, 6, [ 1, 7 ] );
s( t, 3, 4, [ 1, 7 ] );
s( t, 3, 5, [ -1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"12457N" );
## One parameter family, with invariant I(lambda) = lambda + lambda^-1.
t:= e(7);
for i in [2, 3, 5, 6] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 4, [ 1, 7 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 4, [ 1, 6 ] );
s( t, 2, 5, [ lambda, 7 ] );
s( t, 2, 6, [ 1, 7 ] );
s( t, 3, 4, [ 1, 7 ] );
s( t, 3, 5, [ -1, 7 ] );
Add(tables, t);
## Remark: (12457M) in Seeley's list is just a special case of
## (12457N) by taking lambda = 0.

## Upper Central Series Dimensions (12357)

Add( SNLA_NAMES,"12357A" );
t:= e(7);
s( t, 1, 2, [ 1, 4 ] );
for i in [4, 5, 6] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 2, 3, [ 1, 5 ] );
s( t, 3, 4, [ -1, 6 ] );
s( t, 3, 5, [ -1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"12357B" );
t:= e(7);
s( t, 1, 2, [ 1, 4 ] );
for i in [4, 5, 6] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 2, 3, [ 1, 5, 1, 7 ] );
s( t, 3, 4, [ -1, 6 ] );
s( t, 3, 5, [ -1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"12357C" );
t:= e(7);
s( t, 1, 2, [ 1, 4 ] );
for i in [4, 5, 6] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 4, [ 1, 7 ] );
s( t, 3, 4, [ -1, 6 ] );
s( t, 3, 5, [ -1, 7 ] );
Add(tables, t);

## Upper Central Series Dimensions (123457)

Add( SNLA_NAMES,"123457A" );
t:= e(7);
for i in [2 .. 6] do
  s( t, 1, i, [ 1, i+1 ] );
od;
Add(tables, t);

Add( SNLA_NAMES,"123457B" );
t:= e(7);
for i in [2 .. 6] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 2, 3, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"123457C" );
t:= e(7);
for i in [2 .. 6] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 2, 5, [ 1, 7 ] );
s( t, 3, 4, [ -1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"123457D" );
t:= e(7);
for i in [2 .. 5] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 6, [ 1, 7 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 4, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"123457E" );
t:= e(7);
for i in [2 .. 5] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 6, [ 1, 7 ] );
s( t, 2, 3, [ 1, 6, 1, 7 ] );
s( t, 2, 4, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"123457F" );
t:= e(7);
for i in [2 .. 5] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 6, [ 1, 7 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 4, [ 1, 7 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 3, 4, [ -1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"123457G" );
## It is a member of the one parameter family "123457I", with
## lambda = 1, and was not included by Gong, but this algebra has
## different invariants
t:= e(7);
for i in [2 .. 5] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 6, [ 1, 7 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 4, [ 1, 6 ] );
s( t, 2, 5, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"123457H" );
t:= e(7);
for i in [2 .. 5] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 6, [ 1, 7 ] );
s( t, 2, 3, [ 1, 5, 1, 7 ] );
s( t, 2, 4, [ 1, 6 ] );
s( t, 2, 5, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"123457I" );
## One parameter family.
t:= e(7);
for i in [2 .. 5] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 6, [ 1, 7 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 4, [ 1, 6 ] );
s( t, 2, 5, [ lambda, 7 ] );
s( t, 3, 4, [ (1 - lambda), 7 ] );
Add(tables, t);

## Remark: (123457G) in Seeley's list is a special case of (123457I) with
## lambda = 1.


## Paragraph 4.2
## List of 7-Dimensional Indecomposable Nilpotent Lie Algebras over the
## Real Field

## Each of the algebras in the list of Section 4.1 can be interpreted as a
## Lie algebra over R. In the case of infinte families, we have to
## restrict the parameter lambda to take real values. The exceptional
## algebra which occurs in the case char = 3 should be omitted. In
## addition to these algebras, we have the following 24 extra
## indecomposable algebras over the real field R.

## Upper Central Series Dimensions (37)

Add( SNLA_NAMES,"37B1" );
t:= e(7);
s( t, 1, 2, [ 1, 5 ] );
s( t, 1, 3, [ 1, 6 ] );
s( t, 1, 4, [ 1, 7 ] );
s( t, 2, 4, [ 1, 6 ] );
s( t, 3, 4, [ -1, 5 ] );
Add(tables, t);

Add( SNLA_NAMES,"37D1" );
t:= e(7);
s( t, 1, 2, [ 1, 5 ] );
s( t, 1, 3, [ 1, 6 ] );
s( t, 1, 4, [ 1, 7 ] );
s( t, 2, 3, [ -1, 7 ] );
s( t, 2, 4, [ 1, 6 ] );
s( t, 3, 4, [ -1, 5 ] );
Add(tables, t);

## Upper Central Series Dimensions (257)

Add( SNLA_NAMES,"257J1" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 6 ] );
s( t, 1, 4, [ 1, 6 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 3, [ 1, 7 ] );
s( t, 2, 5, [ 1, 6 ] );
Add(tables, t);

## Upper Central Series Dimensions (247)

Add( SNLA_NAMES,"247E1" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 2, 4, [ 1, 7 ] );
s( t, 3, 5, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"247F1" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 2, 4, [ 1, 6 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 3, 4, [ 1, 7 ] );
s( t, 3, 5, [ -1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"247H1" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 2, 4, [ 1, 6 ] );
s( t, 2, 5, [ 1, 7 ] );
s( t, 3, 4, [ 1, 7 ] );
s( t, 3, 5, [ -1, 6 ] );
Add(tables, t);

Add( SNLA_NAMES,"247P1" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 4, [ 1, 7 ] );
s( t, 3, 5, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"247R1" );
t:= e(7);
for i in [2, 3, 4] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 4, [ 1, 7 ] );
s( t, 3, 5, [ 1, 7 ] );
Add(tables, t);

## Upper Central Series Dimensions (2457)

Add( SNLA_NAMES,"2457L1" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 4, [ 1, 6 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 4, [ 1, 7 ] );
s( t, 2, 5, [ -1, 6 ] );
Add(tables, t);

## Upper Central Series Dimensions (2357)

Add( SNLA_NAMES,"2357D1" );
t:= e(7);
s( t, 1, 2, [ 1, 4 ] );
s( t, 1, 3, [ 1, 6 ] );
s( t, 1, 4, [ 1, 5 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 4, [ -1, 6 ] );
s( t, 3, 4, [ -1, 7 ] );
Add(tables, t);

## Upper Central Series Dimensions (147)

Add( SNLA_NAMES,"147A1" );
t:= e(7);
s( t, 1, 2, [ 1, 4 ] );
s( t, 1, 3, [ 1, 5 ] );
s( t, 1, 6, [ 1, 7 ] );
s( t, 2, 4, [ 1, 7 ] );
s( t, 3, 5, [ 1, 7 ] );
Add(tables, t);

if char<>2 then
Add( SNLA_NAMES,"147E1" );
## One parameter family, with lambda > 1
t:= e(7);
s( t, 1, 2, [ 1, 4 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 1, 3, [ -1, 6 ] );
s( t, 1, 6, [ - lambda, 7 ] );
s( t, 2, 5, [ lambda, 7 ] );
s( t, 2, 6, [ 2, 7 ] );
s( t, 3, 4, [ -2, 7 ] );
Add(tables, t);
fi;

## Upper Central Series Dimensions (137)

Add( SNLA_NAMES,"137A1" );
t:= e(7);
s( t, 1, 3, [ 1, 5 ] );
s( t, 1, 4, [ 1, 6 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 3, [ -1, 6 ] );
s( t, 2, 4, [ 1, 5 ] );
s( t, 2, 6, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"137B1" );
t:= e(7);
s( t, 1, 3, [ 1, 5 ] );
s( t, 1, 4, [ 1, 6 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 3, [ -1, 6 ] );
s( t, 2, 4, [ 1, 5 ] );
s( t, 2, 6, [ 1, 7 ] );
s( t, 3, 4, [ 1, 7 ] );
Add(tables, t);

## Upper Central Series Dimensions (1357)

Add( SNLA_NAMES,"1357F1" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 7 ] );
for i in [3, 4] do
  s( t, 2, i, [ 1, i+2 ] );
od;
s( t, 2, 5, [ 1, 7 ] );
s( t, 4, 6, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"1357P1" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
for i in [3, 5] do
  s( t, 1, i, [ 1, i+2 ] );
od;
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 4, [ 1, 5 ] );
s( t, 2, 6, [ -1, 7 ] );
s( t, 3, 4, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"1357Q1" );
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 5 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 3, [ 1, 6 ] );
s( t, 2, 4, [ 1, 6 ] );
s( t, 2, 6, [ -1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"1357QRS1" );
## One parameter family, with invariant I(lambda) = lambda + lambda^-1 and
## lambda <> 0.
t:= e(7);
s( t, 1, 2, [ 1, 3 ] );
s( t, 1, 3, [ 1, 5 ] );
s( t, 1, 4, [ 1, 6 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 2, 3, [ -1, 6] );
s( t, 2, 4, [ 1, 5 ] );
s( t, 2, 6, [ lambda, 7 ] );
s( t, 3, 4, [ (1 - lambda), 7 ] );
Add(tables, t);
## When lambda = 1, (1357QRS1), =~ (1357Q) over C;
## When lambda = - 1, (1357QRS1) =~ (1357R) over C.
## (1357QRS1, lambda <> 0, 1, -1 ) becomes (1357S, lambda > 1) over C.
## When lambda = 0, it becomes (2357D).

## Upper Central Series Dimensions (12457)

Add( SNLA_NAMES,"12457J1" );
t:= e(7);
for i in [2, 3, 5, 6] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 4, [ 1, 7 ] );
for j in [3, 4] do
  s( t, 2, j, [ 1, j+2 ] );
od;
s( t, 2, 5, [ -1, 7 ] );
s( t, 3, 4, [ 1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"12457L1" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 4, [ -1, 6 ] );
s( t, 1, 6, [ 1, 7 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 5, [ -1, 6 ] );
s( t, 3, 5, [ -1, 7 ] );
Add(tables, t);

Add( SNLA_NAMES,"12457N1" );
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 4, [ -1, 6 ] );
s( t, 1, 6, [ 1, 7 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 5, [ -1, 6, 1, 7 ] );
s( t, 3, 5, [ -1, 7 ] );
Add(tables, t);
## It is isomorphic to (12457N, lambda = 1) over C.

Add( SNLA_NAMES,"12457N2" );
## One parameter family, with lambda lambda >= 0.
t:= e(7);
for i in [2, 3] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 4, [ -1, 6 ] );
s( t, 1, 5, [ 1, 7 ] );
s( t, 1, 6, [ 1, 7 ] );
s( t, 2, 3, [ 1, 5 ] );
s( t, 2, 4, [ 1, 7 ] );
s( t, 2, 5, [ -1, 6, lambda, 7 ] );
s( t, 3, 5, [ -1, 7 ] );
Add(tables, t);
## It is isomorphic to (12457N, lambda <> 1) over C.

## Upper Central Series Dimensions (12357)

Add( SNLA_NAMES,"12357B1" );
t:= e(7);
s( t, 1, 2, [ 1, 4 ] );
for i in [4, 5, 6] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 2, 3, [ 1, 5, -1, 7 ] );
s( t, 3, 4, [ -1, 6 ] );
s( t, 3, 5, [ -1, 7 ] );
Add(tables, t);

## Upper Central Series Dimensions (123457)

Add( SNLA_NAMES,"123457H1" );
t:= e(7);
for i in [2 .. 5] do
  s( t, 1, i, [ 1, i+1 ] );
od;
s( t, 1, 6, [ -1, 7 ] );
s( t, 2, 3, [ 1, 5, 1, 7 ] );
s( t, 2, 4, [ 1, 6 ] );
s( t, 2, 5, [ -1, 7 ] );
Add(tables, t);

if not ForAll(tables, x-> TestJacobi(x)=true) then Error("TestJacobi");fi;

l := List( tables, x -> LieAlgebraByStructureConstants( campo, x ) );
for i in [1..Length(l)] do
  SetSnLa_Name(l[i], SNLA_NAMES[i]);
od;
  return l;
end;
