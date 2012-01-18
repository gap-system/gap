#############################################################################
##
#W abelaut.gi                    Polycyc                         Bettina Eick
##

ReduceMatMod := function( mat, exp )
    local i, j;
    for i in [1..Length(mat)] do
        for j in [1..Length(mat)] do
            mat[i][j] := mat[i][j] mod exp[j];
        od;
    od;
end;

InstallGlobalFunction( APEndoNC, function( mat, exp, p )
    local elm, type;
    elm := rec( mat := mat, dim := Length(mat), exp := exp, prime := p);
    type := NewType( APEndoFamily, IsAPEndoRep );
    return Objectify(type, elm );
end );

InstallGlobalFunction( APEndo, function( mat, exp, p )
    if Length(mat) <> Length(mat[1]) then return fail; fi;
    if Length(mat) <> Length(exp) then return fail; fi;
    ReduceMatMod( mat, exp );
    return APEndoNC( mat, exp, p);
end );

IdentityAPEndo := function( exp, p )
    return APEndoNC( IdentityMat(Length(exp)), exp, p );
end;

ZeroAPEndo := function(exp, p)
    return APEndoNC( NullMat(Length(exp), Length(exp)), exp, p );
end;

InstallMethod( PrintObj, "", true, [IsAPEndo], SUM_FLAGS, function(auto)
    local i;
    for i in [1..auto!.dim] do
        Print(auto!.mat[i], "\n");
    od;
    Print(Concatenation(List([1..auto!.dim], x -> "----")),"\n");
    Print(auto!.exp);
end);

InstallMethod( ViewObj, "", true, [IsAPEndo], SUM_FLAGS, function(auto)
    Print("APEndo of dim ",auto!.dim," mod ",auto!.exp);
end);

InstallMethod( \=, "", IsIdenticalObj, [IsAPEndo, IsAPEndo], 0,
function( auto1, auto2 )
    return 
       auto1!.prime = auto2!.prime and
       auto1!.exp = auto2!.exp and
       auto1!.mat = auto2!.mat;
end );
      
InstallMethod( \+, "", IsIdenticalObj, [IsAPEndo, IsAPEndo], 0,
function( auto1, auto2 )
    local mat;
    if auto1!.exp <> auto2!.exp then TryNextMethod(); fi;
    if auto1!.prime <> auto2!.prime then TryNextMethod(); fi;
    mat := auto1!.mat + auto2!.mat;
    ReduceMatMod( mat, auto1!.exp);
    return APEndoNC( mat, auto1!.exp, auto1!.prime );
end);

InstallMethod( \-, "", IsIdenticalObj, [IsAPEndo, IsAPEndo], 0,
function( auto1, auto2 )
    local mat;
    if auto1!.exp <> auto2!.exp then TryNextMethod(); fi;
    if auto1!.prime <> auto2!.prime then TryNextMethod(); fi;
    mat := auto1!.mat - auto2!.mat;
    ReduceMatMod( mat, auto1!.exp);
    return APEndoNC( mat, auto1!.exp, auto1!.prime );
end);

InstallMethod( ZeroOp, "", [IsAPEndo], 0,
function( auto )
    return ZeroAPEndo( auto!.exp, auto!.prime);
end);

InstallMethod( AdditiveInverseOp, "", [IsAPEndo], 0,
function( auto )
    local mat;
    mat := -auto!.mat;
    ReduceMatMod( mat, auto!.exp);
    return APEndoNC( mat, auto!.exp, auto!.prime );
end);

InstallMethod( OneOp, "", [IsAPEndo], 0,
function( auto )
    return IdentityAPEndo( auto!.exp, auto!.prime);
end);

InstallMethod( \*, "", IsIdenticalObj, [IsAPEndo, IsAPEndo], 0,
function( auto1, auto2 )
    local mat;
    if auto1!.exp <> auto2!.exp then TryNextMethod(); fi;
    if auto1!.prime <> auto2!.prime then TryNextMethod(); fi;
    mat := auto1!.mat * auto2!.mat;
    ReduceMatMod( mat, auto1!.exp);
    return APEndoNC( mat, auto1!.exp, auto1!.prime );
end);

InstallOtherMethod( \[\], "", true, [IsAPEndo, IsPosInt], 0,
function( auto, i ) return auto!.mat[i];   end );

InstallOtherMethod( ELMS_LIST, "", true, [IsAPEndo, IsDenseList], 0,
function( auto, l ) return auto!.mat{l};   end );

#InstallMethod( InverseOp, "", [IsAPEndo], 0,
#function( auto )
#end);



