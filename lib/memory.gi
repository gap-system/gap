#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Max Neunhöffer, Ákos Seress.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Group objects remembering how they were created from the generators.
##
#############################################################################


# low-level construction of an object with memory
BindGlobal( "ObjWithMemory", function( slp, n, el )
  local filt;

  filt:= IsObjWithMemory;

  # For permutations, the `IsPerm` filter for the new element
  # is inherited from their family.
  # This is not the case for matrices, thus we have to work.
  if IsMatrixOrMatrixObj( el ) then
    filt:= filt and IsMatrixOrMatrixObj;
    if IsMatrix( el ) then
      filt:= filt and IsMatrix;
    fi;
    if IsMatrixObj( el ) then
      filt:= filt and IsMatrixObj;
    fi;
    if HasBaseDomain( el ) then
      filt:= filt and HasBaseDomain;
    fi;
  fi;

  return Objectify( NewType( FamilyObj( el ), filt ),
                    rec( slp:= slp, n:= n, el:= el ) );
end );

InstallGlobalFunction( GeneratorsWithMemory, function(l)
    # l is a list of objects
    local slp;
    slp := rec(prog := [],nogens := Length(l));
    return List( [ 1 .. Length( l ) ], i -> ObjWithMemory( slp, i, l[i] ) );
  end);

InstallGlobalFunction( MethodsForObjWithMemory, function()
  local flags, methods, op, n;

  flags:= FLAGS_FILTER( IsObjWithMemory );
  methods:= [];
  for op in OPERATIONS do
    for n in [ 1 .. 6 ] do
      Append( methods,
          Filtered( MethodsOperation( op, n ),
              r -> r.early = false and
                   ForAny( r.argFilt, fl -> IS_SUBSET_FLAGS( fl, flags ) ) ) );
    od;
  od;
  return methods;
end );

InstallMethod( StripMemory,
  [ "IsObjWithMemory" ],
  el -> el!.el );

InstallMethod( StripMemory,
  [ "IsList" ],
  l -> List( l, StripMemory ) );

InstallMethod( StripMemory,
  "fallback for all objects",
  [ "IsObject" ],
  IdFunc );

InstallMethod( ForgetMemory,
  "nice error message for all objects",
  [ "IsObject" ],
  function( ob )
    Error( "This object does not allow forgetting memory." );
  end );

InstallMethod( ForgetMemory,
  "nice error message for memory objects",
  [ "IsObjWithMemory" ],
  function( el )
    Error( "You probably mean \"StripMemory\" instead of \"ForgetMemory\"." );
  end );

InstallMethod( ForgetMemory, "for a mutable list",
  [ IsList and IsMutable ],
  function( l )
    local i;
    for i in [1..Length(l)] do
        if IsBound(l[i]) and IsObjWithMemory(l[i]) then
            l[i] := l[i]!.el;
        fi;
    od;
  end );

InstallGlobalFunction( StripStabChain,
  function(S)
    # Throws away all memories of elements in the stabchain
    # Does *not* copy stabchain!
    ForgetMemory( S.labels );
    ForgetMemory( S.generators );
    if IsBound(S.transversal) then
      ForgetMemory( S.transversal );
    fi;
    if IsObjWithMemory(S.identity) then
        S.identity := S.identity!.el;
    fi;
    if IsBound(S.stabilizer) then
        StripStabChain(S.stabilizer);
    fi;
  end);

InstallGlobalFunction( CopyMemory,
  function(gwm,h)
    # h must be a homomorphic image of gwm, the memory of gwm is copied to
    # h. Returns a new object with memory instead of h.
    return ObjWithMemory( gwm!.slp, gwm!.n, h );
  end);

InstallGlobalFunction( GroupWithMemory,
  function(gens)
    # gens a list of generators or a group
    local g,memgens;
    if not IsGroup(gens) then
        # trick: ensure all transformations that GroupWithGenerators applies
        # to the generators are applied here, too
        gens := GroupWithGenerators(gens);
    fi;
    memgens := GeneratorsWithMemory(GeneratorsOfGroup(gens));
    g := GroupWithGenerators(memgens);
    return g;
  end);

