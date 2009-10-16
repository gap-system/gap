#############################################################################
##
#W  glzmodmz.gi                    GAP library                    Stefan Kohl
##
#H  @(#)$Id: glzmodmz.gi,v 1.2 2002/09/05 14:42:08 gap Exp $
##
#Y  (C) 2001 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.glzmodmz_gi :=
    "@(#)$Id: glzmodmz.gi,v 1.2 2002/09/05 14:42:08 gap Exp $";

#############################################################################
##
#F  SizeOfGLdZmodmZ( <d>, <m> ) . . . . . .  Size of the group GL(<d>,Z/<m>Z)
##
##  Computes the order of the group `GL( <d>, Integers mod <m> )' for
##  positive integers <d> and <m> > 1.
##
InstallGlobalFunction( SizeOfGLdZmodmZ,

  function ( d, m )

    local  size, pow, p, q, k, i;

    if   not (IsPosInt(d) and IsInt(m) and m > 1)
    then Error("GL(",d,",Integers mod ",m,") is not a well-defined group, ",
               "resp. not supported.\n");
    fi;
    size := 1;
    for pow in Collected(Factors(m)) do
      p := pow[1]; k := pow[2]; q := p^k;
      size := size * Product([d*k - d .. d*k - 1], i -> q^d - p^i);
    od;
    return size;
  end );

#############################################################################
##
#M  SpecialLinearGroupCons( IsNaturalSL, <d>, Integers mod <m> )
##
InstallMethod( SpecialLinearGroupCons,
               "natural SL for dimension and residue class ring",
               [ IsMatrixGroup and IsFinite, IsPosInt,
                 IsRing and IsFinite and IsZmodnZObjNonprimeCollection ],

  function ( filter, d, R )

    local  G, gens, g, m, T;

    m := Size(R);
    if R <> Integers mod m or m = 1 then TryNextMethod(); fi;
    if IsPrime(m) then return SpecialLinearGroupCons(IsMatrixGroup,d,m); fi;
    if   d = 1
    then gens := [IdentityMat(d,R)];
    else gens := List(GeneratorsOfGroup(SymmetricGroup(d)),
                      g -> PermutationMat(g,d) * One(R));
         for g in gens do
           if DeterminantMat(g) <> One(R) then g[1] := -g[1]; fi;
         od;
         T := IdentityMat(d,R); T[1][2] := One(R); Add(gens,T);
    fi;
    G := GroupByGenerators(gens);
    SetName(G,Concatenation("SL(",String(d),",Z/",String(m),"Z)"));
    SetIsNaturalSL(G,true);
    SetDimensionOfMatrixGroup(G,d);
    SetIsFinite(G,true);
    SetSize(G,SizeOfGLdZmodmZ(d,m)/Phi(m));
    return G;
  end );

#############################################################################
##
#M  GeneralLinearGroupCons( IsNaturalGL, <d>, Integers mod <m> )
##
InstallMethod( GeneralLinearGroupCons,
               "natural GL for dimension and residue class ring",
               [ IsMatrixGroup and IsFinite, IsPosInt,
                 IsRing and IsFinite and IsZmodnZObjNonprimeCollection ],

  function ( filter, d, R )

    local  G, gens, g, m, T, D;

    m := Size(R);
    if R <> Integers mod m or m = 1 then TryNextMethod(); fi;
    if IsPrime(m) then return GeneralLinearGroupCons(IsMatrixGroup,d,m); fi;
    if   d = 1
    then gens := List(GeneratorsOfGroup(Units(R)), g -> [[g]]);
    else gens := List(GeneratorsOfGroup(SymmetricGroup(d)),
                      g -> PermutationMat(g,d) * One(R));
         T := IdentityMat(d,R); T[1][2] := One(R); Add(gens,T);
         for g in GeneratorsOfGroup(Units(R)) do
           D := IdentityMat(d,R); D[1][1] := g; Add(gens,D);
         od;
    fi;
    G := GroupByGenerators(gens);
    SetName(G,Concatenation("GL(",String(d),",Z/",String(m),"Z)"));
    SetIsNaturalGL(G,true);
    SetDimensionOfMatrixGroup(G,d);
    SetIsFinite(G,true);
    SetSize(G,SizeOfGLdZmodmZ(d,m));
    return G;
  end );

#############################################################################
##
#E  glzmodmz.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
