#############################################################################
##
#W cong.gi                 The Congruence package                   Ann Dooms
#W                                                               Eric Jespers
#W                                                        Alexander Konovalov
##
#H $Id: cong.gi,v 1.2 2008/05/28 23:58:03 alexk Exp $
##
#############################################################################


#############################################################################
##
## Constructors of congruence subgroups

InstallGlobalFunction( PrincipalCongruenceSubgroup,
    function(n)
    local type, G;
    type := NewType( FamilyObj([[[1,0],[0,1]]]),
                     IsGroup and 
                     IsAttributeStoringRep and 
                     IsFinitelyGeneratedGroup and 
                     IsMatrixGroup and
                     IsCongruenceSubgroup);
    G := rec();                   
    ObjectifyWithAttributes( G, type, 
      DimensionOfMatrixGroup, 2,
      OneImmutable, [[1,0],[0,1]],
      IsIntegerMatrixGroup, true,
      IsFinite, false,
      LevelOfCongruenceSubgroup, n,
	  IsPrincipalCongruenceSubgroup, true,
      IsIntersectionOfCongruenceSubgroups, false,
      IsCongruenceSubgroupGamma0, false, IsCongruenceSubgroupGammaUpper0, false,
      IsCongruenceSubgroupGamma1, false, IsCongruenceSubgroupGammaUpper1, false,
      IsCongruenceSubgroupGammaMN, false );
    return G;
	end);


InstallGlobalFunction( CongruenceSubgroupGamma0,
    function(n)
    local type, G;
    type := NewType( FamilyObj([[[1,0],[0,1]]]),
                     IsGroup and 
                     IsAttributeStoringRep and 
                     IsFinitelyGeneratedGroup and 
                     IsMatrixGroup and
                     IsCongruenceSubgroup);
    G := rec();                   
    ObjectifyWithAttributes( G, type, 
      DimensionOfMatrixGroup, 2,
      OneImmutable, [[1,0],[0,1]],
      IsIntegerMatrixGroup, true,
      IsFinite, false,
      LevelOfCongruenceSubgroup, n,
	  IsPrincipalCongruenceSubgroup, false,
	  IsIntersectionOfCongruenceSubgroups, false,
      IsCongruenceSubgroupGamma0, true,  IsCongruenceSubgroupGammaUpper0, false,
      IsCongruenceSubgroupGamma1, false, IsCongruenceSubgroupGammaUpper1, false,
      IsCongruenceSubgroupGammaMN, false );
    return G;
	end);
	

InstallGlobalFunction( CongruenceSubgroupGammaUpper0,
    function(n)
    local type, G;
    type := NewType( FamilyObj([[[1,0],[0,1]]]),
                     IsGroup and 
                     IsAttributeStoringRep and 
                     IsFinitelyGeneratedGroup and 
                     IsMatrixGroup and
                     IsCongruenceSubgroup);
    G := rec();                   
    ObjectifyWithAttributes( G, type, 
      DimensionOfMatrixGroup, 2,
      OneImmutable, [[1,0],[0,1]],
      IsIntegerMatrixGroup, true,
      IsFinite, false,
      LevelOfCongruenceSubgroup, n,
	  IsPrincipalCongruenceSubgroup, false,
      IsIntersectionOfCongruenceSubgroups, false,
      IsCongruenceSubgroupGamma0, false, IsCongruenceSubgroupGammaUpper0, true,
      IsCongruenceSubgroupGamma1, false, IsCongruenceSubgroupGammaUpper1, false,
      IsCongruenceSubgroupGammaMN, false );
    return G;
	end);	
	
	
InstallGlobalFunction( CongruenceSubgroupGamma1,
    function(n)
    local type, G;
    type := NewType( FamilyObj([[[1,0],[0,1]]]),
                     IsGroup and 
                     IsAttributeStoringRep and 
                     IsFinitelyGeneratedGroup and 
                     IsMatrixGroup and
                     IsCongruenceSubgroup);
    G := rec();                   
    ObjectifyWithAttributes( G, type, 
      DimensionOfMatrixGroup, 2,
      OneImmutable, [[1,0],[0,1]],
      IsIntegerMatrixGroup, true,
      IsFinite, false,
      LevelOfCongruenceSubgroup, n,
	  IsPrincipalCongruenceSubgroup, false,
	  IsIntersectionOfCongruenceSubgroups, false,
      IsCongruenceSubgroupGamma0, false, IsCongruenceSubgroupGammaUpper0, false,
      IsCongruenceSubgroupGamma1, true, IsCongruenceSubgroupGammaUpper1, false,
      IsCongruenceSubgroupGammaMN, false );
    return G;
	end);
	
	
