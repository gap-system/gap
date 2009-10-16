#############################################################################
##
#W  tk.gd                  Tk share package                   Max Neunhoeffer
##
#H  @(#)$Id: tk.gd,v 1.2 2002/10/26 08:01:56 gap Exp $
##
#Y  Copyright 2001,       Max Neunhoeffer,              Aachen,       Germany
##
##  Package to connect GAP to Tcl/Tk.
##

Revision.pkg_tk_gap_tk_gd :=
    "@(#)$Id: tk.gd,v 1.2 2002/10/26 08:01:56 gap Exp $";

    
############################################################################
##
#I  An info class for Tk:
##
DeclareInfoClass("TkInfo");


############################################################################
##
#C  A family and a category for all our objects:
##
BindGlobal("TkObjFamily",NewFamily("TkObjFamily"));
DeclareCategory("IsTkObj",IsObject);


#############################################################################
##
#F  IsLiving( <gobj> )  . . . . . . . . . filter for living displayed objects
##
##  This filter controls if a graphic object is <living>, meaning that it can
##  be used for further graphic operations.
##
DeclareFilter( "IsLiving" );


############################################################################
##
#V  A few global variables for this package:
##
DeclareGlobalVariable("TkVars", "a record with the global variables");
DeclareGlobalVariable("TkPossibleWidgetTypes");
DeclareGlobalVariable("TkPossibleItemTypes");

############################################################################
##
##  Some helper functions:
##
DeclareGlobalFunction("TkSubStringPos", "search for a substring");
DeclareGlobalFunction("TkRecToStr", "make command string from record");
DeclareGlobalFunction("TkComToStr", "strictly internal");
DeclareGlobalFunction("TkQuote", "puts quotes around string");



############################################################################
##
##  Functions used to communicate with Tk:
##
##  they are mainly internal, so here only declared. See tk.gi for details.
##
DeclareGlobalFunction("TkReadLine", "read a line from wish process");
DeclareGlobalFunction("TkProcessEvent", "process one event");
DeclareGlobalFunction("TkProcessQueue", "process pending events");
DeclareGlobalFunction("TkCmd", "send a command to Tk, handle errors");
DeclareGlobalFunction("TkValue", "ask a value from Tk, handle errors");
DeclareGlobalFunction("TkStreamHandler", "handle input from the stream");


############################################################################
##
##  Functions to be called by the user of this package:
##
############################################################################


############################################################################
##
#F  TkInit( ) . . . . . . . . . . . . . . . . . . .  initialize wish process
##
##  The wish process is started, and all data structures are
##  initialized. The user can call this but does not have to, because it
##  is called automatically from all other functions if not yet done.
##  Returns `true' on success or if already initizalized and `fail'
##  otherwise.
##
DeclareGlobalFunction("TkInit", "initializes wish process");

############################################################################
##
#F  TkShutdown( ) . . . . . . . . . . . . . . . . .  shuts down wish process
##
##  This shuts down the wish process and all data structures in the package.
##  Returns `true'.
##
DeclareGlobalFunction("TkShutdown", "shuts down wish process");

############################################################################
##
#F  Tk( <arg1>, ... ) . . . . . . . . . . . . .  send a command to Tk easily
##
##  This function is used to send an arbitrary command to Tk. All
##  arguments are converted to strings and concatenated with spaces in
##  between. A record is converted to a string of options, that is each
##  bound entry is put into the string with a `-' in front and followed
##  by its value as a string. For all other objects we call `String'.
##  This works in particular for `TkWidget's and `TkItem's. Do not use
##  this to create `TkWidget's and `TkItem's. Use the corresponding
##  contructor functions instead! Returns the result Tk sends back.
##  
DeclareGlobalFunction("Tk", "sends a command to Tk easily");


############################################################################
##
#F  TkProcessEvents( ) . . . . . . . . .  processes events until some signal
##
##  This function processes events and callbacks until one of these events
##  sets the global variable TkVars.Done to true. Then it returns. This is
##  useful if an application wants to suspend itself until something 
##  happens without using up CPU time.
##
DeclareGlobalFunction("TkProcessEvents", "processes events");


