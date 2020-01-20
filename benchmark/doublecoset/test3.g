#description
#author
#timelimit
#cmdlineops
#packages

starttime := Runtime();

res := Test( "doublecoset3.tst", rec(showProgress := true) );

Print( "*** RUNTIME ", Runtime()-starttime, "\n" );

if res then
  QuitGap(0);
else
  QuitGap(1);
fi;
