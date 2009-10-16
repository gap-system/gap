#############################################################################
##
#W  posets.g                  														Andrew Solomon
##
#H  @(#)$Id: posets.g,v 1.1 2000/01/11 15:28:42 gap Exp $
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##
##
Revision.posets_g :=
    "@(#)$Id: posets.g,v 1.1 2000/01/11 15:28:42 gap Exp $";

###########################################################################
##
#F  PosetRelations(<p>, <le>)
##
##  <le> is a partial order function - <le>(x, y) iff x <= y
##  <p> is the a list of elements on which <le> is defined.
## We attempt to figure out the poset of the order without
## comparing every two elements (as this is expensive).
## We know that every pair of elements is in one of the two
## relations : 
## related  - reflexive and transitive; or
## unrelated - symmetric
##
## We keep comparing pairs until every pair appears in one of the
## relations.
PosetRelations := 
function(p, le)
	local i,j, related, unrelated, ims, imlist,tmp;

	related := BinaryRelationByListOfImages(List([1 .. Length(p)], x->[x]));
	unrelated := BinaryRelationByListOfImages(List([1 .. Length(p)], x->[]));
	for i in [1 .. Length(p)]  do
		for j in [1 .. Length(p)] do
			if not ([i,j] in related or [j,i] in related or [i,j] in unrelated) then
				if le(p[i],p[j]) then
					# add (i,j) to related and form transitive closure
					ims := Concatenation(Images(related, i), [j]);
					imlist := Concatenation(List([1 .. i-1], x->Images(related, x)),
						[ims], List([i+1 .. Length(p)], x->Images(related, x)));
					related := TransitiveClosureBinaryRelation(
						BinaryRelationByListOfImages(imlist));
					tmp := ImagesListOfBinaryRelation(related);
				else if le(p[j],p[i]) then
					# add (j,i) to related and form transitive closure
					ims := Concatenation(Images(related, j), [i]);
					imlist := Concatenation(List([1 .. j-1], x->Images(related, x)),
						[ims], List([j+1 .. Length(p)], x->Images(related, x)));
					related := TransitiveClosureBinaryRelation(
						BinaryRelationByListOfImages(imlist));
					tmp := ImagesListOfBinaryRelation(related);
				else
					# add (i,j) to unrelated and form symmetric closure
					ims := Concatenation(Images(unrelated, i), [j]);
					imlist := Concatenation(List([1 .. i-1], x->Images(unrelated, x)),
						[ims], List([i+1 .. Length(p)], x->Images(unrelated, x)));
					unrelated := SymmetricClosureBinaryRelation(
						BinaryRelationByListOfImages(imlist));
					tmp := ImagesListOfBinaryRelation(unrelated);
				fi; fi;
			fi;
		od;
	od;

	return [related, unrelated];
end;

###########################################################################
##
#F  PosetLinearOrder(<related>)
##
##  <related> is the relation  which describes a partial order
##  on a set. i <= j in Source(<related>) iff [i,j] in <related>.
##
##  We return a list <l>  whose elements are the source of <related>
##  and ordered such that i < j => i occurs before j in the list.
##  
PosetLinearOrder := function(related)
	local
		p, i, stack, schedule, degrees, elt, aboves;

	p := AsSSortedList(Source(related));
	stack := []; schedule := [];


	# aboves[i] - the indices of things above (or equal to) element p[i] 
	# in the poset
	aboves := List([1 .. Length(p)], x -> Filtered([1 .. Length(p)],
    y -> [x, y] in related));

	# degrees[i] is the number of things in p less than (or equal to) p[i]
	# which have not been put onto the schedule.
	degrees := List([1 .. Length(p)], 
		x -> Length(Filtered([1 .. Length(p)], y -> x in aboves[y])));

	# this loop adds the minimal elements to the stack
	for i in [1 .. Length(p)] do
		if degrees[i] = 1 then # it is a minimal element
			Append(stack, [i]);
		fi;
	od;

	while not IsEmpty(stack) do
		# pop an element from the stack
		elt := stack[Length(stack)];
		stack := stack{[1 .. Length(stack)-1]};

		# add the element to the linear order
		Append(schedule, [p[elt]]);

		# decrease the degree of each element of p which
		# is more than elt.
		for i in aboves[elt] do
			degrees[i] := degrees[i]  - 1;

			# and push onto the stack if now minimal
			if degrees[i] = 1 then
				Append(stack, [i]);
			fi;
		od;
	od;

	# reorder p
	return schedule;
