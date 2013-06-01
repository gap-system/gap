#############################################################################
##
#W  idgrp10.g                GAP group library             Hans Ulrich Besche
##                                               Bettina Eick, Eamonn O'Brien
##
##  This file contains the identification routines for groups of squarefree
##  order and for groups of cubefree order up to 50000.
##

#############################################################################
##
## tell GAP about the component
##
DeclareComponent("id10","0.1");

#############################################################################
##
#F ID_AVAILABLE_FUNCS[ 10 ]
##
ID_AVAILABLE_FUNCS[ 10 ] := SMALL_AVAILABLE_FUNCS[ 10 ];

#############################################################################
##
#F ID_GROUP_FUNCS[ 24 ]( G, inforec )
##
## squarefree, not contained in lower layers
##
ID_GROUP_FUNCS[ 24 ] := function( G, inforec )
    local primes, spcgs, lg, p_ind, mat, kp, m, n, k, s, im, root, set, i,
          op, op_indices, op_index;

    if IsAbelian( G ) then
         return 1;
    fi;

    if not IsBound( inforec.number ) then
        inforec := NUMBER_SMALL_GROUPS_FUNCS[ 24 ]( Size( G ), inforec );
    fi;
    primes := inforec.primes;

    # calculate special pcgs and find references towards 'primes'
    spcgs := SpecialPcgs( G );
    lg := LGWeights( spcgs );
    p_ind := [ 1 .. Length( primes ) ];
    SortParallel( List( lg, x -> x[ 3 ] ), p_ind );

    # find simultanious matrice 'mat' with operations and K by 'kp'
    mat := [];
    kp := [];
    for m in [ 1 .. Length( primes ) - 1 ] do
        k := p_ind[ m ];
        if lg[ k ][ 1 ] = 1 then
            mat[ m ] := 0 * primes;
            for n in [ m + 1 .. Length( primes ) ] do
                s := p_ind[ n ];
                if lg[ s ][ 1 ] = 2 and primes[n] mod primes[m] = 1 then
                    im := spcgs[ s ] ^ spcgs[ k ];
                    if im <> spcgs[ s ] then
                        root := inforec.roots[n] ^
                             ( ( primes[n] - 1 ) / primes[m] ) mod primes[n];
                        mat[ m ][ n ] := LogMod( LeadingExponentOfPcElement(
                                            spcgs, im ), root, primes[ n ] );
                        AddSet( kp, m );
                    fi;
                fi;
            od;
        fi;
    od;

    # find the set of groups (socles) G belongs to and initialise result 
    # counter i
    set := 2;
    i := 1;
    while inforec.sets[ set ].kp <> kp do
        i := i + inforec.sets[ set ].number;
        set := set + 1;
    od;
    set := inforec.sets[ set ];

    op_indices := [];
    for m in [ 1 .. Length( kp ) ] do

        # normalise operation of sylow_k generator and find index
        k := kp[ m ];
        op := mat[k]{ set.kp_op_sp[ m ]};
        op := op / First( op, x -> x > 0 ) mod primes [ k ];
        op_index := 1;
        for n in [ Position( op, 1 ) + 1 .. set.kp_dim[ m ] ] do 
            op_index := op_index + (op[n]+1) * primes[k] ^ (set.kp_dim[m]-n);
        od;
        Add( op_indices, op_index );
    od;

    # find overall position in set and return id
    m := op_indices[ 1 ] - 1;
    for n in [ 2 .. Length( kp ) ] do
        m := m * set.kp_n_ops[ n ] + op_indices[ n ] - 1;
    od;
    return i + m + 1;
end;

#############################################################################
##
#F ID_GROUP_FUNCS[ 25 ]( G, inforec )
##
## cubefree order < 50000, not contained in lower layers
##
ID_GROUP_FUNCS[ 25 ] := function( G, inforec )
    local per, psl_s, psl_p, phi, size_phi, i, set;

    if not IsBound( inforec.number ) then
        inforec := NUMBER_SMALL_GROUPS_FUNCS[ 25 ]( Size( G ), inforec );
    fi;

    # the perfect residuum will exhibit the PSL( 2, p ) component of G
    per := PerfectResiduum( G );
    if Size( per ) > 1 then
        G := Image( IsomorphismPcGroup( G / per ) );
    fi;
    
    psl_s := [ 1, 60, 660, 1092, 3420, 12180, 25308, 39732 ];
    psl_p := [ 1, 5, 11, 13, 19, 29, 37, 43 ];
    psl_p := psl_p[ Position( psl_s, Size( per ) ) ];

    # since the frattini extension is unique it provides no information 
    # for the identification
    phi := FrattiniSubgroup( G );
    size_phi := Size( phi );
    if size_phi > 1 then
        G := G / phi;
    fi;

    # run over all 'sets' and reduce to the identification of the frattini
    # factor for final determination
    i := 0;
    for set in inforec.sets do
        if set.psl_p <> psl_p or set.size_phi <> size_phi then
            i := i + set.number;
        elif IsAbelian( G ) then
            return i + 1;
        elif IsBound( set.ids ) then
            return i + 1 + Position( set.ids, IdGroup( G )[ 2 ] );
        else
            if not IsBound( ID_GROUP_TREE.next[ Size( G ) ] ) then
                ReadSmallLib( "ids", 10, Int( Size(G) / 500 ) + 1, [] );
            fi;
            return i + 1 + ID_GROUP_FUNCS[ 8 ]( G, rec( lib := 10 ) );
        fi;
    od;
end;
