#############################################################################
##
##  subfield.gi        recog package                      Max Neunhoeffer
##                                                            Ákos Seress
##                                                        Robert McDougal
##                                                            Nick Werner
##                                                            Justin Lynd
##                                                            Niraj Khare
##                                                           
## 
##
##  Copyright 2006 Lehrstuhl D für Mathematik, RWTH Aachen
##
##  Implementation stuff for subfield case.
##
##  $Id: subfield.gi,v 1.7 2006/10/13 04:36:26 gap Exp $
##
#############################################################################

InstallValue( SUBFIELD, rec() );

SUBFIELD.ScalarToMultiplyIntoSmallerField := function(m,k)
  # This assumes that m is an invertible matrix over a finite field k.
  # Returns either fail or a record r with components
  #  r.scalar
  #  r.field
  #  r.mat
  # such that r.mat = r.scalar * m and r.mat has entries in r.field
  # and r.field is a field contained in Field(m).
  local f,mm,pos,s;
  if IsPrimeField(k) then return fail; fi;
  pos := PositionNonZero(m[1]);
  s := m[1][pos]^-1;
  mm := s * m;
  f := FieldOfMatrixList([mm]);
  if k = f then return fail; fi;
  return rec( mat := mm, scalar := s, field := f );
end;

SUBFIELD.ScalarsToMultiplyIntoSmallerField := function(l,k)
  # The same as above but for a list of matrices. Returns either fail
  # or a record:
  #  r.scalars
  #  r.newgens
  #  r.field
  local f,i,newgens,r,scalars;
  scalars := [];
  newgens := [];
  f := PrimeField(k);
  for i in [1..Length(l)] do
      r := SUBFIELD.ScalarToMultiplyIntoSmallerField(l[i],k);
      if r = fail then return fail; fi;
      if not(IsSubset(f,r.field)) then
          f := ClosureField(f,r.field);
          if f = k then 
              return fail; 
          fi;
      fi;
      scalars[i] := r.scalar;
      newgens[i] := r.mat;
  od;
  return rec(scalars := scalars, newgens := newgens, field := f );
end;

SUBFIELD.BaseChangeForSmallestPossibleField := function(grp,mtx,k)
  # grp is a matrix group over k, which must be a finite field. mtx must be 
  # the GModuleByMats(GeneratorsOfGroup(grp),k).
  # The module mtx must be irreducible (not necessarily absolutely irred). 
  # A subfield f of k has property (*), if and only if there
  # is an invertible matrix t with entries in k such that for every generator
  # x in gens t*x*t^-1 has entries in f.
  # Lemma: There is a smallest subfield f of k with property (*).
  # This function either returns fail (in case f=k) or returns a record r
  # with the following components:
  #   r.t       : the matrix t
  #   r.ti      : the inverse of t
  #   r.newgens : the list of generators t * x * ti
  #   r.field   : the smaller field 

  local a,algel,b,bi,charPoly,deg,dim,element,f,facs,field,g,i,newgens,
        r,scalars,seb,v,w;

  f := PrimeField(k);
  MTX.IsAbsolutelyIrreducible(mtx);  # To ensure that the following works:
  deg := MTX.DegreeSplittingField(mtx)/DegreeOverPrimeField(k);

  # Now try to find an IdWord:
  element := false ;
  a := Zero(GeneratorsOfGroup(grp)[1]);
  dim := Length(a);
  while ( element = false ) do
    a := a + Random ( f ) * PseudoRandom ( grp ) ;
  
    # Check char. polynomial of a to make sure it lies in smallField [ x ]
    charPoly := CharacteristicPolynomial ( a ) ;
    field := Field(CoefficientsOfLaurentPolynomial(charPoly)[1]);
    if not(IsSubset(f,field)) then
        f := ClosureField(f,field);
        if Size(f) >= Size(k) then
            return fail;
        fi;
    fi;
    
    # FIXME: We only take factors that occur just once (good factors)!
    facs := Collected(Factors(charPoly : onlydegs := [1..3]));
    facs := Filtered(facs,x->x[2] = 1);
    
    i := 1;
    while i <= Length(facs) do
        algel := Value(facs[i][1],a);
        v := MutableCopyMat(NullspaceMat(algel));
        if Length(v) = deg then  # this is an IdWord!
            break;
        fi;
        i := i + 1;
    od;

    if i <= Length(facs) then   # we were successful!
        element := algel;
    fi;
  od;

  # If we have reached this position, we have an idword and now spin up:
  seb := rec( vectors := [], pivots := [] );
  b := [ShallowCopy(v[1])];
  RECOG.CleanRow(seb,v[1],true,fail);
  i := 1;
  while Length(b) < dim do
      for g in GeneratorsOfGroup(grp) do
          w := b[i] * g;
          if RECOG.CleanRow( seb, ShallowCopy(w), true, fail ) = false then
              Add(b,w);
          fi;
      od;
      i := i + 1;
  od;
  ConvertToMatrixRep(b);
  bi := b^-1;
  newgens := List(GeneratorsOfGroup(grp),x->b*x*bi);
  f := FieldOfMatrixList(newgens);
  if f = k then return fail; fi;
  return rec( newgens := newgens, field := f, t := b, ti := bi );
