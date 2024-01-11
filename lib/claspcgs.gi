#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Heiko Theißen.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains functions that  deal with conjugacy topics in solvable
##  groups using affine  methods.   These  topics includes   calculating  the
##  (rational)   conjugacy classes and centralizers   in solvable groups. The
##  functions   rely only on   the existence of pcgs,  not  on the particular
##  representation of the groups.
##

#############################################################################
##
#F  SubspaceVectorSpaceGroup( <N>, <p>, <gens>, <howmuch> )
##
##  This function creates a record  containing information about a complement
##  in <N> to the span of <gens>.
##
InstallGlobalFunction( SubspaceVectorSpaceGroup, function( N, p, gens,howmuch )
local   zero,  one,  r,  ran,  n,  nan,  cg,  pos,  Q,  i,  j,  v;

    one:=One( GF( p ) );  zero:=0 * one;
    r:=Length( N );       ran:=[ 1 .. r ];
    n:=Length( gens );    nan:=[ 1 .. n ];
    Q:=[  ];
    if n <> 0  and  IsMultiplicativeElementWithInverse( gens[ 1 ] )  then
        Q:=List( gens, gen -> ExponentsOfPcElement( N, gen ) ) * one;
    else
        Q:=ShallowCopy( gens );
    fi;

    cg:=rec( matrix        :=[  ],
               one           :=one,
               baseComplement:=ShallowCopy( ran ),
               commutator    :=0,
               centralizer   :=0,
               dimensionN    :=r,
               dimensionC    :=n );

    if n = 0  or  r = 0  then
        cg.inverse:=NullMapMatrix;
        cg.projection    :=IdentityMat( r, one );
        cg.needed    :=[];
        return cg;
    fi;

    for i  in nan  do
        cg.matrix[ i ]:=Concatenation( Q[ i ], zero * nan );
        cg.matrix[ i ][ r + i ]:=one;
    od;
    TriangulizeMat( cg.matrix );
    pos:=1;
    for v  in cg.matrix  do
        while v[ pos ] = zero  do
            pos:=pos + 1;
        od;
        RemoveSet( cg.baseComplement, pos );
        if pos <= r  then  cg.commutator :=cg.commutator  + 1;
                     else  cg.centralizer:=cg.centralizer + 1;  fi;
    od;

    if howmuch=1 then
      return Immutable(cg);
    fi;

    cg.needed        :=[  ];
    cg.projection    :=IdentityMat( r, one );

    # Find a right pseudo inverse for <Q>.
    Append( Q, cg.projection );
    Q:=MutableTransposedMat( Q );
    TriangulizeMat( Q );
    Q:=TransposedMat( Q );
    i:=1;
    j:=1;
    while i <= Length( N )  do
        while j <= Length( gens ) and Q[ j ][ i ] = zero  do
            j:=j + 1;
        od;
        if j <= Length( gens ) and Q[ j ][ i ] <> zero  then
            cg.needed[ i ]:=j;
        else

            # If <Q> does  not  have full rank, terminate when the bottom row
            # is reached.
            i:=Length( N );

        fi;
        i:=i + 1;
    od;

    if IsEmpty( cg.needed )  then
        cg.inverse:=NullMapMatrix;
    else
        cg.inverse:=Q{ Length( gens ) + ran }
                       { [ 1 .. Length( cg.needed ) ] };
        cg.inverse:=ImmutableMatrix(p,cg.inverse,true);
    fi;
    if IsEmpty( cg.baseComplement )  then
        cg.projection:=NullMapMatrix;
    else

        # Find a base change matrix for the projection onto the complement.
        for i  in [ 1 .. cg.commutator ]  do
            cg.projection[ i ][ i ]:=zero;
        od;
        Q:=[  ];
        for i  in [ 1 .. cg.commutator ]  do
            Q[ i ]:=cg.matrix[ i ]{ ran };
        od;
        for i  in [ cg.commutator + 1 .. r ]  do
            Q[ i ]:=ListWithIdenticalEntries( r, zero );
            Q[ i ][ cg.baseComplement[ i-r+Length(cg.baseComplement) ] ]
             :=one;
        od;
        cg.projection:=cg.projection ^ Q;
        cg.projection:=cg.projection{ ran }{ cg.baseComplement };
        cg.projection:=ImmutableMatrix(p,cg.projection,true);

    fi;

    return Immutable(cg);
end );

#############################################################################
##
#F  KernelHcommaC( <N>, <h>, <C>, <howmuch> )
##
##  Given a homomorphism C -> N, c |-> [h,c],  this function determines (a) a
##  vector space decomposition N =  [h,C] + K with  projection onto K and (b)
##  the  ``kernel'' S <  C which plays   the role of  C_G(h)  in lemma 3.1 of
##  [Mecky, Neub\"user, Bull. Aust. Math. Soc. 40].
##
InstallGlobalFunction( KernelHcommaC, function( N, h, C, howmuch )
local   i,  tmp,  v,x;

    x:=List( C, c -> Comm( h, c ) );

    N!.subspace:=SubspaceVectorSpaceGroup(N,RelativeOrders(N)[1],x,howmuch);
    tmp:=[  ];
    for i  in [ N!.subspace.commutator + 1 ..
                N!.subspace.commutator + N!.subspace.centralizer ]  do
        v:=N!.subspace.matrix[ i ];
        tmp[ i - N!.subspace.commutator ]:=PcElementByExponentsNC( C,
                 v{ [ N!.subspace.dimensionN + 1 ..
                      N!.subspace.dimensionN + N!.subspace.dimensionC ] } );
    od;
    return tmp;
end );

#############################################################################
##
#F  CentralStepClEANS( <homepcgs>,<H>, <U>, <N>, <cl>,<off> )
##
# if <off> is true the normal subgroup is not necessarily in the series and
# we cannot call `ExtendedPcgs' but must form a new pcgs.
InstallGlobalFunction( CentralStepClEANS, function( home,H, U, N, cl,off )
local   classes,    # classes to be constructed, the result
        field,      # field over which <N> is a vector space
        h,          # preimage `cl.representative' under <hom>
        gens,   # preimage `Centralizer( cl )' under <hom>
        cemodk,
        cengen,
        exp,  w,    # coefficient vectors for projection along $[h,N]$
        kern,img,
        c,nc;          # loop variable

    field:=GF( RelativeOrders( N )[ 1 ] );
    h:=cl.representative;
    if IsBound(cl.centralizerpcgs) then
      if IsSubset(cl.centralizerpcgs,DenominatorOfModuloPcgs(N!.capH)) then
        cemodk:=Filtered(cl.centralizerpcgs,i->not i in
        DenominatorOfModuloPcgs(N!.capH));
      else
        cemodk:=cl.centralizerpcgs mod
                    DenominatorOfModuloPcgs( N!.capH );
      fi;
    else
      cemodk:=InducedPcgs(home, cl.centralizer ) mod
                  DenominatorOfModuloPcgs( N!.capH );
    fi;

    kern:=DenominatorOfModuloPcgs( N!.capH );
    if IsBound(cl.candidates) then
      img:=KernelHcommaC( N, h, cemodk,2 );
    else
      img:=KernelHcommaC( N, h, cemodk,1 );
    fi;

    if off then
      cengen:=InducedPcgsByPcSequenceAndGenerators(ParentPcgs( kern ),
                    kern, img );
    else
      #cengen:=ExtendedPcgs(kern,img);
      cengen:=Concatenation(img,kern);
    fi;

    #C:=SubgroupByPcgs( H, cengen );

    classes:=[  ];
    if IsBound( cl.candidates )  then
        gens:=cemodk{ N!.subspace.needed };
        if IsIdenticalObj( FamilyObj( U ), FamilyObj( cl.candidates ) )  then
            for c  in cl.candidates  do
                exp:=ExponentsOfPcElement( N, LeftQuotient( h, c ) );
                MultVector( exp, One( field ) );
                w:=exp * N!.subspace.projection;
                exp{ N!.subspace.baseComplement }:=
                  exp{ N!.subspace.baseComplement }-w;
                nc:=rec( representative:=h * PcElementByExponentsNC
                             ( N, N!.subspace.baseComplement, w ),
                          #centralizer:=C,
                          #centralizerpcgs:=cengen,
                          cengen:=cengen,
                          operator:=LinearCombinationPcgs( gens,
                                  exp * N!.subspace.inverse,
                                  One( cl.candidates[1] ))^(-1));

                # check that action is really OK
                Assert(1,c^nc.operator/nc.representative in
                  Group(DenominatorOfModuloPcgs(N),One(U)));

                Add( classes, nc );
            od;
        else
            c:=rec( representative:=cl.candidates,
                         #centralizer:=C,
                         #centralizerpcgs:=cengen,
                         cengen:=cengen,
                            operator:=One( H ) );
            Add( classes, c );
        fi;

    else
        gens:=N!.subspace.baseComplement;
        for w  in field ^ Length( gens )  do
            c:=rec( representative:=h * PcElementByExponentsNC( N,gens,w ),
                         #centralizer:=C )
                         #centralizerpcgs:=cengen )
                         cengen:=cengen );
            Add( classes, c );
        od;
    fi;
    return classes;
end );

