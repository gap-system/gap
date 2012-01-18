/* toggless.js                                      Frank Lübeck   */

/* this file contains two functions:
   mergeSideTOCHooks:  this changes div.ContSect elements to the class
                       ContSectClosed and includes a hook to toggle between
                       ContSectClosed and ContSectOpen. 
   openclosetoc:       this function does the toggling, the rest is done by
                       CSS
*/



closedTOCMarker = "▶ ";
openTOCMarker = "▼ ";
noTOCMarker = "  ";
/* merge hooks into side toc for opening/closing subsections
   with openclosetoc   */
function mergeSideTOCHooks() {
  var hlist = document.getElementsByTagName("div");
  for (var i = 0; i < hlist.length; i++) {
     if (hlist[i].className == "ContSect") {
       var chlds = hlist[i].childNodes;
       var el = document.createElement("span");
       var oncl = document.createAttribute("class");
       oncl.nodeValue = "toctoggle";
       el.setAttributeNode(oncl);
       var cont;
       if (chlds.length > 2) {
         var oncl = document.createAttribute("onclick");
         oncl.nodeValue = "openclosetoc(event)";
         el.setAttributeNode(oncl);
         cont = document.createTextNode(closedTOCMarker);
       } else {
         cont = document.createTextNode(noTOCMarker);
       }
       el.appendChild(cont);
       hlist[i].firstChild.insertBefore(el, hlist[i].firstChild.firstChild);
       hlist[i].className = "ContSectClosed";
     }
  }
}

function openclosetoc (event) {
  /* first two steps to make it work in most browsers */
  var evt=window.event || event;
  if (!evt.target) 
    evt.target=evt.srcElement;

  var markClosed = document.createTextNode(closedTOCMarker);
  var markOpen = document.createTextNode(openTOCMarker);

  var par = evt.target.parentNode.parentNode;
  if (par.className == "ContSectOpen") {
    par.className = "ContSectClosed";
    evt.target.replaceChild(markClosed, evt.target.firstChild);
  }
  else if (par.className == "ContSectClosed") {
    par.className = "ContSectOpen";
    evt.target.replaceChild(markOpen, evt.target.firstChild);
  }
}

/* adjust jscontent which is called onload */
jscontentfuncs.push(mergeSideTOCHooks);

