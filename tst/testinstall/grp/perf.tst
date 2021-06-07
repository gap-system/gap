gap> START_TEST("perfectgroups.tst");

#
gap> NumberPerfectGroups(1);
1
gap> NumberPerfectGroups(30);
0
gap> NumberPerfectGroups(60);
1
gap> NumberPerfectGroups(60^6);
fail
gap> NumberPerfectLibraryGroups(60^6);
0

#
gap> Filtered(SizesPerfectGroups(),x->x<=10^6);
[ 1, 60, 120, 168, 336, 360, 504, 660, 720, 960, 1080, 1092, 1320, 1344, 
  1920, 2160, 2184, 2448, 2520, 2688, 3000, 3420, 3600, 3840, 4080, 4860, 
  4896, 5040, 5376, 5616, 5760, 6048, 6072, 6840, 7200, 7500, 7560, 7680, 
  7800, 7920, 9720, 9828, 10080, 10752, 11520, 12144, 12180, 14400, 14520, 
  14580, 14880, 15000, 15120, 15360, 15600, 16464, 17280, 19656, 20160, 
  21504, 21600, 23040, 24360, 25308, 25920, 28224, 29120, 29160, 29760, 
  30240, 30720, 32256, 32736, 34440, 34560, 37500, 39600, 39732, 40320, 
  43008, 43200, 43320, 43740, 46080, 48000, 50616, 51840, 51888, 56448, 
  57600, 57624, 58240, 58320, 58800, 60480, 61440, 62400, 64512, 64800, 
  65520, 68880, 69120, 74412, 75000, 77760, 79200, 79464, 79860, 80640, 
  84672, 86016, 86400, 87480, 92160, 95040, 96000, 100920, 102660, 103776, 
  110880, 112896, 113460, 115200, 115248, 115320, 116480, 117600, 120000, 
  120960, 122472, 122880, 126000, 129024, 129600, 131040, 131712, 138240, 
  144060, 146880, 148824, 150348, 151200, 151632, 155520, 158400, 159720, 
  160380, 161280, 169344, 172032, 174960, 175560, 178920, 180000, 181440, 
  183456, 184320, 187500, 190080, 192000, 194472, 201720, 205200, 205320, 
  216000, 221760, 223608, 225792, 226920, 230400, 232320, 233280, 237600, 
  240000, 241920, 243000, 244800, 244944, 245760, 246480, 254016, 258048, 
  259200, 262080, 262440, 263424, 265680, 276480, 285852, 288120, 291600, 
  293760, 300696, 302400, 311040, 320760, 322560, 332640, 336960, 344064, 
  345600, 352440, 357840, 360000, 362880, 363000, 364320, 366912, 367416, 
  368640, 369096, 372000, 375000, 378000, 384000, 387072, 388800, 388944, 
  393120, 393660, 410400, 411264, 411540, 417720, 423360, 432000, 435600, 
  443520, 446520, 447216, 450000, 451584, 453600, 456288, 460800, 460992, 
  464640, 466560, 468000, 475200, 480000, 483840, 489600, 491520, 492960, 
  504000, 515100, 516096, 518400, 524880, 531360, 544320, 546312, 550368, 
  552960, 571704, 574560, 583200, 587520, 589680, 600000, 604800, 604920, 
  607500, 612468, 622080, 626688, 633600, 645120, 647460, 665280, 673920, 
  675840, 677376, 685440, 688128, 691200, 693120, 699840, 704880, 712800, 
  720720, 721392, 725760, 728640, 729000, 730800, 733824, 734832, 737280, 
  748920, 768000, 774144, 777600, 786240, 787320, 806736, 816480, 820800, 
  822528, 823080, 846720, 864000, 871200, 874800, 878460, 881280, 885720, 
  887040, 892800, 900000, 903168, 907200, 912576, 921600, 921984, 929280, 
  933120, 936000, 937500, 943488, 950400, 950520, 960000, 962280, 967680, 
  976500, 979200, 979776, 983040, 987840 ]

