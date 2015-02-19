# Adjust the path for the major release
gappath:="gap4r7";

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

pkgs:=GAPInfo.PackagesInfo;;
pkgs:=SortedList(ShallowCopy(RecNames(pkgs)));

# Hints for other packages that we recommend to install
recommended:=[ "atlasrep", "design", "grape", "guava", "example" ];

# Hints for (some) packages that do not work under Windows 
nowindows:=["ace", "anupq", "carat", "cohomolo", "float", "fplsa", "gauss",
"kbmag", "linboxing", "nq", "pargap", "polymakeinterface", "xgap" ];

Print("=============================================================\n");
# Packages needed by GAP
needed:= List( GAPInfo.Dependencies.NeededOtherPackages, pkg -> pkg[1] );
Print("* ", Length(needed), " packages needed by GAP: ", needed, "\n\n");

Print("=============================================================\n");
# Iteratively extending the list of packages that do not work under
# Windows with with packages that require packages from this list
nowindows:=Set(nowindows);
repeat
  n:=Length(nowindows);
  for pkg in pkgs do
    if not pkg in nowindows then
      neededpkg:=GAPInfo.PackagesInfo.(pkg)[1].Dependencies.NeededOtherPackages;
      if Length(neededpkg) > 0 then
        new := Filtered( neededpkg, x -> LowercaseString(x[1]) in nowindows );
          if Length( new ) > 0 then
          AddSet( nowindows, pkg );
          Print("Package ", pkg, 
                " does not work under Windows since it requires \n  ", new, "\n"); 
        fi;
      fi;
    fi;  
  od;
until Length(nowindows)=n;

Print("\n");
Print("* ", Length(nowindows), 
       " packages not working under Windows :\n", nowindows, "\n"); 

Print("=============================================================\n");
# Packages loaded in the default configuration
# As on Feb 18th 2012 in GAP.dev the list is
# [ "autpgrp", "alnuth", "crisp", "factint", "fga", "irredsol", 
# "laguna", "polenta", "polycyclic", "resclasses", "sophus" ]
default:=SortedList(ShallowCopy( GAPInfo.UserPreferences.gap.PackagesToLoad ));

default := Union( default, recommended ); 
     
Print("Starting with the following list of default packages :\n", default, "\n"); 

# Now find transitive closure w.r.t. needed and suggested packages
repeat
  n:=Length(default);
  
  required:=List( Union(needed, default), pkg -> GAPInfo.PackagesInfo.(pkg)[1].Dependencies.NeededOtherPackages);
  required:=Filtered( required, x -> Length(x) > 0 );
  required:=Union( List( required, x -> List( x, pkg -> LowercaseString(pkg[1]) ) ) );
  required:=Filtered( required, x -> not x in nowindows and not x in default and not x in needed );
  
  suggested:=List( Union(needed, default), pkg -> GAPInfo.PackagesInfo.(pkg)[1].Dependencies.SuggestedOtherPackages);
  suggested:=Filtered( suggested, x -> Length(x) > 0 );
  suggested:=Union( List( suggested, x -> List( x, pkg -> LowercaseString( pkg[1] ) ) ) );
  suggested:=Filtered( suggested, x -> not x in nowindows and not x in default and not x in needed );
  
  new := Union ( required, suggested );
  # tweaking to exclude GAP 3.4.4 package "chevie"
  new := Filtered(new, x -> x <> "chevie" );
  Print("Adding ", new, "\n"); 
  default:=Union(default,new);
until Length(default)=n;  

Print("\n");
Print("* ", Length( default ), " default packages :\n", default, "\n");

Print("=============================================================\n");
# All the remaining packages go into the specialised group
special := Filtered( pkgs, pkg -> not pkg in needed and 
                                  not pkg in default and 
                                  not pkg in nowindows );
Print("\n");
Print("* ", Length( special ), " specialised packages: \n", special, "\n");

# Check that each package is precisely in one group
classes := [needed, default, special, nowindows];
for pkg in pkgs do
  if Number( classes, x -> pkg in x ) <> 1 then
    Error("Classification error for the package ", pkg ); 
  fi;
od;
 
Print("=============================================================\n\n");

nsisstr:="";
nsisout := OutputTextString(nsisstr,false);
SetPrintFormattingStatus(nsisout, false);

PrintHeader := function( txt )
AppendTo(nsisout,"#######################################################################\n");
AppendTo(nsisout,"#\n");
AppendTo(nsisout,"# ", txt, "\n");
AppendTo(nsisout,"#\n"); 
end;

PrintSection := function( pkg, mandatory )
local pkgname, dirname;
pkgname := GAPInfo.PackagesInfo.(pkg)[1].PackageName;
dirname := Basename( GAPInfo.PackagesInfo.(pkg)[1].InstallationPath );
PrintHeader( pkgname );
AppendTo(nsisout,"Section \"", pkgname, "\" SecGAPpkg_", pkg," \n");
if mandatory then
  AppendTo(nsisout,"SectionIn RO \n");
