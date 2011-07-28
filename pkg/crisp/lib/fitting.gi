#############################################################################
##
##  fitting.gi                      CRISP                    Burkhard Höfling
##
##  @(#)$Id: fitting.gi,v 1.4 2011/05/15 19:17:54 gap Exp $
##
##  Copyright (C) 2000 Burkhard Höfling
##
Revision.fitting_gi :=
    "@(#)$Id: fitting.gi,v 1.4 2011/05/15 19:17:54 gap Exp $";


#############################################################################
##
#M  FittingClass (<rec>)
##
InstallMethod (FittingClass, true, [IsRecord], 0,
   function (record)
      local F, r;
      r := ShallowCopy (record);
   
      F := NewClass ("FittingClass", 
         IsGroupClass and IsClassByPropertyRep, 
         rec (definingAttributes :=
            [   ["in", MemberFunction],
                ["rad", RadicalFunction],
                ["inj", InjectorFunction]]));
      SetIsFittingClass (F, true);
      if IsBound (r.char) then
         SetCharacteristic (F, r.char);
         Unbind (r.char);
      fi;
      InstallDefiningAttributes (F, r);
      return F;
   end);


#############################################################################
##
#M  ViewObj (<fit>)
##
InstallMethod (ViewObj, "for Fitting class", true, 
   [IsFittingClass and IsClassByPropertyRep], 0,
   function (C) 
      Print ("FittingClass (");
      ViewDefiningAttributes (C);
      Print (")");
   end);


#############################################################################
##
#M  PrintObj (<fit>)
##
InstallMethod (PrintObj, "for Fitting class", true, 
   [IsFittingClass and IsClassByPropertyRep], 0,
   function (C) 
      Print ("FittingClass ( rec (");
      PrintDefiningAttributes (C);
      Print ("))");
   end);


#############################################################################
##
#M  IsMemberOp (<grp>, <fit>)
##
InstallMethod (IsMemberOp, "if radical is known", true, 
   [IsGroup, IsFittingClass and HasRadicalFunction], 1,  
         # radical function is usually faster than injector
   function (G, C)
      if HasMemberFunction (C) then
         TryNextMethod();
      else
         return IsSubgroup (RadicalFunction(C) (G), G);
      fi;
   end);
 
 
#############################################################################
##
#M  IsMemberOp (<grp>, <fit>)
##
InstallMethod (IsMemberOp, "if injector is known", true, 
      [IsGroup, IsFittingClass and HasInjectorFunction], 0,
   function (G, C)
      if HasMemberFunction (C) then
         TryNextMethod();
      else
         return IsSubgroup (InjectorFunction(C) (G), G);
      fi;
 end);


#############################################################################
##
#R  IsFittingProductRep (<cl>)
##
##  classes which are defined as Fitting product
##
DeclareRepresentation ("IsFittingProductRep", 
   IsClass and IsGroupClass and IsFittingClass and 
      IsComponentObjectRep and IsAttributeStoringRep, 
   ["classId", "bot", "top"]);


#############################################################################
##
#M  FittingProduct (<bot>, <top>)
##
InstallMethod (FittingProduct, "of two Fittng classes", true, 
   [IsFittingClass, IsFittingClass], 0, 
   function (B, T)
      return NewClass ("Fitting product fam", IsFittingProductRep,
         rec (bot := B, top := T));
   end);


#############################################################################
##
#M  ViewObj
##
InstallMethod (ViewObj, "for Fitting product", true, [IsFittingProductRep], 0,
   function (C) 
      Print ("FittingProduct (");
      ViewObj (C!.bot);
      Print (", ");
      ViewObj (C!.top);
      Print (")");
   end);


#############################################################################
##
#M  PrintObj
##
InstallMethod (PrintObj, "for Fitting product", true, [IsFittingProductRep], 0,
   function (C) 
      Print ("FittingProduct (");
      PrintObj (C!.bot);
      Print (", ");
      PrintObj (C!.top);
      Print (")");
   end);


#############################################################################
##
#M  IsMemberOp (<prod>)
##
InstallMethod (IsMemberOp, "for Fitting product", true, 
   [IsGroup, IsFittingProductRep], 0, 
   function (G, C)
      return G/ Radical (G, C!.bot) in C!.top;
   end);


#############################################################################
##
#M  Characteristic (<bot>, <top>)
##
InstallMethod (Characteristic, "for Fitting product", true, 
   [IsFittingProductRep], 0,
   function (C) 
      return Union (Characteristic (C!.top), Characteristic (C!.bot));
   end);
   

#############################################################################
##
#M  FittingProduct (<bot>, <top>)
##
InstallMethod (FittingProduct, 
   "for Fitting formation - use FormationProduct", true, 
   [IsFittingFormation, IsFittingFormation], 0,
   FormationProduct);
   

#############################################################################
##
#R  IsFittingSetRep
##
DeclareRepresentation ("IsFittingSetRep", 
   IsClassByPropertyRep and IsMultiplicativeElementCollColl, 
   ["classId", "group"]);


