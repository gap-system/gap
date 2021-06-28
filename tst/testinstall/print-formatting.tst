#
gap> CALL_WITH_FORMATTING_STATUS(fail, fail, fail);
Error, CALL_WITH_FORMATTING_STATUS: <status> must be 'true' or 'false' (not th\
e value 'fail')
gap> CALL_WITH_FORMATTING_STATUS(false, fail, fail);
Error, CALL_WITH_FORMATTING_STATUS: <args> must be a small list (not the value\
 'fail')
gap> CALL_WITH_FORMATTING_STATUS(false, Display, [x -> x]);
function ( x )
return x;
end

# for comparison
gap> Display(x -> x);
function ( x )
    return x;
end

#
gap> str := JoinStringsWithSeparator(ListWithIdenticalEntries(20, "abcd 1234"), " ");
"abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 12\
34 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd \
1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234"
gap> PrintWithoutFormatting(str, "\n");
abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234
gap> Print(str, "\n");
abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 123\
4 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1234 abcd 1\
234 abcd 1234 abcd 1234 abcd 1234 abcd 1234
