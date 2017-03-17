ReadGapRoot("demo/bench.g");
ReadGapRoot("demo/nqueens.g");

if IsBound(SetMaxTaskWorkers) then
  SetMaxTaskWorkers(12);
fi;

N := 12;

t := Bench(do CountSolutions(N); od);
Print("Seq: ", t, "\n");
t := Bench(do CountSolutionsPar(N); od);
Print("Par: ", t, "\n");