end;

      
###########################################################################
# Currently not used:
###########################################################################


# add the vector v into nnrbasis
# returns true if v expands the set, false if not
SUBFIELD.addToNNRBasis := function ( nnrbasis , v )
  local depth , s , i , width , nonzero , temp ;

  s := Size ( nnrbasis . locOfPivots ) ;

  # get a local copy of v
  temp := ShallowCopy ( v ) ;

  # check each of the previous 1s to see if need to clear them in temp
  for i in [ 1 .. s ] do
    if not ( IsZero ( temp [ nnrbasis . locOfPivots [ i ] ] ) ) then
      AddRowVector ( temp , nnrbasis . ans [ i ] , 
                     - temp [ nnrbasis . locOfPivots [ i ] ] ) ;
    fi ;
  od ;

  # is temp the zero vector?  if so, nothing to add, so return false
  nonzero := PositionNonZero ( temp ) ;
  
  if nonzero > Size ( temp ) then
    return false ;
  fi ;

  # At this stage, temp has been cleared out by as much as possible
  # but still has something in the position nonzero
  # We scale that position to 1
  MultRowVector ( temp ,  temp [ nonzero ] ^ ( - 1 ) ) ;

  # Now clear all the old stuff
  for i in nnrbasis . ans do
    AddRowVector ( i , temp , - i [ nonzero ] ) ;
  od ;

  # Finally include temp in our results and exit
  Add ( nnrbasis . ans , temp ) ;
  Add ( nnrbasis . locOfPivots , nonzero ) ;

  return true ;
  end;


