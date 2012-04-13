#############################################################################
##
#W  solmxgrp.gi			GAP Library		       Gene Cooperman
#W							     and Scott Murray
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  REFERENCE:
##   E.M. Luks, ``Computing in solvable matrix groups'',
##   Proc. 33^{rd}$ IEEE Foundations of Computer Science (FOCS-33), 1992,
##   pp.~111-120.
##  (group membership and related algorithms (Size, Random, Enumerator, etc.)
##   currently implemented through abelian, and nilpotent,
##   will be extended to solvable in next release)
##
##  Cleaning up of code:
##    Testing for Cyclic and QuotientToAdditiveGroup should be
##       combined in routine:  if IsBaseCaseGroup(G) then ...
##    The method, InvariantSubspaceOrCyclicGroup, "for abelian non-char.
##       p-group" is too long and hence should be rewritten.
##

# InfoChain already declared.
#DeclareInfoClass("InfoChain");
# default info level is 0
#SetInfoLevel(InfoChain, 1);

#############################################################################
##
#F  SetIsCyclicWithSize( <G>, <gen>, <size> )
##
InstallGlobalFunction( SetIsCyclicWithSize,
    function(G, gen, size)
        if size = 1 then SetIsTrivial(G,true); return; fi;
        if IsOne(gen) then Error("internal error"); fi;
        SetIsCyclic(G,true);
        SetGeneratorOfCyclicGroup(G,gen);
        SetSize(G,size);
        IsPGroup(G); # It's cheap to test it now.
    end );

#############################################################################
##
#F  ConjugateMatrixActionToLinearAction( <g> )
##
InstallGlobalFunction( ConjugateMatrixActionToLinearAction, function(g)
    local i, j, d, ginv, zero, one, basisMatrix, newLinearMatrix;
    if not IsMatrix(g) then Error("Invalid input"); fi;
    d := Length(g);
    basisMatrix := List( [1..d], x->List([1..d],x->Zero(g[1][1])) );
    zero := Zero(g[1][1]);
    one := One(DefaultFieldOfMatrix(g));
    newLinearMatrix := [];
    ginv := g^(-1);
    for i in [1..d] do
        for j in [1..d] do
            basisMatrix[i][j] := one;
            Add( newLinearMatrix, Flat(ginv * basisMatrix * g) );
            basisMatrix[i][j] := zero;
        od;
    od;
    # return transpose for action, matrix * vec
    return TransposedMat( newLinearMatrix );
end );            

#############################################################################
##
#F  ConjugateMatrixGroupToLinearGroup( <G> )
##
ConjugateMatrixGroupToLinearGroup := function( G )
    return List( GeneratorsOfGroup( G ), g->[g, ConjugateMatrixActionToLinearAction(g) ] );
end;

#############################################################################
#############################################################################
##
##  Abelian matrix groups
##
#############################################################################
#############################################################################

#############################################################################
##
#M  MakeHomChain( <G> )
##
##  
##
InstallMethod( MakeHomChain, "for arbitrary group", true,
        [ IsGroup ], 0,
    function( G )
        # Test abelian first.  It's cheaper.
        if IsFFEMatrixGroup(G) and IsAbelian(G) then
            return MakeHomChain(G);
        elif IsFFEMatrixGroup(G) and IsNilpotentGroup(G) then
            return MakeHomChain(G);
        fi;
        Error("MakeHomChain currently implemented only for nilpotent groups");
    end );
InstallMethod( MakeHomChain, "for nilpotent group with chain", true,
               [ IsGroup and IsNilpotentGroup and HasChainSubgroup ], 0,
    G -> ChainSubgroup(G) );
InstallMethod( MakeHomChain, "for abelian group", true,
               [ IsGroup and IsAbelian ], 0,
    function( G )
        local PowerFnc, SetPGroup, pGroups, pgroupGens, otherPGens, first, pow, H;
        PowerFnc := power -> (g->g^power);
        SetPGroup := function( H, p, exponent)
            SetIsPGroup(H, true );
            SetPrimePGroup( H, p );
            SetExponent( H, exponent );
            if Length(GeneratorsOfGroup(H)) = 1 then
                SetIsCyclicWithSize( H, GeneratorsOfGroup(H)[1], exponent );
            fi;
            # UseSubsetRelation( G, H );
            return H;
        end;
        #Returns list of triples, [p,pgroupGens,exponentOfPGroup]
        pgroupGens := PGroupGeneratorsOfAbelianGroup( G );
        if Length(pgroupGens) = 0 then
            if not IsTrivial(G) then Error("internal error: not triv"); fi;
            SetIsTrivial( G, true );
            Info(InfoChain, 1, "Abelian group is trivial");
            return G;
        fi;
        if Length(pgroupGens) = 1 then
            SetPGroup( G, pgroupGens[1][1], pgroupGens[1][3] );
            Info(InfoChain, 1, "Abelian group is a p-group");
            return MakeHomChain( G );
        fi;
        Info(InfoChain, 1, "Making abelian chain as direct product of ",
                           Length(pgroupGens), " p-groups:  ",
                           List(pgroupGens,x->x[1]));
        pGroups := List( pgroupGens,
                         x -> SetPGroup(SubgroupNC(G,x[2]), x[1], x[3]) );

        # Be nice and tell GAP what we discovered, but don't pay cost
        #  of creating all the homomorphisms for embeddings and projections
        # If GAP knows about p-groups, it can do the homomorphisms on demand.
        first := [1];
        ForAll( pgroupGens,
                function( x ) Add( first, first[Length(first)]+Length(x[2]) );
                              return true;
                end );
        # MODIFYING ORIGINAL GENERATORS OF G; MAKE SURE THIS IS SHALLOW COPY
        # MySetGeneratorsOfGroup( G, Concatenation( List(pgroupGens, x->x[2]) ) );
        G!.PGroupGenerators := Concatenation( List(pgroupGens, x->x[2]) );

        while Length(pgroupGens) > 1 do
            SetDirectProductInfo( G,
                rec( groups := pGroups, first := first,
                     embeddings := [], projections := [] ) );
            otherPGens := pgroupGens{[2..Length(pgroupGens)]};
            if Length(pgroupGens) > 2 then
                H := SubgroupNC(G, Concatenation(List(otherPGens, x->x[2])));
            else H := pGroups[Length(pGroups)];
            fi;
            UseSubsetRelation( G, H );
            pow := ChineseRem( List(pgroupGens,x->x[3]),
                               Concatenation([1], List(otherPGens,x->0)) );
            if pow = 1 then Error("pow = 1, identity projection"); fi;
            ChainSubgroupByProjectionFunction( G, H, pGroups[1],
                                              PowerFnc(pow) );
            # This should be inside ChainSubgroupByProjectionFunction()
            MakeHomChain( QuotientGroup( Transversal( H ) ) );
            G := H;
            pgroupGens := otherPGens;
            pGroups := pGroups{[2..Length(pGroups)]};
            first := first{Flat([1,[3..Length(first)]])} + 1 - first[2];
            first[1] := 1;
        od;
        return MakeHomChain(H);
    end );

