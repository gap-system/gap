#############################################################################
##
#W  idgroup.g                GAP group library             Hans Ulrich Besche
#W                                                             & Bettina Eick
##
##  This file contains the identification routine for groups of order 
##  up to 1000 without the orders 256, 512 and 768.
##
Revision.idgroup_g :=
    "@(#)$Id:";

if not IsBound( IdGroupTree ) then
    IdGroupTree := rec( fp := [ 1 .. 1000 ], next := [ ] );
fi;

#############################################################################
##
#F  IdGroupRandomTest( <G>, <list> ) . . . . . . . . . . . . . . . . . .local
##
##  <G> is the group in question and <list> is the list packed presentations
##  of the posible candidates for <G>
##
IdGroupRandomTest := function( g, c )
    local str1, str2, i, l, l1, l2, r;

    # prepare groups for guessing presentations
    str1 := PcGroupCode( c[1], Size( g ) );
    str2 := PcGroupCode( c[2], Size( g ) );

    # init lists of (numerical coded) presentations
    l  := [ ];
    l1 := [ ];
    l2 := [ ];

    # repeat until two identical presentations are found
    repeat
        r := RandomSpecialPcgsCoded( g );
        if not r in l then Add( l, r ); fi;

        r := RandomSpecialPcgsCoded( str1 );
        if r in l then return c[ 1 ]; fi;
        if not r in l1 then Add( l1, r ); fi;

        r := RandomSpecialPcgsCoded( str2 );
        if r in l then return c[ 2 ]; fi;
        if not r in l2 then Add( l2, r ); fi;

        Info( InfoIdGroup, 1, Length(l), " ", Length(l1), " ", Length(l2) );
    until false;
end;

#############################################################################
##
#F  IdGroupSpecialFp( <G>, <integer> ). . . . . . . . . . . . . . . . . local
##
##  Compute a special fingerprint.
##
IdGroupSpecialFp := function( g, i )
    local p, S, classbound, stanpres;

    p := [ 2, 3, 5, 2 ];
    S := SylowSubgroup( g, p[ i ] );

    if i in [ 1 .. 3 ] then
        Print("#W standard presentation not yet implemented \n");
        return fail;
        # compute standard presentation of S and return code without
        # order
    else 
        # investigate the operation of g on its 2-sylow subgroup
        # this fingerprint differs 2 frattinifree groups of type 2^6:7
        return Sum( List( Orbits( g, AsList( S ) ),
                          x -> Size( Subgroup( g, x ) ) ) );
    fi;
end;

#############################################################################
##
#F  EvalFpCoc( g, coc, desc ) . . . . . . . . . . . . . . . . . . . . . local
##
EvalFpCoc := function( g, coc, desc )
    local powers, exp, targets, result, i, j, g1, g2, fcd4, pos;

    if desc[ 1 ] = 1 then
        # test, if g^i in cl(g)
        return List( coc[ desc[ 2 ] ],
                     function( x )
                     if x[ 1 ] ^ desc[ 3 ] in x then return 1; fi; return 0;
                     end );

    elif desc[ 1 ] = 2 then
        # test, if cl(g) is root of cl(h)
        exp := QuoInt( Order( coc[ desc[ 2 ] ][ 1 ][ 1 ] ),
                       Order( coc[ desc[ 3 ] ][ 1 ][ 1 ] ) );
        powers := Flat( coc[ desc[ 3 ] ] );
        return List( coc[ desc[ 2 ] ],
                     function(x)
                     if x[ 1 ] ^ exp in powers then return 1; fi; return 0;
                     end );

    elif desc[ 1 ] = 3 then
        # test, if cl(g) is power of cl(h)
        exp := QuoInt( Order( coc[ desc[ 3 ] ][ 1 ][ 1 ] ),
                       Order( coc[ desc[ 2 ] ][ 1 ][ 1 ] ) );
        # just one representative for each class of power-candidates
        powers := List( coc[ desc[ 2 ] ], x -> x[ 1 ] );
        result := List( powers, x -> 0 );
        for i in List( Flat( coc[ desc[ 3 ] ] ), x -> x ^ exp ) do
            for j in [ 1 .. Length( powers ) ] do
                if i = powers[ j ] then
                    result[ j ] := result[ j ] + 1;
                fi;
            od;
        od;
        return result;

    else 
        # test how often the word [ a, b ] * a^2 is hit
        targets := List( coc[ desc[ 2 ] ], x -> x[ 1 ] );
        result := List( targets, x -> 0 );
        fcd4 := Flat( coc[ desc[ 4 ] ] );
        for g1 in Flat( coc[ desc[ 3 ] ] ) do
            for g2 in fcd4 do
                if desc[ 1 ] = 4 then 
                    pos := Position( targets, Comm( g1, g2 ) * g1 ^ 2 );
                else 
                # desc[ 1 ] = 5
                    pos := Position( targets, Comm( g1, g2 ) * g1 ^ 3 );
                fi;
                if not IsBool( pos ) then
                    result[ pos ] := result[ pos ] + 1;
                fi;
            od;
        od;
        return result;
    fi;
