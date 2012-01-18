#############################################################################
##
##  AL_EXECUTABLE
##
##  Here 'AL_EXECUTABLE', the path to the executable of PARI/GP, is set.
##  Depending on the installation of PARI/GP the entrymay have to be changed.
##  See '4.3 Adjust the path of the executable for PARI/GP' for details.
##
if not IsBound(AL_EXECUTABLE) then
    BindGlobal("AL_EXECUTABLE", Filename(DirectoriesSystemPrograms(), "gp"));
fi;
