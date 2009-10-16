DeclareRepresentation("IsRecognitionOutcomeDefaultRep", IsPositionalObjectRep,2);

BindGlobal("RecognitionOutcomesFamily",
        NewFamily("RecognitionOutcomesFamily",
                IsRecognitionOutcome));

BindGlobal("RecognitionOutcomesDefaultType", 
        NewType(RecognitionOutcomesFamily, 
                IsRecognitionOutcome and IsRecognitionOutcomeDefaultRep and
                HasNameOfRecognitionOutcome and HasDescriptionOfRecognitionOutcome));

InstallGlobalFunction("DeclareRecognitionOutcome",
        function(name,descr)
    BindGlobal(name, Objectify(RecognitionOutcomesDefaultType, [name, descr]));
end);

DeclareRecognitionOutcome("RO_INAPPLICABLE_ALGORITHM",
        "Algorithm not applicable to this group");

DeclareRecognitionOutcome("RO_NO_SUCH_EPIMORPHISM",
        "No such epimorphism exists");

DeclareRecognitionOutcome("RO_CONTRADICTION",
        "I found a contradiction in the information in this group");

DeclareRecognitionOutcome("RO_NO_LUCK",
        "I think I was just unlucky");

DeclareRecognitionOutcome("RO_TOO_BIG",
        "This computation was too big for me");

DeclareRecognitionOutcome("RO_OTHER",
        "Something else happened");

InstallMethod(NameOfRecognitionOutcome,
        [IsRecognitionOutcomeDefaultRep and IsRecognitionOutcome],
        o->o![1]);

InstallMethod(DescriptionOfRecognitionOutcome,
        [IsRecognitionOutcomeDefaultRep and IsRecognitionOutcome],
        o->o![2]);

InstallMethod(\=,[IsRecognitionOutcome, IsRecognitionOutcome],
        function(o1,o2)
    return NameOfRecognitionOutcome(o1) = NameOfRecognitionOutcome(o2);
end);

InstallMethod(ViewObj,[IsRecognitionOutcome],
        function(o)
    Print(NameOfRecognitionOutcome(o));
end);

InstallMethod(PrintObj,[IsRecognitionOutcome],
        function(o)
    Print(NameOfRecognitionOutcome(o));
end);

InstallMethod(Display,[IsRecognitionOutcome],
        function(o)
    Print(NameOfRecognitionOutcome(o),": ",
          DescriptionOfRecognitionOutcome(o),"\n");
end);



BindGlobal("NON_CONSTRUCTIVE_RECOGNIZERS", []);

BindGlobal("NON_CONSTRUCTIVE_RECOGNIZER_DESCRIPTIONS", []);

InstallGlobalFunction(InstallNonConstructiveRecognizer, function(f, descr)
    if not IsFunction(f) then
        Error("InstallNonConstructiveRecognizer: argument must be a function");
    fi;
    if not IsString(descr) then
        Error("InstallNonConstructiveRecognizer: description should be a string");
    fi;
    Add(NON_CONSTRUCTIVE_RECOGNIZERS,f); 
    Add(NON_CONSTRUCTIVE_RECOGNIZER_DESCRIPTIONS,descr); 
end);
    
BindGlobal("FACTORIZERS", []);
BindGlobal("FACTORIZER_DESCRIPTIONS", []);

InstallGlobalFunction(InstallFactorizer, function(f, descr)
    if not IsFunction(f) then
        Error("InstallFactorizer: argument must be a function");
    fi;
    if not IsString(descr) then
        Error("InstallFactorizer: description should be a string");
    fi;
    Add(FACTORIZERS, f); 
    Add(FACTORIZER_DESCRIPTIONS, descr); 
end);
    
BindGlobal("EPIMORPHSIM_CONSTRUCTORS", []);
BindGlobal("EPIMORPHSIM_CONSTRUCTOR_DESCRIPTIONS", []);

