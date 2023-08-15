#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains methods for elements of rings, given as Z-modules with
##  structure constants for multiplication. It is based on algsc.gi
##


BindGlobal("SCRingReducedModuli",function(moduli,l)
local i;
  if not IsMutable(l) then l:=ShallowCopy(l);fi;
  for i in [1..Length(l)] do
    if moduli[i]<>0 then
      l[i]:=l[i] mod moduli[i];
    fi;
  od;
  return l;
end);

#############################################################################
##
#M  ObjByExtRep( <Fam>, <descr> ) . . . . . . . .  for s.~c. ring elements
##
##  Check whether the coefficients list <coeffs> has the right length,
##  and has integer entries bound by the moduli
##
InstallMethod( ObjByExtRep,
    "for s. c. ring elements family",
    [ IsSCRingObjFamily, IsHomogeneousList ],
    function( Fam, coeffs )
    if Length( coeffs ) <> Length( Fam!.names ) then
      Error( "<coeffs> must be a list of length ", Length( Fam!.names ) );
    elif not ForAll( [1..Length(coeffs)], IsInt ) and
      ForAll([1..Length(coeffs)],p->Fam!.moduli[p]=0 or
        (0<=coeffs[p] and coeffs[p]<Fam!.moduli[p])) then
      Error( "all in <coeffs> must be integers bounded by `moduli'" );
    fi;
    return Objectify( Fam!.defaultTypeDenseCoeffVectorRep,
                      [ Immutable( coeffs ) ] );
    end );

#############################################################################
##
#M  ExtRepOfObj( <elm> )  . . . . . . . . . . . .  for s.~c. ring elements
##
InstallMethod( ExtRepOfObj,
    "for s. c. ring element in dense coeff. vector rep.",
    [ IsSCRingObj and IsDenseCoeffVectorRep ], elm -> elm![1] );

#############################################################################
##
#M  Print( <elm> )  . . . . . . . . . . . . . . .  for s.~c. ring elements
##
InstallMethod( PrintObj,
    "for s. c. ring element",
    [ IsSCRingObj ],
    function( elm )

    local F,      # family of `elm'
          names,  # generators names
          moduli,
          len,    # dimension of the ring
          zero,   # zero element of the ring
          depth,  # first nonzero position in coefficients list
          i;      # loop over the coefficients list

    F     := FamilyObj( elm );
    names := F!.names;
    moduli:= F!.moduli;
    elm   := ExtRepOfObj( elm );
    len   := Length( elm );

    # Treat the case that the ring is trivial.
    if len = 0 then
      Print( "<zero of trivial s.c. ring>" );
      return;
    fi;

    depth := PositionNonZero( elm );

    if len < depth then

      # Print the zero element.
      # (Note that the unique element of a zero ring has a name.)
      Print( "0*", names[1] );

    else

      if elm[depth]<>1 and elm[depth]-moduli[depth] =-1 then
          Print("-");
      elif elm[ depth ] <> 1 then
        Print( elm[ depth ], "*" );
      fi;
      Print( names[ depth ] );

      for i in [ depth+1 .. len ] do
        if elm[i] <> 0 then
          if elm[i]=1 then
            Print( "+" );
          elif elm[i]-moduli[i] =-1 then
            Print("-");
          elif elm[i] <> 1 then
            Print("+", elm[i], "*" );
          fi;
          Print( names[i] );
        fi;
      od;
    fi;
end);

#############################################################################
##
#M  String( <elm> )  . . . . . . . . . . . . . . .  for s.~c. ring elements
##
InstallMethod( String, "for s. c. ring element", [ IsSCRingObj ],
function( elm )

    local s,      # string
          names,  # generators names
          moduli,
          len,    # dimension of the ring
          zero,   # zero element of the ring
          depth,  # first nonzero position in coefficients list
          i;      # loop over the coefficients list

    names := FamilyObj(elm)!.names;
    moduli:= FamilyObj(elm)!.moduli;
    elm   := ExtRepOfObj( elm );
    len   := Length( elm );

    # Treat the case that the ring is trivial.
    if len = 0 then
      return "<zero of trivial s.c. ring>";
    fi;

    depth := PositionNonZero( elm );

    if len < depth then

      # Print the zero element.
      # (Note that the unique element of a zero ring has a name.)
      return Concatenation( "0*", names[1] );

    else

      s:="";
      if elm[depth]<>1 and elm[depth]-moduli[depth] =-1 then
        Add(s,'-');
      elif elm[ depth ] <> 1 then
        Append(s,String(elm[ depth ]));
        Add(s,'*');
      fi;
      Append(s, names[ depth ] );

      for i in [ depth+1 .. len ] do
        if elm[i] <> 0 then
          if elm[i]=1 then
            Add(s,'+');
          elif elm[i]-moduli[i] =-1 then
            Add(s,'-');
          elif elm[i] <> 1 then
            Add(s,'+');
            Append(s,String( elm[i]));
            Add(s,'*');
          fi;
          Append(s, names[i] );
        fi;
      od;

  fi;
  return s;
end );

#############################################################################
##
#M  \=( <x>, <y> )  . . . . . . . . . . equality of two s.~c. ring objects
#M  \<( <x>, <y> )  . . . . . . . . . comparison of two s.~c. ring objects
#M  \+( <x>, <y> )  . . . . . . . . . . . .  sum of two s.~c. ring objects
#M  \-( <x>, <y> )  . . . . . . . . . difference of two s.~c. ring objects
#M  \*( <x>, <y> )  . . . . . . . . . .  product of two s.~c. ring objects
#M  Zero( <x> ) . . . . . . . . . . . . . .  zero of an s.~c. ring element
#M  AdditiveInverse( <x> )  . .  additive inverse of an s.~c. ring element
#M  Inverse( <x> )  . . . . . . . . . . . inverse of an s.~c. ring element
##
InstallMethod( \=,
    "for s. c. ring elements in dense vector rep.",
    IsIdenticalObj,
    [ IsSCRingObj and IsDenseCoeffVectorRep,
      IsSCRingObj and IsDenseCoeffVectorRep ],
    function( x, y ) return x![1] = y![1]; end );

InstallMethod( \<,
    "for s. c. ring elements in dense vector rep.",
    IsIdenticalObj,
    [ IsSCRingObj and IsDenseCoeffVectorRep,
      IsSCRingObj and IsDenseCoeffVectorRep ], 0,
    function( x, y ) return x![1] < y![1]; end );

InstallMethod( \+,
    "for s. c. ring elements in dense vector rep.",
    IsIdenticalObj,
    [ IsSCRingObj and IsDenseCoeffVectorRep,
      IsSCRingObj and IsDenseCoeffVectorRep ],
function( x, y )
  local fam;
  fam:=FamilyObj(x);
  return Objectify( fam!.defaultTypeDenseCoeffVectorRep,
            [ Immutable( SCRingReducedModuli(fam!.moduli,x![1]+y![1])) ] );
end );

