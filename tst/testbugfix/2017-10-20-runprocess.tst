# This is based on an older fragile test - 2006/01/11 (MC)
# We want to check two cases:
# Firstly we ensure we read a whole line, by using a while loop
gap> d := DirectoryCurrent();;
gap> f := Filename(DirectoriesSystemPrograms(), "cat");;
gap> func1 := function()
>    local line,s;
>    if f <> fail then
>      s := InputOutputLocalProcess(d,f,[]);;
>      if PrintFormattingStatus(s) <> false then
>        Print( "unexpected PrintFormattingStatus value\n" );
>      fi;
>      SetPrintFormattingStatus(s,false);
>      AppendTo(s,"The cat sat on the mat\n");
>      line := ReadLine(s);
>      while line[Length(line)] <> '\n' do
>        line := Concatenation(line, ReadLine(s));
>      od;
>      if line <> "The cat sat on the mat\n" then
>        Print( "There is a problem concerning a cat on a mat.\n" );
>      fi;
>      CloseStream(s);
>    fi;
>  end;;
gap>  for i in [1..1000] do func1(); od;

# Here we might only get part of the line, or fail
# This is mainly to check we kill the process when it still has output
gap> func2 := function()
>    local line,s;
>    if f <> fail then
>      s := InputOutputLocalProcess(d,f,[]);;
>      if PrintFormattingStatus(s) <> false then
>        Print( "unexpected PrintFormattingStatus value\n" );
>      fi;
>      SetPrintFormattingStatus(s,false);
>      AppendTo(s,"The cat sat on the mat\n");
>      AppendTo(s,"The cat sat on the mat\n");
>      line := ReadLine(s);
>      if line <> fail and not StartsWith("The cat sat on the mat\n", line) then
>        Print( "There is a problem concerning a cat on a mat.\n" );
>      fi;
>      CloseStream(s);
>    fi;
>  end;;
gap>  for i in [1..1000] do func2(); od;
