#############################################################################
##
#W  ilatgrp.gi                 	XGAP library                  Max Neunhoeffer
##
#H  @(#)$Id: ilatgrp.gi,v 1.47 2004/05/22 14:03:50 gap Exp $
##
#Y  Copyright 1998,       Max Neunhoeffer,              Aachen,       Germany
##
##  This file contains the implementations for graphs and posets
##
Revision.pkg_xgap_lib_ilatgrp_gi :=
    "@(#)$Id: ilatgrp.gi,v 1.47 2004/05/22 14:03:50 gap Exp $";


#############################################################################
##
##  Some little gimmicks to fix a bug in gap4b5fix3:
##
##  FIXMEFIXMEFIXMEFIXMEFIXMEFIXMEFIXMEFIXMEFIXMEFIXMEFIXMEFIXMEFIXMEFIXME
##
#############################################################################
InstallTrueMethod(CanComputeSize,IsPermGroup);
InstallTrueMethod(CanComputeSize,CanEasilyComputePcgs);

# prevent an error message with gap4b5:
if not IsBound(EpimorphismPGroup) then
  EpimorphismPGroup := function(arg) 
    Error("not yet implemented in GAP4b5");
  end;
fi;

# prevent an error message when the small groups library is not there:
if not IsBound(HasIdGroup) then
    HasIdGroup := ReturnFalse;
fi;

#############################################################################
##
##  Logging facilities:
##
#############################################################################

GGLLogFile := false;   # not yet logging

BindGlobal( "GGLChooseLog", function(arg)
  local   di,  command;
  if GGLLogFile <> false then
    GGLLogFile := false;
  fi;
  di := Dialog("Filename","Log File?");
  GGLLogFile := Query(di,"xgap.log");
  if GGLLogFile <> false then
    AppendTo(GGLLogFile,"Log of XGAP Session of ");
    command := "date >>";
    Append(command,GGLLogFile);
    Exec(command);
    AppendTo(GGLLogFile,"\n");
  fi;
end);


BindGlobal( "GGLStopLog", function(arg)
  GGLLogFile := false;
end);


#############################################################################
##
##  Representations:  
##
#############################################################################
  
  
#############################################################################
##
#R  IsGraphicSubgroupLattice . . . . . .  repr. for graphic subgroup lattices
##
if not IsBound(IsGraphicSubgroupLattice) then
  DeclareRepresentation( "IsGraphicSubgroupLattice",
    IsComponentObjectRep and IsAttributeStoringRep and IsGraphicSheet and
    IsGraphicSheetRep and IsGraphicGraphRep and IsGraphicPosetRep,
# we inherit those components from the sheet:        
    [ "name", "width", "height", "gapMenu", "callbackName", "callbackFunc",
      "menus", "objects", "free",
# and the following from being a poset:
      "levels",           # list of levels, stores current total ordering
      "levelparams",      # list of level parameters
      "selectedvertices", # list of selected vertices
      "menutypes",        # one entry per menu which contains list of types
      "menuenabled",      # one entry per menu which contains list of flags
      "rightclickfunction",    # the current function which is called when
                               # user clicks right button
      "color",            # some color infos for the case of different models
      "levelboxes",       # little graphic boxes for the user to handle levels
      "showlevels",       # flag, if levelboxes are shown
# now follow our own components:
      "group",            # the group
      "limits",           # a record with some limits, e.g. "conjugates"
      "menuoperations",   # configuration of menu operations
      "infodisplays",     # list of records for info displays, see below
      "largestlabel",     # largest used number for label
      "lastresult",       # list of vertices which are "green"
      "largestinflevel",  # largest used number for infinity-level
      "selector",         # the current text selector or "false"
      "WholeGroupVert",   # Vertex of the whole group
      "TrivialGroupVert"],# Vertex of the trivial subgroup
    IsGraphicSheet );
fi;


#############################################################################
##
##  Configuration section for menu operations and info displays:
##
#############################################################################

#############################################################################
##
##  Some global constants for configuration purposes (see "ilatgrp.gi"):
##
#############################################################################

BindGlobal( "GGLfrom1", 1 );
BindGlobal( "GGLfrom2", 2 );
BindGlobal( "GGLfromSet", 3 );
BindGlobal( "GGLfromAny", 4 );
BindGlobal( "GGLto0", 0 );
BindGlobal( "GGLto1", 1 );
BindGlobal( "GGLtoSet", 2 );
BindGlobal( "GGLwhereUp", 1 );
BindGlobal( "GGLwhereDown", 2 );
BindGlobal( "GGLwhereAny", 0 );
BindGlobal( "GGLwhereBetween", 3 );
BindGlobal( "GGLrelsMax", 1 );
BindGlobal( "GGLrelsTotal", 2 );
BindGlobal( "GGLrelsNo", 0 );
BindGlobal( "GGLrelsDown", 3 );
BindGlobal( "GGLrelsUp", 4 );


#############################################################################
##
#F  GGLClosureGroup( <grp1>, <grp2>, ... ) . . . . . . calculates the Closure
#F  GGLClosureGroup( <grplist> ) . . . . . . . . . . . calculates the Closure
##
##  This function calculates the closure of a number of groups. It uses
##  ClosureGroup inductively. The groups can be specified as multiple 
##  or as one list of groups.
##
BindGlobal( "GGLClosureGroup",
  function(arg)
    local grp,  i;
    if Length(arg) = 1 and IsList(arg[1]) then
      arg := arg[1];
    fi;

    # the number of arguments will always be at least 1!
    grp := arg[1];
    for i in [2..Length(arg)] do
      grp := ClosureGroup(grp,arg[i]);
    od;
    return grp;
  end );
  
  
#############################################################################
##
#F  GGLStringGroup( <G> ) . . . . . . . generates string that describes group  
##
##  This function generates a string that represents a group. It is mainly
##  intended for fp groups and is actually ``stolen'' from some of the 
##  `ViewObj' methods for fp groups. It covers also the case of free groups.
##  Note that the special case of G being a string, which is handled
##  first comes in handy, if functions return a warning instead of a group.
##
BindGlobal( "GGLStringGroup",

function(G)
  local st,stream;

  st := "";
  stream := OutputTextString(st,false);
  PrintTo(stream,G);
  CloseStream(stream);
  return st;
end );

#BindGlobal( "GGLStringGroup", 
#        
#function(G)
#  
#  local st;   # used to build up the string
#  
#  # Is this already a string?
#  if IsString(G) then
#    return G;
#  fi;
#  
#  if IsFreeGroup(G) then 
#    st := "<free group";
#    if IsGroupOfFamily( G )  then
#      if Length( GeneratorsOfGroup( G ) ) > 6  then
#        Append(st," with ");
#        Append(st,String(Length( GeneratorsOfGroup( G ) ) ));
#        Append(st," generators>" );
#      else
#        Append(st," on the generators ");
#        Append(st,String(List(GeneratorsOfGroup( G ),UnderlyingElement)));
#        Append(st,">" );
#      fi;
#    else
#      st := "Group(";
#      if HasGeneratorsOfGroup( G )  then
#        if not IsBound( G!.gensWordLengthSum )  then
#          G!.gensWordLengthSum 
#            := Sum( List( GeneratorsOfGroup( G ), Length ) );
#        fi;
#        if G!.gensWordLengthSum <= 20  then
#          Append(st,String(List(GeneratorsOfGroup( G ),UnderlyingElement)));
#        else
#          Append(st,"<");
#          Append(st,String(Length( GeneratorsOfGroup( G ) )));
#          Append(st," generators>");
#        fi;
#      else
#        Append(st,", no generators known>" );
#      fi;
#      Append(st,")");
#    fi;
#  else  # no free group
#    if IsGroupOfFamily(G) then
#      st := "<fp group";
#      if HasSize(G) then
#        Append(st," of size ");
#        Append(st,String(Size(G)));
#      fi;
#      if Length(GeneratorsOfGroup(G)) > 6 then
#        Append(st," with ");
#        Append(st,String(Length(GeneratorsOfGroup(G))));
#        Append(st," generators>");
#      else
#        Append(st," on the generators ");
#        Append(st,String(List(GeneratorsOfGroup(G),UnderlyingElement)));
#        Append(st,">");
#      fi;
#    else
#      st := "Group(";
#      if HasGeneratorsOfGroup(G) then
#        if not IsBound(G!.gensWordLengthSum) then
#          G!.gensWordLengthSum:=Sum(List(GeneratorsOfGroup(G),
#                                        i->Length(UnderlyingElement(i))));
#        fi;
#        if G!.gensWordLengthSum <= 20 then                                  
#          Append(st,String(List(GeneratorsOfGroup(G),UnderlyingElement)));
#        else
#          Append(st,"<");
#          Append(st,String(Length(GeneratorsOfGroup(G))));
#          Append(st," generators>");
#        fi;
#      else
#        Append(st,"<fp, no generators known>");
#      fi;
#      Append(st,")");
#    fi;
#  fi;   # no free group
#  return st;
#end);

  
#############################################################################
##
#F  GGLStringCosetTable( <G> ). generates string that describes a coset table
##
##  This function generates a string that represents a coset table. If the
##  table is small enough it is converted to a string. Otherwise some info
##  is generated.
##
BindGlobal( "GGLStringCosetTable", 
        
function(CT)
  local st;
  if Length(CT) * Length(CT[1]) < 20 then
    return String(CT);
  else
    st := "<";
    Append(st,String(Length(CT)/2));
    Append(st," generators, ");
    Append(st,String(Length(CT[1])));
    Append(st," cosets>");
    return st;
  fi;
end );


#############################################################################
##
#F  GGLStringAbInvs( <invs> ). generates string that describes ab. invariants
##
##  This function generates a string that describes the abelian invariants.
##
BindGlobal( "GGLStringAbInvs", 
        
function(invs)
  if invs = [] then
    return "perfect";
  else
    return String(invs);
  fi;
end );


#############################################################################
##
#F  GGLStringEpimorphism( <G> )  . generates string describing an epimorphism
##
##  This function generates a string that represents an epimorphism. 
##  It just displays an arrow and the image.
##
BindGlobal( "GGLStringEpimorphism", 
        
function(epi)
  local st;

  st := "<epi ->> ";
  Append(st,GGLStringGroup(Image(epi)));
  Append(st,">");
  return st;
end );


#############################################################################
##
#F  GGLFactorGroup( <G>, <N> ) . . . . . . computes factor group, if possible
##
##  This function checks, if <N> is a normal subgroup in <G>. If not, a
##  warning message is returned as a string. Otherwise, the operation
##  FactorGroup is called and the result is returned.
##
BindGlobal( "GGLFactorGroup", 

function(G,N);
  if IsNormal(G,N) then
    return FactorGroup(G,N);
  else
    return "subgroup is not normal";
  fi;
end );


##
##  The configuration of the menu operations works as follows:
##  Every menu operation gets a record with the following entries, which
##  can take on the values described after the colon respectively:
##
##   name     : a string
##   op       : a GAP-Operation for group(s)
##   sheet    : true, false
##   parent   : true, false
##   from     : GGLfrom1, GGLfrom2, GGLfromSet, GGLfromAny
##   to       : GGLto0, GGLto1, GGLtoSet
##   where    : GGLwhereUp, GGLwhereDown, GGLwhereAny, GGLwhereBetween
##   plural   : true, false
##   rels     : GGLrelsMax, GGLrelsTotal, GGLrelsNo, GGLrelsDown, GGLrelsup
##   retsel   : true, false
##
##  Please use always these names instead of actual values because the values
##  of these variables can be subject to changes, especially because they
##  actually should be integers rather than strings.
##
##  <name> is the name appearing in the menu and info messages.
##  <op> is called to do the real work. The usage of <op> is however configured
##  by the other entries. <from> says, how many groups <op> gets as parameters.
##  It can be one group, exactly two, a list (GGLfromSet) of groups, or
##  a possibly empty list (GGLfromAny).
##  <sheet> says, if the graphic sheet is supplied as first parameter.
##  <parent> says, if the parent group is supplied as first/second parameter of
##  the call of the operation or not.
##  <to> says, how many groups <op> produces, it can be zero, one or a list
##  of groups (GGLtoSet). <where> determines what is known about the relative
##  position of the new groups with respect to the input groups of <op>.
##  GGLwhereUp means, that the new group(s) all contain all groups <op> was
##  called with. GGLwhereDown means, that the new group(s) are all contained
##  in all groups <op> was called with. GGLwhereAny means that nothing is
##  known about the result(s) with respect to this question. GGLwhereBetween
##  applies only for the case <from>=GGLfrom2 and means, that all produced
##  groups are contained in the first group and contain the second group
##  delivered to <op>. That means that in case such an operation exists
##  it will be checked before the call to the operation, which group is
##  contained in the other! It is an error if that is not the case!
##  <plural> is a flag which determines, if more than the
##  appropriate number of vertices can be selected. In this case <op> is called
##  for all subsets of the set of selected subgroups with the right number of
##  groups. This does not happen if <plural> is false. <rels> gives <op> the
##  possibility to return inclusion information about the newly calculated
##  subgroups. If <rels> is GGLrelsMax or GGLrelsTotal then <op> must return
##  a record with components `subgroups' which is a list of subgroups 
##  generated as well as a component `inclusions' which lists all maximality
##  inclusions among these subgroups.
##  A maximality inclusion is given as a list `[<i>,<j>]' indicating that
##  subgroup number <i> is a maximal subgroup of subgroup number <j>, the
##  numbers 0 and 1+length(`subgroups') are used to denote <U> and <G>
##  respectively, this applies to the case <rels>=GGLrelsMax.
##  In the case <rels>=GGLrelsTotal each pair says that the first group is
##  contained in the second. 
##  Again: The complete poset information must be returned!
##  In the case <rels>=GGLrelsNo nothing is known about the relative inclusions
##  of the results. <op> just returns a list of groups. If <rels>=GGLrelsDown
##  then the returned list is a descending chain and if <rels>=GGLrelsUp then
##  the returned list is an ascending chain.
##  If the record component "givesconjugates" is bound to true, then all
##  new vertices are put in the same class as the input vertex, so this
##  only makes sense for <from>=GGLfrom1. It is also only necessary for
##  those group types, where we don't have CanCompareSubgroups.
##  If retsel is bound and set to true, GGLMenuOps will return the groups
##  produced by the operation.


