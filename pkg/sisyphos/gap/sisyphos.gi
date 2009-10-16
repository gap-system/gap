#############################################################################
##
#W  sisyphos.gi              GAP Share Library               Martin Wursthorn
##
#H  @(#)$Id: sisyphos.gi,v 1.1 2000/10/23 17:05:01 gap Exp $
##
#Y  Copyright 1994-1995,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the implementations of the user interface
##  between {\SISYPHOS} and {\GAP}~4.
##
Revision.sisyphos_gi :=
    "@(#)$Id: sisyphos.gi,v 1.1 2000/10/23 17:05:01 gap Exp $";


#############################################################################
##
#F  SisyphosAutomorphisms( <P>, <flags> ) . . . automorphism group of p-group
##
##  general interface to SISYPHOS's function for computing automorphisms
##
InstallGlobalFunction( SisyphosAutomorphisms, function( P, flags )

    local inputlines,  #
          estimflags,  #
          result,      #
          SISISO,      #
          p,           #
          isoP,        #
          iiso;        #

#T check that the group is a PcGroup

    # prepare the input file for {\SISYPHOS}
    inputlines:= Concatenation( "au = automorphisms( p );\n",
                                "print( au, images );\n",
                                "makecode ( au );\n" );

    # compute amount of memory needed
    estimflags:= [ flags[3] <> 1, false ];

    # call {\SISYPHOS}, read the output, make clean
    result:= SisyphosCall( P, flags, estimflags, inputlines, "SISISO" );
    SISISO:= result[2].SISISO;
    p:= result[1];
    SISISO.generators:= List( SISISO.generators, x ->
                    GroupHomomorphismByImages( p, p, Pcgs(p), x ) );

    # pull back automorphisms to original group if necessary
    if IsBound( result[3] ) then
      isoP:= result[3];
      iiso:= InverseGeneralMapping( isoP );
      SISISO.generators:= List( SISISO.generators, x ->
                     isoP * x * iiso );
    fi;

    # is this a group of outer automorphisms ?
    SISISO.outer := ( flags[5] <> 1 );

    # is this a group of normalized automorphisms ?
    SISISO.normalized := ( flags[3] = 1 );

    # store coded description
    SISISO.SIScode := SISYPHOS.SISCODE;

    # return the result
    return SISISO;
    end );


##############################################################################
##
#F  SAutomorphisms( <P> )  . . . . . . . .  full automorphism group of p-group
#F  OuterAutomorphisms( <P> )  . . . . . . outer automorphism group of p-group
#F  NormalizedAutomorphisms( <P> ) . . . . normalized automorphisms of p-group
#F  NormalizedOuterAutomorphisms(<P>)  .  norm. outer automorphisms of p-group
##
InstallGlobalFunction( SAutomorphisms,
    P -> SisyphosAutomorphisms( P, [1,0,0,1,1] ) );
InstallGlobalFunction( OuterAutomorphisms,
    P -> SisyphosAutomorphisms( P, [1,0,0,1,0] ) );
InstallGlobalFunction( NormalizedAutomorphisms,
    P -> SisyphosAutomorphisms( P, [1,0,1,1,1] ) );
InstallGlobalFunction( NormalizedOuterAutomorphisms,
    P -> SisyphosAutomorphisms( P, [1,0,1,1,0] ) );


##############################################################################
##
#F  PresentationAutomorphisms( <P>, <flag> ) . . automorphism group of p-group
##
InstallGlobalFunction( PresentationAutomorphisms, function( P, flag )

    local inputlines,  #
          estimflags,  #
          SISflags,    #
          result,      #
          SISISO,      #
          p,           #
          isoP,        #
          iiso;        #

    # prepare the input file for {\SISYPHOS}
    if flag <> "outer" then
      flag:= "all";
    fi;
    inputlines:= Concatenation( "au = automorphisms( p );\n",
                                "presentation ( au, ", flag, " );\n" );

    # compute amount of memory needed
    estimflags:= [ false, false ];

    # call {\SISYPHOS}, read the output, make clean
    SISflags:= [ 1, 0, 1, 1, 1 ];
    result:= SisyphosCall( P, SISflags, estimflags, inputlines, "SISISO" );
    SISISO:= result[2].SISISO;
    p:= result[1];

    SISISO.SISAuts.generators:=
        List( SISISO.SISAuts.generators, x ->
              GroupHomomorphismByImages( p, p, Pcgs( p ), x ) );

    # pull back automorphisms to original group if necessary
    if IsBound( result[3] ) then
      isoP:= result[3];
      iiso:= InverseGeneralMapping( isoP );
      SISISO.SISAuts.generators:= List( SISISO.SISAuts.generators,
                    x -> isoP * x * iiso );
    fi;

    # return the result
    return SISISO;
    end );


