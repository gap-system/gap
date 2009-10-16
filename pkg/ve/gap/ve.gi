#############################################################################
##
#W  ve.gi                   GAP Share Library                    Steve Linton
##
#H  @(#)$Id: ve.gi,v 1.1 1998/03/12 14:56:26 gap Exp $
##
#Y  Copyright (C) 1998,  Lehrstuhl D fuer Mathematik,  RWTH, Aachen,  Germany
##
##  This file contains the implementation part of the interface
##  between {\GAP} and {\VE}.
##
Revision.pkg_ve_gap_ve_gi :=
    "@(#)$Id: ve.gi,v 1.1 1998/03/12 14:56:26 gap Exp $";


#############################################################################
##
#V  VE  . . . . . . . . . . . global variable used for the interface to {\VE}
##
InstallValue( VE, rec(
    ncols := 80,
    options := [ "-p", "input",    # presentation file `input.pres'
                 "-o", "output",   # output file `output.g'
                 "-i",             # images
                 "-P",             # preimages
                 "-v0",            # suppress comments
                 "-L'#I  `",       # but set prefix if someone wants comments
                 "-Y", "VE.out",   # assign result to `VE.out'
               ],
    me := "me",
    qme := "qme",
    zme := "zme" ) );


#############################################################################
##
#F  StringVEInput( <A>, <Mgens>, <names>, <ncols> )
#F                                            input for the Vector Enumerator
##
InstallGlobalFunction( StringVEInput, function( A, Mgens, names, ncols )

    local i, j, k,            # loop variables
          str,                # the result string
          char,               # characteristic of the algebra
          Agenerators,        # external representations of generators
          free,               # space in actual line
          App,                # `Append' function taking care of line length
          app_algelmstring,   # local function dealing with algebra elements
          rels,               # relators of the algebra
          grouptyperels,      # group type relators
          otherrels,          # non-group type relators
          one,
          extrep,
          invertible,
          involutions,
          dim,
          entry;

    if not IsSubalgebraFpAlgebra( A ) then
      Error( "<A> must be a finitely presented algebra" );
    elif not ( HasIsAssociative( A ) and IsAssociative( A ) ) then
      Error( "<A> must be (known to be) associative" );
    fi;

    free:= ncols;

    # Initialize the string.
    str:= "";

    # 1. Characteristic of the algebra
    char:= Characteristic( A );
    if char <> 0 then
      if char > 255 or not IsPrimeField( LeftActingDomain( A ) ) then
        Error( "calculations only over prime fields of char. < 256" );
      fi;
    fi;
    Append( str, String( char ) );
    Append( str, ".\n" );

    Agenerators:= List( GeneratorsOfAlgebraWithOne( A ),
                        a -> ExtRepOfObj( a )[2][1][1] );

    # Append `string' to `str',
    # without producing `\' at the end of the lines
    App:= function( string )
      local len;
      len:= Length( string );
      Assert( 1, ncols <= len );
      if len <= free then
        Append( str, string );
        free:= free - len;
      else
        Append( str, "\n" );
        Append( str, string );
        free:= ncols - len;
      fi;
      if str[ Length( str ) ] = '\n' then
        free:= ncols;
      fi;
    end;

    # Append the string of an algebra element to `str',
    # in terms of the new generator names.
    app_algelmstring:= function( elm )
      local j, k, coeff;

      # zero element
      if IsEmpty( elm ) then
        App( "0" );

      # `elm' is the external representation of
      # either an algebra element or a word.
      elif not IsList( elm[1] ) then
        elm:= [ elm, 1 ];
      fi;

      for j in [ 1, 3 .. Length( elm )-1 ] do

        # Handle the coefficient `elm[j+1]'.
        if char = 0 then
          coeff:= elm[ j+1 ];
        else
          coeff:= Int( elm[ j+1 ] );
        fi;
        if 1 < j and 0 < coeff then
          App( "+" );
        fi;

        if coeff <> 0 and coeff <> 1 then
          App( String( coeff ) );
          if not IsEmpty( elm[j] ) then
            App( "*" );
          fi;
        elif coeff = 1 and IsEmpty( elm[j] ) then
          App( "1" );
        fi;

        # Handle the word described by `elm[j]'.
        for k in [ 1, 3 .. Length( elm[j] )-1 ] do
          if 1 < k then
            App( "*" );
          fi;
          App( names[ Position( Agenerators, elm[j][k] ) ] );
          if 1 < elm[j][ k+1 ] then
            App( String( elm[j][ k+1 ] ) );
          fi;
        od;

      od;
    end;

    # Distribute algebra relators to
    # group type relators and other relators.
    # `grouptyperels' will contain all <w> for relators of form
    # `\pm(<w>-1)' in `<A>.relators'.
    # `otherrels' will contain the other relators *themselves*,
    # i.e. as records.
    # *Note* that at this stage also those relators are considered
    # to be group type relators that may contain non-invertible
    # generators.
    rels:= ElementsFamily( FamilyObj( A ) )!.relators;
    grouptyperels:= [];
    otherrels:= [];
    one:= One( LeftActingDomain( A ) );

    for entry in rels do
      extrep:= ExtRepOfObj( entry )[2];
      if     Length( extrep ) = 4
         and IsEmpty( extrep[1] )
         and ( ( extrep[2] = one and extrep[4] = - one )
            or ( extrep[4] = one and extrep[2] = - one ) )
        then
        Add( grouptyperels, extrep[3] );
      else
        Add( otherrels, extrep );
      fi;
    od;

    # 2. Generators of the algebra:
    #    new names, separated by blanks
    for i in names do
      App( i );
      App( " " );
    od;
    App( ".\n" );

    # 2a. Generators not known to be invertible:
    #     Take the difference of all generators and those
    #     that have a left and right inverse.
    invertible:= Intersection2(
                  List( grouptyperels, x -> x[1] ),
                  List( grouptyperels, x -> x[ Length(x)-1 ] ) );

    if IsEmpty( invertible ) then

      # no invertible generators
      App( "*..\n" );

    else

      for i in Difference( Agenerators, invertible ) do
        App( names[ Position( Agenerators, i ) ] );
        App( " " );
      od;
      App( ".\n" );

    # 2b. Generators not known to be involutions:
    #     Take those invertible generators for that
    #     the square is not a group type relator.

      involutions:= Filtered( invertible, x -> [ x, 2 ] in grouptyperels );
      if IsEmpty( involutions ) then
        App( "*.\n" );
      else
        for i in Difference( invertible, involutions ) do
          App( names[ Position( Agenerators, i ) ] );
          App( " " );
        od;
        App( ".\n" );
      fi;
    fi;

    # Move those relators from `grouptyperels' to `otherrels'
    # that contain non-invertible generators.
    for i in [ 1 .. Length( grouptyperels ) ] do
      if ForAny( [ 1, 3 .. Length( grouptyperels[i] )-1 ],
                 x -> not grouptyperels[i][x] in invertible ) then
        AddSet( otherrels, [ [], one, grouptyperels[i], -one ] );
        Unbind( grouptyperels[i] );
      fi;
    od;

    # 4. Submodule Generators
    # rank of the module
    dim:= Length( Mgens[1] );
    App( "{" );
    App( String( dim ) );
    App( "}" );

    # generators of the submodule, separated by `,',
    # each enclosed in `( )',
    for i in [ 1 .. Length( Mgens ) ] do
      App( "(" );
      for j in [ 1 .. dim ] do
        app_algelmstring( ExtRepOfObj( Mgens[i][j] )[2] );
        if j < dim then
          App( "," );
        fi;
      od;
      App( ")" );
      if i < Length( Mgens ) then
        App( ",\n" );
      fi;
    od;
    App( ".\n" );

    # 3. Algebra Relators, first the group type relators ...
    for i in [ 1 .. Length( grouptyperels ) ] do
      if IsBound( grouptyperels[i] ) then
        app_algelmstring( grouptyperels[i] );
        App( ", " );
      fi;
    od;
    App( ":\n" );

    #    ... and then the others
    for i in otherrels do
      app_algelmstring( i );
      App( " = 0, " );
    od;

    # The presentation is complete.
    App( ".\n" );

    # Return the string.
    return str;
end );


