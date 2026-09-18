# test method-not-found traceback rendering while preserving helper access
f := a -> IsDiagonalMat(a);;
f(());
ShowMethods(1);
Where(5);
quit;
