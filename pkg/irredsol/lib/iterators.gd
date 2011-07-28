############################################################################
##
##  iterators.gd                 IRREDSOL                  Burkhard Höfling
##
##  @(#)$Id: iterators.gd,v 1.3 2011/04/07 07:58:08 gap Exp $
##
##  Copyright © Burkhard Höfling (burkhard@hoefling.name)
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
DECLARE_IRREDSOL_FUNCTION ("SelectionIrreducibleSolvableMatrixGroups");


############################################################################
##
#F  OrdersAbsolutelyIrreducibleSolvableMatrixGroups(n, q, blockdims, max)
##
##  returns a set. Each entry is a pair [order, count] describing how many
##  groups of that order are in the data base whose minimal block dims are in <blockdims>
##  if max is true, only the maximal solvable groups are counted, if max is
##  false, the non-maximal ones are returned. 
##  To ignore one of the parameters blockdims, max, set it to fail
##  
DECLARE_IRREDSOL_FUNCTION ("OrdersAbsolutelyIrreducibleSolvableMatrixGroups");


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
DECLARE_IRREDSOL_FUNCTION ("IteratorIrreducibleSolvableMatrixGroups");


############################################################################
##
#F  OneIrreducibleSolvableMatrixGroup(<func_1>, <val_1>, ...)
##
##  see the IRREDSOL manual
##  
DECLARE_IRREDSOL_FUNCTION ("OneIrreducibleSolvableMatrixGroup");


############################################################################
##
#F  AllIrreducibleSolvableMatrixGroups(<func_1>, <val_1>, ...)
##
##  see the IRREDSOL manual
##  
DECLARE_IRREDSOL_FUNCTION ("AllIrreducibleSolvableMatrixGroups");


############################################################################
##
#E
##  