#############################################################################
##
#F  VEOutput( <A>, <Mgens>, <options>[, "mtx"] )
##
InstallGlobalFunction( VEOutput, function( arg )

    local A,          # 1st argument
          Mgens,      # 2nd argument
          options,    # 3rd argument
          mtx,        # boolean: 4th argument `"mtx"'?
          F,          # coefficiants ring of `A'
          command,    # name of the appropriate standalone program
          progname,   # filename of the executable
          Agens,      # generators of `A'
          alpha,      # alphabet over which names of generators are written
          lalpha,     # length of `alpha'
          i,
          names,      # names of generators used by {\VE}
          string,     # text of the presentation file
          tmpdir,     # directory in which the process is executed
          inputfile,  #
          output,     #
          proc,       # the process
          result,     # result of the call to {\VE}
          preim,      # preimages of module generators
          zero,       # zero of the algebra
          gens,       # list of generators
          dir,        # temporary directory name (for {\MeatAxe} output)
          name,       # one generator name (for {\MeatAxe} output)
          dimensions; # dimensions of matrices (for {\MeatAxe} output)

    # Get and check the arguments.
    if Length( arg ) < 3 or 4 < Length( arg ) then
      Error( "usage: VEOutput(<A>,<Mgens>,<options>[,<mtx>])" );
    elif not ( IsAlgebra( arg[1] ) and IsSubalgebraFpAlgebra( arg[1] )
                                   and IsAssociative( arg[1] ) ) then
      Error( "<A> must be a f.p. associative algebra" );
    elif not IsMatrix( arg[2] ) then
      Error( "<Mgens> must be a matrix of elements of <A>" );
    fi;
    A       := arg[1];
    Mgens   := arg[2];
    options := arg[3];

    mtx:= Length( arg ) = 4 and arg[4] = "mtx";

    # Check that the input can be processed by the standalone.
    F:= LeftActingDomain( A );
    if Characteristic( F ) = 0 then

      if F = Integers then
#T no `=' for Integers in GAP 3 ...
        command:= VE.zme;
      elif F = Rationals then
        command:= VE.qme;
      else
        Error( "characteristic 0: `Integers' and `Rationals' only" );
      fi;

      if mtx then
        Error( "MeatAxe output only for nonzero characteristic" );
      fi;

    elif 255 < Characteristic( F ) then
      Error( "`me' allows finite characteristic up to 255 only" );
    else
      command:= VE.me;
    fi;

    # Choose the executable of the standalone.
    progname:= Filename( DirectoriesPackagePrograms( "ve" ),
                         command );
    if progname = fail then
      Error( "did not find the executable for the vector enumerator" );
    fi;

    # Construct a list `names' of names for the generators
    # consisting only of letters.
    # Provide that no generator name is initial part of another
    # by choosing nonzero minimal length,
    # namely if we have $k$ generators and an alphabet of length $n$
    # then choose words of length $i+1$ where $n^i \< k \leq n^{i+1}$,
    # the first word having number $n + n^2 + \cdots + n^i$.
    Agens:= GeneratorsOfAlgebraWithOne( A );
    alpha:= "abcdefghijklmnopqrstuvwxyz";
    lalpha:= Length( alpha );
    i:= 1;
    while lalpha ^ i < Length( Agens ) do i:= i+1; od;
    i:= Sum( [ 1 .. i-1 ], x -> lalpha^x );
    names:= List( [ 1 .. Length( Agens ) ],
                  x -> WordAlp( alpha, x+i ) );

    # Produce the input file for {\VE}.
    string:= StringVEInput( A, Mgens, names, VE.ncols );
    tmpdir:= DirectoryTemporary();
    inputfile:= Filename( tmpdir, "input.pres" );
    PrintTo( inputfile, string );

    # Compose the options.
    options:= Concatenation( VE.options, options );

    # Call the standalone function.
    output:= OutputTextFile( Filename( tmpdir, "output" ), false );
    proc:= Process( tmpdir,
             progname,
             InputTextNone(),
             output,
             options );
    CloseStream( output );
    if proc <> 0 then
      Error( "process `", progname, "' did not succeed" );
    fi;

    # Read the output.
    Unbind( VE.out );
    Read( Filename( tmpdir, "output.g" ) );
#T     EXEC( "rm ", outfile, ".g " );

    # Check whether the output file contained the result.
    if not IsBound( VE.out ) then
      Error( "vector enumerator output file was not readable" );
    fi;
    result:= VE.out;
    Unbind( VE.out );

    if not mtx then

      # {\GAP} output.
      # 1. Decode the `preImages' component.
      preim:= [];
      zero:= ListWithIdenticalEntries( Length( Mgens[1] ), Zero( A ) );
      gens:= List( names, i -> result.( Concatenation( "g", i ) ) );
      for i in [ 1 .. Length( result.preImages ) ] do
        preim[i]:= ShallowCopy( zero );
#T         preim[i][ result.preImages[i].modGen ]:=
#T           MappedWord( result.preImages[i].word, gens, Agens );
#T (use new encoding of words via lists of integers!
      od;

      # 2. Add the information needed to construct
      #    the operation (algebra) homomorphism.
      result.operation:= rec( genimages  := result.gens,
                              moduleinfo := rec(
                                  preimagesBasis := preim,
                                  genimages := result.images_mat ) );

    else

Error( "MeatAxe output is not yet supported" );
#T       # {\MeatAxe} output (constructed with option `-H')
#T       # 1. Get the dimensions of the matrices.
#T       dimensions:= [ result.dim, result.dim ];
#T 
#T #T collapse?
#T       # 2. Convert to internal format.
#T       #    Change the file names in order to have a common stem, extended
#T       #    by numbers only.
#T !!
#T       dir:= VEMeatAxe.TmpName();
#T       EXEC( "mkdir ", dir );
#T       AddSet( VEMeatAxe.dirs, dir );
#T !!
#T 
#T       gens:= [];
#T       for i in [ 1 .. Length( names ) ] do
#T 
#T         # The new file name
#T         name:= Concatenation( dir, "/g.", String( i ) );
#T 
#T #T field info file?
#T         # Convert to internal format.
#T         EXEC( VEMeatAxe.PATH, "zcv ", outfile, ".", names[i], " ", name );
#T 
#T         # Make clean.
#T #T        EXEC( "rm ", outfile, ".", names[i] );
#T 
#T         # Notify the {\MeatAxe} matrix.
#T         gens[i]:= VEMeatAxeMat( name, F, dimensions );
#T         gens[i].gensname:= Concatenation( dir, "/g" );
#T 
#T       od;
#T 
#T       # 3. Store the generators.
#T       result.gens:= gens;
#T 
#T       # 4. Add the information needed to construct
#T       # the operation (algebra) homomorphism.
#T       result.operation:= rec( genimages := gens,
#T                               gensname  := Concatenation( dir, "/g" ) );

    fi;

    return result;
end );


