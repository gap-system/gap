###########################################################################
##  
##  PackageInfoUtil.g                                         (C) Frank Lübeck
##  
##      $Id$
##  
##  This file contains utilities for automatic updating of the information 
##  related to package which are available via the GAP website. 
##  
##     - current PackageInfo.g files are fetched from the Web
##     - if something is new, the following files are updated:
##       - the pkg.input overview file
##       - changed archives are downloaded, if any of the formats
##         .zoo, .tar.gz, -win.zip or .tar.bz2 is not provided these
##         are automatically generated
##       - if an accepted or deposited package has changed, the corresponding
##         merged archives (in the formats mentioned above) are newly generated
##       - if a documentation archive for the online manual has changed, it is
##         fetched from the Web and unpacked
##  
##  CHANGE: produce one archive for acc+dep

## store package infos
PACKAGE_INFOS := rec();

GAPLibraryVersion := "unknown";
GAPKernelVersion := "unknown";

ClearPACKAGE_INFOS := function()
  local a;
  for a in NamesOfComponents(PACKAGE_INFOS) do
    Unbind(PACKAGE_INFOS.(a));
  od;
end;

# try reading a PackageInfo.g file, given by name fname
READPackageInfo := function(fname)
  local r, name;
  Unbind(GAPInfo.PackageInfoCurrent);
  READ(fname);
  if not IsBound(GAPInfo.PackageInfoCurrent) then
    Print("# No package info bound!");
    return;
  fi;
  r := GAPInfo.PackageInfoCurrent;
  Unbind(GAPInfo.PackageInfoCurrent);
  # store under normalized .PackageName
  if not IsRecord(r) or not IsBound(r.PackageName) or 
                        not IsString(r.PackageName) then
    Print("# Ignored: No package name!\n");
    return;
  fi;
  NormalizeWhitespace(r.PackageName);
  name := LowercaseString(r.PackageName);

  # What is the "default Status"???
  if not IsBound(r.Status) then
     r.Status := "None";
     Print("# Warning: package ",r.PackageName," has no Status!!!\n");
  fi;

  PACKAGE_INFOS.(name) := r;
end;


#####   some utilities       ###################################################

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
#T Better introduce general ``text processing'' functions
#T  LeftString( <str>, <pattern> )
#T  RightString( <str>, <pattern> )
#T  LeftBackString( <str>, <pattern> )
#T  RightBackString( <str>, <pattern> )
#T which return the substring in <str> before/after the first/last occurrence
#T of the string <pattern>.

# arg:   cmd, arg1, arg2, ...
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

# checks if an archive file doesn't contain path with ".." in them or
# starting with "/".
# assuming that fname ends in one of:  ".zoo", ".zip", ".tar.gz" or
# ".tar.bz2"
IsLocalArchive := function(fname)
  local ext, s;
  ext := fname{[Length(fname)-3..Length(fname)]};
  if ext = "r.gz" then
    s := StringSystem("tar", "tzf", fname);
  elif ext = ".bz2" then
    s := StringSystem("tar", "tf", fname, "--bzip2");
  elif ext = ".zoo" then
    s := StringSystem("unzoo", "-l", fname);
  elif ext = ".zip" then
    s := StringSystem("unzip", "-qql", fname);
  else
    s := "..";
  fi;
  return PositionSublist(s, "..") = fail and PositionSublist(s, " /") = fail;
end;

ReadAllPackageInfos := function(pkgdir)
  local pkgs, pkg;
  pkgs := Difference(FilesDir(pkgdir, "d", 1), [pkgdir]);
  for pkg in pkgs do
    READPackageInfo(Concatenation(pkg, "/PackageInfo.g"));
  od;
end;


# returns list of names of dirs with updated package info
UpdatePackageInfoFiles := function(pkgdir)
  local path, find, wget, date, stdin, stdout, res, outstr, out, p, 
        pkgs, nam, info, infon, namn, d, pkg, f, update;
  path := DirectoriesSystemPrograms();
  find := Filename( path, "find" );
  wget := Filename( path, "wget" );
  stdin := InputTextUser();
  stdout := OutputTextUser();
  res := [];
  # get directory list 
  pkgs := Difference(FilesDir(pkgdir, "d", 1), [pkgdir]);


  for pkg in pkgs do
    # read local info
    # to initialize handling of a package just 
    #  - create corresponding directory (all small letters)
    #  - provide a 'slim' pkgname/PackageInfo.g file,
    #    setting only the .PackageName and .PackageInfoURL components
    ClearPACKAGE_INFOS();
    READPackageInfo(Concatenation(pkg, "/PackageInfo.g"));
    nam := NamesOfComponents(PACKAGE_INFOS);
    if Length(nam) = 0 then
      Print(pkg, ": IGNORED\n");
      continue;
    else
      nam := nam[1];
      info := PACKAGE_INFOS.(nam);
    fi;
    Print("Package: ", info.PackageName, "\n");
    
    # try to get current info file with wget
    Exec(Concatenation("mkdir -p ", pkg, "/tmp; rm -f ", pkg,
    "/tmp/tmpinfo.g"));
    Exec(Concatenation("wget --timeout=60 --tries=1 -O ", 
                       pkg, "/tmp/tmpinfo.g ",
    info.PackageInfoURL, " 2>> wgetlog"));
    ClearPACKAGE_INFOS();
    READPackageInfo(Concatenation(pkg, "/tmp/tmpinfo.g"));
    if not IsBound(PACKAGE_INFOS.(nam)) then
      Print("  Download of current info file not successful.\n");
      continue;
    fi;
    infon := PACKAGE_INFOS.(nam);
    
    # helper, because "=" for functions doesn't work as it should
    f := function(a)
      if not IsBound(infon.(a)) then
        return false;
      elif IsFunction(info.(a)) then
        return StringPrint(info.(a)) <> StringPrint(infon.(a));
      else
        return info.(a) <> infon.(a);
      fi;
    end;
    
    nam := NamesOfComponents(info);
    namn := NamesOfComponents(infon);
    if nam = namn and ForAll(nam, f) then
      Print("  No changes in info file.\n");
      continue;
    fi;
    update := false;
    d := Difference(nam, namn);
    if Length(d) > 0 then
      Print("  removed components: ", d, "\n");
      update := true;
    fi;
    d := Difference(namn, nam);
    if Length(d) > 0 then
      Print("  new components: ", d, "\n");
      update := true;
    fi;
    d := Filtered(nam, f);
    if Length(d) > 0 then
      Print("  changed components: ", d, "\n");
      update := true;
    fi;
    if update then
      # save old info file, store new one
      outstr := StringCurrentTime();
      Exec(Concatenation("mv -f ", pkg, "/PackageInfo.g ", pkg, 
                         "/PackageInfo.g-", outstr));
      Exec(Concatenation("mv -f ", pkg, "/tmp/tmpinfo.g ", pkg,
                         "/PackageInfo.g"));
      Add(res, pkg);
    else
      Print("  No changes.\n");
    fi;
  od;
  return res;
end;

# For a new setup of the system one can use the output of this
# function for the initializations of all currently handled packages.
AddpackageLinesCurrent := function(pkgdir)
  local path, find, pkgs, resstr, res, nam, info, pkg;
  path := DirectoriesSystemPrograms();
  find := Filename( path, "find" );
  # get directory list 
  pkgs := Difference(FilesDir(pkgdir, "d", 1), [pkgdir]);
  resstr := "";
  res := OutputTextString(resstr, false);
  SetPrintFormattingStatus(res, false);

  for pkg in pkgs do
    # read local info
    # to initialize handling of a package just 
    #  - create corresponding directory (all small letters)
    #  - provide a 'slim' pkgname/PackageInfo.g file,
    #    setting only the .PackageName and .PackageInfoURL components
    ClearPACKAGE_INFOS();
    READPackageInfo(Concatenation(pkg, "/PackageInfo.g"));
    nam := NamesOfComponents(PACKAGE_INFOS);
    if Length(nam) = 0 then
      Print("# ", pkg, ": IGNORED\n");
      continue;
    else
      nam := nam[1];
      info := PACKAGE_INFOS.(nam);
    fi;
    PrintTo(res, "addpackage.py ", info.PackageName, " ", 
            info.PackageInfoURL,"\n");
  od;
  CloseStream(res);
  return resstr;
end;

TextFilesInZooArchive := function(zoofile)
  local lines, tfiles, l, ll, p;
  Exec(Concatenation("rm -f tmpzoocomm; zoo lc ", zoofile, " > tmpzoocomm"));
  lines := SplitString(StringFile("tmpzoocomm"), "", "\n");
  tfiles := [];
  for p in [1..Length(lines)] do
    if Length(lines[p]) >= 8  and lines[p]{[1..8]} = " |!TEXT!" then
      l := lines[p-1];
      ll := Length(l);
      while ll > 0 and l[ll] <> ' ' do
        ll := ll - 1;
      od;
      Add(tfiles, l{[ll+1..Length(l)]});
    fi;
  od;
  Exec("rm -f tmpzoocomm");
  return tfiles;
