/* File bitmanp.c.  Declares two unsigned long arrays useful for bit
   manipulation, as follows:

      bitSetAt:     For i = 0,1,...,31, bitSetAt[i] has 1 in bit i and 0
                    elsewhere.
      bitSetBelow:  For i = 0,1,...,32, bitSetBelow[i] has 1 in bits
                    0,1,...,i-1 and 0 elsewhere. */

#include "group.h"

CHECK( bitman)

unsigned long bitSetAt[32] =
     {1, 2, 4, 8, 16, 32, 64, 128,
      256, 512, 1024, 2048, 4096, 8192, 16384, 32768,
      65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608,
      16777216, 33554432, 67108864, 134217728,
      268435456, 536870912, 1073741824, 0x80000000};

unsigned long bitSetBelow[33] =
      {0, 1, 3, 7, 15, 31, 63, 127,
      255, 511, 1023, 2047, 4095, 8191, 16383, 32767,
      65535, 131071, 262143, 524287, 1048575, 2097151, 4194303, 8388607,
      16777215, 33554431, 67108863, 134217727,
      268435455, 536870911, 1073741823, 2147483647, 0xffffffff};

