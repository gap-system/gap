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

# new one; this time, we test what happens if we expand when the head of
# the queue is near the end of the underlying plist
gap> ch := CreateChannel();;
gap> for i in [1..9] do SendChannel(ch, i); od;
gap> List([1..8], i -> ReceiveChannel(ch));
[ 1, 2, 3, 4, 5, 6, 7, 8 ]
gap> for i in [10..19] do SendChannel(ch, i); od;

#
# Try some nonblocking APIs
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
