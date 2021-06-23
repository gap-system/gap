#############################################################################
##
##
##  This file tests the combination of Where and DownEnv/UpEnv, and also the
##  initial backtrace (for which Where is executed in a slightly different
##  execution context compared to the later Where invocations from the break
##  prompt)
##
##  We test with three slightly different ways to trigger an error, as they
##  exhibit slight differences in how they interact with the error handling
##  code.
##
##  We also test what happens when UpEnv/DownEnv are asked to go beyond the
##  first/last execution context.
##

#############################################################################
##
##  trigger error using Error()
##
test:= function( n )
  if n > 2 then
    Error( "!\n" );
  fi;
  test( n+1 );
end;;
test( 1 );
n; Where();
DownEnv(); n; Where();
DownEnv(); n; Where();
DownEnv(); n; Where();
UpEnv(); n; Where();
UpEnv(); n; Where();
UpEnv(); n; Where();
quit;

#############################################################################
##
##  trigger error in the kernel
##
test:= function( n )
  if n > 2 then
    return 1/0;
  fi;
  test( n+1 );
end;;
test( 1 );
n; Where();
DownEnv(); n; Where();
DownEnv(); n; Where();
DownEnv(); n; Where();
UpEnv(); n; Where();
UpEnv(); n; Where();
UpEnv(); n; Where();
quit;


#############################################################################
##
## trigger method not found error
##
test:= function( n )
  if n > 2 then
    return IsAbelian(1);
  fi;
  test( n+1 );
end;;
test( 1 );
n; Where();
DownEnv(); n; Where();
DownEnv(); n; Where();
DownEnv(); n; Where();
UpEnv(); n; Where();
UpEnv(); n; Where();
UpEnv(); n; Where();
quit;
