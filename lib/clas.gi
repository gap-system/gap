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


#############################################################################
##
#M  Enumerator( <xorb> )  . . . . . . . . . . . . . .  enumerator constructor
##
##  This is installed only because of the `PositionCanonical' functionality.
#T for which groups is this really used?
##
##  The idea is that for the orbit <xorb> given by the acting domain $G$,
##  the representative $r$, and the stabilizer $S$,
##  a right transversal $T$ of $S$ in $G$ is chosen;
##  the $i$-th element in the enumerator <enum> of <orb> is then
##  the image of $r$ under $T[i]$, w.r.t. the action of <xorb>.
##
##  So the position of an element <elm> in <enum> is determined by first
##  finding an element $x$ in $G$ such that $r^x$ equals <elm>,
##  and if $x$ exists then finding an element $y$ in $T$ such that
##  $S x = S y$ holds; then the position of $y$ in $T$ is the result.
##  By the construction of $T$, this can be computed as
##  $`PositionCanonical'( T, x )$.
##
BindGlobal( "ElementNumber_ExternalOrbitByStabilizer", function( enum, pos )
    local xorb;

    xorb := UnderlyingCollection( enum );
    return FunctionAction( xorb )
           ( Representative( xorb ), enum!.rightTransversal[ pos ] );
end );

BindGlobal( "NumberElement_ExternalOrbitByStabilizer", function( enum, elm )
    local xorb, rep;

    xorb := UnderlyingCollection( enum );
    rep := RepresentativeAction( xorb, Representative( xorb ), elm );
    if rep = fail  then
      return fail;
    else
      return PositionCanonical( enum!.rightTransversal, rep );
    fi;
end );

InstallMethod( Enumerator,
    "xorb by stabilizer",
    [ IsExternalOrbitByStabilizerRep ],
    xorb -> EnumeratorByFunctions( xorb, rec(
               NumberElement     := NumberElement_ExternalOrbitByStabilizer,
               ElementNumber     := ElementNumber_ExternalOrbitByStabilizer,

               rightTransversal  := RightTransversal( ActingDomain( xorb ),
                   StabilizerOfExternalSet( xorb ) ) ) ) );


#############################################################################
##
#M  AsList( <xorb> )  . . . . . . . . . . . . . .  enumerator constructor
##
InstallMethod( AsList,"xorb by stabilizer",
  [ IsExternalOrbitByStabilizerRep ],
function( xorb )
local   rep,opr;

    rep:=Representative(xorb);
    opr:=FunctionAction(xorb);
    return List(RightTransversal( ActingDomain(xorb),
                                  StabilizerOfExternalSet( xorb ) ),
                i->opr(rep,i));
end );

#############################################################################
##
#M  IsFinite( <xorb> )  . . . . . . . . . . . for an ext. orbit by stabilizer
##
InstallMethod( IsFinite,
    "method for an ext. orbit by stabilizer",
    [ IsExternalOrbitByStabilizerRep ],
    xorb -> IsInt( Index( ActingDomain( xorb ),
                          StabilizerOfExternalSet( xorb ) ) ) );


#############################################################################
##
#M  Size( <xorb> )  . . . . . . . . . . . . . for an ext. orbit by stabilizer
##
InstallMethod( Size,
    "method for an ext. orbit by stabilizer",
    [ IsExternalOrbitByStabilizerRep ],
    xorb -> Index( ActingDomain( xorb ), StabilizerOfExternalSet( xorb ) ) );


