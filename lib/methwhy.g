#############################################################################
##
#W  methwhy.g                  GAP tools                    Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file allows some fancy accesses to the method selection
##
Revision.methwhy_g :=
    "@(#)$Id$";

#############################################################################
##
#F  Print_Value(val)   print a number factorized by SUM_FLAGS
##
Print_Value := function(val)
  if val>SUM_FLAGS then
    Print(QuoInt(val,SUM_FLAGS),"*SUM_FLAGS");
    val:=val mod SUM_FLAGS;
    if val>0 then
      Print("+",val);
    fi;
  else
    Print(val);
  fi;
end;

#############################################################################
##
#F  MethodXArgs(<operation>,<arglist>[,<verbosity>[,<skip>]])
##
##  verbosity:
##    1: Print information about selected method
##    2: Print information about each method encountered
##    3: Print first reason for discarding
##    4: Print reasons for discarding in all arguments
##  if skip is negative, all methods will be tried. In this case, a list of
##  all possible methods is returned.
MethodXArgs := function(arg)
local oper,l,obj,skip,verbos,fams,type,i,j,methods,flag,flag2,lent,nam,val,
      erg,has,need;
  if Length(arg)<2 or not IS_LIST(arg[2]) or not IS_FUNCTION(arg[1]) then
    Error("usage: MethodXArgs(<operation>,<arglist>[,<verbosity>[,<skip>]])");
  fi;
  oper:=arg[1];
  obj:=arg[2];
  if Length(arg)>2 then
    verbos:=arg[3];
  else
    verbos:=0;
  fi;
  if Length(arg)>3 then
    skip:=arg[4];
    erg:=[];
  else
    skip:=0;
  fi;
  l:=Length(obj);
  if verbos<>0 then
    Print("Searching Method for ",NAME_FUNCTION(oper)," with ",l,
	  " arguments:\n");
  fi;
  type:=[];
  fams:=[];
  for i in obj do
    Add(type,TypeObj(i));
    Add(fams,FamilyObj(i));
  od;
  methods:=METHODS_OPERATION(oper,l);
  lent:=4+l; #length of one entry
  if verbos<>0 then 
    Print("Total :",LEN_LIST(methods)/lent," entries\n");
  fi;
  for i in [1..LEN_LIST(methods)/lent] do
    nam:=methods[lent*(i-1)+l+4];
    val:=methods[lent*(i-1)+l+3];
    if verbos>1 then
      Print("Method ",i,": ``",nam,"'', value: ");
      Print_Value(val);
      Print("\n");
    fi;
    flag:=true;
    j:=1;
    while j<=l and (flag or verbos>3) do
      flag2:=IS_SUBSET_FLAGS(type[j]![2],methods[lent*(i-1)+1+j]);
      flag:=flag and flag2;
      if flag2=false and verbos>2 then
	need:=NamesFilter(methods[lent*(i-1)+1+j]);
	has:=NamesFilter(type[j]![2]);
        Print(" - ",Ordinal(j)," argument needs ",
	      Filtered(need,i->not i in has),"\n");
      fi;
      j:=j+1;
    od;
    if flag then
      if CallFuncList(methods[lent*(i-1)+1],fams) then
	if verbos=1 then
	  Print("Method ",i,": ``",nam,"'', value: ");
	  Print_Value(val);
	  Print("\n");
	fi;
	oper:=methods[lent*(i-1)+j+1];
	if skip=0 then
	  nam:=NAME_FUNCTION(oper);
	  if Length(nam)>5 and nam{[1..6]}="Getter" then
	    Print("\n#W  Warning: System getter!\n");
	  fi;
	  return oper;
	else
	  Add(erg,oper);
	  skip:=skip-1;
	  if verbos>0 then
	    Print("Skipped:\n");
	  fi;
        fi;
      elif verbos>2 then
        Print(" - bad family relations\n");
      fi;
    fi;
  od;
  if skip<0 then
    return erg;
  else
    return fail;
  fi;
end;


#############################################################################
##
#E  methwhy.g . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
