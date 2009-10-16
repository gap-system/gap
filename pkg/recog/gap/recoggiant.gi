#############################################################################
##
#W  recoggiant.g                                     Maska Law
#W                                                & 'Akos Seress
##
##
#Y  Copyright (C)  2004,  School of Mathematics and Statistics,
#Y                        The University of Western Australia.
##
##
##  This file provides code for recognising whether a permutation group
##  on n points is isomorphic to A_n or S_n acting naturally.
##
##
#############################################################################

DeclareInfoClass( "InfoGiants" );
SetInfoLevel( InfoGiants, 1 );


########################################################################
##
#F  WhichGiant(<grp>) . . . . . . . . . . . . . . . is <grp> A_n or S_n
##
##

RECOG.WhichGiant :=  function( grp )

    local  x ;

    for x in GeneratorsOfGroup( grp ) do
        if SignPerm(x) = -1 then return ["Sn"]; fi;
    od;

    return ["An"];

end;


#######################################################################
##
#F  NiceGeneratorsSn(<n>,<grp>,<N>) ...... find n-cycle, transposition
##
##

RECOG.NiceGeneratorsSn := function ( mp, grp, N )

    local t, cyclen, g, y, h, i, x, supp, n;

    n := Length(mp);
    while N > 0 do
	N := N - 1;
        t := PseudoRandom( grp );
        # was: cyclen := Collected( CycleLengths( t, [1..n] ) );
        cyclen := CycleStructurePerm(t);

        # was: if IsBound(g) = false and [n,1] in cyclen then
        if IsBound(g) = false and IsBound(cyclen[n-1]) then
	    # we found an $n$-cycle
            g := t;
        fi;
          
        if IsBound(y) = false and IsBound(cyclen[1]) and cyclen[1] = 1 and
               ForAll([1..QuoInt(n,2)-1],i->not(IsBound(cyclen[2*i+1]))) 
               # was: Filtered( cyclen, x -> x[1] mod 2 = 0 ) = [ [ 2,1 ] ]
        then
            # we can get a transposition
            y := t^(Lcm(Filtered([2..n],x->IsBound(cyclen[x-1])))/2);
        fi;

        if IsBound(g) and IsBound(y) then
            i := 10*n;
            supp := MovedPoints( y );
            while i > 0 do  # take up to i conjugates,
                            # check if they match the $n$-cycle
                i := i-1;
                x := PseudoRandom( grp );
                if (supp[1]^x)^g = supp[2]^x or (supp[2]^x)^g = supp[1]^x
                    then h := y^x;
                    return [ g, h ];
                fi;
	    od;
            return fail;
	fi;    

    od; # loop over random elements

    return fail;

end;


######################################################################
##
#F  ConjEltSn(<n>,<g>,<h>) . . . element c s.t. g^c=(1..n), h^c=(1,2)
##
##

RECOG.ConjEltSn :=  function( mp, g, h )

    local c,i,la,n,oo,pos,supp;

    n := Length(mp);
    la := mp[n];   # this is the largest moved point

    supp := MovedPoints( h );

    if supp[1]^g = supp[2] then pos := supp[1];
    else pos := supp[2];
    fi;

    c := [];
    for i in [ 1 .. n ] do 
        c[pos] := i;
        pos := pos^g;
    od;
    oo := Difference([1..la],mp);
    for i in [1..Length(oo)] do
        c[oo[i]] := i+n;
    od;

    return PermList( c );

end;


######################################################################
##
#F  RecogniseSn(<n>, <grp>, <N>) . . . . . . recognition function
##
##

RECOG.RecogniseSn :=  function( mp, grp, eps )

    local le, N, gens, c, n;

    n := Length(mp);

    le := 0;
    while 2^le < eps^-1 do
        le := le + 1;
    od;

    N := Int(24 * (4/3)^3 * le * 6 * n);

    gens := RECOG.NiceGeneratorsSn( mp, grp, N );
    if gens = fail then 
        Info(InfoGiants,1,"couldn't find nice generators for Sn");
        return fail;
    fi;

    c := RECOG.ConjEltSn( mp, gens[1], gens[2] );

    return rec( stamp := "Sn", degree := n, 
                gens := Reversed(gens),  conjperm := c );