# take a group (matrixGroup) over bigField and return
# false if matrixGroup is not conjugate to an algebra over
# smallField, or return the conjugating matrix if it is
#
# Robert McDougal, Nick Werner,
# Justin Lynd, Niraj Khare
#
SUBFIELD.alg4 := function ( matrixGroup , smallField , bigField )
  local a,b,binverse,charPoly,element,field,g,i,j,k,lambda,match,newgens,
        nnrbasis,roots,temp,v,w;

  # The following is already made sure by the method selection:
  #if not MTX.IsAbsolutelyIrreducible ( GModuleByMats (
  #           GeneratorsOfGroup ( matrixGroup ) , bigField ) ) then
  #  Print ( "This algorithm takes an absolutely irreducible group.\n" ) ;
  #  return fail ;
  #fi ;
  # The following should be taken care of by the caller:
  #if not IsSubset ( bigField , smallField ) then
  #  Print ( "Error.  f = " , smallField , " must be contained in k = " ,
  #          bigField , ".\n" ) ;
  #  return fail ;
  #fi ;

  # Step 1:  Find an element that has an eigenvalue with multiplicity 1

  element := false ;
  k := 0 ;
  while ( element = false ) do
    temp := false ;
    k := k + 1 ;
    for i in [ 1 .. k ] do
      if temp then
        a := a + Random ( smallField ) * PseudoRandom ( matrixGroup ) ;
      else
        a := Random ( smallField ) * PseudoRandom ( matrixGroup ) ;
        temp := true ;
      fi ;
    od ;
  
    # Check char. polynomial of a to make sure it lies in smallField [ x ]
    charPoly := CharacteristicPolynomial ( a ) ;
    field := Field(CoefficientsOfLaurentPolynomial(charPoly)[1]);
    if not(IsSubset(smallField,field)) then
        smallField := ClosureField(smallField,field);
        if Size(smallField) >= Size(bigField) then
            return fail;
        fi;
    fi;

    # check roots of charPoly... does any have multiplicity 1?
    roots := RootsOfUPol ( charPoly ) ;
    lambda := false ;
    for i in [ 1 .. Length ( roots ) ] do
      if lambda = false and IsBound ( roots [ i ] ) then
        match := false ;
        for j in [ i + 1 .. Length ( roots ) ] do
          if roots [ i ] = roots [ j ] then
            match := true ;
            Unbind ( roots [ j ] ) ;
          fi ;
        od ;
        if not match then
          lambda := roots [ i ] ;   # if none of the other roots are the same
                          # as the ith one, the that root has multiplicity 1
        fi ;
      fi ;
    od ;
    if lambda <> false and (lambda in smallField) then
      element := a ;      
    fi ;
  od ;

  a := element ;
  # step 1 ends here.  We now have an element = a with an eigenvalue
  # lambda of multiplicity 1


  # Step 2: Get an eigenvector v of a corresponding to lambda

  # Was:
  #temp := TransposedMat ( a ) - lambda * One ( a ) ;
  temp := a - lambda * One ( a ) ;
  # Was: 
  #v := TriangulizedNullspaceMat( temp ) [1];
  v := NullspaceMat( temp ) [1];

  # step 2 ends here.  v is a (non-zero) lambda eigenvector for a


  # step 3: make a basis b out of vectors of the form g * v
  #b := [ ] ;
  nnrbasis := rec ( ans := [ ] , locOfPivots := [ ] ) ;
  
  
  # Was:
  #while not Size(b) = Size(a) do
  #  g := PseudoRandom(matrixGroup); 
  #  if ( SUBFIELD.addToNNRBasis ( nnrbasis , g * v ) ) then
  #    Add(b, g * v);
  #  fi;
  #od;
  SUBFIELD.addToNNRBasis( nnrbasis, v );
  b := [v];
  i := 1;
  while Length(b) < Length(a) do
      for g in GeneratorsOfGroup(matrixGroup) do
          w := b[i] * g;
          if SUBFIELD.addToNNRBasis( nnrbasis, w ) then
              Add(b,w);
          fi;
      od;
      i := i + 1;
  od;
  ConvertToMatrixRep(b);

  # up until now, b is a list of row vectors... we want to transpose it
  # no longer necessary: b := TransposedMat ( b ) ;    

  # step 3 ends here


  # step 4: conjugate the generators by B & check to see if inside the
  # smaller field. Somehow we are getting here without (necessarily)
  # having b being n x n ???
  binverse := b ^ ( -1 ) ;
  # A little optimisation here, create group object outside:
  newgens := [];
  for g in GeneratorsOfGroup ( matrixGroup ) do 
    # Was:
    # temp := binverse * g * b ;
    temp := b * g * binverse ;
    Add(newgens,temp);
    field := FieldOfMatrixList([temp]);
    if not(IsSubset(smallField,field)) then
        smallField := ClosureField(smallField,field);
        if Size(smallField) >= Size(bigField) then
            return fail;
        fi;
    fi;
  od;
  
  return rec(t := b, ti := binverse, newgens := newgens, 
             field := smallField);
  end ;

# take an absolutely irreducible matrix group g over k and
# decide if it is (modulo scalars in k)
# conjugate to a group over f
#
# Robert McDougal, Nick Werner,
# Justin Lynd, Niraj Khare

