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
##  This file contains the methods for magmas given by their multiplication
##  tables.
##


#############################################################################
##
#R  IsMagmaByMultiplicationTableObj( <obj> )
##
##  At position 1 of the element $m_i$, the number $i$ is stored.
##
DeclareRepresentation( "IsMagmaByMultiplicationTableObj",
    IsPositionalObjectRep and IsMultiplicativeElementWithInverse,
    [ 1 ] );
#T change to IsPositionalObjectOneSlotRep!


#############################################################################
##
#M  PrintObj( <obj> )
##
InstallMethod( PrintObj,
    "for element of magma by mult. table",
    [ IsMagmaByMultiplicationTableObj ],
    function( obj )
    Print( "m", obj![1] );
    end );


#############################################################################
##
#M  \=( <x>, <y> )
#M  \<( <x>, <y> )
#M  \*( <x>, <y> )
#M  \^( <x>, <n> )
##
InstallMethod( \=,
    "for two elements of magma by mult. table",
    IsIdenticalObj,
    [ IsMagmaByMultiplicationTableObj,
      IsMagmaByMultiplicationTableObj ],
    function( x, y ) return x![1] = y![1]; end );

InstallMethod( \<,
    "for two elements of magma by mult. table",
    IsIdenticalObj,
    [ IsMagmaByMultiplicationTableObj,
      IsMagmaByMultiplicationTableObj ],
    function( x, y ) return x![1] < y![1]; end );

InstallMethod( \*,
    "for two elements of magma by mult. table",
    IsIdenticalObj,
    [ IsMagmaByMultiplicationTableObj,
      IsMagmaByMultiplicationTableObj ],
    function( x, y )
    local F;
    F:= FamilyObj( x );
    return F!.set[ MultiplicationTable( F )[ x![1] ][ y![1] ] ];
    end );


#############################################################################
##
#M  OneOp( <elm> )
##
InstallMethod( OneOp,
    "for an element in a magma by mult. table",
    [ IsMagmaByMultiplicationTableObj ],
    function( elm )
    local F, n, A, onepos, one;

    F:= FamilyObj( elm );
    n:= F!.n;

    # Check that the mult. table admits a left and right identity element.
    A:= MultiplicationTable( F );
    onepos:= Position( A, [ 1 .. n ] );
    if onepos = fail or A{ [ 1 .. n ] }[ onepos ] <> [ 1 .. n ] then
      one:= fail;
    else
      one:= F!.set[ onepos ];
    fi;

    SetOne( F, one );

    return one;
end );

#############################################################################
##
#M  IsGeneratorsOfMagmaWithInverses( <elms> )
##
##  Under the assumption that the multiplication for <elms> is associative
##  (cf. the discussion for issue 4480),
##  a collection of magma by multiplication table elements will always be
##  acceptable as generators, provided each one individually has an inverse.
##
InstallMethod( IsGeneratorsOfMagmaWithInverses,
        "for a collection of magma by mult table elements",
        [IsCollection],
        function(c)
    if ForAll(c, x-> IsMagmaByMultiplicationTableObj(x) and Inverse(x) <> fail) then
        return true;
    fi;
    TryNextMethod();
end);


#############################################################################
##
#M  InverseOp( <elm> )
##
InstallMethod( InverseOp,
    "for an element in a magma by mult. table",
    [ IsMagmaByMultiplicationTableObj ],
    function( elm )
    local F, i, one, onepos, inv, j, n, A, invpos;

    F:= FamilyObj( elm );
    i:= elm![1];

    if IsBound( F!.inverse[i] ) then
      return F!.inverse[i];
    fi;

    # Check that `A' admits a left and right identity element.
    # (This is uniquely determined.)
    one:= One( elm );
    if one = fail then
      return fail;
    fi;
    onepos:= one![1];

    # Check that `elm' has a left and right inverse.
    # (If the multiplication is associative, this is uniquely determined.)
    inv:= fail;
    j:= 0;
    n:= F!.n;
    A:= MultiplicationTable( F );
    while j <= n do
      invpos:= Position( A[i], onepos, j );
      if invpos <> fail and A[ invpos ][i] = onepos then
        inv:= F!.set[ invpos ];
        break;
      fi;
      j:= invpos;
    od;

    F!.inverse[i]:= inv;

    return inv;
    end );


