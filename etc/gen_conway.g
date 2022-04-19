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

ConwayPolForCCodeNice := function(p,h,align)
    local list,substring,co,sub,i,lc,lpp,empty,a;
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
    # Remove trailing all-whitespace entries
    repeat
        a := Remove(substring);
        NormalizeWhitespace(a);
    until Length(a) > 0;
    Add(substring, a);
    Add(substring,",\n");
    return Concatenation(substring);
end;

MAX := 2^16;
align := 4 + LogInt(MAX, 10);

polynomials_as_strings_of_numbers := [];
p := 2;
while p^2 <= MAX do
    Print("\rProcessing p = ", p, "\c");
    max_h := LogInt(MAX, p);
    for h in [2..max_h] do
        Add(polynomials_as_strings_of_numbers,ConwayPolForCCodeNice(p,h,align));
    od;
    p := NextPrimeInt(p);
od;
Print("\n");

CleanupNewlines := function(str)
    if str[1] = '\n' then Remove(str, 1); fi;
    return str;
end;

stream := OutputTextFile("src/finfield_conway.h", false);
SetPrintFormattingStatus(stream, false);
PrintTo(stream, CleanupNewlines("""
/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  The polynomial for q = p^r will be of the form x^r + \sum{a_i x^i} and is
**  represented as \sum{a_i q^i}.
*/

#ifndef GAP_FINFIELD_CONWAY_H
#define GAP_FINFIELD_CONWAY_H

/****************************************************************************
**
*V  PolsFF  . . . . . . . . . .  list of Conway polynomials for finite fields
**
**  'PolsFF' is a  list of  Conway  polynomials for finite fields.   The even
**  entries are the  proper prime powers,  odd entries are the  corresponding
**  conway polynomials.
*/
extern const unsigned long PolsFF[]; // FIXME: should be static, but cvec uses it
const unsigned long PolsFF[] = {
"""));
for p in polynomials_as_strings_of_numbers do
  PrintTo(stream, p);
od;
PrintTo(stream, CleanupNewlines("""
};


#endif // GAP_FINFIELD_CONWAY_H
"""));

CloseStream(stream);