InstallGlobalFunction( CongruenceSubgroupGammaUpper1,
    function(n)
    local type, G;
    type := NewType( FamilyObj([[[1,0],[0,1]]]),
                     IsGroup and 
                     IsAttributeStoringRep and 
                     IsFinitelyGeneratedGroup and 
                     IsMatrixGroup and
                     IsCongruenceSubgroup);
    G := rec();                   
    ObjectifyWithAttributes( G, type, 
      DimensionOfMatrixGroup, 2,
      OneImmutable, [[1,0],[0,1]],
      IsIntegerMatrixGroup, true,
      IsFinite, false,
      LevelOfCongruenceSubgroup, n,
	  IsPrincipalCongruenceSubgroup, false,
	  IsIntersectionOfCongruenceSubgroups, false,
      IsCongruenceSubgroupGamma0, false, IsCongruenceSubgroupGammaUpper0, false,
      IsCongruenceSubgroupGamma1, false, IsCongruenceSubgroupGammaUpper1, true,
      IsCongruenceSubgroupGammaMN, false );
    return G;
	end);
	

InstallGlobalFunction( CongruenceSubgroupGammaMN,
    function(m,n)
    local type, G;
    type := NewType( FamilyObj([[[1,0],[0,1]]]),
                     IsGroup and 
                     IsAttributeStoringRep and 
                     IsFinitelyGeneratedGroup and 
                     IsMatrixGroup and
                     IsCongruenceSubgroup);
    G := rec();                   
    ObjectifyWithAttributes( G, type, 
      DimensionOfMatrixGroup, 2,
      OneImmutable, [[1,0],[0,1]],
      IsIntegerMatrixGroup, true,
      IsFinite, false,
      LevelOfCongruenceSubgroup, m*n,
      LevelOfCongruenceSubgroupGammaMN, [m,n],
	  IsPrincipalCongruenceSubgroup, false,
	  IsIntersectionOfCongruenceSubgroups, false,
      IsCongruenceSubgroupGamma0, false, IsCongruenceSubgroupGammaUpper0, false,
      IsCongruenceSubgroupGamma1, false, IsCongruenceSubgroupGammaUpper1, false,
      IsCongruenceSubgroupGammaMN, true );
    return G;
	end);
		

