SetInfoLevel(InfoParkit,2);
Test1 := function()
    local   m,  NoOp,  type,  outs;
    
    m := CreateParkitManager();
    
    NoOp := function(taskid, m, inputs)
        Print("Hello World\n");
        m.finished(taskid);
    end;
    
    m.register("NoOp", NoOp, 0);
    m.submit("NoOp",[],[],0);
    StopParkitManager(m);

end;

ParListViaParkitDivideAndConquer := function(l, f, chunk)
    local   m,  emitter,  collector,  worker,  splitter,  joiner,  
            overall,  x,  func,  taskID,  v,  ins, res;
    m := CreateParkitManager();
    
    emitter := function(taskID, m, ins)
        m.provideOutput(1,l,taskID);
        m.finished(taskID);
    end;
    
    collector := function(taskID, m, ins)
        SyncWrite(v,ins[1]);
        m.finished(taskID);
    end;
    
    worker := function(taskID, m, ins)
        local   l;
        l := Length(ins[1]);
        if l > chunk then
            m.submit("splitter", [1],["t1","t2"], taskID);
            m.submit("worker", ["t1"],["u1"],taskID);
            m.submit("worker", ["t2"],["u2"],taskID);
            m.submit("joiner", ["u1","u2"],[1], taskID);
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
        m.submit("emitter",[],["t1"], taskID);
        m.submit("worker",["t1"],["u1"], taskID);
        m.submit("collector",["u1"],[], taskID);
        m.finished(taskID);
    end;
    for x in [["emitter",emitter], ["collector", collector],
            ["splitter", splitter], ["joiner", joiner],
            ["worker", worker], ["overall", overall]] do
        m.register(x[1],x[2],0);
    od;
    v := CreateSyncVar();
    m.submit("overall",[],[],0,fail);
    res := SyncRead(v);
    StopParkitManager(m);
    return res;
end;    
        

