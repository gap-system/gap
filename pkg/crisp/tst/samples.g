############################################################################
##
##  samples.g                       CRISP                 Burkhard H\"ofling
##
##  @(#)$Id: samples.g,v 1.7 2011/05/18 16:53:58 gap Exp $
##
##  Copyright (C) 2000 by Burkhard H\"ofling, Mathematisches Institut,
##  Friedrich Schiller-Universit\"at Jena, Germany
##
groups:= [
    function (  )
        local G;
        G := TrivialGroup( IsPcGroup);
        SetName (G, "trivial pc group");
        return G;
    end, 
    function (  )
        local G;
        G :=  TrivialGroup( IsPermGroup);
        SetName (G, "trivial perm group");
        return G;
    end, 
    function (  )
        local G;
        G :=  Group ([], IdentityMat (4, GF(25)));
        SetName (G, "trivial mat group");
        return G;
    end, 
    function (  )
        local G;
        G := SmallGroup (48,29);
        SetName (G, "GL(2,3) as pc group");
        return G;
    end,
    function (  )
        local G;
        G :=  SymmetricGroup( 4 );
        SetName (G, "Sym(4)");
        return G;
    end, 
    function (  )
        local G;
        G :=  DihedralGroup( 10 );
        SetName (G, "Dih(10)");
        return G;
    end, 
    function (  )
        local G;
        G :=  GL( 2, 3 );
        SetName (G, "GL(2,3)");
        return G;
    end,
    function (  )
        local G;
        G :=  FibonacciGroup( 3, 5 );
        SetName (G, "Fib(3,5) = C2 x C11");
        return G;
    end,
    function ( )
        local G;
        G := AutomorphismGroup (AlternatingGroup (4));
        SetName (G, "Aut(Alt(4)) = Sym(4)");
        return G;
    end,
    function ( )
        local G;
        G := DirectProduct (CyclicGroup (2), CyclicGroup (3), SymmetricGroup (4));
        SetName (G, "C2 x C3 x S4");
        return G;
    end
];

groups := groups{[1..Length(groups)-3]}; 
   
insolvgroups:= [ function (  )
        return SymmetricGroup( 5 );
    end, 
    function (  )
        return GL(2,5);
    end,
    function (  )
    	return WreathProduct (CyclicGroup (IsPermGroup, 5), SymmetricGroup (5));
    end,
    function ( )
        return AutomorphismGroup (AbelianGroup ([5,5]));
    end]; 
  
25grps := PiGroups ([2,5]);

if not IsBound (InfoTest) then
   DeclareInfoClass ("InfoTest");
fi;

classes := function ()
    local cl, C;
    cl := [];
   
    C := SchunckClass (rec (bound := BoundaryFunction (25grps)));
    SetName (C, "[2,5]-grps by boundary");
    Add (cl, C);
    C := SaturatedFormation (rec (locdef := LocalDefinitionFunction (25grps)));
    SetName (C, "[2,5]-grps by locdef");
    Add (cl, C);
    C := GroupClass (rec (\in := MemberFunction (25grps)));
    SetName (C, "[2,5]-grps by membersip");
    Add (cl, C);
    C := OrdinaryFormation (rec (
        res := function (G)
            local pi;
            pi := Difference (Set (Factors (Size (G))), [1,2,5]);
            return NormalClosure (G, HallSubgroup (G, pi));
        end));
    SetName (C, "[2,5]-grps by res");
    Add (cl, C);
    C := FittingClass (rec (rad := G -> Core (G, HallSubgroup (G, [2,5]))));
    SetName (C, "[2,5]-grps by rad");
    Add (cl, C);
    C := FittingClass (rec (inj := InjectorFunction (25grps)));
    SetName (C, "[2,5]-grps by inj");
    Add (cl, C);
    C := SchunckClass (rec (proj:= ProjectorFunction (25grps)));
    SetName (C, "[2,5]-grps by proj");
    Add (cl, C);
    return cl;
end;


############################################################################
##
#E
##
