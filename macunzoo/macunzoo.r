/****************************************************************************
**
*W  macunzoo.r                                              Burkhard Hoefling
**
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
*/
#include <Types.r>   /*BH: inserted #include */
#include <SysTypes.r>   /*BH: inserted #include */
#include <FileTypesAndCreators.r>   /*BH: inserted #include */

#include "macunzoo.h"

resource 'open' (128) {
	MACUNZOOCREATOR, {'BINA', '****', '????'}
};


resource 'kind' (128)
{
   MACUNZOOCREATOR,
   verUS,
   {
      ftApplicationName,      "unzoo",
      'BINA',                 "unzoo binary file"
   }
};


resource 'vers' (1) {
	16*(MAJORVER/10)+MAJORVER%10,
	16*(MINORVER/10)+MINORVER%10,
	RELEASESTATE,
	16*(RELEASE/10)+RELEASE%10,
	verUS,
	MACUNZOOSHORTVERS,
	MACUNZOOVERS" © Dept. of Maths, University of St. Andrews"
};

resource 'vers' (2) {
	16*(MAJORVER/10)+MAJORVER%10,
	16*(MINORVER/10)+MINORVER%10,
	RELEASESTATE,
	16*(RELEASE/10)+RELEASE%10,
	verUS,
    MACUNZOOSHORTVERS,
	"A simple extractor for zoo archives."
};
