# from paragraph [ 3, 1, 0, 4 ][ "/Users/alexk/gap4r5/pkg/openmath/doc/extend.xml", 23 ]


gap> Display( OMsymRecord.nums1 );          
rec(
  NaN := "nan",
  based_integer := fail,
  e := fail,
  gamma := fail,
  i := E(4),
  infinity := infinity,
  pi := fail,
  rational := function ( x )
        return OMgapId( [ OMgap2ARGS( x ), x[1] / x[2] ] )[2];
    end )


# from paragraph [ 3, 1, 0, 10 ][ "/Users/alexk/gap4r5/pkg/openmath/doc/extend.xml", 64 ]


gap> OMPrint( [ [1..10], ZmodnZObj(2,6), (1,2) ] );                
<OMOBJ>
	<OMA>
		<OMS cd="list1" name="list"/>
		<OMA>
			<OMS cd="interval1" name="integer_interval"/>
			<OMI>1</OMI>
			<OMI>10</OMI>
		</OMA>
		<OMA>
			<OMS cd="integer2" name="class"/>
			<OMI>2</OMI>
			<OMI>6</OMI>
		</OMA>
		<OMA>
			<OMS cd="permut1" name="permutation"/>
			<OMI>2</OMI>
			<OMI>1</OMI>
		</OMA>
	</OMA>
</OMOBJ>