end;

# returns list of dirs with updated archives
UpdatePackageArchives := function(pkgdir)
  local pkgs, res, nam, info, url, pos, fname, formats, pkgtmp, missing, fmt, 
        tfiles, allnames, len, bfiles, lines, l, ll, fun, tnames, pkg, 
        allfiles, p, a, bname, dnam, old, fn;
  # package dirs
  pkgs := Difference(FilesDir(pkgdir, "d", 1), [pkgdir]);
  res := [];
  for pkg in pkgs do
    ClearPACKAGE_INFOS();
    READPackageInfo(Concatenation(pkg, "/PackageInfo.g"));
    nam := NamesOfComponents(PACKAGE_INFOS);
    if Length(nam) = 0 then
      continue;
    fi;
    nam := nam[1];
    Print("Package: ", nam, " --- updating archive ...\n");
    info := PACKAGE_INFOS.(nam);
    Print(info.PackageName, ":\n");
    if not IsBound(info.ArchiveURL) then
      Print("# Warning: no ArchiveURL given! (", info.PackageName, ")\n");
      continue;
    fi;
    url := info.ArchiveURL;
    # filename of the archive without extension
    fname := Basename(url);
    # check if .zoo file is already in the local collection
    if IsExistingFile(Concatenation(pkgdir, "/", nam, 
                      "/", fname, ".zoo")) then
      Print("  archives are already in collection\n");
      continue;
    else
      Add(res, nam);
      Print("  GETTING NEW archives ...\n   (", url, ")\n");
    fi;
    
    # ok, so we have to get the archives
    formats := SplitString(info.ArchiveFormats,""," \n\r\t,");
    # use only recognized formats here
    formats := Intersection(formats, [".zoo", ".tar.gz", ".tar.bz2",
                 "-win.zip", ".deb", ".rpm" ]);
    pkgtmp := Concatenation(pkg, "/tmp/");
    Exec(Concatenation("mkdir -p ", pkgtmp));
    # copy available archive formats
    for fmt in formats do
      Exec(Concatenation("cd ", pkgtmp, ";wget --timeout=60 --tries=1 -O ", 
           fname, fmt, " ", url, fmt, " 2>> wgetlog"));
    od;
    # which formats are missing?
    missing := Filtered([".zoo", ".tar.gz", ".tar.bz2", "-win.zip"], fmt ->
                        not IsExistingFile(Concatenation(pkgtmp, fname, fmt)));
    if Length(missing) > 0 then
      # unpack first archive
      fmt := First([".zoo", ".tar.gz", ".tar.bz2", "-win.zip"], a-> not a in
                   missing);
      if fmt = fail then
        Print("GOT NONE OF THE ARCHIVES! NOT UPDATED!\n");
        Unbind(res[Length(res)]);
        continue;
      fi;
      if not IsLocalArchive(Concatenation(pkgtmp, fname, fmt)) then
        Print("   archive contains path starting with / or containing ..\n",
              "       REJECTED !!!\n");
        continue;
      fi;
      Print("  unpacking ", fname, fmt, "\n");
      if fmt = ".zoo" then
        Exec(Concatenation("cd ", pkgtmp, ";unzoo -x ", fname, 
             ".zoo > /dev/null 2>&1"));
      elif fmt = ".tar.gz" then
        Exec(Concatenation("cd ", pkgtmp, ";gzip -dc ", fname, 
                           ".tar.gz |tar xf - "));
      elif fmt = ".tar.bz2" then
        Exec(Concatenation("cd ", pkgtmp, ";bzip2 -dc ", fname, 
                           ".tar.bz2 |tar xf - "));
      elif fmt = "-win.zip" then
        Exec(Concatenation("cd ", pkgtmp, ";unzip -a ", fname, "-win.zip"));
      else
        Error("no recognized archive format: ", fmt);
      fi;
      # name of unpacked directory (must no longer be 'nam')
      dnam := Difference(FilesDir(pkgtmp, "d", 1), [pkgtmp])[1];
      dnam := dnam{[Length(pkgtmp)+1..Length(dnam)]};
      if ".zoo" in missing or "-win.zip" in missing then
        # need to find out the text files
        Print("  finding text files  . . .\n");
        if IsBound(info.TextFiles) then
          tfiles := List(info.TextFiles, a-> Concatenation(dnam, "/", a));
        elif IsBound(info.BinaryFiles) then
          allnames := FilesDir(Concatenation(pkgtmp, dnam), "f");
          len := Length(pkgtmp) + 1;
          allnames := List(allnames, a-> a{[len..Length(a)]});
          bfiles := List(info.BinaryFiles, a-> Concatenation(dnam, "/", a));
          tfiles := Difference(allnames, bfiles);
        elif not ".zoo" in missing then
          tfiles := TextFilesInZooArchive(Concatenation(pkgtmp, fname, ".zoo"));
        # we could also use the  -win.zip format here, with 'unzip -Z -v'
        # the text files can be found
        # elif not -win.zip in missing then .....
        else
          allnames := FilesDir(Concatenation(pkgtmp, dnam), "f");
          len := Length(pkgtmp) + 1;
          allnames := List(allnames, a-> a{[len..Length(a)]});
          fun := function(name)
            if (Length(name) >= 2 and
               name{[Length(name)-1..Length(name)]} in [".g", ".c", ".h"])
               or
               (Length(name) >= 3 and 
               name{[Length(name)-2..Length(name)]} in
               [".gi", ".gd"])
               or
               (Length(name) >= 4 and 
               name{[Length(name)-3..Length(name)]} in
               [".htm", ".txt", ".tex", ".bib", ".xml", ".six", 
                ".gap", ".bib", ".tst", ".css"])
               or 
               (Length(name) >= 5 and 
               name{[Length(name)-4..Length(name)]} in
               [".html"]) then
              return true;
            else
              return false;
            fi;
          end;
          tfiles := Filtered(allnames, fun);
        fi;
      fi;

      # now create the missing archives
      for fmt in missing do
        if fmt = ".tar.gz" then
          Print("  creating ",fname,".tar.gz\n");
          Exec(Concatenation("cd ", pkgtmp,"; tar cpf ", fname, ".tar ",
               dnam, "; gzip -9 ", fname, ".tar"));
        elif fmt = ".tar.bz2" then
          Print("  creating ",fname,".tar.bz2\n");
          Exec(Concatenation("cd ", pkgtmp,"; tar cpf ", fname, ".tar ",
               dnam, "; bzip2 -9 ", fname, ".tar"));
        elif fmt = ".zoo" then
          Print("  creating ",fname,".zoo\n");
          Exec(Concatenation("cd ", pkgtmp,"; find ", dnam, 
               " -print | zoo aIhq ", fname, ".zoo"));
          for a in tfiles do
            Exec(Concatenation("cd ", pkgtmp,"; (echo '!TEXT!'; echo '/END')", 
                 "| zoo c ", fname, ".zoo ", a));
          od;
        elif fmt = "-win.zip" then
          Print("  creating ",fname,"-win.zip\n");
          FileString(Concatenation(pkgtmp, "tmptfiles"),
                                    JoinStringsWithSeparator(tfiles, "\n"));
          Exec(Concatenation("cd ", pkgtmp,"; find ", dnam, 
                             " -print >allfiles"));
          allfiles := SplitString(StringFile(Concatenation(pkgtmp,
                                  "allfiles")), "", "\n");
          FileString(Concatenation(pkgtmp, "tmpbfiles"), 
                  JoinStringsWithSeparator(Difference(allfiles, tfiles), "\n"));
          Exec(Concatenation("cd ", pkgtmp,"; rm -f ", fname, "-win.zip; ",
               "cat tmpbfiles | zip -9 ", fname, "-win.zip -@ > /dev/null; ",
               "cat tmptfiles | zip -9 -l ", fname, "-win.zip -@ > /dev/null"));
        else
          Print("Cannot create archive with format: ", fmt, "\n");
        fi;
      od;
    fi;
    # copy to Web and move archives
    for fmt in [".zoo", ".tar.gz", ".tar.bz2", "-win.zip"] do
      # first delete old ones from ftp dir
      old := List(FilesDir(pkg, "f", 1), Basename);
      old := Filtered(old, a-> Length(a)>=Length(fmt) and
             a{[Length(a)-Length(fmt)+1..Length(a)]} = fmt);
      for fn in old do
        Exec(Concatenation("rm -f ", pkg, "../../web/ftpdir/", 
             fmt{[2..Length(fmt)]}, "/packages/", fn));
      od;
      Exec(Concatenation("cd ", pkgtmp, "; cp -f ", fname, fmt,
                    " ../../../web/ftpdir/", fmt{[2..Length(fmt)]},
                    "/packages/")); 
      Exec(Concatenation("cd ", pkgtmp,"; mv -f ", fname, fmt,
                       " .."));
    od;

    # and get the README file
    bname := Basename(info.README_URL);
    Exec(Concatenation("cd ", pkgtmp,"; rm -f ", bname, 
         "; wget --timeout=60 --tries=1 ", info.README_URL, " 2>> wgetlog"));
    if IsExistingFile(Concatenation(pkgtmp, "/", bname)) then
      Exec(Concatenation("cd ", pkgtmp,"; mkdir -p ../../../web/Packages/",
           nam, "; cp -f ", bname, 
           " ../../../web/Packages/", nam, "/README.", nam, "; mv -f ", 
           bname, " ../README.", nam));
    else
      Print("#   Error: could not get README file.\n");
    fi;
  od;
  return res;
