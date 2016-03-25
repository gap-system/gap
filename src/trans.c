/*******************************************************************************
*
* A transformation <f> has internal representation as follows:
*
* [Obj* image set, Obj* flat kernel, Obj* external degree, entries image list]
*
* The <internal degree> of <f> is just the length of <entries image list>, this
* is accessed here using <DEG_TRANS2> and <DEG_TRANS4>, in GAP it can be accessed
* using INT_DEG_TRANS (for debugging purposes only).
*
* Transformations must always have internal degree greater than or equal to the
* largest point in <entries image list>. 
* 
* An element of <entries image list> of a transformation in T_TRANS2 must be at
* most 65535 and be UInt2. Hence the internal and external degrees of a T_TRANS2
* are at most 65536. If <f> is T_TRANS4, then the elements of <entries
* image list> must be UInt4.
*
* The <image set> and <flat kernel> are found relative to the internal degree of
* the transformation, and must not be changed after they are first found. 
*
* The <external degree> is the largest non-negative integer <n> such that
* <n^f!=n> or <i^f=n> for some <i!=n>, or equivalently the degree of a
* transformation is the least non-negative <n> such that <[n+1,n+2,...]> is
* fixed pointwise by <f>. This value is an invariant of <f>, in the sense that
* it does not depend on the internal representation. In GAP,
* <DegreeOfTransformation(f)> returns the external degree, so that if <f=g>,
* then <DegreeOfTransformation(f)=DegreeOfTransformation(g)>.
*
* In this file, the external degree of a transformation is accessed using
* <FuncDegreeOfTransformation(f)> (if it is not known if <EXT_TRANS(f)==NULL>)
* or <EXT_TRANS> (if it is known that <EXT_TRANS(f)!=NULL>).
* 
*******************************************************************************/

#include        "trans.h"               /* transformations                 */

#define MIN(a,b)          (a<b?a:b)
#define MAX(a,b)          (a<b?b:a)

// TmpTrans is the same as TmpPerm

Obj TmpTrans;
Obj IdentityTrans;

/*******************************************************************************
** Static functions for transformations
*******************************************************************************/

static inline void ResizeTmpTrans( UInt len ){
  if(SIZE_OBJ(TmpTrans)<len*sizeof(UInt4)){
    ResizeBag(TmpTrans,len*sizeof(UInt4));
  }
}

static inline UInt4 * ResizeInitTmpTrans( UInt len ){
  UInt    i;
  UInt4   *pttmp;

  if(SIZE_OBJ(TmpTrans)<len*sizeof(UInt4)){
    ResizeBag(TmpTrans,len*sizeof(UInt4));
  }
  pttmp=(UInt4*)(ADDR_OBJ(TmpTrans));
  for(i=0;i<len;i++) pttmp[i]=0;
  return pttmp;
}

/* find rank, canonical trans same kernel, and img set (unsorted) */
extern UInt INIT_TRANS2(Obj f){ 
  UInt    deg, rank, i, j;
  UInt2   *ptf;
  UInt4   *pttmp;
  Obj     img, ker;

  deg=DEG_TRANS2(f);
  
  if(deg==0){//special case for degree 0
    img=NEW_PLIST(T_PLIST_EMPTY+IMMUTABLE, 0);
    SET_LEN_PLIST(img, 0);
    IMG_TRANS(f)=img;
    KER_TRANS(f)=img;
    CHANGED_BAG(f);
    return 0;
  }

  img=NEW_PLIST(T_PLIST_CYC+IMMUTABLE, deg);
  ker=NEW_PLIST(T_PLIST_CYC_NSORT+IMMUTABLE, deg);
  SET_LEN_PLIST(ker, (Int) deg);

  pttmp=ResizeInitTmpTrans(deg);
  ptf=ADDR_TRANS2(f); 
 
  rank=0;
  for(i=0;i<deg;i++){        
    j=ptf[i];               /* f(i) */
    if(pttmp[j]==0){ 
      pttmp[j]=++rank;         
      SET_ELM_PLIST(img, rank, INTOBJ_INT(j+1));
    }
    SET_ELM_PLIST(ker, i+1, INTOBJ_INT(pttmp[j]));
  }

  SHRINK_PLIST(img, (Int) rank);
  SET_LEN_PLIST(img, (Int) rank);
  
  IMG_TRANS(f)=img;
  KER_TRANS(f)=ker;
  CHANGED_BAG(f);
  return rank;
}

extern UInt INIT_TRANS4(Obj f){ 
  UInt    deg, rank, i, j;
  UInt4   *ptf;
  UInt4   *pttmp;
  Obj     img, ker;

  deg=DEG_TRANS4(f);
  
  if(deg==0){//special case for degree 0
    img=NEW_PLIST(T_PLIST_EMPTY+IMMUTABLE, 0);
    SET_LEN_PLIST(img, 0);
    IMG_TRANS(f)=img;
    KER_TRANS(f)=img;
    CHANGED_BAG(f);
    return 0;
  }

  img=NEW_PLIST(T_PLIST_CYC+IMMUTABLE, deg);
  ker=NEW_PLIST(T_PLIST_CYC_NSORT+IMMUTABLE, deg);
  SET_LEN_PLIST(ker, (Int) deg);

  pttmp=ResizeInitTmpTrans(deg);
  ptf=ADDR_TRANS4(f); 
 
  rank=0;
  for(i=0;i<deg;i++){        
    j=ptf[i];               /* f(i) */
    if(pttmp[j]==0){ 
      pttmp[j]=++rank;         
      SET_ELM_PLIST(img, rank, INTOBJ_INT(j+1));
    }
    SET_ELM_PLIST(ker, i+1, INTOBJ_INT(pttmp[j]));
  }

  SHRINK_PLIST(img, (Int) rank);
  SET_LEN_PLIST(img, (Int) rank);
  
  IMG_TRANS(f)=img;
  KER_TRANS(f)=ker;
  CHANGED_BAG(f);
  return rank;
}


static Obj SORT_PLIST_CYC(Obj res){
  Obj     tmp;      
  UInt    h, i, k, len;
  
  len=LEN_PLIST(res); 
  h = 1;  while ( 9*h + 4 < len )  h = 3*h + 1;
  while ( 0 < h ) {
    for ( i = h+1; i <= len; i++ ) {
      tmp = ADDR_OBJ(res)[i];  k = i;
      while ( h < k && ((Int)tmp < (Int)(ADDR_OBJ(res)[k-h])) ) {
        ADDR_OBJ(res)[k] = ADDR_OBJ(res)[k-h];
        k -= h;
      }
      ADDR_OBJ(res)[k] = tmp;
    }
    h = h / 3;
  }
  RetypeBag(res, T_PLIST_CYC_SSORT + IMMUTABLE); 
  CHANGED_BAG(res);
  return res;
}

/*******************************************************************************
** GAP functions for transformations
*******************************************************************************/

//for debugging...
Obj FuncHAS_KER_TRANS( Obj self, Obj f ){
  if(IS_TRANS(f)){
    return (KER_TRANS(f)==NULL?False:True);
  } else {
    return Fail;
  }
}

Obj FuncHAS_IMG_TRANS( Obj self, Obj f ){
  if(IS_TRANS(f)){
    return (IMG_TRANS(f)==NULL?False:True);
  } else {
    return Fail;
  }
}

Obj FuncINT_DEG_TRANS( Obj self, Obj f ){
  if(TNUM_OBJ(f)==T_TRANS2){
    return INTOBJ_INT(DEG_TRANS2(f));
  } else if (TNUM_OBJ(f)==T_TRANS4){
    return INTOBJ_INT(DEG_TRANS4(f));
  }
  return Fail;
}

//this only works when <f> is T_TRANS2 and deg(f)<=m<10
Obj FuncNUMB_TRANS_INT(Obj self, Obj f, Obj m){
  UInt                n, a, i, def;
  UInt2               *ptf2;

  n=INT_INTOBJ(m);  a=0;
  def=DEG_TRANS2(f);
  ptf2=ADDR_TRANS2(f);
  for(i=0;i<def;i++)  a=a*n+ptf2[i];
  for(;i<n;i++)       a=a*n+i;      
  return INTOBJ_INT(a+1);  
}  
 
//this only works when <f> is T_TRANS2 and deg(f)<=m<10
Obj FuncTRANS_NUMB_INT(Obj self, Obj b, Obj m){
  UInt    n, a, i, q;
  Obj     f;
  UInt2*  ptf;

  n=INT_INTOBJ(m);   a=INT_INTOBJ(b)-1;
  f=NEW_TRANS2(n);   ptf=ADDR_TRANS2(f);
  for(i=n;0<i;i--){
    q=a/n;  ptf[i-1]=a-q*n;  a=q; 
  } 
  return f;
}

/* method for creating transformation */
Obj FuncTransformationNC( Obj self, Obj list ){ 
  UInt    i, deg;
  UInt2*  ptf2;
  UInt4*  ptf4;
  Obj     f; 
 
  deg=LEN_LIST(list);
  
  if(deg<=65536){ 
    f=NEW_TRANS2(deg);
    ptf2=ADDR_TRANS2(f);
    for(i=0;i<deg;i++) ptf2[i]=INT_INTOBJ(ELM_LIST(list, i+1))-1;
  }else{
    f=NEW_TRANS4(deg);
    ptf4=ADDR_TRANS4(f);
    for(i=0;i<deg;i++) ptf4[i]=INT_INTOBJ(ELM_LIST(list, i+1))-1;
  }
  return f; 
}


Obj FuncTransformationListListNC( Obj self, Obj src, Obj ran ){ 
  UInt    deg, i, s, r;
  Obj     f;
  UInt2*  ptf2;
  UInt4*  ptf4;

  if(!IS_SMALL_LIST(src)){
    ErrorQuit("usage: <src> must be a list (not a %s)", 
        (Int)TNAM_OBJ(src), 0L);
  }
  if(!IS_SMALL_LIST(ran)){
    ErrorQuit("usage: <ran> must be a list (not a %s)", 
        (Int)TNAM_OBJ(ran), 0L);
  }
  if(LEN_LIST(src)!=LEN_LIST(ran)){
    ErrorQuit("usage: <src> and <ran> must have equal length,", 0L, 0L);
  }

  deg=0;
  for(i=LEN_LIST(src);1<=i;i--){
    s=INT_INTOBJ(ELM_LIST(src, i));
    if(s>deg) deg=s;
    r=INT_INTOBJ(ELM_LIST(ran, i));
    if(r>deg) deg=r;
  } 

  if(deg<=65536){ 
    f=NEW_TRANS2(deg);
    ptf2=ADDR_TRANS2(f);
    for(i=0;i<deg;i++) ptf2[i]=i;
    for(i=LEN_LIST(src);1<=i;i--){
      ptf2[INT_INTOBJ(ELM_LIST(src, i))-1]=INT_INTOBJ(ELM_LIST(ran, i))-1;
    }
  }else{
    f=NEW_TRANS4(deg);
    ptf4=ADDR_TRANS4(f);
    for(i=0;i<deg;i++) ptf4[i]=i;
    for(i=LEN_LIST(src);1<=i;i--){
      ptf4[INT_INTOBJ(ELM_LIST(src, i))-1]=INT_INTOBJ(ELM_LIST(ran, i))-1;
    }
  }
  return f; 
}

Obj FuncDegreeOfTransformation(Obj self, Obj f){
  UInt    n, i, deg;
  UInt2   *ptf2;
  UInt4   *ptf4;

  if(TNUM_OBJ(f)==T_TRANS2){ 
    if (EXT_TRANS(f) == NULL) {
      n=DEG_TRANS2(f);
      ptf2=ADDR_TRANS2(f);
      if(ptf2[n-1]!=n-1){
        EXT_TRANS(f) = INTOBJ_INT(n);
      } else {
        deg=0;
        for(i=0;i<n;i++){ 
          if(ptf2[i]>i&&ptf2[i]+1>deg){
            deg=ptf2[i]+1;
          } else if(ptf2[i]<i&&i+1>deg){
            deg=i+1;
          }
        }
        EXT_TRANS(f) = INTOBJ_INT(deg);
      }
    }
    return EXT_TRANS(f);
  } else if (TNUM_OBJ(f)==T_TRANS4){
    if (EXT_TRANS(f) == NULL) {
      n=DEG_TRANS4(f);
      ptf4=ADDR_TRANS4(f);
      if(ptf4[n-1]!=n-1){
        EXT_TRANS(f) = INTOBJ_INT(n);
      } else {
        deg=0;
        for(i=0;i<n;i++){ 
          if(ptf4[i]>i&&ptf4[i]+1>deg){
            deg=ptf4[i]+1;
          } else if(ptf4[i]<i&&i+1>deg){
            deg=i+1;
          }
        }  
        EXT_TRANS(f) = INTOBJ_INT(deg);
      }
    }
    return EXT_TRANS(f);
  }
  ErrorQuit("usage: the argument should be a transformation,", 0L, 0L);
  return 0L;
}


/* rank of transformation */
Obj FuncRANK_TRANS(Obj self, Obj f){ 
  if(TNUM_OBJ(f)==T_TRANS2){ 
    return SumInt(INTOBJ_INT(RANK_TRANS2(f)-DEG_TRANS2(f)), 
          FuncDegreeOfTransformation(self, f)); 
  } else {
    return SumInt(INTOBJ_INT(RANK_TRANS4(f)-DEG_TRANS4(f)), 
          FuncDegreeOfTransformation(self, f)); 
  }
}

/* corank of transformation 
Obj FuncCORANK_TRANS(Obj self, Obj f){ 
  if(TNUM_OBJ(f)==T_TRANS2){ 
    return INTOBJ_INT(DEG_TRANS2(f)-RANK_TRANS2(f));
  } else {
    return INTOBJ_INT(DEG_TRANS4(f)-RANK_TRANS4(f));
  }
}*/

/* rank of transformation */
Obj FuncRANK_TRANS_INT(Obj self, Obj f, Obj n){ 
  UInt    rank, i, m;
  UInt2   *ptf2;
  UInt4   *pttmp, *ptf4;

  m=INT_INTOBJ(n);
  if(TNUM_OBJ(f)==T_TRANS2){ 
    if(m>=DEG_TRANS2(f)){
      return INTOBJ_INT(RANK_TRANS2(f)-DEG_TRANS2(f)+m);
    } else {
      pttmp=ResizeInitTmpTrans(DEG_TRANS2(f));
      ptf2=ADDR_TRANS2(f);
      rank=0; 
      for(i=0;i<m;i++){        
        if(pttmp[ptf2[i]]==0){ 
          rank++;
          pttmp[ptf2[i]]=1;         
        }
      }
      return INTOBJ_INT(rank);
    }
  } else {
    if(m>=DEG_TRANS2(f)){
      return INTOBJ_INT(RANK_TRANS4(f)-DEG_TRANS4(f)+m);
    } else {
      pttmp=ResizeInitTmpTrans(DEG_TRANS4(f));
      ptf4=ADDR_TRANS4(f);
      rank=0; 
      for(i=0;i<m;i++){        
        if(pttmp[ptf4[i]]==0){ 
          rank++;
          pttmp[ptf4[i]]=1;         
        }
      }
      return INTOBJ_INT(rank);
    }
  }
}

Obj FuncRANK_TRANS_LIST(Obj self, Obj f, Obj list){ 
  UInt    rank, i, j, len, def;
  UInt2   *ptf2;
  UInt4   *pttmp, *ptf4;
  Obj     pt;

  len=LEN_LIST(list);
  if(TNUM_OBJ(f)==T_TRANS2){ 
    def=DEG_TRANS2(f);
    pttmp=ResizeInitTmpTrans(def);
    ptf2=ADDR_TRANS2(f);
    rank=0; 
    for(i=1;i<=len;i++){
      pt=ELM_LIST(list, i);
      if(TNUM_OBJ(pt)!=T_INT||INT_INTOBJ(pt)<1){
        ErrorQuit("usage: the second argument <list> must be a list of positive\n integers (not a %s)", (Int)TNAM_OBJ(pt), 0L);
      }
      j=INT_INTOBJ(pt)-1;
      if(j<=def){
        j=ptf2[INT_INTOBJ(ELM_LIST(list, i))-1];
        if(pttmp[j]==0){ rank++; pttmp[j]=1; }
      } else {
        rank++;
      }
    }
  } else {
    def=DEG_TRANS4(f);
    pttmp=ResizeInitTmpTrans(def);
    ptf4=ADDR_TRANS4(f);
    rank=0; 
    for(i=1;i<=len;i++){
      pt=ELM_LIST(list, i);
      if(TNUM_OBJ(pt)!=T_INT||INT_INTOBJ(pt)<1){
        ErrorQuit("usage: the second argument <list> must be a list of positive\n integers (not a %s)", (Int)TNAM_OBJ(pt), 0L);
      }
      j=INT_INTOBJ(pt)-1;
      if(j<=def){
        j=ptf4[INT_INTOBJ(ELM_LIST(list, i))-1];
        if(pttmp[j]==0){ rank++; pttmp[j]=1; }
      } else {
        rank++;
      }
    }
  }
  return INTOBJ_INT(rank);
}

/* test if a transformation is the identity. */

Obj FuncIS_ID_TRANS(Obj self, Obj f){
  UInt2*  ptf2=ADDR_TRANS2(f);
  UInt4*  ptf4=ADDR_TRANS4(f);
  UInt    deg, i; 

  if(TNUM_OBJ(f)==T_TRANS2){
    deg=DEG_TRANS2(f);
    for(i=0;i<deg;i++){
      if(ptf2[i]!=i){
        return False;
      }
    }
  } else {
    deg=DEG_TRANS4(f);
    for(i=0;i<deg;i++){
      if(ptf4[i]!=i){
        return False;
      }
    }
  }
  return True;
}


Obj FuncLARGEST_MOVED_PT_TRANS(Obj self, Obj f){
  UInt2   *ptf2;
  UInt4   *ptf4;
  UInt    i;

  if(TNUM_OBJ(f)==T_TRANS2){
    ptf2=ADDR_TRANS2(f);
    for(i=DEG_TRANS2(f);1<=i;i--){
      if(ptf2[i-1]!=i-1) break;
    }
    return INTOBJ_INT(i);
  } else if(TNUM_OBJ(f)==T_TRANS4){ 
    ptf4=ADDR_TRANS4(f);
    for(i=DEG_TRANS4(f);1<=i;i--){
      if(ptf4[i-1]!=i-1) break;
    }
    return INTOBJ_INT(i);
  }
  return 0L;
}

// the largest point in [1..LargestMovedPoint(f)]^f

Obj FuncLARGEST_IMAGE_PT (Obj self, Obj f){
  UInt2   *ptf2;
  UInt4   *ptf4;
  UInt    i, max, def;
  
  if(!IS_TRANS(f)){
    ErrorQuit("usage: the argument should be a transformation,", 0L, 0L);
  }
 
  max=0;
  if(TNUM_OBJ(f)==T_TRANS2){
    def=DEG_TRANS2(f);
    ptf2=ADDR_TRANS2(f);
    for(i=DEG_TRANS2(f);1<=i;i--){ if(ptf2[i-1]!=i-1) break; }
    for(;1<=i;i--){ 
      if(ptf2[i-1]+1>max){
        max=ptf2[i-1]+1; 
        if(max==def) break;
      }
    }
  } else {
    def=DEG_TRANS4(f);
    ptf4=ADDR_TRANS4(f);
    for(i=DEG_TRANS4(f);1<=i;i--){ if(ptf4[i-1]!=i-1) break; }
    for(;1<=i;i--){ 
      if(ptf4[i-1]+1>max){ 
        max=ptf4[i-1]+1;
        if(max==def) break;
      }
    }
  }
  return INTOBJ_INT(max);
}

// returns the wrong answer when applied to the identity
Obj FuncSMALLEST_MOVED_PT_TRANS(Obj self, Obj f){
  UInt2   *ptf2;
  UInt4   *ptf4;
  UInt    i, deg;
 
  if(!IS_TRANS(f)){
    ErrorQuit("usage: the argument should be a transformation,", 0L, 0L);
  }
  
  if(TNUM_OBJ(f)==T_TRANS2){
    ptf2=ADDR_TRANS2(f);
    deg=DEG_TRANS2(f);
    for(i=1;i<=deg;i++) if(ptf2[i-1]!=i-1) break;
  } else { 
    ptf4=ADDR_TRANS4(f);
    deg=DEG_TRANS4(f);
    for(i=1;i<=deg;i++) if(ptf4[i-1]!=i-1) break;
  }
  return INTOBJ_INT(i);
}

