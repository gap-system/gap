#############################################################################
##
#W  grptbl.gi                   GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the methods for magmas given by their multiplication
##  tables.
##
Revision.grptbl_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  PrintObj( <obj> )
##
InstallMethod( PrintObj,
    "for element of magma by mult. table",
    true,
    [ IsMagmaByMultiplicationTableObj ], 0,
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
      IsMagmaByMultiplicationTableObj ], 0,
    function( x, y ) return x![1] = y![1]; end );

InstallMethod( \<,
    "for two elements of magma by mult. table",
    IsIdenticalObj,
    [ IsMagmaByMultiplicationTableObj,
      IsMagmaByMultiplicationTableObj ], 0,
    function( x, y ) return x![1] < y![1]; end );

InstallMethod( \*,
    "for two elements of magma by mult. table",
    IsIdenticalObj,
    [ IsMagmaByMultiplicationTableObj,
      IsMagmaByMultiplicationTableObj ], 0,
    function( x, y )
    local F;
    F:= FamilyObj( x );
    return F!.set[ F!.A[ x![1] ][ y![1] ] ];
    end );


#############################################################################
##
#M  OneOp( <elm> )
##
InstallMethod( OneOp,
    "for an element in a magma by mult. table",
    true,
    [ IsMagmaByMultiplicationTableObj ], 0,
    function( elm )

    local F, n, onepos, one;

    F:= FamilyObj( elm );
    n:= F!.n;

    # Check that `F!.A' admits a left and right identity element.
    onepos:= Position( F!.A, [ 1 .. n ] );
    if onepos = fail or F!.A{ [ 1 .. n ] }[ onepos ] <> [ 1 .. n ] then
      one:= fail;
    else
      one:= F!.set[ onepos ];
    fi;

    SetOne( F, one );

    return one;
    end );