InstallMethod( \-,
    "for s. c. ring elements in dense vector rep.",
    IsIdenticalObj,
    [ IsSCRingObj and IsDenseCoeffVectorRep,
      IsSCRingObj and IsDenseCoeffVectorRep ],
function( x, y )
local fam;
  fam:=FamilyObj(x);
  return Objectify( fam!.defaultTypeDenseCoeffVectorRep,
            [ Immutable( SCRingReducedModuli(fam!.moduli,x![1]-y![1])) ] );
end );

InstallMethod( \*,
    "for s. c. ring elements in dense vector rep.",
    IsIdenticalObj,
    [ IsSCRingObj and IsDenseCoeffVectorRep,
      IsSCRingObj and IsDenseCoeffVectorRep ],
    function( x, y )
local fam;
  fam:= FamilyObj( x );
  return Objectify( fam!.defaultTypeDenseCoeffVectorRep,
            [ Immutable( SCRingReducedModuli(fam!.moduli,
                        SCTableProduct( fam!.sctable, x![1], y![1] ) )) ] );
  end );

InstallMethod( \*,
    "for integer and s. c. ring element in dense vector rep.",
    IsCoeffsElms,
    [ IsInt, IsSCRingObj and IsDenseCoeffVectorRep ],
function( x, y )
local fam;
  fam:=FamilyObj(y);
  return Objectify( fam!.defaultTypeDenseCoeffVectorRep,
            [ Immutable( SCRingReducedModuli(fam!.moduli,x*y![1])) ] );
end );

InstallMethod( \*,
    "for s. c. ring element in dense vector rep. and integer",
    IsElmsCoeffs,
    [ IsSCRingObj and IsDenseCoeffVectorRep, IsInt ],
function( x, y )
local fam;
  fam:=FamilyObj(x);
  return Objectify( fam!.defaultTypeDenseCoeffVectorRep,
            [ Immutable( SCRingReducedModuli(fam!.moduli,x![1]*y)) ] );
end );

InstallMethod( ZeroOp, "for s. c. ring element", [ IsSCRingObj ],
function( x )
local fam;
  fam:=FamilyObj(x);
  return Objectify( fam!.defaultTypeDenseCoeffVectorRep,
            [ Immutable( SCRingReducedModuli(fam!.moduli,0*x![1])) ] );
end );

InstallMethod( AdditiveInverseOp, "for s. c. ring element", [ IsSCRingObj ],
function( x )
local fam;
  fam:=FamilyObj(x);
  return Objectify( fam!.defaultTypeDenseCoeffVectorRep,
            [ Immutable( SCRingReducedModuli(fam!.moduli,-x![1])) ] );
end );

InstallMethod( OneOp, "for s. c. ring element", [ IsSCRingObj ],
function( x )
local fam,r;
  fam:=FamilyObj(x);
  r:=fam!.fullSCRing;
  return One(r);
end );

InstallMethod( InverseOp, "for s. c. ring element", [ IsSCRingObj ],
function( x )
local fam,r,w,l,o;
  fam:=FamilyObj(x);
  r:=fam!.fullSCRing;
  if One(r)=fail then return fail;fi;
  if IsFinite(r) then
    r:=Filtered(AsSSortedList(r),y->x*y=One(r) and y*x=One(r));
    if Length(r)>0 then
      return r[1];
    else
      return fail;
    fi;
  else
    o:=One(r);
    if x=o then return x;fi;
    # try powering
    w:=x;
    l:=[w];
    repeat
      w:=w*x;
      if w=o then
        # last entry was inverse
        return l[Length(l)];
      fi;
      if w in l then
        # loop without inverse -- not invertible
        return fail;
      fi;
      Add(l,w);
    until Length(l)>10^6;
    Error("cannot find inverse");
  fi;
end );

#############################################################################
##
#F  RingByStructureConstants( <moduli>, <sctable> )
#F  RingByStructureConstants( <moduli>, <sctable>, <name> )
#F  RingByStructureConstants( <moduli>, <sctable>, <names> )
#F  RingByStructureConstants( <moduli>, <sctable>, <name1>, <name2>, ... )
##
##  is an Z-module $M$ defined by the structure constants
##  table <sctable> of length $n$.
##
##  The generators of $M$ are linearly independent abstract space generators
##  $x_1, x_2, \ldots, x_n$ whose additive orders is given by the list
##  <moduli>.  They are multiplied according to the formula
##  $ x_i x_j = \sum_{k=1}^n c_{ijk} x_k$
##  where `$c_{ijk}$ = <sctable>[i][j][1][i_k]'
##  and `<sctable>[i][j][2][i_k] = k'.
##
InstallGlobalFunction( RingByStructureConstants, function( arg )
    local T,      # structure constants table
          n,      # dimensions of structure matrices
          moduli, # additive orders of generators
          names,  # names of the ring generators
          Fam,    # the family of ring elements
          A,      # the ring, result
          filter,
          gens;   # ring generators of `A'

    # Check the argument list.
    if not 1 < Length( arg ) and IsList( arg[1] )
                                 and Length(arg[1])>0
                                 and IsList( arg[2] ) then
      Error( "usage: RingByStructureConstants([<moduli>,<sctable>]) or \n",
             "RingByStructureConstants([<moduli>,<sctable>,<name1>,...])" );
    fi;

    moduli := arg[1];
    n:=Length(moduli);
    T    := Immutable(arg[2]);

    # Construct names of generators (used for printing only).
    if   Length( arg ) = 2 then
      names:= List( [ 1 .. n ],
                    x -> Concatenation( "r.", String(x) ) );
      MakeImmutable( names );
    elif Length( arg ) = 3 and IsString( arg[3] ) then
      names:= List( [ 1 .. n ],
                    x -> Concatenation( arg[3], String(x) ) );
      MakeImmutable( names );
    elif Length( arg ) = 3 and IsHomogeneousList( arg[3] )
                               and Length( arg[3] ) = n
                               and ForAll( arg[3], IsString ) then
      names:= Immutable( arg[3] );
    elif Length( arg ) = 2 + n then
      names:= Immutable( arg{ [ 3 .. Length( arg ) ] } );
    else
      Error( "usage: RingByStructureConstants([<moduli>,<sctable>]) or \n",
             "RingByStructureConstants([<moduli>,<sctable>,<name1>,...])" );
    fi;

    filter:= IsSCRingObj and IsAdditivelyCommutativeElement;

    # Construct the family of elements of our ring.
    Fam:= NewFamily( "SCRingObjFamily", filter );

#X    # If the elements family of `R' has a uniquely determined zero element,
#X    # then all coefficients in this family are admissible.
#X    # Otherwise only coefficients from `R' itself are allowed.
#X    if Zero( ElementsFamily( FamilyObj( R ) ) ) <> fail then
#X      SetFilterObj( Fam, IsFamilyOverFullCoefficientsFamily );
#X    else
#X      Fam!.coefficientsDomain:= R;
#X    fi;

    Fam!.moduli    := moduli;
    Fam!.sctable   := T;
    Fam!.names     := names;

    # Construct the default type of the family.
    Fam!.defaultTypeDenseCoeffVectorRep :=
        NewType( Fam, IsSCRingObj and IsDenseCoeffVectorRep );

    SetCoefficientsFamily( Fam, ElementsFamily( FamilyObj( Integers ) ) );
    # temporary
    SetIsUFDFamily(Fam,false);

    # Make the generators and the ring.
    SetZero( Fam, ObjByExtRep( Fam, List( [ 1 .. n ], x -> 0 ) ) );
    gens:= Immutable( List( IdentityMat( n, Integers ),
                            x -> ObjByExtRep( Fam, x ) ) );
    A:= RingByGenerators( gens );
    SetIsWholeFamily(A,true);

    if Length(moduli)=0 then
      SetSize(A,1);
    elif Product(moduli)=0 then
      SetSize(A,infinity);
    else
      SetSize(A,Product(moduli));
    fi;
#X    Fam!.basisVectors:= gens;

    # Store the ring in the family of the elements,
    # for accessing the full ring, e.g., in `DefaultFieldOfMatrixGroup'.
    Fam!.fullSCRing:= A;

    SetRepresentative(A,Zero(A));

    # if there is only 1 generator, the `One' - if any - can be obtained easily
    if Length(moduli)=1 then
      n:=ExtRepOfObj(gens[1]^2)[1];
      if moduli[1]=0 and n=1 then
        n:=ObjByExtRep(Fam,[1]);
        SetOne(Fam,n);
        SetOne(A,n);
      elif moduli[1]=0 and n=-1 then
        n:=ObjByExtRep(Fam,[-1]);
        SetOne(Fam,n);
        SetOne(A,n);
      elif moduli[1]>1 and Gcd(n,moduli[1])=1 then
        n:=1/n mod moduli[1];
        n:=ObjByExtRep(Fam,[n]);
        SetOne(Fam,n);
        SetOne(A,n);
      fi;
    fi;

    # Return the ring.
    return A;
end );

