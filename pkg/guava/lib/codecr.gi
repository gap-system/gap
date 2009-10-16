#############################################################################
##
#A  codecr.gi               GUAVA library                       Reinald Baart
#A                                                         Jasper Cramwinckel
#A                                                            Erik Roijackers
#A                                                                Eric Minkes
##
##  This file contains functions for calculating with code covering radii
##
#H  @(#)$Id: codecr.gi,v 1.8 2004/12/20 21:26:06 gap Exp $
##
## changes 10-2004:
## 1. CalculateLinearCodeCoveringRadius changed to a slightly faster
##    algorithm.
## 2. minor bug fix for ExhaustiveSearchCoveringRadius
## 2. minor bug fix for IncreaseCoveringRadiusLowerBound
##
Revision.("guava/lib/codecr_gi") :=
    "@(#)$Id: codecr.gi,v 1.8 2004/12/20 21:26:06 gap Exp $";

########################################################################
##
#F  CoveringRadius( <code> )
##
##  Return the covering radius of <code>
##  In case a special algorithm for this code exist, call
##  it first.
##
##  Not useful for large codes.
##
##  That's why I changed it, see the manual for more details
##  -- eric minkes.
##


## Calculation is done in this function, instead of in the method, so that
## users can override the redundancy restriction if desired.  Note that
## this does not check the trivial cases checked in the method,

CalculateLinearCodeCoveringRadius := function( code )
  local H, wts,CLs,i,rho;
  if Redundancy(code) = 0 then
		return 0;
	else
#
#return Maximum( List( SyndromeTable( code ), i -> Weight( i[ 1 ] ) ) );
# (old version had line above in place of next 5)
    H:=CheckMat(code);
    CLs:=CosetLeadersMatFFE(H,LeftActingDomain(code));
    wts:=List([1..Length(CLs)],i->WeightVecFFE(CLs[i]));
    rho:=Maximum(wts);
    return rho;
  fi;
end;

InstallMethod(CoveringRadius, "method for linear code", true, 
	[IsLinearCode], 0, 
function( code )
    # call the special algorithm for this code, if it exists
    if HasSpecialCoveringRadius( code ) then 
        code!.boundsCoveringRadius :=
          SpecialCoveringRadius( code ) ( code );  
    fi;
    
    if Length( BoundsCoveringRadius( code ) ) = 1 then
        return code!.boundsCoveringRadius[ 1 ];
    else
		if Redundancy( code ) < 20 then
			code!.boundsCoveringRadius :=
			  [ CalculateLinearCodeCoveringRadius( code ) ];
		else
			##LR - this sets CR to an interval 
			InfoCoveringRadius(
			  "CoveringRadius: warning, the covering radius of \n",
			  "this code cannot be computed straightforward. \n",
			  "Try to use IncreaseCoveringRadiusLowerBound( <code> ).\n",
			  "(see the manual for more details).\n",
			  "The covering radius of <code> lies in the interval:\n" );
			return BoundsCoveringRadius( code );
		fi;
    fi;
    return code!.boundsCoveringRadius[ 1 ];
end);

# For small codes in large spaces, this may take a very long time 
InstallMethod(CoveringRadius, "method for unrestricted code", true, 
	[IsCode], 0, 
function( code ) 
    local Code, vector, d, curmax, n, q, one, count, size, t, i, j,
			zero, large, gen; 
	if IsLinearCode( code ) then 
		return CoveringRadius( code ); 
	elif Length(code!.boundsCoveringRadius) = 1 then 
		return code!.boundsCoveringRadius[1]; 
	elif HasSpecialCoveringRadius( code ) then 
		code!.boundsCoveringRadius := SpecialCoveringRadius( code ) ( code );  
	else 
		q := Size(LeftActingDomain(code));
		n := WordLength(code);
		size := Size(code);
		one := One(LeftActingDomain(code));  
		zero := Zero(LeftActingDomain(code)); 
		Code := VectorCodeword(AsSSortedList(code)); 
		vector := List([1..n], i-> zero); 
		large := one; 
		gen := Z(q); 

		curmax := n;
		for t in Code do
			d := DistanceVecFFE(t, vector);
			if d < curmax then
				curmax := d;
			fi;
		od;
		for count in [2..q^n] do
			t := n;
			while vector[t] = large do
				vector[t] := zero;
				t := t - 1;
			od;
			if vector[t] = zero then 
				vector[t] := gen; 
			else 
				vector[t] := vector[t] * gen; 
			fi; 
			t := 1;
			repeat
				d := DistanceVecFFE(Code[t], vector);
				t := t + 1;
			until d <= curmax or t > size;
			if d > curmax then
				curmax := n;
				for t in Code do
					d := DistanceVecFFE(t, vector);
					if d < curmax then
						curmax := d;
					fi;
				od;
			fi;
		od;
		code!.boundsCoveringRadius := [curmax];
	fi; 
	return code!.boundsCoveringRadius[1]; 
end);


########################################################################
##
#F  BoundsCoveringRadius( <code> )
##
##  Find a lower and an upper bound for the covering radius of code.
##

InstallMethod(BoundsCoveringRadius, "method for unrestricted code", true, 
	[IsCode], 0, 
function(code) 
	local bcr;
	if HasCoveringRadius(code) then 
		code!.boundsCoveringRadius := [CoveringRadius(code)]; 
	elif not IsBound(code!.boundsCoveringRadius) then 
		bcr := [GeneralLowerBoundCoveringRadius(code) .. 
				GeneralUpperBoundCoveringRadius(code)]; 
		if Length(bcr) = 0 then 
			code!.boundsCoveringRadius := [0,WordLength(code)]; 
		else 
			code!.boundsCoveringRadius := bcr; 
		fi;
	fi; 
	return code!.boundsCoveringRadius; 
end); 


########################################################################
##
#F  SetBoundsCoveringRadius( <code>, <cr> )
##  SetBoundsCoveringRadius( <code>, <interval> )
##
##  Enable the user to set the covering radius (or bounds) him/herself.
##  Used to be SetCoveringRadius, before GAP4.  

InstallOtherMethod(SetBoundsCoveringRadius, 
	"method for unrestricted code, integer", 
	true, [IsCode, IsInt], 0, 
function(code, cr) 
	SetCoveringRadius(code, cr); 
	code!.boundsCoveringRadius := [cr]; 
end); 

InstallMethod(SetBoundsCoveringRadius, 
	"method for unrestricted code, interval",  
	true, [IsCode, IsVector], 0, 
function(code, cr) 
	code!.boundsCoveringRadius := IntersectionSet(
			BoundsCoveringRadius( code ), cr );
	if Length( code!.boundsCoveringRadius ) = 0 then
		code!.boundsCoveringRadius := cr;
	fi;
	IsRange( code!.boundsCoveringRadius );
	if Length(code!.boundsCoveringRadius) = 1 then 
		SetCoveringRadius(code, code!.boundsCoveringRadius[1]); 
	fi; 
end); 


