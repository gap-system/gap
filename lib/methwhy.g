#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This files's authors include Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file allows some fancy accesses to the method selection
##

#############################################################################
##
#F  Print_Value(<val>)   
##
##  <ManSection>
##  <Func Name="Print_Value" Arg='val'/>
##
##  <Description>
##  print a number factorized by SUM_FLAGS
##  </Description>
##  </ManSection>
##
BindGlobal("Print_Value_SFF",function(val)
  if val>SUM_FLAGS then
    Print(QuoInt(val,SUM_FLAGS),"*SUM_FLAGS");
    val:=val mod SUM_FLAGS;
    if val>0 then
      Print("+",val);
    fi;
  else
    Print(val);
  fi;
end);

#############################################################################
##
#F  ApplicableMethod( <opr>, <args>[, <printlevel>[, <nr>]] )
#F  ApplicableMethodTypes( <opr>, <args>[, <printlevel>[, <nr>]] )
##
##  <#GAPDoc Label="ApplicableMethod">
##  <ManSection>
##  <Func Name="ApplicableMethod" Arg='opr, args[, printlevel[, nr]]'/>
##  <Func Name="ApplicableMethodTypes" Arg='opr, args[, printlevel[, nr]]'/>
##
##  <Description>
##  Called with two arguments, <Ref Func="ApplicableMethod"/> returns the
##  method of highest rank that is applicable for the operation <A>opr</A>
##  with the arguments in the list <A>args</A>.
##  The default <A>printlevel</A> is <C>0</C>.
##  If no method is applicable then <K>fail</K> is returned.
##  <P/>
##  If a positive integer is given as the fourth argument <A>nr</A> then
##  <Ref Func="ApplicableMethod"/> returns the <A>nr</A>-th applicable method
##  for the operation <A>opr</A> with the arguments in the list <A>args</A>,
##  where the methods are ordered according to descending rank.
##  If less than <A>nr</A> methods are applicable then <K>fail</K> is
##  returned.
##  <P/>
##  If the fourth argument <A>nr</A> is the string <C>"all"</C> then
##  <Ref Func="ApplicableMethod"/>
##  returns a list of all applicable methods for <A>opr</A> with arguments
##  <A>args</A>, ordered according to descending rank.
##  <P/>
##  Depending on the integer value <A>printlevel</A>, additional information is
##  printed.  Admissible values and their meaning are as follows.
##  <P/>
##  <List>
##  <Mark>0</Mark>
##  <Item>
##      no information,
##  </Item>
##  <Mark>1</Mark>
##  <Item>
##      information about the applicable method,
##  </Item>
##  <Mark>2</Mark>
##  <Item>
##      also information about the not applicable methods of higher rank,
##  </Item>
##  <Mark>3</Mark>
##  <Item>
##      also for each not applicable method the first reason why it is not
##      applicable,
##  </Item>
##  <Mark>4</Mark>
##  <Item>
##      also for each not applicable method all reasons why it is not
##      applicable.
##  </Item>
##  </List>
##  <P/>
##  Since <C>ApplicableMethod</C> returns a function, <C>Print(last);</C> 
##  may be used to view the code. 
##  <P/>
##  If the first argument is a function, rather than an operation, 
##  then the function is returned. 
##  <P/>
##  The first example shows that there are 50 methods for <C>Size</C> 
##  currently available, or which 3 are applicable to <C>s4</C>. 
##  <Log><![CDATA[
##  gap> s4 := Group( (1,2,3,4), (3,4) );; 
##  gap> ApplicableMethod( Size, [s4], 1, "all" );
##  #I  Searching Method for Size with 1 arguments:
##  #I  Total: 50 entries, of which 3 are applicable:
##  #I  Method 6, valid operation number 1, value: 103
##  #I  ``Size'' at ... some path .../lib/coll.gi:176
##  #I  Method 10, valid operation number 2, value: 59
##  #I  ``Size: for a permutation group'' at ... some path .../lib/grpperm.gi:483
##  #I  Method 50, valid operation number 3, value: 2
##  #I  ``Size: for a collection'' at ... some path .../lib/coll.gi:189
##  [ function( C ) ... end, function( G ) ... end, function( C ) ... end ]
##  gap> Print( last[1], "\n" );                  
##  function ( C )
##      if IsFinite( C ) then
##          TryNextMethod();
##      fi;
##      return infinity;
##  end

