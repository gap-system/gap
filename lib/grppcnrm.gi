#############################################################################
##
#F  PCGS_STABILIZER( <pcgs>, <pnt>, <op>, <data> )  . . . . . . . . . . local
##
PCGS_STABILIZER := function( pcgs, pnt, op, data )
    local   pa,  one,  orb,  prod,  n,  s,  i,  mi,  np,  j,  o,  len,  
            l1,  k,  l2,  r,  e;


    # operate on canonical versions
    one := OneOfPcgs(pcgs);
    pnt := op( data, pnt, one );

    # store representatives in <r>
    orb  := [ pnt ];
    prod := [ 1 ];
    n    := [];
    s    := [];

    # go *up* the composition series
    for i  in Reversed([1..Length(pcgs)])  do
        mi := pcgs[i];
        np := op( data, pnt, mi );

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
                    orb[j+l2] := op( data, orb[j+l1], mi );
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
    Info( InfoPcNormalizer, 3, "orbit length: ", Length(orb) );
    return Reversed(s);

end;


#############################################################################
##
#M  PCGS_NORMALIZER( <home-pcgs>, <pcgs>, <point-pcgs>, <modulo-pcgs> )
##
PCGS_NORMALIZER_OPB := function( data, pnt, obj )
    return pnt^obj;
end;

PCGS_NORMALIZER_OPC := function( data, elm, obj )
    return CanonicalPcElement( data[1], elm^obj );
end;

PCGS_NORMALIZER_OPD := function( data, lst, obj )
    lst := HOMOMORPHIC_IGS( data[1], lst, obj );
    NORMALIZE_IGS( data[1], lst );
    return lst;
end;

PCGS_NORMALIZER_OPE := function( data, lst, obj )
    local   home,  pag,  pos,  max,  i,  g,  dg,  exp,  j,  ros;

    home := data[1];
    pag  := data[2]; # make sure to reset <pag> before returning
    pos  := [];
    max  := data[3];
    ros  := data[4];
    for i  in [ Length(lst), Length(lst)-1 .. 1 ]  do
        g  := lst[i]^obj;
        dg := DepthOfPcElement( home, g );
        while dg < max  do
            if IsBound(pag[dg])  then
                g  := ReducedPcElement( home, g, pag[dg] );
                dg := DepthOfPcElement( home, g );
            else
                pag[dg] := g;
                AddSet( pos, dg );
                break;
            fi;
        od;
    od;
    for i  in Reversed(pos)  do
        exp := LeadingExponentOfPcElement( home, pag[i] );
        if exp <> 1  then
            pag[i] := pag[i] ^ (1/exp mod ros[i]);
        fi;
        for j  in [ i+1 .. max-1 ]  do
            if IsBound(pag[j])  then
                exp := ExponentOfPcElement( home, pag[i], j );
                if exp <> 0  then
                    pag[i] := pag[i] * pag[j]^(ros[j]-exp);
                fi;
            fi;
        od;
        pag[i] := HeadPcElementByNumber( home, pag[i], max );
    od;
    lst := pag{pos};
    for i  in pos  do Unbind(pag[i]);  od;
    return lst;
end;