#############################################################################
##
#F  CorrectConjugacyClass(<home>,<h>,<n>,<stabpcgs>,<N>,<depth>,<cNh>,<off> )
##    cf. MN89
##
InstallGlobalFunction( CorrectConjugacyClass,
function( home, h, n, stab, N,depthlev, cNh,off )
local   cl,  comm,  s;

  #AH: take only those elements module N - the part in N is cNh
  stab:=Filtered(stab,i->DepthOfPcElement(home,i)<depthlev);

  if Length(N!.subspace.inverse)>0 and Length(stab)>0 then

    comm:=[];
    for s  in [ 1 .. Length( stab ) ]  do
        comm[ s ]:=ExponentsOfPcElement( N,
                      Comm( n, stab[ s ] )*Comm( h, stab[ s ] ));
    od;
    comm:=comm * N!.subspace.inverse;
    for s  in [ 1 .. Length( comm ) ]  do
        stab[ s ]:=stab[ s ] / PcElementByExponentsNC
          ( N!.capH, N!.subspace.needed, comm[ s ] );
    od;
  fi;

  if off then
    stab:=InducedPcgsByPcSequenceAndGenerators(ParentPcgs( cNh ),
                  cNh, stab );
  elif IsList(cNh) and IsList(cNh[1]) then
    #stab:=ExtendedPcgs(cNh[1],Concatenation(stab,cNh[2]));
    stab:=Concatenation(stab,cNh[2],cNh[1]);
  else
    #stab:=ExtendedPcgs(cNh,stab);
    stab:=Concatenation(stab,cNh);
  fi;

  cl:=rec( representative:=h * n,
                cengen:=stab );
  return cl;

end );

#############################################################################
##
#F  GeneralStepClEANS( <homepcgs>, <H>, <U>, <N>,<nexpo>, <cl>,<off> )
##
# if <off> is true the normal subgroup is not necessarily in the series and
# we cannot call `ExtendedPcgs' but must form a new pcgs.
InstallGlobalFunction(GeneralStepClEANS,function(home, H, U, N,nexpo, cl, off)
local  classes,    # classes to be constructed, the result
        field,      # field over which <N> is a vector space
        h,          # preimage `cl.representative' under <hom>
        cNh,        # centralizer of <h> in <N>
        gens,       # preimage `Centralizer( cl )' under <hom>
        r,          # dimension of <N>
        ran,        # constant range `[ 1 .. r ]'
        aff,        # <N> as affine space
        xset,       # affine operation of <C> on <aff>
        imgs,  M,   # generating matrices for affine operation
        orb,        # orbit of affine operation
        Rep,        # representative function to use for <orb>
        n,  k,      # cf. Mecky--Neub\"user paper
        cls,rep,pos,# set of classes with canonical representatives
        j,
        c,  ca,  i, # loop variables
        S,          # orbit-stabilizer
        ceve,       # exponent vector
        p,          # positions
        Cgens,      # generators of C in N
        next,blist, # orbit stabilizer algo
        depthlev,   # depth at which N starts
        one,zero,
        vec,
    dict,
        kern,img;

    depthlev:=DepthOfPcElement(home,N[1]);
    Cgens:=cl.centralizerpcgs;
    field:=GF( RelativeOrders( N )[ 1 ] );
    h:=cl.representative;

    # Determine the subspace $[h,N]$ and calculate the centralizer of <h>.
    kern:=DenominatorOfModuloPcgs( N!.capH );
    img:=KernelHcommaC( N, h, N!.capH,2 );
    r:=Length( N!.subspace.baseComplement );

    #AH: Take only those which are not in N
    gens:=Cgens mod NumeratorOfModuloPcgs(N!.capH);

    if not (off or IsBound(cl.candidates)) and r=0 then
      # special treatment: The commutators span the whole space
      # this is noncentral_case4 in GAP3
      c:=CorrectConjugacyClass( home, h, One(gens[1]),
                    gens, N, depthlev,[kern,img],off );

      return [c];

    fi;

    ran:=[ 1 .. r ];

    if off then
      cNh:=InducedPcgsByPcSequenceAndGenerators(ParentPcgs( kern ),
                    kern, img );
    else
      #cNh:=ExtendedPcgs(kern,img);
      cNh:=[kern,img]; # we only need cNh to extend it
    fi;

    # Construct matrices for the affine operation on $N/[h,N]$.
    aff:=ExtendedVectors( field ^ r );

    one:=One(field);
    zero:=Zero(field);
    imgs:=[  ];
    for c  in gens  do
        ceve:=ExponentsOfPcElement(home,c,[1..depthlev-1]);

        M:=[  ];
        for i  in [ 1 .. r ]  do
          p:=N!.subspace.baseComplement[i];

            # construct the vector image

            vec:=p;
            for j in [1..Length(ceve)] do
              for k in [1..ceve[j]] do
                if IsInt(vec) then
                  vec:=nexpo[j][vec];
                else
                  vec:=vec*nexpo[j];
                fi;
              od;
            od;

            M[ i ]:=Concatenation( vec
                  * N!.subspace.projection, [ zero ] );
          od;
          i:=Comm( h, c );
          M[ r + 1 ]:=Concatenation( ExponentsOfPcElement
                                ( N, i ) * N!.subspace.projection,
                                [ one ] );

        M:=ImmutableMatrix(field,M,true);
        Add( imgs, M );
    od;

    classes:=[  ];
    if IsBound( cl.candidates )  then
        # not yet improved: we use an external set and thus have to give a
        # full list of generators of C:
        imgs:=Concatenation(imgs,List([1..Length(Cgens)-Length(gens)],i->IdentityMat( r + 1, field )));
        gens:=Cgens;

        xset:=ExternalSet(SubgroupByPcgs(H,Cgens),aff,gens,imgs,OnPoints);

        if IsIdenticalObj( FamilyObj( U ), FamilyObj( cl.candidates ) )  then
            Rep:=CanonicalRepresentativeOfExternalSet;
        else
            cl.candidates:=[ cl.candidates ];
            Rep:=Representative;
        fi;
        cls:=[  ];
        for ca  in cl.candidates  do
            n:=ExponentsOfPcElement( N, LeftQuotient( h, ca ) ) *
                 One( field );
            n:=ImmutableVector( field, n );
            k:=n * N!.subspace.projection;
            orb:=Concatenation( k, [ One( field ) ]);
            orb:=ImmutableVector( field, orb );
            orb:=ExternalOrbit( xset, orb );
            rep:=PcElementByExponentsNC( N, N!.subspace.baseComplement,
                      Rep( orb ){ ran } );
            pos:=Position( cls, rep );
            if pos = fail  then
                Add( cls, rep );
                c:=StabilizerOfExternalSet( orb );
                if IsIdenticalObj( Rep, CanonicalRepresentativeOfExternalSet )
                   then
                    c:=ConjugateSubgroup( c, ActorOfExternalSet( orb ) );
                fi;
                c:=CorrectConjugacyClass( home, h, rep, InducedPcgs(home,c), N,
                depthlev,cNh,off );
            else
                c:=rec( representative:=h * rep,
                             #centralizer:=classes[ pos ].centralizer )
                             #centralizerpcgs:=classes[ pos ].centralizerpcgs )
                             cengen:=classes[ pos ].cengen );
            fi;
            n:=ShallowCopy( -n );
            n{ N!.subspace.baseComplement }:=
              k + n{ N!.subspace.baseComplement };
            c.operator:=PcElementByExponentsNC( N, N!.subspace.needed,
                                   n * N!.subspace.inverse );
            # Now (h.n)^c.operator = h.k
            if IsIdenticalObj(Rep,CanonicalRepresentativeOfExternalSet) then
                c.operator:=c.operator * ActorOfExternalSet( orb );
                # Now (h.n)^c.operator = h.rep mod [h,N]
                k:=PcElementByExponentsNC( N, N!.subspace.needed,
                     ExponentsOfPcElement( N, LeftQuotient
                             ( c.representative, ca ^ c.operator ) ) *
                             N!.subspace.inverse );
                c.operator:=c.operator / k;
                # Now (h.n)^c.operator = h.rep
            fi;
            Add( classes, c );
        od;

    else
      #xset:=ExternalSet( C, aff, gens, imgs );
      #k:=ExternalOrbitsStabilizers( xset );

      # do the orbits stuff ourselves

      # keep the dictionary to avoid recreating blist. Also override fixed
      # limit.
      dict:=NewDictionary(aff[1],true,aff:blistlimit:=Size(aff));

      if not IsPositionDictionary(dict) then
        blist:=BlistList([1..Length(aff)],[]);
      else
        blist:=dict!.blist;
      fi;
      next:=1;
      k:=[];
      while next<>fail do
        if IsPositionDictionary(dict) then
          S:=Pcs_OrbitStabilizer(gens,aff,aff[next],imgs,OnRight,dict);
          #S.dictionary!.vals:=[]; #Not really that expensive to keep
        else
          S:=Pcs_OrbitStabilizer(gens,aff,aff[next],imgs,OnRight);
          for i in S.orbit do
            blist[PositionCanonical(aff,i)]:=true;
          od;
        fi;
        Unbind(S.dictionary);
        S.orbit:=S.orbit{[1]}; # save memory

        Add(k,S);

        next:=Position(blist,false,next);
      od;

      for orb  in k  do
          rep:=PcElementByExponentsNC( N, N!.subspace.baseComplement,
                          orb.orbit[1]{ ran } );
          c:=CorrectConjugacyClass( home, h, rep,
                        #orb.stabilizer, N, depthlev,cNh,off )
                        orb.stabpcs, N, depthlev,cNh,off );
          Add( classes, c );
      od;

    fi;
    return classes;
end );

# Test whether <Npcgs> is central in <grpg> modulo depth in <pcgs>.
# This test is faster than membership with `in'. It is used in pc
# class/centralizer computation
InstallGlobalFunction(PcClassFactorCentralityTest,
    function(pcgs,grpg,Npcgs,dep)
          local i,j;
            for i in grpg do
              for j in Npcgs do
                if DepthOfPcElement(pcgs,Comm(j,i))<dep then
                  return false;
                fi;
              od;
            od;
            return true;
          end);