############################################################################
##
#F  TkWidget( <arg1>, ... ) . . .  send a command to Tk to create a TkWidget
##
##  This function is used to send a command to Tk that creates a widget.
##  The first argument should be the type of widget and should be one
##  in the list `TkPossibleWidgetTypes'. Otherwise a warning is issued.
##  If the second argument is a `TkWidget' it is considered to be the
##  parent of the new widget. If the second argument is no `TkWidget'
##  or not present at all, then `TkRootWindow' is taken as parent. All
##  other arguments are converted to strings and concatenated with
##  spaces in between. A record is converted to a string of options,
##  that is each bound entry is put into the string with a `-' in front
##  and followed by its value as a string. For all other objects we call
##  `String'. This works in particular for `TkWidget's and `TkItem's.
##  Use this to create `TkWidget's. For `TkItem's use the corresponding
##  contructor function instead! Returns a new `TkWidget' or `fail' in
##  case of an error.
##  
DeclareGlobalFunction("TkWidget", 
                      "sends a command to Tk that creates a TkWidget");

############################################################################
##
#F  TkItem( <arg1>, ... ) . . . . .  send a command to Tk to create a TkItem
##
##  This function is used to send a command to Tk that creates an item
##  in a canvas widget. The first argument should be the type of the
##  item and should be one in the list `TkPossibleItemTypes'. Otherwise
##  a warning is issued. The second argument must be a `TkWidget' it
##  is the parent of the new item. All other arguments are converted
##  to strings and concatenated with spaces in between. A record is
##  converted to a string of options, that is each bound entry is put
##  into the string with a `-' in front and followed by its value
##  as a string. For all other objects we call `String'. This works
##  in particular for `TkWidget's and `TkItem's. Use this to create
##  `TkItem's. For `TkWidget's use the corresponding contructor function
##  instead! Returns a new `TkItem' or `fail' in case of an error.
##  
DeclareGlobalFunction("TkItem", 
                      "sends a command to Tk that creates a TkItem");


############################################################################
##
#F  TkDelete( <TkWidget> ) . . . . . .  destroys a widget or deletes an item
##
##  This function is used to destroy a TkWidget or delete a TkItem within
##  a canvas. All installed events or callbacks are deleted also. This is
##  necessary to free memory within GAP (allocated by the tk package).
##
DeclareOperation("TkDelete",[IsTkObj]);


############################################################################
##
#F  TkPack( <arg1>, ... ) . . . . . .  see Tk, but put "pack" before command
##
##  The same as `Tk', but puts "pack" before command and returns 1st 
##  argument or `fail'.
##
DeclareGlobalFunction("TkPack");


############################################################################
##
#F  TkGrid( <arg1>, ... ) . . . . . .  see Tk, but put "grid" before command
##
##  The same as `Tk', but puts "grid" before command and returns 1st 
##  argument or `fail'.
##
DeclareGlobalFunction("TkGrid");


############################################################################
##
##  Operations for `TkWidget's and `TkItem's:
##
############################################################################

############################################################################
##
#O  TkBind( <arg1>, ... ) . . . . . . . . . . . . . see Tk, but for bindings
##
##  Essentially the same as `Tk', but puts "bind" before command and 
##  organizes callback. Without function an unbind is performed.
##
DeclareOperation("TkBind",[IsTkObj,IsString,IsFunction,IsList]);
DeclareOperation("TkBind",[IsTkObj,IsString,IsFunction]);
DeclareOperation("TkBind",[IsTkObj,IsString]);


############################################################################
##
#O  TkLink(<widget>, <scrollbar>, <mode>) . connect a scrollbar and a widget
##
##  Link a widget and a scrollbar. <mode> must be "v" or "vertical" or
##  "h" or "horizontal" and specifies whether the scrollbar handles
##  the y coordinate or the x coordinate of the widget respectively.
##
DeclareOperation("TkLink",[IsTkObj,IsTkObj,IsString]);


