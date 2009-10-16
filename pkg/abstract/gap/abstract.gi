#
# These still get conmfused around attribute testers
#

BindGlobal("IsAttribute",  f -> IsOperation(f) and false <> Tester(f));

BindGlobal("IsProperty",  f -> IsAttribute(f) and IsFilter(f));

InstallFlushableValue(KnownAbstractGroupAbstractions, []);

InstallMethod(AbstractionsOfGroup, 
        "construct abstract structures behind a perm group",
        true,
        [IsPermGroup],
        0,
        function(g)
    local abs, chr, rep, gen, con;
    abs := rec();
    Objectify(NewType( AbstractionsFamily,
            IsAbstractGroupAbstraction and IsAttributeStoringRep), abs);
    chr := rec();
    Objectify(NewType( AbstractionsFamily,
            IsPermutationCharacterAbstraction and
            IsAttributeStoringRep), chr);
    rep := rec();
    Objectify(NewType( AbstractionsFamily,
            IsPermutationRepresentationAbstraction and
            IsAttributeStoringRep), rep);
    gen := rec();
    Objectify(NewType( AbstractionsFamily,
            IsGeneratedGroupAbstraction and IsAttributeStoringRep), gen);
    con := rec();
    Objectify(NewType( AbstractionsFamily,
            IsConcreteGroupAbstraction and IsAttributeStoringRep), con);
    
    SetKnownGeneratedGroupsOfAbstractGroup(abs, []);
    SetKnownCharactersOfAbstractGroup(abs, []);
    SetKnownRepresentationsOfCharacter( chr, []);
    SetKnownConcreteGroupsOfRepresentation( rep, []);
    SetKnownConcreteGroupsOfGeneratedGroup( gen, []);
    SetKnownGroupsOfConcreteGroupAbstraction( con, []);
    
    SetCurrentRepresentationOfConcreteGroupAbstraction(con, [rep]);
    SetCurrentGeneratedGroupOfConcreteGroupAbstraction(con, [gen]);
    SetCurrentCharacterOfRepresentationAbstraction(rep, [chr]);
    SetCurrentAbstractGroupOfGeneratedGroupAbstraction(gen, [abs]);
    SetCurrentAbstractGroupOfCharacterAbstraction(chr, [abs]);
    
    Add(KnownAbstractGroupAbstractions, abs);
    return rec(concrete := con, generated := gen, representation :=
               rep, character := chr, abstract := abs);
end);


InstallMethod(SetAbstractionsOfGroup, "update reverse link", true,
        [IsGroup, IsRecord], 0, 
        function(g, absrec)
    local k;
    k := KnownGroupsOfConcreteGroupAbstraction(absrec.concrete);
    if ForAll(k, x->not IsIdenticalObj(g,x)) then
        Add(k,g);
    fi;
    PropagateMaintainedDataToAbstractions(g, absrec);
    TryNextMethod();
end);

InstallMethod(SetCurrentRepresentationOfConcreteGroupAbstraction, 
        "update reverse link", true, [IsConcreteGroupAbstraction, IsList],
        0, function( con, rep)
    local k;
    rep := rep[1];
    k := KnownConcreteGroupsOfRepresentation(rep);
    if not con in k then
        Add(k, con);
    fi;
    TryNextMethod();
end);

InstallMethod(SetCurrentGeneratedGroupOfConcreteGroupAbstraction, 
        "update reverse link", true, [IsConcreteGroupAbstraction, IsList],
        0, function( con, gen)
    local k;
    gen := gen[1];
    k := KnownConcreteGroupsOfGeneratedGroup(gen);
    if not con in k then
        Add(k, con);
    fi;
    TryNextMethod();
end);

InstallMethod(SetCurrentCharacterOfRepresentationAbstraction,
        "update reverse link", true, [IsRepresentationAbstraction, IsList],
        0, function( rep, chr)
    local k;
    chr := chr[1];
    k := KnownRepresentationsOfCharacter(chr);
    if not rep in k then
        Add(k, rep);
    fi;
    TryNextMethod();
end);

InstallMethod(SetCurrentAbstractGroupOfCharacterAbstraction,
        "update reverse link", true, [IsCharacterAbstraction, IsList],
        0, function( chr, abs)
    local k;
    abs := abs[1];
    k := KnownCharactersOfAbstractGroup(abs);
    if not chr in k then
        Add(k, chr);
    fi;
    TryNextMethod();
end);

