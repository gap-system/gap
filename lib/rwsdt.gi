#############################################################################
##
#W  rwsdt.gi                   GAP Library                  Wolfgang Merkwitz
##
##  This file implements a deep thought collector as representation of a 
##  polycyclic collector with power/conjugate presentation.
Revision.rwsdt_gi :=
    "@(#)$Id$";


#############################################################################
##
#R  IsDeepThoughtCollectorRep( <obj> )
##
IsDeepThoughtCollectorRep := NewRepresentation(
         "IsDeepThoughtCollectorRep",
         IsComponentObjectRep,   
         ["Power", "Exponent", "Conjugate", "Generators", "DeepThoughtPols",
          "Orders", "NumberGenerators"],
         IsPowerConjugateCollector);


#############################################################################
##
#M DeepThoughtCollector( <fgrp>, <orders> )
##

InstallMethod( DeepThoughtCollector,
    true,
    [ IsFreeGroup and IsWholeFamily,
      IsList ],
    0,

function( fgrp, orders )
    local   gens;

    gens := GeneratorsOfGroup(fgrp);
    if Length(orders) > Length(gens)  then
        Error( "need ", Length(gens), " orders, not ", Length(orders) );
    fi;

    # create a new deep thought collector
    return DeepThoughtCollectorByGenerators(
        ElementsFamily(FamilyObj(fgrp)), gens, orders );

end );


#############################################################################

InstallMethod( DeepThoughtCollector,
    true,
    [ IsFreeGroup and IsWholeFamily,
      IsInt ],
    0,

function( fgrp, i )
    local   gens, orders;

    gens := GeneratorsOfGroup(fgrp);
    if  i < 0  or  i = 1  then
	Error("need zero or integer greater than ",1);
    fi;
    orders := i + 0*[1..Length(gens)];

    # create a new deep thought collector
    return DeepThoughtCollectorByGenerators(
        ElementsFamily(FamilyObj(fgrp)), gens, orders );

end );


#############################################################################
##
#M DeepThoughtCollectorByGenerators( <fam>, <gens>, <orders> )
##

InstallMethod( DeepThoughtCollectorByGenerators,
    true,
    [ IsFamily,
      IsList,
      IsList ],
    0,

function( efam, gens, orders )
    local   i,  dt,  m,  bits,  kind,  fam;

    # create the correct family
    fam := NewFamily( "PowerConjugateCollectorFamily",
                      IsPowerConjugateCollector );
    fam!.underlyingFamily := efam;

    # check the generators
    for i  in [ 1 .. Length(gens) ]  do
        if 1 <> NumberSyllables(gens[i])  then
            Error( gens[i], " must be a word of length 1" );
        elif 1 <> ExponentSyllable( gens[i], 1 )  then
            Error( gens[i], " must be a word of length 1" );
        elif i <> GeneratorSyllable( gens[i], 1 )  then
            Error( gens[i], " must be generator number ", i );
        fi;
    od;

    # construct a ddeep thoughe collector as record object
    dt := rec();

    # and a default kind
    dt.defaultKind := efam!.kinds[4];

    # set the corresponding feature later
    dt.isDefaultKind := IsInfBitsAssocWord;

    # the generators must have the default kind
    gens := ShallowCopy(gens);
    for i  in [ 1 .. Length(gens) ]  do
        if not IsInfBitsAssocWord(gens[i])  then
            gens[i] := AssocWord( dt.defaultKind, ExtRepOfObj(gens[i]) );
        fi;
    od;
    # the rhs of the powers
    dt.Power := [];

    # and the rhs of the conjugates
    dt.Conjugate := [];

    # convert into a list object
    kind := NewKind( fam, IsDeepThoughtCollectorRep and IsMutable );
    Objectify( kind, dt );

    # we need the the family
    SetUnderlyingFamily( dt, efam );

    # and the relative orders
    SetRelativeOrders( dt, ShallowCopy(orders) );

    # and the generators
    SetGeneratorsOfRws( dt, gens );
    SetNumberGeneratorsOfRws( dt, Length(gens) );

    # we haven't computed the deep thought polynomials and the generator orders
    OutdatePolycyclicCollector(dt);

    # test whether dtrws is finite and set the corresponding feature
    if  0 in RelativeOrders( dt )  then
	SetIsFinite( dt, false );
    else
	SetIsFinite( dt, true );
    fi;
    # and return
    return dt;

end );


#############################################################################
##
#M Rules( <dtrws> )
##

