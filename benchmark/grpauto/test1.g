#description
#author
#timelimit
#cmdlineops
#packages

starttime := Runtime();

res := Test( "permiso.tst", rec(showProgress := true) );

Print( "*** RUNTIME ", Runtime()-starttime, "\n" );

if res then
  QUIT_GAP(0);
else
  QUIT_GAP(1);
fi;
