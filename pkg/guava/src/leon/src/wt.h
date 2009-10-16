#undef WEIGHT
#undef ADD
#if MAXLEN == 32
  #define WEIGHT   onesCount[cw1 & 0x0000ffff] + onesCount[cw1 >> 16]
  #define ADD(i)   cw1 ^= basis1[i];
#elif MAXLEN == 48
  #define WEIGHT   onesCount[cw1 & 0x0000ffff] + onesCount[cw1 >> 16] + \
                              onesCount[cw2 & 0x0000ffff]
  #define ADD(i)   cw1 ^= basis1[i];  cw2 ^= basis2[i];
#elif MAXLEN == 64
  #define WEIGHT  onesCount[cw1 & 0x0000ffff] + onesCount[cw1 >> 16] + \
                             onesCount[cw2 & 0x0000ffff] + onesCount[cw2 >> 16]
  #define ADD(i)   cw1 ^= basis1[i];  cw2 ^= basis2[i];
#elif MAXLEN == 80
    #define WEIGHT  onesCount[cw1 & 0x0000ffff] + onesCount[cw1 >> 16] + \
                              onesCount[cw2 & 0x0000ffff] + onesCount[cw2 >> 16] + \
                              onesCount[cw3 & 0x0000ffff]
   #define ADD(i)  cw1 ^= basis1[i];  cw2 ^= basis2[i];  cw3 ^= basis3[i];
#elif MAXLEN == 96
    #define WEIGHT  onesCount[cw1 & 0x0000ffff] + onesCount[cw1 >> 16] + \
                              onesCount[cw2 & 0x0000ffff] + onesCount[cw2 >> 16] + \
                              onesCount[cw3 & 0x0000ffff] + onesCount[cw3 >> 16]
   #define ADD(i)  cw1 ^= basis1[i];  cw2 ^= basis2[i];  cw3 ^= basis3[i];
#elif MAXLEN == 112
    #define WEIGHT  onesCount[cw1 & 0x0000ffff] + onesCount[cw1 >> 16] + \
                              onesCount[cw2 & 0x0000ffff] + onesCount[cw2 >> 16] + \
                              onesCount[cw3 & 0x0000ffff] + onesCount[cw3 >> 16] + \
                              onesCount[cw4 & 0x0000ffff]
   #define ADD(i)  cw1 ^= basis1[i];  cw2 ^= basis2[i];  cw3 ^= basis3[i]; \
                   cw4 ^= basis4[i];
#elif MAXLEN == 128
    #define WEIGHT onesCount[cw1 & 0x0000ffff] + onesCount[cw1 >> 16] + \
                             onesCount[cw2 & 0x0000ffff] + onesCount[cw2 >> 16] + \
                             onesCount[cw3 & 0x0000ffff] + onesCount[cw3 >> 16] + \
                             onesCount[cw4 & 0x0000ffff] + onesCount[cw4 >> 16]
   #define ADD(i)  cw1 ^= basis1[i];  cw2 ^= basis2[i];  cw3 ^= basis3[i]; \
                   cw4 ^= basis4[i];
#endif

         for ( loopIndex = 0 ; loopIndex <= lastPass ; ++loopIndex ) {
         ++freq[WEIGHT];
         ADD(0)
         ++freq[WEIGHT];
         ADD(1)
         ++freq[WEIGHT];
         ADD(0)
         ++freq[WEIGHT];
         ADD(2)
         ++freq[WEIGHT];
         ADD(0)
         ++freq[WEIGHT];
         ADD(1)
         ++freq[WEIGHT];
         ADD(0)
         ++freq[WEIGHT];
         temp = loopIndex + 1;
         m = 3;
         while ( (temp & 1) == 0 ) {
            ++m;
            temp >>= 1;
         }
         ADD(m)
      }
#undef MAXLEN
