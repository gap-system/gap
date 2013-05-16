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
vars.Add(EnumVariable("gmp", "Use GMP: yes, no, or system", "yes",
  allowed_values=("yes", "no", "system")))
vars.Add(EnumVariable("gc", "Use GC: yes, no, or system", "yes",
  allowed_values=("yes", "no", "system")))
vars.Add('preprocess', 'Use source preprocessor', "")
vars.Add('ward', 'Specify Ward directory', "")
vars.Add('cpus', "Number of logical CPUs", "auto")

GAP = DefaultEnvironment(variables=vars, PATH=os.environ["PATH"])
if GAP["compiler"] != "":
  GAP["CC"] = GAP["compiler"]
if GAP["cpp_compiler"] != "":
  GAP["CXX"] = GAP["cpp_compiler"]

compiler = GAP["CC"]
cpp_compiler = GAP["CXX"]
platform_name = commands.getoutput("cnf/config.guess")
build_dir = "bin/" + platform_name + "-" + compiler + "-hpc"

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
 

def abi_from_config(config_header_file):
  global GAP
  try:
    config_file_contents = open(config_header_file).read()
  except:
    config_file_contents = ""

  abi = GAP["abi"]
  if "SIZEOF_VOID_P 8" in config_file_contents:
    abi = '64'
  elif "SIZEOF_VOID_P 4" in config_file_contents:
    abi = '32'
  return abi, config_file_contents != ""


# Create config.h if we don't have it and determine ABI

config_header_file = build_dir + "/config.h"
default_abi, has_config = abi_from_config(config_header_file)
changed_abi = GAP["abi"] != "auto" and GAP["abi"] != default_abi
if changed_abi:
  default_abi = GAP["abi"]

if not has_config or "config" in COMMAND_LINE_TARGETS or changed_abi:
  if not GetOption("clean"):
    if GAP["abi"] != "auto":
      os.environ["CFLAGS"] = " -m" + GAP["abi"]
    os.environ["CONFIGNAME"] = "hpc"
    os.system("./hpc/configure CC=\""+GAP["CC"]+"\"")
    os.system("cd "+build_dir+"; sh ../../cnf/configure.out")
    os.system("test -w bin/gap.sh && chmod ugo+x bin/gap.sh")
    if GAP["abi"] != "auto":
      del os.environ["CFLAGS"]
    del os.environ["CONFIGNAME"]

default_abi, has_config = abi_from_config(config_header_file)
if not has_config and not GetOption("clean"):
  print "=== Configuration file wasn't created ==="
  Exit(1)
GAP["abi"] = default_abi

GAP.Command("config", [], "") # Empty builder for the config target

# Which external libraries do we need?

libs = ["gmp", "gc", "atomic_ops"]
conf = Configure(GAP)
if not GetOption("clean"):
  if conf.CheckLib("pthread"):
    libs.append("pthread")
  if conf.CheckLib("rt"):
    libs.append("rt")
  if conf.CheckLib("m"):
    libs.append("m")
  if conf.CheckLib("dl"):
    libs.append("dl")
  if GAP["gc"] == "system":
    if conf.CheckLib("gc"):
      compile_gc = False
    else:
      print "=== No system gc library found, using internal one. ==="
      compile_gc = True
  elif GAP["gc"] == "yes":
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
  linkflags += " -lzmq"
  if GAP["zmq"].startswith("/"):
    add_include_path(GAP["zmq"] + "/include")
    add_library_path(GAP["zmq"] + "/lib")
defines.append("CONFIG_H")
if "gc" in libs:
  defines.append("GC_THREADS")
else:
  defines.append("DISABLE_GC")
if "gmp" in libs:
  defines.append("USE_GMP")

if GAP["debugguards"]:
  defines.append("VERBOSE_GUARDS")

defines.append("NUM_CPUS="+str(ncpus))

if GAP["cflags"]:
  cflags += " " + string.replace(GAP["cflags"], "%", " ")
for define in defines:
  cflags += " -D" + define

if os.uname()[0] == "Linux":
  linkflags += " -Wl,-export-dynamic"

GAP.Append(CCFLAGS=cflags, LINKFLAGS=cflags+linkflags)

# Building external libraries

abi_path = "extern/"+GAP["abi"]+"bit"
GAP.Append(RPATH=os.path.join(os.getcwd(), abi_path, "lib"))