end;
 


# here we assume that the package archives themselves are already up to date
# if arg 'acc' is true, the acc... archives are recreated.
# if arg 'dep' is true, the dep... archives are recreated.
MergePackageArchivesOld := function(pkgdir, tmpdir, acc, dep)
  local accdir, depdir, pkgs, mv, textfilesacc, textfilesdep, nam, info, d, 
        tf, fname, rdm, fun, allfiles, pkg, str, a, date, out, archdir,
        archdir2;
  if tmpdir[Length(tmpdir)] <> '/' then
    tmpdir := Concatenation(tmpdir, "/");
  fi;
  if pkgdir[Length(pkgdir)] <> '/' then
    pkgdir := Concatenation(pkgdir, "/");
  fi;
  accdir := Concatenation(tmpdir, "acc/");
  depdir := Concatenation(tmpdir, "dep/");
  Exec(Concatenation("rm -rf ", accdir, " ", depdir));
  Exec(Concatenation("mkdir -p ", accdir, " ", depdir));
  pkgs := Difference(FilesDir(pkgdir, "d", 1), [pkgdir]);
  textfilesacc := [];
  textfilesdep := [];
  for pkg in pkgs do
    # try to read info file
    ClearPACKAGE_INFOS();
    READPackageInfo(Concatenation(pkg, "/", "PackageInfo.g"));
    nam := NamesOfComponents(PACKAGE_INFOS);
    if Length(nam) = 0 then
      continue;
    fi;
    nam := nam[1];
    info := PACKAGE_INFOS.(nam);
    # decide the corresponding merged archive
    if info.Status = "accepted" and acc = true then
      d := accdir;
      tf := textfilesacc;
    elif info.Status = "deposited" and dep = true then
      d := depdir;
      tf := textfilesdep;
    else
      continue;
    fi;
    fname := Basename(info.ArchiveURL);
    # collect text file names from zoo archive
    Append(tf, TextFilesInZooArchive(Concatenation(pkg, "/", fname, ".zoo")));
    # unpack from .tar.gz file
    Exec(Concatenation("cat ", pkg, "/", fname, ".tar.gz | (cd ", d, 
                       "; tar xzf - )" ) );
    # and copy the README file
    Exec(Concatenation("cp ", pkg, "/README.", nam, " ", d));
  od;

  # now create the merged archives, first accpkg then deppkg
  #  .tar first, then gzip and bzip2 it
  fun := function(pkgdir, dir, fn, textfiles)
    local allfiles;
    Exec(Concatenation("cd ", dir, "; tar cpf ../", fn, ".tar * ; cd .. ; ",
         "cp ", fn, ".tar ", fn, ".tar.X; gzip -9 ", fn, ".tar ; ",
         "mv -f ", fn, ".tar.X ", fn, ".tar; bzip2 -9 ", fn, ".tar ; "
         ));
    # then zoo it
    Exec(Concatenation("cd ", dir, "; ",
         "find * -print | zoo ahIq ../", fn, ".zoo "));
    # add !TEXT! comments to zoo archive
    for a in textfiles do
      Exec(Concatenation("cd ", dir, "/.. ; (echo '!TEXT!'; echo '/END')", 
           "| zoo c ", fn, ".zoo ", a));
    od;
    # and finally zip it 
    FileString(Concatenation(dir, "/../tmptfiles"),
                              JoinStringsWithSeparator(textfiles, "\n"));
    Exec(Concatenation("cd ", dir,"; find * ", " -print > ../allfiles"));
    allfiles := SplitString(StringFile(Concatenation(dir, "/../allfiles")), 
                            "", "\n");
    FileString(Concatenation(dir, "/../tmpbfiles"), 
            JoinStringsWithSeparator(Difference(allfiles, textfiles), "\n"));
    Exec(Concatenation("cd ", dir,"; ",
         "cat ../tmpbfiles | zip -9 ../", fn, "-win.zip -@ ; ",
         "cat ../tmptfiles | zip -9 -l ../", fn, "-win.zip -@"));
  end; 

  str := StringCurrentTime();
  while Length(str) > 0 and str[Length(str)] = '\n' do
    Unbind(str[Length(str)]);
  od;
 
  # arg cp is true for copy and false for move
  mv := function(archdir, dir, fn, cp)
    local cpmv;
    if cp then
      cpmv := "cp";
    else
      cpmv := "mv";
    fi;
    # copy to archdir, move away old archives
    Exec(Concatenation("cd ", archdir, "; mkdir -p old; touch ",
         fn, "* ; mv -f ", fn, "* old"));
    Exec(Concatenation(cpmv, " -f ", dir, "/", fn, "* ", archdir));
  end;
  archdir := Concatenation(pkgdir, "/../archives/");
  archdir2 := Concatenation(pkgdir, "/../web/Packages/");
  if acc = true then
    fun(pkgdir, accdir, Concatenation("accpkg-", str), textfilesacc);
    mv(archdir, tmpdir, "accpkg-", true);
    mv(archdir2, tmpdir, "accpkg-", false);
  fi;
  if dep = true then
    fun(pkgdir, depdir, Concatenation("deppkg-", str), textfilesdep);
    mv(archdir, tmpdir, "deppkg-", true);
    mv(archdir2, tmpdir, "deppkg-", false);
  fi;
end;

MergePackageArchives := function(pkgdir, tmpdir, inmerge)
  local mergedir, pkgs, mv, textfilesmerge, nam, info, d, fmt,
        tf, fname, rdm, fun, allfiles, pkg, str, a, date, out, archdir,
        archdir2;
  if tmpdir[Length(tmpdir)] <> '/' then
    tmpdir := Concatenation(tmpdir, "/");
  fi;
  if pkgdir[Length(pkgdir)] <> '/' then
    pkgdir := Concatenation(pkgdir, "/");
  fi;
  mergedir := Concatenation(tmpdir, "merge/");
  Exec(Concatenation("rm -rf ", mergedir));
  Exec(Concatenation("mkdir -p ", mergedir));
  pkgs := Difference(FilesDir(pkgdir, "d", 1), [pkgdir]);
  textfilesmerge := [];
  for pkg in pkgs do
    # try to read info file
    ClearPACKAGE_INFOS();
    READPackageInfo(Concatenation(pkg, "/", "PackageInfo.g"));
    nam := NamesOfComponents(PACKAGE_INFOS);
    if Length(nam) = 0 then
      continue;
    fi;
    nam := nam[1];
    info := PACKAGE_INFOS.(nam);
    # decide the corresponding merged archive
    if info.Status = "accepted" and inmerge = true then
      d := mergedir;
      tf := textfilesmerge;
    elif info.Status = "deposited" and inmerge = true then
      d := mergedir;
      tf := textfilesmerge;
    else
      continue;
    fi;
    if not IsBound(info.ArchiveURL) then
      continue;
    fi;
    fname := Basename(info.ArchiveURL);
    # collect text file names from zoo archive
    Append(tf, TextFilesInZooArchive(Concatenation(pkg, "/", fname, ".zoo")));
    # unpack from .tar.gz file
    Exec(Concatenation("cat ", pkg, "/", fname, ".tar.gz | (cd ", d, 
                       "; tar xzf - )" ) );
    # and copy the README file
    Exec(Concatenation("cp ", pkg, "/README.", nam, " ", d));
  od;

  # now create the merged archives, 
  #  .tar first, then gzip and bzip2 it
  fun := function(pkgdir, dir, fn, textfiles)
    local allfiles;
    Exec(Concatenation("cd ", dir, "; tar cpf ../", fn, ".tar * ; cd .. ; ",
         "cp ", fn, ".tar ", fn, ".tar.X; gzip -9 ", fn, ".tar ; ",
         "mv -f ", fn, ".tar.X ", fn, ".tar; bzip2 -9 ", fn, ".tar ; "
         ));
    # then zoo it
    Exec(Concatenation("cd ", dir, "; ",
         "find * -print | zoo ahIq ../", fn, ".zoo "));
    # add !TEXT! comments to zoo archive
    for a in textfiles do
      Exec(Concatenation("cd ", dir, "/.. ; (echo '!TEXT!'; echo '/END')", 
           "| zoo c ", fn, ".zoo ", a));
    od;
    # and finally zip it 
    FileString(Concatenation(dir, "/../tmptfiles"),
                              JoinStringsWithSeparator(textfiles, "\n"));
    Exec(Concatenation("cd ", dir,"; find * ", " -print > ../allfiles"));
    allfiles := SplitString(StringFile(Concatenation(dir, "/../allfiles")), 
                            "", "\n");
    FileString(Concatenation(dir, "/../tmpbfiles"), 
            JoinStringsWithSeparator(Difference(allfiles, textfiles), "\n"));
    Exec(Concatenation("cd ", dir,"; ",
         "cat ../tmpbfiles | zip -9 ../", fn, "-win.zip -@ > /dev/null ; ",
         "cat ../tmptfiles | zip -9 -l ../", fn, "-win.zip -@ > /dev/null "));
  end; 

  str := StringCurrentTime();
  while Length(str) > 0 and str[Length(str)] = '\n' do
    Unbind(str[Length(str)]);
  od;
 
  fun(pkgdir, mergedir, Concatenation("packages-", str), textfilesmerge);

  # cp merged to archive collection and ftp directory
  Exec(Concatenation("cd ", pkgdir, "/../archives; mkdir -p old; ",
       "touch packages-*; mv packages-* old; cp -f ", tmpdir, "/packages-* ",
       pkgdir, "/../archives; rm -f ", pkgdir, "/../web/ftpdir/*/packages-*"));
  for fmt in [".zoo", ".tar.gz", ".tar.bz2", "-win.zip"] do
    Exec(Concatenation("mv -f ", tmpdir, "/packages-*", fmt, " ", pkgdir, 
         "/../web/ftpdir/", fmt{[2..Length(fmt)]}, "/"));
  od;
       