// the smallest point in [SmallestMovedPoint..LargestMovedPoint(f)]^f
Obj FuncSMALLEST_IMAGE_PT (Obj self, Obj f){
  UInt2   *ptf2;
  UInt4   *ptf4;
  UInt    i, min, deg;
  
  if(!IS_TRANS(f)){
    ErrorQuit("usage: the argument should be a transformation,", 0L, 0L);
  }
  if(TNUM_OBJ(f)==T_TRANS2){
    ptf2=ADDR_TRANS2(f);
    deg=DEG_TRANS2(f); 
    min=deg;
    for(i=0;i<deg;i++){ if(ptf2[i]!=i&&ptf2[i]<min) min=ptf2[i]; }
  } else {
    ptf4=ADDR_TRANS4(f);
    deg=DEG_TRANS4(f);
    min=deg;
    for(i=0;i<deg;i++){ if(ptf4[i]!=i&&ptf4[i]<min) min=ptf4[i]; }
  }
  return INTOBJ_INT(min+1);
}

 
Obj FuncNR_MOVED_PTS_TRANS(Obj self, Obj f){
  UInt    nr, i, deg;
  UInt2*  ptf2;
  UInt4*  ptf4;

  if(!IS_TRANS(f)){
    ErrorQuit("usage: the argument should be a transformation,", 0L, 0L);
  }

  nr=0;
  if(TNUM_OBJ(f)==T_TRANS2){
    ptf2=ADDR_TRANS2(f);
    deg=DEG_TRANS2(f);
    for(i=0;i<deg;i++){ if(ptf2[i]!=i) nr++; }
  } else {
    ptf4=ADDR_TRANS4(f);
    deg=DEG_TRANS4(f);
    for(i=0;i<deg;i++){ if(ptf4[i]!=i) nr++; }
  }
  return INTOBJ_INT(nr);
}


 
Obj FuncMOVED_PTS_TRANS(Obj self, Obj f){
  UInt    len, deg, i, k;
  Obj     out, tmp;
  UInt2   *ptf2;
  UInt4   *ptf4;

  if(!IS_TRANS(f)){
    ErrorQuit("usage: the argument should be a transformation,", 0L, 0L);
  }

  if(FuncIS_ID_TRANS(self, f)==True){
    out=NEW_PLIST(T_PLIST_EMPTY, 0);
    SET_LEN_PLIST(out, 0);
    return out;
  }

  len=0;
  if(TNUM_OBJ(f)==T_TRANS2){
    deg=DEG_TRANS2(f);
    out=NEW_PLIST(T_PLIST_CYC_SSORT, deg);
    ptf2=ADDR_TRANS2(f);
    for(i=0;i<deg;i++){
      if(ptf2[i]!=i) SET_ELM_PLIST(out, ++len, INTOBJ_INT(i+1));
    }
  } else {
    deg=DEG_TRANS4(f);
    out=NEW_PLIST(T_PLIST_CYC_SSORT, deg);
    ptf4=ADDR_TRANS4(f);
    for(i=0;i<deg;i++){
      if(ptf4[i]!=i) SET_ELM_PLIST(out, ++len, INTOBJ_INT(i+1));
    }
  }
  
  // remove duplicates
  tmp=ADDR_OBJ(out)[1];  k = 1;
  for(i=2;i<=len;i++){
    if(INT_INTOBJ(tmp)!=INT_INTOBJ(ADDR_OBJ(out)[i])) {
      k++;
      tmp = ADDR_OBJ(out)[i];
      ADDR_OBJ(out)[k] = tmp;
    }
  }

  if(k<len||len<deg){
    ResizeBag(out, (k+1)*sizeof(Obj) );
  }
  SET_LEN_PLIST(out, k);
  return out;
}

/* kernel of transformation */
Obj FuncFLAT_KERNEL_TRANS (Obj self, Obj f){ 

  if(KER_TRANS(f)==NULL){
    if(TNUM_OBJ(f)==T_TRANS2){
      INIT_TRANS2(f);
    } else {
      INIT_TRANS4(f);
    }
  }
  return KER_TRANS(f);
} 

Obj FuncFLAT_KERNEL_TRANS_INT (Obj self, Obj f, Obj n){
  Obj     new, *ptnew, *ptker; 
  UInt    deg, m, i;

  m=INT_INTOBJ(n);
  if(TNUM_OBJ(f)==T_TRANS2){
    if(KER_TRANS(f)==NULL) INIT_TRANS2(f);
    deg=DEG_TRANS2(f);
    if(m==deg){
      return KER_TRANS(f);
    } else if(m==0){
      new=NEW_PLIST(T_PLIST_EMPTY, 0);
      SET_LEN_PLIST(new, 0);
      return new;
    } else {
      new=NEW_PLIST(T_PLIST_CYC_NSORT, m);
      SET_LEN_PLIST(new, m);
      
      ptker=ADDR_OBJ(KER_TRANS(f))+1;
      ptnew=ADDR_OBJ(new)+1;

      //copy the kernel set up to minimum of m, deg
      if(m<deg){
        for(i=0;i<m;i++)      *ptnew++=*ptker++;
      } else { //m>deg
        for(i=0;i<deg;i++)    *ptnew++=*ptker++;
        //we must now add another (m-deg) points,
        //starting with the class number (rank+1)
        for(i=1; i<=m-deg; i++)
          *ptnew++=INTOBJ_INT(i+RANK_TRANS2(f));
      }
      return new;
    }
  }else{
    if(KER_TRANS(f)==NULL) INIT_TRANS4(f);
    deg=DEG_TRANS4(f);
    if(m==deg){
      return KER_TRANS(f);
    } else if(m==0){
      new=NEW_PLIST(T_PLIST_EMPTY, 0);
      SET_LEN_PLIST(new, 0);
      return new;
    } else {
      new=NEW_PLIST(T_PLIST_CYC_NSORT, m);
      SET_LEN_PLIST(new, m);
      
      ptker=ADDR_OBJ(KER_TRANS(f))+1;
      ptnew=ADDR_OBJ(new)+1;

      //copy the kernel set up to minimum of m, deg
      if(m<deg){
        for(i=0;i<m;i++)      *ptnew++=*ptker++;
      } else { //m>deg
        for(i=0;i<deg;i++)    *ptnew++=*ptker++;
        //we must now add another (m-deg) points,
        //starting with the class number (rank+1)
        for(i=1; i<=m-deg; i++)
          *ptnew++=INTOBJ_INT(i+RANK_TRANS4(f));
      }
      return new;
    }
  }
}

/* image set of transformation */
Obj FuncIMAGE_SET_TRANS (Obj self, Obj f){ 
  if(IMG_TRANS(f)==NULL){
    if(TNUM_OBJ(f)==T_TRANS2){
      INIT_TRANS2(f);
    } else {
      INIT_TRANS4(f);
    }
  }
  if(!IS_SSORT_LIST(IMG_TRANS(f))){
    return SORT_PLIST_CYC(IMG_TRANS(f));
  }
  return IMG_TRANS(f);  
} 

//the image set of <f> when applied to <1..n> 

Obj FuncIMAGE_SET_TRANS_INT (Obj self, Obj f, Obj n){ 
  Obj     im, new; 
  UInt    deg, m, len, i, j, rank;
  Obj     *ptnew, *ptim;
  UInt4   *pttmp, *ptf4;
  UInt2   *ptf2;

  m=INT_INTOBJ(n);
  deg=DEG_TRANS(f);

  if(m==deg){
    return FuncIMAGE_SET_TRANS(self, f);
  } else if(m==0){
    new=NEW_PLIST(T_PLIST_EMPTY+IMMUTABLE, 0);
    SET_LEN_PLIST(new, 0);
    return new;
  } else if(m<deg){
    //JDM add a check to see if IMAGE_SET_TRANS is known
    pttmp=ResizeInitTmpTrans(deg);
    new=NEW_PLIST(T_PLIST_CYC+IMMUTABLE, m);
    pttmp=(UInt4*)(ADDR_OBJ(TmpTrans));
    
    if(TNUM_OBJ(f)==T_TRANS2){
      ptf2=ADDR_TRANS2(f);
      rank=0;
      for(i=0;i<m;i++){        
        j=ptf2[i];               /* f(i) */
        if(pttmp[j]==0){ 
          pttmp[j]=++rank;         
          SET_ELM_PLIST(new, rank, INTOBJ_INT(j+1));
        }
      }
    } else {
      ptf4=ADDR_TRANS4(f);
      rank=0;
      for(i=0;i<m;i++){        
        j=ptf4[i];               /* f(i) */
        if(pttmp[j]==0){ 
          pttmp[j]=++rank;         
          SET_ELM_PLIST(new, rank, INTOBJ_INT(j+1));
        }
      }
    }
    SHRINK_PLIST(new, (Int) rank);
    SET_LEN_PLIST(new, (Int) rank);
    SORT_PLIST_CYC(new);
  } else {    //m>deg and so m is at least 1!
    im=FuncIMAGE_SET_TRANS(self, f);
    len=LEN_PLIST(im);
    new=NEW_PLIST(T_PLIST_CYC_SSORT, m-deg+len);
    SET_LEN_PLIST(new, m-deg+len);
    
    ptnew=ADDR_OBJ(new)+1;
    ptim=ADDR_OBJ(im)+1;

    //copy the image set 
    for(i=0;i<len;i++)      *ptnew++=*ptim++;
    //add new points
    for(i=deg+1;i<=m;i++)   *ptnew++=INTOBJ_INT(i);
  }
  return new;
} 

/* image list of transformation */

Obj FuncIMAGE_TRANS (Obj self, Obj f, Obj n ){ 
  UInt2*    ptf2;
  UInt4*    ptf4;
  UInt      i, deg, m;
  Obj       out;
  
  m=INT_INTOBJ(n);

  if(m==0){
    out=NEW_PLIST(T_PLIST_EMPTY+IMMUTABLE, 0);
    SET_LEN_PLIST(out, 0);
    return out;
  }

  if(TNUM_OBJ(f)==T_TRANS2){
    out=NEW_PLIST(T_PLIST_CYC+IMMUTABLE, m);
    ptf2=ADDR_TRANS2(f);
    deg=MIN(DEG_TRANS2(f), m); 
    for(i=0;i<deg;i++){ 
      SET_ELM_PLIST(out,i+1,INTOBJ_INT(ptf2[i]+1));
    }
    for(;i<m;i++) SET_ELM_PLIST(out,i+1,INTOBJ_INT(i+1));
  }else{
    out=NEW_PLIST(T_PLIST_CYC+IMMUTABLE, m);
    ptf4=ADDR_TRANS4(f);
    deg=MIN(DEG_TRANS4(f), m);
    for(i=0;i<deg;i++){ 
      SET_ELM_PLIST(out,i+1,INTOBJ_INT(ptf4[i]+1));
    }
    for(;i<m;i++) SET_ELM_PLIST(out,i+1,INTOBJ_INT(i+1));
  }

  SET_LEN_PLIST(out,(Int) m);
  return out;
} 

/* the kernel as a partition of [1..n] */

Obj FuncKERNEL_TRANS (Obj self, Obj f, Obj n){
  Obj     ker, flat;
  UInt    i, j, deg, nr, m, rank, len, min;
  UInt4*  pttmp;
   
  if(INT_INTOBJ(n)==0){//special case for the identity
    ker=NEW_PLIST(T_PLIST_EMPTY, 0);
    SET_LEN_PLIST(ker, 0);
    return ker;
  }
  
  deg=DEG_TRANS(f);
  rank=RANK_TRANS(f);
  flat=KER_TRANS(f);
  
  m=INT_INTOBJ(n);
  nr=(m<=deg?rank:rank+m-deg);  // the number of classes
  len=(UInt) deg/nr+1;          // average size of a class
  min=MIN(m,deg);
  
  ker=NEW_PLIST(T_PLIST_HOM_SSORT, nr);
  pttmp=ResizeInitTmpTrans(nr);

  nr=0;
  // read off flat kernel
  for(i=0;i<min;i++){
    /* renew the ptrs in case of garbage collection */
    j=INT_INTOBJ(ELM_PLIST(flat, i+1));
    if(pttmp[j-1]==0){
      nr++;
      SET_ELM_PLIST(ker, j, NEW_PLIST(T_PLIST_CYC_SSORT, len));
      CHANGED_BAG(ker);
      pttmp=(UInt4*)(ADDR_OBJ(TmpTrans));
    }
    AssPlist(ELM_PLIST(ker, j), (Int) ++pttmp[j-1], INTOBJ_INT(i+1));
    pttmp=(UInt4*)(ADDR_OBJ(TmpTrans));
  }
  
  for(i=0;i<nr;i++){
    SET_LEN_PLIST(ELM_PLIST(ker, i+1), (Int) pttmp[i]);
    SHRINK_PLIST(ELM_PLIST(ker, i+1), (Int) pttmp[i]);
    /* beware maybe SHRINK_PLIST will trigger a garbage collection */
  }

  for(i=deg;i<m;i++){//add trailing singletons if there are any
    SET_ELM_PLIST(ker, ++nr, NEW_PLIST(T_PLIST_CYC_SSORT, 1));
    SET_LEN_PLIST(ELM_PLIST(ker, nr), 1); 
    SET_ELM_PLIST(ELM_PLIST(ker, nr), 1, INTOBJ_INT(i+1));
    CHANGED_BAG(ker);
  }
  SET_LEN_PLIST(ker, (Int) nr);
  return ker;
}


Obj FuncPREIMAGES_TRANS_INT (Obj self, Obj f, Obj pt){
  UInt2   *ptf2;
  UInt4   *ptf4;
  UInt    deg, nr, i, j;
  Obj     out;

  deg=DEG_TRANS(f);

  if((UInt) INT_INTOBJ(pt)>deg){
    out=NEW_PLIST(T_PLIST_CYC, 1);
    SET_LEN_PLIST(out, 1);
    SET_ELM_PLIST(out, 1, pt);
    return out;
  }

  i=(UInt) INT_INTOBJ(pt)-1;
  out=NEW_PLIST(T_PLIST_CYC_SSORT, deg);

  /* renew the ptr in case of garbage collection */
  nr=0;
  if(TNUM_OBJ(f)==T_TRANS2){
    ptf2=ADDR_TRANS2(f);
    for(j=0;j<deg;j++) if(ptf2[j]==i) SET_ELM_PLIST(out, ++nr, INTOBJ_INT(j+1));
  }else{
    ptf4=ADDR_TRANS4(f);
    for(j=0;j<deg;j++) if(ptf4[j]==i) SET_ELM_PLIST(out, ++nr, INTOBJ_INT(j+1));
  }
  if(nr==0){
    RetypeBag(out, T_PLIST_EMPTY);
  }
  SET_LEN_PLIST(out, (Int) nr);
  SHRINK_PLIST(out, (Int) nr);
  return out;
}

// AsTransformation for a permutation <p> and a pos int <n>. This might be
// quicker if we don't install the kernel etc, but then getting the kernel etc
// back is slower than it is from here. 
Obj FuncAS_TRANS_PERM_INT(Obj self, Obj p, Obj deg){
  UInt2   *ptp2, *ptf2;
  UInt4   *ptp4, *ptf4;
  Obj     f, img, *ptimg;
  UInt    def, dep, i, min, n;
  
  n=INT_INTOBJ(deg);
  if(n==0) return IdentityTrans;

  //find the degree of f
  def=n;
  dep=(TNUM_OBJ(p)==T_PERM2?DEG_PERM2(p):DEG_PERM4(p));

  if(n<dep){
    min=def;
    if(TNUM_OBJ(p)==T_PERM2){
      ptp2=ADDR_PERM2(p);
      for(i=0;i<n;i++){
        if(ptp2[i]+1>def) def=ptp2[i]+1;
      }
    } else {
      dep=DEG_PERM4(p);
      ptp4=ADDR_PERM4(p);
      for(i=0;i<n;i++){
        if(ptp4[i]+1>def) def=ptp4[i]+1;
      }
    }
  } else {
    min=dep;
  }

  img=NEW_PLIST(T_PLIST_CYC_SSORT+IMMUTABLE, def);
  //create f 
  if(def<=65536){
    f=NEW_TRANS2(def);
    ptimg=ADDR_OBJ(img)+1;
    ptf2=ADDR_TRANS2(f);
    
    if(TNUM_OBJ(p)==T_PERM2){
      ptp2=ADDR_PERM2(p);
      for(i=0;i<min;i++){
        ptf2[i]=ptp2[i];
        ptimg[i]=INTOBJ_INT(i+1);
      }
    } else { //TNUM_OBJ(p)==T_PERM4
      ptp4=ADDR_PERM4(p);
      for(i=0;i<min;i++){
        ptf2[i]=ptp4[i];
        ptimg[i]=INTOBJ_INT(i+1);
      }
    }
    for(;i<def;i++){
      ptf2[i]=i;
      ptimg[i]=INTOBJ_INT(i+1);
    }
    IMG_TRANS(f)=img;
    KER_TRANS(f)=img;
    CHANGED_BAG(f);
  } else { //def>65536
    f=NEW_TRANS4(def);
    ptimg=ADDR_OBJ(img)+1;
    ptf4=ADDR_TRANS4(f);
    
    if(TNUM_OBJ(p)==T_PERM2){
      ptp2=ADDR_PERM2(p);
      for(i=0;i<min;i++){
        ptf4[i]=ptp2[i];
        ptimg[i]=INTOBJ_INT(i+1);
      }
    } else { //TNUM_OBJ(p)==T_PERM4
      ptp4=ADDR_PERM4(p);
      for(i=0;i<min;i++){
        ptf4[i]=ptp4[i];
        ptimg[i]=INTOBJ_INT(i+1);
      }
    }
    for(;i<def;i++){
      ptf4[i]=i;
      ptimg[i]=INTOBJ_INT(i+1);
    }
    IMG_TRANS(f)=img;
    KER_TRANS(f)=img;
    CHANGED_BAG(f);
  }
  
  SET_LEN_PLIST(img, def);
  return f;
}

/* AsTransformation for a permutation */

Obj FuncAS_TRANS_PERM(Obj self, Obj p){
  UInt2   *ptPerm2;
  UInt4   *ptPerm4;
  UInt    sup;

  //find largest moved point 
  if(TNUM_OBJ(p)==T_PERM2){
    ptPerm2=ADDR_PERM2(p);
    for(sup=DEG_PERM2(p);1<=sup;sup--) if(ptPerm2[sup-1]!=sup-1) break;
    return FuncAS_TRANS_PERM_INT(self, p, INTOBJ_INT(sup));
  } else { 
    ptPerm4 = ADDR_PERM4(p);
    for ( sup = DEG_PERM4(p); 1 <= sup; sup-- ) {
      if ( ptPerm4[sup-1] != sup-1 ) break;
    }
    return FuncAS_TRANS_PERM_INT(self, p, INTOBJ_INT(sup));
  }
}

/* converts transformation into permutation of its image if possible */

Obj FuncAS_PERM_TRANS(Obj self, Obj f){
  UInt2   *ptf2, *ptp2;
  UInt4   *ptf4, *ptp4;
  UInt    deg, i;
  Obj     p;

  if(TNUM_OBJ(f)==T_TRANS2){
    deg=DEG_TRANS2(f);
    if(RANK_TRANS2(f)!=deg) return Fail;
    
    p=NEW_PERM2(deg);
    ptp2=ADDR_PERM2(p);
    ptf2=ADDR_TRANS2(f);
    
    for(i=0;i<deg;i++){
      ptp2[i]=ptf2[i];
    }
    return p;
  }else if (TNUM_OBJ(f)==T_TRANS4){
    deg=DEG_TRANS4(f);
    if(RANK_TRANS4(f)!=deg) return Fail;
    
    p=NEW_PERM4(deg);
    ptp4=ADDR_PERM4(p);
    ptf4=ADDR_TRANS4(f);
    
    for(i=0;i<deg;i++){
      ptp4[i]=ptf4[i];
    }
    return p;
  }
  return Fail;
}

Obj FuncPERM_IMG_TRANS(Obj self, Obj f){
  UInt2   *ptf2, *ptp2;
  UInt4   *ptf4, *ptp4, *pttmp;
  UInt    deg, rank, i, j;
  Obj     p, img;

  if(TNUM_OBJ(f)==T_TRANS2){
    rank=RANK_TRANS2(f);
    deg=DEG_TRANS2(f);

    p=NEW_PERM2(deg);
    ResizeTmpTrans(deg); 
    
    pttmp=(UInt4*)(ADDR_OBJ(TmpTrans));
    ptp2=ADDR_PERM2(p);
    for(i=0;i<deg;i++){ pttmp[i]=0; ptp2[i]=i; }
    
    ptf2=ADDR_TRANS2(f);
    img=IMG_TRANS(f);
   
    for(i=0;i<rank;i++){
      j=INT_INTOBJ(ELM_PLIST(img, i+1))-1;    /* ranset(f)[i] */ 
      if(pttmp[ptf2[j]]!=0) return Fail; 
      pttmp[ptf2[j]]=1;
      ptp2[j]=ptf2[j];
    }
    return p;
  }else if (TNUM_OBJ(f)==T_TRANS4){
    rank=RANK_TRANS4(f);
    deg=DEG_TRANS4(f);

    p=NEW_PERM4(deg);
    ResizeTmpTrans(deg);

    pttmp=(UInt4*)(ADDR_OBJ(TmpTrans));
    ptp4=ADDR_PERM4(p);
    for(i=0;i<deg;i++){ pttmp[i]=0; ptp4[i]=i; }
    
    ptf4=ADDR_TRANS4(f);
    img=IMG_TRANS(f);
   
    for(i=0;i<rank;i++){
      j=INT_INTOBJ(ELM_PLIST(img, i+1))-1;    /* ranset(f)[i] */ 
      if(pttmp[ptf4[j]]!=0) return Fail; 
      pttmp[ptf4[j]]=1;
      ptp4[j]=ptf4[j];
    }
    return p;
  }
  return Fail;
}

/* if <g>=RESTRICTED_TRANS(f), then <g> acts like <f> on <list> and fixes every
 * other point */

