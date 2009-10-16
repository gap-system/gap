############################################################################
##
#W pargap/induce.gi		NQL				René Hartung
##
#H   @(#)$Id: induce.gi,v 1.1 2009/05/06 13:12:56 gap Exp $
##
Revision.("nql/gap/pargap/induce_gi"):=
  "@(#)$Id: induce.gi,v 1.1 2009/05/06 13:12:56 gap Exp $";

############################################################################
##
#F  NQLPar_InduceEndomorphism( <EndoImgs>, <Defs>, <Imgs>, <weights> )
##
ParInstallTOPCGlobalFunction( "NQLPar_InduceEndomorphism", 
  function( EndoImgs, Defs, Imgs, weights )
  local F, 	# free group
	fam, 	# elements family of <F>
	endo,  	# the endomorphism <EndoImgs> as GroupHomomorphismByImages
	H, 	# the covering group
	Epi, 	# the epimorphism onto the covering group <H>
	imgs, 	# the images of the generators of <H> under the induced endom.
	i,	# loop variable
	DoTask, SubmitTaskInput, CheckTaskResult, UpdateSharedData;# MasterSlave

  # rebuild the endomorphism from the list
  F    := FreeGroup( Length( EndoImgs ) );
  fam  := ElementsFamily( FamilyObj( F ) );
  endo := GroupHomomorphismByImagesNC( F, F, GeneratorsOfGroup( F ),
               List( EndoImgs, x -> ObjByExtRep( fam, x )));

  # the covering group
  H := PcpGroupByCollectorNC( ReadEvalFromString( "ftl" ) );

  # compute the epimorphism from the free group onto the cover
  imgs := [];
  for i in [ 1 .. Length( Imgs ) ] do 
    if IsInt( Imgs[i] ) then 
      imgs[i] := PcpElementByGenExpList( ReadEvalFromString( "ftl" ), 
                                         [ Imgs[i], 1 ] );
    else
      imgs[i] := PcpElementByGenExpList( ReadEvalFromString( "ftl" ), Imgs[i] );
    fi;
  od;
  Epi := GroupHomomorphismByImages( F, H, GeneratorsOfGroup( F ), imgs );

  # reset the images 
  imgs := [];
  
  SubmitTaskInput := TaskInputIterator( [ 1 .. Length( Defs ) ] );

  DoTask :=  function( input )
    local output, w, k, obj, msg, orders;

    orders := ReadEvalFromString( "ftl" )![ PC_EXPONENTS ];

    if IsInt( Defs[input] ) then 
      if Defs[ input ] > 0 and weights[ input ] = 1 then 
        # a generator of weight one 
        return GenExpList( Image( Epi, Image( endo, 
                                 GeneratorsOfGroup( F )[ Defs[input] ] ) ) );
      elif Defs[ input ] > 0 and weights[ input ] > 1 then 
        # tail defined by an image
        w := One( H );

        for k in [ 1, 3 .. Length( Imgs[ Defs[input] ] ) - 3 ] do
          while not IsBound( imgs[ Imgs[ Defs[input] ][k] ] ) do 
            # wait for an update
            msg := RecvMsg();
            if not MPI_Get_tag() = BROADCAST_TAG then Error(); fi;
            UpdateSharedData( msg[1], msg[2] );
          od;

          w := w * PcpElementByGenExpList( ReadEvalFromString( "ftl" ), 
                   imgs[ Imgs[ Defs[input] ][k] ] ) ^ Imgs[ Defs[input] ][k+1];
        od;
        return ( GenExpList( w ^ -1 * Image( Epi, Image( endo, 
                            GeneratorsOfGroup( F )[ Defs[input] ] ) ) ) );
      elif Defs[ input ] < 0  then 
        # tail added to a power relation

        w := One( H );
        obj := GetPower( ReadEvalFromString( "ftl" ), - Defs[ input ] );
        obj := obj{ [ 1 ..Length( obj ) - 2 ] };
        for k in [ 1, 3 .. Length( obj ) - 1 ] do
          while not IsBound( imgs[ obj[k] ] ) do
            msg := RecvMsg();
            if not MPI_Get_tag() = BROADCAST_TAG then Error(); fi;
            UpdateSharedData( msg[1], msg[2] );
          od;
          w := w * PcpElementByGenExpList( ReadEvalFromString( "ftl" ), 
                                           imgs[ obj[k] ] ) ^ obj[k+1];
        od;
        return( GenExpList( w ^ -1 * PcpElementByGenExpList( 
                ReadEvalFromString( "ftl" ), 
                imgs[ -Defs[input] ] ) ^ orders[ -Defs[input] ]));
      fi;
    elif IsList( Defs[ input ] ) then 
      # tail added to conjugacy relation
      w := One( H );
      obj := GetConjugate( ReadEvalFromString( "ftl" ), 
                           Defs[input][1], Defs[input][2] );
      obj := obj{[ 3 .. Length( obj ) - 2]};
      for k in [ 1, 3 .. Length( obj ) - 1 ] do 
        while not IsBound( imgs[ obj[k] ] ) do
          msg := RecvMsg();
          if not MPI_Get_tag() = BROADCAST_TAG then Error(); fi;
          UpdateSharedData( msg[1], msg[2] );
        od;
        w := w * PcpElementByGenExpList( ReadEvalFromString( "ftl" ), 
                                         imgs[ obj[k] ] ) ^ obj[k+1];
      od;   
      while not IsBound( imgs[ Defs[input][1] ] ) do
        msg := RecvMsg();
        if not MPI_Get_tag() = BROADCAST_TAG then Error(); fi;
        UpdateSharedData( msg[1], msg[2] );
      od;
      while not IsBound( imgs[ Defs[input][2] ] ) do
        msg := RecvMsg();
        if not MPI_Get_tag() = BROADCAST_TAG then Error(); fi;
        UpdateSharedData( msg[1], msg[2] );
      od;

      return( GenExpList( w ^ -1 * Comm( 
              PcpElementByGenExpList( ReadEvalFromString( "ftl" ), 
                                      imgs[ Defs[input][1] ] ),
              PcpElementByGenExpList( ReadEvalFromString( "ftl" ), 
                                      imgs[ Defs[input][2] ] ) ) ) );
    fi;
    return fail;
    end;

  CheckTaskResult := function( input, output )
    if output = fail then 
      Error();
      return REDO_ACTION;
    else
      return UPDATE_ACTION;
    fi;
    end;
  
  UpdateSharedData := function( input, output )
    if not IsList( output ) then Error("in update"); fi;
    imgs[ input ] := output;
    end;

  # NEVER USE AGGLOMTASK as this may fail
  MasterSlave( SubmitTaskInput, DoTask, CheckTaskResult, UpdateSharedData );

  return( GroupHomomorphismByImagesNC( H, H, GeneratorsOfGroup(H), 
          List( imgs, 
          x -> PcpElementByGenExpList( ReadEvalFromString( "ftl" ), x ) )));
  end);
