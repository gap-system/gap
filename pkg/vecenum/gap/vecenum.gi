#############################################################################
####
##
#W  vecenum.gi                   Vecenum Package                 Steve Linton
##                                                             Maja Waldhausen
##
##  Implementation file for functions of the vecenum package.
##
#H  @(#)$Id: vecenum.gi,v 1.3 2006/07/05 11:36:58 sal Exp $
##
#Y  Copyright (C) 2002  University of St. Andrews, North Haugh,
#Y                          St. Andrews, Fife KY16 9SS, Scotland
##
Revision.("vecenum/gap/vecenum_gi") := 
    "@(#)$Id: vecenum.gi,v 1.3 2006/07/05 11:36:58 sal Exp $";



#
# A quick-and-dirty bare bones vector enumerator for GAP4
#
# How to use it: 
#
# gap> a := FreeAssociativeAlgebraWithOne(Integers,1);
# <free left module over Integers, and ring-with-one, with 1 generators>
# gap> r1 := 2*a.1 - One(a);
# (-1)*<identity ...>+(2)*x.1
# gap> r2 := a.1^7 - One(a);
# (-1)*<identity ...>+(1)*x.1^7
# gap> b := FactorFreeAlgebraByRelators(a,[r1,r2]);
# <algebra over Integers, with 2 generators>
# gap> m := b^1;
# ( <algebra over Integers, with 2 generators>^1 )
# gap> u := ME.create(m,[]);
# rec( 
#   table := [ rec( deleted := false, images := [  ], defin := [ [ [(1)*<identit\
# y ...>] ] ] ) ], fpalg := <algebra over Integers, with 2 generators>, 
#   ngens := 1, basering := Integers, one := 1, zero := 0, modrels := [  ], 
#   freemod := ( <algebra over Integers, with 2 generators>^1 ), 
#   compress := function( v ) ... end, coincs := [  ], 
#   isunit := function( x ) ... end, lattice := [  ], lpivots := [  ], 
#   lclosed := [  ] )
# gap> ME.run(u);
# gap> ME.extract(u);
# rec( mats := [ [ [ 64 ] ] ], ims := [ [ 1 ] ], 
#   preims := [ [ [(1)*<identity ...>] ] ], lattice := [ [ 127 ] ] )
#
# The second argument to ME.create is a list of elements of the free module
# passed as the first argument, which generate the submodule
#  quotiented out (that is a list of module relations)
# 
# The return values are the matrices giving the action of the
# generators of b. The images of the generators of m, the pre-images 
# of the basis in m and the fixed torsion lattice if relevant
#
# The underlying ring (ie the (LeftActingDomain)^2 of the first
# argument) needs to be either a field, or support IsUnit and Gcdex
#

if not IsBound(IsSparseRowVector) then
    ReadLib( "sparselist.gd"  );
    ReadLib( "sparselistgen.gi"  );
    ReadLib( "sparselistsorted.gi"  );
    ReadLib( "sparsevectorsorted.gi" );
fi;

InstallValue(ME,rec());


#
# A great slug of code for timing things. Very useful while developing
#

ME.TIME_CLASSES := [];
ME.TIME := rec();

ME.DeclareTimeClass := function(name)
    ME.TIME.(name) := Length(ME.TIME_CLASSES)+1;
    Add(ME.TIME_CLASSES,name);
end;


ME.stats := fail;

ME.SetupTiming := function(u)
    if u.opts.timing then
        u.StartTimer := function(cat)
            u.stats[cat] := u.stats[cat] - Runtime();
        end;

        u.StopTimer := function(cat)
            u.stats[cat] := u.stats[cat] + Runtime();
        end;

        u.IncCount := function(cat)
            u.stats[cat] := u.stats[cat] + 1;
        end;

        u.ResetStats := function()
            u.stats := ListWithIdenticalEntries(Length(ME.TIME_CLASSES),0);
        end;
        
        
        u.ResetStats();

        u.GetStats := function()
            local   r,  c;
            r := rec();
            for c in ME.TIME_CLASSES do
                r.(c) := u.stats[ME.TIME.(c)];
            od;
            return r;
        end;
    else
        u.StartTimer := function(cat)
            return;
        end;

        u.StopTimer := function(cat)
            return;
        end;

        u.IncCount := function(cat)
            return;
        end;

        u.ResetStats := function()
            return;
        end;

        u.GetStats := function()
            return fail;
        end;
    fi;
