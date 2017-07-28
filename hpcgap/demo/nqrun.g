ReadGapRoot("demo/bench.g");
ReadGapRoot("demo/nqueens.g");

if IsBound(SetMaxTaskWorkers) then
  SetMaxTaskWorkers(12);
fi;

N := 12;

tseq := Bench(do CountSolutions(N); od);
Print("Seq: ", tseq, "\n");
tpar := Bench(do CountSolutionsPar(N); od);
Print("Par: ", tpar, "\n");
Print("Speedup ", tseq/tpar, "\n");