InstallAccessToGenerators( IsSubringSCRing and IsWholeFamily,
                           "whole SC ring", GeneratorsOfRing );

BindGlobal("SCRingElmSift",function(moduli,l,pivots,e,test)
local i, j, q;
  #e:=SCRingReducedModuli(moduli,e);
  if Length(l)=0 then
    if test=true then
      return IsZero(e);
    else
      return e;
    fi;
  fi;

  i:=1;
  while i<=Length(e) do
    if e[i]<>0 then
      # find corresponding pivot
      if IsBound(pivots[i]) then
        j:=pivots[i];
        # reduce
        q:=e[i]/l[j][i];
        if IsInt(q) then
          # can reduce completely
          e:=e-q*l[j];
          e:=SCRingReducedModuli(moduli,e);
        else
          ## cannot eliminate
          #if test=true then return false;fi;
          e:=e-Int(q)*l[j];
          e:=SCRingReducedModuli(moduli,e);
          if test=0 and e[i]<>0 then
            # stop after first nonzero reduction
            return e;
          fi;
        fi;
#      else
#       # no pivot -- not in
#       if test=true then
#          Error("GNU");
#         return false;
#       elif test=0 then
#         # element will give new pivot
#         return e;
#       fi;
      fi;
    fi;
    i:=i+1;
  od;
  if test=true then return IsZero(e);fi;
  return e;
end);

BindGlobal("SCRingElmSiftImages",function(moduli,l,imgs,pivots,e,ei)
local i, j, q;
  if Length(l)=0 then
    return [e,ei];
  fi;

  i:=1;
  while i<=Length(e) do
    if e[i]<>0 then
      # find corresponding pivot
      if IsBound(pivots[i]) then
        j:=pivots[i];
        # reduce
        q:=e[i]/l[j][i];
        if IsInt(q) then
          # can reduce completely
          e:=e-q*l[j];
          e:=SCRingReducedModuli(moduli,e);
          ei:=ei-q*imgs[j];
        else
          # cannot eliminate
          e:=e-Int(q)*l[j];
          e:=SCRingReducedModuli(moduli,e);
          ei:=ei-Int(q)*imgs[j];
          # stop after first reduction
          if e[i]<>0 then
            return [e,ei];
          fi;
        fi;
#      else
#       # no pivot -- not in
#       # element will give new pivot
#       return [e,ei];
      fi;
    fi;
    i:=i+1;
  od;
  return [e,ei];
end);

