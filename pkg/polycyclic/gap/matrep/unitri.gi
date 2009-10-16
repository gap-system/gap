#############################################################################
##
#W  unitri.gi                  Polycyclic                       Werner Nickel
##

InfoMatrixNq := Ignore;

##
##   Test if a matrix is the identity matrix.
##
##   For non-identity matrices this is faster than comparing with an idntity
##   matrix. 
##
InstallGlobalFunction( "IsIdentityMat", function( M )
    local   zero,  one,  i,  j;
    
    zero := Zero( M[1][1] );
    one  := zero + 1;

    if Set( List( M, Length ) ) <> [Length(M)] then
        return false;
    fi;
    
    for i in [1..Length(M)] do
        if M[i][i] <> one then return false; fi;
        for j in [i+1..Length(M)] do
            if M[i][j] <> zero then return false; fi;
            if M[j][i] <> zero then return false; fi;
        od;
    od;
    return true;
end );
            
##
##   Test if a matrix is upper triangular with 1s on the diagonal.
##
InstallGlobalFunction( "IsUpperUnitriMat", function( M )
    local   one,  i;
    
    one := One( M[1][1] );
    if not IsUpperTriangularMat( M ) then return false; fi;
    
    for i in [1..Length(M)] do
        if M[i][i] <> one then return false; fi;
    od;
    
    return true;
end );

##
##    The weight of an upper unitriangular matrix is the number of diagonals
##    above the main diagonal that contain only zeroes.
##
InstallGlobalFunction( "WeightUpperUnitriMat", function( M )
    local   n,  s,  i,  w;
    
    n := Length(M); w := 0; s := 1;
    while s < n do
        s := s+1;
        for i in [1..n-s+1] do 
            if M[i][i+s-1] <> 0 then return w; fi;
        od;
        w := w+1;
    od;
    return w;
end );

##
##    UpperDiagonal() returns the <s>-th diagonal above the main diagonal of
##    the matrix <M>.
##
InstallGlobalFunction( "UpperDiagonalOfMat", function( M, s )
    local   d,  i;
    
    d := [];
    for i in [1..Length(M)-s] do d[i] := M[i][i+s]; od;
    return d;
end );

##
##    Initialise a new level for the recursive sifting structure.
##
##    At each level we store matrices of the apprpriate weight and for each
##    matrix its inverse and the diagonal of the correct weight.
##
InstallGlobalFunction( "MakeNewLevel", function( w )
    
    InfoMatrixNq( "#I  MakeNewLevel( ", w, " ) called\n" );
    return rec( weight :=   w,
                matrices := [],
                inverses := [],
                diags :=    [] );
end );

##
##    When a matrix was added to a level of the sifting structure, then
##    commutators with this matrix and the generators of the group have to be
##    computed and sifted in order to keep the sifting structure from this
##    level on closed under taking commutators.
##
##    This function computes the necessary commutators and sifts each of
##    them. 
##
InstallGlobalFunction( "FormCommutators", function( gens, level, j )
    local   C,  Mj,  i;
    
    InfoMatrixNq( "#I  Forming commutators on level ", level.weight, "\n" );
    
    Mj := level.matrices[j];
    for i in [1..Length(gens)] do
        C := Comm( Mj,gens[i] );
        if not IsIdentityMat(C) then
            if not IsBound( level.nextlevel ) then
                level.nextlevel := MakeNewLevel( level.weight+1 );
            fi;
            SiftUpperUnitriMat( gens, level.nextlevel, C );
        fi;
    od;
    return;
end );

