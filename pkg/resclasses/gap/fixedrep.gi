#############################################################################
##
#W  fixedrep.gi             GAP4 Package `ResClasses'             Stefan Kohl
##
##  This file contains implementations of methods and functions for
##  computing with unions of residue classes with distinguished ("fixed")
##  representatives.
##
#############################################################################

#############################################################################
##
#S  Implications between the categories. ////////////////////////////////////
##
#############################################################################

InstallTrueMethod( IsUnionOfResidueClassesWithFixedRepresentatives,
                   IsUnionOfResidueClassesOfZorZ_piWithFixedRepresentatives);
InstallTrueMethod( IsUnionOfResidueClassesOfZorZ_piWithFixedRepresentatives,
                   IsUnionOfResidueClassesOfZWithFixedRepresentatives );
InstallTrueMethod( IsUnionOfResidueClassesOfZorZ_piWithFixedRepresentatives,
                   IsUnionOfResidueClassesOfZ_piWithFixedRepresentatives );
InstallTrueMethod( IsUnionOfResidueClassesWithFixedRepresentatives,
                   IsUnionOfResidueClassesOfGFqxWithFixedRepresentatives );

#############################################################################
##
#S  Residue classes (mod m). ////////////////////////////////////////////////
##
#############################################################################

#############################################################################
##
#F  AllResidueClassesWithFixedRepresentativesModulo( [ <R>, ] <m> )
#F  AllResidueClassesWithFixedRepsModulo( [ <R>, ] <m> )
##
InstallGlobalFunction( AllResidueClassesWithFixedRepresentativesModulo,

  function ( arg )

    local  R, m;

    if   Length(arg) = 2
    then R := arg[1]; m := arg[2];
    else m := arg[1]; R := DefaultRing(m); fi;
    if IsZero(m) or not m in R then return fail; fi;
    return List(AllResidues(R,m),r->ResidueClassWithFixedRep(R,m,r));
  end );

#############################################################################
##
#S  Construction of unions of residue classes with fixed representatives. ///
##
#############################################################################

#############################################################################
##
#M  UnionOfResidueClassesWithFixedRepresentativesCons(<filter>,<R>,<classes>)
##
InstallMethod( UnionOfResidueClassesWithFixedRepresentativesCons,
               "for Z, Z_pi and GF(q)[x] (ResClasses)", ReturnTrue,
               [ IsUnionOfResidueClassesWithFixedRepresentatives,
                 IsRing, IsList ], 0,

  function ( filter, R, classes )

    local  Result, fam, type, rep;

    if not ( IsIntegers( R ) or IsZ_pi( R )
             or (     IsFiniteFieldPolynomialRing( R )
                  and IsUnivariatePolynomialRing( R ) ) )
    then TryNextMethod( ); fi;
    fam := ResidueClassUnionsFamily( R, true );
    if   IsIntegers( R )
    then type := IsUnionOfResidueClassesOfZWithFixedRepresentatives;
    elif IsZ_pi( R )
    then type := IsUnionOfResidueClassesOfZ_piWithFixedRepresentatives;
    elif IsPolynomialRing( R )
    then type := IsUnionOfResidueClassesOfGFqxWithFixedRepresentatives; fi;
    rep := IsUnionOfResidueClassesWithFixedRepsStandardRep;
    Result := Objectify( NewType( fam, type and rep ),
                         rec( classes := AsSortedList( classes ) ) );
    if classes <> [] then
      SetSize( Result, infinity ); SetIsFinite( Result, false );
      SetIsEmpty( Result, false );
      SetRepresentative( Result, classes[1][2] );
    else
      SetSize( Result, 0 ); SetIsEmpty( Result, true );
    fi;
    return Result;
  end );

