#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include James D. Mitchell.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declarations for equivalence relations on
##  semigroups. Of particular interest are Green's relations,
##  congruences, and Rees congruences.
##

# Viewing, printing, etc

InstallMethod(ViewString, "for a Green's class",
[IsGreensClass],
function(C)
  local str;

  str := "\><";
  Append(str, "\>Green's\< ");

  if IsGreensDClass(C) then
    Append(str, "D");
  elif IsGreensRClass(C) then
    Append(str, "R");
  elif IsGreensLClass(C) then
    Append(str, "L");
  elif IsGreensHClass(C) then
    Append(str, "H");
  elif IsGreensJClass(C) then
    Append(str, "J");
  fi;
  Append(str, "-class: ");
  Append(str, ViewString(Representative(C)));
  Append(str, ">\<");

  return str;
end);

InstallMethod(PrintObj, "for a Green's class",
[IsGreensClass],
function(C)
  Print(PrintString(C));
  return;
end);

InstallMethod(PrintString, "for a Green's class",
[IsGreensClass],
function(C)
  local str;

  str := "\>\>\>Greens";
  if IsGreensDClass(C) then
    Append(str, "D");
  elif IsGreensRClass(C) then
    Append(str, "L");
  elif IsGreensLClass(C) then
    Append(str, "L");
  elif IsGreensHClass(C) then
    Append(str, "H");
  elif IsGreensJClass(C) then
    Append(str, "J");
  fi;
  Append(str, "ClassOfElement\<(\>");
  Append(str, PrintString(Parent(C)));
  Append(str, ",\< \>");
  Append(str, PrintString(Representative(C)));
  Append(str, "\<)\<\<");

  return str;
end);

#######################
#######################
##
#M GreensRRelation(<semigroup>)
#M GreensLRelation(<semigroup>)
#M GreensHRelation(<semigroup>)
#M GreensDRelation(<semigroup>)
#M GreensJRelation(<semigroup>)
##
## returns the appropriate equivalence relation which is stored as an attribute.
## The relation knows nothing about itself except its source, range, and what
## type of congruence it is.


InstallMethod(GreensRRelation, "for a semigroup", true, [IsSemigroup], 0,
function(X)
    local fam, rel;

    fam :=  GeneralMappingsFamily( ElementsFamily(FamilyObj(X)),
             ElementsFamily(FamilyObj(X)) );

    # Create the default type for the elements.
    rel :=  Objectify(NewType(fam,
               IsEquivalenceRelation and IsEquivalenceRelationDefaultRep
               and IsGreensRRelation), rec());

    SetSource(rel, X);
    SetRange(rel, X);
    SetIsLeftSemigroupCongruence(rel,true);

    if HasIsFinite(X) and IsFinite(X) then
       SetIsFiniteSemigroupGreensRelation(rel, true);
    fi;

    return rel;
end);

InstallMethod(GreensLRelation, "for a semigroup", true, [IsSemigroup], 0,
function(X)
    local fam, rel;

    fam :=  GeneralMappingsFamily( ElementsFamily(FamilyObj(X)),
            ElementsFamily(FamilyObj(X)) );

    # Create the default type for the elements.
    rel :=  Objectify(NewType(fam,
            IsEquivalenceRelation and IsEquivalenceRelationDefaultRep
            and IsGreensLRelation), rec());

    SetSource(rel, X);
    SetRange(rel, X);
    SetIsRightSemigroupCongruence(rel,true);
    if HasIsFinite(X) and IsFinite(X) then
      SetIsFiniteSemigroupGreensRelation(rel, true);
    fi;

    return rel;
end);

InstallMethod(GreensJRelation, "for a semigroup", true, [IsSemigroup], 0,
function(X)
    local fam, rel;

    fam :=  GeneralMappingsFamily( ElementsFamily(FamilyObj(X)),
            ElementsFamily(FamilyObj(X)) );

    # Create the default type for the elements.
    rel :=  Objectify(NewType(fam,
            IsEquivalenceRelation and IsEquivalenceRelationDefaultRep
            and IsGreensJRelation), rec());

    SetSource(rel, X);
    SetRange(rel, X);
    if HasIsFinite(X) and IsFinite(X) then
      SetIsFiniteSemigroupGreensRelation(rel, true);
    fi;

    return rel;
end);

InstallMethod(GreensDRelation, "for a semigroup", true, [IsSemigroup], 0,
function(X)
    local fam, rel;

    fam :=  GeneralMappingsFamily( ElementsFamily(FamilyObj(X)),
            ElementsFamily(FamilyObj(X)) );

    # Create the default type for the elements.
    rel :=  Objectify(NewType(fam,
            IsEquivalenceRelation and IsEquivalenceRelationDefaultRep
            and IsGreensDRelation), rec());

    SetSource(rel, X);
    SetRange(rel, X);

    if HasIsFinite(X) and IsFinite(X) then
      SetIsFiniteSemigroupGreensRelation(rel, true);
    fi;

    return rel;
end);

InstallMethod(GreensHRelation, "for a semigroup", true, [IsSemigroup], 0,
function(X)
    local fam, rel;

    fam :=  GeneralMappingsFamily( ElementsFamily(FamilyObj(X)),
            ElementsFamily(FamilyObj(X)) );

    # Create the default type for the elements.
    rel :=  Objectify(NewType(fam,
            IsEquivalenceRelation and IsEquivalenceRelationDefaultRep
            and IsGreensHRelation), rec());

    SetSource(rel, X);
    SetRange(rel, X);

    if HasIsFinite(X) and IsFinite(X) then
      SetIsFiniteSemigroupGreensRelation(rel, true);
    fi;

    return rel;
end);

InstallMethod( ViewObj, "for GreensJRelation", [IsGreensJRelation],
    function( obj )
    Print( "< Green's J-relation on ");
    ViewObj(Source(obj));
    Print(" >");
end );

InstallMethod( ViewObj, "for GreensDRelation", [IsGreensDRelation],
    function( obj )
    Print( "< Green's D-relation on ");
    ViewObj(Source(obj));
    Print(" >");
end );

