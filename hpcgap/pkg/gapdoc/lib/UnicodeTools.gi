#############################################################################
##
#W  UnicodeTools.gi                GAPDoc                     Frank Lübeck
##
##
#Y  Copyright (C)  2007,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##  
##  The files UnicodeTools.g{d,i} contain utilities for converting text
##  between different encodings. They introduce unicode strings and
##  characters as GAP objects.
##  

# reading some extendible tables of translations of unicode characters
ReadPackage("GAPDoc", "lib/UnicodeTabs.g");

# UNICODE_RECODE is a is a record. For some string enc, describing a
# character encoding, UNICODE_RECODE.(enc) is a function which translates
# a GAP string in encoding enc to a list of integers describing the unicode
# codepoints of the characters in the string.
#
# UNICODE_RECODE.TABLES contains some embeddings of 8 bit code pages into 
# unicode as lists of length 256, codepoint of character i in [0..255] in 
# position i+1.

# normalize encoding names
UNICODE_RECODE.NormalizedEncodings := rec(
  latin1 := "ISO-8859-1",
  latin2 := "ISO-8859-2",
  latin3 := "ISO-8859-3",
  latin4 := "ISO-8859-4",
  latin5 := "ISO-8859-9",
  latin6 := "ISO-8859-10",
  latin7 := "ISO-8859-13",
  latin8 := "ISO-8859-14",
  latin9 := "ISO-8859-15",
  latin0 := "ISO-8859-15",
  utf8 := "UTF-8",
  UTF8 := "UTF-8",
  ASCII := "ANSI_X3.4-1968",
  US\-ASCII := "ANSI_X3.4-1968",
  xml := "XML",
  url := "URL",
  URL := "URL",
  percent := "URL",
);

UNICODE_RECODE.f := function()
  local nam, i;
  for i in Concatenation([1..11],[13..15]) do
    nam := Concatenation("ISO-8859-",String(i));
    UNICODE_RECODE.NormalizedEncodings.(nam) := nam;
    UNICODE_RECODE.Decoder.(nam) := function(str)
      return UNICODE_RECODE.TABLES.(nam){List(str, INT_CHAR)+1};
    end;
  od;
  nam := "ANSI_X3.4-1968";
  UNICODE_RECODE.NormalizedEncodings.(nam) := nam;
  UNICODE_RECODE.Decoder.(nam) := function(str)
    return UNICODE_RECODE.TABLES.(nam){List(str, INT_CHAR)+1};
  end;

  UNICODE_RECODE.NormalizedEncodings.("UTF-8") := "UTF-8";
  UNICODE_RECODE.NormalizedEncodings.("XML") := "XML";
end;
UNICODE_RECODE.f();
Unbind(UNICODE_RECODE.f);
# slightly more efficient for latin1:
UNICODE_RECODE.Decoder.("ISO-8859-1") := function(str)
  return List(str, INT_CHAR);
end;
# helper function;  arg:  str[, start], translate single UTF-8 character
# to its unicode number
UNICODE_RECODE.UnicodeUTF8Char := function(arg)
  local str, i, a, i1, i2, i3;
  str := arg[1];
  if Length(arg)>1 then
    i := arg[2];
  else
    i := 1;
  fi;
  a := INT_CHAR(str[i]);
  if a < 128 then
    return a;
  elif a < 224 then
    if i = Length(str) then return fail; fi;
    i1 := INT_CHAR(str[i+1]);
    if i1 < 128 or i1 > 191 then
      return fail;
    fi;
    return (a mod 192)*64 + (i1 mod 64);
  elif a < 240 then
    if Length(str) < i+2 then return fail; fi;
    i1 := INT_CHAR(str[i+1]);
    i2 := INT_CHAR(str[i+2]);
    if i1 < 128 or i2 < 128 or i1 > 191 or i2 > 191 then
      return fail;
    fi;
    return (a mod 224)*4096 + (i1 mod 64)*64
                            + (i2 mod 64);
  else
    if Length(str) < i+3 then return fail; fi;
    i1 := INT_CHAR(str[i+1]);
    i2 := INT_CHAR(str[i+2]);
    i3 := INT_CHAR(str[i+3]);
    if i1<128 or i2<128 or i3<128 or i1>191 or i2>191 or i3>191 then
      return fail;
    fi;
    return (a mod 240)*262144 + (i1 mod 64)*4096
                              + (i2 mod 64)*64
                              + (i3 mod 64);
  fi;
end;
##  UNICODE_RECODE.Decoder.("UTF-8") := function(str)
##    local res, c, i;
##    res := [];
##    for i in [1..Length(str)] do
##      c := INT_CHAR(str[i]);
##      if c < 128 or c > 191 then
##        Add(res, UNICODE_RECODE.UnicodeUTF8Char(str, i));
##      fi;
##    od;
##    if fail in res then return fail; fi;
##    return res;
##  end;
UNICODE_RECODE.Decoder.("UTF-8") := function(str)
  local res, i, n;
  res := [];
  i := 1;
  while i <= Length(str) do
    n := UNICODE_RECODE.UnicodeUTF8Char(str, i);
    if n = fail then
      return fail;
    elif n < 128 then
      i := i+1;
    elif n < 2048 then
      i := i+2;
    elif n < 65536 then
      i := i+3;
    else
      i := i+4;
    fi;
    Add(res, n);
  od;
  if fail in res then return fail; fi;
  return res;
end;

UNICODE_RECODE.Decoder.("XML") := function(str)
  local res, i, j, n;
  res := [];
  i := 1;
  while i <= Length(str) do
    if str[i] = '&' and i < Length(str) and str[i+1] = '#' then
      j := Position(str, ';', i);
      n := str{[i+2..j-1]};
      if n[1] = 'x' then
        n := IntHexString(n{[2..Length(n)]});
      else
        n := Int(n);
      fi;
      Add(res, n);
      i := j+1;
    else
      Add(res, INT_CHAR(str[i]));
      i := i+1;
    fi;
  od;
  return res;
end;

UNICODE_RECODE.Decoder.("URL") := function(str)
  local res, i;
  res := "";
  i := 1;
  while i <= Length(str) do
    if str[i] = '%' then
      Add(res, CHAR_INT(IntHexString(str{[i+1,i+2]})));
      i := i+3;
    else
      Add(res, str[i]);
      i := i+1;
    fi;
  od;
  return IntListUnicodeString(Unicode(res, "UTF-8"));