end;


###########################################################################
##
#F  PosetRelationCovers(<related>)
##
##  <related> is a relation describing a partial order -
##  (x, y) in <related> iff  x <= y
##
##  <p> is a list of the elements of the source of <related>
##
##  returns <covers>  -  <covers>[i] is the set of things covering 
##  p<i> in <related>
##
##
PosetRelationCovers := 
function(related)
	local
			i, j, covers, l;

	l := PosetLinearOrder(related);

	covers := List([1 .. Length(l)], x->[]);
	for i in [1 .. Length(l)] do
		for j in [i+1 .. Length(l)] do
			# if l[j] >= l[i]
			if [l[i], l[j]] in related then
				# if there's nothing smaller than l[j]
				if First(covers[l[i]], x->[x, l[j]] in related) = fail then
					# delete the things bigger than l[j]
					covers[l[i]] := Filtered(covers[l[i]], x->not [l[j],x] in related);

					# ... and add it in!
					Append(covers[l[i]], [l[j]]);
				fi;
			fi;	
		od;
	od;

	return covers;
end;

###########################################################################
##
#F  PosetRelationUnderCovers(<related>)
##
##  <related> is a relation describing a partial order -
##  (x, y) in <related> iff  x <= y
##
##  <p> is a list of the elements of the source of <related>
##
##  returns <undercovers>  -  <undercovers>[i] is the set of things 
##  covered by p<i> in <related>
##
##
PosetRelationUnderCovers := 
function(related)
	local
			i, j, covers, l;


	covers := PosetRelationCovers(related);
	
	return List([1 .. Length(covers)], 
		x->Filtered([1 .. Length(covers)], y->x in covers[y]));

end;


##########################################################
###### OLD VERSIONS NOT USING related and unrelated
############################################################


###########################################################################
##
#F  TopologicalSort(<p>, <le>)
##
##  <le> is a partial order function - <le>(x, y) iff x <= y
##  <p> is the a list of elements on which <le> is defined.
##
##  <p> is reordered so that le(p[i], p[j]) implies i < j.
##
##  Algorithm from:
##
##  http://cheat.xcf.berkeley.edu/archive/cs170/9709/0018.html
##
##  Troy Shahoumian (troys@legato.CS.Berkeley.EDU)
##  4 Sep 1997 03:39:36 GMT 
##  
##  Here is how you implement topological sort in O(V+E) time.
##  
##  We are given a directed graph where the nodes are tasks and an edge
##  from u to v represents the fact that task u must be done before task
##  v. The goal of topological sort is to order the tasks so that no
##  precedence constraints are violated. If there is a directed cycle, no
##  such ordering is possible. In graphs with no directed cycles, there
##  must be a sink--node of degree 0.
##  
##  1. Create an array indexed by the nodes giving the indegree of each
##  node. O(V+E) time.
##  
##  2. Push every sink onto a stack. O(V) time.
##  
##  3. Pop the stack, add the task just popped to the end of the schedule of
##  tasks. Delete this task and all outgoing edges from the graph,
##  updating the in-degree array. Push all newly-created sinks onto the
##  stack. This all takes constant time per node and edge. O(V+E) time.
##  
##  If we ever have no sinks in the graph and tasks remaining to be
##  scheduled, the graph has a directed cycle.
##
TopologicalSort := function(p, le)
	local
		i, stack, schedule, degrees, elt, aboves;

	stack := []; schedule := [];


	# aboves[i] - the indices of things above (or equal to) element p[i] 
	# in the poset
	aboves := List([1 .. Length(p)], x -> Filtered([1 .. Length(p)],
    y -> le(p[x], p[y])));

	# degrees[i] is the number of things in p less than (or equal to) p[i]
	# which have not been put onto the schedule.
	degrees := List([1 .. Length(p)], 
		x -> Length(Filtered([1 .. Length(p)], y -> x in aboves[y])));

	# this loop adds the minimal elements to the stack
	for i in [1 .. Length(p)] do
		if degrees[i] = 1 then # it is a minimal element
			Append(stack, [i]);
		fi;
	od;

	while not IsEmpty(stack) do
		# pop an element from the stack
		elt := stack[Length(stack)];
		stack := stack{[1 .. Length(stack)-1]};

		# add the element to the linear order
		Append(schedule, [p[elt]]);

		# decrease the degree of each element of p which
		# is more than elt.
		for i in aboves[elt] do
			degrees[i] := degrees[i]  - 1;

			# and push onto the stack if now minimal
			if degrees[i] = 1 then
				Append(stack, [i]);
			fi;
		od;
	od;

	# reorder p
	for i in [1 .. Length(p)] do
		p[i] := schedule[i];
	od;