PCGS_NORMALIZER := function( home, pcgs, pnt, modulo )
    local   op,  s,  id,  ros,  sub,  i,  dg,  exp,  max,  data;

    Info( InfoPcNormalizer, 5, "home:       ", ShallowCopy(home) );
    Info( InfoPcNormalizer, 4, "normalizer: ", ShallowCopy(pcgs) );
    Info( InfoPcNormalizer, 4, "point:      ", ShallowCopy(pnt) );
    Info( InfoPcNormalizer, 5, "modulo:     ", ShallowCopy(modulo) );

    # if <pnt> and <modulo> have the same length nothing is to be done
    if Length(pnt) = Length(modulo)  then
        Info( InfoPcNormalizer, 3, "PCGS_NORMALIZER case A" );
        return pcgs;

    # if <pnt> mod <modulo> has only one element operate on elements
    elif Length(pnt)-1 = Length(modulo)  then
        if 0 = Length(modulo)  then
            Info( InfoPcNormalizer, 3, "PCGS_NORMALIZER case B" );
            pnt  := pnt[1];
            op   := PCGS_NORMALIZER_OPB;
            data := 0;
        else
            Info( InfoPcNormalizer, 3, "PCGS_NORMALIZER case C" );
            pnt  := pnt mod modulo;
            pnt  := CanonicalPcElement( modulo, pnt[1] );
            op   := PCGS_NORMALIZER_OPC;
            data := [modulo];
        fi;
        s := PCGS_STABILIZER( pcgs, pnt, op, data );

    # if the <modulo> is trivial it is relatively easy
    elif 0 = Length(modulo)  then
        Info( InfoPcNormalizer, 3, "PCGS_NORMALIZER case D" );
        op   := PCGS_NORMALIZER_OPD;
        data := [home];
        pnt  := op( data, ShallowCopy(pnt), id );
        s    := PCGS_STABILIZER( pcgs, pnt, op, data );
        
    # it is get complicated
    else
        Info( InfoPcNormalizer, 3, "PCGS_NORMALIZER case E" );
        id  := OneOfPcgs(home);
        ros := RelativeOrders(home);
        sub := [];
        for i  in modulo  do
            dg  := DepthOfPcElement( home, i );
            exp := LeadingExponentOfPcElement( home, i );
            if exp <> 1  then
                i := i ^ (1/exp mod ros[dg]);
            fi;
            sub[dg] := i;
        od;
        max := Length(home)+1;
        while 2 <= max and IsBound(sub[max-1])  do
            max := max-1;
        od;
        op   := PCGS_NORMALIZER_OPE;
        data := [ home, sub, max, ros ];
        pnt  := op( data, ShallowCopy( pnt mod modulo ), id );
        s    := PCGS_STABILIZER( pcgs, pnt, op, data );
    fi;

    # convert it into a modulo pcgs
    pcgs := SumPcgs( home, DenominatorOfModuloPcgs(pcgs), s )
        mod DenominatorOfModuloPcgs(pcgs);
    Info( InfoPcNormalizer, 4, "new norm:   ", ShallowCopy(pcgs) );
    return pcgs;

