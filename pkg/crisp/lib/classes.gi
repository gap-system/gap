#############################################################################
##
##  classes.gi                       CRISP                   Burkhard Höfling
##
##  @(#)$Id: classes.gi,v 1.5 2011/05/15 19:17:50 gap Exp $
##
##  Copyright (C) 2000, 2003 Burkhard Höfling
##
Revision.classes_gi :=
    "@(#)$Id: classes.gi,v 1.5 2011/05/15 19:17:50 gap Exp $";


#############################################################################
##
#M  \in
##
##  tests whether <obj> belongs to the class <class>. A class representation
##  should install a method for `IsMemberOp', rather than \in, so that the 
##  result of the membership test can be stored in <obj>, provided <obj> is
##  in IsAttributeStoringRep.
##
InstallMethod (\in, "for class, delegate to IsMember", true, 
   [IsObject, IsClass], 0, 
   function (x, C)
      if IsMember (x, C) then
         SetIsEmpty (C, false);
         return true;
      else
         return false;
      fi;
   end);


#############################################################################
##
#M  \in
##
InstallMethod (\in, "empty class", true, 
   [IsObject, IsClass and IsEmpty], 0, 
   ReturnFalse);


#############################################################################
##
#V  CLASS_ID_COUNT
##
##  used to assign a unique id to each new class generated with `NewClass'
##  this is required when attributes depending on a class are to be stored
##  using `KeyDependentOperation' because they need to be sortable via `<'
##
BindGlobal ("CLASS_ID_COUNT", 0);


#############################################################################
##
#V  INTERSECTION_LIMIT
##
##  an intersection of a class and a list with fewer than INTERSECTION_LIMIT 
##  elements will be a list
##
BindGlobal ("INTERSECTION_LIMIT", 1000);


#############################################################################
##
#F  NewClass (<fam/name>, <rep>, <data>)
##
##  generates a new class with unique class id, belonging to the filter rep
##
InstallGlobalFunction (NewClass, function (famname, rep, data)

   local fam, class;
   
   MakeReadWriteGlobal ("CLASS_ID_COUNT");
   CLASS_ID_COUNT := CLASS_ID_COUNT + 1;
   MakeReadOnlyGlobal ("CLASS_ID_COUNT");
   
   if IsString (famname) then
      fam := NewFamily (famname, IsClass, IsClass);
   else
      fam := famname;
   fi;
   class := Objectify (NewType (fam, rep), data);
   class!.classId := CLASS_ID_COUNT;
   return class;
end);


#############################################################################
##
#F  InstallDefiningAttributes (<cls>, <rec>)  . . . . . . . . . . . . . local
##
InstallGlobalFunction ("InstallDefiningAttributes",
   function (class, record)
   
      local r, f, undef;

      r := ShallowCopy (record);
      undef := true;
      
      if IsBound (r.name) then
         SetName (class, r.name);
         Unbind (r.name);
      fi;
      
      for f in class!.definingAttributes do
         if IsBound (r.(f[1])) then
            Setter (f[2]) (class, r.(f[1]));
            Unbind (r.(f[1]));
            undef := false;
         fi;
      od;
      if undef then
         Error ("The record components do not define <class>.");
      fi;
      if not IsEmpty (RecNames (r)) then
         Error ("The components ", RecNames(r), " of r could not be used");
      fi;
   end);
   

#############################################################################
##
#F  ViewDefiningAttributes (<cls>) . . . . . . . . . . . . . . . . . . local
##
InstallGlobalFunction ("ViewDefiningAttributes",

   function (C)
   
      local sep, a;
      
      sep := false;
      
      for a in C!.definingAttributes do
         if Tester (a[2])(C) then
            if sep then
               Print (", ");
            else
               sep := true;
            fi;
            Print (a[1], ":=");
            ViewObj (a[2](C));
         fi;
      od;
   end);


#############################################################################
##
#F  PrintDefiningAttributes (<cls>) . . . . . . . . . . . . . . . . . . local
##
InstallGlobalFunction ("PrintDefiningAttributes",

   function (C)
   
      local sep, a;
      
      sep := false;

      Print ("rec (\n");
      for a in C!.definingAttributes do
         if Tester (a[2])(C) then
            if sep then
               Print (", \n");
            else
               sep := true;
            fi;
            Print (a[1], " := ", a[2](C));
         fi;
      od;
      Print (")");
   end);


#############################################################################
##
#M  String (<class>)
##
InstallMethod (String, "for a class", true,
   [IsClass], 0,
   function (C)
      local str, stream;
      str := "";
      stream := OutputTextString (str, true);
      PrintTo (stream, C);
      CloseStream (stream);
      return str;
   end);
   

