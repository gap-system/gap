#############################################################################
##
#W  grppcfp.gi                  GAP library                      Bettina Eick
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains some functions to convert a pc group into an
##  fp group and vice versa.
##
Revision.grppcfp_gi :=
    "@(#)$Id$";

#############################################################################
##
#F  PcGroupFpGroup( F )
##
InstallGlobalFunction( PcGroupFpGroup, function( F )
    return PolycyclicFactorGroup(
        FreeGroupOfFpGroup( F ),
        RelatorsOfFpGroup( F ) );
end );

#############################################################################
##
#M  IsomorphismFpGroupByGenerators( G, gens, str )
##
InstallMethod( IsomorphismFpGroupByGenerators,
               "method for pc groups", true,
               [IsGroup, IsList, IsString], 0,
function( G, gens, str )
    local F, hom, rels, H, gensH, iso;
    F   := FreeGroup( Length(gens), str );
    hom := GroupGeneralMappingByImages( G, F, gens, GeneratorsOfGroup(F) );
    rels := GeneratorsOfGroup( CoKernelOfMultiplicativeGeneralMapping( hom ) );
    H := F /rels;
    gensH := GeneratorsOfGroup( H );
    iso := GroupHomomorphismByImagesNC( G, H, gens, gensH );
    SetIsBijective( iso, true );
    SetKernelOfMultiplicativeGeneralMapping( iso, TrivialSubgroup(G) );
    return iso;
end );

InstallOtherMethod( IsomorphismFpGroupByGenerators,
                    "method for pc groups", true,
                    [IsGroup, IsList], 0,
function( G, gens )
    return IsomorphismFpGroupByGenerators( G, gens, "F" );
end );

#############################################################################
##
#F  IsomorphismFpGroupByPcgs( pcgs, str )
##
InstallGlobalFunction( IsomorphismFpGroupByPcgs, function( pcgs, str )
    local n, F, gens, rels, i, pis, exp, t, h, rel, comm, j, H, phi;

    n    := Length( pcgs );
    F    := FreeGroup( n, str );
    gens := GeneratorsOfGroup( F );
    pis  := RelativeOrders( pcgs );
    rels := [ ];
    for i in [1..n] do

        # the power
        exp := ExponentsOfRelativePower( pcgs, i ){[i+1..n]};
        t   := One( F );
        for h in [i+1..n] do
            t := t * gens[h]^exp[h-i];
        od;
        rel := gens[i]^pis[i] / t;
        Add( rels, rel );

        # the commutators
        for j in [i+1..n] do
            comm := Comm( pcgs[j], pcgs[i] );
            exp := ExponentsOfPcElement( pcgs, comm ){[i+1..n]};
            t   := One( F );
            for h in [i+1..n] do
                t := t * gens[h]^exp[h-i];
            od;
            rel := Comm( gens[j], gens[i] ) / t;
            Add( rels, rel );
        od;
    od;
    H := F / rels;
    phi := 
      GroupHomomorphismByImagesNC( GroupOfPcgs(pcgs), H, AsList( pcgs ),
                                        GeneratorsOfGroup( H ) );

    SetIsBijective( phi, true );
    return phi;
    
end );

#############################################################################
##
#M  IsomorphismFpGroupByCompositionSeries( G, str )
##
InstallMethod( IsomorphismFpGroupByCompositionSeries, 
               "method for pc groups",
               true,
               [IsGroup and CanEasilyComputePcgs, IsString],
               0,
function( G, str )
    return IsomorphismFpGroupByPcgs( Pcgs(G), str );
end);

InstallOtherMethod( IsomorphismFpGroupByCompositionSeries, 
               "method for pc groups",
               true,
               [IsGroup and CanEasilyComputePcgs],
               0,
function( G )
    return IsomorphismFpGroupByPcgs( Pcgs(G), "F" );
end);