end;







ME.ScanRelationPass1 := function(u, rel)
    local   res,  er,  monom,  i,  j;
    res := rec(type := "alg", orig := rel);
    er := ExtRepOfObj(rel)[2];
    res.extrep := er;
    # we're interested in binomials 
    if Length(er) <> 4 then
        return res;
    fi;
    #specifically when one of the terms is a unit of the ground ring
    # and the coefficient of the other one is its negative
    if not (u.isunit(er[2]) and u.isunit(er[4]) and IsZero(er[2]+er[4])) then
        return res;
    fi;
    if er[1]= [] then
        monom := er[3];
    elif er[3] = [] then
        monom := er[1];
    else
        return res;
    fi;
    #
    # OK. So now the relation basically says that monom is 1.
    #
    res.type := "monoid";
    res.word := [];
    for i in [1,3..Length(monom)-1] do
        for j in [1..monom[i+1]] do
            Add(res.word, monom[i]);
        od;
    od;
    #
    # Does it give us an inverse for a generator?
    #
    if Length(res.word) = 2 then
        u.inverses[res.word[1]] := res.word[2];
        u.inverses[res.word[2]] := res.word[1];
        res.type := "group";
        return res;
    else
        return res;
    fi;
end;
        

    
ME.ScanRelationPass2 := function(u,rel)
    local   i;
    if rel.type = "monoid" and 
       ForAll(rel.word, l -> IsBound(u.inverses[l])) then
        rel.type := "group";
    fi;
    return;
end;



  

ME.Image1 := function( u, b, gen, maydefine)
    local   v,  next;
    Assert(2, u.table[b].deleted = false);
    v := ME.getent(u,b,gen);
    if v <> fail then
        return v;
    elif maydefine then
        next := Length(u.table)+1;
        u.alive := u.alive+1;
        u.table[next] := rec( deleted := false,
                                images := [],
                                defin := ShallowCopy(u.table[b].defin));
        Add(u.table[next].defin, gen);
        v := ME.unitvec(u,next);
        u.table[b].images[gen] := v;
        if u.opts.defineInverses and IsBound(u.inverses[gen]) then
            u.table[next].images[u.inverses[gen]] := ME.unitvec(u,b);
        fi;
        return v;
    else
        return fail;
    fi;
end;

ME.unitvec := function(u,b) 
    local   l;
    if u.sparse then
        l := SparseVectorBySortedListNC([b],[u.one],b);
    else
        l := ListWithIdenticalEntries(b-1, u.zero);
        Add(l,u.one);
    fi;
    l := u.compress(l);
    return l;
end;

ME.zerovec := function(u)
    return ShallowCopy(u.zerovec);
end;    

ME.defaultOpts := rec( useMonoidRels := true,
                       defineInverses := true,
                       sparse := "not8bit",
                       lookahead := true,
                       lookaheadChunk := 20,
                       lookaheadEvery := 100,
                       packThreshold := 3/2,
                       timing := false);
                      

