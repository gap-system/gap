# This script does some consistency checks of the manual.
#
# Run it in the 'doc/ref' directory
#
#

Read( "makedocreldata.g" );

doc := ComposedXMLString(
    GAPInfo.ManualDataRef.pathtodoc, 
    GAPInfo.ManualDataRef.main, 
    GAPInfo.ManualDataRef.files,
    true);;

# Detect which ManSection should be used to document obj. Returns one of
# "Func", "Oper", "Meth", "Filt", "Prop", "Attr", "Var", "Fam", "InfoClass"
#
# See PRINT_OPERATION where some of the code below is borrowed
#
ManSectionType:=function( op )
local   class,  flags,  types,  catok,  repok,  propok,  seenprop,  t;
if IsInfoClass( op ) then
    return "InfoClass";
elif IsFamily( op ) then
    return "Fam";
elif not IsFunction( op ) then
    return "Var";  
elif IsFunction( op ) and not IsOperation( op ) then
    return "Func";
elif IsOperation( op ) then
    class := "Oper";
    if IS_IDENTICAL_OBJ(op,IS_OBJECT) then
        class := "Filt";
    elif IS_CONSTRUCTOR(op) then
        class := "Constructor"; # seem to never get one
    elif IsFilter(op) then
        class := "Filt";
        flags := TRUES_FLAGS(FLAGS_FILTER(op));
        types := [];
        for t in flags do
            AddSet(types, INFO_FILTERS[t]);
        od;
        catok := true;
        repok := true;
        propok := true;
        seenprop := false;
        for t in types do
            if not t in FNUM_REPS then
                repok := false;
            fi;
            if not t in FNUM_CATS then
                catok := false;
            fi;
            if not t in FNUM_PROS and not t in FNUM_TPRS then
                propok := false;
            fi;
            if t in FNUM_PROS then
                seenprop := true;
            fi;
        od;
        if seenprop and propok then
            class := "Prop";
        elif catok then
            class := "Filt"; # in PRINT_OPERATION - "Category";
        elif repok then
            class := "Filt"; # in PRINT_OPERATION - "Representation";
        fi;
    elif Tester(op) <> false  then
        # op is an attribute
        class := "Attr";
    fi;
    return class;
else
  return fail;
fi;    
end;

#
# Checks whether ManSections are using the right kind of elements
#
CheckManSectionTypes := function( doc, verbose... )
local types, type, r, s, t, x, y, yint, elt, stats, name, pos, obj, man,
      matches, matches2, match, errcount, referrcount, warncount, display_warnings;
if Length( verbose ) = 0 then
  display_warnings := false;
else
  display_warnings := verbose[1];
fi;
types:=[ "Func", "Oper", "Meth", "Filt", "Prop", "Attr", "Var", "Fam", "InfoClass" ];
r := ParseTreeXMLString(doc[1]);;
CheckAndCleanGapDocTree(r);
x := XMLElements( r, types );;
errcount:=0;
Print( "****************************************************************\n" );
Print( "*** Checking types in ManSections \n" );
Print( "****************************************************************\n" );
for elt in x do
  name := elt.attributes.Name;
  if not name in [ "IsBound", "Unbind", "Info", "Assert", "TryNextMethod", "QUIT", "-infinity" ] then
    if EvalString( Concatenation("IsBound(", name, ")") ) <> true then
      pos:=OriginalPositionDocument(doc[2],elt.start);
      Print( pos[1], ":", pos[2], " : ", name, " is unbound \n" );
      errcount:=errcount+1;
    else
      obj := EvalString( name );
      man := ManSectionType( obj );
      # we allow to use "Meth" for "Oper", "Attr", "Prop" but issue a warning
      # if there is no at least one "Oper", "Attr" or "Prop" for any "Meth"
      if ( man <> elt.name ) and not ( man in ["Attr","Prop","Oper"] and elt.name="Meth") then
        pos:=OriginalPositionDocument(doc[2],elt.start);
        Print( pos[1], ":", pos[2], " : ", name, " uses ", elt.name, " instead of ", man, "\n");
        errcount:=errcount+1;
      fi;
      if elt.name="Meth" then
        if Number( x, t -> t.attributes.Name=name and t.name in ["Attr","Prop","Oper"] ) = 0 then
          pos:=OriginalPositionDocument(doc[2],elt.start);
          Print( pos[1], ":", pos[2], " : ", name, " uses Meth with no matching Oper/Attr/Prop\n" );
          errcount:=errcount+1;
        fi;
      fi;
    fi;
  fi;
od;