end;


################################################
UNICODE_RECODE.TABLES := 
rec(
  ANSI_X3\.4\-1968 := [0..127],
  ISO\-8859\-1 := [ 0 .. 255 ],
  ISO\-8859\-2 := [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 
      17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
      35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
      53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 
      71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 
      89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 
      105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 
      119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 
      133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 
      147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 260, 
      728, 321, 163, 317, 346, 166, 167, 352, 350, 356, 377, 172, 381, 379, 
      175, 261, 731, 322, 179, 318, 347, 711, 183, 353, 351, 357, 378, 733, 
      382, 380, 340, 192, 193, 258, 195, 313, 262, 198, 268, 200, 280, 202, 
      282, 204, 205, 270, 272, 323, 327, 210, 211, 336, 213, 214, 344, 366, 
      217, 368, 219, 220, 354, 222, 341, 224, 225, 259, 227, 314, 263, 230, 
      269, 232, 281, 234, 283, 236, 237, 271, 273, 324, 328, 242, 243, 337, 
      245, 246, 345, 367, 249, 369, 251, 252, 355, 729, 255 ],
  ISO\-8859\-3 := [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 
      17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
      35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
      53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 
      71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 
      89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 
      105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 
      119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 
      133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 
      147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 294, 
      728, 162, 163, 164, 292, 166, 167, 304, 350, 286, 308, 172, 173, 379, 
      175, 295, 177, 178, 179, 180, 293, 182, 183, 305, 351, 287, 309, 188, 
      189, 380, 191, 192, 193, 194, 195, 266, 264, 198, 199, 200, 201, 202, 
      203, 204, 205, 206, 207, 208, 209, 210, 211, 288, 213, 214, 284, 216, 
      217, 218, 219, 364, 348, 222, 223, 224, 225, 226, 227, 267, 265, 230, 
      231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 289, 
      245, 246, 285, 248, 249, 250, 251, 365, 349, 729, 255 ],
  ISO\-8859\-4 := [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 
      17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
      35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
      53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 
      71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 
      89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 
      105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 
      119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 
      133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 
      147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 260, 
      312, 342, 163, 296, 315, 166, 167, 352, 274, 290, 358, 172, 381, 174, 
      175, 261, 731, 343, 179, 297, 316, 711, 183, 353, 275, 291, 359, 330, 
      382, 331, 256, 192, 193, 194, 195, 196, 197, 302, 268, 200, 280, 202, 
      278, 204, 205, 298, 272, 325, 332, 310, 211, 212, 213, 214, 215, 370, 
      217, 218, 219, 360, 362, 222, 257, 224, 225, 226, 227, 228, 229, 303, 
      269, 232, 281, 234, 279, 236, 237, 299, 273, 326, 333, 311, 243, 244, 
      245, 246, 247, 371, 249, 250, 251, 361, 363, 729, 255 ],
  ISO\-8859\-5 := [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 
      17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
      35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
      53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 
      71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 
      89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 
      105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 
      119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 
      133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 
      147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 1025, 
      1026, 1027, 1028, 1029, 1030, 1031, 1032, 1033, 1034, 1035, 1036, 172, 
      1038, 1039, 1040, 1041, 1042, 1043, 1044, 1045, 1046, 1047, 1048, 1049, 
      1050, 1051, 1052, 1053, 1054, 1055, 1056, 1057, 1058, 1059, 1060, 1061, 
      1062, 1063, 1064, 1065, 1066, 1067, 1068, 1069, 1070, 1071, 1072, 1073, 
      1074, 1075, 1076, 1077, 1078, 1079, 1080, 1081, 1082, 1083, 1084, 1085, 
      1086, 1087, 1088, 1089, 1090, 1091, 1092, 1093, 1094, 1095, 1096, 1097, 
      1098, 1099, 1100, 1101, 1102, 1103, 8470, 1105, 1106, 1107, 1108, 1109, 
      1110, 1111, 1112, 1113, 1114, 1115, 1116, 167, 1118, 1119, 255 ],
  ISO\-8859\-6 := [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 
      17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
      35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
      53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 
      71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 
      89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 
      105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 
      119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 
      133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 
      147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 
      161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 1548, 172, 173, 174, 
      175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 1563, 187, 188, 
      189, 1567, 191, 1569, 1570, 1571, 1572, 1573, 1574, 1575, 1576, 1577, 
      1578, 1579, 1580, 1581, 1582, 1583, 1584, 1585, 1586, 1587, 1588, 1589, 
      1590, 1591, 1592, 1593, 1594, 218, 219, 220, 221, 222, 1600, 1601, 
      1602, 1603, 1604, 1605, 1606, 1607, 1608, 1609, 1610, 1611, 1612, 1613, 
      1614, 1615, 1616, 1617, 1618, 242, 243, 244, 245, 246, 247, 248, 249, 
      250, 251, 252, 253, 254, 255 ],
  ISO\-8859\-7 := [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 
      17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
      35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
      53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 
      71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 
      89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 
      105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 
      119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 
      133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 
      147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 701, 
      700, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 8213, 
      175, 176, 177, 178, 900, 901, 902, 182, 904, 905, 906, 186, 908, 188, 
      910, 911, 912, 913, 914, 915, 916, 917, 918, 919, 920, 921, 922, 923, 
      924, 925, 926, 927, 928, 929, 209, 931, 932, 933, 934, 935, 936, 937, 
      938, 939, 940, 941, 942, 943, 944, 945, 946, 947, 948, 949, 950, 951, 
      952, 953, 954, 955, 956, 957, 958, 959, 960, 961, 962, 963, 964, 965, 
      966, 967, 968, 969, 970, 971, 972, 973, 974, 254, 255 ],
  ISO\-8859\-8 := [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 
      17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
      35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
      53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 
      71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 
      89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 
      105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 
      119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 
      133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 
      147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 
      161, 162, 163, 164, 165, 166, 167, 168, 215, 170, 171, 172, 173, 8254, 
      175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 247, 186, 187, 188, 
      189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 
      203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 
      217, 218, 219, 220, 221, 8215, 1488, 1489, 1490, 1491, 1492, 1493, 
      1494, 1495, 1496, 1497, 1498, 1499, 1500, 1501, 1502, 1503, 1504, 1505, 
      1506, 1507, 1508, 1509, 1510, 1511, 1512, 1513, 1514, 250, 251, 252, 
      253, 254, 255 ],
  ISO\-8859\-9 := [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 
      17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 
      35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 
      53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 
      71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 
      89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 
      105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 
      119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 
      133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 
      147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 
      161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 
      175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 
      189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 
      203, 204, 205, 206, 286, 208, 209, 210, 211, 212, 213, 214, 215, 216, 
      217, 218, 219, 304, 350, 222, 223, 224, 225, 226, 227, 228, 229, 230, 
      231, 232, 233, 234, 235, 236, 237, 238, 287, 240, 241, 242, 243, 244, 
      245, 246, 247, 248, 249, 250, 251, 305, 351, 254, 255 ],
  ISO\-8859\-10 := [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
      16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 
      34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 
      52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 
      70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 
      88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 
      104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 
      118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 
      132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 
      146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 
      260, 274, 290, 298, 296, 310, 166, 315, 272, 352, 358, 381, 172, 362, 
      330, 175, 261, 275, 291, 299, 297, 311, 182, 316, 273, 353, 359, 382, 
      8213, 363, 331, 256, 192, 193, 194, 195, 196, 197, 302, 268, 200, 280, 
      202, 278, 204, 205, 206, 207, 325, 332, 210, 211, 212, 213, 360, 215, 
      370, 217, 218, 219, 220, 221, 222, 257, 224, 225, 226, 227, 228, 229, 
      303, 269, 232, 281, 234, 279, 236, 237, 238, 239, 326, 333, 242, 243, 
      244, 245, 361, 247, 371, 249, 250, 251, 252, 253, 312, 255 ],
  ISO\-8859\-11 := [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
      16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 
      34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 
      52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 
      70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 
      88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 
      104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 
      118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 
      132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 
      146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 
      3585, 3586, 3587, 3588, 3589, 3590, 3591, 3592, 3593, 3594, 3595, 3596, 
      3597, 3598, 3599, 3600, 3601, 3602, 3603, 3604, 3605, 3606, 3607, 3608, 
      3609, 3610, 3611, 3612, 3613, 3614, 3615, 3616, 3617, 3618, 3619, 3620, 
      3621, 3622, 3623, 3624, 3625, 3626, 3627, 3628, 3629, 3630, 3631, 3632, 
      3633, 3634, 3635, 3636, 3637, 3638, 3639, 3640, 3641, 3642, 218, 219, 
      220, 221, 3647, 3648, 3649, 3650, 3651, 3652, 3653, 3654, 3655, 3656, 
      3657, 3658, 3659, 3660, 3661, 3662, 3663, 3664, 3665, 3666, 3667, 3668, 
      3669, 3670, 3671, 3672, 3673, 3674, 3675, 251, 252, 253, 254, 255 ],
  ISO\-8859\-13 := [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
      16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 
      34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 
      52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 
      70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 
      88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 
      104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 
      118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 
      132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 
      146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 
      8221, 161, 162, 163, 8222, 165, 166, 216, 168, 342, 170, 171, 172, 173, 
      198, 175, 176, 177, 178, 8220, 180, 181, 182, 248, 184, 343, 186, 187, 
      188, 189, 230, 260, 302, 256, 262, 195, 196, 280, 274, 268, 200, 377, 
      278, 290, 310, 298, 315, 352, 323, 325, 210, 332, 212, 213, 214, 370, 
      321, 346, 362, 219, 379, 381, 222, 261, 303, 257, 263, 227, 228, 281, 
      275, 269, 232, 378, 279, 291, 311, 299, 316, 353, 324, 326, 242, 333, 
      244, 245, 246, 371, 322, 347, 363, 251, 380, 382, 8217, 255 ],
  ISO\-8859\-14 := [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
      16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 
      34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 
      52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 
      70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 
      88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 
      104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 
      118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 
      132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 
      146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 
      7682, 7683, 162, 266, 267, 7690, 166, 7808, 168, 7810, 7691, 7922, 172, 
      173, 376, 7710, 7711, 288, 289, 7744, 7745, 181, 7766, 7809, 7767, 
      7811, 7776, 7923, 7812, 7813, 7777, 191, 192, 193, 194, 195, 196, 197, 
      198, 199, 200, 201, 202, 203, 204, 205, 206, 372, 208, 209, 210, 211, 
      212, 213, 7786, 215, 216, 217, 218, 219, 220, 374, 222, 223, 224, 225, 
      226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 373, 
      240, 241, 242, 243, 244, 245, 7787, 247, 248, 249, 250, 251, 252, 375, 
      254, 255 ],
  ISO\-8859\-15 := [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 
      16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 
      34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 
      52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 
      70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 
      88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 
      104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 
      118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 
      132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 
      146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 
      160, 161, 162, 8364, 164, 352, 166, 353, 168, 169, 170, 171, 172, 173, 
      174, 175, 176, 177, 178, 381, 180, 181, 182, 382, 184, 185, 186, 338, 
      339, 376, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 
      202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 
      216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 
      230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 
      244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255 ] );
