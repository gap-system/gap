############################################################################
##
##  primitive.gi                 IRREDSOL                 Burkhard Hoefling
##
##  @(#)$Id: primitive.gi,v 1.4 2005/07/06 10:01:24 gap Exp $
##
##  Copyright (C) 2003-2005 by Burkhard Hoefling, 
##  Institut fuer Geometrie, Algebra und Diskrete Mathematik
##  Technische Universitaet Braunschweig, Germany
##


############################################################################
##
#F  PrimitivePcGroupIrreducibleMatrixGroup(<G>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (PrimitivePcGroupIrreducibleMatrixGroup,
   function (G)
         
      if not IsMatrixGroup (G) or not IsFinite (FieldOfMatrixGroup (G)) 
            or not IsPrimeInt (Size (FieldOfMatrixGroup (G)))
            or not IsIrreducibleMatrixGroup (G) then
         Error ("G must be an irreducible matrix group over a prime field");
      fi;

      return PrimitivePcGroupIrreducibleMatrixGroupNC (G);
   end);
   
         
############################################################################
##
#F  PrimitivePcGroupIrreducibleMatrixGroupNC(<G>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (PrimitivePcGroupIrreducibleMatrixGroupNC,
   function (G)
      local p, iso, pcgs, ros, f, coll, exp, mat, i, j, H, soc_cmpl;
      
      p := Size (FieldOfMatrixGroup (G));

      if not IsPrimeInt (p) then
         Error ("G must be over a prime field ");
      fi;
      iso := RepresentationIsomorphism (G);
      pcgs := Pcgs (Source (iso));
      ros := RelativeOrders (pcgs);
      
      f := FreeGroup (Length (pcgs) + DegreeOfMatrixGroup (G));
      coll := SingleCollector (f, 
         Concatenation (ros, 
            ListWithIdenticalEntries (DegreeOfMatrixGroup (G), p)));
            
      # relations for complement - same as for those for G      
      exp := [];   
      exp{[1,3..2*Length(pcgs)-1]} := [1..Length(pcgs)];
      for i in [1..Length (pcgs)] do
         exp{[2,4..2*Length(pcgs)]} := ExponentsOfPcElement (pcgs, pcgs[i]^ros[i]);
         # Print ("power relation ", i,": ", exp, "\n");
         SetPower (coll, i, ObjByExtRep (FamilyObj (f.1), exp));
         for j in [i+1..Length (pcgs)] do
            exp{[2,4..2*Length(pcgs)]} := ExponentsOfPcElement (pcgs, pcgs[j]^pcgs[i]);
            # Print ("conj. relation ", j, "^", i,": ", exp, "\n");
         SetConjugate (coll, j, i, ObjByExtRep (FamilyObj (f.1), exp));
         od;
      od;
      
      # relations for socle
      for j in [1..DegreeOfMatrixGroup (G)] do
         SetPower (coll, j+Length (pcgs), One(f));
      od;
      
      exp := [];
      exp{[1,3..2*DegreeOfMatrixGroup (G)-1]} := 
         [Length(pcgs) + 1..Length (pcgs) + DegreeOfMatrixGroup (G)];
            
      for i in [1..Length (pcgs)] do
         mat := ImageElm (RepresentationIsomorphism(G), pcgs[i]);
         for j in [1..DegreeOfMatrixGroup (G)] do
            exp{[2,4..2*DegreeOfMatrixGroup(G)]} := List (mat[j], IntFFE);
            # Print ("conj. relation ", j+ Length (pcgs), "^", i,": ", exp, "\n");
            SetConjugate (coll, j + Length (pcgs), i, ObjByExtRep (FamilyObj (f.1), exp));
         od;
      od;
      
      H := GroupByRwsNC (coll);
      SetSocle (H, GroupOfPcgs (InducedPcgsByPcSequenceNC (FamilyPcgs (H),
         FamilyPcgs(H){[Length (pcgs) + 1..Length (FamilyPcgs (H))]})));
      SetFittingSubgroup (H, Socle (H));

      # the following sets attributes/properties which are defined 
      # in the CRISP packages
      
      if IsBoundGlobal ("SetSocleComplement") then
         ValueGlobal ("SetSocleComplement") (H, GroupOfPcgs (InducedPcgsByPcSequenceNC (FamilyPcgs (H),
            FamilyPcgs(H){[1..Length (pcgs)]})));
      fi;
      if IsBoundGlobal ("SetIsPrimitiveSolvable") then
         ValueGlobal ("SetIsPrimitiveSolvable") (H, true);
      fi;
      return H;
   end);
   

