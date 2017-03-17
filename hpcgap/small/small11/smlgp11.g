#############################################################################
##
#W  smlgp11.g                GAP group library             Hans Ulrich Besche
##                                               Bettina Eick, Eamonn O'Brien
##
##  This file contains the function to extract the data of the stored groups
##  of order p^7 for p in { 3, 5, 7, 11 } created by Eamonn O'Brien and 
##  Mike Vaughan-Lee.
##  
##  The data for these groups are stored 'small/small11/sml<n>.z' defining
##  entries of SMALL_GROUP_LIB[ n ] for n in {41,47,59,73}. Each such entry
##  is a record with the following components: 'heads', 'arraytails', 
##  'regtails', 'regsegms', 'pntr' and 'index'. Components 'arraytails', 
##  'regtails' and 'index' are compressed and may be modified in the future
##  if they need unpacking. Components 'heads', 'regsegms' and 'pntr' are 
##  remaining unchanged.
##

#############################################################################
##
## tell GAP about the component
##
DeclareComponent("small11","0.1");

#############################################################################
##
#F SMALL_AVAILABLE_FUNCS[ 11 ]
##
SMALL_AVAILABLE_FUNCS[ 11 ] := function( size )
    local p;

    p := FactorsInt( size );

    if Length( p ) <> 7 or p[ 1 ] = 2 or Length( Set( p ) ) > 1 then
        return fail;
    fi;

    return rec( func := 26,
                lib  := 11,
        p    := p[ 1 ] );
end;

