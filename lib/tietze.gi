#############################################################################
##
#W  tietze.gi                  GAP library                     Volkmar Felsch
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the methods for Tietze transformations of presentation
##  records (i.e., of presentations of finitely presented groups (fp groups).
##
Revision.tietze_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  TzSort( <Tietze record> ) . . . . . . . . . . . . . . . . . sort relators
##
##  'TzSort'  sorts the relators list of the given Tietze Record T, say, and,
##  in parallel, the search flags list.  Note:  All relators  of length 0 are
##  removed from the list.
##
##  The sorting algorithm used is the same as in the GAP function Sort.
##
TzSort := function ( T )

    if T.printLevel >= 3 then  Print( "#I  sorting the relators\n" );  fi;

    # check the given argument to be a Tietze record.
    if not ( IsBound( T.isTietze ) and T.isTietze ) then
        Error( "argument must be a Tietze record" );
    fi;

    if T.tietze[TZ_NUMRELS] > 1 then  TzSortC( T.tietze );  fi;
end;


#############################################################################
##
#M  TzWordRelator( <fgens>, <rel> ) . . . . . . . . .                     
##
##  'TzWordRelator'  
##
##  'TzWordRelator' expects <fgens> to be a list of free group generators
##  and their inverses, and it expects <rel> to be a relator in these
##  generators and inverses. It converts the given relator to a Tietze word
##  and returns that Tieze word. If <rel> is not a word in the given free
##  generators, it returns 'fail', instead.
##
TzWordRelator := function ( fgens, rel )

    local i, i1, i2, tzword;

    # convert the given relator to a Tietze word.
    i1 := 1;
    i2 := LengthWord( rel );
    while i1 < i2 and
        Subword( rel, i1, i1 ) = Subword( rel, i2, i2 )^-1 do 
        i1 := i1 + 1;
        i2 := i2 - 1;
    od;
    tzword := List( [ i1 .. i2 ],
        i -> Position( fgens, Subword( rel, i, i ) ) );

    # return fail, if the given relator is not a word in the given
    # generators.
    if fail in tzword then tzword := fail; fi;

    return tzword;
end;


#############################################################################
##
#E  tietze.gi  . . . . . . . . . . . . . . . . . . . . . . . . . .. ends here


