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

PrintHeader := function( txt )
Print("#######################################################################\n");
Print("#\n");
Print("# ", txt, "\n");
Print("#\n"); 
end;

PrintSection := function( pkg, mandatory )
local pkgname, dirname;
pkgname := GAPInfo.PackagesInfo.(pkg)[1].PackageName;
dirname := Basename( GAPInfo.PackagesInfo.(pkg)[1].InstallationPath );
PrintHeader( pkgname );
Print("Section \"", pkgname, "\" SecGAPpkg_", pkg," \n");
if mandatory then
  Print("SectionIn RO \n");
fi;  
Print("SetOutPath $INSTDIR\\pkg \n");
Print("File gap4r5\\pkg\\README.", pkg, "\n");
Print("SetOutPath $INSTDIR\\pkg\\", dirname, "\n");
Print("File /r gap4r5\\pkg\\", dirname, "\\*.* \n");
Print("SetOutPath $INSTDIR \n");
Print("SectionEnd \n\n");
end;

Print("=============================================================\n\n");

PrintHeader("Needed packages");
Print("SectionGroup \"Needed packages\" SecGAPpkgsNeeded\n\n");
  for pkg in needed do
    PrintSection( pkg, true );
  od;
Print("SectionGroupEnd \n");
Print("# Needed packages end here\n\n");

PrintHeader("Default packages");
Print("SectionGroup \"Default packages\" SecGAPpkgsDefault\n\n");
  for pkg in default do
    PrintSection( pkg, false );
  od;
Print("SectionGroupEnd \n");
Print("# Default packages end here\n\n");

PrintHeader("Specialised  packages");
Print("SectionGroup \"Specialised  packages\" SecGAPpkgsSpecial\n\n");
  for pkg in special do
    PrintSection( pkg, false );
  od;
Print("SectionGroupEnd \n");
Print("# Specialised packages end here\n\n");

PrintHeader("Packages that do not work under Windows");
Print("SectionGroup \"Packages requiring UNIX/Linux\" SecGAPpkgsNoWindows\n\n");
  for pkg in nowindows do
    PrintSection( pkg, false );
  od;
Print("SectionGroupEnd \n");
Print("# Packages that do not work under Windows end here\n\n");

Print("=============================================================\n\n");
for pkg in pkgs do
  Print("LangString DESC_SecGAPpkg_", pkg, " ${LANG_ENGLISH} \"", NormalizedWhitespace(GAPInfo.PackagesInfo.(pkg)[1].Subtitle), "\"\n");
od;
Print("=============================================================\n\n");
for pkg in pkgs do
  Print("!insertmacro MUI_DESCRIPTION_TEXT ${SecGAPpkg_", pkg, "} $(DESC_SecGAPpkg_", pkg, ")\n");
od;
Print("=============================================================\n\n");

