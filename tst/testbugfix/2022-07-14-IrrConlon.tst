gap> G := Group([ (5,9)(10,14)(11,12)(15,16), (2,3)(4,7)(5,10)(9,14)(11,12)(15,16), (2,4)(3,5)(6,12)(7,9)(10,14)(11,13), (1,2)(3,6)(4,8)(5,11)(7,13)(9,12)(10,15)(14,16) ]);;
gap> Order(G);
1024
gap> c := Set(IrrConlon(G));;
gap> bc := Set(IrrBaumClausen(G));;
gap> ds := Set(IrrDixonSchneider(G));;
gap> bc =ds;
true
gap> c = bc;
true