InstallGlobalFunction( IntersectionOfCongruenceSubgroups,
    function( arg )
    local type, G, H, K, T, arglist, n, i, pos;
    type := NewType( FamilyObj([[[1,0],[0,1]]]),
                     IsGroup and 
                     IsAttributeStoringRep and 
                     IsFinitelyGeneratedGroup and 
                     IsMatrixGroup and
                     IsCongruenceSubgroup);
    if not ForAll( arg, IsCongruenceSubgroup ) then
      Error("Usage : IntersectionOfCongruenceSubgroups( G1, G2, ... GN ) \n");
    fi;
    # First we create a list arglist to eliminate evident repetitions of subgroups.
    # Then we eliminate evident inclusions of one subgroup into another:
    # - since intersection is associative, if we can intersect the group T which
    #   is to be added with another subgroup K already contained in alglist, and
    #   the result is one of the canonical congruence subgroups, we replace K by
    #   the result of intersection of K and T 
    # - we do not add a subgroup T to the list of defining subgroups, if alglist 
    #   already contains another subgroup K such that K is in T. 
    # - if we add to alglist a subgroup T and alglist already contains one or more
    #   subgroups K such that T is in K, we add T and remove all these K.
    arglist := [];
    for H in arg do
      if IsIntersectionOfCongruenceSubgroups(H) then
        for T in DefiningCongruenceSubgroups( H ) do
          pos:=PositionProperty( arglist, K -> 
                 CanReduceIntersectionOfCongruenceSubgroups( K, T ) );
          if pos<>fail then
            arglist[pos]:=Intersection( arglist[pos], T );
          else
            if ForAll( arglist, K -> not CanEasilyCompareCongruenceSubgroups( K, T ) ) and
               ForAll( arglist, K -> not IsSubgroup( T, K ) ) then
              for i in [ 1 .. Length(arglist) ] do
                if IsSubgroup( arglist[i], T ) then
                  Unbind( arglist[i] );
                fi;
              od;
              arglist := Compacted( arglist );    
              Add( arglist, T );
            fi;    
          fi;
        od;
      else
        pos:=PositionProperty( arglist, K -> 
               CanReduceIntersectionOfCongruenceSubgroups( K, H ) );
        if pos<>fail then
          arglist[pos]:=Intersection( arglist[pos], H );
        else     
          if ForAll( arglist, K -> not CanEasilyCompareCongruenceSubgroups( K, H ) ) and
             ForAll( arglist, K -> not IsSubgroup( H, K ) ) then
           for i in [ 1 .. Length(arglist) ] do
              if IsSubgroup( arglist[i], H ) then
                Unbind( arglist[i] );
              fi;
            od;
            arglist := Compacted( arglist );    
            Add( arglist, H );
          fi;
        fi;  
      fi;
    od;
    # if the list of defining subgroups was reduced 
    # to a single subgroup, we return this subgroup
    if Length( arglist ) = 1 then
      return arglist[1];
    fi; 
    # otherwise we sort the list of defining subgroups:
    # types of subgroups are sorted in the following way:
    # - IsCongruenceSubgroupGamma0
    # - IsCongruenceSubgroupGammaUpper0
    # - IsCongruenceSubgroupGamma1
    # - IsCongruenceSubgroupGammaUpper1
    # - IsPrincipalCongruenceSubgroup
    # and subgroups of the same type are sorted by ascending level
    Sort( arglist, 
          function(X,Y) 
          local f, t;
          f:=[IsCongruenceSubgroupGamma0,IsCongruenceSubgroupGammaUpper0,IsCongruenceSubgroupGamma1,IsCongruenceSubgroupGammaUpper1,IsPrincipalCongruenceSubgroup];
          return PositionProperty(f, t -> t(X)) < PositionProperty(f, t -> t(Y)) or
               ( PositionProperty(f, t -> t(X)) = PositionProperty(f, t -> t(Y)) and
                 LevelOfCongruenceSubgroup(X) < LevelOfCongruenceSubgroup(Y) ); 
          end );
    n := Lcm( List( arglist, H -> LevelOfCongruenceSubgroup(H) ) );                     
    G := rec();                   
    ObjectifyWithAttributes( G, type, 
      DimensionOfMatrixGroup, 2,
      OneImmutable, [[1,0],[0,1]],	
      IsIntegerMatrixGroup, true,
      IsFinite, false,
      LevelOfCongruenceSubgroup, n,
	  IsPrincipalCongruenceSubgroup, false,
	  IsIntersectionOfCongruenceSubgroups, true,
      IsCongruenceSubgroupGamma0, false, IsCongruenceSubgroupGammaUpper0, false,
      IsCongruenceSubgroupGamma1, false, IsCongruenceSubgroupGammaUpper1, false,
      DefiningCongruenceSubgroups, arglist );
    return G;
	end);
	
  		
#############################################################################
##
## Methods for PrintObj and ViewObj for congruence subgroups		
	
InstallMethod( ViewObj,
    "for principal congruence subgroup",
    [ IsPrincipalCongruenceSubgroup ],
    0,
    function( G )
      Print( "<principal congruence subgroup of level ", 
             LevelOfCongruenceSubgroup(G), " in SL_2(Z)>" );    
    end );
    
    
InstallMethod( PrintObj,
    "for principal congruence subgroup",
    [ IsPrincipalCongruenceSubgroup ],
    0,
    function( G )
      Print( "PrincipalCongruenceSubgroup(", 
             LevelOfCongruenceSubgroup(G), ")" );    
    end ); 
    

InstallMethod( ViewObj,
    "for CongruenceSubgroupGamma0 congruence subgroup",
    [ IsCongruenceSubgroupGamma0 ],
    0,
    function( G )
      Print( "<congruence subgroup CongruenceSubgroupGamma_0(", 
             LevelOfCongruenceSubgroup(G), ") in SL_2(Z)>" );    
    end );
    
    
InstallMethod( PrintObj,
    "for CongruenceSubgroupGamma0 congruence subgroup",
    [ IsCongruenceSubgroupGamma0 ],
    0,
    function( G )
      Print( "CongruenceSubgroupGamma0(", 
             LevelOfCongruenceSubgroup(G), ")" );    
    end );     
    

InstallMethod( ViewObj,
    "for CongruenceSubgroupGammaUpper0 congruence subgroup",
    [ IsCongruenceSubgroupGammaUpper0 ],
    0,
    function( G )
      Print( "<congruence subgroup CongruenceSubgroupGamma^0(", 
             LevelOfCongruenceSubgroup(G), ") in SL_2(Z)>" );    
    end );
    
    
