import commands, os, glob, sys, string, commands, platform

# parse options and set up environment

vars = Variables()
vars.Add('cflags', 'Supply additional CFLAGS', "")
vars.Add(BoolVariable("debug", "Set for debug builds", 0))
vars.Add('mpi','Specify a directory with the MPI implementation',"")
#BoolVariable("mpi", "Enable MPI support", 0))
vars.Add("zmq", "Build with zeromq support (yes, no, /path)", "no")
vars.Add(BoolVariable("debugguards", "Set for debugging guards", 0))
vars.Add(BoolVariable("profile",
  "Set for profiling with google performance tools", 0))
vars.Add(EnumVariable("abi", "Set to 32 or 64 depending on platform", 'auto',
  allowed_values=('32', '64', 'auto')))
vars.Add('compiler', "C compiler", "")
vars.Add('cpp_compiler', "C++ compiler", "")
vars.Add(EnumVariable("gmp", "Use GMP", "yes",
  allowed_values=("yes", "no", "system")))
vars.Add(EnumVariable("gc", "Use GC",
  "boehm-tl", allowed_values=("boehm", "boehm-tl", "boehm-par", "fusion", "no", "system")))
vars.Add(EnumVariable("gcblksize", "Size of GC heap blocks",
  "8192", allowed_values=("auto", "4096", "8192", "16384", "32768")))
vars.Add("gcmaxthreads", "Maximum number of workers to be used by the GC", "32")
vars.Add('preprocess', 'Use source preprocessor', "")
vars.Add('ward', 'Specify Ward directory', "")
vars.Add('cpus', "Number of logical CPUs", "auto")
vars.Add(BoolVariable("readline", "Build with readline support", 0))

GAP = DefaultEnvironment(variables=vars, ENV={"PATH": os.environ["PATH"]})

Help(vars.GenerateHelpText(GAP))

# Allow environment to override settings

for opt in ["CC", "CXX", "CFLAGS", "CXXFLAGS"]:
  if os.environ.has_key(opt):
    GAP[opt] = os.environ[opt]
    del os.environ[opt]

# What compiler and platform are we dealing with?

if GAP["compiler"] != "":
  GAP["CC"] = GAP["compiler"]
if GAP["cpp_compiler"] != "":
  GAP["CXX"] = GAP["cpp_compiler"]

compiler = GAP["CC"]
cpp_compiler = GAP["CXX"]
if not cpp_compiler:
  GAP["zmq"] = "no"
platform_name = commands.getoutput("cnf/config.guess")
build_dir = "bin/" + platform_name + "-" + os.path.basename(compiler) + "-hpc"

def which(program):
  # This only works on UNIXes, but we don't call it on Windows.
  def is_executable(path):
    return os.path.isfile(path) and os.access(path, os.X_OK)
  path = os.environ.get("PATH")
  if not path:
    return 0
  path = path.split(":")
  for p in path:
    progpath = os.path.join(p, program)
    if is_executable(progpath):
      return progpath
  return None

makeprog = "make"
for osprefix in ["freebsd", "openbsd", "netbsd", "dragonfly"]:
  if sys.platform.startswith(osprefix):
    if not which("gmake"):
      print "=== gmake is needed to build HPC-GAP on BSD systems. ==="
      Exit(1)
    makeprog = "gmake"
    break

# We're working around some cygwin compatibility issues.
# Cygwin does not work with the recent Boehm GC development branch;

cygwin = sys.platform.startswith("cygwin")
if cygwin:
  if GAP["gc"].startswith("boehm-"):
    GAP["gc"] = "boehm"

# Figure out the number of processors. This is an estimate and works
# only for Linux and OS X at the moment. For all other platforms, we
# use a default, though that can be overridden with cpus=n.
default_ncpus = 4

if GAP["cpus"] == "auto":
  os_name = platform.system()
  if os_name == "Darwin":
    try:
      st, ncpus = commands.getstatusoutput("sysctl -n machdep.cpu.thread_count")
      if st == 0:
        ncpus = int(ncpus)
      else:
        ncpus = default_ncpus
    except:
      ncpus = default_ncpus
  elif os_name == "Linux":
    try:
      st, ncpus = commands.getstatusoutput("nproc")
      if st == 0:
        ncpus = int(ncpus)
      else:
        ncpus = default_ncpus
    except:
      ncpus = default_ncpus
  else:
    ncpus = default_ncpus
