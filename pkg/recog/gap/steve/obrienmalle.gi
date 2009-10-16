#/***************************************************************/
#/*   Recognise quasi-simple group of Lie type when             */
#/*   characteristic is given                                   */
#/*                                                             */
#/*   Babai et al. (preprint);  Altseimer & Borovik (2001)      */
#/*   provide theoretical basis for algorithms                  */
#/*                                                             */
#/*   this version developed by Malle & O'Brien March 2001      */ 
#/*                                                             */
#/***************************************************************/
#

# GAP translation attempt Jan 2004 SL

SampleSize := 250; # largest sample considered 
NmrTrials := 10;   # repeated sampling */


OMppdset := function(p, o)
    local   primes;
    primes := Set(Factors(o));
    RemoveSet(primes,p);
    return Set(primes, l->OrderMod(p,l));
end;


VerifyOrders := function (type, n, q, orders)
    local   p,  allowed,  maxprime,  r,  rq,  ii, LargestPrimeOccurs;
    LargestPrimeOccurs := function(r, orders)
        local   maxp;
        maxp := Maximum(Factors(r));
        return ForAny(orders, i->i mod maxp = 0);
    end;
    p := Factors(q)[1];
    allowed := orders;  
    maxprime := true;
    if type = "L" then
        if n = 2 then
            if p = 2 then
                allowed := Set([2, q-1, q+1]);
            else
                allowed := Set([p, (q-1)/2, (q+1)/2]);
          fi;
      elif n = 3 then
          if (q-1) mod 3 <> 0 then
              allowed := Set([4, p* (q-1), q^2-1, q^2+q+1]);
          else
              allowed := Set([4, p* (q-1)/3, q-1, (q^2-1)/3, (q^2+q+1)/3]);
          fi;
      elif n = 4 then
          if p = 2 then
              allowed := Set([4* (q-1), p* (q^2-1), q^3-1, (q^2+1)* (q-1), (q^2+1)* (q+1)]);
          elif p = 3 then
              allowed := Set([9, p* (q^2-1), q^3-1, (q^2+1)* (q-1), (q^2+1)* (q+1)]);
          elif (q-1) mod 2 <> 0 then
              allowed := Set([p* (q^2-1), q^3-1, (q^2+1)* (q-1), (q^2+1)* (q+1)]);
          elif (q-1) mod 4 = 2 then
              allowed := Set([p* (q^2-1), (q^3-1)/2, (q^2+1)* (q-1)/2,
                              (q^2+1)* (q+1)/2 ]);
          else
              allowed := Set([p* (q^2-1), (q^3-1)/4, (q^2+1)* (q-1)/4,
                              (q^2+1)* (q+1)/4 ]);
          fi;
      elif n = 5 and q = 2 then
          allowed := Set([8, 12, 14, 15, 21, 31]);
      elif n = 6 and q = 3 then
          allowed := Set([36, 78, 80, 104, 120, 121, 182]);
          maxprime := 91 in orders or 121 in orders;
      else
          maxprime := LargestPrimeOccurs (q^n-1, orders)
                      and LargestPrimeOccurs (q^(n-1)-1, orders)
                      and Maximum (orders) <= (q^n-1)/ (q-1)/Gcd (n,q-1);
          if n = 8 and q = 2 then
              maxprime := maxprime and LargestPrimeOccurs (7, orders);
              #/Set([ i : i in orders | i mod 21 = 0]) <> Set([]);
          fi;
      fi;
  elif type = "U" then
      if n = 3 then
          if (q+1) mod 3 <> 0 then
              allowed := Set([4, p* (q+1), q^2-1, q^2-q+1]);
          else
              allowed := Set([4, p* (q+1)/3, q+1, (q^2-1)/3, (q^2-q+1)/3]);
          fi;
      elif n = 4 then
          if p = 2 then
              allowed := Set([8, 4* (q+1), p* (q^2-1), q^3+1, (q^2+1)* (q-1), (q^2+1)* (q+1)]);
          elif p = 3 then
              allowed := Set([9, p* (q^2-1), q^3+1, (q^2+1)* (q-1), (q^2+1)* (q+1)]);
              if q = 3 then
                  maxprime := 8 in orders and 9 in orders;
              fi;
          elif (q+1) mod 2 <> 0 then
              allowed := Set([p* (q^2-1), q^3+1, (q^2+1)* (q-1), (q^2+1)* (q+1)]);
          elif (q+1) mod 4 = 2 then
              allowed := Set([p* (q^2-1), (q^3+1)/2, (q^2+1)* (q-1)/2,
                              (q^2+1)* (q+1)/2 ]);
              if q = 5 then
                  maxprime := Maximum (orders) > 21;
              fi;
          else
              allowed := Set([p* (q^2-1), (q^3+1)/4, (q^2+1)* (q-1)/4,
                              (q^2+1)* (q+1)/4 ]);
          fi;
      else
          r := 2 * ((n-1)/2)+1;
          maxprime := LargestPrimeOccurs (q^r+1, orders)
                      and Maximum (orders) <= (q^(r+1)-1)/ (q-1);
          if n = 6 and q = 2 then
              maxprime := maxprime and 18 in orders;
          fi;
      fi;
  elif type = "S" then
      if n = 4 then
          if q mod 2 = 0 then
              allowed := Set([4, p * (q-1), p * (q+1), q^2-1, q^2+1]);
          elif q mod 3 = 0 then
              allowed := Set([9, p * (q-1), p * (q+1), (q^2-1)/2, (q^2+1)/2]);
          else
              allowed := Set([p * (q-1), p * (q+1), (q^2-1)/2, (q^2+1)/2]);
          fi;
      elif n = 6 and q = 2 then
          allowed := Set([ 7, 8, 9, 10, 12, 15 ]);
          maxprime := 8 in orders and 15 in orders;
      else
          maxprime := LargestPrimeOccurs (q^(n/2)+1, orders) and
                      LargestPrimeOccurs (q^(n/2)-1, orders);
      fi;
  elif type = "O^+" and n = 8 and q = 2 then
      allowed := Set([ 7, 8, 9, 10, 12, 15 ]);
      maxprime := 8 in orders and 15 in orders;
  elif type = "O^+" and n = 10 and q = 2 then
      allowed := Set([ 18, 24, 31, 42, 45, 51, 60]);
  elif type = "O^-" then
      maxprime := LargestPrimeOccurs (q^(n/2)+1, orders) and
                  LargestPrimeOccurs (q^(n/2 -1)-1, orders);
  elif type = "2B" then
      rq := RootInt(2*q);
      allowed := Set([4, q-1, q-rq+1, q+rq+1]);
  elif type = "2G" then
      rq := RootInt(3*q);
      allowed := Set([9, 3* (q-1), q+1, q-rq+1, q+rq+1]);
  elif type = "G" then
      if p = 2 then
          allowed := Set([8, 4 * (q-1), 4 * (q+1), q^2-1, q^2-q+1, q^2+q+1]);
      elif p <= 5 then
          allowed := Set([p^2, p * (q-1), p * (q+1), q^2-1, q^2-q+1, q^2+q+1]);
      else
          allowed := Set([p * (q-1), p * (q+1), q^2-1, q^2-q+1, q^2+q+1]);
      fi;
  elif type = "2F" and q = 2 then
      allowed := Set([10, 12, 13, 16 ]);
  elif type = "2F" and q = 8 then
      allowed := Set([ 12, 16, 18, 20, 28, 35, 37, 52, 57, 63, 65, 91, 109 ]);
      maxprime := Maximum (orders) > 37;
  elif type = "3D" and q = 2 then
      allowed := Set([ 8, 12, 13, 18, 21, 28 ]);
      maxprime := Maximum (orders) > 13;
  elif type = "F" and q = 2 then
      allowed := Set([ 13, 16, 17, 18, 20, 21, 24, 28, 30 ]);
  elif type = "2E" and q = 2 then
      allowed := Set([ 13, 16, 17, 18, 19, 20, 21, 22, 24, 28, 30, 33, 35 ]);
  elif type = "E" and n = 7 and q = 2 then
      maxprime := Maximum (orders) <= 255;
  fi;
  
  if not maxprime then
      return RO_CONTRADICTION;
  fi;
  for ii in allowed do
      orders := Filtered( orders, o-> ii mod o <> 0 );
  od;
  if orders = [] then
      return Concatenation(type,"_",String(n), "(", String(q), ")");
  else
      return  RO_CONTRADICTION;
  fi;
