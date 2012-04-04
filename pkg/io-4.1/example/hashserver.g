# This is an example for the usage of IOHubs:
LoadPackage("orb");
HashServer := function(pt,size,addr,port,chunksize)
  local done,h,ht,i,l,len,p,r,todo,val;
  ht := HTCreate(pt,rec( treehashsize := size ));
  todo := [];
  h := IOHub();
  AttachServingSocket(h,addr,port);
  done := false;
  while not(done) do
      DoIO(h,true);       # this is blocking
      #Print("done\n");
      while true do
          r := GetInput(h,0);   # a pair [connection,string]
          #Print(r,"\n");
          if r = false then break; fi;
          if r[2] = "exit" then done := true; break; fi;
          if r[2] = "gettask" then
              len := Length(todo);
              if len = 0 then
                  l := [];
              elif len >= chunksize then
                  l := todo{[len-chunksize+1..len]};
                  for i in [len,len-1..len-chunksize+1] do
                      Unbind(l[i]);
                  od;
              else
                  l := ShallowCopy(todo);
                  for i in [len,len-1..1] do
                      Unbind(l[i]);
                  od;
              fi;
              SubmitOutput(h,r[1],IO_Pickle(l));
          else   # some new points
              l := IO_Unpickle(r[2]);
              for p in l do
                  val := HTValue(ht,p);
                  if val = fail then
                      HTAdd(ht,p,true);
                      Add(todo,p);
                  fi;
              od;
          fi;
          DoIO(h,false);   # non-blocking!
      od;
  od;
  Shutdown(h);
end;
