#############################################################################
##
#W  classic.gd                  GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the operations for the construction of the classical
##  group types.
##
Revision.classic_gd :=
    "@(#)$Id$";


#############################################################################
#1
##  The following functions return classical groups.
##  For the linear, symplectic, and unitary groups (the latter in dimension
##  at least $3$), the generators are taken from~\cite{Tay87};
##  for the unitary groups in dimension 2, the isomorphism of $SU(2,q)$ and
##  $SL(2,q)$ is used, see for example~\cite{Hup67}.
##  The generators of the orthogonal groups are taken
##  from~\cite{IshibashiEarnest94} and~\cite{KleidmanLiebeck90},
##  except that the generators of the orthogonal groups in odd dimension in
##  even characteristic are constructed via the isomorphism to a symplectic
##  group, see for example~\cite{Car72a}.
##
##  For symplectic and orthogonal matrix groups returned by the functions
##  described below, the invariant bilinear form is stored as the value of
##  the attribute `InvariantBilinearForm' (see~"InvariantBilinearForm").
##  Analogously, the invariant sesquilinear form defining the unitary groups
##  is stored as the value of the attribute `InvariantSesquilinearForm'
##  (see~"InvariantSesquilinearForm").
##  The defining quadratic form of orthogonal groups is stored as the value
##  of the attribute `InvariantQuadraticForm' (see~"InvariantQuadraticForm").
##


#############################################################################
##
#O  GeneralLinearGroupCons( <filter>, <d>, <q> )
##
DeclareConstructor( "GeneralLinearGroupCons", [ IsGroup, IsInt, IsInt ] );


#############################################################################
##
#F  GeneralLinearGroup( [<filt>, ]<d>, <q> )  . . . . .  general linear group
#F  GL( [<filt>, ]<d>, <q> )
##
##  constructs a group isomorphic to the general linear group GL( <d>, <q> )
##  of all $<d> \times <d>$ matrices over the field with <q> elements,
##  in the category given by the filter <filt>.
##
##  If <filt> is not given it defaults to `IsMatrixGroup',
##  and the returned group is the general linear group as a matrix group in
##  its natural action (see also~"IsNaturalGL").
##
BindGlobal( "GeneralLinearGroup", function ( arg )

  if Length(arg) = 2  then
    return GeneralLinearGroupCons( IsMatrixGroup, arg[1], arg[2] );
  elif IsOperation(arg[1]) then

    if Length(arg) = 3  then
      return GeneralLinearGroupCons( arg[1], arg[2], arg[3] );
    fi;
  fi;
  Error( "usage: GeneralLinearGroup( [<filter>, ]<d>, <q> )" );

end );

DeclareSynonym( "GL", GeneralLinearGroup );


#############################################################################
##
#O  GeneralOrthogonalGroupCons( <filter>, <e>, <d>, <q> )
##
DeclareConstructor( "GeneralOrthogonalGroupCons",
    [ IsGroup, IsInt, IsPosInt, IsPosInt ] );


#############################################################################
##
#F  GeneralOrthogonalGroup( [<filt>, ][<e>, ]<d>, <q> ) .  gen. orthog. group
#F  GO( [<filt>, ][<e>, ]<d>, <q> )
##
##  constructs a group isomorphic to the
##  general orthogonal group GO( <e>, <d>, <q> ) of those $<d> \times <d>$
##  matrices over the field with <q> elements that respect a non-singular
##  quadratic form (see~"InvariantQuadraticForm") specified by <e>,
##  in the category given by the filter <filt>.
##  
##  The value of <e> must be $0$ for odd <d> (and can optionally be 
##  omitted in this case), respectively  one of  $1$ or $-1$ for even <d>.
##  If <filt> is not given it defaults to `IsMatrixGroup',
##  and the returned group is the general orthogonal group itself.
##
##  Note that in~\cite{KleidmanLiebeck90}, GO is defined as the stabilizer
##  $\Delta(V,F,\kappa)$ of the quadratic form, up to scalars,
##  whereas our GO is called $I(V,F,\kappa)$ there.
##
BindGlobal( "GeneralOrthogonalGroup", function ( arg )

  if   Length( arg ) = 2 then
    return GeneralOrthogonalGroupCons( IsMatrixGroup, 0, arg[1], arg[2] );
  elif Length( arg ) = 3 and ForAll( arg, IsInt ) then
    return GeneralOrthogonalGroupCons( IsMatrixGroup,arg[1],arg[2],arg[3] );
  elif IsOperation( arg[1] ) then
    if   Length( arg ) = 3 then
      return GeneralOrthogonalGroupCons( arg[1], 0, arg[2], arg[3] );
    elif Length( arg ) = 4 then
      return GeneralOrthogonalGroupCons( arg[1], arg[2], arg[3], arg[4] );
    fi;
  fi;
  Error( "usage: GeneralOrthogonalGroup( [<filter>, ][<e>, ]<d>, <q> )" );

end );