#############################################################################
##
#M  BasisOfHomCosetAddMatrixGroup( <> )
##
## GAP has V := VectorSpace(FieldOfMatrixGroup(quo), GeneratorsOfGroup(quo));
##    but how does one bootstrap up to get Dimension(V) and Basis(V)?
##    This may go away when there's a clearer way to do it in GAP.
##    This should work for IsAdditiveQuotientGroup, IsAdditiveGroup,
##    and IsFFEMatrixGroup
## LeftModuleByGenerators() also works, but again, GAP refuses to find
##     a basis for it.
## SemiEchelonBasis(V) fails with UseSubsetRelation(arg[1], S);
##
InstallGlobalFunction( BasisOfHomCosetAddMatrixGroupFnc,
function( G )
     local gens, oneOfGroup, g, v, c, basis, residue, firsts, tmp,
           b, i, fld, one, zero, fldSize, MyIntFFE, MyAdditiveOrder;
     # A better way (valid for additive groups, too) is:
     # field := Field( GeneratorsOfNearAdditiveGroup(G));
     # one := One(field);
     # why does FieldOfMatrixGroup work? IsFFEMatrixGroup(G)?
     if IsFFEMatrixGroup(G) then
         gens := GeneratorsOfGroup(G);
         oneOfGroup := One(G);
         fld := FieldOfMatrixGroup(G);
     elif IsAdditiveGroup(G) and HasGeneratorsOfNearAdditiveGroup(G) then
         gens := GeneratorsOfNearAdditiveGroup(G);
         oneOfGroup := Zero(G);
         if not IsEmpty(gens) then fld := Field(Flat(gens));
         else fld := Field(Flat(One(G)));
         fi;
     else Error("can't handle this case");
     fi;
     one := One(fld);
     zero := Zero(fld);
     fldSize := Size(fld);
     # HACK:  until GAP fixes IntFFE(); returns fail if impossible (not error)
     MyIntFFE := f -> First([0..fldSize], i -> f=i*one);
     basis := [];
     residue := [];
     firsts := [];
     for g in gens do
         v := Flat(g);
         for i in [1..Length(basis)] do
             c := PositionNot( v, zero );
             if c > Length(v) then break; fi; # g is now zero vector
             b := Flat(basis[i]); # for finding b[c];  Faster without Flat()
             c := PositionNot( b, zero );
             c := MyIntFFE( v[c] / b[c] );
             if c = fail then # then switch gen with current basis vector
                 tmp := g; g := basis[i]; basis[i] := tmp;
                 tmp := v; v := b; b[i] := tmp;
                 c := MyIntFFE( v[c] / b[c] );
                 if c = fail then Error("internal error"); fi;
             fi;
             g := g - c * basis[i];
             v := Flat(g);
         od;
         if g = oneOfGroup then Add(residue,g); # One(G) is 0 matrix here
         else Add(basis,g);
         fi;
     od;
     Sort(basis);  # GAP Sort works by side effect, only.
     basis := Reversed(basis);
     if IsFFEMatrixGroup(G) or IsQuotientToAdditiveGroup(G) then
         SetSize( G, Product( basis, Order ) );
     elif IsAdditiveGroup(G) then # What's GAP for Order() of elt in add. grp?
         #GAP should have Size() method for IsAdditiveGroup as below:
         # SizeOfChainOfGroup() calls this for now.
         MyAdditiveOrder := function(g)
             if IsZero(g) then return 1;
             else return Size(DefaultFieldOfMatrix(g));
             fi;
         end;
         SetSize( G, Product( basis, MyAdditiveOrder ) );
     fi;
     firsts := List(basis, v->PositionNot(v,zero));
     return rec(basis := basis, firsts := firsts, residue := residue);
end );

# This should eventually generalize to something like:
#    BasisOfAdditiveMatrixGroup, for which both of these are example.
InstallMethod( BasisOfHomCosetAddMatrixGroup, "by linear algebra", true,
    [ IsGroup and IsQuotientToAdditiveGroup ], 0,
    BasisOfHomCosetAddMatrixGroupFnc );
InstallMethod( BasisOfHomCosetAddMatrixGroup, "by linear algebra", true,
    [ IsAdditiveGroup ], 0, BasisOfHomCosetAddMatrixGroupFnc );

