#############################################################################
##
#W  reesmat.gi           GAP library         Andrew Solomon and Isabel Araújo
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the implementation of Rees matrix semigroups.
##

#JDM: make a NC version of ReesMatrixSemigroup and ReesZeroMatrixSemigroup

############################################################################
##
#R  IsReesMatrixSemigroupElementRep(<obj>)
##
##  A ReesMatrix element is a triple ( <i>, <s>, <lambda>)
##  <s> is an element of the underlying semigroup
##  <i>, <lambda> are indices.
##
##  This can be thought of as a matrix with zero everywhere
##  except for an occurrence of <s> at row <lambda> and column <i>
##
DeclareRepresentation("IsReesMatrixSemigroupElementRep",
	IsComponentObjectRep and IsAttributeStoringRep, rec());


#############################################################################
##
#F  ReesMatrixSemigroupElement( <R>, <i>, <a>, <lambda> )
##
##  Returns the element of the RM semigroup <R> corresponding to the
##  matrix with zero everywhere and <a> in row i and column x.
##
##  Notice that:
##  <a> must be in UnderlyingSemigroupOfReesMatrixSemigroup<R>
##  <i> must be in the range 1 .. RowsOfReesMatrixSemigroup(R)
##  <lambda> must be in the range 1 .. ColumnsOfReesMatrixSemigroup(R)
##
InstallGlobalFunction(ReesMatrixSemigroupElement,
function(R, i, a, lambda)
	local
				S, 				# The underlying semigroup
				elt;			# the newly created element

	# Check that R is a Rees Matrix semigroup
	if not IsReesMatrixSemigroup(R) then
		Error("ReesMatrixSemigroupElement - first argument must be a Rees Matrix semigroup");
	fi;

	S  := UnderlyingSemigroupOfReesMatrixSemigroup(R);
	# check that <a> is in the underlying semigroup
	if not a in S then
		 Error("ReesMatrixSemigroupElement - second argument must be in underlying semigroup");
        fi;

	# check that <i> and <lambda> are in the correct range
	if not (i in [1 .. RowsOfReesMatrixSemigroup(R)] and
		lambda in [1 .. ColumnsOfReesMatrixSemigroup(R)]) then
			Error("ReesMatrixSemigroupElement -  indices out of range");
	fi;

	# The arguments are sensible. Create the element.
	elt := Objectify(FamilyObj(R)!.wholeSemigroup!.eType, rec());
	SetUnderlyingElementOfReesMatrixSemigroupElement(elt, a);
	SetColumnIndexOfReesMatrixSemigroupElement(elt, lambda);
	SetRowIndexOfReesMatrixSemigroupElement(elt, i);
	return elt;
end);


#############################################################################
##
#F  ReesZeroMatrixSemigroupElement( <R>, <i>, <a>, <lambda> )
##
##  Returns the element of the RM semigroup <R> corresponding to the
##  matrix with zero everywhere and <a> in row i and column x.
##
##  Notice that:
##  <a> must be in UnderlyingSemigroupOfReesMatrixSemigroup<R>
##  <i> must be in the range 1 .. RowsOfReesMatrixSemigroup(R)
##  <lambda> must be in the range 1 .. ColumnsOfReesMatrixSemigroup(R)
##
InstallGlobalFunction(ReesZeroMatrixSemigroupElement,
function(R, i, a, lambda)
  local S, elt;

  if not IsReesZeroMatrixSemigroup(R) then
    Error("ReesZeroMatrixSemigroupElement - first argument must be a Rees Matrix semigroup");
  fi;
  
  S  := UnderlyingSemigroupOfReesZeroMatrixSemigroup(R);
  # check that <a> is in the underlying semigroup
  if not a in S then
    Error("ReesZeroMatrixSemigroupElement - second argument must be in underlying semigroup");
  fi;

  # check that <i> and <lambda> are in the correct range
  if not (i in [1 .. RowsOfReesZeroMatrixSemigroup(R)] and
    lambda in [1 .. ColumnsOfReesZeroMatrixSemigroup(R)]) then
    Error("ReesZeroMatrixSemigroupElement -  indices out of range");
  fi;

  # The arguments are sensible. Create the element.
  if a=MultiplicativeZero(S) then
    # has the zero already been created?
    return MultiplicativeZero(S);		

#JDM I think that MultiplicativeZero is or should be set when 
#JDM the RMZS is created so that the following can't occur...
#if HasMultiplicativeZero(R) then
#			return MultiplicativeZero(R);
#		else
# need to get the elements family from the whole semigroup
#			elt := Objectify(FamilyObj(R)!.wholeSemigroup!.eType, rec());
#			SetReesZeroMatrixSemigroupElementIsZero(elt, true);
#			SetMultiplicativeZero(R, elt);
#			return elt;
#		fi;
	else
    	elt := Objectify(FamilyObj(R)!.wholeSemigroup!.eType, rec());
		SetReesZeroMatrixSemigroupElementIsZero(elt, false);
    	SetUnderlyingElementOfReesZeroMatrixSemigroupElement(elt, a);
    	SetColumnIndexOfReesZeroMatrixSemigroupElement(elt, lambda);
    	SetRowIndexOfReesZeroMatrixSemigroupElement(elt, i);
    	return elt;
    fi;
end);


#############################################################################
##
#A  SandwichMatrixOfReesZeroMatrixSemigroup( <R> )
#A  RowsOfReesZeroMatrixSemigroup( <R> )
#A  ColumnsOfReesZeroMatrixSemigroup( <R> )
#A  UnderlyingSemigroupOfReesZeroMatrixSemigroup( <R> )
##
##  Install methods for subsemigroups.
##
InstallMethod(SandwichMatrixOfReesZeroMatrixSemigroup,
	"for a subsemigroup of a Rees zero matrix semigroup",
	[IsSubsemigroupReesZeroMatrixSemigroup],
	R->SandwichMatrixOfReesZeroMatrixSemigroup(FamilyObj(R)!.wholeSemigroup));