end;  #  VerifyOrders




PossiblyProjectiveOrder := function(g)
    if IsMatrix(g) and IsFFECollColl(g) then
        return ProjectiveOrder(g)[1];
    else
        return Order(g);
    fi;
end;
    


#/*  P random process for group; 
#    distinguish PSp (2n, p^e) from Omega (2n + 1, p^e);
#    orders are orders of elements */
#

DistinguishSpO := function (G, n, p, e, orders)
    local   twopart,   q,  goodtorus,  t1,  tp,  t2,  
            found,  tf,  ttf,  g,  o,  mp,  i,  x,  z,  po,  h;
    
    twopart := function (n)
        local k;
        k := 1;
        while n mod 2 = 0 do
            n := n/2; 
            k := k*2;
        od;
        return k;
    end;
    
    q := p^e;
    if n mod 2 = 1 and (q + 1) mod 4 = 0 then
        goodtorus := 2 * n; 
        t1 := q^n + 1;
        tp := twopart ((q^n + 1) / 2);
    else
        goodtorus := n; 
        t1 := q^n - 1;
        tp := twopart ((q^n - 1) / 2);
    fi;
    t2 := q^QuoInt(n , 2) + 1;
    
    found := false;
    tf := 0; ttf := 0;  # counters to deal with wrong char groups
    repeat
        g := PseudoRandom (G);
        o := PossiblyProjectiveOrder (g);
        if o mod p <> 0 then
            ttf := ttf+1;
            mp := OMppdset (p, o);
            
            
            if 2*o = t1 then
                tf := tf+1;
                g := g^(o / 2);
                found := n mod 2 = 1; 
                i := 0;
                while not found and i < 8 * n do
                    i := i+1;
                    x := PseudoRandom (G); 
                    z := g * g^x;
                    o := PossiblyProjectiveOrder (z);
                    if o mod 2 = 1 then
                        po := PossiblyProjectiveOrder (z^((o + 1) / 2) / x);
                        mp := OMppdset (p, po);
                        if (q - 1) mod 4 = 0 and (n - 1) * e in mp or
                           (q + 1) mod 4 = 0 and 2 * (n - 1) * e in mp or
                           (q - 1) mod 4 = 0 and 2 * (n - 1) * e in mp or
                           (q + 1) mod 4 = 0 and 2 * n * e in mp
