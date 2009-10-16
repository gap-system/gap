/****************************************************************************
**
*W  gap_tokens.h            OM Package 									Andrew Solomon
**
*H  @(#)$Id: gap_tokens.h,v 1.2 2006/01/22 19:11:20 gap Exp $
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
**  This file defines the tokens which are passed from the C parser
**  gpipe into the GAP parser which reads OpenMath objects from a stream.
**  As such it is not only included in the file src/gpipe.c but also
**  read in at package load by the GAP function OMDefineTokens 
**  which binds each of the token names to its value. 
**
**  NB Lines defining token values must begin with "gap".
**  
*/

#ifndef _GAP_TOKENS_
#define _GAP_TOKENS_ 0

typedef enum gapOMtokenType {

gapOMtokenDelimiter = 255,
gapOMtokenInteger = 2,
gapOMtokenFloat = 3,
gapOMtokenByteArray = 4,
gapOMtokenVar = 5,
gapOMtokenString = 6,
gapOMtokenWCString = 7,
gapOMtokenSymbol = 8,
gapOMtokenComment = 15,
gapOMtokenApp = 16,
gapOMtokenEndApp = 17,
gapOMtokenAttr = 18,
gapOMtokenEndAttr = 19,
gapOMtokenAtp = 20,
gapOMtokenEndAtp = 21,
gapOMtokenError = 22,
gapOMtokenEndError = 23,
gapOMtokenObject = 24,
gapOMtokenEndObject = 25,
gapOMtokenBind = 26,
gapOMtokenEndBind = 27,
gapOMtokenBVar = 28,
gapOMtokenEndBVar = 29

} gapOMtokenType;

#endif