else:
  try:
    ncpus = int(GAP["cpus"])
  except:
    ncpus = default_ncpus
if ncpus <= 0:
  ncpus = default_ncpus

try: os.makedirs(build_dir)
except: pass

try: os.unlink("bin/current")
except: pass

try: os.symlink(build_dir[4:], "bin/current")
except: pass
 
# Calculate the maximum number of GC threads to use
if GAP["gcmaxthreads"] in ("", "auto"):
  gcmaxthreads = ncpus
else:
  try: gcmaxthreads = int(GAP["gcmaxthreads"])
  except:
    print "gcmaxthreads option is not an integer"
    Exit(1)
  if gcmaxthreads <= 0:
    print "gcmaxthreads is not a positive integer"
    Exit(1)


# Routine to scan config.h and figure out whether we are targeting
# a 32-bit or a 64-bit architecture.
def parse_config(config_header_file):
  global GAP
  try:
    config_file_contents = open(config_header_file).read()
    # Because the configure script ignores --with-readline,
    # we're also patching it here.
    have_libreadline = "#define HAVE_LIBREADLINE 1"
    if not GAP["readline"] and have_libreadline in config_file_contents:
      config_file_contents = config_file_contents.replace(
        have_libreadline,
	"/* #undef HAVE_LIBREADLINE */")
      try:
	open(config_header_file, "w").write(config_file_contents)
      except:
        print "Could not update config file"
  except:
    config_file_contents = ""

  abi = GAP["abi"]
  if "SIZEOF_VOID_P 8" in config_file_contents:
    abi = '64'
  elif "SIZEOF_VOID_P 4" in config_file_contents:
    abi = '32'
  return abi, config_file_contents != ""


versionheader = GAP.Command(build_dir + "/gap_version.h", [], "cnf/mkversionheader.sh ${TARGET}")
GAP.AlwaysBuild(versionheader)

# Create config.h if we don't have it and determine ABI

config_header_file = build_dir + "/config.h"
default_abi, has_config = parse_config(config_header_file)
changed_abi = GAP["abi"] != "auto" and GAP["abi"] != default_abi
if changed_abi:
  default_abi = GAP["abi"]

if not has_config or "config" in COMMAND_LINE_TARGETS or changed_abi:
  if not GetOption("clean") and not GetOption("help"):
    if GAP["abi"] != "auto":
      os.environ["CFLAGS"] = " -m" + GAP["abi"]
    # Configuration name is currently forced to be "hpc". This is
    # necessary because we are wrapping the GAP.dev build process.
    os.environ["CONFIGNAME"] = "hpc"
    os.environ["GAPARCH"] = build_dir[4:]
    os.system("./hpc/configure --with-readline=" +
      (GAP["readline"] and "yes" or "no") +
      " CC=\""+GAP["CC"]+"\"")
    os.system("cd "+build_dir+"; sh ../../cnf/configure.out")
    os.system("test -w bin/gap.sh && chmod ugo+x bin/gap.sh")
    if GAP["abi"] != "auto":
      del os.environ["CFLAGS"]
    del os.environ["CONFIGNAME"]
    del os.environ["GAPARCH"]

default_abi, has_config = parse_config(config_header_file)
if not has_config and not GetOption("clean") and not GetOption("help"):
  print "=== Configuration file wasn't created ==="
  Exit(1)
GAP["abi"] = default_abi

GAP.Command("config", [], "") # Empty builder for the config target

# Which external libraries do we need?
# This code also sets compile_gmp and compile_gc so that we know
# later which external libraries to build.