#############################################################################
##
#M  \< 
##
InstallMethod (\<, "for classes", true, [IsClass, IsClass], 0,
   function (C, D)
      return C!.classId < D!.classId;
   end);
   
   
#############################################################################
##
#M  \=
##
InstallMethod (\=, "for classes", true, [IsClass, IsClass], 0,
   function (C, D)
      return C!.classId = D!.classId;
   end);
   
   
#############################################################################
##
#R  IsClassByPropertyRep (<func>)
##
##  contains classes defined by a function f, consisting of all elements 
##  for which f returns true
##
DeclareRepresentation ("IsClassByPropertyRep", 
   IsClass and IsComponentObjectRep and IsAttributeStoringRep, 
   ["classId", "definingAttributes"]);


#############################################################################
##
#M  Class (<rec>)
##
##  returns the class defined by rec
##
InstallMethod (Class, "defined by property function", true, [IsRecord], 0, 
   function (r) 
      local class;
      class := NewClass ("class family", IsClassByPropertyRep, 
         rec(definingAttributes := [["in", MemberFunction]]));
      InstallDefiningAttributes (class, r);
      return class;
   end); 


#############################################################################
##
#M  Class (<func>)
##
##  returns the class consisting of all elements for which func returns true
##
InstallMethod (Class, "defined by property function", true, [IsFunction], 0, 
   function (prop) 
      return Class (rec (\in := prop));
   end); 


#############################################################################
##
#M  ViewObj (<class>)
##
InstallMethod (ViewObj, "for IsClassByPropertyRep", true, 
   [IsClassByPropertyRep], 0,
   function (C) 
      local sep;
      Print ("Class (");
      ViewDefiningAttributes (C);      
      Print (")");
   end);


#############################################################################
##
#M  PrintObj (<class>)
##
InstallMethod (PrintObj, "for IsClassByPropertyRep", true, 
   [IsClassByPropertyRep], 0,
   function (C) 
      Print ("Class (");
      PrintDefiningAttributes (C);
      Print (")");
   end);


#############################################################################
##
#M  IsMemberOp (<obj>, <class>)
##
InstallMethod (IsMemberOp, "for class with member function", true, 
   [IsObject, IsClass and HasMemberFunction], SUM_FLAGS, 
      # raise priority so that MemberFunction is preferred over other 
      # methods trying to do without MemberFunction
   function (x, C)
      return MemberFunction (C)(x);
   end);


#############################################################################
##
#R  IsClassByComplementRep (<cl>)
##
##  classes which are defined as complements of other classes
##
DeclareRepresentation ("IsClassByComplementRep", 
   IsClass and IsComponentObjectRep and IsAttributeStoringRep, 
   ["classId", "complement"]);


#############################################################################
##
#M  Complement (<cl>)
##
InstallMethod (Complement, "for a class", true, [IsClass], 0, 
   function (C) 
      return NewClass ("class complement fam", IsClassByComplementRep,
         rec (complement := C));
   end);


#############################################################################
##
#M  Complement (<cl>)
##
InstallMethod (Complement, "for a class complement", true, 
   [IsClassByComplementRep], 0, 
   function (C) 
      return C!.complement;
   end);


#############################################################################
##
#M  Complement (<list>)
##
InstallMethod (Complement, "for a list/collection", true, [IsListOrCollection], 0, 
   function (list) 
      return NewClass ("class complement fam", IsClassByComplementRep,
         rec (complement := list));
   end);


#############################################################################
##
#M  ViewObj (<class>)
##
InstallMethod (ViewObj, "for IsClassByComplementRep", true, 
   [IsClassByComplementRep], 0,
   function (C) 
      Print ("Complement (");
      View (C!.complement);
      Print (")");
   end);


#############################################################################
##
#M  PrintObj (<class>)
##
InstallMethod (PrintObj, "for IsClassByComplementRep", true, 
   [IsClassByComplementRep], 0,
   function (C) 
      Print ("Complement (");
      Print (C!.complement);
      Print (")");
   end);


#############################################################################
##
#M  IsMemberOp (<obj>, <class>)
##
InstallMethod (IsMemberOp, "for IsClassByComplementRep", true, 
   [IsObject, IsClassByComplementRep], 0, 
   function (x, C)
      return not x in C!.complement;
   end);


#############################################################################
##
#P  IsEmpty (<class>)
##
InstallMethod (IsEmpty, "for generic class", 
   true, [IsClass], 0, 
   function (C)
      Error ("Sorry, cannot decide if the class <C> \
         is empty.");
   end);

      