##    # arg cp is true for copy and false for move
##    mv := function(archdir, dir, fn, cp)
##      local cpmv;
##      if cp then
##        cpmv := "cp";
##      else
##        cpmv := "mv";
##      fi;
##      # copy to archdir, move away old archives
##      Exec(Concatenation("cd ", archdir, "; mkdir -p old; touch ",
##           fn, "* ; mv -f ", fn, "* old"));
##      Exec(Concatenation(cpmv, " -f ", dir, "/", fn, "* ", archdir));
##    end;
##    archdir := Concatenation(pkgdir, "/../archives/");
##    archdir2 := Concatenation(pkgdir, "/../web/Packages/");
##    if inmerge = true then
##      fun(pkgdir, mergedir, Concatenation("packages-", str), textfilesmerge);
##      mv(archdir, tmpdir, "packages-", true);
##      mv(archdir2, tmpdir, "packages-", false);
##    fi;
end;

# returns list of [dirname, bookname] of updated packages
UpdatePackageDoc := function(pkgdir)
  local pkgs, res, nam, info, books, url, fname, pkgtmp, fmt, pkg, 
        b, pkgarch, a, dname, compactname;
  # package dirs
  pkgs := Difference(FilesDir(pkgdir, "d", 1), [pkgdir]);
  res := [];
  for pkg in pkgs do
    ClearPACKAGE_INFOS();
    READPackageInfo(Concatenation(pkg, "/PackageInfo.g"));
    nam := NamesOfComponents(PACKAGE_INFOS);
    if Length(nam) = 0 then
      continue;
    fi;
    nam := nam[1];
    info := PACKAGE_INFOS.(nam);
    Print(info.PackageName, ":\n");
    pkgtmp := Concatenation(pkg, "/tmp/");
    if not IsBound(info.PackageDoc) then
      Print("# Warning: no PackageDoc component!\n");
      continue;
    fi;
    # check if one or several books
    if IsList(info.PackageDoc) then
      books := info.PackageDoc;
    else
      books := [info.PackageDoc];
    fi;

    for b in books do
      if IsBound(b.ArchiveURLSubset) then
        # get files from main package archive
        pkgarch := Concatenation(Basename(info.ArchiveURL), ".tar.gz");
        # we store the archive name when we unpack the doc for this book
        compactname := Filtered(b.BookName, x-> not x in " \t\n\b\r");
        if IsExistingFile(Concatenation(pkgdir, "/", nam, "/docversion", 
                  compactname, pkgarch)) then
          Print("  help book ", b.BookName, " is up-to-date.\n"); 
          continue;
        else
          Print("  updating help book ", b.BookName, " from main archive.\n");
        fi;
        # so we need to extract the book
        Exec(Concatenation("rm -rf ", pkgtmp, "; mkdir -p ", pkgtmp));
        Exec(Concatenation("cd ", pkgtmp, "; tar xzf ../", pkgarch));
        dname := NormalizedWhitespace(StringSystem("sh", "-c", 
                     Concatenation("cd ", pkgtmp, "; ls")));
        for a in b.ArchiveURLSubset do
          Exec(Concatenation("cd ", pkgtmp, "/", dname, "; cp -r --parents ", 
               a, " .."));
        od;
        Exec(Concatenation("cd ", pkgtmp, "; rm -rf ", dname));
        Exec(Concatenation("touch ", pkgtmp, "/../docversion", compactname,
                                                                    pkgarch));
        Add(res, [nam, b.BookName]);
      elif IsBound(b.Archive) then
        url := b.Archive;
        fname := Basename(url);
        # check if it is already in the local collection
        if IsExistingFile(Concatenation(pkgdir, "/", nam, 
                          "/", fname)) then
          Print("  doc archive ", b.BookName, " is up-to-date.\n");
          continue;
        else
          Print("  updating help book ", b.BookName, 
                " from separate archive.\n");
        fi;
         
        # ok, so we have to get the archive
        Add(res, [nam, b.BookName]);
        Exec(Concatenation("rm -rf ", pkgtmp, "; mkdir -p ", pkgtmp));
        Exec(Concatenation("cd ", pkgtmp, ";wget --timeout=60 --tries=1 ", 
             url, " 2>> wgetlog"));
        fmt := url{[Length(url)-3..Length(url)]};
        # for SECURITY: don't allow unpacking of ../.... or /... files 
        if not IsLocalArchive(Concatenation(pkgtmp, fname)) then
          Print("    REJECTING book archive ", [nam, b.BookName], " because ",
                "of non-allowed paths!!!\n");
        fi;
        Print("  unpacking new documentation ", fname, "\n");
        if fmt = ".zoo" then
          Exec(Concatenation("cd ", pkgtmp, ";unzoo -x ", fname, 
               " > /dev/null 2>&1"));
        elif fmt = "r.gz" then
          Exec(Concatenation("cd ", pkgtmp, ";gzip -dc ", fname, 
               " |tar xf - "));
        elif fmt = ".bz2" then
          Exec(Concatenation("cd ", pkgtmp, ";bzip2 -dc ", fname, 
               " |tar xf - "));
        elif fmt = ".zip" then
          Exec(Concatenation("cd ", pkgtmp, ";unzip -a ", fname));
        else
          Error("no recognized archive format: ", fmt);
        fi;
      else
        Print("   No package documentation specified!\n");
      fi;
      # move to web dir and to archives
      Exec(Concatenation("cd ", pkgtmp, "; rm -f wgetlog ; ",
        "mkdir -p ../../../web/Packages/", nam, 
        "; cp -fr * ../../../web/Packages/", nam,  "; cp -fr * ..; rm -rf *"));
    od;
  od;
  return res;
end;



