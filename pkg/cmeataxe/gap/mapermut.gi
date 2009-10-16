#############################################################################
##
#W  mapermut.gi        GAP share package 'cmeataxe'             Thomas Breuer
##
#H  @(#)$Id: mapermut.gi,v 1.1 2000/04/19 09:06:30 gap Exp $
##
#Y  Copyright (C)  2000,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the implementation for C-{\Meataxe} permutations.
##
##  1. Creating C-{\MeatAxe} permutations
##  2. Methods for the basic operations for permutations
##  3. Efficient methods for C-{\MeatAxe} permutations
##  4. Operations to show C-{\MeatAxe} permutations
##  5. Arithmetic operations for C-{\MeatAxe} permutations
##  6. Comparison operations for C-{\MeatAxe} permutations
##
Revision.( "cmeataxe/gap/mapermut_gi" ) :=                       
    "@(#)$Id: mapermut.gi,v 1.1 2000/04/19 09:06:30 gap Exp $";


#############################################################################
##
##  1. Creating C-{\MeatAxe} permutations
##


#############################################################################
##
#F  MeatAxePerm( <perm>[, <maxpoint>][, <file>] ) . construct {\MeatAxe} perm
#F  MeatAxePerm( <file> ) . . . . . . . . . . . . . .  notify {\MeatAxe} perm
##
InstallGlobalFunction( MeatAxePerm, function( arg )

    local file,     # file that will contain the C-{\MeatAxe} permutation
          perm,     # permutation, first argument
          maxpoint, # largest point in the C-{\MeatAxe} file
          pos,      # position in `arg'
          tmp,      # temporary file with ASCII permutation
          result;   # result

    if   1 = Length( arg ) and IsString( arg[1] ) then

      # Just notify a C-{\MeatAxe} permutation.
      # `MeatAxePerm( <file> )'
      file:= arg[1];
      if not IsExistingFile( file ) then
        Error( "file `", file, "' does not exist" );
      fi;

    elif 1 <= Length( arg ) and IsPerm( arg[1] ) then

      # `MeatAxePerm( <perm>[, <maxpoint>][, <file>] )'
      perm:= arg[1];
      if 2 <= Length( arg ) and IsPosInt( arg[2] ) then
        maxpoint:= arg[2];
        pos:= 3;
      else
        maxpoint:= LargestMovedPoint( perm );
        pos:= 2;
      fi;

      # Print the permutation to an intermediate file.
      tmp:= TmpName();
      PrintTo( tmp, MeatAxeString( [ perm ], maxpoint ) );
  
      if Length( arg ) = pos and IsString( arg[ pos ] ) then
        file:= arg[ pos ];
        if file[1] <> '/' then
          file:= Filename( CMeatAxeDirectoryCurrent(), file );
        fi;
      else
        file:= CMeatAxeFilename();
      fi;

      # Convert the permutation to the internal format.
      CMeatAxeProcess( CMeatAxeDirectoryCurrent(), "zcv", OutputTextNone(),
                       [ tmp, file ] );
  
    else

      Error( "usage: MeatAxePerm( <perm>[, <maxpoint>][, <file>] )\n",
             " or MeatAxePerm( <file> )" );

    fi;

    # Construct and return the C-{\MeatAxe} permutation.
    result:= Objectify( NewType( PermutationsFamily, IsCMeatAxePerm ),
                        rec() );
    SetCMeatAxeFilename( result, file );
    if IsBound( pos ) and pos = 2 then
      SetLargestMovedPoint( result, maxpoint );
    fi;
    return result;
    end );


#############################################################################
##
##  2. Methods for the basic operations for permutations
##
##  The basic operations are `LargestMovedPoint' and action of permutations
##  on positive integers via `\^'.
##  The default methods for C-{\MeatAxe} permutations delegate to their
##  `GapObject' values.
##


#############################################################################
##
#M  LargestMovedPoint( <mtxperm> )
##
InstallMethod( LargestMovedPoint,
    "for a MeatAxe permutation",
    [ IsCMeatAxePerm ],
    mtxperm -> LargestMovedPoint( GapObject( mtxperm ) ) );


#############################################################################
##
#M  \^( <posint>, <mtxperm> )
##
InstallMethod( \^,
    "for a positive integer, and a MeatAxe permutation",
    [ IsPosInt, IsCMeatAxePerm ],
    function( posint, mtxperm )
    return \^( posint, GapObject( mtxperm ) );
    end );