ME.create := function( arg )
    local   u,  n,  freemod,  modrels,  q,  r;
    if Length(arg) < 2 or Length(arg) > 3 then
        Error("Usage ME.create(<freemod>, <modrels> [,<options-record>])");
    fi;
    u := rec();
    u.opts := ME.defaultOpts;
    if Length(arg) = 3 then
        for n in RecNames(arg[3]) do
            u.opts.(n) := arg[3].(n);
        od;
    fi;
    freemod := arg[1];
    modrels := arg[2];
    u.nmodgens := Length(GeneratorsOfLeftModule(freemod));
    u.table := List(GeneratorsOfLeftModule(freemod), 
                    m -> rec( deleted 
                            := false, images := [], defin := [m]));
    u.alive := u.nmodgens;
    u.fpalg := LeftActingDomain(freemod);
    u.ngens := Length(FreeGeneratorsOfFpAlgebra(u.fpalg));
    u.basering := LeftActingDomain(u.fpalg);
    u.one := One(u.basering);
    u.zero := Zero(u.basering);
    u.modrels := modrels;
    u.freemod := freemod;
    u.compress := function(v) return v; end;
    u.coincs := [];
    u.inverses := [];
    if u.opts.sparse <> "always" and IsFFECollection(u.basering) and IsField(u.basering) then
        q := Size(u.basering);
        if q <= 256 then
            u.compress := function(v) ConvertToVectorRep(v,q); return v; end;
            u.sparse := false;
        else
            u.sparse := u.opts.sparse <> "never";
        fi;
    else
        u.sparse := u.opts.sparse <> "never";
    fi;
       
    
    if u.sparse then
        u.zerovec := SparseVectorBySortedListNC([],[],1,u.zero);
    else
        u.zerovec := [u.zero];
    fi;
    u.zerovec := u.compress(u.zerovec);
    if IsField(u.basering) then
        u.isunit := ReturnTrue;
    else
        u.isunit := x->IsUnit(u.basering, x);
        u.lattice := [];
        u.latticebyage := [];
        u.lclosed := 0;
        if u.basering = Integers then
            u.gcd := Gcdex;
        else
            u.gcd := ME.generalGcdEx;
        fi;
    fi;
    
    u.arels := List(RelatorsOfFpAlgebra(u.fpalg), r -> ME.ScanRelationPass1(u,r));
    for r in u.arels do
        ME.ScanRelationPass2(u,r);
    od;
    
    u.barrier := u.opts.lookaheadEvery;
    ME.SetupTiming(u);
    return u;
end;

ME.getent := function(u, b, gen)
    local   v;
    if not IsBound(u.table[b].images[gen]) then
        return fail;
    fi;
    v := u.table[b].images[gen];
    ME.root(u,v);
    return v;
end;

ME.root := function(u,v)
    local   i,  x,  r;
    i := PositionNot(v,u.zero);
    while i <= Length(v) do
        if u.table[i].deleted then
            x := v[i];
            v[i] := u.zero;
            r := u.table[i].replacement;
            ME.root(u,r);
            AddCoeffs(v,r,x);
        fi;
        i := PositionNot(v,u.zero,i);
    od;
end;

ME.Image2 := function(u, v, gen, maydefine)
    local   res,  i,  x, im;
    res := ME.zerovec(u);
    i := 0;
    i := PositionNot(v,u.zero,i);
    while i <= Length(v) do
        x := v[i];
        im := ME.Image1(u,i,gen,maydefine);
        if im = fail then
            return fail;
        fi;
        AddCoeffs(res, im, x);
        i := PositionNot(v,u.zero,i);
    od;
    return res;
end;

ME.Image3 := function(u, v, er, maydefine)
    local   res,  i,  mon,  coeff,  w,  j,  k;
    res := ME.zerovec(u);
    for i in [1,3..Length(er)-1] do
        mon := er[i];
        coeff := er[i+1];
        w := v*coeff;
        for j in [1,3..Length(mon)-1] do
            for k in [1..mon[j+1]] do
                w := ME.Image2(u,w,mon[j],maydefine);
                if w = fail then
                    return fail;
                fi;
            od;
        od;
        AddCoeffs(res , w);
    od;
    return res;
end;

ME.TraceMonoidRel := function(u, v, word, mayreverse, maydefine)
    local   w1,  i1,  res,  w2,  i2;
    w1 := v;
    w2 := v;
    i1 := 1;
    while true do
        res := ME.Image2(u, w1, word[i1], maydefine and not mayreverse);
        if res = fail then
            break;
        fi;
        w1 := res;
        i1 := i1+1;
        if i1 > Length(word) then
            break;
        fi;
    od;
    if res = fail and mayreverse then
        i2 := Length(word);
        while true do
            res := ME.Image2(u, w2, u.inverses[word[i2]], maydefine);
            if res = fail then
               return fail;
            fi;
            w2 := res;
            i2 := i2-1;
            if i1-1  = i2 then
                break;
            fi;
        od;
    fi;
    Add(u.coincs,w1-w2);
    return true;
end;