#		      or (n = 4 and 6 in mp)
                           then
                            found := true;
                            #printf"mp= %o, o (z)= %o\n", mp, Factorization (oo);
                        fi;
                    fi;
                od;
            fi;
        fi;
    until found or (tf > 15) or (ttf > 80);
    if ttf > 80 then 
        return RO_NO_LUCK; 
    fi;
    
    for i in [1..6 * n] do
        h := PseudoRandom (G); 
        o := Order (g * g^h);
        if (q * (q + 1) mod o <> 0) and (q * (q - 1) mod o <> 0) 
           then
            return VerifyOrders ("S", 2 * n, q, orders);
        fi;
    od;
    
    return VerifyOrders ("O", 2 * n + 1, q, orders);
    
end;   # DistinguishSpO




#
#/* compute Artin invariants for element of order o; 
#   p is characteristic */

ComputeArtin := function (o, p)
    local   IsFermat,  IsMersenne,  primes,  orders;
    IsFermat := n-> IsPrime(n) and Set(Factors(n-1)) = [2];
    IsMersenne := n->IsPrime(n) and Set(Factors(n+1)) = [2];
    primes := Set(Factors(o));
    RemoveSet(primes,p);
    RemoveSet(primes,2);
    orders := Set(primes, x-> OrderMod(p, x));

    if IsFermat (p) and o mod 4 = 0 then 
        AddSet(orders,1);
    fi;
    if IsMersenne (p) and o mod 4 = 0 then 
        AddSet(orders,2);
    fi;
    if p = 2 and o mod 9 = 0 then
        AddSet(orders, 6);
    fi;
    return orders;
end;


#/* partition at most Nmr elements according to their 
#   projective orders listed in values; we consider
#   at most NmrTries elements; P is a random process */ 

ppdSample := function (G, ppd, p, values, SampleSize) 
    local   Bins,  x,  j,  original,  NmrTries,  g,  o,  list;

    Bins := ListWithIdenticalEntries(Length(values),0);

   for x in ppd do
       for j in [1..Length(values)] do
           if values[j] in x then
               Bins[j] := Bins[j] + 1;
           fi;
       od;
   od;
   original := Length(ppd);
            
   ppd := [];

   NmrTries := 0;
   while NmrTries <= SampleSize do 
       NmrTries := NmrTries + 1;
       g := PseudoRandom (G);
       o := Order (g);
       list := ComputeArtin (o, p);
       Add (ppd, list);
       for j in [1..Length(values)] do
           if values[j] in list then
               Bins[j] := Bins[j]+1;
           fi;
       od;
   od;
   

   return [Bins/(original + SampleSize), ppd, Bins];

end;


OrderSample := function (G, p, orders, values, SampleSize)
    local    Bins,  i,  j,  original,  NmrTries,  g,  o,  
            Total;

    Bins := ListWithIdenticalEntries(Length(values),0);

   for i in orders do
      for j in [1..Length(values)] do
         if i mod values[j] = 0 then
            Bins[j] := Bins[j] + 1;
         fi;
      od;
   od;
   original := Length(orders);
            
   NmrTries := 0;
   while NmrTries <= SampleSize do 
      NmrTries := NmrTries + 1;
      g := PseudoRandom (G);
      o := PossiblyProjectiveOrder (g);
      Add (orders, o);
      for j in [1..Length(values)] do
         if o mod values[j] = 0 then
            Bins[j] := Bins[j]+1;
         fi;
      od;
      Total := Sum(Bins);
   od;

   return [ Bins/ (SampleSize + original), orders, Bins] ;

end;





# PSL (2, p^k) vs PSp (4, p^(k / 2)) 
PSLvsPSP := function (G, ppd, q, SampleSize, NmrTrials, orders)
    local   p,  g,  o,  v1,  values,  temp,  prob;
   p := Factors (q)[1];
   if q = 2 then
      repeat 
         SampleSize := SampleSize - 1;
         g := PseudoRandom (G);
         o := PossiblyProjectiveOrder (g);
         if o = 4 then 
            return VerifyOrders ("L",2,9, orders);
         fi;
      until SampleSize = 0;
      return VerifyOrders ("L",2,4, orders);
   fi;

   v1 := Maximum (ppd);
   ppd := [];
   values := [v1];
   repeat 
       temp := ppdSample (G, ppd, p, values, SampleSize);
       prob := temp[1];
       ppd  := temp[2];
       prob := prob[1];
       if prob >= 1/3 and prob < 1/2 then
           return VerifyOrders ("L",2, q^2, orders);
       elif prob >= 1/5 and prob < 1/4 then
           return VerifyOrders ("S",4, q, orders);
       fi;
       NmrTrials := NmrTrials + 1;
   until NmrTrials = 0;

   if NmrTrials = 0 then 
#      return "Have not settled this recognition"; 
      return RO_NO_LUCK; 
   fi;

end;


OPlus82vsS62 := function (G, orders, SampleSize)
    local   values,  temp,  prob;
    values := [15];
    temp := OrderSample (G, 2, [], values, SampleSize);
    prob := temp[1]; 
    orders := temp[2];
    prob := prob[1];
#"prob is ", prob;
    if AbsoluteValue (1/5 - prob) < AbsoluteValue (1/15 - prob) then 
        return VerifyOrders ("O^+",8, 2, orders );
    else 
        return VerifyOrders ("S",6, 2, orders );
    fi;
end;

OPlus83vsO73vsSP63 := function (G, orders, SampleSize)
    local   values,  temp,  prob;
    values := [20];
    temp := OrderSample (G, 3, [], values, SampleSize);
    prob := temp[1];
    orders := temp[2];
    prob := prob[1];
    if AbsoluteValue (3/20 - prob) < AbsoluteValue (1/20 - prob) then 
        return "O^+_8 ( 3 )";
    else 
        return DistinguishSpO (G, 3, 3, 1, orders);
    fi;
end;