#############################################################################
##
#F  UnionOfResidueClassesWithFixedRepresentatives( <R>, <classes> )
#F  UnionOfResidueClassesWithFixedRepresentatives( <classes> )
#F  UnionOfResidueClassesWithFixedReps( <R>, <classes> )
#F  UnionOfResidueClassesWithFixedReps( <classes> )
##
InstallGlobalFunction( UnionOfResidueClassesWithFixedRepresentatives,

  function ( arg )

    local  R, classes, usage;

    usage := Concatenation("usage: UnionOfResidueClassesWithFixedRepresenta",
                           "tives( [ <R>, ] <classes> )\n");
    if not Length(arg) in [1,2] then Error(usage); return fail; fi;
    if Length(arg) = 2 then R := arg[1];   classes := arg[2];
                       else R := Integers; classes := arg[1]; fi;
    if   not IsIntegers(R) and not IsZ_pi(R) and not IsPolynomialRing(R)
      or not IsList(classes) or not ForAll(classes,IsList)
      or not ForAll(classes,cl->Length(cl)=2)
      or not IsSubset(R,Flat(classes))
      or IsZero(Product(List(classes,cl->cl[1])))
    then Error(usage); return fail; fi;
    return UnionOfResidueClassesWithFixedRepresentativesCons(
             IsUnionOfResidueClassesWithFixedRepresentatives, R, classes );
  end );

#############################################################################
##
#F  ResidueClassWithFixedRepresentative( <R>, <m>, <r> )
#F  ResidueClassWithFixedRepresentative( <m>, <r> )
#F  ResidueClassWithFixedRep( <R>, <m>, <r> )
#F  ResidueClassWithFixedRep( <m>, <r> )
##
InstallGlobalFunction( ResidueClassWithFixedRepresentative,

  function ( arg )

    local  R, m, r, cl, usage;

    usage := Concatenation("usage: ResidueClassWithFixedRepresentative",
                           "( [ <R>, ] <m>, <r> ) for a ring <R> and ",
                           "elements <m> and <r>.\n");
    if not Length(arg) in [2,3] then Error(usage); return fail; fi;
    if Length(arg) = 3 then R := arg[1];   m := arg[2]; r := arg[3];
                       else R := Integers; m := arg[1]; r := arg[2]; fi;
    if not ( IsRing(R) and m in R and r in R )
    then Error(usage); return fail; fi;
    cl := UnionOfResidueClassesWithFixedRepresentatives( R, [ [ m, r ] ] );
    SetIsResidueClassWithFixedRepresentative( cl, true );
    return cl;
  end );

#############################################################################
##
#M  IsResidueClassWithFixedRepresentative( <obj> )  . . . . .  general method
##
InstallMethod( IsResidueClassWithFixedRepresentative,
               "general method (ResClasses)", true, [ IsObject ], 0,

  function ( obj )
    if    IsUnionOfResidueClassesWithFixedRepresentatives(obj)
      and Length(Classes(obj)) = 1
    then return true; fi;
    return false;
  end );

#############################################################################
##
#M  Modulus( <cl> ) . . . . . . for residue classes with fixed representative
##
InstallMethod( Modulus,
               "for residue classes with fixed representative (ResClasses)",
               true, [ IsResidueClassWithFixedRepresentative ], SUM_FLAGS,
               cl -> Classes(cl)[1][1] );

#############################################################################
##
#M  Residue( <cl> ) . . . . . . for residue classes with fixed representative
##
InstallMethod( Residue,
               "for residue classes with fixed representative (ResClasses)",
               true, [ IsResidueClassWithFixedRepresentative ], 0,
               cl -> Classes(cl)[1][2] );

#############################################################################
##
#M  AsOrdinaryUnionOfResidueClasses( <U> )
##
InstallMethod( AsOrdinaryUnionOfResidueClasses,
               "for unions of residue classes with fixed rep's (ResClasses)",
               true, [ IsUnionOfResidueClassesWithFixedRepresentatives ], 0,

  function ( U )

    local  R, cl;

    R := UnderlyingRing(FamilyObj(U));
    return Union(List(Classes(U),cl->ResidueClass(R,cl[1],cl[2])));
  end );

#############################################################################
##
#S  Accessing the components of a union of residue classes object. //////////
##
#############################################################################

#############################################################################
##
#M  Modulus( <U> ) . . . . . . for unions of residue classes with fixed rep's
##
InstallMethod( Modulus,
               "for unions of residue classes with fixed rep's (ResClasses)",
               true, [ IsUnionOfResidueClassesWithFixedRepresentatives ], 0,
               U -> Lcm( UnderlyingRing( FamilyObj( U ) ),
                         List( U!.classes, cl -> cl[1] ) ) );

