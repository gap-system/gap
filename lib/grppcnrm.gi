#############################################################################
##
#F  PCGS_STABILIZER( <pcgs>, <home>, <pnt> )  . . . . . . . . . . . . . local
##
PCGS_STABILIZER := function( pcgs, home, pnt )
    local   pa,  one,  orb,  prod,  n,  s,  i,  mi,  np,  j,  o,  len,  
            l1,  k,  l2,  r,  e;


    # operate on canonical versions
    one := OneOfPcgs(home);
    pnt := HomomorphicCanonicalPcgs( home, pnt, one );

    # store representatives in <r>
    orb  := [ pnt ];
    prod := [ 1 ];
    n    := [];
    s    := [];

    # go *up* the composition series
    for i  in Reversed([1..Length(pcgs)])  do
        mi := pcgs[i];
        np := HomomorphicCanonicalPcgs( home, pnt, mi );

        # is <np> really a new point or is it in <orb>
        j := Position( orb, np );

        # add it if it is new
        if j = fail  then
            o := RelativeOrderOfPcElement( pcgs, mi );
            Add( prod, prod[Length(prod)] * o );
            Add( n, i );
            len := Length(orb);
            l1  := 0;
            for k  in [ 1 .. o-1 ]  do
                l2 := l1 + len;
                for j  in [ 1 .. len ]  do
                    orb[j+l2] := HomomorphicCanonicalPcgs(home,orb[j+l1],mi);
                od;
                l1 := l2;
            od;

        # if it is the start point the element stabilizes
        elif j = 1 then
            Add( s, mi );

        # compute a stabilizing element
        else
            r   := one;
            j   := j-1;
    	    len := Length(prod);
            for k  in [ 1 .. len-1 ]  do
                e := QuoInt( j, prod[len-k] );
                r := pcgs[n[len-k]]^e * r;
                j := j mod prod[len-k];
            od;
            Add( s, pcgs[i] / r );
        fi;
    od;
    Info( InfoPcNormalizer, 3, "  orbit length: ", Length(orb) );
    return Reversed(s);

end;


#############################################################################
##
#M  PcgsStabilizer( <pcgs>, <home-pcgs>, <point-pcgs> )
##
InstallMethod( PcgsStabilizer,
    "prime orders pcgs, pcgs, pcgs",
    true,
    [ IsPcgs and IsPrimeOrdersPcgs,
      IsPcgs,
      IsPcgs ],
    0,

function( pcgs, home, pnt )
    local   s;

    s := PCGS_STABILIZER( pcgs, home, pnt );
    if HasHomePcgs(pcgs)  then
        return InducedPcgsByPcSequence( HomePcgs(pcgs), s );
    else
        return InducedPcgsByPcSequence( pcgs, s );
    fi;
end );



#############################################################################
##
#M  PcgsStabilizer( <modulo-pcgs>, <home-modulo-pcgs>, <point-modulo-pcgs> )
##
InstallOtherMethod( PcgsStabilizer,
    "prime orders pcgs modulo pcgs, modulo pcgs, modulo pcgs",
    true,
    [ IsModuloPcgs and IsPrimeOrdersPcgs,
      IsModuloPcgs,
      IsModuloPcgs ],
    0,

function( pcgs, home, pnt )
    local   den,  s;

    den := DenominatorOfModuloPcgs(pcgs);
    if DenominatorOfModuloPcgs(home) <> den  then
        return PcgsStabilizer( NumeratorOfModuloPcgs(pcgs), home, pnt )
           mod den;
    else
        s := ExtendedIntersectionSumPcgs(
                 NumeratorOfModuloPcgs(pcgs),
                 den,
                 PCGS_STABILIZER( pcgs, home, pnt ) ).sum;
        return s mod den;
    fi;
end );


#############################################################################
##
#M  PcgsStabilizer( <modulo-pcgs>, <home-pcgs>, <point-pcgs> )
##
InstallOtherMethod( PcgsStabilizer,
    "prime orders pcgs modulo pcgs, object, object",
    true,
    [ IsModuloPcgs,
      IsPcgs,
      IsPcgs ],
    0,

function( pcgs, home, pnt )
    local   den,  s;

    den := DenominatorOfModuloPcgs(pcgs);
    s := ExtendedIntersectionSumPcgs(
             NumeratorOfModuloPcgs(pcgs),
             den,
             PCGS_STABILIZER( pcgs, home, pnt ) ).sum;
    return s mod den;
end );


