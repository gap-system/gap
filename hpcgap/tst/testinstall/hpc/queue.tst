#
# test queue.g code
#

#
gap> QueueToList:=function(q)
>   local l, len;
>   q:=ShallowCopy(q);
>   l:=[];
>   len:=LengthQueue(q);
>   while not EmptyQueue(q) do
>     Add(l, PopQueueFront(q));
>     Assert(0, len = LengthQueue(q) + Length(l));
>   od;
>   return l;
> end;;
gap> QueueToListRev:=function(q)
>   local l, len;
>   q:=ShallowCopy(q);
>   l:=[];
>   len:=LengthQueue(q);
>   while not EmptyQueue(q) do
>     Add(l, PopQueueBack(q));
>     Assert(0, len = LengthQueue(q) + Length(l));
>   od;
>   return l;
> end;;
gap> TestQueue:=function(q)
>   local l, l2;
>   l:=QueueToList(q);
>   l2:=QueueToListRev(q);
>   Assert(0, Reversed(l) = l2);
>   return l;
> end;;

# test empty queue
gap> q := NewQueue();;
gap> TestQueue(q);
[  ]

# test head = last in PopQueueFront
gap> q := NewQueue();;
gap> PushQueueFront(q, 42);
gap> TestQueue(q);
[ 42 ]

# test tail = last in PushQueueFront
gap> q := NewQueue();;
gap> for i in [1..7] do PushQueueBack(q,i); od;
gap> PushQueueFront(q, 0);
gap> TestQueue(q);
[ 0, 1, 2, 3, 4, 5, 6, 7 ]

# test tail < head in LengthQueue
gap> q := NewQueue();;
gap> PushQueueFront(q,1);
gap> PushQueueBack(q,2);
gap> TestQueue(q);
[ 1, 2 ]

# test tail = 3 in QueueTail
gap> q := NewQueue();;
gap> for i in [1..7] do PushQueueBack(q,i); od;
gap> PopQueueFront(q);
1
gap> PushQueueBack(q,8);
gap> QueueTail(q);
8
gap> TestQueue(q);
[ 2, 3, 4, 5, 6, 7, 8 ]

# test growing the list using PushQueueBack till it expands
gap> q := NewQueue();;
gap> for i in [1..10] do PushQueueBack(q, i); od;
gap> TestQueue(q);
[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]

# test growing the list using PushQueueBack till it expands
gap> q := NewQueue();;
gap> for i in [1..10] do PushQueueFront(q, i); od;
gap> TestQueue(q);
[ 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]

# test growing the list till it expands
gap> q := NewQueue();;
gap> PushQueueBack(q, 1);
gap> PushQueueBack(q, 2);
gap> PushQueueBack(q, 3);
gap> PushQueueFront(q, 0);
gap> PushQueueFront(q, -1);
gap> PushQueueFront(q, -2);
gap> PushQueueBack(q, 4);
gap> PushQueueBack(q, 5);
gap> TestQueue(q);
[ -2, -1, 0, 1, 2, 3, 4, 5 ]
gap> PopQueueFront(q);
-2
gap> TestQueue(q);
[ -1, 0, 1, 2, 3, 4, 5 ]
gap> PopQueueFront(q);
-1
gap> TestQueue(q);
[ 0, 1, 2, 3, 4, 5 ]
gap> PopQueueBack(q);
5
gap> TestQueue(q);
[ 0, 1, 2, 3, 4 ]
gap> PopQueueBack(q);
4
gap> TestQueue(q);
[ 0, 1, 2, 3 ]
gap> QueueHead(q);
0
gap> QueueTail(q);
3
