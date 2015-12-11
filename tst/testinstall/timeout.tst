gap> START_TEST("timeout.tst");
gap> spinFor := function(ms, arg...) local t;
> t := Runtimes().user_time + Runtimes().system_time;
> while Runtimes().user_time + Runtimes().system_time < t + ms do od;
> if Length(arg) >= 1
> then return arg[1]; else return; fi; end;
function( ms, arg... ) ... end
gap> spinFor(10);
gap> spinFor(10,0);
0
gap> CallWithTimeout(50000,spinFor,1);
[ true ]
gap> CallWithTimeout(5000,spinFor,50000);
[ false ]
gap> CallWithTimeout(50000,spinFor,1,1);
[ true, 1 ]
gap> CallWithTimeoutList(50000,spinFor,[1,1]);
[ true, 1 ]
gap> CallWithTimeoutList(5000,spinFor,[50000,1]);
[ false ]
gap> CallWithTimeoutList(50000,spinFor,[1]);
[ true ]
gap> spin2 := function(use, timeout) return CallWithTimeout(timeout, spinFor, use); end;
function( use, timeout ) ... end
gap> CallWithTimeout(100000, spin2,200,50000);
[ true, [ false ] ]
gap> CallWithTimeout(100000, spin2,50,200000);
[ true, [ true ] ]
gap> CallWithTimeout(1000000, spin2,50,200000);
[ true, [ true ] ]
gap> CallWithTimeout(10000, spin2,50,200000);                                           
[ false ]
gap> ct := 0;; CallWithTimeout(200000, function() while true do spin2(50,500000); ct := ct+1; od; end);; 2 <= ct; ct <= 10;
true
true
gap> STOP_TEST( "timeout.tst", 330000);