#############################################################################
##
#M  PcgsStabilizer( <pcgs>, <home-modulo-pcgs>, <point-modulo-pcgs> )
##
InstallOtherMethod( PcgsStabilizer,
    "prime orders pcgs, pcgs modulo pcgs, pcgs modulo pcgs",
    true,
    [ IsPcgs,
      IsModuloPcgs,
      IsModuloPcgs ],
    0,

function( pcgs, home, pnt )
    local   s;

    if DenominatorOfModuloPcgs(home) <> DenominatorOfModuloPcgs(pnt)  then
        Error( "denominator of <home> and <pnt> are not equal" );
    fi;

    s := PCGS_STABILIZER( pcgs, home, pnt );
    if HasHomePcgs(pcgs)  then
        return InducedPcgsByPcSequence( HomePcgs(pcgs), s );
    else
        return InducedPcgsByPcSequence( pcgs, s );
    fi;
end );


#############################################################################
##
#F  PcGroup_NormalizerWrtHomePcgs( <u>, <f1>, <f2>, <f3>, <f4> )
##
##  compute the normalizer of <u>  in its home pcgs,  the flags <f1> to  <f4>
##  can be used to fine tune the normalizer computation:
##
##  <f1>    if 'true', intersections with the same prime than  the module are
##  	    computed  using    one  cobounds.   Otherwise an  ordinary  orbit
##  	    stabilizer algorithm is used.
##
##  <f2>    if 'true', intersections with different prime than the module are
##  	    computed using one cobounds.  Otherwise the method of computation
##  	    depends on the flag <f3>.
##
##  <f3>    if 'true' and <f2> is  'false', then intersections with different
##  	    prime than  the  module  are computed  using Glasby's  algorithm.
##  	    Otherwise a ordinary orbit stabilizer algorithm is used.
##
##  <f4>    if 'true', the first  intersection  is computed   using    linear
##  	    operations.  Otherwise a ordinary orbit  stabilizer  algorithm is
##  	    used.
##
PcGroup_NormalizerWrtHomePcgs := function( u, f1, f2, f3, f4 )

    local   g,	    	    # home pcgs of <pcgs>
            e,  r,   	    # elementary abelian series of <G> and its length
            ue,	    	    # factor pcgs <pcgs><e>[i] mod <e>[i]
            uk,  uj,  ui_1, # intersections of <pcgs> with <e>[x]
            s,  si_1,	    # stabilizer and its intersection with <e>[i-1]
            se,             # <s> modulo <e>[i] or <uk>
            ei_1,           # <e>[i-1] mod <e>[i]
            pj,  pi_1,	    # primes of <e>[j] and <e>[i-1]
            st,	    	    # used for checking the algorithm
            i,  j,  k,      # loops
            pcgs,           # pcgs of <u>
            tmp;            # temporary

    # get the parent pcgs and the elementary abelian series
    g := HomePcgs(u);
    e := ElementaryAbelianSubseries(g);
    if e = fail  then
        Error( "not ready yet" );
    fi;
    r := Length(e);

    # get a canonical pcgs for <u>
    pcgs := CanonicalPcgsWrtHomePcgs(u);

    # If <r> = 2,  <g> is abelian, so we can return <g>
    if r = 2  then
    	return g;
    fi;

    # compute 'Closure(<pcgs>,<e>[i]) modulo <e>[i]'
    ue := [];
    for i  in [ 1 .. r ]  do
        ue[i] := CanonicalPcgs( ExtendedIntersectionSumPcgs(
                     g, e[i], pcgs ).sum ) mod e[i];
    od;

    # start with <g>/<e>[2], in this factorgroup nothing is to be done
    s := e[1] mod e[2];
    Info( InfoPcNormalizer, 2, "starting with <g> / <e>[2]" );
    Info( InfoPcNormalizer, 3, "  subgroup:   ", AsList(ue[2]) );
    Info( InfoPcNormalizer, 3, "  normalizer: ", AsList(s) );
    Info( InfoPcNormalizer, 5, "  normalizer: ", s );
    Info( InfoPcNormalizer, 5, "  modulo:     ", AsList(e[2]) );

    # start with <g>/<e>[3] because <g>/<e>[2] is abelian
    for i  in [ 3 .. r ]  do

    	# <s> = Normalizer( <G>/<E>[i-1], <pcgs> )
    	#
    	# The first step looks like ( U = <pcgs> )
    	#
    	#   	    S
    	#   	      \
    	#   	       \
    	#   	U        Ei-1
    	#   	 \  	/
    	#   	  \    /
    	#   	   Ui-1
    	#   	       \
    	#   	    	\
    	#   	    	 Ei
        #
    	# Now get  the complete preimage of <s>  in  <g>/<e>[i] and start the
        # whole computation for that factorgroup.

        s  := NumeratorOfModuloPcgs(s) mod e[i];
        Info( InfoPcNormalizer, 2, "reached level ", i, " of ", r );
        Info( InfoPcNormalizer, 3, "  subgroup:   ", AsList(ue[i]) );
        Info( InfoPcNormalizer, 3, "  normalizer: ", AsList(s) );
        Info( InfoPcNormalizer, 5, "  normalizer: ", s );
        Info( InfoPcNormalizer, 5, "  modulo:     ", AsList(e[i]) );

        # keep the old stabilizer for an assert later
        st := s;

        # if <ue>[i] is trivial we can skip this step
        ei_1 := e[i-1] mod e[i];
        if IsEmpty(ue[i])  then
            Info( InfoPcNormalizer, 2, "<ue>[", i, "] is trivial" );

        # if <e>[i-1] is a subgroup of <ue>[i] we can skip this step
        elif ForAll( ei_1, x -> x in GroupOfPcgs(ue[i]) )  then
            Info( InfoPcNormalizer, 2, "<e>[",i-1,"] < <ue>[",i,"]" );

        # now do some real work
        else

            # remember the prime of the current section for later
            pi_1 := RelativeOrderOfPcElement( ei_1, ei_1[1] );

            # If the intersection <ue>i  /\ <e>[i-1] is not trivial  computed
            # the stabilizer of  this  intersection with an orbit  stabilizer
            # algorithm.  If <f4> is true, use linear operations.

            ui_1 := ExtendedIntersectionSumPcgs(
                        g,
                        e[i-1],
                        NumeratorOfModuloPcgs(ue[i]) ).intersection
                    mod e[i];

            if IsEmpty(ui_1)  then
                Info( InfoPcNormalizer, 2,
                      "<ue>[",i,"] /\\ <e>[",i-1,"] is trivial" );

            elif f4  then
                Info( InfoPcNormalizer, 3, "stabilizing <ue>[",i,
                      "] /\\ <e>[",i-1,"] using linear operation" );

                s := PcGroup_LinearNO( s, ei_1, ui_1 );

            else
                Info( InfoPcNormalizer, 3, "stabilizing <ue>[",i,
                      "] /\\ <e>[",i-1,"] using orbit" );
                Info(InfoPcNormalizer, 4, "  point:        ", AsList(ui_1));
                Info(InfoPcNormalizer, 4, "  normalizer:   ", AsList(s));
                Info(InfoPcNormalizer, 5, "  point-home:   ", s);

                s := PcgsStabilizer( s, s, ui_1 );

                Info(InfoPcNormalizer, 4, "  new norm:     ", AsList(s));
            fi;

            # find <ue>[i]/\<E>[j] which is larger then <ue>[i]/\<E>[i-1]
            j  := i-2;
            uj := ExtendedIntersectionSumPcgs(
                      g,
                      e[j],
                      NumeratorOfModuloPcgs(ue[i]) ).intersection
                  mod e[i];
            k  := i-1;
            uk := ui_1;
            while 0 < j and ForAll( uj, x -> x in GroupOfPcgs(ui_1) )  do
                Info( InfoPcNormalizer, 3, "<ue>[",i,"] /\\ <e>[",k,
                      "] = <ue>[",i,"] /\\ e[",j,"]" );

                k  := j;
                uk := uj;
                j  := j - 1;
                if 0 < j  then
                    uj := ExtendedIntersectionSumPcgs(
                              g,
                              e[j],
                              NumeratorOfModuloPcgs(ue[i]) ).intersection
                          mod e[i];
                fi;
            od;

    	    # The next step for <s> = Normalizer(<uk>) is
    	    #
    	    #       S
    	    #        \    Ej
    	    #         \  /  \
    	    #   U      **    \
    	    #    \    /  \    Ek
    	    #     \  /    \  /  \
    	    #      Uj      **    \
    	    #        \    /  \    Ei-1
    	    #         \  /    \  /
    	    # 	       Uk      Si-1
    	    #            \     /
    	    #             \   /
    	    #              Ui-1
    	    #	    	     \
    	    #                 \
    	    #                  Ei
    	    #
            # If <j> = 0 or  <s> and <u> have  the same <E>[i-1] intersection
            # we are finished with this step.

            si_1 := ExtendedIntersectionSumPcgs(
                        g,
                        e[i-1],
                        NumeratorOfModuloPcgs(s) ).intersection
                    mod e[i];

            while 0 < j and not ForAll(si_1, x -> x in GroupOfPcgs(ui_1))  do
                tmp := e[j] mod e[j+1];
                pj  := RelativeOrderOfPcElement( tmp, tmp[1] );
                se  := NumeratorOfModuloPcgs(s)
                       mod CanonicalPcgs( NumeratorOfModuloPcgs(uk) );

                if ( pj = pi_1 and f1 ) or ( pj <> pi_1 and f2 )  then
                    Info( InfoPcNormalizer, 3, "stabilizing <ue>[",i,
                          "] /\\ <e>[",j,"] using cobounds" );

                    s := PcGroup_CoboundsNO( s, si_1, uj, uk );

                elif pj <> pi_1 and f3  then
                    Info( InfoPcNormalizer, 3, "stabilizing <ue>[",i,
                          "] /\\ <e>[",j,"] using Glasby" );

                    s := PcGroup_GlasbyNO( s, si_1, uj, uk );

                else
                    Info( InfoPcNormalizer, 3, "stabilizing <ue>[",i,
                          "] /\\ <e>[",j,"] using orbit" );
                    tmp := NumeratorOfModuloPcgs(uj) 
                               mod NumeratorOfModuloPcgs(uk);
                    Info(InfoPcNormalizer,4,"  point:        ",AsList(tmp));
                    Info(InfoPcNormalizer,4,"  normalizer:   ",AsList(s));
                    Info(InfoPcNormalizer,5,"  point-home:   ",se);

                    s := PcgsStabilizer( s, se, tmp );

                    Info(InfoPcNormalizer,4,"  new norm:     ",AsList(s));
                fi;

                Assert( 1, GroupOfPcgs( NumeratorOfModuloPcgs(
                        Stabilizer(st,uj) ) ) = GroupOfPcgs(
                        NumeratorOfModuloPcgs(s) ),
                        "chain stabilizer and orbit mismatch" );

                # find the next non-trivial intersection
                k  := j;
                uk := uj;
                while 0 < j and ForAll( uj, x -> x in GroupOfPcgs(uk) )  do
                    if k <> j  then
                        Info( InfoPcNormalizer, 3, "<ue>[i] /\\ <e>[",
                              k, "] = <ue>[", i, "] /\\ e[", j, "]" );
                    fi;

                    k  := j;
                    uk := uj;
                    j  := j - 1;
                    if 0 < j  then
                        uj := ExtendedIntersectionSumPcgs(
                                  g,
                                  e[j],
                                  NumeratorOfModuloPcgs(ue[i]) ).intersection
                              mod e[i];
                    fi;
                od;

                # Now we know our new <S>, if <j>-1 is still nonzero, compute
                # the intersection in order to see, if we are ready.

                if 0 < j  then
                    si_1 := ExtendedIntersectionSumPcgs(
                                g,
                                e[i-1],
                                NumeratorOfModuloPcgs(s) ).intersection
                            mod e[i];
                fi;

            od;
        fi;
    od;

    if Length(s) = Length(pcgs)  then
        return pcgs;
    else
        tmp := InducedPcgsByPcSequence( g, List( s, x -> x ) );
        SetHomePcgs( tmp, g );
        return tmp;
    fi;

end;


#############################################################################
##
#M  NormalizerInHomePcgs( <pc-group> )
##
InstallMethod( NormalizerInHomePcgs,
    "for group with home pcgs",
    true,
    [ IsGroup and HasHomePcgs ],
    0,

function( u )
    return PcGroup_NormalizerWrtHomePcgs( u, true, false, true, true );
end );


#############################################################################
##
#M  Normalizer( <pc-group>, <pc-group> )
##
InstallMethod( Normalizer,
    "for groups with home pcgs",
    IsIdentical,
    [ IsGroup and HasHomePcgs,
      IsGroup and HasHomePcgs ],
    0,

function( g, u )
    local   home,  norm;

    # for small groups use direct calculation
    if Size(g) < 1000  then
        TryNextMethod();
    fi;
    home := HomePcgs(g);
    if home <> HomePcgs(u)  then
        TryNextMethod();
    fi;

    # first compute the normalizer with respect to the home
    norm := NormalizerInHomePcgs(u);

    # then the intersection
    norm := Intersection( g, norm );

    # and return
    return norm;

end );


#############################################################################
##

#E  grppcnrm.gi	. . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##