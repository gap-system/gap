#############################################################################
##
#W  clas.gi                     GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.clas_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  Enumerator( <xorb> )  . . . . . . . . . . . . . .  enumerator constructor
##
InstallMethod( Enumerator, "xorb by stabilizer",true,
  [ IsExternalOrbitByStabilizerRep ], 0,
function( xorb )
local   enum;

    enum := Objectify( NewType( FamilyObj( xorb ),
                    IsExternalOrbitByStabilizerEnumerator ),
        rec( rightTransversal := RightTransversal(ActingDomain(xorb),
                    StabilizerOfExternalSet( xorb ) ) ) );
    SetUnderlyingCollection( enum, xorb );
    return enum;
end );

#############################################################################
##
#M  AsList( <xorb> )  . . . . . . . . . . . . . .  enumerator constructor
##
InstallMethod( AsList,"xorb by stabilizer", true,
  [ IsExternalOrbitByStabilizerRep ], 0,
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
    true,
    [ IsExternalOrbitByStabilizerRep ], 0,
    xorb -> IsInt( Index( ActingDomain( xorb ),
                          StabilizerOfExternalSet( xorb ) ) ) );


#############################################################################
##
#M  Size( <xorb> )  . . . . . . . . . . . . . for an ext. orbit by stabilizer
##
InstallMethod( Size,
    "method for an ext. orbit by stabilizer",
    true,
    [ IsExternalOrbitByStabilizerRep ], 0,
    xorb -> Index( ActingDomain( xorb ), StabilizerOfExternalSet( xorb ) ) );

#############################################################################
##
#M  <enum>[ <pos> ] . . . . . . . . . . . . . . . . . .  for such enumerators
##
InstallMethod( \[\],"ext ob by stab enum", true,
  [ IsExternalOrbitByStabilizerEnumerator, IsPosInt ], 0,
function( enum, pos )
local   xorb;

    xorb := UnderlyingCollection( enum );
    return FunctionAction( xorb )
           ( Representative( xorb ), enum!.rightTransversal[ pos ] );
end );

#############################################################################
##
#M  PositionCanonical( <enum>, <elm> )  . . . . . . . .  for such enumerators
##
InstallMethod( PositionCanonical,"ext ob by stab enum", true,
        [ IsExternalOrbitByStabilizerEnumerator, IsObject ], 0,
function( enum, elm )
local   xorb,  rep;

    xorb := UnderlyingCollection( enum );
    rep := RepresentativeAction( xorb, Representative( xorb ), elm );
    if rep = fail  then
        return fail;
    else
        return PositionCanonical( enum!.rightTransversal, rep );
    fi;
end );

#############################################################################
##
#M  \\in(<elm>, <enum> )  . . . . . . . .  for such enumerators
##
InstallMethod( \in,"ext ob by stab enum", true,
        [ IsObject,IsExternalOrbitByStabilizerEnumerator ], 0,
function( elm,enum )
  return elm in UnderlyingCollection(enum);
end);