OPlus8vsO7vsSP6 := function (G, orders, p, e, SampleSize)
    local   i,  g,  o,  list;

   for i in [1..SampleSize] do
       g := PseudoRandom (G);
       o := PossiblyProjectiveOrder (g);
       list := ComputeArtin (o, p);
       if IsSubset(list, [e, 2 * e, 4 * e]) then
           return VerifyOrders ("O^+",8, p^e , orders);    
       fi;
   od;
   if p = 2 then
       return VerifyOrders ("S",6, 2^e, orders);
   else
       return DistinguishSpO (G, 3, p, e, orders);
   fi;
end;


#// O- (8, p^e) vs S (8, p^e) vs O (9, p^e) 
OMinus8vsSPvsO := function (G, v1, p, e, orders, SampleSize, NmrTrials)
    local   ppd,  values,  epsilon,  temp,  prob;
    ppd := [];
    values := [v1];
    epsilon := 1/50;
    repeat 
        temp := ppdSample (G, ppd, p, values, SampleSize);
        prob := temp[1]; 
        ppd := temp[2];
#"prob is ", prob;
        prob := prob[1];
        if prob >= 1/5 - epsilon and prob < 1/4 + epsilon then
            return VerifyOrders ("O^-",8, p^(v1/8), orders);
        elif prob >= 1/10 - epsilon and prob < 1/8 + epsilon then
            if p = 2 then
                return VerifyOrders ("S",8, 2^e, orders);
            else
                return DistinguishSpO (G, 4, p, e, orders);
            fi;
        fi;
        NmrTrials := NmrTrials - 1;
    until NmrTrials = 0;
    
    if NmrTrials = 0 then 
#      return "Have not settled this recognition"; 
        return RO_NO_LUCK; 
    fi;
    
end;

ArtinInvariants := function (G, p, Nmr)
    local   orders,  combs,  invariants,  newv1,  v1,  i,  g,  o,  
            ppds;

    orders := []; 
    combs := [];
    if p > 2 then 
        invariants := [0, 1, 2];
    else 
        invariants := [0, 1];
    fi;
    newv1 := Maximum (invariants);
    repeat
        v1 := newv1;
        for i in [1..Nmr] do
            g := PseudoRandom (G);
            o := PossiblyProjectiveOrder (g);
            AddSet (orders, o);
            if o mod 3 = 0 then 
                AddSet(orders,3);
            fi;
            if o mod 4 = 0 then 
                AddSet (orders, 4); 
            fi;
            ppds := OMppdset (p, o);
            if p = 2 and o mod 9 = 0 then 
                AddSet (ppds, 6);
                AddSet (orders, 9);
            fi;
            UniteSet(invariants,ppds);
            UniteSet(combs, Combinations (ppds, 2));
        od;
        newv1 := Maximum (invariants);
    until newv1 = v1;
    return [invariants, combs, orders];
end; # ArtinInvariants


LieType := function (G, p, orders, Nmr)
    local   temp,  invar,  combs,  orders2,  v1,  v2,  w,  v3,  e,  m,  
            bound,  combs2;

    #   P := RandomProcess ( G );
    temp := ArtinInvariants (G, p, Nmr);
    invar := temp[1];
    combs := temp[2];
    orders2 := temp[3];
   UniteSet(orders, orders2);
   
   v1 := Maximum (invar);
   RemoveSet(invar, v1);

   if v1 = 2 then
      return VerifyOrders ("L",2, p, orders);
   fi;

   if v1 = 3 then
      if p > 2 then
         return VerifyOrders ("L",3, p, orders);
      elif 8 in orders then
         return VerifyOrders ("U",3, 3, orders);
      else
         return VerifyOrders ("L",3, 2, orders);
      fi; 
   fi;


   if v1 = 4 then
      if 3 in invar then
         if p > 2 then
            return VerifyOrders ("L",4, p, orders);
         elif 15 in orders then
	    return VerifyOrders ("L",4, 2, orders);
         else
            return VerifyOrders ("L",3, 4, orders);
         fi; 
      else
         return PSLvsPSP (G, [1, 2, 4], p, SampleSize, NmrTrials, orders);
      fi;
   fi;  # v1 = 4

   v2 := Maximum (invar);
   w := v1 / (v1 - v2);

#v1; v2; w; invar; orders;
   if v1 = 12 and v2 = 4 and p = 2 then
      if 21 in orders then
         return VerifyOrders ("G",2, 4, orders);
      elif 16 in orders then
         return VerifyOrders ("2F",4, 2, orders);
      elif 7 in orders then
         return VerifyOrders ("2B",2, 8, orders);
      elif 15 in orders then
         return VerifyOrders ("U",3, 4, orders);
      else 
          return RO_CONTRADICTION;
      fi; 
   fi;  # v2 = 4

   RemoveSet(invar,v2);
   if Length(invar)  = 0 then 
       return "Unknown"; 
   fi;
   v3 := Maximum (invar);