#############################################################################
##
#F  SiftVector( <basisVecList>, <vec> )
#F  SiftVector( <basisVecList> )
##
InstallGlobalFunction( SiftVector, function(arg)
    local basisVecs, b, firsts, zero, one, fldSize, MyIntFFE, fnc;
    # HACK:  until GAP fixes IntFFE(); returns fail if impossible (not error)
    MyIntFFE := f -> First([0..fldSize], i -> f=i*one);
    basisVecs := arg[1];
    b := List(basisVecs, Flat);
    zero := Zero(b[1][1]);
    one := One(b[1][1]);
    fldSize := Size(Field(Flat(b)));
    firsts := List( b, i->PositionNot(i,zero) );
    if 0 in firsts then Error("internal error"); fi;

    fnc := function(vec)
        local i, c, v;
        for i in [1..Length(b)] do
            v := Flat(vec);  # time for Flat dominated by arithmetic below
            c := MyIntFFE( v[firsts[i]] / b[i][firsts[i]] );
            if c = fail then return fail;
            else vec := vec - c * basisVecs[i];
            fi;
        od;
        return vec;
    end;

    if Length(arg)=2 then return fnc(arg[2]); else return fnc; fi;
end );

#############################################################################
##
#M  SiftFunction( <> )
##
##  
##
InstallMethod( SiftFunction,
    "for abelian quotient to additive group (by lin. algebra)", true,
    [ IsGroup and IsFFEMatrixGroup and IsQuotientToAdditiveGroup ], 0,
    G -> SiftVector( BasisOfHomCosetAddMatrixGroup(G).basis ) );

#############################################################################
##
#M  MakeHomChain( <> )
##
##  
##
InstallMethod( MakeHomChain, "by linear algebra", true,
    [ IsGroup and IsFFEMatrixGroup and IsQuotientToAdditiveGroup ], 0,
function( G )
     local SiftFnc;
     SiftFnc := SiftFunction(G);
     Info(InfoChain, 2, "Extending chain by kernel of abelian image.");
     # This is different from homomorphism transversal.
     # In hom transv, we induce a quotient group
     # Here we want a simple sift, in fact from quotient group to ord. grp.
     ChainSubgroupBySiftFunction( Source(G),
     KernelOfMultiplicativeGeneralMapping(G),
                         g->SourceElt(SiftFnc(HomCoset(Homomorphism(G),g))) );
     if HasSize(G) then SetSize(TransversalOfChainSubgroup(Source(G)), Size(G)); fi;
     if IsTrivial(KernelOfMultiplicativeGeneralMapping(G)) then return
     KernelOfMultiplicativeGeneralMapping(G); fi;
     return MakeHomChain(KernelOfMultiplicativeGeneralMapping(G));
end );

##  Currently, Cyclic and QuotientToAdditiveGroup are manageable.
##  If the argument, G, is already a manageable group, it returns G, itself.
ManageableQuotientOfAbelianPGroup :=
    function( G )
        local subspace, hom, V, fnc, kernel, quo, quo2, grp;
        Info(InfoChain, 2, "Making abelian ", PrimePGroup(G), "-group chain");
        if IsQuotientToAdditiveGroup(G) then # base case
            Error("internal error:  base case");
        fi;
        if ForAny(GeneratorsOfGroup(G), IsZero) then
            Error("internal error:  zero matrix");
        fi;
        if not IsPGroup(G) or not IsAbelian(G) then Error("wrong arg"); fi;
        subspace := InvariantSubspaceOrCyclicGroup( G );
        if IsVectorSpace( subspace ) then
          Info(InfoChain, 2, "Invariant subspace of rank ",
                 Dimension(subspace), " in dimension ",
                 Length(GeneratorsOfVectorSpace(subspace)[1]), " found.");
          Info(InfoChain, 2, "Trying action on invariant subspace");
          hom := NaturalHomomorphismByInvariantSubspace
                                                          ( G, subspace );
          if ForAll( GeneratorsOfGroup(G), g -> IsOne(ImageElm(hom,g)) ) then
             Info(InfoChain, 2, "Trying action on quotient of invar. subspace");
             hom := NaturalHomomorphismByFixedPointSubspace
							  ( G, subspace );
          fi;
          if ForAll( GeneratorsOfGroup(G), g -> IsOne(ImageElm(hom,g)) ) then
              Info(InfoChain, 2, "Trying homomorphism to Hom(V,W)");
              hom := NaturalHomomorphismByHomVW( G, subspace );
              Info(InfoChain, 2, "Creating QuotientToAdditiveGroup");
          fi;
          ChainSubgroupByHomomorphism( hom );
          quo := QuotientGroup(TransversalOfChainSubgroup(G));
          # After calling this, we might discover quo is cyclic.
          IsAbelian(quo);  # Tell GAP quo is abelian in case not propagated.
          # MakeHomChain(quo); # this need only be ChainSubgroup(quo);
          if IsQuotientToAdditiveGroup(quo) then return quo; fi;
          quo2 := ManageableQuotientOfAbelianPGroup(quo);
          if HasIsCyclic(quo) and IsCyclic(quo) then
              # MakeHomChain(quo);
              return quo;
          fi;
          return QuotientGroupByChainHomomorphicImage(quo, quo2);
        else
          Info(InfoChain, 2, PrimePGroup(G), "-group is cyclic.");
          if not HasGeneratorOfCyclicGroup(subspace) then
              Error("internal error:  cyclic group missing single generator");
          fi;
          SetIsCyclicWithSize( G, GeneratorOfCyclicGroup(subspace),
                                  Size(subspace) );
          return G;
        fi;
    end;

#############################################################################
##
#M  MakeHomChain( <> )
##
##GDC - Problem:  Really, this should apply only if it's not
##       HomCosetAddRep.  However, ordinary groups are okay.
##       I'd really like a property:  IsFFEMatrixGroup and IsNotHomCosetAddGroup
##
InstallMethod( MakeHomChain, "for abelian p-group", true,
    [ IsGroup and IsFFEMatrixGroup and IsAbelian and IsPGroup ], 0,
    function( G )
        local quo, kernel;
        quo := ManageableQuotientOfAbelianPGroup(G);
        if IsIdenticalObj(quo,G) then # then HasGeneratorOfCyclicGroup(G)
            MakeHomChain(G);
            return quo; # then not a quotient grp
        else
          IsAbelian(quo); # Special Kernel method for abelian grp
          Info(InfoChain, 2, "Finding kernel of quotient group acting on",
                          " subspace of dimension ",
                          DimensionOfMatrixGroup(quo) );
	  # sets KernelOfMultiplicativeGeneralMapping(Homomorphism(quo))
          kernel := KernelOfHomQuotientGroup(quo); 
          # Now that we have the full kernel, make new ChainSubgroup(grp)
          ChainSubgroupByHomomorphism( Homomorphism(quo) );
          if IsTrivial(kernel) then return kernel;
          else return MakeHomChain( kernel );
          fi;
        fi;
    end );

