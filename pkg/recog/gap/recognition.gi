#############################################################################
##
##  recognition.gi        recog package                   Max Neunhoeffer
##                                                            Ákos Seress
##
##  Copyright 2005 Lehrstuhl D für Mathematik, RWTH Aachen
##
##  The generic code for recognition, implementation part.
##
##  $Id: recognition.gi,v 1.39 2006/10/14 01:50:07 gap Exp $
##
#############################################################################


# First some technical preparations:

# The type:

InstallValue( RecognitionInfoType,
  NewType(RecognitionInfoFamily, IsRecognitionInfo and IsAttributeStoringRep));


# one can now create objects by doing:
# r := rec( ... )
# Objectify(RecognitionInfoType,r);


RECINFORECURLEVEL := 0;

# a nice view method:
InstallMethod( ViewObj, "for recognition infos", [IsRecognitionInfo],
  function( ri )
    local ms;
    if IsReady(ri) then
        Print("<recoginfo ");
    else
        Print("<failed recoginfo ");
    fi;
    if IsBound(ri!.projective) and ri!.projective then
        Print("(projective) ");
    fi;
    if Hasfhmethsel(ri) then
        ms := fhmethsel(ri);
        if IsRecord(ms) then
            if IsBound(ms.successmethod) then
                Print(ms.successmethod);
            else
                Print("NO STAMP");
            fi;
        elif IsString(ms) then
            Print(ms);
        fi;
    fi;
    if HasSize(ri) then
        Print(" Size=",Size(ri));
    fi;
    if Hasgroup(ri) and IsMatrixGroup(group(ri)) then
        Print(" Dim=",DimensionOfMatrixGroup(group(ri)));
    fi;
    if not(IsLeaf(ri)) then
        Print("\n",String("",RECINFORECURLEVEL)," F:"); 
        RECINFORECURLEVEL := RECINFORECURLEVEL+3;
        if Hasfactor(ri) then
            ViewObj(factor(ri));
        else
            Print("has no factor");
        fi;
        Print("\n",String("",RECINFORECURLEVEL-3), " K:");
        if Haskernel(ri) then
            if kernel(ri) = fail then
                Print("<trivial kernel");
            else
                ViewObj(kernel(ri));
            fi;
        else
            Print("has no kernel");
        fi;
        RECINFORECURLEVEL := RECINFORECURLEVEL-3;
    fi;
    Print(">");
  end);

#############################################################################
# Some variables to hold databases of methods and such things:
#############################################################################

# Permutation groups:
              
InstallValue( FindHomMethodsPerm, rec() );   
   # Here we collect FindHomomorphism methods by name
InstallValue( SLPforElementFuncsPerm, rec() );   
   # Here we collect SLPforElement functions by name
InstallValue( FindHomDbPerm, [] );   
   # and here in a list with records describing them

# Matrix groups:

InstallValue( FindHomMethodsMatrix, rec() );   
   # Here we collect FindHomomorphism methods by name
InstallValue( SLPforElementFuncsMatrix, rec() );   
   # Here we collect SLPforElement functions by name
InstallValue( FindHomDbMatrix, [] );   
   # and here in a list with records describing them

# Projective groups:

InstallValue( FindHomMethodsProjective, rec() );   
   # Here we collect FindHomomorphism methods by name
InstallValue( SLPforElementFuncsProjective, rec() );   
   # Here we collect SLPforElement functions by name
InstallValue( FindHomDbProjective, [] );   
   # and here in a list with records describing them

# Black box groups:

InstallValue( FindHomMethodsBB, rec() );   
   # Here we collect FindHomomorphism methods by name
InstallValue( SLPforElementFuncsBB, rec() );   
   # Here we collect SLPforElement functions by name
InstallValue( FindHomDbBB, [] );   
   # and here in a list with records describing them

#############################################################################
# The main recursive function:
#############################################################################

InstallGlobalFunction( RecognisePermGroup,
  function(G)
    return RecogniseGeneric(G,FindHomDbPerm,0);
  end);

