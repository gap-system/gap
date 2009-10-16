# The dialog example from the Tk package.
# $Id: dialog.g,v 1.1 2003/06/06 21:05:50 gap Exp $
LoadPackage("tk");
l := TkWidget("label",rec(text := "Please enter a number:"));
TkPack(l,rec(side := "left"));
e := TkWidget("entry",rec(width := 10));
TkPack(e,rec(side := "left"));
Tk(e,"insert 0 123456");
f := function() Print("The current value is:",TkValue("[",e,"get]"),"\n"); end;
o := TkWidget("button",rec(text := "OK",command := f));
TkPack(o,rec(side := "left"));
