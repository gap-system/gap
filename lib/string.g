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
#C  IsChar( <obj> ) . . . . . . . . . . . . . . . . .  category of characters
#C  IsCharCollection( <obj> ) . . . . . category of collections of characters
##
##  A *character* is simply an object in {\GAP} that represents an arbitrary
##  character from the character set of the operating system.
##  Character literals can be entered in {\GAP} by enclosing the character
##  in *singlequotes* `{'}'.
##
DeclareCategory( "IsChar", IS_OBJECT );

DeclareCategoryCollections( "IsChar" );


#############################################################################
##
#C  IsString( <obj> ) . . . . . . . . . . . . . . . . . . category of strings
##
##  A *string* is simply a dense list (see~"IsList", "IsDenseList")
##  of characters (see~"IsChar"); thus strings are always homogeneous
##  (see~"IsHomogeneousList").
##  Strings are used mainly in filenames and error messages.
##  A string literal can either be entered simply as the list of characters
##  or by writing the characters between *doublequotes* `\"'.
##  {\GAP} will always output strings in the latter format.
##
DeclareCategoryKernel( "IsString", IsHomogeneousList, IS_STRING );

InstallTrueMethod( IsString, IsCharCollection and IsList );


#############################################################################
##
#R  IsStringRep( <obj> )
##
##  `IsStringRep' is a special (internal) representation of dense lists
##  of characters.
##  Dense lists of characters can be converted into this representation
##  using `ConvertToStringRep'.
##  Note that calling `IsString' does *not* change the representation.
##
DeclareRepresentationKernel( "IsStringRep",
    IsInternalRep, [], IS_OBJECT, IS_STRING_REP );


#############################################################################
##
#F  ConvertToStringRep( <obj> ) . . . . . . . . . . . . .  inplace conversion
##
##  If <obj> is a dense internally represented list of characters then
##  `ConvertToStringRep' changes the representation to `IsStringRep'.
##  This is useful in particular for converting the empty list `[]',
##  which usually is in `IsPlistRep', to `IsStringRep'.
##  If <obj> is not a string then `ConvertToStringRep' signals an error.
##
BIND_GLOBAL( "ConvertToStringRep", CONV_STRING );


#############################################################################
##
#V  CharsFamily . . . . . . . . . . . . . . . . . . . .  family of characters
##
##  Each character lies in the family `CharFamily',
##  each nonempty string lies in the collections family of this family.
##  Note the subtle differences between the empty list `[]' and the empty
##  string `\"\"' when both are printed.
##
BIND_GLOBAL( "CharsFamily", NewFamily( "CharsFamily", IsChar ) );


#############################################################################
##
#V  TYPE_CHAR . . . . . . . . . . . . . . . . . . . . . . type of a character
##
BIND_GLOBAL( "TYPE_CHAR", NewType( CharsFamily, IsChar and IsInternalRep ) );


#############################################################################
##
#F  IsEmptyString( <str> )  . . . . . . . . . . . . . . . empty string tester
##
##  `IsEmptyString' returns `true' if <str> is the empty string in the
##  representation `IsStringRep', and `false' otherwise.
##  Note that the empty list `[]' and the empty string `\"\"' have the same
##  type, the recommended way to distinguish them is via `IsEmptyString'.
##  For formatted printing, this distinction is sometimes necessary.
#T The type is the same because `IsStringRep' is not *set* in this type,
#T and `IsPlistRep' is *set*,
#T although *calling* `IsStringRep' for `[]' yields `false',
#T and *calling* `IsPlistRep' for `\"\"' yields `false', too.
#T Why is `TNUM_OBJ_INT' used here,
#T calling `IsStringRep' would be enough, or?
##
BIND_GLOBAL( "TNUM_EMPTY_STRING",
             [ TNUM_OBJ_INT( "" ), TNUM_OBJ_INT( Immutable( "" ) ) ] );

BIND_GLOBAL( "IsEmptyString",
    obj ->     IsString( obj )
           and IsEmpty( obj )
           and TNUM_OBJ_INT( obj ) in TNUM_EMPTY_STRING );


############################################################################
##
#M  String( <str> ) . . . . . . . . . . . . . . . . . . . . . .  for a string
##
InstallMethod( String,
    "for a string (do nothing)",
    [ IsString ],
    IdFunc );


############################################################################
##
#M  String( <str> ) . . . . . . . . . . . . . . . . . . . .  for a character
##
InstallMethod( String,
    "for a character",
    [ IsChar ],
    ch -> [ '\'', ch, '\'' ] );


#############################################################################
##
#E