#############################################################################
##
#F  MagmaElement( <M>, <i> ) . . . . . . . . . .  <i>-th element of magma <M>
##
InstallGlobalFunction( MagmaElement, function( M, i )
    M:= AsSSortedList( M );
    if Length( M ) < i then
      return fail;
    else
      return M[i];
    fi;
end );


#############################################################################
##
#F  MagmaByMultiplicationTableCreator( <A>, <domconst> )
##
InstallGlobalFunction( MagmaByMultiplicationTableCreator,
    function( arg )
    local n,      # dimension of `A'
          range,  # the range `[ 1 .. n ]'
          filts;

    if IsBound(arg[3]) then
      filts:=IsMagmaByMultiplicationTableObj and arg[3];
    else
      filts:=IsMagmaByMultiplicationTableObj;
    fi;

    # Check that `arg[1]' is a valid multiplication table.
    if IsMatrix( arg[1] ) then
      n:= Length( arg[1] );
      range:= [ 1 .. n ];
      if     Length( arg[1][1] ) = n
         and ForAll( arg[1], row -> ForAll( row, x -> x in range ) ) then
        return MagmaByMultiplicationTableCreatorNC(arg[1], arg[2], filts);
      fi;
    fi;
    Error( "<arg[1]> must be a square matrix with entries in `[ 1 .. n ]'" );
end );

#

InstallGlobalFunction( MagmaByMultiplicationTableCreatorNC,
function( A, domconst, filts )
  local n, F, elms, M;

  n:=Length(A);
  # Construct the family of objects.
  F:= NewFamily( "MagmaByMultTableObj", filts );
  F!.n:=n;
  SetMultiplicationTable( F, A );
  elms:= Immutable( List( [1..n],
             i -> Objectify( NewType( F, filts), [ i ] ) ) );
  SetIsSSortedList( elms, true );
  F!.set:= elms;
  F!.inverse:= [];

  # Construct the magma.
  M:= domconst( CollectionsFamily( F ), elms );
  SetSize( M, n );
  SetAsSSortedList( M, elms );
  SetMultiplicationTable( M, MultiplicationTable( F ) );

  # Return the result.
  return M;
end );

#############################################################################
##
#F  MagmaByMultiplicationTable( <A> )
##
InstallGlobalFunction( MagmaByMultiplicationTable, function( A )
    return MagmaByMultiplicationTableCreator( A, MagmaByGenerators );
end );


#############################################################################
##
#F  MagmaWithOneByMultiplicationTable( <A> )
##
InstallGlobalFunction( MagmaWithOneByMultiplicationTable, function( A )
    local n,      # dimension of `A'
          onepos, # position of the identity in `A'
          M;      # the magma, result

    M:= MagmaByMultiplicationTableCreator( A, MagmaWithOneByGenerators );

    # Check that `A' admits a left and right identity element.
    n:= Length( A );
    onepos:= Position( A, [ 1 .. n ] );
    if onepos = fail or A{ [ 1 .. n ] }[ onepos ] <> [ 1 .. n ] then
      return fail;
    fi;

    # Store the identity in the family.
    SetOne( ElementsFamily( FamilyObj( M ) ), AsSSortedList( M )[ onepos ] );
    SetGeneratorsOfMagma( M, AsSSortedList( M ) );

    # Return the result.
    return M;
end );


