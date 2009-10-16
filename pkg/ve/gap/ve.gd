#############################################################################
##
#W  ve.gd                   GAP Share Library                    Steve Linton
##
#H  @(#)$Id: ve.gd,v 1.1 1998/03/12 14:56:25 gap Exp $
##
#Y  Copyright (C) 1998,  Lehrstuhl D fuer Mathematik,  RWTH, Aachen,  Germany
##
##  This file contains the declaration part of the interface
##  between {\GAP} and {\VE}.
##
Revision.pkg_ve_gap_ve_gd :=       
    "@(#)$Id: ve.gd,v 1.1 1998/03/12 14:56:25 gap Exp $";


#############################################################################
##
#V  VE  . . . . . . . . . . . global variable used for the interface to {\VE}
##
##  The {\VE} share library uses the global variable `VE' for
##  storing necessary information to call the standalones; intermediate
##  results that are read from files are stored in the component `out'.
##
##  `VE' is a mutable record with components
##
##  `ncols'
##       number of columns to be used in the presentation files
##       (the default value is 80)
##
##  `options'
##       a list of strings, each denoting an option for {\VE}
##       resp.~its value;
##       these options will be used as last ones in each call to 
##       the {\VE} standalone, so may overwrite chosen options,
##       thus you should *not* use `"-o"' in this list.
##       The entries should be among `"-a"', `"-e"', `"-l"', `"-v"'.
##
##  `me'
##       the name of the executable `me'
##
##  `qme'
##       the name of the executable `qme'
##
##  `zme'
##       the name of the executable `zme'
##
##
DeclareGlobalVariable( "VE" );


#############################################################################
##
#F  StringVEInput( <A>, <Mgens>, <names>, <ncols> )  . . . .  input for {\VE}
##
##  takes a finitely presented algebra <A> and submodule generators <Mgens>
##  (a list of row vectors over <A>), a list <names> of names the
##  generators have in the presentation for {\VE}, and the number <ncols>
##  of columns to be used in the output,
##  and returns the string corresponding to the presentation to be input into
##  the vector enumeration program.
##
DeclareGlobalFunction( "StringVEInput" );


#############################################################################
##
#F  VEOutput( <A>, <Mgens>, <options>[, "mtx"] )
##
##  `VEOutput' computes the presentation file for {\VE} using
##  `StringVEInput', calls the {\VE} standalone,
##  and returns the output record.
##
##  This record can be processed further with the method for
##  `OperationAlgebraHomomorphism' that uses {\VE}.
##
DeclareGlobalFunction( "VEOutput" );


#############################################################################
##
#E  ve.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

