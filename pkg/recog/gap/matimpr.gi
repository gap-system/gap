#############################################################################
##
##  matimpr.gi        recog package                       Max Neunhoeffer
##                                                         Alice Niemeyer
##                                                            Ákos Seress
##
##  Copyright 2005 Lehrstuhl D f Mathematik, RWTH Aachen
##
##  Find an imprimitive action of a matrix group.
##  This should better be (and is now) called "LowIndex".
##
##  $Id: matimpr.gi,v 1.20 2006/10/11 03:30:27 gap Exp $
##
#############################################################################

#############################################################################
##
#F  OrbitSubspaceWithLimit( <grp>, <U>, <max> ) . . . . . . orbit of subspace
##
##  Compute the orbit of a subspace but return fail if the orbit has
##  more than <max> elements.
##
RECOG.OrbitSubspaceWithLimit := function( grp, U, max )

    local   orb,  orbset, new,  pnt,  img,  gen, gens;
  
    gens := GeneratorsOfGroup(grp);

    # start with the singleton orbit
    orb := [ U ];
    orbset := [ U ];

    # loop over all points found
    for pnt  in orb  do

        # apply all generators <gen>
        for gen  in gens  do
            img := OnSubspacesByCanonicalBasis( pnt, gen );

            # add the image <img> to the orbit if it is new
            # can perhaps be improved (is now)
            if not img in orbset then
                Add( orb, img );
                AddSet( orbset, img );
                if Length(orb) > max then return fail; fi;
            fi;

        od;

    od;
    return orbset;
end;

#
#  Test if the module hm already has a submodule with a
#  short enough orbit.
#  Note: We can tweak what ``short enough" means. I set it to 4d,
#  but if we make it smaller it will speed up the code.
#

RECOG.IndexMaxSub := function( hm, grp, d )
    # Call this function only with a reducible module hm!
    local dim,dimnew,f,i,lastorb,lastsub,orb,sp,spnew,sub,subdim;

    # Here is the invariant subspace
    sub := MTX.ProperSubmoduleBasis(hm);
    sub := MutableCopyMat( sub );  # make mutable copy
    # FIXME: this will be unnecessary:
    ConvertToMatrixRep(sub);
    lastsub := fail;
    lastorb := fail;
    repeat
        TriangulizeMat(sub); # Find Hermite Normal Form
        #orb := RECOG.OrbitSubspaceWithLimit(grp, sub, 4 * d );
        orb := Orb(grp,sub,OnSubspacesByCanonicalBasis,
                   rec(storenumbers := true, hashlen := NextPrimeInt(8*d)));
        Enumerate(orb,4*d);
        if not(IsClosed(orb)) then
            Info(InfoRecog,1,"Did not find nice orbit.");
            if lastsub = fail then return fail; fi;
            return rec( orb := lastorb,
                        hom := OrbActionHomomorphism(grp,lastorb) );
        fi;
        Info(InfoRecog,1,"Found orbit of length ",Length(orb),
             " of subspaces of dimension ",Length(orb[1]),".");
        subdim := Length(orb[1]);
        if subdim * Length(orb) = d or    # have block system!
           subdim = 1 then                # no hope in this case
            return
                rec(orb := orb,
                    hom := OrbActionHomomorphism(grp,orb));
        fi;
        # we try intersecting the subspaces in the orbit:
        Info(InfoRecog,1,"Calculating intersections...");
        f := FieldOfMatrixGroup(grp);
        sp := VectorSpace(f,orb[1]);
        dim := Dimension(sp);
        for i in [2..Length(orb)] do
            spnew := Intersection(sp,VectorSpace(f,orb[i]));
            dimnew := Dimension(spnew);
            if dimnew > 0 and dimnew < dim then
                sp := spnew;
                dim := dimnew;
            fi;
        od;
        Info(InfoRecog,1,"Got subspace of dimension ",Dimension(sp));
        if dim = Length(sub) then   # we got nothing new
            Info(InfoRecog,1,"That we already knew, giving up.");
            return
                rec(orb := orb,
                    hom := OrbActionHomomorphism(grp,orb));
        fi;
        lastsub := sub;
        lastorb := orb;
        sub := MutableCopyMat(AsList(Basis(sp)));
        # FIXME: This will vanish:
        ConvertToMatrixRep(sub);
    until false;
end;

