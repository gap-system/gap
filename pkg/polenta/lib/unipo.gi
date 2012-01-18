#############################################################################
##
#W unipo.gi               POLENTA package                     Bjoern Assmann
##
## Methods for the calculation of
## constructive pc-sequences for unipotent matrix groups
##
#H  @(#)$Id: unipo.gi,v 1.13 2011/09/23 13:50:46 gap Exp $
##
#Y 2003
##


# We have to calculate a basis of Q^d
# which exhibits a flag for all u in gens.
# we know that the matrices
# in gens are unipotent. next we have to determine the nullspace of
# (u-1)^1, (u-1)^2,...  we have to do that simultaneously for all
# matrices in gens so we have to write them in one big matrix.

#############################################################################
##
#F POL_BuildBigMatrix( modifiedGens )
##
## writes the matrices of modifiedGens in matrix s.t. we can
## apply NullspaceRatMat
## if modifiedGens=[g_1,...,g_n] then
## BigMatrix:=(g_1,...,g_n)
##
POL_BuildBigMatrix := function( modifiedGens )
    local bigMatrix,i,j ;
    bigMatrix := [];
    for i in [1..Length( modifiedGens[1] )] do
        bigMatrix[i] := [];
        for j in [1..Length(modifiedGens )] do
            Append( bigMatrix[i],modifiedGens[j][i] );
        od;
    od;
    return bigMatrix;
end;


#For determining a flag you have to compute the nullspace W of a matrix u
#then you proceed by passing to the factor V/W an compute a new
#nullspace.
#this process will terminate, because u is unipotent which means that
#u is conjugate to a upper triangular matrix with one's on the diagonal

#############################################################################
##
#F POL_DetermineFlag( gens )
##
POL_DetermineFlag := function( gens )
    local d,flag,u,bigMatrix,nullSpace,full,indGens,factorFlag,
          preImage,modifiedGens,nath;
    d := Length( gens[1][1] );
    flag := [];

    # calculate (u-1 ) for all u in gens
    modifiedGens := [];
    for u in gens do
        Add( modifiedGens,u-IdentityMat(d ) );
    od;

    # calculate the nullspace W
    bigMatrix := POL_BuildBigMatrix( modifiedGens );
    nullSpace := NullspaceRatMat( bigMatrix );
    if nullSpace=[] then
        #Error("Failure in POL_DetermineFlag\n Group is not unipotent\n" );
        return fail;
    fi;

    # induce action to the factor V/W
    full := IdentityMat( d );
    if Length( nullSpace )=d then
        return nullSpace;
    fi;
    nullSpace :=POL_CopyVectorList( nullSpace );
    TriangulizeMat( nullSpace );
    Append( flag, nullSpace );
    nath := NaturalHomomorphismBySemiEchelonBases( full, nullSpace  );
    indGens := List( gens, x-> InducedActionFactorByNHSEB(x,nath) );

    # recursive call
    factorFlag := POL_DetermineFlag( indGens );
    if factorFlag = fail then return fail; fi;
    preImage := PreimagesRepresentativeByNHSEB( factorFlag,nath );
    Append( flag,preImage );
    return flag;
end;

#############################################################################
##
#F POL_DetermineConjugatorTriangular( gens )
##
## brings gens in upper triangular form
##
POL_DetermineConjugatorTriangular := function( gens )
    local a,flag,d,g,i,j,alpha,beta;
    flag := POL_DetermineFlag( gens );
    if flag = fail then return fail; fi;
    # POL_TestFlag( flag,gens );
    d  :=  Length(  gens[1]  );
    g := [];
    # for an upper triangular matrix we need a inversed flag
    for i in [1..d] do
        g[i] := flag[d-i+1];
    od;
    return g^-1;
end;

