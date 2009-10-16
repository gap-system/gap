#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#ifndef WIN32
#include <strings.h>
#else
#include <string.h>
#define strcasecmp _stricmp
#endif

#include "parseopt.h"

typedef struct Option {
  unsigned char alreadyParsed;
  char marker;
  char *longMarker;
  char *comment;
  OptionType type;
  char *defaultv;
  void *res;
} Option;



/* this part is automaticaly updated, do NOT edit below */
/**************************************************************** Prototypes */

/*
 */
static char *optionTypeToString(OptionType ot);
/*
 */
static int convertArg(Options * options, char *arg, Option * option);
/*
 */
static int parseArg(Options * options, int argc, char **argv, int *pos, Option * option, int shift);
/*
 */
static int parseDash(Options * options, int argc, char **argv, int *pos);
/*
 */
static int parseDashCompact(Options * options, int argc, char **argv, int *pos);
/*
 */
static int parseDblDash(Options * options, int argc, char **argv, int *pos);
/*
 */
static void setOptionsDefaults(Options * options);

/************************************************************ End Prototypes */
/* end of automaticaly updated part */



/*
 */
void
initOptions(Options * options, void (*version) (FILE * out), char *usage)
{
  options->version = version;
  options->usage = usage;
  options->optionNb = 0;
  options->optionSz = 0;
  options->options = NULL;
}

/*
 */
void
setOption(Options * options, char marker, char *longMarker, char *comment, OptionType type, char *defaultv, void *res)
{
  Option *option;

  if (options->optionNb == options->optionSz) {
    options->optionSz += 10;
    if (!options->optionNb) {
      options->options = malloc(sizeof(Option) * options->optionSz);
    }
    else {
      options->options = realloc(options->options, sizeof(Option) * options->optionSz);
    }
  }

  option = &(options->options[options->optionNb]);
  options->optionNb++;
  option->alreadyParsed = 0;
  option->marker = marker;
  option->longMarker = longMarker;
  option->comment = comment;
  option->type = type;
  option->defaultv = defaultv;
  option->res = res;
}


/*
 */
static char *
optionTypeToString(OptionType ot)
{
  switch (ot) {
  case OTflag:
    return "";
  case OTbool:
    return "bool";
  case OTint:
    return "int";
  case OTfloat:
    return "float";
  case OTstring:
    return "string";
  default:
    return "??";
  }
}

/*
 */
void
usageOptions(Options * options, char *format,...)
{
  int i;
  Option *option;
  va_list args;

  if (options->version)
    options->version(stderr);
  va_start(args, format);
  if (format) {
    vfprintf(stderr, format, args);
    fprintf(stderr, "\n");
  }
  fprintf(stderr, "%s\n", options->usage);
  for (i = 0; i < options->optionNb; i++) {
    option = &(options->options[i]);
    fprintf(stderr, "   ");
    if (option->marker)
      fprintf(stderr, "-%c ", option->marker);
    if (option->longMarker)
      fprintf(stderr, "--%s", option->longMarker);
    fprintf(stderr, ": %s", optionTypeToString(option->type));
    if (option->defaultv)
      fprintf(stderr, " (%s)", option->defaultv);

    fprintf(stderr, "\n      %s\n", option->comment);
  }
  fflush(stderr);
  va_end(args);
}

/*
 */
static int
convertArg(Options * options, char *arg, Option * option)
{
  void *res = option->res;
  char *end;

  switch (option->type) {
  case OTbool:
    if ((!strcasecmp(arg, "0")) ||
	(!strcasecmp(arg, "nil")) ||
	(!strcasecmp(arg, "false"))) {
      *((unsigned char *) res) = 0;
      return 0;
    }
    else if ((!strcasecmp(arg, "1")) ||
	     (!strcasecmp(arg, "t")) ||
	     (!strcasecmp(arg, "true"))) {
      *((unsigned char *) res) = 1;
      return 0;
    }
    else {
      usageOptions(options, "argument of option -%c must be a boolean.", option->marker);
      return 1;
    }

    break;
  case OTint:
    *((int *) res) = strtol(arg, &end, 10);
    if (end == arg) {
      usageOptions(options, "argument of option -%c must be an int.", option->marker);
      return 1;
    }
    else if (end != arg + strlen(arg)) {
      usageOptions(options, "warning: trash in argumanet of option -%c.", option->marker);
    }
    break;
  case OTfloat:
    *((float *) res) = strtod(arg, &end);
    if (end == arg) {
      usageOptions(options, "argument of option -%c must be a float.", option->marker);
      return 1;
    }
    else if (end != arg + strlen(arg)) {
      usageOptions(options, "warning: trash in argumanet of option -%c.", option->marker);
    }
    break;
  case OTstring:
    *((char **) res) = arg;
    break;
  default:
    return 1;
  }
  return 0;
}