#############################################################################
##
#M  ConjugacyClass( <G>, <g> )  . . . . . . . . . . . . . . . . . constructor
##
InstallMethod( ConjugacyClass,"class of element",
  IsCollsElms, [ IsGroup, IsObject ], 0,
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
  IsCollsElmsColls, [ IsGroup, IsObject,IsGroup ], 0,
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
#M  HomeEnumerator( <cl> )  . . . . . . . . . . . . . . . . enumerator of <G>
##
InstallMethod( HomeEnumerator, true, [ IsConjugacyClassGroupRep ], 0,
    cl -> Enumerator( ActingDomain( cl ) ) );

#############################################################################
##
#M  PrintObj( <cl> )  . . . . . . . . . . . . . . . . . . . .  print function
##
InstallMethod( PrintObj, true, [ IsConjugacyClassGroupRep ], 0,
    function( cl )
    Print( "ConjugacyClass( ", ActingDomain( cl ), ", ",
           Representative( cl ), " )" );
end );

#############################################################################
##
#M  ViewObj( <cl> )  . . . . . . . . . . . . . . . . . . . .  print function
##
InstallMethod( ViewObj, true, [ IsConjugacyClassGroupRep ], 0,
    function( cl )
    View(Representative( cl ));
    Print("^G");
end );

#############################################################################
##
#M  IsFinite( <cl> )  . . . . . . . . . . . . . . . . . . . for a conj. class
##
InstallMethod( IsFinite,
    "for a conjugacy class",
    true,
    [ IsConjugacyClassGroupRep ], 0,
    cl -> IsInt( Index( ActingDomain( cl ),
                        StabilizerOfExternalSet( cl ) ) ) );
#T why to install the same method once for `IsConjugacyClassGroupRep'
#T and once for `IsExternalOrbitByStabilizerRep'?


#############################################################################
##
#M  Size( <cl> )  . . . . . . . . . . . . . . . . . . . . . for a conj. class
##
InstallMethod( Size,
    "for a conjugacy class",
    true,
    [ IsConjugacyClassGroupRep ], 0,
    cl -> Index( ActingDomain( cl ), StabilizerOfExternalSet( cl ) ) );

InstallOtherMethod( Centralizer,
    [ IsConjugacyClassGroupRep ],
    StabilizerOfExternalSet );

InstallMethod( StabilizerOfExternalSet, true, [ IsConjugacyClassGroupRep ],
    # override eventual pc method
    10,
function(xset)
  return Centralizer(ActingDomain(xset),Representative(xset));
end);

InstallGlobalFunction( ConjugacyClassesTry,
function ( G, classes, elm, length, fixes )
local   C,          # new class
	D,          # another new class
	new,        # new classes
	i;          # loop variable

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

    C := ConjugacyClass( G, elm );
    Add( classes, C );
    Info(InfoClasses,2,"found new class ",Length(classes),
	 " of size ",Size(C));
    new := [ C ];

    # try powers that keep the order, compare only with new classes
    for i  in [2..Order(elm)-1]  do
	if GcdInt( i, Order(elm) * fixes ) = 1  then
	    if not elm^i in C  then
		if ForAll( new, D -> not elm^i in D )  then
		    D := ConjugacyClass( G, elm^i );
		    Add( classes, D );
		    Add( new, D );
		    Info(InfoClasses,2,"found new power");
		fi;
	    elif IsPrimeInt(i)  then
		fixes := fixes * i;
	    fi;
	fi;
    od;

    # try also the powers of this element that reduce the order
    for i  in Set( FactorsInt( Order( elm ) ) )  do
	ConjugacyClassesTry(G,classes,elm^i,Size(C),fixes);
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
	cent,	# centralizer from which to take random elements
	elms;       # elements of <G>

    # initialize the conjugacy class list

    # if the group is small, or if its elements are known
    # or if the group is abelian, do it the hard way
    if Size( G ) <= 1000 or HasAsSSortedList( G )  or IsAbelian( G ) then
      return ConjugacyClassesByOrbits(G);
    # otherwise use probabilistic algorithm
    else
	classes := [ ConjugacyClass( G, One( G ) ) ];

	cent:=G;
        # while we have not found all conjugacy classes
        while Sum( List( classes, Size ) ) <> Size( G )  do

            # try random elements
            cent:=ConjugacyClassesTry( G, classes, Random(cent), 0, 1 );

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

#############################################################################
##
#M  ConjugacyClasses( <G> ) . . . . . . . . . . . . . . . . . . .  of a group
##
InstallMethod( ConjugacyClasses, "test options", true, [ IsGroup ], 
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


InstallMethod( ConjugacyClasses, "for groups: try random search", true,
  [ IsGroup ], 0,
function(G)
local cl;
  cl:=ConjugacyClassesForSmallGroup(G);
  if cl<>fail then
    return cl;
  else
    return ConjugacyClassesByRandomSearch(G);
  fi;
end);

InstallMethod( ConjugacyClasses, "try solvable method", true,
    [ IsGroup ], 0,
    function( G )
    local   cls,  cl,  c;

  cl:=ConjugacyClassesForSmallGroup(G);
  if cl<>fail then
    return cl;
  elif IsSolvableGroup( G ) and CanEasilyComputePcgs(G) then
      cls := [  ];
      for cl  in ClassesSolvableGroup( G, 0 )  do
	  c := ConjugacyClass( G, cl.representative, cl.centralizer );
	  Assert(2,Centralizer(G,cl.representative)=cl.centralizer);
	  Add( cls, c );
      od;
      Assert(1,Sum(cls,Size)=Size(G));
      return cls;
  else
      TryNextMethod();
  fi;
end );

#############################################################################
##
#M  RationalClass( <G>, <g> ) . . . . . . . . . . . . . . . . . . constructor
##
InstallMethod( RationalClass, IsCollsElms, [ IsGroup, IsObject ], 0,
    function( G, g )
    local   cl;

    cl := Objectify( NewType( FamilyObj( G ) ), rec(  ) );
    if IsPermGroup( G )  then
        SetFilterObj( cl, IsRationalClassPermGroupRep );
    else
        SetFilterObj( cl, IsRationalClassGroupRep );
    fi;
    SetActingDomain( cl, G );
    SetRepresentative( cl, g );
    SetFunctionAction( cl, OnPoints );
    return cl;
end );

#############################################################################
##
#M  <cl1> = <cl2> . . . . . . . . . . . . . . . . . . .  for rational classes
##
InstallMethod( \=, IsIdenticalObj, [ IsRationalClassGroupRep,
        IsRationalClassGroupRep ], 0,
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
InstallMethod( \in, IsElmsColls, [ IsObject, IsRationalClassGroupRep ], 0,
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
InstallMethod( HomeEnumerator, true, [ IsConjugacyClassGroupRep ], 0,
    cl -> Enumerator( ActingDomain( cl ) ) );

#############################################################################
##
#M  PrintObj( <cl> )  . . . . . . . . . . . . . . . . . . . .  print function
##
InstallMethod( PrintObj, true, [ IsRationalClassGroupRep ], 0,
    function( cl )
    Print( "RationalClass( ", ActingDomain( cl ), ", ",
           Representative( cl ), " )" );
end );

InstallMethod( ViewObj, true, [ IsRationalClassGroupRep ], 0,
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
    true,
    [ IsRationalClassGroupRep ], 0,
    cl -> IndexInParent( GaloisGroup( cl ) ) *
          Index( ActingDomain( cl ), StabilizerOfExternalSet( cl ) ) );

#############################################################################
##
#F  DecomposedRationalClass( <cl> ) . . . . . decompose into ordinary classes
##
InstallGlobalFunction( DecomposedRationalClass, function( cl )
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
#R  IsRationalClassGroupEnumerator  . . . . . . enumerator for rational class
##
DeclareRepresentation( "IsRationalClassGroupEnumerator",
      IsDomainEnumerator and IsAttributeStoringRep,
      [ "rightTransversal" ] );

#############################################################################
##
#M  Enumerator( <rcl> ) . . . . . . . . . . . . . . . . . . of rational class
##
InstallMethod( Enumerator, true, [ IsRationalClassGroupRep ], 0,
    function( rcl )
    local   enum;

    enum := Objectify( NewType( FamilyObj( rcl ),
                IsRationalClassGroupEnumerator ),
                rec( rightTransversal := RightTransversal
                ( ActingDomain( rcl ), StabilizerOfExternalSet( rcl ) ) ) );
    SetUnderlyingCollection( enum, rcl );
    return enum;
end );

InstallMethod( \[\], true, [ IsRationalClassGroupEnumerator,
        IsPosInt ], 0,
    function( enum, pos )
    local   rcl,  rep,  gal,  T,  pow;

    rcl := UnderlyingCollection( enum );
    rep := Representative( rcl );
    gal := RightTransversalInParent( GaloisGroup( rcl ) );
    T := enum!.rightTransversal;
    pos := pos - 1;
    pow := QuoInt( pos, Length( T ) ) + 1;
    pos := pos mod Length( T ) + 1;
    # if gal[pow]=0 then the element is the identity anyhow, no need to worry.
    return ( rep ^ T[ pos ] ) ^ Int( gal[ pow ] );
end );

InstallMethod( PositionCanonical, true,
  [ IsRationalClassGroupEnumerator, IsMultiplicativeElementWithInverse ], 0,
function( enum, elm )
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

InstallOtherMethod( CentralizerOp, true, [ IsRationalClassGroupRep ], 0,
    StabilizerOfExternalSet );

#############################################################################
##
#M  AsList( <rcl> ) . . . . . . . . . . . . . . . . . . .  by orbit algorithm
##
InstallMethod( AsList, true, [ IsRationalClassGroupRep ], 0,
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
InstallOtherMethod( GaloisGroup, true, [ IsRationalClassGroupRep ], 0,
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
InstallMethod( RationalClasses, "trial", true, [ IsGroup ], 0,
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
        for i  in Set(FactorsInt(Order(elm)))  do
            RationalClassesTry( G, classes, elm ^ i );
        od;

    fi;

end );

InstallMethod( RationalClasses,"solvable",true,[ CanEasilyComputePcgs ], 20,
    function( G )
    local   rcls,  cls,  cl,  c,  sum, size;
    
    size := Size(G);
    rcls := [  ];
    if IsPrimePowerInt( size )  then
        for cl  in RationalClassesSolvableGroup( G, 1 )  do
            c := RationalClass( G, cl.representative );
            SetStabilizerOfExternalSet( c, cl.centralizer );
            SetGaloisGroup( c, cl.galoisGroup );
            Add( rcls, c );
        od;
    else
        sum := 0;
        for cl in ConjugacyClasses(G)  do
            c := RationalClass( G, Representative(cl) );
            SetStabilizerOfExternalSet( c, Centralizer(cl) );
            if sum < size and not c in rcls  then
                Add( rcls, c );
                sum := sum + Size( c );
                if sum = size and not IsBound(cls)  then
                    break;
                fi;
            fi;
        od;

    fi;

    return rcls;
end );

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
    pro := OneDimSubspacesTransversal( ff ^ Length( pcgs ) );
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


#############################################################################
##
#E

