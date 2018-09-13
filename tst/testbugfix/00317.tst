##  bug 2 for fix 6
gap> if TestPackageAvailability("tomlib") <> fail and
>       LoadPackage("tomlib", false) <> fail then
>      DerivedSubgroupsTom( TableOfMarks( "A10" ) );
>    fi;
