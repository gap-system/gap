#############################################################################
##
##  grpclass.gi                      CRISP                   Burkhard Höfling
##
##  @(#)$Id: grpclass.gi,v 1.6 2011/05/15 19:17:55 gap Exp $
##
##  Copyright (C) 2000, 2006 Burkhard Höfling
##
Revision.grpclass_gi :=
    "@(#)$Id: grpclass.gi,v 1.6 2011/05/15 19:17:55 gap Exp $";


#############################################################################
##
#M  GroupClass (<rec>)
##
InstallMethod (GroupClass, "for record", true, [IsRecord], 0, 
   function (record)
      local class, r;
      r := ShallowCopy (record);
      class := NewClass ("ClassFamily", 
         IsClassByPropertyRep and IsGroupClass, 
         rec(definingAttributes := [["in", MemberFunction]]));
        if IsBound (r.char) then
           SetCharacteristic (class, r.char);
           Unbind (r.char);
        fi;
      InstallDefiningAttributes (class, r);
      return class;
   end);


#############################################################################
##
#M  GroupClass (<func>)
##
InstallMethod (GroupClass, "for property function", true, [IsFunction], 0, 
   function (prop)
      return GroupClass (rec (\in := prop));
   end);


#############################################################################
##
#M  \in
##
##  We install a method for "in" because we need not store the result
##  (via IsMember) if the object is not a group
##
InstallMethod (\in, "for group class", true, 
   [IsObject, IsGroupClass], 0,
   function (x, C)
      if IsGroup (x) then
         if IsMember (x, C) then
            SetIsEmpty (C, false);
            return true;
         fi;
      fi;
      return false;
   end);


#############################################################################
##
#M  IsMemberOp (<obj>, <class>)
##
InstallMethod (IsMemberOp, "handled by nice monomorphism", true,
   [IsGroup and IsHandledByNiceMonomorphism, IsGroupClass], 0,
   function( grp, class)
      return IsMemberOp (NiceObject (grp), class);
   end);
   
   
#############################################################################
##
#M  ViewObj (<class>)
##
InstallMethod (ViewObj, "for IsGroupClass and IsClassByPropertyRep", true, 
   [IsGroupClass and IsClassByPropertyRep], 0,
   function (C) 
      Print ("GroupClass (");
      ViewDefiningAttributes (C);
      Print (")");
   end);


#############################################################################
##
#M  PrintObj (<class>)
##
InstallMethod (PrintObj, "for IsGroupClass and IsClassByPropertyRep", true, 
   [IsGroupClass and IsClassByPropertyRep], 0,
   function (C) 
      Print ("GroupClass (");
      PrintDefiningAttributes (C);
      Print (")");
   end);


#############################################################################
##
#M  IsGroupClass (<cl>)
##
InstallImmediateMethod (IsGroupClass, IsClassByComplementRep, 0,
   function (cl)
      if HasIsGroupClass (cl!.complement) then
         return IsGroupClass (cl!.complement);
      else
         TryNextMethod();
      fi;
   end);
   
   
#############################################################################
##
#M  IsGroupClass (<class>)
##
InstallImmediateMethod (IsGroupClass, IsClassByIntersectionRep, 0,
   function (cl)
      if ForAll (cl!.intersected, 
            C -> HasIsGroupClass(C) and IsGroupClass(C)) then
         return true;
      else
         TryNextMethod();
      fi;
   end);


#############################################################################
##
#M  ContainsTrivialGroup (<group class>)
##
InstallImmediateMethod (ContainsTrivialGroup, 
   IsClassByIntersectionRep and IsGroupClass, 0,
   function (cl)
      local C;
      for C in cl!.intersected do
         if HasContainsTrivialGroup(C) then
            if not ContainsTrivialGroup(C) then
               return false;
            fi;
         else
            TryNextMethod();
         fi;
      od;
      return true;
   end);



#############################################################################
##
#M  ContainsTrivialGroup (<group class>)
##
InstallImmediateMethod (ContainsTrivialGroup, 
   IsClassByUnionRep and IsGroupClass, 0,
   function (cl)
      if ForAny (cl!.united, 
            C -> HasContainsTrivialGroup(C) 
               and ContainsTrivialGroup(C)) then
         return true;
      else
         TryNextMethod();
      fi;
   end);

    
