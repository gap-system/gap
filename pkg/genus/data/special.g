#############################################################################
##
#V  SPECIAL_INFO
##
##  list of data for handling the special cases that are not covered by the
##  library of small groups
##
##  Each entry is a quadruple of the form `[ g, n, sign, groups ]',
##  where `groups' is a list of all groups that belong to genus `g',
##  order `n', and signature `sign'.
##
SPECIAL_INFO := [

[14,1092,[ 0, 2, 3, 7 ], [ PerfectGroup( IsPermGroup, 1092, 1 ) ] ],
    # The unique perfect group of order $1\,092$ is $L_2(13)$,
    # which is Hurwitz.

[17,768,[ 0, 2, 3, 8 ], [ ReadAsFunction( Filename(
        DirectoriesPackageLibrary( "genus", "data/construct" ), "grp_17_768" ) )() ] ],
    # There is a unique (3,3,4)-group of order 384 in genus 17;
    # it has trivial centre, its automorphism group is of order 6144;
    # this group has a unique conj. class of (2,3,8)-subgroups of order 768.
    # (Of course the direct product of the (3,3,4)-group with a cyclic
    # group of order 2 cannot occur because its commutator factor group is
    # too large.)

[17,1344,[ 0, 2, 3, 7 ], [ PerfectGroup( IsPermGroup, 1344, 2 ) ] ],
    # Exactly one of the two groups of type $2^3.L_3(2)$ is Hurwitz.

[22,1008,[ 0, 2, 3, 8 ], [ ReadAsFunction( Filename(
        DirectoriesPackageLibrary( "genus", "data/construct" ), "grp_22_1008" ) )() ] ],
    # There is no perfect group of order $1\,008$,
    # and the unique (3,3,4)-group of order 504 is $3 \times L_3(2)$.
    # Since the factor groups $3.2$ and $L_3(2).2$ of a (2,3,8)-group
    # of order $1\,008$ are factors of $\Gamma(0;2,3,8)$ (hence these
    # groups are $Aut(L_3(2))$ and $S_3$) and since the subdirect product
    # of $Aut(L_3(2))$ and $S_3$ is in fact a (2,3,8)-group, we get a unique
    # group here.
    # (Again no direct product can occur.)

[26,1200,[ 0, 2, 3, 8 ], [] ],
    # There is no perfect group of order $1\,200$,
    # and the unique (3,3,4)-group of order 600 is of type
    # $5^2\colon SL_2(3)$ (the factor group acting transitively on the
    # Sylow 5 subgroup).
    # The automorphism group of this group is of order $2\,400$,
    # it has a unique normal subgroup of index 2 that is not a (2,3,8)-group
    # because it has a factor group of type $2.(A_4 \times 2)$,
    # which has a too large commutator subgroup.
    # (Again no direct product can occur.)

[27,2184,[ 0, 2, 3, 7 ], [] ],
    # The unique perfect group of order $2\,184$ is $2.L_2(13)$,
    # which has a unique involution and therefore cannot be Hurwitz.

[28,1080,[ 0, 2, 4, 5 ], [] ],
    # The unique perfect group of order $1\,080$ is $3.A_6$, which is
    # not (2,4,5)-generated.
    # The non-perfect case is excluded by the fact that there is no
    # (2,5,5)-group of order 540.

[28,1296,[ 0, 2, 3, 8 ], [ ReadAsFunction( Filename(
        DirectoriesPackageLibrary( "genus", "data/construct" ), "grp_28_1296" ) )() ] ],
    # There is no perfect grgoup of order $1\,296$,
    # and a unique $(3,3,4)$-group of order $648$ in genus $28$.
    # The centre $C$ of this group has order $3$,
    # and the factor group by $C$ is a $(3,3,4)$-group of order $216$
    # in genus $10$, which lies in a $(2,3,8)$-group of order $432$
    # in genus $10$.
    # There is exactly one such group, and extending by a 1-dimensional
    # module in characteristic 3 yields a unique $(2,3,8)$-group
    # of order $1\,296$.

[29,1008,[ 0, 2, 3, 9 ], [] ],
    # There is no perfect group of order $1\,008$,
    # and the unique (2,2,2,3)-group of order $336$ is $L_3(2).2$,
    # which has trivial outer automorphism group.
    # The direct product $3 \times 2.L_3(2)$ is not $(2,3,9)$-generated
    # because it has a unique involution.

[29,1344,[ 0, 2, 3, 8 ], [] ],
    # None of the two perfect groups of order $1\,344$ is (2,3,8)-generated,
    # and there is no (3,3,4)-group of order $672$.

[31,1080,[ 0, 2, 3, 9 ], [] ],
    # The unique perfect group of order $1\,080$ is not (2,3,9)-generated,
    # and the unique (2,2,2,3)-group of order $360$ is isomorphic with
    # $A_5 \times S_3$, which has no element of order 3 in its outer
    # automorphism group.
    # (Again no direct product can occur.)

[31,1200,[ 0, 2, 4, 5 ], [] ],
    # There is no perfect group of order $1\,200$,
    # and no (2,5,5)-group of order $600$.
#T remove after the `SPECIAL' call has disappeared!

[31,1440,[ 0, 2, 3, 8 ], [] ],
    # There is no perfect group of order $1\,440$,
    # and no (3,3,4)-group of order $720$.
#T remove after the `SPECIAL' call has disappeared!

[31,2520,[ 0, 2, 3, 7 ], [] ],
    # The unique perfect group of order $2\,520$ is $A_7$,
    # which is not Hurwitz.

[33,512,[ 0, 2, 4, 8 ], ReadAsFunction( Filename(
        DirectoriesPackageLibrary( "genus", "data/construct" ), "grps_33_512" ) )() ],
    # The group has rank 2, so we need to consider only one normal
    # subgroup of index 2 (all three must exist!).
    # There are 9 subgroups of order $256$ for the signature $(0;4,4,4)$,
    # and computing top extensions by a $2$ (first check compatibility of
    # abelian invariants, then check whether the group is $(2,4,8)$-generated)
    # yields $10$ groups;
    # the numbers of conjugacy classes are $29$ (four times),
    # $38$ (three times), and $26$, $32$, $35$ (each only once).
    # Computing the character tables and possible isomorphisms of these tables
    # yields that two pairs may be isomorphic,
    # hard test with `IsomorphismGroups' in {\GAP}~4 shows that the groups
    # are in fact isomorphic.
    # So we get $8$ nonisomorphic groups.

[33,768,[ 0, 3, 3, 4 ], [ ReadAsFunction( Filename(
        DirectoriesPackageLibrary( "genus", "data/construct" ), "grps_33_768_1" ) )() ] ],
    # There are $9$ groups of order $256$ to consider for $(0;4,4,4)$,
    # exactly one has top extensions with the right abelian invariants,
    # the two $(3,3,4)$-generated candidates yields a unique group.

[33,768,[ 0, 2, 4, 6 ], ReadAsFunction( Filename(
        DirectoriesPackageLibrary( "genus", "data/construct" ), "grps_33_768_2" ) )() ],
    # $\Gamma(0;2,4,6)$ has three subgroups of index $2$,
    # with signatures $(0;2,6,6)$, $(0;3,4,4)$, and $(0;2,2,2,3)$,
    # respectively.
    # There are $7$, $6$, $6$ subgroups to consider for them,
    # and $6$, $6$, resp.~$7$ top extensions are found.
    # All of them have commutator factor group $2^2$,
    # so we need to consider only the $6$ groups obtained for
    # the first $N$, say; they are pairwise nonisomorphic because
    # their numbers of conjugacy classes are different
    # (18, 23, 24, 25, 27, 31).

[33,768,[ 0, 2, 3, 12 ], ReadAsFunction( Filename(
        DirectoriesPackageLibrary( "genus", "data/construct" ), "grps_33_768_3" ) )() ],
    # Checking the two subgroups of prime index, with signatures
    # $(0;3,3,6)$ and $(0;2,2,2,4)$,
    # we have to look at 4 resp.~33 groups of order 384 resp.~256.
    # We find 4 resp.~5 groups, each with abelian invariants $2\times 3$,
    # so we need to look only at the 4 groups for the first signature,
    # and find that they are pairwise nonisomorphic, in fact their
    # character tables are already nonequivalent.

[33,2688,[ 0, 2, 3, 7 ], [] ],
    # None of the three perfect groups of order $2\,688$ is Hurwitz.
#T isom. types?

[34,1320,[ 0, 2, 4, 5 ], [
        Group((3,12,11,10,9,8,7,6,5,4),(1,2,8)(3,7,9)(4,10,5)(6,12,11)) ] ],
    # The unique perfect group of order $1\,320$ is $2.L_2(11)$, which is
    # not (2,4,5)-generated.
    # As for the non-perfect case, the unique (2,5,5)-group of order $660$
    # is of type $L_2(11)$, so only $L_2(11).2$ and $L_2(11) \times 2$
    # must be considered.
    # The former one is in fact (2,4,5)-generated, the latter one is not.

[37,1080,[ 0, 2, 3, 10 ], [] ],
    # The unique perfect group of order $1\,080$ is $3.A_6$, which does
    # not contain elements of order 10, and there is no $(3,3,5)$-group
    # of order $540$.

[37,1296,[ 0, 2, 3, 9 ], [] ],
    # There is no perfect group of order $1\,296$.
    # The two $(2,2,2,3)$-groups of order $432$ have both trivial centre,
    # their automorphism groups have orders $432$ and $1\,728 = 4 \cdot 432$,
    # respectively, so we get no group of order $1\,296$.
    # (The groups have both the structure $3^2.(2\times S_4)$.)
    # (Again no direct product can occur.)

[37,1440,[ 0, 2, 4, 5 ], [] ],
    # There is no perfect group of order $1\,440$ and no $(2,5,5)$-group
    # of order $720$.
#T remove after the `SPECIAL' call has disappeared!

[37,1728,[ 0, 2, 3, 8 ], [ ReadAsFunction( Filename(
        DirectoriesPackageLibrary( "genus", "data/construct" ), "grp_37_1728" ) )() ] ],
    # There is no perfect group of order $1\,728$, and a unique
    # $(3,3,4)$-group of order $864$.
    # This group has trivial centre, since it is solvable no direct
    # product can occur, so it is sufficient to consider its automorphism
    # group.
    # Is has order $6\,912 = 8 \cdot 864$, the factor group by the inner
    # automorphisms is isomorphic with $D_8$.
    # We examine the three preimages of involutions in this factor group
    # under the natural epimorphism, and find exactly one $(2,3,8)$-group
    # of order $1\,728$.

[40,1560,[ 0, 2, 4, 5 ], [] ],
    # There is no perfect group of order $1\,560$ and no $(2,5,5)$-group
    # of order $780$.
#T remove after the `SPECIAL' call has disappeared!

[41,768,[ 0, 2, 3, 16 ], [ ReadAsFunction( Filename(
        DirectoriesPackageLibrary( "genus", "data/construct" ), "grp_41_768_1" ) )(), ReadAsFunction( Filename(
        DirectoriesPackageLibrary( "genus", "data/construct" ), "grp_41_768_2" ) )() ] ],
    # There is no perfect group of order $768$,
    # and there are three $(3,3,8)$-groups of order $384$.
    # Two of them have trivial centre, their autmorphism groups have orders
    # $3\,072$ and $6\,144$, respectively, and the latter one contains a
    # unique $(2,3,16)$-group of order $768$.
    # The third of the groups of order $384$ has centre $C$ of order $2$,
    # and this central subgroup must be central also in any ...
    # The factor group by the centre is a group of order $192$
    # that is either a $(3,3,8)$-group in genus $21$ or a $(3,3,4)$-group
    # in genus $9$. (The former is true.)
    # So the factor group of $G$ modulo $C$ is a $(2,3,16)$-group
    # in genus $21$; there are exactly two such groups, and {\GAP} computes
    # 6 central extensions by a trivial module (4 for the first,
    # 2 for the second group).
    # Exactly one of these groups is in fact $(2,3,16)$-generated.

[41,1440,[ 0, 2, 3, 9 ], [] ],
    # There is no perfect group of order $1\,440$.
    # The unique $(2,2,2,3)$-group of order $480$ is a central product
    # of $2.A_5$ and $Q_8$.
    # Modulo the centre, this group is of the form $2^2 \times A_5$,
    # so the factor group of a possible $(2,3,9)$-group modulo the centre
    # is isomorphic with $A_4 \times A_5$,
    # hence the group itself is a central product of $SL(2,3)$ and $2.A_5$.
    # But this group cannot be $(2,3,9)$-generated because it does not
    # contain elements of order 9.

[41,1920,[ 0, 2, 3, 8 ], [] ],
    # None of the 7 perfect groups of order $1\,920$ is $(2,3,8)$-generated,
    # and there is no $(3,3,4)$-group of order $960$.

[43,1008,[ 0, 3, 3, 4 ], [] ],
    # There is no perfect group of order $m$,
    # and the unique $(4,4,4)$-group $N$ of order $336$ is of type
    # $L_3(2) \times 2$.
    # The group $N / Z(N) \cong L_3(2)$ occurs in genus $22$,
    # extending uniquely to the $(3,3,4)$-group $L_3(2) \times 3$.
    # Each central extension of this group by a group of order $2$
    # has a normal cyclic subgroup of order $6$,
    # so only $N \times 3$ would be possible;
    # but this group is not $(3,3,4)$-generated.

[43,1008,[ 0, 2, 4, 6 ], [] ],
    # There are no $(3,4,4)$- and $(2,6,6)$-groups of order $504$,
    # and $L_2(8)$ is the unique $(2,2,2,3)$-group of this order.
    # Only $L_2(8) \times 2$ is a candidate for $G$,
    # but this group has no element of order $4$.

[43,1008,[ 0, 2, 3, 12 ], [ ReadAsFunction( Filename(
        DirectoriesPackageLibrary( "genus", "data/construct" ), "grp_43_1008" ) )() ] ],
    # For the signature $(0;3,3,6)$, there are $2$ groups with centre of
    # order $6$ and $3$, respectively.
    # In either case, we may choose a central subgroup of order $3$,
    # and the factor group $\tilde{G}$ is a $(2,3,12)$-group of order $336$
    # in genus $15$.
    # There is exactly one such group, and it leads to a unique $(2,3,12)$-group
    # of order $1\,008$;
    # its derived subgroup has index $6$, so this group is also obtained
    # when $(2,2,2,4)$-generation is considered.
    # For $(0;2,2,2,4)$, there are $3$ groups of order $336$ with centre
    # of order $2$ and one group with trivial centre.
    # The latter group $N$ is of type $\Aut(L_3(2))$.
    # We have $N \cong \Aut(N)$, and $N \times 3$ cannot occur
    # because it has a normal subgroup of type $L_3(2) \times 3$,
    # which is not a $(3,3,6)$-group.
    # For the former three groups, we have to consider $(2,3,12)$-
    # and $(2,3,6)$-groups $\tilde{G}$ of order $504$.
    # There are no groups of the latter kind (in genus $1$),
    # and exactly one group of the former (in genus $22$),
    # which admits a unique central extension of order $1\,008$.
    # Thus there is exactly one $(2,3,12)$-group of this order.

[43,1512,[ 0, 2, 3, 9 ], [
        Group((3,8,6,4,9,7,5),(1,2,3)(4,7,5)(6,9,8),(10,11,12)),
        Group( (3,8,6,4,9,7,5), (1,2,3)(4,7,5)(6,9,8), (4,5,7)(6,9,8) ) ] ],
    # There is no perfect group of order $m$,
    # and (see above) the unique $(2,2,2,3)$-group $N$ of order $504$ 
    # is of type $L_2(8)$.
    # We must consider $N \times 3$ and $\Aut(N)$ as candidates for $G$.
    # Both groups are fact $(2,3,9)$-generated.

[43,1680,[ 0, 2, 4, 5 ], [] ],
    # There is neither a perfect group of order $m$,
    # nor a $(2,5,5)$-group of order $840$.

[43,2016,[ 0, 2, 3, 8 ], [] ],
    # There is neither a perfect group of order $m$,
    # nor (see above) a $(3,3,4)$-group of order $1\,008$.

[45,1320,[ 0, 2, 3, 10 ], [
        Group((3,12,11,10,9,8,7,6,5,4),(1,2,8)(3,7,9)(4,10,5)(6,12,11)) ] ],
    # The unique perfect group of order $m$ is of type $2.L_2(11)$,
    # which cannot be $(2,3,10)$-generated because it has a unique involution
    # (see Lemma~\ref{uniqueinv}).
    # For the unique $(3,3,5)$-group of order $660$,
    # which is of type $L_2(11)$, we must consider $L_2(11) \times 2$
    # and $\Aut( L_2(11) )$;
    # the latter group is $(2,3,10)$-generated, the former is not.

[46,1080,[ 0, 3, 3, 4 ], [ PerfectGroup( IsPermGroup, 1080, 1 ),
          DirectProduct( AlternatingGroup( 6 ), CyclicGroup( 3 ) ) ] ],
    # $3.A_6$, the unique perfect group of order $m$,
    # is $(3,3,4)$-generated.
    # The only $(4,4,4)$-group of order $360$ is the alternating group $A_6$,
    # and also $3 \times A_6$ is $(3,3,4)$-generated.

[46,1080,[ 0, 2, 4, 6 ], [] ],
    # $3.A_6$ is not $(2,4,6)$-generated,
    # and there is no group of order $540$ arising from one of the signatures
    # $(0;2,2,2,3)$, $(0;3,4,4)$, $(0;2,6,6)$.

[46,1080,[ 0, 2, 3, 12 ], [] ],
    # The group $3.A_6$ is not $(2,3,12)$-generated,
    # and there is no $(3,3,6)$-group of order $540$.
    # One of the three $(2,2,2,4)$-groups of order $360$ is of type $A_6$,
    # and $3 \times A_6$ is not $(2,3,12)$-generated;
    # the other two $(2,2,2,4)$-groups are solvable,
    # they need not be considered because any $(2,3,12)$-group of order
    # $1\,080$ is nonsolvable by Corollary~\ref{corsolv} (c).

[46,1800,[ 0, 2, 4, 5 ], [] ],
    # There is neither a perfect group of order $m$,
    # nor a $(2,5,5)$-group of order $900$.

[46,2160,[ 0, 2, 3, 8 ],  [ ReadAsFunction( Filename(
        DirectoriesPackageLibrary( "genus", "data/construct" ), "grp_46_2160_1" ) )(), ReadAsFunction( Filename(
        DirectoriesPackageLibrary( "genus", "data/construct" ), "grp_46_2160_2" ) )() ] ],
    # The unique perfect group of order $2\,160$, of type $6.A_6$,
    # is not $(2,3,8)$-generated.
    # Any $(3,3,4)$-group of order $1\,080$ has a central subgroup of order $3$
    # (see above), and the unique $(2,3,8)$-group of order $720$,
    # in genus $16$, is of type $PGL_2(9)$.  The {\ATLAS}
    # (see~\cite[p.~4]{ATLAS}),\index{ATLAS@{\sf ATLAS} of Finite Groups}
    # denotes this group as $A_6.2_2$.
    # Thus $G$ is either of type $3.A_6.2_2$ or a subdirect product of
    # $A_6.2_2$ and a (nonabelian) group of order $6$.
    # The former is $(2,3,8)$-generated,
    # and also in the latter case, we get one $(2,3,8)$-group.
];

