#############################################################################
##
#W helpers.gi                                               Laurent Bartholdi
##
#H   @(#)$Id: helpers.gi,v 1.81 2009/10/07 19:08:45 gap Exp $
##
#Y Copyright (C) 2006, Laurent Bartholdi
##
#############################################################################
##
##  This file contains helper code for functionally recursive groups,
##  in particular related to the geometry of groups.
##
#############################################################################

#############################################################################
##
#W  Compile documentation
##
BindGlobal("PATH@", PackageInfo("fr")[1].InstallationPath);
VERSION@ := Filename(DirectoriesPackageLibrary("fr",""),".version");
if VERSION@<>fail then
    VERSION@ := ReadLine(InputTextFile(VERSION@));
    Remove(VERSION@); # remove \n
fi;

BindGlobal("DOC@", function() MakeGAPDocDoc(Concatenation(PATH@,"/doc"),"fr",
  ["../gap/frmachine.gd","../gap/frelement.gd","../gap/mealy.gd",
   "../gap/group.gd","../gap/vector.gd","../gap/algebra.gd","../gap/img.gd",
   "../gap/examples.gd","../gap/helpers.gd","../gap/perlist.gd",
   "../gap/trans.gd",
   "../PackageInfo.g"],"fr");
end);
#############################################################################

#############################################################################
##
#F Products
##
InstallGlobalFunction(TensorSum, function(arg)
    local d;
    if Length(arg) = 0 then
        Error("<arg> must be nonempty");
    elif Length(arg) = 1 and IsList(arg[1])  then
        if IsEmpty(arg[1])  then
            Error("<arg>[1] must be nonempty");
        fi;
        arg := arg[1];
    fi;
    d := TensorSumOp(arg,arg[1]);
    if ForAll(arg, HasSize) then
        if ForAll(arg, IsFinite) then
            SetSize(d, Product( List(arg, Size)));
        else
            SetSize(d, infinity);
        fi;
    fi;
    return d;
end);

BindGlobal("TENSORPRODUCT@", function(arg)
    local d;
    if Length(arg) = 0 then
        Error("<arg> must be nonempty");
    elif Length(arg) = 1 and IsList(arg[1])  then
        if IsEmpty(arg[1])  then
            Error("<arg>[1] must be nonempty");
        fi;
        arg := arg[1];
    fi;
    d := TensorProductOp(arg,arg[1]);
    if ForAll(arg, HasSize) then
        if ForAll(arg, IsFinite) then
            SetSize(d, Product( List(arg, Size)));
        else
            SetSize(d, infinity);
        fi;
    fi;
    return d;
end);
#############################################################################

#############################################################################
##
#H WordGrowth(g,options)
##
COLOURLIST@ :=
  ["red","blue","green","gray","yellow","cyan","orange","purple"];
BindGlobal("COLOURS@", function(i)
    return COLOURLIST@[(i-1) mod Length(COLOURLIST@)+1];
end);

BindGlobal("EXEC@", rec());
BindGlobal("CHECKEXEC@", function(prog)
    local s;

    if IsBound(EXEC@.(prog)) then return; fi;

    s := Filename(DirectoriesSystemPrograms(), prog);
    while s=fail do
        Error("Could not find program \"",prog,"\" -- set manually EXEC@fr.",prog);
    od;
    EXEC@.(prog) := s;
end);

BindGlobal("EXECINSHELL@", function(input,command,detach)
    local tmp, outs, output;
    outs := "";
    output := OutputTextString(outs,false);
    CHECKEXEC@("sh");

    if detach=fail then
        if IsString(input) then input := InputTextString(input); fi;
    else
	tmp := Filename(DirectoryTemporary(), "stdin");
        if not IsString(input) then
	    input := ReadAll(input);
        fi;
        PrintTo(tmp, input);
        input := InputTextNone();
        CHECKEXEC@("cat");
        command := Concatenation("cat ",tmp,"|",command,"&");
    fi;
    Process(DirectoryCurrent(), EXEC@.sh, input, output, ["-c", command]);
    return outs;
end);

BindGlobal("DOT2DISPLAY@", function(str,prog,args)
    CHECKEXEC@("display");
    CHECKEXEC@(prog);
    CHECKEXEC@("sh");

    return EXECINSHELL@(str,Concatenation(EXEC@.(prog)," ",args," | ",EXEC@.display),ValueOption("detach"));
end);

BindGlobal("JAVAPLOT@", function(input)
    local r, s;
    CHECKEXEC@("appletviewer");

    s := "";
    r := [Concatenation("-J-Djava.security.policy=",Filename(DirectoriesPackageLibrary("fr","java"),"javaplot.pol")), Filename(DirectoriesPackageLibrary("fr","java"),"javaplot.html")];
    if ValueOption("detach")<>fail then
        r := EXECINSHELL@(input,Concatenation(EXEC@.appletviewer," ",r[1]," ",r[2]),true);
    else
        r := Process(DirectoryCurrent(), EXEC@.appletviewer, input,
                     OutputTextString(s,false), r);
    fi;
    if r<>"" and r<>0 then
        Error("JAVAPLOT: error ",r,": ",s);
    fi;
end);

InstallGlobalFunction(WordGrowth, function(arg)
    local gpgens, gens, sphere, i, j, k, n, t, result, limit, keep, g,
          point, draw, S, plotedge, plotvertex,
          trackgroup, trackgens, track, trackhom,
          group, options, optionnames;
    
    optionnames := ["track","limit","draw","point","ball","sphere","balls",
                    "spheres","spheresizes","ballsizes"];
    if Length(arg)=2 then
        group := arg[1];
        options := arg[2];
    elif Length(arg)>2 then
        Error("Too many arguments for WordGrowth");
    else
        group := arg[1];
        options := rec();
        for i in optionnames do
            if ValueOption(i)<>fail then
                options.(i) := ValueOption(i);
            fi;
        od;
    fi;
    
    if IsInt(options) then
        options := rec(spheresizes := options);
    fi;
    i := Difference(RecNames(options),optionnames);
    if not IsEmpty(i) then
        Info(InfoFR,1,"WordGrowth: unused options ",i);
    fi;

    if IsGroup(group) then
        g := group;
        gpgens := Set(GeneratorsOfGroup(g));
        gens := Union(gpgens,List(gpgens,Inverse),[One(g)]);
    elif IsSemigroup(group) then
        g := group;
        gens := Set(GeneratorsOfSemigroup(g));
    elif IsList(group) then
        g := Semigroup(group);
        gens := Set(group);
    else
        TryNextMethod();
    fi;

    if IsBound(options.track) then
        track := [];
        if IsGroup(g) and not IsList(group) then
            if IsList(options.track) then
                trackgroup := FreeGroup(options.track);
            else
                trackgroup := FreeGroup(Length(GeneratorsOfGroup(g)));
            fi;
            trackgens := GroupHomomorphismByImages(trackgroup,g,GeneratorsOfGroup(trackgroup),GeneratorsOfGroup(g));
            trackgens := List(gens,x->PreImagesRepresentative(trackgens,x));
            trackhom := GroupHomomorphismByImagesNC(trackgroup,g,GeneratorsOfGroup(trackgroup),GeneratorsOfGroup(g));
        elif IsMonoid(g) and not IsList(group) then
            if IsList(options.track) then
                trackgroup := FreeMonoid(options.track);
            else
                trackgroup := FreeMonoid(Length(GeneratorsOfMonoid(g)));
            fi;
            trackgens := GeneratorsOfMonoid(trackgroup){List(gens,x->Position(GeneratorsOfMonoid(g),x))};
            trackhom := FreeMonoidNatHomByGeneratorsNC(trackgroup,g);
        elif IsSemigroup(g) then
            if IsList(options.track) then
                trackgroup := FreeSemigroup(options.track);
            else
                trackgroup := FreeSemigroup(Length(GeneratorsOfSemigroup(g)));
            fi;
            trackgens := GeneratorsOfSemigroup(trackgroup){List(gens,x->Position(GeneratorsOfSemigroup(g),x))};
            trackhom := FreeSemigroupNatHomByGeneratorsNC(trackgroup,g);
        fi;
    else
        track := fail;
    fi;

    if IsBound(options.limit) then
        limit := options.limit;
    else
        limit := infinity;
    fi;
    keep := IsBound(options.ball) or IsBound(options.balls) or
            IsBound(options.spheres) or not IsBound(gpgens);
    if IsBound(options.point) then
        point := options.point;
    else
        point := fail;
    fi;
    if IsBound(options.draw) then
        draw := options.draw;
    else
        draw := fail;
    fi;
    if IsBound(options.sphere) and limit=infinity then
        limit := options.sphere;
    fi;
    if IsBound(options.spheres) and limit=infinity then
        limit := options.spheres;
    fi;
    if IsBound(options.spheresizes) and limit=infinity then
        limit := options.spheresizes;
    fi;
    if IsBound(options.ball) and limit=infinity then
        limit := options.ball;
    fi;
    if IsBound(options.balls) and limit=infinity then
        limit := options.balls;
    fi;
    if IsBound(options.ballsizes) and limit=infinity then
        limit := options.ballsizes;
    fi;

    if draw<>fail then
        S := "digraph cayley {\n";
        plotedge := function(nsrc,src,ndst,dst,gen)
            local dir, col;
            dir := "forward";
            if IsBound(gpgens) then
                if IsOne(gen^2) then
                    dir := "both";
                    if ndst=nsrc and dst<src then return; fi;
                fi;
                if gen in gpgens then
                    col := Position(gpgens,gen);
                else
                    col := Position(gpgens,gen^-1);
                    dir := "back";
                fi;
            else
                col := Position(gens,gen);
            fi;
            Append(S,"  "); Append(S,String(nsrc)); Append(S,String("."));
            Append(S,String(src)); Append(S," -> ");
            Append(S,String(ndst)); Append(S,String("."));
            Append(S,String(dst)); Append(S," [color=");
            Append(S,COLOURS@(col)); Append(S,",dir=");
            Append(S,dir); Append(S,"];\n");
        end;
        plotvertex := function(nsrc,src)
            Append(S,"  "); Append(S,String(nsrc)); Append(S,String("."));
            Append(S,String(src));
            Append(S," [height=0.3,width=0.6,fixedsize=true]\n");
        end;
    fi;

    i := PositionProperty(gens,IsMultiplicativeElementWithOne and IsOne);
    if i<>fail then
        sphere := [gens[i]];
        if track<>fail then
            Add(track,[trackgens[i]]);
        fi;
        Remove(gens,i);
    elif HasOne(g) then
        sphere := [One(g)];
        if track<>fail then
            Add(track,[One(trackgroup)]);
        fi;
    else
        sphere := [];
        if track<>fail then Add(track,[]); fi;
    fi;
    if point=fail then
        sphere := [sphere,Difference(gens,sphere)];
        if track<>fail then
            Add(track,trackgens);
            if not IsEmpty(track[1]) then
                t := Position(track[2],track[1][1]);
                if t<>fail then Remove(track[2],t); fi;
            fi;
        fi;
    else
        sphere := List(sphere,g->point^g);
        if track=fail then
            sphere := [sphere,Difference(Set(gens,g->point^g),sphere)];
        else
            sphere := [sphere,[]];
            Add(track,[]);
            for i in [1..Length(gens)] do
                j := point^gens[i];
                if not (j in sphere[1] or j in sphere[2]) then
                    t := PositionSorted(sphere[2],j);
                    Add(sphere[2],j,t);
                    Add(track,trackgens[i],t);
                fi;
            od;
        fi;
    fi;
    if draw<>fail then
        if sphere[1]<>[] then
            for n in [1..Length(gens)] do
                if point=fail then
                    i := n;
                else
                    i := Position(sphere[2],point^gens[n]);
                fi;
                if i=fail then
                    if point^gens[n]=point then
                        plotedge(0,1,0,1,gens[n]);
                    fi;
                else
                    plotedge(0,1,1,i,gens[n]);
                fi;
            od;
        fi;
        if limit<infinity then limit := limit+1; fi;
    fi;
    result := List(sphere,Size);

    n := 1; while n < limit do
        Add(sphere,[]);
        if track<>fail then
            Add(track,[]);
        fi;
        if track<>fail then
            for i in [1..Length(gens)] do for j in [1..Length(sphere[n+1])] do
                if point=fail then
                    k := sphere[n+1][j]*gens[i];
                else
                    k := sphere[n+1][j]^gens[i];
                fi;
                if (IsBound(gpgens) and
                    not (k in sphere[n] or k in sphere[n+1])) or
                   (not IsBound(gpgens) and not ForAny([1..n+1],i->k in sphere[i])) then
                    t := PositionSorted(sphere[n+2],k);
                    if not IsBound(sphere[n+2][t]) or sphere[n+2][t]<>k then
                        Add(sphere[n+2],k,t);
                        Add(track[n+2],track[n+1][j]*trackgens[i],t);
                    fi;
                fi;
            od; od;
        elif draw=fail then
            for i in gens do for j in sphere[n+1] do
                if point=fail then k := j*i; else k := j^i; fi;
                if (IsBound(gpgens) and
                    not (k in sphere[n] or k in sphere[n+1])) or
                   (not IsBound(gpgens) and not ForAny([1..n+1],i->k in sphere[i])) then
                    AddSet(sphere[n+2],k);
                fi;
            od; od;
        else
            for i in gens do for j in [1..Length(sphere[n+1])] do
                if point=fail then k := sphere[n+1][j]*i; else
                    k := sphere[n+1][j]^i;
                fi;
                t := 1; while t <= Length(sphere) do
                    if IsBound(sphere[t]) and k in sphere[t] then break; fi;
                    t := t+1;
                od;
                if t>Length(sphere) then
                    if n+1<limit then
                        Add(sphere[n+2],k); t := n+2;
                    else
                        continue;
                    fi;
                fi;
                if (not IsBound(gpgens)) or ((i in gpgens and t >= n+1) or (t >= n+2)) then
                    plotedge(n,j,t-1,Position(sphere[t],k),i);
                fi;
            od; od;
        fi;
        if limit=infinity and IsEmpty(sphere[n+2]) then
            Remove(sphere);
            if IsEmpty(sphere[n+1]) then Remove(sphere); Remove(result); fi;
            if track<>fail then
                Remove(track);
                if IsEmpty(track[n+1]) then Remove(track); fi;
            fi;
            break;
        fi;
        Add(result,Size(sphere[n+2]));
        n := n+1;
        if not keep then Unbind(sphere[n-1]); fi;
    od;
    if limit=0 then
        Unbind(result[2]); Unbind(sphere[2]);
    fi;
    if IsBound(options.spheresizes) then
        return result;
    elif IsBound(options.ballsizes) then
        return List([1..Length(result)],i->Sum(result{[1..i]}));
    elif IsBound(options.sphere) then
        if track=fail then
            return sphere[limit+1];
        else
            return [sphere[limit+1],trackhom,track[limit+1]];
        fi;
    elif IsBound(options.spheres) then
        if track=fail then return sphere; else return [sphere,trackhom,track]; fi;
    elif IsBound(options.ball) then
        if track=fail then
            return Union(sphere);
        else
            sphere := Concatenation(sphere); track := Concatenation(track);
            SortParallel(sphere,track);
            return [sphere,trackhom,track];
        fi;
    elif IsBound(options.balls) then
        if track=fail then
            return List([1..Length(sphere)],i->Union(sphere{[1..i]}));
        else
            t := [[],trackhom,[]];
            for i in [1..Length(sphere)] do
                Add(t[1],Concatenation(sphere{[1..i]}));
                Add(t[3],Concatenation(track{[1..i]}));
                SortParallel(t[1][i],t[3][i]);
            od;
            return t;
        fi;
    elif IsBound(options.indet) then
        i := options.indet;
        if HasIsUnivariatePolynomial(i) and IsUnivariatePolynomial(i) then
            i := IndeterminateNumberOfUnivariateRationalFunction(i);
        else i := 1; fi;
        return UnivariatePolynomial(Integers,result,i);
    elif draw<>fail then
        if not IsBound(result[n+1]) then n := n-1; fi;
        for n in [0..n] do for i in [1..result[n+1]] do
            plotvertex(n,i);
        od; od;
        Append(S,"}\n");
        if IsString(draw) then
            AppendTo(draw,S);
        else
            DOT2DISPLAY@(S, "neato", "-Gbgcolor=white -Tps 2>/dev/null");
        fi;
    else
        return result; # by default, same as 'spheresizes'
    fi;
end);

