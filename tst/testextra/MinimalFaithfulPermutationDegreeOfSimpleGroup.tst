gap> START_TEST("MinimalFaithfulPermutationDegreeOfSimpleGroupWithIsomorphismType.tst");
gap> Clean := function(INFO)
>     local SporNames,SeriesNames,info,name,q,size;
>     info := ShallowCopy(INFO);
>     SporNames := [
>         ["M11","M(11)"],
>         ["M12","M(12)"],
>         ["M22","M(22)"],
>         ["M23","M(23)"],
>         ["M24","M(24)"],
>         ["J1","J(1)"],
>         ["J2","J(2)"],
>         ["J3","J(3)"],
>         ["Co2","Co(2)"],
>         ["Co3","Co(3)"],
>         ["Fi22","Fi(22)"],
>     ];
>     SeriesNames := [
>         ["U","2A"],
>         ["S","C"],
>         ["Sz","2B"],
>         ["O+","D"],
>         ["O-","2D"],
>         ["O","B"],
>     ];
>     if IsString(info[3]) then
>         for name in SporNames do
>             if name[2] = info[3] then
>                 info[3] := name[1];
>             fi;
>         od;
>         if info[3] = "T" then
>             info[2] := "2F";
>             info[3] := 2;
>             info[4] := 0;
>         fi;
>     else
>         for name in SeriesNames do
>             if name[1] = info[2] then
>                 info[2] := name[2];
>             fi;
>             if INFO[2] = "U" then info[3] := INFO[3] -1;fi;
>             if INFO[2] in ["S","O+","O-"] then info[3] := INFO[3]/2; fi;
>             if INFO[2] = "O" then info[3] := (INFO[3] -1)/2; fi;
>             if not IsInt(info[3]) then Error("wierd .. ",INFO,"\n"); fi;
>             if info[2] = "R" then
>                 q := info[3];
>                 size := info[1];
>                 if size = q^3 * (q^3 + 1) * (q-1) and PrimeDivisors(q) = [3] then
>                     info[2] := "2G";
>                 elif size = q^12 * (q^6 + 1) * (q^4 -1) * (q^3+1) * (q-1)
>                     and PrimeDivisors(q) = [2] then
>                     info[2] := "2F";
>                 else
>                     Error("Couldn't identify");
>                 fi;
>             fi;
>         od;
>     fi;
>     return info;
> end;
function( INFO ) ... end
gap> MakeRecord := function(INFO)
>     local info,parameter,series,shortname;
>     if IsString(INFO[3]) then
>         return rec(
>             series := "Spor",
>             parameter := INFO[4],
>             shortname := INFO[3],
>         );
>     fi;
>     if INFO[4] = 0 then
>         parameter := INFO[3];
>     else
>         parameter := [INFO[3],INFO[4]];
>     fi;
>     return rec(
>         series := INFO[2],
>         parameter := parameter,
>     );
> end;
function( INFO ) ... end
gap> LightChecknonabelianSimple := function(perfectTill)
>     local size,series,INFO,G,mu,mu2,mu3,info;
>     for INFO in SIMPLEGPSNONL2 do
>         if LENGTH(INFO) <> 5 then continue; fi;
>         size := INFO[1];
>         series := INFO[2];
>         mu := Last(INFO);
>         info := MakeRecord(Clean(INFO));
>         mu2 := MinimalFaithfulPermutationDegreeOfSimpleGroupWithIsomorphismType(info);
>         if mu < mu2 then
>             return Concatenation("failed on",String(INFO),". From table :",String(mu),", Computed :",String(mu2),"\n");
>         elif size <= perfectTill and mu>mu2 then
>             if IsString(INFO[3]) then
>                 G := SimpleGroup(INFO[3]);
>             elif INFO[4] = 0 then
>                 G := SimpleGroup(INFO[2],INFO[3]);
>             else
>                 G := SimpleGroup(INFO[2],INFO[3],INFO[4]);
>             fi;
>             mu3 := DoMinimalFaithfulPermutationDegree(G,false);
>             if mu2 <> mu3 then
>                 return Concatenation("failed on",String(INFO),". From MinimalFaithfulPermutationDegree :",String(mu3),", Computed :",String(mu2),"\n");
>             fi;
>         fi;
>     od;
>     return "PASS";
> end;
function( perfectTill ) ... end
gap> LightChecknonabelianSimple(10^6);
"PASS"
gap> STOP_TEST( "MinimalFaithfulPermutationDegreeOfSimpleGroup.tst", 1);