#############################################################################
##
#M  Classes( <U> ) . . . . . . for unions of residue classes with fixed rep's
##
InstallMethod( Classes,
               "for unions of residue classes with fixed rep's (ResClasses)",
               true, [ IsUnionOfResidueClassesWithFixedRepresentatives ], 0,
               U -> U!.classes );

#############################################################################
##
#S  Testing for equality. ///////////////////////////////////////////////////
##
#############################################################################

#############################################################################
##
#M  \=( <U1>, <U2> ) . . . . . for unions of residue classes with fixed rep's
##
InstallMethod( \=,

  "for two unions of residue classes with fixed rep's (ResClasses)",
  IsIdenticalObj,
  [ IsUnionOfResidueClassesWithFixedRepresentatives,
    IsUnionOfResidueClassesWithFixedRepresentatives ], 0,

  function ( U1, U2 )
    return U1!.classes = U2!.classes;
  end );

#############################################################################
##
#M  \<( <U1>, <U2> ) . . . . . for unions of residue classes with fixed rep's
##
##  A total ordering of unions of residue classes with fixed representatives
##  (for technical purposes, only).
##
InstallMethod( \<,

  "for two unions of residue classes with fixed rep's (ResClasses)",
  IsIdenticalObj,
  [ IsUnionOfResidueClassesWithFixedRepresentatives,
    IsUnionOfResidueClassesWithFixedRepresentatives ], 0,

  function ( U1, U2 ) return U1!.classes < U2!.classes; end );

#############################################################################
##
#S  Membership and multiplicity. ////////////////////////////////////////////
##
#############################################################################

#############################################################################
##
#M  \in( <n>, <U> ) . for ring element and union of res.-cl. with fixed rep's
##
InstallMethod( \in,

  "for a ring element and a union of res.-cl. with fixed rep's (ResClasses)",
  ReturnTrue,
  [ IsRingElement, IsUnionOfResidueClassesWithFixedRepresentatives ],
  SUM_FLAGS,

  function ( n, U ) return Multiplicity(n,U) >= 1; end );

#############################################################################
##
#M  \in( <cl>, <U> ) . . . for res.-cl and union of res.-cl. with fixed rep's
##
InstallMethod( \in,

  "for a res.-cl. and a union of res.-cl. with fixed rep's (ResClasses)",
  ReturnTrue,
  [ IsUnionOfResidueClassesWithFixedRepresentatives,
    IsUnionOfResidueClassesWithFixedRepresentatives ], 0,

  function ( cl, U )
    if Length(cl!.classes) > 1 then TryNextMethod(); fi;
    return cl!.classes[1] in U!.classes;
  end );

#############################################################################
##
#M  Multiplicity( <n>, <U> )
##
InstallMethod( Multiplicity,

  "for a ring element and a union of res.-cl. with fixed rep's (ResClasses)",
  ReturnTrue,
  [ IsRingElement, IsUnionOfResidueClassesWithFixedRepresentatives ], 0,

  function ( n, U )
    if not n in UnderlyingRing(FamilyObj(U)) then return 0; fi;
    return Number(U!.classes,cl->n mod cl[1] = cl[2]);
  end );

#############################################################################
##
#M  Multiplicity( <cl>, <U> )
##
InstallMethod( Multiplicity,

  "for a res.-cl. and union of res.-cl. with fixed rep's (ResClasses)",
  ReturnTrue,
  [ IsUnionOfResidueClassesWithFixedRepresentatives,
    IsUnionOfResidueClassesWithFixedRepresentatives ], 0,

  function ( cl, U )
    return Number( AsListOfClasses( U ), unioncl -> unioncl = cl );
  end );

#############################################################################
##
#S  Density and subset relations. ///////////////////////////////////////////
##
#############################################################################

#############################################################################
##
#M  Density( <U> ) . . . . . . for unions of residue classes with fixed rep's
##
InstallOtherMethod( Density,

  "for unions of residue classes with fixed rep's (ResClasses)",
  true, [ IsUnionOfResidueClassesWithFixedRepresentatives ], 0,

  function ( U )

    local  R;

    R := UnderlyingRing(FamilyObj(U));
    return Sum(List(U!.classes,c->1/Length(AllResidues(R,c[1]))));
  end );