InstallMethod(RowsOfReesZeroMatrixSemigroup,
 "for a subsemigroup of a Rees zero matrix semigroup",
  [IsSubsemigroupReesZeroMatrixSemigroup],
  R->RowsOfReesZeroMatrixSemigroup(FamilyObj(R)!.wholeSemigroup));

InstallMethod(ColumnsOfReesZeroMatrixSemigroup,
 "for a subsemigroup of a Rees zero matrix semigroup",
  [IsSubsemigroupReesZeroMatrixSemigroup],
  R->ColumnsOfReesZeroMatrixSemigroup(FamilyObj(R)!.wholeSemigroup));

InstallMethod(UnderlyingSemigroupOfReesZeroMatrixSemigroup,
 "for a subsemigroup of a Rees zero matrix semigroup",
  [IsSubsemigroupReesZeroMatrixSemigroup],
  R->UnderlyingSemigroupOfReesZeroMatrixSemigroup(FamilyObj(R)!.wholeSemigroup));

#############################################################################
##
#A  SandwichMatrixOfReesMatrixSemigroup( <R> )
#A  RowsOfReesMatrixSemigroup( <R> )
#A  ColumnsOfReesMatrixSemigroup( <R> )
#A  UnderlyingSemigroupOfReesMatrixSemigroup( <R> )
##
##  Install methods for subsemigroups.
##
InstallMethod(SandwichMatrixOfReesMatrixSemigroup,
	"for a subsemigroup of a Rees matrix semigroup",
	[IsSubsemigroupReesMatrixSemigroup],
	R->SandwichMatrixOfReesMatrixSemigroup(FamilyObj(R)!.wholeSemigroup));

InstallMethod(RowsOfReesMatrixSemigroup,
 "for a subsemigroup of a Rees matrix semigroup",
  [IsSubsemigroupReesMatrixSemigroup],
  R->RowsOfReesMatrixSemigroup(FamilyObj(R)!.wholeSemigroup));

InstallMethod(ColumnsOfReesMatrixSemigroup,
 "for a subsemigroup of a Rees matrix semigroup",
  [IsSubsemigroupReesMatrixSemigroup],
  R->ColumnsOfReesMatrixSemigroup(FamilyObj(R)!.wholeSemigroup));

InstallMethod(UnderlyingSemigroupOfReesMatrixSemigroup,
 "for a subsemigroup of a Rees matrix semigroup",
  [IsSubsemigroupReesMatrixSemigroup],
  R->UnderlyingSemigroupOfReesMatrixSemigroup(FamilyObj(R)!.wholeSemigroup));


#############################################################################
##
#F  ReesMatrixSemigroup( <S>, <matrix> )
##
##  Returns the Rees matrix semigroup with multiplication defined by
##  <matrix> whose entries are in <S>.
##
##
InstallGlobalFunction(ReesMatrixSemigroup,
function(S, sandmat)
	local
				x, 				# a row of the matrix
				rowlen, 	# length of a row of the matrix
				Y, 				# a list of booleans
				eType,		# the type of an element
				fam,			# the family of an element
                z,              # the zero of S
				T; 				# The resulting Rees matrix Semigroup

	if not (IsSemigroup(S) and IsList(sandmat)) then
		Error("Usage: ReesMatrixSemigroup(<semigroup>, <sandwich matrix>)");
	fi;

	rowlen := Length(sandmat[1]); # the length of the first row
	for x in sandmat do
		if not (IsList(x) and (Length(x) = rowlen)) then
			Error("Usage: ReesMatrixSemigroup(<semigroup>, <sandwich matrix>)");

			Y := List(x, y->y in S);
			if false in Y then
				Error("ReesMatrixSemigroup: the matrix must be over <S>");
			fi;
		fi;
	od;

	# Now we can make the semigroup
	# Create a new family.
	fam := NewFamily( "FamilyElementsReesMatrixSemigroup",
		IsReesMatrixSemigroupElement );

	# Create the rees matrix semigroup.
	T := Objectify( NewType( CollectionsFamily( fam ), IsWholeFamily and IsReesMatrixSemigroup and IsAttributeStoringRep ), rec() );

	eType := NewType(fam,
		IsReesMatrixSemigroupElement and IsReesMatrixSemigroupElementRep,
		T); # The element type now stores the Semigroup in the Type Data

	# Store the element type in the semigroup
	T!.eType := eType;

	# Any subsemigroups given by generators will have this as
	# the whole semigroup
	FamilyObj( T )!.wholeSemigroup := T;

	SetSandwichMatrixOfReesMatrixSemigroup(T, sandmat);
	SetRowsOfReesMatrixSemigroup(T, rowlen);
	SetColumnsOfReesMatrixSemigroup(T, Length(sandmat));
	SetUnderlyingSemigroupOfReesMatrixSemigroup(T, S);

	return T;
end );