#############################################################################
##
##  3. Efficient methods for C-{\MeatAxe} permutations
##


#############################################################################
##
#M  Order( <mtxperm> )  . . . . . . . . . . . .  for a {\MeatAxe} permutation
##
#T why separate methods for perm. and matr.? 
##
InstallMethod( Order,
    "for a MeatAxe permutation",
    [ IsCMeatAxePerm ],
    function( mtxperm )

    local name;

    name:= TmpName();
    CMeatAxeProcess( MeatAxe.tmpdir, "zor", name, [ "-G", mtxperm!.file ] );

    Unbind( MeatAxe.Orders );
    Read( name );
    if not IsBound( MeatAxe.Orders ) then
      Error( "object is no no MeatAxe matrix or permutation" );
    fi;
    Unbind( MeatAxe.Orders );

    return MeatAxe.Orders[1];
    end );


#############################################################################
##
#M  GapObject( <mtxperm> )
##
InstallMethod( GapObject,
    "for a MeatAxe permutation",
    [ IsCMeatAxePerm ],
    function( mtxperm )

    local name,   # temporary file name
          result; # the {\GAP} permutation, result
  
    Info( InfoCMeatAxe, 1,
          "`GapObject' called for C-MeatAxe permutation\n",
          "#I  `", CMeatAxeFilename( mtxperm ), "'" );
          
    name:= TmpName();
    CMeatAxeProcess( CMeatAxeDirectoryCurrent(), "zpr", OutputTextNone(),
                     [ "-G", mtxperm!.mtxfile, name ] );
    Unbind( MeatAxe.Perms );
    Read( name );
    if not IsBound( MeatAxe.Perms ) then
      Error( "file `", CMeatAxeFilename( mtxperm ),
             "'does not contain C-MeatAxe permutations" );
    fi;
    if IsEmpty( MeatAxe.Perms ) then
      result:= ();
    else
      result:= MeatAxe.Perms[1];
    fi;
    Unbind( MeatAxe.Perms );
  
    return result;
    end );


#############################################################################
##
##  4. Operations to show C-{\MeatAxe} permutations
##


#############################################################################
##
#M  ViewObj( <mtxperm> ) . . . . . . . . . . . . for a {\MeatAxe} permutation
##
InstallMethod( ViewObj,
    "for a MeatAxe permutation",
    [ IsCMeatAxePerm ],
    function( mtxperm )
    Print( "MeatAxePerm( \"", CMeatAxeFilename( mtxperm ), "\" )" );
    end );


#############################################################################
##
#M  PrintObj( <mtxperm> )  . . . . . . . . . . . for a {\MeatAxe} permutation
##
InstallMethod( PrintObj,
    "for a MeatAxe permutation",
    [ IsCMeatAxePerm ],
    function( mtxperm )
    Print( "MeatAxePerm( \"", CMeatAxeFilename( mtxperm ), "\" )" );
    end );


#############################################################################
##
#F  Display( <mtxperm> ) . . . . . . . . . . . . for a {\MeatAxe} permutation
##
InstallMethod( Display,
    "for a MeatAxe permutation",
    [ IsCMeatAxePerm ],
    function( mtxperm )
    CMeatAxeProcess( CMeatAxeDirectoryCurrent(), "zpr", OutputTextNone(),
                     [ "-G", CMeatAxeFilename( mtxperm ) ] );
    end );


#############################################################################
##
##  5. Arithmetic operations for C-{\MeatAxe} permutations
##


#############################################################################
##
#M  \*( <p1>, <p2> )  . . . . for two perms., at least one a {\MeatAxe} perm.
##
##  Note that for the multiplications in each of the following methods,
##  the method itself is not applicable and thus the installations are safe.
##
InstallMethod( \*,
    "for two MeatAxe permutations",
    IsIdenticalObj,
    [ IsCMeatAxePerm, IsCMeatAxePerm ],
    function( p1, p2 )
    local name;     # file name of the result

    name:= CMeatAxeNewFilename();
    CMeatAxeProcess( CMeatAxeDirectoryCurrent(), "zmu", OutputTextNone(),
                     [ CMeatAxeFilename( p1 ), CMeatAxeFilename( p2 ),
                       name ] );
    return MeatAxePerm( name );
    end );

InstallMethod( \*,
    "for a MeatAxe permutation and a permutation",
    IsIdenticalObj,
    [ IsCMeatAxePerm, IsPerm ],
    function( p1, p2 )
    return GapObject( p1 ) * p2;
    end );