BindGlobal("SCRHNFExtend",function(moduli,l,pivots,e,imgs,ei)
local p, j, f, fj, g, q, gj, m, k, i;
  if not IsMutable(l) then l:=ShallowCopy(l);fi;
  if not IsMutable(pivots) then pivots:=ShallowCopy(pivots);fi;
  repeat
    if imgs=false then
      e:=SCRingElmSift(moduli,l,pivots,e,0);
      ei:=0;
    else
      e:=SCRingElmSiftImages(moduli,l,imgs,pivots,e,ei);
      ei:=e[2];
      e:=e[1];
    fi;

    #p:=PositionNonZero(e);
    # find the position of largest order
    p:=-1;
    f:=1;
    for j in [1..Length(moduli)] do
      if e[j]<>0 then
        g:=moduli[j]/Gcd(moduli[j],e[j]); # local order
        if g>f then
          f:=g;
          p:=j;
        fi;
      fi;
    od;

    if p>0 and IsBound(pivots[p]) then
      # reduction occurred at pivot element -- need to reduce further
      j:=pivots[p];
      f:=l[j];
      if imgs<>false then
        fj:=imgs[j];
      else
        fj:=0;
      fi;
      repeat
        g:=f;
        f:=e;
        q:=QuoInt(g[p],f[p]);
        e:=g-q*f;
        if imgs<>false then
          gj:=fj;
          fj:=ei;
          ei:=gj-q*fj;
        fi;
        e:=SCRingReducedModuli(moduli,e);
      until e[p]=0;

      #modify l
      if f[p]<0 then f:=-f;fj:=-fj;fi;
      # clean out f
      for k in [p+1..Length(moduli)] do
        if IsBound(pivots[k]) then
          q:=QuoInt(f[k],l[pivots[k]][k]);
          f:=SCRingReducedModuli(moduli,f-q*l[pivots[k]]);
          if imgs<>false then
            fj:=fj-q*imgs[pivots[k]];
          fi;
        fi;
      od;

      #Print("Set l[",j,"]:=",f," at ",p,"\n");
      l[j]:=f;
      if imgs<>false then
        imgs[j]:=f;
      fi;
      # clean out above
      for i in [1..j-1] do
        for k in [p..Length(moduli)] do
          if IsBound(pivots[k]) then
            q:=QuoInt(l[i][k],l[pivots[k]][k]);
            l[i]:=SCRingReducedModuli(moduli,l[i]-q*l[pivots[k]]);
            if imgs<>false then
              imgs[i]:=imgs[i]-q*imgs[pivots[k]];
            fi;
          fi;
        od;
      od;
    fi;
  until IsZero(e) or not IsBound(pivots[p]);

  if not IsZero(e) then
    # reduce modulo:
    if moduli[p]>0 then
      m:=Gcdex(e[p],moduli[p]);
      e:=e*m.coeff1;
      e:=SCRingReducedModuli(moduli,e);
      if imgs<>false then
        ei:=ei*m.coeff1;
      fi;
    fi;

    if e[p]<0 then e:=-e;ei:=-ei;fi;
    # find last known pivot before p
    j:=p-1;
    while j>0 and not IsBound(pivots[j]) do
      j:=j-1;
    od;
    if j>0 then
      j:=pivots[j];
    fi;
    # adjust pivots for insertion
    for i in [1..Length(pivots)] do
      if IsBound(pivots[i]) and pivots[i]>=j+1 then
        pivots[i]:=pivots[i]+1;
      fi;
    od;
    pivots[p]:=j+1;
    # clean out l[1..j]
    m:=[];
    gj:=[];
    for i in [1..j] do
      q:=QuoInt(l[i][p],e[p]);
      Add(m,SCRingReducedModuli(moduli,l[i]-q*e));
      if imgs<>false then
        Add(gj,imgs[i]-q*ei);
      fi;
    od;
    l:=Concatenation(m,[e],l{[j+1..Length(l)]});
    if imgs<>false then
      imgs:=Concatenation(gj,[ei],imgs{[j+1..Length(imgs)]});
    fi;
  fi;
  return [l,pivots,imgs];
end);

InstallMethod(StandardGeneratorsSubringSCRing,
  "for sc rings and their subrings",
  [IsSubringSCRing],
function(R)
local fam, l, piv, m, new, i, j, p;
  fam:=ElementsFamily(FamilyObj(R));
  l:=[];piv:=[];
  for i in GeneratorsOfRing(R) do
    m:=SCRHNFExtend(fam!.moduli,l,piv,ExtRepOfObj(i),false,false);
    l:=m[1];piv:=m[2];
  od;

  repeat
    new:=false;
    i:=1;
    while new=false and i<=Length(l) do
      j:=1;
      while new=false and j<=Length(l) do
        p:=ExtRepOfObj(ObjByExtRep(fam,l[i])*ObjByExtRep(fam,l[j]));
        m:=SCRHNFExtend(fam!.moduli,l,piv,p,false,false);
        new:=Length(m[1])>Length(l) or m[1]<>l;
        l:=m[1];piv:=m[2];

        j:=j+1;
      od;
      i:=i+1;
    od;
  until new=false;

  #RREF
  if Length(l)>1 then
    for i in [1..Length(piv)] do
      if IsBound(piv[i]) then
        for j in Difference([1..Length(l)],[piv[i]]) do
          p:=QuoInt(l[j][i],l[piv[i]][i]);
          if p>0 then
            l[j]:=l[j]-p*l[piv[i]];
          fi;
        od;
      fi;
    od;
  fi;

  return [l,piv,List(l,i->ObjByExtRep(fam,i))];
end);

BindGlobal("StandardGeneratorsImagesSubringSCRing",
function(fam,gens,imgs)
local l, piv, li, m, new, i, j, p, q;
  l:=[];piv:=[];li:=[];
  for i in [1..Length(gens)] do
    m:=SCRHNFExtend(fam!.moduli,l,piv,ExtRepOfObj(gens[i]),li,imgs[i]);
    l:=m[1];piv:=m[2];li:=m[3];
  od;
  repeat
    new:=false;
    i:=1;
    while new=false and i<=Length(l) do
      j:=1;
      while new=false and j<=Length(l) do
        p:=ExtRepOfObj(ObjByExtRep(fam,l[i])*ObjByExtRep(fam,l[j]));
        q:=li[i]*li[j];
        m:=SCRHNFExtend(fam!.moduli,l,piv,p,li,q);
        new:=Length(m[1])>Length(l);
        l:=m[1];piv:=m[2];li:=m[3];
        j:=j+1;
      od;
      i:=i+1;
    od;
  until new=false;
  return [l,piv,List(l,i->ObjByExtRep(fam,i)),li];
end);

# s is ``standard generators'' entry, e an element, return coefficients
BindGlobal("SCRingDecompositionStandardGens",function(s,e)
  local moduli, c, p, x, i;
  moduli:=FamilyObj(e)!.moduli;
  e:=ExtRepOfObj(e);
  c:=ListWithIdenticalEntries(Length(s[1]),0);
  for i in [1..Length(moduli)] do
    if e[i]<>0 then
      if not IsBound(s[2][i]) then
        Error("element does not lie in ring");
      fi;
      p:=s[2][i];
      if moduli[i]<>0 then
        x:=e[i]/s[1][p][i] mod moduli[i];
      else
        x:=e[i]/s[1][p][i];
      fi;
      c[p]:=x;
      e:=e-x*s[1][p];
      e:=SCRingReducedModuli(moduli,e);
    fi;
  od;
  return c;
end);

InstallMethod(Characteristic,
  "for sc rings and their subrings",
  [IsSubringSCRing and HasGeneratorsOfRing],
function(R)
  local fam, s, moduli, ind, ords, o, i;
  fam:=ElementsFamily(FamilyObj(R));
  s:=StandardGeneratorsSubringSCRing(R);

  # are there generators of infinite order?
  moduli:=fam!.moduli;
  ind:=Filtered([1..Length(moduli)],i->moduli[i]=0);
  if ForAny(s,i->ForAny(ind,x->i[x]<>0)) then
    SetSize(R,infinity);
    return 0;
  fi;

  # get additive order for each generator
  ords:=[];
  for i in s[1] do
    ind:=Filtered([1..Length(moduli)],x->i[x]<>0);
    o:=Lcm(List(ind,x->moduli[x]/Gcd(moduli[x],i[x])));
    Add(ords,o);
  od;
  SetSize(R,Product(ords));
  return Lcm(ords);
end);

