#!/usr/bin/env bash

# This script attempts to build all GAP packages contained in the current
# directory. Normally, you should run this script from the 'pkg'
# subdirectory of your GAP installation.

# You can also run it from other locations, but then you need to tell the
# script where your GAP root directory is, by passing it as first argument
# to the script with '--with-gaproot='. By default, the script assumes that
# the parent of the current working directory is the GAP root directory.

# If arguments are added, then they are considered packages. In that case
# only these packages will be built, and all others are ignored.

# You need at least 'gzip', GNU 'tar', a C compiler, sed, pdftex to run this.
# Some packages also need a C++ compiler.

# Contact support@gap-system.org for questions and complaints.

# Note, that this isn't and is not intended to be a sophisticated script.
# Even if it doesn't work completely automatically for you, you may get
# an idea what to do for a complete installation of GAP.

set -e

# Is someone trying to run us from inside the 'bin' directory?
if [[ -f gapicon.bmp ]]
then
  error "This script must be run from inside the pkg directory" \
        "Type: cd ../pkg; ../bin/BuildPackages.sh"
fi

CURDIR="$(pwd)"
GAPROOT="$(cd .. && pwd)"
COLORS=yes
PACKAGES=

# If output does not go into a terminal (but rather into a log file),
# turn of colors.
[[ -t 1 ]] || COLORS=no

while [[ "$#" -ge 1 ]]; do
  option="$1" ; shift
  case "$option" in
    --with-gaproot)   GAPROOT="$1"; shift ;;
    --with-gaproot=*) GAPROOT=${option#--with-gaproot=}; shift ;;
    --no-color)       COLORS=no ;;
    -*)               echo "ERROR: unsupported argument $option" ; exit 1;;
    *)                PACKAGES="$PACKAGES $option" ;;
  esac
done

# packages to build
if [[ -z "$PACKAGES" ]]
then
  PACKAGES="$(find . -maxdepth 2 -type f -name PackageInfo.g  | xargs -n 1 dirname)"
fi

# user  messages
if [[ "x$COLORS" = xyes ]]
then
  # print notices in green, warnings in yellow, errors in read
  notice()    { printf "\033[32m%s\033[0m\n" "$@" ; }
  warning()   { printf "\033[33mWARNING: %s\033[0m\n" "$@" ; }
  error()     { printf "\033[31mERROR: %s\033[0m\n" "$@" ; exit 1 ; }
  std_error() { printf "\033[31m%s\033[0m\n" "$@" ; }
else
  notice()    { printf "%s\n" "$@" ; }
  warning()   { printf "WARNING: %s\n" "$@" ; }
  error()     { printf "ERROR: %s\n" "$@" ; exit 1 ; }
  std_error() { printf "%s\n" "$@" ; }
fi


notice "Using GAP root $GAPROOT"

# test if $GAPROOT is valid
if [[ ! -f "$GAPROOT/sysinfo.gap" ]]
then
  error "$GAPROOT is not the root of a gap installation (no sysinfo.gap)" \
        "Please provide the absolute path of your GAP root directory as" \
        "first argument with '--with-gaproot=' to this script."
fi

if [[ "$(grep -c 'ABI_CFLAGS=-m32' $GAPROOT/Makefile)" -ge 1 ]]
then
  notice "Building with 32-bit ABI"
  ABI32=YES
  CONFIGFLAGS="CFLAGS=-m32 LDFLAGS=-m32 LOPTS=-m32 CXXFLAGS=-m32"
fi


LOGDIR=log
mkdir -p "$LOGDIR"


# Many package require GNU make. So use gmake if available,
# for improved compatibility with *BSD systems where "make"
# is BSD make, not GNU make.
if hash gmake 2> /dev/null
then
  MAKE=gmake
else
  MAKE=make
fi

notice \
"Attempting to build GAP packages." \
"Note that many GAP packages require extra programs to be installed," \
"and some are quite difficult to build. Please read the documentation for" \
"packages which fail to build correctly, and only worry about packages" \
"you require!"

echo_run() {
  notice "Running $(printf "'%s' " "$@")"
  eval "$@"
}

