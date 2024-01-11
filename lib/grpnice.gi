#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This  file  contains generic     methods   for groups handled    by  nice
##  monomorphisms..
##

#############################################################################
##
#M  SetNiceMonomorphism(<G>,<hom>)
##
##  We install a special setter method because we have to make sure that only
##  injective maps get stored as nice monomorphisms.
##  More precisely, the stored map must know that it is injective,
##  otherwise computing its kernel may run into an infinite recursion.
#T This can be activated only after changing some packages accordingly.
##
##  Besides this, we want to tell every nice monomorphism that it is one.
##
InstallMethod(SetNiceMonomorphism,"set `IsNiceomorphism' property",true,
  [IsGroup,IsGroupGeneralMapping],SUM_FLAGS+10, #override system setter
function(G,hom)
# if not ( HasIsInjective( hom ) and IsInjective( hom ) ) then
#   Error( "'NiceMonomorphism' values must have the 'IsInjective' flag" );
# fi;
  SetFilterObj(hom,IsNiceMonomorphism);
  TryNextMethod();
end);


#############################################################################
##
#O  RestrictedNiceMonomorphism(<hom>,<G>)
##
InstallGlobalFunction(RestrictedNiceMonomorphism,
function(hom,G)
  hom:=RestrictedMapping(hom,G:surjective);

  # CompositionMapping methods need this to avoid forming an AsGHBI of an
  # nice mono!
  SetFilterObj(hom,IsNiceMonomorphism);
  Range(hom); # we will need this for example to translate homomorphism props.
              # (if we only map images we don't need the restricted hom)

  return hom;
end);

#############################################################################
##
#M  GeneratorsOfMagmaWithInverses( <group> )  .  get generators from nice obj
##
InstallMethod( GeneratorsOfMagmaWithInverses,
    true,
    [ IsGroup and IsHandledByNiceMonomorphism ],
    0,

function( grp )
    local   nice;
    nice := NiceMonomorphism(grp);
    return List( GeneratorsOfGroup(NiceObject(grp)),
                 x -> PreImagesRepresentative(nice,x) );
end );


#############################################################################
##
#M  SmallGeneratingSet( <group> )  .  get generators from nice obj
##
InstallMethod( SmallGeneratingSet, true,
    [ IsGroup and IsHandledByNiceMonomorphism ], 0,

function( grp )
    local   nice;
    nice := NiceMonomorphism(grp);
    return List( SmallGeneratingSet(NiceObject(grp)),
                 x -> PreImagesRepresentative(nice,x) );
end );


#############################################################################
##
#M  MinimalGeneratingSet( <group> )  .  get generators from nice obj
##
InstallMethod( MinimalGeneratingSet, true,
    [ IsGroup and IsHandledByNiceMonomorphism ], 0,

function( grp )
    local   nice;
    nice := NiceMonomorphism(grp);
    return List( MinimalGeneratingSet(NiceObject(grp)),
                 x -> PreImagesRepresentative(nice,x) );
end );


#############################################################################
##
#M  GroupByNiceMonomorphism( <nice>, <group> )  construct group with nice obj
##
InstallMethod( GroupByNiceMonomorphism,
    true,
    [ IsGroupHomomorphism,
      IsGroup ],
    0,

function( nice, grp )
    local   fam,  pre;

    if not ( HasIsInjective( nice ) and IsInjective( nice ) ) then
      Error( "<nice> is not known to be injective" );
    fi;
    fam := FamilyObj( Source(nice) );
    pre := Objectify(NewType(fam,IsGroup and IsAttributeStoringRep), rec());
    SetIsHandledByNiceMonomorphism( pre, true );
    SetNiceMonomorphism( pre, nice );
    SetNiceObject( pre, grp );
    SetOne(pre,One(Source(nice)));
    UseIsomorphismRelation(grp,pre);
    return pre;
end );


#############################################################################
##
#M  NiceObject( <group> ) . . . . . . . . . . . . .  get nice object of group
##
InstallMethod( NiceObject,
    true,
    [ IsGroup and IsHandledByNiceMonomorphism ],
    0,

function( G )
    local   nice,  img,  D;

    nice := NiceMonomorphism( G );
    # nice might have a larger domain, but if we find out cheaply, it has
    # the same, we don't need to map the generators of G again.
    if IsIdenticalObj(G,Source(nice)) then
      img := ImagesSource( nice );
    else
      img := ImagesSet( nice, G );
    fi;
    if     IsActionHomomorphism( nice )
       and HasBaseOfGroup( UnderlyingExternalSet( nice ) )  then
        if not IsBound( UnderlyingExternalSet( nice )!.basePermImage )  then
            D := HomeEnumerator( UnderlyingExternalSet( nice ) );
            UnderlyingExternalSet( nice )!.basePermImage :=
              List(BaseOfGroup(UnderlyingExternalSet(nice)),
                   b->PositionCanonical(D,b));
        fi;
        SetBaseOfGroup( img, UnderlyingExternalSet( nice )!.basePermImage );
    fi;
    return img;
end );