#
gap> DisplayInformationPerfectGroups(1);
#I Perfect group 1:  trivial group
gap> DisplayInformationPerfectGroups(60);
#I Perfect group 60:  simple group  A5
#I   size = 2^2*3*5  orbit size = 5
#I   Holt-Plesken class 1 (0,1) (occurs also in classes 2, 3, 4, 5)
gap> DisplayInformationPerfectGroups(960);
#I Perfect group 960.1:  A5 2^4
#I   size = 2^6*3*5  orbit size = 16
#I   Holt-Plesken class 1 (4,1)
#I Perfect group 960.2:  A5 2^4'
#I   size = 2^6*3*5  orbit size = 10
#I   Holt-Plesken class 1 (4,2) (occurs also in class 7)
gap> DisplayInformationPerfectGroups(3420);
#I Perfect group 3420:  simple group  L2(19)
#I   size = 2^2*3^2*5*19  orbit size = 20
#I   Holt-Plesken class 22
gap> DisplayInformationPerfectGroups(3840,1);
#I Perfect group 3840:  A5 ( 2^4 E 2^1 A ) C 2^1 I
#I   centre = 4  size = 2^8*3*5  orbit size = 64
#I   Holt-Plesken class 1 (6,1)
gap> DisplayInformationPerfectGroups([3840,2]);
#I Perfect group 3840:  A5 ( 2^4 E 2^1 A ) C 2^1 II
#I   centre = 4  size = 2^8*3*5  orbit size = 64
#I   Holt-Plesken class 1 (6,2)
gap> DisplayInformationPerfectGroups(967680,4);
#I Perfect group 
967680:  quasisimple group  L3(4) 3^1 x ( 2^1 A 2^1 ) x ( 2^1 A 2^1 )
#I   centre = 48  size = 2^10*3^3*5*7  orbit sizes = 63 + 224 + 224
#I   Holt-Plesken class 27 (4,1)

#
gap> SizeNumbersPerfectGroups("A8");
[ [ 20160, 4 ], [ 40320, 3 ], [ 322560, 4 ], [ 322560, 5 ], [ 645120, 4 ], 
  [ 645120, 5 ], [ 1209600, 1 ], [ 1290240, 1 ] ]
gap> SizeNumbersPerfectGroups("A8",-1);
Error, illegal order of abelian factor
gap> SizeNumbersPerfectGroups("S8");
Error, illegal name of simple factor

#
gap> PerfectIdentification(AlternatingGroup(5));
[ 60, 1 ]
gap> PerfectIdentification(AlternatingGroup(4));
fail
gap> PerfectIdentification(AlternatingGroup(8));
[ 20160, 4 ]
gap> PerfectIdentification(PSL(5,2));
#W  No information about size 9999360 available
fail

#
# construct some perfect groups which exercise the different construction methods
#
gap> PerfectGroup(48000, 1);
A5 # 2^5 5^2 [1]
gap> PerfectGroup(56448, 1);
( L3(2) x L3(2) ) 2^1 [1]
gap> PerfectGroup(56448, 2);
( L3(2) x L3(2) ) 2^1 [2]
gap> PerfectGroup(77760, 1);
A5 # 2^4 3^4 [1]
gap> PerfectGroup(IsPermGroup, 48000, 1);
A5 # 2^5 5^2 [1]

#
# alternate constructors
#
gap> g:=PerfectGroup(IsPermGroup, 60, 1);
A5
gap> IsPermGroup(g);
true
gap> g:=PerfectGroup(IsSubgroupFpGroup, 60, 1);
A5
gap> IsFpGroup(g);
true

#
# test PerfGrpConst directly for some corner cases
#
gap> PerfGrpConst(IsPermGroup, []);
Group(())
gap> PerfGrpConst(IsSubgroupFpGroup, []);
<fp group on the generators [ f1 ]>
gap> PerfGrpConst(IsPermGroup, [[5]]);
Error, not supported
gap> PerfGrpConst(IsSubgroupFpGroup, [[5]]);
Error, not supported

#
# test error handling
#
gap> PerfectGroup(1,2);
Error, PerfectGroup(1,2) does not exist !
gap> PerfectGroup(30,1);
Error, PerfectGroup(30,1) does not exist !

#
gap> STOP_TEST("perfectgroups.tst", 1);