InstallMethod(Size,
  "for sc rings and their subrings",
  [IsSubringSCRing and HasGeneratorsOfRing],
function(R)
  local fam, s, moduli, ind, ords, o, i;
  fam:=ElementsFamily(FamilyObj(R));
  s:=StandardGeneratorsSubringSCRing(R);

  # are there generators of infinite order?
  moduli:=fam!.moduli;
  ind:=Filtered([1..Length(moduli)],i->moduli[i]=0);
  if ForAny(s,i->ForAny(ind,x->i[x]<>0)) then
    SetCharacteristic(R,0);
    return infinity;
  fi;

  # get additive order for each generator
  ords:=[];
  for i in s[1] do
    ind:=Filtered([1..Length(moduli)],x->i[x]<>0);
    o:=Lcm(List(ind,x->moduli[x]/Gcd(moduli[x],i[x])));
    Add(ords,o);
  od;
  if Length(ords)=0 then
    ords:=[1];
  else
    SetCharacteristic(R,Lcm(ords));
  fi;
  return Product(ords);
end);

InstallMethod(\in,"SC Rings",IsElmsColls,
  [IsSCRingObj,IsSubringSCRing and HasGeneratorsOfRing],
function(e,r)
local fam,s;
  fam:=FamilyObj(e);
  s:=StandardGeneratorsSubringSCRing(r);
  return SCRingElmSift(fam!.moduli,s[1],s[2],ExtRepOfObj(e),true);
end);

BindGlobal("SCRingGroupInFamily",function(fam)
  local m, a, pcgs, rcgs, x, c, p, e, i,o;
  m:=fam!.moduli;
  if 0 in m then
    return fail;
  elif not IsBound(fam!.group) then
    a:=AbelianGroup(m);
    # translate pcgs generators to ring elements
    pcgs:=FamilyPcgs(a);
    rcgs:=[];
    for i in [1..Length(GeneratorsOfGroup(a))] do
      x:=GeneratorsOfGroup(a)[i];
      c:=1;
      while not IsOne(x) do
        p:=Position(pcgs,x);
        e:=ListWithIdenticalEntries(Length(m),0);
        e[i]:=c;
        rcgs[p]:=ObjByExtRep(fam,e);
        o:=RelativeOrders(pcgs)[p];
        x:=x^o;
        c:=c*o;
      od;
    od;
    fam!.group:=a;
    fam!.rcgs:=rcgs;
  fi;
  return fam!.group;
end);

BindGlobal("SCRingGroupElement",function(fam,e)
  local a, w, i;
  a:=SCRingGroupInFamily(fam);
  e:=ExponentsOfPcElement(FamilyPcgs(a),e);
  w:=Zero(fam);
  for i in [1..Length(e)] do
    w:=w+e[i]*fam!.rcgs[i];
  od;
  return w;
end);

InstallOtherMethod(One,"for finite SC Rings",
  [IsRing],0,
  #{} -> -RankFilter(IsRing),
function(R)
  if not (IsSubringSCRing(R) and IsFinite(R)) then
    TryNextMethod();
  fi;
  #T should be better code for SC rings by solving an equation
  return First(Enumerator(R),i->i=i*i and i<>i+i and
      ForAll(Enumerator(R),j->i*j=j and j*i=j));
end);

InstallOtherMethod(One,"for SC Rings -- try generators",
  [IsRing],0,
function(R)
  local l,a;
  if not IsSubringSCRing(R) then
    TryNextMethod();
  fi;
  l:=GeneratorsOfRing(R);
  a:=First(l,x->ForAll(l,y->x*y=y and y*x=y));
  if a=fail then
    TryNextMethod();
  else
    return a;
  fi;
end);

InstallOtherMethod(OneOp,"for finite SC Rings family",
  [IsSCRingObjFamily],0,
  #{} -> -RankFilter(IsRing),
function(fam)
local R;
  R:=fam!.fullSCRing;
  return One(R);
end);

InstallOtherMethod(IsUnit,"for finite Rings",
  IsCollsElms,[IsRing,IsScalar],0,
function(R,e)
local o,pow,a;
  if not IsFinite(R) then
    TryNextMethod();
  fi;
  if IsAssociative(R) and One(R) <> fail then
    # compute powers of e until we reach one or repeat
    o:=One(R);
    pow:=[];
    a:=e;
    repeat
      Add(pow,a);
      a:=a*e;
      if a=o then
        # power is one. So previous power is inverse
        return true;
      fi;
    until a in pow;
    # repeats without hitting the one element, cannot be a unit
    return false;
  fi;
  return One(R)<>fail
         and ForAny(Enumerator(R),x->x*e=One(R) and e*x=One(R));
end);

InstallMethod(Subrings,"for SC Rings",[IsSubringSCRing],
function(R)
  local fam, a, u, sr, g, l, piv, m, test, x, y, e, t, s, i;
  fam:=ElementsFamily(FamilyObj(R));
  a:=SCRingGroupInFamily(fam);
  # construct all subgroups
  m:=StandardGeneratorsSubringSCRing(R);
  a:=Subgroup(a,List(m[1],i->LinearCombinationPcgs(GeneratorsOfGroup(a),i)));
  u:=List(ConjugacyClassesSubgroups(a),Representative);
  sr:=[];
  #test which ones are a subring
  for s in u do
    g:=List(GeneratorsOfGroup(s),x->SCRingGroupElement(fam,x));
    l:=[];piv:=[];
    for i in g do
      m:=SCRHNFExtend(fam!.moduli,l,piv,ExtRepOfObj(i),false,false);
      l:=m[1];piv:=m[2];
    od;
    test:=true;
    x:=1;
    while test and x<=Length(g) do
      y:=1;
      while test and y<=Length(g) do
        e:=ExtRepOfObj(g[x]*g[y]);
        test:=SCRingElmSift(fam!.moduli,l,piv,e,true);
        y:=y+1;
      od;
      x:=x+1;
    od;
    if test then
      #workaround
      if Length(g)=0 then g:=[Zero(fam)];fi;
      t:=Subring(R,g);
      SetSize(t,Size(s));
      Add(sr,t);
      #Print("Added size ",Size(s),": ",g,"\n");
    else
      #Print("Discarded size ",Size(s),": ",g,"\n");
    fi;
  od;
  return sr;
end);

#############################################################################
##
#M  IsLeftIdealOp( <A>, <S> )
##
InstallOtherMethod( IsLeftIdealOp, "for SCRings", IsIdenticalObj,
    [ IsSubringSCRing, IsSubringSCRing ], 0,
function( A, S )
local gens, a, i;
  if not IsSubset( A, S ) then
    return false;
  fi;

  gens:=StandardGeneratorsSubringSCRing(S)[3];
  for a in GeneratorsOfRing( A ) do
    for i in gens do
      if not a * i in S then
        return false;
      fi;
    od;
  od;
  return true;
end );

