#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the definition of operations and functions for
##  weak pointers.
##
##  WP objects behave in most respects like mutable plain lists, except that
##  they do not keep their subobjects alive, so that one sees things like.
##
##  gap> w := WeakPointerObj([[1,2]]);;
##  gap> IsBound(w[1]);
##  true
##  gap> CollectGarbage( true );
##  gap> w;
##  WeakPointerObj([ [ ] ]);
##
##  for this reason the common idiom
##
##  if IsBound(w[i]) then
##     DoSomethigWith(w[i]);
##  fi;
##
##  is not really safe.
##
##  A solution is provided by the kernel function ElmWPObj (weakptr.c), which
##  returns fail if the entry is (1) unbound or (2) bound to the value fail.
##  Since fail will never be collected as garbage, a subsequent call to IsBound
##  can safely be used to distinguish these two cases, as in:
##
##  x := ElmWPObj(w,i);
##  if x <> fail or IsBound(w[i]) then
##     DoSomethingWith(x);
##  else
##     DoSomethingElse();
##  fi;
##



#############################################################################
##
##
#C  IsWeakPointerObject( <obj> ) . . .  . . . . . . . category of  WP objects
##
##  All WP objects have to be mutable (a stronger term like volatile would
##  be appropriate),
##  but this cannot be expressed via an explicit implication;
##  note that `Immutable' is handled by the kernel.
##

DeclareCategoryKernel( "IsWeakPointerObject",
    IsList and IsSmallList,
    IsWPObj );
