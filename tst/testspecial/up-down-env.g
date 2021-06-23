#############################################################################
##
##  Test UpEnv and DownEnv, and what happens when they are asked to go beyond
##  the first/last active execution context.
##
f:=lvl -> 1/lvl + f(lvl-1);
f(7);
UpEnv(1); lvl;
DownEnv(1); lvl;
DownEnv(1); lvl;
UpEnv(1); lvl;
DownEnv(10); lvl;
UpEnv(1); lvl;
UpEnv(3); lvl;
DownEnv(2); lvl;

#############################################################################
##
##  Reading a file without an error should have no effect on the execution
##  context. In particular, setting lvl there does not affect it in the
##  current execution context, but rather sets a global variable; likewise
##  unbinding lvl has no effect here.
##
Read("good.g");
lvl;

#############################################################################
##
##  start a fresh execution context
##
Read("top-level-error.g");
Where(20);
lvl; # since `Read` started a fresh execution context, we can't access lvl here
quit;
lvl;