InstallMethod( ViewObj, "for GreensHRelation", [IsGreensHRelation],
    function( obj )
    Print( "< Green's H-relation on ");
    ViewObj(Source(obj));
    Print(" >");
end );

InstallMethod(\=, "for GreensRelation", [IsGreensRelation, IsGreensRelation],
    function(rel1, rel2)
    if not Source(rel1)=Source(rel2) then
      Error("Green's relations do not belong to the same semigroup");
    elif IsGreensRRelation(rel1) and not IsGreensRRelation(rel2) then
      return false;
    elif IsGreensLRelation(rel1) and not IsGreensLRelation(rel2) then
      return false;
    elif IsGreensHRelation(rel1) and not IsGreensHRelation(rel2) then
      return false;
    elif IsGreensDRelation(rel1) and not IsGreensDRelation(rel2) then
      return false;
    elif IsGreensJRelation(rel1) and not IsGreensJRelation(rel2) then
      return false;
    else
      return true;
    fi;
end);

#############################################################################
##
##  The following operations are constructors for Green's class with
##  a given element as a representative. The call is for semigroups
##  and an element in the semigroup. This function doesn't check that
##  the element is actually a member of the semigroup.
##
#O  GreensRClassOfElement(<semigroup>, <representative>)
#O  GreensLClassOfElement(<semigroup>, <representative>)
#O  GreensJClassOfElement(<semigroup>, <representative>)
#O  GreensDClassOfElement(<semigroup>, <representative>)
#O  GreensHClassOfElement(<semigroup>, <representative>)
##

InstallMethod(GreensRClassOfElement, "for a semigroup and object",
IsCollsElms,
[IsSemigroup and HasIsFinite and IsFinite, IsObject],
function(s,e)
  return EquivalenceClassOfElementNC( GreensRRelation(s), e );
end);

InstallMethod(GreensLClassOfElement, "for a semigroup and object",
IsCollsElms,
[IsSemigroup and HasIsFinite and IsFinite, IsObject],
function(s,e)
  return EquivalenceClassOfElementNC( GreensLRelation(s), e );
end);


InstallMethod(GreensHClassOfElement, "for a semigroup and object",
IsCollsElms,
[IsSemigroup and HasIsFinite and IsFinite, IsObject],
function(s,e)
  return EquivalenceClassOfElementNC( GreensHRelation(s), e );
end);


InstallMethod(GreensDClassOfElement, "for a semigroup and object",
IsCollsElms,
[IsSemigroup and HasIsFinite and IsFinite, IsObject],
function(s,e)
  return EquivalenceClassOfElementNC( GreensDRelation(s), e );
end);

InstallMethod(GreensJClassOfElement, "for a semigroup and object",
IsCollsElms,
[IsSemigroup and HasIsFinite and IsFinite, IsObject],
function(s,e)
  return EquivalenceClassOfElementNC( GreensJRelation(s), e );
end);

#

InstallMethod(CanonicalGreensClass, "for a Green's class",
[IsGreensClass],
function(class)
  local x, canon;

  if IsGreensRClass(class) then
    x:=GreensRClasses(ParentAttr(class));
    canon:=First(x, y-> Representative(class) in y);
    SetCanonicalGreensClass(class, canon);
  elif IsGreensLClass(class) then
     x:=GreensLClasses(ParentAttr(class));
    canon:=First(x, y-> Representative(class) in y);
    SetCanonicalGreensClass(class, canon);
  elif IsGreensHClass(class) then
     x:=GreensHClasses(ParentAttr(class));
    canon:=First(x, y-> Representative(class) in y);
    SetCanonicalGreensClass(class, canon);
  elif IsGreensDClass(class) then
     x:=GreensDClasses(ParentAttr(class));
    canon:=First(x, y-> Representative(class) in y);
    SetCanonicalGreensClass(class, canon);
  elif IsGreensJClass(class) then
     x:=GreensJClasses(ParentAttr(class));
    canon:=First(x, y-> Representative(class) in y);
    SetCanonicalGreensClass(class, canon);
  fi;

  return canon;
end);

#################
#################
##
#M ImagesElm(<grelation>, <elm>)
##
## method to find the images under a GreensRelation of an
## element of a semigroup.
##

InstallMethod(ImagesElm, "for a Green's equivalence", true, [IsGreensRelation, IsObject], 0,
    function(rel, elm)
    local exp, semi;

    semi:=Source(rel);

    if IsGreensRRelation(rel) then
        exp:=GreensRClassOfElement(semi, elm);
    elif IsGreensLRelation(rel) then
        exp:=GreensLClassOfElement(semi, elm);
    elif IsGreensHRelation(rel) then
        exp:=GreensHClassOfElement(semi, elm);
    elif IsGreensDRelation(rel) then
        exp:=GreensDClassOfElement(semi, elm);
    elif IsGreensJRelation(rel) then
        exp:=GreensJClassOfElement(semi, elm);
    fi;

    return AsSSortedList(exp);
 end);

#################
#################
##
#M Successors(<grelation>)
##
## returns ImagesElm for one element in each class of <grelation>
##

InstallMethod(Successors, "for a Green's equivalence", true, [IsGreensRelation], 0,
    function( rel )
    return List(EquivalenceClasses(rel), AsSSortedList);
end);

#################
#################
##
#M AsSSortedList(<gclass>)
##
## returns the elements of the Greens class <gclass>
##

InstallMethod(AsSSortedList, "for a Green's class", true, [IsGreensClass], 0,
        x-> AsSSortedList(CanonicalGreensClass(x)));

#################
#################
##
#M \= (<class1>,<class2>)
##

InstallMethod(\=, "for Green's classes",  true, [IsGreensClass, IsGreensClass],
0,
function(class1,class2)
  if not ParentAttr(class1)=ParentAttr(class2) then
    Error("Green's classes do not belong to the same semigroup");
  elif not EquivalenceClassRelation(class1)=EquivalenceClassRelation(class2) then
    Error("Green's classes are not of the same type");
  else
    return Representative(class1) in class2;
  fi;
end);

