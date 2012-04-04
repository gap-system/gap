#############################################################################
##
##  iohub.gd               GAP 4 package IO                    
##                                                           Max Neunhoeffer
##
##  Copyright (C) by Max Neunhoeffer
##  This file is free software, see license information at the end.
##
##  This file contains functions for a generic client server framework 
##  for GAP
##
##  Main points:
##
##   - handle multiple connections using IO multiplexing
##   - single threaded
##   - use pickling for data transfer
##

InstallMethod( IOHub, "constructor without arguments", [ ],
  function( )
    local s;
    s := rec( sock := fail, inqueue := [], outqueue := [],
              tosend := [], torecv := [], inbuf := [], outbuf := [], 
              connections := [], isactive := true ) ;
    Objectify(IOHubType, s);
    return s;
  end );

InstallMethod( AttachServingSocket, "for an address and a port",
  [ IsIOHub, IsStringRep, IsPosInt ],
  function( s, address, port )
    s!.sock := IO_socket(IO.PF_INET,IO.SOCK_STREAM,"tcp");
    if s!.sock = fail then return fail; fi;
    IO_setsockopt(s!.sock,IO.SOL_SOCKET,IO.SO_REUSEADDR,"\001\001\001\001");
    if IO_bind(s!.sock,IO_MakeIPAddressPort(address,port)) = fail then
        IO_close(s!.sock);
        s!.sock := fail;
        return fail;
    fi;
    if not(IO_listen(s!.sock,5)) then
        IO_close(s!.sock);
        s!.sock := fail;
        return fail;
    fi;
    return s!.sock;
  end );

InstallMethod( CloseConnection, "for an IO hub and a positive integer",
  [ IsIOHub, IsPosInt ],
  function( s, nr )
    # First remove all entries in the queue from or for this connection:
    local i;
    if not(IsBound(s!.connections[nr])) then
        return fail;
    fi;
    if IsBound(s!.connections[nr][1]) then
        i := 1;
        while i <= Length(s!.inqueue) do
            if s!.inqueue[i][1] = nr then
                Remove(s!.inqueue[i]);
            else
                i := i + 1;
            fi;
        od;
        IO_close(s!.connections[nr][1]);
    fi;
    if IsBound(s!.connections[nr][2]) then
        i := 1;
        while i <= Length(s!.outqueue) do
            if s!.outqueue[i][1] = nr then
                Remove(s!.outqueue[i]);
            else
                i := i + 1;
            fi;
        od;
        IO_close(s!.connections[nr][2]);
    fi;
    Unbind(s!.connections[nr]);
    Unbind(s!.tosend[nr]);
    Unbind(s!.torecv[nr]);
    Unbind(s!.inbuf[nr]);
    Unbind(s!.outbuf[nr]);
    Print("Connection #",nr," closed.\n");
  end );

InstallMethod( ShutdownServingSocket, "for an IO hub",
  [IsIOHub],
  function(s)
    if s!.sock <> fail then 
        IO_close(s!.sock);
        s!.sock := fail;
    fi;
  end );

InstallMethod( Shutdown, "for an IO hub",
  [ IsIOHub ],
  function( s )
    local i;
    if not(s!.isactive) then return; fi;
    for i in [1..Length(s!.connections)] do
        CloseConnection(s,i);
    od;
    ShutdownServingSocket(s);
    s!.isactive := false;
  end );

InstallMethod( ViewObj, "for a tcp server",
  [ IsIOHub ],
  function( s )
    local nr;
    if s!.isactive then
        Print("<IO hub");
        if s!.sock <> fail then
            Print(" with serving socket");
        fi;
        nr := Number([1..Length(s!.connections)],
                     i->IsBound(s!.connections[i]) and 
                        IsBound(s!.connections[i][1]));
        if nr > 0 then
            Print(", reading from ",nr," fds");
        fi;
        nr := Number([1..Length(s!.connections)],
                     i->IsBound(s!.connections[i]) and 
                        IsBound(s!.connections[i][2]));
        if nr > 0 then
            Print(", writing to ",nr," fds");
        fi;
        Print(">");
    else
        Print("<IO hub already shut down>");
    fi;
  end );

