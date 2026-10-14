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
  ffi_func :rl_GuiToggle, %i[float float float float str int], :int
  ffi_func :rl_GuiValueBoxFloat, %i[float float float float str float int], :int
  ffi_func :rl_GuiColorBarHue, %i[float float float float str float], :int
  ffi_func :rl_GuiColorPanel, %i[float float float float str], :int
  ffi_func :rl_GuiColorPanelHSV, %i[float float float float str], :int
  ffi_func :rl_GuiColorPickerHSV, %i[float float float float str], :int
  ffi_func :rl_GuiTextBox, %i[float float float float str int int], :int
  ffi_func :rl_GuiTextInputBox, %i[float float float float str str str int str int int], :int
  ffi_func :rl_GuiListViewEx, %i[float float float float str int int int int], :int
  ffi_func :rl_GuiTabBar, %i[float float float float str int int], :int
  ffi_func :rl_GuiTabBarEx, %i[float float float float str int int int int], :int
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
  def self.GuiScrollPanel(x, y, w, h, text, cx, cy, cw, ch) = Raylib.rl_GuiScrollPanel(x, y, w, h, text, cx, cy, cw, ch)
  def self.GuiIconText(icon, text) = Raylib.rl_GuiIconText(icon, text)

  def self.GuiValueBoxValue(x, y, w, h, text, value, lo, hi, edit)
    res = Raylib.rl_GuiValueBoxValue(x, y, w, h, text, value, lo, hi,
                                     edit ? 1 : 0)
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

  # Extended surface (coverage completion).
  def self.GuiIsLocked = Raylib.rl_GuiIsLocked
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
  def self.GuiTextBox(x, y, w, h, text, text_size, edit)
    res = Raylib.rl_GuiTextBox(x, y, w, h, text, text_size, edit)
    [res, Raylib.rl_Gui_GetText]
  end
  def self.GuiTextInputBox(x, y, w, h, title, message, text, text_size, btns,
                           active, secret)
    res = Raylib.rl_GuiTextInputBox(x, y, w, h, title, message, text, text_size,
                                    btns, active, secret ? 1 : 0)
    [res, Raylib.rl_Gui_GetInt, Raylib.rl_Gui_GetInt2, Raylib.rl_Gui_GetText]
  end
  def self.GuiGetText = Raylib.rl_Gui_GetText

  # Value-returning variants (control result + updated value(s)).
  def self.GuiToggle(x, y, w, h, text, active)
    res = Raylib.rl_GuiToggle(x, y, w, h, text, active ? 1 : 0)
    [res, Raylib.rl_Gui_GetInt]
  end
  def self.GuiValueBoxFloat(x, y, w, h, text, value, edit)
    res = Raylib.rl_GuiValueBoxFloat(x, y, w, h, text, value, edit)
    [res, Raylib.rl_Gui_GetFloat]
  end
  def self.GuiColorBarAlpha(x, y, w, h, text, alpha)
    res = Raylib.rl_GuiColorBarAlpha(x, y, w, h, text, alpha)
    [res, Raylib.rl_Gui_GetFloat]
  end
  def self.GuiColorBarHue(x, y, w, h, text, value)
    res = Raylib.rl_GuiColorBarHue(x, y, w, h, text, value)
    [res, Raylib.rl_Gui_GetFloat]
  end
  def self.GuiToggleGroup(x, y, w, h, text, active)
    res = Raylib.rl_GuiToggleGroup(x, y, w, h, text, active)
    [res, Raylib.rl_Gui_GetInt]
  end
  def self.GuiToggleSlider(x, y, w, h, text, active)
    res = Raylib.rl_GuiToggleSlider(x, y, w, h, text, active)
    [res, Raylib.rl_Gui_GetInt]
  end
  def self.GuiDummyRec(x, y, w, h, text) = Raylib.rl_GuiDummyRec(x, y, w, h, text)
  def self.GuiColorPanel(x, y, w, h, text)
    res = Raylib.rl_GuiColorPanel(x, y, w, h, text)
    [res, Raylib.rl_Gui_GetColorR, Raylib.rl_Gui_GetColorG,
     Raylib.rl_Gui_GetColorB, Raylib.rl_Gui_GetColorA]
  end
  def self.GuiColorPanelHSV(x, y, w, h, text)
    res = Raylib.rl_GuiColorPanelHSV(x, y, w, h, text)
    [res, Raylib.rl_Gui_GetHsvH, Raylib.rl_Gui_GetHsvS, Raylib.rl_Gui_GetHsvV]
  end
  def self.GuiColorPickerHSV(x, y, w, h, text)
    res = Raylib.rl_GuiColorPickerHSV(x, y, w, h, text)
    [res, Raylib.rl_Gui_GetHsvH, Raylib.rl_Gui_GetHsvS, Raylib.rl_Gui_GetHsvV]
  end
  def self.GuiListViewEx(x, y, w, h, text, count, scroll, active, focus)
    res = Raylib.rl_GuiListViewEx(x, y, w, h, text, count, scroll, active, focus)
    [res, Raylib.rl_Gui_GetInt, Raylib.rl_Gui_GetInt2, Raylib.rl_Gui_GetInt3]
  end
  def self.GuiTabBar(x, y, w, h, text, hscroll, active)
    res = Raylib.rl_GuiTabBar(x, y, w, h, text, hscroll, active)
    [res, Raylib.rl_Gui_GetInt, Raylib.rl_Gui_GetInt2]
  end
  def self.GuiTabBarEx(x, y, w, h, text, count, hscroll, active, focus)
    res = Raylib.rl_GuiTabBarEx(x, y, w, h, text, count, hscroll, active, focus)
    [res, Raylib.rl_Gui_GetInt, Raylib.rl_Gui_GetInt2, Raylib.rl_Gui_GetInt3]
  end
  def self.GuiSetColorHSV(h, s, v) = Raylib.rl_Gui_SetHsv(h, s, v)

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

  # ====== generated: snake_case aliases (MRI gem naming, tools/gen_raygui_aliases.py) ======
  def self.gui_toggle_group(p0, p1, p2)
    Raylib.rl_GuiToggleGroup(p0, p1, p2)
  end
  def self.gui_toggle_slider(p0, p1, p2)
    Raylib.rl_GuiToggleSlider(p0, p1, p2)
  end
  def self.gui_dummy_rec(p0, p1)
    Raylib.rl_GuiDummyRec(p0, p1)
  end
  def self.gui_color_bar_alpha(p0, p1, p2)
    Raylib.rl_GuiColorBarAlpha(p0, p1, p2)
  end
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
end