DeclareSynonym( "GO", GeneralOrthogonalGroup );


#############################################################################
##
#O  GeneralUnitaryGroupCons( <filter>, <d>, <q> )
##
DeclareConstructor( "GeneralUnitaryGroupCons",
    [ IsGroup, IsPosInt, IsPosInt ] );


#############################################################################
##
#F  GeneralUnitaryGroup( [<filt>, ]<d>, <q> ) . . . . . general unitary group
#F  GU( [<filt>, ]<d>, <q> )
##
##  constructs a group isomorphic to the general unitary group GU( <d>, <q> )
##  of those $<d> \times <d>$ matrices over the field with $<q>^2$ elements
##  that respect a fixed nondegenerate sesquilinear form,
##  in the category given by the filter <filt>.
##
##  If <filt> is not given it defaults to `IsMatrixGroup',
##  and the returned group is the general unitary group itself.
##
BindGlobal( "GeneralUnitaryGroup", function ( arg )

  if Length( arg ) = 2 then
    return GeneralUnitaryGroupCons( IsMatrixGroup, arg[1], arg[2] );
  elif IsOperation( arg[1] ) then

    if Length( arg ) = 3 then
      return GeneralUnitaryGroupCons( arg[1], arg[2], arg[3] );
    fi;
  fi;
  Error( "usage: GeneralUnitaryGroup( [<filter>, ]<d>, <q> )" );

end );

DeclareSynonym( "GU", GeneralUnitaryGroup );


#############################################################################
##
#O  SpecialLinearGroupCons( <filter>, <d>, <q> )
##
DeclareConstructor( "SpecialLinearGroupCons", [ IsGroup, IsInt, IsInt ] );


#############################################################################
##
#F  SpecialLinearGroup( [<filt>, ]<d>, <q> )  . . . . .  special linear group
#F  SL( [<filt>, ]<d>, <q> )
##
##  constructs a group isomorphic to the special linear group SL( <d>, <q> )
##  of all those $<d> \times <d>$ matrices over the field with <q> elements
##  whose determinant is the identity of the field,
##  in the category given by the filter <filt>.
##
##  If <filt> is not given it defaults to `IsMatrixGroup',
##  and the returned group is the special linear group as a matrix group in
##  its natural action (see also~"IsNaturalSL").
##
BindGlobal( "SpecialLinearGroup", function ( arg )

  if Length(arg) = 2  then
    return SpecialLinearGroupCons( IsMatrixGroup, arg[1], arg[2] );
  elif IsOperation(arg[1]) then

    if Length(arg) = 3  then
      return SpecialLinearGroupCons( arg[1], arg[2], arg[3] );
    fi;
  fi;
  Error( "usage: SpecialLinearGroup( [<filter>, ]<d>, <q> )" );

end );

DeclareSynonym( "SL", SpecialLinearGroup );


#############################################################################
##
#O  SpecialOrthogonalGroupCons( <filter>, <e>, <d>, <q> )
##
DeclareConstructor( "SpecialOrthogonalGroupCons",
    [ IsGroup, IsInt, IsPosInt, IsPosInt ] );


#############################################################################
##
#F  SpecialOrthogonalGroup( [<filt>, ][<e>, ]<d>, <q> ) . spec. orthog. group
#F  SO( [<filt>, ][<e>, ]<d>, <q> )
##
##  `SpecialOrthogonalGroup' returns a group isomorphic to the 
##  special orthogonal group SO( <e>, <d>, <q> ), which is the subgroup of
##  all those matrices in the general orthogonal group
##  (see~"GeneralOrthogonalGroup") that have determinant one,
##  in the category given by the filter <filt>.
##  (The index of SO( <e>, <d>, <q> ) in GO( <e>, <d>, <q> ) is $2$ if <q> is
##  odd, and $1$ if <q> is even.)
#T Also interesting is the group Omega( <e>, <d>, <q> ), which is always of
#T index $2$ in SO( <e>, <d>, <q> );
#T this is the subgroup of all matrices with square spinor norm in odd
#T characteristic or Dickson invariant $0$ in even characteristic.
##
##  If <filt> is not given it defaults to `IsMatrixGroup',
##  and the returned group is the special orthogonal group itself.
##
BindGlobal( "SpecialOrthogonalGroup", function ( arg )

  if   Length( arg ) = 2 then
    return SpecialOrthogonalGroupCons( IsMatrixGroup, 0, arg[1], arg[2] );
  elif Length( arg ) = 3 and ForAll( arg, IsInt ) then
    return SpecialOrthogonalGroupCons( IsMatrixGroup,arg[1],arg[2],arg[3] );
  elif IsOperation( arg[1] ) then
    if   Length( arg ) = 3 then
      return SpecialOrthogonalGroupCons( arg[1], 0, arg[2], arg[3] );
    elif Length( arg ) = 4 then
      return SpecialOrthogonalGroupCons( arg[1], arg[2], arg[3], arg[4] );
    fi;
  fi;
  Error( "usage: SpecialOrthogonalGroup( [<filter>, ][<e>, ]<d>, <q> )" );

end );

