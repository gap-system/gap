############################################################################
##
##  recognizeprim.gi              IRREDSOL                  Burkhard Höfling
##
##  @(#)$Id: recognizeprim.gi,v 1.1 2011/05/18 16:40:29 gap Exp $
##
##  Copyright © Burkhard Höfling (burkhard@hoefling.name)
##


###########################################################################
##
#F  IdPrimitiveSolvableGroup(<grp>)
##
##  see IRREDSOL documentation
##  
InstallMethod (IdPrimitiveSolvableGroup, "for solvable group",
     true, [IsSolvableGroup and IsFinite], 0,
     G -> IdIrreducibleSolvableMatrixGroup (IrreducibleMatrixGroupPrimitiveSolvableGroup (G)));


RedispatchOnCondition (IdPrimitiveSolvableGroup, true, [IsGroup], 
     [IsFinite and IsSolvableGroup], 0);


###########################################################################
##
#F  IdPrimitiveSolvableGroupNC(<grp>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (IdPrimitiveSolvableGroupNC,
     function(G)
          local id;
          id := IdIrreducibleSolvableMatrixGroup (IrreducibleMatrixGroupPrimitiveSolvableGroupNC (G));
          SetIdPrimitiveSolvableGroup (G, id);
          return id;
     end);
     

############################################################################
##
#F  RecognitionPrimitiveSolvableGroup(<G>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (RecognitionPrimitiveSolvableGroup,
    function (G, wantiso)
    
        local N, F, p, pcgsN, C, pcgsC, one, i, mat, mats, CC, H, hom, infomat, info, rep, ext, imgs, g, r;
        
        N := FittingSubgroup (G);
        
        pcgsN := Pcgs (N);
        p := Set (RelativeOrders (pcgsN));
        if Length (p) <> 1 then
            Error ("G must be primitive");
        fi;
        
        p := p[1];
        
        if not IsAbelian (N) or ForAny (pcgsN, g -> g^p <> One(G)) then
            Error ("G must be primitive");
        fi;
        
        # now we know that N is elementary abelian of exponent p
        
        F := GF(p); 
        one := One (F);
        
        mats := [];
        
        C := Complementclasses (G, N);
        if Length (C) <> 1 then
          Error ("G must be primitive");
        fi;
        
        C := C[1];
        
        # N is complemented
        
        pcgsC := Pcgs (C);
        for g in pcgsC do
            mat := [];
            for i in [1..Length (pcgsN)] do
                mat[i] := ExponentsOfPcElement (pcgsN, pcgsN[i]^g)*one;
            od;
            Add (mats, ImmutableMatrix (F, mat));
        od;
        
        if not MTX.IsIrreducible (GModuleByMats (mats, F)) then
            Error ("G must be primitive");
        fi;
        
        H := Group (mats);
        
        # the recognition part works best if the source of the representation isomorphism is a pc group
                
        if IsPcGroup (C) then
            CC := C;
        else
            CC := PcGroupWithPcgs (Pcgs(C));
        fi;
        
        SetSize (H, Size (C));
        hom := GroupGeneralMappingByImages (CC, H, Pcgs(CC), mats);
        SetIsGroupHomomorphism (hom, true);
        SetIsBijective (hom, true);
        SetRepresentationIsomorphism (H, hom);

        infomat := RecognitionIrreducibleSolvableMatrixGroup (H, wantiso, wantiso, wantiso);

        info := rec (id := infomat.id);
        if not wantiso then
            return info;
        fi;

        rep := RepresentationIsomorphism (infomat.group);
        
        ext := PcGroupExtensionByMatrixAction (Pcgs (Source(rep)), rep);
        
        imgs := [];
        for g in Pcgs (CC) do
            Add (imgs, ImageElm (ext.embed, ImageElm (infomat.iso, g)));
        od;
        for r in infomat.mat do
            g := PcElementByExponents (ext.pcgsV, List (r, IntFFE));
            Add (imgs, g);
        od;
        
        info.group := ext.E;
        info.iso := GroupHomomorphismByImages (G, ext.E, 
            Concatenation (pcgsC, pcgsN), imgs);
        if info.iso = fail or not IsBijective (info.iso) then
            Error ("wrong group homomorphism");
        fi;
        return info;
    end);
             

############################################################################
##
#E
##

    