InstallOtherMethod(Draw, "(FR) default",
        [IsObject],
        function(l)
    WordGrowth(l,rec(draw:=true));
end);

InstallOtherMethod(Draw, "(FR) default, with filename",
        [IsObject,IsString],
        function(l,w)
    WordGrowth(l,rec(draw:=w));
end);

InstallOtherMethod(Draw, "(FR) default, with options",
        [IsObject,IsRecord],
        function(l,options)
    options := ShallowCopy(options);
    options.draw := true;
    WordGrowth(l,options);
end);

InstallMethod(Ball, "(FR) for an object and a limit radius",
        [IsObject,IsInt],
        function(x,n)
    return WordGrowth(x,rec(ball:=n));
end);

InstallMethod(Sphere, "(FR) for an object and a limit radius",
        [IsObject,IsInt],
        function(x,n)
    return WordGrowth(x,rec(sphere:=n));
end);

InstallGlobalFunction(OrbitGrowth, "(FR) for an object and point or options",
        function(arg)
    if Length(arg)=2 then
        return WordGrowth(arg[1],rec(point:=arg[2]));
    else
        return WordGrowth(arg[1],rec(point:=arg[2],limit:=arg[3]));
    fi;
end);
#############################################################################

#############################################################################
##
#H StringByInt
##
InstallGlobalFunction(StringByInt, function(arg)
    local base, result, digit, n;
    if Size(arg)=1 then base := 2; else base := arg[2]; fi;
    result := "";
    n := arg[1];
    while n>0 do
        digit := n mod base;
        if digit <= 10 then
            digit := CHAR_INT(digit+INT_CHAR('0'));
        else
            digit := CHAR_INT(digit+INT_CHAR('a')-10);
        fi;
        Add(result,digit,1);
        n := QuoInt(n,base);
    od;
    return result;
end);

InstallGlobalFunction(PositionInTower, function(seq,x)
    local low, high, mid;
    low := 1; high := Size(seq);
    if not IsList(x) then x := [x]; fi;
    if x=seq[Length(seq)] then
        return infinity;
    elif not IsSubset(seq[1],x) then
        return fail;
    fi;
    while low < high-1 do
        mid := QuoInt(low+high,2);
        if IsSubset(seq[mid],x) then
            low := mid;
        else high := mid; fi;
    od;
    return low;
end);

InstallGlobalFunction(CoefficientsInAbelianExtension, function(x,seq,G)
    local ord, i, j, k;
    ord := [];
    for i in [1..Length(seq)] do
        j := 1; k := seq[i];
        while not k in G do j := j+1; k := k*seq[i]; od;
        Add(ord,[0..j-1]);
    od;
    return Filtered(Cartesian(ord),
                   s->Product([1..Length(seq)],n->seq[n]^s[n])/x in G);
end);

BindGlobal("MAPPEDWORD@", function(arg)
    local i, e, w, gens;

    w := arg[1];
    while not IsAssocWord(w) do w := UnderlyingElement(w); od;
    w := LetterRepAssocWord(w);
    gens := arg[2];
    if IsEmpty(w) then
        if Length(arg)=2 then return One(gens[1]); else return arg[3]; fi;
    fi;
    e := fail;
    for i in w do
        if e=fail then
            if i>0 then e := gens[i]; else e := Inverse(gens[-i]); fi;
        elif i>0 then
            e := e*gens[i];
        elif i<0 then
            e := e/gens[-i];
        fi;
    od;
    return e;
    #!!! could be a bit smarter here: if all gens are free group elements,
    # can construct a word by concatenation and convert it once to a free
    # group element; if all gens are fr elements on the same machine, idem.
    # this would presumably speed up quite a lot the code.
end);

InstallGlobalFunction(MagmaEndomorphismByImagesNC, function(f,im)
    return MagmaHomomorphismByImagesNC(f,f,im);
end);

InstallGlobalFunction(MagmaHomomorphismByImagesNC, function(f,g,im)
    local one;

    if IsGroup(f) and IsGroup(g) then
        return GroupHomomorphismByImagesNC(f,g,GeneratorsOfGroup(f),im);
    elif IsFreeGroup(f) or (HasIsFreeMonoid(f) and IsFreeMonoid(f)) or (HasIsFreeSemigroup(f) and IsFreeSemigroup(f)) then
        if IsMonoid(g) then
            one := One(g);
        else
            one := fail;
        fi;
        return MagmaHomomorphismByFunctionNC(f,g,w->MAPPEDWORD@(w,im,one));
    fi;

    if IsMonoid(f) and IsMonoid(g) then
        return MagmaHomomorphismByFunctionNC(f,g,function(x)
            local s;
            s := ShortMonoidWordInSet(f,x,infinity);
            if Length(s)<2 then return fail; fi;
            return MAPPEDWORD@(s[2],im,One(g));
        end);
    else
        return MagmaHomomorphismByFunctionNC(f,g,function(x)
            local s;
            s := ShortSemigroupWordInSet(f,x,infinity);
            if Length(s)<2 then return fail; fi;
            return MAPPEDWORD@(s[2],im,fail);
        end);
    fi;
end);

InstallMethod(ImagesSet, "(FR) for a magma homomorphism",
        [IsMagmaHomomorphism, IsMagma],
	function(map,set)
    local f;
    if HasGeneratorsOfGroup(set) then
        f := GeneratorsOfGroup;
    elif HasGeneratorsOfMonoid(set) or HasGeneratorsOfSemigroup(set) or HasGeneratorsOfMagma(set) then
        f := GeneratorsOfMagma;
    else
    	TryNextMethod();
    fi;
    if not IsGroupHomomorphism(map) then
        f := GeneratorsOfMagma;
    fi;
    set := List(f(set),x->x^map);
    if f=GeneratorsOfGroup then
        return GroupByGenerators(set);
    else
    	return MagmaByGenerators(set);
    fi;
end);
#############################################################################