ME.head := function(u, v)
    local   i, ss;
    if u.sparse and IsSparseListBySortedListRep(v) and IsSparseRowVector(v) then
        ss := SparseStructureOfList(v);
        if Length(ss[2]) = 0 then
            return -1; 
        else
            return ss[2][Length(ss[2])];
        fi;
    else
        for i in [Length(v), Length(v)-1..1] do
            if v[i] <> u.zero then
                return i;
            fi;
        od;
        return -1;
    fi;
end;

ME.coinc := function( u, c)
    local   h,  i,  v,  w;
    h := ME.head(u,c);
    if h = -1 then return; fi;
    if not u.isunit(c[h]) then
        ME.handleInapplicable(u,c);
        return;
    fi;
    MultRowVector(c,-Inverse(c[h]));
    c[h] := u.zero;
    for i in [1..Length(u.table[h].images)] do
        if IsBound(u.table[h].images[i]) then
            v := u.table[h].images[i];
            ME.root(u,v);
            w := ME.Image2(u, c, i, true);
            AddCoeffs(w, v, -u.one);
            Add(u.coincs,  w);
        fi;
    od;
    Unbind(u.table[h].images);
    Unbind(u.table[h].defin);
    u.table[h].deleted := true;
    u.table[h].replacement := c;
    u.alive := u.alive -1;
    if IsBound(u.lattice) then
        ME.applyCoincToLattice(u,h);
    fi;
    return;
end;



ME.clearcoincs := function(u)
    local   c;
    while Length(u.coincs) > 0 do
        c := u.coincs[Length(u.coincs)];
        Unbind(u.coincs[Length(u.coincs)]);
        ME.root(u,c);
        ME.coinc(u,c);
    od;
end;
    
ME.ImageModRel := function(u,mr)
    local   res,  i,  x;
    res := ME.zerovec(u);
    for i in [1..Length(mr)] do
        x := ME.unitvec(u, i);
        ME.root(u,x);
        AddCoeffs(res , ME.Image3(u, x, ExtRepOfObj(mr[i])[2], true));
    od;
    return res;
end;

ME.pushrow := function(u,rownum, lookahead)
    local   row,  v,  r,  x;
    row := u.table[rownum];
    if not row.deleted then
        if lookahead then
            Print("looking ahead");
        else
            Print("pushing ");
        fi;
        Print("at ",rownum," of ",Length(u.table)," \c");
        v := ME.unitvec( u, rownum);
        for r in u.arels do
            if not u.opts.useMonoidRels or r.type = "alg" then
                Print(".\c");
                x := ME.Image3(u, v, r.extrep, not lookahead);
                if x <> fail then
                    Add(u.coincs,x);
                fi;
            else
                Print(",\c");
                Assert(1,r.type in ["group","monoid"]);
                ME.TraceMonoidRel(u,v, r.word, r.type = "group", not lookahead);
            fi;
            
            ME.clearcoincs(u);
            if  row.deleted then
                break;
            fi;
            Assert(1,ForAll(u.lattice, l -> not u.table[l.pivot].deleted and not IsZero(l.vector[l.pivot])));
        od;
        Print(" ",u.alive, " alive\n");
    fi;
end;


    

ME.run := function(u)
    local   mr,  lcurr;
    for mr in u.modrels do
        Add(u.coincs, ME.ImageModRel( u, mr));
        ME.clearcoincs(u);
    od;
    u.curr := 1;
    while u.curr <= Length(u.table) do
        ME.pushrow(u,u.curr,false);
        Assert(1,ForAll(u.lattice, l->not IsZero(l.vector)));
        ME.closelatt(u);
        Assert(1,ForAll(u.lattice, l->not IsZero(l.vector)));
        u.curr := u.curr + 1;
        if Length(u.table) > u.opts.packThreshold*u.alive then
            ME.pack(u);
        fi;
        if u.opts.lookahead and Length(u.table) > u.barrier then
            lcurr := u.curr;
            while lcurr < u.curr+u.opts.lookaheadChunk and lcurr <= Length(u.table) do
                ME.pushrow(u,lcurr,true);
        Assert(1,ForAll(u.lattice, l->not IsZero(l.vector)));
                lcurr := lcurr+1;
            od;
            u.barrier := u.barrier + u.opts.lookaheadEvery;
        fi;
    od;
    while ME.closelatt(u) do
        od;
    return;
