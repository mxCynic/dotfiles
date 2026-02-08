-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
  -- Ignore maximize requests from all apps. You'll probably like this.
  name = "suppress-maximize-events",
  match = { class = ".*" },

  suppress_event = "maximize",
})
suppressMaximizeRule:set_enabled(false)

hl.window_rule({
  -- Fix some dragging issues with XWayland
  name = "fix-xwayland-drags",
  match = {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },

  no_focus = true,
})

hl.window_rule({
  name = "move-hyprland-run",
  match = { class = "hyprland-run" },

  move = "20 monitor_h-120",
  float = true,
})

local float_windows = {
  "图片查看器",
  "(Volume Control)",
  "All FilesA",
  "sattys",
  "Friends ListF",
  "ankia",
  "aitest-tauria",
  "org.pulseaudio.pavucontrol",
}
for _, name in ipairs(float_windows) do
  hl.window_rule({ match = { class = name }, float = true })
end

hl.window_rule({ match = { class = "SPlayer" }, { wokspace = 10, no_initial_focus = true } })
hl.window_rule({ match = { class = "clash-verge" }, { wokspace = 9, no_initial_focus = true } })

-- 浮动窗口无边框
hl.window_rule({ match = { float = true }, border_size = 0 })

hl.window_rule({ match = { tag = "opacity" }, opacity = "0.8" }) -- Set opacity for tag `opacity`

hl.window_rule({ match = { class = "cs2" }, immediate = true })