#############################################################################
##
#F  ClassesSolvableGroup(<G>, <mode> [,<opt>])  . . . . .
##
##  In this function  classes  are described by  records  with   components
##  `representative', `centralizer', `galoisGroup' (for rational classes). If
##  <candidates>  are  given,  their   classes  will   have  a  canonical
##  `representative'
##
InstallGlobalFunction(ClassesSolvableGroup, function(arg)
local  G,  home,  # the group and the home pcgs
       H,Hp,    # acting group
       mustlift,
       liftkerns,
       QH,QG,
       fhome,ofhome,
       first,
       mode,    # LSB: ratCl | power | test :MSB
       candidates,  # candidates to be replaced by their canonical reps.
       eas,     # elementary abelian series in <G>
       step,    # counter looping over <eas>
       K,  L,   # members of <eas>
       indstep, # indice normal steps
       Ldep,    # depth of L in pcgs
       Kp,mK,Lp,mL, # induced and modulo pcgs's
       LcapH,KcapH, # intersections
       N,   cent,   # elementary abelian factor, for affine action
       cls, newcls, # classes in range/source of homomorphism
       cli,     # index
       news,    # new classes obtained in step
       cl,      # class looping over <cls>
       opr,     # (candidates[i]^opr[i])^exp[i]=cls[i].representative
       team,    # team of candidates with same image modulo <K>
       blist,pos,q, # these control grouping of <cls> into <team>s
       i,c,   # loop variables
       opt,      # options
       consider, # consider function
       divi,
       inflev,  # InfoLevel flag
       nexpo,   # N-Exponents of the elements of N conjugated
       allcent; # DivisorsInt(Size(G)) (used for Info)


  inflev:=InfoLevel(InfoClasses)>1;
  mode:=arg[2];  # explained below whenever it appears
  if mode mod 2=1 then
    Error("this function does not cater for rational classes any longer");
  fi;
  G:=arg[1];

  if Length(arg)=3 then
    opt:=ShallowCopy(arg[3]);
    # convert series to pcgs
    if IsBound(opt.series) and not IsBound(opt.pcgs) then
    fi;
  else
    opt:=rec();
  fi;

  # <candidates> is a list  of elements whose classes  will be output  (but
  # with canonical representatives), see comment  above. Or <candidates> is
  # just one element, from whose output class the  centralizer will be read
  # off.
  H:=G;
  if IsBound(opt.candidates) then
    candidates:=opt.candidates;
    if not ForAll(candidates,i->i in G) then
      G:=ClosureGroup(H,candidates);
    fi;
  else
    candidates:=false;
  fi;

  if IsBound(opt.consider) then
    consider:=opt.consider;
  else
    consider:=ReturnTrue;
  fi;

  # Treat the case of a trivial group.
  if IsTrivial(H) then
    if mode=4 then  # test conjugacy of two elements
      return One(G);
    else
      cl:=rec(representative:=One(G),
              centralizer:=H);
    fi;

    if candidates<>false then
      cls:=List(candidates, c -> cl);
    else
      cls:=[cl];
    fi;

    return cls;
  fi;

  # Calculate a (central)  elementary abelian series  with all pcgs induced
  # w.r.t. <homepcgs>.

  if IsBound(opt.pcgs) then
    # we prescribed a series
    home:=opt.pcgs;
    eas:=EANormalSeriesByPcgs(home);

    cent:=false;

  elif IsPGroup(G) then
    home:=PcgsPCentralSeriesPGroup(G);
    eas:=PCentralNormalSeriesByPcgsPGroup(home);

    cent:=ReturnTrue;
  else
    home:=PcgsElementaryAbelianSeries(G);
    eas:=EANormalSeriesByPcgs(home);

    cent:=function(cl, N, L)
      return ForAll(N, k -> ForAll
        #(InducedPcgs(home,cl.centralizer),
        (cl.centralizerpcgs,
#T  was: Only those elements form the induced PCGS. The subset seemed to
#T enforce taking only the elements up, but the ordering of the series used
#T may be different then the ordering in the PCGS. So this will fail. AH
#T one might pick the right ones, but this would be almost the same work.
#T { [1 .. Length(InducedPcgsWrtHomePcgs(cl.centralizer))
#T - Length(InducedPcgsWrtHomePcgs(L))] },
           c -> Comm(k, c) in L));
    end;
    cent:=false;
  fi;

  if cent=false then
    cent:=PcClassFactorCentralityTest;
  fi;
  indstep:=IndicesEANormalSteps(home);

  # is the series large (but can be rectified)?
  step:=IndicesEANormalStepsBounded(home,2^15);
  if indstep<>step then
    indstep:=step;
    eas:=List(indstep,x->SubgroupByPcgs(GroupOfPcgs(home),
      InducedPcgsByPcSequence(home,home{[x..Length(home)]})));
  fi;

  # is the series still large (and merits changing the pcgs)?
  if  Maximum(List([2..Length(eas)],x->IndexNC(eas[x-1],eas[x])))>2^15 then
    if IsBound(G!.claspcgsRefinedSeries) then
      step:=G!.claspcgsRefinedSeries;
    else
      step:=BoundedRefinementEANormalSeries(home,indstep,2^15);
      G!.claspcgsRefinedSeries:=step;
    fi;
    home:=step[1];
    indstep:=step[2];
    eas:=ChiefNormalSeriesByPcgs(home);
  fi;

  # check to which factors we want to lift

  mustlift:=List(eas,ReturnFalse);
  liftkerns:=[];

  if candidates=false then
    # we only want to go in factor groups if no candidates are given
    # (otherwise we'd have to take care not to forget tails when mapping in
    # the factor groups)
    step:=2; # the first step we'd have
    for i in [2..Length(eas)-1] do
      if Index(G,eas[i])>1000 or Index(G,eas[i+1])>10000 then
        # only form a factor if the factor is large enough or the next step
        # would be large

        # form a factor by i and go to this factor at the first time (index
        # step) no factor representation was given
        mustlift[step]:=true;
        liftkerns[step]:=eas[i];
        step:=i+1;
      fi;
    od;
    if step>2 then
      # we created a factor, so we have to lift at the end
      mustlift[step]:=true;
      liftkerns[step]:=eas[Length(eas)];
    fi;
  fi;


  Info(InfoClasses,1,"Series of sizes ",List(eas,Size));

  if mode<3 and inflev then
    divi:=DivisorsInt(Size(G));
    Info(InfoClasses,2,"centsiz: ",divi);
  fi;

  # Initialize the algorithm for the trivial group.
  step:=1;

  L:=eas[step];
  Lp:=InducedPcgs(home,L);

  if not IsIdenticalObj( G, H )  then
    Hp:=InducedPcgs(home, H );
    LcapH:=NormalIntersectionPcgs( home, Hp, Lp );
  fi;

  if  candidates<>false then
    mL:=ModuloPcgsByPcSequenceNC(home, home, Lp);
  fi;

  cl:=rec(representative:=One(G),
          centralizer:=H,
          centralizerpcgs:=InducedPcgs(home,H),
          cengen:=InducedPcgs(home,H));

  if candidates<>false then
    cls:=List(candidates, c -> cl);
    opr:=List(candidates, c -> One(G));
  else
    cls:=[cl];
  fi;

  # Now go back through the factors by all groups in the elementary abelian
  # series.
  first:=true;
  fhome:=home; # just to avoid unboundness the first time
  QG:=G;
  QH:=H;
  for step  in [step + 1 .. Length(eas)]  do

    Info(InfoClasses,1,"Step ",step,", ",Length(cls)," classes to lift");

    # We apply the homomorphism principle to the homomorphism G/L -> G/K.

    if mustlift[step] then
      ofhome:=fhome;
      # get the new quotient and Q's
      if Size(eas[step])=1 then
        QH:=H;
        fhome:=home;
        QG:=G;
      else
        # the new factor group in which we calculate
        QH:=home mod InducedPcgs(home,liftkerns[step]);
        QH:=GROUP_BY_PCGS_FINITE_ORDERS(QH);
        fhome:=FamilyPcgs(QH);
        QG:=SubgroupByPcgs(QG,
              ProjectedInducedPcgs(home,fhome,InducedPcgs(home,G)));
      fi;
    fi;

    # The  actual   computations  are all  done   in <G>,   factors are
    # represented by modulo pcgs.
    Ldep:=indstep[step];

    if IsIdenticalObj(fhome,home) then
      K:=eas[step-1];
      Kp:=InducedPcgs(fhome,K);
      L:=eas[step];
      Lp:=InducedPcgs(fhome,L);
    elif mustlift[step] then
      Kp:=ProjectedInducedPcgs(home,fhome,InducedPcgs(home,eas[step-1]));
      K:=SubgroupByPcgs(QG,Kp);
      Lp:=ProjectedInducedPcgs(home,fhome,InducedPcgs(home,eas[step]));
      L:=SubgroupByPcgs(QG,Lp); # not needed any longer
    else
      # we did not lift
      K:=L;
      Kp:=Lp;
      Lp:=ProjectedInducedPcgs(home,fhome,InducedPcgs(home,eas[step]));
      L:=SubgroupByPcgs(QG,Lp); # not needed any longer
    fi;

    N:=Kp mod Lp;  # modulo pcgs representing the kernel

    if mustlift[step] then
      for i in cls do
        if not IsBound(i.yet) then
          if first then
            # if it is the first time, we must actually map in the factor
            i.representative:=ProjectedPcElement(home,fhome,i.representative);
            i.centralizerpcgs:=ProjectedInducedPcgs(home,fhome,i.cengen);
            i.cengen:=i.centralizerpcgs!.pcSequence;
          else
            i.representative:=LiftedPcElement(fhome,ofhome,i.representative);
            i.centralizerpcgs:=LiftedInducedPcgs(fhome,ofhome,i.cengen,N);
            i.cengen:=i.centralizerpcgs!.pcSequence;
          fi;
          i.yet:=true; # several cl records may be equal. We must map only
                       # once
        fi;
      od;
    else
      for i in cls do
        if IsBound(i.cengen) and not IsBound(i.centralizerpcgs) then
          i.centralizerpcgs:=InducedPcgsByPcSequence(fhome,i.cengen);
          i.cengen:=i.centralizerpcgs!.pcSequence;
        fi;
      od;
    fi;
    first:=false;

#  allcent:=ForAll(N,i->ForAll(GeneratorsOfGroup(G),j->Comm(i,j) in L))
    allcent:=cent(fhome,fhome,N,Ldep);
    if allcent=false then
      nexpo:=LinearOperationLayer(fhome{[1..indstep[step-1]-1]},N);
    fi;

    #T What is this? Obviously it is needed somewhere, but it is
    #T certainly not good programming style. AH
    #SetFilterObj(N, IsPcgs);

    if not IsIdenticalObj(G,H) then
Error("This case disabled -- code not yet corrected");
      KcapH:=LcapH;
      LcapH:=NormalIntersectionPcgs(fhome,Hp,Lp);
      N!.capH:=KcapH mod LcapH;
      SetFilterObj( N!.capH, IsPcgs );
    else
      N!.capH:=N;
    fi;

    # Identification of classes.
    # Rational classes or identification of classes.
    if  candidates<>false then
      mK:=mL;
      mL:=ModuloPcgsByPcSequenceNC(fhome, fhome, Lp);

      if   mode=4  # test conjugacy of two elements
         and not cls[1].representative /
             cls[2].representative in K then
        return fail;
      fi;

      blist:=BlistList([1 .. Length(cls)], []);
      pos:=Position(blist, false);
      while pos<>fail  do

        # Find a team of candidates with same image under <modK>.
        cl:=cls[pos];
        cl.representative:=PcElementByExponentsNC(mK,
          ExponentsOfPcElement(mK, cl.representative));
        cl.candidates:=[];
        team:=[];
        q:=pos;
        while q<>fail  do
          if cls[q].representative /
             cl.representative in K then
            c:=candidates[q] ^ opr[q];
            i:=Position(cl.candidates, c);
            if i=fail then
              Add(cl.candidates, c);
              Add(team, [q]);
            else
              Add(team[i], q);
            fi;
            blist[q]:=true;
          fi;
          q:=Position(blist, false, q);
        od;

        # Now   <cl> is   a  class  modulo  <K>  (possibly   with
        # `<cl>.candidates'  a list of  elements  mapping  into  this
        # class modulo <K>). Let <newcls>  be  a list of all  classes
        # modulo <L> that  map to <cl>  modulo <K>  (resp. a list  of
        # classes to which   the list `<cl>.candidates'   maps modulo
        # <K>,  together  with   `operator's and   `exponent's  as in
        # (c^o^e=r)).
        if allcent then
          # generic central
          Info(InfoClasses,5,"central case 1");
          newcls:=CentralStepClEANS(fhome,QH, QG, N, cl,false);
        elif cent(fhome,cl.centralizerpcgs, N, Ldep) then
          # central in this case
          Info(InfoClasses,5,"central case 2");
          newcls:=CentralStepClEANS(fhome,QH, QG, N, cl,false);
        else
          Info(InfoClasses,5,"general case");
          newcls:=GeneralStepClEANS(fhome, QH, QG, N, nexpo, cl,false);
        fi;

        # Update <cls>, <opr> and <exp>.
        for i  in [1 .. Length(team)]  do
          for q  in team[i]  do
            cls[q]:=newcls[i];
            opr[q]:=opr[q] * newcls[i].operator;
          od;
        od;

        pos:=Position(blist, false, pos);
      od;

    else
      newcls:=[];
      for cli in [1..Length(cls)]  do

        cl:=cls[cli];
        if consider(fhome,cl.representative,cl.centralizerpcgs,K,L)
          then
          if allcent or cent(fhome,cl.centralizerpcgs, N, Ldep) then
            news:=CentralStepClEANS(fhome,QG, QG, N, cl,false);
          else
            news:=GeneralStepClEANS(fhome, QG, QG, N,nexpo,  cl,false);
          fi;
          Assert(1,# only do the test if no factors were formed
           FamilyObj(news[1].cengen)<>FamilyObj(eas[step]) or
           ForAll(news,
                  i->ForAll(i.cengen,
                  j->Comm(i.representative,j) in eas[step])));
          Append(newcls,news);
        fi;

        Unbind(cls[cli]);
      od;
      cls:=newcls;
    fi;

    if inflev then
      c:=Collected(List(cls,i->Size(SubgroupByPcgs(QH,
           InducedPcgsByPcSequence(fhome,i.cengen)))));
      if not IsBound( divi ) then
        divi:=DivisorsInt(Size(G));
      fi;
      c:=Concatenation(c,List(divi,i->[i,0])); # to cope with `First'
      Info(InfoClasses,6,List(divi,i->First(c,j->j[1]=i)[2]));
    fi;

  od;

  if mode=4 then  # test conjugacy of two elements
    if cls[1].representative<>cls[2].representative then
      return fail;
    else
      return opr[1] / opr[2];
    fi;
  fi;

  for i in cls do
    if not IsBound(i.centralizer) then
      if not IsBound(i.centralizerpcgs) then
        i.centralizerpcgs:=InducedPcgsByPcSequence(home,i.cengen);
        i.cengen:=i.centralizerpcgs;
      fi;
      i.centralizer:=SubgroupByPcgs(G,i.centralizerpcgs);
    fi;
  od;

  if candidates<>false then  # add operators (and exponents)
    for i  in [1 .. Length(cls)]  do
      cls[i].operator:=opr[i];
    od;
  fi;
  return cls;
end);