#############################################################################
##
#H ShortMonoidRelations
##
BindGlobal("FINDMONOIDRELATIONS@", function(gens,n)
    local free, seen, reducible, i, iterate, result, freegens;
    free := FreeMonoid(Length(gens));
    freegens := GeneratorsOfMonoid(free);
    seen := NewDictionary(gens[1],true);
    reducible := NewDictionary(freegens[1],false);
    iterate := function(level,elem,word)
        local i, newword;
        if level=0 then
            if KnowsDictionary(seen,elem) then
                Add(result,[word,LookupDictionary(seen,elem)]);
                AddDictionary(reducible,word);
            fi;
            AddDictionary(seen,elem,word);
        else
            AddDictionary(seen,elem,word);
            for i in [1..Length(gens)] do
                newword := word*freegens[i];
                if ForAll([1..Length(newword)],i->not KnowsDictionary(reducible,Subword(newword,i,Length(newword)))) then
                    iterate(level-1,elem*gens[i],newword);
                fi;
            od;
        fi;
    end;
    result := [FreeMonoidNatHomByGeneratorsNC(free,Monoid(gens))];
    for i in [1..n] do iterate(i,gens[1]^0,freegens[1]^0); od;
    return result;
end);

InstallMethod(ShortMonoidRelations, "for a monoid and a length",
        [IsMonoid,IsInt],
        function(m,n)
    return FINDMONOIDRELATIONS@(GeneratorsOfMonoid(m),n);
end);
InstallMethod(ShortMonoidRelations, "for a list and a length",
        [IsListOrCollection,IsInt],
        FINDMONOIDRELATIONS@);

BindGlobal("FINDGROUPRELATIONS_ADD@", function(result,w)
    if Sum(ExponentSums(w))>=0 then
        Add(result,w);
    else
        Add(result,w^-1);
    fi;
end);

BindGlobal("FINDGROUPRELATIONS@", function(group,gens,n)
    local freegens, pigens, freegensinv, pi, inv,
          i, j, k, m, mm, newf, newg, result, rws, seen, todo, x, y, z;

    gens := Unique(Concatenation(gens,List(gens,Inverse)));
    result := [EpimorphismFromFreeGroup(group)];
    y := GeneratorsOfGroup(group);
    z := GeneratorsOfGroup(Source(result[1]));
    for i in [1..Length(y)] do
        for j in [i+1..Length(y)] do
            if y[i]=y[j] then
                FINDGROUPRELATIONS_ADD@(result,z[i]/z[j]);
            elif y[i]=y[j]^-1 then
                FINDGROUPRELATIONS_ADD@(result,z[i]*z[j]);
            fi;
        od;
    od;
    x := FreeMonoid(Length(gens));
    rws := KnuthBendixRewritingSystem(x/[]);
    freegens := GeneratorsOfMonoid(x);
    pigens := List(gens,x->First(GeneratorsOfSemigroup(Source(result[1])),y->y^result[1]=x));
    pi := MagmaHomomorphismByImagesNC(x,Source(result[1]),pigens);
    freegensinv := [];
    for i in [1..Length(gens)] do
        j := Position(gens,gens[i]^-1);
        Add(freegensinv,freegens[j]);
        AddRuleReduced(rws,[[i,j],[]]);
        if j=i then
            FINDGROUPRELATIONS_ADD@(result,(freegens[i]^pi)^2);
        fi;
    od;
    freegensinv := List([1..Length(freegens)],
                        i->freegens[Position(gens,gens[i]^-1)]);
    inv := MagmaHomomorphismByFunctionNC(x,x,
                   w->Reversed(MappedWord(w,freegens,freegensinv)));
    seen := NewDictionary(gens[1],true);

    todo := NewFIFO([[0,freegens[1]^0,gens[1]^0]]); # store [len, normalform, elt]
    AddDictionary(seen,gens[1]^0,freegens[1]^0);

    for i in todo do
        m := i[1]+1;
        for j in [1..Length(gens)] do
            newf := i[2]*freegens[j];
            if not IsReducedForm(rws,newf) then continue; fi;
            newg := i[3]*gens[j];
            x := LookupDictionary(seen,newg);
            if x<>fail then
                mm := Length(x);
                newf := ReducedForm(rws,newf*x^inv);
                if Length(newf)<m+mm then continue; fi;
                FINDGROUPRELATIONS_ADD@(result,newf^pi);
                x := [newf^2,(newf^inv)^2];
                for j in [1..2] do
                    if m=mm then
                        for k in [1..2*m] do
                            y := ReducedForm(rws,Subword(x[j],k,k+m-1));
                            z := ReducedForm(rws,Subword(x[3-j],2*m-k+2,3*m-k+1));
                            if y>z then y := [y,z]; else y := [z,y]; fi;
                            AddRuleReduced(rws,List(y,LetterRepAssocWord));
                        od;
                    fi;
                    for k in [1..m+mm] do
                        y := Subword(x[j],k,k+mm);
                        z := Subword(x[3-j],m+mm-k+2,2*m+mm-k);
                        AddRuleReduced(rws,List([y,z],LetterRepAssocWord));
                    od;
                od;
            elif m<=n then
                AddDictionary(seen,newg,newf);
                Add(todo,[m,newf,newg]);
            fi;
        od;
    od;
    return result;
end);

InstallMethod(ShortGroupRelations, "for a group and a length",
        [IsGroup,IsInt],
        function(g,n)
    return FINDGROUPRELATIONS@(g,GeneratorsOfGroup(g),n);
end);
InstallMethod(ShortGroupRelations, "for a list and a length",
        [IsListOrCollection,IsInt],
        function(g,n)
    return FINDGROUPRELATIONS@(Group(g),g,n);
end);

BindGlobal("SHORTWORDINSET@", function(f,fgen,fone,ggen,gone,set,result,n)
    local x, newfx, newlen, i, seen, forbidden, todo, justone;
    if n<0 then
        n := -n;
        justone := false;
    else
        justone := true;
    fi;
    if fone=fail then
        todo := NewFIFO(List([1..Length(fgen)],i->[ggen[i],fgen[i],1]));
    else
        todo := NewFIFO([[gone,fone,0]]);
    fi;
    if Length(ggen)=0 then # special case
        if IsList(set) then
            if gone in set then Add(result,fone); fi;
        elif IsFunction(set) then
            if set(gone) then Add(result,fone); fi;
        else
            if set=gone then Add(result,fone); fi;
        fi;
        return result;
    fi;
    seen := NewDictionary(ggen[1],false);
    forbidden := NewDictionary(Representative(f),false);
    for x in todo do
        if justone and KnowsDictionary(seen,x[1]) then
            AddDictionary(forbidden,x[2]);
            continue;
        fi;
        AddDictionary(seen,x[1]);
        if IsList(set) then
            if x[1] in set then Add(result,x[2]); if justone then break; fi; fi;
        elif IsFunction(set) then
            if set(x[1]) then Add(result,x[2]); if justone then break; fi; fi;
        else
            if x[1]=set then Add(result,x[2]); if justone then break; fi; fi;
        fi;
        if x[3]<n then
            for i in [1..Length(ggen)] do
                newfx := x[2]*fgen[i];
                newlen := x[3]+1;
                if Length(newfx)<newlen then continue; fi; # free reduction
                if ForAny([1..newlen],j->KnowsDictionary(forbidden,Subword(newfx,j,newlen))) then
                    continue;
                fi;
                Add(todo,[x[1]*ggen[i],newfx,newlen]);
            od;
            continue;
        fi;
    od;
    return result;
end);

InstallMethod(ShortGroupWordInSet, "(FR) for a group, an object and an int",
        [IsGroup,IsObject,IsObject],
        function(g,set,n)
    local f, s, sinv;
    s := GeneratorsOfGroup(g);
    f := FreeGroup(Length(s));
    sinv := Concatenation(List(s,x->[x^-1,x]));
    return SHORTWORDINSET@(f,GeneratorsOfMonoid(f),One(f),sinv,One(g),
            set,[GroupHomomorphismByImagesNC(f,g,GeneratorsOfGroup(f),s)],n);
end);

InstallMethod(ShortMonoidWordInSet, "(FR) for a monoid, an object and an int",
        [IsMonoid,IsObject,IsObject],
        function(g,set,n)
    local f, s;
    s := GeneratorsOfMonoid(g);
    f := FreeMonoid(Length(s));
    return SHORTWORDINSET@(f,GeneratorsOfMonoid(f),One(f),s,One(g),
            set,[FreeMonoidNatHomByGeneratorsNC(f,g)],n);
end);

InstallMethod(ShortSemigroupWordInSet, "(FR) for a semigroup, an object and an int",
        [IsSemigroup,IsObject,IsObject],
        function(g,set,n)
    local f, s;
    s := GeneratorsOfSemigroup(g);
    f := FreeSemigroup(Length(s));
    #!!! bug: GAP refuses free semigroups on 0 generators
    return SHORTWORDINSET@(f,GeneratorsOfSemigroup(f),fail,s,fail,
            set,[FreeSemigroupNatHomByGeneratorsNC(f,g)],n);
end);
#############################################################################

#############################################################################
##
#H Braid groups
##
InstallGlobalFunction(SurfaceBraidFpGroup, function(n,g,p)
  local G, R, a, b, z, s;
  a := List([1..g],i->Concatenation("a",String(i)));
  b := List([1..g],i->Concatenation("b",String(i)));
  s := List([1..n-1],i->Concatenation("s",String(i)));
  if p>0 then
    z := List([1..p-1],i->Concatenation("z",String(i)));
  else
    z := [];
  fi;
  G := FreeGroup(Concatenation(a,b,s,z));
  a := GeneratorsOfGroup(G){[1..g]};
  b := GeneratorsOfGroup(G){[g+1..2*g]};
  s := GeneratorsOfGroup(G){[2*g+1..2*g+n-1]};
  if p>0 then
    z := GeneratorsOfGroup(G){[2*g+n..2*g+n+p-2]};
  fi;
  R := [];
  Append(R,List(Filtered(Combinations([1..n-1],2),p->AbsInt(p[1]-p[2])>=2),p->Comm(s[p[1]],s[p[2]])));
  Append(R,List([1..n-2],i->s[i]*s[i+1]*s[i]/s[i+1]/s[i]/s[i+1]));
  Append(R,List(Cartesian([2..n-1],Concatenation(a,b)),p->Comm(s[p[1]],p[2])));
  if n>1 then
    Append(R,List(Concatenation(a,b),c->c*s[1]*c*s[1]/c/s[1]/c/s[1]));
    Append(R,List([1..g],i->a[i]*s[1]*b[i]/s[1]/a[i]/s[1]/b[i]/s[1]));
    Append(R,List(Cartesian([a,b],[a,b],Combinations([1..g],2)),p->Comm(p[1][p[3][2]],p[2][p[3][1]]^s[1])));
  fi;
  if p=0 then
    Add(R,Product([1..g],i->Comm(a[i],b[i]^-1),One(G))/Product([1..n-1],i->s[i],One(G))/Product([1..n-1],i->s[n-i],One(G)));
  else
    Append(R,List(Cartesian([2..n-1],z),p->Comm(s[p[1]],p[2])));
    Append(R,List(z,z->Comm(z,s[1]*z*s[1])));
    Append(R,List(Combinations(z,2),p->Comm(p[1]^s[1],p[2])));
    Append(R,List(Cartesian(z,Concatenation(a,b)),p->Comm(p[1]^s[1],p[2])));
  fi;
  return G/R;
end);

