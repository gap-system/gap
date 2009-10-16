#############################################################################
##
#W  font.gd                 	XGAP library                  Max Neunhoeffer
##
#H  @(#)$Id: font.gd,v 1.2 1999/06/30 09:13:03 gap Exp $
##
#Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
#Y  Copyright 1998,       Max Neunhoeffer,              Aachen,       Germany
##
Revision.pkg_xgap_lib_font_gd :=
    "@(#)$Id: font.gd,v 1.2 1999/06/30 09:13:03 gap Exp $";


#############################################################################
##
#C  IsFont . . . . . . . . . . . . . . . . . . . . . . . .  category of fonts
##
DeclareCategory( "IsFont", IsObject );


#############################################################################
##
#O  FontInfo( <font> )  . . . . . . . . . . . . . . . . . font info of a font
##
##  Returns the information about the font <font>. The result is a triple
##  of integers. The first number is the maximal size
##  of a character above the baseline in pixels, the second is the maximal size
##  of a character below the baseline in pixels, and the third is the width
##  in pixels of *all* characters, because it is always assumed, that the
##  fonts are non-proportional. Use this function rather than accessing
##  the component `fontInfo' of a font object directly!
##
DeclareOperation( "FontInfo", [ IsFont ] );


#############################################################################
##
#O  FontName( <font> )  . . . . . . . . . . . . . . . . . . .  name of a font
##
DeclareOperation( "FontName", [ IsFont ] );


#############################################################################
##
#V  FontFamily  . . . . . . . . . . . . . . . . . . . . . . . family of fonts
##
BindGlobal( "FontFamily", NewFamily( "FontFamily" ) );


#############################################################################
##
#V  FONTS  . . . . . . . . . . . . . . . . . . . . .  list of available fonts
##
##  The variable  `FONTS' contains a list  of  available fonts.  If  an entry
##  is `false' this  fonts is not available  on your screen.
DeclareGlobalFunction( "CreateFonts" );
DeclareGlobalVariable( "FONTS" );


#############################################################################
##

#E  font.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