end;

ME.subvec := function(u, poss, v)
    local   ss,  iposs,  ivals,  oposs,  ovals,  i,  j,  x,  y,  l1,  
            l2;
    if u.sparse then
        ss := SparseStructureOfList(v);
        iposs := [];
        ivals := [];
        oposs := ss[2];
        ovals := ss[3];
        l1 := Length(oposs);
        l2 := Length(poss);
        if l2 = 0 then
            return [];
        fi;
        if l1 > 0  then
            i := 1;
            j := 1;
            x := oposs[i];
            y := poss[i];
            while true do
                if x < y then
                    i := i+1;
                    if i > l1 then
                        break;
                    fi;
                    x := oposs[i];
                elif y < x then
                    j := j+1;
                    if j > l2 then
                        break;
                    fi;
                    y := poss[j];
                else
                    Add(iposs,j);
                    Add(ivals,ovals[i]);
                    i := i+1;
                    if i > l1 then
                        break;
                    fi;
                    j := j+1;
                    if j > l2 then
                        break;
                    fi;
                    x := oposs[i];
                    y := poss[j];
                fi;
            od; 
        fi;
            
            
        return SparseVectorBySortedListNC(iposs,ivals,l2,u.zero);
    else
        return u.compress(List(poss, function (i) 
            if IsBound(v[i]) then 
                return v[i]; 
            else
                return u.zero; 
            fi; 
        end));
    fi;
end;

ME.pack := function(u)
    local   row,  i,  rowstokeep,  map,  r;
    #
    # First lets clean everything.
    #
    # lattice vectors are kept clean.
    #
    for row in u.table do
        if not row.deleted then
            for i in [1..u.ngens] do
                if IsBound(row.images[i]) then
                    ME.root(u,row.images[i]);
                fi;
            od;
        else
            ME.root(u,row.replacement);
        fi;
    od;
    Assert(1,Length(u.coincs) = 0);
    #
    # OK now rename the basis
    #
    rowstokeep := Filtered([1..Length(u.table)], i-> (i <= u.nmodgens) or not u.table[i].deleted);
    map := [];
    for i in [1..Length(rowstokeep)] do
        map[rowstokeep[i]] := i;
    od;
    
    u.table := u.table{rowstokeep};
    for row in u.table do
        if not row.deleted then
            for i in [1..u.ngens] do
                if IsBound(row.images[i]) then
                    row.images[i] := ME.subvec(u, rowstokeep, row.images[i]);
                fi;
            od;
        fi;
    od;
    
    #
    # and fixup the lattice
    #
    if IsBound(u.lattice) then
        for r in u.lattice do
            r.vector := ME.subvec(u,rowstokeep,r.vector);
            Assert(1, not IsZero(r.vector));
            r.pivot := map[r.pivot];
        od;
    fi;
    #
    # and the current row
    #
    
    u.curr := PositionSorted(rowstokeep,u.curr);
end;
    

ME.extract := function(u)
    local   subvec,  poss,  i,  j,  r,  x,  agens,  p,  p1;
    poss := Filtered([1..Length(u.table)], i-> u.table[i].deleted = false);
    for i in poss do
        for j in [1..u.ngens] do
            ME.root(u,u.table[i].images[j]);
        od;
    od;
    r := rec( mats :=  
              List([1..u.ngens], gen ->
                   List(poss, i-> ME.subvec( u, poss, u.table[i].images[gen]))),
                           ims := [],
                           preims := []);
                         
   for i in [1..u.nmodgens] do
       x := ME.unitvec(u,i);
       ME.root(u,x);
       Add(r.ims, ME.subvec(u, poss, x));
   od;
   agens := GeneratorsOfFLMLOR(u.fpalg);
   agens := agens{[2..Length(agens)]};
   for i in poss do
       p := u.table[i].defin;
       p1 := p[1];
       for j in [2..Length(p)] do
           p1 := p1*agens[p[j]];
       od;
       Add(r.preims,p1 );
   od;
   if IsBound(u.lattice) then
       r.lattice := List(u.lattice, l -> ME.subvec(u, poss, l.vector));
   fi;
   return r;
end;
    

