#############################################################################
##
#W  formation.gi                    FORMAT                       Bettina Eick
#W                                      conversion from GAP3 by C.R.B. Wright 
##
Revision.("format/lib/formation.gi") :=
    "@(#)$Id: formation.gi,v 1.6 2000/10/31 17:16:29 gap Exp $";

#############################################################################
#M  \= ( <form1> , <form2> ) . . . . . . .formation equality defined by names
##  

InstallMethod(\=, "for formations", IsIdenticalObj, 
  [IsFormation, IsFormation],0,
function( form1, form2 )
return NameOfFormation(form1) = NameOfFormation(form2);
end);

#############################################################################
#M \< ( <form1> , <form2> ). . . . . . . . . .to enable KeyDependentOperation
##

InstallMethod(\<, "for formations", IsIdenticalObj, 
  [IsFormation,IsFormation],0,
function( form1, form2 )
return NameOfFormation(form1) < NameOfFormation(form2);
end);

#############################################################################
#M  PrintObj( <form> ) . . . . . . . . . . . . . . . . . . .print a formation
##
InstallMethod(PrintObj, "for a formation", true, [ IsFormation ], 0,
function( form )
Print("formation of ", NameOfFormation(form), " groups ");
if HasSupportOfFormation(form) and not ("Changed" = NameOfFormation(form){[1..7]}) then
  Print("with support ", SupportOfFormation(form));
fi;
end);

#############################################################################
#M Intersection2( <form1>,<form2> ) . . . . . . . .intersection of formations
##

InstallOtherMethod(Intersection2, "intersection of formations", 
    IsIdenticalObj,
  [IsFormation,IsFormation], 0, 
function(form1,form2)
  local newdata,form;
  
  newdata:=rec();
    
  # get the name
  if NameOfFormation(form1) <= NameOfFormation(form2) then
    newdata.name:=Concatenation("(", NameOfFormation(form1), "And", NameOfFormation(form2), ")");
  else newdata.name:=Concatenation("(",NameOfFormation(form2),"And",
      NameOfFormation(form1), ")");
  fi;
  
  if HasResidualFunctionOfFormation(form1) or 
      HasResidualFunctionOfFormation(form2) then
    newdata.fResidual := function (group)
      local fres1,    # <form1>-residual of group
            fres2;    # <form2>-residual of group
  
      fres1 := ResidualWrtFormation(group, form1);
      fres2 := ResidualWrtFormation(group, form2);
      return  ClosureGroup(fres1, fres2);
    end;
  fi;
	  
  # if both have a screen, then the intersection will too
  if HasScreenOfFormation(form1) and HasScreenOfFormation(form2) then
    newdata.fScreen:=function(G,p)
      local L1, L2;
      L1:=ScreenOfFormation(form1)(G,p);
      L2:=ScreenOfFormation(form2)(G,p);
      if IsList( L1 ) or IsList( L2 ) then
        return [ ];
      else
        return ClosureGroup( L1, L2 );
      fi;
    end;
  fi;
 
  # turn newdata into a formation
  form:=Formation(newdata);
  
  # now add the support
  if HasSupportOfFormation(form1) and HasSupportOfFormation(form2) then 
    SetSupportOfFormation(form,
      Intersection(SupportOfFormation(form1),SupportOfFormation(form2)));
  elif HasSupportOfFormation(form1) then 
    SetSupportOfFormation(form,SupportOfFormation(form1));
  elif HasSupportOfFormation(form2) then 
    SetSupportOfFormation(form,SupportOfFormation(form2));
  fi;
 
  # check if integrated
  if HasIsIntegrated(form1) and HasIsIntegrated(form2) and
      IsIntegrated(form1) and IsIntegrated(form2) then
    SetIsIntegrated(form,true);
  fi;

  return form;
  end);

#############################################################################
#M ProductOfFormations( <form1>,<form2> )
## Reference Doerk-Hawkes, especially proof of IV(3.13)(case i).

