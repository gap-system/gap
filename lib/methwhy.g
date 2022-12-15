#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke.
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
  if val>SUM_FLAGS and val < infinity then
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
##  <Mark>6</Mark>
##  <Item>
##      also the function body of the selected method(s)
##  </Item>
##  </List>
##  <P/>
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
local oper,narg,args,skip,verbos,fams,flags,i,j,methods,flag,flag2,
      m,nam,val,erg,has,need,isconstructor;
  if Length(arg)<2 or not IsList(arg[2]) or not IsFunction(arg[1]) then
    Error("usage: ApplicableMethodTypes(<opr>,<arglist>[,<verbosity>[,<nr>]])");
  fi;
  oper:=arg[1];
  isconstructor:=IS_CONSTRUCTOR(oper);
  args:=arg[2];
  if Length(arg)>2 then
    verbos:=arg[3];
  else
    verbos:=0;
  fi;
  if Length(arg)>3 then
    if IsInt( arg[4] ) then
      skip:=arg[4] - 1;
    else
      skip:= -1;
    fi;
    erg:=[];
  else
    skip:=0;
  fi;
  narg:=Length(args);

  # get families and filters
  flags:=[];
  fams:=[];
  for i in args do
    if IsFilter(i) then
      Add(flags,WITH_IMPS_FLAGS(FLAGS_FILTER(i)));
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

  methods:=MethodsOperation(oper,narg);
  if verbos > 0 then
    Print("#I  Searching Method for ",NameFunction(oper)," with ",
          Pluralize(narg, "argument"), ":\n");
  fi;
  if verbos > 0 then
    Print("#I  Total: ", Pluralize(Length(methods), "entry"), "\n");
  fi;
  for i in [1..Length(methods)] do
    m := methods[i];
    nam:=m.info;
    val:=m.rank;
    oper:=m.func;
    if verbos>1 then
      Print("#I  Method ",i,": ``",nam,"''");
      if IsBound(m.location) then
        Print(" at ", m.location[1], ":", m.location[2]);
      elif LocationFunc(oper) <> fail then
        Print(" at ",LocationFunc(oper));
      fi;
      Print(", value: ");
      Print_Value_SFF(val);
      Print("\n");
    fi;
    flag:=true;
    j:=1;
    while j<=narg and (flag or verbos>3) and not m.early do
      if j=1 and isconstructor then
        flag2:=IS_SUBSET_FLAGS(m.argFilt[j],flags[j]);
      else
        flag2:=IS_SUBSET_FLAGS(flags[j],m.argFilt[j]);
      fi;
      flag:=flag and flag2;
      if flag2=false and verbos>2 then
        need:=NamesFilter(m.argFilt[j]);
        if j=1 and isconstructor then
          Print("#I   - ",Ordinal(j)," argument must be ",
                need,"\n");
        else
          has:=NamesFilter(flags[j]);
          Print("#I   - ",Ordinal(j)," argument needs ",
                Filtered(need,i->not i in has),"\n");
        fi;
      fi;
      j:=j+1;
    od;
    if flag then
      if m.early or fams=fail or CallFuncList(m.famPred,fams) then
        if verbos=1 then
          Print("#I  Method ",i,": ``",nam,"''");
          if IsBound(m.location) then
            Print(" at ", m.location[1], ":", m.location[2]);
          elif LocationFunc(oper) <> fail then
            Print(" at ",LocationFunc(oper));
          fi;
          Print(" , value: ");
          Print_Value_SFF(val);
          Print("\n");
        fi;
        if verbos>5 then
          Print("#I  Function Body:\n");
          Print(oper);
        fi;
        if skip=0 then
          return oper;
        else
          Add(erg,oper);
          skip:=skip-1;
          if verbos>0 then
            Print("#I  Skipped:\n");
          fi;
        fi;
      elif verbos>2 then
        Print("#I   - bad family relations\n");
      fi;
    fi;
  od;
  if skip<0 then
    return erg;
  else
    return fail;
  fi;
end);

BIND_GLOBAL("ApplicableMethod",function(arg)
local i,l;
  if Length(arg)<2 or not IsList(arg[2]) or not IsFunction(arg[1]) then
    Error("usage: ApplicableMethod(<opr>,<arglist>[,<verbosity>[,<nr>]])");
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
#F  ShowDeclarationsOfOperation( <oper> )
##
##  <#GAPDoc Label="ShowDeclarationsOfOperation">
##  <ManSection>
##  <Func Name="ShowDeclarationsOfOperation" Arg='oper'/>
##
##  <Description>
##  Displays information about all declarations of the operation <A>oper</A>,
##  including the location of each declaration and the argument filters.
##  <Log><![CDATA[
##  gap> ShowDeclarationsOfOperation(IsFinite);
##  Available declarations for operation <Property "IsFinite">:
##    1: GAPROOT/lib/coll.gd:1451 with 1 argument, and filters [ IsListOrCollection ]
##    2: GAPROOT/lib/float.gd:212 with 1 argument, and filters [ IsFloat ]
##    3: GAPROOT/lib/ctbl.gd:1195 with 1 argument, and filters [ IsNearlyCharacterTable ]
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("ShowDeclarationsOfOperation",function(oper)
    local locs, reqs, i, r, f;
    if not IsOperation(oper) then
        Error("<oper> must be an operation");
    fi;
    Print("Available declarations for operation ", oper, ":\n");
    locs := GET_DECLARATION_LOCATIONS(oper);
    if locs = fail then
        return;
    fi;
    reqs := GET_OPER_FLAGS(oper);
    f := function(filt)
             filt:=NamesFilter(filt);
             if Length(filt) = 0 then filt := ["IsObject"]; fi;
             return filt;
         end;
    for i in [1.. Length(locs)] do
        r := List(reqs[i], r -> JoinStringsWithSeparator(f(r), " and \c"));
        Print(String(i, 3), ": ", locs[i][1], "\c:", locs[i][2], "\c",
              " with ", Length(reqs[i]), "\c",
              " arguments, and filters [ ", "\c",
              JoinStringsWithSeparator(r, ", "),
              " ]\n"
              );
    od;
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
              Length(locs), " declarations. ",
              "To find an installed method see ?ApplicableMethod.\n");
        return;
      else
        if Length(locs) > 1 then
          Print("Operation ", NameFunction(fun), " has ",
                Length(locs), " declarations, showing number ", n, ". ",
                "To find an installed method see ?ApplicableMethod.\n");
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
