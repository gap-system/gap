# A little network client using TCP/IP:

LoadPackage("io");
Print("Connecting via TCP/IP...\n");
s := IO_socket(IO.PF_INET,IO.SOCK_STREAM,"tcp");
res := IO_connect(s,IO_MakeIPAddressPort("127.0.0.1",8000));
if res = fail then
    Print("Error: ",LastSystemError(),"\n");
    IO_close(s);
else
    f := IO_WrapFD(s,IO.DefaultBufSize,IO.DefaultBufSize);
    IO_WriteLine(f,"Hello world!\n");
    Print("Sent: Hello word!\n");
    st := IO_ReadLine(f);
    Print("Got back: ",st);
    IO_Close(f);
fi;
s := IO_socket(IO.PF_INET,IO.SOCK_STREAM,"tcp");
res := IO_connect(s,IO_MakeIPAddressPort("127.0.0.1",8000));
if res = fail then
    Print("Error: ",LastSystemError(),"\n");
    IO_close(s);
else
    f := IO_WrapFD(s,IO.DefaultBufSize,IO.DefaultBufSize);
    IO_WriteLine(f,"QUIT\n");
    Print("Sent: QUIT\n");
    st := IO_ReadLine(f);
    Print("Got back: ",st);
    IO_Close(f);
fi;
