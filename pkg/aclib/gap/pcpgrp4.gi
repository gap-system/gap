#############################################################################
##
#W    pcpgrp4.gi                                                Karel Dekimpe
#W                                                               Bettina Eick
##
##    This file contains the 4-dimensional almost crystallographic groups
##    as pcp groups. There are 95 types of groups.
##

ACPcpGroupDim4Nr001 := function (k1, k2, k3) 
local FTL;
  FTL := FromTheLeftCollector( 4 );
  SetConjugate( FTL, 2, 1, [2,1, 4,k1 ] );
  SetConjugate( FTL, 3, 1, [3,1, 4,k2 ] );
  SetConjugate( FTL, 3, 2, [3,1, 4,k3 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr002 := function (k1, k2, k3 , k4, k5, k6, k7) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [2,0,  3,0,  4,0,  5,k7 ] );
  SetConjugate( FTL, 2, 1, [2,-1,  3,0,  4,0,  5,k4 ] );
  SetConjugate( FTL, 3, 1, [2,0,  3,-1,  4,0,  5,k5 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,-1,  5,k6 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,k1 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,k2 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,k3 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr003 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [2,0,  3,0,  4,0,  5,k4 ] );
  SetConjugate( FTL, 2, 1, [2,-1,  3,0,  4,0,  5,k2 ] );
  SetConjugate( FTL, 3, 1, [2,0,  3,1,  4,0,  5,0 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,-1,  5,k3 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,0 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,k1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr004 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [2,0,  3,1,  4,0,  5,k4 ] );
  SetConjugate( FTL, 2, 1, [2,-1,  3,0,  4,0,  5,k2 ] );
  SetConjugate( FTL, 3, 1, [2,0,  3,1,  4,0,  5,0 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,-1,  5,k3 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,0 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,k1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr004b:= function (k1, k2, k3 ) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [2,0,  3,1,  4,0,  5,k3 ] );
  SetConjugate( FTL, 2, 1, [2,-1,  3,0,  4,0,  5,k1 ] );
  SetConjugate( FTL, 3, 1, [2,0,  3,1,  4,0,  5,2*k3 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,-1,  5,-k2 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,-1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,2*k1 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,0 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,2*k2 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr005 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [2,0,  3,0,  4,0,  5,k4 ] );
  SetConjugate( FTL, 2, 1, [2,0,  3,-1,  4,0,  5,k2 ] );
  SetConjugate( FTL, 3, 1, [2,-1,  3,0,  4,0,  5,k2 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,-1,  5,k3 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,0 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,k1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr006 := function (k1, k2, k3 ) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [2,0,  3,0,  4,0,  5,k3 ] );
  SetConjugate( FTL, 2, 1, [2,1,  3,0,  4,0,  5,0 ] );
  SetConjugate( FTL, 3, 1, [2,0,  3,-1,  4,0,  5,k2 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,1,  5,0 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,0 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,k1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr007 := function (k1, k2, k3 ) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [2,0,  3,0,  4,1,  5,k3 ] );
  SetConjugate( FTL, 2, 1, [2,1,  3,0,  4,0,  5,-k1 ] );
  SetConjugate( FTL, 3, 1, [2,0,  3,-1,  4,0,  5,k2 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,1,  5,0 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,0 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,2*k1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr007b:= function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [2,0,  3,0,  4,1,  5,k4 ] );
  SetConjugate( FTL, 2, 1, [2,1,  3,0,  4,0,  5,-k3 ] );
  SetConjugate( FTL, 3, 1, [2,0,  3,-1,  4,0,  5,k2 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,1,  5,2*k4 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,-1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,k1 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,0 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,2*k2 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr008 := function (k1, k2, k3) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [2,0,  3,0,  4,0,  5,k3 ] );
  SetConjugate( FTL, 2, 1, [2,0,  3,1,  4,0,  5,k2 ] );
  SetConjugate( FTL, 3, 1, [2,1,  3,0,  4,0,  5,-k2 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,1,  5,0 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,0 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,k1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr009 := function (k1, k2, k3) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [2,0,  3,0,  4,1,  5,k3 ] );
  SetConjugate( FTL, 2, 1, [2,0,  3,1,  4,0,  5,-k1 + k2 ] );
  SetConjugate( FTL, 3, 1, [2,1,  3,0,  4,0,  5,-k2 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,1,  5,0 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,0 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,k1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr009b:= function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [2,0,  3,0,  4,1,  5,k4 ] );
  SetConjugate( FTL, 2, 1, [2,0,  3,1,  4,0,  5,k2 - k3 ] );
  SetConjugate( FTL, 3, 1, [2,1,  3,0,  4,0,  5,-k3 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,1,  5,2*k4 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,-1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,k1 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,k2 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,-k2 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr010 := function (k1, k2, k3 , k4, k5, k6) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0,  6,k6 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,0,  5,0,  6,0 ] );
  SetConjugate( FTL, 3, 1, [3,-1,  4,0,  5,0,  6,k2 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,k5 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1,  6,k3 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,0,  6,k4 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,0,  6,k2 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,-1,  6,k3 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,k1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr011 := function (k1, k2, k3 , k4, k5, k6) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0,  6,k5 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,-1,  5,0,  6,-k6 ] );
  SetConjugate( FTL, 3, 1, [3,-1,  4,0,  5,0,  6,k2 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,-2*k6 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1,  6,k3 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,1,  5,0,  6,k4 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,0,  6,k2 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,-1,  6,k3 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,k1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr012 := function (k1, k2, k3 , k4, k5, k6) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0,  6,k6 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,0,  5,0,  6,0 ] );
  SetConjugate( FTL, 3, 1, [3,-1,  4,0,  5,0,  6,k5 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,2*k2 - k5 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1,  6,k3 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,0,  6,k4 ] );
  SetConjugate( FTL, 3, 2, [3,0,  4,-1,  5,0,  6,k2 ] );
  SetConjugate( FTL, 4, 2, [3,-1,  4,0,  5,0,  6,k2 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,-1,  6,k3 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,k1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr013 := function (k1, k2, k3 , k4, k5, k6) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0,  6,k5 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,0,  5,1,  6,k6 ] );
  SetConjugate( FTL, 3, 1, [3,-1,  4,0,  5,0,  6,k1 + k2 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,k4 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1,  6,-2*k6 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,0,  6,k3 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,0,  6,k2 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,-1,  6,-2*k6 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,2*k1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr014 := function (k1, k2, k3 , k4, k5, k6) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0,  6,k5 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,-1,  5,1,  6,-k3 - k6 ] );
  SetConjugate( FTL, 3, 1, [3,-1,  4,0,  5,0,  6,k1 + k2 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,-k3 - 2*k6 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1,  6,k3 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,1,  5,0,  6,k4 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,0,  6,k2 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,-1,  6,k3 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,2*k1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr014b:= function (k1, k2, k3 , k4, k5, k6) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0,  6,k5 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,-1,  5,1,  6,-k2 - 2*k3 + 2*k5 - k6 ] );
  SetConjugate( FTL, 3, 1, [3,-1,  4,0,  5,0,  6,k4 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,k2 - 2*k3 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1,  6,k2 + 2*k3 - 2*k5 + 2*k6 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,1,  5,0,  6,k3 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,0,  6,k1 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,1,  5,0,  6,2*k3 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,-1,  6,-k2 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,-1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,2*k1 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,2*k2 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr015 := function (k1, k2, k3 , k4, k5, k6) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0,  6,k5 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,0,  5,1,  6,k6 ] );
  SetConjugate( FTL, 3, 1, [3,-1,  4,0,  5,0,  6,k4 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,k1 + 2*k2 - k4 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1,  6,-2*k6 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,0,  6,k3 ] );
  SetConjugate( FTL, 3, 2, [3,0,  4,-1,  5,0,  6,k2 ] );
  SetConjugate( FTL, 4, 2, [3,-1,  4,0,  5,0,  6,k2 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,-1,  6,-2*k6 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,k1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr018 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,1,  5,0,  6,k3 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,1,  4,1,  5,0,  6,k1 - 2*k2 + 2*k3 - k4 ] );
  SetConjugate( FTL, 3, 1, [3,-1,  4,0,  5,0,  6,k1 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,1,  5,0,  6,2*k3 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1,  6,0 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,-1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,0,  6,k2 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,0,  6,-k1 + 2*k2 - 2*k3 + 2*k4 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,-1,  5,0,  6,k1 - 2*k3 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,0 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,2*k1 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr019 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,1,  5,0,  6,k3 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,1,  4,1,  5,-1,  6,-3*k1 - 2*k2 + 2*k3 - k4 ] );
  SetConjugate( FTL, 3, 1, [3,-1,  4,0,  5,0,  6,3*k1 + 2*k2 - 2*k3 + 2*k4 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1,  6,-k1 - 2*k2 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,1,  6,k2 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,0,  6,k1 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,-1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,2*k2 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,-1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,2*k1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr019b:= function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,1,  5,0,  6,k3 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,1,  4,1,  5,-1,  6,k1 - 2*k2 + 2*k3 - k4 ] );
  SetConjugate( FTL, 3, 1, [3,-1,  4,0,  5,0,  6,k1 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,1,  5,0,  6,2*k3 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1,  6,0 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,-1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,1,  6,k2 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,0,  6,-k1 + 2*k2 - 2*k3 + 2*k4 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,-1,  5,0,  6,k1 - 2*k3 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,0 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,2*k1 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr019c:= function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,1,  5,0,  6,k3 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,1,  4,1,  5,-1,  6,-2*k2 + 2*k3 + k4 ] );
  SetConjugate( FTL, 3, 1, [3,-1,  4,0,  5,0,  6,0 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,1,  5,0,  6,2*k3 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1,  6,-k1 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,-1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,1,  6,k2 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,0,  6,0 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,-1,  5,0,  6,k1 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,2*k2 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,-1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,2*k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr026 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0,  6,k4 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,0,  5,0,  6,k4 ] );
  SetConjugate( FTL, 3, 1, [3,1,  4,0,  5,0,  6,0 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,k3 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,1,  6,0 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,1,  6,k2 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,0,  6,k1 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,-1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,2*k2 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,-1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,2*k1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr027 := function (k1, k2, k3 , k4, k5) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,1,  6,k5 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,0,  5,0,  6,-k4 ] );
  SetConjugate( FTL, 3, 1, [3,1,  4,0,  5,0,  6,-k2 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,1,  6,2*k5 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,-1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,0,  6,k4 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,0,  6,k2 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,-1,  5,0,  6,k3 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,0 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,k1 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr029 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,1,  6,k3 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,1,  5,0,  6,-2*k2 + 2*k3 - k4 ] );
  SetConjugate( FTL, 3, 1, [3,1,  4,0,  5,0,  6,-k1 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,2*(k2 - k3 + k4) ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,1,  6,0 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,1,  6,k2 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,0,  6,k1 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,-1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,2*k2 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,-1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,2*k1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr029b:= function (k1, k2, k3 , k4, k5) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,1,  6,k4 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,1,  5,0,  6,-2*k3 + 2*k4 - k5 ] );
  SetConjugate( FTL, 3, 1, [3,1,  4,0,  5,0,  6,-k1 - k2 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,1,  6,2*k4 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,-1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,1,  6,k3 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,0,  6,k2 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,-1,  5,0,  6,2*(k3 - k4 + k5) ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,0 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,2*k1 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr029c:= function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,1,  6,k1 + k2 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,1,  5,0,  6,-4*k1 + k4 ] );
  SetConjugate( FTL, 3, 1, [3,1,  4,0,  5,0,  6,-k3 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,2*k1 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,1,  6,2*(k1 + k2) ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,-1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,1,  6,k2 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,0,  6,0 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,-1,  5,0,  6,2*k1 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,2*k2 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,-1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,4*k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr030 := function (k1, k2, k3 , k4, k5) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,1,  6,k4 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,1,  5,0,  6,-2*k3 - k5 ] );
  SetConjugate( FTL, 3, 1, [3,1,  4,0,  5,0,  6,-k1 - k2 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,1,  6,2*k4 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,-1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,0,  6,k3 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,0,  6,k2 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,-1,  5,0,  6,2*(k3 + k5) ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,0 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,2*k1 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr031 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0,  6,k3 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,1,  5,0,  6,2*k3 - k4 ] );
  SetConjugate( FTL, 3, 1, [3,1,  4,0,  5,0,  6,0 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,-2*(k3 - k4) ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,1,  6,0 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,1,  6,k2 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,0,  6,k1 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,-1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,2*k2 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,-1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,2*k1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr032 := function (k1, k2, k3 , k4, k5) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,1,  4,0,  5,0,  6,k4 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,1,  4,1,  5,0,  6,3*k1 - 2*k2 + 2*k4 - k5 ] );
  SetConjugate( FTL, 3, 1, [3,1,  4,0,  5,0,  6,2*k4 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,-k1 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,1,  6,-k3 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,-1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,0,  6,k2 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,0,  6,-k1 - 2*k4 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,-1,  5,0,  6,-3*k1 + 2*k2 - 2*k4 + 2*k5 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,0 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,2*k1 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr033 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,1,  4,0,  5,0,  6,k3 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,1,  4,1,  5,0,  6,2*k3 - k4 ] );
  SetConjugate( FTL, 3, 1, [3,1,  4,0,  5,0,  6,0 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,-k1 - 2*k3 + 2*k4 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,1,  6,k1 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,1,  6,k2 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,0,  6,k1 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,-1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,2*k2 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,-1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,2*k1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr033b:= function (k1, k2, k3 , k4, k5) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,1,  4,0,  5,0,  6,k4 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,1,  4,1,  5,0,  6,3*k1 - 2*k2 - k3 + 2*k4 - k5 ] );
  SetConjugate( FTL, 3, 1, [3,1,  4,0,  5,0,  6,2*k4 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,-k1 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,1,  6,-k3 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,-1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,1,  6,k2 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,0,  6,-k1 - 2*k4 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,-1,  5,0,  6,-3*k1 + 2*k2 + k3 - 2*k4 + 2*k5 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,0 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,2*k1 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr033c:= function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,1,  4,0,  5,0,  6,k3 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,1,  4,1,  5,0,  6,-k1 + 2*k3 + k4 ] );
  SetConjugate( FTL, 3, 1, [3,1,  4,0,  5,0,  6,2*k3 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,1,  6,k1 + 2*k2 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,-1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,1,  6,k2 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,0,  6,0 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,-1,  5,0,  6,k1 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,2*k2 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,-1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,2*k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr034 := function (k1, k2, k3 , k4, k5) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,1,  4,0,  5,1,  6,k4 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,1,  4,1,  5,0,  6,2*k1 - k2 - 2*k3 - k5 ] );
  SetConjugate( FTL, 3, 1, [3,1,  4,0,  5,0,  6,-k1 - k2 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,-k1 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,1,  6,k1 + k2 + 2*k4 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,-1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,0,  6,k3 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,0,  6,k2 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,-1,  5,0,  6,-2*k1 + k2 + 2*k3 + 2*k5 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,0 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,2*k1 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr036 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0,  6,k4 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,0,  5,0,  6,k4 ] );
  SetConjugate( FTL, 3, 1, [3,0,  4,1,  5,0,  6,k3 ] );
  SetConjugate( FTL, 4, 1, [3,1,  4,0,  5,0,  6,-k3 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,1,  6,0 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,1,  6,k2 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,0,  6,k1 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,-1,  5,0,  6,k1 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,2*k2 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,-1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,2*k1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,2*k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr037 := function (k1, k2, k3 , k4, k5) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,1,  6,k5 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,0,  5,0,  6,-k3 ] );
  SetConjugate( FTL, 3, 1, [3,0,  4,1,  5,0,  6,-k4 ] );
  SetConjugate( FTL, 4, 1, [3,1,  4,0,  5,0,  6,-k4 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,1,  6,2*k5 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,-1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,0,  6,k3 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,0,  6,k2 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,-1,  5,0,  6,-k2 + 2*k4 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,0 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,k1 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr041 := function (k1, k2, k3 , k4, k5) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,1,  6,k5 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,1,  4,1,  5,1,  6,k1 - k2 - k3 + k5 ] );
  SetConjugate( FTL, 3, 1, [3,0,  4,-1,  5,0,  6,2*k1 - k4 ] );
  SetConjugate( FTL, 4, 1, [3,-1,  4,0,  5,0,  6,k4 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,1,  6,2*k5 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,-1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,0,  6,k3 ] );
  SetConjugate( FTL, 3, 2, [3,0,  4,-1,  5,0,  6,k2 ] );
  SetConjugate( FTL, 4, 2, [3,-1,  4,0,  5,0,  6,k2 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,-1,  6,2*(k1 - k5) ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,2*k1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,2*k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr043 := function (k1, k2, k3 , k4, k5) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,1,  5,0,  6,k4 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,0,  5,1,  6,-k2 - 2*k3 - k5 ] );
  SetConjugate( FTL, 3, 1, [3,0,  4,1,  5,-1,  6,k1 + k2 + 2*k4 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,1,  5,0,  6,2*k4 ] );
  SetConjugate( FTL, 5, 1, [3,-1,  4,1,  5,0,  6,-k2 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,-1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,0,  6,k3 ] );
  SetConjugate( FTL, 3, 2, [3,0,  4,1,  5,-1,  6,k2 + 2*k3 + 2*k5 ] );
  SetConjugate( FTL, 4, 2, [3,1,  4,0,  5,-1,  6,k2 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,-1,  6,2*(k2 + k3 + k5) ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,k1 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,k1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,-k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr045 := function (k1, k2, k3 , k4, k5) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,1,  4,1,  5,0,  6,k5 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,0,  5,0,  6,-k3 ] );
  SetConjugate( FTL, 3, 1, [3,0,  4,0,  5,-1,  6,-k4 ] );
  SetConjugate( FTL, 4, 1, [3,1,  4,1,  5,1,  6,k4 + 2*k5 ] );
  SetConjugate( FTL, 5, 1, [3,-1,  4,0,  5,0,  6,k4 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,-1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,0,  6,k3 ] );
  SetConjugate( FTL, 3, 2, [3,0,  4,1,  5,0,  6,k2 ] );
  SetConjugate( FTL, 4, 2, [3,1,  4,0,  5,0,  6,-k2 ] );
  SetConjugate( FTL, 5, 2, [3,-1,  4,-1,  5,-1,  6,k2 - 2*k4 - 2*k5 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,k1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,-k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr055 := function (k1, k2, k3 , k4, k5, k6) 
local FTL;
  FTL := FromTheLeftCollector( 7 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [4,0,  5,0,  6,0,  7,2*k1 + k2 + k4 + k6 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  4,1,  5,-1,  6,0,  7,k1 + 2*k2 - 2*k3 + 2*k4 + k6 ] );
  SetConjugate( FTL, 3, 1, [3, 1 ,  4,0,  5,0,  6,0,  7,0 ] );
  SetConjugate( FTL, 4, 1, [4,-1,  5,0,  6,0,  7,-k1 - 2*k2 + 2*k3 - 2*k4 ] );
  SetConjugate( FTL, 5, 1, [4,0,  5,-1,  6,0,  7,-k1 - 2*k3 ] );
  SetConjugate( FTL, 6, 1, [4,0,  5,0,  6,-1,  7,k5 ] );
  SetConjugate( FTL, 7, 1, [4,0,  5,0,  6,0,  7,1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [4,0,  5,1,  6,0,  7,k3 ] );
  SetConjugate( FTL, 3, 2, [ 3, 1,  4,-1,  5,1,  6,0,  7,-k1 - 2*k2 + 2*k3 - k4 ] );
  SetConjugate( FTL, 4, 2, [4,-1,  5,0,  6,0,  7,k1 ] );
  SetConjugate( FTL, 5, 2, [4,0,  5,1,  6,0,  7,2*k3 ] );
  SetConjugate( FTL, 6, 2, [4,0,  5,0,  6,-1,  7,0 ] );
  SetConjugate( FTL, 7, 2, [4,0,  5,0,  6,0,  7,-1 ] );
  SetRelativeOrder( FTL, 3, 2 );
  SetPower( FTL, 3, [4,0,  5,0,  6,0,  7,k2 ] );
  SetConjugate( FTL, 4, 3, [4,-1,  5,0,  6,0,  7,-k1 - 2*k2 + 2*k3 - 2*k4 ] );
  SetConjugate( FTL, 5, 3, [4,0,  5,-1,  6,0,  7,-k1 - 2*k3 ] );
  SetConjugate( FTL, 6, 3, [4,0,  5,0,  6,1,  7,0 ] );
  SetConjugate( FTL, 7, 3, [4,0,  5,0,  6,0,  7,1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0,  7,2*k1 ] );
  SetConjugate( FTL, 6, 4, [6,1,  7,0 ] );
  SetConjugate( FTL, 6, 5, [6,1,  7,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr056 := function (k1, k2, k3 , k4, k5, k6) 
local FTL;
  FTL := FromTheLeftCollector( 7 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [4,0,  5,0,  6,0,  7,k6 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  4,0,  5,-1,  6,1,  7,-2*k3 - k5 + 2*k6 ] );
  SetConjugate( FTL, 3, 1, [3, 1 ,  4,1,  5,1,  6,0,  7,k4 ] );
  SetConjugate( FTL, 4, 1, [4,-1,  5,0,  6,0,  7,2*(k1 + k3 - k4) ] );
  SetConjugate( FTL, 5, 1, [4,0,  5,-1,  6,0,  7,-2*k3 ] );
  SetConjugate( FTL, 6, 1, [4,0,  5,0,  6,-1,  7,2*(k3 + k5 - k6) ] );
  SetConjugate( FTL, 7, 1, [4,0,  5,0,  6,0,  7,1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [4,0,  5,1,  6,0,  7,k3 ] );
  SetConjugate( FTL, 3, 2, [ 3, 1,  4,1,  5,1,  6,0,  7,-k2 + k4 ] );
  SetConjugate( FTL, 4, 2, [4,-1,  5,0,  6,0,  7,k1 ] );
  SetConjugate( FTL, 5, 2, [4,0,  5,1,  6,0,  7,2*k3 ] );
  SetConjugate( FTL, 6, 2, [4,0,  5,0,  6,-1,  7,0 ] );
  SetConjugate( FTL, 7, 2, [4,0,  5,0,  6,0,  7,-1 ] );
  SetRelativeOrder( FTL, 3, 2 );
  SetPower( FTL, 3, [4,0,  5,0,  6,0,  7,k2 ] );
  SetConjugate( FTL, 4, 3, [4,-1,  5,0,  6,0,  7,k1 + 2*k3 - 2*k4 ] );
  SetConjugate( FTL, 5, 3, [4,0,  5,-1,  6,0,  7,k1 - 2*k3 ] );
  SetConjugate( FTL, 6, 3, [4,0,  5,0,  6,1,  7,0 ] );
  SetConjugate( FTL, 7, 3, [4,0,  5,0,  6,0,  7,1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0,  7,2*k1 ] );
  SetConjugate( FTL, 6, 4, [6,1,  7,0 ] );
  SetConjugate( FTL, 6, 5, [6,1,  7,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr058 := function (k1, k2, k3 , k4, k5, k6) 
local FTL;
  FTL := FromTheLeftCollector( 7 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [4,0,  5,0,  6,0,  7,k6 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  4,1,  5,-1,  6,1,  7,-3*k1 - 2*k3 - k5 + 2*k6 ] );
  SetConjugate( FTL, 3, 1, [3, 1 ,  4,0,  5,0,  6,0,  7,0 ] );
  SetConjugate( FTL, 4, 1, [4,-1,  5,0,  6,0,  7,-k1 - 2*k2 + 2*k3 - 2*k4 ] );
  SetConjugate( FTL, 5, 1, [4,0,  5,-1,  6,0,  7,-k1 - 2*k3 ] );
  SetConjugate( FTL, 6, 1, [4,0,  5,0,  6,-1,  7,2*(2*k1 + k2 + k4 + k5 - k6) ] );
  SetConjugate( FTL, 7, 1, [4,0,  5,0,  6,0,  7,1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [4,0,  5,1,  6,0,  7,k3 ] );
  SetConjugate( FTL, 3, 2, [ 3, 1,  4,-1,  5,1,  6,0,  7,-k1 - 2*k2 + 2*k3 - k4 ] );
  SetConjugate( FTL, 4, 2, [4,-1,  5,0,  6,0,  7,k1 ] );
  SetConjugate( FTL, 5, 2, [4,0,  5,1,  6,0,  7,2*k3 ] );
  SetConjugate( FTL, 6, 2, [4,0,  5,0,  6,-1,  7,0 ] );
  SetConjugate( FTL, 7, 2, [4,0,  5,0,  6,0,  7,-1 ] );
  SetRelativeOrder( FTL, 3, 2 );
  SetPower( FTL, 3, [4,0,  5,0,  6,0,  7,k2 ] );
  SetConjugate( FTL, 4, 3, [4,-1,  5,0,  6,0,  7,-k1 - 2*k2 + 2*k3 - 2*k4 ] );
  SetConjugate( FTL, 5, 3, [4,0,  5,-1,  6,0,  7,-k1 - 2*k3 ] );
  SetConjugate( FTL, 6, 3, [4,0,  5,0,  6,1,  7,0 ] );
  SetConjugate( FTL, 7, 3, [4,0,  5,0,  6,0,  7,1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0,  7,2*k1 ] );
  SetConjugate( FTL, 6, 4, [6,1,  7,0 ] );
  SetConjugate( FTL, 6, 5, [6,1,  7,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr060 := function (k1, k2, k3 , k4, k5, k6) 
local FTL;
  FTL := FromTheLeftCollector( 7 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [4,0,  5,0,  6,0,  7,k6 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  4,0,  5,-1,  6,1,  7,-2*k3 - k5 + 2*k6 ] );
  SetConjugate( FTL, 3, 1, [3, 1 ,  4,1,  5,0,  6,0,  7,k1 - k2 + k3 - k4 ] );
  SetConjugate( FTL, 4, 1, [4,-1,  5,0,  6,0,  7,-2*(k1 - k2 + k3 - k4) ] );
  SetConjugate( FTL, 5, 1, [4,0,  5,-1,  6,0,  7,-2*k3 ] );
  SetConjugate( FTL, 6, 1, [4,0,  5,0,  6,-1,  7,2*(k3 + k5 - k6) ] );
  SetConjugate( FTL, 7, 1, [4,0,  5,0,  6,0,  7,1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [4,0,  5,1,  6,0,  7,k3 ] );
  SetConjugate( FTL, 3, 2, [ 3, 1,  4,1,  5,1,  6,0,  7,2*k1 - 2*k2 + 2*k3 - k4 ] );
  SetConjugate( FTL, 4, 2, [4,-1,  5,0,  6,0,  7,2*k1 ] );
  SetConjugate( FTL, 5, 2, [4,0,  5,1,  6,0,  7,2*k3 ] );
  SetConjugate( FTL, 6, 2, [4,0,  5,0,  6,-1,  7,0 ] );
  SetConjugate( FTL, 7, 2, [4,0,  5,0,  6,0,  7,-1 ] );
  SetRelativeOrder( FTL, 3, 2 );
  SetPower( FTL, 3, [4,0,  5,0,  6,0,  7,k2 ] );
  SetConjugate( FTL, 4, 3, [4,-1,  5,0,  6,0,  7,-2*(k1 - k2 + k3 - k4) ] );
  SetConjugate( FTL, 5, 3, [4,0,  5,-1,  6,0,  7,2*(k1 - k3) ] );
  SetConjugate( FTL, 6, 3, [4,0,  5,0,  6,1,  7,0 ] );
  SetConjugate( FTL, 7, 3, [4,0,  5,0,  6,0,  7,1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0,  7,4*k1 ] );
  SetConjugate( FTL, 6, 4, [6,1,  7,0 ] );
  SetConjugate( FTL, 6, 5, [6,1,  7,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr061 := function (k1, k2, k3 , k4, k5, k6) 
local FTL;
  FTL := FromTheLeftCollector( 7 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [4,0,  5,0,  6,0,  7,-k1 + k3 - k4 + k5 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  4,0,  5,-1,  6,1,  7,2*k1 + 2*k2 - k6 ] );
  SetConjugate( FTL, 3, 1, [3, 1 ,  4,1,  5,0,  6,-1,  7,-8*k1 - 2*k2 + 2*k3 - 2*k4 + k5 ] );
  SetConjugate( FTL, 4, 1, [4,-1,  5,0,  6,0,  7,2*(4*k1 + k2 - k3 + k4) ] );
  SetConjugate( FTL, 5, 1, [4,0,  5,-1,  6,0,  7,2*(k1 + k2 - k6) ] );
  SetConjugate( FTL, 6, 1, [4,0,  5,0,  6,-1,  7,-2*(k1 + k2) ] );
  SetConjugate( FTL, 7, 1, [4,0,  5,0,  6,0,  7,1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [4,0,  5,1,  6,0,  7,k3 ] );
  SetConjugate( FTL, 3, 2, [ 3, 1,  4,1,  5,1,  6,-1,  7,-6*k1 - 2*k2 + 2*k3 - k4 ] );
  SetConjugate( FTL, 4, 2, [4,-1,  5,0,  6,0,  7,2*(3*k1 + k2 - k3 + k4) ] );
  SetConjugate( FTL, 5, 2, [4,0,  5,1,  6,0,  7,0 ] );
  SetConjugate( FTL, 6, 2, [4,0,  5,0,  6,-1,  7,-2*(k1 + k2) ] );
  SetConjugate( FTL, 7, 2, [4,0,  5,0,  6,0,  7,1 ] );
  SetRelativeOrder( FTL, 3, 2 );
  SetPower( FTL, 3, [4,0,  5,0,  6,1,  7,k2 ] );
  SetConjugate( FTL, 4, 3, [4,-1,  5,0,  6,0,  7,2*k1 ] );
  SetConjugate( FTL, 5, 3, [4,0,  5,-1,  6,0,  7,0 ] );
  SetConjugate( FTL, 6, 3, [4,0,  5,0,  6,1,  7,2*k2 ] );
  SetConjugate( FTL, 7, 3, [4,0,  5,0,  6,0,  7,-1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0,  7,0 ] );
  SetConjugate( FTL, 6, 4, [6,1,  7,4*k1 ] );
  SetConjugate( FTL, 6, 5, [6,1,  7,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr061b := function (k1, k2, k3 , k4, k5, k6) 
local FTL;
  FTL := FromTheLeftCollector( 7 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [4,0,  5,0,  6,0,  7,-k1 + k2 + k4 + k5 + k6 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  4,0,  5,-1,  6,1,  7,-2*k1 + 2*k2 - 2*k3 + 2*k4 + 2*k5 + k6 ] );
  SetConjugate( FTL, 3, 1, [3, 1 ,  4,1,  5,0,  6,-1,  7,2*k1 - 2*k2 + 2*k3 - 2*k4 - k5 ] );
  SetConjugate( FTL, 4, 1, [4,-1,  5,0,  6,0,  7,-2*(k1 - k2 + k3 - k4) ] );
  SetConjugate( FTL, 5, 1, [4,0,  5,-1,  6,0,  7,-2*k3 ] );
  SetConjugate( FTL, 6, 1, [4,0,  5,0,  6,-1,  7,2*(k1 - k2 + k3 - k4 - k5) ] );
  SetConjugate( FTL, 7, 1, [4,0,  5,0,  6,0,  7,1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [4,0,  5,1,  6,0,  7,k3 ] );
  SetConjugate( FTL, 3, 2, [ 3, 1,  4,1,  5,1,  6,-1,  7,2*k1 - 2*k2 + 2*k3 - k4 ] );
  SetConjugate( FTL, 4, 2, [4,-1,  5,0,  6,0,  7,2*k1 ] );
  SetConjugate( FTL, 5, 2, [4,0,  5,1,  6,0,  7,2*k3 ] );
  SetConjugate( FTL, 6, 2, [4,0,  5,0,  6,-1,  7,0 ] );
  SetConjugate( FTL, 7, 2, [4,0,  5,0,  6,0,  7,-1 ] );
  SetRelativeOrder( FTL, 3, 2 );
  SetPower( FTL, 3, [4,0,  5,0,  6,1,  7,k2 ] );
  SetConjugate( FTL, 4, 3, [4,-1,  5,0,  6,0,  7,-2*(k1 - k2 + k3 - k4) ] );
  SetConjugate( FTL, 5, 3, [4,0,  5,-1,  6,0,  7,2*(k1 - k3) ] );
  SetConjugate( FTL, 6, 3, [4,0,  5,0,  6,1,  7,0 ] );
  SetConjugate( FTL, 7, 3, [4,0,  5,0,  6,0,  7,1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0,  7,4*k1 ] );
  SetConjugate( FTL, 6, 4, [6,1,  7,0 ] );
  SetConjugate( FTL, 6, 5, [6,1,  7,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr061c:= function (k1, k2, k3 , k4, k5, k6) 
local FTL;
  FTL := FromTheLeftCollector( 7 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [4,0,  5,0,  6,0,  7,k1 + k2 + k3 + k6 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  4,0,  5,-1,  6,1,  7,2*k2 + k6 ] );
  SetConjugate( FTL, 3, 1, [3, 1 ,  4,1,  5,0,  6,-1,  7,2*k1 + 2*k3 - k5 + 2*k6 ] );
  SetConjugate( FTL, 4, 1, [4,-1,  5,0,  6,0,  7,-2*(k1 + k3 - k5 + k6) ] );
  SetConjugate( FTL, 5, 1, [4,0,  5,-1,  6,0,  7,2*(k1 - k3) ] );
  SetConjugate( FTL, 6, 1, [4,0,  5,0,  6,-1,  7,-2*k2 ] );
  SetConjugate( FTL, 7, 1, [4,0,  5,0,  6,0,  7,1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [4,0,  5,1,  6,0,  7,k3 ] );
  SetConjugate( FTL, 3, 2, [ 3, 1,  4,1,  5,1,  6,-1,  7,-2*k2 + 2*k3 + k4 ] );
  SetConjugate( FTL, 4, 2, [4,-1,  5,0,  6,0,  7,0 ] );
  SetConjugate( FTL, 5, 2, [4,0,  5,1,  6,0,  7,2*k3 ] );
  SetConjugate( FTL, 6, 2, [4,0,  5,0,  6,-1,  7,-2*k1 ] );
  SetConjugate( FTL, 7, 2, [4,0,  5,0,  6,0,  7,-1 ] );
  SetRelativeOrder( FTL, 3, 2 );
  SetPower( FTL, 3, [4,0,  5,0,  6,1,  7,k2 ] );
  SetConjugate( FTL, 4, 3, [4,-1,  5,0,  6,0,  7,0 ] );
  SetConjugate( FTL, 5, 3, [4,0,  5,-1,  6,0,  7,2*k1 ] );
  SetConjugate( FTL, 6, 3, [4,0,  5,0,  6,1,  7,2*k2 ] );
  SetConjugate( FTL, 7, 3, [4,0,  5,0,  6,0,  7,-1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0,  7,0 ] );
  SetConjugate( FTL, 6, 4, [6,1,  7,0 ] );
  SetConjugate( FTL, 6, 5, [6,1,  7,4*k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr062 := function (k1, k2, k3 , k4, k5, k6) 
local FTL;
  FTL := FromTheLeftCollector( 7 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [4,0,  5,0,  6,0,  7,k3 - k4 + k5 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  4,0,  5,-1,  6,0,  7,-k6 ] );
  SetConjugate( FTL, 3, 1, [3, 1 ,  4,1,  5,0,  6,-1,  7,-3*k1 - 2*k2 + 2*k3 - 2*k4 + k5 ] );
  SetConjugate( FTL, 4, 1, [4,-1,  5,0,  6,0,  7,3*k1 + 2*k2 - 2*k3 + 2*k4 ] );
  SetConjugate( FTL, 5, 1, [4,0,  5,-1,  6,0,  7,-2*k6 ] );
  SetConjugate( FTL, 6, 1, [4,0,  5,0,  6,-1,  7,-k1 - 2*k2 ] );
  SetConjugate( FTL, 7, 1, [4,0,  5,0,  6,0,  7,1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [4,0,  5,1,  6,0,  7,k3 ] );
  SetConjugate( FTL, 3, 2, [ 3, 1,  4,1,  5,1,  6,-1,  7,-3*k1 - 2*k2 + 2*k3 - k4 ] );
  SetConjugate( FTL, 4, 2, [4,-1,  5,0,  6,0,  7,3*k1 + 2*k2 - 2*k3 + 2*k4 ] );
  SetConjugate( FTL, 5, 2, [4,0,  5,1,  6,0,  7,0 ] );
  SetConjugate( FTL, 6, 2, [4,0,  5,0,  6,-1,  7,-k1 - 2*k2 ] );
  SetConjugate( FTL, 7, 2, [4,0,  5,0,  6,0,  7,1 ] );
  SetRelativeOrder( FTL, 3, 2 );
  SetPower( FTL, 3, [4,0,  5,0,  6,1,  7,k2 ] );
  SetConjugate( FTL, 4, 3, [4,-1,  5,0,  6,0,  7,k1 ] );
  SetConjugate( FTL, 5, 3, [4,0,  5,-1,  6,0,  7,0 ] );
  SetConjugate( FTL, 6, 3, [4,0,  5,0,  6,1,  7,2*k2 ] );
  SetConjugate( FTL, 7, 3, [4,0,  5,0,  6,0,  7,-1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0,  7,0 ] );
  SetConjugate( FTL, 6, 4, [6,1,  7,2*k1 ] );
  SetConjugate( FTL, 6, 5, [6,1,  7,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr075 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 4 );
  SetPower( FTL, 1, [2,0,  3,0,  4,0,  5,k4 ] );
  SetConjugate( FTL, 2, 1, [2,0,  3,-1,  4,0,  5,k3 ] );
  SetConjugate( FTL, 3, 1, [2,1,  3,0,  4,0,  5,-k2 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,1,  5,0 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,k1 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,0 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr076 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 4 );
  SetPower( FTL, 1, [2,0,  3,0,  4,1,  5,k4 ] );
  SetConjugate( FTL, 2, 1, [2,0,  3,-1,  4,0,  5,k3 ] );
  SetConjugate( FTL, 3, 1, [2,1,  3,0,  4,0,  5,-k2 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,1,  5,0 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,k1 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,0 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr077 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 4 );
  SetPower( FTL, 1, [2,0,  3,0,  4,2,  5,k4 ] );
  SetConjugate( FTL, 2, 1, [2,0,  3,-1,  4,0,  5,k3 ] );
  SetConjugate( FTL, 3, 1, [2,1,  3,0,  4,0,  5,-k2 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,1,  5,0 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,k1 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,0 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr079 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 4 );
  SetPower( FTL, 1, [2,0,  3,0,  4,0,  5,k4 ] );
  SetConjugate( FTL, 2, 1, [2,1,  3,1,  4,1,  5,-k3 ] );
  SetConjugate( FTL, 3, 1, [2,0,  3,0,  4,-1,  5,k3 ] );
  SetConjugate( FTL, 4, 1, [2,-1,  3,0,  4,0,  5,k2 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,0 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,k1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,-k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr080 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 4 );
  SetPower( FTL, 1, [2,1,  3,1,  4,0,  5,k4 ] );
  SetConjugate( FTL, 2, 1, [2,1,  3,1,  4,1,  5,-k3 ] );
  SetConjugate( FTL, 3, 1, [2,0,  3,0,  4,-1,  5,k3 ] );
  SetConjugate( FTL, 4, 1, [2,-1,  3,0,  4,0,  5,k2 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,0 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,k1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,-k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr081 := function (k1, k2, k3 , k4, k5) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 4 );
  SetPower( FTL, 1, [2,0,  3,0,  4,0,  5,k5 ] );
  SetConjugate( FTL, 2, 1, [2,0,  3,1,  4,0,  5,-k3 ] );
  SetConjugate( FTL, 3, 1, [2,-1,  3,0,  4,0,  5,k2 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,-1,  5,k4 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,k1 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,0 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr082 := function (k1, k2, k3 , k4, k5) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 4 );
  SetPower( FTL, 1, [2,0,  3,0,  4,0,  5,k5 ] );
  SetConjugate( FTL, 2, 1, [2,-1,  3,-1,  4,-1,  5,k2 + k3 + k4 ] );
  SetConjugate( FTL, 3, 1, [2,0,  3,0,  4,1,  5,-k4 ] );
  SetConjugate( FTL, 4, 1, [2,1,  3,0,  4,0,  5,-k2 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,0 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,k1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,-k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr083 := function (k1, k2, k3 , k4, k5, k6) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0,  6,k6 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,0,  5,0,  6,0 ] );
  SetConjugate( FTL, 3, 1, [3,-1,  4,0,  5,0,  6,k2 + k3 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,-k2 + k3 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1,  6,k5 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,1 ] );
  SetRelativeOrder( FTL, 2, 4 );
  SetPower( FTL, 2, [3,0,  4,0,  5,0,  6,k4 ] );
  SetConjugate( FTL, 3, 2, [3,0,  4,-1,  5,0,  6,k3 ] );
  SetConjugate( FTL, 4, 2, [3,1,  4,0,  5,0,  6,-k2 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,0 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,k1 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr084 := function (k1, k2, k3 , k4, k5, k6) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0,  6,k5 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,0,  5,-1,  6,-k6 ] );
  SetConjugate( FTL, 3, 1, [3,-1,  4,0,  5,0,  6,k2 + k3 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,-k2 + k3 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1,  6,-2*k6 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,1 ] );
  SetRelativeOrder( FTL, 2, 4 );
  SetPower( FTL, 2, [3,0,  4,0,  5,2,  6,k4 ] );
  SetConjugate( FTL, 3, 2, [3,0,  4,-1,  5,0,  6,k3 ] );
  SetConjugate( FTL, 4, 2, [3,1,  4,0,  5,0,  6,-k2 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,0 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,k1 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr085 := function (k1, k2, k3 , k4, k5, k6) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0,  6,k5 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,-1,  4,0,  5,0,  6,k2 - k6 ] );
  SetConjugate( FTL, 3, 1, [3,-1,  4,0,  5,0,  6,2*(k2 - k6) ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,-2*k6 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1,  6,k4 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,1 ] );
  SetRelativeOrder( FTL, 2, 4 );
  SetPower( FTL, 2, [3,0,  4,0,  5,0,  6,k3 ] );
  SetConjugate( FTL, 3, 2, [3,0,  4,-1,  5,0,  6,-k1 + k2 - 2*k6 ] );
  SetConjugate( FTL, 4, 2, [3,1,  4,0,  5,0,  6,-k2 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,0 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,2*k1 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr086 := function (k1, k2, k3 , k4, k5, k6) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0,  6,k5 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,-1,  4,0,  5,-1,  6,k2 - k6 ] );
  SetConjugate( FTL, 3, 1, [3,-1,  4,0,  5,0,  6,k1 + k2 + k3 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,k1 - k2 + k3 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1,  6,-k1 + k2 - k3 - 2*k6 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,1 ] );
  SetRelativeOrder( FTL, 2, 4 );
  SetPower( FTL, 2, [3,0,  4,0,  5,2,  6,k4 ] );
  SetConjugate( FTL, 3, 2, [3,0,  4,-1,  5,0,  6,k3 ] );
  SetConjugate( FTL, 4, 2, [3,1,  4,0,  5,0,  6,-k2 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,0 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,2*k1 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr087 := function (k1, k2, k3 , k4, k5, k6) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0,  6,k6 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,0,  5,0,  6,0 ] );
  SetConjugate( FTL, 3, 1, [3,-1,  4,0,  5,0,  6,k5 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,-2*k2 + 2*k3 + k5 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1,  6,2*k2 - k5 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,1 ] );
  SetRelativeOrder( FTL, 2, 4 );
  SetPower( FTL, 2, [3,0,  4,0,  5,0,  6,k4 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,1,  5,1,  6,-k3 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,0,  5,-1,  6,k3 ] );
  SetConjugate( FTL, 5, 2, [3,-1,  4,0,  5,0,  6,k2 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,k1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,-k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr088 := function (k1, k2, k3 , k4, k5, k6) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0,  6,k5 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,1,  4,0,  5,0,  6,-k2 - k6 ] );
  SetConjugate( FTL, 3, 1, [3,-1,  4,0,  5,0,  6,2*(k2 + k6) ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,-k1 + 2*k3 + 2*k6 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1,  6,-2*k6 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,1 ] );
  SetRelativeOrder( FTL, 2, 4 );
  SetPower( FTL, 2, [3,-1,  4,-1,  5,0,  6,k4 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,1,  5,1,  6,-k3 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,0,  5,-1,  6,k3 ] );
  SetConjugate( FTL, 5, 2, [3,-1,  4,0,  5,0,  6,k2 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,k1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,-k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr103 := function (k1, k2, k3 , k4, k5) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,1,  6,k5 ] );
  SetConjugate( FTL, 2, 1, [2, 3 ,  3,0,  4,0,  5,0,  6,-k4 ] );
  SetConjugate( FTL, 3, 1, [3,1,  4,0,  5,0,  6,-k2 - k3 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,1,  6,2*k5 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,-1 ] );
  SetRelativeOrder( FTL, 2, 4 );
  SetPower( FTL, 2, [3,0,  4,0,  5,0,  6,k4 ] );
  SetConjugate( FTL, 3, 2, [3,0,  4,-1,  5,0,  6,k3 ] );
  SetConjugate( FTL, 4, 2, [3,1,  4,0,  5,0,  6,-k2 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,0 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,k1 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr104 := function (k1, k2, k3 , k4, k5) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,1,  4,0,  5,1,  6,k4 ] );
  SetConjugate( FTL, 2, 1, [2, 3 ,  3,1,  4,0,  5,0,  6,-k2 - 2*k3 - k5 ] );
  SetConjugate( FTL, 3, 1, [3,1,  4,0,  5,0,  6,-2*(k2 + k3 + k5) ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,-k1 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,1,  6,2*(k2 + k3 + k4 + k5) ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,-1 ] );
  SetRelativeOrder( FTL, 2, 4 );
  SetPower( FTL, 2, [3,0,  4,0,  5,0,  6,k3 ] );
  SetConjugate( FTL, 3, 2, [3,0,  4,-1,  5,0,  6,-k1 + k2 + 2*k3 + 2*k5 ] );
  SetConjugate( FTL, 4, 2, [3,1,  4,0,  5,0,  6,-k2 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,0 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,2*k1 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr106 := function (k1, k2, k3 , k4, k5) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,1,  4,0,  5,0,  6,k5 ] );
  SetConjugate( FTL, 2, 1, [2, 3 ,  3,1,  4,0,  5,-1,  6,-k3 - k4 + k5 ] );
  SetConjugate( FTL, 3, 1, [3,1,  4,0,  5,0,  6,2*k5 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,-k1 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,1,  6,-2*k4 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,-1 ] );
  SetRelativeOrder( FTL, 2, 4 );
  SetPower( FTL, 2, [3,0,  4,0,  5,2,  6,k3 ] );
  SetConjugate( FTL, 3, 2, [3,0,  4,-1,  5,0,  6,-k1 - k2 - 2*k5 ] );
  SetConjugate( FTL, 4, 2, [3,1,  4,0,  5,0,  6,-k2 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,0 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,2*k1 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr110 := function (k1, k2, k3 , k4, k5) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,1,  4,1,  5,0,  6,k1 - k2 - k4 ] );
  SetConjugate( FTL, 2, 1, [2, 3 ,  3,1,  4,1,  5,1,  6,-2*k1 + 2*k2 - 2*k3 + 2*k4 - k5 ] );
  SetConjugate( FTL, 3, 1, [3,0,  4,0,  5,-1,  6,-k4 ] );
  SetConjugate( FTL, 4, 1, [3,1,  4,1,  5,1,  6,2*k1 - 2*k2 - k4 ] );
  SetConjugate( FTL, 5, 1, [3,-1,  4,0,  5,0,  6,k4 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,-1 ] );
  SetRelativeOrder( FTL, 2, 4 );
  SetPower( FTL, 2, [3,-1,  4,-1,  5,0,  6,k3 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,1,  5,1,  6,-k2 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,0,  5,-1,  6,k2 ] );
  SetConjugate( FTL, 5, 2, [3,-1,  4,0,  5,0,  6,4*k1 - 4*k2 + 2*k3 - 3*k4 + 2*k5 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,0 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,2*k1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,-2*k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr114 := function (k1, k2, k3 , k4, k5) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,1,  5,0,  6,k4 ] );
  SetConjugate( FTL, 2, 1, [2, 3 ,  3,0,  4,1,  5,1,  6,-k1 + k2 - 2*k3 + 2*k4 - k5 ] );
  SetConjugate( FTL, 3, 1, [3,-1,  4,0,  5,0,  6,k1 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,1,  5,0,  6,2*k4 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1,  6,0 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,-1 ] );
  SetRelativeOrder( FTL, 2, 4 );
  SetPower( FTL, 2, [3,0,  4,0,  5,0,  6,k3 ] );
  SetConjugate( FTL, 3, 2, [3,0,  4,1,  5,0,  6,-k1 + k2 + 2*k4 ] );
  SetConjugate( FTL, 4, 2, [3,-1,  4,0,  5,0,  6,k2 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,-1,  6,2*(k1 - k2 + k3 - k4 + k5) ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,2*k1 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr143 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 3 );
  SetPower( FTL, 1, [2,0,  3,0,  4,0,  5,k4 ] );
  SetConjugate( FTL, 2, 1, [2,-1,  3,-1,  4,0,  5,k2 + k3 ] );
  SetConjugate( FTL, 3, 1, [2,1,  3,0,  4,0,  5,-k2 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,1,  5,0 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,k1 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,0 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr144 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 3 );
  SetPower( FTL, 1, [2,0,  3,0,  4,1,  5,k4 ] );
  SetConjugate( FTL, 2, 1, [2,-1,  3,-1,  4,0,  5,k2 + k3 ] );
  SetConjugate( FTL, 3, 1, [2,1,  3,0,  4,0,  5,-k2 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,1,  5,0 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,k1 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,0 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr146 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 3 );
  SetPower( FTL, 1, [2,0,  3,0,  4,0,  5,k4 ] );
  SetConjugate( FTL, 2, 1, [2,0,  3,0,  4,1,  5,k2 + k3 ] );
  SetConjugate( FTL, 3, 1, [2,1,  3,0,  4,0,  5,-k2 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,1,  4,0,  5,-k3 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,k1 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,-k1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr147 := function (k1, k2, k3 , k4, k5) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 6 );
  SetPower( FTL, 1, [2,0,  3,0,  4,0,  5,k5 ] );
  SetConjugate( FTL, 2, 1, [2,1,  3,1,  4,0,  5,k1 - k2 - k3 ] );
  SetConjugate( FTL, 3, 1, [2,-1,  3,0,  4,0,  5,k2 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,-1,  5,k4 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,k1 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,0 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr148 := function (k1, k2, k3 , k4, k5) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 6 );
  SetPower( FTL, 1, [2,0,  3,0,  4,0,  5,k5 ] );
  SetConjugate( FTL, 2, 1, [2,0,  3,0,  4,-1,  5,k4 ] );
  SetConjugate( FTL, 3, 1, [2,-1,  3,0,  4,0,  5,k2 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,-1,  4,0,  5,k3 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,k1 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,-k1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr158 := function (k1, k2, k3 , k4, k5) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,1,  6,k5 ] );
  SetConjugate( FTL, 2, 1, [2, 2 ,  3,0,  4,0,  5,0,  6,-k4 ] );
  SetConjugate( FTL, 3, 1, [3,0,  4,-1,  5,0,  6,-k2 ] );
  SetConjugate( FTL, 4, 1, [3,-1,  4,0,  5,0,  6,k2 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,1,  6,2*k5 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,-1 ] );
  SetRelativeOrder( FTL, 2, 3 );
  SetPower( FTL, 2, [3,0,  4,0,  5,0,  6,k4 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,-1,  5,0,  6,k2 + k3 ] );
  SetConjugate( FTL, 4, 2, [3,1,  4,0,  5,0,  6,-k2 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,0 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,k1 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr159 := function (k1, k2, k3 , k4, k5) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,1,  6,k5 ] );
  SetConjugate( FTL, 2, 1, [2, 2 ,  3,0,  4,0,  5,0,  6,-k3 ] );
  SetConjugate( FTL, 3, 1, [3,0,  4,1,  5,0,  6,-k4 ] );
  SetConjugate( FTL, 4, 1, [3,1,  4,0,  5,0,  6,-k4 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,1,  6,2*k5 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,-1 ] );
  SetRelativeOrder( FTL, 2, 3 );
  SetPower( FTL, 2, [3,0,  4,0,  5,0,  6,k3 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,-1,  5,0,  6,k1 - k2 + 3*k4 ] );
  SetConjugate( FTL, 4, 2, [3,1,  4,0,  5,0,  6,-k1 + 2*k2 - 3*k4 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,0 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,k1 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr161 := function (k1, k2, k3 , k4, k5) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,1,  6,k5 ] );
  SetConjugate( FTL, 2, 1, [2, 2 ,  3,-1,  4,0,  5,0,  6,-k3 - k4 + 2*k5 ] );
  SetConjugate( FTL, 3, 1, [3,0,  4,1,  5,0,  6,-k1 - k2 - 2*k3 + 2*k5 ] );
  SetConjugate( FTL, 4, 1, [3,1,  4,0,  5,0,  6,-k2 - 2*k3 + 2*k5 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,1,  6,2*k5 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,-1 ] );
  SetRelativeOrder( FTL, 2, 3 );
  SetPower( FTL, 2, [3,1,  4,1,  5,1,  6,k4 ] );
  SetConjugate( FTL, 3, 2, [3,0,  4,0,  5,1,  6,k2 + k3 ] );
  SetConjugate( FTL, 4, 2, [3,1,  4,0,  5,0,  6,-k2 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,1,  5,0,  6,-k3 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,k1 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,-k1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr168 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 6 );
  SetPower( FTL, 1, [2,0,  3,0,  4,0,  5,k4 ] );
  SetConjugate( FTL, 2, 1, [2,1,  3,1,  4,0,  5,k1 - k2 - k3 ] );
  SetConjugate( FTL, 3, 1, [2,-1,  3,0,  4,0,  5,k2 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,1,  5,0 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,k1 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,0 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr169 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 6 );
  SetPower( FTL, 1, [2,0,  3,0,  4,5,  5,k4 ] );
  SetConjugate( FTL, 2, 1, [2,1,  3,1,  4,0,  5,k1 - k2 - k3 ] );
  SetConjugate( FTL, 3, 1, [2,-1,  3,0,  4,0,  5,k2 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,1,  5,0 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,k1 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,0 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr172 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 6 );
  SetPower( FTL, 1, [2,0,  3,0,  4,2,  5,k4 ] );
  SetConjugate( FTL, 2, 1, [2,1,  3,1,  4,0,  5,k1 - k2 - k3 ] );
  SetConjugate( FTL, 3, 1, [2,-1,  3,0,  4,0,  5,k2 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,1,  5,0 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,k1 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,0 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr173 := function (k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 6 );
  SetPower( FTL, 1, [2,0,  3,0,  4,3,  5,k4 ] );
  SetConjugate( FTL, 2, 1, [2,1,  3,1,  4,0,  5,k1 - k2 - k3 ] );
  SetConjugate( FTL, 3, 1, [2,-1,  3,0,  4,0,  5,k2 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,1,  5,0 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,k1 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,0 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr174 := function (k1, k2, k3 , k4, k5) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 6 );
  SetPower( FTL, 1, [2,0,  3,0,  4,0,  5,k5 ] );
  SetConjugate( FTL, 2, 1, [2,-1,  3,-1,  4,0,  5,k2 + k3 ] );
  SetConjugate( FTL, 3, 1, [2,1,  3,0,  4,0,  5,-k2 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,-1,  5,k4 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,0,  5,k1 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,0 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr175 := function (k1, k2, k3 , k4, k5, k6) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0,  6,k6 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,0,  5,0,  6,0 ] );
  SetConjugate( FTL, 3, 1, [3,-1,  4,0,  5,0,  6,k1 - 2*k3 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,-k1 + 2*k2 + 2*k3 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1,  6,k5 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,1 ] );
  SetRelativeOrder( FTL, 2, 6 );
  SetPower( FTL, 2, [3,0,  4,0,  5,0,  6,k4 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,1,  5,0,  6,k1 - k2 - k3 ] );
  SetConjugate( FTL, 4, 2, [3,-1,  4,0,  5,0,  6,k2 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,0 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,k1 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr176 := function (k1, k2, k3 , k4, k5, k6) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0,  6,k5 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,0,  5,-1,  6,k6 ] );
  SetConjugate( FTL, 3, 1, [3,-1,  4,0,  5,0,  6,k1 - 2*k3 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,-k1 + 2*k2 + 2*k3 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1,  6,2*k6 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,1 ] );
  SetRelativeOrder( FTL, 2, 6 );
  SetPower( FTL, 2, [3,0,  4,0,  5,3,  6,k4 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,1,  5,0,  6,k1 - k2 - k3 ] );
  SetConjugate( FTL, 4, 2, [3,-1,  4,0,  5,0,  6,k2 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,0 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,k1 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4Nr184 := function (k1, k2, k3 , k4, k5) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,1,  6,k5 ] );
  SetConjugate( FTL, 2, 1, [2, 5 ,  3,0,  4,0,  5,0,  6,-k4 ] );
  SetConjugate( FTL, 3, 1, [3,0,  4,-1,  5,0,  6,-k1 + k2 + 2*k3 ] );
  SetConjugate( FTL, 4, 1, [3,-1,  4,0,  5,0,  6,k1 - k2 - 2*k3 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,1,  6,2*k5 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,-1 ] );
  SetRelativeOrder( FTL, 2, 6 );
  SetPower( FTL, 2, [3,0,  4,0,  5,0,  6,k4 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,1,  5,0,  6,k1 - k2 - k3 ] );
  SetConjugate( FTL, 4, 2, [3,-1,  4,0,  5,0,  6,k2 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,0 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0,  6,k1 ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;
ACPcpGroupDim4NrB1 := function (k , k1, k2 , k3) 
local FTL;
  FTL := FromTheLeftCollector( 4 );
  SetConjugate( FTL, 2, 1, [2,1, 3, k, 4, k1 ] );
  SetConjugate( FTL, 3, 1, [3,1, 4, k2 ] );
  SetConjugate( FTL, 3, 2, [3,1, 4, k3 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4NrB2 := function (k, k1, k2, k3) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [2,0,  3,0,  4,1,  5,k3 ] );
  SetConjugate( FTL, 2, 1, [2,-1,  3,0,  4,0,  5,k1 ] );
  SetConjugate( FTL, 3, 1, [2,0,  3,-1,  4,0,  5,k2 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,1,  5,2*k3 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,-1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,2*k,  5,2*(k*k1 + k*k2 + k*k3) ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,2*k1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,2*k2 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4NrB3c := function (l, k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [2,0,  3,0,  4,0,  5,k4 ] );
  SetConjugate( FTL, 2, 1, [2,1,  3,0,  4,0,  5,0 ] );
  SetConjugate( FTL, 3, 1, [2,0,  3,-1,  4,0,  5,k2 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,-1,  5,k3 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,2*l,  5,(k1 - k3)*l ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,0 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4NrB3b := function (l, k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [2,0,  3,0,  4,0,  5,k4 ] );
  SetConjugate( FTL, 2, 1, [2,1,  3,0,  4,-1,  5,-k2 ] );
  SetConjugate( FTL, 3, 1, [2,0,  3,-1,  4,0,  5,k3 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,-1,  5,-2*k2 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,2*l,  5,-k1 + 2*k1*l + 2*k2*l ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,0 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,2*k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4NrB3 := function (l, k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [2,0,  3,0,  4,0,  5,k4 ] );
  SetConjugate( FTL, 2, 1, [2,1,  3,0,  4,-1,  5,-k2 ] );
  SetConjugate( FTL, 3, 1, [2,0,  3,-1,  4,0,  5,k3 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,-1,  5,-2*k2 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,1 + 2*l,  5,k2 + k1*l + 2*k2*l ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,0 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4NrB4 := function (k, k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [2,1,  3,0,  4,0,  5,k4 ] );
  SetConjugate( FTL, 2, 1, [2,1,  3,0,  4,0,  5,0 ] );
  SetConjugate( FTL, 3, 1, [2,0,  3,-1,  4,-k,  5,k*k1 + k2 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,-1,  5,k3 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,2*k,  5,k*(k1 - k3) ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,0 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4NrB4b := function (k, k1, k2, k3) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [2,1,  3,0,  4,0,  5,k3 ] );
  SetConjugate( FTL, 2, 1, [2,1,  3,0,  4,0,  5,2*k3 ] );
  SetConjugate( FTL, 3, 1, [2,0,  3,-1,  4,-k,  5,k2 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,-1,  5,k1 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,-1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,2*k,  5,-(k*k1) - 2*k2 ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,-2*k1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,0 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4NrB5  := function (l, k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [2,0,  3,0,  4,0,  5,k4 ] );
  SetConjugate( FTL, 2, 1, [2,0,  3,1,  4,0,  5,k2 ] );
  SetConjugate( FTL, 3, 1, [2,1,  3,0,  4,0,  5,-k2 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,-1,  5,k3 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,2*l,  5,-(k3*l) ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,k1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,-k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4NrB5b := function (l, k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 5 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [2,0,  3,0,  4,0,  5,k4 ] );
  SetConjugate( FTL, 2, 1, [2,0,  3,1,  4,0,  5,k2 ] );
  SetConjugate( FTL, 3, 1, [2,1,  3,0,  4,0,  5,-k2 ] );
  SetConjugate( FTL, 4, 1, [2,0,  3,0,  4,-1,  5,2*k3 ] );
  SetConjugate( FTL, 5, 1, [2,0,  3,0,  4,0,  5,1 ] );
  SetConjugate( FTL, 3, 2, [3,1,  4,1 + 2*l,  5,-(k3*(1 + 2*l)) ] );
  SetConjugate( FTL, 4, 2, [4,1,  5,k1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,-k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4NrB7 := function (l, k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0,  6,k3 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,-1,  5,-1,  6,2*k1 - 2*k2 + 2*k3 - k4 ] );
  SetConjugate( FTL, 3, 1, [3,1,  4,0,  5,2*l,  6,-((k1 - 2*k2)*l) ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,k1 - 2*k2 + 2*k3 - 2*k4 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1,  6,k1 - 2*k2 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,1,  6,k2 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,0,  6,0 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,-1,  5,0,  6,k1 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,2*k2 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,-1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,4*l,  6,4*(k1*l + k2*l) ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,2*k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4NrB7b := function (l, k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,0,  4,0,  5,0,  6,k3 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,0,  4,-1,  5,-1,  6,4*k1 - 2*k2 + 2*k3 - k4 ] );
  SetConjugate( FTL, 3, 1, [3,1,  4,0,  5,1 + 2*l,  6,-k1 + k2 - 2*k1*l + 2*k2*l ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,0,  6,2*(k1 - k2 + k3 - k4) ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1,  6,2*(k1 - k2) ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,1,  6,k2 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,0,  6,0 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,-1,  5,0,  6,2*k1 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,2*k2 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,-1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,2*(1 + 2*l),  6,2*(2*k1 + k2 + 4*k1*l + 2*k2*l) ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,4*k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4NrB8  := function (k, k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,1,  4,0,  5,0,  6,k3 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,1,  4,-1,  5,-1 - 4*k,  6,2*k1 + 8*k*k1 - 2*k2 - 6*k*k2 + 2*k3 - k4 ] );
  SetConjugate( FTL, 3, 1, [3,1,  4,0,  5,0,  6,0 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,-2*k,  6,k1 + 6*k*k1 - 2*k2 - 6*k*k2 + 2*k3 - 2*k4 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1,  6,k1 - 2*k2 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,1,  6,k2 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,2*k,  6,2*k*k2 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,-1,  5,-2*k,  6,k1 + 2*k*k1 - 2*k*k2 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,2*k2 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,-1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,4*k,  6,2*(k*k1 + 2*k*k2) ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,0 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,2*k1 ] );
return PcpGroupByCollector(FTL);
end;
 
ACPcpGroupDim4NrB8b := function (k, k1, k2, k3 , k4) 
local FTL;
  FTL := FromTheLeftCollector( 6 );
  SetRelativeOrder( FTL, 1, 2 );
  SetPower( FTL, 1, [3,1,  4,0,  5,0,  6,k3 ] );
  SetConjugate( FTL, 2, 1, [2, 1 ,  3,1,  4,-1,  5,-1 - 4*k,  6,k1 + 2*k*k1 - 2*k*k2 + 2*k3 + k4 ] );
  SetConjugate( FTL, 3, 1, [3,1,  4,0,  5,0,  6,2*k3 ] );
  SetConjugate( FTL, 4, 1, [3,0,  4,-1,  5,-2*k,  6,-2*k*k2 ] );
  SetConjugate( FTL, 5, 1, [3,0,  4,0,  5,-1,  6,k1 ] );
  SetConjugate( FTL, 6, 1, [3,0,  4,0,  5,0,  6,-1 ] );
  SetRelativeOrder( FTL, 2, 2 );
  SetPower( FTL, 2, [3,0,  4,0,  5,1,  6,k2 ] );
  SetConjugate( FTL, 3, 2, [3,-1,  4,0,  5,2*k,  6,-k1 + 2*k*k1 + 2*k*k2 ] );
  SetConjugate( FTL, 4, 2, [3,0,  4,-1,  5,-2*k,  6,-2*k*k2 ] );
  SetConjugate( FTL, 5, 2, [3,0,  4,0,  5,1,  6,2*k2 ] );
  SetConjugate( FTL, 6, 2, [3,0,  4,0,  5,0,  6,-1 ] );
  SetConjugate( FTL, 4, 3, [4,1,  5,4*k,  6,-2*(k*k1 - 2*k*k2) ] );
  SetConjugate( FTL, 5, 3, [5,1,  6,-2*k1 ] );
  SetConjugate( FTL, 5, 4, [5,1,  6,0 ] );
return PcpGroupByCollector(FTL);
end;

#############################################################################
##
## some small helpers
##
ACPcpDim4Funcs := [ ACPcpGroupDim4Nr001, ACPcpGroupDim4Nr002,
ACPcpGroupDim4Nr003,
ACPcpGroupDim4Nr004, ACPcpGroupDim4Nr004b, ACPcpGroupDim4Nr005,
ACPcpGroupDim4Nr006, ACPcpGroupDim4Nr007, ACPcpGroupDim4Nr007b,
ACPcpGroupDim4Nr008, ACPcpGroupDim4Nr009, ACPcpGroupDim4Nr009b,
ACPcpGroupDim4Nr010, ACPcpGroupDim4Nr011, ACPcpGroupDim4Nr012,
ACPcpGroupDim4Nr013, ACPcpGroupDim4Nr014, ACPcpGroupDim4Nr014b,
ACPcpGroupDim4Nr015, ACPcpGroupDim4Nr018, ACPcpGroupDim4Nr019,
ACPcpGroupDim4Nr019b, ACPcpGroupDim4Nr019c, ACPcpGroupDim4Nr026,
ACPcpGroupDim4Nr027, ACPcpGroupDim4Nr029, ACPcpGroupDim4Nr029b,
ACPcpGroupDim4Nr029c, ACPcpGroupDim4Nr030, ACPcpGroupDim4Nr031,
ACPcpGroupDim4Nr032, ACPcpGroupDim4Nr033, ACPcpGroupDim4Nr033b,
ACPcpGroupDim4Nr033c, ACPcpGroupDim4Nr034, ACPcpGroupDim4Nr036,
ACPcpGroupDim4Nr037, ACPcpGroupDim4Nr041, ACPcpGroupDim4Nr043,
ACPcpGroupDim4Nr045, ACPcpGroupDim4Nr055, ACPcpGroupDim4Nr056,
ACPcpGroupDim4Nr058, ACPcpGroupDim4Nr060, ACPcpGroupDim4Nr061,
ACPcpGroupDim4Nr061b, ACPcpGroupDim4Nr061c, ACPcpGroupDim4Nr062,
ACPcpGroupDim4Nr075, ACPcpGroupDim4Nr076, ACPcpGroupDim4Nr077,
ACPcpGroupDim4Nr079, ACPcpGroupDim4Nr080, ACPcpGroupDim4Nr081,
ACPcpGroupDim4Nr082, ACPcpGroupDim4Nr083, ACPcpGroupDim4Nr084,
ACPcpGroupDim4Nr085, ACPcpGroupDim4Nr086, ACPcpGroupDim4Nr087,
ACPcpGroupDim4Nr088, ACPcpGroupDim4Nr103, ACPcpGroupDim4Nr104,
ACPcpGroupDim4Nr106, ACPcpGroupDim4Nr110, ACPcpGroupDim4Nr114,
ACPcpGroupDim4Nr143, ACPcpGroupDim4Nr144, ACPcpGroupDim4Nr146,
ACPcpGroupDim4Nr147, ACPcpGroupDim4Nr148, ACPcpGroupDim4Nr158,
ACPcpGroupDim4Nr159, ACPcpGroupDim4Nr161, ACPcpGroupDim4Nr168,
ACPcpGroupDim4Nr169, ACPcpGroupDim4Nr172, ACPcpGroupDim4Nr173,
ACPcpGroupDim4Nr174, ACPcpGroupDim4Nr175, ACPcpGroupDim4Nr176,
ACPcpGroupDim4Nr184, ACPcpGroupDim4NrB1, ACPcpGroupDim4NrB2,
ACPcpGroupDim4NrB3c, ACPcpGroupDim4NrB3b, ACPcpGroupDim4NrB3,
ACPcpGroupDim4NrB4, ACPcpGroupDim4NrB4b, ACPcpGroupDim4NrB5,
ACPcpGroupDim4NrB5b, ACPcpGroupDim4NrB7, ACPcpGroupDim4NrB7b,
ACPcpGroupDim4NrB8, ACPcpGroupDim4NrB8b ];
MakeReadOnlyGlobal( "ACPcpDim4Funcs" );

