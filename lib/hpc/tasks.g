#############################################################################
##
#W  tasks.g                       GAP library                 Chris Jefferson
##
##
##  This file provides trivial mocks of task-related primitives for
##  traditional GAP.
##
##  The major design decision here it to make these mocks fast and simple,
##  rather than try to make them as accurate as possible.
##

RunTask := function(func, args...)
    local result;
    result := CallFuncListWrap(func, args);
    if result = [] then
        return rec(taskresult := fail);
    else
        return rec(taskresult := result[1]);
    fi;
end;

TaskResult := function(task)
    return task.taskresult;
end;
