###########################################################################
##  
##  PackageInfoTools.g                                         (C) Frank Lübeck
##  
##      $Id$
##  
##  This file contains utilities for automatic updating of the information 
##  related to package which are available via the GAP website. 
##  
##     - current PackageInfo.g files are fetched from the Web
##     - if something is new, the following files are updated:
##       - changed archives are downloaded, if any of the formats
##         .zoo, .tar.gz, -win.zip or .tar.bz2 is not provided these
##         are automatically generated
##       - if  package archives have changed, the  merged archives 
##         (in the formats mentioned above) are newly generated
##       - if a documentation archive for the online manual has changed, it is
##         fetched from the Web and unpacked

#DeclareInfoClass( "InfoExec" );
#SetInfoLevel(InfoExec,1);
#
#MakeReadWriteGlobal("Exec");       
#UnbindGlobal("Exec");
#BindGlobal("Exec",
#function ( arg )
#    local  cmd, i, shell, cs, dir;
#    cmd := ShallowCopy( arg[1] );
#    Info( InfoExec, 1, cmd );
#    if not IsString( cmd )  then
#        Error( "the command ", cmd, " is not a name.\n", 
#         "possibly a binary is missing or has not been compiled." );
#    fi;
#    for i  in [ 2 .. Length( arg ) ]  do
#        Append( cmd, " " );
#        Append( cmd, arg[i] );
#    od;
#    shell := Filename( DirectoriesSystemPrograms(  ), "sh" );
#    cs := "-c";
#    if shell = fail and ARCH_IS_WINDOWS(  )  then
#        shell := Filename( DirectoriesSystemPrograms(  ), "cmd.exe" );
#        cs := "/C";
#    fi;
#    dir := DirectoryCurrent(  );
#    Process( dir, shell, InputTextUser(  ), OutputTextUser(  ), [ cs, cmd ] );
#    return;
#end);

## store package infos
PACKAGE_INFOS := rec();

