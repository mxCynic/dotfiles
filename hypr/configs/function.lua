-- 配置中可复用的函数与共享状态,统一放在这里。
-- 内置触控板开关:
--   变量主体 -> functions.touchpad_enabled(bool,默认开启)
--   函数主体 -> functions.toggle_touchpad()
-- common.lua 引入变量设置启动时的设备状态,binds.lua 引入函数绑定 SUPER + X。

local functions = {}

functions.touchpad_enabled = true

local TOUCHPAD_NAME = "dell0a6e:00-04f3:317e-touchpad"
local TOUCHPAD_MOUSE_NAME = "dell0a6e:00-04f3:317e-mouse"

-- 翻转 bool 后直接调用 hl.device() 运行时启停,不需要 bash/状态文件/reload。
function functions.toggle_touchpad()
  functions.touchpad_enabled = not functions.touchpad_enabled

  hl.device({
    name = TOUCHPAD_NAME,
    enabled = functions.touchpad_enabled,
  })
  -- The companion -mouse node belongs to the same ELAN I2C controller; keep it
  -- in sync so both halves of the device follow the same state.
  hl.device({
    name = TOUCHPAD_MOUSE_NAME,
    enabled = functions.touchpad_enabled,
  })

  hl.notification.create({
    text = functions.touchpad_enabled and "触控板已开启" or "触控板已关闭",
    timeout = 1500,
    icon = "ok",
  })
end

return functions
