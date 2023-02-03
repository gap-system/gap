#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler, Frank Lübeck, Stefan Kohl.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the operations for matrix groups over finite field.
##


#############################################################################
##
#M  FieldOfMatrixGroup( <ffe-mat-grp> )
##
InstallMethod( FieldOfMatrixGroup,
    true,
    [ IsFFEMatrixGroup ],
    0,

function( grp )
    local   gens;

    gens := GeneratorsOfGroup(grp);
    if Length(gens)=0 then
      return FieldOfMatrixList([One(grp)]);
    else
      return FieldOfMatrixList(gens);
    fi;
end );

#############################################################################
##
#M  FieldOfMatrixList
##
InstallMethod(FieldOfMatrixList,"finite field matrices",true,
  [IsListOrCollection and IsFFECollCollColl],0,
function(list)
local   deg,  mat,  char;
  if Length(list)=0 then Error("list must be nonempty");fi;
  deg  := 1;
  for mat in list do
    deg := LcmInt( deg, DegreeFFE(mat) );
  od;
  char := Characteristic(list[1]);
  return GF(char^deg);
end);

#############################################################################
##
#M  DefaultScalarDomainOfMatrixList
##
InstallMethod(DefaultScalarDomainOfMatrixList,"finite field matrices",true,
  [IsListOrCollection and IsFFECollCollColl],0,
function(list)
local   deg,  mat,  char,  B;
  if Length(list)=0 then Error("list must be nonempty");fi;
  if ForAll( list, HasBaseDomain ) then
    B:= BaseDomain( list[1] );
    if ForAll( list, x -> B = BaseDomain( x ) ) then
      return B;
    fi;
  fi;

  deg  := 1;
  for mat in list do
    # treat compact matrices quickly
    if IsGF2MatrixRep(mat) then
      deg:=deg; # always in
    elif Is8BitMatrixRep(mat) then
      deg:=LcmInt( deg, Length(FactorsInt(Q_VEC8BIT(mat![2]))));
    else
      deg := LcmInt( deg, DegreeFFE(mat) );
    fi;
  od;
  char := Characteristic(list[1]);
  return GF(char^deg);
end);

BindGlobal("NonemptyGeneratorsOfGroup",function(grp)
local l;
   l:=GeneratorsOfGroup(grp);
   if Length(l)=0 then l:=[One(grp)]; fi;
   return l;
end);

#############################################################################
##
#M  IsNaturalGL( <ffe-mat-grp> )
##
InstallMethod( IsNaturalGL,
    "size comparison",
    true,
    [ IsFFEMatrixGroup and IsFinite ],
    0,

function( grp )
  return MTX.IsAbsolutelyIrreducible(
    GModuleByMats(NonemptyGeneratorsOfGroup(grp),DefaultFieldOfMatrixGroup(grp))) and
   Size( grp ) = Size( GL( DimensionOfMatrixGroup( grp ),
                  Size( FieldOfMatrixGroup( grp ) ) ) );
end );

InstallMethod( IsNaturalSL,
    "size comparison",
    true,
    [ IsFFEMatrixGroup and IsFinite ],
    0,

function( grp )
local gen, d, f;
  f := FieldOfMatrixGroup( grp );
  d := DimensionOfMatrixGroup( grp );
  gen := GeneratorsOfGroup( grp );
  return MTX.IsAbsolutelyIrreducible(
    GModuleByMats(NonemptyGeneratorsOfGroup(grp),DefaultFieldOfMatrixGroup(grp))) and
    ForAll(gen, x-> DeterminantMat(x) = One(f))
            and Size(grp) = Size(SL(d, Size(f)));
end );