#############################################################################
##
#M  IsEmpty (<class>)
##
InstallImmediateMethod (IsEmpty, IsClassByComplementRep, 0,
   function (C)
      if HasContainsTrivialGroup(C!.complement) 
         and not ContainsTrivialGroup (C!.complement) then
         return false;
      else
         TryNextMethod();
      fi;
   end);


#############################################################################
##
#R  IsClassByIntersectionRep
##
##  classes which are defined as intersections of other classes
##
DeclareRepresentation ("IsClassByIntersectionRep", 
   IsClass and IsComponentObjectRep and IsAttributeStoringRep, 
   ["classId", "intersected"]);


#############################################################################
##
#M  ViewObj (<class>)
##
InstallMethod (ViewObj, "for IsClassByIntersectionRep", true, [IsClassByIntersectionRep], 0,
   function (C) 
      Print ("Intersection (");
      View (C!.intersected);
      Print (")");
   end);


#############################################################################
##
#M  PrintObj (<class>)
##
InstallMethod (PrintObj, "for IsClassByIntersectionRep", true, 
   [IsClassByIntersectionRep], 0,
   function (C) 
      Print ("Intersection (");
      Print (C!.intersected);
      Print (")");
   end);


#############################################################################
##
#M  IsMemberOp (<obj>, <class>)
##
InstallMethod (IsMemberOp, "for IsClassByIntersectionRep", true, 
   [IsObject, IsClassByIntersectionRep], 0, 
   function (x, C)
      return ForAll (C!.intersected, D -> x in D);
   end);


#############################################################################
##
#M  IsEmpty (<class>)
##
InstallImmediateMethod (IsEmpty, IsClassByIntersectionRep, 0,
   function (C)
      if ForAny (C!.intersected, C -> HasIsEmpty (C) and IsEmpty (C)) then
         return true;
      else
         TryNextMethod();
      fi;
   end);
   
   
#############################################################################
##
#M  IsFinite (<class>)
##
InstallImmediateMethod (IsFinite, IsClassByIntersectionRep, 0,
   function (C)
      if ForAny (C!.intersected, C -> HasIsFinite (C) and IsFinite (C)) then
         return true;
      else
         TryNextMethod();
      fi;
   end);
   
   
#############################################################################
##
#M  Intersection2 (<class1>, <class2>)
##
InstallMethod (Intersection2, "of two class intersections", true, 
   [IsClassByIntersectionRep, IsClassByIntersectionRep], 0, 
   function (C, D)
      return NewClass ("class intersection fam", IsClassByIntersectionRep,
         rec (intersected := Concatenation (C!.intersected, D!.intersected)));
   end);


#############################################################################
##
#M  Intersection2 (<obj>, <class>)
##
InstallMethod (Intersection2, "of class/list/coll and class intersection", true, 
   [IsListOrCollection, IsClassByIntersectionRep], 0, 
   function (C, D)
      return NewClass ("class intersection fam", IsClassByIntersectionRep,
         rec (intersected := Concatenation ([C], D!.intersected)));
   end);


#############################################################################
##
#M  Intersection2 (<class>, <obj>)
##
InstallMethod (Intersection2, "of class intersection and class/list/coll", true, 
   [IsClassByIntersectionRep, IsListOrCollection], 0, 
   function (C, D)
      return NewClass ("class intersection fam", IsClassByIntersectionRep,
         rec (intersected := Concatenation (C!.intersected, [D])));
   end);


#############################################################################
##
#M  Intersection2 (<coll>, <class>)
##
InstallMethod (Intersection2, "of small list/coll and class" , true, 
   [IsListOrCollection and IsFinite and HasSize, IsClass], 0, 
   function (C, D)
      if Size (C) < INTERSECTION_LIMIT then
         return Filtered (C, x -> x in D);
      else
         TryNextMethod();
      fi;
   end);


#############################################################################
##
#M  Intersection2 (<list>, <class>)
##
InstallMethod (Intersection2, "of small list and class/list/coll", true, 
   [IsList and IsFinite, IsListOrCollection], 0, 
   function (C, D)
      if Length (C) < INTERSECTION_LIMIT then
         return Filtered (C, x -> x in D);
      else
         TryNextMethod();
      fi;
   end);


#############################################################################
##
#M  Intersection2 (<class>, <coll>)
##
InstallMethod (Intersection2, "of class and small list/coll", true, 
   [IsClass, IsListOrCollection and IsFinite and HasSize], 0, 
   function (C, D)
      if Size (D) < INTERSECTION_LIMIT then
         return Filtered (D, x -> x in C);
      else
         TryNextMethod();
      fi;
   end);


