#include <raylib.h>
#include "raygui.h"
#include <stdlib.h>
#include "spinel/runtime.h"

/* Mirror the raylib adapter's embedded-Color wrapper (used by GuiColorPicker). */
typedef struct sp_Color_s {
  sp_int cls_id;
  Color c;
} sp_Color;

/* raygui_adapter.c — sp_ shims for Spinel AOT
 *
 * raygui takes Rectangle (and other structs) by value and returns int/bool with
 * pointer out-parameters; Spinel FFI cannot pass structs by value, so every
 * control used by the scenes gets a float/pointer shim here.
 */

/* ---- global state ---- */
void sp_GuiLock(void) { GuiLock(); }
void sp_GuiUnlock(void) { GuiUnlock(); }
void sp_GuiEnable(void) { GuiEnable(); }
void sp_GuiDisable(void) { GuiDisable(); }
void sp_GuiSetAlpha(float alpha) { GuiSetAlpha(alpha); }
void sp_GuiSetState(int state) { GuiSetState(state); }
void sp_GuiSetStyle(int control, int property, int value) { GuiSetStyle(control, property, value); }
int sp_GuiGetStyle(int control, int property) { return GuiGetStyle(control, property); }
void sp_GuiSetFont(void *font) { GuiSetFont(*(Font *)font); }
void sp_GuiLoadStyle(const char *fileName) { GuiLoadStyle(fileName); }
void sp_GuiLoadStyleDefault(void) { GuiLoadStyleDefault(); }

/* ---- controls (Rectangle by value -> floats) ---- */
int sp_GuiButton(float x, float y, float w, float h, const char *text) {
  return GuiButton((Rectangle){ x, y, w, h }, text);
}
int sp_GuiLabel(float x, float y, float w, float h, const char *text) {
  return GuiLabel((Rectangle){ x, y, w, h }, text);
}
int sp_GuiLabelButton(float x, float y, float w, float h, const char *text) {
  return GuiLabelButton((Rectangle){ x, y, w, h }, text);
}
int sp_GuiGroupBox(float x, float y, float w, float h, const char *text) {
  return GuiGroupBox((Rectangle){ x, y, w, h }, text);
}
int sp_GuiLine(float x, float y, float w, float h, const char *text) {
  return GuiLine((Rectangle){ x, y, w, h }, text);
}
int sp_GuiPanel(float x, float y, float w, float h, const char *text) {
  return GuiPanel((Rectangle){ x, y, w, h }, text);
}
int sp_GuiStatusBar(float x, float y, float w, float h, const char *text) {
  return GuiStatusBar((Rectangle){ x, y, w, h }, text);
}
int sp_GuiDummyRec(float x, float y, float w, float h, const char *text) {
  return GuiDummyRec((Rectangle){ x, y, w, h }, text);
}
int sp_GuiCheckBox(float x, float y, float w, float h, const char *text,
                   int *checked) {
  bool b = (*checked != 0);
  int r = GuiCheckBox((Rectangle){ x, y, w, h }, text, &b);
  *checked = b ? 1 : 0;
  return r;
}
int sp_GuiComboBox(float x, float y, float w, float h, const char *text,
                   int *active) {
  return GuiComboBox((Rectangle){ x, y, w, h }, text, active);
}
int sp_GuiDropdownBox(float x, float y, float w, float h, const char *text,
                      int *active, int editMode) {
  return GuiDropdownBox((Rectangle){ x, y, w, h }, text, active, editMode != 0);
}
int sp_GuiSpinner(float x, float y, float w, float h, const char *text,
                  int *value, int minValue, int maxValue, int editMode) {
  return GuiSpinner((Rectangle){ x, y, w, h }, text, value, minValue, maxValue,
                    editMode != 0);
}
int sp_GuiValueBox(float x, float y, float w, float h, const char *text,
                   int *value, int minValue, int maxValue, int editMode) {
  return GuiValueBox((Rectangle){ x, y, w, h }, text, value, minValue, maxValue,
                     editMode != 0);
}
int sp_GuiSlider(float x, float y, float w, float h, const char *textLeft,
                 const char *textRight, float *value, float minValue,
                 float maxValue) {
  return GuiSlider((Rectangle){ x, y, w, h }, textLeft, textRight, value,
                   minValue, maxValue);
}
int sp_GuiSliderBar(float x, float y, float w, float h, const char *textLeft,
                    const char *textRight, float *value, float minValue,
                    float maxValue) {
  return GuiSliderBar((Rectangle){ x, y, w, h }, textLeft, textRight, value,
                      minValue, maxValue);
}
int sp_GuiProgressBar(float x, float y, float w, float h, const char *textLeft,
                      const char *textRight, float *value, float minValue,
                      float maxValue) {
  return GuiProgressBar((Rectangle){ x, y, w, h }, textLeft, textRight, value,
                        minValue, maxValue);
}
int sp_GuiWindowBox(float x, float y, float w, float h, const char *title) {
  return GuiWindowBox((Rectangle){ x, y, w, h }, title);
}
int sp_GuiMessageBox(float x, float y, float w, float h, const char *title,
                     const char *message, const char *btnText,
                     int *btnActive) {
  return GuiMessageBox((Rectangle){ x, y, w, h }, title, message, btnText,
                       btnActive);
}
int sp_GuiListView(float x, float y, float w, float h, const char *text,
                   int *scrollIndex, int *active) {
  return GuiListView((Rectangle){ x, y, w, h }, text, scrollIndex, active);
}
int sp_GuiColorPicker(float x, float y, float w, float h, const char *text,
                      void *color) {
  return GuiColorPicker((Rectangle){ x, y, w, h }, text, &((sp_Color *)color)->c);
}
int sp_GuiGrid(float x, float y, float w, float h, const char *text,
               float spacing, int subdivs, void *mouseCell) {
  return GuiGrid((Rectangle){ x, y, w, h }, text, spacing, subdivs,
                 (Vector2 *)mouseCell);
}