## should be told the 'mixer' directly
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
    Print("# Error (", fname, "): no package info bound!\n");
    return;
  fi;
  r := GAPInfo.PackageInfoCurrent;
  Unbind(GAPInfo.PackageInfoCurrent);
  # store under normalized .PackageName
  if not IsRecord(r) or not IsBound(r.PackageName) or 
                        not IsString(r.PackageName) then
    Print("# Warning (", fname, "): ignored, no package name!\n");
    return;
  fi;
  NormalizeWhitespace(r.PackageName);
  name := LowercaseString(r.PackageName);

  # What is the "default Status"???
  if not IsBound(r.Status) then
     r.Status := "None";
     Print("# Warning (", r.PackageName, "): package has no Status!!!\n");
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
        pkgs, nam, info, infon, namn, d, pkg, f, update, has_error;
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
    if IsExistingFile(Concatenation(pkg, "/DONTUPDATE")) then
      Print("Found ", pkg, "/DONTUPDATE  --  not updating PackageInfo.g!!!\n");
      continue;
    fi;
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

    if not IsBound( info.PackageInfoURL ) then
      Print("#  ERROR (", info.PackageName, "): PackageInfoURL not bound in the stored file.\n");
      Print("#  You need to set it manually or using the command \n");
      Print("#  ./addPackage <package-name> <PackageInfoURL>\n");
      continue;
    fi; 
            
    # try to get current info file with wget
    Exec(Concatenation("mkdir -p ", pkg, "/tmp; rm -f ", pkg,
    "/tmp/tmpinfo.g"));
    Exec(Concatenation("wget --timeout=60 --tries=1 -O ", 
                       pkg, "/tmp/tmpinfo.g ",
    info.PackageInfoURL, " 2>> wgetlog"));
    ClearPACKAGE_INFOS();
    READPackageInfo(Concatenation(pkg, "/tmp/tmpinfo.g"));
    if not IsBound(PACKAGE_INFOS.(nam)) then
      Print("  WARNING (", info.PackageName, "): no success in download of the current info file \n  from ", 
            info.PackageInfoURL, "\n");
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
    has_error := false;
    d := Difference(nam, namn);
    if Length(d) > 0 then
      Print("  removed components: ", d, "\n");
      update := true;
      if "PackageInfoURL" in d then
        Print("  WARNING (", info.PackageName, "): no PackageInfoURL component in the current info file from\n   ",
              info.PackageInfoURL, "\n  info file will not be changed\n");
        has_error := true;
      fi;  
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
    if update and not has_error then
      # save old info file, store new one
      outstr := StringCurrentTime();
      Exec(Concatenation("mv -f ", pkg, "/PackageInfo.g ", pkg, 
                         "/PackageInfo.g-", outstr));
      Exec(Concatenation("mv -f ", pkg, "/tmp/tmpinfo.g ", pkg,
                         "/PackageInfo.g"));
      Add(res, pkg);
    elif has_error then
      Print("  There was an error. PackageInfo.g not accepted.\n");
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
    PrintTo(res, "./addPackage ", info.PackageName, " ", 
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
UpdatePackageArchives := function(pkgdir, webdir)
  local pkgs, res, nam, info, url, pos, fname, formats, pkgtmp, missing, 
        available, fmt, lines, l, ll, fun, pkg, p, a, bname, dnam, old, fn;
  # package dirs
  pkgs := Difference(FilesDir(pkgdir, "d", 1), [pkgdir]);
  # make sure the needed subdirs of the webdir exist
  Exec(Concatenation("mkdir -p ", webdir, "/Packages/pkg"));
  # Exec(Concatenation("mkdir -p ", webdir, "/ftpdir/zoo/packages"));
  Exec(Concatenation("mkdir -p ", webdir, "/ftpdir/win.zip/packages"));
  Exec(Concatenation("mkdir -p ", webdir, "/ftpdir/tar.gz/packages"));
  Exec(Concatenation("mkdir -p ", webdir, "/ftpdir/tar.bz2/packages"));

  res := [];
  for pkg in pkgs do
    pkgtmp := Concatenation(pkg, "/tmp/");
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
      Print("# Warning (", info.PackageName, "): no ArchiveURL given!\n");
      continue;
    fi;
    url := info.ArchiveURL;
    # filename of the archive without extension
    fname := Basename(url);

    # check if .tar.gz file is already in the local collection
    Print( "Checking for ", pkgdir, "/", nam, "/", fname, ".tar.gz \c");
    if IsExistingFile(Concatenation(pkgdir, "/", nam, "/", fname, ".tar.gz")) then
      Print(" - already in collection\n");
    else
    
      Print(" - missing\n");
      Print("  GETTING NEW archives ...\n   (", url, ")\n");
      Add(res, nam);
      # ok, so we have to get the archives
      formats := SplitString(info.ArchiveFormats,""," \n\r\t,");
      # use only recognized formats here
      formats := Intersection(formats, [ ".tar.gz", ".tar.bz2",
                   "-win.zip", ".zoo", ".deb", ".rpm" ]);
      # ??? do we need to keep deb and rpm here ???   
      # ??? do we need to clean up the pkgtmp directory ???       
      # Exec(Concatenation("rm -rf ", pkgtmp));
      Exec(Concatenation("mkdir -p ", pkgtmp));
      # copy available archive formats
      for fmt in formats do
        Exec(Concatenation("cd ", pkgtmp, ";wget --timeout=60 --tries=1 -O ", 
             fname, fmt, " ", url, fmt, " 2>> wgetlog"));
      od;
      #

      # which acceptable formats are available? (".zoo" is to be retired soon)
      available := Filtered([ ".tar.gz", ".tar.bz2", "-win.zip", ".zoo" ], fmt ->
                          IsExistingFile(Concatenation(pkgtmp, fname, fmt)));
    
      # which formats are missing and must be recreated? (except ".zoo")
      missing := Filtered([ ".tar.gz", ".tar.bz2", "-win.zip" ], fmt ->
                          not IsExistingFile(Concatenation(pkgtmp, fname, fmt)));

      if Length(available)=0 then 
        Print("GOT NONE OF THE ARCHIVES! NOT UPDATED!\n");
        Unbind(res[Length(res)]);
        continue;
      fi;
      
      fmt:=available[1];
      
      if fmt=".zoo" then
        Print("WARNING: ", info.PackageName, " is distributed only in zoo format\n"); 
      fi;

      if not IsLocalArchive(Concatenation(pkgtmp, fname, fmt)) then
        Print("   archive contains path starting with / or containing ..\n",
              "       REJECTED !!!\n");
        continue;
      fi;
      
      # we need to unpack at least one archive to classify text/binary files
      Print("  unpacking ", fname, fmt, "\n");
      if fmt = ".tar.gz" then
        Exec(Concatenation("cd ", pkgtmp, ";gzip -dc ", fname, 
                           ".tar.gz |tar xpf - "));
      elif fmt = ".tar.bz2" then
        Exec(Concatenation("cd ", pkgtmp, ";bzip2 -dc ", fname, 
                           ".tar.bz2 |tar xpf - "));
      elif fmt = "-win.zip" then
        Exec(Concatenation("cd ", pkgtmp, ";unzip -a ", fname, "-win.zip"));
      elif fmt = ".zoo" then
        Exec(Concatenation("cd ", pkgtmp, ";unzoo -x ", fname, 
             ".zoo > /dev/null 2>&1"));
      else
        Print("ERROR (", info.PackageName, "): no recognized archive format ", fmt, "\n");
        continue;
      fi;
      
      # name of unpacked directory (must no longer be 'nam')
      dnam := Difference(FilesDir(pkgtmp, "d", 1), [pkgtmp]);
      if Length(dnam) = 0 then
        Print("ERROR (", info.PackageName, "): could not unpack archive .... SKIPPING !!!\n");
        continue;
      else
        dnam := dnam[1];
      fi;
      dnam := dnam{[Length(pkgtmp)+1..Length(dnam)]};
      # remove initial "/"
      if dnam[1]='/' then
        dnam := dnam{[2..Length(dnam)]};
      fi;
      
      if not ValidatePackageInfo( Concatenation(pkgtmp, "/", dnam, "/PackageInfo.g")) then
           Print("  ERROR (", info.PackageName, "): validation of the info file not successful .... SKIPPING !!!\n");
           continue;
      else
           Print("  VALIDATION of the info file successful!\n");
      fi;

      # need to find out the text files
      Print("  finding text files  . . .\n");
              PrintTo( Concatenation(pkgtmp, "patternstextbinary.txt" ), "#Autogenerated by GAP\n" );
      Exec( Concatenation ( "cd ", pkgtmp, " ; touch patternstextbinary.txt" ) );

      if Number( [IsBound(info.TextFiles), IsBound(info.BinaryFiles), IsBound(info.TextBinaryFilesPatterns) ],
                 a -> a=true ) > 1 then
        Print("  WARNING (", info.PackageName, 
              "): do not use more than one of TextFiles, BinaryFiles, TextBinaryFilesPatterns\n");
        Print("          The superfluous components will be ignored.\n");
      fi;           

      if IsBound(info.TextFiles) then
        Print("  using ", info.TextFiles, " from PackageInfo.g as text files \n");
        AppendTo( Concatenation(pkgtmp, "patternstextbinary.txt" ), "# Autoextended by GAP\n" );
        for a in info.TextFiles do
          AppendTo( Concatenation(pkgtmp, "patternstextbinary.txt" ), "T", a, "\n" );
        od;
      elif IsBound(info.BinaryFiles) then
        Print("  using ", info.BinaryFiles, " from PackageInfo.g as binary files \n");
        AppendTo( Concatenation(pkgtmp, "patternstextbinary.txt" ), "# Autoextended by GAP\n" );
        for a in info.BinaryFiles do
          AppendTo( Concatenation(pkgtmp, "patternstextbinary.txt" ), "B", a, "\n" );
        od;
      elif IsBound(info.TextBinaryFilesPatterns) then
        Print("  using ", info.TextBinaryFilesPatterns, " from PackageInfo.g to set text/binary patterns \n");
        AppendTo( Concatenation(pkgtmp, "patternstextbinary.txt" ), "# Autoextended by GAP\n" );
        for a in info.TextBinaryFilesPatterns do
          AppendTo( Concatenation(pkgtmp, "patternstextbinary.txt" ), a, "\n" );
        od;  
      #elif not ".zoo" in missing then
        #  tfiles := TextFilesInZooArchive(Concatenation(pkgtmp, fname, ".zoo"));
        # we could also use the  -win.zip format here, with 'unzip -Z -v'
        # the text files can be found
        # elif not -win.zip in missing then .....
      fi;
      
      # classify text/binary files with Max's script classifyfiles.py
      Exec( Concatenation (
        "cp ../classifyfiles.py ", pkgtmp, "/ ; ",
        "cp ../patternscolorpkg.txt ", pkgtmp, "/patternscolor.txt ;",
        "cat ../patternstextbinary.txt >> ", pkgtmp, "/patternstextbinary.txt ;",
        "echo \"B*\" >> ", pkgtmp, "/patternstextbinary.txt ; ",
        "cd ", pkgtmp, " ; ",
        "python ./classifyfiles.py ", dnam ) );           
 
      Print("\n=====================text files==========================\n");
      Exec(Concatenation("cd ", pkgtmp, " ; cat listtextfiles.txt" ));
      Print("\n=====================end of the list of text files=======");
      Print("\n=====================binary files========================\n");
      Exec(Concatenation("cd ", pkgtmp, " ; cat listbinaryfiles.txt" ));
      Print("\n=====================end of the list of binary files=====");
      Print("\n=====================ignored files=======================\n");
      Exec(Concatenation("cd ", pkgtmp, " ; cat listignoredfiles.txt" ));
      Print("\n=====================end of the list of ignored files====\n");
      Exec(Concatenation( "cp ", pkgtmp, "/listtextfiles.txt ", pkg, "/", fname, ".txtfiles" ));
      Exec(Concatenation( "cp ", pkgtmp, "/listbinaryfiles.txt ", pkg, "/", fname, ".binfiles" ));
      
      # now create the missing archives
      for fmt in missing do
        if fmt = ".tar.gz" then
          Print("  creating ",fname,".tar.gz\n");
          Print(Concatenation("cd ", pkgtmp,"; tar cpf \"", fname, ".tar\" ",
               dnam, "; gzip -9 ", fname, ".tar\n"));
          Exec(Concatenation("cd ", pkgtmp,"; tar cpf \"", fname, ".tar\" ",
               dnam, "; gzip -9 ", fname, ".tar"));
        elif fmt = ".tar.bz2" then
          Print("  creating ",fname,".tar.bz2\n");
          Exec(Concatenation("cd ", pkgtmp,"; tar cpf \"", fname, ".tar\" ",
               dnam, "; bzip2 -9 ", fname, ".tar"));
        #elif fmt = ".zoo" then
        #  Print("  creating ",fname,".zoo\n");
        #  Exec(Concatenation("cd ", pkgtmp,"; find ", dnam, 
        #       " -print | zoo aIhq ", fname, ".zoo"));
        #  for a in tfiles do
        #    Exec(Concatenation("cd ", pkgtmp,"; (echo '!TEXT!'; echo '/END')", 
        #         "| zoo c ", fname, ".zoo ", a));
        #  od;
        elif fmt = "-win.zip" then
          Print("  creating ",fname,"-win.zip\n");
          Exec(Concatenation("cd ", pkgtmp,"; rm -f ", fname, "-win.zip ; ",
                 "cat listbinaryfiles.txt | zip -v -9 ", fname, "-win.zip -@ > /dev/null; ",
                 "cat listtextfiles.txt | zip -v -9 -l ", fname, "-win.zip -@ > /dev/null "));
        else
          Print("Cannot create archive with format: ", fmt, "\n");
        fi;
      od; # loop over missing archive formats
    
      # copy to Web and move archives
      for fmt in [ ".tar.gz", ".tar.bz2", "-win.zip"] do # removed .zoo
        if not IsExistingFile(Concatenation(webdir, "/ftpdir/",
          fmt{[2..Length(fmt)]}, "/packages/", fname, fmt)) then
          # first delete old ones from ftp dir
          old := List(FilesDir(pkg, "f", 1), Basename);
          old := Filtered(old, a-> Length(a)>=Length(fmt) and
                 a{[Length(a)-Length(fmt)+1..Length(a)]} = fmt);
          for fn in old do
            Exec(Concatenation("rm -f ", webdir, "/ftpdir/", 
                 fmt{[2..Length(fmt)]}, "/packages/", fn));
          od;
          if IsExistingFile(Concatenation(pkgtmp,"/",fname,fmt)) then
            Exec(Concatenation("cd ", pkgtmp,"; mv -f ", fname, fmt, " .."));
          fi;
          Exec(Concatenation("cd ", pkgtmp, "/.. ; cp -f ", fname, fmt,
                        " ", webdir, "/ftpdir/", fmt{[2..Length(fmt)]},
                        "/packages/")); 
        fi;
      od;

      # and get the README file
      if not IsExistingFile(Concatenation(pkg, "/DONTUPDATE")) then
        if not IsBound( info.README_URL ) then
          Print("#   Error (", info.PackageName, "): README_URL not bound in the info file.\n");
        else 
          Exec(Concatenation("cd ", pkgtmp,"; rm -f ", bname, 
               "; wget --timeout=60 --tries=1 ", info.README_URL, " 2>> wgetlog"));
          if IsExistingFile(Concatenation(pkgtmp, "/", bname)) then
            Exec(Concatenation("cd ", pkgtmp,"; mkdir -p ", webdir,
                 "/Packages/pkg/",
                 nam, "; cp -f ", bname, 
                 " ", webdir, "/Packages/pkg/", nam, "/README.", nam, "; mv -f ", 
                 bname, " ../README.", nam));
          else
            Print("#   Error (", info.PackageName, "): could not get README file from\n   ", info.README_URL, "\n");
          fi;
        fi;
      fi;  
    fi; # if package needs an update
  od; # end of loop over all packages
  return res;
end;
 
MergePackageArchives := function(pkgdir, tmpdir, archdir, webdir, inmerge)
# This function is called from the 'mergePackageArchives' script 
# with the following arguments: 
# PkgCacheDir, PkgMergeTmpDir, PkgMergedArchiveDir, PkgWebFtpDir, true
  local mergedir, pkgs, textfilesmerge, nam, info, d, tf, 
        fname, fun, allfiles, pkg, str, fmt,fn_targzArch;
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
    # decide the corresponding merged archive, currently only one archive
    if info.Status = "accepted" and inmerge = true then
      d := mergedir;
      tf := textfilesmerge;
    elif info.Status in ["submitted","deposited"] and inmerge = true then
      d := mergedir;
      tf := textfilesmerge;
    else
      Print("WARNING (", info.PackageName, "): has status ", info.Status, 
            "\nwhich is is not one of accepted/submitted/deposited\n");
      # for now do the same for others
      d := mergedir;
      tf := textfilesmerge;
      #continue;
    fi;
    if not IsBound(info.ArchiveURL) then
      continue;
    fi;
    fname := Basename(info.ArchiveURL);
    # ???TODO??? should this be done here?
    # collect text file names from zoo archive
    # Append(tf, TextFilesInZooArchive(Concatenation(pkg, "/", fname, ".zoo")));
    # unpack from .tar.gz file
    Exec(Concatenation("cat ", pkg, "/", fname, ".tar.gz | (cd ", d, 
                       "; tar xzpf - )" ) );
    # and copy the README file
    Exec(Concatenation("cp ", pkg, "/README.", nam, " ", d));
    # and copy files with lists of text files and binary files
    Exec( Concatenation("cp ", pkg, "/", fname, ".txtfiles ", d));
    Exec( Concatenation("cp ", pkg, "/", fname, ".binfiles ", d));
  od;

  # now create the merged tar.gz archive
  # (just this, no others any more)
  fun := function(pkgdir, dir, fn, textfiles)
    local a;
##      local allfiles;
    Exec(Concatenation("cd ", dir, "; tar cpf ../", fn, ".tar * ; cd .. ; ",
         " gzip -9 ", fn, ".tar ; " ));
    #Exec(Concatenation("cd ", dir, "; tar cpf ../", fn, ".tar * ; cd .. ; ",
    #     "cp ", fn, ".tar ", fn, ".tar.X; gzip -9 ", fn, ".tar ; ",
    #     "mv -f ", fn, ".tar.X ", fn, ".tar; bzip2 -9 ", fn, ".tar ; "
    #     ));
    # then zoo it
    #Exec(Concatenation("cd ", dir, "; ",
    #     "find * -print | zoo ahIq ../", fn, ".zoo "));
    # add !TEXT! comments to zoo archive
    #for a in textfiles do
    #  Exec(Concatenation("cd ", dir, "/.. ; (echo '!TEXT!'; echo '/END')", 
    #       "| zoo c ", fn, ".zoo \"", a, "\""));
    #od;
    # adjust time stamp
    #Exec(Concatenation("cd ", dir, "/.. ; zoo Tq ", fn, ".zoo"));

    # and finally zip it 
    #FileString(Concatenation(dir, "/../tmptfiles"),
    #                          JoinStringsWithSeparator(textfiles, "\n"));
    #Exec(Concatenation("cd ", dir,"; find * ", " -print > ../allfiles"));
    #allfiles := SplitString(StringFile(Concatenation(dir, "/../allfiles")), 
    #                        "", "\n");
    #FileString(Concatenation(dir, "/../tmpbfiles"), 
    #        JoinStringsWithSeparator(Difference(allfiles, textfiles), "\n"));
    #Exec(Concatenation("cd ", dir,"; ",
    #     "cat ../tmpbfiles | zip -9 ../", fn, "-win.zip -@ > /dev/null ; ",
    #     "cat ../tmptfiles | zip -9 -l ../", fn, "-win.zip -@ > /dev/null "));
  end; 

  str := StringCurrentTime();
  while Length(str) > 0 and str[Length(str)] = '\n' do
    Unbind(str[Length(str)]);
  od;
  
  Exec( Concatenation( 
    "cd ", d, " ; ", 
    "cat *.txtfiles > metainfotxtfiles-", str, ".txt ; ",
    "cat *.binfiles > metainfobinfiles-", str, ".txt ; ",
    "rm *.txtfiles ; ",
    "rm *.binfiles ; ",
    "ls README.* >> metainfotxtfiles-", str, ".txt ; ",
    "ls metainfo* | zip -q metainfopackages", str, " -@" ) );  

  # move metainfo archive to the archive collection and then cleanup
  Exec(Concatenation("cd ", archdir, "; mkdir -p old; ",
       "touch metainfopackages*; mv metainfopackages* old ; ",
       "cp -f ", tmpdir, "/merge/metainfopackages*.zip ", archdir, 
       "; rm -f ", tmpdir, "/merge/metainfo*",
       "; rm -f ", webdir, "/ftpdir/*/metainfo*"));
 
  fun(pkgdir, mergedir, Concatenation("packages-", str), textfilesmerge);

  # cp merged to archive collection and ftp directory
##    Exec(Concatenation("cd ", pkgdir, "/../archives; mkdir -p old; ",
##         "touch packages-*; mv packages-* old; cp -f ", tmpdir, "/packages-* ",
##         pkgdir, "/../archives; rm -f ", pkgdir, "/../web/ftpdir/*/packages-*"));
##    for fmt in [".zoo", ".tar.gz", ".tar.bz2", "-win.zip"] do
##      Exec(Concatenation("mv -f ", tmpdir, "/packages-*", fmt, " ", pkgdir, 
##           "/../web/ftpdir/", fmt{[2..Length(fmt)]}, "/"));
##    od;
  Exec(Concatenation("cd ", archdir, "; mkdir -p old; ",
       "touch packages-*; mv packages-* old; cp -f ", tmpdir, "/packages-* ",
       archdir, "; rm -f ", webdir, "/ftpdir/*/packages-*"));
  for fmt in [ ".tar.gz" ] do # no merged ".tar.bz2", "-win.zip", and retired ".zoo"
    Exec(Concatenation("mv -f ", tmpdir, "/packages-*", fmt, " ", webdir, 
         "/ftpdir/", fmt{[2..Length(fmt)]}, "/"));
  od;

  # repack archives with Frank's script repack.py
  #fn_targzArch := Concatenation("packages-", str, ".tar.gz");
  #Exec(Concatenation("cd ", archdir, 
  #"; /Users/alexk/CVSREPS/GAPDEV/dev/DistributionUpdate/dist45/repack.py ",
  #fn_targzArch, " -all ;" )); 
       
end;

# returns list of [dirname, bookname] of updated packages
UpdatePackageDoc := function(pkgdir, pkgdocdir)
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
      Print("# Warning (", info.PackageName, "): no PackageDoc component!\n");
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
        Exec(Concatenation("cd ", pkgtmp, "; tar xzpf ../", pkgarch));
        dname := NormalizedWhitespace(StringSystem("sh", "-c", 
                     Concatenation("cd ", pkgtmp, "; ls")));
        for a in b.ArchiveURLSubset do
          Exec(Concatenation("cd ", pkgtmp, "/", dname, "; cp -r --parents ", 
               a, " .."));
        od;
        Print(Concatenation("cd ", pkgtmp, "; rm -rf ", dname,"\n"));
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
               " |tar xpf - "));
        elif fmt = ".bz2" then
          Exec(Concatenation("cd ", pkgtmp, ";bzip2 -dc ", fname, 
               " |tar xpf - "));
        elif fmt = ".zip" then
          Exec(Concatenation("cd ", pkgtmp, ";unzip -a ", fname));
        else
          Error("(", info.PackageName, "): no recognized archive format: ", fmt);
        fi;
        # here we must assume that package directory is lower case of
        # package name
        dname := nam;
      else
        dname := nam;
        Print("   WARNING (", info.PackageName, "): No package documentation specified!\n");
      fi;
      # move to web dir and to archives
      Exec(Concatenation("cd ", pkgtmp, "; rm -f wgetlog ; ",
        "mkdir -p ", pkgdocdir, "/", dname, 
        "; cp -fr * ", pkgdocdir, "/", dname,  "; cp -fr * ..; rm -rf *"));
    od;
  od;
  return res;