InstallGlobalFunction( RecogniseMatrixGroup,
  function(G)
    return RecogniseGeneric(G,FindHomDbMatrix,0);
  end);

InstallGlobalFunction( RecogniseProjectiveGroup,
  function(G)
    return RecogniseGeneric(G,FindHomDbProjective,0);
  end);

InstallGlobalFunction( RecogniseBBGroup,
  function(G)
    return RecogniseGeneric(G,FindHomDbBB,0);
  end);

InstallGlobalFunction( RecogniseGroup,
  function(G)
    if IsPermGroup(G) then
        return RecogniseGeneric(G,FindHomDbPerm,0);
    elif IsMatrixGroup(G) then
        return RecogniseGeneric(G,FindHomDbMatrix,0);
    else
        return RecogniseGeneric(G,FindHomDbBB,0);
    fi;
    # Note: one cannot use "RecogniseGroup" to recognise projective groups 
    #       as of now since "Projective groups" do not yet exist as GAP 
    #       objects here!
  end);

InstallGlobalFunction( RecogniseGeneric,
  function(arg)
    # Assume all the generators have no memory!
    local H,N,depth,done,i,knowledge,l,ll,methgensN,methoddb,
          proj1,proj2,ri,rifac,riker,s,x,y,z,succ,counter;

    # Look after arguments:
    H := arg[1];
    methoddb := arg[2];
    depth := arg[3];
    if Length(arg) = 4 then
        knowledge := arg[4];
    else
        knowledge := rec();
    fi;

    Info(InfoRecog,3,"Recognising: ",H);

    if Length(GeneratorsOfGroup(H)) = 0 then
        H := Group([One(H)]);
    fi;

    # Set up the record and the group object:
    ri := ShallowCopy(knowledge);
    Objectify( RecognitionInfoType, ri );
    ri!.depth := depth;
    ri!.nrgensH := Length(GeneratorsOfGroup(H));
    Setgroup(ri,H);
    Setcalcnicegens(ri,CalcNiceGensGeneric);
    Setslpforelement(ri,SLPforElementGeneric);
    Setmethodsforfactor(ri,methoddb);
    SetgensN(ri,[]);       # this will grow over time
    SetfindgensNmeth(ri,rec(method := FindKernelRandom, args := [20]));
    Setimmediateverification(ri,false);
    Setforkernel(ri,rec(hints := []));   
          # this is eventually handed down to the kernel
    Setforfactor(ri,rec(hints := []));   
          # this is eventually handed down to the factor
    # Do some extra stuff for projective groups:
    if IsIdenticalObj( methoddb, FindHomDbProjective ) then
        Setisone(ri,IsOneProjective);
        Setisequal(ri,IsEqualProjective);
        ri!.projective := true;
    else
        Setisone(ri,IsOne);
        Setisequal(ri,\=);
        ri!.projective := false;
    fi;

    # Find a possible homomorphism (or recognise this group as leaf)
    if IsBound(knowledge.hints) and Length(knowledge.hints) > 0 then
        Setfhmethsel(ri,CallMethods(Concatenation(knowledge.hints,methoddb),
                                10,ri,H));
    else
        Setfhmethsel(ri,CallMethods( methoddb, 10, ri, H ));
    fi;
    if fhmethsel(ri).result = fail then
        SetFilterObj(ri,IsLeaf);
        return ri;
    fi;

    # Handle the leaf case:
    if IsLeaf(ri) or DoNotRecurse(ri) then   
        # Handle the case that nobody set nice generators:
        if not(Hasnicegens(ri)) then
            if Hasslptonice(ri) then
                Setnicegens(ri,ResultOfStraightLineProgram(slptonice(ri),
                                            GeneratorsOfGroup(H)));
            else
                Setnicegens(ri,GeneratorsOfGroup(H));
            fi;
        fi;
        # these two were set correctly by FindHomomorphism
        if IsLeaf(ri) then SetFilterObj(ri,IsReady); fi;
        return ri;
    fi;

    # The non-leaf case:
    # In that case we know that ri now knows: homom plus additional data.
    
    # Try to recognise the factor a few times, then give up:
    counter := 0;
    repeat
        counter := counter + 1;
        if counter > 10 then
            Info(InfoRecog,1,"Giving up desperately...");
            return ri;
        fi;

        if IsMatrixGroup(Image(homom(ri))) then
            Info(InfoRecog,1,"Going to the factor (depth=",depth,", try=",
              counter,", dim=",DimensionOfMatrixGroup(Image(homom(ri))),").");
        else
            Info(InfoRecog,1,"Going to the factor (depth=",depth,", try=",
              counter,").");
        fi;
        rifac := RecogniseGeneric( 
                  Group(List(GeneratorsOfGroup(H), x->ImageElm(homom(ri),x))), 
                  methodsforfactor(ri), depth+1, forfactor(ri) );
        Setfactor(ri,rifac);
        Setparent(rifac,ri);

        if IsMatrixGroup(H) then
            Info(InfoRecog,1,"Back from factor (depth=",depth,", dim=",
                 DimensionOfMatrixGroup(H),").");
        else
            Info(InfoRecog,1,"Back from factor (depth=",depth,").");
        fi;

        if not(IsReady(rifac)) then
            # the recognition of the factor failed, also give up here:
            return ri;
        fi;

        # Now we want to have preimages of the new generators in the factor:
        Info(InfoRecog,1,"Calculating preimages of nice generators.");
        Setpregensfac( ri, CalcNiceGens(rifac,GeneratorsOfGroup(H)));
        Setcalcnicegens(ri,CalcNiceGensHomNode);

        ri!.genswithmem := GeneratorsWithMemory(
            Concatenation(GeneratorsOfGroup(H),pregensfac(ri)));
        ri!.groupmem := Group(ri!.genswithmem{[1..ri!.nrgensH]});

        # Now create the kernel generators with the stored method:
        Info(InfoRecog,2,"Creating kernel elements.");
        methgensN := findgensNmeth(ri);
        succ := CallFuncList(methgensN.method,
                             Concatenation([ri],methgensN.args));
    until succ;

    # Do a little bit of preparation for the generators of N:
    l := gensN(ri);
    if not(IsBound(ri!.leavegensNuntouched)) then
        Sort(l,SortFunctionWithMemory);   # this favours "shorter" memories!
        # FIXME: For projective groups different matrices might stand
        #        for the same element, we might overlook this here!
        # remove duplicates:
        ll := [];
        for i in [1..Length(l)] do
            if not(isone(ri)(l[i])) and 
               (i = 1 or not(isequal(ri)(l[i],l[i-1]))) then
                Add(ll,l[i]);
            fi;
        od;
        SetgensN(ri,ll);
    fi;
    if Length(gensN(ri)) = 0 then
        # We found out that N is the trivial group!
        # In this case we do nothing, kernel is fail indicating this.
        Info(InfoRecog,1,"Found trivial kernel (depth=",depth,").");
        Setkernel(ri,fail);
        # We have to learn from the factor, what our nice generators are:
        Setnicegens(ri,pregensfac(ri));
        SetFilterObj(ri,IsReady);
        return ri;
    fi;

    Info(InfoRecog,1,"Going to the kernel (depth=",depth,").");
    repeat
        # Now we go on as usual:
        SetgensNslp(ri,SLPOfElms(gensN(ri)));
        # This is now in terms of the generators of H plus the preimages
        # of the nice generators behind the homomorphism!
        N := Group(StripMemory(gensN(ri)));
        
        riker := RecogniseGeneric( N, methoddb, depth+1, forkernel(ri) );
        Setkernel(ri,riker);
        Setparent(riker,ri);
        Info(InfoRecog,1,"Back from kernel (depth=",depth,").");

        done := true;
        if IsReady(riker) and immediateverification(ri) then
            # Do an immediate verification:
            Info(InfoRecog,1,"Doing immediate verification.");
            i := 1;
            for i in [1..5] do
                x := PseudoRandom( ri!.groupmem );
                s := SLPforElement(rifac,ImageElm( homom(ri), x!.el ));
                if s = fail then
                    Error("Very bad: factor was wrongly recognised and we ",
                          "found out too late");
                fi;
                y := ResultOfStraightLineProgram(s,
                   ri!.genswithmem{[ri!.nrgensH+1..Length(ri!.genswithmem)]});
                z := x*y^-1;
                s := SLPforElement(riker,z!.el);
                if InfoLevel(InfoRecog) >= 1 then Print(".\c"); fi;
                if s = fail then
                    # We missed something!
                    done := false;
                    Add(gensN(ri),z);
                    Info(InfoRecog,1,
                         "Alarm: Found unexpected kernel element! (depth=",
                         depth,")");
                fi;
            od;
            if InfoLevel(InfoRecog) >= 1 then Print("\n"); fi;
            if not(done) then
                succ := FindKernelRandom(ri,20);
                Info(InfoRecog,1,"Have now ",Length(gensN(ri)),
                     " generators for kernel, recognising...");
                if succ = false then
                    Error("Very bad: factor was wrongly recognised and we ",
                          "found out too late");
                fi;
            fi;
        fi;
    until done;

    if IsReady(riker) then    # we are only ready when the kernel is
        # Now make the two projection slps:
        Setnicegens(ri,Concatenation(pregensfac(ri),nicegens(riker)));
        #ll := List([1..Length(nicegens(rifac))],i->[i,1]);
        #ri!.proj1 := StraightLineProgramNC([ll],Length(nicegens(ri)));
        #ll := List([1..Length(nicegens(riker))],
        #           i->[i+Length(nicegens(rifac)),1]);
        #ri!.proj2 := StraightLineProgramNC([ll],Length(nicegens(ri)));
        SetFilterObj(ri,IsReady);
    fi;
    return ri;
  end);

