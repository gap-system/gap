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

BindGlobal( "ObjWithMemory", function( slp, n, el )
  local filt;

  filt:= IsObjWithMemory;
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

InstallGlobalFunction( GeneratorsWithMemory,
  function(l)
    # l is a list of objects
    local slp;
    slp := rec(prog := [],nogens := Length(l));
    return List( [ 1 .. Length( l ) ], i -> ObjWithMemory( slp, i, l[i] ) );
  end);

InstallMethod( StripMemory, "for an object with memory",
  [ IsObjWithMemory ],
  function( el )
    return el!.el;
  end );

InstallMethod( StripMemory, "for a list",
  [ IsList ],
  function( l )
    return List(l,StripMemory);
  end );

InstallMethod( StripMemory, "fallback for all objects",
  [ IsObject ],
  function( ob ) return ob; end );

InstallMethod( ForgetMemory, "nice error message for all objects",
  [ IsObject ],
  function( ob )
    Error( "This object does not allow forgetting memory." );
  end );

InstallMethod( ForgetMemory, "nice error message for memory objects",
  [ IsObjWithMemory ],
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
    local i,identity;
    for i in [1..Length(S.labels)] do
        if IsObjWithMemory(S.labels[i]) then
            S.labels[i] := S.labels[i]!.el;
        fi;
    od;
    for i in [1..Length(S.generators)] do
        if IsObjWithMemory(S.generators[i]) then
            S.generators[i] := S.generators[i]!.el;
        fi;
    od;
    if IsBound(S.transversal) then
        for i in [1..Length(S.transversal)] do
            if IsBound(S.transversal[i]) and
               IsObjWithMemory(S.transversal[i]) then
                S.transversal[i] := S.transversal[i]!.el;
            fi;
        od;
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
    # Returns a straight line program to write elm as in the original
    # generators.
    if ForAny(elms{[2..Length(elms)]}, x -> not IsIdenticalObj(elms[1]!.slp, x!.slp)) then
        ErrorNoReturn("SLPOfElms: the slp components of all elements must be identical");
    fi;
    return IntermediateResultsOfSLPWithoutOverwrite(
               [elms[1]!.slp.prog,elms[1]!.slp.nogens], List(elms,x->x!.n) );
  end);

# Generic methods for group elements with memory:

InstallOtherMethod( One, "partial method for a group (beats to ask family)",
  true, [ IsMagmaWithOne and IsGroup ], 101,
  function( M )
    local gens;
    gens := GeneratorsOfGroup(M);
    if Length(gens) > 0 and IsObjWithMemory(gens[1]) then
      return One(gens[1]);
    else
      TryNextMethod();
    fi;
  end );

InstallMethod( ViewObj, "objects with memory", true, [IsObjWithMemory],0,
  function(o)
    Print("<");
    ViewObj(o!.el);
    Print(" with mem>");
end);

InstallMethod( PrintObj, "objects with memory", true, [IsObjWithMemory],0,
  function(o)
    Print("<");
    PrintObj(o!.el);
    Print(" with mem>");
end);

InstallMethod( \*, "objects with memory", true,
  [IsObjWithMemory,IsObjWithMemory],0,
  function(a,b)
    local slp;
    slp := a!.slp;
    if not IsIdenticalObj( slp, b!.slp ) then
        ErrorNoReturn("\\* for objects with memory: a!.slp and b!.slp must be identical");
    fi;
    if a!.n = 0 then   # the identity!
      return ObjWithMemory( slp, b!.n, b!.el );
    elif b!.n = 0 then   # the identity!
      return ObjWithMemory( slp, a!.n, a!.el );
    else
      Add( slp.prog, [ a!.n, 1, b!.n, 1 ] );
      return ObjWithMemory( slp, Length( slp.prog ) + slp.nogens,
                            a!.el * b!.el );
    fi;
  end);

InstallMethod( One, "objects with memory", true,
  [IsObjWithMemory],0, OneOp);

InstallMethod( OneOp, "objects with memory", true,
  [IsObjWithMemory],0,
  a -> ObjWithMemory( a!.slp, 0, One( a!.el ) ) );

InstallMethod( InverseOp, "objects with memory", true,
  [IsObjWithMemory],0,
  function(a)
    local slp;
    slp := a!.slp;
    if a!.n <> 0 then
      Add( slp.prog, [ a!.n, -1 ] );
      return ObjWithMemory( slp, Length( slp.prog ) + slp.nogens,
                            InverseOp( a!.el ) );
    else
      return ObjWithMemory( slp, 0, a!.el );
    fi;
  end);

InstallMethod( \^, "objects with memory", true,
  [IsObjWithMemory,IsInt],0,
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

InstallMethod(\=,"two objects with memory",IsIdenticalObj,
  [IsObjWithMemory,IsObjWithMemory],0,
  function(a,b)
    return a!.el = b!.el;
  end);

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

InstallMethod(\<,"two objects with memory",IsIdenticalObj,
  [IsObjWithMemory,IsObjWithMemory],0,
  function(a,b)
    return a!.el < b!.el;
  end);

InstallMethod(\=,"objects with memory with x",IsIdenticalObj,
  [IsObjWithMemory,IsMultiplicativeElement],0,
  function(a,x)
    return a!.el=x;
  end);

InstallMethod(\=,"x with objects with memory",IsIdenticalObj,
  [IsMultiplicativeElement,IsObjWithMemory],0,
  function(x,a)
    return x=a!.el;
  end);

InstallMethod(\<,"objects with memory with x",IsIdenticalObj,
  [IsObjWithMemory,IsMultiplicativeElement],0,
  function(a,x)
    return a!.el<x;
  end);

InstallMethod(\<,"x with objects with memory",IsIdenticalObj,
  [IsObjWithMemory,IsMultiplicativeElement],0,
  function(a,x)
    return x<a!.el;
  end);

InstallMethod(Order,"object with memory",true, [IsObjWithMemory],0,
  function(a)
    return Order(a!.el);
  end);

InstallMethod(IsOne,"object with memory",true, [IsObjWithMemory],0,
  function(a)
    return IsOne(a!.el);
  end);

# Permutation methods for permutations with memory:

InstallMethod(LargestMovedPoint,"permutation with memory",true,
  [IsObjWithMemory and IsPerm],0,
  function(a)
    return LargestMovedPoint(a!.el);
  end);

InstallMethod(\^,"integer and permutation with memory", true,
  [IsInt, IsObjWithMemory and IsPerm],0,
  function(a,b)
    return a^b!.el;
  end);

InstallMethod(\/,"integer and permutation with memory", true,
  [IsInt, IsObjWithMemory and IsPerm],0,
  function(a,b)
    return a / b!.el;
  end);

InstallOtherMethod(CycleLengthOp,
  "for a permutation with memory and an integer",true,
  [ IsPerm and IsObjWithMemory, IsInt ], 0,
  function(p,e)
    return CycleLengthOp(p!.el,e);
  end);

InstallMethod(RestrictedPerm,
  "for a permutation with memory and a list of integers",true,
  [ IsPerm and IsObjWithMemory, IsList ], 0,
  function(a,l)
    return ObjWithMemory( a!.slp, a!.n, RestrictedPerm( a!.el, l ) );
  end);

InstallMethod(SignPerm,
  "for a permutation with memory",true,
  [ IsPerm and IsObjWithMemory ], 0,
  function(a)
  return SignPerm(a!.el);
end);

InstallOtherMethod(CycleOp,
  "for a permutation with memory and an integer",true,
  [ IsPerm and IsObjWithMemory, IsInt ], 0,
  function(a,p)
    return CycleOp(a!.el,p);
  end);

InstallOtherMethod(CycleStructurePerm,
  "for a permutation with memory",true,
  [ IsPerm and IsObjWithMemory ], 0,
  p->CycleStructurePerm(p!.el));

# MatrixObj methods:

InstallOtherMethod( BaseDomain, "for a matrix with memory",
  [ IsMatrixOrMatrixObj and IsObjWithMemory ],
  M -> BaseDomain(M!.el) );

InstallOtherMethod( NumberRows, "for a matrix with memory",
  [ IsMatrixOrMatrixObj and IsObjWithMemory ],
  M -> NumberRows(M!.el) );

InstallOtherMethod( NumberColumns, "for a matrix with memory",
  [ IsMatrixOrMatrixObj and IsObjWithMemory ],
  M -> NumberColumns(M!.el) );

InstallOtherMethod( MatElm, "for a matrix with memory",
  [ IsMatrixOrMatrixObj and IsObjWithMemory, IsPosInt, IsPosInt ],
  { M, i, j } -> M!.el[i,j] );

# legacy matrix methods

InstallOtherMethod( Length, "for a matrix with memory",
  [ IsMatrix and IsObjWithMemory ], M -> Length(M!.el) ) ;

InstallOtherMethod( ELM_LIST, "for a matrix with memory",
  [ IsMatrix and IsObjWithMemory, IsPosInt ],
  function(M,i)
    return M!.el[i];
  end);

InstallOtherMethod( \*, "for a row vector and a matrix with memory",
  [ IsListDefault and IsSmallList, IsMatrix and IsObjWithMemory ], 0,
  function(v,M)
    return v * M!.el;
  end);

InstallOtherMethod( \*, "for a scalar and a matrix with memory",
  [ IsScalar, IsMatrixOrMatrixObj and IsObjWithMemory ], 0,
  { s, M } ->  s * M!.el );

InstallOtherMethod( \*, "for a matrix with memory and a scalar",
  [ IsMatrixOrMatrixObj and IsObjWithMemory, IsScalar ], 0,
  { M , s} ->  M!.el * s );

InstallOtherMethod(ProjectiveOrder,"object with memory",
  [IsObjWithMemory],0,
  function(a)
    return ProjectiveOrder(a!.el);
  end);

InstallOtherMethod( ImmutableMatrix,"object with memory",[IsField,IsMatrixOrMatrixObj and IsObjWithMemory],
function(f,a)
    return ObjWithMemory( a!.slp, a!.n, ImmutableMatrix( f, a!.el ) );
end);

# Free group methods:

InstallOtherMethod( Length, "for a word with memory",
  [ IsObjWithMemory and IsWord ], a -> Length(a!.el) );