Obj FuncRESTRICTED_TRANS(Obj self, Obj f, Obj list){
  UInt    deg, i, j, len;
  UInt2   *ptf2, *ptg2;
  UInt4   *ptf4, *ptg4;
  Obj     g;

  len=LEN_LIST(list);

  if(TNUM_OBJ(f)==T_TRANS2){
    deg=DEG_TRANS2(f);
    g=NEW_TRANS2(deg);
  
    ptf2=ADDR_TRANS2(f);
    ptg2=ADDR_TRANS2(g);

    /* g fixes every point */
    for(i=0;i<deg;i++) ptg2[i]=i;

    /* g acts like f on list */
    for(i=0;i<len;i++){
      j=INT_INTOBJ(ELM_LIST(list, i+1))-1;
      if(j<deg) ptg2[j]=ptf2[j];
    }
  }else{
    deg=DEG_TRANS4(f);
    g=NEW_TRANS4(deg);
  
    ptf4=ADDR_TRANS4(f);
    ptg4=ADDR_TRANS4(g);

    /* g fixes every point */
    for(i=0;i<deg;i++) ptg4[i]=i;

    /* g acts like f on list */
    for(i=0;i<len;i++){
      j=INT_INTOBJ(ELM_LIST(list, i+1))-1;
      if(j<deg) ptg4[j]=ptf4[j];
    }
  }
  return g;
}

// AsTransformation for a transformation <f> and a pos int <m> either restricts
// <f> to [1..m] or returns <f> depending on whether m is less than or equal
// Degree(f) or not.

// in the first form, this is similar to TRIM_TRANS except that a new
// transformation is returned. 


Obj FuncAS_TRANS_TRANS(Obj self, Obj f, Obj m){
  UInt2   *ptf2, *ptg2;
  UInt4   *ptf4, *ptg4;
  UInt    i, n, def;
  Obj     g;

  n=INT_INTOBJ(m);
  
  if(TNUM_OBJ(f)==T_TRANS2){    // f and g are T_TRANS2
    def=DEG_TRANS2(f);
    if(def<=n) return f;

    g=NEW_TRANS2(n);
    ptf2=ADDR_TRANS2(f);
    ptg2=ADDR_TRANS2(g);
    for(i=0;i<n;i++){
      if(ptf2[i]>n-1) return Fail;
      ptg2[i]=ptf2[i];
    }
    return g;
  }else{                    // f is T_TRANS4
    def=DEG_TRANS4(f);
    if(def<=n) return f;

    if(n>65536){            // g is T_TRANS4
      g=NEW_TRANS4(n);
      ptf4=ADDR_TRANS4(f);
      ptg4=ADDR_TRANS4(g);
      for(i=0;i<n;i++){
        if(ptf4[i]>n-1) return Fail;
        ptg4[i]=ptf4[i];
      }
    }else{  //  f is T_TRANS4 but n<=65536<def and so g will be T_TRANS2 */
      g=NEW_TRANS2(n);
      ptf4=ADDR_TRANS4(f);
      ptg2=ADDR_TRANS2(g);
      for(i=0;i<n;i++){
        if(ptf4[i]>n-1) return Fail;
        ptg2[i]=(UInt2) ptf4[i];
      }
    }
  }
  return g;
}

// it is assumed that f is actually a transformation of [1..m], i.e. that i^f<=m
// for all i in [1..m]
Obj FuncTRIM_TRANS (Obj self, Obj f, Obj m){
  UInt    deg, i;
  UInt4   *ptf;

  if(!IS_TRANS(f)){
    ErrorQuit("the argument must be a transformation,", 0L, 0L);
  }

  deg=INT_INTOBJ(m);

  if(TNUM_OBJ(f)==T_TRANS2){  // output is T_TRANS2
    if(deg>DEG_TRANS2(f)) return (Obj)0;
    ResizeBag(f, deg*sizeof(UInt2)+3*sizeof(Obj));
  } else if (TNUM_OBJ(f)==T_TRANS4){
    if(deg>DEG_TRANS4(f)) return (Obj)0;
    if(deg>65536UL){          // output is T_TRANS4
      ResizeBag(f, deg*sizeof(UInt4)+3*sizeof(Obj));
    } else {                  // output is T_TRANS2
      ptf=ADDR_TRANS4(f);
      for(i=0;i<deg;i++) ((UInt2*)ptf)[i]=(UInt2)ptf[i];
      RetypeBag(f, T_TRANS2);
      ResizeBag(f, deg*sizeof(UInt2)+3*sizeof(Obj));
    }
  }
  IMG_TRANS(f)=NULL;
  KER_TRANS(f)=NULL;
  EXT_TRANS(f)=NULL;
  CHANGED_BAG(f);
  return (Obj)0;
}

Obj FuncHASH_FUNC_FOR_TRANS(Obj self, Obj f, Obj data){
  UInt deg;

  deg=INT_INTOBJ(FuncDegreeOfTransformation(self, f));
  
  if(TNUM_OBJ(f)==T_TRANS4){
    if(deg<=65536){
      FuncTRIM_TRANS(self, f, INTOBJ_INT(deg));
    } else {
      return INTOBJ_INT((HASHKEY_BAG_NC(f, (UInt4) 255, 3*sizeof(Obj), 
              (int) 4*deg) % (INT_INTOBJ(data)))+1);
    }
  }

  return INTOBJ_INT((HASHKEY_BAG_NC(f, (UInt4) 255, 3*sizeof(Obj), 
          (int) 2*deg) % (INT_INTOBJ(data)))+1);

}

/* check if the trans or list t is injective on the list l */
Obj FuncIS_INJECTIVE_LIST_TRANS( Obj self, Obj l, Obj t){
  UInt    n, i, j;
  UInt2   *ptt2;
  UInt4   *pttmp=0L;
  UInt4   *ptt4;
  
  /* init buffer */
  n=(IS_TRANS(t)?DEG_TRANS(t):LEN_LIST(t));
  pttmp=ResizeInitTmpTrans(n);

  if(TNUM_OBJ(t)==T_TRANS2){/* and LEN_LIST(l), deg(f)<=65536 */
    ptt2=ADDR_TRANS2(t);
    for(i=LEN_LIST(l);i>=1;i--){
      j=(UInt) INT_INTOBJ(ELM_LIST(l, i));
      if(j<=n){
        if(pttmp[ptt2[j-1]]!=0) return False;
        pttmp[ptt2[j-1]]=1;
      }
    }
  } else if(TNUM_OBJ(t)==T_TRANS4){
    ptt4=ADDR_TRANS4(t);
    for(i=LEN_LIST(l);i>=1;i--){
      j=(UInt) INT_INTOBJ(ELM_LIST(l, i));
      if(j<=n) {
        if(pttmp[ptt4[j-1]]!=0) return False;
        pttmp[ptt4[j-1]]=1;
      }
    }
  }else if(n<=65536){/* t is a list */
    for(i=LEN_LIST(l);i>=1;i--){
      j=INT_INTOBJ(ELM_LIST(l, i));    
      if(j<=n){
        if(pttmp[INT_INTOBJ(ELM_LIST(t, j))-1]!=0) return False;
        pttmp[INT_INTOBJ(ELM_LIST(t, j))-1]=1;
      }
    }
  }else{ /* t is a list */
    for(i=LEN_LIST(l);i>=1;i--){
      j=INT_INTOBJ(ELM_LIST(l, i));    
      if(j<=n){
        if(pttmp[INT_INTOBJ(ELM_LIST(t, j))-1]!=0) return False;
        pttmp[INT_INTOBJ(ELM_LIST(t, j))-1]=1;
      }
    }
  }
  return True;
}

/* the perm2 of im(f) induced by f^-1*g, no checking*/
Obj FuncPERM_LEFT_QUO_TRANS_NC(Obj self, Obj f, Obj g)
{ UInt2   *ptf2, *ptg2, *ptp2;
  UInt4   *ptf4, *ptg4, *ptp4;
  UInt    def, deg, i;
  Obj     perm;

  if(TNUM_OBJ(f)==T_TRANS2&&TNUM_OBJ(g)==T_TRANS2){
    def=DEG_TRANS2(f); 
    deg=DEG_TRANS2(g);
    
    if(def<=deg){
      perm=NEW_PERM2(deg);
      ptp2=ADDR_PERM2(perm);
      ptf2=ADDR_TRANS2(f);
      ptg2=ADDR_TRANS2(g);
      for(i=0;i<deg;i++) ptp2[i]=i;
      for(i=0;i<def;i++) ptp2[ptf2[i]]=ptg2[i];
      for(;i<deg;i++)    ptp2[i]=ptg2[i];
    } else { //def>deg
      perm=NEW_PERM2(def);
      ptp2=ADDR_PERM2(perm);
      ptf2=ADDR_TRANS2(f);
      ptg2=ADDR_TRANS2(g);
      for(i=0;i<def;i++) ptp2[i]=i;
      for(i=0;i<deg;i++) ptp2[ptf2[i]]=ptg2[i];
      for(;i<def;i++)    ptp2[ptf2[i]]=i; 
    }
    return perm;
  } else if(TNUM_OBJ(f)==T_TRANS2&&TNUM_OBJ(g)==T_TRANS4){ //def<deg
    def=DEG_TRANS2(f);
    deg=DEG_TRANS4(g); 
    perm=NEW_PERM4(deg);
    ptp4=ADDR_PERM4(perm);
    ptf2=ADDR_TRANS2(f);
    ptg4=ADDR_TRANS4(g);
    for(i=0;i<deg;i++) ptp4[i]=i;
    for(i=0;i<def;i++) ptp4[ptf2[i]]=ptg4[i];
    for(;i<deg;i++)    ptp4[i]=ptg4[i];
    return perm;
  } else if(TNUM_OBJ(f)==T_TRANS4&&TNUM_OBJ(g)==T_TRANS2){ //def>deg
    def=DEG_TRANS4(f);
    deg=DEG_TRANS2(g); 
    perm=NEW_PERM4(def);
    ptp4=ADDR_PERM4(perm);
    ptf4=ADDR_TRANS4(f);
    ptg2=ADDR_TRANS2(g);
    for(i=0;i<def;i++) ptp4[i]=i;
    for(i=0;i<deg;i++) ptp4[ptf4[i]]=ptg2[i];
    for(;i<def;i++)    ptp4[ptf4[i]]=i; 
    return perm;
  } else if(TNUM_OBJ(f)==T_TRANS4&&TNUM_OBJ(g)==T_TRANS4){
    def=DEG_TRANS4(f); 
    deg=DEG_TRANS4(g);
    if(def<=deg){
      perm=NEW_PERM4(deg);
      ptp4=ADDR_PERM4(perm);
      ptf4=ADDR_TRANS4(f);
      ptg4=ADDR_TRANS4(g);
      for(i=0;i<deg;i++) ptp4[i]=i;
      for(i=0;i<def;i++) ptp4[ptf4[i]]=ptg4[i];
      for(;i<deg;i++)    ptp4[i]=ptg4[i];
    } else { //def>deg
      perm=NEW_PERM4(def);
      ptp4=ADDR_PERM4(perm);
      ptf4=ADDR_TRANS4(f);
      ptg4=ADDR_TRANS4(g);
      for(i=0;i<def;i++) ptp4[i]=i;
      for(i=0;i<deg;i++) ptp4[ptf4[i]]=ptg4[i];
      for(;i<def;i++)    ptp4[ptf4[i]]=i; 
    }
    return perm;
  }
  return Fail;
}

/* transformation from image set and flat kernel, no checking*/
Obj FuncTRANS_IMG_KER_NC(Obj self, Obj img, Obj ker){
  UInt    deg=LEN_LIST(ker);
  Obj     f;
  UInt2*  ptf2;
  UInt4*  ptf4;
  UInt    i;
  
  if(deg<=65536){
    f=NEW_TRANS2(deg);
    ptf2=ADDR_TRANS2(f);
    for(i=0;i<deg;i++){
      ptf2[i]=INT_INTOBJ(ELM_LIST(img, INT_INTOBJ(ELM_LIST(ker, i+1))))-1;
    }
  }else{
    f=NEW_TRANS4(deg);
    ptf4=ADDR_TRANS4(f);
    for(i=0;i<deg;i++){
      ptf4[i]=INT_INTOBJ(ELM_LIST(img, INT_INTOBJ(ELM_LIST(ker, i+1))))-1;
    }   
  }
  IMG_TRANS(f)=img;
  KER_TRANS(f)=ker;
  CHANGED_BAG(f);
  return f;
}

/* idempotent from image set and flat kernel, no checking.
*  Note that this is not the same as the previous function */

Obj FuncIDEM_IMG_KER_NC(Obj self, Obj img, Obj ker){
  UInt    deg=LEN_LIST(ker);
  UInt    rank=LEN_LIST(img);
  Obj     f;
  UInt2   *ptf2;
  UInt4   *ptf4, *pttmp;
  UInt    i, j;
  
  if(!IS_PLIST(img)) PLAIN_LIST(img);
  if(!IS_PLIST(ker)) PLAIN_LIST(ker);
    
  if(IS_MUTABLE_OBJ(img)) RetypeBag(img, TNUM_OBJ(img)+IMMUTABLE);
  if(IS_MUTABLE_OBJ(ker)) RetypeBag(ker, TNUM_OBJ(ker)+IMMUTABLE);

  ResizeTmpTrans(deg);
  pttmp=(UInt4*)(ADDR_OBJ(TmpTrans));
  
  // setup the lookup table
  for(i=0;i<rank;i++){
    j=INT_INTOBJ(ELM_PLIST(img, i+1));
    pttmp[INT_INTOBJ(ELM_PLIST(ker, j))-1]=j-1;
  }
  if(deg<=65536){
    f=NEW_TRANS2(deg);
    ptf2=ADDR_TRANS2(f);
    pttmp=(UInt4*)(ADDR_OBJ(TmpTrans)); 

    for(i=0;i<deg;i++) ptf2[i]=pttmp[INT_INTOBJ(ELM_PLIST(ker, i+1))-1];
  }else{
    f=NEW_TRANS4(deg);
    ptf4=ADDR_TRANS4(f);
    pttmp=(UInt4*)(ADDR_OBJ(TmpTrans)); 
    
    for(i=0;i<deg;i++) ptf4[i]=pttmp[INT_INTOBJ(ELM_PLIST(ker, i+1))-1];
  }
  IMG_TRANS(f)=img;
  KER_TRANS(f)=ker;
  CHANGED_BAG(f);
  return f;
}

/* an inverse of a transformation f*g*f=f and g*f*g=g */

Obj FuncINV_TRANS(Obj self, Obj f){
  UInt2   *ptf2, *ptg2;
  UInt4   *ptf4, *ptg4;
  UInt    deg, i;
  Obj     g;

  if(FuncIS_ID_TRANS(self, f)==True) return f;

  if(TNUM_OBJ(f)==T_TRANS2){
    deg=DEG_TRANS2(f);
    g=NEW_TRANS2(deg);
    ptf2=ADDR_TRANS2(f);
    ptg2=ADDR_TRANS2(g);
    for(i=0;i<deg;i++) ptg2[i]=0;
    for(i=deg-1;i>0;i--) ptg2[ptf2[i]]=i;
    /* to ensure that 1 is in the image and so rank of g equals that of f*/
    ptg2[ptf2[0]]=0;
  }else{
    deg=DEG_TRANS4(f);
    g=NEW_TRANS4(deg);
    ptf4=ADDR_TRANS4(f);
    ptg4=ADDR_TRANS4(g);
    for(i=0;i<deg;i++) ptg4[i]=0;
    for(i=deg-1;i>0;i--) ptg4[ptf4[i]]=i;
    /* to ensure that 1 is in the image and so rank of g equals that of f*/
    ptg4[ptf4[0]]=0;
  }
  return g;
}

/* a transformation g such that g: i^f -> i for all i in list 
 * where it is supposed that f is injective on list */
// JDM double-check
Obj FuncINV_LIST_TRANS(Obj self, Obj list, Obj f){
  UInt2   *ptf2, *ptg2; 
  UInt4   *ptf4, *ptg4; 
  UInt    deg, i, j;
  Obj     g;

  if(TNUM_OBJ(f)==T_TRANS2){
    deg=DEG_TRANS2(f);      
    g=NEW_TRANS2(deg);
    ptf2=ADDR_TRANS2(f);
    ptg2=ADDR_TRANS2(g);
    
    for(j=0;j<deg;j++) ptg2[j]=j;
    for(j=1;j<=(UInt) LEN_LIST(list);j++){
      i=INT_INTOBJ(ELM_LIST(list, j))-1;
      if(i<deg) ptg2[ptf2[i]]=i;
    }
    return g;
  }else if(TNUM_OBJ(f)==T_TRANS4){
    deg=DEG_TRANS4(f);      
    g=NEW_TRANS4(deg);
    ptf4=ADDR_TRANS4(f);
    ptg4=ADDR_TRANS4(g);
    
    i=INT_INTOBJ(ELM_LIST(list, 1))-1;
    for(j=0;j<deg;j++) ptg4[j]=j;
    for(j=1;j<=(UInt) LEN_LIST(list);j++){
      i=INT_INTOBJ(ELM_LIST(list, j))-1;
      if(i<deg) ptg4[ptf4[i]]=i;
    }
    return g;
  }
  return Fail;
}

/* returns the permutation p conjugating image set f to image set g 
 * when ker(f)=ker(g) so that gf^-1(i)=p(i). 
 * This is the same as MappingPermListList(IMAGE_TRANS(f), IMAGE_TRANS(g)); */
Obj FuncTRANS_IMG_CONJ(Obj self, Obj f, Obj g){
  Obj     perm;
  UInt2   *ptp2, *ptf2, *ptg2;
  UInt4   *ptsrc, *ptdst, *ptp4, *ptf4, *ptg4;
  UInt    def, deg, i, j;
  
  if(TNUM_OBJ(f)==T_TRANS2){
    def=DEG_TRANS2(f);
    if(TNUM_OBJ(g)==T_TRANS2){
      deg=DEG_TRANS2(g);
      if(def<=deg){
        perm=NEW_PERM2(deg);
        ptsrc=ResizeInitTmpTrans(2*deg);
        ptdst=ptsrc+deg;

        ptp2=ADDR_PERM2(perm);
        ptf2=ADDR_TRANS2(f);
        ptg2=ADDR_TRANS2(g);
        
        for(i=0;i<def;i++){
          ptsrc[ptf2[i]]=1;
          ptdst[ptg2[i]]=1;
          ptp2[ptf2[i]]=ptg2[i];
        }
        for(;i<deg;i++){
          //ptsrc[i]=1;
          ptdst[ptg2[i]]=1;
          ptp2[i]=ptg2[i];
        }
        j=0;
        for(i=0;i<def;i++){
          if(ptsrc[i]==0){
            while(ptdst[j]!=0){ j++; } 
            ptp2[i]=j;
            j++;
          }
        }
        return perm;
      } else {// def>deg
        perm=NEW_PERM2(def);
        ptsrc=ResizeInitTmpTrans(2*def);
        ptdst=ptsrc+def;
        
        ptp2=ADDR_PERM2(perm);
        ptf2=ADDR_TRANS2(f);
        ptg2=ADDR_TRANS2(g);
        
        for(i=0;i<deg;i++){
          ptsrc[ptf2[i]]=1;
          ptdst[ptg2[i]]=1;
          ptp2[ptf2[i]]=ptg2[i];
        }
        for(;i<def;i++){
          ptsrc[ptf2[i]]=1;
          ptdst[i]=1;
          ptp2[ptf2[i]]=i;
        }
        j=0;
        for(i=0;i<def;i++){
          if(ptsrc[i]==0){
            while(ptdst[j]!=0){ j++; } 
            ptp2[i]=j;
            j++;
          }
        }
        return perm;
      }      
    } else if (TNUM_OBJ(g)==T_TRANS4){ //deg>def
      deg=DEG_TRANS4(g);
      perm=NEW_PERM4(deg);
      ptsrc=ResizeInitTmpTrans(2*deg);
      ptdst=ptsrc+deg;

      ptp4=ADDR_PERM4(perm);
      ptf2=ADDR_TRANS2(f);
      ptg4=ADDR_TRANS4(g);
      
      for(i=0;i<def;i++){
        ptsrc[ptf2[i]]=1;
        ptdst[ptg4[i]]=1;
        ptp4[ptf2[i]]=ptg4[i];
      }
      for(;i<deg;i++){
        //ptsrc[i]=1;
        ptdst[ptg4[i]]=1;
        ptp4[i]=ptg4[i];
      }
      j=0;
      for(i=0;i<def;i++){
        if(ptsrc[i]==0){
          while(ptdst[j]!=0){ j++; } 
          ptp4[i]=j;
          j++;
        }
      }
      return perm;
    }
  } else if (TNUM_OBJ(f)==T_TRANS4) { 
    def=DEG_TRANS4(f);

    if(TNUM_OBJ(g)==T_TRANS2){ //def>deg
      deg=DEG_TRANS2(g);
      perm=NEW_PERM4(def);
      
      ptsrc=ResizeInitTmpTrans(2*def);
      ptdst=ptsrc+def;
      ptp4=ADDR_PERM4(perm);
      ptf4=ADDR_TRANS4(f);
      ptg2=ADDR_TRANS2(g);
      
      for(i=0;i<deg;i++){
        ptsrc[ptf4[i]]=1;
        ptdst[ptg2[i]]=1;
        ptp4[ptf4[i]]=ptg2[i];
      }
      for(;i<def;i++){
        ptsrc[ptf4[i]]=1;
        ptdst[i]=1;
        ptp4[ptf4[i]]=i;
      }
      j=0;
      for(i=0;i<def;i++){
        if(ptsrc[i]==0){
          while(ptdst[j]!=0){ j++; } 
          ptp4[i]=j;
          j++;
        }
      }
      return perm;
    } else if (TNUM_OBJ(g)==T_TRANS4){
      deg=DEG_TRANS4(g);
      if(def<=deg){
        perm=NEW_PERM4(deg);
        ptsrc=ResizeInitTmpTrans(2*deg);
        ptdst=ptsrc+deg;

        ptp4=ADDR_PERM4(perm);
        ptf4=ADDR_TRANS4(f);
        ptg4=ADDR_TRANS4(g);
        
        for(i=0;i<def;i++){
          ptsrc[ptf4[i]]=1;
          ptdst[ptg4[i]]=1;
          ptp4[ptf4[i]]=ptg4[i];
        }
        for(;i<deg;i++){
          //ptsrc[i]=1;
          ptdst[ptg4[i]]=1;
          ptp4[i]=ptg4[i];
        }
        j=0;
        for(i=0;i<def;i++){
          if(ptsrc[i]==0){
            while(ptdst[j]!=0){ j++; } 
            ptp4[i]=j;
            j++;
          }
        }
        return perm;
      } else {// def>deg
        perm=NEW_PERM4(def);
        ptsrc=ResizeInitTmpTrans(2*def);
        ptdst=ptsrc+def;
        
        ptp4=ADDR_PERM4(perm);
        ptf4=ADDR_TRANS4(f);
        ptg4=ADDR_TRANS4(g);
        
        for(i=0;i<deg;i++){
          ptsrc[ptf4[i]]=1;
          ptdst[ptg4[i]]=1;
          ptp4[ptf4[i]]=ptg4[i];
        }
        for(;i<def;i++){
          ptsrc[ptf4[i]]=1;
          ptdst[i]=1;
          ptp4[ptf4[i]]=i;
        }
        j=0;
        for(i=0;i<def;i++){
          if(ptsrc[i]==0){
            while(ptdst[j]!=0){ j++; } 
            ptp4[i]=j;
            j++;
          }
        }
        return perm;
      }      
    }
  }
  return Fail;
}