#############################################################################
##
#M  MakeHomChain( <> )
##
##  We need IsFFEMatrixGroup, or we lose to IsFFEMatrixGroup and IsAbelian
##
InstallMethod( MakeHomChain, "for cyclic p-groups", true,
    [ IsGroup and IsFFEMatrixGroup and IsCyclic and IsPGroup ], 0,
    function( G )
        if IsUniformMatrixGroup( G ) or HasGeneratorOfCyclicGroup( G ) then
            return ChainSubgroupBySiftFunction( G, TrivialSubgroup(G),
                                                SiftFunction( G ) );
        else TryNextMethod(); return;
        fi;
    end );


#############################################################################
#############################################################################
##
##  Abelian matrix p-groups:
##
#############################################################################
#############################################################################

#############################################################################
##
#M  InvariantSubspaceOrCyclicGroup( <H> )
##
##  Lemma 4.4 of Luks reference:  returns proper invariant subspace
##     or return isomorphic cyclic group with GeneratorOfCyclicGroup
##     attribute and Size attribute set
##
InstallMethod( InvariantSubspaceOrCyclicGroup, "for abelian group", true,
    [ IsFFEMatrixGroup and IsAbelian ], 0,
    function( H )
        if Length( GeneratorsOfGroup(H) ) = 1 then
            SetIsCyclicWithSize( H, H.1, Order(H.1) );
            return InvariantSubspaceOrCyclicGroup( H );
        else TryNextMethod(); return;
        fi;
    end );
InstallMethod( InvariantSubspaceOrCyclicGroup, "for abelian p-group", true,
    [ IsFFEMatrixGroup and IsAbelian and IsPGroup ], 0,
    function( H )
        IsCharacteristicMatrixPGroup( H );  # Have GAP decide true or false
        return InvariantSubspaceOrCyclicGroup( H );
    end );
InstallMethod( InvariantSubspaceOrCyclicGroup, "for trivial group", true,
    [ IsTrivial ], 0, H -> H );
InstallMethod( InvariantSubspaceOrCyclicGroup, "for abelian char. p-group",true,
    [ IsFFEMatrixGroup and IsAbelian and IsPGroup and IsCharacteristicMatrixPGroup ], 0,
    function( H )
    local gen, gens, space;

    space := UnderlyingVectorSpace(H);
    for gen in GeneratorsOfGroup( H ) do
        # Must first test IsTrivial(space) due to bug in GAP-4r1
        if not IsTrivial(space) then
            space := Intersection2( space, FixedPointSpace( gen ) );
        fi;
    od;
    # This is because char(H) = p
    if space = TrivialSubspace( space ) then
        Error("This shouldn't occur in characteristic case.");
        SetIsCyclic(H,true);
        return H;
    fi;
    return space;
end );
##
##      This method is too long.  It should now be a short routine that
##      calls InvariantSubspaceOrUniformCyclicPGroup()
##      followed by SiftFunction() for cyclic matrix p-Group.  - Gene
##
InstallMethod( InvariantSubspaceOrCyclicGroup, "for abelian non-char. p-group",
    true,
    [ IsFFEMatrixGroup and IsAbelian and IsPGroup and IsNoncharacteristicMatrixPGroup ],
    0,
    function( H )
    local Horig, p, gens, tmp, h, k, h1, k1, ordH, ordK, h1inv,
          space, trivSpace, r, CopyGroup, MySetGeneratorsOfGroup;

 ##  NOTE:  ShallowCopy(G) silently refuses to make a copy of G.
 CopyGroup := function( G )
    local H;
    H := Group( GeneratorsOfGroup(G) );
    # This should SetPrimePGroup() for H
    UseIsomorphismRelation( G, H );
    return H;
 end;

 # We should not be doing this -- Scott.
 # Agreed.  The usage here is to pass in the "shell of a group", and
 # recursively add generators to the shell, to avoid the overhead of
 # destructively modifying a generator list, and constantly making
 # temporary groups based on it.  When this function is rewritten,
 # we can remove this.		-- Gene.
 MySetGeneratorsOfGroup :=
    function(G,gens) G!.GeneratorsOfMagmaWithInverses := gens; end;

    Horig := H;
    p := PrimePGroup( Horig );
    H := CopyGroup(Horig);
    # SET UP PROBLEM
    gens := GeneratorsOfGroup( H );
    tmp := Filtered( gens, g -> not IsOne(g) );
    if Length(tmp) < Length(gens) then
        gens := tmp;
        MySetGeneratorsOfGroup( H, gens );
    fi;
    if Length(gens) < 2 then
        if Length(gens) = 0 then SetIsTrivial( H, true );
        else SetIsCyclicWithSize( Horig, gens[1], Order(gens[1]) );
        fi;
        return InvariantSubspaceOrUniformCyclicPGroup( Horig );
    fi;
    h := gens[1];
    k := gens[2];
    ordH := Order(h);
    ordK := Order(k);
    if ordH < ordK then
        tmp := h;
        h := k;
        k := tmp;
        tmp := ordH;
        ordH := ordK;
        ordK := tmp;
    fi;
    # ALGORITHM
    h1 := h^(ordH/p);
    k1 := k^(ordK/p);
    space := FixedPointSpace( h1 );
    trivSpace := TrivialSubspace(space);
    if trivSpace <> space then return space; fi;
    h1inv := h1^(-1);
    for r in [0..p-1] do
        space := FixedPointSpace( h1inv^r*k1 );
        if space <> trivSpace then
            if space <> UnderlyingVectorSpace(H) then
                return space;
            else break;
            fi;
        fi;
    od;
    if space = trivSpace then Error("internal error: no FixedPointSpace"); fi;
    if k1 <> h1^r then Error("internal error:  k1 <> h1^r"); fi;
    tmp := h^((-r)*ordH/ordK) * k;
    if IsOne( tmp ) then
        gens := Concatenation( [h], gens{[3..Length(gens)]} );
    else gens := Concatenation( [h, tmp], gens{[3..Length(gens)]} );
    fi;
    # Change generating set of this group:
    MySetGeneratorsOfGroup( H, gens );
    space := InvariantSubspaceOrCyclicGroup( H );
    return space;
    if IsVectorSpace(space) then return space;
    else # else space is really a cyclic group.
      SetIsCyclicWithSize( Horig, GeneratorOfCyclicGroup(space), Size(space) );
      return Horig;
    fi;
    # return InvariantSubspaceOrCyclicGroup( AsSubgroup( H, Group(gens) ) );
end );

