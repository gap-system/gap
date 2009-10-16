LieTables:=function(field, dimension, parameters)

local T, dim,
    SetEntrySCTable1, ZeroTab,            # local functions
    a1, a2, a3,                           # indeterminates
    a, b, c, p, q, s,                     # parameters
    dim2, dim3, dim4, dim5, dim6, dim7,   # structure constants tables
    stringtabs2, stringtabs3, stringtabs4, stringtabs5, stringtabs6,
stringtabs7;


if dimension = 0 then
    return [[[ -1, Zero(field) ]], [[]], [] ];
fi;
if dimension = 1 then
    return [[ [ [ [ [  ], [  ] ] ], -1, Zero(field) ]], [[]], [] ];
fi;
if dimension > 7 then 
    return [[],[],[]];
fi;


a1:= Indeterminate(field,"a1":old);
a2:= Indeterminate(field,"a2":old);
a3:= Indeterminate(field,"a3":old);


ZeroTab:=function( n )

   local S,i;

   S:= [ ];
   for i in [1..n] do
    S[i]:=MutableNullMat(n,n);
   od;
   return S;
end;

SetEntrySCTable1:= function( S, i, j, lst )

   local st,v,k,p,q;

   p:=1;
   while p < Length( lst ) do
     v:=lst[p]; k:=lst[p+1];
     S[i][j][k]:= v;
     if IsString(v) then
       if ( v[1] = '-' ) then
         S[j][i][k]:= v{[2..Length(v)]};
       else
         st:= "-";
         Append( st, v );
         S[j][i][k]:=st;
       fi;
     else
       S[j][i][k]:=-v;
     fi;
     p:= p+2;
   od;
end;


# Tables of dimension 2
if dimension = 2 then

T:=EmptySCTable( 2, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,2] );
dim2:=[T]; stringtabs2:=[ [] ];

fi;

# Tables of dimension 3

if dimension = 3 then

dim3:= [ ];
stringtabs3:= [ ];

#A3,1
T:=EmptySCTable( 3, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
Add( dim3, T ); Add( stringtabs3, [] );

#A3,2
T:=EmptySCTable( 3, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 3, [1,1] );
SetEntrySCTable( T, 2, 3, [1,1,1,2] );
Add( dim3, T ); Add( stringtabs3, [] );

#A3,3 and A3,4
T:=EmptySCTable( 3, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 3, [1,1] );
SetEntrySCTable( T, 2, 3, [1,2] );
Add( dim3, T ); Add( stringtabs3, [] );

#A3,5 and A3,6
a:=2;
T:=EmptySCTable( 3, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 3, [1,1] );
SetEntrySCTable( T, 2, 3, [a,2] );
Add( dim3, T ); 

T:=ZeroTab( 3 );
SetEntrySCTable1( T, 1, 3, [1,1] );
SetEntrySCTable1( T, 2, 3, [a1,2] );
Add( stringtabs3, T ); 

#A3,7
a:=1;
T:=EmptySCTable( 3, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 3, [a,1,-1,2] );
SetEntrySCTable( T, 2, 3, [1,1,a,2] );
Add( dim3, T ); 

T:=ZeroTab(3);
SetEntrySCTable1( T, 3, 1, [1,2] );
SetEntrySCTable1( T, 1, 3, [a1,1] );
SetEntrySCTable1( T, 2, 3, [1,1] );
SetEntrySCTable1( T, 2, 3, [a1,2] );
Add( stringtabs3, T );

#A3,8
T:=EmptySCTable( 3, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 3, [-2,1] );
SetEntrySCTable( T, 2, 3, [2,2] );
SetEntrySCTable( T, 1, 2, [1,3] );
Add( dim3, T ); Add( stringtabs3, [] );

#A3,9
T:=EmptySCTable( 3, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 3, [-1,2] );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 1, 2, [1,3] );
Add( dim3, T ); Add( stringtabs3, [] );

fi;

# Tables of dimension 4

if dimension = 4 then

dim4:= [ ];
stringtabs4:= [ ];

#1
T:=EmptySCTable( 4, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 4, [1,1] );
SetEntrySCTable( T, 3, 4, [1,2] );
Add( dim4, T ); Add( stringtabs4, [ ] );

#2
T:=EmptySCTable( 4, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 4, [1,1] );
SetEntrySCTable( T, 2, 4, [1,2] );
SetEntrySCTable( T, 3, 4, [1,2,1,3] );
Add( dim4, T ); Add( stringtabs4, [ ] );

#3
a:=2; # a<>0
T:=EmptySCTable( 4, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 4, [a,1] );
SetEntrySCTable( T, 2, 4, [1,2] );
SetEntrySCTable( T, 3, 4, [1,2,1,3] );
Add( dim4, T );

T:=ZeroTab( 4 );
SetEntrySCTable1( T, 1, 4, [a1,1] );
SetEntrySCTable1( T, 2, 4, [1,2] );
SetEntrySCTable1( T, 3, 4, [1,2] );
SetEntrySCTable1( T, 3, 4, [1,3] );
Add( stringtabs4, T );

#4
T:=EmptySCTable( 4, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 4, [1,1] );
SetEntrySCTable( T, 3, 4, [1,2] );
Add( dim4, T ); Add( stringtabs4, [ ] );

#5
T:=EmptySCTable( 4, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 4, [1,1] );
SetEntrySCTable( T, 2, 4, [1,1,1,2] );
SetEntrySCTable( T, 3, 4, [1,2,1,3] );
Add( dim4, T ); Add( stringtabs4, [ ] );

#6
T:=EmptySCTable( 4, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 4, [1,1] );
SetEntrySCTable( T, 2, 4, [1,2] );
SetEntrySCTable( T, 3, 4, [1,3] );
Add( dim4, T ); Add( stringtabs4, [ ] );

#7
a:=2; 
T:=EmptySCTable( 4, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 4, [1,1] );
SetEntrySCTable( T, 2, 4, [1,2] );
SetEntrySCTable( T, 3, 4, [a,3] );
Add( dim4, T );

T:=ZeroTab( 4 );
SetEntrySCTable1( T, 1, 4, [1,1] );
SetEntrySCTable1( T, 2, 4, [1,2] );
SetEntrySCTable1( T, 3, 4, [a1,3] );
Add( stringtabs4, T );

#8
a:= -2; b:=2; # ab <> 0, -1 < b <= 1 
T:=EmptySCTable( 4, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 4, [1,1] );
SetEntrySCTable( T, 2, 4, [a,2] );
SetEntrySCTable( T, 3, 4, [b,3] );
Add( dim4, T );

T:=ZeroTab( 4 );
SetEntrySCTable1( T, 1, 4, [1,1] );
SetEntrySCTable1( T, 2, 4, [a1,2] );
SetEntrySCTable1( T, 3, 4, [a2,3] );
Add( stringtabs4, T );

#9
a:=2; b:=3; # a <> 0, b >= 0
T:=EmptySCTable( 4, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 4, [a,1] );
SetEntrySCTable( T, 2, 4, [b,2,-1,3] );
SetEntrySCTable( T, 3, 4, [1,2,b,3] );
Add( dim4, T );

T:=ZeroTab( 4 );
SetEntrySCTable1( T, 1, 4, [a1,1] );
SetEntrySCTable1( T, 2, 4, [a2,2] );
SetEntrySCTable1( T, 2, 4, [-1,3] );
SetEntrySCTable1( T, 3, 4, [a2,3] );
SetEntrySCTable1( T, 3, 4, [1,2] );
Add( stringtabs4, T );

#10
T:=EmptySCTable( 4, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 4, [2,1] );
SetEntrySCTable( T, 2, 4, [1,2] );
SetEntrySCTable( T, 3, 4, [1,2,1,3] );
SetEntrySCTable( T, 2, 3, [1,1] );
Add( dim4, T ); Add( stringtabs4, [ ] );

#11
T:=EmptySCTable( 4, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 2, 4, [1,2] );
SetEntrySCTable( T, 3, 4, [-1,3] );
Add( dim4, T ); Add( stringtabs4, [ ] );

#12
T:=EmptySCTable( 4, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 1, 4, [1,1] );
SetEntrySCTable( T, 2, 4, [1,2] );
Add( dim4, T ); Add( stringtabs4, [ ] );

#13
T:=EmptySCTable( 4, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 1, 4, [2,1] );
SetEntrySCTable( T, 2, 4, [1,2] );
SetEntrySCTable( T, 3, 4, [1,3] );
Add( dim4, T ); Add( stringtabs4, [ ] );

#14
b:=2; 
T:=EmptySCTable( 4, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 1, 4, [1+b,1] );
SetEntrySCTable( T, 2, 4, [1,2] );
SetEntrySCTable( T, 3, 4, [b,3] );
Add( dim4, T );

