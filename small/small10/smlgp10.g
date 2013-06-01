#############################################################################
##
#W  smlgp10.g                GAP group library             Hans Ulrich Besche
##                                               Bettina Eick, Eamonn O'Brien
##
##  This file contains the construction for groups of squarefree order and 
##  for all groups of cubefree order up to 50000 not contained in lower
##  layers of the small groups library.
##

#############################################################################
##
## tell GAP about the component
##
DeclareComponent("small10","0.2");

#############################################################################
##
#F SMALL_AVAILABLE_FUNCS[ 10 ]
##
SMALL_AVAILABLE_FUNCS[ 10 ] := function( size )
    local p;

    p := FactorsInt( size );

    if p = Set( p ) then
        return rec( func := 24,
                    primes := p,
                    lib := 10 );
    fi;

    if size > 50000 then
        return fail;
    fi;

    if Maximum( List( Collected( p ), x -> x[ 2 ] ) ) > 2 then
        return fail;
    fi;

    return rec( func := 25,
                lib  := 10 );
end;

#############################################################################
##
#F SMALL_GROUP_FUNCS[ 24 ]( size, i, inforec )
##
## squarefree, not contained in lower layers
##
SMALL_GROUP_FUNCS[ 24 ] := function( size, i, inforec )
    local n, set, primes, kpr, f, c, op_indices, j, op_index, lc, op, s, k, 
          root;

    if i = 1 then
        return AbelianGroup( inforec.primes );
    fi;

    if not IsBound( inforec.number ) then
        inforec := NUMBER_SMALL_GROUPS_FUNCS[ 24 ]( size, inforec );
    fi;
    n := inforec.number;
    if i > n then
        Error( "there are just ", n, " groups of size ", size );
    fi;

    # select the proper set of groups (all groups in one set have same socle)
    set := 1;
    while inforec.sets[ set ].number < i do
        i := i - inforec.sets[ set ].number;
        set := set + 1;
    od;
    set := inforec.sets[ set ];

    primes := inforec.primes;
    kpr := primes{ set.kp };

    f := FreeGroup( Length( primes ) );
    c := SingleCollector( f, primes );

    # find the index for the operation of every p-component
    op_indices := CoefficientsMultiadic( set.kp_n_ops, i - 1 ) + 1;

    # run through every p-component of K and build up the operation
    for j in [ 1 .. Length( kpr ) ] do
        op_index := op_indices[ j ];

        # the operation on the "leading coefficient" is allways "1", thus
        # finding the right operation is technical
        lc := 1;
        while kpr[ j ] ^ (lc - 1) < op_index do
            op_index := op_index - kpr[ j ] ^ (lc - 1);
            lc := lc + 1;
        od;
        op := [ 1 .. set.kp_dim[ j ] ] * 0;
        op[ set.kp_dim[ j ] - lc + 1 ] := 1;
        op{[ set.kp_dim[ j ] - lc + 2 .. set.kp_dim[ j ] ]} := 
            CoefficientsMultiadic( [ 1..lc-1 ] * 0 + kpr[ j ], op_index-1 );

        # Add relations for generators s of socle and k of K
        for n in [ 1 .. Length( op ) ] do
            if op[ n ] > 0 then
                s := set.kp_op_sp[ j ][ n ];
                k := set.kp[ j ];
                root := inforec.roots[ s ] ^
                    ( ( primes[ s ] - 1 ) / primes[ k ] ) mod primes[ s ]; 
                SetConjugate( c, s, k, f.(s)^( root^op[n] mod primes [s] ) );
            fi;
        od;
    od;

    return GroupByRwsNC( c );
end;
    