##  we have two cases up to now:
BindGlobal( "GGLMenuOpsForFiniteGroups",
        [ rec( name := "All Subgroups", 
               op := function(G) 
                 local result,cl;
                 result := [];
                 for cl in LatticeSubgroups(G)!.conjugacyClassesSubgroups do
                   Append(result,AsList(cl));
                 od;
                 return result;
               end,
               parent := false, from := GGLfrom1, to := GGLtoSet, 
               where := GGLwhereDown, plural := false, rels := GGLrelsNo ),
          rec( name := "Centralizers", op := Centralizer, 
               parent := true, from := GGLfrom1, to := GGLto1, 
               where := GGLwhereAny, plural := true, rels := GGLrelsNo ),
          rec( name := "Centres", op := Centre, 
               parent := false, from := GGLfrom1, to := GGLto1, 
               where := GGLwhereDown, plural := true, rels := GGLrelsNo ),
          rec( name := "Closure", op := GGLClosureGroup, 
               parent := false, from := GGLfromSet, to := GGLto1, 
               where := GGLwhereUp, plural := false, rels := GGLrelsNo ),
          rec( name := "Closures", op := ClosureGroup, 
               parent := false, from := GGLfrom2, to := GGLto1, 
               where := GGLwhereUp, plural := true, rels := GGLrelsNo ),
          rec( name := "Commutator Subgroups", op := CommutatorSubgroup,
               parent := false, from := GGLfrom2, to := GGLto1, 
               where := GGLwhereAny, plural := true, rels := GGLrelsNo ),
          rec( name := "Conjugate Subgroups", 
               op := function(G,H) 
                       return AsList(ConjugacyClassSubgroups(G,H)); 
                     end,
               parent := true, from := GGLfrom1, to := GGLtoSet, 
               where := GGLwhereAny, plural := true, rels := GGLrelsNo ),
          rec( name := "Cores", op := Core,
               parent := true, from := GGLfrom1, to := GGLto1, 
               where := GGLwhereDown, plural := true, rels := GGLrelsNo ),
          rec( name := "DerivedSeries", op := DerivedSeriesOfGroup,
               parent := false, from := GGLfrom1, to := GGLtoSet, 
               where := GGLwhereDown, plural := true, rels := GGLrelsDown ),
          rec( name := "DerivedSubgroups", op := DerivedSubgroup,
               parent := false, from := GGLfrom1, to := GGLto1, 
               where := GGLwhereDown, plural := true, rels := GGLrelsNo ),
          rec( name := "Fitting Subgroups", op := FittingSubgroup,
               parent := false, from := GGLfrom1, to := GGLto1, 
               where := GGLwhereDown, plural := true, rels := GGLrelsNo ),
          rec( name := "Intermediate Subgroups", op := IntermediateSubgroups,
               parent := false, from := GGLfrom2, to := GGLtoSet, 
               where := GGLwhereBetween, plural := false, rels := GGLrelsMax),
          rec( name := "Intersection", op := Intersection,
               parent := false, from := GGLfromSet, to := GGLto1, 
               where := GGLwhereDown, plural := false, rels := GGLrelsNo ),
          rec( name := "Intersections", op := Intersection,
               parent := false, from := GGLfrom2, to := GGLto1, 
               where := GGLwhereDown, plural := true, rels := GGLrelsNo ),
          rec( name := "Normalizers", op := Normalizer,
               parent := true, from := GGLfrom1, to := GGLto1, 
               where := GGLwhereUp, plural := true, rels := GGLrelsNo ),
          rec( name := "Normal Closures", op := NormalClosure,
               parent := true, from := GGLfrom1, to := GGLto1, 
               where := GGLwhereUp, plural := true, rels := GGLrelsNo ),
          rec( name := "Normal Subgroups", op := NormalSubgroups,
               parent := false, from := GGLfrom1, to := GGLtoSet, 
               where := GGLwhereDown, plural := true, rels := GGLrelsNo ),
          rec( name := "Sylow Subgroups", op := GGLSylowSubgroup,
               parent := false, from := GGLfrom1, to := GGLto1, 
               where := GGLwhereDown, plural := true, rels := GGLrelsNo ),
          rec( name := "SelectedGroups to GAP", 
               op := function(arg) 
                 # We start GAP-Logging if XGAP-Logging is on!
                 if GGLLogFile <> false then
                   LogTo(GGLLogFile);
                 fi;
               end,
               parent := false, sheet := true, retsel := true,
               from := GGLfromSet, to := GGLto0,
               where := GGLwhereAny, plural := false, rels := GGLrelsNo ),
          rec( name := "InsertVertices from GAP",
               op := function(arg) 
                 local v;
                 # We stop the GAP-Logging:
                 if GGLLogFile <> false then
                   LogTo();
                 fi;
                 v := last;
                 if not IsList(v) then
                   if IsGroup(v) then
                     return [v];
                   else
                     return [];
                   fi;
                 else
                   return Filtered(v,x->IsGroup(x));
                 fi;
               end,
               parent := false, sheet := false,
               from := GGLfromAny, to := GGLtoSet,
               where := GGLwhereAny, plural := false, rels := GGLrelsNo ),
          rec( name := "Start Logging", op := GGLChooseLog,
               parent := false, sheet := false, retsel := false,
               from := GGLfromAny, to := GGLto0,
               where := GGLwhereAny, plural := false, rels := GGLrelsNo ),
          rec( name := "Stop Logging", op := GGLStopLog,
               parent := false, sheet := false, retsel := false,
               from := GGLfromAny, to := GGLto0,
               where := GGLwhereAny, plural := false, rels := GGLrelsNo )
] );
                                             
BindGlobal( "GGLMenuOpsForFpGroups",
        [ rec( name := "Abelian Prime Quotient", op := GGLAbelianPQuotient,
               parent := false, from := GGLfrom1, to := GGLto1, 
               where := GGLwhereDown, plural := false, rels := GGLrelsNo,
               sheet := true ),
          rec( name := "All Overgroups", op := IntermediateSubgroups,
               parent := true, from := GGLfrom1, to := GGLtoSet, 
               where := GGLwhereUp, plural := false, rels := GGLrelsMax ),
          rec( name := "Closure", op := GGLClosureGroup, 
               parent := false, from := GGLfromSet, to := GGLto1, 
               where := GGLwhereUp, plural := false, rels := GGLrelsNo ),
          rec( name := "Compare Subgroups", op := GGLCompareSubgroups,
               parent := false, from := GGLfromSet, to := GGLto0,
               where := GGLwhereAny, plural := false, rels := GGLrelsNo,
               sheet := true ),
          rec( name := "Conjugacy Class", 
               op := function(G,H) 
                       local l;
                       l := AsList(ConjugacyClassSubgroups(G,H));
                       return Filtered(l,h->h <> H);
                     end,
               parent := true, from := GGLfrom1, to := GGLtoSet, 
               where := GGLwhereAny, plural := false, rels := GGLrelsNo,
               givesconjugates := true ),
          rec( name := "Cores", op := Core,
               parent := true, from := GGLfrom1, to := GGLto1, 
               where := GGLwhereDown, plural := true, rels := GGLrelsNo ),
          rec( name := "DerivedSubgroups", op := DerivedSubgroup,
               parent := false, from := GGLfrom1, to := GGLto1, 
               where := GGLwhereDown, plural := true, rels := GGLrelsNo ),
          rec( name := "Epimorphisms (GQuotients)", op := GGLEpimorphisms,
               parent := false, from := GGLfrom1, to := GGLtoSet, 
               where := GGLwhereDown, plural := false, rels := GGLrelsNo,
               sheet := true ),
          rec( name := "Intermediate Subgroups", op := IntermediateSubgroups,
               parent := false, from := GGLfrom2, to := GGLtoSet, 
               where := GGLwhereBetween, plural := false, rels := GGLrelsMax ),
          rec( name := "Intersection", op := Intersection,
               parent := false, from := GGLfromSet, to := GGLto1, 
               where := GGLwhereDown, plural := false, rels := GGLrelsNo ),
          rec( name := "Intersections", op := Intersection,
               parent := false, from := GGLfrom2, to := GGLto1, 
               where := GGLwhereDown, plural := true, rels := GGLrelsNo ),
          rec( name := "Low Index Subgroups", op := GGLLowIndexSubgroups,
               parent := false, from := GGLfrom1, to := GGLtoSet,
               where := GGLwhereDown, plural := false, rels := GGLrelsNo,
               sheet := true ),
          rec( name := "Normalizers", op := Normalizer,
               parent := true, from := GGLfrom1, to := GGLto1,
               where := GGLwhereUp, plural := true, rels := GGLrelsNo ),
          rec( name := "Prime Quotient", op := GGLPrimeQuotient,
               parent := false, from := GGLfrom1, to := GGLtoSet, 
               where := GGLwhereDown, plural := false, rels := GGLrelsDown,
               sheet := true ),
          rec( name := "Test Conjugacy", op := GGLTestConjugacy,
               parent := false, from := GGLfromSet, to := GGLto0, 
               where := GGLwhereAny, plural := false, rels := GGLrelsNo,
               sheet := true ),
          rec( name := "SelectedGroups to GAP",
               op := function(arg) 
                 # We start GAP-Logging if XGAP-Logging is on!
                 if GGLLogFile <> false then
                   LogTo(GGLLogFile);
                 fi;
               end,
               parent := false, sheet := true, retsel := true,
               from := GGLfromSet, to := GGLto0,
               where := GGLwhereAny, plural := false, rels := GGLrelsNo ),
          rec( name := "InsertVertices from GAP",
               op := function(arg) 
                 local v;
                 # We stop the GAP-Logging:
                 if GGLLogFile <> false then
                   LogTo();
                 fi;
                 v := last;
                 if not IsList(v) then
                   if IsGroup(v) then
                     return [v];
                   else
                     return [];
                   fi;
                 else
                   return Filtered(v,x->IsGroup(x));
                 fi;
               end,
               parent := false, sheet := false,
               from := GGLfromAny, to := GGLtoSet,
               where := GGLwhereAny, plural := false, rels := GGLrelsNo ),
          rec( name := "Start Logging", op := GGLChooseLog,
               parent := false, sheet := false, retsel := false,
               from := GGLfromAny, to := GGLto0,
               where := GGLwhereAny, plural := false, rels := GGLrelsNo ),
          rec( name := "Stop Logging", op := GGLStopLog,
               parent := false, sheet := false, retsel := false,
               from := GGLfromAny, to := GGLto0,
               where := GGLwhereAny, plural := false, rels := GGLrelsNo )
        ] );


##
##  The configuration of the info displays works as follows:
##  Info displays come in two flavours:
##   (1) info about an attribute
##   (2) info from a function
##  The reason for (2) is that it could be interesting to see "relative"
##  information about a subgroup with respect to the parent group. This
##  cannot be an attribute because it does not belong to the group itself.
##  Every info display gets a record with the following components:
##   name      : a string
##   tostr     : a function (can be "String") which converts the value to 
##               display into a string, if not bound "String" is taken
##  For case (1) we only have one more component:
##   attrib    : an attribute or property (the gap operation)
##  For case (2) we have:
##   func      : a function which returns the value that should be displayed
##   sheet     : true iff first parameter for <func> should be the sheet
##   parent    : true iff first/second parameter should be the parent group
##  if one of the last two is not bound it counts like "false".
##  The information produced by the functions "func" is cached in the record
##  "info" of the "data" part of the vertex under the component "name".
##
BindGlobal( "GGLInfoDisplaysForFiniteGroups",
        [ rec( name := "Size", attrib := Size ),
          rec( name := "Index", func := Index, parent := true ),
          rec( name := "IsAbelian", attrib := IsCommutative ),
          rec( name := "IsCentral", func := IsCentral, parent := true ),
          rec( name := "IsCyclic", attrib := IsCyclic ),
          rec( name := "IsNilpotent", attrib := IsNilpotentGroup ),
          rec( name := "IsNormal", func := IsNormal, parent := true ),
          rec( name := "IsPerfect", attrib := IsPerfectGroup ),
          rec( name := "IsSimple", attrib := IsSimpleGroup ),
          rec( name := "IsSolvable", attrib := IsSolvableGroup ),
        ] );
                 