InstallMethod( Rules,
    "Deep Thought",
    true,
    [ IsPowerConjugateCollector and IsDeepThoughtCollectorRep ],
    0,

function( dtrws )
    local   rels,  gens,  ords,  i,  j;

    # first the power relators
    rels := [];
    gens := dtrws!.Generators;
    ords := dtrws!.Exponent;
    for i  in [ 1 .. dtrws!.NumberGenerators ]  do
	if IsBound( ords[i] )  then
            if IsBound( dtrws!.Power[i] )  then
                Add( rels, gens[i]^ords[i] / 
                           InfBits_AssocWord( dtrws!.defaultKind, 
                                              dtrws!.Power[i] ) );
            else
                Add( rels, gens[i]^ords[i] );
            fi;
	fi;
    od;

    # and now the conjugates
    for i  in [ 2 .. dtrws!.NumberGenerators ]  do
        for j  in [ 1 .. i-1 ]  do
            if IsBound( dtrws!.Conjugate[i][j] )  then
                Add( rels, gens[i]^gens[j] / 
                           InfBits_AssocWord( dtrws!.defaultKind,
                                              dtrws!.Conjugate[i][j] ) );
            else
                Add( rels, gens[i]^gens[j] / gens[i] );
            fi;
        od;
    od;

    # and return
    return rels;

end );


#############################################################################
##
#M  SetRelativeOrders( <dtrws>, <orders> )
##

InstallMethod( SetRelativeOrders, 
       true,
       [ IsDeepThoughtCollectorRep  and  IsPowerConjugateCollector, IsList ],
       0,

function( dtrws, orders )
    local  i;

    # check the orders
    for  i in orders  do
        if  not IsInt(i)  or  i < 0  or  i=1  then
            Error( "relative orders must be zero or integers greater than 1" );
	fi;
    od;
    orders := ShallowCopy(orders);
    for  i in [1..Length(orders)]  do
	if  IsBound(orders[i])  then
	    if  orders[i] = 0  then
	        Unbind(orders[i]);
	    fi;
	fi;
    od;
    dtrws!.Exponent := orders;
end   );


#############################################################################
##
#M  RelativeOrders( <dtrws> )
##

InstallMethod( RelativeOrders,
      true,
      [ IsDeepThoughtCollectorRep  and  IsPowerConjugateCollector ],
      0,

function( dtrws )
    local  orders, i;
    
    orders := ShallowCopy( dtrws!.Exponent );
    for  i in [1..Length(orders)]  do
	if  not IsBound(orders[i])  then
	    orders[i] := 0;
	fi;
    od;
    for  i in [ Length(orders)+1..dtrws!.NumberGenerators ]  do
	orders[i] := 0;
    od;
    return orders;
end
);


#############################################################################
##
#M  SetNumberGeneratorsOfRws( <dtrws>, <num> )
##

InstallMethod( SetNumberGeneratorsOfRws,
      true, 
      [ IsDeepThoughtCollectorRep  and  IsPowerConjugateCollector, IsInt ],
      0,

function( dtrws, num )
    dtrws!.NumberGenerators := num;
end
);


#############################################################################
##
#M  NumberGeneratorsOfRws( <dtrws> )
##

InstallMethod( NumberGeneratorsOfRws,
    true,
    [ IsDeepThoughtCollectorRep  and  IsPowerConjugateCollector ],
    0,

function( dtrws )
    return dtrws!.NumberGenerators;
end
);


#############################################################################
##
#M  SetGeneratorsOfRws( <dtrws>, <gens> )
##

InstallMethod( SetGeneratorsOfRws,
    true,
    [ IsDeepThoughtCollectorRep  and  IsPowerConjugateCollector, IsList ],
    0,

function( dtrws, gens )
    dtrws!.Generators := ShallowCopy(gens);
end
);


#############################################################################
##
#M  GeneratorsOfRws( <dtrws> )
##

InstallMethod( GeneratorsOfRws,
    true,
    [ IsDeepThoughtCollectorRep  and  IsPowerConjugateCollector ],
    0,

function( dtrws )
    return ShallowCopy( dtrws!.Generators );
end
);


#############################################################################
##
#M  PrintObj( <dtrws> )
##

InstallMethod( PrintObj,
    true,
    [ IsDeepThoughtCollectorRep  and  IsPowerConjugateCollector ],
    0,

function( dtrws )
    Print( "<< deep thought collector >>" );
end  );


#############################################################################
##
#M  SetPower( <dtrws>, <i>, <rhs> )
##

