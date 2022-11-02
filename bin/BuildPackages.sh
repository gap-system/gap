#!/usr/bin/env bash

# This script attempts to build all GAP packages contained in the current
# directory. Normally, you should run this script from the 'pkg'
# subdirectory of your GAP installation.

# You can also run it from other locations, but then you need to tell the
# script where your GAP root directory is, by passing it as an argument
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

CURDIR="$(pwd)"
GAPROOT="$(cd .. && pwd)"
COLORS=yes
STRICT=no       # exit with non-zero exit code when encountering any failures
PARALLEL=no
PACKAGES=()

# If output does not go into a terminal (but rather into a log file),
# turn off colors.
[[ -t 1 ]] || COLORS=no

while [[ "$#" -ge 1 ]]; do
  option="$1" ; shift
  case "$option" in
    --with-gaproot)   GAPROOT="$1"; shift ;;
    --with-gaproot=*) GAPROOT=${option#--with-gaproot=}; ;;
    --parallel)       PARALLEL=yes; ;;

    --with-gap)       GAP_EXE="$1"; shift ;;
    --with-gap=*)     GAP_EXE=${option#--with-gap=}; ;;

    --no-color)       COLORS=no ;;
    --color)          COLORS=yes ;;

    --no-strict)      STRICT=no ;;
    --strict)         STRICT=yes ;;
    --add-package-config-*)   typeset PACKAGE_CONFIG_ARGS_${option:21}="$1"; shift ;;

    -*)               echo "ERROR: unsupported argument $option" ; exit 1;;
    *)                PACKAGES+=("$option") ;;
  esac
done

# Some helper functions for printing user messages
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

# Is someone trying to run us from inside the 'bin' directory?
if [[ -f BuildPackages.sh ]]
then
  error "This script must be run from inside the pkg directory" \
        "Type: cd ../pkg; ../bin/BuildPackages.sh"
fi

if [ "x$PARALLEL" = "xyes" ] && [ "x$STRICT" = "xyes" ]; then
  error "The options --strict and --parallel cannot be used simultaneously"
fi

if [ "x$PARALLEL" = "xyes" ]; then
  export MAKEFLAGS="${MAKEFLAGS:--j3}"
fi;

# If user specified no packages to build, build all packages in subdirectories.
if [[ ${#PACKAGES[@]} == 0 ]]
then
  # Put package directory names into a bash array to avoid issues with
  # spaces in filenames. This code will still break if there are newlines
  # in the name.
  old_IFS=$IFS
  IFS=$'\n' PACKAGES=($(find . -maxdepth 2 -type f -name PackageInfo.g | sort -f))
  IFS=$old_IFS
  PACKAGES=( "${PACKAGES[@]%/PackageInfo.g}" )
fi

notice "Using GAP root $GAPROOT"

# Check whether $GAPROOT is valid
if [[ ! -f "$GAPROOT/sysinfo.gap" ]]
then
  error "$GAPROOT is not the root of a gap installation (no sysinfo.gap)" \
        "Please provide the absolute path of your GAP root directory as" \
        "first argument with '--with-gaproot=' to this script."
fi

# read in sysinfo
source "$GAPROOT/sysinfo.gap"

# determine the GAP executable to call:
# - if the user specified one explicitly via the `--gap` option, then
#   GAP_EXE is set and we should use that
# - otherwise if sysinfo.gap set the GAP variable, use that
# - otherwise fall back to $GAPROOT/bin/gap.sh
if [[ -n $GAP_EXE ]]
then
  GAP="$GAP_EXE"
else
  GAP="${GAP:-$GAPROOT/bin/gap.sh}"
fi



# detect whether GAP was built in 32bit mode
# TODO: once all packages have adapted to the new build system,
# this should no longer be necessary, as package build systems should
# automatically adjust to 32bit mode.
case "$GAP_ABI" in
  32)
    notice "Building with 32-bit ABI"
    CONFIGFLAGS="CFLAGS=-m32 LDFLAGS=-m32 LOPTS=-m32 CXXFLAGS=-m32"
    ;;
  64)
    notice "Building with 64-bit ABI"
    CONFIGFLAGS=""
    ;;
  *)
    error "Unsupported GAP ABI '$GAParch_abi'."
    ;;
