#############################################################################
##
##  http.gi               GAP 4 package IO  
##                                                            Max Neunhoeffer
##
##  Copyright (C) by Max Neunhoeffer
##  This file is free software, see license information at the end.
##
##  This file contains functions implementing the client side of the
##  HTTP protocol.
##

# The following is given as argument to IO_Select for the timeout
# values in a HTTP request.

InstallValue( HTTPTimeoutForSelect, [fail,fail] );

InstallGlobalFunction( OpenHTTPConnection,
  function(server,port)
    local lookup,res,s;
    s := IO_socket(IO.PF_INET,IO.SOCK_STREAM,"tcp");
    if s = fail then 
        return rec( sock := fail,
                    errormsg := "OpenHTTPConnection: cannot create socket" );
    fi;
    lookup := IO_gethostbyname(server);
    if lookup = fail then
        IO_close(s);
        return rec( sock := fail,
                    errormsg := "OpenHTTPConnection: cannot find hostname" );
    fi;
    res := IO_connect(s,IO_make_sockaddr_in(lookup.addr[1],port));
    if res = fail then
        IO_close(s);
        return rec( sock := fail,
                    errormsg := 
                      Concatenation("OpenHTTPConnection: cannot connect: ",
                                    LastSystemError().message) );
    fi;
    # Switch the socket to non-blocking mode, just to be sure!
    IO_fcntl(s,IO.F_SETFL,IO.O_NONBLOCK);

    return rec( sock := IO_WrapFD(s,false,false), 
                errormsg := "",
                host := lookup,
                closed := false );
  end );

InstallGlobalFunction( FixChunkedBody,
  function( st )
    # This parses a chunked body and returns the final result resulting
    # from putting together the chunks. Follows rfc2616, section 3.6.1.
    # If anything goes wrong, the original is returned.
    local chunklen,head,p,pos,q,res;
    pos := 0;
    res := [];
    while true do   # will return eventually 
        p := PositionSublist(st,"\r\n",pos);
        if p = fail then
            break;
        fi;
        head := st{[pos+1..p]};
        pos := p+1;
        q := 1;
        while q <= Length(head) and head[q] in "0123456789ABCDEFabcdef" do
            q := q + 1;
        od;
        chunklen := IntHexString(head{[1..q-1]});
        if chunklen = 0 then    # this was the last chunk
            break;
        else
            Add(res,st{[pos+1..pos+chunklen]});
            pos := pos + chunklen + 2;    # eat up CR and LF
        fi;
    od;
    if Length(res) > 0 then 
        return Concatenation(res);
    else
        return st;
    fi;
  end );

  