libs = ["gmp", "gc", "atomic_ops"]
conf = Configure(GAP)
if not GetOption("clean") and not GetOption("help"):
  if conf.CheckLib("pthread"):
    libs.append("pthread")
  if conf.CheckLib("rt"):
    libs.append("rt")
  if conf.CheckLib("m"):
    libs.append("m")
  if conf.CheckLib("dl"):
    libs.append("dl")
  if GAP["readline"]:
    if conf.CheckLib("ncurses"):
      libs.append("ncurses")
    if conf.CheckLib("readline"):
      libs.append("readline")
  if conf.CheckLib("util"):
    libs.append("util")
  if GAP["gc"] == "system":
    if conf.CheckLib("gc"):
      compile_gc = False
    else:
      print "=== No system gc library found, using internal one. ==="
      compile_gc = True
  elif GAP["gc"] != "no":
    compile_gc = True
  else:
    compile_gc = False
    libs.remove("gc")
  if GAP["gmp"] == "system":
    if conf.CheckLib("gmp"):
      compile_gmp = False
    else:
      print "=== No system gmp library found, using internal one. ==="
      compile_gmp = True
  elif GAP["gmp"] == "yes":
    compile_gmp = True
  else:
    compile_gmp = False
    libs.remove("gmp")
  if GAP["profile"]:
    libs.append("profiler")
else: # cleaning
  compile_gc = False
  compile_gmp = False

conf.Finish()

if GAP["mpi"]:
  if GAP["mpi"] == "system":
    GAP["CC"] = "mpicc"
  else:
    GAP["CC"] = GAP["mpi"] + "/bin/mpicc"

# Construct command line options

abi_path = "extern/"+GAP["abi"]+"bit"

include_path = [ "src/", "src/hpc/", build_dir, "."] # for config.h
library_path = [ ]
options = { }

def add_include_path(path):
  global include_path, options
  if path not in include_path:
    include_path.append(path)
    options["CPPPATH"] = ":".join(include_path)

def add_library_path(path):
  global library_path, options
  if path not in library_path:
    library_path.append(path)
    options["LIBPATH"] = library_path[:]

add_library_path(abi_path + "/lib")
include_path.append(abi_path + "/include")

add_include_path("src/")

defines = ["HPCGAP"]
cflags = ""
linkflags = ""
if not GAP["debug"]:
  cflags = "-O2"
elif not os.system("\"" + GAP["CC"] +
    "\" -Og -E - </dev/null 2>/dev/null >/dev/null"):
  cflags = "-Og"
if compiler == "gcc":
  cflags += " -g3"
else:
  cflags += " -g"
if GAP["mpi"]:
  cflags += " -DGAPMPI"
cflags += " -m"+GAP["abi"]
if GAP["zmq"] != "no":
  defines.append("WITH_ZMQ")
  libs.append("zmq")
  if GAP["zmq"].startswith("/"):
    add_include_path(GAP["zmq"] + "/include")
    add_library_path(GAP["zmq"] + "/lib")
defines.append("CONFIG_H")
if "gc" in libs:
  defines.append("GC_THREADS")
if GAP["gc"] == "no":
  defines.append("DISABLE_GC")
elif GAP["gc"] == "fusion":
  defines.append("FUSION_GC")
else:
  defines.append("BOEHM_GC")
if "gmp" in libs:
  defines.append("USE_GMP=1")

if GAP["debugguards"]:
  defines.append("VERBOSE_GUARDS")

defines.append("NUM_CPUS="+str(ncpus))

if GAP["cflags"]:
  cflags += " " + string.replace(GAP["cflags"], "%", " ")
for define in defines:
  cflags += " -D" + define

if sys.platform.startswith("linux"):
  linkflags += " -Wl,-export-dynamic"
elif sys.platform.startswith("dragonfly"):
  linkflags += " -Xlinker -E"

GAP.Append(CCFLAGS=cflags, LINKFLAGS=cflags+linkflags)

# Building external libraries

GAP.Append(RPATH=os.path.join(os.getcwd(), abi_path, "lib"))

