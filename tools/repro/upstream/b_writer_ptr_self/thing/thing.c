/* repro.c -- carried C for the block-parameter repro.
 *
 * One native class (a "Path B typed object", the shape spinel's own bundled
 * packages use): the struct lives here with the object header first, the
 * compiler holds pointers and stamps cls_id through the constructor.
 */
#include "spinel/runtime.h"

typedef struct sp_Thing_s {
  sp_int cls_id;
  sp_int v;
} sp_Thing;

sp_Thing *sp_Thing_new(sp_int cls_id, sp_int v) {
  sp_Thing *t = (sp_Thing *)sp_gc_alloc(sizeof(sp_Thing), NULL, NULL);
  t->cls_id = cls_id;
  t->v = v;
  return t;
}

sp_int sp_Thing_value(sp_Thing *t) { return t->v; }

/* a :ptr-taking helper (the shape the real library uses for interior
 * pointers: ffi_func :x_addr, [:ptr], :long). */
#include <stdint.h>
long sp_Thing_addr(void *t) { return (long)(intptr_t)t; }

/* a native setter, so the Ruby writer below has something to write. */
void sp_Thing_set_value(sp_Thing *t, sp_int v) { t->v = v; }
