
InstallMethod( UnderlyingElement, "for an pc group element",
  [ IsMultiplicativeElementWithInverseByRws and IsObjWithMemory ],
  function(el)
    local und,ob;
    und := UnderlyingElement(el!.el);
    ob := rec( slp := el!.slp, n := el!.n, el := und );
    return Objectify( TypeOfObjWithMemory(FamilyObj(und)), ob );
  end );

InstallMethod( ExtRepOfObj, "for a free group element",
  [ IsObjWithMemory ],
  function( ob )
    return ExtRepOfObj(ob!.el);
  end);

InstallOtherMethod( NumberSyllables, "for a free group element",
  [ IsObjWithMemory ],
  function( ob )
    return NumberSyllables(ob!.el);
  end );

InstallMethod( Comm, "for two rws-elements",
  [ IsMultiplicativeElementWithInverseByRws and IsObjWithMemory,
    IsMultiplicativeElementWithInverseByRws and IsObjWithMemory ],
  function(a,b)
    local r,slp;
    slp := a!.slp;
    if a!.n = 0 or b!.n = 0 then
        r := rec(slp := slp, n := 0, el := One(a!.el));
    else
        Add(slp.prog,[b!.n,1,a!.n,1]);
        Add(slp.prog,[a!.n,1,b!.n,1]);
        Add(slp.prog,[Length(slp.prog)+slp.nogens-1,-1,
                      Length(slp.prog)+slp.nogens,1]);
        r := rec(slp := slp, n := Length(slp.prog)+slp.nogens,
                 el := Comm(a!.el,b!.el));
    fi;
    Objectify(TypeOfObjWithMemory(FamilyObj(a)),r);
    return r;
  end);

InstallOtherMethod( ExponentSums, "for an associative word and two ints",
  [ IsAssocWord and IsObjWithMemory, IsInt, IsInt ],
  function( ob, a, b )
    return ExponentSums(ob!.el,a,b);
  end );

InstallMethod( ExponentSums, "for an associative word and two ints",
  [ IsAssocWord and IsObjWithMemory ],
  function( ob )
    return ExponentSums(ob!.el);
  end );


g := WreathProduct(SymmetricGroup(4),SymmetricGroup(4));
i := IsomorphismPcGroup(g);
gens := List(GeneratorsOfGroup(g),x->ImageElm(i,x));
gensm := GeneratorsWithMemory(gens);
p := GroupWithGenerators(gens);
pm := GroupWithGenerators(gensm);
ids := List([1..Length(gens)],i->());
idsm := GeneratorsWithMemory(ids);
gm := Group(idsm);
iso := GroupHomomorphismByImages(p,gm,gens,idsm);
pc := Pcgs(p);
gensim := List(pc,x->ImageElm(iso,x));
s := SLPOfElms(gensim);   
ResultOfStraightLineProgram(s,gens) = pc;