esac


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

# print the given command plus arguments, single quoted, then run it
echo_run() {
  # when printf is given a format string with only one format specification,
  # it applies that format string to each argument in sequence
  notice "Running $(printf "'%s' " "$@")"
  "$@"
}

build_fail() {
  echo ""
  warning "Failed to build $PKG"
  echo "$PKG" >> "$LOGDIR/fail.log"
  if [[ $STRICT = yes ]]
  then
    exit 1
  fi
}

run_configure_and_make() {
  # We want to know if this is an autoconf configure script
  # or not, without actually executing it!
  if [[ -x autogen.sh && ! -x configure ]]
  then
    ./autogen.sh
  fi
  if [[ -x configure ]]
  then
    if grep Autoconf ./configure > /dev/null
    then
      local PKG_NAME=$($GAP -q -T -A -M <<GAPInput
Read("PackageInfo.g");
Print(GAPInfo.PackageInfoCurrent.PackageName);
GAPInput
)
      local CONFIG_ARGS_FLAG_NAME="PACKAGE_CONFIG_ARGS_${PKG_NAME}"
      echo_run ./configure --with-gaproot="$GAPROOT" $CONFIGFLAGS ${!CONFIG_ARGS_FLAG_NAME}
      echo_run "$MAKE" clean
    else
      echo_run ./configure "$GAPROOT"
      echo_run "$MAKE" clean
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
  [[ $GITHUB_ACTIONS = true ]] && echo "::group::$PKG"
  echo ""
  date
  echo ""
  notice "==== Checking $PKG"
  (  # start subshell
  set -e
  cd "$CURDIR/$PKG"
  if [[ -x prerequisites.sh ]]
  then
    ./prerequisites.sh "$GAPROOT"
  elif [[ -x build-normaliz.sh ]]
  then
    # used in NormalizInterface; to be replaced by prerequisites.sh in future
    # versions
    ./build-normaliz.sh "$GAPROOT"
  fi
  case "$PKG" in
    # All but the last lines should end by '&&', otherwise (for some reason)
    # some packages that fail to build will not get reported in the logs.
    atlasrep*)
      chmod 1777 datagens dataword
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
      # Old versions of simpcomp were not setting the executable
      # bit for some files; they also were not copying the bistellar
      # executable to the right place
      (chmod a+x configure depcomp install-sh missing || :) && \
      run_configure_and_make && \
      mkdir -p bin && test -x bin/bistellar || mv bistellar bin
    ;;

    *)
      run_configure_and_make
    ;;
  esac
  ) &&
  (  # start subshell
  if [[ $GITHUB_ACTIONS = true ]]
  then
    echo "::endgroup::"
  fi
  ) || build_fail
}

date >> "$LOGDIR/fail.log"
for PKG in "${PACKAGES[@]}"
do 
  (  # start a background process
  # cut off the ending slash (if exists)
  PKG="${PKG%/}"
  # cut off everything before the first slash to only keep the package name
  # (these two commands are mainly to accommodate the logs better,
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
  ) &
  BUILD_PID=$!
  if [ "x$PARALLEL" = "xyes" ]; then
    # If more than 4 background jobs are running, wait for one to finish (if
    # <wait -n> is available) or for all to finish (if only <wait> is available)
    if [[ $(jobs -r -p | wc -l) -gt 4 ]]; then
        wait -n 2>&1 >/dev/null || wait
    fi
  else
    # wait for this package to finish building
    if ! wait $BUILD_PID && [[ $STRICT = yes ]]
    then
      exit 1
    fi
  fi;
done
# Wait until all packages are built, if in parallel
wait

echo "" >> "$LOGDIR/fail.log"
echo ""
notice "Packages which failed to build are in ./$LOGDIR/fail.log"
