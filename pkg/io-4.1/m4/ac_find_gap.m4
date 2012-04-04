# Find the location of GAP
# Sets GAPROOT, GAPARCH and GAP_CPPFLAGS appropriately
# Can be configured using --with-gaproot=... and --with-configname=...
#######################################################################

AC_DEFUN([AC_FIND_GAP],
[
  AC_LANG_PUSH([C])
  
  # Make sure CDPATH is portably set to a sensible value
  CDPATH=${ZSH_VERSION+.}:

  GAP_CPPFLAGS=""

  #Allow the user to specify a configname:
  AC_MSG_CHECKING([for CONFIGNAME])
  AC_ARG_VAR(CONFIGNAME, [Set this to the CONFIGNAME of the GAP compilation
    against which you want to compile this package. Leave this
    variable empty for GAP versions < 4.5.])
  if test "x$CONFIGNAME" = "x"; then
    SYSINFO="sysinfo.gap"
    AC_MSG_RESULT([none])
  else
    SYSINFO="sysinfo.gap-$CONFIGNAME"
    AC_MSG_RESULT([$CONFIGNAME])
  fi

  ######################################
  # Find the GAP root directory by 
  # checking for the sysinfo.gap file 
  AC_MSG_CHECKING([for GAP root directory])
  DEFAULT_GAPROOTS="../.."
  
  #Allow the user to specify the location of GAP
  #
  AC_ARG_WITH(gaproot, 
    [AC_HELP_STRING([--with-gaproot=<path>], [specify root of GAP installation])],
    [DEFAULT_GAPROOTS="$withval"])
  
  havesysinfo=0
  # Otherwise try likely directories
  for GAPROOT in ${DEFAULT_GAPROOTS} 
  do
    # Convert the path to absolute
    GAPROOT=`cd $GAPROOT > /dev/null 2>&1 && pwd`
    if test -e ${GAPROOT}/${SYSINFO}; then
      havesysinfo=1
      break
    fi
  done
    
  if test "x$havesysinfo" = "x1"; then
    AC_MSG_RESULT([${GAPROOT}])
  else
    AC_MSG_RESULT([Not found])
    
    echo ""
    echo "********************************************************************"
    echo "  ERROR"
    echo ""
    echo "  Cannot find your GAP installation. Please specify the location of"
    echo "  GAP's root directory using --with-gaproot=<path>"
    echo ""
    echo "  The GAP root directory (as far as this package is concerned) is"
    echo "  the one containing the file sysinfo.gap and the subdirectories "
    echo "  src/ and bin/."
    echo "********************************************************************"
    echo ""
    
    AC_MSG_ERROR([Unable to find GAP root directory])
  fi
        
  #####################################
  # Now find the architecture
        
  AC_MSG_CHECKING([for GAP architecture])
  GAPARCH="Unknown"
  source $GAPROOT/$SYSINFO
  if test "x$GAParch" != "x"; then
    GAPARCH=$GAParch
  fi

  AC_ARG_WITH(gaparch, 
    [AC_HELP_STRING([--with-gaparch=<path>], [override GAP architecture string])],
    [GAPARCH=$withval])
  AC_MSG_RESULT([${GAPARCH}])
 
  if test "x$GAPARCH" = "xUnknown" -o ! -d $GAPROOT/bin/$GAPARCH ; then
    echo ""
    echo "********************************************************************"
    echo "  ERROR"
    echo ""
    echo "  Found a GAP installation at $GAPROOT but could not find"
    echo "  information about GAP's architecture in the"
    echo "  file ${GAPROOT}/${SYSINFO} or did not find the directory"
    echo "  ${GAPROOT}/bin/${GAPARCH}."
    echo "  This file and directory should be present: please check your"
    echo "  GAP installation."
    echo "********************************************************************"
    echo ""
    
    AC_MSG_ERROR([Unable to find plausible GAParch information.])
  fi  
  
  
  #####################################
  # Now check for the GAP header files

  bad=0
  AC_MSG_CHECKING([for GAP include files])
  if test -r $GAPROOT/src/compiled.h; then
    AC_MSG_RESULT([$GAPROOT/src/compiled.h])
  else
    AC_MSG_RESULT([Not found])
    bad=1
  fi
  AC_MSG_CHECKING([for GAP config.h])
  if test -r $GAPROOT/bin/$GAPARCH/config.h; then
    AC_MSG_RESULT([$GAPROOT/bin/$GAPARCH/config.h])
  else
    AC_MSG_RESULT([Not found])
    bad=1
  fi

  if test "x$bad" = "x1"; then
    echo ""
    echo "********************************************************************"
    echo "  ERROR"
    echo ""
    echo "  Failed to find the GAP source header files in src/ and"
    echo "  GAP's config.h in the architecture dependend directory"
    echo ""
    echo "  The kernel build process expects to find the normal GAP "
    echo "  root directory structure as it is after building GAP itself, and"
    echo "  in particular the files"
    echo "      <gaproot>/sysinfo.gap"
    echo "      <gaproot>/src/<includes>"
    echo "  and <gaproot>/bin/<architecture>/bin/config.h." 
    echo "  Please make sure that your GAP root directory structure"
    echo "  conforms to this layout, or give the correct GAP root using"
    echo "  --with-gaproot=<path>"
    echo "********************************************************************"
    echo ""
    AC_MSG_ERROR([Unable to find GAP include files in /src subdirectory])
  fi
  
  ARCHPATH=$GAPROOT/bin/$GAPARCH
  GAP_CPPFLAGS="-I$GAPROOT -I$ARCHPATH"

  AC_MSG_CHECKING([for GAP's gmp.h location])
  if test -r "$ARCHPATH/extern/gmp/include/gmp.h"; then
    GAP_CPPFLAGS="$GAP_CPPFLAGS -I$ARCHPATH/extern/gmp/include"
    AC_MSG_RESULT([$ARCHPATH/extern/gmp/include/gmp.h])
  else
    AC_MSG_RESULT([not found, GAP was compiled without GMP])
  fi;
 
  AC_SUBST(GAPARCH)
  AC_SUBST(GAPROOT)
  AC_SUBST(GAP_CPPFLAGS)

  AC_LANG_POP([C])
])
