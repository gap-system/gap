#############################################################################
##
#W  font.gi                  	XGAP library                  Max Neunhoeffer
##
#H  @(#)$Id: font.gi,v 1.1 1998/11/27 14:50:48 ahulpke Exp $
##
#Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
#Y  Copyright 1998,       Max Neunhoeffer,              Aachen,       Germany
##
Revision.pkg_xgap_lib_font_gi :=
    "@(#)$Id: font.gi,v 1.1 1998/11/27 14:50:48 ahulpke Exp $";


#############################################################################
##

#R  IsFontRep . . . . . . . . . . . . . . . . . . . .  default representation
##
DeclareRepresentation( "IsFontRep",
    IsComponentObjectRep,
    [ "fontInfo", "name" ],
    IsObject );


#############################################################################
##
#M  FontInfo( <font> )  . . . . . . . . . . . . . . . . . font info of a font
##
InstallMethod( FontInfo,
    "for font",
    true,
    [ IsFont and IsFontRep ],
    0,

function( font )
    return font!.fontInfo;
end );


#############################################################################
##
#M  FontName( <font> )  . . . . . . . . . . . . . . . . . . .  name of a font
##
InstallMethod( FontName,
    "for font",
    true,
    [ IsFont and IsFontRep ],
    0,

function( font )
    return font!.name;
end );


#############################################################################
##
#M  ViewObj( <font> ) . . . . . . . . . . . . . . . . . . pretty print a font
##
InstallMethod( ViewObj,
    "for font",
    true,
    [ IsFont and IsFontRep ],
    0,

function( font )
    Print( "<font ", font!.name, ">" );
end );


#############################################################################
##
#M  PrintObj( <font> ) . . . . . . . . . . . . . . . . .  pretty print a font
##
InstallMethod( PrintObj,
    "for font",
    true,
    [ IsFont and IsFontRep ],
    0,

function( font )
    Print( "<font ", font!.name, ">" );
end );


#############################################################################
##
#M  \=( <font>, <font> )  . . . . . . . . . . . . . . . . . . . equality test
##
InstallMethod( \=,
    "for fonts",
    IsIdenticalObj,
    [ IsFont and IsFontRep,
      IsFont and IsFontRep ],
    0,

function( f1, f2 )
    return f1!.fontInfo = f2!.fontInfo;
end );


#############################################################################
##
#M  \<( <font>, <font> ) . . . . . . . . . . . . . . . . . .  comparison test
##
InstallMethod( \<,
    "for fonts",
    IsIdenticalObj,
    [ IsFont and IsFontRep,
      IsFont and IsFontRep ],
    0,

function( f1, f2 )
    return Position(FONTS.fonts,f1) < Position(FONTS.fonts,f2);
end );


#############################################################################
##
#F  CreateFonts()
#V  FONTS
##
InstallGlobalFunction( CreateFonts, function()
    local   type,  font;

    # get font type
    type := NewType( FontFamily, IsFont and IsFontRep );

    # "black" and "white" are always displayable
    font           := rec();
    font.tiny      := Objectify( type,
                              rec( fontInfo := WindowCmd([ "XFI", 1 ]), 
                                   name := "tiny" ) );
    font.small     := Objectify( type,
                              rec( fontInfo := WindowCmd([ "XFI", 2 ]), 
                                   name := "small" ) );
    font.normal    := Objectify( type,
                              rec( fontInfo := WindowCmd([ "XFI", 3 ]), 
                                   name := "normal" ) );
    font.large     := Objectify( type,
                              rec( fontInfo := WindowCmd([ "XFI", 4 ]), 
                                   name := "large" ) );
    font.huge      := Objectify( type,
                              rec( fontInfo := WindowCmd([ "XFI", 5 ]), 
                                   name := "huge" ) );
    font.fonts := [font.tiny,font.small,font.normal,
                   font.large,font.huge];

    # and return
    return font;

end );

InstallValue( FONTS, CreateFonts() );


#############################################################################
##

#E  font.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