#printf"p, v1, v2, v3: %o %o %o %o;",p,v1,v2,v3; invar; combs; orders;
   if v1 mod 2 = 1 then
      e := v1 - v2;
      if v1 mod e <> 0 then
         return RO_CONTRADICTION;
      fi;
      m := v1/e;
      if v3 <> e* (m-2) then
          return RO_CONTRADICTION;
      fi;
      return VerifyOrders ("L", m, p^e, orders);
   fi;

   if w = 3/2 then
      if p = 2 and not 3 in orders then
      	 if v1 mod 8 <> 4 then
	    return RO_CONTRADICTION;
	 fi;
	 return VerifyOrders ("2B",2,2^(v1 / 4), orders);
      fi;
      if v1 mod 6 <> 0 then
         return RO_CONTRADICTION;
      fi;
      if p = 3 and not 4 in orders then
         if v1 > 6 then
            if v1 mod 12 <> 6 then
	       return RO_CONTRADICTION;
	    fi;
	    return VerifyOrders ("2G",2, 3^(v1 / 6), orders);
         else
	    return VerifyOrders ("L",2, 8, orders);
         fi;
      fi;
      return VerifyOrders ("U",3, p^(v1 / 6), orders);
   fi; 

   if w = 4/3 then
      if p = 2 and v1 mod 8 = 4 then
	 return VerifyOrders ("2B",2, 2^(v1 / 4), orders);
      fi;
      return RO_CONTRADICTION;
   fi;

   if w = 2 then  # exceptional groups
      if v1 mod 12 = 0 and not ([v1 / 3, v1] in combs) then
         if 4 * v3 = v1 then
            return VerifyOrders ("3D",4, p^(v1 / 12), orders);
         elif (v1 / 4) in invar or (p = 2 and v1 = 24) then
            return VerifyOrders ("G",2, p^(v1 / 6), orders);
         else
	    if p = 2 and v1 mod 24 = 12 and 12*v3 = 4*v1 then
               return VerifyOrders ("2F",4,2^(v1 / 12), orders); 
	    else return RO_CONTRADICTION;
	    fi;
         fi; 

  #    /* next clause is replacement for error in draft of paper */
      elif v1 mod 12 = 6 and Maximum (orders) <= p^(v1/3) + p^(v1/6) + 1 then
         return VerifyOrders ("G",2, p^(v1 / 6), orders);
      fi; 

      if v1 mod 4 = 2 then
	 return VerifyOrders ("L",2,p^(v1 / 2), orders);
      else
         return PSLvsPSP (G, Union(invar, [v1, v2]), p^(v1 / 4), SampleSize, 
	        NmrTrials, orders);
      fi;
   fi;  # w = 2

#printf"p, v1, v2, v3: %o %o %o %o;",p,v1,v2,v3; invar; combs; orders;
   if w = 3 then
      if v1 mod 18 = 0 and 18 * v3 = 10 * v1 then
         if 8* (v1 / 18) in invar then
            return VerifyOrders ("2E",6, p^(v1 / 18), orders);
	 else return RO_OTHER;
	 fi;
      elif v1 mod 12 = 0 then
         if v1 > 12 or p > 2 then
            if v1 = 2 * v3 and not ([v1 / 2, v1] in combs)
               and not ([v1 / 3, v1] in combs) then
               return VerifyOrders ("F",4, p^(v1 / 12), orders);
            fi;
         elif 9 in orders and not ([4, 12] in combs) then
            return VerifyOrders ("F",4, 2, orders);
         fi;  
      fi; 
   fi;  # w = 3

   if w = 4 and 8 * v1 = 12 * v3 then
      if v1 mod 12 = 0 then
         return VerifyOrders ("E",6, p^(v1 / 12), orders);
      fi;
      return RO_CONTRADICTION;
   fi;

   if w = 9/2 and 12 * v1 = 18 * v3 then
      if v1 mod 18 = 0 then
         return VerifyOrders ("E",7, p^(v1 / 18), orders);
      fi;
      return RO_CONTRADICTION;
   fi;

   if w = 5 and 20 * v1 = 30 * v3 then
      if v1 mod 30 = 0 then
         return VerifyOrders ("E",8, p^(v1 / 30), orders);
      fi;
      return RO_CONTRADICTION;
   fi;   # exceptional groups

   if v1 mod (v1 - v2) <> 0 then   # unitary groups
      if (v1-v2) mod 4 <> 0  or  2 * v1 mod (v1 - v2) <> 0 then 
          return RO_OTHER;
      fi;
      e := (v1-v2) / 4;
      m := (2 * v1) / (v1 - v2);
      if ((m + 1) mod 4 = 0 and e * (m + 1) in invar) or
        ((m + 1) mod 4 <> 0 and e * (m + 1) / 2 in invar) then
	    if (m > 7 and v2-v3 = 4*e) or (m <= 7 and v2-v3 = 2*e) then
               return VerifyOrders ("U", m + 1, p^e, orders);
	    fi;
      else
         if (m > 5 and v2-v3 = 4*e) or (m = 5 and v2-v3 = 2*e) then
            return VerifyOrders ("U", m, p^e, orders);
	 fi;
      fi;
      return RO_OTHER;
   fi;   # unitary groups
   
