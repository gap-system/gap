SetInfoLevel(InfoParkit,2);
Test1 := function()
    local   m,  NoOp,  type,  outs;
    
    m := CreateParkitManager();
    
    NoOp := function(taskid, m, inputs)
        Print("Hello World\n");
        m.finished(taskid);
    end;
    
    m.register("NoOp", NoOp, 0);
    m.submit("NoOp",[],[],0,fail);
    StopParkitManager(m);

end;

ParListViaParkitDivideAndConquer := function(l, f, chunk)
    local   m,  emitter,  collector,  worker,  splitter,  joiner,  
            overall,  x,  func,  taskID,  v,  ins, res;
    m := CreateParkitManager();
    
    emitter := function(taskID, channel, ins)
        m.provideOutput(1,l,taskID);
        m.finished(taskID);
    end;
    
    collector := function(taskID, channel, ins)
        WriteSyncVar(v,ins[1]);
        m.finished(taskID);
    end;
    
    worker := function(taskID, m, ins)
        local   l;
        l := Length(ins[1]);
        if l > chunk then
            m.submit("splitter", [1],["t1","t2"], taskID, fail);
            m.submit("worker", ["t1"],["u1"],taskID, fail);
            m.submit("worker", ["t2"],["u2"],taskID, fail);
            m.submit("joiner", ["u1","u2"],[1], taskID, fail);
        else
            m.provideOutput(1, List(ins[1],f), taskID);
        fi;
        m.finished(taskID);
    end;
    
    splitter := function(taskID, m, ins)
        local   l,  n;
        l := Length(ins[1]);
        n := Int(l/2);
        m.provideOutput(1,ins[1]{[1..n]},taskID);
        m.provideOutput(2,ins[1]{[n+1..l]},taskID);
        m.finished(taskID);
    end;
    
    joiner := function(taskID, m, ins)
        m.provideOutput(1,Concatenation(ins), taskID);
        m.finished(taskID);
    end;
    
    overall := function(taskID, m, ins)
        m.submit("emitter",[],["t1"], taskID, fail);
        m.submit("worker",["t1"],["u1"], taskID, fail);
        m.submit("collector",["u1"],[], taskID, fail);
        m.finished(taskID);
    end;
    for x in [["emitter",emitter], ["collector", collector],
            ["splitter", splitter], ["joiner", joiner],
            ["worker", worker], ["overall", overall]] do
        m.register(x[1],x[2],0);
    od;
    v := CreateSyncVar();
    m.submit("overall",[],[],0,fail);
    res := ReadSyncVar(v);
    StopParkitManager(m);
    return res;
end;    
        
        
            
        