#############################################################################
##
#F SMALL_GROUP_FUNCS[ 26 ]( size, i, inforec )
##
## p ^ 7, p <> 2
##
SMALL_GROUP_FUNCS[ 26 ] := function( size, i, inforec )
    local n, p, sml, l, j, lb, ub, tail, d, pn, m, h, fix_exps, var_exps, f,
          c, e, g, UnpackArraytail;

    UnpackArraytail := function( pn )
        # this function unpacks one element of the 'arraytails' component
        # of SMALL_GROUP_LIB[ n ] record for n in {41,47,59,73} (defined
        # in small/small11/sml<n>.z files). 
        # It is called only if sml.arraytails[ pn ] is an integer and 
        # replaces sml.arraytails[ pn ] by the record (with components 
        # named d, perm, width, inc, n), which will not be changed any more.
        l := sml.arraytails[ pn ];
        d := l mod 6;
        sml.arraytails[ pn ] := rec( d := d );
        l := Int( l / 6 );
        sml.arraytails[ pn ].perm :=
                      CoefficientsMultiadic( [ 1 .. d ] * 0 + d, l );
        l := Int( l / d^d );
        sml.arraytails[ pn ].width :=
                  CoefficientsMultiadic( [ 1 .. d ] * 0 + p, l ) + 1;
        l := Int( l / p^d );
        sml.arraytails[ pn ].inc :=
                      CoefficientsMultiadic( [ 1 .. d ] * 0 + p, l );
        sml.arraytails[ pn ].n := Product( sml.arraytails[ pn ].width );
        sml.arraytails[ pn ] := AtomicRecord( `sml.arraytails[ pn ] );
    end;

    if not IsBound( inforec.number ) then
        inforec := NUMBER_SMALL_GROUPS_FUNCS[ 26 ]( size, inforec );
    fi;
    n := inforec.number;
    if i > n then
        Error( "there are just ", n, " groups of size ", size );
    fi;
    p := inforec.p;
    if p > 11 then
        Error( "sorry, but groups of size p^7 are available for p<=11 only" );
    fi;

    # for p=3,5,7,10 we have Primes[ p + 10 ] equal to 41, 47, 59, 73,
    # hence the numbers of SMALL_GROUP_LIB entries and filenames in small11
    sml := Primes[ p + 10 ];
    if not IsBound( SMALL_GROUP_LIB[ sml ] ) then
        ReadSmallLib( "sml", 11, sml, [ ] );
    fi;
    sml := SMALL_GROUP_LIB[ sml ];
    ub := Length( sml.heads );

    atomic readwrite sml.index, sml.arraytails, sml.regtails do 

    # unpack index if required
    if Length( sml.index ) <> Length( sml.heads ) then
        l := sml.index;
        # now replace sml.index by unpacked list 
        # (which may be changed in the future)
        sml.index := [];
        for j in [ 1 .. Length( l ) ] do
             sml.index[ Int( j / Length( l ) * ub ) ] := l[ j ];
        od;
    fi;
    
    # search segment by divide et impera
    lb := 0;
    m := Int( ub / 2 );
    while ub > lb + 1 and IsBound( sml.index[ m ] ) do
        m := Int( ( lb + ub ) / 2 );
        if IsBound( sml.index[ m ] ) then
            if i <= sml.index[ m ] then
                ub := m;
            else
                lb := m;
            fi;
        fi;
    od;

    # search segment through list
    repeat 
        lb := lb + 1;
        if not IsBound( sml.index[ lb ] ) then
            pn := sml.pntr[ lb ];
            if pn < 0 then
                if IsInt( sml.arraytails[ -pn ] ) then
                    # unpack sml.arraytails if required
                    UnpackArraytail( -pn );
                fi;
                # adjust sml.index 
                sml.index[ lb ] := sml.index[ lb-1 ] + sml.arraytails[-pn].n;
            else
                tail := sml.regtails[ pn ];
                l := Length( tail );
                # adjust sml.regtails[ pn ] if required
                if tail[ l ] < 0 then
                    tail[ l ] := sml.regsegms[ -tail[ l ] ];
                fi;
                if p = 3 and tail[ l ] <= 81 then
                    l := l * 4 - 3;
                elif p = 3 and tail[ l ] <= 6723 then
                    l := l * 4 - 2;
                elif p = 3 and tail[ l ] <= 551367 then
                    l := l * 4 - 1;
                elif p = 3 then
                    l := l * 4;
                elif p = 5 and tail[ l ] <= 625 then
                    l := l * 3 - 2;
                elif p = 5 and tail[ l ] <= 391875 then
                    l := l * 3 - 1;
                elif p = 5 then
                    l := l * 3;
                elif ( p = 7 and tail[ l ] <= 2401 ) or 
                     ( p = 11 and tail[ l ] <= 14641 ) then
                    l := l * 2 - 1;
                elif p = 7 or p = 11 then
                    l := l * 2;
                fi;
                # adjust sml.index again
                if lb = 1 then
                    sml.index[ 1 ] := l;
                else
                    sml.index[ lb ] := sml.index[ lb - 1 ] + l;
                fi;
            fi;
        fi;
    until i <= sml.index[ lb ];

    # unpack head (or rather *decode* head, since this does not 
    # modify sml.heads[lb], which is an integer)
    h := sml.heads[ lb ];
    if h < 0 then
        h := sml.heads[ -h ];
    fi;
    fix_exps := [ 1 .. 56 ] * 0;
    var_exps := [];
    while h > 0 do
        m := CoefficientsMultiadic( [ p, 57 ], h );
        if m[ 1 ] = 0 then
            Add( var_exps, m[ 2 ] );
        else
            fix_exps[ m[ 2 ] ] := m[ 1 ];
        fi;
        h := Int( h / 57 / p );
    od;

    if lb > 1 then
        i := i - sml.index[ lb - 1 ];
    fi;
    if sml.pntr[ lb ] > 0 then
        # find missing exponents in regular tail
        tail := sml.regtails[ sml.pntr[ lb ] ];
        l := [ ,,4,,3,,2,,,,2 ];
        if IsBound( l[ p ] ) then 
            l := l[ p ];
        else 
            l := 1;
        fi;
        m := Int( ( i - 1 ) / l ) + 1;
        if tail[ m ]  < 0 then
            # where tail = sml.regtails[ sml.pntr[ lb ] ]
            tail[ m ] := sml.regsegms[ -tail[m] ];
        fi;
        m := CoefficientsMultiadic( [ p, p, p, p ], Int( tail[ m ] /
                      ( p^4 + 1 )^( ( i - 1 ) mod l ) ) mod ( p^4 + 1 ) -1 );
        for i in [ 1 .. Length( var_exps) ] do
            fix_exps[ var_exps[ i ] ] := m[ 5 - i ];
        od;
    else
        # find missing exponents in array tail
        if IsInt( sml.arraytails[ -sml.pntr[ lb ] ] ) then
            # unpack sml.arraytails if required
            UnpackArraytail( -sml.pntr[ lb ] );
        fi;
        tail := sml.arraytails[ -sml.pntr[ lb ] ];
        SortParallel( ShallowCopy( tail.perm ), var_exps );
        m := CoefficientsMultiadic( tail.width, i - 1 ) + tail.inc;
        for i in [ 1 .. Length( var_exps) ] do
            fix_exps[ var_exps[ i ] ] := m[ i ];
        od;
    fi;

    ShareSpecialObj(sml.index);
    od; # atomic readwrite sml.index, sml.arraytails, sml.regtails

    # now fix_exps is reconstructed and we may create the group
    
    f := FreeGroup( 7 );
    c := CombinatorialCollector( f, [p,p,p,p,p,p,p] );
    e := fix_exps;
    
    SetPower( c,1,f.2^e[1]*f.3^e[2]*f.4^e[3]*f.5^e[4]*f.6^e[5]*f.7^e[6] );
    SetPower( c,2,f.3^e[7]*f.4^e[8]*f.5^e[9]*f.6^e[10]*f.7^e[11] );
    SetPower( c,3,f.4^e[12]*f.5^e[13]*f.6^e[14]*f.7^e[15] );
    SetPower( c,4,f.5^e[16]*f.6^e[17]*f.7^e[18] );
    SetPower( c,5,f.6^e[19]*f.7^e[20] );
    SetPower( c,6,f.7^e[21] );
    SetCommutator( c,2,1,f.3^e[22]*f.4^e[23]*f.5^e[24]*f.6^e[25]*f.7^e[26] );
    SetCommutator( c,3,1,f.4^e[27]*f.5^e[28]*f.6^e[29]*f.7^e[30] );
    SetCommutator( c,4,1,f.5^e[31]*f.6^e[32]*f.7^e[33] );
    SetCommutator( c,5,1,f.6^e[34]*f.7^e[35] );
    SetCommutator( c,6,1,f.7^e[36] );
    SetCommutator( c,3,2,f.4^e[37]*f.5^e[38]*f.6^e[39]*f.7^e[40] );
    SetCommutator( c,4,2,f.5^e[41]*f.6^e[42]*f.7^e[43] );
    SetCommutator( c,5,2,f.6^e[44]*f.7^e[45] );
    SetCommutator( c,6,2,f.7^e[46] );
    SetCommutator( c,4,3,f.5^e[47]*f.6^e[48]*f.7^e[49] );
    SetCommutator( c,5,3,f.6^e[50]*f.7^e[51] );
    SetCommutator( c,6,3,f.7^e[52] );
    SetCommutator( c,5,4,f.6^e[53]*f.7^e[54] );
    SetCommutator( c,6,4,f.7^e[55] );
    SetCommutator( c,6,5,f.7^e[56] );

    g := GroupByRwsNC( c );
    SetIsPGroup( g, true );
    return g;
end;

#############################################################################
##
#F SELECT_SMALL_GROUPS_FUNCS[ 26 ]( funcs, vals, inforec, all, id )
##
SELECT_SMALL_GROUPS_FUNCS[ 26 ] := SELECT_SMALL_GROUPS_FUNCS[ 11 ];

#############################################################################
##
#F NUMBER_SMALL_GROUPS_FUNCS[ 26 ]( size, inforec )
##
## p ^ 7, p <> 2
##
NUMBER_SMALL_GROUPS_FUNCS[ 26 ] := function( size, inforec )
    local p;

    p := inforec.p;
    if p = 3 then inforec.number := 9310;
    elif p = 5 then inforec.number := 34297;
    else
        inforec.number :=
        3 * p^5 + 12 * p^4 + 44 * p^3 + 170 * p^2 + 707 *p + 2455
          + ( 4 * p^2 + 44 * p + 291 ) * Gcd( p-1, 3 )
          + ( p^2 + 19 * p + 135 ) * Gcd( p-1, 4 )
          + ( 3 * p + 31 ) * Gcd( p-1, 5 )
          + 4 * Gcd( p-1, 7 )
          + 5 * Gcd( p-1, 8 )
          + Gcd( p-1, 9 );
    fi;
    return inforec;
end;

