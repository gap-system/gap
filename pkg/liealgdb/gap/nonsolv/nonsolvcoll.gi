InstallMethod( AllNonSolvableLieAlgebras,
        "for a finite field and a positive integer",
        true,
        [ IsField and IsFinite,  IsPosInt ], 
        0,
        function( F, dim )
    
    local R, fam, parlist;
  
    # Construct the family of element objects of our ring.
    
    if not ( IsField( F ) and IsFinite( F ) and dim in [ 1, 2, 3, 4, 5, 6 ]) then
        Error( "Non-solvable Lie algebras are only included over finite  fields and dimension at most 6." );
    fi;
        
    if dim in [1,2] then return []; fi;
        
    if dim = 3 then
        parlist := [[3]];
    elif dim = 4 and Characteristic( F ) = 2 then
         parlist := [[4,1],[4,2]];
    elif dim = 4 and Characteristic( F ) > 2 then
        parlist := [[4]];
    elif dim = 5 and Characteristic( F ) = 2 then
        parlist := [[5,1],[5,2,0],[5,2,1],[5,3,0],[5,3,1]];
    elif dim = 5 and Characteristic( F ) in [3,5] then
        parlist := [[5,1,0],[5,1,1],[5,2],[5,3]];
    elif dim = 5 and Characteristic( F ) >= 7 then
        parlist := [[5,1,0],[5,1,1],[5,2]];
    elif dim = 6 and Characteristic( F ) = 2 then
        parlist := EnumeratorByFunctions( 
                           NewFamily( IsList ),
                           rec( 
                                NumberElement := 
                                function( e, x )
            local list1, list2, list3;
            
            list1 := [[6,1],[6,2],[6,3,0],[6,3,1],[6,4,0],[6,4,1],[6,4,2],
                        [6,4,3]];
            list2 := [[6,5],[6,6,1],[6,6,2]];
            list3 := [[6,6,4,Zero(F)],[6,6,4,One(F)],[6,7],[6,8]];
            
            if x in list1 then 
                return Position( list1, x );
            elif x[1] = 6 and x[2] = 4 then
                return Position( Enumerator( F ), x[3] )+7;
            elif x in list2 then
                return Position( list2, x ) + 7 + Size( F );
            elif x[1] = 6 and x[2] = 6 and x[3] = 3 then
                return Position( Enumerator( F ), x[4] ) + 10 + Size( F );
            elif x in list3 then
                return Position( list3, x ) + 10 + 2*Size( F );
            else
                return fail;
            fi; end,
              
              ElementNumber := function( e, n )
                local list1, list2, list3;
                
                list1 := [[6,1],[6,2],[6,3,0],[6,3,1],[6,4,0],[6,4,1],[6,4,2],
                            [6,4,3]];
                list2 := [[6,5],[6,6,1],[6,6,2]];
                list3 := [[6,6,4,Zero(F)],[6,6,4,One(F)],[6,7],[6,8]];
                
                if n <= 8 then
                    return list1[n];
                elif n>=9 and n<=7+Size( F ) then
                    return [6,4,Enumerator( F )[n-7]];
                elif n>=8+Size( F ) and n<=10+Size( F ) then
                    return list2[n-7-Size( F )];
                elif n>=11+Size( F ) and n<=10+2*Size( F ) then
                    return [6,6,3,Enumerator( F )[n-10-Size( F )]];
                elif n>=11+2*Size( F ) and n <= 14+2*Size( F ) then
                    return list3[n-10-2*Size( F )];
                fi; end,
                  Length := function( x )
                    return 14+2*Size( F ); end ));

		    
        elif dim = 6 and Characteristic( F ) = 3 then
            parlist := LieAlgDBParListIteratorDimension6Characteristic3( F, dim, [6,1] );
            
        elif dim = 6 and Characteristic( F ) = 5 then
            parlist := EnumeratorByFunctions( 
                               NewFamily( IsList ),
                               rec( 
                                    NumberElement := 
                                    function( e, x )
                local list1, list2;
                
                list1 := [[6,1],[6,2],[6,3,1],[6,3,2]];
                list2 := [[6,3,4,Zero(F)],[6,3,4,Z(Size(F))],[6,3,4,One(F)],
                          [6,4],[6,5],[6,6],[6,7],[6,8],[6,9]];            
                
                if x in list1 then 
                    return Position( list1, x );
                elif x[1] = 6 and x[2] = 3 and x[3] = 3 then
                    return Position( Enumerator( F ), x[4] )+4;
                elif x in list2 then
                    return Position( list2, x ) + 4 + Size( F );
                else
                    return fail;
                fi; end,
                  
                  ElementNumber := function( e, n )
                    local list1, list2;
                    
                    list1 := [[6,1],[6,2],[6,3,1],[6,3,2]];
                    list2 := [[6,3,4,Zero(F)],[6,3,4,Z(Size(F))],[6,3,4,One(F)],
                              [6,4],[6,5],[6,6],[6,7],[6,8],[6,9]];            
                    
                    if n <= 4 then
                        return list1[n];
                    elif n>=5 and n<=4+Size( F ) then
                        return [6,3,3,Enumerator( F )[n-4]];
                    elif n>=5+Size( F ) and n<=13+Size( F ) then
                        return list2[n-4-Size( F )];
                    fi; end,
                      Length := function( x )
                        return 13+Size( F ); end ));
                    elif dim = 6 and Characteristic( F ) >= 7 then
                        parlist := EnumeratorByFunctions( 
                                           NewFamily( IsList ),
                                           rec( 
                                                NumberElement := 
                                                function( e, x )
                            local list1, list2;
                            
                            list1 := [[6,1],[6,2],[6,3,1],[6,3,2]];
                            list2 := [[6,3,4,Zero(F)],[6,3,4,Z(Size(F))],[6,3,4,One(F)],
                                      [6,4],[6,5],[6,6],[6,7]];            
                            
                            if x in list1 then 
                                return Position( list1, x );
                            elif x[1] = 6 and x[2] = 3 and x[3] = 3 then
                                return Position( Enumerator( F ), x[4] )+4;
                            elif x in list2 then
                                return Position( list2, x ) + 4 + Size( F );
                            else
                                return fail;
                            fi; end,
                              
                              ElementNumber := function( e, n )
                                local list1, list2;
                                
                                list1 := [[6,1],[6,2],[6,3,1],[6,3,2]];
                                list2 := [[6,3,4,Zero(F)],[6,3,4,Z(Size(F))],[6,3,4,One(F)],
                                          [6,4],[6,5],[6,6],[6,7]];            
                                
                                if n <= 4 then
                                    return list1[n];
                                elif n>=5 and n<=4+Size( F ) then
                                    return [6,3,3,Enumerator( F )[n-4]];
                                elif n>=5+Size( F ) and n<=11+Size( F ) then
                                    return list2[n-4-Size( F )];
                                fi; end,
                                  Length := function( x )
                                    return 11+Size( F ); end ));
                                fi;
        # Make the domain.
                                R := rec( field := F,
                                          dim := dim,
                                          type := "NonSolvable",
                                          parlist := parlist );
                                fam := NewFamily( IsLieAlgDBCollection_NonSolvable );
                                
                                R := Objectify( NewType( fam, IsLieAlgDBCollection_NonSolvable ), R );
                                return R;
end );

