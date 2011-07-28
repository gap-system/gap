#############################################################################
##
##  form.gi                         CRISP                    Burkhard Höfling
##
##  @(#)$Id: form.gi,v 1.3 2011/05/15 19:17:54 gap Exp $
##
##  Copyright (C) 2000 Burkhard Höfling
##
Revision.form_gi :=
    "@(#)$Id: form.gi,v 1.3 2011/05/15 19:17:54 gap Exp $";


#############################################################################
##
#M  OrdinaryFormation (<rec>)
##
InstallMethod (OrdinaryFormation, true, [IsRecord], 0,
   function (record)
      local F, r;
      r := ShallowCopy (record);
       F := NewClass ("OrdinaryFormation", IsGroupClass and IsClassByPropertyRep, 
          rec (definingAttributes := [
             ["in", MemberFunction],
             ["res", ResidualFunction]]));
      if IsBound (r.char) then
         SetCharacteristic (F, r.char);
         Unbind (r.char);
      fi;
      InstallDefiningAttributes (F, r);
         SetIsOrdinaryFormation (F, true);
       return F;
   end);


#############################################################################
##
#M  ViewObj (<form>)
##
InstallMethod (ViewObj, "for formation", true, 
   [IsOrdinaryFormation and IsClassByPropertyRep], 0,
   function (C) 
      Print ("OrdinaryFormation (");
      ViewDefiningAttributes (C);
      Print (")");
   end);

#############################################################################
##
#M  PrintObj (<form>)
##
InstallMethod (PrintObj, "for formation", true, 
   [IsOrdinaryFormation and IsClassByPropertyRep], 0,
   function (C) 
      Print ("OrdinaryFormation(");
      PrintDefiningAttributes (C);
      Print (")");
   end);


#############################################################################
##
#M  IsMemberOp (<grp>, <form>)
##
InstallMethod (IsMemberOp, "if residual function is known", true, 
   [IsGroup, IsOrdinaryFormation and HasResidualFunction], 10,  
         # residual function is usually faster 
         # than computation of radical or injector
   function (G, C)
      if HasMemberFunction (C) then
         TryNextMethod();
      else
         return IsTrivial (ResidualFunction(C) (G));
      fi;
   end);
 

#############################################################################
##
#M  SaturatedFormation (<rec>)
##
InstallMethod (SaturatedFormation, true, [IsRecord], 0,
   function (record)
      local F, r;
      r := ShallowCopy (record);
      F := NewClass ("saturated Formation", IsGroupClass and IsClassByPropertyRep, 
            rec (definingAttributes := 
                 [   ["in", MemberFunction],
                 ["res", ResidualFunction],
                 ["proj", ProjectorFunction],
                 ["locdef", LocalDefinitionFunction],
                 ["bound", BoundaryFunction]]));
      if IsBound (r.char) then
         SetCharacteristic (F, r.char);
         Unbind (r.char);
      fi;
        SetIsSaturatedFormation (F, true);
        InstallDefiningAttributes (F, r);
      return F;
   end);

#############################################################################
##
#M  ViewObj (<form>)
##
InstallMethod (ViewObj, "for a saturated formation", true, 
   [IsSaturatedFormation and IsClassByPropertyRep], 0,
   function (C) 
      Print ("SaturatedFormation (");
      ViewDefiningAttributes (C);
      Print (")");
   end);


#############################################################################
##
#M  PrintObj (<form>)
##
InstallMethod (PrintObj, "for a saturated formation", true, 
   [IsSaturatedFormation and IsClassByPropertyRep], 0,
   function (C) 
      Print ("SaturatedFormation (");
      PrintDefiningAttributes (C);
      Print (")");
   end);


#############################################################################
##
#M  FittingFormation (<rec>)
##
InstallMethod (FittingFormation, true, [IsRecord], 0,
   function (record)
      local F, r;
      r := ShallowCopy (record);
      F := NewClass ("FittingFormation", IsGroupClass and IsClassByPropertyRep, rec (
         definingAttributes :=
         [   ["in", MemberFunction],
             ["rad", RadicalFunction],
             ["inj", InjectorFunction],
              ["res", ResidualFunction] ]));
      SetIsFittingFormation (F, true);
      if IsBound (r.char) then
         SetCharacteristic (F, r.char);
         Unbind (r.char);
      fi;
      InstallDefiningAttributes (F, r);
      return F;
   end);


#############################################################################
##
#M  ViewObj (<fitform>)
##
InstallMethod (ViewObj, "for Fitting formation", true, 
   [IsFittingFormation and IsClassByPropertyRep], 0,
   function (C) 
      Print ("FittingFormation (");
      ViewDefiningAttributes (C);
      Print (")");
   end);


