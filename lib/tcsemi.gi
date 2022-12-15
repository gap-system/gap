#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Götz Pfeiffer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Installed in GAP4 by Andrew Solomon for Semigroups instead of Monoids.
##
##  This file contains implementations for Todd-Coxeter procedure for
##  fp semigroups. This uses the code written by Götz Pfeiffer
##  based on the thesis of T. Walker.
##


#############################################################################
##
#D  DeclareInfoClass("SemigroupToddCoxeterInfo");
##
##

DeclareInfoClass("SemigroupToddCoxeterInfo");

#############################################################################
##
#A  CosetTableOfFpSemigroup( cong )
##
##  A  monoid presentation is  essentially a list  of  pairs of words over an
##  alphabet.  In GAP this can be represented by a record |M| with components
##  |generators| (a list  of different |AbstractGenerator|s) for the alphabet
##  and a  component |relations| which  is a list of pairs  of words in these
##  generators meaning |r[1] =  r[2]| for each  pair  |r|.  For  example, the
##  commands
##
##      gap> a:= AbstractGenerator("a");;  b:= AbstractGenerator("b");;
##      gap> monoid:= rec( generators:= [a, b],
##      >   relations:= [[a^3, a], [b^7, b], [a*b^3*a*b^2, b^2*a]] );;
##
##  will represent the monoid with presentation $<a, b | a^3  = a, b^7 = b, a
##  b^3  a b^2 =  b^2 a>$.  The  function |CosetTableFpMonoid| enumerates the
##  elements   of a fp  monoid  if called with the  empty  list as its second
##  argument.
##
##      gap> CosetTableFpMonoid(monoid, []);;
##      #I  1005 cosets, 668 active, 337 killed.
##      #I  2010 cosets, 1223 active, 787 killed.
##      #I  2647 cosets defined, maximum 1240, 273 survive.
##
##  The enumerator  requires  an additional list  |cong| of   pairs of words,
##  which generate  a right congruence.   The classes  of this congruence are
##  called *cosets* in this context.
##
##      gap> CosetTableFpMonoid(monoid, [[a^2, a], [b^2, b]]);;
##      #I  355 cosets defined, maximum 196, 37 survive.
##
##  In  order to be able  to recycle cosets  which  have been identified with
##  other cosets  we organize them  in two lists:  the  active list of active
##  cosets and the free list of free cosets.
##
##  The *active list* is a doubly linked list.
##
##            1                 d               last          next
##            |                 |                 |             |
##            V                 V                 V             V
##          |---|---> ... --->|---|---> ... --->|---|-------->|---|---> ...
##          | 1 |             |   |             |   |         |   |
##    0 <---|---|<--- ... <---|---|<--- ... <---|---|         |---|
##
##  The   forward   references --->   are  stored  in  |forwd|,  the backward
##  references  <--- are stored in  |bckwd|.   Three pointers point into this
##  list, 1 to the initial  coset, (this  needn't  be done explicitly  since
##  coset 1 is always stored at  address 1 in the table),  |d| to the current
##  coset which is presently traced  through the relations, and |last| points
##  to the end of the list.   The cosets between  |d| and |last| are still to
##  be traced through the relations.  The last coset points to the free list.
##
##  The *free list* is a simply linked list.
##
##            last          next
##              |             |
##              V             V
##    ... --->|---|-------->|---|--->|---|---> ... --->|---|---> 0
##            |   |         |   |    |   |             |   |
##    ... <---|---|         |---|    |---|             |---|
##
##  Again, the references --->  are  stored in  |forwd|.  The pointer  |next|
##  points to its beginning, the last coset points at 0.  The free list might
##  be (and initially is) empty.  In that case |next| points at 0, too.
##
##  The images   of the cosets under the   generators are compiled in  a list
##  |table| such that  |table[i][s]| contains  the image  of  coset |s| under
##  generator |i|.   The preimages are  stored in a similar  way  in the list
##  |occur|.  Here |occur[i][s]|  contains the set  of  all cosets  which are
##  mapped to |s| under generator |i|.  There the empty set is represented by
##  0. The  list |occur| is needed  for the sole   purpose of identifying the
##  places in |table| where a coset |t|  occurs if this  needs to be replaced
##  by a coset |s|.
##
InstallMethod(CosetTableOfFpSemigroup,
"for a right congruence on an fp semigroup",
true,
[IsRightMagmaCongruence], 0,
function(cong)

   local i, r, d, la,             # loop variables,
         M,                     # the semigroup,
         gens, rels,            # generators |[1..n]| and relations,
         semirels,              # the rels of the semigroup plus x=x, x\in gens
         table, inver, occur,   # the coset table and its inverse,
         forwd, bckwd,          # for- and backward references,
         active,                # number of active cosets,
         next, lust,            # the next and the last address,
         lanext,                # the next lookahead point,
         oldkilled,
         eqnTrace,              # the trace/push,
         laTrace,               # Lookahead trace
         ideNtify,              # identification, please,
         newCoset,              # coset definition,
         repLaced,              # a translation function,
         word_to_list,          # aliased to repLaced
         defind, i1000,         # statistics and info,
         pos;                   # positions.

##  When  a new  coset is  defined the  following  steps are  taken.  Coset N
##  pointed at by |next|  is concatenated (doubly linked)  to coset L pointed
##  at by |last|.  Both  |last| and |next| move  one step forward so that now
##  |last| points to  coset N.

   # how to define a new coset: the image of t under a.
   newCoset:= function(t, a)

      # increase number of cosets.
      active:= active + 1;  defind:= defind + 1;  i1000:= i1000 + 1;

      # if the free list is empty create one of length 1 and link.
      if next = 0 then
         next:= active;  forwd[lust]:= next;  forwd[next]:= 0;
      fi;

      # make new coset active.
      bckwd[next]:= lust;  lust:= next;  next:= forwd[lust];
      for i in gens do
         table[i][lust]:= 0;
         inver[i][lust]:= 0;  #C inver[i][lust]:= [];
      od;
      table[a][t]:= lust;
      inver[a][lust]:= t;  occur[a][t]:= 0;  #C inver[a][lust]:= [t];

      # return new coset.
      pos[lust]:= defind;
#Error("Break Code\n");
      return lust;

   end;


   # how to trace the coset |d| through an equation |w|.
   eqnTrace:= function(w)
      local s, t, a, b, u, v, x;

      # tracing |d| through left of |w| gives |s|.
      s:= d;
      for a in [1..Length(w[1]) - 1] do
         if 0 < table[w[1][a]][s] then
            s:= table[w[1][a]][s];
         else
            s:= newCoset(s, w[1][a]);
         fi;
      od;

      # tracing |d| through right of |w| gives |t|.
      t:= d;
      for a in [1..Length(w[2]) - 1] do
         if 0 < table[w[2][a]][t] then
            t:= table[w[2][a]][t];
         else
            t:= newCoset(t, w[2][a]);
         fi;
      od;

      # print out statistics.
      if 999 < i1000  then
         i1000:= 0;
         Info(SemigroupToddCoxeterInfo, 2, "#I  ", defind, " cosets, ",
              active, " active, ", defind - active, " killed.\n");
      fi;

      a:= w[1][Length(w[1])];
      b:= w[2][Length(w[2])];
      u:= table[a][s];
      v:= table[b][t];

      if u = 0 and v = 0 then
        x:= newCoset(s, a);
        table[b][t]:= x;
        if a = b then
          occur[a][s]:= t;
          occur[a][t]:= 0;
        else
          inver[b][x]:= t;
          occur[b][t]:= 0;
        fi;
      fi;

      if u = 0 and v <> 0 then
        table[a][s]:= v;
        occur[a][s]:= inver[a][v];
        inver[a][v]:= s;
      fi;

      if u <> 0 and v = 0 then
        table[b][t]:= u;
        occur[b][t]:= inver[b][u];
        inver[b][u]:= t;
      fi;

      # if |s| differs from |t| start handling coincidences.
      if u <> 0 and v <> 0 then

        if pos[u] < pos[v] then
           ideNtify([v, u]);
        elif pos[v] < pos[u] then
           ideNtify([u, v]);
        fi;
      fi;

   end;

   laTrace:= function(w)
      local s, t, a, b, u, v;

      # tracing |la| through left of |w| gives |s|.
      s:= la;
      for a in [1..Length(w[1]) - 1] do
         if 0 < table[w[1][a]][s] then
            s:= table[w[1][a]][s];
         else
            return;
         fi;
      od;

      # tracing |la| through right of |w| gives |t|.
      t:= la;
      for a in [1..Length(w[2]) - 1] do
         if 0 < table[w[2][a]][t] then
            t:= table[w[2][a]][t];
         else
            return;
         fi;
      od;

      # print out statistics.
      if 999 < i1000  then
         i1000:= 0;
         Info(SemigroupToddCoxeterInfo, 2, "#I  ", defind, " cosets, ",
              active, " active, ", defind - active, " killed.\n");
      fi;

      a:= w[1][Length(w[1])];
      b:= w[2][Length(w[2])];
      u:= table[a][s];
      v:= table[b][t];

      if u = 0 and v = 0 then
        return;
      fi;

      if u = 0 and v <> 0 then
        table[a][s]:= v;
        occur[a][s]:= inver[a][v];
        inver[a][v]:= s;
      fi;

      if u <> 0 and v = 0 then
        table[b][t]:= u;
        occur[b][t]:= inver[b][u];
        inver[b][u]:= t;
      fi;

      # if |v| differs from |u| start handling coincidences.
      if u <> 0 and v <> 0 then

        if pos[u] < pos[v] then
           ideNtify([v, u]);
        elif pos[v] < pos[u] then
           ideNtify([u, v]);
        fi;
      fi;

   end;

##  When two cosets |s| and |t| are to be identified we work on an additional
##  *stack* of cosets which holds the list of yet to identify pairs of cosets
##  as consecutive entries.   After replacing |t|  by |s| in the coset table,
##  the list of  preimages and, if necessary, the  current coset, the rows of
##  |t| and |s| in  the coset table  are compared.  This produces new entries
##  in the  table and  new  coincidences  which  are written on   the  stack.
##  Afterwards the row of |t| can be  discarded in the  table.  The coset |t|
##  is taken out  of the active list  and linked to  the free  list.  It then
##  carries a (negative) backward reference to |s| in order to direct pending
##  coincidences to their proper place in the active list.

   # how to identify two cosets.
   ideNtify:= function(stack)
      local i, u, v, s, t, l;

      # initialize stack length.
      l:= 2;

      # loop over the stack.
      repeat

         # get current addresses of the top pair.
         s:= stack[l];  t:= stack[l-1];  l:= l-2;
         while bckwd[s] < 0 do
            s:= -bckwd[s];
         od;
         while bckwd[t] < 0 do
            t:= -bckwd[t];
         od;

         # if they still differ do the identification.
         if s <> t then

            # update counters and pointers.
            active:= active - 1;
            if t = d then
               d:= bckwd[d];  # replace current coset.
            fi;
            if t = la then
               la:= bckwd[la];
            fi;
            if t = lust then
               lust:= bckwd[lust];  # delete top of queue.
            else
               bckwd[forwd[t]]:= bckwd[t];  # drop |t| from queue.
               forwd[bckwd[t]]:= forwd[t];
               forwd[t]:= next;  # link |t| to free list.
               forwd[lust]:= t;
            fi;
            next:= t;
            bckwd[t]:= -s;  # leave forwarding address.

            # loop over the generators.
            for i in gens do

               # replace |t| by |s| in coset table ...
               #C for v in inver[i][t] do
               #C    table[i][v]:= s;
               #C    AddSet(inver[i][s], v);
               #C od;
#Error("Break Code");
               v:= inver[i][t];
               while 0 < v do
                  u:= occur[i][v];
                  table[i][v]:= s;
                  occur[i][v]:= inver[i][s];  inver[i][s]:= v;
                  v:= u;
               od;

               # ... and delete |t| from its inverse.
               v:= table[i][t];
               if 0 < v then

                  #C RemoveSet(inver[i][v], t);
                  u:= inver[i][v];
                  if u = t then
                     inver[i][v]:= occur[i][t];
                  else
                     while occur[i][u] <> t do
                        u:= occur[i][u];
                     od;
                     occur[i][u]:= occur[i][t];
                  fi;

                  # draw conclusions.
                  u:= table[i][s];
                  if u = 0 then
                     table[i][s]:= v;

                     #C AddSet(inver[i][v], s);
                     occur[i][s]:= inver[i][v];  inver[i][v]:= s;

                  # stack mismatches such that big is replaced by small.
                  elif pos[u] < pos[v] then
                     l:= l+2;  stack[l-1]:= v;  stack[l]:= u;
                  elif pos[v] < pos[u] then
                     l:= l+2;  stack[l-1]:= u;  stack[l]:= v;
                  fi;

               fi;
            od;

         fi;

      until l = 0;

   end;

   # how to switch to words over |[1..n]|.
   #repLaced:= w-> List(List(w), x-> Position(M.generators, x));
        #transforms a word into a list of integers
        word_to_list:=function(u)
          local i,k,n,l;

          n:=Length(ExtRepOfObj(u));
          l:=[];
          for i in [1..n/2] do
            for k in [1..ExtRepOfObj(u)[2*i]] do
              Add(l,ExtRepOfObj(u)[2*i-1]);
            od;
          od;
          return l;
        end;

   repLaced:= w-> word_to_list(w);

##  Initially there is  only one coset.  The  coset table and its inverse are
##  [[0], [0], ..., [0]] and the linked lists look as follows.
##
##           d last next
##           | |      |
##           V V      V
##          |---|---> 0
##          | 1 |
##    0 <---|---|
##
   # initialize.
         # get the semigroup on which <cong> is a congruence.
         M := Source(cong);
         # Make sure <M> is an fp semigroup
         if not IsFpSemigroup(M) then
             Error("right congruence of an fp-semigroup expected");
         fi;
   gens:= [1..Length(GeneratorsOfSemigroup(M))];
   # we add trivial relations to the semigroup relations to
   # make sure that if the semigroup has a free generator
   # then it does not stop
   semirels := Concatenation(RelationsOfFpSemigroup(M),
                             List(gens,i-> [FreeGeneratorsOfFpSemigroup(M)[i],
                             FreeGeneratorsOfFpSemigroup(M)[i]]));
   rels:= List(semirels, x-> List(x, repLaced));
   cong:= List(GeneratingPairsOfRightMagmaCongruence(cong),
                x-> List(x, y->repLaced(UnderlyingElement(y))));

   table:= [];  inver:= [];  occur:= [];
   for i in gens do
      table[i]:= [0];
      inver[i]:= [0];  occur[i]:= [];  #C inver[i]:= [[]];
   od;

   active:= 1;  defind:= 1;  i1000:= 1;
   lanext:= Int(SemigroupTCInitialTableSize/(3*Length(gens)));
   forwd:= [0];  bckwd:= [0];  pos:= [1];
   lust:= 1;  next:= 0;  la:= 0;
   d:= 1;

   # first close the congruence tables.
   for r in cong do
      eqnTrace(r);
   od;

   # loop over pending def'ns.
   repeat

      # loop over rel'ns.
      for r in rels do
         eqnTrace(r);
      od;

      if active > lanext then
                Info(SemigroupToddCoxeterInfo, 1, "Entering Lookahead");
                oldkilled:= defind - active;
        la:= d;
        repeat
          for r in rels do
            laTrace(r);
          od;
          la:= forwd[la];
        until la = next;
        Info(SemigroupToddCoxeterInfo, 1, "Lookahead done, ",
               (defind-active) - oldkilled," definitions saved");
         Info(SemigroupToddCoxeterInfo, 1, "#I  ", defind, " cosets, ",
                                                active, " active, ", defind - active, " killed.");
        if active > lanext then
          lanext:= lanext * 2;
        fi;
        la:= 0;
      fi;

      # proceed to next coset on active list.
      d:= forwd[d];

   until d = next;

   # print statistics.
   Info(SemigroupToddCoxeterInfo, 1, "#I  ", defind,
                " cosets defined, maximum ", Length(forwd), ", ", active, " survive.\n");

   # shrink coset table: trace coset 1 through |forwd|.
   occur:= 0;  pos:= [];  inver:= [];  i:= 0;  d:= 1;
   repeat
      i:= i+1;  pos[i]:= d;  inver[d]:= i;  d:= forwd[d];
   until d = next;

   # return final coset table.
   for i in gens do
      table[i]:= inver{table[i]{pos}};
   od;
   return table;

end);