# Fix the problem with missing small groups library:
if HasIdGroup <> ReturnFalse then
    Add(GGLInfoDisplaysForFiniteGroups,
        rec( name := "Isomorphism", attrib := IdGroup ));
fi; 

    
BindGlobal( "GGLInfoDisplaysForFpGroups",
        [ rec( name := "Index", func := Index, parent := true ),
          rec( name := "IsNormal", func := IsNormal, parent := true ),
          rec( name := "IsFpGroup", func := IsFpGroup, parent := false ),
# FIXME: could that be of any help: (?)
#          rec( name := "IsSubgroupFpGroup", func := IsSubgroupFpGroup, 
#               parent := false ),
          rec( name := "Abelian Invariants", attrib := AbelianInvariants,
               tostr := GGLStringAbInvs ),
          rec( name := "CosetTable", attrib := CosetTableInWholeGroup,
               tostr := GGLStringCosetTable ),
          rec( name := "IsomorphismFpGroup", func := IsomorphismFpGroup,
               parent := false, tostr := GGLStringEpimorphism ),
          rec( name := "FactorGroup", func := GGLFactorGroup, parent := true,
               tostr := GGLStringGroup )
        ] );


#############################################################################
##
##  Global data, menus etc.:  
##
#############################################################################
  

#############################################################################
##
##  Menu entries and Popups:
##
#############################################################################


LastResultOfInfoDisplay := "no info display calculated yet";


############################################################################
##
#M  GGLRightClickPopup . . . . . . . . . . called if user does a right click
##
##  This is called if the user does a right click on a vertex or somewhere
##  else on the sheet. This operation is highly configurable with respect
##  to the Attributes of groups it can display/calculate. See the 
##  configuration section in "ilatgrp.gi" for an explanation.
##
InstallMethod( GGLRightClickPopup,
    "for a graphic subgroup lattice, a vertex or `fail', and two integers",
    true,
    [ IsGraphicSheet and IsGraphicSubgroupLattice, IsObject, IsInt, IsInt ],
    0,

function(sheet,v,x,y)
  local   grp,  textselectfunc,  text,  i,  ii,  str,  funcclose,  funcall,
          maxlengthofname;
  
  # did we get a vertex?
  if v = fail then
    PopupFromMenu(sheet!.menus[3]);
    return;
  fi;
  
    # destroy other text selectors flying around
  if sheet!.selector <> false then
    Close(sheet!.selector);
    sheet!.selector := false;
  fi;
  
  # get the group of <obj>
  grp := v!.data.group;
  
  # how long are the names of the info displays?
  maxlengthofname := Maximum(List(sheet!.infodisplays,i->Length(i.name)));
  
  # text select function
  textselectfunc := function( sel, name )
    local   tid,  current,  text,  str,  value,  parameters,  
            newlevel,  savemaximals,  savemaximalin,  newv,  w;
    
    tid  := sel!.selected;
    current := sheet!.infodisplays[tid];
    text := ShallowCopy(sel!.labels);
    str  := ShallowCopy(String( current.name, -(maxlengthofname+1) ));
    if IsBound(current.attrib) then
      value := current.attrib( grp );
    else
      if not(IsBound(v!.data.info.(current.name))) then
        # we have to calculate:
        parameters := [];
        if IsBound(current.sheet) and current.sheet then 
          Add(parameters,sheet);
        fi;
        if IsBound(current.parent) and current.parent then 
          Add(parameters,sheet!.group);
        fi;
        Add(parameters,grp);
        value := CallFuncList(current.func,parameters);
        v!.data.info.(current.name) := value;
      else
        # we know "by heart"
        value := v!.data.info.(current.name);
      fi;
    fi;
    if IsBound(current.tostr) then
      Append(str,current.tostr(value));
    else
      Append(str,String(value));
    fi;
    text[tid] := str;
    Relabel( sel, text );
    LastResultOfInfoDisplay := value;
    
    # Perhaps the calculation of one attribute triggered the calculation
    # of another one! So we have to look through all infos, if new information
    # is available!
    for i in [1..Length(sheet!.infodisplays)] do
      ii := sheet!.infodisplays[i];
      if IsBound(ii.attrib) and Tester(ii.attrib)(grp) and
         Length(text[i]) >= maxlengthofname+8 and
         text[i]{[maxlengthofname+2..maxlengthofname+8]} = "unknown" then
        # in fact: new information!
        text[i] := text[i]{[1..maxlengthofname+1]};
        if IsBound(ii.tostr) then
          Append(text[i],ii.tostr(ii.attrib(grp)));
        else
          Append(text[i],String(ii.attrib(grp)));
        fi;
        Relabel(sel,text);
      fi;
    od;
    
    # We check, if we have new knowledge about IsNormal:
    if IsBound(current.func) and current.func = IsNormal and
       v!.obj!.shape = VERTEX.rectangle then
      if IsNormal(sheet!.group,v!.data.group) then
        Reshape(v!.obj,VERTEX.diamond);
      else
        Reshape(v!.obj,VERTEX.circle);
      fi;
    fi;
    
    newlevel := false;
    # We check, if we have new knowledge about Index or Size:
    if IsBound(v!.data.info.Index) and v!.data.info.Index <> infinity then
      # if we are not in a finite index level, we take measures:
      if not IsInt(v!.levelparam) or v!.levelparam < 0 then
        newlevel := true;
      fi;
    elif HasSize(v!.data.group) and Size(v!.data.group) <> infinity then
      # if we are not in a finite size level, we take measures:
      if not IsInt(v!.levelparam) then
        newlevel := true;
      fi;
    fi;
    if newlevel then
      # We delete the vertex and reinsert it with all its connections:
      savemaximals := ShallowCopy(v!.maximals);
      savemaximalin := ShallowCopy(v!.maximalin);
      Query(Dialog("OKcancel",
       "Recent results make it necessary to delete vertex and reinsert it!"));
      Delete(sheet,v);
      if IsList(v!.levelparam) then
        DeleteLevel(sheet,v!.levelparam);
      fi;
      
      newv := InsertVertex(sheet,v!.data.group);
      if newv = fail then
        return fail;
      fi;
      # we preserve our knowledge:
      newv[1]!.data.info := v!.data.info;
      v := newv[1];
      for w in savemaximals do
        NewInclusionInfo(sheet,w,v);
      od;
      for w in savemaximalin do
        NewInclusionInfo(sheet,v,w);
      od;
    fi;
      
    return LastResultOfInfoDisplay;
  end;

  # construct the string in the first place:
  text := [];
  for i in sheet!.infodisplays  do
    str := String( i.name, -(maxlengthofname+1) );
    # do we know the value?
    if IsBound(i.attrib) then
      if Tester(i.attrib)(grp) then
        if IsBound(i.tostr) then
          Append(str,i.tostr(i.attrib(grp)));
        else
          Append(str,String(i.attrib(grp)));
        fi;
      else
        Append(str,"unknown");
      fi;
    else   #  its determined by a function and perhaps cached:
      if IsBound(v!.data.info.(i.name)) then
        if IsBound(i.tostr) then
          Append( str, i.tostr(v!.data.info.(i.name)));
        else
          Append( str, String(v!.data.info.(i.name)));
        fi;
      else
        Append( str, "unknown" );
      fi;
    fi;
    Add( text, str );
    Add( text, textselectfunc );
  od;

  # button select functions:
  funcclose := function( sel, bt )
    Close(sel);
    sheet!.selector := false;
    return true;  
  end;
  funcall := function( sel, bt )
    local i;
    for i  in [ 1 .. Length(sel!.labels) ]  do
      sel!.selected := i;
      sel!.textFuncs[i]( sel, sel!.labels[i] );
    od;
    Enable( sel, "all", false );
    return true;  
  end;
  
  # construct text selector
  sheet!.selector := TextSelector(
        Concatenation( " Information about ", v!.label ),
        text,
        [ "all", funcall, "close", funcclose ] );

end);


#############################################################################
##
##  Methods for menu actions:
##
#############################################################################


##
## we need some dialogs:
##
BindGlobal( "GGLPrimeDialog", Dialog( "OKcancel", "Prime" ) );
BindGlobal( "GGLClassDialog", Dialog( "OKcancel", "Class" ) );
BindGlobal( "GGLGoOnDialog", Dialog( "OKcancel", "Go on?" ) );
BindGlobal( "GGLDegreeDialog", Dialog( "OKcancel", "Degree" ) );
BindGlobal( "GGLDimensionDialog", Dialog( "OKcancel", "Dimension" ) );
BindGlobal( "GGLFieldSizeDialog", Dialog( "OKcancel", "Field Size" ) );
BindGlobal( "GGLMaxIndexDialog", Dialog( "OKcancel", "Maximal Index" ) );


