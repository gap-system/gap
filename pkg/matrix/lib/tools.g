# We want to be able to overwrite attributes from an ``unknown'' value to a
# proper value. Therefore we cannot use the default attribute mechanism, but
# have to use an own mechanism. To distinguish from the standard
# asttributes, we use `Hat'... and `Setz'... for tester and setter.

BindGlobal("UNKNOWN","unknown");
# private properties are stored as part of an info record

RCMETHS:=[];
RCDEDS:=[];

BindGlobal("DeclareRCAttribute",function(string)
local setter;
  setter:=function(I,val)
	  local i;
	    if IsBound(I.(string)) and I.(string)<>val 
	       and I.(string)<>UNKNOWN then
	      Error("value changed");
	    fi;
	    I.(string):=val; 

	    # all deductions
	    for i in RCDEDS do
	      if i[1]=string then
	        i[2](I);
	      fi;
	    od;
	  end;

  BindGlobal(string,function(I)
             local p;
	       if not IsBound(I.(string)) then
		 p:=PositionProperty(RCMETHS,i->i[1]=string);
		 if p=fail then
		   Error("no method");
		 fi;
	         setter(I,RCMETHS[p][2](I));
	       fi;
	       return I.(string); 
             end);
  BindGlobal(Concatenation("Hat",string),function(I)
	       return IsBound(I.(string)); 
             end);
  BindGlobal(Concatenation("Setz",string),setter);
end);

#RCTester:=function(attr)
#local s;
#  s:=NameFunction(attr);
#  return x->IsBound(x.(s));
#end;

BindGlobal("InstallRCDeduction",function(func,meth)
  Add(RCDEDS,[NameFunction(func),meth]);
end);

BindGlobal("InstallRCMethod",function(func,meth)
local n,p;
  n:=NameFunction(func);
  p:=PositionProperty(RCMETHS,i->i[1]=n);
  if p=fail then
    Add(RCMETHS,[NameFunction(func),meth]);
  else
    RCMETHS[p][2]:=meth;
  fi;
end);

#RCIMPLICATIONS:=[];
#
#DoRCImplications:=function(I,string)
#local i,vals,str,new;
#  new:=[string];
#  repeat
#    vals:=[];
#    for i in RCIMPLICATIONS do
#      for str in new do
#	if str in i[1] 
#	  # potential new method
#	  and ForAll(i[1],j->IsBound(I.(j)) and I.(j)=i[2]) then
#	    # indeed, conditions fulfilled
#	    Add(vals,i[3]);
#	fi;
#      od;
#    od;
#    new:=[];
#    for i in vals do
#      if IsBound(I.(i[1])) and I.(i[1])<>i[2] then
#        Error("inconsistent implications");
#      fi;
#      I.(i[1]):=i[2];
#      Add(new,i[1]);
#    od;
#  # until no new implication
#  until Length(vals)=0;
#end;
#
#InstallRCTrueMethod:=function(result,condition)
#local i;
#  if not IsList(condition) then condition:=[condition];fi;
#  for i in [1..Length(condition)] do
#    if IsFunction(condition[i]) then
#      condition[i]:=NameFunction(condition[i]);
#    fi;
#  od;
#  if IsFunction(result) then result:=NameFunction(result);fi;
#  Add(RCIMPLICATIONS,[condition,true,[result,true]]);
#  if Length(condition)=1 then
#    # contraposition 
#    Add(RCIMPLICATIONS,[[result],false,[condition[1],false]]);
#  fi;
#end;