T:=ZeroTab( 4 );
SetEntrySCTable1( T, 2, 3, [1,1] );
SetEntrySCTable1( T, 1, 4, [1+a1,1] );
SetEntrySCTable1( T, 2, 4, [1,2] );
SetEntrySCTable1( T, 3, 4, [a1,3] );
Add( stringtabs4, T );

#15
T:=EmptySCTable( 4, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 2, 4, [-1,3] );
SetEntrySCTable( T, 3, 4, [1,2] );
Add( dim4, T ); Add( stringtabs4, [ ] );

#16
a:=1; # a > 0
T:=EmptySCTable( 4, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 4, [2*a,1] );
SetEntrySCTable( T, 2, 4, [a,2,-1,3] );
SetEntrySCTable( T, 3, 4, [1,2,a,3] );
SetEntrySCTable( T, 2, 3, [1,1] );
Add( dim4, T );

T:=ZeroTab( 4 );
SetEntrySCTable1( T, 1, 4, [2*a1,1] );
SetEntrySCTable1( T, 2, 4, [a1,2] );
SetEntrySCTable1( T, 2, 4, [-1,3] );
SetEntrySCTable1( T, 3, 4, [1,2] );
SetEntrySCTable1( T, 3, 4, [a1,3] );
SetEntrySCTable1( T, 2, 3, [1,1] );
Add( stringtabs4, T );

#17
T:=EmptySCTable( 4, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 3, [1,1] );
SetEntrySCTable( T, 2, 3, [1,2] );
SetEntrySCTable( T, 1, 4, [-1,2] );
SetEntrySCTable( T, 2, 4, [1,1] );
Add( dim4, T ); Add( stringtabs4, [ ] );

fi;

# Tables of dimension 5

if dimension = 5 then


dim5:= [ ];
stringtabs5:= [ ];

#1
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 3, 5, [1,1] );
SetEntrySCTable( T, 4, 5, [1,2] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#2
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 5, [1,1] );
SetEntrySCTable( T, 3, 5, [1,2] );
SetEntrySCTable( T, 4, 5, [1,3] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#3
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 3, 4, [1,2] );
SetEntrySCTable( T, 3, 5, [1,1] );
SetEntrySCTable( T, 4, 5, [1,3] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#4
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 4, [1,1] );
SetEntrySCTable( T, 3, 5, [1,1] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#5
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 3, 4, [1,1] );
SetEntrySCTable( T, 2, 5, [1,1] );
SetEntrySCTable( T, 3, 5, [1,2] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#6
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 3, 4, [1,1] );
SetEntrySCTable( T, 2, 5, [1,1] );
SetEntrySCTable( T, 3, 5, [1,2] );
SetEntrySCTable( T, 4, 5, [1,3] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#7
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 2, 5, [1,2] );
SetEntrySCTable( T, 3, 5, [1,3] );
SetEntrySCTable( T, 4, 5, [1,4] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#8
c:=2;
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 2, 5, [1,2] );
SetEntrySCTable( T, 3, 5, [1,3] );
SetEntrySCTable( T, 4, 5, [c,4] );
Add( dim5, T );

T:= ZeroTab( 5 );
SetEntrySCTable1( T, 1, 5, [1,1] );
SetEntrySCTable1( T, 2, 5, [1,2] );
SetEntrySCTable1( T, 3, 5, [1,3] );
SetEntrySCTable1( T, 4, 5, [a1,4] );
Add( stringtabs5, T );

#9
b:=2;
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 2, 5, [1,2] );
SetEntrySCTable( T, 3, 5, [b,3] );
SetEntrySCTable( T, 4, 5, [b,4] );
Add( dim5, T );

T:= ZeroTab( 5 );
SetEntrySCTable1( T, 1, 5, [1,1] );
SetEntrySCTable1( T, 2, 5, [1,2] );
SetEntrySCTable1( T, 3, 5, [a1,3] );
SetEntrySCTable1( T, 4, 5, [a1,4] );
Add( stringtabs5, T );

#10
b:=2; c:=3;
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 2, 5, [1,2] );
SetEntrySCTable( T, 3, 5, [b,3] );
SetEntrySCTable( T, 4, 5, [c,4] );
Add( dim5, T );

T:= ZeroTab( 5 );
SetEntrySCTable1( T, 1, 5, [1,1] );
SetEntrySCTable1( T, 2, 5, [1,2] );
SetEntrySCTable1( T, 3, 5, [a1,3] );
SetEntrySCTable1( T, 4, 5, [a2,4] );
Add( stringtabs5, T );

#11
a:=2; b:=3; c:=4;
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 2, 5, [a,2] );
SetEntrySCTable( T, 3, 5, [b,3] );
SetEntrySCTable( T, 4, 5, [c,4] );
Add( dim5, T );

T:= ZeroTab( 5 );
SetEntrySCTable1( T, 1, 5, [1,1] );
SetEntrySCTable1( T, 2, 5, [a1,2] );
SetEntrySCTable1( T, 3, 5, [a2,3] );
SetEntrySCTable1( T, 4, 5, [a3,4] );
Add( stringtabs5, T );

#12
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 5, [1,1] );
SetEntrySCTable( T, 3, 5, [1,3] );
SetEntrySCTable( T, 4, 5, [1,4] );
Add( dim5, T ); Add( stringtabs5, [] );

#13
c:= 2; # 0 < |c| <= 1
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 3, 5, [1,3] );
SetEntrySCTable( T, 2, 5, [1,1] );
SetEntrySCTable( T, 4, 5, [c,4] );
Add( dim5, T );

T:=ZeroTab( 5 );
SetEntrySCTable1( T, 3, 5, [1,3] );
SetEntrySCTable1( T, 2, 5, [1,1] );
SetEntrySCTable1( T, 4, 5, [a1,4] );
Add( stringtabs5, T );

#14
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 2, 5, [1,1,1,2] );
SetEntrySCTable( T, 3, 5, [1,3] );
SetEntrySCTable( T, 4, 5, [1,4] );
Add( dim5, T ); Add( stringtabs5, [] );

#15
b:=2;
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 2, 5, [1,1,1,2] );
SetEntrySCTable( T, 3, 5, [b,3] );
SetEntrySCTable( T, 4, 5, [b,4] );
Add( dim5, T );

T:=ZeroTab( 5 );
SetEntrySCTable1( T, 1, 5, [1,1] );
SetEntrySCTable1( T, 2, 5, [1,1] );
SetEntrySCTable1( T, 2, 5, [1,2] );
SetEntrySCTable1( T, 3, 5, [a1,3] );
SetEntrySCTable1( T, 4, 5, [a1,4] );
Add( stringtabs5, T );

#16
c:=2;
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 2, 5, [1,1,1,2] );
SetEntrySCTable( T, 3, 5, [1,3] );
SetEntrySCTable( T, 4, 5, [c,4] );
Add( dim5, T );

T:=ZeroTab( 5 );
SetEntrySCTable1( T, 1, 5, [1,1] );
SetEntrySCTable1( T, 2, 5, [1,1] );
SetEntrySCTable1( T, 2, 5, [1,2] );
SetEntrySCTable1( T, 3, 5, [1,3] );
SetEntrySCTable1( T, 4, 5, [a1,4] );
Add( stringtabs5, T );

#17
b:=2; c:=3; 
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 2, 5, [1,1,1,2] );
SetEntrySCTable( T, 3, 5, [b,3] );
SetEntrySCTable( T, 4, 5, [c,4] );
Add( dim5, T );

T:=ZeroTab( 5 );
SetEntrySCTable1( T, 1, 5, [1,1] );
SetEntrySCTable1( T, 2, 5, [1,1] );
SetEntrySCTable1( T, 2, 5, [1,2] );
SetEntrySCTable1( T, 3, 5, [a1,3] );
SetEntrySCTable1( T, 4, 5, [a2,4] );
Add( stringtabs5, T );

#18
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 3, 5, [1,2] );
SetEntrySCTable( T, 2, 5, [1,1] );
SetEntrySCTable( T, 4, 5, [1,4] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#19
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 2, 5, [1,1,1,2] );
SetEntrySCTable( T, 3, 5, [1,2,1,3] );
SetEntrySCTable( T, 4, 5, [1,4] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#20
c:= 2; 
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 2, 5, [1,1,1,2] );
SetEntrySCTable( T, 3, 5, [1,2,1,3] );
SetEntrySCTable( T, 4, 5, [c,4] );
Add( dim5, T );