end;


########################################################################
##
#F  NiceGeneratorsAnEven(<n>,<grp>,<N>) . . find (2,n-2)-cycle, 3-cycle
##
##

RECOG.NiceGeneratorsAnEven := function ( mp, grp, N )

    local l, t, cyclen, a, b, c, i, fp, suppb, others, g, h, n;

    n := Length(mp);
    l := One(grp);

    while N > 0 do
        N := N - 1;
        t := PseudoRandom( grp );
        # was: cyclen := Collected( CycleLengths( t, [1..n] ) );
        cyclen := CycleStructurePerm(t);

        # was: if IsBound(a) = false and [n-1,1] in cyclen then
        if IsBound(a) = false and IsBound(cyclen[n-2]) then
            # we found an $n-1$-cycle
            a := t;
        fi;

        if IsBound(b) = false and IsBound(cyclen[2]) and cyclen[2] = 1 and
               # Filtered( cyclen, x -> x[1] mod 3 = 0 ) = [ [ 3,1 ] ]
               ForAll( [2..QuoInt(n,3)], x->not(IsBound(cyclen[3*x-1])) )
        then
            # we can get a $3$-cycle
            #b := t^(Lcm(List(cyclen,x->x[1]))/3);
            b := t^(Lcm(Filtered([2..n],x->IsBound(cyclen[x-1])))/3);
        fi;

        if IsBound(a) and IsBound(b) then
            i := 10*n;
            fp := Difference( mp, MovedPoints(a) )[1];
            suppb:= MovedPoints( b );
            while i > 0 do
                i := i-1;
                t := PseudoRandom( grp );
                if fp in List( suppb, x -> x^t ) then
                    c := b^t;
                    others := [ fp^c, (fp^c)^c ];
                    if others[1]^a = others[2] then
                        h := c;
                    elif others[2]^a = others[1] then
                        h := c^2;
                    else
                        h := Comm(c^a,c);   # h = (1,i,i+1)
                    fi;
                    g := a * h;
                    return [ g, h ];
                fi;
            od; # while

            return fail;
        fi;

    od; # loop over random elements

    return fail;

end;


#########################################################################
##
#F  NiceGeneratorsAnOdd(<n>,<grp>,<N>) . . . . find (n-2)-cycle, 3-cycle
##
##

RECOG.NiceGeneratorsAnOdd := function ( mp, grp, N )

    local l, t, cyclen, a, b, i, suppb, suppc, suppca, imc, h, g, n;

    n := Length(mp);
    l := One(grp);

    while N > 0 do
	N := N - 1;
	t := PseudoRandom( grp );
        # was: cyclen := Collected( CycleLengths( t, [1..n] ) );
        cyclen := CycleStructurePerm(t);

        if IsBound(a) = false and IsBound(cyclen[n-1]) then
            # we found an $n$-cycle
            a := t;
        fi;

        if IsBound(b) = false and IsBound(cyclen[2]) and cyclen[2] = 1 and
               # was: Filtered( cyclen, x -> x[1] mod 3 = 0 ) = [ [ 3,1 ] ]
               ForAll( [2..QuoInt(n,3)], x->not(IsBound(cyclen[3*x-1])) )
        then
            # we can get a $3$-cycle
            #b := t^(Lcm(List(cyclen,x->x[1]))/3);
            b := t^(Lcm(Filtered([2..n],x->IsBound(cyclen[x-1])))/3);
        fi;
	    
        if IsBound(a) and IsBound(b) then 
            i := 10*n;
            suppb := MovedPoints( b );
            while i > 0 do
                i := i-1;
                t := PseudoRandom( grp );

                suppc := List( suppb, x -> x^t );  
                # support of c=b^t, say [i,j,k]

                suppca := List( suppc, x -> x^a );
                # support of c^a, so [i^a,j^a,k^a]

                imc := List( suppc, x -> ((x^(t^-1))^b)^t );
                # [i^c,j^c,k^c]

                if Length( Intersection( suppc, suppca ) ) = 2 then
                    # so c=b^t moves three consecutive points of a
                    if  suppca[1] = imc[1] or
                        suppca[2] = imc[2] or
                        suppca[3] = imc[3] then
                        # so c moves points in same order as a
                        h := b^t;
                    else
                        # so c moves points in opposite order to a
                        h := (b^2)^t;
                    fi;
                elif Length( Intersection( suppc, suppca ) ) = 1 then
                    # so c=b^t moves only two consecutive points of a
                    if suppca[1] = imc[1] or
                       suppca[2] = imc[2] or
                       suppca[3] = imc[3] then
                        # so c moves points in same order as a
                        h := b^t;
                        h := Comm( h^2, h^a );
                    else
                        # so c moves points in opposite order to a
                        h := b^t;
                        h := Comm( h, (h^a)^2 );
                    fi;
                fi;

                if IsBound( h ) then
                    g := a * h^2;
                    return [ g, h ];
                fi;

            od; # while

            return fail;
        fi;

    od; # loop over random elements

    return fail;

