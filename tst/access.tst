gap> t:=RunTask(ZmodnZ,3);;
gap> TaskResult(t);
GF(3)
gap> t:=RunTask(ZmodnZ,33);;
gap> TaskResult(t);        
(Integers mod 33)
gap> t:=RunTask(GF,3);;
gap> TaskResult(t);
GF(3)
gap> t:=RunTask(QuaternionAlgebra,Rationals);;
gap> TaskResult(t);                          
<algebra-with-one of dimension 4 over Rationals>
gap> t:=RunTask(SymmetricGroup,3);;
gap> TaskResult(t);              
Sym( [ 1 .. 3 ] )
gap> t:=RunTask(FreeGroup,3);;
gap> TaskResult(t);           
<free group on the generators [ f1, f2, f3 ]>               
gap> t:=RunTask(LLLReducedBasis, [ ] );;
gap> TaskResult(t);                          
rec( B := [  ], basis := [  ], mue := [  ] )
gap> t:=RunTask(LLLReducedBasis, [ [ 0, 0 ], [ 0, 0 ] ], "linearcomb" );;
gap> TaskResult(t);                          
rec( B := [  ], basis := [  ], mue := [  ], 
  relations := [ [ 1, 0 ], [ 0, 1 ] ], transformation := [  ] )