InstallGlobalFunction(InstallEpimorphismConstructor, function(r,descr)
    if not IsRecord(r) then
        Error("InstallNonConstructiveRecognizer: argument must be a function");
    fi;
    if not IsString(descr) then
        Error("InstallNonConstructiveRecognizer: description should be a string");
    fi;
    Add(EPIMORPHSIM_CONSTRUCTORS, r); 
    Add(EPIMORPHSIM_CONSTRUCTOR_DESCRIPTIONS, descr); 
end);
    
    
InstallMethod(RecognitionInfo, "initialise with empty record", [IsGroup], 
        g -> rec());
        
InstallGlobalFunction(NonConstructivelyRecognize, 
        function(g)
    local   i,  f,  res;
    for i in [1..Length(NON_CONSTRUCTIVE_RECOGNIZERS)] do
        f := NON_CONSTRUCTIVE_RECOGNIZERS[i];
        Info(InfoRecog,3,"Trying ",NON_CONSTRUCTIVE_RECOGNIZER_DESCRIPTIONS[i]);
        res := f(g);
        if IsRecognitionOutcome(res) then
            if res <> RO_INAPPLICABLE_ALGORITHM then
                Info(InfoRecog,2,"Non-constructive recognition method ",
                     NON_CONSTRUCTIVE_RECOGNIZER_DESCRIPTIONS[i],
                     " reported ",res);
            else
                Info(InfoRecog,3,"    not applicable");
            fi;
        else
            Info(InfoRecog,1,"Non-constructive recognition method ",
                 NON_CONSTRUCTIVE_RECOGNIZER_DESCRIPTIONS[i],
                 " succeeded");
            return res;
        fi;
    od;
    Info(InfoRecog,1,"No method could name this group");
    return fail;
end);

InstallGlobalFunction(FindSimplifyingEpimorphism,
        function(g)
    local   i,  f,  res;
    for i in [1..Length(EPIMORPHSIM_CONSTRUCTORS)] do
        f := EPIMORPHSIM_CONSTRUCTORS[i].constructor;
        Info(InfoRecog,3,"Trying ",EPIMORPHSIM_CONSTRUCTOR_DESCRIPTIONS[i]);
        res := f(g);
        if IsRecognitionOutcome(res) then
            if res <> RO_INAPPLICABLE_ALGORITHM then
                Info(InfoRecog,2,"Epimorphism constructoe recognition method ",
                     EPIMORPHSIM_CONSTRUCTOR_DESCRIPTIONS[i],
                     " reported failure");
            else
                Info(InfoRecog,3,"    not applicable");
            fi;
            Info(InfoRecog,1,"Epimorphism constructoe recognition method ",
                 EPIMORPHSIM_CONSTRUCTOR_DESCRIPTIONS[i],
                 " succeeded");
            return GroupHomomorphismByFunction(g,res.image, x-> EPIMORPHSIM_CONSTRUCTORS[i].epi(res,x));
        fi;

    od;
    Info(InfoRecog,1,"No method succeeded in finding a useful epimorphism from this group");
    return fail;
end);

InstallGlobalFunction(FactorizeGroupElement,
        function(g,gens,x)
    local   i,  f,  res;
    for i in [1..Length(FACTORIZERS)] do
        f := FACTORIZERS[i];
        Info(InfoRecog,3,"Trying ",FACTORIZER_DESCRIPTIONS[i]);
        res := f(g,gens,x);
        if IsRecognitionOutcome(res) then
            if res <> RO_INAPPLICABLE_ALGORITHM then
                Info(InfoRecog,2,"Factorization recognition method ",
                     FACTORIZER_DESCRIPTIONS[i],
                     " reported failure");
            else
                Info(InfoRecog,3,"    not applicable");
            fi;
            Info(InfoRecog,1,"Factorization recognition method ",
                 FACTORIZER_DESCRIPTIONS[i],
                 " succeeded");
            return res;
        fi;
    od;
    Info(InfoRecog,1,"No method could factorize this element");
    return fail;
end);

