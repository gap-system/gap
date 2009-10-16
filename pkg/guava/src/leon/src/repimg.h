/* Optimized macro to apply a permutation perm to a list pointList of points of
   size listSize.  Four temporary variables of type Unsigned* must be
   supplied:  tImage, ptPtr, breakPtr, and endList.  The first two (especially
   the second) are good candidates for register variables.  */

#define REPLACE_BY_IMAGE( pointList, perm, listSize,  \
                          tImage, ptPtr, breakPtr, endList)  \
   tImage = perm->image;  \
   endList = pointList + listSize;  \
   breakPtr = (listSize >= 10) ? (endList - 9) : pointList;  \
   ptPtr = pointList+1;  \
   while( ptPtr <= breakPtr ) {  \
      *ptPtr = tImage[*ptPtr];  \
      ++ptPtr;  \
      *ptPtr = tImage[*ptPtr];  \
      ++ptPtr;  \
      *ptPtr = tImage[*ptPtr];  \
      ++ptPtr;  \
      *ptPtr = tImage[*ptPtr];  \
      ++ptPtr;   \
      *ptPtr = tImage[*ptPtr];  \
      ++ptPtr;  \
      *ptPtr = tImage[*ptPtr];  \
      ++ptPtr;  \
      *ptPtr = tImage[*ptPtr];  \
      ++ptPtr;  \
      *ptPtr = tImage[*ptPtr];  \
      ++ptPtr;  \
   }  \
   while ( ptPtr <= endList ) {  \
      *ptPtr = tImage[*ptPtr];  \
      ++ptPtr;  \
   }