InstallGlobalFunction(PureSurfaceBraidFpGroup, function(n,g,p)
    local B, Bg, Sg, i;
    B := SurfaceBraidFpGroup(n,g,p);
    Bg := GeneratorsOfGroup(B);
    Sg := List([1..Length(Bg)],i->());
    for i in [1..n-1] do Sg[2*g+i] := (i,i+1); od;
    return Kernel(GroupHomomorphismByImages(B,SymmetricGroup(n),Bg,Sg));
end);

InstallGlobalFunction(CharneyBraidFpGroup, function(n)
    local B, Bg, Sg, i, f;
    B := SurfaceBraidFpGroup(n,0,1);
    Bg := GeneratorsOfGroup(B);
    Sg := List([1..n-1],i->(i,i+1));
    f := GroupHomomorphismByImages(B,SymmetricGroup(n),Bg,Sg);
    Sg := [];
    for i in SymmetricGroup(n) do if i<>() then
        Add(Sg,PreImagesRepresentative(f,i));
    fi; od;
    return FpGroupPresentation(PresentationSubgroupMtc(B,Subgroup(B,Sg)));
end);

InstallGlobalFunction(ArtinRepresentation, function(n)
    local B, F, S;
    B := SurfaceBraidFpGroup(n,0,1);
    F := FreeGroup(n);
    S := GeneratorsOfGroup(F);
    return GroupHomomorphismByImages(B,AutomorphismGroup(F),
                   GeneratorsOfGroup(B),
                   List([1..n-1],i->MagmaEndomorphismByImagesNC(F,
                           Concatenation(S{[1..i-1]},
                                   [S[i+1],S[i]^S[i+1]],
                                   S{[i+2..n]}))));
end);

BindGlobal("ENDOIsOne@", function(x)
    return ForAll(GeneratorsOfGroup(Source(x)),s->s=s^x);
end);

BindGlobal("ENDONorm@", function(x)
    if ENDOIsOne@(x) then
        return 0;
    else
        return LogInt(Maximum(List(GeneratorsOfGroup(Source(x)),s->Length(s^x)))^4,2);
    fi;
end);
#############################################################################

#############################################################################
##
#M LowerCentralSeries etc. for algebras
##
InstallMethod(ProductIdeal, "for left ideal and right ideal",
        [IsAlgebra,IsAlgebra],
        function(i,j)
    local l, r, g;
    if HasLeftActingRingOfIdeal(i) then
        l := i;
    elif HasRightActingRingOfIdeal(i) then
        l := AsLeftIdeal(RightActingRingOfIdeal(i),i);
    else
        l := AsLeftIdeal(i,i);
    fi;
    if HasRightActingRingOfIdeal(j) then
        r := j;
    elif HasLeftActingRingOfIdeal(i) then
        r := AsRightIdeal(LeftActingRingOfIdeal(j),j);
    else
        r := AsRightIdeal(j,j);
    fi;
    g := [];
    for i in GeneratorsOfLeftIdeal(l) do
        for j in GeneratorsOfRightIdeal(r) do
            Add(g,i*j);
        od;
    od;
    return Ideal(LeftActingRingOfIdeal(l),g);
end);

InstallMethod(ProductBOIIdeal, "for two ideals over ring with invertible basis",
        [IsAlgebra,IsAlgebra],
        function(a,b)
    local g, r, i, j, k, c;
    if HasLeftActingRingOfIdeal(a) then
        r := LeftActingRingOfIdeal(a);
    elif HasLeftActingRingOfIdeal(b) then
        r := LeftActingRingOfIdeal(b);
    else
        r := a;
    fi;
    if HasGeneratorsOfIdeal(a) then
        a := GeneratorsOfIdeal(a);
    else
        a := GeneratorsOfAlgebra(a);
    fi;
    if HasGeneratorsOfIdeal(b) then
        b := GeneratorsOfIdeal(b);
    else
        b := GeneratorsOfAlgebra(b);
    fi;
    g := [];
    c := TwoSidedIdeal(r,g);
    for i in a do for j in b do
        k := i*j;
        if not k in c then
            Add(g,k);
            c := TwoSidedIdeal(r,g);
        fi;
    od; od;
    return c;
end);

BindGlobal("DIMENSIONSERIES@", function(A,n)
    local L, k, i;
    L := [AsTwoSidedIdeal(A,A)];
    i := AugmentationIdeal(A);
    k := i;
    while k<>L[Length(L)] and Length(L)<n do
        SetParent(k,A);
        Add(L,k);
        k := ProductBOIIdeal(k,i);
    od;
    return L;
end);

InstallMethod(DimensionSeries, "for an algebra with one",
        [IsAlgebra and HasAugmentationIdeal],
        A->DIMENSIONSERIES@(A,infinity));

InstallMethod(DimensionSeries, "for an algebra with one and a limit",
        [IsAlgebra and HasAugmentationIdeal,IsInt],
        DIMENSIONSERIES@);
#############################################################################

#############################################################################
##
#M Complex numbers, and points on the Riemann sphere
##
InstallValue(MACFLOAT_0,MacFloat(0));
InstallValue(MACFLOAT_1,MacFloat(1));
InstallValue(MACFLOAT_INF,MACFLOAT_1/MACFLOAT_0);
InstallValue(MACFLOAT_MINF,-MACFLOAT_INF);
InstallValue(MACFLOAT_NAN,MACFLOAT_0/MACFLOAT_0);
InstallValue(MACFLOAT_PI,ACOS_MACFLOAT(-MACFLOAT_1));
InstallValue(MACFLOAT_2PI,2*MACFLOAT_PI);
BindGlobal("MACFLOAT_EPS",MACFLOAT_1);
MakeReadWriteGlobal("MACFLOAT_EPS");
while MACFLOAT_1+MACFLOAT_EPS<>MACFLOAT_1 do
    MACFLOAT_EPS := MACFLOAT_EPS / 2;
od;
MakeReadOnlyGlobal("MACFLOAT_EPS");

SetLeftActingDomain(COMPLEX_FIELD,COMPLEX_FIELD);
SetCharacteristic(COMPLEX_FIELD,0);
# SetBaseField(COMPLEX_FIELD,Rationals); # no such method seems to exist
SetDimension(COMPLEX_FIELD,infinity);
SetSize(COMPLEX_FIELD,infinity);
SetIsWholeFamily(COMPLEX_FIELD,true);
SetName(COMPLEX_FIELD,"COMPLEX_FIELD");

InstallGlobalFunction(Complex, function(arg)
    local i, p, q, r, s, z;
    if Length(arg)=2 then
        return Objectify(TYPE_COMPLEX,[MacFloat(arg[1]),MacFloat(arg[2])]);
    elif IS_COMPLEX(arg[1]) then
        return arg[1];
    elif IsP1Point(arg[1]) then
        return arg[1]![1];
    elif IsMacFloat(arg[1]) or IsRat(arg[1]) then
        return Objectify(TYPE_COMPLEX,[MacFloat(arg[1]),MACFLOAT_0]);
    elif IsInfinity(arg[1]) then
        return Objectify(TYPE_COMPLEX,[MACFLOAT_INF,MACFLOAT_0]);
    elif IsCyclotomic(arg[1]) or IsAlgebraicElement(arg[1]) then
        p := MinimalPolynomial(Rationals,arg[1]);
        r := ComplexRootsOfUnivariatePolynomial(p);
        return r[1];
    elif HasIsUnivariateRationalFunction(arg[1]) and IsUnivariateRationalFunction(arg[1]) then
        p := CoefficientsOfUnivariateRationalFunction(arg[1]);
        if Length(p[1])=1 and Length(p[2])=1 and p[3]=0 then
            return Complex(p[1][1]/p[2][1]);
        else
            return fail;
        fi;
    elif IS_STRING(arg[1]) then
        s := DifferenceLists(LowercaseString(arg[1])," *");
        p := 1;
        z := [MacFloat(0),MacFloat(0)];
        while p <= Length(s) do
            i := 1;
            q := p;
            if s[p] in "+-" then p := p+1; fi;
            if s[p]='i' then i := 2; Remove(s,p); fi;
            if p>Length(s) or s[p] in "+-" then Add(s,'1',p); fi;
            while p<=Length(s) and s[p] in "0123456789." do p := p+1; od;
            if p<=Length(s) and s[p]='e' then
                p := p+2;
                while p<=Length(s) and IsDigitChar(s[p]) do p := p+1; od;
            fi;
            if p<=Length(s) and s[p]='i' then i := 2; Remove(s,p); fi;
            z[i] := z[i] + MACFLOAT_STRING(s{[q..p-1]});
        od;
        return Objectify(TYPE_COMPLEX,z);
    fi;
    Error("Unknown argument for `Complex': ",arg);
end);

InstallMethod(ComplexRootsOfUnivariatePolynomial, "for a list of coefficients",
        [IsList],
        function(l)
    local dll;
    return List(COMPLEX_ROOTS(List(l,Complex)),z->Objectify(TYPE_COMPLEX,z));
end);

InstallMethod(ComplexRootsOfUnivariatePolynomial, "for a complex polynomial",
        [IsPolynomial],
        p->ComplexRootsOfUnivariatePolynomial(CoefficientsOfUnivariatePolynomial(p)));

InstallValue(COMPLEX_0,Complex(0));
InstallValue(COMPLEX_1,Complex(1));
InstallValue(COMPLEX_I,Complex(0,1));
InstallValue(COMPLEX_2IPI,Complex(0,2*ACOS_MACFLOAT(-MACFLOAT_1)));

InstallOtherMethod(RealPart, [IS_COMPLEX], x->x![1]);
InstallOtherMethod(ImaginaryPart, [IS_COMPLEX], x->x![2]);
InstallOtherMethod(ComplexConjugate, [IS_COMPLEX],
        x->Objectify(TYPE_COMPLEX, [x![1],-x![2]]));
InstallOtherMethod(Norm, [IS_COMPLEX], x->x![1]^2+x![2]^2);
InstallOtherMethod(AbsoluteValue, [IS_COMPLEX], x->Sqrt(x![1]^2+x![2]^2));
InstallMethod(Argument, [IS_COMPLEX], x->ATAN2_MACFLOAT(x![2],x![1]));

SetIsUFDFamily(COMPLEX_FAMILY,true);
SetZero(COMPLEX_FAMILY,Complex(0));
SetOne(COMPLEX_FAMILY,Complex(1));
InstallMethod(PrintObj, [IS_COMPLEX], function(x)
    Print(x![1]);
    if x![2]>MACFLOAT_0 then
        Print("+I*",x![2]);
    elif x![2]<MACFLOAT_0 then
        Print("-I*",-x![2]);
    fi;
end);
InstallMethod(ViewObj, [IS_COMPLEX], function(x)
    local i;
    Print(x![1]);
    i := (x![2]+x![1])-x![1]; # wipe out a very small imaginary part
    if i>MACFLOAT_0 then
        Print("+I*",i);
    elif x![2]<MACFLOAT_0 then
        Print("-I*",-i);
    fi;
end);
InstallMethod(String, [IS_COMPLEX], function(x)
    local s;
    s := "";
    PrintTo(OutputTextString(s,false),x);
    return s;
end);