InstallMethod( PrintObj,
    "for CongruenceSubgroupGammaUpper0 congruence subgroup",
    [ IsCongruenceSubgroupGammaUpper0 ],
    0,
    function( G )
      Print( "CongruenceSubgroupGammaUpper0(", 
             LevelOfCongruenceSubgroup(G), ")" );    
    end );    
    

InstallMethod( ViewObj,
    "for CongruenceSubgroupGamma1 congruence subgroup",
    [ IsCongruenceSubgroupGamma1 ],
    0,
    function( G )
      Print( "<congruence subgroup CongruenceSubgroupGamma_1(", 
             LevelOfCongruenceSubgroup(G), ") in SL_2(Z)>" );    
    end );
    
    
InstallMethod( PrintObj,
    "for CongruenceSubgroupGamma1 congruence subgroup",
    [ IsCongruenceSubgroupGamma1 ],
    0,
    function( G )
      Print( "CongruenceSubgroupGamma1(", 
             LevelOfCongruenceSubgroup(G), ")" );    
    end );     


InstallMethod( ViewObj,
    "for CongruenceSubgroupGammaUpper1 congruence subgroup",
    [ IsCongruenceSubgroupGammaUpper1 ],
    0,
    function( G )
      Print( "<congruence subgroup CongruenceSubgroupGamma^1(", 
             LevelOfCongruenceSubgroup(G), ") in SL_2(Z)>" );    
    end );
    
    
InstallMethod( PrintObj,
    "for CongruenceSubgroupGammaUpper1 congruence subgroup",
    [ IsCongruenceSubgroupGammaUpper1 ],
    0,
    function( G )
      Print( "CongruenceSubgroupGammaUpper1(", 
             LevelOfCongruenceSubgroup(G), ")" );    
    end );  


InstallMethod( ViewObj,
    "for CongruenceSubgroupGammaMN congruence subgroup",
    [ IsCongruenceSubgroupGammaMN ],
    0,
    function( G )
      Print( "<congruence subgroup CongruenceSubgroupGammaMN(", 
             LevelOfCongruenceSubgroupGammaMN(G)[1], ",", 
             LevelOfCongruenceSubgroupGammaMN(G)[2], ") in SL_2(Z)>" );    
    end );
    
    
InstallMethod( PrintObj,
    "for CongruenceSubgroupGammaMN congruence subgroup",
    [ IsCongruenceSubgroupGammaMN ],
    0,
    function( G )
      Print( "CongruenceSubgroupGammaMN(", 
              LevelOfCongruenceSubgroupGammaMN(G)[1], ",", 
             LevelOfCongruenceSubgroupGammaMN(G)[2], ")" );    
    end ); 
    

InstallMethod( ViewObj,
    "for intersection of congruence subgroups",
    [ IsIntersectionOfCongruenceSubgroups ],
    0,
    function( G )
      Print( "<intersection of congruence subgroups of resulting level ", 
             LevelOfCongruenceSubgroup(G), " in SL_2(Z)>" );    
    end );
    
    
InstallMethod( PrintObj,
    "for intersection of congruence subgroups",
    [ IsIntersectionOfCongruenceSubgroups ],
    0,
    function( G )
      local i, k;
      k := Length(DefiningCongruenceSubgroups(G)); 
      Print( "IntersectionOfCongruenceSubgroups( \n" );
      for i in [ 1 .. k-1 ] do
        Print( "  ", DefiningCongruenceSubgroups(G)[i], ", \n" );
      od;  
      Print( "  ", DefiningCongruenceSubgroups(G)[k], " )" );    
    end );
    

#############################################################################
##
## Membership tests for congruence subgroups

InstallMethod( \in,
    "for a 2x2 matrix and a principal congruence subgroup",
    [ IsMatrix, IsPrincipalCongruenceSubgroup],
    0,
    function( m, G )
    local n;
    if not DimensionsMat( m ) = [2,2] then
      return false;
    elif DeterminantMat(m)<>1 then
      return false;  
    else
      n := LevelOfCongruenceSubgroup(G);
      return IsInt( (m[1][1]-1)/n ) and 
             IsInt(m[1][2]/n) and 
             IsInt(m[2][1]/n) and 
             IsInt( (m[2][2]-1)/n );
    fi;  
    end);         