##############################################################################
##
#F  PcNormalizedAutomorphisms( <P> ) . . normalized automorphisms of p-group <P>
#F  PcNormalizedOuterAutomorphisms( <P> )  . . normalized outer automorphisms of
#F                                                                 p-group <P>
##
InstallGlobalFunction( PcNormalizedAutomorphisms,
    P -> PresentationAutomorphisms( P, "all"  ) );
InstallGlobalFunction( PcNormalizedOuterAutomorphisms,
    P -> PresentationAutomorphisms( P, "outer") );


##############################################################################
##
#F  IsIsomorphic( <P1>, <P2> ) . . . . . . . .  isomorphism check for p-groups
##
InstallGlobalFunction( IsIsomorphic, function( P1, P2 )

    local type,        # string `\"pcgroup\"' or a prime
          inputlines,  #
          estimflags,  #
          result;      #

    # check type of P2
    if not IsPcGroup( P2 ) then
      Error( "<P2> must be a polycyclicly presented p-group" );
    fi;

    # check type of P1
    if   IsPcGroup( P1 ) then
      type:= "pcgroup";
      Size( P1 );
    elif IsFpGroup( P1 ) then
      type:= FactorsInt( Order( P2, P2.1 ) )[1];
    else
      Error( "<P1> must be a polycyclicly or freely presented p-group" );
    fi;

    # check if sizes of groups are known and equal
    if HasSize( P1 ) then
      if Size( P1 ) <> Size( P2 ) then
        return false;
      fi;
    else
      Print ( "#W <P1> is a freely presented group, can only decide if",
        "\n#W there is an epimorphism from <P1> to <P2>\n" );
#T better compute the size?
    fi;

    # prepare the input file for {\SISYPHOS}
    inputlines:= Concatenation( SisyphosInputPGroup( P1, "q", type ), "\n",
#T                              "set displaystyle gap;\n",
#T removed in new version ...
                                "isomorphic(p,q);\n" );

    # compute amount of memory needed
    estimflags:= [ true, false ];

    # call {\SISYPHOS}, read the output, make clean
    result:= SisyphosCall( P2, false, estimflags, inputlines, "SISBOOL" );

    # return the result
    return result[2].SISBOOL;
    end );


##############################################################################
##
#F  Isomorphisms( <P1>, <P2> ) . . . . . . . . . isomorphisms between p-groups
##
InstallGlobalFunction( Isomorphisms, function( P1, P2 )

    local type,        # string `\"pcgroup\"' or a prime
          inputlines,  #
          estimflags,  #
          SISflags,    #
          result,      #
          SISISO,      #
          p,           #
          isoP,        #
          iiso;        #

    # check type of P2
    if not IsPcGroup( P2 ) then
      Error( "<P2> must be a polycyclicly presented p-group" );
    fi;

    # check type of P1
    if   IsPcGroup( P1 ) then
      type:= "pcgroup";
      Size( P1 );
    elif IsFpGroup( P1 ) then
      type:= FactorsInt( Size( P2 ) )[1];
    else
      Error( "<P1> must be a polycyclicly or freely presented p-group" );
    fi;

    # check if sizes of groups are known and equal
    if HasSize( P1 ) then
      if Size( P1 ) <> Size( P2 ) then
        return false;
      fi;
    else
      Print ( "#W <P1> is a freely presented group, can only decide if",
        "\n#W there is an epimorphism from <P1> to <P2>\n" );
    fi;

    # prepare the input file for {\SISYPHOS}
    inputlines:= Concatenation( SisyphosInputPGroup( P1, "q", type ), "\n",
                                "is = isomorphisms(p,q);\n",
                                "print( is, images );\n",
                                "makecode ( is );\n" );

    # compute amount of memory needed
    estimflags:= [ true, false ];

    # call {\SISYPHOS}, read the output, make clean
    result:= SisyphosCall( P2, false, estimflags, inputlines, "SISISO" );
    SISISO:= result[2].SISISO;
    p:= result[1];

    # check whether groups are isomorphic
    if SISISO <> false then

      SISISO.generators:= List( SISISO.generators, x ->
                      GroupHomomorphismByImages( p, p, Pcgs( p ), x ) );

      # pull back automorphisms and epimorphism to original group if necessary
      if IsBound( result[3] ) then
        isoP:= result[3];
        iiso:= InverseGeneralMapping( isoP );
        SISISO.generators:= List( SISISO.generators, x ->
                       isoP * x * iiso );
        SISISO.epimorphism:= List( SISISO.epimorphism,
           x -> Image( iiso, x ) );
      fi;

      SISISO.outer := true;

      # store coded description
      SISISO.SIScode := result[2].SISCODE;

    fi;

    # return the result
    return SISISO;
    end );


