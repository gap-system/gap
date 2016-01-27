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
        types := INFO_FILTERS{flags};
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
CheckManSectionTypes := function( doc )
local r, s, x, elt, stats, name, pos, obj, man, errcount;
r := ParseTreeXMLString(doc[1]);;
CheckAndCleanGapDocTree(r);
x := XMLElements( r, [ "Func", "Oper", "Meth", "Filt", "Prop", "Attr", "Var", "Fam", "InfoClass" ] );;
errcount:=0;
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
      # we allow to use "Meth" for "Oper" but probably should issue a warning
      # if there is no at least one "Oper" for any "Meth"
      if ( man <> elt.name ) and not ( man="Oper" and elt.name="Meth") then
        pos:=OriginalPositionDocument(doc[2],elt.start);
        Print( pos[1], ":", pos[2], " : ", name, " uses ", elt.name, " but must be ", man, "\n");
        errcount:=errcount+1;
      fi;
    fi;
  fi;
od;

stats:=Collected(List(x, elt -> elt.name));
Print("Selected ", Length(x), " ManSections of the following types:\n");
for s in stats do
  Print( s[1], " - ", s[2], "\n");
od;
Print( errcount, " errors detected \n");
return errcount=0;
end;

QUIT_GAP( CheckManSectionTypes( doc ) );
