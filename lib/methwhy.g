#############################################################################
##
#W  methwhy.g                  GAP tools                    Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file allows some fancy accesses to the method selection
##
Revision.methwhy_g :=
    "@(#)$Id$";

#############################################################################
##
#F  Print_Value(<val>)   
##  print a number factorized by SUM_FLAGS
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
#F  ApplicableMethod( <opr>, <args> [, <printlevel> ] )
#F  ApplicableMethod( <opr>, <args>, <printlevel>, <nr> )
#F  ApplicableMethod( <opr>, <args>, <printlevel>, "all" )
#F  ApplicableMethodTypes( <opr>, <args> [, <printlevel> ] )
#F  ApplicableMethodTypes( <opr>, <args>, <printlevel>, <nr> )
#F  ApplicableMethodTypes( <opr>, <args>, <printlevel>, "all" )
##
##  In the first form, `ApplicableMethod' returns the method of highest rank
##  that is applicable for the operation <opr> with the arguments in the
##  list <args>.
##  The default <printlevel> is `0'.
##  If no method is applicable then `fail' is returned.
##
##  In the second form, if <nr> is a positive integer then
##  `ApplicableMethod' returns the <nr>-th applicable method for the
##  operation <opr> with the arguments in the list <args>, where the methods
##  are ordered according to descending rank.  If less than <nr> methods are
##  applicable then `fail' is returned.
##
##  If the fourth argument is the string `"all"' then `ApplicableMethod'
##  returns a list of all applicable methods for <opr> with arguments
##  <args>, ordered according to descending rank.
##
##  Depending on the integer value <printlevel>, additional information is
##  printed.  Admissible values and their meaning are as follows.
##
##  \beginlist
##  \item{0}
##      no information,
##  
##  \item{1}
##      information about the applicable method,
##  
##  \item{2}
##      also information about the not applicable methods of higher rank,
##  
##  \item{3}
##      also for each not applicable method the first reason why it is not
##      applicable,
##  
##  \item{4}
##      also for each not applicable method all reasons why it is not
##      applicable.
##
##  \item{6}
##      also the function body of the selected method(s)
##  \endlist
##  
##  When a method returned by `ApplicableMethod' is called then it returns
##  either the desired result or the string `TRY_NEXT_METHOD', which
##  corresponds to a call to `TryNextMethod' in the method and means that
##  the method selection would call the next applicable method.
##
##  *Note:* The kernel provides special treatment for the infix operations
##  `\\+', `\\-', `\\*', `\\/', `\\^', `\\mod' and `\\in'. For some kernel
##  objects (notably cyclotomic numbers, finite field elements and vectors
##  thereof) it calls kernel methods circumventing the method selection
##  mechanism. Therefore for these operations `ApplicableMethod' may return
##  a method which is not the kernel method actually used.
##
##  The function `ApplicableMethodTypes' takes the *types* or *filters* of
##  the arguments as argument (if only filters are given of course family
##  predicates cannot be tested).
BIND_GLOBAL("ApplicableMethodTypes",function(arg)
local oper,l,obj,skip,verbos,fams,flags,i,j,methods,flag,flag2,
      lent,nam,val,erg,has,need;
  if Length(arg)<2 or not IsList(arg[2]) or not IsFunction(arg[1]) then
    Error("usage: ApplicableMethodTypes(<opr>,<arglist>[,<verbosity>[,<nr>]])");
  fi;
  oper:=arg[1];
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
    if verbos>1 then
      Print("#I  Method ",i,": ``",nam,"'', value: ");
      Print_Value_SFF(val);
      Print("\n");
    fi;
    flag:=true;
    j:=1;
    while j<=l and (flag or verbos>3) do
      flag2:=IS_SUBSET_FLAGS(flags[j],methods[lent*(i-1)+1+j]);
      flag:=flag and flag2;
      if flag2=false and verbos>2 then
	need:=NamesFilter(methods[lent*(i-1)+1+j]);
	has:=NamesFilter(flags[j]);
        Print("#I   - ",Ordinal(j)," argument needs ",
	      Filtered(need,i->not i in has),"\n");
      fi;
      j:=j+1;
    od;
    if flag then
      if fams=fail or CallFuncList(methods[lent*(i-1)+1],fams) then
	if verbos=1 then
	  Print("#I  Method ",i,": ``",nam,"'', value: ");
	  Print_Value_SFF(val);
	  Print("\n");
	fi;
	oper:=methods[lent*(i-1)+j+1];
	if verbos>5 then
	  Print("#I  Function Body:\n");
	  Print(oper);
	fi;
	if skip=0 then
#	  nam:=NameFunction(oper);
#if not IsString(nam) then
#  Error("name!");
#fi;
#Print("\nname=",nam,"\n");
#	  if Length(nam)>5 and nam{[1..6]}="Getter" then
#	    Print("\n#W  Warning: System getter!\n");
#	  fi;
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
    l[i]:=TypeObj(l[i]);
  od;
  arg[2]:=l;
  return CallFuncList(ApplicableMethodTypes,arg);
end);

#############################################################################
##
#F  ShowImpliedFilters( <filter> )
##
##  Displays information about the filters that may be implied by 
##  <filter>. They are given by their names. `ShowImpliedFilters' first
##  displays the names of all filters that are unconditionally implied by
##  <filter>. It then displays implications that require further filters to
##  be present (indicating by `+' the required further filters).
##  The function displays only first-level implications, implications that
##  follow in turn are not displayed (though {\GAP} will do these).
BIND_GLOBAL("ShowImpliedFilters",function(fil)
local flags,f,i,j,l,m,n;
  flags:=FLAGS_FILTER(fil);
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
#E  methwhy.g . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