/* the least m, r such that f^m+r=f^m */

Obj FuncINDEX_PERIOD_TRANS(Obj self, Obj f){
  UInt2   *ptf2;
  UInt4   *ptf4, *ptseen, *ptlast, *ptcurrent, *tmp; 
  UInt    deg, i, current, last, pow, len, j;
  Obj     ord, out;
  Int     s, t, gcd;
 
  deg=DEG_TRANS(f);
  
  ResizeTmpTrans(3*deg);
  
  ptseen=(UInt4*)(ADDR_OBJ(TmpTrans));
  ptlast=(UInt4*)(ADDR_OBJ(TmpTrans))+deg;
  ptcurrent=(UInt4*)(ADDR_OBJ(TmpTrans))+2*deg;
  
  if(TNUM_OBJ(f)==T_TRANS2){
    ptf2=ADDR_TRANS2(f);
    last=deg; current=0; 
    for(i=0;i<deg;i++){ptseen[i]=0; ptcurrent[i]=0; ptlast[i]=i; }
    
    for(i=0;i<last;i++){ /* loop over the last image */
      if(ptseen[ptf2[ptlast[i]]]==0){
        ptseen[ptf2[ptlast[i]]]=1;
        ptcurrent[current++]=ptf2[ptlast[i]];
      }
      /* ptcurrent holds the image set of f^pow (unsorted) */
      /* ptseen is a lookup for membership in ptcurrent */
    }

    /* find least power of f which is a permutation of its image */
    for(pow=1;pow<=deg;){ 
      last=current; current=0; tmp=ptlast;
      ptlast=ptcurrent; ptcurrent=tmp;

      for(i=0;i<deg;i++){ ptseen[i]=0; ptcurrent[i]=0;}
      
      for(i=0;i<last;i++){ /* loop over the last image */
        if(ptseen[ptf2[ptlast[i]]]==0){
          ptseen[ptf2[ptlast[i]]]=1;
          ptcurrent[current++]=ptf2[ptlast[i]];
        }
        /* ptcurrent holds the image set of f^pow (unsorted) */
        /* ptseen is a lookup for membership in ptcurrent */
      }
      if(last==current) break;
      pow++;
    }

    /* find the order of the perm induced by f on im_set(f^pow) */
    /* clear the buffer bag (ptlast) */
    for(i=0;i<deg;i++) ptlast[i]=0;
    ord=INTOBJ_INT(1);
    /* loop over all cycles */
    for(i=0;i<deg;i++){
      /* if we haven't looked at this cycle so far */
      if(ptlast[i]==0&&ptseen[i]!=0&&ptf2[i]!=i){

        /* find the length of this cycle                           */
        len=1;
        for(j=ptf2[i];j!=i;j=ptf2[j]){ len++; ptlast[j]=1; }

        /* compute the gcd with the previously order ord           */
        gcd=len;  s=INT_INTOBJ(ModInt(ord,INTOBJ_INT(len)));
        while (s!= 0){ t=s;  s=gcd%s;  gcd=t; }
        ord=ProdInt(ord,INTOBJ_INT(len/gcd));
      }
    }
    out=NEW_PLIST(T_PLIST_CYC, 2);
    SET_LEN_PLIST(out, 2);
    SET_ELM_PLIST(out, 1, INTOBJ_INT(pow));
    SET_ELM_PLIST(out, 2, ord);
    return out;
  } else if(TNUM_OBJ(f)==T_TRANS4){
    ptf4=ADDR_TRANS4(f);
    last=deg; current=0; 
    for(i=0;i<deg;i++){ ptseen[i]=0; ptcurrent[i]=0; ptlast[i]=i; }
    
    for(i=0;i<last;i++){ /* loop over the last image */
      if(ptseen[ptf4[ptlast[i]]]==0){
        ptseen[ptf4[ptlast[i]]]=1;
        ptcurrent[current++]=ptf4[ptlast[i]];
      }
      /* ptcurrent holds the image set of f^pow (unsorted) */
      /* ptseen is a lookup for membership in ptcurrent */
    }

    /* find least power of f which is a permutation of its image */
    for(pow=1;pow<=deg;){ 
      last=current; current=0; tmp=ptlast;
      ptlast=ptcurrent; ptcurrent=tmp;

      for(i=0;i<deg;i++){ptseen[i]=0; ptcurrent[i]=0;}
      
      for(i=0;i<last;i++){ /* loop over the last image */
        if(ptseen[ptf4[ptlast[i]]]==0){
          ptseen[ptf4[ptlast[i]]]=1;
          ptcurrent[current++]=ptf4[ptlast[i]];
        }
        /* ptcurrent holds the image set of f^pow (unsorted) */
        /* ptseen is a lookup for membership in ptcurrent */
      }
      if(last==current) break;
      pow++;
    }
    
    /* find the order of the perm induced by f on im_set(f^pow) */

    /* clear the buffer bag (ptlast) */
    for(i=0;i<deg;i++) ptlast[i]=0;
    ord=INTOBJ_INT(1);
    
    /* loop over all cycles */
    for(i=0;i<deg;i++){
      /* if we haven't looked at this cycle so far */
      if(ptlast[i]==0&&ptseen[i]!=0&&ptf4[i]!=i){
        /* find the length of this cycle                           */
        len=1;
        for(j=ptf4[i];j!=i;j=ptf4[j]){ len++; ptlast[j]=1; }

        /* compute the gcd with the previously order ord           */
        /* Note that since len is single precision, ord % len is to*/
        gcd=len;  s=INT_INTOBJ(ModInt(ord,INTOBJ_INT(len)));
        while (s!= 0){ t=s;  s=gcd%s;  gcd=t; }
        ord=ProdInt(ord,INTOBJ_INT(len/gcd));
      }
    }
    out=NEW_PLIST(T_PLIST_CYC, 2);
    SET_LEN_PLIST(out, 2);
    SET_ELM_PLIST(out, 1, INTOBJ_INT(pow));
    SET_ELM_PLIST(out, 2, ord);
    return out;
  }
  return Fail;
}

/* the least power of <f> which is an idempotent */

Obj FuncSMALLEST_IDEM_POW_TRANS( Obj self, Obj f ){
  Obj x, ind, per, pow;

  x=FuncINDEX_PERIOD_TRANS(self, f);
  ind=ELM_PLIST(x, 1);
  per=ELM_PLIST(x, 2);
  pow=per;
  while(LtInt(pow, ind)) pow=SumInt(pow, per);
  return pow;
}

// the kernel of <f^p> where ker(f)=<ker> (where the length of the output equals
// the length of <ker>), assumes that <p> is a permutation of <[1..Length(ker)]>
// regardless of its degree
Obj FuncPOW_KER_PERM(Obj self, Obj ker, Obj p){
  UInt    len, rank, i, dep;
  Obj     out;
  UInt4   *ptcnj, *ptlkp, *ptp4;
  UInt2   *ptp2;
  
  len=LEN_LIST(ker);
  if(len==0){
    out=NEW_PLIST(T_PLIST_EMPTY+IMMUTABLE, len);
    SET_LEN_PLIST(out, len);
    return out;
  } else {
    out=NEW_PLIST(T_PLIST_CYC+IMMUTABLE, len);
    SET_LEN_PLIST(out, len);
  }
  
  ResizeTmpTrans(2*len);
  ptcnj = (UInt4*) ADDR_OBJ(TmpTrans);
  
  rank  = 1;
  ptlkp = ptcnj+len;
  
  if(TNUM_OBJ(p)==T_PERM2){
    dep  = DEG_PERM2(p);
    ptp2 = ADDR_PERM2(p);
    
    if(dep<=len){
      // form the conjugate in ptcnj and init the lookup
      for(i=0;i<dep;i++){ //<p^-1*g*p> then <g> with ker(<g>)=<ker>
        ptcnj[ptp2[i]]=ptp2[INT_INTOBJ(ELM_LIST(ker, i+1))-1]; 
        ptlkp[i]=0;
      }
      for(;i<len;i++){
        ptcnj[i]=IMAGE((UInt) INT_INTOBJ(ELM_LIST(ker, i+1))-1, ptp2, dep);
        ptlkp[i]=0;
      }

    }else{ //dep>len but p fixes [1..len] setwise
     
      // form the conjugate in ptcnj and init the lookup
      for(i=0;i<len;i++){ //<p^-1*g*p> then <g> with ker(<g>)=<ker>
        ptcnj[ptp2[i]]=ptp2[INT_INTOBJ(ELM_LIST(ker, i+1))-1]; 
        ptlkp[i]=0;
      }
    }
    
    // form the flat kernel
    for(i=0;i<len;i++){
      if(ptlkp[ptcnj[i]]==0) ptlkp[ptcnj[i]]=rank++;
      SET_ELM_PLIST(out, i+1, INTOBJ_INT(ptlkp[ptcnj[i]]));
    }
    return out;
  } else if(TNUM_OBJ(p)==T_PERM4){
    dep  = DEG_PERM4(p);
    ptp4 = ADDR_PERM4(p);
    
    if(dep<=len){
      // form the conjugate in ptcnj and init the lookup
      for(i=0;i<dep;i++){ //<p^-1*g*p> then <g> with ker(<g>)=<ker>
        ptcnj[ptp4[i]]=ptp4[INT_INTOBJ(ELM_LIST(ker, i+1))-1]; 
        ptlkp[i]=0;
      }
      for(;i<len;i++){
        ptcnj[i]=IMAGE((UInt) INT_INTOBJ(ELM_LIST(ker, i+1))-1, ptp4, dep);
        ptlkp[i]=0;
      }

    }else{ //dep>len but p fixes [1..len] setwise
     
      // form the conjugate in ptcnj and init the lookup
      for(i=0;i<len;i++){ //<p^-1*g*p> then <g> with ker(<g>)=<ker>
        ptcnj[ptp4[i]]=ptp4[INT_INTOBJ(ELM_LIST(ker, i+1))-1]; 
        ptlkp[i]=0;
      }
    }
    
    // form the flat kernel
    for(i=0;i<len;i++){
      if(ptlkp[ptcnj[i]]==0) ptlkp[ptcnj[i]]=rank++;
      SET_ELM_PLIST(out, i+1, INTOBJ_INT(ptlkp[ptcnj[i]]));
    }
    return out;
  }
  ErrorQuit("usage: the second argument must be a transformation,", 0L, 0L);
  return Fail;
}

// the kernel obtained by multiplying f by any g with ker(g)=ker
Obj FuncON_KERNEL_ANTI_ACTION(Obj self, Obj ker, Obj f, Obj n){
  UInt2   *ptf2;
  UInt4   *ptf4, *pttmp;
  UInt    deg, i, j, rank, len;
  Obj     out;

  if(INT_INTOBJ(ELM_LIST(ker, LEN_LIST(ker)))==0){ 
    return FuncFLAT_KERNEL_TRANS_INT(self, f, n);
  }

  len=LEN_LIST(ker);
  
  rank=1;
  
  if(TNUM_OBJ(f)==T_TRANS2){
    deg=INT_INTOBJ(FuncDegreeOfTransformation(self,f));
    if(len>=deg){
      out=NEW_PLIST(T_PLIST_CYC+IMMUTABLE, len);
      SET_LEN_PLIST(out, len);
      pttmp=ResizeInitTmpTrans(len);
      ptf2=ADDR_TRANS2(f);
      for(i=0;i<deg;i++){ //<f> then <g> with ker(<g>)=<ker>
        j=INT_INTOBJ(ELM_LIST(ker, ptf2[i]+1))-1; // f first!
        if(pttmp[j]==0) pttmp[j]=rank++;
        SET_ELM_PLIST(out, i+1, INTOBJ_INT(pttmp[j]));
      }
      i++;
      for(;i<=len;i++){   //just <ker>
        j=INT_INTOBJ(ELM_LIST(ker,i))-1;
        if(pttmp[j]==0) pttmp[j]=rank++;
        SET_ELM_PLIST(out, i, INTOBJ_INT(pttmp[j]));
      }
    } else {//len<deg
      out=NEW_PLIST(T_PLIST_CYC+IMMUTABLE, deg);
      SET_LEN_PLIST(out, deg);
      pttmp=ResizeInitTmpTrans(deg);
      ptf2=ADDR_TRANS2(f);
      for(i=0;i<len;i++){  //<f> then <g> with ker(<g>)=<ker>
        j=INT_INTOBJ(ELM_LIST(ker, ptf2[i]+1))-1; // f first!
        if(pttmp[j]==0) pttmp[j]=rank++;
        SET_ELM_PLIST(out, i+1, INTOBJ_INT(pttmp[j]));
      }
      for(;i<deg;i++){//assume g acts as identity on i
	if(ptf2[i]+1<=len) {  //refers to a class in ker
	  j=INT_INTOBJ(ELM_LIST(ker, ptf2[i]+1))-1;
	  if(pttmp[j]==0) pttmp[j]=rank++;
	  SET_ELM_PLIST(out, i+1, INTOBJ_INT(pttmp[j]));
	} else {  //refers to a class outside ker
	  if(pttmp[ptf2[i]]==0) pttmp[ptf2[i]]=rank++;
	  SET_ELM_PLIST(out, i+1, INTOBJ_INT(pttmp[ptf2[i]]));
	}
      }
    }
  } else { 
    deg=INT_INTOBJ(FuncDegreeOfTransformation(self,f));
    if(len>=deg){
      out=NEW_PLIST(T_PLIST_CYC+IMMUTABLE, len);
      SET_LEN_PLIST(out, len);
      pttmp=ResizeInitTmpTrans(len);
      ptf4=ADDR_TRANS4(f);
      for(i=0;i<deg;i++){ //<f> then <g> with ker(<g>)=<ker>
        j=INT_INTOBJ(ELM_LIST(ker, ptf4[i]+1))-1; // f first!
        if(pttmp[j]==0) pttmp[j]=rank++;
        SET_ELM_PLIST(out, i+1, INTOBJ_INT(pttmp[j]));
      }
      i++;
      for(;i<=len;i++){   //just <ker>
        j=INT_INTOBJ(ELM_LIST(ker,i))-1;
        if(pttmp[j]==0) pttmp[j]=rank++;
        SET_ELM_PLIST(out, i, INTOBJ_INT(pttmp[j]));
      }
    } else {//len<deg
      out=NEW_PLIST(T_PLIST_CYC+IMMUTABLE, deg);
      SET_LEN_PLIST(out, deg);
      pttmp=ResizeInitTmpTrans(deg);
      ptf4=ADDR_TRANS4(f);
      for(i=0;i<len;i++){  //<f> then <g> with ker(<g>)=<ker>
        j=INT_INTOBJ(ELM_LIST(ker, ptf4[i]+1))-1; // f first!
        if(pttmp[j]==0) pttmp[j]=rank++;
        SET_ELM_PLIST(out, i+1, INTOBJ_INT(pttmp[j]));
      }
      for(;i<deg;i++){     //just <f>
	if(ptf4[i]+1<=len) {
	  j=INT_INTOBJ(ELM_LIST(ker, ptf4[i]+1))-1;
	  if(pttmp[j]==0) pttmp[j]=rank++;
	  SET_ELM_PLIST(out, i+1, INTOBJ_INT(pttmp[j]));
	} else {
	  if(pttmp[ptf4[i]]==0) pttmp[ptf4[i]]=rank++;
	  SET_ELM_PLIST(out, i+1, INTOBJ_INT(pttmp[ptf4[i]]));
	}
      }
    }
  }
  return out; 
}  

/* Let <x> be a transformation with <ker(x)=X> and <ker(fx)=f^ker(x)> has the
 * same number of classes as <ker(x)>. Then INV_KER_TRANS(X, f) returns a
 * transformation <g> such that <gf^ker(x)=ker(x)=ker(gfx)> and the action of
 * <gf> on <ker(x)> is the identity. 
 */

Obj FuncINV_KER_TRANS(Obj self, Obj X, Obj f){
  Obj     g;
  UInt2   *ptf2, *ptg2;
  UInt4   *pttmp, *ptf4, *ptg4;
  UInt    deg, i, len;
  
  len=LEN_LIST(X);
  ResizeTmpTrans(len);
  
  if(TNUM_OBJ(f)==T_TRANS2){
    deg=DEG_TRANS2(f);
    if(len<=65536){   // deg(g)<=65536 and g is T_TRANS2
      g=NEW_TRANS2(len);
      pttmp=(UInt4*)(ADDR_OBJ(TmpTrans));
      ptf2=ADDR_TRANS2(f);
      ptg2=ADDR_TRANS2(g);
      if(deg>=len){
        // calculate a transversal of f^ker(x)=ker(fx)
        for(i=0;i<len;i++)  pttmp[INT_INTOBJ(ELM_LIST(X, ptf2[i]+1))-1]=i;
        // install values in g
        for(i=len;i>=1;i--) ptg2[i-1]=pttmp[INT_INTOBJ(ELM_LIST(X, i))-1];
      }else{
        for(i=0;i<deg;i++)  pttmp[INT_INTOBJ(ELM_LIST(X, ptf2[i]+1))-1]=i;
        for(;i<len;i++)     pttmp[INT_INTOBJ(ELM_LIST(X, i+1))-1]=i;
        for(i=len;i>=1;i--) ptg2[i-1]=pttmp[INT_INTOBJ(ELM_LIST(X, i))-1];
      }
      return g;
    } else {        // deg(g)>65536 and g is T_TRANS4
      g=NEW_TRANS4(len);
      pttmp=(UInt4*)(ADDR_OBJ(TmpTrans));
      ptf2=ADDR_TRANS2(f);
      ptg4=ADDR_TRANS4(g);
      if(deg>=len){
        // calculate a transversal of f^ker(x)=ker(fx)
        for(i=0;i<len;i++)  pttmp[INT_INTOBJ(ELM_LIST(X, ptf2[i]+1))-1]=i;
        // install values in g
        for(i=len;i>=1;i--) ptg4[i-1]=pttmp[INT_INTOBJ(ELM_LIST(X, i))-1];
      }else{
        for(i=0;i<deg;i++)  pttmp[INT_INTOBJ(ELM_LIST(X, ptf2[i]+1))-1]=i;
        for(;i<len;i++)     pttmp[INT_INTOBJ(ELM_LIST(X, i+1))-1]=i;
        for(i=len;i>=1;i--) ptg4[i-1]=pttmp[INT_INTOBJ(ELM_LIST(X, i))-1];
      }
      return g;
    }
  } else if(TNUM_OBJ(f)==T_TRANS4){
    deg=DEG_TRANS4(f);
    if(len<=65536){   // deg(g)<=65536 and g is T_TRANS2
      g=NEW_TRANS2(len);
      pttmp=(UInt4*)(ADDR_OBJ(TmpTrans));
      ptf4=ADDR_TRANS4(f);
      ptg2=ADDR_TRANS2(g);
      if(deg>=len){
        // calculate a transversal of f^ker(x)=ker(fx)
        for(i=0;i<len;i++)  pttmp[INT_INTOBJ(ELM_LIST(X, ptf4[i]+1))-1]=i;
        // install values in g
        for(i=len;i>=1;i--) ptg2[i-1]=pttmp[INT_INTOBJ(ELM_LIST(X, i))-1];
      }else{
        for(i=0;i<deg;i++)  pttmp[INT_INTOBJ(ELM_LIST(X, ptf4[i]+1))-1]=i;
        for(;i<len;i++)     pttmp[INT_INTOBJ(ELM_LIST(X, i+1))-1]=i;
        for(i=len;i>=1;i--) ptg2[i-1]=pttmp[INT_INTOBJ(ELM_LIST(X, i))-1];
      }
      return g;
    } else {        // deg(g)>65536 and g is T_TRANS4
      g=NEW_TRANS4(len);
      pttmp=(UInt4*)(ADDR_OBJ(TmpTrans));
      ptf4=ADDR_TRANS4(f);
      ptg4=ADDR_TRANS4(g);
      if(deg>=len){
        // calculate a transversal of f^ker(x)=ker(fx)
        for(i=0;i<len;i++)  pttmp[INT_INTOBJ(ELM_LIST(X, ptf4[i]+1))-1]=i;
        // install values in g
        for(i=len;i>=1;i--) ptg4[i-1]=pttmp[INT_INTOBJ(ELM_LIST(X, i))-1];
      }else{
        for(i=0;i<deg;i++)  pttmp[INT_INTOBJ(ELM_LIST(X, ptf4[i]+1))-1]=i;
        for(;i<len;i++)     pttmp[INT_INTOBJ(ELM_LIST(X, i+1))-1]=i;
        for(i=len;i>=1;i--) ptg4[i-1]=pttmp[INT_INTOBJ(ELM_LIST(X, i))-1];
      }
      return g;
    }
  } else {
    ErrorQuit("usage: the second argument must be a transformation,", 0L, 0L);
  }
  return Fail;
}

