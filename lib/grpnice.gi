#############################################################################
##
#W  grpnice.gi                  GAP library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This  file  contains generic     methods   for groups handled    by  nice
##  monomorphisms..
##
Revision.grpnice_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  GeneratorsOfMagmaWithInverses( <nice> )
##
InstallMethod( GeneratorsOfMagmaWithInverses,
    true,
    [ IsGroup and IsHandledByNiceMonomorphism ],
    0,

function( G )
    local   nice;
    nice := NiceMonomorphism(G);
    return List( GeneratorsOfGroup(NiceObject(G)),
                 x -> PreImagesRepresentative(nice,x) );
end );


#############################################################################
##
#M  One( <nice> )
##
InstallOtherMethod( One,"via niceomorphism",true,
    [ IsGroup and IsHandledByNiceMonomorphism ], 0,
function( G )
    return PreImagesRepresentative(NiceMonomorphism(G),One(NiceObject(G)));
end );

#############################################################################
##
#M  GroupByNiceMonomorphism( <nice>, <grp> )
##
InstallMethod( GroupByNiceMonomorphism,
    true,
    [ IsGroupHomomorphism,
      IsGroup ],
    0,

function( nice, grp )
    local   fam,  pre;

    fam := FamilyObj( Source(nice) );
    pre := Objectify(NewKind(fam,IsGroup and IsAttributeStoringRep), rec());
    SetIsHandledByNiceMonomorphism( pre, true );
    SetNiceMonomorphism( pre, nice );
    SetNiceObject( pre, grp );
    return pre;
end );


#############################################################################
##
#M  NiceObject( <nice> )
##
InstallMethod( NiceObject,
    true,
    [ IsGroup and IsHandledByNiceMonomorphism ],
    0,

function( G )
    return ImagesSet( NiceMonomorphism(G), G );
end );


#############################################################################
##
#M  NiceMonomorphism
##
InstallMethod(NiceMonomorphism,
  "for subgroups that get the nice monomorphism by their parent",true,
    [ IsGroup and IsHandledByNiceMonomorphism and HasParent],0,
function(G)
local P;
  P:=Parent(G);
  if not IsHandledByNiceMonomorphism(P) then
    TryNextMethod();
  fi;
  return NiceMonomorphism(P);
end);

#############################################################################
##

#M  \^( <G>, <g> )
##
GroupMethodByNiceMonomorphismCollElm( \^,
    [ IsGroup, IsMultiplicativeElementWithInverse ] );