# *********  REQUIRES SUBFIELD.alg4 *********
SUBFIELD.alg8 := function ( g , gPrime , f , k )
  local gPrimeGenerators, moduleGenerators, 
	s, temp, t, cosets, cosetReps, length, c, 
	smallRing, charPoly, j, i, perm, c_jSizes ,
        done , positionInTree , descendNext ,
        chanceOfSuccess , depthInTree , gPrimeGenerators2 ,
        testThreshold , k2 , b , bInverse ,
        success , skew ;

  # This must only be called if the natural module of the matrix group g
  # is absolutely irreducible and the natural module of gprime (the derived
  # subgroup) is not absolutely irreducible.
  
  # The following is taken care for in the method selection already:
  # check for absolute irreducibility of g first
  #if not (MTX.IsAbsolutelyIrreducible (
  #    GModuleByMats(GeneratorsOfGroup(g) , k))) then
  #  Print("This algorithm requires an absolutely irreducible group.\n");
  #  return fail ;
  #fi ;
	
  # The following lies in the responsibility of the caller:
  # check to make sure that f is contained in k
  #if not IsSubset(k, f) then
  #  Print("\nError. f = ", f, 
  #        " must be contained in of k = ", k, "\n");
  #  return fail;
  #fi;

  # We already do this outside:
  # Calculating the derived subgroup in general takes a LONG time
  # Let's not do that if our group is really just conjugate to
  # a matrix group over the smaller field
  # For certain types of testing, you may wish to comment out this
  # section.
  #temp := SUBFIELD.alg4 ( g , f , k ) ;
  #if ( temp <> fail and temp <> false ) then
  #  return temp ;
  #fi ;

  # set the threshold for testing (currently arbitrarily)
  testThreshold := 10 ;

  # Step 1:  find a list s of elements of g that together 
  #          with g' act absolutely irreducibly.  

  # we already got that: gPrime := DerivedSubgroup ( g ) ;
  gPrimeGenerators2 := GeneratorsOfGroup ( gPrime ) ;
  # Was:
  #gPrimeGenerators := [ ] ;
  #for temp in gPrimeGenerators2 do
  #  Add ( gPrimeGenerators , temp ) ;
  #od ;
  gPrimeGenerators := ShallowCopy(gPrimeGenerators2);
  s := [ ] ;
  moduleGenerators := StructuralCopy ( gPrimeGenerators ) ;

  repeat
  #while not (MTX.IsAbsolutelyIrreducible(
  #	         GModuleByMats(moduleGenerators , k ))) do
    		
    # to avoid redundancy in s, we check each time
    # to make sure that temp is not already in s		
    temp := PseudoRandom ( g ) ;
    # Will not happen, test is expensive, if so, does not hurt:
    #if Length ( s ) >= 1 then 
    #  while temp in Group ( s ) do
    #    temp := PseudoRandom(g);
    #  od ;
    #fi ;
    Add ( s , temp ) ;
    Add ( moduleGenerators , temp ) ;
  #od ;
  until MTX.IsAbsolutelyIrreducible(GModuleByMats(moduleGenerators,k));
  #t := Length ( s ) ;
  #if t = 0 then
  #  Print("This algorithm requires that the commutator subgroup\n");
  #  Print("does not act absolutely irreducibly.\n");
  #  return(fail);
  #fi ;
  # Step 1 ends here


  # Step 2a:  Find the set c_j of cosets of Units(f) in 
  #           Units(k) such that x*s[j] has its char poly 
  #           in f, where x is a representative of a coset  
  	
  # we require the cosets of the group of units of f in the
  # group of units of k
  cosets := RightCosets(Units(k), Units(f));
	
  # since we will have a list of cosets and a list of coset
  # representatives running in parallel, we work with the 
  # indices of the elements of the lists rather than the 
  # actual elements. That is, we use 
  # 'for i in [1..Length(cosets]' rather than
  # 'for x in cosets'
	
  length := Length(cosets);
  cosetReps := [];
  for i in [1..length] do
    Add(cosetReps, Representative(cosets[i]));
  od;
	
  # c will be the list of lists of cosets c_j for which 
  # cosetReps[i]*s[j] has its charPoly in f
  c := [];
  smallRing := PolynomialRing(f);
  for j in [1 .. t] do
    c[j] := [];
    for i in [1..length] do
      charPoly := CharacteristicPolynomial ( cosetReps [ i ] * s [ j ] ) ;
      if charPoly in smallRing then
        Add ( c [ j ] , cosetReps [ i ] ) ;
      fi;
    od;
				
    if Length ( c [ j ] ) = 0 then
      return false ;
    fi ;
  od ;


