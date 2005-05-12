#############################################################################
##
#W  string.g                     GAP library                    Thomas Breuer
#W                                                             & Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
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
##  A *string* is  a dense list (see~"IsList", "IsDenseList")
##  of characters (see~"IsChar"); thus strings are always homogeneous
##  (see~"IsHomogeneousList").
##  
##  A string literal can either be entered  as the list of characters
##  or by writing the characters between *doublequotes* `\"'.
##  {\GAP} will always output strings in the latter format.
##  However, the input via the double quote syntax enables {\GAP} to store
##  the string in an efficient compact internal representation. See
##  "IsStringRep" below for more details.
##  
##  Each character, in particular those which cannot be typed directly from the
##  keyboard, can also be typed in three digit octal notation. And for some
##  special characters (like the newline character) there is a further
##  possibility to type them, see section "Special Characters".
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
#V  TYPES_STRING . . . . . . . . . . . . . . . . . . . . . types of strings
##
BIND_GLOBAL( "StringFamily", NewFamily( "StringsFamily", IsCharCollection ) );

BIND_GLOBAL( "TYPES_STRING", 
        [ NewType( StringFamily, IsString and IsStringRep and
                IsMutable ), # T_STRING
          
          NewType( StringFamily, IsString and IsStringRep ), 
          # T_STRING + IMMUTABLE
          
          ~[1], # T_STRING_NSORT
          
          ~[2], # T_STRING_NSORT + IMMUTABLE
          
          NewType (StringFamily, IsString and IsStringRep and
                  IsSSortedList and IsMutable ),
          # T_STRING_SSORT 
          
          NewType (StringFamily, IsString and IsStringRep and
                  IsSSortedList )
          # T_STRING_SSORT +IMMUTABLE
          ]);


          



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
    function(s)
      if Length(s) = 0 and not IsStringRep(s) then
        return "[ ]";
      else
        return s;
      fi;
    end);


############################################################################
##
#M  String( <str> ) . . . . . . . . . . . . . . . . . . . .  for a character
##
InstallMethod( String,
    "for a character",
    [ IsChar ],
    function(ch) 
      local res; res := "\'"; Add(res, ch); Add(res, '\''); return res; 
    end);


#############################################################################
##
#E

