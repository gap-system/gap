#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Chris Jefferson.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file provides trivial mocks of task-related primitives for
##  traditional GAP.
##
##  The major design decision here it to make these mocks fast and simple,
##  rather than try to make them as accurate as possible.
##

BindGlobal( "RunTask", function(func, args...)
    local result;
    result := CallFuncListWrap(func, args);
    if result = [] then
        return rec(taskresult := fail);
    else
        return rec(taskresult := result[1]);
    fi;
end );

BindGlobal( "TaskResult", function(task)
    return task.taskresult;
end );

BindGlobal( "ScheduleTask", function(cond, func, args...)
    return CallFuncListWrap(RunTask, Concatenation([func], args))[1];
end );

BindGlobal( "WaitTask", function(args...)
    return;
end );