#############################################################################
##
#M  ConjugacyClass( <G>, <g> )  . . . . . . . . . . . . . . . . . constructor
##
InstallMethod( ConjugacyClass,"class of element",
  IsCollsElms, [ IsGroup, IsObject ],
function( G, g )
local fam,  filter,  cl;

    fam:=FamilyObj(G);
    if not IsBound(fam!.defaultClassType) then
      if IsPermGroup( G )  then  filter := IsConjugacyClassPermGroupRep;
                          else  filter := IsConjugacyClassGroupRep;      fi;
      if CanEasilyComputePcgs( G )  then
          filter := filter and IsExternalSetByPcgs;
      fi;
      filter:=filter and HasActingDomain and HasRepresentative and
              HasFunctionAction;
      fam!.defaultClassType:=NewType( FamilyObj( G ), filter );
    fi;

    cl:=rec( start := [ g ] );
    ObjectifyWithAttributes(cl, fam!.defaultClassType,
            ActingDomain, G,
            Representative, g,
            FunctionAction, OnPoints );
    return cl;
end );

InstallOtherMethod( ConjugacyClass,"class of element and centralizer",
  IsCollsElmsColls, [ IsGroup, IsObject,IsGroup ],
function( G, g, cent )
local fam,  filter,  cl;

    fam:=FamilyObj(G);
    if not IsBound(fam!.defaultClassCentType) then
      if IsPermGroup( G )  then  filter := IsConjugacyClassPermGroupRep;
                          else  filter := IsConjugacyClassGroupRep;      fi;
      if CanEasilyComputePcgs( G )  then
          filter := filter and IsExternalSetByPcgs;
      fi;
      filter:=filter and HasActingDomain and HasRepresentative and
              HasFunctionAction and HasStabilizerOfExternalSet;
      fam!.defaultClassCentType:=NewType( FamilyObj( G ), filter );
    fi;

    cl:=rec( start := [ g ]);
    ObjectifyWithAttributes(cl, fam!.defaultClassCentType,
            ActingDomain, G,
            Representative, g,
            FunctionAction, OnPoints,
            StabilizerOfExternalSet,cent);
    return cl;
end );

#############################################################################
##
#M  \^( <g>, <G> ) . . . . . . . . . conjugacy class of an element of a group
##
InstallOtherMethod( \^, "conjugacy class of an element of a group",
                    IsElmsColls, [ IsMultiplicativeElement, IsGroup ], 0,

  function ( g, G )
    if g in G then return ConjugacyClass(G,g); else TryNextMethod(); fi;
  end );

#############################################################################
##
#M  HomeEnumerator( <cl> )  . . . . . . . . . . . . . . . . enumerator of <G>
##
InstallMethod( HomeEnumerator, [ IsConjugacyClassGroupRep ],
    cl -> Enumerator( ActingDomain( cl ) ) );

#############################################################################
##
#M  PrintObj( <cl> )  . . . . . . . . . . . . . . . . . . . .  print function
##
InstallMethod( PrintObj, [ IsConjugacyClassGroupRep ],
    function( cl )
    Print( "ConjugacyClass( ", ActingDomain( cl ), ", ",
           Representative( cl ), " )" );
end );

#############################################################################
##
#M  ViewObj( <cl> )  . . . . . . . . . . . . . . . . . . . .  print function
##
InstallMethod( ViewObj, [ IsConjugacyClassGroupRep ],
    function( cl )
    View(Representative( cl ));
    Print("^G");
end );


#############################################################################
##
#M  Size( <cl> )  . . . . . . . . . . . . . . . . . . . . . for a conj. class
##
InstallMethod( Size,
    "for a conjugacy class",
    [ IsConjugacyClassGroupRep ],
    cl -> Index( ActingDomain( cl ), StabilizerOfExternalSet( cl ) ) );


#############################################################################
##
#M  IsFinite( <cl> )  . . . . . . . . . . . . . . . . . . . for a conj. class
##
InstallMethod( IsFinite,
    "for a conjugacy class",
    [ IsConjugacyClassGroupRep ],
    cl -> IsInt( Index( ActingDomain( cl ),
                        StabilizerOfExternalSet( cl ) ) ) );
#T is it necessary to install the same method for `IsConjugacyClassGroupRep'
#T and for `IsExternalOrbitByStabilizerRep'?

InstallOtherMethod( Centralizer,
    [ IsConjugacyClassGroupRep ],
    StabilizerOfExternalSet );

