gap> START_TEST( "userpref.tst" );

# The following session documents what happens currently
# if one specifies "group actions" that are in fact not actions.
# (When some of these tests fail then parts of the documentation
# may have to be changed.)

# Define an intransitive group.
gap> if XMLForUserPreferences( "GAP" ) <> StringFile( Filename(
>           DirectoriesLibrary( "doc" ), "ref/user_pref_list.xml" ) ) then
>      Print( "Replace 'doc/ref/user_pref_list.xml' with the result of ",
>             "XMLForUserPreferences( \"GAP\" )\n" );
>    fi;

#
gap> STOP_TEST( "userpref.tst" );