#############################################################################
##
#F  ReesZeroMatrixSemigroup( <S>, <matrix> )
##
##  Returns the rees 0-matrix semigroup with multiplication defined by
##  <matrix> whose entries are in <S>.
##
##
InstallGlobalFunction(ReesZeroMatrixSemigroup,
function(S, sandmat)
	local
				x, 				# a row of the matrix
				rowlen, 	# length of a row of the matrix
				Y, 				# a list of booleans
				eType,		# the type of an element
				fam,			# the family of an element
                z,              # the zero of S
				T; 				# The resulting Rees matrix Semigroup

	if not (IsSemigroup(S) and IsList(sandmat)) then
		Error("Usage: ReesZeroMatrixSemigroup(<semigroup>, <sandwich matrix>)");
	fi;

	rowlen := Length(sandmat[1]); # the length of the first row
	for x in sandmat do
		if not (IsList(x) and (Length(x) = rowlen)) then
			Error("Usage: ReesZeroMatrixSemigroup(<semigroup>, <sandwich matrix>)");

			Y := List(x, y->y in S);
			if false in Y then
				Error("ReesZeroMatrixSemigroup: the matrix must be over <S>");
			fi;
		fi;
	od;

	#JDM is this really necessary? 0 of rms not= 0 of S, should it be? 
	if not HasMultiplicativeZero(S) then 
           Error("must be defined over a semigroup with zero");
	fi;
	# Now we can make the semigroup
	# Create a new family.
	fam := NewFamily( "FamilyElementsReesZeroMatrixSemigroup",
		IsReesZeroMatrixSemigroupElement );

	# Create the rees matrix semigroup.
	T := Objectify( NewType( CollectionsFamily( fam ),
		IsWholeFamily and	IsReesZeroMatrixSemigroup and IsAttributeStoringRep ),
		rec() );

	eType := NewType(fam,
		IsReesZeroMatrixSemigroupElement and IsReesMatrixSemigroupElementRep,
		T); # The element type now stores the Semigroup in the Type Data

	# Store the element type in the semigroup
	T!.eType := eType;

	# Any subsemigroups given by generators will have this as
	# the whole semigroup
	FamilyObj( T )!.wholeSemigroup := T;

	SetSandwichMatrixOfReesZeroMatrixSemigroup(T, sandmat);
	SetRowsOfReesZeroMatrixSemigroup(T, rowlen);
	SetColumnsOfReesZeroMatrixSemigroup(T, Length(sandmat));
	SetUnderlyingSemigroupOfReesZeroMatrixSemigroup(T, S);

	if HasIsZeroGroup(S) and IsZeroGroup(S) then
		SetIsZeroSimpleSemigroup(T, true);
	fi;

    z:= MultiplicativeZero(S);
    if z = fail then
        Error("ReesZeroMatrixSemigroup - underlying semigroup must contain a zero element");
    fi;

    SetMultiplicativeZero(T, ReesZeroMatrixSemigroupElement(T,  1, z, 1));

	return T;
end );



############################################################################
##
#M  PrintObj( <rmelt> ) . . . . .  for an element of a Rees Matrix semigroup
##
InstallMethod( PrintObj, "for elements of Rees matrix semigroups",
[IsReesMatrixSemigroupElement],
function(x)
		Print("(",RowIndexOfReesMatrixSemigroupElement(x),","
                        ,UnderlyingElementOfReesMatrixSemigroupElement(x),
		       ",",ColumnIndexOfReesMatrixSemigroupElement(x), ")");
end);


############################################################################
##
#M  PrintObj( <rmelt> ) . . . for an element of a zero Rees Matrix semigroup
##
InstallMethod( PrintObj, "for elements of Rees zero matrix semigroups",
[IsReesZeroMatrixSemigroupElement],
function(x)
    if ReesZeroMatrixSemigroupElementIsZero(x) then
        Print("0");
    else
		Print("(",RowIndexOfReesZeroMatrixSemigroupElement(x),","
                        ,UnderlyingElementOfReesZeroMatrixSemigroupElement(x),
		       ",",ColumnIndexOfReesZeroMatrixSemigroupElement(x), ")");
    fi;
end);


############################################################################
##
#M  ViewObj( <R> ) . . . . . . . . . . . . . .  for a  Rees matrix semigroup
##
InstallMethod( ViewObj, "for Rees matrix semigroups",
    [ IsSubsemigroupReesMatrixSemigroup ],
function(R)
    if not HasIsWholeFamily(R) then
    	Print("Subsemigroup of Rees Matrix Semigroup over ",
	    	UnderlyingSemigroupOfReesMatrixSemigroup(R));
    else
    	Print("Rees Matrix Semigroup over ");
        ViewObj(UnderlyingSemigroupOfReesMatrixSemigroup(R));
    fi;
end);


############################################################################
##
#M  ViewObj( <R> ) . . . . . . . . . . . . for a  Rees zero matrix semigroup
##
InstallMethod( ViewObj, "for Rees zero matrix semigroups",
    [ IsSubsemigroupReesZeroMatrixSemigroup ],
function(R)
    if not HasIsWholeFamily(R) then
    	Print("Subsemigroup of Rees Zero Matrix Semigroup over ",
	    	UnderlyingSemigroupOfReesZeroMatrixSemigroup(R));
    else
    	Print("Rees Zero Matrix Semigroup over ",
	    	UnderlyingSemigroupOfReesZeroMatrixSemigroup(R));
    fi;
end);


############################################################################
##
#M  PrintObj( <R> ) . . . . . . . . . . . . . .  for a Rees matrix semigroup
##
InstallMethod( PrintObj, "for Rees matrix semigroups",
[IsSubsemigroupReesMatrixSemigroup],
function(R)
    if not HasIsWholeFamily(R) then
    	Print("Subsemigroup of Rees Matrix Semigroup over ",
	    	UnderlyingSemigroupOfReesMatrixSemigroup(R));
    else
    	Print("Rees Matrix Semigroup over ",
	    	UnderlyingSemigroupOfReesMatrixSemigroup(R));
    fi;
end);


############################################################################
##
#M  PrintObj( <R> ) . . . . . . . . . . . . for a Rees zero matrix semigroup
##
InstallMethod( PrintObj, "for Rees zero matrix semigroups",
[IsSubsemigroupReesZeroMatrixSemigroup],
function(R)
    if not HasIsWholeFamily(R) then
    	Print("Subsemigroup of Rees Zero Matrix Semigroup over ",
	    	UnderlyingSemigroupOfReesZeroMatrixSemigroup(R));
    else
    	Print("Rees Zero Matrix Semigroup over ",
	    	UnderlyingSemigroupOfReesZeroMatrixSemigroup(R));
    fi;
end);