########################################################################
##
#F  IncreaseCoveringRadiusLowerBound(
##      <code> [, <stopdistance> ] [, <startword> ] )
##
## small bug fix 10-2004
##
InstallMethod(IncreaseCoveringRadiusLowerBound, 
	"method for unrestricted code, stop distance, start vector", 
	true, [IsCode, IsInt, IsVector], 0, 
function ( code, stopdistance, startvector )
    
    local 
          n,                 # length of the code
          k,                 # dimension of the code
          genmat,            # generator matrix of the code
          field,             # field of the code
          q,                 # the size of field
          fieldels,          # elements of field
          fieldzero,         # zero element of field
          nonzeroels,        # non-zero elements of field
          boundscr,          # current bounds on the covering radius
          lb,                # current achieved lower bound
          current,           # the element of field^n that we are
                             # currently checking
          cwcurrent,         # current in Codeword form
          distcurrenttocode, # the distance of current to the code
          currentchanged,    # did we change current during the loop ?
          counterchanged,    # number of changes we have made so far
          countertotal,      # number of iterations we have made so far
          h, i, j,           # indexes to make the first slice
          slice,             # the number of the current slice
          numberofslices,    # the elements of the code are handled in 
                             # slices of 2^10 elements
          slicedim,          # the dimension of a slice
          slicesize,         # the size of a slice ( q^slicedim )
          index,             # to enumerate the codewords, the
                             # correct generator must be added
                             # index contains the generator number
          satisfied,         # are we satisfied with the results ?
          words,             # a list of codewords in the current slice
          wordslist0,        # a list of codewords with distance
                             # distcurrentocode + 0 from current
          wordslist1,        # a list of codewords with distance
                             # distcurrentocode + 1 from current
          word,              # a index for wordslist*
          coord,             # the coordinate where current will
                             # be changed
          staychance,        # chance that we stay at the same distance
          downchance,        # chance that we move closer to the code
          bestdist,          # best distance reached so far
          bestword,          # the corresponding word
          newelement,        # the new element for current[ coord ]
          newdist;           # the new distance of the changed current
                             # to the code

    # extract some code parameters
    n := WordLength( code );
    if IsLinearCode( code ) then
        k := Dimension( code );
    fi;
    
    field := LeftActingDomain( code );
    q := Size( field );
    
    # if we cannot compute the minimum distance of the code,
    # this algorithm will not be of much help either.
    # <lb> is a safe place to start searching
    lb := IntFloor( MinimumDistance( code ) / 2 );
    
    boundscr := BoundsCoveringRadius( code );
    if lb > boundscr[ 1 ] then
        code!.boundsCoveringRadius := Filtered( boundscr, n -> lb <= n );
        IsRange( code!.boundsCoveringRadius );
        boundscr := code!.boundsCoveringRadius;
    fi;
    
    if Length( boundscr ) = 1 then
        # if there is nothing to compute, 
        # then just return the covering radius
        return boundscr[ 1 ];     
    fi;
    
    # starting vector 
#
	current := ShallowCopy(VectorCodeword( Codeword( startvector ) ));
# (old version has above in place of below)
#	current := Codeword( startvector );
	distcurrenttocode := MinimumDistance( code, Codeword( current) );
    bestdist := distcurrenttocode;
    bestword := ShallowCopy( current );
    
    # initialise some parameters and useful variables
    fieldels := AsSSortedList( field );
    fieldzero := Zero(field);  
    nonzeroels := Difference( fieldels, [ fieldzero ] );
    
    if IsLinearCode( code ) then
        genmat := GeneratorMat( code );
        # try to make the size of a group codewords to be about
        # CRMemSize
        slicedim := LogInt( CRMemSize, q );
        numberofslices := Maximum( 1, q^( k-slicedim ) );
        slicesize := q^slicedim;
    fi;
    
    satisfied := false;
    currentchanged := true;
    counterchanged := 0;
    countertotal := 0;
    staychance := 10; # maybe make arguments of these
    downchance := 1;
    
    # the words array contains all codewords generated by
    # genmat[ 1 ] ... genmat[ slicedim ] ( or genmat[ k ], if
    # slicedim > k )
    
    if IsLinearCode( code ) then
        words := [ NullVector( n, field ) ];
        for i in [ 1 .. Minimum( slicedim, k ) ] do
            for j in [ 1 .. q^( i-1 ) ] do
                for h in [ 1 .. q-1 ] do
                    Add( words, words[ j ] + genmat[ i ] * nonzeroels[ h ] );
                od;
            od;
        od;
    else
        # if the code is non-linear, the
        # elements field is obligatory,
        # so it fits in memory.
        # no need for all the hassle as in the linear case,
        # but the disadvantage is that we can't handle
        # large non-linear codes.
        # but then again, GUAVA can't handle these anyway.
        words := VectorCodeword( AsSSortedList( code ) );
    fi;

    # start algorithm, stop when we are satisfied with the results
    # (either we have a coset leader of weigth <stopweigth>,
    # or lb = ub)
    while not satisfied do
        countertotal := countertotal + 1;
        if countertotal mod 1000 = 0 then
            InfoCoveringRadius( "Number of runs: ",
                    countertotal, 
                    "  best distance so far: ", bestdist, "\n" );
        fi;
        if currentchanged then
            # current word has changed, generate three lists of
            # codewords that have distance distcurrenttocode,
            # distcurrenttocode + 1 and distcurrenttocode + 2
            
            cwcurrent := Codeword( current );
            
            if distcurrenttocode > bestdist then
                bestdist := distcurrenttocode;
                bestword := ShallowCopy( current );
                InfoCoveringRadius( 
                        "New best distance: ", bestdist, "\n" );
            fi;
                
            wordslist0 := [];
            wordslist1 := [];

            if IsLinearCode( code ) then
                for slice in [ 0 .. numberofslices-1 ] do
                    if slice > 0 then
                        i := k - slicedim - 1;
                        while EuclideanRemainder( slice, q^i ) <> 0 do
                            i := i - 1;
                        od;
                        index := slicedim + i + 1;
                        words := List( words, x -> x + genmat[ index ] );
                    fi;
                    
                    Append( wordslist0, 
                            Filtered( words, x -> 
                                    DistanceVecFFE( x, current ) 
                                    = distcurrenttocode ) );
                    Append( wordslist1,
                            Filtered( words, x ->
                                    DistanceVecFFE( x, current ) 
                                    = distcurrenttocode + 1 ) );
                    
                od;
            else
                wordslist0 := Filtered( words, x->
                                      DistanceVecFFE( x, current )
                                      = distcurrenttocode );
                wordslist1 := Filtered( words, x->
                                      DistanceVecFFE( x, current )
                                      = distcurrenttocode + 1 );
            fi;
            
            currentchanged := false;
            counterchanged := counterchanged + 1;
            if EuclideanRemainder( counterchanged, 100 ) = 0 then
                InfoCoveringRadius( "Number of changes: ", 
                        counterchanged, "\n" );
            fi;
        fi;

        # pick a coordinate
        # the algorithm will look what happens if we change this coordinate
        coord := Random( [ 1 .. n ] );
        
        # the possible new element for this coordinate
        # is picked at random from the field elements
        newelement := Random( Difference( fieldels,
                              [ current[ coord ] ] ) );
        
        # check the new word against the codewords that are
        # at distance distcurrenttocode + 0 from current
        # the result can be: 
        #   1) the distance to all words in wordslist0 is 
        #      one more than distcurrenttocode 
        #      (this is the situation that we hope for)
        #   2) there is at least one word in wordslist0 that
        #      has distance distcurrenttocode - 1 to the
        #      new current
        #   3) if the field is not GF(2):
        #      there is a word in wordslist0 that stays
        #      at the same distance
        newdist := distcurrenttocode + 1;
        for word in wordslist0 do
            if word[ coord ] <> current[ coord ] then
                if word[ coord ] = newelement then
                    newdist := distcurrenttocode - 1;
                else
                    newdist := distcurrenttocode;
                fi;
            fi;
        od;
        
        # only check against other words if the previous tests
        # did not fail
        if newdist > distcurrenttocode then
            
            # check the new word against the codewords that are at 
            # distance distcurrenttocode + 1 from current
            # again, two results are possible
            #   1) all words in wordslist1 are at distance 
            #      distcurrenttocode + 1 or + 2 (this is good)
            #   2) there is a word in wordslist1 that now has
            #      distance distcurrenttocode to current
            #      this means we did not find an improvement
            
            for word in wordslist1 do
                if word[ coord ] = newelement then
                    newdist := distcurrenttocode;
                fi;
            od;
        fi;
        
        if newdist > distcurrenttocode then
            # we found a new coset leader with larger weight
            
            # now change current 
            current[ coord ] := newelement;
            currentchanged := true;
            distcurrenttocode := newdist;
            
            # also check whether the covering radius lower bound
            # can be increased, this is what the whole
            # algorithm is about !
            
            if distcurrenttocode > boundscr[ 1 ] then
                
                # write directly to the code to make the change
                # permanent, even if the user interrupted us
                code!.boundsCoveringRadius :=
                  Filtered( boundscr, x -> x >= distcurrenttocode );
                # make it a range together if possible
                IsRange( code!.boundsCoveringRadius );
                boundscr := code!.boundsCoveringRadius;

                # maybe we have reached the upper bound
                # then we can stop altogether !
                if Length( boundscr ) = 1 then
                    satisfied := true;
                fi;
            fi;
        elif newdist = distcurrenttocode then
            # the change to the word did not change the
            # distance to the code
            if Random( [ 1 .. 100 ] ) <= staychance then
                current[ coord ] := newelement;
                currentchanged := true;
            fi;
        else
            # make it a 1 in 100 chance to get closer anyway
            # because we do not want to get stuck in a
            # suboptimal coset
            if Random( [ 1 .. 100 ] ) <= downchance then
                current[ coord ] := newelement;
                currentchanged := true;
                distcurrenttocode := newdist;
            fi;
        fi;
        
        # maybe the distance of current to the code 
        # is high enough for the user
        # then we should stop
        if distcurrenttocode = stopdistance then
            satisfied := true;
        fi;
    od;
    
    # return the new covering radius bounds, and a coset leader
    # that has weight equal to the lower bound
    return rec( boundsCoveringRadius := code!.boundsCoveringRadius,
                cosetLeader := Codeword( current ) );
end);

InstallOtherMethod(IncreaseCoveringRadiusLowerBound, 
	"method for unrestricted code, starting vector", 
	true, [IsCode, IsVector], 0, 
function( code, startvector ) 
	# stopdistance = -1 is the default: never stop, unless the lower 
	# bound meets the upper bound 
	return IncreaseCoveringRadiusLowerBound( code, -1, startvector ); 
end); 

InstallOtherMethod(IncreaseCoveringRadiusLowerBound, 
	"method for unrestricted code, stopdistance", 
	true, [IsCode, IsInt], 0, 
function( code, stopdistance ) 
	local lb, current, distcurrenttocode;
		
    lb := IntFloor( MinimumDistance( code ) / 2 );
    current := RandomVector( WordLength( code ),
							 Random( [0..WordLength( code )] ),
							 LeftActingDomain( code ));
	distcurrenttocode := MinimumDistance( code,  Codeword(current) );
	while distcurrenttocode < lb do
		current := RandomVector( WordLength( code ),
								 Random( [0..WordLength( code )] ),
								 LeftActingDomain( code ));
		distcurrenttocode := MinimumDistance( code,  Codeword(current) );
	od;
					
	return IncreaseCoveringRadiusLowerBound( code, -1, current); 
end); 


InstallOtherMethod(IncreaseCoveringRadiusLowerBound, 
	"method for unrestricted code", true, [IsCode], 0, 
function( code ) 
	local lb, current, distcurrenttocode; 
	
	lb := IntFloor( MinimumDistance( code ) / 2 );	
	current := RandomVector( WordLength( code ), 
							 Random( [0..WordLength( code )] ), 
							 LeftActingDomain( code )); 
#	distcurrenttocode := MinimumDistance( code, current );
#  (old version had above line)
	distcurrenttocode := MinimumDistance( code, Codeword(current) );
	while distcurrenttocode < lb do
		current := RandomVector( WordLength( code ), 
								 Random( [0..WordLength( code )] ), 
								 LeftActingDomain( code ));
		distcurrenttocode := MinimumDistance( code, Codeword(current) );
	od;

	return IncreaseCoveringRadiusLowerBound( code, -1, current);  
end); 