end;

#############################################################################
##
#F  IdSmallGroup( <G> ) . . . . . . . . . . . . . . . . . . . . . . . . local
##
##  Compute identification for <G> where |G| <= 1000 and |G| not in {256, 
##  512, 768} and |G| consists of more than 3 primes.
##
IdSmallGroup := function( G )
    local level, branch, indices, fp, elementOrders, setElOrders, l, L, i, j,
          collElOrders, coc, desc, pos, filename, ldesc, Pack, sfp, newcls,
          classes, classtyps, sclasstyps;

    # packs information from a list - with posible loos of information
    Pack := function( list )
        local r, i;

        if Length( list ) = 0 then 
            return 0;
        fi;
        list := Flat( list );
        r := list[ 1 ] mod 99661;
        for i in list{[ 2 .. Length( list ) ]} do
            r := (r * 10 + i ) mod 99661;
        od;
        return r;
    end;

    # set up
    level := 1;
    branch := IdGroupTree;
    indices := [ ];
    l := "abcdefghijklmnopqrstuvwxyz";

    # main loop
    while not IsInt( branch ) do
        
        if level = 1 then
            fp := Size( G );

        elif level = 2 then 
            fp := Pack( List( DerivedSeriesOfGroup( G )
                      {[ 2 .. Length( DerivedSeriesOfGroup( G ) ) ]}, Size ) );

        elif level = 3 then 
            if IsAbelian( G ) then 
                fp := Pack( AbelianInvariants( G ) );
            else 
                elementOrders := List( AsList( G ), x -> Order( x ) );
                setElOrders := Set( elementOrders );
                fp := Pack( setElOrders{[ 2 .. Length( setElOrders ) ]} );
            fi;

        elif level = 4 then 
            collElOrders := Collected( elementOrders );
            fp := Pack( List( collElOrders{[ 2 .. Length( collElOrders ) ]},
                              x -> x[ 2 ] ) );

        elif level = 5 then 
            # on level 5 the tests on conjugacy classes start
            classes := Orbits( G, AsList( G ) );
            classtyps := List( classes,
                               x -> [ Order( x[ 1 ] ), Length( x ) ] );
            sclasstyps := Set( classtyps );
            # coc is   Clusters Of Conjugacy   classes
            coc := List( sclasstyps, x-> [ ] );
            for i in [ 1 .. Length( sclasstyps ) ] do
                for j in [ 1 .. Length( classes ) ] do
                    if sclasstyps[ i ] = classtyps[ j ] then
                        Add( coc[ i ], classes[ j ] );
                    fi;
                od;
            od;
            
            fp := Pack( List( coc{[ 2 .. Length( coc ) ]},
                              x -> [ Length( x[ 1 ] ), Length( x ) ] ) );

        elif not IsList( branch.desc ) then
            if branch.desc = 0 then
                # this special case could apear only on level >= 6
                fp := IdGroupRandomTest( G, branch.fp );
            
            else
                # use a special fingerprint, apears just for level >= 6
                fp := IdGroupSpecialFp( G, branch.desc );
                if IsBool( fp ) then return branch; fi;
                if IsBool( fp ) then return fp; fi;
            fi;

        else
            # usuall case for level >= 6
            for desc in branch.desc do
                # reconstruct orignial description list of the test
                ldesc := [ desc mod 1000 ];
                desc := QuoInt( desc, 1000 );
                while desc > 0 do
                    Add( ldesc, desc mod 100 );
                    desc := QuoInt( desc, 100 );
                od;
                desc := Reversed( ldesc );
                
                # evaluate the test
                fp := EvalFpCoc( G, coc, desc );

                # split up clusters of classes acording to the result of test
                sfp := Set( fp );
                newcls := List( sfp, x-> [ ] );
                for i in [ 1 .. Length( sfp ) ] do
                    for j in [ 1 .. Length( fp ) ] do
                        if sfp[ i ] = fp[ j ] then
                            Add( newcls[ i ], coc[ desc[ 2 ] ][ j ] );
                        fi;
                    od;
                od;
                coc := Concatenation( coc{[ 1 .. desc[ 2 ] -1 ]}, newcls,
                                   coc{[ desc[ 2 ] + 1 .. Length( coc ) ]} );
            od;

            # make fingerprint independ from the rowing of conj-classes
            fp := Pack( Collected( fp ) );
        fi;

        pos := Position( branch.fp, fp );
        if IsBool( pos ) then
            Error( "IDGROUP: fatal Error. Please mail group to\n",
                   "Hans-Ulrich.Besche@math.rwth-aachen.de" );
        fi;
        Add( indices, pos );

        # load required branch of 'IdGroupTree' if it is not in memory
        if not IsBound( branch.next[ pos ] ) then
            filename := "";
            if Size( G ) < 10 then 
                Append( filename, "00" );
            elif Size( G ) < 100 then 
                Add( filename, '0' );
            fi;
            Append( filename, String( Size( G ) ) );
            for i in indices{[ 2 .. Length( indices ) ]} do
                if i > 26 then 
                    Add( filename, l[ QuoInt( i - 1, 26 ) ] );
                fi;
                Add( filename, l[ ( i - 1 ) mod 26 + 1 ] );
            od;
            filename := Concatenation( "id",
                filename{[ 1 .. Minimum( Length( filename ) - 1, 6 ) ]}, ".",
                filename{[ Minimum( Length( filename ), 7 ) ..
                Length( filename ) ]} );
            ReadIdLib( filename );
            Info( InfoIdGroup, 1, "IdSmallGroup reads ", filename );
        fi;

        branch := branch.next[ pos ];
        level := level + 1;
    od;

    # branch is now a integer
    return branch;