#############################################################################
##
#M  InvariantSubspaceOrUniformCyclicPGroup( <G> )
##
##  Matrix group is uniform if fixed point space of every element
##    is either the trivial space or the entire space.
##
InstallMethod(InvariantSubspaceOrUniformCyclicPGroup, "for matrix group", true,
[IsFFEMatrixGroup], 0,
    function( G )
    local p, gens, g, space;
    if not (IsFFEMatrixGroup and IsCyclic and IsPGroup) then
        Error("implemented only for cyclic matrix p-groups");
    fi;
    p := PrimePGroup(G);
    if p=fail then
        # the group is trivial
        SetIsUniformMatrixGroup( G, true );
        return G;
    fi;
    if HasGeneratorOfCyclicGroup(G) then gens := [ GeneratorOfCyclicGroup(G) ];
    else gens := GeneratorsOfGroup(G);
    fi;
    for g in gens do
        if not IsOne(g) then
            space := FixedPointSpace( g^(Order(g)/p) );
            if space <> UnderlyingVectorSpace(g)
               and Dimension(space) <> 0 then
                return FixedPointSpace( g^(Order(g)/p) );
            fi;
        fi;
    od;
    SetIsUniformMatrixGroup( G, true );
    return G;
end);

#############################################################################
##
#M  SiftFunction( <> )
##
##  For group of size $p^r$, performs in $r p$ multiplies and 
##     uses O(1) space.  Alternative is $r\log p$ multiplies
##     storing $r\log p$ matrices via Schreier tree.
##  Comment below shows how to turn it into $r \log p$ multiplies
##     while storing $\log p$ vectors.
##
InstallMethod( SiftFunction, "for cyclic matrix p-groups", true,
    [ IsGroup and IsFFEMatrixGroup and IsCyclic and IsPGroup ], 0,
    function( H )
    local gens, cyclicGen, ordCyclicGen, p,
        cyclicGen1, cyclicGen1inv, space, 
	underlyingVectorSpace, trivSpace, SiftFnc;
    gens := Filtered( GeneratorsOfGroup(H), g -> not IsOne(g) );
    if Length(gens) = 0 then return k -> k; fi;
    cyclicGen := GeneratorOfCyclicGroup( H );
    ordCyclicGen := Order( cyclicGen );
    p := PrimePGroup( H );
    underlyingVectorSpace := UnderlyingVectorSpace( H );
    trivSpace := TrivialSubspace( underlyingVectorSpace );
    #if not IsUniformMatrixGroup( H ) then Error("not uniform matrix grp"); fi;
        cyclicGen1 := cyclicGen^(ordCyclicGen/p);
        # space := FixedPointSpace( cyclicGen1 );
        # if space = trivSpace then 
        #     Error("cyclicGen is identity");
        # elif space <> underlyingVectorSpace then
        #     Error("matrix group is not uniform");
        # fi;
        cyclicGen1inv := cyclicGen1^(-1);
    # PRODUCE SIFT FUNCTION
    SiftFnc := function( k )
        local ordK, space, k1, tmp, r;
        ordK := Order(k);
        if ordK = 1 then return k; fi; # k is identity
        if ordCyclicGen mod ordK <> 0 then return k; fi; # k not in group
        k1 := k^(ordK/p);
        tmp := k1;
        # Saving image of base vector of < cyclicGen > would
        #     allow one to quickly find r.  So, this part could
        #     use our Random Schreier Sims code.
        for r in [0..p-1] do
            if IsOne(tmp) then break; fi;
            # NOW:  tmp = cyclicGen1inv^r * k1
            # space := FixedPointSpace( tmp );
            # if space <> trivSpace then
            #     if space = underlyingVectorSpace then break;
            #     else return k; # H uniform.  So tmp not in H
            #     fi;
            # fi;
            tmp := tmp * cyclicGen1inv;
        od;
        # if space = trivSpace then Error("cyclicGen1 is identity"); fi;
        if not IsOne(tmp) then return k; fi;
        # NOW:  cyclicGen1^r = k1
        tmp := cyclicGen^((-r)*ordCyclicGen/ordK) * k;
        # NOW:  Order(k)/Order(tmp) >= p
        if IsOne(tmp) then return tmp;
        else return SiftFnc(tmp);
        fi;
    end;
    return SiftFnc;
end );


#############################################################################
#############################################################################
##
##  Normal closure and Kernel of quotient group:
##
#############################################################################
#############################################################################