def build_external(libname, confargs="", makeargs="", cc=""):
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
  if cc:
    ccprefix = "CC=\"%s\"" % cc
  else:
    ccprefix = "CC=\"%(CC)s -m%(abi)s\"" % GAP
  confargs = " " + ccprefix + confargs
  print "=== Building " + libname + " ==="
  if os.system("cd " + abi_path + ";"
          + "tar xzf ../" + libname + ".tar.gz;"
	  + "cd " + libname + ";"
	  + "./configure --prefix=$PWD/.." + confargs
	  + " && make -j " + str(jobs) + makeargs
	  + " && make" + makeargs + " install") != 0:
    print "=== Failed to build " + libname + " ==="
    sys.exit(1)

if compile_gmp and glob.glob(abi_path + "/lib/libgmp.*") == []:
  os.environ["ABI"] = GAP["abi"]
  build_external("gmp-5.0.4", confargs="--disable-shared", cc=GAP["CC"])
  del os.environ["ABI"]

if glob.glob(abi_path + "/lib/libatomic_ops.*") == []:
  build_external("libatomic_ops-2012-03-02")

if compile_gc and glob.glob(abi_path + "/lib/libgc.*") == []:
  build_external("gc-7.2d", confargs="--disable-shared")

if GAP["zmq"] == "yes" and glob.glob(abi_path + "/lib/libzmq.*") == []:
  os.environ["CXX"] = GAP["CXX"]+" -m"+GAP["abi"]
  build_external("zeromq-3.2.0", makeargs="'SUBDIRS=src doc'")
  del os.environ["CXX"]


# Adding paths for external libraries

include_path = [ build_dir, "." ] # for config.h
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
options["CPPPATH"] = ":".join(include_path)
options["OBJPREFIX"] = "../obj/"

# uname file generator

sysinfo_os, sysinfo_host, sysinfo_version, sysinfo_os_full, sysinfo_arch = \
  os.uname()

sysinfo_header = [
  "#ifndef _SYSINFO_H",
  "#define SYSINFO_OS " + sysinfo_os,
  "#define SYSINFO_OS_"+ string.upper(sysinfo_os)+" 1",
  "#define SYSINFO_VERSION " + sysinfo_version,
  "#define SYSINFO_ARCH " + sysinfo_arch,
  "#define SYSINFO_ARCH_"+ string.upper(sysinfo_arch)+" 1",
  "#endif /* _SYSINFO_H */"
]

def SysInfoBuilder(target, source, env):
  file = open(target[0].get_abspath(), "w")
  for line in sysinfo_header:
    file.write(line+"\n")
  file.close()

def WriteFlags(cflags, ldflags):
  arch = "-m" + GAP["abi"]
  file = open("bin/cflags", "w")
  file.write(cflags+"\n")
  file.close()
  file = open("bin/ldflags", "w")
  file.write(ldflags+"\n")
  file.close()
  file = open(build_dir+"/buildflags.sh", "w")
  file.write("extra_cflags=' " + arch + " " + cflags + "'")
  file.write("extra_ldflags=' " + arch + " " + ldflags + "'")
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
  preprocess = GAP["ward"] + "/bin/addguards2c" + \
    make_cc_options("-I", include_path) + make_cc_options("-D", defines)
WriteFlags((make_cc_options("-I", map(os.path.abspath, include_path)) +
  make_cc_options("-D", defines))[1:],
    "-L" + (os.path.abspath(abi_path+"/lib")))

source = glob.glob("src/*.c")
source.remove("src/gapw95.c")
source = filter(lambda s: not s.startswith("src/c_"), source)

if "src/dbgmacro.c" not in source:
  source.append("src/dbgmacro.c")
GAP.Command("src/dbgmacro.c", "etc/dbgmacro.py",
  "python $SOURCE > $TARGET")

if not GAP["mpi"]:
  source.remove("src/gapmpi.c")
if preprocess:
  import os, stat
  try: os.mkdir("gen")
  except: pass
  pregen = source + glob.glob("src/*.h")
  gen = map(lambda s: "gen/"+s[4:], pregen)
  for i in range(len(pregen)):
    GAP.Command(gen[i], pregen[i],
        preprocess + " $SOURCE >$TARGET")
  source = map(lambda s: "gen/"+s[4:], source)

GAP.Command("extern/include/sysinfo.h", [], SysInfoBuilder)
GAP.Program(build_dir + "/gap", source, LIBS=libs, **options)