InstallOtherMethod(SUM, IsIdenticalObj, [IS_COMPLEX, IS_COMPLEX],
        function(x,y)
    return Objectify(TYPE_COMPLEX, [x![1]+y![1], x![2]+y![2]]);
end);
InstallOtherMethod(SUM, [IS_COMPLEX, IsMacFloat],
        function(x,y)
    return Objectify(TYPE_COMPLEX, [x![1]+y, x![2]]);
end);
InstallOtherMethod(SUM, [IS_COMPLEX, IsRat],
        function(x,y)
    return Objectify(TYPE_COMPLEX, [x![1]+y, x![2]]);
end);
InstallOtherMethod(SUM, [IsMacFloat, IS_COMPLEX],
        function(x,y)
    return Objectify(TYPE_COMPLEX, [x+y![1], y![2]]);
end);
InstallOtherMethod(SUM, [IsRat, IS_COMPLEX],
        function(x,y)
    return Objectify(TYPE_COMPLEX, [x+y![1], y![2]]);
end);
InstallOtherMethod(DIFF, IsIdenticalObj, [IS_COMPLEX, IS_COMPLEX],
        function(x,y)
    return Objectify(TYPE_COMPLEX, [x![1]-y![1], x![2]-y![2]]);
end);
InstallOtherMethod(DIFF, [IS_COMPLEX, IsMacFloat],
        function(x,y)
    return Objectify(TYPE_COMPLEX, [x![1]-y, x![2]]);
end);
InstallOtherMethod(DIFF, [IS_COMPLEX, IsRat],
        function(x,y)
    return Objectify(TYPE_COMPLEX, [x![1]-y, x![2]]);
end);
InstallOtherMethod(DIFF, [IsMacFloat, IS_COMPLEX],
        function(x,y)
    return Objectify(TYPE_COMPLEX, [x-y![1], -y![2]]);
end);
InstallOtherMethod(DIFF, [IS_COMPLEX, IsRat],
        function(x,y)
    return Objectify(TYPE_COMPLEX, [x![1]-y, x![2]]);
end);
InstallOtherMethod(AINV_MUT, [IS_COMPLEX], x->Objectify(TYPE_COMPLEX, [-x![1],-x![2]]));

InstallOtherMethod(PROD, IsIdenticalObj, [IS_COMPLEX, IS_COMPLEX],
        function(x,y)
    return Objectify(TYPE_COMPLEX, [x![1]*y![1]-x![2]*y![2],x![1]*y![2]+x![2]*y![1]]);
end);
InstallOtherMethod(PROD, [IS_COMPLEX, IsMacFloat],
        function(x,y)
    return Objectify(TYPE_COMPLEX, [x![1]*y,x![2]*y]);
end);
InstallOtherMethod(PROD, [IS_COMPLEX, IsRat],
        function(x,y)
    return Objectify(TYPE_COMPLEX, [x![1]*y,x![2]*y]);
end);
InstallOtherMethod(PROD, [IsMacFloat, IS_COMPLEX],
        function(x,y)
    return Objectify(TYPE_COMPLEX, [x*y![1],x*y![2]]);
end);
InstallOtherMethod(PROD, [IsRat, IS_COMPLEX],
        function(x,y)
    return Objectify(TYPE_COMPLEX, [x*y![1],x*y![2]]);
end);
InstallOtherMethod(INV, [IS_COMPLEX], function(x)
    local r;
    r := x![1]^2+x![2]^2;
    return Objectify(TYPE_COMPLEX, [x![1]/r,-x![2]/r]);
end);
InstallOtherMethod(QUO, IsIdenticalObj, [IS_COMPLEX, IS_COMPLEX],
        function(x,y)
    return x*INV(y);
end);
InstallOtherMethod(QUO, [IS_COMPLEX, IsMacFloat],
        function(x,y)
    return Objectify(TYPE_COMPLEX, [x![1]/y,x![2]/y]);
end);
InstallOtherMethod(QUO, [IS_COMPLEX, IsRat],
        function(x,y)
    return Objectify(TYPE_COMPLEX, [x![1]/y,x![2]/y]);
end);
InstallOtherMethod(QUO, [IsMacFloat, IS_COMPLEX],
        function(x,y)
    return x*INV(y);
end);
InstallOtherMethod(QUO, [IsRat, IS_COMPLEX],
        function(x,y)
    return x*INV(y);
end);
BindGlobal("COMPLEX_NAN",COMPLEX_0/MACFLOAT_0);
BindGlobal("COMPLEX_INF",COMPLEX_1/MACFLOAT_0);
InstallOtherMethod(POW, IsIdenticalObj, [IS_COMPLEX, IS_COMPLEX],
        function(x,y)
    local r, n, a;
    a := ATAN2_MACFLOAT(x![2],x![1]);
    n := Sqrt(x![1]^2+x![2]^2);
    r := n^y![1]*EXP_MACFLOAT(-y![2]*a);
    a := y![1]*a+y![2]*LOG_MACFLOAT(n);
    return Objectify(TYPE_COMPLEX, [r*COS_MACFLOAT(a),r*SIN_MACFLOAT(a)]);
end);
InstallOtherMethod(POW, [IS_COMPLEX, IsScalar],
        function(x,y)
    local r, a;
    r := (x![1]^2+x![2]^2)^MacFloat(y/2);
    a := ATAN2_MACFLOAT(x![2],x![1])*MacFloat(y);
    return Objectify(TYPE_COMPLEX, [r*COS_MACFLOAT(a),r*SIN_MACFLOAT(a)]);
end);
InstallOtherMethod(POW, [IsScalar, IS_COMPLEX],
        function(x,y)
    return Complex(x)^y;
end);
InstallMethod(Sqrt, [IS_COMPLEX],
        function(x)
    local r, a;
    r := Sqrt(Sqrt(x![1]^2+x![2]^2));
    a := ATAN2_MACFLOAT(x![2],x![1])*MacFloat(1/2);
    return Objectify(TYPE_COMPLEX, [r*COS_MACFLOAT(a),r*SIN_MACFLOAT(a)]);
end);
InstallOtherMethod(Random, [IS_COMPLEXCollection],
        function(D)
    if D=COMPLEX_FIELD then
        return Complex(Random(GlobalMersenneTwister, 0, 10^18)/10^18,
                       Random(GlobalMersenneTwister, 0, 10^18)/10^18);
    else
        TryNextMethod();
    fi;
end);

InstallOtherMethod(IsZero, [IS_COMPLEX], x->IsZero(x![1]) and IsZero(x![2]));
InstallOtherMethod(IsOne, [IS_COMPLEX], x->IsOne(x![1]) and IsZero(x![2]));
InstallOtherMethod(Zero, [IS_COMPLEX], x->Complex(0));
InstallOtherMethod(One, [IS_COMPLEX], x->Complex(1));
InstallMethod(EQ, IsIdenticalObj, [IS_COMPLEX, IS_COMPLEX],
        function(x,y)
    return x![1]=y![1] and x![2]=y![2];
end);
InstallMethod(EQ, [IS_COMPLEX, IsScalar], function(x,y)
    if y=infinity then return x=COMPLEX_INF; else return x=Complex(y); fi;
end);
InstallMethod(EQ, [IsScalar, IS_COMPLEX], function(x,y)
    if x=infinity then return y=COMPLEX_INF; else return Complex(x)=y; fi;
end);
InstallMethod(LT, "for complex numbers",
        [IS_COMPLEX,IS_COMPLEX],
        function(x,y)
    return x![1]<y![1] or (x![1]=y![1] and x![2]<y![2]);
end);
InstallMethod(LT, [IS_COMPLEX, IsScalar], function(x,y) return x<Complex(y); end);
InstallMethod(LT, [IsScalar, IS_COMPLEX], function(x,y) return Complex(x)<y; end);
InstallGlobalFunction(EXP_COMPLEX, function(z)
    local r;
    r := EXP_MACFLOAT(z![1]);
    return Complex(r*COS_MACFLOAT(z![2]),r*SIN_MACFLOAT(z![2]));
end);

InstallOtherMethod(ReduceCoeffs, "(FR) for complex vectors",
        [IS_COMPLEXCollection, IsInt, IS_COMPLEXCollection, IsInt],
        function (l1, n1, l2, n2)
    local l, q, i, x, y;
    if 0 = n2  then
        Error("<l2> must be non-zero");
    elif 0 = n1  then
        return n1;
    fi;
    while 0 < n2 and l2[n2] = COMPLEX_0 do n2 := n2 - 1; od;
    if 0 = n2 then
        Error("<l2> must be non-zero");
    fi;
    while 0 < n1 and l1[n1] = COMPLEX_0 do
        n1 := n1 - 1;
    od;
    while n1 >= n2  do
        q := - l1[n1] / l2[n2];
        l := n1 - n2;
        for i in [ n1 - n2 + 1 .. n1 ] do
            x := q * l2[i-n1+n2];
            y := l1[i]+x;
            if AbsoluteValue(y) <= AbsoluteValue(l1[i])*10*MACFLOAT_EPS or
               AbsoluteValue(y) <= AbsoluteValue(x)*10*MACFLOAT_EPS then
                l1[i] := COMPLEX_0;
            else
                l1[i] := y;
                l := i;
            fi;
        od;
        n1 := l;
    od;
    return n1;
end);

BindGlobal("COMPLEX_INV@", function(M)
    if Length(M)<>2 then
        TryNextMethod(); # we don't care about matrices > 2x2
    fi;
    return [[M[2][2],-M[1][2]],[-M[2][1],M[1][1]]]/(M[1][1]*M[2][2]-M[1][2]*M[2][1]);
end);
InstallOtherMethod(INV_MUT, "(FR) for a complex matrix",
        [IS_COMPLEXCollColl], COMPLEX_INV@);
InstallOtherMethod(INV, "(FR) for a complex matrix",
        [IS_COMPLEXCollColl], COMPLEX_INV@);

BindGlobal("PSL2VALUE@", function(m,z)
    if IsP1Point(z) then
        if z=P1infinity then
            z := [COMPLEX_1,COMPLEX_0];
        else
            z := [Complex(z),COMPLEX_1];
        fi;
        m := m*z;
        if m[2]=COMPLEX_0 then
            return P1infinity;
        else
            return P1Point(m[1]/m[2]);
        fi;
    fi;
    return (z*m[1][1]+m[1][2])/(z*m[2][1]+m[2][2]);
end);

BindGlobal("MATMOEBIUS@", function(m)
    local n, d;
    n := Reversed(CoefficientsOfUnivariatePolynomial(NumeratorOfRationalFunction(m)));
    d := Reversed(CoefficientsOfUnivariatePolynomial(DenominatorOfRationalFunction(m)));
    if Length(n)<2 then Add(n,COMPLEX_0,1); fi;
    if Length(d)<2 then Add(d,COMPLEX_0,1); fi;
    return [n,d];
end);

