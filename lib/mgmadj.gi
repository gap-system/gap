#############################################################################
##
#W  mgmadj.gi                    GAP library                  Andrew Solomon
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains generic methods for magmas with zero adjoined.
##


#############################################################################
##
#M  IsMultiplicativeZero( <M>, <elt> )
##
InstallMethod( IsMultiplicativeZero,
    "generic method for an element and a magma with multiplicative zero",
    IsCollsElms,
    [ IsMagma and HasMultiplicativeZero, IsMultiplicativeElement], 0,
function( M, z )
	return z = MultiplicativeZero(M);
end);

InstallMethod( IsMultiplicativeZero,
    "generic method for an element and a magma",
    IsCollsElms,
    [ IsMagma, IsMultiplicativeElement], 0,
function( M,z  )
	local x,i,en;

	i := 1;
	en := Enumerator(M);
	while IsBound(en[i]) do
		x := en[i];
		if x*z <> z or z*x <> z then	
			return false;
		fi;
		i := i +1;
	od;
	SetMultiplicativeZero(M,Immutable(z));
	return true;
end);

#############################################################################
##
#M  IsMultiplicativeZero( <M>, <elt> )
##
InstallMethod( IsMultiplicativeZero,
	"generic method for an element of a semigroup, given generators",
	IsCollsElms, [IsSemigroup and HasGeneratorsOfSemigroup, 
					IsMultiplicativeElement], 0,
function(S, z)
	if ForAll(GeneratorsOfSemigroup(S), x->x*z=z and z*x=z) then
		SetMultiplicativeZero(S, Immutable(z));
		return true;
	fi;
	return false;
end);

############################################################################
##
#R  IsMagmaWithMultiplicativeZeroAdjoinedElementRep(<obj>)
##
##  Representation of an element of this type is as record which 
##  has a field "IsTheZero" and another, "UnderlyingElement" which
##  has a value in case "IsTheZero" is false.
##
DeclareRepresentation("IsMagmaWithMultiplicativeZeroAdjoinedElementRep", 
	IsComponentObjectRep and IsMultiplicativeElementWithZero,
	["IsTheZero", "UnderlyingElement"]);


#############################################################################
##
#M  OneOp( <elm> )  
##
InstallMethod( OneOp,
    "for an element of a magma with zero adjoined",
    true,
    [ IsMultiplicativeElementWithOne  and 
		IsMagmaWithMultiplicativeZeroAdjoinedElementRep], 0,
function( elm )
	# has to be created "by hand" so to speak, since the family
	# won't necessarily have the homomorphism to hand when it is created.
	return Objectify(TypeObj(elm), rec( IsTheZero:= false, 
					UnderlyingElement := One(FamilyObj(elm)!.underlyingMagma)));
end );

#############################################################################
##
#M  MultiplicativeZeroOp( <elm> )
##
##  This is a shortcut - the family of elements is the same as the 
##  elements of the magma. It is really the *magma's* zero.
##
InstallMethod( MultiplicativeZeroOp,
    "for an element of a magma with zero adjoined",
    true,
    [ IsMagmaWithMultiplicativeZeroAdjoinedElementRep], 0,
function( elm )
    return FamilyObj(elm)!.zero;
end );


#############################################################################
##
#M  MultiplicativeZero( <M> )
##
InstallOtherMethod( MultiplicativeZero,
    "for a magma",
    true,
    [ IsMagma ], 0,
function( M )
		local en, i;

		en := Enumerator(M);
		i := 1;
		while (IsBound(en[i])) do
			if IsMultiplicativeZero(M, en[i]) then
				return en[i];
			fi;
			i := i +1;
		od;
		return fail;
end );



