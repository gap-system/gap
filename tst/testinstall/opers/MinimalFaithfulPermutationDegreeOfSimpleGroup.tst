gap> START_TEST("MinimalFaithfulPermutationDegreeOfSimpleGroup.tst");
gap> checksimple := function(maxsize)
>     local i,mu,mu2,info,G;
>     i := 1;
>     for G in SimpleGroupsIterator(1,maxsize) do
>         mu := DoMinimalFaithfulPermutationDegree(G,false);
>         mu2 := MinimalFaithfulPermutationDegreeOfSimpleGroup(G);
>         if mu2 <> mu then
>             info := IsomorphismTypeInfoFiniteSimpleGroup(G);
>             return Concatenation("Failed on simple group ",String(i)," i.e. ",info.name,"\n");
>         fi;
>         i := i + 1;
>     od;
>     return "Passed";
> end;
function( maxsize ) ... end
gap> checksimple(50000); # first 26 simple groups
"Passed"
gap> LightChecknonabelianSimple := function(maxsize)
>     local size,series,info,G,mu,mu2,mu3;
>     for info in SIMPLEGPSNONL2 do
>         size := info[1];
>         if size > maxsize then break; fi;
>         series := info[2];
>         mu := Last(info);
>         if IsString(info[3]) then #Spor
>             G := SimpleGroup(info[3]);
>         elif Length(info) = 5 then
>             if info[4] = 0 then
>                 G := SimpleGroup(series,info[3]);
>             else
>                 G := SimpleGroup(series,info[3],info[4]);
>             fi;
>         else
>             Print(info,"\n");
>             continue;
>         fi;
>         mu2 := MinimalFaithfulPermutationDegreeOfSimpleGroup(G);
>         if mu < mu2 then
>             return Concatenation("failed on",String(info),". From table :",String(mu),", Computed :",String(mu2),"\n");
>         elif mu > mu2 then
>             mu3 := DoMinimalFaithfulPermutationDegree(G,false);
>             if mu2 <> mu3 then
>                 return Concatenation("failed on",String(info),". From MinimalFaithfulPermutationDegree :",String(mu3),", Computed :",String(mu2),"\n");
>             fi;
>         fi;
>     od;
>     return "PASS";
> end;
function( maxsize ) ... end
gap> LightChecknonabelianSimple(1000000); # First 19 non abelian simple groups
"PASS"