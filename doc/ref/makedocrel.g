##  this creates the documentation, needs: GAPDoc package, latex, pdflatex,
##  mkindex, dvips
##

# TODO make this a function and pass parameters path, .. manually.

# TODO overwrite makedocrel in other directories, only difference is this
# parameter.
# Is this called makedocrel because it is "relative"? In the sense of copy this
# into the directory of the manual you want to compile?

# this file can be called from the same directory or via make from the root
# directory. We need to handle the path variable in both cases.
if not IsBound(path) and not IsBound(dir) then
    path := ".";
    dir := Directory(path);
# TODO this can go once this script is turned into a function
elif not IsBound(path) or not IsBound(dir) then
    ErrorNoReturn("only one of <path> and <dir> is bound");
fi;
f := Filename(dir, "makedocreldata.g");
Read(f);
# TODO this is new: use it to control the output
if not IsBound(createPDF) then
    createPDF := true;
fi;
if not IsBound(createBlackAndWhite) then
    createBlackAndWhite := true;
fi;

latexOptions := rec(Maintitlesize := "\\fontsize{36}{38}\\selectfont");
makeGAPDocArgs := [path, "main.xml", files, bookname, "../..", "MathJax"];
if not createPDF then
    Add(makeGAPDocArgs, "nopdf");
fi;

if createPDF and createBlackAndWhite then
    SetGapDocLaTeXOptions("nocolor", latexOptions);
    CallFuncList(MakeGAPDocDoc, makeGAPDocArgs);

    f1 := Filename(dir, "manual.pdf");
    f2 := Filename(dir, "manual-bw.pdf");
    Exec(Concatenation("mv -f ", f1, " ", f2));
fi;

SetGapDocLaTeXOptions("color", latexOptions);
CallFuncList(MakeGAPDocDoc, makeGAPDocArgs);

# TODO: add a variable which turns off the next two commands. Apparently when
# doing `make doc` we only need to run these commands once.
# This was previously done by calling these only for `run = 2` from
# `doc/make_doc`.
GAPDocManualLabFromSixFile("ref", Concatenation(path, "/manual.six"));;
CopyHTMLStyleFiles(path);
