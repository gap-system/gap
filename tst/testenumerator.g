#############################################################################
##
#F  TestConsistencyOfEnumeratorByFunctions( <enum> )
##
##  This (currently undocumented) function is thought for checking newly
##  implemented enumerators in `IsEnumeratorByFunctions'.
##  Whenever a test fails then a message about this is printed, and `false'
##  is returned in the end.
##  If no obvious errors are found then `true' is returned.
##  (Note that for enumerators of length up to 1000, also access to too large
##  positions is checked.)
##
BindGlobal( "TestConsistencyOfEnumeratorByFunctions", function( enum )
    local bound, filter, result, origlevel, elm, len, list;

    bound:= 1000;
    filter:= IsEnumeratorByFunctions;
    if not filter( enum ) then
      Print( "#E  enumerator is not in `IsEnumeratorByFunctions'\n" );
      return false;
    fi;
    result:= true;

    # Switch off warnings.
    origlevel:= InfoLevel( InfoWarning );
    SetInfoLevel( InfoWarning, 0 );

    # Check that the right methods are used.
    elm:= enum[1];
    if not IsIdenticalObj( ApplicableMethod( Position, [ enum, elm, 0 ] ),
               ApplicableMethodTypes( Position, [ filter, IsObject,
                   IsZeroCyc ] ) ) then
      Print( "#E  wrong `Position' method\n" );
      result:= false;
    fi;
    if not IsIdenticalObj( ApplicableMethod( \[\], [ enum, 1 ] ),
               ApplicableMethodTypes( \[\], [ filter, IsPosInt ] ) ) then
      Print( "#E  wrong `\\[\\]' method\n" );
      result:= false;
    fi;
    if not IsIdenticalObj( ApplicableMethod( IsBound\[\], [ enum, 1 ] ),
               ApplicableMethodTypes( IsBound\[\], [ filter, IsPosInt ] ) )
       then
      Print( "#E  wrong `IsBound\\[\\]' method\n" );
      result:= false;
    fi;
    if not IsIdenticalObj( ApplicableMethod( Length, [ enum ] ),
               ApplicableMethodTypes( Length, [ filter ] ) ) and
       not HasLength( enum ) then
      Print( "#E  wrong `Length' method\n" );
      result:= false;
    fi;
    if not IsIdenticalObj( ApplicableMethod( \in, [ elm, enum ] ),
               ApplicableMethodTypes( \in, [ IsObject, filter ] ) ) then
      Print( "#E  wrong `\\in' method\n" );
      result:= false;
    fi;
    if not IsIdenticalObj( ApplicableMethod( ViewObj, [ enum ] ),
               ApplicableMethodTypes( ViewObj, [ filter ] ) ) then
      Print( "#E  wrong `ViewObj' method\n" );
      result:= false;
    fi;
    if not IsIdenticalObj( ApplicableMethod( PrintObj, [ enum ] ),
               ApplicableMethodTypes( PrintObj, [ filter ] ) ) then
      Print( "#E  wrong `PrintObj' method\n" );
      result:= false;
    fi;

    # Check that the results computed by the methods are reasonable.
    len:= bound;
    if Length( enum ) < len then
      len:= Length( enum );
    fi;
    list:= List( [ 1 .. len ], i -> enum[i] );
    if List( list, x -> Position( enum, x ) ) <> [ 1 .. len ] then
      Print( "#E  `\\[\\]' and `Position' of <enum> do not fit together\n" );
      result:= false;
    fi;
    if not ForAll( list, x -> x in enum ) then
      Print( "#E  `\\[\\]' and `\\in' of <enum> do not fit together\n" );
      result:= false;
    fi;

    if ForAny( list, IsMutable ) then
      Print( "#E  the elements of <enum> must be immutable\n" );
      result:= false;
    fi;
    if HasIsSSortedList( enum ) and IsSSortedList( enum ) then
      if not IsSSortedList( list ) then
        Print( "#E  <enum> is not sorted\n" );
        result:= false;
      fi;
    fi;

    # Reset the info level.
    SetInfoLevel( InfoWarning, origlevel );
    return result;
end );
