BEGIN{mode=0;t="";
  di=0;
  }

{
  if (mode==0) {
    if (substr($0,1,4)!="gap>" && substr($0,1,2)!="> ") {
      mode=1; # switch to mode 1: output
      o=""; #gap output
    }
    else  # print the input line on the screen
      if (substr($0,1,4)=="gap>")
        t=t substr($0,6);
      else
        t=t substr($0,3);
  }
  if (mode==1) {
    if (substr($0,1,8)=="gap> #@ ") {
      mode=2; # switch to mode 2: example output
      e=""; #example result
    }
    else
      o = o unblank($0);
  }
  if (mode==2) {
    if (substr($0,1,8)!="gap> #@ ") { 
      # compare the results
      if (e!=o) {
        if (di == 0)   print "\n\n\n\nDifferences in output:\n=====================";
        print "\nCommand: " t ;
	print "Example: " e;
	print "Output : " o;
        di=1;
      }
      mode=0; # switch to mode 0: input
      # print the input line on the screen
      if (substr($0,1,4)=="gap>")
        t=substr($0,6);
      else
        t=substr($0,3);

    }
    else
      e = e unblank(substr($0,9));
  }
}

END{if (di==0 && quiet == 0) {  
  print "\n\n\n\nDifferences in output:\n=====================";
  print "NONE!"; }
}

function unblank (a) {
  # first ignore trailing comments
  match(a,/\#/);
  # unless #I comment, discard
  if (RSTART>0 && substr(a,RSTART+1,1)!="I")
    a=substr(a,1,RSTART-1);

  # remove blanks
  match(a,/ /);
  while (RSTART>0) {
    a= substr(a,1,RSTART-1) substr(a,RSTART+1);
    match(a,/ /);
  }
  return a;
}