InstallMethod(ProductOfFormations, "product of formations", IsIdenticalObj,
  [IsFormation,IsFormation], 0, 
function(form1,form2)
  local newdata, form;

  newdata := rec();

# make the name
  newdata.name := Concatenation("(", NameOfFormation(form1), "By", NameOfFormation(form2), ")");

  # compute screen if possible [even if form2 is not given integrated]
  if HasScreenOfFormation(form1) and 
      (HasScreenOfFormation(form2) or not HasSupportOfFormation(form1)) then
    newdata.fScreen := function(G,p)
      local R, L;
      R := ResidualWrtFormation(G, form2);
      L := ScreenOfFormation(form1)(R, p);
      if not IsList(L) then
        return L;
      else
        return ScreenOfFormation(Integrated(form2))(G, p);
      fi;
    end;
  fi;

  # compute ResidualFunctionOfFormation in any case
  newdata.fResidual := function(G)
    local R;
    R := ResidualWrtFormation(G, form2);
    return ResidualWrtFormation(R, form1);
  end;
  
  # turn newdata into a formation
  form:=Formation(newdata);
   
  # add support
  if HasSupportOfFormation(form1) and HasSupportOfFormation(form2) then
    SetSupportOfFormation(form, 
        Union(SupportOfFormation(form1), SupportOfFormation(form2)));
  fi;
  
  # check if integrated
  if HasIsIntegrated(form1) and HasIsIntegrated(form2) and
      IsIntegrated(form1) and IsIntegrated(form2) then
    SetIsIntegrated(form,true);
  fi;
  
  return form;
end);


#############################################################################
#M Integrated( <form> ) . . . . . gives <form> an integrated local definition
##

InstallMethod(Integrated, "for a formation with screen given",
true, [IsFormation and HasScreenOfFormation], 0,
function( form )
  local newform, result;

  # change nothing usually
  if HasIsIntegrated(form) and IsIntegrated(form) then
    return form;
  fi;

  newform := rec();

  # change the name
  newform.name := Concatenation(NameOfFormation(form),"Int");

  # and the screen
  newform.fScreen := function( G, p )
    local R, L;
    R := ResidualWrtFormation(G, form);
    L := ScreenOfFormation(form)(G, p);
    if not IsList(L) then
      return ClosureGroup(R, L);
    else
      return [];
    fi;
  end;

  # now make it a formation  
  result := Formation(newform);
  
  SetIsIntegrated(result, true);

  if HasSupportOfFormation(form) then
    SetSupportOfFormation(result, SupportOfFormation(form));
  fi;

  return result;
end);


#############################################################################
#M ChangedSupport( <form>,<support> ) . . . . . . cuts down support of <form>
## 

InstallMethod(ChangedSupport, "reduces support", true,
[IsFormation, IsList], 0,
function( form,support )
  local p, newform, result;

  for p in support do
    if not IsPrimeInt(p) then
      Error( p, " in ", support, " is not a prime.\n" );
    fi;
  od;

  # set up record
  newform := rec();

  if HasSupportOfFormation(form) then
    newform.support := Intersection( SupportOfFormation(form), support );
  else
    newform.support := support;
  fi;

  newform.name := Concatenation("Changed",NameOfFormation(form),String(support));

  if HasScreenOfFormation(form) then
    newform.fScreen := function( G, p )
      if not p in newform!.support then
        return [];
      else
        return ScreenOfFormation(form)(G, p);
      fi;
    end;
  fi;

  if HasResidualFunctionOfFormation(form) then
    newform.fResidual := function( G )
      local R1, R2;
      R1 := ResidualWrtFormation(G, form);
      R2 := PiResidual( G, newform!.support );
      return ClosureGroup( R1, R2 );
    end;
  fi;

  result := Formation(newform);
  if HasIsIntegrated(form) and IsIntegrated(form) then
    SetIsIntegrated(result, true);
  fi;
  return result;
end);
      
#############################################################################
#M  Formation( <record> ). . . . . . . . . constructs formations from records
##

InstallMethod( Formation, "from record", true, [IsRecord], 0,
function( record )
  local form;  # result

  if not IsBound(record.name) then Error("record needs a name"); fi;
  
  if (not IsBound(record.fResidual) and not IsBound(record.fScreen))
    then Error("record needs a residual function or screen");
  fi;

  form:=Objectify(FormationType,record);

  SetNameOfFormation(form,form!.name);
  if IsBound(form!.isIntegrated) then SetIsIntegrated(form,
    form!.isIntegrated);
  fi;
  if IsBound(form!.support) then 
      SetSupportOfFormation(form,form!.support);
  fi;
  if IsBound(form!.fResidual) then 
    SetResidualFunctionOfFormation(form,form!.fResidual);
  fi;
  if IsBound(form!.fScreen) then 
      SetScreenOfFormation(form,form!.fScreen);
  fi;

  return form;
end);

