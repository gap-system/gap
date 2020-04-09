##  this creates the documentation, needs: GAPDoc package,
##  mkindex ?, dvips ?

Read( "makedocreldata.g" );

MakeGAPDocDoc( GAPInfo.ManualDataRef.pathtodoc,
               GAPInfo.ManualDataRef.main,
               GAPInfo.ManualDataRef.files,
               GAPInfo.ManualDataRef.bookname,
               GAPInfo.ManualDataRef.pathtoroot,
               "nopdf" );;