#############################################################################
##
#M  GGLMenuOperation . . . . . . . . . . . . . . . .  is called from the menu
##
##  This operation is called for all so called "menu operations" the user
##  wants to perform on lattices. It is highly configurable with respect
##  to the input and output and the GAP-Operation which is actually performed
##  on the selected subgroups. See the configuration section in "ilatgrp.gi"
##  for an explanation.
##
InstallMethod( GGLMenuOperation,
    "for a graphic subgroup lattice, a menu, and a string",
    true,
    [ IsGraphicSheet and IsGraphicSubgroupLattice, IsMenu, IsString ],
    0,

function(sheet, menu, entry)
  local   menuop,  parameters,  selected,  v,  todolist,  i,  j,  
          todo,  currentparameters,  result,  infostr,  vertices,  
          newflag,  len,  hints,  grp,  res,  T,  inc,  T2,  l,  cl;
  
  # first we determine the menu entry which was selected:
  menuop := Position(menu!.entries,entry);
  # fail is not an option here!
  menuop := sheet!.menuoperations[menuop];
  
  # note that we are guaranteed to have enough vertices selected!
  
  # let's prepare the parameters:
  parameters := [];
  if IsBound(menuop.sheet) and menuop.sheet then 
    Add(parameters,sheet); 
  fi;
  if IsBound(menuop.parent) and menuop.parent then 
    Add(parameters,sheet!.group); 
  fi;
  
  # the selected vertices:
  selected := Selected(sheet);
  
  # we clear old "results":
  for v in sheet!.lastresult do
    if IsAlive(v) then
      if PositionSet(selected,v) = fail then
        Recolor(sheet,v,sheet!.color.unselected);
      else
        Recolor(sheet,v,sheet!.color.selected);
      fi;
    fi;
  od;
  sheet!.lastresult := [];
    
  if menuop.from = GGLfrom1 then
    # we do *not* have to look for menuop.plural because if it is false
    # then there can only be one vertex selected!
    todolist := List(selected,v->[v]);
    
  elif menuop.from = GGLfrom2 then
    # we do *not* have to look for menuop.plural because if it is false
    # then there can only be selected exactly two vertices.
    todolist := [];
    for i in [1..Length(selected)-1] do
      for j in [i+1..Length(selected)] do
        Add(todolist,[selected[i],selected[j]]);
      od;
    od;
    
  else   # menuop.from = GGLfromSet or menuop.from = GGLfromAny then
    # we do *not* have to look for menuop.plural because it is forbidden
    # for this case!
    todolist := [selected];
  fi;
  
  for todo in [1..Length(todolist)] do
    currentparameters := ShallowCopy(parameters);
    
    # there is one special case where we have to compare the two groups
    # in question:
    if menuop.from = GGLfrom2 and menuop.where = GGLwhereBetween then
      if not IsSubgroup( todolist[todo][1]!.data.group, 
                         todolist[todo][2]!.data.group ) then
        todolist[todo]{[1,2]} := todolist[todo]{[2,1]};
      fi;
    fi;
    
    if menuop.from = GGLfromSet or menuop.from = GGLfromAny then
      Add(currentparameters,List(todolist[todo],v->v!.data.group));
    else
      Append(currentparameters,List(todolist[todo],v->v!.data.group));
    fi;
    if menuop.to = GGLto0 then
      CallFuncList(menuop.op,currentparameters);
      result := false;
    else
      result := CallFuncList(menuop.op,currentparameters);
    fi;
    
    # we give some information:
    if Length(todolist[todo]) >= 1 then
      infostr := Concatenation(menuop.name," (",todolist[todo][1]!.label);
    else
      infostr := Concatenation(menuop.name," (");
    fi;
    
    for i in [2..Length(todolist[todo])] do
      Append(infostr,",");
      Append(infostr,todolist[todo][i]!.label);
    od;
    Append(infostr,")");
    
    # now we have either nothing or a group or a list of groups or a record 
    # with components "subgroups" and "inclusions".
    if result = fail then
      Append(infostr," --> fail");
      Info(GraphicLattice,1,infostr);
      if GGLLogFile <> false then
        AppendTo(GGLLogFile,infostr,"\n");
      fi;
      infostr := "";
      if Query( GGLGoOnDialog ) = false then
        Info(GraphicLattice,1,"...Aborted.");
        if GGLLogFile <> false then
          AppendTo(GGLLogFile,"...Aborted.\n");
        fi;
        return;
      fi;
    fi;
    if menuop.to = GGLto0 or result = fail then
      if result <> fail then
        Info(GraphicLattice,1,infostr);
        if GGLLogFile <> false then
          AppendTo(GGLLogFile,infostr,"\n");
        fi;
        infostr := "";
      fi;
    else
      
      Append(infostr," --> (");
      
      if menuop.to = GGLto1 then
        result := [result];
      fi;
      
      if IsList(result) then
        result := rec(subgroups := result, inclusions := []);
      fi;
      
      # first we only insert the "new" vertices:
      vertices := [];
      newflag := [];
      len := Length(result.subgroups);
      hints := List(todolist[todo],v->v!.x);
      for grp in [1..len] do
        # we want no lines to vanish:
        if IsBound(menuop.givesconjugates) and
           menuop.givesconjugates then
          res := InsertVertex( sheet, result.subgroups[grp], 
                               todolist[todo][1],hints );
        else
          res := InsertVertex( sheet, result.subgroups[grp], false, hints );
        fi;
        
        if grp <> 1 then
          Append(infostr,",");
        fi;
        if res = fail then
          vertices[grp] := fail;
          newflag[grp] := fail;
          Append(infostr,"fail");
        else
          vertices[grp] := res[1];
          newflag[grp] := res[2];
        
          # we mark the vertex:
          # Select(sheet,res[1],true);
          # as of 1.4.1999 we do no longer select results
          if sheet!.color.result <> false  then
            Recolor( sheet, res[1], sheet!.color.result );
          fi;
          Add( sheet!.lastresult, res[1] );  

          Append(infostr,vertices[grp]!.label);
        fi;
      od;
      Append(infostr,")");
      Info(GraphicLattice,1,infostr);
      if GGLLogFile <> false then
        AppendTo(GGLLogFile,infostr,"\n");
      fi;
      infostr := "";
      
      # if the sheet has the HasseProperty, we are done, because the 
      # connections are calculated. Otherwise we have to see what we can do.
      if not HasseProperty(sheet) then
        # do we have additional information?
        if menuop.rels = GGLrelsTotal then
          # we calculate the info which vertex is maximal in which:
          T := List([1..len],x->List([1..len],y->0));
          for inc in result.inclusions do
            T[inc[1]][inc[2]] := 1;
          od;
          T2 := T * T;
          # if there is a value <> 0 at the position (i,j) then there is a
          # possibility to walk in two steps from vertex i to vertex j
          for i in [1..len] do
            for j in [1..len] do
              if T[i][j] <> 0 and T2[i][j] = 0 then
                if vertices[i] <> fail and vertices[j] <> fail then
                  NewInclusionInfo( sheet, vertices[i], vertices[j] );
                  if not(IsAlive(vertices[i]!.obj)) then
                    vertices[i] := fail;
                  fi;
                  if not(IsAlive(vertices[j]!.obj)) then
                    vertices[j] := fail;
                  fi;
                fi;
              fi;
            od;
          od;
        elif menuop.rels = GGLrelsMax then
          for inc in result.inclusions do
            if inc[1] >= 1 and inc[1] <= len and 
               inc[2] >= 1 and inc[2] <= len then
              # this is no inclusion with lower or higher groups!
              if vertices[inc[1]] <> fail and vertices[inc[2]] <> fail then
                NewInclusionInfo( sheet, vertices[inc[1]], vertices[inc[2]] );
                if not(IsAlive(vertices[inc[1]]!.obj)) then
                  vertices[inc[1]] := fail;
                fi;
                if not(IsAlive(vertices[inc[2]]!.obj)) then
                  vertices[inc[2]] := fail;
                fi;
              fi;
            fi;
          od;
        elif menuop.rels = GGLrelsDown then
          for i in [1..len-1] do
            if vertices[i+1] <> fail and vertices[i] <> fail then
              NewInclusionInfo( sheet, vertices[i+1], vertices[i] );
              if not(IsAlive(vertices[i]!.obj)) then
                vertices[i] := fail;
              fi;
              if not(IsAlive(vertices[i+1]!.obj)) then
                vertices[i+1] := fail;
              fi;
            fi;
          od;
        elif menuop.rels = GGLrelsUp then
          for i in [1..len-1] do
            if vertices[i] <> fail and vertices[i+1] <> fail then
              NewInclusionInfo( sheet, vertices[i], vertices[i+1] );
              if not(IsAlive(vertices[i]!.obj)) then
                vertices[i] := fail;
              fi;
              if not(IsAlive(vertices[i+1]!.obj)) then
                vertices[i+1] := fail;
              fi;
            fi;
          od;
        fi;
        # we cannot say anything if menuop.rels = GGLrelsNo
        
        # perhaps we have information about the selected groups:
        if menuop.where = GGLwhereUp then
          for i in [1..len] do
            for j in [1..Length(todolist[todo])] do
              if vertices[i] <> fail then
                NewInclusionInfo( sheet, todolist[todo][j], vertices[i] );
                if not(IsAlive(vertices[i]!.obj)) then
                  vertices[i] := fail;
                fi;
              fi;
            od;
          od;
        elif menuop.where = GGLwhereDown then
          for i in [1..len] do
            for j in [1..Length(todolist[todo])] do
              if vertices[i] <> fail then
                NewInclusionInfo( sheet, vertices[i], todolist[todo][j] );
                if not(IsAlive(vertices[i]!.obj)) then
                  vertices[i] := fail;
                fi;
              fi;
            od;
          od;
        elif menuop.where = GGLwhereBetween then
          for i in [1..len] do
            if vertices[i] <> fail then
              NewInclusionInfo( sheet, vertices[i], todolist[todo][1] );
              NewInclusionInfo( sheet, todolist[todo][2], vertices[i] );
              if not(IsAlive(vertices[i]!.obj)) then
                vertices[i] := fail;
              fi;
            fi;
          od;
        fi;
        
        # we cannot say anything if menuop.where = GGLwhereAny
        # except: all subgroups are in the whole group and
        #         all subgroups contain the trivial subgroup
        # first we catch the case that one of the new vertices is the
        # trivial subgroup, it always knows its Size 1!
        for i in [1..len] do
          if vertices[i] <> fail and
             HasSize(vertices[i]!.data.group) and
             Size(vertices[i]!.data.group) = 1 then
            sheet!.TrivialGroupVert := vertices[i];
            # We have the trivial subgroup, it is contained in all other
            # subgroups:
            for l in sheet!.levels do
              for cl in l!.classes do
                for v in cl do
                  NewInclusionInfo(sheet, sheet!.TrivialGroupVert, v);
                od;
              od;
            od;
          fi;
        od;
        for i in [1..len] do
          if vertices[i] <> fail then
            if not(IsAlive(vertices[i]!.obj)) then
              vertices[i] := fail;
            else
              if IsAlive(sheet!.WholeGroupVert!.obj) then
                NewInclusionInfo( sheet, vertices[i], sheet!.WholeGroupVert );
              fi;
              if sheet!.TrivialGroupVert <> false and
                 IsAlive(sheet!.TrivialGroupVert!.obj) then
                NewInclusionInfo( sheet, sheet!.TrivialGroupVert, vertices[i]);
              fi;
            fi;
          fi;
        od;
        
      fi;     # not HasseProperty
    fi;  # operation produced something
  od;  # all done
  if IsBound(menuop.retsel) and menuop.retsel = true then
    last := SelectedGroups(sheet);
  fi;
end);


# We remember the last prime the user wanted:
GGLSylowLastPrime := fail;


#############################################################################
##
#M  GGLSylowSubgroup(<grp>)  . . . . . .  asks for prime, calls SylowSubgroup
##
##  This operation just asks for a prime by a little dialog and calls then
##  SylowSubgroup. Returns its result.
##
InstallMethod( GGLSylowSubgroup,
    "for a group",
    true,
    [ IsGroup ],
    0,

function(grp)
  local   res,  p, st;
  
  repeat
    st := "Prime ?";
    if IsInt(GGLSylowLastPrime) then
      st := Concatenation(st," (Default: ",String(GGLSylowLastPrime));
      st := Concatenation(st,")");
    fi;
    
    res := Query( Dialog("OKcancel",st) );
    if res = false then
      return fail;
    fi;
    if IsInt(GGLSylowLastPrime) and res = "" then
      p := GGLSylowLastPrime;
    else
      p := Int(res);
    fi;
    if not IsInt(p) or not IsPrime(p) then
      res := Query(Dialog("OKcancel","You must enter a prime!"));
      if res = false then
        return fail;
      fi;
      res := false;
    else
      res := true;
    fi;
  until res;
  if p <> GGLSylowLastPrime then
    Info(GraphicLattice,1,"Sylow prime: ",p);
    if GGLLogFile <> false then
      AppendTo(GGLLogFile,"Sylow prime: ",p,"\n");
    fi;
  fi;
  GGLSylowLastPrime := p;
  return SylowSubgroup( grp, p );
end);


#############################################################################
##
#M  GGLAbelianPQuotient(<sheet>,<grp>) . . . . . asks for p and calls library
##
##  This operation asks for a prime p and runs then the library operations
##  to calculate abelian prime quotients.
##
InstallMethod( GGLAbelianPQuotient,
    "for a graphic subgroup lattice sheet, and an fp group",
    true,
    [ IsGraphicSubgroupLattice, IsGroup ],
    0,

function(sheet,grp)
  local res, p, epi;
  res := Query( GGLPrimeDialog );
  if res = false then
    return fail;
  fi;
  p := Int(res);
  if not IsInt(p) or not IsPrime(p) then
    Query(Dialog("OKcancel","You must enter a prime!"));
    return fail;
  fi;
  Info(GraphicLattice,1,"AbelianPQuotient prime: ",p);
  if GGLLogFile <> false then
    AppendTo(GGLLogFile,"AbelianPQuotient prime: ",p,"\n");
  fi;
  epi := EpimorphismPGroup( grp, p, 1 );
  # this should be cheap and store the Size in the Image
  # therefore the following Kernel will know its Index in the whole group!
  Size(Image(epi));
  return Kernel(epi);
end);


#############################################################################
##
#M  GGLPrimeQuotient(<sheet>,<grp>) .  asks for p and class and calls library
##
##  This operation asks for a prime p and a class cl and runs then the
##  library operations to calculate prime quotients up to class cl.
##
InstallMethod( GGLPrimeQuotient,
    "for a graphic subgroup lattice sheet, and an fp group",
    true,
    [ IsGraphicSubgroupLattice, IsGroup ],
    0,

function(sheet,grp)
  local res, p, cl, i, l, epi;
  res := Query( GGLPrimeDialog );
  if res = false then
    return fail;
  fi;
  p := Int(res);
  if not IsInt(p) or not IsPrime(p) then
    Query(Dialog("OKcancel","You must enter a prime!"));
    return fail;
  fi;
  Info(GraphicLattice,1,"PQuotient prime: ",p);
  if GGLLogFile <> false then
    AppendTo(GGLLogFile,"PQuotient prime: ",p,"\n");
  fi;
  res := Query( GGLClassDialog );
  if res = false then
    return fail;
  fi;
  cl := Int(res);
  if not IsInt(cl) or not cl >= 1 then
    Query(Dialog("OKcancel","You must enter an integer >= 1!"));
    return fail;
  fi;
  Info(GraphicLattice,1,"PQuotient class: ",cl);
  if GGLLogFile <> false then
    AppendTo(GGLLogFile,"PQuotient class: ",cl,"\n");
  fi;
  l := [];
  for i in [1..cl] do
    epi := EpimorphismPGroup( grp, p, i );
    # this should be cheap and store the Size in the Image
    # therefore the following Kernel will know its Index in the whole group!
    Size(Image(epi));
    Add(l, Kernel(epi) );
  od;
  return l;
end);


#############################################################################
##
#M  GGLKernelQuotientSystem  . . . . . . . calculates the kernel of epi to qs
##
##  obsolete!?!
#FIXME:
##
#InstallMethod( GGLKernelQuotientSystem,
#    "for a quotient system",
#    true,
#    [ IsQuotientSystem ],
#    -5,
#
#function(qs)
#  return Kernel( GGLEpiQuotientSystem(qs) );
#end );


# We store the text selector in this variable to destroy it, if the next one
# pops up.
GGLEpiTextsel := false;

# the vertex we currently work on:
GGLEpiVertex := false;

# The user can supply groups for epimorghisms in the following variable:
IMAGE_GROUP := 0;