#printf"1: v1 v2 v3 = %o %o %o;;",v1, v2, v3; invar;
   if (v1 - v2) mod 2 <> 0 then
      e := v1 - v2;  m := v1 / (v1 - v2);
      if v3 = e* (m-2) or (p = 2 and e* (m-2) = 6) or (m <= 3) then
         return VerifyOrders ("L", m, p^e, orders);
      else
         return RO_OTHER;
      fi;
   fi;
   
   e := (v1 - v2) / 2; m := v1 / (v1 - v2);  # only classical grps remain

   if p = 2 and e * m = 6 and e <= 2 and 91 in orders then
      if v3 = 10-2*e  or  m = 3 then
         return VerifyOrders ("L", m, 2^(2 * e), orders);
      else
         return RO_OTHER;
      fi;
   fi;

   if Set([m * e, v1]) in combs then
      if v3 = 2*e* (m-2) or m <= 3 then
         return VerifyOrders ("L", m, p^(2 * e), orders);
      else
         return RO_OTHER;
      fi;
   fi;

   if m = 3 then
      if 3 * v3 = v1 then
         return VerifyOrders ("U",4, p^(v1 / 6), orders);
      else
         if p^e = 2 then
            return OPlus82vsS62 (G, orders, SampleSize);
         fi;
         if p^e = 3 then
            return OPlus83vsO73vsSP63 (G, orders, SampleSize);
         else
            return OPlus8vsO7vsSP6 (G, orders, p, e, SampleSize);
         fi; 
      fi;
   fi;

   if v3 <> 2*e* (m-2) and (m > 4 or v3 <> 5*e) then   # wrong characteristic
      return RO_OTHER;
   fi;
   
   if IsMatrixGroup(G) then
       bound := 5*DimensionOfMatrixGroup(G);
   else
       bound := 100;
   fi;
   temp := ArtinInvariants (G, p, bound);
   invar := temp[1]; combs2 := temp[2]; orders2 := temp[3];
   combs := Union(combs, combs2);
   orders := Union(orders, orders2);
   if m mod 2 = 0 then
      if [m * e, (m + 2) * e] in combs then
          return VerifyOrders ("O^+", 2 * m + 2, p^e, orders);
      elif m = 4 then 
         return OMinus8vsSPvsO (G, v1, p, e, orders, SampleSize, NmrTrials);
      else #/* m >= 6 */
         if [ (m - 2) * e, (m + 2) * e] in combs then
            if p = 2 then 
               return VerifyOrders ("S", 2 * m, 2^e, orders);
            else 
               return DistinguishSpO (G, m, p, e, orders);
            fi;
         else
            return VerifyOrders ("O^-", 2*m, p^e, orders);
         fi; 
      fi;  # m even
   elif [(m - 1) * e, (m + 3) * e] in combs then
      return VerifyOrders ("O^+", 2 * m + 2, p^e, orders);
   elif [(m - 1) * e, (m + 1) * e] in combs then
      if p = 2 then 
         return VerifyOrders ("S", 2 * m, 2^e, orders);
      fi;
      # p <> 2 case 
      return DistinguishSpO (G, m, p, e, orders);
   else
      return VerifyOrders ("O^-", 2 * m, p^e, orders);
   fi; 

   return "undecided ";
end;

#**************************************************************/
#   Identify the non-abelian simple composition factor        */
#   of a nearly simple matrix group.                          */
#   Uses:  element orders, involution centralizers            */
#                                                             */
#   Step 1: Determine possible underlying characteristic      */
#           (recursively constructing small invol. central.)  */
#                                                             */
#   Step 2: Identify Lie type groups using LieType ()         */
#                                                             */
#   Step 3: Determine degree (if alternating)                 */
#                                                             */
#   Step 4: Determine sporadic candidates                     */
#                                                             */
#    Gunter Malle & E.A. O'Brien                   March 2001 */
#**************************************************************/

#  SetVerbose ("STCS", 1);

NMR_GENS := 12;
NMR_COMM := 6;
NR1 := 30;
NR2 := 30;
NRINV := 150; # if no element of even order found after NRINV tries,
              # assume characteristic 2 type group

Commutators := function (l1, l2)
    return Union(List(l1,x->Set(l2,y->Comm(x,y))));
end;  # Commutators

ProbablyGroupExponent := function (G)
    local   l,  i,  orders,  g,  o,  m;
    l := [1]; 
    i := 1; 
    orders := [];
   repeat
      g := PseudoRandom (G);
      o := Order (g);
      AddSet(orders,o);
      l[i+1] := Lcm (l[i], o);
      i := i+1;
      m := Maximum ([1, i - 10]);
  until (i > 10) and l[i] = l[m];
  return [l[i], orders];
end;  # GroupExponent

RandomGensDerived := function (G)
    local   gens,  i,  g1,  g2;
   gens := [];
   for i in [1..NMR_COMM] do
       g1 := PseudoRandom (G); 
       g2 := PseudoRandom (G);
       AddSet(gens,Comm(g1,g2));
   od;
   return gens;
end;  # RandomGensCommutator

InvolutionModCenter := function (G, g)
    local   o,  x;
    o := Order (g);
    if o mod 2 = 0 then
        while o mod 2 = 0 do
            o := o/2;
        od;
        g := g^o;
        if ForAll(GeneratorsOfGroup(G), i->g*i=i*g) then
            return One (G);
        fi;
        for x in GeneratorsOfGroup (G) do
            while g^2*x <> x*g^2 do
                g := g^2;
            od;
        od;
        return g;
    fi;
    return One (G);
end;

RandomInvModCenter := function (G)
    local   i,  g,  o;
    for i in [1..NRINV] do
        g := PseudoRandom (G);
        o := PossiblyProjectiveOrder (g);
        g := InvolutionModCenter (G, g);
        if not IsOne(g) then
            return [g, true];
        fi;
    od;
    return [One(G), false];  # No involution found 
end;    # RandomInvModCenter

FindFieldSize := function (H, dim)
    local   o,  qs,  i,  ree;
   o := ProbablyGroupExponent ( H )[1];
   qs := [];
   for i in [o+1, o-1] do
       if IsPrimePowerInt(i) then
           AddSet(qs,i);
       fi;
   od;
   ree := false;
   if dim = 2 then
       if IsPrimePowerInt(2*o-1) and 2*o-1 mod 3 = 0 then
           ree := true;
       fi;
   fi;      # to recognize the Ree groups 
   if (dim = 1) or ree then
       for i in [2*o+1, 2*o-1] do
           if IsPrimePowerInt(i) then
               AddSet(qs,i);
           fi;
       od;
   fi;
   if o = 12 then
       AddSet(qs,3);
       return [qs, false];
   fi;     # it may be L2 (3)
   return [qs, true];