InstallGlobalFunction( CalcNiceGens,
  function(ri,origgens)
    return calcnicegens(ri)(ri,origgens);
  end );

InstallGlobalFunction( CalcNiceGensGeneric,
  # generic function using an slp:
  function(ri,origgens)
    if not(Hasslptonice(ri)) then
        return origgens;
    else
        return ResultOfStraightLineProgram(slptonice(ri),origgens);
    fi;
  end );

InstallGlobalFunction( CalcNiceGensHomNode,
  # function for the situation on a homomorphism node (non-Leaf):
  function(ri,origgens)
    local origkergens,rifac,riker,pregensfactor;
    # Is there a non-trivial kernel?
    rifac := factor(ri);
    if Haskernel(ri) and kernel(ri) <> fail then
        pregensfactor := CalcNiceGens(rifac,origgens);
        riker := kernel(ri);
        origkergens := ResultOfStraightLineProgram( gensNslp(ri), 
                    Concatenation(origgens,pregensfactor) );
        return Concatenation( pregensfactor,
                              CalcNiceGens(riker,origkergens) );
    else
        return CalcNiceGens(rifac,origgens);
    fi;
  end );

InstallGlobalFunction( SLPforElement,
  function(ri,x)
    return slpforelement(ri)(ri,x);
  end );
    
