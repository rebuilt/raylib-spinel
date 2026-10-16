# raygui_ffi.rb — raygui bindings for Spinel AOT.
#
# raygui is compiled into lib/raygui_adapter.o (see raygui_adapter.c) and linked
# into the scenes that need it; every control is a float/pointer rl_ shim.
# Loaded by `require "raylib-spinel/raygui"`. Under CRuby the raylib-bindings
# gem already binds raygui, so that require is a no-op.

module Raylib
  ffi_lib "raylib"
  ffi_cflags "-I/usr/local/include"

  # Global state
  ffi_func :rl_GuiLock, [], :void
  ffi_func :rl_GuiUnlock, [], :void
  ffi_func :rl_GuiEnable, [], :void
  ffi_func :rl_GuiDisable, [], :void
  ffi_func :rl_GuiSetAlpha, [:float], :void
  ffi_func :rl_GuiSetState, [:int], :void
  ffi_func :rl_GuiSetStyle, %i[int int int], :void
  ffi_func :rl_GuiGetStyle, %i[int int], :int
  ffi_func :rl_GuiSetFont, [:ptr], :void
  ffi_func :rl_GuiLoadStyle, [:str], :void
  ffi_func :rl_GuiLoadStyleDefault, [], :void

  # Controls
  ffi_func :rl_GuiButton, %i[float float float float str], :int
  ffi_func :rl_GuiLabel, %i[float float float float str], :int
  ffi_func :rl_GuiLabelButton, %i[float float float float str], :int
  ffi_func :rl_GuiGroupBox, %i[float float float float str], :int
  ffi_func :rl_GuiLine, %i[float float float float str], :int
  ffi_func :rl_GuiPanel, %i[float float float float str], :int
  ffi_func :rl_GuiStatusBar, %i[float float float float str], :int
  ffi_func :rl_GuiDummyRec, %i[float float float float str], :int
  ffi_func :rl_GuiCheckBox, %i[float float float float str ptr], :int
  ffi_func :rl_GuiComboBox, %i[float float float float str ptr], :int
  ffi_func :rl_GuiDropdownBox, %i[float float float float str ptr int], :int
  ffi_func :rl_GuiSpinner, %i[float float float float str ptr int int int], :int
  ffi_func :rl_GuiValueBox, %i[float float float float str ptr int int int], :int
  ffi_func :rl_GuiSlider, %i[float float float float str str ptr float float], :int
  ffi_func :rl_GuiSliderBar, %i[float float float float str str ptr float float], :int
  ffi_func :rl_GuiProgressBar, %i[float float float float str str ptr float float], :int
  ffi_func :rl_GuiWindowBox, %i[float float float float str], :int
  ffi_func :rl_GuiMessageBox, %i[float float float float str str str ptr], :int
  ffi_func :rl_GuiListView, %i[float float float float str ptr ptr], :int
  ffi_func :rl_GuiColorPicker, %i[float float float float str ptr], :int
  ffi_func :rl_GuiGrid, %i[float float float float str float int ptr], :int

  # Value-returning variants (updated value read back via GetFloat/GetInt).
  ffi_func :rl_GuiCheckBoxValue, %i[float float float float str int], :int
  ffi_func :rl_GuiSliderBarValue, %i[float float float float str str float float float], :int
  ffi_func :rl_GuiSliderValue, %i[float float float float str str float float float], :int
  ffi_func :rl_GuiSpinnerValue, %i[float float float float str int int int int], :int
  ffi_func :rl_GuiDropdownBoxValue, %i[float float float float str int int], :int
  ffi_func :rl_GuiComboBoxValue, %i[float float float float str int], :int
  ffi_func :rl_GuiListViewValue, %i[float float float float str int int], :int
  ffi_func :rl_Gui_GetFloat, [], :float
  ffi_func :rl_GuiToggleGroupValue, %i[float float float float str int], :int
  ffi_func :rl_GuiToggleValue, %i[float float float float str int], :int
  ffi_func :rl_GuiTabBarValue, %i[float float float float str int int], :int
  ffi_func :rl_GuiListViewExValue, %i[float float float float str int int int int int], :int
  ffi_func :rl_GuiColorBarHueValue, %i[float float float float str float], :int
  ffi_func :rl_GuiToggleSliderValue, %i[float float float float str int], :int
  ffi_func :rl_GuiColorBarAlphaValue, %i[float float float float str float], :int
  ffi_func :rl_Gui_GetInt, [], :int
  ffi_func :rl_GuiTextBoxFloat, %i[float float float float str int], :int
  ffi_func :rl_GuiScrollPanel, %i[float float float float str ptr ptr ptr], :int
  ffi_func :rl_GuiToggleGroup, %i[float float float float str ptr], :int
  ffi_func :rl_GuiToggleSlider, %i[float float float float str ptr], :int
  ffi_func :rl_GuiColorBarAlpha, %i[float float float float str ptr], :int
  ffi_func :rl_GuiColorPickerSet, %i[int int int int], :void
  ffi_func :rl_GuiColorPickerValue, %i[float float float float str], :int
  ffi_func :rl_Gui_GetColorR, [], :int
  ffi_func :rl_Gui_GetColorG, [], :int
  ffi_func :rl_Gui_GetColorB, [], :int
  ffi_func :rl_Gui_GetColorA, [], :int
  ffi_func :rl_GuiValueBoxValue, %i[float float float float str int int int int], :int
  ffi_func :rl_GuiIconText, %i[int str], :str
  ffi_func :rl_GuiProgressBarValue, %i[float float float float str str float float float], :int

  # Extended surface (coverage completion): global state, tooltips, metrics,
  # icons, text buffers/lists and the HSV colour controls.
  ffi_func :rl_GuiIsLocked, [], :int
  ffi_func :rl_GuiGetState, [], :int
  ffi_func :rl_GuiEnableTooltip, [], :void
  ffi_func :rl_GuiDisableTooltip, [], :void
  ffi_func :rl_GuiSetTooltip, [:str], :void
  ffi_func :rl_GuiSetIconScale, [:int], :void
  ffi_func :rl_GuiGetTextWidth, [:str], :int
  ffi_func :rl_GuiGetFont, [], :ptr
  ffi_func :rl_GuiGetIcons, [], :ptr
  ffi_func :rl_GuiLoadIcons, %i[str int], :ptr
  ffi_func :rl_GuiLoadIconsFromMemory, %i[ptr int int], :ptr
  ffi_func :rl_GuiLoadStyleFromMemory, %i[ptr int], :void
  ffi_func :rl_GuiDrawIcon, %i[int int int int ptr], :void
  ffi_func :rl_GuiToggle, %i[float float float float str ptr], :int
  ffi_func :rl_GuiValueBoxFloat, %i[float float float float str ptr ptr int], :int
  ffi_func :rl_GuiColorBarHue, %i[float float float float str ptr], :int
  ffi_func :rl_GuiColorPanel, %i[float float float float str ptr], :int
  ffi_func :rl_GuiColorPanelHSV, %i[float float float float str ptr], :int
  ffi_func :rl_GuiColorPickerHSV, %i[float float float float str ptr], :int
  ffi_func :rl_GuiTextBox, %i[float float float float ptr int int], :int
  ffi_func :rl_GuiTextInputBox, %i[float float float float str str ptr int str ptr ptr], :int
  ffi_func :rl_GuiListViewEx, %i[float float float float str int int ptr ptr ptr], :int
  ffi_func :rl_GuiTabBar, %i[float float float float str ptr ptr], :int
  ffi_func :rl_GuiTabBarEx, %i[float float float float ptr int ptr ptr ptr], :int
  ffi_func :rl_Gui_GetText, [], :str
  ffi_func :rl_Gui_GetInt2, [], :int
  ffi_func :rl_Gui_GetInt3, [], :int
  ffi_func :rl_Gui_SetHsv, %i[float float float], :void
  ffi_func :rl_Gui_GetHsvH, [], :float
  ffi_func :rl_Gui_GetHsvS, [], :float
  ffi_func :rl_Gui_GetHsvV, [], :float

  # PascalCase surface (matches the gem's Gui* names).
  def self.GuiLock = Raylib.rl_GuiLock
  def self.GuiUnlock = Raylib.rl_GuiUnlock
  def self.GuiEnable = Raylib.rl_GuiEnable
  def self.GuiDisable = Raylib.rl_GuiDisable
  def self.GuiSetAlpha(alpha) = Raylib.rl_GuiSetAlpha(alpha)
  def self.GuiSetState(state) = Raylib.rl_GuiSetState(state)
  def self.GuiSetStyle(control, property, value) = Raylib.rl_GuiSetStyle(control, property, value)
  def self.GuiGetStyle(control, property) = Raylib.rl_GuiGetStyle(control, property)
  def self.GuiSetFont(font) = Raylib.rl_GuiSetFont(font)
  def self.GuiLoadStyle(file) = Raylib.rl_GuiLoadStyle(file)
  def self.GuiLoadStyleDefault = Raylib.rl_GuiLoadStyleDefault

  # raygui 4.x shapes, as the gem binds them: `Rectangle bounds` first, then
  # the control's own parameters. State the control writes back (checked/
  # active/value/scroll/view) is a pointer carrier: an FFI::MemoryPointer in
  # gem code, an Integer address, a struct view (coerced), or nil. The value
  # shims (GuiCheckBoxValue, GuiSliderBarValue, ...) below are unchanged.
  def self.GuiButton(a1, a2) = Raylib.rl_GuiButton(a1.x, a1.y, a1.width, a1.height, Raylib.ptr_addr(a2))
  def self.GuiLabel(a1, a2) = Raylib.rl_GuiLabel(a1.x, a1.y, a1.width, a1.height, Raylib.ptr_addr(a2))
  def self.GuiLabelButton(a1, a2) = Raylib.rl_GuiLabelButton(a1.x, a1.y, a1.width, a1.height, Raylib.ptr_addr(a2))
  def self.GuiGroupBox(a1, a2) = Raylib.rl_GuiGroupBox(a1.x, a1.y, a1.width, a1.height, Raylib.ptr_addr(a2))
  def self.GuiLine(a1, a2) = Raylib.rl_GuiLine(a1.x, a1.y, a1.width, a1.height, Raylib.ptr_addr(a2))
  def self.GuiPanel(a1, a2) = Raylib.rl_GuiPanel(a1.x, a1.y, a1.width, a1.height, Raylib.ptr_addr(a2))
  def self.GuiStatusBar(a1, a2) = Raylib.rl_GuiStatusBar(a1.x, a1.y, a1.width, a1.height, Raylib.ptr_addr(a2))
  def self.GuiCheckBox(a1, a2, a3) = Raylib.rl_GuiCheckBox(a1.x, a1.y, a1.width, a1.height, Raylib.ptr_addr(a2), Raylib.ptr_addr(a3))
  def self.GuiComboBox(a1, a2, a3) = Raylib.rl_GuiComboBox(a1.x, a1.y, a1.width, a1.height, Raylib.ptr_addr(a2), Raylib.ptr_addr(a3))
  def self.GuiDropdownBox(a1, a2, a3, a4) = Raylib.rl_GuiDropdownBox(a1.x, a1.y, a1.width, a1.height, Raylib.ptr_addr(a2), Raylib.ptr_addr(a3), a4 ? 1 : 0)
  def self.GuiSpinner(a1, a2, a3, a4, a5, a6) = Raylib.rl_GuiSpinner(a1.x, a1.y, a1.width, a1.height, Raylib.ptr_addr(a2), Raylib.ptr_addr(a3), a4, a5, a6 ? 1 : 0)
  def self.GuiValueBox(a1, a2, a3, a4, a5, a6) = Raylib.rl_GuiValueBox(a1.x, a1.y, a1.width, a1.height, Raylib.ptr_addr(a2), Raylib.ptr_addr(a3), a4, a5, a6 ? 1 : 0)
  def self.GuiSlider(a1, a2, a3, a4, a5, a6) = Raylib.rl_GuiSlider(a1.x, a1.y, a1.width, a1.height, Raylib.ptr_addr(a2), Raylib.ptr_addr(a3), Raylib.ptr_addr(a4), a5, a6)
  def self.GuiSliderBar(a1, a2, a3, a4, a5, a6) = Raylib.rl_GuiSliderBar(a1.x, a1.y, a1.width, a1.height, Raylib.ptr_addr(a2), Raylib.ptr_addr(a3), Raylib.ptr_addr(a4), a5, a6)
  def self.GuiProgressBar(a1, a2, a3, a4, a5, a6) = Raylib.rl_GuiProgressBar(a1.x, a1.y, a1.width, a1.height, Raylib.ptr_addr(a2), Raylib.ptr_addr(a3), Raylib.ptr_addr(a4), a5, a6)
  def self.GuiWindowBox(a1, a2) = Raylib.rl_GuiWindowBox(a1.x, a1.y, a1.width, a1.height, Raylib.ptr_addr(a2))
  def self.GuiMessageBox(a1, a2, a3, a4, a5) = Raylib.rl_GuiMessageBox(a1.x, a1.y, a1.width, a1.height, Raylib.ptr_addr(a2), Raylib.ptr_addr(a3), Raylib.ptr_addr(a4), Raylib.ptr_addr(a5))
  def self.GuiListView(a1, a2, a3, a4) = Raylib.rl_GuiListView(a1.x, a1.y, a1.width, a1.height, Raylib.ptr_addr(a2), Raylib.ptr_addr(a3), Raylib.ptr_addr(a4))
  def self.GuiColorPicker(a1, a2, a3) = Raylib.rl_GuiColorPicker(a1.x, a1.y, a1.width, a1.height, Raylib.ptr_addr(a2), Raylib.color_addr(a3))
  def self.GuiGrid(a1, a2, a3, a4, a5) = Raylib.rl_GuiGrid(a1.x, a1.y, a1.width, a1.height, Raylib.ptr_addr(a2), a3, a4, Raylib.vector2_addr(a5))

  # raygui 4.x shapes for the widgets converted later (pointer state written
  # back); the *Value helpers below keep the scalar scene-facing form.
  def self.GuiToggle(bounds, text, active) = Raylib.rl_GuiToggle(bounds.x, bounds.y, bounds.width, bounds.height, text, Raylib.ptr_addr(active))
  def self.GuiToggleGroup(bounds, text, active) = Raylib.rl_GuiToggleGroup(bounds.x, bounds.y, bounds.width, bounds.height, text, Raylib.ptr_addr(active))
  def self.GuiToggleSlider(bounds, text, active) = Raylib.rl_GuiToggleSlider(bounds.x, bounds.y, bounds.width, bounds.height, text, Raylib.ptr_addr(active))
  def self.GuiTabBar(bounds, text, hscroll, active) = Raylib.rl_GuiTabBar(bounds.x, bounds.y, bounds.width, bounds.height, text, Raylib.ptr_addr(hscroll), Raylib.ptr_addr(active))
  def self.GuiTabBarEx(bounds, text, count, hscroll, active, focus) = Raylib.rl_GuiTabBarEx(bounds.x, bounds.y, bounds.width, bounds.height, Raylib.ptr_addr(text), count, Raylib.ptr_addr(hscroll), Raylib.ptr_addr(active), Raylib.ptr_addr(focus))
  def self.GuiValueBoxFloat(bounds, text, text_value, value, edit) = Raylib.rl_GuiValueBoxFloat(bounds.x, bounds.y, bounds.width, bounds.height, text, Raylib.ptr_addr(text_value), Raylib.ptr_addr(value), edit ? 1 : 0)
  def self.GuiColorBarAlpha(bounds, text, alpha) = Raylib.rl_GuiColorBarAlpha(bounds.x, bounds.y, bounds.width, bounds.height, text, Raylib.ptr_addr(alpha))
  def self.GuiColorBarHue(bounds, text, value) = Raylib.rl_GuiColorBarHue(bounds.x, bounds.y, bounds.width, bounds.height, text, Raylib.ptr_addr(value))
  def self.GuiColorPickerHSV(bounds, text, color_hsv) = Raylib.rl_GuiColorPickerHSV(bounds.x, bounds.y, bounds.width, bounds.height, text, Raylib.vector3_addr(color_hsv))
  def self.GuiColorPanelHSV(bounds, text, color_hsv) = Raylib.rl_GuiColorPanelHSV(bounds.x, bounds.y, bounds.width, bounds.height, text, Raylib.vector3_addr(color_hsv))
  def self.GuiColorPanel(bounds, text, color) = Raylib.rl_GuiColorPanel(bounds.x, bounds.y, bounds.width, bounds.height, text, Raylib.color_addr(color))
  def self.GuiListViewEx(bounds, text, count, scroll, active, focus) = Raylib.rl_GuiListViewEx(bounds.x, bounds.y, bounds.width, bounds.height, text, count, text.bytesize, Raylib.ptr_addr(scroll), Raylib.ptr_addr(active), Raylib.ptr_addr(focus))
  def self.GuiDummyRec(bounds, text) = Raylib.rl_GuiDummyRec(bounds.x, bounds.y, bounds.width, bounds.height, text)

  # Value-returning helpers: run the control, then read the updated value.
  def self.GuiCheckBoxValue(x, y, w, h, text, checked)
    r = Raylib.rl_GuiCheckBoxValue(x, y, w, h, text, checked ? 1 : 0)
    [r, Raylib.rl_Gui_GetInt]
  end
  def self.GuiSliderBarValue(x, y, w, h, l, r, value, lo, hi)
    res = Raylib.rl_GuiSliderBarValue(x, y, w, h, l, r, value, lo, hi)
    [res, Raylib.rl_Gui_GetFloat]
  end
  def self.GuiSliderValue(x, y, w, h, l, r, value, lo, hi)
    res = Raylib.rl_GuiSliderValue(x, y, w, h, l, r, value, lo, hi)
    [res, Raylib.rl_Gui_GetFloat]
  end
  def self.GuiSpinnerValue(x, y, w, h, text, value, lo, hi, edit)
    # `edit` is a Ruby boolean; the :int FFI slot wants 0/1 (as GuiCheckBoxValue
    # does for `checked`). Handing a bare bool to an int slot is CRuby's
    # TypeError "no implicit conversion of false into Integer".
    res = Raylib.rl_GuiSpinnerValue(x, y, w, h, text, value, lo, hi,
                                    edit ? 1 : 0)
    [res, Raylib.rl_Gui_GetInt]
  end
  def self.GuiDropdownBoxValue(x, y, w, h, text, active, edit)
    res = Raylib.rl_GuiDropdownBoxValue(x, y, w, h, text, active,
                                        edit ? 1 : 0)
    [res, Raylib.rl_Gui_GetInt]
  end
  def self.GuiComboBoxValue(x, y, w, h, text, active)
    res = Raylib.rl_GuiComboBoxValue(x, y, w, h, text, active)
    [res, Raylib.rl_Gui_GetInt]
  end
  def self.GuiListViewValue(x, y, w, h, text, scroll, active)
    res = Raylib.rl_GuiListViewValue(x, y, w, h, text, scroll, active)
    [res, Raylib.rl_Gui_GetInt]
  end

  def self.GuiTextBoxFloat(x, y, w, h, text, edit) = Raylib.rl_GuiTextBoxFloat(x, y, w, h, text, edit ? 1 : 0)
  def self.GuiScrollPanel(bounds, text, content, scroll, view) = Raylib.rl_GuiScrollPanel(bounds.x, bounds.y, bounds.width, bounds.height, text, Raylib.rectangle_addr(content), Raylib.vector2_addr(scroll), Raylib.rectangle_addr(view))
  def self.GuiIconText(icon, text) = Raylib.rl_GuiIconText(icon, text)

  def self.GuiValueBoxValue(x, y, w, h, text, value, lo, hi, edit)
    res = Raylib.rl_GuiValueBoxValue(x, y, w, h, text, value, lo, hi,
                                     edit ? 1 : 0)
    [res, Raylib.rl_Gui_GetInt]
  end
  def self.GuiToggleGroupValue(x, y, w, h, text, active)
    res = Raylib.rl_GuiToggleGroupValue(x, y, w, h, text, active)
    [res, Raylib.rl_Gui_GetInt]
  end
  def self.GuiToggleSliderValue(x, y, w, h, text, active)
    res = Raylib.rl_GuiToggleSliderValue(x, y, w, h, text, active)
    [res, Raylib.rl_Gui_GetInt]
  end
  def self.GuiColorBarAlphaValue(x, y, w, h, text, alpha)
    res = Raylib.rl_GuiColorBarAlphaValue(x, y, w, h, text, alpha)
    [res, Raylib.rl_Gui_GetFloat]
  end
  def self.GuiColorPickerSet(r, g, b, a) = Raylib.rl_GuiColorPickerSet(r, g, b, a)
  def self.GuiColorPickerValue(x, y, w, h, text) = Raylib.rl_GuiColorPickerValue(x, y, w, h, text)
  def self.GuiProgressBarValue(x, y, w, h, l, r, value, lo, hi)
    res = Raylib.rl_GuiProgressBarValue(x, y, w, h, l, r, value, lo, hi)
    [res, Raylib.rl_Gui_GetFloat]
  end

  # Extended surface (coverage completion).
  def self.GuiIsLocked = Raylib.rl_GuiIsLocked != 0
  def self.GuiGetState = Raylib.rl_GuiGetState
  def self.GuiEnableTooltip = Raylib.rl_GuiEnableTooltip
  def self.GuiDisableTooltip = Raylib.rl_GuiDisableTooltip
  def self.GuiSetTooltip(text) = Raylib.rl_GuiSetTooltip(text)
  def self.GuiSetIconScale(scale) = Raylib.rl_GuiSetIconScale(scale)
  def self.GuiGetTextWidth(text) = Raylib.rl_GuiGetTextWidth(text)
  def self.GuiGetFont = Raylib.rl_GuiGetFont
  def self.GuiGetIcons = Raylib.rl_GuiGetIcons
  def self.GuiLoadIcons(file_name, load_names)
    Raylib.rl_GuiLoadIcons(file_name, load_names ? 1 : 0)
  end
  def self.GuiLoadIconsFromMemory(data, data_size, load_names)
    Raylib.rl_GuiLoadIconsFromMemory(data, data_size, load_names ? 1 : 0)
  end
  def self.GuiLoadStyleFromMemory(data, data_size)
    Raylib.rl_GuiLoadStyleFromMemory(data, data_size)
  end
  def self.GuiDrawIcon(icon_id, x, y, pixel_size, color)
    Raylib.rl_GuiDrawIcon(icon_id, x, y, pixel_size, color)
  end
  def self.GuiTextBox(bounds, text, text_size, edit) = Raylib.rl_GuiTextBox(bounds.x, bounds.y, bounds.width, bounds.height, Raylib.ptr_addr(text), text_size, edit ? 1 : 0)
  def self.GuiTextInputBox(bounds, title, message, text, text_size, btns, active, secret)
    # coerce at the boundary: the delegate's parameters are untyped, and a raw
    # forward lets the inference mistype the slots (B4)
    Raylib.rl_GuiTextInputBox(bounds.x, bounds.y, bounds.width, bounds.height,
                              title.to_s, message.to_s, Raylib.ptr_addr(text),
                              text_size.to_i, btns.to_s,
                              Raylib.ptr_addr(active), Raylib.ptr_addr(secret))
  end
  def self.GuiGetText = Raylib.rl_Gui_GetText

  # Value-returning variants (control result + updated value(s)).
  def self.GuiSetColorHSV(h, s, v) = Raylib.rl_Gui_SetHsv(h, s, v)

  # Legacy RGui* aliases (the examples use these names).
  # RGuiCheckBox takes the same `int *` as GuiCheckBox (see the note above).

  # raygui control + style property constants (raygui 5.0)
  DEFAULT = 0
  LABEL = 1
  BUTTON = 2
  TOGGLE = 3
  SLIDER = 4
  PROGRESSBAR = 5
  CHECKBOX = 6
  COMBOBOX = 7
  DROPDOWNBOX = 8
  TEXTBOX = 9
  VALUEBOX = 10
  TABBAR = 11
  LISTVIEW = 12
  COLORPICKER = 13
  SCROLLBAR = 14
  STATUSBAR = 15

  BORDER_COLOR_NORMAL = 0
  BASE_COLOR_NORMAL = 1
  TEXT_COLOR_NORMAL = 2
  BORDER_COLOR_FOCUSED = 3
  BASE_COLOR_FOCUSED = 4
  TEXT_COLOR_FOCUSED = 5
  BORDER_COLOR_PRESSED = 6
  BASE_COLOR_PRESSED = 7
  TEXT_COLOR_PRESSED = 8
  BORDER_WIDTH = 12
  TEXT_PADDING = 13
  TEXT_ALIGNMENT = 14

  TEXT_SIZE = 16
  TEXT_SPACING = 17
  LINE_COLOR = 18
  BACKGROUND_COLOR = 19
  TEXT_LINE_SPACING = 20
  TEXT_ALIGNMENT_VERTICAL = 21
  TEXT_WRAP_MODE = 22
  RAYGUI_VERSION_MAJOR = 5
  RAYGUI_VERSION_MINOR = 0
  RAYGUI_VERSION_PATCH = 0
  RAYGUI_VERSION = "5.0"
  SCROLLBAR_LEFT_SIDE = 0
  SCROLLBAR_RIGHT_SIDE = 1
  RESULT_NONE = 0
  RESULT_PRESSED = 1
  RESULT_CHANGED = 2
  RESULT_TAB_CLOSE = 4
  STATE_NORMAL = 0
  STATE_FOCUSED = 1
  STATE_PRESSED = 2
  STATE_DISABLED = 3
  TEXT_ALIGN_LEFT = 0
  TEXT_ALIGN_CENTER = 1
  TEXT_ALIGN_RIGHT = 2
  TEXT_ALIGN_TOP = 0
  TEXT_ALIGN_MIDDLE = 1
  TEXT_ALIGN_BOTTOM = 2
  TEXT_WRAP_NONE = 0
  TEXT_WRAP_CHAR = 1
  TEXT_WRAP_WORD = 2
  BORDER_COLOR_DISABLED = 9
  BASE_COLOR_DISABLED = 10
  TEXT_COLOR_DISABLED = 11
  BASEPROP16 = 15
  EXTPROP08 = 23
  GROUP_PADDING = 16
  GROUP_WIDTH_FULL = 17
  SLIDER_WIDTH = 16
  SLIDER_PADDING = 17
  PROGRESS_PADDING = 16
  PROGRESS_SIDE = 17
  ARROWS_SIZE = 16
  ARROWS_VISIBLE = 17
  SCROLL_SLIDER_PADDING = 18
  SCROLL_SLIDER_SIZE = 19
  SCROLL_PADDING = 20
  SCROLL_SPEED = 21
  CHECK_PADDING = 16
  COMBO_BUTTON_WIDTH = 16
  COMBO_BUTTON_SPACING = 17
  ARROW_PADDING = 16
  DROPDOWN_ITEMS_SPACING = 17
  DROPDOWN_ARROW_HIDDEN = 18
  DROPDOWN_ROLL_UP = 19
  TEXT_READONLY = 16
  SPINNER_BUTTON_WIDTH = 16
  SPINNER_BUTTON_SPACING = 17
  TAB_ITEMS_WIDTH = 16
  TAB_CLOSE_BUTTON = 17
  TAB_LINE_SIDE = 18
  LIST_ITEMS_HEIGHT = 16
  LIST_ITEMS_SPACING = 17
  SCROLLBAR_WIDTH = 18
  SCROLLBAR_SIDE = 19
  LIST_ITEMS_BORDER_NORMAL = 20
  LIST_ITEMS_BORDER_WIDTH = 21
  COLOR_SELECTOR_SIZE = 16
  HUEBAR_WIDTH = 17
  HUEBAR_PADDING = 18
  HUEBAR_SELECTOR_HEIGHT = 19
  HUEBAR_SELECTOR_OVERFLOW = 20
  ICON_NONE = 0
  ICON_FOLDER_FILE_OPEN = 1
  ICON_FILE_SAVE_CLASSIC = 2
  ICON_FOLDER_OPEN = 3
  ICON_FOLDER_SAVE = 4
  ICON_FILE_OPEN = 5
  ICON_FILE_SAVE = 6
  ICON_FILE_EXPORT = 7
  ICON_FILE_ADD = 8
  ICON_FILE_DELETE = 9
  ICON_FILETYPE_TEXT = 10
  ICON_FILETYPE_AUDIO = 11
  ICON_FILETYPE_IMAGE = 12
  ICON_FILETYPE_PLAY = 13
  ICON_FILETYPE_VIDEO = 14
  ICON_FILETYPE_INFO = 15
  ICON_FILE_COPY = 16
  ICON_FILE_CUT = 17
  ICON_FILE_PASTE = 18
  ICON_CURSOR_HAND = 19
  ICON_CURSOR_POINTER = 20
  ICON_CURSOR_CLASSIC = 21
  ICON_PENCIL = 22
  ICON_PENCIL_BIG = 23
  ICON_BRUSH_CLASSIC = 24
  ICON_BRUSH_PAINTER = 25
  ICON_WATER_DROP = 26
  ICON_COLOR_PICKER = 27
  ICON_RUBBER = 28
  ICON_COLOR_BUCKET = 29
  ICON_TEXT_T = 30
  ICON_TEXT_A = 31
  ICON_SCALE = 32
  ICON_RESIZE = 33
  ICON_FILTER_POINT = 34
  ICON_FILTER_BILINEAR = 35
  ICON_CROP = 36
  ICON_CROP_ALPHA = 37
  ICON_SQUARE_TOGGLE = 38
  ICON_SYMMETRY = 39
  ICON_SYMMETRY_HORIZONTAL = 40
  ICON_SYMMETRY_VERTICAL = 41
  ICON_LENS = 42
  ICON_LENS_BIG = 43
  ICON_EYE_ON = 44
  ICON_EYE_OFF = 45
  ICON_FILTER_TOP = 46
  ICON_FILTER = 47
  ICON_TARGET_POINT = 48
  ICON_TARGET_SMALL = 49
  ICON_TARGET_BIG = 50
  ICON_TARGET_MOVE = 51
  ICON_CURSOR_MOVE = 52
  ICON_CURSOR_SCALE = 53
  ICON_CURSOR_SCALE_RIGHT = 54
  ICON_CURSOR_SCALE_LEFT = 55
  ICON_UNDO = 56
  ICON_REDO = 57
  ICON_REREDO = 58
  ICON_MUTATE = 59
  ICON_ROTATE = 60
  ICON_REPEAT = 61
  ICON_SHUFFLE = 62
  ICON_EMPTYBOX = 63
  ICON_TARGET = 64
  ICON_TARGET_SMALL_FILL = 65
  ICON_TARGET_BIG_FILL = 66
  ICON_TARGET_MOVE_FILL = 67
  ICON_CURSOR_MOVE_FILL = 68
  ICON_CURSOR_SCALE_FILL = 69
  ICON_CURSOR_SCALE_RIGHT_FILL = 70
  ICON_CURSOR_SCALE_LEFT_FILL = 71
  ICON_UNDO_FILL = 72
  ICON_REDO_FILL = 73
  ICON_REREDO_FILL = 74
  ICON_MUTATE_FILL = 75
  ICON_ROTATE_FILL = 76
  ICON_REPEAT_FILL = 77
  ICON_SHUFFLE_FILL = 78
  ICON_EMPTYBOX_SMALL = 79
  ICON_BOX = 80
  ICON_BOX_TOP = 81
  ICON_BOX_TOP_RIGHT = 82
  ICON_BOX_RIGHT = 83
  ICON_BOX_BOTTOM_RIGHT = 84
  ICON_BOX_BOTTOM = 85
  ICON_BOX_BOTTOM_LEFT = 86
  ICON_BOX_LEFT = 87
  ICON_BOX_TOP_LEFT = 88
  ICON_BOX_CENTER = 89
  ICON_BOX_CIRCLE_MASK = 90
  ICON_POT = 91
  ICON_ALPHA_MULTIPLY = 92
  ICON_ALPHA_CLEAR = 93
  ICON_DITHERING = 94
  ICON_MIPMAPS = 95
  ICON_BOX_GRID = 96
  ICON_GRID = 97
  ICON_BOX_CORNERS_SMALL = 98
  ICON_BOX_CORNERS_BIG = 99
  ICON_FOUR_BOXES = 100
  ICON_GRID_FILL = 101
  ICON_BOX_MULTISIZE = 102
  ICON_ZOOM_SMALL = 103
  ICON_ZOOM_MEDIUM = 104
  ICON_ZOOM_BIG = 105
  ICON_ZOOM_ALL = 106
  ICON_ZOOM_CENTER = 107
  ICON_BOX_DOTS_SMALL = 108
  ICON_BOX_DOTS_BIG = 109
  ICON_BOX_CONCENTRIC = 110
  ICON_BOX_GRID_BIG = 111
  ICON_OK_TICK = 112
  ICON_CROSS = 113
  ICON_ARROW_LEFT = 114
  ICON_ARROW_RIGHT = 115
  ICON_ARROW_DOWN = 116
  ICON_ARROW_UP = 117
  ICON_ARROW_LEFT_FILL = 118
  ICON_ARROW_RIGHT_FILL = 119
  ICON_ARROW_DOWN_FILL = 120
  ICON_ARROW_UP_FILL = 121
  ICON_AUDIO = 122
  ICON_FX = 123
  ICON_WAVE = 124
  ICON_WAVE_SINUS = 125
  ICON_WAVE_SQUARE = 126
  ICON_WAVE_TRIANGULAR = 127
  ICON_CROSS_SMALL = 128
  ICON_PLAYER_PREVIOUS = 129
  ICON_PLAYER_PLAY_BACK = 130
  ICON_PLAYER_PLAY = 131
  ICON_PLAYER_PAUSE = 132
  ICON_PLAYER_STOP = 133
  ICON_PLAYER_NEXT = 134
  ICON_PLAYER_RECORD = 135
  ICON_MAGNET = 136
  ICON_LOCK_CLOSE = 137
  ICON_LOCK_OPEN = 138
  ICON_CLOCK = 139
  ICON_TOOLS = 140
  ICON_GEAR = 141
  ICON_GEAR_BIG = 142
  ICON_BIN = 143
  ICON_HAND_POINTER = 144
  ICON_LASER = 145
  ICON_COIN = 146
  ICON_EXPLOSION = 147
  ICON_1UP = 148
  ICON_PLAYER = 149
  ICON_PLAYER_JUMP = 150
  ICON_KEY = 151
  ICON_DEMON = 152
  ICON_TEXT_POPUP = 153
  ICON_GEAR_EX = 154
  ICON_CRACK = 155
  ICON_CRACK_POINTS = 156
  ICON_STAR = 157
  ICON_DOOR = 158
  ICON_EXIT = 159
  ICON_MODE_2D = 160
  ICON_MODE_3D = 161
  ICON_CUBE = 162
  ICON_CUBE_FACE_TOP = 163
  ICON_CUBE_FACE_LEFT = 164
  ICON_CUBE_FACE_FRONT = 165
  ICON_CUBE_FACE_BOTTOM = 166
  ICON_CUBE_FACE_RIGHT = 167
  ICON_CUBE_FACE_BACK = 168
  ICON_CAMERA = 169
  ICON_SPECIAL = 170
  ICON_LINK_NET = 171
  ICON_LINK_BOXES = 172
  ICON_LINK_MULTI = 173
  ICON_LINK = 174
  ICON_LINK_BROKE = 175
  ICON_TEXT_NOTES = 176
  ICON_NOTEBOOK = 177
  ICON_SUITCASE = 178
  ICON_SUITCASE_ZIP = 179
  ICON_MAILBOX = 180
  ICON_MONITOR = 181
  ICON_PRINTER = 182
  ICON_PHOTO_CAMERA = 183
  ICON_PHOTO_CAMERA_FLASH = 184
  ICON_HOUSE = 185
  ICON_HEART = 186
  ICON_CORNER = 187
  ICON_VERTICAL_BARS = 188
  ICON_VERTICAL_BARS_FILL = 189
  ICON_LIFE_BARS = 190
  ICON_INFO = 191
  ICON_CROSSLINE = 192
  ICON_HELP = 193
  ICON_FILETYPE_ALPHA = 194
  ICON_FILETYPE_HOME = 195
  ICON_LAYERS_VISIBLE = 196
  ICON_LAYERS = 197
  ICON_WINDOW = 198
  ICON_HIDPI = 199
  ICON_FILETYPE_BINARY = 200
  ICON_HEX = 201
  ICON_SHIELD = 202
  ICON_FILE_NEW = 203
  ICON_FOLDER_ADD = 204
  ICON_ALARM = 205
  ICON_CPU = 206
  ICON_ROM = 207
  ICON_STEP_OVER = 208
  ICON_STEP_INTO = 209
  ICON_STEP_OUT = 210
  ICON_RESTART = 211
  ICON_BREAKPOINT_ON = 212
  ICON_BREAKPOINT_OFF = 213
  ICON_BURGER_MENU = 214
  ICON_CASE_SENSITIVE = 215
  ICON_REG_EXP = 216
  ICON_FOLDER = 217
  ICON_FILE = 218
  ICON_SAND_TIMER = 219
  ICON_WARNING = 220
  ICON_HELP_BOX = 221
  ICON_INFO_BOX = 222
  ICON_PRIORITY = 223
  ICON_LAYERS_ISO = 224
  ICON_LAYERS2 = 225
  ICON_MLAYERS = 226
  ICON_MAPS = 227
  ICON_HOT = 228
  ICON_LABEL = 229
  ICON_NAME_ID = 230
  ICON_SLICING = 231
  ICON_MANUAL_CONTROL = 232
  ICON_COLLISION = 233
  ICON_CIRCLE_ADD = 234
  ICON_CIRCLE_ADD_FILL = 235
  ICON_CIRCLE_WARNING = 236
  ICON_CIRCLE_WARNING_FILL = 237
  ICON_BOX_MORE = 238
  ICON_BOX_MORE_FILL = 239
  ICON_BOX_MINUS = 240
  ICON_BOX_MINUS_FILL = 241
  ICON_UNION = 242
  ICON_INTERSECTION = 243
  ICON_DIFFERENCE = 244
  ICON_SPHERE = 245
  ICON_CYLINDER = 246
  ICON_CONE = 247
  ICON_ELLIPSOID = 248
  ICON_CAPSULE = 249
  ICON_FILETYPE_FONT = 250
  ICON_FILETYPE_3D = 251
  ICON_FILETYPE_CODE_XML = 252
  ICON_FILETYPE_CODE_C = 253
  ICON_FILETYPE_CODE_PYTHON = 254
  ICON_FILETYPE_CODE_JS = 255
  ICON_FILETYPE_ICON = 256

  # ====== generated: snake_case aliases (MRI gem naming, tools/gen_raygui_aliases.py) ======
  class << self
    alias_method :gui_enable, :GuiEnable
    alias_method :gui_disable, :GuiDisable
    alias_method :gui_lock, :GuiLock
    alias_method :gui_unlock, :GuiUnlock
    alias_method :gui_set_alpha, :GuiSetAlpha
    alias_method :gui_set_state, :GuiSetState
    alias_method :gui_set_font, :GuiSetFont
    alias_method :gui_set_style, :GuiSetStyle
    alias_method :gui_get_style, :GuiGetStyle
    alias_method :gui_load_style, :GuiLoadStyle
    alias_method :gui_load_style_default, :GuiLoadStyleDefault
    alias_method :gui_icon_text, :GuiIconText
    alias_method :gui_window_box, :GuiWindowBox
    alias_method :gui_group_box, :GuiGroupBox
    alias_method :gui_line, :GuiLine
    alias_method :gui_panel, :GuiPanel
    alias_method :gui_scroll_panel, :GuiScrollPanel
    alias_method :gui_label, :GuiLabel
    alias_method :gui_button, :GuiButton
    alias_method :gui_label_button, :GuiLabelButton
    alias_method :gui_check_box, :GuiCheckBox
    alias_method :gui_combo_box, :GuiComboBox
    alias_method :gui_dropdown_box, :GuiDropdownBox
    alias_method :gui_spinner, :GuiSpinner
    alias_method :gui_value_box, :GuiValueBox
    alias_method :gui_slider, :GuiSlider
    alias_method :gui_slider_bar, :GuiSliderBar
    alias_method :gui_progress_bar, :GuiProgressBar
    alias_method :gui_status_bar, :GuiStatusBar
    alias_method :gui_grid, :GuiGrid
    alias_method :gui_list_view, :GuiListView
    alias_method :gui_message_box, :GuiMessageBox
    alias_method :gui_color_picker, :GuiColorPicker
  end

  # ====== generated: snake_case aliases (MRI gem naming, tools/gen_raygui_aliases.py) ======
  class << self
    alias_method :gui_is_locked, :GuiIsLocked
    alias_method :gui_get_state, :GuiGetState
    alias_method :gui_get_font, :GuiGetFont
    alias_method :gui_load_style_from_memory, :GuiLoadStyleFromMemory
    alias_method :gui_enable_tooltip, :GuiEnableTooltip
    alias_method :gui_disable_tooltip, :GuiDisableTooltip
    alias_method :gui_set_tooltip, :GuiSetTooltip
    alias_method :gui_set_icon_scale, :GuiSetIconScale
    alias_method :gui_get_icons, :GuiGetIcons
    alias_method :gui_load_icons, :GuiLoadIcons
    alias_method :gui_load_icons_from_memory, :GuiLoadIconsFromMemory
    alias_method :gui_draw_icon, :GuiDrawIcon
    alias_method :gui_get_text_width, :GuiGetTextWidth
    alias_method :gui_toggle, :GuiToggle
    alias_method :gui_value_box_float, :GuiValueBoxFloat
    alias_method :gui_text_box, :GuiTextBox
    alias_method :gui_list_view_ex, :GuiListViewEx
    alias_method :gui_tab_bar, :GuiTabBar
    alias_method :gui_tab_bar_ex, :GuiTabBarEx
    alias_method :gui_text_input_box, :GuiTextInputBox
    alias_method :gui_color_panel, :GuiColorPanel
    alias_method :gui_color_bar_hue, :GuiColorBarHue
    alias_method :gui_color_picker_hsv, :GuiColorPickerHSV
    alias_method :gui_color_panel_hsv, :GuiColorPanelHSV
  end

  # ====== generated: snake_case aliases (MRI gem naming, tools/gen_raygui_aliases.py) ======
  class << self
    alias_method :gui_toggle_group, :GuiToggleGroup
    alias_method :gui_toggle_slider, :GuiToggleSlider
    alias_method :gui_dummy_rec, :GuiDummyRec
    alias_method :gui_color_bar_alpha, :GuiColorBarAlpha
  end
end
