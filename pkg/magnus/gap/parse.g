if not IsBound(InfoMagnus) then
    DeclareInfoClass("InfoMagnus");
fi;

MagnusTokenise := function(s)
    local tokens, next, depth, tokstart;
    next := 1;
    tokens := [];
    while next <= Length(s) do
        if s[next] = ' ' then
            next := next+1;
        else
            tokstart := next;
            if s[next] = '{' then
                depth := 1;
                while true do
                    next := next+1;
                    if s[next] = '{' then
                        depth := depth+1;
                    elif s[next] = '}' then
                        depth := depth-1;
                        if depth = 0 then 
                            break;
                        fi;
                    elif next = Length(s) then
                      Error("Unbalanced brackets");
                    fi;
                od;
                Add(tokens,s{[tokstart+1..next-1]});
                next := next+1;
            else
                repeat
                    next := next+1;
                until next > Length(s) or s[next] = ' ';
                Add(tokens,s{[tokstart..next-1]});
            fi;

        fi;
    od;
    return tokens;
end;

MagnusParseCommand := function(line)
    local toks;
    toks := MagnusTokenise(line);
    return rec(name := toks[1], args := toks{[2..Length(toks)]});
end;

MagnusParseKeywordData := function(toks)
    local r,i;
    r := rec();
    Assert(1,Length(toks) mod 2 = 0);
    for i in [1,3..Length(toks)-1] do
        r.(toks[i]) := toks[i+1];
    od;
    return r;
end;

MagnusParseKeywordCommand := function(cmd)
    local r;
    r := MagnusParseKeywordData(cmd.args);
    r.name := cmd.name;
    return r;
end;
    
MagnusParseItem := function(item)
    local toks;
    toks := MagnusTokenise(item);
    return rec(type := "real", text := toks[1], action := toks[2],
               message := toks[3]);
end;

MagnusParseOneMenuDefn := function(cmd)
    local  r, igs, ig, ig1, igr, is, item, itemparts;
    Assert(1,cmd.name = "menu_defn_");
    r := rec();
    r.menu := cmd.menu;
    r.sig := cmd.signature;
    r.itemgroups := [];
    igs := MagnusTokenise(cmd.itemGroups);
    for ig in igs do
        ig1 := MagnusTokenise(ig);
        igr := rec(cond := ig1[1], items := []);
        is := MagnusTokenise(ig1[2]);
        for item in is do
            if item <> "s" then
                itemparts := MagnusTokenise(item);
                if itemparts[1] = "c" then
                    Add(igr.items, rec(type := "cascade", text :=
                            itemparts[2], subitems :=
                                    List(MagnusTokenise(itemparts[3]), 
                                         MagnusParseItem)));
                else
                    Add(igr.items, MagnusParseItem(item));
                fi;
            fi;
        od;
        Add(r.itemgroups,igr);
    od;
    return r;
end;

MagnusIntegrateItemList := function( session, il, menu, sig, cond)
    local item, submenu;
    for item in il do
        if item.type = "real" then
            Add(session.MenuCmds, rec( menu := menu, sig := sig, cond := 
                                             cond, text := item.text,
                                             action := item.action,
                                             message := item.message));
        elif item.type = "cascade" then
            submenu := ShallowCopy(menu);
            Add(submenu, item.text);
            MagnusIntegrateItemList( session, item.subitems, submenu, sig, cond);
        else
            Error("Urecognised Item type");
        fi;
    od;
end;
    
MagnusIntegrateMenuDefn := function(session,md)
    local ig;
    for ig in md.itemgroups do
        MagnusIntegrateItemList( session, ig.items, [md.menu], md.sig, ig.cond );
    od;
end;

NewMagnusSession := function()
    return rec(MenuCmds := [], Messages := rec(), Objects := [], Log
               := "", BootDone := false);
end;

MagnusHandleMenuDefn := function(session, cmd)
    MagnusIntegrateMenuDefn(session,MagnusParseOneMenuDefn(MagnusParseKeywordCommand(cmd)));
end;
    

MagnusSetMessage := function(session, cmd)
    local name;
    name := cmd.name{[6..Length(cmd.name)-5]};
    session.Messages.(name) := cmd.args[1];
end;

MagnusPostLog := function(session, cmd)
    local viewids, text, level, obj;
    viewids := MagnusTokenise(cmd.args[1]);
    text := cmd.args[2];
    if text[1] = '{' then
        text := text{[2..Length(text)-1]};
    fi;
    level := Int(cmd.args[3]);
    Info(InfoMagnus,level,text);
    if level = 1 then
        Append(session.Log,text);
        Add(session.Log,'\n');
    fi;
    for obj in session.Objects do
        if obj.viewStructure.viewParameters.viewID in viewids then
            Append(obj.log,text);
            Add(obj.log,'\n');
        fi;
    od;
end;

MagnusParseCreate := function(cmd)
    local kcmd, vs, i;
    kcmd := MagnusParseKeywordCommand(cmd);
    Unbind(kcmd.name);
    vs  := MagnusParseKeywordData(MagnusTokenise(kcmd.viewStructure));
    kcmd.viewStructure := vs;
    vs.viewParameters := MagnusParseKeywordData(MagnusTokenise(vs.viewParameters));
    kcmd.log := "";
    kcmd.properties := MagnusTokenise(kcmd.properties);
    for i in [1..Length(kcmd.properties)] do
        kcmd.properties[i] := MagnusParseKeywordData(kcmd.properties[i]);
    return kcmd;
end;

A

MagnusHandleCreate := function(session, cmd)
    local obj;
    obj := MagnusParseCreate(cmd);
    Add(session.Objects,obj );
    AbsorbProperties(session,obj);
end;

MagnusBootDone := function(session, cmd)
    session.BootDone := true;
end;

MagnusCommandFunctions := [
                           rec( cmds := ["menu_defn_"], act :=
                                MagnusHandleMenuDefn ),
                           rec( cmds := ["magic_cookie_",
                                   "type_name_",  "arc_update_"], act := false ),
                           rec( cmds := ["init_quit_msg_","init_delete_msg_","init_setName_msg_",
                                   "init_view_req_msg_","init_arc_msg_","init_start_msg_",
                                   "init_suspend_msg_",
                                   "init_resume_msg_", "init_terminate_msg_","init_parameter_msg_",
                                   "init_map_gens_msg_"],
                                act := MagnusSetMessage ),
                           rec( cmds := ["post_to_log_"], act :=
                                MagnusPostLog ),
                           rec( cmds := ["create_"], act := MagnusHandleCreate),
                           rec( cmds := ["boot_done_"], act := MagnusBootDone)            

                           ];
    

MagnusHandleCommand := function(session,line)
    local cmd, r;
    cmd := MagnusParseCommand(line);
    r := First(MagnusCommandFunctions, x->cmd.name in x.cmds);
    if r = fail then
        Info(InfoMagnus+InfoWarning,1,"Unrecognised Command ",cmd.name);
    else
        if r.act <> false then
            r.act(session,cmd);
        fi;
    fi;
end;
    
MagnusRunTranscript := function(file)
    local str, line, cmd, session;
    session := NewMagnusSession();
    str := InputTextFile(file);
    while not IsEndOfStream(str) do
        line := ReadLine(str);
        if line <> fail and line[1] = '<' then
            line := line{[Position(line,' ')+1..Length(line)]};
            if line[Length(line)] = '\n' then
                line := line{[1..Length(line)-1]};
            fi;
            MagnusHandleCommand(session,line);
        fi;
    od;
    CloseStream(str);
    return session;
end;

AbsorbProperties := function(session, props);