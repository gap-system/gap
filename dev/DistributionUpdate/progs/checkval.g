
##  some utilities for checking URLs and files
##  (C) Frank Lübeck
##  $Id$


# get file/directory list 
# args: [dir[, type[, depth]]]  (default dir is ".", type as in 'find xxx -type type')
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

# part of string str before last '/', or "." if there is no '/' 
Dirname := function(str)
  local len;
  len := Length(str);
  while len > 0 and str[len] <> '/' do
    len := len - 1;
  od;
  if len = 0 then
    return ".";
  else
    return str{[1..len-1]};
  fi;
end;
    
# part of string str after last '/', or str if there is no '/' 
Basename := function(str)
  local len;
  len := Length(str);
  while len > 0 and str[len] <> '/' do
    len := len - 1;
  od;
  if len = 0 then
    return str;
  else
    return str{[len+1..Length(str)]};
  fi;
end;
# arg:   cmd, arg1, arg2, ...
SYSTEM_RESULT := 0;
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
  SYSTEM_RESULT := 
             Process(DirectoryCurrent(), cmd, inp, out, arg{[2..Length(arg)]});
  CloseStream(out);
  return res;
end;

CheckURL := function(url, fname)
  local str;
  str := StringSystem("sh", "-c", Concatenation("wget ",
         url, " -O ", fname, " 2>&1"));
  if SYSTEM_RESULT <> 0 then
    Print("Cannot download: ", url, "\n'wget' said:\n", str, "\n");
    return false;
  else
    Print("Successful download of ",url,"\n\n");
    return true;
  fi;
end;

CheckZoo := function(fname)
  local str;
  str := StringSystem("sh", "-c", Concatenation("unzoo -l ",
         fname, " 2>&1"));
  if SYSTEM_RESULT <> 0 then
    Print("Cannot unzoo: ", fname, "\n'unzoo -l' said:\n", str, "\n");
    return false;
  else
    Print("Successful unzoo'ing of ",fname,"\n\n");
    return true;
  fi;
end;


CheckTarGz := function(fname)
  local str;
  str := StringSystem("sh", "-c", Concatenation("tar tzf ",
         fname, " 2>&1"));
  if SYSTEM_RESULT <> 0 then
    Print("Cannot gunzip and untar: ", fname, "\n'tar tzf' said:\n", str, "\n");
    return false;
  else
    Print("Successful gunzip'ing and untar'ing of ",fname,"\n\n");
    return true;
  fi;
end;

CheckTarBz2 := function(fname)
  local str;
  str := StringSystem("sh", "-c", Concatenation("tar tjf ",
         fname, " 2>&1"));
  if SYSTEM_RESULT <> 0 then
    Print("Cannot bunzip2 and untar: ",fname, "\n'tar tjf' said:\n", str, "\n");
    return false;
  else
    Print("Successful bunzip2'ing and untar'ing of ",fname,"\n\n");
    return true;
  fi;
end;

CheckWinZip := function(fname)
  local str;
  str := StringSystem("sh", "-c", Concatenation("unzip -t ",
         fname, " 2>&1"));
  if SYSTEM_RESULT <> 0 then
    Print("Cannot unzip: ",fname, "\n'unzip -t' said:\n", str, "\n");
    return false;
  else
    Print("Successful unzip'ing of ",fname,"\n\n");
    return true;
  fi;
end;

CheckText := function(fname)
  local str;
  str := StringSystem("sh", "-c", Concatenation("file ",
         fname, " 2>&1 | grep -q \" text\" "));
  if SYSTEM_RESULT <> 0 then
    Print("File ",fname, " doesn't seem to be a text file.\n");
    Print(StringSystem("sh", "-c", Concatenation("file ",fname, " 2>&1")));
    return false;
  else
    return true;
  fi;
end;

CheckHTML := function(fname)
  local str;
  str := StringSystem("sh", "-c", Concatenation("file ",
         fname, " 2>&1 | grep -q -e 'HTML\\|XML'"));
  if SYSTEM_RESULT <> 0 then
    Print("File ",fname, " doesn't seem to be an HTML file.\n");
    Print(StringSystem("sh", "-c", Concatenation("file ",fname, " 2>&1")));
    return false;
  else
    return true;
  fi;
end;

CheckPDF := function(fname)
  local str;
  str := StringSystem("sh", "-c", Concatenation("file ",
         fname, " 2>&1 | grep -q -e 'PDF document'"));
  if SYSTEM_RESULT <> 0 then
    Print("File ",fname, " doesn't seem to be a PDF file.\n");
    Print(StringSystem("sh", "-c", Concatenation("file ",fname, " 2>&1")));
    return false;
  else
    return true;
  fi;
end;

CheckPackageInfo := function(fname)
  Unbind(GAPInfo.PackageInfoCurrent);
  READ(fname);
  if not IsBound(GAPInfo.PackageInfoCurrent) then
    Print("File ",fname, " is not a PackageInfo.g file.\n");
    return false;
  else
    return true;
  fi;
end;

CheckType := function(fname, type)
  if type in [".zoo", "zoo", ".ZOO", "ZOO"] then
    return CheckZoo(fname);
  elif type in [".tar.gz", "tar.gz", ".tgz", "tgz", "TGZ"] then
    return CheckTarGz(fname);
  elif type in [".tar.bz2", "tbz2", ".tbz2", "tar.bz2"] then
    return CheckTarBz2(fname);
  elif type in ["-win.zip", ".zip", "zip", "ZIP"] then
    return CheckWinZip(fname);
  elif type in ["text",".txt","txt","TEXT", "Text"] then
    return CheckText(fname);
  elif type in [".htm",".html","htm","html","HTML"] then
    return CheckHTML(fname);
  else
    Print("File type ",type," not recognized.\n");
  fi;
end;
    

