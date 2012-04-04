# A small example for a network server:

LoadPackage("io");
Print("Waiting for TCP/IP connections...\n");
s := IO_socket(IO.PF_INET,IO.SOCK_STREAM,"tcp");
IO_bind(s,IO_MakeIPAddressPort("127.0.0.1",8000));
IO_listen(s,5);   # Allow a backlog of 5 connections

terminate := false;
repeat
    # We accept connections from everywhere:
    t := IO_accept(s,IO_MakeIPAddressPort("0.0.0.0",0));
    Print("Got connection...\n");
    f := IO_WrapFD(t,IO.DefaultBufSize,IO.DefaultBufSize);
    repeat
        line := IO_ReadLine(f);
        if line <> "" and line <> fail then
            Print("Got line: ",line);
            IO_Write(f,line);
            IO_Flush(f);
            if line = "QUIT\n" then
                terminate := true;
            fi;
        fi;
    until line = "" or line = fail;
    Print("Connection terminated.\n");
    IO_Close(f);
until terminate;
IO_close(s);
