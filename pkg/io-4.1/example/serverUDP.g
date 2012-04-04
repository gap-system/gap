# A small server example using UDP:
LoadPackage("io");
Print("Waiting for UDP packets...\n");
s := IO_socket(IO.PF_INET,IO.SOCK_DGRAM,"udp");
IO_bind(s,IO_MakeIPAddressPort("127.0.0.1",8000));
repeat
    b := "";
    l := IO_recv(s,b,0,80,0);
    Print("Received ",l," bytes: ",b{[1..l]},"\n");
until b{[1..l]} = "QUIT";
IO_close(s);
