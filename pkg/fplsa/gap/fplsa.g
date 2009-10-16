#############################################################################
##
#W  fplsa.g                     GAP library                     Thomas Breuer
##
#H  @(#)$Id: fplsa.g,v 1.6 2003/11/18 08:35:49 gap Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the interface from {\GAP} to the `fplsa4' package
##  by Gerdt and Kornyak.
##
Revision.fplsa_g :=
    "@(#)$Id: fplsa.g,v 1.6 2003/11/18 08:35:49 gap Exp $";


#############################################################################
##
#V  FPLSA
##
##  `FPLSA' is the global record used by the functions in the fplsa package.
##  Besides components that describe parameters, the following are used.
##
##  `progname'
##      the file name of the executable,
##
##  `T'
##      structure constants table of the algebra under consideration,
##
##  `words'
##      list of elements in the free Lie algebra that correspond to the
##      basis elements,
##
##  `rels'
##      list of relators in the free Lie algebra that are used to express
##      redundant algebra generators in terms of the basis.
##
BindGlobal( "FPLSA", rec(
    Relation_size           :=  2500000,
    Lie_monomial_table_size :=  1000000,
    Node_Lie_term_size      :=  2000000,
    Node_scalar_factor_size :=  2000,
    Node_scalar_term_size   :=  20000,

    progname                := "fplsa4"
    ) );


#############################################################################
##
#F  PrintDataFileForFPLSA( <L>, <relators>, <weight>, <file> )
##
BindGlobal( "PrintDataFileForFPLSA", function( L, relators, weight, file )
    local stringword,  # local function, compute bracket notation of list
          nrgens,      # no. of generators of `L'
          i,u,         # loop over `gens' or a word
          rel;         # loop over relators

    stringword:= function( word )
      if IsInt( word ) then
        return Concatenation( "x", String( word ) );
      else
        return Concatenation( "[", stringword( word[1] ),
                              ",", stringword( word[2] ), "]" );
      fi;
    end;

    nrgens:= Length( GeneratorsOfAlgebra( L ) );

    AppendTo( file, "Generators:" );
    for i in [ 1 .. nrgens ] do
      AppendTo( file, " x" );
      AppendTo( file, String( i ) );

     if i < nrgens then
      AppendTo( file, "\n" );
     fi;
    od;
    AppendTo( file, ";\n\n" );
    AppendTo( file, "Weights:" );

    for i in [ 1 .. nrgens ] do
     AppendTo( file, " 1");
    od;

    AppendTo( file, ";\n\n" );
    AppendTo( file, "Limiting weight: " );
    AppendTo( file, String( weight ) );
    AppendTo( file, ";\n" );
    AppendTo( file, "Relations, N = " );
    AppendTo( file, String( Length( relators ) ) );
    AppendTo( file, ":\n" );

    for u in [1..Length(relators)] do
      rel:= relators[u];
      rel:= ExtRepOfObj( rel )[2];
      for i in [ 2, 4 .. Length( rel ) ] do
        if rel[i] < 0 then
          if rel[i] = -1 then
            AppendTo( file, "-" );
          else
            AppendTo( file, String( rel[i] ) );
            AppendTo( file, " " );
          fi;
        else
          if i <> 2 then
            AppendTo( file, "+" );
          fi;
          if rel[i] <> 1 then
            AppendTo( file, String( rel[i] ) );
            AppendTo( file, " " );
          fi;
        fi;
        AppendTo( file, stringword( rel[ i-1 ] ) );
        #AppendTo( file, "\n");
      od;
      if u <> Length( relators ) then
        AppendTo( file, ";\n" );
      fi;
    od;
    AppendTo( file, "." );
    end );


