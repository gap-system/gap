#############################################################################
##
#W  xmltree.gi          OpenMath Package              Andrew Solomon
#W                                                    Marco Costantini
##
#H  @(#)$Id: xmltree.gi,v 1.5 2008/12/15 17:22:46 alexk Exp $
##
#Y    Copyright (C) 1999, 2000, 2001, 2006
#Y    School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##  The main function in this file converts the OpenMath XML into a tree
##  (using the function ParseTreeXMLString from package GapDoc) and
##  parses it.
##

Revision.("openmath/gap/xmltree.gi") :=
    "@(#)$Id: xmltree.gi,v 1.5 2008/12/15 17:22:46 alexk Exp $";


InstallGlobalFunction( OMParseXmlObj, 
    function ( node )
    local obj;

    if not IsBound( OMObjects.(node.name) )  then
        Error( "unknown OpenMath object ", node.name );
    fi;

    if IsBound( node.content ) and IsList( node.content ) and 
                not (node.name = "OMSTR" or node.name = "OMI")  then
        node.content := Filtered( node.content, OMIsNotDummyLeaf );
    fi;
    obj := OMObjects.(node.name)( node );

    if IsBound( node.attributes.id )  then
        OMTempVars.OMREF.( node.attributes.id ) := obj;
    fi;

    return obj;
end );




InstallGlobalFunction( OMgetObjectXMLTree,
    function ( string )
    local  node;


    OMTempVars.OMBIND := rec(  );
    OMTempVars.OMREF := rec(  );

    node := ParseTreeXMLString( string ).content[1];
    # DisplayXMLStructure( node );
    node.content := Filtered( node.content, OMIsNotDummyLeaf );

    return OMParseXmlObj( node.content[1] );

end );


#############################################################################
#E
