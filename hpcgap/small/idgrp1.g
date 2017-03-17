#############################################################################
##
#W  idgrp1.g                 GAP group library             Hans Ulrich Besche
##                                               Bettina Eick, Eamonn O'Brien
##
##  This file contains the identification routines for groups with order
##  the product of maximal 3 primes. 
##

#############################################################################
##
#F ID_AVAILABLE_FUNCS[ 1 ]
##
ID_AVAILABLE_FUNCS[ 1 ] := SMALL_AVAILABLE_FUNCS[ 1 ];

#############################################################################
##
#F ID_GROUP_FUNCS[ 1 ]( G, inforec )
##
## order p
##
ID_GROUP_FUNCS[ 1 ] := function( G, inforec )

    return 1;
end;

#############################################################################
##
#F ID_GROUP_FUNCS[ 2 ]( G, inforec )
##
## order p ^ 2
##
ID_GROUP_FUNCS[ 2 ] := function( G, inforec )

    if IsCyclic( G ) then 
        return 1;
    else 
        return 2;
    fi;
end;

#############################################################################
##
#F ID_GROUP_FUNCS[ 3 ]( G, inforec )
##
## order p * q
##
ID_GROUP_FUNCS[ 3 ] := function( G, inforec )
    local typ;

    if IsAbelian( G ) then 
        typ := "pq";
    else 
        typ := "Dpq";
    fi;

    return Position(
           NUMBER_SMALL_GROUPS_FUNCS[ 3 ]( Size( G ), inforec ).types, typ );
end;

#############################################################################
##
#F ID_GROUP_FUNCS[ 4 ]( G, inforec )
##
## order p ^ 3
##
ID_GROUP_FUNCS[ 4 ] := function( G, inforec )

    if IsAbelian( G ) then
        if IsCyclic( G ) then         
            return 1;                                                
        elif IsElementaryAbelian( G ) then
            return 5;
        fi;      
        return 2;                            

    else
        if Size( G ) = 8 then              
            if Length( Filtered( AsList( G ), x-> Order( x ) = 2 ) ) = 1 then
                return 4;
            fi;
            return 3;      
        fi;                                                         

        if Maximum( List( GeneratorsOfGroup( G ), x -> Order( x ) ) ) =
                    FactorsInt( Size( G ) )[ 1 ] then          
            return 3;                                         
        fi;                                    
        return 4;  
    fi;
end;

#############################################################################
##
#F ID_GROUP_FUNCS[ 5 ]( G, inforec )
##
## order p ^ 2 * q
##
ID_GROUP_FUNCS[ 5 ] := function( G, inforec )
    local n, p, q, s1, s2, typ;

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
            typ := "p2q";
        else
            typ := "ppq";                                         
        fi;

    elif IsElementaryAbelian( s2 ) then
        if n = 12 and IsNormal( G, s2 ) then       
            typ := "a4";
        else
            typ := "Dpqxp";
        fi;

    elif not IsTrivial( Centralizer( s2, s1 ) ) then
        typ := "Gp2q";
    else
        typ := "Hp2q";
    fi;

    return Position(
           NUMBER_SMALL_GROUPS_FUNCS[ 5 ]( Size( G ), inforec ).types, typ );
end;

#############################################################################
##
#F ID_GROUP_FUNCS[ 6 ]( G, inforec )
##
## order p * q ^ 2
##
ID_GROUP_FUNCS[ 6 ] := function( G, inforec )
    local  n, p, q, s1, s2, typ, lat, nor, non, x, s, A, B, C, AC, BC, PO,id;

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
            typ := "pq2";
        else
            typ := "pqq";
        fi;

    elif ( p <> 2 ) and ( (q+1) mod p = 0 ) then
        typ := "Npq2";

    elif IsCyclic( s1 ) then
        typ := "Mpq2";

    elif not IsTrivial( Centralizer( s1, s2 ) ) then
        typ := "Dpqxq";

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
            # Kpq2;
            typ := 1;
        else
            # Lpq2
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

    return Position(
           NUMBER_SMALL_GROUPS_FUNCS[ 6 ]( Size( G ), inforec ).types, typ );
end;

#############################################################################
##
#F ID_GROUP_FUNCS[ 7 ]( G, inforec )
##
## order p * q * r
##
ID_GROUP_FUNCS[ 7 ] := function( G, inforec )
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
        typ := "Dqrxp";

    elif not IsAbelian( ClosureGroup( s1, s2 ) ) then
        typ := "Hpqr";

    elif IsAbelian( ClosureGroup( s1, s3 ) ) then
        typ := "Dpqxr";

    elif IsAbelian( ClosureGroup( s2, s3 ) ) then
        typ := "Dprxq";

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
        x := First( [2..r-1], t -> t^p mod r = 1 );
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
        y := First( [2..q-1], t -> t^p mod q = 1 );
        s := LogMod( s, y, q ) mod OrderMod( y, q );

        typ := s; # the typ is Gpqr( s )
    fi;

    return Position(
           NUMBER_SMALL_GROUPS_FUNCS[ 7 ]( Size( G ), inforec ).types, typ );
end;
