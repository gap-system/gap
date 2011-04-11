
## some test loops for basic checks of the help books    (Frank Lübeck)
## $Id$

##  check in which formats the help books are available
for a in RecFields(HELP_BOOKS_INFO) do 
  i:=HELP_BOOKS_INFO.(a); 
  Print(a, "  ");
  if IsBound(i.formats) then 
    Print(i.formats,"\n");
  else
    Print(i.types,"\n");
  fi;
od;


##  check if all help sections display 
SizeScreen([80,100000]);
PAGER := "builtin";
?:?

s:="";
for i in [1..Length(HELP_LAST.TOPICS)] do 
  Append(s,"?"); 
  Append(s,String(i));
  Append(s,"\nPrint(\"==============================================>\\c\", ");
  Append(s,String(i));
  Append(s,", \"\\n\");\n");
  # or, if viewer "xpdf" is tested.
  #Append(s,", \"\\n\");\nSleep(1);\n");
od;
SetHelpViewer("screen");
# or SetHelpViewer("netscape"); or SetHelpViewer("xpdf"); [with Sleep above]
Read(InputTextString(s));



