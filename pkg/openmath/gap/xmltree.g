###########################################################################
##
#W  xmltree.gi          OpenMath Package              Andrew Solomon
#W                                                    Marco Costantini
##
#Y  Copyright (C) 1999, 2000, 2001, 2006
#Y  School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##  The main function in this file converts the OpenMath XML into a tree
##  (using the function ParseTreeXMLString from package GapDoc) and
##  parses it.
##

BindGlobal( "OMTempVars", 
	rec( OMBIND := rec(  ), OMREF := rec(  ) ) );
	
MakeReadWriteGlobal("OMTempVars"); 


BindGlobal( "OMIsNotDummyLeaf", 
    node -> not node.name = "PCDATA" and not node.name = "XMLCOMMENT");


if not CompareVersionNumbers( GAPInfo.Version, "4.5.0") and 
   not IsBoundGlobal( "MACFLOAT_STRING" ) then
    MACFLOAT_STRING := Float;
    IS_MACFLOAT := IsFloat;
fi;


BindGlobal( "OMObjects",

    rec(

    # Basic OpenMath objects

  OMB := function ( node )
        return node.content[1].content;
    end,


  OMF := function ( node )
        if not IsBound( node.attributes.dec )  then
            Error( "hexadecimal encoding of floats is not supported" );
        fi;
        if CompareVersionNumbers( GAPInfo.Version, "4.5.0") then
        	return MACFLOAT_STRING( node.attributes.dec );
        else
        	return Float( node.attributes.dec );
        fi;
    end,


  OMI := function ( node )
        node.content[1].content := ReplacedString( node.content[1].content, " ", "" );
        node.content[1].content := ReplacedString( node.content[1].content, "\n", "" );
        node.content[1].content := ReplacedString( node.content[1].content, "\t", "" );
        node.content[1].content := ReplacedString( node.content[1].content, "\r", "" );
        if 'x' in node.content[1].content  then
            return IntHexString( ReplacedString( node.content[1].content, "x", "" ) );
        else
            return Int( node.content[1].content );
        fi;
    end,

  
OMSTR := function ( node )
        local  string;
		if node.content <> 0 then
	        string := Concatenation( List( node.content, x -> x.content ) );
	        ConvertToStringRep( string );
		else
			string := "";
		fi;
        return string;
   end,    


  OMS := function ( node )
        # this is just a nullary symbol
        return OMsymLookup( [ node.attributes.cd, node.attributes.name ] );
    end,


  OMV := function ( node )
        if IsBound( OMTempVars.OMBIND.(node.attributes.name) )  then
            return OMTempVars.OMBIND.(node.attributes.name);
        fi;
        # a variable is returned as the string of its name
        return node.attributes.name;
    end,


    # Constructors of OpenMath objects


  OMA := function ( node )
        local  head, headfun;
        if node.content[1].name = "OMS"  then
            head := OMsymLookup( [ node.content[1].attributes.cd, node.content[1].attributes.name ] );
        else
            head := OMParseXmlObj( node.content[1] );
        fi;
        # check if the head is not a function (e.f. when permutation1.endomap 
        # (evaluated in GAP as Transformation) is be used a head
        if not IsFunction(head) then
        	headfun := function(x) return x[1]^head; end;
        else
        	headfun := head;	
        fi;
        # extra check to achieve compatibility with SCSCP
        if IsBound(node.content[1].attributes.cd) and node.content[1].attributes.cd="scscp2" and 
          node.content[1].attributes.name in [ "get_signature", "is_allowed_head" ] then
            return headfun( [ node.content[2].attributes.cd, node.content[2].attributes.name ] );
        else
            return headfun( List( [ 2 .. Length( node.content ) ], x -> OMParseXmlObj( node.content[x] ) ) );
        fi;
    end,


  OMATTR := function ( node )
        node.content := Filtered( node.content, x -> x.name <> "OMATP" );
        # the only thing we don't ignore - the unattributed object
        return OMParseXmlObj( node.content[1] );
    end,


  OMBIND := function ( node )
    local  OMBVAR, string, i;

#        if not (node.content[1].attributes.cd = "fns1" and node.content[1].attributes.name = "lambda" and
#            node.content[1].name = "OMS" and node.content[2].name = "OMBVAR" )  then
#            Error( "this binding is unimplemented" );
#        fi;

        node.content[2].content := Filtered( node.content[2].content, OMIsNotDummyLeaf );
        if IsList( node.content[3].content )  then
            node.content[3].content := Filtered( node.content[3].content, OMIsNotDummyLeaf );
        fi;

        OMBVAR := List( [ 1 .. Length( node.content[2].content ) ],
              x -> OMParseXmlObj( node.content[2].content[x] ) );

        #Print( " OMBVAR = ", OMBVAR, "\n" );
        #Print( " OMBVAR = ", OMBVAR, " node.content[3] = ", node.content[3], "\n" );

        string := "function( ";
        for i  in [ 1 .. Length( OMBVAR ) ]  do
            Append( string, OMBVAR[i] );
            if i < Length( OMBVAR )  then
                Append( string, ", " );
            fi;
        od;
        Append( string, " )\n" );

        for i  in [ 1 .. Length( OMBVAR ) ]  do
            Append( string, "OMTempVars.OMBIND." );
            Append( string, OMBVAR[i] );
            Append( string, " := " );
            Append( string, OMBVAR[i] );
            Append( string, ";\n" );
        od;

        Append( string, "return OMParseXmlObj( " );
        Append( string, String( node.content[3] ) );
        Append( string, " );\n" );

        Append( string, "end" );
        return EvalString( string );

    end,


  OME := function ( node )
  		if IsBound(node.content[1].attributes.cd) and node.content[1].attributes.cd="error" then
  			Error( node.content[1].attributes.name, " : cd=", 
  			       node.content[2].attributes.cd, ", name=",
  			       node.content[2].attributes.name, "\n" );		
		else
		Error( List( [ 2 .. Length( node.content ) ], x -> OMParseXmlObj( node.content[x] ) )[1],
            "\n", node.content[1].attributes );
        fi;    
    end,


    # Foreign OpenMath objects


 OMFOREIGN := function ( node )
        return node;
    end,


    # References


 OMR := function ( node )
 		local ref;
        ref := node.attributes.href;
        return OMTempVars.OMREF.( ref{[ 2 .. Length( ref ) ]} );
    end


) );

MakeReadWriteGlobal("OMObjects"); 

if CompareVersionNumbers( GAPInfo.Version, "4.5.0") then 

OMObjects.OMF := 
    function ( node )
        if not IsBound( node.attributes.dec )  then
            Error( "hexadecimal encoding of floats is not supported" );
        fi;
      	return MACFLOAT_STRING( node.attributes.dec );
    end;

else

OMObjects.OMF := 
    function ( node )
        if not IsBound( node.attributes.dec )  then
            Error( "hexadecimal encoding of floats is not supported" );
        fi;
       	return Float( node.attributes.dec );
    end;

fi;

#############################################################################
#E