#############################################################################
##
#M  GGLEpimorphisms(<sheet>,<grp>) . . . pops up box to choose on which group
##
##  This operations brings up a text selector where one can choose several
##  types of groups to calculate epimorphisms onto.
##
InstallMethod( GGLEpimorphisms,
    "for a graphic subgroup lattice sheet, and (fp) group",
    true,
    [ IsGraphicSubgroupLattice, IsGroup ],
    0,

function(sheet,grp)
  local   GGLEpiResults,  GGLEpi,  GGLEpiShowResult,  GGLEpiShowStab,  
          info,  width,  text,  i,  closefunc,  name, kerneldone, stabdone;
  
  GGLEpiResults := [];   # no results yet
  kerneldone := false;   # we did not yet include the kernels
  stabdone := false;     # we did not yet include point stabilizers
  
  # Here comes the function that allows the user to search for epimorphisms:

  GGLEpi := function(sel,st)
    local   txt,  tid,  len,  res,  deg,  epigrp,  dim,  fis,  vec,  i,  
            path,  str;
    txt := sel!.labels;
    tid := sel!.selected;
    len := Length(txt[tid]);    # we want to preserve this!
    if st{[1..3]} = "Sym" then   # Epis onto a symmetric group:
      res := Query(GGLDegreeDialog); if res = false then return fail; fi;
      deg := Int(res); if not IsInt(deg) or deg < 2 then return fail; fi;
      epigrp := SymmetricGroup(deg);
      txt[tid] := String(Concatenation("Sym(",String(deg),")"),-len);
    elif st{[1..3]} = "Alt" then # Epis onto an alternating group:
      res := Query(GGLDegreeDialog); if res = false then return fail; fi;
      deg := Int(res); if not IsInt(deg) or deg < 2 then return fail; fi;
      epigrp := AlternatingGroup(deg);
      txt[tid] := String(Concatenation("Alt(",String(deg),")"),-len);
    elif st{[1..3]} = "PSL" then
      # Epis onto a PSL:
      res := Query(GGLDimensionDialog); if res = false then return fail; fi;
      dim := Int(res); if not IsInt(dim) or dim < 2 then return fail; fi;
      res := Query(GGLFieldSizeDialog); if res = false then return fail; fi;
      fis := Int(res); if not IsInt(fis) or not IsPrimePowerInt(fis) then 
        return fail; 
      fi;
      epigrp := SL(dim,fis);
      # FIXME: Do we have to go through this???
      vec := [1]; for i in [2..dim] do Add(vec,0); od;
      vec := vec * Z(fis)^0;
      epigrp := Action(epigrp,Orbit(epigrp,vec,OnLines),OnLines);
      txt[tid] := String(Concatenation("PSL(",String(dim),",",
                                       String(fis),")"),-len);
    elif st{[1..3]} = "Lib" then
      # Epis onto a group of our library:
      path := ShallowCopy(GAP_ROOT_PATHS[1]);
      Append(path,"pkg/xgap/pmg/");
      res := Query(Dialog("Filename","Which group?"),path);
      if res = false then
        return fail;
      fi;
      IMAGE_GROUP := 0;
      if not READ(res) then
        Info(GraphicLattice,1,Concatenation( "cannot read file ", res ));
        return fail;
      elif IsInt(IMAGE_GROUP) then
        Info(GraphicLattice,1,Concatenation( res, 
                " does not define IMAGE_GROUP" ));
        return fail;
      fi;
      epigrp := IMAGE_GROUP;
      if HasName(epigrp) then
        txt[tid] := String(Concatenation("Library: ",Name(epigrp),")"),-len);
      else
        txt[tid] := String("Library: Group with no name",-len);
      fi;
    elif st{[1..3]} = "Use" or st{[1..3]} = "Def" then
      if not IsBound(IMAGE_GROUP) or IsInt(IMAGE_GROUP)  then
        txt[tid] := "Define IMAGE_GROUP & click here! ";
        Relabel( sel, txt );
        return fail;
      fi;
      epigrp := IMAGE_GROUP;
      if HasName(epigrp) then
        txt[tid] := String(Concatenation("User Defined: ",Name(epigrp),")"),
                           -len);
      else
        txt[tid] := String("User Defined: Group with no name",-len);
      fi;
      IMAGE_GROUP := 0;
    fi;
    
    # now the function has either returned (with "fail" as return value) or
    # epigrp is correctly initialized with a group
    txt[tid]{[len-14..len]} := " computing ... ";
    Relabel(sel,txt);
    GGLEpiResults := GQuotients(GGLEpiVertex!.data.group,epigrp);
    str := Concatenation("       ",String(Length(GGLEpiResults))," found");
    txt[tid]{[len-Length(str)+1..len]} := str;
    Relabel(sel,txt);
    Enable(sel,"display",true);
    if IsPermGroup(epigrp) then
      Enable(sel,"display point stabilizers",true);
    fi;
    return true;
  end;
  
  # The following function is called when the user selects "display". The
  # calculated results are put into the lattice.
  
  GGLEpiShowResult := function(sel,entry)
    local   groups,  g,  v,  txt,  tid,  len,  e;
    for e in GGLEpiResults do
      # this should be cheap and store the Size in the Image
      # therefore the following Kernel will know its Index in the whole group!
      Size(Image(e));
    od;
    groups := List(GGLEpiResults,Kernel);
    kerneldone := [];
    for g in [1..Length(groups)] do
      v := InsertVertex(sheet,groups[g],false,[GGLEpiVertex!.x]);
      if v <> fail then
        # as of 1.4.1999 we do no longer select results:
        # Select(sheet,v[1]);
        kerneldone[g] := v[1];
        if sheet!.color.result <> false  then
          Recolor( sheet, v[1], sheet!.color.result );
        fi;
        Add( sheet!.lastresult, v[1] );
        if v[2] then
          NewInclusionInfo(sheet,v[1],GGLEpiVertex);
          if stabdone <> false and IsBound(stabdone[g]) and
             IsAlive(stabdone[g]!.obj) then
            NewInclusionInfo(sheet,v[1],stabdone[g]);
          fi;
        fi;
      fi;
    od;
    Enable(sel,"display",false);
    txt := sel!.labels;
    tid := sel!.selected;
    len := Length(txt[tid]);
    txt[tid]{[len-13..len]} := "              ";
    Relabel(sel,txt);
    return true;
  end;
  
  GGLEpiShowStab := function(sel,entry)
    local   groups,  g,  v,  txt,  tid,  len;
    groups := List(GGLEpiResults,e -> PreImage(e,Stabilizer(Image(e),1)));
    stabdone := [];
    for g in [1..Length(groups)] do
      v := InsertVertex(sheet,groups[g],false,[GGLEpiVertex!.x]);
      if v <> fail then
        # as of 1.4.1999 we do no longer select results:
        # Select(sheet,v[1]);
        stabdone[g] := v[1];
        if sheet!.color.result <> false  then
          Recolor( sheet, v[1], sheet!.color.result );
        fi;
        Add( sheet!.lastresult, v[1] );
        if v[2] then
          NewInclusionInfo(sheet,v[1],GGLEpiVertex);
          if kerneldone <> false and IsBound(kerneldone[g]) and
             IsAlive(kerneldone[g]!.obj) then
            NewInclusionInfo(sheet,kerneldone[g],v[1]);
          fi;
        fi;
      fi;
    od;
    Enable(sel,"display point stabilizers",false);
    txt := sel!.labels;
    tid := sel!.selected;
    len := Length(txt[tid]);
    txt[tid]{[len-13..len]} := "              ";
    Relabel(sel,txt);
    return true;
  end;
  
  # here starts the code of the operation GGLEpimorphisms:
  
  # get rid of old text selectors:
  if GGLEpiTextsel <> false then
    Close(GGLEpiTextsel);
    GGLEpiTextsel := false;
  fi;
  
  # Store the vertex in question:
  GGLEpiVertex := Selected(sheet)[1];
  
  # construct text describing the groups
  info := [
           "Sym(n)",	           GGLEpi,
           "Alt(n)",               GGLEpi,
           "PSL(d,q)",             GGLEpi,
           "Library",              GGLEpi,
           "User Defined",         GGLEpi,
           ];
  width := Maximum(List(info{[1,3..Length(info)-1]},Length))+20;
  text  := [];
  for i  in [ 1, 3 .. Length(info)-1 ]  do
    info[i] := String( info[i], -width );
    Add( text, info[i] );
  od;
  
  # close function
  closefunc := function( sel, bt )
    Close(sel);
    GGLEpiTextsel := false;
    return false;
  end;
  
  # construct a text selector
  if HasName(sheet!.group) then
    name := Name(sheet!.group);
  else
    name := "Group";
  fi;
  
  GGLEpiTextsel :=
    TextSelector(Concatenation(
            "          Epimorphisms from ", name, "           " ),
            info, [ "display", GGLEpiShowResult, "close", closefunc,
                    "display point stabilizers", GGLEpiShowStab ]
            );
  Enable( GGLEpiTextsel, "display", false );
  Enable( GGLEpiTextsel, "display point stabilizers", false );
  return [];
end );


#############################################################################
##
#M  GGLLowIndexSubgroups(<sheet>,<grp>) . .  pops up box to choose max. index
##
##  This operations brings up a dialog, in which one can choose the maximal
##  index for the subgroups that are searched.
##
InstallMethod( GGLLowIndexSubgroups,
    "for a graphic subgroup lattice sheet, and a (fp) group",
    true,
    [ IsGraphicSubgroupLattice, IsGroup ],
    0,

function(sheet,grp)
  local   res,  p;
  res := Query( GGLMaxIndexDialog );
  if res = false then
    return fail;
  fi;
  p := Int(res);
  if not IsInt(p) or p <= 0 then
    return fail;
  fi;
  Info(GraphicLattice,1,"Limit for LowIndex: ",p);
  if GGLLogFile <> false then
    AppendTo(GGLLogFile,"Limit for LowIndex: ",p,"\n");
  fi;
  
  return LowIndexSubgroupsFpGroup(grp,TrivialSubgroup(grp),p);
end);


#############################################################################
##
#M  GGLCompareSubgroups(<sheet>,<grplist>) . . . . .  compares some subgroups
##
##  This operation lets the GAP library compare the selected subgroups.
##  The new information about equality or inclusion of one in the other resp.
##  is included into the graphic lattice. This can lead to the merging of
##  vertices. No new vertices are included into the lattice.
##
InstallMethod( GGLCompareSubgroups,
    "for a graphic subgroup lattice sheet, and a list of fp groups",
    true,
    [ IsGraphicSubgroupLattice, IsList ],
    0,
        
function( sheet, grplist )
  local   vertlist,  poslist,  i,  j,  vert,  pos;
  # we ignore grp1 and grp2 and look at the selected vertices:
  vertlist := Selected(sheet);  # at least one vertex is selected!
  poslist := List(vertlist,v->Position(sheet!.levelparams,v!.levelparam));
  for i in [1..Length(vertlist)] do
    for j in [i+1..Length(vertlist)] do
      if IsAlive(vertlist[i]) and IsAlive(vertlist[j]) then
        # Now the routine for two vertices:
        if poslist[i] < poslist[j] then
          vert := vertlist{[j,i]};
          pos := poslist{[j,i]};
        else
          vert := vertlist{[i,j]};
          pos := poslist{[i,j]};
        fi;

        # first make sure that there is no "way" from v[2] down to v[1] on the 
        # connections which are already in the poset. We use the function
        # GPSearchWay in poset.gi. Documentation there says:
        #   The following function is only internal:
        #   Use it on your own risk and only if you know what you are doing!
        # So I (Max) say:
        #  *I know what I am doing!*
        if not GPSearchWay(sheet, vert[2], vert[1], pos[1]) then 
        # note the order of the vertices in the calling convention!
        # see: I really know what I am doing!
          if IsSubgroup(vert[2]!.data.group,vert[1]!.data.group) then
            Info(GraphicLattice,1,vert[2]!.label," contains ",vert[1]!.label);
            if GGLLogFile <> false then
              AppendTo(GGLLogFile,vert[2]!.label," contains ",
                      vert[1]!.label,"\n");
            fi;
            NewInclusionInfo(sheet,vert[1],vert[2]);
          elif IsSubgroup(vert[1]!.data.group,vert[2]!.data.group) then
            Info(GraphicLattice,1,vert[1]!.label," contains ",vert[2]!.label);
            if GGLLogFile <> false then
              AppendTo(GGLLogFile,vert[1]!.label," contains ",
                       vert[2]!.label,"\n");
            fi;
            NewInclusionInfo(sheet,vert[2],vert[1]);
          fi;
        else
          if vert[1]!.data.group = vert[2]!.data.group then
            # groups are the same!
            MergeVertices(sheet,vert[1],vert[2]);
          fi;
        fi;
      fi;
    od;
  od;
  return;
end );

      
#############################################################################
##
#F  GGLTestConjugacy(<sheet>,<grplist>) . . . . . test conjugacy of subgroups
##
##  This operation lets the GAP library test the selected conjugacy classes
##  of subgroups. If new information about conjugacy is found, classes are
##  merged.
##
InstallMethod( GGLTestConjugacy,
    "for a graphic subgroup lattice sheet, and a list of fp groups",
    true,
    [ IsGraphicSubgroupLattice, IsList ],
    0,
        
function( sheet, grplist )
  local   vert,  levelparams,  classlists,  v,  lpos,  cpos,  i,  j,  pos,  
          lev,  pos1,  cl1,  pos2,  cl2;
  # We ignore the list and take the selected vertices or their classes.
  vert := Selected(sheet);
  levelparams := [];
  classlists := [];
  for v in vert do
    # Do we have this level?
    lpos := Position(levelparams,v!.levelparam);
    if lpos = fail then
      # no, so we store the new level
      Add(levelparams,v!.levelparam);
      Add(classlists,[]);
      lpos := Length(levelparams);
    fi;
    # Do we have the class?
    cpos := Position(classlists[lpos],v!.classparam);
    if cpos = fail then
      Add(classlists[lpos],v!.classparam);
      cpos := Length(classlists[lpos]);
    fi;
  od;
  
  # now we have a list of levels and for each levels a list of classes
  # compare them pairwise:
  for lpos in [1..Length(levelparams)] do
    for i in [1..Length(classlists[lpos])] do
      for j in [i+1..Length(classlists[lpos])] do
        # Compare first subgroups of the two classes:
        pos := Position(sheet!.levelparams,levelparams[lpos]);
        lev := sheet!.levels[pos];
        pos1 := Position(lev!.classparams,classlists[lpos][i]);
        if pos1 <> fail then   # could already be merged!
          cl1 := lev!.classes[pos1];
          pos2 := Position(lev!.classparams,classlists[lpos][j]);
          if pos2 <> fail then  # could already be merged!
            cl2 := lev!.classes[pos2];
            if Length(cl1) > 0 and Length(cl2) > 0 and
               IsConjugate(sheet!.group,
                           cl1[1]!.data.group,cl2[1]!.data.group) then
              # we have to merge the classes:
              Info(GraphicLattice,1,"Classes ",classlists[lpos][i]," and ",
                   classlists[lpos][j]," in level ",levelparams[lpos],
                   " are merged!");
              if GGLLogFile <> false then
                AppendTo(GGLLogFile,"Classes ",classlists[lpos][i]," and ",
                         classlists[lpos][j]," in level ",levelparams[lpos],
                         " are merged!\n");
              fi;
              Append(cl1,cl2);
              for v in [1..Length(cl2)] do
                cl2[v]!.classparam := cl1[1]!.classparam;
                Unbind(cl2[v]);   # Modify the class!
              od;
              Delete(sheet,levelparams[lpos],classlists[lpos][j]); # class!
            fi;
          fi;
        fi;
      od;
    od;
  od;
  # Now we call `UserRearrangeClasses' to align the vertices neatly!
  UserRearrangeClasses(sheet,sheet!.menus[2],"Rearrange Classes");
  
end );