#############################################################################
##
#M  ContainsTrivialGroup (<group class>)
##
InstallImmediateMethod (ContainsTrivialGroup, 
   IsGroupClass and HasIsEmpty and IsNormalSubgroupClosed, 0,
   function (C)
      if not IsEmpty (C) then
         return true;
      else
         TryNextMethod();
      fi;
   end);
      

#############################################################################
##
#M  ContainsTrivialGroup (<group class>)
##
InstallImmediateMethod (ContainsTrivialGroup, 
   IsGroupClass and HasIsEmpty and IsQuotientClosed, 0,
   function (C)
      if not IsEmpty (C) then
         return true;
      else
         TryNextMethod();
      fi;
   end);
      

#############################################################################
##
#M  IsEmpty (<group class>)
##
InstallImmediateMethod (IsEmpty, 
   IsGroupClass and HasContainsTrivialGroup, 0,
   function (C)
      if ContainsTrivialGroup (C) then
         return false;
      else
         TryNextMethod();
      fi;
   end);
      

#############################################################################
##
#M  IsSubgroupClosed (<group class>)
##
InstallImmediateMethod (IsSubgroupClosed, 
   IsClassByIntersectionRep and IsGroupClass and IsNormalSubgroupClosed, 0,
   function (cl)
      if ForAll (cl!.intersected, 
            C -> HasIsSubgroupClosed(C) and IsSubgroupClosed(C)) then
         return true;
      else
         TryNextMethod();
      fi;
   end);


#############################################################################
##
#M  IsNormalSubgroupClosed (<group class>)
##
InstallImmediateMethod (IsNormalSubgroupClosed, 
   IsClassByIntersectionRep and IsGroupClass, 0,
   function (cl)
      if ForAll (cl!.intersected, 
            C -> HasIsNormalSubgroupClosed(C) and IsNormalSubgroupClosed(C)) then
         return true;
      else
         TryNextMethod();
      fi;
   end);


#############################################################################
##
#M  IsQuotientClosed (<group class>)
##
InstallImmediateMethod (IsQuotientClosed, 
   IsClassByIntersectionRep and IsGroupClass, 0,
   function (cl)
      if ForAll (cl!.intersected, 
            C -> HasIsQuotientClosed(C) and IsQuotientClosed(C)) then
         return true;
      else
         TryNextMethod();
      fi;
   end);


#############################################################################
##
#M  IsResiduallyClosed (<group class>)
##
InstallImmediateMethod (IsResiduallyClosed, 
   IsClassByIntersectionRep and IsGroupClass and IsDirectProductClosed, 0,
   function (cl)
      if ForAll (cl!.intersected, 
            C -> HasIsResiduallyClosed(C) and IsResiduallyClosed(C)) then
         return true;
      else
         TryNextMethod();
      fi;
   end);


#############################################################################
##
#M  IsNormalProductClosed (<group class>)
##
InstallImmediateMethod (IsNormalProductClosed, 
   IsClassByIntersectionRep and IsGroupClass and IsDirectProductClosed, 0,
   function (cl)
      if ForAll (cl!.intersected, 
            C -> HasIsNormalProductClosed(C) and IsNormalProductClosed(C)) then
         return true;
      else
         TryNextMethod();
      fi;
   end);


#############################################################################
##
#M  IsDirectProductClosed (<group class>)
##
InstallImmediateMethod (IsDirectProductClosed, 
   IsClassByIntersectionRep and IsGroupClass, 0,
   function (cl)
      if ForAll (cl!.intersected, 
            C -> HasIsDirectProductClosed(C) 
               and IsDirectProductClosed(C)) then
         return true;
      else
         TryNextMethod();
      fi;
   end);


#############################################################################
##
#M  IsSchunckClass (<group class>)
##
InstallImmediateMethod (IsSchunckClass, 
   IsClassByIntersectionRep and IsGroupClass 
      and IsSaturated and IsQuotientClosed and IsDirectProductClosed, 
   0,
   function (cl)
      if ForAll (cl!.intersected, 
            C -> HasIsSchunckClass(C) and IsSchunckClass(C)) then
         return true;
      else
         TryNextMethod();
      fi;
   end);


#############################################################################
##
#M  IsSaturated (<group class>)
##
InstallImmediateMethod (IsSaturated, 
   IsClassByIntersectionRep and IsGroupClass, 0,
   function (cl)
      if ForAll (cl!.intersected, 
            C -> HasIsSaturated(C) and IsSaturated(C)) then
         return true;
      else
         TryNextMethod();
      fi;
   end);