InstallMethod( NewConnection, "for an IO hub and two integers",
  [ IsIOHub, IsInt, IsInt ],
  function( s, inp, out )
    local i,l;
    if not(s!.isactive) then return fail; fi;
    i := Length(s!.connections)+1;   # do not reuse old connection numbers
    l := [];
    if inp > 0 then l[1] := inp; fi;
    if out > 0 then l[2] := out; fi;
    s!.connections[i] := l;
    s!.tosend[i] := 0;
    s!.torecv[i] := 0;
    s!.inbuf[i] := EmptyString(8);
    s!.outbuf[i] := "";
    return i;
  end );

InstallMethod( NewTCPConnection, "for an IO hub, an address and a port",
  [ IsIOHub, IsStringRep, IsPosInt ],
  function( s, address, port )
    local t;
    t := IO_socket(IO.PF_INET,IO.SOCK_STREAM,"tcp");
    if IO_connect(t,IO_MakeIPAddressPort(address,port)) = fail then 
        IO_close(t); 
        return fail; 
    fi;
    return NewConnection(s,t,t);
  end );

InstallMethod( AcceptNewConnection, "for an IO hub",
  [ IsIOHub ],
  function( s )
    local t,i;
    if not(s!.isactive) or not(IsBound(s!.sock)) then
        return fail;
    fi;
    t := IO_accept(s!.sock,IO_MakeIPAddressPort("0.0.0.0",0));
    i := NewConnection( s, t, t );
    Print("Got new connection #",i,"...\n");
    return i;
  end );

InstallMethod( GetInput, "for an IO hub and an integer",
  [ IsIOHub, IsInt ],
  function( s, i )
    local p;
    if not(s!.isactive) then return fail; fi;
    if i = 0 then  # get something from any connection
        if Length(s!.inqueue) = 0 then
            return false;
        else
            return Remove(s!.inqueue,1);
        fi;
    else
        p := 1;
        while p <= Length(s!.inqueue) and s!.inqueue[p][1] <> i do
            p := p + 1;
        od;
        if p > Length(s!.inqueue) then
            return false;
        else
            return Remove(s!.inqueue,p);
        fi;
    fi;
  end );

InstallMethod( SubmitOutput, "for an IO hub, a positive integers and an obj",
  [ IsIOHub, IsPosInt, IsStringRep ],
  function( s, i, o )
    if not(IsBound(s!.connections[i]) and IsBound(s!.connections[i][2])) then
        Error("This connection is closed or has no output");
        return fail;
    fi;
    Add(s!.outqueue,[i,o]);
    return true;
  end );

InstallMethod( OutputQueue, "for an IO hub",
  [ IsIOHub ],
  function( s ) return s!.outqueue; end );

InstallMethod( InputQueue, "for an IO hub",
  [ IsIOHub ],
  function( s ) return s!.inqueue; end );

InstallMethod( StoreLenIn8Bytes, "for a string and a len",
  [IsStringRep, IsInt],
  function( st, len )
    local c,i;
    for i in [1..8] do
      c := len mod 256;
      st[i] := CHAR_INT(c);
      len := (len - c) / 256;
    od;
  end );

InstallMethod( GetLenFrom8Bytes, "for a string",
  [IsStringRep],
  function( st )
    local len,i;
    len := 0;
    for i in [8,7..1] do
        len := len * 256 + INT_CHAR(st[i]);
    od;
    return len;
  end );

InstallMethod( DoIO, "for an IO hub", [ IsIOHub ],
  function( s ) return DoIO(s,false); end );