#############################################################################
##
##  Methods for inserting new vertices:
##
#############################################################################


#############################################################################
##
#V  GGLLimitForIsNormalCalc . . . . . index limit for automatic IsNormal test
##
##  Only for subgroups with index smaller than this number an automatic
##  IsNormal test is performed, when the vertex is added to the sheet.
##
GGLLimitForIsNormalCalc := 1000;


##
## Here comes a (somewhat dirty) hack because we want to use functions
## from the CRYST share package once they are available:
##
if not IsBound(HasIsSpaceGroup) then
  HasIsSpaceGroup := function(arg) return false; end;
  definedHasIsSpaceGroup := true;
else
  definedHasIsSpaceGroup := false;
fi;
if not IsBound(IsSpaceGroup) then
  IsSpaceGroup := function(arg) return false; end;
  definedIsSpaceGroup := true;
else
  definedIsSpaceGroup := false;
fi;
if not IsBound(TranslationBasis) then
  TranslationBasis := function(arg) return []; end;
  definedTranslationBasis := true;
else
  definedTranslationBasis := false;
fi;


#############################################################################
##
#F  GGLEnsureLevelIsLower( <sheet>, <v1>, <v2> ) . . . . . . . . . . . . . .
##    . . . . . . . . . . . . . . . . . . . permute levels to allow inclusion
##
##  This function is used only internally! It is called, whenever a new
##  inclusion info that vertex <v1> is contained in vertex <v2> turns up
##  and the system is in doubt, that the level of <v1> is actually lower
##  on the screen than that of <v2>. This can happen, if a graphic subgroup
##  lattice does not have the `HasseProperty' (for example for finitely
##  presented groups) or if the group is a space group and one of the
##  vertices is in an "infinity" level. If the level of <v1> is higher
##  on the screen than that of <v2>, this function first tries to move
##  the level of <v1> right below the level of <v2>. If this does not
##  work, it tries, to move the level of <v2> directly over the level of
##  <v1>. If this does not work either, it tries to find a "way" of known
##  inclusions from <v2> up to <v1>. If such a way is found, we know
##  that the vertices represent the same subgroup and we call 
##  `MergeVertices' to merge them. If no such way is found, `fail' is 
##  returned. If one of the first movement steps succeeds, the function
##  returns the string "DOWN" if the level of <v1> is moved under the
##  level of <v2>, and "UP" if the level of <v2> is moved over <v1>. It
##  returns `true', if no movement is necessary.

GGLEnsureLevelIsLower := function(sheet,v1,v2)
  local   p1,  p2;
  
  # first check if the level of v1 is lower than that of v2:
  p1 := Position(sheet!.levelparams,v1!.levelparam);
  p2 := Position(sheet!.levelparams,v2!.levelparam);
  if p1 < p2 then
    # we have a problem, first we try to move p1 down:
    if MoveLevel(sheet,v1!.levelparam,p2) <> fail then
      Info(GraphicLattice,1,"Moved level ",v1!.levelparam," down to ",
           "position ",p2,".");
      return("DOWN");
    else
      # that was no solution, we try to move p2 up:
      if MoveLevel(sheet,v2!.levelparam,p1) <> fail then
        Info(GraphicLattice,1,"Moved level ",v2!.levelparam," up to ",
             "position ",p1,".");
        return("UP");
      else
        # that did not work either, so the last idea:
        if GPSearchWay(sheet,v1,v2,p2) then
          MergeVertices(sheet,v1,v2);
          return true;   # we are done with this inclusion!
        else
          return fail;
        fi;
      fi;
    fi;   
    # if we reach this point, the levels are ok, p1 > p2
  elif p1 = p2 then   # equal levels, that is easy:
    # we can do this because we put vertices with infinite index in separate
    # levels each, so they must be equal if they are in some equal (finite)
    # index. FIXME
    MergeVertices(sheet,v1,v2);
    return true;
  fi;
  return true;
end;

  
#############################################################################
##
#M  InsertVertex( <sheet>, <grp>, <conj>, <hints> ) . . . . insert new vertex
##
##  Insert the group <grp> as a new vertex into the sheet. If 
##  CanCompareSubgroups is set for the lattice, we check, if the group is
##  already in the lattice or if we already have a conjugate subgroup.
##  If the lattice has the HasseProperty, then this new vertex is sorted 
##  into the poset. So we check for all vertices on higher levels, if
##  the new vertex is contained and for all vertices on lower levels,
##  if they are contained in the new vertex. We try then to add edges to
##  the appropriate vertices. If the lattice does not have the HasseProperty,
##  nothing is done with respect to the connections of any vertex.
##  Returns list with vertex as first entry and a flag as second, which 
##  says, if this vertex was inserted right now or has already been there.
##  <hint> is a list of x coordinates which should give some hint for the
##  choice of the new x coordinate. It can for example be the x coordinates
##  of those groups which were parameter for the operation which calculated
##  the group. <hints> can be empty but must always be a list!
##  If the lattice does not have CanCompareSubgroups and <conj> is a vertex
##  we put the new vertex into the class of this vertex. Otherwise <conj>
##  should either be false or fail.
##  `InsertVertex' can return `fail', if `CanComputeIndex' *and*
##  `CanComputeSize' return `false' for the subgroup.
##
InstallMethod( InsertVertex,
    "for a graphic subgroup lattice, a group, and a list",
    true,
    [ IsGraphicSubgroupLattice, IsGroup, IsObject, IsList ],
    0,
        
function( sheet, grp, conjugclass, hints )
  local   data,  size,  index,  d,  newlevel,  vertex,  v,  vers,  
          lev,  cl,  conj,  str,  Walkup,  Walkdown,  containerlist,  
          res,  containedlist;
  
  data := rec(group := grp, info := rec());
  
  # The following code is activated since CanComputeSize and CanComputeIndex
  # work:
  if CanComputeSize(grp) then
    size := Size(grp);
  else
    size := fail;
  fi;

  if CanComputeIndex(sheet!.group,grp) then
    index := Index(sheet!.group,grp);
    data.info.Index := index;
  else
    index := fail;
  fi;

  if index = fail and size = fail then
    d := Dialog("OKcancel",
                Concatenation("GAP claims not to be able to calculate the ",
                 "index of a subgroup in the whole group. Proceed anyway?"));
    if Query(d,GroupString(grp,"Group")) = false then
      return fail;
    fi;
    # We do it anyway:
    index := Index(sheet!.group,grp);
    data.info.Index := index;
  fi;
  
  # What will be the level parameter?
  if index <> fail and index <> infinity then
    newlevel := index;
  elif size <> fail and size <> infinity then
    newlevel := -size;
  else
    newlevel := infinity;
  fi;
  # note that in case of an infinity level only one vertex per level is
  # allowed, so it is no bug, that we change the level parameter
  # only later to its correct value [infinity, <n>]!
  
  # Is this vertex already in the sheet?
  # Note that we check this *before* we create a level because of the
  # infinity levels: We would produce an empty level, if we created
  # one and noticed afterwards, that we already have the vertex!
  vertex := false;   # will become the new vertex
  if CanCompareSubgroups(sheet) then
    # we search for this group:
    v := WhichVertex(sheet,grp,function(data,vdata) 
                                 return data=vdata.group; 
                               end);
    if v <> fail then      
      return( [v,false] );
    fi;
    
    # perhaps we have a conjugate group?
    vers := [];
    lev := Position( Levels(sheet), newlevel );
    if lev <> fail then
      # Note: this can happen if there is not yet a level for the new vertex!
      #       (for example in the "infinity" case!)
      lev := sheet!.levels[lev];
        # we walk through all classes and search the class representative:
      for cl in lev!.classes do
        if Length(cl) <> 0 then
          Add(vers,cl[1]);
        else          # This is the case of an empty class!
          Add(vers,false);
        fi;
      od;
      
      if Length(vers) = 0 then 
        conj := fail;
      else
        conj := First([1..Length(vers)],
                      v->(vers[v] <> false and
                          IsConjugate(sheet!.group,grp,vers[v]!.data.group)));
      fi;
      
      if conj <> fail then
        # we insert into that class
        
        sheet!.largestlabel := sheet!.largestlabel+1;
        data.class := vers[conj]!.data.class;
        vertex := Vertex(sheet,data,rec(levelparam := newlevel,
                          classparam := lev!.classparams[conj],
                          label := String(sheet!.largestlabel)));
      fi;
    fi;
  fi;
  
  # do we have this level yet?
  if newlevel = infinity then
    sheet!.largestinflevel := sheet!.largestinflevel + 1;
    if IsBound(HasIsSpaceGroup) and IsBound(IsSpaceGroup) and
       IsBound(TranslationBasis) and
       CallFuncList(HasIsSpaceGroup,[sheet!.group]) and 
       CallFuncList(IsSpaceGroup,[sheet!.group]) then
      # We calculate the Hirsch-Length of this subgroup:
      newlevel := [Concatenation("H",
                      String(Length(CallFuncList(TranslationBasis,[grp])))),
                   sheet!.largestinflevel];
    else
      newlevel := [infinity,sheet!.largestinflevel];
    fi;
  fi;
  
  if Position(Levels(sheet),newlevel) = fail then
    if IsInt(newlevel) then
      if newlevel < 0 then
        str := "Size ";
        Append(str,String(-newlevel));
      else
        str := "Index ";
        Append(str,String(newlevel));
      fi;
    else
      str := String(newlevel);
    fi;
    CreateLevel(sheet,newlevel,str);
  fi;
  
  # if not yet done we create a new vertex in a new class:
  if vertex = false then
    data.class := [data];
    sheet!.largestlabel := sheet!.largestlabel + 1;
    if IsGPVertex(conjugclass) then
      vertex := Vertex(sheet,data,rec(levelparam := conjugclass!.levelparam,
                                      classparam := conjugclass!.classparam,
                                      label := String(sheet!.largestlabel)));
    else
      vertex := Vertex(sheet,data,rec(levelparam := newlevel,
                                      label := String(sheet!.largestlabel)));
    fi;
  fi;
 
  # Is it a normal subgroup?
  if (IsInt(index) and index < GGLLimitForIsNormalCalc) or
    (IsIdenticalObj(sheet!.group,Parent(grp))
     and HasIsNormalInParent(grp)) then
    if IsNormal(sheet!.group,grp) then
      Reshape(sheet,vertex,"diamond");
      vertex!.data.info.IsNormal := true;
    else
      vertex!.data.info.IsNormal := false;
    fi;
  else
    Reshape(sheet,vertex,"rectangle");
  fi;
  
  if not HasseProperty(sheet) then
    return [vertex,true];
  fi;
  
  # now coming to the connections, we first search all higher levels
  # for vertices which contain our group. All those and those which are
  # even higher in the hierarchy meaning they contain vertices which contain
  # the new vertex, are stored in a list by their serial numbers to shorten
  # the search:

  # Note that for "infinity" levels it is necessary to check against
  # all groups in the sheet, because the level says nothing at all 
  # about relative inclusion to other subgroups. As of now, this happens
  # only for space groups provided by the CRYST share package, but this
  # will be true for infinite polycyclic presented groups!
  
  Walkup := function(v)
    local   w;
    for w in v!.maximalin do
      if PositionSet(containerlist,w!.serial) <> fail then
        AddSet(containerlist,w!.serial);
        Walkup(w);
      fi;
    od;
  end;
  
  Walkdown := function(v)
    local   w, list;
    # first check if there are superfluos connections:
    # we need a copy because `Delete' changes v!.maximalin:
    list := ShallowCopy(v!.maximalin);
    for w in list do
      if PositionSet(containerlist,w!.serial) <> fail then
        # gotcha! Attention: new Edge not yet created, so no danger!
        Delete(sheet,w,v);
      fi;
    od;
    
    # now go down:
    for w in v!.maximals do
      if PositionSet(containedlist,w!.serial) <> fail then
        AddSet(containedlist,w!.serial);
        Walkdown(w);
      fi;
    od;
  end;
      
  containerlist := [vertex!.serial];
  if not IsList(newlevel) then       # no infinity level
    # all higher levels:
    lev := Position(Levels(sheet),newlevel)-1;
  else
    lev := Length(Levels(sheet));
  fi;
  while lev > 0 do
    # all classes:
    for cl in sheet!.levels[lev]!.classes do
      for v in cl do
        if PositionSet(containerlist,v!.serial) = fail then
          if IsSubgroup(v!.data.group,grp) then   # for infinity levels!
            # Check, whether the level of `vertex' is actually lower than
            # that of `v'. This can fail for infinity levels!
            res := GGLEnsureLevelIsLower(sheet,vertex,v);
            if res = fail then
              Info(GraphicLattice,1,
                   "This should never have happened! Tell Max!");
            fi;
            Edge(sheet,vertex,v);
            AddSet(containerlist,v!.serial);
            Walkup(v);
          fi;
        fi;
      od;
    od;
    lev := lev - 1;
  od;
  
  # we have now connected to all subgroups which contain our new one as
  # a maximal element and have stored the serial numbers of all vertices
  # that contain our new vertex.
  # we now do the same downwards but we cancel additionally all connections
  # between contained subgroups and overgroups (see `WalkDown').
  containedlist := [vertex!.serial];
  # all lower levels:
  if not(IsList(newlevel)) then
    lev := Position(Levels(sheet),newlevel)+1;
  else
    lev := 1;     # this is necessary for infinity levels!
  fi;
  while lev <= Length(Levels(sheet)) do
    # all classes:
    for cl in sheet!.levels[lev]!.classes do
      for v in cl do
        if PositionSet(containedlist,v!.serial) = fail then
          if IsSubgroup(grp,v!.data.group) then
            res := GGLEnsureLevelIsLower(sheet,v,vertex);
            if res = fail then
              Info(GraphicLattice,1,
                   "This should never have happened! Tell Max!");
            fi;
            AddSet(containedlist,v!.serial);
            Walkdown(v);
            Edge(sheet,vertex,v);
          fi;
        fi;
      od;
    od;
    lev := lev + 1;
  od;
  
  # now at last we are done.
  return [vertex,true];
  
end);

