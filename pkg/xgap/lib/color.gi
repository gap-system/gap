#############################################################################
##
#W  color.gi                  	XGAP library                     Frank Celler
##
#H  @(#)$Id: color.gi,v 1.5 2000/09/12 02:13:13 gap Exp $
##
#Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
#Y  Copyright 1998,       Max Neunhoeffer,              Aachen,       Germany
##
Revision.pkg_xgap_lib_color_gi :=
    "@(#)$Id: color.gi,v 1.5 2000/09/12 02:13:13 gap Exp $";


#############################################################################
##
#R  IsColorRep  . . . . . . . . . . . . . . . . . . .  default representation
##
DeclareRepresentation( "IsColorRep",
    IsComponentObjectRep,
    [ "colorId", "name" ],
    IsObject );

DeclareSynonym( "IsColourRep", IsColorRep );


#############################################################################
##
#M  ColorId( <color> )  . . . . . . . . . . . . . . . . . color id of a color
##
InstallMethod( ColorId,
    "for color",
    true,
    [ IsColor and IsColorRep ],
    0,

function( color )
    return color!.colorId;
end );


#############################################################################
##
#M  PSColour( <color> )  . . . . . . . . . . . . PostScript string for colour
##
InstallMethod( PSColour,
    "for color",
    true,
    [ IsColor and IsColorRep ],
    0,

function( color )
    return color!.psColour;
end );


#############################################################################
##
#M  ViewObj( <color> )  . . . . . . . . . . . . . . . .  pretty print a color
##
InstallMethod( ViewObj,
    "for color",
    true,
    [ IsColor and IsColorRep ],
    0,

function( color )
    Print( "<color ", color!.name, ">" );
end );


#############################################################################
##
#M  PrintObj( <color> ) . . . . . . . . . . . . . . . .  pretty print a color
##
InstallMethod( PrintObj,
    "for color",
    true,
    [ IsColor and IsColorRep ],
    0,

function( color )
    Print( "<color ", color!.name, ">" );
end );


#############################################################################
##
#M  \=( <color>, <color> )  . . . . . . . . . . . . . . . . . . equality test
##
InstallMethod( \=,
    "for colors",
    IsIdenticalObj,
    [ IsColor and IsColorRep,
      IsColor and IsColorRep ],
    0,

function( c1, c2 )
    return c1!.colorId = c2!.colorId;
end );


#############################################################################
##
#M  \<( <color>, <color> )  . . . . . . . . . . . . . . . . . comparison test
##
InstallMethod( \<,
    "for colors",
    IsIdenticalObj,
    [ IsColor and IsColorRep,
      IsColor and IsColorRep ],
    0,

function( c1, c2 )
    return c1!.colorId < c2!.colorId;
end );


#############################################################################
##
#F  CreateColors()
#V  COLORS
##
InstallGlobalFunction( CreateColors, function()
    local   type,  color,  model;

    # get color type
    type := NewType( ColorFamily, IsColor and IsColorRep );

    # "black" and "white" are always displayable
    color           := rec();
    color.black     := Objectify( type,
                             rec( colorId := 0, name := "black",
                                  psColour := "0.0 0.0 0.0" ) );
     color.white     := Objectify( type,
                             rec( colorId := 1, name := "white",
                                  psColour := "1.0 1.0 1.0" ) );
    color.lightGray := false;
    color.dimGray   := false;
    color.red       := false;
    color.blue      := false;
    color.green     := false;

    # check for other colors
    model := WindowCmd(["XCN"])[1];
    if   model = 1  then
        color.model     := "monochrome";
    elif model = 2  then
        color.model     := "gray";
        color.lightGray := Objectify( type,
                                 rec( colorId := 2, name := "light gray",
                                      psColour := "0.83 0.83 0.83" ) );
         color.dimGray   := Objectify( type,
                                 rec( colorId := 3, name := "dim gray",
                                      psColour := "0.41 0.41 0.41" ) );
    elif model = 3  then
        color.model     := "color3";
        color.red       := Objectify( type,
                                 rec( colorId := 4, name := "red",
                                      psColour := "1.0 0.0 0.0" ) );
         color.blue      := Objectify( type,
                                 rec( colorId := 5, name := "blue",
                                      psColour := "0.0 0.0 1.0" ) );
         color.green     := Objectify( type,
                                 rec( colorId := 6, name := "green",
                                      psColour := "0.0 1.0 0.0" ) );
    elif model = 4  then
        color.model     := "color5";
        color.lightGray := Objectify( type,
                                 rec( colorId := 2, name := "light gray",
                                      psColour := "0.83 0.83 0.83" ) );
         color.dimGray   := Objectify( type,
                                 rec( colorId := 3, name := "dim gray",
                                      psColour := "0.41 0.41 0.41" ) );
         color.red       := Objectify( type,
                                 rec( colorId := 4, name := "red",
                                      psColour := "1.0 0.0 0.0" ) );
         color.blue      := Objectify( type,
                                 rec( colorId := 5, name := "blue",
                                      psColour := "0.0 0.0 1.0" ) );
         color.green     := Objectify( type,
                                 rec( colorId := 6, name := "green",
                                      psColour := "0.0 1.0 0.0" ) );
    fi;

    # fix spelling of grey
    color.lightGrey := color.lightGray;
    color.dimGrey   := color.dimGray;

    # and return
    return color;

end );

InstallValue( COLORS, CreateColors() );


#############################################################################
##

#E  color.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