InstallMethod( StabilizerOfExternalSet, [ IsConjugacyClassGroupRep ],
    # override eventual pc method
    10,
function(xset)
  return Centralizer(ActingDomain(xset),Representative(xset));
end);

InstallGlobalFunction( ConjugacyClassesTry,
function ( G, classes, elm, length )
local i,D,o,divs,pows,norms,next,nnorms,oq,lelm,from,n,k,m,nu,zen,pr,orb,lo,
      prg,C,u;

    # if the element is not in one of the known classes add a new class
    i:=1;
    while i<=Length(classes) do
      if length mod Size(classes[i])=0 and elm in classes[i] then
        # return (modified) centralizer of element for iteration
        D:=Centralizer(classes[i]);
        if Size(D)=Order(elm) then
          D:=G;
        fi;
        return D;
      fi;
      i:=i+1;
    od;

    # do not add the class here as we'll do it later with the powers
    o:=Order(elm);
    Info(InfoClasses,2,"process new class ",Length(classes)+1,
         " element order ",o);

    # gho through the divisors lattice
    divs:=Filtered(DivisorsInt(o),x->x>1);
    pows:=[1];
    norms:=[G];

    while Length(divs)>0 do
      # those one prime away
      next:=Filtered(divs,x->ForAny(pows,y->IsInt(x/y) and IsPrimeInt(x/y)));
      divs:=Difference(divs,next);
      nnorms:=[];
      for i in next do
        oq:=o/i; # power needed to get order i
        lelm:=elm^oq;
        from:=First(Reversed(pows),y->IsInt(i/y) and IsPrimeInt(i/y));
        # step of normalizer calculation via powers
        n:=Normalizer(norms[from],Subgroup(G,[lelm]));
        nnorms[i]:=n;

        if i=o or not ForAny(classes,x->lelm in x) then
          # this power gives a new class
          zen:=Centralizer(n,lelm); # all powers have the same centralizer

          # what coprime powers are normalizer induced?
          pr:=Difference(PrimeResidues(i),[1]);
          u:=GroupByGenerators([ZmodnZObj(1,i)]);
          orb:=Orbit(n,lelm);
          lo:=Length(orb);
          orb:=Set(Filtered(orb,x->x<>lelm));
          while Size(u)<lo do
            m:=First(pr,x->lelm^x=orb[1]);
            nu:=ClosureGroup(u,ZmodnZObj(m,i));
            if Size(nu)<lo then
              for k in Difference(nu,u) do
                RemoveSet(orb,lelm^Int(k));
              od;
            fi;
            u:=nu;
          od;
          # now u is the group of normalizer induced powers
          prg:=GroupByGenerators(
            List(Flat(GeneratorsPrimeResidues(i).generators),
                    x->ZmodnZObj(x,i)));
          orb:=List(RightTransversal(prg,u),Int);
          for k in orb do
            D:=ConjugacyClass(G,lelm^k);
            SetStabilizerOfExternalSet(D,zen);
            Add(classes,D);
            Info(InfoClasses,3,"found new power of order ",i,
                 " class size ",Size(D));
            if k=1 and i=o then C:=D;fi; #remember for return value
          od;

        fi;
      od;

      pows:=next;
      norms:=nnorms;
    od;

    return Centralizer(C);

end );

#############################################################################
##
#M  ConjugacyClassesByRandomSearch( <G> )
##
InstallGlobalFunction( ConjugacyClassesByRandomSearch, function ( G )
# uses random Search with Jerrum's strategy
local   classes,    # conjugacy classes of <G>, result
        class,      # one class of <G>
        cent,       # centralizer from which to take random elements
        seed,       # possible seed
        elms;       # elements of <G>

    # initialize the conjugacy class list

    # if the group is small, or if its elements are known
    # or if the group is abelian, do it the hard way
    if Size( G ) <= 1000 or HasAsSSortedList( G )  or IsAbelian( G ) then
      return ConjugacyClassesByOrbits(G);
    # otherwise use probabilistic algorithm
    else
        seed:=ValueOption("seed");
        if not IsList(seed) then seed:=[];fi;
        classes := [ ConjugacyClass( G, One( G ) ) ];

        cent:=G;
        # while we have not found all conjugacy classes
        while Sum( List( classes, Size ) ) <> Size( G )  do

            if Length(seed)>0 then
              # try random elements
              cent:=ConjugacyClassesTry( G, classes, seed[1], 0 );
              seed:=seed{[2..Length(seed)]};
            else
              # try random elements
              cent:=ConjugacyClassesTry( G, classes, Random(cent), 0 );
            fi;

        od;

    fi;

    # return the conjugacy classes
    return classes;

end );

