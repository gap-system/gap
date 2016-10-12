#
# This is a test that Chris Jefferson <caj21@st-andrews.ac.uk> ran to benchmark
# HPC-GAP against legacy GAP
#
# This file can be read in HPC-GAP and legacy GAP
#
# All runtimes are in seconds, time taken by gettimeofday syscall
#
# On: Intel(R) Core(TM) i5-3320M CPU @ 2.60GHz 12GB RAM
#     DragonFly v4.3.1.522.geab4ae-DEVELOPMENT
#
#     GAP
#     v4.7.8-405-gd56a79a
#     [ 1.398771, 0.547569, 0.586479, 0.543494, 0.551666, 0.608868,
#       0.538831, 0.550874, 0.590647, 0.533375 ]
#
#     HPC-GAP
#     v4.7.8-1937-g27f9adb
#     ./make.hpc GC=boehm-par GCBLKSIZE=32768 ZMQ=no
#
#     sh bin/gap.sh
#     [ 1.863809, 1.059302, 1.029212, 1.016774, 1.025828, 1.002134
#     , 1.011906, 0.990309, 1.009315, 0.975533 ] 
#
#     sh bin/gap.sh -m 2g
#     [ 1.139157, 1.140261, 1.131134, 1.141077, 1.146236, 1.154671
#     , 1.090985, 0.918337, 0.909092, 0.914071 ]  
#
#     export GC_DONT_GC=1
#     sh bin/gap.sh -m 3g
#
#     [ 1.200419, 1.188618, 1.19537, 1.27388, 1.199707, 1.2004
#     , 1.189136, 1.190223, 1.197886, 1.194482 ]
#
#     ./make.hpc ZMQ=no
#     sh bin/gap.sh
#     [ 1.177997, 1.204405, 1.148141, 1.199733, 1.15236, 1.155158
#     , 1.155291, 1.200296, 1.149203, 1.173227 ]
#
#     sh bin/gap.sh -m 2g
#     [ 1.210171, 1.203508, 1.210213, 1.197907, 1.200302, 1.274284
#     , 0.986507, 0.912661, 0.924253, 0.913704 ]
#
#     export GC_DONT_GC=1
#     sh bin/gap.sh -m 3g
#     [ 1.991388, 1.166975, 1.192522, 1.183164, 1.209047, 1.199393,
#       1.205105, 1.213722, 1.211879, 1.215503 ]
#     

# (ZMQ=no is necessary because zeromq as bundled with hpcgap does not work
#  on DragonFly)

if not IsBound(CurrentTime) then
    if IsBound(IO_gettimeofday) then
        BindGlobal("CurrentTime", IO_gettimeofday);
    else
        Error("Don't know a way to get time of day\n");
    fi;
fi;
MicroSeconds := function()
    local t;
    t := CurrentTime();
    return t.tv_sec * 1000000 + t.tv_usec;
end;
Bench := function(f)
    local start,stop;
    start := MicroSeconds();
    f();
    stop := MicroSeconds();

    return (stop - start) * 1.0 / 1000000;
end;

p := (1,39,45,82,28,37,23,36,31,83,77,93,29,58,87,91,63,71,70,56,89,74,3,9,
16,54,97,60,96,26,84,40,79,13,73,48,86,72,34,22,35,57,2,10,65,59,66)(4,
92,81,12,21,64,42,25,88,85,33,100,49,24,20,76,8)(5,94,27,18,14,38)(6,53,
98,51,67,99,17,78,68,19,11,52,32,75,47,41,7,95,46,62,43,50,44,55)(15,69,
30,61,90);

res := [];

for i in [1..10] do
    Print("run ", i, "...");
    Add(res, Bench( do
       local g, h;
       g := DirectProduct(List([1..10], x -> AlternatingGroup(10)));
       h := g^p;
       Intersection(g,h);
    od) );
    Print(" completed.\n");
od;
Print(res);
