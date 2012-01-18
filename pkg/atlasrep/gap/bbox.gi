#############################################################################
##
#W  bbox.gi              GAP 4 package AtlasRep                 Thomas Breuer
#W                                                            Simon Nickerson
##
#Y  Copyright (C)  2005,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the implementations of the operations
##  for black box programs and straight line decisions.
##
##  1. Functions for black box algorithms
##  2. Functions for straight line decisions
##


#############################################################################
##
##  1. Functions for black box algorithms
##


#############################################################################
##
#V  BBoxProgramsDefaultType
##
BindGlobal( "BBoxProgramsDefaultType",
    NewType( StraightLineProgramsFamily,
             IsBBoxProgram and IsAttributeStoringRep
                           and HasLinesOfBBoxProgram ) );


#############################################################################
##
#M  Display( <prog> )
##
InstallMethod( Display,
    [ "IsBBoxProgram" ],
    function( prog )
    local line;

    for line in LinesOfBBoxProgram( prog ) do
      Print( line, "\n" );
    od;
    end );


#############################################################################
##
#M  PrintObj( <prog> )
##
InstallMethod( PrintObj,
    [ "IsBBoxProgram" ],
    function( prog )
    Print( "<black box program>" );
    end );


#############################################################################
##
#M  ViewObj( <prog> )
##
InstallMethod( ViewObj,
    [ "IsBBoxProgram" ],
    function( prog )
    Print( "<black box program>" );
    end ); 


