#@local comp,file,len,pos
gap> START_TEST( "userpref.tst" );

# Check whether the documentation of user preferences
# coincides with their declarations.
gap> comp:= XMLForUserPreferences( "GAP" );;
gap> file:= StringFile( Filename( DirectoriesLibrary( "doc" ),
>                                 "ref/user_pref_list.xml" ) );;
gap> if comp <> file then
>      len:= Minimum( Length( file ), Length( comp ) );;
>      Print( "Replace 'doc/ref/user_pref_list.xml' with the result of\n",
>             "XMLForUserPreferences( \"GAP\" )\n" );
>      if Length( file ) <> Length( comp ) then
>        Print( "(lengths differ: ", Length( file ), " vs. ",
>               Length( comp ), ")\n" );
>      fi;
>      pos:= First( [ 1 .. len ], i -> file[i] <> comp[i] );
>      if pos <> fail then
>        Print( "first difference at ", pos, ":\n",
>          "in doc/ref/user_pref_list.xml:\n",
>          file{ [ Maximum( 1, pos-30 ) .. Minimum( pos+30, len ) ] }, "\n",
>          "\nin result of XMLForUserPreferences( \"GAP\" ):\n",
>          comp{ [ Maximum( 1, pos-30 ) .. Minimum( pos+30, len ) ] }, "\n" );
>      fi;
>    fi;

#
gap> STOP_TEST( "userpref.tst" );
