LoadPackage("io");
f := function(delay,x)
  Sleep(delay);
  return x^10;
end;
Print(ParTakeFirstResultByFork([f,f,f],[[2,17],[3,18],[4,19]]),"\n");
Print(ParTakeFirstResultByFork([f,f,f],[[4,17],[3,18],[4,19]]),"\n");
Print(ParTakeFirstResultByFork([f,f,f],[[4,17],[3,18],[2,19]]),"\n");
# A race condition:
Print(ParTakeFirstResultByFork([f,f,f],[[1,1],[1,2],[1,3]]),"\n");
Print(ParTakeFirstResultByFork([f,f,f],[[1,1],[1,2],[1,3]]),"\n");
Print(ParTakeFirstResultByFork([f,f,f],[[1,1],[1,2],[1,3]]),"\n");
