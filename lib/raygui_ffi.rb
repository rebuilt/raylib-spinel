# raygui_ffi.rb — raygui bindings for Spinel AOT.
#
# raygui is compiled into lib/raygui_adapter.o (see raygui_adapter.c) and linked
# into the scenes that need it; every control is a float/pointer sp_ shim.
# Loaded by `require "raylib-spinel/raygui"`. Under CRuby the raylib-bindings
# gem already binds raygui, so that require is a no-op.

module Raylib
  ffi_lib "raylib"
  ffi_cflags "-I/usr/local/include"

  # Global state
  ffi_func :sp_GuiLock, [], :void
  ffi_func :sp_GuiUnlock, [], :void
  ffi_func :sp_GuiEnable, [], :void
  ffi_func :sp_GuiDisable, [], :void
  ffi_func :sp_GuiSetAlpha, [:float], :void
  ffi_func :sp_GuiSetState, [:int], :void
  ffi_func :sp_GuiSetStyle, %i[int int int], :void
  ffi_func :sp_GuiGetStyle, %i[int int], :int
  ffi_func :sp_GuiSetFont, [:ptr], :void
  ffi_func :sp_GuiLoadStyle, [:str], :void
  ffi_func :sp_GuiLoadStyleDefault, [], :void

  # Controls
  ffi_func :sp_GuiButton, %i[float float float float str], :int
  ffi_func :sp_GuiLabel, %i[float float float float str], :int
  ffi_func :sp_GuiLabelButton, %i[float float float float str], :int
  ffi_func :sp_GuiGroupBox, %i[float float float float str], :int
  ffi_func :sp_GuiLine, %i[float float float float str], :int
  ffi_func :sp_GuiPanel, %i[float float float float str], :int
  ffi_func :sp_GuiStatusBar, %i[float float float float str], :int
  ffi_func :sp_GuiDummyRec, %i[float float float float str], :int
  ffi_func :sp_GuiCheckBox, %i[float float float float str ptr], :int
  ffi_func :sp_GuiComboBox, %i[float float float float str ptr], :int
  ffi_func :sp_GuiDropdownBox, %i[float float float float str ptr int], :int
  ffi_func :sp_GuiSpinner, %i[float float float float str ptr int int int], :int
  ffi_func :sp_GuiValueBox, %i[float float float float str ptr int int int], :int
  ffi_func :sp_GuiSlider, %i[float float float float str str ptr float float], :int
  ffi_func :sp_GuiSliderBar, %i[float float float float str str ptr float float], :int
  ffi_func :sp_GuiProgressBar, %i[float float float float str str ptr float float], :int
  ffi_func :sp_GuiWindowBox, %i[float float float float str], :int
  ffi_func :sp_GuiMessageBox, %i[float float float float str str str ptr], :int
  ffi_func :sp_GuiListView, %i[float float float float str ptr ptr], :int
  ffi_func :sp_GuiColorPicker, %i[float float float float str ptr], :int
  ffi_func :sp_GuiGrid, %i[float float float float str float int ptr], :int

  # Value-returning variants (updated value read back via GetFloat/GetInt).
  ffi_func :sp_GuiCheckBoxValue, %i[float float float float str int], :int
  ffi_func :sp_GuiSliderBarValue, %i[float float float float str str float float float], :int
  ffi_func :sp_GuiSliderValue, %i[float float float float str str float float float], :int
  ffi_func :sp_GuiSpinnerValue, %i[float float float float str int int int int], :int
  ffi_func :sp_GuiDropdownBoxValue, %i[float float float float str int int], :int
  ffi_func :sp_GuiComboBoxValue, %i[float float float float str int], :int
  ffi_func :sp_GuiListViewValue, %i[float float float float str int int], :int
  ffi_func :sp_Gui_GetFloat, [], :float
  ffi_func :sp_Gui_GetInt, [], :int
  ffi_func :sp_GuiTextBoxFloat, %i[float float float float str int], :int
  ffi_func :sp_GuiScrollPanel, %i[float float float float str float float float float], :int
  ffi_func :sp_GuiToggleGroup, %i[float float float float str int], :int
  ffi_func :sp_GuiToggleSlider, %i[float float float float str int], :int
  ffi_func :sp_GuiColorBarAlpha, %i[float float float float str float], :int
  ffi_func :sp_GuiColorPickerSet, %i[int int int int], :void
  ffi_func :sp_GuiColorPickerValue, %i[float float float float str], :int
  ffi_func :sp_Gui_GetColorR, [], :int
  ffi_func :sp_Gui_GetColorG, [], :int
  ffi_func :sp_Gui_GetColorB, [], :int
  ffi_func :sp_Gui_GetColorA, [], :int
  ffi_func :sp_GuiValueBoxValue, %i[float float float float str int int int int], :int
  ffi_func :sp_GuiIconText, %i[int str], :str
  ffi_func :sp_GuiProgressBarValue, %i[float float float float str str float float float], :int

  # PascalCase surface (matches the gem's Gui* names).
  def self.GuiLock = Raylib.sp_GuiLock
  def self.GuiUnlock = Raylib.sp_GuiUnlock
  def self.GuiEnable = Raylib.sp_GuiEnable
  def self.GuiDisable = Raylib.sp_GuiDisable
  def self.GuiSetAlpha(alpha) = Raylib.sp_GuiSetAlpha(alpha)
  def self.GuiSetState(state) = Raylib.sp_GuiSetState(state)
  def self.GuiSetStyle(control, property, value) = Raylib.sp_GuiSetStyle(control, property, value)
  def self.GuiGetStyle(control, property) = Raylib.sp_GuiGetStyle(control, property)
  def self.GuiSetFont(font) = Raylib.sp_GuiSetFont(font)
  def self.GuiLoadStyle(file) = Raylib.sp_GuiLoadStyle(file)
  def self.GuiLoadStyleDefault = Raylib.sp_GuiLoadStyleDefault

  def self.GuiButton(x, y, w, h, text) = Raylib.sp_GuiButton(x, y, w, h, text)
  def self.GuiLabel(x, y, w, h, text) = Raylib.sp_GuiLabel(x, y, w, h, text)
  def self.GuiLabelButton(x, y, w, h, text) = Raylib.sp_GuiLabelButton(x, y, w, h, text)
  def self.GuiGroupBox(x, y, w, h, text) = Raylib.sp_GuiGroupBox(x, y, w, h, text)
  def self.GuiLine(x, y, w, h, text) = Raylib.sp_GuiLine(x, y, w, h, text)
  def self.GuiPanel(x, y, w, h, text) = Raylib.sp_GuiPanel(x, y, w, h, text)
  def self.GuiStatusBar(x, y, w, h, text) = Raylib.sp_GuiStatusBar(x, y, w, h, text)
  def self.GuiCheckBox(x, y, w, h, text, checked) = Raylib.sp_GuiCheckBox(x, y, w, h, text, checked)
  def self.GuiComboBox(x, y, w, h, text, active) = Raylib.sp_GuiComboBox(x, y, w, h, text, active)
  def self.GuiDropdownBox(x, y, w, h, text, active, edit) = Raylib.sp_GuiDropdownBox(x, y, w, h, text, active, edit)
  def self.GuiSpinner(x, y, w, h, text, value, lo, hi, edit) = Raylib.sp_GuiSpinner(x, y, w, h, text, value, lo, hi, edit)
  def self.GuiValueBox(x, y, w, h, text, value, lo, hi, edit) = Raylib.sp_GuiValueBox(x, y, w, h, text, value, lo, hi, edit)
  def self.GuiSlider(x, y, w, h, l, r, value, lo, hi) = Raylib.sp_GuiSlider(x, y, w, h, l, r, value, lo, hi)
  def self.GuiSliderBar(x, y, w, h, l, r, value, lo, hi) = Raylib.sp_GuiSliderBar(x, y, w, h, l, r, value, lo, hi)
  def self.GuiProgressBar(x, y, w, h, l, r, value, lo, hi) = Raylib.sp_GuiProgressBar(x, y, w, h, l, r, value, lo, hi)
  def self.GuiWindowBox(x, y, w, h, title) = Raylib.sp_GuiWindowBox(x, y, w, h, title)
  def self.GuiMessageBox(x, y, w, h, title, message, btns, active) = Raylib.sp_GuiMessageBox(x, y, w, h, title, message, btns, active)
  def self.GuiListView(x, y, w, h, text, scroll, active) = Raylib.sp_GuiListView(x, y, w, h, text, scroll, active)
  def self.GuiColorPicker(x, y, w, h, text, color) = Raylib.sp_GuiColorPicker(x, y, w, h, text, color)
  def self.GuiGrid(x, y, w, h, text, spacing, subdivs, cell) = Raylib.sp_GuiGrid(x, y, w, h, text, spacing, subdivs, cell)

  # Value-returning helpers: run the control, then read the updated value.
  def self.GuiCheckBoxValue(x, y, w, h, text, checked)
    r = Raylib.sp_GuiCheckBoxValue(x, y, w, h, text, checked ? 1 : 0)
    [r, Raylib.sp_Gui_GetInt]
  end
  def self.GuiSliderBarValue(x, y, w, h, l, r, value, lo, hi)
    res = Raylib.sp_GuiSliderBarValue(x, y, w, h, l, r, value, lo, hi)
    [res, Raylib.sp_Gui_GetFloat]
  end
  def self.GuiSliderValue(x, y, w, h, l, r, value, lo, hi)
    res = Raylib.sp_GuiSliderValue(x, y, w, h, l, r, value, lo, hi)
    [res, Raylib.sp_Gui_GetFloat]
  end
  def self.GuiSpinnerValue(x, y, w, h, text, value, lo, hi, edit)
    res = Raylib.sp_GuiSpinnerValue(x, y, w, h, text, value, lo, hi, edit)
    [res, Raylib.sp_Gui_GetInt]
  end
  def self.GuiDropdownBoxValue(x, y, w, h, text, active, edit)
    res = Raylib.sp_GuiDropdownBoxValue(x, y, w, h, text, active, edit)
    [res, Raylib.sp_Gui_GetInt]
  end
  def self.GuiComboBoxValue(x, y, w, h, text, active)
    res = Raylib.sp_GuiComboBoxValue(x, y, w, h, text, active)
    [res, Raylib.sp_Gui_GetInt]
  end
  def self.GuiListViewValue(x, y, w, h, text, scroll, active)
    res = Raylib.sp_GuiListViewValue(x, y, w, h, text, scroll, active)
    [res, Raylib.sp_Gui_GetInt]
  end

  def self.GuiTextBoxFloat(x, y, w, h, text, edit) = Raylib.sp_GuiTextBoxFloat(x, y, w, h, text, edit)
  def self.GuiScrollPanel(x, y, w, h, text, cx, cy, cw, ch) = Raylib.sp_GuiScrollPanel(x, y, w, h, text, cx, cy, cw, ch)
  def self.GuiIconText(icon, text) = Raylib.sp_GuiIconText(icon, text)

  def self.GuiValueBoxValue(x, y, w, h, text, value, lo, hi, edit)
    res = Raylib.sp_GuiValueBoxValue(x, y, w, h, text, value, lo, hi, edit)
    [res, Raylib.sp_Gui_GetInt]
  end
  def self.GuiToggleGroupValue(x, y, w, h, text, active)
    res = Raylib.sp_GuiToggleGroup(x, y, w, h, text, active)
    [res, Raylib.sp_Gui_GetInt]
  end
  def self.GuiToggleSliderValue(x, y, w, h, text, active)
    res = Raylib.sp_GuiToggleSlider(x, y, w, h, text, active)
    [res, Raylib.sp_Gui_GetInt]
  end
  def self.GuiColorBarAlphaValue(x, y, w, h, text, alpha)
    res = Raylib.sp_GuiColorBarAlpha(x, y, w, h, text, alpha)
    [res, Raylib.sp_Gui_GetFloat]
  end
  def self.GuiColorPickerSet(r, g, b, a) = Raylib.sp_GuiColorPickerSet(r, g, b, a)
  def self.GuiColorPickerValue(x, y, w, h, text) = Raylib.sp_GuiColorPickerValue(x, y, w, h, text)
  def self.GuiProgressBarValue(x, y, w, h, l, r, value, lo, hi)
    res = Raylib.sp_GuiProgressBarValue(x, y, w, h, l, r, value, lo, hi)
    [res, Raylib.sp_Gui_GetFloat]
  end

  # Legacy RGui* aliases (the examples use these names).
  def self.RGuiCheckBox(x, y, w, h, text, checked) = Raylib.sp_GuiCheckBox(x, y, w, h, text, checked)
  def self.RGuiSliderBar(x, y, w, h, l, r, value, lo, hi) = Raylib.sp_GuiSliderBar(x, y, w, h, l, r, value, lo, hi)
  def self.RGuiSlider(x, y, w, h, l, r, value, lo, hi) = Raylib.sp_GuiSlider(x, y, w, h, l, r, value, lo, hi)
  def self.RGuiDropdownBox(x, y, w, h, text, active, edit) = Raylib.sp_GuiDropdownBox(x, y, w, h, text, active, edit)
  def self.RGuiComboBox(x, y, w, h, text, active) = Raylib.sp_GuiComboBox(x, y, w, h, text, active)
  def self.RGuiProgressBar(x, y, w, h, l, r, value, lo, hi) = Raylib.sp_GuiProgressBar(x, y, w, h, l, r, value, lo, hi)
  def self.RGuiListView(x, y, w, h, text, scroll, active) = Raylib.sp_GuiListView(x, y, w, h, text, scroll, active)

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
end