InstallMethod( \in,
    "for a 2x2 matrix and a congruence subgroup CongruenceSubgroupGamma0",
    [ IsMatrix, IsCongruenceSubgroupGamma0 ],
    0,
    function( m, G )
    local n;
    if not DimensionsMat( m ) = [2,2] then
      return false;
    elif DeterminantMat(m)<>1 then
      return false;  
    else
      n := LevelOfCongruenceSubgroup(G);
      return IsInt(m[2][1]/n);
    fi;  
    end); 
    

InstallMethod( \in,
    "for a 2x2 matrix and a congruence subgroup CongruenceSubgroupGammaUpper0",
    [ IsMatrix, IsCongruenceSubgroupGammaUpper0 ],
    0,
    function( m, G )
    local n;
    if not DimensionsMat( m ) = [2,2] then
      return false;
    elif DeterminantMat(m)<>1 then
      return false;  
    else
      n := LevelOfCongruenceSubgroup(G);
      return IsInt(m[1][2]/n);
    fi;  
    end);
    

InstallMethod( \in,
    "for a 2x2 matrix and a congruence subgroup CongruenceSubgroupGamma1",
    [ IsMatrix, IsCongruenceSubgroupGamma1 ],
    0,
    function( m, G )
    local n;
    if not DimensionsMat( m ) = [2,2] then
      return false;
    elif DeterminantMat(m)<>1 then
      return false;  
    else
      n := LevelOfCongruenceSubgroup(G);
      return IsInt( (m[1][1]-1)/n ) and 
             IsInt( m[2][1]/n ) and 
             IsInt( (m[2][2]-1)/n );
    fi;  
    end);
  

InstallMethod( \in,
    "for a 2x2 matrix and a congruence subgroup CongruenceSubgroupGammaUpper1",
    [ IsMatrix, IsCongruenceSubgroupGammaUpper1 ],
    0,
    function( m, G )
    local n;
    if not DimensionsMat( m ) = [2,2] then
      return false;
    elif DeterminantMat(m)<>1 then
      return false;  
    else
      n := LevelOfCongruenceSubgroup(G);
      return IsInt( (m[1][1]-1)/n ) and 
             IsInt( m[1][2]/n ) and 
             IsInt( (m[2][2]-1)/n );
    fi;  
    end);
    

InstallMethod( \in,
    "for a 2x2 matrix and a congruence subgroup CongruenceSubgroupGammaMN",
    [ IsMatrix, IsCongruenceSubgroupGammaMN ],
    0,
    function( mat, G )
    local m, n;
    if not DimensionsMat( mat ) = [2,2] then
      return false;
    elif DeterminantMat(mat)<>1 then
      return false;  
    else
      m := LevelOfCongruenceSubgroupGammaMN(G)[1];
      n := LevelOfCongruenceSubgroupGammaMN(G)[2];
      return IsInt( (mat[1][1]-1)/m ) and 
             IsInt(mat[1][2]/m) and 
             IsInt(mat[2][1]/n) and 
             IsInt( (mat[2][2]-1)/n );
    fi;  
    end);    
    
    
InstallMethod( \in,
    "for an intersection of congruence subgroups",
    [ IsMatrix, IsIntersectionOfCongruenceSubgroups ],
    0,
    function( m, G )
    local H;
    if not DimensionsMat( m ) = [2,2] then
      return false;
    elif DeterminantMat(m)<>1 then
      return false;  
    else
      return ForAll( DefiningCongruenceSubgroups(G), H -> m in H );
    fi;  
    end);
    
    
#############################################################################
##
## Installing special methods for congruence subgroups 
## for some general methods installed in GAP for matrix groups
    
InstallMethod( DimensionOfMatrixGroup,
    "for congruence subgroup",
    [ IsCongruenceSubgroup ],
    0,
    G -> 2 );  
 
InstallMethod( \=,
    "for a pair of congruence subgroups",
    [ IsCongruenceSubgroup, IsCongruenceSubgroup ],
    0,
    function( G, H )
    if CanEasilyCompareCongruenceSubgroups( G, H ) then
      return true;
    else
      TryNextMethod();
    fi;  
    end);


#############################################################################
##
## IsSubset
##
#############################################################################

InstallMethod( IsSubset,
    "for a natural SL_2(Z) and a congruence subgroup",
    [ IsNaturalSL, IsCongruenceSubgroup ],
    0,
    function( G, H )
    return MultiplicativeNeutralElement(G)=[ [ 1, 0 ], [ 0, 1 ] ];
    end);

