# 2005/10/14 (BH)
gap> if LoadPackage("crisp", "1.2.1", false) <> fail then
>     G := DirectProduct(CyclicGroup(2), CyclicGroup(3), SymmetricGroup(4));
>     AllInvariantSubgroupsWithQProperty (G, G, ReturnTrue, ReturnTrue, rec());
>     if ( (1, 5) in EnumeratorByPcgs ( Pcgs( SymmetricGroup (4) ) ) ) then
>      Print( "problem with crisp (7)\n" );
>     fi;
>    fi;