# reverse tables are only generated when needed
UNICODE_RECODE.TABLES.reverse := rec();
##  # this created the code tables for ISO-8859:
##  for i in Concatenation([1..11],[13..15]) do
##    fn := Concatenation("iso8859-",String(i),".txt");
##    str := StringFile(fn);
##    str := SplitString(str,"","\n");
##    str := List(str, a-> SplitString(a,""," \t"));
##    str := List(str, a-> List([1,2], k-> IntHexString(
##                Filtered(a[k], x-> not x in "=+U"))));
##    str := Filtered(str, a-> a[1]<>a[2]);
##    fn := Concatenation("ISO-8859-",String(i));
##    res := [0..255];
##    for a in str do 
##      res[a[1]] := a[2];
##    od;
##    UNICODE_RECODE.TABLES.(fn) := res;
##  od;
################################################

# wrap and cache integers as unicode characters
InstallMethod(UChar, [IsInt], function(n)
  local res;
  if not IsInt(n) or n < 0 or n > 2097151 then
    return fail;
  fi;
  if IsBound(UNICODECHARCACHE[n]) then
    return UNICODECHARCACHE[n];
  fi;
  res := rec(codepoint := n);
  Objectify(UnicodeCharacterType, res);
  UNICODECHARCACHE[n] := res;
  return res;
end);
# interpret GAP characters as latin 1 encoded
InstallMethod(UChar, [IsChar], function(c)
  return UChar(INT_CHAR(c));
end);

