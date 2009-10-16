#############################################################################
##
#W pcplib.gi                    Polycyc                          Bettina Eick
#W                                                              Werner Nickel
##

#############################################################################
##
#F ExamplesOfSomePcpGroups(n)
##
InstallGlobalFunction( ExamplesOfSomePcpGroups, function(n)
    if not IsInt(n) then return fail; fi;
    if n < 1 or n > 16 then return fail; fi;
    if n <= 13 then return PcpExamples(n); fi;
    return NqExamples(n-13); 
end );

#############################################################################
##
#F PcpExamples(n)
##
InstallGlobalFunction( PcpExamples, function( n )
    local FTL;

    ##
    ##                                             [ 0 1 ]   [ -1  0 ] 
    ##  The semidirect product of the matrices     [ 1 1 ],  [  0 -1 ]
    ##
    ##  and Z^2.  We let the generator corresponding to the second matrix
    ##  have infinite order. 
    ##
    if n = 1 then 
        return SplitExtensionPcpGroup( AbelianPcpGroup( 2, [] ), 
                             [ [[0,1],[1,1]], [[-1,0],[0,-1]] ] );
    fi;

    ##
    ##  The following matrices are a basis of the fundamental units of the
    ##  order defined by the polynomials x^4 - x - 1
    ##
    if n = 2 then 
        return SplitExtensionPcpGroup( AbelianPcpGroup( 2, [] ), 
       [ [ [ 0,1,0,0 ],  [ 0,0,1,0 ],  [ 0,0,0,1 ],  [ 1,1,0,0 ] ],
       [ [ 1,1,0,-1 ], [ -1,0,1,0 ], [ 0,-1,0,1 ], [ 1,1,-1,0 ] ] ] );
    fi;

    ##
    ##  Z split Z 
    ##
    if n = 3 then 
        FTL := FromTheLeftCollector( 2 );
        SetConjugate( FTL, 2,  1, [2,-1] );
        SetConjugate( FTL, 2, -1, [2,-1] );
        return PcpGroupByCollector(FTL);
    fi;

    ##
    ##  A gr oup of Hirsch length 3.  Interesting because the exponents in
    ##  words can become large very quickly.
    ##
    if n = 4 then 
        FTL := FromTheLeftCollector( 3 );
        SetConjugate( FTL, 2, 1, [3, 1] );
        SetConjugate( FTL, 3, 1, [2, 1, 3, 7] );
        return PcpGroupByCollector(FTL);
    fi;

    ##
    ##  A torsion free polycyclic group which is not nilpotent. It is
    ##  taken vom Robinson's book, page 158.
    ##
    if n = 5 then
        FTL := FromTheLeftCollector( 4 );
        SetRelativeOrder( FTL, 1, 2 );
        SetPower( FTL, 1, [4,1] );
        SetConjugate( FTL, 2,1, [2,-1] );
        SetConjugate( FTL, 3,1, [3,-1] );
        SetConjugate( FTL, 3,2, [3,1,4,2] );
        return PcpGroupByCollector(FTL);
    fi;

    ##
    ## The next 4 groups are from Lo/Ostheimer paper on finding matrix reps
    ## for pc groups. They are all non-nilpotent, but poly-Z
    ##
    if n = 6 then
        FTL := FromTheLeftCollector( 3 );
        SetConjugate( FTL, 2, 1, [2,2,3,1]);
        SetConjugate( FTL, 3, 1, [2,1,3,1]);
        return PcpGroupByCollector(FTL);
    fi;

    if n = 7 then
        FTL := FromTheLeftCollector( 4 );
        SetConjugate( FTL, 2, 1, [3,1] );
        SetConjugate( FTL, 3, 1, [2,-1, 3,3, 4,1] );
        SetConjugate( FTL, 3, 2, [3,1,4,-1]);
        return PcpGroupByCollector(FTL);
    fi;

    if n = 8 then
        FTL := FromTheLeftCollector( 5 );
        SetConjugate( FTL, 2, 1, [2,1,4,-1]);
        SetConjugate( FTL, 3, 2, [5,1]);
        SetConjugate( FTL, 4, 2, [3,1,4,-1,5,1]);
        SetConjugate( FTL, 5, 2, [4,1]);
        return PcpGroupByCollector(FTL);
    fi;

    if n = 9 then
        FTL := FromTheLeftCollector( 3 );
        SetConjugate( FTL, 2, 1, [2,1,3,-3] );
        SetConjugate( FTL, 3, 1, [3,-1] );
        SetConjugate( FTL, 3, 2, [3,-1] );
        return PcpGroupByCollector(FTL);
    fi;

    ##
    ## A pc group from Eddie's preprint on `low index for pc groups'
    ##
    if n = 10 then
        FTL := FromTheLeftCollector( 4 );
        SetConjugate( FTL, 2, 1, [2,-1] );
        SetConjugate( FTL, 4, 1, [4,-1] );
        SetConjugate( FTL, 3, 2, [3,2,4,1]);
        SetConjugate( FTL, 4, 2, [3,3,4,2]);
        return PcpGroupByCollector(FTL);
    fi;

    ##
    ## The free nilpotent group of rank 2 and class 3.
    ##
    if n = 11 then
        FTL := FromTheLeftCollector( 5 );
        SetConjugate( FTL, 2, 1, [2,1,3, 1] );
        SetConjugate( FTL, 3, 1, [3,1,4, 1] );
        SetConjugate( FTL, 3, 2, [3,1,5, 1] );
        return PcpGroupByCollector( FTL );
    fi;

    ##
    ## The free nilpotent group of rank 3 and class 2.
    ##
    if n = 12 then
        FTL := FromTheLeftCollector( 6 );
        SetConjugate( FTL, 2, 1, [2,1,4, 1] );
        SetConjugate( FTL, 3, 1, [3,1,5, 1] );
        SetConjugate( FTL, 3, 2, [3,1,6, 1] );
        return PcpGroupByCollector( FTL );
    fi;
  
    if n = 13 then 
        FTL := FromTheLeftCollector( 4 );
        SetConjugate( FTL, 2, 1, [2,-1] );
        SetConjugate( FTL, 4, 1, [4,-1] );
        SetConjugate( FTL, 3, 2, [3,2,4,1]);
        SetConjugate( FTL, 4, 2, [3,3,4,2]);
        return PcpGroupByCollector( FTL );
    fi;
    return fail;

end );

