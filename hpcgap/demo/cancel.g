task := RunTask(function()
  while true do
    OnTaskCancellation({}->99);
  od;
end);

RunAsyncTask(function()
  Sleep(1);
  CancelTask(task);
end);

Display(TaskResult(task));