#################
#################
##
#M Size(<gclass>)
##
## size of a Greens class
##

InstallMethod(Size, "for Green's classes", true, [IsGreensClass], 0,
function(class)
   return Size(AsSSortedList(class));
end);

#################
#################
##
#M <elm> in <gclass>
##
## membership test for a Greens class
##

InstallMethod(\in, "membership test of Green's class", true, [IsObject, IsGreensClass], 0,
function(elm, class)
  if elm=Representative(class) then
     return true;
  fi;
  return elm in AsSSortedList(class);
end);

#################
#################
##
#M EquivalenceRelationPartition(<grelation>)
##
##

InstallMethod(EquivalenceRelationPartition, "for a Green's equivalence", true, [IsEquivalenceRelation and IsGreensRelation], 0,
function(rel)
  return Filtered(Successors(rel), x-> not Length(x)=1);
end);

#################
#################
##
#M EquivalenceClassOfElementNC(<grelation>, <elt>)
##
## new methods required so that what is returned by this function
## is the appropriate type of Green's class

#JDM this should be 5 methods

InstallOtherMethod(EquivalenceClassOfElementNC,
"for a Green's relation and object",
[IsEquivalenceRelation and IsGreensRelation, IsObject],
function(rel, rep)
  local filts, new;

  filts:=IsEquivalenceClass and IsEquivalenceClassDefaultRep;
  if IsGreensRRelation(rel) then
    filts:=filts and IsGreensRClass;
  elif IsGreensLRelation(rel) then
    filts:=filts and IsGreensLClass;
  elif IsGreensHRelation(rel) then
    filts:=filts and IsGreensHClass;
  elif IsGreensDRelation(rel) then
    filts:=filts and IsGreensDClass;
  elif IsGreensJRelation(rel) then
    filts:=filts and IsGreensJClass;
  fi;

  new:= Objectify(NewType(CollectionsFamily(FamilyObj(rep)), filts), rec());

  SetEquivalenceClassRelation(new, rel);
  SetRepresentative(new, rep);
  SetParent(new, UnderlyingDomainOfBinaryRelation(rel));

  return new;
end);

#################
#################
##
#M EquivalenceClasses(<grelation>)
##
##

InstallMethod(EquivalenceClasses, "for a Green's R-relation", true, [IsEquivalenceRelation and IsGreensRRelation], 0,
x->GreensRClasses(Source(x)));

InstallMethod(EquivalenceClasses, "for a Green's L-relation", true, [IsEquivalenceRelation and IsGreensLRelation], 0,
x->GreensLClasses(Source(x)));

InstallMethod(EquivalenceClasses, "for a Green's H-relation", true, [IsEquivalenceRelation and IsGreensHRelation], 0,
x->GreensHClasses(Source(x)));

InstallMethod(EquivalenceClasses, "for a Green's D-relation", true, [IsEquivalenceRelation and IsGreensDRelation], 0,
x->GreensDClasses(Source(x)));

InstallMethod(EquivalenceClasses, "for a Green's J-relation", true, [IsEquivalenceRelation and IsGreensJRelation], 0,
x->GreensJClasses(Source(x)));

#################
#################
##
#M  RClassOfHClass(<hclass>)
#M  LClassOfHClass(<hclass>)
#M  DClassOfHClass(<hclass>)
#M  DClassOfLClass(<lclass>)
#M  DClassOfRClass(<rclass>)
##
##  returns the XClass containing <hclass>, <lclass>, or <rclass>

InstallMethod(RClassOfHClass, "for a Green's H-class", [IsGreensHClass],
function(H)
  return GreensRClassOfElement(Parent(H), Representative(H));
end);

InstallMethod(LClassOfHClass, "for a Green's H-class", [IsGreensHClass],
function(H)
  return GreensLClassOfElement(Parent(H), Representative(H));
end);

InstallMethod(DClassOfHClass, "for a Green's H-class", [IsGreensHClass],
function(H)
  return GreensDClassOfElement(Parent(H), Representative(H));
end);

InstallMethod(DClassOfLClass, "for a Green's L-class", [IsGreensLClass],
function(L)
  return GreensDClassOfElement(Parent(L), Representative(L));
end);

InstallMethod(DClassOfRClass, "for a Green's R-class", [IsGreensRClass],
function(R)
  return GreensDClassOfElement(Parent(R), Representative(R));
end);

#################
#################
##
#M  GreensRClasses(<semigroup>)
#M  GreensLClasses(<semigroup>)
#M  GreensJClasses(<semigroup>)
#M  GreensDClasses(<semigroup>)
#M  GreensHClasses(<semigroup>)
##
##  find all the classes of a particular type

InstallMethod(GreensRClasses, "for a semigroup", true, [IsSemigroup], 0,
function( semi )
local rrel, sc, i, classes, rc;

  rrel:=GreensRRelation(semi);

   if not HasRightCayleyGraphSemigroup(semi) then
     FroidurePinExtendedAlg(semi);
   fi;

   sc:=STRONGLY_CONNECTED_COMPONENTS_DIGRAPH(RightCayleyGraphSemigroup(semi));

   #for faster calculation of Green's D-, J- and H-rels
   SetInternalRepGreensRelation(rrel, sc); classes:=[];

   for i in [1..Length(sc)] do
     rc:=GreensRClassOfElement(semi, AsSSortedList(semi)[sc[i][1]]);
     Add(classes, rc);
     SetAsSSortedList(classes[i], AsSSortedList(semi){sc[i]});
     SetSize(classes[i], Size(sc[i]));
   od;

   SetGreensRClasses(semi,classes);

   return classes;

end);

InstallOtherMethod(GreensRClasses, "for a Green's D-class", true, [IsGreensDClass], 0,
x-> GreensRClasses(CanonicalGreensClass(x)));