InstallGlobalFunction( SLPOfElm,
  function(elm)
    # Returns a straight line program to write elm as in the original
    # generators.
    if elm!.n = 0 then
        return StraightLineProgramNC( [[1,0]], elm!.slp.nogens );
    else
        return IntermediateResultOfSLPWithoutOverwrite (
                 [elm!.slp.prog,elm!.slp.nogens],elm!.n);
    fi;
  end);

InstallGlobalFunction( SLPOfElms,
  function(elms)
    # Returns a straight line program to write elms as in the original
    # generators.
    if ForAny(elms{[2..Length(elms)]}, x -> not IsIdenticalObj(elms[1]!.slp, x!.slp)) then
        ErrorNoReturn("SLPOfElms: the slp components of all elements must be identical");
    fi;
    return IntermediateResultsOfSLPWithoutOverwrite(
               [elms[1]!.slp.prog,elms[1]!.slp.nogens], List(elms,x->x!.n) );
  end);

# Generic methods for group elements with memory:

InstallMethod( One,
  "partial method for a group (beats to ask family)",
  # the method for `IsMagmaWithOne` has incremental rank 100
  [ "IsMagmaWithOne and IsGroup" ], 101,
  function( M )
    local gens;
    gens := GeneratorsOfGroup(M);
    if Length(gens) > 0 and IsObjWithMemory(gens[1]) then
      return One(gens[1]);
    else
      TryNextMethod();
    fi;
  end );

InstallMethod( ViewObj,
  [ "IsObjWithMemory" ],
  function(o)
    Print("<");
    ViewObj(o!.el);
    Print(" with mem>");
  end);

InstallMethod( PrintObj,
  [ "IsObjWithMemory" ],
  function(o)
    Print("<");
    PrintObj(o!.el);
    Print(" with mem>");
  end);

InstallMethod( \*,
  [ "IsObjWithMemory", "IsObjWithMemory" ],
  function(a,b)
    local slp;
    slp := a!.slp;
    if not IsIdenticalObj( slp, b!.slp ) then
        ErrorNoReturn("\\* for objects with memory: a!.slp and b!.slp must be identical");
    fi;
    if a!.n = 0 then   # the identity!
      return b;
    elif b!.n = 0 then   # the identity!
      return a;
    else
      Add( slp.prog, [ a!.n, 1, b!.n, 1 ] );
      return ObjWithMemory( slp, Length( slp.prog ) + slp.nogens,
                            a!.el * b!.el );
    fi;
  end);

InstallMethod( One,
  [ "IsObjWithMemory" ],
  OneOp);

InstallMethod( OneOp,
  [ "IsObjWithMemory" ],
  a -> ObjWithMemory( a!.slp, 0, One( a!.el ) ) );

InstallMethod( InverseOp,
  [ "IsObjWithMemory" ],
  function(a)
    local slp;
    slp := a!.slp;
    if a!.n <> 0 then
      Add( slp.prog, [ a!.n, -1 ] );
      return ObjWithMemory( slp, Length( slp.prog ) + slp.nogens,
                            InverseOp( a!.el ) );
    else
      return a;
    fi;
  end);

InstallMethod( \^,
  [ "IsObjWithMemory", "IsInt" ],
  function(a,b)
    local slp;
    slp := a!.slp;
    if a!.n = 0 or b = 0 then
      return ObjWithMemory( slp, 0, a!.el^0 );
    elif b = 1 then
      return a;
    else
      Add( slp.prog, [ a!.n, b ] );
      return ObjWithMemory( slp, Length( slp.prog ) + slp.nogens, a!.el^b );
    fi;
  end);

InstallMethod( \=, IsIdenticalObj,
  [ "IsObjWithMemory", "IsObjWithMemory" ],
  { a, b } -> a!.el = b!.el );

InstallMethod( \=, IsIdenticalObj,
  [ "IsObjWithMemory", "IsMultiplicativeElement" ],
  { a, x } -> a!.el = x );

InstallMethod( \=, IsIdenticalObj,
  [ "IsMultiplicativeElement", "IsObjWithMemory" ],
  { x, a } -> x = a!.el );

# If the underlying elements are different then consider only their
# < relation.
# If the underlying elements are equal then consider also the positions
# in the straight line program.
InstallGlobalFunction( SortFunctionWithMemory,
  function(a,b)
    if a!.el < b!.el then
        return true;
    elif a!.el = b!.el then
        return a!.n < b!.n;
    else
        return false;
    fi;
  end);