InstallGlobalFunction( SLPforElementGeneric, 
  # generic method for a non-leaf node
  function(ri,g)
    local gg,n,rifac,riker,s,s1,s2,y,nr1,nr2;
    rifac := factor(ri);
    riker := kernel(ri);   # note: might be fail
    gg := ImageElm(homom(ri),g);
    if gg = fail then
        return fail;
    fi;
    s1 := SLPforElement(rifac,gg);
    if s1 = fail then
        return fail;
    fi;
    # if the kernel is trivial, we are done:
    if riker = fail then
        # was: return CompositionOfStraightLinePrograms(s1,gensQslp(ri));
        return s1;
    fi;
    # Otherwise work in the kernel:
    y := ResultOfStraightLineProgram(s1,pregensfac(ri));
    n := g*y^-1;
    s2 := SLPforElement(riker,n);
    if s2 = fail then
        return fail;
    fi;
    nr2 := NrInputsOfStraightLineProgram(s2);
    nr1 := NrInputsOfStraightLineProgram(s1);
    s := NewProductOfStraightLinePrograms(s2,[nr1+1..nr1+nr2],
                                          s1,[1..nr1],
                                          nr1+nr2);
    #s := ProductOfStraightLinePrograms(
    #       CompositionOfStraightLinePrograms(s2,ri!.proj2),
    #       CompositionOfStraightLinePrograms(s1,ri!.proj1));
    return s;
  end);