InstallMethod( \*,
    "for a permutation and a MeatAxe permutation",
    IsIdenticalObj,
    [ IsPerm, IsCMeatAxePerm ],
    function( p1, p2 )
    return p1 * GapObject( p2 );
    end );


#############################################################################
##
#M  InverseOp( <mtxperm> ) . . . . . . . . . . . for a {\MeatAxe} permutation
##
InstallMethod( InverseOp,
    "for a MeatAxe permutation",
    [ IsCMeatAxePerm ],
    function( mtxperm )
    local name, inverse;
    name:= CMeatAxeNewFilename();
    CMeatAxeProcess( CMeatAxeDirectoryCurrent(), "ziv", OutputTextNone(),
                     [ CMeatAxeFilename( mtxperm ), name ] );
    inverse:= MeatAxePerm( name );
    SetInverse( inverse, mtxperm );

#   if IsBound( mtxperm.abstract ) then
#     mtxperm.inverse.abstract:= mtxperm.abstract ^ -1;
#   fi;

    return inverse;
    end );


#############################################################################
##
#M  OneOp( <mtxperm> ) . . . . . . . . . . . . . for a {\MeatAxe} permutation
##
InstallMethod( OneOp,
    "for a MeatAxe permutation",
    [ IsCMeatAxePerm ],
    mtxperm -> MeatAxePerm( (), 0 ) );
    

#############################################################################
##
#M  \^( <mtxperm>, <n> )  . . . . . .  for {\MeatAxe} permutation and integer
##
InstallMethod( \^,
    "for a MeatAxe permutation, and an integer",
    [ IsCMeatAxePerm, IsInt ],
    function( mtxperm, n )

    local name;

    name:= CMeatAxeNewFilename();
    CMeatAxeProcess( CMeatAxeDirectoryCurrent(), "zpo", OutputTextNone(),
                        [ CMeatAxeFilename( mtxperm ), name ] );
    mtxperm:= MeatAxePerm( name );

#         if IsBound( mtxperm.abstract ) then
#           mtxperm.abstract:= mtxperm.abstract ^ n;
#         fi;

    return mtxperm;
    end );


#############################################################################
##
##  6. Comparison operations for C-{\MeatAxe} permutations
##
#T in fact for any two MeatAxe objects in the same family!


#############################################################################
##
#M  \=( <p1>, <p2> )  . . . for two objects, at least one a {\MeatAxe} object
##
##  Note that for all possible comparisons in a method, the method itself
##  is not applicable.
##
InstallMethod( \=,
    "for two MeatAxe objects",
    IsIdenticalObj,
    [ IsCMeatAxeObjRep, IsCMeatAxeObjRep ],
    function( p1, p2 )
#T first check identity of objects & file contents ??
    return GapObject( p1 ) = GapObject( p2 );
    end );

InstallMethod( \=,
    "for a MeatAxe object and an object",
    IsIdenticalObj,
    [ IsCMeatAxeObjRep, IsObject ],
    function( p1, p2 )
    return GapObject( p1 ) = p2;
    end );

InstallMethod( \=,
    "for an object and a MeatAxe object",
    IsIdenticalObj,
    [ IsObject, IsCMeatAxeObjRep ],
    function( p1, p2 )
    return p1 = GapObject( p2 );
    end );


#############################################################################
##
#M  \<( <p1>, <p2> )  . . . for two objects, at least one a {\MeatAxe} object
##
##  Note that for all possible comparisons in a method, the method itself
##  is not applicable.
##
InstallMethod( \<,
    "for two MeatAxe objects",
    IsIdenticalObj,
    [ IsCMeatAxeObjRep, IsCMeatAxeObjRep ],
    function( p1, p2 )
#T first check identity of objects & file contents ??
    return GapObject( p1 ) < GapObject( p2 );
    end );

InstallMethod( \<,
    "for a MeatAxe object and an object",
    IsIdenticalObj,
    [ IsCMeatAxeObjRep, IsObject ],
    function( p1, p2 )
    return GapObject( p1 ) < p2;
    end );

InstallMethod( \<,
    "for an object and a MeatAxe object",
    IsIdenticalObj,
    [ IsObject, IsCMeatAxeObjRep ],
    function( p1, p2 )
    return p1 < GapObject( p2 );
    end );


#############################################################################
##  
#E

