#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Andrew Solomon.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Declarations of utilities for fast prototyping of new GAP objects.
##


##########################################################################
##
#F  ArithmeticElementCreator(<spec>)
##
InstallGlobalFunction(ArithmeticElementCreator,
function(spec)
  local
    makeelt,        # the function returned
    inst_str,
    inst_str_bin,   # method installation strings
    repfilters,     # filters for representation
    mathfilters,    # filters for categories and properties
    cat, rep,       # the category and representation of the new elts
    allfilters,     # category and representation
    eFam, eType;    # the element family and element type

  # first check to see this hasn't already been done
  if IsBoundGlobal(Concatenation("Is",spec.ElementName)) then
    Error(Concatenation(spec.ElementName," already defined"));
  fi;

  # What mathematical filters can we deduce?
  mathfilters := IsObject;

  if IsBound(spec.Multiplication) then
    mathfilters :=  mathfilters and IsMultiplicativeElement;
  fi;

  if IsBound(spec.One) then
    mathfilters :=  mathfilters and IsMultiplicativeElementWithOne;
  fi;

  if IsBound(spec.Inverse) then
    mathfilters :=  mathfilters and IsMultiplicativeElementWithInverse;
  fi;

  if IsBound(spec.Addition) then
    mathfilters :=  mathfilters and IsNearAdditiveElement;
  fi;

  if IsBound(spec.Zero) then
    mathfilters :=  mathfilters and IsNearAdditiveElementWithZero;
  fi;

  if IsBound(spec.AdditiveInverse) then
    mathfilters :=  mathfilters and IsNearAdditiveElementWithInverse;
  fi;

  # what mathematical filters are explicitly asserted?
  if IsBound(spec.MathInfo) then
    mathfilters :=  mathfilters and spec.MathInfo;
  fi;

  # declare the elements category and collections category
  cat := NewCategory(Concatenation("Is",spec.ElementName), mathfilters);
  BindGlobal(Concatenation("Is",spec.ElementName), cat);
  DeclareCategoryCollections(Concatenation("Is",spec.ElementName));

  # See what representation specific filters we have.
  repfilters := IsComponentObjectRep;
  if IsBound(spec.RepInfo) then
    repfilters := repfilters and spec.RepInfo;
  fi;

  # declare the representastion with the single "data" component
  rep := NewRepresentation(Concatenation(spec.ElementName,"Rep"),
    repfilters, ["data"]);
  BindGlobal(Concatenation(spec.ElementName,"Rep"), rep);

  allfilters := cat and rep;

  # create the family
  eFam := NewFamily(Concatenation("Element family of ", spec.ElementName),
    cat);

  # create the type
  eType := NewType(eFam, allfilters);

  # the creation function
  makeelt := x->Objectify(eType, rec(data := x));
  ##
  ## Install the methods
  ##
  inst_str := Concatenation("for ", spec.ElementName);
  inst_str_bin := Concatenation("for ",spec.ElementName,
    " and ",spec.ElementName);

  if IsBound(spec.Multiplication) then
    InstallOtherMethod(\*, inst_str_bin, IsIdenticalObj,
    [allfilters, allfilters], 0,
    function(x, y) return makeelt(spec.Multiplication(x!.data, y!.data)); end);
  fi;

  if IsBound(spec.One) then
    InstallOtherMethod(OneOp, inst_str, true, [allfilters], 0,
    function(x) return makeelt(spec.One(x!.data)); end);
  fi;

  if IsBound(spec.Inverse) then
    InstallOtherMethod(InverseOp, inst_str, true, [allfilters], 0,
    function(x) return makeelt(spec.Inverse(x!.data)); end);
  fi;

  if IsBound(spec.Addition) then
    InstallOtherMethod(\+, inst_str_bin, IsIdenticalObj,
    [allfilters, allfilters], 0,
    function(x,y) return makeelt(spec.Addition(x!.data, y!.data)); end);
  fi;

  if IsBound(spec.Zero) then
    InstallOtherMethod(ZeroOp, inst_str, true, [allfilters], 0,
    function(x) return makeelt(spec.Zero(x!.data)); end);
  fi;

  if IsBound(spec.AdditiveInverse) then
    InstallOtherMethod(AdditiveInverseOp, inst_str,true, [allfilters], 0,
    function(x) return makeelt(spec.AdditiveInverse(x!.data)); end);
  fi;

  if IsBound(spec.Equality) then
    InstallOtherMethod(\=, inst_str_bin, IsIdenticalObj,
      [allfilters, allfilters], 0,
      function(x,y) return spec!.Equality(x!.data, y!.data); end);
  else
  InstallOtherMethod(\=, inst_str_bin, IsIdenticalObj,
    [allfilters, allfilters], 0,
    function(x,y) return x!.data = y!.data; end);
  fi;

  if IsBound(spec.LessThan) then
    InstallOtherMethod(\<, inst_str_bin, IsIdenticalObj,
      [allfilters, allfilters], 0,
      function(x,y) return spec!.LessThan(x!.data, y!.data); end);
  else
    InstallOtherMethod(\<, inst_str_bin, IsIdenticalObj,
      [allfilters, allfilters], 0,
      function(x,y) return x!.data < y!.data; end);
  fi;

  if IsBound(spec.Print) then
    InstallOtherMethod(PrintObj, inst_str,true, [allfilters], 0,
    function(x) spec.Print(x!.data); end);
  else
    InstallOtherMethod(PrintObj, inst_str,true, [allfilters], 0,
    function(x) Print(x!.data); end);
  fi;

  InstallOtherMethod(UnderlyingElement, inst_str, true,
    [allfilters], 0,
    function(x) return x!.data; end);

  return makeelt;

end);
