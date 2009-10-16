#############################################################################
##
#A  codes3.g 		        GUAVA library                   Reinald Baart
#A                                                       & Jasper Cramwinckel
#A                                                          & Erik Roijackers
##
#H  @(#)$Id: codes3.g,v 1.3 2004/12/20 21:26:08 gap Exp $
##
#Y  Copyright (C)  1994,  Vakgroep Algemene Wiskunde,  T.U. Delft,  Nederland
##
#H  $Log: codes3.g,v $
#H  Revision 1.3  2004/12/20 21:26:08  gap
#H  Added release 2 by David Joyner. AH
#H
#H  Revision 1.1.1.1  1998/03/19 17:31:39  lea
#H  Initial version of GUAVA for GAP4.  Development still under way. 
#H  Lea Ruscio 19/3/98
#H
#H
#H  Revision 1.2  1997/01/20 15:34:15  werner
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

if YouWantThisCode(  4,  2,  3, "Ham" ) then
    GUAVA_TEMP_VAR := [HammingCode,[2, 3]];
fi;
if YouWantThisCode(  12,   6,   6, "Gol" ) then
    GUAVA_TEMP_VAR := [ExtendedTernaryGolayCode,[]];
fi;
if YouWantThisCode(  13,   3,   9, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [13, 0, 8, 3]];
fi;
if YouWantThisCode(  13,  10,   3, "Ham" ) then
    GUAVA_TEMP_VAR := [HammingCode, [3, 3]];
fi;
if YouWantThisCode(  14,   7,   6, "QR" ) then
    GUAVA_TEMP_VAR := [ExtendedCode, [[QRCode, [13, 3]]]];
