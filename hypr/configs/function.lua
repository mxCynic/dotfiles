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

-- 焦点在悬浮窗口与平铺窗口之间切换(仅限当前工作区)。
-- 不能直接依赖 focus({ window = "floating"/"tiled" }):它按全局顺序找第一个匹配窗口,
-- 可能跳到别的 workspace;而 no_focus 的窗口会被 Hyprland 拒绝聚焦(包括显式请求),
-- 所以这里自行枚举同工作区的窗口,并对 pin_nofocus 浮层做临时解除来完成显式切换。
local function window_has_tag(window, tag)
  for _, t in ipairs(window.tags or {}) do
    if t == tag then
      return true
    end
  end
  return false
end

function functions.focus.toggle_floating_tiled()
  local active = hl.get_active_window()
  if active == nil or active.workspace == nil then
    return
  end

  local want_floating = not active.floating
  local target = nil
  local nofocus_target = nil -- 若只剩 pin_nofocus 常驻浮层,显式切换也允许聚焦它

  -- get_windows 按窗口顺序返回;不断覆盖可保留同类型里较新的那个窗口。
  for _, window in ipairs(hl.get_windows({ workspace = active.workspace.id })) do
    if window.address ~= active.address and not window.hidden and window.floating == want_floating then
      if window_has_tag(window, pin_nofocus_tag) then
        nofocus_target = window
      else
        target = window
      end
    end
  end

  target = target or nofocus_target
  if target == nil then
    return
  end

  if target == nofocus_target then
    -- no_focus 让一切聚焦请求无效(实测包括显式按地址聚焦)。按键属于显式请求,
    -- 先临时解除、聚焦成功后再恢复,窗口之后仍不会自动抢焦点。
    hl.dispatch(hl.dsp.window.set_prop({ prop = "no_focus", value = "unset", window = target }))
    hl.dispatch(hl.dsp.focus({ window = target }))
    hl.dispatch(hl.dsp.window.set_prop({ prop = "no_focus", value = "1", window = target }))
  else
    hl.dispatch(hl.dsp.focus({ window = target }))
  end
end

return functions