##  Create normal closure with a chain.
NormalClosureByChain := function(grp, subgp)
    local gens, h, g, count, tmp, x;
    if IsTrivial(subgp) then return subgp; fi;
    if IsAbelian(grp) then return subgp; fi;
    # Take randomized generators of normal closure
    subgp := SubgroupNC( grp,
                         List([1..5], i->RandomNormalSubproduct(grp,subgp)) );
    #Test if subgp is cyclic:
    # Routines about should be used to add more effic. method for IsCyclic(G)
    #   for GAP matrix groups.
    # This part can be slow, because GAP may use NiceObject() to compute Size()
    if HasSize(subgp) then
        g := First( GeneratorsOfGroup(subgp), h->Order(h)=Size(subgp) );
    else
        #This part can be simplified when NiceObject() isn't default.
        g := fail;
        for x in GeneratorsOfGroup(subgp) do
            tmp := Group([x]);
            MakeHomChain(tmp);
            if First(GeneratorsOfGroup(subgp), h->not IsOne(Sift(tmp,h)))
               = fail then
                g := x;
                break;
            fi;
        od;
    fi;
    if g <> fail then SetGeneratorOfCyclicGroup( subgp, g ); fi;
    # Form subgroup chain
    MakeHomChain(subgp);
    # Deterministically test it and extend it
    gens := List(GeneratorsOfGroup(subgp));
    for h in gens do
        for g in GeneratorsOfGroup(grp) do
            #Current GAP default for IN can call NiceObject()
            if not IsOne(Sift(subgp,h^g)) then
            # if not h^g in subgp then
		Add( gens, h^g );
                subgp := Group(gens);
                MakeHomChain(subgp);
            fi;
        od;
    od;
    return subgp;
end;

#############################################################################
##
#M  KernelOfHomQuotientGroup( <> )
##
##This should be generally useful in GAP.  It finds the kernel of
##   any homomorphism to an abelian group.
##
##This would be more efficient if we picked out a non-redundant
##   (independent) generating set for the abelian group, and then
##   used commutator relations on only those.  GAP has function
##   IndependentGeneratorsOfAbelianGroup() of unknown efficiency.
##   Or, we could program it ourselves.
##
InstallMethod( KernelOfHomQuotientGroup,
        "for abelian quotient group via presentation", true,
        [ IsHomQuotientGroup and IsAbelian ], 0,
    function( quo )
        local indGenSet, gens, gens2, SiftFnc, hom, rels, srcGrp, kerGrp ;

        # if IsQuotientToAdditiveGroup(quo) then
        #     indGenSet := BasisOfHomCosetAddMatrixGroup(quo);
        #     gens2 := indGenSet.basis;
        #     SiftFnc := SiftVector(indGenSet.basis);
        #     rels := indGenSet.residue;
        # else Error("KernelOfMultiplicativeGeneralMapping() not implemented for this case.");
        # fi;
        # Append( rels, List( gens2, SiftFnc ) );
        # If all source groups of quo are abelian, this is unnec.
        # Append(rels, ListX( gens2, gens2,
        #                     function(g1,g2) return Comm(g1,g2); end ) );
        # if not ForAll(rels, IsOne) then
        #     Error("internal error: invalid relation of presentation");
        # fi;

        #gens := GeneratorsOfGroup(quo);
        #rels := List( gens, g -> Sift(quo,g) );
        #if not ForAll(rels, IsOne) then
        #    Error("internal error: invalid relation of presentation");
        #fi;
        #rels := List( rels, g -> SourceElt(quo,g) );
        #gens2 := List( gens2, g->SourceElt(g) );
        #Append(rels, ListX(gens2,gens2,function(g1,g2) return Comm(g1,g2);end));

        IsPGroup( quo ); # Have GAP check this.

        srcGrp := Source(Homomorphism(quo));
        # TrivialQuotientSubgroup is where the presentations are formed.
        kerGrp := TrivialQuotientSubgroup( quo );
        # gdc - can't use Source(kerGrp) here.  Note bug in quotientgp.gi
        kerGrp := Group(List(GeneratorsOfGroup(kerGrp), g->SourceElt(g)));
        kerGrp := NormalClosureByChain( srcGrp, kerGrp );
        if not IsTrivial(kerGrp) then
            kerGrp := Group( Filtered( GeneratorsOfGroup(kerGrp),
                                       g -> not IsTrivialHomCoset(g) ) );
        fi;
        UseSubsetRelationNC(srcGrp,kerGrp);
        hom := Homomorphism(quo);
        SetKernelOfMultiplicativeGeneralMapping( hom, kerGrp );
        if IsTrivial(kerGrp) then Info(InfoChain, 2,
                                         "  (kernel is trivial)\n");
        fi;

        if HasSize(kerGrp) and HasSize(srcGrp) and 
           Size(kerGrp) = Size(srcGrp) then
            Error("internal error:  kernel not smaller");
        fi;
        return kerGrp;
end );

##  InstallMethod( KernelOfMultiplicativeGeneralMapping, "Monte Carlo algorithm for quotient group", true,
##          [ IsTransvByHomomorphism ], 0,
##      function( transv )
##      local hom, G, i, gens;
##      hom := Homomorphism(transv);
##      G := Source( hom );
##      gens := [];
##      for i in [1..15] do  # HACK
##          Add(gens, SiftOneLevel( transv, PseudoRandom(G) ) );
##      od;
##      # ChainSubgroup(G) is already kernel of hom;  Can set relations now.
##      if not HasKernelOfMultiplicativeGeneralMapping(hom) then
##          Error("internal error:  missing kernel to hom");
##      fi;
##      MySetGeneratorsOfGroup( KernelOfMultiplicativeGeneralMapping(hom), gens );
##      UseSubsetRelation( Source(hom), KernelOfMultiplicativeGeneralMapping(hom) );
##      UseFactorRelation( Source(hom), KernelOfMultiplicativeGeneralMapping(hom), Image(hom) );
##      UseIsomorphismRelation( Image(hom), QuotientGroup(transv) );
##      return KernelOfMultiplicativeGeneralMapping(hom);
##  end);