end;

# recognize an L2 (q), given a list of possible q's */
WhichL2q := function (G, qs)
    local   orders,  maxord,  q,  p;
    orders := List([1..NR1], i->PossiblyProjectiveOrder(PseudoRandom(G)));
    #some random orders
    maxord := Maximum (orders);
    for q in qs do
        p := Factors(q)[1];
        if ForAny(orders, o->2*p mod o <> 0 and (q+1) mod o <> 0 and
                  (q-1) mod o <> 0) then
            RemoveSet(qs,q);
        fi;
    od;
    if not (4 in orders or 8 in orders) then  RemoveSet(qs,9); fi;
    if not (5 in orders or 10 in orders) then RemoveSet(qs, 5); fi;
    return qs;
end;        # WhichL2q

#  Find a small involution centralizer     */


SmallCentralizer := function (G)
    local   G0,  dim,  tmp,  r1,  flag,  invs,  jf,  g,  h,  x,  o,  
            H,  cc,  oG,  xx,  yy;
    G0 := G;
    dim := 0;
    repeat
        tmp :=  RandomInvModCenter(G);
        r1 := tmp[1];
        flag := tmp[2];
        if not flag then
            return [G, 0, G, false];
        fi;
        invs := [];
        for jf in [1..NMR_GENS] do
            g := PseudoRandom (G);
            h := r1*r1^g;
            x := InvolutionModCenter (G, h);
            if x <> One(G) then
                Add(invs, x);
            else   # element has odd order mod center
                o := PossiblyProjectiveOrder (h);
                while o mod 2 = 0 do o := o/2; od;
                Add (invs, h^ ((o+1)/ 2)/g);
            fi;
        od;
        if invs <> [] then
            dim := dim +1;
            H := SubgroupNC(G0,invs);
            cc := RandomGensDerived (H);
            oG := G;
            G := SubgroupNC(G0,cc);
            xx := RandomGensDerived (G);
            G := SubgroupNC(G0, xx);
            yy := Commutators ( xx, cc );
            if ForAll(yy,i->Order(i)=1) then 
                return [oG, dim, H, true];  # L2 (q), D_{q+-1}
            fi;
        fi;
    until false;
    Error( "Error: SmallCentralizer failed!");
    return [G, -1, H];
end;    # SmallCentralizer

# given group G, determine its defining field */
DetermineFieldSize := function (G)
    local   tmp,  qs;
    tmp := SmallCentralizer (G);  
    qs := FindFieldSize (tmp[3], tmp[2]);                       
    return qs;
end;

RemoveSome := function (types, ns, orders)

  if ns = 7 and not 6 in orders then
     ns := 0;
  fi;
  if ns = 9 then
      if 15 in orders then
          RemoveSome(types, "U_4 ( 3 )");
      else 
          ns := 0;
      fi;
  fi;
  if ns >= 19 then
     if ForAny(orders, o-> not o in  [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
                16, 17, 18, 19, 20, 21, 22, 24, 28, 30, 33, 35]) then
         RemoveSet( types,"2E_6 ( 2 )"); 
     fi;
 fi;
 return [types, ns];
end;   # RemoveSome

DegreeAlternating := function (orders)
    local   degs,  prims,  m,  f,  n;
    degs := []; 
    prims := [];
    for m in orders do 
        if m > 1 then
            f := Collected(Factors(m));
            Sort(f);
            n := Sum(f, x->x[1]^x[2]);
            if f[1][1] = 2 then n := n+2; fi;
            AddSet(degs,n);
            UniteSet(prims,Set(f,x->x[1]));
        fi; 
    od;
    return [degs, prims];
end;    #  DegreeAlternating

RecognizeAlternating := function (orders)
    local   tmp,  degs,  prims,  mindeg,  p1,  p2,  i;
   tmp := DegreeAlternating (orders);
   degs := tmp[1];
   prims := tmp[2];
   if Length(degs) = 0 then 
       return "Unknown"; 
   fi;
   mindeg := Maximum (degs);  # minimal possible degree
   
   p1 := PrevPrimeInt (mindeg + 1);
   p2 := PrevPrimeInt (p1);
   if not p1 in prims or not p2 in prims then
       return 0;
   fi;
   if mindeg mod 2 = 1 then
       if not (mindeg in orders and  mindeg - 2 in orders) then 
           return 0;
       fi;
   else
       if not mindeg - 1 in orders then 
           return 0;
       fi;
   fi;
  
   for i in [3..Minimum (QuoInt(mindeg,2) - 1, 6)] do
       if IsPrime (i) and IsPrime (mindeg - i) then
           if not i * (mindeg - i) in orders then
               return 0;
           fi;
       elif IsPrime (i) and IsPrime (mindeg - i -1) then
           if not i * (mindeg - i - 1) in orders then
               return 0;
           fi;
       fi;
   od;
   return  mindeg;
end;   # RecognizeAlternating

RecogniseAlternating := RecognizeAlternating;

