###########################################################################
##  
##  DiffFiles.g                                              (C) Frank Lübeck
##  
##      $Id: DiffFiles.g,v 1.1 2005/06/10 09:29:23 gap Exp $
##  
##  This file contains utilities for checking directory trees, finding
##  differences, creating an archive with differences, reading file names of
##  text files from a GAP zoo file, ...
##  

FilesDir := function(arg)
  local dir, type, depth, aa, path, find, outstr, out, p;
  if Length(arg) > 0 then
    dir := arg[1];
  else
    dir := ".";
  fi;
  if Length(arg) > 1 then
    type := arg[2];
  else
    type := -1;
  fi;
  if Length(arg) > 2 then
    depth := arg[3];
  else
    depth := 1000;
  fi;
  aa := [dir];
  if type <> -1 then
    Append(aa, ["-type", type]);
  fi;
  Append(aa, ["-maxdepth", String(depth), "-print0"]);
  path := DirectoriesSystemPrograms();
  find := Filename( path, "find" );
  outstr := "";
  out := OutputTextString(outstr,false);
  p := Process(DirectoryCurrent(), find, InputTextNone(), out, aa);
  CloseStream(out);
  return SplitString(outstr,"","\000");
end;

# arg:   cmd, arg1, arg2, ...
# returns output of command as string
StringSystem := function(arg)
  local cmd, res, inp, out;
  cmd := arg[1];
  if cmd[1] <> '/' then
    cmd := Filename(DirectoriesSystemPrograms(), cmd);
  fi;
  if not IsString(cmd) then
    return fail;
  fi;
  res := "";
  inp := InputTextUser();
  out := OutputTextString(res, false);
  Process(DirectoryCurrent(), cmd, inp, out, arg{[2..Length(arg)]});
  CloseStream(out);
  return res;
end;

# in format "2005_05_06-21_39_UTC", good for sorting
StringCurrentTime := function()
  local str, date, out;
  str := "";
  date := Filename(DirectoriesSystemPrograms(), "date");
  out := OutputTextString(str, false);
  Process(DirectoryCurrent(), date, InputTextUser(), out,
  ["-u", "+%Y_%m_%d-%H_%M_UTC"]);
  CloseStream(out);
  return Chomp(str);
end;

# string for size of file with name fn, like "13kB" or "2.9MB"
StringSizeFilename := function(fn)
  local res;
  if not IsExistingFile(fn) then
    Print("#I StringSizeFilename, didn't find: ", fn, "\n");
    return "n.a.";
  fi;
  res := StringSystem("sh", "-c", Concatenation("du -h ", fn, "|cut -f 1"));
  while res[Length(res)] = '\n' do
    Unbind(res[Length(res)]);
  od;
  if res[Length(res)] in "kM" then
    Add(res, 'B');
  fi;
  return res;
end;

# returns 'true' if both files exist and have same content, otherwise 'false'
CmpFiles := function(f1, f2)
  local cmp, res;
  cmp := Filename(DirectoriesSystemPrograms(), "cmp");
  res := Process(DirectoryCurrent(), cmp, InputTextUser(),
         OutputTextUser(), ["-s", f1, f2]);
  return res = 0;
end;

# compares recursively files in and below both paths
# returns list [only1, only2, diffs] of three lists of filenames; only1 
# contains the names of files, only in path1, only2 those only in path2, and
# diffs are the files which are in both directories but different
DiffFiles := function(path1, path2)
  local l1, l2, only1, only2, bothfiles, difffiles;
  l1 := SplitString(StringSystem("sh", "-c", 
        Concatenation("cd ",path1,"; find .")), "\n", "");
  l1 := List(l1, a-> a{[3..Length(a)]});
  l2 := SplitString(StringSystem("sh", "-c", 
        Concatenation("cd ",path2,"; find .")), "\n", "");
  l2 := List(l2, a-> a{[3..Length(a)]});
 
  only1 := Difference(l1, l2);
  only2 := Difference(l2, l1);
  bothfiles := Filtered(Intersection(l1, l2), a-> 
                  not IsDirectoryPath(Concatenation(path1,"/",a)));
  difffiles := Filtered(bothfiles, a-> not CmpFiles(
                Concatenation(path1,"/",a),
                Concatenation(path2,"/",a)));
  return [only1, only2, difffiles];
