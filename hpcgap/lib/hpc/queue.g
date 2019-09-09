#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Reimer Behrends.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file implements queues. These can be used both as FIFO queues,
##  as deques, and as stacks.

BIND_GLOBAL("NewQueue", function()
  local result, i;
  result := EmptyPlist(10);
  result[1] := 3;
  result[2] := 3;
  for i in [3..10] do
    result[i] := fail;
  od;
  return result;
end);

BIND_GLOBAL("ExpandQueue", function(queue)
  local result, p, head, tail, last;
  head := queue[1];
  tail := queue[2];
  last := Length(queue);
  p := Length(queue) - 2;
  p := p * 2 + 2;
  result := EmptyPlist(p);
  while p > 2 do
    result[p] := fail;
    p := p - 1;
  od;
  result[1] := 3;
  p := 3;
  while head <> tail do
    result[p] := queue[head];
    p := p + 1;
    head := head + 1;
    if head > last then
      head := 3;
    fi;
  od;
  result[2] := p;
  MigrateSingleObj(result, queue);
  SWITCH_OBJ(queue, result);
end);

BIND_GLOBAL("PushQueue", function(queue, el)
  local head, tail, last;
  head := queue[1];
  tail := queue[2];
  last := Length(queue);
  if tail = last then
    if head = 3 then
      ExpandQueue(queue);
      tail := queue[2];
      queue[tail] := el;
      tail := tail + 1;
      queue[2] := tail;
    else
      queue[2] := 3;
      queue[last] := el;
    fi;
  elif tail + 1 <> head then
    queue[tail] := el;
    tail := tail + 1;
    queue[2] := tail;
  else
    ExpandQueue(queue);
    tail := queue[2];
    queue[tail] := el;
    tail := tail + 1;
    queue[2] := tail;
  fi;
end);

BIND_GLOBAL("PushQueueBack", PushQueue);

BIND_GLOBAL("PushQueueFront", function(queue, el)
  local head, tail, last;
  head := queue[1];
  tail := queue[2];
  last := Length(queue);
  if head = 3 then
    if tail = last then
      ExpandQueue(queue);
      head := Length(queue);
      queue[head] := el;
      queue[1] := head;
    else
      queue[1] := last;
      queue[last] := el;
    fi;
  elif tail + 1 <> head then
    head := head - 1;
    queue[head] := el;
    queue[1] := head;
  else
    ExpandQueue(queue);
    head := Length(queue);
    queue[head] := el;
    queue[1] := head;
  fi;
end);

BIND_GLOBAL("PopQueue", function(queue)
  local head, tail, last, result;
  head := queue[1];
  tail := queue[2];
  last := Length(queue);
  if head <> tail then
    if head = last then
      head := 3;
      result := queue[last];
      queue[last] := fail;
    else
      head := head + 1;
      result := queue[head-1];
      queue[head-1] := fail;
    fi;
    queue[1] := head;
    return result;
  fi;
end);

BIND_GLOBAL("PopQueueFront", PopQueue);

BIND_GLOBAL("PopQueueBack", function(queue)
  local head, tail, last, result;
  head := queue[1];
  tail := queue[2];
  last := Length(queue);
  if head <> tail then
    if tail = 3 then
      tail := last;
    else
      tail := tail - 1;
    fi;
    result := queue[tail];
    queue[tail] := fail;
    queue[2] := tail;
    return result;
  fi;
end);

BIND_GLOBAL("EmptyQueue", function(queue)
  return queue[1] = queue[2];
end);

BIND_GLOBAL("LengthQueue", function(queue)
  local head, tail;
  head := queue[1];
  tail := queue[2];

  if tail >= head then
    return tail - head;
  else
    return Length(queue) - 2 - (head - tail);
  fi;
end);

BIND_GLOBAL("QueueHead", function(queue)
  if queue[1] <> queue[2] then
    return queue[queue[1]];
  fi;
end);

BIND_GLOBAL("QueueTail", function(queue)
  local tail;
  tail := queue[2];
  if queue[1] <> tail then
    if tail <> 3 then
      return queue[tail-1];
    else
      return queue[Length(queue)];
    fi;
  fi;
end);

