# IsomorphismPermGroupOrFailFpGroup ignored its second argument
# which is supposed to limit the number of cosets that get defined
# before it gives up
gap> F:=FreeGroup(2);;G:=F/[F.1^2, F.2^2];;
gap> IsomorphismPermGroupOrFailFpGroup(G, 100);
fail
