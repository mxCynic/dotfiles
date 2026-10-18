-- 配置中可复用的函数与共享状态,统一放在这里,按功能分组:
--   touchpad   : 内置触控板开关(SUPER + X)
--                enabled(bool) 由 device.lua 读取做启动设备配置
--                toggle()      由 binds.lua 绑定
--   pin_nofocus: 悬浮窗固定并禁止自动聚焦(SUPER + A),主要用于浮动歌词不抢聚焦
--   focus      : 焦点在悬浮/平铺窗口间切换(SUPER + TAB,不含 pin_nofocus 浮层)
--   workspace  : 空工作区/上一工作区切换(SUPER + Z)
--
-- 每个函数都写成 `(function() ... end)()`:私有辅助函数、常量与捕获的状态都收在闭包
-- 里,文件级作用域只剩 functions 一张表;binds.lua 里因此统一写成不带括号的函数引用。

local functions = {
  touchpad = {
    enabled = true, -- 默认开启
  },
  pin_nofocus = {},
  focus = {},
  workspace = {},
}

-- 翻转 bool 后直接调用 hl.device() 运行时启停,不需要 bash/状态文件/reload。
functions.touchpad.toggle = (function()
  -- enabled 是跨文件共享状态:device.lua 启动时读它做初始设备配置。
  local touchpad = functions.touchpad
  local TOUCHPAD_NAME = "dell0a6e:00-04f3:317e-touchpad"
  local TOUCHPAD_MOUSE_NAME = "dell0a6e:00-04f3:317e-mouse"

  return function()
    touchpad.enabled = not touchpad.enabled

    hl.device({
      name = TOUCHPAD_NAME,
      enabled = touchpad.enabled,
    })
    -- The companion -mouse node belongs to the same ELAN I2C controller; keep it
    -- in sync so both halves of the device follow the same state.
    hl.device({
      name = TOUCHPAD_MOUSE_NAME,
      enabled = touchpad.enabled,
    })

    hl.notification.create({
      text = touchpad.enabled and "触控板已开启" or "触控板已关闭",
      timeout = 1500,
      icon = "ok",
    })
  end
end)()

-- pin_nofocus:把当前悬浮窗口固定并禁止自动聚焦,再按一次恢复。
functions.pin_nofocus.toggle = (function()
  local tag = "pin_nofocus"

  local function has_tag(window)
    for _, t in ipairs(window.tags or {}) do
      if t == tag then
        return true
      end
    end
    return false
  end

  return function()
    local window = hl.get_active_window()
    if not window then return end

    if window.floating and window.fullscreen == 0 and not window.pinned and not has_tag(window) then
      -- Tag the window and mark it as pinned with no_focus
      hl.dispatch(hl.dsp.window.tag({ tag = "+" .. tag, window = window }))
      hl.dispatch(hl.dsp.window.pin({ window = window }))
      hl.dispatch(hl.dsp.window.set_prop({ prop = "no_focus", value = "1", window = window }))
    else
      -- Restore all windows that were marked this way
      for _, marked_window in ipairs(hl.get_windows({ tag = tag })) do
        hl.dispatch(hl.dsp.window.set_prop({ prop = "no_focus", value = "unset", window = marked_window }))
        -- no_focus can move focus away, so the marked window may not be active.
        if marked_window.pinned then
          hl.dispatch(hl.dsp.window.pin({ window = marked_window }))
        end
        hl.dispatch(hl.dsp.window.tag({ tag = "-" .. tag, window = marked_window }))
      end
    end
  end
end)()

-- 焦点在悬浮窗口与平铺窗口之间切换(仅限当前工作区)。
-- cycle_next 内部用 isWorkspaceMatches(anyWorkspace = false) 限定同一工作区,不会跳到别的
-- workspace;floating / tiled 互斥地传一个,只挑“对面那一类”窗口,否则会在同类窗口之间打转。
-- cycle 只考虑可聚焦窗口,带 no_focus 规则的 pin_nofocus 浮层因此不会被选中。
-- 这是预期行为:浮层只做展示,不参与 SUPER + TAB 的焦点循环。
functions.focus.toggle_floating_tiled = (function()
  return function()
    local window = hl.get_active_window()
    if not window then
      return
    end

    hl.dispatch(hl.dsp.window.cycle_next({
      floating = not window.floating,
      tiled = window.floating,
    }))
  end
end)()

-- MOD+Z:当前工作区非空 → 切到空工作区;当前已是空工作区 → 回到上一个工作区。
functions.workspace.toggle_empty = (function()
  local PREVIOUS = "previous"
  local EMPTY = "empty"

  return function()
    local ws = hl.get_active_workspace()
    if ws == nil then
      return
    end

    if ws.windows == 0 then
      hl.dispatch(hl.dsp.focus({ workspace = PREVIOUS }))
    else
      hl.dispatch(hl.dsp.focus({ workspace = EMPTY }))
    end
  end
end)()

return functions
