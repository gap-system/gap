#############################################################################
##  
##  PackageInfo.g for the package `ParGAP'  by Gene Cooperman 
##  

##  For the LoadPackage mechanism in GAP >= 4.4 only the entries
##  .PackageName, .Version, .PackageDoc, .Dependencies, .AvailabilityTest
##  .Autoload   are needed. The other entries are relevant if the
##  package shall be distributed for other GAP users, in particular if it
##  shall be redistributed via the GAP Website.

##  With a new release of the package at least the entries .Version, .Date and
##  .ArchiveURL must be updated.

SetPackageInfo( rec(
PackageName := "ParGAP",
Subtitle := "Parallel GAP",
Version := "1.2.0",
Date := "20/12/2005",
ArchiveURL := 
          "http://www.math.rwth-aachen.de:8001/GAP/pkgs/ParGAP/pargap1r2",
ArchiveFormats := ".tar.gz",
Persons := [
  rec( 
    LastName      := "Cooperman",
    FirstNames    := "Gene",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "gene@ccs.neu.edu",
    WWWHome       := "http://www.ccs.neu.edu/home/gene/",
    Place         := "Boston",
    PostalAddress :=  "College of Computer Science, 202-WVH\nNortheastern University\nBoston, MA 02115\nUSA\n",
    Institution   := "Northeastern University"
  )
],
Status := "accepted",
CommunicatedBy := "Steve Linton (St Andrews)",
AcceptDate := "07/1999",
README_URL := 
  "http://www.math.rwth-aachen.de:8001/GAP/pkgs/ParGAP/README",
PackageInfoURL := 
  "http://www.math.rwth-aachen.de:8001/GAP/pkgs/ParGAP/PackageInfo.g",
AbstractHTML := 
"The ParGAP (Parallel GAP) package implements Master-Slave parallelism  on \
multiple machines and in doing so provides  a  way  of  writing  parallel \
programs using the  GAP  language.  Former  names  of  the  package  were \
ParGAP/MPI and GAP/MPI; the word MPI refers to Message Passing Interface, \
a well-known standard  for  parallelism.  ParGAP  is  based  on  the  MPI \
standard, and includes a subset  implementation  of  MPI,  to  provide  a \
portable layer  with  a  high  level  interface  to  BSD  sockets.  Since \
knowledge of MPI is not required for use of this software, we  now  refer \
to the package as simply ParGAP. ParGAP also implements the more advanced \
TOP-C model for cooperative parallelism.",
PackageWWWHome := "http://www.ccs.neu.edu/home/gene/pargap.html",
PackageDoc := rec(
  BookName  := "ParGAP",
  ArchiveURLSubset := ["doc", "htm"],
  HTMLStart := "htm/chapters.htm",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Parallel GAP",
  Autoload  := true
),
Dependencies := rec(
  GAP := ">=4.4",
  NeededOtherPackages := [],
  SuggestedOtherPackages := [],
  ExternalConditions := []
                      
),
AvailabilityTest := function()
  if IsBoundGlobal("MPI_Initialized") then
    return ARCH_IS_UNIX() and not IsBoundGlobal("SendMsg");
  else
    #Info(InfoWarning, 1,
    #     "``ParGAP'' should be invoked by the script ",
    #     "generated during installation.");
    #Info(InfoWarning, 1,
    #     "Type `?Running ParGAP' for more details.");
    return false;
  fi;
end,

BannerString :="",
#  Concatenation(
#      "\n",
#      "    Adding parallel features, loading package ...\n",
#      "\n",
#      "    #######                 #######       ##       #######  \n",
#      "    ########               #########     ####      ######## \n",
#      "    ###   ###             ####     #     ####      ###   ###\n",
#      "    ###   ###             ###           ######     ###   ###\n",
#      "    ########              ###   ####   ###  ###    ######## \n",
#      "    #######   ##### # ### ###   ####   ########    #######  \n",
#      "    ###      ##  ## ##    ####   ###  ##########   ###      \n",
#      "    ###      ##  ## ##     #########  ###    ###   ###      \n",
#      "    ###       ### # ##      ######   ###      ###  ###      \n",
#      "\n",
#      "    Parallel GAP, Version: ", "1.2.0", "\n",
#      "    by Gene Cooperman <gene@ccs.neu.edu>\n",
#      "    Type `?ParGAP' for information about using ParGAP.\n",
#      "\n"
#  ),

Autoload := true,
#TestFile := "tst/testall.g",
Keywords := ["Parallel",  "Top-C"]
));