############################################################################
##
#F  IrreducibleMatrixGroupPrimitiveSolvableGroup(<G>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (IrreducibleMatrixGroupPrimitiveSolvableGroup,
   function (G)
   
      local F, p, matgrp;
      
      if not IsSolvableGroup (G) then
         Error ("G must be solvable");
      fi;
      
      F := FittingSubgroup (G);
      
      if not IsPGroup (F)  or not IsAbelian (F) then
         Error ("G must be primitive");
      fi;
      
      p := PrimePGroup (F);
      
      if ForAny (GeneratorsOfGroup (F), x -> x^p <> One(G)) then
         Error ("G must be primitive");
      fi;

      matgrp := IrreducibleMatrixGroupPrimitiveSolvableGroupNC (G);
      
      if not IsIrreducibleMatrixGroup (matgrp, GF(p)) then
         Error ("G must be primitive");
      fi;
      
      return matgrp;
   end);
   
         
############################################################################
##
#F  IrreducibleMatrixGroupPrimitiveSolvableGroupNC(<G>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (IrreducibleMatrixGroupPrimitiveSolvableGroupNC,
   function (G)
   
      local N, p, pcgsN, pcgsGmodN, GmodN, one, mat, mats, g, h, i, H, hom;
      
      N := FittingSubgroup (G);
      
      pcgsN := Pcgs (N);
      p := RelativeOrders (pcgsN)[1];
      one := One (GF(p));
      
      mats := [];
      
      pcgsGmodN := ModuloPcgs (G, N);
      for g in pcgsGmodN do
         mat := [];
         for i in [1..Length (pcgsN)] do
            mat[i] := ExponentsOfPcElement (pcgsN, pcgsN[i]^g)*one;
         od;
         Add (mats, mat);
      od;
      H := Group (mats);
      SetSize (H, Size (G)/Size (N));
      GmodN := PcGroupWithPcgs (pcgsGmodN);
      hom := GroupHomomorphismByImagesNC (GmodN, H, FamilyPcgs (GmodN), mats);
      SetIsGroupHomomorphism (hom, true);
      SetIsBijective (hom, true);
      SetRepresentationIsomorphism (H, hom);
      return H;
   end);
      

############################################################################
##
#F  DoIteratorPrimitiveSolvableGroups(<convert_func>, <arg_list>)
##
##  generic constructor function for an iterator of all primitive solvable groups
##  which can construct permutation groups or pc groups (or other types of groups),
##  depending on convert_func
##  
InstallGlobalFunction (DoIteratorPrimitiveSolvableGroups, 
   function (convert_func, arg_list)

      local r, iter;
      
      r := CheckAndExtractArguments ([
         [[Degree, NrMovedPoints, LargestMovedPoint], IsPosInt],
         [[Order, Size], IsPosInt]],
         arg_list, 
         "IteratorPrimitivePcGroups");
      if ForAny (r.specialvalues, v -> IsEmpty (v)) then
         return Iterator ([]);
      fi;

      iter := rec(convert_func := convert_func);

      if not IsBound (r.specialvalues[1]) then 
         Error ("IteratorPrimitivePcGroupsIterator: You must specify the degree(s) of the desired primitive groups");
      else
         iter.degs := Filtered (r.specialvalues[1], IsPPowerInt);
      fi;   
      
      iter.degind := 0;
      
      if IsBound (r.specialvalues[2]) then
         iter.orders := r.specialvalues[2];
      else
         iter.orders := fail;
      fi;
      
      iter.iteratormatgrp := Iterator([]);

      iter.IsDoneIterator := function (iterator)

         local d, p, n, orders, o;
         
         if iterator!.degind > Length (iterator!.degs) then
            Error ("isDoneIterator called after it returned true");
         fi;
         
         while IsDoneIterator (iterator!.iteratormatgrp) do
            iterator!.degind := iterator!.degind + 1;
            if iterator!.degind > Length (iterator!.degs) then
               return true;
            fi;
            d := iterator!.degs[iterator!.degind];
            p := SmallestRootInt (d);
            n := LogInt (d, p);
            if IsAvailableIrreducibleSolvableGroupData (n, p) then            
               if iterator!.orders <> fail then
                  orders := [];
                  for o in iterator!.orders do
                     if o mod d = 0 then
                        Add (orders, o/d);
                     fi;
                  od;
                  iterator!.iteratormatgrp := IteratorIrreducibleSolvableMatrixGroups(
                     Degree, n, Field, GF(p), Order, orders);
               else
                  iterator!.iteratormatgrp := IteratorIrreducibleSolvableMatrixGroups(
                     Degree, n, Field, GF(p));

               fi;
            else
               Error ("groups of degree ", d, " are beyond the scope of the IRREDSOL library");
               iterator!.iteratormatgrp := Iterator([]);
            fi;
         od;
         return false;
      end;

      iter.NextIterator := function (iterator)
         
         local G;
         
         G := NextIterator (iterator!.iteratormatgrp);
         return iterator!.convert_func (G);
      end;
      
      iter.ShallowCopy := function (iterator)
         return rec (
            orders := iterator!.orders,
            degs := iterator!.degs,
            degind := iterator!.degind,
            convert_func := iterator!.convert_func,
            iteratormatgrp := ShallowCopy (iterator!.iteratormatgrp),
            IsDoneIterator := iterator!.IsDoneIterator,
            NextIterator := iterator!.NextIterator,
            ShallowCopy := iterator!.ShallowCopy);
      end;
      return IteratorByFunctions (iter);
   end);
   
   
