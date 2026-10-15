#include <raylib.h>
#include "raygui.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "spinel/runtime.h"
#include "rl_handle_views.h"

/* Mirror the raylib adapter's embedded-Color wrapper (used by GuiColorPicker). */
typedef struct rl_Color_s {
  sp_int cls_id;
  Color c;
} rl_Color;

/* raygui_adapter.c — rl_ shims for Spinel AOT
 *
 * raygui takes Rectangle (and other structs) by value and returns int/bool with
 * pointer out-parameters; Spinel FFI cannot pass structs by value, so every
 * control used by the scenes gets a float/pointer shim here.
 */

/* ---- global state ---- */
void rl_GuiLock(void) { GuiLock(); }
void rl_GuiUnlock(void) { GuiUnlock(); }
void rl_GuiEnable(void) { GuiEnable(); }
void rl_GuiDisable(void) { GuiDisable(); }
void rl_GuiSetAlpha(float alpha) { GuiSetAlpha(alpha); }
void rl_GuiSetState(int state) { GuiSetState(state); }
void rl_GuiSetStyle(int control, int property, int value) { GuiSetStyle(control, property, value); }
int rl_GuiGetStyle(int control, int property) { return GuiGetStyle(control, property); }
void rl_GuiSetFont(void *font) { GuiSetFont(*RL_FONT(font)); }
void rl_GuiLoadStyle(const char *fileName) { GuiLoadStyle(fileName); }
void rl_GuiLoadStyleDefault(void) { GuiLoadStyleDefault(); }

/* ---- controls (Rectangle by value -> floats) ---- */
int rl_GuiButton(float x, float y, float w, float h, const char *text) {
  return GuiButton((Rectangle){ x, y, w, h }, text);
}
int rl_GuiLabel(float x, float y, float w, float h, const char *text) {
  return GuiLabel((Rectangle){ x, y, w, h }, text);
}
int rl_GuiLabelButton(float x, float y, float w, float h, const char *text) {
  return GuiLabelButton((Rectangle){ x, y, w, h }, text);
}
int rl_GuiGroupBox(float x, float y, float w, float h, const char *text) {
  return GuiGroupBox((Rectangle){ x, y, w, h }, text);
}
int rl_GuiLine(float x, float y, float w, float h, const char *text) {
  return GuiLine((Rectangle){ x, y, w, h }, text);
}
int rl_GuiPanel(float x, float y, float w, float h, const char *text) {
  return GuiPanel((Rectangle){ x, y, w, h }, text);
}
int rl_GuiStatusBar(float x, float y, float w, float h, const char *text) {
  return GuiStatusBar((Rectangle){ x, y, w, h }, text);
}
int rl_GuiDummyRec(float x, float y, float w, float h, const char *text) {
  return GuiDummyRec((Rectangle){ x, y, w, h }, text);
}
int rl_GuiCheckBox(float x, float y, float w, float h, const char *text,
                   int *checked) {
  bool b = (*checked != 0);
  int r = GuiCheckBox((Rectangle){ x, y, w, h }, text, &b);
  *checked = b ? 1 : 0;
  return r;
}
int rl_GuiComboBox(float x, float y, float w, float h, const char *text,
                   int *active) {
  return GuiComboBox((Rectangle){ x, y, w, h }, text, active);
}
int rl_GuiDropdownBox(float x, float y, float w, float h, const char *text,
                      int *active, int editMode) {
  return GuiDropdownBox((Rectangle){ x, y, w, h }, text, active, editMode != 0);
}
int rl_GuiSpinner(float x, float y, float w, float h, const char *text,
                  int *value, int minValue, int maxValue, int editMode) {
  return GuiSpinner((Rectangle){ x, y, w, h }, text, value, minValue, maxValue,
                    editMode != 0);
}
int rl_GuiValueBox(float x, float y, float w, float h, const char *text,
                   int *value, int minValue, int maxValue, int editMode) {
  return GuiValueBox((Rectangle){ x, y, w, h }, text, value, minValue, maxValue,
                     editMode != 0);
}
int rl_GuiSlider(float x, float y, float w, float h, const char *textLeft,
                 const char *textRight, float *value, float minValue,
                 float maxValue) {
  return GuiSlider((Rectangle){ x, y, w, h }, textLeft, textRight, value,
                   minValue, maxValue);
}
int rl_GuiSliderBar(float x, float y, float w, float h, const char *textLeft,
                    const char *textRight, float *value, float minValue,
                    float maxValue) {
  return GuiSliderBar((Rectangle){ x, y, w, h }, textLeft, textRight, value,
                      minValue, maxValue);
}
int rl_GuiProgressBar(float x, float y, float w, float h, const char *textLeft,
                      const char *textRight, float *value, float minValue,
                      float maxValue) {
  return GuiProgressBar((Rectangle){ x, y, w, h }, textLeft, textRight, value,
                        minValue, maxValue);
}
int rl_GuiWindowBox(float x, float y, float w, float h, const char *title) {
  return GuiWindowBox((Rectangle){ x, y, w, h }, title);
}
int rl_GuiMessageBox(float x, float y, float w, float h, const char *title,
                     const char *message, const char *btnText,
                     int *btnActive) {
  return GuiMessageBox((Rectangle){ x, y, w, h }, title, message, btnText,
                       btnActive);
}
int rl_GuiListView(float x, float y, float w, float h, const char *text,
                   int *scrollIndex, int *active) {
  return GuiListView((Rectangle){ x, y, w, h }, text, scrollIndex, active);
}
int rl_GuiColorPicker(float x, float y, float w, float h, const char *text,
                      void *color) {
  return GuiColorPicker((Rectangle){ x, y, w, h }, text, &((rl_Color *)color)->c);
}
int rl_GuiGrid(float x, float y, float w, float h, const char *text,
               float spacing, int subdivs, void *mouseCell) {
  return GuiGrid((Rectangle){ x, y, w, h }, text, spacing, subdivs,
                 (Vector2 *)mouseCell);
}

