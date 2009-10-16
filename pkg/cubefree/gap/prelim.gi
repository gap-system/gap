#############################################################################
##
#W  prelim.gi           Cubefree                               Heiko Dietrich
##
#H   @(#)$Id: prelim.gi,v 1.2 2007/05/08 07:58:50 gap Exp $
##


##############################################################################
##
#P  IsCubeFreeInt( n )
##
## return true if the integer n is cube-free
##
InstallMethod( IsCubeFreeInt,
    "for integers",  
    [ IsInt ], 0,
    n-> ForAll( Collected( FactorsInt( n ) ), x -> x[2] < 3 ) );

##############################################################################
##
#P  IsSquareFreeInt( n )
##
## returns true if the integer n is square-free
##
InstallMethod( IsSquareFreeInt,
    "for integers",
    [ IsInt ], 0,
    n-> ForAll(Collected( FactorsInt( n ) ) , x -> x[2] < 2 ) );

############################################################################# 
## 
#F  ConstructAllCFSimpleGroups( n ) 
## 
## returns all cube-free simple groups of order n up to isomorphism
##
InstallGlobalFunction( ConstructAllCFSimpleGroups, function ( size ) 
    local cl, p, A; 
 
    # check
    if not IsPosInt( size ) or  not IsCubeFreeInt( size )  then
        Error("Argument has to be a positive cube-free integer.\n");
    fi;

    if size = 1 then 
        return []; 
    elif IsPrime( size) then
        return [CyclicGroup( size )];
    fi;

    cl := List( Collected( Factors( size ) ), x -> x[1] );
    cl := Filtered( cl, x -> IsCubeFreeInt( x+1 ) and IsCubeFreeInt( x-1 ) and
                            x>3);
    for p in cl do
        if size = ( p * (p-1) * (p+1) / 2) then
            return [PSL( 2, p )];
        fi;
    od;

    return []; 
end ); 
 
############################################################################# 
## 
#F  ConstructAllCFNilpotentGroups( n ) 
## 
## returns all cube-free nilpotent groups of order n up to isomorphism
##
InstallGlobalFunction(ConstructAllCFNilpotentGroups, function ( size ) 
    local cl, p, A,arg1, arg2, G, temp, C, groups; 
 
    # check
    if not IsPosInt( size ) or  not IsCubeFreeInt( size )  then
        Error("Argument has to be a positive cube-free integer.\n");
    fi;
   
    if size = 1 then 
        return [TrivialGroup()]; 
    fi;

    cl     := Collected( FactorsInt( size ) );
    groups := [[]];
    
    for p in cl do
        temp := [];
        for G in groups do
            if p[2] = 1 then
                Add(temp, Concatenation( G, [p[1]] ) );
            else
                Add(temp, Concatenation( G, [p[1]^2] ) );
                Add(temp, Concatenation( G, [p[1] , p[1]] ) );
            fi;
        od;
        groups := ShallowCopy( temp );
    od;

    return List(groups, x -> AbelianGroup( x ) ); 
end );