#############################################################################
##
#F  ScanBBoxProgram( <string> )
##
InstallGlobalFunction( ScanBBoxProgram, function( string )
    local keywords, rels, notrel, labels, prog, linenums, lines, linenum, s,
          filelinenum, line, i, ss, n, k, j, level, iflines, endifline, l, m,
          result;

    # Get and check the input.
    if   string = fail then
      # This is used to simplify other programs.
      return fail;
    elif not IsString( string ) then
      Error( "<string> must be `fail' or a string" );
    fi;

    keywords:= [ "add", "break", "call", "chcl", "chor", "cj", "cjr", "com",
                 "cp", "decr", "div", "echo", "else", "elseif", "endif",
                 "fail", "false", "if", "incr", "inv", "iv", "jmp", "lbl",
                 "mod", "mu", "mul", "nop", "ord", "oup", "pwr", "rand",
                 "return", "set", "sub", "timeout", "true" ];
    rels:= [ "eq", "in", "gt", "lt", "geq", "leq", "notin", "noteq" ];
    notrel:= function( rel )
      local i;

      i:= Position( rels, rel );
      if i = fail then
        return fail;
      else
        return rels[ 9-i ];
      fi;
    end;

    labels:= [];
    prog:= [];
    linenums:= [];

    lines:= SplitString( string, "\n", "\t" );

    linenum:= 1;
    s:= [];

    for filelinenum in [ 1 .. Length( lines ) ] do
      line:= lines[ filelinenum ];

      # Remove comments.
      i:= Position( line, '#' );
      if i <> fail then
        line:= line{ [ 1 .. i-1 ] };
      fi;

      # Split the line at whitespace, omitting empty words.
      ss:= SplitString( line, " ", " " );

      if IsEmpty( ss ) then
        continue;
      elif ss[1] = "inp" then
        # This is in fact not a supported statement.
        continue;
      elif ss[ Length( ss ) ] = "&" then
        # The instruction is continued on the next line(s).
        Append( s, ss{ [ 1 .. Length( ss ) - 1 ] } );
      else
        # An instruction is complete.
        Append( s, ss );
        if   1 < Number( s, x -> x = "if" ) then
          Info( InfoBBox, 1,
                "cannot have more than one 'if' at line ", filelinenum );
          return fail;
        elif not s[1] in keywords then
          Info( InfoBBox, 1,
                "invalid keyword '", s[1], "' at line ", filelinenum );
          return fail;
        fi;

        # Replace strings representing integers by these integers.
        for i in [ 2 .. Length(s) ] do
          n:= Int( s[i] );
          if n <> fail then
            s[i]:= n;
          fi;
        od;

        if s[1] = "lbl" then
          Add( labels, [ s[2], linenum ] );
        elif s[1] = "elseif" or s[1] = "else" or s[1] = "endif" then
          Add( prog, [ "nop" ] );
          Add( prog, s );
          Add( linenums, 0 );
          Add( linenums, filelinenum );
          linenum := linenum + 2;
        elif s[1] = "if" and s[ Length(s) ] <> "then" then
   #      if not ForAll( s, x -> x in keywords or x in rels
   #               or IsInt( x ) or x = "then"
   #               or ForAny( labels, y -> x = y[1] )
   #               or ( IsString( x ) and Length( x ) = 1 ) ) then
   #        Info( InfoBBox, 1,
   #              "invalid labels in `if' statement at line ", filelinenum );
   #        return fail;
   #      fi;
          s[1]:= "_if";
          Add( prog, s );
          Add( linenums, filelinenum );
          linenum:= linenum + 1;
        else
          Add( prog, s );
          Add( linenums, filelinenum );
          linenum:= linenum + 1;
        fi;
        s:= [];
      fi;

    od;

    for i in [ 1 .. Length( prog ) ] do
      k:= Position( prog[i], "jmp" );
      if k = fail then
        k:= Position( prog[i], "call" );
      fi;
      if k <> fail then
        j:= PositionProperty( labels, x -> x[1] = prog[i][k+1] );
        if j = fail then
          Info( InfoBBox, 1,
                "label ", prog[i][k+1], " not found at line ", linenums[i] );
          return fail;
        fi;
        prog[i][k+1]:= labels[j][2];
      fi;
    od;

    # Preprocess 'if', 'elseif', 'else', 'then'.
    for i in [ 1 .. Length( prog ) ] do
      if prog[i][1] = "if" then
        level := 1;
        iflines := [ i ];
        endifline := 0;
        for k in [ i+1 .. Length( prog ) ] do
          if prog[k][1] = "if" then
            level := level + 1;
          fi;
          if prog[k][1] = "endif" then
            level := level - 1;
            if level = 0 then
              Add(iflines, k);
              endifline := k;
              break;
            fi;
          fi;
          if level = 1 and prog[k][1] = "else" then
            Add(iflines, k);
          fi;
          if level = 1 and prog[k][1] = "elseif" then
            Add(iflines, k);
          fi;
        od;

        if endifline = 0 then
          Info( InfoBBox, 1,
                "no 'endif' for 'if' at line ", linenums[i] );
          return fail;
        fi;

        for l in [1 .. Length( iflines ) - 1 ] do
          k:= iflines[l];
          if prog[k][1] = "else" then
            prog[k][1] := "nop";
          else
            prog[k][1] := "_if";
            prog[k][3] := notrel(prog[k][3]);
            m := Position(prog[k], "then");
            if m <> Length(prog[k]) then
              Info( InfoBBox, 1,
                    "misplaced 'then' at line ", linenums[k] );
              return fail;
            fi;
            Add(prog[k], "jmp");
            Add(prog[k], iflines[l+1]);
          fi;
          prog[iflines[l+1]-1] := ["jmp", endifline];
        od;

        prog[endifline] := [ "nop" ];

      fi;

      if prog[i][1] in [ "else", "elseif", "endif" ] then
        Info( InfoBBox, 1,
              "unexpected '", prog[i][1], "' at line ", linenums[i] );
        return fail;
      fi;

    od;

    result:= rec();
    ObjectifyWithAttributes( result, BBoxProgramsDefaultType,
                             LinesOfBBoxProgram, prog );
    return rec( program:= result );
end );


