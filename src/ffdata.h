#ifndef GAP_FFDATA_H
#define GAP_FFDATA_H

/* 2^16: 6542 fields of prime order, 93 of non-prime order: 6635
 2^24: 1077871 fields of prime order, 684 of non-prime order: 1078555
 2^32: 203280221 fields of prime order, 6948 of non-prime order: 203287169
 changing this into 203280221 gives a linker error ;-) */

enum {
    NUM_SHORT_FINITE_FIELDS = 1078555, /* jdb: 18/09/18 was 6635 */
    SIZE_LARGEST_INTERNAL_FF = 16777216 /* added 19/09/18 */
};

extern unsigned long SizeFF[NUM_SHORT_FINITE_FIELDS+1];
extern unsigned char DegrFF[NUM_SHORT_FINITE_FIELDS+1];
extern unsigned long CharFF[NUM_SHORT_FINITE_FIELDS+1];

#endif // GAP_FFDATA_H
