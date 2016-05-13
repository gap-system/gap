#############################################################################
##
#W  bugfix.tst
##
##
gap> START_TEST("bugfix.tst");
#############################################################################
#
# Tests requiring loading some packages must be performed at the end.
# Do not put tests that do not need any packages below this line.
#
#############################################################################
#
# Tests requiring TomLib

##  bug 2 for fix 6
gap> if LoadPackage("tomlib", false) <> fail then
>      DerivedSubgroupsTom( TableOfMarks( "A10" ) ); 
>    fi;

#############################################################################
#
# Tests requiring CTblLib

# 2005/08/29 (TB)
gap> LoadPackage("ctbllib", "=0.0",false);
fail

##  Bug 18 for fix 4
gap> if LoadPackage("ctbllib", false) <> fail then
>      if Irr( CharacterTable( "WeylD", 4 ) )[1] <>
>           [ 3, -1, 3, -1, 1, -1, 3, -1, -1, 0, 0, -1, 1 ] then
>        Print( "problem with Irr( CharacterTable( \"WeylD\", 4 ) )[1]\n" );
>      fi;
>    fi;

# 2005/08/23 (TB)
gap> tbl:= CharacterTable( ElementaryAbelianGroup( 4 ) );;
gap> IsElementaryAbelian( tbl );
true
gap> ClassPositionsOfMinimalNormalSubgroups( tbl );
[ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ] ]
gap> if LoadPackage("ctbllib", false) <> fail then
>      tbl:= CharacterTableIsoclinic( CharacterTable( "2.A5.2" ) );
>      if tbl mod 3 = fail then
>        Error( CharacterTable( "Isoclinic(2.A5.2)" ), " mod 3" );
>      fi;
>      SourceOfIsoclinicTable( tbl );
>    fi;
gap> tbl:= CharacterTable( Group( () ) );;
gap> ClassPositionsOfElementaryAbelianSeries( tbl );;

# 2005/10/29 (TB)
gap> if LoadPackage("ctbllib", false) <> fail then
>      t:= CharacterTable( "S12(2)" );  p:= PrevPrimeInt( Exponent( t ) );
>      if not IsSmallIntRep( p ) then
>        PowerMap( t, p );
>      fi;
>    fi;

# 2005/12/08 (TB)
gap> if LoadPackage("ctbllib", false) <> fail then
>      if List( Filtered( Irr( CharacterTable( "Sz(8).3" ) mod 3 ),
>                         x -> x[1] = 14 ), ValuesOfClassFunction )
>         <> [ [ 14, -2, 2*E(4), -2*E(4), -1, 0, 1 ],
>              [ 14, -2, -2*E(4), 2*E(4), -1, 0, 1 ] ] then
>        Print( "ordering problem in table of Sz(8).3 mod 3\n" );
>      fi;
>    fi;

# 2005/12/08 (TB)
gap> LoadPackage("ctbllib", false);;
gap> t:= CharacterTable( SymmetricGroup( 4 ) );;
gap> SetIdentifier( t, "Sym(4)" );  Display( t,
>     rec( powermap:= "ATLAS", centralizers:= "ATLAS", chars:= false ) );
Sym(4)

    24  4  8  3  4

 p      A  A  A  B
 p'     A  A  A  A
    1A 2A 2B 3A 4A

#############################################################################
#
# Tests requiring Crisp

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

# 2005/06/23 (AH)
gap> if LoadPackage("crisp", false) <> fail then
>     h:=Source(EpimorphismSchurCover(SmallGroup(64,150)));
>     NormalSubgroups( Centre( h ) );
>     fi;

# 2005/10/14 (BH)
gap> if LoadPackage("crisp", "1.2.1", false) <> fail then
>     G := DirectProduct(CyclicGroup(2), CyclicGroup(3), SymmetricGroup(4));
>     AllInvariantSubgroupsWithQProperty (G, G, ReturnTrue, ReturnTrue, rec());
>     if ( (1, 5) in EnumeratorByPcgs ( Pcgs( SymmetricGroup (4) ) ) ) then
>      Print( "problem with crisp (7)\n" );
>     fi;
>    fi;

# 2012/06/18 (FL)
gap> if LoadPackage("cvec",false) <> fail then mat := [[Z(2)]];
> ConvertToMatrixRep(mat,2); cmat := CMat(mat); cmat := cmat^1000; fi;

# 2012/06/18 (MH)
gap> if LoadPackage("anupq",false) <> fail then
> for i in [1..192] do Q:=Pq( FreeGroup(2) : Prime:=3, ClassBound:=1 ); od; fi;

gap> STOP_TEST( "bugfix.tst", 831990000);

#############################################################################
##
#E