AddHTMLPackageInfoOld := function(info)
  local NameChunk, nam, res, auth, maint, books, dep, arch, 
        ss, fn, s, a, i, p, ext;
  NameChunk := function(r)
    local res;
    res := Concatenation(r.FirstNames, " ", r.LastName);
    # we add link to webpage, if available, or a mailto link, if email
    # address available
    if IsBound(r.WWWHome) then
      res := Concatenation("<a href=\"", r.WWWHome, "\">", res, "</a>"); 
    elif IsBound(r.Email) then
      res := Concatenation("<a href=\"mailto:", r.Email, "\">", res, "</a>"); 
    fi;
    return res;
  end;

  # directory name
  nam := NormalizedWhitespace(LowercaseString(info.PackageName));
  
  # header line with link to package home page
  res := Concatenation("<p><b><a href=\"", info.PackageWWWHome, "\">",
         "<span class=\"pkgname\">", info.PackageName,
           "</span></a></b>, \n");
  
  # summary
  Append(res, Concatenation("<em>", info.AbstractHTML, "</em>"));

  # author(s)/maintainer(s) list, possibly with links
  auth := []; 
  maint := [];
  for a in info.Persons do
    if IsBound(a.IsAuthor) and a.IsAuthor = true then
      Add(auth, a);
    elif IsBound(a.IsMaintainer) and a.IsMaintainer = true then
      Add(maint, a);
    fi;
  od;
  if Length(auth) > 0 then
    Append(res, "<br />\n&nbsp;&nbsp;&nbsp;<strong>Author");
    if Length(auth) > 1 then
      Add(res, 's');
    fi;
    Append(res, ": </strong>");
    Append(res, NameChunk(auth[1]));
    for i in [2..Length(auth)]  do
      Append(res, Concatenation(", \n",  NameChunk(auth[i])));
    od;
    Append(res, "\n");
  fi;
  if Length(maint) > 0 then
    Append(res, "<br />\n&nbsp;&nbsp;&nbsp;<strong>Maintainer");
    if Length(maint) > 1 then
      Add(res, 's');
    fi;
    Append(res, ": </strong>");
    Append(res, NameChunk(maint[1]));
    for i in [2..Length(maint)]  do
      Append(res, Concatenation(", \n",  NameChunk(maint[i])));
    od;
    Append(res, "\n");
  fi;
  
  # version / date
  Append(res, Concatenation("<br />\n&nbsp;&nbsp;&nbsp;<strong>Version: ",
                 "</strong>", info.Version, 
                 " ---&nbsp;Released: ", info.Date, "\n"));

  # status
  Append(res, Concatenation("<br />\n&nbsp;&nbsp;&nbsp;<strong>Status: ",
              "</strong>",  info.Status, "\n"));

  # communicated by ...
  if IsBound(info.CommunicatedBy) then
    Append(res, Concatenation("<br />\n&nbsp;&nbsp;&nbsp;<strong>Communicated ",
                   "by: </strong>", 
                   info.CommunicatedBy,
                   "\n"));
    Append(res, Concatenation("(", info.AcceptDate, ")\n"));
  fi;

  # online documentation
  if not IsList(info.PackageDoc) then
    books := [info.PackageDoc];
  else
    books := info.PackageDoc;
  fi;
  Append(res, "<br />\n&nbsp;&nbsp;&nbsp;<strong>Online documentation: </strong>");
  for a in books do
    Append(res, a.BookName );
    Append(res, ": ");
    if IsBound(a.HTMLStart) then
      Append(res, Concatenation(" <a href='", nam,  "/", a.HTMLStart, 
              "'> [HTML]</a>&nbsp;&nbsp;" ));
    fi;
    if IsBound(a.PDFFile) then
      Append(res, Concatenation(" <a href='", nam, "/", a.PDFFile, 
              "'> [PDF]</a>&nbsp;&nbsp;" ));
    fi;
  od;
  
  # dependencies
  dep := info.Dependencies;
  Append(res, "<br />\n&nbsp;&nbsp;&nbsp;<strong>Dependencies: </strong>");
  Append(res, Concatenation("<span class='pkgname'>GAP</span> (", 
         dep.GAP, ")"));
  if Length(dep.NeededOtherPackages) > 0 then
    Append(res, ", needed other packages: ");
    for p in dep.NeededOtherPackages do
      Append(res, Concatenation(p[1], "(", p[2], "), "));
    od;
  fi;
  if Length(dep.SuggestedOtherPackages) > 0 then
    Append(res, ", suggested other packages: ");
    for p in dep.SuggestedOtherPackages do
      Append(res, Concatenation(p[1], "(", p[2], "), "));
    od;
  fi;
  if Length(dep.ExternalConditions) > 0 then
    Append(res, " external needs: ");
    s := List(dep.ExternalConditions, function(a)
      if IsString(a) then 
        return a;
      else
        return Concatenation("<a href='", String(a[2]), "'>", String(a[1]),
               "</a>");
      fi;
    end);
    Append(res, JoinStringsWithSeparator(s, ",\n"));
  fi;
 
  # links to archives
  Append(res, "<br />\n&nbsp;&nbsp;&nbsp;<strong>Download archives: </strong>");
  # README and then archives
  arch := Concatenation(nam, "/", Basename(info.ArchiveURL));
  Append(res, Concatenation("<a href='{{GAPManualLink}}pkg/", 
          nam, "/README.", nam, 
          "'>[README]</a>&nbsp;&nbsp;"));
  for ext in [".zoo", ".tar.gz",  "-win.zip", ".tar.bz2"] do
    fn := Concatenation(arch, ext);
    s := StringSizeFilename(fn);
    Append(res, Concatenation("[<a href='", arch, ext, "'>", ext, 
           " (", s, ")</a>]&nbsp;&nbsp;\n"));
  od;
  Append(res, "\n");
  Append(res, "</p>\n\n");
  info.HTMLInfo := res;
  return res;
end;

