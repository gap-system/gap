#############################################################################
##
#W  compat3d.g                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the destructive part of the {\GAP}~3 compatibility
##  mode, i.e., those parts whose availability in {\GAP}~4 is possible only
##  at the cost of losing some {\GAP}~4 specific functionality.
##
##  This file should be read only via the `-O' option of {\GAP},
##  one should not simply read it via a `Read' or `ReadLib' statement.
##  *Note* that it is not possible to switch off the destructive part of the
##  compatibility mode once it has been loaded.
##
Revision.compat3d_g :=
    "@(#)$Id$";


#############################################################################
##
##  The files `compat3a.g', `compat3b.g', and `compat3b.g' must have been
##  read before this file can be read.
##
if not IsBound( Revision.compat3c_g ) then
  ReadLib( "compat3c.g" );
fi;


#############################################################################
##
##  Print a warning (preliminary proposal).
##
Print( "#I  Now the destructive part of the GAP 3 compatibility mode\n",
       "#I  is loaded.\n",
       "#I  This makes certain GAP 4 facilities unusable.\n",
       "#I  (If I would be in favour of misusing the literature then\n",
       "#I  I would express the effect of loading this mode as follows.\n",
       "#I  \n",
       "#I  ``Lasciate ogni speranza, voi ch' entrate!'')\n" );


#############################################################################
##
#F  Domain( <list> )
##
##  We must forbid calling `Domain'.
##  In {\GAP}~3, it was used as an oracle in the construction of domains,
##  it returned for example `FiniteFieldMatrices' or `Permutations'.
##
##  In {\GAP}~4, the various aspects of information to create domains are
##  described by the types of objects.
##
MakeReadWriteGlobal( "Domain" );

Domain := function( arg )
    Error( "this function is not available in GAP 4\n",
           "because the domain construction mechanism has changed" );
end;


#############################################################################
##
#F  IsString( <obj> )
##
##  In {\GAP}~3, `IsString' did silently convert its argument to the string
##  representation.
##
if not IsBound( OLDISSTRING ) then
    OLDISSTRING := IsString;
fi;

MakeReadWriteGlobal( "IsString" );

IsString := function( obj )
    local result;
    result:= OLDISSTRING( obj );
    if result then
      ConvertToStringRep( obj );
    fi;
    return result;
end;


#############################################################################
##
#E