InstallMethod( SetPower, 
    IsIdenticalFamiliesColXXXObj,
    [ IsPowerConjugateCollector and  IsDeepThoughtCollectorRep
        and IsMutable,
      IsInt,
      IsMultiplicativeElementWithInverse ],
    0,

function( dtrws, i, rhs )
    local   fam,  m,  n,  l;

    # check the family (this cannot be done in install)
    fam := UnderlyingFamily(dtrws);
    if not IsIdentical( FamilyObj(rhs), fam )  then
        Error( "<rhs> must lie in the group of <dtrws>" );
    fi;

    # check <i>
    if i <= 0  then
        Error( "<i> must be positive" );
    fi;
    if  NumberGeneratorsOfRws(dtrws) < i  then
        Error( "<i> must be at most ", dtrws!.NumberGenerators );
    fi;
    if  not IsBound( dtrws!.Exponent[i] )  then
        Error( "generator ", i, " is torsion free" );
    fi;

    # check that the rhs is a reduced word with respect to the relative orders
    for  m in [1..NumberSyllables(rhs)]  do
        if  IsBound( dtrws!.Exponent[ GeneratorSyllable(rhs, m) ] )  and  
            ExponentSyllable(rhs, m) >= 
                dtrws!.Exponent[ GeneratorSyllable(rhs, m) ]  then
            Error("<rhs> is not reduced");
        fi;
        if  m < NumberSyllables(rhs)  then
	    if  GeneratorSyllable(rhs, m) >= GeneratorSyllable(rhs, m+1)  then
		Error("<rhs> is not reduced");
	    fi;
  	fi;
    od;

    # check that the rhs lies underneath i
    if  NumberSyllables(rhs) > 0  and  GeneratorSyllable(rhs, 1) <= i  then
	Error("illegal <rhs>");
    fi;
    
    # enter the rhs
    dtrws!.Power[i]  := ExtRepOfObj(rhs);

end );    


#############################################################################
##
#M  SetConjugate( <dtrws>, <i>, <j>, <rhs> )
##
##  required:  <i> > <j>
##

DeepThoughtCollector_SetConjugateNC := function(dtrws, i, j, rhs)

    if IsBound(dtrws!.Conjugate[i])  then
	dtrws!.Conjugate[i][j] := ExtRepOfObj(rhs);
    else
	dtrws!.Conjugate[i] := [];
	dtrws!.Conjugate[i][j] := ExtRepOfObj(rhs);
    fi;
end;


InstallMethod( SetConjugate,
    IsIdenticalFamiliesColXXXXXXObj,
    [ IsPowerConjugateCollector and  IsDeepThoughtCollectorRep
        and IsMutable,
      IsInt,
      IsInt,
      IsMultiplicativeElementWithInverse ],
    0,

function( dtrws, i, j, rhs )
    local   fam,  m,  n,  l;

    # check <i> and <j>
    if i <= 1  then
        Error( "<i> must be at least 2" );
    fi;
    if dtrws!.NumberGenerators < i  then
        Error( "<i> must be at most ", dtrws!.NumberGenerators );
    fi;
    if j <= 0  then
        Error( "<j> must be positive" );
    fi;
    if i <= j  then
        Error( "<j> must be at most ", i-1 );
    fi;

    # check that the rhs is non-trivial
    if 0 = NumberSyllables(rhs)  then
        Error( "right hand side is trivial" );
    fi;

    # check that the rhs is a reduced word with respect to the relative orders
    for  m in [1..NumberSyllables(rhs)]  do
        if  IsBound( dtrws!.Exponent[ GeneratorSyllable(rhs, m) ] )  and  
            ExponentSyllable(rhs, m) >= 
                dtrws!.Exponent[ GeneratorSyllable(rhs, m) ]  then
            Error("<rhs> is not reduced");
        fi;
        if  m < NumberSyllables(rhs)  then
	    if  GeneratorSyllable(rhs, m) >= GeneratorSyllable(rhs, m+1)  then
		Error("<rhs> is not reduced");
	    fi;
  	fi;
    od;

    # check that the rhs defines a nilpotent relation
    if  GeneratorSyllable(rhs, 1) <> i  or
        ExponentSyllable(rhs, 1) <> 1  then
    	Error("rhs does not define a nilpotent relation");
    fi;

    # install the conjugate relator
    DeepThoughtCollector_SetConjugateNC( dtrws, i, j, rhs );

end );


#############################################################################
##
#M  UpdatePolycyclicCollector( <dtrws> )
##