############################################################################
##
#M  <rmelt> * <rmelt>
##
##  The product of two rees matrix semigroup elements (a;i,lambda)
##  and (b; j, mu) is (aM_{lambda,j}b; i, mu)
##  where M is the sandwich matrix
##
## 
InstallMethod(\*,
"for two elements of a Rees matrix semigroup",
IsIdenticalObj,
[IsReesMatrixSemigroupElement, IsReesMatrixSemigroupElement], 0,
function(x, y)
  local
				R,						# Rees Matrix semigroup
				M,						# sandwich matrix
				a, b, 				#Underlying elements of x and y resp
				i, j, 				# Row indices of x, y resp
				lambda, mu, 	#column indices of x, y resp
				c;						# The resulting element of the underlying semigroup

	R := DataType(TypeObj(x));


	a := UnderlyingElementOfReesMatrixSemigroupElement(x);
	b := UnderlyingElementOfReesMatrixSemigroupElement(y);

	i := RowIndexOfReesMatrixSemigroupElement(x);
	j := RowIndexOfReesMatrixSemigroupElement(y);

	lambda := ColumnIndexOfReesMatrixSemigroupElement(x);
	mu := ColumnIndexOfReesMatrixSemigroupElement(y);

	M := SandwichMatrixOfReesMatrixSemigroup(R);

	c := a*M[lambda][j]*b;

#JDM
#	return ReesMatrixSemigroupElement(R, c, i, mu);
#

	return ReesMatrixSemigroupElement(R, i, c, mu);
end);


############################################################################
##
#M  <rmelt> * <rmelt>
##
##  The product of two rees matrix semigroup elements (a;i,lambda)
##  and (b; j, mu) is (aM_{lambda,j}b; i, mu)
##  where M is the sandwich matrix
##
InstallMethod(\*,
"for two elements of a Rees zero matrix semigroup",
IsIdenticalObj,
[IsReesZeroMatrixSemigroupElement, IsReesZeroMatrixSemigroupElement], 0,
function(x, y)
  local
				R,						# Rees Matrix semigroup
				M,						# sandwich matrix
				S,						# underlying semigroup
				a, b, 				#Underlying elements of x and y resp
				i, j, 				# Row indices of x, y resp
				lambda, mu, 	#column indices of x, y resp
				c;						# The resulting element of the underlying semigroup

	R := DataType(TypeObj(x));

	if ReesZeroMatrixSemigroupElementIsZero(x) or
		ReesZeroMatrixSemigroupElementIsZero(y) then
		return MultiplicativeZero(R);
	fi;

	# Both are nonzero.

	a := UnderlyingElementOfReesZeroMatrixSemigroupElement(x);
	b := UnderlyingElementOfReesZeroMatrixSemigroupElement(y);

	i := RowIndexOfReesZeroMatrixSemigroupElement(x);
	j := RowIndexOfReesZeroMatrixSemigroupElement(y);

	lambda := ColumnIndexOfReesZeroMatrixSemigroupElement(x);
	mu := ColumnIndexOfReesZeroMatrixSemigroupElement(y);

	M := SandwichMatrixOfReesZeroMatrixSemigroup(R);

	S := UnderlyingSemigroupOfReesZeroMatrixSemigroup(R);

	c := a*M[lambda][j]*b;

	if IsMultiplicativeZero(S,c) then
		return  MultiplicativeZero(R);
	fi;

#JDM
#	return ReesZeroMatrixSemigroupElement(R, c, i, mu);
#

	return ReesZeroMatrixSemigroupElement(R, i, c, mu);
end);


#############################################################################
##
#M  Size( <R> ) . . . . . . . . . . . . . . . . . for a Rees matrix semigroup
##
InstallMethod( Size,
    "for a Rees matrix semigroup",
    [ IsReesMatrixSemigroup ],
function(r)
  local s, m, n, sizeofr;

	s := UnderlyingSemigroupOfReesMatrixSemigroup( r );
	m := RowsOfReesMatrixSemigroup( r );
	n := ColumnsOfReesMatrixSemigroup( r );

	if Size(s) = infinity or m = infinity or n = infinity then
		return infinity;
	fi;

#	if HasMultiplicativeZero( r ) then
#		sizeofr := (Size( s ) - 1) * m * n + 1;
#	else
    sizeofr := Size( s ) * m * n;
#	fi;

   return sizeofr;
end);


#############################################################################
##
#M  Size( <R> ) . . . . . . . . . . . . . .  for a Rees zero matrix semigroup
##
InstallMethod( Size,
    "for a Rees zero matrix semigroup",
    [ IsReesZeroMatrixSemigroup ],
function(r)
  local s, m, n, sizeofr;

	s := UnderlyingSemigroupOfReesZeroMatrixSemigroup( r );
	m := RowsOfReesZeroMatrixSemigroup( r );
	n := ColumnsOfReesZeroMatrixSemigroup( r );

	if Size(s) = infinity or m = infinity or n = infinity then
		return infinity;
	fi;

	sizeofr := (Size( s ) - 1) * m * n + 1;

   return sizeofr;
end);


############################################################################
##
#M  <rmelt> < <rmelt>
##
##  "Lexicographic" ordering on element of rees matrix semigroups.
##  (a; i, lambda) < (b;j, mu) if
##  a < b; or
##  a = b and i < j; or
##  a = b and i = j and lambda < mu;
##
InstallMethod(\<,
"for two elements of a Rees matrix semigroup",
IsIdenticalObj,
[IsReesMatrixSemigroupElement, IsReesMatrixSemigroupElement], 0,
function(x, y)
  local
				a,b, 							# Underlying elements
				i, j, 						# row indices
				lambda, mu; 			# column indices

	# now we know that neither are zero
	a := UnderlyingElementOfReesMatrixSemigroupElement(x);
	b := UnderlyingElementOfReesMatrixSemigroupElement(y);

	i := RowIndexOfReesMatrixSemigroupElement(x);
	j := RowIndexOfReesMatrixSemigroupElement(y);

	lambda := ColumnIndexOfReesMatrixSemigroupElement(x);
	mu := ColumnIndexOfReesMatrixSemigroupElement(y);

	if (a < b) then
		return true;
	elif (a > b) then
		return false;
	elif (i < j) then
		return true;
	elif (i > j) then
		return false;
	elif (lambda < mu) then
		return true;
	else
		return false;
	fi;
end);