#############################################################################
##
#F  BBoxPerformInstruction( fullline, ins, G, ans, gpelts, ctr, options )
##
InstallGlobalFunction( BBoxPerformInstruction,
    function( fullline, ins, G, ans, gpelts, ctr, options )
    local toval, tonum, testresult, set, i, o, newins, thenpos, elsepos;

    tonum:= x -> INT_CHAR( x[1] ) - 64;

    toval:= function(x)
      local n;
      n:= Int( x );
      if n = fail then
        return ans.vars[ tonum( x ) ];
      fi;
      return n;
    end;

    if ins[1] = "_if" then
      thenpos:= Position( ins, "then" );
      if thenpos = fail then
        Info( InfoBBox, 1,
              "'if' statement must have corresponding 'then' at line ",
              ctr, "\n" );
        return fail;
      fi;
      elsepos:= Position( ins, "else" );
      if elsepos = fail then
        elsepos:= Length( ins ) + 1;
      fi;

      if   ins[3] = "eq" then
        testresult:= ( toval( ins[2] )  = toval( ins[4] ) );
      elif ins[3] = "noteq" then
        testresult:= ( toval( ins[2] ) <> toval( ins[4] ) );
      elif ins[3] = "geq" then
        testresult:= ( toval( ins[2] ) >= toval( ins[4] ) );
      elif ins[3] = "gt" then
        testresult:= ( toval( ins[2] )  > toval( ins[4] ) );
      elif ins[3] = "leq" then
        testresult:= ( toval( ins[2] ) <= toval( ins[4] ) );
      elif ins[3] = "lt" then
        testresult:= ( toval( ins[2] )  < toval( ins[4] ) );
      elif ins[3] = "in" then
        set:= List( ins{ [ 4 .. thenpos-1 ] }, toval );
        testresult:= ( toval( ins[2] ) in set );
      elif ins[3] = "notin" then
        set:= List( ins{ [ 4 .. thenpos-1 ] }, toval );
        testresult:= ( not toval( ins[2] ) in set );
      else
        Info( InfoBBox, 1,
              "syntax error in 'if' statement at line ", ctr, "\n" );
        return fail;
      fi;

      if testresult then
        ctr:= BBoxPerformInstruction( fullline,
                  ins{ [ thenpos+1 .. elsepos-1 ] },
                  G, ans, gpelts, ctr, options );
      elif elsepos <= Size( ins ) then
        newins := List([elsepos+1..Size(ins)], x->ins[x]);
        ctr:= BBoxPerformInstruction( fullline,
                  ins{ [ elsepos+1 .. Size( ins ) ] },
                  G, ans, gpelts, ctr, options );
      fi;

    elif ins[1] = "add" then
      ans.vars[ tonum( ins[4] ) ]:= toval( ins[2] ) + toval( ins[3] );
    elif ins[1] = "break" then
      if options.allowbreaks then
        Error( "user defined break" );
      fi;
    elif ins[1] = "call" then
      Add( ans.callstack, ctr );
      if 10 < Length( ans.callstack ) then
        Info( InfoBBox, 1,
              "call stack overflow" );
        return fail;
      fi;
      ctr:= ins[2] - 1;  # -1 because ctr gets increased by 1
    elif ins[1] = "chcl" then
      ans.result:= true;
      if not options.classfunction( gpelts[ ins[2] ], ins[3] ) then
        Info( InfoBBox, 1,
              "ccl check failed for element ", ins[2] );
        ans.result:= false;
        return false;
      fi;
      ans.class:= ans.class + 1;
    elif ins[1] = "chor" then
      ans.result:= true;
      if options.orderfunction( gpelts[ ins[2] ] ) <> ins[3] then
        Info( InfoBBox, 1,
              "order check failed: element ", ins[2], " has order ",
              Order( gpelts[ ins[2] ] ), " not ", ins[3] );
        ans.result := false;
        return false;
      fi;
      ans.order:= ans.order + 1;
    elif ins[1] = "cj" then
      gpelts[ ins[4] ]:= gpelts[ ins[2] ]^gpelts[ ins[3] ];
      ans.conjugate:= ans.conjugate + 1;
    elif ins[1] = "cjr" then
      gpelts[ ins[2] ]:= gpelts[ ins[2] ]^gpelts[ ins[3] ];
      ans.conjugateinplace:= ans.conjugateinplace + 1;
    elif ins[1] = "com" then
      gpelts[ ins[4] ]:= Comm( gpelts[ ins[2] ], gpelts[ ins[3] ] );
      ans.commutator:= ans.commutator + 1;
    elif ins[1] = "cp" then
      gpelts[ ins[3] ]:= gpelts[ ins[2] ];
    elif ins[1] = "decr" then
      ans.vars[ tonum( ins[2] ) ]:= ans.vars[ tonum( ins[2] ) ] - 1;
    elif ins[1] = "div" then
      ans.vars[ tonum( ins[4] ) ]:= Int( toval( ins[2] ) / toval( ins[3] ) );
    elif ins[1] = "echo" then
      if not options.quiet then
        for i in [ 2 .. Length( ins ) ] do
          if IsString( ins[i] ) and ins[i][1] = '$' then
            Print( toval( ins[i]{ [ 2 ] } ), " " );
          else
            Print( ins[i], " " );
          fi;
        od;
      fi;
      Print( "\n" );
    elif ins[1] = "fail" then
      Info( InfoBBox, 1,
            "black box algorithm failed,\n",
            "#I  last line was: ", fullline, "\n",
            "#I  variables: ", ans.vars );
      return fail;
    elif ins[1] = "false" then
      ans.result:= false;
      return false;
    elif ins[1] = "incr" then
      ans.vars[ tonum( ins[2] ) ]:= ans.vars[ tonum( ins[2] ) ] + 1;
    elif ins[1] = "iv" or ins[1] = "inv" then
      gpelts[ ins[3] ]:= gpelts[ ins[2] ]^-1;
      ans.invert:= ans.invert + 1;
    elif ins[1] = "jmp" then
      ctr:= ins[2] - 1;  # -1 because ctr gets increased by 1
    elif ins[1] = "mod" then
      ans.vars[ tonum( ins[4] ) ]:= toval( ins[2] ) mod toval( ins[3] );
    elif ins[1] = "mu" then
      gpelts[ ins[4] ]:= gpelts[ ins[2] ] * gpelts[ ins[3] ];
      ans.multiply:= ans.multiply + 1;
    elif ins[1] = "mul" then
      ans.vars[ tonum( ins[4] ) ]:= toval( ins[2] ) * toval( ins[3] );
    elif ins[1] = "nop" then
      # Do nothing
    elif ins[1] = "ord" then
      o:= options.orderfunction( gpelts[ ins[2] ] );
      ans.vars[ tonum( ins[3] ) ]:= o;
      if options.verbose then
        Print( "#I  o(g", ins[2], ") = ", o, "\n" );
      fi;
      ans.order:= ans.order + 1;
    elif ins[1] = "oup" then
      ans.gens:= gpelts{ ins{ [ 3 .. 2 + ins[2] ] } };
      return false;
    elif ins[1] = "pwr" then
      gpelts[ ins[4] ]:= gpelts[ ins[3] ] ^ ( toval( ins[2] ) );
      ans.power:= ans.power + 1;
    elif ins[1] = "rand" then
      gpelts[ ins[2] ]:= options.randomfunction( G );
      ans.random:= ans.random + 1;
    elif ins[1] = "return" then
      if IsEmpty( ans.callstack ) then
        Info( InfoBBox, 1,
              "call stack empty at line ", ctr );
        return fail;
      fi;
      ctr:= ans.callstack[ Length( ans.callstack ) ]; # N.B. no -1
      Unbind( ans.callstack[ Length( ans.callstack ) ] );
    elif ins[1] = "set" then
      ans.vars[ tonum( ins[2] ) ]:= toval( ins[3] );
    elif ins[1] = "sub" then
      ans.vars[ tonum( ins[4] ) ]:= toval( ins[2] ) - toval( ins[3] );
    elif ins[1] = "timeout" then
      if options.hardtimeout then
        Info( InfoBBox, 1,
              "timed out: check group is correct" );
        return "timeout";
      else
        Info( InfoBBox, 1,
              "warning: timed out, continuing");
      fi;
    elif ins[1] = "true" then
      ans.result:= true;
      return false;
    else
      Info( InfoBBox, 1,
            "unrecognised command '", ins[1], "' at line ", ctr );
      return fail;
    fi;

    return ctr;
end );


