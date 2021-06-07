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

# test formatting status for current output
old := PrintFormattingStatus("*current*");
SetPrintFormattingStatus("*current*", false);
PrintFormattingStatus("*current*");
Display(x -> x);
SetPrintFormattingStatus("*current*", true);
PrintFormattingStatus("*current*");
Display(x -> x);
SetPrintFormattingStatus("*current*", old);;
PrintFormattingStatus("*current*");

