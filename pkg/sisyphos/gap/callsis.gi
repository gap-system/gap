#############################################################################
##
#W  callsis.gi               GAP Share Library               Martin Wursthorn
##
#H  @(#)$Id: callsis.gi,v 1.3 2007/02/06 22:27:04 gap Exp $
##
#Y  Copyright 1994-1995,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the implementations of the low level interface
##  between {\SISYPHOS} and {\GAP}~4.
##
Revision.callsis_gi :=
    "@(#)$Id: callsis.gi,v 1.3 2007/02/06 22:27:04 gap Exp $";


#############################################################################
##
#V  SISYPHOS
#V  p
##
##  These are global variables.
##  A perhaps existing variable 'p' will be saved always (except if the
##  computation is interrupted during the run of one of the programs in this
##  file).
##
InstallValue( SISYPHOS,
             rec( SISOps  := rec( Print:= function( r )
                                 Print( "rec(\n",
                                        "sizeAutG := ", r.sizeAutG, ",\n",
                                        "sizeInnG := ", r.sizeInnG, ",\n",
                                        "sizeOutG := ", r.sizeOutG, ",\n" );
                                 if IsBound( r.epimorphism ) then
                                   Print( "epimorphism := ",
                                           r.epimorphism, ",\n" );
                                 fi;
                                 Print( "generators := \n", r.generators,
                                         " )" );
                                  end ),
                  SISOpsGmodule  := rec( Print:= function( r )
                                 Print( "rec(\n",
                                        "dimension := ", r.dimension, ",\n",
                                        "matrices := ", r.matrices, ")\n" );
                                  end ),
                  SISOpsCohomology  := rec( Print:= function( r )
                                 Print( "rec(\n",
                                        "degree := ", r.degree, ",\n",
                                        "dimension := ", r.dimension, ",\n",
                                                   "cycleDimension := ", 
                                                   r.cycleDimension, ")\n" );
                                  end ) ) );


if not IsBound( p ) then p:= false; fi;


#############################################################################
##
#A  IsCompatiblePCentralSeries( <G> ) . . . .  compatible to p-central series
##
##  Let <G> be a polycyclicly presented $p$-group.
##  `IsCompatiblePCentralSeries' returns `true' if the presentation of <G> is
##  compatible to the exponent-$p$-central series of <G> in the sense that
##  the generators of each term of this series form a subset of
##  the generators of <G>.
##  Otherwise `false' is returned.
##
InstallMethod( IsCompatiblePCentralSeries,
    "for a (p-)group",
    [ IsGroup ],
# PcGroup?
    function( G )

    local p,             # prime dividing the order of `G'
          s,             # $p$-central series of `G'
          gens,          # generators of `G'
          iscompatible,  # boolean variable that is returned
          i,             # loop variable
          x;             # element of generator list

    # Check that the group is in fact a $p$-group.
    if not IsPGroup( G ) then
      return false;
    fi;

# and for trivial group??
    p:= PrimePGroup( G );
    s:= PCentralSeries( G, p );
    gens:= GeneratorsOfGroup( G );
    iscompatible:= true;
    i:= 1;
    while iscompatible and ( i < Length( s ) ) do
      for x in GeneratorsOfGroup( s[i] ) do
        iscompatible:= iscompatible and x in gens;
      od;
      i:= i+1;
    od;
    return iscompatible;
    end );
# better return inside?


#############################################################################
##
#F  OrderGL( <n>, <q> ) . . . . . . . . . . . . order of general linear group
##
InstallGlobalFunction( OrderGL, function ( n, q )

    local pi,   # q^i
          ord,  # order of GL(i,q)
          i;    # loop variable

    pi:= 1;
    ord := 1;
    for i in [1..n] do
      ord := ord * pi;
      pi  := pi  * q;
      ord := ord * (pi-1);
    od;
    return ord;
    end );