/* Value-returning variants for Spinel (avoid pointer out-params under AOT).
 * Each returns the control's click/press state and writes the updated value
 * into a module-level slot read back with sp_Gui_GetFloat/sp_Gui_GetInt. */
static float sp_gui_float_result;
static int sp_gui_int_result;

int sp_GuiCheckBoxValue(float x, float y, float w, float h, const char *text,
                        int checked) {
  bool b = checked != 0;
  int r = GuiCheckBox((Rectangle){ x, y, w, h }, text, &b);
  sp_gui_int_result = b ? 1 : 0;
  return r;
}
int sp_GuiSliderBarValue(float x, float y, float w, float h, const char *l,
                         const char *r, float value, float lo, float hi) {
  float v = value;
  int res = GuiSliderBar((Rectangle){ x, y, w, h }, l, r, &v, lo, hi);
  sp_gui_float_result = v;
  return res;
}
int sp_GuiSliderValue(float x, float y, float w, float h, const char *l,
                      const char *r, float value, float lo, float hi) {
  float v = value;
  int res = GuiSlider((Rectangle){ x, y, w, h }, l, r, &v, lo, hi);
  sp_gui_float_result = v;
  return res;
}
int sp_GuiSpinnerValue(float x, float y, float w, float h, const char *text,
                       int value, int lo, int hi, int edit) {
  int v = value;
  int res = GuiSpinner((Rectangle){ x, y, w, h }, text, &v, lo, hi, edit != 0);
  sp_gui_int_result = v;
  return res;
}
int sp_GuiDropdownBoxValue(float x, float y, float w, float h, const char *text,
                           int active, int edit) {
  int v = active;
  int res = GuiDropdownBox((Rectangle){ x, y, w, h }, text, &v, edit != 0);
  sp_gui_int_result = v;
  return res;
}
int sp_GuiComboBoxValue(float x, float y, float w, float h, const char *text,
                        int active) {
  int v = active;
  int res = GuiComboBox((Rectangle){ x, y, w, h }, text, &v);
  sp_gui_int_result = v;
  return res;
}
int sp_GuiListViewValue(float x, float y, float w, float h, const char *text,
                        int scroll, int active) {
  int s = scroll;
  int a = active;
  int res = GuiListView((Rectangle){ x, y, w, h }, text, &s, &a);
  sp_gui_int_result = a;
  return res;
}
float sp_Gui_GetFloat(void) { return sp_gui_float_result; }
int sp_Gui_GetInt(void) { return sp_gui_int_result; }


