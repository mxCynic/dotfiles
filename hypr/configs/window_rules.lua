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

local float_windows_by_class = {
  "(Volume Control)",
  "All Files",
  "anki",
  "aitest-tauri",
  "org.pulseaudio.pavucontrol",
  "org.kde.dolphin",
  "hyprland-share-picker",
  "org.freedesktop.impl.portal.desktop.kde",
  "imv",
}
for _, name in ipairs(float_windows_by_class) do
  hl.window_rule({ match = { class = name }, float = true, persistent_size = true })
end
local float_windows_by_title = {
  "Friends List",
  "图片查看器",
  "视频播放器",
  "^.*的聊天记录$",
  "SPlayer - 桌面歌词"
}
for _, name in ipairs(float_windows_by_title) do
  hl.window_rule({ match = { title = name }, float = true, persistent_size = true })
end

hl.window_rule({ match = { title = "反恐精英：全球攻势" }, fullscreen = true, persistent_size = true })

hl.window_rule({ match = { class = "splayer" }, workspace = "10", no_initial_focus = true })
hl.window_rule({ match = { class = "clash-verge" }, workspace = "9", no_initial_focus = true })
hl.window_rule({ match = { float = true }, border_size = 0 })    -- 浮动窗口无边框
hl.window_rule({ match = { tag = "opacity" }, opacity = "0.8" }) -- Set opacity for tag `opacity`
hl.window_rule({ match = { class = "cs2", focus = true }, immediate = true, confine_pointer = true })
hl.window_rule({ match = { title = "SPlayer - 桌面歌词" }, float = true, no_blur = true })
hl.window_rule({ match = { title = "flameshot" }, float = true, no_blur = true })

hl.window_rule({
  match = { class = "flameshot" },
  rounding = 0,
  border_size = 0,
  -- 不要禁用初始焦点/activate,否则截图界面拿不到键盘焦点,快捷键会失效
  fullscreen_state = 0,
  float = true,
  pin = true,
  monitor = "eDP-1",
  move = { 0, 0 },
  size = { 4480, 1440 },
})