/* test if a transformation is an idempotent. */

Obj FuncIS_IDEM_TRANS(Obj self, Obj f){
  UInt2*  ptf2;
  UInt4*  ptf4;
  UInt    deg, i;
  
  if(TNUM_OBJ(f)==T_TRANS2){
    deg=DEG_TRANS2(f);
    ptf2=ADDR_TRANS2(f);
    for(i=0;i<deg;i++){
      if(ptf2[ptf2[i]]!=ptf2[i]){
        return False;
      }
    }
  } else {
    deg=DEG_TRANS4(f);
    ptf4=ADDR_TRANS4(f);
    for(i=0;i<deg;i++){
      if(ptf4[ptf4[i]]!=ptf4[i]){
        return False;
      }
    }
  }
  return True;
}

/* returns the least list <out> such that for all <i> in [1..degree(f)]
 * there exists <j> in <out> and a pos int <k> such that <j^(f^k)=i>. */

Obj FuncCOMPONENT_REPS_TRANS(Obj self, Obj f){
  Obj     out;
  UInt2   *ptf2; 
  UInt4   *ptf4, *ptseen, *ptlookup, *ptlens, *ptimg;
  UInt    deg, i, nr, count, m, j, k;

  deg=INT_INTOBJ(FuncDegreeOfTransformation(self, f));
  
  ResizeTmpTrans(4*deg);
  out=NEW_PLIST(T_PLIST, deg);
  
  ptseen=(UInt4*)(ADDR_OBJ(TmpTrans));
  ptlookup=(UInt4*)(ADDR_OBJ(TmpTrans))+deg;
  ptlens=(UInt4*)(ADDR_OBJ(TmpTrans))+2*deg;
  ptimg=(UInt4*)(ADDR_OBJ(TmpTrans))+3*deg;
    
  for(i=0;i<deg;i++){ ptseen[i]=0; ptlookup[i]=0; ptlens[i]=0; ptimg[i]=0; }

  if(TNUM_OBJ(f)==T_TRANS2){
    ptf2=ADDR_TRANS2(f);
    
    /* points in the image of f */
    for(i=0;i<deg;i++) ptimg[ptf2[i]]=1; 

    nr=0; m=0; count=0;

    /* components corresponding to points not in image */
    for(i=0;i<deg;i++){
      if(ptimg[i]==0&&ptseen[i]==0){
        m++;
        for(j=i;ptseen[j]==0;j=ptf2[j]){ ptseen[j]=m; count++;} 
        if(ptseen[j]==m){/* new component */
          k=nr;
          ptlookup[m-1]=nr;
          SET_ELM_PLIST(out, ++nr, NEW_PLIST(T_PLIST_CYC_SSORT, deg-count));
          CHANGED_BAG(out);
          ptlens=(UInt4*)(ADDR_OBJ(TmpTrans))+2*deg;
        }else{ /* old component */
          k=ptlookup[ptseen[j]-1];
          ptlookup[m-1]=k;
        }
        AssPlist(ELM_PLIST(out, k+1), ++ptlens[k], INTOBJ_INT(i+1));
      }
      ptf2=ADDR_TRANS2(f);
      ptseen=(UInt4*)(ADDR_OBJ(TmpTrans));
      ptlookup=(UInt4*)(ADDR_OBJ(TmpTrans))+deg;
      ptlens=(UInt4*)(ADDR_OBJ(TmpTrans))+2*deg;
      ptimg=(UInt4*)(ADDR_OBJ(TmpTrans))+3*deg;
    }

    for(i=0;i<nr;i++){
      SHRINK_PLIST(ELM_PLIST(out, i+1), (Int) ptlens[i]);
      SET_LEN_PLIST(ELM_PLIST(out, i+1), (Int) ptlens[i]);
    }

    ptseen=(UInt4*)(ADDR_OBJ(TmpTrans));
    ptf2=ADDR_TRANS2(f);

    /* components corresponding to cycles */
    for(i=0;i<deg;i++){
      if(ptseen[i]==0){
        for(j=ptf2[i];j!=i;j=ptf2[j]) ptseen[j]=1;
        
        SET_ELM_PLIST(out, ++nr, NEW_PLIST(T_PLIST_CYC_SSORT, 1));
        SET_LEN_PLIST(ELM_PLIST(out, nr), 1);
        SET_ELM_PLIST(ELM_PLIST(out, nr), 1, INTOBJ_INT(i+1));
        CHANGED_BAG(out);
        
        ptseen=(UInt4*)(ADDR_OBJ(TmpTrans));
        ptf2=ADDR_TRANS2(f);
      }
    }
  } else {

    ptf4=ADDR_TRANS4(f);
    /* points in the image of f */
    for(i=0;i<deg;i++){ ptimg[ptf4[i]]=1; }

    nr=0; m=0; count=0;

    /* components corresponding to points not in image */
    for(i=0;i<deg;i++){
      if(ptimg[i]==0&&ptseen[i]==0){
        m++;
        for(j=i;ptseen[j]==0;j=ptf4[j]){ ptseen[j]=m; count++;} 
        if(ptseen[j]==m){/* new component */
          k=nr;
          ptlookup[m-1]=nr;
          SET_ELM_PLIST(out, ++nr, NEW_PLIST(T_PLIST_CYC_SSORT, deg-count));
          CHANGED_BAG(out);
          ptlens=(UInt4*)(ADDR_OBJ(TmpTrans))+2*deg;
        }else{ /* old component */
          k=ptlookup[ptseen[j]-1];
          ptlookup[m-1]=k;
        }
        AssPlist(ELM_PLIST(out, k+1), ++ptlens[k], INTOBJ_INT(i+1));
      }
      ptf4=ADDR_TRANS4(f); 
      ptseen=(UInt4*)(ADDR_OBJ(TmpTrans));
      ptlookup=(UInt4*)(ADDR_OBJ(TmpTrans))+deg;
      ptlens=(UInt4*)(ADDR_OBJ(TmpTrans))+2*deg;
      ptimg=(UInt4*)(ADDR_OBJ(TmpTrans))+3*deg;
    }

    for(i=0;i<nr-1;i++){
      SHRINK_PLIST(ELM_PLIST(out, i+1), (Int) ptlens[i]);
      SET_LEN_PLIST(ELM_PLIST(out, i+1), (Int) ptlens[i]);
    }
    
    ptseen=(UInt4*)(ADDR_OBJ(TmpTrans));
    ptf4=ADDR_TRANS4(f);

    /* components corresponding to cycles */
    for(i=0;i<deg;i++){
      if(ptseen[i]==0){
        for(j=ptf4[i];j!=i;j=ptf4[j]) ptseen[j]=1;
        
        SET_ELM_PLIST(out, ++nr, NEW_PLIST(T_PLIST_CYC_SSORT, 1));
        SET_LEN_PLIST(ELM_PLIST(out, nr), 1);
        SET_ELM_PLIST(ELM_PLIST(out, nr), 1, INTOBJ_INT(i+1));
        CHANGED_BAG(out);

        ptseen=(UInt4*)(ADDR_OBJ(TmpTrans));
        ptf4=ADDR_TRANS4(f);
      }
    }
  }
 
  SHRINK_PLIST(out, (Int) nr);
  SET_LEN_PLIST(out,  (Int) nr);
  return out;
}

/* the number of components of a transformation (as a functional digraph) */

Obj FuncNR_COMPONENTS_TRANS(Obj self, Obj f){
  UInt    nr, m, i, j, deg;
  UInt2   *ptf2;
  UInt4   *ptseen, *ptf4;
  
  deg=INT_INTOBJ(FuncDegreeOfTransformation(self, f));
  ptseen=ResizeInitTmpTrans(deg);
  nr=0; m=0;

  if(TNUM_OBJ(f)==T_TRANS2){
    ptf2=ADDR_TRANS2(f);
    for(i=0;i<deg;i++){
      if(ptseen[i]==0){
        m++;
        for(j=i;ptseen[j]==0;j=ptf2[j]) ptseen[j]=m; 
        if(ptseen[j]==m) nr++;
      }
    }
  }else{
    ptf4=ADDR_TRANS4(f);
    for(i=0;i<deg;i++){
      if(ptseen[i]==0){
        m++;
        for(j=i;ptseen[j]==0;j=ptf4[j]) ptseen[j]=m; 
        if(ptseen[j]==m) nr++;
      }
    }
  }
  return INTOBJ_INT(nr);
}

/* the components of a transformation (as a functional digraph) */

Obj FuncCOMPONENTS_TRANS(Obj self, Obj f){
  UInt    deg, i, nr, m, j;
  UInt2   *ptf2;
  UInt4   *ptseen, *ptlookup, *ptlens, *ptf4;
  Obj     out;
  
  deg=INT_INTOBJ(FuncDegreeOfTransformation(self, f));
  ResizeTmpTrans(3*deg);
  ptseen=(UInt4*)(ADDR_OBJ(TmpTrans));
  ptlookup=(UInt4*)(ADDR_OBJ(TmpTrans))+deg;
  ptlens=(UInt4*)(ADDR_OBJ(TmpTrans))+2*deg;
  
  for(i=0;i<deg;i++){ ptseen[i]=0; ptlookup[i]=0; ptlens[i]=0; }

  nr=0; m=0;
  
  if(TNUM_OBJ(f)==T_TRANS2){
    //find components
    ptf2=ADDR_TRANS2(f);
    for(i=0;i<deg;i++){
      if(ptseen[i]==0){
        m++;
        for(j=i;ptseen[j]==0;j=ptf2[j]){ ptseen[j]=m; } 
        if(ptseen[j]==m){
          ptlookup[m-1]=nr++;
        }else{
          ptlookup[m-1]=ptlookup[ptseen[j]-1];
        }
      }
    }
  } else {
    //find components 
    ptf4=ADDR_TRANS4(f);
    for(i=0;i<deg;i++){
      if(ptseen[i]==0){
        m++;
        for(j=i;ptseen[j]==0;j=ptf4[j]){ ptseen[j]=m; } 
        if(ptseen[j]==m){
          ptlookup[m-1]=nr++;
        }else{
          ptlookup[m-1]=ptlookup[ptseen[j]-1];
        }
      }
    }
  }
  
  out=NEW_PLIST(T_PLIST, nr);
  SET_LEN_PLIST(out, (Int) nr);

  // install the points in out
  for(i=0;i<deg;i++){
    ptseen=(UInt4*)(ADDR_OBJ(TmpTrans));
    ptlookup=(UInt4*)(ADDR_OBJ(TmpTrans))+deg;
    ptlens=(UInt4*)(ADDR_OBJ(TmpTrans))+2*deg;
    
    m=ptlookup[ptseen[i]-1];
    if(ptlens[m]==0){
      SET_ELM_PLIST(out, m+1, NEW_PLIST(T_PLIST_CYC_SSORT, deg));
      CHANGED_BAG(out);
      ptlens=(UInt4*)(ADDR_OBJ(TmpTrans))+2*deg;
    }
    AssPlist(ELM_PLIST(out, m+1), (Int) ++ptlens[m], INTOBJ_INT(i+1));
  }
  
  ptlens=(UInt4*)(ADDR_OBJ(TmpTrans))+2*deg;
  for(i=0;i<nr;i++){
    SHRINK_PLIST(ELM_PLIST(out, i+1), (Int) ptlens[i]);
    SET_LEN_PLIST(ELM_PLIST(out, i+1), (Int) ptlens[i]);
  }
  return out;
}


Obj FuncCOMPONENT_TRANS_INT(Obj self, Obj f, Obj pt){
  UInt    deg, cpt, len;
  Obj     out;
  UInt2   *ptf2;
  UInt4   *ptseen, *ptf4;
    
  deg=INT_INTOBJ(FuncDegreeOfTransformation(self, f));
  cpt=INT_INTOBJ(pt)-1;
  
  if(cpt>=deg){
    out=NEW_PLIST(T_PLIST_CYC_SSORT, 1);
    SET_LEN_PLIST(out, 1);
    SET_ELM_PLIST(out, 1, pt);
    return out;
  }
  out=NEW_PLIST(T_PLIST_CYC, deg);
  ptseen=ResizeInitTmpTrans(deg);
  
  len=0;
  
  //install the points
  if(TNUM_OBJ(f)==T_TRANS2){
    ptf2=ADDR_TRANS2(f);
    do{ SET_ELM_PLIST(out, ++len, INTOBJ_INT(cpt+1));
        ptseen[cpt]=1;
        cpt=ptf2[cpt];
    }while(ptseen[cpt]==0);
  } else {
    ptf4=ADDR_TRANS4(f);
    do{ SET_ELM_PLIST(out, ++len, INTOBJ_INT(cpt+1));
        ptseen[cpt]=1;
        cpt=ptf4[cpt];
    }while(ptseen[cpt]==0);
  }
  SHRINK_PLIST(out, (Int) len);
  SET_LEN_PLIST(out, (Int) len);
  return out;
}

Obj FuncCYCLE_TRANS_INT(Obj self, Obj f, Obj pt){
  UInt    deg, cpt, len, i;
  Obj     out;
  UInt2   *ptf2;
  UInt4   *ptseen, *ptf4;
    
  deg=INT_INTOBJ(FuncDegreeOfTransformation(self, f));
  cpt=INT_INTOBJ(pt)-1;
  
  if(cpt>=deg){
    out=NEW_PLIST(T_PLIST_CYC_SSORT, 1);
    SET_LEN_PLIST(out, 1);
    SET_ELM_PLIST(out, 1, pt);
    return out;
  }
 
  out=NEW_PLIST(T_PLIST_CYC, deg);
  ptseen=ResizeInitTmpTrans(deg);
  len=0;
  
  if(TNUM_OBJ(f)==T_TRANS2){
    ptf2=ADDR_TRANS2(f);
    //find component 
    do{ ptseen[cpt]=1;
        cpt=ptf2[cpt];
    }while(ptseen[cpt]==0);
    //find cycle
    i=cpt;
    do{ SET_ELM_PLIST(out, ++len, INTOBJ_INT(i+1));
        i=ptf2[i];
    }while(i!=cpt);
  } else {
    ptf4=ADDR_TRANS4(f);
    //find component 
    do{ ptseen[cpt]=1;
        cpt=ptf4[cpt];
    }while(ptseen[cpt]==0);
    //find cycle
    i=cpt;
    do{ SET_ELM_PLIST(out, ++len, INTOBJ_INT(i+1));
        i=ptf4[i];
    }while(i!=cpt);
  }
  SHRINK_PLIST (out, (Int) len);
  SET_LEN_PLIST(out, (Int) len);
  return out;
}


Obj FuncCYCLES_TRANS_LIST(Obj self, Obj f, Obj list){
  UInt    deg, pt, len_list, len_out, i, j, m;
  Obj     out;
  UInt2   *ptf2;
  UInt4   *ptseen, *ptlens, *ptf4;
   
  deg=INT_INTOBJ(FuncDegreeOfTransformation(self, f));
  len_list=LEN_LIST(list);
 
  ResizeTmpTrans(deg+len_list);
  out=NEW_PLIST(T_PLIST, len_list);
  
  ptseen=(UInt4*)(ADDR_OBJ(TmpTrans));
  ptlens=(UInt4*)(ADDR_OBJ(TmpTrans))+deg;

  for(i=0;i<deg;i++){ ptseen[i]=0; ptlens[i]=0; }
  for(;i<len_list;i++){ ptlens[i]=0; }

  len_out=0; m=0;
  
  if(TNUM_OBJ(f)==T_TRANS2){
    for(i=1;i<=len_list;i++){
      pt=INT_INTOBJ(ELM_LIST(list, i))-1;
      if(pt>=deg){
        SET_ELM_PLIST(out, ++len_out, NEW_PLIST(T_PLIST_CYC, 1));
        SET_ELM_PLIST(ELM_PLIST(out, len_out), 1, INTOBJ_INT(pt+1));
        CHANGED_BAG(out);
        (((UInt4*)(ADDR_OBJ(TmpTrans))+deg)[len_out])++; //ptlens[len_out]++
      } else {
        m++;
        ptseen=(UInt4*)(ADDR_OBJ(TmpTrans));
        ptf2=ADDR_TRANS2(f);
        while(ptseen[pt]==0){ //look for pts already seen
          ptseen[pt]=m;
          pt=ptf2[pt];
        }
        if(ptseen[pt]==m){//new cycle
          j=pt;
          SET_ELM_PLIST(out, ++len_out, NEW_PLIST(T_PLIST_CYC, 32));
          CHANGED_BAG(out);
          ptlens=(UInt4*)(ADDR_OBJ(TmpTrans))+deg;
          do{ AssPlist(ELM_PLIST(out, len_out), ++ptlens[len_out], 
               INTOBJ_INT(j+1));
              j=(ADDR_TRANS2(f))[j];
              ptlens=(UInt4*)(ADDR_OBJ(TmpTrans))+deg;
          }while(j!=pt);
        }
      }
    }
  } else {
    for(i=1;i<=len_list;i++){
      pt=INT_INTOBJ(ELM_LIST(list, i))-1;
      if(pt>=deg){
        SET_ELM_PLIST(out, ++len_out, NEW_PLIST(T_PLIST_CYC, 1));
        SET_ELM_PLIST(ELM_PLIST(out, len_out), 1, INTOBJ_INT(pt+1));
        CHANGED_BAG(out);
        (((UInt4*)(ADDR_OBJ(TmpTrans))+deg)[len_out])++; //ptlens[len_out]++
      } else {
        m++;
        ptseen=(UInt4*)(ADDR_OBJ(TmpTrans));
        ptf4=ADDR_TRANS4(f);
        while(ptseen[pt]==0){ //look for pts already seen
          ptseen[pt]=m;
          pt=ptf4[pt];
        }
        if(ptseen[pt]==m){//new cycle
          j=pt;
          SET_ELM_PLIST(out, ++len_out, NEW_PLIST(T_PLIST_CYC, 32));
          CHANGED_BAG(out);
          ptlens=(UInt4*)(ADDR_OBJ(TmpTrans))+deg;
          do{ AssPlist(ELM_PLIST(out, len_out), ++ptlens[len_out], 
               INTOBJ_INT(j+1));
              j=(ADDR_TRANS4(f))[j];
              ptlens=(UInt4*)(ADDR_OBJ(TmpTrans))+deg;
          }while(j!=pt);
        }
      }
    }
  }
  ptlens=(UInt4*)(ADDR_OBJ(TmpTrans))+deg;
  for(i=1;i<=len_out;i++){
    SHRINK_PLIST (ELM_PLIST(out, i), (Int) ptlens[i]);
    SET_LEN_PLIST(ELM_PLIST(out, i), (Int) ptlens[i]);
  }
  SHRINK_PLIST (out, (Int) len_out);
  SET_LEN_PLIST(out, (Int) len_out);
  return out;
}

/* an idempotent transformation <e> with ker(e)=ker(f) */
Obj FuncLEFT_ONE_TRANS( Obj self, Obj f){
  Obj   ker, img;
  UInt  rank, n, i;

  if(TNUM_OBJ(f)==T_TRANS2){
    rank=RANK_TRANS2(f);
    ker=KER_TRANS(f);
  } else {
    rank=RANK_TRANS4(f);
    ker=KER_TRANS(f);
  }
  img=NEW_PLIST(T_PLIST_CYC, rank);
  n=1;

  for(i=1;n<=rank;i++){
    if((UInt) INT_INTOBJ(ELM_PLIST(ker, i))==n){
      SET_ELM_PLIST(img, n++, INTOBJ_INT(i));
    }
  }
  
  SET_LEN_PLIST(img, (Int) n-1);
  return FuncIDEM_IMG_KER_NC(self, img, ker);
}

/* an idempotent transformation <e> with im(e)=im(f) */
Obj FuncRIGHT_ONE_TRANS( Obj self, Obj f){
  Obj   ker, img;
  UInt  deg, len, i, j, n;

  if(TNUM_OBJ(f)==T_TRANS2){
    deg=DEG_TRANS2(f);
  } else {
    deg=DEG_TRANS4(f);
  }

  img=FuncIMAGE_SET_TRANS(self, f);
  ker=NEW_PLIST(T_PLIST_CYC, deg);
  SET_LEN_PLIST(ker, deg);
  len=LEN_PLIST(img);
  j=1; n=0;

  for(i=0;i<deg;i++){
    if(j<len&&i+1==(UInt) INT_INTOBJ(ELM_PLIST(img, j+1))) j++;
    SET_ELM_PLIST(ker, ++n, INTOBJ_INT(j));
  }
  return FuncIDEM_IMG_KER_NC(self, img, ker);
}

