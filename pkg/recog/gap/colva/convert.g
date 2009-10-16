//Takes a magma type permutation group, writes it as a list
//of generators in GAP readable form

MakeGapFormat:= procedure(grp)
  printf "[";
  for i in [1..Ngens(grp)-1] do
    printf "%o,", grp.i; 
  end for;
  printf "%o]", grp.Ngens(grp);
end procedure;

//takes a magma primitive group of affine type, writes the matrix
//quotient as a list of generators in GAP readable form.

MakeMatGapFormat:= procedure(mat_grp)
  if Ngens(mat_grp) eq 0 then
    printf "[]";
  else
    p:= #BaseRing(mat_grp.1);

    //this assertion is safe since getting these from groups of 
    //affine type.
    assert IsPrime(p);

    d:= Dimension(mat_grp);

    for i in [1..Ngens(mat_grp)] do
      x:= mat_grp.i;
      for j in [1..d] do
        if i eq 1 and j eq 1 then
          printf "[ [[";
        elif j eq 1 then
          printf "[[";
        else
          printf "[";
        end if;  
        for k in [1..d-1] do
          printf "%o*Z(%o )^0,", x[j][k], p;
        end for;
        if j lt d then
          printf "%o*Z(%o)^0],", x[j][d], p;
        else
          printf "%o*Z(%o)^0]]", x[j][d], p;
        end if;
      end for;
      if i lt Ngens(mat_grp) then
        " ,\n ";
      end if;
    end for;
    "]\n";
  end if;
end procedure;