#############################################################################
##
#M  IsOverlappingFree( <U> ) . for unions of residue classes with fixed rep's
##
InstallMethod( IsOverlappingFree,

  "for unions of residue classes with fixed rep's (ResClasses)",
  true, [ IsUnionOfResidueClassesWithFixedRepresentatives ], 0,

  U -> Density( U ) = Density( AsOrdinaryUnionOfResidueClasses( U ) ) );

#############################################################################
##
#M  IsSubset( <U1>, <U2> ) . . for unions of residue classes with fixed rep's
##
InstallMethod( IsSubset,

  "for two unions of residue classes with fixed rep's (ResClasses)",
  IsIdenticalObj,
  [ IsUnionOfResidueClassesWithFixedRepresentatives,
    IsUnionOfResidueClassesWithFixedRepresentatives ], 0,

  function ( U1, U2 )

    local  R, cls, classes, numbers;

    R       := UnderlyingRing(FamilyObj(U1));
    cls     := [Classes(U1),Classes(U2)];
    classes := Set(Union(cls));
    numbers := List(classes,cl1->List(cls,list->Number(list,cl2->cl2=cl1)));
    return ForAll(numbers,num->num[1]>=num[2]); 
  end );

#############################################################################
##
#S  Computing unions, intersections and differences. ////////////////////////
##
#############################################################################

#############################################################################
##
#M  Union2( <U1>, <U2> ) . . . for unions of residue classes with fixed rep's
##
InstallMethod( Union2,

  "for two unions of residue classes with fixed rep's (ResClasses)",
  IsIdenticalObj,
  [ IsUnionOfResidueClassesWithFixedRepresentatives,
    IsUnionOfResidueClassesWithFixedRepresentatives ], 0,

  function ( U1, U2 )
    return UnionOfResidueClassesWithFixedRepresentatives(
             UnderlyingRing(FamilyObj(U1)),
             Concatenation(Classes(U1),Classes(U2)));
  end );

#############################################################################
##
#M  Intersection2( <U1>, <U2> ) . for unions of res.-classes with fixed rep's
##
InstallMethod( Intersection2,

  "for two unions of residue classes with fixed rep's (ResClasses)",
  IsIdenticalObj,
  [ IsUnionOfResidueClassesWithFixedRepresentatives,
    IsUnionOfResidueClassesWithFixedRepresentatives ], 0,

  function ( U1, U2 )

    local  R, cls, cls1, cls2, int, cl;

    R := UnderlyingRing(FamilyObj(U1));
    cls1 := Classes(U1); cls2 := Classes(U2); int := Intersection(cls1,cls2);
    cls := Concatenation(List(int,cl->ListWithIdenticalEntries(
           Minimum(Number(cls1,cl1->cl1=cl),Number(cls2,cl2->cl2=cl)),cl)));
    return UnionOfResidueClassesWithFixedRepresentatives( R, cls );
  end );

#############################################################################
##
#M  Difference( <U1>, <U2> ) . for unions of residue classes with fixed rep's
##
InstallMethod( Difference,

  "for two unions of residue classes with fixed rep's (ResClasses)",
  IsIdenticalObj,
  [ IsUnionOfResidueClassesWithFixedRepresentatives,
    IsUnionOfResidueClassesWithFixedRepresentatives ], 0,

  function ( U1, U2 )

    local  Multiple, R, cls, classes, numbers, diffcls;

    Multiple := function ( cl, k )
      if   k < 0
      then return ListWithIdenticalEntries(-k,[cl[1],cl[1]-cl[2]]);
      else return ListWithIdenticalEntries(k,cl); fi;
    end;

    R       := UnderlyingRing(FamilyObj(U1));
    cls     := [Classes(U1),Classes(U2)];
    classes := Set(Union(cls));
    numbers := List(classes,cl1->List(cls,list->Number(list,cl2->cl2=cl1)));
    numbers := TransposedMat(numbers); numbers := numbers[1] - numbers[2];
    diffcls := Concatenation(List([1..Length(numbers)],
                                  i->Multiple(classes[i],numbers[i])));
    return UnionOfResidueClassesWithFixedRepresentatives( R, diffcls );
  end );