#############################################################################
##
#M  NiceMonomorphism( <ffe-mat-grp> )
##
MakeThreadLocal("FULLGLNICOCACHE"); # avoid recreating same homom. repeatedly
FULLGLNICOCACHE:=[];
InstallGlobalFunction( NicomorphismFFMatGroupOnFullSpace, function( grp )
    local   field,  dim,  V,  xset,  nice;

    field := FieldOfMatrixGroup( grp );
    dim   := DimensionOfMatrixGroup( grp );

    #check cache
    V:=Size(field);
    nice:=First(FULLGLNICOCACHE,x->x[1]=V and x[2]=dim);
    if nice<>fail then return nice[3];fi;

    if not (HasIsNaturalGL(grp) and IsNaturalGL(grp)) then
      grp:=GL(dim,field); # enforce map on full GL
    fi;
    V     := field ^ dim;
    xset := ExternalSet( grp, V );


    # STILL: reverse the base to get point sorting compatible with lexicographic
    # vector arrangement
    SetBaseOfGroup( xset, One( grp ));
    nice := ActionHomomorphism( xset,"surjective" );
    SetIsInjective( nice, true );
    if not HasNiceMonomorphism(grp) then
      SetNiceMonomorphism(grp,nice);
    fi;
    # because we act on the full space we are canonical.
    SetIsCanonicalNiceMonomorphism(nice,true);
    if Size(V)>10^5 then
      # store only one big one and have it get thrown out quickly
      FULLGLNICOCACHE[1]:=[Size(field),dim,nice];
    else
      if Length(FULLGLNICOCACHE)>4 then
        FULLGLNICOCACHE:=FULLGLNICOCACHE{[2..5]};
      fi;
      Add(FULLGLNICOCACHE,[Size(field),dim,nice]);
    fi;

    return nice;
end );

InstallMethod( NiceMonomorphism, "falling back on GL", true,
    [ IsFFEMatrixGroup and IsFinite ], 0,
function( grp )
local tt;
  # is it GL?
  if (HasIsNaturalGL( grp ) and IsNaturalGL( grp ))
      or (HasIsNaturalSL( grp ) and IsNaturalSL( grp )) then
    return NicomorphismFFMatGroupOnFullSpace(grp);
  fi;

  # is the GL domain small enough in comparison to the group to simply use it?
  tt:=2000;
  if HasSize(grp) and Size(grp)<tt then
    tt:=Size(grp);
  fi;
  if IsTrivial(grp)
     or Size(FieldOfMatrixGroup(Parent(grp)))^DimensionOfMatrixGroup(grp)>tt
         then
    # if the permutation image would be too large, compute the orbit.
    TryNextMethod();
  fi;
  return NicomorphismFFMatGroupOnFullSpace( GL( DimensionOfMatrixGroup( grp ),
                  Size( FieldOfMatrixGroup( Parent(grp) ) ) ) );
end );

#############################################################################
##
#M  ProjectiveActionOnFullSpace(<G>,<f>,<n>)
##
InstallGlobalFunction(ProjectiveActionOnFullSpace,function(g,f,n)
local o;
  # as the groups are large, we can take all normed vectors
  o:=NormedRowVectors(f^n);
  o:=Set(o, r -> ImmutableVector(f, r));
  return Action(g,o,OnLines);
end);

#############################################################################
##
#M  Size( <general-linear-group> )
##
InstallMethod( Size,
    "general linear group",
    true,
    [ IsFFEMatrixGroup and IsFinite and IsNaturalGL ],
    0,

function( G )
    local   n,  q,  size,  qi,  i;

    n := DimensionOfMatrixGroup(G);
    q := Size( FieldOfMatrixGroup(G) );
    size := q-1;
    qi   := q;
    for i  in [ 2 .. n ]  do
        qi   := qi * q;
        size := size * (qi-1);
    od;
    return q^(n*(n-1)/2) * size;
end );

InstallMethod(Size,"natural SL",true,
  [IsFFEMatrixGroup and IsNaturalSL and IsFinite],0,
function(G)
local q,n,size,i,qi;
  n:=DimensionOfMatrixGroup(G);
  q:=Size(FieldOfMatrixGroup(G));

  size := 1;
  qi   := q;
  for i in [ 2 .. n ] do
    qi   := qi * q;
    size := size * (qi-1);
  od;
  return q^(n*(n-1)/2) * size;

end);

InstallMethod( \in, "general linear group", IsElmsColls,
    [ IsMatrix, IsFFEMatrixGroup and IsFinite and IsNaturalGL ], 0,
    function( mat, G )
    return     Length( mat ) = Length( mat[ 1 ] )
           and Length( mat ) = DimensionOfMatrixGroup( G )
           and ForAll( mat, row -> IsSubset( FieldOfMatrixGroup( G ), row ) )
           and Length( mat ) = RankMat( mat );
end );

