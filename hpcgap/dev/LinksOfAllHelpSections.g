##  
##  LinksOfAllHelpSections.g                            Frank Lübeck
##
##  A utility for dumping links to all available manual sections 
##  (for use with named manual references on web pages or in search
##  utilities)
##  
##  First load all the documentation you want to cover. Then read this
##  file. The result is written to a file "AllLinksOfAllHelpSections.data".
##
##  

NOTPKG := ["gpisotyp", "genus", "aclib","xgap"];
WriteAllLinksOfAllHelpSections := function(arg)
  local fname, res, rootpath, entry, path, pn, book, i, a;
  if Length(arg) = 0 then
    fname := "AllLinksOfAllHelpSections.data";
  else
    fname := arg[1];
  fi;

  # load as many packages as possible
  for pn in NamesOfComponents(GAPInfo.PackagesInfo) do
    if not pn in NOTPKG then
      LoadPackage(pn);
    fi;
  od;
  
  # we collect everything in a string
  res := "";
  
  # if path is not below first of the GAP root paths, we write FAIL for the
  # path
  rootpath := GAPInfo.RootPaths[1];
  if Length(rootpath) = 0 or rootpath[Length(rootpath)] <> '/' then
    Add(rootpath, '/');
  fi;
  # load all books
  HELP(":?");
  for a in NamesOfComponents(HELP_BOOKS_INFO) do
    book := HELP_BOOKS_INFO.(a);
    for i in [1..Length(book.entries)] do
      entry := HELP_BOOK_HANDLER.HelpDataRef(book, i);
      if IsString(entry[6]) and PositionSublist(entry[6], rootpath) = 1 then
        path := entry[6]{[Length(rootpath)+1..Length(entry[6])]};
      else
        Print("Invalid HTML path: ", entry, "\n");
        path := "FAIL";
      fi;
      Append(res, StripEscapeSequences(entry[1]));
      Add(res, '|');
      Append(res, path);
      Add(res, '|');
      Append(res, entry[2]);
      Add(res, '\n');
    od;
  od;
  FileString(fname, res);
  return res;
end;

guck := WriteAllLinksOfAllHelpSections();

