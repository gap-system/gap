#############################################################################
##
#W  compiler.g                   GAP library                     Frank Celler
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the frontend function for the compiler.
##


#############################################################################
##
#F  RatPairString( <string> ) . . . . . . . . . . . . . string -> 2 rationals
##
RatPairString := function( string )
    local   p,  x,  y;

    # find ","
    p := Position( string, ',' );
    if p = false  then
        x := Rat(string);
        y := x;
    elif p = 1  then
        x := 1;
        y := Rat(string{[2..Length(string)]});
    elif p = Length(string)  then
        x := Rat(string{[1..p-1]});
        y := 1;
    else
        x := Rat(string{[1..p-1]});
        y := Rat(string{[p+1..Length(string)]});
    fi;
    if x = 0  then x := 1;  fi;
    if y = 0  then y := 1;  fi;
    return [ x, y ];

end;


#############################################################################
##
#F  ParseArguments( <def>, <args>, <pos> )  . . . . parse sequence of options
##
##  <args>  is a  argument  list and <pos> the   position to start at.  <def>
##  describes the arguments, it is a record, whose record names correspond to
##  paramters, the values describe the possible paramters:
##
##  "switch"		toggle the switch or set to the optional paramter
##  "switch/true"       default is `true'
##  "switch/false"      default is `false'
##
##  "string"            set to the mandatory paramter
##  "string/default"    default value
##
##  "integer"           set to the mandatory paramter
##  "integer/default"   default value
##
##  "geometry"          set to the two mandatory paramter width/height
##  "geometry/wxh"	default value
##
##  "alias/name"        define an alias
##  
##  Example:
##
##  gap> a;
##  rec(
##    name := "string/test",
##    nice := "switch/false",
##    depth := "integer/10",
##    ndepth := "integer" )
##  gap> ParseArguments( a, [], 1 );
##  rec(
##    name := "test",
##    nice := false,
##    depth := 10 )
##  gap> ParseArguments( a, ["ndepth",20], 1 );
##  rec(
##    name := "test",
##    nice := false,
##    depth := 10,
##    ndepth := 20 )
##
ParseArguments := function( def, args, pos )
    local   IsMatch,  SplitString,  keys,  type,  val,  key,  tmp,  
            defaultGeometry,  next,  match;
    
    # match a substring
    IsMatch := function( a, b )
        local   c;
        a := LowercaseString(a);
        b := LowercaseString(b);
        c := [ 1 .. Minimum( Length(a), Length(b) ) ];
        return a{c} = b{c};
    end;

    # substring after <sep>
    SplitString := function( str, sep )
        local   p;
        p := Position( str, sep );
        if p = fail  then
            return [ str, "" ];
        else
            return [ str{[1..p-1]}, str{[p+1..Length(str)]} ];
        fi;
    end;

    # parse the default description
    keys := RecNames(def);
    type := rec();
    val  := rec();
    for key  in keys  do

        # a switch
        if IsMatch( "switch", def.(key) )  then
            type.(key) := "switch";
            val.(key)  := not IsMatch("false",SplitString(def.(key),'/')[2]);

        # a string
        elif IsMatch( "string", def.(key) )  then
            type.(key) := "string";
            val.(key)  := SplitString( def.(key), '/' )[2];

        # a geometry
        elif IsMatch( "geometry", def.(key) )  then
            type.(key) := "geometry";
            tmp := SplitString( SplitString( def.(key), '/' )[2], 'x' );
            val.(key) := List( tmp, Int );
            if not IsBound(defaultGeometry)  then
                defaultGeometry := key;
            fi;

        # an integer
        elif IsMatch( "integer", def.(key) )  then
            type.(key) := "integer";
            tmp := SplitString( def.(key), '/' )[2];
            if 0 < Length(tmp)  then tmp := Int(tmp);  else tmp := fail;  fi;
            if tmp <> fail  then val.(key) := tmp;  fi;

        # an alias
        elif IsMatch( "alias", def.(key) )  then
            type.(key) := "alias";
            val.(key)  := SplitString( def.(key), '/' )[2];

        # unknown type
        else
            Error( "type '", def.(key), "' is unknown" );
        fi;

    od;

    # parse the arguments starting at position <pos>
    while pos <= Length(args)  do
        next := args[pos];

        # an integer could be a geometry parameter
        if IsInt(next) and pos < Length(args) and IsInt(args[pos+1])  then
            if IsBound(defaultGeometry)  then
                if next <= 0  then
                    Error( "width must be non-negative, not ", next );
                fi;
                if args[pos+1] <= 0  then
                    Error("height must be non-negative, not ", args[pos+1]);
                fi;
                val.(defaultGeometry) := [ next, args[pos+1] ];
                pos := pos+2;
            else
                Error( "'geometry' may not be specified" );
            fi;

        # just one integer
        elif IsInt(next)  then
            tmp := Concatenation( "unknown parameter '", String(next),
                                  "', known parameters are: " );
            for key  in [ 1 .. Length(keys) ]  do
                if 1 < key  then Append( tmp, ", " );  fi;
                Append( tmp, keys[key] );
            od;
            Error( tmp );

        # check the other keys
        else
            match := false;
            for key  in keys  do
                if not match and IsMatch( key, next )  then
                    match := true;

                    # check for an alias
                    if type.(key) = "alias"  then
                        key := val.(key);
                    fi;

                    # a switch takes an optional boolean argument
                    if type.(key) = "switch"  then
                        if pos < Length(args) and IsBool(args[pos+1])  then
                            val.(key) := args[pos+1];
                            pos := pos+2;
                        else
                            val.(key) := not val.(key);
                            pos := pos+1;
                        fi;

                    # a string
                    elif type.(key) = "string"  then
                        if pos=Length(args) or not IsString(args[pos+1]) then
                            Error( key, " requires a string argument" );
                        fi;
                        val.(key) := args[pos+1];
                        pos := pos+2;

                    # an integer
                    elif type.(key) = "integer"  then
                        if pos=Length(args) or not IsInt(args[pos+1]) then
                            Error( key, " requires an integer argument" );
                        fi;
                        val.(key) := args[pos+1];
                        pos := pos+2;

                    # a geometry
                    elif type.(key) = "geometry"  then
                        if pos+1 = Length(args)  then
                            Error( key, " requires a width and height" );
                        fi;
                        if not IsInt(args[pos+1]) or args[pos+1] <= 0  then
                            Error( "width must be non-negative, not ",
                                   args[pos+1] );
                        fi;
                        if not IsInt(args[pos+2]) or args[pos+2] <= 0  then
                            Error( "height must be non-negative, not ",
                                   args[pos+2] );
                        fi;
                        val.(key) := [ args[pos+1], args[pos+2] ];
                        pos := pos+3;
                    fi;
                fi;
            od;

            # we didn't found a match
            if not match  then
                tmp := Concatenation( "unknown parameter '", next,
                                      "', known parameters are: " );
                for key  in [ 1 .. Length(keys) ]  do
                    if 1 < key  then Append( tmp, ", " );  fi;
                    Append( tmp, keys[key] );
                od;
                Error( tmp );
            fi;
        fi;
    od;
        
    # that's it, remove alias entries
    for key  in keys  do
        if type.(key) = "alias"  then
            Unbind(val.(key));
        fi;
    od;
    return val;

end;


#############################################################################
##
#F  CompileFunc( <output>, <function>, <module_name>, ... )
##
##  <output> must be a filename,
##  <function> the function to compile,
##  <module_name> the name used in the compiled module
##
##  optional parameters are:
##  "Magic1"
##  "Magic2"
##  "FastIntArith"
##  "FastPlainLists"
##  "CheckTypes"
##  "CheckListElements"
##  "CheckPosObjElements"
##
CompileFunc := function( arg )
    local   output,  func,  name,  arguments;

    output := arg[1];
    func   := arg[2];
    name   := arg[3];

    arguments := rec(
        magic1              := "integer/0",
        magic2              := "string",
        fastintarith        := "switch/true",
        fastplainlists      := "switch/true",
        checktypes          := "switch/true",
        checklistelements   := "switch/true",
        checkposobjelements := "switch/true" );

    arguments := ParseArguments( arguments, arg, 4 );

    return COMPILE_FUNC(
        output, func, name,
        arguments.magic1, arguments.magic2, arguments.fastintarith,
        arguments.fastplainlists, arguments.checktypes,
        arguments.checklistelements, arguments.checkposobjelements );

end;


#############################################################################
##

#E  compiler.g  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
