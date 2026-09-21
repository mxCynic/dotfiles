-- 配置中可复用的函数与共享状态,统一放在这里,按功能分组:
--   touchpad   : 内置触控板开关(SUPER + X)
--                enabled(bool) 由 device.lua 读取做启动设备配置
--                toggle()      由 binds.lua 绑定
--   pin_nofocus: 悬浮窗固定并禁止自动聚焦(SUPER + A),主要用于浮动歌词不抢聚焦
--   focus      : 焦点在悬浮/平铺窗口间切换(SUPER + TAB,不含 pin_nofocus 浮层)
--   workspace  : 空工作区/上一工作区切换(SUPER + Z)

local functions = {
  touchpad = {
    enabled = true, -- 默认开启
  },
  pin_nofocus = {},
  focus = {},
  workspace = {},
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

local function window_has_tag(window, tag)
  for _, t in ipairs(window.tags or {}) do
    if t == tag then
      return true
    end
  end
  return false
end

-- tag 本身就是状态,不再单独维护窗口表。
local function restore_pin_nofocus_windows()
  for _, window in ipairs(hl.get_windows({ tag = pin_nofocus_tag })) do
    hl.dispatch(hl.dsp.window.set_prop({ prop = "no_focus", value = "unset", window = window }))
    if window.pinned then
      hl.dispatch(hl.dsp.window.pin({ window = window }))
    end
    hl.dispatch(hl.dsp.window.tag({ tag = "-" .. pin_nofocus_tag, window = window }))
  end
end

function functions.pin_nofocus.toggle()
  local window = hl.get_active_window()
  if window == nil then
    return
  end

  if window.floating and not window.pinned and not window_has_tag(window, pin_nofocus_tag) then
    hl.dispatch(hl.dsp.window.tag({ tag = "+" .. pin_nofocus_tag, window = window }))
    hl.dispatch(hl.dsp.window.pin({ window = window }))
    hl.dispatch(hl.dsp.window.set_prop({ prop = "no_focus", value = "1", window = window }))
    return
  end

  restore_pin_nofocus_windows()
end

-- 焦点在悬浮窗口与平铺窗口之间切换(仅限当前工作区)。
-- cycle_next 内部用 isWorkspaceMatches(anyWorkspace = false) 限定同一工作区,不会跳到别的
-- workspace;floating 传 true 时只在当前工作区里找悬浮窗口,传 false 时不做类型过滤。
-- cycle 只考虑可聚焦窗口,带 no_focus 规则的 pin_nofocus 浮层因此不会被选中。
-- 这是预期行为:浮层只做展示,不参与 SUPER + TAB 的焦点循环。
function functions.focus.toggle_floating_tiled()
  local active = hl.get_active_window()
  if active == nil then
    return
  end

  hl.dispatch(hl.dsp.window.cycle_next({ floating = not active.floating }))
end

-- MOD+Z:当前工作区非空 → 切到空工作区;当前已是空工作区 → 回到上一个工作区。
function functions.workspace.toggle_empty()
  local ws = hl.get_active_workspace()
  if ws == nil then
    return
  end

  if ws.windows == 0 then
    hl.dispatch(hl.dsp.focus({ workspace = "previous" }))
  else
    hl.dispatch(hl.dsp.focus({ workspace = "empty" }))
  end
end

return functions