end;

#############################################################################
##
#F  IdP1Q1R1Group( <G> ). . . . . . . . . . . . . . . . . . . . . . . . local
##
##  Compute identification for <G> where |G| = p*q*r.
##
IdP1Q1R1Group := function( G )
    local  n, p, q, r, s1, s2, s3, typ, PO, A, C, AC, x, s, y, B, BC, id;

    # get primes
    n := Size(G);
    p := FactorsInt(n);
    r := p[3];
    q := p[2];
    p := p[1];

    # compute the sylow subgroups
    s1  := SylowSubgroup( G, r );
    s2  := SylowSubgroup( G, q );
    s3  := SylowSubgroup( G, p );

    if IsAbelian( G ) then
        typ := "pqr";

    elif IsNormal( G, s3 ) then
        typ := "Dqr x p";

    elif not IsAbelian( ClosureGroup( s1, s2 ) ) then
        typ := "Hpqr";

    elif IsAbelian( ClosureGroup( s1, s3 ) ) then
        typ := "Dpq x r";

    elif IsAbelian( ClosureGroup( s2, s3 ) ) then
        typ := "Dpr x q";

    else 

        # find <A> and <C>
        C  := GeneratorsOfGroup( SylowSubgroup(G,p) )[1];
        A  := GeneratorsOfGroup( SylowSubgroup(G,r) )[1];
        AC := A^C;
        PO := 0;
        s  := 1;
        while AC <> PO  do
            s := s+1;
            if s mod r <> 1 and s^p mod r = 1  then
                PO := A^s;
            fi;
        od;

        # correct <C>
        x := First( [2..r-1], t -> t mod r <> 1 and t^p mod r = 1 );
        s := LogMod( x, s, r );
        C := C^s;

        # now find <B>
        B  := GeneratorsOfGroup( SylowSubgroup(G,q) )[1];
        BC := B^C;
        PO := 0;
        s  := 1;
        while BC <> PO  do
            s := s+1;
            if s mod r <> 1 and s^p mod r = 1  then
                PO := B^s;
            fi;
        od;

        # and find <s>
        y := First( [2..q-1], t -> t mod q <> 1 and t^p mod q = 1 );
        s := LogMod( s, y, q );

        typ := s; # the typ is Gpqr( s )
    fi;

    # find the types existing for Size( g ) and count up id
    id := 1;

    if typ = "Hpqr" then
        return id;
    fi;
    if r mod (p*q) = 1 then id := id + 1; fi;

    if typ = "Dqr x p" then
        return id;
    fi;
    if r mod q = 1 then id := id + 1; fi;

    if typ = "Dpq x r" then
        return id;
    fi;
    if q mod p = 1 then id := id + 1; fi;

    if typ = "Dpr x q" then
        return id;
    fi;
    if r mod p = 1 then id := id + 1; fi;

    if IsInt( typ ) then 
        # g is Gpqr( typ )
        return  id - 1 + typ;
    fi; 
    if ( r mod p = 1 ) and ( q mod p = 1 ) then id := id + p - 1; fi;

    # remaining typ is pqr
    return id;
