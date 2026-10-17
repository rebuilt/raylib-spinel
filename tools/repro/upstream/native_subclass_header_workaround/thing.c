#include "thing.h"
#include <stdlib.h>

void sp_Thing_scan(void *p) { (void)p; }

sp_Thing *sp_Thing_new(sp_int cls_id, sp_int v) {
  sp_Thing *t = (sp_Thing *)sp_gc_alloc(sizeof(sp_Thing), NULL, sp_Thing_scan);
  t->cls_id = cls_id;
  t->v = v;
  return t;
}

sp_int sp_Thing_value(sp_Thing *t) { return t->v; }

/* the in-place twin of sp_Thing_new, which a subclass's constructor needs
   (the convention is written down only in stringio's C) */
void sp_Thing_init(sp_Thing *t, sp_int cls_id, sp_int v) {
  t->cls_id = cls_id;
  t->v = v;
}
