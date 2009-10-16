#############################################################################
##
#W  cmeataxe.gd        GAP share package 'cmeataxe'             Thomas Breuer
##
#H  @(#)$Id: cmeataxe.gd,v 1.1 2000/04/19 09:06:30 gap Exp $
##
#Y  Copyright (C)  2000,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  The interface to the {\MeatAxe} share package provides
##  1. methods to deal with matrices and permutations that are stored in
##     files, in {\MeatAxe} format,
##  2. methods to deal with $A$-modules for matrix algebras $A$,
##     where the matrices and the module generators are stored in files.
##
##  This file contains the interface between {\GAP} and the {\MeatAxe}.
##
##  Functions that deal with {\MeatAxe} matrices, {\MeatAxe} permutations,
##  {\MeatAxe} matrix algebras, and {\MeatAxe} modules can be found in the
##  files `mamatrix.g', `mapermut.g', `mamatalg.g', `mamodule.g',
##  respectively.
##
Revision.( "cmeataxe/gap/cmeataxe_gd" ) :=
    "@(#)$Id: cmeataxe.gd,v 1.1 2000/04/19 09:06:30 gap Exp $";


############################################################################
##
#V  MeatAxe
##
##  is a record containing relevant information about the usage of MeatAxe
##  under {\GAP}.
##  Currently there are the following components.
##  \beginitems
##  `gennames' &
##      the list of strings that are used as generator names in `abstract'
##      components of C-{\MeatAxe} matrices,
##
##  `alpha' &
##      alphabet ober which `gennames' entries are formed.
##  \enditems
##
##  Besides these, some components will be intermediately bound
##  when C-{\MeatAxe} output files are read.
##
DeclareGlobalVariable( "MeatAxe" );


#############################################################################
##
#F  CMeatAxeProcess( <dir>, <prog>, <output>, <options> )
##
##  `CMeatAxeProcess' executes the C-{\MeatAxe} program <prog> in the
##  directory <dir>.
##  The output is written to the file with name <output>
##  --if no output occurs then <output> should be `OutputTextNone()'--
##  and <options> is a list of options
##  (cf.~"ref:Process" in the {\GAP} Reference Manual).
##
##  Usually <dir> will be the return value of `CMeatAxeDirectoryCurrent'
##  (see~"CMeatAxeDirectoryCurrent").
##
DeclareGlobalFunction( "CMeatAxeProcess" );


#############################################################################
##
#F  CMeatAxeMaketab( <q> )
##
##  For a prime power <q> not exceeding $256$, `CMeatAxeMaketab' causes the
##  creation of the C-{\MeatAxe} information file for the field with <q>
##  elements (`pxxx.zzz', with `xxx' replaced by the string for <q>),
##  via the C-{\MeatAxe} function `maketab'.
##
DeclareGlobalFunction( "CMeatAxeMaketab" );


#############################################################################
##
#F  CMeatAxeSetDirectory( <dir> )
##
##  When the C-{\MeatAxe} package is loaded a temporary directory is created
##  (using `DirectoryTemporary', see~"ref:DirectoryTemporary" in the {\GAP}
##  Reference Manual)
##  that will contain all data files dealt with by the C-{\MeatAxe}
##  standalone programs.
##  {\GAP} will try to *remove this directory* at the end of the {\GAP}
##  session.
##
#T the input must be a directory object, see ...
#T test writability of the directory!
##
DeclareGlobalFunction( "CMeatAxeSetDirectory" );


#############################################################################
##
#F  CMeatAxeDirectoryCurrent()
##
##  `CMeatAxeDirectoryCurrent' returns the directory in which currently those
##  files are created that contain the data of C-{\MeatAxe} objects.
##  The default for this directory is a temporary directory
##  (see~"DirectoryTemporary"); it can be changed using
##  `CMeatAxeSetDirectory' (see~"CMeatAxeSetDirectory").
##
DeclareGlobalFunction( "CMeatAxeDirectoryCurrent" );


#############################################################################
##
#F  CMeatAxeNewFilename()
##
##  `CMeatAxeNewFilename' returns a new filename in the directory
##  `CMeatAxeDirectoryCurrent' (see~"CMeatAxeDirectoryCurrent").
##
DeclareGlobalFunction( "CMeatAxeNewFilename" );


