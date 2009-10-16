#############################################################################
##
#W  lieautoops.gi                Sophus package               Csaba Schneider 
##
#W This file contains some methods to deal with automorphisms of nilpotent
#W Lie algebras.
##
#H  $Id: lieautoops.gi,v 1.5 2005/08/09 17:06:07 gap Exp $

#############################################################################
##
#F NilpotentLieAutomorphism( <L>, <gens>, <imgs> )
##
## Constructs an automorphism of the nilpotent Lie algebra <L>

InstallMethod( NilpotentLieAutomorphism,
   "for nilpotent Lie algebras", true, [ IsLieNilpotentOverFp, 
	           		       IsList, IsList ], 0,

function( L, gens, imgs )
    local filter, 
          type, 
          r, 
          p, 
          mingenset, 
          mingensetimgs,
          basis, 
          basisimgs, 
          def, 
          d,
          i,
          matrix, 
          defs, 
          im, 
          rem, 
          hom;


    if not IsBound( L!.NilpotentLieAutomType ) then
        filter := IsNilpotentLieAutomorphism and IsBijective;
        type   := TypeOfDefaultGeneralMapping( L, L, filter );
        L!.NilpotentLieAutomType := type;
    else
        type := L!.NilpotentLieAutomType;
    fi;
    
    # get images correct
    r := MinimalGeneratorNumber( L );
    if IsLieCover( L ) then
        basis := Basis( L );
        defs := L!.pseudo_definitions;
    else
        basis := NilpotentBasis( L );
        defs := LieNBDefinitions( basis );
    fi;
   
    mingenset := basis{[1..r]};
    
    if gens = basis then
        basisimgs := imgs;  
        mingensetimgs := imgs{[1..r]};
    elif gens = mingenset then
        basisimgs := ShallowCopy( imgs );
        mingensetimgs := ShallowCopy( imgs );
        for d in defs do
            if d <> 0 then
                im := basisimgs[d[1]]*basisimgs[d[2]];
                rem := Coeff2Compact( Coefficients( basis, basis[d[1]]*basis[d[2]] ));
                RemoveElmList( rem[1], Length( rem[1] ));
                RemoveElmList( rem[2], Length( rem[2] ));
                for i in [1..Length( rem[1] )] do
                    im := im-rem[2][i]*basisimgs[rem[1][i]];
                od;
                Add( basisimgs, im );
                
            fi;
        od;
    else
        Info( LieInfo, 1, "W computing pcgs in PGAutomorphism \n");
        
        basisimgs := List( basis, x -> LinearCombination( 
                             RelativeBasisNC( Basis( L ), imgs ),  
                             Coefficients( RelativeBasisNC( Basis( L ), gens ), x )));
        mingensetimgs := basisimgs{[1..r]};
    fi;
    
    if basis = basisimgs then 
            matrix := IdentityMat( Dimension( L ), LeftActingDomain( L ));
        
    else   # compute matrix
        matrix := [];
        for i in basisimgs do
            Add( matrix, Coefficients( basis, i ));
        od;
    fi;
    ConvertToMatrixRep( matrix );
    matrix := Immutable( matrix );
    
    # create homomorphism

    return Objectify( type, rec( basis := basis, basisimgs := basisimgs,
                   mingenset := mingenset, mingensetimgs := mingensetimgs, 
                   matrix := matrix ));
end );



#############################################################################
##
#F IdentityNilpotentLieAutomorphism( <L> )
##
## Constructs the identity automorphism of <L>

IdentityNilpotentLieAutomorphism := function( L )
    local a;
    a := NilpotentLieAutomorphism( L, NilpotentBasis( L ), AsList( NilpotentBasis( L )));          return a;
end;



#############################################################################
##
#F PrintObj(auto)
##

InstallMethod( PrintObj,
               "for nilpotent Lie algebra automorphisms",
               true,
               [IsNilpotentLieAutomorphism],
               SUM_FLAGS,
function( auto )
    if IsBound( auto!.mat ) then 
        Print("Aut + Mat: ",auto!.basisimgs);
    else
        Print("Aut: ",auto!.basisimgs);
    fi;
end);



#############################################################################
##
#F ViewObj(auto)
##

InstallMethod( ViewObj,
               "for nilpotent Lie algebra automorphisms",
               true,
               [IsNilpotentLieAutomorphism],
               SUM_FLAGS,
function( auto )
    if IsBound( auto!.mat ) then 
        Print("Aut + Mat: ",auto!.basisimgs);
    else
        Print("Aut: ",auto!.basisimgs);
    fi;
end);



#############################################################################
##
#F \= 
##
InstallMethod( \=,
               "for nilpotent Lie algebra automorphisms",
               IsIdenticalObj,
               [IsNilpotentLieAutomorphism, IsNilpotentLieAutomorphism],
               0,
function( auto1, auto2 )
    return auto1!.matrix = auto2!.matrix;
end);