############################################################################
##
#M  <rmelt> < <rmelt>
##
##  "Lexicographic" ordering on element of rees matrix semigroups.
##  (a; i, lambda) < (b;j, mu) if
##  a < b; or
##  a = b and i < j; or
##  a = b and i = j and lambda < mu;
##
InstallMethod(\<,
"for two elements of a Rees zero matrix semigroup",
IsIdenticalObj,
[IsReesZeroMatrixSemigroupElement, IsReesZeroMatrixSemigroupElement], 0,
function(x, y)
  local
				a,b, 							# Underlying elements
				i, j, 						# row indices
				lambda, mu; 			# column indices



	if ReesZeroMatrixSemigroupElementIsZero(x) and
			ReesZeroMatrixSemigroupElementIsZero(y) then
		return false;
	elif ReesZeroMatrixSemigroupElementIsZero(x) then
		return true;
	elif ReesZeroMatrixSemigroupElementIsZero(y) then
		return false;
	fi;

	# now we know that neither are zero
	a := UnderlyingElementOfReesZeroMatrixSemigroupElement(x);
	b := UnderlyingElementOfReesZeroMatrixSemigroupElement(y);

	i := RowIndexOfReesZeroMatrixSemigroupElement(x);
	j := RowIndexOfReesZeroMatrixSemigroupElement(y);

	lambda := ColumnIndexOfReesZeroMatrixSemigroupElement(x);
	mu := ColumnIndexOfReesZeroMatrixSemigroupElement(y);

	if (a < b) then
		return true;
	elif (a > b) then
		return false;
	elif (i < j) then
		return true;
	elif (i > j) then
		return false;
	elif (lambda < mu) then
		return true;
	else
		return false;
	fi;
end);


############################################################################
##
#M  <rmelt> = <rmelt>
##
##  tests equality of two rees matrix semigroup elements
##
InstallMethod(\=, "for two elements of a Rees matrix semigroup",
IsIdenticalObj,
[IsReesMatrixSemigroupElement,
IsReesMatrixSemigroupElement],
function(a, b)

	return
			(RowIndexOfReesMatrixSemigroupElement(a) =
			RowIndexOfReesMatrixSemigroupElement(b))
		and
			(ColumnIndexOfReesMatrixSemigroupElement(a) =
			ColumnIndexOfReesMatrixSemigroupElement(b))
		and
			(UnderlyingElementOfReesMatrixSemigroupElement(a) =
			UnderlyingElementOfReesMatrixSemigroupElement(b));

end);


############################################################################
##
#M  <rmelt> = <rmelt>
##
##  tests equality of two rees matrix semigroup elements
##
InstallMethod(\=, "for two elements of a Rees zero matrix semigroup",
IsIdenticalObj,
[IsReesZeroMatrixSemigroupElement,
IsReesZeroMatrixSemigroupElement],
function(a, b)

	if ReesZeroMatrixSemigroupElementIsZero(a) and
			ReesZeroMatrixSemigroupElementIsZero(b) then
		return true;
	fi;

	if ReesZeroMatrixSemigroupElementIsZero(a) or
			ReesZeroMatrixSemigroupElementIsZero(b) then
		return false;
	fi;

	return
			(RowIndexOfReesZeroMatrixSemigroupElement(a) =
			RowIndexOfReesZeroMatrixSemigroupElement(b))
		and
			(ColumnIndexOfReesZeroMatrixSemigroupElement(a) =
			ColumnIndexOfReesZeroMatrixSemigroupElement(b))
		and
			(UnderlyingElementOfReesZeroMatrixSemigroupElement(a) =
			UnderlyingElementOfReesZeroMatrixSemigroupElement(b));

end);

#############################################################################
##
#F  ReesMatrixSemigroupEnumeratorGetElement( <enum>, <k> )
##
##  Returns a pair [T/F, elm], such that if <k> is less than or equal to
##  the size of the Rees Matrix Semigroup the first of the pair will be
##  true, and elm will be the element at the <k>th place.   Otherwise, the
##  first of the pair will be false.
##
BindGlobal("ReesMatrixSemigroupEnumeratorGetElement",
function(enum, k)
  local r,					# the Rees Matrix semigroup we are enumerating
				s,					# the underlying semigroup
								m,					# the number of rows of the matrix
				n,					# the number of columns of the matrix
				new;				# the new element found

  if k <= Length( enum!.currentlist ) then
    return [ true, enum!.currentlist[k] ];
  fi;

  r := UnderlyingCollection( enum );
  s := UnderlyingSemigroupOfReesMatrixSemigroup( r );
	m := RowsOfReesMatrixSemigroup( r );
	n := ColumnsOfReesMatrixSemigroup( r );

	# it keeps going until either it reaches position k or else
	# there are no more elements to be listed
	# There are no more elements to be listed if the iterator of s is exausted
	# and both the indexes of row and column are as big as they can be
  while Length( enum!.currentlist ) < k and
		not (IsDoneIterator(enum!.itunder) and enum!.column=n and enum!.row =m)   do

		if enum!.column < n then
			enum!.column := enum!.column + 1;
		elif enum!.row < m then
			enum!.row := enum!.row + 1;
			enum!.column := 1;
		else
			enum!.element := NextIterator( enum!.itunder );
			enum!.column := 1;
			enum!.row := 1;
		fi;

		new := ReesMatrixSemigroupElement( r, enum!.row, enum!.element,  enum!.column);
		Add( enum!.currentlist, new );
	od;

  if Length(enum!.currentlist) < k then
    return [false, 0];
  fi;

	return [true, enum!.currentlist[k]];

end);