fi;  
AppendTo(nsisout,"SetOutPath $INSTDIR\\pkg \n");
AppendTo(nsisout,"File ", gappath, "\\pkg\\README.", pkg, "\n");
AppendTo(nsisout,"SetOutPath $INSTDIR\\pkg\\", dirname, "\n");
AppendTo(nsisout,"File /r ", gappath, "\\pkg\\", dirname, "\\*.* \n");
AppendTo(nsisout,"SetOutPath $INSTDIR \n");
AppendTo(nsisout,"SectionEnd \n\n");
end;

PrintTo(nsisout, "# This part is autogenerated by GAP\n");

PrintHeader("Needed packages");
AppendTo(nsisout,"SectionGroup \"Needed packages\" SecGAPpkgsNeeded\n\n");
  for pkg in needed do
    PrintSection( pkg, true );
  od;
AppendTo(nsisout,"SectionGroupEnd \n");
AppendTo(nsisout,"# Needed packages end here\n\n");

PrintHeader("Default packages");
AppendTo(nsisout,"SectionGroup \"Default packages\" SecGAPpkgsDefault\n\n");
  for pkg in default do
    PrintSection( pkg, false );
  od;
AppendTo(nsisout,"SectionGroupEnd \n");
AppendTo(nsisout,"# Default packages end here\n\n");

PrintHeader("Specialised  packages");
AppendTo(nsisout,"SectionGroup \"Specialised  packages\" SecGAPpkgsSpecial\n\n");
  for pkg in special do
    PrintSection( pkg, false );
  od;
AppendTo(nsisout,"SectionGroupEnd \n");
AppendTo(nsisout,"# Specialised packages end here\n\n");

PrintHeader("Packages that do not work under Windows");
AppendTo(nsisout,"SectionGroup \"Packages requiring UNIX/Linux\" SecGAPpkgsNoWindows\n\n");
  for pkg in nowindows do
    PrintSection( pkg, false );
  od;
AppendTo(nsisout,"SectionGroupEnd \n");
AppendTo(nsisout,"# Packages that do not work under Windows end here\n\n");

AppendTo(nsisout,"#######################################################################\n");
AppendTo(nsisout,"# Descriptions\n\n");
AppendTo(nsisout,"# Language strings\n");

AppendTo(nsisout,"LangString DESC_SecGAPcore ${LANG_ENGLISH} \"The core GAP system (GAP kernel, GAP library, data libraries, manuals and tests)\"\n\n");

AppendTo(nsisout,"LangString DESC_SecGAPpkgsNeeded ${LANG_ENGLISH} \"Packages needed to run GAP (in addition to these we advise to install also at least all default packages, some of which extend the GAP functionality quite substantially)\"\n");
AppendTo(nsisout,"LangString DESC_SecGAPpkgsDefault ${LANG_ENGLISH} \"Default packages (loaded by default when GAP starts), and a selection of other packages and data libraries. We advise to select the whole group since dependencies between individual packages are not traced\"\n");
AppendTo(nsisout,"LangString DESC_SecGAPpkgsSpecial ${LANG_ENGLISH} \"Optional packages (some of these are for an expert installation; we advise to select the whole group since dependencies between individual packages are not traced)\"\n");
AppendTo(nsisout,"LangString DESC_SecGAPpkgsNoWindows ${LANG_ENGLISH} \"Packages that do not work under Windows (install them if you wish to be able to access their code and documentation)\"\n\n");


for pkg in pkgs do
  AppendTo(nsisout,"LangString DESC_SecGAPpkg_", pkg, " ${LANG_ENGLISH} \"", NormalizedWhitespace(GAPInfo.PackagesInfo.(pkg)[1].Subtitle), "\"\n");
od;

AppendTo(nsisout,"\n");
AppendTo(nsisout,"# Assign language strings to sections\n");
AppendTo(nsisout,"!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN\n");
AppendTo(nsisout,"!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPcore} $(DESC_SecGAPcore)\n");
AppendTo(nsisout,"\n");
AppendTo(nsisout,"!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkgsNeeded} $(DESC_SecGAPpkgsNeeded)\n");
AppendTo(nsisout,"!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkgsDefault} $(DESC_SecGAPpkgsDefault)\n");
AppendTo(nsisout,"!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkgsSpecial} $(DESC_SecGAPpkgsSpecial)\n");
AppendTo(nsisout,"!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkgsNoWindows} $(DESC_SecGAPpkgsNoWindows)\n");
AppendTo(nsisout,"\n");

for pkg in pkgs do
  AppendTo(nsisout,"!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_", pkg, "} $(DESC_SecGAPpkg_", pkg, ")\n");
od;
AppendTo(nsisout,"\n!insertmacro MUI_FUNCTION_DESCRIPTION_END\n\n\n");

name := Filename( DirectoryCurrent(), "nsiscript.mid" ); 
output := OutputTextFile( name, false );
WriteAll( output, nsisstr );
CloseStream(output);

