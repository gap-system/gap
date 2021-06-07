old := PrintFormattingStatus("*stdout*");
SetPrintFormattingStatus("*stdout*", false);
PrintFormattingStatus("*stdout*");
Display(x -> x);
SetPrintFormattingStatus("*stdout*", true);
PrintFormattingStatus("*stdout*");
Display(x -> x);
SetPrintFormattingStatus("*stdout*", old);;
PrintFormattingStatus("*stdout*");
