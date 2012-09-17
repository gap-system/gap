#############################################################################
##
##  io.gd               GAP 4 package IO                    
##                                                           Max Neunhoeffer
##
##  Copyright (C) by Max Neunhoeffer
##  This file is free software, see license information at the end.
##
##  This file contains functions mid level IO providing buffering and
##  easier access from the GAP level. 
##
DeclareInfoClass("InfoIO");
SetInfoLevel(InfoIO, 1);

DeclareCategory( "IsFile", IsObject );
DeclareGlobalVariable( "FileType" );
DeclareAttribute( "ProcessID", IsFile );

BindGlobal( "IO_ResultsFamily", NewFamily( "IO_ResultsFamily" ) );
DeclareCategory( "IO_Result", IsComponentObjectRep );
DeclareGlobalVariable( "IO_Error" );
DeclareGlobalVariable( "IO_Nothing" );
DeclareGlobalVariable( "IO_OK" );
DeclareGlobalVariable( "IO_EOF" );    # End of file marker

DeclareGlobalFunction( "IO_WrapFD" );
DeclareGlobalFunction( "IO_File" );
DeclareGlobalFunction( "IO_Close" );
DeclareGlobalFunction( "IO_ReadUntilEOF" );
DeclareGlobalFunction( "IO_ReadBlock" );
DeclareGlobalFunction( "IO_Read" );
DeclareGlobalFunction( "IO_ReadLine" );
DeclareGlobalFunction( "IO_ReadLines" );
DeclareGlobalFunction( "IO_HasData" );
DeclareGlobalFunction( "IO_ReadyForWrite" );
DeclareGlobalFunction( "IO_ReadyForFlush" );
DeclareGlobalFunction( "IO_Write" );
DeclareGlobalFunction( "IO_WriteFlush" );
DeclareGlobalFunction( "IO_WriteLine" );
DeclareGlobalFunction( "IO_WriteLines" );
DeclareGlobalFunction( "IO_WriteNonBlocking" );
DeclareGlobalFunction( "IO_Flush" );
DeclareGlobalFunction( "IO_FlushNonBlocking" );
DeclareGlobalFunction( "IO_Select" );
DeclareGlobalFunction( "IO_GetFD" );
DeclareGlobalFunction( "IO_GetWBuf" );
DeclareGlobalFunction( "IO_ListDir" );
DeclareGlobalFunction( "IO_MakeIPAddressPort" );
DeclareGlobalFunction( "IO_FindExecutable" );
DeclareGlobalFunction( "IO_Environment" );
DeclareGlobalFunction( "IO_MakeEnvList" );
DeclareGlobalFunction( "IO_CloseAllFDs" );
DeclareGlobalFunction( "IO_ForkExecWithFDs" );
DeclareGlobalFunction( "IO_Popen" );
DeclareGlobalFunction( "IO_Popen2" );
DeclareGlobalFunction( "IO_Popen3" );
DeclareGlobalFunction( "IO_StartPipeline" );
DeclareGlobalFunction( "IO_StringFilterFile" );
DeclareGlobalFunction( "IO_FileFilterString" );
DeclareGlobalFunction( "IO_FilteredFile" );
DeclareGlobalFunction( "IO_SendStringBackground" );
DeclareGlobalFunction( "IO_PipeThroughWithError" );
DeclareGlobalFunction( "IO_PipeThrough" );

DeclareGlobalFunction( "ChangeDirectoryCurrent" );

# This is for other packages to detect whether the I/O package ist loaded:
BindGlobal( "IO_PackageIsLoaded", true );

##
##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation, either version 3 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program.  If not, see <http://www.gnu.org/licenses/>.
##