InstallMethod(SetCurrentAbstractGroupOfGeneratedGroupAbstraction,
        "update reverse link", true, [IsGeneratedGroupAbstraction, IsList],
        0, function( gen, abs)
    local k;
    abs := abs[1];
    k := KnownGeneratedGroupsOfAbstractGroup(abs);
    if not gen in k then
        Add(k, gen);
    fi;
    TryNextMethod();
end);


#
# Longer term, one could seek to identify equal abstractions
#

InstallMethod(\=, "for abstractions", true, [IsAbstraction, IsAbstraction],
        0, IsIdenticalObj);



InstallMethod(ParentAbstraction, "for actual groups", true,
        [IsGroup, IsString], 0,
        function(g, layer)
    return AbstractionsOfGroup.(layer);
end);

InstallMethod(ParentAbstraction, "for concrete group abstractions", true,
        [IsConcreteGroupAbstraction, IsString], 0,
        function(con, layer)
    if layer = "concrete" then
        return con;
    elif layer = "generated" then
        return CurrentGeneratedGroupOfConcreteGroupAbstraction(con)[1];
    elif layer = "representation" then
        return CurrentRepresentationOfConcreteGroupAbstraction(con)[1];
    elif layer = "character" then
        return CurrentCharacterOfRepresentationAbstraction(
                       CurrentRepresentationOfConcreteGroupAbstraction(con)[1])[1];
    elif layer = "abstract" then
        return CurrentAbstractGroupOfGeneratedGroupAbstraction(
                       CurrentGeneratedGroupOfConcreteGroupAbstraction(con)[1])[1];
    else
        Error("Unknown layer", layer);
    fi;
end);

InstallMethod(ParentAbstraction, "for generated group abstractions", true,
        [IsGeneratedGroupAbstraction, IsString], 0,
        function(gen, layer)
    if layer = "generated" then
        return gen;
    elif layer = "abstract" then
        return CurrentAbstractGroupOfGeneratedGroupAbstraction(gen)[1];
    elif layer in ["concrete", "representation", "character"] then
        Error("A generated group abstraction has no parent ",layer);
    else
        Error("Unknown layer", layer);
    fi;
end);

InstallMethod(ParentAbstraction, "for representation abstractions", true,
        [IsRepresentationAbstraction, IsString], 0,
        function(rep, layer)
    if layer = "representation" then
        return rep;
    elif layer = "character" then
        return CurrentCharacterOfRepresentationAbstraction(rep)[1];
    elif layer = "abstract" then
        return CurrentAbstractGroupOfCharacterAbstraction(
                       CurrentCharacterOfRepresentationAbstraction(rep)[1])[1];
    elif layer in ["concrete", "generated" ] then
        Error("A representation abstraction has no parent ",layer);
    else
        Error("Unknown layer", layer);
    fi;
end);

InstallMethod(ParentAbstraction, "for character abstractions", true,
        [IsRepresentationAbstraction, IsString], 0,
        function(chr, layer)
    if layer = "character" then
        return chr;
    elif layer = "abstract" then
        return CurrentAbstractGroupOfCharacterAbstraction(chr)[1];
    elif layer in ["concrete", "representation", "generated" ] then
        Error("A character abstraction has no parent ",layer);
    else
        Error("Unknown layer", layer);
    fi;
end);

InstallMethod(ParentAbstraction, "for abstract group abstractions", true,
        [IsAbstractGroupAbstraction, IsString], 0,
        function(abs, layer)
    if layer = "abstract" then
        return abs;
    elif layer in ["concrete", "representation", "generated", "character" ] then
        Error("An abstract group abstraction has no parent ",layer);
    else
        Error("Unknown layer", layer);
    fi;
end);



InstallMethod(AllKnownChildrenOfAbstraction, 
        "for a concrete group abstraction", true, [IsConcreteGroupAbstraction, IsString], 0,
        function(con, layer)
    if layer = "real" then
        return ShallowCopy(KnownGroupsOfConcreteGroupAbstraction(con));
    elif layer = "concrete" then
        return [con];
    elif layer in ["generated", "representation", "character",
            "abstract"] then
        Error("A concrete group abstraction has no child ",layer);
    else
        Error("Unknown layer", layer);
    fi;
end);