InstallOtherMethod(GreensLClasses, "for a semigroup", true, [IsSemigroup], 0,
   function( semi )
   local lrel, sc, i, classes, lc;

   lrel:=GreensLRelation(semi);

   if not HasLeftCayleyGraphSemigroup(semi) then
     FroidurePinExtendedAlg(semi);
   fi;

   sc:=STRONGLY_CONNECTED_COMPONENTS_DIGRAPH(LeftCayleyGraphSemigroup(semi));

   #for faster calculation of Green's D-,J- and H-rels
   SetInternalRepGreensRelation(lrel, sc); classes:=[];

   for i in [1..Length(sc)] do
     lc:=GreensLClassOfElement(semi,AsSSortedList(semi)[sc[i][1]]);
     Add(classes, lc);
     SetAsSSortedList(lc, AsSSortedList(semi){sc[i]});
     SetSize(lc, Size(sc[i]));
   od;

   SetGreensLClasses(semi,classes);

   return classes;

end);

InstallOtherMethod(GreensLClasses, "for a Green's D-class", true, [IsGreensDClass], 0,
x-> GreensLClasses(CanonicalGreensClass(x)));

InstallOtherMethod(GreensJClasses, "for a semigroup",
[IsSemigroup and IsFinite], GreensDClasses);

InstallMethod(GreensDClasses, "for a semigroup", true, [IsSemigroup], 0,
function(semi)
  local lrel, rrel, INT_L, INT_R, elts, INT_Rclasses, INT_Lclasses,
  INT_Dclasses, index, pos, INT_rc, INT_hc, INT_lc, new, newINT, Dclasses,
  Lclasses, Rclasses, Hclasses, LHclasses, RHclasses, i, j, positions, R, L;

  ## compute the join of the R- and L-relations

  L:=GreensLClasses(semi); R:=GreensRClasses(semi);
  lrel:=GreensLRelation(semi); rrel:=GreensRRelation(semi);
  INT_L:=InternalRepGreensRelation(lrel);
  INT_R:=InternalRepGreensRelation(rrel);
  elts:=AsSSortedList(semi);

  #these are to collect the R and L-classes that comprise the D-class
  INT_Rclasses:=[]; INT_Lclasses:=[]; INT_Dclasses:=[];
  Dclasses:=[]; Lclasses:=[]; Rclasses:=[]; Hclasses:=[];
  RHclasses:=List(INT_R, x-> []); LHclasses:=List(INT_L, x->[]); positions:=[];

  index:=0;

  for i in [1..Length(INT_L)] do
    INT_lc:=INT_L[i];
    pos:=PositionProperty(INT_Dclasses, x->IsSubset(x, INT_lc));
    #JDM isn't it enough that INT_lc contains a single element in
    #JDM INT_Dclasses[something].
    if pos=fail then
      index:=index+1; Add(Rclasses, []);
      Add(Hclasses, []); Add(positions, []);
      Add(INT_Rclasses, []);

      for j in [1..Length(INT_R)] do
        INT_rc:=INT_R[j];
        INT_hc:=Intersection(INT_rc, INT_lc);
        if INT_hc<>[] then
          new:=GreensHClassOfElement(semi, elts[INT_hc[1]]);
          SetAsSSortedList(new, elts{INT_hc});
          SetSize(new, Length(INT_hc));
          Add(Hclasses[index], new);
          Add(RHclasses[j], new); Add(LHclasses[i], new);

          Add(INT_Rclasses[index], INT_rc);

          new:=R[j];
          Add(Rclasses[index], new);
          Add(positions[index], j);

        fi;
      od;

      newINT:=Concatenation(INT_Rclasses[index]);
      Add(INT_Dclasses, newINT);

      new:=GreensDClassOfElement(semi, elts[newINT[1]]);
      SetAsSSortedList(new, elts{newINT});
      SetSize(new, Length(newINT));
      SetGreensRClasses(new, Rclasses[index]);
      Add(Dclasses, new);

      Add(INT_Lclasses, [INT_lc]);

      SetDClassOfLClass(L[i], Dclasses[index]);
      Add(Lclasses, [L[i]]);
    else
      Add(INT_Lclasses[pos], INT_lc);

      SetDClassOfLClass(L[i], Dclasses[pos]);
      Add(Lclasses[pos], L[i]);

      for j in [1..Length(INT_Rclasses[pos])] do
        INT_rc:=INT_Rclasses[pos][j];
        INT_hc:=Intersection(INT_rc, INT_lc);

        new:=GreensHClassOfElement(semi, elts[INT_hc[1]]);
        SetAsSSortedList(new, elts{INT_hc});
        SetSize(new, Length(INT_hc));
        Add(Hclasses[pos], new);
        SetLClassOfHClass(new, GreensLClasses(semi)[i]);
        Add(LHclasses[i], new);
        SetRClassOfHClass(new, GreensRClasses(semi)[positions[pos][j]]);
        Add(RHclasses[positions[pos][j]], new);
      od;
    fi;
  od;

  SetGreensDClasses(semi, Dclasses);
  SetGreensHClasses(semi, Concatenation(Hclasses));

  for i in [1..index] do
    for j in [1..Length(Rclasses[i])] do
      SetDClassOfRClass(Rclasses[i][j], Dclasses[i]);
    od;
    for j in [1..Length(Hclasses[i])] do
      SetDClassOfHClass(Hclasses[i][j], Dclasses[i]);
    od;
    SetGreensLClasses(Dclasses[i], Lclasses[i]);
    SetGreensHClasses(Dclasses[i], Hclasses[i]);
  od;

  for i in [1..Length(INT_R)] do
    SetGreensHClasses(GreensRClasses(semi)[i],  RHclasses[i]);
  od;
  for i in [1..Length(INT_L)] do
    SetGreensHClasses(GreensLClasses(semi)[i],  LHclasses[i]);
  od;

   return Dclasses;
end);

InstallMethod(GreensHClasses, "for a semigroup", true, [IsSemigroup], 0,
function(semi)
  GreensDClasses(semi);
  return GreensHClasses(semi);
end);

InstallMethod(GreensHClasses, "for a Green's D-class", [IsGreensDClass],
x -> Filtered(GreensHClasses(ParentAttr(x)), y -> Representative(y) in x));