T:=ZeroTab( 5 );
SetEntrySCTable1( T, 1, 5, [1,1] );
SetEntrySCTable1( T, 2, 5, [1,1] );
SetEntrySCTable1( T, 2, 5, [1,2] );
SetEntrySCTable1( T, 3, 5, [1,2] );
SetEntrySCTable1( T, 3, 5, [1,3] );
SetEntrySCTable1( T, 4, 5, [a1,4] );
Add( stringtabs5, T );

#21
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 2, 5, [1,1,1,2] );
SetEntrySCTable( T, 3, 5, [1,2,1,3] );
SetEntrySCTable( T, 4, 5, [1,3,1,4] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#22
p:=1; q:=1;
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 2, 5, [1,2] );
SetEntrySCTable( T, 3, 5, [p,3,-q,4] );
SetEntrySCTable( T, 4, 5, [q,3,p,4] );
Add( dim5, T );

T:=ZeroTab( 5 );
SetEntrySCTable1( T, 1, 5, [1,1] );
SetEntrySCTable1( T, 2, 5, [1,2] );
SetEntrySCTable1( T, 3, 5, [a1,3] );
SetEntrySCTable1( T, 5, 3, [a2,4] );
SetEntrySCTable1( T, 4, 5, [a2,3] );
SetEntrySCTable1( T, 4, 5, [a1,4] );
Add( stringtabs5, T );

#23
a:=2; p:=2; q:=3; 
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 2, 5, [a,2] );
SetEntrySCTable( T, 3, 5, [p,3,-q,4] );
SetEntrySCTable( T, 4, 5, [q,3,p,4] );
Add( dim5, T );

T:=ZeroTab( 5 );
SetEntrySCTable1( T, 1, 5, [1,1] );
SetEntrySCTable1( T, 2, 5, [a1,2] );
SetEntrySCTable1( T, 3, 5, [a2,3] );
SetEntrySCTable1( T, 5, 3, [a3,4] );
SetEntrySCTable1( T, 4, 5, [a3,3] );
SetEntrySCTable1( T, 4, 5, [a2,4] );
Add( stringtabs5, T );

#24
p:=2; # no conditions
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 5, [1,1] );
SetEntrySCTable( T, 3, 5, [p,3,-1,4] );
SetEntrySCTable( T, 4, 5, [1,3,p,4] );
Add( dim5, T );

T:=ZeroTab( 5 );
SetEntrySCTable1( T, 2, 5, [1,1] );
SetEntrySCTable1( T, 3, 5, [a1,3] );
SetEntrySCTable1( T, 5, 3, [a2,4] );
SetEntrySCTable1( T, 4, 5, [1,3] );
SetEntrySCTable1( T, 4, 5, [a1,4] );
Add( stringtabs5, T );

#25
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 2, 5, [1,1,1,2] );
SetEntrySCTable( T, 3, 5, [1,3] );
SetEntrySCTable( T, 4, 5, [1,3,1,4] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#26
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 2, 5, [1,1,1,2] );
SetEntrySCTable( T, 4, 5, [1,3] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#27
a:= 2; 
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 2, 5, [1,1,1,2] );
SetEntrySCTable( T, 3, 5, [a,3] );
SetEntrySCTable( T, 4, 5, [1,3,a,4] );
Add( dim5, T );

T:=ZeroTab( 5 );
SetEntrySCTable1( T, 1, 5, [1,1] );
SetEntrySCTable1( T, 2, 5, [1,1] );
SetEntrySCTable1( T, 2, 5, [1,2] );
SetEntrySCTable1( T, 3, 5, [a1,3] );
SetEntrySCTable1( T, 4, 5, [1,3] );
SetEntrySCTable1( T, 4, 5, [a1,4] );
Add( stringtabs5, T );

#28
p:=2; q:=3; 
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 2, 5, [1,1,1,2] );
SetEntrySCTable( T, 3, 5, [p,3,-q,4] );
SetEntrySCTable( T, 4, 5, [q,3,p,4] );
Add( dim5, T );

T:= ZeroTab( 5 );
SetEntrySCTable1( T, 1, 5, [1,1] );
SetEntrySCTable1( T, 2, 5, [1,1] );
SetEntrySCTable1( T, 2, 5, [1,2] );
SetEntrySCTable1( T, 3, 5, [a1,3] );
SetEntrySCTable1( T, 5, 3, [a2,4] );
SetEntrySCTable1( T, 4, 5, [a2,3] );
SetEntrySCTable1( T, 4, 5, [a1,4] );
Add( stringtabs5, T );

#29
p:=1; q:=2; s:=3; 
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 5, [p,1,-1,2] );
SetEntrySCTable( T, 2, 5, [1,1,p,2] );
SetEntrySCTable( T, 3, 5, [q,3,-s,4] );
SetEntrySCTable( T, 4, 5, [s,3,q,4] );
Add( dim5, T );

T:=ZeroTab( 5 );
SetEntrySCTable1( T, 1, 5, [a1,1,-1,2] );
SetEntrySCTable1( T, 2, 5, [1,1,a1,2] );
SetEntrySCTable1( T, 3, 5, [a2,3,-a3,4] );
SetEntrySCTable1( T, 4, 5, [a3,3,a2,4] );
Add( stringtabs5, T );

#30
p:=1; 
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 5, [p,1,-1,2] );
SetEntrySCTable( T, 2, 5, [1,1,p,2] );
SetEntrySCTable( T, 3, 5, [1,1,p,3,-1,4] );
SetEntrySCTable( T, 4, 5, [1,2,1,3,p,4] );
Add( dim5, T );

T:=ZeroTab( 5 );
SetEntrySCTable1( T, 1, 5, [a1,1,-1,2] );
SetEntrySCTable1( T, 2, 5, [1,1,a1,2] );
SetEntrySCTable1( T, 3, 5, [1,1,a1,3,-1,4] );
SetEntrySCTable1( T, 4, 5, [1,2,1,3,a1,4] );
Add( stringtabs5, T );

#31
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 1, 5, [2,1] );
SetEntrySCTable( T, 2, 5, [1,2] );
SetEntrySCTable( T, 3, 5, [1,3] );
SetEntrySCTable( T, 4, 5, [1,4] );
Add( dim5, T ); Add( stringtabs5, [] );

#32
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 1, 5, [2,1] );
SetEntrySCTable( T, 2, 5, [1,2] );
SetEntrySCTable( T, 3, 5, [1,3] );
SetEntrySCTable( T, 4, 5, [2,4] );
Add( dim5, T ); Add( stringtabs5, [] );

#33
b:=3;
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 1, 5, [2,1] );
SetEntrySCTable( T, 2, 5, [1,2] );
SetEntrySCTable( T, 3, 5, [1,3] );
SetEntrySCTable( T, 4, 5, [b,4] );
Add( dim5, T );

T:=ZeroTab( 5 );
SetEntrySCTable1( T, 2, 3, [1,1] );
SetEntrySCTable1( T, 1, 5, [2,1] );
SetEntrySCTable1( T, 2, 5, [1,2] );
SetEntrySCTable1( T, 3, 5, [1,3] );
SetEntrySCTable1( T, 4, 5, [a1,4] );
Add( stringtabs5, T );

#34
a:=3;
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 1, 5, [a,1] );
SetEntrySCTable( T, 2, 5, [1,2] );
SetEntrySCTable( T, 3, 5, [a-1,3] );
SetEntrySCTable( T, 4, 5, [1,4] );
Add( dim5, T );

T:=ZeroTab( 5 );
SetEntrySCTable1( T, 2, 3, [1,1] );
SetEntrySCTable1( T, 1, 5, [a1,1] );
SetEntrySCTable1( T, 2, 5, [1,2] );
SetEntrySCTable1( T, 3, 5, [a1-1,3] );
SetEntrySCTable1( T, 4, 5, [1,4] );
Add( stringtabs5, T );

#35
a:=3; b:=4; # b <> 0
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 1, 5, [a,1] );
SetEntrySCTable( T, 2, 5, [1,2] );
SetEntrySCTable( T, 3, 5, [a-1,3] );
SetEntrySCTable( T, 4, 5, [b,4] );
Add( dim5, T );

T:=ZeroTab( 5 );
SetEntrySCTable1( T, 2, 3, [1,1] );
SetEntrySCTable1( T, 1, 5, [a1,1] );
SetEntrySCTable1( T, 2, 5, [1,2] );
SetEntrySCTable1( T, 3, 5, [a1-1,3] );
SetEntrySCTable1( T, 4, 5, [a2,4] );
Add( stringtabs5, T );

#36
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 2, 5, [1,2] );
SetEntrySCTable( T, 4, 5, [1,4] );
Add( dim5, T ); Add( stringtabs5, [] );

#37
b:=2;
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 2, 5, [1,2] );
SetEntrySCTable( T, 4, 5, [b,4] );
Add( dim5, T );