InstallMethod( IsSubset,
    "for a congruence subgroup and a principal congruence subgroup",
    [ IsCongruenceSubgroup, IsPrincipalCongruenceSubgroup ],
    0,
    function( G, H )
    local T;
    if IsIntersectionOfCongruenceSubgroups(G) then
      return ForAll( DefiningCongruenceSubgroups(G), T -> IsSubset(T,H) );
    elif IsPrincipalCongruenceSubgroup(G) or 
         IsCongruenceSubgroupGamma1(G) or IsCongruenceSubgroupGammaUpper1(G) or
         IsCongruenceSubgroupGamma0(G) or IsCongruenceSubgroupGammaUpper0(G) then
      return IsInt( LevelOfCongruenceSubgroup(H) / LevelOfCongruenceSubgroup(G) ); 
    else
      # for a case of another type of congruence subgroup  
      TryNextMethod();
    fi;  
    end); 
    
InstallMethod( IsSubset,
    "for a congruence subgroup and CongruenceSubgroupGamma1",
    [ IsCongruenceSubgroup, IsCongruenceSubgroupGamma1 ],
    0,
    function( G, H )
    local T;
    if IsIntersectionOfCongruenceSubgroups(G) then
      return ForAll( DefiningCongruenceSubgroups(G), T -> IsSubset(T,H) );
    elif IsPrincipalCongruenceSubgroup(G) or 
         IsCongruenceSubgroupGammaUpper1(G) or IsCongruenceSubgroupGammaUpper0(G) then
      return false;
    elif IsCongruenceSubgroupGamma1(G) or IsCongruenceSubgroupGamma0(G) then
      return IsInt( LevelOfCongruenceSubgroup(H) / LevelOfCongruenceSubgroup(G) ); 
    else
      # for a case of another type of congruence subgroup  
      TryNextMethod();
    fi;  
    end); 
    
InstallMethod( IsSubset,
    "for a congruence subgroup and CongruenceSubgroupGammaUpper1",
    [ IsCongruenceSubgroup, IsCongruenceSubgroupGammaUpper1 ],
    0,
    function( G, H )
    local T;
    if IsIntersectionOfCongruenceSubgroups(G) then
      return ForAll( DefiningCongruenceSubgroups(G), T -> IsSubset(T,H) );
    elif IsPrincipalCongruenceSubgroup(G) or 
         IsCongruenceSubgroupGamma1(G) or IsCongruenceSubgroupGamma0(G) then
      return false;
    elif IsCongruenceSubgroupGammaUpper1(G) or IsCongruenceSubgroupGammaUpper0(G) then
      return IsInt( LevelOfCongruenceSubgroup(H) / LevelOfCongruenceSubgroup(G) ); 
    else
      # for a case of another type of congruence subgroup  
      TryNextMethod();
    fi;  
    end); 
    
InstallMethod( IsSubset,
    "for a congruence subgroup and CongruenceSubgroupGamma0",
    [ IsCongruenceSubgroup, IsCongruenceSubgroupGamma0 ],
    0,
    function( G, H )
    local T;
    if IsIntersectionOfCongruenceSubgroups(G) then
      return ForAll( DefiningCongruenceSubgroups(G), T -> IsSubset(T,H) );
    elif IsPrincipalCongruenceSubgroup(G) or 
         IsCongruenceSubgroupGamma1(G) or IsCongruenceSubgroupGammaUpper1(G) or IsCongruenceSubgroupGammaUpper0(G) then
      return false;
    elif IsCongruenceSubgroupGamma0(G) then
      return IsInt( LevelOfCongruenceSubgroup(H) / LevelOfCongruenceSubgroup(G) ); 
    else
      # for a case of another type of congruence subgroup  
      TryNextMethod();
    fi;  
    end);     
    
InstallMethod( IsSubset,
    "for a congruence subgroup and CongruenceSubgroupGammaUpper0",
    [ IsCongruenceSubgroup, IsCongruenceSubgroupGammaUpper0 ],
    0,
    function( G, H )
    local T;
    if IsIntersectionOfCongruenceSubgroups(G) then
      return ForAll( DefiningCongruenceSubgroups(G), T -> IsSubset(T,H) );
    elif IsPrincipalCongruenceSubgroup(G) or 
         IsCongruenceSubgroupGamma1(G) or IsCongruenceSubgroupGammaUpper1(G) or IsCongruenceSubgroupGamma0(G) then
      return false;
    elif IsCongruenceSubgroupGammaUpper0(G) then
      return IsInt( LevelOfCongruenceSubgroup(H) / LevelOfCongruenceSubgroup(G) ); 
    else
      # for a case of another type of congruence subgroup  
      TryNextMethod();
    fi;  
    end);
    
