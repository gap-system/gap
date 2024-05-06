# Fix issue with `rewriteToFile` option in test cases with mixed input/output
# See https://github.com/gap-system/gap/issues/5685
gap> temp_dir := DirectoryTemporary();;
gap> FileString(Filename(temp_dir, "test_in_001.tst"), \
> """gap> if true then
> > Print("true\n");
> > else
> > Print("false\n");
> > fi;
> true
> """);;
gap> Test(Filename(temp_dir, "test_in_001.tst"),
> rec(rewriteToFile := Filename(temp_dir, "test_out_001.tst")));;
gap> StringFile(Filename(temp_dir, "test_out_001.tst")) = \
> """gap> if true then
> > Print("true\n");
> > else
> > Print("false\n");
> > fi;
> true
> """;
true
gap> temp_dir := DirectoryTemporary();;
gap> FileString(Filename(temp_dir, "test_in_002.tst"), \
> """gap> if true then
> > Print("true\n");
> true
> > else
> > Print("false\n");
> > fi;
> """);;
gap> Test(Filename(temp_dir, "test_in_002.tst"),
> rec(rewriteToFile := Filename(temp_dir, "test_out_002.tst")));;
gap> StringFile(Filename(temp_dir, "test_out_002.tst")) = \
> """gap> if true then
> > Print("true\n");
> > else
> > Print("false\n");
> > fi;
> true
> """;
true
gap> FileString(Filename(temp_dir, "test_in_003.tst"), \
> """gap> if true then
> true
> > Print("true\n");
> > else
> > Print("false\n");
> > fi;
> """);;
gap> Test(Filename(temp_dir, "test_in_003.tst"),
> rec(rewriteToFile := Filename(temp_dir, "test_out_003.tst")));;
gap> StringFile(Filename(temp_dir, "test_out_003.tst")) = \
> """gap> if true then
> > Print("true\n");
> > else
> > Print("false\n");
> > fi;
> true
> """;
true
gap> FileString(Filename(temp_dir, "test_in_004.tst"), \
> """gap> if true then
> > Print("true\n");
> > else
> true
> > Print("false\n");
> > fi;
> """);;
gap> Test(Filename(temp_dir, "test_in_004.tst"),
> rec(rewriteToFile := Filename(temp_dir, "test_out_004.tst")));;
gap> StringFile(Filename(temp_dir, "test_out_004.tst")) = \
> """gap> if true then
> > Print("true\n");
> > else
> > Print("false\n");
> > fi;
> true
> """;
true
gap> FileString(Filename(temp_dir, "test_in_005.tst"), \
> """gap> if true then
> > Print("true\n");
> > else
> > Print("false\n");
> true
> > fi;
> """);;
gap> Test(Filename(temp_dir, "test_in_005.tst"),
> rec(rewriteToFile := Filename(temp_dir, "test_out_005.tst")));;
gap> StringFile(Filename(temp_dir, "test_out_005.tst")) = \
> """gap> if true then
> > Print("true\n");
> > else
> > Print("false\n");
> > fi;
> true
> """;
true
gap> FileString(Filename(temp_dir, "test_in_006.tst"), \
> """gap> if true then
> > Print("true\nfail\n");
> > else
> > Print("false\n");
> > fi;
> true
> fail
> """);;
gap> Test(Filename(temp_dir, "test_in_006.tst"),
> rec(rewriteToFile := Filename(temp_dir, "test_out_006.tst")));;
gap> StringFile(Filename(temp_dir, "test_out_006.tst")) = \
> """gap> if true then
> > Print("true\nfail\n");
> > else
> > Print("false\n");
> > fi;
> true
> fail
> """;
true
gap> FileString(Filename(temp_dir, "test_in_007.tst"), \
> """gap> if true then
> > Print("true\nfail\n");
> true
> > else
> > Print("false\n");
> > fi;
> fail
> """);;
gap> Test(Filename(temp_dir, "test_in_007.tst"),
> rec(rewriteToFile := Filename(temp_dir, "test_out_007.tst")));;
gap> StringFile(Filename(temp_dir, "test_out_007.tst")) = \
> """gap> if true then
> > Print("true\nfail\n");
> > else
> > Print("false\n");
> > fi;
> true
> fail
> """;
true
gap> FileString(Filename(temp_dir, "test_in_008.tst"), \
> """gap> if true then
> > Print("true\nfail\n");
> true
> > else
> > Print("false\n");
> fail
> > fi;
> """);;
gap> Test(Filename(temp_dir, "test_in_008.tst"),
> rec(rewriteToFile := Filename(temp_dir, "test_out_008.tst")));;
gap> StringFile(Filename(temp_dir, "test_out_008.tst")) = \
> """gap> if true then
> > Print("true\nfail\n");
> > else
> > Print("false\n");
> > fi;
> true
> fail
> """;
true
gap> FileString(Filename(temp_dir, "test_in_009.tst"), \
> """gap> if true then
> > Print("true\nfail\n");
> true
> fail
> > else
> > Print("false\n");
> > fi;
> """);;
gap> Test(Filename(temp_dir, "test_in_009.tst"),
> rec(rewriteToFile := Filename(temp_dir, "test_out_009.tst")));;
gap> StringFile(Filename(temp_dir, "test_out_009.tst")) = \
> """gap> if true then
> > Print("true\nfail\n");
> > else
> > Print("false\n");
> > fi;
> true
> fail
> """;
true
gap> FileString(Filename(temp_dir, "test_in_010.tst"), \
> """gap> if true then
> true
> > Print("true\nfail\n");
> fail
> > else
> > Print("false\n");
> > fi;
> """);;
gap> Test(Filename(temp_dir, "test_in_010.tst"),
> rec(rewriteToFile := Filename(temp_dir, "test_out_010.tst")));;
gap> StringFile(Filename(temp_dir, "test_out_010.tst")) = \
> """gap> if true then
> > Print("true\nfail\n");
> > else
> > Print("false\n");
> > fi;
> true
> fail
> """;
true
gap> FileString(Filename(temp_dir, "test_in_011.tst"), \
> """gap> if true then
> true
> fail
> 
> > Print("true\nfail\n\n");
> > else
> > Print("false\n");
> > fi;
> """);;
gap> Test(Filename(temp_dir, "test_in_011.tst"),
> rec(rewriteToFile := Filename(temp_dir, "test_out_011.tst")));;
gap> StringFile(Filename(temp_dir, "test_out_011.tst")) = \
> """gap> if true then
> > Print("true\nfail\n\n");
> > else
> > Print("false\n");
> > fi;
> true
> fail
> 
> """;
true
gap> FileString(Filename(temp_dir, "test_in_012.tst"), \
> """gap> if true then
> true
> fail
> 
> > Print("true\nfail\n\n");
> > else
> > Print("false\n");
> > fi;
> gap> Print("Hello\nWorld\n");
> Hello
> World
> """);;
gap> Test(Filename(temp_dir, "test_in_012.tst"),
> rec(rewriteToFile := Filename(temp_dir, "test_out_012.tst")));;
gap> StringFile(Filename(temp_dir, "test_out_012.tst")) = \
> """gap> if true then
> > Print("true\nfail\n\n");
> > else
> > Print("false\n");
> > fi;
> true
> fail
> 
> gap> Print("Hello\nWorld\n");
> Hello
> World
> """;
true
gap> FileString(Filename(temp_dir, "test_in_013.tst"), \
> """gap> if true then
> true
> fail
> 
> > Print("true\nfail\n\n");
> > else
> > Print("false\n");
> > fi;
> 
> # New test case
> gap> Print("Hello\nWorld\n");
> Hello
> World
> """);;
gap> Test(Filename(temp_dir, "test_in_013.tst"),
> rec(rewriteToFile := Filename(temp_dir, "test_out_013.tst")));;
gap> StringFile(Filename(temp_dir, "test_out_013.tst")) = \
> """gap> if true then
> > Print("true\nfail\n\n");
> > else
> > Print("false\n");
> > fi;
> true
> fail
> 
> 
> # New test case
> gap> Print("Hello\nWorld\n");
> Hello
> World
> """;
true
gap> FileString(Filename(temp_dir, "test_in_014.tst"), \
> """gap> if true then
> true
> fail
> 
> > Print("true\nfail\n\n");
> > else
> > Print("false\n");
> > fi;
> 
> # New test case
> gap> if true then
> true
> fail
> 
> > Print("true\nfail\n\n");
> > else
> > Print("false\n");
> > fi;
> """);;
gap> Test(Filename(temp_dir, "test_in_014.tst"),
> rec(rewriteToFile := Filename(temp_dir, "test_out_014.tst")));;
gap> StringFile(Filename(temp_dir, "test_out_014.tst")) = \
> """gap> if true then
> > Print("true\nfail\n\n");
> > else
> > Print("false\n");
> > fi;
> true
> fail
> 
> 
> # New test case
> gap> if true then
> > Print("true\nfail\n\n");
> > else
> > Print("false\n");
> > fi;
> true
> fail
> 
> """;
true
