#ifndef THING_H
#define THING_H
#include "spinel/runtime.h"

typedef struct sp_Thing_s {
  sp_int cls_id;
  sp_int v;
} sp_Thing;

void sp_Thing_scan(void *p);
void sp_Thing_init(sp_Thing *t, sp_int cls_id, sp_int v);
#endif
