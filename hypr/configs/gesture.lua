-- 三指手势

-- 上下滑切换 workspace:上滑 -> 后一个 workspace(+1),下滑 -> 前一个(-1)。
-- 用内置 workspace 手势,跟手动画,松手才切换;方向由下面的
-- gestures:workspace_swipe_invert = true 保证。
hl.config({
  gestures = {
    workspace_swipe_invert = true,
    workspace_swipe_create_new = false,
  },
})

hl.gesture({
  fingers = 3,
  direction = "vertical",
  action = "workspace",
})

-- 左右滑在相邻窗口间聚焦(方向已交换:左滑聚焦右边,右滑聚焦左边)
hl.gesture({
  fingers = 3,
  direction = "left",
  action = function()
    hl.dispatch(hl.dsp.focus({ direction = "right" }))
  end,
})
hl.gesture({
  fingers = 3,
  direction = "right",
  action = function()
    hl.dispatch(hl.dsp.focus({ direction = "left" }))
  end,
})

-- 捏合切换全屏
hl.gesture({
  fingers = 3,
  direction = "pinch",
  action = "fullscreen",
})