end;



# Write the <pkgname>.mixer file for a package
# args: info[, webdir]                    default for webdir is "../web"
AddHTMLPackageInfo := function(arg)
  local info, webdir, NameChunk, nam, res, auth, maint, dep, s, books, 
        manlink, bnam, arch, dname, fn, a, i, p, ext;
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

  # hook for additional infos not produced here            
  Append(res, "\n<mixer part=\"extra\" needed=\"no\"/>\n\n");

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
  # directory name of unpacked archive
  arch := Concatenation(webdir, "/ftpdir/tar.gz/packages/",
                        Basename(info.ArchiveURL),".tar.gz");
  dname := StringSystem("sh", "-c", Concatenation("tar tzf ", arch,
           "| head -2| tail -1"));
  if '/' in dname then
    dname := dname{[1..Position(dname, '/')-1]};
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
              dname,  "/", a.HTMLStart, 
              "'> HTML</a>] version&nbsp;&nbsp;" ));
      Append(manlink, Concatenation("<a href=\"{{GAPManualLink}}pkg/", 
        dname, "/", a.HTMLStart, "\">", a.BookName, "</a></td>"));
    else
      Append(manlink, Concatenation(a.BookName, "</td>"));
    fi;
    if IsBound(a.PDFFile) then
      Append(res, Concatenation(" [<a href='{{GAPManualLink}}pkg/", 
              dname, "/", a.PDFFile, 
              "'> PDF</a>] version&nbsp;&nbsp;" ));
      Append(manlink, Concatenation("<td>[<a href=\"{{GAPManualLink}}pkg/",
        dname, "/", a.PDFFile, 
        "\">PDF</a>]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>"));
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
  for ext in [ ".tar.gz",  "-win.zip", ".tar.bz2"] do # retired ".zoo",
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
#Jump
  for a in info.Persons do
    if IsBound(a.IsMaintainer) and a.IsMaintainer = true then

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
    fi;
  od;
  Append(res, "</p>\n");
  Append(res,"\n</mixer>\n");

  info.HTMLInfoMixer := res;
  return res;