#############################################################################
##
#M  ConjugacyClassesByOrbits( <G> )
##
InstallGlobalFunction(ConjugacyClassesByOrbits,
function(G)
local xset,i,cl,c,p,s;
  #xset:=ExternalSet(G,AsSSortedListNonstored(G),OnPoints);
  xset:=AsSSortedListNonstored(G);
  s:=HasAsList(G) or HasAsSSortedList(G); # do we want to store class elements?
  p:=false;
  cl:=[];
  #for i in ExternalOrbitsStabilizers(xset) do
  for i in OrbitsDomain(G,xset) do
    #c:=ConjugacyClass(G,Representative(i),StabilizerOfExternalSet(i));
    c:=ConjugacyClass(G,i[1]);
    SetSize(c,Length(i));
    # the sorted element list will speed up `\in' tests
    if s or Length(i)<5 then
      SetAsSSortedList(c,SortedList(i));
    fi;
    Add(cl,c);
    if IsOne(Representative(i)) then
      SetStabilizerOfExternalSet(c,G);
      p:=Length(cl);
    fi;
  od;
  # force class of one in first position
  c:=cl[p];cl[p]:=cl[1];cl[1]:=c;
  return cl;
end);

InstallGlobalFunction(ConjugacyClassesByHomomorphicImage,function(G,hom)
local H,cl,a,c;
  H:=Image(hom,G);
  cl:=[];
  for c in ConjugacyClasses(H) do
    a:=ConjugacyClass(G,PreImagesRepresentative(hom,Representative(c)));
    if HasStabilizerOfExternalSet(c) then
      SetStabilizerOfExternalSet(a,PreImage(hom,StabilizerOfExternalSet(c)));
    fi;
    Add(cl,a);
  od;
  return cl;
end);

#############################################################################
##
#M  ConjugacyClasses( <G> ) . . . . . . . . . . . . . . . . . . .  of a group
##
InstallMethod( ConjugacyClasses, "test options", [ IsGroup ],
  GETTER_FLAGS-1, # this method tests options which would override the method
               # selection. Therefore we get the highest possible value
               # below the getter.
function(G)
  if ValueOption("random")<>fail then
    return ConjugacyClassesByRandomSearch(G);
  elif ValueOption("action")<>fail then
    return ConjugacyClassesByOrbits(G);
  else
    TryNextMethod();
  fi;
end);


DEFAULT_CLASS_ORBIT_LIMIT:=500;
InstallGlobalFunction(ConjugacyClassesForSmallGroup,function(G)
  if ValueOption("noaction")=fail and
   (HasAsSSortedList(G) or HasAsList(G) or Size(G)<=DEFAULT_CLASS_ORBIT_LIMIT)
    then
      return ConjugacyClassesByOrbits(G);
  else
    return fail;
  fi;
end);

InstallGlobalFunction( ConjugacyClassesForSolvableGroup,
  function( G )
  local   cls,  cl,  c;

  cls := [  ];
  for cl  in ClassesSolvableGroup( G, 0 )  do
    c := ConjugacyClass( G, cl.representative, cl.centralizer );
    Assert(2,Centralizer(G,cl.representative)=cl.centralizer);
    Add( cls, c );
  od;
  Assert(1,Sum(cls,Size)=Size(G));
  return cls;
end );