##  ]]></Log>
##  The second example shows that for <C>DirectProduct</C>, 
##  which is a function the location may be displayed and the code returned. 
##  For <C>DirectProductOp</C> with verbosity <M>2</M> and <M>nr=2</M> 
##  methods <M>1</M> and <M>5</M> are applicable, and all methods numbered 
##  <M>[2..5]</M> are displayed. 
##  <Log><![CDATA[
##  gap> ApplicableMethod( DirectProduct, [s4,s4], 1, 1 );    
##  #I  DirectProduct is a function, not an operation, located at:
##  #I  ... some path .../lib/gprd.gi:17
##  function( arg... ) ... end
##  gap> ApplicableMethod( DirectProductOp, [[s4,s4],s4], 2, 2 );
##  #I  Searching Method for DirectProductOp with 2 arguments:
##  #I  Total: 5 entries, of which 2 are applicable:
##  #I  Method 2, value: 66
##  #I  ``DirectProductOp: for a list (of pc groups), and a pc group''
##  #I   at ... some path .../lib/gprdpc.gi:15
##  #I  Method 3, value: 47
##  #I  ``DirectProductOp: matrix groups''
##  #I   at ... some path .../lib/gprdmat.gi:70
##  #I  Method 4, value: 40
##  #I  ``DirectProductOp: for a list of fp groups, and a fp group''
##  #I   at ... some path .../lib/grpfp.gi:5495
##  #I  Method 5, valid operation number 2, value: 37
##  #I  ``DirectProductOp: for a list (of groups), and a group''
##  #I   at ... some path .../lib/gprd.gi:50
##  function( list, gp ) ... end
##  ]]></Log>
##  The third example shows the sort of output that can be obtained 
##  with verbosity <M>4</M>.  
##  <Log><![CDATA[
##  gap> s := "hello! hello! hello!";;                           
##  gap> ApplicableMethod(SplitString,[s,"!",' '],4,"all");
##  #I  Searching Method for SplitString with 3 arguments:
##  #I  Total: 4 entries, of which 1 is applicable:
##  #I  Method 1, value: 15
##  #I  ``SplitString: for three strings''
##  #I   at ... some path .../lib/string.gi:539
##  #I   - 3rd argument needs [ "IsString" ]
##  #I  Method 2, value: 11
##  #I  ``SplitString: for a string, a character and a string''
##  #I   at ... some path .../lib/string.gi:561
##  #I   - 2nd argument needs [ "IsChar" ]
##  #I   - 3rd argument needs [ "IsString" ]
##  #I  Method 3, valid operation number 1, value: 11
##  #I  ``SplitString: for two strings and a character''
##  #I   at ... some path .../lib/string.gi:553
##  #I  Method 4, value: 7
##  #I  ``SplitString: for a string and two characters''
##  #I   at ... some path .../lib/string.gi:545
##  #I   - 2nd argument needs [ "IsChar" ]
##  [ function( string, d1, d2 ) ... end ]
##  ]]></Log>
##  When a method returned by <Ref Func="ApplicableMethod"/> is called then
##  it returns either the desired result or the string
##  <C>"TRY_NEXT_METHOD"</C>, which corresponds to a call to
##  <Ref Func="TryNextMethod"/> in the method and means that
##  the method selection would call the next applicable method.
##  <P/>
##  <E>Note:</E>
##  The &GAP; kernel provides special treatment for the infix operations
##  <C>\+</C>, <C>\-</C>, <C>\*</C>, <C>\/</C>, <C>\^</C>, <C>\mod</C> and
##  <C>\in</C>.
##  For some kernel objects (notably cyclotomic numbers,
##  finite field elements and row vectors thereof) it calls kernel methods
##  circumventing the method selection mechanism.
##  Therefore for these operations <Ref Func="ApplicableMethod"/> may return
##  a method which is not the kernel method actually used.
##  <P/>
##  The function <Ref Func="ApplicableMethodTypes"/> takes the <E>types</E>
##  or <E>filters</E> of the arguments as argument (if only filters are given
##  of course family predicates cannot be tested).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("ApplicableMethodTypes",function(arg)
local oper,opargs,nopargs,verbos,fams,flags,i,j,methods,flag,flag2,
      m,nam,val,has,need,isconstructor,
      nummeth,valid,applic,numapplic,nr,first,last;
  if Length(arg)<2 or not IsList(arg[2]) or not IsFunction(arg[1]) then
    Error("usage: ApplicableMethodTypes(<opr>,<arglist>[,<verbosity>[,<nr>]])");
  fi;
  ## process the arguments 
  oper:=arg[1];
  isconstructor:=IS_CONSTRUCTOR(oper);
    opargs:=arg[2];
  nopargs:=Length(opargs);
  verbos:=0;
  if Length(arg)>2 and IsPosInt(arg[3]) then
    verbos:=Minimum(arg[3],4);
  fi;
  nr:=1;
  if Length(arg)>3 then 
    if IsPosInt(arg[4]) then
      nr:=arg[4];
    elif arg[4]="all" then 
      nr:=0;
    fi;
  fi;
  ## accept the name of a function 
  if not oper in OPERATIONS then 
    nam:=FilenameFunc(oper); 
    if nam=fail then 
      Print("#I  ",oper," is not recognised as the name of an operation\n"); 
      return fail;
    else
      if verbos>0 then 
        Print("#I  ",NameFunction(oper),
              " is a function, not an operation, located at:\n"); 
        Print("#I  ",LocationFunc(oper),"\n"); 
      fi;
      return oper;
    fi; 
  fi; 
  # get families and filters
  flags:=[];
  fams:=[];
  for i in opargs do
    if IsFilter(i) then
      Add(flags,FLAGS_FILTER(i));
      Add(fams,fail);
    elif IsType(i) then
      Add(flags,i![2]);
      Add(fams,i![1]);
    else
      Error("wrong kind of argument");
    fi;
  od;
  if ForAny(fams,i->i=fail) then
    fams:=fail;
    Info(InfoWarning,1,"Family predicate cannot be tested");
  fi;
  ## find all the methods 
  methods:=MethodsOperation(oper,nopargs);
  nummeth:=Length(methods);
  if nummeth=0 then 
    Print("#I  no method found for this operation with these arguments\n"); 
    return fail;
  fi;
  applic := [ ];
  valid := ListWithIdenticalEntries( nummeth, false );
  for i in [1..nummeth] do 
    flag := true; 
    m := methods[i];
    for j in [1..nopargs] do 
      if isconstructor then
        flag2:=IS_SUBSET_FLAGS(m.argFilt[j],flags[j]);
      else
        flag2:=IS_SUBSET_FLAGS(flags[j],m.argFilt[j]);
      fi;
      flag := flag and flag2;
    od;
    if flag then 
      valid[i] := true; 
      Add( applic, i );;
    fi;
  od;
  numapplic := Length( applic );
  ## if nothing to print then return the oper 
  if verbos=0 then 
    if nr=0 or nr>numapplic then 
      return fail; 
    fi;
    return methods[applic[nr]].func; 
  fi;
  ## output basic information
  Print("#I  Searching Method for ",NameFunction(oper)," with ", 
        nopargs," arguments:\n");
  Print("#I  Total: ",nummeth," entries, of which ",numapplic); 
  if numapplic=1 then 
    Print(" is applicable:\n");
  else 
    Print(" are applicable:\n");
  fi;
  if nr>numapplic then 
    if (numapplic=0) then 
      Print("#I  there are no valid methods with these parameters\n"); 
    else
      if numapplic=1 then 
        Print("#I  there is only 1 valid method\n"); 
      else
        Print("#I  there are only ",numapplic," valid methods\n"); 
      fi;
    fi;
  fi;
  ## find the range [first..last] of methods which might be printed
  if nr=0 then  ## this is the case "all" 
    first:=1;
    last:=nummeth;
  elif numapplic=0 then 
    if verbos=1 then 
      return fail; 
    else
      first:=1;
      last:=nummeth;
    fi;
  elif nr>numapplic then 
    first:=1;
    last:=0;
  else 
    last:=applic[nr]; 
    if verbos>1 then 
      if nr=1 then 
        first:=1;
      else
        first:=applic[nr-1]+1; 
      fi;
    else 
      first := applic[nr];
    fi;
  fi;
  ## loop over the methods to be printed
  for i in [first..last] do
    m := methods[i];
    nam:=m.info;
    val:=m.rank;
    oper:=m.func;
    if i in applic then 
      Print("#I  Method ",i); 
      Print(", valid operation number ",Position(applic,i)); 
      Print(", value: ");  
      Print_Value_SFF(val);
      Print("\n#I  ``",nam,"''\n");
      if IsBound(m.location) then
        Print("#I   at ", m.location[1], ":", m.location[2]);
      elif LocationFunc(oper) <> "" then
        Print(" at ",LocationFunc(oper));
      fi;
      Print("\n");
      ## not sure what this test is for
      if not ( fams=fail or CallFuncList(m.famPred,fams) ) then 
        if verbos>2 then 
          Print("#I   - bad family relations\n"); 
        fi;
      fi;
    elif verbos>1 then
      Print("#I  Method ",i); 
      Print(", value: ");  
      Print_Value_SFF(val);
      Print("\n#I  ``",nam,"''\n");
      if IsBound(m.location) then
        Print("#I   at ", m.location[1], ":", m.location[2]);
      elif LocationFunc(oper) <> "" then
        Print(" at ",LocationFunc(oper));
      fi;
      Print("\n");
      flag:=true;
      j:=1;
      while j<=nopargs and (flag or verbos>3) do
        if j=1 and isconstructor then
          flag2:=IS_SUBSET_FLAGS(m.argFilt[j],flags[j]);
        else
          flag2:=IS_SUBSET_FLAGS(flags[j],m.argFilt[j]);
        fi;
        flag:=flag and flag2;
        if flag2=false and verbos>2 then
          need:=NamesFilter(m.argFilt[j]);
          if j=1 and isconstructor then
            Print("#I   - ",Ordinal(j)," argument must be ", need,"\n");
          else
            has:=NamesFilter(flags[j]);
            Print("#I   - ",Ordinal(j)," argument needs ",
                  Filtered(need,i->not i in has),"\n");
          fi;
        fi;
        j:=j+1;
      od;
    fi;
  od;
  if nr>numapplic then 
    return fail;
  elif nr=0 then 
    return List(applic, i->methods[i].func);
  else 
    return oper;
  fi;