BindGlobal("CLEANUPRATIONAL@", function(f,prec)
    local n, d, z, i, m, norm;
    n := ShallowCopy(CoefficientsOfUnivariatePolynomial(NumeratorOfRationalFunction(f)));
    d := ShallowCopy(CoefficientsOfUnivariatePolynomial(DenominatorOfRationalFunction(f)));
    z := IndeterminateOfUnivariateRationalFunction(f);

    norm := List(d,Norm);
    m := Maximum(norm);
    for i in [1..Length(d)] do
        if norm[i] < prec*m then
            d[i] := Zero(d[i]);
        fi;
    od;
    norm := List(n,Norm);
    m := Maximum(norm);
    for i in [1..Length(n)] do
        if norm[i] < prec*m then
            n[i] := Zero(n[i]);
        fi;
    od;
    m := First(d,x->x<>COMPLEX_0);
    n := n/m;
    d := d/m;
    for i in [1..Length(d)] do
        if AbsoluteValue(ImaginaryPart(d[i])) < prec*AbsoluteValue(RealPart(d[i])) then
            d[i] := Complex(RealPart(d[i]),MACFLOAT_0);
        fi;
    od;
    for i in [1..Length(n)] do
        if AbsoluteValue(ImaginaryPart(n[i])) < prec*AbsoluteValue(RealPart(n[i])) then
            n[i] := Complex(RealPart(n[i]),MACFLOAT_0);
        fi;
    od;
    return Sum([1..Length(n)],i->n[i]*z^(i-1)) / Sum([1..Length(d)],i->d[i]*z^(i-1));
end);

InstallMethod(PROD, "(FR) for a rational and a complex rational function",
        [IsRat, IsUnivariateRationalFunction],
        function(r,f)
    if ForAny(CoefficientsOfUnivariateRationalFunction(f)[1],IS_COMPLEX) then
        return Complex(r)*f;
    fi;
    TryNextMethod();
end);
        
InstallMethod(PROD, "(FR) for a rational and a complex rational function",
        [IsUnivariateRationalFunction, IsRat],
        function(f,r)
    if ForAny(CoefficientsOfUnivariateRationalFunction(f)[1],IS_COMPLEX) then
        return f*Complex(r);
    fi;
    TryNextMethod();
end);
        
InstallOtherMethod(ComplexConjugate, "(FR) for a univariate rational function",
        [IsUnivariateRationalFunction],
        function(f)
    local c;
    c := CoefficientsOfUnivariateRationalFunction(f);
    return UnivariateRationalFunctionByCoefficients(FamilyObj(c[1][1]),List(c[1],ComplexConjugate),List(c[2],ComplexConjugate),c[3],IndeterminateNumberOfUnivariateRationalFunction(f));
end);
#############################################################################

InstallValue(P1infinity, Objectify(TYPE_P1POINT,[infinity]));

InstallGlobalFunction(P1Point, function(arg)
    if arg[1]=infinity then
        return P1infinity;
    else
        return Objectify(TYPE_P1POINT,[CallFuncList(Complex,arg)]);
    fi;
end);

InstallOtherMethod(EQ, IsIdenticalObj, [IsP1Point, IsP1Point],
        function(x,y)
    return x![1]=y![1];
end);

InstallMethod(LT, "for points on P1",
        [IsP1Point,IsP1Point],
        function(x,y)
    x := x![1]; y := y![1];
    if x=infinity then return false; fi;
    return y=infinity or (y<>infinity and x<y);
end);

InstallMethod(PrintObj, [IsP1Point], function(x) Print(x![1]); end);

InstallMethod(Value, "for a rational function and a point on P1",
        [IsRationalFunction,IsP1Point],
        function(rat,p)
    local n, d, i, j;
    n := NumeratorOfRationalFunction(rat);
    d := DenominatorOfRationalFunction(rat);
    if p=P1infinity then
        i := DegreeOfUnivariateLaurentPolynomial(n);
        j := DegreeOfUnivariateLaurentPolynomial(d);
        if i<j then
            return P1Point(0);
        elif i>j then
            return P1infinity;
        else
            return P1Point(CoefficientsOfUnivariatePolynomial(n)[i+1]/CoefficientsOfUnivariatePolynomial(d)[j+1]);
        fi;
    else
        n := Value(n,p![1]);
        d := Value(d,p![1]);
        if IsZero(d) then
            return P1infinity;
        else
            return P1Point(n/d);
        fi;
    fi;
end);

InstallOtherMethod(POW, "for point and matrix",
        [IsP1Point, IsMatrix],
        function(p,M)
    local n, d; # matrix M is transposed of usual one:
    # [[a,b],[c,d]] means (az+c)/(bz+d)
    if p=P1infinity then
        if IsZero(M[1][2]) then
            return P1infinity;
        else
            return P1Point(M[1][1]/M[1][2]);
        fi;
    else
        n := M[1][1]*p![1]+M[2][1];
        d := M[1][2]*p![1]+M[2][2];
        if IsZero(d) then
            return P1infinity;
        else
            return P1Point(n/d);
        fi;
    fi;
end);

InstallMethod(P1Map, "(FR) for images of 0,infinity",
        [IsP1Point,IsP1Point],
        function(a,b)
    # map 0 to a, infinity to b

    a := a![1]; b := b![1];

    if a=infinity then
        return [[b,COMPLEX_1],[COMPLEX_1,COMPLEX_0]];
    elif b=infinity then
        return [[COMPLEX_1,a],[COMPLEX_0,COMPLEX_1]];
    else
        return [[b,a],[COMPLEX_1,COMPLEX_1]];
    fi;
end);

InstallMethod(P1Map, "(FR) for images of 0,1,infinity",
        [IsP1Point,IsP1Point,IsP1Point],
        function(a,b,c)
    # map 0 to a, 1 to b, infinity to c

    a := a![1]; b := b![1]; c := c![1];

    if a=infinity then
        return [[c,b-c],[COMPLEX_1,COMPLEX_0]];
    elif b=infinity then
        return [[c,-a],[COMPLEX_1,-COMPLEX_1]];
    elif c=infinity then
        return [[b-a,a],[COMPLEX_0,COMPLEX_1]];
    else
        return [[c*(b-a),a*(c-b)],[b-a,c-b]];
    fi;
end);

InstallMethod(P1Map, "(FR) for 3 points and their 3 images",
        [IsP1Point,IsP1Point,IsP1Point,IsP1Point,IsP1Point,IsP1Point],
        function(a,b,c,A,B,C)
    # map a to A, b to B, c to C
    return P1Map(A,B,C)/P1Map(a,b,c);
end);

InstallMethod(SphereP1, [IsP1Point],
        function(p)
    local n;
    if p=P1infinity then
        return [MACFLOAT_0,MACFLOAT_0,-MACFLOAT_1];
    else
        n := Norm(p![1]);
        return [2*RealPart(p![1]),2*ImaginaryPart(p![1]),MACFLOAT_1-n]/(MACFLOAT_1+n);
    fi;
end);

BindGlobal("C2SPHERE@", function(p)
    # return a point [v1:v2] in homogeneous coordinates mapping to p
    if p[3]>MACFLOAT_0 then
        return [Complex(p[1],p[2]),Complex(MACFLOAT_1+p[3])];
    else
        return [Complex(MACFLOAT_1-p[3]),Complex(p[1],-p[2])];
    fi;
end);

InstallMethod(P1Sphere, [IsList],
        function(v)
    local n;
    n := C2SPHERE@(v);
    if n[2]=COMPLEX_0 then return P1infinity; else return P1Point(n[1]/n[2]); fi;
end);

InstallMethod(SphereProject, [IsList], v->v/Sqrt(v^2));

InstallMethod(P1Distance, [IsP1Point,IsP1Point],
        function(p,q)
    return Sqrt((SphereP1(p)-SphereP1(q))^2)/2;
end);

InstallMethod(P1PreImages, [IsRationalFunction,IsP1Point],
        function(rat,p)
    local v, n, d;
    n := NumeratorOfRationalFunction(rat);
    d := DenominatorOfRationalFunction(rat);
    if p![1]=infinity then
        v := ComplexRootsOfUnivariatePolynomial(d);
    else
        v := ComplexRootsOfUnivariatePolynomial(n-p![1]*d);
    fi;
    while Length(v)<DegreeOfRationalFunction(rat) do
        Add(v,infinity);
    od;
    return List(v,P1Point);
end);

BindGlobal("SPHEREINVF@", f->(x->List(P1PreImages(f,P1Sphere(x)),SphereP1)));

InstallMethod(XProduct, [IsList, IsList],
        function(v,w)
    return [v[2]*w[3]-v[3]*w[2],v[3]*w[1]-v[1]*w[3],v[1]*w[2]-v[2]*w[1]];
end);

InstallMethod(TripleProduct, [IsList, IsList, IsList],
        function(u,v,w)
    return u[1]*v[2]*w[3]-u[1]*v[3]*w[2]+u[2]*v[3]*w[1]-u[2]*v[1]*w[3]+u[3]*v[1]*w[2]-u[3]*v[2]*w[1];
#    return Determinant([u,v,w]);
end);

InstallMethod(SphereXProduct, [IsList, IsList],
        function(v,w)
    return SphereProject(XProduct(v,w));
end);

InstallMethod(DegreeOfRationalFunction, "(FR) for a rational function",
        [IsRationalFunction],
        f->Maximum(DegreeOfUnivariateLaurentPolynomial(
                NumeratorOfRationalFunction(f)),
                DegreeOfUnivariateLaurentPolynomial(
                        DenominatorOfRationalFunction(f))));

InstallMethod(Primitive, "(FR) for a univariate polynomial",
        [IsUnivariateRationalFunction and IsLaurentPolynomial],
        function(f)
    local d, i, c;

    d := CoefficientsOfLaurentPolynomial(f);
    if IsEmpty(d[1]) then # easy case: primitive of 0-Polynomial
        return f;
    fi;
    c := [];
    for i in [1..Length(d[1])]  do
        if i=-d[2] then
            if not IsZero(d[1][i]) then TryNextMethod(); fi; # has log(x) term
            c[i] := d[1][i];
        else
            c[i] := d[1][i]/(i+d[2]);
        fi;
    od;
    return LaurentPolynomialByCoefficients(CoefficientsFamily(FamilyObj(f)),c,
                   d[2]+1,IndeterminateNumberOfUnivariateRationalFunction(f));

end);
#############################################################################

#############################################################################
##
#H Find incompressible elements
##
## <#GAPDoc Label="">
## <ManSection>
##   <Func Name="" Arg=""/>
##   <Returns>.</Returns>
##   <Description>
##   </Description>
## </ManSection>
## <#/GAPDoc>
##
if false then
G := BinaryKneadingGroup(1/6);
S := [G.1,G.2,G.3];
pi := DecompositionOfFRElement(G);