############################################################################
##
#O  HomomorphismTransformationSemigroup(<S>,<r>)
#A  IsomorphismTransformationSemigroup(<S>)
##
##  As above the first case should become an attribute of <r>?
##

InstallMethod(IsomorphismTransformationSemigroup,
"<fp-semigroup>", true,
[IsFpSemigroup], 0,
function(S)
        return HomomorphismTransformationSemigroup(S,
                RightMagmaCongruenceByGeneratingPairs(S,[]));
end);


InstallMethod( HomomorphismTransformationSemigroup,
    "for an f.p. semigroup, and a right congruence",
    true,
    [ IsFpSemigroup, IsRightMagmaCongruence ],
    0,
function(S,r)
        local
        cotab,          # the coset table of the semigroup
        isofun,         # the function describing the isomorphism
        ts;             # the transformation semigroup

        if not S = Source(r) then
            TryNextMethod();
        fi;

        # make a transformation monoid on the congruence classes.
        cotab := CosetTableOfFpSemigroup(r);
        ts := Semigroup(List(cotab, Transformation));

        ########################################################
        # isofun:
        # The function which computes the isomorphism - take
        # the ith  generator of the fp semigroup to the
        # transformation whose image list is the ith row of the
        # multiplication table
        #
        isofun := function(x)
            local
                i,      # counter
                prod,   # accumulates the value of the image
                gensts, # generators of the transformation semigroup
                extr;   # ext rep of x

            extr := ExtRepOfObj(UnderlyingElement(x));
            gensts := GeneratorsOfSemigroup(ts);

            prod := One(Transformation(cotab[1]));
            for i in [1 .. Length(extr)/2] do
                prod  := prod * gensts[extr[2*i-1]]^extr[2*i];
            od;
            return prod;
        end;
        ########################################################
        # isofun end

        return MagmaHomomorphismByFunctionNC(S, ts, isofun);
end);