#############################################################################
##
#M  IsRightIdealOp( <A>, <S> )
##
InstallOtherMethod( IsRightIdealOp, "for SCRings", IsIdenticalObj,
    [ IsSubringSCRing, IsSubringSCRing ], 0,
function( A, S )
local gens, a, i;
  if not IsSubset( A, S ) then
    return false;
  fi;

  gens:=StandardGeneratorsSubringSCRing(S)[3];
  for a in GeneratorsOfRing( A ) do
    for i in gens do
      if not i*a in S then
        return false;
      fi;
    od;
  od;
  return true;
end );

InstallOtherMethod( IsTwoSidedIdealOp, "for rings and subrings",
    IsIdenticalObj, [ IsRing, IsRing ], 0,
function( A, S )
local is;
  #T Check containment only once!
  is:=IsLeftIdeal(A,S);
  is:=is and IsRightIdeal(A,S);
  return is;
end );

InstallMethod(Ideals,"for SC Rings",[IsSubringSCRing],
function(R)
  return Filtered(Subrings(R),i->IsIdeal(R,i));
end);


#############################################################################
##
#F  DirectSum( <arg> )
##
InstallGlobalFunction( DirectSum, function( arg )
local d,t,i;
  if Length( arg ) = 0 then
    Error( "<arg> must be nonempty" );
  elif Length( arg ) = 1 and IsList( arg[1] ) then
    if IsEmpty( arg[1] ) then
      Error( "<arg>[1] must be nonempty" );
    fi;
    arg:= arg[1];
  fi;

  # special treatment of ``Integers'' as part of a direct sum: Replace by
  # SC ring:
  if ForAny(arg,x->IsIdenticalObj(x,Integers)) then
    t:=EmptySCTable(1,0);
    SetEntrySCTable(t,1,1,[1,1]);
    t:=RingByStructureConstants([0],t,"n");
    arg:=ShallowCopy(arg);
    for i in [1..Length(arg)] do
      if IsIdenticalObj(arg[i],Integers) then
        arg[i]:=t;
      fi;
    od;
  fi;

  d:=DirectSumOp( arg, arg[1] );
  if ForAll(arg,HasSize) then
    if   ForAll(arg,IsFinite)
    then SetSize(d,Product(List(arg,Size)));
    else SetSize(d,infinity); fi;
  fi;
  return d;
end );


#############################################################################
##
#M  DirectSumOp( <list>, <R> )
##
InstallMethod( DirectSumOp, "for a list (of rings), and a ring", true,
    [ IsList, IsRing ], 0,
function( list, gp )
local ids, tup, first, i, G, gens, g, new, D;

  # Check the arguments.
  if IsEmpty( list ) then
    Error( "<list> must be nonempty" );
  elif ForAny( list, G -> not IsRing( G ) ) then
    TryNextMethod();
  fi;

  ids := List( list, Zero );
  tup := [];
  first := [1];
  for i in [1..Length( list )] do
    G    := list[i];
    gens := GeneratorsOfRing( G );
    if Length(gens)=0 then
      gens:=[Zero(G)];
    fi;
    for g in gens do
      new := ShallowCopy( ids );
      new[i] := g;
      new := DirectProductElement( new );
      Add( tup, new );
    od;
    Add( first, Length( tup )+1 );
  od;

  D := RingByGenerators( tup );

  SetDirectSumInfo( D, rec( rings := list,
                            first  := first,
                            embeddings := [],
                            projections := [] ) );

  return D;
end );

InstallMethod( DirectSumOp, "for SC Rings", true,
    [ IsList, IsSubringSCRing ], 0,
function( list, gp )
local ones,s, moduli, orders, offsets, o, p, newmod, t, nams, gens, e, f, D, i, j, k, ii;

  # Check the arguments.
  if IsEmpty( list ) then
    Error( "<list> must be nonempty" );
  elif ForAny( list, G -> not IsSubringSCRing( G ) ) then
    TryNextMethod();
  fi;

  # get respective standard generators
  s:=List(list,StandardGeneratorsSubringSCRing);
  moduli:=List(list,i->ElementsFamily(FamilyObj(i))!.moduli);
  orders:=[];
  offsets:=[0];
  ones:=[];
  for i in [1..Length(list)] do
    o:=[];
    for j in [1..Length(s[i][1])] do
      p:=PositionNonZero(s[i][1][j]);
      if moduli[i][p]=0 then
        Add(o,0);
      else
        Add(o,moduli[i][p]/s[i][1][j][p]);
      fi;
    od;
    Add(orders,o);
    offsets[i+1]:=Sum(List(orders,Length));
    if (HasOne(list[i]) or (HasIsFinite(list[i]) and Size(list[i])<10^5 ))
      and One(list[i])<>fail then
      o:=One(list[i]);
      o:=SCRingDecompositionStandardGens(s[i],o);
      Add(ones,o);
    else
      Add(ones,fail);
    fi;
  od;

  newmod:=Concatenation(orders);
  t:=EmptySCTable(Length(newmod),0);
  nams:=[];
  for i in [1..Length(list)] do
    gens:=s[i][3];
    Append(nams,List([1..Length(gens)],j->[CHARS_UALPHA[i],CHARS_LALPHA[j]]));
    for j in [1..Length(gens)] do
      for k in [1..Length(gens)] do
        e:=gens[j]*gens[k];
        if not IsZero(e) then
          e:=SCRingDecompositionStandardGens(s[i],e);
          f:=[];
          for ii in [1..Length(e)] do
            if e[ii]<>0 then
              Add(f,e[ii]);
              Add(f,ii+offsets[i]);
            fi;
          od;
          SetEntrySCTable(t,j+offsets[i],k+offsets[i],f);
        fi;
      od;
    od;
  od;

  D := RingByStructureConstants(newmod,t,nams);

  if ForAll(ones,i->i<>fail) then
    f:=FamilyObj(Zero(D));
    e:=ObjByExtRep(f,Concatenation(ones));
    SetOne(D,e);
    SetOne(f,e);
  fi;

  SetDirectSumInfo( D, rec( rings := list,
                            first  := offsets,
                            embeddings := [],
                            projections := [] ) );

  return D;
end );

#############################################################################
##
#M  \+( <R1>, <R2> )  . . . . . . . . . . . . . . . . sum of rings
##
InstallOtherMethod( \+, "for two rings", [ IsRing, IsRing ],
function(R1,R2)
  return DirectSum(R1,R2);
end);

