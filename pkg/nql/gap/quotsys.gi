############################################################################
##
#W quotsys.gi			NQL				René Hartung
##
#H   @(#)$Id: quotsys.gi,v 1.4 2009/05/06 12:56:53 gap Exp $
##
Revision.("nql/gap/quotsys_gi"):=
  "@(#)$Id: quotsys.gi,v 1.4 2009/05/06 12:56:53 gap Exp $";


############################################################################
##
#F  SmallerQuotientSystem ( <Q>, <int> )
## 
## computes a nilpotent quotient system for G/gamma_i(G) if a nilpotent 
## quotient system for G/gamma_j(G) is known, i<j.
##
InstallGlobalFunction( SmallerQuotientSystem,
  function(Q,c)
  local QS,		# new quotient system
	i,j,k,		# loop variables
  	n,		# number of gens of <QS>
        orders,		# relative orders of the new qs.
    	imgs,		# new images of the epimorphism
        rhs_old,rhs_new;# right hand side of a relation
       

  QS:=rec();
  QS.Lpres:=Q.Lpres;
  QS.Weights:=Filtered(Q.Weights,x->x<=c);
  
  # number of gens of <QS>
  n:=Length(QS.Weights);
 
  QS.Definitions:=Q.Definitions{[1..n]};
  
  # build new collector using <Q.Pccol>
  QS.Pccol:=FromTheLeftCollector(n);

  # the conjugate relations
  for i in [1..n] do
    for j in [i+1..n] do
      rhs_old:=GetConjugate(Q.Pccol,j,i);
      rhs_new:=[];
      for k in [1,3..Length(rhs_old)-1] do
        if Q.Weights[rhs_old[k]]<=c then 
          Append(rhs_new,rhs_old{[k,k+1]});
        else 
          # the weights-function is increasing
          break;
        fi;
      od; 
      SetConjugate(QS.Pccol,j,i,rhs_new);
    od;
  od;

  # find the gens with power relations
  orders:=RelativeOrders(Q.Pccol){[1..n]};

  # new power relations
  for i in Filtered([1..Length(orders)],x->orders[x]<>0) do
    rhs_old:=GetPower(Q.Pccol,i);
    rhs_new:=[];
    for k in [1,3..Length(rhs_old)-1] do
      if Q.Weights[rhs_old[k]]<=c then 
        Append(rhs_new,rhs_old{[k,k+1]});
      else 
        # the weights-function is increasing
        break;
      fi;
    od; 
    SetRelativeOrder(QS.Pccol,i,orders[i]);
    SetPower(QS.Pccol,i,rhs_new);
  od;
  UpdatePolycyclicCollector(QS.Pccol);

  # the new images of the epimorphism
  QS.Imgs:=[];
  for i in [1..Length(Q.Imgs)] do 
    if IsInt(Q.Imgs[i]) then
      QS.Imgs[i]:=Q.Imgs[i];
    else
      rhs_old:=Q.Imgs[i];
      rhs_new:=[];
      for k in [1,3..Length(rhs_old)-1] do
        if Q.Weights[rhs_old[k]]<=c then 
          Append(rhs_new,rhs_old{[k,k+1]});
        else 
          # the weights-function is increasing
          break;
        fi;
      od;
      QS.Imgs[i]:=rhs_new;
    fi;
  od; 
  
  # build the new epimorphism
  imgs:=[];
  for i in [1..Length(QS.Imgs)] do
    if IsInt(QS.Imgs[i]) then 
      imgs[i]:=[QS.Imgs[i],1];
    else 
      imgs[i]:=QS.Imgs[i];
    fi;
  od;
  imgs:=List(imgs,x->PcpElementByGenExpList(QS.Pccol,x));
  QS.Epimorphism:=GroupHomomorphismByImagesNC(QS.Lpres,
 			PcpGroupByCollectorNC(QS.Pccol),
			GeneratorsOfGroup(QS.Lpres),
			imgs);
 
  return(QS);
  end);