InstallMethod( ConjugacyClasses, "for groups: try solvable method and random search",
  [ IsGroup and IsFinite ],
function(G)
local cl;
  cl:=ConjugacyClassesForSmallGroup(G);
  if cl<>fail then
    return cl;
  elif IsSolvableGroup( G ) and CanEasilyComputePcgs(G) then
    return ConjugacyClassesForSolvableGroup(G);
  else
    return ConjugacyClassesByRandomSearch(G);
  fi;
end);

#############################################################################
##
#M  RationalClass( <G>, <g> ) . . . . . . . . . . . . . . . . . . constructor
##
InstallMethod( RationalClass, IsCollsElms, [ IsGroup, IsObject ],
    function( G, g )
    local   filter, cl;
    if IsPermGroup( G )  then
        filter := IsRationalClassPermGroupRep;
    else
        filter := IsRationalClassGroupRep;
    fi;
    cl := rec(  );
    ObjectifyWithAttributes( cl, NewType( FamilyObj( G ), filter ),
            ActingDomain, G,
            Representative, g,
            FunctionAction, OnPoints );
    return cl;
end );

#############################################################################
##
#M  <cl1> = <cl2> . . . . . . . . . . . . . . . . . . .  for rational classes
##
InstallMethod( \=, IsIdenticalObj, [ IsRationalClassGroupRep,
        IsRationalClassGroupRep ],
    function( cl1, cl2 )
    if ActingDomain( cl1 ) <> ActingDomain( cl2 )
      then
        TryNextMethod();
    fi;
    # the Galois group of the identity is <0>, therefore we have to do this
    # extra test.
    return Order(Representative(cl1))=Order(Representative(cl2)) and
      ForAny( RightTransversalInParent( GaloisGroup( cl1 ) ), e ->
                   RepresentativeAction( ActingDomain( cl1 ),
                           Representative( cl1 ),
                           Representative( cl2 ) ^ Int( e ) ) <> fail );
end );

#############################################################################
##
#M  <g> in <cl> . . . . . . . . . . . . . . . . . . . .  for rational classes
##
InstallMethod( \in, IsElmsColls, [ IsObject, IsRationalClassGroupRep ],
    function( g, cl )
    # the Galois group of the identity is <0>, therefore we have to do this
    # extra test.
    return Order(Representative(cl))=Order(g) and
      ForAny( RightTransversalInParent( GaloisGroup( cl ) ), e ->
                   RepresentativeAction( ActingDomain( cl ),
                           Representative( cl ),
                           g ^ Int( e ) ) <> fail );
end );

#############################################################################
##
#M  HomeEnumerator( <cl> )  . . . . . . . . . . . . . . . . enumerator of <G>
##
InstallMethod( HomeEnumerator, [ IsConjugacyClassGroupRep ],
    cl -> Enumerator( ActingDomain( cl ) ) );

#############################################################################
##
#M  PrintObj( <cl> )  . . . . . . . . . . . . . . . . . . . .  print function
##
InstallMethod( PrintObj, [ IsRationalClassGroupRep ],
    function( cl )
    Print( "RationalClass( ", ActingDomain( cl ), ", ",
           Representative( cl ), " )" );
end );


#############################################################################
##
#M  Size( <cl> )  . . . . . . . . . . . . . . . . . . .  for a rational class
##
InstallMethod( Size,
    "method for a rational class",
    [ IsRationalClassGroupRep ],
    cl -> IndexInParent( GaloisGroup( cl ) ) *
          Index( ActingDomain( cl ), StabilizerOfExternalSet( cl ) ) );

#############################################################################
##
#F  DecomposedRationalClass( <cl> ) . . . . . decompose into ordinary classes
##
InstallOtherMethod(DecomposedRationalClass,
  "generic",true,[IsRationalClassGroupRep],0,function( cl )
local   G,  C,  rep,  gal,  T,  cls,  e,  c;

  G := ActingDomain( cl );
  C := StabilizerOfExternalSet( cl );
  rep := Representative( cl );
  gal := GaloisGroup( cl );
  T := RightTransversalInParent( gal );
  cls := [  ];
  for e  in T  do
    # if e=0 then the element is the identity anyhow, no need to worry.
    c := ConjugacyClass( G, rep ^ Int( e ),C );
    Add( cls, c );
  od;
  return cls;
end );