InstallMethod(AllKnownChildrenOfAbstraction, 
        "for a generated group abstraction", true, [IsGeneratedGroupAbstraction, IsString], 0,
        function(gen, layer)
    if layer = "real" then
        return
          Concatenation(List(KnownConcreteGroupsOfGeneratedGroup(gen), 
                  con-> AllKnownChildrenOfAbstraction(con, layer)));

    elif layer = "concrete" then
        return ShallowCopy(KnownConcreteGroupsOfGeneratedGroup(gen));
    elif layer = "generated" then
        return [gen];
    elif layer in [ "character","representation", "abstract"] then
        Error("A generated group abstraction has no child ",layer);
    else
        Error("Unknown layer", layer);
    fi;
end);

InstallMethod(AllKnownChildrenOfAbstraction, 
        "for a representation abstraction", true, [IsRepresentationAbstraction, IsString], 0,
        function(rep, layer)
    if layer = "real" then
        return
          Concatenation(List(KnownConcreteGroupsOfRepresentation(rep), 
                  con-> AllKnownChildrenOfAbstraction(con, layer)));

    elif layer = "concrete" then
        return ShallowCopy(KnownConcreteGroupsOfRepresentation(rep));
    elif layer = "representation" then
        return [rep];
    elif layer in [ "character","generated", "abstract"] then
        Error("A representation abstraction has no child ",layer);
    else
        Error("Unknown layer", layer);
    fi;
end);

InstallMethod(AllKnownChildrenOfAbstraction, 
        "for a character abstraction", true, [IsCharacterAbstraction, IsString], 0,
        function(chr, layer)
    if layer in ["concrete", "real"] then
        return
          Concatenation(List(KnownRepresentationsOfCharacter(chr), 
                  rep-> AllKnownChildrenOfAbstraction(rep, layer)));
    elif layer = "representation" then
        return ShallowCopy(KnownRepresentationsOfCharacter(chr));
    elif layer = "character" then
        return [chr];
    elif layer in [ "generated", "abstract"] then
        Error("A character abstraction has no child ",layer);
    else
        Error("Unknown layer", layer);
    fi;
end);

InstallMethod(AllKnownChildrenOfAbstraction, 
        "for an abstract group abstraction", true, [IsAbstractGroupAbstraction, IsString], 0,
        function(abs, layer)
    if layer in ["concrete", "real"] then
        return
          Concatenation(List(KnownGeneratedGroupsOfAbstractGroup(abs), 
                  gen-> AllKnownChildrenOfAbstraction(gen, layer)));
    elif layer = "representation" then
        return
          Concatenation(List(KnownCharactersOfAbstractGroup(abs), 
                  chr-> AllKnownChildrenOfAbstraction(chr, layer)));
    elif layer = "character" then
        return ShallowCopy(KnownCharactersOfAbstractGroup(abs));
    elif layer = "generated" then
        return ShallowCopy(KnownGeneratedGroupsOfAbstractGroup(abs));
    elif layer = "abstract" then
        return [abs];
    elif layer in [ "generated", "abstract"] then
        Error("A character abstraction has no child ",layer);
    else
        Error("Unknown layer", layer);
    fi;
end);
        
        


BindGlobal("ABSTRACTION_MAINTAINED_INFO", 
        rec( concrete := [],
                         generated := [],
                         representation := [],
                         character := [],
                         abstract := []));


BindGlobal("ABSTRACTION_FILTERS", rec( concrete := IsConcreteGroupAbstraction,
                                                   generated := IsGeneratedGroupAbstraction,
                                                   representation := IsRepresentationAbstraction,
                                                   character := IsCharacterAbstraction,
                                                   abstract := IsAbstractGroupAbstraction));