##############################################################################
##
#F  CorrespondingAutomorphism( <A>, <w> ) . .  automorphism corresp. to agword
##
InstallGlobalFunction( CorrespondingAutomorphism, function( A, w )

    local type,        # string `\"pcgroup\"' or a prime
          inputlines,  #
          estimflags,  #
          SISflags,    #
          result,      #
          SISISO,      #
          p,           #
          isoP,        #
          iiso,        #
          funcstr,
          i, j, l; # loop variables used in 'func'

    # check argument types
    if not IsPcGroup( A ) then
      Error( "<A> must be a a polycyclicly presented p-group" );
    fi;
    if not IsBound( A.SISAuts ) then
#T need an attribute??
      Error( "<A> is not an automorphism group" );
    fi;
    if not ( w in A ) then
      Error( "<w> is not an element in <A>" );
    fi;

    p:= A.SISAuts.generators[1].source;

    # Construct a string describing ...
    funcstr:= "";
    for i in [ 1 .. Length( A.SISAuts.generators ) ] do
      Append( funcstr, "aut" );
      Append( funcstr, String( i ) );
      Append( funcstr, " = grouphom ( p, seq( " );
      l:= A.SISAuts.generators[i].genimages;
      for j in [ 1 .. Length( l ) - 1 ] do
        Append( funcstr, SisyphosGenWord( "p",
            ExponentsOfPcElement( Image( iiso, l[j] ) ), true ) );
        Add( funcstr, ',' );
      od;
      Append( funcstr, SisyphosGenWord( "p",
          ExponentsOfPcElement( Image( iiso, l[ Length(l) ] ) ), true ) );
      Append( funcstr, "));\n" );
    od;

    # prepare the input file for {\SISYPHOS}
    inputlines:= Concatenation( funcstr,
                                "print ( ",
                 SisyphosGenWord( "aut", ExponentsOfPcElement( w ), false ),
                 ", images );\n" );

    # compute amount of memory needed
    estimflags:= [ false, false ];

    # call {\SISYPHOS}, read the output, make clean
    result:= SisyphosCall( p, false, estimflags, inputlines, "SISISO" );
    SISISO:= result[2].SISISO;
    p:= result[1];

    SISISO:= GroupHomomorphismByImages( p, p, Pcgs( p ), SISISO );

    # pull back automorphisms to original group if necessary
    if IsBound( result[3] ) then
      isoP:= result[3];
      iiso:= InverseGeneralMapping( isoP );
      SISISO:= isoP * SISISO * iiso;
    fi;

    return SISISO;
    end );


