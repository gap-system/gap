LoadPackage("tk");
TkInit();
Tk(TkRootWindow,"configure",rec(background := "white"));
l := TkWidget("label",TkRootWindow,
           rec(text := "This is a short demonstration of GAPTk."));
TkPack(l);

counter := 1;
w := fail;

f := function() 
  local f,f1,f2,f3,f4,f5,l,r,r2;

  if w <> fail then
    Tk("wm withdraw",w);
  fi;
  w := TkWidget("toplevel",TkRootWindow,rec(background := "white"));

  if counter = 1 then

    f := TkWidget("frame",w);
    r := rec(borderwidth := 4,background:="blue",width := "2c",height := "2c");
    r2 := rec(side := "left",padx := "1m",pady := "1m");
    f1 := TkWidget("frame",f,rec(relief := "raised"),r); TkPack(f1,r2);
    f2 := TkWidget("frame",f,rec(relief := "sunken"),r); TkPack(f2,r2);
    f3 := TkWidget("frame",f,rec(relief := "flat"),r); TkPack(f3,r2);
    f4 := TkWidget("frame",f,rec(relief := "groove"),r); TkPack(f4,r2);
    f5 := TkWidget("frame",f,rec(relief := "ridge"),r); TkPack(f5,r2);
    TkPack(f);
    l := TkWidget("label",w,rec(text := "Frames with different reliefs"));
    TkPack(l);
    
  elif counter = 2 then
    
    f1 := TkWidget("label",w,
                rec(bitmap:="@$tk_library/demos/images/flagdown.bmp"));
    TkPack(f1);
    f2 := TkWidget("label",w,rec(text := "Keine Post"));
    TkPack(f2);
    f3 := TkWidget("label",w,rec(text := "Bitmap and text labels"));
    TkPack(f3);

  elif counter = 3 then

  fi;
  counter := counter + 1;
end;

b := TkWidget("button",TkRootWindow,rec(text := "next event",command := f));
TkPack(b);
