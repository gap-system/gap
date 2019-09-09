#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Werner Nickel.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains functions that support running demonstrations with
##  Gap.
##


#############################################################################
##
#F  Demonstration( <file> ) . . . . . . . . . . run a demonstration from file
##
if not IsBound(last) then
    UPDATE_STAT("last", fail);
fi;
if not IsBound(last2) then
    UPDATE_STAT("last2", fail);
fi;
if not IsBound(last3) then
    UPDATE_STAT("last3", fail);
fi;
if not IsBound(time) then
    UPDATE_STAT("time", fail);
fi;


BindGlobal( "Demonstration", function( file )
    local   input,  keyboard,  result, storedtime;

    input := InputTextFile( file );
    while input = fail do
        Error( "Cannot open file ", file );
    od;

    Print( "\nStart of demonstration.\n\n" );

    InputLogTo( "*stdout*" );
    keyboard := InputTextUser();
    Print( "demo> \c" );
    while CHAR_INT( ReadByte( keyboard ) ) <> 'q' do
        storedtime := Runtime();
        result:=READ_COMMAND_REAL( input, true ); # Executing the command.
        UPDATE_STAT("time", Runtime()-storedtime);
        if Length(result) = 2 then
            UPDATE_STAT("last3", last2);
            UPDATE_STAT("last2", last);
            UPDATE_STAT("last", result[2]);
            View( result[2] );
            Print("\n" );
        fi;

        if IsEndOfStream( input ) then
            break;
        fi;
        Print( "demo> \c" );
    od;
    Print( "\nEnd of demonstration.\n\n" );
    CloseStream( keyboard );
    CloseStream( input );
    InputLogTo();
end );

#############################################################################
##
#F  ReadVerbose( <file> ) . . . . . . . . . . run a demonstration from file
##
BindGlobal( "ReadVerbose", function( file )
local   input,command,exec,result,blank,semic,hash,process,l,view,estream;

    input := InputTextFile( file );
    while input = fail do
        Error( "Cannot open file ", file );
    od;

    blank:=" \n";
    semic:=';';
    hash:='#';
    exec:="";
    process:=function()
        local storedtime;
        view:=true;
        if exec[Length(exec)-1]=semic then
            view:=false;
        fi;
        estream:=InputTextString( exec );
        storedtime := Runtime();
        result:=READ_COMMAND_REAL( estream, true ); # Executing the command.
        UPDATE_STAT("time", Runtime()-storedtime);
        CloseStream(estream);
        if Length(result) = 2 then
            UPDATE_STAT("last3", last2);
            UPDATE_STAT("last2", last);
            UPDATE_STAT("last", result[2]);
            if view then
               View(result[2]);
               Print("\n");
            fi;
        fi;
        exec:="";
    end;
    command := ReadLine( input );      # Executing the command.
    while not IsEndOfStream(input) do
      if Length(exec)=0 then
        Print("gap> ");
      else
        Print("> ");
      fi;
      Print(command);

      # is there a hash mark anywhere?
      l:=1;
      while l<=Length(command) and command[l]<>hash do
        l:=l+1;
      od;
      l:=l-1;

      # remove trailing blanks
      while l>0 and command[l] in blank do
        l:=l-1;
      od;

      Append(exec,command{[1..l]});
      if l>0 and command[l]=semic then
        process();
      fi;

      command := ReadLine( input );      # Executing the command.
    od;
    CloseStream( input );
    if Length(exec)>0 then
      process();
    fi;
end );
