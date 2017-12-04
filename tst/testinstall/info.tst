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
gap> InfoTest2 := NewInfoClass("InfoTest2");;
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
gap> Info(InfoTest2, 1, "apple");
gap> Info(InfoTest1 + InfoTest2, 1, "apple");
#I  apple
gap> SetInfoLevel(InfoTest2, 2);
gap> Info(InfoTest2, 2, "apple");
#I  apple
gap> Info(InfoTest1 + InfoTest2, 2, "apple");
#I  apple
gap> Info(InfoTest1 + InfoTest2, 3, "apple");
gap> Info(1,2,3);
Error, usage : Info(<selectors>, <level>, ...)
gap> Info(InfoTest1,0,3);
Error, level 0 Info messages are not allowed
gap> Info(InfoTest1,"apple",3);
Error, usage : Info(<selectors>, <level>, ...)
gap> Info(InfoTest1 + InfoTest2, 0);
Error, level 0 Info messages are not allowed
gap> Info(InfoTest1 + InfoTest2, "apple");
Error, usage : Info(<selectors>, <level>, ...)
gap> str := "";;
gap> str2 := "";;
gap> SetDefaultInfoOutput(OutputTextString(str, false));
gap> SetInfoOutput(InfoTest1, OutputTextString(str2, false));
gap> Info(InfoTest1, 2, "No");
gap> Info(InfoTest1, 1, "One");
gap> Info(InfoTest2, 2, "Two");
gap> Info(InfoTest1 + InfoTest2, 2, "OneTwo");
gap> Info(InfoTest2 + InfoTest1, 2, "TwoOne");
gap> IsOutputTextStringRep(InfoOutput(InfoTest2));
true
gap> IsOutputTextStringRep(InfoOutput(InfoTest1));
true
gap> UnbindInfoOutput(InfoTest1);
gap> Info(InfoTest1, 1, "NormalOut");
gap> str;
"#I  Two\n#I  NormalOut\n"
gap> str2;
"#I  One\n#I  OneTwo\n#I  TwoOne\n"
gap> SetDefaultInfoOutput(MakeImmutable("*Print*"));
gap> Info(InfoTest2, 1, "NormalOut");
#I  NormalOut
gap> STOP_TEST("info.tst", 1);

#############################################################################
##
#E
