/****************************************************************************
**
*W  macheaders.h                GAP source                  Burkhard Hoefling
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
**  This file is part of the GAP source code for Apple Macintosh. It contains 
**  the declarations which must be included in every GAP source file. The 
**  declarations intended only for the Mac-specific files should go into
**  macdefs.h.
*/
#define SYS_IS_MAC_MWC 1
#define OLDROUTINENAMES 0
#define OLDROUTINELOCATIONS 0
#define SYS_HAS_STRING_PROTO 1

#ifdef __MWERKS__
# ifdef powerc
#  define SYS_ARCH "PPC-motorola-macos-mwerksc"
#  define SYS_HAS_STACK_ALIGN 4
# else
#  define SYS_ARCH "MC68020-motorola-macos-mwerksc"
#  define SYS_HAS_STACK_ALIGN 2
# endif
#endif

#define GAPVER 4

#define SYS_HAS_SIGNALS 1
#define WORDS_BIGENDIAN 1

#pragma export on

#undef DEBUG_MASTERPOINTERS
#undef DEBUG_DEADSONS_BAGS