#############################################################################
#############################################################################
##
##  Cyclic matrix p-groups:
##  Exports:  Size, IN, Random, Enumerator, Sift
##  Internal:  GeneratorOfCyclicGroup, TrivialQuotientSubgroup (presentation)
##
#############################################################################
#############################################################################
        
#GeneratorOfCyclicGroup() only implemented currently for cases
#  needed by solmxgrp.gi;  solmxgrp.gi purposely doesn't compute
#  it in the general case --- because it is sometimes more efficient
#  to find an invariant subspace and recurse.
CanFindGeneratorOfCyclicGroup := function(G)
    if HasGeneratorOfCyclicGroup(G) then return true;
    elif Length(GeneratorsOfGroup(G)) = 1 then return true;
    elif IsFFEMatrixGroup(G) and HasIsCyclic(G) and IsCyclic(G) and
      HasIsPGroup(G) and IsPGroup(G) and
       IsUniformMatrixGroup(G) and IsNoncharacteristicMatrixPGroup(G) then
        return true;
    else return false;
    fi;
end;

#############################################################################
##
#M  Size( <G> )
##
InstallMethod( Size, "for cyclic matrix p-group", true,
        [ IsFFEMatrixGroup and IsCyclic and IsPGroup ], NICE_FLAGS+10,
        function (G)
            if CanFindGeneratorOfCyclicGroup(G) then
                return Order( GeneratorOfCyclicGroup( G ) );
            else TryNextMethod(); return;
            fi;
        end );
InstallMethod( Size, "for cyclic 1-gen. group", true,
        [ IsGroup and IsCyclic and HasGeneratorOfCyclicGroup ], NICE_FLAGS+10,
        G -> Order( GeneratorOfCyclicGroup( G ) ) );

#############################################################################
##
#M  Random( <G> )
##
InstallMethod( Random, "for cyclic matrix p-group", true,
        [ IsFFEMatrixGroup and IsCyclic and IsPGroup ], 0,
        function (G)
            if CanFindGeneratorOfCyclicGroup(G) then
                return GeneratorOfCyclicGroup( G )^Random([1..Size(G)]);
            else return; TryNextMethod();
            fi;
        end );

#############################################################################
##
#M  TrivialQuotientSubgroup( <G> )
##
##  Works on any group, but IsOne(gen) for all generators, gen
##  Useful for SourceElt(gen) if group is a quotient group.
##
InstallMethod( TrivialQuotientSubgroup,
        "for cyclic matrix p-group via presentation (assuming sift fnc)", true,
        [ IsFFEMatrixGroup and IsCyclic and IsPGroup ], 0,
        G -> SubgroupNC( G,
                # NOTE: Sift(G,g) = Sift(G)(g).  Should pre-compute Sift(G).
                Concatenation( List( GeneratorsOfGroup( G ), g->Sift(G,g) ),
                               # presentation for independent generators
                               [GeneratorOfCyclicGroup( G )^Size(G)] )));

#############################################################################
##
#M  Enumerator( <G> )
##
InstallMethod( Enumerator, "for cyclic matrix p-group", true,
        [ IsFFEMatrixGroup and IsCyclic and IsPGroup ], NICE_FLAGS,
        function (G)
          if CanFindGeneratorOfCyclicGroup(G) then
              return List( [0..Size(G)-1], i->GeneratorOfCyclicGroup(G)^i );
          else TryNextMethod(); return;
          fi;
        end );

#############################################################################
##
#M  IN( <G> )
##
InstallMethod( IN, "for cyclic matrix p-group", true,
        [ IsMultiplicativeElementWithInverse,
          IsFFEMatrixGroup and IsCyclic and IsPGroup ], NICE_FLAGS,
        function(g, G) return Sift(G, g) = One(G); end );

##
##  These next two do all the real work:
##

#############################################################################
##
#M  Sift( <G> )
##
InstallMethod( Sift, "for cyclic matrix p-group", true,
        [ IsFFEMatrixGroup and IsCyclic and IsPGroup and HasGeneratorOfCyclicGroup,
          IsMultiplicativeElementWithInverse ], 0,
        function(G, g) return SiftFunction(G)(g); end );


#############################################################################
#############################################################################
##
##  General abelian matrix group: (certain operations only)
##
#############################################################################
#############################################################################

##  gens must be IndependentAbelianGenerators
EnumerateIndependentAbelianProducts := function( G, gens )
        local first, rest;
        if Length(gens) = 0 then return One(G); fi;
        first := List( [0..Order(gens[1])-1], i->(gens[1])^i );
        if Length(gens) = 1 then return first;
        else
            rest := EnumerateIndependentAbelianProducts
                              ( G, gens{[2..Length(gens)]} );
            return ListX( first, rest, function(h,g) return h*g; end );
        fi;
end;

#############################################################################
##
#M  Enumerator( <G> )
##
InstallMethod( Enumerator, "for quotient to additive group", true,
        [ IsGroup and IsFFEMatrixGroup and IsQuotientToAdditiveGroup ],
        2*SUM_FLAGS+46,  # need to beat "system getter"
        G -> EnumerateIndependentAbelianProducts
                    (G, BasisOfHomCosetAddMatrixGroup(G).basis) );

#############################################################################
##
#M  Sift( <G>, <g> )
##
InstallMethod( Sift, "for quotient to additive group", true,
        [ IsGroup and IsFFEMatrixGroup and IsQuotientToAdditiveGroup,
          IsHomCosetToAdditiveElt ], 0,
        function(G, g) return SiftFunction(G)(g); end );