SporadicGroupData := [
                      rec( req := [5,6,8,11],
                           allowed := [],
                           name := "M_11"),
                      rec( req := [6,8,10,11],
                           allowed := [],
                           name := "M_12"),
                      rec( req := [5,6,7,8,11],
                           allowed := [],
                           name := "M_22"),
                      rec( req := [11,14,15,23],
                           allowed := [6,8],
                           name := "M_23"),
                      rec( req := [11,21,23],
                           allowed := [8,10,12,14,15],
                           name := "M_24"),
                      rec( req := [11,15,19],
                           allowed := [6,7,10],
                           name := "J_1"),
                      rec( req := [7,12,15],
                           allowed := [8,10],
                           name := "J_2"),
                      rec( req := [15,17,19],
                           allowed := [8,9,10,12],
                           name := "J_3"),
                      rec( req := [11,20],
                           allowed := [7,8,10,12,15],
                           name := "HS"),
                      rec( req := [11,14,30],
                           allowed := [8,9,12],
                           name := "McL"),
                      rec( req := [11,13],
                           allowed := [14,15,18,20,21,24],
                           name := "Suz"),
                      rec( req := [26,29],
                           allowed := [14,15,16,20,24],
                           name := "Ru"),
                      rec( req := [22,23,24,30],
                           allowed := [14,18,20,21],
                           name := "Co_3"),
                      rec( req := [16,23,28,30],
                           allowed := [11,18,20,24],
                           name := "Co_2"),
                      rec( req := [33,42],
                           allowed := [16,22,23,24,26,28,35,36,39,40,60],
                           name := "Co_1"),
                      rec( req := [19,28,31],
                           allowed := [11,12,15,16,19,20,28,31],
                           name := "ON"),
                      rec( req := [13,24,30],
                           allowed := [14,16,18,20,21,22],
                           name := "Fi_22"),
                      rec( req := [17,28],
                           allowed := [8,10,12,15,21],
                           name := "He"),
                      rec( req := [31,67],
                           allowed := [18,22,24,25,28,30,33,37,40,42],
                           name := "Ly"),
                      rec( req := [37,43],
                           allowed := [16,23,24,28,29,30,31,33,35,40,42,44,66],
                           name := "J_4")];
                      
                      

RecognizeSporadic := function (orders)
    local   maxords,  spors,  r;
    orders := Set(orders);
    maxords := Filtered(orders, i-> Number(orders,j -> j mod i = 0)=1);
    spors := [];
    for r in SporadicGroupData do
        if ForAll(r.req, o->o in maxords) and
           ForAll(maxords, o->o in r.allowed or o in r.req) then
            Add(spors,r.name);
        fi;
    od;
  return spors;  
end;  # RecognizeSporadic

RecogniseSporadic := RecognizeSporadic; 

IdentifySimple := function (G0)
    local   NmrTries,  limit,  d,  orders,  NRtries,  ct,  tmp,  G,  
            dim,  H,  flag,  qs,  flag2,  ps,  types,  p,  erg,  ns,  
            spors, deg;
    
    NmrTries := ValueOption("NmrTries");
    if NmrTries = fail then
        NmrTries := 15;
    fi;
    
    if IsMatrixGroup(G0) then
        deg := DimensionOfMatrixGroup(G0);
    else
        deg := 100;
    fi;
    
#  /* replace G0 by successive terms of its derived series  
#     until we obtain a perfect group; if there are more
#     than 3 iterations, then we can conclude that
#     G/Z (F^* (G)) is probably not almost simple */

    limit := 0;
    while IsProbablyPerfect (G0) = false and limit < 4 do
        limit := limit + 1;
        G0 := DerivedSubgroupApproximation (G0);
        if IsTrivial(G0)  then 
            return [false]; 
        fi;
    od;
    
    if limit > 4 then 
        return [false, "G0 is not quasi-simple"]; 
    fi;
    
    if IsMatrixGroup(G0) then
        d := DimensionOfMatrixGroup(G0);
    else
        d := 100; # I dunno
    fi;
    orders := [];
    NRtries := 0;
    repeat
        NRtries := NRtries + 1;
        ct := 0;
        repeat
            tmp := SmallCentralizer (G0);
            G := tmp[1];
            dim := tmp[2];
            H := tmp[3];
            flag := tmp[4];
            if flag then
                tmp :=  FindFieldSize(H, dim);
                qs := tmp[1];
                flag2 := tmp[2];
                qs := WhichL2q (G, qs);
                ct := ct + 1;
            else 
                qs := [2]; 
            fi;
        until Length(qs) >= 1 or ct >= 6;
       
        UniteSet(orders,Set([1..NR2 + 4*d], i-> PossiblyProjectiveOrder(PseudoRandom(G0))));
        ps := Set(qs, q->Factors(q)[1]);
        AddSet(ps,2);
        types := [];
        for p in ps do
            erg := LieType (G0, p, orders, 30 + 10 *  deg);
            if not IsRecognitionOutcome(erg) then
                AddSet(types,erg);
            fi;
        od;
        
        ns := RecognizeAlternating (orders);
        if ns <> "Unknown" then 
            tmp := RemoveSome (types, ns, orders);
            types := tmp[1];
            ns := tmp[2];
            if ns <> 0 then
                AddSet(types,Concatenation("A_",String(ns)));
            fi;
        fi;
     
        spors := RecognizeSporadic (orders);
        types := Union(types, spors);
     
        if Length(types) >= 1 then
            if  Length(types) = 1 then
                return [true, types[1]];
            else
                return [true, types];
            fi;
        fi;
    until Length(types) > 0 or NRtries > NmrTries;
  
    Print("Not recognized after ", NmrTries, " tries; qs = ",qs,"\n");
    return [false];

end;  # IdentifySimple


InstallNonConstructiveRecognizer(function(g) 
    local   res;
    res := IdentifySimple(g);
    if res[1] = true then
        RecognitionInfo(g).Name := res[2];
        return res[2];
    else
        return RO_NO_LUCK;
    fi;
end,
  "Malle and O'Brien code translated into GAP");
