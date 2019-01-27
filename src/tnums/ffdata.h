#ifndef GAP_FFDATA_H
#define GAP_FFDATA_H

enum {
    NUM_SHORT_FINITE_FIELDS = 6635
};

extern const unsigned long SizeFF[NUM_SHORT_FINITE_FIELDS+1];
extern const unsigned char DegrFF[NUM_SHORT_FINITE_FIELDS+1];
extern const unsigned long CharFF[NUM_SHORT_FINITE_FIELDS+1];

#endif // GAP_FFDATA_H