end;

#############################################################################
##
#F  IdP2Q1Group( <G> ). . . . . . . . . . . . . . . . . . . . . . . . . local
##
##  Compute identification for <G> where |G| = p^2*q.
##
IdP2Q1Group := function( G )
    local  n, p, q, id, s1, s2, typ;

    # get primes
    n := Size(G);
    p := FactorsInt(n);
    q := p[3];
    p := p[1];

    # compute the sylow subgroups
    s1  := SylowSubgroup( G, q );
    s2  := SylowSubgroup( G, p );

    if IsAbelian( G ) then
        if IsCyclic( s2 ) then
            typ := "p2 x q";
        else
            typ := "p x pq";
        fi;

    elif IsElementaryAbelian( s2 ) then
        if n = 12 and IsNormal( G, s2 ) then
            typ := "a4";
        else
            typ := "Dpq x p";
        fi;

    elif not IsTrivial( Centralizer( s2, s1 ) ) then
        typ := "Gp2q";
    else 
        typ := "Hp2q";
    fi;

    id := 1;

    if typ = "Gp2q" then
        return id; fi;
    if q mod p = 1 then id := id + 1; fi;

    if typ = "p2 x q" then
        return id; fi;
    id := id + 1;

    if typ = "Hp2q" then
        return id; fi;
    if q mod (p*p) = 1 then id := id + 1; fi;

    if typ = "a4" then
        return 3; fi;
    if n = 12 then id := id + 1; fi;

    if typ = "Dpq x p" then
        return id; fi;
    if q mod p = 1 then id := id + 1; fi;

    return id;
end;

#############################################################################
##
#F  IdP1Q2Group( <G> ). . . . . . . . . . . . . . . . . . . . . . . . . local
##
##  Compute identification for <G> where |G| = p*q^2.
##
IdP1Q2Group := function( G )

    local  n, p, q, s1, s2, typ, lat, nor, non, x, s, A, B, C, AC, BC, PO, id;

    # get primes
    n := Size(G);
    p := FactorsInt(n);
    q := p[3];
    p := p[1];

    # compute the sylow subgroups
    s1  := SylowSubgroup( G, q );
    s2  := SylowSubgroup( G, p );

    if IsAbelian( G ) then
        if IsCyclic( s1 ) then
            typ := "p x q2";
        else
            typ := "pq x q";
        fi;

    elif ( p <> 2 ) and ( (q+1) mod p = 0 ) then
        typ := "Npq2";

    elif IsCyclic( s1 ) then
        typ := "Mpq2";

    elif not IsTrivial( Centralizer( s1, s2 ) ) then
        typ := "Dpq x q";

    else    
        lat := List( ConjugacyClassesSubgroups(s1), Representative );
        lat := Filtered( lat, t -> Size(t) = q );
        nor := [];
        non := [];
        x   := 1;
        while x <= Length(lat) and 0 = Length(non) and Length(nor) < 3 do
            if IsNormal( G, lat[x] )  then
                Add( nor, lat[x] );
            else
                Add( non, lat[x] );
            fi;
            x := x + 1;
        od;
        if 0 = Length(non) and 2 < Length(nor)  then
            typ := "Kpq2";
        else
            while x <= Length(lat) and Length(nor) < 2  do
                if IsNormal( G, lat[x] )  then
                    Add( nor, lat[x] );
                fi;
                x := x + 1;
            od;
            A  := GeneratorsOfGroup( nor[1] )[1];
            B  := GeneratorsOfGroup( nor[2] )[1];
            C  := GeneratorsOfGroup( s2 )[1];
            AC := A^C;
            x  := 1;
            PO := 0;
            while PO <> AC  do
                x := x+1;
                if x^p mod q = 1  then
                    PO := A^x;
                fi;
            od;
            BC := B^C;
            s  := 1;
            PO := 0;
            while s < q and PO <> BC  do
                s := s+1;
                if s mod p <> 0 and s mod p <> 1  then
                    PO := B^((x^s) mod q);
                fi;
            od;
            s := s mod p;
            if ((1/s) mod p) < s  then s := (1/s) mod p;  fi;
            typ := s;
        fi;
    fi;

    id := 1;

    if typ = "Mpq2" then
        return id;
    fi;
    if q mod p = 1 then id := id + 1; fi;

    if typ = "p x q2" then
        return id;
    fi;
    id := id + 1;

    if typ = "Dpq x q" then
        return id;
    fi;
    if q mod p = 1 then id := id + 1; fi;

    if typ = "Npq2" then
        return id;
    fi;
    if (p<>2) and ( (q+1) mod p = 0 ) then id := id + 1; fi;

    if typ = "Kpq2" then
        return id;
    fi;
    if q mod p = 1 then id := id + 1; fi;

    if IsInt( typ ) then
        # g is Lpq2(typ)
        return id - 1 +
            Position( Filtered( [ 2 .. p-1 ], x -> x <= 1/x mod p), typ );
    fi;
    if ( p <> 2 ) and ( q mod p = 1 ) then id := id + ( p - 1 ) / 2; fi;

    return id;