#############################################################################
##
#F POL_DetermineConjugatorIntegral( gens )
##
## brings gens in integer form
##
POL_DetermineConjugatorIntegral := function( gens )
    local d,a,i,j,g,x,alpha;
    d  :=  Length( gens[1]  );
    alpha := IdentityMat(d );
    for i in [2..d] do
        a := 1;
        for g in gens do
            for j in [1..i-1] do
                x := DenominatorRat( alpha[j][j]^-1*g[j][i] );
                a := Lcm( a, x );
            od;
        od;
        alpha[i][i] := a;
    od;
    return alpha;
end;


#############################################################################
##
#F POL_UpperTriangIntTest( gens )
##
##
POL_UpperTriangIntTest := function( gens )
   local d,goodForm,g,i,j;
   d := Length( gens[1] );
   goodForm := true;
   for g in gens do
       for i in [1..d] do
           for j in [1..d] do
               if i=j then
                   if not g[i][j]=1 then
                       Info( InfoPolenta,4, i,"problemplace ",j,"\n" );
                       goodForm := false;
                       return goodForm;
                  fi;
               elif i < j then
                   if DenominatorRat( g[i][j] )>1 then
                        Info( InfoPolenta, 4,i,"problemplace ",j,"\n" );
                        goodForm := false;
                        return goodForm;
                   fi;
               elif not g[i][j]=0 then
                    Info( InfoPolenta, 4,i,"problemplace ",j,"\n" );
                    goodForm := false;
                    return goodForm;
               fi;
           od;
       od;
   od;
   return goodForm;
end;

#############################################################################
##
#F POL_DetermineRealConjugator( gens )
##
## brings <gens> in upper triangular integral form
##
POL_DetermineRealConjugator := function( gens )
    local v,gens_mod,w,conjugator;
    # upper triangular form
    v := POL_DetermineConjugatorTriangular( gens );
    if v = fail then return fail; fi;
    gens_mod := List( gens, x-> x^v );
    # upper triangular integer form
    w := POL_DetermineConjugatorIntegral( gens_mod );
    conjugator := v*w;
    # test if it is in upper triangular and integer form
    return conjugator;
end;

#############################################################################
##
#F POL_UnipotentMats2Pcp( gens )
##
## maps the unipotent group <gens> to a Pcp-Group, and saves the
## used conjugator
##
POL_UnipotentMats2Pcp := function( gens )
    local v,gens_mod,w,conjugator,pcp;
     # determine conjugator
       # upper triangular form
       v := POL_DetermineConjugatorTriangular( gens );
       if v = fail then return fail; fi;
       gens_mod := GeneratorsOfGroup( Group( gens )^v );
       # upper triangular integer form
       w := POL_DetermineConjugatorIntegral( gens_mod );
       conjugator := v*w;

     # conjugate group
       gens_mod := GeneratorsOfGroup( Group( gens )^conjugator );

     # test if it is in upper triangular and integer form
     Assert( 2, POL_UpperTriangIntTest( gens_mod ) );

     # convert the conjugated group to a pcp-group
     pcp := SubgroupUnitriangularPcpGroup( gens_mod );

     return rec( pcp := pcp,conjugator := conjugator,gens_mod := gens_mod );
end;

#############################################################################
##
#F POL_FirstCloseUnderConjugation( gens,gens_U_p )
##
## extends the matrices in gens_U_p to gens_U_p2 in such a way that
## the conjugator belonging to gens_U_p2 can be used also for the
## matrices of the form  gens_U_p2[i]^gens[j]
##
POL_FirstCloseUnderConjugation := function( gens,gens_U_p )
    local conjugator,found,g,h,matrix,newGens,rec1;
    conjugator := POL_DetermineRealConjugator( gens_U_p );
    if conjugator = fail then return fail; fi;
    newGens := [];
    for g in gens_U_p do
        for h in gens do
            matrix := g^h;
            if not POL_UpperTriangIntTest( [matrix^conjugator] ) then
                # we have to extend our gens_U_p
                newGens := Concatenation( gens_U_p,[matrix] );
                Info( InfoPolenta, 3,
                      "Extending in FirstCloseUnderConjugation\n",
                      "newGens are",newGens,"\n" );
                rec1 := POL_FirstCloseUnderConjugation( gens,newGens );
                return rec1;
            fi;
        od;
    od;
    # if the conjugator is good for all conjugates we can proceed
    return rec( gens := gens,gens_U_p := gens_U_p,conjugator := conjugator );