ME.deleteFromLattice := function(u,lrec)
    local   l,  i;
    l := lrec.latposs;
    Remove(u.lattice,l);
    for i in [l..Length(u.lattice)] do
        u.lattice[i].latposs := i;
    od;
    l := lrec.possbyage;
    Remove(u.latticebyage, l);
    for i in [l .. Length(u.latticebyage)] do
        u.latticebyage[i].possbyage := i;
    od;
    if u.lclosed >= l then
        u.lclosed :=  u.lclosed -1;
    fi;
    return;
end;

ME.generalGcdEx :=  function(m,n)
    local   f, g, h, fm, gm, hm, q, qr;
    f := StandardAssociate(m);
    fm := f/m;
    g := StandardAssociate(n);
    gm := 0;
    while not IsZero(g) do
        qr := QuotientRemainder( f, g );
        q := qr[1];
        h := g;          hm := gm;
        g := qr[2];      gm := fm - q * gm;
        f := h;          fm := hm;
    od;
    if IsZero(n)  then
        return rec( gcd := f, coeff1 := fm, coeff2 := Zero(m),
                              coeff3 := gm, coeff4 := One(m) );
    else
        return rec( gcd := f, coeff1 := fm, coeff2 := (f - fm * m) / n,
                              coeff3 := gm, coeff4 := (- gm * m) / n );
    fi;
end;


ME.handleInapplicable := function( u, v)
    local   h,  l,  lrec,  x,  y,  g,  v1,  v2,  i;
    h := ME.head(u,v);
    # Maja does ME.root(u,v) here -- can it ever do anything
    l := 1;
    while l <= Length(u.lattice) do
#        if v[h] < 0 then
#            v := -v;
#        fi;
        lrec := u.lattice[l];
        
        if lrec.pivot < h then
            Add(u.lattice,rec(vector := v, 
                              pivot := h, 
                              latposs := l, 
                                        possbyage := Length(u.latticebyage)+1),l);
            for i in [l+1..Length(u.lattice)] do
                u.lattice[i].latposs := i;
            od;
            Add(u.latticebyage,u.lattice[l]);
            return;
        elif lrec.pivot = h then
            x := lrec.vector[h];
            y := v[h];
            g := u.gcd(x,y);
            v1 := g.coeff1*lrec.vector;
            AddCoeffs(v1, v, g.coeff2);
            v2 := g.coeff3*lrec.vector;
            AddCoeffs(v2,v,g.coeff4);
            Assert(1, v1[h] = g.gcd);
            Assert(1, v2[h] = u.zero);
            if u.isunit(g.gcd) then
                Add(u.coincs, v1);
                ME.deleteFromLattice(u,lrec);
                l := l-1;
            else
                lrec.vector := v1;
                if g.gcd <> x then
                    # v1 is now newest in lattice
                    Remove(u.latticebyage, lrec.possbyage);
                    for i in [lrec.possbyage .. Length(u.latticebyage)] do
                        u.latticebyage[i].possbyage := i;
                    od;
                    if u.lclosed >= lrec.possbyage then
                        u.lclosed :=  u.lclosed -1;
                    fi;
                    Add(u.latticebyage, lrec);
                    lrec.possbyage := Length(u.latticebyage);
                fi;
            fi;
            v := v2;
            h := ME.head(u,v);
            if h = -1 then
                return;
            fi;
            if u.isunit(v[h]) then
                Add(u.coincs, v);
                return;
            fi;
        fi;
        l := l+1;
    od;
    lrec := rec(vector := v,
                pivot := h,
                latposs := Length(u.lattice)+1,
                possbyage := ~.latposs);
    Add(u.lattice,lrec); 
    Add(u.latticebyage, lrec);
    return;
end;
          
              
ME.closelatt := function(u)
    local   lrec,  g;
    if not IsBound(u.lattice) then
        return false;
    fi;
    if u.lclosed = Length(u.lattice) then
        return false;
    fi;
    lrec := u.latticebyage[u.lclosed+1];
    for g in [1..u.ngens] do
        ME.root(u, lrec.vector);
        Add(u.coincs, ME.Image2( u, lrec.vector, g, true));
    od;
    u.lclosed := u.lclosed+1;
    ME.clearcoincs(u);
    return true;