T:=ZeroTab( 5 );
SetEntrySCTable1( T, 2, 3, [1,1] );
SetEntrySCTable1( T, 1, 5, [1,1] );
SetEntrySCTable1( T, 2, 5, [1,2] );
SetEntrySCTable1( T, 4, 5, [a1,4] );
Add( stringtabs5, T );

#38
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 2, 5, [1,2] );
SetEntrySCTable( T, 3, 5, [-1,3] );
SetEntrySCTable( T, 4, 5, [1,4] );
Add( dim5, T ); Add( stringtabs5, [] );

#39
#? this algebra is decomposable
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 2, 5, [1,2] );
SetEntrySCTable( T, 3, 5, [-1,3] );
Add( dim5, T ); Add( stringtabs5, [] );

#40
a:=3;
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 1, 5, [a,1] );
SetEntrySCTable( T, 2, 5, [1,2] );
SetEntrySCTable( T, 3, 5, [a-1,3] );
SetEntrySCTable( T, 4, 5, [a,4] );
Add( dim5, T );

T:=ZeroTab( 5 );
SetEntrySCTable1( T, 2, 3, [1,1] );
SetEntrySCTable1( T, 1, 5, [a1,1] );
SetEntrySCTable1( T, 2, 5, [1,2] );
SetEntrySCTable1( T, 3, 5, [a1-1,3] );
SetEntrySCTable1( T, 4, 5, [a1,4] );
Add( stringtabs5, T );

#41
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 3, 4, [1,1] );
SetEntrySCTable( T, 2, 5, [1,1] );
SetEntrySCTable( T, 3, 5, [1,3] );
SetEntrySCTable( T, 4, 5, [-1,4] );
Add( dim5, T ); Add( stringtabs5, [] );

#42
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 3, 4, [1,1] );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 2, 5, [1,1,1,2] );
SetEntrySCTable( T, 3, 5, [1,3] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#43
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 3, 4, [1,1] );
SetEntrySCTable( T, 1, 5, [2,1] );
SetEntrySCTable( T, 2, 5, [1,1,2,2] );
SetEntrySCTable( T, 3, 5, [1,3] );
SetEntrySCTable( T, 4, 5, [1,4] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#44
a:=3;
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 3, 4, [1,1] );
SetEntrySCTable( T, 1, 5, [a,1] );
SetEntrySCTable( T, 2, 5, [1,1,a,2] );
SetEntrySCTable( T, 3, 5, [1,3] );
SetEntrySCTable( T, 4, 5, [a-1,4] );
Add( dim5, T );

T:= ZeroTab( 5 );
SetEntrySCTable1( T, 3, 4, [1,1] );
SetEntrySCTable1( T, 1, 5, [a1,1] );
SetEntrySCTable1( T, 2, 5, [1,1,a1,2] );
SetEntrySCTable1( T, 3, 5, [1,3] );
SetEntrySCTable1( T, 4, 5, [a1-1,4] );
Add( stringtabs5, T );

#45
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 1, 5, [2,1] );
SetEntrySCTable( T, 2, 5, [1,2,1,3] );
SetEntrySCTable( T, 3, 5, [1,3,1,4] );
SetEntrySCTable( T, 4, 5, [1,4] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#46
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 2, 5, [1,3] );
SetEntrySCTable( T, 4, 5, [1,4] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#47
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 1, 5, [2,1] );
SetEntrySCTable( T, 2, 5, [1,2] );
SetEntrySCTable( T, 3, 5, [1,2,1,3] );
SetEntrySCTable( T, 4, 5, [1,4] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#48
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 1, 5, [2,1] );
SetEntrySCTable( T, 2, 5, [1,2] );
SetEntrySCTable( T, 3, 5, [1,2,1,3] );
SetEntrySCTable( T, 4, 5, [2,4] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#49
b:=3; # b <> 0
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 1, 5, [2,1] );
SetEntrySCTable( T, 2, 5, [1,2] );
SetEntrySCTable( T, 3, 5, [1,2,1,3] );
SetEntrySCTable( T, 4, 5, [b,4] );
Add( dim5, T );

T:= ZeroTab( 5 );
SetEntrySCTable1( T, 2, 3, [1,1] );
SetEntrySCTable1( T, 1, 5, [2,1] );
SetEntrySCTable1( T, 2, 5, [1,2] );
SetEntrySCTable1( T, 3, 5, [1,2,1,3] );
SetEntrySCTable1( T, 4, 5, [a1,4] );
Add( stringtabs5, T );

#50
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 1, 5, [2,1] );
SetEntrySCTable( T, 2, 5, [1,2,1,3] );
SetEntrySCTable( T, 3, 5, [1,3] );
SetEntrySCTable( T, 4, 5, [1,1,2,4] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#51
p:=1; 
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 1, 5, [2*p,1] );
SetEntrySCTable( T, 2, 5, [p,2,1,3] );
SetEntrySCTable( T, 3, 5, [-1,2,p,3] );
SetEntrySCTable( T, 4, 5, [2*p,4] );
Add( dim5, T );

T:=ZeroTab( 5 );
SetEntrySCTable1( T, 2, 3, [1,1] );
SetEntrySCTable1( T, 1, 5, [2*a1,1] );
SetEntrySCTable1( T, 2, 5, [a1,2,1,3] );
SetEntrySCTable1( T, 3, 5, [-1,2,a1,3] );
SetEntrySCTable1( T, 4, 5, [2*a1,4] );
Add( stringtabs5, T );

#52
b:=1; p:=2; # b <> 0
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 1, 5, [2*p,1] );
SetEntrySCTable( T, 2, 5, [p,2,1,3] );
SetEntrySCTable( T, 3, 5, [-1,2,p,3] );
SetEntrySCTable( T, 4, 5, [b,4] );
Add( dim5, T );

T:=ZeroTab( 5 );
SetEntrySCTable1( T, 2, 3, [1,1] );
SetEntrySCTable1( T, 1, 5, [2*a2,1] );
SetEntrySCTable1( T, 2, 5, [a2,2,1,3] );
SetEntrySCTable1( T, 3, 5, [-1,2,a2,3] );
SetEntrySCTable1( T, 4, 5, [a1,4] );
Add( stringtabs5, T );

#53
b:=1;
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 2, 5, [1,3] );
SetEntrySCTable( T, 3, 5, [-1,2] );
SetEntrySCTable( T, 4, 5, [b,4] );
Add( dim5, T );

T:=ZeroTab( 5 );
SetEntrySCTable1( T, 2, 3, [1,1] );
SetEntrySCTable1( T, 2, 5, [1,3] );
SetEntrySCTable1( T, 3, 5, [-1,2] );
SetEntrySCTable1( T, 4, 5, [a1,4] );
Add( stringtabs5, T );

#54
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 3, 4, [1,1] );
SetEntrySCTable( T, 2, 5, [1,1] );
SetEntrySCTable( T, 3, 5, [1,4] );
SetEntrySCTable( T, 4, 5, [-1,3] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#55
p:=1; 
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 3, 4, [1,1] );
SetEntrySCTable( T, 1, 5, [2*p,1] );
SetEntrySCTable( T, 2, 5, [1,1,2*p,2] );
SetEntrySCTable( T, 3, 5, [p,3,1,4] );
SetEntrySCTable( T, 4, 5, [-1,3,p,4] );
Add( dim5, T );

T:=ZeroTab( 5 );
SetEntrySCTable1( T, 3, 4, [1,1] );
SetEntrySCTable1( T, 1, 5, [2*a1,1] );
SetEntrySCTable1( T, 2, 5, [1,1,2*a1,2] );
SetEntrySCTable1( T, 3, 5, [a1,3,1,4] );
SetEntrySCTable1( T, 4, 5, [-1,3,a1,4] );
Add( stringtabs5, T );

#56
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 3, 5, [1,3,1,4] );
SetEntrySCTable( T, 4, 5, [1,1,1,4] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#57
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 2, 5, [-1,2] );
SetEntrySCTable( T, 3, 5, [1,3,1,4] );
SetEntrySCTable( T, 4, 5, [1,4] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#58
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 3, 5, [1,3,1,4] );
SetEntrySCTable( T, 4, 5, [1,4] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#59
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 1, 5, [2,1] );
SetEntrySCTable( T, 2, 5, [1,2] );
SetEntrySCTable( T, 3, 5, [1,3,1,4] );
SetEntrySCTable( T, 4, 5, [1,4] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#60
a:=3;
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 1, 5, [a,1] );
SetEntrySCTable( T, 2, 5, [a-1,2] );
SetEntrySCTable( T, 3, 5, [1,3,1,4] );
SetEntrySCTable( T, 4, 5, [1,4] );
Add( dim5, T ); 