DeclareSynonym( "SO", SpecialOrthogonalGroup );


#############################################################################
##
#O  SpecialUnitaryGroupCons( <filter>, <d>, <q> )
##
DeclareConstructor( "SpecialUnitaryGroupCons",
    [ IsGroup, IsPosInt, IsPosInt ] );


#############################################################################
##
#F  SpecialUnitaryGroup( [<filt>, ]<d>, <q> ) . . . . . general unitary group
#F  SU( [<filt>, ]<d>, <q> )
##
##  constructs a group isomorphic to the speial unitary group GU( <d>, <q> )
##  of those $<d> \times <d>$ matrices over the field with $<q>^2$ elements
##  whose determinant is the identity of the field and that respect a fixed
##  nondegenerate sesquilinear form,
##  in the category given by the filter <filt>.
##
##  If <filt> is not given it defaults to `IsMatrixGroup',
##  and the returned group is the special unitary group itself.
##
BindGlobal( "SpecialUnitaryGroup", function ( arg )

  if Length( arg ) = 2 then
    return SpecialUnitaryGroupCons( IsMatrixGroup, arg[1], arg[2] );
  elif IsOperation( arg[1] ) then

    if Length( arg ) = 3 then
      return SpecialUnitaryGroupCons( arg[1], arg[2], arg[3] );
    fi;
  fi;
  Error( "usage: SpecialUnitaryGroup( [<filter>, ]<d>, <q> )" );

end );

DeclareSynonym( "SU", SpecialUnitaryGroup );


#############################################################################
##
#O  SymplecticGroupCons( <filter>, <d>, <q> )
##
DeclareConstructor( "SymplecticGroupCons", [ IsGroup, IsPosInt, IsPosInt ] );


#############################################################################
##
#F  SymplecticGroup( [<filt>, ]<d>, <q> ) . . . . . . . . .  symplectic group
#F  Sp( [<filt>, ]<d>, <q> )
#F  SP( [<filt>, ]<d>, <q> )
##
##  constructs a group isomorphic to the symplectic group Sp( <d>, <q> )
##  of those $<d> \times <d>$ matrices over the field with <q> elements
##  that respect a fixed nondegenerate symplectic form,
##  in the category given by the filter <filt>.
##
##  If <filt> is not given it defaults to `IsMatrixGroup',
##  and the returned group is the symplectic group itself.
##
BindGlobal( "SymplecticGroup", function ( arg )

  if Length( arg ) = 2 then
    return SymplecticGroupCons( IsMatrixGroup, arg[1], arg[2] );
  elif IsOperation( arg[1] ) then

    if Length( arg ) = 3 then
      return SymplecticGroupCons( arg[1], arg[2], arg[3] );
    fi;
  fi;
  Error( "usage: SymplecticGroup( [<filter>, ]<d>, <q> )" );

end );

DeclareSynonym( "Sp", SymplecticGroup );
DeclareSynonym( "SP", SymplecticGroup );


BindGlobal("DECLARE_PROJECTIVE_GROUPS_OPERATION",
  # (<name>,<abbreviation>,<fieldextdeg>,<sizefunc-or-fail>)
  function(nam,abbr,extdeg,szf)
local pnam,cons,opr;
  opr:=VALUE_GLOBAL(nam);
  pnam:=Concatenation("Projective",nam);
  cons:=NewConstructor(Concatenation(pnam,"Cons"),[IsGroup,IsInt,IsInt]);
  BindGlobal(Concatenation(pnam,"Cons"),cons);
  BindGlobal(pnam,function(arg)
    if Length(arg) = 2  then
      return cons( IsPermGroup, arg[1], arg[2] );
    elif IsOperation(arg[1]) then
      if Length(arg) = 3  then
	return cons( arg[1], arg[2], arg[3] );
      fi;
    fi;
    Error( "usage: ",pnam,"( [<filter>, ]<d>, <q> )" );
  end );
  DeclareSynonym(Concatenation("P",abbr),VALUE_GLOBAL(pnam));

  # install a method to get the permutation action on lines
  InstallMethod( cons,"action on lines",
      [ IsPermGroup, IsPosInt,IsPosInt ],
  function(fil,n,q)
  local g,f,p;
    g:=opr(IsMatrixGroup,n,q);
    f:=GF(q^extdeg);
    p:=ProjectiveActionOnFullSpace(g,f,n);
    if szf<>fail then
      SetSize(p,szf(n,q,g));
    fi;
    return p;
  end);

end);