##
##    Sift the unitriangular matrix <M> through the recursive sifting
##    structure <level>.  It is assumed that the weight of <M> is equal to or
##    larger than the weight of <level>.
##
##    This function checks, if there is a matrix N at this level such that M
##    N^k for suitable k has higher weight than M.  If N does not exist, M is
##    added to <level> and all commutators of M with the generators of the
##    group are formed and sifted.  If there is such a matrix N, then M N^k
##    is sifted through the next level.
##
InstallGlobalFunction( "SiftUpperUnitriMat", function( gens, level, M )
    local   w,  d,  h,  r,  R,  Ri,  c,  rr,  RR;
    
    w := WeightUpperUnitriMat( M );
    if w > level.weight then
        if not IsBound( level.nextlevel ) then
            level.nextlevel := MakeNewLevel( level.weight+1 );
        fi;
        SiftUpperUnitriMat( gens, level.nextlevel, M );
        return;
    fi;
    
    InfoMatrixNq( "#I  Sifting at level ", level.weight, " with " );
    
    d := UpperDiagonalOfMat( M, w+1 );
    h := 1; while h <= Length(d) and d[h] = 0 do h := h+1; od;
    
    while h <= Length(d) do
        if IsBound(level.diags[h]) then
            r  := level.diags[ h ];
            R  := level.matrices[ h ];
            Ri := level.inverses[ h ];
            c := Int( d[h] / r[h] );
            InfoMatrixNq( " ", c );
            if c <> 0 then
                d := d - c * r;
                if c > 0 then  M := Ri^c * M;
                else           M := R^(-c) * M;
                fi;
            fi;
            rr := r; r := d; d := rr;
            RR := R; R := M; M := RR;
            while r[h] <> 0 do
                c := Int( d[h] / r[h] );
                InfoMatrixNq( " ", c );
                if c <> 0 then
                    d := d - c  * r;
                    M := R^(-c) * M;
                fi;
                rr := r; r := d; d := rr;
                RR := R; R := M; M := RR;            od;
            if d <> level.diags[ h ] then
                level.diags[ h ] := d;
                level.matrices[ h ] := M;
                level.inverses[ h ] := M^-1;
                InfoMatrixNq( "\n" );
                FormCommutators( gens, level, h );
 InfoMatrixNq( "#I  continuing reduction on level ", level.weight, " with " );
            fi;
            d := r;
            M := R;
        else
            level.matrices[ h ] := M;
            level.inverses[ h ] := M^-1;
            level.diags[ h ]    := d;
            InfoMatrixNq( "\n" );
            FormCommutators( gens, level, h );
            return;
        fi;
        while h <= Length(d) and d[h] = 0 do h := h+1; od;
    od;
    InfoMatrixNq( "\n" );

    if WeightUpperUnitriMat(M) < Length(M)-1 then
        if not IsBound( level.nextlevel ) then
            level.nextlevel := MakeNewLevel( level.weight+1 );
        fi;
        SiftUpperUnitriMat( gens, level.nextlevel, M );
    fi;
end );

##
##    The subgroup U of GL(n,Z) of upper unitriangular matrices is a
##    nilpotent group.  The n-th term of the lower central series of U
##    consists of all unitriangular matrices of weight at least n-1.  This
##    defines a filtration on each subgroup of U.
##
##    This function computes this filtration for the unitriangular matrix
##    group  G. 
##   
InstallGlobalFunction( "SiftUpperUnitriMatGroup", function( G )
    local   firstlevel,  g;
 
    firstlevel := MakeNewLevel( 0 );
    for g in GeneratorsOfGroup(G) do
        SiftUpperUnitriMat( GeneratorsOfGroup(G), firstlevel, g );
    od;
    return firstlevel;
end );


##
##    Return the Z-ranks of the level of the sifting structure.
##
InstallGlobalFunction( "RanksLevels", function( L )
    local   ranks;
    
    ranks := [];
    Add( ranks, Length( Filtered( L.diags, x->IsBound(x) ) ) );
    while IsBound( L.nextlevel ) do
        L := L.nextlevel;
        Add( ranks, Length( Filtered( L.diags, x->IsBound(x) ) ) );
    od;
    return ranks;
end );

##
##    This function decomposes the given matrix <M> into the generators of
##    the sifting structure <level>.
##
InstallGlobalFunction( "DecomposeUpperUnitriMat", function( level, M )
    local   w,  d,  h,  r,  R,  c;
    
    InfoMatrixNq( "#I  Decomposition on level ", level.weight, "\n" );
    
    w := WeightUpperUnitriMat(M);
    if w = Length(M[1])-1 then return []; fi;
    if w > level.weight then
        if not IsBound( level.nextlevel ) then return false; fi;
        return DecomposeUpperUnitriMat( level.nextlevel, M );
    fi;
    
    w := [];
    d := UpperDiagonalOfMat( M, WeightUpperUnitriMat(M)+1 );
    h := 1; while h <= Length(d) and d[h] = 0 do h := h+1; od;
    
    while h <= Length(d) do
        if not IsBound( level.diags[ h ] ) then return false; fi;
        r := level.diags[ h ];
        R := level.matrices[ h ];
        if d[h] mod r[h] <> 0 then return false; fi;        
        c := Int( d[h] / r[h] );
        d := d - c * r;
        M := R^(-c) * M;
        Add( w, [[level.weight, h], c] );
        InfoMatrixNq( "#I      gen: ", h );
        InfoMatrixNq( "   coeff: ", c, "\n" );
        while h <= Length(d) and d[h] = 0 do h := h+1; od;
    od;
    
    if not IsIdentityMat( M ) then
        if not IsBound( level.nextlevel ) then return false; fi;
        h := DecomposeUpperUnitriMat( level.nextlevel, M );
        if h = false then return false; fi;
        return Concatenation( w,h );
    fi;
    return w;
end );

##     
InstallGlobalFunction( "PolycyclicGenerators", function( L )
    local   matrices,  gens,  i,  l;

    matrices := Compacted( L.matrices );
    gens := [];
    for i in [1..Length(L.diags)] do
        if IsBound( L.diags[i] ) then Add( gens, [L.weight,i] ); fi;
    od;

    l := L;
    while IsBound( l.nextlevel ) do
        l := l.nextlevel;

        Append( matrices, Compacted( l.matrices ) );

        for i in [1..Length(l.diags)] do
            if IsBound( l.diags[i] ) then Add( gens, [l.weight,i] ); fi;
        od;

    od;

    return rec( gens := gens, matrices := matrices );
end ); 

