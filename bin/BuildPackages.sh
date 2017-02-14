#!/usr/bin/env bash

# This script attempts to build all GAP packages contained in the current
# directory. Normally, you should run this script from the 'pkg'
# subdirectory of your GAP installation.

# You can also run it from other locations, but then you need to tell the
# script where your GAP root directory is, by passing it as an argument
# to the script with '--with-gaproot='. By default, the script assumes that
# the parent of the current working directory is the GAP root directory.

# By default the script colors its output, even in the log files. One can
# turn it off by adding the argument '--no-color'.

# By default the logs are created into the './log' directory. This directory
# can be changed by the argument '--with-logdir='.

# By default the name of the main log file is 'buildpackages'. This filename
# can be changed by the argument '--with-logfile='. Three files are created:
# - one with .out extension containing the stdout output,
# - one with .err extension containing the stderr output,
# - one with .log extension containing the stdout and stderr together.

# By default the packages failed to build are collected into the file named
# 'fail'. This filename can be changed by the argument '--with-failpkgfile='.

# If further arguments are added, then they are considered packages. In that
# case only these packages will be built, and all others are ignored.

# You need at least 'gzip', GNU 'tar', a C compiler, sed, pdftex to run this.
# Some packages also need a C++ compiler.

# Contact support@gap-system.org for questions and complaints.

# Note, that this isn't and is not intended to be a sophisticated script.
# Even if it doesn't work completely automatically for you, you may get
# an idea what to do for a complete installation of GAP.

set -e

# Is someone trying to run us from inside the 'bin' directory?
run_from_bin(){
if [[ -f gapicon.bmp ]]
then
  error "This script must be run from inside the pkg directory" \
        "Type: cd ../pkg; ../bin/BuildPackages.sh"
fi
}

# set default parameters
set_default_parameters() {

# CURDIR
CURDIR="$(pwd)"

# default GAPDIR
GAPDIR="$(cd .. && pwd)"

# default COLOR
if [[ -t 1 ]]
then
  COLOR=YES
else
  COLOR=NO
fi

# default LOGDIR
LOGDIR=log

# default LOGFILE
LOGFILE=buildpackages

# default FAILPKGFILE
FAILPKGFILE=fail
}

# collect arguments
collect_arguments(){
while [[ "$#" -ge 1 ]]
do
  case "$1" in
    --with-gaproot=*)
      GAPDIR=${$1#--with-gaproot=}
      shift
    ;;

    --with-gaproot)
      shift
      GAPDIR="$1"
      shift
    ;;

    --with-logdir=*)
      LOGDIR=${$1#--with-logdir=}
      shift
    ;;

    --with-logdir)
      shift
      LOGDIR="$1"
      shift
    ;;

    --with-logfile=*)
      LOGFILE=${$1#--with-logfile=}
      shift
    ;;

    --with-logfile)
      shift
      LOGFILE="$1"
      shift
    ;;

    --with-failpkgfile=*)
      FAILPKGFILE=${$1#--with-failpkgfile=}
      shift
    ;;

    --with-failpkgfile)
      shift
      FAILPKGFILE="$1"
      shift
    ;;

    --no-color|--no-colors|--no-colour|--no-colours|\
    --nocolor|--nocolors|--nocolour|--nocolours)
      COLOR=NO
      shift
    ;;

    -*)
      # Colors may not be defined at this point,
      # then the default is to use coloring.
      warning "Discarding unrecognized argument $1"
      shift
    ;;

    *)
      # Any other argument is considered to be a package directory to build.
      PACKAGES+=("$1")
      shift
    ;;
  esac
done
}

# We need to test if $GAPDIR is right
test_GAPDIR(){
if ! [[ -f "$GAPDIR/sysinfo.gap" ]]
then
  error "$GAPDIR is not the root of a gap installation (no sysinfo.gap)" \
        "Please provide the absolute path of your GAP root directory as" \
        "first argument with '--with-gaproot=' to this script."
fi
}

# set build flags for 32 bit
set_build_flags_for_32_bit(){
if [[ "$(grep -c 'ABI_CFLAGS=-m32' $GAPDIR/Makefile)" -ge 1 ]]
then
  notice "Building with 32-bit ABI"
  ABI32=YES
  CONFIGFLAGS="CFLAGS=-m32 LDFLAGS=-m32 LOPTS=-m32 CXXFLAGS=-m32"
fi
}

# packages to build
set_packages(){
if [[ "${PACKAGES[0]}" = "" ]]
then
  # If there were no extra arguments, therefore PACKAGES[0] is not defined,
  # then build all packages.
  shopt -s nullglob
  PACKAGES=(*)
  shopt -u nullglob
fi
}