# viewing and printing unicode characters
InstallMethod(ViewObj, [IsUnicodeCharacter], function(c)
  Print("'", UNICODE_RECODE.UTF8UnicodeChar(c!.codepoint), "'");
end);
InstallMethod(PrintObj, [IsUnicodeCharacter], function(c)
  Print("UChar(",c!.codepoint,")");
end);
# \=
InstallMethod(\=, [IsUnicodeCharacter, IsUnicodeCharacter],
function(c, d)
  return c!.codepoint = d!.codepoint;
end);
InstallOtherMethod(Int, [IsUnicodeCharacter], function(uc)
  return uc!.codepoint;
end);

##  <#GAPDoc Label="Unicode">
##  <ManSection>
##  <Heading>Unicode Strings and Characters</Heading>
##  <Oper Name="Unicode" Arg="list[, encoding]"/>
##  <Oper Name="UChar" Arg="num"/>
##  <Filt Name="IsUnicodeString" />
##  <Filt Name="IsUnicodeCharacter" />
##  <Func Name="IntListUnicodeString" Arg="ustr" />
##  
##  <Description>
##  Unicode characters are described by their <Emph>codepoint</Emph>, an
##  integer in the range from <M>0</M> to <M>2^{21}-1</M>. 
##  For details about unicode, see <URL>http://www.unicode.org</URL>.<P/>
##  
##  The function <Ref Oper="UChar"/> wraps an integer <A>num</A> into
##  a &GAP; object lying in the filter <Ref Filt="IsUnicodeCharacter"/>.
##  Use <C>Int</C> to get the codepoint back. The argument <A>num</A> can
##  also be a &GAP; character which is then translated to an integer via 
##  <Ref BookName="Reference" Func="IntChar"/>. <P/>
##  
##  <Ref Oper="Unicode" /> produces a &GAP; object in the filter
##  <Ref Filt="IsUnicodeString"/>. This is a wrapped list of integers 
##  for the unicode characters in the string. The function <Ref
##  Func="IntListUnicodeString"/> gives access to this list of integers. 
##  Basic list functionality is available for <Ref Filt="IsUnicodeString"/>
##  elements. The entries are in <Ref Filt="IsUnicodeCharacter"/>.
##  The argument <A>list</A> for <Ref Oper="Unicode"/> is either a list of
##  integers or a &GAP; string. In the latter case an <A>encoding</A> can be
##  specified as string, its default is <C>"UTF-8"</C>. <P/>
##  
##  <Index>URL encoding</Index><Index>RFC 3986</Index>
##  Currently supported encodings can be found in
##  <C>UNICODE_RECODE.NormalizedEncodings</C> (ASCII, 
##  ISO-8859-X, UTF-8 and aliases). The encoding <C>"XML"</C> means an ASCII
##  encoding in which non-ASCII characters are specified by XML character
##  entities. The encoding <C>"URL"</C> is for URL-encoded (also called
##  percent-encoded strings, as specified in RFC 3986 
##  (<URL Text="see here">http://www.ietf.org/rfc/rfc3986.txt</URL>).
##  The listed encodings <C>"LaTeX"</C> and aliases
##  cannot be used with <Ref Oper="Unicode" />.
##  See the operation <Ref Oper="Encode"/> for mapping  a unicode string 
##  to a &GAP; string.<P/>
##  <Example>
##  gap> ustr := Unicode("a and \366", "latin1");
##  Unicode("a and \303\266")
##  gap> ustr = Unicode("a and &amp;#246;", "XML");  
##  true
##  gap> IntListUnicodeString(ustr);
##  [ 97, 32, 97, 110, 100, 32, 246 ]
##  gap> ustr[7];
##  'ö'
##  </Example>
##  </Description>
##  </ManSection>
##  
##  <#/GAPDoc>


# NC method, assume that l is (plain?) list of integers in correct range
InstallMethod(Unicode, [IsList], function(l)
  local res;
  res := [l];
  Objectify(UnicodeStringType, res);
  return res;
end);
# extract the list of integers
InstallGlobalFunction("IntListUnicodeString", function(ustr)
  return ustr![1];
end);


InstallMethod(Unicode, [IsString, IsString], function(str, enc)
  local res;
  if Length(str) > 0 and not IsStringRep(str) then
##      Info(InfoWarning, 1, "#W Changing argument to IsStringRep");
##      Info(InfoWarning, 2, ":\n ", str);
##      Info(InfoWarning, 1, "\n");
##      ConvertToStringRep(str);
    str := ShallowCopy(str);
    ConvertToStringRep(str);
  fi;
  if not IsBound(UNICODE_RECODE.NormalizedEncodings.(enc)) then
    Error("Sorry, only the following encodings are supported for 'Unicode':\n",
              RecFields(UNICODE_RECODE.Decoder), "\n");
  fi;
  enc := UNICODE_RECODE.NormalizedEncodings.(enc);
  res := UNICODE_RECODE.Decoder.(enc)(str);
  if res = fail then
    return fail;
  fi;
  return Unicode(res);
end);
# just a string as argument is assumed to be in UTF-8 encoding
InstallMethod(Unicode, [IsStringRep], function(str)
  return Unicode(str, "UTF-8");
end);
  
# view and print 
InstallMethod(ViewObj, [IsUnicodeString], function(ustr)
  local l;
  l := IntListUnicodeString(ustr);
  if Length(l) > 40 then
    l := l{[1..37]};
    Append(l, [46,46,46]);
  fi;
  Print("Unicode(");
  ViewObj(Concatenation(List(l, UNICODE_RECODE.UTF8UnicodeChar)));
  Print(")");
end);
InstallMethod(PrintObj, [IsUnicodeString], function(ustr)
  Print("Unicode(");
  PrintObj(Concatenation(List(IntListUnicodeString(ustr), 
           UNICODE_RECODE.UTF8UnicodeChar)));
  Print(")");
end);

