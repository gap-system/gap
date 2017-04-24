#ifndef GAP_FFDATA_H
#define GAP_FFDATA_H

enum {
    NUM_SHORT_FINITE_FIELDS = 6635
};

extern unsigned long SizeFF[NUM_SHORT_FINITE_FIELDS+1];
extern unsigned char DegrFF[NUM_SHORT_FINITE_FIELDS+1];
extern unsigned long CharFF[NUM_SHORT_FINITE_FIELDS+1];

#endif /* _GAP_FFDATA_H */