end;


#########################################################################
##
#F  ConjEltAnEven(<n>,<g>,<h>) . . . c s.t. g^c=(1,2)(3..n), h^c=(1,2,3)
##
##

RECOG.ConjEltAnEven := function( mp, g, h )
    local c,i,la,n,oo,pos,s1,s1g,supp;

    n := Length(mp);
    la := mp[n];    # this is the largest moved point

    supp := MovedPoints(h);  # {i,j,k} where h=(i,j,k), i^g=j, j^g=i
    s1 := supp[1];
    s1g := s1^g;

    c := [];
    if s1g in supp then      # {s1,s1g} = {i,j}
        if s1^h = s1g then   # [s1,s1g] = [i,j]
            c[s1] := 1;
            c[s1g] := 2;
        else
            c[s1g] := 1;
            c[s1] := 2;
        fi;
        pos := Difference(supp,Set([s1,s1g]))[1];
        for i in [3..n] do
            c[pos] := i;
            pos := pos^g;
        od;
        oo := Difference([1..la],mp);
        for i in [1..Length(oo)] do
            c[oo[i]] := i+n;
        od;
        
    else   # s1 = k
        if supp[2]^h = supp[2]^g then 
            c[supp[2]] := 1;
            c[supp[3]] := 2;
        else 
            c[supp[3]] := 1;
            c[supp[2]] := 2;
        fi;
        pos := s1;
        for i in [3..n] do
            c[pos] := i;
            pos := pos^g;
        od;
        oo := Difference([1..la],mp);
        for i in [1..Length(oo)] do
            c[oo[i]] := i+n;
        od;
    fi;

    return PermList( c );

end;


######################################################################
##
#F  ConjEltAnOdd(<n>,<g>,<h>) . . . . c s.t. g^c=(3..n), h^c=(1,2,3)
##
##

RECOG.ConjEltAnOdd := function( mp, g, h )
    local c,compt,i,la,n,oo,pos;

    n := Length(mp);
    la := mp[n];   # this is the largest moved point

    compt := Intersection( MovedPoints( g ), MovedPoints( h ) )[1];
    # compt is the common point moved by both g and h : so becomes 3

    c := [];
    c[ compt^h ] := 1;
    c[ (compt^h)^h ] := 2;

    pos := compt;

    for i in [3..n] do
        c[pos] := i;
        pos := pos^g;
    od;

    oo := Difference([1..la],mp);
    for i in [1..Length(oo)] do
        c[oo[i]] := i+n;
    od;

    return PermList(c);

end;


######################################################################
##
#F  RecogniseAn(<n>, <grp>, <N>) . . . . . . recognition function
##
##

