
# The classical simple Lie algebras over GF(2) up to dim 100
# See the book of Kac and Moody or the book by Willem

ClassicSimpleLieAlgebra := function( type, n )
    local L, I, c;

    if type = "A" then                            # A/Z(A) is simple
        if not n >= 2 then return fail; fi;
        L := SimpleLieAlgebra( "A", n, GF(2) );
        if not IsInt(n/2) then L := L/LieCentre(L); fi;
    fi;

    if type = "B" then                            # B/S(B) is simple
        if not n >= 3 then return fail; fi;
        L := SimpleLieAlgebra( "B", n, GF(2) );
        c := ChiefSeriesLieAlgebra(L);
        I := c[Length(c)-1];
        L := L/I;
    fi;

    if type = "C" then                            # C^(2)/Z(C^(2)) is simple
        if not n >= 3 then return fail; fi;
        L := SimpleLieAlgebra( "C", n, GF(2) );
        L := LieDerivedSeries(L)[3];
        if IsInt(n/2) then L := L/LieCentre(L); fi;
    fi;

    if type = "D" then                            # D/Z(D) is simple
        if not n >= 4 then return fail; fi;
        L := SimpleLieAlgebra( "D", n, GF(2) );
        L := L/LieCentre(L);
    fi;

    if type = "E" then                            # E is simple
        if not n in [6,7,8] then return fail; fi;
        L := SimpleLieAlgebra( "E", n, GF(2) );
    fi;
       
    if type = "F" then                            # F decomposes non-split
        if n <> 4 then return fail; fi;
        L := SimpleLieAlgebra( "F", n, GF(2) );
        I := IdealByGenerators( L, BasisVectors(Basis(L)){[1]} );
        L := L/I;
        L!.sub := I;
    fi;
       
    if type = "G" then                            # G is simple
        if n <> 2 then return fail; fi;
        L := SimpleLieAlgebra( "G", n, GF(2) );
    fi;

    SetName( L, Concatenation( type, String(n) ) );
    return L;
end;

ClassicSimpleLieAlgebras := function(limit)
    local all, n, m;

    all := [];

    # type A has dimension (n+1)^2 - 1 or (n+1)^2 - 2
    m := RootInt(limit+2);
    for n in [2..m-1] do Add(all, ClassicSimpleLieAlgebra( "A", n ) ); od;

    # types B,C,D have dimension 2(n^2+n-1) or 2(n^2+n-2)
    m := RootInt(QuoInt(limit,2)+2);
    for n in [3..m] do Add(all, ClassicSimpleLieAlgebra( "B", n ) ); od;
    for n in [3..m] do Add(all, ClassicSimpleLieAlgebra( "C", n ) ); od;
    for n in [4..m] do Add(all, ClassicSimpleLieAlgebra( "D", n ) ); od;

    if limit >=  78 then Add( all, ClassicSimpleLieAlgebra( "E", 6 ) ); fi;
    if limit >= 133 then Add( all, ClassicSimpleLieAlgebra( "E", 7 ) ); fi;
    if limit >= 248 then Add( all, ClassicSimpleLieAlgebra( "E", 8 ) ); fi;
    if limit >=  26 then Add( all, ClassicSimpleLieAlgebra( "F", 4 ) ); fi;
    if limit >=  14 then Add( all, ClassicSimpleLieAlgebra( "G", 2 ) ); fi;

    Sort( all, function(a,b) return Dimension(a)<Dimension(b); end );
    return all;
end;