end;


#############################################################################
##
#M POL_UnitriangularPcpGroup( n, p ) . . .. . . . for p = 0 we take UT( n, Z )
##
POL_UnitriangularPcpGroup :=  function( n, p )
    local l, c, g, r, i, j, h, f, k, v, o, G;

    if not IsInt(n) or n <= 1 then return fail; fi;
    if not (IsPrimeInt(p) or p=0) then return fail; fi;

    l := n*(n-1)/2;
    c := FromTheLeftCollector( l );

    # compute matrix generators
    g := [];
    for i in [1..n-1] do
        for j in [1..n-i] do
            r := IdentityMat( n );
            r[j][i+j] := 1;
            Add( g, r );
        od;
    od;

    # mod out p if necessary
    if p > 0 then g := List( g, x -> x * One( GF(p) ) ); fi;

    # get inverses
    h := List( g, x -> x^-1 );

    # read of pc presentation
    for i in [1..l] do

          # commutators
        for j in [1..i-1] do
            #v := Comm( g[j], g[i] );
            v := Comm( g[i], g[j] );
            if v <> v^0 then
                if v in g then
                    k := Position( g, v );
                    o := [k, 1];
                elif v in h then
                    k := Position( h, v );
                    o := [k, -1];
                else
                    Error("commutator out of range");
                fi;
                SetCommutator( c, i, j, o );
            fi;
        od;

        # powers
        if p > 0 then
            SetRelativeOrder( c, i, p );
            v := g[i]^p;
            if v <> v^0 then Error("power out of range"); fi;
        fi;
    od;
    UpdatePolycyclicCollector( c );

    # translate from collector to group
    G := PcpGroupByCollectorNC( c );
    G!.mats := g;
    G!.isomorphism := GroupHomomorphismByImagesNC( G, Group(g), Igs(G), g);
    return G;
end;


#############################################################################
##
#F POL_SubgroupUnitriangularPcpGroup_Mod(  mats  )
##
## just the returned value is changed in comparaison with original
## function
##
POL_SubgroupUnitriangularPcpGroup_Mod  :=  function(  mats  )
    local rec1,n, p, G, g, i, j, r, h, m, e, v, c;

    # get the dimension, the char and the full unitriangular group
    n  :=  Length(  mats[1]  );
    p  :=  Characteristic(  mats[1][1][1]  );
    G  :=  POL_UnitriangularPcpGroup(  n, p  );

    # compute corresponding generators
    g  :=  [];
    for i in [1..n-1] do
        for j in [1..n-i] do
            r  :=  IdentityMat(  n  );
            r[j][i+j]  :=  1;
            Add(  g, r  );
        od;
    od;

    # get exponents for each matrix
    h  :=  [];
    for m in mats do
        e  :=  [];
        c  :=  0;
        for i in [1..n-1] do
            v  :=  List(  [1..n-i], x -> m[x][x+i]  );
            r  :=  MappedVector(  v, g{[c+1..c+n-i]}  );
            m  :=  r^-1 * m;
            c  :=  c + n-i;
            Append(  e, v  );
        od;
        Add(  h, MappedVector(  e, Pcp( G )  )  );
    od;
    # Print( " h = ",h,"\n" );
    return rec( pcp := Subgroup(  G, h  ),UT := G );
end;