RECOG.RecogniseAn :=  function( mp, grp, eps )

	local le, N, gens, c, n;

        n := Length(mp);

	le := 0;
	while 2^le < eps^-1 do
	    le := le + 1;
        od;

	N := Int(24 * (4/3)^3 * le * 6 * n);

        if n mod 2 = 0 then
	    gens := RECOG.NiceGeneratorsAnEven( mp, grp, N );
        else
            gens := RECOG.NiceGeneratorsAnOdd( mp, grp, N );
        fi;

	if gens = fail then 
            Info(InfoGiants,1,"couldn't find nice generators for An");
            return fail;
        fi;

        if n mod 2 = 0 then
            c := RECOG.ConjEltAnEven( mp, gens[1], gens[2] );
        else
            c := RECOG.ConjEltAnOdd( mp, gens[1], gens[2] );
        fi;

	return rec( stamp := "An", degree := n, 
                    gens := Reversed(gens), conjperm := c );
end;


######################################################################
##
#F  RecogniseGiant(<n>, <grp>, <N>) . . . . . . recognition function
##
##
##  This is the main function.
##

RECOG.RecogniseGiant :=  function( mp, grp, eps )

    if RECOG.WhichGiant( grp ) = [ "Sn" ] then
        return RECOG.RecogniseSn( mp, grp, eps );
    else
        return RECOG.RecogniseAn( mp, grp, eps );
    fi;

end;


########################################################################
##
#F  FindImageGiant(<pi>, <data>) . . . . . image of pi under conj perm
##
##

RECOG.FindImageGiant :=  function( pi, data )

    return pi^data.conjperm;

end;


########################################################################
##
#F  FindHomomorphismMethods.Giant
##

RECOG.IsGiant:=function(g,mp)
  local bound, i, p, cycles, l, x, n;
  n := Length(mp);
  bound:=20*LogInt(n,2);
  i:=0;
  repeat
    i:=i+1;
    p:=PseudoRandom(g);
    x:=Random(mp);
    l:=CycleLength(p,x);
  until (i>bound) or (l> n/2 and l<n-2 and IsPrime(l));
  if i>bound then
    return fail;
  else
    return true;
  fi;
end;

##  SLP for pi from (1,2), (1,...,n)

RECOG.SLPforSn :=  function( n, pi )

    local cycles, initpts, c, newc, i, R, ci, cycslp, k ;

    if IsOne(pi) then
        return StraightLineProgramNC( [[1,0]], 2 );
    fi;

    # we need the cycles of pi of length > 1 to be written such 
    # that the minimum point is the initial point of the cycle
    initpts := [ ];
    cycles := [ ];
    for c in Filtered( Cycles( pi, [ 1 .. n ] ), c -> Length(c) > 1 ) do
        i := Minimum( c );
        Add( initpts, i );
        if i = c[1] then 
            Add( cycles, c );
        else
            newc := [ i ];
            for k in [ 2 .. Length(c) ] do
                Add( newc, newc[k-1]^pi );
            od;
            Add( cycles, newc );
        fi;
    od;

    # R will be a straight line program from tau_1, sigma_1
    # we update cycle product, tau_i+1, sigma_i+2
    # and then overwrite the updates into positions 1,2,3
    R := [ [1,0], [3,1], [1,1], [2,1,1,1], 
                    [[4,1],1], [[5,1],2], [[6,1],3] ];
    i := 1;
    repeat
        if i in initpts then
            # ci is the cycle of pi beginning with i
            ci := cycles[ Position( initpts, i ) ];
            # cycslp is the SLP for ci from tau_i and sigma_i+1
            cycslp := [ 1,1, 3,1+ci[1]-ci[2] ];
            for k in [ 2 .. Length(ci)-1 ] do
                Append( cycslp, [ 2,1, 3,ci[k]-ci[k+1] ] );
            od;
            Append( cycslp, [ 2,1, 3,ci[Length(ci)]-ci[1]-1 ] );
            Append( R, [ [cycslp,4] ]);
        else    # we carry forward cycle product computed so far
            Append( R, [ [[1,1],4] ] );
        fi;
                # we update tau_i+1 and sigma_i+2
        Append( R, [ [[2,1,3,-1,2,1,3,1,2,1],5],
                 [[3,1,2,1,3,-1,2,1,3,1,2,1],6],
                [[4,1],1], [[5,1],2], [[6,1],3] ]);
        i := i + 1;
    until i > Maximum( initpts );

    # the return value
    Add(R,[ [1,1],1 ]);

    # R is a straight line program with 2 inputs
    R:=StraightLineProgramNC( R, 2 );

    return R;

