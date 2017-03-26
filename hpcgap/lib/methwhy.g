#############################################################################
##
#W  methwhy.g                  GAP tools                    Alexander Hulpke
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
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
local oper,l,obj,skip,verbos,fams,flags,i,j,methods,flag,flag2,
      lent,nam,val,erg,has,need,isconstructor;
  if Length(arg)<2 or not IsList(arg[2]) or not IsFunction(arg[1]) then
    Error("usage: ApplicableMethodTypes(<opr>,<arglist>[,<verbosity>[,<nr>]])");
  fi;
  oper:=arg[1];
  isconstructor:=IS_CONSTRUCTOR(oper);
  obj:=arg[2];
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
  l:=Length(obj);

  # get families and filters
  flags:=[];
  fams:=[];
  for i in obj do
    if IsFilter(i) or IsIdenticalObj( i, IsObject ) then
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

  methods:=METHODS_OPERATION(oper,l);
  if verbos > 0 then
    Print("#I  Searching Method for ",NameFunction(oper)," with ",l,
	  " arguments:\n");
  fi;
  lent:=4+l; #length of one entry
  if verbos > 0 then 
    Print("#I  Total: ", Length(methods)/lent," entries\n");
  fi;
  for i in [1..Length(methods)/lent] do
    nam:=methods[lent*(i-1)+l+4];
    val:=methods[lent*(i-1)+l+3];
    oper:=methods[lent*(i-1)+l+2];
    if verbos>1 then
      Print("#I  Method ",i,": ``",nam,"''");
      if LocationFunc(oper) <> "" then
        Print(" at ",LocationFunc(oper));
      fi;
      Print(", value: ");
      Print_Value_SFF(val);
      Print("\n");
    fi;
    flag:=true;
    j:=1;
    while j<=l and (flag or verbos>3) do
      if j=1 and isconstructor then
	flag2:=IS_SUBSET_FLAGS(methods[lent*(i-1)+1+j],flags[j]);
      else
	flag2:=IS_SUBSET_FLAGS(flags[j],methods[lent*(i-1)+1+j]);
      fi;
      flag:=flag and flag2;
      if flag2=false and verbos>2 then
	need:=NamesFilter(methods[lent*(i-1)+1+j]);
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
      if fams=fail or CallFuncList(methods[lent*(i-1)+1],fams) then
	oper:=methods[lent*(i-1)+j+1];
	if verbos=1 then
	  Print("#I  Method ",i,": ``",nam,"''");
	  if LocationFunc(oper) <> "" then
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
##  Displays information about the filters that may be implied by 
##  <A>filter</A>. They are given by their names. <C>ShowImpliedFilters</C> first
##  displays the names of all filters that are unconditionally implied by
##  <A>filter</A>. It then displays implications that require further filters to
##  be present (indicating by <C>+</C> the required further filters).
##  The function displays only first-level implications, implications that
##  follow in turn are not displayed (though &GAP; will do these).
##  <Example><![CDATA[
##  gap> ShowImpliedFilters(IsMatrix);
##  Implies:
##     IsGeneralizedRowVector
##     IsNearAdditiveElementWithInverse
##     IsAdditiveElement
##     IsMultiplicativeElement
##  
##  
##  May imply with:
##  +IsGF2MatrixRep
##     IsOrdinaryMatrix
##  
##  +CategoryCollections(CategoryCollections(IsAdditivelyCommutativeElement))
##     IsAdditivelyCommutativeElement
##  
##  +IsInternalRep
##     IsOrdinaryMatrix
##  
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL("ShowImpliedFilters",function(fil)
local flags,f,i,j,l,m,n;
  flags:=FLAGS_FILTER(fil);
  atomic readonly IMPLICATIONS do
      f:=Filtered(IMPLICATIONS,x->IS_SUBSET_FLAGS(x[2],flags));
  l:=[];
  m:=[];
    for i in f do
      n:=SUB_FLAGS(i[2],flags); # the additional requirements
      if SIZE_FLAGS(n)=0 then
        Add(l,i[1]);
      else
        Add(m,[n,i[1]]);
      fi;
    od;
  od;
  if Length(l)>0 then
    Print("Implies:\n");
    for i in l do
      for j in NamesFilter(i) do
	Print("   ",j,"\n");
      od;
    od;
  fi;
  if Length(m)>0 then
    Print("\n\nMay imply with:\n");
    for i in m do
      for j in NamesFilter(i[1]) do
        Print("+",j,"\n");
      od;
      for j in NamesFilter(i[2]) do
        Print("   ",j,"\n");
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
##  <Func Name="PageSource" Arg='func'/>
##
##  <Description>
##  This shows the file containing the source code of the function or method
##  <A>func</A> in a pager (see <Ref Func="Pager"/>). The display starts at 
##  a line shortly before the code of <A>func</A>.<P/>
##  
##  This function works if <C>FilenameFunc(<A>func</A>)</C> returns the name of
##  a proper file. In that case this filename and the position of the 
##  function definition are also printed.
##  Otherwise the function indicates that the source is not available 
##  (for example this happens for functions which are implemented in 
##  the &GAP; C-kernel).<P/>
##  
##  Usage examples:<Br/>
##  <C>met := ApplicableMethod(\^, [(1,2),2743527]); PageSource(met);</C><Br/>
##  <C>PageSource(Combinations);</C><Br/>
##  <C>ct:=CharacterTable(Group((1,2,3))); </C><Br/>
##  <C>met := ApplicableMethod(Size,[ct]); PageSource(met); </C>
##  <P/>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
BIND_GLOBAL("PageSource", function ( fun )
    local f, l;
    f := FILENAME_FUNC( fun );
    if f = fail then
        if IsKernelFunction(fun) then
          Print("Cannot locate source of kernel function ",
                 NameFunction(fun),".\n");
        else
          Print( "Source not available.\n" );
        fi;
    elif not (IsExistingFile(f) and IsReadableFile(f)) then
        Print( "Cannot access code from file \"",f,"\".\n");
    else
        l := Maximum(STARTLINE_FUNC( fun )-5, 1);
        Print( "Showing source in ", f, " (from line ", l, ")\n" );
        # Exec( Concatenation( "view +", String( l ), " ", f ) );
        Pager(rec(lines := StringFile(f), formatted := true, start := l));
    fi;
end);

#############################################################################
##
#E