#############################################################################
##
#F  MultiClassIdsPc(<dat>, <candidates>)
##
InstallGlobalFunction(MultiClassIdsPc, function(dat,candidates)
local  G,home,  # the group and the home pcgs
       H,       # acting group
       levdat,leda,
       allcl,
       eas,     # elementary abelian series in <G>
       step,    # counter looping over <eas>
       K,  L,   # members of <eas>
       indstep, # indice normal steps
       Ldep,    # depth of L in pcgs
       Kp,Lp,mL, # induced and modulo pcgs's
       N,   cent,   # elementary abelian factor, for affine action
       cls, newcls, # classes in range/source of homomorphism
       cl,      # class looping over <cls>
       opr,     # (candidates[i]^opr[i])^exp[i]=cls[i].representative
       team,    # team of candidates with same image modulo <K>
       blist,pos,q, # these control grouping of <cls> into <team>s
       i,c,   # loop variables
       nexpo,   # N-Exponents of the elements of N conjugated
       allcent; # DivisorsInt(Size(G)) (used for Info)

  G:=dat.group;

  # <candidates> is a list  of elements whose classes  will be output  (but
  # with canonical representatives), see comment  above. Or <candidates> is
  # just one element, from whose output class the  centralizer will be read
  # off.
  H:=G;

  cls:=ShallowCopy(candidates);

  if IsBound(dat.eas) then
    eas:=dat.eas;
    indstep:=dat.indstep;
    home:=dat.home;
    cent:=dat.cent;
    levdat:=dat.levdat;
    allcl:=dat.allcl;
  else
    # Calculate a (central)  elementary abelian series  with all pcgs induced
    # w.r.t. <homepcgs>.

    if IsPGroup(G) then
      home:=PcgsPCentralSeriesPGroup(G);
      eas:=PCentralNormalSeriesByPcgsPGroup(home);

      cent:=ReturnTrue;
    else
      home:=PcgsElementaryAbelianSeries(G);
      eas:=EANormalSeriesByPcgs(home);

      cent:=PcClassFactorCentralityTest;
    fi;

    indstep:=IndicesEANormalSteps(home);

    # is the series large (but can be rectified)?
    step:=IndicesEANormalStepsBounded(home,2^15);
    if indstep<>step then
      indstep:=step;
      eas:=List(indstep,x->SubgroupByPcgs(GroupOfPcgs(home),
        InducedPcgsByPcSequence(home,home{[x..Length(home)]})));
    fi;

    # is the series still large (and merits changing the pcgs)?
    if  Maximum(List([2..Length(eas)],x->IndexNC(eas[x-1],eas[x])))>2^15 then
      step:=BoundedRefinementEANormalSeries(home,indstep,2^15);
      home:=step[1];
      indstep:=step[2];
      eas:=ChiefNormalSeriesByPcgs(home);
    fi;

    # make steps larger if possible
    L:=[Length(eas)];
    for step in [Length(eas)-1,Length(eas)-2..1] do
      if (Size(eas[step])/Size(eas[L[Length(L)]])>2^15 and not step+1 in L) or not HasElementaryAbelianFactorGroup(eas[step],eas[L[Length(L)]]) then
        Add(L,step+1);
      fi;
    od;
    Add(L,1);
    L:=Reversed(L);
    indstep:=indstep{L};
    eas:=eas{L};

    dat.home:=home;
    dat.eas:=eas;
    dat.indstep:=indstep;
    dat.cent:=cent;
    levdat:=List(eas,x->rec());
    dat.levdat:=levdat;

    Info(InfoClasses,1,"Series of sizes ",List(eas,Size));

    allcl:=[];
    dat.allcl:=allcl;

  fi;

  # Initialize the algorithm for the trivial group.
  step:=1;

  L:=eas[step];
  leda:=levdat[step];
  if IsBound(leda.Lp) then
    Lp:=leda.Lp;
    mL:=leda.mL;
  else
    Lp:=InducedPcgs(home,L);
    mL:=ModuloPcgsByPcSequenceNC(home, home, Lp);
    leda.Lp:=Lp;
    leda.mL:=mL;
  fi;

  cl:=rec(representative:=One(G),
          centralizer:=H,
          centralizerpcgs:=InducedPcgs(home,H),
          cengen:=InducedPcgs(home,H));

  if candidates<>false then
    cls:=List(candidates, c -> cl);
    opr:=List(candidates, c -> One(G));
  else
    cls:=[cl];
  fi;

  if not IsBound(allcl[step]) then allcl[step]:=[ShallowCopy(cl)];fi;

  # Now go back through the factors by all groups in the elementary abelian
  # series.
  for step  in [2 .. Length(eas)]  do


    Info(InfoClasses,1,"Step ",step,", ",Length(cls)," classes to lift");

    # We apply the homomorphism principle to the homomorphism G/L -> G/K.

    # The  actual   computations  are all  done   in <G>,   factors are
    # represented by modulo pcgs.
    Ldep:=indstep[step];

    K:=eas[step-1];
    L:=eas[step];


    leda:=levdat[step];
    if IsBound(leda.Lp) then
      Lp:=leda.Lp;
      N:=leda.N;
      mL:=leda.mL;
      allcent:=leda.allcent;
      nexpo:=leda.nexpo;
    else
      Lp:=InducedPcgs(home,L);
      Kp:=InducedPcgs(home,K);
      N:=Kp mod Lp;  # modulo pcgs representing the kernel
      mL:=ModuloPcgsByPcSequenceNC(home, home, Lp);
      leda.Lp:=Lp;
      leda.N:=N;
      leda.mL:=mL;

      allcent:=cent(home,home,N,Ldep);
      if allcent=false then
        nexpo:=LinearOperationLayer(home{[1..indstep[step-1]-1]},N);
      else
        nexpo:=fail;
      fi;
      leda.allcent:=allcent;
      leda.nexpo:=nexpo;

    fi;

    if IsBound(allcl[step]) then
      # allcl[step-1] has data
      for i in cls do
        q:=PositionProperty(allcl[step-1],x->x.representative=i.representative);
        i.centralizerpcgs:=allcl[step-1][q].centralizerpcgs;
        i.cengen:=i.centralizerpcgs!.pcSequence;
      od;
    else
      for i in cls do
        if IsBound(i.cengen) and not IsBound(i.centralizerpcgs) then
          i.centralizerpcgs:=InducedPcgsByPcSequence(home,i.cengen);
          i.cengen:=i.centralizerpcgs!.pcSequence;
        fi;
      od;
    fi;

    N!.capH:=N;

    # Identification of classes.

    blist:=BlistList([1 .. Length(cls)], []);
    pos:=Position(blist, false);
    while pos<>fail  do

      # Find a team of candidates with same image under <modK>.
      cl:=cls[pos];
      cl.candidates:=[];
      team:=[];
      q:=pos;
      while q<>fail  do
        if q=pos or cls[q].representative /
            cl.representative in K then
          c:=candidates[q] ^ opr[q];
          i:=Position(cl.candidates, c);
          if i=fail then
            Add(cl.candidates, c);
            Add(team, [q]);
          else
            Add(team[i], q);
          fi;
          blist[q]:=true;
        fi;
        q:=Position(blist, false, q);
      od;

      # Now   <cl> is   a  class  modulo  <K>  (possibly   with
      # `<cl>.candidates'  a list of  elements  mapping  into  this
      # class modulo <K>). Let <newcls>  be  a list of all  classes
      # modulo <L> that  map to <cl>  modulo <K>  (resp. a list  of
      # classes to which   the list `<cl>.candidates'   maps modulo
      # <K>,  together  with   `operator's and   `exponent's  as in
      # (c^o^e=r)).
      if allcent then
        # generic central
        Info(InfoClasses,5,"central case 1");
        newcls:=CentralStepClEANS(home,H, G, N, cl,false);
      elif cent(home,cl.centralizerpcgs, N, Ldep) then
        # central in this case
        Info(InfoClasses,5,"central case 2");
        newcls:=CentralStepClEANS(home,H, G, N, cl,false);
      else
        Info(InfoClasses,5,"general case");
        newcls:=GeneralStepClEANS(home, H, G, N, nexpo, cl,false);
      fi;

      # Update <cls>, <opr> and <exp>.
      for i  in [1 .. Length(team)]  do

        for q  in team[i]  do
          cls[q]:=newcls[i];
          opr[q]:=opr[q] * newcls[i].operator;
        od;
      od;

      pos:=Position(blist, false, pos);
    od;

    if not IsBound(allcl[step]) then allcl[step]:=Unique(cls);fi;

  od;

  Assert(1,ForAll([1..Length(cls)],
    i->candidates[i]^opr[i]=cls[i].representative));

  return List(cls,x->x.representative);
end);


