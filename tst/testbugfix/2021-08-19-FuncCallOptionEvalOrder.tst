#@local myfunc, func_call, proc_call
# Fix GitHub issue #4631: The evaluation order of arguments versus
# options in function and procedure calls differed between the immediate
# interpreter, and the executor for coded statements.
gap> myfunc := function( )
>       Display( ValueOption( "myopt" ) );
>       return 1;
>    end;;
gap> func_call := function( )
>       # a function call follows; one of the arguments uses myopt as a side effect
>       return IdFunc( myfunc( ) : myopt := "myopt_value" );
>    end;;
gap> proc_call := function( )
>     # a procedure call follows; one of the arguments uses myopt as a side effect
>     Ignore( myfunc( ) : myopt := "myopt_value" );
>    end;;

# call as function, delayed
gap> func_call( );;
fail

# call as function, immediately
gap> IdFunc( myfunc( ) : myopt := "myopt_value" );;
fail

# call as procedure, delayed
gap> proc_call( );
fail

# call as procedure, immediately
gap> Ignore( myfunc( ) : myopt := "myopt_value" );
fail
