#############################################################################
##
#W  string.g                     GAP library                    Thomas Breuer
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file deals with strings and characters.
##
Revision.string_g :=
    "@(#)$Id$";


#############################################################################
##
#C  IsChar  . . . . . . . . . . . . . . . . . . . . .  category of characters
##
##  is the category of characters.
DeclareCategory( "IsChar", IS_OBJECT );


#############################################################################
##
#C  IsString  . . . . . . . . . . . . . . . . . . . . . . category of strings
##
##  A string is a dense list of characters. 
#T  will *not* change the representation. (still true? AH)
##
DeclareCategoryKernel( "IsString", IsDenseList, IS_STRING );

#T  1996/08/23  M.Schoenert this is a hack because 'IsString' is a category
Add( CATEGORIES_COLLECTIONS, [ IsChar, IsString ] );


#############################################################################
##
#V  CharsFamily . . . . . . . . . . . . . . . . . . . .  family of characters
##
CharsFamily := NewFamily( "CharsFamily", IsChar );


#############################################################################
##
#V  TYPE_CHAR . . . . . . . . . . . . . . . . . . . . . . type of a character
##
TYPE_CHAR := NewType( CharsFamily, IsChar and IsInternalRep );


#############################################################################
##

#F  IsEmptyString . . . . . . . . . . . . . . . . . . . . empty string tester
##
##  Note that empty list and empty string have the same type, the only way to
##  distinguish them is via 'TNUM_OBJ'.
##
IsEmptyString := function( obj )
    return     IsString( obj )
           and IsEmpty( obj )
           and TNUM_OBJ( obj ) = TNUM_OBJ( "" );
end;


#############################################################################
##
#F  ConvertToStringRep  . . . . . . . . . . . . . . . . .  inplace conversion
##
ConvertToStringRep := CONV_STRING;


############################################################################
##

#M  String( <str> ) . . . . . . . . . . . . . . . . . . . . . .  for a string
##
InstallMethod( String,
    "method for a string",
    true,
    [ IsString ], 0,
    IdFunc );


#############################################################################
##

#E  string.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
