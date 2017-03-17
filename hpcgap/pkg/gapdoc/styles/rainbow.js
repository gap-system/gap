
function randchar(str) {
  var i = Math.floor(Math.random() * str.length);
  while (i == str.length)
    i = Math.floor(Math.random() * str.length);
  return str[i]; 
}

hexdigits = "0123456789abcdef";

function randlight() {
  return    randchar("cdef")+randchar(hexdigits)+
            randchar("cdef")+randchar(hexdigits)+
            randchar("cdef")+randchar(hexdigits)
}
function randdark() {
  return    randchar("012345789")+randchar(hexdigits)+
            randchar("012345789")+randchar(hexdigits)+
            randchar("102345789")+randchar(hexdigits)
}

document.write('<style type="text/css">\n<!--\n');
document.write('body {\n  color: #'+randdark()+';\n  background: #'+
               randlight()+';\n}\n');
document.write('a:link {\n  color: #'+randdark()+';\n}\n');
document.write('a:visited {\n  color: #'+randdark()+';\n}\n');
document.write('a:active {\n  color: #'+randdark()+';\n}\n');
document.write('a:hover {\n  background-color: #'+randlight()+';\n}\n');
document.write('pre {\n  color: #'+randdark()+';\n}\n');
document.write('tt {\n  color: #'+randdark()+';\n}\n');
document.write('code {\n  color: #'+randdark()+';\n}\n');
document.write('var {\n  color: #'+randdark()+';\n}\n');
document.write('div.func {\n  background-color: #'+randlight()+';\n}\n');
document.write('div.example {\n  background-color: #'+randlight()+';\n}\n');
document.write('div.chlinktop {\n  background-color: #'+randlight()+';\n}\n');
document.write('div.chlinkbot {\n  background-color: #'+randlight()+';\n}\n');
document.write('pre.normal {\n  color: #'+randdark()+';\n}\n');
document.write('code.func {\n  color: #'+randdark()+';\n}\n');
document.write('code.keyw {\n  color: #'+randdark()+';\n}\n');
document.write('code.file {\n  color: #'+randdark()+';\n}\n');
document.write('code.code {\n  color: #'+randdark()+';\n}\n');
document.write('code.i {\n  color: #'+randdark()+';\n}\n');
document.write('strong.button {\n  color: #'+randdark()+';\n}\n');
document.write('span.Heading {\n  color: #'+randdark()+';\n}\n');
document.write('var.Arg {\n  color: #'+randdark()+';\n}\n');
document.write('strong.pkg {\n  color: #'+randdark()+';\n}\n');
document.write('strong.Mark {\n  color: #'+randdark()+';\n}\n');
document.write('b.Ref {\n  color: #'+randdark()+';\n}\n');
document.write('span.Ref {\n  color: #'+randdark()+';\n}\n');
document.write('span.GAPprompt {\n  color: #'+randdark()+';\n}\n');
document.write('span.GAPbrkprompt {\n  color: #'+randdark()+';\n}\n');
document.write('span.GAPinput {\n  color: #'+randdark()+';\n}\n');
document.write('b.Bib_author {\n  color: #'+randdark()+';\n}\n');
document.write('span.Bib_key {\n  color: #'+randdark()+';\n}\n');
document.write('i.Bib_title {\n  color: #'+randdark()+';\n}\n');

document.write('-->\n</style>\n');