#############################################################################
##
#O  IsomorphismFpGroup( G )
##
InstallMethod( IsomorphismFpGroup, 
               "method for pc groups",
               true,
               [IsGroup and CanEasilyComputePcgs],
               0,
function( G )
    return IsomorphismFpGroupByPcgs( Pcgs( G ), "F" );
end );
               
#############################################################################
##
#F  SmithNormalFormSQ( mat )
##
##  returns D = diagonalised form, M = P * D * Q, I = Q^-1
##
InstallGlobalFunction( SmithNormalFormSQ, function( M )
	local	divisor, minimum, diagonal,
	    	col_add, row_add, reduce_col, reduce_row,
		    k, l, pos, h, i, j, P, Q, I;

	col_add := function ( h, f, j )
		local	i;
		for i in [ pos..Length( M ) ] do
			M[i][h] := M[i][h] + f * M[i][j];
		od;
		for i in [ 1..Length( M[1] ) ] do
			Q[i][h] := Q[i][h] + f * Q[i][j];
		od;
		I[j] := I[j] - f * I[h];
	end;

	diagonal := function ()
		local	i, j;
		for i in [ pos..Length( M ) ] do
			for j in [ pos..Length( M[1] ) ] do
				if i <> j and M[i][j] <> 0 then
					return( false );
				fi;
			od;
		od;
		return( true );
	end;

	divisor := function ( div )
		local	i, j;
		for i in [ pos..Length( M ) ] do
			for j in [ pos..Length( M[1] ) ] do
				if M[i][j] mod div <> 0 then
					k := i; l := j; return( false );
				fi;
			od;
		od;
		return( true );
	end;

	minimum := function()
		local	abs, i, j, min;
		min := 0;
		for i in [ pos..Length( M ) ] do
		    for j in [ pos..Length( M[1] ) ] do
			if M[i][j] <> 0 then
				abs := AbsInt( M[i][j] );
				if abs < min or min = 0 then
					min := abs; k := i; l := j;
				fi;
			fi;
		    od;
		od;
		return( min );
	end;

	reduce_col := function ()
	    local	h, i, min;
	    for i in [ pos+1..Length( M ) ] do
	      if M[i][pos] <> 0 then
		repeat
		  min := M[pos][pos];
		  if M[i][pos] mod min = 0 then
		    row_add( i, -QuoInt( M[i][pos], min ), pos );
		  else
		    row_add( i, -QuoInt( M[i][pos], min ), pos );
		    h := M[i]; M[i] := M[pos]; M[pos] := h;
		    h := P[i]; P[i] := P[pos]; P[pos] := h;
		  fi;
		until M[i][pos] = 0;
	      fi;
	    od;
	end;

	reduce_row := function ()
	    local	h, i, j, min;
	    for j in [ pos+1..Length( M[1] ) ] do
	      if M[pos][j] <> 0 then
		repeat
		  min := M[pos][pos];
		  if M[pos][j] mod min = 0 then
		    col_add( j, -QuoInt( M[pos][j], min ), pos );
		  else
		    col_add( j, -QuoInt( M[pos][j], min ), pos );
		    for i in [ pos..Length( M ) ] do
			h := M[i][j]; M[i][j] := M[i][pos]; M[i][pos] := h;
		    od;
		    for i in [ 1..Length( M[1] ) ] do
			h := Q[i][j]; Q[i][j] := Q[i][pos]; Q[i][pos] := h;
		    od;
		    h := I[j]; I[j] := I[pos]; I[pos] := h;
		    reduce_col();
		  fi;
		until M[pos][j] = 0;
	      fi;
	    od;
	end;

	row_add := function ( i, f, k )
		local	j;
		for j in [ pos..Length( M[1] ) ] do
			M[i][j] := M[i][j] + f * M[k][j];
		od;
		for j in [ 1..Length( M ) ] do
			P[i][j] := P[i][j] + f * P[k][j];
		od;
	end;

    # here starts the main function
	P := IdentityMat( Length( M ) );
	M := List( M, ShallowCopy );
	Q := IdentityMat( Length( M[1] ) );
	I := IdentityMat( Length( M[1] ) );

	for pos in [ 1..Minimum( Length( M ), Length( M[1] ) ) ] do
	    if minimum() <> 0 then

		h := M[k]; M[k] := M[pos]; M[pos] := h;
		h := P[k]; P[k] := P[pos]; P[pos] := h;
		for i in [ pos..Length( M ) ] do
			h := M[i][l]; M[i][l] := M[i][pos]; M[i][pos] := h;
		od;
		for i in [ 1..Length( M[1] ) ] do
			h := Q[i][l]; Q[i][l] := Q[i][pos]; Q[i][pos] := h;
		od;
		h := I[l]; I[l] := I[pos]; I[pos] := h;

		reduce_col(); reduce_row();
		while not divisor( M[pos][pos] ) do
		    col_add( pos, 1, l ); reduce_col(); reduce_row();
		od;

		if M[pos][pos] < 0 then
			M[pos][pos] := -M[pos][pos];
			for j in [ 1..Length( M ) ] do
				P[pos][j] := -P[pos][j];
			od;
		fi;

	    fi;
	od;
	return( rec( D := M, P := P, Q := Q, I := I ) );
end );