#############################################################################
##
#M  IsGroupClass (<class>)
##
InstallImmediateMethod (IsGroupClass, 
   IsClassByUnionRep, 0,
   function (cl)
      if ForAll (cl!.united, 
            C -> HasIsGroupClass(C) and IsGroupClass(C)) then
         return true;
      else
         TryNextMethod();
      fi;
   end);


#############################################################################
##
#M  ContainsTrivialGroup (<group class>)
##
InstallMethod (ContainsTrivialGroup, "for generic group class - test membership",
   ReturnTrue,
   [IsGroupClass], 
   0,
   cl -> TrivialGroup() in cl);


#############################################################################
##
#M  ContainsTrivialGroup (<group class>)
##
InstallImmediateMethod (ContainsTrivialGroup, 
   IsClassByUnionRep and IsGroupClass, 0,
   function (cl)
      if ForAny (cl!.united, 
            C -> HasContainsTrivialGroup(C) and ContainsTrivialGroup(C)) then
         return true;
      else
         TryNextMethod();
      fi;
   end);


#############################################################################
##
#M  IsSubgroupClosed (<group class>)
##
InstallImmediateMethod (IsSubgroupClosed, 
   IsClassByUnionRep and IsGroupClass and IsNormalSubgroupClosed, 0,
   function (cl)
      if ForAll (cl!.united, 
            C -> HasIsSubgroupClosed(C) and IsSubgroupClosed(C)) then
         return true;
      else
         TryNextMethod();
      fi;
   end);


#############################################################################
##
#M  IsNormalSubgroupClosed (<group class>)
##
InstallImmediateMethod (IsNormalSubgroupClosed, 
   IsClassByUnionRep and IsGroupClass, 0,
   function (cl)
      if ForAll (cl!.united, 
            C -> HasIsNormalSubgroupClosed(C) and IsNormalSubgroupClosed(C)) then
         return true;
      else
         TryNextMethod();
      fi;
   end);


#############################################################################
##
#M  IsQuotientClosed (<group class>)
##
InstallImmediateMethod (IsQuotientClosed, 
   IsClassByUnionRep and IsGroupClass, 0,
   function (cl)
      if ForAll (cl!.united, 
            C -> HasIsQuotientClosed(C) and IsQuotientClosed(C)) then
         return true;
      else
         TryNextMethod();
      fi;
   end);


#############################################################################
##
#M  IsSaturated (<group class>)
##
InstallImmediateMethod (IsSaturated, 
   IsClassByUnionRep and IsGroupClass, 0,
   function (cl)
      if ForAll (cl!.united, 
            C -> HasIsSaturated(C) and IsSaturated(C)) then
         return true;
      else
         TryNextMethod();
      fi;
   end);


#############################################################################
##
#F  DEFAULT_ISO_FUNC (<grp1>, <grp2>)
##
InstallGlobalFunction (DEFAULT_ISO_FUNC,
   function (G, H) 
      return IsomorphismGroups(G, H) <> fail;
   end);
   

#############################################################################
##
#R  IsGroupClassByListRep
##
DeclareRepresentation ("IsGroupClassByListRep", 
   IsClass and IsGroupClass, ["classId", "list", "isofunc"]);


#############################################################################
##
#M  GroupClass (<list>)
##
InstallOtherMethod (GroupClass, "for group defined by list", true, 
   [IsList], 0, 
   function (l) 
      return GroupClass (l, DEFAULT_ISO_FUNC);
   end);


#############################################################################
##
#M  GroupClass (<list>, <func>)
##
InstallOtherMethod (GroupClass, " for list and function", true, 
   [IsList, IsFunction], 0, 
   function (l, iso) 
      local class;
      class := NewClass ("group class fam", IsGroupClassByListRep,
         rec (list := l, 
            isofunc := iso));
      SetIsGroupClass (class, true);
      return class;
   end);


#############################################################################
##
#M  IsMemberOp <grp>, (<class>)
##
InstallMethod (IsMemberOp, " for group class by list", true, 
   [IsGroup, IsGroupClassByListRep], 0, 
   function (x, C)
      if IsGroup (x) then
         return ForAny (C!.list, y -> C!.isofunc (y, x));
      else
         return false;
      fi;
   end);


