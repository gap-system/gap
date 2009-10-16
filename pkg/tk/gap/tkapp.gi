#############################################################################
##
#A  tkapp.gi                      for Tk                       Michael Ummels
##
#H  @(#)$Id: tkapp.gi,v 1.3 2003/08/20 21:06:14 gap Exp $
##
#Y  Copyright 2002-03         Michael Ummels                  Aachen, Germany
##
##  An interface to implement GAP applications using the Tk toolkit
##

Revision.pkg_tk_gap_tkapp_gi :=
  "@(#)$Id: tkapp.gi,v 1.3 2003/08/20 21:06:14 gap Exp $";

# Representations for our objects
DeclareRepresentation("IsTkMenuFunctionRep", IsComponentObjectRep, ["method",
  "caption", "requirement"]);
DeclareRepresentation("IsTkEventRep", IsComponentObjectRep, ["type", "detail",
  "modifiers", "code"]);

#
# Create a new TkEvent
#
InstallMethod(TkEvent, "for a string, a string and a list", true, [IsString,
  IsString, IsList], 0, function(type, detail, modifiers)
    local res, code, modif;

    modifiers := Set(modifiers);
    if type in TK_EVENT_TYPES and IsSubsetSet(TK_EVENT_MODIFIERS, modifiers)
      and (((type = "KeyPress" or type = "KeyRelease") and not detail = "") or
      ((type = "ButtonPress" or type = "ButtonRelease") and detail in ["1",
      "2", "3", "4", "5"]) or (not(type = "KeyPress" or type = "KeyRelease" or
      type = "ButtonPress" or type = "ButtonRelease") and detail = "")) then
      code := "";
      if not modifiers = [] then
        for modif in modifiers do
          Append(code, Concatenation(modif, "-"));
        od;
      fi;
      Append(code, type);
      if not detail = "" then
        Append(code, Concatenation("-", detail));
      fi;
      res := rec(type := type, detail := detail, modifiers := modifiers,
        code := code);
      Objectify(NewType(TkEventFamily, IsTkEvent and IsTkEventRep), res);
      return res;
    else
      Error("TkEvent: Wrong event specification");
    fi;
  end);

InstallMethod(TkEvent, "for a string and a string", true, [IsString, IsString],
  0, function(type, detail)
    return TkEvent(type, detail, []);
  end);

InstallMethod(TkEvent, "for a string and a list", true, [IsString, IsList],
  0, function(type, modifiers)
    return TkEvent(type, "", modifiers);
  end);

InstallMethod(TkEvent, "for a string", true, [IsString], 0,
  function(type)
    return TkEvent(type, "", []);
  end);

#
# Return the event type of a TkEvent
#
InstallMethod(Type, "for a TkEvent", true, [IsTkEvent and IsTkEventRep], 0,
  function(obj)
    return obj!.type;
  end);

#
# Return the event detail of a TkEvent
#
InstallMethod(Detail, "for a TkEvent", true, [IsTkEvent and IsTkEventRep], 0,
  function(obj)
    return obj!.detail;
  end);

#
# Return the modifiers of a TkEvent
#
InstallMethod(Modifiers, "for a TkEvent", true, [IsTkEvent and IsTkEventRep],
  0, function(obj)
    return obj!.modifiers;
  end);

#
# Return the Tk code of a TkEvent
#
InstallMethod(Code, "for a TkEvent", true, [IsTkEvent and IsTkEventRep], 0,
  function(obj)
    return obj!.code;
  end);

#
# Return if two TkEvents are equal
#
InstallMethod(\=, "for a TkEvent and a TkEvent", true, [IsTkEvent and
  IsTkEventRep, IsTkEvent and IsTkEventRep], 0, function(obj1, obj2)
    return obj1!.type = obj2!.type and obj1!.detail = obj2!.detail and
      obj1!.modifiers = obj2!.modifiers;
  end);

InstallMethod(\<, "for a TkEvent and a TkEvent", true, [IsTkEvent and
  IsTkEventRep, IsTkEvent and IsTkEventRep], 0, function(obj1, obj2)
    return obj1!.type < obj2!.type or (obj1!.type = obj2!.type and obj1!.detail
    < obj2!.detail) or (obj1!.type = obj2!.type and obj1!.detail = obj2!.detail
    and obj1!.modifiers < obj2!.modifiers);
  end);

#
# Print a representation of a TkEvent
#
InstallMethod(PrintObj, "for a TkEvent", true, [IsTkEvent], 0,
  function(obj)
    Print("<TkEvent \"", Code(obj), "\">");
  end);
