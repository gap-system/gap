#@local G, P, ind, kinds, info, series, checkinfo, isEA, isCentral
gap> START_TEST("pcgsseriesinfo.tst");

# the indices returned must describe a normal series refined by the pcgs
# returned, and that series must be of the kind that was asked for
gap> series := info -> List( info.indices,
>      i -> SubgroupByPcgs( GroupOfPcgs( info.pcgs ),
>             InducedPcgsByPcSequence( info.pcgs,
>               info.pcgs{[ i .. Length( info.pcgs ) ]} ) ) );;
gap> isEA := ser -> ForAll( [ 2 .. Length( ser ) ],
>      i -> HasElementaryAbelianFactorGroup( ser[i-1], ser[i] ) );;
gap> isCentral := ser -> ForAll( [ 2 .. Length( ser ) ],
>      i -> IsSubset( ser[i], CommutatorSubgroup( ser[1], ser[i-1] ) ) );;
gap> checkinfo := function( info, prop )
>      local ser;
>      if info.indices[1] <> 1 or
>         Last( info.indices ) <> Length( info.pcgs ) + 1 then
>        return "indices do not start with 1 or do not end with n+1";
>      fi;
>      ser := series( info );
>      if not ForAll( ser, N -> IsNormal( ser[1], N ) ) then
>        return "series is not normal";
>      elif not prop( ser ) then
>        return "series is not of the kind that was asked for";
>      fi;
>      return true;
>    end;;

# pc groups, permutation groups, direct products; the codes are those of
# SmallGroup( 96, 3 ) and SmallGroup( 64, 10 ), spelled out so that this test
# does not need the small groups library
gap> for G in [ DihedralGroup( 16 ), PcGroupCode( 55306968584587147680, 96 ),
>               SylowSubgroup( SymmetricGroup( 8 ), 2 ),
>               DirectProduct( DihedralGroup( 8 ), CyclicGroup( 4 ) ) ] do
>      info := PcgsElementaryAbelianSeriesInfo( G );
>      if checkinfo( info, isEA ) <> true then
>        Error( checkinfo( info, isEA ), " for ", G );
>      elif info.indices <>
>           PcgsSeriesInfo( IsPcgsElementaryAbelianSeries, G ).indices then
>        Error( "tag based dispatch disagrees for ", G );
>      fi;
>    od;

# the central kinds need a nilpotent group; their indices must be the ones of
# the central series, not the ones of some elementary abelian series which
# the same pcgs may also belong to
gap> for G in [ DihedralGroup( 16 ), PcGroupCode( 217336074077211757, 64 ),
>               SylowSubgroup( SymmetricGroup( 8 ), 2 ) ] do
>      for kinds in [ [ PcgsCentralSeriesInfo, IsPcgsCentralSeries,
>                       IndicesCentralNormalSteps ],
>                     [ PcgsPCentralSeriesPGroupInfo,
>                       IsPcgsPCentralSeriesPGroup,
>                       IndicesPCentralNormalStepsPGroup ] ] do
>        info := kinds[1]( G );
>        if checkinfo( info, isCentral ) <> true then
>          Error( checkinfo( info, isCentral ), " for ", G );
>        elif info.indices <> kinds[3]( info.pcgs ) then
>          Error( "indices are not the ones of this kind, for ", G );
>        elif info.indices <> PcgsSeriesInfo( kinds[2], G ).indices then
>          Error( "tag based dispatch disagrees for ", G );
>        fi;
>      od;
>    od;

# an unknown kind is reported as such
gap> PcgsSeriesInfo( IsFinite, DihedralGroup( 8 ) );
Error, no method for series kind IsFinite installed for `PcgsSeriesInfo'

# refining indices, without taking them off the pcgs
gap> P := SylowSubgroup( SymmetricGroup( 8 ), 2 );;
gap> info := PcgsPCentralSeriesPGroupInfo( P );;
gap> IndicesNormalStepsBounded( info.pcgs, info.indices, 2^15 ) = info.indices;
true
gap> ind := IndicesNormalStepsBounded( info.pcgs, info.indices, 2 );;
gap> IsSubset( ind, info.indices ) and Length( ind ) >= Length( info.indices );
true

# that's all, folks
gap> STOP_TEST( "pcgsseriesinfo.tst" );
