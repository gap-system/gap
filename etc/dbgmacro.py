#
# Engine to build macros
#

import re, string
paren = re.compile(r"(.*[^\s]\s+|.*\*)([A-Za-z_][A-Za-z0-9_]*)\s*\((.*)\)")
comma = re.compile(r"(?:\s*),(?:\s*)")

def extract_macro(line):
  result = paren.match(line);
  if not result:
    return None, None, None
  groups = result.groups()
  if len(groups) != 3:
    return None, None, None
  macro_type, macro_name, macro_args = groups
  if re.match(r"\s*$", macro_args):
    macro_arg_list = []
  else:
    macro_arg_list = comma.split(macro_args)
  return macro_type, macro_name, macro_arg_list

def emit(line):
  print line

def sysinclude(file):
  emit('#include <'+file+'>')

def include(file):
  emit('#include "'+file+'"')

def emit_redef(return_type, name, arg_types):
  arg_names = map(lambda n: "arg"+str(n), range(len(arg_types)))
  args = map(lambda (t, a): t + " " + a, zip(arg_types, arg_names))
  emit("")
  emit("#ifdef " + name)
  emit("")
  emit(return_type + "DBG_" + name + "(" + ", ".join(args) + ")")
  emit("{")
  if len(args):
    if re.match("void\s*", return_type):
      emit("  " + name + "(" + ", ".join(arg_names) + ");")
    else:
      emit("  return " + name + "(" + ", ".join(arg_names) + ");")
  else:
    if re.match("void\s*", return_type):
      emit("  " + name + ";")
    else:
      emit("  return " + name + ";")
  emit("}")
  emit("")
  emit("#undef " + name)
  emit("")
  emit(return_type + name + "(" + ", ".join(args) + ")")
  emit("{")
  if re.match("void\s*", return_type):
    emit("  DBG_" + name + "(" + ", ".join(arg_names) + ");")
  else:
    emit("  return DBG_" + name + "(" + ", ".join(arg_names) + ");")
  emit("}")
  emit("")
  emit("#endif")

def macros(lines):
  for line in string.split(lines, "\n"):
    if not re.match(r"\s*$", line):
      return_type, name, arg_types = extract_macro(line)
      if return_type:
	emit_redef(return_type, name, arg_types)

#
# Define actual include files and macros
#

emit("#ifndef WARD_ENABLED")
emit("")

sysinclude("assert.h")
include("system.h")
include("gasman.h")
include("objects.h")
include("scanner.h")
include("gap.h")
include("read.h")
include("gvars.h")
include("calls.h")
include("opers.h")
include("ariths.h")
include("records.h")
include("lists.h")
include("bool.h")
include("integer.h")
include("permutat.h")
include("precord.h")
include("plist.h")
include("range.h")
include("string.h")
include("code.h")
include("funcs.h")
include("read.h")
include("intrprtr.h")
include("hpc/tls.h")
include("hpc/thread.h")
include("hpc/aobjects.h")
include("vars.h")

macros("""
UInt TNUM_OBJ(Obj);
const char *TNAM_OBJ(Obj);
UInt SIZE_BAG(Bag);
UInt SIZE_OBJ(Obj);
UInt TEST_OBJ_FLAG(Bag, UInt);
void SET_OBJ_FLAG(Bag, UInt);
void CLEAR_OBJ_FLAG(Bag, UInt);
Obj *ADDR_OBJ(Bag);
Obj *PTR_BAG(Bag);
Region *DS_BAG(Bag);

Obj FAMILY_TYPE(Obj);
Obj FAMILY_OBJ(Obj);
Obj TYPE_OBJ(Obj);
void SET_TYPE_OBJ(Obj, Obj);
Obj SHALLOW_COPY_OBJ(Obj);

Obj INTOBJ_INT(Int);
Int INT_INTOBJ(Obj);

Obj ELM_PLIST(Obj, Int);
void SET_ELM_PLIST(Obj, UInt, Obj);
UInt LEN_PLIST(Obj);

Obj ELM_LIST(Obj, Int);
Obj ELM0_LIST(Obj, Int);
void SET_ELM_LIST(Obj, UInt, Obj);
UInt LEN_LIST(Obj);

Obj NAME_FUNC(Obj);
Obj BODY_FUNC(Obj);
Int NARG_FUNC(Obj);
Obj NAMS_FUNC(Obj);
Obj ENVI_FUNC(Obj);
ObjFunc HDLR_FUNC(Obj, UInt);
Obj CURR_FUNC();
Char *CSTR_STRING(Obj);
""")

emit("")
emit("#endif")