#############################################################################
##
#F  ProjectiveGeneralLinearGroup( [<filt>, ]<d>, <q> )
#F  PGL( [<filt>, ]<d>, <q> )
##
##  constructs a group isomorphic to the projective general linear group
##  PGL( <d>, <q> ) of those $<d> \times <d>$ matrices over the field with
##  <q> elements, modulo the
##  centre, in the category given by the filter <filt>.
##
##  If <filt> is not given it defaults to `IsPermGroup',
##  and the returned group is the action on lines of the underlying vector
##  space.
##

#PseudoDeclare("ProjectiveGeneralLinearGroup");
#PseudoDeclare("PGL");
DECLARE_PROJECTIVE_GROUPS_OPERATION("GeneralLinearGroup","GL",1,
  # size function
  function(n,q,g)
    return Size(g)/(q-1);
  end);


#############################################################################
##
#F  ProjectiveSpecialLinearGroup( [<filt>, ]<d>, <q> )
#F  PSL( [<filt>, ]<d>, <q> )
##
##  constructs a group isomorphic to the projective special linear group
##  PSL( <d>, <q> ) of those $<d> \times <d>$ matrices over the field with
##  <q> elements whose determinant is the identity of the field, modulo the
##  centre, in the category given by the filter <filt>.
##
##  If <filt> is not given it defaults to `IsPermGroup',
##  and the returned group is the action on lines of the underlying vector
##  space.
##

#PseudoDeclare("ProjectiveSpecialLinearGroup");
#PseudoDeclare("PSL");
DECLARE_PROJECTIVE_GROUPS_OPERATION("SpecialLinearGroup","SL",1,
  # size function
  function(n,q,g)
    return Size(g)/Gcd(n,q-1);
  end);


#############################################################################
##
#F  ProjectiveGeneralUnitaryGroup( [<filt>, ]<d>, <q> )
#F  PGU( [<filt>, ]<d>, <q> )
##
##  constructs a group isomorphic to the projective general unitary group
##  PGU( <d>, <q> ) of those $<d> \times <d>$ matrices over the field with
##  $<q>^2$ elements that respect a fixed nondegenerate sesquilinear form,
##  modulo the centre, in the category given by the filter <filt>.
##
##  If <filt> is not given it defaults to `IsPermGroup',
##  and the returned group is the action on lines of the underlying vector
##  space.
##

#PseudoDeclare("ProjectiveGeneralUnitaryGroup");
#PseudoDeclare("PGU");
DECLARE_PROJECTIVE_GROUPS_OPERATION("GeneralUnitaryGroup","GU",2,
  # size function
  function(n,q,g)
    return Size(g)/(q+1);
  end);


#############################################################################
##
#F  ProjectiveSpecialUnitaryGroup( [<filt>, ]<d>, <q> )
#F  PSU( [<filt>, ]<d>, <q> )
##
##  constructs a group isomorphic to the projective special unitary group
##  PSU( <d>, <q> ) of those $<d> \times <d>$ matrices over the field with
##  $<q>^2$ elements that respect a fixed nondegenerate sesquilinear form
##  and have determinant 1,
##  modulo the centre, in the category given by the filter <filt>.
##
##  If <filt> is not given it defaults to `IsPermGroup',
##  and the returned group is the action on lines of the underlying vector
##  space.
##

#PseudoDeclare("ProjectiveSpecialUnitaryGroup");
#PseudoDeclare("PSU");
DECLARE_PROJECTIVE_GROUPS_OPERATION("SpecialUnitaryGroup","SU",2,
  # size function
  function(n,q,g)
    return Size(g)/Gcd(n,q+1);
  end);


#############################################################################
##
#F  ProjectiveSymplecticGroup( [<filt>, ]<d>, <q> )
#F  PSP( [<filt>, ]<d>, <q> )
#F  PSp( [<filt>, ]<d>, <q> )
##
##  constructs a group isomorphic to the projective symplectic group
##  PSp(<d>,<q>) of those $<d> \times <d>$ matrices over the field with <q>
##  elements that respect a fixed nondegenerate symplectic form, modulo the
##  centre, in the category given by the filter <filt>.
##
##  If <filt> is not given it defaults to `IsPermGroup',
##  and the returned group is the action on lines of the underlying vector
##  space.
##

#PseudoDeclare("ProjectiveSymplecticGroup");
#PseudoDeclare("PSP");
DECLARE_PROJECTIVE_GROUPS_OPERATION("SymplecticGroup","SP",2,
  # size function
  function(n,q,g)
    return Size(g)/Gcd(2,q-1);
  end);
DeclareSynonym( "PSp", PSP );


#############################################################################
##
#E

