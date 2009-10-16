#############################################################################
##  
##  PackageInfo.g for the package `vecenum'                      Steve Linton
##  

SetPackageInfo( rec(

PackageName := "vecenum",
Subtitle := "Vector Enumeration",
Version := "0.91",
Date := "16/12/2003",
ArchiveURL := "", 
ArchiveFormats := ".tar.gz",

Persons := [
  rec( 
      LastName      := "Linton",
      FirstNames    := "Steve",
      IsAuthor      := true,
      IsMaintainer  := true,
      Email         := "sal@dcs.st-and.ac.uk",
      WWWHome       := "",
      PostalAddress := "",
      Place         := "",
           Institution   := ""),
  rec( 
      LastName      := "Waldhausen",
      FirstNames    := "Maja",
      IsAuthor      := true,
      IsMaintainer  := false,
      Email         := "maja@dcs.st-and.ac.uk",
      WWWHome       := "",
      PostalAddress := "",
      Place         := "",
           Institution   := ""),
            ],

Status := "dev",
#CommunicatedBy := "",
#AcceptDate := "",

README_URL := "",
PackageInfoURL := "",
AbstractHTML := "",
PackageWWWHome := "",
               
PackageDoc := rec(
  BookName  := "VecEnum",
  ArchiveURLSubset := ["doc", "htm"],
  HTMLStart := "htm/chapters.htm",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Vector Enumeration",
  Autoload  := false),

Dependencies := rec(
  GAP := ">=4.3",
  NeededOtherPackages := [],
  SuggestedOtherPackages := [],
  ExternalConditions := [] ),

AvailabilityTest := ReturnTrue,
BannerString := "Loading VecEnum 0.91 ... \n",
Autoload := false,
Keywords := ["vector enumeration"]

));