#############################################################################
##
#F  InitEpimorphismSQ( F )
##
InstallGlobalFunction( InitEpimorphismSQ, function( F )
	local g, gens, r, rels, ng, nr, pf, pn, pp, D, P, M, Q, I, A, G, min,
      	  gensA, relsA, gensG, imgs, prei, i, j, k, l, norm, index, diag, n;

	gens := GeneratorsOfGroup( FreeGroupOfFpGroup( F ) );
    ng   := Length( gens );
	rels := RelatorsOfFpGroup( F );
    nr   := Length( rels );

	# build the relation matrix for the commutator  quotient  group
	M := [];
	for i in [ 1..Maximum( nr, ng ) ] do
	    M[i] := List( [ 1..ng ], i->0 );
	    if i <= nr then
  		    r := rels[i];
		    for j in [ 1..Length( r ) ] do
		        g := Subword( r, j, j );
		        k := 1;
		        while (g <> gens[k]) and (g^-1<>gens[k]) do
				    k := k+1;
		        od;
		        if g = gens[k] then
			        M[i][k] := M[i][k] + 1;
		        else
			        M[i][k] := M[i][k] - 1;
		        fi;
		    od;
	    fi;
	od;

    # compute normal form
	norm := SmithNormalFormSQ( M );
	D := norm.D; 
    P := norm.P; 
    Q := norm.Q; 
    I := norm.I;
    min := Minimum( Length(D), Length(D[1]) );
    diag := List( [1..min], x -> D[x][x] );
    if ForAny( diag, x -> x = 0 ) then
        Print("solvable quotient is infinite \n");
        return false;
    fi;

    # compute pc presentation for the finite quotient
    n := Filtered( diag, x -> x <> 1 );
    n := Length( Flat( List( n, x -> FactorsInt( x ) ) ) );
    A := FreeGroup( n );
	gensA := GeneratorsOfGroup( A );

	index := [];
    relsA := []; 
	g := 1;	
    pf := [];
	for i in [ 1..ng ] do
	    if D[i][i] <> 1 then
	        index[i] := g;
	        pf[i] := TransposedMat( Collected( FactorsInt( D[i][i] ) ) );
            pf[i] := rec( factors := pf[i][1],
                          powers  := pf[i][2] );
	        for j in [ 1..Length( pf[i].factors ) ] do
		        pn := pf[i].factors[j];
          	    pp := pf[i].powers [j];
		        for k in [ 1..pp ] do
		            relsA[g] := []; 
                    relsA[g][g] := gensA[g]^pn;
		            for l in [ 1..g-1 ] do
		                relsA[g][l] := gensA[g]^gensA[l]/gensA[g];
		            od;
		            if j <> 1 or k <> 1 then
		                relsA[g-1][g-1] := relsA[g-1][g-1]/gensA[g];
		            fi;
		            g := g + 1;
		        od;
	        od;
	    fi;
	od;

    relsA := Flat( relsA );
    A     := A / relsA;

    # compute corresponding pc group
	G := PcGroupFpGroup( A );
    gensG := Pcgs( G );
  
    # set up epimorphism F -> A -> G
	imgs  := [];
	for i in [ 1..ng ] do
	    imgs[i] := One( G );
		for j in [ 1..ng ] do
		    if Q[i][j] <> 0 and D[j][j] <> 1 then
			    imgs[i] := imgs[i] * gensG[index[j]]^( Q[i][j] mod D[j][j] );
		    fi;
		od;
	od;

    # compute preimages
	prei := [];
	for i in [ 1..ng ] do
		if D[i][i] <> 1 then
		    r := One( FreeGroupOfFpGroup( F ) );
		    for j in [ 1..ng ] do
		    	if imgs[j] <> One( G ) then
		    	    r := r * gens[j] ^ ( I[i][j] mod Order( imgs[j] ) );
		    	fi;
		    od;
		    g := index[i];
		    for j in [ 1..Length( pf[i].factors ) ] do
		    	pn := pf[i].factors[j];
		    	pp := pf[i].powers [j];
		    	for k in [ 1..pp ] do
		    	    prei[g] := r; 
                    g := g + 1; 
                    r := r ^ pn;
		    	od;
		    od;
		fi;
	od;

    return rec( source := F,
                image  := G,
                imgs   := imgs,
                prei   := prei );
end );