# the *basic* list operations
InstallMethod(Length, [IsUnicodeString], function(ustr)
  return Length(IntListUnicodeString(ustr));
end);

InstallMethod(\[\], [IsUnicodeString, IsPosInt], function(ustr, i)
  return UChar(IntListUnicodeString(ustr)[i]);
end);

InstallOtherMethod(\[\]\:\=, [IsUnicodeString and IsMutable, 
                              IsPosInt, IsUnicodeCharacter], 
function(ustr, i, x)
  local l;
  if i > Length(ustr)+1 then
    Error("no unicode string assignment at position ",i,"\n");
  fi;
  l := IntListUnicodeString(ustr);
  l[i] := x!.codepoint;
end);

InstallMethod(Unbind\[\], [IsUnicodeString and IsMutable, IsPosInt],
function(ustr, i)
  local l;
  if i < Length(ustr) then
    Error("can only unbind last character in unicode string\n");
  fi;
  if i = Length(ustr) then
    l := IntListUnicodeString(ustr);
    Unbind(l[Length(l)]);
  fi;
end);

# let ShallowCopy produce a unicode string
InstallMethod(ShallowCopy, [IsUnicodeString], function(ustr)
  return Unicode(ShallowCopy(IntListUnicodeString(ustr)));
end);
# let sublists be unicode strings
InstallMethod(\{\}, [IsUnicodeString, IsList], function(ustr, poss)
  return Unicode(IntListUnicodeString(ustr){poss});
end);

# a better Append for efficiency
InstallMethod(Append, [IsUnicodeString and IsMutable, IsUnicodeString],
function(ustr, ustr2)
  Append(IntListUnicodeString(ustr), IntListUnicodeString(ustr2));
end);

# better \= for efficiency
InstallMethod(\=, [IsUnicodeString, IsUnicodeString], function(ustr1, ustr2)
  return IntListUnicodeString(ustr1) = IntListUnicodeString(ustr2);
end);

# better Position, PositionSublist
InstallMethod(Position, [IsUnicodeString, IsUnicodeCharacter],
function(ustr, c)
  return Position(IntListUnicodeString(ustr), c!.codepoint);
end);
InstallMethod(Position, [IsUnicodeString, IsUnicodeCharacter, IsInt],
function(ustr, c, pos)
  return Position(IntListUnicodeString(ustr), c!.codepoint, pos);
end);
InstallOtherMethod(PositionSublist, [IsUnicodeString, IsUnicodeString],
function(ustr, ustr2)
  return PositionSublist(IntListUnicodeString(ustr),
                                            IntListUnicodeString(ustr2));
end);
InstallMethod(PositionSublist, [IsUnicodeString, IsUnicodeString, IsInt],
function(ustr, ustr2, pos)
  return PositionSublist(IntListUnicodeString(ustr),
                                            IntListUnicodeString(ustr2), pos);
end);

##  <#GAPDoc Label="Encode">
##  <ManSection>
##  <Oper Name="Encode" Arg="ustr[, encoding]" />
##  <Returns>a &GAP; string</Returns>
##  <Func Name="SimplifiedUnicodeString" Arg='ustr[, encoding][, "single"]' />
##  <Returns>a unicode string</Returns>
##  <Func Name="LowercaseUnicodeString" Arg="ustr" />
##  <Returns>a unicode string</Returns>
##  <Func Name="UppercaseUnicodeString" Arg="ustr" />
##  <Returns>a unicode string</Returns>
##  <Var Name="LaTeXUnicodeTable" />
##  <Var Name="SimplifiedUnicodeTable" />
##  <Var Name="LowercaseUnicodeTable" />
##  
##  <Description>
##  The operation <Ref Oper="Encode"/> translates a unicode string <A>ustr</A>
##  into a &GAP; string in some specified <A>encoding</A>. The default
##  encoding is <C>"UTF-8"</C>. <P/>
##  
##  Supported encodings can be found in 
##  <C>UNICODE_RECODE.NormalizedEncodings</C>. Except for some cases
##  mentioned below characters which are not available in the target
##  encoding are substituted by '?' characters.<P/>
## 
##  If the <A>encoding</A> is <C>"URL"</C> (see <Ref Oper="Unicode"/>) then
##  an optional argument <A>encreserved</A> can be given, it must be a list
##  of reserved characters which should be percent encoded; the default is
##  to encode only the <C>%</C> character.<P/>
##  
##  The encoding <C>"LaTeX"</C>  substitutes 
##  non-ASCII characters and &LaTeX; special characters by &LaTeX; code 
##  as given in an ordered list 
##  <C>LaTeXUnicodeTable</C> of pairs [codepoint, string]. If you have a
##  unicode character for which no substitution is contained in that list,
##  you will get a warning and the translation is <C>Unicode(nr)</C>. 
##  In this case find a substitution and add a 
##  corresponding [codepoint, string] 
##  pair to  <C>LaTeXUnicodeTable</C> using <Ref BookName="reference"
##  Oper="AddSet"/>. Also, please, tell the &GAPDoc; authors about your 
##  addition, such that we can extend the list <C>LaTeXUnicodeTable</C>.
##  (Most of the initial entries were generated from lists in the
##  &TeX; projects enc&TeX; and <C>ucs</C>.)
##  There are some variants of this encoding:<P/>
##  <C>"LaTeXleavemarkup"</C> does
##  the same translations for non-ASCII characters but leaves the &LaTeX;
##  special characters (e.g., any &LaTeX; commands) as they are.<P/>
##  <C>"LaTeXUTF8"</C> does not give a warning about unicode characters
##  without explicit translation, instead it translates the character
##  to its <C>UTF-8</C> encoding. Make sure to setup your &LaTeX; document such
##  that all these characters are understood.<P/>
##  <C>"LaTeXUTF8leavemarkup"</C> is a combination of the last two variants.<P/>
##  
##  Note that the <C>"LaTeX"</C> encoding can only be used with <Ref
##  Oper="Encode"/> but not for the opposite translation with <Ref
##  Oper="Unicode" /> (which would need far too complicated heuristics).<P/>
##  
##  The  function  <Ref  Func="SimplifiedUnicodeString"/>  can  be  used  to
##  substitute  many  non-ASCII  characters   by  related  ASCII  characters
##  or  strings  (e.g.,  by  a  corresponding  character  without  accents).
##  The  argument  <A>ustr</A>  and  the  result  are  unicode  strings,  if
##  <A>encoding</A>  is <C>"ASCII"</C>  then  all  non-ASCII characters  are
##  translated,  otherwise only  the  non-latin1 characters.  If the  string
##  <C>"single"</C> in  an argument  then only substitutions  are considered
##  which don't make  the result string longer. The  translations are stored
##  in a sorted  list <C>SimplifiedUnicodeTable</C>. Its entries  are of the
##  form <C>[codepoint, trans1, trans2,  ...]</C>. Here <C>trans1</C> and so
##  on is either an integer for the codepoint of a substitution character or
##  it is  a list of  codepoint integers. If  you are missing  characters in
##  this list  and know a  sensible ASCII  approximation, then add  an entry
##  (with <Ref  BookName="reference" Oper="AddSet"/>) and tell  the &GAPDoc;
##  authors about it. (The  initial content of <C>SimplifiedUnicodeTable</C>
##  was mainly  generated from  the <Q><C>transtab</C></Q> tables  by Markus
##  Kuhn.)<P/>
##  
##  The function <Ref Func="LowercaseUnicodeString"/> gets and returns a 
##  unicode string and translates each uppercase character to its
##  corresponding lowercase version. This function uses a list 
##  <C>LowercaseUnicodeTable</C> of pairs of codepoint integers.
##  This list was generated using the file <F>UnicodeData.txt</F> from the
##  unicode definition (field 14 in each row).<P/>
##  
##  The function <Ref Func="UppercaseUnicodeString"/> does the similar
##  translation to uppercase characters.
##  
##  <Example>
##  gap> ustr := Unicode("a and &amp;#246;", "XML");
##  Unicode("a and \303\266")
##  gap> SimplifiedUnicodeString(ustr, "ASCII");
##  Unicode("a and oe")
##  gap> SimplifiedUnicodeString(ustr, "ASCII", "single");
##  Unicode("a and o")
##  gap> ustr2 := UppercaseUnicodeString(ustr);;
##  gap> Print(Encode(ustr2, GAPInfo.TermEncoding), "\n");
##  A AND Ö
##  </Example>
##  </Description>
##  </ManSection>
##  
##  <#/GAPDoc>
##  

