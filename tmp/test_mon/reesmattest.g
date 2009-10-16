#############################
g := Group((1,2,3));
elg := Elements(g);
smat := [[elg[1], elg[2]],[elg[3],elg[2]]];
rms := ReesMatrixSemigroup(g, smat); 
IsSimpleSemigroup(rms);
i := InjectionZeroMagma(g);
gz := Range(i);
IsZeroGroup(gz);
gzel := Elements(gz); 
tmat := [[gzel[1],gzel[2]],[gzel[3],gzel[4]]] ; 
rmt := ReesMatrixSemigroup(gz, tmat);
IsZeroSimpleSemigroup(rmt);
elt := ReesMatrixSemigroupElement(rmt, gzel[2],1,1);;
elt;

elt^2 = MultiplicativeZero(rmt); 

Set([elt,elt^2]);
elt1 := ReesMatrixSemigroupElement(rmt, gzel[2],2,1);;
elt*elt1;
gzel[2];
elt3 := ReesMatrixSemigroupElement(rmt, gzel[3],2,1);;
elt3*elt;
elt*elt3;


m := Semigroup([elt,elt1,elt3]);
Elements(m);

#still need to implement Elements for the whole family


##########################################################
#
#  Tests for testing if semigroups are simple and 0-simple
#	 and build the Rees Matrix Semigroup
#
#########################################################
f:=FreeSemigroup("a");;        
a:=GeneratorsOfSemigroup(f)[1];;
g:=f/[[a^6,a]];;
Elements(g);						 # [ a, a^2, a^3, a^4, a^5 ]
# the Applicable method for the following is 
# ``IsSimpleSemigroup: for semigroup with generators''
IsSimpleSemigroup(g);		 # true
# now we adjoin a zero to the semigroup and obtain a semigroup h
phi:=InjectionZeroMagma(g);;
h:=Range(phi);;
# the Applicable method for the following is
#``IsZeroSimpleSemigroup: for a semigroup with generators, which has a multi\
#plicative zero'', value: 17
IsZeroSimpleSemigroup(h); 				# true

f:=FreeSemigroup("a");;
a:=GeneratorsOfSemigroup(f)[1];;
g:=f/[[a^6,a^3]];;
Elements(g); 						 			# [ a, a^2, a^3, a^4, a^5 ]
# the Applicable method for the following is 
# ``IsSimpleSemigroup: for semigroup with generators''
IsSimpleSemigroup(g);		# false
a:=GeneratorsOfSemigroup(g)[1];;
s:=Semigroup([a^3,a^4,a^5]);;
Elements(s);									# [ a^3, a^4, a^8 ]
# the Applicable method for the following is 
# ``IsSimpleSemigroup: for semigroup with generators''
IsSimpleSemigroup(s);					# true
# adjoin a zero to the semigroup s and obtain a semigroup h
phi:=InjectionZeroMagma(g);;
h:=Range(phi);;
# the Applicable method for the following is
# ``IsSimpleSemigroup: for semigroup with generators''
IsZeroSimpleSemigroup(h);            	# false 
phi:=InjectionZeroMagma(s);;
t:=Range(phi);;
# the Applicable method for the following is
# ``IsSimpleSemigroup: for semigroup with generators''
IsZeroSimpleSemigroup(t);             # true 

# the following is a group, so it has to be simple
f:=FreeMonoid("a","b");;
x:=GeneratorsOfMonoid(f);;a:=x[1];;b:=x[2];;
e:=Identity(f);;
g:=f/[[a^2,e],[b^2,e],[a*b,b*a]];;
Elements(g);							# [ <identity ...>, a, b, a*b ]
e:=GeneratorsOfSemigroup(g)[1];; # e is the identity of g
SetMultiplicativeNeutralElement(g,e);
# (this should not be done thsi way... but this is just until 
#	the method for MultiplicativeNeutralElement is implemented)
# the Applicable method for the following is 
# ``IsSimpleSemigroup: for a semigroup with a MultiplicativeNeutralElement'' 
IsSimpleSemigroup(g);			# true
# adjoin a zero to g
phi:=InjectionZeroMagma(g);;
h:=Range(phi);;
IsZeroSimpleSemigroup(h);	# true

# next test the method for a general semigroup



###

f := FreeSemigroup("a");;
a := GeneratorsOfSemigroup( f )[1];;
s := f/[ [a^3,a]];;
el := Elements(s);
IsSimpleSemigroup( s );
d := EquivalenceClassOfElement( GreensDRelation( s ), el[2] );
groupHclass := GroupHClassOfGreensDClass( d );
phi := IsomorphismPermGroup( groupHclass );
time; # 140


