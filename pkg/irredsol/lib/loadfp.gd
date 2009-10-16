############################################################################
##
##  loadfp.gd                    IRREDSOL                 Burkhard Hoefling
##
##  @(#)$Id: loadfp.gd,v 1.4 2005/07/06 10:04:53 gap Exp $
##
##  Copyright (C) 2003-2005 by Burkhard Hoefling, 
##  Institut fuer Geometrie, Algebra und Diskrete Mathematik
##  Technische Universitaet Braunschweig, Germany
##


############################################################################
##
#F  IsAvailableAbsolutelyIrreducibleSolvableGroupFingerprintIndex(<n>, <q>)
##
##  returns true if the fingerprint data index is available
##  
DeclareGlobalFunction ("IsAvailableAbsolutelyIrreducibleSolvableGroupFingerprintIndex");


############################################################################
##
#F  TryLoadAbsolutelyIrreducibleSolvableGroupFingerprintIndex(<n>, <q>)
##
##  tries to load the fingerprint database index file and returns 
##  true if it succeeds, and false otherwise
##  
DeclareGlobalFunction ("TryLoadAbsolutelyIrreducibleSolvableGroupFingerprintIndex");


############################################################################
##
#F  LoadAbsolutelyIrreducibleSolvableGroupFingerprintIndex(<n>, <q>)
##
##  loads the fingerprint database index file
##  
DeclareGlobalFunction ("LoadAbsolutelyIrreducibleSolvableGroupFingerprintIndex");


############################################################################
##
#F  IsAvailableAbsolutelyIrreducibleSolvableGroupFingerprintData(<n>, <q>, <k>)
##
##  returns true if the k-th fingerprint data file for GL(n,q) exists, and
##  false otherwise.
##  
DeclareGlobalFunction ("IsAvailableAbsolutelyIrreducibleSolvableGroupFingerprintData");


############################################################################
##
#F  TryLoadAbsolutelyIrreducibleSolvableGroupFingerprintData(<n>, <q>, <index>)
##
##  tries to load the <index>-th fingerprint data file for subgroups of GL(n,q) 
##  and returns true if it succeeds and false otherwise.
##  
DeclareGlobalFunction ("TryLoadAbsolutelyIrreducibleSolvableGroupFingerprintData");


###########################################################################
##
#F  LoadAbsolutelyIrreducibleSolvableGroupFingerprintData(<n>, <q>, <index>)
##
##  loads the <index>-th fingerprint data file for subgroups of GL(n,q) 
##  The fiongerprint data is a record with entries elms
##  and fps. elms is a set of lists of four integers each.
##  Each entry of elms corresponds to the fingerprint of one conjugacy 
##  class of elements.
##  Each entry of fps is a list with three entries and corresponds to a
##  set of groups having the same fingerprint, F, say. Each entry is a 
##  list with three elements, the first being the group order (i.e., <o>), 
##  The second is a set of integers from [1..Length (elms)], indicating 
##  which entries in elms occur in F. The third is a list of the indices
##  of the gropus having that fingerprint F.
##  
DeclareGlobalFunction ("LoadAbsolutelyIrreducibleSolvableGroupFingerprintData");


###########################################################################
##
#F  LoadAbsolutelyIrreducibleSolvableGroupFingerprints(<arg>)
##
##  see IRREDSOL documentation
##  
DeclareGlobalFunction ("LoadAbsolutelyIrreducibleSolvableGroupFingerprints");


###########################################################################
##
#F  UnloadAbsolutelyIrreducibleSolvableGroupFingerprints(<arg>)
##
##  see IRREDSOL documentation
##  
DeclareGlobalFunction ("UnloadAbsolutelyIrreducibleSolvableGroupFingerprints");


###########################################################################
##
#F  LoadedAbsolutelyIrreducibleSolvableGroupFingerprints(<arg>)
##
##  see IRREDSOL documentation
##  
DeclareGlobalFunction ("LoadedAbsolutelyIrreducibleSolvableGroupFingerprints");


###########################################################################
##
#E
##