########################################################################
##
#F  ExhaustiveSearchCoveringRadius( <code> )
##
##  Try to compute the covering radius. Don't compute all coset
##  leaders, but increment the lower bound as soon as a coset leader
##  is found.
##

InstallMethod(ExhaustiveSearchCoveringRadius, 
	"unrestricted code, boolean stopsoon", 
	true, [IsCode,IsBool], 0, 
function(C, stopsoon) 
	if IsLinearCode(C) then 
		return ExhaustiveSearchCoveringRadius(C, stopsoon); 
	else 
		Error("ExhaustiveSearchCoveringRadius: <code> must be a linear code"); 
	fi; 
end); 

InstallMethod(ExhaustiveSearchCoveringRadius, "linear code, boolean stopsoon", 
	true, [IsLinearCode, IsBool], 0, 
function(code, stopsoon) 

    local k, n, i, j, lastone, zerofound, IsCosetLeader,
          lb, we, wd, vc, cont, codewords,
          leaderfound, allexamined, supp, elmsC, elms, len, one, zero,
          boundscr;
    
    IsCosetLeader := function( codewords, len, word, wt, one )
        local i, check, cw, wcw, j;
        check := true;
        i := 1;
        while i <= len and check do
            cw := codewords[ i ] + word;
            wcw := 0;
            for j in [ 1 .. Length( cw ) ] do
                if cw[ j ] = one then
                    wcw := wcw + 1;
                fi;
            od;
            if wcw < wt then
                check := false;
            fi;
            i := i + 1;
        od;
        return check;
    end;

    if Size( LeftActingDomain( code ) ) <> 2 then
        Error( "CoveringRadiusSearch: <code> must be a binary code" );
    fi;

    boundscr := BoundsCoveringRadius( code );
    if Length( boundscr ) = 1 then
        return boundscr[ 1 ];
    fi;
    
    lb := boundscr[ 1 ];
    n := WordLength( code );
    wd := WeightDistribution( code );
    elms := [];
    for i in [ 0 .. n ] do
        if wd[ i + 1 ] > 0 then
            elms[ i + 1 ] := ShallowCopy(AsSSortedList( 
                                     ConstantWeightSubcode( code, i ) ));
        fi;
    od;
    
    for i in [ 1 .. n+1 ] do
        if IsBound( elms[ i ] ) then
            for j in [ 1 .. Length( elms[ i ] ) ] do
                elms[ i ][ j ] := VectorCodeword( elms[ i ][ j ] );
#mutable error on:
# C:=RandomLinearCode(10,5,GF(2));
# ExhaustiveSearchCoveringRadius(C,true);
            od;
        fi;
    od;

    # try to find a coset leader with weight > lb
    # if found, increase lb
    one := One(GF(2));
    zero := Zero(GF(2));
    cont := true;
    while cont do
        k := BoundsCoveringRadius(code)[ 1 ] + 1;
        InfoCoveringRadius( "Trying ", k, " ...\n" );
        codewords := [ NullVector(n, GF(2) ) ];
        for i in [ 1 .. Minimum( n, 2 * k - 1) ] do
            if wd[ i + 1 ] <> 0 then
                Append( codewords, elms[ i + 1 ] );
            fi;
        od;
        len := Length( codewords );

        vc := NullVector( n, GF(2) );
        for i in [ 1 .. k ] do
            vc[ i ] := one;
        od;
        lastone := k;
        allexamined := false;
        leaderfound := false;

        while not leaderfound and not allexamined do
            if not IsCosetLeader( codewords, len, vc, k, one ) then
                if lastone = n then
                    zerofound := false;
                    i := lastone - 1;
                    while i > n - k and vc[ i ] = one do
                        i := i - 1;
                    od;
                    if i = n - k then 
                        allexamined := true;
                    else
                        j := i;
                        i := i + 1;
                        while vc[ j ] = zero do
                            j := j - 1;
                        od;
                        vc[ j ] := zero;
                        vc[ j + 1 ] := one;
                        j := j + 2;
                        if i <> j then
                            while i <= lastone do
                                vc[ j ] := one;
                                vc[ i ] := zero;
                                i := i + 1;
                                j := j + 1;
                            od;
                            lastone := j - 1;
                        else
                            lastone := n;
                        fi;
                    fi;
                else
                    vc[ lastone ] := zero;
                    lastone := lastone + 1;
                    vc[ lastone ] := one;
                fi;
            else
                leaderfound := true;
            fi;
        od;

        if leaderfound then
            code!.boundsCoveringRadius :=   
              Filtered( code!.boundsCoveringRadius, x -> x >= k );
            if stopsoon then
                cont := false;
            fi;
        else
            code!.boundsCoveringRadius :=
              [ code!.boundsCoveringRadius[ 1 ] ];
            cont := false;
        fi;
    od;
    
    IsRange( code!.boundsCoveringRadius );
    return( code!.boundsCoveringRadius );
end);

InstallOtherMethod(ExhaustiveSearchCoveringRadius, "unrestricted code", true, 
	[IsCode], 0, 
function(C) 
	return ExhaustiveSearchCoveringRadius(C, true); 
end); 


########################################################################
##
#F  CoveringRadiusLowerBoundTable
##

