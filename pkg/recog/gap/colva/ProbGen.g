findnpe := function(name)
# Finds n,p and e from the name
 local v1,v2,n,q,p,e;

 v1 := SplitString(name,"_")[2];
 v2 := SplitString(v1,"("); 
 n := Int(v2[1]);
 q := PrimePowersInt(Int(SplitString(v2[2],")")[1]));
 p := q[1]; e := q[2];  
 return [n,p,e];
end;




SchurMultiplierOrder := function(name)
# returns the order of schur multiplier of the simple group of give name
 local n,p,f,d,npf,q,v;

# First the sporadics

 if name in ["M_11","M_23","M_24","Co_3","Co_2","He","Fi_23"
,"HN","Th","M","J_1","Ly","J_4"] then
   return 1;
 elif name in ["M_12","J_2","Co_1","B","Ru"] then return 2;
 elif name in ["McL","ON","J_3"] then return 3;
 elif name in ["Suz","Fi_22"] then return 6;
 elif name in ["M_22"] then return 12;
 fi;

# Alternating groups
 if name[1]='A' then
   n := Int(SplitString(name,"_")[2]);
   if n in [6,7] then return 6;
   else return 2;
   fi;
 fi;

# SL

 if name[1]='L' then
   npf := findnpe(name);
   n := npf[1]; p := npf[2]; f := npf[3];
   if n=2 then 
     d := GcdInt(2,p^f-1);
     if p=2 and f=2 then return 2*d;
     elif p=3 and f=2 then return 3*d;
     else return d;
     fi;
   else
     d := GcdInt(n,p^f-1);
     if n=3 and p=2 and f=1 then return 2*d;
     elif n=3 and p=2 and f=2 then return 4^2*d;
     elif n=4 and p=2 and f=1 then return 2*d;
     else return d;
     fi;
   fi;
 fi;

# SU
 if name[1]='U' then
   npf := findnpe(name);
   n := npf[1]-1; p := npf[2]; f := npf[3]; q := p^f;
   d := GcdInt(n+1,q+1);
   if [n,p,f]=[3,2,1] then return 2*d;
   elif [n,p,f]=[3,3,1] then return 3^2*d;
   elif [n,p,f]=[5,2,1] then return 2^2*d;
   else return d;
   fi;
 fi;

# Sp
 if name[1]='S' then
   npf := findnpe(name);
   n := (npf[1])/2; p := npf[2]; f := npf[3]; q := p^f;
   d := GcdInt(2,q-1);
   if [n,p,f]=[3,2,1] then return 2*d;
   else
     return d;
   fi;
 fi;

# Omega
 v := SplitString(name,"_");
 if v[1]="O" then     
   npf := findnpe(name);
   n := (npf[1]-1)/2; p := npf[2]; f := npf[3]; q := p^f;
   d := GcdInt(2,q-1);
   if [n,p,f] in [[2,2,1],[3,2,1]] then return 2*d;
   elif [n,p,f]=[3,3,1] then return 3*d;
   else return d;
   fi;
 fi;



# Omega^+ 
 if v[1]="O^+" then
   npf := findnpe(name);
   n := npf[1]/2; p := npf[2]; f := npf[3]; q := p^f;
   if IsEvenInt(n) then
     d := GcdInt(2,q-1)^2;
     if [n,p,f]=[4,2,1] then return 2^2*d;
     else return d;
     fi;
   else
     d := GcdInt(4,q^n-1);
     return d;
   fi;
 fi;

# Omega^-   
 if v[1]="O^-" then
   npf := findnpe(name);
   n := npf[1]; p := npf[2]; f := npf[3]; q := p^f;
   d := GcdInt(4,q^n+1);
   return d;
 fi;
 
## Given up - this has become very boring - can't be bothered to do the exceptionals!!!

 return 6;
end;

OuterOrderBound := function(str)
## Given a simple group defined by str compute an upper bound for the order of Out(G) using the Stefan Kohl paper
# Could probably do better using the ATLAS
 local v1,f,n,npf,p;

  if str[1]='A' then
# Alternating groups
    n := Int(SplitString(str,"_")[2]);
    if n=6 then return 4; 
    else return 2;
    fi;
  elif str in 
  ["M_11","M_23","M_24","Co_3","Co_2","He","Fi_23"
,"HN","Th","M","J_1","Ly","J_4","M_12","J_2","Co_1","B","Ru",
"McL","ON","J_3","Suz","Fi_22","M_22"] then return 2;
  elif str[1]='L' or str[1]='U' then