RECOG.SmallHomomorphicImageProjectiveGroup := function ( grp )

    local hm, findred, ans, fld, d, i, gens;

    fld := FieldOfMatrixGroup(grp);
    d := DimensionOfMatrixGroup(grp);

    findred := function( gens )
      local hm,i,j,res;
      i := Length(gens)+1;
      for j in [1..d] do
          gens[i] := PseudoRandom(grp);
          hm := GModuleByMats(gens,fld);
          if not MTX.IsIrreducible(hm) then
              res := RECOG.IndexMaxSub( hm, grp, d );
              if res <> fail then return [res, gens]; fi;
              if i < LogInt(d,2) then
                  res := findred(gens);
                  if res = false then return false; fi;
                  if res <> fail then return res; fi;
              fi;
          fi;
      od;
      return false;   # go out all the way without success
    end;
    
    Info(InfoRecog,1,"Trying 10 first elements...");
    for i in [1..10] do   # this is just heuristics!
        gens := [PseudoRandom(grp)];
        hm := GModuleByMats(gens,fld);
        if not MTX.IsIrreducible(hm) then
            ans := findred( gens );
            if ans <> fail and ans <> false then
                return ans;
            fi;
        fi;
        if InfoLevel(InfoRecog) >= 1 then Print(".\c"); fi;
    od;
    if InfoLevel(InfoRecog) >= 1 then Print("\n"); fi;

    return fail;
end;

RECOG.ParseNumber := function( number, d, default )
  if IsInt(number) then 
      return number; 
  fi;
  if IsString(number) then
      if number = "logd" then return LogInt(d,2); fi;
      if number[Length(number)] = 'd' then
          return d * Int(number{[1..Length(number)-1]});
      fi;
  fi;
  return default;
end;

InstallGlobalFunction( DoHintedLowIndex, function(ri,G,hint)
  local bas,d,fld,gens,hm,hom,i,numberrandgens,orb,orblenlimit,s,
        tries,triesinner,triesinnerlimit,trieslimit,x,y;

  Info(InfoRecog,1,"Got hint for group, trying LowIndex...");

  fld := FieldOfMatrixGroup(G);
  d := DimensionOfMatrixGroup(G);
  if IsBound(hint.elordersstart) then
      repeat
          x := PseudoRandom(G);
      until Order(x) in hint.elordersstart;
      x := [x];
  else
      x := [];
  fi;

  tries := 0;
  numberrandgens := RECOG.ParseNumber(hint.numberrandgens,d,2);
  triesinnerlimit := RECOG.ParseNumber(hint.triesforgens,d,"1d");
  trieslimit := RECOG.ParseNumber(hint.tries,d,10);
  orblenlimit := RECOG.ParseNumber(hint.orblenlimit,d,"4d");
  Info(InfoRecog,2,"Using numberrandgens=",numberrandgens,
       " triesinnerlimit=",triesinnerlimit," trieslimit=",trieslimit,
       " orblenlimit=",orblenlimit);
  
  repeat
      gens := ShallowCopy(x);
      triesinner := 0;
      if numberrandgens = Length(gens) then   # we have to make the hm module
          hm := GModuleByMats(gens,fld);
          if MTX.IsIrreducible(hm) then
              tries := tries + 1;
              continue;
          fi;
      else
          while Length(gens) < numberrandgens and 
                triesinner < triesinnerlimit do
              y := PseudoRandom(G);
              Add(gens,y);
              triesinner := triesinner + 1;
              hm := GModuleByMats(gens,fld);
              if MTX.IsIrreducible(hm) then
                  Unbind(gens[Length(gens)]);
              fi;
          od;
      fi;
      if Length(gens) = numberrandgens then
          # We hope to have the maximal subgroup!
          bas := [MTX.ProperSubmoduleBasis(hm)];
          s := bas[1];
          while s <> fail do
              hm := MTX.InducedActionSubmodule(hm,s);
              s := MTX.ProperSubmoduleBasis(hm);
              Add(bas,s);
          od;
          Unbind(bas[Length(bas)]);
          s := bas[Length(bas)];
          for i in [Length(bas)-1,Length(bas)-2..1] do
              s := s * bas[i];
          od;
          # Now s is the basis of a minimal submodule, permute that:
          s := MutableCopyMat(s);
          TriangulizeMat(s);
          # FIXME: this will be unnecessary:
          ConvertToMatrixRep(s);
          Info(InfoRecog,1,"Found invariant subspace of dimension ",
               Length(s),", enumerating orbit...");
          if not IsBound(hint.subspacedims) or 
             Length(s) in hint.subspacedims then
              #orb := RECOG.OrbitSubspaceWithLimit(G,s,orblenlimit);
              orb := Orb(G,s,OnSubspacesByCanonicalBasis,
                         rec(storenumbers := true, 
                             hashlen := NextPrimeInt(2*orblenlimit)));
              Enumerate(orb,orblenlimit);
              if IsClosed(orb) then
                  hom := OrbActionHomomorphism(G,orb);
                  if Length(s) * Length(orb) = d then
                      # A block system!
                      forkernel(ri).t := Concatenation(orb);
                      forkernel(ri).blocksize := Length(s);
                      Add(forkernel(ri).hints,
                  rec(method:=FindHomMethodsProjective.DoBaseChangeForBlocks, 
                            rank := 2000, stamp := "DoBaseChangeForBlocks"),1);
                      Setimmediateverification(ri,true);
                      findgensNmeth(ri).args[1] := Length(orb)+20;
                      Info(InfoRecog,1,"Found block system with ",
                           Length(orb)," blocks.");
                  else
                      Info(InfoRecog,1,"Found orbit of length ",
                           Length(orb)," - not a block system.");
                  fi;
                  Sethomom(ri,hom);
                  Setmethodsforfactor(ri,FindHomDbPerm);
                  return true;
              fi;
          else
              Info(InfoRecog,1,"Subspace dimension not as expected, ",
                   "not enumerating orbit.");
          fi;
      fi;
      tries := tries + 1;
  until tries > trieslimit;
  return fail;
end );
  
