/* Generate ffdata.{c,h} for finite fields, used in
   finfield.c
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#define MAX_FF 65536

unsigned char is_prime[MAX_FF + 1];
unsigned char is_ff[MAX_FF + 1];
unsigned      deg[MAX_FF + 1];
unsigned      ch[MAX_FF + 1];
unsigned      num_ff;

void make_primes()
{
    unsigned long i, j;
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
    unsigned long i, j, d;
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

void emit_code(FILE * dest, int header)
{
    unsigned i, j;
    if (header) {
        fprintf(dest, "#ifndef GAP_FFDATA_H\n");
        fprintf(dest, "#define GAP_FFDATA_H\n");
        fprintf(dest, "\n");
        fprintf(dest, "enum {\n");
        fprintf(dest, "    NUM_SHORT_FINITE_FIELDS = %d\n", num_ff);
        fprintf(dest, "};\n");
        fprintf(dest, "\n");
        fprintf(dest, "extern const unsigned long SizeFF[NUM_SHORT_FINITE_FIELDS+1];\n");
        fprintf(dest, "extern const unsigned char DegrFF[NUM_SHORT_FINITE_FIELDS+1];\n");
        fprintf(dest, "extern const unsigned long CharFF[NUM_SHORT_FINITE_FIELDS+1];\n");
        fprintf(dest, "\n");
        fprintf(dest, "#endif // GAP_FFDATA_H\n");
    }
    else {
        fprintf(dest, "#include \"ffdata.h\"\n");
        fprintf(dest, "\n");
        fprintf(dest, "/* Entries are ordered by value of p^d; can use binary search\n");
        fprintf(dest, " * to find them. Indices start at 1.\n");
        fprintf(dest, " */\n");
        fprintf(dest, "\n");
        fprintf(dest, "const unsigned char DegrFF[NUM_SHORT_FINITE_FIELDS+1] = {\n");
        fprintf(dest, " %3d,", 0);
        for (i = 0, j = 1; i <= MAX_FF; i++) {
            if (is_ff[i]) {
                fprintf(dest, "%3d,", deg[i]);
                j++;
                j %= 16;
                if (!j)
                    fprintf(dest, "\n ");
            }
        }
        if (j)
            fprintf(dest, "\n");
        fprintf(dest, "};\n");
        fprintf(dest, "\n");
        fprintf(dest, "const unsigned long CharFF[NUM_SHORT_FINITE_FIELDS+1] = {\n");
        fprintf(dest, " %6d,", 0);
        for (i = 0, j = 1; i <= MAX_FF; i++) {
            if (is_ff[i]) {
                fprintf(dest, "%6d,", ch[i]);
                j++;
                j %= 8;
                if (!j)
                    fprintf(dest, "\n ");
            }
        }
        if (j)
            fprintf(dest, "\n");
        fprintf(dest, "};\n");
        fprintf(dest, "\n");
        fprintf(dest, "const unsigned long SizeFF[NUM_SHORT_FINITE_FIELDS+1] = {\n");
        fprintf(dest, " %6d,", 0);
        for (i = 0, j = 1; i <= MAX_FF; i++) {
            if (is_ff[i]) {
                fprintf(dest, "%6d,", i);
                j++;
                j %= 8;
                if (!j)
                    fprintf(dest, "\n ");
            }
        }
        if (j)
            fprintf(dest, "\n");
        fprintf(dest, "};\n");
    }
}

int main(int argc, char * argv[])
{
    char * opt = argc > 1 ? argv[1] : NULL;
    make_primes();
    make_ff();
    if (!opt)
        emit_code(stdout, 0);
    else if (!strcmp(opt, "h") || !strcmp(opt, ".h") || !strcmp(opt, "-h"))
        emit_code(stdout, 1);
    else if (!strcmp(opt, "c") || !strcmp(opt, ".c") || !strcmp(opt, "-c"))
        emit_code(stdout, 0);
    else {
        fprintf(stderr, "Usage: ffgen [-h|-c]\n");
        fprintf(stderr, "  -h for header file\n");
        fprintf(stderr, "  -c for C source file\n");
        return 1;
    }
    return 0;
}
