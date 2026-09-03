-- 可复用的函数与共享状态(内置触控板开关等),见 configs/function.lua
local functions = require("configs.function")

hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 10,

    border_size = 2,

    col = {
      active_border = { colors = { "rgba(39c5bbee)", "rgba(39c5bbee)" }, angle = 45 },
      inactive_border = "rgba(595959aa)",
    },

    -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
    resize_on_border = false,

    -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
    allow_tearing = true,

    snap = {
      enabled        = true,
      window_gap     = 5,
      monitor_gap    = 5,
      border_overlap = true,
      respect_gaps   = false,

    }
  },


  decoration = {
    rounding = 10,
    rounding_power = 2,

    -- Change transparency of focused and unfocused windows
    active_opacity = 1.0,
    inactive_opacity = 1.0,

    shadow = {
      enabled = false,
      range = 4,
      render_power = 3,
      sharp = true,
      color = "rgba(39c5bbee)",
      color_inactive = "rgba(39c5bbee)",
      offset = { 0, 0 },
      scale = 1,

    },

    blur = {
      enabled = true,
      size = 0,
      passes = 1,
      vibrancy = 0.1696,
      xray = false,
    },

    glow = {
      enabled = false,
      range = 10,
      render_power = 1,
      color = "rgba(39c5bbee)",
      color_inactive = 0,

    }
  },

  animations = {
    enabled = true,
  },

  input = {
    kb_layout = "us",
    kb_variant = "",
    kb_model = "",
    kb_options = "",
    kb_rules = "",

    follow_mouse = 1,
    left_handed = false,
    scroll_factor = 1.0,

    sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

    touchpad = {
      natural_scroll = false,
    },
  },

  cursor = {
    no_warps = false,
  },


  misc = {
    force_default_wallpaper = -1,  -- Set to 0 or 1 to disable the anime mascot wallpapers
    disable_hyprland_logo = false, -- If true disables the random hyprland logo / anime girl background. :(
  },

  binds = {
    movefocus_cycles_fullscreen = true
  },

  ecosystem = {
    no_update_news = true,
    no_donation_nag = true,
  }
})
-- 三指手势统一在 configs/gesture.lua 配置:
-- 上下滑切 workspace,左右滑聚焦相邻窗口。

hl.device({
  name = "epic-mouse-v1",
  sensitivity = 0.5,
})

-- 内置触控板默认开启,状态变量在 configs/function.lua;
-- SUPER + X 由 binds.lua 调 functions.toggle_touchpad() 运行时切换。
-- 注意:该 bool 只存在于本次配置上下文,reload/重启后回到默认开启。
local touchpad_enabled = functions.touchpad_enabled

-- The companion -mouse node belongs to the same ELAN I2C controller; keep it
-- in sync so both halves of the device follow the same state.
hl.device({
  name = "dell0a6e:00-04f3:317e-touchpad",
  enabled = touchpad_enabled,
  -- tap_button_map "lrm": 1-finger tap = left, 2-finger tap = right,
  -- 3-finger tap = middle. Requires tap_to_click.
  tap_to_click = true,
  tap_button_map = "lrm",
})
hl.device({
  name = "dell0a6e:00-04f3:317e-mouse",
  enabled = touchpad_enabled,
})

-- keyd may expose a virtual pointer device even when no mouse remapping is
-- configured. Disabling it avoids duplicate/swapped pointer events in Hyprland.
hl.device({
  name = "keyd-virtual-pointer",
  enabled = false,
  left_handed = false,
  natural_scroll = false,
  scroll_factor = 1.0,
})