# Some helper functions for generic code:

InstallGlobalFunction( FindKernelRandom,
  function(ri,n)
    local i,l,rifac,s,x,y;
    Info(InfoRecog,1,"Creating ",n," random generators for kernel.");
    l := gensN(ri);
    rifac := factor(ri);
    for i in [1..n] do
        x := PseudoRandom( ri!.groupmem );
        s := SLPforElement(rifac,ImageElm( homom(ri), x!.el ));
        if s = fail then
            return false;
        fi;
        y := ResultOfStraightLineProgram(s,
                 ri!.genswithmem{[ri!.nrgensH+1..Length(ri!.genswithmem)]});
        Add(l,x^-1*y);
        if InfoLevel(InfoRecog) >= 1 then
            Print(".\c");
        fi;
    od;
    if InfoLevel(InfoRecog) >= 1 then
        Print("\n");
    fi;
    return true;
  end );

InstallGlobalFunction( FindKernelDoNothing,
  function(ri,n)
    return true;
  end );

InstallGlobalFunction( RandomSubproduct, function(a)
    local prod, list, g;

    if IsGroup(a) then
        prod := One(a);
        list := GeneratorsOfGroup(a);
    elif IsList(a) then
        if Length(a) = 0 or
            not IsMultiplicativeElementWithInverse(a[1]) then
            Error("<a> must be a nonempty list of group elements");
        fi;
        prod := One(a[1]);
        list := a;
    else
        Error("<a> must be a group or a nonempty list of group elements");
    fi;

    for g in list do
        if Random( [ true, false ] )  then
            prod := prod * g;
        fi;
    od;
    return prod;
end );

InstallGlobalFunction( FastNormalClosure , function( grp, list, n )
  local i,list2,randgens,randlist;
  list2:=ShallowCopy(list);
  if Length(GeneratorsOfGroup(grp)) > 3 then
    for i in [1..6*n] do
      if Length(list2)=1 then
        randlist:=list2[1];
      else
        randlist:=RandomSubproduct(list2);
      fi;
      if not(IsOne(randlist)) then
        randgens:=RandomSubproduct(GeneratorsOfGroup(grp));
        if not(IsOne(randgens)) then
          Add(list2,randlist^randgens);
        fi;
      fi;
    od;
  else # for short generator lists, conjugate with all generators
    for i in [1..3*n] do
      if Length(list2)=1 then
        randlist:=list2[1];
      else
        randlist:=RandomSubproduct(list2);
      fi;
      if randlist <> One(grp) then
         for randgens in GeneratorsOfGroup(grp) do
             Add(list2, randlist^randgens);
         od;
      fi;
    od;
  fi;
  return list2;
end );

InstallGlobalFunction( FindKernelFastNormalClosure,
  # Used in the generic recursive routine.
  function(ri,n)
    local succ;

    succ := FindKernelRandom(ri,n);
    if succ = false then
        return false;
    fi;

    SetgensN(ri,FastNormalClosure(ri!.groupmem(ri),gensN(ri),n));

    return true;
  end);

