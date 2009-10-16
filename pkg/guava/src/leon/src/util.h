#ifndef UTIL
#define UTIL

extern void parseLibraryName(
   const char *const inputString,
   const char *const prefix,
   const char *const suffix,
   char *const libraryFileName,
   char *const libraryName)
;

extern void showLimits(void)
;

extern void checkCompileOptions(
   char *localFileName,
   CompileOptions *mainOpts,
   CompileOptions *localOpts)
;

#endif
