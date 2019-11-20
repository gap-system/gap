#@if IsHPCGAP
# Tests for HPC-GAP channels
#
# TODO: right now these tests are all using a single thread; add some which
# use multiple threads, and also non-dynamic (i.e., blocking) channels.
#
# create a dynamic channel
gap> ch := CreateChannel();;
gap> SendChannel(ch, 3);
gap> SendChannel(ch, 2);
gap> SendChannel(ch, 1);
gap> TallyChannel(ch);
3
gap> InspectChannel(ch);
[ 3, 2, 1 ]
gap> ReceiveChannel(ch);
3
gap> InspectChannel(ch);
[ 2, 1 ]
gap> ReceiveChannel(ch);
2

# grow the channel till it is full at capacity (initially 10)
# note that since we already pre-filled the channel with some data,
# the loop causes it to "wrap around" (internally a channel is a
# queue, implemented as a ring buffer).
gap> for i in [2..9] do SendChannel(ch, i); od;
gap> TallyChannel(ch);
9

# empty the channel
gap> List([1..9], i -> ReceiveChannel(ch));
[ 1, 2, 3, 4, 5, 6, 7, 8, 9 ]

# now fill it again, this time exceeding the initial capacity
gap> for i in [1..20] do SendChannel(ch, i); od;
gap> TallyChannel(ch);
20

# we are done with this channel
gap> DestroyChannel(ch);

# new one; this time, we test what happens if we expand when the head of
# the queue is near the end of the underlying plist
gap> ch := CreateChannel();;
gap> for i in [1..9] do SendChannel(ch, i); od;
gap> List([1..8], i -> ReceiveChannel(ch));
[ 1, 2, 3, 4, 5, 6, 7, 8 ]
gap> for i in [10..19] do SendChannel(ch, i); od;
gap> DestroyChannel(ch);

#
# Create a thread that blocks while trying to send to a channel
#
gap> chA := CreateChannel(5);;
gap> chB := CreateChannel();;
gap> for i in [1..5] do SendChannel(chA,i); od;
gap> [ InspectChannel(chA), InspectChannel(chB) ];
[ [ 1, 2, 3, 4, 5 ], [  ] ]
gap> t:=CreateThread(
> function()
> local x;
> SendChannel(chA,42); # this blocks until another thread reads from chA
> x:=ReceiveChannel(chA);
> SendChannel(chB,x);
> end);;
gap> [ InspectChannel(chA), InspectChannel(chB) ];
[ [ 1, 2, 3, 4, 5 ], [  ] ]
gap> ReceiveChannel(chA);
1
gap> WaitThread(t);
gap> [ InspectChannel(chA), InspectChannel(chB) ];
[ [ 3, 4, 5, 42 ], [ 2 ] ]

#
# Create a thread that blocks while trying to read from several channels
#
gap> chA := CreateChannel(5);
<channel with 0/5 elements, 0 waiting>
gap> chB := CreateChannel();
<channel with 0 elements, 0 waiting>
gap> [ InspectChannel(chA), InspectChannel(chB) ];
[ [  ], [  ] ]
gap> t:=CreateThread(function() ReceiveAnyChannel(chA,chB); end);;
gap> [ InspectChannel(chA), InspectChannel(chB) ];
[ [  ], [  ] ]
gap> MultiTransmitChannel(chA, [ 1, 2, 3 ]);
gap> WaitThread(t);
gap> [ InspectChannel(chA), InspectChannel(chB) ];
[ [ 2, 3 ], [  ] ]
gap> TryMultiSendChannel(chA, [10..19]);
3
gap> TryMultiTransmitChannel(chB, [20..29]);
10
gap> [ InspectChannel(chA), InspectChannel(chB) ];
[ [ 2, 3, 10, 11, 12 ], [ 20, 21, 22, 23, 24, 25, 26, 27, 28, 29 ] ]

#
# Some manual examples
#

#
gap> ch := CreateChannel(1);;
gap> TrySendChannel(ch, 1);
true
gap> TrySendChannel(ch, 2);
false

#
gap> ch := CreateChannel();;
gap> SendChannel(ch, 99);
gap> TryReceiveChannel(ch, fail);
99
gap> TryReceiveChannel(ch, fail);
fail

#
gap> ch:=CreateChannel();;
gap> MultiSendChannel(ch, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
gap> MultiReceiveChannel(ch,7);
[ 1, 2, 3, 4, 5, 6, 7 ]
gap> MultiReceiveChannel(ch,7);
[ 8, 9, 10 ]
gap> MultiReceiveChannel(ch,7);
[  ]

#
gap> ch1 := CreateChannel();;
gap> ch2 := CreateChannel();;
gap> SendChannel(ch2, [1, 2, 3]);;
gap> ReceiveAnyChannel(ch1, ch2);
[ 1, 2, 3 ]

#
gap> ch1 := CreateChannel();;
gap> ch2 := CreateChannel();;
gap> SendChannel(ch2, [1, 2, 3]);;
gap> ReceiveAnyChannelWithIndex(ch1, ch2);
[ [ 1, 2, 3 ], 2 ]

# TODO: add tests for these:
# TransmitChannel
# MultiTransmitChannel
# TryMultiSendChannel
# TryMultiTransmitChannel
# TryTransmitChannel
# ReceiveAnyChannel

#@fi