InstallOtherMethod( Size, "for a recognition info record", 
  [IsRecognitionInfo and IsReady],
  function(ri)
    local size;
    if IsLeaf(ri) then
        # Note: A leaf in projective recognition *has* to set the size
        #       of the recognition info record!
        return Size(group(ri));
    else
        size := Size(factor(ri));
        if kernel(ri) <> fail then
            return Size(kernel(ri)) * size;
        else
            return size;   # trivial kernel
        fi;
    fi;
  end);

InstallOtherMethod( Size, "for a failed recognition info record",
  [IsRecognitionInfo],
  function(ri)
    Error("the recognition described by this info record has failed!");
  end);

InstallOtherMethod( \in, "for a group element and a recognition info record",
  [IsObject, IsRecognitionInfo and IsReady],
  function( el, ri )
    local gens,slp;
    slp := SLPforElement(ri,el);
    if slp = fail then
        return false;
    else
        gens := GeneratorsOfGroup(group(ri));
        if IsObjWithMemory(gens[1]) then
            gens := StripMemory(gens);
        fi;
        return isequal(ri)(el,ResultOfStraightLineProgram(slp,gens));
    fi;
  end);

InstallOtherMethod( \in, "for a group element and a recognition info record",
  [IsObject, IsRecognitionInfo],
  function( el, ri )
    Error("the recognition described by this info record has failed!");
  end);

InstallGlobalFunction( "DisplayCompositionFactors", function(arg)
  local c,depth,f,i,j,ri,homs,ksize;
  if Length(arg) = 1 then
      ri := arg[1];
      depth := 0;
      homs := 0;
      ksize := 1;
  else
      ri := arg[1];
      depth := arg[2];
      homs := arg[3];
      ksize := arg[4];
  fi;
  if not(IsReady(ri)) then
      for j in [1..homs] do Print("-> "); od;
      Print("Recognition failed\n");
      return;
  fi;
  if IsLeaf(ri) then
      c := CompositionSeries(group(ri));
      for i in [1..Length(c)-1] do
          if homs > 0 then
              Print("Group with Size ",ksize*Size(c[i]));
              for j in [1..homs] do Print(" ->"); od;
              Print(" ");
          fi;
          Print("Group ",GroupString(c[i],""),"\n | ");
          f := Image( NaturalHomomorphismByNormalSubgroup( c[i], c[i+1] ) );
          Print(IsomorphismTypeInfoFiniteSimpleGroup( f ).name, "\n" );
      od;
  else
      if Haskernel(ri) and kernel(ri) <> fail then
          DisplayCompositionFactors(factor(ri),depth+1,homs+1,
                                    ksize*Size(kernel(ri)));
          DisplayCompositionFactors(kernel(ri),depth+1,homs,ksize);
      else
          DisplayCompositionFactors(factor(ri),depth+1,homs+1,ksize);
      fi;
  fi;
  if depth = 0 then
      Print("1\n");
  fi;
end );

BindGlobal( "SLPforNiceGens", function(ri)
  local l,ll,s;
  l := List( [1..Length(GeneratorsOfGroup(group(ri)))], x->() );
  l := GeneratorsWithMemory(l);
  ll := CalcNiceGens(ri,l);
  s := SLPOfElms(ll);
  return s;
end );

  
# Testing:

RECOG.TestGroup := function(g,proj,size)
  local l,r,ri,s,x;
  r := Runtime();
  if proj then
      ri := RecogniseProjectiveGroup(g);
  else
      ri := RecogniseGroup(g);
  fi;
  Print("Time for recognition: ",Runtime()-r,"\n");
  if Size(ri) <> size then
      Error("Alarm: Size not correct!\n");
      return ri;
  fi;
  View(ri);
  Print("\n");
  l := CalcNiceGens(ri,GeneratorsOfGroup(g));
  x := PseudoRandom(g);
  s := SLPforElement(ri,x);
  if s = fail or not(isequal(ri)(ResultOfStraightLineProgram(s,l),x)) then
      Error("Alarm: SLPforElement did not work!\n");
      return ri;
  fi;
  return ri;
end;