end;


##  SLP for pi from (1,2,3), sigma

RECOG.SLPforAn :=  function( n, pi )

    local cycles, initpts, c, newc,  R, i, nexttrpn, ci, cycslp, k, j,
          nexttau, nextsigma ;

    if IsOne(pi) then
        return StraightLineProgramNC( [[1,0]], 2 );
    fi;
    if SignPerm( pi ) = -1 then
        return fail;
    fi;

    # we need the cycles of pi of length > 1 to be written such 
    # that the minimum point is the initial point of the cycle
    initpts := [ ];
    cycles := [ ];
    for c in Filtered( Cycles( pi, [ 1 .. n ] ), c -> Length(c) > 1 ) do
        i := Minimum( c );
        Add( initpts, i );
        if i = c[1] then 
            Add( cycles, c );
        else
            newc := [ i ];
            for k in [ 2 .. Length(c) ] do
                Add( newc, newc[k-1]^pi );
            od;
            Add( cycles, newc );
        fi;
    od;

    # R will be a straight line program from tau_1, sigma_1
    # we update cycle product, tau_i+1, sigma_i+1
    # and then overwrite the updates into positions 1,2,3
    R := [ [1,0], [3,1], [1,1], [2,1],
                  [[4,1],1], [[5,1],2], [[6,1],3] ];
    i := 1;

    # we keep track of which transposition of pi we must compute next
    nexttrpn := 1;

    repeat
      if i in initpts then
        # ci is the cycle of pi beginning with i
        ci := cycles[ Position( initpts, i ) ];
        # cycslp is the SLP for ci from tau_i and sigma_i
        # we carry forward the cycle product computed so far
        cycslp := [ 1,1 ];
        for k in [ 2 .. Length(ci) ] do
            j := ci[k];  # so (i,j)=(ci[1],ci[k])
            if j < n-1 then
                # NB: if i < j < n-1 then (i,j)(n-1,n) = (n-1,n)(i,j)
                if j = i+1 then
                    if IsEvenInt( n-i ) then
                        Append( cycslp, [ 3,i+2-n, 2,2, 3,1, 2,1, 
                                          3,-1, 2,2, 3,n-i-2 ] );
                    else
                        Append( cycslp, [ 3,i+2-n, 2,1, 3,1, 2,1, 
                                          3,-1, 2,1, 3,n-i-2 ] );
                    fi;
                else
                    if IsEvenInt( n-i ) then
                        Append( cycslp, [ 3,i+2-j, 2,1, 3,j-n, 
                                          2,2, 3,1, 2,1, 3,-1, 2,2, 
                                          3,n-j, 2,2, 3,j-i-2 ] );
                    elif IsOddInt( n-i ) and IsEvenInt( j-i-2 ) then
                        Append( cycslp, [ 3,i+2-j, 2,1, 3,j-n, 
                                          2,1, 3,1, 2,1, 3,-1, 2,1,
                                          3,n-j, 2,2, 3,j-i-2 ] );
                    else
                        Append( cycslp, [ 3,i+2-j, 2,2, 3,j-n, 
                                          2,1, 3,1, 2,1, 3,-1, 2,1,
                                          3,n-j, 2,1, 3,j-i-2 ] );
                    fi;
                fi;
            elif ( j = n-1 or j = n ) and i < n-1 then
                if ( j = n-1 and IsOddInt( nexttrpn ) ) or
                   ( j = n and IsEvenInt( nexttrpn ) ) then
                    if IsEvenInt( n-i ) then
                        Append( cycslp,
                                [ 3,i+2-n, 2,2, 3,1, 2,1, 3,n-i-3  ] );
                    else
                        Append( cycslp,
                                [ 3,i+2-n, 2,1, 3,1, 2,1, 3,n-i-3  ] );
                    fi;
                elif ( j = n and IsOddInt( nexttrpn ) ) or
                     ( j = n-1 and IsEvenInt( nexttrpn ) ) then
                    if IsEvenInt( n-i ) then
                        Append( cycslp,
                                [ 3,i+3-n, 2,2, 3,-1, 2,1, 3,n-i-2  ] );
                    else
                        Append( cycslp,
                                [ 3,i+3-n, 2,2, 3,-1, 2,2, 3,n-i-2  ] );
                    fi;
                fi;
            else   # (i,j) = (n-1,n)
                Append( cycslp, [ ] );
            fi;

            nexttrpn := nexttrpn + 1;
        od;
        Append( R, [ [cycslp,4] ] );

      else  # not (i in initpts)  
        # we carry forward cycle product computed so far
        Append( R, [ [[1,1],4] ] );
      fi;

      # we update tau_i+1 and sigma_i+1
      if IsEvenInt(n-i) then
          nexttau   := [ 2,-1,3,-1,2,1,3,1,2,1 ];
          nextsigma := [ 3,1,5,1 ];
      else
          nexttau   := [ 2,-1,3,-1,2,2,3,1,2,1 ];
          nextsigma := [ 3,1,2,2,5,-1 ];
      fi;

      Append( R, [ [nexttau,5], [nextsigma,6],
                     [[4,1],1], [[5,1],2], [[6,1],3] ]);
      i := i + 1;

    until i > Maximum( initpts );

    # the return value
    Add(R,[ [1,1],1 ]);

    # R is a straight line program with 2 inputs
    R:=StraightLineProgramNC( R, 2 );

    return R;