# helper function for encoding a unicode character to UTF-8
UNICODE_RECODE.UTF8UnicodeChar := function(n)
  local res, a, b, c, d;
  res := "";
  if n < 0 then
    return fail;
  elif n < 128 then
    Add(res, CHAR_INT(n));
  elif n < 2048 then
    a := n mod 64;
    b := (n - a) / 64;
    Add(res, CHAR_INT(b + 192));
    Add(res, CHAR_INT(a + 128));
  elif n < 65536 then
    a := n mod 64;
    n := (n - a)/64;
    b := n mod 64;
    c := (n - b)/64;
    Add(res, CHAR_INT(c + 224));
    Add(res, CHAR_INT(b + 128));
    Add(res, CHAR_INT(a + 128));
  elif n < 2097152 then
    a := n mod 64;
    n := (n - a)/64;
    b := n mod 64;
    n := (n - b)/64;
    c := n mod 64;
    d := (n - c)/64;
    Add(res, CHAR_INT(d + 240));
    Add(res, CHAR_INT(c + 128));
    Add(res, CHAR_INT(b + 128));
    Add(res, CHAR_INT(a + 128));
  else
    return fail;
  fi;
  return res;
end;
# encode unicode string to GAP string in UTF-8 encoding
UNICODE_RECODE.Encoder.("UTF-8") := function(ustr)
  local res, f, n;
  res := "";
  f := UNICODE_RECODE.UTF8UnicodeChar;
  for n in IntListUnicodeString(ustr) do
    Append(res, f(n));
  od;
  return res;
end;
# non-ASCII characters to XML character entities
UNICODE_RECODE.Encoder.("XML") := function(ustr)
  local res, n;
  res := "";
  for n in IntListUnicodeString(ustr) do
    if n < 128 then
      Add(res, CHAR_INT(n));
    else
      Append(res, Concatenation("&#x", LowercaseString(HexStringInt(n)),";"));
    fi;
  od;
  return res;
end;

UNICODE_RECODE.RFC3986Unreserved := Set(List(
  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~", 
  INT_CHAR));
UNICODE_RECODE.RFC3986Reserved := Set(List("!*'();:@&=+$,/?%#[]", INT_CHAR));
UNICODE_RECODE.Encoder.("URL") := function(arg)
  local ustr, encreserved, res, s, i, j;
  ustr := arg[1];
  # also allow UTF-8 GAP string
  if not IsUnicodeString(ustr) then
    ustr := Unicode(ustr);
  fi;
  if Length(arg) > 1 then
    encreserved := arg[2];
  else
    encreserved := "%";
  fi;
  if IsString(encreserved) then
    encreserved := Set(List(encreserved, INT_CHAR));
  fi;
  res := "";
  for i in IntListUnicodeString(ustr) do
    if i in UNICODE_RECODE.RFC3986Unreserved then
      Add(res, CHAR_INT(i));
    elif i in UNICODE_RECODE.RFC3986Reserved and not i in encreserved then
      Add(res, CHAR_INT(i));
    elif i < 128 then
      Add(res, '%');
      if i < 16 then
        Add(res, '0');
      fi;
      Append(res, HexStringInt(i));
    else
      s := Encode(Unicode([i]), "UTF-8");
      for j in List(s, INT_CHAR) do
        Add(res, '%');
        Append(res, HexStringInt(j));
      od;
    fi;
  od;
  return res;
end;