InstallMethod( AsList, 
        "method for LieAlgDBCollections",
        [ IsLieAlgDBCollection_NonSolvable ],
        function( R )
    local i, l, list;
    
    if IsEnumeratorByFunctions( Enumerator( R )) then    
        TryNextMethod();		 
    fi;
    
    i := Iterator( R );
    list := [];
    for l in i do
        Add( list, l );
    od;
    
    return list;
end);

InstallMethod(	Enumerator,
        "method for LieAlgDBCollections",
        [ IsLieAlgDBCollection_NonSolvable ],
        function( R )
    
    if not IsEnumeratorByFunctions( R!.parlist ) and not
       IsList( R!.parlist ) then
        return fail;
    else
        return EnumeratorByFunctions( NewFamily( 
                       CategoryCollections( IsLieAlgebra )), 
                       rec( 
                       ElementNumber := function( e, n )
            return NonSolvableLieAlgebra( R!.field, R!.parlist[n] );
        end, 
          NumberElement := function( e, x )
            return Position( R!.parlist, x!.arg );
        end,
          Length := function( x ) return Length( R!.parlist ); end ));
    fi;
end );

InstallMethod( Iterator,
        "method for LieAlgDBCollections",
        [ IsLieAlgDBCollection_NonSolvable ],
        function( R )
    
    if IsEnumeratorByFunctions( R!.parlist ) or IsList( R!.parlist ) then
        TryNextMethod();
    elif IsIterator( R!.parlist ) then
        R!.parlist := LieAlgDBParListIteratorDimension6Characteristic3( R!.field, R!.dim, [6,1] );
        return
          IteratorByFunctions( rec( 
                  NextIterator := function( iter )
            return NonSolvableLieAlgebra( R!.field, 
                           NextIterator( R!.parlist ));
        end,
          IsDoneIterator := function( iter )
            return IsDoneIterator( R!.parlist );
        end,
          ShallowCopy := function( iter )
            return fail;
        end ));
    fi;
end );
