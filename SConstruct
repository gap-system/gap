import commands, os, glob, sys

# parse options and set up environment

vars = Variables()
vars.Add(BoolVariable("debug", "Set for debug builds", 0))
vars.Add(EnumVariable("abi", "Set to 32 or 64 depending on platform", 'auto',
  allowed_values=('32', '64', 'auto')))
vars.Add(EnumVariable("gmp", "Use GMP: yes, no, or system", "yes",
  allowed_values=("yes", "no", "system")))
vars.Add(EnumVariable("gc", "Use GC: yes, no, or system", "yes",
  allowed_values=("yes", "no", "system")))

GAP = DefaultEnvironment(variables=vars)

compiler = GAP["CC"]
platform = commands.getoutput("cnf/config.guess")
build_dir = "bin/" + platform + "-" + compiler

try:
  os.makedirs(build_dir)
except:
  pass

# Create confi.h if we don't have it

config_header_file = build_dir + "/config.h"

if (not os.access(config_header_file, os.R_OK) or
    "config" in COMMAND_LINE_TARGETS):
  os.system("./configure")
  os.system("cd "+build_dir+"; sh ../../cnf/configure.out")

# determine ABI

config_file_contents = open(config_header_file).read()

default_abi = GAP["abi"]
if default_abi == "auto":
  if "SIZEOF_VOID_P 8" in config_file_contents:
    default_abi = '64'
  elif "SIZEOF_VOID_P 4" in config_file_contents:
    default_abi = '32'
    if repr(1 << 32)[-1] == 'L':
      default_abi = '32'
    else:
      default_abi = '64'
  GAP["abi"] = default_abi


GAP.Command("config", [], "") # Empty builder for the config target

# Which external libraries do we need?

conf = Configure(GAP)
libs = ["gmp", "gc"]
if conf.CheckLib("pthread"):
  libs.append("pthread")
if conf.CheckLib("rt"):
  libs.append("rt")
if conf.CheckLib("m"):
  libs.append("m")
if GAP["gc"] == "system":
  if conf.CheckLib("gc"):
    compile_gc = False
  else:
    print "No system gc library found, using internal one."
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
    print "No system gmp library found, using internal one."
    compile_gmp = True
elif GAP["gmp"] == "yes":
  compile_gmp = True
else:
  compile_gmp = False
  libs.remove("gmp")
conf.Finish()

# Construct command line options

cflags = ""
if not GAP["debug"]:
  cflags = "-O2"
cflags += " -g"
cflags += " -m"+GAP["abi"]
cflags += " -DCONFIG_H"
if "gmp" in libs:
  cflags += " -DUSE_GMP"

GAP.Append(CCFLAGS=cflags, LINKFLAGS=cflags)

# Building external libraries

abi_path = "extern/"+GAP["abi"]+"bit"
GAP.Append(RPATH=os.path.join(os.getcwd(), abi_path, "lib"))

def build_external(libname):
  global abi_path
  try:
    os.makedirs(abi_path)
  except:
    pass
  if os.system("cd " + abi_path + ";"
          + "tar xzf ../" + libname + ".tar.gz;"
	  + "cd " + libname + ";"
	  + "./configure --prefix=$PWD/.. && make && make install") != 0:
    print "=== Failed to build " + libname + " ==="
    sys.exit(1)

if compile_gmp and glob.glob(abi_path + "/lib/libgmp.*") == []:
  os.environ["ABI"] = GAP["abi"]
  build_external("gmp-4.2.2")
  del os.environ["ABI"]

if compile_gc and glob.glob(abi_path + "/lib/libgc.*") == []:
  if commands.getoutput("uname -s") != "Darwin":
    os.environ["CC"] = GAP["CC"]+" -m"+GAP["abi"]
  else:
    os.environ["CC"] = GAP["CC"]+" -m"+GAP["abi"] + " -D_XOPEN_SOURCE"
  build_external("gc-7.2alpha2")
  del os.environ["CC"]

# Adding paths for external libraries

options = { }
include_path = build_dir+":." # for config.h
if compile_gc or compile_gmp:
  options["LIBPATH"] = abi_path + "/lib"
  include_path += ":" + abi_path + "/include"
options["CPPPATH"] = include_path
options["OBJPREFIX"] = "../" + build_dir + "/"

# Building binary from source

source = glob.glob("src/*.c")
source.remove("src/gapw95.c")
source.append("extern/jenkins/jhash.o")

GAP.Command("extern/include/jhash.h", "extern/jenkins/jhash.h",
            "cp -f $SOURCE $TARGET")
GAP.Object("extern/jenkins/jhash.o", "extern/jenkins/jhash.c")
GAP.Program(build_dir + "/gap", source, LIBS=libs, **options)