#############################################################################
##
#F  PrintInitFileForFPLSA( <filename>, <nrgens>, <table>, <words>, <rels>,
#F                         <tmpdir> )
##
##  produces an initialization file <filename> for an algebra with <nrgens>
##  generators.
##  <table> and <words> are booleans.
##  If <table> is `true' then the s.c. table of the result is output.
##  If <words> is `true' then the words in the f.p. algebra corresponding to
##  the basis elements of the result are output.
##  If <rels> is `true' then the reduced relations are output.
##
BindGlobal( "PrintInitFileForFPLSA",
    function( filename, nrgens, table, words, rels, tmpdir )

    if table then table:= "Yes"; else table:= "No"; fi;
    if words then words:= "Yes"; else words:= "No"; fi;
    if rels  then rels := "Yes"; else rels := "No"; fi;

    PrintTo( filename,

    "Crude time : No\n",
    "Echo input file : No\n",
    "Put program heading       : No\n",
    "Put initial relations     : No\n",  # <* Print read relations *>
    "Put reduced relations     : No\n",
    "Put basis elements        : No\n",  # <* Print basis of algebra *>
    "Put commutators           : No\n",  # <* Print non-zero commutators *>
    "Put Hilbert series        : No\n",  # <* Print dimensions of
                                         #    homogeneous components *>
    "Put non-zero coefficients : No\n",  # <* Print table of non-zero
                                         #    parametric coefficients *>
    "Put statistics            : No\n",
    "Left normed output        : No\n",  # <* Left normed notation for Lie
                                         #    monomials, otherwise standard
                                         #    bracket notation *>
    "GAP output basis       : ",         # <* Convey basis words of ordinary
    words, "\n",                         #    finite-dimensional Lie algebra
                                         #    to GAP *>
    "GAP output commutators : ",         # <* Convey commutator table of
    table, "\n",                         #    ordinary finite-dimensional
                                         #    Lie algebra to GAP *>
    "GAP output relations   : ",         # <* Convey relations of ordinary
    rels, "\n",                          #    finite-dimensional Lie algebra
                                         #    to GAP *>
    "GAP algebra name : FPLSA.T\n",      # <* Name of algebra
                                         #    conveyed to GAP *>
    "GAP basis name   : FPLSA.words\n",  # <* Name of basis words list
                                         #    conveyed to GAP *>
    "GAP relations name : FPLSA.rels\n", # <* Name of relations conveyed
                                         #    to GAP *>
    "Coefficient sum table size : 16\n", # <* Size of table for\n",
                                         #    non-zero parametric sums *>
    "Generator max. number   :   ",      # <* Max. no. of input generators *>
    nrgens, "\n",
    "Input integer size      :   32\n",  # <* Maximum number of LIMBs
                                         #    for input integers *>
    "Input string size       :  8192\n",  # <* String for reading input
                                         #    portion *>
    "Line length             :   76\n",  # <* Width of 2D output page *>
    "Name length             :    ",     # <* Max. length of object name *>
    LogInt( nrgens, 10 ) + 2, "\n",
    "Relation size           :  ",       # <* Size of array Relation *>
    FPLSA.Relation_size, "\n",
    "Lie monomial table size :  ",
    FPLSA.Lie_monomial_table_size, "\n",
    "Node Lie term size      :  ",       # <* Size of pool NodeLT for Lie
    FPLSA.Node_Lie_term_size, "\n",      #    term nodes *>
    "Node scalar factor size :  ",       # <* Size of pool NodeSF
    FPLSA.Node_scalar_factor_size, "\n", #    for scalar factor nodes *>
    "Node scalar term size   : ",        # <* Size of pool NodeST
    FPLSA.Node_scalar_term_size, "\n",   #    for scalar term nodes *>
    "OutLine size            :  256\n",  # <* String for preparing 2D
                                         #    output portion *>
    "Parameter max. number   :   0\n",   # <* Max. no. of input parameters *>
    "Even basis symbol : E\n",           # <* Even basis element name *>
    "Odd basis symbol  : O\n",           # <* Odd basis element name *>
    "Input directory : ", Filename(tmpdir,""), "\n",
                                         # <* Directory containing input
                                         #files *>
    "" );
    end );