#############################################################################
##
#F  RunBBoxProgram( <prog>, <G>, <input>, <options> )
##
InstallGlobalFunction( "RunBBoxProgram", function( prog, G, input, options )
    local ans, ctr, gpelts, starttime, lines, ins, i;

    # Set default options.
    if not IsBound( options.allowbreaks ) then
      options.allowbreaks:= true;
    fi;
    if not IsBound( options.verbose ) then
      options.verbose:= false;
    fi;
    if not IsBound( options.quiet ) then
      options.quiet:= false;
    fi;
    if not IsBound( options.orderfunction ) then
      options.orderfunction:= Order;
    fi;
    if not IsBound( options.hardtimeout ) then
      options.hardtimeout:= true;
    fi;
    if not IsBound( options.classfunction ) then
      options.classfunction:= function( x, y ) return true; end;
    fi;
    if not IsBound( options.randomfunction ) then
      options.randomfunction:= PseudoRandom;
    fi;

    # Initialize the result record.
    ans:= rec( multiply := 0,
               invert := 0,
               power := 0,
               order := 0,
               class := 0,
               random := 0,
               timetaken := 0,
               conjugate := 0,
               conjugateinplace := 0,
               commutator := 0,
               vars := [ ],
               callstack := [ ],
               );

    ctr:= 1;
    gpelts:= ShallowCopy( input );
    starttime:= Runtime();
    lines:= LinesOfBBoxProgram( prog );

    # Main loop
    repeat
      ins:= lines[ctr];
      if options.verbose then
        if ctr < 100 then Print( " " ); fi;
        if ctr <  10 then Print( " " ); fi;
        Print( ctr, ". " );
        for i in ins do
          Print( i, " " );
        od;
        Print( "\n" );
      fi;
      ctr:= BBoxPerformInstruction( ins, ins, G, ans, gpelts, ctr, options );
      if   ctr = fail or ctr = "timeout" then
        return ctr;
      elif ctr = false then
        break;
      fi;
      ctr:= ctr + 1;
    until Length( lines ) < ctr;

    ans.timetaken:= Runtime() - starttime;
    return ans;
end );


