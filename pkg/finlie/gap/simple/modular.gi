
# The modular simple Lie algebras over GF(2)
# Farnsteiner, Strade `Modular Lie algebras and their representations`
# (The contact algebra corresponds to a Hamiltonian algebra over GF(2))

ModularSimpleLieAlgebra := function( type, n )
    local L, I, c;

    # type W = Witt algebra (n1, ..., nl) 
    if type = "W" then
        L := SimpleLieAlgebra( "W", n, GF(2) );
        if Length(n) = 1 then L := LieDerivedSubalgebra(L); fi;
    fi;

    # type S = Special algebra <= Witt algebra (n1, ..., nl)
    if type = "S" then
        L := SimpleLieAlgebra( "S", n, GF(2) );
        if Length(n) = 2 then L := LieDerivedSubalgebra(L); fi;
        if Length(n) = 2 and 1 in n then 
            I := IdealByGenerators(L, GeneratorsOfAlgebra(L){[1]});
            L := L/I;
        fi;
    fi;

    # type H: Hamiltonian algebra <= Witt algebra (n1, ..., nl), l gerade
    if type = "H" then
        L := SimpleLieAlgebra( "H", n, GF(2) );
        if Length(n) = 2 and 1 in n then
            I := IdealByGenerators(L, GeneratorsOfAlgebra(L){[1]});
            L := L/I;
        fi;
    fi;

    SetName( L, Concatenation( type, String(n) ) );
    return L;
end;

ModularSimpleLieAlgebras := function(limit)
    local all, n, par, parW, parS, parH, parK;

    all := [];
    par := Concatenation( List( [2..LogInt(limit,2)+1], Partitions ) );

    # type W and partitions of length 1 - Zassenhaus
    parW := Filtered( par, x -> Length(x) = 1 );
    parW := Filtered( parW, x -> 2^Sum(x)-1 <= limit );
    for n in parW do Add(all, ModularSimpleLieAlgebra( "W", n ) ); od;

    # type W and partitions of length > 1 - Witt
    parW := Filtered( par, x -> Length(x) > 1 );
    parW := Filtered( parW, x -> Length(x)*2^Sum(x) <= limit );
    for n in parW do Add(all, ModularSimpleLieAlgebra( "W", n ) ); od;

    # type S and partitions of length 2 without 1
    parS := Filtered( par, x -> Length(x) = 2 and not 1 in x);
    parS := Filtered( parS, x -> 2^Sum(x)-2 <= limit );
    for n in parS do Add(all, ModularSimpleLieAlgebra( "S", n ) ); od;

    # type S and partitions of length > 2
    parS := Filtered( par, x -> Length(x) > 2);
    parS := Filtered( parS, x -> (Length(x)-1)*(2^Sum(x)-1) <= limit );
    for n in parS do Add(all, ModularSimpleLieAlgebra( "S", n ) ); od;

    # type H # Problem mit Permutations
    parH := Filtered( par, x -> Length(x) > 2);
    parH := Filtered( parH, x -> IsInt(Length(x)/2));
    parH := Filtered( parH, x -> 2^Sum(x)-2 <= limit );
    for n in parH do Add(all, ModularSimpleLieAlgebra( "H", n ) ); od;

    Sort( all, function(a,b) return Dimension(a)<Dimension(b); end );
    return all;
end;

