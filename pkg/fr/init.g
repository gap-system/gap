#############################################################################
##
#W init.g                                                   Laurent Bartholdi
##
#H   @(#)$Id: init.g,v 1.32 2009/10/09 15:07:08 gap Exp $
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
##
#W  Add missing methods
##
if false then
    Info(InfoWarning,1,"Installed generic IsSubset");
InstallOtherMethod(IsSubset,
        [IsObject,IsObject],
        function(x,y)
    for y in y do if not y in x then return false; fi; od; return true;
end);
fi;
InstallMethod(String, "ultimate recourse for groups",
        [IsGroup],
        function(O)
    local s, os;
    s := "";
    os := OutputTextString(s,true);
    PrintTo(os,O);
    CloseStream(os);
    return s;
end);
#############################################################################

if GAPInfo.Version{[1..3]}="4.4" then # a set of hacks
    Info(InfoFR,2,"Extending `ListPerm'");
    __ListPerm := ListPerm;
    MakeReadWriteGlobal("ListPerm");
    ListPerm := function(arg)
        local l; l := __ListPerm(arg[1]);
        while Length(arg)=2 and Length(l)<arg[2] do Add(l,Length(l)+1); od;
        return l;
    end;

    Info(InfoFR,2,"Declaring stubs for FLOAT and COMPLEX -- will be broken");
    InstallOtherMethod(Sqrt,[IsFloat],x->x);
    DeclareSynonym("MacFloat", Float);
    DeclareSynonym("IsMacFloat", IsFloat);
    DeclareSynonym("MACFLOAT_INT", FLOAT_INT);
    DeclareSynonym("MACFLOAT_STRING", FLOAT_STRING);
    ForAll(["ACOS","COS","SIN","TAN","LOG","EXP","ATAN2","RINT"], function(w)
        BindGlobal(Concatenation(w,"_MACFLOAT"), function(arg)
            Info(InfoFR,2,"You need a more recent GAP kernel to use this floating-point function; I'll return 0");
	    return Float(0);
        end);
        return true;
    end);

    DeclareOperation("AsPermutation",[IsObject]); # appeared in 4.dev

    Info(InfoFR,2,"Fixing bug in GroupHomomorphismByImagesNC for 0-generated groups");
    InstallOtherMethod(GroupHomomorphismByImagesNC,[IsGroup,IsGroup,IsEmpty,IsEmpty],SUM_FLAGS,
            function(g,h,gg,gh)
        return GroupHomomorphismByFunction(g,h,x->One(h));
    end);

    Info(InfoFR,2,"Fixing bug in IsomorphismFpMonoid for 0-generated groups");
    InstallOtherMethod(IsomorphismFpMonoid,[IsFpGroup], SUM_FLAGS,
            function(g)
        local f, h;
        if Length(GeneratorsOfGroup(g))>0 then
            TryNextMethod();
        fi;
        f := FreeMonoid(0); SetIsFreeMonoid(f,true);
        h := f/[]; SetFreeMonoidOfFpMonoid(h,f);
        return MagmaIsomorphismByFunctionsNC(g,h,x->One(h),x->One(g));
    end);
    
    InstallOtherMethod(GeneratorsOfLeftOperatorRingWithOne,[IsLeftOperatorRing],GeneratorsOfLeftOperatorRing);
fi;

if not IsBound(FpElementNFFunction) then # appeared in 4.dev
    DeclareSynonym("FpElementNFFunction", FpElmKBRWS);
fi;

if not IsBound(IsomorphismFpMonoidInversesFirst) then # appeared in 4.dev
    DeclareSynonym("IsomorphismFpMonoidInversesFirst", IsomorphismFpMonoid);
fi;

if not IsBound(DirectSum) then
DeclareGlobalFunction("DirectSum");
DirectSumOp := fail; # shut up warning
InstallGlobalFunction(DirectSum, function(arg)
    local d;
    if Length(arg) = 0 then
        Error("<arg> must be nonempty");
    elif Length(arg) = 1 and IsList(arg[1])  then
        if IsEmpty(arg[1])  then
            Error("<arg>[1] must be nonempty");
        fi;
        arg := arg[1];
    fi;
    d := DirectSumOp(arg,arg[1]);
    if ForAll(arg, HasSize) then
        if ForAll(arg, IsFinite) then
            SetSize(d, Product( List(arg, Size)));
        else
            SetSize(d, infinity);
        fi;
    fi;
    return d;
end);
Unbind(DirectSumOp);
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
if IsBound(MacFloat) then
    ReadPackage("fr", "gap/img.gd");
fi;
ReadPackage("fr", "gap/examples.gd");

CallFuncList(function()
    local dirs, dll, w;
    dirs := DirectoriesPackagePrograms("fr");
    dll := Filename(dirs,"fr_dll.so");
    if dll=fail then
        dll := Filename(dirs[1],"fr_dll.so");
        if IsBound(PACKAGE_WARNING) then
            LogPackageLoadingMessage(PACKAGE_WARNING, Concatenation("Could not find ",dll,"; did you compile it?"));
        fi;
        for w in ["COMPLEX_ROOTS","DELAUNAY_TRIANGULATION","DELAUNAY_FIND",
                "FIND_BARYCENTER","ARC_MIN_SPAN_TREE"] do            
            BindGlobal(w, function(arg)
                Error("Could not find ",dll,"; did you compile it?");
            end);
        od;
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
#############################################################################

#E init.g . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