#############################################################################
##
#F  LiftEpimorphismSQ( epi, M, c )
##
InstallGlobalFunction( LiftEpimorphismSQ, function( epi, M, c )
    local F, G, pcgsG, n, H, pcgsH, d, gensf, pcgsN, htil, gtil, mtil,
          w, e, g, m, i, A, V, rel, l, v, mats, j, t, mat, k, elms, imgs,
          lift, null, vec, new, U, sol, sub, elm, r;

    F := epi.source;
    gensf := GeneratorsOfGroup( FreeGroupOfFpGroup( F ) );
    r := Length( gensf );

    d := M.dimension;

    G := epi.image;
    pcgsG := Pcgs( G );
    n := Length( pcgsG );

    H := Extension( G, M, c );
    pcgsH := Pcgs( H );
    pcgsN := InducedPcgsByPcSequence( pcgsH, pcgsH{[n+1..n+d]} );


    htil := pcgsH{[1..n]};
    gtil := [];
    mtil := [];
    for w in epi.imgs do
        e := ExponentsOfPcElement( pcgsG, w );
        g := PcElementByExponentsNC( pcgsH, htil, e );
        Add( gtil, g );
        m := Immutable( IdentityMat( d, M.field ) );
        for i in [1..n] do
            m := m * M.generators[i]^e[i];
        od;
        Add( mtil, m );
    od;

    # set up inhom eq
    A := List( [1..r*d], x -> [] );
    V := [];

    # for each relator of G add 
    for rel in RelatorsOfFpGroup( F ) do
        l := Length( rel );

        # right hand side
        v := MappedWord( rel, gensf, gtil );
        v := ExponentsOfPcElement( pcgsN, v ) * One( M.field );
        Append( V, v );
   
        # left hand side
        mats := ListWithIdenticalEntries( r,
                    Immutable( NullMat( d, d, M.field ) ) );
        for i in [1..l] do
            g := Subword( rel, i, i );
            j := Position( gensf, g );
            if not IsBool( j ) then
                if i+1 <= l then
                    t := Subword( rel, i+1, l );
                else
                    t := One( FreeGroupOfFpGroup( F ) );
                fi;
                mat := MappedWord( t, gensf, mtil );
                mats[j] := mats[j] + mat;
            elif IsBool( j ) then
                j := Position( gensf, g^-1 );
                t := Subword( rel, i, l );
                mat := MappedWord( t, gensf, mtil );
                mats[j] := mats[j] - mat;
            fi;
        od;
        for i in [1..r] do
            for j in [1..d] do
                k := d * (i-1) + j;
                Append( A[k], mats[i][j] );
            od;
        od; 
    od;
    sol := SolutionMat( A, V );

    # if there is no solution, then there is no lift
    if sol = fail then return false; fi;
#T return value should be fail?

    # create lift
    elms := [];
    for i in [1..r] do
        sub := sol{[d*(i-1)+1..d*i]}; 
        elm := PcElementByExponentsNC( pcgsN, sub );
        Add( elms, elm );
    od;
    imgs := List( [1..r], x -> gtil[x] * elms[x] ) ;
    lift := rec( source := F,
                 image  := H, 
                 imgs   := imgs ); 

    # in non-split case this is it
    if IsRowVector( c ) then return lift; fi;
  
    # otherwise check
    U    := Subgroup( H, imgs );
    if Size( U ) = Size( H ) then return lift; fi;

    # this is not optimal - see Plesken
    null := NullspaceMat( A );
    for vec in null do
        new  := vec + sol;
        elms := [];
        for i in [1..r] do
            sub := new{[d*(i-1)+1..d*i]}; 
            elm := PcElementByExponentsNC( pcgsN, sub );
            Add( elms, elm );
        od;
        imgs := List( [1..r], x -> gtil[x] * elms[x] );
        U    := Subgroup( H, imgs );
        if Size( U ) = Size( H ) then
            lift := rec( source := F,
                         image  := H, 
                         imgs   := imgs );
            return lift;
        fi;
    od;

    # give up 
    return false;
end );