############################################################################
##
#F  NQL_SaveQuotientSystem( <Q>, <file> )
##
InstallGlobalFunction( NQL_SaveQuotientSystem,
  function( Q, file )
  local endo,	# an endomorphism of <Q.Lpres>
	mapi,	# MappingGeneratorsImages
	orders, # relative orders of <Q.Pccol>
	i,j,k;	# loop variables

  if not IsString( file ) then 
    Error("in input: <file> must be a string!");
  fi;
  
  if not ( IsBound( Q.Lpres ) and IsBound( Q.Pccol ) and
           IsBound( Q.Imgs ) and IsBound( Q.Definitions ) and 
           IsBound( Q.Weights ) and IsBound( Q.Epimorphism ) ) then 
    Error("in input: <Q> must be a quotient system!");
  fi;
  
  PrintTo( file, "RequirePackage(\"NQL\");\n");
  AppendTo( file, "Q:=rec( ); \n");
 
  # the LpGroup
  AppendTo( file, "F := FreeGroup( ", List( GeneratorsOfGroup( Q.Lpres ), 
                                           String )," );\n");
  AppendTo( file, "frels := List( ", 
                  List( FixedRelatorsOfLpGroup( Q.Lpres ), ExtRepOfObj ), 
                 ", x -> ObjByExtRep( FamilyObj( F.1 ), x ) );\n");

  AppendTo( file, "irels := List( ", 
                  List( IteratedRelatorsOfLpGroup( Q.Lpres ), ExtRepOfObj ), 
                 ", x -> ObjByExtRep( FamilyObj( F.1 ), x ) );\n");

  AppendTo( file, "endo := [];\n" );

  for endo in EndomorphismsOfLpGroup( Q.Lpres ) do 
    mapi := List( MappingGeneratorsImages( endo ), 
                  y -> List( y, ExtRepOfObj ) );
    AppendTo( file, "Add( endo, GroupHomomorphismByImagesNC( F, F, List( ",
                     mapi[1], 
                    ", x -> ObjByExtRep( FamilyObj( F.1 ), x ) ), List( ",
                     mapi[2],
                    ", x -> ObjByExtRep( FamilyObj( F.1 ), x ))));\n");
  od;
  AppendTo( file, "Q.Lpres := LPresentedGroup( F, frels, endo, irels );\n");

  if HasIsInvariantLPresentation( Q.Lpres ) then
    AppendTo( file, "SetIsInvariantLPresentation( Q.Lpres, ",
                     IsInvariantLPresentation( Q.Lpres ), " );\n");
  fi;
  
  if IsAscendingLPresentation( Q.Lpres ) then
    AppendTo( file, "SetIsAscendingLPresentation( Q.Lpres, true );\n");
  fi;
  

  # store the polycyclic presentation
  AppendTo( file, "Q.Pccol := FromTheLeftCollector( ",
                              NumberOfGenerators(Q.Pccol), " );\n");

  orders := RelativeOrders( Q.Pccol );
  for i in Filtered( [ 1..Length(orders)], x -> orders[x]<>0 ) do
    AppendTo( file, "SetRelativeOrder( Q.Pccol, ",i,", ",orders[i]," );\n" );
    AppendTo( file, "SetPower( Q.Pccol, ",i,", ",GetPower(Q.Pccol,i)," );\n");
# don't compute the inverses of gens with finite relative order
    if IsBound( Q.Pccol![ PC_POWERS ][i] ) then
      AppendTo( file, "Q.Pccol![ PC_INVERSEPOWERS ][", i, "] := ",
                      Q.Pccol![ PC_INVERSEPOWERS ][i], ";\n");
    fi;
  od;

  for i in [1..Length(orders)-1] do
    for j in [i+1..Length(orders)] do
      AppendTo( file, "SetConjugate( Q.Pccol, ",j,", ",i,", ", 
                       GetConjugate( Q.Pccol, j, i )," );\n");
      if orders[i] = 0 then 
        AppendTo( file, "SetConjugate( Q.Pccol, ",j,", ",-i,", ", 
                         GetConjugate( Q.Pccol, j, -i )," );\n");
        if orders[j] = 0 then 
          AppendTo( file, "SetConjugate( Q.Pccol, ",-j,", ",-i,", ", 
                           GetConjugate( Q.Pccol, -j, -i )," );\n");
        fi;
      elif orders[j] = 0 then 
        AppendTo( file, "SetConjugate( Q.Pccol, ",-j,", ",i,", ", 
                         GetConjugate( Q.Pccol, -j, i )," );\n");
      fi;
    od;
  od;
  AppendTo( file, "FromTheLeftCollector_SetCommute( Q.Pccol );\n");
  AppendTo( file, "SetFeatureObj( Q.Pccol, IsUpToDatePolycyclicCollector, true);\n");
  AppendTo( file, "FromTheLeftCollector_CompleteConjugate( Q.Pccol );\n");
# don't compute the inverse of gens with finite relative order
# AppendTo( file, "FromTheLeftCollector_CompletePowers( Q.Pccol );\n");
  AppendTo( file, "SetFeatureObj( Q.Pccol, IsUpToDatePolycyclicCollector, true);\n");

  AppendTo( file, "Q.Imgs := ", Q.Imgs, ";\n");
  AppendTo( file, "Q.Definitions := ", Q.Definitions, ";\n");
  AppendTo( file, "Q.Weights := ", Q.Weights, ";\n");
  AppendTo( file, "H := PcpGroupByCollectorNC( Q.Pccol );;\n" );
  AppendTo( file, "Q.Epimorphism := GroupHomomorphismByImagesNC( Q.Lpres,",
                  " H, GeneratorsOfGroup( Q.Lpres ), List( ", 
                   List( MappingGeneratorsImages( Q.Epimorphism )[2], 
                         GenExpList ),
                  ", x-> PcpElementByGenExpList( Q.Pccol, x)));\n");

  end);