# non-ASCII characters to LaTeX code, if known from LaTeXUnicodeTable
# args: unicodestring[, leavemarkup[, leaveutf8]]
UNICODE_RECODE.Encoder.("LaTeX") := function(arg)
  local ustr, leavemarkup, tt, res, pos, s, n, leaveutf8;
  ustr := arg[1];
  if Length(arg) > 1 then
    leavemarkup := arg[2];
  else
    leavemarkup := false;
  fi;
  if Length(arg) > 2 then
    leaveutf8 := arg[3];
  else
    leaveutf8 := false;
  fi;
  tt := LaTeXUnicodeTable;
  res := "";
  for n in IntListUnicodeString(ustr) do
    pos := Position([ 35, 36, 37, 38, 60, 62, 92, 94, 95, 123, 125, 126], n);
    if pos <> fail and not leavemarkup then
      Append(res, tt[pos][2]);
    elif n < 128 then
      Add(res, CHAR_INT(n));
    else
      pos := POSITION_FIRST_COMPONENT_SORTED(tt, n);
      if IsBound(tt[pos]) and tt[pos][1] = n then
        Append(res, tt[pos][2]);
      elif leaveutf8 = true then
        Append(res, UNICODE_RECODE.UTF8UnicodeChar(n));
      else
        s := Encode(Unicode([n]), GAPInfo.TermEncoding);
        Info(InfoWarning, 1, 
              "#W Missing LaTeX translation of unicode character ",
              String(n), ":", s, ",\nadd to LaTeXUnicodeTable\n");
        Append(res, Concatenation("Unicode(", String(n), ")"));
      fi;
    fi;
  od;
  return res;
end;
UNICODE_RECODE.NormalizedEncodings.LaTeX := "LaTeX";
UNICODE_RECODE.NormalizedEncodings.latex := "LaTeX";
UNICODE_RECODE.NormalizedEncodings.BibTeX := "LaTeX";

UNICODE_RECODE.Encoder.("LaTeXleavemarkup") := function(ustr)
  return UNICODE_RECODE.Encoder.("LaTeX")(ustr, true);
end;
UNICODE_RECODE.NormalizedEncodings.LaTeXleavemarkup := "LaTeXleavemarkup";
UNICODE_RECODE.NormalizedEncodings.latexleavemarkup := "LaTeXleavemarkup";
UNICODE_RECODE.NormalizedEncodings.BibTeXleavemarkup := "LaTeXleavemarkup";
UNICODE_RECODE.Encoder.("LaTeXUTF8leavemarkup") := function(ustr)
  return UNICODE_RECODE.Encoder.("LaTeX")(ustr, true, true);
end;
UNICODE_RECODE.NormalizedEncodings.LaTeXUTF8leavemarkup := "LaTeXUTF8leavemarkup";
UNICODE_RECODE.NormalizedEncodings.BibTeXUTF8leavemarkup := "LaTeXUTF8leavemarkup";
UNICODE_RECODE.Encoder.("LaTeXUTF8") := function(ustr)
  return UNICODE_RECODE.Encoder.("LaTeX")(ustr, false, true);
end;
UNICODE_RECODE.NormalizedEncodings.LaTeXUTF8 := "LaTeXUTF8";
UNICODE_RECODE.NormalizedEncodings.BibTeXUTF8:= "LaTeXUTF8";

InstallGlobalFunction(SimplifiedUnicodeString, function(arg)
  local ustr, single, max, tt, res, pos, a, f, n;
  ustr := arg[1];
  # at most single character substitutions?
  single := false;
  # maximal untouched character (255 for latin1 and 127 for ASCII)
  max := 255;
  if "single" in arg then
    single := true;
  fi;
  if "ascii" in arg or "ASCII" in arg or "ANSI_X3.4-1968" in arg then
    max := 127;
  fi;
  tt := SimplifiedUnicodeTable;
  res := [];
  for n in IntListUnicodeString(ustr) do
    if n <= max then
      Add(res, n);
    else
      pos := POSITION_FIRST_COMPONENT_SORTED(tt, n);
      if IsBound(tt[pos]) and tt[pos][1] = n then
        a := tt[pos];
        f := Filtered([2..Length(a)], i-> (IsInt(a[i]) and a[i] <= max)
             or (IsList(a[i]) and ForAll(a[i], j-> j <= max)));
        if single then
          f := Filtered(f, i-> IsInt(a[i]) or Length(a[i]) <= 1);
        fi;
        if Length(f) > 0 then
          a := a[f[1]];
          if IsInt(a) then
            Add(res, a);
          else
            Append(res, a);
          fi;
        else
          # &#63; is '?'
          Add(res, 63);
        fi;
      else
        Add(res, 63);
      fi;
    fi;
  od;
  return Unicode(res);
end);

InstallGlobalFunction(LowercaseUnicodeString, function(ustr)
  local res, tt, pos, i;
  res := ShallowCopy(IntListUnicodeString(ustr));
  tt := LowercaseUnicodeTable;
  for i in [1..Length(res)] do
    pos := POSITION_FIRST_COMPONENT_SORTED(tt, res[i]);
    if IsBound(tt[pos]) and tt[pos][1] = res[i] then
      res[i] := tt[pos][2];
    fi;
  od;
  return Unicode(res);
end);
InstallGlobalFunction(UppercaseUnicodeString, function(ustr)
  local res, UppercaseUnicodeTable, tt, pos, i;
  res := ShallowCopy(IntListUnicodeString(ustr));
  if not IsBound(UppercaseUnicodeTable) then
    UppercaseUnicodeTable := Set(List(LowercaseUnicodeTable, a-> [a[2],a[1]]));
  fi;
  tt := UppercaseUnicodeTable;
  for i in [1..Length(res)] do
    pos := POSITION_FIRST_COMPONENT_SORTED(tt, res[i]);
    if IsBound(tt[pos]) and tt[pos][1] = res[i] then
      res[i] := tt[pos][2];
    fi;
  od;
  return Unicode(res);
end);

# ISO-8859 cases, substitute '?' for unknown characters
UNICODE_RECODE.f := function()
  local nam, i;
  for i in Concatenation([1..11],[13..15]) do
    # 'nam' is a high variable for the Encoder function
    # that belongs to the main thread, but must be accessible
    # by all threads.
    nam := MakeImmutable(Concatenation("ISO-8859-", String(i)));
    UNICODE_RECODE.Encoder.(nam) := function(ustr)
      local t, s, res, pos, c;
      if not IsBound(UNICODE_RECODE.TABLES.reverse.(nam)) then
        t := [0..255];
        s := ShallowCopy(UNICODE_RECODE.TABLES.(nam));
        SortParallel(s, t);
        UNICODE_RECODE.TABLES.reverse.(nam) := [s, t];
      fi;
      t := UNICODE_RECODE.TABLES.reverse.(nam);
      res := [];
      for c in IntListUnicodeString(ustr) do
        if c < 160 then
          Add(res, c);
        else
          pos := PositionSorted(t[1], c);
          if pos = fail then
            Add(res, 63); # '?'
          else
            Add(res, t[2][pos]);
          fi;
        fi;
      od;
      return STRING_SINTLIST(res);
    end;
  od;