#############################################################################
##
#M  TrivialQuotientSubgroup( <G> )
##
##  Works on any group, but primarily useful for quotient groups
##  IsOne(gen) for all generators, gen,
##    but SourceElt(gen) is non-trivial for a general quotient group.
##
InstallMethod( TrivialQuotientSubgroup,
        "for abelian matrix group via presentation (assuming Sift fnc)", true,
        [ IsFFEMatrixGroup and IsAbelian ], 0,
    function(G)
        local gens;
        gens := IndependentGeneratorsOfAbelianMatrixGroup(G);
        return SubgroupNC( G,
                Concatenation( List( GeneratorsOfGroup(G), g->Sift(G,g) ),
                               # presentation for independent generators
                               List( gens, g->g^Order(g) ),
                               ListX( gens, gens,
				      function(g1,g2) return Comm(g1,g2); end )
                             ));
end );


#############################################################################
#############################################################################
##
##  Additive abelian group:
##
#############################################################################
#############################################################################

#############################################################################
##
#M  TrivialQuotientSubgroup( <quo> )
##
InstallMethod( TrivialQuotientSubgroup,
        "for additive quotient group via presentation", true,
        [ IsQuotientToAdditiveGroup ], 0,
        function( quo )
        local indGenSet, gens, gens2, SiftFnc, hom, rels, srcGrp, kerGrp ;

  if not ForAll(GeneratorsOfGroup(quo), g->ImageElm(Homomorphism(g),SourceElt(g))
                         = ImageElt(g)) then
       Error("bad gens of grp");
  fi;
        indGenSet := BasisOfHomCosetAddMatrixGroup(quo);
        gens2 := indGenSet.basis;
  if not ForAll(gens2, g->ImageElm(Homomorphism(g),SourceElt(g))
                         = ImageElt(g)) then
       Error("bad gens2");
  fi;
        SiftFnc := SiftVector(indGenSet.basis);
        rels := indGenSet.residue;
        if not IsMutable(rels) then rels := List(rels); fi;
  if not ForAll(rels, g->ImageElm(Homomorphism(g),SourceElt(g))
                         = ImageElt(g)) then
       Error("bad residue");
  fi;
        Append( rels, List( gens2, g -> g^Order(g) ) );
  if not ForAll(rels, g->ImageElm(Homomorphism(g),SourceElt(g))
                         = ImageElt(g)) then
       Error("bad order");
  fi;
        Append( rels, List( gens2, SiftFnc ) );
        # If all source groups of quo are abelian, this is unnec.
        Append(rels, ListX( gens2, gens2,
                            function(g1,g2) return Comm(g1,g2); end ) );
        if not ForAll(rels, IsOne) then
            Error("internal error: invalid relation of presentation");
        fi;
        return SubgroupNC(quo, rels);
    end );

#############################################################################
#############################################################################
##
##  Nilpotent matrix groups:
##
#############################################################################
#############################################################################

##  Always try SizeUpperBound first.

#############################################################################
##
#M  CanFindNilpotentClassTwoElement( <G> )
##
InstallMethod( CanFindNilpotentClassTwoElement, "compute elt or fail", true,
    [ IsGroup ], 0,
function(G)
    local gens, g, count, i;
    gens := GeneratorsOfGroup( G );
    g := First(gens, h -> not IsInCenter(G,h));
    SetIsAbelian(G, g = fail);
    if IsAbelian(G) then return false; fi;
    # gdc -
    # Want max. length derived series for _nilpotent_ group of a given size.
    # There should be much better bound than LogInt(SizeUpperBound(G),2).
    # I can look it up some other time.
    for count in [1..LogInt(SizeUpperBound(G),2)] do
        i := PositionProperty(gens, h -> not IsInCenter(G,Comm(g,h)));
        if i = fail then
            SetNilpotentClassTwoElement(G,g);
            return true;
        else g := Comm(g,gens[i]);
        fi;
    od;
    return false;
end );

#############################################################################
##
#M  NilpotentClassTwoElement( <G> )
##
InstallMethod( NilpotentClassTwoElement,
    "by calling CanFindNilpotentClassTwoElement()", true, [ IsGroup ], 0,
function(G)
    if CanFindNilpotentClassTwoElement(G) then
        return NilpotentClassTwoElement(G);
    else TryNextMethod(); return;
    fi;
end );

#############################################################################
##
#F  NaturalHomomorphismByNilpotentClassTwoElement( <G> )
##
InstallGlobalFunction( NaturalHomomorphismByNilpotentClassTwoElement,
function(G)
    local elt;
    elt := NilpotentClassTwoElement(G);
    if elt = fail then return Error("abelian or not nilpotent"); fi;
    return GroupHomomorphismByFunction
       ( G, Group( List( GeneratorsOfGroup(G), h->Comm(h,elt) ) ),
         h->Comm(h,elt) );
end );

#############################################################################
##
#F  ManageableQuotientOfNilpotentGroup( <G> )
##

ManageableQuotientOfNilpotentGroup := function( G )
            local hom, quo;
            hom := NaturalHomomorphismByNilpotentClassTwoElement(G);
            ChainSubgroupByHomomorphism( hom );
            quo := QuotientGroup(TransversalOfChainSubgroup(G));
            IsAbelian(quo);  # Tell GAP quo is abelian in case not propagated.
            return quo;
        end;
        
        
#############################################################################
##
#M  MakeHomChain( <G> )
##

InstallMethod( MakeHomChain, "for nilpotent group", true,
        [ IsGroup and IsNilpotentGroup ], 0,
    function( G )
        local quo, kernel;
        if IsAbelian(G) then return MakeHomChain(G); fi;
        quo := ManageableQuotientOfNilpotentGroup(G);
        Info(InfoChain, 2, "Finding kernel of homomorphism by",
                           "nilpotent class 2 elt");
        IsAbelian(quo); # Special Kernel method for abelian grp
        MakeHomChain(quo);
        # sets Kernel(Homomorphism(quo))
        kernel := KernelOfHomQuotientGroup(quo);
        # Now that we have the full kernel, make new ChainSubgroup(grp)
        ChainSubgroupByHomomorphism( Homomorphism(quo) );
        if IsTrivial(kernel) then return kernel;
        else return MakeHomChain( kernel );
        fi;
    end );

#E
