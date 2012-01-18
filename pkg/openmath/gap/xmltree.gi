#############################################################################
##
#W  xmltree.gi          OpenMath Package              Andrew Solomon
#W                                                    Marco Costantini
##
#Y    Copyright (C) 1999, 2000, 2001, 2006
#Y    School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##  The main function in this file converts the OpenMath XML into a tree
##  (using the function ParseTreeXMLString from package GapDoc) and
##  parses it.
##


InstallGlobalFunction( OMParseXmlObj, function ( node )
    local obj;

    if not IsBound( OMObjects.(node.name) )  then
        Error( "unknown OpenMath object ", node.name );
    fi;

    if IsBound( node.content ) and 
       IsList( node.content ) and 
        not (node.name = "OMSTR" or node.name = "OMI" or node.name = "OMB")  then
        node.content := Filtered( node.content, OMIsNotDummyLeaf );
    fi;
    obj := OMObjects.(node.name)( node );

    if IsBound( node.attributes.id )  then
        OMTempVars.OMREF.( node.attributes.id ) := obj;
    fi;

    return obj;
end );




InstallGlobalFunction( OMgetObjectXMLTree, function ( string )
    local  node;

    # TODO: this maybe be reset in the middle of the session
    # making references invalid. We need either to keep this
    # for the whole session or to create another record to 
    # store such objects
    
    OMTempVars.OMBIND := rec(  );
    OMTempVars.OMREF := rec(  );

    node := ParseTreeXMLString( string ).content[1];
    # DisplayXMLStructure( node );
    node.content := Filtered( node.content, OMIsNotDummyLeaf );

    return OMParseXmlObj( node.content[1] );

end );


#############################################################################
#E