#############################################################################
##
#F  ReesZeroMatrixSemigroupEnumeratorGetElement( <enum>, <k> )
##
##  Returns a pair [T/F, elm], such that if <k> is less than or equal to
##  the size of the Rees Matrix Semigroup the first of the pair will be
##  true, and elm will be the element at the <k>th place.   Otherwise, the
##  first of the pair will be false.
##
BindGlobal("ReesZeroMatrixSemigroupEnumeratorGetElement",
function(enum, k)
  local r,		# the Rees Matrix semigroup we are enumerating
	s,		# the underlying semigroup
	m,		# the number of rows of the matrix
	n,		# the number of columns of the matrix
	new;		# the new element found

  if k <= Length( enum!.currentlist ) then
    return [ true, enum!.currentlist[k] ];
  fi;

  r := UnderlyingCollection( enum );
  s := UnderlyingSemigroupOfReesZeroMatrixSemigroup( r );
	m := RowsOfReesZeroMatrixSemigroup( r );
	n := ColumnsOfReesZeroMatrixSemigroup( r );

	# it keeps going until either it reaches position k or else
	# there are no more elements to be listed
	# There are no more elements to be listed if the iterator of s is exausted
	# and both the indexes of row and column are as big as they can be
  while Length( enum!.currentlist ) < k and
		not (IsDoneIterator(enum!.itunder) and enum!.column=n and enum!.row =m) do

		if enum!.column < n then
			enum!.column := enum!.column + 1;
		elif enum!.row < m then
			enum!.row := enum!.row + 1;
			enum!.column := 1;
		else
			enum!.element := NextIterator( enum!.itunder );
      # here we have to check whether the element of s we
      # obtained is the zero or not - if it is the zero
      # of s it will generate only 0 and hence we should skip it
			if enum!.element=MultiplicativeZero(s) then
				if not(IsDoneIterator(enum!.itunder)) then
					enum!.element := NextIterator( enum!.itunder );
        fi;
      fi;
			enum!.column := 1;
			enum!.row := 1;
		fi;

		new := ReesZeroMatrixSemigroupElement( r, enum!.row, enum!.element,  enum!.column);
		Add( enum!.currentlist, new );
	od;

  if Length(enum!.currentlist) < k then
    return [false, 0];
  fi;

	return [true, enum!.currentlist[k]];

end);


#############################################################################
##
#M  \[\]( <E>, <n> )
##
##  Returns the <n>-th element of the Rees matrix semigroup enumerator <E>.
##
BindGlobal( "ElementNumber_ReesMatrixSemigroupEnumerator",
    function( enum, n )
  if IsBound(enum[n]) then
    return enum!.currentlist[n];
  else
    Error("Position out of range");
  fi;
end );


#############################################################################
##
#M  IsBound\[\]( <E>, <n> )
##
##  Returns true if the enumerator <E> has size at least <n>.
##
BindGlobal( "IsBound_ReesMatrixSemigroupEnumerator", function( enum, n )
    local pair;

    if IsReesMatrixSemigroup(UnderlyingCollection(enum)) then
      pair:= ReesMatrixSemigroupEnumeratorGetElement( enum, n);
    else
      pair:= ReesZeroMatrixSemigroupEnumeratorGetElement( enum, n);
    fi;
    return pair[1];
end );


############################################################################
##
#M  Enumerator( <R> ) . . . . . . . . . . . . .  for a Rees matrix semigroup
##
##  Elements are enumerated respecting their order, hence we get the
##  enumerator sorted.
#T but the enumerator does not store this, and the method is also not
#T installed for `EnumeratorSorted'!
#T (what about the method further down?)
##
InstallMethod( Enumerator, "for a Rees matrix semigroup",
    [ IsReesMatrixSemigroup ],
    function( r )
    local its;    # an iterator of the underlying semigroup

    # This method only works for the whole Rees matrix semigroup.
    if FamilyObj( r )!.wholeSemigroup <> r then
      TryNextMethod();
    fi;

    its:= Iterator( UnderlyingSemigroupOfReesMatrixSemigroup( r ) );

    return EnumeratorByFunctions( r, rec(
        ElementNumber := ElementNumber_ReesMatrixSemigroupEnumerator,
        NumberElement := NumberElement_SemigroupIdealEnumerator,
        IsBound\[\]   := IsBound_ReesMatrixSemigroupEnumerator,
        Length        := Length_SemigroupIdealEnumerator,
        Membership    := Membership_SemigroupIdealEnumerator,

        currentlist   := [],
        row           := 1,
        column        := 0,
        element       := NextIterator( its ),
        itunder       := its ) );
end );


############################################################################
##
#M  Enumerator( <R> ) . . . . . . . . . . . for a Rees zero matrix semigroup
##
InstallMethod( Enumerator, "for a Rees zero matrix semigroup",
    [ IsReesZeroMatrixSemigroup ],
    function( r )
    local s,    # the underlying semigroup
          its,  # the iterator of the semigroup s
          x,    # the first element of s
          enum;

    s := UnderlyingSemigroupOfReesZeroMatrixSemigroup( r );
    its := Iterator( s );
    x := NextIterator( its );

    enum:= EnumeratorByFunctions( r, rec(
        ElementNumber := ElementNumber_ReesMatrixSemigroupEnumerator,
        NumberElement := NumberElement_SemigroupIdealEnumerator,
        IsBound\[\]   := IsBound_ReesMatrixSemigroupEnumerator,
        Length        := Length_SemigroupIdealEnumerator,
        Membership    := Membership_SemigroupIdealEnumerator,

        currentlist   := [ MultiplicativeZero( r ) ],
        row           := 1,
        column        := 0,
        element       := x,
        itunder       := its ) );

    # recall that r has a zero iff s has a zero
    # and if the zero of s is the first element of s
    # we should move to the next one
    if x = MultiplicativeZero( s ) then
      if not IsDoneIterator( its ) then
        enum!.element:= NextIterator( its );
      fi;
    fi;

    return enum;
end );


#JDM: the functions from here on down need to be rechecked.