EasyReduce := function(x)
  local e, i, verygeod, geod;
  e := ShallowCopy(ExtRepOfObj(x));
  verygeod := true;
  geod := true;
  for i in [2,4..Length(e)] do
    if e[i]=-1 then e[i] := 1; fi;
    if e[i] >= 2 or e[i] <= -2 then
      e[i] := RemInt(RemInt(e[i],2)+2,2);
      verygeod := false;
      if e[i-1] >= 2 then geod := false; fi;
    fi;
  od;
  return [ObjByExtRep(FamilyObj(x),e),geod,verygeod];
end;

MakeIncompressible := function(n)
  local inc, ginc, i;

  inc := [[One(G)],[G.1,G.2,G.3],Difference(Ball(G,2),Ball(G,1))];
  ginc := Ball(G,2);

  for i in [3..n] do
    inc[i+1] := Filtered(List(Cartesian(inc[i],[G.1,G.2,G.3]),p->p[1]*p[2]),function(g)
      local x;
      x := pi(g);
      return EasyReduce(g)[3] and x[1][1] in ginc and x[1][2] in ginc and EasyReduce(x[1][1])[2] and EasyReduce(x[1][2])[2];
    end);
    Append(ginc,inc[i+1]);
  od;
  return ginc;
end;

#############################################################################
##
#H Unused complex methods
##
InstallMethod(P1MidPoint, [IsP1Point, IsP1Point],
        function(a,b)
    local c;
    c := SphereP1(a)+SphereP1(b);
    return P1Sphere(SphereProject(c));
end);

InstallMethod(SphereIntersection, [IsList, IsList, IsList, IsList],
        function(a1,b1,a2,b2)
    # intersection number of segment a1-b1 with segment a2-b2
    # returns 0 if no intersection;
    # +-1 if a1b1 intersects a2b2 in positive/negative direction;
    # +-1/2 if b1 touches a2b2 arriving in positive/negative direction.
    local x1, x2;
    if a1*a2<MACFLOAT_0 then return 0; fi;
    x1 := TripleProduct(a1,b1,a2);
    x2 := TripleProduct(a1,b1,b2);
    if x1*x2>=MACFLOAT_0 then return 0; fi;
    x1 := TripleProduct(a2,b2,a1);
    x2 := TripleProduct(a2,b2,b1);
    if x1*x2<MACFLOAT_0 then
        if x1>0 then return 1; else return -1; fi;
    elif x2=MACFLOAT_0 then
        if x1>0 then return 1/2; else return -1/2; fi;
    else
        return 0;
    fi;
end);

InstallMethod(P1Angle, [IsP1Point, IsP1Point, IsP1Point],
        function(base,a,b)
    local angle;
    base := SphereP1(base);
    a := XProduct(base,SphereP1(a));
    b := XProduct(base,SphereP1(b));
    angle := (a*b)/Sqrt(a^2*b^2);
    if angle > 1 then
        return MACFLOAT_0;
    elif angle < -1 then
        return MACFLOAT_PI;
    else
        angle := ACOS_MACFLOAT((a*b)/Sqrt(a^2*b^2));
        if TripleProduct(base,a,b)<0 then
            angle := 2*MACFLOAT_PI-angle;
        fi;
    fi;
    return angle;
end);
fi;
#############################################################################

#############################################################################
##
#F WreathProductPc
##
InstallOtherMethod( WreathProduct,
[IsPcGroup, IsPcGroup],
        function( G, H )
    return WreathProduct( G, H, RegularActionHomomorphism(H), Size(H));
end);

InstallOtherMethod( WreathProduct, true,
[IsPcGroup, IsPcGroup, IsMapping], 0,
        function( G, H, act )
    return WreathProduct( G, H, act,
                   Maximum( 1, LargestMovedPoint( Image( act ))));
end);

InstallOtherMethod( WreathProduct, true,
        [IsPcGroup, IsPcGroup, IsMapping, IsPosInt], 0,
function( G, H, act, l )
    local pcgsG, pcgsH, isoG, isoH, gensG, gensH, gensFG, gensFH, rels, W,
          i, j, k, m, n, a, b, F;

    pcgsG := Pcgs(G);
    pcgsH := Pcgs(H);
    n := Length( pcgsG );
    m := Length( pcgsH );

    F := FreeGroup(IsSyllableWordsFamily, m + n*l);
    rels := [];
    isoG := IsomorphismFpGroupByPcgs(pcgsG, "G");
    isoH := IsomorphismFpGroupByPcgs(pcgsH, "H");
    gensG := GeneratorsOfGroup(FreeGroupOfFpGroup(Range(isoG)));
    gensH := GeneratorsOfGroup(FreeGroupOfFpGroup(Range(isoH)));
    gensFG := List([1..l],i->GeneratorsOfGroup(F){m+(i-1)*n+[1..n]});
    gensFH := GeneratorsOfGroup(F){[1..m]};
    rels := List(RelatorsOfFpGroup(Range(isoH)),
                 w->MappedWord(w,gensH,gensFH));
    for i in [1..l] do
        Append(rels,List(RelatorsOfFpGroup(Range(isoG)),
                w->MappedWord(w,gensG,gensFG[i])));
    od;
    for i in [1..l] do
        for j in [i+1..l] do
            for a in gensFG[i] do
                for b in gensFG[j] do
                    Add(rels,Comm(a,b));
                od;
            od;
        od;
    od;
    for i in [1..l] do
        for a in [1..Length(pcgsH)] do
            b := pcgsH[a]^act;
            for j in [1..Length(gensFG[i])] do
                Add(rels,gensFG[i][j]^gensFH[a]/gensFG[i^b][j]);
            od;
        od;
    od;
    W := PcGroupFpGroup(F/rels);

    SetWreathProductInfo( W, rec(l := l, m := m, n := n,
        G := G, pcgsG := pcgsG, genG := GeneratorsOfGroup(G),
        H := H, pcgsH := pcgsH, genH := GeneratorsOfGroup(H),
        pcgsW := Pcgs(W),
        embeddings := []) );
    return W;
end );

InstallMethod(Embedding,"pc wreath product",
        [IsPcGroup and HasWreathProductInfo, IsPosInt],
        function(W,i)
    local info, FilledIn;

    FilledIn := function( exp, shift, len )
        local s;
        s := List([1..len], i->0);
        s{shift+[1..Length(exp)]} := exp;
        return s;
    end;

    info := WreathProductInfo(W);
    if not IsBound(info.embeddings[i]) then
        if i<=info.l then
            info.embeddings[i] := GroupHomomorphismByImagesNC(info.G,W,
                info.genG, List(info.genG, x->PcElementByExponents(info.pcgsW,
                    FilledIn(ExponentsOfPcElement(info.pcgsG,x),info.m+(i-1)*info.n,info.m+info.l*info.n))));
        elif i=info.l+1 then
            info.embeddings[i] := GroupHomomorphismByImagesNC(info.H,W,
                info.genH, List(info.genH, x->PcElementByExponents(info.pcgsW,
                    FilledIn(ExponentsOfPcElement(info.pcgsH,x),0,info.m+info.l*info.n))));
        else
            return fail;
        fi;
        SetIsInjective(info.embeddings[i],true);
    fi;
    return info.embeddings[i];
end);
#############################################################################

#############################################################################
##
#F JenningsLieAlgebra
##
BindGlobal("LIEELEMENT@", function(A,l)
    return Objectify(A!.type,[A,l]);
end);

LIEEXTENDLCS@ := fail; # shut up warning

BindGlobal("LIECOMPUTEBASIS@", function(A,d)
    local i, l;

    if IsBound(A!.basis[d]) then return; fi;

    LIEEXTENDLCS@(A,d);
    A!.hom[d] := NaturalHomomorphismByNormalSubgroup(A!.lcs[d],A!.lcs[d+1]);
    A!.basis[d] := [];
    for i in IdentityMat(Length(AbelianInvariants(Range(A!.hom[d]))),A!.ring) do
        l := []; l[d] := i;
        Add(A!.basis[d],LIEELEMENT@(A,l));
    od;
    A!.transversal[d] := List(A!.pcp(Range(A!.hom[d])),
                              x->PreImagesRepresentative(A!.hom[d],x));
end);

BindGlobal("JENNINGSSERIES@", function(G,p,d)
    local n, L, C, T;

    L := [G];
    for n in [2..d] do
        C := CommutatorSubgroup(G,L[n-1]);
        if p=0 then
            T := NaturalHomomorphismByNormalSubgroup(L[n-1],C);
            L[n] := PreImage(T,TorsionSubgroup(Range(T)));
        else
            L[n] := ClosureGroup(C,List(GeneratorsOfGroup(L[QuoInt(n+p-1,p)]), x->x^p));
        fi;
    od;
    return L;
end);

if not IsBound(PqEpimorphism) then PqEpimorphism := ReturnFail; fi;
#!!! a hack; should exist in nql

UnbindGlobal("LIEEXTENDLCS@");
BindGlobal("LIEEXTENDLCS@", function(A,d)
    local i;

    if d<=A!.degree then return; fi;

    if IsLpGroup(A!.group) then
        A!.quo := NqEpimorphismNilpotentQuotient(A!.group,d);
        A!.pcp := Pcp;
        A!.exp := ExponentsByPcp;
    elif IsFpGroup(A!.group) and Characteristic(A!.ring)=0 then
        A!.quo := EpimorphismNilpotentQuotient(A!.group,d);
        A!.pcp := Pcp;
        A!.exp := ExponentsByPcp;
    else
        A!.quo := PqEpimorphism(A!.group : ClassBound := d, Prime := Characteristic(A!.ring));
        A!.pcp := Pcgs;
        A!.exp := ExponentsOfPcElement;
    fi;
    A!.lcs := JENNINGSSERIES@(Range(A!.quo),Characteristic(A!.ring),d+1);
    A!.degree := d;
    for i in BoundPositions(A!.basis) do
        Unbind(A!.basis[i]);
        LIECOMPUTEBASIS@(A,i);
    od;
end);

if PqEpimorphism=ReturnFail then Unbind(PqEpimorphism); fi;

InstallOtherMethod(JenningsLieAlgebra, "(FR) for a ring and an FP group",
        [IsRing,IsGroup],
        function(R,G)
    local C, A;

    C := NewFamily("LieFpElementsFamily",IsLieFpElementRep);
    A := Objectify(NewType(CollectionsFamily(C),
                 IsFpLieAlgebra and IsAttributeStoringRep),
                 rec(group := G,
                     family := C,
                     ring := R,
                     degree := 0,
                     lcs := [],
                     bracket := [],
                     pmap := [],
                     hom := [],
                     transversal := [],
                     basis := []));
    A!.type := NewType(A!.family,IsLieObject and IsLieFpElementRep);
    Grading(A);
    SetRepresentative(A,LIEELEMENT@(A,[]));
    SetLeftActingDomain(A,R);
    SetZero(C,Representative(A));
    return A;
end);

InstallMethod(GeneratorsOfAlgebra, "(FR) for an FP Lie algebra",
        [IsFpLieAlgebra],
        function(A)
    LIECOMPUTEBASIS@(A,1);
    return List(GeneratorsOfGroup(A!.group),x->LIEELEMENT@(A,[One(A!.ring)*A!.exp(A!.pcp(Range(A!.hom[1])),(x^A!.quo)^A!.hom[1])]));
end);

