#############################################################################
##
#W  grpffmat.gi                 GAP Library                      Frank Celler
#W                                                              Frank Luebeck
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the operations for matrix groups over finite field.
##
Revision.grpffmat_gi :=
    "@(#)$Id$";


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
function(l)
local   deg,  i,  j,  char;
  deg  := 1;
  for i  in l  do
    for j  in i  do
      deg := LcmInt( deg, DegreeFFE(j) );
    od;
  od;
  if 0 < Length(l)  then
    char := Characteristic(l[1][1]);
  fi;
  return GF(char^deg);
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
    return Size( grp ) = Size( GL( DimensionOfMatrixGroup( grp ),
                   Size( FieldOfMatrixGroup( grp ) ) ) );
end );


#############################################################################
##
#M  NiceMonomorphism( <ffe-mat-grp> )
##
InstallGlobalFunction( NicomorphismOfFFEMatrixGroup, function( grp )
    local   field,  dim,  V,  xset,  nice;
    
    field := FieldOfMatrixGroup( grp );
    dim   := DimensionOfMatrixGroup( grp );
    V     := field ^ dim;
    # for large groups it is not worth to find short orbits
    if (HasIsNaturalGL( grp ) and IsNaturalGL( grp ))
       or (HasIsNaturalSL( grp ) and IsNaturalSL( grp ))
       or (     HasIsFullSubgroupGLorSLRespectingBilinearForm( grp )
            and IsFullSubgroupGLorSLRespectingBilinearForm( grp ) )
       or (     HasIsFullSubgroupGLorSLRespectingSesquilinearForm( grp )
            and IsFullSubgroupGLorSLRespectingSesquilinearForm( grp ) ) then
        xset := ExternalSet( grp, V );
    else
	# One(grp) is a silly way to give the standard basis
        xset := ExternalSubset( grp, V, One( grp ) );
    fi;
    # STILL: reverse the base to get point sorting compatible with lexicographic
    # vector arrangement
    SetBaseOfGroup( xset, One( grp ));
    nice := ActionHomomorphism( xset,"surjective" );
    if not HasNiceMonomorphism(grp) then
      SetNiceMonomorphism(grp,nice);
    fi;
    SetIsInjective( nice, true );
    SetFilterObj(nice,IsNiceMonomorphism);
    # because we act on the full space we are canonical.
    SetIsCanonicalNiceMonomorphism(nice,true);
    return nice;
end );

InstallMethod( NiceMonomorphism, "falling back on GL", true,
    [ IsFFEMatrixGroup and IsFinite ], 0,
function( grp )
  if IsTrivial(grp) 
     or Size(FieldOfMatrixGroup(Parent(grp)))^DimensionOfMatrixGroup(grp)
         >10000 then
    # if the permutation image would be too large, compute the orbit.
    TryNextMethod();
  fi;
  return NicomorphismOfFFEMatrixGroup( GL( DimensionOfMatrixGroup( grp ),
		  Size( FieldOfMatrixGroup( Parent(grp) ) ) ) );
end );


#############################################################################
##
#M  IsomorphismPermGroup( <grp> ) . . . . . . . . . operation on vector space
##
InstallMethod( IsomorphismPermGroup, "ffe matrix group", true,
        [ IsFFEMatrixGroup and IsFinite ], 0,
function( grp )
local   nice;
  if Size(FieldOfMatrixGroup(Parent(grp)))^DimensionOfMatrixGroup(grp)
    >10000 then
      # if the permutation image would be too large, compute the orbit.
      TryNextMethod();
  fi;
    
  nice := NicomorphismOfFFEMatrixGroup( grp );
  SetRange( nice, Image( nice ) );
  SetIsBijective( nice, true );
  return nice;
end );

#############################################################################
##
#M  ProjectiveActionOnFullSpace(<G>,<f>,<n>)
##
InstallGlobalFunction(ProjectiveActionOnFullSpace,function(g,f,n)
local o,i;
  # as the groups are large, we can take all normed vectors
  o:=NormedVectors(f^n);
  for i in o do
    ConvertToVectorRep(i,f);
    MakeImmutable(i);
  od;
  o:=Set(o);
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
##  <la> must be a partition of, say, n.
##  
##  This function returns a  pair [coefficient list, valuation] defining a
##  polynomial over the integers, having the following property: The order
##  of the centralizer of a unipotent element in GL_n(q), q a prime power,
##  with Jordan block sizes given by <la>, is the value of this polynomial
##  at q.
##
SizePolynomialUnipotentClassGL := function(la)
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
end;

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
    tup := Set(List(tup,Set));
    
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
      rep[i][n][n] := Z(q)^i;
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
#M  Random( <G> ) . . . . . . . . . . . . . . . . . . . . . .  for natural GL
##
InstallMethod( Random,
    "for natural GL",
    true,
    [ IsFFEMatrixGroup and IsFinite and IsNaturalGL ],
    0,
    G -> RandomInvertibleMat( DimensionOfMatrixGroup( G ),
                              FieldOfMatrixGroup( G ) ) );


#############################################################################
##
#M  Random( <G> ) . . . . . . . . . . . . . . . . . . . . . .  for natural SL
##
##  We use that the matrices obtained from the identity matrix by setting the
##  entry in the upper left corner to arbitrary nonzero values in the field
##  $F$ form a set of coset representatives of $SL(n,F)$ in $GL(n,F)$.
##
InstallMethod( Random,
    "for natural SL",
    true,
    [ IsFFEMatrixGroup and IsFinite and IsNaturalSL ],
    0,
    function( G )
    G:= RandomInvertibleMat( DimensionOfMatrixGroup( G ),
                             FieldOfMatrixGroup( G ) );
    G[1]:= G[1] / DeterminantMat( G );
    return G;
    end );


#############################################################################
##
#E