#############################################################################
##
#M  FittingSet (<grp>, <rec>)
##
InstallMethod (FittingSet, true, [IsGroup, IsRecord], 0,
   function (G, r)
      
      local F;
      
      F := NewClass (CollectionsFamily (FamilyObj (G)), IsFittingSetRep, 
         rec (group := G,
            definingAttributes := 
            [   ["in", MemberFunction],
                ["rad", RadicalFunction],
                ["inj", InjectorFunction]]));
      InstallDefiningAttributes (F, r); 
      return F;
   end);


      
#############################################################################
##
#M  IsFittingSet (<grp>, <class>)
##
InstallMethod (IsFittingSet, " for IsFittingSetRep", 
   function (G, C) return IsIdenticalObj (CollectionsFamily (G), C); end, 
   [IsGroup, IsFittingSetRep], 3,
   function (G, C)
      return IsSubgroup (C!.group, G);
   end);

   
#############################################################################
##
#M  IsFittingSet (<grp>, <class>)
##
InstallMethod (IsFittingSet, " for Fitting class", 
   true,
   [IsGroup, IsFittingClass], 0,
   function (G, C)
      return true;
   end);


#############################################################################
##
#M  ViewObj (<fit>)
##
InstallMethod (ViewObj, "for Fitting set", true, 
   [IsFittingSetRep and IsClassByPropertyRep], 0,
   function (C) 
      Print ("FittingSet (", C!.group, ", rec (");
      ViewDefiningAttributes (C);
      Print ("))");
   end);


#############################################################################
##
#M  PrintObj (<fit>)
##
InstallMethod (PrintObj, "for Fitting set", true, 
   [IsFittingSetRep and IsClassByPropertyRep], 0,
   function (C) 
      Print ("FittingSet (", C!.group, ", rec (");
      PrintDefiningAttributes (C);
      Print ("))");
   end);


#############################################################################
##
#M  IsMemberOp (<grp>, <fitset>)
##
InstallMethod (IsMemberOp, "if radical is known", 
   function (G, C) return IsIdenticalObj (CollectionsFamily (G), C); end, 
      [IsGroup, IsFittingSetRep and HasRadicalFunction], 1,  # radical function is usually faster than injector
   function (G, C)
      if HasMemberFunction (C) then
         TryNextMethod();
      else
         return IsSubgroup (RadicalFunction(C) (G), G);
      fi;
   end);
   
#############################################################################
##
#M  IsMemberOp (<grp>, <fitset>)
##
InstallMethod (IsMemberOp, "for FittingSetRep with inj function", 
   function (G, C) return IsIdenticalObj (CollectionsFamily (G), C); end, 
   [IsGroup, IsFittingSetRep and HasInjectorFunction], 0,
   function (G, C)
      if HasMemberFunction (C) then
         TryNextMethod();
      else
         return IsSubgroup (InjectorFunction(C) (G), G);
      fi;
   end);
   
   
#############################################################################
##
#M  Intersection2 (<fitset>, <fit>)
##
InstallMethod (Intersection2, "for Fitting set and Fitting class", true,
   [IsFittingSetRep, IsFittingClass], 0,
   function (F1, F2)
      local F;
      F := FittingSet (F1!.group, 
         rec (\in := x -> x in F1 and x in F2, 
             rad := G -> Radical (Radical (G, F2), F1)));
      return F;
   end);
      

#############################################################################
##
#M  Intersection2 (<fit>, <fitset>)
##
InstallMethod (Intersection2, "for Fitting class and Fitting set", 
   IsIdenticalObj,
   [IsFittingClass, IsFittingSetRep], 0,
   function (F1, F2)
      return Intersection2 (F2, F1);
   end);
      

#############################################################################
##
#M  Intersection2 (<fitset1>, <fitset2>)
##
InstallMethod (Intersection2, "for Fitting sets", IsIdenticalObj,
   [IsFittingSetRep, IsFittingSetRep], 0,
   function (F1, F2)
      local F;
      F := FittingSet (Intersection (F1!.group, F2!.group), 
         rec (\in := x -> x in F1 and x in F2, 
             rad := G -> Radical (Radical (G, F2), F1)));
      return F;
   end);
      
      
#############################################################################
##
#M   PreImageFittingSet (<alpha>, <fitset>) 
##
##   return Fitting set of preimage
##
InstallMethod (PreImageFittingSet, "for Fitting set", 
   function (famalpha, famF)
      return IsIdenticalObj (FamilyRange (famalpha),
                  ElementsFamily (ElementsFamily (famF)));
   end,
   [IsGroupHomomorphism, IsFittingSetRep], 0, 
   function (alpha, F)

      if not IsFittingSet (ImagesSource (alpha), F) then
         Error ("F must be a Fitting set of the image of alpha");
      else 
         return FittingSet (Source (alpha), rec(
            inj := G ->PreImagesSet (alpha, 
               Injector (ImagesSet (alpha, G), F))));
      fi;
   end);


