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


#############################################################################
##
#F  WordAlp( <alpha>, <nr> )  . . . . . .  <nr>-th word over alphabet <alpha>
##
##  is a string that is the <nr>-th word over the alphabet <alpha>,
##  w.r. to word length and lexicographical order.
##  The empty word is 'WordAlp( <alpha>, 0 )'.
##
WordAlp := function( alpha, nr )

    local lalpha,   # length of the alphabet
          word,     # the result
          nrmod;    # position of letter

    lalpha:= Length( alpha );
    word:= "";
    while nr <> 0 do
      nrmod:= nr mod lalpha;
      if nrmod = 0 then nrmod:= lalpha; fi;
      Add( word, alpha[ nrmod ] );
      nr:= ( nr - nrmod ) / lalpha;
    od;
    return Reversed( word );
end;


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