InstallGlobalFunction(InstallAbstractionMaintenance,
        function( attr, layer )
    local layerno;
    if not IsAttribute(attr) or not layer in RecNames(ABSTRACTION_MAINTAINED_INFO)  then
        Error("Usage: InstallAbstractionMaintenance( <attribute>, <layer> )");
    fi;
    Add(ABSTRACTION_MAINTAINED_INFO.(layer), attr);
    
    InstallOtherMethod(attr, "look in abstraction", true, [IsGroup and
            HasAbstractionsOfGroup], 0, function(g)
        local abs;
        abs := AbstractionsOfGroup(g).(layer);
        if Tester(attr)(abs) then 
            return attr(abs);
        else
            TryNextMethod();
        fi;
    end);
    
    
    InstallOtherMethod(attr, "look in real objects", 
            true, [ABSTRACTION_FILTERS.(layer)], 0,
            function(a)
        local g;
        for g in AllKnownChildrenOfAbstraction(a, "real") do
            if Tester(attr)(g) then
                return attr(g);
            fi;
        od;
        TryNextMethod();
    end);
    
    #
    # No setter methods get called for properties
    # How to handle this?
    #
    if not IsProperty(attr) then
        InstallOtherMethod(Setter(attr), "set in abstraction", true,
                [IsGroup and HasAbstractionsOfGroup, IsObject], 0,
                function(g, val)
            local abs;
            #
            # Do this first, to avoid infinite regress
            #
            abs := AbstractionsOfGroup(g).(layer);
            SetFilterObj(g, Tester(attr));
            if not Tester(attr)(abs) then
                Setter(attr)(abs, val);
            fi;
            ResetFilterObj(g, Tester(attr));
            TryNextMethod();
        end);
        
        InstallOtherMethod(Setter(attr), "set in real objects", true,
                [ABSTRACTION_FILTERS.(layer), IsObject], 0,
                function(a, val)
            local g;
            #
            # Do this first, to avoid infinite regress
            #
            SetFilterObj(a, Tester(attr));
            for g in AllKnownChildrenOfAbstraction(a, "real") do
                if not Tester(attr)(g) then
                    Setter(attr)(g, val);
                fi;
            od;
            ResetFilterObj(a, Tester(attr));
            TryNextMethod();
        end);
    fi;
    return;
end);


InstallGlobalFunction(PropagateMaintainedDataToAbstractions, 
        function( g, absrec  )
    local layer, a, attr;
    for layer in ["concrete", "generated", "representation",
            "character", "abstract" ] do 
        a := absrec.(layer);
        for attr in ABSTRACTION_MAINTAINED_INFO.(layer) do
            if Tester(attr)(g) and not Tester(attr)(a) then
                Setter(attr)(a, attr(g));
            fi;
        od;
    od;
    
end);


InstallAbstractionMaintenance( Size, "abstract");
InstallAbstractionMaintenance( IsSimpleGroup, "abstract");
InstallAbstractionMaintenance( IsNilpotentGroup, "abstract");
InstallAbstractionMaintenance( OrdinaryCharacterTable, "abstract");
InstallAbstractionMaintenance( TableOfMarks, "abstract");
InstallAbstractionMaintenance( IsFinite, "abstract");
InstallAbstractionMaintenance( IsSolvableGroup, "abstract");
InstallAbstractionMaintenance( NrMovedPoints, "character");
InstallAbstractionMaintenance( IsTransitive, "character");
InstallAbstractionMaintenance( IsPrimitive, "character");
InstallAbstractionMaintenance( Transitivity, "character");
InstallAbstractionMaintenance( MovedPoints, "representation");
InstallAbstractionMaintenance( AllBlocks, "representation");
InstallAbstractionMaintenance( NameIsomorphismClass, "abstract");
InstallAbstractionMaintenance( IsCyclic, "abstract");
InstallAbstractionMaintenance( IsElementaryAbelian, "abstract" );
InstallAbstractionMaintenance( IsPGroup, "abstract");
InstallAbstractionMaintenance( PrimePGroup, "abstract");
InstallAbstractionMaintenance( PClassPGroup, "abstract");
InstallAbstractionMaintenance( RankPGroup, "abstract" );
InstallAbstractionMaintenance( IsPerfectGroup, "abstract");
InstallAbstractionMaintenance( IsSupersolvableGroup, "abstract");
InstallAbstractionMaintenance( IsMonomialGroup, "abstract");
InstallAbstractionMaintenance( AbelianInvariants, "abstract");
InstallAbstractionMaintenance( DerivedLength, "abstract");
InstallAbstractionMaintenance( CommutatorLength, "abstract");
InstallAbstractionMaintenance( Exponent, "abstract");
InstallAbstractionMaintenance( InvariantForm, "representation");
InstallAbstractionMaintenance( NrConjugacyClasses, "abstract");




InstallMethod(PrintObj, "abstract group abstraction", true, [IsAbstractGroupAbstraction],
        function(abs) Print("<abstract group abstraction>"); end);
InstallMethod(PrintObj, "generated group abstraction", true, [IsGeneratedGroupAbstraction],
        function(abs) Print("<generated group abstraction>"); end);
InstallMethod(PrintObj, "character abstraction", true, [IsCharacterAbstraction],
        function(abs) Print("<character abstraction>"); end);
InstallMethod(PrintObj, "representation abstraction", true, [IsRepresentationAbstraction],
        function(abs) Print("<representation abstraction>"); end);
InstallMethod(PrintObj, "concrete group abstraction", true, [IsConcreteGroupAbstraction],
        function(abs) Print("<concrete group abstraction>"); end);
