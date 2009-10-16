SMALL_LIE_ALGEBRAS_DATA := LieTables;



SmallLieAlgebra := function ( arg )
local a;
    if Length( arg ) = 1  then
        return CallFuncList( SmallLieAlgebra, arg[1] );
    elif ForAll( arg, IsList )  then
        return DirectSumOfAlgebras( List( arg, x->SmallLieAlgebra(x) ) );
    fi;
    a := ShallowCopy(arg);
if not IsBound(a[4]) then a[4]:=[];fi;
#    if parameters ...
    return LieAlgebraByStructureConstants( a[1],
       SMALL_LIE_ALGEBRAS_DATA( a[1], a[2], a[4] )[1][a[3]] );
end;



AllSmallLieAlgebras := function ( field, dimension )
    return List( SMALL_LIE_ALGEBRAS_DATA( field, dimension, [] )[1],
       x -> LieAlgebraByStructureConstants( field, x ) );
end;



OneSmallLieAlgebras := function ( arg )
    return "This function is not yet implemented ";
end;



NumberSmallLieAlgebras := function ( field, dimension )
    return Length( SMALL_LIE_ALGEBRAS_DATA( field, dimension, [] )[1] );
end;



NrSmallLieAlgebras := NumberSmallLieAlgebras;



IdSmallLieAlgebra := function ( L )
    if Length( DirectSumDecomposition( L ) ) = 1  then
        return [ LeftActingDomain( L ), Dimension( L ), LookUp( L ) ];
    else
        return List( DirectSumDecomposition( L ), IdSmallLieAlgebra );
    fi;
end;



IdLieAlgebra := IdSmallLieAlgebra;



IdsOfAllSmallLieAlgebras := function ( arg )
    return "This function is not yet implemented ";
end;



SmallLieAlgebrasInformation := function ( arg )
    return "This function is not yet implemented ";
end;



UnloadLieAlgebrasData := ReturnTrue;
