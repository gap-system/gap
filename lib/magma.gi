#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains generic methods for magmas.
##


#############################################################################
##
#M  PrintObj( <M> ) . . . . . . . . . . . . . . . . . . . . . . print a magma
##
InstallMethod( PrintString,
    "for a magma",
    true,
    [ IsMagma ], 0,
    function( M )
    return "Magma( ... )";
    end );

InstallMethod( PrintString,
    "for a magma with generators",
    true,
    [ IsMagma and HasGeneratorsOfMagma ], 0,
    function( M )
    return STRINGIFY( "Magma( ", GeneratorsOfMagma( M ), " )" );
    end );

InstallMethod( PrintString,
    "for a magma-with-one with generators",
    true,
    [ IsMagmaWithOne and HasGeneratorsOfMagmaWithOne ], 0,
    function( M )
    if IsEmpty( GeneratorsOfMagmaWithOne( M ) ) then
      return STRINGIFY("MagmaWithOne( ", One( M ), " )" );
    else
      return STRINGIFY( "MagmaWithOne( ", GeneratorsOfMagmaWithOne( M ), " )" );
    fi;
    end );

InstallMethod( PrintString,
    "for a magma-with-inverses with generators",
    true,
    [ IsMagmaWithInverses and HasGeneratorsOfMagmaWithInverses ], 0,
    function( M )
    if IsEmpty( GeneratorsOfMagmaWithInverses( M ) ) then
      return STRINGIFY("MagmaWithInverses( ", One( M ), " )" );
    else
      return STRINGIFY("MagmaWithInverses( ", GeneratorsOfMagmaWithInverses(M), " )" );
    fi;
    end );


#############################################################################
##
#M  ViewObj( <M> )  . . . . . . . . . . . . . . . . . . . . . .  view a magma
##
InstallMethod( ViewString,
    "for a magma",
    true,
    [ IsMagma ], 0,
    function( M )
    return "<magma>";
    end );

InstallMethod( ViewString,
    "for a magma with generators",
    true,
    [ IsMagma and HasGeneratorsOfMagma ], 0,
    function( M )
    local nrgens;
    nrgens := Length( GeneratorsOfMagma(M) );
    return STRINGIFY( "<magma with ", Pluralize( nrgens, "generator" ), ">" );
    end );

InstallMethod( ViewString,
    "for a magma-with-one with generators",
    true,
    [ IsMagmaWithOne and HasGeneratorsOfMagmaWithOne ], 0,
    function( M )
    local nrgens;
    nrgens := Length( GeneratorsOfMagmaWithOne(M) );
    if nrgens = 0 then
      return "<trivial magma-with-one>" ;
    fi;
    return STRINGIFY( "<magma-with-one with ",
                      Pluralize( nrgens, "generator" ), ">" );
    end );

InstallMethod( ViewString,
    "for a magma-with-inverses with generators",
    true,
    [ IsMagmaWithInverses and HasGeneratorsOfMagmaWithInverses ], 0,
    function( M )
    local nrgens;
    nrgens := Length( GeneratorsOfMagmaWithInverses( M ) );
    if nrgens = 0 then
      return "<trivial magma-with-inverses>";
    fi;
    return STRINGIFY( "<magma-with-inverses with ",
                      Pluralize( nrgens, "generator" ), ">" );
    end );


