#############################################################################
##
##  excluded from 'testinstall.g' as it takes considerable time
##
#@local tmpSolvableResiduum, n, i, g, t, l

#
gap> START_TEST( "ctbl.tst" );

##
gap> tmpSolvableResiduum:= function( G )
>      local iso;
>      if Size( G ) = 1 then  # bug in 'SQ'
>        return G;
>      elif IsSolvable( G ) then
>        return TrivialSubgroup( G );
>      fi;
>      iso:= IsomorphismFpGroup( G );
>      return PreImages( iso, Kernel(
>        EpimorphismSolvableQuotient( ImagesSource( iso ), Size( G ) ) ) );
>    end;;
gap> for n in [ 1 .. 150 ] do
>      for i in [ 1 .. NumberSmallGroups( n ) ] do
>        g:= SmallGroup( n, i );
>        t:= CharacterTable( g );
>        if NormalSubgroupClasses( t, ClassPositionsOfCentre( t ) )
>           <> Centre( g ) then
>          Error( "ClassPositionsOfCentre?" );
>        fi;
>        if NormalSubgroupClasses( t, ClassPositionsOfDerivedSubgroup( t ) )
>           <> DerivedSubgroup( g ) then
>          Error( "ClassPositionsOfDerivedSubgroup?" );
>        fi;
>        if NormalSubgroupClasses( t, ClassPositionsOfFittingSubgroup( t ) )
>           <> FittingSubgroup( g ) then
>          Error( "ClassPositionsOfFittingSubgroup?" );
>        fi;
>        if NormalSubgroupClasses( t, ClassPositionsOfSolvableResiduum( t ) )
>           <> tmpSolvableResiduum( g ) then
>          Error( "ClassPositionsOfSolvableResiduum?" );
>        fi;
>        if NormalSubgroupClasses( t, ClassPositionsOfSupersolvableResiduum( t ) )
>           <> SupersolvableResiduum( g ) then
>          Error( "ClassPositionsOfSupersolvableResiduum?" );
>        fi;
>        if List( ClassPositionsOfLowerCentralSeries( t ),
>                 l -> NormalSubgroupClasses( t, l ) )
>           <> LowerCentralSeries( g ) then
>          Error( "ClassPositionsOfLowerCentralSeries?" );
>        fi;
>        l:= Reversed( UpperCentralSeries( g ) );
>        if 1 < Length( l ) then
>          Remove( l, 1 );
>        fi;
>        if List( ClassPositionsOfUpperCentralSeries( t ),
>                 l -> NormalSubgroupClasses( t, l ) )
>           <> l then
>          Error( "ClassPositionsOfUpperCentralSeries?" );
>        fi;
>        if SortedList( List( ClassPositionsOfMaximalNormalSubgroups( t ),
>                 l -> NormalSubgroupClasses( t, l ) ) )
>           <> SortedList( MaximalNormalSubgroups( g ) ) then
>          Error( "ClassPositionsOfMaximalNormalSubgroups?" );
>        fi;
>        if SortedList( List( ClassPositionsOfMinimalNormalSubgroups( t ),
>                 l -> NormalSubgroupClasses( t, l ) ) )
>           <> SortedList( MinimalNormalSubgroups( g ) ) then
>          Error( "ClassPositionsOfMinimalNormalSubgroups?" );
>        fi;
>        if not IsAbelian( t ) and
>           SortedList( List( ClassPositionsOfNormalSubgroups( t ),
>                 l -> NormalSubgroupClasses( t, l ) ) )
>           <> SortedList( NormalSubgroups( g ) ) then
>          Error( "ClassPositionsOfNormalSubgroups?" );
>        fi;
>        if ( not IsElementaryAbelian( g ) ) or ( Size( g ) < 128 ) then
>          l:= ClassPositionsOfElementaryAbelianSeries( t );
>          if l = fail then
>            if IsSolvable( g ) then
>              Error( "ClassPositionsOfElementaryAbelianSeries?" );
>            fi;
>          else
>            l:= List( l, x -> NormalSubgroupClasses( t, x ) );
>            if ForAny( [ 1 .. Length( l ) - 1 ],
>                       i -> not IsElementaryAbelian( l[i] / l[ i+1 ] ) ) then
>              Error( "ClassPositionsOfElementaryAbelianSeries?" );
>            fi;
>          fi;
>        fi;
>      od;
>    od;

##
gap> STOP_TEST( "ctbl.tst" );