end;

# examines a GAP style .zoo file and returns the list of file names in the
# archive which are marked as text files (uses GAPs 'unzoo').
TextFilesInZooArchive := function(arch)
  local s, tf, l, pos, fin, i;
  s := StringSystem("unzoo", "-v", arch);
  s := SplitString(s, "", "\n");
  tf := [];
  for i in [1..Length(s)] do
    if s[i] = "# !TEXT!" then
      l := s[i-1];
      pos := Position(l, ':');
      pos := Position(l, ':');
      pos := Position(l, ':', pos);
      fin := Length(l);
      while l[fin] <> ';' do
        fin := fin - 1;
      od;
      Add(tf, l{[pos+6..fin-1]});
    fi;
  od;
  return tf;
end;

# put things together:
# args: newzoo (name of new zoo archive), 
#       oldzoos (list of names of old zoo archives to compare with), 
#       tmpdirname (directory for the comparison, must hold twice the 
#                   largest content of any of the given zoo archives)
#       diffnam (name of archive with the different files)
#       cdpath (enter this subdirectory to pack diffnam, and strip this
#               part from filenames to pack)
#       nodel (don't overwrite these files from old versions - other files
#              only in old archives are substituted by empty ones)

# Algorithm:
# Compare the new archive with each of the old ones, collect names of files
# which are in the new archive but not in any of the old archives. 
# And a list of those which are different from the same file in any of 
# the old archives. Also collect names of files in old archives which are 
# no longer in the new archive.
CreateDiffsArchive := function(newzoo, oldzoos, tmpdirname, diffname, 
                               cdpath, nodel)
  local textfiles, del, diffs, d, b, a;

  textfiles := TextFilesInZooArchive(newzoo);
  Exec(Concatenation("mkdir -p ",tmpdirname));
  Exec(Concatenation("cd ", tmpdirname, "; mkdir 0; cd 0; unzoo -x ", newzoo));
  del := [];
  diffs := [];
  for a in oldzoos do
    Exec(Concatenation("cd ", tmpdirname, "; mkdir 1; cd 1; unzoo -x ", a));
    d := DiffFiles(Concatenation(tmpdirname, "/0"),
                   Concatenation(tmpdirname, "/1"));
    Exec(Concatenation("cd ", tmpdirname, "; rm -rf 1"));
    Append(diffs, d[1]);
    Append(diffs, d[3]);
    Append(del, d[2]);
    diffs := Set(diffs);
    del := Set(del);
  od;
  # overwrite files no longer in new archive by empty ones, except if given 
  # explicitly in 'nodel'
  del := Difference(del, nodel);
  for a in del do
    Print("Subtituting deleted file by empty one: ", a, "\n");
    Exec(Concatenation("touch ", tmpdirname, "/0/", a));
    Exec(Concatenation("chmod 644 ", tmpdirname, "/0/", a));
    Add(diffs, a);
    Add(textfiles, a);
  od;
  # now pack new archive, only files at and below 'cdpath'
  diffs := Filtered(diffs, a-> PositionSublist(a, cdpath) = 1);
  Print("Packing archive with different files . . .\n");
  for a in diffs do
    b := a{[Length(cdpath)+1..Length(a)]};
    if a in textfiles then
      Print("  adding ", b, " [text]\n");
      Exec(Concatenation("cd ", tmpdirname, "/0/", cdpath, "; ",
           "(echo \"!TEXT!\"; echo \"/end\") |  zoo ahc ",
           tmpdirname, "/", diffname, " \"", b, "\""));
    else
      Print("  adding ", b, " [binary]\n");
      Exec(Concatenation("cd ", tmpdirname, "/0/", cdpath, "; ",
           "(echo \"!BINARY!\"; echo \"/end\") |  zoo ahc ",
           tmpdirname, "/", diffname, " \"", b, "\""));
    fi;
  od;
end;





               
