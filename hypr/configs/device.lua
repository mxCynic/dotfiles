-- 设备相关配置:显示器、输入(键盘/指针/触控板)、光标,以及按设备名覆盖的 hl.device()。
-- 可复用的函数与共享状态(内置触控板开关等)见 configs/function.lua。
local functions = require("configs.function")

-- 显示器
hl.monitor({ output = "eDP-1", mode = "1920x1080@165", position = "0x0", scale = "1", disabled = false })
hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@144", position = "1920x-20", scale = "1", })

-- 键盘/指针/触控板的全局默认值
hl.config({
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
    inactive_timeout = 2,
    hide_on_key_press = true,
  },
})

-- 鼠标:降低灵敏度
hl.device({
  name = "epic-mouse-v1",
  sensitivity = 0.5,
})

-- 内置触控板默认开启,状态变量在 configs/function.lua 的 functions.touchpad.enabled;
-- SUPER + X 由 binds.lua 调 functions.touchpad.toggle() 运行时切换。
-- 注意:该 bool 只存在于本次配置上下文,reload/重启后回到默认开启。
local touchpad_enabled = functions.touchpad.enabled

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