#############################################################################
##
#M  OperationAlgebraHomomorphism( <A>, <Mgens>, <opr> )
#T change this: second argument should be the <A>-module itself!
##
#M  OperationAlgebraHomomorphism( <A>, <Q>, <opr> )
#M  OperationAlgebraHomomorphism( <A>, <Q>, "mtx" )
##
##  takes a finitely presented algebra <A> and a quotient module <Q> of a
##  free <A>-module, and returns the matrix representation computed by {\VE}.
##
##  If the third argument is the string `"mtx"' then the output is an algebra
##  of {\MeatAxe} matrices.
##
InstallOtherMethod( OperationAlgebraHomomorphism,
    "for full f.p. associative FLMLOR, a module, and a function (call VE)",
    IsElmsCollsX,
    [ IsFLMLORWithOne and IsSubalgebraFpAlgebra and IsAssociative
      and IsFullFpAlgebra, IsObject, IsObject ], 0,
    function( A, Mgens, opr )

    local F,          # coefficients ring
          output,     # output of {\VE}
          image,      # matrix algebra, image of the operation
          ophom;      # returned homomorphism

    # Check the arguments.
    if not IsList( Mgens ) then
      Error( "<A> must be f.p. algebra, <M> list of submodule generators" );
    fi;

    F:= LeftActingDomain( A );

    # Call the appropriate standalone with standard options.
    if opr = "mtx" then

      # Choose {\MeatAxe} output.
      output:= VEOutput( A, Mgens, [ "-m", "-H" ], "mtx" );

    else

      # Choose {\GAP} output.
      output:= VEOutput( A, Mgens, [ "-G" ] );

    fi;

    # Make the image algebra.
    # Check for the special case of total collapse.
    if IsEmpty( output.gens[1] ) or DimensionsMat( output.gens[1] )[1] = 0 then

      output.operation.genimages:= ListWithIdenticalEntries(
          Length( output.gens ), EmptyMatrix( F ) );
      image:= NullAlgebra( F );

    else

      image:= AlgebraWithOneByGenerators( F, output.gens );

    fi;

    # Make the homomorphism.
    ophom:= Objectify( NewType( GeneralMappingsFamily(
                                  ElementsFamily( FamilyObj( A ) ),
                                  CollectionsFamily( FamilyObj(
                                      LeftActingDomain( A ) ) ) ),
                                  IsSPGeneralMapping
                              and IsAlgebraHomomorphism
                              and IsOperationAlgebraHomomorphismFromFpRep ),
                     rec(
                          operation := opr,
                          Agenerators := GeneratorsOfAlgebraWithOne( A ),
                          Agenimages  := output.gens
                         ) );
    SetSource( ophom, A );
    SetRange( ophom, image );
    SetIsSurjective( ophom, true );

    # Handle the case that the basis is empty.
    if IsTrivial( image ) then

      ophom!.basisImage          := BasisOfDomain( image );
      ophom!.preimagesBasisImage := [ Zero( A ) ];

      SetKernelOfAdditiveGeneralMapping( ophom, A );

    fi;

#T still to add somewhere as soon as I can deal with preimages!
#T     result.operation:= output.operation;
#T     result.operation.genpreimages:=
#T           A.generators{ List( result.generators,
#T                         x -> Position( output.operation.genimages, x ) ) };

    # Return the operation homomorphism.
    return ophom;
    end );


#############################################################################
##
#E  ve.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