InstallMethod( \in, "special linear group", IsElmsColls,
    [ IsMatrix, IsFFEMatrixGroup and IsFinite and IsNaturalSL ], 0,
    function( mat, G )
    return     Length( mat ) = Length( mat[ 1 ] )
           and Length( mat ) = DimensionOfMatrixGroup( G )
           and ForAll( mat, row -> IsSubset( FieldOfMatrixGroup( G ), row ) )
           and Length( mat ) = RankMat( mat )
           and DeterminantMat(mat)=One(FieldOfMatrixGroup( G ));
end );


#############################################################################
##
#F  SizePolynomialUnipotentClassGL( <la> ) . . . . . . centralizer order of
#F  unipotent elements in GL_n( q )
##
##  <la> must be a partition of the natural number n.
##
##  This function returns a  pair [coefficient list, valuation] defining a
##  polynomial over the integers, having the following property: The order
##  of the centralizer of a unipotent element in GL_n(q), q a prime power,
##  with Jordan block sizes given by <la>, is the value of this polynomial
##  at q.
##
BindGlobal( "SizePolynomialUnipotentClassGL", function(la)
    local   lad,  n,  nla,  ri,  tmp,  phila,  i,  a;

    lad := AssociatedPartition(la);
    n := Sum(la);
    nla := Sum(lad, i->i*(i-1)/2);
    ri := List([1..Maximum(la)], i-> Number(la, x-> x=i));

## the following should be
##    T := Indeterminate(Rationals);
##    phila := Product(Concatenation(List(ri,
##               r-> List([1..r], j-> (1-T^j)))));
##    return T^(n+2*nla)*Value(phila,1/T);
##    but for now (or ever?) we avoid polynomials

    tmp := Concatenation(List(ri, r-> [1..r]));
    phila := [1];
    for i in tmp do
        a := 0*[1..i+1];
        a[1] := 1;
        a[i+1] := -1;
        phila := ProductCoeffs(phila, a);
    od;
    return [Reversed(phila), n+2*nla-Length(phila)+1];
end );

