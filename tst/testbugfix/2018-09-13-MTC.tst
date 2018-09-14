#MTC memory request/drop issue , Github PR#2812
# was reported in forum email
# https://mail.gap-system.org/pipermail/forum/2018/005793.html
gap> F:=FreeGroup("a","b");;
gap> rels:=ParseRelators(F,"a2,b4,(ab)11, (ab2)5,[a,bab]3,(ababaB)5");;
gap> G:=F/rels;;
gap> Size(G);
443520