#############################################################################
##
#F POL_MapToUnipotentPcp( matrix,pcp_record )
##
##
POL_MapToUnipotentPcp := function( matrix,pcp_record )
    local n,p,m,i,j,r,g,e,c,v;
    # get the dimension, and the full unitriangular group
    n  :=  Length(  matrix  );
    p  :=  0;
    m :=  matrix;

    # compute corresponding generators
    g  :=  [];
    for i in [1..n-1] do
        for j in [1..n-i] do
            r  :=  IdentityMat(  n  );
            r[j][i+j]  :=  1;
            Add(  g, r  );
        od;
    od;

    # get exponent
        e  :=  [];
        c  :=  0;
        for i in [1..n-1] do
            v  :=  List(  [1..n-i], x -> m[x][x+i]  );
            r  :=  MappedVector(  v, g{[c+1..c+n-i]}  );
            m  :=  r^-1 * m;
            c  :=  c + n-i;
            Append(  e, v  );
        od;
    return  MappedVector( e,Pcp( pcp_record.UT ) ) ;
end;


#############################################################################
##
#F CPCS_Unipotent( gens_U_p )
##
## calculates a constructive pc-sequence for
## the unipotent group <gens_U_p>
##
CPCS_Unipotent := function( gens_U_p )
    local g,rec1,mats,A,dim,gens_U_p_mod,mat,mat3,h,
          mat2,pcpElement,conjugator,G,gensOfG,
          pcp_rec,rels,pcs,newGens,i;
    dim := Length( gens_U_p[1] );

    #check for trivial elements
    gens_U_p_mod := [];
    for i in [1..Length( gens_U_p )] do
        if not gens_U_p[i]=gens_U_p[i]^0 then
            Add( gens_U_p_mod,gens_U_p[i] );
        fi;
    od;

    # exclude the trivial case
    if gens_U_p_mod=[] then
        return rec( rels := [],pcs := [] );
    fi;

    # find a conjugator
    conjugator := POL_DetermineRealConjugator( gens_U_p_mod );
    if conjugator = fail then return fail; fi;
    #calculate a pcp for <gens_U_p_mod>^conjugator
    G := Group( gens_U_p_mod );
    G := G^conjugator;
    gensOfG := GeneratorsOfGroup( G );

    # assert that <gensOfG> is in upper triangular and integer form
    Assert( 2, POL_UpperTriangIntTest( gensOfG ) );

    # convert the conjugated group to a Pcp-group
    Info( InfoPolenta, 3, "calculate the pcp-Group of the group\n",
                           gensOfG,"\n" );
    pcp_rec := POL_SubgroupUnitriangularPcpGroup_Mod( gensOfG );

    # calculate a pc-sequence for <gens_U_p>
    pcs := [];
    A := POL_UnitriangularPcpGroup( dim,0 );
    mats := A!.mats;
    for g in GeneratorsOfPcp( Pcp( pcp_rec.pcp ) ) do
        #calculate preimage, i.e. convert it to a mat and conjugate it
        mat := MappedVector( Exponents( g ), mats );
        mat := mat^( conjugator^-1 );
        Add( pcs,mat );
    od;

    # save the relative orders
    rels := Pcp( pcp_rec.pcp )!.rels;

    return rec( pcp_record := pcp_rec,
                conjugator := conjugator,
                pcs := pcs,rels := rels );
end;