#############################################################################
##
#M  PrintObj (<fitform>)
##
InstallMethod (PrintObj, "for Fitting formation", true, 
   [IsFittingFormation and IsClassByPropertyRep], 0,
   function (C) 
      Print ("FittingFormation ( ");
      PrintDefiningAttributes (C);
      Print (")");
   end);


#############################################################################
##
#M  SaturatedFittingFormation (<rec>)
##
InstallMethod (SaturatedFittingFormation, true, [IsRecord], 0,
   function (record)
      local F, r;
      r := ShallowCopy (record);
      F := NewClass ("SaturatedFittingFormation", IsGroupClass and IsClassByPropertyRep, rec (
         definingAttributes :=
         [   ["in", MemberFunction],
             ["rad", RadicalFunction],
             ["inj", InjectorFunction],
             ["locdef", LocalDefinitionFunction],
              ["res", ResidualFunction],
              ["proj", ProjectorFunction],
              ["bound", BoundaryFunction]
           ]));
      SetIsSaturatedFittingFormation (F, true);
      if IsBound (r.char) then
         SetCharacteristic (F, r.char);
         Unbind (r.char);
      fi;
      InstallDefiningAttributes (F, r);
      return F;
   end);


#############################################################################
##
#M  ViewObj (<fitform>)
##
InstallMethod (ViewObj, "for saturated Fitting formation", true, 
   [IsSaturatedFittingFormation and IsClassByPropertyRep], 0,
   function (C) 
      Print ("SaturatedFittingFormation (");
      ViewDefiningAttributes (C);
      Print (")");
   end);


#############################################################################
##
#M  PrintObj (<fitform>)
##
InstallMethod (PrintObj, "for saturated Fitting formation", true, 
   [IsSaturatedFittingFormation and IsClassByPropertyRep], 0,
   function (C) 
      Print ("SaturatedFittingFormation (");
      PrintDefiningAttributes (C);
      Print (")");
   end);


#############################################################################
##
#R  IsFormationProductRep (<cl>)
##
##  classes which are defined as formation product
##
DeclareRepresentation ("IsFormationProductRep", 
   IsClass and IsGroupClass and IsOrdinaryFormation 
      and IsComponentObjectRep and IsAttributeStoringRep, 
   ["classId", "bot", "top"]);


#############################################################################
##
#M  FormationProduct (<bot>, <top>)
##
InstallMethod (FormationProduct, "of two formations", true, 
   [IsOrdinaryFormation, IsOrdinaryFormation], 0, 
   function (B, T)
      return NewClass ("formation product fam", IsFormationProductRep,
         rec (bot := B, top := T));
   end);


#############################################################################
##
#M  ViewObj
##
InstallMethod (ViewObj, "for formation product", true, [IsFormationProductRep], 0,
   function (C) 
      Print ("FormationProduct (");
      ViewObj (C!.bot);
      Print (", ");
      ViewObj (C!.top);
      Print (")");
   end);


#############################################################################
##
#M  PrintObj
##
InstallMethod (PrintObj, "for formation product", true, [IsFormationProductRep], 0,
   function (C) 
      Print ("FormationProduct (");
      PrintObj (C!.bot);
      Print (", ");
      PrintObj (C!.top);
      Print (")");
   end);


#############################################################################
##
#M  IsMemberOp (<prod>)
##
InstallMethod (IsMemberOp, "for formation product", true, 
   [IsGroup, IsFormationProductRep], 0, 
   function (G, C)
      return Residual (G, C!.top) in C!.bot;
   end);


#############################################################################
##
#M  Characteristic (<prod>)
##
InstallMethod (Characteristic, "for formation product", true, 
   [IsFormationProductRep], 0,
   function (C) 
      return Union (Characteristic (C!.top), Characteristic (C!.bot));
   end);
   

#############################################################################
##
#M  IsSaturated (<grpclass>)
##
InstallImmediateMethod (IsSaturated, IsFormationProductRep, 0,
   function (C) 
      if HasIsSaturated (C!.bot) and HasIsSaturated (C!.top)
         and IsSaturated (C!.bot) and IsSaturated (C!.top) then
            return true;
      else
         TryNextMethod();
      fi;
   end);
         
         
#############################################################################
##
#M  LocalDefinitionFunction (<prod>)
##
InstallImmediateMethod (LocalDefinitionFunction, 
   IsFormationProductRep and IsSaturated, 0,
   function (C) 
      if HasLocalDefinitionFunction (C!.bot) 
            and HasLocalDefinitionFunction (C!.top) then
         return function (G, p)
            local gens;
            gens := LocalDefinitionFunction (C!.bot) (Residual (G, C!.top), p);
            if gens = fail then # p is not in the characteristic of C!.bot
               return LocalDefinitionFunction (C!.top) (G, p);
            else
               return gens;
            fi;
         end;
      else
         TryNextMethod();
      fi;
   end);
   
   