#############################################################################
##
#F  ResultOfBBoxProgram( <prog>, <G> )
#F  ResultOfBBoxProgram( <prog>, <gens> )
##
InstallGlobalFunction( ResultOfBBoxProgram, function( prog, G )
    local result;

    if IsList( G ) then
      result:= RunBBoxProgram( prog, "dummy", G, rec() );
    else
      result:= RunBBoxProgram( prog, G, [], rec() );
    fi;
    if   result = fail or result = "timeout" then
      return result;
    elif IsBound( result.result ) then
      return result.result;
    else
      return result.gens;
    fi;
end );


# blackboxtrials := function(G, filename, numtrials)
#     local i, prog, options, ans, cost, outputtime;
# 
#     prog := prepareblackbox(filename);
#     options := rec(allowbreaks := false,
#                    verbose := false);
#     cost := 0;
#     outputtime := Runtime();
#     for i in [1..numtrials] do
#         repeat
#             ans := blackbox(G, prog, options);
#             if ans = fail then
#                 Print("Algorithm failed. Trying again.\n");
#             fi;
#         until not ans = fail;
#         cost := cost + ans.random;
#         if Runtime() - outputtime > 5000 then
#             Print("Trial ", i, "/", numtrials,
#                   ": average cost = ", Int(cost*100/i), "/100\n");
#             outputtime := Runtime();
#         fi;
#     od;
# 
#     return cost / numtrials;
# 
# end;


#############################################################################
##
##  2. Functions for straight line decisions
##


#############################################################################
##
#V  StraightLineDecisionsFamily
#V  StraightLineDecisionsDefaultType
##
BindGlobal( "StraightLineDecisionsFamily",
    NewFamily( "StraightLineDecisionsFamily", IsStraightLineDecision ) );

BindGlobal( "StraightLineDecisionsDefaultType",
    NewType( StraightLineDecisionsFamily,
             IsStraightLineDecision and IsAttributeStoringRep
                                    and HasLinesOfStraightLineDecision ) );


#############################################################################
##
#F  StraightLineDecision( <lines>[, <nrgens>] )
#F  StraightLineDecisionNC( <lines>[, <nrgens>] )
##
InstallGlobalFunction( StraightLineDecision, function( arg )
    local result;

    result:= CallFuncList( StraightLineDecisionNC, arg );
    if     not IsStraightLineDecision( result )
       or not IsInternallyConsistent( result ) then
      result:= fail;
    fi;
    return result;
end );