CoveringRadiusLowerBoundTable := [
    [ 3, 2, , , , , , , , ,                     # n = 13
       ,  , , , , , , , , ,
       ,  , , , , , , , , ,
       ,  , , , , , , , , ,
       ,  , , , , , , , ],
    [ 3, 3, , , , , , , , ,                     # n = 14
       ,  , , , , , , , , ,
       ,  , , , , , , , , ,
       ,  , , , , , , , , ,
       ,  , , , , , , , ],
    [ 4, 3, 3, , , , , , , ,                    # n = 15
       ,  ,  , , , , , , , ,
       ,  ,  , , , , , , , ,
       ,  ,  , , , , , , , ,
       ,  ,  , , , , , , ],
    [ 4, 4, 3, 3, , , , , , ,                   # n = 16
       ,  ,  ,  , , , , , , ,
       ,  ,  ,  , , , , , , ,
       ,  ,  ,  , , , , , , ,
       ,  ,  ,  , , , , , ],
    [ 4, 4, 3, 3, 3, , , , , ,                  # n = 17
       ,  ,  ,  ,  , , , , , ,
       ,  ,  ,  ,  , , , , , ,
       ,  ,  ,  ,  , , , , , ,
       ,  ,  ,  ,  , , , , ],
    [ 5, 4, 4, 3, 3, 3, , , , ,                 # n = 18
       ,  ,  ,  ,  ,  , , , , ,
       ,  ,  ,  ,  ,  , , , , ,
       ,  ,  ,  ,  ,  , , , , ,
       ,  ,  ,  ,  ,  , , , ],
    [ 5, 4, 4, 4, 3, 3, 2, , , ,                # n = 19
       ,  ,  ,  ,  ,  ,  , , , ,
       ,  ,  ,  ,  ,  ,  , , , ,
       ,  ,  ,  ,  ,  ,  , , , ,
       ,  ,  ,  ,  ,  ,  , , ],
    [ 6, 5, 4, 4, 4, 3, 3, 2, , ,               # n = 20
       ,  ,  ,  ,  ,  ,  ,  , , ,
       ,  ,  ,  ,  ,  ,  ,  , , ,
       ,  ,  ,  ,  ,  ,  ,  , , ,
       ,  ,  ,  ,  ,  ,  ,  , ],
    [ 6, 5, 5, 4, 4, 3, 3, 3, , ,               # n = 21
       ,  ,  ,  ,  ,  ,  ,  , , ,
       ,  ,  ,  ,  ,  ,  ,  , , ,
       ,  ,  ,  ,  ,  ,  ,  , , ,
       ,  ,  ,  ,  ,  ,  ,  , ],
    [ 6, 6, 5, 5, 4, 4, 3, 3, 3, ,              # n = 22
       ,  ,  ,  ,  ,  ,  ,  ,  , ,
       ,  ,  ,  ,  ,  ,  ,  ,  , ,
       ,  ,  ,  ,  ,  ,  ,  ,  , ,
       ,  ,  ,  ,  ,  ,  ,  ,  ],
    [ 7, 6, 5, 5, 4, 4, 3, 3, 3, 3,             # n = 23
       ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
       ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
       ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
       ,  ,  ,  ,  ,  ,  ,  ,  ],
    [ 7, 6, 6, 5, 5, 4, 4, 3, 3, 3,             # n = 24
      3,  ,  ,  ,  ,  ,  ,  ,  ,  ,
       ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
       ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
       ,  ,  ,  ,  ,  ,  ,  ,  ],
    [ 7, 7, 6, 6, 5, 5, 4, 4, 3, 3,             # n = 25
      3, 2,  ,  ,  ,  ,  ,  ,  ,  ,
       ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
       ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
       ,  ,  ,  ,  ,  ,  ,  ,  ],
    [ 8, 7, 7, 6, 6, 5, 5, 4, 4, 3,             # n = 26
      3, 3, 2,  ,  ,  ,  ,  ,  ,  ,
       ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
       ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
       ,  ,  ,  ,  ,  ,  ,  ,  ],
    [ 8, 8, 7, 6, 6, 5, 5, 4, 4, 4,             # n = 27
      3, 3, 3, 2,  ,  ,  ,  ,  ,  ,
       ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
       ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
       ,  ,  ,  ,  ,  ,  ,  ,  ],
    [ 9, 8, 7, 7, 6, 6, 5, 5, 4, 4,             # n = 28
      4, 3, 3, 3, 2,  ,  ,  ,  ,  ,
       ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
       ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
       ,  ,  ,  ,  ,  ,  ,  ,  ],
    [ 9, 8, 8, 7, 7, 6, 6, 5, 5, 4,             # n = 29
      4, 4, 3, 3, 3, 2,  ,  ,  ,  ,
       ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
       ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
       ,  ,  ,  ,  ,  ,  ,  ,  ],
    [ 9, 9, 8, 7, 7, 6, 6, 5, 5, 5,             # n = 30
      4, 4, 4, 3, 3, 3,  ,  ,  ,  ,
       ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
       ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
       ,  ,  ,  ,  ,  ,  ,  ,  ],
    [ 10, 9, 8, 8, 7, 7, 6, 6, 5, 5,            # n = 31
       5, 4, 4, 3, 3, 3, 3,  ,  ,  ,
        ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
        ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
        ,  ,  ,  ,  ,  ,  ,  ,  ],
    [ 10, 9, 9, 8, 8, 7, 7, 6, 6, 5,            # n = 32
       5, 4, 4, 4, 3, 3, 3, 3,  ,  ,
        ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
        ,  ,  ,  ,  ,  ,  ,  ,  ,  ,
        ,  ,  ,  ,  ,  ,  ,  ,  ],
    [ 11, 10, 9, 9, 8, 7, 7, 6, 6, 6,           # n = 33
       5,  5, 4, 4, 4, 3, 3, 3, 3,  ,
        ,   ,  ,  ,  ,  ,  ,  ,  ,  ,
        ,   ,  ,  ,  ,  ,  ,  ,  ,  ,
        ,   ,  ,  ,  ,  ,  ,  ,  ],
    [ 11, 10, 10, 9, 8, 8, 7, 7, 6, 6,          # n = 34
       5,  5,  5, 4, 4, 4, 3, 3, 3, 2,
        ,   ,   ,  ,  ,  ,  ,  ,  ,  ,
        ,   ,   ,  ,  ,  ,  ,  ,  ,  ,
        ,   ,   ,  ,  ,  ,  ,  ,  ],
    [ 11, 11, 10, 9, 9, 8, 8, 7, 7, 6,          # n = 35
       6,  5,  5, 5, 4, 4, 4, 3, 3, 3,
       2,   ,   ,  ,  ,  ,  ,  ,  ,  ,
        ,   ,   ,  ,  ,  ,  ,  ,  ,  ,
        ,   ,   ,  ,  ,  ,  ,  ,  ],
    [ 12, 11, 10, 10, 9, 9, 8, 8, 7, 7,         # n = 36
       6,  6,  5,  5, 5, 4, 4, 4, 3, 3,
       3,  2,   ,   ,  ,  ,  ,  ,  ,  ,
        ,   ,   ,   ,  ,  ,  ,  ,  ,  ,
        ,   ,   ,   ,  ,  ,  ,  ,  ],
    [ 12, 11, 11, 10, 9, 9, 8, 8, 7, 7,         # n = 37
       6,  6,  6,  5, 5, 4, 4, 4, 4, 3,
       3,  3,  2,   ,  ,  ,  ,  ,  ,  ,
        ,   ,   ,   ,  ,  ,  ,  ,  ,  ,
        ,   ,   ,   ,  ,  ,  ,  ,  ],
    [ 13, 12, 11, 10, 10, 9, 9, 8, 8, 7,        # n = 38
       7,  6,  6,  6,  5, 5, 4, 4, 4, 3,
       3,  3,  3,  2,   ,  ,  ,  ,  ,  ,
        ,   ,   ,   ,   ,  ,  ,  ,  ,  ,
        ,   ,   ,   ,   ,  ,  ,  ,  ],
    [ 13, 12, 12, 11, 10, 10, 9, 9, 8, 8,       # n = 39
       7,  7,  6,  6,  5,  5, 5, 4, 4, 4,
       3,  3,  3,  3,  2,   ,  ,  ,  ,  ,
        ,   ,   ,   ,   ,   ,  ,  ,  ,  ,
        ,   ,   ,   ,   ,   ,  ,  ,  ],
    [ 14, 13, 12, 11, 11, 10, 9, 9, 8, 8,       # n = 40
       7,  7,  7,  6,  6,  5, 5, 5, 4, 4,
       4,  3,  3,  3,  3,  2,  ,  ,  ,  ,
        ,   ,   ,   ,   ,   ,  ,  ,  ,  ,
        ,   ,   ,   ,   ,   ,  ,  ,  ],
    [ 14, 13, 12, 12, 11, 10, 10, 9, 9, 8,      # n = 41
       8,  7,  7,  6,  6,  6,  5, 5, 5, 4,
       4,  4,  3,  3,  3,  3,  2,  ,  ,  ,
        ,   ,   ,   ,   ,   ,   ,  ,  ,  ,
        ,   ,   ,   ,   ,   ,   ,  ,  ],
    [ 14, 14, 13, 12, 11, 11, 10, 10, 9, 9,     # n = 42
       8,  8,  7,  7,  6,  6,  6,  5, 5, 5,
       4,  4,  4,  3,  3,  3,  3,  2,  ,  ,
        ,   ,   ,   ,   ,   ,   ,   ,  ,  ,
        ,   ,   ,   ,   ,   ,   ,   ,  ],
    [ 15, 14, 13, 12, 12, 11, 10, 10, 9, 9,     # n = 43
       8,  8,  7,  7,  7,  6,  6,  6, 5, 5,
       5,  4,  4,  4,  3,  3,  3,  3, 2,  ,
        ,   ,   ,   ,   ,   ,   ,   ,  ,  ,
        ,   ,   ,   ,   ,   ,   ,   ,  ],
    [ 15, 14, 14, 13, 12, 11, 11, 10, 10, 9,    # n = 44
       9,  8,  8,  7,  7,  7,  6,  6,  5, 5,
       5,  4,  4,  4,  4,  3,  3,  3,  3,  ,
        ,   ,   ,   ,   ,   ,   ,   ,   ,  ,
        ,   ,   ,   ,   ,   ,   ,   ,   ],
    [ 16, 15, 14, 13, 12, 12, 11, 11, 10, 10,   # n = 45
       9,  9,  8,  8,  7,  7,  7,  6,  6,  5,
       5,  5,  4,  4,  4,  4,  3,  3,  3,  3,
        ,   ,   ,   ,   ,   ,   ,   ,   ,   ,
        ,   ,   ,   ,   ,   ,   ,   ,   ],
    [ 16, 15, 14, 14, 13, 12, 12, 11, 11, 10,   # n = 46
       9,  9,  8,  8,  8,  7,  7,  6,  6,  6,
       5,  5,  5,  4,  4,  4,  4,  3,  3,  3,
       3,   ,   ,   ,   ,   ,   ,   ,   ,   ,
        ,   ,   ,   ,   ,   ,   ,   ,   ],
    [ 16, 16, 15, 14, 13, 13, 12, 11, 11, 10,   # n = 47
      10,  9,  9,  8,  8,  8,  7,  7,  6,  6,
       6,  5,  5,  5,  4,  4,  4,  3,  3,  3,
       3,  2,   ,   ,   ,   ,   ,   ,   ,   ,
        ,   ,   ,   ,   ,   ,   ,   ,   ],
    [ 17, 16, 15, 14, 14, 13, 12, 12, 11, 11,   # n = 48
      10, 10,  9,  9,  8,  8,  7,  7,  7,  6,
       6,  6,  5,  5,  5,  4,  4,  4,  3,  3,
       3,  3,  2,   ,   ,   ,   ,   ,   ,   ,
        ,   ,   ,   ,   ,   ,   ,   ,   ],
    [ 17, 16, 16, 15, 14, 13, 13, 12, 12, 11,   # n = 49
      11, 10,  9,  9,  9,  8,  8,  7,  7,  7,
       6,  6,  6,  5,  5,  5,  4,  4,  4,  3,
       3,  3,  3,  2,   ,   ,   ,   ,   ,   ,
        ,   ,   ,   ,   ,   ,   ,   ,   ],
    [ 18, 17, 16, 15, 14, 14, 13, 13, 12, 11,   # n = 50
      11, 10, 10,  9,  9,  8,  8,  8,  7,  7,
       7,  6,  6,  6,  5,  5,  5,  4,  4,  4,
       3,  3,  3,  3,  2,   ,   ,   ,   ,   ,
        ,   ,   ,   ,   ,   ,   ,   ,   ],
    [ 18, 17, 16, 16, 15, 14, 13, 13, 12, 12,   # n = 51
      11, 11, 10, 10,  9,  9,  8,  8,  8,  7,
       7,  6,  6,  6,  5,  5,  5,  5,  4,  4,
       4,  3,  3,  3,  3,  2,   ,   ,   ,   ,
        ,   ,   ,   ,   ,   ,   ,   ,   ],
    [ 19, 18, 17, 16, 15, 15, 14, 13, 13, 12,   # n = 52
      12, 11, 11, 10, 10,  9,  9,  8,  8,  8,
       7,  7,  6,  6,  6,  5,  5,  5,  5,  4,
       4,  4,  3,  3,  3,  3,  2,   ,   ,   ,
        ,   ,   ,   ,   ,   ,   ,   ,   ],
    [ 19, 18, 17, 16, 16, 15, 14, 14, 13, 12,   # n = 53
      12, 11, 11, 10, 10,  9,  9,  9,  8,  8,
       7,  7,  7,  6,  6,  6,  5,  5,  5,  4,
       4,  4,  4,  3,  3,  3,  3,  2,   ,   ,
        ,   ,   ,   ,   ,   ,   ,   ,   ],
    [ 19, 18, 18, 17, 16, 15, 15, 14, 13, 13,   # n = 54
      12, 12, 11, 11, 10, 10,  9,  9,  9,  8,
       8,  7,  7,  7,  6,  6,  6,  5,  5,  5,
       4,  4,  4,  4,  3,  3,  3,  3,  2,   ,
        ,   ,   ,   ,   ,   ,   ,   ,   ],
    [ 20, 19, 18, 17, 16, 16, 15, 14, 14, 13,   # n = 55
      13, 12, 12, 11, 11, 10, 10,  9,  9,  8,
       8,  8,  7,  7,  7,  6,  6,  6,  5,  5,
       5,  4,  4,  4,  4,  3,  3,  3,  3,  2,
        ,   ,   ,   ,   ,   ,   ,   ,   ],
    [ 20, 19, 18, 18, 17, 16, 15, 15, 14, 14,   # n = 56
      13, 12, 12, 11, 11, 10, 10, 10,  9,  9,
       8,  8,  8,  7,  7,  7,  6,  6,  6,  5,
       5,  5,  4,  4,  4,  4,  3,  3,  3,  3,
       2,   ,   ,   ,   ,   ,   ,   ,   ],
    [ 21, 20, 19, 18, 17, 16, 16, 15, 14, 14,   # n = 57
      13, 13, 12, 12, 11, 11, 10, 10,  9,  9,
       9,  8,  8,  7,  7,  7,  6,  6,  6,  5,
       5,  5,  5,  4,  4,  4,  4,  3,  3,  3,
       3,  2,   ,   ,   ,   ,   ,   ,   ],
    [ 21, 20, 19, 18, 18, 17, 16, 15, 15, 14,   # n = 58
      14, 13, 13, 12, 12, 11, 11, 10, 10,  9,
       9,  9,  8,  8,  7,  7,  7,  6,  6,  6,
       5,  5,  5,  5,  4,  4,  4,  4,  3,  3,
       3,  3,  2,   ,   ,   ,   ,   ,   ],
    [ 22, 21, 20, 19, 18, 17, 17, 16, 15, 15,   # n = 59
      14, 14, 13, 12, 12, 11, 11, 11, 10, 10,
       9,  9,  8,  8,  8,  7,  7,  7,  6,  6,
       6,  5,  5,  5,  5,  4,  4,  4,  4,  3,
       3,  3,  3,  2,   ,   ,   ,   ,   ],
    [ 22, 21, 20, 19, 18, 18, 17, 16, 16, 15,   # n = 60
      14, 14, 13, 13, 12, 12, 11, 11, 10, 10,
      10,  9,  9,  8,  8,  8,  7,  7,  7,  6,
       6,  6,  5,  5,  5,  5,  4,  4,  4,  3,
       3,  3,  3,  3,  2,   ,   ,   ,   ],
    [ 23, 21, 20, 20, 19, 18, 17, 17, 16, 15,   # n = 61
      15, 14, 14, 13, 13, 12, 12, 11, 11, 10,
      10, 10,  9,  9,  8,  8,  8,  7,  7,  7,
       6,  6,  6,  5,  5,  5,  5,  4,  4,  4,
       3,  3,  3,  3,  3,  2,   ,   ,   ],
    [ 23, 22, 21, 20, 19, 18, 18, 17, 16, 16,   # n = 62
      15, 15, 14, 14, 13, 12, 12, 12, 11, 11,
      10, 10,  9,  9,  9,  8,  8,  8,  7,  7,
       7,  6,  6,  6,  5,  5,  5,  4,  4,  4,
       4,  3,  3,  3,  3,  3,  2,   ,   ],
    [ 23, 22, 21, 20, 20, 19, 18, 17, 17, 16,   # n = 63
      16, 15, 14, 14, 13, 13, 12, 12, 11, 11,
      11, 10, 10,  9,  9,  9,  8,  8,  7,  7,
       7,  6,  6,  6,  6,  5,  5,  5,  4,  4,
       4,  4,  3,  3,  3,  3,  3,  2,   ],
    [ 24, 23, 22, 21, 20, 19, 18, 18, 17, 16,   # n = 64
      16, 15, 15, 14, 14, 13, 13, 12, 12, 11,
      11, 10, 10, 10,  9,  9,  8,  8,  8,  7,
       7,  7,  6,  6,  6,  6,  5,  5,  5,  4,
       4,  4,  4,  3,  3,  3,  3,  3,  2 ]
];

