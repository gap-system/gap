# A few examples for IO to and from strings:
# Click this into a GAP:
LoadPackage("io");

# Reading from a string:
s := "A long string\nMax is here!\nHello world";
f := IO_WrapFD(-1,s,false);
IO_ReadLine(f);
f;
IO_Read(f,2);
f;
IO_ReadLines(f);
f; 
IO_ReadLines(f);
IO_ReadUntilEOF(f);
IO_ReadLine(f);
IO_Close(f);

# Writing into a string:
b := "Anfang\n";
f2:= IO_WrapFD(-1,false,b);
IO_WriteLine(f2,"Max");
f2;
IO_GetWBuf(f2);
IO_Write(f2,"Hi there","\n","\c",1234,2/3,"\n");
f2;
IO_Write(f2,Elements(SymmetricGroup(3)),"\n");
l := ["a","b","c"];
IO_WriteLines(f2,l);
IO_GetWBuf(f2);
f2;
IO_Close(f2);
f2;
IO_GetWBuf(f2);

