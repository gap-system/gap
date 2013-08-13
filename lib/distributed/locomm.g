DeclareGlobalFunction("RecvStringMsg");
DeclareGlobalVariable("MESSAGE_TYPES");

InstallGlobalFunction(RecvStringMsg, function( arg )
    local buffer;
    MPI_Probe();
    buffer := UNIX_MakeString( MPI_Get_count() );
    return MPI_Recv( buffer, MPI_Get_source() );
end);

UnpackSourceTag := function (p)
  local l, pos;
  l := [];
  l[1] := IO_Unpickle(p);
  l[2] := IO_Unpickle(String(p{[1+Length(IO_Pickle(l[1]))..Length(p)]}));
  return l;
end;

UnpickleMsg := function (p)
  local x, l, ind, pos;
  l := [];
  pos := 1;
  ind := 1;
  while pos<=Length(p) do
    x := IO_Unpickle(String(p{[pos..Length(p)]}));
    l[ind] := x;
    ind := ind+1;
    pos := pos + Length((IO_Pickle(x)));
  od;
  return l;
end;

SendMessage := function(arg)
  local content, i;
  
  content := Concatenation(IO_Pickle(processId), IO_Pickle(arg[2])); # source, tag
  for i in [3..Length(arg)] do
    content := Concatenation(content, IO_Pickle(arg[i]));
  od;
  
  #atomic readwrite MPISendLock do
  MPI_Send (content, arg[1], arg[2]);
  #od;
  
end;

GetMessage := function ()
  local raw, msg, strBuffer, tmp;
  
  strBuffer := UNIX_MakeString(MPI_Get_count());
  MPI_Recv(strBuffer);
  # peek into the message and see whether it is EVAL_MSG or not
  # if it is EVAL_MSG, the body of the message needs not be unpickled
  tmp := UnpackSourceTag(strBuffer);
  if tmp[2]=MESSAGE_TYPES.EVAL_MSG then
    msg := rec (source := tmp[1],
                type := MESSAGE_TYPES.EVAL_MSG,
                content := String(strBuffer{[1+Length(IO_Pickle(tmp[1]))+Length(IO_Pickle(MESSAGE_TYPES.EVAL_MSG))..Length(strBuffer)]})
                );
    return msg;
  else
    raw := UnpickleMsg(strBuffer);
    msg := rec ( source := raw[1],
                 type := raw[2],
                 content := raw{[3..Length(raw)]});
    return msg;
  fi;
  
end;
