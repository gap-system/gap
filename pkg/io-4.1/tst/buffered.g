# This file checks buffered I/O:

# First we create a longish string:
st := "";
for i in [1..100000] do 
    Append(st,String(i));
    Add(st,'\n');
od;

# Now we write this to a file called "tmpfile":
f := IO_File("tmpfile","w");   # we use standard buffer size
if IO_Write(f,st) = fail then Error("write error ",1); fi;
IO_Close(f);

# Now read the same file again in different ways:
f := IO_File("tmpfile");
s := "";
repeat
    block := IO_ReadBlock(f,1000);
    if block = fail then Error("read error ",2); fi;
    Append(s,block);
until block = "";
IO_Close(f);

if s <> st then Error("reading unsuccessful ",3); fi;

# Now in principle it works, we now try nonblocking I/O on files:

f := IO_File("tmpfile","w");
pos := 1;
while pos <= Length(st) do
    if IO_ReadyForWrite(f) then
       bytes := IO_WriteNonBlocking(f,st,pos-1,Minimum(Length(st)-pos+1,1000));
       pos := pos + bytes;
    else
       Print(".\c");
    fi;
od;
IO_Close(f);

# Now read the same file again:
f := IO_File("tmpfile");
s := "";
block := "non-space";
repeat
    if IO_HasData(f) then
        block := IO_Read(f,1000);
        Append(s,block);
    else
        Print(".\c");
    fi;
until block = "";
IO_Close(f);

if s <> st then Error("reading unsuccessful ",4); fi;


# Now we want to send it over a named pipe:
IO_mkfifo("PIPE",6*64+4*8+4);

sender := function()
  local f,pos;
  f := IO_File("PIPE","w");
  pos := 1;
  while pos <= Length(st) do
      if IO_ReadyForWrite(f) then
          bytes := IO_WriteNonBlocking(f,st,pos-1,Minimum(Length(st)-pos+1,
                                                          100000));
          pos := pos + bytes;
      #else
      #    Print("Cannot write\n");
      fi;
  od;
  IO_Close(f);
end;

selectsender := function()
  local f,pos;
  f := IO_File("PIPE","w");
  pos := 1;
  while pos <= Length(st) do
      if IO_Select([],[f],[],[],fail,fail) = 1 then
          bytes := IO_WriteNonBlocking(f,st,pos-1,Minimum(Length(st)-pos+1,
                                                          10000));
          pos := pos + bytes;
          Print("Wrote ",bytes,"\n");
      #else
      #    Print("Cannot write\n");
      fi;
  od;
  repeat
      IO_Select([],[],[f],[],fail,fail);
      Print("Can flush\n");
  until IO_FlushNonBlocking(f);
  IO_Close(f);
end;

# Let's fork to get a second process going:
pid := IO_fork();

if pid = -1 then Error("cannot fork ",5); fi;
if pid = 0 then
    # The child
    sender();
    IO_exit(0);
fi;

# Now read the same file again:
f := IO_File("PIPE");
s := "";
block := "non-space";
repeat
    if IO_HasData(f) then
        block := IO_Read(f,100000);
        Append(s,block);
    #else
    #    Print("Cannot read\n");
    fi;
until block = "";
IO_Close(f);

if s <> st then Error("reading unsuccessful ",4); fi;

# Let's fork to get a third process going:
pid := IO_fork();

if pid = -1 then Error("cannot fork ",6); fi;
if pid = 0 then
    # The child
    selectsender();
    IO_exit(0);
fi;

# Now read the same file again:
f := IO_File("PIPE");
s := "";
block := "non-space";
repeat
    if IO_Select([f],[],[],[],fail,fail) = 1 then
        block := IO_Read(f,10000);
        Append(s,block);
        Print("Read ",Length(block),"\n");
    #else
    #    Print("Cannot read\n");
    fi;
until block = "";
IO_Close(f);

if s <> st then Error("reading unsuccessful ",7); fi;

# Cleanup:
IO_unlink("PIPE");
IO_unlink("tmpfile");

