#############################################################################
##
#A  codes4.g 		        GUAVA library                   Reinald Baart
#A                                                       & Jasper Cramwinckel
#A                                                          & Erik Roijackers
##
#H  @(#)$Id: codes4.g,v 1.3 2004/12/20 21:26:08 gap Exp $
##
#Y  Copyright (C)  1994,  Vakgroep Algemene Wiskunde,  T.U. Delft,  Nederland
##
#H  $Log: codes4.g,v $
#H  Revision 1.3  2004/12/20 21:26:08  gap
#H  Added release 2 by David Joyner. AH
#H
#H  Revision 1.1.1.1  1998/03/19 17:31:41  lea
#H  Initial version of GUAVA for GAP4.  Development still under way. 
#H  Lea Ruscio 19/3/98
#H
#H
#H  Revision 1.2  1997/01/20 15:34:25  werner
#H  Upgrade from Guava 1.2 to Guava 1.3 for GAP release 3.4.4.
#H
#H  Revision 1.1  1994/11/10  14:29:23  rbaart
#H  Initial revision
#H
##
YouWantThisCode := function(n, k, d, ref)
    if IsList( GUAVA_TEMP_VAR ) and GUAVA_TEMP_VAR[1] = false then
        Add( GUAVA_TEMP_VAR, [n, k, d, ref] );
    fi;
    return [n, k] = GUAVA_TEMP_VAR;
end;


if YouWantThisCode(  6,  3,  4, "GH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 12,  6,  6, "Q1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 17,  4, 12, "GH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 17, 13,  4, "c" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 18,  6, 10, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 18,  9,  8, "MO" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 20, 10,  8, "Q1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 20, 13,  6, "Slo" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 21,  3, 16, "La" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 21, 12,  7, "Ki" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 21, 15,  5, "Ki" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 21, 18,  3, "HM" ) then
    GUAVA_TEMP_VAR := [HammingCode, [3, 4 ]];
