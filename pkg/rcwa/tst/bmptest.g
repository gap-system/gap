#############################################################################
##
#W  bmptest.g                 GAP4 Package `RCWA'                 Stefan Kohl
##
##  This file contains a function which tests RCWA's functionality for
##  bitmap graphics files in general and for drawing orbit pictures in
##  particular.
##
#############################################################################

RCWABitmapGraphicsTest := function ( directory )

  local  PSL2Z, fname, outname, examples, i;

  PSL2Z := Image(IsomorphismRcwaGroup(FreeProduct(CyclicGroup(2),
                                                  CyclicGroup(3))));
  fname := List(["example1_1.bmp","example1_2.bmp","example2_1.bmp",
                 "example2_2.bmp","example3_1.bmp","example3_2.bmp"],
                str->Concatenation(directory,str));
  DrawOrbitPicture(PSL2Z,[0,1],20,512,512,false,fail,fname[1]);
  DrawOrbitPicture(PSL2Z,[0,1],20,337,510,false,fail,fname[2]);
  DrawOrbitPicture(PSL2Z,Combinations([1..4],2),20,512,512,true,
                   [[255,0,0],[0,255,0],[0,0,255]],fname[3]);
  DrawOrbitPicture(PSL2Z,Combinations([1..4],2),20,276,317,true,
                   [[255,0,0],[0,255,0],[0,0,255]],fname[4]);
  DrawOrbitPicture(PSL2Z,[0,1],20,256,256,true,
                   [[255,0,0],[0,255,0],[0,0,255]],fname[5]);
  DrawOrbitPicture(PSL2Z,[0,1],20,237,278,true,
                   [[255,0,0],[0,255,0],[0,0,255]],fname[6]);
  examples := List(fname,LoadBitmapPicture);
  for i in [1..6] do SaveAsBitmapPicture(examples[i],fname[i]); od;
end;

#############################################################################
##
#E  bmptest.g . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here