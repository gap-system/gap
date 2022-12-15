#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Andrew Solomon.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Conversion to, and fast methods for, transformation representation
##  of EndoMappings.
##

############################################################################
##
#R  IsTransformationRepOfEndo(<obj>)
##
##  An endomorphism of a finite domain <D> with EnumeratorSorted can be
##  represented as transformation on  [1 .. Length(EnumeratorSorted(D))]
##
DeclareRepresentation("IsTransformationRepOfEndo",
IsComponentObjectRep and IsAttributeStoringRep,
["transformation"]);

############################################################################
##
#F  EndoMappingByTransformation(<dom>, <gmfam>, <trans>)
##
##  Creates an endo general mapping from <dom> to itself
##  in the general mappings family <gmfam>, described by transformation
##  <trans>. At present this is a private function.
##
BindGlobal("EndoMappingByTransformation",
function(dom, gmfam, trans)
  local tmap;

  tmap := Objectify(gmfam!.transtype, rec( transformation := trans));
  SetSource(tmap,dom);
  SetRange(tmap,dom);
  SetIsEndoMapping(tmap, true);

  return tmap;
end);

############################################################################
##
#A  TransformationRepresentation(<obj>)
##
##  The user must deliberately put endomorphisms into this representation
##  since it calls enumerator sorted on the Source.
##
InstallMethod(TransformationRepresentation,
"for an endo general mapping", true,
[IsEndoMapping], 0,
function(m)
  local trans;

  if not (HasIsFinite(Source(m)) and IsFinite(Source(m))) then
    TryNextMethod();
  fi;

  # create the type if necessary
  if not IsBound(FamilyObj(m)!.transtype) then
    FamilyObj(m)!.transtype := NewType(FamilyObj(m),
            IsEndoMapping and IsNonSPGeneralMapping
            and IsTransformationRepOfEndo);
  fi;

  trans:= Transformation(List([1 .. Size(Source(m))],
          i -> Position(EnumeratorSorted(Source(m)),
                  EnumeratorSorted(Source(m))[i]^m)));

  return EndoMappingByTransformation(Source(m),FamilyObj(m), trans);
end);

InstallMethod(TransformationRepresentation,
"for an endo general mapping", true,
[IsEndoMapping and IsTransformationRepOfEndo], 0,m->m);

#############################################################################
##
#M  CompositionMapping2( <endo>, <endo> )  . . for IsTransformationRepOfEndo
##
##  Note: this is the dual of \*
##
InstallMethod(CompositionMapping2,
"IsTransformationRepOfEndo, IsTransformationRepOfEndo", IsIdenticalObj,
[IsTransformationRepOfEndo and IsEndoMapping,
 IsTransformationRepOfEndo and IsEndoMapping],
function(n, m)
  local mntrans;

  if Source(n) <> Source(m) then
                TryNextMethod();
  fi;

  mntrans := m!.transformation* n!.transformation;

  return EndoMappingByTransformation(Source(m),FamilyObj(m), mntrans);
end);

InstallMethod( CompositionMapping2,
"IsEndoMapping, IsTransformationRepOfEndo", IsIdenticalObj,
[ IsEndoMapping, IsTransformationRepOfEndo and IsEndoMapping ],
function( n, m )
  if Source(n) <> Source(m) then
    #T Is this really necessary?
    TryNextMethod();
  fi;

  return EndoMappingByTransformation( Source(m), FamilyObj(m),
               m!.transformation
               * TransformationRepresentation( n )!.transformation );
end );

InstallMethod( CompositionMapping2,
"IsTransformationRepOfEndo, IsEndoMapping", IsIdenticalObj,
  [ IsTransformationRepOfEndo and IsEndoMapping, IsEndoMapping ],
function( n, m )
  if Source(n) <> Source(m) then
    #T Is this really necessary?
    TryNextMethod();
  fi;

  return EndoMappingByTransformation( Source(m), FamilyObj(m),
               TransformationRepresentation( m )!.transformation
               * n!.transformation );
end );

#############################################################################
##
#M  \=( <endo>, <endo> )  . . . for IsTransformationRepOfEndo
##
InstallMethod(\=,
"IsTransformationRepOfEndo, IsTransformationRepOfEndo", IsIdenticalObj,
[IsTransformationRepOfEndo and IsEndoMapping,
IsTransformationRepOfEndo and IsEndoMapping], 0,
function(m, n)

  if Source(n) <> Source(m) then
    return false;
  fi;

  return m!.transformation = n!.transformation;
end);

InstallMethod(\=,
"IsTransformationRepOfEndo, IsEndoMapping", IsIdenticalObj,
[IsTransformationRepOfEndo and IsEndoMapping, IsEndoMapping], 0,
function(m, n)

  if Source(n) <> Source(m) then
    return false;
  fi;

  return m!.transformation = TransformationRepresentation(n)!.transformation;
end);

InstallMethod(\=,
"IsEndoMapping, IsTransformationRepOfEndo", IsIdenticalObj,
[IsEndoMapping, IsTransformationRepOfEndo and IsEndoMapping], 0,
function(m, n)
  if Source(n) <> Source(m) then
    return false;
  fi;

  return TransformationRepresentation(m)!.transformation = n!.transformation;
end);

#############################################################################
##
#M  \<( <endo>, <endo> )  . . . for IsTransformationRepOfEndo
##
InstallMethod(\<,
"IsTransformationRepOfEndo, IsTransformationRepOfEndo", IsIdenticalObj,
[IsEndoMapping and IsTransformationRepOfEndo,
IsEndoMapping and IsTransformationRepOfEndo], 0,
function(m, n)
  return TransformationRepresentation(m)!.transformation <
                TransformationRepresentation(n)!.transformation;
end);

InstallMethod(\<,
"IsEndoMapping, IsTransformationRepOfEndo", IsIdenticalObj,
[IsEndoMapping, IsEndoMapping and IsTransformationRepOfEndo], 0,
function(m, n)
  if Source(n) <> Source(m) then
    TryNextMethod();
  fi;
  if not HasEnumeratorSorted(Source(m)) then
    TryNextMethod();
  fi;

  return TransformationRepresentation(m)!.transformation <
                TransformationRepresentation(n)!.transformation;
end);

InstallMethod(\<,
"IsTransformationRepOfEndo, IsEndoMapping", IsIdenticalObj,
[IsEndoMapping and IsTransformationRepOfEndo, IsEndoMapping], 0,
function(m, n)
  if Source(n) <> Source(m) then
    TryNextMethod();
  fi;
  if not HasEnumeratorSorted(Source(m)) then
    TryNextMethod();
  fi;

  return TransformationRepresentation(m)!.transformation <
                TransformationRepresentation(n)!.transformation;
end);

#############################################################################
##
#M  ImagesElm( <endo>, <elm> )  . . . for IsTransformationRepOfEndo
##
InstallMethod( ImagesElm,
"IsTransformationRepOfEndo",
FamSourceEqFamElm,
[IsTransformationRepOfEndo and IsEndoMapping, IsObject ], 0,
function( endo, elm )
  local poselm;

  poselm := Position(EnumeratorSorted(Source(endo)), elm);
  return [EnumeratorSorted(Source(endo))[poselm^(endo!.transformation)]];
end);
