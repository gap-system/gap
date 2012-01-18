#############################################################################
##
#W semi.gi               POLENTA package                     Bjoern Assmann
##
## Methods for the calculation of
## constructive pc-sequences for rational abelian semisimple matrix groups
##
#H  @(#)$Id: semi.gi,v 1.7 2011/09/23 13:36:32 gap Exp $
##
#Y 2003
##

############################################################################
##
#F CPCS_AbelianSSBlocks( gensOfBlockAction )
##
## gensOfBlockAction is a list with the induced action of  K_p to the
## to the factors of the homogeneous series of G
##
CPCS_AbelianSSBlocks := function( gensOfBlockAction )
    local normal,newGensOfBlockAction,i,rels,r2,freeGens,l,t,
          module,r,module2,k,full,nath,realFactor,trivial, F,relOrders;
    k:=Length(gensOfBlockAction[1]);
    full:=IdentityMat(k);

    # calculate the relations of the gensOfBlockAction
    module:=IdentityMat(k);
    for r in gensOfBlockAction do
        # trivial case: we check if r contains just 1's
        trivial:=true;
        for i in [1..Length(r)] do
            if not r[i]=r[i]^0 then
               trivial:=false;
               break;
            fi;
        od;
        if not trivial then
            F := FieldByMatricesNC( r );
            if F = false then return fail; fi;
            r2 := RelationLattice( F, r );
            module:=LatticeIntersection(module,r2);
        fi;
    od;

    # let k be the number of gens = Length(gensOfBlockAction[1])
    # compute a basis for Z^k/module
    # with this vectors we can calculate free gens
     # trivial check
     if Length( module ) = 0 then
         return rec( gensOfBlockAction := gensOfBlockAction,
                     newGensOfBlockAction := gensOfBlockAction,
                     trsf := IdentityMat(k),
                     rels := module,
                     relOrders := List( [1..k] , x-> 0 )
                   );
     fi;
    realFactor := GeneratorLattice( module );
    relOrders := realFactor.relord;
    realFactor := realFactor.exps;

    # calculate the new free generators blockwise
    newGensOfBlockAction:=[];
    for i in [1..Length(gensOfBlockAction)] do
        newGensOfBlockAction[i]:=[];
        for t in realFactor do
            Add( newGensOfBlockAction[i],
                 Exp2Groupelement(gensOfBlockAction[i],t));
         od;
    od;

    return rec( gensOfBlockAction := gensOfBlockAction,
                newGensOfBlockAction := newGensOfBlockAction,
                trsf := realFactor, rels := module, relOrders := relOrders);
end;

#############################################################################
##
#F POL_TestExponentVector_AbelianSS( CPCS_nue_K_p, g, exp )
##
POL_TestExponentVector_AbelianSS := function( CPCS_nue_K_p, g, exp )
    local newGens, n, i, test;
    newGens := CPCS_nue_K_p.newGensOfBlockAction;
    # n is the number of blocks
    n:=Length(newGens);
    for i in [1..n] do
        test := MappedVector( exp, newGens[i]) = g[i][1];
        if test = false then
            return false;
        fi;
    od;
    return true;
end;