InstallMethod( DoIO, "for an IO hub and a boolean",
  [ IsIOHub, IsBool ],
  function( s, block )
    # This uses select to see to all open connections including the
    # original socket to perform all possible IO on them. New connections
    # are created if needed and those to which network connectivity is
    # lost are closed.
    # Note that this does not automatically call the worker on the input
    # queue.
    # However, it does serve the output queue.
    local activity,bytes,hadactivity,i,infds,inptab,j,len,nr,outfds,outtab,st;

    if not(s!.isactive) then return fail; fi;

    hadactivity := false;
    repeat   
        activity := false;
        # First we check whether some output from the queue has to be sent:
        j := 1;
        while j <= Length(s!.outqueue) do
            i := s!.outqueue[j][1];
            if s!.tosend[i] = 0 then   # idle
                st := Concatenation("00000000",s!.outqueue[j][2]);
                # the first 8 will be the length
                len := Length(st);
                StoreLenIn8Bytes(st,len-8);
                s!.outbuf[i] := st;
                s!.tosend[i] := len;
                Remove(s!.outqueue,j);
            else
                j := j + 1;
            fi;
        od;

        # Now do a select:
        infds := EmptyPlist(Length(s!.connections)+1);
        outfds := EmptyPlist(Length(s!.connections));
        inptab := EmptyPlist(Length(s!.connections)+1);
        outtab := EmptyPlist(Length(s!.connections));
        for i in [1..Length(s!.connections)] do
            if IsBound(s!.connections[i]) then
                if IsBound(s!.connections[i][1]) then
                    Add(infds,s!.connections[i][1]);
                    Add(inptab,i);
                fi;
                if IsBound(s!.connections[i][2]) and s!.tosend[i] <> 0 then
                    Add(outfds,s!.connections[i][2]);
                    Add(outtab,i);
                fi;
            fi;
        od;
        if s!.sock <> fail then
            Add(infds,s!.sock);
            Add(inptab,0);
        fi;
        if block and not(hadactivity) then
            nr := IO_select(infds,outfds,[],false,false);
        else
            nr := IO_select(infds,outfds,[],0,0);
        fi;
        if nr > 0 then
            # Look for possible output first:
            for j in [1..Length(outfds)] do
                if outfds[j] <> fail then
                    activity := true;
                    i := outtab[j];
                    bytes := IO_write(s!.connections[i][2],s!.outbuf[i],
                                      Length(s!.outbuf[i])-s!.tosend[i],
                                      s!.tosend[i]);
                    if bytes <= 0 then   # an error
                        CloseConnection(s,i);
                        # maybe we want to have a callback here!
                    else
                        s!.tosend[i] := s!.tosend[i] - bytes;
                        if s!.tosend[i] = 0 then
                            Unbind(s!.outbuf[i]);
                        fi;
                    fi;
                fi;
            od;
            # Now look for possible inputs next:
            # We need to remember that some connections might already
            # me closed by the output routine above!
            for j in [1..Length(infds)] do
                if infds[j] <> fail then
                    activity := true;
                    i := inptab[j];
                    if i = 0 then
                        AcceptNewConnection(s);
                    else
                        if IsBound(s!.connections[i]) then
                            if s!.torecv[i] = 0 then   # read length
                                bytes := IO_read(s!.connections[i][1],
                                   s!.inbuf[i],Length(s!.inbuf[i]),
                                   8-Length(s!.inbuf[i]));
                                if bytes <= 0 then   # an error
                                    CloseConnection(s,i);
                                    # maybe we want to have a callback here!
                                    continue;
                                fi;
                                if Length(s!.inbuf[i]) = 8 then
                                    s!.torecv[i]:=GetLenFrom8Bytes(s!.inbuf[i]);
                                    s!.inbuf[i] := EmptyString(s!.torecv[i]);
                                fi;
                            else   # we are in the reading process
                                bytes := IO_read(s!.connections[i][1],
                                   s!.inbuf[i],Length(s!.inbuf[i]),
                                   s!.torecv[i]-Length(s!.inbuf[i]));
                                if bytes <= 0 then   # an error
                                    CloseConnection(s,i);
                                    # maybe we want to have a callback here!
                                    continue;
                                fi;
                                if Length(s!.inbuf[i]) = s!.torecv[i] then
                                    Add(s!.inqueue,[i,s!.inbuf[i]]);
                                    s!.torecv[i] := 0;
                                    s!.inbuf[i] := EmptyString(8);
                                fi;
                            fi;
                        fi;
                    fi;
                fi;
            od;
        fi;
        if activity then hadactivity := true; fi;
    until activity = false;
    return hadactivity;
  end );


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
