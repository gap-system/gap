#############################################################################
##
##  iohub.gd               GAP 4 package IO                    
##                                                           Max Neunhoeffer
##
##  Copyright (C) by Max Neunhoeffer
##  This file is free software, see license information at the end.
##
##  This file contains declarations for a generic client server framework 
##  for GAP
##
##  Main points:
##
##   - handle multiple connections using IO multiplexing
##   - single threaded
##   - use pickling for data transfer
##

BindGlobal( "IOHubFamily", NewFamily("IOHubFamily") );
DeclareCategory( "IsIOHubCat", IsComponentObjectRep );
DeclareRepresentation( "IsIOHub", IsIOHubCat,
  [ "inqueue", "outqueue", "sock", "connections",
    "tosend", "torecv", "inbuf", "outbuf" ] );
DeclareOperation( "IOHub", [] );
BindGlobal( "IOHubType", NewType(IOHubFamily, IsIOHub) );
DeclareOperation( "CloseConnection", [IsIOHub, IsPosInt] );
DeclareOperation( "ShutdownServingSocket", [IsIOHub] );
DeclareOperation( "Shutdown", [IsIOHub] );
DeclareOperation( "AttachServingSocket", [IsIOHub, IsStringRep, IsPosInt] );
DeclareOperation( "NewConnection", [IsIOHub, IsInt, IsInt] );
DeclareOperation( "AcceptNewConnection", [IsIOHub] );
DeclareOperation( "GetInput", [IsIOHub, IsInt] );
DeclareOperation( "SubmitOutput", [IsIOHub, IsPosInt, IsStringRep] );
DeclareOperation( "OutputQueue", [IsIOHub] );
DeclareOperation( "InputQueue", [IsIOHub] );
DeclareOperation( "DoIO", [IsIOHub, IsBool] );
DeclareOperation( "DoIO", [IsIOHub] );
DeclareOperation( "NewTCPConnection", [IsIOHub, IsStringRep, IsPosInt] );
DeclareOperation( "StoreLenIn8Bytes", [IsStringRep, IsInt] );
DeclareOperation( "GetLenFrom8Bytes", [IsStringRep] );

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