#############################################################################
##
#S  Applying arithmetic operations to the residue classes. //////////////////
##
#############################################################################

#############################################################################
##
#M  \+( <U>, <x> ) .  for union of res.-cl. with fixed rep's and ring element
##
InstallOtherMethod( \+,

  "for a union of res.-cl. with fixed rep's and a ring element (ResClasses)",
  ReturnTrue,
  [ IsUnionOfResidueClassesWithFixedRepresentatives, IsRingElement ], 0,

  function ( U, x )
    return UnionOfResidueClassesWithFixedRepresentatives(
             UnderlyingRing(FamilyObj(U)),
             List(Classes(U),cl->[cl[1],cl[2]+x]) );
  end );

#############################################################################
##
#M  \+( <x>, <U> ) .  for ring element and union of res.-cl. with fixed rep's
##
InstallOtherMethod( \+,

  "for a ring element and a union of res.-cl. with fixed rep's (ResClasses)",
  ReturnTrue,
  [ IsRingElement, IsUnionOfResidueClassesWithFixedRepresentatives ], 0,

  function ( x, U ) return U + x; end );

#############################################################################
##
#M  AdditiveInverseOp( <U> ) . for unions of residue classes with fixed rep's
##
InstallOtherMethod( AdditiveInverseOp,

  "for unions of residue classes with fixed rep's (ResClasses)",
  ReturnTrue, [ IsUnionOfResidueClassesWithFixedRepresentatives ], 0,

  function ( U )

    local  R, invclasses;

    R := UnderlyingRing(FamilyObj(U));
    invclasses := List(Classes(U),cl->[-cl[1],-cl[2]]);
    return UnionOfResidueClassesWithFixedRepresentatives(R,invclasses);
  end );

#############################################################################
##
#M  \-( <U>, <x> ) .  for union of res.-cl. with fixed rep's and ring element
##
InstallOtherMethod( \-,

  "for a union of res.-cl. with fixed rep's and a ring element (ResClasses)",
  ReturnTrue,
  [ IsUnionOfResidueClassesWithFixedRepresentatives, IsRingElement ], 0,

  function ( U, x ) return U + (-x); end );

#############################################################################
##
#M  \-( <x>, <U> ) .  for ring element and union of res.-cl. with fixed rep's
##
InstallOtherMethod( \-,

  "for a ring element and a union of res.-cl. with fixed rep's (ResClasses)",
  ReturnTrue,
  [ IsRingElement, IsUnionOfResidueClassesWithFixedRepresentatives ], 0,

  function ( x, U ) return (-U) + x; end );

#############################################################################
##
#M  \*( <U>, <x> ) .  for union of res.-cl. with fixed rep's and ring element
##
InstallOtherMethod( \*,

  "for a union of res.-cl. with fixed rep's and a ring element (ResClasses)",
  ReturnTrue,
  [ IsUnionOfResidueClassesWithFixedRepresentatives, IsRingElement ], 0,

  function ( U, x )

    local  R;

    R := UnderlyingRing(FamilyObj(U));
    return UnionOfResidueClassesWithFixedRepresentatives( R, Classes(U)*x );
  end );

#############################################################################
##
#M  \*( <x>, <U> ) .  for ring element and union of res.-cl. with fixed rep's
##
InstallOtherMethod( \*,

  "for a ring element and a union of res.-cl. with fixed rep's (ResClasses)",
  ReturnTrue,
  [ IsRingElement, IsUnionOfResidueClassesWithFixedRepresentatives ], 0,

  function ( x, U ) return U * x; end );

#############################################################################
##
#M  \/( <U>, <x> ) .  for union of res.-cl. with fixed rep's and ring element
##
InstallOtherMethod( \/,

  "for a union of res.-cl. with fixed rep's and a ring element (ResClasses)",
  ReturnTrue,
  [ IsUnionOfResidueClassesWithFixedRepresentatives, IsRingElement ], 0,

  function ( U, x )

    local  R, quotclasses;

    R := UnderlyingRing(FamilyObj(U));
    quotclasses := Classes(U)/x;
    if not IsSubset(R,Flat(quotclasses)) then TryNextMethod(); fi;
    return UnionOfResidueClassesWithFixedRepresentatives( R, quotclasses );
  end );

