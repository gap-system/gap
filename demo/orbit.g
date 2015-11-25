#
# Main routine
#

G:=MathieuGroup(24);
OurNumberOfGenerators:=2;
 
HashAddress:=function( point )
return point;
end;

# From InitiateApplicator:

 NumberOfHashServers:=3;
 OurFreeGroup:=FreeGroup(OurNumberOfGenerators);
 AbsGens:=GeneratorsOfGroup(OurFreeGroup);
 AssignGeneratorVariables(OurFreeGroup);
 OurAlpha:=AbsGens{[1..OurG]};
 OurBeta:=AbsGens{[OurG+1..2*OurG]};
 OurGamma:=AbsGens{[2*OurG+1..2*OurG+OurR]}; 
 MappingClassGroupGenerators([OurNumberOfGenerators]);
 Read("mympc.g");
 PrepareMinimization();

# End of part from InitiateApplicator:

    inhash := List( [1..3], i -> CreateChannel() );
    inrec := CreateChannel();
    inapp := CreateChannel();
    
    recorder := function()
        local log, num, x, t, s, aold, k, tot, i;
        log := [];
        num := 0;
        while true do
            x := ReceiveChannel(inrec);
            if x = fail then
                Print("Orbit length = ", Sum( List( log, Length ) ), "\n" );
                return;
            fi;
            for t in x do
                # received a list of [ s, aold, k, nr, a ]
                s:=t[1];
                aold:=t[2];
                k:=t[3];
                if not IsBound(log[s]) then
                    log[s]:=[];
                fi;
                if not IsBound(log[s][aold]) then
                    log[s][aold]:=[];
                fi;
                log[s][aold][k]:=t{[4..5]};
                num := num + 1;
            od;
            tot := Sum( List( log, Length ) );
            Print("Current orbit length = ", tot," ",num, "\n" );
 #           if tot * Length( OurAction ) = num then
 #               SendChannel( inapp, fail );
 #               SendChannel( inapp, fail );
 #               SendChannel( inapp, fail );
 #               for i in [1..3] do
 #                   SendChannel( inhash[ i ], fail );
 #               od;
 #               SendChannel( inrec, fail );
 #           fi;
        od;
    end;            
     
    hashkeeper := function(nr)
        local res, tup, tups, OurHashTable, TupleTable, NewTuples,h,t,a,found;
        OurHashTable:=[];
        TupleTable:=[];
        NewTuples:=[];
        while true do
            tups := ReceiveChannel(inhash[nr]);
            if nr = 1 then
                Print("Hashkeeper ", nr, " received ", tups, "\n" );              
            fi;
            if tups = fail then
                    return;
            fi;
            if tups[1][1]=0 then
                h:=tups[1][4];
                t:=ShallowCopy(tups[1][5]);
                Add(TupleTable,t); 
                OurHashTable[h]:=1;
                Add( NewTuples, [ nr, 1, t ] );
            else
              res:=[];
              for tup in tups do
                h:=tup[4];
                t:=ShallowCopy(tup[5]);
                found := false;
                while IsBound(OurHashTable[h]) do 
                    if TupleTable[OurHashTable[h]]=t then
                        Add(res, [ tup[1], tup[2], tup[3], nr, OurHashTable[h] ] );
                        found := true;
                    else
                        h:=h+1;
                        if h>HashPerServer then
                            h:=h-HashPerServer;
                        fi;
                    fi;
                od;
                if not found then
                    Add(TupleTable,t);
                    a:=Length(TupleTable);
                    OurHashTable[h]:=a;
                    Add( NewTuples, [ nr, a, t ] );
                    Add( res, [ tup[1], tup[2], tup[3], nr, a ] );
                fi;
              od;
              if nr = 1 then
                Print("Hashkeeper ", nr, " sending ", res, "\n" );              
              fi;
              SendChannel(inrec, res);
            fi;  
            if NewTuples<>[] then
              SendChannel( inapp, NewTuples );
              NewTuples:=[];
            fi;
        od;
    end;
    
    applicator := function()
    local i,ll,o,t,j,tt,a,s;
     while true do
        ll := ReceiveChannel(inapp);
        if ll = fail then
            return;
        fi;
        o:=List([1..NumberOfHashServers],k->[]);
        for i in [1..Length(ll)] do
            t:=ShallowCopy(ll[i][3]);
            for j in [1..Length(OurAction)] do
                tt:=List(OurAction[j],x->MappedWord(x,AbsGens,t));
                if not IsAbelian(PrincipalFiniteGroup) then
                    tt:=MinimizeTuple(tt);
                fi;  
                a:=OurHashAddress(tt);
                s:=a[1];
                a:=a[2];
                Add(o[s],[ ll[i][1], ll[i][2], j, a, tt ]);
            od;
        od;
        for s in [1..NumberOfHashServers] do
            if o[s]<>[] then
                SendChannel( inhash[s], o[s] );
            fi;
        od;
    od;
    end;
    
    
while true do
    tup:=[ x^Random(PrincipalFiniteGroup),
           x^Random(PrincipalFiniteGroup),
           x^Random(PrincipalFiniteGroup),
           x^Random(PrincipalFiniteGroup),
           x^Random(PrincipalFiniteGroup),
           x^Random(PrincipalFiniteGroup) ];
    Add(tup,Product(tup)^-1);
    if Order(tup[ Length (tup) ]) = 2 and 
       Subgroup( PrincipalFiniteGroup, tup ) = PrincipalFiniteGroup then
        break;
    fi;
od;
    
tup:=MinimizeTuple( tup );

a:=OurHashAddress(tup);
s:=a[1];
a:=a[2];

SendChannel( inhash[s], [ [ 0, 0, 0, a, tup ] ]);

Exec("sleep 3");
hashtreads := List([1..3], i->CreateThread(hashkeeper, i) );
Exec("sleep 3");
recthread := CreateThread( recorder );
Exec("sleep 3");
appthreads := List([1..3], i->CreateThread(applicator) );





