# The hello example from the Tk package:
# $Id: hello.g,v 1.2 2003/06/06 21:05:18 gap Exp $
LoadPackage("tk");
t := TkInit();
b := TkWidget("button",rec(text := "Hello world!"));
TkPack(b);
f := function() Print("Hallo Welt!\n"); end;
Tk(b,"configure",rec(command := f));

