#############################################################################
##
#W init.g                                                   Laurent Bartholdi
##
#H   @(#)$Id: init.g,v 1.50 2011/05/16 07:05:45 gap Exp $
##
#Y Copyright (C) 2006, Laurent Bartholdi
##
#############################################################################
##
##  This file reads the declarations of the packages' new objects
##
#############################################################################

POSTHOOK@fr := []; # to be processed at the end

#############################################################################
##
#I Create info class to be able to debug loading
##
InfoFR := NewInfoClass("InfoFR");
SetInfoLevel(InfoFR, 1);
#############################################################################

#############################################################################

if true  then # a set of hacks
    Info(InfoPackageLoading,2,"Installing missing 2-argument `MaximumList' and `MinimumList'");
    InstallOtherMethod(MaximumList, "with seed",
            [IsSortedList, IsInt],
            function(list,seed)
        local i;
        if Length(list)>0 then
            i := list[Length(list)];
            if i>seed then return i; fi;
        fi;
        return seed;
    end);

InstallOtherMethod(MaximumList, "with seed",
        [IsList, IsInt],
        function(list,seed)
    local i;
    for i in list do
        if i>seed then
            seed := i;
        fi;
    od;
    return seed;
end);

InstallOtherMethod(MinimumList, "with seed",
        [IsSortedList, IsInt],
        function(list,seed)
    local i;
    if Length(list)>0 then
        i := list[1];
        if i<seed then return i; fi;
    fi;
    return seed;
end);

InstallOtherMethod(MinimumList, "with seed",
        [IsList, IsInt],
        function(list,seed)
    local i;
    for i in list do
        if i<seed then
            seed := i;
        fi;
    od;
    return seed;
end);
fi;
#############################################################################
##
#R Read the declaration files.
##
ReadPackage("fr", "gap/helpers.gd");
ReadPackage("fr", "gap/perlist.gd");
ReadPackage("fr", "gap/trans.gd");
ReadPackage("fr", "gap/frmachine.gd");
ReadPackage("fr", "gap/frelement.gd");
ReadPackage("fr", "gap/mealy.gd");
ReadPackage("fr", "gap/group.gd");
ReadPackage("fr", "gap/vector.gd");
ReadPackage("fr", "gap/algebra.gd");
ReadPackage("fr", "gap/img.gd");
ReadPackage("fr", "gap/examples.gd");

CallFuncList(function()
    local dirs, dll, w;
    dirs := DirectoriesPackagePrograms("fr");
    dll := Filename(dirs,"fr_dll.so");
    if dll=fail then
        dll := Filename(dirs[1],"fr_dll.so");
        for w in ["COMPLEX_ROOTS","DELAUNAY_TRIANGULATION","DELAUNAY_FIND",
                "FIND_BARYCENTER","FIND_RATIONALFUNCTION","STRING_MACFLOAT_FR",
                "EQ_P1POINT","LT_P1POINT","SphereP1","P1Sphere",
                "P1POINT2STRING","P1Distance","P1POINT2C2","P1BARYCENTRE",
                "P1MAP2","P1MAP3","COMPOSEP1MAP","INVERTP1MAP","P1MAP2MAT",
                "P1Image","P1PreImages","CleanedP1Map","P1ROTATION",
                "P1INTERSECT","P1MapCriticalPoints","DegreeOfP1Map",
		"P1Path","P1Circumcentre","NFFUNCTION_FR","P1XRatio",
                "SphereP1Y","CleanedP1Point","P1Midpoint"] do
            BindGlobal(w, function(arg)
                Error("You need to compile ",dll," before using ",w,"\nYou may compile it with './configure && make' in ",PackageInfo("fr")[1].InstallationPath,"\n...");
            end);
        od;
        BindGlobal("MAT2P1MAP",ReturnFail);
        BindGlobal("P1Antipode",ReturnFail); # hack, so we can define P1infinity
        BindGlobal("C22P1POINT",ReturnFail);
    else
        LoadDynamicModule(dll);
    fi;
end,[]);

if not IsBound(IsLpGroup) then
    ForAll(["IsLpGroup","IsElementOfLpGroup","LPresentedGroup",
            "ElementOfLpGroup","SetEmbeddingOfAscendingSubgroup"], function(w)
        BIND_GLOBAL(w, fail);
        Add(POSTHOOK@fr,function() MAKE_READ_WRITE_GLOBAL(w); UNBIND_GLOBAL(w); end);
        return true;
    end);
fi;

InstallMethod(IsMatrixModule,[IsFRAlgebra],1000,ReturnFalse);
# otherwise, bug causes SubmoduleNC(algebra,[]) to run indefinitely

#############################################################################

#E init.g . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