end;

EnsureLatin1Strings := function(r)
  local uni, res, a, i;
  if LoadPackage("GAPDoc", "1.0") <> true then
    Error("Please install GAPDoc version >= 1.0 ...\n");
  fi;
  if IsString(r) then
    # heuristic: assume that encoding is UTF-8 if string is valid UTF-8
    # otherwise assume latin1 and do nothing
    uni := Unicode(r, "UTF-8");
    if uni = fail then 
      return r;
    else
      return Encode(uni, "latin1");
    fi;
  elif IsRecord(r) then
    res := rec();
    for a in RecFields(r) do
      res.(a) := EnsureLatin1Strings(r.(a));
    od;
    return res;
  elif IsList(r) then
    res := [];
    for i in [1..Length(r)] do
      if IsBound(r[i]) then
        res[i] := EnsureLatin1Strings(r[i]);
      fi;
    od;
    return res;
  else
    return r;
  fi;
end;

# This function
# writes variable setting for package web pages in a python readable file
# <pkgconffile>.
# It also creates the short info pages for each package, like ace.mixer, ...
# these files are written in <webdir>/Packages.
# The current archive files must be in <webdir>/ftpdir/<fmt>   with <fmt> in
# zoo, tar.gz, tar.bz2, win.zip
WritePackageWebPageInfos := function(webdir, pkgconffile)
  local mergedarchivelinks, templ, treelines, pi, fl, fn, manualslinks, 
    suggestupgradeslines, nam, lnam, pkgmix, mixfile, linkentry, ss, s, 
    tree, mantempl, names, str, lines, strs, updtempl, a, pers, l, 
    webftp, n, esc, uc;
  Print("Updating info for web pages ...\n");
  # empty result file
  pkgconffile := OutputTextFile(pkgconffile, false);
  SetPrintFormattingStatus(pkgconffile, false);
  PrintTo(pkgconffile, "# -*- coding: ISO-8859-1 -*-\n");
  # a function to escape "'''" in python readable strings
  esc := function(s)
    local pos, off, res;
    pos := PositionSublist(s, "'''");
    if pos = fail then
      return s;
    fi;
    off := 0;
    res := "";
    while pos <> fail do
      Append(res, s{[off+1..pos-1]});
      Append(res, "'''\"'''\"'''");
      off := pos+2;
      pos := PositionSublist(s, "'''", off);
    od;
    Append(res, s{[off+1..Length(s)]});
    return res;
  end;
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
#          "[<a href=\"{{gap4ftp}}zoo/",fn,".zoo\">.zoo (", 
#          StringSizeFilename(Concatenation(webdir,"/ftpdir/zoo/",fn,".zoo")),
#          ")</a>]\n",
          "[<a href=\"{{gap4ftp}}tar.gz/",fn,".tar.gz\">.tar.gz (", 
          StringSizeFilename(Concatenation(webdir,"/ftpdir/tar.gz/",
          fn,".tar.gz")), ")</a>]\n"#,
