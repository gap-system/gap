#############################################################################
##
#W  obsolete.g                  GAP library                     Steve Linton
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains a number of functions, or extensions of
##  functions to certain numbers or combinations of arguments, which
##  are now considered "deprecated" or "obsolescent", but which are presently
##  included in the system to maintain backwards compatibility.
##
##  Procedures for dealing with this functionality are not yet completely
##  agreed, but it will probably be removed from the system over
##  several releases.
##
##  These functions should NOT be used in the library.
##
##  The current contents of the file was added after the release of
##  {\GAP}~4.2, is regarded as ``obsolescent'' in {\GAP}~4.3,
##  and is expected to be removed with the release of {\GAP}~4.4.
##  (After the release of {\GAP}~4.3, the code will be added that
##  is regarded as ``obsolescent'' in {\GAP}~4.4.
##
Revision.obsolete_g :=
    "@(#)$Id$";


#############################################################################
##
##  Some relics of the old primitive groups library.
##
BindGlobal( "AffinePermGroupByMatrixGroup", function( arg )
    return AffineActionByMatrixGroup( arg[1] );
end );

DeclareSynonym( "PrimitiveAffinePermGroupByMatrixGroup",
    AffineActionByMatrixGroup );


#############################################################################
##
##  relics of vector space basis stuff (from times when only unary methods
##  could be installed for attributes and thus additional non-attributes had
##  been introduced)
##

#############################################################################
##
#A  BasisOfDomain( <V> )
#O  BasisByGenerators( <V>, <vectors> )
#O  BasisByGeneratorsNC( <V>, <vectors> )
#A  SemiEchelonBasisOfDomain( <V> )
#O  SemiEchelonBasisByGenerators( <V>, <vectors> )
#O  SemiEchelonBasisByGeneratorsNC( <V>, <vectors> )
##
DeclareSynonymAttr( "BasisOfDomain", Basis );
DeclareSynonym( "BasisByGenerators", Basis );
DeclareSynonym( "BasisByGeneratorsNC", BasisNC );
DeclareSynonymAttr( "SemiEchelonBasisOfDomain", SemiEchelonBasis );
DeclareSynonym( "SemiEchelonBasisByGenerators", SemiEchelonBasis );
DeclareSynonym( "SemiEchelonBasisByGeneratorsNC", SemiEchelonBasisNC );


#############################################################################
##
#O  NewBasis( <V>[, <gens>] )
##
##  This operation is obsolete.
##  The idea to introduce it was that its methods were allowed to call
##  `Objectify', whereas `Basis' methods were thought to call `NewBasis'.
##
DeclareSynonym( "NewBasis", Basis );


#############################################################################
##
#O  MutableBasisByGenerators( <F>, <gens>[, <zero>] )
##
DeclareSynonym( "MutableBasisByGenerators", MutableBasis );


#############################################################################
##
##  relics of list arithmetic code
##


#############################################################################
##
#M  \*( <emptylist>, <matrix> )
#M  \*( <matrix>, <emptylist> )
##
##  Up to {\GAP}~4.2, this was defined, the result being an empty list.
##  This belonged to the cases `<matlist> * <matrix>' and
##  `<matrix> * <matlist>', with empty <matlist>.
##  (These cases are better dealt with via calls to `List'.)
##  They do not fit to the {\GAP}~4.3 concept for list arithmetic,
##  so they will not be supported in {\GAP}~4.4.
##
InstallOtherMethod( \*,
    [ IsList and IsEmpty, IsMatrix ],
    function( emptylist, matrix )
    Info( InfoWarning, 1,
          "multiplication of an empty list with a matrix\n",
          "#I  will not be supported in GAP 4.4, use 'List' instead" );
    return [];
    end );

InstallOtherMethod( \*,
    [ IsMatrix, IsList and IsEmpty ],
    function( matrix, emptylist )
    Info( InfoWarning, 1,
          "multiplication of a matrix with an empty list\n",
          "#I  will not be supported in GAP 4.4, use 'List' instead" );
    return [];
    end );


#############################################################################
##
#F  IsomorphismTypeFiniteSimpleGroup( <G> )
##
##  *IsomorphismTypeFiniteSimpleGroup is obsolete,
##  use IsomorphismTypeInfoFiniteSimpleGroup instead!*
##
BindGlobal( "IsomorphismTypeFiniteSimpleGroup",
    function( G )
    Info( InfoWarning, 1,
          "'IsomorphismTypeFiniteSimpleGroup' will not be supported",
          " in GAP 4.4,\n",
          "#I  use 'IsomorphismTypeInfoFiniteSimpleGroup' instead" );
    return IsomorphismTypeInfoFiniteSimpleGroup( G );
    end );