InstallGlobalFunction( HTTPRequest,
  function(conn,method,uri,header,body,target)
    # method, uri are the strings for the first line of the request
    # header must be a record
    # body either false or a string
    # target either false or the name of a file where the body is stored
    local ParseHeader,bodyread,byt,chunk,contentlength,haveseenheader,
          inpos,k,msg,nr,out,outeof,r,responseheader,ret,w,SetError,
          chunked;

    if conn.sock = fail or conn.closed = true then
        Error("Trying to work with closed connection");
    fi;

    ParseHeader := function( out )
      # Now we want to take this apart:
      # This function modifies the variables ret and responseheader
      # in the outer function and returns the position of the first
      # byte in out after the header.
      local line,lineend,pos,pos2,pos3;
      pos := 0;
      lineend := Position(out,'\n');
      if lineend <> fail then
          if lineend >= 2 and out[lineend-1] = '\r' then
              line := out{[pos+1..lineend-2]};
          else
              line := out{[pos+1..lineend-1]};
          fi;
          ret.status := "Header corrupt";
          if line{[1..5]} = "HTTP/" and Length(line) >= 8 then
              ret.protoversion := line{[6..8]};
              pos3 := Position(line,' ');
              if pos3 <> fail then
                  pos2 := Position(line,' ',pos3);
                  if pos2 <> fail then
                      ret.statuscode := Int(line{[pos3+1..pos2-1]});
                      ret.status := line{[pos2+1..Length(line)]};
                  fi;
              fi;
          fi;
          pos := lineend;
      fi;

      while true do   # will be left by break
          lineend := Position(out,'\n',pos);
          if lineend = fail or lineend <= pos+2 then 
              if lineend <> fail then pos := lineend+1; fi;
              break;   # we have seen the header
          fi;
          if out[lineend-1] = '\r' then
              line := out{[pos+1..lineend-2]};
          else
              line := out{[pos+1..lineend-1]};
          fi;
          pos2 := PositionSublist(line,": ");
          if pos2 <> fail then
              responseheader.(LowercaseString(line{[1..pos2-1]})) :=
                                      line{[pos2+2..Length(line)]};
          fi;
          pos := lineend;
      od;
      
      if lineend = fail then   # incomplete or corrupt header!
          return fail;
      else
          return pos;
      fi;
    end;

    # Maybe add some default values:
    if not(IsBound(header.UserAgent)) then
        header.UserAgent := Concatenation("GAP/IO/",
                                          PackageInfo("io")[1].Version);
    fi;
    if IsString(body) and Length(body) > 0 then
        header.Content\-Length := String(Length(body));
    fi;
    if not(IsBound(header.Host)) then
        header.Host := conn.host.name;
    fi;

    # Now we have a TCP connection, we can start talking:
    msg := Concatenation(method," ",uri," HTTP/1.1\r\n");
    for k in RecNames(header) do
        Append(msg,k);
        Append(msg,": ");
        Append(msg,header.(k));
        Append(msg,"\r\n");
    od;
    Append(msg,"\r\n");
    if IsString(body) then Append(msg,body); fi;

    # Here we collect first the header, then maybe the rest:
    out := "";

    # Now we have collected the complete request, we do I/O multiplexing
    # to send away everything eventually and getting back the answer:

    # Here we just do I/O multiplexing, sending away msg (if non-empty)
    # and receiving from the connection.

    # Note that we first look for the header to learn the content length:
    haveseenheader := false;

    # The answer:
    ret := rec( protoversion := "unknown",
                statuscode := 0,   # indicates an error
                status := "",      # will be filled before return
                header := fail,
                body := fail,
                closed := false );

    # The following function is used to report on errors:
    SetError := function(msg)
      # Changes the variable ret outside!
      ret.status := msg;
      ret.statuscode := 0;
      if haveseenheader then 
          ret.header := responseheader; 
      fi;
      if IsList(out) then 
          if IsStringRep(out) then
              ret.body := out; 
          else
              ret.body := Concatenation(out);
          fi;
      else
          IO_Close(out);
          ret.body := target;
      fi;
    end;

    inpos := 0;
    outeof := false;
    chunked := false;
    repeat
        if not(outeof) then
            r := [conn.sock];
        else
            r := [];
        fi;
        if inpos < Length(msg) then
            w := [conn.sock];
        else
            w := [];
        fi;
        nr := IO_Select(r,w,[],[],HTTPTimeoutForSelect[1],
                                  HTTPTimeoutForSelect[2]);
        if nr = fail then   # an error!
            SetError("Error in select, connection broken?");
            return ret;
        fi;
        if nr = 0 then      # a timeout
            SetError("Connection timed out");
            return ret;
        fi;

        # First writing:
        if Length(w) > 0 and w[1] <> fail then
            byt := IO_WriteNonBlocking(conn.sock,msg,inpos,
                        Minimum(Length(msg)-inpos,65536));
            if byt = fail and 
               LastSystemError().number <> IO.EWOULDBLOCK then   
                # an error occured, probably connection broken
                SetError("Connection broken");
                return ret;
            fi;
            inpos := inpos + byt;
        fi;
        # Now reading:
        if not(outeof) and r[1] <> fail then
            chunk := IO_Read(conn.sock,4096);
            if chunk = "" or chunk = fail then 
                outeof := true; 
                break;
            fi;

            # Otherwise it must be a non-empty string
            if not(haveseenheader) then
                Append(out,chunk);
                responseheader := rec();
                r := ParseHeader(out);
                if r <> fail then   # then it is a position number!
                    if IsBound(responseheader.transfer\-encoding) and
                       responseheader.transfer\-encoding = "chunked" then
                        chunked := true;
                        contentlength := infinity;
                        # This now only works if the server closes the
                        # connection after sending the body!
                    elif not(IsBound(responseheader.content\-length)) then
                        Print("HTTP Warning: no content length!\n");
                        contentlength := infinity;
                    else
                        if method <> "HEAD" then
                            contentlength:=Int(responseheader.content\-length);
                        else
                            contentlength := 0;
                        fi;
                    fi;
                    chunk := out{[r..Length(out)]};

                    # See to the target:
                    if IsString(target) then
                        out := IO_File(target,"w",false);
                        IO_Write(out,chunk);
                        bodyread := Length(chunk);
                    else
                        out := [chunk];
                        bodyread := Length(chunk);
                    fi;
                    haveseenheader := true;
                fi;
            else
                # We are only reading the body until done:
                if IsList(out) then
                    Add(out,chunk);
                else
                    IO_Write(out,chunk);
                fi;
                bodyread := bodyread + Length(chunk);
            fi;
        fi;
    until outeof or (haveseenheader and bodyread >= contentlength);
  
    if outeof and not(haveseenheader) then
        # Obviously, the connection broke:
        SetError("Connection broken");
        return ret;
    fi;

    # In the case that contentlength is infinity because it was not 
    # specified and we thus read until end of file we still report
    # success! This is some tolerance against faulty servers.

    ret.closed := outeof;
    ret.header := responseheader;
    if IsList(out) then
        ret.body := Concatenation(out);
    else
        IO_Close(out);
        ret.body := target;
    fi;

    if chunked then
        # Now we have to fix everything since it came in chunks.
        if target = false then    # things are still in memory
            ret.body := FixChunkedBody(ret.body);
        else    # oops, already in a file!
            # This is a dirty hack:
            FileString(target,FixChunkedBody(StringFile(target)));
        fi;
    fi;
    return ret;
  end );
 