InstallGlobalFunction( StraightLineDecisionNC, function( arg )
    local lines, nrgens, prog;

    # Get the arguments.
    if   Length( arg ) = 1 then
      lines  := arg[1];
    elif Length( arg ) = 2 then
      lines  := arg[1];
      nrgens := arg[2];
    else
      Error( "usage: StraightLineDecisionNC( <lines>[, <nrgens>] )" );
    fi;

    prog:= rec();
    ObjectifyWithAttributes( prog, StraightLineDecisionsDefaultType,
                             LinesOfStraightLineDecision, lines );
    if IsBound( nrgens ) and IsInt( nrgens ) and 0 <= nrgens then
      SetNrInputsOfStraightLineDecision( prog, nrgens );
    fi;

    return prog;
end );


#############################################################################
##
#M  NrInputsOfStraightLineDecision( <prog> )
##
##  This is equal to the code for straight line programs.
#T  (Unify this!)
##
InstallMethod( NrInputsOfStraightLineDecision,
    [ "IsStraightLineDecision" ],
    function( prog )
    local defined,    # list of currently assigned positions
          maxinput,   # current maximum of input needed
          lines,      # lines of `prog'
          len,        # length of `lines'
          adjust,     # local function to  increase the number
          line,       # one line of the program
          i, j;       # loop over the lines

    defined:= [];
    maxinput:= 0;
    lines:= LinesOfStraightLineDecision( prog );
    len:= Length( lines );
    if len = 0 then
      # If the number of inputs is not known then this is not allowed.
      Error( "<lines> must not be empty, or input number must be known" );
    fi;

    adjust:= function( line )
      local needed;
      needed:= Difference( line{ [ 1, 3 .. Length( line ) - 1 ] },
                           defined );
      if not IsEmpty( needed ) then
        needed:= MaximumList( needed );
        if maxinput < needed then
          maxinput:= needed;
        fi;
      fi;
    end;

    # Inspect the lines.
    for i in [ 1 .. len ] do
      line:= lines[i];
      if ForAll( line, IsInt ) then
        if i = len then
          adjust( line );
        else
          Error( "<lines> contains a line of integers" );
        fi;
      elif Length( line ) = 2 and IsInt( line[2] ) then
        adjust( line[1] );
        AddSet( defined, line[2] );
      elif i = len and ForAll( line, IsList ) then
        for j in line do
          adjust( j );
        od;
      fi;
    od;

    return maxinput;
end );


#############################################################################
##
#M  ResultOfStraightLineDecision( <prog>, <gens>[, <orderfunc>] )
##
InstallMethod( ResultOfStraightLineDecision,
    [ "IsStraightLineDecision", "IsHomogeneousList" ],
    function( prog, gens )
    return ResultOfStraightLineDecision( prog, gens, Order );
    end );

InstallMethod( ResultOfStraightLineDecision,
    [ "IsStraightLineDecision", "IsHomogeneousList", "IsFunction" ],
    function( prog, gens, orderfunc )
    local r,         # list of intermediate results
          line,      # loop over the lines
          ord;       # result of an order check

    # Initialize the list of intermediate results.
    r:= ShallowCopy( gens );

    # Initialize the list of intermediate results.
    r:= ShallowCopy( gens );

    # Loop over the program.
    for line in LinesOfStraightLineDecision( prog ) do

      if   IsInt( line[1] ) then

        # The line describes a word to be appended.
        Add( r, ResultOfLineOfStraightLineProgram( line, r ) );

      elif line[1] = "Order" then

        # The line describes an order check.
        ord:= orderfunc( r[ line[2] ] );
        if ord <> line[3] then
          if not IsInt( ord ) then
            Info( InfoBBox, 1, "order function returned `", ord, "'" );
          fi;
          return false;
        fi;

      else

        # The line describes a word that shall replace.
        r[ line[2] ]:= ResultOfLineOfStraightLineProgram( line[1], r );

      fi;

    od;

    # Return the result.
    return true;
    end );