#############################################################################
#M  Formation( <name> ). . . . . . . . . . . . constructs standard formations
##

InstallMethod( Formation, "from name", true, [IsString], 0,
function( name )
  local form;  # result

  if not name in ["Nilpotent", "Supersolvable", "Abelian",  
    "ElementaryAbelianProduct", "PiGroups", "PNilpotent", "PLengthOne"] then
    Error( name, "is not in list of standard formations.");
  fi;

  if name = "PiGroups" then
    Error("Usage: Formation( ", name, " [<primes>])");
  fi;
  if name in ["PLengthOne", "PNilpotent"] then
    Error("Usage: Formation( ", name, " <primes>)");
  fi;

  # set up formation record
  form := rec( );

  form.name := name;

  # compute screen and/or residual function
  if name = "Nilpotent" then
    form.fScreen:= function( G, p) return G; end;
    form.fResidual     := NilpotentResidual;
    form.isIntegrated  := true;
  elif name = "Supersolvable" then
    form.fScreen:= AbelianExponentResidual;
    form.isIntegrated  := true;
  elif name = "Abelian" then
    form.fResidual := DerivedSubgroup;
  elif name = "ElementaryAbelianProduct" then
    form.fResidual := ElementaryAbelianProductResidual;
  fi;
  return Formation(form);
end);

#############################################################################
#M  Formation( <name>, <primes> ). . . . . . . constructs standard formations
##

InstallOtherMethod( Formation, "from name and primes", true, [IsString, IsList],0,
function( name, pi )
  local p, form, newname, i;  

  if Length(pi) = 0 then
    Error(name, " wants at least one prime.");
  fi;

  if not name = "PiGroups" then
    if Length(pi) = 1 then return Formation( name, pi[1] ); fi;
    Error(name, " does not take a list as second argument.");
  fi;

  for p in pi do
    if not IsPrimeInt(p) then
      Error( pi, " is not a list of primes.");
    fi;
  od;
  
  form := rec();
  
  newname := Concatenation("(",String( pi[1] ));
  for i in [2..Length(pi)] do
    newname := Concatenation( newname, ",", String( pi[i] ));
  od;
  newname := Concatenation( newname, ")-Group");
  form.name := newname;

  form.fScreen:= function( G, p )
    if p in pi then
      return PiResidual( G, pi );
    else
      return [];
    fi;
  end;
  form.isIntegrated  := true;
  form.fResidual := function( G )
    return PiResidual( G, pi );
  end;
  form.support := pi;

  return Formation(form);
end);


#############################################################################
#M  Formation( <name>, <prime> ). . . . . . . .constructs standard formations
##

InstallOtherMethod( Formation, "from name and prime", true, [IsString, IsPosInt], 0,
function( name, prime )
  local form, p;  

  if not IsPrimeInt(prime) then
    Error(prime, " must be prime in ", name);
  fi;

  if not name in ["PNilpotent", "PLengthOne"] then
    Error( name, " does not look familiar.");
  fi;

  form := rec();

  if name = "PNilpotent" then
    form.name := Concatenation( String(prime), "Nilpotent" );
  elif name = "PLengthOne" then
    form.name := Concatenation( String(prime), "LengthOne" );
  fi;

  if name = "PNilpotent" then
    form.fScreen:= function( G, p )
      local N;
      N := PResidual( G, p );
      if p = prime then
        return N;
      else
        return CoprimeResidual( N, [prime] );
      fi;
    end;
    form.isIntegrated  := true;
    form.fResidual := function( G )
      local N;
      N := PResidual( G, prime );
      return CoprimeResidual( N, [prime] );
    end;
  elif name = "PLengthOne" then
    form.fScreen:= function( G, p )
      local N;
      N := CoprimeResidual( G, [prime] );
      if p = prime then
        return N;
      else
        N := PResidual( N, prime );
        return CoprimeResidual( N, [prime] );
      fi;
    end;
    form.isIntegrated  := true;
    form.fResidual := function( G )
      local N;
      N := CoprimeResidual( G, [prime] );
      N := PResidual( N, prime );
      return CoprimeResidual( N, [prime] );
    end;
  fi;
  return Formation(form);
end);

#E  End of formation.gi

