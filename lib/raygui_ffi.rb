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
  ffi_func :rl_Gui_GetInt, [], :int
  ffi_func :rl_GuiTextBoxFloat, %i[float float float float str int], :int
  ffi_func :rl_GuiScrollPanel, %i[float float float float str float float float float], :int
  ffi_func :rl_GuiToggleGroup, %i[float float float float str int], :int
  ffi_func :rl_GuiToggleSlider, %i[float float float float str int], :int
  ffi_func :rl_GuiColorBarAlpha, %i[float float float float str float], :int
  ffi_func :rl_GuiColorPickerSet, %i[int int int int], :void
  ffi_func :rl_GuiColorPickerValue, %i[float float float float str], :int
  ffi_func :rl_Gui_GetColorR, [], :int
  ffi_func :rl_Gui_GetColorG, [], :int
  ffi_func :rl_Gui_GetColorB, [], :int
  ffi_func :rl_Gui_GetColorA, [], :int
  ffi_func :rl_GuiValueBoxValue, %i[float float float float str int int int int], :int
  ffi_func :rl_GuiIconText, %i[int str], :str
  ffi_func :rl_GuiProgressBarValue, %i[float float float float str str float float float], :int

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

  def self.GuiButton(x, y, w, h, text) = Raylib.rl_GuiButton(x, y, w, h, text)
  def self.GuiLabel(x, y, w, h, text) = Raylib.rl_GuiLabel(x, y, w, h, text)
  def self.GuiLabelButton(x, y, w, h, text) = Raylib.rl_GuiLabelButton(x, y, w, h, text)
  def self.GuiGroupBox(x, y, w, h, text) = Raylib.rl_GuiGroupBox(x, y, w, h, text)
  def self.GuiLine(x, y, w, h, text) = Raylib.rl_GuiLine(x, y, w, h, text)
  def self.GuiPanel(x, y, w, h, text) = Raylib.rl_GuiPanel(x, y, w, h, text)
  def self.GuiStatusBar(x, y, w, h, text) = Raylib.rl_GuiStatusBar(x, y, w, h, text)
  def self.GuiCheckBox(x, y, w, h, text, checked) = Raylib.rl_GuiCheckBox(x, y, w, h, text, checked)
  def self.GuiComboBox(x, y, w, h, text, active) = Raylib.rl_GuiComboBox(x, y, w, h, text, active)
  def self.GuiDropdownBox(x, y, w, h, text, active, edit) = Raylib.rl_GuiDropdownBox(x, y, w, h, text, active, edit)
  def self.GuiSpinner(x, y, w, h, text, value, lo, hi, edit) = Raylib.rl_GuiSpinner(x, y, w, h, text, value, lo, hi, edit)
  def self.GuiValueBox(x, y, w, h, text, value, lo, hi, edit) = Raylib.rl_GuiValueBox(x, y, w, h, text, value, lo, hi, edit)
  def self.GuiSlider(x, y, w, h, l, r, value, lo, hi) = Raylib.rl_GuiSlider(x, y, w, h, l, r, value, lo, hi)
  def self.GuiSliderBar(x, y, w, h, l, r, value, lo, hi) = Raylib.rl_GuiSliderBar(x, y, w, h, l, r, value, lo, hi)
  def self.GuiProgressBar(x, y, w, h, l, r, value, lo, hi) = Raylib.rl_GuiProgressBar(x, y, w, h, l, r, value, lo, hi)
  def self.GuiWindowBox(x, y, w, h, title) = Raylib.rl_GuiWindowBox(x, y, w, h, title)
  def self.GuiMessageBox(x, y, w, h, title, message, btns, active) = Raylib.rl_GuiMessageBox(x, y, w, h, title, message, btns, active)
  def self.GuiListView(x, y, w, h, text, scroll, active) = Raylib.rl_GuiListView(x, y, w, h, text, scroll, active)
  def self.GuiColorPicker(x, y, w, h, text, color) = Raylib.rl_GuiColorPicker(x, y, w, h, text, color)
  def self.GuiGrid(x, y, w, h, text, spacing, subdivs, cell) = Raylib.rl_GuiGrid(x, y, w, h, text, spacing, subdivs, cell)

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
    res = Raylib.rl_GuiSpinnerValue(x, y, w, h, text, value, lo, hi, edit)
    [res, Raylib.rl_Gui_GetInt]
  end
  def self.GuiDropdownBoxValue(x, y, w, h, text, active, edit)
    res = Raylib.rl_GuiDropdownBoxValue(x, y, w, h, text, active, edit)
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

  def self.GuiTextBoxFloat(x, y, w, h, text, edit) = Raylib.rl_GuiTextBoxFloat(x, y, w, h, text, edit)
  def self.GuiScrollPanel(x, y, w, h, text, cx, cy, cw, ch) = Raylib.rl_GuiScrollPanel(x, y, w, h, text, cx, cy, cw, ch)
  def self.GuiIconText(icon, text) = Raylib.rl_GuiIconText(icon, text)

  def self.GuiValueBoxValue(x, y, w, h, text, value, lo, hi, edit)
    res = Raylib.rl_GuiValueBoxValue(x, y, w, h, text, value, lo, hi, edit)
    [res, Raylib.rl_Gui_GetInt]
  end
  def self.GuiToggleGroupValue(x, y, w, h, text, active)
    res = Raylib.rl_GuiToggleGroup(x, y, w, h, text, active)
    [res, Raylib.rl_Gui_GetInt]
  end
  def self.GuiToggleSliderValue(x, y, w, h, text, active)
    res = Raylib.rl_GuiToggleSlider(x, y, w, h, text, active)
    [res, Raylib.rl_Gui_GetInt]
  end
  def self.GuiColorBarAlphaValue(x, y, w, h, text, alpha)
    res = Raylib.rl_GuiColorBarAlpha(x, y, w, h, text, alpha)
    [res, Raylib.rl_Gui_GetFloat]
  end
  def self.GuiColorPickerSet(r, g, b, a) = Raylib.rl_GuiColorPickerSet(r, g, b, a)
  def self.GuiColorPickerValue(x, y, w, h, text) = Raylib.rl_GuiColorPickerValue(x, y, w, h, text)
  def self.GuiProgressBarValue(x, y, w, h, l, r, value, lo, hi)
    res = Raylib.rl_GuiProgressBarValue(x, y, w, h, l, r, value, lo, hi)
    [res, Raylib.rl_Gui_GetFloat]
  end

  # Legacy RGui* aliases (the examples use these names).
  def self.RGuiCheckBox(x, y, w, h, text, checked) = Raylib.rl_GuiCheckBox(x, y, w, h, text, checked)
  def self.RGuiSliderBar(x, y, w, h, l, r, value, lo, hi) = Raylib.rl_GuiSliderBar(x, y, w, h, l, r, value, lo, hi)
  def self.RGuiSlider(x, y, w, h, l, r, value, lo, hi) = Raylib.rl_GuiSlider(x, y, w, h, l, r, value, lo, hi)
  def self.RGuiDropdownBox(x, y, w, h, text, active, edit) = Raylib.rl_GuiDropdownBox(x, y, w, h, text, active, edit)
  def self.RGuiComboBox(x, y, w, h, text, active) = Raylib.rl_GuiComboBox(x, y, w, h, text, active)
  def self.RGuiProgressBar(x, y, w, h, l, r, value, lo, hi) = Raylib.rl_GuiProgressBar(x, y, w, h, l, r, value, lo, hi)
  def self.RGuiListView(x, y, w, h, text, scroll, active) = Raylib.rl_GuiListView(x, y, w, h, text, scroll, active)

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
