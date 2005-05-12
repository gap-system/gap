# awk script to produce the three `INSTALL' files from a lynx-produced ASCII
# version of the installation chapter.
BEGIN{
  mode=0;
  unix="../../../../INSTALL";
  win ="../../../../INSTALL.WIN";
  mac ="../../../../INSTALL-MAC.TXT";
}

# set the different modes  (this refers to absolute section numbers!)
/1 Installation for the Impatient/{mode=2}
/2 Getting GAP/{mode=1}
/3 GAP for UNIX/{mode=2}
/8 GAP for Windows/{mode=3}
/12 GAP for MacOS/{mode=4}
/15 Testing for the System Architecture/{mode=9}
/16 Porting GAP/{mode=2}
/17 The Documentation/{mode=1}
/\[Top\]/{mode=0}

{ if (substr($0,1,3)!="   ") {
    # remove section numbers
    match($0,/[0-9]+\.[0-9]+/);
    if (RSTART==1) {
      $0=substr($0,RSTART+RLENGTH+1);
      eqlin=$0;
      gsub(/[ -~]/,"=",eqlin);

      $0="\n\n " eqlin;
    }
    else {
      $0="   " $0;
    }
  }
  if ((mode==1)||(mode==2)) {
    print $0 > unix;
  }
  if ((mode==1)||(mode==3)) {
    print $0 >win;
  }
  if ((mode==1)||(mode==4)) {
    print $0 >mac;
  }
}

