-- 配置中可复用的函数与共享状态,统一放在这里,按功能分组:
--   touchpad   : 内置触控板开关(SUPER + X)
--                enabled(bool) 由 common.lua 读取做启动设备配置
--                toggle()      由 binds.lua 绑定
--   pin_nofocus: 悬浮窗固定并禁止自动聚焦(SUPER + A),主要用于浮动歌词不抢聚焦
--   focus      : 焦点在悬浮/平铺窗口间切换(SUPER + TAB)

local functions = {
  touchpad = {
    enabled = true, -- 默认开启
  },
  pin_nofocus = {},
  focus = {},
}

local TOUCHPAD_NAME = "dell0a6e:00-04f3:317e-touchpad"
local TOUCHPAD_MOUSE_NAME = "dell0a6e:00-04f3:317e-mouse"

-- 翻转 bool 后直接调用 hl.device() 运行时启停,不需要 bash/状态文件/reload。
function functions.touchpad.toggle()
  functions.touchpad.enabled = not functions.touchpad.enabled

  hl.device({
    name = TOUCHPAD_NAME,
    enabled = functions.touchpad.enabled,
  })
  -- The companion -mouse node belongs to the same ELAN I2C controller; keep it
  -- in sync so both halves of the device follow the same state.
  hl.device({
    name = TOUCHPAD_MOUSE_NAME,
    enabled = functions.touchpad.enabled,
  })

  hl.notification.create({
    text = functions.touchpad.enabled and "触控板已开启" or "触控板已关闭",
    timeout = 1500,
    icon = "ok",
  })
end

-- pin_nofocus:把当前悬浮窗口固定并禁止自动聚焦,再按一次恢复
local pin_nofocus_tag = "pin_nofocus"
local pin_nofocus_windows = {}

local function restore_pin_nofocus_windows()
  for _, window in ipairs(hl.get_windows({ tag = pin_nofocus_tag })) do
    hl.dispatch(hl.dsp.window.set_prop({ prop = "no_focus", value = "unset", window = window }))
    if window.pinned then
      hl.dispatch(hl.dsp.window.pin({ window = window }))
    end
    hl.dispatch(hl.dsp.window.tag({ tag = "-" .. pin_nofocus_tag, window = window }))
    pin_nofocus_windows[window.address] = nil
  end
end

function functions.pin_nofocus.toggle()
  local window = hl.get_active_window()
  if window == nil then
    return
  end

  if window.floating and not window.pinned and pin_nofocus_windows[window.address] == nil then
    pin_nofocus_windows[window.address] = true
    hl.dispatch(hl.dsp.window.tag({ tag = "+" .. pin_nofocus_tag, window = window }))
    hl.dispatch(hl.dsp.window.pin({ window = window }))
    hl.dispatch(hl.dsp.window.set_prop({ prop = "no_focus", value = "1", window = window }))
    return
  end

  restore_pin_nofocus_windows()
end

-- 焦点在悬浮窗口与平铺窗口之间切换
function functions.focus.toggle_floating_tiled()
  local window = hl.get_active_window()
  if window ~= nil and window.floating then
    hl.dispatch(hl.dsp.focus({ window = "tiled" }))
  else
    hl.dispatch(hl.dsp.focus({ window = "floating" }))
  end
end

return functions