T:=ZeroTab( 5 );
SetEntrySCTable1( T, 2, 3, [1,1] );
SetEntrySCTable1( T, 1, 5, [a1,1] );
SetEntrySCTable1( T, 2, 5, [a1-1,2] );
SetEntrySCTable1( T, 3, 5, [1,3,1,4] );
SetEntrySCTable1( T, 4, 5, [1,4] );
Add( stringtabs5, T );

#61
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 4, [1,1] );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 2, 5, [1,2] );
SetEntrySCTable( T, 4, 5, [1,3] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#62
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 4, [1,1] );
SetEntrySCTable( T, 3, 4, [1,2] );
SetEntrySCTable( T, 2, 5, [-1,2] );
SetEntrySCTable( T, 3, 5, [-2,3] );
SetEntrySCTable( T, 4, 5, [1,4] );
Add( dim5, T ); Add( stringtabs5, [] );

#63
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 4, [1,1] );
SetEntrySCTable( T, 3, 4, [1,2] );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 3, 5, [-1,3] );
SetEntrySCTable( T, 4, 5, [1,4] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#64
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 4, [1,1] );
SetEntrySCTable( T, 3, 4, [1,2] );
SetEntrySCTable( T, 1, 5, [2,1] );
SetEntrySCTable( T, 2, 5, [1,2] );
SetEntrySCTable( T, 4, 5, [1,4] );
Add( dim5, T ); Add( stringtabs5, [] );

#65
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 4, [1,1] );
SetEntrySCTable( T, 3, 4, [1,2] );
SetEntrySCTable( T, 1, 5, [3,1] );
SetEntrySCTable( T, 2, 5, [2,2] );
SetEntrySCTable( T, 3, 5, [1,3] );
SetEntrySCTable( T, 4, 5, [1,4] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#66
a:=3; # no conditions
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 4, [1,1] );
SetEntrySCTable( T, 3, 4, [1,2] );
SetEntrySCTable( T, 1, 5, [a+1,1] );
SetEntrySCTable( T, 2, 5, [a,2] );
SetEntrySCTable( T, 3, 5, [a-1,3] );
SetEntrySCTable( T, 4, 5, [1,4] );
Add( dim5, T );

T:=ZeroTab( 5 );
SetEntrySCTable1( T, 2, 4, [1,1] );
SetEntrySCTable1( T, 3, 4, [1,2] );
SetEntrySCTable1( T, 1, 5, [a1+1,1] );
SetEntrySCTable1( T, 2, 5, [a1,2] );
SetEntrySCTable1( T, 3, 5, [a1-1,3] );
SetEntrySCTable1( T, 4, 5, [1,4] );
Add( stringtabs5, T );

#67
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 4, [1,1] );
SetEntrySCTable( T, 3, 4, [1,2] );
SetEntrySCTable( T, 1, 5, [3,1] );
SetEntrySCTable( T, 2, 5, [2,2] );
SetEntrySCTable( T, 3, 5, [1,3] );
SetEntrySCTable( T, 4, 5, [1,3,1,4] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#68
a:=1; # no conditions
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 3, 4, [1,1] );
SetEntrySCTable( T, 2, 4, [1,3] );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 2, 5, [a,1,1,2] );
SetEntrySCTable( T, 3, 5, [1,3] );
Add( dim5, T ); 

T:=ZeroTab( 5 );
SetEntrySCTable1( T, 3, 4, [1,1] );
SetEntrySCTable1( T, 2, 4, [1,3] );
SetEntrySCTable1( T, 1, 5, [1,1] );
SetEntrySCTable1( T, 2, 5, [a1,1,1,2] );
SetEntrySCTable1( T, 3, 5, [1,3] );
Add( stringtabs5, T );

#69
#? this algebra is decomposable
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 4, [1,1] );
SetEntrySCTable( T, 3, 4, [1,3] );
SetEntrySCTable( T, 2, 5, [1,2] );
Add( dim5, T ); Add( stringtabs5, [] );

#70
a:=2; b:=3; # a^2 + b^2 <> 0
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 4, [1,1] );
SetEntrySCTable( T, 3, 4, [b,3] );
SetEntrySCTable( T, 2, 5, [1,2] );
SetEntrySCTable( T, 3, 5, [a,3] );
Add( dim5, T );

T:= ZeroTab( 5 );
SetEntrySCTable1( T, 1, 4, [1,1] );
SetEntrySCTable1( T, 3, 4, [a2,3] );
SetEntrySCTable1( T, 2, 5, [1,2] );
SetEntrySCTable1( T, 3, 5, [a1,3] );
Add( stringtabs5, T );

#71
a:=2; 
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 4, [a,1] );
SetEntrySCTable( T, 2, 4, [1,2] );
SetEntrySCTable( T, 3, 4, [1,3] );
SetEntrySCTable( T, 1, 5, [1,1] );
SetEntrySCTable( T, 3, 5, [1,2] );
Add( dim5, T );

T:=ZeroTab(5);
SetEntrySCTable1( T, 1, 4, [a1,1] );
SetEntrySCTable1( T, 2, 4, [1,2] );
SetEntrySCTable1( T, 3, 4, [1,3] );
SetEntrySCTable1( T, 1, 5, [1,1] );
SetEntrySCTable1( T, 3, 5, [1,2] );
Add( stringtabs5, T );

#72
a:=2; b:=3; 
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 4, [b,1] );
SetEntrySCTable( T, 2, 4, [1,2] );
SetEntrySCTable( T, 3, 4, [1,3] );
SetEntrySCTable( T, 1, 5, [a,1] );
SetEntrySCTable( T, 2, 5, [-1,3] );
SetEntrySCTable( T, 3, 5, [1,2] );
Add( dim5, T );

T:=ZeroTab(5);
SetEntrySCTable1( T, 1, 4, [a2,1] );
SetEntrySCTable1( T, 2, 4, [1,2] );
SetEntrySCTable1( T, 3, 4, [1,3] );
SetEntrySCTable1( T, 1, 5, [a1,1] );
SetEntrySCTable1( T, 2, 5, [-1,3] );
SetEntrySCTable1( T, 3, 5, [1,2] );
Add( stringtabs5, T );

#73
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 1, 4, [1,1] );
SetEntrySCTable( T, 2, 4, [1,2] );
SetEntrySCTable( T, 2, 5, [-1,2] );
SetEntrySCTable( T, 3, 5, [1,3] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#74
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 2, 3, [1,1] );
SetEntrySCTable( T, 1, 4, [2,1] );
SetEntrySCTable( T, 2, 4, [1,2] );
SetEntrySCTable( T, 3, 4, [1,3] );
SetEntrySCTable( T, 2, 5, [-1,3] );
SetEntrySCTable( T, 3, 5, [1,2] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#75
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 4, [1,1] );
SetEntrySCTable( T, 2, 5, [1,2] );
SetEntrySCTable( T, 4, 5, [1,3] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#76
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 4, [1,1] );
SetEntrySCTable( T, 2, 5, [1,1] );
SetEntrySCTable( T, 4, 5, [1,3] );
SetEntrySCTable( T, 2, 4, [1,2] );
SetEntrySCTable( T, 1, 5, [-1,2] );
Add( dim5, T ); Add( stringtabs5, [ ] );

#77
T:=EmptySCTable( 5, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [2,1] );
SetEntrySCTable( T, 1, 3, [-1,2] );
SetEntrySCTable( T, 2, 3, [2,3] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 2, 4, [1,4] );
SetEntrySCTable( T, 2, 5, [-1,5] );
SetEntrySCTable( T, 3, 5, [1,4] ); 
Add( dim5, T ); Add( stringtabs5, [ ] );

fi;

# 6-dimensional nilpotent Lie algebras.

if dimension = 6 then


dim6:=[]; stringtabs6:=[];

#1
T:=EmptySCTable( 6, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 5, [1,6] );
Add( dim6, T ); Add(stringtabs6,[]);

#2
T:=EmptySCTable( 6, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
Add( dim6, T ); Add(stringtabs6,[]);

#3
T:=EmptySCTable( 6, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,6] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 2, 3, [1,5] );
Add( dim6, T ); Add(stringtabs6,[]);

#3bis
T:=EmptySCTable( 6, 0, "antisymmetric" );
SetEntrySCTable(T,1,2,[1,5]);
SetEntrySCTable(T,1,3,[1,6]);
SetEntrySCTable(T,2,4,[1,6]);
Add( dim6, T ); Add(stringtabs6,[]);

#4
a:=2;
T:=EmptySCTable( 6, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 2, 3, [a,6] );
SetEntrySCTable( T, 2, 4, [1,5] );
Add( dim6, T );