#############################################################################
##
#M  IsSaturated (<grpclass>)
##
InstallImmediateMethod (IsSaturated, IsFormationProductRep, 0,
   function (C) 
      local char;
      if HasIsSaturated (C!.bot) and IsSaturated (C!.bot) 
            and HasCharacteristic (C!.bot) 
            and Characteristic (C!.bot) = AllPrimes then
         return true;
      else
         TryNextMethod();
      fi;
   end);
         
         

#############################################################################
##
#M  LocalDefinitionFunction (<prod>)
##
InstallImmediateMethod (LocalDefinitionFunction, 
   IsFormationProductRep and IsSaturated, 0,
   function (C) 
      if HasCharacteristic (C!.bot) and Characteristic (C!.bot) = AllPrimes
            and HasLocalDefinitionFunction (C!.bot) then
         SetCharacteristic (C, AllPrimes);
         return function (G, p)
            return LocalDefinitionFunction (C!.bot) (Residual (G, C!.top), p);
         end;
      else
         TryNextMethod();
      fi;
   end);
   

#############################################################################
##
#M  IsSaturated (<grpclass>)
##
##  (this can be expensive in some cases, so it is not an immediate method)
##
InstallMethod (IsSaturated, 
   "test if char of top class is subset of char of bot class",
   true, [IsFormationProductRep], 0,
   function (C) 
      local char;
      char := Characteristic (C!.top);
      if IsSaturated (C!.bot) and IsList (char) and ForAll (char, p -> p in Characteristic (C!.bot)) then
         return true;
      else
         TryNextMethod();
      fi;
   end);
         
         
#############################################################################
##
#M  LocalDefinitionFunction (<prod>)
##
##  (this can be expensive in some cases, so it is not an immediate method)
##
InstallMethod (LocalDefinitionFunction, 
   "test if char of top class is subset of char of bot class",
   true, [IsFormationProductRep], 0,
   function (C) 
      local char;
      char := Characteristic (C!.top);
      if IsList (char) and ForAll (char, p -> p in Characteristic (C!.bot)) then
         SetIsSaturated (C, true);
         SetCharacteristic (C, Characteristic (C!.bot));
         return function (G, p)
            return LocalDefinitionFunction (C!.bot) (Residual (G, C!.top), p);
         end;;
      else
         TryNextMethod();
      fi;
   end);
         
         
#############################################################################
##
#M  FormationProduct (<bot>, <top>)
##
InstallMethod (FormationProduct, "of two Fitting formations", true, 
   [IsOrdinaryFormation and IsFittingClass, 
      IsOrdinaryFormation and IsFittingClass], 0, 
   function (B, T)
      return NewClass ("formation/Fitting product fam", 
         IsFormationProductRep and IsFittingProductRep,
         rec (bot := B, top := T));
   end);


#############################################################################
##
#M  FittingFormationProduct (<bot>, <top>)
##
InstallMethod (FittingFormationProduct, "of two Fitting formations", true, 
   [IsOrdinaryFormation and IsFittingClass, IsOrdinaryFormation and IsFittingClass], 0, 
   FormationProduct);


#############################################################################
##
#M  ViewObj
##
InstallMethod (ViewObj, "for product of Fitting formations", true, 
   [IsFormationProductRep and IsFittingProductRep], 0,
   function (C) 
      Print ("FittingFormationProduct (");
      ViewObj (C!.bot);
      Print (", ");
      ViewObj (C!.top);
      Print (")");
   end);


#############################################################################
##
#M  PrintObj
##
InstallMethod (PrintObj, "for product of Fitting formations", true, 
   [IsFormationProductRep and IsFittingProductRep], 0,
   function (C) 
      Print ("FittingFormationProduct (");
      PrintObj (C!.bot);
      Print (", ");
      PrintObj (C!.top);
      Print (")");
   end);


#############################################################################
##
#M  IsMemberOp (<prod>)
##
InstallMethod (IsMemberOp, "for Fitting/formation product", true, 
   [IsGroup, IsFormationProductRep and IsFittingProductRep], 0, 
   function (G, C)
      return Residual (G, C!.top) in C!.bot;
   end);


#############################################################################
##
#M  IsSubgroupClosed (<prod>)
##
InstallImmediateMethod (IsSubgroupClosed, IsFittingProductRep, 0,
   function (C)
      if HasIsSubgroupClosed (C!.bot) and IsSubgroupClosed (C!.bot) and 
            HasIsSubgroupClosed (C!.top) and IsSubgroupClosed (C!.top) then
         return true;
      else
         TryNextMethod();
      fi;
   end);


############################################################################
##
#E
##

   