#############################################################################
##
#M  Enumerator( <rcl> ) . . . . . . . . . . . . . . . . . . of rational class
##
##  The idea is that for the rational class <rcl> given by the acting domain
##  $G$, the representative $r$, the centralizer $S$ of $r$, and the Galois
##  group $\Sigma$ acting on the algebraic conjugates of the class $r^G$,
##  a right transversal $T$ of $S$ in $G$ is chosen;
##  for $i = |T| \cdot i_1 + i_2$, with $1 \leq i_2 \leq |T|$,
##  the $i$-th element in the enumerator <enum> of <rcl> is then
##  the image of $r$ under $T[i_2]$, w.r.t. the action of <xorb>, raised to
##  the power given by the $i_1$-th element in $\Sigma$.
##
##  So the position of an element <elm> in <enum> is determined by first
##  finding an element $x$ in $G$ and an integer $i$ coprime to the order of
##  $r$ such that $(r^x)^i$ equals <elm>,
##  and if $x$ and $i$ exist then finding an element $y$ in $T$ such that
##  $S x = S y$ holds; then the position of $y$ in $T$ is the result.
##  By the construction of $T$, this can be computed as
##  $`PositionCanonical'( T, x )$.
##
BindGlobal( "ElementNumber_RationalClassGroup", function( enum, pos )
    local   rcl,  rep,  gal,  T,  pow;

    rcl := UnderlyingCollection( enum );
    rep := Representative( rcl );
    gal := RightTransversalInParent( GaloisGroup( rcl ) );
    T := enum!.rightTransversal;
    pos := pos - 1;
    pow := QuoInt( pos, Length( T ) ) + 1;
    if Length( gal ) < pow then
      Error( "<enum>[", pos + 1, "] must have an assigned value" );
    fi;
    pos := pos mod Length( T ) + 1;
    # if gal[pow]=0 then the element is the identity anyhow, no need to worry.
    return ( rep ^ T[ pos ] ) ^ Int( gal[ pow ] );
end );

BindGlobal( "NumberElement_RationalClassGroup", function( enum, elm )
    local   rcl,  G,  rep,  gal,  T,  pow,  t;

    rcl := UnderlyingCollection( enum );
    G   := ActingDomain( rcl );
    rep := Representative( rcl );
    gal := RightTransversalInParent( GaloisGroup( rcl ) );
    T := enum!.rightTransversal;
    for pow  in [ 1 .. Length( gal ) ]  do
        # if gal[pow]=0 then the rep is the identity , no need to worry.
        t := RepresentativeAction( G, rep ^ Int( gal[ pow ] ), elm );
        if t <> fail  then
            break;
        fi;
    od;
    if t = fail  then
        return fail;
    else
        return ( pow - 1 ) * Length( T ) + PositionCanonical( T, t );
    fi;
end );

InstallMethod( Enumerator,
    [ IsRationalClassGroupRep ],
    rcl -> EnumeratorByFunctions( rcl, rec(
               NumberElement     := NumberElement_RationalClassGroup,
               ElementNumber     := ElementNumber_RationalClassGroup,

               rightTransversal  := RightTransversal( ActingDomain( rcl ),
                   StabilizerOfExternalSet( rcl ) ) ) ) );


InstallOtherMethod( CentralizerOp, [ IsRationalClassGroupRep ],
    StabilizerOfExternalSet );

#############################################################################
##
#M  AsList( <rcl> ) . . . . . . . . . . . . . . . . . . .  by orbit algorithm
##
InstallMethod( AsList, [ IsRationalClassGroupRep ],
    function( rcl )
    local   aslist,  orb,  e;

    aslist := [  ];
    orb := Orbit( ActingDomain( rcl ), Representative( rcl ) );
    for e  in RightTransversalInParent( GaloisGroup( rcl ) )  do
        # if e=0 then the element is the identity anyhow, no need to worry.
        Append( aslist, List( orb, g -> g ^ Int( e ) ) );
    od;
    return aslist;
end );

