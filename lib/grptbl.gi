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
    [ IsMagmaByMultiplicationTableObj, IsMagmaByMultiplicationTableObj ], 0,
    function( x, y ) return x![1] = y![1]; end );

InstallMethod( \<,
    "for two elements of magma by mult. table",
    IsIdenticalObj,
    [ IsMagmaByMultiplicationTableObj, IsMagmaByMultiplicationTableObj ], 0,
    function( x, y ) return x![1] < y![1]; end );

InstallMethod( \*,
    "for two elements of magma by mult. table",
    IsIdenticalObj,
    [ IsMagmaByMultiplicationTableObj, IsMagmaByMultiplicationTableObj ], 0,
    function( x, y )
    local F;
    F:= FamilyObj( x );
    return F!.set[ F!.A[ x![1] ][ y![1] ] ];
    end );

InstallMethod( Inverse,
    "for element of magma by mult. table",
    true,
    [     IsMagmaByMultiplicationTableObj
      and IsMultiplicativeElementWithInverse ], 0,
    x -> FamilyObj( x )!.inverse[ x![1] ] );


#############################################################################
##
#M  ObjByExtRep( <F>, <i> )
##
##  The external representation of the $i$-th element is the integer $i$.
##
InstallMethod( ObjByExtRep,
    "for family of elements of magma by mult. table, and pos. integer",
    true,
    [ IsMagmaByMultiplicationTableObjFamily, IsPosInt ], 0,
    function( F, i )
    if 0 < i and i <= F!.n then
      return Objectify( NewType( F, IsMagmaByMultiplicationTableObj ), [i] );
    else
      Error( "<i> must be in the range `[ 1 .. ", F!.n, " ]'" );
    fi;
    end );


#############################################################################
##
#F  MagmaElement( <M>, <i> ) . . . . . . . . . .  <i>-th element of magma <M>
##
InstallGlobalFunction( MagmaElement, function( M, i )
    if not ( IsMagmaByMultiplicationTable( M ) and IsInt( i ) ) then
      Error( "<M> must be a magma by multiplication table, <i> a position" );
    fi;
    return ObjByExtRep( ElementsFamily( FamilyObj( M ) ), i );
end );


#############################################################################
##
#M  Enumerator( <M> )
#M  EnumeratorSorted( <M> )
##
InstallMethod( Enumerator,
    "for magma by mult. table",
    true,
    [ IsMagmaByMultiplicationTable ], 100,
    M -> ElementsFamily( FamilyObj( M ) )!.set );

InstallMethod( EnumeratorSorted,
    "for magma by mult. table",
    true,
    [ IsMagmaByMultiplicationTable ], 100,
    M -> ElementsFamily( FamilyObj( M ) )!.set );


#############################################################################
##
#M  GeneratorsOfMagma( <M> )
#M  GeneratorsOfMagmaWithOne( <M> )
#M  GeneratorsOfMagmaWithInverses( <M> )
##
InstallMethod( GeneratorsOfMagma,
    "for magma by mult. table",
    true,
    [ IsMagmaByMultiplicationTable ], 0,
    AsListSorted );

InstallMethod( GeneratorsOfMagmaWithOne,
    "for magma-with-one by mult. table",
    true,
    [ IsMagmaByMultiplicationTable and IsMagmaWithOne], 0,
    AsListSorted );

InstallMethod( GeneratorsOfMagmaWithInverses,
    "for magma-with-inverses by mult. table",
    true,
    [ IsMagmaByMultiplicationTable and IsMagmaWithInverses ], 0,
    AsListSorted );


#############################################################################
##
#F  MagmaByMultiplicationTable( <A> )
##
InstallGlobalFunction( MagmaByMultiplicationTable, function( A )

    local F,      # the family of objects
          n,      # dimension of `A'
          range,  # the range `[ 1 .. n ]'
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
        F!.set:= Immutable( List( [ 1 .. n ], i -> ObjByExtRep( F, i ) ) );
        SetIsSSortedList( F!.set, true );

        # Construct the magma.
        M:= Objectify( NewType( CollectionsFamily( F ),
                                    IsMagmaByMultiplicationTable
                                and IsAttributeStoringRep ),
                       rec() );
#T call `MagmaByGenerators'?
        SetSize( M, n );

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
                           IsMagmaByMultiplicationTableObj
                       and IsMultiplicativeElementWithOne );
        F!.n:= n;
        F!.A:= A;
        F!.set:= Immutable( List( [ 1 .. n ], i -> ObjByExtRep( F, i ) ) );
        SetIsSSortedList( F!.set, true );

        # Store the identity.
        SetOne( F, F!.set[ onepos ] );

        # Construct the magma with one.
        M:= Objectify( NewType( CollectionsFamily( F ),
                                    IsMagmaByMultiplicationTable
                                and IsMagmaWithOne
                                and IsAttributeStoringRep ),
                       rec() );
        SetSize( M, n );

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
                           IsMagmaByMultiplicationTableObj
                       and IsMultiplicativeElementWithInverse );
        F!.n:= n;
        F!.A:= A;
        F!.set:= Immutable( List( [ 1 .. n ], i -> ObjByExtRep( F, i ) ) );
        SetIsSSortedList( F!.set, true );

        # Store identity and inverses.
        SetOne( F, F!.set[ onepos ] );
        F!.inverse:= List( inv, i -> ObjByExtRep( F, i ) );

        # Construct the magma with one.
        M:= Objectify( NewType( CollectionsFamily( F ),
                                    IsMagmaByMultiplicationTable
                                and IsMagmaWithInverses
                                and IsAttributeStoringRep ),
                       rec() );
        SetSize( M, n );

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
#E  grptbl.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

