#############################################################################
##
##  KANTEXEC
##
##  Here 'KANTEXEC', the the name of the executable for KASH, is set. 
##  Depending on the installation of KASH the entry may have to be changed.
##  See '4.3 Adjust the path of the executable for KASH' for details.
##  
if not IsBound( KANTEXEC ) then
    BindGlobal( "KANTEXEC", Filename( DirectoriesSystemPrograms( ), "kash" ) );
fi;