#############################################################################
##
#F  EstimateAmount( <G>, <flags> )  .  amount of memory needed in {\SISYPHOS}
##
InstallGlobalFunction( EstimateAmount, function( G, flags )

    local d,       # rank of <G>
          p,       # prime dividing the order of <G>
          sg,      # amount needed to store group presentation
          s,       # total amount
          ogl,     # order of $Gl('d','p')$
          n;       # $\log_{'p'}(\|<G>\|)$

    n:= Factors( Size( G ) );
    p:= n[1];
    n:= Length( n );
    d:= Length( Factors( Size( G ) / Size( FrattiniSubgroup( G ) ) ) );
    sg := 4*n^2*(n+1);
    ogl := OrderGL(d,p);

    s := (20+d*(n-d) )*d*n + 2*sg;
    if flags[1] then
      s := s + ogl*(d^2+50);
    fi;

    if flags[2] then
      s := s + 3*ogl*p^(d*(n-d))*d*n;
    fi;

    return Minimum ( 5000000, Maximum( 200000, s ) );
    end );


#############################################################################
##
#F  SisyphosWord( <pcgs>, <a> ) . . . . .  convert agword to {\SISYPHOS} word
##
#T  remove this, make it a special case of SisyphosGenWord!
##
InstallGlobalFunction( SisyphosWord, function( pcgs, a )

    local list,   # list of exponents of `a' w.r.t. `pcgs'
          k,      # position of first nonzero entry in `list', if exists
          count,  # number of printed characters in actual output line
          str,    # result string
          l;      # loop variable, actual position in `list'

    list:= ExponentsOfPcElement( pcgs, a );
    k:= 1;
    while k <= Length( list ) and list[k] = 0 do
      k:= k + 1;
    od;

    # special case of the identity element
    if Length( list ) < k then
      return "1";
    fi;

    count:= 16;
    str:= "g";
    Append( str, String( k ) );
    count:= count + Length( String( k ) );
    if list[k] <> 1 then
      Add( str, '^' );
      Append( str, String( list[k] ) );
      count:= count + 1 + Length( String( list[k] ) );
    fi;

    for l in [ k + 1 .. Length( list ) ] do
      if 60 < count then
        Append( str, "\n " );
        count:= 4;
      fi;
      if list[l] <> 0 then
        Append( str, "*g" );
        Append( str, String( l ) );
        count:= count + 2 + Length( String( l ) );
      fi;
      if 1 < list[l] then
        Add( str, '^' );
        Append( str, String( list[l] ) );
        count:= count + 1 + Length( String( list[l] ) );
      fi;
    od;

    # Return the result.
    return str;
    end );


#############################################################################
##
#F  SisyphosGenWord( <S>, <a>, <pp> )
##
InstallGlobalFunction( SisyphosGenWord, function( S, a, pp )

    local k,      # position of first nonzero entry in `a', if exists
          str,    # result string
          sl,     # length of string `S'
          l,      # loop variable, current position in `a'
          count;  # number of characters in current output line

    k:= 1;
    while k <= Length( a ) and a[k] = 0 do
      k:= k + 1;
    od;

    if pp then
      S:= Concatenation( S, "." );
    fi;

    # special case of the identity element
    if Length( a ) < k then
      return Concatenation( S, "id" );
    fi;

    str:= "";
    sl:= Length( S );
    count:= 15;
    Append( str, S );
    Append( str, String( k ) );
    count:= count + sl + Length( String( k ) );
    if a[k] <> 1  then
      Append( str, "^" );
      Append( str, String( a[k] ) );
      count:= count + 1 + Length( String( a[k] ) );
    fi;
    for l in [ k+1 .. Length( a ) ] do
      if 60 < count then
        Append( str, "\n " );
        count:= 4;
      fi;
      Append( str, "*" );
      Append( str, S );
      Append( str, String( l ) );
      count:= count + 1 + sl + Length( String( l ) );
      if a[ l ] > 1  then
        Append( str, "^" );
        Append( str, String( a[l] ) );
        count:= count + 1 + Length( String( a[l] ) );
      fi;
    od;

    # Return the result.
    return str;
    end );