# We start a database of hints, whenever we discover a certain group, we
# can ask this database what to do:

RECOG.SimplesHints := rec();

InstallGlobalFunction( InstallLowIndexHint,
  function( name, type, re )
    if not(IsBound(RECOG.SimplesHints.(name))) then
        RECOG.SimplesHints.(name) := [];
    fi;
    re.type := "LowIndexHint";
    Add( RECOG.SimplesHints.(name),re );
  end );

InstallLowIndexHint( "HS", "LowIndexHint",
  rec( characteristics := [2], degreedivs := [20,56,132,518,896,1000,1408],
       elordersstart := [11], numberrandgens := 2, tries := 10,
       triesforgens := 300,
       subspacedims := [1,10,34,70], orblenlimit := 100 ) );
InstallLowIndexHint( "HS", "LowIndexHint",
  rec( characteristics := [3], degreedivs := [22,77,154],  # more?
       elordersstart := [11], numberrandgens := 2, tries := 10,
       triesforgens := 300,
       subspacedims := [1,21,45,49,55,99], orblenlimit := 100 ) );
# degreeupperlimit optionally
# degreelowerlimit optionally
# subspacedims there or not
# elordersstart unbound ==> start with empty generator list
# if numberrandgens = "logd" then it will use LogInt(d,2)
# if triesforgens = "Xd" then it will use X * d (X a number as a string)
# if orblenlimit = "Xd" then it will use X * d (X a number as a string)
# L2 hint with doing the decision on the fly
#   depending on the ppd-Properties of L2(p)
# This means:
#   rec( numberrandgens := "logd", tries := 10, triesforgens := "1d",
#        orblenlimit := "4d" )
# is the standard low index.

InstallLowIndexHint( "L2(31)", "LowIndexHint",
  rec( characteristics := true, degrees := [1,2,3],
       elordersstart := [31], numberrandgens := 2, tries := 1,
       triesforgens := 100, orblenlimit := 32 ) );

InstallGlobalFunction( LookupHintForSimple, 
  function(ri,G,name)
    local dim,f,hi,j,p,q;
    Info(InfoRecog,2,"Looking up hints for ",name,"...");
    if IsBound(RECOG.SimplesHints.(name)) then
        j := 1;
        hi := RECOG.SimplesHints.(name);
        f := DefaultFieldOfMatrixGroup(G);
        p := Characteristic(f);
        q := Size(f);
        dim := DimensionOfMatrixGroup(G);
        while j <= Length(hi) do
            if (not(IsBound(hi[j].characteristics)) or 
                p in hi[j].characteristics) and 
               (not(IsBound(hi[j].degreedivs)) or 
                ForAny(hi[j].degreedivs,d->dim mod d = 0)) and
               (not(IsBound(hi[j].degreeupperlimit)) or
                dim <= hi[j].degreeupperlimit) and
               (not(IsBound(hi[j].degreelowerlimit)) or
                dim >= hi[j].degreelowerlimit) then
                # This hint is applicable!
                if hi[j].type = "LowIndexHint" then
                    return DoHintedLowIndex(ri,G,hi[j]);
                # Put other hint types here!
                fi;
            fi;
            j := j + 1;
        od;
    fi;
    Info(InfoRecog,2,"No hint worked, giving up.");
    return fail;
  end );