#############################################################################
##
#F  BlowUpCocycleSQ( v, K, F )
##
InstallGlobalFunction( BlowUpCocycleSQ, function( v, K, F )
    local Q, B, vectors, hlp, i, k;

    if F = K then return v; fi;

    Q := AsField( K, F );
    B := Basis( Q );
    vectors:= BasisVectors( B );
    hlp := [];
    for i in [ 1..Length( v ) ] do
        for k in [ 1..Length( vectors ) ] do
        	Add( hlp, Coefficients( B, v[i] * vectors[k] )[1] );
        od;
    od;
    return hlp;
end );

#############################################################################
##
#F  TryModuleSQ( epi, M )
##
InstallGlobalFunction( TryModuleSQ, function( epi, M )
    local  C, lift, co, cb, cc, r, q, j, k, l, v, qi, c;

    # first try a split extension
    lift := LiftEpimorphismSQ( epi, M, 0 );
    if not IsBool( lift ) then return lift; fi;

    # get collector
    C := CollectorSQ( epi.image, M.absolutelyIrreducible, true );

    # compute the two cocycles
    co := TwoCocyclesSQ( C, epi.image, M.absolutelyIrreducible );

    # if there is one non split extension,  try all mod coboundaries
    if 0 < Length(co) then
        cb := TwoCoboundariesSQ( C, epi.image, M.absolutelyIrreducible );

        # use only those coboundaries which lie in <co>
        if 0 < Length(C.avoid)  then
            cb := SumIntersectionMat( co, cb )[2];
        fi;

        # convert them into row spaces
        if 0 < Length(cb)  then
            cc  := BaseSteinitzVectors( co, cb ).factorspace;
        else
            cc := co;
        fi;

        # try all non split extensions
        if 0 < Length(cc)  then
            r  := PrimitiveRoot( M.absolutelyIrreducible.field );
            q  := Size( M.absolutelyIrreducible.field );

            # loop over all vectors of <cc>
            for j in [ 1 .. Length(cc) ]  do
                for k in [ 0 .. q^(Length(cc)-j)-1 ]  do
                    v := cc[Length(cc)-j+1];
                    for l in [ 1 .. Length(cc)-j ]  do
                        qi := QuoInt( k, q^(l-1) );
                        if qi mod q <> q-1  then
                            v := v + r^(qi mod q) * cc[l];
                        fi;
                    od;

                    # blow cocycle up
                    c := BlowUpCocycleSQ( v, M.field, 
                         M.absolutelyIrreducible.field );

                    # try to lift epimorphism
                    lift := LiftEpimorphismSQ( epi, M, c );

                    # return if we have found a lift
                    if not IsBool( lift ) then return lift; fi;
                od;
            od;
        fi;
    fi;

    # give up
    return false;
end );

