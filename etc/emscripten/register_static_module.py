#!/usr/bin/env python3
"""Register a package kernel module as a static module in src/compstat.c.

GAP's static-module table (CompInitFuncs[] in src/compstat.c) is the list
of init functions that SHOW_STAT() reports; LoadKernelExtension finds a
module there and loads it without dlopen (which the wasm build lacks).
This adds an entry for a module whose init function has been renamed to
Init__<name> (via -DInit__Dynamic=Init__<name> when compiling it).

Idempotent: running twice for the same module is a no-op. Usage:
    register_static_module.py <module-name> [path/to/compstat.c]
"""
import re
import sys

name = sys.argv[1]
path = sys.argv[2] if len(sys.argv) > 2 else "src/compstat.c"
init = "Init__" + name

src = open(path).read()
if init in src:
    sys.exit(0)  # already registered

# Add the extern declaration after the last existing one.
externs = list(re.finditer(r"extern StructInitInfo \* Init__\w+\(void\);\n", src))
if not externs:
    sys.exit("register_static_module: no extern declarations found in " + path)
at = externs[-1].end()
src = src[:at] + "extern StructInitInfo * %s(void);\n" % init + src[at:]

# Add the entry before the 0 terminator of CompInitFuncs[].
src, n = re.subn(r"\n(\s*)0(,?\n\};)", r"\n\1%s,\n\g<1>0\2" % init, src, count=1)
if n != 1:
    sys.exit("register_static_module: could not find CompInitFuncs terminator in " + path)

open(path, "w").write(src)