# data base of small rings. (Data taken from the nearring library in SONATA)

BindGlobal("NUMBER_SMALL_RINGS",
MakeImmutable([1,2,2,11,2,4,2,52,11,4,2,22,2,4,4]));

BindGlobal("SMALL_RINGS_DATA",
MakeImmutable(
[[1,1,[1],[]],
[2,1,[2],[]],[2,2,[2],[[1,1,[1,1]]]],
[3,1,[3],[]],[3,2,[3],[[1,1,[1,1]]]],
[4,1,[4],[]],[4,2,[4],[[1,1,[2,1]]]],[4,3,[4],[[1,1,[1,1]]]],
[4,4,[2,2],[]],[4,5,[2,2],[[1,1,[1,2]]]],[4,6,[2,2],[[1,1,[1,1]]]],
[4,7,[2,2],[[1,1,[1,1]],[1,2,[1,2]]]],[4,8,[2,2],[[1,1,[1,1]],[2,1,[1,2]]]],
[4,9,[2,2],[[1,1,[1,1]],[1,2,[1,2]],[2,1,[1,2]],[2,2,[1,1]]]],
[4,10,[2,2],[[1,1,[1,1]],[1,2,[1,2]],[2,1,[1,2]],[2,2,[1,2]]]],
[4,11,[2,2],[[1,1,[1,1]],[1,2,[1,2]],[2,1,[1,2]],[2,2,[1,1,1,2]]]],
[5,1,[5],[]],[5,2,[5],[[1,1,[1,1]]]],
[6,1,[6],[]],[6,2,[6],[[1,1,[4,1]]]],[6,3,[6],[[1,1,[3,1]]]],
[6,4,[6],[[1,1,[1,1]]]],
[7,1,[7],[]],[7,2,[7],[[1,1,[1,1]]]],
[8,1,[8],[]],[8,2,[8],[[1,1,[2,1]]]],[8,3,[8],[[1,1,[1,1]]]],
[8,4,[8],[[1,1,[4,1]]]],[8,5,[4,2],[]],[8,6,[4,2],[[2,2,[2,1]]]],
[8,7,[4,2],[[2,2,[1,2]]]],[8,8,[4,2],[[2,1,[2,1]]]],
[8,9,[4,2],[[2,1,[2,1]],[2,2,[2,1]]]],[8,10,[4,2],[[1,2,[2,1]]]],
[8,11,[4,2],[[1,2,[2,1]],[2,1,[2,1]]]],
[8,12,[4,2],[[1,2,[2,1]],[2,1,[2,1]],[2,2,[2,1]]]],[8,13,[4,2],[[1,1,[1,1]]]],
[8,14,[4,2],[[1,1,[1,1]],[1,2,[1,2]],[2,1,[1,2]],[2,2,[1,2]]]],
[8,15,[4,2],[[1,1,[1,1]],[2,1,[1,2]]]],[8,16,[4,2],[[1,1,[2,1]]]],
[8,17,[4,2],[[1,1,[2,1]],[2,2,[1,2]]]],
[8,18,[4,2],[[1,1,[2,1]],[2,1,[2,1]],[2,2,[2,1]]]],
[8,19,[4,2],[[1,1,[2,1]],[1,2,[2,1]],[2,1,[2,1]]]],
[8,20,[4,2],[[1,1,[3,1]],[1,2,[1,2]]]],
[8,21,[4,2],[[1,1,[1,1]],[1,2,[1,2]],[2,1,[1,2]]]],
[8,22,[4,2],[[1,1,[1,1]],[1,2,[1,2]],[2,1,[1,2]],[2,2,[2,1]]]],
[8,23,[4,2],[[1,1,[1,2]]]],[8,24,[4,2],[[1,1,[1,2]],[1,2,[2,1]],[2,1,[2,1]]]],
[8,25,[2,2,2],[]],[8,26,[2,2,2],[[1,1,[1,3]]]],[8,27,[2,2,2],[[1,1,[1,1]]]],
[8,28,[2,2,2],[[1,2,[1,3]]]],[8,29,[2,2,2],[[1,1,[1,1]],[1,2,[1,2]]]],
[8,30,[2,2,2],[[1,1,[1,1]],[1,2,[1,2]],[1,3,[1,3]]]],
[8,31,[2,2,2],[[1,2,[1,3]],[2,1,[1,3]]]],
[8,32,[2,2,2],[[1,1,[1,3]],[1,2,[1,3]],[2,1,[1,3]]]],
[8,33,[2,2,2],[[1,1,[1,2]],[1,2,[1,3]],[2,1,[1,3]]]],
[8,34,[2,2,2],[[1,1,[1,1]],[2,1,[1,2]]]],
[8,35,[2,2,2],[[1,1,[1,1]],[1,2,[1,2]],[2,1,[1,2]]]],
[8,36,[2,2,2],[[1,1,[1,1]],[1,3,[1,3]],[2,1,[1,2]]]],
[8,37,[2,2,2],[[1,1,[1,1,1,2]],[1,2,[1,2]],[1,3,[1,3]],[2,1,[1,2]]]],
[8,38,[2,2,2],[[1,1,[1,1]],[2,2,[1,3]]]],
[8,39,[2,2,2],[[1,1,[1,3]],[1,2,[1,3]],[2,2,[1,3]]]],
[8,40,[2,2,2],[[1,1,[1,1]],[2,2,[1,2]]]],
[8,41,[2,2,2],[[1,1,[1,1]],[1,3,[1,3]],[2,2,[1,2]]]],
[8,42,[2,2,2],[[1,1,[1,1,1,2]],[1,2,[1,1]],[2,1,[1,1]],[2,2,[1,2]]]],
[8,43,[2,2,2],[[1,1,[1,1]],[2,1,[1,2]],[3,1,[1,3]]]],
[8,44,[2,2,2],[[1,1,[1,1]],[1,2,[1,2]],[2,1,[1,2]],[3,1,[1,3]]]],
[8,45,[2,2,2],[[1,1,[1,1]],[1,2,[1,2]],[1,3,[1,3]],[2,1,[1,2]],[2,2,[1,1]],
  [2,3,[1,3]],[3,1,[1,3]],[3,2,[1,3]]]],
[8,46,[2,2,2],[[1,1,[1,1]],[1,2,[1,2]],[1,3,[1,3]],[2,1,[1,2]],[2,2,[1,1]],
  [2,3,[1,3]],[3,1,[1,3]],[3,2,[1,3]],[3,3,[1,1,1,2]]]],
[8,47,[2,2,2],[[1,1,[1,1]],[2,2,[1,2]],[3,1,[1,3]]]],
[8,48,[2,2,2],[[1,1,[1,1]],[1,2,[1,2]],[1,3,[1,3]],[2,1,[1,2]],[2,2,[1,2]],
  [2,3,[1,3]],[3,1,[1,3]],[3,2,[1,3]]]],
[8,49,[2,2,2],[[1,1,[1,1]],[1,2,[1,2]],[1,3,[1,3]],[2,1,[1,2]],[2,2,[1,2]],
  [3,1,[1,3]],[3,2,[1,3]]]],
[8,50,[2,2,2],[[1,1,[1,1]],[1,2,[1,2]],[1,3,[1,3]],[2,1,[1,2]],[2,2,[1,2]],
  [3,1,[1,3]],[3,3,[1,3]]]],
[8,51,[2,2,2],[[1,1,[1,1]],[1,2,[1,2]],[1,3,[1,3]],[2,1,[1,2]],[2,2,[1,2,1,3]],
  [2,3,[1,2]],[3,1,[1,3]],[3,2,[1,2]],[3,3,[1,3]]]],
[8,52,[2,2,2],[[1,1,[1,1]],[1,2,[1,2]],[1,3,[1,3]],[2,1,[1,2]],[2,2,[1,1,1,3]],
  [2,3,[1,2,1,3]],[3,1,[1,3]],[3,2,[1,2,1,3]],[3,3,[1,1,1,2,1,3]]]],
[9,1,[9],[]],[9,2,[9],[[1,1,[1,1]]]],[9,3,[9],[[1,1,[3,1]]]],[9,4,[3,3],[]],
[9,5,[3,3],[[1,1,[1,2]]]],[9,6,[3,3],[[1,1,[1,1]]]],
[9,7,[3,3],[[1,1,[2,1]],[1,2,[2,2]]]],[9,8,[3,3],[[1,1,[1,1]],[2,1,[1,2]]]],
[9,9,[3,3],[[1,1,[1,1]],[1,2,[1,2]],[2,1,[1,2]],[2,2,[2,1,2,2]]]],
[9,10,[3,3],[[1,1,[1,1]],[1,2,[1,2]],[2,1,[1,2]],[2,2,[1,2]]]],
[9,11,[3,3],[[1,1,[1,1]],[1,2,[1,2]],[2,1,[1,2]],[2,2,[2,1]]]],
[10,1,[10],[]],[10,2,[10],[[1,1,[4,1]]]],[10,3,[10],[[1,1,[1,1]]]],
[10,4,[10],[[1,1,[5,1]]]],
[11,1,[11],[]],[11,2,[11],[[1,1,[1,1]]]],
[12,1,[12],[]],[12,2,[12],[[1,1,[2,1]]]],[12,3,[12],[[1,1,[9,1]]]],
[12,4,[12],[[1,1,[4,1]]]],[12,5,[12],[[1,1,[1,1]]]],
[12,6,[12],[[1,1,[6,1]]]],[12,7,[6,2],[]],[12,8,[6,2],[[1,1,[1,2]]]],
[12,9,[6,2],[[1,1,[3,1]]]],[12,10,[6,2],[[1,1,[3,1]],[1,2,[1,2]]]],
[12,11,[6,2],[[1,1,[3,1]],[2,1,[1,2]]]],
[12,12,[6,2],[[1,1,[3,1]],[1,2,[1,2]],[2,1,[1,2]]]],
[12,13,[6,2],[[1,1,[2,1]],[2,2,[1,2]]]],
[12,14,[6,2],[[1,1,[1,1]],[1,2,[1,2]],[2,1,[1,2]],[2,2,[1,2]]]],
[12,15,[6,2],[[1,1,[2,1]],[1,2,[3,1]],[2,2,[1,2]]]],[12,16,[6,2],[[1,1,[4,1]]]],
[12,17,[6,2],[[1,1,[4,1,1,2]]]],[12,18,[6,2],[[1,1,[1,1]],[1,2,[1,2]]]],
[12,19,[6,2],[[1,1,[1,1]],[1,2,[1,2]],[2,1,[1,2]]]],
[12,20,[6,2],[[1,1,[3,1]],[2,2,[1,2]]]],
[12,21,[6,2],[[1,1,[3,1,1,2]],[1,2,[3,1]],[2,1,[3,1]],[2,2,[1,2]]]],
[12,22,[6,2],[[1,1,[1,1]],[1,2,[1,2]],[2,1,[1,2]],[2,2,[3,1,1,2]]]],
[13,1,[13],[]],[13,2,[13],[[1,1,[1,1]]]],
[14,1,[14],[]],[14,2,[14],[[1,1,[4,1]]]],
[14,3,[14],[[1,1,[1,1]]]],[14,4,[14],[[1,1,[7,1]]]],
[15,1,[15],[]],[15,2,[15],[[1,1,[1,1]]]],[15,3,[15],[[1,1,[9,1]]]],
[15,4,[15],[[1,1,[10,1]]]]]
));