#############################################################################
##
#M  \=( <G>, <H> )  . . . . . . . . . . . . . .  test if two groups are equal
##
PropertyMethodByNiceMonomorphismCollColl( \=,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  \in( <elm>, <G> )  . . . . . . . . . . . .  test if elm \in G
##
InstallMethod( \in, "by nice monomorphism", IsElmsColls,
        [ IsMultiplicativeElementWithInverse,
          IsGroup and IsHandledByNiceMonomorphism ], 0,
    function( elm, G )
    local   nice,  img;
    
    nice := NiceMonomorphism( G );
    img := ImagesRepresentative( nice, elm );
    return     img in NiceObject( G )
           and PreImagesRepresentative( nice, img ) = elm;
end );


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
GroupMethodByNiceMonomorphismCollColl( Centralizer,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  Centralizer( <G>, <elm> ) . . . . . . . . . . . .  centralizer of element
##
GroupMethodByNiceMonomorphismCollElm( Centralizer,
    [ IsGroup, IsObject ] );


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
GroupMethodByNiceMonomorphismCollElm( ClosureGroup,
    [ IsGroup, IsMultiplicativeElementWithInverse ] );


#############################################################################
##
#M  CommutatorFactorGroup( <G> )  . . . .  commutator factor group of a group
##
SubgroupMethodByNiceMonomorphism( CommutatorFactorGroup,
    [ IsGroup ] );


#############################################################################
##
#M  CommutatorSubgroup( <U>, <V> )  . . . . commutator subgroup of two groups
##
GroupMethodByNiceMonomorphismCollColl( CommutatorSubgroup,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  ConjugateSubgroup( <G>, <g> ) . . . . . . . . . . . . .  conjugate of <G>
##
GroupMethodByNiceMonomorphismCollElm( ConjugateSubgroup,
    [ IsGroup and HasParent, IsMultiplicativeElementWithInverse ] );


#############################################################################
##
#M  Core( <G>, <U> )  . . . . . . . . . . . . . . . .  core of a <U> in a <G>
##
GroupMethodByNiceMonomorphismCollColl( Core,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  CoreInParent( <G> ) . . . . . . . . . . . . . . . . core of <G> in parent
##
SubgroupMethodByNiceMonomorphism( CoreInParent,
    [ IsGroup and HasParent ] );


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
#M  Index( <G>, <H> ) . . . . . . . . . . . . . . . . . . index of <H> in <G>
##
AttributeMethodByNiceMonomorphismCollColl( Index,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  IndexInParent( <G> )  . . . . . . . . . . . . . .  index of <G> in parent
##
AttributeMethodByNiceMonomorphism( IndexInParent,
    [ IsGroup and HasParent ] );


#############################################################################
##
#M  Intersection2( <G>, <H> ) . . . . . . . . . . . .  intersection of groups
##
GroupMethodByNiceMonomorphismCollColl( Intersection2,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  IsCentral( <G>, <U> )  . . . . . . . . is a group centralized by another?
##
PropertyMethodByNiceMonomorphismCollColl( IsCentral,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  IsCyclic( <G> ) . . . . . . . . . . . . . . . . test if a group is cyclic
##
PropertyMethodByNiceMonomorphism( IsCyclic,
    [ IsGroup ] );


#############################################################################
##
#M  IsElementaryAbelian( <G> )  . . . . test if a group is elementary abelian
##
PropertyMethodByNiceMonomorphism( IsElementaryAbelian,
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
PropertyMethodByNiceMonomorphismCollColl( IsNormal,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  IsNormalInParent( <G> ) . . . . . . . . . .  test if <G> normal in parent
##
PropertyMethodByNiceMonomorphism( IsNormalInParent,
    [ IsGroup and HasParent ] );


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
#M  IsSubgroup( <G>, <U> )  . . . . . . . .  test if <U> is a subgroup of <G>
##
PropertyMethodByNiceMonomorphismCollColl( IsSubgroup,
    [ IsGroup, IsGroup ] );


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
#M  NormalClosure( <G>, <U> ) . . . . normal closure of a subgroup in a group
##
GroupMethodByNiceMonomorphismCollColl( NormalClosure,
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
GroupMethodByNiceMonomorphismCollColl( Normalizer,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  NormalizerInParent( <G> ) . . . . . . . . . . normalizer of <G> in parent
##
SubgroupMethodByNiceMonomorphism( NormalizerInParent, 
    [ IsGroup and HasParent ] );


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
#M  OrdersClassRepresentatives( <G> ) . . . . orders of class representatives
##
AttributeMethodByNiceMonomorphism( OrdersClassRepresentatives,
    [ IsGroup ] );


#############################################################################
##
#M  PCentralSeriesOp( <G>, <p> )  . . . . . .  . . . . . . <p>-central series
##
GroupSeriesMethodByNiceMonomorphismCollOther( PCentralSeriesOp,
    [ IsGroup, IsPosRat and IsInt ] );


#############################################################################
##
#M  PCoreOp( <G>, <p> ) . . . . . . . . . . . . . . . . . . p-core of a group
##
GroupMethodByNiceMonomorphismCollOther( PCoreOp,
    [ IsGroup, IsPosRat and IsInt ] );


#############################################################################
##
#M  RadicalGroup( <G> ) . . . . . . . . . . . . . . . . .  radical of a group
##
SubgroupMethodByNiceMonomorphism( RadicalGroup,
    [ IsGroup ] );


#############################################################################
##
#M  Size( <G> ) . . . . . . . . . . . . . . . . . . . . . . . . . size of <G>
##
AttributeMethodByNiceMonomorphism( Size,
    [ IsGroup ] );


#############################################################################
##
#M  SizesCentralizers( <G> )  . . . . . . . . . . . sizes of the centralizers
##
AttributeMethodByNiceMonomorphism( SizesCentralizers,
    [ IsGroup ] );


#############################################################################
##
#M  SizesConjugacyClasses( <G> )  . . . . . .  sizes of the conjugacy classes
##
AttributeMethodByNiceMonomorphism( SizesConjugacyClasses,
    [ IsGroup ] );


#############################################################################
##
#M  SubnormalSeries( <G>, <U> ) . subnormal series from a group to a subgroup
##
GroupSeriesMethodByNiceMonomorphismCollColl( SubnormalSeries,
    [ IsGroup, IsGroup ] );


#############################################################################
##
#M  SylowSubgroupOp( <G>, <p> ) . . . . . . . . . . Sylow subgroup of a group
##
GroupMethodByNiceMonomorphismCollOther( SylowSubgroupOp,
    [ IsGroup, IsPosRat and IsInt ] );


#############################################################################
##
#M  TrivialSubgroup( <G> ) . . . . . . . . . . .  trivial subgroup of a group
##
SubgroupMethodByNiceMonomorphism( TrivialSubgroup,
    [ IsGroup ] );


#############################################################################
##
#M  UpperCentralSeriesOfGroup( <G> )  . . . . upper central series of a group
##
GroupSeriesMethodByNiceMonomorphism( UpperCentralSeriesOfGroup,
    [ IsGroup ] );


#############################################################################
##
#M  IsomorphismPcGroup
##
InstallMethod(IsomorphismPcGroup,"via niceomorphisms",true,
  [IsGroup and IsHandledByNiceMonomorphism],NICE_FLAGS,
function(g)
local mon,iso;
   mon:=NiceMonomorphism(g);
   iso:=IsomorphismPcGroup(NiceObject(g));
   if iso=fail then
     return fail;
   else
     return mon*iso;
   fi;
end);

#############################################################################
##
#M  ConjugacyClasses
##
InstallMethod(ConjugacyClasses,"via niceomorphism",true,
  [IsGroup and IsHandledByNiceMonomorphism],NICE_FLAGS,
function(g)
local mon,cl,clg,c,i;
   mon:=NiceMonomorphism(g);
   cl:=ConjugacyClasses(NiceObject(g));
   clg:=[];
   for i in cl do
     c:=ConjugacyClass(g,PreImagesRepresentative(mon,Representative(i)));
     if HasStabilizerOfExternalSet(i) then
       SetStabilizerOfExternalSet(c,PreImages(mon,StabilizerOfExternalSet(i)));
     fi;
     Add(clg,c);
   od;
   return clg;
end);


#############################################################################
##
#M  RightTransversal
##
InstallMethod(RightTransversal,"via niceomorphism",true,
  [IsGroup and IsHandledByNiceMonomorphism,IsGroup],NICE_FLAGS,
function(g,u)
local mon,rt;
   mon:=NiceMonomorphism(g);
   rt:=RightTransversal(ImagesSet(mon,g),ImagesSet(mon,u));
   rt:=List(rt,i->PreImagesRepresentative(mon,i));
   return rt;
end);


#############################################################################
##

#E  grpnice.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