InstallGlobalFunction(CentralizerSizeLimitConsiderFunction,function(sz)
  return function(fhome,rep,cenp,K,L)
           return Product(RelativeOrders(cenp))/Size(K)<=sz;
          end;
end);

#############################################################################
##
#M  ActorOfExternalSet( <cl> ) . . . . . . . . . conj. cl. of solv. groups
##
InstallMethod( ActorOfExternalSet, true,
        [ IsConjugacyClassGroupRep ], 0,
    function( cl )
    local   G,  rep;

    G:=ActingDomain( cl );
    if not CanEasilyComputePcgs( G )  then
        TryNextMethod();
    fi;
    rep:=ClassesSolvableGroup( G, 0,rec(candidates:=[ Representative(cl)]) )
           [ 1 ];
    if not HasStabilizerOfExternalSet( cl )  then
        SetStabilizerOfExternalSet( cl,
                ConjugateSubgroup( rep.centralizer, rep.operator ^ -1 ) );
    fi;
    SetCanonicalRepresentativeOfExternalSet( cl, rep.representative );
    return rep.operator;
end );


#############################################################################





#############################################################################

# everything which follows is only used for rational classes in p groups.
# This is not of that much importance any longer as the permutation groups
# class algorithm is different, but it is still worth having for rational
# classes of p-elements.  AH, 14-apr-99


