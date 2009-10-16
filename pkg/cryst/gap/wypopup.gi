#############################################################################
##
#A  wypopup.gi                Cryst library                      Bettina Eick
#A                                                              Franz G"ahler
#A                                                              Werner Nickel
##
#Y  Copyright 1997-1999  by  Bettina Eick,  Franz G"ahler  and  Werner Nickel
##
##  Routines for text selector popup for Wyckoff graph
##

############################################################################
##
#F  CCInfo . . . . . . . . . . . . . ConjugacyClassInfo of WyckoffStabilizer
##
CCInfo := function( W )
    local G, C, R, L, max;
    G := PointGroup( WyckoffStabilizer( W ) );
    C := ConjugacyClasses( G );
    R := List( C, Representative );
    L := [ [1..Length(C)],
           List( R, Order ),
           List( R, TraceMat ),
           List( R, DeterminantMat ),
           List( C, Size )
         ];
    L := TransposedMat( L );
    L := Concatenation( [[ "cl", "ord", "tr", "det", "sz" ]], L );
    max := Maximum( List( L, l -> Maximum(
                    List( l, x -> Length( String(x) ) ) ) ) ); 
    max := max + 1;
    L := List( L, l -> Concatenation( List( l, x -> String( x, max ) ) ) ); 
    return L;
end;

############################################################################
##
#F  WyckoffInfoDisplays . . . . functions call by WyckoffGraph text selector
##
BindGlobal( "WyckoffInfoDisplays",
  rec( 
    Isomorphism := rec( name := "Isomorphism", func := 
                        x -> IdGroup( PointGroup( WyckoffStabilizer(x) ) ) ),
    ConjugacyClassInfo := rec( name := "ConjugacyClassInfo", 
                               func := x -> CCInfo( x ) )
  ) 
);