# General routine to build an external library using gunzip,
# tar, configure, and make.
def build_external(libname, confargs="", makeargs="",
                   cc="", cflags="", patch=[]):
  global abi_path
  if GetOption("help") or GetOption("clean"):
    return
  try:
    os.makedirs(abi_path)
  except:
    pass
  jobs = GetOption("num_jobs")
  if confargs:
    confargs = " " + confargs
  if makeargs:
    makeargs = " " + makeargs
  if not cc:
    cc = "%(CC)s -m%(abi)s" % GAP
  if cflags:
    cc += " " + cflags
  ccprefix = "CC=\"%s\"" % cc
  confargs = " " + ccprefix + confargs
  print "=== Extracting " + libname + " ==="
  if os.system("cd " + abi_path
          + " && tar xzf ../" + libname + ".tar.gz"):
    print("=== Missing or damaged " + libname + ".tar.gz")
    Exit(1)
  if patch:
    for p in patch:
      print "=== Patching " + libname + " with " + p + " ==="
      if os.system("cd " + abi_path + "/" + libname
                 + " && patch -p1 -f < ../../" + p) != 0:
	print("=== Failed to patch " + libname);
	Exit(1)
  print "=== Building " + libname + " ==="
  if os.system("cd " + abi_path + "/" + libname
	  + " && ./configure --prefix=$PWD/.. --libdir=$PWD/../lib" + confargs
	  + " && " + makeprog + " -j " + str(jobs) + makeargs
	  + " && " + makeprog + makeargs + " install") != 0:
    print "=== Failed to build " + libname + " ==="
    Exit(1)

if compile_gmp and glob.glob(abi_path + "/lib/libgmp.*") == []:
  os.environ["ABI"] = GAP["abi"]
  build_external("gmp-6.0.0", confargs="--disable-shared", cc=GAP["CC"])
  del os.environ["ABI"]

if glob.glob(abi_path + "/lib/libatomic_ops.*") == []:
  build_external("libatomic_ops-2012-03-02")

# Build the garbage collector
gc_configuration = "%(gc)s:%(gcblksize)s:%(gcmaxthreads)s\n" % GAP
new_gc = False
if compile_gc and glob.glob(abi_path + "/lib/libgc.*") == []:
  new_gc = True
  gc_cflags = "-DMAX_MARKERS=" + str(gcmaxthreads)
  if GAP["gcblksize"] != "auto":
    import resource
    if GAP["gc"].startswith("boehm-"):
      if resource.getpagesize() > int(GAP["gcblksize"]):
	gc_cflags += " -DHBLKSIZE=" + str(resource.getpagesize())
      else:
	gc_cflags += " -DHBLKSIZE=" + GAP["gcblksize"]
  if cygwin:
    patchfiles = []
  else:
    patchfiles = ["gc-7.4.2-conf.patch"]
    if GAP["gc"].startswith("boehm-"):
      patchfiles.append("gc-7.4.2-tl.patch")
  build_external(cygwin and "gc-7.2d" or "gc-7.4.2", cflags=gc_cflags,
    confargs="--disable-shared --disable-gcj-support --enable-large-config" +
      (GAP["gc"] == "boehm-par" and " --enable-parallel-mark" or
                                    " --disable-parallel-mark"),
    patch=patchfiles)

if GAP["zmq"] == "yes" and glob.glob(abi_path + "/lib/libzmq.*") == []:
  os.environ["CXX"] = GAP["CXX"]+" -m"+GAP["abi"]
  build_external("zeromq-3.2.3", makeargs="'SUBDIRS=src doc'")
  del os.environ["CXX"]


# Adding paths for external libraries

options["CPPPATH"] = ":".join(include_path)
options["OBJPREFIX"] = "../build/obj/"

# Store the compiler and linker flags in files in the build directory
# so that GAP packages can access them.

def write_build_info(cflags, ldflags):
  global gc_configuration, gcmaxthreads
  try: os.mkdir("build")
  except: pass
  arch = "-m" + GAP["abi"]
  file = open("build/cflags", "w")
  file.write(cflags+"\n")
  file.close()
  file = open("build/ldflags", "w")
  file.write(ldflags+"\n")
  file.close()
  file = open("build/buildenv.sh", "w")
  file.write("extra_cflags=' " + arch + " " + cflags + "'")
  file.write("extra_ldflags=' " + arch + " " + ldflags + "'")
  file.close()
  if new_gc:
    file = open("build/gcconfig", "w")
    file.write(gc_configuration)
    file.close()
  else:
    # If the GC was already built, we retrieve the actual number
    # of max GC threads, since we need that to compile the 
    try:
      file = open("build/gcconfig", "r")
      gc_configuration = file.read()
      gcmaxthreads = int((gc_configuration.rstrip().split(":"))[2])
      file.close()
    except:
      file.close()