InstallMethod(GreensHClasses, "for a Green's R-class", [IsGreensRClass],
x -> Filtered(GreensHClasses(ParentAttr(x)), y -> Representative(y) in x));

InstallMethod(GreensHClasses, "for a Green's L-class", [IsGreensLClass],
x -> Filtered(GreensHClasses(ParentAttr(x)), y -> Representative(y) in x));

#############################################################################
##
#O  IsRegularDClass(<greens class>)
##
##  returns true if the class contains an idempotent
##

InstallMethod(IsRegularDClass, "for a Green's D class", true,
        [IsGreensDClass],0,
        x-> ForAny(GreensRClassOfElement(ParentAttr(x), Representative(x)),
                    IsIdempotent));

InstallMethod(IsGreensLessThanOrEqual, "for two Green's classes",
[IsGreensClass, IsGreensClass],
function(gcL,gcR)
  local a,b;

  a := Representative(gcL);
  b := Representative(gcR);

  if IsGreensRClass(gcL) and IsGreensRClass(gcR) then
    return a in RightMagmaIdealByGenerators(ParentAttr(gcR),[b]);
  elif IsGreensLClass(gcL) and IsGreensLClass(gcR) then
    return a in LeftMagmaIdealByGenerators(ParentAttr(gcR),[b]);
  elif (IsGreensJClass(gcL) and IsGreensJClass(gcR)) or
    (IsGreensDClass(gcL) and IsGreensDClass(gcR) and
      IsFinite(ParentAttr(gcL))) then
    return a in MagmaIdealByGenerators(ParentAttr(gcR),[b]);
  fi;

  ErrorNoReturn("Green's classes are not of the same type or not L-, R-, or J-classes");
end);

#############################################################################
##
#M  IsGroupHClass( <H> )
##
##  returns true if the Greens H-class <H> is a group, which in turn is
##  true if and only if <H>^2 intersects <H>.
##
InstallMethod(IsGroupHClass, "for Green's H-class", true,
    [IsGreensHClass], 0, h->ForAny(h, IsIdempotent));

############################################################################
##
#M  GroupHClassOfGreensDClass( <Dclass> )
##
##  for a D class <Dclass> of a semigroup,
##  returns a group H class of the D class, or `fail' if there is no
##  group H class.
##
## (if d contains an idempotent, then it is regular, and so contains
##  at least one idempotent in *each* R-class.)

InstallMethod(GroupHClassOfGreensDClass, "for a Green's H-class", true,
    [IsGreensDClass], 0,

    function(d)
        local idm, rcs;

        rcs:=GreensRClasses(d);

        idm := First(rcs[1], IsIdempotent);
        if idm=fail then
          return fail;
        else
          return GreensHClassOfElement(ParentAttr(d),idm);
        fi;
    end);

#############################################################################
##
#A  EggBoxOfDClass( <D> )
##
## this returns a matrix with the j-th entry in the i-th row
## being the intersection of the i-th R-class and the j-th L-class
##Ê(by the construction of GreensHClasses)
##

InstallMethod(EggBoxOfDClass, "for a Green's D class", true,
        [IsGreensDClass],0,
    function(d)

    return List(GreensRClasses(d), GreensHClasses);
end);

#############################################################################
##
#F  DisplayEggBoxOfDClass( <D> )
##
##  A "picture" of the D class <D>, as an array of 1s and 0s.
##  A 1 represents a group H class.
##

InstallGlobalFunction(DisplayEggBoxOfDClass,
    function(d)
        if not IsGreensDClass(d) then
            Error("requires IsGreensDClass");
        fi;

        PrintArray(
            List(EggBoxOfDClass(d), r->List(r,
                function(h)
                   if IsGroupHClass(h) then
                        return 1;
                   else
                        return 0;
                   fi;
                end))
       );
    end);

#############################################################################
##
#M  DisplayEggBoxesOfSemigroup( <S> )
##

InstallMethod(DisplayEggBoxesOfSemigroup, "for finite semigroups",
    [IsTransformationSemigroup],
function(X)
local dclasses, layer, class, len, i, D;

   dclasses:=GreensDClasses(X);
   layer:=List([1..DegreeOfTransformationSemigroup(X)], x-> []);

   for class in dclasses do
     Add(layer[RankOfTransformation(Representative(class))], [class,
        Size(GreensHClasses(class)[1]), IsRegularDClass(class)]);
   od;

   len:= Length(layer);
   for i in [len, len-1..1] do
        if layer[i] <> [] then
            for D in layer[i] do
                Print("Rank ", i, ", H-class size ", D[2]);
                if D[3] then
                  Print(", regular \n");
                else
                  Print(", non-regular \n");
                fi;

                DisplayEggBoxOfDClass(D[1]);

            od;
        fi;
   od;
end );

####################
####################
##
#M FroidurePinSimpleAlg(<semigroup>);
##
## for details of the workings of this algorithm see:
##
## V. Froidure, and J.-E. Pin, Algorithms for computing finite semigroups.
## Foundations of computational mathematics (Rio de Janeiro, 1997), 112-126,
## Springer, Berlin,  1997.
##
## this function returns [elements of <semigroup>, set of defining relations
## for <semigroup>, the fp semigroup isomorphic to <semigroup>]. This is only
## included because it may give a quicker way of finding a presentation for
## <semigroup> than the extended algorithm.

InstallMethod(FroidurePinSimpleAlg, "for a finite monoid",
[IsMonoid and HasIsFinite and IsFinite and HasGeneratorsOfMonoid],
function(semi)
  local  gens, concreteelts, free, freegens, fpelts, rules, Last, upos, u, i,
   newelt, newword, j, new;

  gens:=GeneratorsOfMonoid(semi);
  concreteelts:=[One(semi)];

  free:=FreeMonoid(Size(gens));
  freegens:=GeneratorsOfMonoid(free);
  fpelts:=[One(free)];
  rules:=[];

  Last:=1;
  upos:=0;

  repeat
    upos:=upos+1;
    u:=concreteelts[upos];

    for i in [1..Length(gens)] do
      newelt:=u*gens[i];
      newword:=fpelts[upos]*freegens[i];

      j:=0;
      new:=true;

      repeat#hmmm.... JDM
        j:=j+1;
        if newelt=concreteelts[j] then
          Add(rules, [newword, fpelts[j]]);
          new:=false;
        fi;
      until j=Last or not new;

      if new then
        Add(concreteelts, newelt);
        Add(fpelts, newword);
        Last:=Last+1;
      fi;
    od;

  until upos=Last;

  return [concreteelts, rules, free/rules];

end);