InstallMethod( IsSubset,
    "for a congruence subgroup and intersection of congruence subgroups",
    [ IsCongruenceSubgroup, IsIntersectionOfCongruenceSubgroups ],
    0,
    function( G, H )
    local DG, DH;
    # here we can check only sufficient conditions, and they are not 
    # satisfied, then we call the next method
    if IsIntersectionOfCongruenceSubgroups(G) then
      if ForAll( DefiningCongruenceSubgroups(H), DH -> 
                 ForAll( DefiningCongruenceSubgroups(G), DG -> 
                         IsSubset(G,DH) ) ) then
        return true;
      else
        TryNextMethod();
      fi;
    elif IsPrincipalCongruenceSubgroup(G) or 
         IsCongruenceSubgroupGamma1(G) or IsCongruenceSubgroupGammaUpper1(G) or 
         IsCongruenceSubgroupGamma0(G) or IsCongruenceSubgroupGammaUpper0(G) then
      if ForAll( DefiningCongruenceSubgroups(H), DH -> IsSubset(G,DH) ) then
        return true;
      else
        TryNextMethod();
      fi;  
    else
      # for a case of another type of congruence subgroup  
      TryNextMethod();
    fi;  
    end);    
    
    
#############################################################################
##
## Intersection2
##
#############################################################################


InstallMethod( Intersection2,
    "for a pair of congruence subgroups",
    [ IsCongruenceSubgroup, IsCongruenceSubgroup ],
    0,
    function( G, H )
    #
    # Case 1 - at least one subgroup is an intersection of congruence subgroups
    #
    if IsIntersectionOfCongruenceSubgroups(G) or
       IsIntersectionOfCongruenceSubgroups(H) then
      return IntersectionOfCongruenceSubgroups(G,H);
    #
    # Case 2 - the diagonal (both subgroups has the same type)
    # 
    elif IsPrincipalCongruenceSubgroup(G) and IsPrincipalCongruenceSubgroup(H) then
      return PrincipalCongruenceSubgroup( Lcm( LevelOfCongruenceSubgroup(G),
                                               LevelOfCongruenceSubgroup(H) ) );
    elif IsCongruenceSubgroupGamma1(G) and IsCongruenceSubgroupGamma1(H) then
      return CongruenceSubgroupGamma1( Lcm( LevelOfCongruenceSubgroup(G),
                          LevelOfCongruenceSubgroup(H) ) );
    elif IsCongruenceSubgroupGammaUpper1(G) and IsCongruenceSubgroupGammaUpper1(H) then
      return CongruenceSubgroupGammaUpper1( Lcm( LevelOfCongruenceSubgroup(G),
                          LevelOfCongruenceSubgroup(H) ) );
    elif IsCongruenceSubgroupGamma0(G) and IsCongruenceSubgroupGamma0(H) then
      return CongruenceSubgroupGamma0( Lcm( LevelOfCongruenceSubgroup(G),
                          LevelOfCongruenceSubgroup(H) ) );
    elif IsCongruenceSubgroupGammaUpper0(G) and IsCongruenceSubgroupGammaUpper0(H) then
      return CongruenceSubgroupGammaUpper0( Lcm( LevelOfCongruenceSubgroup(G),
                          LevelOfCongruenceSubgroup(H) ) );
    #
    # Case 3 - Subgroups has different level
    #
    elif LevelOfCongruenceSubgroup(G) <> LevelOfCongruenceSubgroup(H) then
      return IntersectionOfCongruenceSubgroups(G,H);
    #
    # Now subgroups have the same level
    #
    elif IsCongruenceSubgroupGamma1(G) and IsCongruenceSubgroupGamma0(H) then
      return G; # so all properties and attributes of G will be preserved
    elif IsCongruenceSubgroupGamma0(G) and IsCongruenceSubgroupGamma1(H) then
      return H; 
    elif IsCongruenceSubgroupGammaUpper1(G) and IsCongruenceSubgroupGammaUpper0(H) then
      return G;
    elif IsCongruenceSubgroupGammaUpper0(G) and IsCongruenceSubgroupGammaUpper1(H) then
      return H;
    elif IsCongruenceSubgroupGamma0(G) and IsCongruenceSubgroupGammaUpper0(H) or IsCongruenceSubgroupGammaUpper0(G) and IsCongruenceSubgroupGamma0(H) then
      return IntersectionOfCongruenceSubgroups(G,H);
    else
      return PrincipalCongruenceSubgroup(LevelOfCongruenceSubgroup(G));
    fi;                                             
    end);
    

