#############################################################################
##
#W  info.gd                     GAP library                      Steve Linton
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This package sets up the new Info messages system
##  
##  Informational messages are controlled by the user setting desired
##  levels of verbosity for InfoClasses. A set of InfoClasses is an
##  InfoSelector, and classes and selectors may be built up with \+
#N  I wanted to use \or, but this isn't at operation
##  
##  A message is associated with a selector and a level and is
##  printed when the desired level for any of the classes in the selector
##  equals or exceeds  the level of the message
##
##  The main user calls are  NewInfoClass( <name> ) to define a new class,
##  \+ or \[\] to combine InfoClasses into an InfoSelector 
##  SetInfoLevel( <class>, <level> ) to set desired printing levels and
##  Info( <selector>, <level>, <data>, <moredata>, ... ) to selectively print
##  <data>, <moredata>, etc.
##
##  Also available are InfoLevel( <class> ) to inspect the level, and 
##  SetAllInfoLevels( <level> ) 
##
#N  There may be a case for doing this without using method selection at all
#N  as it could then be installed earlier in library loading
#N
##
##  This file is the declarations part of that package
##
Revision.info_gd :=
    "@(#)$Id$";

#############################################################################
##
#C  IsInfoClass(<obj>)                           the category of Info Classes
##

IsInfoClass := NewCategory("IsInfoClass", IsObject);

#############################################################################
##
#V  InfoClassFamily                                the family of Info Classes
##

InfoClassFamily := NewFamily("InfoClassFamily", IsInfoClass, IsInfoClass);

#############################################################################
##
#C  IsInfoSelector(<obj>)                 the category of sets of InfoClasses
##         
##  Such sets are what we actually use in message selection
##

IsInfoClassCollection := CategoryCollections( IsInfoClass );

IsInfoSelector := IsInfoClassCollection and IsSSortedList;

#############################################################################
##
#O  NewInfoClass( <name> )                            obtain a new Info Class
##
##  The name is used only for printing, and is not checked for uniqueness
##

NewInfoClass := NewOperation("NewInfoClass", 
                     [IsString] );

             
#############################################################################
##
#O  SetInfoLevel( <class>, <level>)   set desired verbosity level for a class  
##
#N  Is it sensible to SetInfoLevel for a selector?
#N  Would RaiseInfoLevel (which would not lower it if it were already higher
#N  or LowerInfoLevel (the opposite) be any use?
##
##  Info level 0 means no #I messages, higher levels produce more messages
##

SetInfoLevel := NewOperation("SetInfoLevel", 
                        [IsInfoClass, IsInt]);

#############################################################################
##
#O  InfoLevel( <class> )              get desired verbosity level for a class  
##
#N Does this make sense for a selector (gets the max of the levels for the
#N classes that make up the selector, presumably)? 
#N
#N In the final version, this will have to be done directly, not via an 
#N Operation, as the kernel needs to do it quickly, and for a whole selector
##

InfoLevel := NewOperation("InfoLevel", 
                        [IsInfoClass]);

#############################################################################
##
#O  Info( <selector>, <level>, <data> [, <moredata>...] )      possibly print
##                                                                  a message
##
##  If the desired verbosity level for any of the classes making up selector
##  is equal to or greater than level, then this function should Print "#I  "
##  then do CallFuncList(Print, <data> ...) (where <data> may be multiple
##  arguments), then Print a newline
##
##  Info is now a keyword, implemented in the kernel, so that data arguments
##  are not evaluated when they are not needed
##

##  Info := NewOperationArgs("Info");

        
#############################################################################
##
#E  info.gd ends here  
##

        