#############################################################################
##
#F  RationalClassesSolvableGroup(<G>, <mode> [,<opt>])  . . . . .
##
##  This is the old version. It is now only used for rational classes and
##  does not incorporate any of the improvements to the ordinary code.
##  (However therefore the ordinary code does not need to worry with the
##  rational classes case)
##  In this function  classes  are described by  records  with   components
##  `representative', `centralizer', `galoisGroup' (for rational classes). If
##  <candidates>  are  given,  their   classes  will   have  a  canonical
##  `representative'
##  and additional components `operator' and `exponent' (for
##  rational classes) such that
##    (candidate ^ operator) ^ exponent=representative.     (c^o^e=r)
##
InstallGlobalFunction(RationalClassesSolvableGroup, function(arg)
local  G,  home,  # the group and the home pcgs
       H,Hp,    # acting group
       mode,    # LSB: ratCl | power | test :MSB
       candidates,  # candidates to be replaced by their canonical reps.
       eas,     # elementary abelian series in <G>
       step,    # counter looping over <eas>
       K,  L,   # members of <eas>
       Kp,mK,Lp,mL, # induced and modulo pcgs's
       LcapH,KcapH, # intersections
       N,   cent,   # elementary abelian factor, for affine action
       cls, newcls, # classes in range/source of homomorphism
       news,    # new classes obtained in step
       cl,      # class looping over <cls>
       opr, exp,  # (candidates[i]^opr[i])^exp[i]=cls[i].representative
       team,    # team of candidates with same image modulo <K>
       blist,pos,q, # these control grouping of <cls> into <team>s
       p,       # prime dividing $|G|$
       ord,     # order of a rational class modulo <L>
       new, power,  # auxiliary variables for determination of power tree
       c,  i,     # loop variables
       opt,     # options
       divi;    # DivisorsInt(Size(G)) (used for Info)


  G:=arg[1];

  mode :=arg[2];  # explained below whenever it appears

  if Length(arg)=3 then
    opt:=ShallowCopy(arg[3]);
    # convert series to pcgs
    if IsBound(opt.series) and not IsBound(opt.pcgs) then
      Error("convert series to pcgs!");
    fi;
  else
    opt:=rec();
  fi;

  # <candidates> is a list  of elements whose classes  will be output  (but
  # with canonical representatives), see comment  above. Or <candidates> is
  # just one element, from whose output class the  centralizer will be read
  # off.
  H:=G;
  if IsBound(opt.candidates) then
    candidates:=opt.candidates;
    if not ForAll(candidates,i->i in G) then
      G:=ClosureGroup(H,candidates);
    fi;
  else
    candidates:=false;
  fi;

  #if IsBound(opt.consider) then
  #  consider:=opt.consider;
  #else
  #  consider:=true;
  #fi;

  # Treat the case of a trivial group.
  if IsTrivial(H) then
    if mode=4 then  # test conjugacy of two elements
      return One(G);
    elif mode mod 2=1 then  # rational classes
      cl:=rec(representative:=One(G),
              centralizer:=G,
              galoisGroup:=GroupByPrimeResidues([], 1));
      cl.galoisGroup!.type:=3;
      cl.galoisGroup!.operators:=[];
      cl.isCentral:=true;
      if mode mod 4=3 then  # construct the power tree
        cl.power     :=rec(representative:=One(G));
        cl.power.operator:=One(G);
        cl.power.exponent:=1;
      fi;
    else
      cl:=rec(representative:=One(G),
              centralizer:=H);
    fi;

    if candidates<>false then
      cls:=List(candidates, c -> cl);
    else
      cls:=[cl];
    fi;

    return cls;
  fi;

  # Calculate a (central)  elementary abelian series  with all pcgs induced
  # w.r.t. <homepcgs>.

  if IsBound(opt.pcgs) then
    # we prescribed a series
    home:=opt.pcgs;
    eas:=EANormalSeriesByPcgs(home);
    cent:=function(cl, N, L)
      return ForAll(N, k -> ForAll
        (InducedPcgs(home,cl.centralizer), c -> Comm(k, c) in L));
    end;
  elif IsPGroup(G) then
    p:=PrimePGroup(G);
    home:=PcgsPCentralSeriesPGroup(G);
    eas:=PCentralNormalSeriesByPcgsPGroup(home);

    cent:=ReturnTrue;
  elif mode mod 2=1 then  # rational classes
    Error("<G> must be a p-group");
  else
    home:=PcgsElementaryAbelianSeries(G);
    eas:=EANormalSeriesByPcgs(home);
    cent:=function(cl, N, L)
      return ForAll(N, k -> ForAll
        (InducedPcgs(home,cl.centralizer),
#T  was: Only those elements form the induced PCGS. The subset seemed to
#T enforce taking only the elements up, but the ordering of the series used
#T may be different then the ordering in the PCGS. So this will fail. AH
#T one might pick the right ones, but this would be almost the same work.
#T { [1 .. Length(InducedPcgsWrtHomePcgs(cl.centralizer))
#T - Length(InducedPcgsWrtHomePcgs(L))] },
           c -> Comm(k, c) in L));
    end;
  fi;

  Info(InfoClasses,1,"Series of sizes ",List(eas,Size));

  if mode<3 and InfoLevel(InfoClasses)>1 then
    divi:=DivisorsInt(Size(G));
    Info(InfoClasses,2,"centsiz: ",divi);
  fi;

  # Initialize the algorithm for the trivial group.
  step:=1;

  L :=eas[step];
  Lp:=InducedPcgs(home,L);

  if not IsIdenticalObj( G, H )  then
    Hp := InducedPcgs(home, H );
    LcapH := NormalIntersectionPcgs( home, Hp, Lp );
  fi;


  if  mode mod 2=1  # rational classes
     or candidates<>false then
    mL:=ModuloPcgsByPcSequenceNC(home, home, Lp);
  fi;

  if mode mod 2=1 then  # rational classes
    cl:=rec(representative:=One(G),
            centralizer:=H,
            galoisGroup:=GroupByPrimeResidues([], 1));
    cl.galoisGroup!.type:=3;
    cl.galoisGroup!.operators:=[];
    if mode mod 4=3 then  # construct the power tree
      cl.power     :=rec(representative:=One(G));
      cl.power.operator:=One(G);
      cl.power.exponent:=1;
      cl.power.kernel  :=false;
    fi;
  else
    cl:=rec(representative:=One(G),
            centralizer:=H);
  fi;

  if candidates<>false then
    cls:=List(candidates, c -> cl);
    opr:=List(candidates, c -> One(G));
    exp:=ListWithIdenticalEntries(Length(candidates), 1);
  else
    cls:=[cl];
  fi;

  # Now go back through the factors by all groups in the elementary abelian
  # series.
  for step  in [step + 1 .. Length(eas)]  do

    Info(InfoClasses,1,"Step ",step,", ",Length(cls)," classes to lift");

    # We apply the homomorphism principle to the homomorphism G/L -> G/K.
    # The  actual   computations  are all  done   in <G>,   factors are
    # represented by modulo pcgs.
    K :=L;
    Kp:=Lp;
    L :=eas[step];
    Lp:=InducedPcgs(home,L);
    N :=Kp mod Lp;  # modulo pcgs representing the kernel

    #T What is this? Obviously it is needed somewhere, but it is
    #T certainly not good programming style. AH
    SetFilterObj(N, IsPcgs);

    if not IsIdenticalObj(G,H) then
      KcapH := LcapH;
      LcapH := NormalIntersectionPcgs(home,Hp,Lp);
      N!.capH:=KcapH mod LcapH;
      SetFilterObj( N!.capH, IsPcgs );
    else
      N!.capH:=N;
    fi;

    # Rational classes or identification of classes.
    if  mode mod 2=1
       or candidates<>false then
      mK:=mL;
      mL:=ModuloPcgsByPcSequenceNC(home, home, Lp);
    fi;


    # Identification of classes.
    if candidates<>false then
      if   mode=4  # test conjugacy of two elements
         and not cls[1].representative /
             cls[2].representative in K then
        return fail;
      fi;

      blist:=BlistList([1 .. Length(cls)], []);
      pos:=Position(blist, false);
      while pos<>fail  do

        # Find a team of candidates with same image under <modK>.
        cl:=cls[pos];
        cl.representative:=PcElementByExponentsNC(mK,
          ExponentsOfPcElement(mK, cl.representative));
        cl.candidates:=[];
        team:=[];
        q:=pos;
        while q<>fail  do
          if cls[q].representative /
             cl.representative in K then
            c:=candidates[q] ^ opr[q];
            if mode mod 2=1 then  # rational classes
              c:=c ^ exp[q];
            fi;
            i:=PositionSorted(cl.candidates, c);
            if  i > Length(cl.candidates)
                or cl.candidates[i]<>c then
                Add( cl.candidates,c,i);
                Add(team, [q], i);
            else
              Add(team[i], q);
            fi;
            blist[q]:=true;
          fi;
          q:=Position(blist, false, q);
        od;

        # Now   <cl> is   a  class  modulo  <K>  (possibly   with
        # `<cl>.candidates'  a list of  elements  mapping  into  this
        # class modulo <K>). Let <newcls>  be  a list of all  classes
        # modulo <L> that  map to <cl>  modulo <K>  (resp. a list  of
        # classes to which   the list `<cl>.candidates'   maps modulo
        # <K>,  together  with   `operator's and   `exponent's  as in
        # (c^o^e=r)).
        if mode mod 2=1 then  # rational classes
          newcls:=CentralStepRatClPGroup(home, H, N, mK, mL, cl);
        elif cent(cl, N, L) then
          newcls:=CentralStepClEANS(home,H, G, N, cl);
        else
          newcls:=GeneralStepClEANS(home, H, G, N, cl);
        fi;

        # Update <cls>, <opr> and <exp>.
        for i  in [1 .. Length(team)]  do
          for q  in team[i]  do
            cls[q]:=newcls[i];
            opr[q]:=opr[q] * newcls[i].operator;
            if mode mod 2=1 then  # rational classes
              ord:=OrderModK(cls[q].representative, mL);
              if ord<>1 then

                # For  historical  reasons,   the `exponent's
                # returns by `CentralStepRatClPGroup' are the
                # inverses of what we need.
                exp[q]:=exp[q] /
                      newcls[i].exponent mod ord;

              fi;
            fi;
          od;
        od;

        pos:=Position(blist, false, pos);
      od;

    elif mode mod 2=1 then  # rational classes
      newcls:=[];
      for cl  in cls  do
        if IsBound(cl.power) then  # construct the power tree
          cl.representative:=PcElementByExponentsNC(mK,
            ExponentsOfPcElement(mK, cl.representative));
          cl.power.representative:=PcElementByExponentsNC(mK,
            ExponentsOfPcElement(mK, cl.power.representative));
        fi;
        new:=CentralStepRatClPGroup(home, G, N, mK, mL, cl);
        ord:=OrderModK(new[1].representative, mL);

#  if   ord <= limit.order
#   and ( limit.size=0
#       or limit.size mod Size(new[1])=0) then

        if IsBound(cl.power) then  # construct the power tree
          if ord=1 then
          power:=cl.power;
          else
          cl.power.candidates:=[(new[1].representative ^
            cl.power.operator) ^ (p*cl.power.exponent)];
          power:=CentralStepRatClPGroup(home, G, N, mK, mL,
                   cl.power)[1];
          power.operator:=cl.power.operator
                     * power.operator;
          power.exponent:=cl.power.exponent
                     / power.exponent mod ord;
          fi;
          for c  in new  do
          c.power:=power;
          od;
        fi;
        Append(newcls, new);

# fi
      od;
      cls:=newcls;

    else
      newcls:=[];
      for cl  in cls  do

        #if consider=true or consider(fhome,cl.representative,cl.centralizerpcgs,K,L)
          #then
          if cent(cl, N, L) then
            news:=CentralStepClEANS(home,G, G, N, cl);
          else
            news:=GeneralStepClEANS(home, G, G, N, cl);
          fi;
          Assert(1,ForAll(news,
                  i->ForAll(GeneratorsOfGroup(i.centralizer),
                  j->Comm(i.representative,j) in eas[step])));
          Append(newcls,news);
        #fi;

      od;
      cls:=newcls;
    fi;

    if InfoLevel(InfoClasses)>1 then
      c:=Collected(List(cls,i->Size(i.centralizer)));
      if not IsBound( divi ) then
        divi:=DivisorsInt(Size(G));
      fi;
      c:=Concatenation(c,List(divi,i->[i,0])); # to cope with `First'
      Info(InfoClasses,2,List(divi,i->First(c,j->j[1]=i)[2]));
    fi;
  od;

  if mode=4 then  # test conjugacy of two elements
    if cls[1].representative<>cls[2].representative then
      return fail;
    else
      return opr[1] / opr[2];
    fi;
  fi;

  if candidates<>false then  # add operators (and exponents)
    for i  in [1 .. Length(cls)]  do
      cls[i].operator:=opr[i];
      if mode mod 2=1 then  # rational classes
        cls[i].exponent:=exp[i];
      fi;
    od;
  fi;
  return cls;
end);

#############################################################################
##
#F  OrderModK( <h>, <mK> )  . . . . . . . . . .  order modulo normal subgroup
##
InstallGlobalFunction( OrderModK, function( h, mK )
    local   ord,  d,  o;

    ord:=1;
    d:=DepthOfPcElement( mK, h );
    while d <= Length( mK )  do
        o:=RelativeOrders( mK )[ d ];
        h:=h ^ o;
        ord:=ord * o;
        d:=DepthOfPcElement( mK, h, d + 1 );
    od;
    return ord;
end );