#############################################################################
##
#M  ViewObj (<class>)
##
InstallMethod (ViewObj, " for IsGroupClassByListRep", true, 
   [IsGroupClassByListRep], 0,
   function (C) 
      Print ("GroupClass (");
      View (C!.list);
      if C!.isofunc <> DEFAULT_ISO_FUNC then
         Print (", ");
         View (C!.isofunc);
      fi;
      Print (")");
   end);


#############################################################################
##
#M  PrintObj (<class>)
##
InstallMethod (PrintObj, " for IsGroupClassByListRep", true, 
   [IsGroupClassByListRep], 0,
   function (C) 
      Print ("GroupClass (");
      Print (C!.list);
      Print (", ");
      if C!.isofunc = DEFAULT_ISO_FUNC then
         Print ("<default isomorphism test>");
      else
         Print (C!.isofunc);
      fi;
      Print (")");
   end);


#############################################################################
##
#M  Intersection2 (<class1>, <class2>)
##
InstallMethod (Intersection2, "for two group classes by list", 
    true, [IsGroupClassByListRep, IsGroupClassByListRep], 0, 
   function (C, D)
      local iso;

      iso := C!.isofunc;
      if iso = DEFAULT_ISO_FUNC then
         iso := D!.isofunc;
      elif D!.isofunc <> iso and D!.isofunc <> DEFAULT_ISO_FUNC then
         Info (InfoWarning ,1,
            "Don't know which isomorphism function to choose");
      fi;
      
      return GroupClass (Filtered (C!.list, x -> x in D), iso);
   end);


#############################################################################
##
#M  Intersection2 (<class1>, <class2>)
##
InstallMethod (Intersection2, "for group class by list and group class", 
    true, [IsGroupClassByListRep, IsGroupClass], 0, 
   function (C, D)
      return GroupClass (Filtered (C!.list, x -> x in D), C!.isofunc);
   end);


#############################################################################
##
#M  Intersection2 (<class1>, <class2>)
##
InstallMethod (Intersection2, "for grp class and group class by list",
   true, [IsGroupClass, IsGroupClassByListRep], 0, 
   function (C, D)
      return GroupClass (Filtered (D!.list, x -> x in C), D!.isofunc);
   end);


#############################################################################
##
#M  Difference (<class1>, <class2>)
##
InstallMethod (Difference, "for group class by list and group class", true, 
   [IsGroupClassByListRep, IsGroupClass], 0, 
   function (C, D)
      return GroupClass (Filtered (C!.list, x -> not x in D), C!.isofunc);
   end);


#############################################################################
##
#M  IsSubgroupClosed (<group class>)
##
InstallMethod (IsSubgroupClosed, "for generic group class", 
   true, [IsGroupClass], 0, 
   function (C)
      Error ("Sorry, cannot decide if the group class <C> \
         is subgroup closed.");
   end);
   
   
#############################################################################
##
#M  IsNormalSubgroupClosed (<group class>)
##
InstallMethod (IsNormalSubgroupClosed, "for generic group class", 
   true, [IsGroupClass], 0, 
   function (C)
      Error ("Sorry, cannot decide if the group class <C> \
         is normal subgroup closed.");
   end);
   
   
#############################################################################
##
#M  IsQuotientClosed (<group class>)
##
InstallMethod (IsQuotientClosed, "for generic group class", 
   true, [IsGroupClass], 0, 
   function (C)
      Error ("Sorry, cannot decide if the group class <C> \
         is quotient closed.");
   end);
   
   
#############################################################################
##
#M  IsResiduallyClosed (<group class>)
##
InstallMethod (IsResiduallyClosed, "for generic group class", 
   true, [IsGroupClass], 0, 
   function (C)
      Error ("Sorry, cannot decide if the group class <C> \
         is residually closed.");
   end);
   
   
#############################################################################
##
#M  IsNormalProductClosed (<group class>)
##
InstallMethod (IsNormalProductClosed, "for generic group class", 
   true, [IsGroupClass], 0, 
   function (C)
      Error ("Sorry, cannot decide if the group class <C> \
         is closed under products of normal subgroups.");
   end);
   
   
#############################################################################
##
#M  IsDirectProductClosed (<group class>)
##
InstallMethod (IsDirectProductClosed, "for generic group class", 
   true, [IsGroupClass], 0, 
   function (C)
      Error ("Sorry, cannot decide if the group class <C> \
         is closed under direct products.");
   end);

   
