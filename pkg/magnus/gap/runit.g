PATH_TO_MAGNUS := "/home/sal/magnus/back_end/SessionManager/test/bin/magnus";

ReadLineBlocking := function(stream)
    local line, line2;
    line := ReadLine(stream);
    while not IsEndOfStream(stream) and (line = fail or line[Length(line)] <> '\n') do
        Sleep(1);
        line2 := ReadLine(stream);
        if line <> fail and line2 <> fail then
            Append(line,line2);
        else
            line := line2;
        fi;
    od;
    return line;
end;

StartMagnusSession := function()
    local session,str, line,line2;
    str := InputOutputLocalProcess(DirectoryTemporary(),PATH_TO_MAGNUS,[]);
    session := NewMagnusSession();
    while not session.BootDone do
        line := ReadLineBlocking(str);
        Info(InfoMagnus,2,line);
        line := line{[1..Length(line)-1]};
        MagnusHandleCommand(session, line);
    od;
    session.Stream := str;
    return session;
end;




CheckinFPGroup := function(session,g, name)
    local line,cmd, obj, kcmd;
    WriteAll(session.Stream,MagnusCreateFPGroupMess(session, g, name));
    WriteByte(session.Stream,INT_CHAR('\n'));
    line := ReadLineBlocking(session.Stream);
    if line[Length(line)] = '\n' then
        line := line{[1..Length(line)-1]};
    fi;
    cmd := MagnusParseCommand(line);
    if cmd.name = "create_" then
        obj := MagnusParseCreate(cmd);
        Add(session.Objects, obj);
        return obj;
    elif cmd.name = "syntax_error_in_defn_" then
        kcmd := MagnusParseKeywordCommand(cmd);
        Error("Magnus reports syntax error creating ",kcmd.name,": ",kcmd.errMesg);
    else
        Error("Unexpected response from Magnus ",line);
    fi;
end;
    
    
    
    
    