T:= ZeroTab( 6 );
SetEntrySCTable1( T, 1, 3, [1,5] );
SetEntrySCTable1( T, 1, 4, [1,6] );
SetEntrySCTable1( T, 2, 3, [a1,6] );
SetEntrySCTable1( T, 2, 4, [1,5] );
Add( stringtabs6, T );

#5
T:=EmptySCTable( 6, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,6] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 2, 3, [1,5] );
Add( dim6, T ); Add( stringtabs6, [] );

#6
T:=EmptySCTable( 6, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 2, 3, [1,6] );
Add( dim6, T ); Add( stringtabs6, [] );

#7
T:=EmptySCTable( 6, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3,1,5] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 2, 5, [1,6] );
Add( dim6, T ); Add( stringtabs6, [] );

#8
T:=EmptySCTable( 6, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 2, 3, [1,6] );
Add( dim6, T ); Add( stringtabs6, [] );

#9
a:=2; # a<>0
T:=EmptySCTable( 6, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 2, 3, [a,6] );
SetEntrySCTable( T, 2, 4, [1,5] ); 
Add( dim6, T );

T:=ZeroTab( 6 );
SetEntrySCTable1( T, 1, 2, [1,3] );
SetEntrySCTable1( T, 1, 3, [1,5] );
SetEntrySCTable1( T, 1, 4, [1,6] );
SetEntrySCTable1( T, 2, 3, [a1,6] );
SetEntrySCTable1( T, 2, 4, [1,5] ); 
Add( stringtabs6, T );

#10
T:=EmptySCTable( 6, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 2, 3, [1,6] );
Add( dim6, T ); Add( stringtabs6, [] );

#11
T:=EmptySCTable( 6, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 2, 5, [1,6] );
Add( dim6, T ); Add( stringtabs6, [] );

#12
T:=EmptySCTable( 6, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,5] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 2, 5, [1,6] );
Add( dim6, T ); Add( stringtabs6, [] );

#13
a:=2;
T:=EmptySCTable( 6, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 2, 3, [1,5] );
SetEntrySCTable( T, 2, 5, [a,6] ); 
Add( dim6, T );

T:=ZeroTab( 6 );
SetEntrySCTable1( T, 1, 3, [1,4] );
SetEntrySCTable1( T, 1, 4, [1,6] );
SetEntrySCTable1( T, 2, 3, [1,5] );
SetEntrySCTable1( T, 2, 5, [a1,6] ); 
Add( stringtabs6, T );

#14
T:=EmptySCTable( 6, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3,1,5] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 2, 5, [1,6] ); 
Add( dim6, T ); Add( stringtabs6, [] );

#15
T:=EmptySCTable( 6, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 2, 3, [1,5] );
SetEntrySCTable( T, 2, 4, [1,6] );
Add( dim6, T ); Add( stringtabs6, [] );

#16
T:=EmptySCTable( 6, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 2, 5, [1,6] ); 
Add( dim6, T ); Add( stringtabs6, [] );

#17
a:=2;
T:=EmptySCTable( 6, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 2, 3, [1,5] );
SetEntrySCTable( T, 2, 5, [a,6] ); 
Add( dim6, T );

T:=ZeroTab( 6 );
SetEntrySCTable1( T, 1, 2, [1,3] );
SetEntrySCTable1( T, 1, 3, [1,4] );
SetEntrySCTable1( T, 1, 4, [1,6] );
SetEntrySCTable1( T, 2, 3, [1,5] );
SetEntrySCTable1( T, 2, 5, [a1,6] ); 
Add( stringtabs6, T );

#18
T:=EmptySCTable( 6, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 2, 3, [1,6] ); 
Add( dim6, T ); Add( stringtabs6, [] );

#19
T:=EmptySCTable( 6, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 2, 3, [1,5] );
SetEntrySCTable( T, 2, 4, [1,6] );
Add( dim6, T ); Add( stringtabs6, [] );

#20
T:=EmptySCTable( 6, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 2, 3, [1,4] );
SetEntrySCTable( T, 2, 4, [1,5] );
SetEntrySCTable( T, 3, 4, [1,6] ); 
Add( dim6, T ); Add( stringtabs6, [] );

#21
T:=EmptySCTable( 6, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 2, 3, [1,4] );
SetEntrySCTable( T, 2, 4, [1,5] );
SetEntrySCTable( T, 3, 4, [1,6] );
Add( dim6, T ); Add( stringtabs6, [] );

fi;

# Nilpotent Lie algebras of dimension 7.
# C. Seeley, 7-dimensional nilpotent Lie algebras, Trans Amer Math Soc, 335, 
# 479--496 (1993). (Corrected version, C. Seeley, Preprint).

if dimension = 7 then


dim7:= []; stringtabs7:=[];

#1
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,5] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 2, 4, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#2
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,5] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 3, 4, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#3
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,5] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 3, 4, [1,5] );
SetEntrySCTable( T, 2, 4, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#4
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,5] );
SetEntrySCTable( T, 2, 4, [1,7] );
SetEntrySCTable( T, 3, 4, [1,5] );
SetEntrySCTable( T, 1, 3, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#5
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,7] );
SetEntrySCTable( T, 2, 4, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#6
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,7] );
SetEntrySCTable( T, 2, 3, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#7
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,7] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 2, 4, [1,5] );
Add( dim7, T ); Add(stringtabs7,[]);