/* Value-returning variants for Spinel (avoid pointer out-params under AOT).
 * Each returns the control's click/press state and writes the updated value
 * into a module-level slot read back with rl_Gui_GetFloat/rl_Gui_GetInt. */
static float sp_gui_float_result;
static int sp_gui_int_result;
/* Extra result slots (multi-value controls such as the tab/list views;
 * read back with rl_Gui_GetInt2/rl_Gui_GetInt3). */
static int sp_gui_int_result2;
static int sp_gui_int_result3;

int rl_GuiCheckBoxValue(float x, float y, float w, float h, const char *text,
                        int checked) {
  bool b = checked != 0;
  int r = GuiCheckBox((Rectangle){ x, y, w, h }, text, &b);
  sp_gui_int_result = b ? 1 : 0;
  return r;
}
int rl_GuiSliderBarValue(float x, float y, float w, float h, const char *l,
                         const char *r, float value, float lo, float hi) {
  float v = value;
  int res = GuiSliderBar((Rectangle){ x, y, w, h }, l, r, &v, lo, hi);
  sp_gui_float_result = v;
  return res;
}
int rl_GuiSliderValue(float x, float y, float w, float h, const char *l,
                      const char *r, float value, float lo, float hi) {
  float v = value;
  int res = GuiSlider((Rectangle){ x, y, w, h }, l, r, &v, lo, hi);
  sp_gui_float_result = v;
  return res;
}
int rl_GuiSpinnerValue(float x, float y, float w, float h, const char *text,
                       int value, int lo, int hi, int edit) {
  int v = value;
  int res = GuiSpinner((Rectangle){ x, y, w, h }, text, &v, lo, hi, edit != 0);
  sp_gui_int_result = v;
  return res;
}
int rl_GuiDropdownBoxValue(float x, float y, float w, float h, const char *text,
                           int active, int edit) {
  int v = active;
  int res = GuiDropdownBox((Rectangle){ x, y, w, h }, text, &v, edit != 0);
  sp_gui_int_result = v;
  return res;
}
int rl_GuiComboBoxValue(float x, float y, float w, float h, const char *text,
                        int active) {
  int v = active;
  int res = GuiComboBox((Rectangle){ x, y, w, h }, text, &v);
  sp_gui_int_result = v;
  return res;
}
int rl_GuiListViewValue(float x, float y, float w, float h, const char *text,
                        int scroll, int active) {
  int s = scroll;
  int a = active;
  int res = GuiListView((Rectangle){ x, y, w, h }, text, &s, &a);
  sp_gui_int_result = a;
  sp_gui_int_result2 = s;
  return res;
}
float rl_Gui_GetFloat(void) { return sp_gui_float_result; }
int rl_Gui_GetInt(void) { return sp_gui_int_result; }


