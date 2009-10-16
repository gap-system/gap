#############################################################################
##
##  schunck.gi                      CRISP                 Burkhard H\"ofling
##
##  @(#)$Id: schunck.gi,v 1.5 2005/12/21 17:00:58 gap Exp $
##
##  Copyright (C) 2000 by Burkhard H\"ofling, Mathematisches Institut,
##  Friedrich Schiller-Universit\"at Jena, Germany
##
Revision.schunck_gi :=
    "@(#)$Id: schunck.gi,v 1.5 2005/12/21 17:00:58 gap Exp $";


#############################################################################
##
#M  SchunckClass (<rec>)
##
InstallMethod (SchunckClass, "for record", true, [IsRecord], 0,
   function (record)
      local F, r;
      r := ShallowCopy (record);
        F := NewClass ("Schunck Class", IsGroupClass and IsClassByPropertyRep, 
           rec (definingAttributes := 
              [   ["in", MemberFunction],
                 ["proj", ProjectorFunction],
                 ["bound", BoundaryFunction]]));
        SetIsSchunckClass (F, true);
        if IsBound (r.char) then
           SetCharacteristic (F, r.char);
           Unbind (r.char);
        fi;
        InstallDefiningAttributes (F, r);
      return F;
  end);


#############################################################################
##
#M  ViewObj (<class>)
##
InstallMethod (ViewObj, "for a Schunck class", true, 
   [IsSchunckClass and IsClassByPropertyRep], 0,
   function (C) 
      Print ("SchunckClass (");
      ViewDefiningAttributes (C);
      Print (")");
   end);


#############################################################################
##
#M  PrintObj (<class>)
##
InstallMethod (PrintObj, "for a Schunck class", true, 
   [IsSchunckClass and IsClassByPropertyRep], 0,
   function (C) 
      Print ("SchunckClass (");
      PrintDefiningAttributes (C);
      Print (")");
   end);


#############################################################################
##
#M  IsMemberOp (<grp>, <class>)
##
InstallMethod (IsMemberOp, "if ProjectorFunction is known", true, 
   [IsGroup, IsSchunckClass and HasProjectorFunction], 0,
   function (G, C)
    return Size (ProjectorFunction(C)(G)) = Size (G);
 end);


#############################################################################
##
#M  IsMemberOp (<grp>, <class>)
##
InstallMethod (IsMemberOp, "compute from LocalDefinitionFunction", true, 
   [IsGroup and IsFinite and IsSolvableGroup, 
      IsSaturatedFormation and HasLocalDefinitionFunction], 
   RankFilter (HasBoundaryFunction),
   function (G, C)
      return ProjectorFromExtendedBoundaryFunction (
         G, 
         rec (
            char := Characteristic (C),
            class := C,
            dfunc := DFUNC_FROM_CHARACTERISTIC,
            cfunc := CFUNC_FROM_CHARACTERISTIC,
            kfunc := KFUNC_FROM_LOCAL_DEFINITION, 
            lfunc := function (G, p, data)
               return LocalDefinitionFunction (data.class) (G, p);
            end),            
          true); # we want a membership test, not a projector
   end);


#############################################################################
##
#M  IsMemberOp (<grp>, <class>)
##
InstallMethod (IsMemberOp, "compute from boundary", true, 
   [IsGroup and IsFinite and IsSolvableGroup, 
      IsSchunckClass and HasBoundaryFunction], 
   0,
   function (G, C)
      return ProjectorFromExtendedBoundaryFunction (
         G, 
         rec (
            cfunc := CFUNC_FROM_CHARACTERISTIC_SCHUNCK,
            char := Characteristic (C),
            class := C,
            bfunc := BFUNC_FROM_TEST_FUNC,
            test := function (G, data) 
               return BoundaryFunction (data.class) (G);
            end),
          true); # we want a membership test, not a projector
   end);


#############################################################################
##
#M  IsMemberOp (<grp>, <class>)
##
RedispatchOnCondition (IsMemberOp, true, 
   [IsGroup, IsSchunckClass], [IsFinite and IsSolvableGroup],
   RankFilter (IsGroup) + RankFilter (IsClass));


#############################################################################
##
#M  Boundary (<class>)
##
InstallMethod (Boundary, "if BoundaryFunction is known", true, 
   [IsSchunckClass and HasBoundaryFunction], 3,
   function (H)
       return GroupClass (
          function (G)
             if not IsPrimitiveSolvable (G) then
                return false;
             fi;
             Socle (G);
             if SocleComplement (G) in H then
                return BoundaryFunction(H)(G);
             else
                return false;
             fi;
          end);
   end);
  

#############################################################################
##
#M  Boundary (<class>)
##
InstallMethod (Boundary, "for Schunck class with local definition", true, 
   [IsSchunckClass and HasLocalDefinitionFunction], 0,
   function (H)
       return GroupClass (
          function (G)
          
             local soc, p;
             
             if not IsPrimitiveSolvable (G) then
                return false;
             fi;
             if SocleComplement (G) in H then
                soc := Socle (G);
                p := Factors (Size (soc))[1];
                return ForAny (LocalDefinitionFunction (H) (G, p),
                   x -> ForAny (GeneratorsOfGroup (soc), y -> y^x <> y));
             else
                return false;
             fi;
          end);
    end);
 

#############################################################################
##
#M  Boundary (<class>)
##
##  This function is not particularly efficient - it exists merely for the
##  convenience of the user. 
##
InstallMethod (Boundary, "for generic grp class", true, 
   [IsGroupClass], 0,
   function (H)
       return GroupClass (G -> IsPrimitiveSolvable (G) 
          and not G in H
          and SocleComplement (G) in H);
   end);
  

#############################################################################
##
#M  Characteristic (<class>)
##
InstallMethod (Characteristic, "for Schunck class w/boundary", true, 
   [IsSchunckClass and HasBoundaryFunction], 0,
   function (H)
       return Class (function (p)
          local C;
          if IsPosInt (p) and IsPrime (Integers, p) then
             C := CyclicGroup (p);
             SetSocle (C, C);
             SetSocleComplement (C, TrivialSubgroup (C));
             return not BoundaryFunction (H)(C);
          else
             return false;
          fi;
       end);
   end);


#############################################################################
##
#M  Characteristic (<class>)
##
InstallMethod (Characteristic, "for local formation", true, 
   [IsSaturatedFormation and HasLocalDefinitionFunction], 0,
   function (H)
       return Class (p -> IsPosInt (p) and IsPrime (Integers, p) and 
          LocalDefinitionFunction (H)(TrivialGroup (), p) <> fail);
   end);


#############################################################################
##
#E
##



