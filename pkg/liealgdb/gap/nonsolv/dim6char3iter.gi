InstallGlobalFunction( LieAlgDBParListIteratorDimension6Characteristic3,
    "function for LieAlgDBCollections",
        function( F, dim, param )
    
    return Objectify( NewType( IteratorsFamily,
                   IsIterator and IsMutable
                   and IsLieAlgDBParListIteratorDimension6Characteristic3CompRep ),
                   rec( counter := 0,
                        param := param,
                        dim := dim,
                        field := F ));
end );

InstallMethod( IsDoneIterator,
        "for LieAlgDBParListIterators",
        [ IsIterator and IsLieAlgDBParListIteratorDimension6Characteristic3CompRep ],
        function( iter )
    return iter!.param = "done";
end );

InstallMethod( NextIterator, 
        "for LieAlgDBParListIterators",
        [ IsMutable and IsIterator and IsLieAlgDBParListIteratorDimension6Characteristic3CompRep ],
        0,
        function( iter )
    local x, F, eF, oldpar, z, list1, list2, list3, pos;
    
    if IsDoneIterator( iter ) then
        Error( "this iterator is exhausted" );
    fi;
    
    iter!.counter := iter!.counter + 1;
    oldpar := ShallowCopy( iter!.param );
    F := iter!.field;
    eF := Enumerator( F );
    
    list1 := [[6,1],[6,2],[6,3,1],[6,3,2]];
    list2 := [[6,3,4,Zero(F)],[6,3,4,Z(Size(F))],[6,3,4,One(F)],
              [6,4],[6,5],[6,6],[6,7]];
    list3 := [[6,9],[6,10],[6,11,0],[6,11,1],[6,12],[6,13], "done" ];
    
    if iter!.param in list1 then
        pos := Position( list1, iter!.param );
        if pos <= 3 then
            iter!.param := list1[pos+1];
        else
            iter!.param := [6,3,3,eF[1]];
        fi;
    elif Length( iter!.param ) >= 3 and iter!.param{[1,2,3]} = [6,3,3] then
        pos := Position( eF, iter!.param[4] );
        if pos < Size( F ) then
            iter!.param := [6,3,3,eF[pos+1]];
        else
          iter!.param := list2[1];
        fi;
    elif iter!.param in list2 then
        pos := Position( list2, iter!.param );
        if pos <= 6 then
            iter!.param := list2[pos+1];
        else
            iter!.param := [6,8,-1];
        fi;
    elif iter!.param{[1,2]} = [6,8] then
        x := Indeterminate( F );
        z := First( [iter!.param[3]+1..Size( F )-1],
                    z->not IsIrreducible( x^3+x^2-Z(Size( F ))^z ));
        if z <> fail then
            iter!.param := [6,8,z];
        else
            iter!.param := list3[1];
        fi;
    elif iter!.param in list3	 then
        pos := Position( list3, iter!.param );
        iter!.param := list3[pos+1];
  fi;
  
  return oldpar;
end );	

InstallMethod( ShallowCopy,
        "for LieAlgDBParListIterators",
        [ IsIterator and IsLieAlgDBParListIteratorDimension6Characteristic3CompRep ],
        function( iter )
    return rec(
               counter := iter!.counter,
               dim := iter!.dim,
               field := iter!.field,
               param := iter!.param );
end );