FindHomMethodsProjective.LowIndex := function(ri,G)
  local res;
  res := RECOG.SmallHomomorphicImageProjectiveGroup(G);
  if res = fail then
      return fail;
  else
      res := res[1];
      # Now distinguish between a block system and just an orbit:
      if Length(res.orb) * Length(res.orb[1]) <> DimensionOfMatrixGroup(G) then
          Info(InfoRecog,1,"Found orbit of length ",Length(res.orb),
               " - not a block system.");
      else
          Info(InfoRecog,1,"Found block system with ",Length(res.orb),
               " blocks.");
          # A block system: We do a base change isomorphism:
          forkernel(ri).t := Concatenation(res.orb);
          forkernel(ri).blocksize := Length(res.orb[1]);
          Add(forkernel(ri).hints, 
              rec(method := FindHomMethodsProjective.DoBaseChangeForBlocks, 
                  rank := 2000, stamp := "DoBaseChangeForBlocks"),1);
          Setimmediateverification(ri,true);
          findgensNmeth(ri).args[1] := Length(res.orb)+20;
      fi;

      # we are done, report the hom:
      Sethomom(ri,res.hom);
      Setmethodsforfactor(ri,FindHomDbPerm);

      return true;
  fi;
end;

FindHomMethodsProjective.DoBaseChangeForBlocks := function(ri,G)
  # Do the base change:
  local H,iso,newgens,ti;

  ti := ri!.t^-1;
  newgens := List(GeneratorsOfGroup(G),x->ri!.t*x*ti);
  H := GroupWithGenerators(newgens);
  iso := GroupHomByFuncWithData(G,H,RECOG.HomDoBaseChange,
                                rec(t := ri!.t,ti := ti));

  # Now report back:
  Sethomom(ri,iso);
  findgensNmeth(ri).method := FindKernelDoNothing;

  # Inform authorities that the factor can be recognised easily:
  forfactor(ri).blocksize := ri!.blocksize;
  Add(forfactor(ri).hints,
      rec(method := FindHomMethodsProjective.Blocks,rank := 2000,
          stamp := "Blocks"));

  return true;
end;

FindHomMethodsProjective.Blocks := function(ri,G)
  # Here we use BlocksModScalars and then get a kernel of scalar blocks
  # altogether mod scalars.
  local blocks,d,hom,i;
  hom := IdentityMapping(G);
  Sethomom(ri,hom);
  blocks := [];
  d := DimensionOfMatrixGroup(G);
  for i in [1..d/ri!.blocksize] do
      Add(blocks,[(i-1)*ri!.blocksize+1..i*ri!.blocksize]);
  od;
  # For the factor:
  forfactor(ri).blocks := blocks;
  Add(forfactor(ri).hints,
      rec(method := FindHomMethodsProjective.BlocksModScalars, rank := 2000,
          stamp := "BlocksModScalars"));
  # For the kernel:
  forkernel(ri).blocks := blocks;
  Add(forkernel(ri).hints,
      rec(method := FindHomMethodsProjective.BlocksBackToMats, rank := 2000,
          stamp := "BlocksBackToMats"));
  return true;
end;

RECOG.HomBackToMats := function(el)
  # We assume that el is block diagonal with the last block being scalar.
  # This just norms this last block to 1.
  local d;
  d := Length(el);
  return (el[d][d]^-1)*el;
end;

FindHomMethodsProjective.BlocksBackToMats := function(ri,G)
  # This is only called as hint from Blocks, so we know that we in fact
  # have scalar blocks along the diagonal and nothing else.
  local H,hom,newgens;
  newgens := List(GeneratorsOfGroup(G),RECOG.HomBackToMats);
  H := Group(newgens);
  hom := GroupHomomorphismByFunction(G,H,RECOG.HomBackToMats);
  Sethomom(ri,hom);
  
  # hints for the factor:
  Setmethodsforfactor(ri,FindHomDbMatrix);
  forfactor(ri).blocks := ri!.blocks{[1..Length(ri!.blocks)-1]};
  Add(forfactor(ri).hints,
      rec(method := FindHomMethodsMatrix.BlockScalar, rank := 2000,
          stamp := "BlockScalar"));

  # This is an isomorphism:
  findgensNmeth(ri).method := FindKernelDoNothing;
  
  return true;
end;

