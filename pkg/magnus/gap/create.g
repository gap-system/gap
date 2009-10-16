


FindMagnusCmd := function(session, profile)
    local filt,matches;
    filt := function(cmd)
        if IsBound(profile.menu) and profile.menu <>
           cmd.menu{[1..Length(profile.menu)]} then
            return false;
        fi;
        if IsBound(profile.sig) and profile.sig <> cmd.sig then
            return false;
        fi;
        if IsBound(profile.text) and PositionSublist(cmd.text,
                   profile.text) = fail then
            return false;
        fi;
        return true;
    end;
    matches := Filtered(session.MenuCmds, filt);
    if Length(matches) <> 1 then
        Error("Magnus Command not found, or too many commands found");
    fi;
    return matches[1];
end;

MagnusStringWord := function(gennames,w)
    local s,e,i;
    s := "";
    e := ExtRepOfObj(w);
    for i in [1,3..Length(e)-1] do
        Append(s,gennames[e[i]]);
        if e[i+1] <> 1 then
            Add(s,'^');
            Append(s,String(e[i]));
        fi;
        Add(s,' ');
    od;
    if Length(s) = 0 then
        s := "1";
    fi;
    return s;
end;

MagnusStringFpGroup := function(g)
    local s,gennames,i,r,rels;
    gennames := FamilyObj(One(FreeGroupOfFpGroup(g)))!.names;
    s := "< ";
    if Length(gennames) > 0 then
        Append(s, gennames[1]);
    fi;
    for i in [2..Length(gennames)] do
        Add(s,',');
        Add(s,' ');
        Append(s, gennames[i]);
    od;
    Add(s,';');
    Add(s,' ');
    rels := RelatorsOfFpGroup(g);
    if Length(rels) > 0 then
        Append(s,MagnusStringWord(gennames,rels[1]));
        for r in rels{[2..Length(rels)]} do
            Add(s,',');
            Add(s,' ');
            Append(s,MagnusStringWord(gennames,r));
        od;
    fi;
    Add(s,'>');
    return s;
end;

MagnusCreateFPGroupMess := function(session,g,name)
    local cmd, mess;
    cmd := FindMagnusCmd(session, rec( menu := ["checkin"], sig := "", 
                   text := "Finitely Presented Group"));
    mess := ShallowCopy(cmd.message);
    Add(mess,' ');
    Append(mess,name);
    Add(mess,' ');
    Append(mess,MagnusStringFpGroup(g));
    ConvertToStringRep(mess);
    return mess;
end;    

FindMagnusCommandForObject := function( session, obj, profile)
    local cmd,mess;
    cmd := FindMagnusCmd( session, rec( menu := profile.menu, sig :=
                   obj.typeID, text := profile.text));
    mess := ShallowCopy(cmd.message);
    Add(mess,' ');
    Append(mess,obj.objectID);
    return mess;
end;