# Write the <pkgname>.mixer file for a package
# args: info[, webdir]                    default for webdir is "../web"
AddHTMLPackageInfo := function(arg)
  local info, webdir, NameChunk, nam, res, auth, maint, dep, s, books, 
        manlink, bnam, arch, fn, a, i, p, ext;
  info := arg[1];
  if Length(arg)>1 then
    webdir := arg[2];
  else
    webdir := "../web";
  fi;
  NameChunk := function(r)
    local res;
    res := Concatenation(r.FirstNames, " ", r.LastName);
    # we add link to webpage, if available, or a mailto link, if email
    # address available
    if IsBound(r.WWWHome) then
      res := Concatenation("<a href=\"", r.WWWHome, "\">", res, "</a>"); 
    elif IsBound(r.Email) then
      res := Concatenation("<a href=\"mailto:", r.Email, "\">", res, "</a>"); 
    fi;
    return res;
  end;

  # directory name
  nam := NormalizedWhitespace(LowercaseString(info.PackageName));
  
  res := Concatenation("<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n",
         "<mixer template=\"gw.tmpl\">\n");
  # header line with link to package home page
  Append(res, Concatenation("<mixertitle><mixer var=\"GAP\"/> package ", 
         info.PackageName, 
         "</mixertitle>\n\n"));

  if IsBound(info.Subtitle) then
    Append(res, Concatenation("<h2>", info.Subtitle, "</h2>\n"));
  fi;
  if not IsBound(info.PackageWWWHome) then
    info.PackageWWWHome := "n.a.";
  fi;
  Append(res, Concatenation("<p class=\"homelink\">[<a href=\"",
         info.PackageWWWHome, "\">WWW homepage</a>]</p>\n"));
  # author(s)/maintainer(s) list, possibly with links
  auth := []; 
  maint := [];
  if not IsBound(info.Persons) then
    info.Persons := [];
  fi;
  for a in info.Persons do
    if IsBound(a.IsAuthor) and a.IsAuthor = true then
      Add(auth, a);
    elif IsBound(a.IsMaintainer) and a.IsMaintainer = true then
      Add(maint, a);
    fi;
  od;
  if Length(auth) > 0 then
    Append(res, "<h4>Author");
    if Length(auth) > 1 then
      Add(res, 's');
    fi;
    Append(res, "</h4>\n<p>");
    Append(res, NameChunk(auth[1]));
    for i in [2..Length(auth)]  do
      Append(res, Concatenation(", \n",  NameChunk(auth[i])));
    od;
    Append(res, "</p>\n");
  fi;
  if Length(maint) > 0 then
    Append(res, "<h4>Maintainer");
    if Length(maint) > 1 then
      Add(res, 's');
    fi;
    Append(res, "</h4>\n<p>");
    Append(res, NameChunk(maint[1]));
    for i in [2..Length(maint)]  do
      Append(res, Concatenation(", \n",  NameChunk(maint[i])));
    od;
    Append(res, "\n</p>\n");
  fi;
  
  # summary
  if not IsBound(info.AbstractHTML) then
    info.AbstractHTML := "";
  fi;
  Append(res, Concatenation("<h4>Short Description</h4>\n<p><![CDATA[", 
              info.AbstractHTML, "]]>\n</p>\n"));

  # version / date
  if not IsBound(info.Version) then
    info.Version := "unknown";
  fi;
  if not IsBound(info.Date) then
    info.Date := "unknown";
  fi;
  Append(res, Concatenation("<h4>Version</h4>\n<p> Current version number ",
                 info.Version, 
                 " &nbsp;&nbsp;(Released  ", info.Date, ")\n</p>\n"));
  # SuggestUpgrades  entry
  info.SuggestUpgradesEntry := Concatenation("[ \"", info.PackageName,
       "\", \"", info.Version, "\" ], ");
  # status
  Append(res, Concatenation("<h4>Status</h4>\n<p>",
              info.Status, "\n"));
  # communicated by ...
  if IsBound(info.CommunicatedBy) then
    Append(res, Concatenation("&nbsp;&nbsp; (communicated  by ",
                   info.CommunicatedBy,
                   ", \n"));
    if not IsBound(info.AcceptDate) then
      info.AcceptDate := "unknown";
    fi;
    Append(res, Concatenation("accepted ", info.AcceptDate, ")\n"));
  fi;
  Append(res, "</p>\n");

  # dependencies
  if IsBound(info.Dependencies) then
    dep := info.Dependencies;
    Append(res, "<h4>Dependencies</h4>\n<p>\n");
    if not IsBound(dep.GAP) then
      dep.GAP := "unknown";
    fi;
    Append(res, Concatenation("<span class='pkgname'>GAP</span> ",
           "version: ", dep.GAP, "<br />"));
    if IsBound(dep.NeededOtherPackages) and 
                         Length(dep.NeededOtherPackages) > 0 then
      Append(res, "Needed other packages: ");
      for p in dep.NeededOtherPackages do
        Append(res, Concatenation(p[1], "(", p[2], "), "));
      od;
      Append(res, "<br />");
    fi;
    if IsBound(dep.SuggestedOtherPackages) and
                          Length(dep.SuggestedOtherPackages) > 0 then
      Append(res, "Suggested other packages: ");
      for p in dep.SuggestedOtherPackages do
        Append(res, Concatenation(p[1], "(", p[2], "), "));
      od;
      Append(res, "<br />");
    fi;
    if IsBound(dep.ExternalConditions) and
                           Length(dep.ExternalConditions) > 0 then
      Append(res, "External needs: ");
      s := List(dep.ExternalConditions, function(a)
        if IsString(a) then 
          return a;
        else
          return Concatenation("<a href='", String(a[2]), "'>", String(a[1]),
                 "</a>");
        fi;
      end);
      Append(res, JoinStringsWithSeparator(s, ",\n"));
    fi;
    Append(res,"\n</p>\n");
  fi;
 
  # online documentation
  if not IsBound(info.PackageDoc) then
    info.PackageDoc := [];
  fi;
  if not IsList(info.PackageDoc) then
    books := [info.PackageDoc];
  else
    books := info.PackageDoc;
  fi;
  Append(res, "<h4>Online documentation</h4>\n");
  info.HTMLManLinks := "";
  for a in books do
    Append(res, "<p>");
    Append(res, a.BookName );
    Append(res, ": ");
    manlink := "<tr><td>";
    if IsBound(a.HTMLStart) then
      Append(res, Concatenation(" [<a href='{{GAPManualLink}}pkg/", 
              nam,  "/", a.HTMLStart, 
              "'> HTML</a>] version&nbsp;&nbsp;" ));
      Append(manlink, Concatenation("<a href=\"{{GAPManualLink}}pkg/", 
        nam, "/", a.HTMLStart, "\">", a.BookName, "</a></td>"));
    else
      Append(manlink, Concatenation(a.BookName, "</td>"));
    fi;
    if IsBound(a.PDFFile) then
      Append(res, Concatenation(" [<a href='{{GAPManualLink}}pkg/", 
              nam, "/", a.PDFFile, 
              "'> PDF</a>] version&nbsp;&nbsp;" ));
      Append(manlink, Concatenation("<td>[<a href=\"{{GAPManualLink}}pkg/",
        nam, "/", a.PDFFile, "\">PDF</a>]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>"));
    else
      Append(manlink, "<td>&nbsp;</td>");
    fi;
    Append(res,"\n</p>\n");
    # link entry for manuals overview
    if IsBound(a.LongTitle) then 
      Append(manlink, Concatenation("<td>", a.LongTitle, "</td></tr>\n"));
    else
      Append(manlink, "<td>&nbsp;</td></tr>\n");
    fi;
    Append(info.HTMLManLinks, manlink);
  od;
  
  # links to archives
  Append(res, "<h4>Download</h4>\n<p>");
  # README and then archives
  if not IsBound(info.ArchiveURL) then
    info.ArchiveURL := "n.a.";
  fi;
  bnam := Basename(info.ArchiveURL);
  arch := Concatenation(nam, "/", bnam);
  Append(res, Concatenation("[<a href='{{GAPManualLink}}pkg/", 
          nam, "/README.", nam, 
          "'>README</a>]&nbsp;&nbsp;&nbsp;&nbsp;",bnam));
  for ext in [".zoo", ".tar.gz",  "-win.zip", ".tar.bz2"] do
    fn := Concatenation(webdir, "/ftpdir/", ext{[2..Length(ext)]}, 
          "/packages/", bnam, ext);
    s := StringSizeFilename(fn);
    Append(res, Concatenation("[<a href='{{gap4ftp}}", ext{[2..Length(ext)]}, 
           "/packages/", bnam, ext, "'>", ext, 
           "&nbsp; (", s, ")</a>]&nbsp;&nbsp;\n"));
  od;
  Append(res, "\n");
  Append(res, "</p>\n\n");

  # full given contact information
  Append(res, "<h4>Contact</h4>\n<p>\n");
  if not IsBound(info.Persons) then
    info.Persons := [];
  fi;
  for a in info.Persons do
    Append(res, Concatenation(a.FirstNames, " ", a.LastName, "<br />\n"));
    if IsBound(a.PostalAddress) then
      Append(res, "Address:<br />\n");
      Append(res, SubstitutionSublist(a.PostalAddress,"\n", "<br />\n"));
      Append(res, "<br />\n");
    fi;
    if IsBound(a.WWWHome) then
      Append(res, "WWW: <a href=\"");
      Append(res, Concatenation(a.WWWHome, "\">", a.WWWHome, "</a><br />\n"));
    fi;
    if IsBound(a.Email) then
      Append(res, "E-mail: <a href=\"mailto:");
      Append(res, Concatenation(a.Email, "\">", a.Email, "</a><br />\n"));
    fi;
    Append(res,"</p><p>\n");
  od;
  Append(res, "</p>\n");
  Append(res,"\n</mixer>\n");

  info.HTMLInfoMixer := res;
  return res;
end;

WritePackageInputWebFileOld := function(inclfilename)
  local inc, arch, subs, fn, s, pi, ext, a;
  inc := StringFile(inclfilename);
  # merged archives:
  arch := Chomp(StringSystem("sh", "-c", "ls accpkg*.zoo"));
  arch := arch{[1..Length(arch)-4]};
  subs := ShallowCopy(arch);
  for ext in [".zoo", ".tar.gz",  "-win.zip", ".tar.bz2"] do
    fn := Concatenation(arch, ext);
    s := StringSizeFilename(fn);
    Append(subs, Concatenation("[<a href='", arch, ext, "'>", ext, 
           " (", s, ")</a>]&nbsp;&nbsp;\n"));
  od;
  inc := SubstitutionSublist(inc, "##Include-latest-accpkg", subs);
  arch := Chomp(StringSystem("sh", "-c", "ls deppkg*.zoo"));
  arch := arch{[1..Length(arch)-4]};
  subs := ShallowCopy(arch);
  for ext in [".zoo", ".tar.gz",  "-win.zip", ".tar.bz2"] do
    fn := Concatenation(arch, ext);
    s := StringSizeFilename(fn);
    Append(subs, Concatenation("[<a href='", arch, ext, "'>", ext, 
           " (", s, ")</a>]&nbsp;&nbsp;\n"));
  od;
  inc := SubstitutionSublist(inc, "##Include-latest-deppkg", subs);

  pi := PACKAGE_INFOS;
  for a in NamesOfComponents(pi) do
    AddHTMLPackageInfo(pi.(a));
    if IsRecord(pi.(a)) and IsBound(pi.(a).HTMLInfo) then
      inc := SubstitutionSublist(inc, Concatenation("##Include-", a),
             pi.(a).HTMLInfo);
    fi;
  od;
  FileString(Concatenation(Dirname(inclfilename), "/pkg.input"), inc);
end;

# this functions fills lines of type <!--Link_ace--> in template for
#      packages.mixer     (the template is <webdir>/packages.mixer.templ
# and creates the short info pages for each package, like ace.mixer, ...
# (these files are in webdir)
PACKAGEMIXERDIRS := rec(
  atlasrep := "/Datalib", smallgroups := "/Datalib", crystcat := "/Datalib",
  aclib := "/Datalib", ctbllib := "/Datalib" );
                