########################################################################
##
#F  GeneralLowerBoundCoveringRadius( <n>, <size> [, <F> ] )
##  GeneralLowerBoundCoveringRadius( <code> )
##

InstallMethod(GeneralLowerBoundCoveringRadius, "unrestricted code", true, 
	[IsCode], 0, 
function(code)  
	local n, size, field, listofbounds, max;
	if IsLinearCode(code) then 
		return GeneralLowerBoundCoveringRadius(code);  
	fi; 
	n := WordLength( code );
	size := Size( code );
	field := LeftActingDomain( code );
	listofbounds := [
	  LowerBoundCoveringRadiusSphereCovering( n, size, field, false ),
	];
	if field = GF(2) then
		Append( listofbounds, [
		  LowerBoundCoveringRadiusVanWee1( n, size, field, false ),
		  LowerBoundCoveringRadiusVanWee2( n, size, false ),
		  LowerBoundCoveringRadiusCountingExcess( n, size, false )
		] );
		if n <= 200 then
			Append( listofbounds, [
			  LowerBoundCoveringRadiusEmbedded1( n, size, field, false ),
				  LowerBoundCoveringRadiusEmbedded2( n, size, field, false )
				] );
		fi;
	fi; 
	max := Maximum( listofbounds ); 

	if IsBound(code!.boundsCoveringRadius) then 
		return Maximum ([ max, code!.boundsCoveringRadius[1] ]); 
	else 
		return max;
	fi; 
end); 


InstallMethod(GeneralLowerBoundCoveringRadius, "linear code", true, 
	[IsLinearCode], 0, 
function (code) 
	local n, size, field, k, listofbounds, return_value; 
	n := WordLength(code); 
	size := Size(code); 
	field := LeftActingDomain(code); 
	listofbounds := [  
	  LowerBoundCoveringRadiusSphereCovering( n, size, field, false ), 
	]; 
	return_value := -99;  # Allows to check whether next set of if 
						  # statements actually assign a value 
	if field = GF(2) then
		k := Dimension( code );
		# small codimensions (n-k)
		if k = n then
			return_value :=  0;
		elif k = n - 1 then
			return_value :=  1;
		elif k = n - 2 then
			return_value :=  1;
		elif k = n - 3 and n >= 7 then
			return_value :=  1;
		elif k = n - 4 and n >= 5 then
			if n >= 15 then
				return_value :=  1;
			else
				return_value :=  2;
			fi;
		elif k = n - 5 and n >= 9 then
			if n >= 31 then
				return_value :=  1;
			else
				return_value :=  2;
			fi;
		elif k = n - 6 then
			if n >= 63 then
				return_value :=  1;
			elif n >= 14 then
				return_value :=  2;
			elif n = 12 then
				return_value :=  3;
			fi;
		elif k = n - 7 and n >= 21 and n <= 64 then
			return_value :=  2;
		elif k = n - 8 and n >= 30 and n <= 64 then
			return_value :=  2;
		elif k = n - 9 and n >= 44 and n <= 64 then
			return_value :=  2;
		elif k = 1 then
			return_value :=  IntFloor( n/2 );
		elif k = 2 then
			return_value :=  IntFloor( (n-1)/2 );
		elif k = 3 then
			return_value :=  IntFloor( (n-2)/2 );
		elif k = 4 then
			return_value :=  IntFloor( (n-4)/2 );
		elif k = 5 then
			return_value :=  IntFloor( (n-5)/2 );
		fi;


		# use the table of Cohen, Litsyn, Lobstein and Mattson
		if return_value < 0 and n >= 13 and n <= 64 and k>=6 and k<= 64 then
			if IsBound( 
				 CoveringRadiusLowerBoundTable[ n - 12 ][ k - 5 ] ) then
				return_value :=  
							CoveringRadiusLowerBoundTable[ n - 12 ][ k - 5 ]; 
			fi;
		fi;
	
		if return_value < 0 then 
			# not in the table. use the bounds
			listofbounds := [
			  LowerBoundCoveringRadiusSphereCovering( n, size, field, false ),
			  LowerBoundCoveringRadiusVanWee1( n, size, field, false ),
			  LowerBoundCoveringRadiusVanWee2( n, size, false ),
			  LowerBoundCoveringRadiusCountingExcess( n, size, false )
			];
			if n <= 200 then
				Append( listofbounds, [
				  LowerBoundCoveringRadiusEmbedded1( n, size, field, false ),
				  LowerBoundCoveringRadiusEmbedded2( n, size, field, false ),
				] );        
			fi;
			return_value := Maximum( listofbounds );
		fi; 
	else  # field is not GF(2)
		listofbounds := [
		  LowerBoundCoveringRadiusSphereCovering( n, size, field, false ),
		];
		return_value := Maximum( listofbounds );
	fi;

	if IsBound(code!.boundsCoveringRadius) then 
		return Maximum([return_value, code!.boundsCoveringRadius[1]]); 
	else 
		return return_value; 
	fi; 

end);

InstallOtherMethod(GeneralLowerBoundCoveringRadius, "n, k, field", true, 
	[IsInt, IsInt, IsField], 0, 
function(n, size, field) 
	local listofbounds;  
	if n < 1 or size < 1 then 
		Error("GeneralLBCR: <n> and <size> must be positive"); 
	fi; 
	listofbounds := [
	  LowerBoundCoveringRadiusSphereCovering( n, size, field, false ),
	  LowerBoundCoveringRadiusVanWee1( n, size, field, false ),
	  LowerBoundCoveringRadiusEmbedded1( n, size, field, false ),
	  LowerBoundCoveringRadiusEmbedded2( n, size, field, false )
	];
	if field = GF(2) then
		Append( listofbounds, [
		  LowerBoundCoveringRadiusVanWee2( n, size, false ),
		  LowerBoundCoveringRadiusCountingExcess( n, size, false )
		] );
	fi;
	return Maximum( listofbounds );
end);
   
