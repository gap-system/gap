# 2006/01/11 (MC)
gap> d := DirectoryCurrent();;
gap> f := Filename(DirectoriesSystemPrograms(), "rev");;
gap> if f <> fail then
>      s := InputOutputLocalProcess(d,f,[]);;
>      if PrintFormattingStatus(s) <> false then
>        Print( "unexpected PrintFormattingStatus value\n" );
>      fi;
>      SetPrintFormattingStatus(s,false);
>      AppendTo(s,"The cat sat on the mat\n");
>      if ReadLine(s) <> "tam eht no tas tac ehT\n" then
>        Print( "There is a problem concerning a cat on a mat.\n" );
>      fi;
>      CloseStream(s);
>    fi;
