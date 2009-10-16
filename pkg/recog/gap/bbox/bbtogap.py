#!/usr/bin/env python

# Configurable variables:
indentsteps = 4

import os,sys


header = '''# Created by bbtogap.py from %s from the Atlas web page
%s := 
function(arg)
    local vars,els,G;
    if Length(arg) > 0 and IsList(arg[1]) then arg := arg[1]; fi;
    els := ShallowCopy(arg);
    vars := rec();
    G := Group(arg);
'''

footer = '''end;
'''

def num(st):
    if len(st) == 1 and st >= 'A' and st <= 'Z':
        return 'vars.'+st
    else:
        return st

def doif(ifstmt,args):
    pos = args.index('then')
    st = ifstmt+' '+num(args[0])
    if args[1] == 'eq':
        st += ' = '+num(args[2])+' then'
    elif args[1] == 'noteq':
        st += ' <> '+num(args[2])+' then'
    elif args[1] == 'in':
        # find 'then':
        li = map(int,args[2:pos])
        st += ' in '+str(li)+' then'
    elif args[1] == 'notin':
        # find 'then':
        li = map(int,args[2:pos])
        st = ifstmt+' not('+num(args[0])+' in '+str(li)+') then'
    elif args[1] == 'lt':
        st += ' < '+num(args[2])+' then'
    elif args[1] == 'leq':
        st += ' <= '+num(args[2])+' then'
    elif args[1] == 'gt':
        st += ' > '+num(args[2])+' then'
    elif args[1] == 'geq':
        st += ' >= '+num(args[2])+' then'
    return (st,pos)

def rewriteline(line):
    global curindent,newindent,labels
    if len(line) == 0 or line[0] == '#': return line
    l = line.split()
    cmd = l[0]
    args = l[1:]
    if cmd == 'oup':
        li = map(int,args[1:])
        return 'return els{'+str(li)+'};'
    elif cmd == 'mu':
        return 'els['+args[2]+'] := els['+args[0]+']*els['+args[1]+'];'
    elif cmd == 'iv':
        return 'els['+args[1]+'] := els['+args[0]+']^-1;'
    elif cmd == 'pwr':
        return 'els['+args[2]+'] := els['+args[1]+']^'+num(args[0])+';'
    elif cmd == 'cp':
        return 'els['+args[1]+'] := els['+args[0]+'];'
    elif cmd == 'cj':
        return 'els['+args[2]+'] := els['+args[0]+']^els['+args[1]+'];'
    elif cmd == 'cjr':
        return 'els['+args[0]+'] := els['+args[0]+']^els['+args[1]+'];'
    elif cmd == 'com':
        return 'els['+args[2]+'] := Comm(els['+args[0]+'],els['+args[1]+']);'
    elif cmd == 'rand':
        return 'els['+args[0]+'] := PseudoRandom(G);'
    elif cmd == 'ord':
        return 'vars.'+args[1]+' := Order(els['+args[0]+']);'
    elif cmd == 'chor':
        return 'if Order(els['+args[0]+']) <> ',args[1],' then return fail; fi;'
    elif cmd == 'incr':
        return 'vars.'+args[0]+' := vars.'+args[0]+' + 1;'
    elif cmd == 'decr':
        return 'vars.'+args[0]+' := vars.'+args[0]+' + 1;'
    elif cmd == 'set':
        return 'vars.'+args[0]+' := '+args[1]+';'
    elif cmd == 'add':
        return 'vars.'+args[2]+' := '+num(args[0])+' + '+num(args[1])+';'
    elif cmd == 'sub':
        return 'vars.'+args[2]+' := '+num(args[0])+' - '+num(args[1])+';'
    elif cmd == 'mul':
        return 'vars.'+args[2]+' := '+num(args[0])+' * '+num(args[1])+';'
    elif cmd == 'div':
        return 'vars.'+args[2]+' := QuoInt('+num(args[0])+','+num(args[1])+');'
    elif cmd == 'mod':
        return 'vars.'+args[2]+' := '+num(args[0])+' mod '+num(args[1])+';'
    elif cmd == 'if':
        st,pos = doif('if',args)
        if pos == len(args)-1: 
            newindent += indentsteps
            return st
        # there is a statement after the if:
        st2 = rewriteline(' '.join(args[pos+1:]))
        return st+'\n'+(' '*indentsteps)+st2+'\nfi;'
    elif cmd == 'elif':
        st,pos = doif('elif',args)
        curindent -= indentsteps
        return st
    elif cmd == 'else':
        curindent -= indentsteps
        return 'else'
    elif cmd == 'endif':
        curindent -= indentsteps
        newindent -= indentsteps
        return 'fi;'
    elif cmd == 'timeout':
        return 'return fail;  # a timeout'
    elif cmd == 'false':
        return 'return false;'
    elif cmd == 'true':
        return 'return true;'
    elif cmd == 'fail':
        return 'return fail;'
    elif cmd == 'lbl':
        if labels.has_key(args[0]) and labels[args[0]] == 'ALREADYJUMPEDTO':
            curindent -= indentsteps
            newindent -= indentsteps
            return 'od;    # label '+args[0]
        else:
            labels[args[0]] = curline
            newindent += indentsteps
            return 'repeat    # label '+args[0]
    elif cmd == 'jmp':
        # a very simplistic approach to jumping...
        if labels.has_key(args[0]):   # label is known, so its above
            return 'continue;    # was jmp to '+args[0]
        else:
            labels[args[0]] = 'ALREADYJUMPEDTO'
            return 'break;       # was jmp to '+args[0]
    else:
        return '>>> NOT SUPPORTED: '+line

for f in sys.argv[1:]:
    i = file(f,"r")
    o = file(f+".g","w")

    o.write(header % (f,f.replace("-",""))+"\n")

    curindent = 4
    newindent = 4
    curline = 0
    labels = {}

    while 1:
        line = i.readline()
        while line[-2:] == '&\n':
            line = line[:-2] + i.readline()
        if not(line): break
        curline += 1
        line = line.strip()
        newline = rewriteline(line)
        newlines = newline.split('\n')
        for li in newlines:
            o.write(' '*curindent + li + "\n")
        #print ' '*curindent + '# was '+line
        curindent = newindent

    o.write(footer+"\n")
    o.close()
    i.close()