#############################################################################
##
#F  OldSubspaceVectorSpaceGroup( <N>, <p>, <gens>, <howmuch> )  . complement and projection
##
##  This function creates a record  containing information about a complement
##  in <N> to the span of <gens>.
##
BindGlobal("OldSubspaceVectorSpaceGroup", function( N, p, gens )
    local   zero,  one,  r,  ran,  n,  nan,  cg,  pos,  Q,  i,  j,  v;

    one:=One( GF( p ) );  zero:=0 * one;
    r:=Length( N );       ran:=[ 1 .. r ];
    n:=Length( gens );    nan:=[ 1 .. n ];
    Q:=[  ];
    if n <> 0  and  IsMultiplicativeElementWithInverse( gens[ 1 ] )  then
        Q:=List( gens, gen -> ExponentsOfPcElement( N, gen ) ) * one;
    else
        Q:=ShallowCopy( gens );
    fi;

    cg:=rec( matrix        :=[  ],
               needed        := [],
               one           :=one,
               baseComplement:=ShallowCopy( ran ),
               projection    := IdentityMat( r, one ),
               commutator    :=0,
               centralizer   :=0,
               dimensionN    :=r,
               dimensionC    :=n );

    if n = 0  or  r = 0  then
        cg.inverse:=NullMapMatrix;
        return cg;
    fi;

    for i  in nan  do
        cg.matrix[ i ]:=Concatenation( Q[ i ], zero * nan );
        cg.matrix[ i ][ r + i ]:=one;
    od;
    TriangulizeMat( cg.matrix );
    pos:=1;
    for v  in cg.matrix  do
        while v[ pos ] = zero  do
            pos:=pos + 1;
        od;
        RemoveSet( cg.baseComplement, pos );
        if pos <= r  then  cg.commutator :=cg.commutator  + 1;
                     else  cg.centralizer:=cg.centralizer + 1;  fi;
    od;

    cg.needed        :=[  ];
    cg.projection    :=IdentityMat( r, one );

    # Find a right pseudo inverse for <Q>.
    Append( Q, cg.projection );
    Q:=MutableTransposedMat( Q );
    TriangulizeMat( Q );
    Q:=TransposedMat( Q );
    i:=1;
    j:=1;
    while i <= Length( N )  do
        while j <= Length( gens ) and Q[ j ][ i ] = zero  do
            j:=j + 1;
        od;
        if j <= Length( gens ) and Q[ j ][ i ] <> zero  then
            cg.needed[ i ]:=j;
        else

            # If <Q> does  not  have full rank, terminate when the bottom row
            # is reached.
            i:=Length( N );

        fi;
        i:=i + 1;
    od;

    if IsEmpty( cg.needed )  then
        cg.inverse:=NullMapMatrix;
    else
        cg.inverse:=Q{ Length( gens ) + ran }
                       { [ 1 .. Length( cg.needed ) ] };
        cg.inverse:=ImmutableMatrix(p,cg.inverse,true);
    fi;
    if IsEmpty( cg.baseComplement )  then
        cg.projection:=NullMapMatrix;
    else

        # Find a base change matrix for the projection onto the complement.
        for i  in [ 1 .. cg.commutator ]  do
            cg.projection[ i ][ i ]:=zero;
        od;
        Q:=[  ];
        for i  in [ 1 .. cg.commutator ]  do
            Q[ i ]:=cg.matrix[ i ]{ ran };
        od;
        for i  in [ cg.commutator + 1 .. r ]  do
            Q[ i ]:=ListWithIdenticalEntries( r, zero );
            Q[ i ][ cg.baseComplement[ i-r+Length(cg.baseComplement) ] ]
             :=one;
        od;
        cg.projection:=cg.projection ^ Q;
        cg.projection:=cg.projection{ ran }{ cg.baseComplement };
        cg.projection:=ImmutableMatrix(p,cg.projection,true);

    fi;

    return Immutable(cg);
end );

#############################################################################
##
#F  OldKernelHcommaC( <N>, <h>, <C> )
##
##  Given a homomorphism C -> N, c |-> [h,c],  this function determines (a) a
##  vector space decomposition N =  [h,C] + K with  projection onto K and (b)
##  the  ``kernel'' S <  C which plays   the role of  C_G(h)  in lemma 3.1 of
##  [Mecky, Neub\"user, Bull. Aust. Math. Soc. 40].
##
BindGlobal("OldKernelHcommaC", function( N, h, C )
    local   i,  tmp,  v;

    N!.subspace := OldSubspaceVectorSpaceGroup( N, RelativeOrders( N )[ 1 ],
                           List( C, c -> Comm( h, c ) ) );
    tmp := [  ];
    for i  in [ N!.subspace.commutator + 1 ..
                N!.subspace.commutator + N!.subspace.centralizer ]  do
        v := N!.subspace.matrix[ i ];
        tmp[ i - N!.subspace.commutator ] := PcElementByExponentsNC( C,
                 v{ [ N!.subspace.dimensionN + 1 ..
                      N!.subspace.dimensionN + N!.subspace.dimensionC ] } );
    od;
    return tmp;
end );

#############################################################################
##
#F  CentralStepConjugatingElement( ... )  . . . . . . . . . . . . . . . local
##
##  This function returns an element of <G> conjugating <hk1> to <hk2>^<l>.
##
InstallGlobalFunction( CentralStepConjugatingElement,
  function( N, h, k1, k2, l, cN )
    local   v,  conj;

    v:=ExponentsOfPcElement( N, h ^ -l * h ^ cN * k1 * k2 ^ -l );
    conj:=LinearCombinationPcgs( N!.CmodK{ N!.subspace.needed },
                    v * N!.subspace.inverse,OneOfPcgs( N ) );
    conj:=LeftQuotient( conj, cN );
    return conj;
end );