#############################################################################
##
#S  Computing partitions into residue classes. //////////////////////////////
##
#############################################################################

#############################################################################
##
#M  AsListOfClasses( <U> ) . . for unions of residue classes with fixed rep's
##
InstallMethod( AsListOfClasses,
               "for unions of residue classes with fixed rep's (ResClasses)",
               true, [ IsUnionOfResidueClassesWithFixedRepresentatives ], 0,

  U -> SortedList( List( Classes( U ),
                   cl -> ResidueClassWithFixedRepresentative(
                   UnderlyingRing( FamilyObj( U ) ), cl[1], cl[2] ) ) ) );

#############################################################################
##
#S  The invariants Delta and Rho. ///////////////////////////////////////////
##
#############################################################################

#############################################################################
##
#M  Delta( <U> ) . . . .  for unions of residue classes of Z with fixed rep's
##
InstallMethod( Delta,

  "for unions of residue classes of Z with fixed rep's (ResClasses)",
  true, [ IsUnionOfResidueClassesOfZWithFixedRepresentatives ], 0,

  U -> Sum(List(Classes(U),c->c[2]/c[1])) - Length(Classes(U))/2 );

#############################################################################
##
#M  Rho( <U> ) . . . . .  for unions of residue classes of Z with fixed rep's
##
InstallMethod( Rho,

  "for unions of residue classes of Z with fixed rep's (ResClasses)", true,
  [ IsUnionOfResidueClassesOfZWithFixedRepresentatives ], 0,

  function ( U )

    local  product, factor, classes, cl, delta;

    product := 1;
    classes := AsListOfClasses(U);
    for cl in classes do
      delta  := Delta(cl)/2;
      factor := E(DenominatorRat(delta))^NumeratorRat(delta);
      if Classes(cl)[1][1] < 0 then factor := factor^-1; fi;
      product := product * factor;
    od;
    return product;
  end );

#############################################################################
##
#M  RepresentativeStabilizingRefinement( <U>, <k> )
##
InstallMethod( RepresentativeStabilizingRefinement,

  Concatenation("for a union of residue classes of Z with fixed rep's and ",
                "a positive integer (ResClasses)"), ReturnTrue,
  [ IsUnionOfResidueClassesOfZWithFixedRepresentatives, IsPosInt ], 0,

  function ( U, k )

    local  classes;

    classes := Concatenation(List(Classes(U),
                                  cl->List([0..k-1],
                                           i->[k*cl[1],i*cl[1]+cl[2]])));
    return UnionOfResidueClassesWithFixedRepresentatives(Integers,classes);
  end );

#############################################################################
##
#M  RepresentativeStabilizingRefinement( <U>, 0 )
##
InstallMethod( RepresentativeStabilizingRefinement,

  Concatenation("for a union of residue classes of Z with fixed rep's and 0",
                " (simplify) (ResClasses)"),
  ReturnTrue, [ IsUnionOfResidueClassesOfZWithFixedRepresentatives,
                IsInt and IsZero ], 0,

  function ( U, k )

    local  cls, olds, mods, parts, part, mp, rp, kp, m, complete, c,
           progression, replacement, found, cl, pos;

    cls := ShallowCopy(Classes(U));
    if Length(cls) < 2 then return U; fi;
    repeat
      olds  := ShallowCopy(cls);
      mods  := Set(List(cls,cl->cl[1]));
      parts := List(mods,m->Filtered(cls,cl->cl[1]=m));
      found := false;
      for part in parts do
        mp := part[1][1]; rp := Set(part,cl->cl[2]);
        for kp in Intersection([2..Length(rp)],DivisorsInt(mp)) do
          m := mp/kp;
          complete := First(Collected(rp mod m),c->c[2]=kp);
          if complete <> fail then
            progression := Set(Filtered(part,t->t[2] mod m = complete[1]));
            if   Set(List([1..Length(progression)-1],
                          i->progression[i+1][2]-progression[i][2]))
              <> [AbsInt(m)]
            then continue; fi;
            if m < 0 then progression := Reversed(progression); fi;
            replacement := [[m,progression[1][2]]];
            while progression <> [] do
              cl := progression[1];
              pos := Position(cls,cl);
              Unbind(cls[pos]);
              cls := SortedList(cls); 
              Unbind(progression[1]);
              progression := SortedList(progression);
            od;
            cls := Concatenation(cls,replacement);
            found := true;
          fi;
          if found then break; fi;
        od;
        if found then break; fi;
      od;
    until cls = olds;
    return UnionOfResidueClassesWithFixedRepresentatives(Integers,cls);
  end );