build_carat() {
(
# TODO: FIX Carat
# Installation of Carat produces a lot of data, maybe you want to leave
# this out until a user complains.
# It is not possible to move around compiled binaries because these have the
# path to some data files burned in.
zcat carat-2.1b1.tgz | tar pxf -
# If the symbolic link does not exist then create it.
# Does not check if bin exists already with some content or as a file, etc.
# Thus this code is unstable, but should be corrected by package author
# and not by this script.
if [[ ! -L ./bin ]]
then
  ln -s ./carat-2.1b1/bin ./bin
fi
cd carat-2.1b1
make TOPDIR="$(pwd)"
chmod -R a+rX .
cd bin
# This sets GAParch as it should be.
# Alternatively, one could check $GAPROOT/bin for all directories instead.
source "$GAPROOT/sysinfo.gap"
# If the symbolic link does not exist then create it.
if [[ ! -L "$GAParch" ]]
then
  shopt -s nullglob
  # We assume that there is only one appropriate directory....
  for archdir in *
  do
    if [[ -d "$archdir" && ! -L "$archdir" ]]
    then
      ln -s ./"$archdir" ./"$GAParch"
    fi
  done
  shopt -u nullglob
fi
)
}

build_fail() {
  echo ""
  warning "Failed to build $PKG"
  echo "$PKG" >> "$LOGDIR/fail.log"
}

run_configure_and_make() {
  # We want to know if this is an autoconf configure script
  # or not, without actually executing it!
  if [[ -f autogen.sh && ! -f configure ]]
  then
    ./autogen.sh
  fi
  if [[ -f "configure" ]]
  then
    if grep Autoconf ./configure > /dev/null
    then
      echo_run ./configure --with-gaproot="$GAPROOT" $CONFIGFLAGS
    else
      echo_run ./configure "$GAPROOT"
    fi
    echo_run "$MAKE"
  else
    notice "No building required for $PKG"
  fi
}

build_one_package() {
  # requires one argument which is the package directory
  PKG="$1"
  echo ""
  date
  echo ""
  notice "==== Checking $PKG"
  (  # start subshell
  set -e
  cd "$CURDIR/$PKG"
  case "$PKG" in
    # All but the last lines should end by '&&', otherwise (for some reason)
    # some packages that fail to build will not get reported in the logs.
    anupq*)
      echo_run ./configure CFLAGS=-m32 LDFLAGS=-m32 --with-gaproot=$GAPROOT && \
      echo_run "$MAKE" CFLAGS=-m32 LOPTS=-m32
    ;;

    atlasrep*)
      chmod 1777 datagens dataword
    ;;

    carat*)
      build_carat
    ;;

    fplsa*)
      echo_run ./configure "$GAPROOT" && \
      echo_run "$MAKE" CC="gcc -O2 "
    ;;

    kbmag*)
      echo_run ./configure "$GAPROOT" && \
      echo_run "$MAKE" COPTS="-O2 -g"
    ;;

    NormalizInterface*)
      ./build-normaliz.sh "$GAPROOT" && \
      run_configure_and_make
    ;;

    pargap*)
      echo_run ./configure --with-gap="$GAPROOT" && \
      echo_run "$MAKE" && \
      cp bin/pargap.sh "$GAPROOT/bin" && \
      rm -f ALLPKG
    ;;

    xgap*)
      echo_run ./configure --with-gaproot="$GAPROOT" && \
      echo_run "$MAKE" && \
      rm -f "$GAPROOT/bin/xgap.sh" && \
      cp bin/xgap.sh "$GAPROOT/bin"
    ;;

    simpcomp*)
    ;;

    *)
      run_configure_and_make
    ;;
  esac
  ) || build_fail
}

date >> "$LOGDIR/fail.log"
for PKG in ${PACKAGES}
do
  # cut off the ending slash (if exists)
  PKG="${PKG%/}"
  # cut off everything before the first slash to only keep the package name
  # (these two commands are mainly to accomodate the logs better,
  # as they make no difference with changing directories)
  PKG="${PKG##*/}"
  if [[ -e "$CURDIR/$PKG/PackageInfo.g" ]]
  then
    (build_one_package "$PKG" \
     > >(tee "$LOGDIR/$PKG.out") \
    2> >(while read line
         do \
           std_error "$line"
         done \
         > >(tee "$LOGDIR/$PKG.err" >&2) \
         ) \
    )> >(tee "$LOGDIR/$PKG.log" ) 2>&1

    # remove superfluous log files if there was no error message
    if [[ ! -s "$LOGDIR/$PKG.err" ]]
    then
      rm -f "$LOGDIR/$PKG.err"
      rm -f "$LOGDIR/$PKG.out"
    fi

    # remove log files if package needed no compilation
    if [[ "$(grep -c 'No building required for' $LOGDIR/$PKG.log)" -ge 1 ]]
    then
      rm -f "$LOGDIR/$PKG.err"
      rm -f "$LOGDIR/$PKG.out"
      rm -f "$LOGDIR/$PKG.log"
    fi
  else
    echo
    warning "$PKG does not seem to be a package directory, skipping"
  fi
done

echo "" >> "$LOGDIR/fail.log"
echo ""
notice "Packages failed to build are in ./$LOGDIR/fail.log"
