#############################################################################
##
##  schunck.gi                      CRISP                    Burkhard Höfling
##
##  @(#)$Id: schunck.gi,v 1.6 2011/05/15 19:18:01 gap Exp $
##
##  Copyright (C) 2000, 2005 Burkhard Höfling
##
Revision.schunck_gi :=
    "@(#)$Id: schunck.gi,v 1.6 2011/05/15 19:18:01 gap Exp $";


###################################################################################
##
#M  IsPrimitiveSolvableGroup
##
InstallMethod (IsPrimitiveSolvableGroup, "for generic group", true,
   [IsGroup], 0,
   function (G)
   
      local N, ds, p, pcgs, mats, R, Q, M, m, k, q, c, i;
      
      if IsTrivial (G) then
         return false;
      fi;
      
      ds := DerivedSeries (G);
      
      if not IsTrivial (ds[Length (ds)]) then
         return false;
      fi; 
      
      N := ds[Length (ds)-1];
      
      pcgs := Pcgs (N);
      if Length (ds) = 2 then # abelian case
         if Length (pcgs) = 1 then
            SetSocle (G, G);
            SetSocleComplement (G, TrivialSubgroup (G));
            return true;
         else
            return false;
         fi;
      fi;
      
      p := RelativeOrderOfPcElement (pcgs, pcgs[1]);
      
      if ForAny (pcgs, x -> x^p <> One(G)) then
         return false;
      fi;
      
      R := ds[Length (ds)-2];
      m := ModuloPcgs (R, N);
      
      if p in RelativeOrders (m) then # N is not the Fitting subgroup of G
         return false;
      fi;
      
      # find out if N is a minimal normal subgroup of G
      mats := LinearActionLayer (G, GeneratorsOfGroup (G), pcgs);

      if not MTX.IsIrreducible (GModuleByMats (mats, GF(p))) then
         return false;
      fi;
      
      # now test if N is complemented
      
      # find small Sylow subgroup of R 
      c := Collected (RelativeOrders (m));
      k := c[1][2];
      q := c[1][1];
      
      for i in [2..Length (c)] do
         if c[i][2] < k then
            k := c[i][2];
            q := c[i][1];
         fi;
      od;
      
      Q := SylowSubgroup (R, q);
      
      if IsNormal (G, Q) then
             return false;
      fi;
      
      M := NormalizerOfPronormalSubgroup (G, Q);
      
      if not IsTrivial (Core (N, M)) then
         return false;
      fi;
      
      # save some information about G
      SetSocle (G, N);
      SetFittingSubgroup (G, N);
      
      # if Q is not normal, its normalizer is a complement of N in G
      SetSocleComplement (G, M);
      return true;
   end);


###################################################################################
##
#M  SocleComplement
##
InstallMethod (SocleComplement, "for primitive solvable group", true,
   [IsGroup and IsPrimitiveSolvableGroup], 0,
   function (G)
   
      local N, ds, p, pcgs, mats, R, Q, M, m, k, q, c, i;
      
      if IsTrivial (G) then
         Error ("G must be primitive and solvable");
      fi;
      
      ds := DerivedSeries (G);
      
      if not IsTrivial (ds[Length (ds)]) then
          Error ("G must be primitive and solvable");
      fi; 
      
      N := ds[Length (ds)-1];
      
      pcgs := Pcgs (N);
      if Length (ds) = 2 then # abelian case
         if Length (pcgs) = 1 then
            SetSocle (G, G);
            SetSocleComplement (G, TrivialSubgroup (G));
            return true;
         else
            return false;
         fi;
      fi;
      
      p := RelativeOrderOfPcElement (pcgs, pcgs[1]);
      
      if ForAny (pcgs, x -> x^p <> One(G)) then
          Error ("G must be primitive and solvable");
      fi;
      
      R := ds[Length (ds)-2];
      
      # now test if N is complemented
      
      # find small Sylow subgroup of R 
      c := Collected (RelativeOrders (m));
      k := c[1][2];
      q := c[1][1];
      
      for i in [2..Length (c)] do
         if c[i][2] < k then
            k := c[i][2];
            q := c[i][1];
         fi;
      od;
      
      Q := SylowSubgroup (R, q);
      
      if IsNormal (G, Q) then
         return false;
      fi;
      
      M := NormalizerOfPronormalSubgroup (G, Q);
      
      if not IsTrivial (Core (N, M)) then
         return false;
      fi;
      
      # save some information about G
      SetSocle (G, N);
      SetFittingSubgroup (G, N);
      
      # if Q is not normal, its normalizer is a complement of N in G
      return M;
   end);


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
             if not IsPrimitiveSolvableGroup (G) then
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
             
             if not IsPrimitiveSolvableGroup (G) then
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
       return GroupClass (G -> IsPrimitiveSolvableGroup (G) 
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