end;
UNICODE_RECODE.f();
Unbind(UNICODE_RECODE.f);
UNICODE_RECODE.Encoder.("ANSI_X3.4-1968") := function(ustr)
  local res;
  res := List(IntListUnicodeString(ustr), function(i) 
    if i < 128 then return i; else return 63; fi; end);
  return STRING_SINTLIST(res);
end;
  
InstallMethod(Encode, [IsUnicodeString, IsString], function(ustr, enc)
  if not IsBound(UNICODE_RECODE.NormalizedEncodings.(enc)) then
    Error("Sorry, only the following encodings are supported for Encode:\n",
                    RecFields(UNICODE_RECODE.Encoder), "\n");
  fi;
  enc := UNICODE_RECODE.NormalizedEncodings.(enc);
  return UNICODE_RECODE.Encoder.(enc)(ustr);
end);
# generic dispatcher for encoding depending on extra data (e.g. used with "URL"
InstallOtherMethod(Encode, [IsUnicodeString, IsString, IsObject], 
function(ustr, enc, data)
  if not IsBound(UNICODE_RECODE.NormalizedEncodings.(enc)) then
    Error("Sorry, only the following encodings are supported for Encode:\n",
                    RecFields(UNICODE_RECODE.Encoder), "\n");
  fi;
  enc := UNICODE_RECODE.NormalizedEncodings.(enc);
  return UNICODE_RECODE.Encoder.(enc)(ustr, data);
end);

# here the default is UTF-8 encoding
InstallMethod(Encode, [IsUnicodeString], function(ustr)
  return UNICODE_RECODE.Encoder.("UTF-8")(ustr);
end);

##  <#GAPDoc Label="WidthUTF8String">
##  <ManSection >
##  <Heading>Lengths of UTF-8 strings</Heading>
##  <Func Arg="str" Name="WidthUTF8String" />
##  <Func Arg="str" Name="NrCharsUTF8String" />
##  <Returns>an integer</Returns>
##  <Description>
##  Let <A>str</A> be a &GAP; string  with text in UTF-8 encoding. There are
##  three <Q>lengths</Q> of  such a string which must  be distinguished. The
##  operation <Ref BookName="reference" Oper="Length"/> returns the number of
##  bytes  and so  the  memory  occupied by  <A>str</A>.  The function  <Ref
##  Func="NrCharsUTF8String"/> returns the number of unicode  characters  in
##  <A>str</A>, that is the length of <C>Unicode(<A>str</A>)</C>. <P/>
##  
##  In many applications the  function <Ref Func="WidthUTF8String"/> is more
##  interesting, it  returns the number of  columns needed by the  string if
##  printed  to  a terminal.  This  takes  into  account that  some  unicode
##  characters are combining  characters and that there  are wide characters
##  which need two columns (e.g., for  Chinese or Japanese). (To be precise:
##  This  implementation assumes  that there  are no  control characters  in
##  <A>str</A> and uses  the character width returned  by the <C>wcwidth</C>
##  function in the GNU C-library called with UTF-8 locale.)
##  <Example>
##  gap> # A, German umlaut u, B, zero width space, C, newline
##  gap> str := Encode( Unicode( "A&amp;#xFC;B&amp;#x200B;C\n", "XML" ) );;
##  gap> Print(str);
##  AüB​C
##  gap> # umlaut u needs two bytes and the zero width space three
##  gap> Length(str);
##  9
##  gap> NrCharsUTF8String(str);
##  6
##  gap> # zero width space and newline don't contribute to width
##  gap> WidthUTF8String(str);
##  4
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
InstallGlobalFunction(NrCharsUTF8String, function(str)
  local n, nc, c;
  n := 0;
  for c in str do
    nc := INT_CHAR(c);
    if nc < 128 or nc > 191 then
      n := n+1;
    fi;
  od;
  return n;
end);

InstallGlobalFunction(WidthUTF8String, function(str)
  local res, pos, i;
  if not IsUnicodeString(str) then
    str := Unicode(str, "UTF-8");
  fi;
  str := IntListUnicodeString(str);
  res := 0;
  for i in str do
    if i > 31 and i < 127 then
      res := res+1;
    else
      pos := POSITION_FIRST_COMPONENT_SORTED(WidthUnicodeTable, i);
      if not IsBound(WidthUnicodeTable[pos]) or WidthUnicodeTable[pos][1] <> i
          then
        pos := pos-1;
      fi;
      res := res + WidthUnicodeTable[pos][2];
    fi;
  od;
  return res;
end);


# Not (yet?) documented utility to translate a latin1 or UTF-8 encoded
# GAP string to a string with lowercase ASCII characters. Can be used for 
# sorting and searching, allowing some freedom for the input of non-ASCII
# characters.
InstallGlobalFunction(LowerASCIIString, function(str)
  local u;
  # heuristic to distinguish UTF-8 and latin1
  u := Unicode(str);
  if u = fail then
    u := Unicode(str, "latin1");
  fi;
  u := SimplifiedUnicodeString(u, "ASCII");
  u := LowercaseUnicodeString(u);
  return Encode(u);
end);

# overwrite library method if sensible depending on term encoding and
# encoding of string
InstallMethod(ViewObj, "IsString", true, [IsString and IsFinite],0,
function(s)
  local u, c;
  u := Unicode(s, GAPInfo.TermEncoding);
  if u <> fail then
    Print("\"");
    u := IntListUnicodeString(u);
    for c in u do
      if c = 34 then
        Print("\\\"");
      elif c = 92 then
        Print("\\\\");
      elif c < 32 then
        Print(SPECIAL_CHARS_VIEW_STRING[2][c+1]);
      else
        Print(Encode(Unicode([c]), GAPInfo.TermEncoding));
      fi;
    od;
    Print("\"");
  else
    PrintObj(s);
  fi;
end);

MakeThreadLocal("UNICODE_RECODE");

