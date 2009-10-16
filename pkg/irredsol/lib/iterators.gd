############################################################################
##
##  iterators.gd                 IRREDSOL                 Burkhard Hoefling
##
##  @(#)$Id: iterators.gd,v 1.2 2005/02/14 12:19:40 gap Exp $
##
##  Copyright (C) 2003-2005 by Burkhard Hoefling, 
##  Institut fuer Geometrie, Algebra und Diskrete Mathematik
##  Technische Universitaet Braunschweig, Germany
##


############################################################################
##
#F  SelectionIrreducibleSolvableMatrixGroups(n, q, d, indices, orders, blockdims, max)
##
##  selects the subset of <indices> corresponding to those irreducible 
##  matrix gropus whose orders are in <orders>, whose minimal block dims are in 
##  <blockdims>. if max is true and d = 1, only the maximal solvable groups are returned,
##  if max is false, the non-maximal ones are returned. 
##  To ignore one of the parameters orders, blockdims, max, set it to fail
##  If <indices> is fail, all groups are considered.
##  
DeclareGlobalFunction ("SelectionIrreducibleSolvableMatrixGroups");


############################################################################
##
#F  MaximalAbsolutelyIrreducibleSolvableMatrixGroup(<n>, <q>, <k>)
##
##  see the IRREDSOL manual
##  
DeclareGlobalFunction ("OrdersAbsolutelyIrreducibleSolvableMatrixGroups");


############################################################################
##
#F  CheckAndExtractArguments(specialfuncs, checks, argl, caller)
##
##  This function tests whether argl is a list of even length in which the 
##  entries at odd positions are functions.
##  For special functions in this list (each entry in specialfuncs is a list of synonyms
##  of such functions) it tests whether the following entry in argl satisfies the 
##  function in checks corresponding to specailfunc, and that each specialfunc
##  only occurs once (including synonyms).
##
##  The function returns a record with entries specialvalues, functions, and values.
##  if specialvalues[i] is bound, it was the entry following a function in 
##  specialfuncs[i]. The functions at odd positions in argl but not in specialfuncs 
##  are returned in the record entry functions,
##  the following entries in argl are in the record entry values.
##
DeclareGlobalFunction ("CheckAndExtractArguments");


############################################################################
##
#F  IteratorIrreducibleSolvableMatrixGroups(<func_1>, <val_1>, ...)
##
##  see the IRREDSOL manual
##  
DeclareGlobalFunction ("IteratorIrreducibleSolvableMatrixGroups");


############################################################################
##
#F  OneIrreducibleSolvableMatrixGroup(<func_1>, <val_1>, ...)
##
##  see the IRREDSOL manual
##  
DeclareGlobalFunction ("OneIrreducibleSolvableMatrixGroup");


############################################################################
##
#F  AllIrreducibleSolvableMatrixGroups(<func_1>, <val_1>, ...)
##
##  see the IRREDSOL manual
##  
DeclareGlobalFunction ("AllIrreducibleSolvableMatrixGroups");


############################################################################
##
#E
##  