####################
####################
##
#M  FroidurePinExtendedAlg(<semigroup>);
##
##  for details of the workings of this algorithm see:
##
##  V. Froidure, and J.-E. Pin, Algorithms for computing finite semigroups.
##  Foundations of computational mathematics (Rio de Janeiro, 1997), 112-126,
##  Springer, Berlin,  1997.
##
##  this function returns nothing, but determines the elements, size,
##  a presentation, and the left and right Cayley graphs of <semigroup>.
##
##  JDM shouldn't produce fp representation if input is fp semigroup!
##

InstallMethod(FroidurePinExtendedAlg, "for a finite semigroup",
[IsSemigroup],
function(m)
  local gens, k, free, freegens, actualelts, fpelts, rules, i, u, v, Last,
        currentlength, b, s, r, newelt, p, new, length, newword, first,
        final, prefix, suffix, postmult, reducedflags, premult, fpsemi,
        old, sortedelts, pos, semi, perm, free2, one;

  if not IsFinite(m) then
    return fail;
  fi;

  if not IsMonoid(m) then
      semi := MonoidByAdjoiningIdentity(m);
  else
      semi:=m;
  fi;

  #gens:=Set(GeneratorsOfMonoid(semi));
  one:=One(semi);
  gens:=Set(Filtered(GeneratorsOfMonoid(semi), x -> x <> one));
  k:=Length(gens);
  free:=FreeMonoid(k);
  freegens:=GeneratorsOfMonoid(free);
  actualelts:=Concatenation([one], gens);
  fpelts:=Concatenation([One(free)], freegens);
  sortedelts:=List(Concatenation([one], gens));

  #output

  Sort(sortedelts);
  rules:=[];
  pos:=List([1..k+1], x-> Position(actualelts, sortedelts[x]));

  # table containing all data
  # for a word <u>

  # position of first letter in <gens>
  first:=Concatenation([fail], [1..k]);
  # position of last letter in <gens>
  final:=Concatenation([fail], [1..k]);
  # position of prefix of length |u|-1 in <fpelts>
  prefix:=Concatenation([fail], List([1..k], x->1));
  # position of suffix of length |u|-1 in <fpelts>
  suffix:=Concatenation([fail], List([1..k], x->1));
  # position of u*freegens[i] in <fpelts>
  postmult:=Concatenation([[2..k+1]], List([1..k], x-> []));
  # true if u*freegens[i] is the same word as fpelts[i]
  reducedflags:=Concatenation([List([1..k], x->  true)], List([1..k], x-> []));
  # position of freegens[i]*u in <fpelts>
  premult:=Concatenation([[2..k+1]],  List([1..k], x-> []));
  # length of <u>
  length:=Concatenation([0], List([1..k], x->1));

  # initialize loop

  u:=2;               # position of the first generator
  v:=u;               # place holder
  Last:=k+1;          # the current position of the last element in <fpelts>
  currentlength:=1;   # current length of words under consideration

  # loop

  repeat

    while u<=Last and length[u]=currentlength do

      b:=first[u];
      s:=suffix[u];

      for i in [1..k] do #loop over generators

        newword:=fpelts[u]*freegens[i]; # newword=u*a_i

        if not reducedflags[s][i] then  # if s*a_i is not reduced
          r:=postmult[s][i];            # r=s*a_i
          if fpelts[r]=One(free) then   # r=1
            postmult[u][i]:=b+1;
            reducedflags[u][i]:=true;   # u*a_i=b and it is reduced
          else
            postmult[u][i]:=postmult[premult[prefix[r]][b]][final[r]];
            #\rho(u*a_i)=\rho(\rho(b*r)*l(r))
            reducedflags[u][i]:=(newword=fpelts[postmult[u][i]]);
            # if \rho(u*a_i)=u*a_i then true
          fi;
        else

          newelt:=actualelts[u]*gens[i];      # newelt=nu(u*a_i)
          old:=PositionSorted(sortedelts, newelt);
          if old<=Last and newelt=sortedelts[old] then
            old:=pos[old];
            Add(rules, [newword, fpelts[old]]);
            postmult[u][i]:=old;
            reducedflags[u][i]:=false;  # u*a_i represents the same elt as
                                        # fpelts[j] and is (hence) not reduced
          else
            Add(fpelts, newword); Add(first, b); Add(final, i);
            # add all its info to the table
            Add(prefix,u); Add(suffix, postmult[suffix[u]][i]);
            # u=b*suffix(u)*a_i
            Add(postmult, []); Add(reducedflags, []); Add(premult, []);
            Add(length, length[u]+1); Add(actualelts, newelt);

            Last:=Last+1;
            postmult[u][i]:=Last; reducedflags[u][i]:=true;
            # the word u*a_i is a new elt
            # and is hence reduced

            AddSet(sortedelts, newelt);

            CopyListEntries( pos, old, 1, pos, old+1, 1, Last-old );
            pos[old] := Last;

          fi;
       fi;
     od;

      u:=u+1;

    od;
    u:=v;  # go back to the first elt with length=currentlength

    while u<=Last and length[u]=currentlength do
      p:=prefix[u];
      for i in [1..k] do
        premult[u][i]:=postmult[premult[p][i]][final[u]];
        # \rho(a_i*u)=\rho(\rho(a_i*p)*final(u))
      od;
      u:=u+1;
    od;

    v:=u;

    currentlength:=currentlength+1;

  until u=Last+1;

  if IsMonoid(m) then

    fpsemi:=free/rules;
    fpelts:=List(fpelts, function(x)
      local new;
      new:=MappedWord(x, FreeGeneratorsOfFpMonoid(fpsemi),
       GeneratorsOfMonoid(fpsemi));

      SetIsFpMonoidReducedElt(new, true);
      return new;
    end);

    SetAsSSortedList(fpsemi, fpelts);
    SetSize(fpsemi, Last);
    SetLeftCayleyGraphSemigroup(fpsemi, premult);
    SetRightCayleyGraphSemigroup(fpsemi, postmult);
    SetAssociatedConcreteSemigroup(fpsemi, semi);

    #JDM if KnuthBendixRewritingSystem was an attribute and not an operation
    #JDM it would be possible to set that it is confluent at this point

    perm:=PermListList(pos, [1..Last]);
    premult:=Permuted(OnTuplesTuples(premult, perm), perm);
    postmult:=Permuted(OnTuplesTuples(postmult, perm), perm);

    SetAsSSortedList(m, sortedelts);
    SetSize(m, Last);
    SetLeftCayleyGraphSemigroup(m, premult);
    SetRightCayleyGraphSemigroup(m, postmult);
    SetAssociatedFpSemigroup(m, fpsemi);

    u:=SemigroupHomomorphismByImagesNC(m, fpsemi,
         List(pos, x-> fpelts[x]));
    SetInverseGeneralMapping(u, SemigroupHomomorphismByImagesNC(fpsemi, m,
    actualelts));
    SetIsTotal(u, true); SetIsInjective(u, true);
    SetIsSurjective(u, true); SetIsSingleValued(u, true);
    SetIsomorphismFpMonoid(m, u);

  else

    #get rid of the identity! JDM better to do this online?

    free2:=FreeSemigroup(k);

    rules:=List(rules, x-> [MappedWord(x[1], GeneratorsOfMonoid(free),
     GeneratorsOfSemigroup(free2)), MappedWord(x[2], GeneratorsOfMonoid(free),
     GeneratorsOfSemigroup(free2))]);

    fpsemi:=free2/rules;

    fpelts:=List(fpelts{[2..Last]}, function(x)
      local new;
      new:=MappedWord(x, GeneratorsOfMonoid(free),
       GeneratorsOfSemigroup(fpsemi));
      SetIsFpSemigpReducedElt(new, true);
      return new;
    end);
    SetAsSSortedList(fpsemi, fpelts);
    SetSize(fpsemi, Last-1);

    premult:=premult{[2..Length(premult)]}-1;
    postmult:=postmult{[2..Length(postmult)]}-1;

    SetLeftCayleyGraphSemigroup(fpsemi, premult);
    SetRightCayleyGraphSemigroup(fpsemi, postmult);
    SetAssociatedConcreteSemigroup(fpsemi, m);

    sortedelts:=sortedelts{[2..Last]};
    actualelts:=actualelts{[2..Length(actualelts)]};
    pos:=pos{[2..Last]}-1;
    perm:=PermListList(pos, [1..Last-1]);
    sortedelts := List(sortedelts,
    UnderlyingSemigroupElementOfMonoidByAdjoiningIdentityElt);
    actualelts:=List(actualelts,
     UnderlyingSemigroupElementOfMonoidByAdjoiningIdentityElt);

    premult:=Permuted(OnTuplesTuples(premult, perm), perm);
    postmult:=Permuted(OnTuplesTuples(postmult, perm), perm);

    SetAsSSortedList(m, sortedelts);
    SetSize(m, Last-1);
    SetLeftCayleyGraphSemigroup(m, premult);
    SetRightCayleyGraphSemigroup(m, postmult);
    SetAssociatedFpSemigroup(m, fpsemi);

    u:=SemigroupHomomorphismByImagesNC(m, fpsemi,
        List(pos, x-> fpelts[x]));

    SetInverseGeneralMapping(u, SemigroupHomomorphismByImagesNC(fpsemi, m,
    actualelts));

    SetIsTotal(u, true); SetIsInjective(u, true);
    SetIsSurjective(u, true); SetIsSingleValued(u, true);
    SetIsomorphismFpSemigroup(m, u);
  fi;

end);