#8
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 2, 5, [1,7] );
SetEntrySCTable( T, 3, 4, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#9
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 2, 5, [1,7] );
SetEntrySCTable( T, 3, 4, [1,6,1,7] );
SetEntrySCTable( T, 3, 5, [1,6,1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#10
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,6] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 4, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#11
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,6] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 4, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#12
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,6] );
SetEntrySCTable( T, 2, 5, [1,7] );
SetEntrySCTable( T, 2, 4, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#13
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,6] );
SetEntrySCTable( T, 1, 4, [1,7] );
SetEntrySCTable( T, 2, 4, [1,6] );
SetEntrySCTable( T, 2, 5, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#14
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,6] );
SetEntrySCTable( T, 2, 5, [1,7] );
SetEntrySCTable( T, 4, 5, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#15
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,6] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 4, 5, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#16
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,6] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 4, [1,7] );
SetEntrySCTable( T, 4, 5, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#17
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,6] );
SetEntrySCTable( T, 2, 4, [1,6] );
SetEntrySCTable( T, 4, 5, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#18
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,6] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 3, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#19
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,6] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 3, [1,7] );
SetEntrySCTable( T, 2, 4, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#20
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,6] );
SetEntrySCTable( T, 2, 3, [1,7] );
SetEntrySCTable( T, 4, 5, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#21
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,6] );
SetEntrySCTable( T, 1, 4, [1,7] );
SetEntrySCTable( T, 2, 3, [1,7] );
SetEntrySCTable( T, 4, 5, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#22
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,4] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 1, 5, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#23
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,4] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 3, 5, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#24
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,4] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,7] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 3, 5, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#25
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,4] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 5, [1,6] );
SetEntrySCTable( T, 3, 4, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#26
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,4] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,7] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 5, [1,6] );
SetEntrySCTable( T, 3, 4, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#27
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,4] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 2, 4, [1,6] );
SetEntrySCTable( T, 3, 5, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#28
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,4] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,7] );
SetEntrySCTable( T, 2, 4, [1,6] );
SetEntrySCTable( T, 3, 5, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#29
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,4] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,7] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 2, 4, [1,6] );
SetEntrySCTable( T, 3, 5, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#30
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,4] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 2, 5, [1,6] );
SetEntrySCTable( T, 3, 4, [1,6] );
SetEntrySCTable( T, 3, 5, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#31
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,4] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 2, 5, [1,6] );
SetEntrySCTable( T, 3, 4, [1,6] );
SetEntrySCTable( T, 3, 5, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#32
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,4] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,7] );
SetEntrySCTable( T, 2, 5, [1,6] );
SetEntrySCTable( T, 3, 4, [1,6] );
SetEntrySCTable( T, 3, 5, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#33
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,4] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 3, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#34
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,4] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 2, 4, [1,7] );
SetEntrySCTable( T, 2, 3, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#35
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,4] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 4, [1,7] );
SetEntrySCTable( T, 2, 3, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#36
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,4] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 4, [1,7] );
SetEntrySCTable( T, 2, 3, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#37
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,4] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 2, 5, [1,7] );
SetEntrySCTable( T, 3, 4, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#38
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,4] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 2, 5, [1,7] );
SetEntrySCTable( T, 3, 4, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#39
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,4] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 2, 5, [1,7] );
SetEntrySCTable( T, 3, 4, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#40
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 1, 5, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#41
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,7] );
SetEntrySCTable( T, 2, 5, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#42
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 5, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#43
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 2, 5, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#44
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,7] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 2, 5, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#45
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 3, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#46
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,7] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 2, 3, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#47
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,7] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 2, 5, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#48
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 2, 5, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#49
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,6,1,7] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 2, 5, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#50
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,7] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 2, 5, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#51
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 2, 3, [1,5] );
SetEntrySCTable( T, 2, 5, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#52
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,7] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 2, 3, [1,5] );
SetEntrySCTable( T, 2, 4, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#53
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 2, 4, [1,5,1,7] );
SetEntrySCTable( T, 3, 4, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#54
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,7] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 2, 4, [1,5] );
SetEntrySCTable( T, 3, 4, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#55
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 2, 3, [1,7] );
SetEntrySCTable( T, 2, 4, [1,5] );
SetEntrySCTable( T, 3, 4, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#56
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 2, 3, [1,7] );
SetEntrySCTable( T, 2, 4, [1,5,1,7] );
SetEntrySCTable( T, 3, 4, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#57
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 2, 3, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#58
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 2, 3, [1,7] );
SetEntrySCTable( T, 2, 5, [1,6] );
SetEntrySCTable( T, 3, 4, [-1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#59
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 2, 5, [1,7] );
SetEntrySCTable( T, 3, 4, [-1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#60
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 2, 5, [1,7] );
SetEntrySCTable( T, 3, 4, [-1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#61
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 2, 3, [1,5,1,7] );
SetEntrySCTable( T, 2, 4, [1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#62
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 2, 3, [1,5,1,7] );
SetEntrySCTable( T, 2, 5, [1,6] );
SetEntrySCTable( T, 3, 4, [-1,6] );
Add( dim7, T ); Add(stringtabs7,[]);

#63
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 2, 3, [1,5] );
SetEntrySCTable( T, 2, 4, [1,6] );
SetEntrySCTable( T, 2, 5, [1,7] );
SetEntrySCTable( T, 3, 4, [-1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#64
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,7] );
SetEntrySCTable( T, 3, 4, [1,7] );
SetEntrySCTable( T, 5, 6, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#65
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,7] );
SetEntrySCTable( T, 2, 4, [1,7] );
SetEntrySCTable( T, 5, 6, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#66
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,4] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 5, [1,7] );
SetEntrySCTable( T, 3, 4, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#67
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,4] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,7] );
SetEntrySCTable( T, 2, 6, [1,7] );
SetEntrySCTable( T, 3, 5, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

if Characteristic( field ) <> 2 then 
#68
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,4] );
SetEntrySCTable( T, 1, 3, [-1,6] );
SetEntrySCTable( T, 1, 5, [-1,7] );
SetEntrySCTable( T, 2, 3, [1,5] );
SetEntrySCTable( T, 2, 6, [1/2,7] );
SetEntrySCTable( T, 3, 4, [1/2,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#69
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,4] );
SetEntrySCTable( T, 1, 3, [-1,6] );
SetEntrySCTable( T, 1, 5, [-1,7] );
SetEntrySCTable( T, 2, 3, [1,5] );
SetEntrySCTable( T, 2, 6, [1/2,7] );
SetEntrySCTable( T, 3, 4, [1/2,7] );
SetEntrySCTable( T, 3, 6, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

fi;

#70
a:=-2;
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,4] );
SetEntrySCTable( T, 1, 3, [-1,6] );
SetEntrySCTable( T, 1, 5, [-1,7] );
SetEntrySCTable( T, 2, 3, [1,5] );
SetEntrySCTable( T, 2, 6, [a,7] );
SetEntrySCTable( T, 3, 4, [1-a,7] );
Add( dim7, T ); 

T:= ZeroTab( 7 );
SetEntrySCTable1( T, 1, 2, [1,4] );
SetEntrySCTable1( T, 1, 3, [-1,6] );
SetEntrySCTable1( T, 1, 5, [-1,7] );
SetEntrySCTable1( T, 2, 3, [1,5] );
SetEntrySCTable1( T, 2, 6, [a1,7] );
SetEntrySCTable1( T, 3, 4, [1-a1,7] );
Add( stringtabs7, T );

