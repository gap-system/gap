#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This files's authors include Jan De Beule, Max Horn.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains code to regenerate the PolsFF table in
##  src/finfield_conway.h.
##

ConwayPolNumber := function(p,h)
    local list, number;
    list := ConwayPol(p,h);
    return Sum([1..Length(list)-1],i->list[i]*p^(i-1));
end;

ConwayPolForCCodeFlat := function(p,h)
    local number;
    number := ConwayPolNumber(p,h);
    return Concatenation(String(p^h),", ",String(number),",\n");
end;

ConwayPolForCCodeNice := function(p,h,align)
    local list,substring,co,sub,i,lc,lpp,empty,idx,a,stop;
    empty := Concatenation(List([1..40],x->" "));
    list := ConwayPol(p,h);
    substring := [String(p^h, align)];
    Add(substring,", ");
    for i in [1..Length(list)-1] do
        co := Int(list[i]);
        if co = 0 then
            lpp := Length(String(p^(i-1)));
            if p = 2 then
                sub := empty{[1..1+lpp]};
            else
                sub := empty{[1..3+lpp]};
            fi;
        else
            if i = 1 then
                sub := Concatenation(String(co, 2)," ");
            elif p = 2 then
                sub := Concatenation("+",String(p^(i-1)));
            else
                sub := Concatenation("+",String(co),"*",String(p^(i-1)));
            fi;
        fi;
        Add(substring,sub);
    od;
    idx := Length(substring);
    stop := false;
    while not stop do
        a := substring[idx];
        NormalizeWhitespace(a);
        if a = "" then
            Unbind(substring[idx]);
            idx := idx - 1;
        else
            stop := true;
        fi;
    od;
    Add(substring,",\n");
    return Concatenation(substring);
end;

#MAX := 2^16;
MAX := 2^32;
align := 4 + LogInt(MAX, 10)+1;

polynomials_as_strings_of_numbers := [];
polynomials_as_strings_of_flat_numbers := [];
p := 2;
while p^2 <= MAX do
    Print("\rProcessing p = ", p, "\c");
    max_h := LogInt(MAX, p);
    for h in [2..max_h] do
        Add(polynomials_as_strings_of_numbers,ConwayPolForCCodeNice(p,h,align));
        Add(polynomials_as_strings_of_flat_numbers,ConwayPolForCCodeFlat(p,h));
        h := h+1;
    od;
    p := NextPrimeInt(p);
od;
Print("\n");

# TODO: actually regenerate src/finfield_conway.h

stream := OutputTextFile("output", false);
SetPrintFormattingStatus(stream, false);
for p in polynomials_as_strings_of_numbers do
  PrintTo(stream, p);
od;
CloseStream(stream);

# stream := OutputTextFile("output2", false);
# SetPrintFormattingStatus(stream, false);
# for p in polynomials_as_strings_of_flat_numbers do
#   PrintTo(stream, p);
# od;
# CloseStream(stream);
