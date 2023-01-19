# Benchmark( func[, optrec] )
#
# func - a function taking no arguments
# optrec - an optional record with various options
#
# Measures how long executing the given function "func" takes.
# In order to improve accuracy, it invokes the function repeatedly.
# Before each repetition, the garbage collector is run, and
# (unless turned off by an option) the random number generators
# are reset.
# At the end, it outputs the average, median, and std deviation.
#
# Example:
# gap> Benchmark(function() Factors(x^293-1); end);
# .................................................
# Performed 49 iterations, taking 201 milliseconds.
# average: 4.1 +/- 0.11 (+/- 3%)
# median: 4.06396484375
# rec( avg := 4.09581, counter := 49, median := 4.06396, std := 0.109638, total := 200.695, var := 0.0120205 )
#
#
# The following options are currently implemented:
#
#  minreps:  the minimal number of repetitions;
#            the function will be executed at least that often,
#            unless some other condition (maxreps exceeded, maxtime exceeded)
#            aborts the benchmark early.
#  mintime:  the minimal number of milliseconds that has to pass before
#            benchmarking ends;
#            benchmarking will not stop before this time has passed,
#            unless some other condition (maxreps exceeded, maxtime exceeded)
#            aborts the benchmark early.
#  maxreps:  the maximal number of repetitions;
#            once this is reached, benchmarking stops immediately.
#  maxtime:  the maximal number of milliseconds before benchmarking ends;
#            once this is reached, benchmarking stops immediately.
#  showSummary:
#  showProgress:
#  resetRandom:  whether to reset the random number generators before each repetition (default: true)
#
#
# TODO: allow passing a function that is executed before every test run.
# That function can reset other state, flush caches etc.
#
Benchmark := function(func, arg...)
    local opt, getTime, timings, total, t, i, res;

    opt := rec(
                minreps := 5,
                maxreps := 1000,
                silent := false,
                resetRandom := true,
                mintime := 200,
                maxtime := infinity,
                showProgress := true,
                showSummary := true,
           );

    if Length(arg) = 1 and IsRecord(arg[1]) then
        for i in RecNames(arg[1]) do
            opt.(i) := arg[1].(i);
        od;
    elif Length(arg) <> 0 then
        Error("Usage: Benchmark( func[, optrec] )");
    fi;

    # force mintime and maxtime to be floats
    opt.mintime := Float(opt.mintime);
    opt.maxtime := Float(opt.maxtime);

    # if available, use NanosecondsSinceEpoch
    if IsBound(NanosecondsSinceEpoch) then
        getTime := function() return NanosecondsSinceEpoch()/1000000.; end;
    else
        getTime := Runtime;
    fi;

    timings := [];
    total := 0.0;
    i := 0;
    # repeat at most opt.maxreps times, and at least opt.minreps
    # times, resp. at least till opt.mintime milliseconds passed
    #
    # TODO: what we really should do is repeat until the variance
    # is low enough (or until it stagnates)
    while i < opt.maxreps and (opt.maxtime = infinity or total < opt.maxtime) and
        (i < opt.minreps or total < opt.mintime) do
        i := i + 1;

        if opt.resetRandom then
            Reset(GlobalMersenneTwister);
            Reset(GlobalRandomSource);
        fi;
        GASMAN("collect");

        t := getTime();
        func();
        t := getTime() - t;

        total := total + t;
        Add(timings, t);
        if opt.showProgress then
            #Print(".\c");
            Print(['\r', "|/-\\"[1+(i mod 4)],'\c']);
        fi;
    od;
    if opt.showProgress then
        #Print("\n");
        Print("\r   \c\r");
    fi;

    Sort(timings);

    res := rec();
    #res.timings := timings;
    res.total := total;
    res.counter := i;
    res.avg := Sum(timings) * 1.0 / res.counter;
    res.var := Sum(timings, t -> (t-res.avg)^2) / res.counter;
    res.std := Sqrt(res.var);
    if IsOddInt(res.counter) then
        res.median := timings[(res.counter+1)/2];
    else
        res.median := (timings[(res.counter)/2] + timings[(res.counter+2)/2]) / 2.;
    fi;
    # TODO: discard outliers?

    if opt.showSummary then
        Print("Performed ", res.counter, " iterations, taking ", Round(res.total), " milliseconds.\n");
        #Print("timings: ", timings, "\n");
        Print("average: ", Round(100*res.avg)/100,
            " +/- ", Round(100*res.std)/100,
            " (+/- ", Round(100*res.std/res.avg), "%)",
            "\n");
        Print("median: ", res.median, "\n");
    fi;

    return res;
end;

if false then
x:=X(Integers);
Benchmark(function() Factors(x^293-1); end);
Benchmark(function() Factors(x^293-1); end, rec(maxreps:=10));
fi;


PrintBoxed := function(str)
    local n, line;
    n := Length(str) + 2;
    line := Concatenation("+", ListWithIdenticalEntries(n,'-'), "+\n");
    Print(line);
    Print("| ", str, " |\n");
    Print(line);
end;

PrintHeadline := function(what);
    Print(TextAttr.5, "Testing ", what, ":\n",TextAttr.reset);
end;

MyBench := function(func)
    local opt, res;

    opt := rec(
        mintime:=300,
        #maxtime:=2000,
        maxreps:=200,
        showSummary := false
        );
    res := Benchmark(func, opt);

    Print("  ",
        Int(Round(res.total / res.counter * 1000.0)), " µs per iteration; ",
        Int(Round(res.counter * 1000.0 / res.total )), " iterations per second; ",
        "(", res.counter, " iterations)",
        "\n");

#     Print("  Performed ", res.counter, " iterations, taking ", Round(res.total), " milliseconds; ");
#     #Print("timings: ", timings, "\n");
# #     Print("average: ", Round(100*res.avg)/100,
# #         " +/- ", Round(100*res.std)/100,
# #         " (+/- ", Round(100*res.std/res.avg), "%)",
# #         "\n");
#     Print("  median: ", res.median, "\n");
end;