#############################################################################
##
##        Free Semigroups
##
#############################################################################

#############################################################################
##
#M  GreensRRelation(<semigroup>)
#M  GreensLRelation(<semigroup>)
#M  GreensJRelation(<semigroup>)
#M  GreensDRelation(<semigroup>)
#M  GreensHRelation(<semigroup>)
##
##  Green's relations for free semigroups
##
##
InstallMethod(GreensRRelation, "for free semigroups", true,
        [IsSemigroup and IsFreeSemigroup], 0,
    function(s)
        Info(InfoWarning,1,
            "Green's relations for infinite semigroups is not supported");
        return fail;
    end);

InstallMethod(GreensLRelation, "for free semigroups", true,
        [IsSemigroup and IsFreeSemigroup], 0,
    function(s)
        Info(InfoWarning,1,
            "Green's relations for infinite semigroups is not supported");
        return fail;
    end);

InstallMethod(GreensJRelation, "for free semigroups", true,
        [IsSemigroup and IsFreeSemigroup], 0,
    function(s)
        Info(InfoWarning,1,
            "Green's relations for infinite semigroups is not supported");
        return fail;
    end);

InstallMethod(GreensDRelation, "for free semigroups", true,
        [IsSemigroup and IsFreeSemigroup], 0,
    function(s)
        Info(InfoWarning,1,
            "Green's relations for infinite semigroups is not supported");
        return fail;
    end);

InstallMethod(GreensHRelation, "for free semigroups", true,
        [IsSemigroup and IsFreeSemigroup], 0,
    function(s)
        Info(InfoWarning,1,
            "Green's relations for infinite semigroups is not supported");
        return fail;
    end);


#############################################################################
##
#O  SemigroupHomomorphismByImagesNC( <mapp> )
##
##  returns a `SemigroupHomomorphism' represented by
## `IsSemigroupHomomorphismByImagesRep'.