##
##  Another method for convenience:
##  Note that here the vertex is automatically selected!
##  no longer true since 1.4.1999
##
InstallOtherMethod( InsertVertex,
    "for a graphic subgroup lattice, and a subgroup",
    true,
    [ IsGraphicSheet and IsGraphicPosetRep and IsGraphicSubgroupLattice,
      IsGroup ],
    0,
function(sheet,group)
  local l;
  l := InsertVertex(sheet,group,fail,[]);
  # as of 1.4.1999 we do no longer select new vertices
  # Select(sheet,l[1],true);
  return l;
end);

    
##
## Here comes the rest of the dirty hack because we want to use functions
## from the CRYST share package once they are available:
##
if definedHasIsSpaceGroup then 
  Unbind(HasIsSpaceGroup);
  Unbind(definedHasIsSpaceGroup);
fi;
if definedIsSpaceGroup then 
  Unbind(IsSpaceGroup);
  Unbind(definedIsSpaceGroup);
fi;
if definedTranslationBasis then 
  Unbind(TranslationBasis);
  Unbind(definedTranslationBasis);
fi;


#############################################################################
##
#M  NewInclusionInfo( <sheet>, <v1>, <v2> ) . . . . . . . . . . v1 lies in v2
##
##  For graphic group lattices without the HasseProperty we cannot calculate
##  all inclusion information for each new vertex. This operation is the
##  proposed method to enter an inclusion information which normally comes
##  out of the process of subgroup calculation into the poset. It should
##  normally only be called if one conjectures or knows that v1 is a
##  maximal subobject with respect to the current poset, but the methods
##  for this operation first check, if there is already a way from v1 up
##  to v2. If this is the case, nothing is done. Otherwise we have to check,
##  if this new connection can be established: If v2 lies in a lower level
##  than v1 (of course those two levels are not comparable, so by definition
##  both subgroups must lie in a level of their own!) then, we try
##  to move the level of v1 into a new level right below that of v2. If 
##  that does not work we try to move the level of v2 right over the level
##  of v1. If that does not work check if we know that v2 is contained in v1
##  In this case we call MergeVertices. Otherwise we finally give up and 
##  display an info!
##  Now we draw the connection but have to make sure, that this new connection
##  does not close a circle such that there is an edge in the poset which
##  connects a vertex "below" v1 to a vertex "over" v2. Therefore we 
##  calculate all vertices lying "below" v1 and "over" v2 and disconnect
##  them pairwise. This is all done by means of posets and not by means
##  of groups. There are no group inclusion checks performed!
InstallMethod( NewInclusionInfo,
    "for a graphic subgroup lattice, and two vertices",
    true,
    [ IsGraphicPosetRep and IsGraphicSubgroupLattice, IsGPVertex, IsGPVertex ],
    0,

function( sheet, v1, v2 )
  local   res,  over,  Walkup,  under,  Walkdown,  v,  w;
  
  # A trivial case:
  if v1 = v2 then
    return;
  fi;
  
  # first make sure that there is no "way" from v2 down to v1 on the 
  # connections which are already in the poset. We use the function
  # GPSearchWay in poset.gi. Documentation there says:
  #   The following function is only internal:
  #   Use it on your own risk and only if you know what you are doing!
  # So I (Max) say:
  #  *I know what I am doing!*
  if GPSearchWay(sheet, v2, v1, 
                 Position(sheet!.levelparams,v1!.levelparam)) then
    # note the order of the vertices in the calling convention!
    # see: I really know what I am doing!
    return;
  fi;
  # note: this works also, if v1 is in a higher level than v2 and is very
  #       fast in this case!
  
  # now check if the level of v1 is lower than that of v2:
  res := GGLEnsureLevelIsLower(sheet,v1,v2);
  if res = fail then
    Info(GraphicLattice,1,"Cannot use inclusion ",v1!.label," in ",
         v2!.label," because of levels!");
    if GGLLogFile <> false then
      AppendTo(GGLLogFile,"Cannot use inclusion ",v1!.label," in ",
              v2!.label," because of levels!\n");
    fi;
    return;       # nothing to do!
  fi;
  
  # now we can begin our work. we don't have a way between the vertex v1 and
  # the vertex v2, which lies higher in the poset.
  # we collect now all vertices "over" v2 and all vertices "under" v1:
  over := [v2];
  Walkup := function(v)
    local   w;
    for w in v!.maximalin do
      if PositionSet(over,w) = fail then
        Walkup(w);
        AddSet(over,w);
      fi;
    od;
  end;
  
  Walkup(v2);
  
  under := [v1];
  Walkdown := function(v)
    local   w;
    for w in v!.maximals do
      if PositionSet(under,w) = fail then
        Walkdown(w);
        AddSet(under,w);
      fi;
    od;
  end;
  
  Walkdown(v1);
  
  # now we consider all pairs:
  for v in over do
    for w in under do
      if w in v!.maximals and (v <> v2 or w <> v1) then
        Delete(sheet,v,w);   # we delete the edge
      fi;
    od;
  od;
  
  # a new edge:
  Edge(sheet,v1,v2);
  return;
end);


#############################################################################
##
#M  MergeVertices( <sheet>, <v1>, <v2> ) . . . . . . . . . . . merge vertices
##
##  For graphic group lattices without the HasseProperty we cannot calculate
##  all inclusion information for each new vertex. If we don't have
##  CanCompareSubgroups either, we have to think of the case where we have two
##  vertices to which belongs the same group respectively. If we come to
##  know this, then we have to fix this situation by merging vertices.
##  This operation does exactly this *without* further checks. The vertex
##  having the lower (that is older) serial number survives and inherits all
##  inclusion information the other one has. This in turn is deleted.
##
InstallMethod( MergeVertices,
    "for a graphic subgroup lattice, and two vertices",
    true,
    [ IsGraphicPosetRep and IsGraphicSubgroupLattice, IsGPVertex, IsGPVertex],
    0,

function( sheet, v1, v2 )
  local   p1,  p2,  dummy,  v2maximalin,  v2maximals,  v,  lev,  cls;
  
  # we check the levels:
  p1 := Position(sheet!.levelparams,v1!.levelparam);
  if p1 = fail then
    return fail;
  fi;
  p2 := Position(sheet!.levelparams,v2!.levelparam);
  if p2 = fail then
    return fail;
  fi;
  if v1!.serial > v2!.serial then                                               
    dummy := v1;                                                                
    v1 := v2;                                                                   
    v2 := dummy;                                                                
  fi;                                                                           
  # now v1 is "older", this is the one that survives
  
  # we remember the connections of v2:
  v2maximalin := ShallowCopy(v2!.maximalin);
  v2maximals := ShallowCopy(v2!.maximals);
  
  Delete(sheet,v2);  # now v2 is gone with all connections!
  
  # give some information:
  Info(GraphicLattice,1,"Vertices ",v1!.label," and ",v2!.label,
       " are merged!");
  if GGLLogFile <> false then
    AppendTo(GGLLogFile,"Vertices ",v1!.label," and ",v2!.label,
             " are merged!\n");
  fi;
  
  # we use the inclusions of v2 as new inclusion information for v1:
  # note that it is possible that this can move around levels and even
  # call MergeVertices recursively! So we have to ensure that the vertices
  # in these lists (and v1) are still in the poset if we come to the new 
  # connections: 
  for v in v2maximalin do
    p1 := Position(sheet!.levelparams,v!.levelparam);
    if p1 <> fail then
      lev := sheet!.levels[p1];
      p2 := Position(lev!.classparams,v!.classparam);
      if p2 <> fail then
        cls := lev!.classes[p2];
        if Position(cls,v) <> fail then
          p1 := Position(sheet!.levelparams,v1!.levelparam);
          if p1 <> fail then
            lev := sheet!.levels[p1];
            p2 := Position(lev!.classparams,v1!.classparam);
            if p2 <> fail then
              cls := lev!.classes[p2];
              if Position(cls,v1) <> fail then
                # we have both!
                NewInclusionInfo(sheet,v1,v);
              fi;
            fi;
          fi;
        fi;
      fi;
    fi;
  od;
  for v in v2maximals do
    p1 := Position(sheet!.levelparams,v!.levelparam);
    if p1 <> fail then
      lev := sheet!.levels[p1];
      p2 := Position(lev!.classparams,v!.classparam);
      if p2 <> fail then
        cls := lev!.classes[p2];
        if Position(cls,v) <> fail then
          p1 := Position(sheet!.levelparams,v1!.levelparam);
          if p1 <> fail then
            lev := sheet!.levels[p1];
            p2 := Position(lev!.classparams,v1!.classparam);
            if p2 <> fail then
              cls := lev!.classes[p2];
              if Position(cls,v1) <> fail then
                # we have both!
                NewInclusionInfo(sheet,v,v1);
              fi;
            fi;
          fi;
        fi;
      fi;
    fi;
  od;
  return;
end);

  
#############################################################################
##
#M  CompareLevels(<poset>,<levelp1>,<levelp2>) . . . compares two levelparams
##
##  Compare two levelparams. -1 means that levelp1 is "higher", 1 means
##  that levelp2 is "higher", 0 means that they are equal. fail means that
##  they are not comparable. This method is for the case of subgroup lattices
##  parameters are integers or a list with first entry infinity. All those
##  "infinities" are not comparable. Negative values are Sizes instead of 
##  indices. They are lower than infinity and than all finite indices.
##  One has to make sure that the index is used if the whole group is finite,
##  because this method can not decide, if G is finite.
##
TEMPORARYFUNCTION := function( poset, l1, l2 )
  if IsList(l1) then          # infinity!
    if IsList(l2) then        # two infinities not comparable
      # Here we have the special case of a space group, where the Hirsch-
      # length is in the first component: Higher Hirsch lengths are higher
      # in the lattice:
      if IsString(l1[1]) and IsString(l2[1]) then
        if Length(l1[1]) > Length(l2[1]) then   # first has more digits
          return -1;
        elif Length(l1[1]) < Length(l2[1]) then # second has more digits
          return 1;
        elif l1[1] > l2[1] then  # this is string comparison!
          return -1;
        elif l1[1] < l2[1] then
          return 1;
        else
          return fail;
        fi;
      else
        return fail;
      fi;
    elif l2 > 0 then          # infinity lower than number
      return 1;
    else                      # infinity higher than size
      return -1;
    fi;      
  elif l1 > 0 then
    if IsList(l2) then        # index higher than infinity
      return -1;
    elif l2 > 0 then          # two indices, smaller index is higher
      if l1 < l2 then
        return -1;
      elif l1 > l2 then
        return 1;
      else
        return 0;             # they are equal
      fi;
    else      # l2 < 0        # indices higher than sizes
      return -1;
    fi;
  else   # l1 < 0
    if IsList(l2) then        # infinite higher than sizes
      return 1;
    elif l2 > 0 then          # indices higher than sizes
      return 1;
    else                      # two sizes, bigger size is higher
      if l1 < l2 then
        return -1;
      elif l1 = l2 then
        return 0;
      else    # l1 > l2
        return 1;
      fi;
    fi;
  fi;