#############################################################################
##
#M  StraightLineProgramFromStraightLineDecision( <dec> )
##
InstallMethod( StraightLineProgramFromStraightLineDecision,
    [ "IsStraightLineDecision" ],
    function( dec )
    local lines, checkpos, maxslot, line, i, result;

    lines:= ShallowCopy( LinesOfStraightLineDecision( dec ) );

    # Find the check lines.
    checkpos:= [];
    maxslot:= NrInputsOfStraightLineDecision( dec );;
    for i in [ 1 .. Length( lines ) ] do
      line:= lines[i];
      if   IsInt( line[1] ) then
        maxslot:= maxslot + 1;
      elif line[1] = "Order" then
        Add( checkpos, i );
      elif maxslot < line[2] then
        maxslot:= line[2];
      fi;
    od;

    # Replace the check lines.
    result:= [];
    for i in checkpos do
      maxslot:= maxslot + 1;
      line:= lines[i];
      lines[i]:= [ [ line[2], line[3] ], maxslot ];
      Add( result, [ maxslot, 1 ] );
    od;
    Add( lines, result );

    # Return the result.
    return StraightLineProgramNC( lines,
                                  NrInputsOfStraightLineDecision( dec ) );
    end );


#############################################################################
##
#M  Display( <dec> )
#M  Display( <dec>, <record> )
##
InstallMethod( Display,
    [ "IsStraightLineDecision" ],
    function( dec )
    Display( dec, rec() );
    end );

InstallOtherMethod( Display,
    [ "IsStraightLineDecision", "IsRecord" ],
    function( prog, record )
    local gensnames,
          listname,
          PrintLine,
          i,
          lines,
          len,
          line,
          j;

    # Get and check the arguments.
    if IsBound( record.gensnames ) then
      gensnames:= record.gensnames;
    else
      gensnames:= List( [ 1 ..  NrInputsOfStraightLineDecision( prog ) ],
                        i -> Concatenation( "g", String( i ) ) );
    fi;
    listname:= "r";
    if IsBound( record.listname ) then
      listname:= record.listname;
    fi;

    PrintLine := function( line )
      local j;
      for j in [ 2, 4 .. Length( line )-2 ] do
        Print( "r[", line[ j-1 ], "]" );
        if line[j] <> 1 then
          Print( "^", line[j] );
        fi;
        Print( "*" );
      od;
      j:= Length( line );
      if 0 < j then
        Print( "r[", line[ j-1 ], "]" );
        if line[j] <> 1 then
          Print( "^", line[j] );
        fi;
      fi;
    end;

    # Print the initialisation.
    Print( "# input:\n" );
    Print( listname, ":= [ " );
    if not IsEmpty( gensnames ) then
      Print( gensnames[1] );
    fi;
    for i in [ 2 .. Length( gensnames ) ] do
      Print( ", ", gensnames[i] );
    od;
    Print( " ];\n" );

    # Loop over the lines.
    lines:= LinesOfStraightLineDecision( prog );
    len:= Length( gensnames );
    Print( "# program:\n" );
    for i in [ 1 .. Length( lines ) ] do

      line:= lines[i];
      if   Length( line ) = 2 and IsList( line[1] )
                              and IsPosInt( line[2] ) then

        Print( "r[", line[2], "]:= " );
        PrintLine( line[1] );
        Print( ";\n" );
        if len < line[2] or i = Length( lines ) then
          len:= line[2];
        fi;

      elif not IsEmpty( line ) and ForAll( line, IsInt ) then

        len:= len + 1;
        Print( "r[", len, "]:= " );
        PrintLine( line );
        Print( ";\n" );

      elif line[1] = "Order" then

        Print( "if Order( r[", line[2], "] ) <> ", line[3], " then",
               "  return false;  fi;\n" );

      fi;

    od;

    Print( "# return value:\ntrue\n" );
    end );