InstallMethod( UpdatePolycyclicCollector,
    true,
    [ IsPowerConjugateCollector and IsDeepThoughtCollectorRep ],
    0,

function( dtrws )
    local i,j;

    if  IsUpToDatePolycyclicCollector(dtrws)  then
	return;
    fi;

    # complete dtrws
    for  i in [2..dtrws!.NumberGenerators]  do
	if  not IsBound( dtrws!.Conjugate[i] )  then
	    dtrws!.Conjugate[i] := [];
	fi;
    od;

    # remove trivial rhs's
    for  i in [2..Length(dtrws!.Conjugate)]  do
	for  j in [1..i-1]  do
	    if  IsBound(dtrws!.Conjugate[i][j])  then
	        if  Length(dtrws!.Conjugate[i][j]) = 2  then
		    Unbind( dtrws!.Conjugate[i][j] );
	        fi;
	    fi;
	od;
    od;
    for  i in [1..Length(dtrws!.Generators)]  do
	    if  IsBound( dtrws!.Power[i])  then
	        if  Length(dtrws!.Power[i]) = 0  then
		    Unbind( dtrws!.Power[i] );
	        fi;
	    fi;
    od;	    

    # Compute the deep thought polynomials
    Print("computing deep thought polynomials  ...\n");
    dtrws!.DeepThoughtPols := calcreps2(dtrws!.Conjugate, 8);
    Print("done\n");

    # Compute the orders of the genrators of dtrws
    Print("computing generator orders  ...\n");
    CompleteOrdersOfRws(dtrws);
    Print("done\n");

    # reduce the coefficients of the deep thought polynomials
    ReduceCoefficientsOfRws(dtrws);

    SetFeatureObj( dtrws, IsUpToDatePolycyclicCollector, true );

end );


#############################################################################
##
#M  ReducedProduct( <dtrws>, <left>, <right> )
##

InstallMethod(ReducedProduct,
    "DeepThoughtReducedProduct",
    IsIdenticalFamiliesRwsObjObj,
    [IsPowerConjugateCollector and IsDeepThoughtCollectorRep
        and IsUpToDatePolycyclicCollector,
     IsAssocWord,
     IsAssocWord],
     0,

function(dtrws, lword, rword)
    return InfBits_AssocWord( dtrws!.defaultKind,
                              DTMultiply( ExtRepOfObj(lword), 
                                          ExtRepOfObj(rword),
                                          dtrws )  );
end   );


#############################################################################
##
#M  ReducedComm( <dtrws>, <left>, <right> )
##

InstallMethod(ReducedComm,
    "DeepThoughtReducedComm",
    IsIdenticalFamiliesRwsObjObj,
    [IsPowerConjugateCollector and IsDeepThoughtCollectorRep
        and IsUpToDatePolycyclicCollector,
     IsAssocWord,
     IsAssocWord],
     0,

function(dtrws, lword, rword)
    return InfBits_AssocWord( dtrws!.defaultKind,
                              DTCommutator( ExtRepOfObj(lword), 
                                            ExtRepOfObj(rword),
                                            dtrws )  );
end   );


#############################################################################
##
#M  ReducedLeftQuotient( <dtrws>, <left>, <right> )
##

InstallMethod(ReducedLeftQuotient,
    "DeepThoughtReducedLeftQuotient",
    IsIdenticalFamiliesRwsObjObj,
    [IsPowerConjugateCollector and IsDeepThoughtCollectorRep
        and IsUpToDatePolycyclicCollector,
     IsAssocWord,
     IsAssocWord],
     0,

function(dtrws, lword, rword)
    return InfBits_AssocWord( dtrws!.defaultKind,
                              DTSolution( ExtRepOfObj(lword), 
                                          ExtRepOfObj(rword),
                                          dtrws )  );
end   );


#############################################################################
##
#M  ReducedPower( <dtrws>, <word>, <int> )
##

InstallMethod(ReducedPower,
    "DeepThoughtReducedPower",
    IsIdenticalFamiliesRwsObjXXX,
    [IsPowerConjugateCollector and IsDeepThoughtCollectorRep
        and IsUpToDatePolycyclicCollector,
     IsAssocWord,
     IsInt],
     0,

function(dtrws, word, int)
    return InfBits_AssocWord( dtrws!.defaultKind,
                              DTPower( ExtRepOfObj(word), int, dtrws )  );
end   );


#############################################################################
##
#M  ReducedQuotient( <dtrws>, <left>, <right> )
##

