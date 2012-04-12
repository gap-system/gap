function toggle(theEvent){
    theEvent = theEvent || window.event;
    var target = theEvent.target || theEvent.srcElement;
    target = target.parentNode.parentNode;
    if (target.getAttribute('class') == 'ContSect') {
        target.setAttribute ('class', 'ContSectSubsectOn'); 
    } else if (target.getAttribute('class') == 'ContSectSubsectOn') {
        target.setAttribute ('class', 'ContSect'); 
    } else if (target.getAttribute('class') == 'ContChap') {
        target.setAttribute ('class', 'ContChapSectOff'); 
    } else if (target.getAttribute('class') == 'ContChapSectOff') {
        target.setAttribute ('class', 'ContChap');
    }
    return true;
}
