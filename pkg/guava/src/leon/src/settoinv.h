/* Optimized macro to set one point list to the inverse of another.
   Two temporary variable of type Unsigned*, followed by three of type
   Unsigned, are required.  The first three of the five temporary variables
   are good candidates for register variables.  */

#define SET_TO_INVERSE( pointList, invPointList, listSize, \
                        ptr, invPtr, index, bound, pBound)  \
   ptr = pointList;  \
   invPtr = invPointList;  \
   index = 1;  \
   bound = listSize;  \
   pBound = (bound > 9 ) ? (bound - 9) : 0;  \
   while( index <= pBound ) {  \
      invPtr[ptr[index]] = index; ++index;  \
      invPtr[ptr[index]] = index; ++index;  \
      invPtr[ptr[index]] = index; ++index;  \
      invPtr[ptr[index]] = index; ++index;  \
      invPtr[ptr[index]] = index; ++index;  \
      invPtr[ptr[index]] = index; ++index;  \
      invPtr[ptr[index]] = index; ++index;  \
      invPtr[ptr[index]] = index; ++index;  \
      invPtr[ptr[index]] = index; ++index;  \
      invPtr[ptr[index]] = index; ++index;  \
   }  \
   while ( index <= bound ) {  \
      invPtr[ptr[index]] = index; ++index;  \
   }
