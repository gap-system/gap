import commands, os, glob

# parse options and set up environment

vars = Variables()
vars.Add(BoolVariable("debug", "Set for debug builds", 0))
vars.Add(EnumVariable("abi", "Set to 32 or 64 depending on platform", '32',
  allowed_values=('32', '64')))
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

# Create config.h if we don't have it

if (not os.access(build_dir+"/config.h", os.R_OK) or
    "config" in COMMAND_LINE_TARGETS):
  os.system("cd "+build_dir+"; sh ../../cnf/configure.out")

GAP.Command("config", [], "") # Empty builder for the config target

# Which external libraries do we need?

conf = Configure(GAP)
libs = ["gmp", "gc"]
if conf.CheckLib("pthread"):
  libs.append("pthread")
if conf.CheckLib("rt"):
  libs.append("rt")
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

def build_external(libname):
  global abi_path
  try:
    os.makedirs(abi_path)
  except:
    pass
  os.system("cd " + abi_path + ";"
          + "tar xzf ../" + libname + ".tar.gz;"
	  + "cd " + libname + ";"
	  + "./configure --prefix=$PWD/.. && make && make install")

if compile_gmp and glob.glob(abi_path + "/lib/libgmp.*") == []:
  os.environ["ABI"] = GAP["abi"]
  build_external("gmp-4.2.2")
  del os.environ["ABI"]

if compile_gc and glob.glob(abi_path + "/lib/libgc.*") == []:
  os.environ["CC"] = GAP["CC"]+" -m"+GAP["abi"]
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