############################################################################
##
#F  NQL_SaveQuotientSystemCover( <Q>, <file> )
##
InstallGlobalFunction( NQL_SaveQuotientSystemCover,
  function( Q, file )
  local endo,	# an endomorphism of <Q.Lpres>
	mapi,	# MappingGeneratorsImages
	orders, # relative orders of <Q.Pccol>
	i,j,k;	# loop variables

  if not IsString( file ) then 
    Error("in input: <file> must be a string!");
  fi;
  
  if not ( IsBound( Q.Lpres ) and IsBound( Q.Pccol ) and
           IsBound( Q.Imgs ) and IsBound( Q.Definitions ) and 
           IsBound( Q.Weights ) and IsBound( Q.Epimorphism ) ) then 
    Error("in input: <Q> must be a quotient system!");
  fi;
  
  AppendTo( file, "local Q,F,frels,irels,endo,mapi,H;\n");
  AppendTo( file, "Q:=rec( ); \n");
 
  # the LpGroup
  AppendTo( file, "F := FreeGroup( ", List( GeneratorsOfGroup( Q.Lpres ), 
                                           String )," );\n");
  AppendTo( file, "frels := List( ", 
                  List( FixedRelatorsOfLpGroup( Q.Lpres ), ExtRepOfObj ), 
                 ", x -> ObjByExtRep( FamilyObj( F.1 ), x ) );\n");

  AppendTo( file, "irels := List( ", 
                  List( IteratedRelatorsOfLpGroup( Q.Lpres ), ExtRepOfObj ), 
                 ", x -> ObjByExtRep( FamilyObj( F.1 ), x ) );\n");

  AppendTo( file, "endo := [];\n" );

  for endo in EndomorphismsOfLpGroup( Q.Lpres ) do 
    mapi := List( MappingGeneratorsImages( endo ), 
                  y -> List( y, ExtRepOfObj ) );
    AppendTo( file, "Add( endo, GroupHomomorphismByImagesNC( F, F, List( ",
                     mapi[1], 
                    ", x -> ObjByExtRep( FamilyObj( F.1 ), x ) ), List( ",
                     mapi[2],
                    ", x -> ObjByExtRep( FamilyObj( F.1 ), x ))));\n");
  od;
  AppendTo( file, "Q.Lpres := LPresentedGroup( F, frels, endo, irels );\n");

  if HasIsInvariantLPresentation( Q.Lpres ) then
    AppendTo( file, "SetIsInvariantLPresentation( Q.Lpres, ",
                     IsInvariantLPresentation( Q.Lpres ), " );\n");
  fi;
  
  if IsAscendingLPresentation( Q.Lpres ) then
    AppendTo( file, "SetIsAscendingLPresentation( Q.Lpres, true );\n");
  fi;
  

  # store the polycyclic presentation
  AppendTo( file, "Q.Pccol := FromTheLeftCollector( ",
                              NumberOfGenerators(Q.Pccol), " );\n");

  orders := RelativeOrders( Q.Pccol );
  for i in Filtered( [ 1..Length(orders)], x -> orders[x]<>0 ) do
    AppendTo( file, "SetRelativeOrder( Q.Pccol, ",i,", ",orders[i]," );\n" );
    AppendTo( file, "SetPower( Q.Pccol, ",i,", ",GetPower(Q.Pccol,i)," );\n");
  od;

  for i in [1..Length(orders)-1] do
    for j in [i+1..Length(orders)] do
      AppendTo( file, "SetConjugate( Q.Pccol, ",j,", ",i,", ", 
                       GetConjugate( Q.Pccol, j, i )," );\n");
      if orders[i] = 0 then 
        AppendTo( file, "SetConjugate( Q.Pccol, ",j,", ",-i,", ", 
                         GetConjugate( Q.Pccol, j, -i )," );\n");
        if orders[j] = 0 then 
          AppendTo( file, "SetConjugate( Q.Pccol, ",-j,", ",-i,", ", 
                           GetConjugate( Q.Pccol, -j, -i )," );\n");
        fi;
      elif orders[j] = 0 then 
        AppendTo( file, "SetConjugate( Q.Pccol, ",-j,", ",i,", ", 
                         GetConjugate( Q.Pccol, -j, i )," );\n");
      fi;
    od;
  od;
  AppendTo( file, "FromTheLeftCollector_SetCommute( Q.Pccol );\n");
  AppendTo( file, "SetFeatureObj( Q.Pccol, IsUpToDatePolycyclicCollector, true);\n");
  AppendTo( file, "FromTheLeftCollector_CompleteConjugate( Q.Pccol );\n");
  AppendTo( file, "FromTheLeftCollector_CompletePowers( Q.Pccol );\n");
  AppendTo( file, "SetFeatureObj( Q.Pccol, IsUpToDatePolycyclicCollector, true);\n");

  AppendTo( file, "Q.Imgs := ", Q.Imgs, ";\n");
  AppendTo( file, "Q.Definitions := ", Q.Definitions, ";\n");
  AppendTo( file, "Q.Weights := ", Q.Weights, ";\n");
  AppendTo( file, "H := PcpGroupByCollectorNC( Q.Pccol );;\n" );
  AppendTo( file, "Q.Epimorphism := GroupHomomorphismByImagesNC( Q.Lpres,",
                  " H, GeneratorsOfGroup( Q.Lpres ), List( ", 
                   List( MappingGeneratorsImages( Q.Epimorphism )[2], 
                         GenExpList ),
                  ", x-> PcpElementByGenExpList( Q.Pccol, x)));\n");
  AppendTo( file, "return( Q );\n" );
  end);