####################################
#  Step 2b:  Reorder s (and c) in order of 
#            increasing size of c_j
############################################

  SortParallel(c,s, function(v,w) return Length(v) < Length(w) ; end );


  # Step 3:  backtrack search fun
  done := false ;
  depthInTree := 0 ;
  positionInTree := [ ] ;
  descendNext := true ;   # true when next move to descend;
                          # false when next move to advance
  success := false ;
  while not done do

    # move to next position in tree

    if descendNext then
      depthInTree := depthInTree + 1 ;
      positionInTree [ depthInTree ] := 1 ;
    else
      positionInTree [ depthInTree ] := positionInTree [ depthInTree ]+ 1  ;
      if positionInTree [ depthInTree ] <= Length ( c [ depthInTree ] ) then
        done := true ;
      fi ;
      # backtrack if we can't advance until we get to a point where we can
      # (and then advance at that point)
      while not done do
        depthInTree := depthInTree - 1 ;
        if depthInTree = 0 then
          done := true ;
        else
          positionInTree [ depthInTree ] := positionInTree [ depthInTree ] + 1;
          if positionInTree [ depthInTree ] <= Length(c[depthInTree]) then
            done := true ;
          fi ;
        fi ;
      od ;
      if depthInTree > 0 then
        done := false ;
      fi ;
    fi ;

    if depthInTree > 0 then
      # is there any chance of this position working?
      # We do this by picking some elements of
      #   F[<g' , s_1*c_1 , ... , s_depthInTree*c_depthInTree>]
      # and checking their characteristic poly
      # To work, the characteristic poly must lie in F[x]...
      # we try testThreshold number of times using elements
      # with testThreshold parts from G' and testThreshold
      # parts from s_i*c_i
      chanceOfSuccess := true ;

      for i in [ 1 .. testThreshold ] do
        if chanceOfSuccess then
          temp := Zero ( f ) ;
          for j in [ 1 .. testThreshold ] do
            k2 := Random ( [ 1 .. depthInTree ] ) ;
            temp := temp + Random ( f ) * PseudoRandom ( gPrime ) 
                         + Random ( f ) * s [ k2 ] * c[k2][positionInTree[k2]];
          od ;
          if not ( CharacteristicPolynomial ( temp ) in smallRing ) then
            chanceOfSuccess := false ;
          fi ;
        fi ;
      od ;

      # if yes, next time descend;
      # if no, next time advance on same level (or backtrack)
      descendNext := chanceOfSuccess ;  # we use these being independent
                                        # later, so don't try to
                                        # consolidate variables without
                                        # taking that into account

      # are we at depth t?  Be deterministic then (only check of
      # course if there's a chance that this could work)
      if depthInTree = t then
        descendNext := false ;
        if chanceOfSuccess then
          # Can < g' , s_1*c_1 , ... , s_t*c_t > be written over F?
          # sounds like a job for SUBFIELD.alg4
          temp := ShallowCopy ( gPrimeGenerators ) ;
          for i in [ 1 .. t ] do
            Add ( temp , s [ i ] * c [ i ] [ positionInTree [ i ] ] ) ;
          od ;
          b := SUBFIELD.alg4 ( Group ( temp ) , f , k ) ;
          if ( b <> fail ) and ( b <> false ) then
            # if we're inside this if loop, then yes it could be.
            # conjugating matrix is b.  So let's check the generators
            # of the original group g to see if when we conjugate them by
            # b, we get a matrix that is a k-scalar multiple of a matrix
            # in f.
            success := true ;
            bInverse := b ^ ( -1 ) ;
            for k2 in GeneratorsOfGroup ( g ) do 
              if success then
                temp := b * k2 * bInverse ;
                done := false ;
                # find a nonzero i , j position inside temp
                # must exist since temp <> [ 0 ]
                i := 1 ;
                j := 1 ;
                while not done do
                  if IsZero ( temp [ i ] [ j ] ) then
                    i := i + 1 ;
                    if i > Size ( temp ) then
                      i := 1 ;
                      j := j + 1 ;
                    fi ;
                  else
                    done := true ;
                  fi ;
                od ;
                # all entries of temp must lie in the same coset
                # as temp [ i ] [ j ]... thus if we divide the entries
                # all by this element the result must lie in f
                skew := temp [ i ] [ j ] ;
                success := ( skew ^ ( -1 ) * temp ) in GL ( Size ( temp ) , f );
              fi ;
            od ;
            # done iff success
            done := success ;
          fi ;
        fi ;
      fi ;
     
    else
      done := true ;
    fi ;

  od ;

  # How about the scalars???
  if success then
    return b ;
  fi ;

  return false ;

  end;

