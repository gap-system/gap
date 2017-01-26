# 2005/06/23 (AH)
gap> if LoadPackage("crisp", false) <> fail then
>     h:=Source(EpimorphismSchurCover(SmallGroup(64,150)));
>     NormalSubgroups( Centre( h ) );
>     fi;