#############################################################################
##
#F  SisyphosInputPGroup( <P>, <name>, <type>[, <weights>] )
##
InstallGlobalFunction( SisyphosInputPGroup, function( arg )

    local   P,            # $p$-group, argument
            name,         # name of `P', argument
            type,         # type of `P', argument
            str,          # result string
            weights,      # weights w.r.t. the Jennings series, argument
            gens,         # list of generators for `P'
            prime,        # prime dividing the order of `P'
            rank,         # rank of `P'
            rels,         # relators (of free presentation)
            relorders,    #
            i, j,         # loop variables
            w,            # word in `P'
            l;            # length of word `w'

    # Check the arguments.
    if Length( arg ) < 3 or Length( arg ) > 4
       or not IsGroup( arg[1] ) or not IsString( arg[2] )
       or not ( arg[3] = "pcgroup" or IsPrimeInt( arg[3] ) ) then
      Error( "usage: ",
             "SisyphosInputPGroup(<P>,<name>,<type>[,<weights>]),\n",
             "<type> must be \"pcgroup\" resp. a prime number" );
    elif Length( arg ) = 4 and arg[3] <> "pcgroup" then
      Error( "weights are allowed only for <type> = \"pcgroup\"" );
    fi;

    # Get the arguments.
    P    := arg[1];
    name := arg[2];
    type := arg[3];
    str  := ShallowCopy( name );

    if IsFpGroup( P ) then

      if not IsPrimeInt( type ) then
        Error( "<type> must be a prime integer in case of a f.p. group" );
      fi;

      prime:= type;
      rank:= PQuotient( P, prime, 1 ).dimensions[1];

      # Get the generators and relators for the group `P'.
      gens:= FreeGeneratorsOfFpGroup( P );
      rels:= RelatorsOfFpGroup( P );

      # Initialize group and generators.
      Append( str, " = group (" );
      if Length( gens ) = rank then
        Append( str, "minimal,\n" );
      fi;
      Append( str, String( prime ) );
      Append( str, ",\ngens(\n" );
      for i in [ 1 .. Length( gens ) - 1 ] do
        Append( str, String( gens[i] ) );
        Append( str, ",\n" );
      od;
      Append( str, String( gens[ Length( gens ) ] ) );
      Append( str, "),\nrels(\n" );

      for i in [ 1 .. Length( rels ) ] do
        w:= rels[i];
        l:= Length( w );
        while 12 < l do
          Append( str, String( Subword( w, 1, 12 ) ) );
          Append( str, "*\n" );
          w:= Subword( w, 13, l );
          l:= l - 12;
        od;
        Append( str, String( w ) );
        if i < Length( rels ) then
          Append( str, ",\n" );
        else
          Append( str, "));\n" );
        fi;
      od;

    elif IsPcGroup( P ) then

      if type <> "pcgroup" then
        type:= "group";
      fi;

      prime:= Set( Factors( Size( P ) ) );
      if Length( prime ) = 1 then
        prime:= prime[1];
      else
        Error( "Sisyphos allows p-groups only" );
      fi;

      # Get the generators for the group <P>.
      gens:= Pcgs( P );

      # Initialize group and generators.
      Append( str, " = " );
      Append( str, type );
      Add( str, '(' );
      Append( str, String( prime ) );
      Append( str, ",\ngens(\n" );
      for i in [ 1 .. Length( gens ) - 1 ] do
        Add( str, 'g' );
        Append( str, String( i ) );
        Append( str, ",\n" );
      od;
      Add( str, 'g' );
      Append( str, String( Length( gens ) ) );
      Append( str, "),\nrels(\n" );

      # Add the power presentation part.
      relorders:= RelativeOrders( gens );
      Append( str, "g1^" );
      Append( str, String( relorders[1] ) );
      Append( str, " = " );
      Append( str, SisyphosWord( gens, gens[1]^relorders[1] ) );
      for i in [ 2 .. Length( gens ) ] do
        Append( str, ",\ng" );
        Append( str, String( i ) );
        Add( str, '^' );
        Append( str, String( relorders[i] ) );
        Append( str, " = " );
        Append( str, SisyphosWord( gens, gens[i]^relorders[i] ) );
      od;

      # Add the commutator presentation part.
      for i in [ 1 .. Length( gens ) - 1 ] do
        for j in [ i + 1 .. Length( gens ) ] do
          w:= Comm( gens[j], gens[i] );
          if not IsOne( w ) then
            Append( str, ",\n[g" );
            Append( str, String( j ) );
            Append( str, ",g" );
            Append( str, String( i ) );
            Append( str, "] = " );
            Append( str, SisyphosWord( gens, w ) );
          fi;
        od;
      od;

      # If weights are given, add them.
      if Length( arg ) = 4 then
        Append( str, "),\nweights([" );
        for i in [ 1 .. Length( arg[4] )-1 ] do
          Append( str, String( arg[4][i] ) );
          Append( str, ",\n" );
        od;
        Append( str, String( arg[4][ Length( arg[4] ) ] ) );
        Add( str, ']' );
      fi;
        
      # Postamble.
      Append( str, "));\n" );

    else
      Error( "<P> must be a polycyclicly or freely presented p-group" );
    fi;

    return str;
    end );