UpdatePackageWebPagesOld := function(webdir)
  local templ, fl, fn, treelines, pi, nam, pkgmix, mixfile, 
        linkentry, ss, s, tree, a, pers, lnam;
  Print("Updating package web pages ...\n");
  templ := StringFile(Concatenation(webdir, "/Packages/packages.mixer.templ"));
  treelines := [];
  pi := PACKAGE_INFOS;
  # find combined package files
  fl := SplitString(StringSystem("ls", Concatenation(webdir, "/Packages/")),
                    "", "\n");
  fn := First(fl, a-> Length(a)>8 and a{[1..8]} = "packages" and 
        a{[Length(a)-6..Length(a)]} = ".tar.gz");
  if fn <> fail then
    fn := fn{[1..Length(fn)-7]};
    templ := SubstitutionSublist(templ, "<!--packageslinks-->",
          Concatenation("Combined archives:&nbsp;&nbsp;&nbsp; ",fn,
          "[<a href=\"",fn,".zoo\">.zoo (", 
          StringSizeFilename(Concatenation(webdir,"/Packages/",fn,".zoo")),
          ")</a>]&nbsp;&nbsp;&nbsp;\n",
          "[<a href=\"",fn,".tar.gz\">.tar.gz (", 
          StringSizeFilename(Concatenation(webdir,"/Packages/",fn,".tar.gz")),
          ")</a>]&nbsp;&nbsp;&nbsp;\n",
          "[<a href=\"",fn,"-win.zip\">-win.zip (", 
          StringSizeFilename(Concatenation(webdir,"/Packages/",fn,"-win.zip")),
          ")</a>]&nbsp;&nbsp;&nbsp;\n",
          "[<a href=\"",fn,".tar.bz2\">.tar.bz2 (", 
          StringSizeFilename(Concatenation(webdir,"/Packages/",fn,".tar.bz2")),
          ")</a>]\n"));
  fi;
  
  # write the <pkgname>.mixer files and fill the package.mixer entries and
  # the 'tree' file
  for a in NamesOfComponents(pi) do
    nam := pi.(a).PackageName;
    lnam := LowercaseString(pi.(a).PackageName);
    pkgmix := AddHTMLPackageInfo(pi.(a));
    mixfile := "";
    if IsBound(PACKAGEMIXERDIRS.(lnam)) then
      Append(mixfile, PACKAGEMIXERDIRS.(lnam));
      Add(treelines, [lnam, 
                      Concatenation("  <entry file=\"..",
                      PACKAGEMIXERDIRS.(lnam), "/", lnam, ".html\">",
                      nam, "</entry>\n")]);
    else
      Append(mixfile, "/Packages");
      Add(treelines, [lnam, 
                      Concatenation("  <entry file=\"", lnam, ".html\">",
                      nam, "</entry>\n")]);
    fi;
    Append(mixfile, Concatenation("/", lnam));
    FileString(Concatenation(webdir, mixfile, ".mixer"), pkgmix);
    linkentry := Concatenation("<li><a href=\"", mixfile, ".html\">",
                 nam, "</a>&nbsp;&nbsp; by ");
    ss := [];
    if not IsBound(pi.(a).Persons) then
      pi.(a).Persons := [];
    fi;
    for pers in pi.(a).Persons do
      s := List(SplitString(pers.FirstNames, "", " "), x-> 
                Concatenation(x{[1]}, ". "));
      Add(ss, Concatenation(Concatenation(s), pers.LastName)); 
    od;
    Append(linkentry, JoinStringsWithSeparator(ss, ", "));
    if IsBound(pi.(a).Subtitle) then
      Append(linkentry, Concatenation("\n<br />", pi.(a).Subtitle, "\n"));
    fi;
    Append(linkentry, "</li>\n");
    templ := SubstitutionSublist(templ, Concatenation("<!--Link_", lnam,
             "-->"), linkentry);
  od;
  # write package.mixer
  FileString(Concatenation(webdir, "/Packages/packages.mixer"), templ);
  # and the tree file, all packages sorted alphabetically by name
  tree := Concatenation("<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n",
          "<node file=\"packages.html\">\n");
  Sort(treelines);
  for a in treelines do
    Append(tree, a[2]);
  od;
  Append(tree, "</node>\n");
  FileString(Concatenation(webdir, "/Packages/tree"), tree); 
end;

