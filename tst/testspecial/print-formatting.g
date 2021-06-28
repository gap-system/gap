# test formatting status for stdout
old := PrintFormattingStatus("*stdout*");
SetPrintFormattingStatus("*stdout*", false);
PrintFormattingStatus("*stdout*");
Display(x -> x);
SetPrintFormattingStatus("*stdout*", true);
PrintFormattingStatus("*stdout*");
Display(x -> x);
SetPrintFormattingStatus("*stdout*", old);;
PrintFormattingStatus("*stdout*");

# test formatting status for errout
1/0; # trigger a break loop
old := PrintFormattingStatus("*errout*");
SetPrintFormattingStatus("*errout*", false);
PrintFormattingStatus("*errout*");
Display(x -> x);
SetPrintFormattingStatus("*errout*", true);
PrintFormattingStatus("*errout*");
Display(x -> x);
SetPrintFormattingStatus("*errout*", old);;
PrintFormattingStatus("*errout*");