#############################################################################
##
#M  InverseOp( <elm> )
##
InstallMethod( InverseOp,
    "for an element in a magma by mult. table",
    true,
    [ IsMagmaByMultiplicationTableObj ], 0,
    function( elm )

    local F, i, one, onepos, inv, j, n, invpos;

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
    while j <= n do

      invpos:= Position( F!.A[i], onepos, j );
      if invpos <> fail and F!.A[ invpos ][i] = onepos then
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
#F  MagmaByMultiplicationTable( <A> )
##
InstallGlobalFunction( MagmaByMultiplicationTable, function( A )

    local F,      # the family of objects
          n,      # dimension of `A'
          range,  # the range `[ 1 .. n ]'
          elms,   # sorted list of elements
          M;      # the magma, result

    # Check that `A' is a valid multiplication table.
    if IsMatrix( A ) then
      n:= Length( A );
      range:= [ 1 .. n ];
      if     Length( A[1] ) = n
         and ForAll( A, row -> ForAll( row, x -> x in range ) ) then

        # Construct the family of objects.
        F:= NewFamily( "MagmaByMultTableObj",
                       IsMagmaByMultiplicationTableObj );
        F!.n:= n;
        F!.A:= A;
        elms:= Immutable( List( range,
                   i -> Objectify( NewType( F,
                            IsMagmaByMultiplicationTableObj ), [ i ] ) ) );
        F!.set:= elms;
        SetIsSSortedList( elms, true );
        F!.inverse:= [];

        # Construct the magma.
        M:= MagmaByGenerators( CollectionsFamily( F ), elms );
        SetSize( M, n );
        SetAsSSortedList( M, elms );

        # Return the result.
        return M;
      fi;
    fi;
    Error( "<A> must be a square matrix with entries in `[ 1 .. n ]'" );
end );


#############################################################################
##
#F  MagmaWithOneByMultiplicationTable( <A> )
##
InstallGlobalFunction( MagmaWithOneByMultiplicationTable, function( A )

    local F,      # the family of objects
          n,      # dimension of `A'
          range,  # the range `[ 1 .. n ]'
          onepos, # position of the identity in `A'
          elms,   # sorted list of elements
          M;      # the magma, result

    # Check that `A' is a valid multiplication table.
    if IsMatrix( A ) then
      n:= Length( A );
      range:= [ 1 .. n ];
      if     Length( A[1] ) = n
         and ForAll( A, row -> ForAll( row, x -> x in range ) ) then

        # Check that `A' admits a left and right identity element.
        onepos:= Position( A, [ 1 .. n ] );
        if onepos = fail or A{ [ 1 .. n ] }[ onepos ] <> [ 1 .. n ] then
          return fail;
        fi;

        # Construct the family of objects.
        F:= NewFamily( "MagmaByMultTableObj",
                       IsMagmaByMultiplicationTableObj );
        F!.n:= n;
        F!.A:= A;
        elms:= Immutable( List( range,
                   i -> Objectify( NewType( F,
                            IsMagmaByMultiplicationTableObj ), [ i ] ) ) );
        F!.set:= elms;
        SetIsSSortedList( elms, true );
        F!.inverse:= [];

        # Store the identity.
        SetOne( F, F!.set[ onepos ] );

        # Construct the magma-with-one.
        M:= MagmaWithOneByGenerators( CollectionsFamily( F ), elms );
        SetSize( M, n );
        SetAsSSortedList( M, elms );
        SetGeneratorsOfMagma( M, elms );

        # Return the result.
        return M;
      fi;
    fi;
    Error( "<A> must be a square matrix with entries in `[ 1 .. n ]'" );
end );


#############################################################################
##
#F  MagmaWithInversesByMultiplicationTable( <A> )
##
InstallGlobalFunction( MagmaWithInversesByMultiplicationTable, function( A )

    local F,      # the family of objects
          n,      # dimension of `A'
          range,  # the range `[ 1 .. n ]'
          onepos, # position of the identity in `A'
          inv,    # list of positions of inverses
          i,      # loop over the elements
          invpos, # position of one inverse
          elms,   # sorted list of elements
          M;      # the magma, result

    # Check that `A' is a valid multiplication table.
    if IsMatrix( A ) then
      n:= Length( A );
      range:= [ 1 .. n ];
      if     Length( A[1] ) = n
         and ForAll( A, row -> ForAll( row, x -> x in range ) ) then

        # Check that `A' admits a left and right identity element.
        onepos:= Position( A, [ 1 .. n ] );
        if onepos = fail or A{ [ 1 .. n ] }[ onepos ] <> [ 1 .. n ] then
          return fail;
        fi;

        # Check that `A' admits inverses.
        inv:= [];
        for i in [ 1 .. n ] do
          invpos:= Position( A[i], onepos );
          if invpos = fail or A[ invpos ][i] <> onepos then

            # no inverse at least for element `i'
            return fail;

          fi;
          inv[i]:= invpos;
        od;

        # Construct the family of objects.
        F:= NewFamily( "MagmaByMultTableObj",
                       IsMagmaByMultiplicationTableObj );
        F!.n:= n;
        F!.A:= A;
        elms:= Immutable( List( range,
                   i -> Objectify( NewType( F,
                            IsMagmaByMultiplicationTableObj ), [ i ] ) ) );
        F!.set:= elms;
        SetIsSSortedList( elms, true );

        # Store identity and inverses in the family.
        SetOne( F, F!.set[ onepos ] );
        F!.inverse:= Immutable( elms{ inv } );

        # Construct the magma-with-inverses.
        M:= MagmaWithInversesByGenerators( CollectionsFamily( F ), elms );
        SetSize( M, n );
        SetAsSSortedList( M, elms );
        SetGeneratorsOfMagma( M, elms );

        # Return the result.
        return M;
      fi;
    fi;
    Error( "<A> must be a square matrix with entries in `[ 1 .. n ]'" );
end );


#############################################################################
##
#F  SemigroupByMultiplicationTable( <A> )
##
InstallGlobalFunction( SemigroupByMultiplicationTable, function( A )
    A:= MagmaByMultiplicationTable( A );
    if not IsAssociative( A ) then
      return fail;
    fi;
    return A;
end );


#############################################################################
##
#F  MonoidByMultiplicationTable( <A> )
##
InstallGlobalFunction( MonoidByMultiplicationTable, function( A )
    A:= MagmaWithOneByMultiplicationTable( A );
    if A = fail or not IsAssociative( A ) then
      return fail;
    fi;
    return A;
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
#F  MultiplicationTable( <elmlist> )
##
InstallGlobalFunction( MultiplicationTable, function( elmlist )

    local A, n, i, j;

    A:= [];
    n:= Length( elmlist );
    for i in [ 1 .. n ] do
      A[i]:= [];
      for j in [ 1 .. n ] do
        A[i][j]:= Position( elmlist, elmlist[i] * elmlist[j] );
      od;
    od;
    return A;
end );


#############################################################################
##
#E