#############################################################################
##
#F CPCS_Unipotent_Conjugation_Version2( gens, gens_U_p )
##
## calculate a constructive pc-sequence for
## the unipotent group <gens_U_p>^<gens>
##
CPCS_Unipotent_Conjugation_Version2 := function( gens, gens_U_p )
    local g,rec1,mats,A,dim,gens_U_p_mod,mat,mat3,h,
          mat2,pcpElement,conjugator,G,gensOfG,
          pcp_rec,rels,pcs,newGens,i, gens2;
    dim := Length( gens[1] );

    #check for trivial elements
    gens_U_p_mod := [];
    for i in [1..Length( gens_U_p )] do
        if not gens_U_p[i]=gens_U_p[i]^0 then
            Add( gens_U_p_mod,gens_U_p[i] );
        fi;
    od;

    # exclude the trivial case
    if gens_U_p_mod=[] then
        return rec( rels := [], pcs := [] );
    fi;

    # find a good conjugator even for conjugated elements of gens_U_p
    rec1 := POL_FirstCloseUnderConjugation( gens, gens_U_p_mod );
    if rec1 = fail then return fail; fi;
    gens_U_p_mod := rec1.gens_U_p;
    conjugator := rec1.conjugator;

    #calculate a pcp for <gens_U_p_mod>^conjugator;
    G := Group( gens_U_p_mod );
    G := G^conjugator;
    gensOfG := GeneratorsOfGroup( G );

    # assert that <gensOfG> is in upper triangular and integer form
    Assert( 2, POL_UpperTriangIntTest( gensOfG ) );

    # convert the conjugated group to a Pcp-group
    Info( InfoPolenta, 3, "Unipotent: calculate the pcp-Group of the group\n",
                           gensOfG,"\n" );
    pcp_rec := POL_SubgroupUnitriangularPcpGroup_Mod( gensOfG );

    # check if the preimages of the gens of the pcp are
    # stable under conjugation
    A := POL_UnitriangularPcpGroup( dim,0 );
    mats := A!.mats;
    for g in GeneratorsOfGroup( pcp_rec.pcp ) do
        # calculate the preimage, i.e. convert it to a matrix and conjugate
        mat := MappedVector( Exponents( g ),mats );
        mat := mat^( conjugator^-1 );
        gens2 := Concatenation( gens, List( gens, x-> x^-1 ));
        for h in gens2 do
            mat2 := mat^h;
            mat3 := mat2^conjugator;
            if not POL_MapToUnipotentPcp( mat3,pcp_rec ) in pcp_rec.pcp then
                #extend gens_U_p
                Info( InfoPolenta,3, "Extending gens_U_p \n" );
                # newGens := Concatenation( gens_U_p,[mat2] );
                newGens := Concatenation( gens_U_p_mod,[mat2] );
                return CPCS_Unipotent_Conjugation_Version2( gens,newGens );
            fi;
        od;
    od;

    # calculate a pc-sequence for <gens_U_p>
    pcs := [];
    for g in GeneratorsOfPcp( Pcp( pcp_rec.pcp ) ) do
        #calculate preimage, i.e. convert it to a mat and conjugate it
        mat := MappedVector( Exponents( g ),mats );
        mat := mat^( conjugator^-1 );
        Add( pcs,mat );
    od;

    # save the relative orders
    rels := Pcp( pcp_rec.pcp )!.rels;

    return rec( pcp_record := pcp_rec,
                conjugator := conjugator,
                pcs := pcs,rels := rels );
end;