#FindHomMethodsProjective.BalTreeForBlocks := function(ri,G)
#  local H,cut,dim,hom,newgens,nrblocks,subdim,gen;
#  dim := DimensionOfMatrixGroup(G);
#  nrblocks := dim / ri!.blocksize;   # this we know from above
#  if nrblocks = 1 then     # this might happen during the descent into the tree
#      return false;
#  fi;
#  cut := QuoInt(nrblocks,2);  # this is now at least 1
#  subdim := cut * ri!.blocksize;
#  
#  # Project onto factor:
#  newgens := List(GeneratorsOfGroup(G),
#                  x->ExtractSubMatrix(x,[subdim+1..dim],[subdim+1..dim]));
#  for gen in newgens do
#      ConvertToMatrixRep(gen);
#  od;
#  H := GroupWithGenerators(newgens);
#  hom := GroupHomByFuncWithData(G,H,RECOG.HomInducedOnFactor,
#                                rec(subdim := subdim));
#  Sethomom(ri,hom);
#
#  # Create some more kernel generators:
#  findgensNmeth(ri).args[1] := 20 + nrblocks;
#
#  # Pass the block information on to the factor:
#  forfactor(ri).blocksize := ri!.blocksize;
#  Add(forfactor(ri).hints,
#      rec( method := FindHomMethodsProjective.BalTreeForBlocks,
#           rank := 2000, stamp := "BalTreeForBlocks" ),1);
#
#  # Inform authorities that the kernel can be recognised easily:
#  forkernel(ri).subdim := subdim;
#  forkernel(ri).blocksize := ri!.blocksize;
#  Add(forkernel(ri).hints,
#      rec( method := FindHomMethodsProjective.BalTreeForBlocksProjKernel, 
#           rank := 2000, stamp := "BalTreeForBlocksProjKernel" ),1);
#
#  # Verify the kernel immediately after its recognition:
#  Setimmediateverification(ri,true);
#
#  return true;
#end;
#
#RECOG.HomInducedOnSubspace := function(data,el)
#  local m;
#  m := ExtractSubMatrix(el,[1..data.subdim],[1..data.subdim]);
#  # FIXME: no longer necessary, as soon as the new interface is in place
#  ConvertToMatrixRep(m);
#  return m;
#end;

#FindHomMethodsMatrix.InducedOnSubspace := function(ri,G)
#  local H,dim,gens,hom,newgens,gen,data;
#  # Are we applicable?
#  if not(IsBound(ri!.subdim)) then
#      return NotApplicable;
#  fi;
#
#  # Project onto subspace:
#  gens := GeneratorsOfGroup(G);
#  data := rec(subdim := ri!.subdim);
#  newgens := List(gens, x->RECOG.HomInducedOnSubspace(data,x));
#  H := Group(newgens);
#  hom := GroupHomByFuncWithData(G,H,RECOG.HomInducedOnSubspace,data);
#
#  # Now report back:
#  Sethomom(ri,hom);
#
#  # We know that the kernel is a GF(p) vectorspace and thus may need
#  # quite some generators. Therefore we generate them in a non-standard
#  # way such that we can be reasonably sure that we got enough:
#  findgensNmeth(ri).method := FindKernelLowerLeftPGroup;
#  findgensNmeth(ri).args := [];
#
#  # Inform authorities that the kernel can be recognised easily:
#  forkernel(ri).subdim := ri!.subdim;
#  Add(forkernel(ri).hints,rec(method := FindHomMethodsMatrix.LowerLeftPGroup,
#                              rank := 2000,stamp := "LowerLeftPGroup"));
#
#  return true;
#end;

#FindHomMethodsProjective.BalTreeForBlocksProjKernel := function(ri,G)
#  # We just have to project onto the upper left corner, see
#  local H,gen,hom,newgens;
#
#  newgens := List(GeneratorsOfGroup(G),x->x{[1..ri!.subdim]}{[1..ri!.subdim]});
#  for gen in newgens do ConvertToMatrixRep(gen); od;
#  H := Group(newgens);
#  hom := GroupHomByFuncWithData(G,H,RECOG.HomInducedOnSubspace,
#                                rec(subdim := ri!.subdim));
#  Sethomom(ri,hom);
#
#  findgensNmeth(ri).method := FindKernelDoNothing;
#
#  # But pass on the information on blocks:
#  forfactor(ri).blocksize := ri!.blocksize;
#  Add(forfactor(ri).hints, 
#      rec(method := FindHomMethodsProjective.BalTreeForBlocks,
#                               rank := 2000, stamp := "BalTreeForBlocks"),1);
#
#  return true;
#end;

  

