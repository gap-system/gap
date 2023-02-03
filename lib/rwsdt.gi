#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Wolfgang Merkwitz.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file implements a deep thought collector as representation of a
##  polycyclic collector with power/conjugate presentation.


#############################################################################
##
#R  IsDeepThoughtCollectorRep( <obj> )
##
DeclareRepresentation( "IsDeepThoughtCollectorRep",
         IsPositionalObjectRep);



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
    local   i,  dt,  type,  fam;

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

    # construct a deep thought collector as positional object
    dt := [];

    # and a default type
    dt[PC_DEFAULT_TYPE] := efam!.types[4];

    # the generators must have IsInfBitsAssocWord
    gens := ShallowCopy(gens);
    for i  in [ 1 .. Length(gens) ]  do
        if not IsInfBitsAssocWord(gens[i])  then
            gens[i] := AssocWord( dt[PC_DEFAULT_TYPE], ExtRepOfObj(gens[i]) );
        fi;
    od;
    # the rhs of the powers
    dt[PC_POWERS] := [];

    # and the rhs of the conjugates
    dt[ PC_CONJUGATES ] := List( gens, g -> [] );

    # convert into a positional object
    type := NewType( fam, IsDeepThoughtCollectorRep and IsMutable );
    Objectify( type, dt );

    # and the generators
    SetGeneratorsOfRws( dt, gens );
    SetNumberGeneratorsOfRws( dt, Length(gens) );

    # and the relative orders
    SetRelativeOrders( dt, ShallowCopy(orders) );

    # we haven't computed the deep thought polynomials and the generator orders
    OutdatePolycyclicCollector(dt);

    # test whether dtrws is finite and set the corresponding feature
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
    gens := dtrws![PC_GENERATORS];
    ords := dtrws![PC_EXPONENTS];
    for i  in [ 1 .. dtrws![PC_NUMBER_OF_GENERATORS] ]  do
        if IsBound( ords[i] )  then
            if IsBound( dtrws![PC_POWERS][i] )  then
                Add( rels, gens[i]^ords[i] /
                           InfBits_AssocWord( dtrws![PC_DEFAULT_TYPE],
                                              dtrws![PC_POWERS][i] ) );
            else
                Add( rels, gens[i]^ords[i] );
            fi;
        fi;
    od;

    # and now the conjugates
    for i  in [ 2 .. dtrws![PC_NUMBER_OF_GENERATORS] ]  do
        for j  in [ 1 .. i-1 ]  do
            if IsBound( dtrws![PC_CONJUGATES][i][j] )  then
                Add( rels, gens[i]^gens[j] /
                           InfBits_AssocWord( dtrws![PC_DEFAULT_TYPE],
                                              dtrws![PC_CONJUGATES][i][j] ) );
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
       [ IsDeepThoughtCollectorRep and IsPowerConjugateCollector, IsList ],
       0,

function( dtrws, orders )
    local  i;

    # check the orders
    for  i in orders  do
        if  (not IsInt(i)  and  i <> infinity)  or  i < 0  or  i=1  then
            Error( "relative orders must be zero or infinity or integers greater than 1" );
        fi;
    od;
    orders := ShallowCopy(orders);
    for  i in [1..Length(orders)]  do
        if  IsBound(orders[i])  then
            if  orders[i] = 0  or  orders[i] = infinity  then
                Unbind(orders[i]);
            fi;
        fi;
    od;
    dtrws![PC_EXPONENTS] := orders;
    if  Length(orders) < dtrws![PC_NUMBER_OF_GENERATORS]  or
        not IsHomogeneousList( orders )                        then
        SetIsFinite( dtrws, false );
    else
        SetIsFinite( dtrws, true );
    fi;
end   );


#############################################################################
##
#M  SetRelativeOrder( <dtrws>, <i>, <ord> )
##

InstallMethod( SetRelativeOrder,
      true,
      [ IsDeepThoughtCollectorRep and IsPowerConjugateCollector and
        IsMutable,
        IsInt,
        IsObject  ],
      0,

function( dtrws, i, ord )

    if  i <= 0  then
        Error("<i> must be positive");
    fi;
    if  i > dtrws![PC_NUMBER_OF_GENERATORS]  then
        Error( "<i> must be at most ", dtrws![PC_NUMBER_OF_GENERATORS] );
    fi;
    if  (not IsInt(ord)  and  ord <> infinity)  or  ord < 0  or  ord=1  then
        Error( "relative order must be zero or infinity or an integer greater than 1" );
    fi;
    if  ord = infinity  or  ord = 0  then
        if  IsBound( dtrws![PC_EXPONENTS][i] )  then
            Unbind( dtrws![PC_EXPONENTS][i] );
            SetIsFinite( dtrws, false );
        fi;
    else
        dtrws![PC_EXPONENTS][i] := ord;
        if  0 in RelativeOrders( dtrws )  then
            SetIsFinite( dtrws, false );
        else
            SetIsFinite( dtrws, true );
        fi;
    fi;
end   );




