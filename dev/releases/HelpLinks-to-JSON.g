##  A utility for dumping links to all available manual sections
##  (for use with named manual references on web pages or in search utilities).
##
##  The main purpose for this script is to create the help-links.json file that
##  is used by the GAP website. This happens as part of the release process.
##
##  In order to be used on the GAP website, relative to a particular GAP
##  version, this script should be run from within the corresponding released
##  version of GAP, with exactly its bundled packages (installed in the pkg/
##  subdirectory), and with no special user config. The GAP and package manuals
##  are precompiled in the released version.

# Temporary hack to make sure that the record components in the JSON file are
# sorted, to increase stability in the output between GAP versions.
# Remove once https://github.com/gap-packages/json/pull/24 is merged+released.
InstallMethod(RecNames, [IsRecord and IsInternalRep], x -> AsSSortedList(REC_NAMES(x)));

LoadPackage("json");
out := OutputTextUser();
r := rec();
# load all books (without prompting the user for input)
Perform(HELP_KNOWN_BOOKS[1], HELP_BOOK_INFO);;
for x in NamesOfComponents(HELP_BOOKS_INFO) do
  book := HELP_BOOKS_INFO.(x);

  # We need two capitalised versions of the book name:
  # - One with " (not loaded)" removed (we don't want this suffix, ultimately)
  # - One with ": " added (for matching and removing this as a substring)
  bname := ReplacedString(book.bookname, " (not loaded)", "");
  match := Concatenation(book.bookname, ": ");

  # Paths in the record <book> are full paths, which are machine-specific.
  #
  # For the GAP website use-case described above, for the individual items, we
  # require paths relative to an imaginary common GAP root:
  #   doc/{ref/tut/dev}/...    for the GAP manuals,
  #   pkg/<pkgdir>/...         for the package manuals,
  # where <pkgdir> agrees with the naming of the relevant bundled GAP package.
  #
  # If GAP is installed with packages from a release, then this can be achieved
  # by simply removing the relevant GAP root path.
  # We store the specific paths relative to the book directory, and we store
  # the book directory relative to the imaginary GAP root.
  #
  # There seem to be two different ways to access the book directory.
  if IsBound(book.directory) then
    # Convert directory object to string.
    fulldir := Filename(book.directory, "");
  elif IsBound(book.directories) then
    Assert(0, IsList(book.directories) and IsTrivial(book.directories));
    # gapmacro manual: convert, and replace any trailing "/doc/" with "/htm/".
    fulldir := Filename(book.directories[1], "");
    if EndsWith(fulldir, "/doc/") then
      fulldir := Concatenation(fulldir{[1 .. Length(fulldir) - 5]}, "/htm/");
    fi;
  else
    Error("cannot determine the installation directory of the book: ", book);
  fi;
  reldir := ShallowCopy(fulldir);
  for root in GAPInfo.RootPaths do
    reldir := ReplacedString(reldir, root, "");
  od;

  r.(bname) := rec(directory := reldir, reference := rec());

  for i in [1 .. Length(book.entries)] do
    entry := HELP_BOOK_HANDLER.HelpDataRef(book, i);
    name := StripEscapeSequences(entry[1]);
    name := ReplacedString(name, match, "");
    NormalizeWhitespace(name);

    path := entry[6];
    if path = fail then
      path := "FAIL";
    else
      path := ReplacedString(path, fulldir, "");
      path := ReplacedString(path, "_mj.html", ".html");
    fi;

    r.(bname).reference.(name) := path;
  od;
od;

GapToJsonStream(out, r);;
QUIT;
