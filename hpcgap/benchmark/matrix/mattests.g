#
# Matrix arithmetic benchmarks
#

#
# Hack to work under GAP3 as well as GAP4
#

#
# makemats here is a function that returns a list of d x d matrices
# over the given field, The list contains all possibly different representations
# for GAP3 there is just one (since a non-vecffe representation will
# be converted by the kernel almost immediately anyway
#
# for GAP4, there are 8: all combinations of fully mutable, mutable
# list of immutable lists and fully immutable  with Plist of Plists,
# Plist of compressed vectors and special matrix rep (if any), except
# that fully mutable matrices cannot be in the special rep
#
# I changed the actual matrix from the one Willem used to get one with 
# a realistic density of zeros, This leaves a problem with testing
# Inverse in GAP3
# because the matrices are not always invertible.
#
#

if IsBound(VERLIB)  then
    Immutable := x->x;
    Inverse := x->x^-1;
    makemats := function(d,F)
        local q, m, i, j, z;    
        q:= Size(F);
        z := Z(q);
        m := [];
        for i in [1..d] do
            m[i] := (z*0)*[1..d];
            IsVector(m[i]);
        od;
        for i in [1..d] do
            for j in [1..d] do
                if (i +j) mod q <> 0 then
                    m[i][j]:= z^(i-1)*z^(j-1);
                fi;
            od;
        od;
        return [m];
    end;
    nmats := 1;
else
   
    makemats := function(d,F)
        local z, q, m, mats, i, j;    
        z:= PrimitiveRoot( F );
        q := Size(F);
        m:= NullMat( d, d, F );
        for i in [1..d] do
            for j in [1..d] do
                if (i+j) mod q <> 0 then
                    m[i][j]:= z^(i-1)*z^(j-1);
                fi;
            od;
        od;
        mats := [];
        mats[1] := List(m, PlainListCopy);
        mats[2] := List(mats[1], Immutable);
        mats[3] := Immutable(mats[1]);
        mats[4] := m;
        mats[5] := StructuralCopy(m);
        for i in mats[5] do
            MakeImmutable(i);
        od;
        mats[6] := Immutable(mats[5]);
        mats[7] := ShallowCopy(mats[5]);
        ConvertToMatrixRep(mats[7], F);
        mats[8] := Immutable(mats[7]);
        return mats;
    end;
    nmats := 8;
fi;


#
#  some lists of field sizes
#

allqs:= [ 
  2, 3, 4, 5, 7, 8, 9, 11, 13, 16, 17, 19, 23, 25, 27, 29, 31, 32, 37, 41, 
  43, 47, 49, 53, 59, 61, 64, 67, 71, 73, 79, 81, 83, 89, 97, 101, 103, 107, 
  109, 113, 121, 125, 127, 128, 131, 137, 139, 149, 151, 157, 163, 167, 169, 
  173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 243, 
  251, 256, 257, 1009 ];

someqs := [ 2,3,4,9,11,16,27,71,256,257];


#
# This function accepts as argument one function f, which must accept
# an integer n and do n repetitions of some test. timer will rerun it with
# larger and larger n until it takes at least 200ms and then return the
# average time per iteration in nanoseconds
#

timer := function(f)
    local t,n;
    n := 1;
    t := 0;
    while t < 200 do
        GASMAN("collect");
        t := -Runtime();
        f(n);
        t := t+Runtime();
        n := n*5;
    od;
    return Int(5000000*t/n);
end;



#
# ns2times turns a number of nanoseconds into a tidy string form
#

ns2times := function(n)
    local s;
    if n < 1000 then 
        s := ShallowCopy(String(n));
        Append(s,"ns");
    elif n < 1000000 then
        s := ShallowCopy(String(Int(n/1000)));
        if (n < 100000) then
            Append(s,".");
            Append(s,String(Int((n mod 1000)/100)));
            if ( n < 10000) then
                Append(s, String(Int((n mod 100)/10)));
            fi;
        fi;
        Append(s,"us");
    elif n < 10^9 then
        s := ShallowCopy(String(Int(n/1000000)));
        if (n < 10^8) then
            Append(s,".");
            Append(s,String(Int((n mod 10^6)/100000)));
            if ( n < 10^7) then
                Append(s, String(Int((n mod 10^5)/10000)));
            fi;
        fi;
        Append(s,"ms");
    else
        s := ShallowCopy(String(Int(n/10^9)));
        if (n < 10^11) then
            Append(s,".");
            Append(s,String(Int((n mod 10^9)/10^8)));
            if ( n < 10^10) then
                Append(s, String(Int((n mod 10^8)/10^7)));
            fi;
        fi;
        Append(s,"s");
    fi;
    IsString(s);
    return s;