InstallOtherMethod(GeneralLowerBoundCoveringRadius, "n, size", true, 
	[IsInt, IsInt], 0, 
function(n, size) 
	return GeneralLowerBoundCoveringRadius(n, size, GF(2)); 
end); 


########################################################################
##
#F  LowerBoundCoveringRadiusSphereCovering( <n>, <r> [, <F> ] [, true ] )
##

InstallMethod(LowerBoundCoveringRadiusSphereCovering, 
	"n, r, fieldsize, usage", 
	true, [IsInt, IsInt, IsInt, IsBool], 0, 
function(n, r, q, usage) 
	local m, lb, ub, tmpcr, tmpsize, t;  
	if n <= 0 then 
		Error("LBCRSphereCovering: <n> must be positive"); 
	fi; 
    
	if usage = false then
        # last argument is false, try to find a lower bound for
        # the covering radius, given length and size of the code, and field 
        
        m := r;
        if m <= 0 or m > q^n then
            Error( "LBCRSphereCovering: <m> must be > 0 and <= q^n" );
        fi;
        
        # everything is set up. now compute the bound
        
        lb := 0;
        ub := n;
        while lb <> ub do
            tmpcr := IntFloor( ( lb + ub ) / 2 );
            tmpsize := IntCeiling( q^n / SphereContent( n, tmpcr, q ) );
            if tmpsize > m then
                lb := tmpcr + 1;
            else
                ub := tmpcr;
            fi;
        od;
        return ub;
    else
        # the last argument is not false
        # now it is assumed that the first argument is the length
        # of the code and the second argument is the covering radius
        # of the code. a lower bound for the minimal size of the
        # code is returned
        
        t := r;
        if t < 0 or t > n then
            Error( "LBCRSphereCovering: <t> must be >= 0 and <= <n>" );
        fi;
            
        return IntCeiling( q^n / SphereContent( n, t, q ) );
    fi;
end);
        
InstallOtherMethod(LowerBoundCoveringRadiusSphereCovering, 
	"n, r, field, usage", true, 
	[IsInt, IsInt, IsField, IsBool], 0, 
function(n, r, F, usage) 
	if not IsFinite(F) then 
		Error("LBCRSphereCovering: <F> must be a finite field"); 
	else 
		return LowerBoundCoveringRadiusSphereCovering(n, r, Size(F), usage); 
	fi; 
end); 

InstallOtherMethod(LowerBoundCoveringRadiusSphereCovering, 
	"n, r, fieldsize", true, [IsInt, IsInt, IsInt], 0, 
function(n, r, q) 
	return LowerBoundCoveringRadiusSphereCovering(n, r, q, true); 
end); 

InstallOtherMethod(LowerBoundCoveringRadiusSphereCovering, 
	"n, r, field", true, [IsInt, IsInt, IsField], 0, 
function(n, r, F) 
	if not IsFinite(F) then 
		Error("LBCRSphereCovering: <F> must be a finite field"); 
	else 
		return LowerBoundCoveringRadiusSphereCovering(n, r, Size(F), true); 
	fi; 
end); 

InstallOtherMethod(LowerBoundCoveringRadiusSphereCovering, 
	"n, r, usage", true, [IsInt, IsInt, IsBool], 0, 
function(n, r, usage) 
	return LowerBoundCoveringRadiusSphereCovering(n, r, 2, usage);  
end); 

InstallOtherMethod(LowerBoundCoveringRadiusSphereCovering, "n, r", true, 
	[IsInt, IsInt], 0, 
function(n, r)  
	return LowerBoundCoveringRadiusSphereCovering(n, r, 2, true); 
end); 


########################################################################
##
#F  LowerBoundCoveringRadiusVanWee1( ... )
##

InstallMethod(LowerBoundCoveringRadiusVanWee1, 
	"n, r, fieldsize, usage", true, [IsInt, IsInt, IsInt, IsBool], 0, 
function(n, r, q, usage) 
    local m, lb, ub, tmpcr, tmpsize, t, tmp;
   	if n <= 0 then 
		Error("LBCRVanWee1: <n> must be positive"); 
	fi; 
    if usage = false then
        # last argument is false, try to find a lower bound for
        # the covering radius, given length and size of the code, and field 

        m := r;
        if m <= 0 or m > q^n then
            Error( "LBCRVanWee1: <m> must be > 0 and <= q^n" );
        fi;
        
        # everything is set up. now compute the bound
        
        lb := 0;
        ub := n;
        while lb <> ub do
            tmpcr := IntFloor( (ub+lb) / 2 );
            tmpsize := LowerBoundCoveringRadiusVanWee1( n, tmpcr, q );
            if tmpsize > m then
                lb := tmpcr + 1;
            else
                ub := tmpcr;
            fi;
        od;
        return ub;
    else
        # the last argument is not false
        # now it is assumed that the first argument is the length
        # of the code and the second argument is the covering radius
        # of the code. a lower bound for the minimal size of the
        # code is returned
   
        t := r;
        if t < 0 or t > n then
            Error( "LBCRVanWee1: <t> must be >= 0 and <= <n>" );
        fi;
        if t = n then
            return 1;
        fi;
        
        tmp := (Binomial(n,t))/(IntCeiling((n-t)/(t+1)));
        tmp := tmp * (IntCeiling((t+1)/(t+1)) - (t+1)/(t+1));
        tmp := SphereContent( n, t, q ) - tmp;
        return IntCeiling( q^n / tmp );
    fi;
end);

InstallOtherMethod(LowerBoundCoveringRadiusVanWee1, 
	"n, r, field, usage", true, [IsInt, IsInt, IsField, IsBool], 0, 
function(n, r, F, usage) 
	if not IsFinite(F) then 
		Error("LBCRVanWee1: <F> must be a finite field"); 
	else 
		return LowerBoundCoveringRadiusVanWee1(n, r, Size(F), usage); 
	fi; 
end); 

InstallOtherMethod(LowerBoundCoveringRadiusVanWee1, "n,r,fieldsize", 
	true, [IsInt, IsInt, IsInt], 0, 
function(n, r, q) 
	return LowerBoundCoveringRadiusVanWee1(n, r, q, true); 
end); 

InstallOtherMethod(LowerBoundCoveringRadiusVanWee1, "n, r, field", 
	true, [IsInt, IsInt, IsField], 0, 
function(n, r, F) 
	if not IsFinite(F) then 
		Error("LBCRVanWee1: <F> must be a finite field"); 
	else 
		return LowerBoundCoveringRadiusVanWee1(n, r, Size(F), true); 
	fi; 
end); 

InstallOtherMethod(LowerBoundCoveringRadiusVanWee1, 
	"n, r, usage", true, [IsInt, IsInt, IsBool], 0, 
function(n, r, usage) 
	return LowerBoundCoveringRadiusVanWee1(n, r, 2, usage); 
end); 

InstallOtherMethod(LowerBoundCoveringRadiusVanWee1, 
	"n, r", true, [IsInt, IsInt], 0, 
function(n, r) 
	return LowerBoundCoveringRadiusVanWee1(n, r, 2, true); 
end); 


#############################################################################
##
#F  LowerBoundCoveringRadiusVanWee2( <n>, <r> ) Counting Excess bound
##

InstallMethod(LowerBoundCoveringRadiusVanWee2, 
	"code length, code size or covering radius, usage", 
	true, [IsInt, IsInt, IsBool], 0, 
function(n, r, usage) 
    local m, lb, ub, tmpcr, eps, tmpsize, t, tmpb1, tmpb2;
    
    if n<=0 then
        Error( "LBCRVanWee2: <n> must be positive" );
    fi;
    
    if usage = false then
        m := r;
        if m <= 0 or m > 2^n then
            Error( "LBCRVanWee2: <m> must be > 0 and <= 2^n" );
        fi;
        lb := 0;
        ub := IntFloor( n/2 );
        while lb <> ub do
            tmpcr := IntFloor( ( ub + lb ) / 2 );
            tmpb1 := (tmpcr+2)*(tmpcr+1)/2; # Binomial(tmpcr+2,2)
            tmpb2 := (n-tmpcr+1)*(n-tmpcr)/2; # Binomial(n-tmpcr+1,2)
            eps := tmpb1 * IntCeiling( tmpb2/tmpb1 ) - tmpb2;
            tmpsize := 2^n * ( SphereContent( n, 2, 2 ) + eps
                               - 1/2*( tmpcr + 2 )*( tmpcr - 1 ) );
            tmpsize := tmpsize / ( SphereContent( n, tmpcr, 2 ) * 
                               ( SphereContent( n, 2, 2 ) 
                                 - 1/2*( tmpcr + 2 )*( tmpcr - 1 ) )
                               + eps * SphereContent( n, tmpcr - 2 ) );
            if tmpsize > m then
                lb := tmpcr + 1;
            else
                ub := tmpcr;
            fi;
        od;
        return ub;
    else
        t := r;
        if t < 0 or t > n then
            Error( "LBCRVanWee2: <t> must be >= 0 and <= <n>" );
        fi;
        if 2 * t > n then
            return 0;
        fi;
        tmpb1 := (t+2)*(t+1)/2;
        tmpb2 := (n-t+1)*(n-t)/2;
        eps := tmpb1 * IntCeiling( tmpb2/tmpb1 ) - tmpb2;
        tmpsize := 2^n * ( SphereContent( n, 2, 2 ) + eps
                           - 1/2*( t + 2 )*( t - 1 ) );
        tmpsize := tmpsize / ( SphereContent( n, t, 2 ) 
                           * ( SphereContent( n, 2, 2 ) 
                               - 1/2*( t + 2 )*( t - 1 ) ) 
                           + eps * SphereContent( n, t-2, 2 ) );
        return IntCeiling(tmpsize);
    fi;
end);

