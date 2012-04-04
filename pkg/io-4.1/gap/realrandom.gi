#############################################################################
##
##  realrandom.gi           IO package 
##                                                        by Max Neunhoeffer
##
##  Copyright (C) 2006-2010 by Max Neunhoeffer
##  This file is free software, see license information at the end.
##
##  Code for "real" random sources using /dev/random
##
#############################################################################

InstallMethod( Init, "for a real random source", 
  [IsRealRandomSource,IsString], 1,
  function( r, type )
    local f;
    if type <> "random" and type <> "urandom" then 
        Error("seed must be \"random\" or \"urandom\"");
    fi;
    if type = "random" then
        f := IO_File("/dev/random",128);  # Use smaller buffer size
    else
        f := IO_File("/dev/urandom",1024);  # Use medium buffer size
    fi; 
    if f = fail then return fail; fi;
    r!.file := f;
    r!.type := type;
    return r;
  end );

InstallMethod( State, "for a real random source",
  [IsRealRandomSource],
  function(r)
    return fail;
  end );

InstallMethod( Reset, "for a real random source",
  [IsRealRandomSource],
  function(r)
    return;
  end );

InstallMethod( Reset, "for a real random source and an object",
  [IsRealRandomSource,IsObject],
  function(r,o)
    return;
  end );

InstallMethod( Random, "for a real random source and two integers",
  [ IsRealRandomSource, IsInt, IsInt ],
  function( r, f, t )
    local c,d,h,i,l,q,s;
    d := t-f;   # we need d+1 different outcomes from [0..d]
    if d <= 0 then return fail; fi;
    l := (Log2Int(d)+1);      # now 2^l >= d
    l := (l+7) - (l+7) mod 8; # this rounds up to a multiple of 8, still 2^l>=d
    q := QuoInt(2^l,d+1);     # now q*(d+1) <= 2^l < (q+1)*(d+1)
                              # thus for 0 <= x   < 2^l
                              # we have  0 <= x/q <= d+1 <= 2^l/q
                              # Thus if we do QuoInt(x,q) we get something
                              # between 0 and d inclusively, and if x is
                              # evenly distributed in [0..2^l-1], all values
                              # between 0 and d occur equally often
    repeat
        s := IO_ReadBlock(r!.file,l/8); # note that l is divisible by 8
        h := "";
        for c in s do Append(h,HexStringInt(INT_CHAR(c))); od;
        i := IntHexString(h);  # this is now between 0 and 2^l-1 inclusively
        i := QuoInt(i,q);
    until i <= d;
    return f+i;
  end );

InstallMethod( Random, "for a real random source and a list",
  [ IsRealRandomSource, IsList ],
  function( r, l )
    local nr;
    repeat
        nr := Random(r,1,Length(l));
    until IsBound(l[nr]);
    return l[nr];
  end );

InstallMethod( ViewObj, "for a real random source",
  [IsRealRandomSource],
  function(rs)
    Print("<a real random source>");
  end );

InstallMethod( IO_Pickle, "for a real random source",
  [IsFile, IsRealRandomSource],
  function(f,rs)
    if IO_Write(f,"RSRE") = fail then return IO_Error; fi;
    if IO_Pickle(f,rs!.type) = IO_Error then return IO_Error; fi;
    return IO_OK;
  end );

IO_Unpicklers.RSRE := function(f)
  local t;
  t := IO_Unpickle(f);
  if t = IO_Error then return IO_Error; fi;
  return RandomSource(IsRealRandomSource,t);
end;


##
##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation, either version 3 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program.  If not, see <http://www.gnu.org/licenses/>.
##