############################################################################
##
#M  GGLRightClickPopup . . . . . . . . . . called if user does a right click
##
##  This is called if the user does a right click on a vertex or somewhere
##  else on the sheet. This operation is highly configurable with respect
##  to the Attributes of groups it can display/calculate. See the 
##  configuration section in "ilatgrp.gi" for an explanation.
##
InstallMethod( GGLRightClickPopup, "for a Wyckoff graph", true,
    [ IsGraphicSheet and IsWyckoffGraph, IsObject, IsInt, IsInt ], 0,
function(sheet,v,x,y)

  local w, r, textselectfunc, text, pg, ps, i, str, basis, vec,
        funcclose, funcall, maxlengthofname, names;
  
  maxlengthofname := 11;

  # did we get a vertex?
  if v = fail then
    return;
  fi;
  
  # destroy other text selectors flying around
  if sheet!.selector <> false then
    Close(sheet!.selector);
    sheet!.selector := false;
  fi;
  
  # get the Wyckoff position of <obj>
  w := v!.data.wypos;
  
  # how long are the names of the info displays?
  r := sheet!.infodisplays;
# maxlengthofname := Maximum( List( RecNames(r), x -> Length( r.(x).name ) ) );

  # text select function
  textselectfunc := function( sel, name )
    local tid, text, str, curr, value;
    
    tid  := sel!.selected;
    name := sel!.names[tid];
    text := ShallowCopy(sel!.labels);
    if name = "ConjugacyClassInfo" then
        str  := text[tid]{[1..Length(name)]};
    else
        str  := text[tid]{[1..maxlengthofname+1]};
    fi;

    if name = "dummy" then
        return true;
    fi;
    curr := sheet!.infodisplays.(name);

    value := curr.func( w );
    v!.data.info.(name) := value;
    if name = "ConjugacyClassInfo" then
      Append( str, ":" );
    else
      Append( str, String( value ) );
    fi;
    text[tid] := str;
    if name = "ConjugacyClassInfo" then
        for str in value do
            Add( text, str );
            Add( sel!.textFuncs, textselectfunc );
            Add( sel!.names, "dummy" );
        od;
        sel!.labels := text;
    fi;

    Relabel( sel, text );
    SetName( sel, tid, "dummy" );
    LastResultOfInfoDisplay := value;
    
    return true;
  end;

  # construct the initial text selector
  text := [];
  names := [];
  pg := PointGroup( WyckoffStabilizer( w ) );
  ps := PointGroup( WyckoffSpaceGroup( w ) );

  # the stabilizer size
  str := String( "StabSize", -(maxlengthofname+1) );
  Append( str, String( Size( pg ) ) );
  Append( text, [ str, textselectfunc ] );
  Add( names, "dummy" );

  # the stabilizer dimension
  str := String( "StabDim", -(maxlengthofname+1) );
  Append( str, String( Length( WyckoffBasis( w ) ) ) );
  Append( text, [ str, textselectfunc ] );
  Add( names, "dummy" );

  # the orbit length modulo lattice translations
  str := String( "OrbitLength", -(maxlengthofname+1) );
  Append( str, String( Size( ps ) / Size( pg ) ) );
  Append( text, [ str, textselectfunc ] );
  Add( names, "dummy" );

  # the translation of the affine subspace
  str := String( "Translation", -(maxlengthofname+1) );
  Append( str, String( WyckoffTranslation( w ) ) );
  Append( text, [ str, textselectfunc ] );
  Add( names, "dummy" );

  # the basis of the affine subspace
  basis := WyckoffBasis( w );
  str   := String( "Basis", -(maxlengthofname+1) );
  if basis = [] then
    Append( str, "[ ]" );
    Append( text, [ str, textselectfunc ] );
    Add( names, "dummy" );
  elif Length( basis ) = 1 then
    Append( str, String( basis ) );
    Append( text, [ str, textselectfunc ] );
    Add( names, "dummy" );
  else
    Append( str, "[ " );
    Append( str, String( basis[1] ) );
    for vec in basis{[2..Length(basis)]} do
      Append( text, [ str, textselectfunc ] );
      Add( names, "dummy" );
      str := String( " ", -(maxlengthofname+3) );
      Append( str, String( vec ) );
    od;
    Append( str, " ]" );
    Append( text, [ str, textselectfunc ] );
    Add( names, "dummy" );
  fi;

  # the isomorphism type
  str := String( "Isomorphism", -(maxlengthofname+1) );
  if HasIdGroup( pg ) then
    Append( str, String( IdGroup( pg ) ) );
  else
    Append( str, "unknown" );
  fi;
  Append( text, [ str, textselectfunc ] );
  Add( names, "Isomorphism" );

  # the conjugacy class info
  str := "ConjugacyClassInfo";
  if IsBound( v!.data.info.ConjugacyClassInfo ) then
      Append( str, ":" );
      Add( names, "dummy" );
  else
      Add( names, "ConjugacyClassInfo" );
  fi;
  Append( text, [ str, textselectfunc ] );
  Add( names, "Isomorphism" );
  if IsBound( v!.data.info.ConjugacyClassInfo ) then
      for str in v!.data.info.ConjugacyClassInfo do
          Append( text, [ str, textselectfunc ] );
          Add( names, "dummy" );
      od;
  fi;

  # button select functions:
  funcclose := function( sel, bt )
    Close(sel);
    sheet!.selector := false;
    return true;  
  end;
  funcall := function( sel, bt )
    local i;
    for i  in [ 1 .. Length(sel!.labels) ]  do
      sel!.selected := i;
      sel!.textFuncs[i]( sel, sel!.labels[i] );
    od;
    Enable( sel, "all", false );
    return true;  
  end;
  
  # construct text selector
  sheet!.selector := TextSelector(
        Concatenation( " Information about ", v!.label ),
        text,
        [ "all", funcall, "close", funcclose ] );

  # set entry names
  for i in [1..Length(names)] do
      SetName( sheet!.selector, i, names[i] );
  od;

end);