#############################################################################
##
#F CPCS_Unipotent_Conjugation( gens, gens_U_p )
##
## calculates a constructive pc-sequence for
## the unipotent group <gens_U_p>^<gens>
##
CPCS_Unipotent_Conjugation := function( gens, gens_U_p )
    local dim, gens_U_p_mod,rec1,conjugator,U,gensOfU, gensWithInverses,
          level, mat, h, mat2, mat3,P, rels, newGens,i,testMembership,
          pcs, gensWithInversesConj, pcs_U_p;

    dim := Length( gens[1] );

    # clear generators list from trivial elements
    gens_U_p_mod := [];
    for i in [1..Length( gens_U_p )] do
        if not gens_U_p[i]=gens_U_p[i]^0 then
            Add( gens_U_p_mod,gens_U_p[i] );
        fi;
    od;

    # exclude the trivial case
    if gens_U_p_mod=[] then
        return rec( rels := [], pcs := [] );
    fi;

    # find a good conjugator even for conjugated elements of gens_U_p
    rec1 := POL_FirstCloseUnderConjugation( gens, gens_U_p_mod );
    if rec1 = fail then return fail; fi;
    gens_U_p_mod := rec1.gens_U_p;
    conjugator := rec1.conjugator;

    #calculate a pcp for <gens_U_p_mod>^conjugator;
    U := Group( gens_U_p_mod );
    U := U^conjugator;
    gensOfU := GeneratorsOfGroup( U );

    # assert that <gensOfU> is in upper triangular and integer form
    Assert( 2, POL_UpperTriangIntTest( gensOfU ) );

    # compute a  polycyclic sequence for U
    Info( InfoPolenta, 3, "calculate levels ",
                          " of the group...\n",
                           gensOfU,"\n" );
    level := SiftUpperUnitriMatGroup( U );
    Info( InfoPolenta, 3, "... finished\n" );

    # check if <gens_U_p> is stable under conjugation
      Info( InfoPolenta, 3,
            "check if <gens_U_p> is stable under conjugation...");
      gensWithInverses := Concatenation( gens, List( gens, x-> x^-1 ));
      gensWithInversesConj := List( gensWithInverses, x-> x^conjugator );
      P :=  PolycyclicGenerators( level );
      # maybe incomplete pcs of U^conjugator
      pcs_U_p := P.matrices;
      for mat in pcs_U_p do
      #for mat in gens_U_p do
          for h in gensWithInversesConj do
              mat2 := mat^h;
              Info( InfoPolenta, 3, "test membership ..." );
              testMembership :=  DecomposeUpperUnitriMat( level, mat2 );
              Info( InfoPolenta, 3, "... finished" );
              if IsBool( testMembership ) then
                 #extend gens_U_p
                 Info(InfoPolenta,3,"Extending generator list of unipotent subgroup\n" );
                 #newGens := Concatenation( gens_U_p,[mat2] );
                 newGens := Concatenation( pcs_U_p,[mat2] );
                 newGens := List( newGens, x-> x^( conjugator^-1 ) );
                 Info( InfoPolenta, 2,
                 "An extended list of the normal subgroup generators for the\n",
                 "    unipotent subgroup is" );
                 Info( InfoPolenta, 2, newGens );
                 return CPCS_Unipotent_Conjugation( gens,newGens );
              fi;
           od;
      od;
      Info( InfoPolenta, 3, "...finished" );

    # assemble necessary data for a constructive pcs of <gens_U_p>
    #P :=  PolycyclicGenerators( level );
    rels := List(  [1..Length(P.gens)], x->0 );
    pcs := List( pcs_U_p, x-> x^( conjugator^-1 ) );

    #U := Group( P.matrices );
    #U := U^( conjugator^-1 );

    return rec( level := level,
                pcs := pcs,
                gens := P.gens,
                conjugator := conjugator,
                rels := rels );
end;

#############################################################################
##
#F ExponentOfCPCS_Unipotent( matrix, conPcs )
##
##
ExponentOfCPCS_Unipotent := function( matrix, conPcs )
    local matrix2,exp,n,counter,i,e,decomp;
    # exclude trivial case
    if conPcs.rels=[] then
       return [];
    fi;
    matrix2 := matrix^conPcs.conjugator;
    if not POL_UpperTriangIntTest( [matrix2] ) then
        return fail;
    fi;
    decomp := DecomposeUpperUnitriMat( conPcs.level, matrix2 );
    if IsBool( decomp ) then return fail; fi;
    n := Length( conPcs.gens );
    exp := [];
    counter := 1;
    for i in [1..n] do
        if IsBound( decomp[counter] ) then
            e := decomp[counter];
            if conPcs.gens[i] = e[1] then
                Add( exp, e[2] );
                counter := counter + 1;
            else
                Add( exp, 0 );
            fi;
        else
            Add( exp, 0 );
        fi;
    od;
    Assert( 1,  matrix = Exp2Groupelement( conPcs.pcs, exp ),
            "Failure in ExponentOfCPCS_Unipotent \n"  );
    return exp;
end;

#############################################################################
##
## Test functions

#############################################################################
##
#F POL_TestCPCS_Unipotent( gens )
##
##
POL_TestCPCS_Unipotent :=
                     function( gens )
     local con, i, g, exp;

     con := CPCS_Unipotent( gens );
     Print( "START TESTING !!!\n" );
     SetAssertionLevel( 1 );
     for i in [1..10] do
         g := POL_RandomGroupElement( gens );
         Print( g );
         exp := ExponentOfCPCS_Unipotent( g, con );
         Print( i );
     od;
     # SetAssertionLevel( 0 );