#############################################################################
##
#A  WordsTom( <tom> )
##
##  Let <tom> be a table of marks with `IsTableOfMarksWithGens' value `true'.
##  Then `WordsTom' returns a list that contains at position $i$ a list of
##  words in abstract generators that encode generators of a representative
##  of the $i$-th conjugacy class of subgroups of `UnderlyingGroup( <tom> )'.
#T No!
#T These "words" that are in fact wordlists are evaluated by
#T `ResultOfStraightLineProgram'.
##
##  *WordsTom is obsolete, use StraightLineProgramsTom instead!*
##
DeclareAttribute( "WordsTom", IsTableOfMarks );

InstallMethod( WordsTom,
    "for a table of marks with known straight line programs",
    [ IsTableOfMarks and HasStraightLineProgramsTom ],
    function( tom )
    local progs, numgens, wordsfam, flat, proglist, prog, line, j, names,
          result, i;

    Info( InfoWarning, 1,
          "'WordsTom' will not be supported in GAP 4.4,\n",
          "use 'StraightLineProgramsTom' instead" );

    progs:= List( StraightLineProgramsTom( tom ),
                  list -> List( list, LinesOfStraightLineProgram ) );
    numgens:= Length( GeneratorsOfGroup( UnderlyingGroup( tom ) ) );

    # Make a new family.
    wordsfam:= NewFamily( "TomWordsFamily", IsAssocWordWithInverse );

    # Compute the concatenation of occurring words.
    flat:= [];
    for proglist in progs do
      for prog in proglist do
        for line in prog do
          if ForAll( line, IsInt ) then
            UniteSet( flat, line{ [ 1, 3 .. Length( line ) - 1 ] } );
          else
            Error( "only lines of type 1. for WordsTom" );
          fi;
        od;
      od;
    od;

    if IsEmpty( flat ) then
      j:= 0;
    else
      j:= MaximumList( flat ) - numgens;
    fi;
    names:= Concatenation( List( [ 1 .. numgens ],
                                 x -> Concatenation( "g", String( x ) ) ),
                           List( [ 1 .. j ],
                                 x -> Concatenation( "w", String( x ) ) ) );
    StoreInfoFreeMagma( wordsfam, names, IsAssocWordWithInverse );

    # Convert the words into internal representation.
    result:= [];
    for i in [ 1 .. Length( progs ) ] do
      if IsBound( progs[i] ) then
        result[i]:= List( progs[i],
                          x -> List( x, y -> ObjByExtRep( wordsfam, y ) ) );
      fi;
    od;

    # Return the result.
    return result;
    end );


#############################################################################
##
##  Obsolete synonyms, see the functions with names where ``Operation'' is
##  replaced by ``Action''.
##
DeclareSynonym( "RepresentativeOperation", RepresentativeAction );
DeclareSynonym( "RepresentativeOperationOp", RepresentativeActionOp );
DeclareSynonym( "Operation", Action );
DeclareSynonym( "IsOperationHomomorphism", IsActionHomomorphism );
DeclareSynonym( "IsOperationHomomorphismByOperators",
    IsActionHomomorphismByActors);
DeclareSynonym( "IsOperationHomomorphismSubset",
    IsActionHomomorphismSubset);
DeclareSynonym( "IsOperationHomomorphismByBase",
    IsActionHomomorphismByBase);
DeclareSynonym( "IsLinearOperationHomomorphism",
    IsLinearActionHomomorphism);
DeclareSynonymAttr( "FunctionOperation", FunctionAction );
DeclareSynonym( "OperationHomomorphism", ActionHomomorphism );
DeclareSynonymAttr( "OperationHomomorphismAttr", ActionHomomorphismAttr );
DeclareSynonym( "OperationHomomorphismConstructor",
    ActionHomomorphismConstructor);
DeclareSynonymAttr( "SurjectiveOperationHomomorphismAttr",
    SurjectiveActionHomomorphismAttr );
DeclareSynonym( "ImageElmOperationHomomorphism", ImageElmActionHomomorphism );
DeclareSynonym( "SparseOperationHomomorphism", SparseActionHomomorphism );
DeclareSynonym( "SortedSparseOperationHomomorphism",
    SortedSparseActionHomomorphism );


#############################################################################
##
#E