/* Additional controls for the gui_controls scene. */
int sp_GuiTextBoxFloat(float x, float y, float w, float h, const char *text,
                       int editMode) {
  /* Read-only display box; editing handled via static buffer. */
  static char buf[1024];
  int i = 0;
  if (text != NULL) {
    while (text[i] != '\0' && i < 1023) { buf[i] = text[i]; i++; }
  }
  buf[i] = '\0';
  return GuiTextBox((Rectangle){ x, y, w, h }, buf, 1024, editMode != 0);
}
int sp_GuiScrollPanel(float x, float y, float w, float h, const char *text,
                      float cx, float cy, float cw, float ch) {
  Rectangle view = { 0 };
  Vector2 scroll = { 0 };
  return GuiScrollPanel((Rectangle){ x, y, w, h }, text,
                        (Rectangle){ cx, cy, cw, ch }, &scroll, &view);
}
int sp_GuiToggleGroup(float x, float y, float w, float h, const char *text,
                      int active) {
  int a = active;
  int r = GuiToggleGroup((Rectangle){ x, y, w, h }, text, &a);
  sp_gui_int_result = a;
  return r;
}
int sp_GuiToggleSlider(float x, float y, float w, float h, const char *text,
                       int active) {
  int a = active;
  int r = GuiToggleSlider((Rectangle){ x, y, w, h }, text, &a);
  sp_gui_int_result = a;
  return r;
}
int sp_GuiColorBarAlpha(float x, float y, float w, float h, const char *text,
                        float alpha) {
  float a = alpha;
  int r = GuiColorBarAlpha((Rectangle){ x, y, w, h }, text, &a);
  sp_gui_float_result = a;
  return r;
}
/* Color picker updating an embedded sp_Color via a value-returning int. */
static unsigned char sp_gui_color_r = 255, sp_gui_color_g = 0,
                     sp_gui_color_b = 0, sp_gui_color_a = 255;
void sp_GuiColorPickerSet(int r, int g, int b, int a) {
  sp_gui_color_r = r; sp_gui_color_g = g; sp_gui_color_b = b; sp_gui_color_a = a;
}
int sp_GuiColorPickerValue(float x, float y, float w, float h, const char *text) {
  Color c = { sp_gui_color_r, sp_gui_color_g, sp_gui_color_b, sp_gui_color_a };
  int r = GuiColorPicker((Rectangle){ x, y, w, h }, text, &c);
  sp_gui_color_r = c.r; sp_gui_color_g = c.g; sp_gui_color_b = c.b; sp_gui_color_a = c.a;
  return r;
}
int sp_Gui_GetColorR(void) { return sp_gui_color_r; }
int sp_Gui_GetColorG(void) { return sp_gui_color_g; }
int sp_Gui_GetColorB(void) { return sp_gui_color_b; }
int sp_Gui_GetColorA(void) { return sp_gui_color_a; }
int sp_GuiValueBoxValue(float x, float y, float w, float h, const char *text,
                        int value, int lo, int hi, int edit) {
  int v = value;
  int r = GuiValueBox((Rectangle){ x, y, w, h }, text, &v, lo, hi, edit != 0);
  sp_gui_int_result = v;
  return r;
}
const char *sp_GuiIconText(int iconId, const char *text) {
  return GuiIconText(iconId, text);
}

int sp_GuiProgressBarValue(float x, float y, float w, float h, const char *l,
                           const char *r, float value, float lo, float hi) {
  float v = value;
  int res = GuiProgressBar((Rectangle){ x, y, w, h }, l, r, &v, lo, hi);
  sp_gui_float_result = v;
  return res;
}