#############################################################################
##
#M  GaloisGroup( <cl> ) . . . . . . . . . . . . . . . . . of a rational class
##
InstallOtherMethod( GaloisGroup, [ IsRationalClassGroupRep ],
function( cl )
local   rep,  ord,  gals,  i, pr;

    rep := Representative( cl );
    ord := Order( rep );
    gals := [  ];
    if ord>1 then
      pr:=PrimeResidues(ord);
    else
      pr:=[];
    fi;
    for i in pr do
        if RepresentativeAction( ActingDomain( cl ),
                   rep, rep ^ i ) <> fail  then
            Add( gals, i );
        fi;
    od;
    return GroupByPrimeResidues( gals, ord );
end );

#############################################################################
##
#F  GroupByPrimeResidues( <gens>, <oh> )  . . . . . . . . . . . . . . . local
##
InstallGlobalFunction( GroupByPrimeResidues, function( gens, oh )
    local   R;

    R := Integers mod oh;
    return SubgroupNC( Units( R ), gens * One( R ) );
end );

#############################################################################
##
#M  RationalClasses( <G> )  . . . . . . . . . . . . . . . . . . .  of a group
##
InstallMethod( RationalClasses, "trial", [ IsGroup ],
    function( G )
    local   rcl;

    rcl := [];
    while Sum( rcl, Size ) < Size( G )  do
        RationalClassesTry( G, rcl, Random(G) );
    od;
    return rcl;
end );

InstallGlobalFunction( RationalClassesTry, function(  G, classes, elm  )
    local   C,          # new class
            i;          # loop variable

    # if the element is not in one of the known classes add a new class
    if ForAll( classes, D -> not elm in D )  then
        C := RationalClass( G, elm );
        Add( classes, C );

        # try the powers of this element that reduce the order
        for i in PrimeDivisors(Order(elm)) do
            RationalClassesTry( G, classes, elm ^ i );
        od;

    fi;

end );

InstallMethod( RationalClasses,"use classes",[ IsGroup ], 0,
function( G )
local rcls, cl, mark, rep, c, o, cop, same, sub, pow, p, i, j,closure,
      dec,ggg;

  closure:=function(sub,gens,m)
  local test, t, i;
    # dimino algorithm for normal subgroup
    test:=[1];
    while Length(test)>0 do
      t:=test[1];
      for i in gens do
        if i<>1 then
          AddSet(ggg,i);
        fi;
        if not (sub[t]*i mod m) in sub then
          AddSet(test,Length(sub)+1); # next element to test
          Append(sub,Filtered(List(sub,x->x*i mod m),x-> not x in sub));
        fi;
      od;
      RemoveSet(test,t);
    od;
    #Print(m," ",gens," ",sub,"\n");
  end;

  rcls:=[];
  cl:=ConjugacyClasses(G);

  if Number(cl,x->Size(x)<10)<10000 then
    # trigger for cheap element test
    for i in [1..Length(cl)] do
      if Size(cl[i])<10 then AsSSortedList(cl[i]);fi;
    od;
  fi;

  mark:=BlistList([1..Length(cl)],[]);
  for i in [1..Length(cl)] do
    if mark[i]=false then
      sub:=fail;
      mark[i]:=true;
      rep:=Representative(cl[i]);
      c := RationalClass( G, rep);
      SetStabilizerOfExternalSet( c, Centralizer(cl[i]) );
      Add(rcls,c);
      o:=Order(rep);
      dec:=[cl[i]];
      if o>2 then
        cop:=Set(Flat(GeneratorsPrimeResidues(o).generators));

        # get orders that give the same class
        #same:=Filtered(cop,i->RepresentativeAction(G,rep,rep^i)<>fail);
        same:=Filtered(cop,x->rep^x in cl[i]);
        if Length(same)<Length(cop) then
          # there are other classes:
          sub:=[1];
          ggg:=[];
          closure(sub,same,o);
          cop:=Difference(cop,same);
          for j in cop do
            # we know these are different
            pow:=rep^j;
            p:=First([i+1..Length(cl)],x->pow in cl[x]);
            if p=fail then
              Error("not found");
            else
              if mark[p]=false then
                Add(dec,cl[p]);
              fi;
              mark[p]:=true;
            fi;
          od;

          cop:=Difference(PrimeResidues(o),cop); # we've tested these
          for j in cop do
            if not j in sub then
              pow:=rep^j;
              p:=First([i..Length(cl)],x->pow in cl[x]);
              if p=fail then
                Error("not found");
              elif p=i then
                closure(sub,[j],o);
              else
                if mark[p]=false then
                  Add(dec,cl[p]);
                fi;
                mark[p]:=true;
              fi;
            fi;
          od;
        fi;
      fi;
      SetDecomposedRationalClass(c,dec);
      SetSize(c,Length(dec)*Size(dec[1]));
      if sub<>fail then
        SetGaloisGroup(c,GroupByPrimeResidues(ggg,o));
      fi;
    fi;
  od;
  return rcls;
end);

