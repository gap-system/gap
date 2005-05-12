##############################################################################
##
#W  unknown.gd                 GAP Library                   Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file declares the operations for unknowns.
##
Revision.unknown_gd :=
    "@(#)$Id$";


#############################################################################
#1
##  Sometimes the result of an operation does not allow further
##  computations with it.
##  In many cases, then an error is signalled,
##  and the computation is stopped.
##  
##  This is not appropriate for some applications in character theory.
##  For example, if one wants to induce a character of a group to a
##  supergroup (see~"InducedClassFunction") but the class fusion is only a
##  parametrized map (see Chapter~"Maps Concerning Character Tables"),
##  there may be values of the induced character which are determined by the
##  fusion map, whereas other values are not known.
##
##  For this and other situations, {\GAP} provides the data type *unknown*.
##  An object of this type, further on called an *unknown*,
##  may stand for any cyclotomic (see Chapter~"Cyclotomic Numbers"),
##  in particular its family (see~"Families") is `CyclotomicsFamily'.
##  
##  Unknowns are parametrized by positive integers.
##  When a {\GAP} session is started, no unknowns exist.
##  
##  The only ways to create unknowns are to call the function `Unknown'
##  or a function that calls it,
##  or to do arithmetical operations with unknowns.
##  
##  {\GAP} objects containing unknowns will contain *fixed* unknowns
##  when they are printed to files, i.e.,
##  function calls `Unknown( <n> )' instead of `Unknown()'.
##  So be careful to read files printed in different {\GAP} sessions,
##  since there may be the same unknown at different places.
##  
##  The rest of this chapter contains information about the unknown
##  constructor, the category,
##  and comparison of and arithmetical operations for unknowns;
##  more is not known about unknowns in {\GAP}.
##  


#############################################################################
##
#2
##  Unknowns can be *compared* via `=' and `\<' with all cyclotomics
##  and with certain other {\GAP} objects (see~"Comparisons").
##  We have `Unknown( <n> ) >= Unknown( <m> )' if and only if `<n> >= <m>'
##  holds; unknowns are larger than all cyclotomics that are not unknowns.


#############################################################################
##
#3
##  The usual arithmetic operations `+', `-', `*' and `/' are defined for
##  addition, subtraction, multiplication and division of unknowns and
##  cyclotomics.
##  The result will be a new unknown except in one of the following cases.
##
##  Multiplication with zero yields zero,
##  and multiplication with one or addition of zero yields the old unknown.
##  *Note* that division by an unknown causes an error, since an unknown
##  might stand for zero.
##
##  As unknowns are cyclotomics, dense lists of unknowns and other
##  cyclotomics are row vectors and
##  they can be added and multiplied in the usual way.
##  Consequently, lists of such row vectors of equal length are (ordinary)
##  matrices (see~"IsOrdinaryMatrix").


#############################################################################
##
#C  IsUnknown( <obj> )
##
##  is the category of unknowns in {\GAP}.
##
DeclareCategory( "IsUnknown", IsCyclotomic );
    
    
#############################################################################
##
#V  LargestUnknown  . . . . . . . . . . . . largest used index for an unknown
##
##  `LargestUnknown' is the largest <n> that is used in any `Unknown( <n> )'
##  in the current {\GAP} session.
##  This is used in `Unknown' which increments this value when asked to make
##  a new unknown.
##
LargestUnknown := 0;


#############################################################################
##
#O  Unknown()
#O  Unknown( <n> )
##
##  In the first form `Unknown' returns a new unknown value, i.e., the first
##  one that is larger than all unknowns which exist in the current {\GAP}
##  session.
##
##  In the second form `Unknown' returns the <n>-th unknown;
##  if it did not exist yet, it is created.
##
DeclareOperation( "Unknown", [] );
DeclareOperation( "Unknown", [ IsPosInt ] );


#############################################################################
##
#E

