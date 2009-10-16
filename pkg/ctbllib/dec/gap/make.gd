##############################################################################
##
#W  make.gd                                                      Thomas Breuer
##
#H  @(#)$Id: make.gd,v 1.2 2007/08/01 11:01:54 gap Exp $
##
#Y  Copyright  (C)  2002,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declarations of the {\GAP} functions that are
##  needed for the automatic construction of the database of decomposition
##  matrices from the {\GAP} character table library.
##
##  In order to create library files, {\GAP} must be called in the directory
##  containing the `gap' and `tex' directories of the database.
##
##  The whole database can be created with `DecMatMakeAll'.
##  The files concerning one specific simple group
##  (including the `index.html' file for the directory of the simple group)
##  can be created with `DecMatMakeGroup'.
##  The file for a fixed upward extension of a fixed simple group and a fixed
##  characteristic can be created with `DecMatMakePage'.
##
##  The names of simple groups, and the names of their Schur covers and
##  automorphism groups are collected by `DecMatNames'.
##  Note that currently not all groups belonging to a simple group can be
##  dealt with, for example some decomposition matrices for the symmetric
##  groups $S_{16}$ and $S_{17}$ are known but the matrices for the
##  corresponding alternating groups and the Schur covers of these groups
##  are missing.
##  So it may be necessary to change the global variables
##  `DecMatSpecialCases' and `DecMatSpecialCases' when new decomposition
##  matrices are to be added.
##
##  The overview table for the main `index.html' file of the database can be
##  created with `DecMatHTMLTableString'.
##


##############################################################################
##
#F  DecMatNames()
##
##  Get the names of all tables of simple groups in the {\GAP} character
##  table library,
##  sort them according to the group order,
##  and get the names of (maximal cyclic factors of) their Schur covers.
##
##  The output of `DecMatNames' is a list of triples where
##  at first position the identifier of the group $G.a$ is stored,
##  at second position the order of $G.a$,
##  and at third position the name of the maximal downward extension
##  $m.G.a$ of the upward extension $G.a$.
##
##  For example, the entry for the simple group $A_5$ is
##  `[ [ "A5", 60, "2.A5" ], [ "A5.2", 120, "2.A5.2" ] ]'.
##
##  The available tables of simple groups in the {\GAP} character table
##  library are listed using `AllCharacterTableNames( IsSimple, true )'.
##
DeclareGlobalFunction( "DecMatNames" );


##############################################################################
##
#F  DecMatHeadingString( <name>, <p> )
##
##  returns a string representing the preamble of the {\LaTeX} file for the
##  <p>-modular decomposition matrices of the upward extension of a simple
##  group with name <name>.
##
DeclareGlobalFunction( "DecMatHeadingString" );


##############################################################################
##
#F  DecMatAppendMatrices( <str>, <decmatspos>, <mtbl>, <ordlabels>,
#F                        <modlabels>, <offset> )
##
##  appends the decomposition matrices ...
##  to the string <str>.
##
DeclareGlobalFunction( "DecMatAppendMatrices" );


##############################################################################
##
#F  DecMatLinesPortions( <entry>, <p> )
##
##  ....
##
DeclareGlobalFunction( "DecMatLinesPortions" );


##############################################################################
##
#F  DecMatInfoString( <linesportions>, <widths>, <divisors> )
##
##  returns ...
##
DeclareGlobalFunction( "DecMatInfoString" );


##############################################################################
##
#F  DecMatTreatSpecialCases( <simple>, <entry>, <p>, <info> )
##
##  ... for $L_3(4)$ and $U_4(3)$
##
DeclareGlobalFunction( "DecMatTreatSpecialCases" );


##############################################################################
##
#F  DecMatMakePage( <entry>, <p>, <dirname> )
##
##  ...
##
DeclareGlobalFunction( "DecMatMakePage" );


##############################################################################
##
#F  DecMatMakeGroup( <entrylist> )
##
##  ...
##
DeclareGlobalFunction( "DecMatMakeGroup" );


##############################################################################
##
#F  DecMatMakeAll( )
#F  DecMatMakeAll( <names> )
#F  DecMatMakeAll( <names>, <from> )
##
##  In the first form, `DecMatMakeAll' calls the second form with argument
##  the output of `DecMatNames'.
##  In the second form, `DecMatMakeAll' calls `DecMatMakeGroup' for each
##  entry in the list <names>.
##  In the second form, `DecMatMakeAll' calls `DecMatMakeGroup' for each
##  entry in the list <names> at position at leat <from>.
##
DeclareGlobalFunction( "DecMatMakeAll" );


##############################################################################
##
#F  DecMatHTMLTableString( <names> )
##
##  returns a string describing a {\HTML} table with 10 columns,
##  the entries being {\HTML} names of those simple groups for which the
##  database contains a directory, each with a crossreference to the
##  directory of the group.
##
DeclareGlobalFunction( "DecMatHTMLTableString" );


#############################################################################
##
#F  DecMatLaTeXStringDecompositionMatrix( <modtbl>[, <blocknr>][, <options>]
#F                                        [, <fblock>] )
##
##  does the same as `LaTeXStringDecompositionMatrix',
##  except that a vertical and horizontal line are inserted if a block of a
##  (noncentral) extension splits into two blocks in the factor group;
##  this is encoded by the optional fourth argument <fblock>.
##
DeclareGlobalFunction( "DecMatLaTeXStringDecompositionMatrix" );


##############################################################################
##
#F  DecMatMakeSym( <Sn>, <p>, <dirname> )
##
##  For a symmetric group with name <Sn> and such that the decomposition
##  matrices reside in the directory <dirname>, the file with the full
##  <p>-modular decomposition matrix (labelled by partitions)
##  is created by `DecMatMakeSym'.
##
DeclareGlobalFunction( "DecMatMakeSym" );


##############################################################################
##
#E

