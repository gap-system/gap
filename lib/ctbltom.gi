#############################################################################
##
#W  ctbltom.gi                  GAP library                     Thomas Breuer
#W                                                            Thomas Merkwitz
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1998,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the interface between the {\GAP} libraries
##  of character tables and of tables of marks.
##
##  The interface consists of methods for the operations `CharacterTable' and
##  `TableOfMarks', with argument a table of marks and a character table,
##  respectively.
##  These methods try to get the coresponding character table resp.~table of
##  marks from the library.
##
##  If the required information is not found in the respective library,
##  and if no group is available from which this information can be computed
##  then `fail' returned.
##
##  The availability of the required information is looked up in the global
##  variable `TOM_TBL_INFO'.
##  If not both libraries are installed then `TOM_TBL_INFO' is emptied,
##  hence the methods mentioned above become trivial.
##
Revision.ctbltom_gi :=
    "@(#)$Id$";


#############################################################################
##
##  Delete the information in `TOM_TBL_INFO' if not both the library of
##  character tables and the library of tables of marks are  installed.
##
if not( TBL_AVAILABLE and TOM_AVAILABLE ) then
  TOM_TBL_INFO:= [ [], [] ];
fi;


#############################################################################
##
#M  TableOfMarks( <tbl> ) . . . . . . . . . . . . . . . for a character table
#M  TableOfMarks( <G> )
##
##  We delegate from <tbl> to the underlying group in the general case.
##
##  If the argument is a group, we can use the known table of marks of the
##  known ordinary character table.
##
InstallOtherMethod( TableOfMarks,
    "for a character table with underlying group",
    true,
    [ IsCharacterTable and HasUnderlyingGroup ], 0,
    tbl -> TableOfMarks( UnderlyingGroup( tbl ) ) );


#T make `TableOfMarks' an attribute!
#T InstallOtherMethod( TableOfMarks,
#T     "for a group with known ordinary character table",
#T     true,
#T     [ IsGroup and HasOrdinaryCharacterTable ], 100,
#T #T ?
#T     function( G )
#T     local tbl;
#T     tbl:= OrdinaryCharacterTable( G );
#T     if HasTableOfMarks( tbl ) then
#T       return TableOfMarks( tbl );
#T     else
#T       TryNextMethod();
#T     fi;
#T     end );


#############################################################################
##
#M  TableOfMarks( <tbl> ) . . . . . . . . . . . for a library character table
##
##  If <tbl> is a library character table then we check whether there is a
##  corresponding table of marks in the library.
##  If there is no such table of marks but <tbl> knows a group then we
##  delegate to this group.
##  Otherwise we return `fail'.
##
InstallOtherMethod( TableOfMarks,
    "for a library character table",
    true,
    [ IsOrdinaryTable and IsLibraryCharacterTableRep ], 0,
    function( tbl )
    local pos;
    pos:= Position( TOM_TBL_INFO[1], Identifier( tbl ) );
    if pos <> fail then
      return TableOfMarks( TOM_TBL_INFO[2][ pos ] );
    elif HasUnderlyingGroup( tbl ) then
      TryNextMethod();
    fi;
    return fail;
    end );


#############################################################################
##
#M  CharacterTable( <tom> ) . . . . . . . . . . . . . .  for a table of marks
#M  CharacterTable( <G> )
##
##  We delegate from <tom> to the underlying group in the general case.
##
##  If the argument is a group, we can use the known character table of the
##  known table table of marks.
##
InstallOtherMethod( CharacterTable,
    "for a table of marks with underlying group",
    true,
    [ IsTableOfMarks and HasUnderlyingGroup ], 0,
    tom -> CharacterTable( UnderlyingGroup( tom ) ) );


#T make `TableOfMarks' an attribute!
#T InstallOtherMethod( CharacterTable,
#T     "for a group with known table of marks",
#T     true,
#T     [ IsGroup and HasTableOfMarks ], 100,
#T #T ?
#T     function( G )
#T     local tom;
#T     tom:= TableOfMarks( G );
#T     if HasOrdinaryTable( tom ) then
#T       return OrdinaryTable( tom );
#T     else
#T       TryNextMethod();
#T     fi;
#T     end );


#############################################################################
##
#M  CharacterTable( <tom> ) . . . . . . . . . .  for a library table of marks
##
##  If <tom> is a library table of marks then we check whether there is a
##  corresponding character table in the library.
##  If there is no such character table but <tom> knows a group then we
##  delegate to this group.
##  Otherwise we return `fail'.
##
InstallOtherMethod( CharacterTable,
    "for a library table of marks",
    true,
    [ IsTableOfMarks and IsLibTomRep ], 0,
    function( tom )
    local pos;
    pos:= Position( TOM_TBL_INFO[2], IdentifierOfTom( tom ) );
    if pos <> fail then
      return CharacterTable( TOM_TBL_INFO[1][ pos ] );
    elif HasUnderlyingGroup( tom ) then
      TryNextMethod();
    fi;
    return fail;
    end );


#############################################################################
##
#E  ctbltom.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