end;

#############################################################################
##
#F  IdP1Group( <G> ). . . . . . . . . . . . . . . . . . . . . . . . . . local
##
##  Compute identification for <G> where |G| = p.
##
IdP1Group := function( G )

    return 1;
end;

#############################################################################
##
#F  IdP2Group( <G> ). . . . . . . . . . . . . . . . . . . . . . . . . . local
##
##  Compute identification for <G> where |G| = p^2.
##
IdP2Group := function( G )

    if IsCyclic( G ) then
        return 1;
    fi;
    return 2;
end;

#############################################################################
##
#F  IdP3Group( <G> ). . . . . . . . . . . . . . . . . . . . . . . . . . local
##
##  Compute identification for <G> where |G| = p^3.
##
IdP3Group := function( G )

    if IsAbelian( G ) then
        if IsCyclic( G ) then
            return 1;
        elif IsElementaryAbelian( G ) then
            return 5;
        fi;
        return 2;

    else 
        if Size( G ) = 8 then
            if Length(Filtered(AsList(G),x->Order(x)=2)) = 1 then
                return 4;
            fi;
            return 3; 
        fi;

        if Maximum( List( GeneratorsOfGroup(G), x -> Order(x) ) ) =
                    FactorsInt( Size( G ) )[ 1 ] then
            return 3;
        fi;    
        return 4;
    fi;
end;



#############################################################################
##
#F  IdP1Q1Group( <G> ). . . . . . . . . . . . . . . . . . . . . . . . . local
##
##  Compute identification for <G> where |G| = p*q.
##
IdP1Q1Group := function( G )
    local typ, p, q, id;

    p := FactorsInt( Size( G ) );
    q := p[ 2 ];
    p := p[ 1 ];

    if IsAbelian( G ) then
        typ := "pq";
    else 
        typ := "Dpq";
    fi;

    id := 1;

    if typ = "Dpq" then 
        return id;
    fi;
    if q mod p = 1 then id := id + 1; fi;

    # typ is pq
    return id;
end;

#############################################################################
##
#F  IdGroup( <G> ) . . . . . . . . . . . . . . . .identify group, if possible
## 
##  It will be possible, if |G| <= 1000 and |G| <> 256, 512, 768 or if
##  |G| is a product of at most 3 primes. 
##  G should be an PcGroup or a PermGroup.
##
InstallMethod( IdGroup, 
               "for permgroups or pcgroups", 
               true, 
               [ IsGroup ], 
               0,
function( G )
    local size, primes, sprimes, result;

    # set up
    size := Size( G );
    primes := FactorsInt( size );
    sprimes := Set( primes );
    
    # catch the trivial case
    if size = 1 then
        result := 1;

    # p-groups with size <= p ^ 3
    elif ( Length( sprimes ) = 1 ) and ( Length( primes ) <= 3 ) then
        if Length( primes ) = 1 then
            result := IdP1Group( G );
        elif Length( primes ) = 2 then
            result := IdP2Group( G );
        else 
            result := IdP3Group( G );
        fi;

    # pq-groups of typ pq, ppq and pqq
    elif ( Length( sprimes ) = 2 ) and ( Length( primes ) <= 3 ) then
        if Length( primes ) = 2 then 
            result := IdP1Q1Group( G );
        else 
            if primes[ 1 ] = primes[ 2 ] then
                result := IdP2Q1Group( G );
            else
                result := IdP1Q2Group( G );
            fi;
        fi;

    # pqr-groups of typ pqr
    elif ( Length( sprimes ) = 3 ) and ( Length( primes ) = 3 ) then
        result := IdP1Q1R1Group( G );

    # if Size( G ) is not as above, then the size is restricted
    elif ( size > 1000 ) or ( size in [ 256, 512, 768 ] ) then
        Error( "IdGroup: Size(G) restricted to 1000, except 256, 512, 768" );

    # final case
    else
        result := IdSmallGroup( G );
    fi;
    return [ Size( G ), result ];

end );

