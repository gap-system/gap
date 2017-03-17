##  this creates the documentation, needs: 
##  GAPDoc package, latex, pdflatex, mkindex
##
LoadPackage( "GAPDoc" );

Reread ("../conv/MakeLaTeX.gi");
Reread ("../conv/MakeHTML.gi");
Reread ("../conv/MakeText.gi");
Reread ("../conv/MakeBWText.gi");
Read ("../conv/BuildManual.g");

Read( "makedocreldata.g" );

Exec( "ln -s -f ../conv/manual.css manual.css" );
Exec( "ln -s -f ../conv/java.css java.css" );
Exec( "ln -s -f ../conv/toggle.js toggle.js" );
Exec( "ln -s -f ../conv/open.png open.png" );
Exec( "ln -s -f ../conv/closed.png closed.png" );
Exec( "ln -s -f ../conv/empty.png empty.png" );
if not IsDirectoryPath ("textmarkup") then
    Exec ("mkdir textmarkup");
fi;


BuildManuals (rec(
    bookname := GAPInfo.ManualDataTut.bookname,
    pathtodoc := GAPInfo.ManualDataTut.pathtodoc, 
    main := GAPInfo.ManualDataTut.main,
    pathtoroot := GAPInfo.ManualDataTut.pathtoroot,
    files := GAPInfo.ManualDataTut.files,
    htmlspecial := ["MathJax"]));

#############################################################################
##
#E