InstallOtherMethod(LowerBoundCoveringRadiusVanWee2, 
	"code length, code covering radius", 
	true, [IsInt, IsInt], 0, 
function(n, r) 
	return LowerBoundCoveringRadiusVanWee2(n, r, true); 
end); 

#############################################################################
##
#F  LowerBoundCoveringRadiusCountingExcess( <n>, <r> )
## 

InstallMethod(LowerBoundCoveringRadiusCountingExcess, 
	"code length, code size or covering radius, usage", true, 
	[IsInt, IsInt, IsBool], 0, 
function(n, r, usage) 
    local m, lb, ub, tmpcr, tmpsize, t, rho, eps;
    
    if n<=0 then
        Error( "LBCRCountingExcess: <n> must be positive" );
    fi;
    
    if usage = false then
        m := r;
        if m<=0 or m > 2^n then
            Error( "LBCRCountingExcess: <m> must be > 0 and <= 2^n" );
        fi;
        
        lb := 0;
        ub := IntFloor( ( n-1 ) / 2 );
        while lb <> ub do
            tmpcr := IntFloor( ( ub + lb ) / 2 );
            tmpsize := LowerBoundCoveringRadiusCountingExcess(
                               n, tmpcr, true );
            if tmpsize > m then
                lb := tmpcr + 1;
            else
                ub := tmpcr;
            fi;
        od;
        return ub;
    else
        t := r;
        if t < 0 or t > n then
            Error( "LBCRCountingExcess: <t> must be >=0 and <= <n>" );
        fi;
        
        if t < 2 or 2 * t + 1 > n then
            return 0;
        fi;
        if t = 2 then
            rho := n - 3 + 2/n;
        else
            rho := n - t - 1;
        fi;
        eps := ( t+1 ) * IntCeiling( ( n+1 ) / ( t+1 ) ) - ( n+1 );
        if eps > t then 
            return 0;
        fi;
        tmpsize := 2^n * ( rho + eps );
        tmpsize := tmpsize / ( rho * SphereContent( n, t ) 
                           + eps * SphereContent( n, t-1 ) );
        
        return IntCeiling( tmpsize );
    fi;
end);

InstallOtherMethod(LowerBoundCoveringRadiusCountingExcess, 
	"code length, code covering radius", true, 
	[IsInt, IsInt], 0, 
function(n, r) 
	return LowerBoundCoveringRadiusCountingExcess(n, r, true); 
end); 


########################################################################
##
#F  LowerBoundCoveringRadiusEmbedded1( <n>, <r> [, <givesize> ] )
##

InstallMethod(LowerBoundCoveringRadiusEmbedded1, 
	"code length, code size or covering radius, field size, usage", 
	true, [IsInt, IsInt, IsInt, IsBool], 0, 
function(n, r, q, usage)
    local m, lb, ub, tmpcr, tmpsize, t, upperb;
   	if n <= 0 then 
		Error("LBCREmbedded1: <n> must be positive"); 
	fi; 

    if usage = false then
        # last argument is false, try to find a lower bound for
        # the covering radius, given length and size of the code, and field 

        m := r;
        if m <= 0 or m > q^n then
            Error( "LBCREmbedded1: <m> must be > 0 and <= q^n" );
        fi;
        
        # everything is set up. now compute the bound
        
        if m = q^n then
            return 0;
        fi;
        if n = 1 then
            return 0;
        fi;
        
        lb := 1;   
        ub := n;
        while lb <> ub do
            tmpcr := IntFloor( (ub+lb) / 2 );
            tmpsize := SphereContent( n, tmpcr, q )
                       - Binomial( 2*tmpcr, tmpcr ); 
            if tmpsize = 0 then
                lb := lb + 1;
            elif tmpsize < 0 then
                ub := tmpcr;
            else
                if 2*tmpcr+1 > n then
                    upperb := 1;
                else
                    upperb := UpperBound( n, 2*tmpcr+1, q );
                fi;
                tmpsize := IntCeiling( ( q^n - upperb
                                   * Binomial( 2 * tmpcr, tmpcr ) )
                                   / tmpsize );
                if tmpsize > m then
                    lb := tmpcr + 1;
                else
                    ub := tmpcr;
                fi;
            fi;
        od;
        return ub;
    else
        # the last argument is not false
        # now it is assumed that the first argument is the length
        # of the code and the second argument is the covering radius
        # of the code. a lower bound for the minimal size of the
        # code is returned
        
        t := r;
        if t < 0 or t > n then
            Error( "LBCREmbedded1: <t> must be >= 0 and <= <n>" );
        fi;
        
        tmpsize := SphereContent( n, t, q ) - Binomial( 2*t, t );
        if tmpsize <= 0 then
            return 0;
        else
            if 2 * t + 1 > n then
                upperb := 1;
            else
                upperb := UpperBound( n, 2*t+1, q );
            fi;
            return IntCeiling( ( q^n - upperb
              * Binomial( 2*t, t ) ) / tmpsize );
        fi;
    fi;
end);

InstallOtherMethod(LowerBoundCoveringRadiusEmbedded1, 
	"code length, code size or covering radius, field, usage", 
	true, [IsInt, IsInt, IsField, IsBool], 0, 
function(n, r, F, usage) 
	if not IsFinite(F) then 
		Error("LBCREmbedded1: <F> must be a finite field"); 
	else 
		return LowerBoundCoveringRadiusEmbedded1(n, r, Size(F), usage); 
	fi; 
end); 

InstallOtherMethod(LowerBoundCoveringRadiusEmbedded1,  
	"code length, code size or covering radius, usage", 
	true, [IsInt, IsInt, IsBool], 0, 
function(n, r, usage) 
	return LowerBoundCoveringRadiusEmbedded1(n, r, 2, usage); 
end); 

InstallOtherMethod(LowerBoundCoveringRadiusEmbedded1, 
	"code length, code covering radius, field size", true, 
	[IsInt, IsInt, IsInt], 0, 
function(n, r, q) 
	return LowerBoundCoveringRadiusEmbedded1(n, r, q, true); 
end); 

InstallOtherMethod(LowerBoundCoveringRadiusEmbedded1, 
	"code length, code covering radius, field", true, 
	[IsInt, IsInt, IsField], 0, 
function(n, r, F) 
	if not IsFinite(F) then 
		Error("LBCREmbedded1: <F> must be a finite field");  
	else 
		return LowerBoundCoveringRadiusEmbedded1(n, r, Size(F), true); 
	fi; 
end); 

InstallOtherMethod(LowerBoundCoveringRadiusEmbedded1, 
	"code length, code covering radius", true, [IsInt, IsInt], 0, 
function(n, r) 
	return LowerBoundCoveringRadiusEmbedded1(n, r, 2, true); 
end); 


########################################################################
##
#F  LowerBoundCoveringRadiusEmbedded2( <n>, <r> [, <givesize> ] )
##

InstallMethod(LowerBoundCoveringRadiusEmbedded2, 
	"code length, code size or covering radius, field size, usage", 
	true, [IsInt, IsInt, IsInt, IsBool], 0, 
function(n, r, q, usage) 
    local m, lb, ub, tmpcr, tmpsize, t, upperb;
   	if n <= 0 then 
		Error("LBCREmbedded2: <n> must be positive"); 
	fi; 

    if usage = false then
        # last argument is false, try to find a lower bound for
        # the covering radius, given length and size of the code, and field 
        
        m := r;
        if m <= 0 or m > q^n then
            Error( "LBCREmbedded2: <m> must be > 0 and <= q^n" );
        fi;
        
        # everything is set up. now compute the bound
        
        if m = q^n then
            return 0;
        fi;
        if n = 1 or n = 2 then
            return 0;
        fi;
        
        lb := 1;   
        ub := n;
        while lb <> ub do
            
            tmpcr := IntFloor( (ub+lb) / 2 );
            tmpsize := SphereContent( n, tmpcr, q )
                       - 3/2 * Binomial( 2*tmpcr, tmpcr ); 
            if tmpsize = -1/2 then
                lb := lb + 1;
            elif tmpsize <= 0 then
                ub := tmpcr;
            else
                if 2*tmpcr+1 > n then
                    upperb := 1;
                else
                    upperb := UpperBound( n, 2*tmpcr+1, q );
                fi;
                tmpsize := IntCeiling( ( q^n - 2 * upperb
                                   * Binomial( 2*tmpcr, tmpcr ) )
                                   / tmpsize );
                if tmpsize > m then
                    lb := tmpcr + 1;
                else
                    ub := tmpcr;
                fi;
            fi;
        od;
        return ub;
    else
        # the last argument is not false
        # now it is assumed that the first argument is the length
        # of the code and the second argument is the covering radius
        # of the code. a lower bound for the minimal size of the
        # code is returned
        
        t := r;
        if t < 0 or t > n then
            Error( "LBCREmbedded2: <t> must be >= 0 and <= <n>" );
        fi;
        
        tmpsize := SphereContent( n, t, q ) - 3/2*Binomial( 2*t, t );
        if tmpsize <= 0 then
            return 0;
        else
            if 2*t+1 > n then
                upperb := 1;
            else
                upperb := UpperBound( n, 2*t+1, q );
            fi;
            
            return IntCeiling( ( q^n - 2*upperb
                           * Binomial( 2*t, t ) ) / tmpsize );
        fi;
    fi;
end);

