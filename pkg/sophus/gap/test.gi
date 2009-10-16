#############################################################################
##
#W  test.gi                 Sophus package                  Csaba Schneider 
##
#W  Testing the Sophus package
##
#H  $Id: test.gi,v 1.3 2004/07/02 09:20:08 gap Exp $

SophusTest := function()
	local i, L1, L2, L3, L4, L5, L6, L7, size;


	Print(  "Computing Lie algebras over GF(2)\n" );
	
	L1 := [ AbelianLieAlgebra( GF(2), 1 ) ];;	 
	L2 := [ AbelianLieAlgebra( GF(2), 2 ) ];;
 	L3 := [ AbelianLieAlgebra( GF(2), 3 ) ];;

 	Append( L3, Descendants( L2[1], 1 ));
 	L4 := [ AbelianLieAlgebra( GF(2), 4 ) ];;

 	for i in L3 do
 		Append( L4, Descendants( i, 1 ));
 	od;
 
	L5 := [ AbelianLieAlgebra( GF(2), 5 ) ];;
 	for i in L3 do
 		Append( L5, Descendants( i, 2 ));
 	od;
 
	for i in L4 do
 		Append( L5, Descendants( i, 1 ));
 	od;
	
	Print(  "Lie algs computed up to dimension 5\n" );

	L6 := [ AbelianLieAlgebra( GF(2), 6 ) ];;
 	for i in L3 do
 		Append( L6, Descendants( i, 3 ));
 	od;
 
	for i in L4 do
 		Append( L6, Descendants( i, 2 ));
 	od;
 
	for i in L5 do
 		Append( L6, Descendants( i, 1 ));
 	od;

	Print(  "Dimension 6 completed\n" );	 

	L7 := [ AbelianLieAlgebra( GF(2), 6 ) ];;
 	for i in L4 do
 		Append( L7, Descendants( i, 3 ));
 	od;
 
	for i in L5 do
 		Append( L7, Descendants( i, 2 ));
 	od;
 
	for i in L6 do
 		Append( L7, Descendants( i, 1 ));
 	od;
 	
	Print(  "Dimension 7 completed\n" );	 

	if Length( L7 ) <> 202 then 
		Print(  
		"The no. of isom types of 7-dimensional algebras over F_2 should be 202\n" );
		return false;
	fi;
	
	Print(  "Computing the autgrp of an algebra\n" );
	size := AutomorphismGroupOfNilpotentLieAlgebra( L7[100] ).size;	
	Print(  "the size of autgrp is ", size, "\n" );
	
	Print(  "Testing the isomorphism test\n" );

	if not AreIsomorphicNilpotentLieAlgebras( L7[100], L7[100] ) then
		Print(  "the same algebras should be isomorphic\n" );
		return false;
	fi;

	if AreIsomorphicNilpotentLieAlgebras( L7[100], L7[101] ) then
		Print(  "these algebras should be non-isomorphic\n" );
		return false;
	fi;

	Print(  "Now computing algebras over GF(3)\n" );

	L1 := [ AbelianLieAlgebra( GF(3), 1 ) ];;	 
	L2 := [ AbelianLieAlgebra( GF(3), 2 ) ];;
 	L3 := [ AbelianLieAlgebra( GF(3), 3 ) ];;

 	Append( L3, Descendants( L2[1], 1 ));
 	L4 := [ AbelianLieAlgebra( GF(3), 4 ) ];;

 	for i in L3 do
 		Append( L4, Descendants( i, 1 ));
 	od;
 
	L5 := [ AbelianLieAlgebra( GF(3), 5 ) ];;
 	for i in L3 do
 		Append( L5, Descendants( i, 2 ));
 	od;
 
	for i in L4 do
 		Append( L5, Descendants( i, 1 ));
 	od;
	
	Print(  "Algebras up to dim 5 computed\n" );	

	L6 := [ AbelianLieAlgebra( GF(3), 6 ) ];;
 	for i in L3 do
 		Append( L6, Descendants( i, 3 ));
 	od;
 
	for i in L4 do
 		Append( L6, Descendants( i, 2 ));
 	od;
 
	for i in L5 do
 		Append( L6, Descendants( i, 1 ));
 	od;
	
	Print(  "Dimension 6 completed\n" );	 

	
	if Length( L6 ) <> 34 then
		Print(  
		"The no. of isom types of 6-dimensional algebras over GF(3) should be 34\n" );
		return false;
	fi;	

	Print(  "Computing the autgrp of an algebra\n" );
	size := AutomorphismGroupOfNilpotentLieAlgebra( L6[30] ).size;	
	Print(  "the size of autgrp is ", size, "\n" );
	
	Print(  "Testing the isom test\n" );
	
	if not AreIsomorphicNilpotentLieAlgebras( L6[30], L6[30] ) then
		Print(  "the same algebras should be isomorphic\n" );
		return false;
	fi;

	if AreIsomorphicNilpotentLieAlgebras( L6[30], L6[31] ) then
		Print(  "these algebras should be non-isomorphic\n" );
		return false;
	fi;

	Print(  "Test passed. No problem found\n" );

	return true;
end;	 
	