end;


#
# The next three functions are very similar
# each times a different operation with matrices of various sizes over 
# the given field, stopping when one of the tests takes longer than
# <cutoff> ns
#
# It returns a list of triples: [ dimension, times, timestrings]
# the times and timestrings correspond to the output of makemats
#

TestMult1Field:= function( F, cutoff, wmats )

    local times,d,mats, t, ts;
    times := [];
    t := [0];
    d := 1;
    Print("#I ",F," \n");
    while ForAll(t, x->x<cutoff) do
        mats := makemats(d,F);
        t := List(mats{wmats}, m->timer(function(n)
            local i,x;
            for i in [1..n] do
                x:= m*m;
            od;
        end));
        ts := List(t, ns2times);
        Print("#I     ",[d,ts],"\n");
        Add(times, [d,t,ts]);
        d := 2*d;
    od;
    return times;
end;    


TestPlus1Field:= function( F, cutoff, wmats  )

    local times,d,mats, t, ts;
    times := [];
    t := [0];
    d := 1;
    Print("#I ",F," \n");
    while ForAll(t, x->x<cutoff) do
        mats := makemats(d,F);
        t := List(mats{wmats}, m->timer(function(n)
            local i,x;
            for i in [1..n] do
                x:= m+m;
            od;
        end));
        ts := List(t, ns2times);
        Print("#I     ",[d,ts],"\n");
        Add(times, [d,t,ts]);
        d := 2*d;
    od;
    return times;
end;    

TestMinus1Field:= function( F, cutoff, wmats  )

    local times,d,mats, t, ts;
    times := [];
    t := [0];
    d := 1;
    Print("#I ",F," \n");
    while ForAll(t, x->x<cutoff) do
        mats := makemats(d,F);
        t := List(mats{wmats}, m->timer(function(n)
            local i,x;
            for i in [1..n] do
                x:= m-m;
            od;
        end));
        ts := List(t, ns2times);
        Print("#I     ",[d,ts],"\n");
        Add(times, [d,t,ts]);
        d := 2*d;
    od;
    return times;
end;    


TestInv1Field:= function( F, cutoff, wmats )

    local times,d,mats, t, ts;
    times := [];
    t := [0];
    d := 1;
    Print("#I ",F," \n");
    while ForAll(t, x->x<cutoff) do
        mats := makemats(d,F);
        t := List(mats{wmats}, m->timer(function(n)
            local i,x;
            for i in [1..n] do
                x:= m^-1;
            od;
        end));
        ts := List(t, ns2times);
        Print("#I     ",[d,ts],"\n");
        Add(times, [d,t,ts]);
        d := 2*d;
    od;
    return times;
end;    






RunTestAllFields:= function(  test, fields, cutoff, wmats )

  local tt,f,t;

  tt:= [ ];
  for f in fields do
      t := test(f, cutoff, wmats);
      Add( tt, [ f, t ] );
  od;
  return tt;
end;


Test:= function( arg)
    
    local   qs, cutoff, tt, fields, wmats;    
    qs := arg[1];
    cutoff := arg[2];
    if Length(arg) > 2 then
        wmats := arg[3];
    else
        wmats := [1..nmats];
    fi;
    fields := List(qs, GF);
    tt:= [ ];
    Print("\n\n#I    MULTIPLICATION\n#I    ==============\n\n");
    tt[1]:= RunTestAllFields(TestMult1Field, fields, cutoff, wmats);
    Print("\n\n#I    ADDITION\n#I    ==============\n\n");
    tt[2]:= RunTestAllFields(TestPlus1Field, fields, cutoff, wmats);
    Print("\n\n#I    SUBTRACTION\n#I    ==============\n\n");
    tt[3]:= RunTestAllFields(TestMinus1Field, fields, cutoff, wmats);
    Print("\n\n#I    INVERSION\n#I    ==============\n\n");
    tt[4]:= RunTestAllFields(TestInv1Field, fields, cutoff, wmats);
    return tt;
end;