#############################################################################
##
#F ExponentVector_AbelianSS( CPCS_nue_K_p, g )
##
## g is a list which entries contain the induced action of an group
## element to the blocks of the factor series
##
ExponentVector_AbelianSS:=function( CPCS_nue_K_p, g )
   local trivial,freeGens,n,A,m,rels3,v,exp,i,rels,r2,F,
         rels2,r,newGens,a,ll;

   # check if nue_K_p is trivial
    if Length( CPCS_nue_K_p.relOrders )=0 then
        return [];
    fi;

   #check if g is trivial
    n := Length( g );
    trivial := true;
    for i in [1..n] do
        if not g[i][1] = g[i][1]^0 then
            trivial := false;
            break;
        fi;
    od;
    #if the action of g on the radical series is trivial we
    #return an as the exponent vector [0 ... 0] of the length of the
    #pc sequence of nue(K_p)
    if trivial then
       ll := Length( CPCS_nue_K_p.relOrders );
       return List( [1..ll], x->0 );
    fi;

   newGens := CPCS_nue_K_p.newGensOfBlockAction;
   # n is the number of blocks
   n:=Length(newGens);
   # A contains an extended genslist, i.e. the newGens plus the
   # element, for which we want to compute the exp
   A:=[];
   for i in [1..n] do
       a:=StructuralCopy(newGens[i]);
       a := Concatenation( [g[i][1]], a );
       # Add(a,g[i][1]);
       Add(A,a);
   od;
   # compute the relations of A
   rels:=IdentityMat(n+1);
            #trivial:=true;
   for r in A do
            # trivial case: we check if r just contains  1's
            #for i in [1..Length(r)] do
            # if not r[i]=r[i]^0 then
            #   trivial:=false;
            # break;
            # fi;
            #od;
            #if not trivial then
          F := FieldByMatricesNC( r );
          if F = false then return fail; fi;
          r2 := RelationLattice( F, r );
          rels:=LatticeIntersection(rels,r2);
            #fi;
   od;
            #if the action of g on the radical series is trivial we
            #return an as the exponent vector [0 ... 0] of the length of the
            #pc sequence of nue(K_p)
            #  if trivial then
            #  ll := Length( CPCS_nue_K_p.relOrders );
            #  return List( [1..ll], x->0 );
            # fi;
   rels := NormalFormIntMat(rels,0).normal;
   if not rels[1][1]=1 then return fail; fi;

   exp := -rels[1]; exp[1] := 0;
   # Reduce exp by the remaining rows
   for r in rels do
     i := PositionNonZero(r);
     if exp[i] < 0 then
       exp := exp + QuoInt(-exp[i]+r[i]-1, r[i]) * r;
     fi;
   od;

   # Remove the leading zero
   Remove(exp, 1);

   Assert( 2,  POL_TestExponentVector_AbelianSS( CPCS_nue_K_p, g, exp ),
           "failure in ExponentVector_AbelianSS" );
   return exp;
end;

#############################################################################
##
#F Membership_AbelianSS(CPCS_nue_K_p,g)
##
## g is a list which entries contains the induced action to a block
##
Membership_AbelianSS:=function(CPCS_nue_K_p,g)
    local exp;
    exp := ExponentVector_AbelianSS( CPCS_nue_K_p, g );
    if not IsBool( exp ) then
        return true;
    else
        return false;
    fi;
end;

#############################################################################
##
#F CPCS_AbelianSSBlocks_ClosedUnderConj(gens_K_p,gens,radicalSeries)
##
CPCS_AbelianSSBlocks_ClosedUnderConj := function(gens_K_p,gens,radicalSeries)
    local  list,gensOfBlockAction,CPCS_nue_K_p,g,h,test,l,gens_K_p2,i;

    #setup
    gensOfBlockAction :=POL_InducedActionToSeries( gens_K_p, radicalSeries );
    CPCS_nue_K_p:=CPCS_AbelianSSBlocks( gensOfBlockAction );
    if CPCS_nue_K_p = fail then return fail; fi;
    i := 1;

    # test if CPCS_nue_K_p is not  trivial
    if Length( CPCS_nue_K_p.relOrders ) > 0 then

       #test if the CPCS for the image is closed under conjugation
       Info( InfoPolenta, 1, "Close the constructive polycyclic sequence \n",
             "    computed with the normal subgroup generators of the kernel\n",
             "    under the conjugation action of the whole group");
       for g in gens_K_p do
           for h in gens do
               l := POL_InducedActionToSeries( [g^h], radicalSeries );
               if InfoLevel( InfoPolenta ) >= 1 then Print( "." ); fi;
               test := Membership_AbelianSS( CPCS_nue_K_p, l );
               if not test then
                   Info( InfoPolenta, 3, "Extending gens_K_p !\n");
                   Add(gens_K_p,g^h);
                   #now in gens_K_p we have a more complete list of
                   #the generators.
                   #don't forget to modify gens_K_p as well on a
                   #higher function level
                   gensOfBlockAction :=
                              POL_InducedActionToSeries(gens_K_p,radicalSeries);
                   CPCS_nue_K_p :=
                            CPCS_AbelianSSBlocks( gensOfBlockAction );
                   if CPCS_nue_K_p = fail then return fail; fi;
               fi;
               i := i+1;
            od;
        od;
        if InfoLevel( InfoPolenta ) >= 1 then Print( "\n" ); fi;
    fi;

    Info( InfoPolenta, 3,
          "loops inCPCS_AbelianSSBlocks_ClosedUnderConj  = ",
          Length(gens_K_p)*Length(gens),"\n");
     return rec( pcgs_nue_K_p := CPCS_nue_K_p, gens_K_p := gens_K_p);
end;

#############################################################################
##
#E
