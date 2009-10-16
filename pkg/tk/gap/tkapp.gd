#############################################################################
##
#A  tkapp.gd                      for Tk                       Michael Ummels
##
#H  @(#)$Id: tkapp.gd,v 1.4 2003/09/28 13:41:14 gap Exp $
##
#Y  Copyright 2002-03         Michael Ummels                  Aachen, Germany
##
##  An interface to implement GAP applications using the Tk toolkit
##

Revision.pkg_tk_gap_tkapp_gd :=
  "@(#)$Id: tkapp.gd,v 1.4 2003/09/28 13:41:14 gap Exp $";

# Some global variables
BindGlobal("TkApplicationFamily", NewFamily("TkApplication"));
BindGlobal("TkEventFamily", NewFamily("TkEvent"));

BindGlobal("TK_EVENT_TYPES", ["Activate", "ButtonPress", "ButtonRelease",
"Circulate", "CirculateRequest", "Colormap", "Configure", "ConfigureRequest",
"Create", "Deactivate", "Destroy", "Enter", "Expose", "FocusIn", "FocusOut",
"Gravity", "KeyPress", "KeyRelease", "Leave", "Map", "MapRequest",
"Motion", "MouseWheel", "Property", "Reparent", "ResizeRequest", "Unmap",
"Visibility"]);

BindGlobal("TK_EVENT_MODIFIERS", ["Control", "Shift", "Lock", "Button1",
  "Button2", "Button3", "Button4", "Button5", "Mod1", "Mod2", "Mod3", "Mod4",
  "Mod5", "Meta", "Alt", "Double", "Triple", "Quadruple"]);

# Categories for our objects
DeclareCategory("IsTkApplication", IsObject);
DeclareCategory("IsTkEvent", IsObject);
DeclareCategory("IsTkMenuFunction", IsObject);

#
# Set the window title of a TkApplication
#
DeclareOperation("SetWindowTitle", [IsTkApplication, IsString]);

#
# Registers a new event to a TkApplication
#
DeclareOperation("RegisterEvent", [IsTkApplication, IsTkEvent, IsFunction]);

#
# Return whether an event is registered by a TkApplication
#
DeclareOperation("IsRegisteredEvent", [IsTkApplication, IsTkEvent]);

#
# Unregisters an event from a TkApplication
#
DeclareOperation("UnregisterEvent", [IsTkApplication, IsTkEvent]);

#
# Insert a TkMenuFunction as a menu item of a TkApplication
#
DeclareOperation("RegisterMenuItem", [IsTkApplication, IsString, IsFunction,
  IsFunction, IsPosInt]);

DeclareOperation("RegisterMenuItem", [IsTkApplication, IsString, IsFunction,
  IsPosInt]);

DeclareOperation("RegisterMenuItem", [IsTkApplication, IsString, IsFunction,
  IsFunction]);

DeclareOperation("RegisterMenuItem", [IsTkApplication, IsString, IsFunction,]);

#
# Remove a certain menu item of a TkApplication
#
DeclareOperation("UnregisterMenuItem", [IsTkApplication, IsPosInt]);
DeclareOperation("UnregisterMenuItem", [IsTkApplication, IsString]);

#
# Create a new TkEvent
#
DeclareOperation("TkEvent", [IsString, IsString, IsList]);
DeclareOperation("TkEvent", [IsString, IsList]);
DeclareOperation("TkEvent", [IsString]);

#
# Create a function that works on a TkApplication
#
DeclareOperation("TkMenuFunction", [IsFunction, IsString, IsFunction]);
DeclareOperation("TkMenuFunction", [IsFunction, IsString]);

#
# Return the event type of a TkEvent
#
DeclareAttribute("Type", IsTkEvent);

#
# Return the event detail of a TkEvent
#
DeclareAttribute("Detail", IsTkEvent);

#
# Return the modifiers of a TkEvent
#
DeclareAttribute("Modifiers", IsTkEvent);

#
# Return the Tk code of a TkEvent
#
DeclareAttribute("Code", IsTkEvent);
