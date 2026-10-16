# frozen_string_literal: true

# raygui_compat.rb — the gem's RGui* helper layer for the Spinel path.
#
# raygui_helper.rb defines RGui* wrappers that take a Rectangle and return the
# updated value(s) plus the control result (the C API's out-params become
# return values). raygui_ffi.rb ships flat-coordinate RGui* forms for the
# hello_raylib scenes; this file defines the gem-shaped ones, and because it is
# loaded after raygui_ffi.rb it wins on the gem-compat path. The value shims
# (rl_Gui*Value + rl_Gui_Get*) carry the out-params out of C.
module Raylib
  def self.RGuiTabBar(bounds, text, count, active)
    res = Raylib.rl_GuiTabBarValue(bounds.x, bounds.y, bounds.width, bounds.height,
                                   text, (count || 0).to_i, (active || 0).to_i)
    [Raylib.rl_Gui_GetInt, res]
  end

  def self.RGuiToggle(bounds, text, active)
    res = Raylib.rl_GuiToggleValue(bounds.x, bounds.y, bounds.width, bounds.height,
                                   text, active ? 1 : 0)
    [Raylib.rl_Gui_GetInt, res]
  end

  def self.RGuiToggleGroup(bounds, text, active)
    res = Raylib.rl_GuiToggleGroupValue(bounds.x, bounds.y, bounds.width,
                                        bounds.height, text, (active || 0).to_i)
    [Raylib.rl_Gui_GetInt, res]
  end

  def self.RGuiToggleSlider(bounds, text, active)
    res = Raylib.rl_GuiToggleSliderValue(bounds.x, bounds.y, bounds.width,
                                         bounds.height, text, (active || 0).to_i)
    [Raylib.rl_Gui_GetInt, res]
  end

  def self.RGuiCheckBox(bounds, text, checked)
    res = Raylib.rl_GuiCheckBoxValue(bounds.x, bounds.y, bounds.width,
                                     bounds.height, text, checked ? 1 : 0)
    [Raylib.rl_Gui_GetInt != 0, res]
  end

  def self.RGuiComboBox(bounds, text, active)
    res = Raylib.rl_GuiComboBoxValue(bounds.x, bounds.y, bounds.width,
                                     bounds.height, text, (active || 0).to_i)
    [Raylib.rl_Gui_GetInt, res]
  end

  def self.RGuiDropdownBox(bounds, text, active, edit_mode)
    res = Raylib.rl_GuiDropdownBoxValue(bounds.x, bounds.y, bounds.width,
                                        bounds.height, text, (active || 0).to_i,
                                        edit_mode ? 1 : 0)
    [Raylib.rl_Gui_GetInt, res]
  end

  def self.RGuiSpinner(bounds, text, value, min_value, max_value, edit_mode)
    res = Raylib.rl_GuiSpinnerValue(bounds.x, bounds.y, bounds.width,
                                    bounds.height, text, (value || 0).to_i, (min_value || 0).to_i,
                                    (max_value || 0).to_i, edit_mode ? 1 : 0)
    [Raylib.rl_Gui_GetInt, res]
  end

  def self.RGuiValueBox(bounds, text, value, min_value, max_value, edit_mode)
    res = Raylib.rl_GuiValueBoxValue(bounds.x, bounds.y, bounds.width,
                                     bounds.height, text, (value || 0).to_i, (min_value || 0).to_i,
                                     (max_value || 0).to_i, edit_mode ? 1 : 0)
    [Raylib.rl_Gui_GetInt, res]
  end

  def self.RGuiSlider(bounds, text_left, text_right, value, min_value, max_value)
    res = Raylib.rl_GuiSliderValue(bounds.x, bounds.y, bounds.width,
                                   bounds.height, text_left, text_right, (value || 0).to_f,
                                   (min_value || 0).to_f, (max_value || 0).to_f)
    [Raylib.rl_Gui_GetFloat, res]
  end

  def self.RGuiSliderBar(bounds, text_left, text_right, value, min_value,
                         max_value)
    res = Raylib.rl_GuiSliderBarValue(bounds.x, bounds.y, bounds.width,
                                      bounds.height, text_left, text_right,
                                      (value || 0).to_f, (min_value || 0).to_f, (max_value || 0).to_f)
    [Raylib.rl_Gui_GetFloat, res]
  end

  def self.RGuiProgressBar(bounds, text_left, text_right, value, min_value,
                           max_value)
    res = Raylib.rl_GuiProgressBarValue(bounds.x, bounds.y, bounds.width,
                                        bounds.height, text_left, text_right,
                                        (value || 0).to_f, (min_value || 0).to_f, (max_value || 0).to_f)
    [Raylib.rl_Gui_GetFloat, res]
  end

  def self.RGuiListView(bounds, text, scroll_index, active)
    res = Raylib.rl_GuiListViewValue(bounds.x, bounds.y, bounds.width,
                                     bounds.height, text, (scroll_index || 0).to_i, (active || 0).to_i)
    [Raylib.rl_Gui_GetInt2, Raylib.rl_Gui_GetInt, res]
  end

  def self.RGuiListViewEx(bounds, text, count, scroll_index, active, focus)
    res = Raylib.rl_GuiListViewExValue(bounds.x, bounds.y, bounds.width,
                                       bounds.height, text, (count || 0).to_i, text.bytesize, (scroll_index || 0).to_i,
                                       (active || 0).to_i, (focus || 0).to_i)
    [Raylib.rl_Gui_GetInt, Raylib.rl_Gui_GetInt2, Raylib.rl_Gui_GetInt3, res]
  end

  def self.RGuiColorBarAlpha(bounds, text, alpha)
    res = Raylib.rl_GuiColorBarAlphaValue(bounds.x, bounds.y, bounds.width,
                                          bounds.height, text, (alpha || 0).to_f)
    [Raylib.rl_Gui_GetFloat, res]
  end

  def self.RGuiColorBarHue(bounds, text, value)
    res = Raylib.rl_GuiColorBarHueValue(bounds.x, bounds.y, bounds.width,
                                        bounds.height, text, (value || 0).to_f)
    [Raylib.rl_Gui_GetFloat, res]
  end
end