UpdatePackageWebPages := function(webdir)
  local mergedarchivelinks, templ, treelines, pi, fl, fn, manualslinks, 
    suggestupgradeslines, nam, lnam, pkgmix, mixfile, linkentry, ss, s, 
    tree, mantempl, names, str, lines, strs, updtempl, a, pers, l, 
    mainarchivelinks, xtomarchivelinks, toolsarchivelinks, webftp;
  Print("Updating package web pages ...\n");


  templ := StringFile(Concatenation(webdir, "/Packages/packages.mixer.templ"));
  treelines := [];
  pi := PACKAGE_INFOS;
  # find combined package files
  fl := SplitString(StringSystem("ls", 
           Concatenation(webdir, "/ftpdir/tar.gz/")), "", "\n");
  fn := First(fl, a-> Length(a)>8 and a{[1..9]} = "packages-" and 
        a{[Length(a)-6..Length(a)]} = ".tar.gz");
  if fn <> fail then
    fn := fn{[1..Length(fn)-7]};
  else
    Print("No merged package-*.tar.gz\n");
    fn := "nopackage";
  fi;
  # can be used in several places
  mergedarchivelinks := 
     Concatenation(fn,
          "[<a href=\"{{gap4ftp}}zoo/",fn,".zoo\">.zoo (", 
          StringSizeFilename(Concatenation(webdir,"/ftpdir/zoo/",fn,".zoo")),
          ")</a>]\n",
          "[<a href=\"{{gap4ftp}}tar.gz/",fn,".tar.gz\">.tar.gz (", 
          StringSizeFilename(Concatenation(webdir,"/ftpdir/tar.gz/",
          fn,".tar.gz")), ")</a>]\n",
          "[<a href=\"{{gap4ftp}}tar.bz2/",fn,".tar.bz2\">.tar.bz2 (", 
          StringSizeFilename(Concatenation(webdir,"/ftpdir/tar.bz2/",
          fn,".tar.bz2")), ")</a>]\n",
          "[<a href=\"{{gap4ftp}}win.zip/",fn,"-win.zip\">-win.zip (", 
          StringSizeFilename(Concatenation(webdir,"/ftpdir/win.zip/",
          fn,"-win.zip")), ")</a>]\n"
          );
  templ := SubstitutionSublist(templ, "<!--packageslinks-->",
             mergedarchivelinks);
  
  # write the <pkgname>.mixer files and fill the package.mixer entries and
  # the 'tree' file and manual overview lines and SuggestUpgrade args
  manualslinks := rec();
  suggestupgradeslines := rec();
  for a in NamesOfComponents(pi) do
    nam := pi.(a).PackageName;
    lnam := LowercaseString(pi.(a).PackageName);
    pkgmix := AddHTMLPackageInfo(pi.(a));
    mixfile := "";
    # line for 'tree' file
    if IsBound(PACKAGEMIXERDIRS.(lnam)) then
      Append(mixfile, PACKAGEMIXERDIRS.(lnam));
      Add(treelines, [lnam, 
                      Concatenation("  <entry file=\"..",
                      PACKAGEMIXERDIRS.(lnam), "/", lnam, ".html\">",
                      nam, "</entry>\n")]);
    else
      Append(mixfile, "/Packages");
      Add(treelines, [lnam, 
                      Concatenation("  <entry file=\"", lnam, ".html\">",
                      nam, "</entry>\n")]);
    fi;
    # write <pkgname>.mixer file
    Append(mixfile, Concatenation("/", lnam));
    FileString(Concatenation(webdir, mixfile, ".mixer"), pkgmix);
    linkentry := Concatenation("<li><a href=\"", mixfile, ".html\">",
                 nam, "</a>&nbsp;&nbsp; by ");
    # list entry in overview
    ss := [];
    if not IsBound(pi.(a).Persons) then
      pi.(a).Persons := [];
    fi;
    for pers in pi.(a).Persons do
      s := List(SplitString(pers.FirstNames, "", " "), x-> 
                Concatenation(x{[1]}, ". "));
      Add(ss, Concatenation(Concatenation(s), pers.LastName)); 
    od;
    Append(linkentry, JoinStringsWithSeparator(ss, ", "));
    if IsBound(pi.(a).Subtitle) then
      Append(linkentry, Concatenation("\n<br />", pi.(a).Subtitle, "\n"));
    fi;
    Append(linkentry, "</li>\n");
    templ := SubstitutionSublist(templ, Concatenation("<!--Link_", lnam,
             "-->"), linkentry);

    manualslinks.(lnam) := pi.(a).HTMLManLinks;
    suggestupgradeslines.(lnam) := pi.(a).SuggestUpgradesEntry;
  od;
  
  # write package.mixer
  FileString(Concatenation(webdir, "/Packages/packages.mixer"), templ);
  # and the tree file, all packages sorted alphabetically by name
  tree := Concatenation("<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n",
          "<node file=\"packages.html\">\n  ",
          "<entry file=\"Authors.html\">For Authors</entry>\n");
  Sort(treelines);
  for a in treelines do
    Append(tree, a[2]);
  od;
  Append(tree, "</node>\n");
  FileString(Concatenation(webdir, "/Packages/tree"), tree); 

  # now the manuals overview
  mantempl := StringFile(Concatenation(webdir, "/Manuals/manuals.mixer.templ"));
  names := ShallowCopy(NamesOfComponents(manualslinks));
  Sort(names);
  str := JoinStringsWithSeparator(List(names, a-> manualslinks.(a)), "\n");
  mantempl := SubstitutionSublist(mantempl, "<!--pkgmanualslinks-->", str);
  FileString(Concatenation(webdir, "/Manuals/manuals.mixer"), mantempl);
  
  # info for SuggestUpgrades
  names := ShallowCopy(NamesOfComponents(suggestupgradeslines));
  Sort(names);
  # read kernel and library versions from file
  Read(Concatenation(webdir, "/Download/versions.g"));
  lines := [ Concatenation("[ \"GAPKernel\", \"", GAPKernelVersion, "\" ], "),
           Concatenation("[ \"GAPLibrary\", \"", GAPLibraryVersion, "\" ], ")];
  # now sort by package name and format for lines < 65 characters
  for a in names do
    Add(lines, suggestupgradeslines.(a));
  od;
  strs := [];
  str := "        ";
  for l in lines do;
    if Length(str) + Length(l) < 65 then
      Append(str, l);
    else
      Add(strs, str);
      str := Concatenation("        ", l);
    fi;
  od;
  Add(strs, str);
  str := JoinStringsWithSeparator(strs, "\n");
  updtempl := StringFile(Concatenation(webdir, 
                                        "/Download/upgrade.mixer.templ"));
  updtempl := SubstitutionSublist(updtempl, "<!--SuggestUpgradeLines-->",
                str);
  FileString(Concatenation(webdir, "/Download/upgrade.mixer"), updtempl);

  # now we collect further archive links, assuming that gap4rXXX, tools4rXXX
  # and xtom1r1XXX archives are copied to web/ftpdir/<fmt>
  webftp := Concatenation(webdir, "/ftpdir/");
  fl := SplitString(StringSystem("ls", 
          Concatenation(webftp, "tar.gz/")),
                    "", "\n");
  fn := First(fl, a-> Length(a)>8 and a{[1..4]} = "gap4" and 
        a{[Length(a)-6..Length(a)]} = ".tar.gz");
  if fn <> fail then
    fn := fn{[1..Length(fn)-7]};
  else
    Print("No gap4*.tar.gz:", fl, "\n");
    fn := "nogap4";
  fi;
  mainarchivelinks := 
     Concatenation(fn,
          "[<a href=\"{{gap4ftp}}zoo/",fn,".zoo\">.zoo (", 
          StringSizeFilename(Concatenation(webftp, "zoo/",fn,".zoo")),
          ")</a>]\n",
          "[<a href=\"{{gap4ftp}}tar.gz/",fn,".tar.gz\">.tar.gz (", 
          StringSizeFilename(Concatenation(webftp, "tar.gz/",fn,".tar.gz")),
          ")</a>]\n",
          "[<a href=\"{{gap4ftp}}tar.bz2/",fn,".tar.bz2\">.tar.bz2 (", 
          StringSizeFilename(Concatenation(webftp, "tar.bz2/",fn,".tar.bz2")),
          ")</a>]\n",
          "[<a href=\"{{gap4ftp}}win.zip/",fn,"-win.zip\">-win.zip (", 
          StringSizeFilename(Concatenation(webftp,"win.zip/",fn,"-win.zip")),
          ")</a>]\n"
          );
  fn := First(fl, a-> Length(a)>8 and a{[1..5]} = "tools" and 
        a{[Length(a)-6..Length(a)]} = ".tar.gz");
  if fn <> fail then
    fn := fn{[1..Length(fn)-7]};
  else
    Print("No tools*.tar.gz:", fl, "\n");
    fn := "notools";
  fi;
  toolsarchivelinks := 
     Concatenation(fn,
          "[<a href=\"{{gap4ftp}}zoo/",fn,".zoo\">.zoo (", 
          StringSizeFilename(Concatenation(webftp,"zoo/",fn,".zoo")),
          ")</a>]\n",
          "[<a href=\"{{gap4ftp}}tar.gz/",fn,".tar.gz\">.tar.gz (", 
          StringSizeFilename(Concatenation(webftp,"tar.gz/",fn,".tar.gz")),
          ")</a>]\n",
          "[<a href=\"{{gap4ftp}}tar.bz2/",fn,".tar.bz2\">.tar.bz2 (", 
          StringSizeFilename(Concatenation(webftp,"tar.bz2/",fn,".tar.bz2")),
          ")</a>]\n",
          "[<a href=\"{{gap4ftp}}win.zip/",fn,"-win.zip\">-win.zip (", 
          StringSizeFilename(Concatenation(webftp,"win.zip/",fn,"-win.zip")),
          ")</a>]\n"
          );
  # only for 4.4, afterwards independent package
  fn := First(fl, a-> Length(a)>8 and a{[1..4]} = "xtom" and 
        a{[Length(a)-6..Length(a)]} = ".tar.gz");
  if fn <> fail then
    fn := fn{[1..Length(fn)-7]};
  else
    Print("No xtom*.tar.gz:", fl, "\n");
    fn := "xtom4";
  fi;
  xtomarchivelinks := 
     Concatenation(fn,
          "[<a href=\"{{gap4ftp}}zoo/",fn,".zoo\">.zoo (", 
          StringSizeFilename(Concatenation(webftp,"zoo/",fn,".zoo")),
          ")</a>]\n",
          "[<a href=\"{{gap4ftp}}tar.gz/",fn,".tar.gz\">.tar.gz (", 
          StringSizeFilename(Concatenation(webftp,"tar.gz/",fn,".tar.gz")),
          ")</a>]\n",
          "[<a href=\"{{gap4ftp}}tar.bz2/",fn,".tar.bz2\">.tar.bz2 (", 
          StringSizeFilename(Concatenation(webftp,"tar.bz2/",fn,".tar.bz2")),
          ")</a>]\n",
          "[<a href=\"{{gap4ftp}}win.zip/",fn,"-win.zip\">-win.zip (", 
          StringSizeFilename(Concatenation(webftp,"win.zip/",fn,"-win.zip")),
          ")</a>]\n"
          );
  templ := StringFile(Concatenation(webdir, "/Download/index.mixer.templ"));
  templ := SubstitutionSublist(templ, "<!--toolsarchivelinks-->",
                               toolsarchivelinks);
  templ := SubstitutionSublist(templ, "<!--mainarchivelinks-->",
                               mainarchivelinks);
  templ := SubstitutionSublist(templ, "<!--xtomarchivelinks-->",
                               xtomarchivelinks);
  templ := SubstitutionSublist(templ, "<!--mergedarchivelinks-->",
                               mergedarchivelinks);
  FileString(Concatenation(webdir, "/Download/index.mixer"), templ);
end;

UpdateAllPackages := function(pkgdir)
  local addpackagelines, newinfo, newarch, fun, inmerge, newdoc;
  # first save the current setup with a time stamp
  addpackagelines := AddpackageLinesCurrent("../pkg");
  FileString(Concatenation("addpackageCurrent_", StringCurrentTime()), 
             addpackagelines);
  # now start the update
  newinfo := UpdatePackageInfoFiles(pkgdir);
  newarch := UpdatePackageArchives(pkgdir);
  fun := function(nam, stat)
    READPackageInfo(Concatenation(pkgdir, "/", nam, "/PackageInfo.g"));
    return PACKAGE_INFOS.(nam).Status = stat;
  end;
  if ForAny(newarch, a-> fun(a, "accepted") or fun(a, "deposited")) then
    inmerge := true;
  else 
    inmerge := false;
  fi;
  MergePackageArchives(pkgdir, Concatenation(pkgdir, "/../tmp/tmpmerge"), 
                       inmerge);
  newdoc := UpdatePackageDoc(pkgdir);
  if Length(newinfo) > 0 or Length(newarch) > 0 then
    ReadAllPackageInfos(pkgdir);
    UpdatePackageWebPages(Concatenation(pkgdir, "/../web"));
  fi;
  Print("\n\n==============   SUMMARY ========\n\nChanged info files: ", 
    " ", newinfo, "\n\nNew archive files in: ",
    newarch, "\n\nNewly merged packages: ", inmerge,
    "\n\nNew documentation: ", newdoc, "\n\n");
end;