#############################################################################
##
#F  SCAlgebraInfoOfFpLieAlgebra( <L>, <relators>, <limit_weight>,
#F                               <words>, <rels> )
##
##  computes a s.c. algebra isomorphic to the Lie algebra `<L> / <relators>'
##  if this is possible using Lie monomials of length at most <limit_weight>.
##
##  The function calls the external program `fplsa4'.
##
##  <L> must be a free Lie algebra, <relators> a list of elements in <L>,
##  <limit_weight> a positive integer.
##
##  <words> is a boolean, if it is `true' then a list of elements in <L>
##  is constructed that correspond to the basis elements.
##
##  <rels> is a boolean, if it is `true' then a list of reduced relators in
##  <L> is constructed that describes how algebra generators are expressed
##  in terms of the basis elements if they are not themselves basis elements.
##
BindGlobal( "SCAlgebraInfoOfFpLieAlgebra",
    function( L, relators, limitweight, words, rels )
    local progname,     # filename of the executable
          tmpdir,       # directory in that the standalone is called
          inputfile,    # file with input
          inifile,      # file with parameter definitions
          output,       # output file
          proc,         # process to be run
          info,         # result record
          Fam;          # elements family of the algebra

    # Check that `L' is a Lie algebra over the rationals.
    if not (     IsLieAlgebra( L )
             and IsMagmaRingModuloRelations( L )
             and LeftActingDomain( L ) = Rationals ) then
      Error( "<L> must be a free Lie algebra over the rationals" );
    fi;

    # Choose the executable of the standalone.
    progname:= Filename( DirectoriesPackagePrograms( "fplsa" ),
                         FPLSA.progname );
    if progname = fail then
      Error( "did not find the executable" );
    fi;

    # Write the file with the data.
    tmpdir:= DirectoryTemporary();
    inputfile:= Filename( tmpdir, "input" );

    PrintDataFileForFPLSA( L, relators, limitweight, inputfile );

    # Write the file with options.
    inifile:= Filename( tmpdir, Concatenation( FPLSA.progname, ".ini" ) );
    PrintInitFileForFPLSA( inifile, Length( GeneratorsOfAlgebra( L ) ),
                           true, words, rels, tmpdir );

    # Call the standalone function.
    output:= OutputTextFile( Filename( tmpdir, "output" ), false );
    proc:= Process( tmpdir,
             progname,
             InputTextNone(),
             output,
             [ "input" ] );
    CloseStream( output );

    if proc <> 0 then
      Error( "process did not succeed" );
    fi;

    # Read the output file.
    Unbind( FPLSA.T );
    Unbind( FPLSA.words );
    Unbind( FPLSA.rels );
    Read( Filename( tmpdir, "output" ) );

    # Check whether the maximal weight was big enough to compute
    # a finite dimensional Lie algebra.
    if not IsBound( FPLSA.T ) then
      return fail;
    fi;

    # Construct and return the algebra.
    info:= rec( sc:= LieAlgebraByStructureConstants( Rationals, FPLSA.T ) );
    if words then
      Fam:= ElementsFamily( FamilyObj( L ) );
      info.words:= List( FPLSA.words,
                         w -> ObjByExtRep( Fam, [ 0, [ w, 1 ] ] ) );
    fi;
    if rels then
      Fam:= ElementsFamily( FamilyObj( L ) );
      info.rels:= List( FPLSA.rels,
                         w -> ObjByExtRep( Fam, [ 0, w ] ) );
    fi;

    return info;
    end );


#############################################################################
##
#F  IsomorphicSCAlgebra( <K>[ ,<bound>] )
##
##  computes a s.c. algebra isomorphic to the finitely presented
##  Lie algebra <K>.
##  If the optional parameter <bound> is specified the computation will
##  be carried out using monomials of degree at most <bound>.
##  If <bound> is not specified, then it will initially be set to
##  10000. If this does not suffice to calculate a multiplication tabel
##  of the algebra, then the bound will be increased until a multiplication
##  table is found.
##
##  If the computation was succesful a structure constants algebra
##  will be returned isomorphic to <K>. Otherwise `fail'
##  will be returned.
##
BindGlobal( "IsomorphicSCAlgebra", function( arg )
    local K,      # fp Lie algebra
          bound,  # bound on the degree of the monomials in the calculation
          fam,    # elements family of K
          L,      # free Lie algebra corresponding to K
          rels,   # relators corresponding to K
          sca;    # structure constants algebra.

    if Length( arg ) = 1 and IsSubalgebraFpAlgebra( arg[1] ) then
      K:= arg[ 1 ];
      bound:= "infinity";
    elif Length( arg ) = 2 and IsSubalgebraFpAlgebra( arg[1] ) and
         IsPosInt( arg[2] ) then
      K:= arg[1];
      bound:= arg[2];
    else
      Error( "usage: IsomorphicSCAlgebra( <K> [,<bound>] ),\n",
             "where <K> is a f.p. Lie algebra and <bound> a pos. integer" );
    fi;

    fam:= ElementsFamily( FamilyObj( K ) );
    L:= fam!.freeAlgebra;
    rels:= fam!.relators;

    if IsPosInt( bound ) then
      sca:= SCAlgebraInfoOfFpLieAlgebra( L, rels, bound, false, false );
      if sca = fail then
        return sca;
      else
        return sca.sc;
      fi;
    else
      bound:= 10000;
      while true do
        sca:= SCAlgebraInfoOfFpLieAlgebra( L, rels, bound, false, false );
        if sca <> fail then
          return sca.sc;
        else
          bound:= bound + 1000;
        fi;
      od;
    fi;
    end );


#############################################################################
##
#E