#############################################################################
##
#M  IsSchunckClass (<group class>)
##
InstallMethod (IsSchunckClass, "for generic group class", 
   true, [IsGroupClass], 0, 
   function (C)
      Error ("Sorry, cannot decide if the group class <C> \
         is a Schunck class.");
   end);

   
#############################################################################
##
#P  IsSaturated (<group class>)
##
InstallMethod (IsSaturated, "for generic group class", 
   true, [IsGroupClass], 0, 
   function (C)
      Error ("Sorry, cannot decide if the group class <C> \
         is saturated.");
   end);

      
#############################################################################
##
#F  SetIsOrdinaryFormation (<group class>)
##
##  fake setter function
##
InstallGlobalFunction ("SetIsOrdinaryFormation", 
   function (C, b)
      if not IsGroupClass (C) or b <> true then
         Error ("<C> must be a group class and <b> must be true");
      fi;
      SetContainsTrivialGroup (C, b);
      SetIsQuotientClosed (C, b);
      SetIsResiduallyClosed (C, b);
   end);
   
   
#############################################################################
##
#F  SetIsFittingClass (<group class>)
##
##  fake setter function
##
InstallGlobalFunction ("SetIsFittingClass", 
   function (C, b)
      if not IsGroupClass (C) or b <> true then
         Error ("<C> must be a group class and <b> must be true");
      fi;
      SetContainsTrivialGroup (C, b);
      SetIsNormalSubgroupClosed (C, b);
      SetIsNormalProductClosed (C, b);
   end);

   
#############################################################################
##
#F  SetIsFittingFormation (<group class>)
##
##  fake setter function
##
InstallGlobalFunction ("SetIsFittingFormation", 
   function (C, b)
      if not IsGroupClass (C) or b <> true then
         Error ("<C> must be a group class and <b> must be true");
      fi;
      SetIsFittingClass (C, b);
      SetIsOrdinaryFormation (C, b);
   end);

   
#############################################################################
##
#F  SetIsSaturatedFormation (<group class>)
##
##  fake setter function
##
InstallGlobalFunction ("SetIsSaturatedFormation", 
   function (C, b)
      if not IsGroupClass (C) or b <> true then
         Error ("<C> must be a group class and <b> must be true");
      fi;
      SetIsOrdinaryFormation (C, b);
      SetIsSaturated (C, b);
   end);

   
#############################################################################
##
#F  SetIsSaturatedFittingFormation (<group class>)
##
##  fake setter function
##
InstallGlobalFunction  ("SetIsSaturatedFittingFormation", 
   function (C, b)
      if not IsGroupClass (C) or b <> true then
         Error ("<C> must be a group class and <b> must be true");
      fi;
      SetIsFittingFormation (C, b);
      SetIsSaturated (C, b);
   end);


#############################################################################
##
#M  Basis (<class>)
##
##  the basis of a group class <class> consists of the primitive solvable 
##  groups in <class>
##
InstallMethod (Basis, "for group class", true, 
   [IsGroupClass], 0,
   function (H)
      return GroupClass (G -> IsPrimitiveSolvableGroup (G) and G in H);
   end);
   

#############################################################################
##
#M  Characteristic (<class>)
##
InstallMethod (Characteristic, "for generic grp class", true, 
   [IsGroupClass], 0,
   function (H)
       return Class (p -> IsPosInt (p) and IsPrime (Integers, p) 
          and CyclicGroup (p) in H);
   end);


#############################################################################
##
#M  Characteristic (<class>)
##
InstallMethod (Characteristic, "for intersection of group classes", true, 
   [IsGroupClass and IsClassByIntersectionRep], 0,
   function (H)
      if ForAll (H!.intersected, IsGroupClass) then
         return Intersection (List (H!.intersected, Characteristic));
      else
         TryNextMethod();
      fi;
   end);


#############################################################################
##
#M  Characteristic (<class>)
##
InstallMethod (Characteristic, "for union of group classes", true, 
   [IsGroupClass and IsClassByUnionRep], 0,
   function (H)
      if ForAll (H!.united, C -> IsGroupClass (C)) then
         return Union (List (H!.united, Characteristic));
      else
         TryNextMethod();
      fi;
   end);


#############################################################################
#E
##