#############################################################################
##
## Indices of congruence subgroups
##
#############################################################################

    
InstallMethod( Index,
    "for a natural SL_2(Z) and a congruence subgroup",
    [ IsNaturalSL, IsCongruenceSubgroup ],
    0,
    function( G, H )
    local n, prdiv, r, p;
    n := LevelOfCongruenceSubgroup(H);     
    if HasIsPrincipalCongruenceSubgroup( H ) and 
       IsPrincipalCongruenceSubgroup( H ) then
      if n=1 then
        Assert( 1, IndexInPSL2ZByFareySymbol( FareySymbol ( H ) ) = 1 );
        return 1;
      elif n=2 then
        Assert( 1, IndexInPSL2ZByFareySymbol( FareySymbol ( H ) ) = 6 );
        return 12; # not 6, since we are in SL, not in PSL
      else
        prdiv := Set( Factors( n ) );
        r := n^3; # not (n^3)/2 since we are in SL, not in PSL
        for p in prdiv do
          r := r*(1-1/p^2);
        od;
        Assert( 1, IndexInPSL2ZByFareySymbol( FareySymbol ( H ) ) = r/2 );
        return r;
      fi;
    elif ( HasIsCongruenceSubgroupGamma0( H ) and IsCongruenceSubgroupGamma0( H ) ) or 
         ( HasIsCongruenceSubgroupGammaUpper0( H ) and IsCongruenceSubgroupGammaUpper0( H ) ) then
      # for CongruenceSubgroupGamma0 we use the formula
      # [ SL_2(Z) : CongruenceSubgroupGamma0(n) ] = n * "Product over prime p | n" ( 1 + 1/p )
      prdiv := Set( Factors( n ) );
      r := n; 
      for p in prdiv do
        r := r*(1+1/p);
      od;
      Assert( 1, IndexInPSL2ZByFareySymbol( FareySymbol ( H ) ) = r );
      return r;
    elif ( HasIsCongruenceSubgroupGamma1( H ) and IsCongruenceSubgroupGamma1( H ) ) or 
         ( HasIsCongruenceSubgroupGammaUpper1( H ) and IsCongruenceSubgroupGammaUpper1( H ) ) then 
      # for CongruenceSubgroupGamma1 we use the formula
      # [ CongruenceSubgroupGamma0(n) : CongruenceSubgroupGamma1(n) ] = n * "Product over prime p | n" ( 1 - 1/p )
      # Combining with the previous case, we get that
      # [ SL_2(Z) : CongruenceSubgroupGamma1(n) ] = n^2 * "Product over prime p | n" ( 1 - 1/p^2 )
      prdiv := Set( Factors( n ) );
      r := n^2;
      for p in prdiv do
        r := r*(1-1/p^2);
      od;
      Assert( 1, IndexInPSL2ZByFareySymbol( FareySymbol ( H ) ) = r/2 );
      return r;
    else
      # if H is not in any of the cases above, for example is an intersection
      # of some congruence subgroups, we derive the index from its Farey symbol
      if [[-1,0],[0,-1]] in H then
        return IndexInPSL2ZByFareySymbol( FareySymbol ( H ) ) ;
      else
        return IndexInPSL2ZByFareySymbol( FareySymbol ( H ) ) * 2;
      fi;  
    fi;  
    end);    
    

InstallMethod( IndexInSL2Z,
    "for a congruence subgroup",
    [ IsCongruenceSubgroup ],
    0,
    G -> Index( SL(2,Integers), G ) );
    

InstallMethod( Index,
    "for a pair of congruence subgroups",
    [ IsCongruenceSubgroup, IsCongruenceSubgroup ],
    0,
    function( G, H )
    if IsSubgroup( G, H ) then
      return IndexInSL2Z(H)/IndexInSL2Z(G);
    fi;  
    end);

    
#############################################################################
##
## Generators of confruence subgroups from Farey symbols
##
#############################################################################


InstallMethod( GeneratorsOfGroup,
	"for a congruence subgroup",
	[ IsCongruenceSubgroup ],
	0,
	function(G)
	local gens, i;
	Info( InfoCongruence, 1, "Using the Congruence package for GeneratorsOfGroup ...");
	gens := GeneratorsByFareySymbol( FareySymbol( G ) );
	for i in [ 1 .. Length(gens) ] do
	  if not gens[i] in G then
	    gens[i] := -gens[i];
	    Assert( 1, gens[i] in G );
	  fi;
	od;
	return gens;
	end );
	
	
#############################################################################
##
#E
##
