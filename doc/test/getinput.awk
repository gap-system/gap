BEGIN{x=0; gin="in";gout="out";
  print "LogTo(\"gaout\");" >gin;
  print >gout}
/\\endexample/{
  if (x==0) print "Error! not in example";
  else x=0;
 }
{if (x==1) {
  sub(/\&/,"#");
  if (substr($0,1,4)=="gap>") {
    print substr($0,6) >>gin;
  }
  else if ( substr($0,1,1)==">" ) {
    print substr($0,3) >> gin;
  }
  else {
    print $0 >gout;
    print "#@ " $0 >>gin; 
   }
 }
}
/\\beginexample/{
  if (x==1) print "Error! still in example";
  else x=1;
 }
END{if (x==1) print "Error! exit in example";
  print "quit;" >>gin;
}