InstallGlobalFunction( CloseHTTPConnection,
  function( conn )
    IO_Close(conn.sock);
    conn.closed := true;
  end );

InstallGlobalFunction( SingleHTTPRequest,
  function(server,port,method,uri,header,body,target)
    local conn,r;
    conn := OpenHTTPConnection(server,port);
    if conn.sock = fail then
        return rec( protoversion := "unknown",
                    statuscode := 0,
                    status := conn.errormsg,
                    header := fail,
                    body := fail,
                    closed := true );
    fi;
    if not(IsBound(header.Host)) then header.Host := server; fi;
    r := HTTPRequest(conn,method,uri,header,body,target);
    CloseHTTPConnection(conn);
    r.closed := true;
    return r;
  end );

InstallGlobalFunction( CheckForUpdates,
  # This function was kindly contributed by Alexander Konovalov.
  function()
    local n1,n2,r;
    r := SingleHTTPRequest( "www.gap-system.org",
                            80,
                            "GET",
                            "/Download/upgrade.html",
                            rec(),
                            false,
                            false);
    n1 := PositionSublist( r.body, "SuggestUpgrades" );
    n2 := PositionSublist( r.body, "]);" ) + 3;
    Read( InputTextString( r.body{[n1..n2]} ) );
  end );

InstallGlobalFunction( ReadWeb,
  function(url)
    local p, domain, uri, f;
    # split off http://
    if Length(url)>7 and LowercaseString(url{[1..7]})="http://" then
      url:=url{[8..Length(url)]};
    fi;
    p:=Position(url,'/');
    domain:=url{[1..p-1]}; # e.g. www.gap-system.org
    uri:=url{[p..Length(url)]}; # e.g. ~xyrxmir/mystuff/bla.txt
    f:=SingleHTTPRequest(domain,80,"GET",uri,rec(),false,false);
    if f.statuscode=404 then
      Error("File not found -- Check URL");
    elif f.statuscode >= 400 then
      Error("HTTP error code ",f.statuscode);
    fi;
    f:=f.body;
    # now `f' is a string containing the file.
    Read(InputTextString(f)); # read in the contents
  end);
 
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