#############################################################################
##
#M  RelativeOrders( <dtrws> )
##

InstallMethod( RelativeOrders,"Method for Deep Thought",
      true,
      [ IsDeepThoughtCollectorRep  and  IsPowerConjugateCollector ],
      0,

function( dtrws )
    local  orders, i;

    orders := ShallowCopy( dtrws![PC_EXPONENTS] );
    for  i in [1..Length(orders)]  do
        if  not IsBound(orders[i])  then
            orders[i] := 0;
        fi;
    od;
    for  i in [ Length(orders)+1..dtrws![PC_NUMBER_OF_GENERATORS] ]  do
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
    dtrws![PC_NUMBER_OF_GENERATORS] := num;
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
    return dtrws![PC_NUMBER_OF_GENERATORS];
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
    dtrws![PC_GENERATORS] := ShallowCopy(gens);
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
    return ShallowCopy( dtrws![PC_GENERATORS] );
end
);


#############################################################################
##
#M  ViewObj( <dtrws> )
##

InstallMethod( ViewObj,
    true,
    [ IsDeepThoughtCollectorRep  and  IsPowerConjugateCollector ],
    0,

function( dtrws )
    Print( "<< deep thought collector >>" );
end  );


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
#T install a better `PrintObj' method!


#############################################################################
##
#M  SetPower( <dtrws>, <i>, <rhs> )
##

InstallMethod( SetPower,
    IsIdenticalObjFamiliesColXXXObj,
    [ IsPowerConjugateCollector and  IsDeepThoughtCollectorRep
        and IsMutable,
      IsInt,
      IsMultiplicativeElementWithInverse ],
    0,

function( dtrws, i, rhs )
    local   fam,  m;

    # check the family (this cannot be done in install)
    fam := UnderlyingFamily(dtrws);
    if not IsIdenticalObj( FamilyObj(rhs), fam )  then
        Error( "<rhs> must lie in the group of <dtrws>" );
    fi;

    # check <i>
    if i <= 0  then
        Error( "<i> must be positive" );
    fi;
    if  NumberGeneratorsOfRws(dtrws) < i  then
        Error( "<i> must be at most ", dtrws![PC_NUMBER_OF_GENERATORS] );
    fi;
    if  not IsBound( dtrws![PC_EXPONENTS][i] )  then
        Error( "no relative order is set for generator ", i );
    fi;

    # check that the rhs is a reduced word with respect to the relative orders
    for  m in [1..NumberSyllables(rhs)]  do
        if  IsBound( dtrws![PC_EXPONENTS][ GeneratorSyllable(rhs, m) ] )  and
            ExponentSyllable(rhs, m) >=
                dtrws![PC_EXPONENTS][ GeneratorSyllable(rhs, m) ]  then
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
    dtrws![PC_POWERS][i]  := ExtRepOfObj(rhs);

end );


#############################################################################
##
#M  SetConjugate( <dtrws>, <i>, <j>, <rhs> )
##
##  required:  <i> > <j>
##

BindGlobal( "DeepThoughtCollector_SetConjugateNC", function(dtrws, i, j, rhs)

    if IsBound(dtrws![PC_CONJUGATES][i])  then
        dtrws![PC_CONJUGATES][i][j] := ExtRepOfObj(rhs);
    else
        dtrws![PC_CONJUGATES][i] := [];
        dtrws![PC_CONJUGATES][i][j] := ExtRepOfObj(rhs);
    fi;
end );