#############################################################################
##
#M  NiceMonomorphism( <group> ) . . construct a nice monomorphism from parent
##
InstallMethod(NiceMonomorphism,
    "for subgroups that get the nice monomorphism by their parent", true,
    [ IsGroup and IsHandledByNiceMonomorphism and HasParent],
    # to rank higher than matrix group methods.
    {} -> RankFilter(IsFinite and IsMatrixGroup),

function(G)
    local P;

    P :=Parent(G);
    if not (HasIsHandledByNiceMonomorphism(P)
        and IsHandledByNiceMonomorphism(P) and HasNiceMonomorphism(P)) then
      TryNextMethod();
    fi;
    return NiceMonomorphism(P);
end );

#############################################################################
##
#M  NiceMonomorphism( <G> ) . . . . . . . . . . . . . . . . regular operation
##
InstallMethod( NiceMonomorphism, "regular action", true,
        [ IsGroup and IsHandledByNiceMonomorphism ], 0,
function( G )
    if not HasGeneratorsOfGroup( G )  then
      TryNextMethod();
    elif not HasOne( G ) and Length(GeneratorsOfGroup(G))>0  then
      SetOne( G, One( GeneratorsOfGroup( G )[ 1 ] ) );
    fi;

    if not HasEnumerator(G) then
      SetEnumerator(G,GroupEnumeratorByClosure(G));
    fi;
    return RegularActionHomomorphism( G );
end );

#############################################################################
##
#M  NiceMonomorphism( <G> ) . . . . . . . . .  independent abelian generators
##
InstallMethod( NiceMonomorphism, "via IsomorphismAbelianGroupViaIndependentGenerators", true,
        [ IsGroup and IsHandledByNiceMonomorphism and CanEasilyComputeWithIndependentGensAbelianGroup ], 0,
    function( G )
    return IsomorphismAbelianGroupViaIndependentGenerators( IsPermGroup, G );
end );


