# 2005/05/03 (BH)
gap> if LoadPackage("crisp", false) <> fail then
>      F:=FreeGroup("a","b","c");;
>      a:=F.1;;b:=F.2;;c:=F.3;;
>      G:=F/[a^12,b^2*a^6,c^2*a^6,b^-1*a*b*a,c^-1*a*c*a^-7,c^-1*b*c*a^-9*b^-1];;
>      pcgs := PcgsElementaryAbelianSeries (G);;
>      ser := ChiefSeries (G);;
>      if ForAny (ser, H -> ParentPcgs (InducedPcgs (pcgs, H))
>                           <> ParentPcgs (pcgs)) then
>        Print( "problem with crisp (1)\n" );
>      fi;
>      if ForAny (ser, H -> ParentPcgs (InducedPcgsWrtHomePcgs (H))
>                           <>  ParentPcgs(HomePcgs (H))) then
>        Print( "problem with crisp (2)\n" );
>      fi;
>      if ForAny (ser, H -> ParentPcgs (InducedPcgsWrtHomePcgs (H))
>                           <> HomePcgs (H)) then
>        Print( "problem with crisp (3)\n" );
>      fi;
>      G2:=Image(IsomorphismPermGroup(G));
>      pcgs := PcgsElementaryAbelianSeries (G2);
>      ser := ChiefSeries (G2);
>      if ForAny (ser, H -> ParentPcgs (InducedPcgs (pcgs, H))
>                           <> pcgs) then
>        Print( "problem with crisp (4)\n" );
>      fi;
>      if ForAny (ser, H -> ParentPcgs (InducedPcgsWrtHomePcgs (H))
>                           <> ParentPcgs(HomePcgs (H))) then
>        Print( "problem with crisp (5)\n" );
>      fi;
>      if ForAny (ser, H -> ParentPcgs (InducedPcgsWrtHomePcgs (H))
>                           <> HomePcgs (H)) then
>        Print( "problem with crisp (6)\n" );
>      fi;
>    fi;