#############################################################################
##
#F SMALL_GROUP_FUNCS[ 25 ]( size, i, inforec )
##
## cubefree order < 50000, not contained in lower layers
##
SMALL_GROUP_FUNCS[ 25 ] := function( size, i, inforec )
    local n, set, j, k, found, primes, F, H, mods, bigm, M, c, r, blow_up;

    blow_up := function( M, F, H )
        local N, l, mats;
        N := ShallowCopy( M );
        l := Length( Pcgs( H ) ) - Length( Pcgs( F ) );
        mats := List( [1..l], x -> IdentityMat( M.dimension, M.field ) );
        N.generators := Concatenation( N.generators, mats );
        return N;
    end;

    if not IsBound( inforec.number ) then
        inforec := NUMBER_SMALL_GROUPS_FUNCS[ 25 ]( size, inforec );
    fi;
    n := inforec.number;
    if i > n then
        Error( "there are just ", n, " groups of size ", size );
    fi;

    # find the apropriate set determined by PSL( 2, p ) and size of frattini
    # factor resp. frattini subgroup
    set := 1;
    while inforec.sets[ set ].number < i do
        i := i - inforec.sets[ set ].number;
        set := set + 1;
    od;
    set := inforec.sets[ set ];

    # fetch frattini factor F from any kind of index
    if set.size_ff = 1 then
        return PSL( 2, set.psl_p );
    elif i = 1 then
        # avoid cohomology calculations in the abelian case
        F := AbelianGroup( FactorsInt( set.size_ff ) );
    elif IsBound( set.ids ) then
        F := SMALL_GROUP_FUNCS[ set.inforec_j.func ]( set.size_ff,
                                           set.ids[ i - 1 ], set.inforec_j );
    else
        F := PcGroupCode( set.codes[ i - 1 ], set.size_ff );
    fi;

    if set.size_phi = 1 then
        primes := [ ];
    else
        primes := FactorsInt( set.size_phi );
    fi;

    # the frattini extension is uniquely determined in the given cases
    H := F;
    mods := List( primes, x -> IrreducibleModules( F, GF( x ), 1)[ 2 ] );
    for j in [ 1 .. Length( primes ) ] do
        bigm := List( mods[ j ], x -> blow_up( x, F, H ) );
        found := false;
        k := 0;
        while not found do
            k := k + 1;
            M := bigm[ k ];
            c := TwoCohomology( H, M );
            if Dimension( Image( c.cohom ) ) > 0 then
                found := true;
                r := PreImagesRepresentative( c.cohom, 
                                            Basis( Image( c.cohom ) )[ 1 ] );
                H := ExtensionSQ( c.collector, H, M, r );
            fi;
        od;
    od;

    if set.psl_p = 1 then
        return H;
    else
        return DirectProduct( PSL( 2, set.psl_p ),
                              Image( IsomorphismPermGroup( H ) ) );
    fi;
end;

#############################################################################
##
#F SELECT_SMALL_GROUPS_FUNCS[ 24 .. 25 ]( funcs, vals, inforec, all, id )
##
SELECT_SMALL_GROUPS_FUNCS[ 24 ] := SELECT_SMALL_GROUPS_FUNCS[ 11 ];
SELECT_SMALL_GROUPS_FUNCS[ 25 ] := SELECT_SMALL_GROUPS_FUNCS[ 11 ];

#############################################################################
##
#F NUMBER_SMALL_GROUPS_FUNCS[ 24 ]( size, inforec )
##
## squarefree, not contained in lower layers
##
NUMBER_SMALL_GROUPS_FUNCS[ 24 ] := function( size, inforec )
    local primes, lp, i, j, k, kp_cand, i_list, mat, kp, sp, kp_dim,
          kp_n_ops, number, kp_op_sp; 

    primes := inforec.primes;
    lp := Length( primes );

    # build up matrice of incidences for q mod p = 1
    mat := List( primes, x -> 0 * primes );
    for i in [ 1 .. lp - 1 ] do
        for j in [ i + 1 .. lp ] do
            if primes[ j ] mod primes[ i ] = 1 then
                mat[ i ][ j ] := 1;
            fi;
        od;
    od;
    kp_cand := Filtered( [ 1 .. lp ], x -> 1 in mat[ x ] );

    inforec.sets := [ rec( kp := [], number := 1 ) ];

    # run through all possible socles
    for i in [ 1 .. 2 ^ Length( kp_cand ) - 1 ] do
        i_list := 0 * primes;
        i_list{ kp_cand } := CoefficientsMultiadic( 2 + 0 * kp_cand, i );

        # choose primes for K and S
        kp := Filtered( [ 1 .. lp ], x -> i_list[ x ] = 1 );
        sp := Difference( [ 1.. lp ], kp );

        # check out dimension of p-sylow subgroups of Aut( S ) and find
        # number of different operations
        kp_dim := List( [ 1 .. Length(primes) ], x -> Sum( mat[ x ]{sp} ) );
        kp_n_ops := List( kp, x -> ( primes[ x ] ^ kp_dim[ x ] - 1 ) /
                                   ( primes[ x ] - 1 ) );
        number := Product( kp_n_ops );

        if number > 0 then
            kp_op_sp := [];
            # note which K_p might operate on which S_p
            for k in kp do
                Add( kp_op_sp, Filtered( sp, x -> mat[ k ][ x ] = 1 ) );
            od;
            Add( inforec.sets, rec( kp       := kp,
                                    kp_dim   := kp_dim{ kp },
                                    kp_n_ops := kp_n_ops,
                                    kp_op_sp := kp_op_sp,
                                    number   := number ) );
        fi;
    od;

    inforec.number := Sum( inforec.sets, x -> x.number );
    inforec.roots := List( primes, x -> PrimitiveRootMod( x ) );

    return inforec;
