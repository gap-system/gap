#############################################################################
##
##  classes.gd                       CRISP                   Burkhard Höfling
##
##  @(#)$Id: classes.gd,v 1.3 2011/05/15 19:17:07 gap Exp $
##
##  Copyright (C) 2000 Burkhard Höfling
##
Revision.classes_gd :=
    "@(#)$Id: classes.gd,v 1.3 2011/05/15 19:17:07 gap Exp $";


#############################################################################
##
#C  IsClass (<obj>)
##
##  category of (set theoretic) classes
##
DeclareCategory ("IsClass", IsListOrCollection);


#############################################################################
##
#A  MemberFunction (<obj>)
##
##  function tests whether <obj> belongs to the class
##
DeclareAttribute ("MemberFunction", IsClass); 


#############################################################################
##
#A  IsMember (<obj>, <class>)
##
##  tests whether <obj> belongs to the class <class>. A class representation
##  should install a method for `IsMember', rather than \in, so that the 
##  result of the membership test can be stored in <obj> if the latter 
##  belongs to IsAttributeStoringRep.
##
KeyDependentOperation ("IsMember", IsObject, IsClass, ReturnTrue); 


#############################################################################
##
#O  Class (<obj>)
##
##  create a class from an object
##
DeclareOperation ("Class", [IsObject]);


#############################################################################
##
#O  Complement (<class>)
##
##  compute the (unary) complement of a class, consisting of all elements 
##  which do not belong to <class>
##
DeclareOperation ("Complement", [IsListOrCollection]);


#############################################################################
##
#F  NewClass (<fam/name>, <rep>, <data>)
##
##  generates a new class with unique class id, belonging to the filter 
##  <rep>. <data> is the data (a record or list) in the object representing
##  the class.
##
DeclareGlobalFunction ("NewClass");


#############################################################################
##
#F  InstallDefiningAttributes (<cls>, <rec>)  . . . . . . . . . . . . . local
##
##  takes record components from <rec>, and if admissible, installs them as 
##  attributes of the group class <cls>. The list <allowed> consists of pairs
##  [<fld>, <setter>]. If <fld> is a record field of <rec>, 
##  <setter>(<cls>, <fld>) is called, and otherwise an error is printed.
##
DeclareGlobalFunction ("InstallDefiningAttributes");


#############################################################################
##
#F  ViewDefiningAttributes (<cls>) . . . . . . . . . . . . . . . . . . local
##
DeclareGlobalFunction ("ViewDefiningAttributes");


#############################################################################
##
#F  PrintDefiningAttributes (<cls>) . . . . . . . . . . . . . . . . . . local
##
DeclareGlobalFunction ("PrintDefiningAttributes");


#############################################################################
##
#E
##