############################################################################
##
#F  IteratorPrimitivePcGroups(<func_1>, <val_1>, ...)
##
##  see the IRREDSOL manual
##  
InstallGlobalFunction (IteratorPrimitivePcGroups,
   function (arg)
      return DoIteratorPrimitiveSolvableGroups (
         PrimitivePcGroupIrreducibleMatrixGroupNC,
         arg);
   end);
   

###########################################################################
##
#F  AllPrimitivePcGroups(<arg>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (AllPrimitivePcGroups,
   function (arg)
   
      local iter, l, G;
      
      iter := CallFuncList (IteratorPrimitivePcGroups, arg);
      
      l := [];
      for G in iter do
         Add (l, G);
      od;
      return l;
   end);


###########################################################################
##
#F  OnePrimitivePcGroup(<arg>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (OnePrimitivePcGroup,
   function (arg)
   
      local iter;
      
      iter := CallFuncList (IteratorPrimitivePcGroups, arg);
      if IsDoneIterator (iter) then
         return fail;
      else 
         return NextIterator (iter);
      fi;
   end);


############################################################################
##
#F  PrimitivePermutatioinGroupIrreducibleMatrixGroup(<G>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (PrimitivePermutationGroupIrreducibleMatrixGroup,
   function (G)
         
      if not IsMatrixGroup (G) or not IsFinite (FieldOfMatrixGroup (G)) 
            or not IsPrimeInt (Size (FieldOfMatrixGroup (G)))
            or not IsIrreducibleMatrixGroup (G) then
         Error ("G must be an irreducible matrix group over a prime field");
      fi;

      return PrimitivePermutationGroupIrreducibleMatrixGroupNC (G);
   end);
   
         
############################################################################
##
#F  PrimitivePermutationGroupIrreducibleMatrixGroupNC(<G>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (PrimitivePermutationGroupIrreducibleMatrixGroupNC, 
   function ( M )
       local  gensc, genss, V, G;
       V := FieldOfMatrixGroup( M ) ^ DimensionOfMatrixGroup( M );
       gensc := List (GeneratorsOfGroup (M), x -> Permutation (x, V));
       genss := List( Basis( V ), x -> Permutation( x, V, \+));
       G := GroupByGenerators(Concatenation (genss, gensc));
       SetSize( G, Size( M ) * Size( V ) );
       SetSocle (G, Subgroup (G, genss));
       
      # the following sets attributes/properties which are defined 
      # in the CRISP packages

      if IsBoundGlobal ("SetSocleComplement") then
         ValueGlobal ("SetSocleComplement") (G, Subgroup (G, gensc));
      fi;
      if IsBoundGlobal ("SetIsPrimitiveSolvable") then
         ValueGlobal ("SetIsPrimitiveSolvable") (G, true);
      fi;
       return G;
   end);


############################################################################
##
#F  IteratorPrimitiveSolvablePermutationGroups(<func_1>, <val_1>, ...)
##
##  see the IRREDSOL manual
##  
InstallGlobalFunction (IteratorPrimitiveSolvablePermutationGroups,
   function (arg)
      return DoIteratorPrimitiveSolvableGroups (
         PrimitivePermutationGroupIrreducibleMatrixGroupNC,
         arg);
   end);
   

###########################################################################
##
#F  AllPrimitiveSolvablePermutationGroups(<arg>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (AllPrimitiveSolvablePermutationGroups,
   function (arg)
   
      local iter, l, G;
      
      iter := CallFuncList (IteratorPrimitiveSolvablePermutationGroups, arg);
      
      l := [];
      for G in iter do
         Add (l, G);
      od;
      return l;
   end);


###########################################################################
##
#F  OnePrimitiveSolvablePermutationGroup(<arg>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (OnePrimitiveSolvablePermutationGroup,
   function (arg)
   
      local iter;
      
      iter := CallFuncList (IteratorPrimitiveSolvablePermutationGroups, arg);
      if IsDoneIterator (iter) then
         return fail;
      else 
         return NextIterator (iter);
      fi;
   end);


###########################################################################
##
#F  IdPrimitiveSolvableGroup(<grp>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (IdPrimitiveSolvableGroup,
   G -> IdIrreducibleSolvableMatrixGroup (IrreducibleMatrixGroupPrimitiveSolvableGroup (G)));


###########################################################################
##
#F  IdPrimitiveSolvableGroupNC(<grp>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (IdPrimitiveSolvableGroupNC,
   G -> IdIrreducibleSolvableMatrixGroup (IrreducibleMatrixGroupPrimitiveSolvableGroupNC (G)));


############################################################################
##
#E
##
         
      
      

   