############################################################################
##
#F  BuildIsomorphismReesMatrixSemigroupWithMap( <S>, <groupHclass>, <phi> )
##
##	for s simple semigroup <S>.
##	for a 0-simple semigroup <S>.
##
BindGlobal( "BuildIsomorphismReesMatrixSemigroupWithMap",
function( s1,groupHclass, phi)

	local	e,s,iso,								# a representative of H
				lclassesrep,			# list of representatives of the L classes
				rclassesrep,			# list of representatives of the R classes
				R,L,							# greens R and L relations on s
				r,l,h,						# R, L and H classes of e
				m,n,							# length of lclassesrep and rclassesrep, resp
				matrix,						# the matrix
				iszerosimple,			# boolean to ensure we are in the right case
				i,j,p,
				semi,							# the underlying semigroup of the Rees Matrix smg
				reesfun,
				reessmg;					# the Rees Matrix Semigroup built from s

        iso := IsomorphismTransformationSemigroup(s1);
        s := Range(iso);

	if not( IsSimpleSemigroup(s) or IsZeroSimpleSemigroup(s) ) then
		Error( "Can only build isomorphism for simple or 0-simple semigroups");
	fi;

	if IsSimpleSemigroup(s) then
		iszerosimple:= false;
	else
		iszerosimple:= true;
	fi;

	# First we build the Rees Matrix Semigroup

	# we can get the underlying semigroup, from the mapping phi
	# it is going to be exactly the Source of phi
	semi := Source( phi );

	# now we need to build the matrix

	# pick a representative of h
	e := Image(iso, groupHclass );
	# now we have to fix an element in each of the H classes in the R class of e
	# notice that this will also be a list of l classes rep for all l classes of s
	lclassesrep := [];
	R := GreensRRelation( s );
        r := GreensRClassOfElement(s,e);
	#r := EquivalenceClassOfElementNC( R, e);
	for h in GreensHClasses(r) do
		AddSet( lclassesrep, PreImage(iso,Representative(h)) );
	od;

	# do the same for the H classes in the L class of e
  rclassesrep := [];
  L := GreensLRelation( s );
  l := GreensLClassOfElement(s,e);
  #l := EquivalenceClassOfElementNC( L, e);
  for h in GreensHClasses(l) do
    AddSet( rclassesrep, PreImage(iso,Representative(h)) );
  od;
 

	# now build the matrix
	# it is going to be a m times n matrix, where m is the length of el
	# and m is the length of er
	m := Length( lclassesrep );
	n := Length( rclassesrep );

	# We need a matrix with entries in semi
	# (ie, entries in the perm group isom to h or perm group with zero adjoined)
	# From the theory we know that in the simple case the product of an element from
	# the list  rclassesrep with one formn lclassesrep will be in the H class of e
	# and in the zero simple case it will be in that H class or else is zero
	# so the following makes sense
	matrix := [];
	for i in [1..m] do
		matrix[ i ] := [];
		for j in [1..n] do
			# the entries of the matrix corresponds to the products lclassesrep[j]*rclassesrep[i]
			# in the permgroup (or zero perm group in zero simple case)
			# so they will be the unique preimage under phi of lclassesrep[j]*rclassesrep[i]
			p := ImagesRepresentative( InverseGeneralMapping(phi), Image(iso,lclassesrep[i]*rclassesrep[j]));
			Add( matrix[ i ], p );
		od;
	od;

	# we have all the ingredients to build the ReesMatrix semigroup

	if iszerosimple then
		reessmg:= ReesZeroMatrixSemigroup( semi, matrix);
	else
		reessmg:= ReesMatrixSemigroup( semi, matrix);
	fi;

	# now we need to build the isomorphism

	reesfun := function( x )
		local el,j,i,y;

		if iszerosimple and ReesZeroMatrixSemigroupElementIsZero( x ) then
			return MultiplicativeZero( s1 );
		fi;

		i := RowIndexOfReesMatrixSemigroupElement( x );
		j := ColumnIndexOfReesMatrixSemigroupElement( x );
		y := ImagesRepresentative( phi, UnderlyingElementOfReesMatrixSemigroupElement(x));
		el := rclassesrep[ i ] * y * lclassesrep[ j ];

		return el;
	end;

	return MagmaHomomorphismByFunctionNC( reessmg, s1, reesfun);
end);


############################################################################
##
#M  IsomorphismReesMatrixSemigroup( <S> )
##
##  for a finite simple semigroup <S>.
##  Returns an isomorphism from <S> to an isomorphic Rees Matrix Semigroup
##
InstallMethod( IsomorphismReesMatrixSemigroup,
  "for a finite simple semigroup",
  [IsSimpleSemigroup],
function(s1)
	local	it,s,iso,		# iterator od the semigroup
				d,						# the unique D class of the semigroup
				groupHclass,	# group H class of d
				phi,					# isomorphism from groupHclass to a perm group
				injection_perm_group;
                iso := IsomorphismTransformationSemigroup(s1);
                s := Range(IsomorphismTransformationSemigroup(s1));
	#############################################
	# for a simple semigroup and a group H class.
	# Returns the injection from the perm group isomorphic to H, to S.
	injection_perm_group:=function( s, h)
		local	phi,				# the isomorphim from H to the perm group
					geninvphi,	# the general mapping that is the inverse of phi
					invfun,			# the function taking each el of g to the its preimage in s
					invphi,			# the actual inverse of phi
					g;					# the perm group

		# first we get the mapping, which we know is a bijection, from H to G
		phi := IsomorphismPermGroup( h );
		# and get g, the perm group
		g := Range( phi );

		# then we build its inverse as a general mapping
		geninvphi := InverseGeneralMapping( phi );

		# then we build the inverse of phi, by mapping each element
		# of g to its image representative (notice that since we know that
		# phi is bijective, there is no choice for the image rep,
		# and everything is fixed and well defined
		invfun := x -> ImagesRepresentative( geninvphi, x);
		invphi := MappingByFunction( g, s, invfun);

		return invphi;

	end;

	########################################
	# the actual method now

	# this only works for finite semigroups
	if not (IsFinite( s )) then
		TryNextMethod();
	fi;

	# first get a group H class
	it := Iterator( s );

        d := GreensDClassOfElement(s,NextIterator(it));

        #d := EquivalenceClassOfElementNC( GreensDRelation( s ), NextIterator( it ) );
	groupHclass := GroupHClassOfGreensDClass( d );

	# the a mapping from the perm group (to which groupHclass is isomorphic) to s
	phi := injection_perm_group( s, groupHclass);

	return BuildIsomorphismReesMatrixSemigroupWithMap( s1,
               PreImage(iso,Representative(groupHclass)), phi);
end);


