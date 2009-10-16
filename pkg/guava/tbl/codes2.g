#############################################################################
##
#A  codes2.g 		        GUAVA library                   Reinald Baart
#A                                                       & Jasper Cramwinckel
#A                                                          & Erik Roijackers
##
#H  @(#)$Id: codes2.g,v 1.3 2004/12/20 21:26:08 gap Exp $
##
#Y  Copyright (C)  1994,  Vakgroep Algemene Wiskunde,  T.U. Delft,  Nederland
##
#H  $Log: codes2.g,v $
#H  Revision 1.3  2004/12/20 21:26:08  gap
#H  Added release 2 by David Joyner. AH
#H
#H  Revision 1.1.1.1  1998/03/19 17:31:36  lea
#H  Initial version of GUAVA for GAP4.  Development still under way. 
#H  Lea Ruscio 19/3/98
#H
#H
#H  Revision 1.2  1997/01/20 15:34:01  werner
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

if YouWantThisCode(  17,   9,   5, "N" ) then
    GUAVA_TEMP_VAR := [QRCode, [17, 2]];
fi;
if YouWantThisCode(  23,   7,   9, "HP" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  23,  12,   7, "N" ) then
    GUAVA_TEMP_VAR := [BinaryGolayCode, [] ];
fi;
if YouWantThisCode(  23,  14,   5, "Wa" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  27,  10,   9, "Pi2" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  27,  14,   7, "L" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  31,  11,  11, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [31, 1, 11, 2]];
fi;
if YouWantThisCode(  32,   8,  13, "Sa" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  32,  13,  10, "Sh" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  32,  17,   8, "CS" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  34,  12,  12, "Sh" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  34,  23,   6, "Sh" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  35,   9,  14, "Pi" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  36,   8,  16, "DH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  36,  14,  11, "Mo" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  36,  16,  10, "Sh" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  37,   9,  15, "FB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  37,  11,  13, "O" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  38,  22,   8, "Sh" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  39,   7,  17, "vT3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  39,  10,  15, "Zv" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  40,  12,  14, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  41,  21,   9, "N" ) then
    # This probably should be a QRCode(41, GF(2))
    GUAVA_TEMP_VAR := [GeneratorPolCode, [Polynomial(GF(2), 
[ 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 1 ]*Z(2)),
41, 2]];
fi;
if YouWantThisCode(  42,   7,  19, "vT1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  42,   8,  18, "DM" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  42,  12,  15, "FB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  43,  15,  13, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [43, 1, 7, 2]];
fi;
if YouWantThisCode(  45,   6,  22, "SS" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  45,   8,  20, "DM" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  45,  10,  18, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  45,  13,  16, "CLS" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  45,  16,  13, "DJ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  46,   9,  19, "Sa" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  46,  11,  17, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  47,  24,  11, "N" ) then
    # This probably should be a QRCode(47, GF(2))
    GUAVA_TEMP_VAR := [GeneratorPolCode, [Polynomial(GF(2),
[1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1]*Z(2)),
47, 2]];
fi;
if YouWantThisCode(  48,   8,  22, "DM" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  48,  16,  15, "FB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  48,  17,  14, "Je" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  48,  31,   8, "RR" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  48,  36,   6, "Sh" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  49,  11,  19, "B2x" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  49,  13,  17, "B2x" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  49,  26,  10, "Sh" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  51,   8,  24, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [51, 0, 20, 2]];
fi;
if YouWantThisCode(  51,  17,  16, "N" ) then
    GUAVA_TEMP_VAR := [GeneratorPolCode, [Polynomial(GF(2),
[ 1, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 
  0, 1, 0, 0, 1, 1, 0, 1, 0, 1 ]*Z(2)), 51, 2]];
fi;
if YouWantThisCode(  51,  19,  14, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [51, 1, 19, 2]];
fi;
if YouWantThisCode(  51,  25,  11, "DJ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  52,  10,  21, "Pu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  54,  11,  21, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  55,   7,  25, "Zv" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  55,  10,  23, "Zv" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  55,  16,  19, "LC" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  55,  21,  15, "N" ) then
    GUAVA_TEMP_VAR := [GeneratorPolCode, [Polynomial(GF(2),
[ 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1, 
  0, 0, 1, 0, 1, 0, 1, 0, 1, 1 ]*Z(2)), 55, 2]];
fi;
if YouWantThisCode(  55,  23,  13, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  55,  31,  10, "Sh" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  56,  17,  17, "MoY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  57,  11,  23, "SRC" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  58,   8,  26, "DH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  58,  13,  22, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  60,   8,  27, "Sa" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  60,  10,  25, "Ch" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  60,  17,  20, "CDJ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  60,  19,  18, "CZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  63,  10,  27, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [63, 1, 27, 2]];
fi;
if YouWantThisCode(  63,  11,  26, "N" ) then
    GUAVA_TEMP_VAR := [GeneratorPolCode, [Polynomial(GF(2),
[ 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 
  0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 
  1, 1, 1 ]*Z(2)), 63, 2]];
fi;
if YouWantThisCode(  63,  16,  23, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [63, 1, 23, 2]];
fi;
if YouWantThisCode(  63,  18,  21, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [63, 1, 21, 2]];
fi;
if YouWantThisCode(  63,  28,  15, "N" ) then
    GUAVA_TEMP_VAR := [GeneratorPolCode, [Polynomial(GF(2),
[ 1, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1, 1, 1, 
  1, 0, 0, 0, 1, 0, 1, 0, 1, 1, 1 ]*Z(2)), 63, 2]];
fi;
if YouWantThisCode(  63,  30,  13, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [63, 1, 13, 2]];
fi;
if YouWantThisCode(  63,  36,  11, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [63, 1, 11, 2]];
fi;
if YouWantThisCode(  63,  46,   7, "N" ) then
    GUAVA_TEMP_VAR := [GeneratorPolCode, [Polynomial(GF(2),
[ 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1 ]*Z(2)), 63, 2]];
fi;
if YouWantThisCode(  64,  40,   9, "G" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  65,   8,  30, "DH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  65,  11,  27, "Ch" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  65,  13,  25, "N" ) then
    GUAVA_TEMP_VAR := [GeneratorPolCode, [Polynomial(GF(2),
[ 1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 
  1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 1, 0, 1, 
  1, 0, 1 ]*Z(2)), 65, 2]];
fi;
if YouWantThisCode(  65,  24,  17, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  65,  53,   5, "N" ) then
    GUAVA_TEMP_VAR := [GeneratorPolCode, [Polynomial(GF(2),
[ 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1 ]*Z(2)), 65, 2]];
fi;
if YouWantThisCode(  66,  18,  23, "O" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  66,  21,  20, "CZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  67,   8,  31, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  67,  10,  29, "O" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  67,  39,  11, "O" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  68,  19,  21, "Wi" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  69,  50,   8, "Sh" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  70,  10,  31, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  70,  11,  29, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  70,  13,  28, "GB2" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  70,  16,  25, "O" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  70,  45,   9, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  71,  19,  23, "Wi" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  71,  21,  21, "Wi" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  71,  28,  17, "SRC" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  72,  12,  29, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  72,  17,  25, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  72,  41,  12, "To" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  73,   6,  36, "SS" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  73,   8,  33, "Sa" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  73,  11,  31, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  73,  27,  20, "PT" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  73,  36,  16, "PT" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  73,  38,  13, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  74,   7,  35, "HP" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  74,  16,  27, "SRC" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  74,  18,  25, "Al2" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  74,  21,  23, "Wi" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  74,  23,  21, "Wi" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  74,  43,  11, "To" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  75,  12,  31, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  75,  13,  30, "To2" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  76,   8,  35, "Sa" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  76,   9,  33, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  76,  17,  27, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  76,  28,  20, "PTX" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  76,  50,   9, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  77,  23,  23, "Wi" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  77,  25,  21, "Wi" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  78,   7,  37, "HP" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  78,  13,  32, "To" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  78,  16,  29, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  78,  18,  27, "Al2" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  78,  46,  11, "ZL" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  79,  40,  15, "L" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  80,   8,  37, "vT1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  80,  10,  35, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  80,  14,  32, "Pi" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  80,  25,  23, "Wi" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  80,  27,  21, "Wi" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  80,  41,  14, "Wz" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  81,   7,  39, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  81,  20,  26, "CZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  81,  31,  20, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  82,  21,  25, "CZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  82,  68,   6, "Sh" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  83,   9,  38, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  83,  16,  31, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  83,  17,  29, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  83,  27,  23, "Wi" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  84,   8,  40, "Q" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  84,  10,  37, "B2" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  84,  11,  36, "GB2" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  84,  20,  28, "CZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  84,  29,  22, "Je" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  85,   9,  39, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  85,  13,  34, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  85,  22,  26, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  86,  18,  29, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  87,   7,  42, "Al" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  87,  13,  35, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  87,  31,  22, "PT" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  87,  36,  20, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  88,   8,  41, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  88,  15,  34, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  88,  17,  32, "PTX" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  89,  11,  40, "S" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  89,  23,  28, "X" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  89,  24,  25, "MoY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  89,  31,  23, "Wi" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  89,  45,  17, "L" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  89,  56,  11, "PT" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  89,  69,   8, "Sh" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  90,  15,  35, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  91,   9,  41, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  91,  12,  38, "GB2" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  91,  16,  33, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  91,  25,  25, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  91,  32,  22, "PWK" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  91,  51,  14, "PT" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  91,  64,   9, "Hg" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  92,   7,  45, "SS" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  93,   8,  44, "Al" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  93,  13,  38, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  93,  33,  22, "PT" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  94,  24,  28, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  94,  48,  15, "Ch" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  95,  10,  42, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  95,  13,  39, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  95,  17,  33, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  95,  23,  31, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  95,  25,  27, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  95,  33,  23, "Ch" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  95,  35,  21, "Ch" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  95,  54,  14, "To4" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  96,   8,  46, "vT1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  96,  15,  38, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  96,  16,  36, "We" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  96,  27,  26, "Wz" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  96,  75,   8, "Sh" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  97,  11,  42, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  98,  15,  39, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  98,  17,  35, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  98,  24,  29, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  98,  26,  27, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  98,  29,  25, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  99,   8,  48, "DH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  99,   9,  46, "GB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  99,  11,  43, "GB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  99,  35,  24, "To" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode(  99,  65,  11, "Ro" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 100,  13,  41, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 100,  16,  37, "Ch" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 100,  20,  34, "CZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 100,  39,  21, "Ch" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 101,  24,  31, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 101,  60,  13, "Ro" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 102,  25,  30, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 102,  27,  28, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 102,  31,  25, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 102,  37,  24, "QC" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 103,  11,  46, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 103,  13,  43, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 103,  15,  41, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 103,  52,  19, "L" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 104,  16,  40, "We" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 104,  20,  36, "We" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 105,   7,  52, "SS" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 105,   8,  49, "HP" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 105,  18,  38, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 105,  23,  33, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 105,  32,  26, "Wz" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 105,  39,  24, "QC" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 105,  43,  21, "X" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 105,  57,  15, "Ro" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 106,  11,  48, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 106,  15,  43, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 107,  41,  23, "Ch" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 107,  54,  19, "L" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,   9,  50, "GB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  12,  46, "GB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  16,  41, "Ch" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  24,  33, "Ch" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  28,  32, "B2x" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  30,  30, "B2x" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 108,  32,  28, "B2x" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 109,   8,  52, "DH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 109,  13,  45, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 109,  23,  35, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 110,  10,  49, "GB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 110,  20,  40, "Pi" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 110,  36,  26, "Wz" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 111,   9,  52, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 111,  12,  48, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,   8,  54, "vT1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  14,  45, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  16,  44, "We" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 112,  24,  36, "We" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 113,  11,  50, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 113,  13,  47, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 113,  18,  42, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 113,  22,  38, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 114,   9,  53, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 114,  10,  52, "Q" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 114,  15,  45, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 115,   8,  56, "DH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 116,  11,  52, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 116,  12,  50, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 116,  16,  45, "Ch" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 117,   9,  55, "GB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 117,  10,  54, "Q" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 117,  14,  48, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 117,  20,  43, "X" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 117,  36,  32, "SW" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 117,  42,  26, "SW" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 117,  49,  24, "SW" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 118,  22,  42, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 118,  24,  40, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 118,  26,  38, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 118,  28,  36, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 119,  11,  54, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 119,  12,  52, "GG1" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 119,  50,  23, "Ch" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 120,   8,  57, "Al" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 120,  10,  56, "Q" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 120,  16,  48, "We" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 120,  17,  46, "B2" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 120,  37,  32, "SW" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 122,  11,  56, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 122,  12,  54, "B2" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 122,  14,  52, "B2" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 124,  10,  57, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 124,  16,  49, "Ch" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 127,  10,  59, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 127,  15,  55, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [127, 1, 55, 2]];
fi;
if YouWantThisCode( 127,  22,  47, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [127, 1, 47, 2]];
fi;
if YouWantThisCode( 127,  29,  43, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [127, 1, 43, 2]];
fi;
if YouWantThisCode( 127,  30,  37, "MoY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 127,  36,  35, "SW" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 127,  43,  31, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [127, 1, 28, 2]];
fi;
if YouWantThisCode( 127,  50,  27, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [127, 1, 27, 2]];
fi;
if YouWantThisCode( 127,  57,  23, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [127, 1, 23, 2]];
fi;
if YouWantThisCode( 127,  64,  21, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [127, 1, 21, 2]];
fi;
if YouWantThisCode( 127,  71,  19, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [127, 1, 19, 2]];
fi;
if YouWantThisCode( 128,  16,  52, "We" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 128,  72,  17, "Gp" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 128,  79,  15, "Gp" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 128,  86,  13, "Gp" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 128,  93,  11, "Gp" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 128, 100,   9, "Gp" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 128, 107,   7, "Gp" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 128, 114,   5, "Gp" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 129,  11,  57, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 131,  51,  27, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 131,  72,  19, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  10,  61, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  11,  59, "GuB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  16,  53, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  17,  52, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  20,  49, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 132,  32,  37, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 135,   8,  65, "Be" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 135,  10,  63, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 135,  15,  57, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 135,  22,  49, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 135,  29,  45, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 135,  50,  29, "M" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 135,  54,  27, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 135,  57,  25, "M" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 135,  64,  23, "M" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 135,  71,  21, "M" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 135,  75,  19, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 135,  78,  17, "M" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 135,  85,  15, "M" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 135,  92,  13, "M" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 135,  99,  11, "M" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 135, 106,   9, "M" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 135, 113,   7, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 136,  16,  56, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 136,  20,  52, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 136,  32,  40, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 136,  39,  34, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 137,  11,  61, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 138,   7,  68, "vT3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 138,  17,  54, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 139,   8,  67, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 139,  12,  61, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 139,  15,  59, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 139,  22,  51, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 139,  29,  47, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 139,  39,  35, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 139,  57,  27, "M" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 139,  78,  19, "M" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 140,  11,  63, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 140,  40,  34, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 140,  44,  32, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 142,   7,  70, "vT3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 142,  10,  65, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 142,  35,  37, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 142,  53,  29, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 142,  63,  25, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 142,  70,  23, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 142,  74,  21, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 142,  84,  17, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 142,  91,  15, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 142,  98,  13, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 142, 105,  11, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 142, 112,   9, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 142, 119,   7, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 143,   8,  69, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 143,  13,  63, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 143,  15,  61, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 143,  22,  53, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 144,   9,  68, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 144,  16,  57, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 144,  24,  49, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 144,  32,  41, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 145,   7,  72, "HvT" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 145,  36,  38, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 145,  40,  36, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 145,  44,  34, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 145,  48,  32, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 146,   8,  71, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 146,  10,  67, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 146,  15,  63, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 146,  22,  55, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 146,  56,  29, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 146,  77,  21, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 147,  11,  66, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 147,  16,  59, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 147,  24,  51, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 147,  32,  43, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 148,  17,  57, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 149,   7,  73, "Be" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 149,  69,  25, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 149,  73,  23, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 149,  90,  17, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 149,  97,  15, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 149, 104,  13, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 149, 111,  11, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 150,   9,  72, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 150,  10,  70, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 150,  11,  68, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 150,  12,  66, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 150,  39,  39, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 150,  40,  38, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 150,  44,  36, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 150,  48,  34, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 150,  52,  32, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 150,  57,  30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 151,  13,  65, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 151,  64,  27, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 151,  85,  19, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 151, 136,   5, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 152,   7,  75, "Be" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 152,   8,  74, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 152,  17,  59, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 153,  12,  68, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 153,  20,  57, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 153,  29,  49, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 153,  76,  23, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 154,  10,  72, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 155,   8,  75, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 155,  13,  67, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 155,  36,  42, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 155,  40,  40, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 155,  44,  38, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 155,  48,  36, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 155,  52,  34, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 155,  61,  30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 156,  12,  70, "PWK" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 156,  15,  65, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 156,  16,  62, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 156,  24,  53, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 156,  25,  52, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 156,  32,  45, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 156,  33,  44, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 156,  68,  27, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 156,  72,  25, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 156,  96,  17, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 156, 103,  15, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 156, 110,  13, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 157,  20,  59, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 158,  22,  57, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 158,  84,  21, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 159,  13,  69, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 160,   8,  78, "DH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 160,   9,  76, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 160,  10,  74, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 160,  15,  67, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 160,  17,  64, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 160,  24,  56, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 160,  28,  52, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 160,  32,  48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 160,  40,  42, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 160,  44,  40, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 160,  48,  38, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 160,  52,  36, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 160,  56,  34, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 160,  61,  32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 160,  65,  30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 160,  69,  28, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 161,  12,  72, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 161,  76,  25, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 161,  81,  23, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 162,   9,  77, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 162,  13,  71, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 162,  16,  66, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 162,  18,  62, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 162,  22,  59, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 163,   8,  80, "DH" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 163, 102,  17, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 163, 109,  15, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 164,  15,  69, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 164,  20,  61, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 164,  24,  57, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 164,  25,  56, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 164,  28,  53, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 164,  29,  52, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 164,  32,  49, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 164,  33,  48, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 165,  11,  75, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 165,  16,  68, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 165,  44,  42, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 165,  48,  40, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 165,  52,  38, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 165,  56,  36, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 165,  61,  33, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 165,  65,  32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 165,  69,  30, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 167,   9,  80, "AEB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 167,  15,  71, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 167,  70,  29, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 167,  76,  27, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 167,  81,  25, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 167,  86,  23, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 167, 136,   9, "Hg" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 168,   8,  81, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 168,  12,  76, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 168,  16,  70, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 168,  17,  68, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 168,  19,  66, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 168,  20,  64, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 168,  24,  60, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 168,  28,  56, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 168,  32,  52, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 168,  36,  48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 170,  10,  80, "Gu" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 170,  22,  63, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 170, 108,  17, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 171,   8,  83, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 171,   9,  81, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 171,  14,  74, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 171,  16,  72, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 171,  19,  68, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 171,  39,  46, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 172,  20,  65, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 172,  24,  61, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 172,  25,  60, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 172,  28,  57, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 172,  29,  56, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 172,  32,  53, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 172,  33,  52, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 172,  36,  49, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 172,  37,  48, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 172,  48,  41, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 172,  52,  39, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 172,  56,  37, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 173,  17,  69, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 173,  61,  35, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 173,  81,  27, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 173,  86,  25, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 173,  91,  23, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 174,  12,  78, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 174,  14,  76, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 174,  16,  74, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 174,  41,  46, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 174,  65,  34, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 174,  70,  32, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 176,  20,  68, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 176,  24,  64, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 176,  28,  60, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 176,  32,  56, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 176,  36,  52, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 176,  40,  48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 176,  47,  44, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 177,  10,  82, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 177,  12,  80, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 177,  14,  78, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 177,  16,  76, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 177,  19,  69, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 177,  43,  46, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 179,  81,  29, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 179,  86,  27, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 179,  91,  25, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 180,   9,  87, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 180,  10,  84, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 180,  12,  82, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 180,  14,  80, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 180,  16,  78, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 180,  18,  72, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 180,  20,  69, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 180,  21,  68, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 180,  24,  65, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 180,  25,  64, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 180,  28,  61, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 180,  29,  60, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 180,  32,  57, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 180,  33,  56, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 180,  36,  53, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 180,  37,  52, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 180,  40,  49, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 180,  41,  48, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 180,  45,  46, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 180,  48,  44, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 180,  52,  42, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 180,  56,  40, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 180,  60,  38, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 180,  65,  36, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 180,  70,  34, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 180,  75,  32, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 183,   8,  90, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 183,  10,  86, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 183,  12,  84, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 183,  14,  82, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 183,  16,  80, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 183,  47,  46, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 184,  17,  73, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 184,  20,  72, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 184,  24,  68, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 184,  28,  64, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 184,  32,  60, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 184,  36,  56, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 184,  40,  52, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 184,  44,  48, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 185,  52,  44, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 185,  56,  42, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 185,  60,  40, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 185,  86,  29, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 185,  91,  27, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 185,  96,  25, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 186,  10,  88, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 186,  12,  86, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 186,  14,  84, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 186,  16,  82, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 186,  49,  46, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 186,  70,  36, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 186,  75,  34, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 188,   8,  93, "Be" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 188,  17,  76, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 188,  20,  73, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 188,  21,  72, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 188,  24,  69, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 188,  25,  68, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 188,  28,  65, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 188,  29,  64, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 188,  32,  61, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 188,  33,  60, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 188,  36,  57, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 188,  37,  56, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 188,  40,  53, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 188,  41,  52, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 188,  44,  49, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 189,   9,  92, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 189,  10,  90, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 189,  12,  88, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 189,  14,  86, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 189,  16,  84, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 190,  52,  46, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 190,  56,  44, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 190,  60,  42, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 190,  64,  40, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 190,  69,  38, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 191,  17,  77, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 191,  91,  29, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 191,  96,  27, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 191, 101,  25, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 191, 116,  21, "X" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 191, 124,  19, "X" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 191, 128,  17, "X" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 191, 136,  15, "Su" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 191, 144,  13, "X" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 191, 152,  11, "X" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 192,  14,  88, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 192,  16,  86, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 192,  20,  76, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 192,  24,  72, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 192,  28,  68, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 192,  32,  64, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 192,  36,  60, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 192,  40,  56, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 192,  41,  54, "PWK" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 192,  44,  52, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 192,  51,  48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 192,  53,  46, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 192,  65,  40, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 192,  70,  38, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 192,  75,  36, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 192,  80,  34, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 192,  86,  32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 195,  10,  94, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 195,  12,  89, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 195,  16,  88, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 195,  17,  80, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 195,  18,  78, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 195,  55,  46, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 196,  21,  76, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 196,  24,  73, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 196,  25,  72, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 196,  28,  69, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 196,  29,  68, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 196,  32,  65, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 196,  33,  64, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 196,  36,  61, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 196,  37,  60, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 196,  40,  57, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 196,  41,  56, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 196,  44,  53, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 196,  45,  52, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 197,  56,  45, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 197,  96,  29, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 197, 101,  27, "Ka" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 198,   8,  97, "Be" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 198,  14,  89, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 198,  65,  42, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 198,  70,  40, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 198,  75,  38, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 198,  80,  36, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 198,  86,  33, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 198,  91,  32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 199,  12,  91, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 199,  17,  81, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 200,  20,  80, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 200,  24,  76, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 200,  28,  72, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 200,  32,  68, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 200,  36,  64, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 200,  40,  60, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 200,  44,  56, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 200,  48,  52, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 200,  51,  50, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 200,  55,  48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 200,  62,  44, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 201,  97,  29, "Ch" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 202,   8,  99, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 202,  14,  91, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 202,  17,  83, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 203,  12,  93, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 203,  16,  89, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 203,  51,  51, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 204,   9,  98, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 205,  18,  81, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 205,  21,  80, "Sab" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 205,  52,  50, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 205,  56,  48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 205,  60,  46, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 206,  12,  95, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 206,  14,  93, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 206,  17,  85, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 206,  47,  53, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 206,  70,  41, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 206,  75,  39, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 206,  96,  31, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 206, 101,  29, "Ch" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 207,   8, 102, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 207,   9, 100, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 207,  16,  91, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 207,  22,  78, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 207,  86,  35, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 207,  91,  33, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 207, 108,  27, "X" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 207, 116,  25, "X" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 207, 124,  23, "X" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 208,  20,  81, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 208,  28,  73, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 208,  32,  69, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 208,  36,  65, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 208,  40,  61, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 208,  44,  57, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 208,  48,  53, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 209,  14,  95, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 210,  10,  99, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 210,  11,  98, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 210,  17,  88, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 210,  22,  80, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 210,  58,  48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 211,  16,  93, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 211,  20,  83, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 211,  28,  75, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 211,  32,  71, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 211,  36,  67, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 211,  40,  63, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 211,  44,  59, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 212,   9, 101, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 212,  18,  85, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 212,  24,  77, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 212,  56,  49, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 212,  60,  47, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 212, 106,  29, "Ch" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 213,   8, 105, "Be" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 213,  12,  98, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 214,  13,  97, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 214,  16,  95, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 214,  17,  89, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 214,  22,  81, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 214,  51,  55, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 214,  55,  51, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 215,   9, 103, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 215,  18,  87, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 216,   8, 107, "Be" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 216,  10, 102, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 216,  12, 100, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 216,  14,  97, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 216,  24,  80, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 216,  62,  48, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 216,  96,  34, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 216, 101,  32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 217,  17,  91, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 217,  22,  83, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 219,  10, 104, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 219,  12, 102, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 219,  20,  86, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 220,   8, 109, "Be" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 220,  14,  99, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 220,  24,  81, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 220,  25,  80, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 220,  28,  77, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 220,  29,  76, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 220,  32,  73, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 220,  33,  72, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 220,  36,  69, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 220,  37,  68, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 220,  40,  65, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 220,  41,  64, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 220,  44,  61, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 220,  45,  60, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 220,  48,  57, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 220,  55,  53, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 221,   9, 107, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 221,  17,  93, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 222,  10, 106, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 222,  12, 104, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 222,  20,  88, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 222,  22,  86, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 222,  60,  50, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 222, 106,  32, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 223,  16,  97, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 224,  14, 101, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 224,  18,  91, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 224,  24,  84, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 224,  28,  80, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 224,  32,  76, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 224,  36,  72, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 224,  40,  68, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 224,  44,  64, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 224,  48,  60, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 224,  55,  56, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 225,   9, 110, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 225,  10, 108, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 225,  12, 106, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 225,  13, 104, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 225,  17,  96, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 225,  22,  88, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 226,  51,  57, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 227,  14, 103, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 227,  16,  99, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 228,  10, 110, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 228,  12, 108, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 228,  20,  91, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 228,  24,  85, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 228,  25,  84, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 228,  28,  81, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 228,  29,  80, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 228,  32,  77, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 228,  33,  76, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 228,  36,  73, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 228,  37,  72, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 228,  40,  69, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 228,  41,  68, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 228,  44,  65, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 228,  45,  64, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 228,  48,  61, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 228,  49,  60, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 229,   8, 113, "Be" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 229,  13, 105, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 229,  17,  97, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 229,  22,  89, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 231,  10, 112, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 231,  12, 110, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 231,  16, 101, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 231,  18,  95, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 232,   8, 115, "Be" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 232,  17,  99, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 232,  24,  88, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 232,  28,  84, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 232,  32,  80, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 232,  36,  76, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 232,  40,  72, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 232,  44,  68, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 232,  48,  64, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 232,  52,  60, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 232,  55,  58, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 232,  59,  56, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 234,  12, 112, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 234,  13, 107, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 234,  16, 103, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 234,  20,  95, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 234,  22,  92, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 235,  14, 105, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 236,   8, 117, "Be" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 236,  17, 101, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 236,  18,  99, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 236,  48,  65, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 236,  49,  64, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 236,  52,  61, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 236,  59,  57, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 236,  61,  56, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 237,  22,  94, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 238,   9, 116, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 238,  10, 113, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 239,  14, 107, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 239,  20,  99, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 240,  13, 112, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 240,  16, 105, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 240,  17, 104, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 240,  22,  96, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 240,  32,  86, "B2" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 240,  34,  84, "B2" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 240,  36,  82, "B2" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 240,  38,  80, "B2" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 240,  40,  78, "B2" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 240,  42,  76, "B2" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 240,  44,  74, "B2" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 240,  46,  72, "B2" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 240,  48,  68, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 240,  52,  64, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 240,  59,  60, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 240,  61,  58, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 240,  64,  56, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 241,  11, 113, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 241,  18, 103, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 241,  24,  94, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 242,  10, 115, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 243,   9, 118, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 243,  12, 113, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 243,  14, 109, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 243,  16, 107, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 244,   8, 121, "Be" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 244,  20, 103, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 244,  28,  90, "B2" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 244,  48,  69, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 244,  49,  68, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 244,  52,  65, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 244,  53,  64, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 244,  64,  58, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 245,  11, 115, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 245,  13, 113, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 246,  10, 117, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 246,  14, 111, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 246,  16, 109, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 246,  18, 107, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 246,  22,  97, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 247,  12, 115, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 248,  24,  96, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 248,  48,  72, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 248,  52,  68, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 248,  56,  64, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 248,  59,  62, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 248,  67,  58, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 249,  10, 119, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 249,  13, 115, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 249,  16, 111, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 249,  18, 109, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 249,  20, 107, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 250,  22,  99, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 252,  11, 120, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 252,  12, 118, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 252,  24,  97, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 252,  48,  73, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 252,  49,  72, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 252,  52,  69, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 252,  53,  68, "BY" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 252,  56,  65, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 252,  63,  61, "XB" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 252,  70,  58, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 253,  14, 113, "GG" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255,  10, 122, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255,  13, 119, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255,  21, 111, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255,  22, 102, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255,  24,  99, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255,  29,  95, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255,  30,  94, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255,  37,  91, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255,  38,  90, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255,  45,  87, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255,  47,  85, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255,  48,  75, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255,  52,  71, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255,  56,  67, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255,  63,  63, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255,  71,  59, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255,  73,  57, "BZ" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255,  79,  55, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [255, 1, 55, 2]];
fi;
if YouWantThisCode( 255,  87,  53, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255,  91,  51, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255,  99,  47, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255, 107,  45, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255, 115,  43, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255, 123,  39, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255, 131,  37, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255, 134,  34, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255, 139,  31, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255, 147,  29, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255, 155,  27, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255, 163,  25, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255, 171,  23, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255, 179,  21, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255, 187,  19, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255, 199,  15, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255, 215,  11, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 255, 231,   7, "I" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 257,  16, 114, "Gu3" ) then
    GUAVA_TEMP_VAR := false;
fi;
if YouWantThisCode( 257, 192,  18, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [257, 1, 9,  2]];
fi;
if YouWantThisCode( 257, 208,  14, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [127, 1, 23, 2]];
fi;
if YouWantThisCode( 257, 224,  10, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [257, 0, 6, 2]];
fi;
if YouWantThisCode( 257, 240,   6, "BCH" ) then
    GUAVA_TEMP_VAR := [BCHCode, [257, 0, 4, 2]];
fi;

Unbind(YouWantThisCode);