StrassenMult := function(m1,m2, threshold)
    local   m,  n,  emitter,  collector,  splitter,  joiner,  adder,  
            sub,  multiplier,  overall,  v,  x,  res;

    m := CreateParkitManager();
    n := Length(m1);
    
    emitter := x-> function(taskID, m, ins)
        m.provideOutput(1,x,taskID);
        m.finished(taskID);
    end;
    
    collector := v-> function(taskID, m, ins)
        SyncWrite(v,ins[1]);
        m.finished(taskID);
    end; 
    
    splitter := function(taskID, m, ins)
        local   t,  n,  l,  s,  z,  pad,  r,  v;
        t := Runtime();
        n := Length(ins[1]);
        l := QuoInt(n+1,2);
        s := ins[1]{[1..l]}{[1..l]};
        m.provideOutput(1,s,taskID);
        z := Zero(ins[1][1][1]);
        s := ins[1]{[1..l]}{[l+1..n]};
        pad := n mod 2 = 1;
        if pad then
            for r in s do
                Add(r,z);
            od;
        fi;
        m.provideOutput(2,s,taskID);
        s := ins[1]{[l+1..n]}{[1..l]};
        if pad then
            v := ListWithIdenticalEntries(l,z);
            Add(s,v);
        fi;
        m.provideOutput(3,s,taskID);
        s := ins[1]{[l+1..n]}{[l+1..n]};
        if pad then
            for r in s do
                Add(r,z);
            od;
            Add(s,v);
        fi;
        m.provideOutput(4,s,taskID);
        m.finished(taskID, Runtime() - t);
    end;

         
       joiner := function(taskID, m, ins)
           local   l,  f,  s, t;
           t := Runtime();
           l := Length(ins[1]);
           f := DefaultRing(ins[1]);
           s := NullMat(2*l,2*l,f);
           s{[1..l]}{[1..l]} := ins[1];
           m.releaseInput(1,taskID);
           s{[1..l]}{[l+1..2*l]} := ins[2];
           m.releaseInput(2,taskID);
           s{[l+1..2*l]}{[1..l]} := ins[3];
           m.releaseInput(3,taskID);
           s{[l+1..2*l]}{[l+1..2*l]} := ins[4];
           m.releaseInput(4,taskID);
           m.provideOutput(1,s,taskID);
           m.finished(taskID, Runtime()-t);
       end;
       
       adder := function(taskID, m, ins)
           local t;
           t := Runtime();
           m.provideOutput(1,Sum(ins),taskID);
           m.finished(taskID, Runtime()-t);
       end;
       
       sub := function(taskID, m, ins)
           local t;
           t := Runtime();
           m.provideOutput(1,ins[1]-ins[2],taskID);
           m.finished(taskID, Runtime()-t);
       end;
       
       multiplier := function(taskID, m, ins)
           local t;
           t := Runtime();
           if Length(ins[1]) <= threshold then
               Perform(ins, TypeObj);
               m.provideOutput(1,Product(ins), taskID);
           else
               m.submit("splitter", [1],["a11","a12","a21","a22"], taskID);
               m.releaseInput(1,taskID);
               m.submit("splitter", [2],["b11","b12","b21","b22"], taskID);
               m.releaseInput(2,taskID);
               m.submit("adder", ["a11","a22"],["t1"], taskID);
               m.submit("adder", ["b11","b22"],["t2"], taskID);
               m.submit("multiplier",["t1","t2"],["m1"],taskID);
               m.submit("adder",["a21","a22"],["t3"],taskID);
               m.submit("multiplier",["t3","b11"],["m2"], taskID);
               m.submit("sub",["b12","b22"],["t4"],taskID);
               m.submit("multiplier",["a11","t4"],["m3"], taskID);
               m.submit("sub",["b21","b11"],["t5"],taskID);
               m.submit("multiplier",["a22","t5"],["m4"], taskID);
               m.submit("adder",["a11","a12"],["t6"],taskID);
               m.submit("multiplier",["t6","b22"],["m5"], taskID);
               m.submit("sub",["a21","a11"],["t7"], taskID);
               m.submit("adder",["b11","b12"],["t8"],taskID);
               m.submit("multiplier", ["t7", "t8"], ["m6"], taskID);
               m.submit("sub",["a12","a22"],["t9"], taskID);
               m.submit("adder",["b21","b22"],["t10"],taskID);
               m.submit("multiplier", ["t9", "t10"], ["m7"], taskID);
               
               m.submit("adder",["m1","m4","m7"],["u1"], taskID);
               m.submit("sub", ["u1", "m5"], ["c11"], taskID);
               m.submit("adder", ["m3","m5"], ["c12"], taskID);
               m.submit("adder", ["m2", "m4"], ["c21"], taskID);
               m.submit("adder", ["m1", "m3", "m6"], ["u2"], taskID);
               m.submit("sub", ["u2", "m2"], ["c22"], taskID);
               
               m.submit("joiner", ["c11","c12", "c21", "c22"], [1], taskID);
           fi;
           m.finished(taskID, Runtime() -t );
       end;
                      
       overall := function(taskID, m, ins)
           m.submit("emitter1",[],["t1"], taskID);
           m.submit("emitter2",[],["t2"], taskID);
           m.submit("multiplier",["t1", "t2"],["u"], taskID);
           m.submit("collector",["u"],[], taskID);
           m.finished(taskID);
       end;
    v := CreateSyncVar();
    for x in [["emitter1",emitter(m1)], 
            ["emitter2",emitter(m2)], 
            ["collector", collector(v)],
            ["splitter", splitter], ["joiner", joiner],
            ["adder", adder], 
            ["sub", sub], 
            ["multiplier", multiplier], 
            ["overall", overall]] do
        m.register(x[1],x[2],0);
    od;
    m.submit("overall",[],[],0);
    res := SyncRead(v);
    StopParkitManager(m);
    return res{[1..n]}{[1..n]};     
end;


TimeCurrent := function()
    local ct;
    ct := CurrentTime();
    return 1000000*ct.tv_sec + ct.tv_usec;
end;
