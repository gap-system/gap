# String( F ) does not work for a field in gap -A. Here is a fix.
#
# this is taken from gapdoc and put here to avoid future incompatibility

LieAlgDBField2String := function ( F )
    local  str, out;
    str := "";
    out := OutputTextString( str, false );
    PrintTo1( out, function (  )
          Print( F );
          return;
      end );
    CloseStream( out );
    return str;
end;


InstallMethod( PrintObj,
        "for LieAlgDBCollections",
        [ IsLieAlgDBCollection ],
        function( R )
    Print( "All", R!.type, "LieAlgebras( ", 
           LieAlgDBField2String( R!.field ), ", ", 
           String( R!.dim ), " )");
end );
    

InstallMethod( ViewObj,
        "for LieAlgDBCollections",
        [ IsLieAlgDBCollection ],
        function( R )
    Print( "<Collection of ", LowercaseString( R!.type ), 
           " Lie algebras with dimension ", String( R!.dim ), 
           " over ", LieAlgDBField2String( R!.field ), ">" );
end );
    
    


      