end;


RECOG.GiantEpsilon := 1/1024;

FindHomMethodsPerm.Giant :=
  function(ri,grp)
    local grpmem,mp,res;
    if not(IsPermGroup(grp)) then
        return NotApplicable;
    fi;
    if not(IsTransitive(grp)) then
        return false;
    fi;
    mp := MovedPoints(grp);
    if RECOG.IsGiant(grp,mp) = fail then
        return fail;
    fi;
    grpmem := GroupWithMemory(grp);
    res := RECOG.RecogniseGiant(mp,grpmem,RECOG.GiantEpsilon);
    if res = fail then
        return fail;
    fi;
    res.slpnice := SLPOfElms(res.gens);
    # Note that when putting the generators into the record, we reverse
    # their order, such that it fits to the SLPforSn/SLPforAn function!
    Setslpforelement(ri,SLPforElementFuncsPerm.Giant);
    ri!.giantinfo := res;
    SetFilterObj(ri,IsLeaf);
    if res.stamp = "An" then
        SetSize(ri,Factorial(Length(mp))/2);
    else
        SetSize(ri,Factorial(Length(mp)));
    fi;
    Setnicegens(ri,StripMemory(res.gens));
    Setslptonice(ri,res.slpnice);
    return true;
  end;

SLPforElementFuncsPerm.Giant :=
  function(ri,g)
    local gg;
    gg := g^ri!.giantinfo.conjperm;
    # Note that when putting the generators into the record, we reverse
    # their order, such that it fits to the SLPforSn/SLPforAn function!
    if ri!.giantinfo.stamp = "An" then
        return RECOG.SLPforAn(ri!.giantinfo.degree,gg);
    else   # Sn
        return RECOG.SLPforSn(ri!.giantinfo.degree,gg);
    fi;
  end;