//
Obj FuncIsCommutingTransformation( Obj self, Obj f, Obj g ){
  UInt    def, deg, i;
  UInt2   *ptf2, *ptg2;
  UInt4   *ptf4, *ptg4;

  if(TNUM_OBJ(f)==T_TRANS2){
    def=DEG_TRANS2(f);
    ptf2=ADDR_TRANS2(f);
    if(TNUM_OBJ(g)==T_TRANS2){
      deg=DEG_TRANS2(g);
      ptg2=ADDR_TRANS2(g);
      if(def<deg){
        for(i=0;i<def;i++){
          if(ptf2[ptg2[i]]!=ptg2[ptf2[i]]){
            return False;
          }
        }
        for(;i<deg;i++){
          if(IMAGE(ptg2[i], ptf2, def)!=ptg2[i]){
            return False;
          }
        }
        return True;
      }else{
        for(i=0;i<deg;i++){
          if(ptf2[ptg2[i]]!=ptg2[ptf2[i]]){
            return False;
          }
        }
        for(;i<def;i++){
          if(IMAGE(ptf2[i], ptg2, deg)!=ptf2[i]){
            return False;
          }
        }
      }
    } else if(TNUM_OBJ(g)==T_TRANS4){
      deg=DEG_TRANS4(g);
      ptg4=ADDR_TRANS4(g);
      if(def<deg){
        for(i=0;i<def;i++){
          if(ptf2[ptg4[i]]!=ptg4[ptf2[i]]){
            return False;
          }
        }
        for(;i<deg;i++){
          if(IMAGE(ptg4[i], ptf2, def)!=ptg4[i]){
            return False;
          }
        }
        return True;
      }else{
        for(i=0;i<deg;i++){
          if(ptf2[ptg4[i]]!=ptg4[ptf2[i]]){
            return False;
          }
        }
        for(;i<def;i++){
          if(IMAGE(ptf2[i], ptg4, deg)!=ptf2[i]){
            return False;
          }
        }
      }
    } else {
      ErrorQuit("usage: the arguments must be transformations,", 0L, 0L);
    }
  } else if (TNUM_OBJ(f)==T_TRANS4){
    def=DEG_TRANS4(f);
    ptf4=ADDR_TRANS4(f);
    if(TNUM_OBJ(g)==T_TRANS2){
      deg=DEG_TRANS2(g);
      ptg2=ADDR_TRANS2(g);
      if(def<deg){
        for(i=0;i<def;i++){
          if(ptf4[ptg2[i]]!=ptg2[ptf4[i]]){
            return False;
          }
        }
        for(;i<deg;i++){
          if(IMAGE(ptg2[i], ptf4, def)!=ptg2[i]){
            return False;
          }
        }
        return True;
      }else{
        for(i=0;i<deg;i++){
          if(ptf4[ptg2[i]]!=ptg2[ptf4[i]]){
            return False;
          }
        }
        for(;i<def;i++){
          if(IMAGE(ptf4[i], ptg2, deg)!=ptf4[i]){
            return False;
          }
        }
      }
    } else if(TNUM_OBJ(g)==T_TRANS4){
      deg=DEG_TRANS4(g);
      ptg4=ADDR_TRANS4(g);
      if(def<deg){
        for(i=0;i<def;i++){
          if(ptf4[ptg4[i]]!=ptg4[ptf4[i]]){
            return False;
          }
        }
        for(;i<deg;i++){
          if(IMAGE(ptg4[i], ptf4, def)!=ptg4[i]){
            return False;
          }
        }
        return True;
      }else{
        for(i=0;i<deg;i++){
          if(ptf4[ptg4[i]]!=ptg4[ptf4[i]]){
            return False;
          }
        }
        for(;i<def;i++){
          if(IMAGE(ptf4[i], ptg4, deg)!=ptf4[i]){
            return False;
          }
        }
      }
    }
  } else {
    ErrorQuit("usage: the arguments must be transformations,", 0L, 0L);
  }
  return True;
}
/****************************************************************************/

/* GAP kernel functions */

/* one for a transformation */
Obj OneTrans( Obj f ){
  return IdentityTrans;
}

/* equality for transformations */

// the following function is used to check equality of both permutations and
// transformations, it is written by Chris Jefferson in pull request #280

Int             EqPermTrans22 (UInt                degL,
                               UInt                degR, 
                               UInt2 *             ptLstart,       
                               UInt2 *             ptRstart) {
    
    UInt2 *             ptL;            /* pointer to the left operand     */
    UInt2 *             ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* if permutations are different sizes, check final element as
     * early check                                                         */

    if ( degL != degR ) {
      if ( degL < degR ) {
        if ( *(ptRstart + degR - 1) != (degR - 1) )
          return 0L;
      }
      else {
        if ( *(ptLstart + degL - 1) != (degL - 1) )
          return 0L;
      }
    }

    /* search for a difference and return False if you find one          */
    if ( degL <= degR ) {
      ptR = ptRstart + degL;
      for ( p = degL; p < degR; p++ )
          if ( *(ptR++) !=        p )
              return 0L;

        if(memcmp(ptLstart, ptRstart, degL * sizeof(UInt2)) != 0)
            return 0L;
    }
    else {
        ptL = ptLstart + degR;
        for ( p = degR; p < degL; p++ )
            if ( *(ptL++) !=        p )
                return 0L;
        if(memcmp(ptLstart, ptRstart, degR * sizeof(UInt2)) != 0)
          return 0L;
    }

    /* otherwise they must be equal                                        */
    return 1L;
}

Int             EqPermTrans44 (UInt                degL,
                               UInt                degR, 
                               UInt4 *             ptLstart,       
                               UInt4 *             ptRstart) {
    UInt4 *             ptL;            /* pointer to the left operand     */
    UInt4 *             ptR;            /* pointer to the right operand    */
    UInt                p;              /* loop variable                   */

    /* if permutations/transformation are different sizes, check final element
     * as early check */

    if ( degL != degR ) {
      if ( degL < degR ) {
        if ( *(ptRstart + degR - 1) != (degR - 1) )
          return 0L;
      }
      else {
        if ( *(ptLstart + degL - 1) != (degL - 1) )
          return 0L;
      }
    }
    
    /* search for a difference and return False if you find one          */
    if ( degL <= degR ) {
      ptR = ptRstart + degL;
      for ( p = degL; p < degR; p++ )
          if ( *(ptR++) !=        p )
              return 0L;
        
        if(memcmp(ptLstart, ptRstart, degL * sizeof(UInt4)) != 0)
            return 0L;
    }
    else {
        ptL = ptLstart + degR;
        for ( p = degR; p < degL; p++ )
            if ( *(ptL++) !=        p )
                return 0L;
        if(memcmp(ptLstart, ptRstart, degR * sizeof(UInt4)) != 0)
          return 0L;
    }

    /* otherwise they must be equal                                        */
    return 1L;
}

Int             EqTrans22 (Obj opL,
                           Obj opR ) {
  return EqPermTrans22(DEG_TRANS2(opL), 
                       DEG_TRANS2(opR), 
                       ADDR_TRANS2(opL),
                       ADDR_TRANS2(opR));
}

Int             EqTrans44 (
    Obj                 opL,
    Obj                 opR ) {
  return EqPermTrans44(DEG_TRANS4(opL), 
                       DEG_TRANS4(opR), 
                       ADDR_TRANS4(opL),
                       ADDR_TRANS4(opR));
}

Int EqTrans24 (Obj f, Obj g){
  UInt   i, def, deg;
  UInt2  *ptf;
  UInt4  *ptg;

  ptf=ADDR_TRANS2(f);   ptg=ADDR_TRANS4(g);
  def=DEG_TRANS2(f);    deg=DEG_TRANS4(g);

  if(def<=deg){
    for(i=0;i<def;i++) if(*(ptf++)!=*(ptg++)) return 0L;
    for(;i<deg;i++)    if(*(ptg++)!=i) return 0L;
  } else {
    for(i=0;i<deg;i++) if(*(ptf++)!=*(ptg++)) return 0L;
    for(;i<def;i++)    if(*(ptf++)!=i) return 0L;
  }
  
  /* otherwise they must be equal */
  return 1L;
}

Int EqTrans42 (Obj f, Obj g){
  UInt   i, def, deg;
  UInt4  *ptf;
  UInt2  *ptg;

  ptf=ADDR_TRANS4(f);   ptg=ADDR_TRANS2(g);
  def=DEG_TRANS4(f);    deg=DEG_TRANS2(g);

  if(def<=deg){
    for(i=0;i<def;i++) if(*(ptf++)!=*(ptg++)) return 0L;
    for(;i<deg;i++)    if(*(ptg++)!=i)        return 0L;
  } else {
    for(i=0;i<deg;i++) if(*(ptf++)!=*(ptg++)) return 0L;
    for(;i<def;i++)    if(*(ptf++)!=i)        return 0L;
  }
  
  /* otherwise they must be equal */
  return 1L;
}

/* less than for transformations */

Int LtTrans22(Obj f, Obj g){ 
  UInt   i, def, deg;
  UInt2  *ptf, *ptg;

  ptf=ADDR_TRANS2(f);   ptg=ADDR_TRANS2(g);
  def= DEG_TRANS2(f);   deg= DEG_TRANS2(g);
  
  if(def<=deg){
    for(i=0;i<def;i++){ 
      if(ptf[i]!=ptg[i]){
        if(ptf[i]<ptg[i]){ return 1L; } else { return 0L; }
      }
    }
    for(;i<deg;i++){
      if(ptg[i]!=i){ 
        if(i<ptg[i]){ return 1L; } else { return 0L; }
      }
    }
  } else { //def>deg
    for(i=0;i<deg;i++){ 
      if(ptf[i]!=ptg[i]){
        if(ptf[i]<ptg[i]){ return 1L; } else { return 0L; }
      }
    }
    for(;i<def;i++){
      if(ptf[i]!=i){ 
        if(i>ptf[i]){ return 1L; } else { return 0L; }
      }
    }
  }
  return 0L;
}


Int LtTrans24(Obj f, Obj g){ 
  UInt   i, def, deg;
  UInt2  *ptf;
  UInt4  *ptg;

  ptf=ADDR_TRANS2(f);   ptg=ADDR_TRANS4(g);
  def= DEG_TRANS2(f);   deg= DEG_TRANS4(g);
  
  if(def<=deg){
    for(i=0;i<def;i++){ 
      if(ptf[i]!=ptg[i]){
        if(ptf[i]<ptg[i]){ return 1L; } else { return 0L; }
      }
    }
    for(;i<deg;i++){
      if(ptg[i]!=i){ 
        if(i<ptg[i]){ return 1L; } else { return 0L; }
      }
    }
  } else {
    for(i=0;i<deg;i++){ 
      if(ptf[i]!=ptg[i]){
        if(ptf[i]<ptg[i]){ return 1L; } else { return 0L; }
      }
    }
    for(;i<def;i++){
      if(ptf[i]!=i){ 
        if(i>ptf[i]){ return 1L; } else { return 0L; }
      }
    }
  }
  return 0L;
}


Int LtTrans42(Obj f, Obj g){ 
  UInt   i, def, deg;
  UInt4  *ptf; 
  UInt2  *ptg;

  ptf=ADDR_TRANS4(f);   ptg=ADDR_TRANS2(g);
  def= DEG_TRANS4(f);   deg= DEG_TRANS2(g);
  
  if(def<=deg){
    for(i=0;i<def;i++){ 
      if(ptf[i]!=ptg[i]){
        if(ptf[i]<ptg[i]){ return 1L; } else { return 0L; }
      }
    }
    for(;i<deg;i++){
      if(ptg[i]!=i){ 
        if(i<ptg[i]){ return 1L; } else { return 0L; }
      }
    }
  } else {
    for(i=0;i<deg;i++){ 
      if(ptf[i]!=ptg[i]){
        if(ptf[i]<ptg[i]){ return 1L; } else { return 0L; }
      }
    }
    for(;i<def;i++){
      if(ptf[i]!=i){ 
        if(i>ptf[i]){ return 1L; } else { return 0L; }
      }
    }
  }
  return 0L;
}


Int LtTrans44(Obj f, Obj g){ 
  UInt   i, def, deg;
  UInt4  *ptf, *ptg;

  ptf=ADDR_TRANS4(f);   ptg=ADDR_TRANS4(g);
  def= DEG_TRANS4(f);   deg= DEG_TRANS4(g);
  
  if(def<=deg){
    for(i=0;i<def;i++){ 
      if(ptf[i]!=ptg[i]){
        if(ptf[i]<ptg[i]){ return 1L; } else { return 0L; }
      }
    }
    for(;i<deg;i++){
      if(ptg[i]!=i){ 
        if(i<ptg[i]){ return 1L; } else { return 0L; }
      }
    }
  } else {
    for(i=0;i<deg;i++){ 
      if(ptf[i]!=ptg[i]){
        if(ptf[i]<ptg[i]){ return 1L; } else { return 0L; }
      }
    }
    for(;i<def;i++){
      if(ptf[i]!=i){ 
        if(i>ptf[i]){ return 1L; } else { return 0L; }
      }
    }
  }
  return 0L;
}

/* product of transformations */
Obj ProdTrans22(Obj f, Obj g){ 
  UInt2   *ptf, *ptg, *ptfg;
  UInt    i, def, deg, defg;
  Obj     fg;

  def =DEG_TRANS2(f);
  deg =DEG_TRANS2(g);
  defg=MAX(def,deg);
  fg=NEW_TRANS2(defg);
  
  ptfg=ADDR_TRANS2(fg);
  ptf =ADDR_TRANS2(f);
  ptg =ADDR_TRANS2(g);
  if(def<=deg){
    for(i=0;i<def;i++) *(ptfg++)=ptg[*(ptf++)];
    for(;i<deg;i++) *(ptfg++)=ptg[i];
  } else {
    for(i=0;i<def;i++) *(ptfg++)=IMAGE(ptf[i], ptg, deg);
  }
  return fg;
}

Obj ProdTrans24(Obj f, Obj g){ 
  UInt2   *ptf; 
  UInt4   *ptg, *ptfg;
  UInt    i, def, deg, defg;
  Obj     fg;

  def =DEG_TRANS2(f);
  deg =DEG_TRANS4(g);
  defg=MAX(def,deg);
  fg=NEW_TRANS4(defg);
  
  ptfg=ADDR_TRANS4(fg);
  ptf =ADDR_TRANS2(f);
  ptg =ADDR_TRANS4(g);
  if(def<=deg){
    for(i=0;i<def;i++) *ptfg++=ptg[*ptf++]; 
    for(;i<deg;i++) *ptfg++=ptg[i]; 
  } else {
    for(i=0;i<def;i++) *(ptfg++)=IMAGE(ptf[i], ptg, deg);
  }
  return fg;
}

Obj ProdTrans42(Obj f, Obj g){ 
  UInt4   *ptf, *ptfg;
  UInt2   *ptg;
  UInt    i, def, deg, defg;
  Obj     fg;

  def=DEG_TRANS4(f);
  deg=DEG_TRANS2(g);
  defg=MAX(def,deg);
  fg=NEW_TRANS4(defg);
  
  ptfg=ADDR_TRANS4(fg);
  ptf =ADDR_TRANS4(f);
  ptg =ADDR_TRANS2(g);
  if(def<=deg){
    for(i=0;i<def;i++) *(ptfg++)=ptg[*(ptf++)];
    for(;i<deg;i++) *(ptfg++)=ptg[i];
  } else {
    for(i=0;i<def;i++) *(ptfg++)=IMAGE(ptf[i], ptg, deg);
  }
  return fg;
}

Obj ProdTrans44(Obj f, Obj g){ 
  UInt4   *ptf, *ptg, *ptfg;
  UInt    i, def, deg, defg;
  Obj     fg;

  def=DEG_TRANS4(f);
  deg=DEG_TRANS4(g);
  defg=MAX(def,deg);
  fg=NEW_TRANS4(defg);
  
  ptfg=ADDR_TRANS4(fg);
  ptf =ADDR_TRANS4(f);
  ptg =ADDR_TRANS4(g);
  if(def<=deg){
    for(i=0;i<def;i++) *(ptfg++)=ptg[*(ptf++)];
    for(;i<deg;i++) *(ptfg++)=ptg[i];
  } else {
    for(i=0;i<def;i++) *(ptfg++)=IMAGE(ptf[i], ptg, deg);
  }
  return fg;
}

/* product of transformation and permutation */
Obj ProdTrans2Perm2(Obj f, Obj p){ /* p(f(x)) */
  UInt2   *ptf, *ptp, *ptfp;
  UInt    i, def, dep, defp;
  Obj     fp;

  dep =  DEG_PERM2(p);
  def = DEG_TRANS2(f);
  defp=MAX(def,dep);
  fp  = NEW_TRANS2(defp);

  ptfp=ADDR_TRANS2(fp);
  ptf =ADDR_TRANS2(f);
  ptp = ADDR_PERM2(p);
  
  if(def<=dep){
    for(i=0;i<def;i++) *(ptfp++)=ptp[*(ptf++)];
    for(;i<dep;i++) *(ptfp++)=ptp[i];
  } else {
    for(i=0;i<def;i++) *(ptfp++)=IMAGE(ptf[i], ptp, dep);
  }
  return fp;
}

Obj ProdTrans2Perm4(Obj f, Obj p){ /* p(f(x)) */
  UInt2   *ptf;
  UInt4   *ptp, *ptfp;
  UInt    i, def, dep, defp;
  Obj     fp;

  dep =  DEG_PERM4(p);
  def = DEG_TRANS2(f);
  defp= MAX(def,dep);
  fp  = NEW_TRANS4(defp);

  ptfp=ADDR_TRANS4(fp);
  ptf =ADDR_TRANS2(f);
  ptp = ADDR_PERM4(p);
  
  if(def<=dep){
    for(i=0;i<def;i++) *(ptfp++)=ptp[*(ptf++)];
    for(;i<dep;i++) *(ptfp++)=ptp[i];
  } else {
    for(i=0;i<def;i++) *(ptfp++)=IMAGE(ptf[i], ptp, dep);
  }
  return fp;
}

Obj ProdTrans4Perm2(Obj f, Obj p){ /* p(f(x)) */
  UInt4   *ptf, *ptfp;
  UInt2   *ptp;
  UInt    i, def, dep, defp;
  Obj     fp;

  dep =  DEG_PERM2(p);
  def = DEG_TRANS4(f);
  defp= MAX(def,dep);
  fp  = NEW_TRANS4(defp);

  ptfp=ADDR_TRANS4(fp);
  ptf =ADDR_TRANS4(f);
  ptp = ADDR_PERM2(p);
  
  if(def<=dep){
    for(i=0;i<def;i++) *(ptfp++)=ptp[*(ptf++)];
    for(;i<dep;i++) *(ptfp++)=ptp[i];
  } else {
    for(i=0;i<def;i++) *(ptfp++)=IMAGE(ptf[i], ptp, dep);
  }
  return fp;
}

Obj ProdTrans4Perm4(Obj f, Obj p){ /* p(f(x)) */
  UInt4   *ptf, *ptp, *ptfp;
  UInt    i, def, dep, defp;
  Obj     fp;

  dep =  DEG_PERM4(p);
  def = DEG_TRANS4(f);
  defp= MAX(def,dep);
  fp  = NEW_TRANS4(defp);
  
  ptfp=ADDR_TRANS4(fp);
  ptf =ADDR_TRANS4(f);
  ptp = ADDR_PERM4(p);
  
  if(def<=dep){
    for(i=0;i<def;i++) *(ptfp++)=ptp[*(ptf++)];
    for(;i<dep;i++) *(ptfp++)=ptp[i];
  } else {
    for(i=0;i<def;i++) *(ptfp++)=IMAGE(ptf[i], ptp, dep);
  }
  return fp;
}

/* product of permutation and transformation */
Obj ProdPerm2Trans2(Obj p, Obj f){ /* f(p(x)) */
  UInt2   *ptf, *ptp, *ptpf;
  UInt    i, def, dep, depf;
  Obj     pf;

  dep =  DEG_PERM2(p);
  def = DEG_TRANS2(f);
  depf= MAX(def,dep);
  pf  = NEW_TRANS2(depf);

  ptpf=ADDR_TRANS2(pf);
  ptf =ADDR_TRANS2(f);
  ptp = ADDR_PERM2(p);
  
  if(dep<=def){
    for(i=0;i<dep;i++) *(ptpf++)=ptf[*(ptp++)];
    for(;i<def;i++) *(ptpf++)=ptf[i];
  } else {
    for(i=0;i<dep;i++) *(ptpf++)=IMAGE(ptp[i], ptf, def);
  }
  return pf;
}

Obj ProdPerm2Trans4(Obj p, Obj f){ /* f(p(x)) */
  UInt4   *ptf, *ptpf; 
  UInt2   *ptp;
  UInt    i, def, dep, depf;
  Obj     pf;

  dep =  DEG_PERM2(p);
  def = DEG_TRANS4(f);
  depf= MAX(def,dep);
  pf  = NEW_TRANS4(depf);

  ptpf=ADDR_TRANS4(pf);
  ptf =ADDR_TRANS4(f);
  ptp = ADDR_PERM2(p);
  
  if(dep<=def){
    for(i=0;i<dep;i++) *(ptpf++)=ptf[*(ptp++)];
    for(;i<def;i++) *(ptpf++)=ptf[i];
  } else {
    for(i=0;i<dep;i++) *(ptpf++)=IMAGE(ptp[i], ptf, def);
  }
  return pf;
}