InstallGlobalFunction(NumberSmallRings,function(x)
  if IsPosInt(x) then
    if IsBound(NUMBER_SMALL_RINGS[x]) then
      return NUMBER_SMALL_RINGS[x];
    else
      Error("the library of rings of size ", x, " is not available");
    fi;
  else
    Error("NumberSmallRings: the argument should be a positive integer");
  fi;
end);

InstallGlobalFunction(SmallRing,function(x,n)
  local r, s, t, i;
  if not (IsPosInt(x) and IsBound(NUMBER_SMALL_RINGS[x])
    and IsPosInt(n) and n<=NUMBER_SMALL_RINGS[x]) then
    r:=Filtered([1..Length(NUMBER_SMALL_RINGS)],i->NUMBER_SMALL_RINGS[i]>0);
    IsRange(r);
    Error("Size must be in ",r," and number in [1..",
          NUMBER_SMALL_RINGS[x],"]\n");
  else
    s:=First(SMALL_RINGS_DATA,i->i[1]=x and i[2]=n);
    r:=s[3];
    t:=EmptySCTable(Length(r),0);
    for i in s[4] do
      SetEntrySCTable(t,i[1],i[2],i[3]);
    od;
    if Length(r)>26 then
      s:="R";
    else
      s:=List([1..Length(r)],i->[CHARS_LALPHA[i]]);
    fi;
    r:=RingByStructureConstants(r,t,s);
    return r;
  fi;
end);

# matrices
InstallOtherMethod( InverseOp, "for sc ring matrices",
    [ IsListDefault and IsSCRingObjCollColl ],
    function( mat )
    if NestingDepthM( mat ) mod 2 = 0 and IsSmallList( mat ) then
        if IsRectangularTable( mat ) then
            return INV_MATRIX_MUTABLE( mat );
        else
            return fail;
        fi;
    else
      TryNextMethod();
    fi;
    end );