#############################################################################
##
#F ImagesRepresentative( auto, g )
##
InstallMethod( ImagesRepresentative,
               "for nilpotent Lie algebra automorphisms",
               true,
               [IsNilpotentLieAutomorphism, IsObject],
               0,
        function( auto, g )
    
        local L, b;
        
        L := Source( auto );
        b := auto!.basis;
        return LinearCombination( b, Coefficients( b, g )^auto!.matrix );
end ); 



##########################################################################
## 
#M ImagesElm
##

InstallMethod( ImagesElm,
               "for nilpotent Lie algebra automorphisms",
               true,
               [IsNilpotentLieAutomorphism, IsObject ],
               0,
        function( auto, g )
    

        return [g^auto];
end ); 



#############################################################################
##
#F PGMult( auto1, auto2 )
##

InstallMethod( PGMult, true, [IsNilpotentLieAutomorphism, 
                              IsNilpotentLieAutomorphism], 0,

function( auto1, auto2 )
    local new, aut;

    new := List( auto1!.basisimgs, x -> ImagesRepresentative( auto2, x ) );
    if IsBound( auto1!.mat ) and IsBound( auto2!.mat ) then
	aut := NilpotentLieAutomorphism( Source(auto1), auto1!.basis, new );
        aut!.mat := auto1!.mat * auto2!.mat;
    else
	aut := NilpotentLieAutomorphism( Source(auto1), auto1!.basis, new );
    fi;
    return aut;

end );



#############################################################################
##
#F CompositionMapping2( auto1, auto2 )
##

InstallMethod( CompositionMapping2,
               "for nilpotent Lie algebra automorphisms",
               true,
               [IsNilpotentLieAutomorphism, IsNilpotentLieAutomorphism],
               0,
        function( auto1, auto2 )
    return PGMult( auto2, auto1 );
end );
               
######################################################################
## 
#F \<
##

InstallMethod( \<,
               "for nilpotent Lie algebra automorphisms",
               IsIdenticalObj,
               [IsNilpotentLieAutomorphism, IsNilpotentLieAutomorphism],
               0,
function( auto1, auto2 )
    return auto1!.matrix < auto2!.matrix;
end);



#############################################################################
##
#F PGPower( n, aut )
##

InstallMethod( PGPower, true, [IsInt, IsNilpotentLieAutomorphism], 0,
function( n, aut )
    local c, l, i, j, new;

    if n <= 0 then return fail; fi;
    if n = 1 then return aut; fi;
    c := CoefficientsQadic( n, 2 );

    # create power list, if necessary 
    if not IsBound( aut!.power ) then aut!.power := []; fi;

    # add powers, if necessary
    l := Length( aut!.power );
    if l = 0 then
        new := aut;
    else
        new := aut!.power[l];
    fi;
    for i in [l+1..Length(c)-1] do
        new := PGMult( new, new );
        Add( aut!.power, new );
    od; 

    # multiply powers together
    if c[1] = 1 then
        new := [aut];
    else 
        new := [];
    fi;
    for i in [2..Length(c)] do
        if c[i] = 1 then
            Add( new, aut!.power[i-1] );
        fi;
    od;
    return PGMultList( new );
end );


#############################################################################
##
#F PGInverse( aut )
##

InstallMethod( PGInverse, true, [IsNilpotentLieAutomorphism], 0,
function( aut )
    local new, inv, L;
    
    L := Source( aut );
    
    if not IsBound( aut!.inv ) then 
        new :=  List( NilpotentBasis( L ), x -> LinearCombination( 
                             RelativeBasisNC( Basis( L ), aut!.basis ),  
                        Coefficients( RelativeBasisNC( Basis( L ), 
                                aut!.basisimgs ), x )));
        inv := NilpotentLieAutomorphism( Source( aut ), aut!.basis, new );
    else 
        inv := aut!.inv;
    fi;

    if IsBound( aut!.mat ) and not IsBound( inv!.mat) then
        inv!.mat := aut!.mat^-1;
    fi;

    aut!.inv := inv;
    return aut!.inv;
end);



#############################################################################
##
#F InverseGeneralMapping(auto)
##

InstallMethod( InverseGeneralMapping,
               "for nilpotent Lie algebra automorphism",
               true,
               [IsNilpotentLieAutomorphism],
               SUM_FLAGS,
function( auto )
    return PGInverse( auto );
end );

InstallMethod( \^,
        "for nilpotent Lie algebra automorphisms",
        true,
        [IsNilpotentLieAutomorphism, IsInt],
        0,
function( auto, exp )
	
    if exp = 0 then
        return IdentityMapping( Source( auto ));;
    elif exp > 0 then
        return Product( List( [1..exp], x -> auto ));
    else
        return Product( List( [1..-exp], x -> InverseGeneralMapping( auto )));
    fi;
    
end);
