fi;
if YouWantThisCode(  14,   8,   5, "KP" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  15,   6,   7, "LiH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  16,   5,   9, "HN" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  20,   5,  12, "GH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  21,   7,  10, "KP" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  22,   6,  12, "KP" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  24,  12,   9, "QR" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  27,   4,  18, "D3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  28,   8,  15, "KP" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  28,  14,   9, "KP" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  28,  15,   8, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [28,0,5,3]];
fi;
if YouWantThisCode(  28,  20,   6, "KP" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  29,   5,  18, "vE" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  30,   9,  14, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  30,  10,  13, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  31,   6,  18, "vE" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  32,   4,  21, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  32,   7,  17, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  32,   8,  16, "KP" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  33,  10,  15, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  34,   5,  21, "vE" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  35,   7,  19, "KP" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  36,   4,  24, "D3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  36,   6,  21, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  36,   9,  18, "KP" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  36,  18,  12, "Ple" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  36,  26,   6, "D3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  38,   5,  24, "BB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  40,   6,  24, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [40,0,23,3]];
fi;
if YouWantThisCode(  40,   9,  20, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  40,  12,  18, "KP" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  40,  20,  12, "Hu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  40,  24,   9, "KP" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  40,  36,   3, "Ham" ) then
    GUAVA_TEMP_VAR := [HammingCode, [4, 3]];
fi;
if YouWantThisCode(  41,   8,  22, "KP" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  41,  26,   8, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  41,  30,   6, "D1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  41,  33,   5, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [41, 2, 3]];
fi;
if YouWantThisCode(  42,   7,  24, "KP" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  43,   5,  27, "vE" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  43,  27,   8, "D1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  44,  10,  21, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  44,  11,  20, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  45,   5,  28, "GH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  45,   6,  27, "Ha" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  45,   7,  25, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  45,   9,  24, "KP" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  48,   8,  26, "KP" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  48,  11,  22, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  48,  12,  21, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  48,  24,  15, "Ple" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  49,   5,  31, "BB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  49,   6,  30, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  49,   7,  28, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  50,   8,  27, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  50,   9,  26, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  52,   7,  30, "CG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  52,   9,  27, "CG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  52,  10,  25, "CG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  52,  12,  24, "CG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  52,  13,  22, "CG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  52,  15,  20, "CG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  54,   8,  30, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  54,   9,  28, "GB1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  54,  16,  20, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  55,  11,  26, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  56,   6,  36, "Hi" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  56,   7,  33, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  56,  50,   4, "Hi1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  57,   9,  30, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  57,  10,  29, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  57,  14,  22, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  60,   9,  32, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  60,  11,  29, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  60,  12,  28, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  60,  14,  24, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  60,  16,  22, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  60,  21,  20, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  60,  30,  18, "Ple" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  61,   5,  39, "vE" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  61,  10,  31, "GB2" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  61,  38,  10, "D1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  63,   4,  42, "D3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  63,   6,  39, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  63,   8,  36, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  64,  10,  33, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  64,  12,  30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  64,  14,  27, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  64,  17,  24, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  64,  18,  22, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  64,  32,  18, "Be" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  64,  38,  12, "D1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  65,   5,  42, "HN" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  65,   7,  39, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  65,   9,  36, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  66,  10,  34, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  66,  11,  32, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  67,   6,  42, "Ha" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  68,  24,  20, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  69,   5,  45, "vEH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  70,   7,  42, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  70,   9,  39, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  70,  33,  16, "D1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  72,   4,  48, "D3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  72,   6,  45, "GB1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  72,   8,  42, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  72,  18,  27, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  73,  33,  18, "D1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  74,   5,  48, "vE" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  74,  23,  24, "D1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  76,  18,  30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  76,  20,  27, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  76,  24,  24, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  76,  35,  18, "D1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  78,  23,  26, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  80,  20,  30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  80,  35,  20, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  81,   5,  54, "D3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  81,   7,  51, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  81,  11,  45, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  81,  18,  32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  81,  25,  26, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  81,  28,  24, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  81,  32,  23, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  81,  34,  21, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  81,  42,  17, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  81,  46,  15, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  81,  50,  14, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  81,  54,  12, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  81,  56,  11, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  81,  60,   9, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  81,  72,   5, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  82,   8,  48, "YCh" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  82,  16,  42, "YCh" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  82,  33,  22, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [82, 0, 12, 3]];
fi;
if YouWantThisCode(  82,  57,  10, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [82, 0, 6, 3]];
fi;
if YouWantThisCode(  82,  65,   8, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [82, 0, 5, 3]];
fi;
if YouWantThisCode(  84,   6,  54, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  84,   8,  49, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  84,  18,  34, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  84,  20,  32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  84,  22,  30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  84,  25,  28, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  84,  27,  26, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  84,  30,  24, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  84,  37,  20, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  84,  42,  18, "D1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  84,  66,   7, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  84,  71,   6, "D3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  85,  23,  29, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  87,   5,  57, "Liz" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  88,   7,  53, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  88,  11,  46, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  88,  24,  30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  88,  27,  28, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  88,  30,  26, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  88,  33,  24, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  88,  37,  22, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  88,  40,  20, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  88,  44,  18, "D1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  88,  47,  16, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  88,  57,  12, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  89,  22,  32, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  89,  50,  15, "D1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  90,   6,  57, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  90,   8,  52, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  90,  19,  36, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  90,  20,  34, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  90,  64,  10, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  91,   5,  60, "HN" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  91,   7,  55, "GB1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  91,  12,  45, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  91,  51,  15, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [91,0,14,3]];
fi;
if YouWantThisCode(  92,  21,  34, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  92,  24,  32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  92,  27,  30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  92,  30,  28, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  92,  33,  26, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  92,  40,  22, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  92,  43,  20, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  93,  18,  38, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  93,  48,  18, "D1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  96,   5,  63, "D3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  96,   8,  57, "GB1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  96,  11,  51, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  96,  12,  48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  96,  14,  45, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  96,  18,  39, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  96,  21,  36, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  96,  24,  34, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  96,  27,  32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  96,  30,  30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  96,  33,  28, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  96,  36,  26, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  96,  40,  24, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  96,  43,  22, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  96,  46,  20, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  98,   6,  63, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  98,   7,  60, "GB1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  99,   9,  57, "GB1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  99,  10,  54, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  99,  11,  52, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  99,  75,   9, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 100,   5,  66, "HN1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 100,   8,  59, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 100,  12,  51, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 100,  14,  48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 100,  16,  45, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 100,  18,  42, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 100,  20,  39, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 100,  21,  38, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 100,  24,  36, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 100,  27,  34, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 100,  30,  32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 100,  33,  30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 100,  36,  28, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 100,  43,  24, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 100,  46,  22, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 100,  49,  20, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 100,  54,  18, "D1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 100,  58,  16, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 100,  68,  12, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 104,   5,  69, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [104,0,66,3]];
fi;
if YouWantThisCode( 104,   6,  66, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 104,   8,  61, "GB1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 104,  10,  57, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 104,  12,  54, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 104,  14,  51, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 104,  16,  48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 104,  18,  45, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 104,  20,  42, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 104,  21,  40, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 104,  22,  39, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 104,  24,  38, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 104,  27,  36, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 104,  30,  34, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 104,  33,  32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 104,  36,  30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 104,  39,  28, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 104,  43,  26, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 104,  46,  24, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 104,  49,  22, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 105,   7,  64, "GB1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 105,  78,  10, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,   5,  72, "D3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,   6,  69, "GB1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,   9,  63, "GB1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  10,  60, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  11,  58, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  12,  57, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  14,  54, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  16,  51, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  18,  48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  20,  45, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  22,  42, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  24,  40, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  27,  38, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  30,  36, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  33,  34, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  36,  32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  39,  30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  46,  26, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  49,  24, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  52,  22, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  56,  20, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  61,  18, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  65,  16, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  71,  14, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 110,   8,  65, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,   7,  69, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,   8,  66, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  12,  60, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  14,  57, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  16,  54, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  18,  51, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  20,  48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  22,  45, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  24,  42, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  27,  40, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  30,  38, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  33,  36, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  36,  34, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  39,  32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  42,  30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  46,  28, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  49,  26, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  52,  24, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  55,  22, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  59,  20, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  64,  18, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  68,  16, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  71,  15, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  74,  14, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  79,  12, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  98,   6, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 113,   5,  75, "HN1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 113,  43,  29, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 115,  43,  30, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 115,  87,  10, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 117,   5,  78, "D3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 117,   7,  72, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 117,  49,  27, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 118,  18,  54, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 118,  20,  51, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 118,  22,  48, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 118,  24,  45, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 118,  27,  42, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 118,  30,  40, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 118,  33,  38, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 118,  36,  36, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 118,  39,  34, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 118,  42,  32, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 118,  46,  29, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 118,  52,  26, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 120,   6,  78, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 120,   7,  74, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 120,  46,  30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 120,  49,  28, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 120,  57,  24, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 121,   5,  81, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 121,  10,  72, "YCh" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 121,  15,  63, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 121,  25,  44, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 121,  43,  32, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 121,  61,  23, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 121,  66,  21, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 121,  71,  18, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 121,  81,  14, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 121,  86,  12, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 121, 101,   8, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 121, 116,   3, "Ham" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 122,  11,  68, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 122,  16,  62, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 122,  32,  41, "NBC" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 122,  76,  17, "BCH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 122,  92,  11, "NBC" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 122, 112,   5, "GaS" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 123,  98,   9, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 124,  27,  44, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 124,  30,  42, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 124,  33,  40, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 124,  36,  38, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 124,  39,  36, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 124,  42,  34, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 124,  72,  18, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 125,  50,  30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 125,  53,  28, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 125,  61,  24, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 125,  64,  22, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 125,  68,  20, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 126,   4,  84, "D3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 126,   6,  81, "vEH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 126,   7,  78, "GB1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 126,   8,  75, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 126,   9,  73, "GB1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 126,  13,  66, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 126,  18,  57, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 126,  20,  54, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 126,  22,  51, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 126,  25,  48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 128,  19,  55, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 128,  27,  46, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 128,  30,  44, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 128,  33,  42, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 128,  36,  40, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 128,  39,  38, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 128,  42,  36, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 128,  45,  34, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 128,  49,  32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 128,  61,  25, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 128,  80,  16, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 130,   7,  81, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 130,   8,  78, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 130,   9,  75, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 130,  17,  60, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 130,  21,  54, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 130,  22,  52, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 130,  26,  48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 130,  54,  30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 130,  57,  28, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 130,  61,  26, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 130,  65,  24, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 130,  68,  22, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 131,  70,  21, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,   4,  88, "D3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,   6,  84, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  10,  75, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  11,  72, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  12,  70, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  13,  69, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  14,  65, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  15,  64, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  16,  63, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  18,  59, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  19,  58, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  20,  57, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  22,  53, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  23,  52, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  24,  51, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  25,  49, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  27,  48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  28,  47, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  30,  46, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  33,  44, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  36,  42, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  39,  40, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  42,  38, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  45,  36, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  48,  34, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  49,  33, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  52,  32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  55,  30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  56,  29, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  58,  28, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  59,  27, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  62,  26, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  64,  25, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  66,  24, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  67,  23, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  69,  22, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  74,  20, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  75,  19, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  79,  18, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  81,  17, "XBC" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  83,  16, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  87,  15, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  91,  14, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  92,  13, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  96,  12, "XBC" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132, 101,  11, "XBC" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132, 103,  10, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132, 106,   9, "XBC" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132, 111,   8, "XBC" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132, 112,   7, "XBC" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132, 117,   6, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132, 121,   5, "XBC" ) then
    GUAVA_TEMP_VAR := false;
fi;