# Building binary from source

def make_cc_options(prefix, args):
  return (" " + prefix).join([""] + args)

if GAP["mpi"]:
  if GAP["mpi"] == "system":
    GAP["LINK"] = "mpicc"
  else:
    GAP["LINK"] = GAP["mpi"] + "/bin/mpicc"

preprocess = string.replace(GAP["preprocess"], "%", " ")
if GAP["ward"]:
  preprocess = GAP["ward"] + "/bin/addguards2" + \
    make_cc_options("-I", include_path) + make_cc_options("-D", defines)

if not GetOption("clean") and not GetOption("help"):
  write_build_info((make_cc_options("-I", map(os.path.abspath, include_path)) +
    make_cc_options("-D", defines))[1:],
      "-L" + (os.path.abspath(abi_path+"/lib")))

# We are setting -DMAX_GC_THREADS here so that (1) it does not get
# added to the public build/cflags list and (2) does not force
# rebuilding of GAP proper when the GC wasn't actually rebuilt.

GAP.Append(CFLAGS=" -DMAX_GC_THREADS="+str(gcmaxthreads))

# Get all the source files that we need to compile GAP.
# We currently exclude the Win95 file and GAC-generated files.
source = glob.glob("src/*.c") + glob.glob("src/hpc/*.c")
source.remove("src/gapw95.c")
# source = filter(lambda s: not s.startswith("src/c_"), source)

# If we're not using MPI, don't use the MPI code.
if not GAP["mpi"]:
  source.remove("src/hpc/gapmpi.c")

# Offer a "testward" target to check syntax.
if "testward" in COMMAND_LINE_TARGETS:
  ward = GAP["ward"]
  if not ward:
    if os.path.exists("../ward/bin/ward"):
      ward = "../ward"
    elif os.path.exists("ward/bin/ward"):
      ward = "ward"
    else:
      print("Cannot find ward")
      Exit(1)
  if len(COMMAND_LINE_TARGETS) == 1:
    wardfiles = source
  else:
    wardfiles = COMMAND_LINE_TARGETS[:]
    wardfiles.remove("testward")
  for file in wardfiles:
    cmd = ward + "/bin/ward -parseonly" + \
      make_cc_options("-I", include_path) + make_cc_options("-D", defines) + \
      " " + file
    print(cmd)
    os.system(cmd)
  Exit(0)

# Generate src/debugmacro.c. It contains functions that wrap important
# GAP macros to help with debugging on platforms that do not store
# macros as part of the debugging information.
if "src/dbgmacro.c" not in source:
  source.append("src/dbgmacro.c")
GAP.Command("src/dbgmacro.c", "etc/dbgmacro.py",
  "bin/run-python $SOURCE > $TARGET")

# If there is a preprocessor defined, run all files through it,
# generating matching files in the gen/ directory and make them
# the actual source files instead.
gen = []
if preprocess:
  import os, stat
  try: os.mkdir("gen")
  except: pass
  pregen = source
  gen = map(lambda s: "gen/"+s[4:], pregen)
  for i in range(len(pregen)):
    GAP.Command(gen[i], pregen[i],
        preprocess + " $SOURCE >$TARGET")
  source = map(lambda s: "gen/"+s[4:], source)

# Cygwin needs to be explicitly told to include libstdc++ when linking
# against a C++ library (-lzmq).
if cygwin and GAP["zmq"]:
  libs.append("stdc++")

# Report if Ward failed for any source file

def report(*args, **kwd):
  failed = []
  for file in gen:
    try:
      fp = open(file)
      head = fp.readline()
      fp.close()
      if head.index("ERROR: Ward") >= 0:
        failed.append(file)
    except:
      pass
  if len(failed) > 0:
    files = " file" + (len(failed) != 1 and "s" or "")
    print "=== warning: ward failed to parse " + str(len(failed)) + files


# Build the HPC-GAP binary.
GAP.Program(build_dir + "/gap", source, LIBS=libs, **options)
GAP.AddPostAction(build_dir + "/gap", Action("", report))
