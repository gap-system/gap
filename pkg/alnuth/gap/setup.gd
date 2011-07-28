#############################################################################
##
#W setup.gi             Alnuth -  Kant interface             Andreas Distler
##

#############################################################################
##
#F ChangeGlobalVariable(name, path)
##
DeclareGlobalFunction("ChangeGlobalVariable");

#############################################################################
##
#F SetPariStackSize(size)
##
DeclareGlobalFunction("SetPariStackSize");

#############################################################################
##
#F SetAlnuthExternalExecutable(path)
##
DeclareGlobalFunction("SetAlnuthExternalExecutable");

#############################################################################
##
#F SuitablePariExecutable(path)
##
DeclareGlobalFunction("SuitablePariExecutable");

#############################################################################
##
#F SetAlnuthExternalExecutablePermanently(path)
##
## Changes the file defs.g to set a new default value for AL_EXECUTABLE
##
DeclareGlobalFunction("SetAlnuthExternalExecutablePermanently");

#############################################################################
##
#F RestoreAlnuthExternalExecutablePermanently(path)
##
## restores the original content of the file defs.g
##
DeclareGlobalFunction("RestoreAlnuthExternalExecutablePermanently");

#############################################################################
##
#E