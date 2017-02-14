## bug 4 for fix 5
gap> emb:= Embedding( DirectProduct( Group( (1,2) ), Group( (1,2) ) ), 1 );;
gap> PreImagesRepresentative( emb, (1,2)(3,4) );
fail