# Many package require GNU make. So use gmake if available,
# for improved compatibility with *BSD systems where "make"
# is BSD make, not GNU make.
set_make(){
if ! [[ "x$(which gmake)" = "x" ]]
then
  MAKE=gmake
else
  MAKE=make
fi
}


# print notices in green
notice() {
  if [[ "$COLOR" = "YES" ]]
  then
    printf "\033[32m%s\033[0m\n" "$@"
  else
    printf "%s\n" "$@"
  fi
}

# print warnings in yellow
warning() {
  if [[ "$COLOR" = "YES" ]]
  then
    printf "\033[33mWARNING: %s\033[0m\n" "$@"
  else
    printf "%s\n" "$@"
  fi
}

# print error in red and exit
error() {
  if [[ "$COLOR" = "YES" ]]
  then
    printf "\033[31mERROR: %s\033[0m\n" "$@"
  else
    printf "%s\n" "$@"
  fi
  exit 1
}

# print stderr error in red but do not exit
std_error() {
  if [[ "$COLOR" = "YES" ]]
  then
    printf "\033[31mERROR: %s\033[0m\n" "$@"
  else
    printf "%s\n" "$@"
  fi
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
# Alternatively, one could check $GAPDIR/bin for all directories instead.
source "$GAPDIR/sysinfo.gap"
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

build_cohomolo() {
(
./configure "$GAPDIR"
cd standalone/progs.d
cp makefile.orig makefile
cd ../..
"$MAKE"
)
}

build_fail() {
  echo ""
  warning "Failed to build $PKG"
  echo "$PKG" >> "$LOGDIR/$FAILPKGFILE.log"
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
      ./configure "$CONFIGFLAGS" --with-gaproot="$GAPDIR"
    else
      ./configure "$GAPDIR"
    fi
    "$MAKE"
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
      ./configure "CFLAGS=-m32 LDFLAGS=-m32 --with-gaproot=$GAPDIR" && \
      "$MAKE" CFLAGS=-m32 LOPTS=-m32
    ;;

    atlasrep*)
      chmod 1777 datagens dataword
    ;;

    carat*)
      build_carat
    ;;

    cohomolo*)
      build_cohomolo
    ;;

    fplsa*)
      ./configure "$GAPDIR" && \
      "$MAKE" CC="gcc -O2 "
    ;;

    kbmag*)
      ./configure "$GAPDIR" && \
      "$MAKE" COPTS="-O2 -g"
    ;;

    NormalizInterface*)
      ./build-normaliz.sh "$GAPDIR" && \
      run_configure_and_make
    ;;

    pargap*)
      ./configure "$GAPDIR" && \
      "$MAKE" && \
      cp bin/pargap.sh "$GAPDIR/bin" && \
      rm -f ALLPKG
    ;;

    xgap*)
      ./configure --with-gaproot="$GAPDIR" && \
      "$MAKE" && \
      rm -f "$GAPDIR/bin/xgap.sh" && \
      cp bin/xgap.sh "$GAPDIR/bin"
    ;;

    simpcomp*)
    ;;

    *)
      run_configure_and_make
    ;;
  esac
  ) || build_fail
}


### The main function to be run, its output is going to be logged.
build_packages() {

notice "Using GAP location: $GAPDIR"
echo ""

set_packages
set_build_flags_for_32_bit
set_make

notice \
"Attempting to build GAP packages." \
"Note that many GAP packages require extra programs to be installed," \
"and some are quite difficult to build. Please read the documentation for" \
"packages which fail to build correctly, and only worry about packages" \
"you require!" \
"Logging into ./$LOGDIR/$LOGFILE.log"

date >> "$LOGDIR/$FAILPKGFILE.log"
for PKG in "${PACKAGES[@]}"
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
  fi
done

echo "" >> "$LOGDIR/$FAILPKGFILE.log"
echo ""
notice "Output logged into ./$LOGDIR/$LOGFILE.log"
notice "Packages failed to build are in ./$LOGDIR/$FAILPKGFILE.log"
# end of build_packages
}


### The main body of the script.
set_default_parameters
run_from_bin
collect_arguments "$@"
test_GAPDIR

# Create LOGDIR
mkdir -p "$LOGDIR"

# Log error to .err, output to .out, everything to .log
( build_packages \
 > >(tee "$LOGDIR/$LOGFILE.out") \
2> >(while read line
     do \
       std_error "$line"
     done \
     > >(tee "$LOGDIR/$LOGFILE.err" >&2) \
    ) \
)> >( tee "$LOGDIR/$LOGFILE.log" ) 2>&1

# remove superfluous buildpackages log files if there was no error message
if [[ ! -s "$LOGDIR/$LOGFILE.err" ]]
then
  rm -f "$LOGDIR/$LOGFILE.err"
  rm -f "$LOGDIR/$LOGFILE.out"
fi
