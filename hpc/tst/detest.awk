{if (substr($0,1,2)=="> ") {
 print substr($0,3);
}
else {if (substr($0,1,5)=="gap> ") {
 print substr($0,6);
}}}