#############################################################################
##
#S  Viewing, printing and displaying unions of residue classes. /////////////
##
#############################################################################

#############################################################################
##
#M  ViewObj( <U> ) . . . . . . for unions of residue classes with fixed rep's
##
InstallMethod( ViewObj,
               "for unions of residue classes with fixed rep's (ResClasses)",
               true, [ IsUnionOfResidueClassesWithFixedRepresentatives ], 0,

  function ( U )

    local  R, classes, l, i, short;

    short := RESCLASSES_VIEWINGFORMAT = "short";
    R := UnderlyingRing(FamilyObj(U));
    classes := Classes(U); l := Length(classes);
    if l = 0 or l > 8 or IsPolynomialRing(R) and l > 3 then
      if l = 0 then
        if not short then
          Print("Empty union of residue classes of ",RingToString(R),
                " with fixed representatives");
        else
          Print("[]");
        fi;
      else
        Print("<union of ",l," residue classes");
        if   not short
        then Print(" of ",RingToString(R)," with fixed representatives>");
        else Print(" with fixed rep's>"); fi;
      fi;
    else
      for i in [1..l] do
        if i > 1 then Print(" U "); fi;
        Print("[",classes[i][2],"/",classes[i][1],"]");
      od;
    fi;
  end );

#############################################################################
##
#M  String( <U> ) . . . . . .  for unions of residue classes with fixed rep's
##
InstallMethod( String,
               "for unions of residue classes with fixed rep's (ResClasses)",
               true, [ IsUnionOfResidueClassesWithFixedRepresentatives ], 0,

  function ( U )

    local  R, classes;

    R := UnderlyingRing(FamilyObj(U)); classes := Classes(U);
    if Length(classes) = 1 then
      return Concatenation("ResidueClassWithFixedRepresentative( ",
                           String(R),", ",String(classes[1][1]),", ",
                           String(classes[1][2])," )");
    else
      return Concatenation("UnionOfResidueClassesWithFixedRepresentative",
                           "s( ",String(R),", ",String(classes)," )");
    fi;
  end );

#############################################################################
##
#M  PrintObj( <U> ) . . . . .  for unions of residue classes with fixed rep's
##
InstallMethod( PrintObj,
               "for unions of residue classes with fixed rep's (ResClasses)",
               true, [ IsUnionOfResidueClassesWithFixedRepresentatives ], 0,

  function ( U )

    local  R, classes;

    R := UnderlyingRing(FamilyObj(U)); classes := Classes(U);
    if Length(classes) = 1 then
      Print("ResidueClassWithFixedRepresentative( ",R,", ",
            classes[1][1],", ",classes[1][2]," )");
    else
      Print("UnionOfResidueClassesWithFixedRepresentatives( ",R,", ",
            classes," )");
    fi;
  end );

#############################################################################
##
#M  Display( <U> ) . . . . . . for unions of residue classes with fixed rep's
##
InstallMethod( Display,
               "for unions of residue classes with fixed rep's (ResClasses)",
               true, [ IsUnionOfResidueClassesWithFixedRepresentatives ], 0,

  function ( U )

    local  R, classes, l, i;

    R := UnderlyingRing(FamilyObj(U));
    classes := Classes(U); l := Length(classes);
    if l = 0 then View(U); else
      for i in [1..l] do
          if i > 1 then Print(" U "); fi;
          Print("[",classes[i][2],"/",classes[i][1],"]");
      od;
    fi;
    Print("\n");
  end );

#############################################################################
##
#E  fixedrep.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here