end;

ME.applyCoincToLattice := function( u, h)
    local   l,  lrec;
    l := 1;
    while l <= Length(u.lattice) do
        lrec := u.lattice[l];
        if IsBound(lrec.vector[h]) and
           lrec.vector[h] <> u.zero then
            ME.root(u, lrec.vector);
            if h = lrec.pivot then
                Add(u.coincs, lrec.vector);
                ME.deleteFromLattice(u, lrec);
                l := l-1;
            else
                Assert(1, not IsZero(lrec.vector));
            fi;
        fi;
        l := l+1;
    od;
end;


ME.processLatt := function(u, f)
    local   vecs,  n,  v,  i;
    vecs := List(u.lattice,x->x.vector);
    if Length(vecs) = 0 then
        return;
    fi;
    n := Maximum(List(vecs,Length));
    for v in vecs do
        for i in [n,n-1..Length(v)+1] do
            v[i] := u.zero;
        od;
    od;
#    Print("processed ",vecs," to \c");
    vecs := f(vecs);
#    Print(vecs,"\n");
    u.lattice := [];
    u.latticebyage := [];
    u.lclosed := 0;
    Append(u.coincs, vecs);
    ME.clearcoincs(u);
    return;
end;

#
# Function useful for constructing examples
#

InstallGlobalFunction(FpAlgebraByFpGroup, function( arg )
    local   ring,  fpgrp,  gens,  ngens,  xgens,  rels,  invmap,  i,  
            names,  freealg,  agens,  af,  arels,  r,  er,  aer,  fpa,  
            module,  mf,  submodgens,  subgp,  subgens;
    ring := arg[1];
    fpgrp := arg[2];
    gens := FreeGeneratorsOfFpGroup( fpgrp );
    ngens := Length(gens);
    if ngens = 0 then 
        return FreeAssociativeAlgebraWithOne(ring,[]);
    fi;
    xgens := ngens;
    rels := RelatorsOfFpGroup(fpgrp);
    invmap := [];
    for i in [1..ngens] do
        if gens[i]^2 in rels then
            invmap[i] := i;
        else
            xgens := xgens + 1;
            invmap[i] := xgens;
            invmap[xgens] := i;
        fi;
    od;
    names := ShallowCopy(FamilyObj(gens[1])!.names);
    for i in [ngens+1..xgens] do
        Add(names, Concatenation(names[invmap[i]],"i"));
    od;
    freealg := FreeAssociativeAlgebraWithOne(ring, names);
    agens := GeneratorsOfAlgebraWithOne(freealg);
    af := FamilyObj(agens[1]);
    arels := [];
    for i in [1..xgens] do
        if invmap[i] <> i then
            Add(arels, agens[i]*agens[invmap[i]] - One(freealg));
        fi;
    od;
    for r in rels do
        er := ExtRepOfObj(r);
        aer := [];
        for i in [1,3..Length(er)-1] do
            if er[i+1] < 0 then
                Add(aer,invmap[er[i]]);
                Add(aer, - er[i+1]);
            else
                Add(aer, er[i]);
                Add(aer, er[i+1]);
            fi;
        od;
        aer := [Zero(ring),[aer, -One(ring), [],One(ring)]];
        Add(arels, ObjByExtRep(af,aer));
    od;
    fpa := FactorFreeAlgebraByRelators(freealg, arels);
    submodgens := [];
    if Length(arg) > 2 then
        subgp := arg[3];
        subgens := List(GeneratorsOfGroup(subgp), h -> ExtRepOfObj(UnderlyingElement(h))) ;
        for er in subgens do
            aer := [];
            for i in [1,3..Length(er)-1] do
                if er[i+1] < 0 then
                    Add(aer,invmap[er[i]]);
                    Add(aer, - er[i+1]);
                else
                    Add(aer, er[i]);
                    Add(aer, er[i+1]);
                fi;
            od;
            aer := [Zero(ring),[aer, -One(ring), [],One(ring)]];
            Add(submodgens, [ObjByExtRep(af,aer)]);
        od;
        return [fpa, submodgens];
    else
        return fpa;
    fi;
end);
    
#E ends here        