/* Additional controls for the gui_controls scene. */
int rl_GuiTextBoxFloat(float x, float y, float w, float h, const char *text,
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
/* Scalar shape (the scene ports): x, y, w, h, text, content x/y/w/h. */
int rl_GuiScrollPanelScalar(float x, float y, float w, float h, const char *text,
                            float cx, float cy, float cw, float ch) {
  Rectangle view = { 0 };
  Vector2 scroll = { 0 };
  return GuiScrollPanel((Rectangle){ x, y, w, h }, text,
                        (Rectangle){ cx, cy, cw, ch }, &scroll, &view);
}
int rl_GuiScrollPanel(float x, float y, float w, float h, const char *text,
                      void *content, void *scroll, void *view) {
  /* gem shape: content is a Rectangle, scroll/view are written back */
  Rectangle c = content ? *(Rectangle *)content : (Rectangle){ 0, 0, 0, 0 };
  Vector2 s = scroll ? *(Vector2 *)scroll : (Vector2){ 0, 0 };
  Rectangle v = view ? *(Rectangle *)view : (Rectangle){ 0, 0, 0, 0 };
  int r = GuiScrollPanel((Rectangle){ x, y, w, h }, text, c, &s, &v);
  if (scroll) *(Vector2 *)scroll = s;
  if (view) *(Rectangle *)view = v;
  return r;
}
int rl_GuiToggleGroup(float x, float y, float w, float h, const char *text,
                      int active) {
  int a = active;
  int r = GuiToggleGroup((Rectangle){ x, y, w, h }, text, &a);
  sp_gui_int_result = a;
  return r;
}
int rl_GuiToggleSlider(float x, float y, float w, float h, const char *text,
                       int active) {
  int a = active;
  int r = GuiToggleSlider((Rectangle){ x, y, w, h }, text, &a);
  sp_gui_int_result = a;
  return r;
}
int rl_GuiColorBarAlpha(float x, float y, float w, float h, const char *text,
                        float alpha) {
  float a = alpha;
  int r = GuiColorBarAlpha((Rectangle){ x, y, w, h }, text, &a);
  sp_gui_float_result = a;
  return r;
}
/* Color picker updating an embedded rl_Color via a value-returning int. */
static unsigned char sp_gui_color_r = 255, sp_gui_color_g = 0,
                     sp_gui_color_b = 0, sp_gui_color_a = 255;
void rl_GuiColorPickerSet(int r, int g, int b, int a) {
  sp_gui_color_r = r; sp_gui_color_g = g; sp_gui_color_b = b; sp_gui_color_a = a;
}
int rl_GuiColorPickerValue(float x, float y, float w, float h, const char *text) {
  Color c = { sp_gui_color_r, sp_gui_color_g, sp_gui_color_b, sp_gui_color_a };
  int r = GuiColorPicker((Rectangle){ x, y, w, h }, text, &c);
  sp_gui_color_r = c.r; sp_gui_color_g = c.g; sp_gui_color_b = c.b; sp_gui_color_a = c.a;
  return r;
}
int rl_Gui_GetColorR(void) { return sp_gui_color_r; }
int rl_Gui_GetColorG(void) { return sp_gui_color_g; }
int rl_Gui_GetColorB(void) { return sp_gui_color_b; }
int rl_Gui_GetColorA(void) { return sp_gui_color_a; }
int rl_GuiValueBoxValue(float x, float y, float w, float h, const char *text,
                        int value, int lo, int hi, int edit) {
  int v = value;
  int r = GuiValueBox((Rectangle){ x, y, w, h }, text, &v, lo, hi, edit != 0);
  sp_gui_int_result = v;
  return r;
}
const char *rl_GuiIconText(int iconId, const char *text) {
  return GuiIconText(iconId, text);
}

int rl_GuiProgressBarValue(float x, float y, float w, float h, const char *l,
                           const char *r, float value, float lo, float hi) {
  float v = value;
  int res = GuiProgressBar((Rectangle){ x, y, w, h }, l, r, &v, lo, hi);
  sp_gui_float_result = v;
  return res;
}

/* ================================================================
 * Coverage completion: the rest of the raygui 5.0 surface. Same
 * conventions as above (Rectangle by value -> floats; pointer out-params
 * become return-value slots read back with the rl_Gui_Get* helpers).
 * ================================================================ */

static char sp_gui_text_result[1024];
static float sp_gui_hsv_h, sp_gui_hsv_s, sp_gui_hsv_v;

/* ---- global state, tooltips, metrics, icons ---- */
int rl_GuiIsLocked(void) { return GuiIsLocked() ? 1 : 0; }
int rl_GuiGetState(void) { return GuiGetState(); }
void rl_GuiEnableTooltip(void) { GuiEnableTooltip(); }
void rl_GuiDisableTooltip(void) { GuiDisableTooltip(); }
void rl_GuiSetTooltip(const char *tooltip) { GuiSetTooltip(tooltip); }
void rl_GuiSetIconScale(int scale) { GuiSetIconScale(scale); }
int rl_GuiGetTextWidth(const char *text) { return GuiGetTextWidth(text); }

/* GuiGetFont returns a Font by value; hand back a pointer to a static copy
 * that can be fed straight back to rl_GuiSetFont (which dereferences it). */
void *rl_GuiGetFont(void) {
  static Font f;
  f = GuiGetFont();
  return &f;
}
void *rl_GuiGetIcons(void) { return GuiGetIcons(); }
void *rl_GuiLoadIcons(const char *fileName, int loadIconsName) {
  return GuiLoadIcons(fileName, loadIconsName != 0);
}
void *rl_GuiLoadIconsFromMemory(void *fileData, int dataSize,
                                int loadIconsName) {
  return GuiLoadIconsFromMemory((const unsigned char *)fileData, dataSize,
                                loadIconsName != 0);
}
void rl_GuiLoadStyleFromMemory(void *fileData, int dataSize) {
  GuiLoadStyleFromMemory((const unsigned char *)fileData, dataSize);
}
void rl_GuiDrawIcon(int iconId, int posX, int posY, int pixelSize, void *color) {
  GuiDrawIcon(iconId, posX, posY, pixelSize, ((rl_Color *)color)->c);
}

/* ---- value-returning controls ---- */
int rl_GuiToggle(float x, float y, float w, float h, const char *text,
                 int active) {
  bool b = active != 0;
  int r = GuiToggle((Rectangle){ x, y, w, h }, text, &b);
  sp_gui_int_result = b ? 1 : 0;
  return r;
}
int rl_GuiValueBoxFloat(float x, float y, float w, float h, const char *text,
                        float value, int edit) {
  char buf[64];
  snprintf(buf, sizeof buf, "%g", value);
  float v = value;
  int r = GuiValueBoxFloat((Rectangle){ x, y, w, h }, text, buf, &v, edit != 0);
  sp_gui_float_result = v;
  return r;
}
int rl_GuiColorBarHue(float x, float y, float w, float h, const char *text,
                      float value) {
  float v = value;
  int r = GuiColorBarHue((Rectangle){ x, y, w, h }, text, &v);
  sp_gui_float_result = v;
  return r;
}
int rl_GuiColorPanel(float x, float y, float w, float h, const char *text) {
  Color c = { sp_gui_color_r, sp_gui_color_g, sp_gui_color_b, sp_gui_color_a };
  int r = GuiColorPanel((Rectangle){ x, y, w, h }, text, &c);
  sp_gui_color_r = c.r; sp_gui_color_g = c.g;
  sp_gui_color_b = c.b; sp_gui_color_a = c.a;
  return r;
}
int rl_GuiColorPanelHSV(float x, float y, float w, float h, const char *text) {
  Vector3 hsv = { sp_gui_hsv_h, sp_gui_hsv_s, sp_gui_hsv_v };
  int r = GuiColorPanelHSV((Rectangle){ x, y, w, h }, text, &hsv);
  sp_gui_hsv_h = hsv.x; sp_gui_hsv_s = hsv.y; sp_gui_hsv_v = hsv.z;
  return r;
}
int rl_GuiColorPickerHSV(float x, float y, float w, float h, const char *text) {
  Vector3 hsv = { sp_gui_hsv_h, sp_gui_hsv_s, sp_gui_hsv_v };
  int r = GuiColorPickerHSV((Rectangle){ x, y, w, h }, text, &hsv);
  sp_gui_hsv_h = hsv.x; sp_gui_hsv_s = hsv.y; sp_gui_hsv_v = hsv.z;
  return r;
}
void rl_Gui_SetHsv(float h, float s, float v) {
  sp_gui_hsv_h = h; sp_gui_hsv_s = s; sp_gui_hsv_v = v;
}
float rl_Gui_GetHsvH(void) { return sp_gui_hsv_h; }
float rl_Gui_GetHsvS(void) { return sp_gui_hsv_s; }
float rl_Gui_GetHsvV(void) { return sp_gui_hsv_v; }

/* ---- editable text buffers ---- */
int rl_GuiTextBox(float x, float y, float w, float h, const char *text,
                  int textSize, int edit) {
  int i = 0;
  if (text != NULL) {
    while (text[i] != '\0' && i < 1023) { sp_gui_text_result[i] = text[i]; i++; }
  }
  sp_gui_text_result[i] = '\0';
  int r = GuiTextBox((Rectangle){ x, y, w, h }, sp_gui_text_result, 1024,
                     edit != 0);
  /* gem semantics: the caller's buffer (an FFI::MemoryPointer there, a String
   * or buffer here) receives the edited text. */
  if (text != NULL && edit != 0) {
    size_t want = textSize > 0 ? (size_t)textSize - 1 : (size_t)1023;
    size_t n = 0;
    while (sp_gui_text_result[n] != '\0' && n < want) { ((char *)text)[n] = sp_gui_text_result[n]; n++; }
    ((char *)text)[n] = '\0';
  }
  return r;
}
int rl_GuiTextInputBox(float x, float y, float w, float h, const char *title,
                       const char *message, void *text, int textSize,
                       const char *btnText, void *btnActive, void *secretView) {
  /* gem shape: text / btnActive / secretView are written back to the caller */
  size_t cap = textSize > 0 ? (size_t)textSize - 1 : (size_t)1023;
  size_t i = 0;
  if (text != NULL) {
    const char *t = (const char *)text;
    while (t[i] != '\0' && i < cap) { sp_gui_text_result[i] = t[i]; i++; }
  }
  sp_gui_text_result[i] = '\0';
  int b = btnActive != NULL ? *(int *)btnActive : 0;
  bool secret = secretView != NULL ? *(bool *)secretView : false;
  int r = GuiTextInputBox((Rectangle){ x, y, w, h }, title, message,
                          sp_gui_text_result, 1024, btnText, &b, &secret);
  if (text != NULL) {
    size_t n = 0;
    while (sp_gui_text_result[n] != '\0' && n < cap) {
      ((char *)text)[n] = sp_gui_text_result[n];
      n++;
    }
    ((char *)text)[n] = '\0';
  }
  if (btnActive != NULL) *(int *)btnActive = b;
  if (secretView != NULL) *(bool *)secretView = secret;
  return r;
}
const char *rl_Gui_GetText(void) { return sp_gui_text_result; }

/* ---- text-list controls (char** built from a ';'-delimited string) ---- */
static char sp_gui_list_buf[1024];
static char *sp_gui_list_items[64];
static char **sp_gui_split_text(const char *text, int *count_out) {
  int n = 0;
  if (text != NULL) {
    size_t len = strlen(text);
    if (len > sizeof(sp_gui_list_buf) - 1) len = sizeof(sp_gui_list_buf) - 1;
    memcpy(sp_gui_list_buf, text, len);
    sp_gui_list_buf[len] = '\0';
    char *p = sp_gui_list_buf;
    while (*p != '\0' && n < 64) {
      sp_gui_list_items[n++] = p;
      char *semi = strchr(p, ';');
      if (semi == NULL) break;
      *semi = '\0';
      p = semi + 1;
    }
  }
  *count_out = n;
  return sp_gui_list_items;
}
int rl_GuiListViewEx(float x, float y, float w, float h, const char *text,
                     int count, int scrollIndex, int active, int focus) {
  (void)count;
  int n = 0;
  char **items = sp_gui_split_text(text, &n);
  int s = scrollIndex, a = active, f = focus;
  int r = GuiListViewEx((Rectangle){ x, y, w, h }, items, n, &s, &a, &f);
  sp_gui_int_result = a;
  sp_gui_int_result2 = s;
  sp_gui_int_result3 = f;
  return r;
}
int rl_GuiTabBar(float x, float y, float w, float h, const char *text,
                 int hscroll, int active) {
  int hs = hscroll, a = active;
  int r = GuiTabBar((Rectangle){ x, y, w, h }, text, &hs, &a);
  sp_gui_int_result = a;
  sp_gui_int_result2 = hs;
  return r;
}
int rl_GuiTabBarEx(float x, float y, float w, float h, const char *text,
                   int count, int hscroll, int active, int focus) {
  (void)count;
  int n = 0;
  char **items = sp_gui_split_text(text, &n);
  int hs = hscroll, a = active, f = focus;
  int r = GuiTabBarEx((Rectangle){ x, y, w, h }, items, n, &hs, &a, &f);
  sp_gui_int_result = a;
  sp_gui_int_result2 = hs;
  sp_gui_int_result3 = f;
  return r;
}
int rl_Gui_GetInt2(void) { return sp_gui_int_result2; }
int rl_Gui_GetInt3(void) { return sp_gui_int_result3; }