end;



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
            id,             # identity element
            tmp;            # temporary

    # get the parent pcgs and the elementary abelian series
    g  := HomePcgs(u);
    id := OneOfPcgs(g);
    e  := ElementaryAbelianSubseries(g);
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

    # compute the closure of <pcgs> and <e>[i]
    ue := [];
    for i  in [ 1 .. r ]  do
        ue[i] := SumPcgs( g, e[i], pcgs );
    od;

    # begin with <g>/<e>[2], in this factorgroup nothing is to be done
    s := e[1] mod e[2];
    Info( InfoPcNormalizer, 1, "skiping level 1 of ", r );
    Info( InfoPcNormalizer, 1, "skiping level 2 of ", r );

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

        s := NumeratorOfModuloPcgs(s) mod e[i];
        Info( InfoPcNormalizer, 1, "reached level ", i, " of ", r );
        Info( InfoPcNormalizer, 4, "normalizer:   ", AsList(s) );
        Info( InfoPcNormalizer, 4, "subgroup:     ", AsList(ue[i]) );
        Info( InfoPcNormalizer, 5, "modulo:       ", AsList(e[i]) );

        # keep the old stabilizer for an assert later
        st := s;

        # if <ue>[i] is trivial we can skip this step
        ei_1 := e[i-1] mod e[i];
        if Length(ue[i]) = Length(e[i])  then
            Info( InfoPcNormalizer, 2, "<ue>[", i, "] is trivial" );
            Assert( 1, IsNormal(GroupOfPcgs(st),GroupOfPcgs(ue[i])) );

        # if <e>[i-1] is a subgroup of <ue>[i] we can skip this step
        elif ForAll( ei_1, x -> SiftedPcElement(ue[i],x) = id )  then
            Info( InfoPcNormalizer, 2, "<e>[",i,"] > <ue>[",i-1,"]" );
            Assert( 1, IsNormal(GroupOfPcgs(st),GroupOfPcgs(ue[i])) );

        # now do some real work
        else

            # remember the prime of the current section for later
            pi_1 := RelativeOrderOfPcElement( g, ei_1[1] );

            # get the first section
            ui_1 := NormalIntersectionPcgs( g, e[i-1], ue[i] );

            # if the factor is trivial do nothing
            if Length(ui_1) = Length(e[i])  then
                Info( InfoPcNormalizer, 2,
                      "<ue>[",i,"] /\\ <e>[",i-1,"] is trivial" );

            # if <f4> is true, use linear operations
            elif f4  then
                Info( InfoPcNormalizer, 2, "<ue>[", i, "] /\\ <e>[", i-1,
                      "] using linear operation" );

                s := PcGroup_LinearNO( s, ei_1, ui_1 );

            # otherwise use a normal stabilizer
            else
                Info( InfoPcNormalizer, 2, "<ue>[", i, "] /\\ <e>[", i-1,
                      "] using orbit" );
                s := PCGS_NORMALIZER( g, s, ui_1, e[i] );
            fi;

            # check the stabilizer
            Assert( 2, Stabilizer( GroupOfPcgs(st), GroupOfPcgs(ui_1) )
                     = GroupOfPcgs(s) );

            # now <ui_1> must be stabilized by <s>
            st := s;
            Assert( 1, IsNormal(GroupOfPcgs(st),GroupOfPcgs(ui_1)) );

            # find <ue>[i]/\<E>[j] which is larger then <ue>[i]/\<E>[i-1]
            j  := i-2;
            uj := NormalIntersectionPcgs( g, e[j], ue[i] );
            k  := i-1;
            uk := ui_1;
            while 0 < j and Length(uj) = Length(ui_1)  do
                Info( InfoPcNormalizer, 2, "<ue>[",i,"] /\\ <e>[", j,
                      "] = <ue>[", i, "] /\\ e[", k, "]" );
                k  := j;
                uk := uj;
                j  := j - 1;
                if 0 < j  then
                    uj := NormalIntersectionPcgs( g, e[j], ue[i] );
                fi;
            od;

    	    # The next step for <s> = Normalizer( <uk> ) is
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

            si_1 := NormalIntersectionPcgs(
                        g,
                        e[i-1],
                        NumeratorOfModuloPcgs(s) )
                    mod e[i];

            while 0<j and not ForAll(si_1,x ->SiftedPcElement(ui_1,x)=id)  do

                # this only works for subseries <e>
                tmp := First( e[j], x -> not x in e[j+1] );
                pj  := RelativeOrderOfPcElement( g, tmp );

                # cobounds
                if ( pj = pi_1 and f1 ) or ( pj <> pi_1 and f2 )  then
                    Info( InfoPcNormalizer, 2, "<ue>[", i, "] /\\ <e>[", j,
                          "] using cobounds" );

                    s := PcGroup_CoboundsNO( s, si_1, uj, uk );

                # glasby
                elif pj <> pi_1 and f3  then
                    Info( InfoPcNormalizer, 2, "<ue>[", i, "] /\\ <e>[", j,
                          "] using Glasby" );

                    s := PcGroup_GlasbyNO( s, si_1, uj, uk );

                # orbit
                else
                    Info( InfoPcNormalizer, 2, "<ue>[", i, "] /\\ <e>[", j,
                          "] using orbit" );
                    s := PCGS_NORMALIZER( g, s, uj, uk );
                fi;

                # check the stabilizer
                Assert( 2, Stabilizer( GroupOfPcgs(st), GroupOfPcgs(uj) )
                         = GroupOfPcgs(s) );

                # now <uj> must be stabilized by <s>
                st := s;
                Assert( 1, IsNormal(GroupOfPcgs(st),GroupOfPcgs(uj)) );

                # find the next non-trivial intersection
                k  := j;
                uk := uj;
                while 0 < j and Length(uj) = Length(uk)  do
                    if k <> j  then
                        Info( InfoPcNormalizer, 2, "<ue>[", i, "] /\\ <e>[",
                              j, "] = <ue>[", i, "] /\\ e[", k, "]" );
                    fi;

                    k  := j;
                    uk := uj;
                    j  := j - 1;
                    if 0 < j  then
                        uj := NormalIntersectionPcgs( g, e[j], ue[i] );
                    fi;
                od;

                # Now we know our new <S>, if <j>-1 is still nonzero, compute
                # the intersection in order to see, if we are finshed.

                if 0 < j  then
                    si_1 := NormalIntersectionPcgs(
                                g,
                                e[i-1],
                                NumeratorOfModuloPcgs(s) )
                            mod e[i];
                fi;

            od;
        fi;
    od;
    Assert( 1, IsNormal( GroupOfPcgs(s), u ) );

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