#############################################################################
##
#M  ConjugacyClassesOfNaturalGroup( <G> )
##
InstallGlobalFunction( ConjugacyClassesOfNaturalGroup,
function( G, flag )
  local   mycartesian,  fill,  myval, pols,  nrpols,  pairs,
          types,  a,  a2,  pos,  i,  tup,  arr,  mat,  cen,  b,
          c, cl, powerpol, one, n, q, cls, new, o, m, rep, gcd;

  # to handle single argument
  mycartesian := function(arg)
    if Length(arg[1]) = 1 then
      return List(arg[1][1], x-> [x]);
    else
      return Cartesian(arg[1]);
    fi;
  end;

  # small helper
  fill := function(l, pos, val)
    l := ShallowCopy(l);
    l{pos} := val;
    return l;
  end;

  # since polynomials are just lists of coefficients
  powerpol := function(c, r)
    local   pr,  i;
    if r=1 then
      return c;
    else
      pr := c;
      for i in [2..r] do
        pr := ProductCoeffs(pr, c);
      od;
      return pr;
    fi;
  end;

  # Value for polynomials as [coeffs,val]
  myval := function(p, x)
    local   r,  c;
    r := 0*x;
    for c in Reversed(p[1]) do
      r := x*r+c;
    od;
    return r*x^p[2];
  end;

  # set up
  n := DimensionOfMatrixGroup( G );
  q := Size( FieldOfMatrixGroup( G ) );
  o := Size( G );
  cls := [];


  # irreducible polynomials up to degree n
  pols := List([1..n],
               i-> AllIrreducibleMonicPolynomialCoeffsOfDegree(i, q));

  # remove minimal polynomial of 0
  pols[1] := Difference(pols[1],[[0,1]*Z(q)^0]);
  nrpols := List(pols, Length);

  # parameters for semisimple class types
  # typ in types is of form [[m1,n1],...,[mr,nr]] standing for a centralizer
  # of type GL_m1(q^n1) x ... x GL_mr(q^nr)
  pairs := List([1..n], i->List(DivisorsInt(i), j-> [j,i/j]));
  types := Concatenation(List(Partitions(n), a-> mycartesian(pairs{a})));
  for a in types do Sort(a); od;

  # 'Reversed' to get central elements first
  types := Reversed(Set(types));

  for a in types do
    a2 := List(a,x->x[2]);
    pos := [];
    for i in Set(a2) do
      pos[i] := [];
    od;
    for i in [1..Length(a2)] do
      Add(pos[a2[i]], i);
    od;

    # find representatives of semisimple classes corresponding to type
    tup := [[]];
    for i in Set(a2) do
      arr := Arrangements([1..nrpols[i]], Length(pos[i]));
      tup := Concatenation(List(tup, b-> List(arr, c-> fill(b, pos[i], c))));
    od;

    # merge with 'a' to remove duplicates
    tup := List(tup, b-> List([1..Length(a)],
                     i-> Concatenation(a[i],[b[i]])));
    tup := Set(tup,Set);

    # now append partitions for distinguishing the unipotent parts
    tup := Concatenation(List(tup, a->
                   Cartesian(List(a,x->List(Partitions(x[1]),b->
                           Concatenation(x,[b]))))));
    Append(cls, tup);
  od;

  # in the sl-case
  if flag then
    rep := List([1..Gcd(q-1, n)-1], i-> IdentityMat(n, GF(q)));
    for i in [1..Gcd(q-1, n)-1] do
      rep[i][n,n] := Z(q)^i;
    od;
  fi;

  # now convert into actual matrices and compute centralizer order
  cl := [];
  one :=  One(GF(q));
  for a in cls do
    mat := [];
    cen := 1;
    for b in a do
      for c in b[4] do
        Add(mat, powerpol(pols[b[2]][b[3]], c));
      od;
      cen := cen * myval(SizePolynomialUnipotentClassGL(b[4]), q^b[2]);
    od;
    mat := one * DirectSumMat(List(mat, CompanionMat));

    # in the sl-case we have to split this class
    if flag then
      if DeterminantMat(mat)=Z(q)^0 then
        gcd := Gcd(Concatenation(List(a, b-> b[4])));
        gcd := Gcd(gcd, q-1);
        mat := [mat];
        for i in [1..gcd-1] do
          Add(mat, mat[1]^rep[i]);
        od;
        for m in mat do
            new := ConjugacyClass( G, m );
            SetSize( new, (o*(q-1))/(cen*gcd) );
            Add( cl, new );
        od;
      fi;
    else
      new := ConjugacyClass( G, mat );
      SetSize( new, o/cen );
      Add(cl, new );
    fi;
  od;
  # obey general rule in GAP to put class of identity first
  i := First([1..Length(cl)], c-> Representative(cl[c]) = One(G));
#T note that One(G) is in Is8BitMatrixRep,
#T but the class representatives are in IsPlistRep
  if i <> 1 then
    a := cl[i];
    cl[i] := cl[1];
    cl[1] := a;
  fi;
  return cl;
end );

#############################################################################
##
#M  ConjugacyClasses( <G> ) . . . . . . . . . . . . . . . . .  for natural GL
##
InstallMethod( ConjugacyClasses, "for natural gl", true,
               [IsFFEMatrixGroup and IsFinite and IsNaturalGL],
               0,
    G -> ConjugacyClassesOfNaturalGroup( G, false ) );


#############################################################################
##
#M  ConjugacyClasses( <G> ) . . . . . . . . . . . . . . . . .  for natural SL
##
InstallMethod( ConjugacyClasses, "for natural sl", true,
               [IsFFEMatrixGroup and IsFinite and IsNaturalSL],
               0,
    G -> ConjugacyClassesOfNaturalGroup( G, true ) );

#############################################################################
##
#M  ConjugacyClasses
##
InstallMethod(ConjugacyClasses,"matrix groups: test naturality",true,
  [IsFFEMatrixGroup and IsFinite and IsHandledByNiceMonomorphism],0,
function(g)
  if (((not HasIsNaturalGL(g)) and IsNaturalGL(g))
      or ((not HasIsNaturalSL(g)) and IsNaturalSL(g))) then
    # redispatch as we found something out
    return ConjugacyClasses(g);
  fi;
  TryNextMethod();
end);


