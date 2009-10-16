#############################################################################
##
#W read.g                                                   Laurent Bartholdi
##
#H   @(#)$Id: read.g,v 1.15 2009/07/16 19:59:37 gap Exp $
##
#Y Copyright (C) 2006, Laurent Bartholdi
##
#############################################################################
##
##  This file reads the implementations, and in principle could be reloaded
##  during a GAP session.
#############################################################################

#############################################################################
##
#R Read the install files.
##
ReadPackage("fr", "gap/helpers.gi");
ReadPackage("fr", "gap/perlist.gi");
ReadPackage("fr", "gap/trans.gi");
ReadPackage("fr", "gap/frmachine.gi");
ReadPackage("fr", "gap/frelement.gi");
ReadPackage("fr", "gap/mealy.gi");
ReadPackage("fr", "gap/group.gi");
ReadPackage("fr", "gap/vhgroup.gi");
ReadPackage("fr", "gap/vector.gi");
ReadPackage("fr", "gap/linear.gi");
ReadPackage("fr", "gap/algebra.gi");
if IsBound(MacFloat) then
    ReadPackage("fr", "gap/img.gi");
fi;
ReadPackage("fr", "gap/examples.gi");
#############################################################################

#############################################################################
##
#X install shortcuts
##
INSTALL@ := function()
    CallFuncList(function(arg)
        local s;
        for s in arg do
            if IsBoundGlobal(s) then
                Info(InfoFR,2,Concatenation("Removing cybersquatter `",s,"'"));
                if IsReadOnlyGlobal(s) then MakeReadWriteGlobal(s); fi;
                UnbindGlobal(s);
            fi;
        od;
    end, ["Nucleus","Decomposition"]);

    DeclareOperation("Nucleus", [IsFRSemigroup]);
    InstallMethod(Nucleus, [IsFRSemigroup], NucleusOfFRSemigroup);
    DeclareOperation("Nucleus", [IsFRMachine]);
    InstallMethod(Nucleus, "(FR) for an FR machine", [IsFRMachine], NucleusOfFRMachine);

    DeclareOperation("Decomposition", [IsFRMachine]);
    InstallMethod(Decomposition, "(FR) for an FR element", [IsFRElement], DecompositionOfFRElement);
end;
#############################################################################

DeclareAttribute("Alphabet", IsFRObject);
DeclareAttribute("Alphabet", IsFRSemigroup);
#DeclareAttribute("Alphabet", IsFRAlgebra); # since they're semigroups
InstallMethod(Alphabet, [IsFRObject], AlphabetOfFRObject);
InstallMethod(Alphabet, [IsFRSemigroup], AlphabetOfFRSemigroup);
InstallMethod(Alphabet, [IsFRAlgebra], AlphabetOfFRAlgebra);

while not IsEmpty(POSTHOOK@) do Remove(POSTHOOK@)(); od;
Unbind(POSTHOOK@);

#E read.g . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