InstallGlobalFunction( "WordPolycyclicGens", function( gens, w )
    local   r,  g;

    r := ShallowCopy(w);
    for g in r do
        g[1] := Position( gens.gens, g[1] );
    od;
    return Flat( r );
end );

InstallGlobalFunction( "PresentationMatNq", function( L )
    local   matrices,  gens,  i,  l,  rels,  j,  r,  g;
    
    matrices := Compacted( L.matrices );
    gens := [];
    for i in [1..Length(L.diags)] do
        if IsBound( L.diags[i] ) then Add( gens, [L.weight,i] ); fi;
    od;

    l := L;
    while IsBound( l.nextlevel ) do
        l := l.nextlevel;

        Append( matrices, Compacted( l.matrices ) );

        for i in [1..Length(l.diags)] do
            if IsBound( l.diags[i] ) then Add( gens, [l.weight,i] ); fi;
        od;

    od;

    rels :=[];
    for j in [1..Length(matrices)] do
        rels[j] := [];
        for i in [1..j-1] do
            r := DecomposeUpperUnitriMat( L,Comm( matrices[j],matrices[i] ) );
            for g in r do
                g[1] := Position( gens, g[1] );
            od;
            rels[j][i] := r;
        od;
    od;
    
    return rec( generators := [1..Length(rels)],
                relators   := rels );
end );

InstallGlobalFunction( "PrintMatPres", function( P )
    local   r;
    
    Print( P.generators, "\n" );
    for r in P.relators do
        Print( r, "\n" );
    od;
end );


InstallGlobalFunction( "PrintNqPres", function( P )
    local   x,  CommString,  PowerString,  s,  i,  j,  r,  g;
    
    x := "x";
    
    CommString := function( j, i )
        local   s;
        
        s := "[ ";
        Append( s, x ); Append( s, String(j) ); Append( s, ", " );
        Append( s, x ); Append( s, String(i) ); Append( s, " ]" );
        return s;
    end;
    
    PowerString := function( g )
        local   s;
        
        s := "";
        Append( s, x );   Append( s, String(g[1]) );
        Append( s, "^" ); Append( s, String(g[2]) ); Append( s, "*" );
        return s;
    end;
    
        
    s := "< ";
    for i in P.generators do 
        Append(s,x); Append(s,String(i)); Append(s,","); 
    od;
    Unbind( s[ Length(s) ] );    # remove trailing comma
    
    Append( s, " | \n" );
    
    for j in P.generators do
        for i in [1..j-1] do
            r := P.relators[j][i];
            Append( s, "    " );
            Append( s, CommString( j, i ) );
            if r <> [] then Append( s, " = " ); fi;
            for g in r do
                Append( s, PowerString(g) );
            od;                                 # remove trailing asterisk
            if s[ Length(s) ] = '*' then Unbind( s[ Length(s) ] ); fi;
            Append( s, ",\n" );        
        od;
    od;
    Unbind( s[ Length(s) ] );
    Unbind( s[ Length(s) ] );    # remove trailing comma & newline
    
    Append( s, "\n>\n" );
    return s;
end );

InstallGlobalFunction( "CollectorByMatNq", function( levels )
    local   pres,  n,  coll,  j,  i;

    pres := PresentationMatNq( levels );
    
    n := Length( pres.generators );
    coll := FromTheLeftCollector( n );

    for j in [1..n] do
        for i in [1..j-1] do
            if IsBound( pres.relators[j][i] ) and 
                       pres.relators[j][i] <> [] then
                SetCommutator( coll, j, i, Flat( pres.relators[j][i] ) );
            fi;
        od;
    od;

    UpdatePolycyclicCollector( coll );

    return coll;
end );


InstallGlobalFunction( "IsomorphismUpperUnitriMatGroupPcpGroup", function( G )
    local   levs,  pcgens,  coll,  H,  images,  M,  w,  phi;

    levs := SiftUpperUnitriMatGroup( G );

    pcgens := PolycyclicGenerators( levs );
    
    coll := CollectorByMatNq( levs );
    H := PcpGroupByCollectorNC( coll );

    images := [];
    for M in GeneratorsOfGroup( G ) do
        w := DecomposeUpperUnitriMat( levs, M );
        w := WordPolycyclicGens( pcgens, w );
        Add( images, PcpElementByGenExpListNC( coll, w ) );
    od;

    phi := GroupHomomorphismByImagesNC( G, H,
                   GeneratorsOfGroup( G ), images );

    SetFeatureObj( phi, IsInjective, true );
    SetFeatureObj( phi, IsSurjective, true );

    return phi;
end );