#############################################################################
##
#M  Random( <G> ) . . . . . . . . . . . . . . . . . . . . . .  for natural GL
##
InstallMethodWithRandomSource( Random,
    "for a random source and natural GL",
    [ IsRandomSource, IsFFEMatrixGroup and IsFinite and IsNaturalGL ],
function(rs, G)
    local m;
    m := RandomInvertibleMat( rs, DimensionOfMatrixGroup( G ),
                 FieldOfMatrixGroup( G ) );
    return ImmutableMatrix(FieldOfMatrixGroup(G), m, true);
end);


#############################################################################
##
#M  Random( <G> ) . . . . . . . . . . . . . . . . . . . . . .  for natural SL
##
##  We use that the matrices obtained from the identity matrix by setting the
##  entry in the upper left corner to arbitrary nonzero values in the field
##  $F$ form a set of coset representatives of $SL(n,F)$ in $GL(n,F)$.
##
InstallMethodWithRandomSource( Random,
    "for a random source and natural SL",
    [ IsRandomSource, IsFFEMatrixGroup and IsFinite and IsNaturalSL ],
function(rs, G)
    local m;
    m:= RandomInvertibleMat( rs, DimensionOfMatrixGroup( G ),
                FieldOfMatrixGroup( G ) );
    MultVector(m[1], DeterminantMat(m)^-1);
    return ImmutableMatrix(FieldOfMatrixGroup(G), m, true);
end);

#############################################################################
##
#F  Phi2_Md( <n> )  . . . . . . . . . .  Modification of Euler's Phi function
##
##  This is needed for the computation of the class numbers of SL(n,q),
##  PSL(n,q), SU(n,q) and PSU(n,q). Defined by Macdonald in [Mac81].
##
InstallGlobalFunction(Phi2_Md,
n -> n^2 * Product(Set(Filtered(Factors(Integers,n), m -> m <> 1)),
                   p -> (1 - 1/p^2)));

#############################################################################
##
#F  NrConjugacyClassesGL( <n>, <q> ) . . . . . . . . Class number for GL(n,q)
##
##  This is also needed for the computation of the class numbers of PGL(n,q),
##  SL(n,q) and PSL(n,q)
##
InstallGlobalFunction(NrConjugacyClassesGL,
function(n,q)
  return Sum(Partitions(n),
             v -> Product(List(Set(v), i -> Number(v, j -> j = i)),
                          n_i -> q^n_i - q^(n_i - 1)));
end);

#############################################################################
##
#F  NrConjugacyClassesSLIsogeneous( <n>, <q>, <f> )
##
##  Class number for group isogeneous to SL(n,q)
##
InstallGlobalFunction(NrConjugacyClassesSLIsogeneous,
function(n,q,f)
  return Sum(Cartesian(DivisorsInt(Gcd(  f,q - 1)),
                       DivisorsInt(Gcd(n/f,q - 1))),
             d ->   Phi(d[1]) * Phi2_Md(d[2])
                  * NrConjugacyClassesGL(n/Product(d),q))/(q - 1);
end);

#############################################################################
##
#F  NrConjugacyClassesSL( <n>, <q> )  . . . . . . .  Class number for SL(n,q)
##
InstallGlobalFunction(NrConjugacyClassesSL,
function(n,q)
  return NrConjugacyClassesSLIsogeneous(n,q,1);
end);

#############################################################################
##
#F  NrConjugacyClassesPGL( <n>, <q> ) . . . . . . . Class number for PGL(n,q)
##
InstallGlobalFunction(NrConjugacyClassesPGL,
function(n,q)
  return NrConjugacyClassesSLIsogeneous(n,q,n);
end);

#############################################################################
##
#F  NrConjugacyClassesPSL( <n>, <q> ) . . . . . . . Class number for PSL(n,q)
##
InstallGlobalFunction(NrConjugacyClassesPSL,
function(n,q)
  return Sum(Filtered(Cartesian(DivisorsInt(q - 1),DivisorsInt(q - 1)),
                      d -> n mod Product(d) = 0),
             d -> Phi(d[1]) * Phi2_Md(d[2])
                * NrConjugacyClassesGL(n/Product(d),q)/(q - 1))/Gcd(n,q - 1);
end);