Obj ProdPerm4Trans2(Obj p, Obj f){ /* f(p(x)) */
  UInt2   *ptf;
  UInt4   *ptp, *ptpf;
  UInt    i, def, dep, depf;
  Obj     pf;

  dep =  DEG_PERM4(p);
  def = DEG_TRANS2(f);
  depf= MAX(def,dep);
  pf  = NEW_TRANS4(depf);

  ptpf=ADDR_TRANS4(pf);
  ptf =ADDR_TRANS2(f);
  ptp = ADDR_PERM4(p);
  
  if(dep<=def){
    for(i=0;i<dep;i++) *(ptpf++)=ptf[*(ptp++)];
    for(;i<def;i++) *(ptpf++)=ptf[i];
  } else {
    for(i=0;i<dep;i++) *(ptpf++)=IMAGE(ptp[i], ptf, def);
  }
  return pf;
}

Obj ProdPerm4Trans4(Obj p, Obj f){ /* f(p(x)) */
  UInt4   *ptf, *ptp, *ptpf;
  UInt    i, def, dep, depf;
  Obj     pf;

  dep =  DEG_PERM4(p);
  def = DEG_TRANS4(f);
  depf= MAX(def,dep);
  pf  = NEW_TRANS4(depf);

  ptpf=ADDR_TRANS4(pf);
  ptf =ADDR_TRANS4(f);
  ptp = ADDR_PERM4(p);
  
  if(dep<=def){
    for(i=0;i<dep;i++) *(ptpf++)=ptf[*(ptp++)];
    for(;i<def;i++) *(ptpf++)=ptf[i];
  } else {
    for(i=0;i<dep;i++) *(ptpf++)=IMAGE(ptp[i], ptf, def);
  }
  return pf;
}

/* Conjugation: p^-1*f*p */
Obj PowTrans2Perm2(Obj f, Obj p){
  UInt2   *ptf, *ptp, *ptcnj;
  UInt    i, def, dep, decnj;
  Obj     cnj;

  dep  =  DEG_PERM2(p);
  def  = DEG_TRANS2(f);
  decnj=MAX(dep,def);
  cnj  = NEW_TRANS2(decnj);

  ptcnj=ADDR_TRANS2(cnj);
  ptf  =ADDR_TRANS2(f);
  ptp  = ADDR_PERM2(p);
  
  if(def==dep){
    for(i=0;i<decnj;i++) ptcnj[ptp[i]]=ptp[ptf[i]];
  } else {
    for(i=0;i<decnj;i++){
      ptcnj[IMAGE(i, ptp, dep)]=IMAGE(IMAGE(i, ptf, def), ptp, dep);
    }
  }
  return cnj;
}

Obj PowTrans2Perm4(Obj f, Obj p){
  UInt2   *ptf;
  UInt4   *ptp, *ptcnj;
  UInt    i, def, dep, decnj;
  Obj     cnj;

  dep  =  DEG_PERM4(p);
  def  = DEG_TRANS2(f);
  decnj=MAX(dep,def);
  cnj  = NEW_TRANS4(decnj);

  ptcnj=ADDR_TRANS4(cnj);
  ptf  =ADDR_TRANS2(f);
  ptp  = ADDR_PERM4(p);
  
  if(def==dep){
    for(i=0;i<decnj;i++) ptcnj[ptp[i]]=ptp[ptf[i]];
  } else {
    for(i=0;i<decnj;i++){
      ptcnj[IMAGE(i, ptp, dep)]=IMAGE(IMAGE(i, ptf, def), ptp, dep);
    }
  }
  return cnj;
}

Obj PowTrans4Perm2(Obj f, Obj p){
  UInt2   *ptp;
  UInt4   *ptf, *ptcnj;
  UInt    i, def, dep, decnj;
  Obj     cnj;

  dep  =  DEG_PERM2(p);
  def  = DEG_TRANS4(f);
  decnj=MAX(dep,def);
  cnj  = NEW_TRANS4(decnj);

  ptcnj=ADDR_TRANS4(cnj);
  ptf  =ADDR_TRANS4(f);
  ptp  = ADDR_PERM2(p);
  
  if(def==dep){
    for(i=0;i<decnj;i++) ptcnj[ptp[i]]=ptp[ptf[i]];
  } else {
    for(i=0;i<decnj;i++){
      ptcnj[IMAGE(i, ptp, dep)]=IMAGE(IMAGE(i, ptf, def), ptp, dep);
    }
  }
  return cnj;
}

Obj PowTrans4Perm4(Obj f, Obj p){
  UInt4   *ptf, *ptp, *ptcnj;
  UInt    i, def, dep, decnj;
  Obj     cnj;

  dep  =  DEG_PERM4(p);
  def  = DEG_TRANS4(f);
  decnj=MAX(dep,def);
  cnj  = NEW_TRANS4(decnj);

  ptcnj=ADDR_TRANS4(cnj);
  ptf  =ADDR_TRANS4(f);
  ptp  = ADDR_PERM4(p);
  
  if(def==dep){
    for(i=0;i<decnj;i++) ptcnj[ptp[i]]=ptp[ptf[i]];
  } else {
    for(i=0;i<decnj;i++){
      ptcnj[IMAGE(i, ptp, dep)]=IMAGE(IMAGE(i, ptf, def), ptp, dep);
    }
  }
  return cnj;
}

/* f*p^-1 */
Obj QuoTrans2Perm2(Obj f, Obj p){ 
  UInt    def, dep, deq, i;
  UInt2   *ptf, *ptquo, *ptp;
  UInt4   *pttmp;
  Obj     quo;

  def=DEG_TRANS2(f);
  dep= DEG_PERM2(p);
  deq=MAX(def, dep);
  quo=NEW_TRANS2( deq );
  ResizeTmpTrans(SIZE_OBJ(p));

  /* invert the permutation into the buffer bag */
  pttmp = (UInt4*)(ADDR_OBJ(TmpTrans));
  ptp =   ADDR_PERM2(p);
  for(i=0;i<dep;i++) pttmp[*ptp++]=i;

  ptf   = ADDR_TRANS2(f);
  ptquo = ADDR_TRANS2(quo);

  if(def<=dep){
    for(i=0;i<def;i++) *(ptquo++)=pttmp[*(ptf++)];
    for(i=def;i<dep;i++) *(ptquo++)=pttmp[i];
  }
  else {
    for(i=0;i<def;i++) *(ptquo++)=IMAGE(ptf[i], pttmp, dep );
  }
  return quo;
}

Obj QuoTrans2Perm4(Obj f, Obj p){ 
  UInt    def, dep, deq, i;
  UInt2   *ptf;
  UInt4   *ptquo, *ptp, *pttmp;
  Obj     quo;

  def=DEG_TRANS2(f);
  dep= DEG_PERM4(p);
  deq=MAX(def, dep);
  quo=NEW_TRANS4( deq );
  ResizeTmpTrans(SIZE_OBJ(p));

  /* invert the permutation into the buffer bag */
  pttmp = (UInt4*)(ADDR_OBJ(TmpTrans));
  ptp =   ADDR_PERM4(p);
  for(i=0;i<dep;i++) pttmp[*ptp++]=i;

  ptf   = ADDR_TRANS2(f);
  ptquo = ADDR_TRANS4(quo);

  if(def<=dep){
    for(i=0;i<def;i++) *(ptquo++)=pttmp[*(ptf++)];
    for(i=def;i<dep;i++) *(ptquo++)=pttmp[i];
  }
  else {
    for(i=0;i<def;i++) *(ptquo++)=IMAGE(ptf[i], pttmp, dep );
  }
  return quo;
}

Obj QuoTrans4Perm2(Obj f, Obj p){ 
  UInt    def, dep, deq, i;
  UInt4   *ptf, *ptquo, *pttmp;
  UInt2   *ptp;
  Obj     quo;

  def=DEG_TRANS4(f);
  dep= DEG_PERM2(p);
  deq=MAX(def, dep);
  quo=NEW_TRANS4( deq );
  
  ResizeTmpTrans(SIZE_OBJ(p));

  /* invert the permutation into the buffer bag */
  pttmp = (UInt4*)(ADDR_OBJ(TmpTrans));
  ptp =   ADDR_PERM2(p);
  for(i=0;i<dep;i++) pttmp[*ptp++]=i;

  ptf   = ADDR_TRANS4(f);
  ptquo = ADDR_TRANS4(quo);

  if(def<=dep){
    for(i=0;i<def;i++) *(ptquo++)=pttmp[*(ptf++)];
    for(i=def;i<dep;i++) *(ptquo++)=pttmp[i];
  }
  else {
    for(i=0;i<def;i++) *(ptquo++)=IMAGE(ptf[i], pttmp, dep );
  }
  return quo;
}

Obj QuoTrans4Perm4(Obj f, Obj p){ 
  UInt    def, dep, deq, i;
  UInt4   *ptf, *pttmp, *ptquo, *ptp;
  Obj     quo;

  def=DEG_TRANS4(f);
  dep= DEG_PERM4(p);
  deq=MAX(def, dep);
  quo=NEW_TRANS4( deq );

  ResizeTmpTrans(SIZE_OBJ(p));

  /* invert the permutation into the buffer bag */
  pttmp = (UInt4*)(ADDR_OBJ(TmpTrans));
  ptp =   ADDR_PERM4(p);
  for(i=0;i<dep;i++) pttmp[*ptp++]=i;

  ptf   = ADDR_TRANS4(f);
  ptquo = ADDR_TRANS4(quo);

  if(def<=dep){
    for(i=0;i<def;i++) *(ptquo++)=pttmp[*(ptf++)];
    for(i=def;i<dep;i++) *(ptquo++)=pttmp[i];
  }
  else {
    for(i=0;i<def;i++) *(ptquo++)=IMAGE(ptf[i], pttmp, dep );
  }
  return quo;
}

/* p^-1*f */
Obj LQuoPerm2Trans2(Obj opL, Obj opR){ 
  UInt   degL, degR, degM, p;
  Obj    mod;
  UInt2  *ptL, *ptR, *ptM; 

  degL = DEG_PERM2(opL);
  degR = DEG_TRANS2(opR);
  degM = degL < degR ? degR : degL;
  mod = NEW_TRANS2( degM );

  /* set up the pointers                                                 */
  ptL = ADDR_PERM2(opL);
  ptR = ADDR_TRANS2(opR);
  ptM = ADDR_TRANS2(mod);

  /* its one thing if the left (inner) permutation is smaller            */
  if ( degL <= degR ) {
      for ( p = 0; p < degL; p++ )
          ptM[ *(ptL++) ] = *(ptR++);
      for ( p = degL; p < degR; p++ )
          ptM[ p ] = *(ptR++);
  }

  /* and another if the right (outer) permutation is smaller             */
  else {
      for ( p = 0; p < degR; p++ )
          ptM[ *(ptL++) ] = *(ptR++);
      for ( p = degR; p < degL; p++ )
          ptM[ *(ptL++) ] = p;
  }

  /* return the result                                                   */
  return mod;
}

Obj LQuoPerm2Trans4(Obj opL, Obj opR){ 
  UInt   degL, degR, degM, p;
  Obj    mod;
  UInt2  *ptL;
  UInt4  *ptR, *ptM; 

  degL = DEG_PERM2(opL);
  degR = DEG_TRANS4(opR);
  degM = degL < degR ? degR : degL;
  mod = NEW_TRANS4( degM );

  /* set up the pointers                                                 */
  ptL = ADDR_PERM2(opL);
  ptR = ADDR_TRANS4(opR);
  ptM = ADDR_TRANS4(mod);

  /* its one thing if the left (inner) permutation is smaller            */
  if ( degL <= degR ) {
      for ( p = 0; p < degL; p++ )
          ptM[ *(ptL++) ] = *(ptR++);
      for ( p = degL; p < degR; p++ )
          ptM[ p ] = *(ptR++);
  }

  /* and another if the right (outer) permutation is smaller             */
  else {
      for ( p = 0; p < degR; p++ )
          ptM[ *(ptL++) ] = *(ptR++);
      for ( p = degR; p < degL; p++ )
          ptM[ *(ptL++) ] = p;
  }

  /* return the result                                                   */
  return mod;
}

Obj LQuoPerm4Trans2(Obj opL, Obj opR){ 
  UInt   degL, degR, degM, p;
  Obj    mod;
  UInt4  *ptL, *ptM;
  UInt2  *ptR; 

  degL = DEG_PERM4(opL);
  degR = DEG_TRANS2(opR);
  degM = degL < degR ? degR : degL;
  mod = NEW_TRANS4( degM );

  /* set up the pointers                                                 */
  ptL = ADDR_PERM4(opL);
  ptR = ADDR_TRANS2(opR);
  ptM = ADDR_TRANS4(mod);

  /* its one thing if the left (inner) permutation is smaller            */
  if ( degL <= degR ) {
      for ( p = 0; p < degL; p++ )
          ptM[ *(ptL++) ] = *(ptR++);
      for ( p = degL; p < degR; p++ )
          ptM[ p ] = *(ptR++);
  }

  /* and another if the right (outer) permutation is smaller             */
  else {
      for ( p = 0; p < degR; p++ )
          ptM[ *(ptL++) ] = *(ptR++);
      for ( p = degR; p < degL; p++ )
          ptM[ *(ptL++) ] = p;
  }

  /* return the result                                                   */
  return mod;
}

Obj LQuoPerm4Trans4(Obj opL, Obj opR){ 
  UInt   degL, degR, degM, p;
  Obj    mod;
  UInt4  *ptL, *ptR, *ptM; 

  degL = DEG_PERM4(opL);
  degR = DEG_TRANS4(opR);
  degM = degL < degR ? degR : degL;
  mod = NEW_TRANS4( degM );

  /* set up the pointers                                                 */
  ptL = ADDR_PERM4(opL);
  ptR = ADDR_TRANS4(opR);
  ptM = ADDR_TRANS4(mod);

  /* its one thing if the left (inner) permutation is smaller            */
  if ( degL <= degR ) {
      for ( p = 0; p < degL; p++ )
          ptM[ *(ptL++) ] = *(ptR++);
      for ( p = degL; p < degR; p++ )
          ptM[ p ] = *(ptR++);
  }

  /* and another if the right (outer) permutation is smaller             */
  else {
      for ( p = 0; p < degR; p++ )
          ptM[ *(ptL++) ] = *(ptR++);
      for ( p = degR; p < degL; p++ )
          ptM[ *(ptL++) ] = p;
  }

  /* return the result                                                   */
  return mod;
}

/* i^f */
Obj PowIntTrans2(Obj i, Obj f){
  UInt    img;
 
  if(TNUM_OBJ(i)==T_INTPOS) return i; 

  if(TNUM_OBJ(i)!=T_INT){
    ErrorQuit("usage: the first argument should be a positive integer", 0L, 0L);
  }
  
  img=INT_INTOBJ(i);
  
  if(img<=0){
    ErrorQuit("usage: the first argument should be a positive integer", 0L, 0L);
  }
  
  if(img<=DEG_TRANS2(f)){
    img=(ADDR_TRANS2(f))[img-1]+1;
  }
  
  return INTOBJ_INT(img);
}

Obj PowIntTrans4(Obj i, Obj f){
  UInt    img;
 
  if(TNUM_OBJ(i)==T_INTPOS) return i; 

  if(TNUM_OBJ(i)!=T_INT){
    ErrorQuit("usage: the first argument should be a positive integer", 0L, 0L);
  }
  
  img=INT_INTOBJ(i);
  
  if(img<=0){
    ErrorQuit("usage: the first argument should be a positive integer", 0L, 0L);
  }
  
  if(img<=DEG_TRANS4(f)){
    img=(ADDR_TRANS4(f))[img-1]+1;
  }
  
  return INTOBJ_INT(img);
}

/* OnSetsTrans for use in FuncOnSets */
Obj OnSetsTrans (Obj set, Obj f){
  UInt2  *ptf2;
  UInt4  *ptf4;
  UInt   deg;
  Obj    *ptset, *ptres, tmp, res;
  UInt   i, isint, k, h, len;

  res=NEW_PLIST(IS_MUTABLE_PLIST(set)?T_PLIST:T_PLIST+IMMUTABLE,LEN_LIST(set));
  ADDR_OBJ(res)[0]=ADDR_OBJ(set)[0]; 

  /* get the pointer                                                 */
  ptset = ADDR_OBJ(set) + LEN_LIST(set);
  ptres = ADDR_OBJ(res) + LEN_LIST(set);
  if(TNUM_OBJ(f)==T_TRANS2){   
    ptf2 = ADDR_TRANS2(f);
    deg = DEG_TRANS2(f);
    /* loop over the entries of the tuple                              */
    isint = 1;
    for ( i =LEN_LIST(set) ; 1 <= i; i--, ptset--, ptres-- ) {
      if ( TNUM_OBJ( *ptset ) == T_INT && 0 < INT_INTOBJ( *ptset ) ) {
        k = INT_INTOBJ( *ptset );
        if ( k <= deg ) k = ptf2[k-1] + 1 ; 
        *ptres = INTOBJ_INT(k);
      } else {/* this case cannot occur since I think POW is not defined */
        ErrorQuit("not yet implemented!", 0L, 0L); 
      }
    }
  } else {
    ptf4 = ADDR_TRANS4(f);
    deg = DEG_TRANS4(f);

    /* loop over the entries of the tuple                              */
    isint = 1;
    for ( i =LEN_LIST(set) ; 1 <= i; i--, ptset--, ptres-- ) {
      if ( TNUM_OBJ( *ptset ) == T_INT && 0 < INT_INTOBJ( *ptset ) ) {
        k = INT_INTOBJ( *ptset );
        if ( k <= deg ) k = ptf4[k-1] + 1 ; 
        *ptres = INTOBJ_INT(k);
      } else {/* this case cannot occur since I think POW is not defined */
        ErrorQuit("not yet implemented!", 0L, 0L); 
      }
    }
  }
  /* sort the result */
  len=LEN_LIST(res);
  h = 1;  while ( 9*h + 4 < len )  h = 3*h + 1;
  while ( 0 < h ) {
    for ( i = h+1; i <= len; i++ ) {
      tmp = ADDR_OBJ(res)[i];  k = i;
      while ( h < k && ((Int)tmp < (Int)(ADDR_OBJ(res)[k-h])) ) {
        ADDR_OBJ(res)[k] = ADDR_OBJ(res)[k-h];
        k -= h;
      }
      ADDR_OBJ(res)[k] = tmp;
    }
    h = h / 3;
  }

  /* remove duplicates */
  if ( 0 < len ) {
    tmp = ADDR_OBJ(res)[1];  k = 1;
    for ( i = 2; i <= len; i++ ) {
      if ( ! EQ( tmp, ADDR_OBJ(res)[i] ) ) {
        k++;
        tmp = ADDR_OBJ(res)[i];
        ADDR_OBJ(res)[k] = tmp;
      }
    }
    if ( k < len ) {
      ResizeBag( res, (k+1)*sizeof(Obj) );
      SET_LEN_PLIST(res, k);
    }
  }

  /* retype if we only have integers */
  if(isint){
    RetypeBag( res, IS_MUTABLE_PLIST(set) ? T_PLIST_CYC_SSORT :
     T_PLIST_CYC_SSORT + IMMUTABLE ); 
  }

  return res;
}

/* OnTuplesTrans for use in FuncOnTuples */
Obj OnTuplesTrans (Obj tup, Obj f){
  UInt2  *ptf2;
  UInt4  *ptf4;
  UInt   deg, isint, i, k;
  Obj    *pttup, *ptres, res;

  res=NEW_PLIST(IS_MUTABLE_PLIST(tup)?T_PLIST:T_PLIST+IMMUTABLE,LEN_LIST(tup));
  ADDR_OBJ(res)[0]=ADDR_OBJ(tup)[0]; 

  /* get the pointer                                                 */
  pttup = ADDR_OBJ(tup) + LEN_LIST(tup);
  ptres = ADDR_OBJ(res) + LEN_LIST(tup);
  if(TNUM_OBJ(f)==T_TRANS2){
    ptf2 = ADDR_TRANS2(f);
    deg = DEG_TRANS2(f);

    /* loop over the entries of the tuple                              */
    isint=1;
    for ( i =LEN_LIST(tup) ; 1 <= i; i--, pttup--, ptres-- ) {
      if ( TNUM_OBJ( *pttup ) == T_INT && 0 < INT_INTOBJ( *pttup ) ) {
        k = INT_INTOBJ( *pttup );
        if ( k <= deg ) k = ptf2[k-1] + 1 ; 
        *ptres = INTOBJ_INT(k);
      } else {/* this case cannot occur since I think POW is not defined */
        ErrorQuit("not yet implemented!", 0L, 0L);
      }
    }
  } else {
    ptf4 = ADDR_TRANS4(f);
    deg = DEG_TRANS4(f);

    /* loop over the entries of the tuple                              */
    isint=1;
    for ( i =LEN_LIST(tup) ; 1 <= i; i--, pttup--, ptres-- ) {
      if ( TNUM_OBJ( *pttup ) == T_INT && 0 < INT_INTOBJ( *pttup ) ) {
        k = INT_INTOBJ( *pttup );
        if ( k <= deg ) k = ptf4[k-1] + 1 ; 
        *ptres = INTOBJ_INT(k);
      } else {/* this case cannot occur since I think POW is not defined */
        ErrorQuit("not yet implemented!", 0L, 0L);
      }
    }
  }
  if(isint){
    RetypeBag( res, IS_MUTABLE_PLIST(tup) ? T_PLIST_CYC_SSORT :
     T_PLIST_CYC_SSORT + IMMUTABLE );
  }
  return res;
}