Print( "****************************************************************\n" );
Print( "*** Checking types in cross-references \n" );
Print( "****************************************************************\n" );
y := XMLElements( r, [ "Ref" ] );
Print( "Found ", Length(y), " Ref elements " );
yint := Filtered( y, elt ->
      not IsBound(elt.attributes.BookName) or
      (IsBound(elt.attributes.BookName) and elt.attributes.BookName="ref"));
Print( "including ", Length(yint), " within the Reference manual\n" );
y := Filtered( yint, elt -> ForAny( types, t -> IsBound(elt.attributes.(t))));

referrcount:=0;
warncount:=0;
for elt in y do
  type := First( types, t -> IsBound(elt.attributes.(t)));
  if type <> fail then
    matches := Filtered(x, t -> t.attributes.Name=elt.attributes.(type));
    if Length(matches) = 0 then
      pos:=OriginalPositionDocument(doc[2],elt.start);
      Print( pos[1], ":", pos[2], " : no match for ", type , ":=", elt.attributes.(type), "\n" );
      referrcount:=referrcount+1;
      continue;
    elif Length(matches) = 1 then
      match := matches[1];
    elif IsBound(elt.attributes.Label) then
      matches := Filtered( matches, t -> IsBound(t.attributes.Label));
      matches := Filtered( matches, t -> t.attributes.Label=elt.attributes.Label);
      if Length(matches) > 1 then
        Error("Multiple labels - this should not happen!");
      fi;
      match := matches[1];
    else
      matches2 := Filtered( matches, t -> not IsBound(t.attributes.Label));
      if Length(matches2)=0 then
        pos:=OriginalPositionDocument(doc[2],elt.start);
        Print( pos[1], ":", pos[2], " : no match (wrong type or missing label?) for ", type , ":=", elt.attributes.(type), "\n" );
        Print("  Suggestions: \n");
        matches := Filtered( matches, t -> IsBound(t.attributes.Label));
        for t in matches do
          Print( "Use ", t.name, " with Label:=\"", t.attributes.Label, "\" (for Arg:=\"", t.attributes.Arg, "\")\n");
        od;
        
        referrcount:=referrcount+1;
        continue;
      elif Length(matches2) > 1 then
        Error("Multiple labels - this should not happen!");
      else
        match := matches[1];
      fi;
    fi;
    if match.name <> type then
      pos:=OriginalPositionDocument(doc[2],elt.start);
      if display_warnings then
        Print( pos[1], ":", pos[2], " : Ref to ", elt.attributes.(type), " uses ", type, " instead of ", match.name, "\n" );
      fi;
      warncount:=warncount+1;
    fi;
  fi;
od;

Print( "****************************************************************\n" );
stats:=Collected(List(x, elt -> elt.name));
Print("Selected ", Length(x), " ManSections of the following types:\n");
for s in stats do
  Print( s[1], " - ", s[2], "\n");
od;
Print( "Found ", errcount, " errors in ManSection types \n");

Print( "Selected ", Length(y), " Ref elements referring to ManSections \n" );
Print( "Found ", referrcount, " errors and ", warncount, " warnings in Ref elements \n");

if display_warnings then
  Print("To suppress warnings, use CheckManSectionTypes(doc,false) or with one argument\n");
else
  Print("To show warnings, use CheckManSectionTypes(doc,true); \n");
fi;
Print( "****************************************************************\n" );
return errcount=0;
end;


CheckDocCoverage := function( doc )
local r, x, with, without, mansect, pos, y;
r := ParseTreeXMLString(doc[1]);
CheckAndCleanGapDocTree(r);
x:=XMLElements( r, ["ManSection"] );;
with:=0;
without:=0;
Print( "****************************************************************\n" );
Print( "*** Looking for ManSections having no examples \n" );
Print( "****************************************************************\n" );
for mansect in x do
  pos:=OriginalPositionDocument(doc[2],mansect.start);
  y := XMLElements( mansect, ["Example"] );
  if Length(y)=0 then
    if IsBound(mansect.content[1].attributes) and
      IsBound(mansect.content[1].attributes.Name) then
      Print( pos[1], ":", pos[2], " : ", mansect.content[1].attributes.Name );
    elif IsBound(mansect.content[2].attributes) and
      IsBound(mansect.content[2].attributes.Name) then
      Print( pos[1], ":", pos[2], " : ", mansect.content[2].attributes.Name );
    else
      Print( pos[1], ":", pos[2], " : ", mansect.content[1].content[1].content );
    fi;
    without := without + 1;
    Print("\n");
  else
    with := with + 1;
  fi;
od;
Print( "****************************************************************\n" );
Print( "*** Doc coverage report \n");
Print( "****************************************************************\n" );
Print( Length(x), " mansections \n");
Print( with, " with examples \n");
Print( without , " without examples \n");
end;

CheckDocCoverage(doc);
QUIT_GAP( CheckManSectionTypes(doc) );