InstallMethod( SetConjugate,
    IsIdenticalObjFamiliesColXXXXXXObj,
    [ IsPowerConjugateCollector and  IsDeepThoughtCollectorRep
        and IsMutable,
      IsInt,
      IsInt,
      IsMultiplicativeElementWithInverse ],
    0,

function( dtrws, i, j, rhs )
    local  m;

    # check <i> and <j>
    if i <= 1  then
        Error( "<i> must be at least 2" );
    fi;
    if dtrws![PC_NUMBER_OF_GENERATORS] < i  then
        Error( "<i> must be at most ", dtrws![PC_NUMBER_OF_GENERATORS] );
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
        if  IsBound( dtrws![PC_EXPONENTS][ GeneratorSyllable(rhs, m) ] )  and
            ExponentSyllable(rhs, m) >=
                dtrws![PC_EXPONENTS][ GeneratorSyllable(rhs, m) ]  then
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
    OutdatePolycyclicCollector( dtrws );

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
    for  i in [2..dtrws![PC_NUMBER_OF_GENERATORS]]  do
        if  not IsBound( dtrws![PC_CONJUGATES][i] )  then
            dtrws![PC_CONJUGATES][i] := [];
        fi;
    od;

    # remove trivial rhs's
    for  i in [2..Length(dtrws![PC_CONJUGATES])]  do
        for  j in [1..i-1]  do
            if  IsBound(dtrws![PC_CONJUGATES][i][j])  then
                if  Length(dtrws![PC_CONJUGATES][i][j]) = 2  then
                    Unbind( dtrws![PC_CONJUGATES][i][j] );
                fi;
            fi;
        od;
    od;
    for  i in [1..dtrws![PC_NUMBER_OF_GENERATORS]]  do
            if  IsBound( dtrws![PC_POWERS][i])  then
                if  Length(dtrws![PC_POWERS][i]) = 0  then
                    Unbind( dtrws![PC_POWERS][i] );
                fi;
            fi;
    od;

    # Compute the deep thought polynomials
    Print("computing deep thought polynomials  ...\n");
    dtrws![PC_DEEP_THOUGHT_POLS] := Calcreps2(dtrws![PC_CONJUGATES], 8, 1);
    Print("done\n");

    # Compute the orders of the generators of dtrws
    Print("computing generator orders  ...\n");
    CompleteOrdersOfRws(dtrws);
    Print("done\n");

    # reduce the coefficients of the deep thought polynomials
    ReduceCoefficientsOfRws(dtrws);

    SetFilterObj( dtrws, IsUpToDatePolycyclicCollector );

end );


#############################################################################
##
#M  ReducedProduct( <dtrws>, <left>, <right> )
##

InstallMethod(ReducedProduct,
    "DeepThoughtReducedProduct",
    IsIdenticalObjFamiliesRwsObjObj,
    [IsPowerConjugateCollector and IsDeepThoughtCollectorRep
        and IsUpToDatePolycyclicCollector,
     IsAssocWord,
     IsAssocWord],
     0,

function(dtrws, lword, rword)
    return InfBits_AssocWord( dtrws![PC_DEFAULT_TYPE],
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
    IsIdenticalObjFamiliesRwsObjObj,
    [IsPowerConjugateCollector and IsDeepThoughtCollectorRep
        and IsUpToDatePolycyclicCollector,
     IsAssocWord,
     IsAssocWord],
     0,

function(dtrws, lword, rword)
    return InfBits_AssocWord( dtrws![PC_DEFAULT_TYPE],
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
    IsIdenticalObjFamiliesRwsObjObj,
    [IsPowerConjugateCollector and IsDeepThoughtCollectorRep
        and IsUpToDatePolycyclicCollector,
     IsAssocWord,
     IsAssocWord],
     0,

function(dtrws, lword, rword)
    return InfBits_AssocWord( dtrws![PC_DEFAULT_TYPE],
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
    IsIdenticalObjFamiliesRwsObjXXX,
    [IsPowerConjugateCollector and IsDeepThoughtCollectorRep
        and IsUpToDatePolycyclicCollector,
     IsAssocWord,
     IsInt],
     0,

function(dtrws, word, int)
    return InfBits_AssocWord( dtrws![PC_DEFAULT_TYPE],
                              DTPower( ExtRepOfObj(word), int, dtrws )  );
end   );


#############################################################################
##
#M  ReducedQuotient( <dtrws>, <left>, <right> )
##

InstallMethod(ReducedQuotient,
    "DeepThoughtReducedQuotient",
    IsIdenticalObjFamiliesRwsObjObj,
    [IsPowerConjugateCollector and IsDeepThoughtCollectorRep
        and IsUpToDatePolycyclicCollector,
     IsAssocWord,
     IsAssocWord],
     0,

function(dtrws, lword, rword)
    return InfBits_AssocWord( dtrws![PC_DEFAULT_TYPE],
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
    IsIdenticalObjFamiliesRwsObjObj,
    [IsPowerConjugateCollector and IsDeepThoughtCollectorRep
        and IsUpToDatePolycyclicCollector,
     IsAssocWord,
     IsAssocWord],
     0,

function(dtrws, lword, rword)
    return InfBits_AssocWord( dtrws![PC_DEFAULT_TYPE],
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
    IsIdenticalObjFamiliesRwsObj,
    [IsPowerConjugateCollector and IsDeepThoughtCollectorRep
        and IsUpToDatePolycyclicCollector,
     IsAssocWord],
     0,

function(dtrws, word)
    return InfBits_AssocWord( dtrws![PC_DEFAULT_TYPE],
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
    IsIdenticalObjFamiliesColXXXObj,
    [IsPowerConjugateCollector  and  IsDeepThoughtCollectorRep,
     IsList,
     IsMultiplicativeElementWithInverse],
    0,

function(dtrws, l, word)
    local i, help, help1,ext;

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
    return InfBits_AssocWord( dtrws![PC_DEFAULT_TYPE], res );
end  );
