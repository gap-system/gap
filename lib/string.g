#############################################################################
##
#W  string.g                     GAP library                    Thomas Breuer
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file deals with strings and characters.
##
Revision.string_g :=
    "@(#)$Id$";


#############################################################################
##

#C  IsChar  . . . . . . . . . . . . . . . . . . . . .  category of characters
##
IsChar := NewCategory( "IsChar", IS_OBJECT );


#############################################################################
##
#C  IsString  . . . . . . . . . . . . . . . . . . . . . . category of strings
##
##  This will *not* change the representation.
##
IsString := NewCategoryKernel( 
    "IsString",
    IsDenseList,
    IS_STRING );

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

#M  Int( <str> )  . . . . . . . . . . . . . . . . integer described by  <str>
##
InstallOtherMethod( Int,
    true,
    [ IsString ],
    0,

function( str )
    local   m,  z,  d,  i,  s;

    m := 1;
    z := 0;
    d := 1;
    for i  in [ 1 .. Length(str) ]  do
        if i = d and str[i] = '-'  then
            m := m * -1;
            d := i+1;
        else
            s := Position( "0123456789", str[i] );
            if s <> fail  then
                z := 10 * z + (s-1);
            else
                return fail;
            fi;
        fi;
    od;
    return z * m;
end );



#############################################################################
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
