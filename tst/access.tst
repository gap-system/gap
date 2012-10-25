#############################################################################
##
#W  tasks.tst                 GAP tests                   Alexander Konovalov
##
##
#Y  Copyright (C)  2012
##
##  To be listed in testinstall.g
##
gap> START_TEST("tasks.tst");
gap> CallAsTask := function(arg)
> return TaskResult( RunTask( CallFuncList, arg[1], arg{[2..Length(arg)]} ) );
> end;;
gap> TaskResult(RunTask(Factorial, 99)) = Factorial(99);
true
gap> TaskResult(RunTask(x -> Size(x),[(1,2)]));
1
gap> CallAsTask(ZmodnZ,2);
GF(2)
gap> CallAsTask(ZmodnZ,3);
GF(3)
gap> CallAsTask(ZmodnZ,33);
(Integers mod 33)
gap> CallAsTask(ZmodnZ,70001);
GF(70001)
gap> CallAsTask( Z, 2, 17);
z
gap> z:=CallAsTask( Z, 65537, 2 );
z
gap> TaskResult( RunTask( x -> x^-1, z) );
21846+43691z
gap> CallAsTask( Z, 268435399, 2 );
z
gap> CallAsTask(GF,7);
GF(7)
gap> CallAsTask(GF,7^2);
GF(7^2)
gap> CallAsTask(GF,65537);
GF(65537)
gap> CallAsTask(GF,65537^2);
GF(65537^2)
gap> CallAsTask(Indeterminate,GF(13));
x_1
gap> CallAsTask( NF, 7, [ 1 ] );
CF(7)
gap> CallAsTask( NF, 7, [ 1,2 ] );
NF(7,[ 1, 2, 4 ])
gap> CallAsTask(SymmetricGroup,3);
Sym( [ 1 .. 3 ] )
gap> CallAsTask(FreeGroup,3);
<free group on the generators [ f1, f2, f3 ]>
gap> g:= FreeGroup( "a", "b" );;
gap> enum:= Enumerator( g );;
gap> first50:=List( [ 1 .. 50 ], x -> enum[x] );;
gap> CallAsTask( Position, enum, first50[1]);
1
gap> CallAsTask(SmallGroup,256,1);
<pc group of size 256 with 8 generators>
gap> CallAsTask(QuaternionAlgebra,Rationals);
<algebra-with-one of dimension 4 over Rationals>
gap> CallAsTask( JordanDecomposition, [[1,2,3],[4,5,6],[7,8,9]] );
[ [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ], 
  [ [ 0, 0, 0 ], [ 0, 0, 0 ], [ 0, 0, 0 ] ] ]
gap> CallAsTask(LLLReducedBasis,[]);
rec( B := [  ], basis := [  ], mue := [  ] )
gap> CallAsTask(LLLReducedBasis,[ [ 0, 0 ], [ 0, 0 ] ], "linearcomb" );
rec( B := [  ], basis := [  ], mue := [  ], 
  relations := [ [ 1, 0 ], [ 0, 1 ] ], transformation := [  ] )
gap> STOP_TEST( "tasks.tst", 1 );
#############################################################################
##
#E

