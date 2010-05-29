SetInfoLevel(InfoParkit,2);
Test1 := function()
    local   m,  NoOp,  type,  outs;
    
    m := CreateParkitManager();
    
    NoOp := function(taskid, channel, inputs)
        Print("Hello World\n");
        SendChannel(channel, rec( op := "finished", taskID := taskid));
    end;

    SendChannel(m.channel, rec(op := "register", taskID := 0, key := "NoOp", func := NoOp));

    SendChannel(m.channel, rec(op := "submit", 
            type := "NoOp", ins := [],
                                   outs := [], taskID := 0));

    SendChannel(m.channel, rec(op := "quit"));

end;

ParListViaParkitDivideAndConquer := function(l, f, chunk)
    local   m,  emitter,  collector,  worker,  splitter,  joiner,  
            overall,  x,  func,  taskID,  v,  ins;
    m := CreateParkitManager();
    
    emitter := function(taskID, channel, ins)
        SendChannel(channel, rec(op := "ProvideOutput", 
                which := 1,
                                 value := l,
                                 taskID := taskID));
        SendChannel(channel, rec(op := "Finished",
                taskID := taskID));
    end;
    
    collector := function(taskID, channel, ins)
        WriteSyncVar(v,ins[1]);
        SendChannel(channel, rec(op := "Finished",
                taskID := taskID));
    end;
    
    worker := function(taskID, channel, ins)
        local   l;
        l := Length(ins[1]);
        if l > chunk then
            SendChannel(channel, rec(op := "Submit",
                taskID := taskID,
                                 type := "splitter",
                                 ins := [1],
                                 outs := ["t1","t2"]
                                 ));
            SendChannel(channel, rec(op := "Submit",
                taskID := taskID,
                                 type := "worker",
                                 ins := ["t1"],
                                 outs := ["u1"]
                                 ));
            SendChannel(channel, rec(op := "Submit",
                taskID := taskID,
                                 type := "worker",
                                 ins := ["t2"],
                                 outs := ["u2"]
                                 ));
            SendChannel(channel, rec(op := "Submit",
                taskID := taskID,
                                 type := "joiner",
                                 ins := ["u1","u2"],
                                 outs := [1]
                                 ));
        else
            SendChannel(channel, rec(op := "ProvideOutput",
                taskID := taskID,
                                 which := 1,
                                 value := List(ins[1],f)
                                 ));
        fi;
                                                                 
        SendChannel(channel, rec(op := "Finished",
                taskID := taskID));
    end;
    splitter := function(taskID, channel, ins)
        local   l,  m;
        l := Length(ins[1]);
        m := Int(l/2);
        SendChannel(channel, rec(op := "ProvideOutput",
                    taskID := taskID,
                                 which := 1,
                                 value := ins[1]{[1..m]}
                                 ));
        SendChannel(channel, rec(op := "ProvideOutput",
                taskID := taskID,
                                 which := 2,
                                 value := ins[1]{[m+1..l]}
                                 ));
        SendChannel(channel, rec(op := "Finished",
                taskID := taskID));
    end;
    
    joiner := function(taskID, channel, ins)
        SendChannel(channel, rec(op := "ProvideOutput",
                    taskID := taskID,
                                 which := 1,
                                 value := Concatenation(ins)
                                 ));
        SendChannel(channel, rec(op := "Finished",
                taskID := taskID));
    end;
    overall := function(taskID, channel, ins)
            SendChannel(channel, rec(op := "Submit",
                taskID := taskID,
                                 type := "emitter",
                                 ins := [],
                                 outs := ["t1"]
                                 ));
            SendChannel(channel, rec(op := "Submit",
                taskID := taskID,
                                 type := "worker",
                                 ins := ["t1"],
                                 outs := ["u1"]
                                 ));
            SendChannel(channel, rec(op := "Submit",
                taskID := taskID,
                                 type := "collector",
                                  ins := ["u1"],
                                  outs := []
                                  ));
        SendChannel(channel, rec(op := "Finished",
                taskID := taskID));
    end;
    for x in [["emitter",emitter], ["collector", collector],
            ["splitter", splitter], ["joiner", joiner],
            ["worker", worker], ["overall", overall]] do
        SendChannel(m.channel, rec(op := "register", key := x[1],
                                                             func := x[2],
                                                             taskID := 0));
    od;
    v := CreateSyncVar();
    
    SendChannel(m.channel, rec(op := "submit", type := "overall",
            ins := [], outs := [], taskID := 0));
    return ReadSyncVar(v);
end;    
        
        
            
        