InstallMethod( \<, IsIdenticalObj,
  [ "IsObjWithMemory", "IsObjWithMemory" ],
  { a, b } -> a!.el < b!.el );

InstallMethod( \<, IsIdenticalObj,
  [ "IsObjWithMemory", "IsMultiplicativeElement" ],
  { a, x } -> a!.el < x );

InstallMethod( \<, IsIdenticalObj,
  [ "IsMultiplicativeElement", "IsObjWithMemory" ],
  { x, a } -> x < a!.el );

InstallMethod( Order,
  [ "IsObjWithMemory" ],
  a -> Order( a!.el ) );

InstallMethod( IsOne,
  [ "IsObjWithMemory" ],
  a -> IsOne( a!.el ) );

# permutation methods

InstallMethod( LargestMovedPoint,
  [ "IsObjWithMemory and IsPerm" ],
  a -> LargestMovedPoint( a!.el ) );

InstallMethod( \^,
  [ "IsInt", "IsObjWithMemory and IsPerm" ],
  { a, b } -> a^b!.el );

InstallMethod( \/,
  [ "IsInt", "IsObjWithMemory and IsPerm" ],
  { a, b } -> a / b!.el );

InstallOtherMethod( CycleOp,
  [ "IsPerm and IsObjWithMemory", "IsInt" ],
  { p, i } -> CycleOp( p!.el, i ) );

InstallOtherMethod( CycleLengthOp,
  [ "IsPerm and IsObjWithMemory", "IsInt" ],
  { p, i } -> CycleLengthOp( p!.el, i ) );

InstallMethod( CycleStructurePerm,
  [ "IsPerm and IsObjWithMemory" ],
  p -> CycleStructurePerm( p!.el ) );

InstallMethod( RestrictedPerm,
  [ "IsPerm and IsObjWithMemory", "IsList" ],
  { a, l } -> ObjWithMemory( a!.slp, a!.n, RestrictedPerm( a!.el, l ) ) );

InstallMethod( SignPerm,
  [ "IsPerm and IsObjWithMemory" ],
  a -> SignPerm( a!.el ) );

# MatrixObj methods:

InstallMethod( BaseDomain,
  [ "IsMatrixOrMatrixObj and IsObjWithMemory" ],
  M -> BaseDomain( M!.el ) );

InstallMethod( NumberRows,
  [ "IsMatrixOrMatrixObj and IsObjWithMemory" ],
  M -> NumberRows( M!.el ) );

InstallMethod( NumberColumns,
  [ "IsMatrixOrMatrixObj and IsObjWithMemory" ],
  M -> NumberColumns( M!.el ) );

InstallMethod( MatElm,
  [ "IsMatrixOrMatrixObj and IsObjWithMemory", "IsPosInt", "IsPosInt" ],
  { M, i, j } -> M!.el[i,j] );

# legacy matrix methods

InstallOtherMethod( Length,
  [ "IsMatrix and IsObjWithMemory" ],
  M -> Length( M!.el ) ) ;

InstallOtherMethod( ELM_LIST,
  [ "IsMatrix and IsObjWithMemory", "IsPosInt" ],
  { M, i } -> M!.el[i] );

InstallOtherMethod( \*,
  [ "IsListDefault and IsSmallList", "IsMatrix and IsObjWithMemory" ],
  { v, M } -> v * M!.el );

InstallOtherMethod( \*,
  [ "IsScalar", "IsMatrixOrMatrixObj and IsObjWithMemory" ],
  { s, M } -> s * M!.el );

InstallOtherMethod( \*,
  [ "IsMatrixOrMatrixObj and IsObjWithMemory", "IsScalar" ],
  { M , s } -> M!.el * s );

InstallOtherMethod( ProjectiveOrder,
  [ "IsObjWithMemory" ],
  a -> ProjectiveOrder( a!.el ) );

InstallOtherMethod( ImmutableMatrix,
  [ "IsField", "IsMatrixOrMatrixObj and IsObjWithMemory" ],
  { f, a } -> ObjWithMemory( a!.slp, a!.n, ImmutableMatrix( f, a!.el ) ) );

# free group element methods

InstallOtherMethod( Length,
  [ "IsObjWithMemory and IsWord" ],
  a -> Length( a!.el ) );