InstallMethod(SemigroupHomomorphismByImagesNC, "for a semigroup, semigroup, list", true,
              [IsSemigroup, IsSemigroup, IsList], 0,
function(S, T, imgslist)
local hom;

 if Size(S)<>Length(imgslist) then
    Error("<S> and <T> must have the same size");
  fi;

  #SetAsSSortedList(imgslist, imgslist);
  hom:=rec(imgslist:=imgslist);

Objectify(NewType( GeneralMappingsFamily
    ( ElementsFamily( FamilyObj( S ) ),
      ElementsFamily( FamilyObj( T ) ) ), IsSemigroupHomomorphism
      and IsSemigroupHomomorphismByImagesRep), hom);

  SetSource(hom, S);
  SetRange(hom, T);

  return hom;
end);

#

########
########

InstallMethod(ImagesRepresentative, "for semigroup homomorphism by images",
              FamSourceEqFamElm,
              [IsSemigroupHomomorphism and IsSemigroupHomomorphismByImagesRep, IsMultiplicativeElement],
function(hom, elt)
  return hom!.imgslist[Position(AsSSortedList(Source(hom)), elt)];
end);

########
########

InstallMethod(PreImagesRepresentative,  "for semigroup homomorphism by images",
              FamRangeEqFamElm,
              [IsSemigroupHomomorphism and IsSemigroupHomomorphismByImagesRep, IsMultiplicativeElement],
function(hom, x)
  local preimgs, imgs;

  if HasInverseGeneralMapping(hom) then
    return ImageElm(InverseGeneralMapping(hom), x);
  fi;

  imgs:=hom!.imgslist;

  preimgs:=List([1..Length(imgs)], function(y)
  if imgs[y]=x then
    return AsSSortedList(Source(hom))[y];
  else
    return fail;
  fi;
  end);

  return Filtered(preimgs, x-> not x=fail);
end);

########
########

InstallMethod( ViewObj, "for semigroup homomorphism by images",
              [IsSemigroupHomomorphism and IsSemigroupHomomorphismByImagesRep],
function( obj )
  Print( "SemigroupHomomorphismByImages ( ", Source(obj), "->", Range(obj), ")" );
end );

########
########

InstallMethod( PrintObj, "for semigroup homomorphism by images",
              [IsSemigroupHomomorphism and IsSemigroupHomomorphismByImagesRep],
function( obj )
  Print( "SemigroupHomomorphismByImages ( ", Source(obj), "->", Range(obj), ")" );
end );

########
########

InstallMethod(ImagesElm, "for semigroup homomorphism by images",
              FamSourceEqFamElm,
              [IsSemigroupHomomorphism and IsSemigroupHomomorphismByImagesRep, IsMultiplicativeElement],
function( hom, x)
  return [ImagesRepresentative(hom, x)];
end);

########
########

InstallMethod(CompositionMapping2, "for semigroup homomorphism by images",
              #IsIdenticalObj,
              [IsSemigroupHomomorphism and IsSemigroupHomomorphismByImagesRep, IsSemigroupHomomorphism and IsSemigroupHomomorphismByImagesRep],
              0,
function(hom1, hom2)
  local imgslist;

  if not IsSubset(Source(hom2), Range(hom1)) then
    Error("source of <hom2> must contain range of <hom>");
  fi;

  imgslist:=List(hom1!.imgslist, x-> ImageElm(hom2, x));

  return SemigroupHomomorphismByImagesNC(Source(hom1), Range(hom2), imgslist);
end);

########
########

InstallMethod(InverseGeneralMapping, "for semigroup homomorphism by images",
              [IsSemigroupHomomorphism and IsSemigroupHomomorphismByImagesRep and IsInjective and IsSurjective],
              0,
function(iso)

  return SemigroupHomomorphismByImagesNC(Range(iso), Source(iso),
  List(AsSSortedList(Range(iso)), x-> AsSSortedList(Source(iso))[Position(iso!.imgslist, x)]));

end);

########
########

InstallMethod(\=, "for semigroup homomorphism by images", IsIdenticalObj,
              [IsSemigroupHomomorphism and IsSemigroupHomomorphismByImagesRep, IsSemigroupHomomorphism and IsSemigroupHomomorphismByImagesRep],
              0,
function(hom1, hom2)

  return ForAll(GeneratorsOfSemigroup(Source(hom1)),
    x -> ImageElm(hom1,x) = ImageElm(hom2,x));

end);

#HACKS

#JDM This is a terrible hack: the way that fp semigroups are implemented in GAP
# means that every time you try to compute anything it first tries to find a
# reduced confluent rewriting system for the presentation. Despite the fact that
# the fp semigroups generated by the FP algorithm already know all their
# elements and have a reduced confluent presentation.

InstallMethod(\<, "for fp semigp elts produced by the Froidure-Pin algorithm", IsIdenticalObj, [IsFpSemigpReducedElt, IsFpSemigpReducedElt],
function(x,y)
  if not x=y then
    return IsShortLexLessThanOrEqual(UnderlyingElement(x), UnderlyingElement(y));
  else
    return false;
  fi;
end);

InstallMethod(\=, "for fp semigp elts produced by the Froidure-Pin algorithm", IsIdenticalObj, [IsFpSemigpReducedElt, IsFpSemigpReducedElt],
function(x,y)
  return UnderlyingElement(x)=UnderlyingElement(y);
end);

InstallMethod(\<, "for fp monoid elts produced by the Froidure-Pin algorithm", IsIdenticalObj, [IsFpMonoidReducedElt, IsFpMonoidReducedElt],
function(x,y)
  if not x=y then
    return IsShortLexLessThanOrEqual(UnderlyingElement(x), UnderlyingElement(y));
  else
    return false;
  fi;
end);

InstallMethod(\=, "for fp monoid elts produced by the Froidure-Pin algorithm", IsIdenticalObj, [IsFpMonoidReducedElt, IsFpMonoidReducedElt],
function(x,y)
  return UnderlyingElement(x)=UnderlyingElement(y);
end);

