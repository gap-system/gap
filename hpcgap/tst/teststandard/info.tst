#############################################################################
##
#W  info.tst
##
##
#Y  Copyright (C)  2015
##
##
gap> START_TEST("info.tst");
gap> InfoTest1 := NewInfoClass("InfoTest1");;
gap> InfoLevel(InfoTest1);
0
gap> Info(InfoTest1, 1, "No");
gap> Info(InfoTest1, 200, "No");
gap> SetInfoLevel(InfoTest1, 1);
gap> Info(InfoTest1, 1, "Yes");
#I  Yes
gap> Info(InfoTest1, 2, "No");
gap> Info(InfoTest1, 200, "No");
gap> Info(InfoTest1, 1, []);
#I  [  ]
gap> Info(InfoTest1, 1, [[]], [], 6);
#I  [ [  ] ][  ]6
gap> Info(InfoTest1, 1, (1,2)(3,4));
#I  (1,2)(3,4)
gap> Info(InfoTest1, 1, ['a', 'b', 'c']);
#I  abc
gap> STOP_TEST("info.tst", 1);

#############################################################################
##
#E