InstallMethod(Grading, "(FR) for a FP Lie algebra",
        [IsFpLieAlgebra],
        function(A)
    return rec(min_degree := 1, source := Integers, hom_components := function(d)
        LIECOMPUTEBASIS@(A,d);
        return VectorSpace(A!.ring,A!.basis[d],Representative(A));
    end);
end);

InstallMethod(ViewObj, "(FR) for a FP Lie algebra",
        [IsFpLieAlgebra],
        function(A)
    Print("<FP Lie algebra over ",A!.ring);
    if A!.degree>0 then
        if IsTrivial(A!.lcs[A!.degree]) then
            Print(", of");
        else
            Print(", computed up to");
        fi;
        Print(" degree ",A!.degree);
    fi;
    Print(">");
end);

InstallOtherMethod(ZeroOp, "(FR) for a FP Lie algebra",
        [IsFpLieAlgebra],
        function(A)
    return Representative(A);
end);

InstallMethod(ZeroOp, "(FR) for a FP Lie algebra element",
        [IsLieObject and IsLieFpElementRep],
        function(X)
    return LIEELEMENT@(X![1],[]);
end);

InstallMethod(EQ, "(FR) for FP Lie algebra elements",
        IsIdenticalObj,
        [IsLieObject and IsLieFpElementRep,IsLieObject and IsLieFpElementRep],
        function(X,Y)
    local n;
    for n in Union(BoundPositions(X![2]),BoundPositions(Y![2])) do
        if not IsBound(X![2][n]) and not ForAll(Y![2][n],IsZero) then
            return false;
        fi;
        if not IsBound(Y![2][n]) and not ForAll(X![2][n],IsZero) then
            return false;
        fi;
        if X![2][n]<>Y![2][n] then
            return false;
        fi;
    od;
    return true;
end);

InstallMethod(LT, "(FR) for FP Lie algebra elements",
        IsIdenticalObj,
        [IsLieObject and IsLieFpElementRep,IsLieObject and IsLieFpElementRep],
        function(X,Y)
    local n;
    for n in Union(BoundPositions(X![2]),BoundPositions(Y![2])) do
        if not IsBound(X![2][n]) and not ForAll(Y![2][n],IsZero) then
            return Y![2][n]>0;
        fi;
        if not IsBound(Y![2][n]) and not ForAll(X![2][n],IsZero) then
            return X![2][n]<0;
        fi;
        if X![2][n]<>Y![2][n] then
            return X![2][n]<Y![2][n];
        fi;
    od;
    return false;
end);

InstallMethod(SUM, "(FR) for FP Lie algebra elements",
        IsIdenticalObj,
        [IsLieObject and IsLieFpElementRep,IsLieObject and IsLieFpElementRep],
        function(X,Y)
    local m, n;
    m := [];
    for n in Union(BoundPositions(X![2]),BoundPositions(Y![2])) do
        if not IsBound(X![2][n]) then
            m[n] := Y![2][n];
        elif not IsBound(Y![2][n]) then
            m[n] := X![2][n];
        else
            m[n] := X![2][n]+Y![2][n];
        fi;
    od;
    return LIEELEMENT@(X![1],m);
end);

InstallMethod(DIFF, "(FR) for FP Lie algebra elements",
        IsIdenticalObj,
        [IsLieObject and IsLieFpElementRep,IsLieObject and IsLieFpElementRep],
        function(X,Y)
    local m, n;
    m := [];
    for n in Union(BoundPositions(X![2]),BoundPositions(Y![2])) do
        if not IsBound(X![2][n]) then
            m[n] := -Y![2][n];
        elif not IsBound(Y![2][n]) then
            m[n] := X![2][n];
        else
            m[n] := X![2][n]-Y![2][n];
        fi;
    od;
    return LIEELEMENT@(X![1],m);
end);

InstallMethod(AINV, "(FR) for an FP Lie algebra element",
        [IsLieObject and IsLieFpElementRep],
        function(X)
    local m, n;
    m := [];
    for n in BoundPositions(X![2]) do
        m[n] := -X![2][n];
    od;
    return LIEELEMENT@(X![1],m);
end);

InstallMethod(PROD, "(FR) for FP Lie algebra elements",
        IsIdenticalObj,
        [IsLieObject and IsLieFpElementRep,IsLieObject and IsLieFpElementRep],
        function(X,Y)
    local i, j, ii, jj, m, A;
    m := [];
    A := X![1];
    for i in BoundPositions(X![2]) do
        if not IsBound(A!.bracket[i]) then A!.bracket[i] := []; fi;
        for j in BoundPositions(Y![2]) do
            if not IsBound(A!.bracket[i][j]) then A!.bracket[i][j] := []; fi;
            LIECOMPUTEBASIS@(A,i+j);
            if not IsBound(m[i+j]) then
                m[i+j] := List(A!.basis[i+j],i->Zero(A!.ring));
            fi;
            for ii in [1..Length(A!.basis[i])] do
                if not IsBound(A!.bracket[i][j][ii]) then
                    A!.bracket[i][j][ii] := [];
                fi;
                for jj in [1..Length(A!.basis[j])] do
                    if not IsBound(A!.bracket[i][j][ii][jj]) then
                        A!.bracket[i][j][ii][jj] := A!.exp(A!.pcp(Range(A!.hom[i+j])),Comm(A!.transversal[i][ii],A!.transversal[j][jj])^A!.hom[i+j]);
                    fi;
                    m[i+j] := m[i+j] + X![2][i][ii]*Y![2][j][jj]*A!.bracket[i][j][ii][jj];
                od;
            od;
        od;
    od;
    for i in BoundPositions(m) do
        if ForAll(m[i],IsZero) then Unbind(m[i]); fi;
    od;
    return LIEELEMENT@(X![1],m);
end);

InstallMethod(PROD, "(FR) for a scalar and an FP Lie algebra element",
        [IsScalar,IsLieObject and IsLieFpElementRep],
        function(X,Y)
    return LIEELEMENT@(Y![1],X*Y![2]);
end);

InstallMethod(PROD, "(FR) for an FP Lie algebra element and a scalar",
        [IsLieObject and IsLieFpElementRep,IsScalar],
        function(X,Y)
    return LIEELEMENT@(X![1],X![2]*Y);
end);

BindGlobal("PTHPOWER@", function(X,A,p,s)
    local m, i, ii, j, t;
    m := [];
    for i in BoundPositions(X![2]) do
        LIECOMPUTEBASIS@(A,p*i);
        if not IsBound(m[p*i]) then
            m[p*i] := List(A!.basis[p*i],i->Zero(A!.ring));
        fi;
        if not IsBound(A!.pmap[i]) then A!.pmap[i] := []; fi;
        for ii in [1..Length(A!.basis[i])] do
            if not IsBound(A!.pmap[i][ii]) then
                A!.pmap[i][ii] := A!.exp(A!.pcp(Range(A!.hom[p*i])),(A!.transversal[i][ii]^p)^A!.hom[p*i]);
            fi;
            m[p*i] := m[p*i] + X![2][i][ii]^p*A!.pmap[i][ii];
        od;
    od;
    m := LIEELEMENT@(X![1],m);
    for i in BoundPositions(X![2]) do
        for ii in [1..Length(A!.basis[i])] do
            if IsBound(X![2][i]) and not IsZero(X![2][i][ii]) then
                t := X![2][i][ii]*A!.basis[i][ii];
                X := X - t;
                for j in [1..p-1] do m := m + s[j]([t,X]); od;
            fi;
        od;
    od;
    return m;
end);

InstallMethod(POW, "(FR) for an FR Lie algebra element and a p-power",
        [IsLieObject and IsLieFpElementRep,IsPosInt],
        function(X,Y)
    local p, n;
    p := Characteristic(X![1]!.ring);
    if p=0 or p^LogInt(Y,p)<>p then
        Error(Y," must be a power of the characteristic");
    fi;
    for n in [1..LogInt(Y,p)] do
        X := PTHPOWER@(X,X![1],p,PowerS(X![1]));
    od;
    return X;
end);

InstallMethod(Degree, "(FR) for a FR Lie algebra element",
        [IsLieObject and IsLieFpElementRep],
         function(X)
    local n;
    for n in [1..Length(X![2])] do
        if IsBound(X![2][n]) and not ForAll(X![2][n],IsZero) then return n; fi;
    od;
    return infinity;
end);

InstallMethod(ViewObj, "(FR) for a FP Lie algebra element",
        [IsLieObject and IsLieFpElementRep],
        function(X)
    local n;
    Print("<");
    n := Degree(X);
    if n=infinity then
        Print("zero");
    else
        if ForAll([n+1..Length(X![2])],i->not IsBound(X![2][i]) or ForAll(X![2][i],IsZero)) then
            Print("homogeneous ");
        fi;
        Print("degree-",n);
    fi;
    Print(" Lie element>");
end);

BindGlobal("LIE2VECTOR@", function(dims,dim,x)
    local i, v;
    v := List([1..dim],i->Zero(x![1]!.ring));
    for i in BoundPositions(x![2]) do
        if not IsBound(dims[i]) then
            if not ForAll(x![2][i],IsZero) then
                return fail;
            fi;
        else
            v{dims[i]} := x![2][i];
        fi;
    od;
    ConvertToVectorRep(v);
    MakeImmutable(v);
    return v;
end);

InstallHandlingByNiceBasis("IsLieFpElementSpace", rec(
        detect := function(R,l,V,z)
    if IsEmpty(l) then
        return IsLieObject(z) and IsLieFpElementRep(z) and z![1]!.ring=R;
    else
        return ForAll(l,x->IsLieObject(x) and IsLieFpElementRep(x) and x![1]!.ring=R);
    fi;
end,
  NiceFreeLeftModuleInfo := function(V)
    local b, dim, dims, i, j, k, R;
    b := GeneratorsOfLeftModule(V);
    R := Zero(V)![1];
    dim := 0;
    dims := [];
    for i in b do
        for j in BoundPositions(i![2]) do
            if ForAll(i![2][j],IsZero) then continue; fi;
            dims[j] := true;
        od;
    od;
    for i in BoundPositions(dims) do
        dims[i] := [dim+1..dim+Length(R!.basis[i])];
        dim := dim+Length(R!.basis[i]);
    od;
    b := List(b,x->LIE2VECTOR@(dims,dim,x));
    return rec(dims := dims,
               dim := dim,
               ring := R,
               space := VectorSpace(LeftActingDomain(V),b,LIE2VECTOR@(dims,dim,Zero(V))));
end,
  NiceVector := function(V,v)
    local info, x;
    info := NiceFreeLeftModuleInfo(V);
    x := LIE2VECTOR@(info.dims,info.dim,v);
    if x=fail or not x in info.space then
        return fail;
    else
        return x;
    fi;
end,
  UglyVector := function(V,v)
    local info, i, l;
    info := NiceFreeLeftModuleInfo(V);
    if not v in info.space then return fail; fi;
    l := [];
    for i in BoundPositions(info.dims) do
        l[i] := v{info.dims[i]};
    od;
    return LIEELEMENT@(info.ring,l);
end));
#############################################################################

#E helpers.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