#          "[<a href=\"{{gap4ftp}}tar.bz2/",fn,".tar.bz2\">.tar.bz2 (", 
#          StringSizeFilename(Concatenation(webdir,"/ftpdir/tar.bz2/",
#          fn,".tar.bz2")), ")</a>]\n",
#          "[<a href=\"{{gap4ftp}}win.zip/",fn,"-win.zip\">-win.zip (", 
#          StringSizeFilename(Concatenation(webdir,"/ftpdir/win.zip/",
#          fn,"-win.zip")), ")</a>]\n"
          );
  AppendTo(pkgconffile, "PKG_mergedarchivelinks = r'''", 
          esc(mergedarchivelinks), "'''\n\n");
  
  # write the <pkgname>.mixer files and fill the package.mixer entries and
  # the 'tree' file and manual overview lines and SuggestUpgrade args
  manualslinks := rec();
  suggestupgradeslines := rec();
  pi := EnsureLatin1Strings(pi);
  for a in NamesOfComponents(pi) do
    nam := pi.(a).PackageName;
    lnam := LowercaseString(pi.(a).PackageName);
    pkgmix := AddHTMLPackageInfo(pi.(a), webdir);
    # heuristics in case PackageInfoFile is in UTF-8
    uc := Unicode(pkgmix, "UTF-8");
    if uc <> fail then
      pkgmix := Encode(uc, "XML");
    fi;
    mixfile := "";
    # line for 'tree' file
    #Append(mixfile, "");
    Add(treelines, [lnam, 
                    Concatenation("  <entry file=\"", lnam, ".html\">",
                    nam, "</entry>\n")]);
    # write <pkgname>.mixer file
    Append(mixfile, Concatenation("/", lnam));
    FileString(Concatenation(webdir, "/Packages/", mixfile, ".mixer"), pkgmix);
    linkentry := Concatenation("<a href=\"{{pkgmixerpath}}", 
                 mixfile, ".html\">",
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
    Append(linkentry, "\n");
    AppendTo(pkgconffile, "PKG_OverviewLink_", esc(lnam), " = r'''",
             esc(linkentry), "'''\n\n");

    manualslinks.(lnam) := pi.(a).HTMLManLinks;
    suggestupgradeslines.(lnam) := pi.(a).SuggestUpgradesEntry;
  od;
  
  # for tree file, all packages sorted alphabetically by name
  tree := "";
  Sort(treelines);
  for a in treelines do
    Append(tree, a[2]);
  od;

  # now the manuals overview
  names := ShallowCopy(NamesOfComponents(manualslinks));
  Sort(names);
  str := JoinStringsWithSeparator(List(names, a-> manualslinks.(a)), "\n");
  for n in names do
    AppendTo(pkgconffile, "PKG_ManualLink_", n, " = r'''", 
             esc(manualslinks.(n)), "'''\n\n");
  od;
  AppendTo(pkgconffile, "PKG_AllManualLinks = r'''", esc(str), "'''\n\n");
  
  # info for SuggestUpgrades
  names := ShallowCopy(NamesOfComponents(suggestupgradeslines));
  Sort(names);
  lines := [ "[ \"GAPKernel\", \"<mixer var='GAPKernelVersion'/>\" ], ",
             "[ \"GAPLibrary\", \"<mixer var='GAPLibraryVersion'/>\" ], " ];
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
  AppendTo(pkgconffile, "PKG_SuggestUpgradeLines = r'''", esc(str), 
           "\n'''\n\n");
end;


# some general utilities using the above functions
UpdateAllPackages := function(pkgdir)
  local addpackagelines, newinfo, newarch, fun, inmerge, newdoc, pkgdocdir;
  # first save the current setup with a time stamp
  addpackagelines := AddpackageLinesCurrent(pkgdir);
  FileString(Concatenation("addpackageCurrent_", StringCurrentTime()), 
             addpackagelines);
  # now start the update
  newinfo := UpdatePackageInfoFiles(pkgdir);
  newarch := UpdatePackageArchives(pkgdir, Concatenation(pkgdir,
             "/../web"));
  fun := function(nam, stat)
    READPackageInfo(Concatenation(pkgdir, "/", nam, "/PackageInfo.g"));
    return PACKAGE_INFOS.(nam).Status = stat;
  end;
  if true then #ForAny(newarch, a-> fun(a, "accepted") or fun(a, "deposited")) then
    inmerge := true;
  else 
    inmerge := false;
  fi;
  if inmerge then
    MergePackageArchives(pkgdir, Concatenation(pkgdir, "/../tmp/tmpmerge"), 
                       inmerge);
  fi;
  pkgdocdir := Concatenation(pkgdir, "/../web/Packages/pkg");
  Exec(Concatenation("mkdir -p ", pkgdocdir));
  newdoc := UpdatePackageDoc(pkgdir, pkgdocdir);
  if Length(newinfo) > 0 or Length(newarch) > 0 then
    ReadAllPackageInfos(pkgdir);
    WritePackageWebPageInfos(Concatenation(pkgdir, "/../web"),
      Concatenation(pkgdir, "/../web/Packages/pkgconf.py"));
  fi;
  Print("\n\n==============   SUMMARY ========\n\nChanged info files: ", 
    " ", newinfo, "\n\nNew archive files in: ",
    newarch, "\n\nNewly merged packages: ", inmerge,
    "\n\nNew documentation: ", newdoc, "\n\n");
end;

# adding a package
AddPackage := function(pkgdir, pkgname, pkginfourl)
  local nam;
  nam := LowercaseString(NormalizedWhitespace(pkgname));
  Exec(Concatenation("mkdir -p ", pkgdir, "/", nam));
  PrintTo(Concatenation(pkgdir, "/", nam, "/PackageInfo.g"), 
    Concatenation("SetPackageInfo( rec( \n PackageName := \"", nam,  
                  "\",\nPackageInfoURL := \"", pkginfourl, "\",\n",
                  "Status := \"unknown\"  ) );\n"));
end;