#############################################################################
##
#F  NrConjugacyClassesGU( <n>, <q> ) . . . . . . . . Class number for GU(n,q)
##
##  This is also needed for the computation of the class numbers of PGU(n,q),
##  SU(n,q) and PSU(n,q)
##
InstallGlobalFunction(NrConjugacyClassesGU,
function(n,q)
  return Sum(Partitions(n),
             v -> Product(List(Set(v), i -> Number(v, j -> j = i)),
                          n_i -> q^n_i + q^(n_i - 1)));
end);

#############################################################################
##
#F  NrConjugacyClassesSUIsogeneous( <n>, <q>, <f> )
##
##  Class number for group isogeneous to SU(n,q)
##
InstallGlobalFunction(NrConjugacyClassesSUIsogeneous,
function(n,q,f)
  return Sum(Cartesian(DivisorsInt(Gcd(  f,q + 1)),
                       DivisorsInt(Gcd(n/f,q + 1))),
             d ->   Phi(d[1]) * Phi2_Md(d[2])
                  * NrConjugacyClassesGU(n/Product(d),q))/(q + 1);
end);

#############################################################################
##
#F  NrConjugacyClassesSU( <n>, <q> )  . . . . . . .  Class number for SU(n,q)
##
InstallGlobalFunction(NrConjugacyClassesSU,
function(n,q)
  return NrConjugacyClassesSUIsogeneous(n,q,1);
end);

#############################################################################
##
#F  NrConjugacyClassesPGU( <n>, <q> ) . . . . . . . Class number for PGU(n,q)
##
InstallGlobalFunction(NrConjugacyClassesPGU,
function(n,q)
  return NrConjugacyClassesSUIsogeneous(n,q,n);
end);

#############################################################################
##
#F  NrConjugacyClassesPSU( <n>, <q> ) . . . . . . . Class number for PSU(n,q)
##
InstallGlobalFunction(NrConjugacyClassesPSU,
function(n,q)
  return Sum(Filtered(Cartesian(DivisorsInt(q + 1),DivisorsInt(q + 1)),
                      d -> n mod Product(d) = 0),
             d -> Phi(d[1]) * Phi2_Md(d[2])
                * NrConjugacyClassesGU(n/Product(d),q)/(q + 1))/Gcd(n,q + 1);
end);

#############################################################################
##
#M  NrConjugacyClasses( <G> ) . . . . . . . . . .  Method for natural GL(n,q)
##
InstallMethod( NrConjugacyClasses,
               "for natural GL",
               true,
               [ IsFFEMatrixGroup and IsFinite and IsNaturalGL ],
               0,
function ( G )

  local  n,q;

  n := DimensionOfMatrixGroup(G);
  q := Size(FieldOfMatrixGroup(G));

  return NrConjugacyClassesGL(n,q);
end );

#############################################################################
##
#M  NrConjugacyClasses( <G> ) . . . . . . . . . .  Method for natural SL(n,q)
##
InstallMethod( NrConjugacyClasses,
               "for natural SL",
               true,
               [ IsFFEMatrixGroup and IsFinite and IsNaturalSL ],
               0,
function ( G )

  local  n,q;

  n := DimensionOfMatrixGroup(G);
  q := Size(FieldOfMatrixGroup(G));

  return NrConjugacyClassesSL(n,q);
end );

#############################################################################
##
#M  NrConjugacyClasses( <G> ) . . . . . . . . . . . . . .  Method for GU(n,q)
##
InstallMethod( NrConjugacyClasses,
               "for GU(n,q)",
               true,
               [ IsFFEMatrixGroup and IsFinite
                 and IsFullSubgroupGLorSLRespectingSesquilinearForm ],
               0,
function ( G )

  local  n,q;

  if IsSubgroupSL(G) then TryNextMethod(); fi;

  n := DimensionOfMatrixGroup(G);
  q := RootInt(Size(FieldOfMatrixGroup(G)));

  return NrConjugacyClassesGU(n,q);
end );