#############################################################################
##
#F  SisyphosCall( <P>, <sisflags>, <estimflags>, <inputlines>, <resultcomp> )
##
InstallGlobalFunction( SisyphosCall,
    function( P, sisflags, estimflags, inputlines, resultcomp )

    local
          progname,  # filename of the `sis' executable
          tmpdir,    # temporary directory for the input and output file
          inputfile, # input file
          grpstr,
          prime,     #
          phi,       #
          qs,        #
          psi,       #
          isoP,      #
          p,         #
          type,      #
          estim,     #
          output,    #
          proc,      #
          result;    #

    # Check the input.
#T really check!

    # Choose the executable of the standalone.
    progname:= Filename( DirectoriesPackagePrograms( "sisyphos" ), "sis" );
    if progname = fail then
      Error( "did not find the `sis' executable" );
    fi;

    # Write the file with the data.
    tmpdir:= DirectoryTemporary();
    inputfile:= Filename( tmpdir, "input" );

    # Check if the presentation is normalized;
    # if not then compute a normalized presentation via `PQuotient'.
    if P = false then
      grpstr:= "";
    else

      prime:= Factors( Size( P ) )[1];
      if not IsCompatiblePCentralSeries( P ) then
        phi:= IsomorphismFpGroup( P );
        qs:= PQuotient( Image( phi ), prime, PClassPGroup( P ) );
        psi:= EpimorphismQuotientSystem( qs );
        isoP:= CompositionMapping2( psi, phi );
        SetIsBijective( isoP, true );
        p:= Image( isoP );
#T put this into an attribute?
      else
        p:= P;
      fi;

      # at this point the group p, that will be  passed to {\SISYPHOS},
      # is in any case given via a normalized pc-presentation.
      if IsPcGroup( p ) then
        type:= "pcgroup";
      else
        type:= prime;
      fi;

      grpstr:= SisyphosInputPGroup( p, "p", type );

    fi;

    if sisflags = false then
      sisflags:= "";
    else
      sisflags:= ShallowCopy( String( sisflags ) );
      sisflags[1]:= '(';
      sisflags[ Length( sisflags ) ]:= ')';
      sisflags:= Concatenation( "set ( flags, seq", sisflags, ");\n" );
    fi;

    # Write the input file for {\SISYPHOS}.
    PrintTo( inputfile,
             grpstr,
             sisflags,
             inputlines,
             "quit;\n" );

    # Compute the amount of memory needed.
    if IsBool( estimflags[1] ) then
      estim:= EstimateAmount( p, estimflags );
      estim:= [ String( estim ), String( Int( estim/3 ) ) ];
    else
      estim:= estimflags;
    fi;

    # Print a header to the output file.
    output:= OutputTextFile( Filename( tmpdir, "output" ), false );
    PrintTo( output, "local Igs, p;\nIgs:= Pcgs;\np:= SISYPHOS.p;\n" );
    CloseStream( output );
    output:= OutputTextFile( Filename( tmpdir, "output" ), true );

    # Call {\SISYPHOS}.
    proc:= Process( tmpdir,
             progname,
             InputTextFile( inputfile ),  # why not InputTextString?
             output, [ "-b", "-q",
                       "-s", "gap",
                       "-t", estim[1],
                       "-m", estim[2],
                     ] );

    if proc <> 0 then
      CloseStream( output );
      Error( "process did not succeed" );
    fi;

    AppendTo( output, "return SISYPHOS;\n" );
    CloseStream( output );

    # Read the output file.
    SISYPHOS.p:= p;
    result:= [ p, ReadAsFunction( Filename( tmpdir, "output" ) )() ];
    Unbind( SISYPHOS.p );

    # Check whether the output file contained the result.
    if not IsBound( result[2].( resultcomp ) ) then
      Error( "output file was not readable" );
    fi;

    if IsBound( isoP ) then
      Add( result, isoP );
    fi;

    # Return the result.
    return result;
    end );


#############################################################################
##
#E

