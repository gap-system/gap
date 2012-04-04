# Test HTTP protocol:

LoadPackage("io");

r := SingleHTTPRequest("www.math.rwth-aachen.de",80,"GET",
        "/~Max.Neunhoeffer/Computer/Software/Gap/io.version",
        rec(),false,false);

if r.statuscode <> 200 then
    Print("Request was not successful, please check record r!\n");
else
    expected := Concatenation(
    "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n<mixer>\n",
    PackageInfo("io")[1].Version,
    "\n</mixer>\n");

    if r.body <> expected then
        Print("Did not find expected body. ",
              "Maybe your IO package is not current?\n");
    else
        Print("OK\n");
    fi;
fi;


