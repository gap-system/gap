#############################################################################
##
#W    lib.gi               The GenSift package                Max Neunhoeffer
##                                                             Cheryl Praeger
##                                                            Csaba Schneider
##
##    @(#)$Id: lib.gi,v 1.3 2009/07/25 22:15:26 gap Exp $
##
##  This file contains some basic things used in other files.
##

# A helper for floating point numbers:

if not(IsBound(MACFLOAT_INT)) then
    MACFLOAT_INT := FLOAT_INT;
    LOG_MACFLOAT := LOG_FLOAT;
    EXP_MACFLOAT := EXP_FLOAT;
    IS_MACFLOAT := IS_FLOAT;
fi;

InstallGlobalFunction(FLOAT_RAT,function(r)
  local a,b;
  a := MACFLOAT_INT(NumeratorRat(r));
  b := MACFLOAT_INT(DenominatorRat(r));
  if a = fail or b = MACFLOAT_INT(0) then
      return infinity;
  elif b = fail then
      return MACFLOAT_INT(0);
  else
      return a/b;
  fi;
end);

# By default, we write out some info:
SetInfoLevel(InfoGenSift,2);

# Switch the following to 1 if you want to see the generalized sift working:
SIFT_VERBOSITY := 0;

# The place where we collect internal functions:
# This record will be filled with functions, note that lib.gi is read first!
InstallValue( GenSift, rec() );