#############################################################################
##
#M  NrConjugacyClasses( <G> ) . . . . . . . . . .  Method for natural SU(n,q)
##
InstallMethod( NrConjugacyClasses,
               "for natural SU",
               true,
               [ IsFFEMatrixGroup and IsFinite
                 and IsFullSubgroupGLorSLRespectingSesquilinearForm
                 and IsSubgroupSL ],
               0,
function ( G )

  local  n,q;

  n := DimensionOfMatrixGroup(G);
  q := RootInt(Size(FieldOfMatrixGroup(G)));

  return NrConjugacyClassesSU(n,q);
end );


InstallGlobalFunction(ClassesProjectiveImage,function(act)
local G,PG,cl,c,i,sel,p,z,a,x,prop,fus,f,reps,repi,repo,zel,fcl,
      real,goal,good,e;

  G:=Source(act);

  # elementary divisors for GL-class identification
  x:=X(DefaultFieldOfMatrixGroup(G),1);
  prop:=y->Set(Filtered(ElementaryDivisorsMat(y-x*y^0),
               y->DegreeOfUnivariateLaurentPolynomial(y)>0));

  # compute real fusion
  real:=function(set)
  local new,i,a,b;
    new:=[];
    for i in set do
      if i in set then # might have been removed by now
        b:=ConjugacyClass(PG,repi[i]);
        a:=Filtered(set,x->x<>i and repi[x] in b);
        a:=Union(a,[i]);
        fcl[a[1]]:=b;
        Add(new,a);
        set:=Difference(set,a);
      fi;
    od;
    return new;
  end;

  #dom:=NormedRowVectors(DefaultFieldOfMatrixGroup(G)^Length(One(G)));
  #act:=ActionHomomorphism(G,dom,OnLines,"surjective");
  PG:=Image(act); # this will be PSL etc.

  StabChainMutable(PG);; # needed anyhow and will speed up images under act
  z:=Size(Centre(G));
  zel:=Filtered(AsSSortedList(Centre(G)),x->Order(x)>1);
  cl:=ConjugacyClasses(G);
  if IsNaturalGL(G) then
    goal:=NrConjugacyClassesPGL(Length(One(G)),
           Size(DefaultFieldOfMatrixGroup(G)));
  elif IsNaturalSL(G) then
    goal:=NrConjugacyClassesPSL(Length(One(G)),
           Size(DefaultFieldOfMatrixGroup(G)));
  else
    goal:=Length(cl); # this is too loose, but upper limit
  fi;

  sel:=[];
  reps:=List(cl,Representative);
  repi:=List(reps,x->ImagesRepresentative(act,x));
  repo:=List(repi,Order);
  e:=List(reps,prop);

  sel:=[1..Length(cl)];
  fcl:=[]; # cached factor group classes
  if z=1 then
    fus:=List(sel,x->[x]);
  else
    # fuse maximally under centre multiplication
    fus:=[];
    while Length(sel)>0 do
      a:=sel[1]; sel:=sel{[2..Length(sel)]};
      p:=Union(e{[a]},List(zel,x->prop(reps[a]*x)));
      f:=Filtered(sel,x->e[x] in p and repo[a]=repo[x]);
      sel:=Difference(sel,f);
      AddSet(f,a);
      Add(fus,f);
    od;

    # separate those that clearly cannot fuse fully
    good:=[];
    for i in Filtered(fus,x->Length(x)>z or z mod Length(x)<>0) do
      a:=real(i);
      fus:=Union(Filtered(fus,x->x<>i),a);
      good:=Union(good,a); # record that we properly tested
    od;


    # now go through and test properly and fuse, unless we reached the
    # proper class number
    for i in fus do
      if not i in good and Length(fus)<goal then
        # fusion could split up -- test
        a:=real(i);
        fus:=Union(Filtered(fus,x->x<>i),a);
      fi;
    od;
  fi;

  # now fusion is good -- form classes
  c:=[];
  for i in fus do
    if IsBound(fcl[i[1]]) then
      a:=fcl[i[1]];
    else
      a:=ConjugacyClass(PG,repi[i[1]]);
    fi;
    Add(c,a);
    f:=Sum(cl{i},Size)/z;
    SetSize(a,f);
  od;

  SetConjugacyClasses(PG,c);
  return [act,PG,c];
end);