#############################################################################
##
#F  TryLayerSQ( epi, layer )
##
InstallGlobalFunction( TryLayerSQ, function( epi, layer )
    local field, dim, reps, rep, lift;

    # compute modules for prime
    field := GF(layer[1]);
    dim   := layer[2];
    reps  := IrreducibleModules( epi.image, field, dim );
    reps:=reps[2]; # the actual modules
        
    # loop over the representations
    for rep in reps do
        lift := TryModuleSQ( epi, rep );
        if not IsBool( lift ) then
           if not layer[3] or rep.dimension = dim then
               return lift;
           fi; 
        fi;
    od;
    
    # give up
    return false;
end );

#############################################################################
##
#F  SQ( <F>, <...> ) / SolvableQuotient( <F>, <...> )
##
InstallGlobalFunction( SolvableQuotient, function ( F, primes )
    local G, epi, tup, lift, i, found, fac, j, p;

    # initialise epimorphism
    epi := InitEpimorphismSQ(F);
    G   := epi.image;
    Print("init done, quotient has size ",Size(G)," \n");

    # if the commutator factor group is trivial return
    if Size( G ) = 1 then return epi; fi;

    # if <primes> is a list of tuples, it denotes a chief series
    if IsList( primes ) and IsList( primes[1] ) then
        Print("have chief series given \n");
        for tup in primes{[2..Length(primes)]} do
            Print("  trying ", tup,"\n");
            tup[3] := true;
            lift := TryLayerSQ( epi, tup );
            if IsBool( lift ) then 
                return epi;
            else
                epi := ShallowCopy( lift );
                G   := epi.image;
            fi;
            Print("  found quotient of size ", Size(G),"\n");
        od;
    fi;

    # if <primes> is a list of primes, we have to use try and error
    if IsList( primes ) and IsInt( primes[1] ) then
        found := true;
        i     := 1;
        while found and i <= Length( primes ) do
            p := primes[i];
            tup := [p, 0, false];
            Print("  trying ", tup,"\n");
            lift := TryLayerSQ( epi, tup );
            if not IsBool( lift ) then
                epi := ShallowCopy( lift );
                G := epi.image;
                found := true;
                i := 1; 
            else
                i := i + 1;
            fi;
            Print("  found quotient of size ", Size(G),"\n");
        od;
    fi;
                
    # if <primes> is an integer it is size we want
    if IsInt(primes)  then
        i := primes / Size( G );
        found := true;
        while i > 1 and found do
            fac := Collected( FactorsInt( i ) );
            found := false;
            j := 1;
            while not found and j <= Length( fac ) do
                fac[j][3] := false;
                Print("  trying ", fac[j],"\n");
                lift := TryLayerSQ( epi, fac[j] );
                if not IsBool( lift ) then
                    epi := ShallowCopy( lift );
                    G := epi.image;
                    found := true;
                    i := primes / Size( G );
                else
                    j := j + 1;
                fi;
                Print("  found quotient of size ", Size(G),"\n");
            od;
        od;
    fi;

    # this is the result - should be G only with setted epimorphism
    return epi;
end );

#InstallGlobalFunction( SQ, SolvableQuotient );

