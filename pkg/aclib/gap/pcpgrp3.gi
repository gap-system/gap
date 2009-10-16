#############################################################################
##
#W    pcpgrp3.gi                                                Karel Dekimpe
#W                                                               Bettina Eick
##
##    This file contains the 3-dimensional almost crystallographic groups
##    as pcp groups. There are 17 types groups.
##

ACPcpGroupDim3Nr01 := function (k1) 
local FTL;
  FTL := FromTheLeftCollector( 3 );
  SetConjugate( FTL, 2, 1, [2,1,  3,k1] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim3Nr02 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 4 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [2,0,  3,0,  4,k4] );
  SetConjugate( FTL, 2, 1, [2,-1,  3,0,  4,k2] );
  SetConjugate( FTL, 3, 1, [2,0,  3,-1,  4,k3] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,1] );
  SetConjugate( FTL, 3, 2, [3,1,  4,k1] );
  SetConjugate( FTL, 4, 2, [3,0,  4,1] );
  SetConjugate( FTL, 4, 3, [4,1] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim3Nr03 := function (k1, k2) 
local FTL;
  FTL := FromTheLeftCollector( 4 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [2,0,  3,0,  4,0] );
  SetConjugate( FTL, 2, 1, [2,1,  3,0,  4,-k2] );
  SetConjugate( FTL, 3, 1, [2,0,  3,-1,  4,0] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,-1] );
  SetConjugate( FTL, 3, 2, [3,1,  4,k1] );
  SetConjugate( FTL, 4, 2, [3,0,  4,1] );
  SetConjugate( FTL, 4, 3, [4,1] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim3Nr04 := function (k1, k2) 
local FTL;
  FTL := FromTheLeftCollector( 4 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [2,1,  3,0,  4,k2] );
  SetConjugate( FTL, 2, 1, [2,1,  3,0,  4,2*k2] );
  SetConjugate( FTL, 3, 1, [2,0,  3,-1,  4,-k1] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,-1] );
  SetConjugate( FTL, 3, 2, [3,1,  4,2*k1] );
  SetConjugate( FTL, 4, 2, [3,0,  4,1] );
  SetConjugate( FTL, 4, 3, [4,1] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim3Nr05 := function (k1, k2) 
local FTL;
  FTL := FromTheLeftCollector( 4 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [2,0,  3,0,  4,0] );
  SetConjugate( FTL, 2, 1, [2,0,  3,1,  4,-k2] );
  SetConjugate( FTL, 3, 1, [2,1,  3,0,  4,-k2] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,-1] );
  SetConjugate( FTL, 3, 2, [3,1,  4,k1] );
  SetConjugate( FTL, 4, 2, [3,0,  4,1] );
  SetConjugate( FTL, 4, 3, [4,1] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim3Nr06 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,0,  5,-k4] );
  SetConjugate( FTL, 3, 1, [3,1,  4,0,  5,-k2] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,k4] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,k2] );
  SetConjugate( FTL, 4, 2, [3,0,  4,-1,  5,k3] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1] );
  SetConjugate( FTL, 4, 3, [4,1,  5,k1] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim3Nr07 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,-1,  5,-2*k3 - k4] );
  SetConjugate( FTL, 3, 1, [3,1,  4,0,  5,k1 - k2] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,k3] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,k2] );
  SetConjugate( FTL, 4, 2, [3,0,  4,-1,  5,-2*(k3 + k4)] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1] );
  SetConjugate( FTL, 4, 3, [4,1,  5,2*k1] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim3Nr08 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,1,  4,0,  5,-k3] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,1,  4,-1,  5,-2*k1 + k2 - 2*k3 - k4] );
  SetConjugate( FTL, 3, 1, [3,1,  4,0,  5,-2*k3] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,-k1] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,k4] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,k1 + 2*k3] );
  SetConjugate( FTL, 4, 2, [3,0,  4,-1,  5,-k1 + 2*k2 - 2*k3] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1] );
  SetConjugate( FTL, 4, 3, [4,1,  5,2*k1] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim3Nr09 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,0,  5,-k4] );
  SetConjugate( FTL, 3, 1, [3,0,  4,1,  5,-k3] );
  SetConjugate( FTL, 4, 1, [3,1,  4,0,  5,-k3] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,k4] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,k2] );
  SetConjugate( FTL, 4, 2, [3,0,  4,-1,  5,-k2 + 2*k3] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1] );
  SetConjugate( FTL, 4, 3, [4,1,  5,k1] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim3Nr10 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 4 );
  SetRelativeOrder( FTL, 1, 4 );
  SetPower( FTL, 1, [2,0,  3,0,  4,k4] );
  SetConjugate( FTL, 2, 1, [2,0,  3,-1,  4,k3] );
  SetConjugate( FTL, 3, 1, [2,1,  3,0,  4,-k2] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,1] );
  SetConjugate( FTL, 3, 2, [3,1,  4,k1] );
  SetConjugate( FTL, 4, 2, [3,0,  4,1] );
  SetConjugate( FTL, 4, 3, [4,1] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim3Nr11 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0] );
  SetConjugate( FTL, 2, 1, [2, 3 ,  3,0,  4,0,  5,-k4] );
  SetConjugate( FTL, 3, 1, [3,1,  4,0,  5,-k2 - k3] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1] );
  SetRelativeOrder( FTL, 2, 4 );
  SetPower( FTL, 2, [3,0,  4,0,  5,k4] );
  SetConjugate( FTL, 3, 2, [3,0,  4,-1,  5,k3] );
  SetConjugate( FTL, 4, 2, [3,1,  4,0,  5,-k2] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1] );
  SetConjugate( FTL, 4, 3, [4,1,  5,k1] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim3Nr12 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,1,  4,0,  5,k3] );
  SetConjugate( FTL, 2, 1, [2, 3 ,  3,0,  4,-1,  5,-k2 - k3 - k4] );
  SetConjugate( FTL, 3, 1, [3,1,  4,0,  5,2*k3] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,-k1] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1] );
  SetRelativeOrder( FTL, 2, 4 );
  SetPower( FTL, 2, [3,0,  4,0,  5,k4] );
  SetConjugate( FTL, 3, 2, [3,0,  4,-1,  5,k1 - k2 - 2*k3] );
  SetConjugate( FTL, 4, 2, [3,1,  4,0,  5,-k2] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1] );
  SetConjugate( FTL, 4, 3, [4,1,  5,2*k1] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim3Nr13 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 4 );
  SetRelativeOrder( FTL, 1, 3 );
  SetPower( FTL, 1, [2,0,  3,0,  4,k4] );
  SetConjugate( FTL, 2, 1, [2,-1,  3,-1,  4,k2 + k3] );
  SetConjugate( FTL, 3, 1, [2,1,  3,0,  4,-k2] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,1] );
  SetConjugate( FTL, 3, 2, [3,1,  4,k1] );
  SetConjugate( FTL, 4, 2, [3,0,  4,1] );
  SetConjugate( FTL, 4, 3, [4,1] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim3Nr14 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0] );
  SetConjugate( FTL, 2, 1, [2, 2 ,  3,0,  4,0,  5,-k4] );
  SetConjugate( FTL, 3, 1, [3,0,  4,-1,  5,-k2] );
  SetConjugate( FTL, 4, 1, [3,-1,  4,0,  5,k2] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1] );
  SetRelativeOrder( FTL, 2, 3 );
  SetPower( FTL, 2, [3,0,  4,0,  5,k4] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,-1,  5,k2 + k3] );
  SetConjugate( FTL, 4, 2, [3,1,  4,0,  5,-k2] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1] );
  SetConjugate( FTL, 4, 3, [4,1,  5,k1] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim3Nr15 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0] );
  SetConjugate( FTL, 2, 1, [2, 2 ,  3,0,  4,0,  5,-k4] );
  SetConjugate( FTL, 3, 1, [3,0,  4,1,  5,-k2] );
  SetConjugate( FTL, 4, 1, [3,1,  4,0,  5,-k2] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1] );
  SetRelativeOrder( FTL, 2, 3 );
  SetPower( FTL, 2, [3,0,  4,0,  5,k4] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,-1,  5,k1 + 3*k2 - k3] );
  SetConjugate( FTL, 4, 2, [3,1,  4,0,  5,-k1 - 3*k2 + 2*k3] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1] );
  SetConjugate( FTL, 4, 3, [4,1,  5,k1] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim3Nr16 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 4 );
  SetRelativeOrder( FTL, 1, 6 );
  SetPower( FTL, 1, [2,0,  3,0,  4,k4] );
  SetConjugate( FTL, 2, 1, [2,0,  3,-1,  4,k3] );
  SetConjugate( FTL, 3, 1, [2,1,  3,1,  4,k1 - k2 - k3] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,1] );
  SetConjugate( FTL, 3, 2, [3,1,  4,k1] );
  SetConjugate( FTL, 4, 2, [3,0,  4,1] );
  SetConjugate( FTL, 4, 3, [4,1] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim3Nr17 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0] );
  SetConjugate( FTL, 2, 1, [2, 5 ,  3,0,  4,0,  5,-k4] );
  SetConjugate( FTL, 3, 1, [3,0,  4,1,  5,-k3] );
  SetConjugate( FTL, 4, 1, [3,1,  4,0,  5,-k3] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1] );
  SetRelativeOrder( FTL, 2, 6 );
  SetPower( FTL, 2, [3,0,  4,0,  5,k4] );
  SetConjugate( FTL, 3, 2, [3,0,  4,-1,  5,k3] );
  SetConjugate( FTL, 4, 2, [3,1,  4,1,  5,k1 - k2 - k3] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1] );
  SetConjugate( FTL, 4, 3, [4,1,  5,k1] );
return PcpGroupByCollector(FTL);
end;

#############################################################################
##
## some small helpers
##
ACPcpDim3Funcs := [ ACPcpGroupDim3Nr01, ACPcpGroupDim3Nr02,
ACPcpGroupDim3Nr03,
ACPcpGroupDim3Nr04, ACPcpGroupDim3Nr05, ACPcpGroupDim3Nr06,
ACPcpGroupDim3Nr07, ACPcpGroupDim3Nr08, ACPcpGroupDim3Nr09,
ACPcpGroupDim3Nr10, ACPcpGroupDim3Nr11, ACPcpGroupDim3Nr12,
ACPcpGroupDim3Nr13, ACPcpGroupDim3Nr14, ACPcpGroupDim3Nr15,
ACPcpGroupDim3Nr16, ACPcpGroupDim3Nr17 ];
MakeReadOnlyGlobal( "ACPcpDim3Funcs" );

