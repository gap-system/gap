#ifndef ORBIT
#define ORBIT

extern FIXUP1 minimalPointOfOrbit(
   PermGroup *G,
   Unsigned level,
   Unsigned point,
   UnsignedS *minPointOfOrbit,
   UnsignedS *minPointKnown,
   UnsignedS *minPointKnownCount,
   UnsignedS *invOmega)
;

#endif