Obj FuncOnPosIntSetsTrans (Obj self, Obj set, Obj f, Obj n){
  UInt2  *ptf2;
  UInt4  *ptf4;
  UInt   deg;
  Obj    *ptset, *ptres, tmp, res;
  UInt   i, k, h, len;

  if(LEN_LIST(set)==0) return set;

  if(LEN_LIST(set)==1&&INT_INTOBJ(ELM_LIST(set, 1))==0){
    return FuncIMAGE_SET_TRANS_INT(self, f, n);
  }  

  PLAIN_LIST(set);
  res=NEW_PLIST(IS_MUTABLE_PLIST(set)?T_PLIST:T_PLIST+IMMUTABLE,LEN_LIST(set));
  ADDR_OBJ(res)[0]=ADDR_OBJ(set)[0]; 

  /* get the pointer                                                 */
  ptset = ADDR_OBJ(set) + LEN_LIST(set);
  ptres = ADDR_OBJ(res) + LEN_LIST(set);
  
  if(TNUM_OBJ(f)==T_TRANS2){   
    ptf2 = ADDR_TRANS2(f);
    deg = DEG_TRANS2(f);
    for ( i =LEN_LIST(set) ; 1 <= i; i--, ptset--, ptres-- ) {
      k = INT_INTOBJ( *ptset );
      if ( k <= deg ) k = ptf2[k-1] + 1 ; 
      *ptres = INTOBJ_INT(k);
    }
  } else {
    ptf4 = ADDR_TRANS4(f);
    deg = DEG_TRANS4(f);
    for ( i =LEN_LIST(set) ; 1 <= i; i--, ptset--, ptres-- ) {
      k = INT_INTOBJ( *ptset );
      if ( k <= deg ) k = ptf4[k-1] + 1 ; 
      *ptres = INTOBJ_INT(k);
    }
  }
  /* sort the result */
  len=LEN_LIST(res);
  h = 1;  while ( 9*h + 4 < len )  h = 3*h + 1;
  while ( 0 < h ) {
    for ( i = h+1; i <= len; i++ ) {
      tmp = ADDR_OBJ(res)[i];  k = i;
      while ( h < k && ((Int)tmp < (Int)(ADDR_OBJ(res)[k-h])) ) {
        ADDR_OBJ(res)[k] = ADDR_OBJ(res)[k-h];
        k -= h;
      }
      ADDR_OBJ(res)[k] = tmp;
    }
    h = h / 3;
  }

  /* remove duplicates */
  if ( 0 < len ) {
    tmp = ADDR_OBJ(res)[1];  k = 1;
    for ( i = 2; i <= len; i++ ) {
      if ( ! EQ( tmp, ADDR_OBJ(res)[i] ) ) {
        k++;
        tmp = ADDR_OBJ(res)[i];
        ADDR_OBJ(res)[k] = tmp;
      }
    }
    if ( k < len ) {
      ResizeBag( res, (k+1)*sizeof(Obj) );
      SET_LEN_PLIST(res, k);
    }
  }

  /* retype if we only have integers */
  RetypeBag( res, IS_MUTABLE_PLIST(set) ? T_PLIST_CYC_SSORT :
   T_PLIST_CYC_SSORT + IMMUTABLE ); 

  return res;
}

/******************************************************************************/
/******************************************************************************/

/* other internal things */

/* so that kernel and image set are preserved during garbage collection */

void MarkTransSubBags( Obj f ){
  if(IMG_TRANS(f)!=NULL){
    MARK_BAG(IMG_TRANS(f));
    MARK_BAG(KER_TRANS(f));
  }
  if(EXT_TRANS(f)!=NULL){
    MARK_BAG(EXT_TRANS(f));
  }
}

/* Save and load */
void SaveTrans2( Obj f){
  UInt2   *ptr;
  UInt    len, i;
  ptr=ADDR_TRANS2(f); /* save the image list */
  len=DEG_TRANS2(f);
  for (i = 0; i < len; i++) SaveUInt2(*ptr++);
}

void LoadTrans2( Obj f){
  UInt2   *ptr;
  UInt    len, i;
  len=DEG_TRANS2(f);
  ptr=ADDR_TRANS2(f);
  for (i = 0; i < len; i++) *ptr++=LoadUInt2();
}

void SaveTrans4( Obj f){
  UInt4   *ptr;
  UInt    len, i;
  ptr=ADDR_TRANS4(f); /* save the image list */
  len=DEG_TRANS4(f);
  for (i = 0; i < len; i++) SaveUInt4(*ptr++);
}

void LoadTrans4( Obj f){
  UInt4   *ptr;
  UInt    len, i;
  len=DEG_TRANS4(f);
  ptr=ADDR_TRANS4(f);
  for (i = 0; i < len; i++) *ptr++=LoadUInt4();
}

Obj TYPE_TRANS2;

Obj TypeTrans2(Obj f){
  return TYPE_TRANS2;
}

Obj TYPE_TRANS4;

Obj TypeTrans4(Obj f){
  return TYPE_TRANS4;
}

Obj IsTransFilt;

Obj IsTransHandler (
    Obj                 self,
    Obj                 val )
{
    /* return 'true' if <val> is a transformation and 'false' otherwise       */
    if ( TNUM_OBJ(val) == T_TRANS2 || TNUM_OBJ(val) == T_TRANS4 ) {
        return True;
    }
    else if ( TNUM_OBJ(val) < FIRST_EXTERNAL_TNUM ) {
        return False;
    }
    else {
        return DoFilter( self, val );
    }
}

/*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * */

/****************************************************************************
**

*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

    { "IS_TRANS", "obj", &IsTransFilt,
      IsTransHandler, "src/trans.c:IS_TRANS" },

    { 0 }

};

/******************************************************************************
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

  { "HAS_KER_TRANS", 1, "f",
     FuncHAS_KER_TRANS,
    "src/TRANS.c:FuncHAS_KER_TRANS" },

  { "HAS_IMG_TRANS", 1, "f",
     FuncHAS_IMG_TRANS,
    "src/TRANS.c:FuncHAS_IMG_TRANS" },

  { "INT_DEG_TRANS", 1, "f",
     FuncINT_DEG_TRANS,
    "src/TRANS.c:FuncINT_DEG_TRANS" },
  
  { "NUMB_TRANS_INT", 2, "f, m",
     FuncNUMB_TRANS_INT,
    "src/trans.c:FuncNUMB_TRANS_INT" },

  { "TRANS_NUMB_INT", 2, "f, m",
     FuncTRANS_NUMB_INT,
    "src/trans.c:FuncTRANS_NUMB_INT" },

  { "TransformationNC", 1, "list",
     FuncTransformationNC,
    "src/trans.c:FuncTransformationNC" },

  { "TransformationListListNC", 2, "src, ran",
     FuncTransformationListListNC,
    "src/trans.c:FuncTransformationListListNC" },

  { "DegreeOfTransformation", 1, "f",
     FuncDegreeOfTransformation,
    "src/trans.c:FuncDegreeOfTransformation" },

  { "HASH_FUNC_FOR_TRANS", 2, "f, data",
     FuncHASH_FUNC_FOR_TRANS,
    "src/trans.c:FuncHASH_FUNC_FOR_TRANS" },
  
  { "RANK_TRANS", 1, "f",
     FuncRANK_TRANS,
    "src/trans.c:FuncRANK_TRANS" },

  { "RANK_TRANS_INT", 2, "f, n",
     FuncRANK_TRANS_INT,
    "src/trans.c:FuncRANK_TRANS_INT" },

  { "RANK_TRANS_LIST", 2, "f, list",
     FuncRANK_TRANS_LIST,
    "src/trans.c:FuncRANK_TRANS_LIST" },

  { "LARGEST_MOVED_PT_TRANS", 1, "f",
     FuncLARGEST_MOVED_PT_TRANS,
    "src/trans.c:FuncLARGEST_MOVED_PT_TRANS" },

  { "LARGEST_IMAGE_PT", 1, "f",
     FuncLARGEST_IMAGE_PT,
    "src/trans.c:FuncLARGEST_IMAGE_PT" },

  { "SMALLEST_MOVED_PT_TRANS", 1, "f",
     FuncSMALLEST_MOVED_PT_TRANS,
    "src/trans.c:FuncSMALLEST_MOVED_PT_TRANS" },

  { "SMALLEST_IMAGE_PT", 1, "f",
     FuncSMALLEST_IMAGE_PT,
    "src/trans.c:FuncSMALLEST_IMAGE_PT" },

  { "NR_MOVED_PTS_TRANS", 1, "f",
     FuncNR_MOVED_PTS_TRANS,
    "src/trans.c:FuncNR_MOVED_PTS_TRANS" },

  { "MOVED_PTS_TRANS", 1, "f",
     FuncMOVED_PTS_TRANS,
    "src/trans.c:FuncMOVED_PTS_TRANS" },

  { "IMAGE_TRANS", 2, "f, n",
     FuncIMAGE_TRANS,
    "src/trans.c:FuncIMAGE_TRANS" },

  { "FLAT_KERNEL_TRANS", 1, "f",
     FuncFLAT_KERNEL_TRANS,
    "src/trans.c:FuncFLAT_KERNEL_TRANS" },

  { "FLAT_KERNEL_TRANS_INT", 2, "f, n",
     FuncFLAT_KERNEL_TRANS_INT,
    "src/trans.c:FuncFLAT_KERNEL_TRANS_INT" },

  { "IMAGE_SET_TRANS", 1, "f",
     FuncIMAGE_SET_TRANS,
    "src/trans.c:FuncIMAGE_SET_TRANS" },

  { "IMAGE_SET_TRANS_INT", 2, "f, n",
     FuncIMAGE_SET_TRANS_INT,
    "src/trans.c:FuncIMAGE_SET_TRANS_INT" },

  { "KERNEL_TRANS", 2, "f, n",
     FuncKERNEL_TRANS,
    "src/trans.c:FuncKERNEL_TRANS" },

  { "PREIMAGES_TRANS_INT", 2, "f, pt",
     FuncPREIMAGES_TRANS_INT,
    "src/trans.c:FuncPREIMAGES_TRANS_INT" },

  { "AS_TRANS_PERM", 1, "f",
     FuncAS_TRANS_PERM,
    "src/trans.c:FuncAS_TRANS_PERM" },

  { "AS_TRANS_PERM_INT", 2, "f, n",
     FuncAS_TRANS_PERM_INT,
    "src/trans.c:FuncAS_TRANS_PERM_INT" },

  { "AS_PERM_TRANS", 1, "f",
     FuncAS_PERM_TRANS,
    "src/trans.c:FuncAS_PERM_TRANS" },

  { "PERM_IMG_TRANS", 1, "f",
     FuncPERM_IMG_TRANS,
    "src/trans.c:FuncPERM_IMG_TRANS" },

  { "RESTRICTED_TRANS", 2, "f, list",
     FuncRESTRICTED_TRANS,
    "src/trans.c:FuncRESTRICTED_TRANS" },

  { "AS_TRANS_TRANS", 2, "f, m",
     FuncAS_TRANS_TRANS,
    "src/trans.c:FuncAS_TRANS_TRANS" },

  { "TRIM_TRANS", 2, "f, m",
     FuncTRIM_TRANS,
    "src/trans.c:FuncTRIM_TRANS" },

  { "IS_INJECTIVE_LIST_TRANS", 2, "t, l",
     FuncIS_INJECTIVE_LIST_TRANS,
    "src/trans.c:FuncIS_INJECTIVE_LIST_TRANS" },

  { "PERM_LEFT_QUO_TRANS_NC", 2, "f, g",
     FuncPERM_LEFT_QUO_TRANS_NC,
    "src/trans.c:FuncPERM_LEFT_QUO_TRANS_NC" },

  { "TRANS_IMG_KER_NC", 2, "img, ker",
     FuncTRANS_IMG_KER_NC,
    "src/trans.c:FuncTRANS_IMG_KER_NC" },

  { "IDEM_IMG_KER_NC", 2, "img, ker",
     FuncIDEM_IMG_KER_NC,
    "src/trans.c:FuncIDEM_IMG_KER_NC" },

  { "INV_TRANS", 1, "f",
     FuncINV_TRANS,
    "src/trans.c:FuncINV_TRANS" },

  { "INV_LIST_TRANS", 2, "list, f",
     FuncINV_LIST_TRANS,
    "src/trans.c:FuncINV_LIST_TRANS" },

  { "TRANS_IMG_CONJ", 2, "f,g",
     FuncTRANS_IMG_CONJ,
    "src/trans.c:FuncTRANS_IMG_CONJ" },

  { "INDEX_PERIOD_TRANS", 1, "f",
     FuncINDEX_PERIOD_TRANS,
    "src/trans.c:FuncINDEX_PERIOD_TRANS" },

  { "SMALLEST_IDEM_POW_TRANS", 1, "f",
     FuncSMALLEST_IDEM_POW_TRANS,
    "src/trans.c:FuncSMALLEST_IDEM_POW_TRANS" },

  { "POW_KER_PERM", 2, "ker, f",
     FuncPOW_KER_PERM,
    "src/trans.c:FuncPOW_KER_PERM" },

  { "ON_KERNEL_ANTI_ACTION", 3, "ker, f, n",
     FuncON_KERNEL_ANTI_ACTION,
    "src/trans.c:FuncON_KERNEL_ANTI_ACTION" },

  { "INV_KER_TRANS", 2, "ker, f",
     FuncINV_KER_TRANS,
    "src/trans.c:FuncINV_KER_TRANS" },

  { "IS_IDEM_TRANS", 1, "f",
    FuncIS_IDEM_TRANS,
    "src/trans.c:FuncIS_IDEM_TRANS" },

  { "IS_ID_TRANS", 1, "f",
    FuncIS_ID_TRANS,
    "src/trans.c:FuncIS_ID_TRANS" },
  
  { "COMPONENT_REPS_TRANS", 1, "f",
    FuncCOMPONENT_REPS_TRANS,
    "src/trans.c:FuncCOMPONENT_REPS_TRANS" },
  
  { "NR_COMPONENTS_TRANS", 1, "f",
    FuncNR_COMPONENTS_TRANS,
    "src/trans.c:FuncNR_COMPONENTS_TRANS" },

  { "COMPONENTS_TRANS", 1, "f",
    FuncCOMPONENTS_TRANS,
    "src/trans.c:FuncCOMPONENTS_TRANS" },

  { "COMPONENT_TRANS_INT", 2, "f, pt",
    FuncCOMPONENT_TRANS_INT,
    "src/trans.c:FuncCOMPONENT_TRANS_INT" },

  { "CYCLE_TRANS_INT", 2, "f, pt",
    FuncCYCLE_TRANS_INT,
    "src/trans.c:FuncCYCLE_TRANS_INT" },

  { "CYCLES_TRANS_LIST", 2, "f, pt",
    FuncCYCLES_TRANS_LIST,
    "src/trans.c:FuncCYCLES_TRANS_LIST" },

  { "LEFT_ONE_TRANS", 1, "f",
    FuncLEFT_ONE_TRANS,
    "src/trans.c:FuncLEFT_ONE_TRANS" },

  { "RIGHT_ONE_TRANS", 1, "f",
    FuncRIGHT_ONE_TRANS,
    "src/trans.c:FuncRIGHT_ONE_TRANS" },
  
  { "OnPosIntSetsTrans", 3, "set, f, n", 
    FuncOnPosIntSetsTrans, 
    "src/trans.c:FuncOnPosIntSetsTrans" },

  { "IsCommutingTransformation", 2, "f, g", 
    FuncIsCommutingTransformation, 
    "src/trans.c:FuncIsCommutingTransformation" },
  
  { 0 }

};
/******************************************************************************
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel ( StructInitInfo *module )
{

    /* install the marking functions                                       */
    InfoBags[ T_TRANS2 ].name = "transformation (small)";
    InfoBags[ T_TRANS4 ].name = "transformation (large)";
    InitMarkFuncBags( T_TRANS2, MarkTransSubBags );
    InitMarkFuncBags( T_TRANS4, MarkTransSubBags );
    
    MakeBagTypePublic( T_TRANS2);
    MakeBagTypePublic( T_TRANS4);

    /* install the type functions                                          */
    ImportGVarFromLibrary( "TYPE_TRANS2", &TYPE_TRANS2 );
    ImportGVarFromLibrary( "TYPE_TRANS4", &TYPE_TRANS4 );

    TypeObjFuncs[ T_TRANS2 ] = TypeTrans2;
    TypeObjFuncs[ T_TRANS4 ] = TypeTrans4;

    /* init filters and functions                                          */
    InitHdlrFiltsFromTable( GVarFilts );
    InitHdlrFuncsFromTable( GVarFuncs );

    /* make the buffer bag                                                 */
    InitGlobalBag( &TmpTrans, "src/trans.c:TmpTrans" );
    
    // make the identity trans
    InitGlobalBag( &IdentityTrans, "src/trans.c:IdentityTrans" );
    
    /* install the saving functions */
    SaveObjFuncs[ T_TRANS2 ] = SaveTrans2;
    LoadObjFuncs[ T_TRANS2 ] = LoadTrans2; 
    SaveObjFuncs[ T_TRANS4 ] = SaveTrans4;
    LoadObjFuncs[ T_TRANS4 ] = LoadTrans4; 

    /* install the comparison methods                                      */
    EqFuncs  [ T_TRANS2  ][ T_TRANS2  ] = EqTrans22;    
    EqFuncs  [ T_TRANS2  ][ T_TRANS4  ] = EqTrans24;    
    EqFuncs  [ T_TRANS4  ][ T_TRANS2  ] = EqTrans42;    
    EqFuncs  [ T_TRANS4  ][ T_TRANS4  ] = EqTrans44;    
    LtFuncs  [ T_TRANS2  ][ T_TRANS2  ] = LtTrans22;
    LtFuncs  [ T_TRANS2  ][ T_TRANS4  ] = LtTrans24;
    LtFuncs  [ T_TRANS4  ][ T_TRANS2  ] = LtTrans42;
    LtFuncs  [ T_TRANS4  ][ T_TRANS4  ] = LtTrans44;
    
    /* install the binary operations */
    ProdFuncs [ T_TRANS2  ][ T_TRANS2 ] = ProdTrans22;
    ProdFuncs [ T_TRANS4  ][ T_TRANS4 ] = ProdTrans44;
    ProdFuncs [ T_TRANS2  ][ T_TRANS4 ] = ProdTrans24;
    ProdFuncs [ T_TRANS4  ][ T_TRANS2 ] = ProdTrans42;
    ProdFuncs [ T_TRANS2  ][ T_PERM2 ] = ProdTrans2Perm2;
    ProdFuncs [ T_TRANS2  ][ T_PERM4 ] = ProdTrans2Perm4;
    ProdFuncs [ T_TRANS4  ][ T_PERM2 ] = ProdTrans4Perm2;
    ProdFuncs [ T_TRANS4  ][ T_PERM4 ] = ProdTrans4Perm4;
    ProdFuncs [ T_PERM2  ][ T_TRANS2 ] = ProdPerm2Trans2;
    ProdFuncs [ T_PERM4  ][ T_TRANS2 ] = ProdPerm4Trans2;
    ProdFuncs [ T_PERM2  ][ T_TRANS4 ] = ProdPerm2Trans4;
    ProdFuncs [ T_PERM4  ][ T_TRANS4 ] = ProdPerm4Trans4;
    PowFuncs  [ T_TRANS2  ][ T_PERM2 ] = PowTrans2Perm2;    
    PowFuncs  [ T_TRANS2  ][ T_PERM4 ] = PowTrans2Perm4;    
    PowFuncs  [ T_TRANS4  ][ T_PERM2 ] = PowTrans4Perm2;    
    PowFuncs  [ T_TRANS4  ][ T_PERM4 ] = PowTrans4Perm4;    
    QuoFuncs  [ T_TRANS2  ][ T_PERM2 ] = QuoTrans2Perm2;
    QuoFuncs  [ T_TRANS2  ][ T_PERM4 ] = QuoTrans2Perm4;
    QuoFuncs  [ T_TRANS4  ][ T_PERM2 ] = QuoTrans4Perm2;
    QuoFuncs  [ T_TRANS4  ][ T_PERM4 ] = QuoTrans4Perm4;
    LQuoFuncs [ T_PERM2  ][ T_TRANS2 ] = LQuoPerm2Trans2;
    LQuoFuncs [ T_PERM4  ][ T_TRANS2 ] = LQuoPerm4Trans2;
    LQuoFuncs [ T_PERM2  ][ T_TRANS4 ] = LQuoPerm2Trans4;
    LQuoFuncs [ T_PERM4  ][ T_TRANS4 ] = LQuoPerm4Trans4;
    PowFuncs  [ T_INT    ][ T_TRANS2 ] = PowIntTrans2;
    PowFuncs  [ T_INT    ][ T_TRANS4 ] = PowIntTrans4;
  
    /* install the 'ONE' function for transformations */
    OneFuncs    [ T_TRANS2 ] = OneTrans;
    OneMutFuncs [ T_TRANS2 ] = OneTrans;
    OneFuncs    [ T_TRANS4 ] = OneTrans;
    OneMutFuncs [ T_TRANS4 ] = OneTrans;

    /* return success                                                      */
    return 0;
}

/******************************************************************************
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary ( StructInitInfo *module )
{
    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );
    InitGVarFiltsFromTable( GVarFilts );
    TmpTrans = NEW_TRANS4(1000);
    IdentityTrans = NEW_TRANS2(0);

    /* return success                                                      */
    return 0;
}

/****************************************************************************
**
*F  InitInfoTrans()  . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "trans",                            /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    0,                                  /* postRestore                    */
    "src/trans.c",                      /* filename                       */
    1                                   /* isGapRootRelative              */
};

StructInitInfo * InitInfoTrans ( void )
{
    return &module;
}

