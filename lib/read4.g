#############################################################################
##
#X  now read profiling functions, help system
##
ReadLib( "profile.g"   );
ReadLib( "methwhy.g"   );

##  the help system
ReadLib( "pager.gi"    );
ReadLib( "helpbase.gi"  );
#  moved to init.g, because completion doesn't work with if-statements
#  around function definitions!
#ReadLib( "helpview.gi"  );
ReadLib( "helpt2t.gi"   );
ReadLib( "helpdef.gi"   );

ReadLib( "reread.g"    );
ReadLib( "package.g"   );