/*
 */
static int
parseArg(Options * options, int argc, char **argv, int *pos, Option * option, int shift)
{
  int ret;
  char *arg = argv[*pos] + shift;

  option->alreadyParsed = 1;
  if (option->type == OTflag) {
    *((unsigned char *) (option->res)) = 1;
    return 0;
  }
  else {
    if (argc <= *pos) {
      usageOptions(options, "given no argument to option -%c.", option->marker);
      return 1;
    }
    else {
      ret = convertArg(options, arg, option);
      if (!ret) {
	(*pos)++;
	return 0;
      }
      else {
	return ret;
      }
    }
  }
}

/*
 */
static int
parseDash(Options * options, int argc, char **argv, int *pos)
{
  int i;
  char m;

  m = argv[*pos][1];
  for (i = 0; i < options->optionNb; i++) {
    if (options->options[i].marker == m) {
      (*pos)++;
      return parseArg(options, argc, argv, pos, &(options->options[i]), 0);
    }
  }
  usageOptions(options, "unknown option %c.", m);
  return 1;
}

/*
 */
static int
parseDashCompact(Options * options, int argc, char **argv, int *pos)
{
  int i, o, found, ret;
  char *comp, m;

  comp = argv[*pos];
  (*pos)++;
  for (o = 1; o < strlen(comp); o++) {
    m = comp[o];
    found = 0;
    for (i = 0; i < options->optionNb; i++) {
      if (options->options[i].marker == m) {
	if (options->options[i].type == OTflag) {
	  if ((ret = parseArg(options, argc, argv, pos, &(options->options[i]), 0))) {
	    return ret;
	  }
	  found = 1;
	  break;
	}
	else {
	  if (o == 1) {
	    (*pos)--;
	    return parseArg(options, argc, argv, pos, &(options->options[i]), 2);
	  }
	  else {
	    usageOptions(options, "option -%c can't be compacted, it needs an argument!", m);
	  }
	}
      }
    }
    if (!found) {
      usageOptions(options, "unknown option %c.", m);
      return 1;
    }
  }
  return 0;
}

/*
 */
static int
parseDblDash(Options * options, int argc, char **argv, int *pos)
{
  int i;
  char *m;

  m = argv[*pos];
  for (i = 0; i < options->optionNb; i++) {
    if (!strcasecmp(options->options[i].longMarker, m + 2)) {
      (*pos)++;
      return parseArg(options, argc, argv, pos, &(options->options[i]), 0);
    }
  }
  usageOptions(options, "unknown option %s.", m);
  return 1;
}


/*
 */
static void
setOptionsDefaults(Options * options)
{
  Option *option;
  int i;

  for (i = 0; i < options->optionNb; i++) {
    option = &(options->options[i]);
    if (!(option->alreadyParsed) && (option->defaultv)) {
      convertArg(options, option->defaultv, option);
    }
  }
}

/*
 */
int
parseOptions(Options * options, int argc, char **argv, int *unparsedNb, char ***unparsed)
{
  int i = 1, ret = 0;

  setOptionsDefaults(options);
  while (i < argc) {
    if ((argv)[i][0] == '-') {
      if ((argv)[i][1] == '-') {
	if ((ret = parseDblDash(options, argc, argv, &i))) {
	  break;
	}
      }
      else {
	if (strlen(argv[i]) > 2) {
	  if ((ret = parseDashCompact(options, argc, argv, &i)))
	    break;
	}
	else {
	  if ((ret = parseDash(options, argc, argv, &i)))
	    break;
	}
      }
    }
    else {
      break;
    }
  }
  *unparsedNb = argc - i;
  *unparsed = &argv[i];
  return ret;
}
