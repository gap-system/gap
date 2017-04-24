/* Generate ffdata.{c,h} for finite fields, used in
   finfield.c
 */

#include <stdio.h>
#include <string.h>

#define MAX_FF 65536

unsigned char is_prime[MAX_FF + 1];
unsigned char is_ff[MAX_FF + 1];
unsigned      deg[MAX_FF + 1];
unsigned      ch[MAX_FF + 1];
unsigned      num_ff;

void make_primes()
{
    unsigned i, j;
    for (i = 2; i <= MAX_FF; i++)
        is_prime[i] = 1;
    for (i = 2; i * i <= MAX_FF; i++) {
        if (is_prime[i]) {
            for (j = 2 * i; j <= MAX_FF; j += i)
                is_prime[j] = 0;
        }
    }
}

void make_ff()
{
    unsigned i, j, d;
    for (i = 2; i <= MAX_FF; i++) {
        if (is_prime[i]) {
            for (j = i, d = 1; j <= MAX_FF; j *= i, d++) {
                is_ff[j] = 1;
                deg[j] = d;
                ch[j] = i;
                num_ff++;
            }
        }
    }
}

void emit_code(int header)
{
    unsigned i, j;
    if (header) {
        printf("#ifndef _GAP_FFDATA_H\n");
        printf("#define _GAP_FFDATA_H\n");
        printf("\n");
        printf("#define NUM_SHORT_FINITE_FIELDS %d\n", num_ff);
        printf("\n");
        printf("extern unsigned long SizeFF[NUM_SHORT_FINITE_FIELDS+1];\n",
               num_ff);
        printf("extern unsigned char DegrFF[NUM_SHORT_FINITE_FIELDS+1];\n",
               num_ff);
        printf("extern unsigned long CharFF[NUM_SHORT_FINITE_FIELDS+1];\n",
               num_ff);
        printf("\n");
        printf("#endif /* _GAP_FFDATA_H */\n");
    }
    else {
        printf("#include \"ffdata.h\"\n");
        printf("\n");
        printf("/* Entries are ordered by value of p^d; can use binary "
               "search\n");
        printf(" * to find them. Indices start at 1.\n");
        printf(" */\n");
        printf("\n");
        printf("unsigned char DegrFF[NUM_SHORT_FINITE_FIELDS+1] = {\n");
        printf(" %3d,", 0);
        for (i = 0, j = 1; i <= MAX_FF; i++) {
            if (is_ff[i]) {
                printf("%3d,", deg[i]);
                j++;
                j %= 16;
                if (!j)
                    printf("\n ");
            }
        }
        if (j)
            printf("\n");
        printf("};\n");
        printf("\n");
        printf("unsigned long CharFF[NUM_SHORT_FINITE_FIELDS+1] = {\n");
        printf(" %6d,", 0);
        for (i = 0, j = 1; i <= MAX_FF; i++) {
            if (is_ff[i]) {
                printf("%6d,", ch[i]);
                j++;
                j %= 8;
                if (!j)
                    printf("\n ");
            }
        }
        if (j)
            printf("\n");
        printf("};\n");
        printf("\n");
        printf("unsigned long SizeFF[NUM_SHORT_FINITE_FIELDS+1] = {\n");
        printf(" %6d,", 0);
        for (i = 0, j = 1; i <= MAX_FF; i++) {
            if (is_ff[i]) {
                printf("%6d,", i);
                j++;
                j %= 8;
                if (!j)
                    printf("\n ");
            }
        }
        if (j)
            printf("\n");
        printf("};\n");
    }
}

int main(int argc, char * argv[])
{
    char * opt = argc > 1 ? argv[1] : NULL;
    make_primes();
    make_ff();
    if (!opt)
        emit_code(0);
    else if (!strcmp(opt, "h") || !strcmp(opt, ".h") || !strcmp(opt, "-h"))
        emit_code(1);
    else if (!strcmp(opt, "c") || !strcmp(opt, ".c") || !strcmp(opt, "-c"))
        emit_code(0);
    else {
        fprintf(stderr, "Usage: ffgen [-h|-c]\n");
        fprintf(stderr, "  -h for header file\n");
        fprintf(stderr, "  -c for C source file\n");
        return 1;
    }
    return 0;
}
