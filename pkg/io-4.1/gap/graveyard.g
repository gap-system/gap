HTTPRequestOld := function(server,port,method,uri,header,body)
  local byt,chunk,f,inpflushed,inpos,k,line,lineend,lookup,msg,nr,out,
        outeof,pos,pos2,pos3,r,res,responseheader,ret,s,sock,w;
  s := IO_socket(IO.PF_INET,IO.SOCK_STREAM,"tcp");
  if s = fail then 
      Print("HTTPRequest: cannot create socket\n");
      return fail; 
  fi;
  lookup := IO_gethostbyname(server);
  if lookup = fail then
      Print("HTTPRequest: cannot find hostname\n");
      return fail;
  fi;
  res := IO_connect(s,IO_make_sockaddr_in(lookup.addr[1],port));
  if res = fail then
      Print("HTTPRequest: cannot connect: ",LastSystemError(),"\n");
      IO_close(s);
      return fail;
  fi;
  sock := IO_WrapFD(s,false,false);
  
  # Maybe add some default values:
  if not(IsBound(header.UserAgent)) then
      header.UserAgent := Concatenation("GAP/IO/",
                                        PackageInfo("io")[1].Version);
  fi;
  if IsString(body) and Length(body) > 0 then
      header.Content\-Length := String(Length(body));
  fi;

  # Now we have a TCP connection, we can start talking:
  msg := Concatenation(method," ",uri," HTTP/1.0\r\n");
  for k in RecNames(header) do
      Append(msg,k);
      Append(msg,": ");
      Append(msg,header.(k));
      Append(msg,"\r\n");
  od;
  Append(msg,"\r\n");
  if IsString(body) then Append(msg,body); fi;

  # Now we have collected the complete request, we do I/O multiplexing
  # to send away everything eventually and getting back the answer:
  # Note that the flushing part is superfluous since we switched off
  # the buffers, but still, like this, the code would also work with
  # buffering.

  # Here we just do I/O multiplexing, sending away msg (if non-empty)
  # and receiving from the connection.
  inpos := 0;
  inpflushed := (msg = "");
  outeof := false;
  # Here we collect the answer:
  out := "";
  repeat
      if not(outeof) then
          r := [sock];
      else
          r := [];
      fi;
      if inpos < Length(msg) then
          w := [sock];
          f := [];
      else
          w := [];
          if not(inpflushed) then 
              f := [sock]; 
          else
              f := [];
          fi;
      fi;
      nr := IO_Select(r,w,f,[],fail,fail);
      # First writing:
      if Length(w) > 0 and w[1] <> fail then
          byt := IO_WriteNonBlocking(sock,msg,inpos,
                      Minimum(Length(msg)-inpos,IO.PIPE_BUF));
          inpos := inpos + byt;
      fi;
      # Now perhaps flushing:
      if Length(f) > 0 and f[1] <> fail then
          if IO_FlushNonBlocking(sock) = true then
              inpflushed := true;
          fi;
      fi;
      # Now reading:
      if not(outeof) and r[1] <> fail then
          chunk := IO_Read(sock,65536);
          if chunk = "" then outeof := true; fi;
          Append(out,chunk);
      fi;
  until outeof;
  IO_Close(sock);

  # Now we want to take this apart:
  pos := 0;
  lineend := Position(out,'\n');
  ret := rec();
  if lineend <> fail then
      if lineend >= 2 and out[lineend-1] = '\r' then
          line := out{[1..lineend-2]};
      else
          line := out{[1..lineend-1]};
      fi;
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

  responseheader := rec();
  while true do   # will be left by break
      lineend := Position(out,'\n',pos);
      if lineend <= pos+2 or lineend = fail then 
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
          responseheader.(line{[1..pos2-1]}) := line{[pos2+2..Length(line)]};
      fi;
      pos := lineend;
  od;
  ret.header := responseheader;
  ret.body := out{[pos..Length(out)]};
  return ret;
end;