end;

InstallOtherMethod( CompareLevels,
    "for a graphic subgroup lattice, and two objects",
    true,
    [ IsGraphicPosetRep and IsGraphicSubgroupLattice, IsObject, IsObject ],
    34,   # this is necessary because of IsObject, IsObject, is it?
    TEMPORARYFUNCTION
);

InstallMethod( CompareLevels,
    "for a graphic subgroup lattice, and two integers",
    true,
    [ IsGraphicPosetRep and IsGraphicSubgroupLattice, IsInt, IsInt ],
    0, TEMPORARYFUNCTION
);



#############################################################################
##
##  Constructors:  
##
#############################################################################
  
#############################################################################
##
#F  GGLMakeSubgroupsMenu( <sheet>, <config> ) . . . . .  makes subgroups menu
##
##  This function is used to generate a menu out of the configuration data.
##
InstallGlobalFunction( GGLMakeSubgroupsMenu,
  function( sheet, config )
  
  local   entries,  types,  functions,  i,  c;
  
  entries := [];
  types := [];
  functions := [];
  
  for i in [1..Length(config)] do
    if IsBound(config) then
      c := config[i];
      entries[i] := c.name;
      functions[i] := GGLMenuOperation;
      if c.from = GGLfrom1 then
        if c.plural then
          types[i] := "forsubset";
        else
          types[i] := "forone";
        fi;
      elif c.from = GGLfrom2 then
        if c.plural then
          types[i] := "formin2";
        else
          types[i] := "fortwo";
        fi;
      elif c.from = GGLfromSet then
        types[i] := "forsubset";
      else  # c.from = GGLfromAny
        types[i] := "forany";
      fi;
    fi;
  od;
  
  Menu( sheet, "Subgroups", entries, types, functions );
end);


#############################################################################
##
#M  GraphicSubgroupLattice(<G>) . . . . displays subgroup lattice graphically
#M  GraphicSubgroupLattice(<G>,<def>)  . . . . . . . . . . same with defaults
##
##  Displays a graphic poset which shows (parts of) the subgroup lattice of
##  the group <group>. Normally only the whole group and the trivial group are
##  shown (behaviour of "InteractiveLattice" in xgap3). Returns a
##  IsGraphicSubgroupLattice object. Calls DecideSubgroupLatticeType. See
##  there for details.
##
InstallMethod( GraphicSubgroupLattice,
    "for a group, and a record",
    true,
    [ IsGroup, IsRecord ],
    0,
        
function(G,def)
  local   latticetype,  defaults,  poset,  indices,  levelheight,  l,  str,  
          vmath,  v2,  v1;
  
  latticetype := DecideSubgroupLatticeType(G);
  # we do some heuristics to avoid the trivial group:
  # if we know all levels, we probably can calc. Size, if we shall generate
  # a vertex for the trivial subgroup, we should also know Size!
  if latticetype[1] or latticetype[4] then   
    # no trivial case:
    if Size(G) = 1 then
      return Error( "<G> must be non-trivial" );
    fi;
  fi;
  
  # we need a defaults record for the poset:
  defaults := rec(width := 800,
                  height := 600,
                  title := "GraphicSubgroupLattice");
  if HasName(G) then
    defaults.title := Concatenation(defaults.title," of ",Name(G));
  elif HasIdGroup(G) then
    defaults.title := Concatenation(defaults.title," of ",String(IdGroup(G)));
  fi;
  
  if IsBound(def.width) then defaults.width := def.width; fi;
  if IsBound(def.height) then defaults.height := def.height; fi;
  if IsBound(def.title) then defaults.title := def.title; fi;
  
  # we open a graphic poset:
  poset := GraphicPoset(defaults.title,defaults.width,defaults.height);
  # and make it a GraphicSubgroupLattice:
  SetFilterObj( poset, IsGraphicSubgroupLattice );
  
  poset!.group := G;
  
  # now the other filters, depending on type:
  if latticetype[1] then
    SetFilterObj(poset,KnowsAllLevels);
  fi;
  if latticetype[2] then
    SetFilterObj(poset,HasseProperty);
  fi;
  if latticetype[3] then
    SetFilterObj(poset,CanCompareSubgroups);
  fi;
  
  # initialize some components:
  poset!.selector := false;
  InstallCallback(poset,"Close",
          function(poset)
            if poset!.selector <> false then
              Close(poset!.selector);
              poset!.selector := false;
            fi;
            
            # get rid of an old text selectors for Epis:
            if GGLEpiTextsel <> false then
              Close(GGLEpiTextsel);
              GGLEpiTextsel := false;
            fi;
          end);
          
  # set the limits:
  poset!.limits := rec(conjugates := 100);
  
  if KnowsAllLevels(poset) then
    # create all possible level parameters and levels:
    indices := DivisorsInt(Size(G));
    levelheight := QuoInt(poset!.height,Length(indices));
    for l in indices do
      str := "Index ";
      Append(str,String(l));
      CreateLevel(poset,l,str);
      ResizeLevel(poset,l,levelheight);
    od;
  else
    # we just create one or two levels:
    CreateLevel(poset,1,"Index 1");  # for the whole group
    if latticetype[4] then
      if CanComputeSize(G) and Size(G) <> infinity then
        str := "Index ";
        Append(str,String(Size(G)));
        CreateLevel(poset,Size(G),str);
      else
        CreateLevel(poset,-1,"Size 1");
      fi;
    fi;
  fi;
  
  # create one or two initial vertices (G itself and trivial subgroup):
  # we seperate the mathematical data and the graphical data:
  vmath := rec(group := G,
               info := rec(Index := 1, IsNormal := true));
  vmath.class := [vmath];
  v2 := Vertex(poset,vmath,rec(levelparam := vmath.info.Index, label := "G",
                               shape := "diamond"));
  poset!.WholeGroupVert := v2;
  
  # we keep track of largest label:
  poset!.largestlabel := 1;
  # we keep track of largest number of infinity label
  poset!.largestinflevel := 0;
  
  if latticetype[4] then
    vmath := rec(group := TrivialSubgroup(G));
    if CanComputeSize(G) then
      vmath.info := rec(Index := Size(G));
    else
      vmath.info := rec();
    fi;
    vmath.class := [vmath];
    if CanComputeSize(G) and Size(G) <> infinity then
      v1 := Vertex(poset,vmath,rec(levelparam := vmath.info.Index,label := "1",
                    shape := "diamond"));
    else
      v1 := Vertex(poset,vmath,rec(levelparam := -1,label := "1",
                    shape := "diamond"));
    fi;
    
    # connect the two vertices
    Edge(poset,v1,v2);
    poset!.TrivialGroupVert := v1;
  else
    poset!.TrivialGroupVert := false;
  fi;
  
  # <G> is selected at first
  Select(poset,v2,true);
  
  # create menus:
  GGLMakeSubgroupsMenu(poset,latticetype[5]);
  poset!.menuoperations := latticetype[5];
  
  # Install the info method:
  poset!.infodisplays := latticetype[6];
  InstallPopup(poset,GGLRightClickPopup);
  
  # no vertex is green right now:
  poset!.lastresult := [];
  
  # disable deletion of edges:
  Enable(poset!.menus[2],"Delete Edge",false);
         
  return poset;
end);

##
## without defaults record:
##
InstallOtherMethod(GraphicSubgroupLattice,
    "for a group",
    true,
    [ IsGroup ],
    0,
function(G)
  return GraphicSubgroupLattice(G,rec());
end);


#############################################################################
##
##  Decision function for subgroup lattice type:
##
#############################################################################


#############################################################################
##
#M  DecideSubgroupLatticeType(<grp>)  . . decides about the type of a lattice
##
##  This operation is called while creation of a new graphic subgroup lattice.
##  It has to decide about the type of the lattice. That means it has to
##  decide 5 questions:
##   1) Are all levels known right from the beginning?
##   2) Has the lattice the HasseProperty?
##   3) Can we test two subgroups for equality reasonably cheaply?
##   4) Shall we create a vertex for the trivial subgroup at the beginning?
##   5) What menu operations are possible?
##   6) What information is displayed on RightClick?
##  Returns a list. The first four entries are boolean values for  questions
##  1-4. Note that if the answer to 2 is true, then the answer to 3 must also
##  be true. The fifth and sixth entry are configuration lists as explained 
##  in the configuration section of "ilatgrp.gi" for menu operations and
##  info displays respectively.
##
##  The following is the default "fallback" method suitable for reasonably
##  small finite groups.
##
InstallMethod( DecideSubgroupLatticeType,
    "for a group",
    true,
    [ IsGroup ],
    0,
        
function( G )
  local   knowslevels;
  if Size(G) > 10^17 then    # that is just heuristic!
    knowslevels := false;
  else
    knowslevels := Length(DivisorsInt(Size(G))) < 50;
  fi;
  return [knowslevels,
          true,         # we assume HasseProperty
          true,         # we assume we can compare groups
          true,         # we want the trivial subgroup
          GGLMenuOpsForFiniteGroups,
          GGLInfoDisplaysForFiniteGroups];
end);

## for finitely presented groups:
InstallMethod( DecideSubgroupLatticeType,
    "for a group",
    true,
    [ IsGroup and IsFpGroup ],
    0,
        
function( G )
  return [false,        # we create levels dynamically
          false,        # we do not assume HasseProperty
          false,        # we assume we cannot compare groups efficiently
          false,        # we don't want the trivial subgroup
          GGLMenuOpsForFpGroups,
          GGLInfoDisplaysForFpGroups];
end);


############################################################################
##
##  Operations to switch between graphics and GAP calculations:
##
############################################################################


############################################################################
##
#M  SelectedGroups( <sheet> ) . . . . . . .  returns list of selected groups
##
##  Uses the `Selected' operation to get a list of vertices and returns the
##  corresponding list of subgroups.
##
InstallMethod( SelectedGroups,
    "for a graphic subgroup lattice",
    true,
    [ IsGraphicSheet and IsGraphicPosetRep and IsGraphicSubgroupLattice ],
    0,
function( sheet )
  return List(Selected(sheet),v->v!.data.group);
end);


############################################################################
##
#M  SelectGroups( <sheet>, <list> ) . . . . . . . . select subgroups in list
##
##  Uses the `Select' operation to select exactly those vertices to which
##  the subgroups in the supplied list belong. Be careful: We use
##  `IsIdenticalObj' here because comparison must be fast. If a subgroup is
##  not yet as vertex in the lattice, only a warning is printed. If two
##  or more vertices have the subgroup as associated group, only one of them
##  is selected.
##
InstallMethod( SelectGroups,
    "for a graphic subgroup lattice",
    true,
    [ IsGraphicSheet and IsGraphicPosetRep and IsGraphicSubgroupLattice,
      IsList ],
    0,
function( sheet, li )
  local   g,  v;
  DeselectAll(sheet);
  for g in li do
    if not IsGroup(g) then
      Info(GraphicLattice,1,"Warning: This is no subgroup: ",g);
      if GGLLogFile <> false then
        AppendTo(GGLLogFile,"Warning: This is no subgroup: ",g,"\n");  
      fi;
    else
      v := WhichVertex(sheet,g,function(a,b) 
                                 return a = b.group;
                               end );
      if v = fail then
        Info(GraphicLattice,1,"Warning: Subgroup not in lattice: ",g);
        if GGLLogFile <> false then
          AppendTo(GGLLogFile,"Warning: Subgroup not in lattice: ",g,"\n");  
        fi;
      else
        Select(sheet,v,true);
      fi;
    fi;
  od;
end);


#############################################################################
##  
##  Some small things that don't fit in another section:
##
#############################################################################

##
##  ViewObj methods:
##
InstallMethod( ViewObj,"for a graphic subgroup lattice",true,
        [IsGraphicSheet and IsGraphicSheetRep and IsGraphicGraphRep and 
         IsGraphicPosetRep and IsGraphicSubgroupLattice],
        0,function( sheet ) 
  Print("<");
  if not IsAlive(sheet) then
    Print("dead ");
  fi;
  Print("graphic subgroup lattice \"",sheet!.name,"\">");
end);
  