############################################################################
##
#M  IsomorphismReesMatrixSemigroup( <S> )
##
##  for a finite 0-simple semigroup <S>.
##  Returns an isomorphism from <S> to an isomorphic Rees Matrix Semigroup
##
InstallMethod( IsomorphismReesMatrixSemigroup,
  "for a finite 0-simple semigroup",
  [IsZeroSimpleSemigroup],
function(s1)
  local e,s,iso,						# an element of the semigroup
        it,           # iterator od the semigroup
        d,            # the unique D class of the semigroup
        groupHclass,  # group H class of d
        phi,          # the mapping from permgroup with zero to s
				injection_zero_perm_group;

        iso := IsomorphismTransformationSemigroup(s1);
        s := Range(IsomorphismTransformationSemigroup(s1));
	###########################################################
	# for a zero simple semigroup and a non zero group H class.
	# Returns the injection from the perm group with zero adjoined
	# to S, which image is H together with the MultiplicativeZero of s
	injection_zero_perm_group:=function( s, h)
		  local phi,        # the isomorphim from H to the perm group
						csi,				# the injection from g to zero g
	    	    geninvphi,  # the general mapping that is the inverse of phi
						geninvcsi,	# the general mapping that is the inverse of csi
      	  	inj, 		    # the actual mapping we are looking for
						zerog,			# g with a zero adjoined
						fun,				#	the function that will give rise to the mapping we want
    	    	g;          # the perm group

	  # first we get the mapping, which we know is a bijection, from H to G
	  phi := IsomorphismPermGroup( h );
		# and the perm group
		g := Range( phi );

		# the the mapping, an injection, from G to G with zero adjoined
  	csi := InjectionZeroMagma( g );
 	 	# and the perm group with zero adjoined
  	zerog:= Range( csi );

		# so we want to build a mapping from zero g to s

  	# first we build the inverse of phi as a general mapping
	  geninvphi := InverseGeneralMapping( phi );
		# and similarly the inverse of csi as a general mapping
		geninvcsi := InverseGeneralMapping( csi );

		# now we build the mapping, using the follwoing function
		fun := function( x )
			local y;

			# the zero of zerog is mapped to the zero of s
			if x = MultiplicativeZero( zerog ) then
				return MultiplicativeZero( s );
			fi;
			y := ImagesRepresentative( geninvcsi, x );

			# other elements have a unique preimage in g
			# and that obatined pre image has a unique premiage in h, therefore in s
			return ImagesRepresentative( geninvphi, y );
		end;

  	inj:= MappingByFunction( zerog, s, fun);

 		 return inj;

	end;

	#######################################
	# the actual method now

	# this only works for finite semigroups
	if not(IsFinite( s )) then
		TryNextMethod();
	fi;

  # first get a nonzero group H class
  it := Iterator( s );

	# there are at least two elements in s, since s is 0-simple
	# so find a non zero element and fix its d class
	e := NextIterator( it );
	if e=MultiplicativeZero( s ) then
		e := NextIterator( it );
	fi;
  d:= GreensDClassOfElement(s,e);
  #d := EquivalenceClassOfElementNC( GreensDRelation( s ), e);

	# hence get a non zero h class of the semigroup
  groupHclass := GroupHClassOfGreensDClass( d );

	# groupHclass is isomorphic to a permgroup
	# We now get the mapping from the perm group with zero adjoined
	# to the semigroup s
	phi := injection_zero_perm_group( s, groupHclass);

  return BuildIsomorphismReesMatrixSemigroupWithMap( s1,
         PreImage(iso,Representative(groupHclass)), phi);

end);


############################################################################
##
#M  AssociatedReesMatrixSemigroupOfDClass( <D> )
##


InstallMethod(AssociatedReesMatrixSemigroupOfDClass, "for d class",
    [IsGreensDClass],
function( D )
    local h, phi, g, gz, fun, map, r, l, rreps, lreps, n, m, mat, psi;

    if not IsFinite(AssociatedSemigroup(D)) then
        TryNextMethod();
    fi;

    if not IsRegularDClass(D) then
        Error("D class must be regular");
    fi;

    h:= GroupHClassOfGreensDClass(D);

    # find the isomorphic perm group.
    phi:=IsomorphismPermGroup(h);
    g:= Range(phi);
    psi:=InjectionZeroMagma(g);
    gz:= Range(psi);

    # build the function
    fun:= function(x)
        if not x in h then
            return MultiplicativeZero(gz);
        fi;
        return (x^phi)^psi;
    end;

    map:= MappingByFunction(AssociatedSemigroup(D), gz, fun);

    r:= EquivalenceClassOfElement(GreensRRelation(AssociatedSemigroup(D)),
        Representative(h));
    l:= EquivalenceClassOfElement(GreensLRelation(AssociatedSemigroup(D)),
        Representative(h));

    rreps:= List(GreensHClasses(l), Representative);
    lreps:= List(GreensHClasses(r), Representative);

    n:= Length(rreps);
    m:= Length(lreps);

    mat:= List([1..m], x->List([1..n], y->(lreps[x]*rreps[y])^map));

    if ForAll(mat, x->ForAll(x, y -> y <> MultiplicativeZero(gz))) then
        return ReesMatrixSemigroup(g, mat);
    else
        return ReesZeroMatrixSemigroup(gz, mat);
    fi;
end);


#############################################################################
##
#E