end);

BIND_GLOBAL("ApplicableMethod",function(arg)
local i,l,ok,errstr;
  ok:=false;
  errstr:="#I  usage: ApplicableMethod(<opr>,<arglist>[,<verbosity>[,<nr>]])\n";
  if Length(arg)<2 then 
    Print("#I  ApplicableMethod requires at least two arguments\n"); 
  elif not IsList(arg[2]) then 
    Print("#I  argument 2 must be a list of arguments for the operation\n" ); 
  elif not IsFunction(arg[1]) then 
    Print("#I  argument 1 must be the name of an operation\n" );
  else 
    ok := true;
  fi;
  if not ok then 
    Print(errstr);
    return fail;
  fi;
  l:=ShallowCopy(arg[2]);
  for i in [1..Length(l)] do
    if i=1 and IS_CONSTRUCTOR(arg[1]) then
      l[i]:=l[i];
    else
      l[i]:=TypeObj(l[i]);
    fi;
  od;
  arg[2]:=l;
  return CallFuncList(ApplicableMethodTypes,arg);
end);

#############################################################################
##
#F  ShowImpliedFilters( <filter> )
##
##  <#GAPDoc Label="ShowImpliedFilters">
##  <ManSection>
##  <Func Name="ShowImpliedFilters" Arg='filter'/>
##
##  <Description>
##  Displays information about the filters that may be
##  implied by <A>filter</A>. They are given by their names.
##  <Ref Func="ShowImpliedFilters"/> first displays the names of all filters
##  that are unconditionally implied by <A>filter</A>. It then displays
##  implications that require further filters to be present (indicating
##  by <C>+</C> the required further filters).
##  <Example><![CDATA[
##  gap> ShowImpliedFilters(IsNilpotentGroup);
##  Implies:
##     IsListOrCollection
##     IsCollection
##     IsDuplicateFree
##     IsExtLElement
##     CategoryCollections(IsExtLElement)
##     IsExtRElement
##     CategoryCollections(IsExtRElement)
##     CategoryCollections(IsMultiplicativeElement)
##     CategoryCollections(IsMultiplicativeElementWithOne)
##     CategoryCollections(IsMultiplicativeElementWithInverse)
##     IsGeneralizedDomain
##     IsMagma
##     IsMagmaWithOne
##     IsMagmaWithInversesIfNonzero
##     IsMagmaWithInverses
##     IsAssociative
##     HasMultiplicativeNeutralElement
##     IsGeneratorsOfSemigroup
##     IsSimpleSemigroup
##     IsRegularSemigroup
##     IsInverseSemigroup
##     IsCompletelyRegularSemigroup
##     IsGroupAsSemigroup
##     IsMonoidAsSemigroup
##     IsOrthodoxSemigroup
##     IsSupersolvableGroup
##     IsSolvableGroup
##     IsNilpotentByFinite
##  
##  
##  May imply with:
##  +IsFinitelyGeneratedGroup
##     IsPolycyclicGroup
##  
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("ShowImpliedFilters",function(filter)
  local flags, implied, f, extra_implications, implication, name, diff_reqs,
        diff_impls, reduced;

  flags:=FLAGS_FILTER(filter);
  implied := WITH_IMPS_FLAGS(flags);
  atomic readonly IMPLICATIONS_SIMPLE do
    # select all implications which involved <filter> in the requirements
    f:=Filtered(IMPLICATIONS_SIMPLE, x->IS_SUBSET_FLAGS(x[2],flags));
    Append(f, Filtered(IMPLICATIONS_COMPOSED, x->IS_SUBSET_FLAGS(x[2],flags)));
  od; # end atomic

  extra_implications:=[];
  for implication in f do
    # the additional requirements
    diff_reqs:=SUB_FLAGS(implication[2],flags);
    if SIZE_FLAGS(diff_reqs) = 0 then
      Assert(0, IS_SUBSET_FLAGS(implied,implication[1]));
      continue;
    fi;
    # the combined implications...
    diff_impls:=implication[1];
    # ... minus those implications that already follow from <filter>
    diff_impls:=SUB_FLAGS(diff_impls,implied);
    # ... minus those implications that already follow from diff_reqs
    diff_impls:=SUB_FLAGS(diff_impls,WITH_IMPS_FLAGS(diff_reqs));
    if SIZE_FLAGS(diff_impls) > 0 then
      Add(extra_implications, [diff_reqs, diff_impls]);
    fi;
  od;

  # remove "obvious" implications
  if IS_ELEMENTARY_FILTER(filter) then
    implied := SUB_FLAGS(implied, flags);
  fi;

  reduced:= function( trues )
    atomic readonly FILTER_REGION do
      return Filtered( trues,
      i -> not ( INFO_FILTERS[i] in FNUM_TPRS
                 and FLAG1_FILTER( FILTERS[i] ) in trues ) );
    od;
  end;

  if SIZE_FLAGS(implied) > 0 then
    Print("Implies:\n");
    for name in NamesFilter( reduced( TRUES_FLAGS( implied ) ) ) do
      Print("   ",name,"\n");
    od;
  fi;

  if Length(extra_implications) > 0 then
    Print("\n\nMay imply with:\n");
    for implication in extra_implications do
      for name in NamesFilter( reduced( TRUES_FLAGS( implication[1] ) ) ) do
        Print("+",name,"\n");
      od;
      for name in NamesFilter( reduced( TRUES_FLAGS( implication[2] ) ) ) do
        Print("   ",name,"\n");
      od;
      Print("\n");
    od;
  fi;
end);