###########################################################################
# End of currently not used.
###########################################################################

# The subfield find hom method:

SUBFIELD.ForceToOtherField := function(m,fieldsize)
  local n,v,w;
  n := [];
  for v in m do
      w := List(v,x->x);  # this unpacks
      if ConvertToVectorRep(w,fieldsize) = fail then
          return fail;
      fi;
      Add(n,w);
  od;
  ConvertToMatrixRep(n,fieldsize);
  return n;
end;

SUBFIELD.HomDoBaseAndFieldChange := function(data,el)
  local m;
  m := data.t * el * data.ti;
  return SUBFIELD.ForceToOtherField(m,Size(data.field));
end;

SUBFIELD.HomDoBaseAndFieldChangeWithScalarFinding := function(data,el)
  local m,p;
  m := data.t * el * data.ti;
  p := PositionNonZero(m[1]);
  m := (m[1][p]^-1) * m;     # this gets rid of any possible scalar
                             # from some bigger field
  return SUBFIELD.ForceToOtherField(m,Size(data.field));
end;

FindHomMethodsProjective.Subfield :=
  function(ri,G)
    # We assume G to be absolutely irreducible, although this is not 
    # necessary:
    local Gprime,H,b,dim,f,hom,mo,newgens,pf,r;
    f := FieldOfMatrixGroup(G);
    if IsPrimeField(f) then
        return false;     # nothing to do
    fi;
    if not(IsBound(ri!.meataxemodule)) then
        ri!.meataxemodule := GModuleByMats(GeneratorsOfGroup(G),f);
    fi;
    if not(MTX.IsIrreducible(ri!.meataxemodule)) then
        return false;     # not our case
    fi;
    dim := DimensionOfMatrixGroup(G);
    pf := PrimeField(f);
    b := SUBFIELD.BaseChangeForSmallestPossibleField(G,ri!.meataxemodule,f);
    if b <> fail then
        Info(InfoRecog,1,"Conjugating group from GL(",dim,",",f,
             ") into GL(",dim,",",b.field,").");
        # Do base change isomorphism:
        H := GroupWithGenerators(b.newgens);
        hom := GroupHomByFuncWithData(G,H,SUBFIELD.HomDoBaseAndFieldChange,b);
        # Now report back, it is an isomorphism:
        Sethomom(ri,hom);
        findgensNmeth(ri).method := FindKernelDoNothing;
        return true;
    fi;

    # Now look at the derived subgroup:
    Info(InfoRecog,1,"Computing derived subgroup...");
    Gprime := RECOG.DerivedSubgroupMonteCarlo(G);
    mo := GModuleByMats(GeneratorsOfGroup(Gprime),f);
    if not(MTX.IsIrreducible(mo)) then
        # Handle reducible case
        ri!.derived := Gprime;
        ri!.derived_mtx := mo;
        Info(InfoRecog,1,"Reducible derived subgroup, we give up here, ",
             "others will continue this...");
        return false;    # the derived subgroup method will follow!
    else
        # Try with derived subgroup:
        b := SUBFIELD.BaseChangeForSmallestPossibleField(Gprime,mo,f);
        if b = fail then return false; fi;    # not our case
        Info(InfoRecog,1,"Can conjugate derived subgroup from GL(",dim,
             ",",f,") into GL(",dim,",",b.field,").");
        # Now do base change for generators of G:
        newgens := List(GeneratorsOfGroup(G),x->b.t*x*b.ti);
        r := SUBFIELD.ScalarsToMultiplyIntoSmallerField(newgens,f);
        if r = fail then return false; fi;
        Info(InfoRecog,1,"Conjugating group from GL(",dim,",",f,
             ") into GL(",dim,",",r.field,").");

        # Set up an isomorphism:
        H := GroupWithGenerators(newgens);
        hom := GroupHomByFuncWithData(G,H,
                      SUBFIELD.HomDoBaseAndFieldChangeWithScalarFinding,b);
        # Now report back, it is an isomorphism, because this is a projective
        # method:
        Sethomom(ri,hom);
        findgensNmeth(ri).method := FindKernelDoNothing;
        return true;
    fi;
  end;


