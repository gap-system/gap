filt:=NewFilter("BreakPrint");;
InstallMethod(ViewObj, [filt], SUM_FLAGS, x -> 0/0);;
badgroup := Group(());
SetFilterObj(badgroup, filt);
old_OnBreak:=OnBreak;;
OnBreak:=fail;; # prevent backtrace with line numbers that keep chaning
View([[badgroup]]); # <- trigger break loop
quit;
OnBreak:=old_OnBreak;;
l := [1,2,3];
l;
Print(l,"\n");
l;
Print(l,"\n");
Print(l,"\n");
2;
Print(l,"\n");
Print(l,"\n");