#############################################################################
##
#F  PageSource( func ) . . . . . . . . . . . . . . . show source code in pager
##
##  <#GAPDoc Label="PageSource">
##  <ManSection>
##  <Func Name="PageSource" Arg='func[, nr]'/>
##
##  <Description>
##  This shows the file containing the source code of the function or method
##  <A>func</A> in a pager (see <Ref Func="Pager"/>). The display starts at 
##  a line shortly before the code of <A>func</A>.<P/>
##  
##  For operations <A>func</A> the function shows the source code of the
##  declaration of <A>func</A>. Operations can have several declarations, use
##  the optional second argument to specify which one should be shown (in the
##  order the declarations were read); the default is to show the first.<P/>
##  
##  For kernel functions the function tries to show the C source code.<P/>
##  
##  If GAP cannot find a file containing the source code this will be indicated.
##  <P/>
##  Usage examples:<Br/>
##  <C>met := ApplicableMethod(\^, [(1,2),2743527]); PageSource(met);</C><Br/>
##  <C>PageSource(Combinations);</C><Br/>
##  <C>PageSource(SORT_LIST); </C><Br/>
##  <C>PageSource(Size, 2);</C><Br/>
##  <C>ct := CharacterTable(Group((1,2,3))); </C><Br/>
##  <C>met := ApplicableMethod(Size,[ct]); PageSource(met); </C>
##  <P/>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
BIND_GLOBAL("PageSource", function ( fun, nr... )
    local f, n, l, s, ss, locs;

    if Length(nr) > 0 and IsPosInt(nr[1]) then
      n := nr[1];
    else
      n := 1;
    fi;
    l := fail;
    f := FILENAME_FUNC( fun );
    if IsString(f) and Length(f)>0 and f[1] <> '/' then
      # first assume it is a local path, otherwise look in GAP roots
      if not IsReadableFile(f) then
        if Length(f) > 7 and f{[1..8]} = "GAPROOT/" then
          f := f{[9..Length(f)]};
        fi;
        f := Filename(List(GAPInfo.RootPaths, Directory), f);
      fi;
    fi;
    if f = fail and fun in OPERATIONS then
      # for operations we show the location(s) of their declaration
      locs := GET_DECLARATION_LOCATIONS(fun);
      if n > Length(locs) then
        Print("Operation ", NameFunction(fun), " has only ",
              Length(locs), " declarations.\n");
        return;
      else
        if Length(locs) > 1 then
          Print("Operation ", NameFunction(fun), " has ",
                Length(locs), " declarations, showing number ", n, ".\n");
        fi;
        f := locs[n][1];
        l := locs[n][2];
      fi;
    fi;
    if f <> fail then
        if l = fail then
          l := STARTLINE_FUNC( fun );
          if l <> fail then
              l := Maximum(l-5, 1);
          elif IsKernelFunction(fun) then
              # page correct C source file and try to find line in C
              # source starting `Obj Func<fun>`
              s := String(fun);
              ss:=SplitString(s,""," <>");
              s := First(ss, a-> ':' in a);
              if s <> fail then
                ss := SplitString(s,":","");
                l := Concatenation("/Obj *Func", ss[2]);
              fi;
          fi;
        fi;
    fi;
    if f = fail or l = fail then
        if IsKernelFunction(fun) then
          Print("Cannot locate source of kernel function ",
                 NameFunction(fun),".\n");
        else
          Print( "Source not available.\n" );
        fi;
    elif not (IsExistingFile(f) and IsReadableFile(f)) then
        Print( "Cannot access code from file \"",f,"\".\n");
    else
        Print( "Showing source in ", f, " (from line ", l, ")\n" );
        Pager(rec(lines := StringFile(f), formatted := true, start := l));
    fi;
end);