#############################################################################
##
#F  MagmaWithInversesByMultiplicationTable( <A> )
##
InstallGlobalFunction( MagmaWithInversesByMultiplicationTable, function( A )
    local F,      # the family of objects
          n,      # dimension of `A'
          onepos, # position of the identity in `A'
          inv,    # list of positions of inverses
          i,      # loop over the elements
          invpos, # position of one inverse
          elms,   # sorted list of elements
          M;      # the magma, result

    M:= MagmaByMultiplicationTableCreator( A,
            MagmaWithInversesByGenerators );

    # Check that `A' admits a left and right identity element.
    n:= Length( A );
    onepos:= Position( A, [ 1 .. n ] );
    if onepos = fail or A{ [ 1 .. n ] }[ onepos ] <> [ 1 .. n ] then
      return fail;
    fi;

    # Check that `A' admits inverses.
    inv:= [];
    for i in [ 1 .. n ] do
      invpos:= Position( A[i], onepos );
      if invpos = fail or A[ invpos ][i] <> onepos then
        return fail;
      fi;
      inv[i]:= invpos;
    od;

    # Store identity and inverses in the family.
    F:= ElementsFamily( FamilyObj( M ) );
    elms:= AsSSortedList( M );
    SetOne( F, elms[ onepos ] );
    F!.inverse:= Immutable( elms{ inv } );
    SetGeneratorsOfMagma( M, elms );

    # Return the result.
    return M;
end );


#############################################################################
##
#F  SemigroupByMultiplicationTable( <A> )
##
InstallGlobalFunction( SemigroupByMultiplicationTable,
function( A )
  local n, range, i, j, k;

    # Check that `A' is a valid multiplication table.
    if IsMatrix( A ) then
      n := Length( A );
      range := [ 1 .. n ];

      if     Length( A[1] ) = n
         and ForAll( A, row -> ForAll( row, x -> x in range ) ) then

        # check associativity
        for i in range do
          for j in range do
            for k in range do
              if A[A[i][j]][k]<>A[i][A[j][k]] then
                return fail;
              fi;
            od;
          od;
        od;

        return MagmaByMultiplicationTableCreatorNC(A, MagmaByGenerators,
         IsAssociativeElement and IsMagmaByMultiplicationTableObj);
      fi;
    fi;
    Error( "<A> must be a square matrix with entries in `[ 1 .. n ]'" );
end );


#############################################################################
##
#F  MonoidByMultiplicationTable( <A> )
##
InstallGlobalFunction( MonoidByMultiplicationTable,
function( A )
  local n, range, onepos, M, i, j, k;

  if IsMatrix( A ) then
    n := Length( A );
    range := [ 1 .. n ];

    if     Length( A[1] ) = n
       and ForAll( A, row -> ForAll( row, x -> x in range ) ) then

      # Check that `A' admits a left and right identity element.
      onepos:= Position( A, [ 1 .. n ] );
      if onepos = fail or A{ [ 1 .. n ] }[ onepos ] <> [ 1 .. n ] then
        return fail;
      fi;

      # check associativity
      for i in range do
        for j in range do
          for k in range do
            if A[A[i][j]][k]<>A[i][A[j][k]] then
              return fail;
            fi;
          od;
        od;
      od;
      M:=MagmaByMultiplicationTableCreatorNC(A, MagmaWithOneByGenerators,
         IsAssociativeElement and IsMagmaByMultiplicationTableObj);

      # Store the identity in the family.
      SetOne( ElementsFamily( FamilyObj( M ) ), AsSSortedList( M )[ onepos ] );
      SetGeneratorsOfMagma( M, AsSSortedList( M ) );

      # Return the result.
      return M;
    fi;
  fi;
  Error( "<A> must be a square matrix with entries in `[ 1 .. n ]'" );
end );


#############################################################################
##
#F  GroupByMultiplicationTable( <A> )
##
InstallGlobalFunction( GroupByMultiplicationTable, function( A )
    A:= MagmaWithInversesByMultiplicationTable( A );
    if A = fail or not IsAssociative( A ) then
      return fail;
    fi;
    return A;
end );


#############################################################################
##
#M  MultiplicationTable( <elmlist> )
##
InstallMethod( MultiplicationTable,
    "for a list of elements",
    [ IsHomogeneousList ],
    elmlist -> List( elmlist, x -> List( elmlist,
                 y -> Position( elmlist, x * y ) ) ) );


#############################################################################
##
#M  MultiplicationTable( <M> )
##
InstallMethod( MultiplicationTable,
    "for a magma",
    [ IsMagma ],
    M -> MultiplicationTable( AsSSortedList( M ) ) );