##############################################################################
##
#F  AutomorphismGroupElements( <A> ) . . .  element list of automorphism group
##
InstallGlobalFunction( AutomorphismGroupElements, function( A )

    local isoP,         # record containing normalized presentation isoP.P
                        # and isomorphism <P> -> 'isoP.P'
          iiso,         # (inverse) isomorphism
          normf,        # specifies whether 'A' consists of normalized
                        # automorphisms
          i, j, l,      # loop variables
          estim,        #
          func,         # local function (to avoid 'AppendTo')
          codestr,      # string in {\SISYPHOS} format containing contents
                        # of A.SIScode
          type,         # either "outer" or "all"
          SISISO, p, result, inputlines, funcstr;

    # obtain $p$-group to which <A> belongs
    if IsList ( A ) then
      p := A[1].source;
    else
      if  IsBound ( A.elements ) then
        # nothing to do
        return A.elements;
      fi;
      p := A.generators[1].source;
    fi;

    # check if <A> is just a list
    if IsList( A ) then

      normf := true;

      funcstr:= "seq(\n";
      for i in [ 1 .. Length( A ) ] do
        Append( funcstr, "grouphom ( p, seq( " );
        l:= A[i].genimages;
        for j in [ 1 .. Length( l ) - 1 ] do
          Append( funcstr,
                  SisyphosGenWord( "p", ExponentsOfPcElement( Image( iiso, l[j] ) ), true ) );
          Append( funcstr, "," );
        od;
        Append( funcstr, SisyphosGenWord( "p", ExponentsOfPcElement ( Image ( iiso,
                        l[ Length( l ) ] ) ), true ) );
        Append( funcstr, "))" );
        if i < Length( A ) then
          Append( funcstr, ",\n" );
        fi;
      od;
      Append( funcstr, ")" );

      inputlines:= Concatenation(
                "auts = autspan ( ",
                funcstr,
                ");\n",
                "print ( auts, images );\n" );

    else

      if ( A.outer ) then
        type:= "outer";
      else
        type:= "all";
      fi;
      normf:= A.normalized;
      codestr := ShallowCopy( String( A.SIScode ) );
      codestr[1] := '(';
      codestr[Length(codestr)] := ')';

      inputlines:= Concatenation(
                "auts = code ( seq", codestr, "));\n",
                "autl = elements ( auts, ", type, ");\n",
                "print ( autl, images, ", type, ");\n" );

    fi;

    # Compute the amount of memory needed (individual numbers).
    estim:= EstimateAmount( p, [ not normf, true ] );
    estim:= [ String( estim ), String( Int( estim / 2 ) ) ];

    # call {\SISYPHOS}, read the output, make clean
    result:= SisyphosCall( false, false, estim, inputlines, "SISISO" );
    SISISO:= result[2].SISISO;
    p:= result[1];

    SISISO.generators:= List( SISISO.generators, x ->
             GroupHomomorphismByImages( p, p, Pcgs( p ), x ) );

    # pull back automorphisms to original group if necessary
    if IsBound( isoP.isomorphism ) then
      iiso:= InverseGeneralMapping( isoP.isomorphism );
      SISISO.generators:= List( SISISO.generators, x ->
                     isoP.isomorphism * x * iiso );
    fi;

    if not IsList ( A ) then
      A.elements:= SISISO.generators;
#T SetAsListSorted??
    fi;

    # Return the result.
    return SISISO.generators;
    end );


#############################################################################
##
#A  NormalizedUnitsGroupRing( <P> )
#O  NormalizedUnitsGroupRing( <P>, <n> )
##
BindGlobal( "SisyphosNormalizedUnitsGroupRing", function( P, n )

    local isoP,    # isomorphism from `P' onto group that is compatible
                   # with the Jennings series of `P'
          jser,    # Jennings series of `p'
          weights, # list of Jennings weights of the generators of `p'
          mtable,  # string containing SISYPHOS command for computing
                   # a multiplication table for `p' (or empty)
          tsize,   # size of the multiplication table
          estim,
          inputlines,
          j,       # loop variable
          i,       # loop variable
          result;

    # Check the arguments.
    if not IsGroup( P ) or not ( n = true or IsInt( n ) ) then
      Error( "usage: SisyphosNormalizedUnitsGroupRing( <P>[, <n>] )" );
    fi;

    # Compute an isomorphic group with presentation compatible
    # with the Jennings series.
#T How does this work in GAP 4?
    isoP:= IsomorphismPcGroup( JenningsSeries( P ) );
    p:= Range( isoP );

    # Compute the weights of the generators w.r.t. the Jennings series.
    jser:= JenningsSeries( p );
    weights:= [];
    for i in Pcgs( p ) do
      j:= 2;
      while i in jser[j] do
        j:= j+1;
      od;
      Add( weights, j-1 );
    od;

    if IsInt( n ) then
      n:= Maximum( n, 1 );
    else
      n:= Length( DimensionsLoewyFactors( p ) );
    fi;

    # compute amount of memory needed (individually)
    tsize:= Size( p ) * Size( p ) * 4;
    if tsize < 5400000 then
      tsize:= tsize + 600000;
      mtable:= "use (multiplication table);\n";
      Print( "#D Sisyphos: use multiplication table\n" );    
#T Info?
    else
      tsize:= 600000;
      mtable:= "";
    fi;
    estim:= [ String( tsize ), "300000" ];

    # Prepare the input file for {\SISYPHOS}
    inputlines:= Concatenation(
                     SisyphosInputPGroup( p, "p", "pcgroup", weights ),
                     "setdomain( groupring( p ) );\n",
                     mtable,
                     "unitgroup( ", n, ",\"SISYPHOS.SISISO\", 1 );\n" );

    # Call {\SISYPHOS}, read the output, make clean.
    result:= SisyphosCall( p, false, estim, inputlines, "SISISO" );
    P:= result[2].SISISO;

    # Return the result.
    return P;
    end );

InstallMethod( NormalizedUnitsGroupRing,
    [ IsGroup ],
    P -> SisyphosNormalizedUnitsGroupRing( P, true ) );

InstallMethod( NormalizedUnitsGroupRing,
    [ IsGroup, IsInt ],
    SisyphosNormalizedUnitsGroupRing );


#############################################################################
##
#E