#############################################################################
##
#F  CentralStepRatClPGroup(<homepcgs>, <G>, <N>, <mK>, <mL>, <cl> )
##
InstallGlobalFunction( CentralStepRatClPGroup,
    function( home, G, N, mK, mL, cl )
    local  h,           # preimage of `cl.representative' under <hom>
           candexps,    # list of exponent vectors for <h> mod <candidates>
           classes,     # the resulting list of classes
           ohN,  oh,    # order of <h> in `Range(<hom>)' resp. `Source(<hom>)'
           p,           # exponent of <N>
           K,           # a complement to $[h,C]$ in <N>
           Gal,  gal,   # Galois group for element in `Source(<hom>)'
           preimage,    # preimage of $Gal(hN)$ in $Z_oh^*$
           operator,    # generator of <preimage> acting by conjugation
           reps, conj,  #\ representatives, conjugating elements,
           exps, #/ exponents and orbit lengths in orbit algorithm
           Q,  v,  r,   # subspace to be projected onto, projection vectors
           k,           # orbit representative in <N>
           gens,  oprs, # generators and operators for new Galois group
           type,        # the type of the Galois group as subgroup of Z_2^r^*
           i, j, l, c,  # loop variables
           C,  cyc,  xset,  opr,  orb,kern,img;

    p  :=RelativeOrders( N )[ 1 ];
    h  :=cl.representative;
    ohN:=OrderModK( h, mK );
    oh :=OrderModK( h, mL );

    classes:=[  ];
    if oh = 1  then

        # Special case: <h> is trivial.
        Gal:=Units( Integers mod 1 );
        gal:=GroupByPrimeResidues( [  ], p );
        gal!.type:=3;
        gal!.operators:=[  ];

        if IsBound( cl.candidates )  then
            for c  in cl.candidates  do
                l:=LeadingExponentOfPcElement( N, c );
                if l = fail  then
                    l:=1;
                    c:=rec( representative:=c,
                                 galoisGroup:=TrivialSubgroup( Gal ) );
                    c.galoisGroup!.type:=3;
                    c.galoisGroup!.operators:=[  ];
                else
                    c:=rec( representative:=c ^ ( 1 / l mod p ),
                                 galoisGroup:=gal );
                fi;
                c.centralizer:=G;
                c.operator   :=OneOfPcgs( N );
                c.exponent   :=l;
                Add( classes, c );
            od;
        else
            c:=rec( representative:=One( G ),
                         centralizer:=G,
                         galoisGroup:=TrivialSubgroup( Gal ) );
            c.galoisGroup!.type:=3;
            c.galoisGroup!.operators:=[  ];
            Add( classes, c );
            for v in EnumeratorOfNormedRowVectors( GF( p ) ^ Length( N ) ) do
                c:=rec( representative:=PcElementByExponentsNC( N, v ),
                             centralizer:=G,
                             galoisGroup:=gal );
                Add( classes, c );
            od;
        fi;

    else
        Gal:=Units( Integers mod oh );
        if IsBound( cl.kernel )  then
            N:=cl.kernel;
        else
            N!.CmodK:=InducedPcgs(home, cl.centralizer ) mod
                        DenominatorOfModuloPcgs( N );
            kern:=DenominatorOfModuloPcgs( N );
            img:=OldKernelHcommaC( N, h, N!.CmodK ) ;
            #N!.CmodL:=ExtendedPcgs(kern,img);
            N!.CmodL:=InducedPcgsByPcSequenceAndGenerators(ParentPcgs( kern ),
                    kern, img );

        fi;
        if IsBound( cl.candidates )  then
            cl.candidates:=List( cl.candidates, c ->
                LeftQuotient( h, c ) );
            candexps:=List( cl.candidates, c ->
                ExponentsOfPcElement( N, c ) ) * N!.subspace.projection;
        fi;

        # If <p> = 2, use a projection operation.
        if p = 2  then

            # Construct the preimage of $Gal(hN)$ in $Z_oh^*$.
            if ohN <= 2  then
                preimage:=GroupByPrimeResidues( [ -1, 5 ], oh );
                preimage!.type:=1;
                preimage!.operators:=List( GeneratorsOfGroup( preimage ),
                                            i -> One( G ) );
            else
                if   cl.galoisGroup!.type = 1  then
                    preimage:=[ -1, 5^(ohN/(2*Size(cl.galoisGroup))) ];
                elif cl.galoisGroup!.type = 2  then
                    preimage:=[  -( 5^(ohN/(4*Size(cl.galoisGroup)))) ];
                else
                    preimage:=[     5^(ohN/(4*Size(cl.galoisGroup))) ];
                fi;
                preimage:=GroupByPrimeResidues( preimage, oh );
                preimage!.type:=cl.galoisGroup!.type;
                if Length( GeneratorsOfGroup( preimage ) ) =
                   Length( GeneratorsOfGroup( cl.galoisGroup ) )  then
                    preimage!.operators:=cl.galoisGroup!.operators;
                else
                    preimage!.operators:=Concatenation
                      ( cl.galoisGroup!.operators, [ One( G ) ] );
                fi;
            fi;

            # Construct the image of the homomorphism <preimage> -> <K>.
            Q:=[  ];
            for i  in [ 1 .. Length( GeneratorsOfGroup( preimage ) ) ]  do

#Assert(2,LeftQuotient(h^Int(GeneratorsOfGroup(preimage)[i]),
#                      h^preimage!.operators[i]) in
#                      Group(NumeratorOfModuloPcgs(N)));

                Add( Q, ExponentsOfPcElement( N, LeftQuotient( h ^
                        Int( GeneratorsOfGroup( preimage )[ i ] ),
                        h ^ preimage!.operators[ i ] ) ) );
            od;
            Q:=Q * N!.subspace.projection;
            K:=InducedPcgsByPcSequenceNC( N,
                         N{ N!.subspace.baseComplement } );
            K!.subspace:=OldSubspaceVectorSpaceGroup( K, p, Q );

            # Project the factors in <N> onto a complement to <Q>.
            if IsBound( cl.candidates )  then
                v:=List( candexps, ShallowCopy );
                r:=v * K!.subspace.projection;
                reps:=[  ];
                exps:=[  ];
                conj:=[  ];
                if not IsEmpty( K!.subspace.baseComplement )  then
                    v{[1..Length(v)]}{K!.subspace.baseComplement}:=
                      v{[1..Length(v)]}{K!.subspace.baseComplement} + r;
                fi;
                v:=v * K!.subspace.inverse;
                for i  in [ 1 .. Length( r ) ]  do
                    reps[ i ]:=PcElementByExponentsNC
                        ( K, K!.subspace.baseComplement, r[ i ] );
                    exps[ i ]:=LinearCombinationPcgs(
                      GeneratorsOfGroup(preimage){K!.subspace.needed},
                      v[ i ],One(preimage));
                    conj[ i ]:=LinearCombinationPcgs(
                      preimage!.operators { K!.subspace.needed }, v[ i ],
                      One(G));
                od;

            # In the  construction case,  the complement  to <Q>  is a set of
            # representatives.
            else
                reps:=EnumeratorByPcgs( K, K!.subspace.baseComplement );
            fi;

            # The kernel of the homomorphism into  <K> is the Galois group of
            # <h>.
            if IsTrivial( preimage )  then  # pre = < 1 >
                gens:=GeneratorsOfGroup( preimage );
                oprs:=preimage!.operators;
                type:=preimage!.type;
            else
                if Q[ 1 ] = Zero( Q[ 1 ] )  then  i:=1;
                                            else  i:=2;  fi;
                if Length( GeneratorsOfGroup( preimage ) ) = 1  then
                    gens:=[ GeneratorsOfGroup( preimage )[ 1 ] ^ i ];
                    oprs:=[ preimage!.operators          [ 1 ] ^ i ];
                    if   preimage!.type = 1  then  type:=2 * i - 1; # <-1>
                    elif preimage!.type = 2  then  type:=i + 1;
                                             else  type:=3;          fi;
                else
                    if Q[ 2 ] = Zero( Q[ 2 ] )  then  j:=1;
                                                else  j:=2;  fi;
                    if i = 1  then
                        gens:=[ GeneratorsOfGroup( preimage )[ 1 ],
                                  GeneratorsOfGroup( preimage )[ 2 ] ^ j ];
                        oprs:=[ preimage!.operators          [ 1 ],
                                  preimage!.operators          [ 2 ] ^ j ];
                        type:=1;
                    elif j = 2  and  Q[ 1 ] = Q[ 2 ]  then
                        gens:=[ GeneratorsOfGroup( preimage )[ 1 ] *
                                  GeneratorsOfGroup( preimage )[ 2 ] ];
                        oprs:=[ preimage!.operators          [ 1 ] *
                                  preimage!.operators          [ 2 ] ];
                        type:=2;
                    else
                        gens:=[ GeneratorsOfGroup( preimage )[ 2 ] ^ j ];
                        oprs:=[ preimage!.operators          [ 2 ] ^ j ];
                        type:=3;
                    fi;
                fi;
            fi;

        # If <p> <> 2, use an affine operation of a cyclic group generated by
        # <preimage>.
        else
            K:=EnumeratorByPcgs( N, N!.subspace.baseComplement );
            cyc:=GroupByPrimeResidues( [ PowerModInt
                           ( PrimitiveRootMod( oh ),
                             IndexInParent( cl.galoisGroup ), oh ) ], oh );
            SetSize( cyc, Phi( oh ) / IndexInParent( cl.galoisGroup ) );
            if IsTrivial( cyc )  then
                preimage:=One( cyc );
            else
                SetIndependentGeneratorsOfAbelianGroup( cyc,
                        GeneratorsOfGroup( cyc ) );
                preimage:=Pcgs( cyc )[ 1 ];
            fi;
            if IsTrivial( cl.galoisGroup )  then
                operator:=One( G );
            else
                operator:=cl.galoisGroup!.operators[ 1 ];
            fi;

            v:=PcElementByExponentsNC( N, N!.subspace.baseComplement,
                 ExponentsOfPcElement( N, LeftQuotient( h ^ Int( preimage ),
                         h ^ operator ) ) * N!.subspace.projection );
            opr:=function( k, l )
                return
                #AH, jun3 2001: without the pcgs filtereing we might get
                # extra kernel elements. I have no idea how this was
                # originally avoided. This is rather a workaround than a fix
                # -- the whole code should be rewritten cleanly.
                PcElementByExponentsNC(N,ExponentsOfPcElement(N,
                ( v * k ) ^ ( 1 / Int( l ) mod p )
                ));
            end;
            xset:=ExternalSet( cyc, K, opr );

            reps:=[  ];
            exps:=[  ];
            if IsBound( cl.candidates )  then
                conj:=[  ];
                for c  in candexps  do
                    orb:=ExternalOrbit( xset, PcElementByExponentsNC( N,
                                   N!.subspace.baseComplement, c ) );
                    Add( reps, CanonicalRepresentativeOfExternalSet( orb ) );
                    i:=Size( cyc ) / Order( ActorOfExternalSet( orb ) );
                    Add( exps, preimage ^ i );
                    Add( conj, operator ^ i );
                od;
            else
                for orb  in ExternalOrbits( xset )  do
                    Add( reps, CanonicalRepresentativeOfExternalSet( orb ) );
                    Add( exps, preimage ^ Size( orb ) );
                od;
            fi;

        fi;

        # If <reps> is a set of  representatives of the orbits then <h><reps>
        # is a set of representatives of the rational classes in <hN>.
        for l  in [ 1 .. Length( reps ) ]  do
            k:=reps[ l ];

            # Construct  the   Galois  group and find   conjugating  elements
            # corresponding to its generator(s).
            if p <> 2  then
                gens:=[ exps[ l ] ];
                oprs:=[ operator ^ Int( exps[ l ] ) ];
            fi;
            gal:=SubgroupNC( Gal, gens );
            if p = 2  then
                gal!.type:=type;
            fi;
            gal!.operators:=[  ];
            for i  in [ 1 .. Length( GeneratorsOfGroup( gal ) ) ]  do
                Add( gal!.operators, CentralStepConjugatingElement
                     ( N, h, k, k, Int( GeneratorsOfGroup( gal )[ i ] ),
                       oprs[ i ] ) );
            od;

            C:=SubgroupNC( G, N!.CmodL );
            c:=rec( representative:=h * k,
                         centralizer:=C,
                         galoisGroup:=gal );
            if IsBound( cl.candidates )  then

                # cl.candidates[l] ^ c.operator =
                # c.representative ^ c.exponent (DIFFERS from (c^o^e=r)!)
                c.exponent:=Int( exps[ l ] );
                c.operator:=CentralStepConjugatingElement
                    ( N, h, cl.candidates[ l ], k, c.exponent, conj[ l ] );

                if IsBound( cl.kernel )  then
                    c.kernel:=N;
                fi;
            fi;
            Add( classes, c );
        od;

    fi;
    return classes;
end );

InstallMethod(CanonicalRepresentativeOfExternalSet,"pc class",true,
    [ IsExternalOrbit and IsConjugacyClassGroupRep and
      CategoryCollections(IsElementFinitePolycyclicGroup)],0,
function(c)
local a;
  a:=ClassesSolvableGroup( ActingDomain(c), 0,
    rec(candidates:= [Representative(c)] ));
  return a[1].representative;
end);

#############################################################################
##
#M  <cl1> = <cl2>
##
InstallMethod( \=,"classes for pc group", IsIdenticalObj,
    [ IsExternalOrbit and IsConjugacyClassGroupRep and
    CategoryCollections(IsElementFinitePolycyclicGroup),
    IsExternalOrbit and IsConjugacyClassGroupRep and
    CategoryCollections(IsElementFinitePolycyclicGroup) ],
function( cl1, cl2 )
  if not IsIdenticalObj( ActingDomain( cl1 ), ActingDomain( cl2 ) )  then
      TryNextMethod();
  fi;
  return Size(cl1)=Size(cl2) and
    CanonicalRepresentativeOfExternalSet(cl1)
      =CanonicalRepresentativeOfExternalSet(cl2);
end );