#InstallMethod( RationalClasses,"solvable",[ CanEasilyComputePcgs ], 20,
#    function( G )
#    local   rcls,  cls,  cl,  c,  sum, size;
#
#    size := Size(G);
#    rcls := [  ];
#    if IsPrimePowerInt( size )  then
#        for cl  in RationalClassesSolvableGroup( G, 1 )  do
#            c := RationalClass( G, cl.representative );
#            SetStabilizerOfExternalSet( c, cl.centralizer );
#            SetGaloisGroup( c, cl.galoisGroup );
#            Add( rcls, c );
#        od;
#    else
#        sum := 0;
#        for cl in ConjugacyClasses(G)  do
#            c := RationalClass( G, Representative(cl) );
#            SetStabilizerOfExternalSet( c, Centralizer(cl) );
#            if sum < size and not c in rcls  then
#                Add( rcls, c );
#                sum := sum + Size( c );
#                if sum = size and not IsBound(cls)  then
#                    break;
#                fi;
#            fi;
#        od;
#
#    fi;
#
#    return rcls;
#end );

#############################################################################
##
#F  RationalClassesInEANS( <G>, <E> ) . . . . . . . . by projective operation
##
InstallGlobalFunction( RationalClassesInEANS, function( G, E )
    local  pcgs,  ff,  one,  pro,  opr,  gens,  orbs,  xorb,  rcl,  rcls,
           rep,  N;

    rcls := [ RationalClass( G, One( G ) ) ];
    if IsTrivial( E )  then
        return rcls;
    fi;

    pcgs := Pcgs( E );
    ff := GF( RelativeOrders( pcgs )[ 1 ] );
    one := One( ff );
    pro := EnumeratorOfNormedRowVectors( ff ^ Length( pcgs ) );
    opr := function( v, g )
        return one * ExponentsConjugateLayer( pcgs,
                       PcElementByExponentsNC( pcgs, v ) , g );
    end;
    gens := Pcgs( G );
    if gens = fail  then
        gens := GeneratorsOfGroup( G );
    fi;
    orbs := ExternalOrbits( G, pro, gens, gens, opr );

    # Construct the rational classes  from the  orbit representatives and the
    # centralizers from the stabilizers.
    for xorb  in orbs  do
        rep := PcElementByExponentsNC( pcgs, Representative( xorb ) );
        rcl := RationalClass( G, rep );
        if HasStabilizerOfExternalSet( xorb )  then
            N := StabilizerOfExternalSet( xorb );
        else
            N := G;
        fi;
        SetStabilizerOfExternalSet( rcl, Centralizer( N, rep, E ) );
        Add( rcls, rcl );
    od;
    return rcls;
end );