############################################################################
##
#F  NQL_LoadCoveringGroups( G, <List> )
##
NQL_LoadCoveringGroups := function( G, L )
  local f,
	Cov,
	Q,
	i;

  if HasCoveringGroups( G ) then
    Cov := ShallowCopy( CoveringGroups( G ) );;
  else
    Cov := [];
  fi;

  for i in [ 1 .. Length( L ) ] do
    if not IsString( L[i] ) then 
      Error("<L> must be a list of files");
    fi;
    f := ReadAsFunction( L[i] );
    Q := f();;

    # check if the LpGroup <G> and <Q.Lpres> are the same (but not identical)
    if RankOfFreeGroup( FreeGroupOfLpGroup( Q.Lpres ) ) <> 
             RankOfFreeGroup( FreeGroupOfLpGroup( G ) ) or
       List( FixedRelatorsOfLpGroup( Q.Lpres ), ExtRepOfObj ) <>
             List( FixedRelatorsOfLpGroup( G ), ExtRepOfObj )  or
       List( IteratedRelatorsOfLpGroup( Q.Lpres ), ExtRepOfObj ) <>
             List( IteratedRelatorsOfLpGroup( G ), ExtRepOfObj )  or
       List( EndomorphismsOfLpGroup( Q.Lpres ), x -> 
             List( MappingGeneratorsImages(x), y -> List( y, ExtRepOfObj))) <>
       List( EndomorphismsOfLpGroup( G ), x -> 
             List( MappingGeneratorsImages(x), y -> List( y, ExtRepOfObj))) then
       Error("the LpGroups differ");
    fi;;

    # modify the epimorphism so that it maps from the free group to the PcpGroup
    Q.Epimorphism := GroupHomomorphismByImagesNC( FreeGroupOfLpGroup( G ),
                  Range( Q.Epimorphism ), FreeGeneratorsOfLpGroup( G ),
                  MappingGeneratorsImages( Q.Epimorphism )[2] );;
 
    if not IsBound(Cov[ Maximum( Q.Weights ) - 1]) then 
      Cov[ Maximum( Q.Weights ) - 1 ] := Q;
    else
      Info( InfoNQL, 1, "this quotient system is already bound" );
    fi;
  od;
  if HasCoveringGroups( G ) then ResetFilterObj( G, CoveringGroups ); fi;
  SetCoveringGroups( G, Cov );
  end;;