#############################################################################
##
#M  IsTrivial( <M> )  . . . . . . . . . . . . test whether a magma is trivial
##
InstallImmediateMethod( IsTrivial,
    IsMagmaWithOne and HasGeneratorsOfMagmaWithOne, 0,
    function( M )
    if IsEmpty( GeneratorsOfMagmaWithOne( M ) ) then
      return true;
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( IsTrivial,
    [IsMagmaWithInverses and HasGeneratorsOfMagmaWithInverses], 0,
    function( M )
    if IsEmpty( GeneratorsOfMagmaWithInverses( M ) ) then
      return true;
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  IsAssociative( <M> )  . . . . .  test whether a collection is associative
##
InstallMethod( IsAssociative,
    "for a collection",
    [ IsCollection ],
    function( M )

    local elms,      # list of elements
          i, j, k;   # loop variables

    # Test associativity for all triples of elements.
    elms:= Enumerator( M );
    for i in elms do
      for j in elms do
        for k in elms do
          if ( i * j ) * k <> i * ( j * k ) then
            return false;
          fi;
        od;
      od;
    od;

    # No associativity test failed.
    return true;
    end );


#############################################################################
##
#M  IsCommutative( <M> )  . . . . .  test whether a collection is commutative
##
InstallImmediateMethod( IsCommutative,
    IsMagma and IsAssociative and HasGeneratorsOfMagma, 0,
    function( M )
    if Length( GeneratorsOfMagma( M ) ) = 1 then
      return true;
    else
      TryNextMethod();
    fi;
    end );

InstallImmediateMethod( IsCommutative,
    IsMagmaWithOne and IsAssociative and HasGeneratorsOfMagmaWithOne, 0,
    function( M )
    if Length( GeneratorsOfMagmaWithOne( M ) ) = 1 then
      return true;
    else
      TryNextMethod();
    fi;
    end );

#  This used to be an immediate method. It was replaced by an ordinary
#  method, as the filter is now set when creating groups.
InstallMethod( IsCommutative,true,
    [IsMagmaWithInverses and IsAssociative
                        and HasGeneratorsOfMagmaWithInverses], 0,
    function( M )
    if Length( GeneratorsOfMagmaWithInverses( M ) ) = 1 then
      return true;
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( IsCommutative,
    "for a collection",
    [ IsCollection ],
    function( C )
      local elms, n, x, y, i, j;

      elms:= Enumerator( C );
      n := Length( elms );
      for i in [ 1 .. n ] do
        for j in [ i + 1 .. n ] do
          x := elms[ i ];
          y := elms[ j ];
          if x * y <> y * x then
            return false;
          fi;
        od;
      od;
      return true;
    end);

InstallMethod( IsCommutative,
    "for a magma",
    true,
    [ IsMagma ], 0,
    IsCommutativeFromGenerators( GeneratorsOfDomain ) );

InstallMethod( IsCommutative,
    "for an associative magma",
    true,
    [ IsMagma and IsAssociative ], 0,
    IsCommutativeFromGenerators( GeneratorsOfMagma ) );

InstallMethod( IsCommutative,
    "for an associative magma with one",
    true,
    [ IsMagmaWithOne and IsAssociative ], 0,
    IsCommutativeFromGenerators( GeneratorsOfMagmaWithOne ) );

InstallMethod( IsCommutative,
    "for an associative magma with inverses",
    true,
    [ IsMagmaWithInverses and IsAssociative ], 0,
    IsCommutativeFromGenerators( GeneratorsOfMagmaWithInverses ) );


#############################################################################
##
#P  IsFinitelyGeneratedMagma( <M> ) . . . . test whether a magma is fin. gen.
##
InstallMethod( IsFinitelyGeneratedMagma,
    [ IsMagma and HasGeneratorsOfMagma ],
    function( M )
    if IsFinite( GeneratorsOfMagma( M ) ) then
      return true;
    fi;
    TryNextMethod();
    end );

InstallMethod( IsFinitelyGeneratedMagma,
    [ IsMagmaWithOne and HasGeneratorsOfMagmaWithOne ],
    function( M )
    if IsFinite( GeneratorsOfMagmaWithOne( M ) ) then
      return true;
    fi;
    TryNextMethod();
    end );

InstallMethod( IsFinitelyGeneratedMagma,
    [ IsMagmaWithInverses and HasGeneratorsOfMagmaWithInverses ],
    function( M )
    if IsFinite( GeneratorsOfMagmaWithInverses( M ) ) then
      return true;
    fi;
    TryNextMethod();
    end );


#############################################################################
##
#M  Centralizer( <M>, <elm> ) . . . . .  centralizer of an element in a magma
#M  Centralizer( <M>, <N> ) . . . . . . . . centralizer of a magma in a magma
##
InstallMethod( CentralizerOp,
    "for a magma, and a mult. element",
    IsCollsElms,
    [ IsMagma, IsMultiplicativeElement ], 0,
    function( M, obj )
    return Filtered( AsList( M ), x -> x * obj = obj * x );
    end );

InstallMethod( CentralizerOp,
    "for a commutative magma, and a mult. element",
    IsCollsElms,
    [ IsMagma and IsCommutative, IsMultiplicativeElement ],
    SUM_FLAGS, # for commutative magmas this is best possible
  function( M, obj )
    if obj in M then
      return M;
    else
      TryNextMethod();
    fi;
  end );

InstallMethod( CentralizerOp,
    "for two magmas",
    IsIdenticalObj,
    [ IsMagma, IsMagma ], 0,
    function( M, N )
    return Filtered( M, x -> ForAll( N, y -> x * y = y * x ) );
    end );

InstallMethod( CentralizerOp,
    "for two magmas, the first being commutative",
    IsIdenticalObj,
    [ IsMagma and IsCommutative, IsMagma ],
    SUM_FLAGS, # for commutative magmas this is best possible
  function( M, N )
    if IsSubset( M, N ) then
      return M;
    else
      TryNextMethod();
    fi;
  end );

InstallOtherMethod( CentralizerOp,
    "dummy to ignore optional third argument",
    true,
    [ IsMagma, IsObject,IsObject ], 0,
    function( M, obj, x )
    return CentralizerOp( M, obj );
    end );


#############################################################################
##
#M  Centre( <M> ) . . . . . . . . . . . . . . . . . . . . . centre of a magma
##
InstallMethod( Centre,
    "generic method for a magma",
    [ IsMagma ],
    function( M )
    local T;
    T:= Tuples( M, 2 );
    M:= Filtered( M, x -> ForAll( M, y -> x * y = y * x ) and
                          ForAll( T, p -> (p[1]*p[2])*x = p[1]*(p[2]*x) and
                                          (p[1]*x)*p[2] = p[1]*(x*p[2]) and
                                          (x*p[1])*p[2] = x*(p[1]*p[2]) ) );
    if IsDomain( M ) then
      Assert( 1, IsAbelian( M ) );
      SetIsAbelian( M, true );
    fi;
    return M;
    end );

InstallMethod( Centre,
    "for an associative magma",
    [ IsMagma and IsAssociative ],
    function( M )
    M:= Centralizer( M, M );
    if IsDomain( M ) then
      Assert( 1, IsAbelian( M ) );
      SetIsAbelian( M, true );
    fi;
    return M;
    end );

InstallMethod( Centre,
    "for an associative and commutative magma",
    [ IsMagma and IsAssociative and IsCommutative ],
    SUM_FLAGS, # for commutative magmas this is best possible
    IdFunc );


#############################################################################
##
#A  Idempotents( <M> ) . .  . . . . . . . . . . . . . . idempotents of a magma
##
InstallMethod(Idempotents,"for finite magmas", true,
               [IsMagma], 0,
     function(M)
     local I, m;
     I := [];

     for m in AsList(M) do
         if m*m=m then
             Add(I,m);
         fi;
     od;
     return I;
end);

#############################################################################
##
#F  Magma( <gens> )
#F  Magma( <Fam>, <gens> )
##
InstallGlobalFunction( Magma, function( arg )

    # list of generators
    if Length( arg ) = 1 and IsList( arg[1] ) and 0 < Length( arg[1] ) then
      return MagmaByGenerators( arg[1] );

    # family plus list of generators
    elif Length( arg ) = 2 and IsFamily( arg[1] ) and IsList( arg[2] ) then
      return MagmaByGenerators( arg[1], arg[2] );

    # generators
    elif 0 < Length( arg ) then
      return MagmaByGenerators( arg );
    fi;

    # no argument given, error
    Error("usage: Magma(<gens>), Magma(<Fam>,<gens>)");
end );


#############################################################################
##
#F  Submagma( <M>, <gens> ) . . . . . . . submagma of <M> generated by <gens>
##
InstallGlobalFunction( Submagma, function( M, gens )

    if not IsMagma( M ) then
        Error( "<M> must be a magma" );
    elif IsEmpty( gens ) then
        return SubmagmaNC( M, gens );
    elif not IsHomogeneousList(gens)  then
        Error( "<gens> must be a homogeneous list of elements" );
    elif not IsIdenticalObj( FamilyObj(M), FamilyObj(gens) )  then
        Error( "families of <gens> and <M> are different" );
    fi;
    if not ForAll( gens, x -> x in M ) then
        Error( "<gens> must be elements in <M>" );
    fi;
    return SubmagmaNC( M, gens );
end );


#############################################################################
##
#F  SubmagmaNC( <M>, <gens> )
##
##  Note that `SubmagmaNC' is allowed to call `Objectify'
##  in the case that <gens> is empty.
##
InstallGlobalFunction( SubmagmaNC, function( M, gens )
    local K, S;

    if IsEmpty( gens ) then
      K:= NewType( FamilyObj(M),
                       IsMagma
                   and IsEmpty
                   and IsAttributeStoringRep );
      S:= Objectify( K, rec() );
      SetGeneratorsOfMagma( S, [] );
    else
      S:= MagmaByGenerators(gens);
    fi;
    SetParent( S, M );
    return S;
end );


#############################################################################
##
#F  MagmaWithOne( <gens> )
#F  MagmaWithOne( <Fam>, <gens> )
##
InstallGlobalFunction( MagmaWithOne, function( arg )

    # list of generators
    if Length( arg ) = 1 and IsList( arg[1] ) and 0 < Length( arg[1] ) then
      return MagmaWithOneByGenerators( arg[1] );

    # family plus list of generators
    elif Length( arg ) = 2 and IsFamily( arg[1] ) and IsList( arg[2] ) then
      return MagmaWithOneByGenerators( arg[1], arg[2] );

    # generators
    elif 0 < Length( arg ) then
      return MagmaWithOneByGenerators( arg );
    fi;

    # no argument given, error
    Error("usage: MagmaWithOne(<gens>), MagmaWithOne(<Fam>,<gens>)");
end );


#############################################################################
##
#F  SubmagmaWithOne( <M>, <gens> )  . submagma-with-one of <M> gen. by <gens>
##
InstallGlobalFunction( SubmagmaWithOne, function( M, gens )

    if not IsMagmaWithOne( M ) then
        Error( "<M> must be a magma-with-one" );
    elif IsEmpty( gens ) then
        return SubmagmaWithOneNC( M, gens );
    elif not IsHomogeneousList(gens)  then
        Error( "<gens> must be a homogeneous list of elements" );
    elif not IsIdenticalObj( FamilyObj(M), FamilyObj(gens) )  then
        Error( "families of <gens> and <M> are different" );
    fi;
    if not ForAll( gens, x -> x in M ) then
        Error( "<gens> must be elements in <M>" );
    fi;
    return SubmagmaWithOneNC( M, gens );
end );


#############################################################################
##
#F  SubmagmaWithOneNC( <M>, <gens> )
##
##  Note that `SubmagmaWithOneNC' is allowed to call `Objectify'
##  in the case that <gens> is empty.
##
##  Furthermore note that a trivial submagma-with-one is automatically
##  a group.
##
InstallGlobalFunction( SubmagmaWithOneNC, function( M, gens )
    local K, S;

    if IsEmpty( gens ) then
      K:= NewType( FamilyObj(M),
                       IsMagmaWithInverses
                   and IsTrivial
                   and IsAttributeStoringRep );
      S:= Objectify( K, rec() );
      SetGeneratorsOfMagmaWithInverses( S, [] );
      SetSize( S, 1 );
#T should be unnecessary since `IsTrivial' implies a good `Size' method
    else
      S:= MagmaWithOneByGenerators(gens);
    fi;
    SetParent( S, M );
    return S;
end );


#############################################################################
##
#F  MagmaWithInverses( <gens> )
#F  MagmaWithInverses( <Fam>, <gens> )
##
InstallGlobalFunction( MagmaWithInverses, function( arg )

    # list of generators
    if Length( arg ) = 1 and IsList( arg[1] ) and 0 < Length( arg[1] ) then
      return MagmaWithInversesByGenerators( arg[1] );

    # family plus list of generators
    elif Length( arg ) = 2 and IsFamily( arg[1] ) and IsList( arg[2] ) then
      return MagmaWithInversesByGenerators( arg[1], arg[2] );

    # generators
    elif 0 < Length( arg ) then
      return MagmaWithInversesByGenerators( arg );
    fi;

    # no argument given, error
    Error("usage: MagmaWithInverses(<gens>), ",
          "MagmaWithInverses(<Fam>,<gens>)");
end );


#############################################################################
##
#F  SubmagmaWithInverses( <M>, <gens> )
#F                    . . . . . . .  submagma-with-inv. of <M> gen. by <gens>
##
InstallGlobalFunction( SubmagmaWithInverses, function(arg)
local M,gens,S;
    M:=arg[1];
    if not IsMagmaWithInverses( M ) then
        Error( "<M> must be a magma-with-inverses" );
    fi;
    if Length(arg)=1 then
      S:=Objectify(NewType( FamilyObj(M),
                            IsMagmaWithInverses
                            and IsAttributeStoringRep), rec() );
      SetParent(S,M);
      return S;
    else
      gens:=arg[2];
    fi;
    if IsEmpty( gens ) then
        return SubmagmaWithInversesNC( M, gens );
    elif not IsHomogeneousList(gens)  then
        Error( "<gens> must be a homogeneous list of elements" );
    elif not IsIdenticalObj( FamilyObj(M), FamilyObj(gens) )  then
        Error( "families of <gens> and <M> are different" );
    fi;
    if not ForAll( gens, x -> x in M ) then
        Error( "<gens> must be elements in <M>" );
    fi;
    return SubmagmaWithInversesNC( M, gens );
end );


#############################################################################
##
#F  SubmagmaWithInversesNC( <M>, <gens> )
##
##  Note that `SubmagmaWithInversesNC' is allowed to call `Objectify'
##  in the case that <gens> is empty.
##
InstallGlobalFunction( SubmagmaWithInversesNC, function( M, gens )
    local K, S;

    if IsEmpty( gens ) then
      K:= NewType( FamilyObj(M),
                       IsMagmaWithInverses
                   and IsTrivial
                   and IsAttributeStoringRep
                   and HasGeneratorsOfMagmaWithInverses);
      S:=rec();
      ObjectifyWithAttributes(S, K, GeneratorsOfMagmaWithInverses, [] );
    else
      S:= MagmaWithInversesByGenerators(gens);
    fi;
    SetParent( S, M );
    return S;
end );


#############################################################################
##
#M  MagmaByGenerators( <gens> ) . . . . . . . . . . . . . .  for a collection
##
InstallMethod( MagmaByGenerators,
    "for collection",
    true,
    [ IsCollection ] , 0,
    function( gens )
    local M;
    M:= Objectify( NewType( FamilyObj( gens ),
                            IsMagma and IsAttributeStoringRep ),
                   rec() );
    SetGeneratorsOfMagma( M, AsList( gens ) );
    return M;
    end );


#############################################################################
##
#M  MagmaByGenerators( <Fam>, <gens> )  . . . . . . . . . for family and list
##
InstallOtherMethod( MagmaByGenerators,
    "for family and list",
    true,
    [ IsFamily, IsList ], 0,
    function( family, gens )
    local M;
    if not ( IsEmpty(gens) or IsIdenticalObj( FamilyObj(gens), family ) ) then
      Error( "<family> and family of <gens> do not match" );
    fi;
    M:= Objectify( NewType( family,
                            IsMagma and IsAttributeStoringRep ),
                   rec() );
    SetGeneratorsOfMagma( M, AsList( gens ) );
    return M;
    end );


#############################################################################
##
#M  MagmaWithOneByGenerators( <gens> )  . . . . . . . . . .  for a collection
##
InstallMethod( MagmaWithOneByGenerators,
    "for collection",
    true,
    [ IsCollection ] , 0,
    function( gens )
    local M;
    M:= Objectify( NewType( FamilyObj( gens ),
                            IsMagmaWithOne and IsAttributeStoringRep ),
                   rec() );
    SetGeneratorsOfMagmaWithOne( M, AsList( gens ) );
    return M;
    end );


#############################################################################
##
#M  MagmaWithOneByGenerators( <Fam>, <gens> ) . . . . . . for family and list
##
InstallOtherMethod( MagmaWithOneByGenerators,
    "for family and list",
    true,
    [ IsFamily, IsList ], 0,
    function( family, gens )
    local M;
    if not ( IsEmpty(gens) or IsIdenticalObj( FamilyObj(gens), family ) ) then
      Error( "<family> and family of <gens> do not match" );
    fi;
    M:= Objectify( NewType( family,
                            IsMagmaWithOne and IsAttributeStoringRep ),
                   rec() );
    SetGeneratorsOfMagmaWithOne( M, AsList( gens ) );
    return M;
    end );


#############################################################################
##
#M  MagmaWithInversesByGenerators( <gens> ) . . . . . . . .  for a collection
##
BindGlobal( "MakeMagmaWithInversesByFiniteGenerators", function(family,gens)
local M;

  M:=MakeGroupyObj(family, IsMagmaWithInverses, gens, fail);

  if HasIsAssociative( M ) and IsAssociative( M ) then
    SetIsFinitelyGeneratedGroup( M, true );
  fi;
  return M;
end );

InstallMethod( MagmaWithInversesByGenerators, "for collection", true,
    [ IsCollection and IsFinite] , 0,
function( gens )
  return MakeMagmaWithInversesByFiniteGenerators(FamilyObj(gens),gens);
end);

#############################################################################
##
#M  MagmaWithInversesByGenerators( <Fam>, <gens> )  . . . for family and list
##
InstallOtherMethod( MagmaWithInversesByGenerators, "for family and list",
    true, [ IsFamily, IsList and IsFinite], 0,
function( family, gens )
  if not ( IsEmpty(gens) or IsIdenticalObj( FamilyObj(gens), family ) ) then
    Error( "<family> and family of <gens> do not match" );
  fi;
  return MakeMagmaWithInversesByFiniteGenerators(family,gens);
end );


#############################################################################
##
#M  TrivialSubmagmaWithOne( <M> ) . . . . . . . . . . .  for a magma-with-one
##
InstallMethod( TrivialSubmagmaWithOne,
    "for magma-with-one",
    true,
    [ IsMagmaWithOne ], 0,
    # use the `Parent' to avoid too many nonmaximal parents
    M -> SubmagmaWithOneNC( Parent(M), [] ) );


#############################################################################
##
#M  GeneratorsOfMagma( <M> )
##
##  If nothing special is known about the magma <M> we delegate to
##  `GeneratorsOfDomain'.
##
##  If <M> is in fact a magma-with-one or a magma-with-inverses with known
##  generators of one of these kinds then magma generators can be computed
##  from them.
##
##  Adding identity and inverses can be avoided if the elements in the magma
##  are known to have finite order;
##  this holds for example for permutation groups.
##
InstallMethod( GeneratorsOfMagma,
    "generic method for a magma (take domain generators)",
    true,
    [ IsMagma ], 0,
    GeneratorsOfDomain );

InstallMethod( GeneratorsOfMagma,
    "for a magma-with-one with known generators",
    true,
    [ IsMagmaWithOne and HasGeneratorsOfMagmaWithOne ], 0,
function(M)
local c;
  c:=Concatenation( GeneratorsOfMagmaWithOne( M ), [ One(M) ] );
  if CanEasilySortElements(One(M)) then
    return Set(c);
  elif CanEasilyCompareElements(One(M)) then
    return Unique(c);
  fi;
  return c;
end);

InstallMethod( GeneratorsOfMagma,
    "for a magma-with-inverses with known generators",
    true,
    [ IsMagmaWithInverses and HasGeneratorsOfMagmaWithInverses ], 0,
function(M)
local c;
  c:=Concatenation( GeneratorsOfMagmaWithInverses( M ),
              [ One( M ) ],
              List( GeneratorsOfMagmaWithInverses( M ), Inverse ) );
  if CanEasilySortElements(One(M)) then
    return Set(c);
  elif CanEasilyCompareElements(One(M)) then
    return Unique(c);
  fi;
  return c;
end);

InstallMethod( GeneratorsOfMagma,
    "for a magma-with-one with generators, all elms. of finite order",
    true,
    [ IsMagmaWithOne and HasGeneratorsOfMagmaWithOne
      and IsFiniteOrderElementCollection ], 0,
    function( M )
    local gens;
    gens:= GeneratorsOfMagmaWithOne( M );
    if IsEmpty( gens ) then
      return [ One( M ) ];
    else
      return gens;
    fi;
    end );

InstallMethod( GeneratorsOfMagma,
    "for a magma-with-inv. with gens., all elms. of finite order",
    true,
    [ IsMagmaWithInverses and HasGeneratorsOfMagmaWithInverses
      and IsFiniteOrderElementCollection ], 0,
    function( M )
    local gens;
    gens:= GeneratorsOfMagmaWithInverses( M );
    if IsEmpty( gens ) then
      return [ One( M ) ];
    else
      return gens;
    fi;
    end );


#############################################################################
##
#M  GeneratorsOfMagmaWithOne( <M> )
##
##  A known `GeneratorsOfMagma' value can be taken for
##  `GeneratorsOfMagmaWithOne'.
##
##  If <M> is in fact a magma-with-inverses with known
##  generators of this kind then magma-with-one generators can be computed
##  from them.
##
##  Adding inverses can be avoided if the elements in the magma
##  are known to have finite order;
##  this holds for example for permutation groups.
##
InstallMethod( GeneratorsOfMagmaWithOne,
    "for a magma-with-one with known magma generators (take them)",
    true,
    [ IsMagmaWithOne and HasGeneratorsOfMagma ], 0,
    GeneratorsOfMagma );

InstallMethod( GeneratorsOfMagmaWithOne,
    "for a magma-with-inverses with generators",
    true,
    [ IsMagmaWithInverses and HasGeneratorsOfMagmaWithInverses ], 0,
function(M)
local c;
  c:=Concatenation( GeneratorsOfMagmaWithInverses( M ),
              List( GeneratorsOfMagmaWithInverses( M ), Inverse ) );
  if CanEasilySortElements(One(M)) then
    return Set(c);
  elif CanEasilyCompareElements(One(M)) then
    return Unique(c);
  fi;
  return c;
end);

InstallMethod( GeneratorsOfMagmaWithOne,
    "for a magma-with-inv. with gens., all elms. of finite order",
    true,
    [ IsMagmaWithInverses and HasGeneratorsOfMagmaWithInverses
      and IsFiniteOrderElementCollection ], 0,
    GeneratorsOfMagmaWithInverses );


#############################################################################
##
#M  GeneratorsOfMagmaWithInverses( <M> )
##
##  A known `GeneratorsOfMagma' or `GeneratorsOfMagmaWithOne' value
##  can be taken for `GeneratorsOfMagmaWithInverses'.
##
InstallMethod( GeneratorsOfMagmaWithInverses,
    "for a magma-with-inverses with known magma generators (take them)",
    true,
    [ IsMagmaWithInverses and HasGeneratorsOfMagma ], 0,
    GeneratorsOfMagma );

InstallMethod( GeneratorsOfMagmaWithInverses,
    "for a magma-with-inverses with known magma-with-one gen.s (take them)",
    true,
    [ IsMagmaWithInverses and HasGeneratorsOfMagmaWithOne ], 0,
    GeneratorsOfMagmaWithOne );


#############################################################################
##
#M  Representative( <M> ) . . . . . . . . . . . . . .  one element of a magma
##
InstallMethod( Representative,
    "for magma with generators",
    true,
    [ IsMagma and HasGeneratorsOfMagma ], 0,
    RepresentativeFromGenerators( GeneratorsOfMagma ) );

InstallMethod( Representative,
    "for magma-with-one with generators",
    true,
    [ IsMagmaWithOne and HasGeneratorsOfMagmaWithOne ], 0,
    RepresentativeFromGenerators( GeneratorsOfMagmaWithOne ) );

InstallMethod( Representative,
    "for magma-with-inverses with generators",
    true,
    [ IsMagmaWithInverses and HasGeneratorsOfMagmaWithInverses ], 0,
    RepresentativeFromGenerators( GeneratorsOfMagmaWithInverses ) );

InstallMethod( Representative,
    "for magma-with-one with known one",
    true,
    [ IsMagmaWithOne and HasOne ], SUM_FLAGS,
    One );

InstallMethod( Representative,
    "for magma-with-one with stored parent",
    [ IsMagmaWithOne and HasParentAttr ],
    function( M )
    if not IsIdenticalObj( M, Parent( M ) ) then
      return One( Representative( Parent( M ) ) );
    fi;
    TryNextMethod();
    end );


#############################################################################
##
#M  MultiplicativeNeutralElement( <M> ) . . . . . . . . . . . . . for a magma
##
InstallMethod( MultiplicativeNeutralElement,
    "for a magma",
    true,
    [ IsMagma ], 0,
    function( M )
    local m;
    if IsFinite( M ) then
      for m in M do
        if ForAll( M, n -> n * m = n and m * n = n ) then
          return m;
        fi;
      od;
      return fail;
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
##  HasMultiplicativeNeutralElement( <M> )
##
##  always true for a magma-with-one
##
InstallTrueMethod(HasMultiplicativeNeutralElement, IsMagmaWithOne);

#############################################################################
##
#M  MultiplicativeNeutralElement( <M> ) . . . . . . . .  for a magma-with-one
##
InstallMethod(MultiplicativeNeutralElement,
    "for a magma-with-one",
    true,
    [HasMultiplicativeNeutralElement and IsMagmaWithOne], GETTER_FLAGS+1,
    One );

InstallMethod(SetMultiplicativeNeutralElement,
    "for a magma-with-one",
    true,
    [IsMagma, IsBool], 0,
function(m, b)
    if b<>fail then
      TryNextMethod();
    fi;
end);


#############################################################################
##
#M  One( <M> )  . . . . . . . . . . . . . . . . . . . . . identity of a magma
##
InstallOtherMethod( One,
    "for a magma",
    true,
    [ IsMagma ], 0,
    function( M )
    local one;
    one:= One( Representative( M ) );
    if one <> fail and one in M then
      return one;
    else
      return fail;
    fi;
    end );

InstallOtherMethod( One,
    "partial method for a magma-with-one (ask family)",
    true,
    [ IsMagmaWithOne ], 100,
#T high priority?
    function( M )
    M:= ElementsFamily( FamilyObj( M ) );
    if HasOne( M ) then
      return One( M );
    else
      TryNextMethod();
    fi;
    end );

InstallOtherMethod( One,
    "for a magma-with-one that has a parent",
    true,
    [ IsMagmaWithOne and HasParent ], SUM_FLAGS,
    function( M )
    if not IsIdenticalObj( M, Parent( M ) ) then
      return One( Parent( M ) );
    fi;
    TryNextMethod();
    end );

InstallOtherMethod( One,
    "for a magma-with-one",
    true,
    [ IsMagmaWithOne ], 0,
    M -> One( Representative( M ) ) );


#############################################################################
##
#M  Enumerator( <M> ) . . . . . . . . .  enumerator of trivial magma with one
##
BindGlobal( "EnumeratorOfTrivialMagmaWithOne",
    M -> Immutable( [ One( M ) ] ) );

InstallMethod( Enumerator,
    "for trivial magma-with-one",
    true,
    [ IsMagmaWithOne and IsTrivial ], 0,
    EnumeratorOfTrivialMagmaWithOne );


#############################################################################
##
#F  ClosureMagmaDefault( <M>, <elm> ) . . . . . closure of magma with element
##
BindGlobal( "ClosureMagmaDefault", function( M, elm )

    local   C,          # closure of `M' with `obj', result
            gens,       # generators of `M'
            gen,        # generator of `M' or `C'
            Celements,  # intermediate list of elements
            len;        # current number of elements

    gens:= GeneratorsOfMagma( M );

    # try to avoid adding an element to a magma that already contains it
    if   elm in gens
      or ( HasAsSSortedList( M ) and elm in AsSSortedList( M ) )
    then
        return M;
    fi;

    # make the closure magma
    gens:= Concatenation( gens, [ elm ] );
    C:= MagmaByGenerators( gens );
    UseSubsetRelation( C, M );

    # if the elements of <M> are known then extend this list
    # (multiply each element from the left and right with the new
    # generator, and then multiply with all elements until the
    # list becomes stable)
    if HasAsSSortedList( M ) then

        Celements := ShallowCopy( AsSSortedList( M ) );
        AddSet( Celements, elm );
        UniteSet( Celements, Celements * elm );
        UniteSet( Celements, elm * Celements );
        repeat
            len:= Length( Celements );
            for gen in Celements do
                UniteSet( Celements, Celements * gen );
                UniteSet( Celements, gen * Celements );
            od;
        until len = Length( Celements );

        SetAsSSortedList( C, AsSSortedList( Celements ) );
        SetIsFinite( C, true );
        SetSize( C, Length( Celements ) );

    fi;

    # return the closure
    return C;
end );


#############################################################################
##
#M  Enumerator( <M> ) . . . . . . . . . . . .  set of the elements of a magma
##
BindGlobal( "EnumeratorOfMagma", function( M )

    local   gens,       # magma generators of <M>
            H,          # submagma of the first generators of <M>
            gen;        # generator of <M>

    # The following code only does not work infinite magmas.
    if HasIsFinite( M ) and not IsFinite( M ) then
      TryNextMethod();
    fi;

    # handle the case of an empty magma
    gens:= GeneratorsOfMagma( M );
    if IsEmpty( gens ) then
      return [];
    fi;

    # start with the empty magma and its element list
    H:= Submagma( M, [] );
    SetAsSSortedList( H, Immutable( [ ] ) );

    # Add the generators one after the other.
    # We use a function that maintains the elements list for the closure.
    for gen in gens do
      H:= ClosureMagmaDefault( H, gen );
    od;

    # return the list of elements
    Assert( 2, HasAsSSortedList( H ) );
    return AsSSortedList( H );
end );

InstallMethod( Enumerator,
    "generic method for a magma",
    true,
    [ IsMagma and IsAttributeStoringRep ], 0,
    EnumeratorOfMagma );


#############################################################################
##
#M  IsCentral( <M>, <N> )
##
InstallMethod( IsCentral,
    "for two magmas",
    IsIdenticalObj,
    [ IsMagma, IsMagma ], 0,
    IsCentralFromGenerators( GeneratorsOfMagma, GeneratorsOfMagma ) );

InstallMethod( IsCentral,
    "for two magmas-with-one",
    IsIdenticalObj,
    [ IsMagmaWithOne, IsMagmaWithOne ], 0,
    IsCentralFromGenerators( GeneratorsOfMagmaWithOne,
                             GeneratorsOfMagmaWithOne ) );

InstallMethod( IsCentral,
    "for two magmas-with-inverses",
    IsIdenticalObj,
    [ IsMagmaWithInverses, IsMagmaWithInverses ], 0,
    IsCentralFromGenerators( GeneratorsOfMagmaWithInverses,
                             GeneratorsOfMagmaWithInverses ) );

#############################################################################
##
#M  IsCentral( <M>, <elm> )
##
InstallMethod( IsCentral,
    "for a magma and an element",
    IsCollsElms,
    [ IsMagma, IsObject ], 0,
    IsCentralElementFromGenerators( GeneratorsOfMagma ) );

InstallMethod( IsCentral,
    "for a magma-with-one and an element",
    IsCollsElms,
    [ IsMagmaWithOne, IsObject ], 0,
    IsCentralElementFromGenerators( GeneratorsOfMagmaWithOne ) );

InstallMethod( IsCentral,
    "for a magma-with-inverses and an element",
    IsCollsElms,
    [ IsMagmaWithInverses, IsObject ], 0,
    IsCentralElementFromGenerators( GeneratorsOfMagmaWithInverses ) );


#############################################################################
##
#M  IsSubset( <M>, <N> )  . . . . . . . . . . . . . . . . . .  for two magmas
##
InstallMethod( IsSubset,
    "for two magmas",
    IsIdenticalObj,
    [ IsMagma, IsMagma ], 0,
    function( M, N )
    return IsSubset( M, GeneratorsOfMagma( N ) );
    end );


#############################################################################
##
#M  IsSubset( <M>, <N> )  . . . . . . . . . . . . . . for two magmas with one
##
InstallMethod( IsSubset,
    "for two magmas with one",
    IsIdenticalObj,
    [ IsMagmaWithOne, IsMagmaWithOne ], 0,
    function( M, N )
    return IsSubset( M, GeneratorsOfMagmaWithOne( N ) );
    end );


#############################################################################
##
#M  IsSubset( <M>, <N> )  . . . . . . . . . . .  for two magmas with inverses
##
InstallMethod( IsSubset,
    "for two magmas with inverses",
    IsIdenticalObj,
    [ IsMagmaWithInverses, IsMagmaWithInverses ], 0,
    function( M, N )
    return IsSubset( M, GeneratorsOfMagmaWithInverses( N ) );
    end );


#############################################################################
##
#M  AsMagma( <D> ) . . . . . . . . . . . . . .  domain <D>, regarded as magma
##
InstallMethod( AsMagma,
    "for a magma (return the argument)",
    true,
    [ IsMagma ], 100,
    IdFunc );

InstallMethod( AsMagma,
    "generic method for collections",
    true,
    [ IsCollection ], 0,
    function( D )
    local   M,  L;

    D := AsSSortedList( D );
    L := ShallowCopy( D );
    M := Submagma( MagmaByGenerators( D ), [] );
    SubtractSet( L, AsSSortedList( M ) );
    while not IsEmpty(L)  do
        M := ClosureMagmaDefault( M, L[1] );
        SubtractSet( L, AsSSortedList( M ) );
    od;
    if Length( AsSSortedList( M ) ) <> Length( D )  then
        return fail;
    fi;
    M := MagmaByGenerators( GeneratorsOfMagma( M ) );
    SetAsSSortedList( M, D );
    SetIsFinite( M, true );
    SetSize( M, Length( D ) );

    # return the magma
    return M;
    end );


#############################################################################
##
#M  AsSubmagma( <G>, <U> )
##
InstallMethod( AsSubmagma,
    "generic method for a domain and a collection",
    IsIdenticalObj,
    [ IsDomain, IsCollection ], 0,
    function( G, U )
    local S;
    if not IsSubset( G, U ) then
      return fail;
    fi;
    if IsMagma( U ) then
      S:= SubmagmaNC( G, GeneratorsOfMagma( U ) );
    else
      S:= SubmagmaNC( G, AsList( U ) );
    fi;
    UseIsomorphismRelation( U, S );
    UseSubsetRelation( U, S );
    return S;
    end );


#############################################################################
##
#M  IsEmpty( <M> )  . . . . . . . . . . . . . . test whether a magma is empty
##
InstallMethod(IsEmpty, "for a magma with generators of magma",
[IsMagma and HasGeneratorsOfMagma],
M -> IsEmpty(GeneratorsOfMagma(M)));