#############################################################################
##
#M  IsInternallyConsistent( <prog> )
##
InstallMethod( IsInternallyConsistent,
    [ "IsStraightLineDecision" ],
    function( prog )
    local lines, nrgens, defined, testline, len, i, line;

    lines:= LinesOfStraightLineDecision( prog );
    if not IsList( lines ) then
      return false;
    fi;
    len:= Length( lines );

    if   HasNrInputsOfStraightLineDecision( prog ) then
      nrgens:= NrInputsOfStraightLineDecision( prog );
      defined:= [ 1 .. nrgens ];
    elif len = 0 then
      return false;
    else
      defined:= [];
    fi;

    testline:= function( line )
      local len, gens;

      # The external representation of an associative word has even length,
      len:= Length( line );
      if len mod 2 <> 0 then
        return false;
      fi;

      # and the generator numbers are stored at odd positions.
      gens:= line{ [ 1, 3 .. len-1 ] };
      if not ForAll( gens, IsPosInt ) then
        return false;
      fi;

      # If the number of generators is stored then check
      # that only defined positions are accessed.
      if IsBound( nrgens ) and not IsSubset( defined, gens ) then
        return false;
      else
        return true;
      fi;
    end;

    for i in [ 1 .. len ] do
      line:= lines[i];
      if   not IsList( line ) then
        return false;
      elif not IsEmpty( line ) and ForAll( line, IsInt ) then
        if not testline( line ) or ( i < len and not IsBound( nrgens ) ) then
          return false;
        fi;
        AddSet( defined, Length( defined ) + 1 );
      elif Length( line ) = 2 and IsPosInt( line[2] ) then
        if not ( IsList( line[1] ) and ForAll( line[1], IsInt ) ) then
          return false;
        fi;
        if not testline( line[1] ) then
          return false;
        fi;
        AddSet( defined, line[2] );
      elif not ( Length( line ) = 3 and line[1] = "Order"
          and IsPosInt( line[2] )
          and line[2] <= defined and IsPosInt( line[3] ) ) then

        # The syntax of the line is not correct.
        return false;

      fi;
    od;

    return true;
    end );


#############################################################################
##
#M  PrintObj( <prog> )
##
InstallMethod( PrintObj,
    [ "IsStraightLineDecision" ],
    function( prog )
    Print( "StraightLineDecision( ",
           LinesOfStraightLineDecision( prog ) );
    if HasNrInputsOfStraightLineDecision( prog ) then
      Print( ", ", NrInputsOfStraightLineDecision( prog ) );
    fi;
    Print( " )" );
    end );


#############################################################################
##
#M  ViewObj( <prog> )
##
InstallMethod( ViewObj,
    [ "IsStraightLineDecision" ],
    function( prog )
    Print( "<straight line decision>" );
    end );


#############################################################################
##
#M  AsBBoxProgram( <prog> )
##
InstallMethod( AsBBoxProgram,
    [ "IsStraightLineProgram" ],
    function( prog )
    prog:= AtlasStringOfProgram( prog );
    # Straight line programs use `iv', black box programs use `inv'.
    prog:= ReplacedString( prog, "\niv ", "\ninv " );
    prog:= ScanBBoxProgram( prog );
    if prog = fail then
      return fail;
    fi;
    return prog.program;
    end );


#############################################################################
##
#M  AsBBoxProgram( <dec> )
##
InstallMethod( AsBBoxProgram,
    [ "IsStraightLineDecision" ],
    function( dec )
    dec:= AtlasStringOfProgram( dec );
    # Straight line programs use `iv', black box programs use `inv'.
    dec:= ReplacedString( dec, "\niv ", "\ninv " );
    dec:= ScanBBoxProgram( dec );
    if dec = fail then
      return fail;
    fi;
    return dec.program;
    end );


#############################################################################
##
#M  AsStraightLineProgram( <bbox> )
##
InstallMethod( AsStraightLineProgram,
    [ "IsBBoxProgram" ],
    function( bbox )
    local lines;

    lines:= JoinStringsWithSeparator( List( LinesOfBBoxProgram( bbox ),
                l -> JoinStringsWithSeparator( List( l, String ), " " ) ),
                "\n" );
    # Straight line programs use `iv', black box programs use `inv'.
    lines:= ReplacedString( lines, "\ninv ", "\niv " );
    lines:= ScanStraightLineProgram( lines, "string" );
    if lines = fail then
      return fail;
    fi;
    return lines.program;
    end );


#############################################################################
##
#M  AsStraightLineDecision( <bbox> )
##
InstallMethod( AsStraightLineDecision,
    [ "IsBBoxProgram" ],
    function( bbox )
    local lines;

    lines:= JoinStringsWithSeparator( List( LinesOfBBoxProgram( bbox ),
                l -> JoinStringsWithSeparator( List( l, String ), " " ) ),
                "\n" );
    # Straight line programs use `iv', black box programs use `inv'.
    lines:= ReplacedString( lines, "\ninv ", "\niv " );
    lines:= ScanStraightLineDecision( lines );
    if lines <> fail then
      return lines.program;
    fi;
    end );


#############################################################################
##
#E

