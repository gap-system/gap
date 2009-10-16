#############################################################################
##
#W  metacyc.gi                   Polycyclic                     Werner Nickel
##

#############################################################################
##
#F  InfiniteMetacyclicPcpGroup  . . . . . . . . the metacyclic group G(m,n,r)
##
##  In 
##       J.R. Beuerle & L.-C. Kappe (2000), Infinite Metacyclic Groups and
##       Their Non-Abelian Tensor Square, Proc. Edin. Math. Soc., 43,
##       651--662 
##  the infinite metacyclic groups are classified up to isomorphism.  This
##  function implements their classification.  The groups are given by the
##  following family of presentations:
##                   < a,b | a^m, b^n, [a,b] = a^(1-r) >
##  where [a,b] = a b a^-1 b^-1.
##
##  For this function we use the presentation
##                      < x,y | x^n, y^m, y^x = y^r >
##  which is isomorphic to the one above via x --> b^-1, y --> a.
##
##  It would be nice if this function could also return representatives for
##  the isomorphism classes of finite metacyclic groups.
##
InstallGlobalFunction( InfiniteMetacyclicPcpGroup, function( n, m, r )
    local   coll;

    ##  <m> or <n> must be zero for the group to be infinite.
    if m*n <> 0 then
        return Error( "at least one of <m> or <n> must be zero" );
    fi;

    if m < 0 or m = 1 or n < 0 or n = 1 then
        return Error( "<n> and <m> must not be negative and not be 1" );
    fi;

    if r = 0 then
        return Error( "<r> must not be zero" );
    fi;

    if m = 0 and AbsInt(r) <> 1 then
        return Error( "<m> = 0 implies <r> = 1 or <r> = -1" );
    fi;

    ##  If r = -1 mod m, then n must be even.
    if IsOddInt(n) and (r = -1 or (m <> 0 and r mod m = -1)) then
        return Error( "<r> = -1 implies that n is even" );
    fi;

    coll := FromTheLeftCollector( 2 );
    SetRelativeOrder( coll, 1, n );
    SetRelativeOrder( coll, 2, m );

    if m <> 0 then
        r := r mod m;
        SetConjugate( coll, 2, 1, [2,r] );
    fi;

    UpdatePolycyclicCollector( coll );
    return PcpGroupByCollector( coll );
end );