# PSL
    npf := findnpe(str);
    n := npf[1]; f := npf[3];
    if n=2 then return 2*f;
    elif n=3 then return 6*f;
    elif n=4 then return 8*f;
    else return 2*(n+1)*f;
    fi;
  elif str[1]='C' or (str[1]='O' and str[2]="_") then
    npf := findnpe(str);
    return 2*npf[3];
  elif str[1]='O' and str[3]='+' then
    npf := findnpe(str);
    n := npf[1]; f := npf[3];
    if n=8 then
      return 24*f;
    else
      return 8*f;
    fi;
  elif str[1]='2' and str[2]='B' then      
    v1 := SplitString(str,"(")[2];
    f := PrimePowersInt(Int(SplitString(v1,")")[1]))[2];
    return f;
  else
    v1 := SplitString(str,"(")[2];
    f := PrimePowersInt(Int(SplitString(v1,")")[1]))[2];
    return 6*f;
  fi;
end;

SimpleGroupOrder := function(name)
  local npe,n;

  if name in
   ["M_11","M_23","M_24","Co_3","Co_2","He","Fi_23"
,"HN","Th","M","J_1","Ly","J_4","M_12","J_2","Co_1","B","Ru",
"McL","ON","J_3","Suz","Fi_22","M_22"] then
    name:=Concatenation(SplitString(name,"_"));
    return Size(CharacterTable(name));
  fi;

  if name[1]='A' then
    n := Int(SplitString(name,"_")[2]);
    return Factorial(n)/2;
  elif name[1]='L' then
    npe := findnpe(name);
    return Size(SL(npe[1],npe[2]^npe[3]))/GcdInt(npe[1],npe[2]^npe[3]-1);
  elif name[1]='S' then
    npe := findnpe(name);
    return Size(Sp(npe[1],npe[2]^npe[3]))/GcdInt(2,npe[2]^npe[3]-1);
  elif name[1]='U' then
    npe := findnpe(name);
    return Size(SU(npe[1],npe[2]^npe[3]))/GcdInt(npe[1],npe[2]^npe[3]+1);
  elif name[1]='O' then
    if name[2]='_' then
      npe := findnpe(name);
      return Size(SO(npe[1],npe[2]^npe[3]))/GcdInt(2,npe[2]^npe[3]-1);   
    elif name[3]='+' then
      npe := findnpe(name);
      return Size(SO(1,npe[1],npe[2]^npe[3]))/(2*GcdInt(2,(npe[2]^npe[3])^(npe[1]/1)-1));   
    elif name[3]='-' then     
      npe := findnpe(name);
      return Size(SO(-1,npe[1],npe[2]^npe[3]))/(2*GcdInt(2,(npe[2]^npe[3])^(npe[1]/1)+1));   
    fi;
  fi;

  Error("Don't know any exceptional groups");

end;

ProbGenNonAb :=function(str,m,k)
## Returns an underestimate of the probability of k random generators generating the simple group given by str.  Assumes that the probability of randomly generating a simple group with 3 generators is > 833/900 = P_3(A_6)
# Require k to be greater than 3
  local Ord_G, Out_G, C ,psi_k,y;
  
  Ord_G:=SimpleGroupOrder(str);
  Out_G:=OuterOrderBound(str);
  C:=833/900;
  psi_k:=1-(1-C)^Int(k/3);
  if m > 1 then
    y:=Product(List([1..(m-1)],i->1-i*Out_G/(Ord_G^(k-1)*psi_k)));
  else y:=1;
  fi;
  return psi_k*y;
end;


ProbGenAb := function(q,r,k)
## Returns the probability of k random generators generating Z_q^r
  if k<r then return 0; fi;
  return Product(List([1..r],l->1-q^(l-1)/q^k));
end;
  

RequiredNumberOfGens := function(T,e)
# T is a list of tuples containing names and the number of copies #of simple groups
#i.e. T=[*["A_5",3],2^7*] is 3 copies of Alt(5) and 7 copies of Z_2
#  Returns k such that k generators will generate G with #probability gt 1-e
  local k,p,q,f,l;
  k:=4;
  repeat
    p:=1;
    for l in T do
      if not IsList(l) then
        q := PrimePowersInt(l);
        f := q[2];  q := q[1];
        p:=p*ProbGenAb(q,f,k);
      else
        p:=p*ProbGenNonAb(l[1],l[2],k);
      fi;
    od;
    if p>1-e then return k; fi;
    k := k+1;
  until k=1000;
  Error("k is very large > 1000");
end;