#############################################################################
##
#M   PreImageFittingSet (<alpha>, <fitset>) 
##
##   return Fitting set of preimage of an isomorphism
##
InstallMethod (PreImageFittingSet, "for Fitting set - injective case", 
   function (famalpha, famF)
      return IsIdenticalObj (FamilyRange (famalpha), 
                  ElementsFamily (ElementsFamily (famF)));
   end,
   [IsGroupHomomorphism and IsInjective, IsFittingSetRep], 0, 
   function (alpha, F)

      if not IsFittingSet (ImagesSource (alpha), F) then
         Error ("F must be a Fitting set of the image of alpha");
      else
         return FittingSet (Source (alpha), rec (
            \in := G ->ImagesSet (alpha, G) in F, 
            rad := G ->PreImagesSet (alpha, 
               Radical (ImagesSet (alpha, G), F)),
            inj := G ->PreImagesSet (alpha, 
               Injector (ImagesSet (alpha, G), F))));
      fi;
   end);


#############################################################################
##
#M   ImageFittingSet (<alpha>, <fitset>) 
##
##   return Fitting set of image
##
InstallMethod (ImageFittingSet, "for Fitting set",
   function (famalpha, famF)
      return IsIdenticalObj (FamilySource (famalpha), 
         ElementsFamily (ElementsFamily (famF)));
   end,
   [IsGroupHomomorphism, IsFittingSetRep], 0, 
   function (alpha, F)

      if not IsFittingSet (Source (alpha), F) then
         Error ("F must be a Fitting set of the preimage of alpha");
      else 
         return FittingSet (ImagesSource (alpha), rec(
            inj := G ->ImagesSet (alpha, 
               Injector (PreImagesSet (alpha, G), F))));
      fi;
   end);



#############################################################################
##
#M   ImageFittingSet (<alpha>, <fitset>) 
##
##   return Fitting set of image when alpha is injective
##
InstallMethod (ImageFittingSet, "for Fitting set - injective case",
   function (famalpha, famF)
      return IsIdenticalObj (FamilySource (famalpha), 
                  ElementsFamily (ElementsFamily (famF)));
   end,
   [IsGroupHomomorphism and IsInjective, IsFittingSetRep], 0, 
   function (alpha, F)

      if not IsFittingSet (Source (alpha), F) then
         Error ("F must be a Fitting set of the preimage of alpha");
      else 
         return FittingSet (ImagesSet (alpha), rec(
            \in := G ->PreImagesSet (alpha, G) in F, 
            rad := G ->ImagesSet (alpha, 
            Radical (PreImagesSet (alpha, G), F)),
            inj := G ->ImagesSet (alpha, 
               Injector (PreImagesSet (alpha, G), F))));
      fi;
   end);


#############################################################################
##
#M   PreImageFittingSet (<alpha>, <fit>) 
##
##   return Fitting set of preimage
##
InstallMethod (PreImageFittingSet, "for Fitting class", true,
    [IsGroupHomomorphism, IsFittingClass], 0, 
   function (alpha, F)

      return FittingSet (Source (alpha), rec(
         inj := G ->PreImagesSet (alpha, 
            Injector (ImagesSet (alpha, G), F))));
   end);


#############################################################################
##
#M   PreImageFittingSet (<alpha>, <fit>) 
##
##   return Fitting set of preimage of an isomorphism
##
InstallMethod (PreImageFittingSet, "for Fitting class - injective case", true,
    [IsGroupHomomorphism and IsInjective, IsFittingClass], 0, 
   function (alpha, F)

      return FittingSet (Source (alpha), rec (
         \in := G ->ImagesSet (alpha, G) in F, 
         rad := G ->PreImagesSet (alpha, 
            Radical (ImagesSet (alpha, G), F)),
         inj := G ->PreImagesSet (alpha, 
            Injector (ImagesSet (alpha, G), F))));
   end);

#############################################################################
##
#M   ImageFittingSet (<alpha>, <fitset>) 
##
##   return Fitting set of image
##
InstallMethod (ImageFittingSet, "for Fitting class", true,
    [IsGroupHomomorphism, IsFittingClass], 0, 
   function (alpha, F)

      return FittingSet (Image (alpha), rec(
         inj := G ->ImagesSet (alpha, 
            Injector (PreImagesSet (alpha, G), F))));
   end);



#############################################################################
##
#M   ImageFittingSet (<alpha>, <fitset>) 
##
##   return Fitting set of image when alpha is injective
##
InstallMethod (ImageFittingSet, "for Fitting class - injective case", true,
    [IsGroupHomomorphism and IsInjective, IsFittingClass], 0, 
   function (alpha, F)

      return FittingSet (Image (alpha), rec(
         \in := G ->PreImagesSet (alpha, G) in F, 
         rad := G ->ImagesSet (alpha, 
            Radical (PreImagesSet (alpha, G), F)),
         inj := G ->ImagesSet (alpha, 
            Injector (PreImagesSet (alpha, G), F))));
   end);


############################################################################
##
#E
##