#############################################################################
##
#A  InjectionZeroMagma( <M> )
##  
##  The canonical homomorphism from the 
##  <M> into the magma formed from <M> with a single new element
##  which is a multiplicative zero for the resulting magma.
##  
##  In order to be able to define multiplication, the elements of the
##  new magma must be in  a new family.
##
InstallMethod(InjectionZeroMagma, 
    "method for a magma",
    true,
    [IsMagma], 0,
function(M)

	local
				Fam, Typ, 	# the new family and type
				z, 					# the new zero
				ZM,					# the new magma
				ZMgens,			# generators of the new magma
				filters,		# the new elements family's filters
				coerce;			# coerce an element of the base magma into the zero magma


  # Putting IsMultiplicativeElement in the NewFamily means that when you make,
  # say [a] it picks up the Category from the Family object and makes
  # sure that [a] has CollectionsCategory(IsMultiplicativeElement)

	# Preserve all sensible properties
	filters := IsMultiplicativeElementWithZero;

	if IsMultiplicativeElementWithOne(Representative(M)) then
		filters := filters and IsMultiplicativeElementWithOne;
	fi;

	if IsAssociativeElement(Representative(M)) then
		filters := filters and IsAssociativeElement;
	fi;

  Fam := NewFamily( "TypeOfElementOfMagmaWithZeroAdjoined", filters);
	Fam!.underlyingMagma := Immutable(M);

	# put n in the type data so that we can find the position in the database
	# without a search
	Typ := NewType(Fam, filters and 
			IsMagmaWithMultiplicativeZeroAdjoinedElementRep);

	
	coerce :=  g->Objectify(Typ, 
		rec( IsTheZero:= false, UnderlyingElement := g));

	# Now create the new magma and its zero element
	z := Objectify(Typ, rec( IsTheZero:= true ) );

	if Length(GeneratorsOfMagma(M))=0 then
		# ZM := Magma(CollectionsFamily(Fam),[]);
		Error("Can't adjoin a zero to a Magma without generators");
	fi;

	# make the list of generators into generators of ZM

	ZMgens := List(GeneratorsOfMagma(M), g->coerce(g));

	if IsSemigroup(M) then
		if IsMonoid(M) then
			# need to supply the identity as second argument
			ZM :=  MonoidByGenerators(Concatenation(ZMgens, [z]));
		else
			ZM :=  Semigroup(Concatenation(ZMgens, [z]));
		fi;
	else
		ZM :=  Magma(Concatenation(ZMgens, [z]));
	fi;

	if IsGroup(M) then
		SetIsZeroGroup(ZM,true);
	fi;

	SetMultiplicativeZero(ZM,z);

	Fam!.injection := Immutable(MagmaHomomorphismByFunctionNC(M, ZM, coerce));
	Fam!.zero := Immutable(z);
	return Fam!.injection;
end);

#############################################################################
##
#M  Size( <S> ) 
##
InstallMethod( Size,
    "method for a magma with a zero adjoined",
    true,
    [ IsMagma and HasMultiplicativeZero ], 0,
    function(s)
      local sizeofs,m,fam,z;

			# if the magma has a zero, but it is not a magma with
			# a zero adjoined then this method does not apply
			z := MultiplicativeZero( s );
			if not( IsMagmaWithMultiplicativeZeroAdjoinedElementRep( z ) ) then
				TryNextMethod();
			fi; 

			# get the magma underlying s		
			fam := ElementsFamily( FamilyObj (s ) );
			m := fam!.underlyingMagma;
	
      sizeofs:=Size(m) + 1;

      return sizeofs;
    end);

#############################################################################
##
#M  <elm> * <elm>
##
##  returns the product of two elements of a magma with a zero adjoined
InstallMethod( \*,
    "for two elements of a magma with zero adjoined",
    IsIdenticalObj,
    [ IsMagmaWithMultiplicativeZeroAdjoinedElementRep, 
			IsMagmaWithMultiplicativeZeroAdjoinedElementRep ], 0,
function ( elm1, elm2 )

	if elm1!.IsTheZero or elm2!.IsTheZero then	
		return MultiplicativeZeroOp(elm1);
	else
		# compute the product in the underlying magma and then
		# inject back into the zeromagma
		return (elm1!.UnderlyingElement * elm2!.UnderlyingElement)^ 
				(FamilyObj(elm1)!.injection);
	fi;
		
end );



#############################################################################
##
#M  <elm> = <elm>
##
##  decides equality of two elements of a magma with zero adjoined
##
InstallMethod( \=,
    "for two elements of a magma with zero adjoined",
    IsIdenticalObj,
    [ IsMagmaWithMultiplicativeZeroAdjoinedElementRep, 
			IsMagmaWithMultiplicativeZeroAdjoinedElementRep ], 0,
function ( elm1, elm2 )

	if elm1!.IsTheZero and elm2!.IsTheZero then	
		return true;
	elif elm1!.IsTheZero or elm2!.IsTheZero  then 
		# only one is zero
		return false;
	else
		# compute in the underlying magma 
		return (elm1!.UnderlyingElement = elm2!.UnderlyingElement);
	fi;
		
end );

############################################################################
##
#M  <eltz> < <eltz> .. for magma with a zero adjoined
##
##  Ordering of the underlying magma with zero less than everything else
## 

InstallMethod(\<, 
"for elements of magmas with 0 adjoined", 
IsIdenticalObj,
[ IsMagmaWithMultiplicativeZeroAdjoinedElementRep, 
IsMagmaWithMultiplicativeZeroAdjoinedElementRep ], 0,
function ( elm1, elm2 )

	if elm1!.IsTheZero and elm2!.IsTheZero then						# 0 0 
		return false;
	elif elm2!.IsTheZero then 														# 1 0
		return false;
	elif elm1!.IsTheZero and not(elm2!.IsTheZero)  then 	# 0 1
		return true;
	else
		# compute in the underlying magma 
		return (elm1!.UnderlyingElement < elm2!.UnderlyingElement);
	fi;
		
end );

############################################################################
##
#A  Print(<elz>)
##
##  Print the element 
##

InstallMethod(PrintObj, "for elements of magmas with 0 adjoined", true,
[IsMagmaWithMultiplicativeZeroAdjoinedElementRep], 0, 
function(x) 
				if x!.IsTheZero then
					Print("0");
				else
					Print(x!.UnderlyingElement);
				fi;
end);


#############################################################################
##
#E

