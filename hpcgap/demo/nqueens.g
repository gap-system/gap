NewBoard := function(n)
  return List([1..n],
    x->List([1..n], y->false));
end;

LegalMove := function(board, n, x, y)
  local i;
  for i in [1..x-1] do
    if board[i][y] or (i < y and board[x-i][y-i]) or
       (y <= n-i and board[x-i][y+i]) then
      return false;
    fi;
  od;
  return true;
end;

CountSolutionsRec := function(board, n, x)
  local result, y;
  result := 0;
  for y in [1..n] do
    if LegalMove(board, n, x, y) then
      if x = n then
        result := result + 1;
      else
	board[x][y] := true;
	result := result + CountSolutionsRec(board, n, x+1);
	board[x][y] := false;
      fi;
    fi;
  od;
  return result;
end;

CountSolutions := function(n)
  return CountSolutionsRec(NewBoard(n), n, 1);
end;

CountSolutionsPar := function(n)
  local i, boards, tasks;
  tasks := [];
  boards := List([1..n], x->fail);
  for i in [1..n] do
    boards[i] := NewBoard(n);
    boards[i][1][i] := true;
    Add(tasks, RunTask(CountSolutionsRec, boards[i], n, 2));
  od;
  return Sum(List(tasks, TaskResult));
end;
