#############################################################################
##  
##  PackageInfo.g for the package `fplsa'                       Thomas Breuer
##  (created from Frank Lübeck's PackageInfo.g template file)
##  
SetPackageInfo( rec(
PackageName :=
  "FPLSA",
MyVersion :=
  "1r1",
MyWWWHome :=
  "http://www.math.rwth-aachen.de/~Thomas.Breuer",
Subtitle :=
  "Finitely Presented Lie Algebras",
Version :=
  JoinStringsWithSeparator( SplitString( ~.MyVersion, "rp" ), "." ),
Autoload :=
  false,
Date :=
  # "01/07/1999" -- Version 1.0
  "17/11/2003",
PackageWWWHome :=
  Concatenation( ~.MyWWWHome, "/", LowercaseString( ~.PackageName ) ),
ArchiveURL :=
  Concatenation( ~.PackageWWWHome, "/", LowercaseString( ~.PackageName ),
                 ~.MyVersion ),
ArchiveFormats :=
  ".zoo",
Persons := [
  rec(
    LastName := "Gerdt",
    FirstNames := "Vladimir",
    IsAuthor := true,
    IsMaintainer := false,
#   WWWHome := "",
#   Place := "",
#   Institution := "",
    Email := "gerdt@jinr.ru"
  ),
  rec(
    LastName := "Kornyak",
    FirstNames := "Vladimir",
    IsAuthor := true,
    IsMaintainer := false,
#   WWWHome := "",
#   Place := "",
#   Institution := "",
    Email := "kornyak@jinr.dubna.su"
  )
  ],
Status :=
  "accepted",
CommunicatedBy :=
  "Steve Linton (St Andrews)",
AcceptDate :=
  "07/1999",
README_URL :=
  Concatenation( ~.PackageWWWHome, "/README" ),
PackageInfoURL :=
  Concatenation( ~.PackageWWWHome, "/PackageInfo.g" ),
AbstractHTML :=
  "The <span class=\"pkgname\">FPLSA</span> package uses \
   the authors' C program (version 4.0) that implements \
   a Lie Todd-Coxeter method for converting \
   finitely presented Lie algebras into isomorphic \
   structure constant algebras. \
   This is called via the GAP function IsomorphismSCTableAlgebra.",
PackageDoc := rec(
  BookName :=
    "fplsa",
  ArchiveURLSubset :=
    [ "doc", "htm" ],
  HTMLStart :=
    "htm/chapters.htm",
  PDFFile :=
    "doc/manual.pdf",
  SixFile :=
    "doc/manual.six",
  LongTitle :=
    "Interface to fast external Lie Todd-Coxeter Program",
  Autoload :=
    true
  ),
Dependencies := rec(
  GAP :=
    ">= 4.4",
  NeededOtherPackages :=
    [],
  SuggestedOtherPackages :=
    [],
  ExternalConditions :=
    []
  ),
AvailabilityTest :=
  function()
  local path,file;
    # test for existence of the compiled binary
    path:= DirectoriesPackagePrograms( "fplsa" );
    file:= Filename( path, "fplsa4" );
    if file = fail then
      Info( InfoWarning, 1,
            "Package ``fplsa'': The program `fplsa4' is not compiled" );
    fi;
    return file <> fail;
  end,
TestFile :=
  "tst/testall.g",
Keywords :=
  ["Lie algebra", "presentation", "structure constants"]
) );

#############################################################################
##
#E