end;


###########################################################################
##
#F  AddMinSet(<m>, <x>, <le>)
##
##  <le> is a partial order function - <le>(x, y) iff x <= y
##  <m> is a list in which every element is minimal under <le>
##  <x> is an element of the partial order.
##
##  AddMinSet then changes m to the minimal elements of the 
##  set m \union {x}.
##
AddMinSet := 
function(m, x, le)
	local y,n;

	# if there's a y <= x then don't add x in.
	if First(m, y->le(y, x)) <> fail then
		return;
	fi;

	
	# now remove the y's greater than x and replace with x
	n := ShallowCopy(m);
	for y in n do
		if le(x, y) then
			RemoveElmList(m, Position(m, y));
		fi;
	od;
	Append(m, [x]);
	
end;



###########################################################################
##
#F  AddMaxSet(<m>, <x>, <le>)
##
##  <le> is a partial order function - <le>(x, y) iff x <= y
##  <m> is a list in which every element is maximal under <le>
##  <x> is an element of the partial order.
##
##  AddMaxSet then changes m to the maximal elements of the 
##  set m \union {x}.
##
AddMaxSet := 
function(m, x, le)

	local ge;


	ge := function(a,b) return le(b, a); end;
	AddMinSet(m, x, ge);
	
end;

###########################################################################
##
#F  PosetCovers(<p>, <le>)
##
##  <le> is a partial order function - <le>(x, y) iff x <= y
##  <p> is a list whose elements form a  poset under <le>
##
##  Returns the list whose ith element is the set of indices in p of the
##  covers of the ith element of p.
##
##  NOTE: This function modifies p by topologically sorting it.
##
PosetCovers := 
function(p, le)
	local
			i, j, covers;

	# topologically sort p so that p[i] <  p[j] => i < j
	TopologicalSort(p, function(x,y) return le(x, y); end);

	covers := [];
	for i in [1 .. Length(p)] do
		covers[i] := [];
		for j in [i+1 .. Length(p)] do
			# if p[j] >= p[i]
			if le(p[i], p[j]) then
				# if there's nothing smaller than p[j]
				if First(covers[i], x->le(p[x], p[j])) = fail then
					# delete the things bigger than p[j]
					covers[i] := Filtered(covers[i], x->not le(p[j],p[x]));

					# ... and add it in!
					Append(covers[i], [j]);
				fi;
			fi;	
		od;
	od;

	return covers;
end;


###########################################################################
##
#F  PosetUnderCovers(<p>, <le>)
##
##  <le> is a partial order function - <le>(x, y) iff x <= y
##  <p> is a list whose elements form a  poset under <le>
##
##  Returns the list whose ith element is the set of indices in p of the
##  undercovers of the ith element of p.
##
##  NOTE: This function modifies p by *reverse* topologically sorting it.
##  NOTE: x is an *undercover* of y if y is a *cover* of x
##
PosetUnderCovers := 
function(p, le)
	local ge;


	ge := function(a,b) return le(b, a); end;
	return PosetCovers(p, ge);

end;