InstallMethod(ReducedQuotient,
    "DeepThoughtReducedQuotient",
    IsIdenticalFamiliesRwsObjObj,
    [IsPowerConjugateCollector and IsDeepThoughtCollectorRep
        and IsUpToDatePolycyclicCollector,
     IsAssocWord,
     IsAssocWord],
     0,

function(dtrws, lword, rword)
    return InfBits_AssocWord( dtrws!.defaultKind,
                              DTQuotient( ExtRepOfObj(lword), 
                                          ExtRepOfObj(rword),
                                          dtrws )  );
end   );


#############################################################################
##
#M  ReducedConjugate( <dtrws>, <left>, <right> )
##

InstallMethod(ReducedConjugate,
    "DeepThoughtReducedConjugate",
    IsIdenticalFamiliesRwsObjObj,
    [IsPowerConjugateCollector and IsDeepThoughtCollectorRep
        and IsUpToDatePolycyclicCollector,
     IsAssocWord,
     IsAssocWord],
     0,

function(dtrws, lword, rword)
    return InfBits_AssocWord( dtrws!.defaultKind,
                              DTConjugate( ExtRepOfObj(lword), 
                                           ExtRepOfObj(rword),
                                           dtrws )  );
end   );


#############################################################################
##
#M  ReducedInverse( <dtrws>, <word> )
##

InstallMethod(ReducedInverse,
    "DeepThoughtReducedInverse",
    IsIdenticalFamiliesRwsObj,
    [IsPowerConjugateCollector and IsDeepThoughtCollectorRep
        and IsUpToDatePolycyclicCollector,
     IsAssocWord],
     0,

function(dtrws, word)
    return InfBits_AssocWord( dtrws!.defaultKind,
                              DTSolution( ExtRepOfObj(word), [], dtrws )  );
end   );



#############################################################################
##
#M  CollectWordOrFail( <dtrws>, <list>, <word> )
##
##  This is only implemented to please the generic method for GroupByRws. For
##  computations use ReducedProduct, ReducedComm etc.
##

InstallMethod(CollectWordOrFail,
    "DeepThought",
    IsIdenticalFamiliesColXXXObj,
    [IsPowerConjugateCollector  and  IsDeepThoughtCollectorRep,
     IsList,
     IsMultiplicativeElementWithInverse],
    0,

function(dtrws, l, word)
    local i,j, help, help1,ext;

    if  not IsUpToDatePolycyclicCollector(dtrws)  then
	UpdatePolycyclicCollector(dtrws);
    fi;
    if  NumberSyllables(word) = 0  then
	return true;
    fi;
    ext := ExtRepOfObj(word);
    i := 1;
    help := [];

    # reduce ext and store the result in help
    while  i < Length(ext)  do
	Append(help, [ ext[i], ext[i+1] ] );
	if  i+1 = Length(ext)  or  ext[i] >= ext[i+2]  then
	    break;
	fi;
	i := i+2;
    od;
    i := i+2;
    help1 := [];
    while  i < Length(ext)  do
	Append( help1, [ ext[i], ext[i+1] ] );
	if  i+1 = Length(ext)  or  ext[i] >= ext[i+2]  then
	    help := DTMultiply(help, help1, dtrws);
	    help1 := [];
	fi;
	i := i+2;
    od;

    # convert l into ExtRep of a word and store the result in help1
    help1 := [];
    for  i in [1..Length(l)]  do
	if  l[i] <> 0  then
	    Append( help1, [ i, l[i] ] );
	fi;
    od;
   
    # compute the product of help1 and help
    help := DTMultiply(help1, help, dtrws);

    # convert the result into an exponent vector and store the result in l
    for  i in [1..Length(l)]  do
	l[i] := 0;
    od;
    for  i in [1,3..Length(help)-1]  do
	l[ help[i] ] := help[i+1];
    od;
    return true;
end   );


#############################################################################
##
#M  ObjByExponents( <dtrws>, <exps> )
##

InstallMethod(ObjByExponents,
    "DeepThought",
    true,
    [IsPowerConjugateCollector  and  IsDeepThoughtCollectorRep,
     IsList],
    0,

function(dtrws, l)
    local res, i;

    res := [];
    for  i in [1..Length(l)]  do
	if  l[i] <> 0  then
	    Append( res, [ i, l[i] ] );
	fi;
    od;
    return InfBits_AssocWord( dtrws!.defaultKind, res );
end  );

#############################################################################
##
#E  rwsdt.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##