###########################################################################
##
#W    new.g               OpenMath Package                 Marco Costantini
#W                                                      Alexander Konovalov
##
#Y  Copyright (C) 1999, 2000, 2001, 2006
#Y  School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##  This file contains updates to the record OMsymRecord, according to 
##  the current OpenMath CDs (for converting from OpenMath to GAP).
##


#######################################################################
## 
## Conversion from OpenMath to GAP, to be moved into gap.g after tests
##

OMsymRecord_new := rec(

calculus1 := rec(
	partialdiff :=
      	# the code is correct, but the problem is to match variables 
      	# during OpenMath encoding/decoding - check handling of polyd1.DMP
      	function(x)
      	local ind, f, i;
      	ind := x[1];
      	f := x[2];
      	for i in ind do
        	Print( "Derivative of ", f, " by ", i, " = \c" );
        	f := Derivative( f, i );
        	Print( f, "\n" );
        	if IsZero(f) then
          		return f;
        	fi;
      	od;
      	return f;
      	end
),

complex1 := rec(
	argument := fail,
	complex_cartesian := x -> OMgapId([OMgap2ARGS(x), x[1]+E(4)*x[2]])[2],
	complex_polar := fail,
    conjugate := x -> OMgapId([OMgap1ARGS(x), x -> ComplexConjugate( x[1] )])[2], # check this!!!
    imaginary := x -> OMgapId([OMgap1ARGS(x), x -> (x[1] - ComplexConjugate( x[1] )) / 2]* -1/2 *E(4))[2], # check this!!!
    real := x -> OMgapId([OMgap1ARGS(x), x -> (x[1] + ComplexConjugate( x[1] )) / 2])[2] # check this!!!
),

linalg1 := rec(
	determinant := x -> DeterminantMat(x[1]),
    matrix_selector := x -> x[3][x[1]][x[2]],
    outerproduct := x -> TransposedMat([x[1]])*[x[2]],    
    scalarproduct := x -> x[1]*x[2],
    transpose := x -> TransposedMat(x[1]),
    vector_selector := x -> x[2][x[1]],
    vectorproduct := 
    	function( x )
		local z1, z2, z3;
		z1 := x[1][2]*x[2][3] - x[1][3]*x[2][2];
		z2 := x[1][3]*x[2][1] - x[1][1]*x[2][3];
		z3 := x[1][1]*x[2][2] - x[1][2]*x[2][1];
		return [ z1, z2, z3 ];
    	end 	
),

linalg2 := rec(
    matrix := OMgapMatrix,
	matrixrow := OMgapMatrixRow,
    vector := OMgapMatrixRow
),

linalg3 := rec(
	matrix := fail, 
	matrixcolumn := fail, 
	vector := fail
),

linalg4 := rec(
	characteristic_eqn :=fail, 
	columncount :=fail, 
	eigenvalue :=fail, 
	eigenvector :=fail, 
	rank :=fail, 
	rowcount :=fail, 
	size := fail
),

linalg5 := rec(
	("anti-Hermitian") :=fail, 
	banded :=fail, 
	constant :=fail, 
	diagonal_matrix :=fail, 
	Hermitian :=fail, 
	identity :=fail, 
	("lower-Hessenberg") :=fail, 
	("lower-triangular") :=fail, 
	scalar :=fail, 
	("skew-symmetric") :=fail, 
	symmetric :=fail, 
	tridiagonal :=fail, 
	("upper-Hessenberg") :=fail, 
	("upper-triangular") :=fail, 
	zero := fail
),

linalg6 := rec(
	matrix_tensor := fail, 
	vector_tensor := fail
),	

linalg7 := rec(
	list_to_matrix := fail, 
	list_to_vector := fail
),

minmax1 := rec(
	min := x -> Minimum(x[1]),
    max := x-> Maximum(x[1])
),

relation3 := rec( # TO BE TESTED 
    class := fail, 
    classes := fail,
    equivalence_closure := x -> TransitiveClosureBinaryRelation( 
                                  SymmetricClosureBinaryRelation(
                                    ReflexiveClosureBinaryRelation( x[1] ) ) ),   
    is_equivalence := x -> IsEquivalenceRelation( x[1] ),
    is_reflexive := x -> IsReflexiveBinaryRelation( x[1] ),
	is_relation := fail,
    is_symmetric := x -> IsSymmetricBinaryRelation( x[1] ),
    is_transitive := x -> IsTransitiveBinaryRelation( x[1] ),
    reflexive_closure := x -> ReflexiveClosureBinaryRelation( x[1] ),
    symmetric_closure := x -> SymmetricClosureBinaryRelation( x[1] ),
    transitive_closure := x -> TransitiveClosureBinaryRelation( x[1] )
),

relation4 := rec(
	eqs := fail
),

);

OM_append_new := function (  )
    local cd, name;
    MakeReadWriteGlobal( "OMsymRecord" );
    for cd in RecNames( OMsymRecord_new )  do
    	if IsBound( OMsymRecord.(cd) ) then
    		for name in RecNames( OMsymRecord_new.(cd) ) do
    	    	OMsymRecord.(cd).(name) := OMsymRecord_new.(cd).(name);
    	  	od;
    	else
    	  	OMsymRecord.(cd) := OMsymRecord_new.(cd);     
    	fi;
    od;	   
    MakeReadOnlyGlobal( "OMsymRecord" );
end;

OM_append_new();

Unbind( OM_append_new );

OMsymRecord_private := rec();

OM_append_private := function (  )
    local cd, name;
    if IsExistingFile( Concatenation( GAPInfo.PackagesInfo.("openmath")[1].InstallationPath,"/private/private.g") ) then
		Read( Concatenation( GAPInfo.PackagesInfo.("openmath")[1].InstallationPath,"/private/private.g") );
    fi;
    MakeReadWriteGlobal( "OMsymRecord" );
    for cd in RecNames( OMsymRecord_private )  do
    	if IsBound( OMsymRecord.(cd) ) then
    		for name in RecNames( OMsymRecord_private.(cd) ) do
    	    	OMsymRecord.(cd).(name) := OMsymRecord_private.(cd).(name);
    	  	od;
    	else
    	  	OMsymRecord.(cd) := OMsymRecord_private.(cd);     
    	fi;
    od;	   
    MakeReadOnlyGlobal( "OMsymRecord" );
end;

OM_append_private();

Unbind( OM_append_private );


#############################################################################
#E

