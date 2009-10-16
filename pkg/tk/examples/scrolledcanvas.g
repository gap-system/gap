# The scrolledcanvas example from the Tk package
# $Id: scrolledcanvas.g,v 1.2 2003/06/06 21:05:18 gap Exp $
LoadPackage("tk");
t := TkWidget("toplevel");
f := TkWidget("frame",t);
c := TkWidget("canvas",f,rec(scrollregion := "0 0 2000 2000",background := "white"));
o := TkItem("oval",c,100,100,200,200,rec(fill := "red"));
h := TkWidget("scrollbar",f,"-orient horizontal");
v := TkWidget("scrollbar",f,"-orient vertical");
TkPack(f,"-fill both -expand 1");
TkGrid(c,"-row 0 -column 0 -sticky news");
TkGrid(h,"-sticky ew -row 1 -column 0");
TkGrid(v,"-sticky ns -row 0 -column 1");
TkLink(c,h,"h");
TkLink(c,v,"v");
Tk("grid rowconfigure",f,"0 -weight 1");         
Tk("grid columnconfigure",f,"0 -weight 1");           
Tk(c,"configure -scrollregion {0 0 400 400}");