end;

#############################################################################
##
#F POL_TestCPCS_Unipotent2( dim, numberGens_U_p )
##
##
POL_TestCPCS_Unipotent2 :=
                     function( dim, numberGens_U_p )
     local g2,exp,G,k,i,j,d,mats,h2,g,matrix,U,U2,h,v,gens2,gens_U_p,
           gens,con, numberOfTests;

     g := [];
     matrix := [];
     d  :=  dim;
     k := numberGens_U_p;
     numberOfTests := 10;

     # construct some unipotent rational matrix groups
     G := POL_UnitriangularPcpGroup( dim,0 );
     mats := G!.mats;
     for i in [1..k] do
         g[i] := Random( G );
     od;
     for i in [1..k] do
         matrix[i] := MappedVector( Exponents( g[i] ),mats );
     od;
     Print( "matrix ist gleich ",matrix,"\n" );
     U := Group( matrix );

     # we need a random element of GL( n,Q )
     h := RandomInvertibleMat( dim,Rationals );
     Print( "h ist gleich ",h,"\n" );
     U2 := U^h;
     gens_U_p := GeneratorsOfGroup( U2 );
     # gens_U_p := GeneratorsOfGroup( U );
     Print( "gens_U_p ist gleich ", gens_U_p,"\n" );
     con := CPCS_Unipotent( gens_U_p );
     Print( "START TESTING !!!\n" );
     SetAssertionLevel( 1 );
     for i in [1..numberOfTests] do
         g := POL_RandomGroupElement( gens_U_p );
         Print( g );
         exp := ExponentOfCPCS_Unipotent( g,con );
         Print( i );
     od;
     # SetAssertionLevel( 0 );
end;

#############################################################################
##
#F POL_TestFlag(  flag,gens  )
##
POL_TestFlag  :=  function(  flag,gens  )
   local i,V,v,g, test;
   test  :=  true;
   for i in [1..(  Length(  flag  )  )] do
       V  :=  VectorSpace(  Rationals,flag{[1..i]}  );
       for g in gens do
           v  :=  flag[i]*g;
           #Print(  "flag[i] ist gleich ",flag[i],"\n"  );
           #Print(  "v ist gleich ",v,"\n"  );
           if not v in V then
              Print(  "Flag Fehler enthalten gleich  ",v in V,"\n"  );
              Print(  "flag[",i,"] ist gleich ",flag[i],"\n"  );
              Print(  "v ist gleich ",v,"\n\n"  );
              test  :=  false;
           fi;
       od;
   od;
   return test;
end;

#############################################################################
##
##
#F POL_Test_UnipotentMats2Pcp( dim, k )
##
POL_Test_UnipotentMats2Pcp := function( dim, k )
    local G,i,j,d,mats,g,matrices,U,U2,h,v,gens2,gens3;
    SetAssertionLevel( 2 );
    g := [];
    matrices := [];
    d  :=  dim;
    # construct some unipotent rational matrix groups
    G := POL_UnitriangularPcpGroup( dim,0 );
    mats := G!.mats;
    for i in [1..k] do
        g[i] := Random( G );
    od;
    for i in [1..k] do
        matrices[i] := MappedVector( Exponents( g[i] ),mats );;
    od;
    Print( "used matrices are ",matrices,"\n" );
    U := Group( matrices );

    # random element of GL( n,Q )
    h := RandomInvertibleMat( dim,Rationals );
    Print( "h is ",h,"\n" );
    U2 := U^h;
    gens2 := GeneratorsOfGroup( U2 );
    gens3 := POL_UnipotentMats2Pcp( gens2 );
    if gens3 = fail then return fail; fi;
    SetAssertionLevel( 0 );
    return gens3;
end;

#############################################################################
##
#E