sub_lengths:= function(g)
  orbits:= Orbits(Stabiliser(g, 1));
  assert #orbits[1] eq 1;
  Exclude(~orbits, orbits[1]);
  lengths:= [#x : x in orbits];
  Sort(~lengths);
  dif_lengths:= Seqset(lengths);
  new_lengths:=[];
  for x in dif_lengths do
    i:= 0;
    for j in [1..#lengths] do
      if lengths[j] eq x then
        i:= i+1;
      end if;
    end for;
    Append(~new_lengths, [x, i]);
  end for;
  return new_lengths;
end function;

get_ons:= function(g, ons, i)
   if ons eq "Affine" then 
      id:= "1";
    elif ons eq "AlmostSimple" then
      id:= "2";
    elif ons eq "DiagonalAction" then
      soc:= Socle(g);
      ns:= NormalSubgroups(soc);
      num_norms:= 0;
      for x in ns do
        if (x`order gt 1) and (x`order lt #g) and IsNormal(g, x`subgroup) then
          num_norms:= num_norms+1;
        end if;
      end for;
      if num_norms gt 1 then
        id:= "3a";
      else
        id:= "3b";
      end if;
    elif ons eq "ProductAction" then
      id:= "4c"; //no other types have small enough degrees;
    else
      "error in ONS, i =", i;
    end if;
    return id;
end function;


procedure GetGapFiles(d1, d2)
  for d in [d1..d2] do
    printf "PRIMGRP2005[%o]:= \n[", d;
    max:= NumberOfPrimitiveGroups(d);
    for i in [1..max] do
      g, name, ons:= PrimitiveGroup(d, i);
      if i lt (max-1) then
      s:= #g;
      elif i eq max-1 then
        s:= "Factorial(" cat IntegerToString(d) cat ")/2";
      else
        s:= "Factorial(" cat IntegerToString(d) cat ")";
      end if;
      if IsSimple(g) then b1:= 1; else b1:= 0; end if;
      if IsSoluble(g) then b2:= 2; else b2:= 0; end if;
      b:= b1+b2;
      //pull out A_n, S_n to make it run faster.    
      if i gt max-2 then
        id:= "AlmostSimple";
      else
        id:= get_ons(g, ons, i);
      end if;
      //pull outA_n, S_n
      if i gt max-2 then
        sl:= [[d-1, 1]];
      else
        sl:= sub_lengths(g);
      end if;
      //pull out A_n, S_n for speed.
      if i eq max-1 then
        t:= d-2;
      elif i eq max then
        t:= d;
      else
        t:= Transitivity(g);
      end if;
      printf "[%o,%o,%o,\"%o\",%o,%o,\"%o\",,", i, s, b, id, sl, t, name;
      if i eq max-1 then
        printf "\"Alt\"";
      elif i eq max then
        printf "\"Sym\"";
      elif id eq "1" and (d gt 3) then
        MakeMatGapFormat(g);
      elif IsPrime(d-1) and g eq PSL(2, d-1) then
        printf "\"psl\"";
      elif IsPrime(d-1) and g eq PGL(2, d-1) then
        printf "\"pgl\"";
      elif i eq max-1 then
        printf "\"Alt\"";
      elif i eq max then
        printf "\"Sym\"";
      else
        MakeGapFormat(g);
      end if;
      //will need to add sims number if degree is less than 50.
      if d lt 51 then
        printf ",";
      end if;
      if i lt max then
        printf "],";
      else
        printf "]];\n";
      end if;
    end for;
  end for;
end procedure;    




SetLogFile("~/moreprims/gap/newgrps/grps1.gap");
GetGapFiles(2, 150);
UnsetLogFile();

SetLogFile("~/moreprims/gap/newgrps/grps2.gap");
GetGapFiles(151, 300);
UnsetLogFile();

SetOutputFile("~/moreprims/gap/newgrps/grps3.gap");
GetGapFiles(301, 450);
UnsetOutputFile();

SetLogFile("~/moreprims/gap/newgrps/grps4.gap");
GetGapFiles(451, 600);
UnsetLogFile();

SetOutputFile("~/moreprims/gap/newgrps/grps5.gap");
GetGapFiles(601, 650);
UnsetOutputFile();

SetOutputFile("~/moreprims/gap/newgrps/grps6.gap");
GetGapFiles(651, 720);
UnsetOutputFile();

SetOutputFile("~/moreprims/gap/newgrps/grps7.gap");
GetGapFiles(721, 750);
UnsetOutputFile();

SetOutputFile("~/moreprims/gap/newgrps/grps8.gap");
GetGapFiles(751, 850);
UnsetOutputFile();

SetOutputFile("~/moreprims/gap/newgrps/grps9.gap");
GetGapFiles(851, 999);
UnsetOutputFile();

SetOutputFile("~/moreprims/gap/newgrps/grps10.gap");
GetGapFiles(1000, 1001);
UnsetOutputFile();

SetOutputFile("~/moreprims/gap/newgrps/grps11.gap");
GetGapFiles(1002, 1100);
UnsetOutputFile();

SetOutputFile("~/moreprims/gap/newgrps/grps12.gap");
GetGapFiles(1101, 1295);
UnsetOutputFile();

SetOutputFile("~/moreprims/gap/newgrps/grps13.gap");
GetGapFiles(1296, 1297);
UnsetOutputFile();

SetOutputFile("~/moreprims/gap/newgrps/grps14.gap");
GetGapFiles(1298, 1400);
UnsetOutputFile();

SetOutputFile("~/moreprims/gap/newgrps/grps15.gap");
GetGapFiles(1401, 1600);
UnsetOutputFile();

SetOutputFile("~/moreprims/gap/newgrps/grps16.gap");
GetGapFiles(1601, 1750);
UnsetOutputFile();

SetOutputFile("~/moreprims/gap/newgrps/grps17.gap");
GetGapFiles(1751, 1900);
UnsetOutputFile();

SetOutputFile("~/moreprims/gap/newgrps/grps18.gap");
GetGapFiles(1901, 2020);
UnsetOutputFile();

SetOutputFile("~/moreprims/gap/newgrps/grps19.gap");
GetGapFiles(2021, 2050);
UnsetOutputFile();

SetOutputFile("~/moreprims/gap/newgrps/grps20.gap");
GetGapFiles(2051, 2150);
UnsetOutputFile();

SetOutputFile("~/moreprims/gap/newgrps/grps21.gap");
GetGapFiles(2151, 2225);
UnsetOutputFile();

SetOutputFile("~/moreprims/gap/newgrps/grps22.gap");
GetGapFiles(2226, 2400);
UnsetOutputFile();

SetOutputFile("~/moreprims/gap/newgrps/grps23.gap");
GetGapFiles(2401, 2402);
UnsetOutputFile();

SetOutputFile("~/moreprims/gap/newgrps/grps24.gap");
GetGapFiles(2403, 2499);
UnsetOutputFile();

load "~/moreprims/code/affines/sols4_7.rec";
load "~/moreprims/code/affines/insols4_7.rec";


groups:= sols4_7 cat insols4_7;
perm_groups:= [Semidir(x`Group, Getvecs(x`Group)) : x in groups];
max:= #perm_groups;
SetOutputFile("~/moreprims/gap/2401extras.gap");
for i in [1..max] do
  g:= perm_groups[i];
  s:= #g;
  if IsSimple(g) then b1:= 1; else b1:= 0; end if;
  if IsSoluble(g) then b2:= 2; else b2:= 0; end if;
  b:= b1+b2;
  id:= "Affine";
  sl:= sub_lengths(g);
  t:= Transitivity(g);
  name:= "";
  printf "[%o,%o,%o,\"%o\",%o,%o,\"%o\",,", i, s, b, id, sl, t, name;
  MakeMatGapFormat(g);
  if i lt max then
    printf "],";
  else
     printf "]];\n";
  end if;
end for;
UnsetOutputFile();