fi;
if YouWantThisCode( 24,  5, 16, "Liz" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 24,  7, 13, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 26,  6, 16, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 26, 18,  6, "Slo" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 27,  8, 14, "Slo" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 27,  9, 13, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 28,  4, 20, "GH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 28,  6, 17, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 28,  7, 16, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 30,  5, 20, "Ki" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 30,  9, 15, "Slo" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 30, 15, 12, "Q1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 31,  4, 22, "GH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 32,  6, 20, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 32,  7, 19, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 32,  8, 17, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 33, 17, 10, "Ki" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 35,  6, 22, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 35, 11, 16, "Ki" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 35, 23,  8, "c" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 36,  8, 20, "Slo" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 36,  9, 19, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 38, 19, 12, "Q1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 39,  7, 24, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 39, 12, 18, "Ki" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 39, 21, 11, "Ki" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 39, 24,  9, "Ki" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 40,  5, 28, "Ki" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 40,  9, 21, "Slo" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 41, 11, 20, "Ki" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 41, 30,  7, "Ki" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 41, 36,  4, "IN" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 42,  6, 28, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 43,  7, 27, "Ki" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 43,  8, 26, "Ki" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 43, 14, 18, "Ki" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 43, 29,  8, "Ki" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 43, 36,  5, "Ki" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 44,  4, 32, "GH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 44, 10, 23, "Slo" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 44, 11, 21, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 44, 22, 14, "Q1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 45,  5, 31, "Ki" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 45,  7, 28, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 45,  9, 24, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 45, 12, 20, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 48,  6, 32, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 48,  7, 30, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 48,  8, 28, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 48, 11, 24, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 48, 13, 21, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 48, 14, 20, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 48, 16, 18, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 48, 19, 16, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 49,  4, 36, "GH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 50,  5, 35, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 50,  9, 28, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 50, 12, 24, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 50, 28, 12, "Slo" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 50, 42,  5, "Slo" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 51, 21, 16, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 52,  5, 36, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 52,  6, 35, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 52,  7, 33, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 52, 13, 24, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 53, 11, 27, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 54,  6, 36, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 54, 27, 14, "Q1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 54, 39,  8, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 55,  4, 40, "GH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 55,  5, 38, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 55, 11, 28, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 56, 10, 30, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 56, 13, 27, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 56, 33, 12, "Slo" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 57,  9, 34, "Yi" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 60,  9, 36, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 60, 10, 33, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 60, 11, 32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 60, 13, 30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 60, 28, 16, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 64,  4, 48, "RM" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 64, 17, 28, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 64, 20, 27, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 64, 23, 24, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 64, 33, 15, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 64, 36, 14, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 64, 42, 11, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 64, 51,  7, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 64, 54,  6, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 65,  8, 44, "BC" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 65, 11, 36, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 65, 13, 33, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 65, 15, 31, "BC" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 65, 21, 25, "BC" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 65, 27, 23, "BC" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 65, 28, 18, "BC" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 65, 32, 16, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 65, 40, 12, "BC" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 65, 46, 10, "BC" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 66,  5, 47, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 66,  9, 40, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 66, 30, 17, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 66, 34, 15, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 66, 38, 13, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 68,  5, 48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 68, 12, 36, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 68, 15, 33, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 68, 17, 30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 68, 24, 24, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 68, 42, 12, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 68, 48,  9, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 69, 40, 13, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 69, 44, 11, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 70,  4, 52, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 70, 11, 40, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 70, 13, 36, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 70, 16, 32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 70, 19, 28, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 70, 30, 20, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 70, 32, 18, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 70, 36, 16, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 70, 39, 14, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 72,  7, 47, "Slo" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 72,  9, 44, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 72, 14, 36, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 72, 20, 28, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 72, 22, 26, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 72, 56,  8, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 75,  4, 56, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 75,  8, 48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 75, 11, 44, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 75, 13, 40, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 75, 16, 36, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 75, 19, 32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 75, 20, 30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 75, 22, 28, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 75, 28, 24, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 75, 30, 22, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 75, 34, 20, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 75, 36, 18, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 76, 25, 26, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 76, 38, 17, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 76, 44, 14, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 76, 46, 13, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 78,  6, 56, "Hi" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 78,  7, 52, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 79, 48, 13, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 80,  4, 60, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 80,  8, 52, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 80, 11, 48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 80, 13, 44, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 80, 15, 40, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 80, 19, 36, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 80, 22, 32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 80, 23, 30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 80, 26, 28, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 80, 28, 26, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 80, 32, 24, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 80, 34, 22, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 80, 38, 20, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 80, 40, 18, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 80, 45, 16, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 85,  4, 64, "La" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 85,  6, 60, "BC" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 85,  8, 56, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 85, 13, 48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 85, 15, 44, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 85, 17, 40, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 85, 18, 39, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 85, 22, 36, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 85, 23, 33, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 85, 24, 32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 85, 26, 31, "BC" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 85, 30, 28, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 85, 32, 26, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 85, 36, 24, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 85, 38, 22, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 85, 42, 20, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 85, 49, 16, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 85, 58, 12, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 85, 59, 11, "BC" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 85, 63, 10, "BC" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 85, 64,  9, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 85, 73,  6, "BC" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 85, 75,  5, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 85, 81,  3, "HM" ) then
    GUAVA_TEMP_VAR := [ HammingCode, [ 4, 4 ]];
fi;
if YouWantThisCode( 86, 11, 52, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 86, 27, 30, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 86, 45, 18, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 86, 53, 14, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 87, 25, 32, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 87, 76,  5, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 88, 17, 42, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 88, 19, 39, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 88, 24, 33, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 88, 28, 30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 90,  6, 64, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 90,  8, 58, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 90, 14, 48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 90, 15, 46, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 90, 32, 28, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 90, 34, 26, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 90, 38, 24, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 90, 40, 22, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 90, 45, 20, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 90, 47, 18, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 90, 55, 14, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 90, 73,  8, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 91,  7, 61, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 91, 11, 54, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 91, 13, 50, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 92, 17, 45, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 92, 19, 42, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 92, 21, 39, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 92, 24, 36, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 92, 28, 32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 92, 31, 30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 93,  8, 60, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 93, 15, 48, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 93, 22, 38, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 93, 26, 34, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 94, 11, 56, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 94, 13, 52, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 95,  5, 68, "Slo" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 96,  7, 64, "Slo" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 96,  8, 61, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 96, 12, 54, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 96, 14, 51, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 96, 17, 48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 96, 19, 45, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 96, 21, 42, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 96, 22, 40, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 96, 23, 39, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 96, 24, 38, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 96, 26, 36, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 96, 28, 34, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 96, 29, 33, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 96, 31, 32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 96, 33, 30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 96, 36, 28, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 96, 38, 26, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 96, 43, 24, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 96, 45, 22, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 96, 50, 20, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 96, 52, 18, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 96, 58, 16, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 96, 60, 14, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 99,  6, 69, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 99, 24, 40, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 99, 33, 32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 99, 35, 30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 99, 64, 13, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(100,  5, 72, "Slo" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(100,  8, 64, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(100, 11, 60, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(100, 12, 57, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(100, 13, 56, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(100, 14, 54, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(100, 15, 52, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(100, 19, 48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(100, 21, 45, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(100, 23, 42, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(100, 26, 39, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(100, 29, 36, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(100, 31, 34, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(100, 32, 33, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(101, 17, 51, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(102,  4, 76, "GH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(102, 20, 48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(102, 22, 44, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(102, 25, 40, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(102, 34, 32, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(102, 36, 30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(102, 41, 28, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(102, 43, 26, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(102, 48, 24, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(102, 50, 22, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(102, 55, 20, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(102, 63, 16, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(102, 73, 12, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(103, 58, 18, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(104,  7, 71, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(104, 24, 42, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(104, 26, 40, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(104, 28, 38, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(105,  6, 73, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(105,  8, 68, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(105, 13, 60, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(105, 15, 56, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(105, 21, 48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(105, 27, 39, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(105, 31, 36, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(105, 33, 34, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(105, 42, 28, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(105, 44, 26, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(106, 11, 64, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(106, 23, 45, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(106, 25, 42, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(107, 17, 54, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(107, 19, 51, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(108, 18, 52, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(108, 28, 40, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(108, 29, 39, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(108, 30, 38, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(108, 33, 36, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(108, 35, 34, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(108, 39, 32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(108, 51, 24, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(108, 90,  8, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(109,  5, 80, "AEB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(110,  6, 77, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(110,  7, 74, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(110,  8, 72, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(110, 10, 68, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(110, 13, 64, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(110, 15, 60, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(110, 17, 56, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(110, 20, 51, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(110, 23, 48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(110, 26, 44, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(110, 40, 32, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(110, 42, 30, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(110, 46, 28, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(111, 28, 42, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(111, 30, 40, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(111, 35, 36, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(111, 37, 34, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(112, 11, 68, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(112, 19, 54, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(112, 21, 51, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(112, 32, 39, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(114, 30, 42, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(114, 32, 40, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(114, 35, 38, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(115,  5, 84, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(115,  8, 76, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(115, 10, 72, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(115, 13, 68, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(115, 15, 64, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(115, 17, 60, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(115, 22, 52, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(115, 26, 48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(115, 29, 44, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(115, 38, 36, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(115, 40, 34, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(115, 44, 32, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(115, 46, 30, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(115, 50, 28, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(116, 19, 57, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(116, 21, 54, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(116, 23, 51, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(116, 31, 42, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(116, 33, 40, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(116, 34, 39, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(117,  7, 80, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(118,  4, 88, "GH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(120,  5, 88, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(120,  6, 86, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(120,  7, 81, "Slo" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(120,  8, 80, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(120, 10, 76, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(120, 13, 72, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(120, 15, 68, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(120, 17, 64, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(120, 19, 60, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(120, 21, 57, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(120, 22, 56, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(120, 23, 54, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(120, 24, 52, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(120, 25, 51, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(120, 29, 48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(120, 30, 45, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(120, 31, 44, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(120, 34, 42, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(120, 36, 40, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(120, 37, 39, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(120, 38, 38, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(120, 42, 36, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(120, 44, 34, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(120, 48, 32, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(120, 90, 12, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(123,  4, 92, "GH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(124, 23, 57, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(124, 25, 54, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(124, 33, 45, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(124, 34, 44, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(124, 36, 42, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(124, 93, 12, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(125,  5, 91, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(125,  6, 88, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(125,  8, 84, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(125, 10, 80, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(125, 15, 72, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(125, 17, 68, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(125, 19, 64, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(125, 22, 60, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(125, 24, 56, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(125, 27, 52, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(125, 28, 51, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(125, 31, 48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(125, 40, 40, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(125, 42, 38, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(125, 46, 36, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(125, 48, 34, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(125, 52, 32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(126, 13, 76, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(128, 18, 66, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(128, 21, 63, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(128, 23, 60, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(128, 25, 57, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(128, 27, 54, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(128, 29, 51, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(128, 30, 50, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(128, 33, 48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(128, 35, 45, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(128, 36, 44, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(128, 38, 42, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(128, 96, 12, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130,  6, 92, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130,  7, 89, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130, 10, 82, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130, 17, 70, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130, 42, 40, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130, 44, 38, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130, 46, 37, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130, 50, 35, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130, 52, 34, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130, 54, 33, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130, 56, 32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130, 58, 31, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130, 60, 30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130, 62, 29, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130, 64, 28, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130, 66, 27, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130, 68, 26, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130, 70, 25, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130, 72, 24, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130, 74, 23, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130, 76, 22, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130, 78, 21, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130, 80, 20, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130, 82, 19, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130, 84, 18, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130, 86, 17, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130, 88, 16, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(130, 90, 15, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(131, 13, 78, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(131, 15, 74, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132,  5, 96, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132,  6, 93, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132,  9, 84, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 10, 83, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 11, 80, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 12, 79, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 14, 75, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 16, 72, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 17, 71, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 18, 69, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 19, 67, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 21, 66, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 23, 63, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 25, 60, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 27, 57, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 29, 54, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 30, 52, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 32, 51, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 35, 48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 36, 46, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 38, 45, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 41, 42, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 43, 40, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 44, 39, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 45, 38, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 47, 37, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 50, 36, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 51, 35, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 53, 34, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 55, 33, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 57, 32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 59, 31, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 61, 30, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 63, 29, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 65, 28, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 67, 27, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 69, 26, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 71, 25, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 73, 24, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 75, 23, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 77, 22, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 79, 21, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 81, 20, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 83, 19, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 85, 18, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 87, 17, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 89, 16, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 91, 15, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 95, 14, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 96, 13, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132, 99, 12, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132,103, 11, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132,107, 10, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132,108,  9, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132,111,  8, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132,115,  7, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132,119,  6, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(132,120,  5, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;

Unbind(YouWantThisCode);