end;

#############################################################################
##
#F NUMBER_SMALL_GROUPS_FUNCS[ 25 ]( size, inforec )
##
## cubefree order < 50000, not contained in lower layers
##
NUMBER_SMALL_GROUPS_FUNCS[ 25 ] := function( size, inforec )
    local psl_p, psl_s,
          set,
          i, j,
          size_comp, inforec_j;

    # the next case would be PSL( 2, 59 ) of order 102660
    psl_p := [ 1, 5, 11, 13, 19, 29, 37, 43 ];
    psl_s := [ 1, 60, 660, 1092, 3420, 12180, 25308, 39732 ];

    inforec.sets := [ ];

    # run over all suitable PSL( 2, psl_p[ i ] )
    for i in Filtered( [ 1 .. 8 ], x -> IsInt( size / psl_s[ x ] ) ) do
        size_comp := size / psl_s[ i ];
        # run over all suitable orders of frattini factors of the complemtent
        for j in Filtered( DivisorsInt( size_comp ), x ->
                                Set( FactorsInt( x ) ) = 
                                Set( FactorsInt( size_comp ) ) ) do

            set := rec( psl_p := psl_p[ i ],
                        size_ff := j,
                        size_phi := size_comp / j );

            if j = 1 then
                set.number := 1;
            elif Length( FactorsInt( j ) ) <= 3 then
                # have a look at the 3-primes group library if you wish to
                # follow up the next lines
                inforec_j := SMALL_AVAILABLE( j );
                if inforec_j.func > 2 then
                    inforec_j := NUMBER_SMALL_GROUPS_FUNCS[
                                        inforec_j.func ]( j, inforec_j );
                fi;
                set.ids := [ ];
                if inforec_j.func = 3 and inforec_j.number = 2 then
                    set.ids := [ 1 ];
                elif inforec_j.func = 6 and inforec_j.number = 3 then
                    set.ids := [ 2 ];
                elif inforec_j.func in [ 5, 6 ] then
                    # A3 is out of scope
                    set.ids := [ 3 .. inforec_j.number - 1 ];
                elif inforec_j.func = 7 then
                    set.ids := [ 1 .. inforec_j.number - 1 ];
                fi;
                set.number := Length( set.ids ) + 1;
                set.inforec_j := inforec_j;

            elif j < 2000 then
                # in these cases a reference to the layers 2 and 5 is fine
                set.ids := List( IdsOfAllSmallGroups( j, IsSolvable,
                                  IsAbelian, false,
                                  FrattinifactorSize, j ), x -> x[ 2 ] );
                set.number := Length( set.ids ) + 1;
                set.inforec_j := SMALL_AVAILABLE( j );

            elif IsSet( FactorsInt( j ) ) then
                # know we observe the generic squarefree order groups
                inforec_j := NUMBER_SMALL_GROUPS_FUNCS[ 24 ]( j,
                                                  SMALL_AVAILABLE( j ) );
                set.number := inforec_j.number;
                set.ids := [ 2 .. inforec_j.number ];
                set.inforec_j := inforec_j;

            else
                # and finally we have to look in the data base of layer 10
                if not IsBound( SMALL_GROUP_LIB[ j ] ) then
                    ReadSmallLib( "col", 10, Int( j / 500 ) + 1, [ ] );
                fi;
                if SMALL_GROUP_LIB[ j ] = fail then
                    ReadSmallLib( "sml", 10, j, [ ] );
                fi;
                set.number := Length( SMALL_GROUP_LIB[ j ] ) + 1;
                set.codes := SMALL_GROUP_LIB[ j ];

            fi;
            Add( inforec.sets, set );
        od;
    od;
    inforec.number := Sum( inforec.sets, x -> x.number );

    return inforec;
end;