#71
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,7] );
SetEntrySCTable( T, 5, 6, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#72
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,7] );
SetEntrySCTable( T, 2, 3, [1,7] );
SetEntrySCTable( T, 5, 6, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#73
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,5] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 3, 4, [1,6] );
SetEntrySCTable( T, 3, 6, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#74
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,5] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 4, [1,7] );
SetEntrySCTable( T, 3, 4, [1,6] );
SetEntrySCTable( T, 3, 6, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#75
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,5] );
SetEntrySCTable( T, 1, 3, [1,6] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 3, 4, [1,5] );
SetEntrySCTable( T, 4, 6, [-1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#76
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,5] );
SetEntrySCTable( T, 1, 3, [1,6] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 3, [1,7] );
SetEntrySCTable( T, 3, 4, [1,5] );
SetEntrySCTable( T, 4, 6, [-1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#77
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 4, [1,5] );
SetEntrySCTable( T, 2, 6, [1,7] );
SetEntrySCTable( T, 3, 4, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#78
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 4, [1,5] );
SetEntrySCTable( T, 4, 6, [1,7] );
SetEntrySCTable( T, 3, 4, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#79
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 3, [1,7] );
SetEntrySCTable( T, 2, 4, [1,5] );
SetEntrySCTable( T, 4, 6, [1,7] );
SetEntrySCTable( T, 3, 4, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#80
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 6, [1,7] );
SetEntrySCTable( T, 3, 4, [-1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#81
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 4, 6, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#82
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 3, [1,7] );
SetEntrySCTable( T, 4, 6, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#83
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 4, [1,6] );
SetEntrySCTable( T, 2, 6, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#84
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 4, [1,6] );
SetEntrySCTable( T, 2, 6, [1,7] );
SetEntrySCTable( T, 3, 4, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#85
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 4, [1,6] );
SetEntrySCTable( T, 4, 6, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#86
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 3, [1,7] );
SetEntrySCTable( T, 2, 4, [1,6] );
SetEntrySCTable( T, 4, 6, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

if Characteristic( field ) <> 2 then

#87
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 4, [1,5] );
SetEntrySCTable( T, 2, 6, [1/2,7] );
SetEntrySCTable( T, 3, 4, [1/2,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#88
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 3, [1,7] );
SetEntrySCTable( T, 2, 4, [1,5] );
SetEntrySCTable( T, 2, 6, [1/2,7] );
SetEntrySCTable( T, 3, 4, [1/2,7] );
Add( dim7, T ); Add(stringtabs7,[]);

fi;
#89
a:=2;
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 4, [1,5] );
SetEntrySCTable( T, 2, 6, [a,7] );
SetEntrySCTable( T, 3, 4, [1-a,7] );
Add( dim7, T );

T:= ZeroTab( 7 );
SetEntrySCTable1( T, 1, 2, [1,3] );
SetEntrySCTable1( T, 1, 3, [1,5] );
SetEntrySCTable1( T, 1, 4, [1,6] );
SetEntrySCTable1( T, 1, 5, [1,7] );
SetEntrySCTable1( T, 2, 4, [1,5] );
SetEntrySCTable1( T, 2, 6, [a1,7] );
SetEntrySCTable1( T, 3, 4, [1-a1,7] );
Add( stringtabs7, T );

#90
a:=2;
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 3, [a,7] );
SetEntrySCTable( T, 2, 4, [1,5] );
SetEntrySCTable( T, 3, 4, [1,7] );
SetEntrySCTable( T, 4, 6, [1,7] );
Add( dim7, T );

T:= ZeroTab( 7 );
SetEntrySCTable1( T, 1, 2, [1,3] );
SetEntrySCTable1( T, 1, 3, [1,5] );
SetEntrySCTable1( T, 1, 4, [1,6] );
SetEntrySCTable1( T, 1, 5, [1,7] );
SetEntrySCTable1( T, 2, 3, [a1,7] );
SetEntrySCTable1( T, 2, 4, [1,5] );
SetEntrySCTable1( T, 3, 4, [1,7] );
SetEntrySCTable1( T, 4, 6, [1,7] );
Add( stringtabs7, T );

#91
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 2, 5, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#92
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 2, 6, [1,7] );
SetEntrySCTable( T, 3, 4, [-1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#93
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3,1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 2, 6, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#94
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3,1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 2, 5, [1,7] );
SetEntrySCTable( T, 3, 4, [-1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#95
a:=2;
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 2, 4, [1,6] );
SetEntrySCTable( T, 2, 5, [1,7] );
SetEntrySCTable( T, 2, 6, [a,7] );
SetEntrySCTable( T, 3, 4, [-1,7] );
Add( dim7, T ); 

T:= ZeroTab( 7 );
SetEntrySCTable1( T, 1, 2, [1,4] );
SetEntrySCTable1( T, 1, 4, [1,5] );
SetEntrySCTable1( T, 1, 5, [1,7] );
SetEntrySCTable1( T, 1, 6, [1,7] );
SetEntrySCTable1( T, 2, 3, [1,6] );
SetEntrySCTable1( T, 2, 4, [1,6] );
SetEntrySCTable1( T, 2, 5, [1,7] );
SetEntrySCTable1( T, 2, 6, [a1,7] );
SetEntrySCTable1( T, 3, 4, [-1,7] );
Add( stringtabs7, T ); 

#96
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 6, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#97
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 3, [1,7] );
SetEntrySCTable( T, 2, 6, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#98
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 5, [1,7] );
SetEntrySCTable( T, 3, 4, [-1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#99
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 3, [1,5] );
SetEntrySCTable( T, 2, 4, [1,7] );
SetEntrySCTable( T, 2, 6, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#100
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 3, [1,5] );
SetEntrySCTable( T, 2, 5, [1,7] );
SetEntrySCTable( T, 3, 4, [-1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#101
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 2, 6, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#102
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 2, 4, [1,7] );
SetEntrySCTable( T, 2, 5, [1,7] );
SetEntrySCTable( T, 3, 4, [-1,7] );
Add( dim7, T ); Add(stringtabs7,[]);


#104
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 2, 4, [1,7] );
SetEntrySCTable( T, 2, 5, [1,7] );
SetEntrySCTable( T, 2, 6, [1,7] );
SetEntrySCTable( T, 3, 4, [-1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#105
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 5, [1,6] );
SetEntrySCTable( T, 3, 5, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#106
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 5, [1,6,1,7] );
SetEntrySCTable( T, 3, 5, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#107
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 2, 5, [1,6] );
SetEntrySCTable( T, 2, 6, [1,7] );
SetEntrySCTable( T, 3, 4, [-1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#108
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 5, [1,6] );
SetEntrySCTable( T, 2, 6, [1,7] );
SetEntrySCTable( T, 3, 4, [-1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#109
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 2, 4, [1,7] );
SetEntrySCTable( T, 2, 5, [1,6] );
SetEntrySCTable( T, 3, 5, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#110
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 2, 5, [1,6] );
SetEntrySCTable( T, 2, 6, [1,7] );
SetEntrySCTable( T, 3, 4, [-1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#111
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,6] );
SetEntrySCTable( T, 1, 5, [1,7] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 2, 5, [1,6] );
SetEntrySCTable( T, 2, 6, [1,7] );
SetEntrySCTable( T, 3, 4, [-1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#112
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 3, [1,5] );
SetEntrySCTable( T, 2, 4, [1,6] );
SetEntrySCTable( T, 3, 4, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#113
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 3, [1,5] );
SetEntrySCTable( T, 2, 4, [1,6] );
SetEntrySCTable( T, 2, 5, [1,7] );
SetEntrySCTable( T, 3, 4, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#114
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,7] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 3, [1,5] );
SetEntrySCTable( T, 2, 4, [1,6] );
SetEntrySCTable( T, 2, 5, [1,7] );
SetEntrySCTable( T, 3, 4, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#115
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,7] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 3, [1,5] );
SetEntrySCTable( T, 2, 4, [1,6] );
SetEntrySCTable( T, 3, 4, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#116
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 3, [1,5] );
SetEntrySCTable( T, 2, 4, [1,6] );
SetEntrySCTable( T, 2, 6, [1,7] );
SetEntrySCTable( T, 3, 4, [1,7] );
SetEntrySCTable( T, 3, 5, [-1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#117
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,7] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 3, [1,5] );
SetEntrySCTable( T, 2, 4, [1,6] );
SetEntrySCTable( T, 2, 6, [1,7] );
SetEntrySCTable( T, 3, 4, [1,7] );
SetEntrySCTable( T, 3, 5, [-1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#118
a:=2;
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,7] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 3, [1,5] );
SetEntrySCTable( T, 2, 4, [1,6] );
SetEntrySCTable( T, 2, 5, [a,7] );
SetEntrySCTable( T, 2, 6, [1,7] );
SetEntrySCTable( T, 3, 4, [1,7] );
SetEntrySCTable( T, 3, 5, [-1,7] );
Add( dim7, T ); 

T:= ZeroTab( 7 );
SetEntrySCTable1( T, 1, 2, [1,3] );
SetEntrySCTable1( T, 1, 3, [1,4] );
SetEntrySCTable1( T, 1, 4, [1,7] );
SetEntrySCTable1( T, 1, 5, [1,6] );
SetEntrySCTable1( T, 1, 6, [1,7] );
SetEntrySCTable1( T, 2, 3, [1,5] );
SetEntrySCTable1( T, 2, 4, [1,6] );
SetEntrySCTable1( T, 2, 5, [a1,7] );
SetEntrySCTable1( T, 2, 6, [1,7] );
SetEntrySCTable1( T, 3, 4, [1,7] );
SetEntrySCTable1( T, 3, 5, [-1,7] );
Add( stringtabs7, T ); 

#119
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 4, [1,5] );
SetEntrySCTable( T, 3, 4, [1,6] );
SetEntrySCTable( T, 4, 5, [-1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#120
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 4, [1,5,1,7] );
SetEntrySCTable( T, 3, 4, [1,6] );
SetEntrySCTable( T, 4, 5, [-1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#121
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 3, [1,7] );
SetEntrySCTable( T, 2, 4, [1,5] );
SetEntrySCTable( T, 3, 4, [1,6] );
SetEntrySCTable( T, 4, 5, [-1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#122
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 1, 6, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#123
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 3, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#124
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 5, [1,7] );
SetEntrySCTable( T, 3, 4, [-1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#125
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 2, 4, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#126
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 3, [1,6,1,7] );
SetEntrySCTable( T, 2, 4, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#127
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 3, [1,6] );
SetEntrySCTable( T, 2, 4, [1,7] );
SetEntrySCTable( T, 2, 5, [1,7] );
SetEntrySCTable( T, 3, 4, [-1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#128
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 3, [1,5] );
SetEntrySCTable( T, 2, 4, [1,6] );
SetEntrySCTable( T, 2, 5, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#129
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 3, [1,5,1,7] );
SetEntrySCTable( T, 2, 4, [1,6] );
SetEntrySCTable( T, 2, 5, [1,7] );
Add( dim7, T ); Add(stringtabs7,[]);

#130
a:=2;
T:=EmptySCTable( 7, 0, "antisymmetric" );
SetEntrySCTable( T, 1, 2, [1,3] );
SetEntrySCTable( T, 1, 3, [1,4] );
SetEntrySCTable( T, 1, 4, [1,5] );
SetEntrySCTable( T, 1, 5, [1,6] );
SetEntrySCTable( T, 1, 6, [1,7] );
SetEntrySCTable( T, 2, 3, [1,5] );
SetEntrySCTable( T, 2, 4, [1,6] );
SetEntrySCTable( T, 2, 5, [a,7] );
SetEntrySCTable( T, 3, 4, [1-a,7] );
Add( dim7, T ); 

T:= ZeroTab( 7 );
SetEntrySCTable1( T, 1, 2, [1,3] );
SetEntrySCTable1( T, 1, 3, [1,4] );
SetEntrySCTable1( T, 1, 4, [1,5] );
SetEntrySCTable1( T, 1, 5, [1,6] );
SetEntrySCTable1( T, 1, 6, [1,7] );
SetEntrySCTable1( T, 2, 3, [1,5] );
SetEntrySCTable1( T, 2, 4, [1,6] );
SetEntrySCTable1( T, 2, 5, [a1,7] );
SetEntrySCTable1( T, 3, 4, [1-a1,7] );
Add( stringtabs7, T );


fi;


if dimension=2 then dim:=dim2; fi;
if dimension=3 then dim:=dim3; fi;
if dimension=4 then dim:=dim4; fi;
if dimension=5 then dim:=dim5; fi;
if dimension=6 then dim:=dim6; fi;
if dimension=7 then dim:=dim7; fi;

if not 1 in field then 
    dim:=List(dim, x->ReducedSCTable(x, One(field)) );
fi;

if dimension=2 then return [ dim, stringtabs2, [] ]; fi;
if dimension=3 then return [ dim, stringtabs3, [a1] ]; fi;
if dimension=4 then return [ dim, stringtabs4, [a1,a2] ]; fi;
if dimension=5 then return [ dim, stringtabs5, [a1,a2,a3] ]; fi;
if dimension=6 then return [ dim, stringtabs6, [a1] ]; fi;
if dimension=7 then return [ dim, stringtabs7, [a1] ]; fi;

end;

