
#ifndef PARSEOPT_H
#define PARSEOPT_H


typedef enum OptionType {
  OTbad = 0, OTflag, OTbool, OTint, OTfloat, OTstring, OTlast
} OptionType;


typedef struct Options {
  void (*version) (FILE *);
  char *usage;
  int optionNb;
  int optionSz;
  struct Option *options;
} Options;


/**************************************************************** Prototypes */


/*
 */
void initOptions(Options * options, void (*version) (FILE * out), char *usage);

/*
 */
void setOption(Options * options, char marker, char *longMarker, char *comment, OptionType type, char *defaultv, void *res);

/*
 */
void usageOptions(Options * options, char *format,...);

/*
 */
int parseOptions(Options * options, int argc, char **argv, int *unparsedNb, char ***unparsed);


/************************************************************ End Prototypes */



#endif /* PARSEOPT_H */
