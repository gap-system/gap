informproc0 := function(l)
Add(l,1);
l();
return; end;
informproc0([]);
quit;
informproc1 := function(l)
Add(l,1);
l(1);
return; end;
informproc1([]);
quit;
informproc2 := function(l)
Add(l,1);
l(1,2);
return; end;
informproc2([]);
quit;
informproc3 := function(l)
Add(l,1);
l(1,2,3);
return; end;
informproc3([]);
quit;
informproc4 := function(l)
Add(l,1);
l(1,2,3,4);
return; end;
informproc4([]);
quit;
informproc5 := function(l)
Add(l,1);
l(1,2,3,4,5);
return; end;
informproc5([]);
quit;
informproc6 := function(l)
Add(l,1);
l(1,2,3,4,5,6);
return; end;
informproc6([]);
quit;
informprocmore := function(l)
Add(l,1);
l(1,2,3,4,5,6,7);
return; end;
informprocmore([]);
quit;
informfunc0 := function(l)
Add(l,1);
Print(l());
return; end;
informfunc0([]);
quit;
informfunc1 := function(l)
Add(l,1);
Print(l(1));
return; end;
informfunc1([]);
quit;
informfunc2 := function(l)
Add(l,1);
Print(l(1,2));
return; end;
informfunc2([]);
quit;
informfunc3 := function(l)
Add(l,1);
Print(l(1,2,3));
return; end;
informfunc3([]);
quit;
informfunc4 := function(l)
Add(l,1);
Print(l(1,2,3,4));
return; end;
informfunc4([]);
quit;
informfunc5 := function(l)
Add(l,1);
Print(l(1,2,3,4,5));
return; end;
informfunc5([]);
quit;
informfunc6 := function(l)
Add(l,1);
Print(l(1,2,3,4,5,6));
return; end;
informfunc6([]);
quit;
informfuncmore := function(l)
Add(l,1);
Print(l(1,2,3,4,5,6,7));
return; end;
informfuncmore([]);
quit;