#############################################################################
##
#M  \=( <G>, <H> )  . . . . . . . . . . . . . .  test if two groups are equal
##
PropertyMethodByNiceMonomorphismCollColl( \=,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  \in( <elm>, <G> ) . . . . . . . . . . . . . . . . .  test if <elm> in <G>
##
InstallMethod( \in,
    "by nice monomorphism",
    IsElmsColls,
    [ IsMultiplicativeElementWithInverse,
      IsGroup and IsHandledByNiceMonomorphism ],
    0,

function( elm, G )
    local   nice,  img;

    if HasGeneratorsOfGroup(G) and elm in GeneratorsOfGroup(G) then
      return true;
    fi;
    nice := NiceMonomorphism( G );
    img  := ImagesRepresentative( nice, elm:actioncanfail:=true );
    return img<>fail and img in NiceObject( G )
       and PreImagesRepresentative( nice, img ) = elm;
end );


#############################################################################
##
#M  CanEasilyTestMembership( <permgroup> )
##
InstallTrueMethod(CanEasilyTestMembership,IsHandledByNiceMonomorphism);


#############################################################################
##
#M  CanComputeSizeAnySubgroup( <permgroup> )
##
InstallTrueMethod(CanComputeSizeAnySubgroup,IsHandledByNiceMonomorphism);


#############################################################################
##
#M  AbelianInvariants( <G> )  . . . . . . . . . abelian invariants of a group
##
AttributeMethodByNiceMonomorphism( AbelianInvariants,
    [ IsGroup ] );


#############################################################################
##
#M  Centralizer( <G>, <H> )   . . . . . . . . . . . . centralizer of subgroup
##
SubgroupMethodByNiceMonomorphismCollColl( CentralizerOp,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  Centralizer( <G>, <elm> ) . . . . . . . . . . . .  centralizer of element
##
SubgroupMethodByNiceMonomorphismCollElm( CentralizerOp,
    [ IsGroup, IsObject ] );


#############################################################################
##
#M  ChiefSeries( <G> )  . . . . . . . . . . . . . . . chief series of a group
##
GroupSeriesMethodByNiceMonomorphism( ChiefSeries,
    [ IsGroup ] );


#############################################################################
##
#M  ClosureGroup( <G>, <U> )  . . . . . . . . . . closure of group with group
##
GroupMethodByNiceMonomorphismCollColl( ClosureGroup,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  ClosureGroup( <G>, <elm> )  . . . . . . . . closure of group with element
##
# don't use `GroupMethodByNiceMonomorphismCollElm' to treat case of element
# contained in.
#GroupMethodByNiceMonomorphismCollElm( ClosureGroup,
#    [ IsGroup, IsMultiplicativeElementWithInverse ] );
InstallMethod(ClosureGroup,"by niceo",
  IsCollsElms,[IsGroup and IsHandledByNiceMonomorphism,
               IsMultiplicativeElementWithInverse],0,
function( obj1, obj2 )
    local   nice,no,  img,  img1;
    nice := NiceMonomorphism(obj1);
    img  := ImagesRepresentative( nice, obj2:actioncanfail:=true );
    if img = fail or
      not (img in ImagesSource(nice) and
        PreImagesRepresentative(nice,img)=obj2) then
        TryNextMethod();
    fi;
    no:=NiceObject(obj1);
    img1 := ClosureGroup( NiceObject(obj1), img );

    # avoid recreating same object anew
    if img1=no then
      return obj1;
    fi;

    no:=GroupByNiceMonomorphism( nice, img1 );
    if HasGeneratorsOfGroup(obj1) and not HasGeneratorsOfGroup(no) then
      SetGeneratorsOfGroup(no,
        Concatenation(GeneratorsOfGroup(obj1),[obj2]));
    fi;
    return no;
end);


#############################################################################
##
#M  CommutatorFactorGroup( <G> )  . . . .  commutator factor group of a group
##
AttributeMethodByNiceMonomorphism( CommutatorFactorGroup,
    [ IsGroup ] );


#############################################################################
##
#M  CommutatorSubgroup( <U>, <V> )  . . . . commutator subgroup of two groups
##
GroupMethodByNiceMonomorphismCollColl( CommutatorSubgroup,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  CompositionSeries( <G> )  . . . . . . . . . composition series of a group
##
GroupSeriesMethodByNiceMonomorphism( CompositionSeries,
    [ IsGroup ] );


#############################################################################
##
#M  ConjugacyClasses
##
InstallMethod(ConjugacyClasses,"via niceomorphism",true,
  [IsGroup and IsHandledByNiceMonomorphism],0,
function(g)
local mon,cl,clg,c,i;
  cl:=ConjugacyClassesForSmallGroup(g);
  if cl<>fail then
    return cl;
  fi;
  mon:=NiceMonomorphism(g);
  cl:=ConjugacyClasses(NiceObject(g));
  clg:=[];
  for i in cl do
    c:=ConjugacyClass(g,PreImagesRepresentative(mon,Representative(i)));
    c!.niceClass:=i;
    if HasStabilizerOfExternalSet(i) then
      SetStabilizerOfExternalSet(c,PreImages(mon,StabilizerOfExternalSet(i)));
    fi;
    Add(clg,c);
  od;
  return clg;
end);


#############################################################################
##
#M  ConjugateGroup( <G>, <g> )  . . . . . . . . . . . . . .  conjugate of <G>
##
GroupMethodByNiceMonomorphismCollElm( ConjugateGroup,
    [ IsGroup and HasParent, IsMultiplicativeElementWithInverse ] );


#############################################################################
##
#M  Core( <G>, <U> )  . . . . . . . . . . . . . . . .  core of a <U> in a <G>
##
GroupMethodByNiceMonomorphismCollColl( CoreOp,
    [ IsGroup, IsGroup ] );


##############################################################################
##
#M  DerivedLength( <G> ) . . . . . . . . . . . . . . derived length of a group
##
AttributeMethodByNiceMonomorphism( DerivedLength,
    [ IsGroup ] );


#############################################################################
##
#M  DerivedSeriesOfGroup( <G> ) . . . . . . . . . . derived series of a group
##
GroupSeriesMethodByNiceMonomorphism( DerivedSeriesOfGroup,
    [ IsGroup ] );


#############################################################################
##
#M  DerivedSubgroup( <G> )  . . . . . . . . . . . derived subgroup of a group
##
SubgroupMethodByNiceMonomorphism( DerivedSubgroup,
    [ IsGroup ] );


#############################################################################
##
#M  ElementaryAbelianSeries( <G> )  . .  elementary abelian series of a group
##
GroupSeriesMethodByNiceMonomorphism( ElementaryAbelianSeries,
    [ IsGroup ] );
GroupSeriesMethodByNiceMonomorphism( ElementaryAbelianSeriesLargeSteps,
    [ IsGroup ] );


#############################################################################
##
#M  Exponent( <G> ) . . . . . . . . . . . . . . . . . . . . . exponent of <G>
##
AttributeMethodByNiceMonomorphism( Exponent,
    [ IsGroup ] );


#############################################################################
##
#M  FittingSubgroup( <G> )  . . . . . . . . . . . Fitting subgroup of a group
##
SubgroupMethodByNiceMonomorphism( FittingSubgroup,
    [ IsGroup ] );


#############################################################################
##
#M  FrattiniSubgroup( <G> ) . . . . . . . . . .  Frattini subgroup of a group
##
SubgroupMethodByNiceMonomorphism( FrattiniSubgroup,
    [ IsGroup ] );

#############################################################################
##
#M  HallSubgroup
##
InstallMethod(HallSubgroupOp,"via niceomorphism",true,
  [IsGroup and IsHandledByNiceMonomorphism,IsList],0,
function(g,l)
local mon,h;
   mon:=NiceMonomorphism(g);
   h:=HallSubgroup(NiceObject(g),l);
   if h = fail then
       return fail;
   elif IsList(h) then
       return List(h, k -> PreImage(mon, k));
   elif IsGroup(h) then
       return PreImage(mon,h);
   else
       Error("Unexpected return value from HallSubgroup");
   fi;
end);

#############################################################################
##
#M  IndexOp( <G>, <H> ) . . . . . . . . . . . . . . . . . index of <H> in <G>
#M  IndexNC( <G>, <H> ) . . . . . . . . . . . . . . . . . index of <H> in <G>
##
##  We install methods for both `IndexOp' and `IndexNC'.
##  The former is useful because the check whether <H> is a subset of <G> is
##  better performed in the image under the nice monomorphism.
##  (Note that this is safe since the method strikes only if the nice
##  monomorphisms of <G> and <H> are identical.)
##  The latter is useful because one might choose `IndexNC' deliberately in
##  one's code.
##
AttributeMethodByNiceMonomorphismCollColl( IndexOp,
    [ IsGroup, IsGroup ] );

AttributeMethodByNiceMonomorphismCollColl( IndexNC,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  Intersection2( <G>, <H> ) . . . . . . . . . . . .  intersection of groups
##
GroupMethodByNiceMonomorphismCollColl( Intersection2,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  IsCyclic( <G> ) . . . . . . . . . . . . . . . . test if a group is cyclic
##
PropertyMethodByNiceMonomorphism( IsCyclic,
    [ IsGroup ] );


#############################################################################
##
#M  IsMonomialGroup( <G> )  . . . . . . . . . . . test if a group is monomial
##
PropertyMethodByNiceMonomorphism( IsMonomialGroup,
    [ IsGroup ] );


#############################################################################
##
#M  IsNilpotentGroup( <G> ) . . . . . . . . . .  test if a group is nilpotent
##
PropertyMethodByNiceMonomorphism( IsNilpotentGroup,
    [ IsGroup ] );


#############################################################################
##
#M  IsNormal( <G>, <U> )  . . . . . . . . . . . . . test if <U> normal in <G>
##
PropertyMethodByNiceMonomorphismCollColl( IsNormalOp,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  IsPerfectGroup( <G> ) . . . . . . . . . . . .  test if a group is perfect
##
PropertyMethodByNiceMonomorphism( IsPerfectGroup,
    [ IsGroup ] );


#############################################################################
##
#M  IsSimpleGroup( <G> )  . . . . . . . . . . . . . test if a group is simple
##
PropertyMethodByNiceMonomorphism( IsSimpleGroup,
    [ IsGroup ] );


#############################################################################
##
#M  IsSolvableGroup( <G> )  . . . . . . . . . . . test if a group is solvable
##
PropertyMethodByNiceMonomorphism( IsSolvableGroup,
    [ IsGroup ] );


#############################################################################
##
#M  IsSubset( <G>, <H> ) . . . . . . . . . . . . .  test for subset of groups
##
PropertyMethodByNiceMonomorphismCollColl( IsSubset,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  IsSupersolvableGroup( <G> ) . . . . . .  test if a group is supersolvable
##
PropertyMethodByNiceMonomorphism( IsSupersolvableGroup,
    [ IsGroup ] );


#############################################################################
##
#M  IsomorphismPermGroup
##
InstallMethod(IsomorphismPermGroup,"via niceomorphisms",true,
  [IsGroup and IsFinite and IsHandledByNiceMonomorphism],
  # This is intended to be better than the generic ``action on element''
  # method. However for example for matrix groups there are better methods.
  # The downranking is compatible with that for the method for finite
  # matrix groups in 'lib/grpmat.gi'.
  -NICE_FLAGS+5,
function(g)
local mon,iso;
  mon:=NiceMonomorphism(g);
  if not IsIdenticalObj(Source(mon),g) then
    mon:=RestrictedNiceMonomorphism(mon,g);
  fi;
  iso:=IsomorphismPermGroup(NiceObject(g));
  if iso=fail then
    return fail;
  else
    mon:=mon*iso;
    SetIsInjective(mon,true);
    SetIsSurjective(mon,true);
    return mon;
  fi;
end);

#############################################################################
##
#M  IsomorphismPcGroup
##
InstallMethod(IsomorphismPcGroup,"via niceomorphisms",true,
  [IsGroup and IsFinite and IsHandledByNiceMonomorphism],0,
function(g)
local mon,iso;
  mon:=NiceMonomorphism(g);
  if not IsIdenticalObj(Source(mon),g) then
    mon:=RestrictedNiceMonomorphism(mon,g);
  fi;
  iso:=IsomorphismPcGroup(NiceObject(g));
  if iso=fail then
    return fail;
  else
    mon:=mon*iso;
    SetIsInjective(mon,true);
    SetIsSurjective(mon,true);
    return mon;
  fi;
end);

#############################################################################
##
#M  IsomorphismFpGroup
##
InstallOtherMethod(IsomorphismFpGroup,"via niceomorphism",true,
  [IsGroup and IsHandledByNiceMonomorphism,IsString],0,
function(g,nam)
local mon,iso;
  mon:=NiceMonomorphism(g);
  if not IsIdenticalObj(Source(mon),g) then
    mon:=RestrictedNiceMonomorphism(mon,g);
  fi;
  iso:=IsomorphismFpGroup(NiceObject(g),nam);
  if iso=fail then
    return fail;
  else
    mon:=mon*iso;
    SetIsInjective(mon,true);
    SetIsSurjective(mon,true);
    ProcessEpimorphismToNewFpGroup(mon);
    return mon;
  fi;
end);

InstallMethod(IsomorphismFpGroupByGeneratorsNC,"via niceomorphism/w. gens",
  IsFamFamX,[IsGroup and IsHandledByNiceMonomorphism, IsList,IsString],0,
function(g,c,nam)
local mon,iso;
  mon:=NiceMonomorphism(g);
  c:=List(c,i->Image(mon,i));
  if not IsIdenticalObj(Source(mon),g) then
    mon:=RestrictedNiceMonomorphism(mon,g);
  fi;
  iso:=IsomorphismFpGroupByGeneratorsNC(NiceObject(g),c,nam);
  if iso=fail then
    return fail;
  else
    iso:=mon*iso;
    SetIsInjective(iso,true);
    SetIsSurjective(iso,true);
    ProcessEpimorphismToNewFpGroup(iso);
    mon:=MappingGeneratorsImages(iso);
    SetName(iso,Concatenation("<composed isomorphism:",
      String(mon[1]),"->",String(mon[2]),">"));
    return iso;
  fi;
end);

#############################################################################
##
#M  JenningsSeries( <G> ) . . . . . . . . . . .  jennings series of a p-group
##
GroupSeriesMethodByNiceMonomorphism( JenningsSeries,
    [ IsGroup ] );


#############################################################################
##
#M  LowerCentralSeriesOfGroup( <G> )  . . . . lower central series of a group
##
GroupSeriesMethodByNiceMonomorphism( LowerCentralSeriesOfGroup,
    [ IsGroup ] );


#############################################################################
##
#M  MaximalSubgroupClassReps( <G> )
##
InstallOtherMethod( CalcMaximalSubgroupClassReps,
  "handled by nice monomorphism, transfer tainter",
  [IsGroup and IsHandledByNiceMonomorphism],
function( G )
local   nice,  img,  sub,i;
  nice := NiceMonomorphism(G);
  img  := ShallowCopy(CalcMaximalSubgroupClassReps( NiceObject(G) ));
  for i in [1..Length(img)] do
    sub  := GroupByNiceMonomorphism( nice, img[i] );
    SetParent( sub, G );
    img[i]:=sub;
  od;
  return img;
end );


#############################################################################
##
#M  NormalSubgroups( <G> )
##
SubgroupsMethodByNiceMonomorphism( NormalSubgroups, [ IsGroup ] );


#############################################################################
##
#M  NormalClosure( <G>, <U> ) . . . . normal closure of a subgroup in a group
##
GroupMethodByNiceMonomorphismCollColl( NormalClosureOp,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  NormalIntersection( <G>, <U> )  . . . . . intersection with normal subgrp
##
GroupMethodByNiceMonomorphismCollColl( NormalIntersection,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  Normalizer( <G>, <U> )  . . . . . . . . . . . .  normalizer of <U> in <G>
##
SubgroupMethodByNiceMonomorphismCollColl( NormalizerOp,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  NrConjugacyClasses( <G> ) . . no. of conj. classes of elements in a group
##
AttributeMethodByNiceMonomorphism( NrConjugacyClasses,
    [ IsGroup ] );


#############################################################################
##
#M  NrConjugacyClassesInSupergroup( <U>, <H> ) . . . . . . . .  no of classes
##
AttributeMethodByNiceMonomorphismCollColl( NrConjugacyClassesInSupergroup,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  PCentralSeriesOp( <G>, <p> )  . . . . . .  . . . . . . <p>-central series
##
GroupSeriesMethodByNiceMonomorphismCollOther( PCentralSeriesOp,
    [ IsGroup, IsPosInt ] );


#############################################################################
##
#M  PCoreOp( <G>, <p> ) . . . . . . . . . . . . . . . . . . p-core of a group
##
SubgroupMethodByNiceMonomorphismCollOther( PCoreOp,
    [ IsGroup, IsPosInt ] );

#############################################################################
##
#M  PowerMapOfGroup
##
InstallMethod(PowerMapOfGroup,"via niceomorphism",true,
  [IsGroup and IsHandledByNiceMonomorphism,IsInt,IsHomogeneousList],0,
function( G, n, ccl )
local nice;
  nice:=NiceMonomorphism(G);
  return PowerMapOfGroup( NiceObject(G), n,
    List(ccl,function(i)
      local c;
      if IsBound(i!.niceClass) then
        return i!.niceClass;
      else
        c:=ConjugacyClass(NiceObject(G),ImageElm(nice,Representative(i)));
        if HasStabilizerOfExternalSet(i) then
          SetStabilizerOfExternalSet(c,Image(nice,StabilizerOfExternalSet(i)));
        fi;
        return c;
      fi;
    end));
end );


#############################################################################
##
#M  SolvableRadical( <G> )  . . . . . . . . . . . solvable radical of a group
##
SubgroupMethodByNiceMonomorphism( SolvableRadical,
    [ IsGroup ] );

#############################################################################
##
#M  Random( <G> )
##
InstallMethodWithRandomSource( Random,
    "for a random source and a group handled by nice monomorphism",
    [ IsRandomSource, IsGroup and IsHandledByNiceMonomorphism ], 0,
    {rs, G} -> PreImagesRepresentative( NiceMonomorphism( G ),
                                  Random( rs, NiceObject( G ) ) ) );


#############################################################################
##
#M  RationalClasses
##
InstallMethod(RationalClasses,"via niceomorphism",true,
  [IsGroup and IsHandledByNiceMonomorphism],0,
function(g)
local mon,cl,clg,c,i;
   mon:=NiceMonomorphism(g);
   cl:=RationalClasses(NiceObject(g));
   clg:=[];
   for i in cl do
     c:=RationalClass(g,PreImagesRepresentative(mon,Representative(i)));
     if HasStabilizerOfExternalSet(i) then
       SetStabilizerOfExternalSet(c,PreImages(mon,StabilizerOfExternalSet(i)));
     fi;
     if HasGaloisGroup(i) then
       SetGaloisGroup(c,GaloisGroup(i));
     fi;
     Add(clg,c);
   od;
   return clg;
end);


#############################################################################
##
#M  RightCosets
##
InstallMethod(RightCosetsNC,"via niceomorphism",true,
  [IsGroup and IsHandledByNiceMonomorphism,IsGroup],0,
function(g,u)
local mon,rt;
   mon:=NiceMonomorphism(g);
   rt:=RightTransversal(ImagesSet(mon,g),ImagesSet(mon,u));
   rt:=List(rt,i->RightCoset(u,PreImagesRepresentative(mon,i)));
   return rt;
end);


#############################################################################
##
#M  Size( <G> ) . . . . . . . . . . . . . . . . . . . . . . . . . size of <G>
##
AttributeMethodByNiceMonomorphism( Size,
    [ IsGroup ] );

#############################################################################
##
#M  StructureDescription( <G> )
##
AttributeMethodByNiceMonomorphism( StructureDescription,
    [ IsGroup ] );


#############################################################################
##
#M  StructureDescription( <G> )
##
AttributeMethodByNiceMonomorphism( StructureDescription,
    [ IsGroup ] );


#############################################################################
##
#M  SubnormalSeries( <G>, <U> ) . subnormal series from a group to a subgroup
##
GroupSeriesMethodByNiceMonomorphismCollColl( SubnormalSeriesOp,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  SylowSubgroupOp( <G>, <p> ) . . . . . . . . . . Sylow subgroup of a group
##
SubgroupMethodByNiceMonomorphismCollOther( SylowSubgroupOp,
    [ IsGroup, IsPosInt ] );


#############################################################################
##
#M  UpperCentralSeriesOfGroup( <G> )  . . . . upper central series of a group
##
GroupSeriesMethodByNiceMonomorphism( UpperCentralSeriesOfGroup,
    [ IsGroup ] );


#############################################################################
##
#M  RepresentativeAction( <G> )
##
InstallOtherMethod(RepresentativeActionOp,"nice group on elements",
  IsCollsElmsElmsX,[IsHandledByNiceMonomorphism and IsGroup,
  IsMultiplicativeElementWithInverse,IsMultiplicativeElementWithInverse,
  IsFunction],10,
function(G,a,b,op)
local hom,rep;
  if op<>OnPoints then
    TryNextMethod();
  fi;
  hom:=NiceMonomorphism(G);
  if not ( a in Source( hom ) and b in Source( hom ) ) then
    TryNextMethod();
  fi;
  rep:= RepresentativeAction( NiceObject( G ),
            ImageElm( hom, a ), ImageElm( hom, b ), OnPoints );
  if rep<>fail then
    rep:=PreImagesRepresentative(hom,rep);
  fi;
  return rep;
end);

#############################################################################
##
#M  NaturalHomomorphismByNormalSubgroup( <G>, <N> ) . . . .  via nicomorphism
##
InstallMethod( NaturalHomomorphismByNormalSubgroupOp, IsIdenticalObj,
        [ IsHandledByNiceMonomorphism and IsGroup, IsGroup ], 0,
    function( G, N )
    local   nice;

    nice := RestrictedNiceMonomorphism(NiceMonomorphism( G ),G);
    G := ImagesSet( nice,G );
    N := ImagesSet   ( nice, N );
    return CompositionMapping( NaturalHomomorphismByNormalSubgroup( G, N ),
                   nice );
end );

#############################################################################
##
#M  GroupGeneralMappingByImagesNC( <G>, <H>, <gens>, <imgs> ) . . . . make GHBI
##
InstallMethod( GroupGeneralMappingByImagesNC,
   "from a group handled by a niceomorphism",true,
    [ IsGroup and IsHandledByNiceMonomorphism, IsGroup, IsList, IsList ], 0,
function( G, H, gens, imgs )
local nice,geni,map2,tmp;
  if RUN_IN_GGMBI=true then
    TryNextMethod();
  fi;
  tmp := RUN_IN_GGMBI;
  RUN_IN_GGMBI:=true;
  nice:=NiceMonomorphism(G);
  if not IsIdenticalObj(Source(nice),G) then
    nice:=RestrictedNiceMonomorphism(nice,G);
  fi;
  geni:=List(gens,i->ImageElm(nice,i));
  map2:=GroupGeneralMappingByImagesNC(NiceObject(G),H,geni,imgs);
  RUN_IN_GGMBI:=tmp;
  return CompositionMapping(map2,nice);
end );

InstallMethod( GroupGeneralMappingByImagesNC,
   "from a group handled by a niceomorphism",true,
    [ IsGroup and IsHandledByNiceMonomorphism, IsList, IsList ], 0,
function( G, gens, imgs )
  return GroupGeneralMappingByImagesNC(G,Group(imgs),gens,imgs);
end);

#############################################################################
##
#M  AsGroupGeneralMappingByImages( <niceomorphism> )
##
InstallMethod( AsGroupGeneralMappingByImages,
  "for Niceomorphisms: avoid recursion",true,
  [IsGroupGeneralMapping and IsNiceMonomorphism],NICE_FLAGS,
function(hom)
local h, tmp;
  # we actually want to use the next method with `RUN_IN_GGMBI' set to
  # `true'. Therefore we redispatch, but will skip this method the second
  # time.
  if RUN_IN_GGMBI=true then
    TryNextMethod();
  fi;
  tmp := RUN_IN_GGMBI;
  RUN_IN_GGMBI:=true;
  h:=AsGroupGeneralMappingByImages(hom);
  RUN_IN_GGMBI:=tmp;
  return h;
end);

#############################################################################
##
#M  PreImagesRepresentative( <hom>, <elm> ) . . . . . . . . . . .  via images
##
InstallMethod( PreImagesRepresentative, "for PBG-Niceo",
    FamRangeEqFamElm,
    [ IsPreimagesByAsGroupGeneralMappingByImages and IsNiceMonomorphism,
      IsMultiplicativeElementWithInverse ], 0,
function( hom, elm )
local p, tmp;
  # avoid the double dispatch for `AsGroupGeneralMappingByImages'
  tmp := RUN_IN_GGMBI;
   RUN_IN_GGMBI:=true;
  p:=PreImagesRepresentative( AsGroupGeneralMappingByImages( hom ), elm );
  RUN_IN_GGMBI:=tmp;
  return p;
end );

#############################################################################
##
#M  NiceMonomorphism( <group> ) . .
##
InstallMethod(NiceMonomorphism,
    "if a canonical nice monomorphism is already known",
    true,[ IsGroup and HasCanonicalNiceMonomorphism],100,
    CanonicalNiceMonomorphism);

#############################################################################
##
#M  CanonicalNiceMonomorphism( <group> )] . .
##
InstallMethod(CanonicalNiceMonomorphism,"test canonicity of existing niceo",
    true,[ IsGroup and HasNiceMonomorphism],0,
function(G)
  if IsCanonicalNiceMonomorphism(NiceMonomorphism(G)) then
    return NiceMonomorphism(G);
  else
    TryNextMethod();
  fi;
end);

#############################################################################
##
#M  SeedFaithfulAction( <group> ) . .
##
InstallMethod(SeedFaithfulAction,
    "default: fail",
    true,[ IsGroup ],0,
    ReturnFail);

#############################################################################
##
#M  NiceMonomorphism( <G> ) . . . . . . . . . . . . . . . . regular operation
##
InstallMethod( NiceMonomorphism, "SeedFaithfulAction supersedes", true,
        [ IsGroup and IsHandledByNiceMonomorphism and
          HasSeedFaithfulAction], 1000,
function(G)
  local b, hom;
  b:=SeedFaithfulAction(G);
  if b=fail then
    TryNextMethod();
  fi;
  hom:= MultiActionsHomomorphism(G,b.points,b.ops);
  SetIsInjective( hom, true );
  return hom;
end);


#############################################################################
##
#R  IsEnumeratorByNiceomorphismRep
##
DeclareRepresentation( "IsEnumeratorByNiceomorphismRep",
    IsAttributeStoringRep, [ "group", "morphism", "niceEnumerator" ] );

#############################################################################
##
#M  Enumerator( <G> ) . . . . . . . . . . . . . . . . .  enumerator by niceo
##
InstallMethod( Enumerator,"use nice monomorphism",true,
        [ IsGroup and IsHandledByNiceMonomorphism and IsFinite ], 0,
function( G )
    return Objectify(
        NewType( FamilyObj(G), IsList and IsEnumeratorByNiceomorphismRep ),
        rec( group:=G,
             morphism:=NiceMonomorphism(G),
             niceEnumerator:=Enumerator(NiceObject(G))));
end );

#############################################################################
##
#M  Length( <enum-by-niceo> )
##
InstallMethod( Length,"enum-by-niceomorphism", true,
    [ IsList and IsEnumeratorByNiceomorphismRep ], 0,
    enum -> Length(enum!.niceEnumerator));


#############################################################################
##
#M  <enum-by-niceo> [ <pos> ]
##
InstallMethod( \[\],"enum-by-niceo", true,
    [ IsList and IsEnumeratorByNiceomorphismRep, IsPosInt ], 0,
function( enum, pos )
local img;
  img:=enum!.niceEnumerator[pos];
  return PreImagesRepresentative(enum!.morphism,img);
end);


#############################################################################
##
#M  Position( <enum-by-niceo>, <elm>, <zero> )
##
InstallMethod( Position,"enum-by-niceo", IsCollsElmsX,
    [ IsList and IsEnumeratorByNiceomorphismRep,
      IsMultiplicativeElementWithInverse,
      IsZeroCyc ], 0,
function( enum, elm, zero )
  elm:=ImageElm(enum!.morphism,elm);
  return Position(enum!.niceEnumerator,elm,zero);
end );


#############################################################################
##
#M  PositionCanonical( <enum-by-niceo>, <elm> )
##
InstallMethod( PositionCanonical,"enum-by-niceo",
    IsCollsElms,
    [ IsList and IsEnumeratorByNiceomorphismRep,
      IsMultiplicativeElementWithInverse ],
    0,

function( enum, elm )
  elm:=ImageElm(enum!.morphism,elm);
  return PositionCanonical(enum!.niceEnumerator,elm);
end );