InstallOtherMethod(LowerBoundCoveringRadiusEmbedded2, 
	"code length, code size or covering radius, field, usage", 
	true, [IsInt, IsInt, IsField, IsBool], 0, 
function(n, r, F, usage) 
	if not IsFinite(F) then 
		Error("LBCREmbedded2: <F> must be a finite field"); 
	else 
		return LowerBoundCoveringRadiusEmbedded2(n, r, Size(F), usage); 
	fi; 
end); 

InstallOtherMethod(LowerBoundCoveringRadiusEmbedded2, 
	"code length, code size or covering radius, usage", 
	true, [IsInt, IsInt, IsBool], 0, 
function(n, r, usage) 
	return LowerBoundCoveringRadiusEmbedded2(n, r, 2, usage);  
end); 

InstallOtherMethod(LowerBoundCoveringRadiusEmbedded2, 
	"code length, code covering radius, field size", 
	true, [IsInt, IsInt, IsInt], 0, 
function(n, r, q) 
	return LowerBoundCoveringRadiusEmbedded2(n, r, q, true); 
end); 

InstallOtherMethod(LowerBoundCoveringRadiusEmbedded2, 
	"code length, code covering radius, field", 
	true, [IsInt, IsInt, IsField], 0, 
function(n, r, F) 
	if not IsFinite(F) then 
		Error("LBCREmbedded2: <F> must be a finite field"); 
	else 
		return LowerBoundCoveringRadiusEmbedded2(n, r, Size(F), true); 
	fi; 
end); 

InstallOtherMethod(LowerBoundCoveringRadiusEmbedded2, 
	"code length, code covering radius", 
	true, [IsInt, IsInt], 0, 
function(n, r) 
	return LowerBoundCoveringRadiusEmbedded2(n, r, 2, true); 
end); 


#############################################################################
##
#F  LowerBoundCoveringRadiusInduction( <n>, <r> ) Induction bound
##

InstallMethod(LowerBoundCoveringRadiusInduction, 
	"method for two integers", true, [IsInt, IsInt], 0, 
function(n, t) 
    if n <= 0 then 
        Error( "LBCRInduction: <n> must be positive" );
    fi;
    if t < 0 or t > n then
        Error( "LBCRInduction: <t> must be >= 0 and <= <n>" );
    fi;
    
    if n = 2 * t + 2 and t >= 1 then
        return 4;
    elif n = 2 * t + 3 and t >= 1 then
        return 7;
    elif n = 2 * t + 4 and t >= 4 then
        return 8;
    else
        return 0;
    fi;
    
end);

        
########################################################################
##
#F  GeneralUpperBoundCoveringRadius( <code> )
##
InstallMethod(GeneralUpperBoundCoveringRadius, "unrestricted code", true, 
	[IsCode], 0, 
function(code) 
    local listofbounds;

    listofbounds := [ UpperBoundCoveringRadiusStrength( code ) ];
    if WordLength( code ) <= 100 then
        Append( listofbounds, [
          UpperBoundCoveringRadiusDelsarte( code )
                ] );
    fi;
    if IsLinearCode( code ) then
        Append( listofbounds, [
          UpperBoundCoveringRadiusRedundancy( code ),
        ] );
        if LeftActingDomain( code ) = GF(2) then
            if ( IsBound( code!.lowerBoundMinimumDistance ) and
                 IsBound( code!.upperBoundMinimumDistance ) ) and
               LowerBoundMinimumDistance( code ) = 
                 UpperBoundMinimumDistance (code ) 
               then
                Append( listofbounds, [
                        UpperBoundCoveringRadiusGriesmerLike( code )
                        ] );
            fi;
        fi;
    fi;
    if IsCyclicCode( code ) and LeftActingDomain( code ) = GF(2) then
        Append( listofbounds, [
          UpperBoundCoveringRadiusCyclicCode( code )
        ] );
    fi;
    if IsBound( code!.boundsCoveringRadius ) then  
        Add( listofbounds, Maximum( code!.boundsCoveringRadius ) );
    fi;
    return Minimum( listofbounds );
end);


########################################################################
##
#F  UpperBoundCoveringRadiusRedundancy( <code> )
##
##  Return the redundancy of the code as an upper bound for
##  the covering radius.
##
##  Only for linear codes.
##

InstallMethod(UpperBoundCoveringRadiusRedundancy, "unrestricted code", true, 
	[IsCode], 0, 
function( code ) 
	if IsLinearCode( code ) then 
		return UpperBoundCoveringRadiusRedundancy( code ); 
	else 
		Error("UBCRRedundancy: <code> must be a linear code"); 
	fi; 
end); 

InstallMethod(UpperBoundCoveringRadiusRedundancy, "linear code", true, 
	[IsLinearCode], 0, 
function( code) 
	return Redundancy(code); 
end); 


########################################################################
##
#F  UpperBoundCoveringRadiusDelsarte( <code> )
##

InstallMethod(UpperBoundCoveringRadiusDelsarte, "method for unrestricted codes", true, [IsCode], 0, 
function(code) 
	local p; 
	p := CodeMacWilliamsTransform(code); 
	p := CoefficientsOfLaurentPolynomial(p); 
	p := ShiftedCoeffs(p[1], p[2]); 
	return WeightVector(p) - 1; 
end); 

InstallMethod(UpperBoundCoveringRadiusDelsarte, "method for linear codes", 
	true, [IsLinearCode], 0, 
function(code) 
	local dual, wddual;  
	if not IsBound(code!.boundsCoveringRadius) then
		# avoid recursion
		code!.boundsCoveringRadius := [ 0 .. WordLength( code ) ];
	fi;
	dual := DualCode( code );
	wddual := WeightDistribution( dual );
	return WeightVector( wddual ) - 1;
end); 


########################################################################
##
#F  UpperBoundCoveringRadiusStrength( <code> )
##
##  Return (q-1)n/q as an upper bound for <code>, if it
##  has strength 1 (i.e. every coordinate contains each element
##  of the field the same number of times).
##

InstallMethod(UpperBoundCoveringRadiusStrength, "method for unrestricted codes", 	true, [IsCode], 0, 
function(code) 
	local q, n, stris1, i, j, els, fieldels, coordlist, number, zerocols; 
	if IsLinearCode(code) then 
		return UpperBoundCoveringRadiusStrength(code); 
	fi; 
	q := Size( LeftActingDomain( code ) );
    n := WordLength( code );
	stris1 := true;
	i := 1;
	els := VectorCodeword( AsSSortedList( code ) );
	if not ( Length( els ) in List( [ 1 .. n ], x -> q^x ) ) then
		stris1 := false;
	fi;
	fieldels := AsSSortedList(LeftActingDomain( code ) );
	zerocols := 0;
	while stris1 and i <= n do
		coordlist := List( els, x -> x[ i ] );
		for j in fieldels do
			number := Length( Filtered( coordlist, x -> x = j ) );
			if number = Length( els ) then
				zerocols := zerocols + 1;
			elif number <> Length( els ) / q then
				stris1 := false;
			fi;
		od;
		i := i + 1;
	od;
	if stris1 then
		return IntFloor((q-1)*(n-zerocols)/q)+zerocols;
	else
		return n;
	fi;
end);

InstallMethod(UpperBoundCoveringRadiusStrength, "method for linear code", 
	true, [IsLinearCode], 0, 
function(code) 
	local q, zerocols, i, j, genmat, n, k, zero, onlyzeroes;
	if Dimension(code) = 0 then 
		return WordLength(code); 
	fi; 
	q := Size(LeftActingDomain(code)); 
	genmat := GeneratorMat( code );
	n := WordLength( code );
	k := Dimension( code );
	zerocols := 0;
	zero := Zero(LeftActingDomain(code));
	for i in [ 1 .. n ] do
		onlyzeroes := true;
		j := 1;
		while onlyzeroes and j <= k do
			onlyzeroes := ( genmat[ j ][ i ] = zero );
			j := j + 1;
		od;
		if onlyzeroes then
			zerocols := zerocols + 1;
		fi;
	od;

	return IntFloor((q-1)*(n-zerocols)/q) + zerocols;
end);


########################################################################
##
#F  UpperBoundCoveringRadiusGriesmerLike( <code> )
##

InstallMethod(UpperBoundCoveringRadiusGriesmerLike, "unrestrictred code", 
	true, [IsCode], 0, 
function( code ) 
	if IsLinearCode( code ) then 
		return UpperBoundCoveringRadiusGriesmerLike(code); 
	else 
		Error("UBCRGriesmerLike: <code> must be a linear code"); 
	fi; 
end); 

InstallMethod(UpperBoundCoveringRadiusGriesmerLike, "linear codes", true, 
	[IsLinearCode], 0, 
function(code) 
    local q;
    q := Size( LeftActingDomain( code ) );
    return WordLength( code ) - Sum( [ 1 .. Dimension( code ) ],
                   x -> IntCeiling( MinimumDistance( code ) / q^x ) );
end);


########################################################################
##
#F  UpperBoundCoveringRadiusCyclicCode( <code> )
##

InstallMethod(UpperBoundCoveringRadiusCyclicCode, "unrestricted code", 
	true, [IsCode], 0, 
function( code ) 
	if IsCyclicCode( code ) then  
		return UpperBoundCoveringRadiusCyclicCode( code ); 
	else 
		Error("UBCRCyclicCode: <code> must be a cyclic code"); 
	fi; 
end); 

InstallMethod(UpperBoundCoveringRadiusCyclicCode, "cyclic codes", true, 
	[IsCyclicCode], 0, 
function(code) 
    return WordLength( code ) - Dimension( code ) + 1 -
           IntCeiling( Weight( Codeword( GeneratorPol( code ) ) ) / 2 );
end);