#############################################################################
##
#R  IsCMeatAxeObjRep( <obj> )  . . . . . . . . . is <obj> a {\MeatAxe} object
##
##  The C-{\MeatAxe} package provides alternative representations for
##  matrices and permutations.
##  These objects lie in the representation `IsCMeatAxeObjRep',
##  which is a subrepresentation of `IsAttributeStoringRep'
##  (see~"ref:IsAttributeStoringRep" in the {\GAP} Reference Manual);
##  the objects are immutable (see~"ref:Mutability and Copyability" in the
##  {\GAP} Reference Manual), defining attributes of C-{\MeatAxe} objects are
##  `GapObject' (see~"GapObject") and
##  `CMeatAxeFilename' (see~"CMeatAxeFilename").
##
DeclareRepresentation( "IsCMeatAxeObjRep", IsAttributeStoringRep, [] );


#############################################################################
##
#A  GapObject( <mtxobj> ) . . . . . . {\GAP} object corresponding to <mtxobj>
##
##  For an object <mtxobj> in the representation `IsCMeatAxeObjRep'
##  (see~"IsCMeatAxeObjRep"), `GapObject' returns an object that is equal to
##  <mtxobj> and guaranteed to be *not* in `IsCMeatAxeObjRep'.
##
##  Each `GapObject' method calls `Info' for the class `InfoCMeatAxe'
##  (see~"InfoCMeatAxe"), at info level $1$.
##
DeclareAttribute( "GapObject", IsCMeatAxeObjRep );


#############################################################################
##
#A  CMeatAxeFilename( <mtxobj> )  . . . . . name of the data file of <mtxobj>
##
##  For an object <mtxobj> in the representation `IsCMeatAxeObjRep'
##  (see~"IsCMeatAxeObjRep"), `CMeatAxeFilename' returns the string that is
##  the absolute name of the file containing the data of <mtxobj>.
##
DeclareAttribute( "CMeatAxeFilename", IsCMeatAxeObjRep );


#############################################################################
##
#F  IsCMeatAxePerm( <obj> )
##
##  `IsCMeatAxePerm' is a synonym for the meet of the two filters
##  `IsPerm' and `IsCMeatAxeObjRep' (see~"IsCMeatAxeObjRep").
##  Objects in this filter are permutations that are represented by a file in
##  C-{\MeatAxe} format.
##  These permutations are compatible with {\GAP}'s internally represented
##  permutations, in particular C-{\MeatAxe} permutations can be compared and
##  multiplied with internally represented permutations.
##
##  The default methods for the basic operations for permutations
##  (see~"ref:IsPerm" in the {\GAP} Reference Manual) for C-{\MeatAxe}
##  permutations delegate to the internally represented permutations returned
##  by `GapObject' (see~"GapObject").
##
##  For the following operations, efficient methods (*not* relying on
##  `GapObject') are installed:
##  `ViewObj', `PrintObj' (showing just the filename),
##  `Display' (showing the permutation via the `zpr' program),
##  `Order', `Inverse', `One', and the product of two C-{\MeatAxe}
##  permutations and the power of a C-{\MeatAxe} permutation by an integer.
##
##  C-{\MeatAxe} permutations are constructed by `MeatAxePerm'
##  (see~"MeatAxePerm").
##
DeclareSynonym( "IsCMeatAxePerm", IsPerm and IsCMeatAxeObjRep );


#############################################################################
##
#F  MeatAxePerm( <perm>[, <maxpoint>][, <file>] ) . construct {\MeatAxe} perm
#F  MeatAxePerm( <file> ) . . . . . . . . . . . . . .  notify {\MeatAxe} perm
##
##  In the first form, `MeatAxePerm' returns a C-{\MeatAxe} permutation
##  (see~"IsCMeatAxePerm") that is equal to the permutation <perm>.
##  If a nonnegative integer <maxpoint> is given as second argument then the
##  data file of the result object stores <perm> as permutation on the points
##  up to <maxpoint>; the default for <maxpoint> is the largest moved point
##  of <perm> (see~"ref:LargestMovedPoint" in the {\GAP} Reference Manual).
##  If a string <file> is given as last argument then it denotes the name of
##  the file to which the data of <perm> shall be written;
##  if <file> starts with a slash character `/' then <file> is interpreted as
##  an absolute filename, otherwise as a filename relative to the current
##  C-{\MeatAxe} directory (see~"CMeatAxeDirectoryCurrent");
##  the default for <file> is a new filename in the current C-{\MeatAxe}
##  directory (see~"CMeatAxeFilename").
##
##  In the second form, `MeatAxePerm' returns the C-{\MeatAxe} permutation
##  that is given by the file with absolute name <file>, which is expected
##  to contain a permutation in C-{\MeatAxe} binary format.
##
DeclareGlobalFunction( "MeatAxePerm" );


#############################################################################
##
#E