#############################################################################
##
#M  Intersection2 (<obj>, <list>)
##
InstallMethod (Intersection2, "of class and small list", true, 
   [IsClass, IsList and IsFinite], 0, 
   function (C, D)
      if Length (D) < INTERSECTION_LIMIT then
         return Filtered (D, x -> x in C);
      else
         TryNextMethod();
      fi;
   end);


#############################################################################
##
#M  Intersection2 (<class1>, <class2>)
##
InstallMethod (Intersection2, "of two classes", true, 
   [IsClass, IsClass], 0, 
   function (C, D)
      return NewClass ("class intersection fam", IsClassByIntersectionRep,
         rec (intersected := [C,D]));
   end);


#############################################################################
##
#M  Intersection2 (<list/coll>, <ist/coll>)
##
InstallMethod (Intersection2, "of list/collection and list/collection", true, 
   [IsListOrCollection, IsListOrCollection], 0, 
   function (C, D)
      return NewClass ("class intersection fam", IsClassByIntersectionRep,
         rec (intersected := [C,D]));
   end);


#############################################################################
##
#M  Intersection2 (<obj>, <class>)
##
InstallMethod (Intersection2, "of list/collection and class", true, 
   [IsListOrCollection, IsClass], 0, 
   function (C, D)
      return NewClass ("class intersection fam", IsClassByIntersectionRep,
         rec (intersected := [C,D]));
   end);


#############################################################################
##
#R  IsClassByUnionRep
##
##  classes which are defined as unions of other classes
##
DeclareRepresentation ("IsClassByUnionRep", 
   IsClass and IsComponentObjectRep and IsAttributeStoringRep, 
   ["classId", "united"]);


#############################################################################
##
#M  ViewObj (<class>)
##
InstallMethod (ViewObj, "for IsClassByUnionRep", true, [IsClassByUnionRep], 0,
   function (C) 
      Print ("Union (");
      View (C!.united);
      Print (")");
   end);


#############################################################################
##
#M  PrintObj (<class>)
##
InstallMethod (PrintObj, "for IsClassByUnionRep", true, 
   [IsClassByUnionRep], 0,
   function (C) 
      Print ("Union (");
      Print (C!.united);
      Print (")");
   end);


#############################################################################
##
#M  IsMemberOp (<obj>, <class>)
##
InstallMethod (IsMemberOp, "for IsClassByUnionRep", true, 
   [IsObject, IsClassByUnionRep], 0, 
   function (x, C)
      return ForAny (C!.united, D -> x in D);
   end);


#############################################################################
##
#M  IsEmpty (<class>)
##
InstallImmediateMethod (IsEmpty, IsClassByUnionRep, 0,
   function (cl)
      local C;
      for C in cl!.united do
         if HasIsEmpty(C) then
            if not IsEmpty(C) then
               return false;
            fi;
         else
            TryNextMethod();
         fi;
      od;
      return true;
   end);


#############################################################################
##
#M  Union2 (<class>, <class>)
##
InstallMethod (Union2, "for two class unions", true, 
   [IsClassByUnionRep, IsClassByUnionRep], 0, 
   function (C, D)
      return NewClass ("class union fam", IsClassByUnionRep,
         rec (united := Concatenation (C!.united, D!.united)));
   end);


#############################################################################
##
#M  Union2 (<obj>, <class>)
##
InstallMethod (Union2, "for class/list/collection and class union", true, 
   [IsListOrCollection, IsClassByUnionRep], 0, 
   function (C, D)
      return NewClass ("class union fam", IsClassByUnionRep,
         rec (united := Concatenation ([C], D!.united)));
   end);


#############################################################################
##
#M  Union2 (<class>, <obj>)
##
InstallMethod (Union2, "for class union and class/list/collection", true, 
   [IsClassByUnionRep, IsListOrCollection], 0, 
   function (C, D)
      return NewClass ("class union fam", IsClassByUnionRep,
         rec (united := Concatenation (C!.united, [D])));
   end);


#############################################################################
##
#M  Union2 (<obj1>, <obj2>)
##
InstallMethod (Union2, "for two classes/lists/collections", true, 
   [IsListOrCollection, IsListOrCollection], 0, 
   function (C, D)
      return NewClass ("class union fam", IsClassByUnionRep,
         rec (united := [C,D]));
   end);


#############################################################################
##
#M  Difference (<obj1>, <obj2>)
##
InstallMethod (Difference, "for two classes/lists/collections", true, 
   [IsListOrCollection, IsListOrCollection], 0, 
   function (C, D)
      return Intersection2 (C, Complement (D));
   end);


#############################################################################
##
#E
##
